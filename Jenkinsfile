pipeline {
  agent { dockerfile { reuseNode true } }
  options { ansiColor('xterm') }
  stages {
    stage('Init title') {
      when { changeRequest() }
      steps { script { currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}" } }
    }
    stage('Dependencies') { steps { sh 'make deps'      } }
    stage('Build')        { steps { sh 'make build -j4' } }
    stage('Test') {
      options { timeout(time: 15, unit: 'MINUTES') }
      parallel {
        stage('Execution') { steps { sh 'make test-execution -j4' } }
        stage('Proofs')    { steps { sh 'make test-prove -j4'     } }
      }
    }
  }
}

