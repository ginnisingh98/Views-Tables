--------------------------------------------------------
--  DDL for Package Body PA_PAXEXONE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXEXONE_XMLP_PKG" AS
/* $Header: PAXEXONEB.pls 120.0 2008/01/02 11:30:05 krreddy noship $ */

FUNCTION  get_cover_page_values RETURN BOOLEAN IS

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
 hold_employee_name  VARCHAR2(80);
 org_name hr_organization_units.name%TYPE;

BEGIN



/*srw.user_exit('FND SRWINIT');*/null;

/*srw.message(1,'Expense Report Testing on dom1151');*/null;

IF p_mrcsobtype = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;







/*srw.message(1,'this is ur report');*/null;

/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;






IF incurred_org is not null then
   select substr(name,1,30)
   into org_name from
   hr_organization_units
   where organization_id = incurred_org;
END IF;
c_incurred_org := org_name;



IF employee_id is not null
  THEN
    select SUBSTR(full_name,1,80)
    into   hold_employee_name
    from   per_people_f
    where  person_id = employee_id
    and   sysdate between effective_start_date
					 and  nvl(effective_end_date,sysdate + 1)
    and   (employee_number IS NOT NULL or npw_number IS NOT NULL);
    c_employee_name := hold_employee_name;
END IF;


IF (get_company_name <> TRUE) THEN       RAISE init_failure;
END IF;

EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                gl_sets_of_books.name%TYPE;

BEGIN

  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl
  WHERE   gl.set_of_books_id = p_ca_set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function c_billable_expensesformula(c_total_expenses in number, c_total_billable_expenses in number) return number is
  temp_value  number;
begin
  if c_total_expenses <> 0 then
    temp_value := round((nvl(c_total_billable_expenses,0)/c_total_expenses),4) * 100;
  else
    temp_value :=  0;
  end if;
  return(temp_value);
end;

function AfterReport return boolean is
begin

	BEGIN
 		/*srw.user_exit('FND SRWEXIT');*/null;

	END;

	return (TRUE);

end;

function c_display_total_bill_expformul(c_total_billable_expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(c_total_billable_expenses);*/null;

RETURN
  (TO_CHAR(c_total_billable_expenses, pa_currency.currency_fmt_mask(12)));
end;

function c_display_total_expformula(c_total_expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(c_total_expenses);*/null;

RETURN
  (TO_CHAR(c_total_expenses, pa_currency.currency_fmt_mask(12)));
end;

function c_display_bill_expformula(c_billable_expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(c_billable_expenses);*/null;

RETURN
  (to_char(c_billable_expenses));
  end;

function c_expensesformula(expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(expenses);*/null;

RETURN
  (TO_CHAR(expenses, pa_currency.currency_fmt_mask(12)));
end;

function c_billable_expformula(billable_expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(billable_expenses);*/null;

RETURN
  (TO_CHAR(billable_expenses, pa_currency.currency_fmt_mask(10)));
end;

function c_disp_rep_expensesformula(c_rep_expenses in number) return varchar2 is
begin

/*SRW.REFERENCE(c_rep_expenses);*/null;

RETURN
  (TO_CHAR(c_rep_expenses, pa_currency.currency_fmt_mask(12)));
end;

function c_amountformula(amount in number) return char is
begin
  /*srw.reference(amount);*/null;

  return(to_char(amount,pa_currency.currency_fmt_mask(12)));
end;

function c_amount1formula(sse_amount in number) return char is
begin
  /*srw.reference(sse_amount);*/null;

  return(to_char(sse_amount,pa_currency.currency_fmt_mask(12)));
end;

function c_dis_sum_invoiceformula(c_sum_invoice in number) return char is
begin
  /*srw.reference(c_sum_invoice);*/null;

  return(to_char(c_sum_invoice,pa_currency.currency_fmt_mask(12)));
end;

function c_disp_sum_sseformula(c_sum_sse in number) return char is
begin
  /*srw.reference(c_sum_sse);*/null;

  return(to_char(c_sum_sse,pa_currency.currency_fmt_mask(12)));
end;

function c_dis_sum_invoice1formula(c_sum_invoice1 in number) return char is
begin
   /*srw.reference(c_sum_invoice1);*/null;

  return(to_char(c_sum_invoice1,pa_currency.currency_fmt_mask(12)));
end;

function c_disp_sum_sse1formula(c_sum_sse1 in number) return char is
begin
 /*srw.reference(c_sum_sse1);*/null;

  return(to_char(c_sum_sse1,pa_currency.currency_fmt_mask(12)));
end;

function c_bill_pctformula(c_sum_invoice in number, c_sum_invoice1 in number) return char is

  temp_value  number;
begin
  if c_sum_invoice <> 0 then
    temp_value := round((nvl(c_sum_invoice,0)/c_sum_invoice1),4) * 100;
  else
    temp_value :=  0;
  end if;
  return(temp_value);
end;

function AfterPForm return boolean is
begin



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

                  lp_pa_ei_denorm_v := 'PA_EI_DENORM_MRC_V';
  lp_ap_invoice_dist := 'AP_INVOICE_DISTS_MRC_V';
ELSE
                  lp_pa_ei_denorm_v := 'PA_EI_DENORM_V';
  lp_ap_invoice_dist := 'AP_INVOICE_DISTRIBUTIONS';
END IF;





  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_employee_name_p return varchar2 is
	Begin
	 return C_employee_name;
	 END;
 Function c_no_data_found_p return varchar2 is
	Begin
	 return c_no_data_found;
	 END;
 Function c_incurred_org_p return varchar2 is
	Begin
	 return c_incurred_org;
	 END;
END PA_PAXEXONE_XMLP_PKG ;


/
