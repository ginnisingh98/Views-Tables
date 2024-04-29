--------------------------------------------------------
--  DDL for Package Body HR_APPLICANT_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPLICANT_INTERNAL" as
/* $Header: peaplbsi.pkb 120.2.12010000.3 2009/04/01 15:28:30 sidsaxen ship $ */
  --
  -- Package Variables
  --
  g_package            constant varchar2(33) := 'hr_applicant_internal.';
  g_debug                       boolean      := hr_utility.debug_enabled;
  --
  g_APL_person_type    constant varchar2(10) := 'APL';
  g_EX_APL_person_type constant varchar2(10) := 'EX_APL';
  --

  CURSOR csr_person_record (cp_person_id number) IS
    select *
      from per_all_people_f
     where person_id = cp_person_id
       and rownum = 1;

-- ------------------------------------------------------------------------ +
-- -------------------< generate_applicant_number >------------------------ |
-- ------------------------------------------------------------------------ +
procedure generate_applicant_number
  (p_business_group_id  IN  NUMBER
  ,p_person_id          IN  NUMBER
  ,p_effective_date     IN  DATE
  ,p_party_id           IN  NUMBER
  ,p_date_of_birth      IN  DATE
  ,p_start_date         IN  DATE
  ,p_applicant_number   IN OUT NOCOPY VARCHAR2) IS
   --
   cursor csr_get_apl_number(cp_person_id         number
                            ,cp_business_group_id number
                            ,cp_effective_date    date ) is
      select applicant_number
        from per_all_people_f
       where person_id = cp_person_id
         and business_group_id = cp_business_group_id
         and applicant_number is not null
         and (cp_effective_date between effective_start_date and effective_end_date
              or effective_start_date > cp_effective_date)
        order by effective_start_date ASC;
   --
   l_dummy                 varchar2(100);
   l_applicant_number      per_all_people_f.applicant_number%TYPE;
   l_method_of_generation  VARCHAR2(30);
   --
BEGIN
  --
  l_applicant_number := p_applicant_number;
  --
  SELECT pbg.method_of_generation_apl_num
  INTO   l_method_of_generation
  FROM   per_business_groups_perf pbg
  WHERE  pbg.business_group_id = p_business_group_id;
  --

  if l_method_of_generation = 'M' and l_applicant_number IS NULL then
     open csr_get_apl_number(p_person_id, p_business_group_id, p_effective_date);
     fetch csr_get_apl_number into l_applicant_number;
     close csr_get_apl_number;
  end if;

  hr_person.generate_number
       (p_current_employee    => 'N'
       ,p_current_applicant   => 'Y'
       ,p_current_npw         => 'N'
       ,p_national_identifier => NULL
       ,p_business_group_id   => p_business_group_id
       ,p_person_id           => p_person_id
       ,p_employee_number     => l_dummy
       ,p_applicant_number    => l_applicant_number
       ,p_npw_number          => l_dummy
       ,p_effective_date      => p_effective_date
       ,p_party_id            => p_party_id
       ,p_date_of_birth       => p_date_of_birth
       ,p_start_date          => p_start_date);

  hr_person.validate_unique_number
       (p_person_id         => p_person_id
       ,p_business_group_id => p_business_group_id
       ,p_employee_number   => null
       ,p_applicant_number  => l_applicant_number
       ,p_npw_number        => null
       ,p_current_employee  => 'N'
       ,p_current_applicant => 'Y'
       ,p_current_npw       => 'N');
  --
  p_applicant_number := l_applicant_number;
  --
END generate_applicant_number;
--
-- ------------------------------------------------------------------------ +
-- ---------------< get_new_APL_person_type >------------------------------ |
-- ------------------------------------------------------------------------ +
procedure get_new_APL_person_type(p_business_group_id   IN number
                                ,p_current_person_type  IN varchar2
                                ,p_new_sys_person_type OUT nocopy varchar2
                                ,p_new_person_type_id  OUT nocopy number)
is
  --  ------------------------------------------------------
  --  Current person type   New person type
  --  -------------------   -------------------------------
  --  EX_APL                APL
  --  EX_EMP                EX_EMP_APL
  --  EMP                   EMP_APL
  --  EX_CWK                APL
  --  CWK                   APL
  --  OTHER                 APL
  --  ------------------------------------------------------

  l_new_sys_person_type  per_person_types.system_person_type%TYPE;

begin

  if p_current_person_type in ('EMP','EMP_APL') then
     l_new_sys_person_type := 'EMP_APL';
  elsif p_current_person_type in ('EX_EMP', 'EX_EMP_APL') then
     l_new_sys_person_type := 'EX_EMP_APL';
  else
     l_new_sys_person_type := 'APL';

  end if;

  p_new_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
        (p_business_group_id, l_new_sys_person_type);

  p_new_sys_person_type := l_new_sys_person_type;

end get_new_APL_person_type;
--
-- ------------------------------------------------------------------------ +
-- ----------------< get_new_EX_APL_person_type >-------------------------- |
-- ------------------------------------------------------------------------ +
procedure get_new_EX_APL_person_type(p_business_group_id    IN number
                                    ,p_current_person_type  IN varchar2
                                    ,p_new_sys_person_type OUT nocopy varchar2
                                    ,p_new_person_type_id  OUT nocopy number)
is
  --  ------------------------------------------------------
  --  Current person type   New person type
  --  -------------------   -------------------------------
  --  APL                   APL_EX_APL
  --  EX_EMP                EX_APL
  --  EMP                   EX_APL
  --  EX_CWK                EX_APL
  --  CWK                   EX_APL
  --  OTHER                 EX_APL
  --  ------------------------------------------------------

  l_new_sys_person_type  per_person_types.system_person_type%TYPE;

begin
  --
  if p_current_person_type = 'EX_EMP_APL' then
     l_new_sys_person_type := 'EX_EMP';
  elsif p_current_person_type = 'EMP_APL' then
     l_new_sys_person_type := 'EMP';
  else
     l_new_sys_person_type := 'EX_APL';

  end if;

  p_new_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
        (p_business_group_id, l_new_sys_person_type);

  p_new_sys_person_type := l_new_sys_person_type;

end get_new_EX_APL_person_type;
--
-- ----------------------------------------------------------------------- +
-- -----------------------< Update_Person_Rec >--------------------------- |
-- ----------------------------------------------------------------------- +
PROCEDURE Update_Person_Rec
   (p_person_id             number
   ,p_effective_start_date  date
   ,p_effective_end_date    date
   ,p_person_type_id        number
   ,p_applicant_number      varchar2
   ,p_current_emp_apl_flag  varchar2
   ,p_current_apl_flag      varchar2
   ,p_object_version_number in out nocopy number -- BUG4081676
   ) IS
--
   l_ovn 	per_all_people_f.object_version_number%TYPE;
--
BEGIN

   l_ovn := p_object_version_number + 1; -- BUG4081676

   UPDATE per_all_people_f
     set person_type_id          = p_person_type_id
        ,current_applicant_flag  = p_current_apl_flag
        ,current_emp_or_apl_flag = p_current_emp_apl_flag
        ,applicant_number      = p_applicant_number
        ,object_version_number = l_ovn -- BUG4081676
   where person_id            = p_person_id
     and effective_start_date = p_effective_start_date
     and effective_end_date   = p_effective_end_date;

   p_object_version_number := l_ovn; -- BUG4081676
   --
END Update_Person_rec;
-- ----------------------------------------------------------------------- +
-- -----------------------< Insert_Person_Rec >--------------------------- |
-- ----------------------------------------------------------------------- +
PROCEDURE Insert_Person_Rec(p_rec                   csr_person_record%ROWTYPE
                           ,p_person_id             number
                           ,p_effective_start_date  date
                           ,p_effective_end_date    date
                           ,p_person_type_id        number
                           ,p_applicant_number      varchar2
                           ,p_current_emp_apl_flag  varchar2
                           ,p_current_apl_flag      varchar2
                           ,p_current_npw_flag      varchar2
                           ,p_current_employee_flag varchar2
                           ,p_object_version_number in out nocopy number -- BUG4081676
                           ) IS
--
   l_created_by                per_all_people_f.created_by%TYPE;
   l_creation_date             per_all_people_f.creation_date%TYPE;
   l_last_update_date          per_all_people_f.last_update_date%TYPE;
   l_last_updated_by           per_all_people_f.last_updated_by%TYPE;
   l_last_update_login         per_all_people_f.last_update_login%TYPE;
   l_ovn                       per_all_people_f.object_version_number%TYPE;
