project_environment_servers = [
  dev:  [ '10.0.3.96' ]
]

if (BRANCH_NAME == 'master') {
  project_environment_servers['prod'] = [ '10.0.3.48' ]
}

pipeline {
    agent {
        label 'master'
    }
    
    parameters {
        string(name: 'version', description: "Version of nexus artifact")
	choice(name: 'environment', choices: project_environment_servers.keySet() as ArrayList)
    }

    options {
        skipDefaultCheckout()
    }
    
    stages {
        stage("Test") {
            steps {
                script {
	            currentBuild.displayName = "${version} to ${environment}"
                    sshagent(credentials : ['ubuntu-slave']) {
                        withCredentials([usernameColonPassword(credentialsId: 'nexus', variable: 'USERPASS')]) {
 
                            slaves = project_environment_servers[params.environment]
                            for (slave in slaves) {
                                sh """\
                                ssh -o StrictHostKeyChecking=no ubuntu@${slave} <<EOF
                                    set -xe
                                    cd /opt/backend
                                    curl -sSL -X GET -G "http://nexus.shavlyuk-ci.test.coherentprojects.net/service/rest/v1/search/assets" \
                                        -d repository=maven-releases \
                                        -d maven.groupId=issoft.training \
                                        -d maven.artifactId=backend \
                                        -d maven.baseVersion=${params.version} \
                                        -d maven.extension=jar \
                                        -u ${USERPASS} \
                                        | grep -Po '"downloadUrl" : "\\K.+(?=",)' \
                                        | sudo xargs curl -fsSL -o backend.jar -u ${USERPASS}
                                    sudo systemctl restart backend
                                EOF
                                """.stripIndent()
                            }
                        }
                    }
                }
            }
        }
    }
}
