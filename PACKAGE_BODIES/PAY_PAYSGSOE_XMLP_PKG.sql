--------------------------------------------------------
--  DDL for Package Body PAY_PAYSGSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYSGSOE_XMLP_PKG" AS
/* $Header: PAYSGSOEB.pls 120.0 2007/12/13 12:23:31 amakrish noship $ */

function cf_gross_pay_currformula(assignment_action_id in number, person_id in number) return number is
  v_gross_pay_curr		number;
  v_ass_act_id pay_assignment_actions.assignment_action_id%type;
   cursor c_pay_ass_act_id(v_assignment_action_id pay_assignment_actions.assignment_action_id%type) is
   select max(pai.locked_action_id) from pay_action_interlocks pai
   where pai.locking_action_id = v_assignment_action_id;
begin
            open c_pay_ass_act_id(assignment_action_id);
    fetch c_pay_ass_act_id into v_ass_act_id;
    if v_ass_act_id is NULL then
       v_ass_act_id := assignment_action_id;
    end if;
    close c_pay_ass_act_id;



    pay_sg_soe.balance_totals( p_assignment_action_id 		=> 	v_ass_act_id,
 			       p_person_id                      =>      person_id,
  	  		       p_gross_pay_current		=> 	v_gross_pay_curr,
  		  	       p_statutory_deductions_current   => 	cp_stat_ded_curr,
  			       p_other_deductions_current	=>  	cp_other_curr,
  			       p_net_pay_current		=>	cp_net_pay_curr,
  			       p_non_payroll_current		=>	cp_non_pay_curr,
  			       p_gross_pay_ytd			=>	cp_gross_pay_ytd,
  			       p_statutory_deductions_ytd	=>	cp_stat_ded_ytd,
  			       p_other_deductions_ytd		=>	cp_other_ytd,
  			       p_net_pay_ytd			=>	cp_net_pay_ytd,
  			       p_non_payroll_ytd		=>	cp_non_pay_ytd,
  			       p_employee_cpf_current		=>	cp_employee_cpf_curr,
  			       p_employer_cpf_current		=>	cp_employer_cpf_curr,
  			       p_cpf_total_current		=>	cp_total_cpf_curr,
  			       p_employee_cpf_ytd		=>	cp_employee_cpf_ytd,
  			       p_employer_cpf_ytd		=>	cp_employer_cpf_ytd,
  			       p_cpf_total_ytd			=>	cp_total_cpf_ytd
                             );
  RETURN(v_gross_pay_curr);
end;

function cf_address_line1formula(expense_check_send_to_address in varchar2, person_id in number, location_id in number) return char is

  v_address_line_1  hr_locations.address_line_1%type;
  v_address_line_2  hr_locations.address_line_2%type;
  v_address_line_3  hr_locations.address_line_3%type;
  v_town_city       hr_locations.town_or_city%type;
  v_postal_code     hr_locations.postal_code%type;
  v_country         fnd_territories_tl.territory_short_name%type;
begin
      if expense_check_send_to_address = 'H' then
    pay_sg_soe.get_home_address(person_id,
                                    v_address_line_1,
                                    v_address_line_2,
                                    v_address_line_3,
                                    v_town_city,
                                    v_postal_code,
                                    v_country);
  else     pay_sg_soe.get_work_address(location_id,
                                    v_address_line_1,
                                    v_address_line_2,
                                    v_address_line_3,
                                    v_town_city,
                                    v_postal_code,
                                    v_country);
  end if;

    cp_address_line2  := v_address_line_2;
  cp_address_line3  := v_address_line_3;
  cp_town			     := v_town_city;
  cp_post_code      := v_postal_code;
  cp_country        := v_country;

  return v_address_line_1;
end;

function cf_get_absence_detailsformula(assignment_id_l in number, accrual_plan_id_l in number, period_end_date in date, period_start_date in date, payroll_id_l in number, business_group_id_l in number, effective_date_l in date) return number is

