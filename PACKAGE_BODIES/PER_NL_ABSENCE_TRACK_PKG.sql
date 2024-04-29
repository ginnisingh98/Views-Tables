--------------------------------------------------------
--  DDL for Package Body PER_NL_ABSENCE_TRACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NL_ABSENCE_TRACK_PKG" AS
/* $Header: penlabst.pkb 120.2 2006/09/07 11:13:40 niljain noship $ */
g_package                  varchar2(33) := '  PER_NL_ABSENCE_TRACK_PKG.';

--
-- Creates Default Absence Actions for a Employee if no actions
-- are entered for a employee
PROCEDURE create_Default_Absence_Actions
	(p_absence_attendance_id number,
	 p_effective_date date,
	 p_return_status  in out nocopy varchar2
          ) IS

  l_business_group_id number;
  l_user_table_name pay_user_tables.user_table_name%TYPE;


  l_action pay_user_column_instances_f.value%TYPE;
  l_time_period pay_user_column_instances_f.value%TYPE;
  l_units pay_user_column_instances_f.value%TYPE;


  l_expected_date  date;
  l_absence_action_id     number ;
  l_object_version_number number ;

  /* Bug # 5225587 - added extra parameter vp_effective_date date */

  CURSOR c_user_rows(vp_business_group_id number,
                     vp_user_table_name varchar2,
                     vp_effective_date date) IS
  SELECT  pur.row_low_range_or_name
  FROM pay_user_rows_f pur,
  pay_user_tables put
  WHERE put.user_table_id=pur.user_table_id
  and put.business_group_id = vp_business_group_id
  and put.user_table_name =vp_user_table_name
  and vp_effective_date between
           pur.effective_start_date
      and  pur.effective_end_date;


  CURSOR c_abs_actions IS
  SELECT '1' from PER_NL_ABSENCE_ACTIONS
  where absence_attendance_id = p_absence_attendance_id;



  l_row_number pay_user_rows_f.row_low_range_or_name%TYPE;
  l_proc varchar2(72) := g_package || '.create_Default_Absence_Actions';
  l_date_start date;
  l_setup_exists varchar2(30);
  l_actions_exists varchar2(30);
BEGIN

  l_setup_exists:= 'E';
  l_actions_exists :='N';

  hr_utility.set_location('Entering ' || l_proc, 100);


  --Fetch the Business Group Id and User Table Name
  chk_Abs_Action_Setup_Exists
           (p_absence_attendance_id ,
            l_business_group_id,l_user_table_name,
            l_date_start,l_setup_exists);

  p_return_status := l_setup_exists;

  hr_utility.set_location(' l_business_group_id :  ' || l_business_group_id, 110);
  hr_utility.set_location(' l_user_table_name ' || l_user_table_name, 120);
  hr_utility.set_location(' l_date_start  ' || l_date_start, 130);
  hr_utility.set_location(' p_return_status   ' || p_return_status, 140);


  OPEN c_abs_actions;
  FETCH c_abs_actions INTO l_actions_exists;
  IF c_abs_actions%FOUND THEN
     --Absence Actions have already been created for the Absence
     l_actions_exists:='Y' ;
  else
     --Absence Actions are not created for this Absence
     --continue with the rest
     l_actions_exists:='N' ;
  END IF;
  CLOSE c_abs_actions;

  --Create the Default Absence Action, Only if the
  --User Table is set up and
  --Absence Actions has not been entered for the Absence.

  --2651341
  --Added Savepoint to Rollback
  --In Case User do not completely define the User Table
  SAVEPOINT InvalidUDTSetup;

  IF l_setup_exists='S' AND l_actions_exists='N' THEN
    hr_utility.set_location('Abs Action Setup exists ' || l_setup_exists, 200);

    --Fetch the Rows from the User Table
    OPEN c_user_rows(l_business_group_id,l_user_table_name,l_date_start);
    LOOP
        FETCH c_user_rows INTO l_row_number;
	EXIT WHEN c_user_rows%NOTFOUND;
	hr_utility.set_location('Fetching Action Rows ' || l_row_number, 210);

	l_expected_date := null;
	l_action := null;
	l_time_period := null;
	l_units := null;


	begin
        -- Bug# 5476730, pass l_date_start instead of p_effective_date

	 /*l_action := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
		'ACTION',l_row_number,p_effective_date);
	 l_time_period := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
	        'TIME_PERIOD',l_row_number,p_effective_date);
	 l_units := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
	        'TIME_UNITS',l_row_number,p_effective_date); */
         l_action := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
		'ACTION',l_row_number,l_date_start);
	 l_time_period := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
	        'TIME_PERIOD',l_row_number,l_date_start);
	 l_units := hruserdt.get_table_value(l_business_group_id,l_user_table_name,
	        'TIME_UNITS',l_row_number,l_date_start);
   	 if l_units='D' then
	   l_expected_date := l_date_start + l_time_period;
	 elsif l_units='W' then
	   l_expected_date := l_date_start + l_time_period * 7;
	 elsif l_units='M' then
	   l_expected_date := add_months(l_date_start,l_time_period);
	 else
	   p_return_status := 'E';
	   exit;
	 end if;


	 hr_utility.set_location('Row Number  ' || l_row_number, 220);
	 hr_utility.set_location('Action  ' || l_action, 230);
	 hr_utility.set_location('Time Period ' || l_time_period, 240);
	 hr_utility.set_location('Unit  ' || l_units, 250);
	 hr_utility.set_location('Expected Date  ' || l_expected_date, 260);

	 exception
	  when Others then
	    p_return_status := 'E';
	    hr_utility.set_location(' Others :' || SQLERRM(SQLCODE),900);
	    exit;
	 end;
	 --Call the SWI Wrapper for Creating the Action
         hr_nl_absence_action_swi.create_absence_action
		  (p_absence_attendance_id        =>p_absence_attendance_id,
                   p_enabled                      =>'Y',
		   p_expected_date                =>l_expected_date,
		   p_description                  =>l_action,
		   p_absence_action_id            =>l_absence_action_id,
		   p_object_version_number        =>l_object_version_number,
		   p_return_status 		  =>p_return_status
		) ;
	 hr_utility.set_location('p_absence_action_id  ' || l_absence_action_id, 910);
	 hr_utility.set_location('p_object_version_number  ' || l_object_version_number, 920);
	 hr_utility.set_location('p_return_status ' || p_return_status, 930);

	 if p_return_status<>'S' then
		exit;
	 end if;
     END LOOP;
  END IF;
  --2651341
  --Rollback to Savepoint if Errors are encountered
  --While creating Default Actions.
  IF p_return_status = 'E' THEN
  	ROLLBACK to InvalidUDTSetup;
  END IF;

  hr_utility.set_location('p_return_status  ' || p_return_status, 400);
  hr_utility.set_location('Leaving' || l_proc, 500);
