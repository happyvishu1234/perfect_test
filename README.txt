README

Prerequisit ::

vagrant box add thinktainer/centos-6_6-x64

TASK:


All the mentioned TASK in the comepleted 

http to https redirection
Used the php instead python for the memcache output.
Self generated SSL certs and install 

STPS To run config :: 

vagrant up --provider=virtualbox


OUPUT :: 


Vagrant URL after the port forwarding

http://localhost:8080  :: default
https://localhost:8443 :: default https

TO check the memcached stats

http://localhost:8080 will automatically will get redirected
https://localhost:8443/app/test.php will the memcached stats

