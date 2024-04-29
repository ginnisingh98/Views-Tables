--------------------------------------------------------
--  DDL for Package Body PA_RPT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RPT_UTILS" AS
/* $Header: PARPUTLB.pls 115.2 99/09/30 14:20:13 porting shi $ */

----------------------------
--  PROCEDURES AND FUNCTIONS
--
--
--  1. Procedure Name:	DISCOVERER_INIT
--  	Usage:		Populates data in tables : PA_PROJ_RPT_ATTRIBS_TEMP
--                      Reads the profiles for the responsibility,
--                      and accordingly creates records.
Procedure DISCOVERER_INIT
IS
BEGIN
NULL;
END Discoverer_Init;

-----------------------------------------------------------------------
-- 2.  Function Name:   PROJECT_RPT_CLASS
--     Usage:           Returns the Class_Code assigned to the project
--                      for the given Class_Category.
Function PROJECT_RPT_CLASS ( x_Project_ID Number,
                             x_Class_Category Varchar2 )
Return Varchar2
IS
x_class_code PA_Class_Codes.Class_Code%type;

Begin
   Select P.Class_Code
   Into   x_class_code
   From   PA_Project_Classes P
   Where  P.Project_id = x_Project_ID
   And    P.Class_Category = x_Class_Category;

   Return x_class_code;
Exception
   WHEN NO_DATA_FOUND Then
	Return Unassigned_txt;
End Project_Rpt_Class;

------------------------------------------------------------------------
-- 3.  Function Name:   PROJECT_RPT_KEYMEMBER
--     Usage:           Returns the Key member assigned to the project
--                      for the given Project Role Type.
Function PROJECT_RPT_KEYMEMBER ( x_Project_ID Number,
                                 x_Project_Role_Type Varchar2 )
Return Varchar2
IS
x_person Per_People_F.Full_Name%type;

Begin
   Select P.Full_Name
   Into   x_person
   From
          PER_People_F P,
          PA_Project_Players PP
   Where
          P.Person_ID = PP.Person_ID
   And    PP.Project_ID = x_Project_ID
   And    PP.Project_Role_Type = x_Project_Role_Type
   And    PP.Start_date_active <= PA_Start_Date
   And    nvl(PP.End_date_active,PA_End_Date) >= PA_End_Date
   And    rownum < 2;

   Return x_person;
Exception
   WHEN NO_DATA_FOUND Then
        Return Unassigned_txt;
End Project_Rpt_KeyMember;
-------------------------------------------------------------------------
-- 4.  Function Name:    GET_RPT_CLASS_CATEGORY
--     Usage:            Returns the reporting class category attributes
--                       Returns the corresponding value.
--     Parameters:       x_number = 1,2,or 3.
Function GET_RPT_CLASS_CATEGORY ( x_number Number )
Return Varchar2
IS
Begin
   IF x_number = 1 then
      Return Class_category1;
   Elsif x_number = 2 then
      Return Class_Category2;
   Elsif x_number = 3 then
      Return Class_category3;
   Else Return Null;
   End if;

End Get_Rpt_Class_Category;

-------------------------------------------------------------------------
-- 5.  Function Name:    GET_RPT_ROLE_TYPE
--     Usage:            Returns the reporting project role type attributes
--                       Returns the corresponding value.
--     Parameters:       x_number = 1,2,or 3.
Function GET_RPT_ROLE_TYPE ( x_number Number )
Return Varchar2
IS
Begin
   IF x_number = 1 then
      Return Role_type1;
   Elsif x_number = 2 then
      Return Role_type2;
   Elsif x_number = 3 then
      Return Role_type3;
   Else Return Null;
   End if;

End Get_Rpt_Role_type;

-------------------------------------------------------------------------
-- 6.  Function Name:    GET_RPT_BUDGET_TYPE
--     Usage:            Returns the reporting budget type attributes
--                       Returns the corresponding value.
--     PARAMETERS:       x_type = C: Cost R: Revenue
--                       x_number = 1 or 2.
Function GET_RPT_BUDGET_TYPE ( x_type varchar2,
                             x_number Number )
Return Varchar2
IS
Begin
   IF x_type = 'C' then
      IF x_number = 1 then
         Return Cost_Budget_typeCode1;
      Elsif x_number = 2 then
         Return Cost_Budget_TypeCode2;
      Else Return NULL;
      End if;
   Elsif x_type = 'R' then
      IF x_number = 1 then
         Return Revenue_Budget_typeCode1;
      Elsif x_number = 2 then
         Return Revenue_Budget_TypeCode2;
      Else Return NULL;
      End if;
   End if;
End Get_RPT_Budget_Type;

-------------------------------------------------------------------------
Begin
      cost_budget_typecode1 := fnd_profile.value('PA_RPT_BUDGET_TYPE1_COST');
      cost_budget_typecode2 := fnd_profile.value('PA_RPT_BUDGET_TYPE2_COST');
      revenue_budget_typecode1 := fnd_profile.value('PA_RPT_BUDGET_TYPE3_REV');
      revenue_budget_typecode2 := fnd_profile.value('PA_RPT_BUDGET_TYPE4_REV');
      role_type1 := fnd_profile.value('PA_RPT_PROJ_ROLE_TYPE1');
      role_type2 := fnd_profile.value('PA_RPT_PROJ_ROLE_TYPE2');
      role_type3 := fnd_profile.value('PA_RPT_PROJ_ROLE_TYPE3');
      class_category1 := fnd_profile.value('PA_RPT_CLASS_CATEGORY1');
      class_category2 := fnd_profile.value('PA_RPT_CLASS_CATEGORY2');
      class_category3 := fnd_profile.value('PA_RPT_CLASS_CATEGORY3');
      Unassigned_txt  := fnd_message.get_string('PA',
                                                'PA_BIS_PAPFPJCL_UNASSIGNED');

      Select Start_date, End_date
      Into PA_Start_Date, PA_End_Date
      From PA_Periods
      Where Current_pa_period_flag = 'Y';

END PA_RPT_UTILS;

/
