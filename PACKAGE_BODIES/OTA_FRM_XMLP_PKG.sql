--------------------------------------------------------
--  DDL for Package Body OTA_FRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FRM_XMLP_PKG" AS
/* $Header: otafrmxmlp.pkb 120.2 2008/01/08 10:11:20 aabalakr noship $ */

  FUNCTION C_FORUM_NAME_p RETURN varchar2 IS
  cursor c_forum_name_csr is
   select name
   from ota_forums_tl
   where forum_id = P_FORUM_ID
   and language = userenv('LANG');
  BEGIN
     open c_forum_name_csr;
     fetch c_forum_name_csr into C_FORUM_NAME;
     close c_forum_name_csr;
     return  C_FORUM_NAME;
  END C_FORUM_NAME_p;

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

END ota_frm_xmlp_pkg;


/