--
BEGIN
   -- Set the AOL updated WHO values
   --
   l_last_update_date   := sysdate;
   l_last_updated_by    := fnd_global.user_id;
   l_last_update_login  := fnd_global.login_id;
   l_ovn := p_object_version_number + 1; -- BUG4081676

   INSERT INTO per_all_people_f
    (person_id,
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
    request_id,
    program_application_id,
    program_id,
    program_update_date,
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
    object_version_number,
    suffix,
    DATE_OF_DEATH,
    BACKGROUND_CHECK_STATUS         ,
    BACKGROUND_DATE_CHECK           ,
    BLOOD_TYPE                      ,
    CORRESPONDENCE_LANGUAGE         ,
    FAST_PATH_EMPLOYEE              ,
    FTE_CAPACITY                    ,
    HOLD_APPLICANT_DATE_UNTIL       ,
    HONORS                          ,
    INTERNAL_LOCATION               ,
    LAST_MEDICAL_TEST_BY            ,
    LAST_MEDICAL_TEST_DATE          ,
    MAILSTOP                        ,
    OFFICE_NUMBER                   ,
    ON_MILITARY_SERVICE             ,
    ORDER_NAME                      ,
    PRE_NAME_ADJUNCT                ,
    PROJECTED_START_DATE            ,
    REHIRE_AUTHORIZOR               ,
    REHIRE_RECOMMENDATION           ,
    RESUME_EXISTS                   ,
    RESUME_LAST_UPDATED             ,
    SECOND_PASSPORT_EXISTS          ,
    STUDENT_STATUS                  ,
    WORK_SCHEDULE                   ,
    PER_INFORMATION21               ,
    PER_INFORMATION22               ,
    PER_INFORMATION23               ,
    PER_INFORMATION24               ,
    PER_INFORMATION25               ,
    PER_INFORMATION26               ,
    PER_INFORMATION27               ,
    PER_INFORMATION28               ,
    PER_INFORMATION29               ,
    PER_INFORMATION30               ,
    REHIRE_REASON                   ,
    benefit_group_id                ,
    receipt_of_death_cert_date      ,
    coord_ben_med_pln_no            ,
    coord_ben_no_cvg_flag           ,
    COORD_BEN_MED_EXT_ER,
    COORD_BEN_MED_PL_NAME,
    COORD_BEN_MED_INSR_CRR_NAME,
    COORD_BEN_MED_INSR_CRR_IDENT,
    COORD_BEN_MED_CVG_STRT_DT,
    COORD_BEN_MED_CVG_END_DT,
    uses_tobacco_flag               ,
    dpdnt_adoption_date             ,
    dpdnt_vlntry_svce_flag          ,
    original_date_of_hire           ,
    town_of_birth                ,
    region_of_birth              ,
    country_of_birth             ,
    global_person_id             ,
    party_id             ,
    npw_number,
    current_npw_flag,
    local_name,
    global_name,
    created_by,
    creation_date,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    -- ---------------------------------------------
    VALUES
    -- ---------------------------------------------
    (p_person_id,
    p_effective_start_date,
    p_effective_end_date,
    p_rec.business_group_id,
    p_person_type_id,
    p_rec.last_name,
    p_rec.start_date,
    p_applicant_number,
    p_rec.comment_id,
    p_current_apl_flag,
    p_current_emp_apl_flag,
    p_current_employee_flag,
    p_rec.date_employee_data_verified,
    p_rec.date_of_birth,
    p_rec.email_address,
    p_rec.employee_number,
    p_rec.expense_check_send_to_address,
    p_rec.first_name,
    p_rec.full_name,
    p_rec.known_as,
    p_rec.marital_status,
    p_rec.middle_names,
    p_rec.nationality,
    p_rec.national_identifier,
    p_rec.previous_last_name,
    p_rec.registered_disabled_flag,
    p_rec.sex,
    p_rec.title,
    p_rec.vendor_id,
    p_rec.request_id,
    p_rec.program_application_id,
    p_rec.program_id,
    p_rec.program_update_date,
    p_rec.attribute_category,
    p_rec.attribute1,
    p_rec.attribute2,
    p_rec.attribute3,
    p_rec.attribute4,
    p_rec.attribute5,
    p_rec.attribute6,
    p_rec.attribute7,
    p_rec.attribute8,
    p_rec.attribute9,
    p_rec.attribute10,
    p_rec.attribute11,
    p_rec.attribute12,
    p_rec.attribute13,
    p_rec.attribute14,
    p_rec.attribute15,
    p_rec.attribute16,
    p_rec.attribute17,
    p_rec.attribute18,
    p_rec.attribute19,
    p_rec.attribute20,
    p_rec.attribute21,
    p_rec.attribute22,
    p_rec.attribute23,
    p_rec.attribute24,
    p_rec.attribute25,
    p_rec.attribute26,
    p_rec.attribute27,
    p_rec.attribute28,
    p_rec.attribute29,
    p_rec.attribute30,
    p_rec.per_information_category,
    p_rec.per_information1,
    p_rec.per_information2,
    p_rec.per_information3,
    p_rec.per_information4,
    p_rec.per_information5,
    p_rec.per_information6,
    p_rec.per_information7,
    p_rec.per_information8,
    p_rec.per_information9,
    p_rec.per_information10,
    p_rec.per_information11,
    p_rec.per_information12,
    p_rec.per_information13,
    p_rec.per_information14,
    p_rec.per_information15,
    p_rec.per_information16,
    p_rec.per_information17,
    p_rec.per_information18,
    p_rec.per_information19,
    p_rec.per_information20,
    -- p_rec.object_version_number,
    l_ovn,       -- BUG4081676
    p_rec.suffix,
    p_rec.DATE_OF_DEATH                     ,
    p_rec.BACKGROUND_CHECK_STATUS           ,
    p_rec.BACKGROUND_DATE_CHECK             ,
    p_rec.BLOOD_TYPE                        ,
    p_rec.CORRESPONDENCE_LANGUAGE           ,
    p_rec.FAST_PATH_EMPLOYEE                ,
    p_rec.FTE_CAPACITY                      ,
    p_rec.HOLD_APPLICANT_DATE_UNTIL         ,
    p_rec.HONORS                            ,
    p_rec.INTERNAL_LOCATION                 ,
    p_rec.LAST_MEDICAL_TEST_BY              ,
    p_rec.LAST_MEDICAL_TEST_DATE            ,
    p_rec.MAILSTOP                          ,
    p_rec.OFFICE_NUMBER                     ,
    p_rec.ON_MILITARY_SERVICE               ,
    p_rec.ORDER_NAME                        ,
    p_rec.PRE_NAME_ADJUNCT                  ,
    p_rec.PROJECTED_START_DATE              ,
    p_rec.REHIRE_AUTHORIZOR                 ,
    p_rec.REHIRE_RECOMMENDATION             ,
    p_rec.RESUME_EXISTS                     ,
    p_rec.RESUME_LAST_UPDATED               ,
    p_rec.SECOND_PASSPORT_EXISTS            ,
    p_rec.STUDENT_STATUS                    ,
    p_rec.WORK_SCHEDULE                     ,
    p_rec.PER_INFORMATION21                 ,
    p_rec.PER_INFORMATION22                 ,
    p_rec.PER_INFORMATION23                 ,
    p_rec.PER_INFORMATION24                 ,
    p_rec.PER_INFORMATION25                 ,
    p_rec.PER_INFORMATION26                 ,
    p_rec.PER_INFORMATION27                 ,
    p_rec.PER_INFORMATION28                 ,
    p_rec.PER_INFORMATION29                 ,
    p_rec.PER_INFORMATION30                 ,
    p_rec.REHIRE_REASON                     ,
    p_rec.BENEFIT_GROUP_ID                  ,
    p_rec.RECEIPT_OF_DEATH_CERT_DATE        ,
    p_rec.COORD_BEN_MED_PLN_NO              ,
    p_rec.COORD_BEN_NO_CVG_FLAG             ,
    p_rec.COORD_BEN_MED_EXT_ER,
    p_rec.COORD_BEN_MED_PL_NAME,
    p_rec.COORD_BEN_MED_INSR_CRR_NAME,
    p_rec.COORD_BEN_MED_INSR_CRR_IDENT,
    p_rec.COORD_BEN_MED_CVG_STRT_DT,
    p_rec.COORD_BEN_MED_CVG_END_DT ,
    p_rec.USES_TOBACCO_FLAG                 ,
    p_rec.DPDNT_ADOPTION_DATE               ,
    p_rec.DPDNT_VLNTRY_SVCE_FLAG            ,
    p_rec.ORIGINAL_DATE_OF_HIRE             ,
    p_rec.town_of_birth                           ,
    p_rec.region_of_birth                         ,
    p_rec.country_of_birth                        ,
    p_rec.global_person_id                        ,
    p_rec.party_id                        ,
    p_rec.npw_number,
    p_current_npw_flag,
    p_rec.local_name,
    p_rec.global_name,
    p_rec.created_by,
    p_rec.creation_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
    );

    p_object_version_number := l_ovn; -- BUG4081676

END Insert_Person_Rec;
-- -------------------------------------------------------------------------- +
-- |--------------------< Update_PER_PTU_to_EX_APL >------------------------- |
-- -------------------------------------------------------------------------- +
PROCEDURE Update_PER_PTU_to_EX_APL
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_effective_date            IN date
   ,p_person_type_id            IN number -- EX_APL type
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   )
IS
--
   cursor csr_get_person_details(cp_person_id number, cp_effective_date date)
    IS
     select *
     from per_all_people_f peo
     where person_id = cp_person_id
      and (effective_start_date >= cp_effective_date
            OR
           cp_effective_date between effective_start_date
                               and effective_end_date)
      order by peo.effective_start_date ASC
      for update of person_type_id;

   cursor csr_get_person_type(cp_person_type_id number) IS
      select ppt.system_person_type
        from per_person_types ppt
       where ppt.person_type_id = cp_person_type_id;

   cursor csr_ptu_details(cp_person_id number, cp_effective_date date) is
      select ptu.person_type_id, ppt.system_person_type
             ,ptu.effective_start_date, ptu.effective_end_date
        from per_person_type_usages_f ptu
            ,per_person_types ppt
       where ptu.person_id = cp_person_id
         and cp_effective_date between ptu.effective_start_date
                                   and ptu.effective_end_date
         and ppt.person_type_id = ptu.person_type_id
         and ppt.system_person_type in ('APL','EX_APL')
         order by effective_start_date ASC;


   l_proc constant varchar2(100) := g_package||'Update_PER_PTU_to_EX_APL';
   l_effective_date date;

   l_business_group_id    per_all_people_f.business_group_id%TYPE;
   l_effective_start_date per_all_people_f.effective_start_date%TYPE;
   l_effective_end_date   per_all_people_f.effective_end_date%TYPE;
   l_system_person_type   per_person_types.system_person_type%TYPE;
   l_ovn                  per_all_people_f.object_version_number%TYPE;

   l_new_person_type_id   per_person_types.person_type_id%TYPE;
   l_ptu_person_type_id   per_person_types.person_type_id%TYPE;
   l_new_sys_person_type  per_person_types.system_person_type%TYPE;

   l_new_effective_date   DATE;
   --
   l_per_effective_start_date   date;
   l_per_effective_end_date     date;
   l_name_combination_warning   boolean;
   l_dob_null_warning           boolean;
   l_orig_hire_warning          boolean;
   l_comment_id                 number;

   l_current_applicant_flag    per_people_f.current_applicant_flag%type;
   l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
   l_current_employee_flag     per_people_f.current_employee_flag%type;
   l_employee_number           per_people_f.employee_number%type;
   l_applicant_number          per_people_f.applicant_number%TYPE;
   l_npw_number                per_people_f.npw_number%TYPE;

   l_full_name                 per_people_f.full_name%type;

   l_person_rec                csr_get_person_details%ROWTYPE;
   l_future_person_rec         csr_get_person_details%ROWTYPE;
   l_ptu_rec                   csr_ptu_details%ROWTYPE;

   l_person_type_usage_id      per_person_type_usages_f.person_type_usage_id%TYPE;
   l_ptu_ovn                   per_person_type_usages_f.object_version_number%TYPE;
   l_ptu_eff_start_date        per_person_type_usages_f.effective_start_date%TYPE;
   l_ptu_eff_end_date          per_person_type_usages_f.effective_end_date%TYPE;


