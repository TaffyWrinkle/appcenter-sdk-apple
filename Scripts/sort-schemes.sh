#!/bin/bash

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# Sort the order of projects' schemes.
# Usage: sort-schemes.sh

# Alias for replacing symbols.
aliasNewLine='@'
aliasSpase='<space>'

# Scheme counter.
currentSchemeNumber=0;

replace_number_or_hide_scheme() {

    # Get params and remove aliases from schema name.
    schemeName="${1//${aliasSpase}/ }_^#shared#^_"
    fileName=$2
    isHidden=$3

    # Prepare the backup file.
    backupFile="${fileName}.bak"
    if $isHidden ; then

        # Regex for search place for insert hidden value.
        numberPattern="\(<key>${schemeName}<\/key>[${aliasNewLine}][[:space:]]*<dict>[${aliasNewLine}][[:space:]]*\)\(<key>orderHint\)"

        # Regex for insert hidden value.
        newNumberPattern="\1<key>isShown<\/key><false\/>${aliasNewLine}\2"
    else 

        # Regex for search the number of scheme.
        numberPattern="\(<key>${schemeName}<\/key>[${aliasNewLine}][[:space:]]*<dict>[${aliasNewLine}][[:space:]]*<key>orderHint<\/key>[${aliasNewLine}][[:space:]]*<integer>\)[0-9]*\(<\/integer>\)"
        
        # Regex for replacing the number of scheme.
        newNumberPattern="\1$currentSchemeNumber\2"
    fi

    # Replace new line to alias.
    tr '\n' "${aliasNewLine}" < ${fileName} > ${backupFile}

    # Replace number of scheme.
    sed -ie "s/${numberPattern}/${newNumberPattern}/" ${backupFile}

    # Replace alias to new line.
    tr "${aliasNewLine}" '\n' < ${backupFile} > ${fileName}

    # Remove backup file.
    rm ${backupFile}

    # Increase number of scheme.
    if ! $isHidden ; then
        currentSchemeNumber=$((currentSchemeNumber+1))
    fi
}

sort_schemes_function () {

    # Get params.
    projectName=$1
    isHidden=$2

    # Build path to file of scheme.
    fileName="${projectName}/xcuserdata/$USER.xcuserdatad/xcschemes/xcschememanagement.plist"

    # Build path to schemes directory.
    directoryName="${projectName}/xcshareddata/xcschemes/*"

    # Check that the scheme file exists.
    if [ -f $fileName ]; then

        # Sort schemes in project.
        for file in ${directoryName}; do

            # Get file name without full path.
            scheme="${file##*/}"

            # Prepare scheme name for passing to replacing function.
            schemeName="${scheme// /${aliasSpase}}"

            # Call replacing function.
            replace_number_or_hide_scheme ${schemeName} ${fileName} ${isHidden}
        done
    else
        echo "The file $fileName not exist."
    fi
}

# Sort scheme in the AppCenter.xcworkspace project.
sort_schemes_function "AppCenter.xcworkspace" false

# Sort schemes in modules projects.
sort_schemes_function "AppCenter/AppCenter.xcodeproj" false
sort_schemes_function "AppCenterAnalytics/AppCenterAnalytics.xcodeproj" false
sort_schemes_function "AppCenterCrashes/AppCenterCrashes.xcodeproj" false
sort_schemes_function "AppCenterDistribute/AppCenterDistribute.xcodeproj" false
sort_schemes_function "AppCenterPush/AppCenterPush.xcodeproj" false

# Sort schemes in apps projects.
sort_schemes_function "Sasquatch/Sasquatch.xcodeproj" false
sort_schemes_function "SasquatchMac/SasquatchMac.xcodeproj" false
sort_schemes_function "SasquatchTV/SasquatchTV.xcodeproj" false

# Sort other schemes.
sort_schemes_function "CrashLib/CrashLib.xcodeproj" false
sort_schemes_function "Vendor/PLCrashReporter/CrashReporter.xcodeproj" false
sort_schemes_function "Vendor/OCMock/Source/OCMock.xcodeproj" true
sort_schemes_function "Vendor/OCHamcrest/Source/OCHamcrest.xcodeproj" true
