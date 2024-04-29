--------------------------------------------------------
--  DDL for Package Body PER_PEOPLE_V15_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEOPLE_V15_PKG" as
/* $Header: peper15t.pkb 120.0 2005/05/31 13:42:21 appldev noship $ */
--
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Person_Id                           NUMBER,
                     X_Effective_Start_Date         IN OUT NOCOPY DATE,
                     X_Effective_End_Date           IN OUT NOCOPY DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Type_Id                      NUMBER,
                     X_Last_Name                           VARCHAR2,
                     X_Start_Date                          DATE,
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
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Current_Application_Id              NUMBER DEFAULT NULL
) IS
--
-- 3889584: We need to derive the person names when updating the person record
-- This cursor allows the retrieval of all other name components that
-- are needed when calling the derive person names function
--
   cursor csr_get_person_details is
     select *
       from per_all_people_f
      where rowid = X_rowid;
   --
   l_person_rec   csr_get_person_details%rowtype;
   l_full_name    per_all_people_f.full_name%type;
   l_order_name   per_all_people_f.order_name%type;
   l_global_name  per_all_people_f.global_name%type;
   l_local_name   per_all_people_f.local_name%type;
   l_dup_name     varchar(10);
--
BEGIN
  l_dup_name := 'N';
  if X_Current_Application_Id = 810
  then
    per_people_v15_pkg.check_person_changes(X_person_id
                     ,X_hire_date
                     ,X_s_hire_Date
                     ,X_current_application_id );
  end if;
  if X_termination_date is not null
  and X_S_termination_date is null
  and X_current_employee_flag = 'Y'
  then
    per_people_v15_pkg.check_person_changes(X_person_id
                     ,X_termination_date
                     ,X_Hire_date
                     ,X_current_application_id );
   X_effective_end_date := X_termination_date;
  elsif x_hire_date <> X_s_hire_date then
   X_effective_start_date := X_hire_date;
  end if;
  --
  -- >> 3889584: Derive person names before updating record
  open csr_get_person_details;
  fetch csr_get_person_details into l_person_rec;
  close csr_get_person_details;
  --
  hr_person_name.derive_person_names
      (p_format_name        =>  NULL, -- generate all names
       p_business_group_id  =>  x_business_group_id,
       p_person_id          =>  l_person_rec.person_id,
       p_first_name         =>  x_first_name,
       p_middle_names       =>  x_middle_names,
       p_last_name          =>  x_last_name,
       p_known_as           =>  x_known_as,
       p_title              =>  x_title,
       p_suffix             =>  l_person_rec.suffix,
       p_pre_name_adjunct   =>  l_person_rec.pre_name_adjunct,
       p_date_of_birth      =>  x_date_of_birth,
       p_previous_last_name =>  x_previous_last_name,
       p_email_address      =>  x_email_address  ,
       p_employee_number    =>  X_Employee_Number,
       p_applicant_number   =>  x_applicant_number,
       p_npw_number         =>  l_person_rec.npw_number,
       p_per_information1   =>  l_person_rec.per_information1  ,
       p_per_information2   =>  l_person_rec.per_information2  ,
       p_per_information3   =>  l_person_rec.per_information3  ,
       p_per_information4   =>  l_person_rec.per_information4  ,
       p_per_information5   =>  l_person_rec.per_information5  ,
       p_per_information6   =>  l_person_rec.per_information6  ,
       p_per_information7   =>  l_person_rec.per_information7  ,
       p_per_information8   =>  l_person_rec.per_information8  ,
       p_per_information9   =>  l_person_rec.per_information9  ,
       p_per_information10  =>  l_person_rec.per_information10  ,
       p_per_information11  =>  l_person_rec.per_information11  ,
       p_per_information12  =>  l_person_rec.per_information12  ,
       p_per_information13  =>  l_person_rec.per_information13  ,
       p_per_information14  =>  l_person_rec.per_information14  ,
       p_per_information15  =>  l_person_rec.per_information15  ,
       p_per_information16  =>  l_person_rec.per_information16  ,
       p_per_information17  =>  l_person_rec.per_information17  ,
       p_per_information18  =>  l_person_rec.per_information18  ,
       p_per_information19  =>  l_person_rec.per_information19  ,
       p_per_information20  =>  l_person_rec.per_information20  ,
       p_per_information21  =>  l_person_rec.per_information21  ,
       p_per_information22  =>  l_person_rec.per_information22  ,
       p_per_information23  =>  l_person_rec.per_information23  ,
       p_per_information24  =>  l_person_rec.per_information24  ,
       p_per_information25  =>  l_person_rec.per_information25  ,
       p_per_information26  =>  l_person_rec.per_information26  ,
       p_per_information27  =>  l_person_rec.per_information27  ,
       p_per_information28  =>  l_person_rec.per_information28  ,
       p_per_information29  =>  l_person_rec.per_information29  ,
       p_per_information30  =>  l_person_rec.per_information30  ,
       p_attribute1         =>  x_attribute1  ,
       p_attribute2         =>  x_attribute2  ,
       p_attribute3         =>  x_attribute3  ,
       p_attribute4         =>  x_attribute4  ,
       p_attribute5         =>  x_attribute5  ,
       p_attribute6         =>  x_attribute6  ,
       p_attribute7         =>  x_attribute7  ,
       p_attribute8         =>  x_attribute8  ,
       p_attribute9         =>  x_attribute9  ,
       p_attribute10        =>  x_attribute10  ,
       p_attribute11        =>  x_attribute11  ,
       p_attribute12        =>  x_attribute12  ,
       p_attribute13        =>  x_attribute13  ,
       p_attribute14        =>  x_attribute14  ,
       p_attribute15        =>  x_attribute15  ,
       p_attribute16        =>  x_attribute16  ,
       p_attribute17        =>  x_attribute17  ,
       p_attribute18        =>  x_attribute18  ,
       p_attribute19        =>  x_attribute19  ,
       p_attribute20        =>  x_attribute20  ,
       p_attribute21        =>  x_attribute21  ,
       p_attribute22        =>  x_attribute22  ,
       p_attribute23        =>  x_attribute23,
       p_attribute24        =>  x_attribute24,
       p_attribute25        =>  x_attribute25,
       p_attribute26        =>  x_attribute26,
       p_attribute27        =>  x_attribute27,
       p_attribute28        =>  x_attribute28,
       p_attribute29        =>  x_attribute29,
       p_attribute30        =>  x_attribute30,
       p_full_name          => l_full_name,
       p_order_name         => l_order_name,
       p_global_name        => l_global_name,
       p_local_name         => l_local_name,
       p_duplicate_flag     => l_dup_name
       );
  -- << 3889584
  UPDATE PER_PEOPLE_F
  SET
    person_id                             =    X_Person_Id,
    effective_start_date                  =    X_Effective_Start_Date,
    effective_end_date                    =    X_Effective_End_Date,
    business_group_id                     =    X_Business_Group_Id,
    person_type_id                        =    X_Person_Type_Id,
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
    full_name                             =    l_full_name,  -- 3889584: X_Full_Name,
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
--    work_telephone                        =    X_Work_Telephone,
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
    order_name                            =    l_order_name,  -- 3889584
    global_name                           =    l_global_name,
    local_name                            =    l_local_name,
    last_update_date                      =    X_Last_Update_Date,
    last_updated_by                       =    X_Last_Updated_By,
    last_update_login                     =    X_Last_Update_Login
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
if X_termination_date is not null
  and X_S_termination_date is null
  and X_current_employee_flag = 'Y'
  then
   terminate_employment(X_period_of_service_id
                       ,X_person_id
                       ,X_Rowid
                       ,X_Business_group_id
                       ,X_termination_date);
  elsif X_hire_date <> X_s_hire_date
  then
    update_employee_rows(X_period_of_service_id
                        ,X_person_id
                        ,X_hire_date
                        ,X_s_hire_date);
  end if;
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
where ppt.business_group_id = X_business_group_id -- Perf Fix 3648655
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
per_rec person%ROWTYPE;
l_person_type_id number;
l_current_emp_or_apl_flag VARCHAR2(1);
l_current_applicant_flag VARCHAR2(1);
l_current_employee_flag VARCHAR2(1);
l_dummy_date DATE;
l_rowid VARCHAR2(18);
l_period_of_service_id NUMBER;
--
begin
  open period;
  fetch period into l_dummy_date;
  close period;
  begin
    update per_periods_of_service
    set    actual_termination_date = X_termination_date
    ,      final_process_date = X_termination_date
    ,      last_standard_process_date = X_termination_date
    where  period_of_service_id = X_period_of_service_id;
  end;
  --
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
      X_Party_Id            => Per_rec.Party_Id,
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
      X_Work_Telephone       => Per_rec.Work_Telephone,
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
      X_Per_Information_Category => Per_rec.Per_information_category,
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
      X_Suffix               => Per_rec.suffix,
      X_Pre_Name_Adjunct     => Per_rec.pre_name_adjunct,
      X_Order_Name           => Per_rec.order_name,  -- #3889584
      X_Global_Name          => Per_rec.global_name,
      X_Local_Name           => Per_rec.local_name);

  --