begin
   if g_debug then
      hr_utility.set_location(' Entering: '||l_proc,10);
   end if;
   --
   l_effective_date := trunc(p_effective_date);
   --
   l_ptu_person_type_id := p_person_type_id;
   per_per_bus.chk_person_type
    (p_person_type_id     => l_ptu_person_type_id,
     p_business_group_id  => p_business_group_id,
     p_expected_sys_type  => 'EX_APL');
   --
   if g_debug then
      hr_utility.set_location(' Entering: '||l_proc,10);
   end if;
   --
   open csr_get_person_details(p_person_id, l_effective_date);
   fetch csr_get_person_details into l_person_rec;
   if csr_get_person_details%FOUND then

       if g_debug then
          hr_utility.set_location(l_proc,15);
       end if;

       open csr_get_person_type(l_person_rec.person_type_id);
       fetch csr_get_person_type into l_system_person_type;
       close csr_get_person_type;

       get_new_EX_APL_person_type(l_person_rec.business_group_id
                                  ,l_system_person_type
                                  ,l_new_sys_person_type
                                  ,l_new_person_type_id);

       if hr_general2.is_person_type(
                   p_person_id       => l_person_rec.person_id
                  ,p_person_type     => 'EMP'
                  ,p_effective_date  => l_effective_date) then
          l_current_emp_or_apl_flag := 'Y';
       else
          l_current_emp_or_apl_flag := null;
       end if;
       l_current_applicant_flag := null;
       l_ovn := l_person_rec.object_version_number;
       l_new_effective_date := l_person_rec.effective_start_date;
       l_per_effective_end_date := l_person_rec.effective_end_date;

       if l_new_sys_person_type = l_system_person_type then
          --
          -- person is ex_applicant; do nothing
          --
             if g_debug then
                hr_utility.set_location(l_proc,20);
             end if;
          --
        else
          --
          -- update current record to ex_applicant
          --
             if l_person_rec.effective_start_date = l_effective_date then
                 --
                 -- Update current record, simulate 'CORRECTION' mode
                 --
                 if g_debug then
                     hr_utility.set_location(l_proc,25);
                 end if;
                 --
                 Update_Person_Rec
                    (p_person_id             => l_person_rec.person_id
                    ,p_effective_start_date  => l_person_rec.effective_start_date
                    ,p_effective_end_date    => l_person_rec.effective_end_date
                    ,p_person_type_id        => l_new_person_type_id
                    ,p_applicant_number      => l_person_rec.applicant_number
                    ,p_current_emp_apl_flag  => l_current_emp_or_apl_flag
                    ,p_current_apl_flag      => l_current_applicant_flag
                    ,p_object_version_number => l_ovn);

             else
                 --
                 -- DT update: person becomes ex_applicant on effective date
                 --
                 if g_debug then
                     hr_utility.set_location(l_proc,30);
                 end if;

                   l_new_effective_date := l_effective_date;
                   l_per_effective_end_date := l_person_rec.effective_end_date;
                   --
                   -- End date current record
                   UPDATE per_all_people_f
                     set effective_end_date = l_effective_date -1
                   where person_id = l_person_rec.person_id
                     and effective_start_date = l_person_rec.effective_start_date
                     and effective_end_date = l_person_rec.effective_end_date;

                   -- Create the new DT update using new person type
                   --
                    Insert_Person_Rec
                           (p_rec                   => l_person_rec
                           ,p_person_id             => p_person_id
                           ,p_effective_start_date  => l_effective_date
                           ,p_effective_end_date    => l_person_rec.effective_end_date
                           ,p_person_type_id        => l_new_person_type_id
                           ,p_applicant_number      => l_person_rec.applicant_number
                           ,p_current_emp_apl_flag  => l_current_emp_or_apl_flag
                           ,p_current_apl_flag      => l_current_applicant_flag
                           ,p_current_employee_flag => l_person_rec.current_employee_flag
                           ,p_current_npw_flag      => l_person_rec.current_npw_flag
                           ,p_object_version_number => l_ovn);
             end if;
          end if;
          --
          if g_debug then
              hr_utility.set_location(l_proc,40);
          end if;
          --
          -- process future person records using "CORRECTION" mode
          --
          LOOP
              fetch csr_get_person_details into l_person_rec;

              exit when csr_get_person_details%NOTFOUND;

                  open csr_get_person_type(l_person_rec.person_type_id);
                  fetch csr_get_person_type into l_system_person_type;
                  close csr_get_person_type;

                  l_ovn := l_person_rec.object_version_number;

                  get_new_EX_APL_person_type(l_person_rec.business_group_id
                                       , l_system_person_type
                                       , l_new_sys_person_type
                                       , l_new_person_type_id);
                  if hr_general2.is_person_type
                        (p_person_id       => l_person_rec.person_id
                        ,p_person_type     => 'EMP'
                        ,p_effective_date  => l_person_rec.effective_start_date) then
                      l_current_emp_or_apl_flag := 'Y';
                  else
                      l_current_emp_or_apl_flag := null;
                  end if;

                  if l_new_sys_person_type <> l_system_person_type then

                       Update_Person_Rec
                            (p_person_id             => l_person_rec.person_id
                            ,p_effective_start_date  => l_person_rec.effective_start_date
                            ,p_effective_end_date    => l_person_rec.effective_end_date
                            ,p_person_type_id        => l_new_person_type_id
                            ,p_applicant_number      => l_person_rec.applicant_number
                            ,p_current_emp_apl_flag  => l_current_emp_or_apl_flag
                            ,p_current_apl_flag      => l_current_applicant_flag
                            ,p_object_version_number => l_ovn);

                  end if;  -- person type is different

          END LOOP;
          if g_debug then
             hr_utility.set_location(l_proc,45);
          end if;

   else
      -- person details not found: ABNORMAL condition
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',l_proc);
      hr_utility.set_message_token('STEP',80);
      hr_utility.raise_error;
   end if;
   close csr_get_person_details;


   -- ---------------------------------------------------------------------- +
   -- ------------------------ PTU UPDATES --------------------------------- |
   -- ---------------------------------------------------------------------- +
   if g_debug then
      hr_utility.set_location(l_proc,50);
      hr_utility.trace('    ==> person record became EX_APL on '||
                          to_char(l_new_effective_date));
   end if;
   --
   open csr_ptu_details(p_person_id, l_new_effective_date);
   fetch csr_ptu_details into l_ptu_rec;
   if csr_ptu_details%FOUND then

          if l_ptu_rec.system_person_type = 'EX_APL' then
            --
            -- person is ex_applicant on new_effective_date
            --
            if g_debug then
               hr_utility.set_location(l_proc,60);
            end if;

          else -- person is APL
            if g_debug then
               hr_utility.set_location(l_proc,65);
            end if;
            --
            if l_ptu_rec.effective_end_date <> hr_api.g_eot then
                hr_per_type_usage_internal.maintain_person_type_usage
                (p_effective_date       => l_new_effective_date
                ,p_person_id            => p_person_id
                ,p_person_type_id       => l_ptu_person_type_id
                ,p_datetrack_update_mode   => hr_api.g_update_override
                );
            else
                hr_per_type_usage_internal.maintain_person_type_usage
                (p_effective_date       => l_new_effective_date
                ,p_person_id            => p_person_id
                ,p_person_type_id       => l_ptu_person_type_id
                ,p_datetrack_update_mode  => hr_api.g_update
                );
            end if;
           --
           end if;
    ELSE   -- APL ptu record not found
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',l_proc);
      hr_utility.set_message_token('STEP',85);
      hr_utility.raise_error;
    END IF;
    if g_debug then
        hr_utility.set_location(' Leaving: '||l_proc,1000);
    end if;
   --
   -- Setting OUT parameters
   --
   p_per_effective_start_date := l_new_effective_date;
   p_per_effective_end_date   := l_per_effective_end_date;
   --
end Update_PER_PTU_to_EX_APL;
--
--
-- -------------------------------------------------------------------------- +
-- |---------------------< Update_PER_PTU_Records >-------------------------- |
-- -------------------------------------------------------------------------- +
PROCEDURE Update_PER_PTU_Records
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_effective_date            IN date
   ,p_applicant_number          IN varchar2
   ,p_APL_person_type_id        IN number
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   ,p_per_object_version_number in out nocopy number -- BUG4081676
   )
IS
--
   cursor csr_get_person_details(cp_person_id number, cp_effective_date date)
    IS
     select *
     from per_all_people_f peo
     where person_id = cp_person_id
      and (effective_start_date >= cp_effective_date
            OR
           cp_effective_date between effective_start_date
                               and effective_end_date)
      order by peo.effective_start_date ASC
      for update of person_type_id;

   cursor csr_get_person_type(cp_person_type_id number) IS
      select ppt.system_person_type
        from per_person_types ppt
       where ppt.person_type_id = cp_person_type_id;

   cursor csr_ptu_details(cp_person_id number, cp_effective_date date) is
      select ptu.person_type_id, ppt.system_person_type
             ,ptu.effective_start_date, ptu.effective_end_date
        from per_person_type_usages_f ptu
            ,per_person_types ppt
       where ptu.person_id = cp_person_id
         and (cp_effective_date between ptu.effective_start_date
                                   and ptu.effective_end_date
              or
              effective_start_date > cp_effective_date)
         and ppt.person_type_id = ptu.person_type_id
         and ppt.system_person_type in ('APL','EX_APL')
         order by effective_start_date ASC;


   l_proc constant varchar2(100) := g_package||'Update_PER_PTU_Records';
   l_effective_date date;

   l_business_group_id    per_all_people_f.business_group_id%TYPE;
   l_effective_start_date per_all_people_f.effective_start_date%TYPE;
   l_effective_end_date   per_all_people_f.effective_end_date%TYPE;
   l_system_person_type   per_person_types.system_person_type%TYPE;
   l_ovn                  per_all_people_f.object_version_number%TYPE;

   l_ptu_person_type_id  per_person_types.person_type_id%TYPE;
   l_new_person_type_id   per_person_types.person_type_id%TYPE;
   l_new_sys_person_type  per_person_types.system_person_type%TYPE;
   l_first_person_type_id per_person_types.person_type_id%TYPE;
   l_current_person_type  per_person_types.person_type_id%TYPE;
   l_start_date           date;

   l_new_effective_date   DATE;
   --
   l_per_effective_start_date   date;
   l_per_effective_end_date     date;
   l_name_combination_warning   boolean;
   l_dob_null_warning           boolean;
   l_orig_hire_warning          boolean;
   l_comment_id                 number;

   l_current_applicant_flag    per_people_f.current_applicant_flag%type;
   l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
   l_current_employee_flag     per_people_f.current_employee_flag%type;
   l_employee_number           per_people_f.employee_number%type;
   l_applicant_number          per_people_f.applicant_number%TYPE;
   l_npw_number                per_people_f.npw_number%TYPE;

   l_full_name                 per_people_f.full_name%type;

   l_person_rec                csr_get_person_details%ROWTYPE;
   l_future_person_rec         csr_get_person_details%ROWTYPE;
   l_ptu_rec                   csr_ptu_details%ROWTYPE;

   l_person_type_usage_id      per_person_type_usages_f.person_type_usage_id%TYPE;
   l_ptu_ovn                   per_person_type_usages_f.object_version_number%TYPE;
   l_ptu_eff_start_date        per_person_type_usages_f.effective_start_date%TYPE;
   l_ptu_eff_end_date          per_person_type_usages_f.effective_end_date%TYPE;
   -- BUG4081676
   cursor csr_get_per_ovn is
     select object_version_number
     from per_all_people_f
     where person_id = p_person_id
     and   effective_start_date = l_new_effective_date
     and   effective_end_date   = l_per_effective_end_date;
   --
