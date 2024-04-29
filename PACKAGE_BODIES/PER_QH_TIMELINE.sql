--------------------------------------------------------
--  DDL for Package Body PER_QH_TIMELINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_TIMELINE" as
/* $Header: peqhtmln.pkb 120.1.12010000.2 2008/08/06 09:30:57 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) :='  per_qh_timeline.';
--
procedure get_dates
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,records                OUT NOCOPY datetab) is
--
  val_old    VARCHAR2(240);
  val_new    VARCHAR2(240);
  date_start VARCHAR2(240);
  date_end   VARCHAR2(15);
--
  l_column varchar2(240);
  l_table  varchar2(240);
  l_type   varchar2(2);
  l_primary_key_name varchar2(240);
  l_primary_key number;
--
  l_select_stmt varchar2(20000);
  TYPE DateCurTyp is REF CURSOR;
  date_cv DateCurTyp;
  l_date_rec daterec;
  i number;
  l_sub_query varchar2(20000);
  l_date_string varchar2(30);
  l_proc varchar2(72):=g_package||'get_dates';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  l_date_string:='to_date('''
  ||to_char(p_effective_date,'DDMMYYYY')||
  ''',''DDMMYYYY'')';
  --
  hr_utility.set_location(l_proc,20);
  --
  -- look for the column name.
  --
  if P_FIELD='MAINTAIN.PERSON_TYPE' then
    l_column:='PERSON_TYPE_ID';
    l_table:='PER_PERSON_TYPE_USAGES_F';
    l_type:='N';
--bug no 5169311 starts here
--    l_sub_query:= NULL;
   l_sub_query:='select USER_PERSON_TYPE from per_person_types_tl where
  language=userenv(''LANG'') and PERSON_TYPE_ID=:1';
--bug no 5169311 ends here

  ELSIF P_FIELD='MAINTAIN.BACKGROUND_CHK_STAT_MEANING' then
    l_column:='BACKGROUND_CHK_STATATUS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.BLOOD_TYPE_MEANING' then
    l_column:='BLOOD_TYPE';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''BLOOD_TYPE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.CORR_LANG_MEANING' then
    l_column:='CORRESPONDENCE_LANGUAGE';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
    'select description
    from fnd_languages_vl
    where language_code=:1';
  ELSIF P_FIELD='MAINTAIN.EXPNSE_CHK_SEND_ADDR_MEANING' then
    l_column:='EXPNSE_CHECK_SEND_TO_ADDRESS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''HOME_OFFICE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.MARITAL_STATUS_MEANING' then
    l_column:='MARITAL_STATUS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''MAR_STATUS''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.NATIONALITY_MEANING' then
    l_column:='NATIONALITY';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''NATIONALITY''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.ON_MILITARY_SERVICE_MEANING' then
    l_column:='ON_MILITARY_SERVICE';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.RESUME_EXISTS_MEANING' then
    l_column:='RESUME_EXISTS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.REGISTERED_DISABLED_FLAG' then
    l_column:='REGISTERED_DISABLED_FLAG';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';

-- Bug 3037019 Start here

    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''REGISTERED_DISABLED''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';

-- Bug 3037019 End here

  ELSIF P_FIELD='MAINTAIN.SECND_PASSPORT_EXSTS_MEANING' then
    l_column:='SECOND_PASSPORT_EXISTS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.SEX_MEANING' then
    l_column:='SEX';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''SEX''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.STUDENT_STATUS_MEANING' then
    l_column:='STUDENT_STATUS';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''STUDENT_STATUS''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.TITLE_MEANING' then
    l_column:='TITLE';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''TITLE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.WORK_SCHEDULE_MEANING' then
    l_column:='WORK_SCHEDULE';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''WORK_SCHEDULE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.CORD_BEN_NO_CVG_FLAG_MEANING' then
    l_column:='COORD_BEN_NO_CVG_FLAG';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.DPDNT_VLNTRY_SVC_FLG_MEANING' then
    l_column:='DPDNT_VLNTRY_SVCE_FLAG';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.USES_TOBACCO_MEANING' then
    l_column:='USES_TOBACCO';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.BENEFIT_GROUP' then
    l_column:='BENEFIT_GROUP_ID';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from  ben_benfts_grp
    where benfts_grp_id=:1';
  ELSIF P_FIELD in ('MAINTAIN.LAST_NAME'
                  ,'MAINTAIN.APPLICANT_NUMBER'
                  ,'MAINTAIN.BACKGROUND_DATE_CHECK'
                  ,'MAINTAIN.EMAIL_ADDRESS'
                  ,'MAINTAIN.EMPLOYEE_NUMBER'
,'MAINTAIN.NPW_NUMBER'
                  ,'MAINTAIN.FIRST_NAME'
                  ,'MAINTAIN.PER_FTE_CAPACITY'
                  ,'MAINTAIN.FULL_NAME'
                  ,'MAINTAIN.HOLD_APPLICANT_DATE_UNTIL'
                  ,'MAINTAIN.HONORS'
                  ,'MAINTAIN.INTERNAL_LOCATION'
                  ,'MAINTAIN.KNOWN_AS'
                  ,'MAINTAIN.LAST_MEDICAL_TEST_BY'
                  ,'MAINTAIN.MAILSTOP'
                  ,'MAINTAIN.MIDDLE_NAMES'
                  ,'MAINTAIN.NATIONAL_IDENTIFIER'
                  ,'MAINTAIN.OFFICE_NUMBER'
                  ,'MAINTAIN.PRE_NAME_ADJUNCT'
                  ,'MAINTAIN.PREVIOUS_LAST_NAME'
                  ,'MAINTAIN.REHIRE_RECOMMENDATION'
                  ,'MAINTAIN.RESUME_LAST_UPDATED'
                  ,'MAINTAIN.SUFFIX'
                  ,'MAINTAIN.COORD_BEN_MED_PLN_NO'
                  ,'MAINTAIN.PER_ATTRIBUTE_CATEGORY'
           /*       ,'MAINTAIN.PER_ATTRIBUTE1_V' -- Commented for fix of #3211345
                  ,'MAINTAIN.PER_ATTRIBUTE2_V'
                  ,'MAINTAIN.PER_ATTRIBUTE3_V'
                  ,'MAINTAIN.PER_ATTRIBUTE4_V'
                  ,'MAINTAIN.PER_ATTRIBUTE5_V'
                  ,'MAINTAIN.PER_ATTRIBUTE6_V'
                  ,'MAINTAIN.PER_ATTRIBUTE7_V'
                  ,'MAINTAIN.PER_ATTRIBUTE8_V'
                  ,'MAINTAIN.PER_ATTRIBUTE9_V'
                  ,'MAINTAIN.PER_ATTRIBUTE10_V'
                  ,'MAINTAIN.PER_ATTRIBUTE11_V'
                  ,'MAINTAIN.PER_ATTRIBUTE12_V'
                  ,'MAINTAIN.PER_ATTRIBUTE13_V'
                  ,'MAINTAIN.PER_ATTRIBUTE14_V'
                  ,'MAINTAIN.PER_ATTRIBUTE15_V'
                  ,'MAINTAIN.PER_ATTRIBUTE16_V'
                  ,'MAINTAIN.PER_ATTRIBUTE17_V'
                  ,'MAINTAIN.PER_ATTRIBUTE18_V'
                  ,'MAINTAIN.PER_ATTRIBUTE19_V'
                  ,'MAINTAIN.PER_ATTRIBUTE20_V'
                  ,'MAINTAIN.PER_ATTRIBUTE21_V'
                  ,'MAINTAIN.PER_ATTRIBUTE22_V'
                  ,'MAINTAIN.PER_ATTRIBUTE23_V'
                  ,'MAINTAIN.PER_ATTRIBUTE24_V'
                  ,'MAINTAIN.PER_ATTRIBUTE25_V'
                  ,'MAINTAIN.PER_ATTRIBUTE26_V'
                  ,'MAINTAIN.PER_ATTRIBUTE27_V'
                  ,'MAINTAIN.PER_ATTRIBUTE28_V'
                  ,'MAINTAIN.PER_ATTRIBUTE29_V'
                  ,'MAINTAIN.PER_ATTRIBUTE30_V'*/
                  ,'MAINTAIN.PER_INFORMATION_CATEGORY'
                 /* ,'MAINTAIN.PER_INFORMATION1_V' -- Commented for fix of #3211345
                  ,'MAINTAIN.PER_INFORMATION2_V'
                  ,'MAINTAIN.PER_INFORMATION3_V'
                  ,'MAINTAIN.PER_INFORMATION4_V'
                  ,'MAINTAIN.PER_INFORMATION5_V'
                  ,'MAINTAIN.PER_INFORMATION6_V'
                  ,'MAINTAIN.PER_INFORMATION7_V'
                  ,'MAINTAIN.PER_INFORMATION8_V'
                  ,'MAINTAIN.PER_INFORMATION9_V'
                  ,'MAINTAIN.PER_INFORMATION10_V'
                  ,'MAINTAIN.PER_INFORMATION11_V'
                  ,'MAINTAIN.PER_INFORMATION12_V'
                  ,'MAINTAIN.PER_INFORMATION13_V'
                  ,'MAINTAIN.PER_INFORMATION14_V'
                  ,'MAINTAIN.PER_INFORMATION15_V'
                  ,'MAINTAIN.PER_INFORMATION16_V'
                  ,'MAINTAIN.PER_INFORMATION17_V'
                  ,'MAINTAIN.PER_INFORMATION18_V'
                  ,'MAINTAIN.PER_INFORMATION19_V'
                  ,'MAINTAIN.PER_INFORMATION20_V'
                  ,'MAINTAIN.PER_INFORMATION21_V'
                  ,'MAINTAIN.PER_INFORMATION22_V'
                  ,'MAINTAIN.PER_INFORMATION23_V'
                  ,'MAINTAIN.PER_INFORMATION24_V'
                  ,'MAINTAIN.PER_INFORMATION25_V'
                  ,'MAINTAIN.PER_INFORMATION26_V'
                  ,'MAINTAIN.PER_INFORMATION27_V'
                  ,'MAINTAIN.PER_INFORMATION28_V'
                  ,'MAINTAIN.PER_INFORMATION29_V'
                  ,'MAINTAIN.PER_INFORMATION30_V'
                  ,'MAINTAIN.PER_INFORMATION30_M'*/
                 ) then
    l_column:=substrb(p_field,10);
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=null;
-- ADDED FOR FIX OF #3211345 START
  elsif p_field in ('MAINTAIN.PER_ATTRIBUTE1_V'
                  ,'MAINTAIN.PER_ATTRIBUTE2_V'
                  ,'MAINTAIN.PER_ATTRIBUTE3_V'
                  ,'MAINTAIN.PER_ATTRIBUTE4_V'
                  ,'MAINTAIN.PER_ATTRIBUTE5_V'
                  ,'MAINTAIN.PER_ATTRIBUTE6_V'
                  ,'MAINTAIN.PER_ATTRIBUTE7_V'
                  ,'MAINTAIN.PER_ATTRIBUTE8_V'
                  ,'MAINTAIN.PER_ATTRIBUTE9_V'
                  ,'MAINTAIN.PER_ATTRIBUTE10_V'
                  ,'MAINTAIN.PER_ATTRIBUTE11_V'
                  ,'MAINTAIN.PER_ATTRIBUTE12_V'
                  ,'MAINTAIN.PER_ATTRIBUTE13_V'
                  ,'MAINTAIN.PER_ATTRIBUTE14_V'
                  ,'MAINTAIN.PER_ATTRIBUTE15_V'
                  ,'MAINTAIN.PER_ATTRIBUTE16_V'
                  ,'MAINTAIN.PER_ATTRIBUTE17_V'
                  ,'MAINTAIN.PER_ATTRIBUTE18_V'
                  ,'MAINTAIN.PER_ATTRIBUTE19_V'
                  ,'MAINTAIN.PER_ATTRIBUTE20_V'
                  ,'MAINTAIN.PER_ATTRIBUTE21_V'
                  ,'MAINTAIN.PER_ATTRIBUTE22_V'
                  ,'MAINTAIN.PER_ATTRIBUTE23_V'
                  ,'MAINTAIN.PER_ATTRIBUTE24_V'
                  ,'MAINTAIN.PER_ATTRIBUTE25_V'
                  ,'MAINTAIN.PER_ATTRIBUTE26_V'
                  ,'MAINTAIN.PER_ATTRIBUTE27_V'
                  ,'MAINTAIN.PER_ATTRIBUTE28_V'
                  ,'MAINTAIN.PER_ATTRIBUTE29_V'
                  ,'MAINTAIN.PER_ATTRIBUTE30_V') then
    l_column:=substrb(p_field,14,LENGTH(p_field)-15);
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=null;
  elsif p_field in ('MAINTAIN.PER_INFORMATION1_V'
                  ,'MAINTAIN.PER_INFORMATION2_V'
                  ,'MAINTAIN.PER_INFORMATION3_V'
                  ,'MAINTAIN.PER_INFORMATION4_V'
                  ,'MAINTAIN.PER_INFORMATION5_V'
                  ,'MAINTAIN.PER_INFORMATION6_V'
                  ,'MAINTAIN.PER_INFORMATION7_V'
                  ,'MAINTAIN.PER_INFORMATION8_V'
                  ,'MAINTAIN.PER_INFORMATION9_V'
                  ,'MAINTAIN.PER_INFORMATION10_V'
                  ,'MAINTAIN.PER_INFORMATION11_V'
                  ,'MAINTAIN.PER_INFORMATION12_V'
                  ,'MAINTAIN.PER_INFORMATION13_V'
                  ,'MAINTAIN.PER_INFORMATION14_V'
                  ,'MAINTAIN.PER_INFORMATION15_V'
                  ,'MAINTAIN.PER_INFORMATION16_V'
                  ,'MAINTAIN.PER_INFORMATION17_V'
                  ,'MAINTAIN.PER_INFORMATION18_V'
                  ,'MAINTAIN.PER_INFORMATION19_V'
                  ,'MAINTAIN.PER_INFORMATION20_V'
                  ,'MAINTAIN.PER_INFORMATION21_V'
                  ,'MAINTAIN.PER_INFORMATION22_V'
                  ,'MAINTAIN.PER_INFORMATION23_V'
                  ,'MAINTAIN.PER_INFORMATION24_V'
                  ,'MAINTAIN.PER_INFORMATION25_V'
                  ,'MAINTAIN.PER_INFORMATION26_V'
                  ,'MAINTAIN.PER_INFORMATION27_V'
                  ,'MAINTAIN.PER_INFORMATION28_V'
                  ,'MAINTAIN.PER_INFORMATION29_V'
                  ,'MAINTAIN.PER_INFORMATION30_V'
                  ,'MAINTAIN.PER_INFORMATION30_M') then
    l_column:=substrb(p_field,10,LENGTH(p_field)-11);
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=null;
-- ADDED FOR FIX OF #3211345 END
  elsif p_field in ('MAINTAIN.START_DATE'
                  ,'MAINTAIN.DATE_EMPLOYEE_DATA_VERIFIED'
                  ,'MAINTAIN.DATE_OF_BIRTH'
                  ,'MAINTAIN.LAST_MEDICAL_TEST_DATE'
                  ,'MAINTAIN.DPDNT_ADOPTION_DATE'
                  ,'MAINTAIN.RECEIPT_OF_DEATH_CERT_DATE'
                  ,'MAINTAIN.DATE_OF_DEATH'
                  ,'MAINTAIN.ORIGINAL_DATE_OF_HIRE') then
    l_column:=substrb(p_field,10);
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='D';
    l_sub_query:=null;
  ELSIF P_FIELD='MAINTAIN.RECRUITER' then
    l_column:='RECRUITER_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select full_name
    from per_all_people_f
    where person_id=:1
    and to_date('''
    ||to_char(p_effective_date,'DDMMYYYY')||
    ''',''DDMMYYYY'') between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.GRADE' then
    l_column:='GRADE_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from per_grades_vl
    where grade_id=:1';
  ELSIF P_FIELD='MAINTAIN.POSITION' then
    l_column:='POSITION_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from hr_all_positions_f_vl
    where position_id=:1
    and '||l_date_string||' between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.JOB' then
    l_column:='JOB_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from per_jobs_vl
    where job_id=:1';
  ELSIF P_FIELD='MAINTAIN.ASSIGNMENT_STATUS_TYPE' then
    l_column:='ASSIGNMENT_STATUS_TYPE_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'SELECT nvl(atl.user_status,stl.user_status)
    FROM
    per_ass_status_type_amends_tl atl,
    per_ass_status_type_amends a,
    per_assignment_status_types_tl stl,
    per_assignment_status_types s
    WHERE
    s.assignment_status_type_id=:1 and
    a.assignment_status_type_id (+)=s.assignment_status_type_id and
    a.business_group_id (+) +0='||p_business_group_id||' and
    nvl(a.active_flag, s.active_flag)=''Y'' and
    a.ass_status_type_amend_id=atl.ass_status_type_amend_id (+) and
    decode(atl.language,null,''1'',atl.language)
    =decode(atl.language,null,''1'',userenv(''LANG'')) and
    s.assignment_status_type_id=stl.assignment_status_type_id and
    stl.language=userenv(''LANG'')';
  ELSIF P_FIELD='MAINTAIN.PAYROLL' then
    l_column:='PAYROLL_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select payroll_name
    from pay_all_payrolls_f
    where payroll_id=:1
    and '||l_date_string||' between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.LOCATION' then
    l_column:='LOCATION_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_type:='N';
    l_sub_query:=
    'select location_code
    from hr_locations
    where location_id=:1';
  ELSIF P_FIELD='MAINTAIN.PERSON_REFERRED_BY' then
    l_column:='PERSON_REFERRED_BY_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select full_name
    from per_all_people_f
    where person_id=:1
    and '||l_date_string||' between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.SUPERVISOR' then
    l_column:='SUPERVISOR_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select full_name
    from per_all_people_f
    where person_id=:1
    and '||l_date_string||' between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.SUPERVISOR_ASSIGNMENT_NUMBER' then
    l_column:='SUPERVISOR_ASSIGNMENT_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select assignment_number
    from per_all_assignments_f
    where person_id=:1
    and '||l_date_string||' between effective_start_date and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.RECRUITMENT_ACTIVITY' then
    l_column:='RECRUITMENT_ACTIVITY_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from per_recruitment_activities
    where recruitment_activity_id=:1';
  ELSIF P_FIELD='MAINTAIN.SOURCE_ORGANIZATION' then
    l_column:='SOURCE_ORGANIZATION_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from hr_organization_units
    where organization_id=:1';
  ELSIF P_FIELD='MAINTAIN.ORGANIZATION' then
    l_column:='ORGANIZATION_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from hr_organization_units
    where organization_id=:1';
  ELSIF P_FIELD='MAINTAIN.VACANCY' then
    l_column:='VACANCY_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from per_vacancies
    where vacancy_id=:1';
  ELSIF P_FIELD='MAINTAIN.SALARY_BASIS' then
    l_column:='PAY_BASIS_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from per_pay_bases
    where pay_basis_id=:1';
  ELSIF P_FIELD='MAINTAIN.ASG_PRIMARY_FLAG' then
    l_column:='PRIMARY_FLAG';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
