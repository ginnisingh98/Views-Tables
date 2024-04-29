--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE_V14_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE_V14_PKG" AS
/* $Header: peper14t.pkb 120.1 2005/12/06 23:21:51 amigarg noship $ */
PROCEDURE form_startup(X_Business_group_id IN OUT NOCOPY NUMBER
                      ,X_Set_Of_Books_Id IN OUT NOCOPY NUMBER
                      ,X_Resp_Appl_Id NUMBER
                      ,X_Resp_Id NUMBER
                      ,X_Legislation_Code IN OUT NOCOPY VARCHAR2
                      ,X_business_group_name IN OUT NOCOPY VARCHAR2
                      ,X_property_on NUMBER
                      ,X_property_off NUMBER
                      ,X_Query_Only_Flag VARCHAR2
                      ,X_employee_property IN OUT NOCOPY NUMBER
                      ,X_expense_check_to_address IN OUT NOCOPY VARCHAR2
                      ,X_expense_to_address_meaning IN OUT NOCOPY VARCHAR2
                      ,X_chart_of_accounts_id IN OUT NOCOPY NUMBER
                      ,X_set_of_books_name IN OUT NOCOPY VARCHAR2
                      ,X_Session_Date IN OUT NOCOPY DATE
                      ,X_End_Of_Time IN OUT NOCOPY DATE
                      ,X_current_appl_id IN OUT NOCOPY NUMBER
                      ,X_person_type_id IN OUT NOCOPY NUMBER
                      ,X_current_employee_flag IN OUT NOCOPY VARCHAR2
                      ,X_current_applicant_flag IN OUT NOCOPY VARCHAR2
                      ,X_current_emp_or_apl_flag IN OUT NOCOPY VARCHAR2)