begin
   --
   if g_debug then
      hr_utility.set_location(' Entering: '||l_proc,10);
   end if;
   --
   l_effective_date := trunc(p_effective_date);
   --
   l_ptu_person_type_id := p_APL_person_type_id;
   per_per_bus.chk_person_type
    (p_person_type_id     => l_ptu_person_type_id,
     p_business_group_id  => p_business_group_id,
     p_expected_sys_type  => 'APL');
   --
   open csr_get_person_details(p_person_id, l_effective_date);
   fetch csr_get_person_details into l_person_rec;
   if csr_get_person_details%FOUND then

       if g_debug then
          hr_utility.set_location(l_proc,15);
       end if;
       --
       open csr_get_person_type(l_person_rec.person_type_id);
       fetch csr_get_person_type into l_system_person_type;
       close csr_get_person_type;
       --
       get_new_APL_person_type(l_person_rec.business_group_id
                              ,l_system_person_type
                              ,l_new_sys_person_type
                              ,l_new_person_type_id);
       --
       if l_person_rec.effective_start_date > l_effective_date then
         --
         -- person becomes applicant before first created in the system
         --
         if g_debug then
          hr_utility.set_location(l_proc,16);
         end if;
         --
         l_ovn := l_person_rec.object_version_number;

         l_new_effective_date := l_effective_date;
         l_per_effective_end_date := l_person_rec.effective_start_date - 1;
         --
         Insert_Person_Rec
               (p_rec                   => l_person_rec
               ,p_person_id             => p_person_id
               ,p_effective_start_date  => l_effective_date
               ,p_effective_end_date    => l_person_rec.effective_start_date - 1
               ,p_person_type_id        => l_ptu_person_type_id
               ,p_applicant_number      => p_applicant_number
               ,p_current_emp_apl_flag  => 'Y'
               ,p_current_apl_flag      => 'Y'
               ,p_current_employee_flag => NULL
               ,p_current_npw_flag      => NULL
               ,p_object_version_number => l_ovn); -- BUG4081676
         --
         if l_person_rec.applicant_number is null then
            l_applicant_number := p_applicant_number;
         else
            l_applicant_number := l_person_rec.applicant_number;
         end if;
         if l_system_person_type <> l_new_sys_person_type then
            Update_Person_Rec
                 (p_person_id             => l_person_rec.person_id
                 ,p_effective_start_date  => l_person_rec.effective_start_date
                 ,p_effective_end_date    => l_person_rec.effective_end_date
                 ,p_person_type_id        => l_new_person_type_id
                 ,p_applicant_number      => l_applicant_number
                 ,p_current_emp_apl_flag  => 'Y'
                 ,p_current_apl_flag      => 'Y'
                 ,p_object_version_number => l_ovn); -- BUG4081676
         end if;
       -- --------------------------------------------------------------------+
       else
       -- --------------------------------------------------------------------+
        l_ovn := l_person_rec.object_version_number;
        l_new_effective_date := l_person_rec.effective_start_date;
        l_per_effective_end_date := l_person_rec.effective_end_date;
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
        if l_new_sys_person_type = l_system_person_type then
          --
          -- person is applicant; do nothing
          --
             if g_debug then
                hr_utility.set_location(l_proc,20);
             end if;
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
        else
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
          -- update current record to applicant
          -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
             if l_person_rec.effective_start_date = l_effective_date then
                 --
                 -- Update current record, simulate 'CORRECTION' mode
                 --
                 if g_debug then
                     hr_utility.set_location(l_proc,25);
                 end if;
                 --
                 Update_Person_Rec
                    (p_person_id             => l_person_rec.person_id
                    ,p_effective_start_date  => l_person_rec.effective_start_date
                    ,p_effective_end_date    => l_person_rec.effective_end_date
                    ,p_person_type_id        => l_new_person_type_id
                    ,p_applicant_number      => p_applicant_number
                    ,p_current_emp_apl_flag  => 'Y'
                    ,p_current_apl_flag      => 'Y'
                    ,p_object_version_number => l_ovn); -- BUG4081676
             -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
             else
             -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                 -- DT update: person becomes applicant on effective date
                 --
                 if g_debug then
                     hr_utility.set_location(l_proc,30);
                 end if;

                   l_new_effective_date := l_effective_date;
                   l_per_effective_end_date := l_person_rec.effective_end_date;
                   --
                   -- End date current record
                   UPDATE per_all_people_f
                     set effective_end_date = l_effective_date -1
                   where person_id = l_person_rec.person_id
                     and effective_start_date = l_person_rec.effective_start_date
                     and effective_end_date = l_person_rec.effective_end_date;

                   -- Create the new DT update using new person type
                   --
                    Insert_Person_Rec
                           (p_rec                   => l_person_rec
                           ,p_person_id             => p_person_id
                           ,p_effective_start_date  => l_effective_date
                           ,p_effective_end_date    => l_person_rec.effective_end_date
                           ,p_person_type_id        => l_new_person_type_id
                           ,p_applicant_number      => p_applicant_number
                           ,p_current_emp_apl_flag  => 'Y'
                           ,p_current_apl_flag      => 'Y'
                           ,p_current_employee_flag => l_person_rec.current_employee_flag
                           ,p_current_npw_flag      => l_person_rec.current_npw_flag
                           ,p_object_version_number => l_ovn); -- BUG4081676

             end if; -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++
          end if;    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
         end if;  -- person became applicant before first created?
          --
          if g_debug then
              hr_utility.set_location(l_proc,40);
          end if;
          --
          -- process future person records using "CORRECTION" mode
          --
          LOOP
              fetch csr_get_person_details into l_person_rec;

              exit when csr_get_person_details%NOTFOUND;

                  open csr_get_person_type(l_person_rec.person_type_id);
                  fetch csr_get_person_type into l_system_person_type;
                  close csr_get_person_type;

                  -- l_ovn := l_person_rec.object_version_number;

                  get_new_APL_person_type(l_person_rec.business_group_id
                                       , l_system_person_type
                                       , l_new_sys_person_type
                                       , l_new_person_type_id);

                  if l_new_sys_person_type <> l_system_person_type then
                       if l_person_rec.applicant_number is null then
                          l_applicant_number := p_applicant_number;
                       else
                          l_applicant_number := l_person_rec.applicant_number;
                       end if;
                       --
                       Update_Person_Rec
                            (p_person_id             => l_person_rec.person_id
                            ,p_effective_start_date  => l_person_rec.effective_start_date
                            ,p_effective_end_date    => l_person_rec.effective_end_date
                            ,p_person_type_id        => l_new_person_type_id
                            ,p_applicant_number      => l_applicant_number
                            ,p_current_emp_apl_flag  => 'Y'
                            ,p_current_apl_flag      => 'Y'
                            ,p_object_version_number => l_ovn); -- BUG4081676

                  end if;  -- person type is different

          END LOOP;
          if g_debug then
             hr_utility.set_location(l_proc,45);
          end if;

   else
      -- person details not found: ABNORMAL condition
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',l_proc);
      hr_utility.set_message_token('STEP',50);
      hr_utility.raise_error;
   end if;
   close csr_get_person_details;

   -- ---------------------------------------------------------------------- +
   -- ------------------------ PTU UPDATES --------------------------------- |
   -- ---------------------------------------------------------------------- +
   if g_debug then
      hr_utility.set_location(l_proc,50);
      hr_utility.trace('    ==> person record became APL on '||
                          to_char(l_new_effective_date));
   end if;
   -- get default APL person type for PTU updates
   l_new_person_type_id := l_ptu_person_type_id;

   open csr_ptu_details(p_person_id, l_new_effective_date);
   fetch csr_ptu_details into l_ptu_rec;
   if csr_ptu_details%FOUND then

      if l_ptu_rec.effective_start_date > l_new_effective_date then
      -- APL is created in the future, so change the start date
      -- and cancel first EX_APL + future rows after EX_APL
      --
        if l_ptu_rec.system_person_type <> 'APL' then
        -- person should be an applicant otherwise it is an abnormal condition
          close csr_ptu_details;
          hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
          hr_utility.set_message_token('PROCEDURE',l_proc);
          hr_utility.set_message_token('STEP',60);
          hr_utility.raise_error;
        else
        --
           l_first_person_type_id := l_ptu_rec.person_type_id;

           hr_per_type_usage_internal.change_hire_date_ptu
            (p_date_start         => l_new_effective_date
            ,p_old_date_start     => l_ptu_rec.effective_start_date
            ,p_person_id          => p_person_id
            ,p_system_person_type => l_ptu_rec.system_person_type
            );
           l_start_date := l_ptu_rec.effective_start_date;
           Loop
            fetch csr_ptu_details into l_ptu_rec;
            exit when csr_ptu_details%NOTFOUND;

               if l_ptu_rec.system_person_type = 'EX_APL' then
                  hr_per_type_usage_internal.maintain_person_type_usage
                    (p_effective_date          => l_start_date
                    ,p_person_id               => p_person_id
                    ,p_person_type_id          => l_first_person_type_id
                    ,p_datetrack_delete_mode   => hr_api.g_future_change
                    );
                  exit;
               else
                 l_start_date := l_ptu_rec.effective_start_date;
                 l_first_person_type_id := l_ptu_rec.person_type_id;
               end if;
           end loop;
           close csr_ptu_details;

        end if; -- person is APL
      --
      else -- start_date <= new effective date
          --
          if l_ptu_rec.system_person_type = 'APL' then
            --
            -- person is applicant on new_effective_date
            --
            if g_debug then
               hr_utility.set_location(l_proc,60);
            end if;
            l_first_person_type_id := l_ptu_rec.person_type_id;
            --
            -- check whether future changes exist, if yes delete otherwise do nothing
            --
            l_start_date := l_ptu_rec.effective_start_date;
            l_current_person_type := l_ptu_rec.person_type_id;
            Loop
             fetch csr_ptu_details into l_ptu_rec;
             exit when csr_ptu_details%NOTFOUND;

               if l_ptu_rec.system_person_type = 'EX_APL' then
                  hr_per_type_usage_internal.maintain_person_type_usage  -- 3962781
                    (p_effective_date          => l_start_date
                    ,p_person_id               => p_person_id
                    ,p_person_type_id          => l_current_person_type
                    ,p_datetrack_delete_mode   => hr_api.g_future_change
                    );
                 --
                 exit;
               else
                  l_start_date := l_ptu_rec.effective_start_date;
                  l_current_person_type  := l_ptu_rec.person_type_id;
               end if;
            end loop;
            close csr_ptu_details;
          --
          else -- person is EX_APL
            if g_debug then
               hr_utility.set_location(l_proc,65);
            end if;
            --
            if l_ptu_rec.effective_start_date = l_new_effective_date then
                close csr_ptu_details;
                open csr_ptu_details(p_person_id, l_new_effective_date -1);
                fetch csr_ptu_details into l_ptu_rec;
                close csr_ptu_details;
                --
                hr_per_type_usage_internal.maintain_person_type_usage      -- 3962781
                (p_effective_date        => l_new_effective_date -1
                ,p_person_id             => p_person_id
                ,p_person_type_id        => l_ptu_rec.person_type_id --l_new_person_type_id
                ,p_datetrack_delete_mode => hr_api.g_future_change
                );
                hr_per_type_usage_internal.maintain_person_type_usage
                   (p_effective_date       => l_new_effective_date
                   ,p_person_id            => p_person_id
                   ,p_person_type_id       => l_new_person_type_id
                   ,p_datetrack_update_mode   => hr_api.g_update
                   );
            else
                if g_debug then
                   hr_utility.set_location(l_proc,75);
                end if;
                close csr_ptu_details;
                if l_ptu_rec.effective_end_date <> hr_api.g_eot then
                    hr_per_type_usage_internal.maintain_person_type_usage
                    (p_effective_date       => l_new_effective_date
                    ,p_person_id            => p_person_id
                    ,p_person_type_id       => l_new_person_type_id
                    ,p_datetrack_update_mode   => hr_api.g_update_override
                    );
                else
                    hr_per_type_usage_internal.maintain_person_type_usage
                    (p_effective_date       => l_new_effective_date
                    ,p_person_id            => p_person_id
                    ,p_person_type_id       => l_new_person_type_id
                    ,p_datetrack_update_mode   => hr_api.g_update
                    );
                end if;
            end if;
           --
           end if;
      end if;
    ELSE   -- APL ptu record not found
        ---
        -- person needs to be transformed into applicant on effective_date
        --
        if g_debug then
           hr_utility.set_location(l_proc,80);
        end if;
       hr_per_type_usage_internal.create_person_type_usage
        (p_person_id                => p_person_id
        ,p_person_type_id           => l_new_person_type_id
        ,p_effective_date           => l_new_effective_date
        ,p_person_type_usage_id     => l_person_type_usage_id
        ,p_object_version_number    => l_ptu_ovn
        ,p_effective_start_date     => l_ptu_eff_start_date
        ,p_effective_end_date       => l_ptu_eff_end_date
        );

    END IF;

   -- Get the person's object version number BUG4081676
   open csr_get_per_ovn;
   fetch csr_get_per_ovn into l_ovn;
   close csr_get_per_ovn;

    if g_debug then
        hr_utility.trace(' l_ovn : '||l_ovn);
        hr_utility.set_location(' Leaving: '||l_proc,1000);
    end if;
   --
   -- Setting OUT parameters
   --
   p_per_effective_start_date := l_new_effective_date;
   p_per_effective_end_date   := l_per_effective_end_date;
   p_per_object_version_number := l_ovn;   -- BUG4081676

