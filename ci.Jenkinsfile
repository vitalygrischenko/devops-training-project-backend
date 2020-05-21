import java.time.*

def version = "${BRANCH_NAME}.${BUILD_NUMBER}.${new Date().format('yyyy-MM-dd_HH-mm')}"

pipeline {
    
    environment {
        gradle_skip_analysis = "-x findbugsMain -x findbugsTest -x pmdMain -x pmdTest -x checkstyleMain -x checkstyleTest"
    }
    
    agent {
        label "master"
    }
    stages {
        stage("Build") {
            steps {
	        script {
	            currentBuild.displayName = version
		}
                dir("backend") {
                    sh "./gradlew build -Pversion=${version} -x test ${gradle_skip_analysis}"
                }
            }
        }
        stage("Test") {
            steps {
                dir("backend") {
                    sh "./gradlew test -Pversion=${version} ${gradle_skip_analysis} || true"
                }
            }
        }
        stage("Analyze") {
            steps {
                dir("backend") {
                    withSonarQubeEnv('main') {
                        sh './gradlew sonarqube -x test ${gradle_skip_analysis}'
                    }
                }
            }
        }
        stage("Push") {
            steps {
                dir("backend") {
                    nexusPublisher nexusInstanceId: 'main',
                        nexusRepositoryId: 'maven-releases',
                        packages: [[
                            $class: 'MavenPackage',
                            mavenAssetList: [[classifier: '', extension: '', filePath: "./build/libs/backend-${version}.jar"]],
                            mavenCoordinate: [groupId: 'issoft.training', artifactId: 'backend', version: version, packaging: 'jar']
                        ]]
                }
            }
        }
        stage("Trigger deploy") {
	    steps {
	        script {
                    build job: "backend-cd-multibranch/${env.BRANCH_NAME}/",
		        parameters: [
		            [$class: 'StringParameterValue', name: 'version', value: version],
		            [$class: 'StringParameterValue', name: 'environment', value: (env.BRANCH_NAME == 'master') ? 'prod' : 'dev']
		        ],
		        wait: false
		}
	    }
	}
    }
}
