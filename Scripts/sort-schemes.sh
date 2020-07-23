#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Alias for replacing symbols.
aliasNewLine='@'
aliasSpase='<space>'

# Schemes and platforms for sort modules schemes.
supportPlatforms=("iOS" "macOS" "tvOS")
schemeModules=("Documentation" "Fat${aliasSpase}Framework" "Framework")
schemeMainProject=("All${aliasSpase}Documentation" "All${aliasSpase}Fat${aliasSpase}Frameworks" "All${aliasSpase}Frameworks+Documentation" "All${aliasSpase}XCFrameworks" "All${aliasSpase}iOS${aliasSpase}Frameworks" "All${aliasSpase}macOS${aliasSpase}Frameworks" "All${aliasSpase}tvOS${aliasSpase}Frameworks")

# Apps schemes.
schemeSasquatchiOS=("SasquatchObjC" "SasquatchObjC" "SasquatchPuppet" "SasquatchSwift${aliasSpase}Extension" "SasquatchSwift-Preview${aliasSpase}Extension" "SasquatchSwift-Preview${aliasSpase}XCFrameworks" "SasquatchSwift-Preview" "SasquatchSwift" "SasquatchWatchObjC" "SasquatchWatchSwift")
schemeSasquatchTV=("SasquatchTVObjC-Preview" "SasquatchTVObjC" "SasquatchTVSwift-Preview" "SasquatchTVSwift")
schemeSasquatchMac=("SasquatchMacObjC-Preview" "SasquatchMacObjC" "SasquatchMacSwift-Extension" "SasquatchMacSwift-Preview" "SasquatchMacSwift")

# Other libs schemes.
schemeCrashLib=("CrashLibIOS" "CrashLibMac" "CrashLibTV" "CrashLibWatch")
schemeCrashReporter=("CrashReporter${aliasSpase}XCFramework" "CrashReporter${aliasSpase}iOS${aliasSpase}Framework" "CrashReporter${aliasSpase}iOS${aliasSpase}Universal" "CrashReporter${aliasSpase}iOS" "CrashReporter${aliasSpase}macOS${aliasSpase}Framework" "CrashReporter${aliasSpase}macOS" "CrashReporter${aliasSpase}tvOS${aliasSpase}Framework" "CrashReporter${aliasSpase}tvOS${aliasSpase}Universal" "CrashReporter${aliasSpase}tvOS" "DemoCrash${aliasSpase}iOS" "DemoCrash${aliasSpase}macOS" "DemoCrash${aliasSpase}tvOS" "Disk${aliasSpase}Image" "Documentation" "Fuzz${aliasSpase}Testing" "plcrashutil")
schemeOCMock=("OCMock${aliasSpase}iOS" "OCMock${aliasSpase}tvOS" "OCMock${aliasSpase}watchOS" "OCMock" "OCMockLib")
schemeOCHamcrest=("OCHamcrest-iOS" "OCHamcrest-tvOS" "OCHamcrest-watchOS" "OCHamcrest" "libochamcrest")

# Scheme counter.
currentSchemeNumber=0;

replace_number() {
    schemeName="${1//${aliasSpase}/ }.xcscheme_^#shared#^_"
    fileName=$2
    backupFile="${fileName}.bak"

    # Regex for search the number of scheme.
    numberPattern="\(<key>${schemeName}<\/key>[${aliasNewLine}][[:space:]]*<dict>[${aliasNewLine}][[:space:]]*<key>orderHint<\/key>[${aliasNewLine}][[:space:]]*<integer>\)[0-9]*\(<\/integer>\)"
    
    # Regex for replacing the number of scheme.
    newNumberPattern="\1$currentSchemeNumber\2"

    # Replace new line to alias.
    tr '\n' "${aliasNewLine}" < ${fileName} > ${backupFile}

    # Replace number of scheme.
    sed -ie "s/${numberPattern}/${newNumberPattern}/" ${backupFile}

    # Replace alias to new line.
    tr "${aliasNewLine}" '\n' < ${backupFile} > ${fileName}

    # Remove backup file.
    rm ${backupFile}

    # Increase number of scheme.
    currentSchemeNumber=$((currentSchemeNumber+1))
}

sort_modules_schemes_function () {

    # Module name.
    projectName=$1

    # Build path to scheme.
    fileName="${projectName}/${projectName}.xcodeproj/xcuserdata/$USER.xcuserdatad/xcschemes/xcschememanagement.plist"

    # Check that the scheme file exists.
    if [ -f $fileName ]; then
    
        # Build full scheme name for each module.
        schemeName="${projectName}${aliasSpase}XCFramework"
        replace_number ${schemeName} ${fileName}

        for platform in ${!supportPlatforms[*]} ; do
            for scheme in ${!schemeModules[*]} ; do
                
                # Build regex for replacing to number of scheme.
                schemeName="${projectName}${aliasSpase}${supportPlatforms[platform]}${aliasSpase}${schemeModules[scheme]}"
                replace_number ${schemeName} ${fileName}
            done
        done
    else
        echo "The file $fileName not exist."
    fi
}

sort_apps_schemes_function() {

    # Get array with schemes.
    schemes=("$@")
    ((last_idx=${#schemes[@]} - 1))

    # Directory where placed the .xcodeproj.
    directory=${schemes[last_idx]}
    unset schemes[last_idx]
   
    # Build path to scheme.
    fileName="${directory}/xcuserdata/$USER.xcuserdatad/xcschemes/xcschememanagement.plist"
    
    # Check that the scheme file exists.
    if [ -f $fileName ]; then

        # Sort schemes in App Center modules.
        for scheme in "${schemes[@]}" ; do

            # Build scheme name.
            schemeName="${scheme}"
            replace_number ${schemeName} ${fileName}
        done
    else
        echo "The file $fileName not exist."
    fi
}

# Sort scheme in the AppCenter.xcworkspace project.
sort_apps_schemes_function "${schemeMainProject[@]}" "AppCenter.xcworkspace"

# Sort schemes in modules projects.
sort_modules_schemes_function "AppCenter" 
sort_modules_schemes_function "AppCenterAnalytics" 
sort_modules_schemes_function "AppCenterCrashes" 
sort_modules_schemes_function "AppCenterDistribute" 
sort_modules_schemes_function "AppCenterPush" 

# Sort schemes in apps projects.
sort_apps_schemes_function "${schemeSasquatchiOS[@]}" "Sasquatch/Sasquatch.xcodeproj"
sort_apps_schemes_function "${schemeSasquatchMac[@]}" "SasquatchMac/SasquatchMac.xcodeproj" 
sort_apps_schemes_function "${schemeSasquatchTV[@]}" "SasquatchTV/SasquatchTV.xcodeproj"

# Sort other schemes.
sort_apps_schemes_function "${schemeCrashLib[@]}" "CrashLib/CrashLib.xcodeproj"
sort_apps_schemes_function "${schemeCrashReporter[@]}" "Vendor/PLCrashReporter/CrashReporter.xcodeproj"
sort_apps_schemes_function "${schemeOCMock[@]}" "Vendor/OCMock/Source/OCMock.xcodeproj"
sort_apps_schemes_function "${schemeOCHamcrest[@]}" "Vendor/OCHamcrest/Source/OCHamcrest.xcodeproj"
