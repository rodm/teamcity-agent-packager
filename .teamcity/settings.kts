
import jetbrains.buildServer.configs.kotlin.v2018_2.project
import jetbrains.buildServer.configs.kotlin.v2018_2.version
import jetbrains.buildServer.configs.kotlin.v2018_2.BuildType
import jetbrains.buildServer.configs.kotlin.v2018_2.CheckoutMode
import jetbrains.buildServer.configs.kotlin.v2018_2.DslContext
import jetbrains.buildServer.configs.kotlin.v2018_2.FailureAction
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.exec
import jetbrains.buildServer.configs.kotlin.v2018_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2018_2.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2018_2.vcs.GitVcsRoot

version = "2018.2"

project {

    val vcsId = "TeamcityAgentPackager"
    val vcs = GitVcsRoot({
        id(vcsId)
        name = "teamcity-agent-packager"
        url = "https://github.com/rodm/teamcity-agent-packager"
        useMirrors = false
    })
    vcsRoot(vcs)

    val buildVersion = BuildType({
        id("BuildVersion")
        name = "Build version"

        params {
            param("RELEASE", "")
            param("VERSION", "")
        }

        vcs {
            root(vcs)
            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            script {
                scriptContent = """
                #!/bin/bash

                VERSION=${'$'}{VERSION:-`head -1 %teamcity.build.checkoutDir%/VERSION`}
                RELEASE=%build.number%
                echo "##teamcity[setParameter name='VERSION' value='${'$'}VERSION']"
                echo "##teamcity[setParameter name='RELEASE' value='${'$'}RELEASE']"
            """.trimIndent()
            }
        }

        failureConditions {
            executionTimeoutMin = 5
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "Linux")
        }
    })
    buildType(buildVersion)

    val buildLinuxDebPackage = BuildType({
        uuid = "1f1b15fc-1dfe-42a6-82df-d34759279162"
        id("BuildLinuxDebPackage")
        name = "Build Linux deb package"

        artifactRules = "build/*.deb => ."

        params {
            param("env.RELEASE", "%dep.${DslContext.projectId}_BuildVersion.RELEASE%")
            param("env.VERSION", "%dep.${DslContext.projectId}_BuildVersion.VERSION%")
        }

        vcs {
            root(vcs)
            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            exec {
                path = "/bin/sh"
                arguments = "-x build-deb.sh"
            }
        }

        triggers {
            vcs {
            }
        }

        failureConditions {
            executionTimeoutMin = 5
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
            dependency(buildVersion) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "Linux")
            matches("os.linux.name", "Ubuntu")
        }
    })
    buildType(buildLinuxDebPackage)

    val buildLinuxRpmPackage = BuildType({
        uuid = "b47c7581-2da6-4a15-8727-7defbdb7b532"
        id("BuildLinuxRpmPackage")
        name = "Build Linux rpm package"

        artifactRules = "build/RPMS/noarch/*.rpm => ."

        params {
            param("env.RELEASE", "%dep.${DslContext.projectId}_BuildVersion.RELEASE%")
            param("env.VERSION", "%dep.${DslContext.projectId}_BuildVersion.VERSION%")
        }

        vcs {
            root(vcs)
            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            exec {
                path = "/bin/sh"
                arguments = "-x build-rpm.sh"
            }
        }

        triggers {
            vcs {
            }
        }

        failureConditions {
            executionTimeoutMin = 5
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
            dependency(buildVersion) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "Linux")
            matches("os.linux.name", "CentOS")
        }
    })
    buildType(buildLinuxRpmPackage)

    val buildMacOSPackage = BuildType({
        uuid = "5f9cf62a-b70f-4fcb-9a0a-8a7ec6cdb8b2"
        id("BuildMacOsPackage")
        name = "Build macOS package"

        artifactRules = "build/*.pkg => ."

        params {
            param("env.RELEASE", "%dep.${DslContext.projectId}_BuildVersion.RELEASE%")
            param("env.VERSION", "%dep.${DslContext.projectId}_BuildVersion.VERSION%")
        }

        vcs {
            root(vcs)

            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            exec {
                path = "/bin/sh"
                arguments = "-x build-osx-pkg.sh"
            }
        }

        triggers {
            vcs {
            }
        }

        failureConditions {
            executionTimeoutMin = 5
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
            dependency(buildVersion) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "Mac OS X")
        }
    })
    buildType(buildMacOSPackage)

    val buildSolarisPackage = BuildType({
        uuid = "f4709b29-5bd1-484e-a953-13cd7b54480a"
        id("BuildSolarisPackage")
        name = "Build Solaris package"

        artifactRules = "build/*.p5p => ."

        params {
            param("env.RELEASE", "%dep.${DslContext.projectId}_BuildVersion.RELEASE%")
            param("env.VERSION", "%dep.${DslContext.projectId}_BuildVersion.VERSION%")
        }

        vcs {
            root(vcs)
            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            exec {
                path = "/bin/sh"
                arguments = "-x build-solaris-ips.sh"
            }
        }

        triggers {
            vcs {
            }
        }

        failureConditions {
            executionTimeoutMin = 5
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
            dependency(buildVersion) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "SunOS")
        }
    })
    buildType(buildSolarisPackage)

    val publishToBintray = BuildType({
        uuid = "f91a0a93-98ca-43ed-9af4-ff2ed583ccab"
        id("PublishToBintray")
        name = "Publish packages to Bintray"

        params {
            param("env.RELEASE", "%dep.${DslContext.projectId}_BuildVersion.RELEASE%")
            param("env.VERSION", "%dep.${DslContext.projectId}_BuildVersion.VERSION%")
            param("env.UPLOAD_DIR", "files")
        }

        vcs {
            root(vcs)
            checkoutMode = CheckoutMode.ON_SERVER
        }

        steps {
            script {
                scriptContent = """
                #!/bin/bash

                echo "Publishing version: ${'$'}VERSION, release: ${'$'}RELEASE"
                ls -l %teamcity.build.checkoutDir%/${'$'}UPLOAD_DIR
            """.trimIndent()
            }
            exec {
                name = "Upload and publish deb"
                path = "/bin/sh"
                arguments = "-x publish-deb.sh"
            }
            exec {
                name = "Upload and publish rpm"
                path = "/bin/sh"
                arguments = "-x publish-rpm.sh"
            }
            exec {
                name = "Upload and publish pkg"
                path = "/bin/sh"
                arguments = "-x publish-pkg.sh"
            }
            exec {
                name = "Upload and publish p5p"
                path = "/bin/sh"
                arguments = "-x publish-solaris-ips.sh"
            }
        }

        failureConditions {
            executionTimeoutMin = 15
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
            dependency(buildSolarisPackage) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }

                artifacts {
                    cleanDestination = true
                    artifactRules = "teamcity-agent-%env.VERSION%-%env.RELEASE%.p5p => %env.UPLOAD_DIR%"
                }
            }
            dependency(buildMacOSPackage) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }

                artifacts {
                    cleanDestination = true
                    artifactRules = "teamcity-agent-%env.VERSION%-%env.RELEASE%.pkg => %env.UPLOAD_DIR%"
                }
            }
            dependency(buildLinuxDebPackage) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }

                artifacts {
                    cleanDestination = true
                    artifactRules = "teamcity-agent_%env.VERSION%-%env.RELEASE%_all.deb => %env.UPLOAD_DIR%"
                }
            }
            dependency(buildLinuxRpmPackage) {
                snapshot {
                    onDependencyFailure = FailureAction.FAIL_TO_START
                }

                artifacts {
                    cleanDestination = true
                    artifactRules = "teamcity-agent-%env.VERSION%-%env.RELEASE%.noarch.rpm => %env.UPLOAD_DIR%"
                }
            }
        }

        requirements {
            contains("teamcity.agent.jvm.os.name", "Linux")
        }
    })
    buildType(publishToBintray)
    buildTypesOrder = arrayListOf(buildVersion, buildLinuxDebPackage, buildLinuxRpmPackage, buildMacOSPackage, buildSolarisPackage, publishToBintray)
}
