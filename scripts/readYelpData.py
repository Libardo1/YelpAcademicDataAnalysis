import json
import pandas as pd
import numpy as np
import sys



def main():
    options = ['user','business','review','checkin']
    f = sys.argv[2]
    data = readJSON(f)
    
    if sys.argv[1] in options:
        if sys.argv[1] == 'user':
            df = pd.DataFrame([getUserData(x) for x in data], columns = ['id_user', 'stars_user','name_user', 'review_count_user', 'votes_cool_user', 'votes_funny_user', 'votes_useful_user']) 
        elif sys.argv[1] == 'business':
            df = pd.DataFrame([getBusinessData(x) for x in data], columns = ['id_business', 'lat_business', 'lon_business', 'name_business', 'openclosed_business', 'review_count_business', 'stars_business', 'categories'])
            global businessCategories 
            businessCategories = list(set(flatten(df.categories)))
            cat_df = pd.DataFrame([binaryCategorizer(cats) for cats in df.categories], columns = businessCategories)
            df = df.drop('categories',1)
            df = df.join(cat_df)
        elif sys.argv[1] == 'review':
            df = pd.DataFrame([getReviewData(x) for x in data], columns = ['id_review', 'id_business', 'date', 'date_year', 'date_month', 'date_day', 'date_weekday', 'id_user', 'votes_cool_review', 'votes_funny_review', 'votes_useful_review', 'stars_review', 'text'])
        elif sys.argv[1] == 'checkin':
            temp = ['id_business']
            global checks
            checks = []
            for hr in range(0,24):
                for day in range(0,7):
                    checks.append(str(hr) + '-' + str(day))
            temp.extend(checks)
            df = pd.DataFrame([getCheckinData(x) for x in data], columns = temp)                
        df.to_csv(sys.stdout, sep='\t', index=False, encoding='utf-8')
    else: # if invalid argument is provided, stop process
        sys.stderr.write('bad data type. Please choose one of the following arguments: user, business, review, or checkin')
        
def readJSON(json_file):
    '''
    reads raw json file, line by line
    ----------------------------------
    input:  array of individual raw json objects
    output: array of individual json objects
    '''
    data = []
    with open(json_file) as f:
        for line in f:
            data.append(json.loads(line))
    return data 
    
def getUserData(json_item):
    '''
    extracts user information objects
    --------------------------------------
    input:  
    
    '''
    id_user = json_item['user_id']
    name_user = json_item['name']
    review_count_user = json_item['review_count']
    votes_cool_user = json_item['votes']['cool']
    votes_funny_user = json_item['votes']['funny']
    votes_useful_user = json_item['votes']['useful']
    stars_user = json_item['average_stars']
    return [id_user, stars_user, name_user, review_count_user, votes_cool_user, votes_funny_user, votes_useful_user]

def getBusinessData(json_item):
    id_business = json_item['business_id']
    lat_business = json_item['latitude']
    lon_business = json_item['longitude']
    name_business = json_item['name']
    openclosed_business = json_item['open']
    review_count_business = json_item['review_count']
    stars_business = json_item['stars']
    categories = json_item['categories']
    
    return [id_business, lat_business, lon_business, name_business, openclosed_business, review_count_business, stars_business, categories]

def getReviewData(json_item):
    from datetime import datetime
    id_business = json_item['business_id']
    id_user = json_item['user_id']
    id_review = json_item['review_id']
    votes_cool_review = json_item['votes']['cool']
    votes_funny_review = json_item['votes']['funny']
    votes_useful_review = json_item['votes']['useful']
    stars_review = json_item['stars']
    text = json_item['text'].lower()
    date = datetime.strptime(json_item['date'], '%Y-%m-%d')
    date_year = date.year
    date_month = date.month
    date_day = date.day
 
    # Adjust weekday for convention used by Yelp, Sunday -> 0. Python's datetime has Monday -> 0
    date_weekday = (date.weekday() + 1) % 7
    return [id_review, id_business, date, date_year, date_month, date_day, date_weekday, id_user, votes_cool_review, votes_funny_review, votes_useful_review, stars_review, text]


def getCheckinData(json_item):
    id_business = json_item['business_id']
    checkinTimes = json_item['checkin_info'].keys()
    checkinValues = []
    
    for checkintime in checks:
        if checkintime in checkinTimes:
            checkinValues.append(json_item['checkin_info'][checkintime])
        else:
            checkinValues.append(0)        
    result = [id_business]
    result.extend(checkinValues)
    return result
    
def flatten(l):
    ''' Recursively remove nested brackets
    ------------------------------------------
    Parameters: l is a nested list    
    Output: flattenedList is an un-nested list    
    '''
    flattenedList = []
    for item in l:
        if isinstance(item, list):
            flattenedList.extend(flatten(item))
        else:
            flattenedList.append(item)
    return flattenedList
    
def binaryCategorizer(x):
    categoryVector = []
    for cat in businessCategories:
        if cat in x:
            categoryVector.append(1)
        else:
            categoryVector.append(0)
    return categoryVector

if __name__ == "__main__":
    main()