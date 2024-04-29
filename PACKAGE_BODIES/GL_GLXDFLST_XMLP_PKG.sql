--------------------------------------------------------
--  DDL for Package Body GL_GLXDFLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXDFLST_XMLP_PKG" AS
/* $Header: GLXDFLSTB.pls 120.0 2007/12/27 14:55:08 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
    SELECT user_definition_access_set, description
    INTO   DEFAS_NAME, DEFAS_DESCRIPTION
    FROM   gl_defas_access_sets
    WHERE  definition_access_set_id = P_DEFAS_ID;

  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
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

 Function DEFAS_NAME_p return varchar2 is
	Begin
	 return DEFAS_NAME;
	 END;
 Function DEFAS_DESCRIPTION_p return varchar2 is
	Begin
	 return DEFAS_DESCRIPTION;
	 END;
END GL_GLXDFLST_XMLP_PKG ;


/
