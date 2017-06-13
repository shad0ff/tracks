name 'tracks'
maintainer 'Yurii Pyvovarov'
maintainer_email 'yuriy.pyvovarov@gmail.com'
license 'All Rights Reserved'
description 'Installs/Configures Tracks 2.3.0'
long_description 'Installs/Configures Tracks version 2.3.0. http://www.getontracks.org'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/yupvr/tracks/issues' if respond_to?(:issues_url)
source_url 'https://github.com/yupvr/tracks' if respond_to?(:source_url)
supports 'ubuntu', '= 14.04'

depends 'mysql', '~> 8.0'
depends 'mysql2_chef_gem', '~> 2.0'
depends 'database', '~> 6.1'
depends 'chef_nginx', '~> 6.1.1'
