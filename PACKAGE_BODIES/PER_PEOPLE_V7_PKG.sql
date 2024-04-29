--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE_V7_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE_V7_PKG" as
/* $Header: peper07t.pkb 120.2.12000000.6 2007/05/02 14:02:03 asgugupt noship $ */
--
--bug no 6028006 starts here
--g_package  varchar2(18) := '  PER_PEOPLE_V7_PKG.';
g_package  varchar2(18) := 'PER_PEOPLE_V7_PKG.';
--bug no 6028006 ends here
g_debug    boolean; -- debug flag
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Effective_Start_Date         IN OUT NOCOPY DATE,
                     X_Effective_End_Date           IN OUT NOCOPY DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Start_Date                   IN OUT NOCOPY DATE,
                     X_Hire_date                           DATE,
                     X_S_Hire_Date                         DATE,
                     X_Period_of_service_id                NUMBER,
                     X_Termination_Date                    DATE,
                     X_S_Termination_Date                  DATE,
                     X_Applicant_Number                    VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Current_Applicant_Flag              VARCHAR2,
                     X_Current_Emp_Or_Apl_Flag             VARCHAR2,
                     X_Current_Employee_Flag               VARCHAR2,
                     X_Date_Employee_Data_Verified         DATE,
                     X_Date_Of_Birth                       DATE,
                     X_Email_Address                       VARCHAR2,
                     X_Employee_Number                     VARCHAR2,
                     X_Expense_Check_To_Address            VARCHAR2,
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
                     X_Current_Application_Id              NUMBER, --DEFAULT NULL
                     X_Order_Name                          VARCHAR2,
                     X_Global_Name                         VARCHAR2,
                     X_Local_Name                          VARCHAR2
) IS
  --
  l_old_work_telephone           per_phones.phone_number%TYPE;
  l_phn_object_version_number    per_phones.object_version_number%TYPE;
  l_phone_id                     per_phones.phone_id%TYPE;
  --
  cursor csr_phones is
         select    phone_number, phone_id,  phn.object_version_number
         from      per_phones phn
         --
         -- Removed fnd_sessions_f table in From Clause
         -- becuase it is not used in the data retrieval at all.
         --        fnd_sessions f
         --
         where     phn.parent_id = x_person_id
         and       phn.parent_table = 'PER_ALL_PEOPLE_F'
         and       phn.phone_type = 'W1'
         and       x_start_date between phn.date_from and
                        nvl(phn.date_to,x_start_date);
  /* BEGIN OF WWBUG 1975359 */
  cursor c1 is
    select party_id
    from   per_all_people_f
    where  person_id = x_person_id;
  --
  l_party_id number;
  --
  cursor c_person is
    select *
    from   per_all_people_f
    where  person_id = x_person_id
    and    x_effective_start_date
           between effective_start_date
           and     effective_end_date;
  --
  l_person per_all_people_f%rowtype;
  --
  /* END OF WWBUG 1975359 */
BEGIN
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',10);
  if X_Current_Application_Id = 810
  then
    per_people_v7_pkg.check_person_changes(X_person_id
							,X_hire_date
							,X_s_hire_Date
							,X_current_application_id );
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',20);
  end if;
  if X_termination_date is not null
  and X_S_termination_date is null
  and X_current_employee_flag = 'Y'
  then
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',30);
    per_people_v7_pkg.check_person_changes(X_person_id
                     ,X_termination_date
                     ,X_Hire_date
                     ,X_current_application_id );
   X_effective_end_date := X_termination_date;
  elsif x_hire_date <> X_s_hire_date then
   X_effective_start_date := X_hire_date;
   X_start_date := X_hire_date;
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',40);
  end if;
  /* BEGIN OF WWBUG 1975359 */
  open c1;
     --
     fetch c1 into l_party_id;
     --
   close c1;
  /* END OF WWBUG 1975359 */
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',50);
  UPDATE PER_PEOPLE_F
  SET
    person_id                             =    X_Person_Id,
    party_id                              =    l_Party_Id,
    effective_start_date                  =    X_Effective_Start_Date,
    effective_end_date                    =    X_Effective_End_Date,
    business_group_id                     =    X_Business_Group_Id,
    person_type_id                        =    -- X_Person_Type_Id,
    hr_person_type_usage_info.get_default_person_type_id(X_Person_Type_Id),
    last_name                             =    X_Last_Name,
    start_date                            =    X_Start_Date,
    applicant_number                      =    X_Applicant_Number,
    comment_id                            =    X_Comment_Id,
    current_applicant_flag                =    X_Current_Applicant_Flag,
    current_emp_or_apl_flag               =    X_Current_Emp_Or_Apl_Flag,
    current_employee_flag                 =    X_Current_Employee_Flag,
    date_employee_data_verified           =    X_Date_Employee_Data_Verified,
    date_of_birth                         =    X_Date_Of_Birth,
    email_address                         =    X_Email_Address,
    employee_number                       =    X_Employee_Number,
    expense_check_send_to_address         =    X_Expense_Check_To_Address,
    first_name                            =    X_First_Name,
    full_name                             =    X_Full_Name,
    known_as                              =    X_Known_As,
    marital_status                        =    X_Marital_Status,
    middle_names                          =    X_Middle_Names,
    nationality                           =    X_Nationality,
    national_identifier                   =    X_National_Identifier,
    previous_last_name                    =    X_Previous_Last_Name,
    registered_disabled_flag              =    X_Registered_Disabled_Flag,
    sex                                   =    X_Sex,
    title                                 =    X_Title,
    vendor_id                             =    X_Vendor_Id,
--  The update of the work_telephone data is now done on the PER_PHONES table.
--  work_telephone                        =    X_Work_Telephone,
    attribute_category                    =    X_Attribute_Category,
    attribute1                            =    X_Attribute1,
    attribute2                            =    X_Attribute2,
    attribute3                            =    X_Attribute3,
    attribute4                            =    X_Attribute4,
    attribute5                            =    X_Attribute5,
    attribute6                            =    X_Attribute6,
    attribute7                            =    X_Attribute7,
    attribute8                            =    X_Attribute8,
    attribute9                            =    X_Attribute9,
    attribute10                           =    X_Attribute10,
    attribute11                           =    X_Attribute11,
    attribute12                           =    X_Attribute12,
    attribute13                           =    X_Attribute13,
    attribute14                           =    X_Attribute14,
    attribute15                           =    X_Attribute15,
    attribute16                           =    X_Attribute16,
    attribute17                           =    X_Attribute17,
    attribute18                           =    X_Attribute18,
    attribute19                           =    X_Attribute19,
    attribute20                           =    X_Attribute20,
    attribute21                           =    X_Attribute21,
    attribute22                           =    X_Attribute22,
    attribute23                           =    X_Attribute23,
    attribute24                           =    X_Attribute24,
    attribute25                           =    X_Attribute25,
    attribute26                           =    X_Attribute26,
    attribute27                           =    X_Attribute27,
    attribute28                           =    X_Attribute28,
    attribute29                           =    X_Attribute29,
    attribute30                           =    X_Attribute30,
    per_information_category              =    X_Per_Information_Category,
    per_information1                      =    X_Per_Information1,
    per_information2                      =    X_Per_Information2,
    per_information3                      =    X_Per_Information3,
    per_information4                      =    X_Per_Information4,
    per_information5                      =    X_Per_Information5,
    per_information6                      =    X_Per_Information6,
    per_information7                      =    X_Per_Information7,
    per_information8                      =    X_Per_Information8,
    per_information9                      =    X_Per_Information9,
    per_information10                     =    X_Per_Information10,
    per_information11                     =    X_Per_Information11,
    per_information12                     =    X_Per_Information12,
    per_information13                     =    X_Per_Information13,
    per_information14                     =    X_Per_Information14,
    per_information15                     =    X_Per_Information15,
    per_information16                     =    X_Per_Information16,
    per_information17                     =    X_Per_Information17,
    per_information18                     =    X_Per_Information18,
    per_information19                     =    X_Per_Information19,
    per_information20                     =    X_Per_Information20,
    per_information21                     =    X_Per_Information21,
    per_information22                     =    X_Per_Information22,
    per_information23                     =    X_Per_Information23,
    per_information24                     =    X_Per_Information24,
    per_information25                     =    X_Per_Information25,
    per_information26                     =    X_Per_Information26,
    per_information27                     =    X_Per_Information27,
    per_information28                     =    X_Per_Information28,
    per_information29                     =    X_Per_Information29,
    per_information30                     =    X_Per_Information30,
    order_name                            =    X_Order_Name,    -- #3889584
    global_name                           =    X_Global_Name,
    local_name                            =    X_Local_Name,
    last_update_date                      =    X_Last_Update_Date,
    last_updated_by                       =    X_Last_Updated_By,
    last_update_login                     =    X_Last_Update_Login
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
--
-- #2221990
-- This should be added later depending on the type of transaction
-- generated.
--
-- PTU : Start of Changes
--
-- hr_per_type_usage_internal.maintain_person_type_usage
--        (p_effective_date       => X_effective_Start_Date
--        ,p_person_id            => X_Person_Id
--        ,p_person_type_id       => X_Person_Type_Id
--        ,p_datetrack_update_mode=> 'CORRECTION'
--        );
--
hr_utility.set_location('per_people_v7_pkg.update_row',55);
-- PTU : End of Changes

   /* BEGIN OF WWBUG 1975359 */
   --
   open c_person;
     --
     fetch c_person into l_person;
     --
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',60);
   close c_person;
   --
   per_hrtca_merge.update_tca_person(p_Rec => l_person);
   --
   hr_utility.set_location('update_row - after update',1);
   --
   /* END OF WWBUG 1975359 */
   --
   -- HR/WF Synchronization call
   --
   per_hrwf_synch.per_per_wf(p_rec      => l_person,
                             p_action   => 'UPDATE');
   --
  --
  -- Beginning of logic for the update of the phones table
  --
  -- Firstly, find the number, ovn and id for the old work_telephone (if it exists)
  --
  open csr_phones;
  fetch csr_phones into l_old_work_telephone,
                        l_phone_id,
                        l_phn_object_version_number;
  close csr_phones;
  --
  -- If old entry is null and new entry is not null then just use the create
  -- phone B.P.
  --
  if (l_old_work_telephone is null and
      x_work_telephone is not null) then
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',70);
     hr_phone_api.create_phone
       (p_date_from                 => x_start_date
       ,p_date_to                   => null
       ,p_phone_type                => 'W1'
       ,p_phone_number              => x_work_telephone
       ,p_parent_id                 => x_person_id
       ,p_parent_table              => 'PER_ALL_PEOPLE_F'
       ,p_validate                  => FALSE
       ,p_effective_date            => x_start_date
       ,p_object_version_number     => l_phn_object_version_number  --out
       ,p_phone_id                  => l_phone_id                   --out
       );
    --
    -- If old entry is not null and corrected entry is null then delete the phone.
    --
  elsif l_old_work_telephone is not null and x_work_telephone is null then
      hr_phone_api.delete_phone(FALSE, l_phone_id, l_phn_object_version_number);
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',80);
  --
  -- If old and corrected entries are both not null then update the row with
  -- no changes to start and to dates.
  --
  elsif l_old_work_telephone is not null and x_work_telephone is not null then
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',90);
     --
     -- 115.22: only one row is maintained in per_phones.
     -- when changing the phone, date_to should remain null. This keeps the
     -- row "open" until the "end of time"
    if ( l_old_work_telephone <> x_work_telephone) then
    -- Bug 5554383 : Added IF condition.
      hr_utility.set_location('Entering : per_people_v7_pkg.update_row',95);
      hr_phone_api.update_phone
                  (p_phone_id              => l_phone_id,
                   p_phone_number          => x_work_telephone,
                   p_date_to               => null, -- 1020074 x_termination_date,
                   p_object_version_number => l_phn_object_version_number,
                   p_effective_date        => x_effective_start_date); -- 1020074 x_start_date
    end if;
  end if;
  --
  -- End of logic for the update of the phones table
  --
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',100);
  --
