FROM ubuntu:trusty

MAINTAINER Alexandre Viau <alexandre.viau@savoirfairelinux.com>

RUN apt-get update && \
    apt-get install -y vim wget python-pip

## Influxdb
RUN apt-get update && \
    apt-get install -y curl
RUN wget https://s3.amazonaws.com/influxdb/influxdb_0.10.1-1_amd64.deb
RUN useradd influxdb -u 1050 # We should remove this when issue is fixed (https://github.com/influxdb/influxdb/issues/670)
RUN dpkg -i influxdb*.deb
RUN service influxdb start && \
    sleep 10 && \
    curl -G "http://localhost:8086/query?u=root&p=root" --data-urlencode "q=CREATE DATABASE grafana" && \
    curl -G "http://localhost:8086/query?u=root&p=root" --data-urlencode "q=CREATE DATABASE mon"

### Grafana
RUN apt-get update && \
    apt-get install -y adduser libfontconfig
RUN wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.6.0_amd64.deb
RUN dpkg -i grafana*.deb

## Influxdb reverse proxy for grafana
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-proxy-html
RUN a2enmod proxy_http
ADD etc/apache2/conf-enabled/influxdb.conf /etc/apache2/conf-enabled/influxdb.conf

### Shinken
RUN useradd shinken && pip install https://github.com/naparuba/shinken/archive/2524270e7106802f3b6d6ab7e4b406ae84ed12b4.zip
RUN apt-get update && \
    apt-get install -y python-pycurl
RUN shinken --init

## modules
RUN shinken install webui
RUN shinken install auth-cfg-password
RUN pip install influxdb && shinken install mod-influxdb
RUN shinken install ws-arbiter

## Nagios plugins
RUN apt-get install -y nagios-plugins
RUN pip install shinkenplugins==0.1.3
# run permissions for user `shinken`
RUN chmod u+s /usr/lib/nagios/plugins/check_icmp
RUN chmod u+s /bin/ping
RUN chmod u+s /bin/ping6

## configuration
RUN rm -rf /etc/shinken
ADD etc/shinken /etc/shinken
RUN chown -R root:shinken /etc/shinken

### Supervisor
RUN apt-get -y install supervisor
ADD etc/supervisor /etc/supervisor

# Shinken WEBUI
EXPOSE 7767 

# ws-arbiter
EXPOSE 7760

# Influxdb
EXPOSE 8083
EXPOSE 8086

# Grafana
EXPOSE 3000

CMD ["/usr/bin/supervisord"]
