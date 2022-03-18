#! /bin/python3

# pip install lxml

from lxml import etree
snp  = etree.parse('/data/output/report_result/note/positive.snp.html', etree.HTMLParser())
indel = etree.parse('/data/output/report_result/note/positive.indel.html', etree.HTMLParser())

snp_keys = '''
downstream_gene_variant
intergenic_region
intragenic_variant
intron_variant
missense_variant
non_coding_transcript_exon_variant
splice_acceptor_variant
splice_donor_variant
splice_region_variant
stop_gained
stop_lost
stop_retained_variant
synonymous_variant
upstream_gene_variant
3_prime_UTR_variant
5_prime_UTR_variant
UPSTREAM
DOWNSTREAM
INTERGENIC'''

indel_keys = '''
downstream_gene_variant
upstream_gene_variant
intergenic_region
intragenic_variant
intron_variant
DOWNSTREAM
EXON
INTERGENIC
INTRON
TRANSCRIPT
NONE
SPLICE_SITE_ACCEPTOR
SPLICE_SITE_DONOR
SPLICE_SITE_REGION
UPSTREAM
UTR_3_PRIME
UTR_5_PRIME
'''

bsa_snp_keys = '''
DOWNSTREAM
EXON
INTERGENIC
INTRON
TRANSCRIPT
NONE
SPLICE_SITE_ACCEPTOR
SPLICE_SITE_DONOR
SPLICE_SITE_REGION
UPSTREAM
UTR_3_PRIME
UTR_5_PRIME
'''
bsa_snp_keys = bsa_snp_keys.split()
bsa_indel_keys = '''
DOWNSTREAM
EXON
INTERGENIC
INTRON
TRANSCRIPT
NONE
SPLICE_SITE_ACCEPTOR
SPLICE_SITE_DONOR
SPLICE_SITE_REGION
UPSTREAM
UTR_3_PRIME
UTR_5_PRIME
'''
bsa_indel_keys = bsa_indel_keys.split()
#keys = keys.split()

b_list = snp.xpath('//tr/td/b')
result = []
for b in b_list:
    for key in bsa_snp_keys:
        if b.text.strip() == key:
            p = b.getparent().getparent()
            items = p.xpath('./td')
            if len(items) == 3:
                line = "|".join([key, items[1].text.strip(), items[2].text.strip()])
                print(line)
                result.append("|" + line + "\n")

    with open("/data/output/report_result/note/bsa_snp_result.txt", "w+") as f:
        for i in result:
            f.writelines(i)

print("start indel")

b_list_ex = indel.xpath('//tr/td/b')
result_ex = []
for b in b_list_ex:
    for key in bsa_indel_keys:
        if b.text.strip() == key:
            p = b.getparent().getparent()
            items = p.xpath('./td')
            if len(items) == 3:
                line = "|".join([key, items[1].text.strip(), items[2].text.strip()])
                print(line)
                result_ex.append("|" + line + "\n")

    with open("/data/output/report_result/note/bsa_indel_result.txt", "w+") as f:
        for i in result_ex:
            f.writelines(i)
