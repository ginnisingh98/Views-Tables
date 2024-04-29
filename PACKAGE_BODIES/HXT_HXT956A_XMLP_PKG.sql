--------------------------------------------------------
--  DDL for Package Body HXT_HXT956A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT956A_XMLP_PKG" AS
/* $Header: HXT956AB.pls 120.0 2007/12/03 10:59:37 amakrish noship $ */

function cf_pep_nameformula(pep_id in number) return varchar2 is
   pep_name VARCHAR2(80);
begin

  select name
  into pep_name
  from  hxt_prem_eligblty_policies
  where id = pep_id;

return (pep_name);

RETURN NULL; exception when no_data_found then return (null);
end;

function cf_pip_nameformula(pip_id in number) return varchar2 is
   pip_name VARCHAR2(80);
begin

  select name
  into pip_name
  from  hxt_prem_interact_policies
  where id = pip_id;

return (pip_name);

RETURN NULL; exception when no_data_found then return (null);
end;

function cf_egt_nameformula(egt_id in number) return varchar2 is
   egt_type VARCHAR2(80);
begin

  select name
  into egt_type
  from  hxt_earn_group_types
  where id = egt_id;

return (egt_type);

RETURN NULL; exception when no_data_found then return (null);
end;

function earn_typeformula(arg_ELEMENT_TYPE_ID in number, arg_EFFECTIVE_START_DATE in date, arg_EFFECTIVE_END_DATE in date) return varchar2 is
   EARN_TYPE   VARCHAR2(240);
BEGIN
   earn_type := ' ';
DECLARE
      CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT
            ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV
      WHERE  ELT.ELEMENT_TYPE_ID = arg_ELEMENT_TYPE_ID
      AND    ELTT.ELEMENT_TYPE_ID = ELT.ELEMENT_TYPE_ID
      AND    ELTV.ELEMENT_TYPE_ID = ELT.ELEMENT_TYPE_ID
      AND elt.effective_start_date <= arg_EFFECTIVE_START_DATE
      and elt.effective_end_date >= arg_EFFECTIVE_END_DATE
      AND eltt.language = userenv('LANG')
      AND     HXT_EARNING_CATEGORY IN ('OVT', 'REG');
  BEGIN
    earn_type := ' ';
    IF arg_ELEMENT_TYPE_ID IS NULL THEN
       EARN_TYPE := ' ';
    ELSE
    OPEN C;
    FETCH C
    INTO   EARN_TYPE;
      IF C%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
      END IF;
    CLOSE C;
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND
       THEN EARN_TYPE := ' ';
    when others
       then /*srw.message(01,'Error -Earn Type '||earn_type);*/null;

  END;

  RETURN EARN_TYPE;

end;

function BeforePForm return boolean is
begin
   /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT956A_XMLP_PKG ;

/
