#!/usr/bin/env python3
"""Regenerate the dependency-free Xcode project when adding/removing Swift files."""
from pathlib import Path
import hashlib
import json

root = Path(__file__).resolve().parent.parent
objects = {}
def ident(name): return hashlib.sha1(name.encode()).hexdigest()[:24].upper()
def add(name, body):
    objects[ident(name)] = body
    return ident(name)
def q(value): return json.dumps(str(value))
def arr(values): return '(' + ', '.join(values) + (',' if values else '') + ')'

def source_files(folder):
    files, builds = [], []
    for path in sorted((root / folder).rglob('*.swift')):
        rel = str(path.relative_to(root))
        ref = add(rel, '{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ' + q(rel) + '; sourceTree = "<group>";}')
        build = add(rel + '-build', '{isa = PBXBuildFile; fileRef = ' + ref + ';}')
        files.append(ref); builds.append(build)
    return files, builds

app_files, app_builds = source_files('CareShare')
test_files, test_builds = source_files('CareShareUITests')
assets = add('assets', '{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = CareShare/Assets.xcassets; sourceTree = "<group>";}')
asset_build = add('asset-build', '{isa = PBXBuildFile; fileRef = ' + assets + ';}')
app_product = add('app-product', '{isa = PBXFileReference; explicitFileType = wrapper.application; path = CareShare.app; sourceTree = BUILT_PRODUCTS_DIR;}')
test_product = add('test-product', '{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; path = CareShareUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR;}')
app_group = add('app-group', '{isa = PBXGroup; children = ' + arr(app_files + [assets]) + '; name = CareShare; sourceTree = "<group>";}')
test_group = add('test-group', '{isa = PBXGroup; children = ' + arr(test_files) + '; name = CareShareUITests; sourceTree = "<group>";}')
products = add('products', '{isa = PBXGroup; children = ' + arr([app_product, test_product]) + '; name = Products; sourceTree = "<group>";}')
main = add('main-group', '{isa = PBXGroup; children = ' + arr([app_group, test_group, products]) + '; sourceTree = "<group>";}')

def phase(name, kind, files):
    return add(name, '{isa = ' + kind + '; buildActionMask = 2147483647; files = ' + arr(files) + '; runOnlyForDeploymentPostprocessing = 0;}')