IS
--
CURSOR data_group
IS
SELECT dgu.oracle_id
,      fr.data_group_application_id
FROM   fnd_data_group_units dgu
,      fnd_responsibility fr
WHERE  fr.data_group_id = dgu.data_group_id
AND    fr.data_group_application_id = dgu.application_id
AND    fr.application_id = X_Resp_Appl_Id
AND    fr.responsibility_id = X_Resp_Id;
--
--
CURSOR chart_of_accounts
IS
SELECT gsb.chart_of_accounts_id
,      gsb.name
FROM   gl_sets_of_books gsb
WHERE  gsb.set_of_books_id = X_Set_Of_Books_Id;
--
CURSOR bg_details
IS
SELECT pbg.legislation_code
,      pbg.name
,      DECODE(pbg.METHOD_OF_GENERATION_EMP_NUM,'A'
,      X_property_off , X_property_on)
FROM   per_business_groups pbg
WHERE  pbg.business_group_id = X_Business_group_id;
--
CURSOR expense_address
IS
SELECT hl.meaning
FROM   hr_lookups hl
WHERE  hl.lookup_type= 'HOME_OFFICE'
AND    hl.lookup_code = X_expense_check_to_address;
--
CURSOR person_type IS
SELECT ppt.person_type_id
,      pst.current_employee_flag
,      pst.current_applicant_flag
,      pst.current_emp_or_apl_flag
,      TRUNC(SYSDATE)
,      TO_DATE('31/12/4712','DD/MM/YYYY')
FROM per_person_types ppt
,    per_startup_person_types pst
WHERE ppt.business_group_id = X_Business_group_id -- Bug 3648460
AND   ppt.system_person_type = pst.system_person_type
AND   ppt.system_person_type = DECODE(X_current_appl_id,810,'OTHER','EMP')
AND   ppt.default_flag = 'Y'
AND   pst.default_flag = 'Y';
--
l_sql_text VARCHAR2(2000):=NULL;
l_sql_cursor INTEGER;
l_rows_fetched INTEGER;
l_rows NUMBER;
l_oracle_id NUMBER;
l_fsp_business_group_id NUMBER;
l_set_of_books_id NUMBER;
l_dummy BOOLEAN;
l_status VARCHAR2(1);
l_ap_status VARCHAR2(1);
l_po_status VARCHAR2(1);
l_industry VARCHAR2(1);
--
BEGIN
  --
  -- Check whether responsibility is allowed to use form
  --
  OPEN data_group;
  FETCH data_group INTO l_oracle_id, X_current_appl_id;
  CLOSE data_group;
  --
  -- If query only mode then ignore this test
  --
  IF (SUBSTR(X_Query_Only_Flag,1,1) <> 'Y')
  THEN
  --
  -- Check HR not Installed and Liscensed.
  --
  IF (fnd_installation.get(appl_id => 800
                          ,dep_appl_id => 800
                          ,status => l_status
                          ,industry => l_industry))
  THEN
	 -- If installed and Not OTA
	 -- then error
	 IF (l_status = 'I')
	  AND (X_current_appl_id <> 810)
	 THEN
		hr_utility.set_message('801','HR_6041_PO_EMP_HR_INSTALLED');
		hr_utility.raise_error;
		hr_utility.raise_error;
	 END IF;
  END IF;
  END IF;

  --
  -- Check Purchasing and Payables not Installed and Liscensed.
  --
    l_dummy :=fnd_installation.get(appl_id => 201
                          ,dep_appl_id => 201
                          ,status => l_ap_status
                          ,industry => l_industry);

     l_dummy :=fnd_installation.get(appl_id => 200
                          ,dep_appl_id => 200
                          ,status => l_po_status
                          ,industry => l_industry);
	 --
	 -- If either AP or PO is fully installed (l_status = 'I')
	 -- get the set of books from financials_system_parameters
	 --
    IF (l_ap_status = 'I') OR  (l_po_status = 'I')
    THEN
  --
  -- Dynamic SQL cursor to get round the problem of Table not existing.
  -- This uses a similar method to OCI but Via PL/SQL instead.
  --
    BEGIN
      --
      l_sql_text := 'select fsp.set_of_books_id '
                 || ',fsp.expense_check_address_flag '
                 || 'from financials_system_parameters fsp';
      --
      -- Open Cursor for Processing Sql statment.
      --
      l_sql_cursor := dbms_sql.open_cursor;
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
      dbms_sql.define_column(l_sql_cursor, 1, l_set_of_books_id);
      dbms_sql.define_column(l_sql_cursor,2, X_expense_check_to_address,30);
      --
      -- Execute the SQL statement.
      --
      l_rows_fetched := dbms_sql.EXECUTE(l_sql_cursor);
      --
      --
      l_rows := dbms_sql.fetch_rows(l_sql_cursor);
      --
      IF l_rows > 1
      THEN
	hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      	hr_utility.set_message_token('PROCEDURE','Form_startup');
        hr_utility.raise_error;
      END IF;
      --
      IF l_rows > 0
      THEN
        --
        -- Extract the select list for the current row into local variables.
        --
        dbms_sql.column_value(l_sql_cursor, 1, l_set_of_books_id);
        dbms_sql.column_value(l_sql_cursor, 2, X_expense_check_to_address);
      END IF;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
    END;
    END IF;
  --
  --
  IF l_set_of_books_id IS NOT NULL
  THEN
      X_Set_Of_Books_ID := l_set_of_books_id;
  END IF;
  --
  -- Get the chart of Accounts id for the GL Flexfield
  -- If set of books profile is set.
  -- Note: with shared install this table should always exist
  --       so no need for Dynamic PL/SQL cursor.
  --
  IF X_Set_Of_Books_Id IS NOT NULL
  THEN
    OPEN chart_of_accounts;
    FETCH chart_of_accounts INTO X_chart_of_accounts_id
			 ,X_set_of_books_name;
    IF chart_of_accounts%NOTFOUND THEN
      hr_utility.set_message('801','HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Form_startup');
      hr_utility.raise_error;
    END IF;
    CLOSE chart_of_accounts;
  END IF;
  --
  -- Gets the Legislation of the Business Group (used to Default style
  -- for the address) and the form property of the Employee Number field
  -- which is toggled based on whether the Business group has
  -- its generation set to A(utomatic) or not.
  --
  OPEN bg_details;
  FETCH bg_details INTO X_Legislation_Code
                       ,X_business_group_name
                       ,X_employee_property;
  CLOSE bg_details;
  --
  OPEN expense_address;
  FETCH expense_address INTO X_expense_to_address_meaning;
  CLOSE expense_address;
  --
  -- Get the Default Employee Person_type from Per_Person_types
  -- and the start and end dates for a row entered as of sysdate.
  --
  OPEN person_type;
  FETCH person_type INTO X_person_type_id,X_current_employee_flag
                        ,X_current_applicant_flag,X_current_emp_or_apl_flag
                        ,X_Session_Date,X_End_Of_Time;
  CLOSE person_type;
  --
END;
--
PROCEDURE Insert_period_of_Service(X_Person_Id NUMBER
                                  ,X_Business_Group_Id NUMBER
                                  ,X_Date_Start DATE
                                  ,X_Period_of_Service_Id IN OUT NOCOPY NUMBER)
IS
CURSOR C1 IS SELECT per_periods_of_service_s.NEXTVAL FROM sys.dual;
--
-- START WWBUG 1390173 fix
--
l_old   ben_pps_ler.g_pps_ler_rec;
l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG 1390173 fix
--
--

BEGIN
  OPEN C1;
  FETCH C1 INTO X_Period_of_Service_Id;
  CLOSE C1;
--
  INSERT INTO PER_PERIODS_OF_SERVICE(
   PERIOD_OF_SERVICE_ID
  ,BUSINESS_GROUP_ID
  ,PERSON_ID
  ,DATE_START
  ) VALUES (
  X_Period_of_Service_Id
 ,X_Business_Group_Id
 ,X_Person_Id
 ,X_Date_Start);
--
--
-- START WWBUG 1390173 fix
--
l_new.PERSON_ID := x_person_id;
l_new.BUSINESS_GROUP_ID := x_business_group_id;
l_new.DATE_START := x_date_start;
l_new.ACTUAL_TERMINATION_DATE := NULL;
l_new.LEAVING_REASON := NULL;
l_new.ADJUSTED_SVC_DATE := NULL;
l_new.ATTRIBUTE1 := NULL;
l_new.ATTRIBUTE2 := NULL;
l_new.ATTRIBUTE3 := NULL;
l_new.ATTRIBUTE4 := NULL;
l_new.ATTRIBUTE5 := NULL;
l_new.final_process_date := NULL;
--
ben_pps_ler.ler_chk(p_old            => l_old
                   ,p_new            => l_new
                   ,p_event          => 'INSERTING'
                   ,p_effective_date => x_date_start);