if X_termination_date is not null
  and X_S_termination_date is null
  and X_current_employee_flag = 'Y'
  then
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',110);
   terminate_employment(X_period_of_service_id
                       ,X_person_id
                       ,X_Rowid
                       ,X_Business_group_id
                       ,X_termination_date);
  elsif X_hire_date <> X_s_hire_date
  then
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',120);
    update_employee_rows(X_period_of_service_id
                        ,X_person_id
                        ,X_hire_date
                        ,X_s_hire_date);
  end if;
hr_utility.set_location('Entering : per_people_v7_pkg.update_row',130);
END Update_Row;
--
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PER_PEOPLE_F
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
-- #2975471
-- ------------------------------------------------------------------ +
-- ---------------------<< create_EX_EMP >>-------------------------- |
-- ------------------------------------------------------------------ +
procedure create_EX_EMP( p_person_rec per_all_people_f%ROWTYPE
                        ,p_pos_id               NUMBER
                        ,p_person_id            NUMBER
                        ,p_Business_group_id    NUMBER
                        ,p_start_date           DATE
                        ,p_end_date             DATE)
IS
--
    c_proc_name varchar2(100) := 'PER_PEOPLE_V7_PKG.create_EX_EMP';
--
    cursor csr_ex_status is
        select ppt.person_type_id
        ,      pst.current_applicant_flag
        ,      pst.current_emp_or_apl_flag
        ,      pst.current_employee_flag
        from  per_person_types ppt
        ,     per_startup_person_types pst
        where ppt.business_group_id  = p_business_group_id  -- Bug fix 3645987
        and   pst.system_person_type = ppt.system_person_type
        and   ppt.active_flag = 'Y'
        and   ppt.default_flag = 'Y'
        and   pst.system_person_type = 'EX_EMP';
--
    l_person_type_id          number;
    l_current_emp_or_apl_flag VARCHAR2(1);
    l_current_applicant_flag  VARCHAR2(1);
    l_current_employee_flag   VARCHAR2(1);
    l_dummy_date              DATE;
    l_period_of_service_id    NUMBER;
    l_rowid                   VARCHAR2(18);
    l_person_id               per_all_people_f.person_id%TYPE;

--
begin
    hr_utility.set_location('Entering: '||c_proc_name,10);
    hr_utility.trace('p_start_date = '||to_char(p_start_date,'DD-MON-YYYY'));

    l_person_id := p_person_id;
    l_period_of_service_id := p_pos_id;

    open csr_ex_status;
    fetch csr_ex_status into l_person_type_id,l_current_emp_or_apl_flag
                            ,l_current_applicant_flag,l_current_employee_flag;
    close csr_ex_status;

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
        order_name,
        global_name,
        local_name
         ) VALUES (
          l_Person_Id,
          p_start_date,
          p_end_date,
          p_person_rec.Business_Group_Id,
          hr_person_type_usage_info.get_default_person_type_id(l_person_type_id),
          p_person_rec.Last_Name,
          p_person_rec.Start_Date,
          p_person_rec.Applicant_Number,
          p_person_rec.Comment_Id,
          l_Current_Applicant_Flag,
          l_Current_Emp_Or_Apl_Flag,
          l_Current_Employee_Flag,
          p_person_rec.Date_Employee_Data_Verified,
          p_person_rec.Date_Of_Birth,
          p_person_rec.Email_Address,
          p_person_rec.Employee_Number,
          p_person_rec.expense_check_send_to_address,
          p_person_rec.First_Name,
          p_person_rec.Full_Name,
          p_person_rec.Known_As,
          p_person_rec.Marital_Status,
          p_person_rec.Middle_Names,
          p_person_rec.Nationality,
          p_person_rec.National_Identifier,
          p_person_rec.Previous_Last_Name,
          p_person_rec.Registered_Disabled_Flag,
          p_person_rec.Sex,
          p_person_rec.Title,
          p_person_rec.Vendor_Id,
          p_person_rec.Attribute_Category,
          p_person_rec.Attribute1,
          p_person_rec.Attribute2,
          p_person_rec.Attribute3,
          p_person_rec.Attribute4,
          p_person_rec.Attribute5,
          p_person_rec.Attribute6,
          p_person_rec.Attribute7,
          p_person_rec.Attribute8,
          p_person_rec.Attribute9,
          p_person_rec.Attribute10,
          p_person_rec.Attribute11,
          p_person_rec.Attribute12,
          p_person_rec.Attribute13,
          p_person_rec.Attribute14,
          p_person_rec.Attribute15,
          p_person_rec.Attribute16,
          p_person_rec.Attribute17,
          p_person_rec.Attribute18,
          p_person_rec.Attribute19,
          p_person_rec.Attribute20,
          p_person_rec.Attribute21,
          p_person_rec.Attribute22,
          p_person_rec.Attribute23,
          p_person_rec.Attribute24,
          p_person_rec.Attribute25,
          p_person_rec.Attribute26,
          p_person_rec.Attribute27,
          p_person_rec.Attribute28,
          p_person_rec.Attribute29,
          p_person_rec.Attribute30,
          p_person_rec.per_information_category,
          p_person_rec.per_information1,
          p_person_rec.per_information2,
          p_person_rec.per_information3,
          p_person_rec.per_information4,
          p_person_rec.per_information5,
          p_person_rec.per_information6,
          p_person_rec.per_information7,
          p_person_rec.per_information8,
          p_person_rec.per_information9,
          p_person_rec.per_information10,
          p_person_rec.per_information11,
          p_person_rec.per_information12,
          p_person_rec.per_information13,
          p_person_rec.per_information14,
          p_person_rec.per_information15,
          p_person_rec.per_information16,
          p_person_rec.per_information17,
          p_person_rec.per_information18,
          p_person_rec.per_information19,
          p_person_rec.per_information20,
          p_person_rec.per_information21,
          p_person_rec.per_information22,
          p_person_rec.per_information23,
          p_person_rec.per_information24,
          p_person_rec.per_information25,
          p_person_rec.per_information26,
          p_person_rec.per_information27,
          p_person_rec.per_information28,
          p_person_rec.per_information29,
          p_person_rec.per_information30,
          p_person_rec.Last_Update_Date,
          p_person_rec.Last_Updated_By,
          p_person_rec.Last_Update_Login,
          p_person_rec.Created_By,
          p_person_rec.Creation_Date,
          p_person_rec.town_of_birth,
          p_person_rec.region_of_birth,
          p_person_rec.country_of_birth,
          p_person_rec.global_person_id,
          p_person_rec.party_id,
          p_person_rec.blood_type,
          p_person_rec.correspondence_language,
          p_person_rec.honors,
          p_person_rec.pre_name_adjunct,
          p_person_rec.rehire_authorizor,
          p_person_rec.rehire_recommendation,
          p_person_rec.resume_exists,
          p_person_rec.resume_last_updated,
          p_person_rec.second_passport_exists,
          p_person_rec.student_status,
          p_person_rec.suffix,
          p_person_rec.date_of_death,
          p_person_rec.uses_tobacco_flag,
          p_person_rec.fast_path_employee,
          p_person_rec.fte_capacity,
          p_person_rec.order_name,
          p_person_rec.global_name,
          p_person_rec.local_name);

   hr_utility.set_location('Leaving: '||c_proc_name,99);

end create_EX_EMP;
--
--

procedure terminate_employment(X_period_of_service_id NUMBER
                        ,X_person_id NUMBER
                        ,X_Rowid VARCHAR2
                        ,X_Business_group_id NUMBER
                        ,X_termination_Date DATE)
