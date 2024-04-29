--------------------------------------------------------
--  DDL for Package Body ZPB_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_SECURITY_CONTEXT" as
/* $Header: ZPBVCTXB.pls 120.8 2007/12/04 14:38:02 mbhat ship $ */

-- InitContext
--   This routine initializes the ZPB_CONTEXT.
--
-- Input
--   P_USER_ID:    the Apps session userId.(VARCHAR2)
--   P_SHADOW_ID:  the OLAP session userId.(VARCHAR2)
--   P_RESP_ID:    the Apps session responsibility Id.(VARCHAR2)
--   P_SESSION_ID: the Apps session Id. (VARCHAR2)
--   P_BUSINESS_AREA_ID: the EPB Business Area ID (NUMBER)
--
-- Usage Example:
--   CREATE CONTEXT ZPB_CONTEXT using ZPB_SECURITY_CONTEXT;
--   begin ZPB_SECURITY_CONTEXT.InitContext('1005262', '1005262', '1234', '5678'); end;
--

PROCEDURE INITCONTEXT(P_USER_ID          IN VARCHAR2,
                      P_SHADOW_ID        IN VARCHAR2,
                      P_RESP_ID          IN VARCHAR2,
                      P_SESSION_ID       IN VARCHAR2,
                      P_BUSINESS_AREA_ID IN NUMBER)
IS

BEGIN
   DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'user_id', P_USER_ID);
   DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'shadow_id', P_SHADOW_ID);
   DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'resp_id', P_RESP_ID);
   DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'session_id', P_SESSION_ID);
   DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'business_area_id', P_BUSINESS_AREA_ID);
END INITCONTEXT;

PROCEDURE INITOPENSQL		 (P_BUSINESS_AREA_ID IN NUMBER, P_LANG IN VARCHAR2)

IS

	l_shar_aw   varchar2(32);
	l_annot_aw  varchar2(32);
	l_zpb_pref  varchar2(8);

BEGIN

	select data_aw, annotation_aw into l_shar_aw, l_annot_aw
	from zpb_business_areas
	where business_area_id=P_BUSINESS_AREA_ID;

    DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'business_area_id', P_BUSINESS_AREA_ID);

	l_zpb_pref := zpb_aw.get_schema;
    l_zpb_pref := l_zpb_pref || '.';

dbms_aw.execute ('aw attach ' || l_zpb_pref || 'ZPBCODE');
dbms_aw.execute ('aw attach ' || l_zpb_pref || l_annot_aw);
dbms_aw.execute ('aw attach ' || l_zpb_pref || l_shar_aw);
dbms_aw.execute ('aw aliaslist ' || l_zpb_pref  || l_shar_aw  ||' alias SHARED');
dbms_aw.execute ('aw aliaslist ' || l_zpb_pref  || l_shar_aw  ||' alias S');
dbms_aw.execute ('aw aliaslist ' || l_zpb_pref  || l_shar_aw  ||' alias AGGAW');

-- if provided, limit the language dimension
if p_lang is not null then
	dbms_aw.execute ('limit ' || l_zpb_pref || l_shar_aw || '!LANG to ''' || p_lang || '''');
end if;


END INITOPENSQL;

  PROCEDURE INITEPBLANG(P_LANG_ID IN VARCHAR2)

   IS

   BEGIN
    DBMS_SESSION.SET_CONTEXT('ZPB_CONTEXT', 'user_lang', P_LANG_ID);

   end INITEPBLANG;

end ZPB_SECURITY_CONTEXT;


/
