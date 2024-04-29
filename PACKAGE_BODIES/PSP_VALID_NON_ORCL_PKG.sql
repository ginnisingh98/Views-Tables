--------------------------------------------------------
--  DDL for Package Body PSP_VALID_NON_ORCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_VALID_NON_ORCL_PKG" AS
 /* $Header: PSPNONB.pls 120.1.12000000.4 2007/02/22 14:30:38 spchakra noship $ */
  /**********************************************************************************
	-- Made modifications on May 18th, 1998
	RETURN CODES FROM EACH OF THE INDIVIDUAL VALIDATIONS MEAN THE FOLLOWING
		0 => Individual Validation was performed successfully (NO ERROR. Hence, No Error Code when this value is returned)
		1 => Invalid Payroll ID
		2 => Invalid Payroll Period ID
		3 => Invalid Assignment ID
		4 => Invalid Person ID
		5 => Invalid Effective Date (Effective Date does not occur within Time Period's Start and End Dates)
		6 => Invalid Sub Line Start Date (Sub Line Start Date does not occur within Time Period's Start and End Dates)
		7 => Invalid Sub Line End Date (Sub Line End Date does not occur within Time Period's Start and End Dates)
		8 => Sub Line Start Date is later than the Sub Line End Date
		9 => Invalid Payroll Source Code (Payroll Source Code does not occur in the PSP_LOOKUPS table)
		10 => Invalid Daily Rate (Daily Rate is greater than the pay amount)
		11 => Invalid Element Type ID
PRE_GEN		12 => Invalid Distribution Date
PRE_GEN		13 => Invalid GL_Code_Combination_ID
PRE_GEN		14 => Invalid Project ID
PRE_GEN		15 => Invalid Expenditure Organization ID
PRE_GEN		16 => Invalid Expenditure Type
PRE_GEN		17 => Invalid Task ID
PRE_GEN		18 => Invalid Award ID
PRE_GEN		19 => GL_Code_Combination_ID and Project ID cannot both exist for the same distribution line
PRE_GEN		20 => GL_Code_Combination_ID and Project ID fields are both empty for the same distribution line
NON_ORCL	21 => Invalid GL_Code_Combination ID value obtained for selected Payroll
PRE_GEN		22 => Invalid Costed GL_CCID (Costed GL_CCID is NULL)
NON_ORCL	23 => Set_Of_Books_ID from Profile does not match Set of Books ID in Payrolls table
  		24 => No Business Days in selected date range (Summarize and Transfer will fail)
                25 => Invalid Debit/Credit Flag
                26 => Sub-line start and end dates co-incide with the dates in another sub-line in batch in Payroll Interface
                27 => Sub-line start and end dates co-incide with dates in another sub-line in batch in Payroll Sub-lines table
NON_ORCL        28 => Pay Amount Not equal to Daily Rate * Business Days -- Added by Al on 02/16/99 for bug 707404
                29 => Invalid Sub Line Start Date (Sub Line Start Date does not occur within Assignment Start Date
			and End date)
                30 => Invalid Sub Line End Date (Sub Line End Date does not occur within Assignment Start and End                       Dates)

                 PSP_HR_SHARED profile is deleted since we will not be able to support in multi-org
		 Multi-org changes with addition of business group id and set of books id conditions -- vcirigir

  **********************************************************************************/
  Function Validate_Payroll_ID(v_Payroll_ID IN Number, v_Assignment_ID IN Number, v_Effective_Date IN Date,
				v_business_group_id IN NUMBER,v_set_of_books_id IN NUMBER) Return Number;
  Function Validate_Payroll_Period_ID(v_Payroll_ID IN Number, v_Payroll_Period_ID IN Number, v_Effective_Date IN Date,
				v_business_group_id IN NUMBER,v_set_of_books_id IN NUMBER) Return Number;
  Function Validate_Assignment_ID(v_Person_ID IN Number, v_Assignment_ID IN Number, v_Effective_Date IN Date,
			       	  v_business_group_id IN NUMBER,v_set_of_books_id IN NUMBER) Return Number;
  Function Validate_Person_ID(v_Person_ID IN Number, v_Effective_Date IN Date,v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER) Return Number;
  -- No need to validate Effective Dates anymore
  -- Function Validate_Effective_Date(v_Effective_Date IN Date, v_Payroll_ID IN number, v_Payroll_Period_ID IN number) return Number;
  Function Validate_Sub_Line_End_Date(v_Sub_Line_End_Date IN Date,v_Sub_Line_Start_Date IN Date,
					v_Payroll_ID IN Number,v_Payroll_Period_ID IN Number,
					v_Effective_Date IN Date, v_Assignment_id IN Number) Return Number;
  Function Validate_Sub_Line_Start_Date(v_Sub_Line_Start_Date IN Date, v_Sub_Line_End_Date IN Date,
			v_Payroll_ID IN number, v_Payroll_Period_ID IN number, v_Effective_Date IN Date,
			 v_Assignment_id IN Number) Return Number;
  Function Validate_Payroll_Source_Code(v_Payroll_Source_Code IN varchar2) Return Number;
  Function Validate_Daily_Rate(v_Pay_Amount IN Number, v_Daily_Rate IN Number, v_currency_code IN VARCHAR2) Return Number;
  Function Validate_Element_Type_ID(v_Element_Type_ID IN Number, v_Payroll_Period_ID IN Number,
					v_business_group_id	IN	NUMBER,	-- Introduced for bug 3098050
					v_set_of_books_id	IN	NUMBER,	-- Introduced for bug 3098050
				    v_currency_code   IN VARCHAR2 ) Return Number;

  -- introduced parameter v_currency_code for bug 2916848 for Ilo Enhancement in validate_element_type_id

  Time_Period_Start_Date Date;
  Time_Period_End_Date Date;
  Assignment_start_date DATE;
  Assignment_end_date   DATE;
  g_hire_zero_work_days CHAR(1)  := 'N';--Added for zero work days build.Bug 1994421.

  Procedure Obtain_Start_End_Dates_From_HR(v_Payroll_ID IN number, v_Payroll_Period_ID IN number,
						v_Effective_Date IN Date,v_Assignment_id IN NUMBER);
