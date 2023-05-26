#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how may I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get service customer wants
  echo -e "1) cut\n2) color\n3) perm\n4) style\n5) trim"
  read SERVICE_ID_SELECTED

  # if service doesn't exist (not a number)
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]
    then
      # send to main
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      # get phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if no customer_id
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customer name
        echo I don't have a record for that phone number, what's your name?
        read CUSTOMER_NAME
        
        # insert new customer information
        CUSTOMER_INSULT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

        # get new customer_name
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      else
        # get customer name
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      fi
      echo "At what time would you like your appointment, $CUSTOMER_NAME?"
      read SERVICE_TIME

      echo $CUSTOMER_ID $SERVICE_ID_SELECTED $SERVICE_TIME

      SERVICE_TIME_INSERT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//')."
    fi
  fi
}

MAIN_MENU
