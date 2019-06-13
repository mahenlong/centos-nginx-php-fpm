#
# MAINTAINER        Carson,C.J.Zeong <zcy@nicescale.com>
# DOCKER-VERSION    1.8.2
#
# Dockerizing php-fpm: Dockerfile for building php-fpm images
#
FROM  centos:7
MAINTAINER mahenglong <mahenglong@163.com>

#Set environment variable
ENV  APP_DIR /app

#Install nginx server and php-fpm
RUN  yum -y install epel-release && \
     yum -y install supervisor  nginx php-cli php-mysql php-pear php-ldap php-mbstring php-soap php-dom php-gd php-xmlrpc php-fpm php-mcrypt && \ 
     yum clean all

#Add nginx config files and seting php.ini
COPY nginx_nginx.conf /etc/nginx/nginx.conf
COPY nginx_default.conf /etc/nginx/conf.d/default.conf
COPY php_www.conf /etc/php-fpm.d/www.conf
RUN	sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini

#Create test page
RUN  mkdir -p /app && echo "<?php phpinfo(); ?>" > ${APP_DIR}/info.php && \
     cp /usr/share/nginx/html/* /app

#Add nginx and php-fpm start files
COPY supervisor_nginx.conf /etc/supervisor.d/nginx.conf
COPY supervisor_php-fpm.conf /etc/supervisor.d/php-fpm.conf
COPY supervisord.conf /etc/supervisord.conf
ADD start.sh /start.sh

ONBUILD ADD . /app
ONBUILD RUN chown -R nginx:nginx /app

WORKDIR "/var/www/html"
EXPOSE	80 443 9000
CMD /start.sh
