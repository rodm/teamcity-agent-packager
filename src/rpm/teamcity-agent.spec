%global _binaries_in_noarch_packages_terminate_build 0

%define __jar_repack 0
%define uid teamcity

Name: @NAME@
Version: @VERSION@
Release: @RELEASE@
Summary: TeamCity Build Agent
BuildArch: noarch
Epoch: 1
Group: Development/Tools
License: JetBrains
URL: http://www.jetbrains.com/teamcity
Source0: buildAgent.zip
Source1: %{name}.init
Source2: agent.sh
Source3: %{name}.conf
Source4: %{name}.properties
Prefix: /opt
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Vendor: JetBrains
Packager: Rod MacKenzie <rod.n.mackenzie@gmail.com>

%description
TeamCity Build Agent

%prep

%setup -q -c

%install
rm -rf $RPM_BUILD_ROOT

install -d -m 755 $RPM_BUILD_ROOT/opt/%{name}
cp -R . $RPM_BUILD_ROOT/opt/%{name}
rm -rf $RPM_BUILD_ROOT/opt/%{name}/logs

install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
install -m 755 %{SOURCE1} $RPM_BUILD_ROOT%{_initrddir}/%{name}

install -d -m 755 $RPM_BUILD_ROOT/usr/share/%{name}
install -m 755 %{SOURCE2} $RPM_BUILD_ROOT/usr/share/%{name}/agent.sh

install -d -m 755 $RPM_BUILD_ROOT/etc/%{name}
install -m 644 %{SOURCE3} $RPM_BUILD_ROOT/etc/%{name}/%{name}.conf
install -m 644 %{SOURCE4} $RPM_BUILD_ROOT/etc/%{name}/%{name}.properties

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,%{uid},%{uid})
/opt/%{name}
/etc/%{name}
%attr(755, teamcity, teamcity) %{_initrddir}/%{name}
%attr(755, teamcity, teamcity) /opt/%{name}/bin/agent.sh
%attr(755, teamcity, teamcity) /usr/share/%{name}/agent.sh
%attr(644, teamcity, teamcity) /etc/%{name}/%{name}.conf
%attr(644, teamcity, teamcity) /etc/%{name}/%{name}.properties
%config(noreplace) /etc/%{name}/%{name}.conf
%config(noreplace) /etc/%{name}/%{name}.properties

%pre
function create_dir {
    [ -d $1 ] || mkdir $1
    chown %{uid}:%{uid} $1
}

/usr/sbin/groupadd -r %{uid} 2>/dev/null || :
/usr/sbin/useradd -c "%{uid}" -r -s /bin/bash -d /opt/%{name} -g %{uid} %{uid} 2>/dev/null || :

if [ "$1" = "1" ] ; then # install
    create_dir /var/lib/%{name}
    create_dir /var/log/%{name}
    create_dir /var/run/%{name}
fi

%post
if [ "$1" = "1" ] ; then # install
    chkconfig --add %{name}
fi

%preun
/etc/init.d/%{name} stop > /dev/null 2>&1 

if [ "$1" = "0" ] ; then # uninstall
    chkconfig --del %{name}
fi

%postun
if [ "$1" = "0" ] ; then # uninstall
    rm -fr /var/lib/%{name}
    rm -fr /var/log/%{name}
    rm -fr /var/run/%{name}
fi

%changelog
* Thu Jan 5 2012 Rod MacKenzie <rod.n.mackenzie@gmail.com>
- Added init.d script to start/stop build agent
- Added wrapper script to setup configuration and agent properties file
- Corrected default attributes for installed files

* Tue May 10 2011 Rod MacKenzie <rod.n.mackenzie@gmail.com>
- Created initial spec file

