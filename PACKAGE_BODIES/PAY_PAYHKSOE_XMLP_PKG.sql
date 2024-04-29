--------------------------------------------------------
--  DDL for Package Body PAY_PAYHKSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYHKSOE_XMLP_PKG" AS
/* $Header: PAYHKSOEB.pls 120.0 2007/12/13 12:17:25 amakrish noship $ */

function BeforeReport return boolean is
begin

  /*srw.user_exit('FND SRWINIT');*/null;
      P_PAYMENTS_FROM_DATE_DISP := to_char(P_PAYMENTS_FROM_DATE,'DD-MON-YYYY');
      P_PAYMENTS_TO_DATE_DISP:= to_char(P_PAYMENTS_TO_DATE,'DD-MON-YYYY');

  construct_where_clause;
  construct_order_by;


  return (TRUE);
end;

PROCEDURE construct_order_by IS
begin
  cp_order_by := null;


  if P_SORT_ORDER_1 is not null then
    cp_order_by := P_SORT_ORDER_1;
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
    cp_order_by := ' order by ' || cp_order_by || ', Assignment_ID';
  else
    cp_order_by := ' order by Assignment_ID';
  end if;
end;

PROCEDURE construct_where_clause IS

begin

 -- cp_where_clause := null;
  cp_where_clause := ' ';

  if p_Consolidation_Set is not null then
     cp_where_clause := ' and Consolidation_Set_ID = ' || p_Consolidation_Set;
  end if;

  if p_Payroll is not null then
     cp_where_clause := cp_where_clause || ' and Payroll_ID = ' || P_Payroll;
  end if;

end;

function cf_get_balances_totalsformula(assignment_action_id4 in number, tax_unit_id1 in number) return number is
begin
  pay_hk_soe_pkg.balance_totals(assignment_action_id4,
				tax_unit_id1,
                                cp_Total_Earnings_This_Pay,
				cp_Total_Earnings_YTD,
                                cp_Total_Deductions_This_pay,
				cp_Total_Deductions_YTD,
				cp_Net_Pay_This_pay,
                                cp_Net_Pay_YTD,
                                cp_Direct_Payments_This_Pay,
                                cp_Direct_Payments_YTD,
                                cp_Total_Payment_This_Pay,
                 		cp_Total_Payment_YTD);

RETURN 0;
end;

function AfterReport return boolean is
begin

  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_currency_format_maskFormula return VARCHAR2 is

  v_currency_code	fnd_currencies.currency_code%type;
  v_format_mask		varchar2(100) := null;
  v_field_length	number(3)	:= 15;

begin

    v_currency_code := pay_hk_soe_pkg.business_currency_code(p_business_group_id);
  v_format_mask   := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;

end;

function CF_MPF_Flag1Formula return Number is
begin

    Print_MPF_Flag := 0;

  Return 0;

end;

function cf_mpf_flag2formula(CS_Count in number, element_name_sort1 in number) return number is
begin

  If CP_Count is null then
    CP_Count := 0;
  End if;

  If CS_Count = 0 then
    Print_MPF_Flag := 0;
  End if;

  If CP_Count = 0 then
    Print_MPF_Flag := 0;
  End if;

  CP_Count := CP_Count + 1;


  If element_name_sort1 < 99 then
    Print_MPF_Flag := 1;
    If CP_Count = CS_Count then
       CP_Count := 0;
    End if;
    Return 0;
  End if;

  If CP_Count = CS_Count then
     CP_Count := 0;
  End if;

  Return 0;

end;

function cf_net_accrualformula(assignment_id3 in number, accrual_plan_id1 in number, payroll_id in number, business_group_id in number, end_date1 in date) return number is
begin

  per_accrual_calc_functions.get_net_accrual(p_assignment_id => assignment_id3,
					     p_plan_id => accrual_plan_id1,
					     p_payroll_id => payroll_id,
					     p_business_group_id => business_group_id,
					     p_calculation_date => end_date1,
					     p_start_date => cp_start_date,
					     p_end_date => cp_end_date,
					     p_accrual_end_date => cp_accrual_end_date,
					     p_accrual => cp_accrual,
					     p_net_entitlement => cp_net_entitlement);
  Return 0;

  Exception
	when no_data_found then return(null);
end;

--Functions to refer Oracle report placeholders--
 Function PRINT_MPF_FLAG_p return number is
	Begin
	 return PRINT_MPF_FLAG;
	 END;

 Function CP_Total_Earnings_This_Pay_p return number is
	Begin
	 return CP_Total_Earnings_This_Pay;
	 END;
 Function CP_Total_Deductions_This_Pay_p return number is
	Begin
	 return CP_Total_Deductions_This_Pay;
	 END;
 Function CP_Net_Pay_This_Pay_p return number is
	Begin
	 return CP_Net_Pay_This_Pay;
	 END;
 Function CP_Direct_Payments_This_Pay_p return number is
	Begin
	 return CP_Direct_Payments_This_Pay;
	 END;
 Function CP_Total_Payment_This_Pay_p return number is
	Begin
	 return CP_Total_Payment_This_Pay;
	 END;
 Function CP_Total_Earnings_YTD_p return number is
	Begin
	 return CP_Total_Earnings_YTD;
	 END;
 Function CP_Total_Deductions_YTD_p return number is
	Begin
	 return CP_Total_Deductions_YTD;
	 END;
 Function CP_Net_Pay_YTD_p return number is
	Begin
	 return CP_Net_Pay_YTD;
	 END;
 Function CP_Direct_Payments_YTD_p return number is
	Begin
	 return CP_Direct_Payments_YTD;
	 END;
 Function CP_Total_Payment_YTD_p return number is
	Begin
	 return CP_Total_Payment_YTD;
	 END;
 Function CP_Count_p return number is
	Begin
	 return CP_Count;
	 END;
 Function CP_start_date_p return date is
	Begin
	 return CP_start_date;
	 END;
 Function CP_End_Date_p return date is
	Begin
	 return CP_End_Date;
	 END;
 Function CP_accrual_end_date_p return date is
	Begin
	 return CP_accrual_end_date;
	 END;
 Function CP_accrual_p return number is
	Begin
	 return CP_accrual;
	 END;
 Function CP_net_entitlement_p return number is
	Begin
	 return CP_net_entitlement;
	 END;
 Function cp_order_by_p return varchar2 is
	Begin
	 return cp_order_by;
	 END;
 Function CP_sort_by_p return varchar2 is
	Begin
	 return CP_sort_by;
	 END;
 Function CP_where_clause_p return varchar2 is
	Begin
	 return CP_where_clause;
	 END;
END PAY_PAYHKSOE_XMLP_PKG ;

/