--
-- END WWBUG 1390173 fix
--
--
END insert_period_of_service;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Person_Id                           IN OUT NOCOPY NUMBER,
                     X_Party_Id                            NUMBER DEFAULT NULL,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Start_Date                          DATE,
                     X_Applicant_Number                    VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Current_Applicant_Flag              VARCHAR2,
                     X_Current_Emp_Or_Apl_Flag             VARCHAR2,
                     X_Current_Employee_Flag               VARCHAR2,
                     X_Date_Employee_Data_Verified         DATE,
                     X_Date_Of_Birth                       DATE,
                     X_Email_Address                       VARCHAR2,
                     X_Employee_Number                     VARCHAR2,
                     X_Expense_Check_To_Address       VARCHAR2,
                     X_First_Name                          VARCHAR2,
                     X_Full_Name                           VARCHAR2,
                     X_Known_As                            VARCHAR2,
                     X_Marital_Status                      VARCHAR2,
                     X_Middle_Names                        VARCHAR2,
                     X_Nationality                         VARCHAR2,
                     X_National_Identifier                 VARCHAR2,
                     X_Previous_Last_Name                  VARCHAR2,
                     X_Registered_Disabled_Flag            VARCHAR2,
                     X_Sex                                 VARCHAR2,
                     X_Title                               VARCHAR2,
                     X_Vendor_Id                           NUMBER,
                     X_Work_Telephone                      VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
                     X_Attribute21                         VARCHAR2,
                     X_Attribute22                         VARCHAR2,
                     X_Attribute23                         VARCHAR2,
                     X_Attribute24                         VARCHAR2,
                     X_Attribute25                         VARCHAR2,
                     X_Attribute26                         VARCHAR2,
                     X_Attribute27                         VARCHAR2,
                     X_Attribute28                         VARCHAR2,
                     X_Attribute29                         VARCHAR2,
                     X_Attribute30                         VARCHAR2,
                     X_Per_Information_Category            VARCHAR2,
                     X_Per_Information1                    VARCHAR2,
                     X_Per_Information2                    VARCHAR2,
                     X_Per_Information3                    VARCHAR2,
                     X_Per_Information4                    VARCHAR2,
                     X_Per_Information5                    VARCHAR2,
                     X_Per_Information6                    VARCHAR2,
                     X_Per_Information7                    VARCHAR2,
                     X_Per_Information8                    VARCHAR2,
                     X_Per_Information9                    VARCHAR2,
                     X_Per_Information10                   VARCHAR2,
                     X_Per_Information11                   VARCHAR2,
                     X_Per_Information12                   VARCHAR2,
                     X_Per_Information13                   VARCHAR2,
                     X_Per_Information14                   VARCHAR2,
                     X_Per_Information15                   VARCHAR2,
                     X_Per_Information16                   VARCHAR2,
                     X_Per_Information17                   VARCHAR2,
                     X_Per_Information18                   VARCHAR2,
                     X_Per_Information19                   VARCHAR2,
                     X_Per_Information20                   VARCHAR2,
                     X_Per_Information21                   VARCHAR2,
                     X_Per_Information22                   VARCHAR2,
                     X_Per_Information23                   VARCHAR2,
                     X_Per_Information24                   VARCHAR2,
                     X_Per_Information25                   VARCHAR2,
                     X_Per_Information26                   VARCHAR2,
                     X_Per_Information27                   VARCHAR2,
                     X_Per_Information28                   VARCHAR2,
                     X_Per_Information29                   VARCHAR2,
                     X_Per_Information30                   VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE,
                     X_Order_Name                          VARCHAR2,
                     X_Global_Name                         VARCHAR2,
                     X_Local_Name                          VARCHAR2,
                     X_PERIOD_OF_SERVICE_ID         IN OUT NOCOPY NUMBER,
				 X_TOWN_OF_BIRTH                       VARCHAR2 DEFAULT NULL,
				 X_REGION_OF_BIRTH                     VARCHAR2 DEFAULT NULL,
				 X_COUNTRY_OF_BIRTH                    VARCHAR2 DEFAULT NULL,
			      X_GLOBAL_PERSON_ID                    VARCHAR2 DEFAULT NULL,
                     X_blood_type            VARCHAR2 default NULL,
                     X_correspondence_language VARCHAR2 default NULL,
                     X_honors                 VARCHAR2 default NULL,
                     X_pre_name_adjunct       VARCHAR2 default NULL,
                     X_rehire_authorizor      VARCHAR2 default NULL,
                     X_rehire_recommendation  VARCHAR2 default NULL,
                     X_resume_exists          VARCHAR2 default NULL,
                     X_resume_last_updated    DATE default NULL,
                     X_second_passport_exists VARCHAR2 default NULL,
                     X_student_status     VARCHAR2 default NULL,
                     X_suffix             VARCHAR2 default NULL,
                     X_date_of_death      DATE default NULL,
                     X_uses_tobacco_flag  VARCHAR2 default NULL,
                     X_fast_path_employee VARCHAR2 default NULL,
                     X_fte_capacity    VARCHAR2 default NULL
 ) IS