--  Function Validate_GL_CCID(v_Payroll_ID IN Number, v_Effective_Date IN DATE) return NUMBER;
  Function Find_DB_Error_Code(num_Err_Code Number) return varchar2;
  Function Validate_Sub_Line_Dates(v_Assignment_ID IN Number, v_Payroll_Period_ID IN Number,
		v_Element_Type_ID IN Number, v_Sub_Line_Start_Date Date, v_Sub_Line_End_Date Date,
				v_Batch_Name IN varchar2) return NUMBER;
Function Validate_Pay_Amount(v_Pay_Amount IN Number, v_Daily_Rate IN Number, v_Sub_Line_Start_Date Date,
				v_Sub_Line_End_Date Date,v_Assignment_ID Number, v_Effective_Date Date,
				v_precision  IN NUMBER,v_ext_precision IN NUMBER) return Number;

-- introduced v_precision parameter in validate_pay_amount for Bug 2916848

-- introduced v_precision,v_ext_precision,v_currency_code parameters for bug 2916848
  Procedure ALL_RECORDS(v_Batch_Name         IN VARCHAR2,
			v_business_group_id  IN NUMBER,
			v_set_of_books_id    IN NUMBER,
			v_precision	     IN NUMBER,
			v_ext_precision	     IN NUMBER,
			v_currency_code	     IN VARCHAR2) IS

	  cursor IMPORT_CURSOR is
	  Select	*
	  from	PSP_PAYROLL_INTERFACE
	  where BATCH_NAME = v_Batch_Name
	  and	STATUS_CODE <> 'T'
	  FOR UPDATE OF STATUS_CODE, ERROR_CODE;

	  retVal Number;
	  v_DB_Err_Code varchar2(10);
	  b_Records_Exist_In_Cursor BOOLEAN := FALSE;

  Begin

     Begin
          FND_STATS.Gather_Table_Stats(ownname => 'PSP',
				       tabname => 'PSP_PAYROLL_INTERFACE');

---				       percent => 10,
--				       tmode   => 'NORMAL');
--   Above two parameters commented out for bug fix 2463762

     Exception
          When others then
	     null;
     End;

	retVal := 0;
  	FOR IMPORT_CURSOR_Agg IN IMPORT_CURSOR LOOP

	 b_Records_Exist_In_Cursor := TRUE;

	  If retVal = 0 Then
	  Begin
		retVal := Validate_Person_ID(Import_Cursor_Agg.Person_ID, Import_cursor_Agg.EFFECTIVE_DATE,
					     v_business_group_id,v_set_of_books_id);

		If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	  End If;

 	  If retVal =0 Then
	  Begin
		retVal := Validate_Assignment_ID(Import_Cursor_Agg.Person_ID, Import_Cursor_Agg.Assignment_ID,
						Import_Cursor_Agg.Effective_Date,v_business_group_id,
						v_set_of_books_id);

	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
  	  End If;

	  If retVal =0 Then
	  Begin
		retVal := Validate_Payroll_ID(Import_Cursor_Agg.Payroll_ID, Import_Cursor_Agg.Assignment_ID,
						Import_Cursor_Agg.Effective_Date,v_business_group_id,v_set_of_books_id);
	  	If retVal <> 0 Then
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
	  	End If;
	  End;
          End If;

	  If retVal = 0 Then
	    Begin
		retVal := Validate_Payroll_Period_ID(Import_Cursor_Agg.Payroll_ID, Import_Cursor_Agg.Payroll_Period_ID,
							Import_Cursor_Agg.Effective_Date,v_business_group_id,
							v_set_of_books_id);

	  	If retVal = 0 Then
	  	  Null;
	  	Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
	  	End If;
	    End;
	End If;

	If retVal = 0 Then
	  Begin
		retVal := Validate_Sub_Line_End_Date(Import_Cursor_Agg.Sub_Line_End_Date,
				Import_Cursor_Agg.Sub_Line_Start_Date, Import_Cursor_Agg.Payroll_ID,
				Import_Cursor_Agg.Payroll_Period_ID, Import_Cursor_Agg.Effective_Date,
				Import_Cursor_Agg.Assignment_id);
	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;

	If retVal = 0 Then
	  Begin
		retVal := Validate_Sub_Line_Start_Date(Import_Cursor_Agg.Sub_Line_Start_Date,
				Import_Cursor_Agg.Sub_Line_End_Date, Import_Cursor_Agg.Payroll_ID,
				Import_Cursor_Agg.Payroll_Period_ID, Import_Cursor_Agg.Effective_Date,
				Import_Cursor_Agg.Assignment_id);

	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;

	If retVal = 0 Then
	  Begin
		retVal := Validate_Payroll_Source_Code(Import_Cursor_Agg.Payroll_Source_Code);
	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;

	If retVal = 0 Then
	  Begin
		retVal := Validate_Daily_Rate(Import_Cursor_Agg.Pay_Amount, Import_Cursor_Agg.Daily_Rate, Import_Cursor_Agg.currency_code);
	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;

        If retVal = 0 Then
          -- Need to validate Pay Amount
          -- Check if Pay Amount = Daily Rate * Num. of Business Days
          -- fnd_message.debug('Validating Pay Amount');
          Begin
                retVal := Validate_Pay_Amount(Import_Cursor_Agg.Pay_Amount, Import_Cursor_Agg.Daily_Rate,
				Import_Cursor_Agg.Sub_Line_Start_Date, Import_Cursor_Agg.Sub_Line_End_Date,
				Import_Cursor_Agg.Assignment_id,Import_Cursor_Agg.Effective_Date,
				v_precision,v_ext_precision);
                If retVal = 0 Then
                  Null;
                Else
                  v_DB_Err_Code := Find_DB_Error_Code(retVal);
                  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
                End If;
          End;
        End If;

	If retVal = 0 Then
	  Begin
	      retVal := Validate_Element_Type_ID(Import_Cursor_Agg.Element_Type_ID, Import_Cursor_Agg.Payroll_Period_ID,
						v_business_group_id, v_set_of_books_id,
						v_currency_code);
	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;

