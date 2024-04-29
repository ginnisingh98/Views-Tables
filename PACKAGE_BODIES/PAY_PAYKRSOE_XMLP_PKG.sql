--------------------------------------------------------
--  DDL for Package Body PAY_PAYKRSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYKRSOE_XMLP_PKG" AS
/* $Header: PAYKRSOEB.pls 120.0 2007/12/13 12:20:41 amakrish noship $ */

function BeforeReport return boolean is
begin

   /*srw.user_exit('FND SRWINIT');*/null;


 -- Pk_GlobalVariables.GlVar_Earnings := 0;
  -- Pk_GlobalVariables.GlVar_Deductions := 0;
   --Pk_GlobalVariables.GlVar_Hours := 0;
   --Pk_GlobalVariables.GlVar_Earnings_Frame_Count := 0;
    --Pk_GlobalVariables.GlVar_Deductions_Frame_Count := 0;

   GlVar_Earnings := 0;
   GlVar_Deductions := 0;
   GlVar_Hours := 0;
   GlVar_Earnings_Frame_Count := 0;
  GlVar_Deductions_Frame_Count := 0;

  return (TRUE);
end;

function AfterReport return boolean is
begin

  /*srw.user_exit('FND SRWEXIT');*/null;


  return (TRUE);
end;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_organization_units.name%type;

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

function BetweenPage return boolean is
begin
   GlVar_Earnings := 0;
   GlVar_Deductions := 0;
   GlVar_Hours := 0;
   GlVar_Earnings_Frame_Count := 0;
  GlVar_Deductions_Frame_Count := 0;

 /* Pk_GlobalVariables.GlVar_Earnings := 0;
  Pk_GlobalVariables.GlVar_Deductions := 0;
  Pk_GlobalVariables.GlVar_Hours := 0;
  Pk_GlobalVariables.GlVar_Earnings_Frame_Count := 0;
  Pk_GlobalVariables.GlVar_Deductions_Frame_Count := 0; */
  return (TRUE);
end;

function leavetakenformula(Leave_Taken_Dim_Bal in varchar2, End_Date_Bal in date, Assignment_Id_Bal in number, Accrual_Plan_Id_Bal in number,
Start_Date_Bal in date, Payroll_Id_Bal in number, Business_Group_Id_Bal in number, Assignment_Action_Id_Bal in number) return number is
lvFromDate				DATE;
lvToDate					DATE;
lvLeaveTaken			NUMBER := 0;
lvAccrual  				NUMBER;
lvNetEntitlement 	NUMBER:= 0;
lvDate1 					DATE;
lvDate2 					DATE;
lvDate3 					DATE;
begin
	   If Leave_Taken_Dim_Bal = 'KRCTD' Then
	   				lvFromDate := to_date('01-01-'||to_char(End_Date_Bal,'RRRR'),'DD-MM-RRRR');
	   				lvToDate	 := End_Date_Bal;
	   Elsif Leave_Taken_Dim_Bal = 'KRFTD' Then
	   	      lvFromDate := to_date('01-04-'||to_char(End_Date_Bal,'RRRR'),'DD-MM-RRRR');
	   				lvToDate	 := End_Date_Bal;
	   End If;

	   If Leave_Taken_Dim_Bal IS NOT NULL Then
	   				lvLeaveTaken := Per_Accrual_Calc_Functions.Get_Absence ( p_assignment_id     => Assignment_Id_Bal
	   																													 ,p_plan_id                => Accrual_Plan_Id_Bal
	   																													 ,p_calculation_date       => lvToDate
	   																													 ,p_Start_Date				     => Start_Date_Bal
	   																													 );

     				Per_Accrual_Calc_Functions.Get_Net_Accrual (  P_Assignment_Id 					=>Assignment_Id_Bal
     																							 ,P_Plan_Id 							=>Accrual_Plan_Id_Bal
     																							 ,P_Payroll_Id 						=>Payroll_Id_Bal
     																							 ,P_Business_Group_Id 		=>Business_Group_Id_Bal
     																							 ,P_Assignment_Action_Id 	=>Assignment_Action_Id_Bal
     																							 ,P_Calculation_Date 			=>lvToDate
     																							 ,P_Accrual_Start_Date		=>lvFromDate
     																							 ,P_START_DATE 						=>lvDate1
     																							 ,P_END_DATE 							=>lvDate2
     																							 ,P_ACCRUAL_END_DATE 			=>lvDate3
     																						   ,P_ACCRUAL 							=>lvAccrual
     																							 ,P_NET_ENTITLEMENT 			=>lvNetEntitlement
     																							 );
     	End If;

     	LeaveBalance := lvNetEntitlement ;
     	CP_PERIOD := '('||Start_Date_Bal||' - '||lvToDate||')';
     	Return ( lvLeaveTaken );
