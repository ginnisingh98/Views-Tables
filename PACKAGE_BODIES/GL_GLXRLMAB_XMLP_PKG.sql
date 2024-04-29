--------------------------------------------------------
--  DDL for Package Body GL_GLXRLMAB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLMAB_XMLP_PKG" AS
/* $Header: GLXRLMABB.pls 120.0 2007/12/27 15:15:02 vijranga noship $ */

function BeforeReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  /*SRW.REFERENCE(P_STRUCT_NUM);*/null;


 null;
  SEL_FLEXDATA := replace(SEL_FLEXDATA, 'LEDGER_SEGMENT',
                           'NVL(GLLR.TARGET_LEDGER_SHORT_NAME, GLLED.SHORT_NAME)');


  select max(concatenated_segment_delimiter)
  into   DELIMITER
  from   FND_ID_FLEX_STRUCTURES
  where  application_id = 101
  and    id_flex_code = 'GLLE'
  and    id_flex_num = P_STRUCT_NUM;

  IF (DELIMITER IS NULL) THEN
    DELIMITER := ' ';
  END IF;

  return(TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

function C_Standard_FormulaFormula return VARCHAR2 is
begin
  RETURN('A * B/C');
end;

function account_action_codeformula(AMOUNT in number, LEDGER_ACTION_CODE in varchar2, SEGMENT_TYPES_KEY in varchar2) return char is
begin
  IF (AMOUNT IS NULL) THEN
    RETURN (LEDGER_ACTION_CODE || DELIMITER || SEGMENT_TYPES_KEY);
  END IF;

  RETURN (NULL);
end;

--Functions to refer Oracle report placeholders--

 Function SEL_FLEXDATA_p return varchar2 is
	Begin
	 return SEL_FLEXDATA;
	 END;
 Function DELIMITER_p return varchar2 is
	Begin
	 return DELIMITER;
	 END;
END GL_GLXRLMAB_XMLP_PKG ;


/
