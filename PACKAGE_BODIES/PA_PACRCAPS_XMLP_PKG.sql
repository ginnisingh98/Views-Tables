--------------------------------------------------------
--  DDL for Package Body PA_PACRCAPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PACRCAPS_XMLP_PKG" AS
/* $Header: PACRCAPSB.pls 120.0 2008/01/02 10:56:33 krreddy noship $ */

function BeforeReport return boolean is
begin
    /*SRW.MESSAGE('1','THE VALUE  OF P1 IS '||P_PROJECT_TYPE);*/null;

    /*SRW.MESSAGE('1','THE VALUE  OF P2 IS '||P_PROJECT_ID);*/null;

    /*SRW.MESSAGE('1','THE VALUE  OF P3 IS '||P_PROJECT_ORG);*/null;

    /*SRW.MESSAGE('1','THE VALUE  OF P4 IS '||P_CLASS_CATEGORY);*/null;

    /*SRW.MESSAGE('1','THE VALUE  OF P5 IS '||P_CLASS_CODE);*/null;


        /*srw.user_exit('FND SRWINIT');*/null;


    /*srw.user_exit('FND GETPROFILE
                   NAME="PA_DEBUG_MODE"
                   FIELD=":p_debug_mode"
                   PRINT_ERROR="N"');*/null;



    If p_debug_mode = 'Y' then

       /*srw.do_sql('ALTER SESSION SET SQL_TRACE TRUE');null;*/
       execute immediate 'ALTER SESSION SET SQL_TRACE TRUE';

    End If;

    /*SRW.MESSAGE('1','TBOUT TO GET THE COMPANY NAME');*/null;


    SELECT  gl.name
    INTO    cp_company_name
    FROM    gl_sets_of_books gl,pa_implementations pi
    WHERE   gl.set_of_books_id = pi.set_of_books_id;

        IF p_project_id IS NOT NULL THEN
         BEGIN

             SELECT  segment1
             INTO    CP_PROJECT_NUMBER
             FROM    pa_projects_all
             WHERE   project_id=p_project_id;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  NULL;
         END;

    END IF;

         IF p_project_org IS NOT NULL THEN
         BEGIN

             SELECT  name
             INTO    CP_PROJECT_ORG
             FROM    pa_organizations_proj_all_bg_v
             WHERE   organization_id=p_project_org;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  NULL;
         END;
     END IF;

     return (TRUE);
exception
when others then
    /*SRW.MESSAGE('1','UNEXPECTED ERROR IN BEFORE REPORT');*/null;

    raise_application_error(-20101,null);/*SRW.program_abort;*/null;

end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_FORMAT_MASDFormula return Char is
tmp_fmt_mask  varchar2(15);
begin
    return(pa_multi_currency.get_acct_currency_code);

end;

--Functions to refer Oracle report placeholders--

 Function CP_project_id_p return number is
	Begin
	 return CP_project_id;
	 END;
 Function CP_COMPANY_NAME_p return varchar2 is
	Begin
	 return CP_COMPANY_NAME;
	 END;
 Function CP_PROJECT_NUMBER_p return varchar2 is
	Begin
	 return CP_PROJECT_NUMBER;
	 END;
 Function CP_PROJECT_ORG_p return varchar2 is
	Begin
	 return CP_PROJECT_ORG;
	 END;
END PA_PACRCAPS_XMLP_PKG ;


/
