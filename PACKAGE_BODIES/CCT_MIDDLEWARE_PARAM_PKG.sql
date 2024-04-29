--------------------------------------------------------
--  DDL for Package Body CCT_MIDDLEWARE_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_MIDDLEWARE_PARAM_PKG" AS
/* $Header: cctmwseb.pls 115.0 2003/05/20 17:48:57 rajayara noship $ */
PROCEDURE init IS
BEGIN
 Ordering_index :=10;
END init;

PROCEDURE seed_param(
         P_MIDDLEWARE_TYPE_ID IN VARCHAR2,
         P_NAME IN VARCHAR2,
         P_TYPE IN VARCHAR2,
         P_LENGTH IN VARCHAR2,
         P_DOMAIN_LOOKUP_TYPE IN VARCHAR2
         ) IS
BEGIN

        seed_param(
         P_MIDDLEWARE_PARAM_ID => null,
         P_MIDDLEWARE_TYPE_ID => P_MIDDLEWARE_TYPE_ID,
         P_NAME =>P_NAME,
         P_TYPE =>P_TYPE,
         P_LENGTH=>P_LENGTH,
         P_ORDERING_SEQUENCE =>Ordering_index,
         P_DOMAIN_LOOKUP_TYPE=>P_DOMAIN_LOOKUP_TYPE
         );

         Ordering_index := Ordering_index+10;
END;





PROCEDURE seed_param(
         P_MIDDLEWARE_PARAM_ID IN VARCHAR2,
         P_MIDDLEWARE_TYPE_ID IN VARCHAR2,
         P_NAME IN VARCHAR2,
         P_TYPE IN VARCHAR2,
         P_LENGTH IN VARCHAR2,
         P_DOMAIN_LOOKUP_TYPE IN VARCHAR2
         ) IS
BEGIN

        seed_param(
         P_MIDDLEWARE_PARAM_ID => P_MIDDLEWARE_PARAM_ID,
         P_MIDDLEWARE_TYPE_ID => P_MIDDLEWARE_TYPE_ID,
         P_NAME =>P_NAME,
         P_TYPE =>P_TYPE,
         P_LENGTH=>P_LENGTH,
         P_ORDERING_SEQUENCE =>Ordering_index,
         P_DOMAIN_LOOKUP_TYPE=>P_DOMAIN_LOOKUP_TYPE
         );

         Ordering_index := Ordering_index+10;
END;


PROCEDURE seed_param(
         P_MIDDLEWARE_PARAM_ID IN VARCHAR2,
         P_MIDDLEWARE_TYPE_ID IN VARCHAR2,
         P_NAME IN VARCHAR2,
         P_TYPE IN VARCHAR2,
         P_LENGTH IN VARCHAR2,
         P_ORDERING_SEQUENCE IN VARCHAR2,
         P_DOMAIN_LOOKUP_TYPE IN VARCHAR2
         ) IS

 CURSOR csr_chk_upgrade_need IS
   SELECT 1
   FROM CCT_MIDDLEWARE_PARAMS
   WHERE NAME= P_NAME
   and TYPE = P_TYPE
   and LENGTH = P_LENGTH
   and MIDDLEWARE_TYPE_ID = P_MIDDLEWARE_TYPE_ID
   and DOMAIN_LOOKUP_TYPE =P_DOMAIN_LOOKUP_TYPE
   and ORDERING_SEQUENCE = P_ORDERING_SEQUENCE;


 CURSOR csr_chk_param_exists IS
   SELECT MIDDLEWARE_PARAM_ID
   FROM CCT_MIDDLEWARE_PARAMS
   WHERE NAME= P_NAME
   and MIDDLEWARE_TYPE_ID = P_MIDDLEWARE_TYPE_ID;

  l_param_id cct_middleware_params.middleware_param_id%TYPE;
  l_temp VARCHAR2(20);

BEGIN
  dbms_output.put_line('Inside seed');
  OPEN csr_chk_upgrade_need;
  FETCH csr_chk_upgrade_need into l_temp;
   IF (csr_chk_upgrade_need%NOTFOUND) THEN
       dbms_output.put_line('Inside seed - Upgrade needed');
     OPEN csr_chk_param_exists;
     FETCH csr_chk_param_exists into l_param_id;
       IF(csr_chk_param_exists%NOTFOUND) THEN
         dbms_output.put_line('Inside seed - Upgrade needed - Need to create');
         -- Create
         INSERT INTO CCT_MIDDLEWARE_PARAMS
           (MIDDLEWARE_PARAM_ID, MIDDLEWARE_TYPE_ID, NAME, TYPE, LENGTH,ORDERING_SEQUENCE,DOMAIN_LOOKUP_TYPE,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY)
         select CCT_MIDDLEWARE_PARAMS_S.NEXTVAL+1000, P_MIDDLEWARE_TYPE_ID, P_NAME, P_TYPE, P_LENGTH,P_ORDERING_SEQUENCE,P_DOMAIN_LOOKUP_TYPE,sysdate, 1, sysdate, 1
         from dual where not exists (SELECT 1 FROM CCT_MIDDLEWARE_PARAMS WHERE NAME=P_NAME and MIDDLEWARE_TYPE_ID = P_MIDDLEWARE_TYPE_ID);

       ELSIF (csr_chk_param_exists%FOUND) THEN
         -- Update
         Fetch csr_chk_param_exists into l_param_id;
         dbms_output.put_line('Inside seed - Upgrade needed - Need to Update, l_param_id='||l_param_id);
         update CCT_MIDDLEWARE_PARAMS
         set MIDDLEWARE_TYPE_ID =P_MIDDLEWARE_TYPE_ID,
             NAME = P_NAME,
             TYPE = P_TYPE,
             LENGTH = P_LENGTH,
             ORDERING_SEQUENCE= P_ORDERING_SEQUENCE,
             DOMAIN_LOOKUP_TYPE= P_DOMAIN_LOOKUP_TYPE,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = 1,
             LAST_UPDATE_LOGIN =1
         where middleware_param_id = l_param_id;


       END IF;
     CLOSE csr_chk_param_exists;

   END IF;
  CLOSE csr_chk_upgrade_need;
  dbms_output.put_line('Leaving seed');
EXCEPTION
  WHEN others THEN
     CLOSE csr_chk_upgrade_need;
     CLOSE csr_chk_param_exists;
	   raise_application_error(-20000, sqlerrm || '.' )  ;
END seed_param;

END CCT_MIDDLEWARE_PARAM_PKG;

/
