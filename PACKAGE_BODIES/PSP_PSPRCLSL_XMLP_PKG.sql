--------------------------------------------------------
--  DDL for Package Body PSP_PSPRCLSL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPRCLSL_XMLP_PKG" AS
/* $Header: PSPRCLSLB.pls 120.4 2007/10/29 07:27:12 amakrish noship $ */

function cf_assignment_numberformula(assignment_id_1 in number) return varchar2 is
  x_assignment_number	VARCHAR2(30);
begin



	  select assignment_number
	  into x_assignment_number
	  from per_assignments_f
	  where assignment_id = assignment_id_1
	  AND	assignment_type ='E'		  and rownum < 2 ;  	  	  	  return(x_assignment_number);


RETURN NULL; exception
  when no_data_found then
  return('no_data_found');
  when too_many_rows then
  return('too many rows');
  when others then
  return('error');
end;

function CF_element_nameFormula return VARCHAR2 is
begin
return(null);
end;

function cf_person_nameformula(person_id_1 in number) return varchar2 is
  x_person_name		VARCHAR2(240);
  x_end_date		DATE;
begin
  select end_date into x_end_date
  from per_time_periods
  where time_period_id = p_time_period_id;

  select full_name into x_person_name
  from per_people_f
  where person_id = person_id_1
  and x_end_date BETWEEN effective_start_date and effective_end_date;

  return(x_person_name);
RETURN NULL; exception
  when no_data_found then
  return('no data found');
  when too_many_rows then
  return('too many rows');
end;

function cf_amt_sl_dformula(person_id_1 in number, assignment_id_1 in number, element_type_id_1 in number, currency_code_1 in varchar2) return number is
       v_debit_amount_sl  NUMBER; begin



	SELECT 	sum(decode(ppl.dr_cr_flag, 'C',ppsl.pay_amount,0)) sl_Credit_Amount,
		sum(decode(ppl.dr_cr_flag, 'D',ppsl.pay_amount,0)) sl_Debit_Amount
	INTO	cp_credit_amount_sl,
		v_debit_amount_sl
	FROM 	psp_payroll_lines ppl,
		psp_payroll_controls ppc,
		psp_payroll_sub_lines ppsl
	WHERE 	ppl.payroll_control_id 	= ppc.payroll_control_id
	AND	ppl.payroll_line_id 	= ppsl.payroll_line_id
	AND 	ppc.source_type 	= p_source_type
	and 	ppc.payroll_source_code = p_source_code
	and 	ppc.time_period_id 	= p_time_period_id
	and 	(ppc.batch_name 	= p_batch_name or ppc.batch_name IS NULL)
	and 	ppl.person_id 		= person_id_1
	and 	ppl.assignment_id 	= assignment_id_1
	and	ppc.currency_code	= currency_code_1
	and 	ppl.element_type_id 	= element_type_id_1;




  	RETURN(v_debit_amount_sl);
RETURN NULL; exception
  when no_data_found then
  return(null);
end;

function AfterPForm return boolean is
begin
  --orientation := 'LANDSCAPE';


  select start_date into p_start_date
  from per_time_periods
  where time_period_id = p_time_period_id;
  return (TRUE);
  RETURN NULL; exception when no_data_found then
    /*srw.message(1,'Start Date not found for the selected time period id');*/null;

    return (FALSE);
  when too_many_rows then
    /*srw.message(2,'Too many rows found for the selected time period id');*/null;

    return (FALSE);
  when others then
    /*srw.message(3,'Others exception raised');*/null;

  return (FALSE);


end;

function cf_mismatch_eltformula(l_debit_amount in number, cf_amt_sl_d in number, l_credit_amount in number) return varchar2 is
begin
  if l_debit_amount <> cf_amt_sl_d or l_credit_amount <> cp_credit_amount_sl then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_mismatch_assgformula(sum_l_d_assg in number, sum_sl_d_assg in number, sum_l_c_assg in number, sum_sl_c_assg in number) return varchar2 is
begin
  if sum_l_d_assg <> sum_sl_d_assg or sum_l_c_assg <> sum_sl_c_assg then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_mismatch_personformula(sum_l_d_person in number, sum_sl_d_person in number, sum_l_c_person in number, sum_sl_c_person in number) return varchar2 is
begin
  if sum_l_d_person <> sum_sl_d_person or sum_l_c_person <> sum_sl_c_person then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_mismatch_reportformula(sum_l_d_total in number, sum_sl_d_total in number, sum_l_c_total in number, sum_sl_c_total in number) return varchar2 is
begin

  if sum_l_d_total <> sum_sl_d_total or sum_l_c_total <> sum_sl_c_total then
     return('Mismatch');
  end if;
RETURN NULL; end;

function CF_amt_sl_cFormula return Number is
  begin



RETURN NULL; exception
  when no_data_found then
  return(null);
end;

function CF_amt_l_cFormula return Number is
  begin




RETURN NULL; exception
  when no_data_found then
  return(null);
end;

function CF_amt_l_dFormula return Number is

begin