l_period_of_service_id NUMBER;
   CURSOR C IS SELECT ROWID FROM PER_ALL_PEOPLE_F
             WHERE person_id = X_Person_Id;
    CURSOR C2 IS SELECT per_people_s.NEXTVAL FROM sys.dual;
--
CURSOR c_person IS
  SELECT *
  FROM   per_all_people_f
  WHERE  person_id = x_person_id
  AND    x_effective_start_date
         BETWEEN effective_start_date
         AND     effective_end_date;
--
l_person per_all_people_f%ROWTYPE;
--
l_phone_ovn        NUMBER       := NULL ;
l_phone_id         NUMBER       := NULL ;
  l_proc VARCHAR2(72):='per_people_v14_pkg.insert_row';
--
BEGIN
  hr_utility.set_location('Entering: '||l_proc,10);
   IF (X_Person_Id IS NULL) THEN
     OPEN C2;
     FETCH C2 INTO X_Person_Id;
     CLOSE C2;
   END IF;

   -- Verify party id, if one is passed in
   IF X_party_id IS NOT NULL THEN
     --
     per_per_bus.chk_party_id
       (p_person_id             => X_person_id
       ,p_party_id              => X_party_id
       ,p_effective_date        => X_effective_start_date
       ,p_object_version_number => NULL);
   END IF;
   hr_utility.set_location(l_proc,20);
  INSERT INTO PER_ALL_PEOPLE_F(
          person_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          person_type_id,
          last_name,
          start_date,
          applicant_number,
          comment_id,
          current_applicant_flag,
          current_emp_or_apl_flag,
          current_employee_flag,
          date_employee_data_verified,
          date_of_birth,
          email_address,
          employee_number,
          expense_check_send_to_address,
          first_name,
          full_name,
          known_as,
          marital_status,
          middle_names,
          nationality,
          national_identifier,
          previous_last_name,
          registered_disabled_flag,
          sex,
          title,
          vendor_id,
    --    work_telephone,      -- Now handled by the Create_phone call.
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          per_information_category,
          per_information1,
          per_information2,
          per_information3,
          per_information4,
          per_information5,
          per_information6,
          per_information7,
          per_information8,
          per_information9,
          per_information10,
          per_information11,
          per_information12,
          per_information13,
          per_information14,
          per_information15,
          per_information16,
          per_information17,
          per_information18,
          per_information19,
          per_information20,
          per_information21,
          per_information22,
          per_information23,
          per_information24,
          per_information25,
          per_information26,
          per_information27,
          per_information28,
          per_information29,
          per_information30,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date,
		town_of_birth,
		region_of_birth,
		country_of_birth,
		global_person_id,
        party_id,
        blood_type,
        correspondence_language,
        honors,
        pre_name_adjunct,
        rehire_authorizor,
        rehire_recommendation,
        resume_exists,
        resume_last_updated,
        second_passport_exists,
        student_status,
        suffix,
        date_of_death,
        uses_tobacco_flag,
        fast_path_employee,
        fte_capacity,
        order_name,   -- #3889584
        global_name,
        local_name
         ) VALUES (
          X_Person_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
--          X_Person_Type_Id,
          hr_person_type_usage_info.get_default_person_type_id(X_Person_Type_Id),
          X_Last_Name,
          X_Start_Date,
          X_Applicant_Number,
          X_Comment_Id,
          X_Current_Applicant_Flag,
          X_Current_Emp_Or_Apl_Flag,
          X_Current_Employee_Flag,
          X_Date_Employee_Data_Verified,
          X_Date_Of_Birth,
          X_Email_Address,
          X_Employee_Number,
          X_Expense_Check_To_Address,
          X_First_Name,
          X_Full_Name,
          X_Known_As,
          X_Marital_Status,
          X_Middle_Names,
          X_Nationality,
          X_National_Identifier,
          X_Previous_Last_Name,
          X_Registered_Disabled_Flag,
          X_Sex,
          X_Title,
          X_Vendor_Id,
--        X_Work_Telephone, -- Now handled by the Create_phone call.
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
          X_Attribute21,
          X_Attribute22,
          X_Attribute23,
          X_Attribute24,
          X_Attribute25,
          X_Attribute26,
          X_Attribute27,
          X_Attribute28,
          X_Attribute29,
          X_Attribute30,
          X_per_information_category,
          X_per_information1,
          X_per_information2,
          X_per_information3,
          X_per_information4,
          X_per_information5,
          X_per_information6,
          X_per_information7,
          X_per_information8,
          X_per_information9,
          X_per_information10,
          X_per_information11,
          X_per_information12,
          X_per_information13,
          X_per_information14,
          X_per_information15,
          X_per_information16,
          X_per_information17,
          X_per_information18,
          X_per_information19,
          X_per_information20,
          X_per_information21,
          X_per_information22,
          X_per_information23,
          X_per_information24,
          X_per_information25,
          X_per_information26,
          X_per_information27,
          X_per_information28,
          X_per_information29,
          X_per_information30,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Created_By,
          X_Creation_Date,
		X_town_of_birth,
		X_region_of_birth,
		X_country_of_birth,
		X_global_person_id,
          X_party_id,
          X_blood_type,
          X_correspondence_language,
          X_honors,
          X_pre_name_adjunct,
          X_rehire_authorizor,
          X_rehire_recommendation,
          X_resume_exists,
          X_resume_last_updated,
          X_second_passport_exists,
          X_student_status,
          X_suffix,
          X_date_of_death,
          X_uses_tobacco_flag,
          X_fast_path_employee,
          X_fte_capacity,
          X_Order_Name,
          X_Global_Name,
          X_Local_Name);

  hr_utility.set_location(l_proc,30);
  --kramajey uncommented the part of the commented code to make sure the person details are
  --populated in l_person Bug 4093145

  --
  OPEN c_person;
    --
    FETCH c_person INTO l_person;
    --
  CLOSE c_person;
  --
    /* BEGIN OF PARTY_ID WORK */
  /* This is being commented out as part of TCA party unmerge. This part of the code
   is being called from per_person_type_usage_internal.maintain_person_type_usage
  --
  per_hrtca_merge.create_tca_person(p_rec => l_person);
  hr_utility.set_location('UPDATING party id',10);
  --
  -- Now assign the resulting party id back to the record.
  --
--Bug fix 4861893
--update statement modified ,per_All_people_f used  instead of per_people_f.
IF x_party_id IS NULL THEN
    UPDATE per_all_people_f
       SET party_id = l_person.party_id
     WHERE person_id = x_person_id;
  END IF;
  --
  */
  /* END OF PARTY ID WORK */
  --
  -- HR/WF synchronization call
  --
  per_hrwf_synch.per_per_wf(p_rec      => l_person,
                            p_action   => 'INSERT');
  --
  --
  -- Create a phone row if the work_telephone parm is not null.
  -- Use p_start_date (i.e., p_date_received passed from per_applicant_pkg)
  -- as the value for effective date and date from.
  --
  IF x_work_telephone IS NOT NULL THEN
  hr_utility.set_location(l_proc,40);
         hr_phone_api.create_phone
            (p_date_from                 => x_effective_start_date
            ,p_date_to                   => NULL
            ,p_phone_type                => 'W1'
            ,p_phone_number              => x_work_telephone
            ,p_parent_id                 => x_person_id
            ,p_parent_table              => 'PER_ALL_PEOPLE_F'
            ,p_validate                  => FALSE
            ,p_effective_date            => x_start_date
            ,p_object_version_number     => l_phone_ovn  --out
            ,p_phone_id                  => l_phone_id   --out
            );
  END IF;
  hr_utility.set_location(l_proc,50);
  --
  OPEN C;
  FETCH C INTO X_Rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;
  hr_utility.set_location(l_proc,60);
