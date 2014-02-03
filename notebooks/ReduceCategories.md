
The purpose of this notebook is to define mutually exclusive categories for each
business in an algorithmic way. Below is a simple approach, using factor
analysis to reduce the 500+ unique category values, which have already been
binarized, to 20 components. These 20 components are then used as input into a
basic k-means clustering in order to classify businesses in an unsupervised
manner.


    import sklearn as sk
    import pandas as pd


    # Read in data
    df_business = pd.read_csv('../data/processed/yelp_business.tsv', sep='\t')


    # Extract only the binary category columns
    businesses = df_business.iloc[:,7:]


    from sklearn.decomposition import FactorAnalysis


    fa = FactorAnalysis(n_components=20) # Arbitrarily chose 20 components. 
    # See "factor_loadings_analysis.xls" for an understanding of how well variables group together. 
    # This reduction can be greatly improved in the future.


    # Note: Will take some time to run
    X = fa.fit_transform(businesses)


    factors = pd.DataFrame(fa.components_, columns = businesses.columns[0:])


    # Export factors to a tsv, which will be analyzed by hand (Excel) to see that variables are reasonably grouped
    factors.to_csv('../data/processed/factor_loadings_20.tsv', sep='\t')


    from sklearn.cluster import k_means


    cent, lab, inert = k_means(X, n_clusters = 8, random_state = 123)


    businesses['label'] = pd.Series(lab)


    businesses.label.value_counts() 
    # At k = 8, we have an alarming number of businesses in one class (maybe food related) 
    # Other classes have a reasonable number of observations.




    1    8542
    4     757
    7     640
    0     553
    2     474
    5     317
    6     136
    3     118
    dtype: int64




    # We now must 'profile' our classification, to get an idea of what these class assignments mean.
    # Using column means, we can examine the % of each binary category in each of the latent classes.


    def observeClasses(label):
        return businesses.groupby('label').mean().T.sort(label,ascending = False)


    #ex:
    observeClasses(1)