RETURN NULL; exception
  when no_data_found then
  return(null);
end;

function CF_orgFormula return VARCHAR2 is
  x_org_name 	hr_all_organization_units_tl.name%TYPE;	  x_org_id	varchar2(15);
begin
  fnd_profile.get('PSP_ORG_REPORT', x_org_id);

  if x_org_id is not null then
	select name into x_org_name from hr_organization_units				where organization_id = TO_NUMBER(x_org_id);
	return(x_org_name);
  end if;

  RETURN NULL;


EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
		RETURN('Organization Defined in Profile Not Found');


end;

function CF_source_typeFormula return VARCHAR2 is
  x_source_type		varchar2(80);
begin
  select meaning into x_source_type from psp_lookups
  where lookup_type = 'PSP_SOURCE_TYPE' and lookup_code = p_source_type;
  return(x_source_type);
end;

function CF_time_periodFormula return VARCHAR2 is
  x_time_period		varchar2(35);
begin
  if p_time_period_id is not null then
  	select period_name into x_time_period from per_time_periods
  	where time_period_id = p_time_period_id;
  	return(x_time_period);
  end if;
RETURN NULL; end;

function BeforeReport return boolean is
begin

	--hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function cf_currency_formatformula(currency_code in varchar2) return char is
begin
   	/*srw.reference(currency_code);*/null;

	RETURN(fnd_currency.get_format_mask(currency_code, 30));

end;

function cf_currency_codeformula(currency_code in varchar2) return char is
begin
  /*srw.reference(currency_code);*/null;

   RETURN('(' || currency_code || ')');
end;

function cf_l_debit_amount_dspformula(l_debit_amount in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(l_debit_amount);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(l_debit_amount,cf_currency_format));

end;

function cf_l_credit_amount_dspformula(l_credit_amount in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(l_credit_amount);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(l_credit_amount,cf_currency_format));

end;

function cf_mismatch_currencyformula(cs_sum_l_d_total in number, cs_sum_sl_d_total in number, cs_sum_l_c_total in number, cs_sum_sl_c_total in number) return char is
begin

  if cs_sum_l_d_total <> cs_sum_sl_d_total or cs_sum_l_c_total <> cs_sum_sl_c_total then
	return('Mismatch');
  end if;
RETURN NULL;
end;

function CP_credit_amount_slFormula return Number is
begin
  null;
  return CP_CREDIT_AMOUNT_SL;
end;

function cf_amt_sl_d_dspformula(cf_amt_sl_d in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cf_amt_sl_d);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cf_amt_sl_d,cf_currency_format));

end;

function cf_credit_amount_sl_dspformula(cf_currency_format in varchar2) return char is
begin

    /*srw.reference(cp_credit_amount_sl);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(cp_credit_amount_sl,cf_currency_format));

end;

function cf_sum_l_d_assg_dspformula(sum_l_d_assg in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(sum_l_d_assg);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(sum_l_d_assg,cf_currency_format));

end;

function cf_sum_l_c_assg_dspformula(sum_l_c_assg in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(sum_l_c_assg);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(sum_l_c_assg,cf_currency_format));

end;

function cf_sum_sl_d_assg_dspformula(sum_sl_d_assg in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(sum_sl_d_assg);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_sl_d_assg,cf_currency_format));

end;

function cf_sum_sl_c_assg_dspformula(sum_sl_c_assg in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(sum_sl_c_assg);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_sl_c_assg,cf_currency_format));

end;

function cf_sum_l_d_person_dspformula(sum_l_d_person in number, cf_currency_format in varchar2) return char is
begin
    /*srw.reference(sum_l_d_person);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_l_d_person,cf_currency_format));
end;

function cf_sum_l_c_person_dspformula(sum_l_c_person in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(sum_l_c_person);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_l_c_person,cf_currency_format));

end;

function cf_sum_sl_d_person_dspformula(sum_sl_d_person in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(sum_sl_d_person);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_sl_d_person,cf_currency_format));

end;

function cf_sum_sl_c_person_dspformula(sum_sl_c_person in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(sum_sl_c_person);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(sum_sl_c_person,cf_currency_format));


end;

function cf_sum_l_d_total_dspformula(cs_sum_l_d_total in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(cs_sum_l_d_total);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(cs_sum_l_d_total,cf_currency_format));

end;

function cf_sum_sl_d_total_dspformula(cs_sum_sl_d_total in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(cs_sum_sl_d_total);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(cs_sum_sl_d_total,cf_currency_format));


end;

function cf_sum_sl_c_total_dspformula(cs_sum_sl_c_total in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(cs_sum_sl_c_total);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(cs_sum_sl_c_total,cf_currency_format));


end;

function cf_sum_l_c_total_dspformula(cs_sum_l_c_total in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(cs_sum_l_c_total);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(cs_sum_l_c_total,cf_currency_format));

end;

function AfterReport return boolean is
begin
	--hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_credit_amount_sl_p return number is
	Begin
	 return CP_credit_amount_sl;
	 END;
END PSP_PSPRCLSL_XMLP_PKG ;

/
