--------------------------------------------------------
--  DDL for Package Body AP_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_NOTES_PVT" AS
/* $Header: apwnotvb.pls 120.2 2006/01/09 21:35:58 rlangi noship $ */


PKG_NAME      CONSTANT VARCHAR2(30):='AP_NOTES_PVT';


/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Get_User_Full_Name
--  TYPE                 : Public
--  PURPOSE              : Given a USER_ID the function will return the
--                         full name of the user.
--  PRE_REQS             : None
--
--  PARAMETERS           :
--  IN -
--  OUT -
--  IN OUT NO COPY -
--
--  MODIFICATION HISTORY :
--   Date         Author          Description of Changes
--   11-Nov-2003  V Nama          Created
--
--  NOTES                : Based on API - JTF_COMMON_PVT.GetUserInfo
--
-- End of comments
/*===========================================================================*/
FUNCTION Get_User_Full_Name (
  p_user_id                     IN     NUMBER
)
RETURN VARCHAR2
IS

   CURSOR c_user
   /****************************************************************************
   ** Cursor used to fetch the foreign keys needed to access the source tables
   ****************************************************************************/
   (b_user_id IN NUMBER
   )IS SELECT employee_id
       ,      customer_id
       ,      supplier_id
       ,      description
       ,      user_name
       FROM fnd_user
       WHERE user_id = b_user_id;

   CURSOR c_employee
   /****************************************************************************
   ** Cursor used to fetch the employee name in case the foreign key is to an
   ** Employee
   ****************************************************************************/
   (b_employee_id IN NUMBER
   )IS SELECT full_name
       ,      employee_number
       FROM per_people_x -- Bug 4730292/4890523
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
   l_description     VARCHAR2(360);
   l_user_name       VARCHAR2(360);

   l_number          VARCHAR2(30);
   l_name            VARCHAR2(240);
   l_display_info    VARCHAR2(500);

BEGIN
  /*****************************************************************************
  ** Get the foreigh keys to the user information
  *****************************************************************************/
  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;


  -- get info from fnd_user
  OPEN c_user(p_user_id);

  FETCH c_user
    INTO l_employee_id,l_customer_id,l_supplier_id,l_description,l_user_name;

  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;


  --check employee based name
  IF (l_employee_id IS NOT NULL)
  THEN
    -- get the employee information
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


  --return
  IF l_name IS NOT NULL
  THEN
    RETURN l_name;
  ELSE
    IF l_description IS NOT NULL
    THEN
      RETURN l_description;
    ELSE
      RETURN l_user_name;
    END IF;
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
END Get_User_Full_Name;



END AP_NOTES_PVT;

/