IS

cursor period
is
select actual_termination_date
from per_periods_of_service
where period_of_service_id = X_period_of_service_id
for update of actual_termination_date;
--
cursor assignment
is
select effective_end_date
from per_assignments_f
where  period_of_service_id = X_period_of_service_id
and    effective_end_date = to_date('31-12-4712','DD-MM-YYYY')
for update of effective_end_date;
--
cursor ex_status is
select ppt.person_type_id
,      pst.current_applicant_flag
,      pst.current_emp_or_apl_flag
,      pst.current_employee_flag
from  per_person_types ppt
,     per_startup_person_types pst
where ppt.business_group_id  = X_business_group_id --bug fix 3645987
and   pst.system_person_type = ppt.system_person_type
and   ppt.active_flag = 'Y'
and   ppt.default_flag = 'Y'
and   pst.system_person_type = 'EX_EMP';
cursor person
is
select *
from per_people_f
where rowid = chartorowid(X_Rowid);
--
l_proc            varchar2(20) :=  'terminate_employment';
--
per_rec person%ROWTYPE;
l_person_type_id number;
l_current_emp_or_apl_flag VARCHAR2(1);
l_current_applicant_flag VARCHAR2(1);
l_current_employee_flag VARCHAR2(1);
l_dummy_date DATE;
l_rowid VARCHAR2(18);
l_period_of_service_id NUMBER;
--
-- START WWBUG 1390173 fix
--
l_old   ben_pps_ler.g_pps_ler_rec;
l_new   ben_pps_ler.g_pps_ler_rec;
--
-- END WWBUG 1390173 fix
--
cursor c1 is
  select *
  from   per_periods_of_service
  where  period_of_service_id = x_period_of_service_id;
--
l_c1 c1%rowtype;
--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  open period;
  fetch period into l_dummy_date;
  close period;
--
-- START WWBUG 1390173 fix
--
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;
  open c1;
    fetch c1 into l_c1;
    if c1%found then
      --
      l_old.PERSON_ID := l_c1.person_id;
      l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
      l_old.DATE_START := l_c1.date_start;
      l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
      l_old.LEAVING_REASON := l_c1.leaving_reason;
      l_old.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
      l_old.ATTRIBUTE1 := l_c1.attribute1;
      l_old.ATTRIBUTE2 := l_c1.attribute2;
      l_old.ATTRIBUTE3 := l_c1.attribute3;
      l_old.ATTRIBUTE4 := l_c1.attribute4;
      l_old.ATTRIBUTE5 := l_c1.attribute5;
      l_old.final_process_date := l_c1.final_process_date;
      l_new.PERSON_ID := l_c1.person_id;
      l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
      l_new.DATE_START := l_c1.date_start;
      l_new.ACTUAL_TERMINATION_DATE := x_termination_date;
      l_new.LEAVING_REASON := l_c1.leaving_reason;
      l_new.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
      l_new.ATTRIBUTE1 := l_c1.attribute1;
      l_new.ATTRIBUTE2 := l_c1.attribute2;
      l_new.ATTRIBUTE3 := l_c1.attribute3;
      l_new.ATTRIBUTE4 := l_c1.attribute4;
      l_new.ATTRIBUTE5 := l_c1.attribute5;
      l_new.final_process_date := X_termination_date;
      --
      ben_pps_ler.ler_chk(p_old            => l_old
                         ,p_new            => l_new
                         ,p_event          => 'UPDATING'
                         ,p_effective_date => l_c1.date_start);
      --
    end if;
  close c1;
--
-- END WWBUG 1390173 fix
--
--START HR/WF Synchronization  --tpapired
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;
    per_hrwf_synch.per_pds_wf(
                          p_rec     => l_c1,
                          p_date    => X_termination_date,
                          p_action  => 'TERMINATION');
--
--END   HR/WF Synchronization  --tpapired
--
  begin
    update per_periods_of_service
    set    actual_termination_date = X_termination_date
    ,      final_process_date = X_termination_date
    ,      last_standard_process_date = X_termination_date
    where  period_of_service_id = X_period_of_service_id;
  end;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 30);
  END IF;

  open assignment;
  loop
    fetch assignment into l_dummy_date;
    exit when assignment%notfound;
  end loop;
  close assignment;
  begin
    update per_assignments_f
    set effective_end_date = X_termination_date
    where period_of_service_id = X_period_of_service_id
    and   effective_end_date = to_date('31-12-4712','DD-MM-YYYY');
  end;
  --
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 40);
  END IF;

  open ex_status;
  fetch ex_status into l_person_type_id,l_current_emp_or_apl_flag
                       ,l_current_applicant_flag,l_current_employee_flag;

  close ex_status;
  open person;
  fetch person into per_rec;
  close person;
  --
     PER_PEOPLE_V14_PKG.Insert_Row(
      X_Rowid                => l_rowid,
      X_Person_Id            => Per_rec.Person_Id,
      X_Party_Id             => Per_rec.Party_Id,
      X_Effective_Start_Date => X_termination_date + 1,
      X_Effective_End_Date   => to_date('31-12-4712','DD-MM-YYYY'),
      X_Business_Group_Id    => Per_rec.Business_Group_Id,
      X_Person_Type_Id       => l_person_type_id,
      X_Last_Name            => Per_rec.Last_Name,
      X_Start_Date           => Per_rec.Start_Date,
      X_Applicant_Number     => Per_rec.Applicant_Number,
      X_Comment_Id           => Per_rec.Comment_Id,
      X_Current_Applicant_Flag=> l_current_applicant_flag,
      X_Current_Emp_Or_Apl_Flag=> l_current_emp_or_apl_flag,
      X_Current_Employee_Flag=> l_current_employee_flag,
      X_Date_Employee_Data_Verified=> Per_rec.Date_Employee_Data_Verified,
      X_Date_Of_Birth        => Per_rec.Date_Of_Birth,
      X_Email_Address        => Per_rec.Email_Address,
      X_Employee_Number      => Per_rec.Employee_Number,
      X_Expense_Check_To_Address=> Per_rec.expense_check_send_to_address,
      X_First_Name           => Per_rec.First_Name,
      X_Full_Name            => Per_rec.Full_Name,
      X_Known_As             => Per_rec.Known_As,
      X_Marital_Status       => Per_rec.Marital_Status,
      X_Middle_Names         => Per_rec.Middle_Names,
      X_Nationality          => Per_rec.Nationality,
      X_National_Identifier  => Per_rec.National_Identifier,
      X_Previous_Last_Name   => Per_rec.Previous_Last_Name,
      X_Registered_Disabled_Flag=> Per_rec.Registered_Disabled_Flag,
      X_Sex                  => Per_rec.Sex,
      X_Title                => Per_rec.Title,
      X_Vendor_Id            => Per_rec.Vendor_Id,
      --
      -- 115.22 : We need to ensure the per_phones table does not create rows.
      --          Phone changes are handled by the "update_phone" api
      --
      X_Work_Telephone       => null, -- 1020074 Per_rec.Work_Telephone,
      X_Attribute_Category   => Per_rec.Attribute_Category,
      X_Attribute1           => Per_rec.Attribute1,
      X_Attribute2           => Per_rec.Attribute2,
      X_Attribute3           => Per_rec.Attribute3,
      X_Attribute4           => Per_rec.Attribute4,
      X_Attribute5           => Per_rec.Attribute5,
      X_Attribute6           => Per_rec.Attribute6,
      X_Attribute7           => Per_rec.Attribute7,
      X_Attribute8           => Per_rec.Attribute8,
      X_Attribute9           => Per_rec.Attribute9,
      X_Attribute10          => Per_rec.Attribute10,
      X_Attribute11          => Per_rec.Attribute11,
      X_Attribute12          => Per_rec.Attribute12,
      X_Attribute13          => Per_rec.Attribute13,
      X_Attribute14          => Per_rec.Attribute14,
      X_Attribute15          => Per_rec.Attribute15,
      X_Attribute16          => Per_rec.Attribute16,
      X_Attribute17          => Per_rec.Attribute17,
      X_Attribute18          => Per_rec.Attribute18,
      X_Attribute19          => Per_rec.Attribute19,
      X_Attribute20          => Per_rec.Attribute20,
      X_Attribute21          => Per_rec.Attribute21,
      X_Attribute22          => Per_rec.Attribute22,
      X_Attribute23          => Per_rec.Attribute23,
      X_Attribute24          => Per_rec.Attribute24,
      X_Attribute25          => Per_rec.Attribute25,
      X_Attribute26          => Per_rec.Attribute26,
      X_Attribute27          => Per_rec.Attribute27,
      X_Attribute28          => Per_rec.Attribute28,
      X_Attribute29          => Per_rec.Attribute29,
      X_Attribute30          => Per_rec.Attribute30,
      X_Per_Information_Category   => Per_rec.Per_Information_Category,
      X_Per_Information1           => Per_rec.Per_Information1,
      X_Per_Information2           => Per_rec.Per_Information2,
      X_Per_Information3           => Per_rec.Per_Information3,
      X_Per_Information4           => Per_rec.Per_Information4,
      X_Per_Information5           => Per_rec.Per_Information5,
      X_Per_Information6           => Per_rec.Per_Information6,
      X_Per_Information7           => Per_rec.Per_Information7,
      X_Per_Information8           => Per_rec.Per_Information8,
      X_Per_Information9           => Per_rec.Per_Information9,
      X_Per_Information10          => Per_rec.Per_Information10,
      X_Per_Information11          => Per_rec.Per_Information11,
      X_Per_Information12          => Per_rec.Per_Information12,
      X_Per_Information13          => Per_rec.Per_Information13,
      X_Per_Information14          => Per_rec.Per_Information14,
      X_Per_Information15          => Per_rec.Per_Information15,
      X_Per_Information16          => Per_rec.Per_Information16,
      X_Per_Information17          => Per_rec.Per_Information17,
      X_Per_Information18          => Per_rec.Per_Information18,
      X_Per_Information19          => Per_rec.Per_Information19,
      X_Per_Information20          => Per_rec.Per_Information20,
      X_Per_Information21          => Per_rec.Per_Information21,
      X_Per_Information22          => Per_rec.Per_Information22,
      X_Per_Information23          => Per_rec.Per_Information23,
      X_Per_Information24          => Per_rec.Per_Information24,
      X_Per_Information25          => Per_rec.Per_Information25,
      X_Per_Information26          => Per_rec.Per_Information26,
      X_Per_Information27          => Per_rec.Per_Information27,
      X_Per_Information28          => Per_rec.Per_Information28,
      X_Per_Information29          => Per_rec.Per_Information29,
      X_Per_Information30          => Per_rec.Per_Information30,
      X_Last_Update_Date     => Per_rec.Last_Update_Date,
      X_Last_Updated_By      => Per_rec.Last_Updated_By,
      X_Last_Update_Login    => Per_rec.Last_Update_Login,
      X_Created_By           => Per_rec.Created_By,
      X_Creation_Date        => Per_rec.Creation_Date,
      X_Period_Of_Service_Id => l_period_of_service_id,
      X_town_of_birth        => Per_rec.town_of_birth,
      X_region_of_birth      => Per_rec.region_of_birth,
      X_country_of_birth     => Per_rec.country_of_birth,
      X_global_person_id     => Per_rec.global_person_id,
      X_Order_Name           => Per_rec.order_Name,     -- #3889584
      X_Global_Name          => Per_rec.global_name,
      X_Local_Name           => Per_rec.local_name);

  --
  -- add maintain_ptu for TERM
  --
