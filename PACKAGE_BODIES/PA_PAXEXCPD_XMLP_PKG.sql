--------------------------------------------------------
--  DDL for Package Body PA_PAXEXCPD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXEXCPD_XMLP_PKG" AS
/* $Header: PAXEXCPDB.pls 120.0 2008/01/02 11:28:33 krreddy noship $ */

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

function BeforeReport return boolean is
begin

Declare
 init_failure exception;
 ndf VARCHAR2(80);
 l_start_date DATE;
 l_end_date DATE;
BEGIN
/*srw.user_exit('FND SRWINIT');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;


select nvl(paimp.org_id,-99) into org_id1 from pa_implementations paimp;


select nvl(fnd_profile.value_specific('PA_EN_NEW_GLDATE_DERIVATION'),'N') into pa_new_gl_date from dual;












  IF (get_ou_name <> TRUE) THEN
     RAISE init_failure;
  END IF;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;


if (calling_mode = 'PA') then

   SELECT START_DATE
   INTO START_DATE
   FROM PA_PERIODS
   WHERE PERIOD_NAME= START_PERIOD;

   SELECT END_DATE
   INTO END_DATE
   FROM PA_PERIODS
   WHERE PERIOD_NAME= END_PERIOD;

elsif (calling_mode = 'GL') then

   SELECT START_DATE
   INTO START_DATE
   FROM GL_PERIOD_STATUSES gps, PA_IMPLEMENTATIONS imp
   WHERE gps.PERIOD_NAME= START_PERIOD
   AND gps.APPLICATION_ID = 8721
   AND gps.SET_OF_BOOKS_ID = imp.set_of_books_id;

   SELECT END_DATE
   INTO END_DATE
   FROM GL_PERIOD_STATUSES gps, PA_IMPLEMENTATIONS imp
   WHERE gps.PERIOD_NAME= END_PERIOD
   AND gps.APPLICATION_ID = 8721
   AND gps.SET_OF_BOOKS_ID = imp.set_of_books_id;


end if;

fnd_client_info.set_currency_context(org_id1);

EXCEPTION
  WHEN  NO_DATA_FOUND THEN
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

 EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_exception_type  RETURN BOOLEAN IS

BEGIN

  IF exception_type IS NOT NULL
     AND NOT (exception_type = 'AP INVOICES' OR
            exception_type = 'COSTING' OR
            exception_type = 'DRAFT REVENUES') THEN
     RETURN FALSE;
  ELSE
     RETURN TRUE;
  END IF;

 EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END ;

function CF_acct_curr_codeFormula return VARCHAR2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

function AfterReport return boolean is
begin


  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

FUNCTION get_ou_name RETURN boolean IS

  v_ou_name  hr_organization_units.name%type;

BEGIN

	select hr.name
	into v_ou_name
	from hr_all_organization_units_tl hr,
	     pa_implementations pi
	where hr.organization_id(+) = pi.org_id
 	and decode(hr.organization_id,null,'1',hr.language)=
     	    decode(hr.organization_id,null,'1',userenv('lang')) ;

	cp_ou_name := v_ou_name;
        return (true);

EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function cf_inv_ou_nameformula(inv_org_id in number) return char is
begin
     IF  nvl(inv_org_id ,-99)  <>  -99 then
         return (pa_expenditures_utils.getorgtlname(inv_org_id));
      Else
          return get_ou_name1;
      End if;
end;

function cf_cst_ou_nameformula(cst_org_id in number) return char is
begin
   IF  nvl(cst_org_id ,-99)  <>  -99 then
         return pa_expenditures_utils.getorgtlname(cst_org_id);
   Else
         return  get_ou_name1;
   End if;


end;

function cf_mfg_ou_nameformula(org_id_pmg in number) return char is
begin
  	IF nvl(org_id_pmg ,-99) <>  -99 then
            return pa_expenditures_utils.getorgtlname(org_id_pmg);
 	Else
 	    return  get_ou_name1;
        End if;

end;

function cf_rev_ou_nameformula(rev_org_id in number) return char is
begin
      IF  nvl(rev_org_id ,-99)  <>  -99 then
           return  pa_expenditures_utils.getorgtlname(rev_org_id);
      Else
           return get_ou_name1;
      End if;

end;

function cf_cc_ou_nameformula(cc_org_id in number) return char is
begin
 	If nvl(cc_org_id ,-99)  <>  -99 then
           return  pa_expenditures_utils.getorgtlname(cc_org_id);
        Else
           return get_ou_name1;
        End if;

end;

function cf_mrc_ou_nameformula(mrc_org_id in number) return char is
begin
 	If nvl(mrc_org_id ,-99)  <>  -99 then
            return pa_expenditures_utils.getorgtlname(mrc_org_id);
        Else
            return get_ou_name1;
        End if;

end;

FUNCTION get_ou_name1 RETURN varchar2 IS

  v_ou_name  hr_organization_units.name%type;

BEGIN

	select hr.name
	into v_ou_name
	from hr_all_organization_units_tl hr,
	     pa_implementations pi
	where hr.organization_id(+) = pi.org_id
 	and decode(hr.organization_id,null,'1',hr.language)=
     	    decode(hr.organization_id,null,'1',userenv('lang')) ;
        return (v_ou_name);

EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (null);

END;

function cf_uncst_sob_nameformula(uncst_sob in number) return char is

	v_name   varchar2(60);
begin
       If  uncst_sob is not null then
             select gl.name
             into  v_name
             from  gl_sets_of_books gl
             where  gl.set_of_books_id  = uncst_sob;
       End if;

       return v_name;

exception

     when others then
          return null;


end;

function cf_rec_book_nameformula(receipt_books in number) return char is
	v_name   varchar2(60);
begin
       If  receipt_books is not null then
             select gl.name
             into  v_name
             from  gl_sets_of_books gl
             where  gl.set_of_books_id  = receipt_books;
       End if;

       return v_name;

exception

     when others then
          return null;

end;

function cf_project_numformula(project_id in number) return varchar2 is
l_project_number varchar2(50);
begin
   pa_utils3.GetCachedProjNum(project_id,l_project_number);
   return l_project_number;
 end;

function cf_task_numformula(task_id in number) return varchar2 is
l_task_number varchar2(50);
begin
 pa_utils3.GetCachedTaskNum(task_id,l_task_number);
 return l_task_number;
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_dummy_data_p return number is
	Begin
	 return C_dummy_data;
	 END;
 Function CP_OU_Name_p return varchar2 is
	Begin
	 return CP_OU_Name;
	 END;
END PA_PAXEXCPD_XMLP_PKG ;


/
