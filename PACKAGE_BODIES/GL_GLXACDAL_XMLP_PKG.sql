--------------------------------------------------------
--  DDL for Package Body GL_GLXACDAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXACDAL_XMLP_PKG" AS
/* $Header: GLXACDALB.pls 120.0 2007/12/27 14:42:19 vijranga noship $ */
function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;
  declare
    errbuf     VARCHAR2(132);
  begin
    COA_NAME := gl_flexfields_pkg.get_coa_name(P_STRUCT_NUM);
    exception
      when NO_DATA_FOUND then
        errbuf := gl_message.get_message('GL_PLL_ROUTINE_ERROR', 'N',
                   'ROUTINE','gl_flexfields_pkg.get_coa_name');
        /*srw.message('00', errbuf);*/null;
        raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
  /*srw.reference( P_STRUCT_NUM) ;*/null;
 null;
  /*srw.reference( P_STRUCT_NUM );*/null;
 null;
  /*srw.reference( P_STRUCT_NUM );*/null;
  /*srw.reference( P_FLEX_LOW );*/null;
  /*srw.reference( P_FLEX_HIGH );*/null;
 null;
  /*srw.reference( P_STRUCT_NUM );*/null;
 null;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function FLEX_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL;
	 END;
 Function FLEX_WHERE_ALL_p return varchar2 is
	Begin
	 return FLEX_WHERE_ALL;
	 END;
 Function FLEX_ORDERBY_ALL_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_ALL;
	 END;
 Function FLEX_NODATA_SELECT_BAL_p return varchar2 is
	Begin
	 return FLEX_NODATA_SELECT_BAL;
	 END;
 Function COA_NAME_p return varchar2 is
	Begin
	 return COA_NAME;
	 END;
END GL_GLXACDAL_XMLP_PKG ;



/
