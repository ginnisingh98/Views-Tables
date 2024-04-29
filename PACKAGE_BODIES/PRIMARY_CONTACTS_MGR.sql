--------------------------------------------------------
--  DDL for Package Body PRIMARY_CONTACTS_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRIMARY_CONTACTS_MGR" AS
/* $Header: JTFAPRMB.pls 120.1 2005/07/02 02:00:24 appldev ship $ */

  FUNCTION query_primary_contacts(API_VERSION IN NUMBER DEFAULT 1.0,
                                  P_PARTY_ID  IN NUMBER)
  RETURN VARCHAR2 IS

     l_sort_data               JTF_TASKS_PUB.SORT_DATA;
     l_total_retrieved         NUMBER;
     l_total_returned          NUMBER;
     l_rs                      VARCHAR2(1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);
     l_version_num             NUMBER;

     l_first_name              VARCHAR2(2000);
     l_middle_name             VARCHAR2(2000);
     l_last_name               VARCHAR2(2000);

     new_row                   VARCHAR2(4000) := '';
     result                    VARCHAR2(4000) := '';

     current_count             NUMBER := 1;
     row_count                 NUMBER := 10;

      -- new field names:
      --SELECT PERSON_FIRST_NAME, PERSON_LAST_NAME,
      --       PERSON_MIDDLE_NAME
      --FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  ROW_ID = P_COMPANY_ID;

      --SELECT FIRST_NAME, LAST_NAME,
      --       MIDDLE_NAME
      --FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  PARTY_ID = P_COMPANY_ID;

     CURSOR primary_contacts IS
        SELECT FIRST_NAME, LAST_NAME, MIDDLE_NAME, PARTY_ID
        FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  LAST_NAME IS NOT NULL
        WHERE  PARTY_ID = P_PARTY_ID
      --AND    PARTY_ID < 9075
        ORDER BY 1;

     one_row primary_contacts%rowtype;

  BEGIN

--DBMS_OUTPUT.PUT_LINE('Querying primary contacts...');

     OPEN primary_contacts;
     FETCH primary_contacts INTO one_row;

     WHILE primary_contacts%FOUND LOOP

       current_count := current_count + 1;
       IF (current_count > row_count) THEN
         EXIT;
       END IF;

       l_first_name  := one_row.first_name;
       l_middle_name := one_row.middle_name;
       l_last_name   := one_row.last_name;

       IF( l_first_name IS NULL ) THEN
         l_first_name := 'first name null '||
                        one_row.party_id;
       END IF;

       IF( l_middle_name IS NULL ) THEN
         l_middle_name := 'middle name null '||
                        one_row.party_id;
       END IF;

       IF( l_last_name IS NULL ) THEN
         l_last_name := 'last name null '||
                        one_row.party_id;
       END IF;

       new_row := trim(l_first_name)||' '||trim(l_middle_name)
                                    ||' '||trim(l_last_name)||'^';
       result := result || new_row;

       FETCH primary_contacts INTO one_row;
     END LOOP;

     CLOSE primary_contacts;

     RETURN( result );

  END QUERY_PRIMARY_CONTACTS;


  PROCEDURE test(API_VERSION  IN NUMBER DEFAULT 1.0,
                P_PARTY_ID IN NUMBER DEFAULT 1) IS

     l_sort_data               JTF_TASKS_PUB.SORT_DATA;
     l_total_retrieved         NUMBER;
     l_total_returned          NUMBER;
     l_rs                      VARCHAR2(1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);
     l_version_num             NUMBER;

     l_first_name              VARCHAR2(2000) := '';
     l_middle_name             VARCHAR2(2000) := '';
     l_last_name               VARCHAR2(2000) := '';

     new_row                   VARCHAR2(4000) := '';
     result                    VARCHAR2(4000) := '';
     current_count             NUMBER := 1;
     row_count                 NUMBER := 10;

      -- new field names:
      --SELECT PERSON_FIRST_NAME, PERSON_LAST_NAME,
      --       PERSON_MIDDLE_NAME
      --FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  PARTY_ID = P_PARTY_ID

      --SELECT FIRST_NAME, LAST_NAME,
      --       MIDDLE_NAME
      --FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  PARTY_ID = P_PARTY_ID

     CURSOR primary_contacts IS
        SELECT FIRST_NAME, LAST_NAME, MIDDLE_NAME, PARTY_ID
        FROM   JTF_PARTY_CUSTOMERS_V
      --WHERE  LAST_NAME IS NOT NULL
        WHERE  PARTY_ID = P_PARTY_ID
      --AND    PARTY_ID < 9075
        ORDER BY 1;

     one_row primary_contacts%rowtype;

  BEGIN

  --   DBMS_OUTPUT.PUT_LINE('test Querying primary contacts...');

     OPEN primary_contacts;
     FETCH primary_contacts INTO one_row;

     WHILE primary_contacts%FOUND LOOP

       l_first_name  := one_row.first_name;
       l_middle_name := one_row.middle_name;
       l_last_name   := one_row.last_name;

       IF( l_first_name IS NULL ) THEN
         l_first_name := 'first name null '||
                        one_row.party_id;
       END IF;

       IF( l_middle_name IS NULL ) THEN
         l_middle_name := 'middle name null '||
                        one_row.party_id;
       END IF;

       IF( l_last_name IS NULL ) THEN
         l_last_name := 'last name null '||
                        one_row.party_id;
       END IF;

       new_row := trim(l_first_name)||' '||trim(l_middle_name)
                                    ||' '||trim(l_last_name)||'^';
       result := result || new_row;

--DBMS_OUTPUT.PUT_LINE('3 current_count = '||current_count);
--DBMS_OUTPUT.PUT_LINE('3 new row       = '||new_row);

       current_count := current_count + 1;
       IF (current_count > row_count) THEN
         EXIT;
       END IF;

       FETCH primary_contacts INTO one_row;
     END LOOP;

     CLOSE primary_contacts;

--DBMS_OUTPUT.PUT_LINE('result = '||result);

  END test;

END PRIMARY_CONTACTS_MGR;

/
