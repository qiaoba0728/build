import os


# pip install matplotlib

def aggregation(path="/data/output/diff"):
    result = {}
    # path = "down_up"
    f = open('/data/output/diff/all_down_up.template', 'w')
    allf = open('/data/output/diff/all_down_up.template', 'w')
    files = os.listdir(path)
    for file in files:
        if not file.endswith("_down_up.csv"):
            continue
        name = file.replace("_down_up.csv", "")
        with open(os.path.join(path, file)) as f:
            content = f.read()
        lines = content.splitlines()
        result[name] = {"up": lines[0].split()[1], "down": lines[1].split()[1]}
        print(name.split("_vs_")[0],name.split("_vs_")[1])
        print(lines[0].split()[1],lines[1].split()[1])
        print(int(lines[0].split()[1]))
        allf.write('|%s|%s|%s|%s|%d|\n'% (name.split("_vs_")[0],name.split("_vs_")[1],lines[0].split()[1],lines[1].split()[1],int(lines[0].split()[1])+int(lines[1].split()[1])))
    print(result)
    allf.close()
    return result


def double_bar(data):
    import matplotlib.pyplot as plt

    # 设置中文字体和负号正常显示
    plt.rcParams['font.sans-serif'] = ['SimHei']
    plt.rcParams['axes.unicode_minus'] = False

    plt.figure(figsize=(40, 20))
    name = list(data.keys())
    value1 = [int(v.get("up")) for v in data.values()]
    value2 = [int(v.get("down")) for v in data.values()]
    x = range(len(data.items()))
    bar1 = plt.bar([i - 0.2 for i in x], height=value1, width=0.4, alpha=0.8, color='#F8766D', label='up')  # 第一个图

    bar2 = plt.bar([i + 0.2 for i in x], value2, width=0.4, alpha=0.8, color='#00BEC4', label='down')  # 第二个图

    plt.xticks(x, name)  # 设置x轴刻度显示值
    # plt.ylim(0, 10500)  # y轴的范围
    #plt.title('XXX公司')  # 标题
    #plt.xlabel('月份')  # x轴的标签
    plt.ylabel('Number of gene')  # y轴的标签
    plt.legend()  # 设置图例
    plt.xticks(size=9, rotation=30)  # x轴标签旋转

    for rect in bar1:
        height = rect.get_height()  # 获得bar1的高度
        plt.text(rect.get_x() + rect.get_width() / 2, height + 3, str(height), ha="center", va="bottom")
    for rect in bar2:
        height = rect.get_height()
        plt.text(rect.get_x() + rect.get_width() / 2, height + 3, str(height), ha="center", va="bottom")

    plt.savefig("/data/output/diff/all_down_up.pdf", format='pdf')
    plt.savefig(r'/data/output/diff/all_down_up.png',
            dpi=400,bbox_inches = 'tight')
    plt.show()


if __name__ == '__main__':
    data = aggregation()
    double_bar(data)
