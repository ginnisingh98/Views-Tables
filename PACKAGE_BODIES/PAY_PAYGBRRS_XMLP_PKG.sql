--------------------------------------------------------
--  DDL for Package Body PAY_PAYGBRRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGBRRS_XMLP_PKG" AS
/* $Header: PAYGBRRSB.pls 120.1 2007/12/24 12:44:07 amakrish noship $ */

function Before_Report_Trigger return boolean is
begin
	begin
	/*srw.user_exit('FND SRWINIT');*/null;
 	select input_value_id into CP_NI_Input_Value_ID from
	pay_element_types_x pet,
	pay_input_values_x piv
	where  pet.system_element_name = 'NI'
        and    piv.system_name = 'Category'
        and pet.element_type_id = piv.element_type_id
        and pet.legislation_code = 'GB';
        begin
      	   select piv.input_value_id,piv2.input_value_id
           into CP_Tax_Code_Input_Value_ID ,CP_Tax_Basis_Input_Value_ID from
	   pay_element_types_x pet,
	   pay_input_values_x piv,
	   pay_input_values_x piv2
	   where  pet.system_element_name = 'PAYE'
           and    piv.system_name = 'Tax Code'
           and    piv2.system_name = 'Tax Basis'
           and pet.element_type_id = piv.element_type_id
           and pet.element_type_id = piv2.element_type_id
           and pet.legislation_code = 'GB';
        exception when no_data_found then
      	   select piv.input_value_id,piv2.input_value_id
           into CP_Tax_Code_Input_Value_ID ,CP_Tax_Basis_Input_Value_ID from
	   pay_element_types_x pet,
	   pay_input_values_x piv,
	   pay_input_values_x piv2
	   where  pet.system_element_name = 'PAYE Details'
           and    piv.system_name = 'Tax Code'
           and    piv2.system_name = 'Tax Basis'
           and pet.element_type_id = piv.element_type_id
           and pet.element_type_id = piv2.element_type_id
           and pet.legislation_code = 'GB';
        end;
end;

begin
 null; 	--Global_Variable.Initialise_Variables;
 Initialise_Variables;
 cp_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);
end;
begin
  if P_CONSOLIDATION_SET_ID is null then
     P_CONSOLIDATION_SET_LINE := ' ';
  else
     P_CONSOLIDATION_SET_LINE :=
                'and ppa.consolidation_set_id ='||(P_CONSOLIDATION_SET_ID);
  end if;
  select LEGISLATION_CODE
  into P_LEGISLATION_CODE
  from per_business_groups
  where BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID;
  select distinct PAYROLL_NAME
  into CP_PAYROLL_NAME
  from PAY_PAYROLLS_F
  where payroll_id = P_PAYROLL_ID;
  select PERIOD_NAME
  into CP_Time_Period_Time
  from PER_TIME_PERIODS
  where time_period_id = P_TIME_PERIOD_ID;
  if P_CONSOLIDATION_SET_ID is not null then
    select CONSOLIDATION_SET_NAME
    into CP_CONSOLIDATION_SET_NAME
    from PAY_CONSOLIDATION_SETS
    where CONSOLIDATION_SET_ID = P_CONSOLIDATION_SET_ID;
  else
    CP_CONSOLIDATION_SET_NAME := null;
  end if;
  if P_Sort_Order = 'FULL_NAME' then
	CP_Sort_Order := 'Full_Name';
  elsif P_Sort_Order = 'ASSIGNMENT_NUMBER' then
	CP_Sort_Order := 'Assignment_Number';
  elsif P_Sort_Order = 'LAST_NAME' then
	CP_Sort_Order := 'Last_Name';
  end if;
if p_currency_code is null
then
   CP_CURRENCY_TEXT := '';
else
   CP_CURRENCY_TEXT := p_currency_code || ' Totals:';
end if;

end;
  return (TRUE);
end;

function Before_Parameter_Form_Trigger return boolean is
begin

  return (TRUE);
end;