end;

function cf_miscearningsformula(Assignment_Action_Id in number) return number is

Cursor Cur_Pay_Kr_Asg_Elements_V_E is
					Select	Amount
					From		Pay_Kr_Asg_Elements_V
					Where		Classification_Name = 'EARNINGS'
					And			Assignment_Action_Id = Assignment_Action_Id
					Order by	Processing_Priority desc;
lvResult_Value    					Pay_Kr_Asg_Elements_V.Amount%TYPE := 0;
lvMisc_Earnings							NUMBER := 0;
begin
			Open  Cur_Pay_Kr_Asg_Elements_V_E ;
			Loop
					Fetch 	Cur_Pay_Kr_Asg_Elements_V_E Into 		lvResult_Value ;
					Exit When Cur_Pay_Kr_Asg_Elements_V_E%NOTFOUND;

					If Cur_Pay_Kr_Asg_Elements_V_E%ROWCOUNT >10 Then
								lvMisc_Earnings := lvMisc_Earnings + lvResult_Value;
					End IF;
			End Loop;
			Close Cur_Pay_Kr_Asg_Elements_V_E ;

			Return ( lvMisc_Earnings );
End;

function cf_mischoursformula(Assignment_Action_Id in number) return number is

Cursor Cur_Pay_Kr_Asg_Elements_V_E is
					Select	Hours
					From		Pay_Kr_Asg_Elements_V
					Where		Classification_Name  = 'EARNINGS'
					And			Assignment_Action_Id = Assignment_Action_Id
					Order by	Processing_Priority desc;
lvResult_Value    					Pay_Kr_Asg_Elements_V.Amount%TYPE := 0;
lvMisc_Hours								NUMBER := 0;
begin
			Open  Cur_Pay_Kr_Asg_Elements_V_E ;
			Loop
					Fetch 	Cur_Pay_Kr_Asg_Elements_V_E Into 		lvResult_Value ;
					Exit When Cur_Pay_Kr_Asg_Elements_V_E%NOTFOUND;

					If Cur_Pay_Kr_Asg_Elements_V_E%ROWCOUNT >10 Then
								lvMisc_Hours := lvMisc_Hours + lvResult_Value;
					End IF;
			End Loop;
			Close Cur_Pay_Kr_Asg_Elements_V_E ;

			Return ( lvMisc_Hours );
End;

function cf_miscdeductionsformula(Assignment_Action_Id in number) return number is

Cursor Cur_Pay_Kr_Asg_Elements_V_D is
					Select	Amount
					From		Pay_Kr_Asg_Elements_V
					Where		Classification_Name  = 'DEDUCTIONS'
					And			Assignment_Action_Id = Assignment_Action_Id
					Order by	Processing_Priority desc;
