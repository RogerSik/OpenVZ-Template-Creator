The OpenVZ-Template-Creator is an application to simply create and modify quickly OpenVZ templates.
It is built on a modular base in order to write quick scripts for new version of the distributions and distributions on their own.

## Requirements
<ul>
  <li>chroot</li>
  <li>dialog</li>
  <li>md5sum</li>
  <li>wget</li>
</ul>
optional
<ul>
  <li>links or lynx</li>
</ul>

## Control:
1. In order to install the tools and create the distri, one has to start '1_create_system.sh'
2. Now you'll be chrooted into the system and you need to execute "2_install_$distri_$codename.sh" in order to install and configure other programs which are needed
3. As a last step execute the 3_cleanup_system.sh to clean up (clear logs, etc.)
