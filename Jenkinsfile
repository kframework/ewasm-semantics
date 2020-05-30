pipeline {
  agent {
    dockerfile {
      label 'docker'
      additionalBuildArgs '--build-arg K_COMMIT=$(cd deps/wasm-semantics/deps/k && git rev-parse --short=7 HEAD) --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  options { ansiColor('xterm') }
  stages {
    stage('Init title') {
      when { changeRequest() }
      steps { script { currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}" } }
    }
    stage('Definition Deps') { steps { sh 'make definition-deps -j4' } }
    stage('Build')           { steps { sh 'make build -j4'           } }
    stage('Test') {
      options { timeout(time: 15, unit: 'MINUTES') }
      parallel {
        stage('Execution') { steps { sh 'make test-execution -j4' } }
        stage('Proofs')    { steps { sh 'make test-prove -j4'     } }
      }
    }
  }
}

