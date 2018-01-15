https://fordc5.github.io/ExtremeWeatherAndTerrorism/


### Note on reproducibility

We have created this repository with the intention that the analysis is 100% reproducible. Cloning the code and compiling the R code should be straightforward with the caveat that our data is stored on GitHub with lfs. This means if not already familiar with lfs a couple key steps are needed to run the code:



Install lfs:

```$ brew update ```

```$ brew install git-lfs```

```$ git lfs install```

Before putting the .csv files in your **local** git repo:

```$ git lfs track "*.csv"```

``` gitt clone ...```

```git pull```


## Update

1. Have you already collected, or do you have access to, all of the data that you will need in order to complete your project? If not, please estimate the percentage of the data that you have, describe any issues that you are having, and what your plan is for getting the rest of the data.

We have our terrorism, temperature, and drought data. For now, we believe that this covers all the raw data that we will need. We assume that we will have to be creative with this raw data by creating more columns such as "number of attacks that have occurred in this region in past year" and "average change in temperature over the past year". We are having some issues with our data which we will describe below.

2. What is the single biggest unresolved issue you are having? Please describe it briefly, and what your plan is for resolving this issue.
    
Our biggest issue to date is that because have so much data, when we wrangle/join global terrorism and temperature data we have large holes in the terrorism data. We also have limited global accessibility to drought data, so are going to create our initial model for only the United States where there are fewer terrorist attacks and more robust temperature, drought, and rain data.
    
3. What are the elements from outside of the course, if any, that you plan to incorporate into your project?

We are going to create a neural net to predict whether or not a terrorist attack will occur on a given day in a given place and make some visualizations that we didn't cover in the course. These visualizations will hopefully elucidate trends in weather and terrorism on their own over time as well as possible links between the two phenomenon.

###  Prof Hardin comments on update

I like the fact that you know enough about your data to know that there will be limitations.  Given that you are focused on the US, do you feel comfortable about the current amount of missing data?  That is, does your US only data have any missing data?  You might need to impute information (kNN??) if there is sitll missing information.

Neural network sounds great!  If the groups have substantial imbalance (very few terrorist attacks), you might investigate whether there are neural networks which are specific to situations with a lot of imbalance.   I'm not super familiar with neural networks in particular, but I do know that random forests, for example, use different criteria for splitting when applied to imbalanced data.  

You are right on track, nice job.  Let me know if there are any specific questions I can answer.


## Proposal

Bradley Druzinsky and Connor Ford
Computational Statistics
Updated Project Proposal
November 3rd, 2017

The Intersection of Climate Change and Terrorism

Purpose

When our world’s climate turns for the worst, does it become deadly? In October of 2015, speaking at the Universal Exhibition in Milan, John Kerry stated that “I’m not telling you that the crisis in Syria was caused by climate change, but the devastating drought clearly made a bad situation a lot worse.” Was Kerry right? Or was the parallel of crisis and drought a mere consequence? We want to explore if climate change, droughts, flooding, monsoons, and other extreme weather patterns can forecast the likelihood of terrorist activity in certain areas around the world. Training and testing a model on weather and terrorist data from the last 40+ years will hopefully shed light on where and when the next large terrorist attack is likely to happen.

Biggest Issue(s) To Date

We understand that the topics of climate change and terrorism are both extremely broad and wide-ranging. For this reason, our project is still lacking some specificity as to what exact questions we will be answering, or trying to answer, in our project. Our plan to add precision to this project is do some exploratory work once we have completed our data set. This will include looking at summary statistics, examining potential correlations variables, and creating some nice visualizations. The hope is to use these in order to hone in on what are the most interesting phenomenons in our dataset and thus ask better, more specific questions.

Also, we need to come up with a more specific definition of outlier as it pertains to extreme weather. This will involved diving into some climate literature to see how that field of research defines extreme weather.

Group Roles

Being a two person group and having worked together on previous occasions, the two of us feel more comfortable with having a more fluid group dynamic. However, for the sake of assigning group roles, Connor will be the director of computation and project management, Bradley will be the director of research and task management, and the two will share the responsibilities of the reporter and facilitator.

Data

We believe that we have roughly 80% of our data. We feel confident in the quality of our terrorism dataset and once we have joined our weather/climate data sets to it, we will try to find holes/gaps in our new dataset. These gaps might be a lack of weather/climate info on particular regions of the world. We will try to fill these holes by supplementing our data set with data from regions that we are missing.

Global Terrorism: 
We will use the Global Terrorism Database which has information on over 170,000 terrorist attacks since 1970. Each unit in the database is an attack and includes information on the time, location, tactics, perpetrators, and targets of said attack. The database is in CSV format.

Link:
https://www.kaggle.com/START-UMD/gtd/data

Climate Change:

There are a few sources that we may use for our climate change data. One such is the Berkeley Earth dataset which contains average monthly temperature in particular location (i.e. city, state, or country) going back to 1750. This data is in csv format. Another source may be the Storm Events Database which contains info on rare and deadly weather occurrences by location. This source is in csv format. Another source may be a dataset on African rainfall which is spatial data which will require more research on our part to learn how to handle.

Links: https://www.kaggle.com/berkeleyearth/climate-change-earth-surface-temperature-data/data
https://www.ncdc.noaa.gov/stormevents/
https://catalog.data.gov/dataset/climate-prediction-center-cpc-africa-rainfall-climatology-version-2-0-arc2-01d37

Definitions

Terrorist attack: "The threatened or actual use of illegal force and violence by a non-state actor to attain a political, economic, religious, or social goal through fear, coercion, or intimidation." (SMART at University of Maryland)

Extreme weather: Outliers (see issues) from historical averages in temperature, rainfall, seismic activity

Time period: A set of consecutive days grouping terrorism and weather data. We will not explicitly define a set time period, rather experiment with a couple (i.e. 30 days, 60 days, etc..)

Variables

Location: City, State, or Country where weather event or temperature change occurred and terrorist attack occurred.

Date: Month and Year for both weather events and terrorist attacks

Temperature: Historical and actual average monthly temperature at a given location measured in celsius.

Rainfall: Historical and actual rainfall counts for a given location

Earthquakes: Occurrence and magnitude of earthquakes at a given location/region

(Weather) Event Type: Classification of storm (i.e. tornado, thunderstorm)

(Weather) Number Killed: The number of individuals killed in the weather event.

(Weather) Property Damage: A measure of impact of a weather event based on damage it caused in USD

(Terrorist) Target Type: The target of the terrorist attack (i.e. Government, Private Company, Individual)

(Terrorist) Weapon Type: The category of weapon used in terrorist attack

(Terrorist) Number Killed: The number of individuals killed in a terrorist attack

End Product

Ultimately, we want to create a predictive model that calculates the likelihood of a terrorist event occurring in specific regions (i.e. cities, states, or countries) for a given time period (i.e. next month). In addition to this, we hope to provide insights into what the potential terrorist attack could look like (i.e. will private individuals or the government be targeted). With some more research into neural networks, the two of us hope to create one using our dataset to create this predictive model.  We also hope to create a graphic that depicts terrorist attacks over time superimposed on a world or local map.


