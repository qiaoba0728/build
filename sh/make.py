import json
import os
import subprocess


def make_txt(name, b1, b2):
    rootdir = '/data/output/sorted_result'
    name = os.path.join("/tmp", name)
    b1_list = []
    b2_list = []
    list = os.listdir(rootdir)
    for i in range(0,len(list)):
       path = os.path.join(rootdir,list[i])
       print(path)
       if os.path.isfile(path) and b1 in path and path.endswith(".sorted.bam"):
	        b1_list.append(path)
       if os.path.isfile(path) and b2 in path and path.endswith(".sorted.bam"):
            b2_list.append(path)
    if not os.path.exists(name):
        os.makedirs(name)
    b1_txt = "%s/b1.txt" % name
    b2_txt = "%s/b2.txt" % name
    with open(b1_txt, "w+") as f:
        f.write(",".join(b1_list))
    print("write b1.txt", b1, b1_list)
    with open(b2_txt, "w+") as f:
        f.write(",".join(b2_list))
    print("write b2.txt", b2, b2_list)
    return b1_txt, b2_txt


def find_gtf(path="/data/input/references"):
    for file in os.listdir(path):
        if file.endswith(".gtf"):
            return os.path.join(path, file)


cmd = "python rmats.py  --b1 {} --b2 {} --gtf {} --tmp /tmp --od /data/output/rmats_result/{} -t paired --readLength 150 --cstat 0.0001 --nthread 1"

with open("/data/config.json") as f:
    data = json.load(f)
print("load config.json")

for group in data["group"]:
    name = group["name"]
    b1, b2 = name.split("_vs_")
    if b1.startswith("vs"):
        b1 = b1[2:]
    if b2.startswith("vs"):
        b2 = b2[2:]
    b1txt, b2txt = make_txt(name, b1, b2)
    print("generate txt file", b1txt, b2txt)
    gtf_file = find_gtf()
    real_cmd = cmd.format(b1txt, b2txt, gtf_file,name)
    print("run command:", real_cmd)
    os.system(real_cmd)
    os.system("rm -rf /tmp/*")

os.system("./rmats.sh")