/********* Commented since GL_CCID is not being called**************
	If retVal = 0 Then
	  -- Need to check if a valid GL_Code_Combination_ID is to be obtained for selected payroll
	  Begin
		retVal := Validate_GL_CCID(Import_Cursor_Agg.Payroll_ID, Import_Cursor_Agg.Effective_Date);
	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;
************End Of Commenting*********************/

       If retVal = 0 Then
	  -- Need to check if there is atleast one business day in selected sub_line date range
	  Begin
        	If PSP_General.Business_Days(Import_Cursor_Agg.Sub_Line_Start_Date, Import_Cursor_Agg.Sub_Line_End_Date) = 0
                AND  g_hire_zero_work_days='N'  Then --Modified for zero work days build.Bug 1994421.
           		retVal := 24;
           	End If;

		If retVal = 0 Then
			Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
       End If;


	If retVal = 0 Then
	  Begin
		retVal := Validate_Sub_Line_Dates(Import_Cursor_Agg.Assignment_ID, Import_Cursor_Agg.Payroll_Period_ID,
				Import_Cursor_Agg.Element_Type_ID, Import_Cursor_Agg.Sub_Line_Start_Date,
				Import_Cursor_Agg.Sub_Line_End_Date, v_Batch_Name);

	 	If retVal = 0 Then
		  Null;
		Else
		  v_DB_Err_Code := Find_DB_Error_Code(retVal);
		  UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'E', ERROR_CODE = (v_DB_Err_Code) where CURRENT OF Import_Cursor;
		End If;
	  End;
	End If;
       If retVal <> 0 Then
		retVal := 0;
	Else
		UPDATE PSP_PAYROLL_INTERFACE Set STATUS_CODE = 'V', ERROR_CODE = '' where CURRENT OF Import_Cursor;
       End If;

       END LOOP;
       If b_Records_Exist_In_Cursor Then
	  COMMIT;
       End If;

  Exception
	when OTHERS Then
		null;
  End All_Records;

  Function Validate_Sub_Line_Dates(v_Assignment_ID IN Number, v_Payroll_Period_ID IN Number, v_Element_Type_ID IN Number,
				v_Sub_Line_Start_Date Date, v_Sub_Line_End_Date Date,
				v_Batch_Name IN varchar2) return NUMBER is

    v_Record_Count number:= 0;
  Begin

     -- This cursor checks if the current line's start and end date overlaps over any other line's dates for same
	-- time period, assignment, and element type in current batch in Interface table
	Select count(*)
	into v_Record_Count
	from PSP_PAYROLL_INTERFACE
	where Payroll_Period_ID = v_Payroll_Period_ID
	and   Assignment_ID = v_Assignment_ID
	and   Element_Type_ID = v_Element_Type_ID
	and   Batch_Name = v_Batch_Name
	and   ((Sub_Line_Start_Date Between v_Sub_Line_Start_Date and v_Sub_Line_End_Date)
	or    (Sub_Line_End_Date Between v_Sub_Line_Start_Date and v_Sub_Line_End_Date)
	or    (Sub_Line_Start_Date < v_Sub_Line_Start_Date and Sub_Line_End_Date > v_Sub_Line_End_Date));

	If v_Record_Count > 1 Then
	  return 26;  -- Error Message indicating that multiple records with overlapping dates exist in Interface table.
	End If;

	v_Record_Count := 0; -- Reset counter
