--------------------------------------------------------
--  DDL for Package Body PSP_ORG_DLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ORG_DLS_PKG" AS
  /* $Header: PSPLSDLB.pls 120.1 2006/11/07 06:08:58 tbalacha noship $ */
  -- Package level variable
  p_Batch_Sequence_number Number;

  /***************************************************************************************************/
  -- PRIVATE PROCEDURE AND FUNCTION DEFINITIONS
  Function Process_Assgn_Level_Schedule(l_Time_Period_Start DATE, l_Time_Period_End DATE,
	l_Assignment_ID Number, l_Element_Type_ID Number,l_AS_Period1_Start IN OUT NOCOPY DATE,
	l_AS_Period1_End IN OUT NOCOPY DATE, l_AS_Period2_Start IN OUT NOCOPY DATE, l_AS_Period2_End IN OUT NOCOPY DATE) 	return NUMBER;

  Function Process_Element_Group_Schedule(l_Time_Period_Start DATE, l_Time_Period_End DATE,
	l_Assignment_ID Number, l_Element_Type_ID Number,l_EG_Period1_Start IN OUT NOCOPY DATE,
	l_EG_Period1_End IN OUT NOCOPY DATE, l_EG_Period2_Start IN OUT NOCOPY DATE, l_EG_Period2_End IN OUT NOCOPY DATE)
	return NUMBER;

  Function Process_Glob_Elem_Schedule(l_Assignment_ID Number, l_Element_Type_ID Number,
			l_Time_Period_Start DATE, l_Time_Period_End DATE,
			l_GE_Period1_Start IN OUT NOCOPY DATE, l_GE_Period1_End IN OUT NOCOPY DATE,
			l_GE_Period2_Start IN OUT NOCOPY DATE, l_GE_Period2_End IN OUT NOCOPY DATE) return NUMBER;

  PROCEDURE Calculate_Split_Periods(l_Assignment_Id Number, l_Schedule_Begin_Date DATE, l_Schedule_End_Date DATE ,
	l_Time_Period_Start DATE, l_Time_Period_End DATE, l_Period1_Start IN OUT NOCOPY DATE, l_Period1_End IN OUT NOCOPY
	DATE, l_Period2_Start IN OUT NOCOPY DATE, l_Period2_End IN OUT NOCOPY DATE);

  PROCEDURE Get_Split_Before(l_Assignment_id Number, l_Schedule_begin_date DATE, l_schedule_end_date DATE,
            l_Time_period_Start DATE, l_Time_Period_End DATE, l_Period1_start IN OUT NOCOPY DATE,
            l_Period1_End IN OUT NOCOPY DATE);

  PROCEDURE Get_Split_After(l_Assignment_Id Number, l_Schedule_begin_date DATE, l_schedule_end_date DATE,
            l_Time_Period_Start DATE, l_Time_Period_End DATE,
            l_Period2_Start IN OUT NOCOPY DATE, l_Period2_End IN OUT NOCOPY DATE);

  PROCEDURE Table_Insert(Organization_ID Number, Element_Type_ID Number DEFAULT NULL, Person_ID Number,
	Assignment_ID Number, Begin_Date Date, End_Date Date, Original_Sch_Code Varchar2,
	Schedule_Line_ID Number);

  PROCEDURE Process_All_ET_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE);
  PROCEDURE Process_All_EG_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE);
  PROCEDURE Process_All_ASSGN_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE);
  PROCEDURE Add_If_Within_DLS(v_Organization_ID Number, v_Begin_Date DATE,
	v_End_Date DATE, v_Assignment_ID Number, v_Person_ID Number, v_Element_Type_ID Number,
	v_Original_Sch_Code varchar2, v_Schedule_Line_ID Number);
  /***************************************************************************************************/

  Function Insert_Records_To_Table(p_template_id number, p_start_date DATE,p_end_date DATE,p_set_of_books_id number,p_business_group_id  number) return NUMBER IS

	l_cur_handle1 	INTEGER;
	l_total_rows  INTEGER		:= 0;

	l_Assignment_ID NUMBER(22,2)	:= 0;
	l_Organization_ID Number(22,2) 	:= 0;
	l_Person_ID Number(22,0)	:= 0;
	l_Element_Type_ID Number(22,0)	DEFAULT NULL;
  	l_Schedule_Begin_Date DATE;
	l_Schedule_End_Date DATE;
	l_Time_Period_Start_Date DATE;
	l_Time_Period_End_Date DATE;

	v_Assgn_List_To_Add varchar2(200);

	v_Scheduling_type_code varchar2(2);
	b_Goto_Next_Assignment boolean;
	b_Goto_NExt_Element_Type boolean;

	l_organization_str     Varchar2(2000);
	l_org_count Number;



	cursor Org_count  is
        select count(1)
	from   psp_report_template_details
        Where template_id = p_template_id
        and CRITERIA_LOOKUP_TYPE = 'PSP_SELECTION_CRITERIA'
        and CRITERIA_LOOKUP_CODE = 'ORG';

	retVal Number := 0;



  Begin
	--Resetting the Batch Sequence Number
	p_Batch_Sequence_Number := NULL;

	g_element_type_id_str := '( Select DISTINCT a.ELEMENT_TYPE_ID
                                   from PSP_ELEMENT_TYPES a, PAY_ELEMENT_TYPES_F b
                                   where a.ELEMENT_TYPE_ID = b.ELEMENT_TYPE_ID
                                   AND a.business_group_id = ' || p_business_group_id || '
                                   AND a.set_of_books_id = ' || p_set_of_books_id || ')' ;




/*******************************************************************************************************
First, need to check if the assignments from the selected organizations exist in the PSP_SCHEDULES table.
If they do not, then, we need to add these assignments to the report to be displayed.
This is pretty straight-forward. If they do, then, we need to proceed to the next step.
*******************************************************************************************************/
	-- First, obtain the Start and End Dates for assignments not existing in
	-- PSP_SCHEDULE_HIERARCHY=>  Time Period Begin and End Dates
	/* For bug
	Select 	Start_Date, End_Date
	into	l_Time_Period_Start_Date, l_Time_Period_End_Date
	from	PER_TIME_PERIODS
	whee	Time_Period_ID = v_Time_Period_ID; */

        l_Time_Period_Start_Date := p_start_date ;
        l_Time_Period_End_Date := p_end_date;

        If (p_template_id is null ) Then

	 g_organization_str := ' 1 = 1 ' ;

	Else
          Open Org_count;
          Fetch Org_count into l_org_count;
          Close Org_count;

	  If l_org_count<> 0 then

	    g_organization_str := ' a.Organization_id in (select to_number(criteria_value1)
	                                                  from psp_report_template_details
							  where template_id = '|| p_template_id  || '
							  and   CRITERIA_LOOKUP_TYPE = ''PSP_SELECTION_CRITERIA''
                                                          and   CRITERIA_LOOKUP_CODE = ''ORG'' ) ' ;


	  else

	    g_organization_str := ' 1 = 1 ' ;

	  end if ;

	End If;




--	dbms_output.put_line('start date is ' || to_char(l_Time_Period_Start_Date));

	l_Cur_Handle1 := dbms_sql.open_cursor;

