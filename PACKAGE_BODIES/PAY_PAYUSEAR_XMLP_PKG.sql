--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSEAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSEAR_XMLP_PKG" AS
/* $Header: PAYUSEARB.pls 120.0 2007/12/28 06:44:46 srikrish noship $ */

function BeforeReport return boolean is
begin

DECLARE l_time_period_name VARCHAR2(70);
        l_period_start_date DATE;
        l_period_end_date DATE;

begin

-- hr_standard.event('BEFORE REPORT');
 null;
 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

 if p_consolidation_set_id is not null then
    c_consolidation_set_name :=
       hr_us_reports.get_consolidation_set
       (p_consolidation_set_id);
 end if;

 if p_time_period_id is not null then
    hr_reports.get_time_period
         (p_time_period_id
         ,l_time_period_name
         ,l_period_start_date
         ,l_period_end_date);
    c_time_period_name := l_time_period_name;
    c_period_start_date := l_period_start_date;
    c_period_end_date := l_period_end_date;
 end if;

 if p_payroll_id is not null then
    c_payroll_name :=
hr_reports.get_payroll_name(l_period_end_date
                              ,p_payroll_id);
 end if;

 if p_tax_unit_id is not null then
    c_tax_unit := hr_us_reports.get_org_name(p_tax_unit_id,p_business_group_id);
 end if;

 if p_payroll_action_id is not null then
    c_payroll_action := hr_us_reports.get_payroll_action
                   (p_payroll_action_id);
 end if;

 if p_element_type_id is not null then
    c_element_type_name := hr_us_reports.get_element_type_name
                  (p_element_type_id);
 end if;

end;  return (TRUE);
end;

function tax_unit_addressformula(location_id in number) return varchar2 is
begin

DECLARE l_tax_unit_address VARCHAR2(300);
        l_location_id NUMBER(15);

begin

   l_location_id := location_id;
   hr_us_reports.get_address
                   (l_location_id
                   ,l_tax_unit_address);

   c_tax_unit_address2 := l_tax_unit_address;

end;

RETURN NULL; end;

function c_valueformula(value in varchar2, uom in varchar2, currency1 in varchar2) return varchar2 is
begin

DECLARE
in_pay_value varchar2(30);
out_pay_value varchar2(30);
begin
in_pay_value := value;
hr_chkfmt.changeformat(in_pay_value,
                       out_pay_value,
                       uom,
                       currency1);
return (out_pay_value);
end;
RETURN NULL; end;

function G_tax_unit_headerGroupFilter return boolean is
begin

/*srw.message('001','GRE Name ->'||tax_unit_name);*/null;
  return (TRUE);
end;

function AfterReport return boolean is
begin

 -- hr_standard.event('AFTER REPORT');


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_TAX_UNIT_ADDRESS2_p return varchar2 is
	Begin
	 return C_TAX_UNIT_ADDRESS2;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_CONSOLIDATION_SET_NAME_p return varchar2 is
	Begin
	 return C_CONSOLIDATION_SET_NAME;
	 END;
 Function C_TIME_PERIOD_NAME_p return varchar2 is
	Begin
	 return C_TIME_PERIOD_NAME;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
 Function C_PAYROLL_ACTION_p return varchar2 is
	Begin
	 return C_PAYROLL_ACTION;
	 END;
 Function C_TAX_UNIT_p return varchar2 is
	Begin
	 return C_TAX_UNIT;
	 END;
 Function C_PERIOD_START_DATE_p return date is
	Begin
	 return C_PERIOD_START_DATE;
	 END;
 Function C_PERIOD_END_DATE_p return date is
	Begin
	 return C_PERIOD_END_DATE;
	 END;
 Function C_ELEMENT_TYPE_NAME_p return varchar2 is
	Begin
	 return C_ELEMENT_TYPE_NAME;
	 END;
END PAY_PAYUSEAR_XMLP_PKG ;

/
