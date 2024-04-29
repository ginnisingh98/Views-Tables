--------------------------------------------------------
--  DDL for Package Body JTF_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_COMMON_PVT" 
/* $Header: jtfvcmnb.pls 120.2 2006/06/29 07:26:46 abraina ship $ */
AS

FUNCTION GetUserInfo
/*******************************************************************************
** Given a USER_ID the function will return the username/partyname. This
** Function is used to display the CREATED_BY who column information on JTF
** transaction pages.
*******************************************************************************/
(p_user_id IN NUMBER
)RETURN VARCHAR2
IS
   CURSOR c_user
   /****************************************************************************
   ** Cursor used to fetch the foreign keys needed to access the source tables
   ****************************************************************************/
   (b_user_id IN NUMBER
   )IS SELECT employee_id
       ,      customer_id
       ,      supplier_id
       ,      user_name
       FROM fnd_user
       WHERE user_id = b_user_id;

   CURSOR c_employee_active
   /****************************************************************************
   ** Cursor used to fetch the employee name in case the foreign key is to an
   ** Employee
   ****************************************************************************/
   (b_employee_id IN NUMBER
   )IS SELECT full_name
       ,      employee_number
       FROM per_all_people_f
       WHERE person_id = b_employee_id
       AND trunc(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

   CURSOR c_employee
   /****************************************************************************
   ** Cursor used to fetch the employee name in case the foreign key is to an
   ** Employee
   ****************************************************************************/
   (b_employee_id IN NUMBER
   )IS SELECT full_name
       ,      employee_number
       FROM per_all_people_f
       WHERE person_id = b_employee_id;

   CURSOR c_party
   /****************************************************************************
   ** Cursor used to fetch the party name in case the foreign key is to a
   ** Customer or Supplier
   ****************************************************************************/
   (b_party_id IN NUMBER
   )IS SELECT party_name
       ,      party_number
       FROM hz_parties
       WHERE party_id = b_party_id;

   l_employee_id     NUMBER;
   l_customer_id     NUMBER;
   l_supplier_id     NUMBER;
-- For bug 5360709. Increased the variable length.
   l_user_name       VARCHAR2(1000);

   l_number          VARCHAR2(30);
   l_name            VARCHAR2(500);
   l_display_info    VARCHAR2(500);


BEGIN
  /*****************************************************************************
  ** Get the foreigh keys to the user information
  *****************************************************************************/
  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

  OPEN c_user(p_user_id);

  FETCH c_user INTO l_employee_id,l_customer_id,l_supplier_id,l_user_name;

  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

  IF (l_employee_id IS NOT NULL)
  THEN
    -- get the employee information
    --first see if there are any active records
    IF c_employee_active%ISOPEN
    THEN
      CLOSE c_employee_active;
    END IF;

    OPEN c_employee_active(l_employee_id);

    FETCH c_employee_active INTO l_name,l_number;

    IF c_employee_active%NOTFOUND
    THEN
      IF c_employee%ISOPEN
      THEN
        CLOSE c_employee;
      END IF;

      OPEN c_employee(l_employee_id);

      FETCH c_employee INTO l_name,l_number;

      IF c_employee%ISOPEN
      THEN
        CLOSE c_employee;
      END IF;
    END IF;

    IF c_employee_active%ISOPEN
    THEN
      CLOSE c_employee_active;
    END IF;

  ELSIF (l_customer_id IS NOT NULL)
  THEN
    -- get the customer information
    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;

    OPEN c_party(l_customer_id);

    FETCH c_party INTO l_name, l_number;

    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;

  ELSIF (l_supplier_id IS NOT NULL)
  THEN
    -- get the supplier information
    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;

    OPEN c_party(l_supplier_id);

    FETCH c_party INTO l_name, l_number;

    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;
  END IF;

  IF l_name IS NULL
  THEN
    RETURN l_user_name;
  ELSE
    RETURN l_name||'('||l_user_name||','||l_number||')';
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    IF c_employee%ISOPEN
    THEN
      CLOSE c_employee;
    END IF;

    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;
    RETURN 'Not Found';
END GetUserInfo;

END JTF_COMMON_PVT;

/