end Update_PER_PTU_Records;
--
-- -------------------------------------------------------------------------- +
-- |-------------------< Upd_person_EX_APL_and_APL >------------------------- |
-- -------------------------------------------------------------------------- +
PROCEDURE Upd_person_EX_APL_and_APL
   (p_business_group_id         IN number
   ,p_person_id                 IN number
   ,p_ex_apl_effective_date     IN date   -- date person becomes EX_APL
   ,p_apl_effective_date        IN date   -- date person becomes APL
   ,p_per_effective_start_date  out nocopy date
   ,p_per_effective_end_date    out nocopy DATE
   )
IS
--
   cursor csr_get_person_details(cp_person_id number, cp_ex_apl_date date, cp_apl_date date) is
        select *
        from per_all_people_f peo
        where person_id = cp_person_id
        and (cp_ex_apl_date between effective_start_date
                                and effective_end_date   -- becomes ex-apl on this date
            or cp_apl_date between effective_start_date
                               and effective_end_date    -- is apl on this date
            )
        order by peo.effective_start_date ASC;
   --
   cursor csr_get_person_type(cp_person_type_id number) IS
      select ppt.system_person_type
        from per_person_types ppt
       where ppt.person_type_id = cp_person_type_id;

   cursor csr_ptu_details(cp_person_id number, cp_effective_date date) is
      select ptu.person_type_id, ppt.system_person_type
             ,ptu.effective_start_date, ptu.effective_end_date
        from per_person_type_usages_f ptu
            ,per_person_types ppt
       where ptu.person_id = cp_person_id
         and cp_effective_date between ptu.effective_start_date
                                   and ptu.effective_end_date
         and ppt.person_type_id = ptu.person_type_id
         and ppt.system_person_type in ('APL','EX_APL')
         order by effective_start_date ASC;
    --
   l_proc constant varchar2(100) := g_package||'Upd_person_EX_APL_and_APL';
   l_effective_date date;

   l_business_group_id    per_all_people_f.business_group_id%TYPE;
   l_effective_start_date per_all_people_f.effective_start_date%TYPE;
   l_effective_end_date   per_all_people_f.effective_end_date%TYPE;
   l_system_person_type   per_person_types.system_person_type%TYPE;
   l_ovn                  per_all_people_f.object_version_number%TYPE;

   l_new_person_type_id   per_person_types.person_type_id%TYPE;
   l_ptu_person_type_id   per_person_types.person_type_id%TYPE;
   l_new_sys_person_type  per_person_types.system_person_type%TYPE;

   l_new_effective_date   DATE;
   --
   l_per_effective_start_date   date;
   l_per_effective_end_date     date;
   l_name_combination_warning   boolean;
   l_dob_null_warning           boolean;
   l_orig_hire_warning          boolean;
   l_comment_id                 number;

   l_current_applicant_flag    per_people_f.current_applicant_flag%type;
   l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
   l_current_employee_flag     per_people_f.current_employee_flag%type;
   l_employee_number           per_people_f.employee_number%type;
   l_applicant_number          per_people_f.applicant_number%TYPE;
   l_npw_number                per_people_f.npw_number%TYPE;

   l_full_name                 per_people_f.full_name%type;

   l_person_rec                csr_get_person_details%ROWTYPE;
   l_future_person_rec         csr_get_person_details%ROWTYPE;
   l_ptu_rec                   csr_ptu_details%ROWTYPE;

   l_person_type_usage_id      per_person_type_usages_f.person_type_usage_id%TYPE;
   l_ptu_ovn                   per_person_type_usages_f.object_version_number%TYPE;
   l_ptu_eff_start_date        per_person_type_usages_f.effective_start_date%TYPE;
   l_ptu_eff_end_date          per_person_type_usages_f.effective_end_date%TYPE;
   --
   l_ex_per_rec  csr_get_person_details%ROWTYPE;
   l_apl_per_rec csr_get_person_details%ROWTYPE;
   --
    PROCEDURE Upd_person
        (p_mode                   varchar2
        ,p_ex_apl_rec             csr_get_person_details%ROWTYPE
        ,p_apl_rec                csr_get_person_details%ROWTYPE
        ,p_ex_apl_date            date
        ,p_apl_date               date
        ,p_person_type            number
        ,p_current_emp_apl_flag   varchar2
        ,p_current_apl_flag       varchar2
        ,p_object_version_number in out nocopy number
        ) IS
    BEGIN
        if p_mode = 'CORRECTION' then
            UPDATE per_all_people_f
               SET person_type_id = p_person_type
             WHERE person_id = p_ex_apl_rec.person_id
               AND effective_start_date = p_ex_apl_rec.effective_start_date
               AND effective_end_date   = p_ex_apl_rec.effective_end_date;
        else
            -- the UPDATE scenarios will:
            -- a. end current applicant record
            -- b. create the ex_applicant record effective on p_ex_apl_date
            -- c. insert/update APL record depending on scenario
            --
            -- a. End APL record
            UPDATE per_all_people_f
               SET effective_end_date = p_ex_apl_date - 1
             WHERE person_id = p_ex_apl_rec.person_id
               AND effective_start_date = p_ex_apl_rec.effective_start_date
               AND effective_end_date   = p_ex_apl_rec.effective_end_date;
            --
            -- b. Insert EX_APL record as of p_ex_apl_date
            Insert_Person_Rec(
                p_rec                   => p_ex_apl_rec
               ,p_person_id             => p_ex_apl_rec.person_id
               ,p_effective_start_date  => p_ex_apl_date
               ,p_effective_end_date    => p_apl_date - 1
               ,p_person_type_id        => p_person_type
               ,p_applicant_number      => p_ex_apl_rec.applicant_number
               ,p_current_emp_apl_flag  => p_current_emp_apl_flag
               ,p_current_apl_flag      => p_current_apl_flag
               ,p_current_employee_flag => p_ex_apl_rec.current_employee_flag
               ,p_current_npw_flag      => p_ex_apl_rec.current_npw_flag
               ,p_object_version_number => p_object_version_number  -- BUG4081676
               );
             -- c. Insert/Update next APL record
            if p_mode = 'UPDATE_CHANGE_INSERT' then
                -- insert APL record as of p_apl_date
                Insert_Person_Rec(
                    p_rec                   => p_ex_apl_rec
                   ,p_person_id             => p_ex_apl_rec.person_id
                   ,p_effective_start_date  => p_apl_date
                   ,p_effective_end_date    => p_ex_apl_rec.effective_end_date
                   ,p_person_type_id        => p_ex_apl_rec.person_type_id
                   ,p_applicant_number      => p_ex_apl_rec.applicant_number
                   ,p_current_emp_apl_flag  => p_ex_apl_rec.current_emp_or_apl_flag
                   ,p_current_apl_flag      => p_ex_apl_rec.current_applicant_flag
                   ,p_current_employee_flag => p_ex_apl_rec.current_employee_flag
                   ,p_current_npw_flag      => p_ex_apl_rec.current_npw_flag
                   ,p_object_version_number => p_object_version_number  -- BUG4081676
		);
            elsif p_mode = 'UPDATE_OVERRIDE' then
                -- insert APL record as of p_apl_date
                UPDATE per_all_people_f
                   SET effective_start_date = p_apl_date
                 WHERE person_id            = p_apl_rec.person_id
                   AND effective_start_date = p_apl_rec.effective_start_date
                   AND effective_end_date   = p_apl_rec.effective_end_date;
            end if;
        end if;
    END Upd_person;
   --