<div style="max-height:1000px;max-width:1500px;overflow:auto;">
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th>label</th>
      <th>0</th>
      <th>1</th>
      <th>2</th>
      <th>3</th>
      <th>4</th>
      <th>5</th>
      <th>6</th>
      <th>7</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>Restaurants</th>
      <td> 0.001808</td>
      <td> 0.488410</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.002642</td>
      <td> 0.003155</td>
      <td> 0.000000</td>
      <td> 0.510938</td>
    </tr>
    <tr>
      <th>Food</th>
      <td> 0.028933</td>
      <td> 0.176188</td>
      <td> 0.073840</td>
      <td> 0.000000</td>
      <td> 0.039630</td>
      <td> 0.003155</td>
      <td> 0.000000</td>
      <td> 0.045312</td>
    </tr>
    <tr>
      <th>Shopping</th>
      <td> 0.021700</td>
      <td> 0.124795</td>
      <td> 1.000000</td>
      <td> 0.000000</td>
      <td> 0.114927</td>
      <td> 0.107256</td>
      <td> 0.000000</td>
      <td> 0.012500</td>
    </tr>
    <tr>
      <th>Mexican</th>
      <td> 0.000000</td>
      <td> 0.070709</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.040625</td>
    </tr>
    <tr>
      <th>Active Life</th>
      <td> 0.000000</td>
      <td> 0.057598</td>
      <td> 0.014768</td>
      <td> 0.008475</td>
      <td> 0.010568</td>
      <td> 0.012618</td>
      <td> 0.000000</td>
      <td> 0.020313</td>
    </tr>
    <tr>
      <th>Pizza</th>
      <td> 0.000000</td>
      <td> 0.051744</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.023438</td>
    </tr>
    <tr>
      <th>Event Planning &amp; Services</th>
      <td> 0.000000</td>
      <td> 0.050222</td>
      <td> 0.004219</td>
      <td> 0.033898</td>
      <td> 0.011889</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.014063</td>
    </tr>
    <tr>
      <th>American (Traditional)</th>
      <td> 0.000000</td>
      <td> 0.045774</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.139063</td>
    </tr>
    <tr>
      <th>Fast Food</th>
      <td> 0.000000</td>
      <td> 0.045188</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Sandwiches</th>
      <td> 0.000000</td>
      <td> 0.044135</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.007812</td>
    </tr>
    <tr>
      <th>Hotels &amp; Travel</th>
      <td> 0.003617</td>
      <td> 0.042379</td>
      <td> 0.000000</td>
      <td> 0.033898</td>
      <td> 0.011889</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.003125</td>
    </tr>
    <tr>
      <th>Coffee &amp; Tea</th>
      <td> 0.000000</td>
      <td> 0.037228</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.006250</td>
    </tr>
    <tr>
      <th>Grocery</th>
      <td> 0.001808</td>
      <td> 0.035121</td>
      <td> 0.071730</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Health &amp; Medical</th>
      <td> 0.000000</td>
      <td> 0.034886</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.047556</td>
      <td> 0.003155</td>
      <td> 1.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Chinese</th>
      <td> 0.000000</td>
      <td> 0.033716</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Home Services</th>
      <td> 0.003617</td>
      <td> 0.031843</td>
      <td> 0.000000</td>
      <td> 1.000000</td>
      <td> 0.000000</td>
      <td> 0.053628</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Hotels</th>
      <td> 0.000000</td>
      <td> 0.031609</td>
      <td> 0.000000</td>
      <td> 0.025424</td>
      <td> 0.011889</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.003125</td>
    </tr>
    <tr>
      <th>American (New)</th>
      <td> 0.000000</td>
      <td> 0.030087</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001321</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.129688</td>
    </tr>
    <tr>
      <th>Pets</th>
      <td> 0.000000</td>
      <td> 0.029033</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Italian</th>
      <td> 0.001808</td>
      <td> 0.028799</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.025000</td>
    </tr>
    <tr>
      <th>Burgers</th>
      <td> 0.000000</td>
      <td> 0.028565</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.025000</td>
    </tr>
    <tr>
      <th>Ice Cream &amp; Frozen Yogurt</th>
      <td> 0.000000</td>
      <td> 0.027745</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Arts &amp; Entertainment</th>
      <td> 0.000000</td>
      <td> 0.026223</td>
      <td> 0.004219</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.121875</td>
    </tr>
    <tr>
      <th>Home &amp; Garden</th>
      <td> 0.007233</td>
      <td> 0.025521</td>
      <td> 0.027426</td>
      <td> 0.000000</td>
      <td> 0.001321</td>
      <td> 0.015773</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Fitness &amp; Instruction</th>
      <td> 0.000000</td>
      <td> 0.022243</td>
      <td> 0.008439</td>
      <td> 0.000000</td>
      <td> 0.009247</td>
      <td> 0.009464</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Breakfast &amp; Brunch</th>
      <td> 0.000000</td>
      <td> 0.021306</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.012500</td>
    </tr>
    <tr>
      <th>Specialty Food</th>
      <td> 0.000000</td>
      <td> 0.020955</td>
      <td> 0.002110</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Bakeries</th>
      <td> 0.000000</td>
      <td> 0.018848</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Delis</th>
      <td> 0.000000</td>
      <td> 0.017092</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Doctors</th>
      <td> 0.000000</td>
      <td> 0.016741</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.007926</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Japanese</th>
      <td> 0.000000</td>
      <td> 0.014282</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.004687</td>
    </tr>
    <tr>
      <th>Pet Services</th>
      <td> 0.000000</td>
      <td> 0.013931</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Buffets</th>
      <td> 0.000000</td>
      <td> 0.013580</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Books, Mags, Music &amp; Video</th>
      <td> 0.000000</td>
      <td> 0.011707</td>
      <td> 0.004219</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Gyms</th>
      <td> 0.000000</td>
      <td> 0.011590</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.002642</td>
      <td> 0.009464</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Arts &amp; Crafts</th>
      <td> 0.000000</td>
      <td> 0.010770</td>
      <td> 0.010549</td>
      <td> 0.000000</td>
      <td> 0.001321</td>
      <td> 0.003155</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Veterinarians</th>
      <td> 0.000000</td>
      <td> 0.010653</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Barbeque</th>
      <td> 0.000000</td>
      <td> 0.010536</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.003125</td>
    </tr>
    <tr>
      <th>Sushi Bars</th>
      <td> 0.000000</td>
      <td> 0.010419</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.007812</td>
    </tr>
    <tr>
      <th>Steakhouses</th>
      <td> 0.000000</td>
      <td> 0.010068</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.021875</td>
    </tr>
    <tr>
      <th>Seafood</th>
      <td> 0.000000</td>
      <td> 0.009951</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.004687</td>
    </tr>
    <tr>
      <th>Drugstores</th>
      <td> 0.000000</td>
      <td> 0.009951</td>
      <td> 0.023207</td>
      <td> 0.000000</td>
      <td> 0.038309</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Parks</th>
      <td> 0.000000</td>
      <td> 0.009600</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Mediterranean</th>
      <td> 0.000000</td>
      <td> 0.009483</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.006250</td>
    </tr>
    <tr>
      <th>Sporting Goods</th>
      <td> 0.001808</td>
      <td> 0.009365</td>
      <td> 0.056962</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Desserts</th>
      <td> 0.000000</td>
      <td> 0.009365</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Thai</th>
      <td> 0.000000</td>
      <td> 0.009131</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Greek</th>
      <td> 0.000000</td>
      <td> 0.009131</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Pet Stores</th>
      <td> 0.000000</td>
      <td> 0.008663</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Golf</th>
      <td> 0.000000</td>
      <td> 0.008663</td>
      <td> 0.000000</td>
      <td> 0.008475</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001563</td>
    </tr>
    <tr>
      <th>Public Services &amp; Government</th>
      <td> 0.000000</td>
      <td> 0.008312</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Beer, Wine &amp; Spirits</th>
      <td> 0.001808</td>
      <td> 0.008195</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.023438</td>
    </tr>
    <tr>
      <th>Asian Fusion</th>
      <td> 0.000000</td>
      <td> 0.008195</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.009375</td>
    </tr>
    <tr>
      <th>Furniture Stores</th>
      <td> 0.000000</td>
      <td> 0.008078</td>
      <td> 0.010549</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Flowers &amp; Gifts</th>
      <td> 0.000000</td>
      <td> 0.008078</td>
      <td> 0.004219</td>
      <td> 0.000000</td>
      <td> 0.001321</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Donuts</th>
      <td> 0.000000</td>
      <td> 0.007961</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Trainers</th>
      <td> 0.000000</td>
      <td> 0.007844</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.001321</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Education</th>
      <td> 0.000000</td>
      <td> 0.007727</td>
      <td> 0.002110</td>
      <td> 0.008475</td>
      <td> 0.005284</td>
      <td> 0.022082</td>
      <td> 0.007353</td>
      <td> 0.000000</td>
    </tr>
    <tr>
      <th>Tex-Mex</th>
      <td> 0.000000</td>
      <td> 0.007609</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.003125</td>
    </tr>
    <tr>
      <th>Venues &amp; Event Spaces</th>
      <td> 0.000000</td>
      <td> 0.007609</td>
      <td> 0.002110</td>
      <td> 0.008475</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.000000</td>
      <td> 0.009375</td>
    </tr>
    <tr>
      <th></th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
  </tbody>
</table>
<p>508 rows × 8 columns</p>
</div>



Summary:

0 ~ automotive services

1 ~ food/dining --- problems with uniqueness with respect to shopping

2 ~ shopping

3 ~ financial/real-estate services

4 ~ Beauty/personal-services

5 ~ Other maintenance services

6 ~ Medical and educations services

7 ~ Night life, bars, and other social dining

Let's see how these classifications appear in overall statistics by day of the
week (done in R for easier plotting)


    df_business['label'] = businesses['label']


    df_business.to_csv('../data/processed/business_withLabels.tsv', sep='\t')
