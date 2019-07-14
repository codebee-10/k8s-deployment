set -e


echo "install openvswitch ..."

yum -y install systemd systemd-libs net-tools

yum -y install openssl-devel wget kernel-devel

yum -y groupinstall "Development Tools"

useradd ovswitch
su ovswitch

mkdir -p /home/ovswitch/rpmbuild/SOURCES
cd /home/ovswitch/rpmbuild/SOURCES/

wget http://openvswitch.org/releases/openvswitch-2.3.1.tar.gz
tar zxvf openvswitch-2.3.1.tar.gz

sed 's/openvswitch-kmod,//g' openvswitch-2.3.1/rhel/openvswitch.spec >openvswitch-2.3.1/rhel/openvswitch_no_kmod.spec

rpmbuild -bb --nocheck ./openvswitch-2.3.1/rhel/openvswitch_no_kmod.spec
exit


yum -y localinstall /home/ovswitch/rpmbuild/RPMS/x86_64/openvswitch-2.3.1-1.x86_64.rpm

service openvswitch start
service openvswitch status
chkconfig openvswitch on

ovs-vsctl --version

echo "install openvswitch finished ..."