--Bug 3063591 Start Here
  ELSIF P_FIELD='MAINTAIN.WORK_AT_HOME' then
    l_column:='WORK_AT_HOME';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''YES_NO''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
--Bug 3063591 End Here
  ELSIF P_FIELD='MAINTAIN.EMPLOYMENT_CATEGORY_MEANING' then
    l_column:='EMPLOYMENT_CATEGORY';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''EMP_CAT''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.EMPLOYEE_CATEGORY_MEANING' then
    l_column:='EMPLOYEE_CATEGORY';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''EMPLOYEE_CATG''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.FREQUENCY_MEANING' then
    l_column:='FREQUENCY';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''FREQUENCY''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.PROBATION_UNIT_MEANING' then
    l_column:='PROBATION_UNIT';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''QUALIFYING_UNITS''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.BARGAINING_UNIT_CODE_MEANING' then
    l_column:='BARGAINING_UNIT_CODE';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''BARGAINING_UNIT_CODE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.HOURLY_SALARIED_MEANING' then
    l_column:='HOURLY_SALARIED_CODE';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''HOURLY_SALARIED_CODE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.SPECIAL_CEILING_STEP' then
    l_column:='SPECIAL_CEILING_STEP_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
   'select psp.spinal_point
   from per_spinal_points psp
   , per_spinal_point_steps_f psps
   where psp.spinal_point_id=psps.spinal_point_id
   and psps.step_id=:1
   and '||l_date_string||' between psps.effective_start_date
      and psps.effective_end_date';
  ELSIF P_FIELD='MAINTAIN.CHANGE_REASON_MEANING' then
    l_column:='CHANGE_REASON';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''APL_ASSIGN_REASON''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.PERF_REV_PERIOD_FREQ_MEANING' then
    l_column:='PERF_REV_PERIOD_FREQUENCY';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''FREQUENCY''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.SAL_REV_PERIOD_FREQ_MEANING' then
    l_column:='SAL_REV_PERIOD_FREQUENCY';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''FREQUENCY''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.SOURCE_TYPE_MEANING' then
    l_column:='SOURCE_TYPE';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=
  'select meaning from hr_lookups
   where lookup_type=''REC_TYPE''
   and enabled_flag=''Y''
   and '||l_date_string||' between nvl(start_date_active,'||l_date_string||')
   and nvl(end_date_active,'||l_date_string||') and lookup_code=:1';
  ELSIF P_FIELD='MAINTAIN.CONTRACT' then
    l_column:='CONTRACT_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
  'select reference
   from per_contracts_f
   where contract_id=:1
   and '||l_date_string||' between effective_start_date
   and effective_end_date';
  ELSIF P_FIELD='MAINTAIN.COLLECTIVE_AGREEMENT' then
    l_column:='COLLECTIVE_AGREEMENT_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
  'select name
   from per_collective_agreements
   where collective_agreement_id=:1';
  ELSIF P_FIELD='MAINTAIN.CAGR_ID_FLEX_NAME' then
    l_column:='CAGR_ID_FLEX_NUM';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
  'select id_flex_structure_name
   from fnd_id_flex_structures_vl
   where id_flex_code=''CAGR''
   and   application_id=800
   and   id_flex_num=:1';
  ELSIF P_FIELD='MAINTAIN.CAGR_GRADE' then
    l_column:='CAGR_GRADE_DEF_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
  ELSIF P_FIELD='MAINTAIN.ESTABLISHMENT' then
    l_column:='ESTABLISHMENT_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select name
    from hr_organization_units
    where organization_id=:1';
  ELSIF P_FIELD='MAINTAIN.VENDOR_NAME' then
    l_column:='VENDOR_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select vendor_name
     from po_vendors
     where vendor_id=:1';
  ELSIF P_FIELD='MAINTAIN.VENDOR_SITE_CODE' then
    l_column:='VENDOR_SITE_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select vendor_site_code
     from po_vendor_sites
     where vendor_site_id=:1';
  ELSIF P_FIELD='MAINTAIN.PO_HEADER_NUM' then
    l_column:='PO_HEADER_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select segment1
     from po_headers_all
     where po_header_id=:1';
  ELSIF P_FIELD='MAINTAIN.PO_LINE_NUM' then
    l_column:='PO_LINE_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select line_num
     from po_lines_all
     where po_line_id=:1';
  ELSIF P_FIELD in('MAINTAIN.NORMAL_HOURS'
                  ,'MAINTAIN.PROBATION_PERIOD'
                  ,'MAINTAIN.TIME_NORMAL_FINISH'
                  ,'MAINTAIN.TIME_NORMAL_START'
                  ,'MAINTAIN.PERF_REVIEW_PERIOD'
                  ,'MAINTAIN.SAL_REVIEW_PERIOD'
            ,'MAINTAIN.NOTICE_PERIOD') then
    l_column:=substrb(p_field,10);
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=null;

  ELSIF P_FIELD in('MAINTAIN.PROJECTED_ASSIGNMENT_END') then
    l_column:=substrb(p_field,10);
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='D';
    l_sub_query:=null;

  ELSIF P_FIELD in('MAINTAIN.PGP_SEGMENT1_V'
                  ,'MAINTAIN.PGP_SEGMENT2_V'
                  ,'MAINTAIN.PGP_SEGMENT3_V'
                  ,'MAINTAIN.PGP_SEGMENT4_V'
                  ,'MAINTAIN.PGP_SEGMENT5_V'
                  ,'MAINTAIN.PGP_SEGMENT6_V'
                  ,'MAINTAIN.PGP_SEGMENT7_V'
                  ,'MAINTAIN.PGP_SEGMENT8_V'
                  ,'MAINTAIN.PGP_SEGMENT9_V'
                  ,'MAINTAIN.PGP_SEGMENT10_V'
                  ,'MAINTAIN.PGP_SEGMENT11_V'
                  ,'MAINTAIN.PGP_SEGMENT12_V'
                  ,'MAINTAIN.PGP_SEGMENT13_V'
                  ,'MAINTAIN.PGP_SEGMENT14_V'
                  ,'MAINTAIN.PGP_SEGMENT15_V'
                  ,'MAINTAIN.PGP_SEGMENT16_V'
                  ,'MAINTAIN.PGP_SEGMENT17_V'
                  ,'MAINTAIN.PGP_SEGMENT18_V'
                  ,'MAINTAIN.PGP_SEGMENT19_V'
                  ,'MAINTAIN.PGP_SEGMENT20_V'
                  ,'MAINTAIN.PGP_SEGMENT21_V'
                  ,'MAINTAIN.PGP_SEGMENT22_V'
                  ,'MAINTAIN.PGP_SEGMENT23_V'
                  ,'MAINTAIN.PGP_SEGMENT24_V'
                  ,'MAINTAIN.PGP_SEGMENT25_V'
                  ,'MAINTAIN.PGP_SEGMENT26_V'
                  ,'MAINTAIN.PGP_SEGMENT27_V'
                  ,'MAINTAIN.PGP_SEGMENT28_V'
                  ,'MAINTAIN.PGP_SEGMENT29_V'
                  ,'MAINTAIN.PGP_SEGMENT30_V') then
    l_column:='PEOPLE_GROUP_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select group_name
    from pay_people_groups
    where people_group_id=:1';

  ELSIF P_FIELD in('MAINTAIN.SCL_SEGMENT1_V'
                  ,'MAINTAIN.SCL_SEGMENT2_V'
                  ,'MAINTAIN.SCL_SEGMENT3_V'
                  ,'MAINTAIN.SCL_SEGMENT4_V'
                  ,'MAINTAIN.SCL_SEGMENT5_V'
                  ,'MAINTAIN.SCL_SEGMENT6_V'
                  ,'MAINTAIN.SCL_SEGMENT7_V'
                  ,'MAINTAIN.SCL_SEGMENT8_V'
                  ,'MAINTAIN.SCL_SEGMENT9_V'
                  ,'MAINTAIN.SCL_SEGMENT10_V'
                  ,'MAINTAIN.SCL_SEGMENT11_V'
                  ,'MAINTAIN.SCL_SEGMENT12_V'
                  ,'MAINTAIN.SCL_SEGMENT13_V'
                  ,'MAINTAIN.SCL_SEGMENT14_V'
                  ,'MAINTAIN.SCL_SEGMENT15_V'
                  ,'MAINTAIN.SCL_SEGMENT16_V'
                  ,'MAINTAIN.SCL_SEGMENT17_V'
                  ,'MAINTAIN.SCL_SEGMENT18_V'
                  ,'MAINTAIN.SCL_SEGMENT19_V'
                  ,'MAINTAIN.SCL_SEGMENT20_V'
                  ,'MAINTAIN.SCL_SEGMENT21_V'
                  ,'MAINTAIN.SCL_SEGMENT22_V'
                  ,'MAINTAIN.SCL_SEGMENT23_V'
                  ,'MAINTAIN.SCL_SEGMENT24_V'
                  ,'MAINTAIN.SCL_SEGMENT25_V'
                  ,'MAINTAIN.SCL_SEGMENT26_V'
                  ,'MAINTAIN.SCL_SEGMENT27_V'
                  ,'MAINTAIN.SCL_SEGMENT28_V'
                  ,'MAINTAIN.SCL_SEGMENT29_V'
                  ,'MAINTAIN.SCL_SEGMENT30_V') then
    l_column:='SOFT_CODING_KEYFLEX_ID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='N';
    l_sub_query:=
    'select concatenated_segments
    from hr_soft_coding_keyflex
    where soft_coding_keyflex_id=:1';

  ELSIF P_FIELD in ('MAINTAIN.LABOUR_UNION_MEMBER_FLAG'
                  ,'MAINTAIN.INTERNAL_ADDRESS_LINE'
                  ,'MAINTAIN.MANAGER_FLAG'
            ,'MAINTAIN.BILLING_TITLE'
            ,'MAINTAIN.PROJECT_TITLE'
            ,'MAINTAIN.VENDOR_EMPLOYEE_NUMBER'
            ,'MAINTAIN.VENDOR_ASSIGNMENT_NUMBER'
                  ,'MAINTAIN.ASS_ATTRIBUTE_CATEGORY'
                  ,'MAINTAIN.ASS_ATTRIBUTE1_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE2_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE3_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE4_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE5_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE6_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE7_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE8_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE9_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE10_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE11_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE12_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE13_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE14_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE15_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE16_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE17_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE18_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE19_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE20_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE21_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE22_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE23_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE24_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE25_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE26_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE27_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE28_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE29_V'
                  ,'MAINTAIN.ASS_ATTRIBUTE30_V') then
   -- l_column:=substrb(p_field,10);-- fix for bug6846610
     l_column:=substrb(p_field,10,LENGTH(p_field)-11);  -- fix for bug6846610
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=null;

