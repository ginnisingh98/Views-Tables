--------------------------------------------------------
--  DDL for Package Body GL_GLXRLRFL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLRFL_XMLP_PKG" AS
/* $Header: GLXRLRFLB.pls 120.0 2007/12/27 15:16:39 vijranga noship $ */

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  /*srw.reference( P_STRUCT_NUM );*/null;


 null;

  /*srw.reference( P_STRUCT_NUM );*/null;


 null;

  /*srw.reference( P_STRUCT_NUM );*/null;


 null;
  FLEX_2_SELECT_ALL_GLLE := replace(FLEX_2_SELECT_ALL_GLLE, 'LEDGER_SEGMENT',
                             'LR.TARGET_LEDGER_SHORT_NAME');

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function FLEX_1_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_1_SELECT_ALL;
	 END;
 Function FLEX_2_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_2_SELECT_ALL;
	 END;
 Function FLEX_2_SELECT_ALL_GLLE_p return varchar2 is
	Begin
	 return FLEX_2_SELECT_ALL_GLLE;
	 END;
END GL_GLXRLRFL_XMLP_PKG ;


/