BEGIN
   if g_debug then
      hr_utility.set_location(' Entering: '||l_proc,10);
   end if;
  --
  open csr_get_person_details (p_person_id, p_ex_apl_effective_date, p_apl_effective_date);
  fetch csr_get_person_details into l_ex_per_rec;
  --
  if csr_get_person_details%FOUND then -- yes current
     --
       open csr_get_person_type(l_ex_per_rec.person_type_id);
       fetch csr_get_person_type into l_system_person_type;
       close csr_get_person_type;

       get_new_EX_APL_person_type(l_ex_per_rec.business_group_id
                                  ,l_system_person_type
                                  ,l_new_sys_person_type
                                  ,l_new_person_type_id);
       --
       if hr_general2.is_person_type(
                   p_person_id       => l_ex_per_rec.person_id
                  ,p_person_type     => 'EMP'
                  ,p_effective_date  => l_effective_date) then
          l_current_emp_or_apl_flag := 'Y';
       else
          l_current_emp_or_apl_flag := null;
       end if;
       l_current_applicant_flag := null;
       l_ovn := l_ex_per_rec.object_version_number;
       l_new_effective_date     := l_ex_per_rec.effective_start_date;
       l_per_effective_end_date := l_ex_per_rec.effective_end_date;
       --
       if l_ex_per_rec.effective_start_date = p_ex_apl_effective_date then
           -- correct current: only update person type
           close csr_get_person_details;
           Upd_person( p_mode                   => 'CORRECTION'
                      ,p_ex_apl_rec             => l_ex_per_rec
                      ,p_apl_rec                => NULL
                      ,p_ex_apl_date            => p_ex_apl_effective_date
                      ,p_apl_date               => NULL
                      ,p_person_type            => l_new_person_type_id
                      ,p_current_emp_apl_flag   => l_current_emp_or_apl_flag
                      ,p_current_apl_flag       => l_current_applicant_flag
                      ,p_object_version_number  => l_ovn -- BUG4081676
                      );
       else
           fetch csr_get_person_details into l_apl_per_rec;
           if csr_get_person_details%NOTFOUND then  -- next not found
              --
              -- |----APL----> OR
              -- |----APL----|---APL--->
              --    |----| << the EX_APL period does not expand current APL record
              --
              -- end date current, DT update insert (ex_apl) before apl date,
              -- insert APL on apl date
              --
              close csr_get_person_details;
              Upd_person(p_mode             => 'UPDATE_CHANGE_INSERT'
                  ,p_ex_apl_rec             => l_ex_per_rec
                  ,p_apl_rec                => NULL
                  ,p_ex_apl_date            => p_ex_apl_effective_date
                  ,p_apl_date               => p_apl_effective_date
                  ,p_person_type            => l_new_person_type_id
                  ,p_current_emp_apl_flag   => l_current_emp_or_apl_flag
                  ,p_current_apl_flag       => l_current_applicant_flag
                  ,p_object_version_number  => l_ovn -- BUG4081676
                  );

           else
              -- next found
              -- |----APL----|---APL--->
              --           |----| << the EX_APL period expands two APL records
              --
              -- end date current, insert DT update (ex_apl), move start date of next record
              --
              close csr_get_person_details;
              Upd_person(p_mode             => 'UPDATE_OVERRIDE'
                  ,p_ex_apl_rec             => l_ex_per_rec
                  ,p_apl_rec                => l_apl_per_rec
                  ,p_ex_apl_date            => p_ex_apl_effective_date
                  ,p_apl_date               => p_apl_effective_date
                  ,p_person_type            => l_new_person_type_id
                  ,p_current_emp_apl_flag   => l_current_emp_or_apl_flag
                  ,p_current_apl_flag       => l_current_applicant_flag
                  ,p_object_version_number  => l_ovn -- BUG4081676
                  );
           end if;
           --
        end if;
     --
  else
    close csr_get_person_details;
    -- abnormal: record not found
    null;
  end if;
   -- ---------------------------------------------------------------------- +
   -- ------------------------ PTU UPDATES --------------------------------- |
   -- ---------------------------------------------------------------------- +
   if g_debug then
      hr_utility.set_location(l_proc,50);
      hr_utility.trace('    ==> person record became EX_APL on '||
                          to_char(l_new_effective_date));
   end if;
   --
   l_ptu_person_type_id := hr_person_type_usage_info.get_default_person_type_id
                              (p_business_group_id, 'EX_APL');

   open csr_ptu_details(p_person_id, p_ex_apl_effective_date);
   fetch csr_ptu_details into l_ptu_rec;
   IF csr_ptu_details%FOUND THEN

      if l_ptu_rec.system_person_type = 'EX_APL' then
        --
        -- person is ex_applicant on p_ex_apl_effective_date
        --
        if g_debug then
           hr_utility.set_location(l_proc,60);
        end if;

      else -- person is APL
        if g_debug then
           hr_utility.set_location(l_proc,65);
        end if;
        --
        if l_ptu_rec.effective_end_date <> hr_api.g_eot then
            hr_per_type_usage_internal.maintain_person_type_usage
            (p_effective_date       => p_ex_apl_effective_date
            ,p_person_id            => p_person_id
            ,p_person_type_id       => l_ptu_person_type_id    -- EX_APL record
            ,p_datetrack_update_mode   => hr_api.g_update_change_insert
            );
        else
            hr_per_type_usage_internal.maintain_person_type_usage
            (p_effective_date       => p_ex_apl_effective_date
            ,p_person_id            => p_person_id
            ,p_person_type_id       => l_ptu_person_type_id   -- EX_APL record
            ,p_datetrack_update_mode  => hr_api.g_update
            );
            hr_per_type_usage_internal.maintain_person_type_usage
            (p_effective_date       => p_apl_effective_date
            ,p_person_id            => p_person_id
            ,p_person_type_id       => l_ptu_rec.person_type_id  -- APL record
            ,p_datetrack_update_mode  => hr_api.g_update
            );
        end if;
       --
       end if;
    ELSE   -- APL ptu record not found
      hr_utility.set_message(800,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE',l_proc);
      hr_utility.set_message_token('STEP',95);
      hr_utility.raise_error;
    END IF;
    if g_debug then
        hr_utility.set_location(' Leaving: '||l_proc,1000);
    end if;
   --
   -- Setting OUT parameters
   --
   p_per_effective_start_date := l_new_effective_date;
   p_per_effective_end_date   := l_per_effective_end_date;

end Upd_person_EX_APL_and_APL;

-- -------------------------------------------------------------------------- +
-- |--------------------< Update_APL_Assignments >--------------------------- |
-- -------------------------------------------------------------------------- +
PROCEDURE Update_APL_Assignments
   (p_business_group_id  IN number
   ,p_old_application_id IN number
   ,p_new_application_id IN number
   )
 IS
BEGIN
   hr_utility.trace('Update APL asg belonging to future applications');
   hr_utility.trace('OLD appl id = '||p_old_application_id);
   hr_utility.trace('New appl id = '||p_new_application_id);

   UPDATE per_all_assignments_f
      set application_id = p_new_application_id
      where business_group_id = p_business_group_id
        and application_id is not null
        and application_id = p_old_application_id;

END Update_APL_Assignments;
--
-- -------------------------------------------------------------------------- +
-- |----------------------< create_application >----------------------------- |
-- -------------------------------------------------------------------------- +
PROCEDURE Create_Application
          (p_application_id            OUT nocopy   number
          ,p_business_group_id         IN           number
          ,p_person_id                 IN           number
          ,p_effective_date            IN           date
          ,p_date_received             OUT nocopy   date
          ,p_object_version_number     OUT nocopy   number
          ,p_appl_override_warning     OUT nocopy   boolean
          ,p_validate_df_flex          IN           boolean default true --4689836
          ) IS

    cursor csr_fut_apl(cp_person_id number, cp_effective_date date) is
        select application_id, date_received, object_version_number
        from per_applications
        where person_id = cp_person_id
        and   date_received > cp_effective_date
        order by date_received asc;

    cursor csr_current_apl(cp_person_id number, cp_effective_date date) is
        select application_id, date_received, object_version_number
        from per_applications
        where person_id = cp_person_id
        and   date_received <= cp_effective_date
        and   nvl(date_end,hr_api.g_eot) >= cp_effective_date;

    cursor csr_apl_yesterday(cp_person_id number, cp_effective_date date) is
        select application_id, date_received, object_version_number
        from per_applications
        where person_id = cp_person_id
        and   date_end = cp_effective_date-1;

    -- start changes for bug 8337406
    cursor csr_chk_EMP_or_CWK(cp_person_id number, cp_effective_date date) is
	select 1
        from per_person_types ppt, per_person_type_usages_f ptu
        where ptu.person_type_id = ppt.person_type_id
         and ppt.business_group_id = p_business_group_id
         AND ptu.person_id = p_person_id
         and ppt.system_person_type in ('EMP','CWK')
         and ptu.effective_start_date = cp_effective_date;

    l_dummy                 number;
    -- start changes for bug 8337406

    l_proc                        constant varchar2(100) := g_package||
                                     '.create_application';
    l_future_apl_id               per_applications.application_id%TYPE;
    l_fut_apl_date_received       per_applications.date_received%TYPE;
    l_fut_apl_ovn                 per_applications.object_version_number%TYPE;

    l_current_apl_id              per_applications.application_id%TYPE;
    l_yesterday_apl_id            per_applications.application_id%TYPE;

    l_application_id             per_applications.application_id%TYPE;
    l_date_received              per_applications.date_received%TYPE;
    l_apl_object_version_number  per_applications.object_version_number%TYPE;

    l_del_fut_apl_id             per_applications.application_id%TYPE;
    l_del_fut_apl_date_received  per_applications.date_received%TYPE;
    l_del_fut_apl_ovn            per_applications.object_version_number%TYPE;

    l_appl_override_warning boolean;
    l_rowcount              number;
    l_effective_date        date;

    l_date_received_OUT     per_applications.date_received%TYPE;
    l_application_id_OUT    per_applications.application_id%TYPE;
    l_apl_ovn_OUT           per_applications.object_version_number%TYPE;

begin
    if g_debug then
       hr_utility.set_location(' Entering: '||l_proc,10);
    end if;
    --
    l_appl_override_warning := FALSE;
    l_rowcount := 0;
    --
    l_effective_date := trunc(p_effective_date);
    --
    open csr_fut_apl(p_person_id, l_effective_date);
    fetch csr_fut_apl into l_future_apl_id, l_fut_apl_date_received
                                     ,l_fut_apl_ovn;

    if csr_fut_apl%notfound then               --no future

      hr_utility.trace('NO FUTURE');

      open csr_current_apl(p_person_id, l_effective_date) ;
      fetch csr_current_apl into l_current_apl_id, l_date_received
                                     ,l_apl_object_version_number;

      if csr_current_apl%notfound then         --no future, no current

        hr_utility.trace('NO FUTURE, NO CURRENT');
        close csr_current_apl;
        open csr_apl_yesterday(p_person_id, l_effective_date);
        fetch csr_apl_yesterday into l_yesterday_apl_id, l_date_received
                                     ,l_apl_object_version_number;

        if csr_apl_yesterday%notfound then     --no future, no current, no yesterday
          close csr_apl_yesterday;

          --insert brand new application
          hr_utility.trace('no future, no current, no yesterday');
          hr_utility.trace('Insert brand new application');

          per_apl_ins.ins
              (p_application_id            => l_application_id
              ,p_business_group_id         => p_business_group_id
              ,p_person_id                 => p_person_id
              ,p_date_received             => l_effective_date
              ,p_object_version_number     => l_apl_object_version_number
              ,p_effective_date            => l_effective_date
              ,p_validate_df_flex          => false -- 4689836
              );

          l_date_received_OUT  := l_effective_date;
          l_application_id_OUT := l_application_id;
          l_apl_ovn_OUT        := l_apl_object_version_number;

        else                                    -- no future, no current, yes yesterday

          close csr_apl_yesterday;

          -- start changes for bug 8337406
          -- in case if a person becomes a EMP or CWK on the same day then
          -- system will create a new application.

          open csr_chk_EMP_or_CWK(p_person_id, l_effective_date);
          fetch csr_chk_EMP_or_CWK into l_dummy;
          if csr_chk_EMP_or_CWK%found then

              hr_utility.trace('EMP or CWK on the same day');
              hr_utility.trace('Insert new application');

              CLOSE csr_chk_EMP_or_CWK;

              per_apl_ins.ins
              (p_application_id            => l_application_id
              ,p_business_group_id         => p_business_group_id
              ,p_person_id                 => p_person_id
              ,p_date_received             => l_effective_date
              ,p_object_version_number     => l_apl_object_version_number
              ,p_effective_date            => l_effective_date
              ,p_validate_df_flex          => false
              );

             l_date_received_OUT  := l_effective_date;
             l_application_id_OUT := l_application_id;
             l_apl_ovn_OUT        := l_apl_object_version_number;

          else

             hr_utility.trace('No EMP or CWK on the same');
             CLOSE csr_chk_EMP_or_CWK;
             -- end changes for bug 8337406

             --
             -- set date_end to null where application_id=l_yesterday_apl_id
             --
             per_apl_upd.upd
               (p_application_id             => l_yesterday_apl_id
               ,p_date_end                   => null
               --bug 4369122 starts here
               ,p_termination_reason          =>null
               --bug 4369122 ends here
               ,p_object_version_number      => l_apl_object_version_number
               ,p_effective_date             => l_effective_date
               );

             l_date_received_OUT  := l_date_received;
             l_application_id_OUT := l_yesterday_apl_id;
             l_apl_ovn_OUT        := l_apl_object_version_number;
          END IF;

        end if; -- added for bug 8337406
      -- ----------------------------------------
      else  --no future, yes current
      -- ----------------------------------------
        hr_utility.trace('no future, yes current');

        close csr_current_apl;
        --
        --set date_end to null where application_id=l_current_apl_id
        --
        per_apl_upd.upd
            (p_application_id             => l_current_apl_id
            ,p_date_end                   => null
            ,p_object_version_number      => l_apl_object_version_number
            ,p_effective_date             => l_effective_date
            );

        l_date_received_OUT  := l_date_received;
        l_application_id_OUT := l_current_apl_id;
        l_apl_ovn_OUT        := l_apl_object_version_number;

      end if;
    -- -------------------------------------------------------------------
    else  --yes future
    -- -------------------------------------------------------------------
      hr_utility.trace('YES future');

      open csr_current_apl(p_person_id, l_effective_date);
      fetch csr_current_apl into l_current_apl_id, l_date_received
                                ,l_apl_object_version_number;

      if csr_current_apl%notfound then         --yes future, no current
        close csr_current_apl;
        --
        -- delete more future applications, but not the first one (merge)
        l_rowcount := 0;
        loop
          fetch csr_fut_apl into l_del_fut_apl_id, l_del_fut_apl_date_received
                                   ,l_del_fut_apl_ovn ;
          exit when csr_fut_apl%notfound;

              Update_APL_assignments(p_business_group_id, l_del_fut_apl_id,l_future_apl_id);

              per_apl_del.del
                (p_application_id        => l_del_fut_apl_id
                ,p_object_version_number => l_del_fut_apl_ovn
                );
              l_rowcount := l_rowcount + 1;
        end loop;
        close csr_fut_apl;

        if l_rowcount > 0 then
           l_appl_override_warning := TRUE;
        end if;

        -- set date_received=p_effective_date where application_id=l_future_apl_id;
        per_apl_upd.upd
            (p_application_id             => l_future_apl_id
            ,p_date_received              => l_effective_date
            ,p_date_end                   => null
            ,p_object_version_number      => l_fut_apl_ovn
            ,p_effective_date             => l_effective_date
            );

        l_date_received_OUT  := l_fut_apl_date_received;
        l_application_id_OUT := l_future_apl_id;
        l_apl_ovn_OUT        := l_fut_apl_ovn;
      -- ----------------------------------------
      else  --yes future, yes current
      -- ----------------------------------------
        hr_utility.trace('yes future, yes current');

        close csr_current_apl;
        --
        -- delete the first future apl we already fetched
        --
        Update_APL_assignments(p_business_group_id, l_future_apl_id,l_current_apl_id);
        --
        per_apl_del.del
            (p_application_id        => l_future_apl_id
            ,p_object_version_number => l_fut_apl_ovn
            );
        --
        l_appl_override_warning := TRUE;
        --
        -- delete more future applications (merge)
        --
        loop
          fetch csr_fut_apl into l_del_fut_apl_id, l_del_fut_apl_date_received
                                ,l_del_fut_apl_ovn ;

          exit when csr_fut_apl%notfound;

              Update_APL_assignments(p_business_group_id, l_del_fut_apl_id,l_current_apl_id);

              per_apl_del.del
                (p_application_id        => l_del_fut_apl_id
                ,p_object_version_number => l_del_fut_apl_ovn
                );
        --
        end loop;
        close csr_fut_apl;
        --
        -- set date_end to null where application_id=l_current_apl_id
        --
        per_apl_upd.upd
            (p_application_id             => l_current_apl_id
            ,p_date_received              => l_date_received
            ,p_date_end                   => null
            ,p_object_version_number      => l_apl_object_version_number
            ,p_effective_date             => l_effective_date
            );

        l_application_id_OUT := l_current_apl_id;
        l_date_received_OUT  := l_date_received;
        l_apl_ovn_OUT        := l_apl_object_version_number;
      end if;
      --
    end if;
    --
    -- Setting up the OUT parameters
    --
    p_application_id          := l_application_id_OUT;
    p_date_received           := l_date_received_OUT;
    p_object_version_number   := l_apl_ovn_OUT;
    p_appl_override_warning   := l_appl_override_warning;

    if g_debug then
       hr_utility.set_location(' Leaving: '||l_proc,1000);
    end if;

end Create_Application;
--
-- ------------------------------------------------------------------------- +
-- --------------------< override_future_applications >--------------------- |
-- ------------------------------------------------------------------------- +
FUNCTION override_future_applications
   (p_person_id  IN NUMBER
   ,p_effective_date IN DATE
   )
 RETURN VARCHAR2 IS
--
    l_future_apl_id    per_applications.application_id%type;
    l_current_apl_id   per_applications.application_id%type;
    l_yesterday_apl_id per_applications.application_id%type;
    l_raise_warning    VARCHAR2(10);

    cursor csr_fut_apl is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_received > p_effective_date
    order by date_received asc;

    cursor csr_current_apl is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_received < p_effective_date
    and   nvl(date_end,hr_api.g_eot) >= p_effective_date;

    cursor csr_apl_yesterday is
    select application_id
    from per_applications
    where person_id = p_person_id
    and   date_end = p_effective_date-1;



BEGIN
    l_raise_warning := 'N';
    open csr_fut_apl;
    fetch csr_fut_apl into l_future_apl_id;
    if csr_fut_apl%found then
      open csr_current_apl;
      fetch csr_current_apl into l_current_apl_id;
      if csr_current_apl%notfound then        --yes future, no current
        close csr_current_apl;
        fetch csr_fut_apl INTO l_future_apl_id;
        IF csr_fut_apl%FOUND then
          l_raise_warning := 'Y';
        end if;
      else                                     --yes future, yes current
        close csr_current_apl;
        l_raise_warning := 'Y';
      END IF;
    end if;
    close csr_fut_apl;

    RETURN l_raise_warning;

END override_future_applications;
--
-- ------------------------------------------------------------------------- +
-- ------------------------< future_apl_asg_exist >------------------------- |
-- ------------------------------------------------------------------------- +
FUNCTION future_apl_asg_exist
   (p_person_id         IN NUMBER
   ,p_effective_date    IN DATE
   ,p_application_id    IN NUMBER
   ) RETURN VARCHAR2 IS
    --
    cursor csr_future_apl_asg is
        select 'Y'
         from per_all_assignments_f paf
        where paf.person_id = p_person_id
          and paf.effective_start_date > p_effective_date
          and paf.assignment_type = 'A'
          and paf.application_id = p_application_id;
    --
    l_raise_warning varchar2(10);
    --

BEGIN
    l_raise_warning := 'N';
    open csr_future_apl_asg;
    fetch csr_future_apl_asg into l_raise_warning;
    close csr_future_apl_asg;
    l_raise_warning := nvl(l_raise_warning,'N');

    RETURN l_raise_warning;

END future_apl_asg_exist;
--
--
-- -------------------------------------------------------------------------- +
-- |--------------------< create_applicant_anytime >------------------------- |
-- -------------------------------------------------------------------------- +
-- This creates an application with default information and transforms
-- an existing person into an applicant.
--
-- To create a new person as an applicant then use the
-- hr_applicant_api.create_applicant() API
--
procedure create_applicant_anytime
  (p_effective_date                in date
  ,p_person_id                     in number
  ,p_applicant_number              in out nocopy varchar2
  ,p_per_object_version_number     in out nocopy number
  ,p_vacancy_id                    in number
  ,p_person_type_id                in number
  ,p_assignment_status_type_id     in number
  ,p_application_id                   out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy DATE
  ,p_appl_override_warning            OUT NOCOPY boolean
  ) is
  --
  -- declare local variables
  --
  l_proc                   constant varchar2(72) := g_package||'create_applicant_anytime';
  l_business_group_id         per_people_f.business_group_id%type;
  l_name_combination_warning  boolean;
  l_dob_null_warning          boolean;
  l_orig_hire_warning         boolean;
  l_organization_id           per_business_groups.organization_id%type;
  l_legislation_code          per_business_groups.legislation_code%type;
  l_person_type_id            per_people_f.person_type_id%type;
  l_application_id            per_applications.application_id%type;
  l_comment_id                per_assignments_f.comment_id%type;
  l_assignment_sequence       per_assignments_f.assignment_sequence%type;
  l_assignment_id             per_assignments_f.assignment_id%type;
  l_object_version_number     per_assignments_f.object_version_number%type;
  l_current_applicant_flag    per_people_f.current_applicant_flag%type;
  l_current_emp_or_apl_flag   per_people_f.current_emp_or_apl_flag%type;
  l_current_employee_flag     per_people_f.current_employee_flag%type;
  l_employee_number           per_people_f.employee_number%type;
  l_applicant_number          per_people_f.applicant_number%TYPE;
  l_npw_number                per_people_f.npw_number%TYPE;
  l_per_object_version_number per_people_f.object_version_number%TYPE;
  l_full_name                 per_people_f.full_name%type;
  l_system_person_type        per_person_types.system_person_type%type;
  l_effective_date            date;
  l_effective_start_date      date;
  l_effective_end_date        date;
  l_default_start_time        per_business_groups.default_start_time%type;
  l_default_end_time          per_business_groups.default_end_time%type;
  l_normal_hours              number;
  l_frequency                 per_business_groups.frequency%type;
  l_recruiter_id              per_vacancies.recruiter_id%type;
  l_grade_id                  per_vacancies.grade_id%type;
  l_position_id               per_vacancies.position_id%type;
  l_job_id                    per_vacancies.job_id%type;
  l_location_id               per_vacancies.location_id%type;
  l_people_group_id           per_vacancies.people_group_id%type;
  l_vac_organization_id       per_vacancies.organization_id%type;
  l_vac_business_group_id     per_vacancies.business_group_id%type;
  l_group_name            pay_people_groups.group_name%type;
--
--
  l_apl_object_version_number          number;
  l_apl_date_received                  DATE;
  l_asg_object_version_number          number;
  l_per_effective_start_date           date;
  l_per_effective_end_date             date;
  l_appl_override_warning              BOOLEAN;
  l_per_party_id                       per_all_people_f.party_id%TYPE;
  l_per_dob                            per_all_people_f.date_of_birth%TYPE;
  l_per_start_date                     per_all_people_f.effective_start_date%TYPE;
--
    --
    -- select and validate the person
    --
    -- now returns person details
    --
    cursor csr_chk_person_exists is
      select   ppf.business_group_id
              ,ppf.employee_number
              ,ppf.npw_number
              ,ppf.date_of_birth
              ,ppf.party_id
              ,ppf.effective_start_date
              ,ppt.system_person_type
      from     per_person_types ppt
              ,per_people_f ppf
      where   ppf.person_id = p_person_id
      and     ppt.person_type_id        = ppf.person_type_id
      and     ppt.business_group_id + 0 = ppf.business_group_id
      and     (l_effective_date
      between ppf.effective_start_date
      and     ppf.effective_end_date or ppf.effective_start_date > l_effective_date)
      order by ppf.effective_start_date ASC;
    --
    -- Get organization id for business group.
    --
    cursor csr_get_organization_id is
      select  organization_id
             ,legislation_code
             ,default_start_time
             ,default_end_time
             ,fnd_number.canonical_to_number(working_hours)
             ,frequency
              from per_business_groups
      where business_group_id = l_business_group_id;
    --
    -- Get vacancy information.
    --
    cursor csr_get_vacancy_details is
      select  recruiter_id
             ,grade_id
             ,position_id
             ,job_id
             ,location_id
             ,people_group_id
             ,organization_id   -- added org id to cursor. thayden 7/10.
             ,business_group_id  -- added business_group_id to cursor lma 7/11
       from per_vacancies
      where vacancy_id = p_vacancy_id;
    --
    CURSOR csr_lock_person(cp_person_id number, cp_termination_date date) IS
        SELECT null
          FROM per_all_people_f
         WHERE person_id = cp_person_id
           AND (effective_start_date > cp_termination_date
                OR
                cp_termination_date between effective_start_date
                                        and effective_end_date)
         for update nowait;
    --
    CURSOR csr_lock_ptu(cp_person_id number, cp_termination_date date) IS
        SELECT null
          FROM per_person_type_usages_f ptu
              ,per_person_types         ppt
         WHERE person_id = cp_person_id
           AND (effective_start_date > cp_termination_date
                OR
                cp_termination_date between effective_start_date
                                        and effective_end_date)
           AND ptu.person_type_id = ppt.person_type_id
           AND ppt.system_person_type in ('APL','EX_APL')
         for update nowait;
-- ------------------------------------------------------------------------ +
-- ------------------------<< BEGIN  >>------------------------------------ |
-- ------------------------------------------------------------------------ +
BEGIN
    --
    if g_debug then
       hr_utility.set_location('Entering:'|| l_proc, 5);
    end if;
    --
    -- Truncate p_effective_date
    --
    l_effective_date := trunc(p_effective_date);
    l_person_type_id := p_person_type_id;
    --
    hr_utility.trace('  l_effective_date = '||to_char(l_effective_date));
    --
    l_applicant_number          := p_applicant_number;
    l_per_object_version_number := p_per_object_version_number;
    --
    -- Validation Logic
    --
    --  Ensure that the mandatory parameter, p_person_id is not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'person id'
      ,p_argument_value => p_person_id);
    --
    if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    end if;
    --
    -- Check that this person (p_person_id) exists as of l_effective_date
    -- the current person type (per_people_f.person_type_id) has a
    -- corresponding system person type.
    --
    open  csr_chk_person_exists;
    fetch csr_chk_person_exists into
       l_business_group_id
      ,l_employee_number
      ,l_npw_number
      ,l_per_dob
      ,l_per_party_id
      ,l_per_start_date
      ,l_system_person_type;
    if csr_chk_person_exists%notfound then
      close csr_chk_person_exists;
      hr_utility.set_message(800, 'HR_51011_PER_NOT_EXIST_DATE');
      hr_utility.raise_error;
    end if;
    close csr_chk_person_exists;
    --
    if g_debug then
    hr_utility.set_location(l_proc, 15);
    end if;
    --
    per_per_bus.chk_person_type
    (p_person_type_id     => l_person_type_id,
     p_business_group_id  => l_business_group_id,
     p_expected_sys_type  => 'APL');
    --
    if g_debug then
      hr_utility.set_location(l_proc, 20);
    end if;
    --
    --  Get organization id
    --
    open  csr_get_organization_id;
    fetch csr_get_organization_id into
      l_organization_id
     ,l_legislation_code
     ,l_default_start_time
     ,l_default_end_time
     ,l_normal_hours
     ,l_frequency;
    if csr_get_organization_id%notfound then
      close csr_get_organization_id;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    end if;
    close csr_get_organization_id;
    --
    --  Get vacancy details.
    --
    if p_vacancy_id is not null then
        open  csr_get_vacancy_details;
        fetch csr_get_vacancy_details into
          l_recruiter_id
         ,l_grade_id
         ,l_position_id
         ,l_job_id
         ,l_location_id
         ,l_people_group_id
         ,l_vac_organization_id
         ,l_vac_business_group_id;
        if csr_get_vacancy_details%notfound then
            close csr_get_vacancy_details;
            hr_utility.set_message(801, 'HR_51001_THE_VAC_NOT_FOUND');
            hr_utility.raise_error;
        end if;
        close csr_get_vacancy_details;
        --
        if l_vac_organization_id is null then
            l_vac_organization_id := l_vac_business_group_id;
        end if;
    else
        l_vac_organization_id  := l_business_group_id;
    end if;
    --
    if g_debug then
        hr_utility.set_location(l_proc, 30);
    end if;
  --
  -- Validate applicant number
  -- Get number if one exists and parameter is NULL
  --
  hr_applicant_internal.generate_applicant_number
     (p_business_group_id  => l_business_group_id
     ,p_person_id          => p_person_id
     ,p_effective_date     => l_effective_date
     ,p_party_id           => l_per_party_id
     ,p_date_of_birth      => l_per_dob
     ,p_start_date         => l_per_start_date
     ,p_applicant_number   => l_applicant_number);

    if g_debug then
        hr_utility.set_location(l_proc, 33);
    end if;
  -- ------------------------------------------------------------------------ +
  -- ----------------------<< MAIN PROCESS >>-------------------------------- |
  -- ------------------------------------------------------------------------ +
  --
    -- Lock person records
    open csr_lock_person(p_person_id, l_effective_date);
    close csr_lock_person;
    -- Lock ptu records
    open csr_lock_ptu(p_person_id, l_effective_date);
    close csr_lock_ptu;
    --
    if g_debug then
      hr_utility.set_location(l_proc, 40);
    end if;
    --
    -- Update Person and PTU Records:
    --
    Update_PER_PTU_Records
        (p_business_group_id         => l_business_group_id
        ,p_person_id                 => p_person_id
        ,p_effective_date            => l_effective_date
        ,p_applicant_number          => l_applicant_number
        ,P_APL_person_type_id        => l_person_type_id
        ,p_per_effective_start_date  => l_per_effective_start_date
        ,p_per_effective_end_date    => l_per_effective_end_date
        ,p_per_object_version_number => l_per_object_version_number --BUG4081676
        );
    --
    Create_Application
      (p_application_id            => l_application_id
      ,p_business_group_id         => l_business_group_id
      ,p_person_id                 => p_person_id
      ,p_date_received             => l_apl_date_received
      ,p_effective_date            => l_effective_date
      ,p_object_version_number     => l_apl_object_version_number
      ,p_appl_override_warning     => l_appl_override_warning
      ,p_validate_df_flex          => false --4689836
      );
    --
    if g_debug then
      hr_utility.set_location(l_proc, 50);
    end if;
    --
    -- create an applicant assignment
    --
    hr_assignment_internal.create_apl_asg
      (p_effective_date               => l_effective_date
      ,p_legislation_code             => l_legislation_code
      ,p_business_group_id            => l_business_group_id
      ,p_person_id                    => p_person_id
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_organization_id              => l_vac_organization_id
      ,p_application_id               => l_application_id
      ,p_recruiter_id                 => l_recruiter_id
      ,p_grade_id                     => l_grade_id
      ,p_position_id                  => l_position_id
      ,p_job_id                       => l_job_id
      ,p_location_id                  => l_location_id
      ,p_people_group_id              => l_people_group_id
      ,p_vacancy_id                   => p_vacancy_id
      ,p_frequency                    => l_frequency
      ,p_manager_flag                 => 'N'
      ,p_normal_hours                 => l_normal_hours
      ,p_time_normal_finish           => l_default_end_time
      ,p_time_normal_start            => l_default_start_time
      ,p_assignment_id                => l_assignment_id
      ,p_object_version_number        => l_asg_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_comment_id                   => l_comment_id
      --
      -- START bug# 4610369 added the parameter by risgupta for not to validate
      -- DFFs when assignment created internally.
      --
      ,p_validate_df_flex             => false
      --
      -- END bug# 4610369
      --
      );

    if g_debug then
      hr_utility.set_location(l_proc, 60);
    end if;
    --
    -- add to the security list
    --
    hr_security_internal.add_to_person_list(l_effective_date,l_assignment_id);
  -- ------------------------------------------------------------------------ +
  -- ---------------------<< END MAIN PROCESS >>----------------------------- |
  -- ------------------------------------------------------------------------ +
  --
  --  Set all output arguments
  --
   p_application_id                   := l_application_id;
   p_applicant_number                 := l_applicant_number;
   p_assignment_id                    := l_assignment_id;
   p_apl_object_version_number        := l_apl_object_version_number;
   p_asg_object_version_number        := l_asg_object_version_number;
   p_assignment_sequence              := l_assignment_sequence;
   p_per_effective_start_date         := l_per_effective_start_date;
   p_per_effective_end_date           := l_per_effective_end_date;
   p_appl_override_warning            := l_appl_override_warning;
   p_per_object_version_number        := l_per_object_version_number; --BUG4081676
  --
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;

end create_applicant_anytime;
--
--
end hr_applicant_internal;

/
