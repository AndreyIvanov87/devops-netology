# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.  
Это файл, в котором последовательности нулевых байтов[1] заменены на информацию об этих последовательностях (список дыр). 

1. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
Нет. Файл  представляет собой структуру блоков данных на диске, имеющую уникальный индексный дескриптор (или i-node) и набор атрибутов (метаинформацию). Жёсткая ссылка связывает индексный дескриптор файла с каталогом и даёт ему имя. То есть файл в данном случае будет один , и мета информация (права, владелец) будет одна, и повторятся для всех хардлинков на него. Разные права могут быть у симлинков.

1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:  
_________________________  
    ```bash  
    Vagrant.configure("2") do |config|  
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```  
  
    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.  
___________________________
	ivanov@lusankiya:~/vagrant$ vagrant destroy 
	    default: Are you sure you want to destroy the 'default' VM? [y/N] y  
	==> default: Forcing shutdown of VM...  
	==> default: Destroying VM and associated drives...  
	ivanov@lusankiya:~/vagrant$ vim.tiny Vagrantfile   
	vanov@lusankiya:~/vagrant$ vagrant up
	Bringing machine 'default' up with 'virtualbox' provider...
	==> default: Importing base box 'bento/ubuntu-20.04'...
	==> default: Matching MAC address for NAT networking...
	==> default: Checking if box 'bento/ubuntu-20.04' version '202107.28.0' is up to date...
	==> default: Setting the name of the VM: vagrant_default_1637842073513_30921


1. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
_________________________  
	Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
	Disk model: VBOX HARDDISK     
	Units: sectors of 1 * 512 = 512 bytes  
	Sector size (logical/physical): 512 bytes / 512 bytes  
	I/O size (minimum/optimal): 512 bytes / 512 bytes  
	Disklabel type: gpt  
	Disk identifier: A382C89B-40F3-9643-AB1D-1690705DC5D0  
	  
	Device       Start     End Sectors  Size Type   
	/dev/sdb1     2048 4196351 4194304    2G Linux filesystem  
	/dev/sdb2  4196352 5242846 1046495  511M Linux filesystem  
	  
1. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
___________________________  
	vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb | sudo  sfdisk /dev/sdc   
	Checking that no-one is using this disk right now ... OK  
	
	Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors  
	Disk model: VBOX HARDDISK  
	Units: sectors of 1 * 512 = 512 bytes  
	Sector size (logical/physical): 512 bytes / 512 bytes  
	I/O size (minimum/optimal): 512 bytes / 512 bytes  
	
	>>> Script header accepted.  
	>>> Script header accepted.  
	>>> Script header accepted.  
	>>> Script header accepted.  
	>>> Script header accepted.  
	>>> Script header accepted.  
	>>> Created a new GPT disklabel (GUID: A382C89B-40F3-9643-AB1D-1690705DC5D0).  
	/dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.  
	/dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.  
	/dev/sdc3: Done.  
	
	New situation:  
	Disklabel type: gpt  
	Disk identifier: A382C89B-40F3-9643-AB1D-1690705DC5D0  
	
	Device       Start     End Sectors  Size Type  
	/dev/sdc1     2048 4196351 4194304    2G Linux filesystem  
	/dev/sdc2  4196352 5242846 1046495  511M Linux filesystem  
	
	The partition table has been altered.  
	Calling ioctl() to re-read partition table.  
	Syncing disks.  

1. Соберите `mdadm` RAID1 на паре разделов 2 Гб.  
______________________________  
	root@vagrant:~# mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1  
	mdadm: Note: this array has metadata at the start and  
	    may not be suitable as a boot device.  If you plan to  
	    store '/boot' on this device please ensure that  
	    your boot-loader understands md/v1.x metadata, or use  
	    --metadata=0.90  
	mdadm: size set to 2094080K  
	Continue creating array? y  
	mdadm: Defaulting to version 1.2 metadata  
	mdadm: array /dev/md0 started.  

1. Соберите `mdadm` RAID0 на второй паре маленьких разделов.  
_______________________________  
	root@vagrant:~# mdadm --create --verbose /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2  
	mdadm: chunk size defaults to 512K  
	mdadm: partition table exists on /dev/sdb2  
	mdadm: partition table exists on /dev/sdb2 but will be lost or  
	       meaningless after creating array  
	Continue creating array? y  
	mdadm: Defaulting to version 1.2 metadata  
	mdadm: array /dev/md1 started.  

1. Создайте 2 независимых PV на получившихся md-устройствах.  
_______________________________  
	root@vagrant:~# pvcreate /dev/md0  
	  Physical volume "/dev/md0" successfully created.  
	root@vagrant:~# pvcreate /dev/md1
	  Physical volume "/dev/md1" successfully created.
	root@vagrant:~# pvs
	  PV         VG        Fmt  Attr PSize    PFree   
	  /dev/md0             lvm2 ---    <2.00g   <2.00g
	  /dev/md1             lvm2 ---  1017.00m 1017.00m
	  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0 

1. Создайте общую volume-group на этих двух PV.
_______________________________  
	root@vagrant:~# vgcreate myvgtest /dev/md1 /dev/md0
	  Volume group "myvgtest" successfully created
	root@vagrant:~# pvs
	  PV         VG        Fmt  Attr PSize    PFree   
	  /dev/md0   myvgtest  lvm2 a--    <2.00g   <2.00g
	  /dev/md1   myvgtest  lvm2 a--  1016.00m 1016.00m
	  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0 
	root@vagrant:~# vgs
	  VG        #PV #LV #SN Attr   VSize   VFree 
	  myvgtest    2   0   0 wz--n-  <2.99g <2.99g
	  vgvagrant   1   2   0 wz--n- <63.50g     0 
	

1. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
______________________________   
	root@vagrant:~# sudo lvcreate -L 100M -n logical_vol1 myvgtest /dev/md1  
	  Logical volume "logical_vol1" created.  
	root@vagrant:~# lvs  
	  LV           VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert  
	  logical_vol1 myvgtest  -wi-a----- 100.00m  
	  root         vgvagrant -wi-ao---- <62.54g                                                    
	  swap_1       vgvagrant -wi-ao---- 980.00m                                                    
	root@vagrant:~# pvs  
	  PV         VG        Fmt  Attr PSize    PFree  
	  /dev/md0   myvgtest  lvm2 a--    <2.00g  <2.00g  
	  /dev/md1   myvgtest  lvm2 a--  1016.00m 916.00m  
	  /dev/sda5  vgvagrant lvm2 a--   <63.50g      0   

1. Создайте `mkfs.ext4` ФС на получившемся LV.  
_____________________________  
	root@vagrant:~# mkfs.ext4 /dev/myvgtest/logical_vol1 
	mke2fs 1.45.5 (07-Jan-2020)
	Creating filesystem with 25600 4k blocks and 25600 inodes
	
	Allocating group tables: done                            
	Writing inode tables: done                            
	Creating journal (1024 blocks): done
	Writing superblocks and filesystem accounting information: done


1. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.  
_____________________________  
	root@vagrant:~# mount /dev/myvgtest/logical_vol1 /mnt/  
	root@vagrant:~# df -h /mnt/  
	Filesystem                         Size  Used Avail Use% Mounted on  
	/dev/mapper/myvgtest-logical_vol1   93M   72K   86M   1% /mnt  

1. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
	wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/test.gz  
	2021-11-26 09:39:57 (1.12 MB/s) - ‘/mnt/test.gz’ saved [22595572/22595572]  

1. Прикрепите вывод `lsblk`.
_____________________________  
	root@vagrant:~# lsblk  
	NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT  
	sda                           8:0    0   64G  0 disk    
	├─sda1                        8:1    0  512M  0 part  /boot/efi  
	├─sda2                        8:2    0    1K  0 part    
	└─sda5                        8:5    0 63.5G  0 part    
	  ├─vgvagrant-root          253:0    0 62.6G  0 lvm   /  
	  └─vgvagrant-swap_1        253:1    0  980M  0 lvm   [SWAP]  
	sdb                           8:16   0  2.5G  0 disk    
	├─sdb1                        8:17   0    2G  0 part    
	│ └─md0                       9:0    0    2G  0 raid1   
	└─sdb2                        8:18   0  511M  0 part    
	  └─md1                       9:1    0 1017M  0 raid0   
	    └─myvgtest-logical_vol1 253:2    0  100M  0 lvm   /mnt  
	sdc                           8:32   0  2.5G  0 disk    
	├─sdc1                        8:33   0    2G  0 part    
	│ └─md0                       9:0    0    2G  0 raid1   
	└─sdc2                        8:34   0  511M  0 part    
	  └─md1                       9:1    0 1017M  0 raid0   
	    └─myvgtest-logical_vol1 253:2    0  100M  0 lvm   /mnt  


1. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
_________________________  
	root@vagrant:~# gzip -t /mnt/test.gz  
	root@vagrant:~# echo $?  
	0  

1. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
________________________  
	root@vagrant:~# pvmove -n logical_vol1 /dev/md1 /dev/md0 
	  /dev/md1: Moved: 16.00%
	  /dev/md1: Moved: 100.00%
	root@vagrant:~# lsblk 
	NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
	sda                           8:0    0   64G  0 disk  
	├─sda1                        8:1    0  512M  0 part  /boot/efi
	├─sda2                        8:2    0    1K  0 part  
	└─sda5                        8:5    0 63.5G  0 part  
	  ├─vgvagrant-root          253:0    0 62.6G  0 lvm   /
	  └─vgvagrant-swap_1        253:1    0  980M  0 lvm   [SWAP]
	sdb                           8:16   0  2.5G  0 disk  
	├─sdb1                        8:17   0    2G  0 part  
	│ └─md0                       9:0    0    2G  0 raid1 
	│   └─myvgtest-logical_vol1 253:2    0  100M  0 lvm   /mnt
	└─sdb2                        8:18   0  511M  0 part  
	  └─md1                       9:1    0 1017M  0 raid0 
	sdc                           8:32   0  2.5G  0 disk  
	├─sdc1                        8:33   0    2G  0 part  
	│ └─md0                       9:0    0    2G  0 raid1 
	│   └─myvgtest-logical_vol1 253:2    0  100M  0 lvm   /mnt
	└─sdc2                        8:34   0  511M  0 part  
	  └─md1                       9:1    0 1017M  0 raid0 

1. Сделайте `--fail` на устройство в вашем RAID1 md.
_________________________  
	root@vagrant:~# mdadm /dev/md0 --fail /dev/sdb1
	mdadm: set /dev/sdb1 faulty in /dev/md0

1. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
_________________________  
	[74982.810252] md/raid1:md0: Disk failure on sdb1, disabling device.
	               md/raid1:md0: Operation continuing on 1 devices.

1. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
	root@vagrant:~# gzip -t /mnt/test.gz 
	root@vagrant:~# echo $?
	0
    ```

1. Погасите тестовый хост, `vagrant destroy`.

 
