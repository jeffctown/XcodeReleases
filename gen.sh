#!/bin/bash
buck project //XcodeReleasesKit:XcodeReleasesKit
buck project //XcodeReleases:XcodeReleases
open XcodeReleases/XcodeReleases.xcworkspace/