lvResult_Value    					Pay_Kr_Asg_Elements_V.Amount%TYPE := 0;
lvMisc_Deductions						NUMBER := 0;
begin
			Open  Cur_Pay_Kr_Asg_Elements_V_D ;
			Loop
					Fetch 	Cur_Pay_Kr_Asg_Elements_V_D Into 		lvResult_Value ;
					Exit When Cur_Pay_Kr_Asg_Elements_V_D%NOTFOUND;

					If Cur_Pay_Kr_Asg_Elements_V_D%ROWCOUNT >10 Then
								lvMisc_Deductions := lvMisc_Deductions + lvResult_Value;
					End IF;
			End Loop;
			Close Cur_Pay_Kr_Asg_Elements_V_D ;

			Return ( lvMisc_Deductions );
End;

function AfterPForm return boolean is
begin
  return (TRUE);
end;

function CF_Effective_DateFormula return Date is

lv_Effective_Date					Pay_Payroll_Actions.Effective_Date%TYPE;
lv_Payroll_Name						Pay_PAyrolls_F.Payroll_Name%TYPE;
lv_RunType_Period					VARCHAR2(100);
lv_Bus_Place							hr_organization_information.Org_Information1%TYPE;
lv_Assignment_Number			Per_Assignments_F.Assignment_Number%TYPE;
lvnum											NUMBER;
lvmesg									  VARCHAR2(2000);
lvsort1                              VARCHAR2(50);
lvsort2                              VARCHAR2(50);
lvsort3                              VARCHAR2(50);
lvsort4                              VARCHAR2(50);
Cursor Cur_Pay_Payrolls_F is
						Select  Payroll_Name
						From		Pay_Payrolls_F
						Where		Payroll_Id = P_PAYROLL_ID;

Cursor Cur_Per_Assignments_F is
						Select	Assignment_Number
						From		Per_Assignments_F
						Where		Assignment_Id = P_ASSIGNMENT_ID;
