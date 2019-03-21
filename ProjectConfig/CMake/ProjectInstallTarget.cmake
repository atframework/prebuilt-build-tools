function (ProjectSetupInstallLib TARGET_NAME CMAKE_INSTALL_LIBDIR VERSION_MAJOR VERSION_MINOR VERSION_PATCH)
    set("${TARGET_NAME}_VERSION_MAJOR" ${VERSION_MAJOR})
    set("${TARGET_NAME}_VERSION_MINOR" ${VERSION_MINOR})
    set("${TARGET_NAME}_VERSION_PATCH" ${VERSION_PATCH})
    set("${TARGET_NAME}_VERSION" "${${TARGET_NAME}_VERSION_MAJOR}.${${TARGET_NAME}_VERSION_MINOR}.${${TARGET_NAME}_VERSION_PATCH}")
    set(TARGET_VERSION ${${TARGET_NAME}_VERSION})

    # Install configuration
    set(CMAKE_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake" CACHE STRING "Directory relative to CMAKE_INSTALL to install the cmake configuration files")

    include(CMakePackageConfigHelpers)
    set(INCLUDE_INSTALL_DIR include)

    file(MAKE_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake")

    configure_package_config_file(
        "${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/ProjectInstallConfig.cmake.in"
        "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/${TARGET_NAME}Config.cmake"
        INSTALL_DESTINATION ${CMAKE_INSTALL_CMAKEDIR}
        PATH_VARS TARGET_NAME TARGET_VERSION INCLUDE_INSTALL_DIR CMAKE_INSTALL_LIBDIR PROJECT_SOURCE_DIR
        NO_CHECK_REQUIRED_COMPONENTS_MACRO
    )

    write_basic_package_version_file(
        "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/${TARGET_NAME}ConfigVersion.cmake"
        VERSION ${TARGET_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(
        FILES "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/${TARGET_NAME}Config.cmake" "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/cmake/${TARGET_NAME}ConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_CMAKEDIR}
    )

endfunction()
