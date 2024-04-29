--------------------------------------------------------
--  DDL for Package Body PMI_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_SECURITY_PKG" AS
/* $Header: PMISECPB.pls 115.10 2003/04/22 16:39:01 srpuri ship $ */

  	FUNCTION show_record
		( p_orgn_code VARCHAR2,
              P_orgn_type NUMBER,
              P_USER_ID   NUMBER)

		RETURN VARCHAR2 IS

       CURSOR 	Cur_resp(P_user_id NUMBER) IS
       SELECT 	Responsibility_id
       FROM   	fnd_user_resp_groups
       WHERE  	User_id = p_user_id
       AND	start_date <= SYSDATE
       AND 	(end_date IS NULL OR
		 end_date >= SYSDATE)
	AND 	responsibility_application_id = 558;

        l_user_id       	NUMBER(15);
        l_orgn_cnt      	NUMBER(15):= 0;
        l_profile_value 	VARCHAR2(4);
        l_responsibility_id 	NUMBER(15);
        l_result		      BOOLEAN;

        BEGIN

          IF (p_orgn_code  IS NULL) THEN
              RETURN  'FALSE';
          END IF;

          IF p_user_id IS NULL THEN
            l_user_id := FND_GLOBAL.USER_ID;
          ELSE
            l_user_id := p_user_id;
          END IF;

/* 11/17/99 This condition is to validate the organizations for PMF. It is
a temporary fix. Decision needs to be made in the next release - Savita */

          IF (FND_GLOBAL.USER_ID  = -1) THEN
		RETURN 'TRUE';
	  END IF;

          IF (l_user_id IS NULL)  THEN
             	RETURN 'FALSE';
          END IF;

          OPEN Cur_resp(l_user_id);

          LOOP

           	FETCH Cur_resp into l_responsibility_id;
     		EXIT WHEN Cur_resp%NOTFOUND;

 		 /* Check the All profile */

		fnd_profile.get_specific('PMI$COMPANY_ALL',l_user_id,l_responsibility_id,558,
                          l_profile_value,l_result);


		IF l_profile_value = 'ALL' THEN
                	 RETURN  'TRUE';
            END IF;

		/* Check company profile for responsibility */

		fnd_profile.get_specific('PMI$COMPANY',l_user_id,l_responsibility_id,558,l_profile_value,
                          l_result);

		IF l_profile_value IS NOT NULL THEN
              IF l_profile_value <> p_orgn_code THEN
                IF p_orgn_type = 2 THEN
		      SELECT  count(*)
                    INTO l_orgn_cnt
                  FROM sy_orgn_mst a
                  WHERE co_code = l_profile_value
		        AND a.orgn_code = p_orgn_code;
                  IF l_orgn_cnt > 0 THEN
                    RETURN 'TRUE';
                  END IF;
                END IF;
              ELSE
                RETURN 'TRUE';
              END IF;
            END IF;
          END LOOP;
          IF p_orgn_type = 2 THEN
            SELECT  count(*)
              INTO l_orgn_cnt
            FROM  sy_orgn_usr
            WHERE user_id   = l_user_id
              AND orgn_code = p_orgn_code;

            IF l_orgn_cnt > 0 THEN
      	  RETURN 'TRUE';
	      ELSE
 	        RETURN 'FALSE';
	      END IF;
	     ELSE
             RETURN 'FALSE';
           END IF;
	  RETURN 'FALSE';
   	END show_record;
END PMI_SECURITY_PKG ;

/
