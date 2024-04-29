--------------------------------------------------------
--  DDL for Package Body BOMPCOAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCOAN" AS
/* $Header: BOMCOANB.pls 120.2.12010000.3 2010/01/25 20:20:50 umajumde ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCOANB.pls                                               |
| DESCRIPTION  :                                                            |
|              This file creates a packaged procedure that performs ECO     |
|              autonumbering.  When passed a user id and an organization    |
|              id, it searches for a valid ECO autonumber prefix and next   |
|              available number, searching in the following order:          |
|                 1 - specific user, specific organization                  |
|                 2 - specific user, across all organizations               |
|                 3 - specific organization, across all users               |
|                 4 - across all users and all organizations                |
| INPUTS       :  P_USER_ID - user id					    |
|                 P_ORGANIZATION_ID - organization id                       |
|                 P_MODE - indicates whether or not to update next          |
|                          available number in the ECO autonumber table     |
|                                                                           |
+==========================================================================*/



--Begin  bug fix 9234014
PROCEDURE Check_Next_AutoNum(p_user_id  IN NUMBER
   , p_organization_id  IN NUMBER
   , p_change_notice IN VARCHAR2
   , x_return_status IN OUT NOCOPY VARCHAR2)

IS
    p_next_number       ENG_AUTO_NUMBER_ECN.NEXT_AVAILABLE_NUMBER%TYPE;
    p_prefix_temp       VARCHAR2(12);
    p_prefix_temp1       VARCHAR2(12);
    p_greatest_num      NUMBER;
    l_return_status     VARCHAR2(1);
    p_temp_number      NUMBER;
    no_prefix_found     EXCEPTION;

    CURSOR PREFIX_CURSOR (c_user_id IN NUMBER,
                          c_org_id  IN NUMBER,
                          c_prefix IN VARCHAR2) IS
                 SELECT
                          alpha_prefix,
                          next_available_number
                 FROM     eng_auto_number_ecn
                 WHERE    nvl(organization_id, c_org_id) = c_org_id
                 AND      nvl(user_id, c_user_id) = c_user_id
                 AND      alpha_prefix = c_prefix
		             AND      change_type_id IS NULL
                 ORDER BY user_id, organization_id;


BEGIN



P_PREFIX_TEMP1 := RTRIM(P_CHANGE_NOTICE,'0123456789');

IF P_PREFIX_TEMP1 = P_CHANGE_NOTICE
THEN
  RAISE no_prefix_found;
ELSE
 OPEN PREFIX_CURSOR(P_USER_ID, P_ORGANIZATION_ID, P_PREFIX_TEMP1);

 FETCH PREFIX_CURSOR INTO
                         p_prefix_temp,
                         p_next_number;

/* If no prefix is found, raise an exception and return to calling routine */

 IF PREFIX_CURSOR%NOTFOUND
 THEN RAISE no_prefix_found;
 END IF;
 CLOSE PREFIX_CURSOR;

END IF;

/* Find the chosen prefix and next number combination */
--p_temp_num is from change_notice
P_TEMP_NUMBER := GREATEST(TO_NUMBER(LTRIM(P_CHANGE_NOTICE,P_PREFIX_TEMP)))+1;

P_NEXT_NUMBER := GREATEST(P_NEXT_NUMBER, P_TEMP_NUMBER);

SELECT GREATEST(P_NEXT_NUMBER,
       NVL(GREATEST(TO_NUMBER(LTRIM(CHANGE_NOTICE,P_PREFIX_TEMP))),0)+1)
INTO   P_GREATEST_NUM
FROM   ENG_ENGINEERING_CHANGES
WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
AND    RTRIM(CHANGE_NOTICE,'0123456789') = P_PREFIX_TEMP;

P_NEXT_NUMBER := GREATEST(P_GREATEST_NUM, P_NEXT_NUMBER);

/* Ensure that the length of the entire string is less than or equal to 10,
the maximum length for ECO name */

if LENGTHB(P_PREFIX_TEMP || P_NEXT_NUMBER) <= 10
then
   l_return_status := 'S';
else
   l_return_status := 'F';
end if;
x_return_status := l_return_status;


EXCEPTION
WHEN no_prefix_found THEN
 l_return_status := 'S';
 x_return_status := l_return_status;

 WHEN no_data_found THEN
   if LENGTHB(P_PREFIX_TEMP || P_NEXT_NUMBER) <= 10
   then
     l_return_status := 'S';
  else
     l_return_status := 'F';
  end if;
x_return_status := l_return_status;
WHEN others THEN
 l_return_status := 'S';
 x_return_status := l_return_status;

END Check_Next_AutoNum;

--Eng bug fix 9234014


PROCEDURE BOM_ECO_AUTONUMBER
   (P_USER_ID 			IN	NUMBER,
    P_ORGANIZATION_ID		IN	NUMBER,
    P_MODE 			IN      NUMBER,
    P_PREFIX			IN OUT NOCOPY  VARCHAR2,
    x_return_status		IN	OUT NOCOPY    VARCHAR2)