--   hr_per_type_usage_internal.maintain_ptu(
--     p_validate => TRUE,
--     p_action => 'TERM',
--     p_person_id => Per_rec.person_id,
--     p_period_of_service_id => l_period_of_service_id,
--     p_actual_termination_date => X_termination_date,
--     p_business_group_id => Per_rec.Business_group_id,
--     p_date_start => Per_rec.start_date);
  --
--
-- #2221990
-- This procedure has already been called within PER_PEOPLE_V14_PKG
-- thus it is not necessary.
--
-- PTU : Start of Changes
--
-- hr_per_type_usage_internal.maintain_person_type_usage
--	(p_effective_date	=> X_termination_date
--	,p_person_id		=> Per_rec.person_id
--	,p_person_type_id	=>
--               hr_person_type_usage_info.get_default_person_type_id
--                        (p_business_group_id    =>  Per_rec.Business_group_id
--                        ,p_system_person_type   => 'EX_EMP')
--        );
--
-- PTU : End of Changes
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 50);
  END IF;

end;
--
procedure update_employee_rows(X_period_of_service_id NUMBER
                        ,X_person_id NUMBER
                        ,X_hire_date DATE
                        ,X_s_hire_date DATE) IS
  --
  cursor period is
    select date_start
    from   per_periods_of_service
    where  period_of_service_id = X_period_of_service_id
    for    update of date_start;
  --
  cursor assignment is
    select effective_start_date
    from   per_assignments_f
    where  period_of_service_id = X_period_of_service_id
    and    effective_start_date = X_s_hire_date
    and    person_id = X_person_id
    for    update of effective_start_date;
  --
  cursor address is
    select date_from
    from   per_addresses pa
    where  person_id = X_person_id
    and    date_from = X_s_hire_Date
    for    update of date_from;
  --
  l_dummy_date date;
  --
  -- START WWBUG 1390173 fix
  --
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
  --
  -- END WWBUG 1390173 fix
  --
  cursor c1 is
    select *
    from   per_periods_of_service
    where  period_of_service_id = x_period_of_service_id
    and    date_start = x_s_hire_date;
  --
  -- Fix for WWBUG 1408379
  --
  l_old_add            ben_add_ler.g_add_ler_rec;
  l_new_add            ben_add_ler.g_add_ler_rec;
  --
  -- End of Fix for WWBUG 1408379
  --
  l_c1 c1%rowtype;
  --
  cursor c2 is
    select *
    from   per_addresses
    where  person_id = X_person_id
    and    date_from = X_S_hire_date;
  --
  l_c2 c2%rowtype;
  l_row_found boolean := false;
  --
  l_proc            varchar2(20) :=   'update_employee_rows';
  --
BEGIN
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  open period;
  fetch period into l_dummy_date;
  close period;
  begin
--
-- START WWBUG 1390173 fix
--
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;

    open c1;
      fetch c1 into l_c1;
      if c1%found then
        --
        l_old.PERSON_ID := l_c1.person_id;
        l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
        l_old.DATE_START := l_c1.date_start;
        l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
        l_old.LEAVING_REASON := l_c1.leaving_reason;
        l_old.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
        l_old.ATTRIBUTE1 := l_c1.attribute1;
        l_old.ATTRIBUTE2 := l_c1.attribute2;
        l_old.ATTRIBUTE3 := l_c1.attribute3;
        l_old.ATTRIBUTE4 := l_c1.attribute4;
        l_old.ATTRIBUTE5 := l_c1.attribute5;
        l_new.PERSON_ID := l_c1.person_id;
        l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
        l_new.DATE_START := x_hire_date;
        l_new.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
        l_new.LEAVING_REASON := l_c1.leaving_reason;
        l_new.ADJUSTED_SVC_DATE := l_c1.adjusted_svc_date;
        l_new.ATTRIBUTE1 := l_c1.attribute1;
        l_new.ATTRIBUTE2 := l_c1.attribute2;
        l_new.ATTRIBUTE3 := l_c1.attribute3;
        l_new.ATTRIBUTE4 := l_c1.attribute4;
        l_new.ATTRIBUTE5 := l_c1.attribute5;
        l_new.final_process_date := l_c1.final_process_date;
        --
        ben_pps_ler.ler_chk(p_old            => l_old
                           ,p_new            => l_new
                           ,p_event          => 'UPDATING'
                           ,p_effective_date => x_hire_date);
        --
      end if;
    close c1;
--
-- END WWBUG 1390173 fix
--
    --
    update per_periods_of_service
    set    date_start = X_hire_date
    where  period_of_service_id = X_period_of_service_id
    and    date_start = X_s_hire_date;
    -- VT 01/29/97 #417906 added exception
    exception
      when no_data_found then null;
  end;
  --
   IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;

  open assignment;
  loop
    fetch assignment into l_dummy_date;
    exit when assignment%notfound;
  end loop;
  close assignment;
  begin
    update per_assignments_f
    set effective_start_date = X_hire_date
    where period_of_service_id = X_period_of_service_id
    and   effective_start_date = X_s_hire_date;
    -- VT 01/29/97 #417906 added exception
    exception
      when others then null;
    --if SQL%ROWCOUNT <1
    --then
    --  raise no_data_found;
    --end if;
  end;
  --
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 30);
  END IF;

  open address;
  loop
    fetch address into l_dummy_date;
    exit when address%notfound;
  end loop;
  close address;
  --
  open c2;
    --
    fetch c2 into l_c2;
    if c2%found then
      --
      l_row_found := true;
      --
    end if;
    --
  close c2;
  --
  begin
    --
    update per_addresses
    set date_from = X_hire_date
    where person_id = X_person_id
    and date_from = X_S_hire_date;
    -- VT 01/29/97 #417906 added exception
    exception
      when no_data_found then null;
  end;
  --
  if l_row_found then
    --
    -- Fix for WWBUG 1408379
    --
    l_old_add.person_id := l_c2.person_id;
    l_old_add.business_group_id := l_c2.business_group_id;
    l_old_add.date_from := l_c2.date_from;
    l_old_add.date_to := l_c2.date_to;
    l_old_add.primary_flag := l_c2.primary_flag;
    l_old_add.postal_code := l_c2.postal_code;
    l_old_add.region_2 := l_c2.region_2;
    l_old_add.address_type := l_c2.address_type;
    l_old_add.address_id := l_c2.address_id;
    l_new_add.person_id := l_c2.person_id;
    l_new_add.business_group_id := l_c2.business_group_id;
    l_new_add.date_from := x_hire_date;
    l_new_add.date_to := l_c2.date_to;
    l_new_add.primary_flag := l_c2.primary_flag;
    l_new_add.postal_code := l_c2.postal_code;
    l_new_add.region_2 := l_c2.region_2;
    l_new_add.address_type := l_c2.address_type;
    l_new_add.address_id := l_c2.address_id;
    --
    ben_add_ler.ler_chk(p_old            => l_old_add,
                        p_new            => l_new_add,
                        p_effective_date => l_new_add.date_from);
    --
    -- End of Fix for WWBUG 1408379
    --
  end if;
  --
  IF g_debug THEN
    hr_utility.set_location('leaving: '|| g_package || l_proc, 40);
  END IF;


END update_employee_rows;
--
--
-- ENHANCEMENT BUG: 2293945. Starts here.
--
-- PRCEDURE NAME  : modify_hire_date
--
-- PURPOSE        : To allow user to modify the Hire_Date of the employment.
--                  To correct the personal and assignment information
--                  according to the new Hire_Date.
--
-- PARAMETERS     : X_Person_Id      - Unique Id of the person.
--                  X_Hire_Date      - Modified Hire Date.
--                  X_S_Hire_Date    - Original Hire Date.
--                  X_Person_Type_Id - Unique key of Person Type Usage table
--                                           for this person.
--                  X_Period_Of_Service_Id - Unique key of Period of Service
--                                           table for this person.
--
Procedure modify_hire_date(X_Person_Id 	          NUMBER
		          ,X_Hire_Date            DATE
			  ,X_S_Hire_Date          DATE
			  ,X_System_Person_Type   VARCHAR2
			  ,X_Period_Of_Service_Id NUMBER )
