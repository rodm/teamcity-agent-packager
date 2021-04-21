
import jetbrains.buildServer.configs.kotlin.v2019_2.project
import jetbrains.buildServer.configs.kotlin.v2019_2.version
import jetbrains.buildServer.configs.kotlin.v2019_2.CheckoutMode
import jetbrains.buildServer.configs.kotlin.v2019_2.DslContext
import jetbrains.buildServer.configs.kotlin.v2019_2.FailureAction
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.exec
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2019_2.vcs.GitVcsRoot

version = "2020.1"

project {

    val vcsId = "TeamcityAgentPackager"
    val vcs = GitVcsRoot {
        id(vcsId)
        name = "teamcity-agent-packager"
        url = "https://github.com/rodm/teamcity-agent-packager"
        useMirrors = false
    }
    vcsRoot(vcs)

    params {
        param("teamcity.ui.settings.readOnly", "true")
    }

    val buildVersion = buildType {
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
    }

    val buildLinuxDebPackage = buildType {
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
            matches("linux.os.name", "Ubuntu")
        }
    }

    val buildLinuxRpmPackage = buildType {
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
            contains("linux.os.name", "CentOS")
        }
    }

    val buildMacOSPackage = buildType {
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
    }

    val publishToBintray = buildType {
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
        }

        failureConditions {
            executionTimeoutMin = 20
        }

        features {
            feature {
                type = "perfmon"
            }
        }

        dependencies {
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
    }
    buildTypesOrder = arrayListOf(buildVersion, buildLinuxDebPackage, buildLinuxRpmPackage, buildMacOSPackage, publishToBintray)
}
