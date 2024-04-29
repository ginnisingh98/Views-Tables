--------------------------------------------------------
--  DDL for Package Body AR_ARXPOMR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXPOMR_XMLP_PKG" AS
/* $Header: ARXPOMRB.pls 120.0 2007/12/27 14:02:03 abraghun noship $ */

FUNCTION ar_meaning (po_name in varchar2,
                     po_value in varchar2)
RETURN varchar2 IS
l_meaning varchar2(80);
BEGIN

 If po_name = 'AR_CROSS_CURRENCY_RATE_TYPE' then
   begin
    SELECT user_conversion_type
     INTO   l_meaning
     FROM   GL_DAILY_CONVERSION_TYPES
     WHERE conversion_type = po_value;
    exception when others then
     null;
   end;
 elsif po_name = 'AR_SHOW_BILLING_NUMBER' then
   begin
      SELECT  meaning
       INTO l_meaning
      FROM ar_lookups
      WHERE lookup_type = 'YES/NO'
            and lookup_code = po_value;
    exception when others then
     null;
   end;
 elsif   po_name = 'AR_DOC_SEQ_GEN_LEVEL'  then
     begin
     select MEANING
     into   l_meaning
     from   AR_LOOKUPS
     where  lookup_type='DOC_SEQ_GEN_LEVEL'
           and lookup_code = po_value;
    exception when others then
     null;
   end;
elsif  po_name =   'AR_PA_CODE' then

   begin
     SELECT meaning
       INTO l_meaning
       FROM ar_lookups
        WHERE lookup_type = 'PA_CODE'
            and to_number(decode(lookup_code,'UNDEFINED','-1',lookup_code))
                 = DECODE(po_value,'UNDEFINED',-1,po_value);
  exception when others then
     null;
   end;
 null;
elsif   po_name =   'AR_ZENGIN_CHAR_SET' then
    begin
      select MEANING
       into l_meaning
       from AR_LOOKUPS
      where lookup_type = 'AR_ZENGIN_CHAR_SET'
             and lookup_code = po_value;
      exception when others then
     null;
   end;

end if;
  return l_meaning;

END;

function cf_1formula(po_name in varchar2, resposibility in varchar2) return varchar2 is
begin

  return ar_meaning(po_name,resposibility);

end;

FUNCTION p_org_po_id RETURN number IS

l_po_id number :=0;
 begin
begin
   SELECT  fpo.profile_option_id
      INTO   l_po_id
       FROM   fnd_profile_options fpo,
           fnd_profile_options_tl fpo_tl
       WHERE
        fpo.profile_option_name  = 'ORG_ID'
        AND fpo.profile_option_name = fpo_tl.profile_option_name
        AND fpo_tl.language         = USERENV('LANG');
exception
  when others then
    null;

end;
  return l_po_id;

END;

function BeforeReport return boolean is

 begin

/*srw.user_exit('FND SRWINIT');*/null;


begin
   SELECT  fpo.profile_option_id
      INTO   l_po_id
       FROM   fnd_profile_options fpo,
           fnd_profile_options_tl fpo_tl
       WHERE
        fpo.profile_option_name  = 'ORG_ID'
        AND fpo.profile_option_name = fpo_tl.profile_option_name
        AND fpo_tl.language         = USERENV('LANG');
exception
  when others then
    null;

end;
L_PO_ID_V:=L_PO_ID;
  return (TRUE);
end;

function cf_appformula(po_name in varchar2, application in varchar2) return varchar2 is
begin
   return ar_meaning(po_name,application);
end;

function cf_siteformula(po_name in varchar2, site in varchar2) return varchar2 is
begin
  return ar_meaning(po_name,site);
end;

function cf_userformula(po_name in varchar2, us in varchar2) return varchar2 is
begin
   return ar_meaning(po_name,us);
end;

FUNCTION ar_profile_user_name (po_name in varchar2)

 RETURN varchar2 IS
l_po_user_name varchar2(80);
BEGIN

  begin

     SELECT    fpo_tl.user_profile_option_name
      INTO l_po_user_name
      FROM fnd_profile_options fpo,
           fnd_profile_options_tl fpo_tl
      WHERE
        fpo.profile_option_name =po_name
      AND fpo.profile_option_name = fpo_tl.profile_option_name
      AND fpo_tl.language         = USERENV('LANG')
      ORDER BY fpo.profile_option_name;
   exception
     when others then
      null;
    end;
  return l_po_user_name;

END;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;
/*ADDED AS FIX*/
function CF_po_user_nameFormula(po_int_name in varchar2) return varchar2 is
begin
  return ar_profile_user_name(po_int_name);
end;
/* FIX ENDS*/
--Functions to refer Oracle report placeholders--

END AR_ARXPOMR_XMLP_PKG ;


/