IS
--
l_dummy_date      DATE;
l_dummy_num       NUMBER(20);
l_earlier_date    DATE;
l_assignment_type VARCHAR2(1);
l_later_date      DATE;
l_Work_Telephone  per_phones.phone_number%TYPE;
l_Phone_Id        per_phones.phone_id%TYPE;
l_Phone_OVN       per_phones.object_version_number%TYPE;
--
l_business_group_id per_all_people_f.business_group_id%TYPE;
--

l_proc            varchar2(16) :=  'modify_hire_date';
--
cursor ex_emp_rec
is select Effective_End_Date
   from   per_people_f
   where  person_id = X_Person_Id
   and nvl(Effective_End_Date,X_S_Hire_Date) = (X_S_Hire_Date - 1)
   and nvl(Current_Employee_Flag,'N') <> 'Y'
for update of Effective_End_Date;
--
cursor emp_rec
is select person_id
   from   per_people_f
   where  person_id = X_Person_Id
   and    effective_start_date = X_S_Hire_Date
for update of Person_Id;
--
cursor assignment is
  select effective_start_date
  from   per_assignments_f
  where  period_of_service_id = X_period_of_service_id
  and    effective_start_date = X_s_hire_date
  and    person_id = X_person_id
for update of effective_start_date;
--
cursor period is
  select date_start, business_group_id
  from   per_periods_of_service
  where  Period_of_service_Id = X_Period_of_service_Id
  and    date_start = X_S_Hire_Date
  and    actual_termination_date is null
for update of date_start;
--
cursor address is
  select address_id,date_from
  from   per_addresses pa
  where  person_id = X_person_id
  and    date_from = X_s_hire_Date
  and    primary_flag = 'Y'
  for    update of date_from;
--
cursor is_valid_addr(lc_addr_id NUMBER,lc_date_from date) is
  select date_from
  from   per_addresses pa
  where  person_id = X_Person_Id
  and    address_id <> lc_addr_id
  and    primary_flag = 'Y'
  and    lc_date_from between date_from and nvl(date_to,hr_api.g_eot);
--
cursor phones is
  select phone_id,phone_number,object_version_number
  from per_phones
  where parent_table = 'PER_ALL_PEOPLE_F'
  and   parent_id    = X_Person_Id
  and   date_from    = X_S_Hire_Date
  and   phone_type   = 'W1';
--
   cursor csr_latestATD(cp_date_start date) is
     select max(actual_termination_date)
       from per_periods_of_service
       where date_start < cp_date_start
          and person_id = X_person_id;
--
    cursor csr_person(cp_date DATE, cp_bg_id NUMBER) is
        select * from per_all_people_f
           where business_group_id = cp_bg_id
             and person_id = X_person_id
             and nvl(Effective_End_Date,cp_date) = cp_date;
   --
    l_atd        date;   -- 2975471
    l_date_start date;
    l_person_rec per_all_people_f%ROWTYPE;
   --
BEGIN
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

--
-- 2975471: Ensure new hire date is greater than last termination date
  open  period;
  fetch period into l_date_start, l_business_group_id;
  close period;

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;

  if l_date_start is not null then
     open csr_latestATD(l_date_start);
     fetch csr_latestATD into l_atd;
     close csr_latestATD;
     if (l_atd is not null)
        and (X_Hire_date <= l_atd)
     then
        hr_utility.set_message(800,'HR_6841_EMP_REF_DATE_CHG');
        hr_utility.raise_error;
     end if;
  end if;
--
-- this call is replaced by previous stmts
--  check_person_changes(p_person_id 	=> X_Person_Id
--		      ,p_hire_date 	=> X_Hire_Date
--                      ,p_s_hire_Date 	=> X_S_Hire_Date);
  -- end #2975471

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;

  open ex_emp_rec;
  fetch ex_emp_rec into l_dummy_date;
  if ex_emp_rec%found then
     --
     update per_people_f
     set Effective_End_Date = X_Hire_Date - 1
     where Effective_End_Date = l_dummy_date
     and   person_id = X_Person_Id
     and   nvl(Current_Employee_Flag,'N') <> 'Y';
     --
  end if;
  close ex_emp_rec;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 30);
  END IF;

  open emp_rec;
  fetch emp_rec into l_dummy_num;
  if emp_rec%found then
     --
  -- Added updation of start date for bug fix 5525333
     update per_people_f
     set effective_start_date = X_Hire_Date,
         start_date = X_hire_Date
     where effective_start_date = X_S_Hire_Date
     and person_id = X_person_id;
     --
     if SQL%ROWCOUNT < 1 then
        raise no_data_found;
     end if;
     --
  end if;
  close emp_rec;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 40);
  END IF;

  if (X_s_hire_date > X_hire_date) then
     l_later_date      := X_s_hire_date;
     l_earlier_date    := X_hire_date;
  else
     l_later_date      := X_hire_date;
     l_earlier_date    := X_s_hire_date;
  end if;
  l_assignment_type := 'E';
  --
  hr_date_chk.check_for_ass_chg(p_person_id       => X_Person_id
                               ,p_earlier_date    => l_earlier_date
                               ,p_later_date      => l_later_date
                               ,p_assignment_type => l_assignment_type
                               ,p_s_start_date    => X_S_Hire_Date
                               ,p_start_date      => X_Hire_Date);
  --
  open assignment;
  loop
    fetch assignment into l_dummy_date;
    exit when assignment%notfound;
  end loop;
  close assignment;
  --
  update per_assignments_f
  set   effective_start_date = X_hire_date
  where period_of_service_id = X_period_of_service_id
  and   effective_start_date = X_s_hire_date;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 50);
  END IF;


  open  address;
  fetch address into l_dummy_num,l_dummy_date;
  if address%found then
    --
    open is_valid_addr(l_dummy_num,X_Hire_Date);
    fetch is_valid_addr into l_dummy_date;
    if (is_valid_addr%notfound) then
       --
       update per_addresses
       set   date_from  = X_Hire_Date
       where person_id  = X_Person_Id
       and   date_from  = X_S_Hire_Date
       and   address_id = l_dummy_num;
       --
       close is_valid_addr;
       --
    else
       --
       close address;
       close is_valid_addr;
       hr_utility.set_message(801,'HR_6510_PER_PRIMARY_ADDRESS');
       hr_utility.raise_error;
       --
    end if;
  end if;
  close address;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 60);
  END IF;

  if SQL%ROWCOUNT < 1 then
     raise no_data_found;
  end if;
  --
  hr_per_type_usage_internal.change_hire_date_ptu(p_date_start         => X_Hire_date
    						 ,p_old_date_start     => X_S_Hire_date
    						 ,p_person_id	       => X_Person_Id
    						 ,p_system_person_type => X_System_Person_Type);
  --
  -- #2975471
  --
  if l_atd is not null and ((l_atd + 1) = X_S_Hire_Date) then -- back-to-back hire?
        --hr_utility.set_message(801,'HR_51811_EMP_CONTIG_POS');
        --hr_utility.raise_error;

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 70);
  END IF;


        open csr_person(l_atd, l_business_group_id);
        fetch csr_person into l_person_rec;
        close csr_person;
     --
     -- update per_all_people_f
        create_EX_EMP( p_person_rec        => l_person_rec
                      ,p_pos_id            => X_Period_of_service_Id
                      ,p_person_id         => X_person_id
                      ,p_Business_group_id => l_business_group_id
                      ,p_start_date        => l_atd + 1
                      ,p_end_date          => X_Hire_Date - 1);

     -- update PTU table
       hr_per_type_usage_internal.maintain_person_type_usage
       (p_effective_date       => l_atd + 1
       ,p_person_id            => X_Person_id
       ,p_datetrack_update_mode => 'UPDATE_CHANGE_INSERT'
       ,p_person_type_id       => hr_person_type_usage_info.get_default_person_type_id
                                    (l_business_group_id
                                    ,'EX_EMP')
       );
     --
  end if;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 80);
  END IF;

  if l_date_start is not null then
     --
     update per_periods_of_service
     set   date_start = X_Hire_Date
     where Period_of_service_Id = X_Period_of_service_Id
     and   date_start = X_S_Hire_Date
     and   actual_termination_date is null;
     --
  end if;
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 90);
  END IF;

  open  phones;
  fetch phones into l_Phone_Id,l_Work_Telephone,l_Phone_OVN;
  if (phones%found) then
     hr_phone_api.update_phone
                    (p_phone_id              => l_Phone_Id,
                     p_phone_number          => l_work_telephone,
                     p_date_to               => null,
                     p_object_version_number => l_Phone_OVN,
                     p_date_from             => X_Hire_date,
                     p_effective_date        => X_Hire_Date);
  end if;
  close phones;
  --

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 100);
  END IF;


End modify_hire_date;
--
-- BUG: 2293945. Ends here.
--
procedure cancel_termination(X_period_of_service_id NUMBER
                            ,X_Person_id NUMBER
                            ,X_termination_date DATE
                            ,X_s_termination_date DATE )
IS
cursor person
--changes for bug 5857638 here
--is select person_id
is select *
--changes for bug 5857638 here
   from per_people_f
   where person_id = X_Person_Id
   for update of Person_Id;
--
cursor assignment
is
   select effective_end_date
   from   per_assignments_f
   where  person_id = X_person_id
   and    effective_end_date = X_s_termination_date
   for update of effective_end_date;
--
--START HR/WF Synchronization  --tpapired
  cursor l_pds_cur is
    select *
    from per_periods_of_service
    where person_id = x_person_id
    and   rownum = 1;
  l_pds_rec l_pds_cur%rowtype;