/***********************************************************
	-- This cursor checks if the current line's start and end date overlaps over any other line's dates for same
		-- time period, assignment, and element type in PSP_Payroll_Sub_Lines table.
	Select count(*)
	into v_Record_Count
	from PSP_PAYROLL_LINES a,
	     PSP_PAYROLL_SUB_LINES b,
	     PSP_PAYROLL_CONTROLS c
	where a.PAYROLL_CONTROL_ID = c.PAYROLL_CONTROL_ID
	and   a.PAYROLL_LINE_ID = b.PAYROLL_LINE_ID
	and   c.TIME_PERIOD_ID = v_Payroll_Period_ID
	and   a.ASSIGNMENT_ID = v_Assignment_ID
	and   a.ELEMENT_TYPE_ID = v_Element_Type_ID
	and   ((b.Sub_Line_Start_Date Between v_Sub_Line_Start_Date and v_Sub_Line_End_Date)
	or    (b.Sub_Line_End_Date Between v_Sub_Line_Start_Date and v_Sub_Line_End_Date)
	or    (b.Sub_Line_Start_Date < v_Sub_Line_Start_Date and b.Sub_Line_End_Date > v_Sub_Line_End_Date));

	If v_Record_Count > 1 Then
	  return 27; -- Error Message indicating that multiple records with overlapping dates exist in Payroll Sub-lines.
	End If;
*****************************************************************/

	return 0;
  End Validate_Sub_Line_Dates;

  Function Validate_GL_CCID(v_Payroll_ID IN Number, v_Effective_Date IN DATE) return NUMBER is
	n_Set_Of_Books_ID Number;
	v_Set_Of_Books_ID varchar2(30);
	n_Cost_Allocation_KeyFlex_ID Number;
	n_GL_Code_Combination_ID Number;
  Begin
	/*************************************************************************
	--- We are no longer validating the GL CCID in the Validate Procedure. Instead, we will be checking for
	-- the GL CCID in the Import Sub-lines Process. Moreover the GLCCID will be obtained from
	-- PSP_Clearing_Account table. (Decided by Venkat in 07/1998)
	select 	a.GL_SET_OF_BOOKS_ID, Cost_Allocation_KeyFlex_ID
	into	n_Set_Of_Books_ID, n_Cost_Allocation_KeyFlex_ID
	from 	PAY_PAYROLLS_F a
	where	a.PAYROLL_ID = v_Payroll_ID
	and	v_Effective_Date BETWEEN a.EFFECTIVE_START_DATE AND a.EFFECTIVE_END_DATE;

	v_Set_Of_Books_ID := fnd_Profile.Value('PSP_SET_OF_BOOKS');

	If (v_Set_Of_Books_ID IS NULL) or (to_number(v_Set_Of_Books_ID) <> n_Set_Of_Books_ID) Then
		-- fnd_message.debug('Profile value for Set of Books ID :' || v_Set_Of_Books_ID || ' does not match
		-- 		value from PAY_PAYROLLS_F. Cannot proceed');
		return 23;
	End If;

	-- Obtain Cost Allocation Key Flex ID, GL_Code_Combination_ID, and Balance_Amount using
		-- 	Venkat's procedure

	PSP_General.get_GL_CCID(P_Payroll_ID => v_Payroll_ID, P_Set_Of_Books_ID => n_Set_Of_Books_ID,
		P_Cost_KeyFlex_ID => n_Cost_Allocation_KeyFlex_ID, x_GL_CCID => n_GL_Code_Combination_ID);
	If n_GL_Code_Combination_ID IS NULL or n_GL_Code_Combination_ID = 0 Then
		-- fnd_message.debug('GL Code Combination ID is invalid. Cannot proceed');
		return 21;
	End If;

	***************************************************************************/
	return 0;
  Exception
	when OTHERS Then
		return 21;
  End Validate_GL_CCID;

  Procedure Obtain_Start_End_Dates_From_HR(v_Payroll_ID IN number, v_Payroll_Period_ID IN number, v_Effective_Date IN Date,v_Assignment_id IN Number) is

 -- This cursor is added to check for subline start date to be greater than or equal to the hiredate of the person
   /* The following cursor is added to replace the select statement to get assignment dates.
      Bug 1994421 "Zero Work Days build */
        CURSOR assignment_date_cur IS
   	SELECT  min(effective_start_date), max(effective_end_date)
        FROM    PER_ALL_ASSIGNMENTS_F
	WHERE   assignment_id = v_assignment_id
	AND 	assignment_type ='E'; --Added for bug 2624259


Begin
	select 	a.Start_Date, a.End_Date
	into 	Time_Period_Start_Date, Time_Period_End_Date
	from 	PER_TIME_PERIODS a
	where 	a.Time_Period_ID = v_Payroll_Period_ID
	and	a.PAYROLL_ID = v_Payroll_ID
	and	(v_Effective_Date BETWEEN a.Start_Date AND a.End_Date);

  -- This query is added to check for subline start date to be greater than or equal to the hiredate of the person

