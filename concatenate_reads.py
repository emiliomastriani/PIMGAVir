#!/usr/bin/env python


from Bio import SeqIO
fasta_sequences = SeqIO.parse(open('Forward.fasta'),'fasta')
sequences = []
names = []
for fasta in fasta_sequences:
    name, sequence = fasta.id, str(fasta.seq)
    name = name.split(' ')[0]
    #name = name.split(':')[6]
    name = '>'+name
    names.append(name)
    sequences.append(sequence)
other_sequences = SeqIO.parse(open("Reverse.fasta"), 'fasta')
other = []

for fasta in other_sequences:
    name, sequence = fasta.id, str(fasta.seq)
    other.append(sequence)
    
    
mylist = []
for i in range(len(sequences)):
    mylist.append('%sNNNNNNNNNN%s' % (sequences[i], other[i]))



from Bio.SeqIO.FastaIO import SimpleFastaParser

count = 0
with open("Forward.fasta") as in_handle:
    with open("Concatenated_Unmerged.fasta", "w") as out_handle:
        for title, seq in SimpleFastaParser(in_handle):
            seq = mylist[count]
            count += 1
            out_handle.write(">%s\n%s\n" % (title, seq))
