#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU(){
  echo -e "\n~~~~~ MY SALON ~~~~~"
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi
  GET_SERVICES=$($PSQL "select * from services")
  echo "$GET_SERVICES" | while read SERVICE_ID BAR NAME BAR
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-6]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    GET_CUSTOMER_NAME_WITH_PHONENUMBER=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
    GET_SELECTION_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

    if [[ -z $GET_CUSTOMER_NAME_WITH_PHONENUMBER ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      SAVE_CUSTOMER=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

      echo -e "\nWhat time would you like your $GET_SELECTION_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME

      GET_CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$CUSTOMER_NAME'")
      SAVE_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($GET_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

      echo -e "\nI have put you down for a $GET_SELECTION_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo SERVICE_TIME
      GET_CUSTOMER_ID=$($PSQL "select customer_id from customers where name='$GET_CUSTOMER_NAME_WITH_PHONENUMBER'")
      SAVE_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($GET_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo -e "\nI have put you down for a $GET_SELECTION_NAME at $SERVICE_TIME, $GET_CUSTOMER_NAME_WITH_PHONENUMBER."
    fi
  fi
}
MAIN_MENU