/*  The following code is commented for bug 1994421,"Zero Work days build " */
/*      select min(a.effective_start_date),max(a.effective_end_date)
        into   assignment_start_date,assignment_end_date
        from   PER_ALL_ASSIGNMENTS_F a
        where  a.assignment_id = v_Assignment_id
        and    assignment_status_type_id IN (select distinct assignment_status_type_id
                                                from per_assignment_status_types
                                                where per_system_status = 'ACTIVE_ASSIGN') */

/* The following code is added to get assignment dates. Bug 1994421 "Zero Work Days build */
        OPEN assignment_date_cur;
        FETCH assignment_date_cur into assignment_start_date,assignment_end_date;
        CLOSE assignment_date_cur;

  End Obtain_Start_End_Dates_From_HR;

  Function Validate_Payroll_ID(v_Payroll_ID IN Number, v_Assignment_ID IN Number,
				v_Effective_Date IN Date, v_business_group_id IN NUMBER,
				v_set_of_books_id IN NUMBER) Return Number IS
   v_local_number Number;
  Begin
	If v_Payroll_ID is NULL Then
		return 1;
	ELSE
/*****	Modifed the following SELECT for 11510_CU2 consolidated performance fixes.
	  Select DISTINCT a.payroll_id
	  into v_local_number
	  from pay_payrolls_f a, per_assignments_f b
	  where a.payroll_id = b.payroll_id
	  and a.PAYROLL_ID = v_Payroll_ID
	  and b.assignment_id = v_assignment_id
	  and (v_effective_date between a.effective_start_date and a.effective_end_date)
          and a.business_group_id = v_business_group_id
	  and a.gl_set_of_books_id = v_set_of_books_id;
	End of comment for 11510_CU2 consolidated performance fixes.	*****/

--	Introduced the following for 11510_CU2 conslodated fixes.
	SELECT	a.payroll_id
	INTO	v_local_number
	FROM	pay_payrolls_f a
	WHERE	a.payroll_id = v_payroll_id
	AND	(v_effective_date between a.effective_start_date and a.effective_end_date)
	AND	a.business_group_id = v_business_group_id
	AND	a.gl_set_of_books_id = v_set_of_books_id
	AND	EXISTS	(SELECT	1
			FROM	per_assignments_f b
			WHERE	b.payroll_id = a.payroll_id
			AND	b.assignment_id = v_assignment_id
			AND	v_effective_date BETWEEN b.effective_start_date AND b.effective_end_date);
--	End of changes for 11510_CU2 conslodated fixes.

	End If;

	Return 0;
  Exception
	WHEN NO_DATA_FOUND THEN
	  Return 1;
	WHEN TOO_MANY_ROWS THEN
	  Return 0;
	WHEN OTHERS THEN
	  Return 1;
  End Validate_Payroll_ID;

  Function Validate_Payroll_Period_ID(v_Payroll_ID IN number, v_Payroll_Period_ID IN number, v_Effective_Date IN Date,
					v_business_group_id IN NUMBER,v_set_of_books_id IN NUMBER)
					return NUMBER IS
   v_local_number Number;
   v_Cost_Allocation_KeyFlex_ID Number;
   v_GL_CCID Number;
  Begin

	If v_Payroll_Period_ID IS NULL Then
		return 2;
	End If;

	Select Time_Period_id
	into v_local_number
	From Per_Time_Periods
	where Payroll_id = v_Payroll_ID
	and Time_Period_ID = v_Payroll_Period_ID
	and (v_Effective_Date between start_date and end_date);


	Select Cost_Allocation_KeyFlex_ID
	into v_Cost_Allocation_Keyflex_ID
	from PAY_PAYROLLS_F
	where Payroll_ID = v_Payroll_Id
	and v_Effective_Date between Effective_Start_Date and Effective_End_Date
	and business_group_id  = v_business_group_id
	and gl_set_of_books_id = v_set_of_books_id;

	PSP_General.get_GL_CCID(P_Payroll_ID => v_Payroll_ID, P_Set_Of_Books_ID => v_Set_Of_Books_ID,
		P_Cost_KeyFlex_ID => v_Cost_Allocation_KeyFlex_ID, x_GL_CCID => v_GL_CCID);

	If v_GL_CCID = 0 Then
		return 21;
	End If;

	Return 0;
  Exception
	when no_data_found then
	  Return 2;
	when TOO_MANY_ROWS Then
	  Return 0;
	when OTHERS then
	  Return 2;
  End Validate_Payroll_Period_ID;

  Function Validate_Assignment_ID(v_Person_ID IN Number, v_Assignment_ID IN Number, v_Effective_Date IN Date,
					v_business_group_id IN NUMBER,v_set_of_books_id IN NUMBER) Return Number IS
   v_local_number Number;
  Begin
	If v_Assignment_ID IS Null Then
		Return 3;
	End If;

	Select a.assignment_id
	into v_local_number
	from per_assignments_f a ,
	     pay_payrolls_f b
	where a.person_id = v_person_id
        AND   a.assignment_type ='E' --Added for bug 2624259.
	and a.assignment_id = v_Assignment_ID
	and (v_effective_date between a.effective_start_date and a.effective_end_date)
        and a.business_group_id = v_business_group_id
        and b.gl_set_of_books_id   = v_set_of_books_id
        and a.payroll_id = b.payroll_id;

	return 0;
  Exception
	when no_data_found then
	  Return 3;
	when TOO_MANY_ROWS Then
	  Return 0;
	when OTHERS then
	  Return 3;
  End Validate_Assignment_ID;

  Function Validate_Person_ID(v_Person_ID IN Number, v_Effective_Date IN Date,
			      v_business_group_id  IN NUMBER,v_set_of_books_id IN NUMBER)
				Return Number IS
   v_local_number Number;
