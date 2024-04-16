# NFS

Создаем Vagrantfile с двумя машинами, с настройкой nfs. 
```
nfss(nfsserv) - сервер
nfsc(nfscln) - клиент
nfs_server.sh - для сервера
nfs_client.sh - для клиента
```
Сначала проверяем стенд вручную.
заходим на сервер:
```
root@testvm:/home/NFS# vagrant ssh nfss
[vagrant@nfsserv ~]$ root@testvm:/home/NFS# vagrant ssh nfss
```
Дальнейшие действия выполняются от имени пользователя имеющего повышенные привилегии:

Доустановливаем утилиты, которые облегчат отладку:
```
[root@nfsserv vagrant]# yum install nfs-utils
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.corbina.net
 * extras: mirror.docker.ru
 * updates: mirror.corbina.net
base                                                                                                                                                                                                                  | 3.6 kB  00:00:00
extras                                                                                                                                                                                                                | 2.9 kB  00:00:00
updates                                                                                                                                                                                                               | 2.9 kB  00:00:00
(1/4): base/7/x86_64/group_gz                                                                                                                                                                                         | 153 kB  00:00:00
(2/4): extras/7/x86_64/primary_db                                                                                                                                                                                     | 253 kB  00:00:00
(3/4): base/7/x86_64/primary_db                                                                                                                                                                                       | 6.1 MB  00:00:01
(4/4): updates/7/x86_64/primary_db                                                                                                                                                                                    |  26 MB  00:00:05
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7.2 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=============================================================================================================================================================================================================================================
 Package                                                 Arch                                                 Version                                                            Repository                                             Size
=============================================================================================================================================================================================================================================
Updating:
 nfs-utils                                               x86_64                                               1:1.3.0-0.68.el7.2                                                 updates                                               413 k

Transaction Summary
=============================================================================================================================================================================================================================================
Upgrade  1 Package
```
Включаем firewall и проверяем, что он работает:
```
[root@nfsserv vagrant]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
```
Разрешаем в firewall доступ к сервисам NFS
[root@nfsserv vagrant]# firewall-cmd --add-service="nfs3" \
> --add-service="rpc-bind" \
> --add-service="mountd" \
> --permanent
success
```
[root@nfsserv vagrant]# firewall-cmd --reload
success
```
Включаем сервер NFS (для конфигурации NFSv3 over UDP он не требует дополнительной настройки:
```
[root@nfsserv vagrant]# systemctl enable nfs --now
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
```
проверяем наличие слушаемых портов 2049/udp, 2049/tcp, 20048/udp,  20048/tcp:
```
[root@nfsserv vagrant]# ss -tnplu
Netid State      Recv-Q Send-Q                                                                       Local Address:Port                                                                                      Peer Address:Port
udp   UNCONN     0      0                                                                                        *:35196                                                                                                *:*
udp   UNCONN     0      0                                                                                        *:931                                                                                                  *:*                   users:(("rpcbind",pid=342,fd=7))
udp   UNCONN     0      0                                                                                127.0.0.1:946                                                                                                  *:*                   users:(("rpc.statd",pid=3738,fd=5))
udp   UNCONN     0      0                                                                                        *:40923                                                                                                *:*                   users:(("rpc.statd",pid=3738,fd=8))
udp   UNCONN     0      0                                                                                        *:2049                                                                                                 *:*
udp   UNCONN     0      0                                                                                        *:68                                                                                                   *:*                   users:(("dhclient",pid=2597,fd=6))
udp   UNCONN     0      0                                                                                        *:20048                                                                                                *:*                   users:(("rpc.mountd",pid=3744,fd=7))
udp   UNCONN     0      0                                                                                        *:111                                                                                                  *:*                   users:(("rpcbind",pid=342,fd=6))
udp   UNCONN     0      0                                                                                127.0.0.1:323                                                                                                  *:*                   users:(("chronyd",pid=344,fd=5))
udp   UNCONN     0      0                                                                                     [::]:931                                                                                               [::]:*                   users:(("rpcbind",pid=342,fd=10))
udp   UNCONN     0      0                                                                                     [::]:36323                                                                                             [::]:*
udp   UNCONN     0      0                                                                                     [::]:2049                                                                                              [::]:*
udp   UNCONN     0      0                                                                                     [::]:20048                                                                                             [::]:*                   users:(("rpc.mountd",pid=3744,fd=9))
udp   UNCONN     0      0                                                                                     [::]:111                                                                                               [::]:*                   users:(("rpcbind",pid=342,fd=9))
udp   UNCONN     0      0                                                                                    [::1]:323                                                                                               [::]:*                   users:(("chronyd",pid=344,fd=6))
udp   UNCONN     0      0                                                                                     [::]:36174                                                                                             [::]:*                   users:(("rpc.statd",pid=3738,fd=10))
tcp   LISTEN     0      64                                                                                       *:2049                                                                                                 *:*
tcp   LISTEN     0      128                                                                                      *:53284                                                                                                *:*                   users:(("rpc.statd",pid=3738,fd=9))
tcp   LISTEN     0      128                                                                                      *:111                                                                                                  *:*                   users:(("rpcbind",pid=342,fd=8))
tcp   LISTEN     0      128                                                                                      *:20048                                                                                                *:*                   users:(("rpc.mountd",pid=3744,fd=8))
tcp   LISTEN     0      128                                                                                      *:22                                                                                                   *:*                   users:(("sshd",pid=614,fd=3))
tcp   LISTEN     0      100                                                                              127.0.0.1:25                                                                                                   *:*                   users:(("master",pid=814,fd=13))
tcp   LISTEN     0      64                                                                                       *:42202                                                                                                *:*
tcp   LISTEN     0      64                                                                                    [::]:2049                                                                                              [::]:*
tcp   LISTEN     0      64                                                                                    [::]:34435                                                                                             [::]:*
tcp   LISTEN     0      128                                                                                   [::]:111                                                                                               [::]:*                   users:(("rpcbind",pid=342,fd=11))
tcp   LISTEN     0      128                                                                                   [::]:20048                                                                                             [::]:*                   users:(("rpc.mountd",pid=3744,fd=10))
tcp   LISTEN     0      128                                                                                   [::]:50165                                                                                             [::]:*                   users:(("rpc.statd",pid=3738,fd=11))
tcp   LISTEN     0      128                                                                                   [::]:22                                                                                                [::]:*                   users:(("sshd",pid=614,fd=4))
tcp   LISTEN     0      100                                                                                  [::1]:25                                                                                                [::]:*                   users:(("master",pid=814,fd=14))
```
Да все в норме, продолжаем....

Создаём и настраиваем директорию, которая будет экспортирована в будущем:
```
[root@nfsserv vagrant]# mkdir -p /srv/share/upload
[root@nfsserv vagrant]# chown -R nfsnobody:nfsnobody /srv/share
[root@nfsserv vagrant]# chmod 0777 /srv/share/upload
```
Cоздаём в файле __/etc/exports__ структуру, которая позволит экспортировать ранее созданную директорию:
```
[root@nfsserv vagrant]# cat << EOF > /etc/exports
> /srv/share 192.168.56.130/32(rw,sync,root_squash)
> EOF
```
Экспортируем ранее созданную директорию:
```
[root@nfsserv vagrant]# exportfs -r
```
Проверяем экспортированную директорию следующей командой:
```
[root@nfsserv vagrant]# exportfs -s
/srv/share  192.168.56.130/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```
-----------------------------------------------------------------------------------------------------------------
Настраиваем клиент NFS
Дальнейшие действия выполняются от имени пользователя имеющего повышенные привилегии.
```
root@testvm:/home/NFS# vagrant ssh nfsc
[vagrant@nfscln ~]$ sudo -s
[root@nfscln vagrant]# yum install nfs-utils
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.corbina.net
 * extras: mirror.corbina.net
 * updates: centos-mirror.rbc.ru
base    
```
Включаем firewall и проверяем, что он работает:
```
  [root@nfscln vagrant]# systemctl enable firewalld --now
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
```
  [root@nfscln vagrant]# systemctl status firewalld
  firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2024-04-15 20:53:58 UTC; 29s ago
     Docs: man:firewalld(1)
 Main PID: 22278 (firewalld)
   CGroup: /system.slice/firewalld.service
           └─22278 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid

Apr 15 20:53:58 nfscln systemd[1]: Starting firewalld - dynamic firewall daemon...
Apr 15 20:53:58 nfscln systemd[1]: Started firewalld - dynamic firewall daemon.
Apr 15 20:53:58 nfscln firewalld[22278]: WARNING: AllowZoneDrifting is enabled. This is considered an insecure configuration option. It will be removed in a future release. Please consider disabling it now.
```
 добавляем в /etc/fstab строку:
```
[root@nfscln vagrant]# echo "192.168.56.120:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab
```
и выполняем
```
[root@nfscln vagrant]# systemctl daemon-reload
[root@nfscln vagrant]# systemctl restart remote-fs.target
```
Заходим в директорию `/mnt/` и проверяем успешность монтирования:
```
[root@nfscln vagrant]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=46,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=46394)
```
---------------------------------------------------------------------------------------
Проверка работоспособности:
- заходим на сервер 
- заходим в каталог `/srv/share/upload` 
- создаём тестовый файл `touch check_file
```
root@testvm:/home/NFS# vagrant ssh nfss
Last login: Mon Apr 15 19:44:53 2024 from 10.0.2.2
[root@nfsserv upload]# touch check_file
[root@nfsserv upload]# ls
check_file
```
```
- заходим на клиент 
- заходим в каталог `/mnt/upload` 
- проверяем наличие ранее созданного файла 
- создаём тестовый файл `touch client_file` 
- проверяем, что файл успешно создан 
```
```
root@testvm:/home/NFS# vagrant ssh nfsc
Last login: Mon Apr 15 21:16:38 2024 from 10.0.2.2
[vagrant@nfscln ~]$ sudo -s
[root@nfscln vagrant]# cd /mnt/upload
[root@nfscln upload]# ls
check_file
[root@nfscln upload]# touch client_file
[root@nfscln upload]# ls
check_file  client_file
[root@nfscln upload]#
```
Файл виден от сервера и создался от клиента на сервере, значит проблем с правами нет.

