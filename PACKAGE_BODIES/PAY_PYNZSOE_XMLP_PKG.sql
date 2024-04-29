--------------------------------------------------------
--  DDL for Package Body PAY_PYNZSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYNZSOE_XMLP_PKG" AS
/* $Header: PYNZSOEB.pls 120.0 2007/12/13 12:22:45 amakrish noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
l_param_display_payroll_name    pay_payrolls_f.Payroll_Name%TYPE;
l_param_display_payroll_action  hr_lookups.meaning%TYPE;
l_token                         number(1);

BEGIN


  /*srw.user_exit('FND SRWINIT');*/null;


  l_token := 1;
  select payroll_name
  into l_param_display_payroll_name
  from pay_payrolls_f
  where payroll_id = P_Payroll_Id;

  CP_PAYROLL_NAME := l_param_display_payroll_name;


  l_token := 2;
  select fcl.meaning
  into l_param_display_payroll_action
  from pay_payroll_actions ppa,
       hr_lookups fcl
  where fcl.lookup_type = 'ACTION_TYPE'
  and ppa.payroll_action_id = P_Payroll_Action_Id
  and ppa.action_type = fcl.lookup_code;

  CP_PAYMENT_RUN:= l_param_display_payroll_action;


  --cp_where_clause := null;
  cp_where_clause :=  ' ';

  l_token := 3;
  IF p_assignment_id is not null THEN
     CP_WHERE_CLAUSE := ' and assignment_id = ' || to_char(p_assignment_id);
  END IF;

  l_token := 4;
  IF p_location_id is not null THEN
     CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || ' and location_id = ' || to_char(p_location_id);
  END IF;

  l_token := 5;
  IF p_organisation_name is not null THEN
     CP_WHERE_CLAUSE := CP_WHERE_CLAUSE || ' and registered_employer = ''' || p_organisation_name ||'''';
  END IF;


  cp_order_by := null;

  if p_sort_order_1 = 'FULL_NAME' then
     p_sort_order_1 := 'nvl(order_name,full_name)';
   end if;

   if p_sort_order_2 = 'FULL_NAME' then
      p_sort_order_2 := 'nvl(order_name,full_name)';
   end if ;

  if p_sort_order_3 = 'FULL_NAME' then
     p_sort_order_3 := 'nvl(order_name,full_name)';
   end if;

   if p_sort_order_4 = 'FULL_NAME' then
      p_sort_order_4 := 'nvl(order_name,full_name)';
   end if ;



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

  return (TRUE);

RETURN NULL; EXCEPTION
 WHEN  USER_EXIT_FAILURE /*srw.user_exit_failure */THEN
   BEGIN
     /*srw.message(100, 'Foundation is not initialised');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

   END;

 RETURN NULL; WHEN NO_DATA_FOUND THEN
   IF l_token = 1 THEN
     /*srw.message(100, 'Payroll ' || to_char(P_Payroll_Id) || ' does not exist.');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

   ELSIF l_token = 2 THEN
     /*srw.message(200, 'Payroll Action Id ' || to_char(P_Payroll_Action_Id) || ' is not valid.');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

   ELSIF l_token in (3,4,5) THEN
     /*srw.message(300, 'Where clause substitution failed.');*/null;

     raise_application_error(-20101,null);/*srw.program_abort;*/null;

   END IF;

 RETURN NULL; WHEN OTHERS THEN
     /*srw.message( 1000, 'Report encountered an undefined error.');*/null;

     return (FALSE);

END;

function AfterReport return boolean is
begin

  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--function f_get_detailsformula(ass_number in varchar2, assignment_id in number, date_earned in date, home_office_ind in varchar2, person_id1 in number, location_id1 in number) return number is
function f_get_detailsformula(ass_number in varchar2, v_assignment_id in number, date_earned in date, home_office_ind in varchar2, person_id1 in number, location_id1 in number) return number is


l_address_line_1  varchar2(60);
l_address_line_2  varchar2(60);
l_address_line_3  varchar2(60);
l_town_city       varchar2(60);
l_postcode        varchar2(60);
l_country         varchar2(60);
l_position_name   varchar2(30);


BEGIN

  BEGIN
        IF ass_number is not null THEN
            select substr(ppos.name,1,30)
       into l_position_name
       from per_assignments_f paf,
            per_positions ppos
       where paf.position_id = ppos.position_id
       --and paf.assignment_id = assignment_id
       and paf.assignment_id = v_assignment_id
       and date_earned between paf.effective_start_date and paf.effective_end_date;

       p_position_name := l_position_name;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         p_position_name := 'Position name N/A';
  END;

      IF home_office_ind = 'H' THEN
     pay_nz_soe_pkg.get_home_address(p_person_id    => person_id1,
                                     p_addr_line1   => l_address_line_1,
                                     p_addr_line2   => l_address_line_2,
                                     p_addr_line3   => l_address_line_3,
                                     p_town_city    => l_town_city,
                                     p_postal_code  => l_postcode,
                                     p_country_name => l_country);

     p_address_line_1 := l_address_line_1;
     p_address_line_2 := l_address_line_2;
     p_address_line_3 := l_address_line_3;
     p_town_city      := l_town_city;
     p_postcode       := l_postcode;
     p_country        := l_country;


  ELSIF home_office_ind <> 'H' or home_office_ind is null THEN
     IF location_id1 is not null THEN
         pay_nz_soe_pkg.get_work_address(p_location_id  => location_id1,
                                         p_addr_line1   => l_address_line_1,
                                         p_addr_line2   => l_address_line_2,
                                         p_addr_line3   => l_address_line_3,
                                         p_town_city    => l_town_city,
                                         p_postal_code  => l_postcode,
                                         p_country_name => l_country);
         p_address_line_1 := l_address_line_1;
         p_address_line_2 := l_address_line_2;
         p_address_line_3 := l_address_line_3;
         p_town_city      := l_town_city;
         p_postcode       := l_postcode;
         p_country        := l_country;

     END IF;
  END IF;

  RETURN(1);

END;

function f_get_cumulative_leave_balform(leave_balance_absence_type in varchar2, leave_balance_assignment_id in number, leave_balance_payroll_id in number, leave_balance_bus_grp_id in number, leave_balance_accrual_plan_id in number,
period_end_date in date) return number is
l_cumulative_bal      number(10) := 0;

BEGIN
  IF leave_balance_absence_type is not null THEN
     l_cumulative_bal := HR_NZ_HOLIDAYS.GET_NET_ACCRUAL( leave_balance_assignment_id,
                                                         leave_balance_payroll_id,
                                                         leave_balance_bus_grp_id,
                                                         leave_balance_accrual_plan_id,
                                                         period_end_date);
     p_cumulative_leave_bal := l_cumulative_bal;

     return(l_cumulative_bal);
  END IF;
RETURN NULL; END;

function cf_amount_paidformula(classification_name in varchar2, earnings_element_value in number) return number is

begin
  IF classification_name = 'Employer Superannuation Contributions' THEN
     return(0);
  ELSIF classification_name = 'Deductions' THEN
     return(earnings_element_value * -1);
  ELSE
     return(earnings_element_value);
  END IF;
RETURN NULL; end;

function cf_get_miscellaneous_valuesfor(assignment_id in number, run_ass_action_id_link_from_q1 in number, date_earned in date) return number is
begin
  pay_nz_soe_pkg.balance_totals( assignment_id,
                                run_ass_action_id_link_from_q1,
                                date_earned,
                                cp_gross_this_pay,
                                cp_other_deductions_this_pay,
                                cp_tax_deductions_this_pay,
                                cp_gross_ytd,
                                cp_other_deductions_ytd,
                                cp_tax_deductions_ytd,
                                 cp_non_tax_allow_this_pay,
                                cp_non_tax_allow_ytd,
                                 cp_pre_tax_deductions_this_pay,
                                cp_pre_tax_deductions_ytd);

 cp_gross_this_pay := cp_gross_this_pay + cp_pre_tax_deductions_this_pay;
 cp_gross_ytd := cp_gross_ytd + cp_pre_tax_deductions_ytd;

 return 0;
end;

function CF_net_this_payFormula return Number is
begin


  return (cp_gross_this_pay
        + cp_non_tax_allow_this_pay
        - cp_other_deductions_this_pay
        - cp_tax_deductions_this_pay);
end;

function CF_net_ytdFormula return Number is
begin


  return (cp_gross_ytd
        + cp_non_tax_allow_ytd
        - cp_other_deductions_ytd
        - cp_tax_deductions_ytd);
end;

function CF_CURRENCY_FORMAT_MASKFormula return VARCHAR2 is



  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)     := 15;

begin
    v_currency_code := pay_nz_soe_pkg.business_currency_code(p_business_group_id);
  v_format_mask   := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;
end;

function G_Asg_Payments_Break_GGroupFil return boolean is
begin
  /*srw.message(1000,'pay action id' || to_char(p_payroll_action_id));*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function P_Address_Line_1_p return varchar2 is
	Begin
	 return P_Address_Line_1;
	 END;
 Function P_Address_Line_2_p return varchar2 is
	Begin
	 return P_Address_Line_2;
	 END;
 Function P_Address_Line_3_p return varchar2 is
	Begin
	 return P_Address_Line_3;
	 END;
 Function P_Town_City_p return varchar2 is
	Begin
	 return P_Town_City;
	 END;
 Function P_PostCode_p return varchar2 is
	Begin
	 return P_PostCode;
	 END;
 Function P_Country_p return varchar2 is
	Begin
	 return P_Country;
	 END;
 Function P_Position_Name_p return varchar2 is
	Begin
	 return P_Position_Name;
	 END;
 Function CP_non_tax_allow_this_pay_p return number is
	Begin
	 return CP_non_tax_allow_this_pay;
	 END;
 Function CP_non_tax_allow_ytd_p return number is
	Begin
	 return CP_non_tax_allow_ytd;
	 END;
 Function CP_gross_ytd_p return number is
	Begin
	 return CP_gross_ytd;
	 END;
 Function CP_gross_this_pay_p return number is
	Begin
	 return CP_gross_this_pay;
	 END;
 Function CP_other_deductions_ytd_p return number is
	Begin
	 return CP_other_deductions_ytd;
	 END;
 Function CP_other_deductions_this_pay_p return number is
	Begin
	 return CP_other_deductions_this_pay;
	 END;
 Function CP_tax_deductions_ytd_p return number is
	Begin
	 return CP_tax_deductions_ytd;
	 END;
 Function CP_pre_tax_deductions_this_pa return number is
	Begin
	 return CP_pre_tax_deductions_this_pay;
	 END;
 Function CP_pre_tax_deductions_ytd_p return number is
	Begin
	 return CP_pre_tax_deductions_ytd;
	 END;
 Function CP_tax_deductions_this_pay_p return number is
	Begin
	 return CP_tax_deductions_this_pay;
	 END;
 Function P_Cumulative_Leave_Bal_p return number is
	Begin
	 return P_Cumulative_Leave_Bal;
	 END;
 Function CP_Where_Clause_p return varchar2 is
	Begin
	 return CP_Where_Clause;
	 END;
 Function CP_Payroll_Name_p return varchar2 is
	Begin
	 return CP_Payroll_Name;
	 END;
 Function CP_Payment_Run_p return varchar2 is
	Begin
	 return CP_Payment_Run;
	 END;
 Function CP_ORDER_BY_p return varchar2 is
	Begin
	 return CP_ORDER_BY;
	 END;
END PAY_PYNZSOE_XMLP_PKG ;

/
