##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into post-fs-data.sh or service.sh
# 5. Add your additional or modified system properties into system.prop
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
##########################################################################################

##########################################################################################
# Variables
##########################################################################################

# If you need even more customization and prefer to do everything on your own, declare SKIPUNZIP=1 in customize.sh to skip the extraction and applying default permissions/secontext steps.
# Be aware that by doing so, your customize.sh will then be responsible to install everything by itself.
SKIPUNZIP=1
# If you need to call busybox inside MAGISK
# Please mark ASH_STANDALONE=1 in customize.sh
ASH_STANDALONE=1


##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
# Install
##########################################################################################

# Extract $ZIPFILE to $MODPATH
ui_print "- Extracting module files... "
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

# Load lang
# locale=$(getprop persist.sys.locale|awk -F "-" '{print $1"_"$NF}')
# [[ ${locale} == "" ]] && locale=$(settings get system system_locales|awk -F "," '{print $1}'|awk -F "-" '{print $1"_"$NF}')
# if [ -e $MODPATH/lang/${locale}.ini ];then
#   if [ $locale != "" ];then
#       . $MODPATH/lang/en_US.ini
#   fi
#   . $MODPATH/lang/${locale}.ini
# else
#   . $MODPATH/lang/en_US.ini
# fi

# Precheck
ui_print "- Prechecking version of Android... "
if [ ! -e $MODPATH/system/app/NextPay_$API ] ;then
    abort "???????????? Android ?????????"
fi

# File processing
ui_print "- Processing files... "
mv $MODPATH/system/app/NextPay_$API $MODPATH/system/app/NextPay
rm -rf $MODPATH/system/app/NextPay_*
mv $MODPATH/system/app/TSMClient_$API $MODPATH/system/app/TSMClient
rm -rf $MODPATH/system/app/TSMClient_*

# Build processing
ui_print "- Processing system.prop... "
echo "" >> $MODPATH/system.prop
echo "ro.se.type=eSE,HCE,UICC" >> $MODPATH/system.prop

# Cache cleaning
ui_print "- Cleaning package cache... "
rm -rf /data/system/package_cache/*

# Delete extra files
ui_print "- Deleting extra files... "
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/tools $MODPATH/lang 4>/dev/null

##########################################################################################
# Permissions
##########################################################################################

# Note that all files/folders in magisk module directory have the $MODPATH prefix - keep this prefix on all of your files/folders
# Some examples:

# For directories (includes files in them):
# set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)

# set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
# set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

# For files (not in directories taken care of above)
# set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)

# set_perm $MODPATH/system/lib/libart.so 0 0 0644
# set_perm /data/local/tmp/file.txt 0 0 644

# The following is the default rule, DO NOT remove
set_perm_recursive $MODPATH 0 0 0755 0644
