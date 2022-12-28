#!/bin/bash

# Make the curl request and store the result in a file
curl --request GET \
        --url https://vaccovid-coronavirus-vaccine-and-treatment-tracker.p.rapidapi.com/api/npm-covid-data/ \
        --header 'X-RapidAPI-Host: vaccovid-coronavirus-vaccine-and-treatment-tracker.p.rapidapi.com' \
        --header 'X-RapidAPI-Key: 18aa1ab4d5msh0776885b18f496ap18781fjsne16b6bc5c7b9'  > api.txt

# Extract the values for France
line="$(cat api.txt | grep -oP '"Country":"France".*?}')"
echo $line

# Remove the curly braces from the line
line=${line#\{}
line=${line%\}}

# Split the line on the commas
IFS=',' read -r -a array <<< "$line"
result=""


# Iterate through the array and extract the key and value for each element
for element in "${array[@]}"; do
        # Split the element on the colon
        IFS=':' read -r -a pair <<< "$element"
        key=${pair[0]}
        value=${pair[1]}
        # Remove the quotes from the key and value
        key=${key#\"}
        key=${key%\"}
        value=${value#\"}
        value=${value%\"}
        # Store the key and value in variables
        if [ "$key" = "Country" ]; then
                country=$value
        elif [ "$key" = "Continent" ]; then
                continent=$value
        elif [ "$key" = "Population" ]; then
                population=$value
        elif [ "$key" = "Infection_Risk" ]; then
                infection_risk=$value
        elif [ "$key" = "Case_Fatality_Rate" ]; then
                case_fatality_rate=$value
        elif [ "$key" = "TotalCases" ]; then
                total_cases=$value
        elif [ "$key" = "TotalDeaths" ]; then
                total_deaths=$value
        elif [ "$key" = "TotalRecovered" ]; then
                total_recovered=$value
        elif [ "$key" = "ActiveCases" ]; then
                active_cases=$value
        elif [ "$key" = "TotalTests" ]; then
                total_tests=$value
        fi
done

# Put the value into a airtable table with api
curl -X POST https://api.airtable.com/v0/appNly6KQtUVC2Mot/covidFrance\
 -H "Authorization: Bearer keyb8gsvTJ7gwCm8n"\
 -H "Content-Type: application/json"\
 --data '{"fields": {
        "Country": "'"$country"'",
        "Continent": "'"$continent"'",
        "Population": "'"$population"'", 
        "Total_cases": "'"$total_cases"'", 
        "Total_deaths": "'"$total_deaths"'", 
        "Total_recovered": "'"$total_recovered"'", 
        "Total_tests": "'"$total_tests"'", 
        "Actives_cases": "'"$active_cases"'", 
        "Infection_risk": "'"$infection_risk"'", 
        "Case_fatality_rate": "'"$case_fatality_rate"'"
        },"typecast": true}'


# Send telegram message with if the infection risk is greater than 75%
if ["$infection_risk" -gt 75]; then 
        curl --data chat_id="-1001838128850" --data-urlencode "text=High infection risk : $infection_risk%. Pay attention... (//site à ajouter)" "https://api.telegram.org/bot5625068551:AAHxjTB01jzP3iel5SBLCBfCgHafApewPrs/sendMessage?parse_mode=HTML"
fi