begin
  cp_abs_this_period := per_accrual_calc_functions.get_absence
                         (p_assignment_id    => assignment_id_l,
                          p_plan_id          => accrual_plan_id_l,
                          p_calculation_date => period_end_date,
                          p_start_date       => period_start_date);

  cp_net_accrual     := pay_sg_soe.net_accrual
                         (p_assignment_id     => assignment_id_l,
                          p_plan_id           => accrual_plan_id_l,
                          p_payroll_id        => payroll_id_l,
                          p_business_group_id => business_group_id_l,
                          p_effective_date    => effective_date_l);

  return 0;
end;

function cf_hourly_rateformula(hours in number, amount in number) return number is
  v_rate   NUMBER;
begin
  IF nvl(hours,0) <> 0 THEN
    v_rate := amount/hours;
  END IF;
  return(v_rate);
end;

function CF_CURRENCY_FORMAT_MASKFormula return Char is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)     := 15;

begin
    v_currency_code := pay_sg_soe.business_currency_code(p_business_group_id);
  v_format_mask   := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;
end;

function CF_PERCENT_FORMAT_MASKFormula return Char is
  v_mask 		varchar2(30);
begin
  v_mask := '990D0';
  return(v_mask);
end;

function CF_HOURS_FORMAT_MASKFormula return Char is
  v_mask 		varchar2(30);
begin
  v_mask := '990D0';
  return(v_mask);
end;

function CF_RATE_FORMAT_MASKFormula return Char is
  v_mask 		varchar2(30);
begin
  v_mask := '990D90';
  return(v_mask);
end;

function CF_FX_RATE_FORMAT_MASKFormula return Char is
  v_mask 		varchar2(30);
begin
  v_mask := '990D9990';
  return(v_mask);
end;

function BeforeReport return boolean is
begin

  construct_where_clause;
  construct_order_by;

 -- hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

PROCEDURE construct_where_clause IS

begin

  --cp_where_clause := null;
  cp_where_clause :=' ';

  if p_assignment_id is not null then
     cp_where_clause := ' and assignment_id = ' || to_char(p_assignment_id);
  end if;

  if p_location_id is not null then
     cp_where_clause := cp_where_clause || ' and location_id = ' || to_char(p_location_id);
  end if;

  if p_organization_name is not null then
     cp_where_clause := cp_where_clause || ' and legal_employer = ' || '''' || p_organization_name || '''';
  end if;
end;

PROCEDURE construct_order_by IS
begin
  cp_order_by := null;


  if p_sort_order_1 is not null then
    cp_order_by := p_sort_order_1;
  end if;

  if p_sort_order_2 is not null then
    if cp_order_by is not null then
      cp_order_by := cp_order_by || ', ' || p_sort_order_2;
    else
      cp_order_by := p_sort_order_2;
    end if;
  end if;

  if p_sort_order_3 is not null then
    if cp_order_by is not null then
      cp_order_by := cp_order_by || ', ' || p_sort_order_3;
    else
      cp_order_by := p_sort_order_3;
    end if;
  end if;

  if p_sort_order_4 is not null then
    if cp_order_by is not null then
      cp_order_by := cp_order_by || ', ' || p_sort_order_4;
    else
      cp_order_by := p_sort_order_4;
    end if;
  end if;

    if cp_order_by is not null then
    cp_order_by := ' order by ' || cp_order_by;
  else
    cp_order_by := ' order by assignment_number';
  end if;
end;

function AfterReport return boolean is
begin
 -- hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function cf_1formula(ELEMENT_REPORTING_NAME in varchar2) return char is
begin
  IF ELEMENT_REPORTING_NAME IS NULL THEN
   CP_DISPLAY_EARNINGS := 'FALSE';
  ELSE
   CP_DISPLAY_EARNINGS := 'TRUE';
  END IF;
  RETURN(NULL);
end;

function cf_deductions_existformula(ELEMENT_REPORTING_NAME1 in varchar2) return char is
begin
  IF ELEMENT_REPORTING_NAME1 IS NULL THEN
   CP_DISPLAY_DEDUCTIONS := 'FALSE';
  ELSE
   CP_DISPLAY_DEDUCTIONS := 'TRUE';
  END IF;
  RETURN(NULL);
end;

function cf_messages_existformula(PAY_ADVICE_MESSAGE in varchar2) return char is
begin
  IF PAY_ADVICE_MESSAGE IS NULL THEN
   CP_DISPLAY_MESSAGES := 'FALSE';
  ELSE
   CP_DISPLAY_MESSAGES := 'TRUE';
  END IF;
  RETURN(NULL);
