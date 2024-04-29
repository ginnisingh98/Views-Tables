--------------------------------------------------------
--  DDL for Package Body HXT_HXT956C_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_HXT956C_XMLP_PKG" AS
/* $Header: HXT956CB.pls 120.0 2007/12/03 11:07:08 amakrish noship $ */

function earn_typeformula(arg_ELEMENT_TYPE_ID in number, arg_EFFECTIVE_START_DATE in date, arg_EFFECTIVE_END_DATE in date) return varchar2 is
   EARN_TYPE   VARCHAR2(80);
BEGIN
   earn_type := ' ';
DECLARE
      CURSOR C IS
      SELECT ELTT.ELEMENT_NAME
      FROM   PAY_ELEMENT_TYPES_F ELT
	    ,PAY_ELEMENT_TYPES_F_TL ELTT
            ,HXT_PAY_ELEMENT_TYPES_F_DDF_V ELTV
      WHERE  ELT.ELEMENT_TYPE_ID = arg_ELEMENT_TYPE_ID
      AND elt.effective_start_date <= arg_EFFECTIVE_START_DATE
      and elt.effective_end_date >= arg_EFFECTIVE_END_DATE
      AND    HXT_EARNING_CATEGORY = 'SDF'
      AND    ELT.element_type_id = eltt.element_type_id
      AND    ELTV.element_type_id = elt.element_type_id
      and    eltt.language = userenv('LANG');
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

END HXT_HXT956C_XMLP_PKG ;

/
