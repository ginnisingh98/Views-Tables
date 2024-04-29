--------------------------------------------------------
--  DDL for Package Body HXT_HXT956D_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT956D_XMLP_PKG" AS
/* $Header: HXT956DB.pls 120.0 2007/12/03 11:09:35 amakrish noship $ */

function bhtformula(ELT_BASE_ID in number, arg_effective_start_date in date, arg_effective_end_date in date) return varchar2 is
   bht   VARCHAR2(240);
begin
   bht := ' ';
DECLARE
    CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT
            ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV
      WHERE  ELTV.ELEMENT_TYPE_ID = ELT_BASE_ID
      AND    ELTV.EFFECTIVE_START_DATE <= arg_effective_start_date
      AND    ELTV.EFFECTIVE_END_DATE >= arg_effective_end_date
      AND    ELTV.ELEMENT_TYPE_ID = ELT.ELEMENT_TYPE_ID
      AND    ELT.EFFECTIVE_START_DATE <= arg_effective_start_date
      AND    ELT.EFFECTIVE_END_DATE >= arg_effective_end_date
      AND    ELT.element_type_id = eltv.element_type_id
      AND    ELTT.element_type_id = elt.element_type_id
      AND    ELTT.language = userenv('LANG')
      AND    ELTV.HXT_EARNING_CATEGORY IN ('REG', 'OVT', 'ABS');
   BEGIN
    if elt_base_id is not NULL then
    OPEN C;
    FETCH C
    INTO   bht;
    IF C%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
    end if;
  EXCEPTION
    when no_data_found then
      bht := ' ';
    WHEN OTHERS THEN
      /*srw.message(01,'Error  '||bht);*/null;

  END;
   return bht;
end;

function premformula(ELT_PREMIUM_ID in number) return varchar2 is
  prem   VARCHAR2(80);
begin
  prem := ' ';
 DECLARE
    CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT1
            ,pay_element_types_f_tl eltt
      WHERE  ELT1.ELEMENT_TYPE_ID = ELT_PREMIUM_ID
      AND    ELT1.element_type_id = eltt.element_type_id
      AND    eltt.language  = userenv('LANG');
  BEGIN
    if elt_premium_id is not null then
    OPEN C;
    FETCH C
    INTO   prem;
    IF C%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE C;
    end if;
  EXCEPTION
    when no_data_found then
      prem := ' ';
    WHEN OTHERS THEN
      /*srw.message(01,'Error  '||prem);*/null;

  END;




  return prem;
end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END HXT_HXT956D_XMLP_PKG ;

/
