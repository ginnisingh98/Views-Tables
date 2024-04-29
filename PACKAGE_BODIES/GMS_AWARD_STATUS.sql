--------------------------------------------------------
--  DDL for Package Body GMS_AWARD_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARD_STATUS" AS
/* $Header: gmsawrlb.pls 120.1 2005/07/26 14:20:58 appldev ship $ */

 FUNCTION gms_primary_member (x_award_id IN  NUMBER)
  RETURN NUMBER IS

 l_personnel_id  NUMBER;
 l_award_id   	 NUMBER;
 l_award_role 	 VARCHAR2(30);

  CURSOR award_primary_member IS
         SELECT personnel_id
           FROM gms_personnel
          WHERE award_id = x_award_id
            AND award_role = l_award_role
          ORDER BY end_date_active desc;

 BEGIN

  --initializing all local variables to NULL.
  l_personnel_id  := NULL;
  l_award_id   	  := NULL;
  l_award_role    := NULL;

   --checking if valid award_id is entered as input.
	BEGIN
	   SELECT  award_id
    	   INTO  l_award_id
           FROM  gms_awards
           WHERE  award_id = x_award_id;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RETURN(-8888);
           WHEN OTHERS THEN
             RETURN(-9999);
       END;

    -- processing comes here only when valid award_id is entered as input.
    -- checking for 'PI's for that Award.

   l_award_role := 'PI';
   OPEN award_primary_member;
   FETCH award_primary_member INTO l_personnel_id;
   CLOSE award_primary_member;

    -- processing comes here only when valid award_id is entered
    -- as input and award_role 'PI' is not defined.

   IF l_personnel_id IS NULL THEN
     l_award_role := 'AM';
     OPEN award_primary_member;
     FETCH award_primary_member INTO l_personnel_id;
     CLOSE award_primary_member;
   END IF;

   RETURN (NVL(l_personnel_id, 0));

 END gms_primary_member;

END GMS_AWARD_STATUS;  --End of Package Body

/
