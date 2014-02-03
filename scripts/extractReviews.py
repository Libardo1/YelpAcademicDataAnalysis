import pandas as pd
import nltk

def main():
    global daysOfWeek
    daysOfWeek = {0:'Sunday', 1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4:'Thursday', 5:'Friday', 6:'Saturday'}
    df = pd.read_csv('../data/processed/yelp_review.tsv',sep = '\t')
    df.apply(exportReviewText, axis = 1)
    
    
def exportReviewText(row):    
    row = row.values
    id_review = row[0]
    weekday = daysOfWeek[row[6]]
    rev = row[12]
    path = '../data/reviews/' + weekday + '/' + id_review + '.txt'
    with open(path,'w') as f:
        f.write(str(rev))
    f.close()
    
if __name__ == "__main__":
    main()