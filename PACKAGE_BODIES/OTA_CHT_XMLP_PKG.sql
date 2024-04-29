--------------------------------------------------------
--  DDL for Package Body OTA_CHT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_CHT_XMLP_PKG" AS
/* $Header: otachttxmlp.pkb 120.1 2008/01/08 10:13:02 aabalakr noship $ */

  FUNCTION C_CHAT_NAME_p RETURN varchar2 IS
  cursor c_chat_name_csr is
   select name
   from ota_chats_tl
   where chat_id = P_CHAT_ID
   and language = userenv('LANG');
  BEGIN
     open c_chat_name_csr;
     fetch c_chat_name_csr into C_CHAT_NAME;
     close c_chat_name_csr;
     return  C_CHAT_NAME;
  END C_CHAT_NAME_p;

  FUNCTION C_CHAT_CONTENT_TYPE_p RETURN varchar2 IS
  cursor c_lookup_code is
    select es.meaning
    from hr_lookups es
    WHERE es.lookup_type='OTA_CHAT_REPORT_TYPES'
    AND sysdate BETWEEN NVL(es.start_date_active,sysdate) AND NVL (es.end_date_active, sysdate)
    AND es.enabled_flag ='Y'
    AND es.lookup_code = P_TYPE ;

  BEGIN
     open c_lookup_code;
     fetch c_lookup_code into C_CHAT_CONTENT_TYPE;
     close c_lookup_code;
     return  C_CHAT_CONTENT_TYPE;
  END C_CHAT_CONTENT_TYPE_p;

  Function C_FROM_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_MESSAGE_START_DATE),1,10),'yyyy/mm/dd'))
     into C_FROM_DATE
     from dual;
     return C_FROM_DATE;
  END;

  Function C_TO_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_MESSAGE_END_DATE),1,10),'yyyy/mm/dd'))
     into C_TO_DATE
     from dual;
     return C_TO_DATE;
  END;



END ota_cht_xmlp_pkg;


/