/* Following cursor is added to replace the select statement to get person_id.
   Bug 1994421 "Zero Work Days Build" */
/*****	Modified the following cursor for R12 performance fixes (bug 4507892)
   CURSOR Valid_person_cur IS
   SELECT a.person_id
   FROM	  Per_People_F a
   WHERE  a.Person_ID 	= v_person_id
--   AND	  a.current_employee_flag ='Y'   --Added for bug 2624259. Commented for Bug 3424494
   AND    (v_effective_date BETWEEN a.EFFECTIVE_START_DATE and a.EFFECTIVE_END_DATE)
   AND	  v_effective_date <= (SELECT	 max(b.effective_end_date)
  	  FROM	per_assignments_f b,pay_payrolls_f f
          WHERE	 a.person_id = b.person_id
          AND    b.assignment_type ='E'  --Added for bug 2624259.
	  AND  	 b.business_group_id = v_business_group_id
          AND    f.gl_set_of_books_id = v_set_of_books_id
          AND    f.payroll_id = b.payroll_id) ;
	End of comment for bug fix 4507892	*****/

--	New cursor definition for R12 performance fix (4507892)
CURSOR	valid_person_cur IS
SELECT	ppf.person_id
FROM	per_people_f ppf
WHERE	ppf.person_id = v_person_id
AND	(v_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date)
AND	v_effective_date <=	(SELECT	MAX(paf.effective_end_date)
				FROM	 per_assignments_f  paf,
			 		pay_payrolls_f ppf2
				WHERE	paf.person_id = v_person_id
				AND	paf.business_group_id = v_business_group_id
				AND	ppf2.payroll_id = paf.payroll_id
				AND	paf.assignment_type ='E'
				AND	ppf2.gl_set_of_books_id  = v_set_of_books_id);
  Begin
	If v_Person_ID IS Null Then
	  Return 4;
	End If;

/* Commented for bug no 1994421,"Zero Work Days Build"*/
/*	Select a.person_id
	into v_local_number
	from Per_People_F a
	where a.Person_ID = v_Person_ID
	and (v_effective_date BETWEEN a.EFFECTIVE_START_DATE and A.EFFECTIVE_END_DATE)
        and     a.business_group_id = v_business_group_id
        and   a.person_id in ( select distinct person_id
                               from   per_assignments_f f,pay_payrolls_f b
                               where  (v_effective_date between f.effective_start_date and f.effective_end_date)
			       and    f.business_group_id = v_business_group_id
                               and    b.gl_set_of_books_id = v_set_of_books_id
                               and    f.payroll_id = b.payroll_id )
        and    a.current_employee_flag = 'Y';   */
--Added following code to get person_id into v_local_number.Bug 1994421,"Zero Work Days Build".
       OPEN Valid_person_cur;
       FETCH Valid_Person_cur into v_local_number;
       CLOSE Valid_Person_cur;

     /* Following added for bug 2624259 */
	IF v_local_number IS NULL THEN
	  Return 4;
	END IF ;

