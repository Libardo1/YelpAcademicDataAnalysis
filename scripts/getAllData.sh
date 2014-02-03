# Process raw data in Python and output tsvs

# run in /scripts
# Store raw Yelp json files in data/raw

python readYelpData.py user '../data/raw/yelp_academic_dataset_user.json' > '../data/processed/yelp_user.tsv'
python readYelpData.py business '../data/raw/yelp_academic_dataset_business.json' > '../data/processed/yelp_business.tsv'
python readYelpData.py review '../data/raw/yelp_academic_dataset_review.json' > '../data/processed/yelp_review.tsv'
python readYelpData.py checkin '../data/raw/yelp_academic_dataset_checkin.json' > '../data/processed/yelp_checkin.tsv'
