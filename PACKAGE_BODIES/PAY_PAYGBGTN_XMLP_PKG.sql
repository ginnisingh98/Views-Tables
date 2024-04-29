--------------------------------------------------------
--  DDL for Package Body PAY_PAYGBGTN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGBGTN_XMLP_PKG" AS
/* $Header: PAYGBGTNB.pls 120.1 2007/12/24 12:43:05 amakrish noship $ */

function Before_Report_Trigger return boolean is
begin

begin

null;
--hr_standard.event('BEFORE REPORT');

	--Global_Variable.Initialise_Variables;
	Initialise_Variables;

cp_business_group_name :=
   rtrim(substr(hr_reports.get_business_group(p_business_group_id),1,240));
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
end;
  return (TRUE);
end;

function Before_Parameter_Form_Trigger return boolean is
begin

  return (TRUE);
end;

function cf_calculate_totals_formula(Balance_Order in number, CS_Balance_Total in number) return number is
begin
	if Balance_Order = 1 then
			--Global_Variable.Gross_Payment:= CS_Balance_Total;
			Gross_Payment:= CS_Balance_Total;
			--Global_Variable.Net_Payment:= CS_Balance_Total;
			Net_Payment:= CS_Balance_Total;
			--Global_Variable.Total_Payment:= CS_Balance_Total;
			Total_Payment:= CS_Balance_Total;
			--Global_Variable.Total_Cost:= CS_Balance_Total;
			Total_Cost:= CS_Balance_Total;
	elsif  Balance_Order = 2 then
		--Global_Variable.Net_Payment:= Global_Variable.Net_Payment - CS_Balance_Total;
		Net_Payment:= Net_Payment - CS_Balance_Total;
	elsif  Balance_Order = 3 then
		--Global_Variable.Total_Payment:= Global_Variable.Net_Payment + CS_Balance_Total;
		Total_Payment:= Net_Payment + CS_Balance_Total;
		--Global_Variable.Total_Cost:= Global_Variable.Total_Cost + CS_Balance_Total;
		Total_Cost:= Total_Cost + CS_Balance_Total;
	elsif  Balance_Order = 4 then
		--Global_Variable.Total_Cost:= Global_Variable.Total_Cost + CS_Balance_Total;
		Total_Cost:= Total_Cost + CS_Balance_Total;
	end if;
	return(0);
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
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

	----------------------
	--Additional package--
	----------------------
	Procedure Initialise_Variables IS
	BEGIN
			Gross_Payment:=0;
			Net_Payment:=0;
			Total_Payment:=0;
			Total_Cost:=0;
	end;
	----------------------
END PAY_PAYGBGTN_XMLP_PKG ;

/