/*****************************************************************************
-- Commented out the foll. lines of code bcos of performance issues. (AL comm.
-- the lines on 12/09/98)
	and 	a.Person_ID in
		(select distinct Person_ID
		from 	per_assignments_f
		where 	(v_Effective_Date between per_assignments_f.effective_start_date
				and per_assignments_f.effective_end_date));
****************************************************************************/
	return 0;
  Exception
	when no_data_found then
	  Return 4;
	when too_many_rows then
	 Return 0;
	when OTHERS then
	  Return 4;
  End Validate_Person_ID;

  Function Validate_Sub_Line_Start_Date(v_Sub_Line_Start_Date IN Date, v_Sub_Line_End_Date IN Date, v_Payroll_ID IN number, v_Payroll_Period_ID IN number, v_Effective_Date IN Date,v_Assignment_id IN Number) Return Number IS
   v_Local_Date Date;
  Begin

	If v_Sub_Line_Start_Date IS NULL Then
	  return 6;
	End If;

	If v_Sub_Line_End_Date IS NOT NULL Then
	  If v_Sub_Line_Start_Date > v_Sub_Line_End_Date Then
		return 8;
	  End If;
	End If;

	Obtain_Start_End_Dates_From_HR(v_Payroll_ID, v_Payroll_Period_ID, v_Effective_Date,v_Assignment_id);
	If ((v_Sub_Line_Start_Date >= Time_Period_Start_Date) AND (v_Sub_Line_Start_Date <= Time_Period_End_Date)) AND (v_sub_line_start_date >= Assignment_start_date) Then
	  return 0;
	Else
               if (v_sub_line_start_date < Assignment_start_date) then
                  return 29;
               elsif (v_sub_line_start_date < Time_Period_Start_Date) then  --Added for bug 1994421."Zero work days"
		  return 31;						    --Added for bug 1994421."Zero work days"
                else
                  return 6;
                end if;
	End If;

  End Validate_Sub_Line_Start_Date;

  Function Validate_Sub_Line_End_Date(v_Sub_Line_End_Date IN Date, v_Sub_Line_Start_Date IN Date, v_Payroll_ID IN Number, v_Payroll_Period_ID IN Number, v_Effective_Date IN Date,v_Assignment_id IN Number) Return Number IS
   v_Local_Date Date;
  Begin

	If v_Sub_Line_End_Date IS NULL Then
	  return 7;
	End If;

	If v_Sub_Line_Start_date IS NOT NULL Then
		If v_Sub_Line_End_Date < v_Sub_Line_Start_Date Then
		  return 8;
		End If;
	End If;

	Obtain_Start_End_Dates_From_HR(v_Payroll_ID, v_Payroll_Period_ID, v_Effective_Date,v_Assignment_id);
	If ((v_Sub_Line_End_Date >= Time_Period_Start_Date) AND (v_Sub_Line_End_Date <= Time_Period_End_Date))
	 	AND (v_sub_line_end_date <= assignment_end_date) Then
	  return 0;
        Else
            if (v_sub_line_end_date > Assignment_end_date) then
  	        return 30;
 	   elsif (v_sub_line_end_date > Time_Period_End_Date) then  -- Added for bug 1994421."Zero work days build"
                 return 32;					    -- Added for bug 1994421."Zero work days build"
            else
                 return 7;
             end if;
        end if;

  End Validate_Sub_Line_End_Date;

  Function Validate_Payroll_Source_Code(v_Payroll_Source_Code IN varchar2) Return Number IS
   v_local_char varchar2(30);
  Begin
	If v_Payroll_Source_Code IS Null Then
	   Return 9;
	End If;

	select 	a.source_code
	into	v_local_char
	from 	psp_payroll_sources a
	where 	a.source_type = 'N'
	and	a.source_code = v_Payroll_Source_Code;

	/****************************
	Select 	DISTINCT LOOKUP_CODE into v_local_char from PSP_LOOKUPS
	where	LOOKUP_CODE = v_Payroll_Source_Code
	and	LOOKUP_TYPE = 'PAYROLL_SOURCES'
	and 	LOOKUP_CODE NOT IN ('PSP','LDM');
	***************************/
	return 0;

  Exception
	when no_data_found then
	  Return 9;
	when too_many_rows then
	 Return 0;
	when OTHERS then
	  Return 9;
  End Validate_Payroll_Source_Code;

  Function Validate_Daily_Rate(v_Pay_Amount IN Number, v_Daily_Rate IN Number, v_currency_code IN Varchar2)
           Return Number IS
  Begin
	If (abs(v_Pay_Amount) < abs(v_Daily_Rate)) or (v_Pay_Amount IS Null) or (v_Daily_Rate IS Null) Then
	  Return 10;
	End If;

	IF (v_currency_code = 'STAT') AND ((v_daily_rate < -24) OR (v_daily_rate > 24)) THEN
	  Return 10;
	END IF;

	Return 0;
  End Validate_Daily_Rate;

-- Introduced v_currency_code variable for Bug 2916848 Ilo Enhancement

  Function Validate_Element_Type_ID(v_Element_Type_ID IN Number, v_Payroll_Period_ID IN Number,
					v_business_group_id	IN	NUMBER,
					v_set_of_books_id	IN	NUMBER,
				    v_currency_code   IN Varchar2) Return Number IS
	v_local_number NUMBER;
  Begin

/*   commented the following code to agument Element check based on currency
     for Bug 2916848 Ilo Enhancement

	Select a.element_type_id
	into v_local_number
	from psp_element_types a, pay_element_types_f b, per_time_periods c
	where a.element_type_id = b.element_type_id
	and a.element_type_id = v_Element_Type_ID
	and c.time_period_id = v_payroll_period_id
	and ((c.start_date between a.start_date_active and a.end_date_active)
  		or (c.end_date between a.start_date_active and a.end_date_active)
  		or ((a.start_date_active < c.start_date) and (a.end_date_active > c.end_date)))
        and b.output_currency_code = v_currency_code;
*/ -- End of Commenting

/* Introduced the following check for element_type_id for Bug 2916848 Ilo Enhancement */

	SELECT  a.element_type_id
	INTO 	v_local_number
	FROM	PSP_ELEMENT_TYPES a,
		PER_TIME_PERIODS  b
	WHERE	a.element_type_id = v_element_type_id
	AND	b.time_period_id  = v_payroll_period_id
--	Introduced BG/SOB check on psp_element_types for bug fix 3098050
	AND	a.business_group_id = v_business_group_id
	AND	a.set_of_books_id = v_set_of_books_id
	AND 	b.start_date <= a.end_date_active
	AND	b.end_date >= a.start_date_active
	AND	exists
		(SELECT 1
		 FROM	PAY_ELEMENT_TYPES_F pef
		 WHERE	pef.element_type_id = a.element_type_id
		 AND 	(	pef.output_currency_code = v_currency_code
			OR	v_currency_code = 'STAT')
		 AND	pef.effective_end_date >= a.start_date_active
		 AND	pef.effective_start_date <= a.end_date_active
		);

	return 0;

  Exception
	when no_data_found then
	  Return 11;
	when too_many_rows then
	 Return 0;
	when OTHERS then
	  Return 11;

  End Validate_Element_Type_ID;