def configs(name, settings):
    refs = []
    for mode in ['Debug', 'Release']:
        values = dict(settings)
        values['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone' if mode == 'Debug' else '-O'
        values['DEBUG_INFORMATION_FORMAT'] = 'dwarf' if mode == 'Debug' else 'dwarf-with-dsym'
        if mode == 'Debug': values['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
        refs.append(add(name + mode, '{isa = XCBuildConfiguration; buildSettings = {' + ''.join(k + ' = ' + q(v) + ';' for k,v in values.items()) + '}; name = ' + mode + ';}'))
    return add(name + '-configs', '{isa = XCConfigurationList; buildConfigurations = ' + arr(refs) + '; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;}')

common = {'SDKROOT': 'iphoneos', 'IPHONEOS_DEPLOYMENT_TARGET': '16.0', 'SWIFT_VERSION': '5.0', 'CLANG_ENABLE_MODULES': 'YES', 'CLANG_ENABLE_OBJC_ARC': 'YES', 'ENABLE_USER_SCRIPT_SANDBOXING': 'YES'}
project_configs = configs('project', common)
app_settings = {
    'PRODUCT_NAME': '$(TARGET_NAME)', 'PRODUCT_BUNDLE_IDENTIFIER': 'com.emrillion.CareShare',
    'TARGETED_DEVICE_FAMILY': '1', 'SUPPORTED_PLATFORMS': 'iphoneos iphonesimulator',
    'SUPPORTS_MACCATALYST': 'NO', 'SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD': 'NO',
    'CODE_SIGN_STYLE': 'Automatic', 'GENERATE_INFOPLIST_FILE': 'YES',
    'INFOPLIST_KEY_CFBundleDisplayName': 'CareShare', 'INFOPLIST_KEY_LSApplicationCategoryType': 'public.app-category.lifestyle',
    'INFOPLIST_KEY_UIApplicationSceneManifest_Generation': 'YES', 'INFOPLIST_KEY_UILaunchScreen_Generation': 'YES',
    'INFOPLIST_KEY_UISupportedInterfaceOrientations': 'UIInterfaceOrientationPortrait',
    'ASSETCATALOG_COMPILER_APPICON_NAME': 'AppIcon', 'CURRENT_PROJECT_VERSION': '1', 'MARKETING_VERSION': '0.1.0',
    'LD_RUNPATH_SEARCH_PATHS': '$(inherited) @executable_path/Frameworks', 'SWIFT_EMIT_LOC_STRINGS': 'YES'
}
app_configs = configs('app', app_settings)
test_configs = configs('tests', {'PRODUCT_NAME': '$(TARGET_NAME)', 'PRODUCT_BUNDLE_IDENTIFIER': 'com.emrillion.CareShareUITests', 'TARGETED_DEVICE_FAMILY': '1,2', 'GENERATE_INFOPLIST_FILE': 'YES', 'CODE_SIGN_STYLE': 'Automatic', 'TEST_TARGET_NAME': 'CareShare'})
app_phases = [phase('app-sources', 'PBXSourcesBuildPhase', app_builds), phase('app-frameworks', 'PBXFrameworksBuildPhase', []), phase('app-resources', 'PBXResourcesBuildPhase', [asset_build])]
test_phases = [phase('test-sources', 'PBXSourcesBuildPhase', test_builds), phase('test-frameworks', 'PBXFrameworksBuildPhase', []), phase('test-resources', 'PBXResourcesBuildPhase', [])]
proxy = add('proxy', '{isa = PBXContainerItemProxy; containerPortal = ' + ident('project') + '; proxyType = 1; remoteGlobalIDString = ' + ident('app') + '; remoteInfo = CareShare;}')
dep = add('dependency', '{isa = PBXTargetDependency; target = ' + ident('app') + '; targetProxy = ' + proxy + ';}')
add('app', '{isa = PBXNativeTarget; buildConfigurationList = ' + app_configs + '; buildPhases = ' + arr(app_phases) + '; buildRules = (); dependencies = (); name = CareShare; productName = CareShare; productReference = ' + app_product + '; productType = "com.apple.product-type.application";}')
add('tests', '{isa = PBXNativeTarget; buildConfigurationList = ' + test_configs + '; buildPhases = ' + arr(test_phases) + '; buildRules = (); dependencies = ' + arr([dep]) + '; name = CareShareUITests; productName = CareShareUITests; productReference = ' + test_product + '; productType = "com.apple.product-type.bundle.ui-testing";}')
add('project', '{isa = PBXProject; attributes = {LastUpgradeCheck = 2700; BuildIndependentTargetsInParallel = YES; TargetAttributes = {' + ident('app') + ' = {CreatedOnToolsVersion = 27.0;}; ' + ident('tests') + ' = {CreatedOnToolsVersion = 27.0; TestTargetID = ' + ident('app') + ';};};}; buildConfigurationList = ' + project_configs + '; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base); mainGroup = ' + main + '; productRefGroup = ' + products + '; projectDirPath = ""; projectRoot = ""; targets = ' + arr([ident('app'), ident('tests')]) + ';}')
(root / 'CareShare.xcodeproj/project.pbxproj').write_text('// !$*UTF8*$!\n{archiveVersion = 1; classes = {}; objectVersion = 56; objects = {\n' + '\n'.join(k + ' = ' + v + ';' for k,v in objects.items()) + '\n}; rootObject = ' + ident('project') + ';}\n')

def ref(target, product, name):
    return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ident(target)}" BuildableName="{product}" BlueprintName="{name}" ReferencedContainer="container:CareShare.xcodeproj"/>'
a = ref('app','CareShare.app','CareShare')
t = ref('tests','CareShareUITests.xctest','CareShareUITests')
(root / 'CareShare.xcodeproj/xcshareddata/xcschemes/CareShare.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.3">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{a}</BuildActionEntry></BuildActionEntries></BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO">{t}</TestableReference></Testables></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{a}</BuildableProductRunnable></LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{a}</BuildableProductRunnable></ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>''')
