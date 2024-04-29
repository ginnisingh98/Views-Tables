--------------------------------------------------------
--  DDL for Package Body OTA_CERT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CERT_XMLP_PKG" AS
/* $Header: otacertxmlp.pkb 120.1 2008/01/08 10:06:33 aabalakr noship $ */

  FUNCTION C_CERTIFICATION_NAME_p RETURN varchar2 IS
  cursor c_certification is
    select name
    from ota_certifications_tl
    where certification_id = P_CERTIFICATION_ID
    and language = userenv('LANG') ;
  BEGIN
     open c_certification;
     fetch c_certification into C_CERTIFICATION_NAME;
     close c_certification;
     return  C_CERTIFICATION_NAME;
  END C_CERTIFICATION_NAME_p;

  FUNCTION C_SUBSCRIPTION_STATUS_p RETURN varchar2 IS
  cursor c_lookup_code is
    select es.meaning
    from hr_lookups es
    WHERE es.lookup_type='OTA_CERT_ENROLL_STATUS'
    AND sysdate BETWEEN NVL(es.start_date_active,sysdate) AND NVL (es.end_date_active, sysdate)
    AND es.enabled_flag ='Y'
    AND es.lookup_code = P_SUBSCRIPTION_STATUS ;

  BEGIN
     open c_lookup_code;
     fetch c_lookup_code into C_SUBSCRIPTION_STATUS;
     close c_lookup_code;
     return  C_SUBSCRIPTION_STATUS;
  END C_SUBSCRIPTION_STATUS_p;

  Function C_SUBSCRIPTION_START_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_SUBSCRIPTION_START_DATE),1,10),'yyyy/mm/dd'))
     into C_SUBSCRIPTION_START_DATE
     from dual;
     return C_SUBSCRIPTION_START_DATE;
  END;

    Function C_SUBSCRIPTION_END_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_SUBSCRIPTION_END_DATE),1,10),'yyyy/mm/dd'))
     into C_SUBSCRIPTION_END_DATE
     from dual;
     return C_SUBSCRIPTION_END_DATE;
  END;

    Function C_EXPIRY_FROM_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_EXPIRY_FROM_DATE),1,10),'yyyy/mm/dd'))
     into C_EXPIRY_FROM_DATE
     from dual;
     return C_EXPIRY_FROM_DATE;
  END;

    Function C_EXPIRY_TO_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_EXPIRY_TO_DATE),1,10),'yyyy/mm/dd'))
     into C_EXPIRY_TO_DATE
     from dual;
     return C_EXPIRY_TO_DATE;
  END;

END ota_cert_xmlp_pkg;


/