function cf_total_paymentformula(Gross in number, Total_Deductions in number, Direct_Payments in number) return number is
begin
	--Global_Variable.Total_Payment:= (Gross - Total_Deductions) + Direct_Payments;
	Total_Payment:= (Gross - Total_Deductions) + Direct_Payments;
	--Return(Global_Variable.Total_Payment);
	Return(Total_Payment);
end;

function cf_other_deductionsformula(Total_Deductions in number, PAYE in number, NI_Employee in number) return number is
begin
	--Global_Variable.Other_Deductions := Total_Deductions - (PAYE + NI_Employee);
	Other_Deductions := Total_Deductions - (PAYE + NI_Employee);
	--return(Global_Variable.Other_Deductions);
	return(Other_Deductions);
end;

function cf_total_payments_currencyform(currency_code in varchar2, date_earned in date, net in number) return number is
begin

if p_currency_code is null
then
   return(null);
else
   begin

   /*Global_Variable.Calc_Amount := hr_currency_pkg.convert_amount(
					currency_code,
					p_currency_code,
					date_earned,
					net,
					'H');*/
	Calc_Amount := hr_currency_pkg.convert_amount(
					currency_code,
					p_currency_code,
					date_earned,
					net,
					'H');
   exception
   when others then
      --Global_Variable.Calc_Amount := 0;
      Calc_Amount := 0;
   end;

   --return(Global_Variable.Calc_Amount);
   return(Calc_Amount);
end if;

RETURN NULL; end;

function cf_total_payments_currency(currency_code in varchar2, date_earned in date, Gross in number, Total_Deductions in number, Direct_Payments in number) return number is
begin

if p_currency_code is null
then
   return(null);
else
   begin

   /*Global_Variable.Calc_Amount := hr_currency_pkg.convert_amount(
					currency_code,
					p_currency_code,
					date_earned,
					(Gross - Total_Deductions) + Direct_Payments,
					'H');*/
	Calc_Amount := hr_currency_pkg.convert_amount(
					currency_code,
					p_currency_code,
					date_earned,
					(Gross - Total_Deductions) + Direct_Payments,
					'H');
   exception
   when others then
      --Global_Variable.Calc_Amount := 0;
      Calc_Amount := 0;
   end;

   --return(Global_Variable.Calc_Amount);
   return(Calc_Amount);
end if;

RETURN NULL; end;

function CP_CURRENCY_TEXTFormula return VARCHAR2 is
begin

null;

RETURN NULL; end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
   return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP_NAME;
	 END;
 Function CP_PAYROLL_NAME_p return varchar2 is
	Begin
	 return CP_PAYROLL_NAME;
	 END;
 Function CP_Time_Period_Time_p return varchar2 is
	Begin
	 return CP_Time_Period_Time;
	 END;
 Function CP_CONSOLIDATION_SET_NAME_p return varchar2 is
	Begin
	 return CP_CONSOLIDATION_SET_NAME;
	 END;
 Function CP_NI_input_Value_ID_p return number is
	Begin
	 return CP_NI_input_Value_ID;
	 END;
 Function CP_Tax_Code_Input_Value_ID_p return number is
	Begin
	 return CP_Tax_Code_Input_Value_ID;
	 END;
 Function CP_Tax_Basis_Input_Value_ID_p return number is
	Begin
	 return CP_Tax_Basis_Input_Value_ID;
	 END;
 Function CP_Sort_Order_p return varchar2 is
	Begin
	 return CP_Sort_Order;
	 END;
 Function CP_CURRENCY_TEXT_p return varchar2 is
	Begin
	 return CP_CURRENCY_TEXT;
	 END;

	----------------------
	--Additional package--
	----------------------
	Procedure Initialise_Variables IS
	BEGIN
		Gross_Payment:=0;
		Net_Payment:=0;
		Total_Payment:=0;
		Total_Cost:=0;
		Other_Deductions:=0;
	end;
	----------------------
END PAY_PAYGBRRS_XMLP_PKG ;

/
