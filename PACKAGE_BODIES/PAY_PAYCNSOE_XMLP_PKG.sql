--------------------------------------------------------
--  DDL for Package Body PAY_PAYCNSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYCNSOE_XMLP_PKG" AS
/* $Header: PAYCNSOEB.pls 120.1 2008/01/07 13:13:19 srikrish noship $ */

function BeforeReport return boolean is
begin

P_START_DATE_t := to_date(substr(P_START_DATE,1,10),'YYYY/MM/DD');
P_END_DATE_t := to_date(substr(P_END_DATE,1,10),'YYYY/MM/DD');
P_START_DATE_DISP := to_char(P_START_DATE_t,'DD-MON-YY');
P_END_DATE_DISP := to_char(P_END_DATE_t,'DD-MON-YY');
			construct_order_by;
        get_parameters_name;
	/*srw.user_exit('FND SRWINIT');*/null;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_all_organization_units.name%type;

begin
  v_business_group := hr_reports.get_business_group(p_business_group_id);
  return v_business_group;
end;

function CF_legislation_codeFormula return VARCHAR2 is

  v_legislation_code    hr_organization_information.org_information9%type := null;

  cursor legislation_code
    (c_business_group_id hr_organization_information.organization_id%type) is

  select org_information9
  from   hr_organization_information
  where  organization_id  = c_business_group_id
  and    org_information9 is not null
  and    org_information_context = 'Business Group Information';
begin
  open legislation_code (p_business_group_id);
  fetch legislation_code into v_legislation_code;
  close legislation_code;

  return v_legislation_code;
end;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)    := 14;

  cursor currency_format_mask
    (c_territory_code in fnd_currencies.issuing_territory_code%type) is
  select currency_code
  from   fnd_currencies
  where  issuing_territory_code = c_territory_code;

begin
  open currency_format_mask (cf_legislation_code);
  fetch currency_format_mask into v_currency_code;
  close currency_format_mask;

  v_format_mask := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;
end;

PROCEDURE set_currency_format_mask IS
BEGIN

  /*SRW.SET_FORMAT_MASK(CF_currency_format_mask);*/null;


END;

function P_BUSINESS_GROUP_IDValidTrigge return boolean is
begin
  return (TRUE);
end;

function CF_Net_This_PayFormula return Number is
begin

  	RETURN ( nvl(CP_TAXABLE_THIS_PAY,0)
           + nvl(CP_NON_TAXABLE_THIS_PAY,0)
           - nvl(CP_VOLUNTARY_THIS_PAY,0)
           - nvl(CP_STATUTORY_THIS_PAY,0)
           );

end;

function CF_Net_YTDFormula return Number is
begin

  RETURN ( nvl(CP_Taxable_YTD,0)
         + nvl(CP_Non_Taxable_YTD,0)
         - nvl(CP_Voluntary_YTD,0)
         - nvl(CP_Statutory_YTD,0)
         );

end;

function cf_balancesformula(balance_org_name in varchar2, balances_this_Pay in number, balances_YTD in number) return number is
begin
  IF balance_org_name = 'Taxable Earnings'
  	THEN
  		CP_Taxable_This_Pay := balances_this_Pay ;
  		CP_Taxable_YTD := balances_YTD ;

		CP_Non_Taxable_This_Pay:=0;
		CP_Non_Taxable_YTD:=0;
  		CP_Voluntary_This_Pay :=0;
		CP_Voluntary_YTD:=0;
		CP_Statutory_This_Pay :=0;
		CP_Statutory_YTD:=0;
  ELSIF balance_org_name = 'Non Taxable Earnings'
  	THEN
  		CP_Non_Taxable_This_Pay :=  balances_this_pay ;
  	  CP_Non_Taxable_YTD :=  balances_YTD ;

		CP_Taxable_This_Pay:=0;
		CP_Taxable_YTD:=0;
  		CP_Voluntary_This_Pay :=0;
		CP_Voluntary_YTD:=0;
		CP_Statutory_This_Pay :=0;
		CP_Statutory_YTD:=0;
  ELSIF balance_org_name = 'Voluntary Deductions'
  	THEN
  		CP_Voluntary_This_Pay :=  balances_this_pay ;
  	  CP_Voluntary_YTD :=  balances_YTD ;

		CP_Taxable_This_Pay:=0;
		CP_Taxable_YTD:=0;
  		CP_Non_Taxable_This_Pay :=0;
		CP_Non_Taxable_YTD:=0;
		CP_Statutory_This_Pay :=0;
		CP_Statutory_YTD:=0;
  ELSIF balance_org_name = 'Statutory Deductions'
  	THEN
     	CP_Statutory_This_Pay :=  balances_this_pay ;
  	  CP_Statutory_YTD :=  balances_YTD ;

	  CP_Taxable_This_Pay:=0;
		CP_Taxable_YTD:=0;
  		CP_Non_Taxable_This_Pay :=0;
		CP_Non_Taxable_YTD:=0;
		CP_Voluntary_This_Pay :=0;
		CP_Voluntary_YTD:=0;
else

		CP_Statutory_This_Pay :=  0 ;
  		  CP_Statutory_YTD :=  0 ;

		CP_Taxable_This_Pay:=0;
		CP_Taxable_YTD:=0;
  		CP_Non_Taxable_This_Pay :=0;
		CP_Non_Taxable_YTD:=0;
		CP_Voluntary_This_Pay :=0;
		CP_Voluntary_YTD:=0;
  END IF;
    RETURN (0);
end;

