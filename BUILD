load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

ios_application(
    name = "XcodeReleases",
    bundle_id = "com.jefflett.XcodeReleases",
    families = [
        "iphone",
        "ipad",
    ],
    minimum_os_version = "12.0",
    infoplists = ["XcodeReleases/XcodeReleases/Resources/Info.plist"],
    visibility = ["//visibility:public"],
    deps = [":XcodeReleasesLib"],
)

swift_library(
    name = "XcodeReleasesLib",
    srcs = glob([
      "XcodeReleases/XcodeReleases/**/*.swift"
    ]),
    visibility = [],
    deps = [":XcodeReleasesKit"]
)

swift_library(
    name = "XcodeReleasesKit",
        srcs = glob([
        "XcodeReleasesKit/Sources/**/*.swift",
    ]),
    visibility = [],
    deps = [],
)