end;
--
procedure update_employee_rows(X_period_of_service_id NUMBER
                        ,X_person_id NUMBER
                        ,X_hire_date DATE
                        ,X_s_hire_date DATE) IS
--
cursor period
is
select date_start
from per_periods_of_service
where period_of_service_id = X_period_of_service_id
for update of date_start;
--
cursor assignment is
select effective_start_date
from   per_assignments_f
where  period_of_service_id = X_period_of_service_id
and   effective_start_date = X_s_hire_date
and   person_id = X_person_id
for   Update of effective_start_date;
--
cursor address is
select date_from
from   per_addresses pa
where  person_id = X_person_id
and    date_from = X_s_hire_Date
for update of date_from;
--
l_dummy_date date;
BEGIN
  open period;
  fetch period into l_dummy_date;
  close period;
  begin
    update per_periods_of_service
    set    date_start = X_hire_date
    where  period_of_service_id = X_period_of_service_id
    and    date_start = X_s_hire_date;
    -- VT 01/29/97 #417906 added exception
    exception
      when no_data_found then null;
  end;
  --
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
      when no_data_found then null;
    --if SQL%ROWCOUNT <1
    --then
    --  raise no_data_found;
    --end if;
  end;
  --
  open address;
  loop
    fetch address into l_dummy_date;
    exit when address%notfound;
  end loop;
  close address;
  --
  begin
    update per_addresses
    set date_from = X_hire_date
    where person_id = X_person_id
    and date_from = X_S_hire_date;
    -- VT 01/29/97 #417906 added exception
    exception
      when no_data_found then null;
  end;
