function(find_sign_tool result)
  find_program(
    sign_tool
    NAMES SignTool
    REQUIRED
  )

  set(${result} "${sign_tool}")

  return(PROPAGATE ${result})
endfunction()

function(code_sign_windows target)
  set(one_value_keywords
    PATH
    TARGET
    SUBJECT_NAME
    THUMBPRINT
    TIMESTAMP
  )

  set(multi_value_keywords
    DEPENDS
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "" "${one_value_keywords}" "${multi_value_keywords}"
  )

  if(ARGV_TARGET)
    set(ARGV_TARGET $<TARGET_FILE:${ARGV_TARGET}>)

    list(APPEND ARGV_DEPENDS ${ARGV_TARGET})
  else()
    cmake_path(ABSOLUTE_PATH ARGV_PATH NORMALIZE)
  endif()

  if(NOT ARGV_TIMESTAMP)
    set(ARGV_TIMESTAMP "http://timestamp.digicert.com")
  endif()

  if(ARGV_SUBJECT_NAME)
    list(APPEND args /n "${ARGV_SUBJECT_NAME}")
  endif()

  if(ARGV_THUMBPRINT)
    list(APPEND args /sha1 "${ARGV_THUMBPRINT}")
  endif()

  list(APPEND args /a /fd SHA256 /t "${ARGV_TIMESTAMP}")

  find_sign_tool(sign_tool)

  add_custom_target(
    ${target}
    ALL
    COMMAND ${sign_tool} sign ${args} "${ARGV_PATH}"
    DEPENDS ${ARGV_DEPENDS}
  )
endfunction()