begin


	Begin
		Open Cur_Pay_Payrolls_F;
		Fetch Cur_Pay_Payrolls_F Into lv_Payroll_Name;
		Close Cur_Pay_Payrolls_F;

		CP_Payroll_Name := lv_Payroll_Name;
	end;


	Begin
		Select	distinct Run_Type_Name||'-'||Period_Name||'-'||ppa.Payroll_Action_Id
		Into		lv_RunType_Period
 		From		Pay_Payroll_Actions	ppa
 						,Pay_Assignment_Actions paa
 						,Pay_Run_Types_F prt
 						,Per_Time_Periods ptp
 						,Pay_Payroll_Actions rppa
 						,Pay_Assignment_Actions rpaa
 						,Pay_Action_Interlocks pai
    Where		ppa.Payroll_Action_Id = P_TIME_PERIOD_ID     And			rppa.Payroll_Id				= P_PAYROLL_ID
    And			ppa.Payroll_Action_Id = paa.Payroll_Action_Id
    And			ppa.action_type IN ('U','P')
    And			ppa.action_status = 'C'
    And			rppa.Payroll_Action_Id = rpaa.Payroll_Action_Id
    And			rppa.action_type IN ('R','Q')
    And			rppa.action_status = 'C'
    And			pai.Locking_Action_Id = paa.Assignment_Action_Id
    And			pai.Locked_Action_Id  = rpaa.Assignment_Action_Id
    And			rpaa.Run_Type_Id = prt.Run_Type_Id
    And			pai.Locked_Action_Id = ( Select max(Locked_Action_Id) Locked_Action_Id
 							 From		Pay_Action_Interlocks ai
							where    ai.Locking_Action_Id = pai.Locking_Action_Id )
    And			rppa.Payroll_Id = ptp.Payroll_Id
    And			rppa.Effective_Date		Between	ptp.Start_Date
    															And			ptp.End_Date
    And			rppa.Effective_Date		Between prt.Effective_Start_Date
    															And			prt.Effective_End_Date	;


    CP_RunType_Period :=   lv_RunType_Period;
	Exception
		When Others Then
				CP_RunType_Period := null;
  End;


	Begin
		Select	Org_Information1
		Into		lv_Bus_Place
		From		hr_organization_information
		Where		org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
		And			Organization_Id = P_ESTABLISHMENT_ID;

		CP_Bus_Place := lv_Bus_Place;
	Exception
		When Others Then
			 CP_Bus_Place := NULL;
	End;


	Begin
		Open Cur_Per_Assignments_F;
		Fetch Cur_Per_Assignments_F Into lv_Assignment_Number;
		Close Cur_Per_Assignments_F;

	  CP_ASSIGN_NUM := lv_Assignment_Number;
	End;



	Begin
		Select count(*)
		Into   lvnum
		From ( Select distinct paa.Run_Type_Id
					 From 	Pay_Assignment_Actions paa
					 				,Pay_Action_Interlocks pai
					 				,Pay_Payroll_Actions   pa
					 				,Pay_Assignment_Actions aa
					 Where	pa.Payroll_Action_Id = aa.Payroll_Action_Id
					 And		pa.Action_Type IN ('P','U')
					 And		pai.Locked_Action_Id = paa.Assignment_Action_Id
					 And		pai.Locking_Action_Id = aa.Assignment_Action_Id
					 And		paa.Run_Type_Id IS NOT NULL
					 And		pa.Payroll_Action_Id =  P_TIME_PERIOD_ID );

    If 	lvnum > 1 Then
    	FND_MESSAGE.SET_NAME('PAY','PAY_KR_RUN_TYPE_WARNING_MESG');
    	lvmesg := FND_MESSAGE.GET;
    	CP_Warning_Message := 'Warning :'||lvmesg;
    Else
    	CP_Warning_Message := NULL ;
    End If;
	End;

        Begin
             If P_SORT_ORDER_1 = 'FULL_NAME' Then
                lvsort1 := 'Full Name';
             Elsif P_SORT_ORDER_1 = 'ESTABLISHMENT_ID' Then
                lvsort1 := 'Business Place';
             End If;

             If P_SORT_ORDER_2 = 'FULL_NAME' Then
                lvsort2 := ',Full Name';
             Elsif P_SORT_ORDER_2 = 'ESTABLISHMENT_ID' Then
                lvsort2 := ',Business Place';
             End If;



            CP_SORT_OPTION := lvsort1||lvsort2;


        Exception
            When Others Then
              CP_SORT_OPTION := null;
        End;



	Begin
  	Select	Effective_Date
  	Into		lv_Effective_Date
  	From		Pay_Payroll_Actions
  	Where		Payroll_Action_Id = P_TIME_PERIOD_ID;
	  return ( lv_Effective_Date );
	Exception
		When Others Then
					Return null;
	End;

end;

function cf_messageflagformula(Payroll_Action_Id_Payroll in number) return number is

lvFlagNum			NUMBER := 0;
begin
  Select	decode(Pay_Advice_Message,null,0,1)
  Into		lvFlagNum
  From    Pay_Payroll_Actions
  Where   Payroll_Action_Id = Payroll_Action_Id_Payroll;

  return ( lvFlagNum );
exception
	When Others Then
			lvFlagNum := 0;
			return ( lvFlagNum );
end;

--Functions to refer Oracle report placeholders--

 Function LeaveBalance_p return number is
	Begin
	 return LeaveBalance;
	 END;
 Function CP_PERIOD_p return varchar2 is
	Begin
	 return CP_PERIOD;
	 END;
 Function CP_Payroll_Name_p return varchar2 is
	Begin
	 return CP_Payroll_Name;
	 END;
 Function CP_RunType_Period_p return varchar2 is
	Begin
	 return CP_RunType_Period;
	 END;
 Function CP_BUS_PLACE_p return varchar2 is
	Begin
	 return CP_BUS_PLACE;
	 END;
 Function CP_Assign_Num_p return varchar2 is
	Begin
	 return CP_Assign_Num;
	 END;
 Function CP_Warning_Message_p return varchar2 is
	Begin
	 return CP_Warning_Message;
	 END;
 Function CP_SORT_OPTION_p return varchar2 is
	Begin
	 return CP_SORT_OPTION;
	 END;
END PAY_PAYKRSOE_XMLP_PKG ;

/
