name		  "umpire"
maintainer        "Hector Castro"
maintainer_email  "hectcastro@gmail.com"
license           "Apache 2.0"
description       "Installs and configures Umpire."
version           "0.1.0"
recipe            "umpire", "Installs and configures Umpire"

%w{ git logrotate ruby_build }.each do |d|
  depends d
end

%w{ ubuntu }.each do |os|
    supports os
end
