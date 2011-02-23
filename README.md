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

## Download of already created templates
<a href="http://files.openvz-tc.org/templates">Here</a> can you download templates that are created with this Creator.

# Seeking for distributions which aren't listed here yet.
If there is a distribution you want to be added to the OpenVZ TC project
please get in touch with me: Roger roger@sikorski.cc (English, German &
Polish). In such a case, I take order for creating the asked
distribution and script. Only condition set for the script is that it is
licensed under the GNU GPLv3. Price for the order are negotiable.

# Donate
<a href="http://pledgie.com/campaigns/11129">Donate button</a>

# Powered by
<a href="http://www.carrot-server.com/"><img src="http://yoschi.cc/wp-content/uploads/carrot-server.png"></a>

