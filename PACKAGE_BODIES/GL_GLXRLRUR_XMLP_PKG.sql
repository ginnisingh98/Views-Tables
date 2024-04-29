--------------------------------------------------------
--  DDL for Package Body GL_GLXRLRUR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLRUR_XMLP_PKG" AS
/* $Header: GLXRLRURB.pls 120.0 2007/12/27 15:17:52 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
    COA_NAME := gl_flexfields_pkg.get_coa_name(P_STRUCT_NUM);

  exception
    when NO_DATA_FOUND then
      errbuf := gl_message.get_message('GL_PLL_ROUTINE_ERROR', 'N',
                   'ROUTINE','gl_flexfields_pkg.get_coa_name');
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function COA_NAME_p return varchar2 is
	Begin
	 return COA_NAME;
	 END;
END GL_GLXRLRUR_XMLP_PKG ;


/