end;

function cf_fx_amountformula(exchange_rate in number, amount in number) return number is
v_fx_amount number;
begin
  if NVL(exchange_rate, 0) <> 0 then
	v_fx_amount := amount/exchange_rate;
  end if;
  return v_fx_amount;
end;

--Functions to refer Oracle report placeholders--

 Function CP_ADDRESS_LINE2_p return varchar2 is
	Begin
	 return CP_ADDRESS_LINE2;
	 END;
 Function CP_ADDRESS_LINE3_p return varchar2 is
	Begin
	 return CP_ADDRESS_LINE3;
	 END;
 Function CP_TOWN_p return varchar2 is
	Begin
	 return CP_TOWN;
	 END;
 Function CP_POST_CODE_p return varchar2 is
	Begin
	 return CP_POST_CODE;
	 END;
 Function CP_COUNTRY_p return varchar2 is
	Begin
	 return CP_COUNTRY;
	 END;
 Function CP_GROSS_PAY_YTD_p return number is
	Begin
	 return CP_GROSS_PAY_YTD;
	 END;
 Function CP_STAT_DED_CURR_p return number is
	Begin
	 return CP_STAT_DED_CURR;
	 END;
 Function CP_STAT_DED_YTD_p return number is
	Begin
	 return CP_STAT_DED_YTD;
	 END;
 Function CP_OTHER_CURR_p return number is
	Begin
	 return CP_OTHER_CURR;
	 END;
 Function CP_OTHER_YTD_p return number is
	Begin
	 return CP_OTHER_YTD;
	 END;
 Function CP_NON_PAY_CURR_p return number is
	Begin
	 return CP_NON_PAY_CURR;
	 END;
 Function CP_NON_PAY_YTD_p return number is
	Begin
	 return CP_NON_PAY_YTD;
	 END;
 Function CP_NET_PAY_CURR_p return number is
	Begin
	 return CP_NET_PAY_CURR;
	 END;
 Function CP_NET_PAY_YTD_p return number is
	Begin
	 return CP_NET_PAY_YTD;
	 END;
 Function CP_EMPLOYEE_CPF_CURR_p return number is
	Begin
	 return CP_EMPLOYEE_CPF_CURR;
	 END;
 Function CP_EMPLOYEE_CPF_YTD_p return number is
	Begin
	 return CP_EMPLOYEE_CPF_YTD;
	 END;
 Function CP_EMPLOYER_CPF_CURR_p return number is
	Begin
	 return CP_EMPLOYER_CPF_CURR;
	 END;
 Function CP_EMPLOYER_CPF_YTD_p return number is
	Begin
	 return CP_EMPLOYER_CPF_YTD;
	 END;
 Function CP_TOTAL_CPF_CURR_p return number is
	Begin
	 return CP_TOTAL_CPF_CURR;
	 END;
 Function CP_TOTAL_CPF_YTD_p return number is
	Begin
	 return CP_TOTAL_CPF_YTD;
	 END;
 Function CP_ABS_THIS_PERIOD_p return number is
	Begin
	 return CP_ABS_THIS_PERIOD;
	 END;
 Function CP_NET_ACCRUAL_p return number is
	Begin
	 return CP_NET_ACCRUAL;
	 END;
 Function CP_WHERE_CLAUSE_p return varchar2 is
	Begin
	 return CP_WHERE_CLAUSE;
	 END;
 Function CP_ORDER_BY_p return varchar2 is
	Begin
	 return CP_ORDER_BY;
	 END;
 Function CP_DISPLAY_EARNINGS_p return varchar2 is
	Begin
	 return CP_DISPLAY_EARNINGS;
	 END;
 Function CP_DISPLAY_DEDUCTIONS_p return varchar2 is
	Begin
	 return CP_DISPLAY_DEDUCTIONS;
	 END;
 Function CP_DISPLAY_MESSAGES_p return varchar2 is
	Begin
	 return CP_DISPLAY_MESSAGES;
	 END;
END PAY_PAYSGSOE_XMLP_PKG ;

/