/* Added new parameters v_assignment_id,v_effective_date for bug 1004421 */
-- Adding new parameter v_precision,v_ext_precision for ILO enhancement Bug 2916848

  Function Validate_Pay_Amount(v_Pay_Amount IN Number, v_Daily_Rate IN Number, v_Sub_Line_Start_Date Date,
				v_Sub_Line_End_Date Date, v_assignment_id Number,v_effective_date date,
				v_precision	IN NUMBER,v_ext_precision  IN NUMBER) return Number is

        n_Business_Days Number;
  Begin
/*  The following code is added for bug 1994421 ."Zero work days build"*/
    n_Business_Days := PSP_General.Business_Days(v_Sub_Line_Start_Date, v_Sub_Line_End_Date, v_assignment_id);

    IF n_Business_Days=0 and v_sub_line_start_date=v_effective_date THEN
         g_hire_zero_work_days:='Y';
         IF v_sub_line_start_date<>v_sub_line_end_date THEN
             return 34;
         END IF;

         IF v_Pay_Amount <> v_Daily_Rate THEN
             return 33;
         END IF;  -- End of Modification for bug 1994421."Zero work days build".

    ELSE
    	IF   ROUND(v_Pay_Amount,v_precision) <> ROUND((ROUND(v_Daily_Rate,v_ext_precision)* n_Business_Days),
	v_precision)
	Then

	-- Changed the precision from 2 to the v_precision for Bug 2916848
        -- fnd_message.debug('Please ensure that Pay Amount equals Daily Rate times num. of business days.');
            return 28;
    	End If;
    END IF ;
    return 0;

  Exception
    when OTHERS then
        return 28;

  End Validate_Pay_Amount;

  Function Find_DB_Error_Code(num_Err_Code Number) return varchar2 is
  Begin
	If num_Err_Code is NULL or num_Err_Code = 0 Then
		return NULL;
	End If;

	If num_Err_Code = 1 Then
		return 'INV_PID';
	elsif num_Err_Code = 2 Then
		return 'INV_TPI';
	elsif num_Err_Code = 3 Then
		return 'INV_ASG';
	elsif num_Err_Code = 4 Then
		return 'INV_PER';
	elsif num_Err_Code = 5 Then
		return 'INV_EFF';
	elsif num_Err_Code = 6 Then
		return 'INV_STD';
	elsif num_Err_Code = 7 Then
		return 'INV_END';
	elsif num_Err_Code = 8 Then
		return 'ST_END';
	elsif num_Err_Code = 9 Then
		return 'INV_SRC';
	elsif num_Err_Code = 10 Then
		return 'INV_DLY';
	elsif num_Err_Code = 11 Then
		return 'INV_ELE';
	elsif num_Err_Code = 12 Then
		return 'INV_DIS';
	elsif num_Err_Code = 13 Then
		return 'INV_GLC';
	elsif num_Err_Code = 14 Then
		return 'INV_PRI';
	elsif num_Err_Code = 15 Then
		return 'INV_EOI';
	elsif num_Err_Code = 16 Then
		return 'INV_ET';
	elsif num_Err_Code = 17 Then
		return 'INV_TI';
	elsif num_Err_Code = 18 Then
		return 'INV_AI';
	elsif num_Err_Code = 19 Then
		return 'NOT_GLP';
	elsif num_Err_Code = 20 Then
		return 'NUL_GLP';
	elsif num_Err_Code = 21 Then
		return 'INV_GL2';
	elsif num_Err_Code = 22 Then
		return 'INV_COS';
	elsif num_Err_Code = 23 Then
		return 'SOB_PRO';
	elsif num_Err_Code = 24 Then
		return 'NUL_BUS';
	elsif num_Err_Code = 25 Then
		return 'INV_D_C';
	elsif num_Err_Code = 26 Then
		return 'OVLP_DT1';
/*********************************
	elsif num_Err_Code = 27 Then
		return 'OVLP_DT2';
**********************************/
        elsif num_Err_Code = 28 Then
                return 'INV_PAY';
        elsif num_Err_Code = 29 Then
                return 'INV_ASDT';
        elsif num_Err_Code = 30 Then
                return 'INV_AEDT';
        elsif num_Err_Code = 31 Then --Added for bug 1994421."Zero work days build".
                return 'INV_PSDT';
	elsif num_Err_Code = 32 Then --Added for bug 1994421."Zero work days build".
                return 'INV_PEDT';
	elsif num_Err_Code = 33 Then --Added for bug 1994421."Zero work days build".
                return 'INV_PAY1';
	elsif num_Err_Code = 34 Then --Added for bug 1994421."Zero work days build".
                return 'INV_SUDT';

	else
		return NULL;
	End If;
  End Find_DB_Error_Code;

END;

/
