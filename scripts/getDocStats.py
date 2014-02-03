import nltk
import sys
import csv


corpus = nltk.corpus.CategorizedPlaintextCorpusReader('../data/reviews/', r'.*\.txt', cat_pattern=r'(\w+)/*')
for cat in corpus.categories():
    csvfile = '../data/processed/docStat_' + cat + '.csv'
    with open(csvfile, 'w') as output:
        writer = csv.writer(output, lineterminator = '\n')
        writer.writerow(['Number of Words', 'Average Word Length', 'Average Sentence Length', 'Vocabulary Diversity'])
        for fileid in corpus.fileids(categories=cat):
            num_chars = len(corpus.raw(fileid))
            num_words = len(corpus.words(fileid))
            num_sents = len(corpus.sents(fileid))
            num_vocab = len(set([w.lower() for w in corpus.words(fileid)]))
            result = [num_words, float(num_chars)/num_words, float(num_words)/num_sents, float(num_words)/num_vocab]
            writer.writerow(result)