--END  HR/WF Synchronization  --tpapired
--
cursor period
is
select actual_termination_date
from   per_periods_of_service
where  period_of_service_id = X_period_of_service_id
for    update of actual_termination_date;
--
l_dummy_date 	    VARCHAR2(30);
l_business_group_id number(15);
--changes for bug 5857638 here
l_person_record             per_people_f%rowtype;
l_EFFECTIVE_START_DATE      per_people_f.EFFECTIVE_START_DATE%type;
l_CURRENT_EMP_OR_APL_FLAG   per_people_f.CURRENT_EMP_OR_APL_FLAG%type;
l_CURRENT_EMPLOYEE_FLAG     per_people_f.CURRENT_EMPLOYEE_FLAG%type;
l_PERSON_TYPE_ID            per_people_f.PERSON_TYPE_ID%type;
--
l_proc            varchar2(20) :=  'cancel_termination';
--

--changes for bug 5857638 here
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;


  --
  -- Lock assignments and update the end dates.
  --
  open assignment;
  loop
    fetch assignment into l_dummy_date;
    exit when assignment%NOTFOUND;
    update per_assignments_f
    set effective_end_date = hr_general.end_of_time
    where current of assignment;
    if SQL%ROWCOUNT <1 then
      raise NO_DATA_FOUND;
    end if;
  end loop;
  close assignment;
  --
  -- Lock and update the Period of Service row
  --
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;
  open period;
  loop
    fetch period into l_dummy_date;
    exit when period%NOTFOUND;
    update per_periods_of_service
    set actual_termination_date = null
    ,   last_standard_process_date = null
    ,   final_process_date = null
    where current of period;
  end loop;
  close period;
  --
  -- Lock Person rows
  --
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;
  open person;
  loop
----changes for bug 5857638 here
--    fetch person into l_dummy_date;
    fetch person into l_person_record;
        if l_person_record.effective_end_date=X_s_termination_date  then
            hr_utility.set_location('Entering : per_people_v7_pkg.cancel termination',25);
            l_EFFECTIVE_START_DATE      :=l_person_record.EFFECTIVE_START_DATE;
            l_CURRENT_EMP_OR_APL_FLAG   :=l_person_record.CURRENT_EMP_OR_APL_FLAG;
            l_CURRENT_EMPLOYEE_FLAG     :=l_person_record.CURRENT_EMPLOYEE_FLAG;
            l_PERSON_TYPE_ID            :=l_person_record.PERSON_TYPE_ID;
        end if;
--changes for bug 5857638 here
    exit when person%NOTFOUND;
  end loop;
  --
  -- Reverse Date-track change by deleting current row
  -- and updating Previous row.
  --
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 30);
  END IF;
  delete from per_people_f
--changes for bug 5857638 here
--  where  effective_start_date = X_s_termination_date + 1
    where  effective_end_date = X_s_termination_date
--changes for bug 5857638 here
  and    person_id = X_person_id;
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 40);
  END IF;
  --
  update per_people_f
--  set effective_end_date = hr_general.end_of_time
--changes for bug 5857638 here
  set  EFFECTIVE_START_DATE      =l_EFFECTIVE_START_DATE,
            CURRENT_EMP_OR_APL_FLAG   =l_CURRENT_EMP_OR_APL_FLAG,
            CURRENT_EMPLOYEE_FLAG     =l_CURRENT_EMPLOYEE_FLAG,
            PERSON_TYPE_ID            =l_PERSON_TYPE_ID
--  where  effective_end_date = X_s_termination_date
  where  effective_start_date = X_s_termination_date+1
--changes for bug 5857638 here
  and    person_id = X_person_id;
  --
  -- These changes are part of version 115.16. They are not necessary
  -- since approach changed. (version 115.22)
  --
  -- Start of Bug No. 1020074 Start.
  --
  -- While terminating an employee, it creates another row in per_all_people_f
  -- and per_phines, and while canceling the termination, it deletes the second
  -- row and updates the date_to of first row (reverse Date-track change) in
  -- per_all_people_f but not in per_phones table. Modified the code so that while
  -- canceling the termination, it removes the second row and updates the
  -- date_to (reverse Date-track change) of work_phone in per_phones table too.
  --
  -- delete from per_phones
  -- where     parent_id = X_person_id
  -- and       parent_table = 'PER_ALL_PEOPLE_F'
  -- and       phone_type = 'W1'
  -- and       date_from =X_s_termination_date + 1;
  --
  -- update per_phones
  -- set date_to = null
  -- where     parent_id = X_person_id
  -- and       parent_table = 'PER_ALL_PEOPLE_F'
  -- and       phone_type = 'W1'
  -- and       date_to =X_s_termination_date;
  --
  -- End of Bug No. 1020074.
  --
  -- End of changes 1020074 version 115.22
  --
  --
  -- add maintain_ptu for REV_TERM
  --
--  hr_per_type_usage_internal.maintain_ptu(
--    p_validate => TRUE,
--    p_action => 'REV_TERM',
--    p_person_id => X_person_id,
--    p_period_of_service_id => X_period_of_service_id,
--    p_actual_termination_date => X_s_termination_date);
  --

-- PTU : Start of Changes
-- #2287055: modified effective_date and system_person_type
-- parameters value.
--
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 50);
  END IF;
 hr_per_type_usage_internal.cancel_person_type_usage
        (p_effective_date     => X_s_termination_date+1
        ,p_person_id          => X_person_id
        ,p_system_person_type => 'EX_EMP'
        );

-- PTU : End of Changes
--START HR/WF Synchronization  --tpapired
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 60);
  END IF;

  open l_pds_cur;
  fetch l_pds_cur into l_pds_rec;
  close l_pds_cur;
    per_hrwf_synch.per_pds_wf(
                          p_rec     => l_pds_rec,
                          p_date   => null,
                          p_action => 'REVERSE TERMINATION');
--
--END HR/WF Synchronization  --tpapired
--
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 70);
  END IF;
end cancel_termination;
--
procedure rehire(X_Person_Id NUMBER
                ,X_Rowid VARCHAR2
                ,X_Business_group_id NUMBER
                ,X_Set_Of_Books_Id NUMBER
                ,X_Hire_Date DATE)
IS
cursor person
is select *
from per_people_f
where person_id = X_Person_Id
and   X_Hire_date between
 effective_start_Date and effective_end_date
for update of effective_end_date;
--
per_rec person%rowtype;
--
  cursor c_all_person is
    select *
    from   per_all_people_f
    where  person_id = x_person_id
    and    x_hire_date
           between effective_start_date
           and     effective_end_date;
per_all_rec c_all_person%rowtype;
--START HR/WF Synchronization  --tpapired
  cursor l_pds_cur is
    select *
    from per_periods_of_service
    where person_id = x_person_id
    and   rownum = 1;
  l_pds_rec l_pds_cur%rowtype;

--END  HR/WF Synchronization  --tpapired
--
cursor person_type is
select ppt.person_type_id
,      pst.current_employee_flag
,      pst.current_applicant_flag
,      pst.current_emp_or_apl_flag
,      to_date('31/12/4712','DD/MM/YYYY') effective_end_date
from per_person_types ppt
,    per_startup_person_types pst
where ppt.business_group_id  =X_Business_group_id  --Bug fix 3645987
and   ppt.system_person_type = pst.system_person_type
and   ppt.system_person_type = 'EMP'
and   ppt.default_flag = 'Y'
and   pst.default_flag = 'Y';
type_rec person_type%rowtype;
--
cursor ass_type is
select past.assignment_status_type_id
from per_assignment_status_types past
,      per_ass_status_type_amends pasa
,      per_business_groups pbg
where  pasa.assignment_status_type_id(+) = past.assignment_status_type_id
and    pasa.business_group_id(+) = X_Business_Group_id
and    pbg.business_group_id = X_Business_Group_id
and    nvl(past.business_group_id,X_Business_Group_id) = X_Business_Group_id
and    nvl(past.legislation_code, pbg.legislation_code) = pbg.legislation_code
and    nvl(pasa.active_flag,past.active_flag) = 'Y'
and    nvl(pasa.default_flag,past.default_flag) = 'Y'
and    nvl(pasa.per_system_status,past.per_system_status) = 'ACTIVE_ASSIGN';
ass_rec ass_type%rowtype;
--
l_rowid ROWID;
l_ass_id NUMBER;
l_ass_seq VARCHAR2(30);
l_primary_flag VARCHAR2(1);
--l_ass_number VARCHAR2(15);
l_ass_number VARCHAR2(30);
l_period_of_service_id NUMBER;
--
l_proc            varchar2(10) :=  'rehire';
--

--
begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  open person;
  fetch person into per_rec;

-- Start of Fix for Bug 2438403
--  update per_people_f
--  set effective_end_date = X_Hire_date - 1
--  where current of person;
-- End of Fix for Bug 2438403

  close person;
  --
  open person_type;
  fetch person_type into type_rec;
  close person_type;

--
-- Start of Fix for Bug 2438403
--
if (per_periods_of_service_pkg_v2.IsBackToBackContract
        (p_person_id =>  X_Person_Id,
         p_hire_date_of_current_pds => X_HIRE_DATE)) then

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;

