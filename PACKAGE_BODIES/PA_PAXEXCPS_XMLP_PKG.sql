--------------------------------------------------------
--  DDL for Package Body PA_PAXEXCPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXEXCPS_XMLP_PKG" AS
/* $Header: PAXEXCPSB.pls 120.0 2008/01/02 11:29:17 krreddy noship $ */

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

 EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


Declare
 init_failure exception;
 ndf VARCHAR2(80);
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


/*srw.user_exit('FND GETPROFILE
NAME="CURRENCY:MIXED_PRECISION"
FIELD=":p_min_precision"
PRINT_ERROR="N"');*/null;


select nvl(paimp.org_id,-99) into org_id1  from pa_implementations paimp;









    IF (get_company_name <> TRUE or get_ou_name <>true) THEN       RAISE init_failure;
  END IF;
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;


if (calling_mode = 'PA') then

   SELECT START_DATE
   INTO START_DATE
   FROM PA_PERIODS
   WHERE PERIOD_NAME= PA_PAXEXCPS_XMLP_PKG.START_PERIOD;

   SELECT END_DATE
   INTO END_DATE
   FROM PA_PERIODS
   WHERE PERIOD_NAME= PA_PAXEXCPS_XMLP_PKG.END_PERIOD;

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


EXCEPTION
  WHEN  NO_DATA_FOUND THEN
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;


END;
   return (TRUE);
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

function CF_ACCT_CURR_CODEFormula return VARCHAR2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
   return 'USD';
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

FUNCTION get_ou_name RETURN boolean IS




v_ou_name hr_all_organization_units_tl.name%type;

BEGIN
select substr(hr.name,1,60)
into v_ou_name
from hr_all_organization_units_tl hr, pa_implementations pi
where hr.organization_id(+) = pi.org_id and
      decode(hr.organization_id,null,'1',hr.language)=
      decode(hr.organization_id,null,'1',userenv('lang'));



cp_ou_name := v_ou_name;
return(true);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function cf_cost_ou_nameformula(org_id in number) return char is
begin
      If org_id is not null then
	  return (substr(PA_EXPENDITURES_UTILS.getorgtlname(org_id),1,60));
      Else
          return null;
      End if;

end;

function cf_inv_ou_nameformula(inv_org_id in number) return char is
begin


   If nvl(inv_org_id,-99) <> -99 Then
       return (substr(pa_expenditures_utils.getorgtlname(inv_org_id),1,60));
   Else
     	return cp_ou_name;
   End if;
end;

function cf_rev_ou_nameformula(rev_org_id in number) return char is
begin
      If rev_org_id is not null then
	  return (substr(PA_EXPENDITURES_UTILS.getorgtlname(rev_org_id),1,60));
      Else
          return null;
      End if;
end;

function cf_cc_ou_nameformula(cc_org_id in number) return char is
begin
      If cc_org_id is not null then
	  return (substr(PA_EXPENDITURES_UTILS.getorgtlname(cc_org_id),1,60));
      Else
          return null;
      End if;

end;

function cf_mfg_ou_nameformula(mfg_org_id in number) return char is
begin
  If mfg_org_id is NOT NULL then
      return  (substr(pa_expenditures_utils.getorgtlname(mfg_org_id),1,60));
   Else
      return  null;
   End if;
end;

function cf_uncst_ou_nameformula(uncst_org_id in number) return char is
begin
   If nvl(uncst_org_id , -99)  <>  -99 then
       return (substr(pa_expenditures_utils.getorgtlname(uncst_org_id),1,60));
    else
        return cp_ou_name;
    End if;

end;

function cf_uncst_sob_nameformula(uncst_sob in number) return char is
     l_name   varchar2(50);
begin

     select gl.name
     into l_name
     from  gl_sets_of_books  gl
     where  gl.set_of_books_id  = uncst_sob;

     return l_name;
exception
     when no_data_found then
       return null;

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
 Function CP_ou_name_p return varchar2 is
	Begin
	 return CP_ou_name;
	 END;
END PA_PAXEXCPS_XMLP_PKG ;


/