--Bug 3063591 Start Here
  ELSIF P_FIELD='MAINTAIN.WORK_AT_HOME' then
    l_column:='WORK_AT_HOME';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=null;
--Bug 3063591 End Here

  ELSIF P_FIELD='MAINTAIN.DATE_PROBATION_END' then
    l_column:=substrb(p_field,10);
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='D';
    l_sub_query:=null;

  ELSIF P_FIELD='PALL' then
    l_column:='ROWID';
    l_table:='PER_ALL_PEOPLE_F';
    l_type:='V';
    l_sub_query:=null;
  ELSIF P_FIELD='AALL' then
    l_column:='ROWID';
    l_table:='PER_ALL_ASSIGNMENTS_F';
    l_type:='V';
    l_sub_query:=null;
  END IF;
  --
  hr_utility.set_location(l_proc,100);
  --
  if(l_type='V') then
    l_select_stmt:='select '||l_column;
  elsif(l_type='N') then
    l_select_stmt:='select to_char('||l_column||')';
  elsif(l_type='D') then
    l_select_stmt:='select fnd_date.date_to_display_date('||l_column||')';
  end if;
  --
  hr_utility.set_location(l_proc,110);
  --
  if ((l_table='PER_ALL_PEOPLE_F') or (l_table='PER_PERSON_TYPE_USAGES_F')) then
    l_primary_key_name:='PERSON_ID';
    l_primary_key:=NVL(p_person_id,hr_api.g_number);
  else
    l_primary_key_name:='ASSIGNMENT_ID';
    l_primary_key:=NVL(p_assignment_id,hr_api.g_number);
  end if;

  l_select_stmt:=l_select_stmt||'
  ,to_char(effective_start_date,''J'')
  ,to_char(effective_end_date,''J'')
  from '||l_table||'
  where '||l_primary_key_name||' = '||l_primary_key;
  --
  -- get the dates to look at
  if( p_security_mode='FUTURE') then
    l_select_stmt:=l_select_stmt||'
    and effective_end_date>=
    to_date('''||to_char(p_datetrack_date,'YYYY/MM/DD')||''',''YYYY/MM/DD'')';
  elsif(p_security_mode='PAST') then
    l_select_stmt:=l_select_stmt||'
    and effective_start_date<=
    to_date('''||to_char(p_datetrack_date,'YYYY/MM/DD')||''',''YYYY/MM/DD'')';
  elsif(p_security_mode='PRESENT') then
    l_select_stmt:=l_select_stmt||'
    and to_date('''||to_char(p_datetrack_date,'YYYY/MM/DD')||''',''YYYY/MM/DD'')
    between effective_start_date and effective_end_date';
  end if;
  --
  l_select_stmt:=l_select_stmt||' order by effective_start_date';
  --
  hr_utility.set_location(l_proc,120);
  --
  i:=1;
  OPEN date_cv FOR l_select_stmt;
  FETCH date_cv into l_date_rec;
  if date_cv%FOUND then
    --
    hr_utility.set_location(l_proc,130);
    --
    date_start:=l_date_rec.start_date;
    date_end:=l_date_rec.end_date;
    val_old:=l_date_rec.value;
    LOOP
      FETCH date_cv into l_date_rec;
      EXIT when date_cv%NOTFOUND;
      val_new:=l_date_rec.value;
      --
      hr_utility.set_location(l_proc,140);
      --
      if( nvl(val_new,hr_api.g_varchar2)<>nvl(val_old,hr_api.g_varchar2) ) then
        --
        hr_utility.set_location(l_proc,150);
        --
        records(i).start_date:=date_start;
        records(i).end_date:=date_end;
        if l_sub_query is not null and val_old is not null then
          EXECUTE IMMEDIATE l_sub_query
          into records(i).value
          using val_old;
        else
          records(i).value:=val_old;
        end if;
        i:=i+1;
        date_start:=l_date_rec.start_date;
      end if;
      date_end:=l_date_rec.end_date;
      val_old:=val_new;
    END LOOP;
    --
    hr_utility.set_location(l_proc,160);
    --
    records(i).start_date:=date_start;
    records(i).end_date:=date_end;
    if l_sub_query is not null and val_old is not null then
      EXECUTE IMMEDIATE l_sub_query
      into records(i).value
      using val_old;
    else
      records(i).value:=val_old;
    end if;
  end if;
  CLOSE date_cv;
  --
  hr_utility.set_location('Leaving '||l_proc,200);
  --