--
-- add the person to the security lists
--
  IF (X_current_emp_or_apl_flag='Y') THEN
  hr_utility.set_location(l_proc,70);
    hr_security_internal.populate_new_person
    (p_person_id         => X_Person_Id
    ,p_business_group_id => X_Business_group_Id);
  END IF;
  hr_utility.set_location(l_proc,80);
  IF (X_current_employee_flag IS NOT NULL)
  THEN
  hr_utility.set_location(l_proc,90);
    insert_period_of_service(X_Person_id => X_Person_Id
                            ,X_Business_Group_Id => X_Business_Group_id
                            ,X_Date_Start => X_effective_Start_Date
                            ,X_Period_Of_Service_Id => X_Period_Of_Service_Id
                            );
  END IF;
-- PTU : Start of Changes

 hr_per_type_usage_internal.maintain_person_type_usage
        (p_effective_date       => X_effective_Start_Date
        ,p_person_id            => X_Person_Id
        ,p_person_type_id       => X_Person_Type_Id
        );

-- PTU : End of Changes

  hr_utility.set_location('Leaving '||l_proc,100);
END Insert_Row;
--
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Person_Id                             NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Person_Type_Id                        NUMBER,
                   X_Last_Name                             VARCHAR2,
                   X_Start_Date                            DATE,
                   X_Applicant_Number                      VARCHAR2,
                   X_Comment_Id                            NUMBER,
                   X_Current_Applicant_Flag                VARCHAR2,
                   X_Current_Emp_Or_Apl_Flag               VARCHAR2,
                   X_Current_Employee_Flag                 VARCHAR2,
                   X_Date_Employee_Data_Verified           DATE,
                   X_Date_Of_Birth                         DATE,
                   X_Email_Address                         VARCHAR2,
                   X_Employee_Number                       VARCHAR2,
                   X_Expense_Check_To_Address              VARCHAR2,
                   X_First_Name                            VARCHAR2,
                   X_Full_Name                             VARCHAR2,
                   X_Known_As                              VARCHAR2,
                   X_Marital_Status                        VARCHAR2,
                   X_Middle_Names                          VARCHAR2,
                   X_Nationality                           VARCHAR2,
                   X_National_Identifier                   VARCHAR2,
                   X_Previous_Last_Name                    VARCHAR2,
                   X_Registered_Disabled_Flag              VARCHAR2,
                   X_Sex                                   VARCHAR2,
                   X_Title                                 VARCHAR2,
                   X_Vendor_Id                             NUMBER,
                   X_Work_Telephone                        VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2,
                   X_Attribute21                           VARCHAR2,
                   X_Attribute22                           VARCHAR2,
                   X_Attribute23                           VARCHAR2,
                   X_Attribute24                           VARCHAR2,
                   X_Attribute25                           VARCHAR2,
                   X_Attribute26                           VARCHAR2,
                   X_Attribute27                           VARCHAR2,
                   X_Attribute28                           VARCHAR2,
                   X_Attribute29                           VARCHAR2,
                   X_Attribute30                           VARCHAR2,
                   X_Per_Information_Category              VARCHAR2,
                   X_Per_Information1                      VARCHAR2,
                   X_Per_Information2                      VARCHAR2,
                   X_Per_Information3                      VARCHAR2,
                   X_Per_Information4                      VARCHAR2,
                   X_Per_Information5                      VARCHAR2,
                   X_Per_Information6                      VARCHAR2,
                   X_Per_Information7                      VARCHAR2,
                   X_Per_Information8                      VARCHAR2,
                   X_Per_Information9                      VARCHAR2,
                   X_Per_Information10                     VARCHAR2,
                   X_Per_Information11                     VARCHAR2,
                   X_Per_Information12                     VARCHAR2,
                   X_Per_Information13                     VARCHAR2,
                   X_Per_Information14                     VARCHAR2,
                   X_Per_Information15                     VARCHAR2,
                   X_Per_Information16                     VARCHAR2,
                   X_Per_Information17                     VARCHAR2,
                   X_Per_Information18                     VARCHAR2,
                   X_Per_Information19                     VARCHAR2,
                   X_Per_Information20                     VARCHAR2,
                   X_Per_Information21                     VARCHAR2,
                   X_Per_Information22                     VARCHAR2,
                   X_Per_Information23                     VARCHAR2,
                   X_Per_Information24                     VARCHAR2,
                   X_Per_Information25                     VARCHAR2,
                   X_Per_Information26                     VARCHAR2,
                   X_Per_Information27                     VARCHAR2,
                   X_Per_Information28                     VARCHAR2,
                   X_Per_Information29                     VARCHAR2,
                   X_Per_Information30                     VARCHAR2) IS

  CURSOR C IS
      SELECT *
      FROM   PER_ALL_PEOPLE_F
      WHERE  ROWID = X_Rowid
      FOR UPDATE OF Person_Id  NOWAIT;
  Recinfo C%ROWTYPE;

  --
  -- Declare a similar cursor to lock the phone row.
  --
  CURSOR csr_phones IS
      SELECT phone_number
      FROM per_phones
      WHERE parent_id = X_person_id
      FOR UPDATE OF phone_id NOWAIT;
  phoneinfo csr_phones%ROWTYPE;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

  OPEN csr_phones;
  FETCH csr_phones INTO phoneinfo;
    -- no need to raise an error if no data found. Phone is not mandatory.
  CLOSE csr_phones;

  IF (
          (   (Recinfo.person_id = X_Person_Id)
           OR (    (Recinfo.person_id IS NULL)
               AND (X_Person_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
-- PTU : Changes
--      AND (   (Recinfo.person_type_id = X_Person_Type_Id)
--           OR (    (Recinfo.person_type_id IS NULL)
--               AND (X_Person_Type_Id IS NULL)))
-- PTU : End Changes
      AND (   (Recinfo.last_name = X_Last_Name)
           OR (    (Recinfo.last_name IS NULL)
               AND (X_Last_Name IS NULL)))
      AND (   (Recinfo.start_date = X_Start_Date)
           OR (    (Recinfo.start_date IS NULL)
               AND (X_Start_Date IS NULL)))
      AND (   (Recinfo.applicant_number = X_Applicant_Number)
           OR (    (Recinfo.applicant_number IS NULL)
               AND (X_Applicant_Number IS NULL)))
      AND (   (Recinfo.comment_id = X_Comment_Id)
           OR (    (Recinfo.comment_id IS NULL)
               AND (X_Comment_Id IS NULL)))
      AND (   (Recinfo.current_applicant_flag = X_Current_Applicant_Flag)
           OR (    (Recinfo.current_applicant_flag IS NULL)
               AND (X_Current_Applicant_Flag IS NULL)))
      AND (   (Recinfo.current_emp_or_apl_flag = X_Current_Emp_Or_Apl_Flag)
           OR (    (Recinfo.current_emp_or_apl_flag IS NULL)
               AND (X_Current_Emp_Or_Apl_Flag IS NULL)))
      AND (   (Recinfo.current_employee_flag = X_Current_Employee_Flag)
           OR (    (Recinfo.current_employee_flag IS NULL)
               AND (X_Current_Employee_Flag IS NULL)))
      AND (
(Recinfo.date_employee_data_verified = X_Date_Employee_Data_Verified)
           OR (    (Recinfo.date_employee_data_verified IS NULL)
               AND (X_Date_Employee_Data_Verified IS NULL)))
      AND (   (Recinfo.date_of_birth = X_Date_Of_Birth)
           OR (    (Recinfo.date_of_birth IS NULL)
               AND (X_Date_Of_Birth IS NULL)))
      AND (   (Recinfo.email_address = X_Email_Address)
           OR (    (Recinfo.email_address IS NULL)
               AND (X_Email_Address IS NULL)))
      AND (   (Recinfo.employee_number = X_Employee_Number)
           OR (    (Recinfo.employee_number IS NULL)
               AND (X_Employee_Number IS NULL)))
      AND (   (Recinfo.expense_check_send_to_address =
      X_Expense_Check_To_Address)
           OR (    (Recinfo.expense_check_send_to_address IS NULL)
               AND (X_Expense_Check_To_Address IS NULL)))
      AND (   (Recinfo.first_name = X_First_Name)
           OR (    (Recinfo.first_name IS NULL)
               AND (X_First_Name IS NULL)))
      AND (   (Recinfo.full_name = X_Full_Name)
           OR (    (Recinfo.full_name IS NULL)
               AND (X_Full_Name IS NULL)))
      AND (   (Recinfo.known_as = X_Known_As)
           OR (    (Recinfo.known_as IS NULL)
               AND (X_Known_As IS NULL)))
      AND (   (Recinfo.marital_status = X_Marital_Status)
           OR (    (Recinfo.marital_status IS NULL)
               AND (X_Marital_Status IS NULL)))
      AND (   (Recinfo.middle_names = X_Middle_Names)
           OR (    (Recinfo.middle_names IS NULL)
               AND (X_Middle_Names IS NULL)))
      AND (   (Recinfo.nationality = X_Nationality)
           OR (    (Recinfo.nationality IS NULL)
               AND (X_Nationality IS NULL)))
      AND (   (Recinfo.national_identifier = X_National_Identifier)
           OR (    (Recinfo.national_identifier IS NULL)
               AND (X_National_Identifier IS NULL)))
      AND (   (Recinfo.previous_last_name = X_Previous_Last_Name)
           OR (    (Recinfo.previous_last_name IS NULL)
               AND (X_Previous_Last_Name IS NULL)))
      AND (   (Recinfo.registered_disabled_flag = X_Registered_Disabled_Flag)
           OR (    (Recinfo.registered_disabled_flag IS NULL)
               AND (X_Registered_Disabled_Flag IS NULL)))
      AND (   (Recinfo.sex = X_Sex)
           OR (    (Recinfo.sex IS NULL)
               AND (X_Sex IS NULL)))
      AND (   (Recinfo.title = X_Title)
           OR (    (Recinfo.title IS NULL)
               AND (X_Title IS NULL)))
      AND (   (Recinfo.vendor_id = X_Vendor_Id)
           OR (    (Recinfo.vendor_id IS NULL)
               AND (X_Vendor_Id IS NULL)))
      AND (   (phoneinfo.phone_number = X_Work_Telephone)
           OR (    (phoneinfo.phone_number IS NULL)
               AND (X_Work_Telephone IS NULL)))

       )
THEN
     IF (
         (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
      AND (   (Recinfo.attribute21 = X_Attribute21)
           OR (    (Recinfo.attribute21 IS NULL)
               AND (X_Attribute21 IS NULL)))
      AND (   (Recinfo.attribute22 = X_Attribute22)
           OR (    (Recinfo.attribute22 IS NULL)
               AND (X_Attribute22 IS NULL)))
      AND (   (Recinfo.attribute23 = X_Attribute23)
           OR (    (Recinfo.attribute23 IS NULL)
               AND (X_Attribute23 IS NULL)))
      AND (   (Recinfo.attribute24 = X_Attribute24)
           OR (    (Recinfo.attribute24 IS NULL)
               AND (X_Attribute24 IS NULL)))
      AND (   (Recinfo.attribute25 = X_Attribute25)
           OR (    (Recinfo.attribute25 IS NULL)
               AND (X_Attribute25 IS NULL)))
      AND (   (Recinfo.attribute26 = X_Attribute26)
           OR (    (Recinfo.attribute26 IS NULL)
               AND (X_Attribute26 IS NULL)))
      AND (   (Recinfo.attribute27 = X_Attribute27)
           OR (    (Recinfo.attribute27 IS NULL)
               AND (X_Attribute27 IS NULL)))
      AND (   (Recinfo.attribute28 = X_Attribute28)
           OR (    (Recinfo.attribute28 IS NULL)
               AND (X_Attribute28 IS NULL)))
      AND (   (Recinfo.attribute29 = X_Attribute29)
           OR (    (Recinfo.attribute29 IS NULL)
               AND (X_Attribute29 IS NULL)))
      AND (   (Recinfo.attribute30 = X_Attribute30)
           OR (    (Recinfo.attribute30 IS NULL)
               AND (X_Attribute30 IS NULL)))
      AND (   (Recinfo.per_information_category = X_Per_Information_Category)
           OR (    (Recinfo.per_information_category IS NULL)
               AND (X_Per_Information_Category IS NULL)))
      AND (   (Recinfo.per_information1 = X_Per_Information1)
           OR (    (Recinfo.per_information1 IS NULL)
               AND (X_Per_Information1 IS NULL)))
      AND (   (Recinfo.per_information2 = X_Per_Information2)
           OR (    (Recinfo.per_information2 IS NULL)
               AND (X_Per_Information2 IS NULL)))
      AND (   (Recinfo.per_information3 = X_Per_Information3)
           OR (    (Recinfo.per_information3 IS NULL)
               AND (X_Per_Information3 IS NULL)))
      AND (   (Recinfo.per_information4 = X_Per_Information4)
           OR (    (Recinfo.per_information4 IS NULL)
               AND (X_Per_Information4 IS NULL)))
      AND (   (Recinfo.per_information5 = X_Per_Information5)
           OR (    (Recinfo.per_information5 IS NULL)
               AND (X_Per_Information5 IS NULL)))
      AND (   (Recinfo.per_information6 = X_Per_Information6)
           OR (    (Recinfo.per_information6 IS NULL)
               AND (X_Per_Information6 IS NULL)))
      AND (   (Recinfo.per_information7 = X_Per_Information7)
           OR (    (Recinfo.per_information7 IS NULL)
               AND (X_Per_Information7 IS NULL)))
      AND (   (Recinfo.per_information8 = X_Per_Information8)
           OR (    (Recinfo.per_information8 IS NULL)
               AND (X_Per_Information8 IS NULL)))
      AND (   (Recinfo.per_information9 = X_Per_Information9)
           OR (    (Recinfo.per_information9 IS NULL)
               AND (X_Per_Information9 IS NULL)))
      AND (   (Recinfo.per_information10 = X_Per_Information10)
           OR (    (Recinfo.per_information10 IS NULL)
               AND (X_Per_Information10 IS NULL)))
      AND (   (Recinfo.per_information11 = X_Per_Information11)
           OR (    (Recinfo.per_information11 IS NULL)
               AND (X_Per_Information11 IS NULL)))
      AND (   (Recinfo.per_information12 = X_Per_Information12)
           OR (    (Recinfo.per_information12 IS NULL)
               AND (X_Per_Information12 IS NULL)))
      AND (   (Recinfo.per_information13 = X_Per_Information13)
           OR (    (Recinfo.per_information13 IS NULL)
               AND (X_Per_Information13 IS NULL)))
      AND (   (Recinfo.per_information14 = X_Per_Information14)
           OR (    (Recinfo.per_information14 IS NULL)
               AND (X_Per_Information14 IS NULL)))
      AND (   (Recinfo.per_information15 = X_Per_Information15)
           OR (    (Recinfo.per_information15 IS NULL)
               AND (X_Per_Information15 IS NULL)))
      AND (   (Recinfo.per_information16 = X_Per_Information16)
           OR (    (Recinfo.per_information16 IS NULL)
               AND (X_Per_Information16 IS NULL)))
      AND (   (Recinfo.per_information17 = X_Per_Information17)
           OR (    (Recinfo.per_information17 IS NULL)
               AND (X_Per_Information17 IS NULL)))
      AND (   (Recinfo.per_information18 = X_Per_Information18)
           OR (    (Recinfo.per_information18 IS NULL)
               AND (X_Per_Information18 IS NULL)))
      AND (   (Recinfo.per_information19 = X_Per_Information19)
           OR (    (Recinfo.per_information19 IS NULL)
               AND (X_Per_Information19 IS NULL)))
      AND (   (Recinfo.per_information20 = X_Per_Information20)
           OR (    (Recinfo.per_information20 IS NULL)
               AND (X_Per_Information20 IS NULL)))
      AND (   (Recinfo.per_information21 = X_Per_Information21)
           OR (    (Recinfo.per_information21 IS NULL)
               AND (X_Per_Information21 IS NULL)))
      AND (   (Recinfo.per_information22 = X_Per_Information22)
           OR (    (Recinfo.per_information22 IS NULL)
               AND (X_Per_Information22 IS NULL)))
      AND (   (Recinfo.per_information23 = X_Per_Information23)
           OR (    (Recinfo.per_information23 IS NULL)
               AND (X_Per_Information23 IS NULL)))
      AND (   (Recinfo.per_information24 = X_Per_Information24)
           OR (    (Recinfo.per_information24 IS NULL)
               AND (X_Per_Information24 IS NULL)))
      AND (   (Recinfo.per_information25 = X_Per_Information25)
           OR (    (Recinfo.per_information25 IS NULL)
               AND (X_Per_Information25 IS NULL)))
      AND (   (Recinfo.per_information26 = X_Per_Information26)
           OR (    (Recinfo.per_information26 IS NULL)
               AND (X_Per_Information26 IS NULL)))
      AND (   (Recinfo.per_information27 = X_Per_Information27)
           OR (    (Recinfo.per_information27 IS NULL)
               AND (X_Per_Information27 IS NULL)))
      AND (   (Recinfo.per_information28 = X_Per_Information28)
           OR (    (Recinfo.per_information28 IS NULL)
               AND (X_Per_Information28 IS NULL)))
      AND (   (Recinfo.per_information29 = X_Per_Information29)
           OR (    (Recinfo.per_information29 IS NULL)
               AND (X_Per_Information29 IS NULL)))
      AND (   (Recinfo.per_information30 = X_Per_Information30)
           OR (    (Recinfo.per_information30 IS NULL)
               AND (X_Per_Information30 IS NULL)))
          ) THEN
    RETURN;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
 END IF;
END Lock_Row;
--
END PER_PEOPLE_V14_PKG;

/