Предварительно проверяем клиент: 
- перезагружаем клиент 
- заходим на клиент 
- заходим в каталог `/mnt/upload` 
- проверяем наличие ранее созданных файлов 
```
[root@nfscln upload]# reboot
Connection to 127.0.0.1 closed by remote host.
root@testvm:/home/NFS# vagrant ssh nfsc
Last login: Mon Apr 15 21:23:54 2024 from 10.0.2.2
[vagrant@nfscln ~]$ sudo -s
[root@nfscln vagrant]# cd /mnt/upload
[root@nfscln upload]# ls
check_file  client_file
```

Тест клиента прошел успешно. После перезагрузки папкапримонтирована, файлы на месте.
```
Проверяем сервер: 
- заходим на сервер в отдельном окне терминала 
- перезагружаем сервер 
- заходим на сервер 
- проверяем наличие файлов в каталоге /srv/share/upload/
- проверяем статус сервера NFS systemctl status nfs 
- проверяем статус firewall systemctl status firewalld 
- проверяем экспорты `exportfs -s` 
- проверяем работу RPC showmount -a 192.168.56.120
```
```
root@testvm:/home/NFS# vagrant ssh nfss
Last login: Mon Apr 15 21:17:49 2024 from 10.0.2.2
[vagrant@nfsserv ~]$ sudo -s
[root@nfsserv vagrant]# reboot
```
```
root@testvm:/home/NFS# vagrant ssh nfss
Last login: Mon Apr 15 21:35:22 2024 from 10.0.2.2
[vagrant@nfsserv ~]$ sudo -s
[root@nfsserv vagrant]# ls /srv/share/upload/
check_file  client_file
```
Файлы и монтирование после перезагрузки на месте.
```
[root@nfsserv vagrant]# systemctl status nfs
● nfs-server.service - NFS server and services
   Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; vendor preset: disabled)
  Drop-In: /run/systemd/generator/nfs-server.service.d
           └─order-with-mounts.conf
   Active: active (exited) since Mon 2024-04-15 21:36:35 UTC; 2min 33s ago
  Process: 835 ExecStartPost=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
  Process: 810 ExecStart=/usr/sbin/rpc.nfsd $RPCNFSDARGS (code=exited, status=0/SUCCESS)
  Process: 805 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
 Main PID: 810 (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/nfs-server.service

Apr 15 21:36:35 nfsserv systemd[1]: Starting NFS server and services...
Apr 15 21:36:35 nfsserv systemd[1]: Started NFS server and services.
```
статус firewall успешно
```
```
[root@nfsserv vagrant]# exportfs -s
/srv/share  192.168.56.130/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```
```
[root@nfsserv vagrant]# showmount -a 192.168.56.120
All mount points on 192.168.56.120:
192.168.56.130:/srv/share
```
192.168.56.120 -сервер
192.168.56.130:/srv/share -клиент
```
```
Проверяем клиент: 
 
```
- возвращаемся на клиент
- перезагружаем клиент 
```
root@testvm:/home/NFS# vagrant ssh nfsc
Last login: Mon Apr 15 21:28:08 2024 from 10.0.2.2
[vagrant@nfscln ~]$ sudo -s
[root@nfscln vagrant]# reboot
```
- заходим на клиент 
- проверяем работу RPC `showmount -a 192.168.56.120`
```
Connection to 127.0.0.1 closed by remote host.
root@testvm:/home/NFS# vagrant ssh nfsc
Last login: Mon Apr 15 21:46:27 2024 from 10.0.2.2
[vagrant@nfscln ~]$ showmount -a 192.168.56.120
All mount points on 192.168.56.120:
```
- заходим в каталог `/mnt/upload` 
- проверяем статус монтирования `mount | grep mnt`
```
[root@nfscln vagrant]# cd /mnt/upload
[root@nfscln upload]# mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=33,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=11183)
192.168.56.120:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.56.120,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.56.120)
```
- проверяем наличие ранее созданных файлов
```
[root@nfscln upload]# ls
check_file  client_file
```
- создаём тестовый файл `touch final_check` 
- проверяем, что файл успешно создан 
```
[root@nfscln upload]# touch final_check
[root@nfscln upload]# ls
check_file  client_file  final_check

Проверки стенда пройдены!!!