end get_dates;

procedure get_first_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE) is

l_records datetab;
l_new_date date;
i number;
--
l_proc varchar2(72):=g_package||'get_first_date';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  get_dates(p_field             => p_field
           ,p_security_mode     => ''
           ,p_effective_date    => p_effective_date
           ,p_datetrack_date    => p_datetrack_date
           ,p_person_id         => p_person_id
           ,p_assignment_id     => p_assignment_id
           ,p_business_group_id => p_business_group_id
           ,records             => l_records);
  --
  hr_utility.set_location(l_proc,20);
  --
  if p_security_mode='FUTURE' then
    if to_date(l_records(1).start_date,'J')>p_datetrack_date then
      l_new_date:=to_date(l_records(1).start_date,'J');
    else
      l_new_date:=p_datetrack_date;
    end if;
  elsif p_security_mode='PRESENT' then
    l_new_date:=p_effective_date;
  else
    l_new_date:=to_date(l_records(1).start_date,'J');
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  p_new_date:=l_new_date;
  --
  hr_utility.set_location('Leaving '||l_proc,40);
  --
end get_first_date;

procedure get_previous_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE) is

l_records datetab;
l_new_date date;
i number;
--
l_proc varchar2(72):=g_package||'get_previous_date';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  get_dates(p_field             => p_field
           ,p_security_mode     => ''
           ,p_effective_date    => p_effective_date
           ,p_datetrack_date    => p_datetrack_date
           ,p_person_id         => p_person_id
           ,p_assignment_id     => p_assignment_id
           ,p_business_group_id => p_business_group_id
           ,records             => l_records);
  --
  hr_utility.set_location(l_proc,20);
  --
  if p_security_mode='PRESENT' then
    l_new_date:=p_effective_date;
  else
    i:=l_records.COUNT;
    loop
      l_new_date:= to_date(l_records(i).start_date,'J');
      exit when l_new_date<p_effective_date
      or i=1;
      i:=i-1;
    end loop;
    if p_security_mode='FUTURE' and l_new_date<p_datetrack_date then
      l_new_date:=p_datetrack_date;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  p_new_date:=l_new_date;
  --
  hr_utility.set_location('Leaving '||l_proc,40);
  --
