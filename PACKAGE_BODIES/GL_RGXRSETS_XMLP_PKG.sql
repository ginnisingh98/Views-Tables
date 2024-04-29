--------------------------------------------------------
--  DDL for Package Body GL_RGXRSETS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RGXRSETS_XMLP_PKG" AS
/* $Header: RGXRSETSB.pls 120.1 2007/12/28 11:04:00 vijranga noship $ */

function print_detail (dtl_type in varchar2,
                       pset_id in number) return number is
      print_flag number;
begin
   select count(*) into print_flag
   from rg_report_parameters
   where parameter_set_id = pset_id
     and data_type = dtl_type;
   return (print_flag);
end;

function print_detail_text (pset_id in number) return number is
      print_flag number;
begin
      select count(*) into print_flag
      from rg_report_parameters
      where parameter_set_id = pset_id
        and data_type in ('B','E','C');
      return print_flag;
end;

function BeforeReport return boolean is
begin

DECLARE
   COA_ID    NUMBER;
   FUNC_CURR VARCHAR2(15);
BEGIN
    /*SRW.USER_EXIT('FND SRWINIT');*/null;


    IF P_ACCESS_SET_ID IS NULL THEN
       NULL;
    ELSE
      SELECT chart_of_accounts_id INTO COA_ID
      FROM gl_access_sets WHERE access_set_id = P_ACCESS_SET_ID;
      C_STRUCTURE_ID := COA_ID;
    END IF;

    C_ID_FLEX_CODE := 'GLLE' ;



    /*SRW.USER_EXIT('FND GETPROFILE
                    INDUSTRY :C_INDUSTRY_TYPE');*/null;


    IF ( C_INDUSTRY_TYPE = 'G' )
    THEN




       /*SRW.USER_EXIT('FND GETPROFILE
                    ATTRIBUTE_REPORTING :C_ATTRIBUTE_FLAG');*/null;




    IF ( C_ATTRIBUTE_FLAG = 'Y' )
    THEN
         C_ID_FLEX_CODE := 'GLAT' ;
    END IF;

    END IF ;

END;  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_STRUCTURE_ID_p return number is
	Begin
	 return C_STRUCTURE_ID;
	 END;
 Function C_ID_FLEX_CODE_p return varchar2 is
	Begin
	 return C_ID_FLEX_CODE;
	 END;
 Function C_INDUSTRY_TYPE_p return varchar2 is
	Begin
	 return C_INDUSTRY_TYPE;
	 END;
 Function C_ATTRIBUTE_FLAG_p return varchar2 is
	Begin
	 return C_ATTRIBUTE_FLAG;
	 END;
END GL_RGXRSETS_XMLP_PKG ;


/
