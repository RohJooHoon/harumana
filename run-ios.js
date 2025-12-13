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

async function openSimulator() {
    log('📱 iOS 시뮬레이터를 실행 중...', colors.blue);

    return new Promise((resolve, reject) => {
        exec('open -a Simulator', (error) => {
            if (error) {
                log(`❌ 시뮬레이터 실행 실패: ${error.message}`, colors.red);
                reject(error);
                return;
            }
            log('✅ iOS 시뮬레이터 실행 명령 전송됨', colors.green);
            resolve();
        });
    });
}

async function checkXcodeSetup() {
    return new Promise((resolve) => {
        exec('xcode-select -p', (error, stdout) => {
            if (error) {
                resolve(false);
                return;
            }
            // Command Line Tools만 설치된 경우 (/Library/Developer/CommandLineTools)는 시뮬레이터 사용 불가
            // 전체 Xcode가 설치된 경우만 true (/Applications/Xcode.app/...)
            const isFullXcode = stdout.trim().includes('/Applications/Xcode.app');
            resolve(isFullXcode);
        });
    });
}

async function waitForSimulator() {
    log('⏳ 시뮬레이터가 완전히 부팅될 때까지 대기 중...', colors.yellow);

    // Xcode 설정 확인
    const xcodeConfigured = await checkXcodeSetup();
    if (!xcodeConfigured) {
        log('⚠️  Xcode가 설정되지 않았습니다. 시뮬레이터 대기를 건너뜁니다.', colors.yellow);
        log('💡 iOS 시뮬레이터를 사용하려면 Xcode 설정이 필요합니다:', colors.blue);
        log('   1. App Store에서 Xcode 설치', colors.blue);
        log('   2. sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer', colors.blue);
        log('   3. sudo xcodebuild -runFirstLaunch', colors.blue);
        log('', colors.reset);
        log('📱 macOS나 Chrome에서 실행 가능합니다.\n', colors.green);
        return false;
    }

    const maxAttempts = 30; // 최대 30번 시도 (약 60초)
    let attempts = 0;

    while (attempts < maxAttempts) {
        attempts++;

        try {
            // Flutter devices로 확인
            const flutterOutput = await new Promise((resolve, reject) => {
                exec(`${flutterBinPath} devices`, (error, stdout) => {
                    if (error) {
                        reject(error);
                        return;
                    }
                    resolve(stdout);
                });
            });

            // iOS 시뮬레이터가 리스트에 있는지 확인
            if (flutterOutput.includes('iPhone') || flutterOutput.includes('iPad') || flutterOutput.includes('iOS Simulator')) {
                console.log(); // 새 줄
                log('✅ iOS 시뮬레이터 준비 완료!', colors.green);
                return true;
            }

            // 진행 상황 표시
            process.stdout.write(`\r${colors.yellow}⏳ 시뮬레이터 대기 중... (${attempts}/${maxAttempts})${colors.reset}`);

            // 2초 대기
            await new Promise(resolve => setTimeout(resolve, 2000));

        } catch (error) {
            // flutter devices 명령이 실패해도 계속 시도
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
    }

    console.log(); // 새 줄
    log('⚠️  iOS 시뮬레이터를 찾을 수 없습니다.', colors.yellow);
    log('macOS나 Chrome에서 실행할 수 있습니다.', colors.blue);
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
        log('🎯 iOS 시뮬레이터 + Flutter 실행 스크립트', colors.bright);
        log('========================================\n', colors.bright);

        // Xcode 설정 확인
        const xcodeConfigured = await checkXcodeSetup();

        if (xcodeConfigured) {
            // 1. 시뮬레이터 실행
            await openSimulator();

            // 2. 시뮬레이터가 준비될 때까지 대기
            await waitForSimulator();
        } else {
            // Xcode가 없으면 시뮬레이터 열기 건너뜀
            log('⚠️  Xcode가 설정되지 않아 시뮬레이터를 건너뜁니다.', colors.yellow);
            log('💡 iOS 시뮬레이터를 사용하려면 Xcode 설정이 필요합니다:', colors.blue);
            log('   1. App Store에서 Xcode 설치', colors.blue);
            log('   2. sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer', colors.blue);
            log('   3. sudo xcodebuild -runFirstLaunch', colors.blue);
            log('', colors.reset);
            log('📱 macOS나 Chrome에서 실행합니다.\n', colors.green);
        }

        // 3. Flutter 실행
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
