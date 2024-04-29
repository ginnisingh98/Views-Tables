--------------------------------------------------------
--  DDL for Package Body GL_GLXDFUSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXDFUSR_XMLP_PKG" AS
/* $Header: GLXDFUSRB.pls 120.0 2007/12/27 14:57:00 vijranga noship $ */

function BeforeReport return boolean is
desc_col    VARCHAR2(30);
  errbuf      VARCHAR2(132);
begin
  /*srw.user_exit('FND SRWINIT');*/null;


  begin
    SELECT display_name
    INTO   DEFINITION_TYPE
    FROM   fnd_objects_vl
    WHERE  obj_name = P_DEFINITION_TYPE;

    gl_defas_access_details_pkg.get_query_component(
        P_DEFINITION_TYPE,
        ID_COLUMNS,
        NAME_COLUMN,
        desc_col,
        WHERE_DEFAS,
        TABLE_NAME);

  exception
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  NAME_COLUMN := 'DEF.'||NAME_COLUMN;
  ID_COLUMN1 := '-1';

  IF (LENGTH(ID_COLUMNS) <> 0 AND INSTR(ID_COLUMNS, ',', 1, 1) = 0) THEN
    IF(INSTR(LOWER(ID_COLUMNS), 'to_char', 1, 1) = 0) THEN
      ID_COLUMNS := REPLACE(ID_COLUMNS,' ');
      ID_COLUMN1 := 'DEF.' ||ID_COLUMNS;
    ELSE
      ID_COLUMNS := REPLACE(ID_COLUMNS,' ');
      ID_COLUMN1 := REPLACE(ID_COLUMNS,'to_char(', 'to_char(DEF.');
    END IF;
  END IF;
  ROW_COUNT := 0;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

PROCEDURE GL_INCREMENT_COUNT IS
BEGIN
  ROW_COUNT := ROW_COUNT + 1;
END;

--Functions to refer Oracle report placeholders--

 Function ID_COLUMNS_p return varchar2 is
	Begin
	 return ID_COLUMNS;
	 END;
 Function NAME_COLUMN_p return varchar2 is
	Begin
	 return NAME_COLUMN;
	 END;
 Function TABLE_NAME_p return varchar2 is
	Begin
	 return TABLE_NAME;
	 END;
 Function WHERE_DEFAS_p return varchar2 is
	Begin
	 return WHERE_DEFAS;
	 END;
 Function DEFINITION_TYPE_p return varchar2 is
	Begin
	 return DEFINITION_TYPE;
	 END;
 Function ROW_COUNT_p return number is
	Begin
	 return ROW_COUNT;
	 END;
 Function ID_COLUMN1_p return varchar2 is
	Begin
	 return ID_COLUMN1;
	 END;
END GL_GLXDFUSR_XMLP_PKG ;


/