END update_employee_rows;
--
procedure cancel_termination(X_period_of_service_id NUMBER
                            ,X_Person_id NUMBER
                            ,X_termination_date DATE
                            ,X_s_termination_date DATE )
IS
cursor person
is select person_id
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
cursor period
is
select actual_termination_date
from   per_periods_of_service
where  period_of_service_id = X_period_of_service_id
for    update of actual_termination_date;
--
l_dummy_date VARCHAR2(30);
begin
  --
  -- Lock assignments and update the end dates.
  --
  open assignment;
  loop
    fetch assignment into l_dummy_date;
    exit when assignment%NOTFOUND;
    update per_assignments_f
    set effective_end_date = to_date('31-12-4712','DD-MM-YYYY')
    where current of assignment;
    if SQL%ROWCOUNT <1 then
      raise NO_DATA_FOUND;
    end if;
  end loop;
  close assignment;
  --
  -- Lock and update the Period of Service row
  --
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
  open person;
  loop
    fetch person into l_dummy_date;
    exit when person%NOTFOUND;
  end loop;
  --
  -- Reverse Date-track change by deleting current row
  -- and updating Previous row.
  --
  delete from per_people_f
  where  effective_start_date = X_s_termination_date + 1
  and    person_id = X_person_id;
  --
  update per_people_f
  set effective_end_date = to_date ('31-12-4712','DD-MM-YYYY')
  where  effective_end_date = X_s_termination_date
  and    person_id = X_person_id;
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
cursor person_type is
select ppt.person_type_id
,      pst.current_employee_flag
,      pst.current_applicant_flag
,      pst.current_emp_or_apl_flag
,      to_date('31/12/4712','DD/MM/YYYY') effective_end_date
from per_person_types ppt
,    per_startup_person_types pst
where ppt.business_group_id =X_Business_group_id -- Perf Fix 3648655
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
l_ass_number VARCHAR2(15);
l_period_of_service_id NUMBER;
--
begin
  open person;
  fetch person into per_rec;
  update per_people_f
  set effective_end_date = X_Hire_date - 1
  where current of person;
  close person;
  --
  open person_type;
  fetch person_type into type_rec;
  close person_type;
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
                     ,per_rec.Work_Telephone
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
                     ,per_rec.order_name    -- #3889584
                     ,per_rec.global_name
                     ,per_rec.local_name
                     ,l_period_of_service_id);
  --
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
begin
  open future_exists;
  fetch future_exists into l_future_exists;
  if future_exists%FOUND then
    close future_exists;
    fnd_message.set_name('PER','HR_7193_PER_FUT_TYPE_EXISTS');
    app_exception.raise_exception;
  else
    close future_exists;
  end if;
end;
--
procedure check_person_changes(p_person_id NUMBER
                              ,p_hire_date DATE
                              ,p_s_hire_Date DATE
                              ,p_current_application_id NUMBER DEFAULT NULL)
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
Begin
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
  open check_assignment_changes;
  loop
    fetch check_assignment_changes into l_assignment_id;
    exit when check_assignment_changes%NOTFOUND;
    per_assignments_V7_pkg.get_future_changes(l_assignment_id,p_hire_date,NULL);
    per_assignments_V7_pkg.get_previous_changes(l_assignment_id,p_hire_date,NULL);
  end loop;
  close check_assignment_changes;
  end if;
end check_person_changes;
END PER_PEOPLE_V15_PKG;

/