--dbms_output.put_line('tried opening cursor,....valueis ' || to_char(l_Cur_Handle1));

	dbms_sql.parse(l_cur_handle1,  	'Select DISTINCT a.Assignment_ID ASSIGNMENT_ID,
			a.Organization_ID ORGANIZATION_ID,
			a.Person_ID PERSON_ID
			from	PER_ASSIGNMENTS_F  a
			where	' || g_organization_str || '
			and     a.business_group_id = '|| p_business_group_id ||'
			and     a.payroll_id in ( select payroll_id from
		        pay_payrolls_f where gl_set_of_books_id = '|| p_set_of_books_id || ')
			and	( :p_end_date  between a.EFFECTIVE_START_DATE
				and a.EFFECTIVE_END_DATE)
				and     Not(Exists(Select ''X''
                                from PSP_SCHEDULE_HIERARCHY SCHI
                                ,PSP_SCHEDULE_LINES SCHL
			where SCHI.Assignment_ID = a.ASSIGNMENT_ID
      			and SCHI.SCHEDULE_HIERARCHY_ID = SCHL.SCHEDULE_HIERARCHY_ID
      and ((SCHL.SCHEDULE_BEGIN_DATE between :p_start_date  and  :p_end_date )
      or (SCHL.SCHEDULE_END_DATE between :p_start_date  and  :p_end_date )
      or (SCHL.SCHEDULE_BEGIN_DATE <= :p_start_date and SCHL.SCHEDULE_END_DATE
      >= :p_end_date ))))', dbms_sql.V7);

     dbms_sql.bind_variable(l_cur_handle1, ':p_start_date', p_start_date);
     dbms_sql.bind_variable(l_cur_handle1, ':p_end_date', p_end_date);

	dbms_sql.define_column(l_cur_handle1, 1, l_Assignment_ID);
	dbms_sql.define_column(l_cur_handle1, 2, l_Organization_ID);
	dbms_sql.define_column(l_cur_handle1, 3, l_Person_ID);

	l_total_rows := dbms_sql.execute(l_cur_handle1);
        while dbms_sql.fetch_rows(l_cur_handle1) > 0
    	LOOP
      		dbms_sql.column_value(l_cur_handle1, 1, l_Assignment_ID);
		dbms_sql.column_value(l_cur_handle1, 2, l_Organization_ID);
		dbms_sql.column_value(l_cur_handle1, 3, l_Person_ID);
		-- Obtain the Part of Period1 that is covered by a PSP
		-- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
		-- table
		Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
			v_Begin_Date => l_Time_Period_Start_Date, v_End_Date => l_Time_Period_End_Date,
			v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
			v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'O',
			v_Schedule_Line_ID => '');
		 --dbms_output.put_line('After calling the Table_Insert Procedure');
	END LOOP;
	 --dbms_output.put_line('Have to insert Assignments : ' || v_Assgn_List_To_Add || ' to Report');

    	dbms_sql.close_cursor(l_cur_handle1);

	/*******************************************************************************************************
		Next, we need to check if all assignments that have scheduling code of 'ET', have schedule begin
		and end dates that fully encapsulate the selected time period. If they do, then, we NEED NOT
		display these assignments.
		If they do not, then we should obtain the time periods that are not covered and proceed to the
		next step (viz Check if the periods are covered by Element Group schedules and Assignment Level
		Schedules).
	*******************************************************************************************************/
		Process_All_ET_Schedules(p_template_id , p_start_date ,p_end_date);
		 --dbms_output.put_line('Successfully processed ET Schedules');

	/*******************************************************************************************************
		Next, we need to check if all assignments that have scheduling code of 'EG', have schedule begin
		and end dates that fully encapsulate the selected time period. If they do, then, we NEED NOT
		display these assignments.
		If they do not, then we should obtain the time periods that are not covered and proceed to the
		next step (viz Check if the periods are covered by Assignment Level Schedules).
	*******************************************************************************************************/
		Process_All_EG_Schedules(p_template_id , p_start_date ,p_end_date);
		-- dbms_output.put_line('Successfully processed EG Schedules');

	/*******************************************************************************************************
		Finally, we need to check if all assignments that have scheduling code of 'AS', have schedule
		begin and end dates that fully encapsulate the selected time period. If they do, then, we NEED
		NOT display these assignments.
		If they do not, then we should display these records.
	*******************************************************************************************************/
		Process_All_ASSGN_Schedules(p_template_id , p_start_date ,p_end_date);
		 --dbms_output.put_line('Successfully processed ASSGN Schedules..p_batch seq is ' || to_char(p_Batch_Sequence_Number));

        	return p_Batch_Sequence_Number;

  Exception
	when OTHERS Then
		--dbms_output.put_line('ERROR ENCOUNTERED WHILE PROCESSING PACKAGE:' || sqlerrm);
		return 0;

  End Insert_Records_To_Table;

  Procedure Process_All_ASSGN_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE) IS
 	l_cur_handle  	INTEGER ;
	l_total_rows  INTEGER		:= 0;

	l_Assignment_ID NUMBER(22,2)	:= 0;
	l_Organization_ID Number(22,2) 	:= 0;
	l_Person_ID Number(22,0)	:= 0;
	l_Element_Type_ID Number(22,0)	:= 0;
  	l_Schedule_Begin_Date DATE;
	l_Schedule_End_Date DATE;
	l_Time_Period_Start_Date DATE;
	l_Time_Period_End_Date DATE;
	l_Schedule_Line_ID Number(22,0) := 0;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'GLOBAL ELEMENT LEVEL SCHEDULES'
	l_GE_Period1_Start Date;
	l_GE_Period1_End Date;
	l_GE_Period2_Start Date;
	l_GE_Period2_End Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ASSIGNMENT LEVEL SCHEDULES'
	l_AS_Period1_Start Date;
	l_AS_Period1_End Date;
	l_AS_Period2_Start Date;
	l_AS_Period2_End Date;

	v_Assgn_List_To_Add varchar2(200);

	v_Scheduling_type_code varchar2(2);
	b_Goto_Next_Assignment boolean;
	b_Goto_NExt_Element_Type boolean;
	retVal Number := 0;
  Begin


        l_cur_handle := dbms_sql.open_cursor;
	-- dbms_output.put_line('About to parse Assignment Level SQL');
        dbms_sql.parse(l_cur_handle,	'SELECT DISTINCT a.ASSIGNMENT_ID ASSIGNMENT_ID,
						a.ORGANIZATION_ID ORGANIZATION_ID,
						b.PERSON_ID PERSON_ID,
						c.ELEMENT_TYPE_ID ELEMENT_TYPE_ID,
						d.SCHEDULE_LINE_ID SCHEDULE_LINE_ID,
						d.SCHEDULE_BEGIN_DATE SCHEDULE_BEGIN_DATE,
						d.SCHEDULE_END_DATE SCHEDULE_END_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_start_date) ||''')  TIME_PERIOD_START_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_end_date) ||''')  TIME_PERIOD_END_DATE
					from 	PER_ASSIGNMENTS_F a,
						PSP_SCHEDULES b,
						PSP_SCHEDULE_HIERARCHY c,
						PSP_SCHEDULE_LINES d,
						PSP_DEFAULT_LABOR_SCHEDULES f
					where	a.ASSIGNMENT_ID = b.ASSIGNMENT_ID
					and	b.ASSIGNMENT_ID = c.ASSIGNMENT_ID
					and	c.SCHEDULE_HIERARCHY_ID = d.SCHEDULE_HIERARCHY_ID
					and 	NOT(d.SCHEDULE_BEGIN_DATE <= :p_start_date   AND
							d.SCHEDULE_END_DATE >=  :p_end_date )
                                        and     NOT(d.SCHEDULE_BEGIN_DATE > :p_end_date   OR
                                                    d.SCHEDULE_END_DATE < :p_start_date )
					and	(:p_end_date   BETWEEN a.EFFECTIVE_START_DATE and
							a.EFFECTIVE_END_DATE)
					and	c.SCHEDULING_TYPES_CODE = ''A''
					and	a.ORGANIZATION_ID = f.ORGANIZATION_ID
					and	(:p_start_date   >= f.SCHEDULE_BEGIN_DATE
						or :p_end_date   <= f.SCHEDULE_END_DATE
						or ( :p_start_date  <= f.SCHEDULE_BEGIN_DATE and
							:p_END_DATE  >= f.SCHEDULE_END_DATE))
					and	' || g_organization_str ,
			dbms_sql.V7);
     dbms_sql.bind_variable(l_cur_handle, ':p_start_date', p_start_date);
      dbms_sql.bind_variable(l_cur_handle, ':p_end_date', p_end_date);


	-- dbms_output.put_line('About to define numeric columns.');
	dbms_sql.define_column(l_cur_handle, 1, l_Assignment_ID);
	dbms_sql.define_column(l_cur_handle, 2, l_Organization_ID);
	dbms_sql.define_column(l_cur_handle, 3, l_Person_ID);
	dbms_sql.define_column(l_cur_handle, 4, l_Element_Type_ID);
	dbms_sql.define_column(l_cur_handle, 5, l_Schedule_Line_ID);

	-- dbms_output.put_line('About to define Date columns.');
	dbms_sql.define_column(l_cur_handle, 6, l_Schedule_Begin_Date);
	dbms_sql.define_column(l_cur_handle, 7, l_Schedule_End_Date);
	dbms_sql.define_column(l_cur_handle, 8, l_Time_Period_Start_Date);
	dbms_sql.define_column(l_cur_handle, 9, l_Time_Period_End_Date);

	l_total_rows := dbms_sql.execute(l_cur_handle);
        while dbms_sql.fetch_rows(l_cur_handle) > 0
    	LOOP
		-- dbms_output.put_line('Inside loop of Assignment Level Schedules');
      		dbms_sql.column_value(l_cur_handle, 1, l_Assignment_ID);
      		dbms_sql.column_value(l_cur_handle, 2, l_Organization_ID);
      		dbms_sql.column_value(l_cur_handle, 3, l_Person_ID);
      		dbms_sql.column_value(l_cur_handle, 4, l_Element_Type_ID);
      		dbms_sql.column_value(l_cur_handle, 5, l_Schedule_Line_ID);
      		dbms_sql.column_value(l_cur_handle, 6, l_Schedule_Begin_Date);
      		dbms_sql.column_value(l_cur_handle, 7, l_Schedule_End_Date);
		dbms_sql.column_value(l_cur_handle, 8, l_Time_Period_Start_Date);
		dbms_sql.column_value(l_cur_handle, 9, l_Time_Period_End_Date);


		retVal := Process_Glob_Elem_Schedule(l_Assignment_ID, l_Element_Type_ID,
			l_Time_Period_Start_Date, l_Time_Period_End_Date, l_GE_Period1_Start,
			l_GE_Period1_End, l_GE_Period2_Start, l_GE_Period2_End);

		If l_GE_Period1_Start IS NOT NULL Then

		  -- dbms_output.put_line('Before Calculating Split Periods for Assignment Level
		  -- Schedules');
		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period1_Start, l_GE_Period1_End, l_AS_Period1_Start,
			l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);

		  If l_AS_Period1_Start IS NOT NULL then
			-- Obtain the Part of Period1 that is covered by a PSP
			-- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
			-- table
			Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
				v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
				v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
				v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'A',
				v_Schedule_Line_ID => l_Schedule_Line_ID);
			-- dbms_output.put_line('After calling the Table_Insert Procedure');
		  End If;

		  If l_AS_Period2_Start IS NOT NULL then
			-- Obtain the Part of Period1 that is covered by a PSP
			-- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
			-- table
			Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
				v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
				v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
				v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'A',
				v_Schedule_Line_ID => l_Schedule_Line_ID);
			-- dbms_output.put_line('After calling the Table_Insert Procedure');
		  End If;
		End If;

		If l_GE_Period2_Start IS NOT NULL Then

		  -- dbms_output.put_line('Before Calculating Split Periods for Assignment Level
		  -- Schedules');
		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period2_Start, l_GE_Period2_End, l_AS_Period1_Start,
			l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);

		  If l_AS_Period1_Start IS NOT NULL then
			-- Obtain the Part of Period1 that is covered by a PSP
			-- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
			-- table
			Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
				v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
				v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
				v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'A',
				v_Schedule_Line_ID => l_Schedule_Line_ID);
			 --dbms_output.put_line('After calling the Table_Insert Procedure');
		  End If;

		  If l_AS_Period2_Start IS NOT NULL then
			-- Obtain the Part of Period1 that is covered by a PSP
			-- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
			-- table
			Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
				v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
				v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
				v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'A',
				v_Schedule_Line_ID => l_Schedule_Line_ID);
			 --dbms_output.put_line('After calling the Table_Insert Procedure');
		  End If;
	   	End If;

	END LOOP;

  End Process_All_ASSGN_Schedules;

  Procedure Process_All_EG_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE) IS
 	l_cur_handle  	INTEGER ;
	l_total_rows  INTEGER		:= 0;

	l_Assignment_ID NUMBER(22,2)	:= 0;
	l_Organization_ID Number(22,2) 	:= 0;
	l_Person_ID Number(22,0)	:= 0;
	l_Element_Type_ID Number(22,0)	:= 0;
  	l_Schedule_Begin_Date DATE;
	l_Schedule_End_Date DATE;
	l_Time_Period_Start_Date DATE;
	l_Time_Period_End_Date DATE;
	l_Schedule_Line_ID Number(22,0) := 0;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'GLOBAL ELEMENT LEVEL SCHEDULES'
	l_GE_Period1_Start Date;
	l_GE_Period1_End Date;
	l_GE_Period2_Start Date;
	l_GE_Period2_End Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ELEMENT_GROUP LEVEL SCHEDULES'
	l_EG_Period1_Start Date;
	l_EG_Period1_End Date;
	l_EG_Period2_Start Date;
	l_EG_Period2_End Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ASSIGNMENT LEVEL SCHEDULES'
	l_AS_Period1_Start Date;
	l_AS_Period1_End Date;
	l_AS_Period2_Start Date;
	l_AS_Period2_End Date;

	v_Assgn_List_To_Add varchar2(200);

	v_Scheduling_type_code varchar2(2);
	b_Goto_Next_Assignment boolean;
	b_Goto_NExt_Element_Type boolean;
	retVal Number := 0;
  Begin
        l_cur_handle := dbms_sql.open_cursor;
        dbms_sql.parse(l_cur_handle,	'SELECT DISTINCT a.ASSIGNMENT_ID ASSIGNMENT_ID,
						a.ORGANIZATION_ID ORGANIZATION_ID,
						b.PERSON_ID PERSON_ID,
						f.ELEMENT_TYPE_ID ELEMENT_TYPE_ID,
						d.SCHEDULE_LINE_ID SCHEDULE_LINE_ID,
						d.SCHEDULE_BEGIN_DATE SCHEDULE_BEGIN_DATE,
						d.SCHEDULE_END_DATE SCHEDULE_END_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_start_date) ||''') TIME_PERIOD_START_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_end_date) ||''') 	TIME_PERIOD_END_DATE
					from 	PER_ASSIGNMENTS_F a,
						PSP_SCHEDULES b,
						PSP_SCHEDULE_HIERARCHY c,
						PSP_SCHEDULE_LINES d,
						PSP_GROUP_ELEMENT_LIST f,
						PSP_DEFAULT_LABOR_SCHEDULES g
					where	a.ASSIGNMENT_ID = b.ASSIGNMENT_ID
					and	b.ASSIGNMENT_ID = c.ASSIGNMENT_ID
					and	c.SCHEDULE_HIERARCHY_ID = d.SCHEDULE_HIERARCHY_ID
					and	f.ELEMENT_GROUP_ID = c.ELEMENT_GROUP_ID
					and 	NOT(d.SCHEDULE_BEGIN_DATE <= :p_start_date AND
						 d.SCHEDULE_END_DATE >= :p_end_date )
                                        and     NOT(d.SCHEDULE_BEGIN_DATE > :p_end_date OR
                                                   d.SCHEDULE_END_DATE < :p_start_date )
					and	(:p_end_date   BETWEEN a.EFFECTIVE_START_DATE and
							a.EFFECTIVE_END_DATE)
					and	c.SCHEDULING_TYPES_CODE = ''EG''
					and     f.ELEMENT_GROUP_ID IN (Select Distinct
							PGEL.ELEMENT_GROUP_ID
							from    PSP_GROUP_ELEMENT_LIST PGEL,
                       						PSP_ELEMENT_GROUPS PEG
         						where   PGEL.Element_Type_ID IN ' ||
								g_element_type_id_str || '
        						and     PGEL.Element_Group_ID =
								PEG.Element_Group_ID)
					and	a.ORGANIZATION_ID = g.ORGANIZATION_ID
					and	f.ELEMENT_TYPE_ID IN ' || g_element_type_id_str || '
					and	(:p_start_date   >= g.SCHEDULE_BEGIN_DATE
						or :p_end_date  <= g.SCHEDULE_END_DATE
						or (:p_start_date  <= g.SCHEDULE_BEGIN_DATE and
							:p_end_date   >= g.SCHEDULE_END_DATE))
					and	 ' || g_organization_str,
			 dbms_sql.V7);

        dbms_sql.bind_variable(l_cur_handle, ':p_start_date', p_start_date);
        dbms_sql.bind_variable(l_cur_handle, ':p_end_date', p_end_date);

	-- dbms_output.put_line('About to define numeric columns.');
	dbms_sql.define_column(l_cur_handle, 1, l_Assignment_ID);
	dbms_sql.define_column(l_cur_handle, 2, l_Organization_ID);
	dbms_sql.define_column(l_cur_handle, 3, l_Person_ID);
	dbms_sql.define_column(l_cur_handle, 4, l_Element_Type_ID);
	dbms_sql.define_column(l_cur_handle, 5, l_Schedule_Line_ID);

	-- dbms_output.put_line('About to define Date columns.');
	dbms_sql.define_column(l_cur_handle, 6, l_Schedule_Begin_Date);
	dbms_sql.define_column(l_cur_handle, 7, l_Schedule_End_Date);
	dbms_sql.define_column(l_cur_handle, 8, l_Time_Period_Start_Date);
	dbms_sql.define_column(l_cur_handle, 9, l_Time_Period_End_Date);

	l_total_rows := dbms_sql.execute(l_cur_handle);
        while dbms_sql.fetch_rows(l_cur_handle) > 0
    	LOOP
		-- dbms_output.put_line('Inside Loop of Element Group Schedules');
      		dbms_sql.column_value(l_cur_handle, 1, l_Assignment_ID);
      		dbms_sql.column_value(l_cur_handle, 2, l_Organization_ID);
      		dbms_sql.column_value(l_cur_handle, 3, l_Person_ID);
      		dbms_sql.column_value(l_cur_handle, 4, l_Element_Type_ID);
      		dbms_sql.column_value(l_cur_handle, 5, l_Schedule_Line_ID);
      		dbms_sql.column_value(l_cur_handle, 6, l_Schedule_Begin_Date);
      		dbms_sql.column_value(l_cur_handle, 7, l_Schedule_End_Date);
		dbms_sql.column_value(l_cur_handle, 8, l_Time_Period_Start_Date);
		dbms_sql.column_value(l_cur_handle, 9, l_Time_Period_End_Date);

		retVal := Process_Glob_Elem_Schedule(l_Assignment_ID, l_Element_Type_ID,
			l_Time_Period_Start_Date, l_Time_Period_End_Date, l_GE_Period1_Start,
			l_GE_Period1_End, l_GE_Period2_Start, l_GE_Period2_End);

		If l_GE_Period1_Start IS NOT NULL Then


		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period1_Start, l_GE_Period1_End, l_EG_Period1_Start,
			l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);

		  If l_EG_Period1_Start IS NOT NULL Then
			-- Period1 is not encompassed in Element Group schedule. So, do assignment level
			-- schedule check
			retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start, l_EG_Period1_End,
					l_Assignment_ID, l_Element_Type_ID, l_AS_Period1_Start,
					l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);
			If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

			If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

		  End If;

		  If l_EG_Period2_Start IS NOT NULL Then
			-- Period2 is not encompassed in Element Group Schedule. So, do assignment level
			-- schedule check
			retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start, l_EG_Period2_End,
					l_Assignment_ID, l_Element_Type_ID, l_AS_Period1_Start,
					l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);
			If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

			If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;
		  End If;
		End If;

		If l_GE_Period2_Start IS NOT NULL Then


		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period2_Start, l_GE_Period2_End, l_EG_Period1_Start,
			l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);

		  If l_EG_Period1_Start IS NOT NULL Then
			-- Period1 is not encompassed in Element Group schedule. So, do assignment level
			-- schedule check
			retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start, l_EG_Period1_End,
					l_Assignment_ID, l_Element_Type_ID, l_AS_Period1_Start,
					l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);
			If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

			If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

		  End If;

		  If l_EG_Period2_Start IS NOT NULL Then
			-- Period2 is not encompassed in Element Group Schedule. So, do assignment level
			-- schedule check
			retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start, l_EG_Period2_End,
					l_Assignment_ID, l_Element_Type_ID, l_AS_Period1_Start,
					l_AS_Period1_End, l_AS_Period2_Start, l_AS_Period2_End);
			If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;

			If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'EG',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
			End If;
		  End If;
		End If;


	END LOOP;
  End Process_All_EG_Schedules;

  Procedure Process_All_ET_Schedules(p_template_id number, p_start_date DATE,p_end_date DATE) IS
 	l_cur_handle  	INTEGER ;
	l_total_rows  INTEGER		:= 0;

	l_Assignment_ID NUMBER(22,2)	:= 0;
	l_Organization_ID Number(22,2) 	:= 0;
	l_Person_ID Number(22,0)	:= 0;
	l_Element_Type_ID Number(22,0)	:= 0;
  	l_Schedule_Begin_Date DATE;
	l_Schedule_End_Date DATE;
	l_Time_Period_Start_Date DATE;
	l_Time_Period_End_Date DATE;
	l_Schedule_Line_ID Number(22,0) := 0;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'GLOBAL ELEMENT LEVEL SCHEDULES'
	l_GE_Period1_Start Date;
	l_GE_Period1_End Date;
	l_GE_Period2_Start Date;
	l_GE_Period2_End Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ELEMENT_TYPE LEVEL SCHEDULES'
	l_Period1_Start Date;
	l_Period1_End	Date;
	l_Period2_Start Date;
	l_Period2_End	Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ELEMENT_GROUP LEVEL SCHEDULES'
	l_EG_Period1_Start Date;
	l_EG_Period1_End Date;
	l_EG_Period2_Start Date;
	l_EG_Period2_End Date;

	-- Variables used to store the start and the end dates of two possible periods
	-- (Period1 => Before the Selected Time Period Start Date,
	--	Period2 => After the Selected Time Period End Date) for 'ASSIGNMENT LEVEL SCHEDULES'
	l_AS_Period1_Start Date;
	l_AS_Period1_End Date;
	l_AS_Period2_Start Date;
	l_AS_Period2_End Date;

	v_Assgn_List_To_Add varchar2(200);

	v_Scheduling_type_code varchar2(2);
	b_Goto_Next_Assignment boolean;
	b_Goto_NExt_Element_Type boolean;
	retVal Number := 0;
  Begin
        l_cur_handle := dbms_sql.open_cursor;
        dbms_sql.parse(l_cur_handle,	'SELECT DISTINCT a.ASSIGNMENT_ID ASSIGNMENT_ID,
						a.ORGANIZATION_ID ORGANIZATION_ID,
						b.PERSON_ID PERSON_ID,
						c.ELEMENT_TYPE_ID ELEMENT_TYPE_ID,
						d.SCHEDULE_LINE_ID SCHEDULE_LINE_ID,
						d.SCHEDULE_BEGIN_DATE SCHEDULE_BEGIN_DATE,
						d.SCHEDULE_END_DATE SCHEDULE_END_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_start_date) ||''')	TIME_PERIOD_START_DATE,
						fnd_date.canonical_to_date('''|| fnd_date.date_to_canonical(p_end_date) ||''')	TIME_PERIOD_END_DATE
					from 	PER_ASSIGNMENTS_F a,
						PSP_SCHEDULES b,
						PSP_SCHEDULE_HIERARCHY c,
						PSP_SCHEDULE_LINES d,
						PSP_DEFAULT_LABOR_SCHEDULES f
					where	a.ASSIGNMENT_ID = b.ASSIGNMENT_ID
					and	b.ASSIGNMENT_ID = c.ASSIGNMENT_ID
					and	c.SCHEDULE_HIERARCHY_ID = d.SCHEDULE_HIERARCHY_ID
					and 	NOT(d.SCHEDULE_BEGIN_DATE <= :p_start_date  AND
						d.SCHEDULE_END_DATE >=  :p_end_date )
                                        and     NOT(d.SCHEDULE_BEGIN_DATE > :p_end_date  OR
                                                    d.SCHEDULE_END_DATE <  :p_start_date )
					and	( :p_end_date BETWEEN a.EFFECTIVE_START_DATE and
							a.EFFECTIVE_END_DATE)
					and	c.SCHEDULING_TYPES_CODE = ''ET''
					and	 ' || g_organization_str || '
					and	a.ORGANIZATION_ID = f.ORGANIZATION_ID
					and	( :p_start_date  >= f.SCHEDULE_BEGIN_DATE
						or :p_end_date  <= f.SCHEDULE_END_DATE
						or ( :p_start_date  <= f.SCHEDULE_BEGIN_DATE and
							:p_end_date  >= f.SCHEDULE_END_DATE))
					and	c.ELEMENT_TYPE_ID IN ' || g_element_type_id_str,
			dbms_sql.V7);

         dbms_sql.bind_variable(l_cur_handle, ':p_start_date', p_start_date);
         dbms_sql.bind_variable(l_cur_handle, ':p_end_date', p_end_date);

	 --dbms_output.put_line('About to define numeric columns.');
	dbms_sql.define_column(l_cur_handle, 1, l_Assignment_ID);
	dbms_sql.define_column(l_cur_handle, 2, l_Organization_ID);
	dbms_sql.define_column(l_cur_handle, 3, l_Person_ID);
	dbms_sql.define_column(l_cur_handle, 4, l_Element_Type_ID);
	dbms_sql.define_column(l_cur_handle, 5, l_Schedule_Line_ID);

	-- dbms_output.put_line('About to define Date columns.');
			 --dbms_output.put_line('After calling the Table_Insert Procedure');
	dbms_sql.define_column(l_cur_handle, 6, l_Schedule_Begin_Date);
	dbms_sql.define_column(l_cur_handle, 7, l_Schedule_End_Date);
	dbms_sql.define_column(l_cur_handle, 8, l_Time_Period_Start_Date);
	dbms_sql.define_column(l_cur_handle, 9, l_Time_Period_End_Date);

	l_total_rows := dbms_sql.execute(l_cur_handle);
        while dbms_sql.fetch_rows(l_cur_handle) > 0
    	LOOP
		-- dbms_output.put_line('Inside Loop of ET Schedules');
      		dbms_sql.column_value(l_cur_handle, 1, l_Assignment_ID);
      		dbms_sql.column_value(l_cur_handle, 2, l_Organization_ID);
      		dbms_sql.column_value(l_cur_handle, 3, l_Person_ID);
      		dbms_sql.column_value(l_cur_handle, 4, l_Element_Type_ID);
      		dbms_sql.column_value(l_cur_handle, 5, l_Schedule_Line_ID);
      		dbms_sql.column_value(l_cur_handle, 6, l_Schedule_Begin_Date);
      		dbms_sql.column_value(l_cur_handle, 7, l_Schedule_End_Date);
		dbms_sql.column_value(l_cur_handle, 8, l_Time_Period_Start_Date);
		dbms_sql.column_value(l_cur_handle, 9, l_Time_Period_End_Date);

		retVal := Process_Glob_Elem_Schedule(l_Assignment_ID, l_Element_Type_ID,
			l_Time_Period_Start_Date, l_Time_Period_End_Date, l_GE_Period1_Start,
			l_GE_Period1_End, l_GE_Period2_Start, l_GE_Period2_End);

		If l_GE_Period1_Start IS NOT NULL Then

		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period1_Start, l_GE_Period1_End, l_Period1_Start,
			l_Period1_End, l_Period2_Start, l_Period2_End);
		  /*dbms_output.put_line('Split Periods are as follows: Period1 Start - ' ||
			to_char(l_Period1_start) || ', Period1 End - ' || to_char(l_Period1_End) || ',
			Period2 Start - ' || to_char(l_Period2_Start) || ', Period2 End - ' ||
			to_char(l_Period2_End));*/

		  -- To check if the current schedule falls within the Time Period for any records with
		  -- scheduling type code of 'EG'

		/****************************************************************************
			For the current Assignment and Element Type, check if there is a schedule with
			Scheduling type code of 'EG'. If there is not any record. Then will have to do
			assignment level checking. If there is one, then check the current date range(s)
			to see if they are covered in the Schedule.

			If they are, then go to next assignment.
			If they are not, then will have to do assignment level checking.					****************************************************************************/

		  If l_Period1_Start IS NOT NULL Then
			-- dbms_output.put_line('About to execute Process Element Group Schedule.');
			retVal := Process_Element_Group_Schedule(l_Period1_Start, l_Period1_End,
					l_Assignment_ID, l_Element_Type_ID, l_EG_Period1_Start,
					l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);
			If l_EG_Period1_Start IS NOT NULL Then
				-- Period1 is not encompassed in Element Group schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start,
						l_EG_Period1_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;

			If l_EG_Period2_Start IS NOT NULL Then
				-- Period2 is not encompassed in Element Group Schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start,
						l_EG_Period2_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);

				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;
		  End If;

		  If l_Period2_Start IS NOT NULL Then
			retVal := Process_Element_Group_Schedule(l_Period2_Start, l_Period2_End,
					l_Assignment_ID, l_Element_Type_ID, l_EG_Period1_Start,
					l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);
			If l_EG_Period1_Start IS NOT NULL Then
				-- Period1 is not encompassed in Element Group schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start,
						l_EG_Period1_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

			End If;

			If l_EG_Period2_Start IS NOT NULL Then
				-- Period2 is not encompassed in Element Group Schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start,
						l_EG_Period2_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;


				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;
		  End If;
	       End If;

		If l_GE_Period2_Start IS NOT NULL Then

		  Calculate_Split_Periods(l_Assignment_Id, l_Schedule_Begin_Date, l_Schedule_End_Date,
			l_GE_Period2_Start, l_GE_Period2_End, l_Period1_Start,
			l_Period1_End, l_Period2_Start, l_Period2_End);
		  /**dbms_output.put_line('Split Periods are as follows: Period1 Start - ' ||
			to_char(l_Period1_start) || ', Period1 End - ' || to_char(l_Period1_End) || ',
			Period2 Start - ' || to_char(l_Period2_Start) || ', Period2 End - ' ||
			to_char(l_Period2_End));**/

		  -- To check if the current schedule falls within the Time Period for any records with
		  -- scheduling type code of 'EG'
		/**************************************************************************************
			For the current Assignment and Element Type, check if there is a schedule with
			Scheduling type code of 'EG'. If there is not any record. Then will have to do
			assignment level checking. If there is one, then check the current date range(s)
			to see if they are covered in the Schedule.

			If they are, then go to next assignment.
			If they are not, then will have to do assignment level checking.					**************************************************************************************/
		  If l_Period1_Start IS NOT NULL Then
			-- dbms_output.put_line('About to execute Process Element Group Schedule.');
			retVal := Process_Element_Group_Schedule(l_Period1_Start, l_Period1_End,
					l_Assignment_ID, l_Element_Type_ID, l_EG_Period1_Start,
					l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);
			If l_EG_Period1_Start IS NOT NULL Then
				-- Period1 is not encompassed in Element Group schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start,
						l_EG_Period1_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;

			If l_EG_Period2_Start IS NOT NULL Then
				-- Period2 is not encompassed in Element Group Schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start,
						l_EG_Period2_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);

				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;
		  End If;

		  If l_Period2_Start IS NOT NULL Then
			retVal := Process_Element_Group_Schedule(l_Period2_Start, l_Period2_End,
					l_Assignment_ID, l_Element_Type_ID, l_EG_Period1_Start,
					l_EG_Period1_End, l_EG_Period2_Start, l_EG_Period2_End);
			If l_EG_Period1_Start IS NOT NULL Then
				-- Period1 is not encompassed in Element Group schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period1_Start,
						l_EG_Period1_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;

			End If;

			If l_EG_Period2_Start IS NOT NULL Then
				-- Period2 is not encompassed in Element Group Schedule. So, do
				-- assignment level schedule check
				retVal := Process_Assgn_Level_Schedule(l_EG_Period2_Start,
						l_EG_Period2_End, l_Assignment_ID, l_Element_Type_ID,
						l_AS_Period1_Start, l_AS_Period1_End,
						l_AS_Period2_Start, l_AS_Period2_End);
				If l_AS_Period1_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period1_Start, v_End_Date => l_AS_Period1_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;


				If l_AS_Period2_Start IS NOT NULL then
				    -- Obtain the Part of Period1 that is covered by a PSP
				    -- Default Labor Schedule. Add corresponding records to PSP_REP_ORG_DLS
				    -- table
				    Add_If_Within_DLS(v_Organization_ID => l_Organization_ID,
					v_Begin_Date => l_AS_Period2_Start, v_End_Date => l_AS_Period2_End,
					v_Assignment_ID => l_Assignment_ID, v_Person_ID => l_Person_ID,
					v_Element_Type_ID => l_Element_Type_ID, v_Original_Sch_Code => 'ET',
					v_Schedule_Line_ID => l_Schedule_Line_ID);
				End If;
			End If;
		  End If;
		End If;

    	END LOOP;
    dbms_sql.close_cursor(l_cur_handle);

   End Process_All_ET_Schedules;
/*******************************************************************************************************
	This is a private procedure that is called to actually insert data to the intermediate
	PSP_REP_ORG_DLS_PKG table that is used by the Organization Level DLS Report.  *******************************************************************************************************/
  Procedure Table_Insert(Organization_ID Number, Element_Type_ID Number DEFAULT NULL, Person_ID Number,
	Assignment_ID Number, Begin_Date Date, End_Date Date, Original_Sch_Code Varchar2,
	Schedule_Line_ID Number) IS

	l_RowID varchar2(30);
	l_Line_ID Number;
  Begin
	-- dbms_output.put_line('About to Insert record to table');

	/**dbms_output.put_line('Values to be inserted are : Org ID - ' || to_char(Organization_ID) ||
		 ', Elem. Type ID - ' || to_char(Element_Type_ID) || ', Person ID - ' ||
		to_char(Person_ID) || ', Assignment ID - ' || to_char(Assignment_ID)
		|| ', Begin Date - ' || to_char(Begin_Date) || ', End Date - ' || to_char(End_Date));**/

	If Organization_ID IS NULL or Person_ID IS NULL or Assignment_ID IS NULL or Begin_Date IS NULL
		 or End_Date IS NULL Then
		-- dbms_output.put_line('One of the primary key fields is null....');
		return;
	End If;

	If p_Batch_Sequence_Number IS NULL Then
		Select 	PSP_REP_ORG_DLS_S.NextVal
		into	p_Batch_Sequence_Number
		from	DUAL;
	End If;

	Select 	PSP_REP_ORG_DLS2_S.NextVal
	into	l_Line_ID
	from	DUAL;

	PSP_REP_ORG_DLS_PKG.INSERT_ROW (
  		X_ROWID => l_RowID,
  		X_ORG_DLS_BATCH_ID => p_Batch_Sequence_Number,
		X_ORG_DLS_LINE_ID => l_Line_ID,
  		X_ORGANIZATION_ID => Organization_ID,
  		X_ASSIGNMENT_ID => Assignment_ID,
		X_SCHEDULE_LINE_ID => Schedule_Line_ID,
		X_ORIGINAL_SCH_CODE => Original_Sch_Code,
  		X_SCHEDULE_BEGIN_DATE => Begin_Date,
  		X_SCHEDULE_END_DATE => End_Date,
  		X_PERSON_ID => Person_ID,
  		X_ELEMENT_TYPE_ID => Element_Type_ID,
  		X_MODE => 'R'
  	);
	COMMIT;

End Table_Insert;

/*******************************************************************************************************
	This is a private procedure that is called while processing Assignment Level Schedules. This
	procedure checks if any uncovered Element Group schedule is covered by Assignment Schedules. If
	they are, then a value of 0 is returned, else, a value of 1 is returned.
*******************************************************************************************************/
  Function Process_Assgn_Level_Schedule(l_Time_Period_Start DATE, l_Time_Period_End DATE,
	l_Assignment_ID Number, l_Element_Type_ID Number, l_AS_Period1_Start IN OUT NOCOPY DATE,
	l_AS_Period1_End IN OUT NOCOPY DATE, l_AS_Period2_Start IN OUT NOCOPY DATE, l_AS_Period2_End IN OUT NOCOPY DATE)
	return NUMBER IS

/* Commented for Bug 3263333

	Cursor C1 is
       select   DISTINCT c.ASSIGNMENT_ID,
         	d.SCHEDULE_BEGIN_DATE,
         	d.SCHEDULE_END_DATE
	from    PER_ASSIGNMENTS_F a,
   		PSP_SCHEDULES b,
   		PSP_SCHEDULE_HIERARCHY c,
   		PSP_SCHEDULE_LINES d,
   		PSP_GROUP_ELEMENT_LIST e
	where   a.assignment_id = b.assignment_id
	and     b.assignment_id = c.assignment_id
	and     c.schedule_hierarchy_id = d.schedule_hierarchy_id
	and     a.assignment_id = l_Assignment_ID
	and     not (d.schedule_begin_date <= l_Time_Period_Start
        	 or d.schedule_end_date >= l_Time_Period_End)
	and	l_Time_Period_End Between a.EFFECTIVE_START_DATE and a.EFFECTIVE_END_DATE
	and     c.SCHEDULING_TYPES_CODE = 'A';*/

-- Introduced the following for Bug 3263333

	Cursor C1 is
		select   DISTINCT c.ASSIGNMENT_ID,
         	d.SCHEDULE_BEGIN_DATE,
         	d.SCHEDULE_END_DATE
	from    PER_ASSIGNMENTS_F a,
   		PSP_SCHEDULES b,
   		PSP_SCHEDULE_HIERARCHY c,
   		PSP_SCHEDULE_LINES d
	where   a.assignment_id = b.assignment_id
	and     b.assignment_id = c.assignment_id
	and     c.schedule_hierarchy_id = d.schedule_hierarchy_id
	and     a.assignment_id = l_Assignment_ID
	and     not (d.schedule_begin_date <= l_Time_Period_Start
        	 or d.schedule_end_date >= l_Time_Period_End)
	and	l_Time_Period_End Between a.EFFECTIVE_START_DATE and a.EFFECTIVE_END_DATE
	and     c.SCHEDULING_TYPES_CODE = 'A';

	C1_Row C1%RowType;
	retVal Number;
  Begin
	-- First, set Element Group Period's start and end dates to NULL
	l_AS_Period1_Start := NULL;
	l_AS_Period1_End := NULL;
	l_AS_Period2_Start := NULL;
	l_AS_Period2_End := NULL;

	/***dbms_output.put_line('About to search for Assignment labor schedules with assignment of ' ||
	 to_char(l_assignment_id) || ' and element type of ' || to_char(l_Element_Type_ID) || ' and dates
	in ' || to_char(l_Time_Period_Start) || ' and ' || to_char(l_Time_Period_End));	***/
	Open C1;
	Fetch C1 into C1_Row;
	If C1%NotFound Then
		-- dbms_output.put_line('No data found');
		Close C1;
		l_AS_Period1_Start := l_Time_Period_Start;
		l_AS_Period1_End := l_Time_Period_End;
		return 0;
	Else
		-- dbms_output.put_line('Data found');
		Calculate_Split_Periods(l_Assignment_Id, C1_Row.Schedule_Begin_Date, C1_Row.Schedule_End_Date,
			l_Time_Period_Start, l_Time_Period_End, l_AS_Period1_Start, l_AS_Period1_End,
			l_AS_Period2_Start, l_AS_Period2_End);
		/***dbms_output.put_line('Split Periods are as follows: Period1 Start - ' ||
			to_char(l_AS_Period1_start) || ', Period1 End - ' || to_char(l_AS_Period1_End)
			|| ', Period2 Start - ' || to_char(l_AS_Period2_Start) || ', Period2 End - ' ||
			to_char(l_AS_Period2_End)); ***/
		return 1;
	End If;
  End Process_Assgn_Level_Schedule;

  /***************************************************************************************************
	Function: PROCESS_GLOB_ELEM_SCHEDULE
  ***************************************************************************************************/
  Function Process_Glob_Elem_Schedule(l_Assignment_ID Number, l_Element_Type_ID Number,
			l_Time_Period_Start DATE, l_Time_Period_End DATE,
			l_GE_Period1_Start IN OUT NOCOPY DATE, l_GE_Period1_End IN OUT NOCOPY DATE,
			l_GE_Period2_Start IN OUT NOCOPY DATE, l_GE_Period2_End IN OUT NOCOPY DATE) return NUMBER IS
     Cursor C1 is
	Select 	DISTINCT e.Start_Date_Active, e.End_Date_Active
	from	PER_ASSIGNMENTS_F a,
		PAY_ELEMENT_ENTRIES_F b,
		PAY_ELEMENT_LINKS_F c,
		PAY_ELEMENT_TYPES_F d,
		PSP_ELEMENT_TYPE_ACCOUNTS e
	where	a.ASSIGNMENT_ID = b.ASSIGNMENT_ID
	and	b.ELEMENT_LINK_ID = c.ELEMENT_LINK_ID
	and	c.ELEMENT_TYPE_ID = d.ELEMENT_TYPE_ID
	and	d.ELEMENT_TYPE_ID = e.ELEMENT_TYPE_ID
	and	e.ELEMENT_TYPE_ID = l_Element_Type_ID
	and	(l_Time_Period_End Between a.EFFECTIVE_START_DATE AND a.EFFECTIVE_END_DATE)
	and	(l_Time_Period_End Between b.EFFECTIVE_START_DATE AND b.EFFECTIVE_END_DATE)
	and	(l_Time_Period_End Between c.EFFECTIVE_START_DATE AND c.EFFECTIVE_END_DATE)
	and	(l_Time_Period_End Between d.EFFECTIVE_START_DATE AND d.EFFECTIVE_END_DATE)
	and	a.ASSIGNMENT_ID = l_Assignment_ID;

     C1_Row C1%RowType;
  Begin

	l_GE_Period1_Start := NULL;
	l_GE_Period1_End := NULL;
	l_GE_Period2_Start := NULL;
	l_GE_Period2_End := NULL;

	Open C1;
	Fetch C1 into C1_Row;
	/**dbms_output.put_line('Finding Global Element Schedule...for Assignment : ' ||
		to_char(l_Assignment_ID) || '. Element Type : ' || to_char(l_Element_Type_ID) || '
		Period Begin and End Dates are : ' || to_char(l_Time_Period_Start) || ', ' ||
		to_char(l_Time_Period_End)); **/
	If C1%NOTFOUND Then
		/**dbms_output.put_line('No Entry found for Global Element Schedule for Assignment : '
		|| to_char(l_Assignment_ID)); **/
		l_GE_Period1_Start := l_Time_Period_Start;
		l_GE_Period1_End := l_Time_Period_End;
		return 0;
	Else
		-- A Record exists in the Global Elements table for user selected Element Type ID.
		-- Need to calculate the portion of the Time Period that is not covered by the Element
		Calculate_Split_Periods(l_Assignment_Id, C1_Row.Start_Date_Active, C1_Row.End_Date_Active,
			l_Time_Period_Start, l_Time_Period_End, l_GE_Period1_Start, l_GE_Period1_End,
			l_GE_Period2_Start, l_GE_Period2_End);
		/**dbms_output.put_line('Found Global Schedule. GE_Period1_Start, GE_Period1_End,
			Period2 Start and End are :' || to_char(l_GE_Period1_Start) || ', ' ||
			to_char(l_GE_Period1_End) || ', ' || to_char(l_GE_Period2_start) || ', ' ||
			to_char(l_GE_Period2_End)); **/
		return 1;
	End If;

  End Process_Glob_Elem_Schedule;

/*******************************************************************************************************
	This is a private procedure that is called while processing Element Type Schedules. This
	procedure checks if any uncovered Element Type schedule is covered by Element Group Schedules.
	If they are, then a value of 0 is returned, else, a value of 1 is returned.
*******************************************************************************************************/
  Function Process_Element_Group_Schedule(l_Time_Period_Start DATE, l_Time_Period_End DATE,
	l_Assignment_ID Number, l_Element_Type_ID Number, l_EG_Period1_Start IN OUT NOCOPY DATE,
	l_EG_Period1_End IN OUT NOCOPY DATE, l_EG_Period2_Start IN OUT NOCOPY DATE, l_EG_Period2_End IN OUT NOCOPY DATE)
	return NUMBER IS

	Cursor C1 is
		select   DISTINCT c.ASSIGNMENT_ID,
         	c.ELEMENT_GROUP_ID,
         	d.SCHEDULE_BEGIN_DATE,
         	d.SCHEDULE_END_DATE
	from    PER_ASSIGNMENTS_F a,
   		PSP_SCHEDULES b,
   		PSP_SCHEDULE_HIERARCHY c,
   		PSP_SCHEDULE_LINES d,
   		PSP_GROUP_ELEMENT_LIST e
	where   a.assignment_id = b.assignment_id
	and     b.assignment_id = c.assignment_id
	and     c.schedule_hierarchy_id = d.schedule_hierarchy_id
	and     a.assignment_id = l_Assignment_ID
	and	l_Time_Period_End Between a.EFFECTIVE_START_DATE and a.EFFECTIVE_END_DATE
	and     not (d.schedule_begin_date <= l_Time_Period_Start
        	 or d.schedule_end_date >= l_Time_Period_End)
	and     c.SCHEDULING_TYPES_CODE = 'EG'
	and     e.element_group_id = c.ELEMENT_GROUP_ID
	and     e.ELEMENT_GROUP_ID = (Select Distinct PGEL.ELEMENT_GROUP_ID
        			        from    PSP_GROUP_ELEMENT_LIST PGEL,
                	                PSP_ELEMENT_GROUPS PEG
                        	        where   PGEL.Element_Type_ID = l_Element_Type_ID
                                	and     PGEL.Element_Group_ID = PEG.Element_Group_ID
                                 	and     (PEG.Start_Date_Active Between
                                         	l_Time_Period_Start and
                                         	l_Time_Period_End)
					and   (PEG.End_Date_Active Between  l_Time_Period_Start and
						l_Time_Period_End));
	C1_Row C1%RowType;
	retVal Number;
  Begin
	-- First, set Element Group Period's start and end dates to NULL
	l_EG_Period1_Start := NULL;
	l_EG_Period1_End := NULL;
	l_EG_Period2_Start := NULL;
	l_EG_Period2_End := NULL;

	/*** dbms_output.put_line('About to search for EG labor schedules with assignment of ' ||
		to_char(l_assignment_id) || ' and element type of ' || to_char(l_Element_Type_ID) || '
		and dates in ' || to_char(l_Time_Period_Start) || ' and ' ||
		to_char(l_Time_Period_End));	***/
	Open C1;
	Fetch C1 into C1_Row;
	If C1%NotFound Then
		-- dbms_output.put_line('No data found. Have to do Assignment level Labor Scheduling');
		Close C1;
		l_EG_Period1_Start := l_Time_Period_Start;
		l_EG_Period1_End := l_Time_Period_End;
		return 0;
	Else
		-- dbms_output.put_line('Data found');
		Calculate_Split_Periods(l_Assignment_Id, C1_Row.Schedule_Begin_Date, C1_Row.Schedule_End_Date,
			l_Time_Period_Start, l_Time_Period_End, l_EG_Period1_Start, l_EG_Period1_End,
			l_EG_Period2_Start, l_EG_Period2_End);
		/**** dbms_output.put_line('Split Periods are as follows: Period1 Start - ' ||
			to_char(l_EG_Period1_start) || ', Period1 End - ' || to_char(l_EG_Period1_End)
			|| ', Period2 Start - ' || to_char(l_EG_Period2_Start) || ', Period2 End - ' ||
			to_char(l_EG_Period2_End));***/
		return 1;
	End If;
  End Process_Element_Group_Schedule;

/*******************************************************************************************************
	PRIVATE PROCEDURE TO CALCULATE THE PERIODS TO BE SPLIT INTO BASED ON SCHEDULE BEGIN AND END
	DATES AND TIME PERIOD
*******************************************************************************************************/
  PROCEDURE Calculate_Split_Periods(l_Assignment_Id NUMBER, l_Schedule_Begin_Date DATE, l_Schedule_End_Date DATE ,
	l_Time_Period_Start DATE, l_Time_Period_End DATE, l_Period1_Start IN OUT NOCOPY DATE, l_Period1_End IN OUT NOCOPY
	DATE, l_Period2_Start IN OUT NOCOPY DATE, l_Period2_End IN OUT NOCOPY DATE) IS
  Begin
	-- First, ensure that all variables that have to be returned are set to NULL
	l_Period1_Start := NULL;
	l_Period1_End := NULL;
	l_Period2_start := NULL;
	l_Period2_End := NULL;
	-- Case when the Time Period is fully encompassed within the Schedule Period.
	If l_Schedule_Begin_Date <= l_Time_Period_Start AND l_Schedule_End_Date >= l_Time_Period_End Then
		-- This record should not be displayed
		return;
	End If;

	-- Case when The Schedule Period does not coincide with the Time Period at all
	If l_Schedule_End_Date < l_Time_Period_Start OR l_Schedule_Begin_Date > l_Time_Period_End Then
		l_Period1_Start := l_Time_Period_Start;
		l_Period1_End := l_Time_Period_End;
		return;
	End If;

	-- Case when the Schedule Period is fully encompassed within the Time Period. =>(Two Split
	-- Periods)
	If l_Schedule_Begin_Date >= l_Time_Period_Start AND l_Schedule_End_Date <= l_Time_Period_End
		Then
            if l_schedule_begin_date = l_Time_period_Start AND l_schedule_end_date = l_Time_Period_End then

		l_Period1_Start := NULL;
		l_Period1_End := NULL;
            end if;

            if l_schedule_begin_date = l_Time_period_Start AND l_schedule_end_date < l_Time_Period_End then
                GET_SPLIT_AFTER(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period1_start, l_period1_end);
            end if;

            if l_schedule_begin_date > l_Time_period_Start AND l_schedule_end_date = l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 1 C');
                GET_SPLIT_BEFORE(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period1_start, l_period1_end);
            end if;

            if l_schedule_begin_date > l_Time_period_Start AND l_schedule_end_date < l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 1 D');
                GET_SPLIT_BEFORE(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period1_start, l_period1_end);
                GET_SPLIT_AFTER(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period2_start, l_period2_end);
            end if;
		If l_Period1_End < l_Period1_Start Then -- This split period is less than 1 day. So, set it to NULL.
			l_Period1_Start := NULL;
			l_Period1_End := NULL;
		End If;

		If l_Period2_Start > l_Period2_End Then
			l_Period2_Start := NULL;
			l_Period2_End := NULL;
		End If;

		return;
	End If;

	-- Case when the Schedule Period Starts before Time Period Start and Ends within the Time Period
	If l_Schedule_Begin_Date <= l_Time_Period_Start AND l_Schedule_End_Date <= l_Time_Period_End
		Then
            if l_schedule_begin_date < l_Time_period_Start AND l_schedule_end_date = l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 2 A');
		l_Period1_Start := NULL;
		l_Period1_End := NULL;
            end if;
            if l_schedule_begin_date < l_Time_period_Start AND l_schedule_end_date < l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 2 B');
                GET_SPLIT_AFTER(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period1_start, l_period1_end);
            end if;
		If l_Period1_End < l_Period1_Start Then -- This split period is less than 1 day. So, set it to NULL.
			l_Period1_Start := NULL;
			l_Period1_End := NULL;
		End If;

		return;
	End If;

	-- Case when the Schedule Period Ends after Time Period End and starts within the Time Period
	If l_Schedule_Begin_Date >= l_Time_Period_Start AND l_Schedule_End_Date >= l_Time_Period_End
		Then
            if l_schedule_begin_date = l_Time_period_Start AND l_schedule_end_date > l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 3 A');
		l_Period1_Start := NULL;
		l_Period1_End := NULL;
            end if;
            if l_schedule_begin_date > l_Time_period_Start AND l_schedule_end_date > l_Time_Period_End then
	 --dbms_output.put_line('Calculate split records condition 3 B');
                GET_SPLIT_BEFORE(l_assignment_id, l_schedule_begin_date, l_schedule_end_date, l_time_period_start,
                                 l_time_period_end, l_period1_start, l_period1_end);
            end if;
		If l_Period1_End < l_Period1_Start Then -- This split period is less than 1 day. So, set it to NULL.
			l_Period1_Start := NULL;
			l_Period1_End := NULL;
		End If;

		return;
	End If;

  Exception
	when OTHERS Then
		--dbms_output.put_line('Error occured while processing Split Period Calculator');
		return;
  End Calculate_Split_Periods;
  /********************************************************************************************************
        PRIVATE PROCEDURE TO CALCULATE THE SPLIT BEFORE THE SCHEDULE BASED UPON THE
        ASSIGNMENT, SCHEDULE BEGIN DATE, SCHEDULE END DATE and TIME PERIOD
   *******************************************************************************************************/
  PROCEDURE GET_SPLIT_BEFORE(l_Assignment_Id Number, l_Schedule_Begin_Date DATE, l_Schedule_End_Date DATE,
       l_Time_Period_Start DATE, l_Time_Period_End DATE, l_Period1_Start IN OUT NOCOPY DATE,
       l_Period1_End IN OUT NOCOPY DATE) is
       l_max_schedule_end_date DATE;
       l_temp_schedule_begin_date DATE;
  begin
	-- First, ensure that all variables that have to be returned are set to NULL
	l_Period1_Start := NULL;
	l_Period1_End := NULL;
        Select MAX(SCHEDULE_END_DATE) into l_max_schedule_end_date
        from PSP_REP_SCH_EMP_V
        where assignment_id = l_assignment_id
        and schedule_end_date < l_schedule_begin_date
        and schedule_end_date >= l_time_period_start
        and not exists (select assignment_id from PSP_REP_SCH_EMP_V
                        where assignment_id = l_assignment_id and
                              l_schedule_begin_date between schedule_begin_date and schedule_end_date
                         and schedule_begin_date < l_schedule_begin_date);
        if l_schedule_begin_date - l_max_schedule_end_date <=1 then
             return;
        end if;
        --dbms_output.put_line('max end date : '||to_char(l_max_schedule_end_date));
       if l_max_schedule_end_date is not NULL then
            l_Period1_Start := l_max_schedule_end_date + 1;
            l_Period1_End := l_Schedule_begin_date -1;
	    --dbms_output.put_line('Split before.. l_Period1_start ' || to_char(l_Period1_Start));
	    --dbms_output.put_line('Split before.. l_Period1_end ' || to_char(l_Period1_End));
            return;
       else
            begin
                select min(schedule_begin_date)  into l_temp_schedule_begin_date
                from PSP_REP_SCH_EMP_V
                where assignment_id = l_assignment_id and
                l_schedule_begin_date between schedule_begin_date and schedule_end_date
                and schedule_begin_date < l_schedule_begin_date;
                if l_temp_schedule_begin_date is not NULL then
                    if l_Time_Period_Start < l_temp_Schedule_Begin_Date then
                        l_Period1_Start := l_Time_Period_Start;
                        l_Period1_End := l_temp_Schedule_Begin_Date -1;
                        return;
                    end if;
                else
                    l_Period1_Start := l_Time_Period_Start;
                    l_Period1_End := l_Schedule_Begin_Date -1;
                    --dbms_output.put_line(to_char(l_period1_start)||' '||to_char(l_period1_end));
                    return;
                end if;
           end;
       end if;
       return;
       exception
         when no_data_found then
            return;
  end;
  /********************************************************************************************************
        PRIVATE PROCEDURE TO CALCULATE THE SPLIT AFTER THE SCHEDULE BASED UPON THE
        ASSIGNMENT, SCHEDULE BEGIN DATE, SCHEDULE END DATE and TIME PERIOD
   *******************************************************************************************************/

  PROCEDURE GET_SPLIT_AFTER(l_Assignment_Id Number, l_Schedule_Begin_Date DATE, l_Schedule_End_Date DATE,
       l_Time_Period_Start DATE, l_Time_Period_End DATE,
       l_Period2_Start IN OUT NOCOPY DATE, l_Period2_End IN OUT NOCOPY DATE) is
  l_min_schedule_begin_date DATE;
  l_temp_schedule_end_date date;
  begin
	-- First, ensure that all variables that have to be returned are set to NULL
	l_Period2_start := NULL;
	l_Period2_End := NULL;
        Select MIN(SCHEDULE_BEGIN_DATE) into l_min_schedule_begin_date
        from PSP_REP_SCH_EMP_V
        where assignment_id = l_assignment_id
        and schedule_begin_date > l_schedule_end_date
        and schedule_begin_date <= l_time_period_end
        and not exists (select assignment_id from PSP_REP_SCH_EMP_V
                        where assignment_id = l_assignment_id and
                              l_schedule_end_date between schedule_begin_date and schedule_end_date
                             and schedule_end_date > l_schedule_end_date);
        if l_min_schedule_begin_date - l_schedule_begin_date <=1 then
             return;
        end if;
        if l_min_schedule_begin_date is not NULL then
            l_Period2_Start := l_Schedule_End_date + 1;
            l_Period2_End := l_min_schedule_begin_date - 1;
	    --dbms_output.put_line('Split after.. l_Period2_start ' || to_char(l_Period2_Start));
	    --dbms_output.put_line('Split after.. l_Period2_end ' || to_char(l_Period2_End));
            return;
        else
            begin
               select max(schedule_end_date) into l_temp_schedule_end_date
               from PSP_REP_SCH_EMP_V
               where assignment_id = l_assignment_id and
               l_schedule_end_date between schedule_begin_date and schedule_end_date
               and schedule_end_date > l_schedule_end_date;
               if l_temp_schedule_end_date is not NULL then
                   if l_time_period_end > l_temp_schedule_end_date then
                      l_Period2_Start := l_temp_schedule_end_date + 1;
                      l_Period2_End := l_Time_period_end;
                      return;
                   end if;
               else
                   l_Period2_Start := l_Schedule_End_Date + 1;
                   l_Period2_End := l_Time_Period_End;
                   return;
               end if;
            end;
        end if;
        return;
     exception
     when no_data_found then
     return;
  end;
  /********************************************************************************************************
	Though this procedure accepts Schedule Line Numbers, this is no longer adding these line
	numbers to the PSP_REP_ORG_DLS table. Instead, the Org_Schedule_ID from PSP_DEFAULT_LABOR_SCHEDULES
	is being added. The report will have to obtain the Default Labor Schedule Charging Instruction from
	this.
  *********************************************************************************************************/
  PROCEDURE Add_If_Within_DLS(v_Organization_ID Number, v_Begin_Date DATE,
	v_End_Date DATE, v_Assignment_ID Number, v_Person_ID Number, v_Element_Type_ID Number,
	v_Original_Sch_Code varchar2, v_Schedule_Line_ID Number) IS
    Cursor C1 is
	Select 	Org_Schedule_ID, Schedule_Begin_Date, Schedule_End_Date
	from	PSP_DEFAULT_LABOR_SCHEDULES
	where	Organization_ID = v_Organization_ID;
    DLS_Begin_Date DATE;
    DLS_End_Date DATE;
  Begin

	/*** dbms_output.put_line ('Processing Record with Schedule of ' || v_Original_Sch_Code || ' for
	Org : ' || to_char(v_Organization_ID));
	dbms_output.put_line('Processing record for Schedule Begin and End Dates of ' ||
		to_char(v_Begin_Date) || ' and ' || 	to_char(v_End_Date)); ***/
	For C1_Row IN C1 LOOP
	  /***dbms_output.put_line('Inside cursor loop. DLS Schedule Begin and End Dates are ' ||
		to_char(C1_Row.Schedule_Begin_Date) || ' and ' || to_char(C1_Row.Schedule_End_Date));***/
	  If C1_Row.Schedule_Begin_Date <= v_Begin_Date AND C1_Row.Schedule_End_Date >= v_End_Date
		Then
		DLS_Begin_Date := v_Begin_Date;
		DLS_End_Date := v_End_Date;
		/*dbms_output.put_line('Adding record with Begin and End Dates of :' ||
		to_char(DLS_Begin_Date) || ' and ' || to_char(DLS_End_Date));*/
		Table_Insert(Assignment_ID => v_Assignment_ID, Organization_ID
			=> v_Organization_ID, Person_ID => v_Person_ID,
			Element_Type_ID => v_Element_Type_ID, Begin_Date =>
			DLS_Begin_Date, End_Date => DLS_End_Date,
			Original_Sch_Code => v_Original_Sch_Code, Schedule_Line_ID =>
			C1_Row.Org_Schedule_ID);
	  Elsif C1_Row.Schedule_Begin_Date >= v_Begin_Date AND C1_Row.Schedule_End_Date <= v_End_Date
		Then
		DLS_Begin_Date := C1_Row.Schedule_Begin_Date;
		DLS_End_Date := C1_Row.Schedule_End_Date;
		/*dbms_output.put_line('Adding record with Begin and End Dates of :' ||
		to_char(DLS_Begin_Date)	|| ' and ' || to_char(DLS_End_Date));*/
		Table_Insert(Assignment_ID => v_Assignment_ID, Organization_ID
			=> v_Organization_ID, Person_ID => v_Person_ID,
			Element_Type_ID => v_Element_Type_ID, Begin_Date =>
			DLS_Begin_Date, End_Date => DLS_End_Date,
			Original_Sch_Code => v_Original_Sch_Code, Schedule_Line_ID =>
			C1_Row.Org_Schedule_ID);
	  Elsif C1_Row.Schedule_Begin_Date <= v_Begin_Date AND C1_Row.Schedule_End_Date <= v_End_Date
		AND NOT (C1_Row.Schedule_End_Date <= v_Begin_Date) Then
		DLS_Begin_Date := v_Begin_Date;
		DLS_End_Date := C1_Row.Schedule_End_Date;

		/*dbms_output.put_line('Adding record with Begin and End Dates of :' ||
		to_char(DLS_Begin_Date) || ' and ' || to_char(DLS_End_Date));*/
		Table_Insert(Assignment_ID => v_Assignment_ID, Organization_ID
			=> v_Organization_ID, Person_ID => v_Person_ID,
			Element_Type_ID => v_Element_Type_ID, Begin_Date =>
			DLS_Begin_Date, End_Date => DLS_End_Date,
			Original_Sch_Code => v_Original_Sch_Code, Schedule_Line_ID =>
			C1_Row.Org_Schedule_ID);
	  Elsif C1_Row.Schedule_Begin_Date >= v_Begin_Date AND C1_Row.Schedule_End_Date >= v_End_Date
		AND Not(C1_Row.Schedule_Begin_Date >= v_End_Date) Then
		DLS_Begin_Date := C1_Row.Schedule_Begin_Date;
		DLS_End_Date := v_End_Date;
		/**dbms_output.put_line('Adding record with Begin and End Dates of :' ||
		to_char(DLS_Begin_Date) || ' and ' || to_char(DLS_End_Date)); **/
		Table_Insert(Assignment_ID => v_Assignment_ID, Organization_ID
			=> v_Organization_ID, Person_ID => v_Person_ID,
			Element_Type_ID => v_Element_Type_ID, Begin_Date =>
			DLS_Begin_Date, End_Date => DLS_End_Date,
			Original_Sch_Code => v_Original_Sch_Code, Schedule_Line_ID =>
			C1_Row.Org_Schedule_ID);
	  End If;
	End LOOP;

	return;

  End Add_If_Within_DLS;

END;

/
