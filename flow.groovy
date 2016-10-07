node() {
  deleteDir()

  stage ('Checkout') {
    checkout scm
  }

  //prefix = 'docker run -i --rm jaredzhang09/android-docker:latest'
  stage ('Create Env') {
    docker.image('jaredzhang09/android-docker-minimum:latest').inside {  
      
      stage ('Build') {
        sh "./gradlew clean assembleDebug"
        archive 'app/build/outputs/**/app-debug.apk'
      }
    }
  }
}

//node() {
//  build "${env.JOB_NAME} (AWS)"
//}