UPDATE PER_ALL_PEOPLE_F
SET       effective_start_date=X_hire_date,
          effective_end_date= type_rec.effective_end_date,
          business_group_id= per_rec.Business_Group_Id,
          person_type_id= hr_person_type_usage_info.get_default_person_type_id(type_rec.Person_Type_Id),
          last_name= per_rec.Last_Name,
          start_date= per_rec.Start_Date,
          applicant_number= per_rec.Applicant_Number,
          comment_id= per_rec.Comment_Id,
          current_applicant_flag=  type_rec.Current_Applicant_Flag,
          current_emp_or_apl_flag= type_rec.Current_Emp_Or_Apl_Flag,
          current_employee_flag= type_rec.Current_Employee_Flag,
          date_employee_data_verified= per_rec.Date_Employee_Data_Verified,
          date_of_birth= per_rec.Date_Of_Birth,
          email_address= per_rec.Email_Address,
          employee_number= per_rec.Employee_Number,
          expense_check_send_to_address= per_rec.expense_check_send_to_address,
          first_name= per_rec.First_Name,
          full_name= per_rec.Full_Name,
          known_as= per_rec.Known_As,
          marital_status= per_rec.Marital_Status,
          middle_names= per_rec.Middle_Names,
          nationality= per_rec.Nationality,
          national_identifier= per_rec.National_Identifier,
          previous_last_name= per_rec.Previous_Last_Name,
          registered_disabled_flag= per_rec.Registered_Disabled_Flag,
          sex= per_rec.Sex,
          title= per_rec.Title,
          vendor_id= per_rec.Vendor_Id,
          attribute_category= per_rec.Attribute_Category,
          attribute1= per_rec.Attribute1,
          attribute2= per_rec.Attribute2,
          attribute3= per_rec.Attribute3,
          attribute4= per_rec.Attribute4,
          attribute5= per_rec.Attribute5,
          attribute6= per_rec.Attribute6,
          attribute7= per_rec.Attribute7,
          attribute8= per_rec.Attribute8,
          attribute9= per_rec.Attribute9,
          attribute10= per_rec.Attribute10,
          attribute11= per_rec.Attribute11,
          attribute12= per_rec.Attribute12,
          attribute13= per_rec.Attribute13,
          attribute14= per_rec.Attribute14,
          attribute15= per_rec.Attribute15,
          attribute16= per_rec.Attribute16,
          attribute17= per_rec.Attribute17,
          attribute18= per_rec.Attribute18,
          attribute19= per_rec.Attribute19,
          attribute20= per_rec.Attribute20,
          attribute21= per_rec.Attribute21,
          attribute22= per_rec.Attribute22,
          attribute23= per_rec.Attribute23,
          attribute24= per_rec.Attribute24,
          attribute25= per_rec.Attribute25,
          attribute26= per_rec.Attribute26,
          attribute27= per_rec.Attribute27,
          attribute28= per_rec.Attribute28,
          attribute29= per_rec.Attribute29,
          attribute30= per_rec.Attribute30,
          per_information_category= per_rec.per_information_category,
          per_information1= per_rec.per_information1,
          per_information2= per_rec.per_information2,
          per_information3= per_rec.per_information3,
          per_information4= per_rec.per_information4,
          per_information5= per_rec.per_information5,
          per_information6= per_rec.per_information6,
          per_information7= per_rec.per_information7,
          per_information8= per_rec.per_information8,
          per_information9= per_rec.per_information9,
          per_information10= per_rec.per_information10,
          per_information11= per_rec.per_information11,
          per_information12= per_rec.per_information12,
          per_information13= per_rec.per_information13,
          per_information14= per_rec.per_information14,
          per_information15= per_rec.per_information15,
          per_information16= per_rec.per_information16,
          per_information17= per_rec.per_information17,
          per_information18=  per_rec.per_information18,
          per_information19= per_rec.per_information19,
          per_information20= per_rec.per_information20,
          per_information21= per_rec.per_information21,
          per_information22= per_rec.per_information22,
          per_information23= per_rec.per_information23,
          per_information24= per_rec.per_information24,
          per_information25= per_rec.per_information25,
          per_information26= per_rec.per_information26,
          per_information27= per_rec.per_information27,
          per_information28= per_rec.per_information28,
          per_information29= per_rec.per_information29,
          per_information30= per_rec.per_information30,
          last_update_date= per_rec.Last_Update_Date,
          last_updated_by= per_rec.Last_Updated_By,
          last_update_login= per_rec.Last_Update_Login,
          created_by= per_rec.Created_By,
          creation_date= per_rec.Creation_Date,
          town_of_birth= per_rec.town_of_birth,
          region_of_birth= per_rec.region_of_birth,
          country_of_birth= per_rec.country_of_birth,
          global_person_id= per_rec.global_person_id,
          party_id= per_rec.party_id,
          blood_type= per_rec.blood_type,
          correspondence_language= per_rec.correspondence_language,
          honors=  per_rec.honors,
          pre_name_adjunct=   per_rec.pre_name_adjunct,
          rehire_authorizor=  per_rec.rehire_authorizor,
          rehire_recommendation=    per_rec.rehire_recommendation,
          resume_exists=   per_rec.resume_exists,
          resume_last_updated=  per_rec.resume_last_updated,
          second_passport_exists= per_rec.second_passport_exists,
          student_status= per_rec.student_status,
          suffix=  per_rec.suffix,
          date_of_death= per_rec.date_of_death,
          uses_tobacco_flag=   per_rec.uses_tobacco_flag,
          fast_path_employee= per_rec.fast_path_employee,
          fte_capacity = per_rec.fte_capacity,
          order_name   = per_rec.order_name,  -- #3889584
          global_name  = per_rec.global_name,
          local_name   = per_rec.local_name
	 where person_id = per_rec.person_id
	and X_HIRE_DATE between effective_start_date
	and effective_end_date;


  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;


  IF (type_rec.Current_Employee_Flag IS NOT NULL)
  THEN
    Per_People_V14_Pkg.insert_period_of_service(X_Person_id => X_Person_Id
                            ,X_Business_Group_Id => X_Business_Group_id
                            ,X_Date_Start => X_HIRE_DATE
                            ,X_Period_Of_Service_Id => l_period_of_service_id
                            );
  END IF;

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 30);
  END IF;


 hr_per_type_usage_internal.maintain_person_type_usage
        (p_effective_date       => X_HIRE_DATE
        ,p_person_id            => X_Person_Id
        ,p_person_type_id       => type_rec.Person_Type_Id
        ,p_datetrack_update_mode =>'CORRECTION'
        );


-- End of Fix for Bug 2438403
else

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 40);
  END IF;

  open person;
  fetch person into per_rec;
  update per_people_f
  set effective_end_date = X_Hire_date - 1
  where current of person;
  close person;

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 50);
  END IF;


  per_people_v14_pkg.insert_row(l_Rowid
                     ,per_rec.Person_Id
                     ,per_rec.Party_Id
                     ,X_Hire_date
                     ,type_rec.effective_end_date
                     ,per_rec.Business_Group_Id
                     ,type_rec.Person_Type_Id
                     ,per_rec.Last_Name
                     ,per_rec.Start_Date
                     ,per_rec.Applicant_Number
                     ,per_rec.Comment_Id
                     ,type_rec.Current_Applicant_Flag
                     ,type_rec.Current_Emp_Or_Apl_Flag
                     ,type_rec.Current_Employee_Flag
                     ,per_rec.Date_Employee_Data_Verified
                     ,per_rec.Date_Of_Birth
                     ,per_rec.Email_Address
                     ,per_rec.Employee_Number
                     ,per_rec.expense_check_send_to_address
                     ,per_rec.First_Name
                     ,per_rec.Full_Name
                     ,per_rec.Known_As
                     ,per_rec.Marital_Status
                     ,per_rec.Middle_Names
                     ,per_rec.Nationality
                     ,per_rec.National_Identifier
                     ,per_rec.Previous_Last_Name
                     ,per_rec.Registered_Disabled_Flag
                     ,per_rec.Sex
                     ,per_rec.Title
                     ,per_rec.Vendor_Id
                     --
                     -- 115.22: We need to ensure no rows get created in per_phones
                     --         table.
                     --
                     ,null -- #1020074 per_rec.Work_Telephone
                     ,per_rec.Attribute_Category
                     ,per_rec.Attribute1
                     ,per_rec.Attribute2
                     ,per_rec.Attribute3
                     ,per_rec.Attribute4
                     ,per_rec.Attribute5
                     ,per_rec.Attribute6
                     ,per_rec.Attribute7
                     ,per_rec.Attribute8
                     ,per_rec.Attribute9
                     ,per_rec.Attribute10
                     ,per_rec.Attribute11
                     ,per_rec.Attribute12
                     ,per_rec.Attribute13
                     ,per_rec.Attribute14
                     ,per_rec.Attribute15
                     ,per_rec.Attribute16
                     ,per_rec.Attribute17
                     ,per_rec.Attribute18
                     ,per_rec.Attribute19
                     ,per_rec.Attribute20
                     ,per_rec.Attribute21
                     ,per_rec.Attribute22
                     ,per_rec.Attribute23
                     ,per_rec.Attribute24
                     ,per_rec.Attribute25
                     ,per_rec.Attribute26
                     ,per_rec.Attribute27
                     ,per_rec.Attribute28
                     ,per_rec.Attribute29
                     ,per_rec.Attribute30
                     ,per_rec.Per_Information_Category
                     ,per_rec.Per_Information1
                     ,per_rec.Per_Information2
                     ,per_rec.Per_Information3
                     ,per_rec.Per_Information4
                     ,per_rec.Per_Information5
                     ,per_rec.Per_Information6
                     ,per_rec.Per_Information7
                     ,per_rec.Per_Information8
                     ,per_rec.Per_Information9
                     ,per_rec.Per_Information10
                     ,per_rec.Per_Information11
                     ,per_rec.Per_Information12
                     ,per_rec.Per_Information13
                     ,per_rec.Per_Information14
                     ,per_rec.Per_Information15
                     ,per_rec.Per_Information16
                     ,per_rec.Per_Information17
                     ,per_rec.Per_Information18
                     ,per_rec.Per_Information19
                     ,per_rec.Per_Information20
                     ,per_rec.Per_Information21
                     ,per_rec.Per_Information22
                     ,per_rec.Per_Information23
                     ,per_rec.Per_Information24
                     ,per_rec.Per_Information25
                     ,per_rec.Per_Information26
                     ,per_rec.Per_Information27
                     ,per_rec.Per_Information28
                     ,per_rec.Per_Information29
                     ,per_rec.Per_Information30
                     ,per_rec.Last_Update_Date
                     ,per_rec.Last_Updated_By
                     ,per_rec.Last_Update_Login
                     ,per_rec.Created_By
                     ,per_rec.Creation_Date
                     ,per_rec.order_name   -- #3889584
                     ,per_rec.global_name
                     ,per_rec.local_name
                     ,l_period_of_service_id
                     ,per_rec.town_of_birth
                     ,per_rec.region_of_birth
                     ,per_rec.country_of_birth
                     ,per_rec.global_person_id);
  --
