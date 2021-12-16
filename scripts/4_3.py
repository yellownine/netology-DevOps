### Задаине 4
import socket
import os
import json
import yaml

json_path = 'dns_data.json'
yml_path = 'dns_data.yaml'
dns_data_default = {'drive.google.com': 0, 'mail.google.com': 0, 'google.com': 0}

if os.path.exists(json_path):
    f_json = open(json_path, 'r')
    dns_data_last_json = json.load(f_json)
    f_json.close()
else:
    dns_data_last = dns_data_default

if os.path.exists(yml_path):
    f_yaml = open(yml_path, 'r')
    dns_data_last_yml = yaml.safe_load(f_yaml)
    f_yaml.close()
else:
    dns_data_last_yml = dns_data_default

dns_data_last = dns_data_last_json

urls_to_check = ['drive.google.com', 'mail.google.com', 'google.com']

for url_to_check in urls_to_check:
    ip = socket.gethostbyname(url_to_check)
    if dns_data_last[url_to_check] != ip:
        print(f'[ERROR] {url_to_check} IP mismatch: {dns_data_last[url_to_check]} {ip}')
    else:
        print(url_to_check + ' - ' + ip)
    dns_data_last[url_to_check] = ip

with open(json_path, "w") as f_json:
    json.dump(dns_data_last, f_json)
    f_json.close()

with open(yml_path, "w") as f_yaml:
    dns_data_for_yaml = []
    for url in dns_data_last:
        dns_data_for_yaml.append({url: dns_data_last[url]})
    yaml.dump(dns_data_for_yaml, f_yaml)
    f_yaml.close()
