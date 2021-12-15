#### Задаине 1
# a = 1
# b = '2'
# c = a + b
# # c = str(a) + b
# # c = a + int(b)
# print(c)

# #### Задаине 2
# import os
# current_dir = os.getcwd()
# rel_path = "~/netology/netology-DevOps"
# git_key = "изменено"
# bash_command = [f'cd {rel_path}', "git status"]
# result_os = os.popen(' && '.join(bash_command)).read()
# is_change = False # не задействованная переменная ?!
# for result in result_os.split('\n'):
#     if result.find(git_key) != -1:
#         prepare_result = result.replace(f'\t{git_key}:   ', '')
#         print(os.path.join(current_dir, prepare_result.strip()))

# ### Задаине 3
# import os
# import sys
#
# rep_dirs = sys.argv[1:]
# if len(rep_dirs) == 0:
#     rep_dirs.append(os.getcwd())
#
# def log_modified(rep_dir):
#     git_key = "изменено"
#     bash_command = [f'cd {rep_dir}', "git status"]
#     result_os = os.popen(' && '.join(bash_command)).read()
#     for result in result_os.split('\n'):
#         if result.find(git_key) != -1:
#             prepare_result = result.replace(f'\t{git_key}:   ', '')
#             print(os.path.join(rep_dir, prepare_result.strip()))
#
#
# for r_dir in rep_dirs:
#     log_modified(r_dir)

### Задаине 4
import socket

dns_data_last = {'drive.google.com': 0, 'mail.google.com': 0, 'google.com': 0}
urls_to_check = ['drive.google.com', 'mail.google.com', 'google.com']

for i in range(10):
    for url_to_check in urls_to_check:
        ip = socket.gethostbyname(url_to_check)
        if dns_data_last[url_to_check] != ip:
            print(f'[ERROR] {url_to_check} IP mismatch: {dns_data_last[url_to_check]} {ip}')
        else:
            print(url_to_check + ' - ' + ip)
        dns_data_last[url_to_check] = ip
