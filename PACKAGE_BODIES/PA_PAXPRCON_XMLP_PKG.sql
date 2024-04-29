--------------------------------------------------------
--  DDL for Package Body PA_PAXPRCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPRCON_XMLP_PKG" AS
/* $Header: PAXPRCONB.pls 120.0 2008/01/02 11:49:39 krreddy noship $ */
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
 init_failure 	exception;
 p_name 	VARCHAR2(30);
 p_number 	VARCHAR2(30);
 p_ptype 	VARCHAR2(20);
 p_bill_id	NUMBER;
 p_bill_name	VARCHAR2(30);
BEGIN
 IF (no_data_found_func <> TRUE) THEN
      RAISE init_failure;
 END IF;
/*srw.user_exit('FND SRWINIT');*/null;
/*IF p_mrcsobtype = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;*/
   Select Decode ( pa_install.is_billing_licensed (), 'Y','N','Y')
   Into   p_costing
   From   Dual;
/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;
SELECT name, segment1, project_type INTO p_name, p_number, p_ptype
FROM   pa_projects
WHERE  project_id = p_project_id;
c_project_name   := p_name;
c_project_number := p_number;
SELECT billing_cycle_id INTO p_bill_id FROM pa_project_types
WHERE  project_type = p_ptype ;
IF p_bill_id IS NOT NULL THEN
   SELECT billing_cycle_name INTO p_bill_name
   FROM   pa_billing_cycles
   WHERE  billing_cycle_id = p_bill_id ;
END IF;
cp_bill_name := p_bill_name ;
 IF (get_company_name <> TRUE) THEN       RAISE init_failure;
 END IF;
 IF (no_data_found_func <> TRUE) THEN
      RAISE init_failure;
 END IF;
EXCEPTION
  WHEN   OTHERS  THEN
        null;
END;  return (TRUE);
end;
FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  name
 INTO    l_name
 FROM    gl_sets_of_books
 WHERE   set_of_books_id = (SELECT set_of_books_id
			    FROM   pa_implementations_all
			    WHERE org_id = (SELECT org_id
			                    FROM pa_projects_all
					    WHERE project_id = p_project_id ));
  c_company_name_header     := l_name;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
Function NO_DATA_FOUND_FUNC RETURN BOOLEAN IS
message_name VARCHAR2(80);
BEGIN
 select
  meaning
 into
  message_name
 from
  pa_lookups
 where
    lookup_type = 'MESSAGE'
and lookup_code = 'NO_DATA_FOUND';
c_no_data_found := replace(message_name,'*','');
RETURN(TRUE);
EXCEPTION
 when others then
 RETURN(FALSE);
END;
function AfterReport return boolean is
begin
BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;
END;
  return (TRUE);
end;
function g_rev_billgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_job_bill_ratesgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_emp_bill_ratesgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_nl_bill_ratesgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_job_title_orgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_job_assgn_orgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function g_labor_multipliersgroupfilter(ptcc in varchar2) return boolean is
begin
IF (ptcc = 'CONTRACT') then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;
function G_customerGroupFilter return boolean is
begin
return (TRUE);
end;
function G_contactsGroupFilter return boolean is
begin
 return (TRUE);
end;
function g_project_assetgroupfilter(ptcc in varchar2) return boolean is
begin
if ptcc = 'CAPITAL' then
  return true;
else
  return false;
