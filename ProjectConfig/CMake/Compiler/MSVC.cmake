

add_definitions(/wd"4458" /wd"4456" /wd"4477" /wd"4595")
add_definitions(/Zo /Zi)

add_compiler_define(
    WIN32
    NDEBUG
    _WINDOWS
    _USRDLL
    NIDEBUG
    EE_EFD_IMPORT
    EE_EFD_CONFIG_RELEASE
    _SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
)

add_linker_flags_for_runtime(
    /DEBUG
    /INCREMENTAL
)

if (MSVC_VERSION GREATER 1919)
    # FIXME TODO-PLATFORM 临时关闭版本检查
    add_definitions(/Wv:18)
endif ()