PROCEDURE construct_order_by IS
BEGIN

  IF P_SORT_ORDER_1 IS NOT NULL THEN
     CP_ORDER_BY := 'ORDER BY ' || P_SORT_ORDER_1 ;
     IF P_SORT_ORDER_2 IS NOT NULL THEN
        CP_ORDER_BY := CP_ORDER_BY ||', ' || P_SORT_ORDER_2 ;
        IF P_SORT_ORDER_3 IS NOT NULL THEN
           CP_ORDER_BY := CP_ORDER_BY || ', ' || P_SORT_ORDER_3 ;
           IF P_SORT_ORDER_4 IS NOT NULL THEN
              CP_ORDER_BY := CP_ORDER_BY || ', ' || P_SORT_ORDER_4 ;
           END IF ;         END IF ;      END IF ;   ELSE
     CP_ORDER_BY := 'ORDER BY EMPLOYEE_NUMBER' ;
  END IF ;
END;

PROCEDURE get_parameters_name IS

CURSOR  csr_payroll_name  IS
   SELECT ppf.payroll_name
   FROM   pay_payrolls_f ppf
   WHERE  ppf.payroll_id = P_PAYROLL_ID
   AND    ppf.business_group_id = P_BUSINESS_GROUP_ID
  -- AND    P_START_DATE BETWEEN ppf.effective_start_date AND ppf.effective_end_date;
   AND    P_START_DATE_T BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

CURSOR  csr_consolidation_name  IS
   SELECT  pcs.consolidation_set_name
   FROM    pay_consolidation_sets pcs
   WHERE   pcs.consolidation_set_id = P_CONSOLIDATION_SET_ID
   AND     pcs.business_group_id = P_BUSINESS_GROUP_ID ;

CURSOR  csr_business_group  IS
   SELECT pbg.name
   FROM   per_business_groups pbg
   WHERE  pbg.organization_id = P_BUSINESS_GROUP_ID ;


BEGIN

   OPEN csr_payroll_name;
   FETCH csr_payroll_name INTO cp_payroll_name;
   CLOSE csr_payroll_name;

   OPEN  csr_consolidation_name;
   FETCH csr_consolidation_name INTO cp_consolidation_set_name;
   CLOSE csr_consolidation_name;

   OPEN  csr_business_group;
   FETCH csr_business_group INTO cp_business_group_name;
   CLOSE csr_business_group;

   cp_payroll_location := hr_general.decode_lookup('CN_PAYOUT_LOCATION', P_PAYOUT_LOCATION);

   cp_start_date := P_START_DATE_t ;
   cp_end_date := P_END_DATE_t ;

   cp_sort_order_1 := hr_general.decode_lookup('CN_SOE_SORT_BY', P_SORT_ORDER_1);
   cp_sort_order_2 := hr_general.decode_lookup('CN_SOE_SORT_BY', P_SORT_ORDER_2);
   cp_sort_order_3 := hr_general.decode_lookup('CN_SOE_SORT_BY', P_SORT_ORDER_3);
   cp_sort_order_4 := hr_general.decode_lookup('CN_SOE_SORT_BY', P_SORT_ORDER_4);





END;

--Functions to refer Oracle report placeholders--

 Function CP_Taxable_This_Pay_p return number is
	Begin
	 return CP_Taxable_This_Pay;
	 END;
 Function CP_Taxable_YTD_p return number is
	Begin
	 return CP_Taxable_YTD;
	 END;
 Function CP_Non_Taxable_This_Pay_p return number is
	Begin
	 return CP_Non_Taxable_This_Pay;
	 END;
 Function CP_Non_Taxable_YTD_p return number is
	Begin
	 return CP_Non_Taxable_YTD;
	 END;
 Function CP_Voluntary_This_Pay_p return number is
	Begin
	 return CP_Voluntary_This_Pay;
	 END;
 Function CP_Voluntary_YTD_p return number is
	Begin
	 return CP_Voluntary_YTD;
	 END;
 Function CP_Statutory_This_Pay_p return number is
	Begin
	 return CP_Statutory_This_Pay;
	 END;
 Function CP_Statutory_YTD_p return number is
	Begin
	 return CP_Statutory_YTD;
	 END;
 Function CP_ORDER_BY_p return varchar2 is
	Begin
	 return CP_ORDER_BY;
	 END;
 Function CP_Payroll_name_p return varchar2 is
	Begin
	 return CP_Payroll_name;
	 END;
 Function CP_Consolidation_Set_name_p return varchar2 is
	Begin
	 return CP_Consolidation_Set_name;
	 END;
 Function CP_Payroll_Location_p return varchar2 is
	Begin
	 return CP_Payroll_Location;
	 END;
 Function CP_Business_Group_name_p return varchar2 is
	Begin
	 return CP_Business_Group_name;
	 END;
 Function CP_Start_Date_p return date is
	Begin
	 return CP_Start_Date;
	 END;
 Function CP_End_date_p return date is
	Begin
	 return CP_End_date;
	 END;
 Function CP_Sort_Order_1_p return varchar2 is
	Begin
	 return CP_Sort_Order_1;
	 END;
 Function CP_Sort_Order_2_p return varchar2 is
	Begin
	 return CP_Sort_Order_2;
	 END;
 Function CP_Sort_Order_3_p return varchar2 is
	Begin
	 return CP_Sort_Order_3;
	 END;
 Function CP_Sort_Order_4_p return varchar2 is
	Begin
	 return CP_Sort_Order_4;
	 END;
END PAY_PAYCNSOE_XMLP_PKG ;


/