end if;  return (TRUE);
end;
function cf_baselineformula(baseline_funding_flag in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF baseline_funding_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = baseline_funding_flag ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_revaluateformula(revaluate_funding_flag in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF revaluate_funding_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = revaluate_funding_flag ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_includeformula(include_gains_losses_flag in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF include_gains_losses_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = include_gains_losses_flag ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_emp_reasonformula(emp_disc_reason in varchar2) return char is
l_reason pa_lookups.meaning%TYPE;
Begin
select meaning
  into l_reason
  from pa_lookups
 where lookup_type ='RATE AND DISCOUNT REASON'
   and lookup_code= emp_disc_reason;
return(l_reason);
EXCEPTION
when others then
l_reason:=NULL;
return(l_reason);
end;
function cf_nl_reasonformula(nl_disc_reason in varchar2) return char is
l_reason pa_lookups.meaning%TYPE;
Begin
select meaning
  into l_reason
  from pa_lookups
 where lookup_type ='RATE AND DISCOUNT REASON'
   and lookup_code= nl_disc_reason;
return(l_reason);
EXCEPTION
when others then
l_reason:=NULL;
return(l_reason);
end;
function cf_job_reasonformula(job_disc_reason in varchar2) return char is
l_reason pa_lookups.meaning%TYPE;
Begin
select meaning
  into l_reason
  from pa_lookups
 where lookup_type ='RATE AND DISCOUNT REASON'
   and lookup_code= job_disc_reason;
return(l_reason);
EXCEPTION
when others then
l_reason:=NULL;
return(l_reason);
end;
function AfterPForm return boolean is
begin
BEGIN
select decode(mrc_sob_type_code,'R','R','P')
into p_mrcsobtype
from gl_sets_of_books
where set_of_books_id = (SELECT set_of_books_id
			    FROM   pa_implementations_all
			    WHERE org_id = (SELECT org_id
			                    FROM pa_projects_all
					    WHERE project_id = p_project_id )
);
EXCEPTION
WHEN OTHERS THEN
p_mrcsobtype := 'P';
END;
IF p_mrcsobtype = 'R'
THEN
  lp_pa_events := 'PA_EVENTS_MRC_V';
ELSE
  lp_pa_events := 'PA_EVENTS';
END IF;
  return (TRUE);
end;
function cf_bill_to_customerformula(bill_to_customer_id in number) return char is
tmp_flag VARCHAR2(80);
begin
  IF bill_to_customer_id IS NOT NULL THEN
      select substr(party.party_name,1,50) into tmp_flag
      from
           hz_parties party,
           hz_cust_accounts cust_acct
      where
           party.party_id = cust_acct.party_id
       and cust_acct.cust_account_id = bill_to_customer_id;
            RETURN tmp_flag;
  ELSE
      RETURN NULL;
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
     RAISE;
end;
function cf_ship_to_customerformula(ship_to_customer_id in number) return char is
tmp_flag VARCHAR2(80);
begin
  IF ship_to_customer_id IS NOT NULL THEN
      	SELECT substrb(party.party_name,1,50) INTO tmp_flag
	FROM
	      hz_parties party,
	      hz_cust_accounts cust_acct
	WHERE
	      party.party_id = cust_acct.party_id
	  and cust_acct.cust_account_id = ship_to_customer_id;
            RETURN tmp_flag;
  ELSE
      RETURN NULL;
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
     RAISE;
end;
function cf_bill_to_cust_noformula(bill_to_customer_id in number) return char is
l_cust_no varchar2(100);begin
  IF bill_to_customer_id IS NOT NULL THEN
      	SELECT cust_acct.account_number INTO l_cust_no
	FROM
	      hz_parties party,
	      hz_cust_accounts cust_acct
	WHERE
	      party.party_id = cust_acct.party_id
	  and cust_acct.cust_account_id = bill_to_customer_id;
            RETURN l_cust_no;
  ELSE
      RETURN NULL;
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
     RAISE;
end;
function cf_ship_to_cust_noformula(ship_to_customer_id in number) return char is
l_cust_no varchar2(100);begin
  IF ship_to_customer_id IS NOT NULL THEN
      SELECT cust_acct.account_number INTO l_cust_no
      FROM
            hz_parties party,
            hz_cust_accounts cust_acct
      WHERE
            party.party_id = cust_acct.party_id
        and cust_acct.cust_account_id = ship_to_customer_id;
      RETURN l_cust_no;
  ELSE
      RETURN NULL;
  END IF;
  EXCEPTION
   WHEN OTHERS THEN
     RAISE;
end;
function cf_customerformula(enable_top_task_customer_flag in varchar2, project_id_1 in number) return char is
tmp_flag VARCHAR2(80);
begin
IF enable_top_task_customer_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_flag
        FROM pa_lookups lkp, pa_projects prj
        WHERE lkp.lookup_type = 'YES_NO'
        AND   lkp.lookup_code = prj.enable_top_task_customer_flag
       -- AND   prj.project_id = project_id;
       AND   prj.project_id = project_id_1;
	RETURN tmp_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_inv_methodformula(enable_top_task_inv_mth_flag in varchar2, project_id_1 in number) return char is
tmp_flag VARCHAR2(80);
begin
IF enable_top_task_inv_mth_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_flag
        FROM pa_lookups lkp, pa_projects prj
        WHERE lkp.lookup_type = 'YES_NO'
        AND   lkp.lookup_code = prj.enable_top_task_inv_mth_flag
       -- AND   prj.project_id = project_id;
       AND   prj.project_id = project_id_1;
	RETURN tmp_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_rev_acc_mthformula(revenue_accrual_method in varchar2, project_id_1 in number) return char is
tmp_flag VARCHAR2(80);
begin
IF revenue_accrual_method IS NOT NULL THEN
	SELECT meaning INTO tmp_flag
        FROM pa_lookups lkp, pa_projects prj
        WHERE lkp.lookup_type = 'REVENUE ACCRUAL METHOD'
        AND   lkp.lookup_code = prj.revenue_accrual_method
       -- AND   prj.project_id = project_id;
       AND   prj.project_id = project_id_1;
	RETURN tmp_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
function cf_inv_mthformula(invoice_method in varchar2, project_id_1 in number) return char is
tmp_flag VARCHAR2(80);
begin
IF invoice_method IS NOT NULL THEN
	SELECT meaning INTO tmp_flag
        FROM pa_lookups lkp, pa_projects prj
        WHERE lkp.lookup_type = 'INVOICE METHOD'
        AND   lkp.lookup_code = prj.invoice_method
       -- AND   prj.project_id = project_id;
        AND   prj.project_id = project_id_1;
	RETURN tmp_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;
--Functions to refer Oracle report placeholders--
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_project_name_p return varchar2 is
	Begin
	 return C_project_name;
	 END;
 Function C_project_number_p return varchar2 is
	Begin
	 return C_project_number;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function CP_bill_name_p return varchar2 is
	Begin
	 return CP_bill_name;
	 END;
END PA_PAXPRCON_XMLP_PKG ;


/
