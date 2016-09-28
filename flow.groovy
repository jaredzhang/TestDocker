node() {
  deleteDir()

  stage ('Checkout') {
    checkout scm
  }

  //prefix = 'docker run -i --rm jaredzhang09/android-docker:latest'
  stage ('Create Env') {
    docker.image('jaredzhang09/android-docker-minimum:latest').inside {  
      
      stage ('Build') {
        sh "pwd"
        sh "ls"
        sh "id"
        sh "./gradlew clean assembleDebug"
        archive 'app/build/outputs/**/app-debug.apk'
      }

      stage ('Quality') {
        sh "./gradlew lint"
        stash includes: '*/build/outputs/lint-results*.xml', name: 'lint-reports'
      }
   
      stage ('Test (unit)') {
        try {
          sh "./gradlew test"
        } catch (err) {
            currentBuild.result = 'UNSTABLE'
        }
        stash includes: '**/test-results/**/*.xml', name: 'junit-reports'
      }

      stage ('Test (device)') {
        sh "./gradlew :app:assembleDebug :app:assembleDebugAndroidTest"
        // Archive for downstream AWS job
        archive 'app/build/outputs/**/*androidTest*.apk'
      }
    }
  }
}

//node() {
//  build "${env.JOB_NAME} (AWS)"
//}

stage 'Report'
node() {
  deleteDir()

  unstash 'junit-reports'
  step([$class: 'JUnitResultArchiver', testResults: '**/test-results/**/*.xml'])

  unstash 'lint-reports'
  step([$class: 'LintPublisher', canComputeNew: false, canRunOnFailed: true, defaultEncoding: '', healthy: '', pattern: '*/build/outputs/lint-results*.xml', unHealthy: ''])
}