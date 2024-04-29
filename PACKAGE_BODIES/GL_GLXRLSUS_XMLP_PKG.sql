--------------------------------------------------------
--  DDL for Package Body GL_GLXRLSUS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLSUS_XMLP_PKG" AS
/* $Header: GLXRLSUSB.pls 120.2 2008/01/07 20:09:59 vijranga noship $ */

function BeforeReport return boolean is
coa_id       NUMBER;
  led_name     VARCHAR2(30);
  func_curr    VARCHAR2(15);
  errbuf       VARCHAR2(132);
  errbuf2      VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;



  gl_info.gl_get_ledger_info(P_LEDGER_ID,
                             coa_id,
                             led_name,
                             func_curr,
                             errbuf);


  if (errbuf is not null) then
    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR',
                 'N',
                 'ROUTINE',
                 'gl_info.gl_get_ledger_info' );
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  STRUCT_NUM := coa_id;
  LEDGER_NAME := led_name;

  /*srw.reference( STRUCT_NUM );*/null;


 null;

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
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function FLEX_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL;
	 END;
END GL_GLXRLSUS_XMLP_PKG ;


/
