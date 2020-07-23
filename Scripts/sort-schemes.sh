#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Alias for replacing symbols.
aliasNewLine='@'
aliasSpase='<space>'

# Scheme counter.
currentSchemeNumber=0;

replace_number() {
    schemeName="${1//${aliasSpase}/ }_^#shared#^_"
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

sort_schemes_function () {

    # Module name.
    projectName=$1

    # Build path to scheme.
    fileName="${projectName}/xcuserdata/$USER.xcuserdatad/xcschemes/xcschememanagement.plist"

    # Build path to schemes directory.
    directoryName="${projectName}/xcshareddata/xcschemes/*"

    # Check that the scheme file exists.
    if [ -f $fileName ]; then

        # Sort schemes in App Center modules.
        for file in ${directoryName}; do
            scheme="${file##*/}"

            # Build scheme name.
            schemeName="${scheme// /${aliasSpase}}"
                
            # Build regex for replacing to number of scheme.
            replace_number ${schemeName} ${fileName}
        done
    else
        echo "The file $fileName not exist."
    fi
}

# Sort scheme in the AppCenter.xcworkspace project.
sort_schemes_function "AppCenter.xcworkspace"

# Sort schemes in modules projects.
sort_schemes_function "AppCenter/AppCenter.xcodeproj" 
sort_schemes_function "AppCenterAnalytics/AppCenterAnalytics.xcodeproj" 
sort_schemes_function "AppCenterCrashes/AppCenterCrashes.xcodeproj" 
sort_schemes_function "AppCenterDistribute/AppCenterDistribute.xcodeproj" 
sort_schemes_function "AppCenterPush/AppCenterPush.xcodeproj" 

# Sort schemes in apps projects.
sort_schemes_function "Sasquatch/Sasquatch.xcodeproj"
sort_schemes_function "SasquatchMac/SasquatchMac.xcodeproj" 
sort_schemes_function "SasquatchTV/SasquatchTV.xcodeproj"

# Sort other schemes.
sort_schemes_function "CrashLib/CrashLib.xcodeproj"
sort_schemes_function "Vendor/PLCrashReporter/CrashReporter.xcodeproj"
sort_schemes_function "Vendor/OCMock/Source/OCMock.xcodeproj"
sort_schemes_function "Vendor/OCHamcrest/Source/OCHamcrest.xcodeproj"
