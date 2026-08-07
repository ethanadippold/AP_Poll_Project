#This is for my preseason vs postseason AP Poll project
#I started by creating an excel spreadsheet with all the "bare bones" starting data I need
#First I need to import pandas because that's how I'm going to do all this
import pandas as pd
#now I need to turn that excel spreadsheet into a dataframe
df=pd.read_excel("APpollProj (1).xlsx", sheet_name=None)
#that reads the file and creates separate dataframes (df for dataframe), one per each sheet
#The "sheet_name=None" command is to ensure that it does every sheet, rather than just one
#Now we have to concatenate into one big table instead of 12 smaller ones,
#so we will create a big table called "combined"
combined = pd.concat(df.values())
#the table "combined" is made by using the pandas concat function on the "values" of the dataframes "df"
print(combined)
print(combined.shape)
#just quickly want to print and make sure that everyhting is running smoothly
#When running correctly should be 1 big table of 600 rows x 4 columns

#At this point I realized that when creating my original excel, I had only planned on getting week 0 and week 12
#When I actually did it, I did neither. I got postseason and preseason. I need to update to reflect that
week = {0:"Preseason", 12:"Postseason"}
#creates a dictionary that coorelates the ints 0 and 12 to the strings "preseason" and "postseason"
combined["Week"] = combined["Week"].replace(week)
print(combined)
#Takes the Week column from the combined table and replaces the values with the new ones defined in dictionary

combined.to_csv("AP_Poll_Script.csv", index=False)
#Converts combined into a csv to put into SQL
#index=false makes it so the extra pandas column does not get included