IS

    p_next_number       ENG_AUTO_NUMBER_ECN.NEXT_AVAILABLE_NUMBER%TYPE;
    p_prefix_temp       VARCHAR2(12);
    p_output_user_id    NUMBER;
    p_output_org_id     NUMBER;
    p_greatest_num      NUMBER;
    l_rowid             VARCHAR2(102);
    p_next_num_temp     number; --added for bug 9234014

    no_prefix_found     EXCEPTION;
    next_eco_invalid    EXCEPTION;  --added for bug 9234014
 /* Added row_id to the cursor */
    CURSOR PREFIX_CURSOR (c_user_id IN NUMBER,
                          c_org_id  IN NUMBER) IS
                 SELECT
		          rowid ,
			  alpha_prefix,
                          next_available_number,
                          user_id,
                          organization_id
                 FROM     eng_auto_number_ecn
                 WHERE    nvl(organization_id, c_org_id) = c_org_id
                 AND      nvl(user_id, c_user_id) = c_user_id
		 AND      change_type_id IS NULL --* Added for bug #3959772
                 ORDER BY user_id, organization_id
		 FOR UPDATE;


BEGIN

/* P_MODE = 1 --> update ENG_AUTO_NUMBER_ECN to show next available
                  number
*/

OPEN PREFIX_CURSOR(P_USER_ID, P_ORGANIZATION_ID);

FETCH PREFIX_CURSOR INTO
                         l_rowid ,
                         p_prefix_temp,
                         p_next_number,
                         p_output_user_id,
                         p_output_org_id;

/* If no prefix is found, raise an exception and return to calling routine */

IF PREFIX_CURSOR%NOTFOUND
THEN RAISE no_prefix_found;
END IF;

CLOSE PREFIX_CURSOR;

/* Ensure that chosen prefix and next number has not already been used */

SELECT GREATEST(P_NEXT_NUMBER,
       NVL(MAX(TO_NUMBER(LTRIM(CHANGE_NOTICE,P_PREFIX_TEMP))),0)+1)
INTO   P_GREATEST_NUM
FROM   ENG_ENG_CHANGES_INTERFACE
WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
AND    RTRIM(CHANGE_NOTICE,'0123456789') = P_PREFIX_TEMP;

P_NEXT_NUMBER := GREATEST(P_GREATEST_NUM, P_NEXT_NUMBER);

SELECT GREATEST(P_NEXT_NUMBER,
       NVL(MAX(TO_NUMBER(LTRIM(CHANGE_NOTICE,P_PREFIX_TEMP))),0)+1)
INTO   P_GREATEST_NUM
FROM   ENG_ENGINEERING_CHANGES
WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
AND    RTRIM(CHANGE_NOTICE,'0123456789') = P_PREFIX_TEMP;

P_NEXT_NUMBER := GREATEST(P_GREATEST_NUM, P_NEXT_NUMBER);

/* Ensure that the length of the entire string is less than or equal to 10,
the maximum length for ECO name */


if LENGTHB(P_PREFIX_TEMP || P_NEXT_NUMBER) <= 10
then
    p_next_num_temp := P_NEXT_NUMBER + 1;
  --check if the next available number would be greater than > 10 digits then fail this update and raise exception
  --added for bug 9234014 (begin)
  if LENGTHB(P_PREFIX_TEMP || p_next_num_temp) > 10 THEN
   RAISE next_eco_invalid;
   --added for bug 9234014 (end)
  else

   if P_MODE = 1   -- Only update the autonumber table if P_MODE is 1
   then
   --Added rowd_id ,as for case 4 ,the update statement updated all the records ,which is not desirable
   UPDATE ENG_AUTO_NUMBER_ECN
   SET NEXT_AVAILABLE_NUMBER = P_NEXT_NUMBER+1
   WHERE NVL(ORGANIZATION_ID, -999) = NVL(P_OUTPUT_ORG_ID, -999)
   AND   NVL(USER_ID, -999) = NVL(P_OUTPUT_USER_ID, -999)
   AND   rowid =l_rowid;
   end if;
 end if;
P_PREFIX := P_PREFIX_TEMP || P_NEXT_NUMBER;
x_return_status := 'S'; --added for bug 9234014
else RAISE no_prefix_found;

end if;

EXCEPTION
WHEN no_prefix_found THEN --added for bug 9234014 (begin)
P_PREFIX := null;
x_return_status := 'F';

WHEN next_eco_invalid
THEN
P_PREFIX := P_PREFIX_TEMP || P_NEXT_NUMBER;
x_return_status := 'F';

WHEN others THEN
P_PREFIX := null;
x_return_status := 'F'; --added for bug 9234014 (end)

END BOM_ECO_AUTONUMBER;

END BOMPCOAN;

/
