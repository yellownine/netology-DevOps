FROM centos:7
RUN yum install wget -y
RUN yum install perl-Digest-SHA -y
RUN yum clean all
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN shasum -a 512 -c elasticsearch-8.1.0-linux-x86_64.tar.gz.sha512
RUN tar -xzf elasticsearch-8.1.0-linux-x86_64.tar.gz
COPY elasticsearch.yml /elasticsearch-8.1.0/config/
RUN useradd elastic_user -p password
RUN chown elastic_user -R /elasticsearch-8.1.0; chown elastic_user -R /var/lib
USER elastic_user
CMD /elasticsearch-8.1.0/bin/elasticsearch