end if; --backtoback
  --

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 60);
  END IF;

  PER_ASSIGNMENTS_V7_PKG.insert_row(X_Rowid =>l_rowid
                     ,X_Assignment_Id =>l_ass_id
                     ,X_Effective_Start_Date =>X_Hire_Date
                     ,X_Effective_End_Date =>
                                          type_rec.effective_end_date
                     ,X_Business_Group_Id => X_business_group_id
                     ,X_Recruiter_Id                        =>NULL
                     ,X_Grade_Id                            =>NULL
                     ,X_Position_Id                         =>NULL
                     ,X_Job_Id                              =>NULL
                     ,X_Assignment_Status_Type_Id =>
                                           ass_rec.Assignment_Status_Type_Id
                     ,X_Payroll_Id                          =>NULL
                     ,X_Location_Id                         =>NULL
                     ,X_Person_Referred_By_Id               =>NULL
                     ,X_Supervisor_Id                       =>NULL
                     ,X_Special_Ceiling_Step_Id             =>NULL
                     ,X_Person_Id => X_person_id
                     ,X_Employee_Number => per_rec.employee_number
                     ,X_Recruitment_Activity_Id             =>NULL
                     ,X_Source_Organization_Id              =>NULL
                     ,X_Organization_Id => X_business_group_id
                     ,X_People_Group_Id                     =>NULL
                     ,X_Soft_Coding_Keyflex_Id              =>NULL
                     ,X_Vacancy_Id                          =>NULL
                     ,X_Pay_Basis_Id                        =>NULL
                     ,X_Assignment_Sequence =>l_ass_seq
                     ,X_Assignment_Type => 'E'
                     ,X_Primary_Flag => l_primary_flag
                     ,X_Application_Id                      =>NULL
                     ,X_Assignment_Number => l_ass_number
                     ,X_Change_Reason                       =>NULL
                     ,X_Comment_Id                          =>NULL
                     ,X_Date_Probation_End                  =>NULL
                     ,X_Default_Code_Comb_Id                =>NULL
                     ,X_Employment_Category                 =>NULL
                     ,X_Frequency                           =>NULL
                     ,X_Internal_Address_Line               =>NULL
                     ,X_Manager_Flag                        =>NULL
                     ,X_Normal_Hours                        =>NULL
                     ,X_Perf_Review_Period                  =>NULL
                     ,X_Perf_Review_Period_Frequency        =>NULL
                     ,X_Period_Of_Service_Id                =>l_period_of_service_id
                     ,X_Probation_Period                    =>NULL
                     ,X_Probation_Unit                      =>NULL
                     ,X_Sal_Review_Period                   =>NULL
                     ,X_Sal_Review_Period_Frequency         =>NULL
                     ,X_set_of_books_id =>X_Set_Of_Books_Id
                     ,X_Source_Type                         =>NULL
                     ,X_Time_Normal_Finish                  =>NULL
                     ,X_Time_Normal_Start                   =>NULL
                     ,X_Ass_Attribute_Category              =>NULL
                     ,X_Ass_Attribute1                      =>NULL
                     ,X_Ass_Attribute2                      =>NULL
                     ,X_Ass_Attribute3                      =>NULL
                     ,X_Ass_Attribute4                      =>NULL
                     ,X_Ass_Attribute5                      =>NULL
                     ,X_Ass_Attribute6                      =>NULL
                     ,X_Ass_Attribute7                      =>NULL
                     ,X_Ass_Attribute8                      =>NULL
                     ,X_Ass_Attribute9                      =>NULL
                     ,X_Ass_Attribute10                     =>NULL
                     ,X_Ass_Attribute11                     =>NULL
                     ,X_Ass_Attribute12                     =>NULL
                     ,X_Ass_Attribute13                     =>NULL
                     ,X_Ass_Attribute14                     =>NULL
                     ,X_Ass_Attribute15                     =>NULL
                     ,X_Ass_Attribute16                     =>NULL
                     ,X_Ass_Attribute17                     =>NULL
                     ,X_Ass_Attribute18                     =>NULL
                     ,X_Ass_Attribute19                     =>NULL
                     ,X_Ass_Attribute20                     =>NULL
                     ,X_Ass_Attribute21                     =>NULL
                     ,X_Ass_Attribute22                     =>NULL
                     ,X_Ass_Attribute23                     =>NULL
                     ,X_Ass_Attribute24                     =>NULL
                     ,X_Ass_Attribute25                     =>NULL
                     ,X_Ass_Attribute26                     =>NULL
                     ,X_Ass_Attribute27                     =>NULL
                     ,X_Ass_Attribute28                     =>NULL
                     ,X_Ass_Attribute29                     =>NULL
                     ,X_Ass_Attribute30                     =>NULL
                     ,X_Last_Update_Date                    =>NULL
                     ,X_Last_Updated_By                     =>NULL
                     ,X_Last_Update_Login                   =>NULL
                     ,X_Created_By                          =>NULL
                     ,X_Creation_Date                       =>NULL
                     ,X_Title                               =>NULL
                                   );
--START HR/WF Synchronization  --tpapired

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 70);
  END IF;

  open l_pds_cur;
  fetch l_pds_cur into l_pds_rec;
  close l_pds_cur;
    per_hrwf_synch.per_pds_wf(
                          p_rec     => l_pds_rec,
                          p_date   => null,
                          p_action => 'REVERSE TERMINATION');
--
--END HR/WF Synchronization  --tpapired
--
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 80);
  END IF;


end;
procedure check_future_person_types(p_system_person_type  VARCHAR2
                                   ,p_person_id IN INTEGER
                                   ,p_business_group_id IN INTEGER
                                   ,p_effective_start_date IN DATE)
IS
cursor future_exists
IS
select 'Y'
from   per_people_f ppf
        ,per_person_types ppt
        ,per_startup_person_types pst
        where  ppf.person_type_id = ppt.person_type_id
        and  ppf.person_id = p_person_id
        and  ppf.business_group_id +0 = ppt.business_group_id+0
        and  ppf.business_group_id +0 = p_business_group_id
        and  p_effective_start_date < ppf.effective_start_date
        and  ppt.system_person_type <> pst.system_person_type
        and  pst.system_person_type = p_system_person_type;
--
l_future_exists VARCHAR2(1);
--
l_proc            varchar2(25) :=  'check_future_person_types';
--

begin
  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;

  open future_exists;
  fetch future_exists into l_future_exists;
  if future_exists%FOUND then
    close future_exists;
    fnd_message.set_name('PER','HR_7193_PER_FUT_TYPE_EXISTS');
    app_exception.raise_exception;
  else
    close future_exists;
  end if;
  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 10);
  END IF;

end;
--
procedure check_person_changes(p_person_id 		NUMBER
                              ,p_hire_date 		DATE
                              ,p_s_hire_Date 		DATE
			      ,p_current_application_id NUMBER )
IS
cursor get_future_changes
is
select 'Y'
from   per_people_f p
where  p.effective_start_date > p_hire_date
and    p.person_id = p_person_id;
--
cursor check_person
is
select 'Y'
from   per_people_f p
where p.effective_start_date > p_hire_date - 1
and  p.effective_start_date <> p_s_hire_date
and  p.person_id = p_person_id;
--
l_dummy VARCHAR2(1);
cursor check_assignment_changes
is
select assignment_id
from   per_assignments_f paf
,      per_periods_of_service pos
where  paf.person_id = pos.person_id
and    paf.period_of_service_id = pos.period_of_service_id
and    pos.date_start = p_s_hire_date
and    pos.person_id = p_person_id;
--
l_assignment_id NUMBER;
--
l_proc            varchar2(20) :=  'check_person_changes';
--

Begin

  g_debug := hr_utility.debug_enabled; -- get debug status
  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 5);
  END IF;


  if p_current_application_id = 810
  then
	 open get_future_changes;
	 fetch get_future_changes into l_dummy;
	 if get_future_changes%FOUND then
      close get_future_changes;
      fnd_message.set_name('PER','HR_7510_PER_FUT_CHANGE');
      app_exception.raise_exception;
	 end if;
	 close get_future_changes;
  else

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 10);
  END IF;

    open check_person;
    fetch check_person into l_dummy;
    if check_person%FOUND then
      close check_person;
      fnd_message.set_name('PER','HR_6841_EMP_REF_DATE_CHG');
      app_exception.raise_exception;
    else
      close check_person;
    end if;
  end if;
  if p_hire_date > p_s_hire_date
  then

  IF g_debug THEN
    hr_utility.set_location('Entering: '|| g_package || l_proc, 20);
  END IF;

  open check_assignment_changes;
  loop
	 fetch check_assignment_changes into l_assignment_id;
	 exit when check_assignment_changes%NOTFOUND;
	 per_assignments_V7_pkg.get_future_changes(l_assignment_id,p_hire_date,NULL);
	 per_assignments_V7_pkg.get_previous_changes(l_assignment_id,p_hire_date,NULL);
  end loop;
  close check_assignment_changes;
  end if;

  IF g_debug THEN
    hr_utility.set_location('Leaving: '|| g_package || l_proc, 30);
  END IF;


end check_person_changes;
END PER_PEOPLE_V7_PKG;

/
