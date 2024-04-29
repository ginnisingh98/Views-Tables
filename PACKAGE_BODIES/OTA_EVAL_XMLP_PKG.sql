--------------------------------------------------------
--  DDL for Package Body OTA_EVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVAL_XMLP_PKG" AS
/* $Header: otaevalxmlp.pkb 120.2 2008/01/08 10:14:06 aabalakr noship $ */

  FUNCTION C_ACTIVITY_VERSION_NAME_p RETURN varchar2 IS
  cursor c_activity_version is
   select version_name
   from ota_activity_versions_tl
   where activity_version_id = P_ACTIVITY_ID
   and language = userenv('LANG');
  BEGIN
   if P_ACTIVITY_ID is not null then
     open c_activity_version;
     fetch c_activity_version into c_activity_version_name;
     close c_activity_version;
   end if;
   return  c_activity_version_name;
  END C_ACTIVITY_VERSION_NAME_p;

  FUNCTION C_EVENT_TITLE_p RETURN varchar2 IS
  cursor c_event is
    select title
    from ota_events_tl
    where event_id = P_EVENT_ID
    and language = userenv('LANG') ;
  BEGIN
     open c_event;
     fetch c_event into c_event_title;
     close c_event;
     return  c_event_title;
  END C_EVENT_TITLE_p;

  FUNCTION C_ANSWER_TYPE_p RETURN varchar2 IS
  cursor c_lookup_code is
    select es.meaning
    from hr_lookups es
    WHERE es.lookup_type='OTA_EVAL_REPORT_TYPE'
    AND sysdate BETWEEN NVL(es.start_date_active,sysdate) AND NVL (es.end_date_active, sysdate)
    AND es.enabled_flag ='Y'
    AND es.lookup_code = P_ANSWER_TYPE ;

  BEGIN
     open c_lookup_code;
     fetch c_lookup_code into C_ANSWER_TYPE;
     close c_lookup_code;
     return  C_ANSWER_TYPE;
  END C_ANSWER_TYPE_p;

  Function C_FROM_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_FROM_DATE),1,10),'yyyy/mm/dd'))
     into C_FROM_DATE
     from dual;
     return C_FROM_DATE;
  END;

  Function C_TO_DATE_p return varchar2 is
  Begin
     select fnd_date.date_to_displaydate(to_date(substr((P_TO_DATE),1,10),'yyyy/mm/dd'))
     into C_TO_DATE
     from dual;
     return C_TO_DATE;
  END;


END ota_eval_xmlp_pkg;


/
