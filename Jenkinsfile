pipeline {

    agent {
        kubernetes {
            yamlFile 'kubernetesPod.yaml'
        }
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '3'))
    }


    stages {

        stage('Load maven cache repository from S3') {
            steps {
                container('builder') {
                    sh """
                        aws --region 'eu-west-1' s3 sync s3://oa-phaedra2-jenkins-maven-cache/  /home/jenkins/maven-repository --quiet
                        """
                }
            }
        }

        stage('Build') {
            steps {
                container('builder') {

                    configFileProvider([configFile(fileId: 'maven-settings-rsb', variable: 'MAVEN_SETTINGS_RSB')]) {

                        sh 'mvn -s $MAVEN_SETTINGS_RSB -U clean install -DskipTests -Ddockerfile.skip -Dmaven.repo.local=/home/jenkins/maven-repository'

                    }

                }
            }
        }

        stage("Deploy to Nexus") {
            steps {
                container('builder') {

                    configFileProvider([configFile(fileId: 'maven-settings-rsb', variable: 'MAVEN_SETTINGS_RSB')]) {

                        sh 'mvn -s $MAVEN_SETTINGS_RSB deploy -DskipTests -Ddockerfile.skip -Dmaven.repo.local=/home/jenkins/maven-repository'

                    }

                }
            }
        }

        stage('Cache maven repository to S3') {
            steps {
                container('builder') {
                    sh """
                        aws --region 'eu-west-1' s3 sync /home/jenkins/maven-repository s3://oa-phaedra2-jenkins-maven-cache/ --quiet
                        """
                }
            }
        }

    }

}
