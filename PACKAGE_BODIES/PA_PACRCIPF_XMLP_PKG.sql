--------------------------------------------------------
--  DDL for Package Body PA_PACRCIPF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PACRCIPF_XMLP_PKG" AS
/* $Header: PACRCIPFB.pls 120.0 2008/01/02 10:58:15 krreddy noship $ */

function CF_FORMAT_MASKFormula return Char is
l_curr_code    varchar2(30);
begin






	select currency_code
	into l_curr_code
	from gl_sets_of_books
	where set_of_books_id = p_ca_set_of_books_id;

return (l_curr_code);

end;

function BeforeReport return boolean is
begin
declare
ndf varchar2(80);
BEGIN

select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  CP_NO_DATA_FOUND := ndf;








        /*srw.user_exit('FND SRWINIT');*/null;

    /*SRW.MESSAGE('100','AFTER CALLING INIT USEREXIT');*/null;


        /*srw.user_exit('FND GETPROFILE
                   NAME="PA_DEBUG_MODE"
	           FIELD=":p_debug_mode"
		   PRINT_ERROR="N"');*/null;


    /*SRW.MESSAGE('100','BEFORE SETTING ALTER SEESION');*/null;


    If p_debug_mode = 'Y' then
       /*srw.do_sql('ALTER SESSION SET SQL_TRACE TRUE');*/null;

    End If;


    /*SRW.MESSAGE('100','BEFORE GETTING COA ID');*/null;









    /*SRW.MESSAGE('100','BEFORE GETTING THE GL ACCOUNT NAMES');*/null;


 null;

    /*SRW.MESSAGE('100','BEFORE GETTING THE FROM PERIOD NAMES');*/null;




    /*SRW.MESSAGE('100','BEFORE GETTING THE TO PERIOD NAMES');*/null;




    /*SRW.MESSAGE('100','BEFORE GETTING THE PROJECT NUMBERS');*/null;

          IF p_project_id IS NOT NULL THEN
         SELECT  segment1
         INTO    p_project_number
         FROM    pa_projects_all
         WHERE   project_id=p_project_id ;
     END IF;

          IF p_project_org IS NOT NULL THEN
         SELECT name
         INTO   cp_proj_org_name
         FROM   hr_all_organization_units_tl
         WHERE  language=userenv('LANG')
         AND    organization_id=p_project_org;
    END IF;




    return (TRUE);
EXCEPTION
    WHEN   OTHERS  THEN
        /*srw.message('101','Unexpected Error '||sqlerrm);*/null;

        RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;
END;

function AfterReport return boolean is
begin
    /*srw.user_exit('FND SRWEXIT');*/null;

    return (TRUE);
end;

function AfterPForm return boolean is
begin
/*srw.user_exit('FND SRWINIT');*/null;


BEGIN
SELECT
		glb.chart_of_accounts_id
  	        ,glb.name
   	 INTO
		cp_coa_id
       		,cp_company_name
   	 FROM   gl_sets_of_books glb
   	 WHERE  glb.set_of_books_id=p_ca_set_of_books_id ;
EXCEPTION
         WHEN NO_DATA_FOUND THEN
	         	              		NULL;
     END ;

BEGIN
	     IF p_from_period IS NOT NULL THEN
		     SELECT   MIN(period_open_date)
                     INTO     cp_min_open_date
		     FROM     fa_deprn_periods
		     WHERE    period_name=p_from_period;
	     END IF;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
	         	              		NULL;
     END ;


     BEGIN
	     IF p_to_period IS NOT NULL THEN
		     SELECT   MAX(period_close_date)
                     INTO     cp_max_close_date
		     FROM     fa_deprn_periods
	             WHERE    period_name=p_to_period;
	     END IF;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
	         	              		NULL;
     END;



IF p_ca_set_of_books_id <> -1999 THEN
BEGIN



select decode(mrc_sob_type_code,'R','R','P')
into p_mrcsobtype
from gl_sets_of_books
where set_of_books_id = p_ca_set_of_books_id;
EXCEPTION
WHEN OTHERS THEN
p_mrcsobtype := 'P';
END;
ELSE
p_mrcsobtype := 'P';
END IF;



IF p_mrcsobtype = 'R'
THEN
   lp_pa_proj_asset_line := 'PA_PROJ_ASSET_LINES_MRC_V';
   lp_pa_curr_asset_cost := 'REP_CURR_CURRENT_ASSET_COST';
   c_sob_id := 'set_of_books_id = :p_ca_set_of_books_id';
ELSE
   lp_pa_proj_asset_line := 'PA_PROJECT_ASSET_LINES';
   lp_pa_curr_asset_cost := 'CURRENT_ASSET_COST';
   c_sob_id := '1 = 1';
END IF;




  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_WHERE_p return varchar2 is
	Begin
	 return C_WHERE;
	 END;
 Function CP_1_p return number is
	Begin
	 return CP_1;
	 END;
 Function CP_PROJ_ORG_NAME_p return varchar2 is
	Begin
	 return CP_PROJ_ORG_NAME;
	 END;
 Function CP_NO_DATA_FOUND_p return varchar2 is
	Begin
	 return CP_NO_DATA_FOUND;
	 END;
END PA_PACRCIPF_XMLP_PKG ;


/