EXCEPTION
   WHEN OTHERS THEN
    p_return_status := 'E';
    ROLLBACK to InvalidUDTSetup;
    hr_utility.set_location(' Others :' || SQLERRM(SQLCODE),900);
END create_Default_Absence_Actions;

PROCEDURE chk_Abs_Action_Setup_Exists
         (p_absence_attendance_id IN number ,
          p_business_group_id     OUT nocopy NUMBER,
          p_user_table_name       OUT nocopy VARCHAR2,
          p_start_date            OUT nocopy DATE,
          p_setup_exists          OUT nocopy varchar2)IS

  CURSOR c_abs_cat IS
     select abs.absence_attendance_id,abs.business_group_id,
            abs.absence_attendance_type_id,atyp.absence_category,
            nvl(abs.date_start,abs.date_projected_start) start_date
       from per_absence_attendances abs,
            per_absence_attendance_types atyp
      where absence_attendance_id =p_absence_attendance_id
        and abs.absence_attendance_type_id= atyp.absence_attendance_type_id;

   vc_abs_cat c_abs_cat%ROWTYPE;

  CURSOR c_abs_utab(vp_business_group_id varchar2,
       vp_user_table_name varchar2) IS
    select user_table_id,user_table_name
      from pay_user_tables utab
     where business_group_id =vp_business_group_id
       and user_table_name =vp_user_table_name;
  vc_abs_utab c_abs_utab%ROWTYPE;

  l_proc varchar2(72) := g_package || '.chk_Abs_Action_Setup_Exists';
BEGIN

   hr_utility.set_location('Entering ' || l_proc, 100);
   p_setup_exists := 'E';

   --Fetch the Absence Category
   OPEN c_abs_cat;
   FETCH c_abs_cat INTO vc_abs_cat;
   CLOSE c_abs_cat;

   hr_utility.set_location('Absence Category ' || vc_abs_cat.Absence_Category, 110);
   --If Absence Category is Not Null,
   --Check if User Table is Set up
   IF vc_abs_cat.Absence_Category IS NOT NULL THEN

     OPEN c_abs_utab(vc_abs_cat.business_group_id,
     'NL_ABS_ACTION_'||vc_abs_cat.absence_category);
     FETCH c_abs_utab INTO vc_abs_utab;
     IF c_abs_utab%FOUND THEN
        --Default Absence Actions User Table exists
	p_business_group_id := vc_abs_cat.Business_Group_Id;
	p_user_table_name := 'NL_ABS_ACTION_'||vc_abs_cat.absence_category;
        p_setup_exists := 'S';
        p_start_date := vc_abs_cat.start_date;
        hr_utility.set_location('p_setup_exists ' || p_setup_exists, 120);
     END IF;
     CLOSE c_abs_utab;
   END IF;

   hr_utility.set_location('p_setup_exists ' || p_setup_exists, 120);
   hr_utility.set_location('Leaving ' || l_proc, 500);

END chk_Abs_Action_Setup_Exists;

END PER_NL_ABSENCE_TRACK_PKG;

/