end get_previous_date;

procedure get_next_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE) is

l_records datetab;
l_new_date date;
i number;
--
l_proc varchar2(72):=g_package||'get_next_date';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  get_dates(p_field             => p_field
           ,p_security_mode     => ''
           ,p_effective_date    => p_effective_date
           ,p_datetrack_date    => p_datetrack_date
           ,p_person_id         => p_person_id
           ,p_assignment_id     => p_assignment_id
           ,p_business_group_id => p_business_group_id
           ,records             => l_records);
  --
  hr_utility.set_location(l_proc,20);
  --
  if p_security_mode='PRESENT' then
    l_new_date:=p_effective_date;
  else
    i:=1;
    loop
      l_new_date:= to_date(l_records(i).start_date,'J');
      exit when l_new_date>p_effective_date
      or i=l_records.COUNT;
      i:=i+1;
    end loop;
    if p_security_mode='PAST' and l_new_date>p_datetrack_date then
      l_new_date:=p_datetrack_date;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  if l_new_date>p_effective_date then
    p_new_date:=l_new_date;
  else
    p_new_date:=p_effective_date;
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,40);
  --
end get_next_date;

procedure get_last_date
(p_field             IN     VARCHAR2
,p_security_mode     IN     VARCHAR2
,p_effective_date    IN     DATE
,p_datetrack_date    IN     DATE
,p_person_id         IN     NUMBER
,p_assignment_id     IN     NUMBER
,p_business_group_id IN     NUMBER
,p_new_date          OUT NOCOPY DATE) is

l_records datetab;
l_new_date date;
i number;
--
l_proc varchar2(72):=g_package||'get_last_date';
--
begin
  --
  hr_utility.set_location('Entering: '||l_proc,10);
  --
  get_dates(p_field             => p_field
           ,p_security_mode     => ''
           ,p_effective_date    => p_effective_date
           ,p_datetrack_date    => p_datetrack_date
           ,p_person_id         => p_person_id
           ,p_assignment_id     => p_assignment_id
           ,p_business_group_id => p_business_group_id
           ,records             => l_records);
  --
  hr_utility.set_location(l_proc,20);
  --
  if p_security_mode='PRESENT' then
    l_new_date:=p_effective_date;
  else
    l_new_date:=to_date(l_records(l_records.COUNT).start_date,'J');
    if p_security_mode='PAST' and l_new_date>p_datetrack_date then
      l_new_date:=p_datetrack_date;
    end if;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  if l_new_date>p_effective_date then
    p_new_date:=l_new_date;
  else
    p_new_date:=p_effective_date;
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,40);
  --
end get_last_date;


end per_qh_timeline;

/
