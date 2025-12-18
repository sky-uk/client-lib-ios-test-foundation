pipeline {
    agent {
        label 'macos-agent'
    }
    
    options {
        skipDefaultCheckout(false)
        buildDiscarder(logRotator(daysToKeepStr: '30'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                script {
                    sh '''
                        current_value=$(defaults read com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM 2>/dev/null || echo "0")
                        if [ "$current_value" != "1" ]; then
                            sudo defaults write com.apple.dt.Xcode IDEPackageSupportUseBuiltinSCM YES
                            echo "Xcode setting updated"
                        else
                            echo "Xcode setting already configured"
                        fi
                    '''
                }
            }
        }
        
        stage('Configure SSH') {
            steps {
                script {
                    sh '''
                        # Add GitHub to SSH Known Hosts
                        rm ~/.ssh/id_rsa || true
                        for ip in $(dig @8.8.8.8 github.com +short); do 
                            ssh-keyscan github.com,$ip
                            ssh-keyscan $ip
                        done 2>/dev/null >> ~/.ssh/known_hosts || true
                    '''
                }
            }
        }
        
        stage('Build & Test') {
            steps {
                script {
                    sh '''
                        #!/bin/bash
                        set -eo pipefail
                        swift test
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo 'Build and tests completed successfully!'
        }
        failure {
            echo 'Build or tests failed.'
        }
        always {
            cleanWs()
        }
    }
}
