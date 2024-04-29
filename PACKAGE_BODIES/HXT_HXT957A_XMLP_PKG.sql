--------------------------------------------------------
--  DDL for Package Body HXT_HXT957A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT957A_XMLP_PKG" AS
/* $Header: HXT957AB.pls 120.1 2008/04/03 07:38:17 amakrish noship $ */

function ORG_NAMEFormula(ORGANIZATION_ID1 in number) return VARCHAR2 is
      ORG_NAME   VARCHAR2(60);
begin
  ORG_NAME := '';
  SELECT HR_ALL_ORGANIZATION_UNITS_TL.NAME INTO
  ORG_NAME FROM HR_ALL_ORGANIZATION_UNITS_TL WHERE
   (HR_ALL_ORGANIZATION_UNITS_TL.ORGANIZATION_ID=ORGANIZATION_ID1)
   AND HR_ALL_ORGANIZATION_UNITS_TL.language = userenv('LANG');
  RETURN ORG_NAME;
RETURN NULL; EXCEPTION
 when NO_DATA_FOUND then
    org_name := '';

RETURN NULL; end;

function earn_typeformula(P_ELEMENT_TYPE_ID in number, P_EFFECTIVE_START_DATE in date, P_EFFECTIVE_END_DATE in date) return varchar2 is
     EARN_TYPE VARCHAR2(80);
begin
     earn_type := ' ';
DECLARE
      CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT
            ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV
      WHERE  ELT.ELEMENT_TYPE_ID = P_ELEMENT_TYPE_ID
      AND elt.effective_start_date <= P_EFFECTIVE_START_DATE
      and elt.effective_end_date >= P_EFFECTIVE_END_DATE
      AND eltv.effective_start_date <= P_EFFECTIVE_START_DATE
      and eltv.effective_end_date >= P_EFFECTIVE_END_DATE
      and eltt.element_type_id = elt.element_type_id
      and eltv.element_type_id = elt.element_type_id
      and eltt.language = userenv('LANG')
      AND     HXT_EARNING_CATEGORY = 'ABS';
  BEGIN
    earn_type := ' ';
    IF P_ELEMENT_TYPE_ID IS NULL THEN
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

function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;

  if start_date is null then
     start_date := hr_general.start_of_time;
  end if;
  if end_date is null then
     end_date := hr_general.end_of_time;
  end if;
  AP_START_DATE:=to_char(start_date,'DD-MON-YYYY');
  AP_END_DATE:=to_char(end_date,'DD-MON-YYYY');
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT957A_XMLP_PKG ;

/
