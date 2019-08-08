timeout(5) {
  node("master") {
    stage("Create folder") {
      sh("mkdir -p ${FOLDER_NAME}")
      echo("${FOLDER_NAME} was successfully created.")
    }
  }
}
