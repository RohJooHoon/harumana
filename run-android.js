#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');

// 색상 코드
const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    green: '\x1b[32m',
    blue: '\x1b[34m',
    yellow: '\x1b[33m',
    red: '\x1b[31m',
};

function log(message, color = colors.reset) {
    console.log(`${color}${message}${colors.reset}`);
}

// Flutter 경로 설정
const flutterBinPath = 'flutter';

async function checkAndroidSetup() {
    return new Promise((resolve) => {
        exec(`${flutterBinPath} doctor`, (error, stdout) => {
            if (error) {
                resolve({ configured: false, message: 'Flutter doctor 실행 실패' });
                return;
            }

            // Android toolchain이 설정되어 있는지 확인
            const hasAndroid = stdout.includes('Android toolchain') && !stdout.includes('[✗] Android toolchain');

            if (!hasAndroid) {
                resolve({
                    configured: false,
                    message: 'Android SDK가 설치되지 않았습니다.'
                });
                return;
            }

            resolve({ configured: true });
        });
    });
}

async function getAvailableEmulators() {
    return new Promise((resolve, reject) => {
        exec(`${flutterBinPath} emulators`, (error, stdout) => {
            if (error) {
                reject(error);
                return;
            }

            // 에뮬레이터 파싱
            const lines = stdout.split('\n').filter(line => line.trim().length > 0);
            const emulators = lines
                .filter(line => line.includes('•'))
                .map(line => {
                    const match = line.match(/(\S+)\s+•\s+(.+)/);
                    if (match) {
                        return { id: match[1], name: match[2].trim() };
                    }
                    return null;
                })
                .filter(e => e !== null);

            resolve(emulators);
        });
    });
}

async function launchEmulator(emulatorId) {
    log(`🚀 안드로이드 에뮬레이터 실행 중: ${emulatorId}`, colors.blue);

    return new Promise((resolve, reject) => {
        exec(`${flutterBinPath} emulators --launch ${emulatorId}`, (error) => {
            if (error) {
                log(`❌ 에뮬레이터 실행 실패: ${error.message}`, colors.red);
                reject(error);
                return;
            }
            log('✅ 에뮬레이터 실행 명령 전송됨', colors.green);
            resolve();
        });
    });
}

async function waitForEmulator() {
    log('⏳ 에뮬레이터가 완전히 부팅될 때까지 대기 중...', colors.yellow);

    const maxAttempts = 60; // 최대 60번 시도 (약 120초)
    let attempts = 0;

    while (attempts < maxAttempts) {
        attempts++;

        try {
            const output = await new Promise((resolve, reject) => {
                exec(`${flutterBinPath} devices`, (error, stdout) => {
                    if (error) {
                        reject(error);
                        return;
                    }
                    resolve(stdout);
                });
            });

            // 안드로이드 에뮬레이터가 리스트에 있는지 확인
            if (output.includes('android') || output.includes('emulator')) {
                console.log(); // 새 줄
                log('✅ 안드로이드 에뮬레이터 준비 완료!', colors.green);
                return true;
            }

            // 진행 상황 표시
            process.stdout.write(`\r${colors.yellow}⏳ 에뮬레이터 대기 중... (${attempts}/${maxAttempts})${colors.reset}`);

            // 2초 대기
            await new Promise(resolve => setTimeout(resolve, 2000));

        } catch (error) {
            // flutter devices 명령이 실패해도 계속 시도
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
    }

    console.log(); // 새 줄
    log('⚠️  에뮬레이터를 찾을 수 없습니다.', colors.yellow);
    return false;
}

async function runFlutter() {
    log('🚀 Flutter 앱을 실행 중...', colors.blue);

    return new Promise((resolve, reject) => {
        const flutter = spawn(flutterBinPath, ['run'], {
            cwd: __dirname,
            stdio: 'inherit'
        });

        flutter.on('error', (error) => {
            log(`❌ Flutter 실행 실패: ${error.message}`, colors.red);
            reject(error);
        });

        flutter.on('close', (code) => {
            if (code === 0) {
                log('✅ Flutter 앱 종료됨', colors.green);
                resolve();
            } else {
                log(`❌ Flutter가 오류 코드 ${code}로 종료됨`, colors.red);
                reject(new Error(`Flutter exited with code ${code}`));
            }
        });
    });
}

async function main() {
    try {
        log('========================================', colors.bright);
        log('🤖 안드로이드 에뮬레이터 + Flutter 실행 스크립트', colors.bright);
        log('========================================\n', colors.bright);

        // 1. Android 설정 확인
        log('🔍 안드로이드 설정 확인 중...', colors.blue);
        const androidCheck = await checkAndroidSetup();

        if (!androidCheck.configured) {
            log('⚠️  ' + androidCheck.message, colors.red);
            log('', colors.reset);
            log('안드로이드 에뮬레이터를 사용하려면 Android SDK 설정이 필요합니다:', colors.yellow);
            log('1. Android Studio 설치: https://developer.android.com/studio', colors.yellow);
            log('2. Android Studio에서 SDK 및 에뮬레이터 설정', colors.yellow);
            log('3. flutter doctor --android-licenses 실행하여 라이센스 동의', colors.yellow);
            log('', colors.reset);
            log('지금은 다른 플랫폼(macOS, Chrome)에서 실행할 수 있습니다.\n', colors.blue);

            // 그래도 Flutter 실행 시도
            await runFlutter();
            return;
        }

        log('✅ 안드로이드 설정 확인 완료\n', colors.green);

        // 2. 사용 가능한 에뮬레이터 확인
        log('🔍 사용 가능한 에뮬레이터 확인 중...', colors.blue);

        let emulators = [];
        try {
            emulators = await getAvailableEmulators();
        } catch (error) {
            log('⚠️  에뮬레이터를 찾을 수 없습니다.', colors.yellow);
            log('Android Studio에서 AVD(Android Virtual Device)를 생성해주세요.\n', colors.yellow);
            await runFlutter();
            return;
        }

        if (emulators.length === 0) {
            log('⚠️  생성된 에뮬레이터가 없습니다.', colors.yellow);
            log('Android Studio > AVD Manager에서 에뮬레이터를 생성해주세요.\n', colors.yellow);
            await runFlutter();
            return;
        }

        log(`✅ ${emulators.length}개의 에뮬레이터 발견:`, colors.green);
        emulators.forEach((emu, index) => {
            log(`   ${index + 1}. ${emu.name} (${emu.id})`, colors.blue);
        });
        log('');

        // 3. 첫 번째 에뮬레이터 실행
        const selectedEmulator = emulators[0];
        await launchEmulator(selectedEmulator.id);

        // 4. 에뮬레이터가 준비될 때까지 대기
        await waitForEmulator();

        // 5. Flutter 실행
        await runFlutter();

    } catch (error) {
        log(`\n💥 오류 발생: ${error.message}`, colors.red);
        process.exit(1);
    }
}

// Ctrl+C 처리
process.on('SIGINT', () => {
    log('\n\n👋 종료 중...', colors.yellow);
    process.exit(0);
});

main();
