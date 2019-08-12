pipeline {

    agent { label 'aap' }

    environment {
        ANDROID_HOME = "/Users/apesotskiy/Library/Android/sdk"
        ANDROID_SERIAL = "emulator-5554"
        zdAutomationRun = "true"
    }

    stages {
        stage('Clean Workspace') {
            steps{
                cleanWs()
            }
        }
        stage('Checkout Repo') {
            steps {
              checkout([$class: 'GitSCM',
                branches: [[name: '*/master']],
                doGenerateSubmoduleConfigurations: false,
                extensions: [[$class: 'CleanCheckout']],
                submoduleCfg: [],
                userRemoteConfigs: [[credentialsId: 'b0999eff-a7df-44f6-9aeb-84f639a1ddcb', url: 'git@github.com:zendesk/zendesk_scarlett_android.git']]
              ])
            }
        }
        stage('Reset Devices, download Composer') {
            steps {
                sh ''' set -x
                   $ANDROID_HOME/platform-tools/adb kill-server
                   $ANDROID_HOME/platform-tools/adb devices
                   #Below line due to: https://issuetracker.google.com/issues/37078920
                   $ANDROID_HOME/platform-tools/adb shell settings put secure long_press_timeout 2500
                   # Download composer from jcenter
                   COMPOSER_VERSION=0.2.9
                   curl --fail --location https://jcenter.bintray.com/com/gojuno/composer/composer/${COMPOSER_VERSION}/composer-${COMPOSER_VERSION}.jar --output composer.jar '''
            }
        }
        stage('Build Debug and Test App') {
            steps {
                sh ''' set -x
                   # Get both the regular app and the test app
                   ./gradlew app:assembleDebug app:assembleAndroidTest
                   cp app/build/outputs/apk/development/debug/app-development-debug.apk app.apk
                   cp app/build/outputs/apk/androidTest/development/debug/app-development-debug-androidTest.apk appTest.apk'''
            }
        }
        stage('Run Tests') {
            // Setting a MAX timeout to jobs start and finish, if the job takes more than 45 minutes will be automatically canceled
            // Setting a retry MAX 1 in case of some of the stage fails
            options {
                retry(1)
                timeout(time: 45, unit: 'MINUTES')
            }
            steps {
                sh ''' set -x
                    # Run tests using Composer
                    java -jar composer.jar \
                    --apk app.apk \
                    --test-apk appTest.apk \
                    --test-package com.zendesk.android.test \
                    --test-runner com.zendesk.android.utils.TestRunner \
                    --output-directory artifacts/composer-output \
                    --instrumentation-arguments package com.zendesk.android.suites \
                    --verbose-output false \
                    --device-pattern "emulator.+" \
                    --shard true'''
            }
        }
    }

    post {
        always {
            publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'artifacts/composer-output/html-report', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
            junit allowEmptyResults: true, testResults: 'artifacts/composer-output/junit4-reports/*.xml'
        }
    }
}
