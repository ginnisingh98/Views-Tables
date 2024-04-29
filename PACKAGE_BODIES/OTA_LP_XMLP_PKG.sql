--------------------------------------------------------
--  DDL for Package Body OTA_LP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LP_XMLP_PKG" AS
/* $Header: otalpxmlp.pkb 120.0.12010000.2 2009/09/23 09:27:52 pekasi noship $ */

FUNCTION C_LP_NAME_p RETURN varchar2 IS

  CURSOR c_lp_name_csr IS
   select name
   from ota_learning_paths_tl
   where learning_path_id = P_LP_ID
   and language = userenv('LANG');

  BEGIN
     open c_lp_name_csr;
     fetch c_lp_name_csr into C_LP_NAME;
     close c_lp_name_csr;
     return  C_LP_NAME;

END C_LP_NAME_p;

FUNCTION C_LP_STATUS_p RETURN varchar2 IS

  CURSOR c_lookup_code IS
    select es.meaning
    from hr_lookups es
    WHERE es.lookup_type = 'OTA_LP_CURRENT_STATUS'
    AND sysdate BETWEEN NVL(es.start_date_active,sysdate) AND NVL (es.end_date_active, sysdate)
    AND es.enabled_flag ='Y'
    AND es.lookup_code = P_LP_STATUS_CODE ;

  BEGIN
     open c_lookup_code;
     fetch c_lookup_code into C_LP_STATUS;
     close c_lookup_code;
     return  C_LP_STATUS;

END C_LP_STATUS_p;

FUNCTION C_LEARNER_NAME_p return varchar2 IS

  CURSOR c_learner_name_csr IS
  SELECT ppf.full_name
  FROM per_all_people_f ppf
  WHERE trunc(sysdate) BETWEEN nvl(ppf.effective_start_date, trunc(sysdate)) AND nvl(ppf.effective_end_date, trunc(sysdate))
  AND ppf.person_id = P_LEARNER_ID;

  BEGIN
     open c_learner_name_csr;
     fetch c_learner_name_csr into C_LEARNER_NAME;
     close c_learner_name_csr;
     return  C_LEARNER_NAME;

END C_LEARNER_NAME_p;

FUNCTION AfterPForm RETURN BOOLEAN IS
error_msg varchar2(4000);
BEGIN
IF ((P_LP_ID IS NULL and P_LEARNER_ID IS NULL) or (P_LP_ID IS NOT NULL and P_LEARNER_ID IS NOT NULL)) THEN

   fnd_message.set_name('OTA', 'OTA_467206_LP_REPORT_PARAM_ERR');
   error_msg   := fnd_message.get;
   RAISE_application_error(-20101, error_msg);
   RETURN(FALSE);

END IF;

RETURN(TRUE);

END;

END ota_lp_xmlp_pkg;


/
