#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Main Menu
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    if [[ $CUSTOMER_PHONE =~ [0-9] ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' AND name = '$CUSTOMER_NAME'")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE CUSTOMER_ID = $CUSTOMER_ID")
      fi

      echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *//g'), $(echo $CUSTOMER_NAME | sed 's/^ *//g')?"
      read SERVICE_TIME

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *//g') at $(echo $SERVICE_TIME | sed 's/^ *//g'), $(echo $CUSTOMER_NAME | sed 's/^ *//g')."

      else
        MAIN_MENU "Please input correct format phone number."
    fi
  fi
}

MAIN_MENU