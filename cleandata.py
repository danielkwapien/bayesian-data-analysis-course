import pandas as pd
import requests

steps = pd.read_csv('./data/step_count_raw.csv')
forest = pd.read_csv('./data/forest.csv')
speeds = pd.read_csv('./data/step_speed_raw.csv')

steps.drop(columns=['EndDate'], inplace=True)
steps['StartDate'] = pd.to_datetime(steps['StartDate'], utc=True).dt.date
steps['StepCount'] = steps['StepCount'].astype(int)
steps_groupped = steps.groupby('StartDate')['StepCount'].sum().reset_index()
print(steps_groupped.head())

speeds.drop(columns=['EndDate'], inplace=True)
speeds['StartDate'] = pd.to_datetime(speeds['StartDate'], utc=True).dt.date
speeds['StepCount'] = speeds['Speed'].astype(float)
speeds = speeds.groupby('StartDate')['Speed'].mean().reset_index()
print(speeds.head())

steps = steps_groupped.join(speeds.set_index('StartDate'), on='StartDate', how='left')


forest.drop(columns=['Tag','Note','Tree Type','Is Success'], inplace=True)
print(forest.head())
forest['Start Time'] = pd.to_datetime(forest['Start Time'], utc=True).dt.tz_convert(None)
forest['End Time'] = pd.to_datetime(forest['End Time'], utc=True).dt.tz_convert(None)

forest['Duration'] = (forest['End Time'] - forest['Start Time']).dt.total_seconds() / 60
forest['Start Time'] = forest['Start Time'].dt.date
forest = forest.groupby('Start Time')['Duration'].sum().reset_index()


forest.set_index(pd.to_datetime(forest['Start Time']), inplace=True)
forest = forest.resample('D').asfreq().fillna(0)

print(forest['Start Time'])

steps.set_index(steps['StartDate'], inplace=True)
data = steps.join(forest, how='inner')
data['Day'] = data.index.day_name()
data = data.reset_index(inplace=False, drop=True).drop(columns=['Start Time'])
print(data.head(20))
#data = data.groupby(['StartDate', 'Duration', 'Day'])['StepCount'].sum().reset_index()
data.rename(columns={'StartDate': 'Date', 'Duration': 'Study', 'StepCount': 'Steps'}, inplace=True)

print(data.head(20))
data.to_csv('./data/cleaned_data.csv', index=False)
