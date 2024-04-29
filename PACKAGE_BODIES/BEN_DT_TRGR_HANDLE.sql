--------------------------------------------------------
--  DDL for Package Body BEN_DT_TRGR_HANDLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DT_TRGR_HANDLE" as
/*$Header: bendttrg.pkb 120.2 2005/06/17 03:33:05 swjain noship $*/
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_dt_trgr_handle.';
--
g_debug boolean := hr_utility.debug_enabled;
--
--
procedure person(p_rowid in VARCHAR2
  ,p_business_group_id in NUMBER
  ,p_person_id in NUMBER
  ,p_effective_start_date in DATE
  ,p_effective_end_date in DATE
  ,p_date_of_birth in DATE
  ,p_date_of_death in DATE
  ,p_marital_status in VARCHAR2
  ,p_on_military_service in VARCHAR2
  ,p_registered_disabled_flag in VARCHAR2
  ,p_sex in VARCHAR2
  ,p_student_status in VARCHAR2
  ,p_coord_ben_med_pln_no in VARCHAR2
  ,p_coord_ben_no_cvg_flag in VARCHAR2
  ,p_uses_tobacco_flag in VARCHAR2
  ,p_benefit_group_id in NUMBER
  ,p_per_information10 in VARCHAR2
  ,p_dpdnt_vlntry_svce_flag in VARCHAR2
  ,p_receipt_of_death_cert_date in DATE
  ,p_attribute1  in VARCHAR2
  ,p_attribute2  in VARCHAR2
  ,p_attribute3  in VARCHAR2
  ,p_attribute4  in VARCHAR2
  ,p_attribute5  in VARCHAR2
  ,p_attribute6  in VARCHAR2
  ,p_attribute7  in VARCHAR2
  ,p_attribute8  in VARCHAR2
  ,p_attribute9  in VARCHAR2
  ,p_attribute10 in VARCHAR2
  ,p_attribute11 in VARCHAR2
  ,p_attribute12 in VARCHAR2
  ,p_attribute13 in VARCHAR2
  ,p_attribute14 in VARCHAR2
  ,p_attribute15 in VARCHAR2
  ,p_attribute16 in VARCHAR2
  ,p_attribute17 in VARCHAR2
  ,p_attribute18 in VARCHAR2
  ,p_attribute19 in VARCHAR2
  ,p_attribute20 in VARCHAR2
  ,p_attribute21 in VARCHAR2
  ,p_attribute22 in VARCHAR2
  ,p_attribute23 in VARCHAR2
  ,p_attribute24 in VARCHAR2
  ,p_attribute25 in VARCHAR2
  ,p_attribute26 in VARCHAR2
  ,p_attribute27 in VARCHAR2
  ,p_attribute28 in VARCHAR2
  ,p_attribute29 in VARCHAR2
  ,p_attribute30 in VARCHAR2
  )
is
  --
  l_proc        varchar2(72):=g_package||'person';
  --

cursor get_old_ppf(p_rowid in varchar2)
is
  select PERSON_ID
         ,BUSINESS_GROUP_ID
         ,EFFECTIVE_START_DATE
         ,EFFECTIVE_END_DATE
         ,DATE_OF_BIRTH
         ,DATE_OF_DEATH
         ,ON_MILITARY_SERVICE
         ,MARITAL_STATUS
         ,REGISTERED_DISABLED_FLAG
         ,SEX
         ,STUDENT_STATUS
         ,BENEFIT_GROUP_ID
         ,COORD_BEN_NO_CVG_FLAG
         ,USES_TOBACCO_FLAG
         ,COORD_BEN_MED_PLN_NO
         ,PER_INFORMATION10
         ,DPDNT_VLNTRY_SVCE_FLAG
         ,RECEIPT_OF_DEATH_CERT_DATE
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE20
         ,ATTRIBUTE21
         ,ATTRIBUTE22
         ,ATTRIBUTE23
         ,ATTRIBUTE24
         ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
         ,null
  from per_all_people_f

  where rowid = p_rowid;

  --

  l_old_rec ben_ppf_ler.g_ppf_ler_rec;

  l_new_rec ben_ppf_ler.g_ppf_ler_rec;

  --

  l_benasg_id      number;
  l_benasg_ovn     number;
  l_perhasmultptus boolean;
  --
begin
--
-- Bug : 3320133

benutils.set_data_migrator_mode;
--
-- Bug : 3320133
--
g_debug := hr_utility.debug_enabled;
if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering: '|| l_proc, 10);
    hr_utility.set_location('p_mar_stat: '||p_marital_status||' '||l_proc, 10);
    hr_utility.set_location('p_per_esd: '||p_effective_start_date||' '||l_proc, 10);
    hr_utility.set_location('rowid: '||p_rowid||' '||l_proc, 10);
  end if;
--
  ben_assignment_internal.copy_empasg_to_benasg
    (p_person_id             => p_person_id
    --
    ,p_per_date_of_death     => p_date_of_death
    ,p_per_marital_status    => p_marital_status
    ,p_per_esd               => p_effective_start_date
    --
    ,p_assignment_id         => l_benasg_id
    ,p_object_version_number => l_benasg_ovn
    ,p_perhasmultptus        => l_perhasmultptus
    );
  open get_old_ppf(p_rowid);
  fetch get_old_ppf into l_old_rec;
  close get_old_ppf;
--
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.person_id := p_person_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.date_of_birth := p_date_of_birth;
  l_new_rec.date_of_death := p_date_of_death;
  l_new_rec.marital_status := p_marital_status;
  l_new_rec.on_military_service := p_on_military_service;
  l_new_rec.registered_disabled_flag := p_registered_disabled_flag;
  l_new_rec.sex := p_sex;
  l_new_rec.student_status := p_student_status;
  l_new_rec.coord_ben_med_pln_no := p_coord_ben_med_pln_no;
  l_new_rec.coord_ben_no_cvg_flag := p_coord_ben_no_cvg_flag;
  l_new_rec.uses_tobacco_flag := p_uses_tobacco_flag;
  l_new_rec.benefit_group_id := p_benefit_group_id;
  l_new_rec.DPDNT_VLNTRY_SVCE_FLAG:= p_dpdnt_vlntry_svce_flag;
  l_new_rec.RECEIPT_OF_DEATH_CERT_DATE:= p_receipt_of_death_cert_date;
  l_new_rec.per_information10 := p_per_information10;
  l_new_rec.attribute1 := p_attribute1;
  l_new_rec.attribute2 := p_attribute2;
  l_new_rec.attribute3 := p_attribute3;
  l_new_rec.attribute4 := p_attribute4;
  l_new_rec.attribute5 := p_attribute5;
  l_new_rec.attribute6 := p_attribute6;
  l_new_rec.attribute7 := p_attribute7;
  l_new_rec.attribute8 := p_attribute8;
  l_new_rec.attribute9 := p_attribute9;
  l_new_rec.attribute10 := p_attribute10;
  l_new_rec.attribute11 := p_attribute11;
  l_new_rec.attribute12 := p_attribute12;
  l_new_rec.attribute13 := p_attribute13;
  l_new_rec.attribute14 := p_attribute14;
  l_new_rec.attribute15 := p_attribute15;
  l_new_rec.attribute16 := p_attribute16;
  l_new_rec.attribute17 := p_attribute17;
  l_new_rec.attribute18 := p_attribute18;
  l_new_rec.attribute19 := p_attribute19;
  l_new_rec.attribute20 := p_attribute20;
  l_new_rec.attribute21 := p_attribute21;
  l_new_rec.attribute22 := p_attribute22;
  l_new_rec.attribute23 := p_attribute23;
  l_new_rec.attribute24 := p_attribute24;
  l_new_rec.attribute25 := p_attribute25;
  l_new_rec.attribute26 := p_attribute26;
  l_new_rec.attribute27 := p_attribute27;
  l_new_rec.attribute28 := p_attribute28;
  l_new_rec.attribute29 := p_attribute29;
  l_new_rec.attribute30 := p_attribute30;
  --
  --Bug 2215549 added p_effective_start_date parameter
  --
  ben_ppf_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;

end person;

procedure person(p_rowid in VARCHAR2
  ,p_business_group_id in NUMBER
  ,p_person_id in NUMBER
  ,p_effective_start_date in DATE
  ,p_effective_end_date in DATE
  ,p_date_of_birth in DATE
  ,p_date_of_death in DATE
  ,p_marital_status in VARCHAR2
  ,p_on_military_service in VARCHAR2
  ,p_registered_disabled_flag in VARCHAR2
  ,p_sex in VARCHAR2
  ,p_student_status in VARCHAR2
  ,p_coord_ben_med_pln_no in VARCHAR2
  ,p_coord_ben_no_cvg_flag in VARCHAR2
  ,p_uses_tobacco_flag in VARCHAR2
  ,p_benefit_group_id in NUMBER
  ,p_per_information10 in VARCHAR2
  ,p_original_date_of_hire in DATE
  ,p_dpdnt_vlntry_svce_flag in VARCHAR2
  ,p_receipt_of_death_cert_date in DATE
  ,p_attribute1  in VARCHAR2
  ,p_attribute2  in VARCHAR2
  ,p_attribute3  in VARCHAR2
  ,p_attribute4  in VARCHAR2
  ,p_attribute5  in VARCHAR2
  ,p_attribute6  in VARCHAR2
  ,p_attribute7  in VARCHAR2
  ,p_attribute8  in VARCHAR2
  ,p_attribute9  in VARCHAR2
  ,p_attribute10 in VARCHAR2
  ,p_attribute11 in VARCHAR2
  ,p_attribute12 in VARCHAR2
  ,p_attribute13 in VARCHAR2
  ,p_attribute14 in VARCHAR2
  ,p_attribute15 in VARCHAR2
  ,p_attribute16 in VARCHAR2
  ,p_attribute17 in VARCHAR2
  ,p_attribute18 in VARCHAR2
  ,p_attribute19 in VARCHAR2
  ,p_attribute20 in VARCHAR2
  ,p_attribute21 in VARCHAR2
  ,p_attribute22 in VARCHAR2
  ,p_attribute23 in VARCHAR2
  ,p_attribute24 in VARCHAR2
  ,p_attribute25 in VARCHAR2
  ,p_attribute26 in VARCHAR2
  ,p_attribute27 in VARCHAR2
  ,p_attribute28 in VARCHAR2
  ,p_attribute29 in VARCHAR2
  ,p_attribute30 in VARCHAR2
  )
is
  --
  l_proc        varchar2(72):=g_package||'person';
  --
cursor get_old_ppf(p_rowid in varchar2)
is
  select  PERSON_ID
         ,BUSINESS_GROUP_ID
         ,EFFECTIVE_START_DATE
         ,EFFECTIVE_END_DATE
         ,DATE_OF_BIRTH
         ,DATE_OF_DEATH
         ,ON_MILITARY_SERVICE
         ,MARITAL_STATUS
         ,REGISTERED_DISABLED_FLAG
         ,SEX
         ,STUDENT_STATUS
         ,BENEFIT_GROUP_ID
         ,COORD_BEN_NO_CVG_FLAG
         ,USES_TOBACCO_FLAG
         ,COORD_BEN_MED_PLN_NO
         ,PER_INFORMATION10
         ,DPDNT_VLNTRY_SVCE_FLAG
         ,RECEIPT_OF_DEATH_CERT_DATE
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE16
         ,ATTRIBUTE17
         ,ATTRIBUTE18
         ,ATTRIBUTE19
         ,ATTRIBUTE20
         ,ATTRIBUTE21
         ,ATTRIBUTE22
         ,ATTRIBUTE23
         ,ATTRIBUTE24
         ,ATTRIBUTE25
         ,ATTRIBUTE26
         ,ATTRIBUTE27
         ,ATTRIBUTE28
         ,ATTRIBUTE29
         ,ATTRIBUTE30
         ,ORIGINAL_DATE_OF_HIRE
  from per_all_people_f
  where rowid = p_rowid;
  --
  l_old_rec ben_ppf_ler.g_ppf_ler_rec;
  l_new_rec ben_ppf_ler.g_ppf_ler_rec;
  --
  l_benasg_id      number;
  l_benasg_ovn     number;
  l_perhasmultptus boolean;

begin
--
-- Bug : 3320133

benutils.set_data_migrator_mode;
--
-- Bug : 3320133
--
g_debug := hr_utility.debug_enabled;
if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering: '|| l_proc, 10);
    hr_utility.set_location('p_mar_stat: '||p_marital_status||' '||l_proc, 10);
    hr_utility.set_location('p_per_esd: '||p_effective_start_date||' '||l_proc, 10);
    hr_utility.set_location('rowid: '||p_rowid||' '||l_proc, 10);
  end if;

--
  ben_assignment_internal.copy_empasg_to_benasg
    (p_person_id             => p_person_id
    --
    ,p_per_date_of_death     => p_date_of_death
    ,p_per_marital_status    => p_marital_status
    ,p_per_esd               => p_effective_start_date
    --
    ,p_assignment_id         => l_benasg_id
    ,p_object_version_number => l_benasg_ovn
    ,p_perhasmultptus        => l_perhasmultptus
    );
  open get_old_ppf(p_rowid);
  fetch get_old_ppf into l_old_rec;
  close get_old_ppf;
--
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.person_id := p_person_id;
  l_new_rec.effective_start_date := p_effective_start_date;

  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.date_of_birth := p_date_of_birth;
  l_new_rec.date_of_death := p_date_of_death;
  l_new_rec.marital_status := p_marital_status;
  l_new_rec.on_military_service := p_on_military_service;
  l_new_rec.registered_disabled_flag := p_registered_disabled_flag;
  l_new_rec.sex := p_sex;
  l_new_rec.student_status := p_student_status;
  l_new_rec.coord_ben_med_pln_no := p_coord_ben_med_pln_no;
  l_new_rec.coord_ben_no_cvg_flag := p_coord_ben_no_cvg_flag;
  l_new_rec.uses_tobacco_flag := p_uses_tobacco_flag;
  l_new_rec.benefit_group_id := p_benefit_group_id;
  l_new_rec.DPDNT_VLNTRY_SVCE_FLAG:= p_dpdnt_vlntry_svce_flag;
  l_new_rec.RECEIPT_OF_DEATH_CERT_DATE:= p_receipt_of_death_cert_date;
  l_new_rec.per_information10 := p_per_information10;
  l_new_rec.attribute1 := p_attribute1;
  l_new_rec.attribute2 := p_attribute2;
  l_new_rec.attribute3 := p_attribute3;
  l_new_rec.attribute4 := p_attribute4;
  l_new_rec.attribute5 := p_attribute5;
  l_new_rec.attribute6 := p_attribute6;
  l_new_rec.attribute7 := p_attribute7;
  l_new_rec.attribute8 := p_attribute8;
  l_new_rec.attribute9 := p_attribute9;
  l_new_rec.attribute10 := p_attribute10;
  l_new_rec.attribute11 := p_attribute11;
  l_new_rec.attribute12 := p_attribute12;
  l_new_rec.attribute13 := p_attribute13;
  l_new_rec.attribute14 := p_attribute14;
  l_new_rec.attribute15 := p_attribute15;
  l_new_rec.attribute16 := p_attribute16;
  l_new_rec.attribute17 := p_attribute17;
  l_new_rec.attribute18 := p_attribute18;
  l_new_rec.attribute19 := p_attribute19;
  l_new_rec.attribute20 := p_attribute20;
  l_new_rec.attribute21 := p_attribute21;
  l_new_rec.attribute22 := p_attribute22;
  l_new_rec.attribute23 := p_attribute23;
  l_new_rec.attribute24 := p_attribute24;
  l_new_rec.attribute25 := p_attribute25;
  l_new_rec.attribute26 := p_attribute26;
  l_new_rec.attribute27 := p_attribute27;
  l_new_rec.attribute28 := p_attribute28;
  l_new_rec.attribute29 := p_attribute29;
  l_new_rec.attribute30 := p_attribute30;
  l_new_rec.person_id := p_person_id;
  ben_ppf_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;


end person;
procedure assignment
  (p_rowid IN VARCHAR2
  ,p_assignment_id IN NUMBER
  ,p_business_group_id IN NUMBER
  ,p_person_id in NUMBER
  ,p_effective_start_date in DATE
  ,p_effective_end_date in DATE
  ,p_assignment_status_type_id IN NUMBER
  ,p_assignment_type IN VARCHAR2
  ,p_organization_id IN NUMBER
  ,p_primary_flag IN VARCHAR2
  ,p_change_reason IN VARCHAR2
  ,p_employment_category IN VARCHAR2
  ,p_frequency IN VARCHAR2

  ,p_grade_id IN NUMBER
  ,p_job_id IN NUMBER
  ,p_position_id IN NUMBER
  ,p_location_id IN NUMBER
  ,p_normal_hours IN VARCHAR2
  ,p_payroll_id in NUMBER
  ,p_pay_basis_id IN NUMBER
  ,p_bargaining_unit_code IN VARCHAR2
  ,p_labour_union_member_flag IN VARCHAR2
  ,p_hourly_salaried_code IN VARCHAR2
  ,p_people_group_id IN NUMBER
  ,p_ass_attribute1  in VARCHAR2
  ,p_ass_attribute2  in VARCHAR2
  ,p_ass_attribute3  in VARCHAR2
  ,p_ass_attribute4  in VARCHAR2
  ,p_ass_attribute5  in VARCHAR2
  ,p_ass_attribute6  in VARCHAR2
  ,p_ass_attribute7  in VARCHAR2
  ,p_ass_attribute8  in VARCHAR2
  ,p_ass_attribute9  in VARCHAR2
  ,p_ass_attribute10 in VARCHAR2
  ,p_ass_attribute11 in VARCHAR2
  ,p_ass_attribute12 in VARCHAR2
  ,p_ass_attribute13 in VARCHAR2
  ,p_ass_attribute14 in VARCHAR2
  ,p_ass_attribute15 in VARCHAR2
  ,p_ass_attribute16 in VARCHAR2
  ,p_ass_attribute17 in VARCHAR2
  ,p_ass_attribute18 in VARCHAR2
  ,p_ass_attribute19 in VARCHAR2
  ,p_ass_attribute20 in VARCHAR2
  ,p_ass_attribute21 in VARCHAR2
  ,p_ass_attribute22 in VARCHAR2
  ,p_ass_attribute23 in VARCHAR2
  ,p_ass_attribute24 in VARCHAR2
  ,p_ass_attribute25 in VARCHAR2
  ,p_ass_attribute26 in VARCHAR2
  ,p_ass_attribute27 in VARCHAR2
  ,p_ass_attribute28 in VARCHAR2
  ,p_ass_attribute29 in VARCHAR2
  ,p_ass_attribute30 in VARCHAR2
  )
is
  --
  l_proc           varchar2(72):=g_package||'assignment';
  --
  l_old_rec        ben_asg_ler.g_asg_ler_rec;
  l_new_rec        ben_asg_ler.g_asg_ler_rec;
  --
  l_benasg_id      number;
  l_benasg_ovn     number;
  --

cursor get_old_asg(p_rowid in varchar2)
is
select PERSON_ID
       ,ASSIGNMENT_ID
       ,BUSINESS_GROUP_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
       ,ORGANIZATION_ID
       ,GRADE_ID
       ,JOB_ID
       ,POSITION_ID
       ,PAYROLL_ID
       ,LOCATION_ID
       ,ASSIGNMENT_STATUS_TYPE_ID
       ,ASSIGNMENT_TYPE
       ,PAY_BASIS_ID
       ,PRIMARY_FLAG
       ,CHANGE_REASON
       ,EMPLOYMENT_CATEGORY
       ,FREQUENCY
       ,NORMAl_HOURS
       ,BARGAINING_UNIT_CODE
       ,LABOUR_UNION_MEMBER_FLAG
       ,PEOPLE_GROUP_ID
       ,HOURLY_SALARIED_CODE
       ,ASS_ATTRIBUTE1
       ,ASS_ATTRIBUTE2
       ,ASS_ATTRIBUTE3
       ,ASS_ATTRIBUTE4
       ,ASS_ATTRIBUTE5
       ,ASS_ATTRIBUTE6
       ,ASS_ATTRIBUTE7
       ,ASS_ATTRIBUTE8
       ,ASS_ATTRIBUTE9
       ,ASS_ATTRIBUTE10
       ,ASS_ATTRIBUTE11
       ,ASS_ATTRIBUTE12
       ,ASS_ATTRIBUTE13
       ,ASS_ATTRIBUTE14
       ,ASS_ATTRIBUTE15
       ,ASS_ATTRIBUTE16
       ,ASS_ATTRIBUTE17
       ,ASS_ATTRIBUTE18
       ,ASS_ATTRIBUTE19
       ,ASS_ATTRIBUTE20
       ,ASS_ATTRIBUTE21
       ,ASS_ATTRIBUTE22
       ,ASS_ATTRIBUTE23
       ,ASS_ATTRIBUTE24
       ,ASS_ATTRIBUTE25
       ,ASS_ATTRIBUTE26
       ,ASS_ATTRIBUTE27
       ,ASS_ATTRIBUTE28
       ,ASS_ATTRIBUTE29
       ,ASS_ATTRIBUTE30
from per_all_assignments_f
where rowid = p_rowid;
  --
begin
--
g_debug := hr_utility.debug_enabled;
if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.set_location('p_per_esd: '||p_effective_start_date||' '||l_proc, 10);
    hr_utility.set_location('rowid: '||p_rowid||' '||l_proc, 10);
  end if;
  --
  open get_old_asg(p_rowid);
  fetch get_old_asg into l_old_rec;
  close get_old_asg;
  --
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.person_id := p_person_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.assignment_status_type_id :=p_assignment_status_type_id;
  l_new_rec.assignment_type :=p_assignment_type;
  l_new_rec.organization_id := p_organization_id;
  l_new_rec.primary_flag := p_primary_flag;
  l_new_rec.change_reason := p_change_reason;
  l_new_rec.employment_category := p_employment_category;

  l_new_rec.assignment_id := p_assignment_id;
  l_new_rec.frequency := p_frequency;
  l_new_rec.grade_id := p_grade_id;
  l_new_rec.job_id := p_job_id;
  l_new_rec.position_id := p_position_id;
  l_new_rec.location_id := p_location_id;
  l_new_rec.normal_hours := p_normal_hours;
  l_new_rec.payroll_id := p_payroll_id;
  l_new_rec.pay_basis_id := p_pay_basis_id;
  l_new_rec.bargaining_unit_code := p_bargaining_unit_code;
  l_new_rec.labour_union_member_flag := p_labour_union_member_flag;
  l_new_rec.people_group_id := p_people_group_id;
  l_new_rec.hourly_salaried_code := p_hourly_salaried_code;
  l_new_rec.ass_attribute1 := p_ass_attribute1;
  l_new_rec.ass_attribute2 := p_ass_attribute2;
  l_new_rec.ass_attribute3 := p_ass_attribute3;
  l_new_rec.ass_attribute4 := p_ass_attribute4;
  l_new_rec.ass_attribute5 := p_ass_attribute5;
  l_new_rec.ass_attribute6 := p_ass_attribute6;
  l_new_rec.ass_attribute7 := p_ass_attribute7;
  l_new_rec.ass_attribute8 := p_ass_attribute8;
  l_new_rec.ass_attribute9 := p_ass_attribute9;
  l_new_rec.ass_attribute10 := p_ass_attribute10;
  l_new_rec.ass_attribute11 := p_ass_attribute11;
  l_new_rec.ass_attribute12 := p_ass_attribute12;
  l_new_rec.ass_attribute13 := p_ass_attribute13;
  l_new_rec.ass_attribute14 := p_ass_attribute14;
  l_new_rec.ass_attribute15 := p_ass_attribute15;
  l_new_rec.ass_attribute16 := p_ass_attribute16;
  l_new_rec.ass_attribute17 := p_ass_attribute17;
  l_new_rec.ass_attribute18 := p_ass_attribute18;
  l_new_rec.ass_attribute19 := p_ass_attribute19;
  l_new_rec.ass_attribute20 := p_ass_attribute20;
  l_new_rec.ass_attribute21 := p_ass_attribute21;
  l_new_rec.ass_attribute22 := p_ass_attribute22;
  l_new_rec.ass_attribute23 := p_ass_attribute23;
  l_new_rec.ass_attribute24 := p_ass_attribute24;
  l_new_rec.ass_attribute25 := p_ass_attribute25;
  l_new_rec.ass_attribute26 := p_ass_attribute26;
  l_new_rec.ass_attribute27 := p_ass_attribute27;
  l_new_rec.ass_attribute28 := p_ass_attribute28;
  l_new_rec.ass_attribute29 := p_ass_attribute29;
  l_new_rec.ass_attribute30 := p_ass_attribute30;
  ben_asg_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end assignment;
/*
procedure person_type_usages
  (p_rowid in VARCHAR2
  ,p_person_id IN NUMBER
  ,p_person_type_id IN NUMBER
--  ,p_effective_start_date in DATE
-- ,p_effective_end_date in DATE
  )
is
  --
  l_proc        varchar2(72):=g_package||'person_type_usages';
  --
cursor get_old_ptu(p_rowid in VARCHAR2) is
select PERSON_ID
     -- 9999  ,person_type_usage_id
       ,null
       ,PERSON_TYPE_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
from per_person_type_usages_f
where rowid = p_rowid;
--
l_old_rec ben_ptu_ler.g_ptu_ler_rec;
l_new_rec ben_ptu_ler.g_ptu_ler_rec;
--
begin
g_debug := hr_utility.debug_enabled;
if g_debug then
  hr_utility.set_location('MUPPET',10);
end if;
--
if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_ptu(p_rowid);
  fetch get_old_ptu into l_old_rec;
  close get_old_ptu;
  -- get new record
  l_new_rec.person_id := p_person_id;
  l_new_rec.person_type_id := p_person_type_id;
  -- 999 l_new_rec.person_type_usage_id := p_person_type_usage_id;
  -- 999 l_new_rec.person_type_usage_id := l_old_rec.person_type_usage_id;
  l_new_rec.business_group_id := null;
--  l_new_rec.effective_start_date := p_effective_start_date;
-- l_new_rec.effective_end_date := p_effective_end_date;
  --
  ben_ptu_ler.ler_chk(l_old_rec,l_new_rec);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
end person_type_usages;
*/

procedure periods_of_service
(p_rowid              in VARCHAR2
,p_person_id          IN NUMBER
,p_pds_atd            IN date
,p_pds_leaving_reason in VARCHAR2
,p_pds_fpd            IN date
,p_pds_old_atd        IN date default null
)
is
  --
  l_proc                 varchar2(72):=g_package||'periods_of_service';
  --
  l_benasg_id            number;
  l_exists               varchar2(1);
  l_benasg_ovn           number;
  l_perhasmultptus       boolean;
  l_delete_benass        boolean := false;
  l_num_recs             number;
  l_effective_start_date date;
  l_effective_end_date   date;
  --
  cursor c1 is
    select  count(*)
    from    per_periods_of_service
    where   person_id = p_person_id;
  --
  cursor c2 is
    select *
    from   per_all_assignments_f
    where  person_id = p_person_id
    and    assignment_type = 'B'
    and    primary_flag = 'Y'
    --
    -- Bug 4395472 : added condition so that correct benefit
    --               assignment record is picked
    and    effective_end_date >= p_pds_old_atd
    -- End Bug 4395472
    order  by effective_start_date;
  --
  cursor c3 is
    select null
    from   per_all_assignments_f  asg
    where  asg.person_id = p_person_id
    and    asg.effective_start_date = p_pds_atd + 1
    and    assignment_type = 'B'
    and    primary_flag = 'Y';
  --
  l_c2 c2%rowtype;
  --
    l_ptu_index                 number := 0;
    l_ptu_system_person_type    per_person_types.system_person_type%type;
  --
    cursor c1_revterm_ptu is
    select ptu.person_id, ppt.system_person_type
    from   per_person_type_usages_f ptu,
           per_person_types ppt
    where  ptu.person_id in (select pcr.contact_person_id
                             from   per_contact_relationships pcr
                             where  pcr.person_id =  p_person_id
                            )
    and    trunc(p_pds_old_atd+1) between trunc(ptu.effective_start_date)
                                  and trunc(ptu.effective_end_date)
    and    ptu.person_type_id = ppt.person_type_id
    and    ppt.system_person_type  in (  'SRVNG_SPS',
                                         'SRVNG_DP',
                                         'SRVNG_DPFM',
                                         'SRVNG_FMLY_MMBR');
  --
  -- Bug 3865655
  l_zap_mode                            boolean;
  l_delete_mode                         boolean;
  l_future_change_mode                  boolean;
  l_delete_next_change_mode             boolean;
  l_asg_delete_mode                     varchar2(60);
  -- Bug 3865655
  --
begin
--

  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  --  Only create a benefit assignment if the actual termination date
  --  is not null.  When the hr apis are called to terminate an employee, we
  --  do not want the benefit assignment created twice.
  --
  if g_debug then
    hr_utility.set_location('p_pds_old_atd: '|| p_pds_old_atd, 10);
  end if;
  --
  if (p_pds_old_atd is null and
      p_pds_atd is not null) then
    open c3;
    fetch c3 into l_exists;
    if c3%notfound then
      close c3;
      ben_assignment_internal.copy_empasg_to_benasg
        (p_person_id             => p_person_id
        --
        ,p_pds_atd               => p_pds_atd
        ,p_pds_leaving_reason    => p_pds_leaving_reason
        ,p_pds_fpd               => p_pds_fpd
        --
        ,p_assignment_id         => l_benasg_id
        ,p_object_version_number => l_benasg_ovn
        ,p_perhasmultptus        => l_perhasmultptus
        );
    else
      close c3;
    end if;
  end if;

   -- Fix for 2057246
    /*   The reverse termination:
         Requirement:
            When the termination is reversed, the persontype usages created
            at the time of termination, should be cancelled.
         Plan :
            if old_atd is not null and atd is null
                then
                    1. For each termination related persontype usages
                    get the ptu s created at the time of termination
                    2. cancell them.
            end if.
    */

    begin

     if g_debug then
       hr_utility.set_location('To cancel ptu s for reverse termination : ', 1010);
     end if;
     if p_pds_atd is null  and
       p_pds_old_atd is not null
     then
     if g_debug then
       hr_utility.set_location('Cancel ptu s for reverse termination Started : ', 1011);
     end if;

        for l_ptu_index in c1_revterm_ptu
        loop
     if g_debug then
       hr_utility.set_location('Cancel ptu s for contact_id : '||l_ptu_index.person_id
       				||' Of Type : '||l_ptu_index.system_person_type, 1012);
     end if;
            hr_per_type_usage_internal.cancel_person_type_usage
            (    p_effective_date     =>(p_pds_old_atd+1)
                ,p_person_id          => l_ptu_index.person_id
                ,p_system_person_type => l_ptu_index.system_person_type
            );

        end loop;
     if g_debug then
       hr_utility.set_location('Cancel ptu s for reverse termination Completed Normal: ', 1013);
     end if;

     end if;
    exception when others then
     if g_debug then
       hr_utility.set_location('Cancel ptu s for reverse termination Completed with Exception: ', 1014);
     end if;
     raise;
    end;

  --
  -- BUG Fix for WWBUG 1176101.
  -- If a person is terminated and then unterminated then we have to make
  -- sure that they only have one period of service if we are going to delete
  -- the benefit assignment.
  --
  open c1;
    --
    fetch c1 into l_num_recs;
    --
  close c1;
  --
  if g_debug then
    hr_utility.set_location('Number of records:'|| l_num_recs, 10);
  end if;
  --
  if l_num_recs > 1 then
    --
    -- Previous period of service exists
    --
    l_delete_benass := false;
    --
    if g_debug then
      hr_utility.set_location('Assignment not being deleted', 10);
    end if;
    --
  else
    --
    -- Check if what we are updating has been nullified, in other words a
    -- reverse termination.
    --
    if g_debug then
      hr_utility.set_location('ATD'||p_pds_atd, 10);
    end if;
    --
    if p_pds_atd is null  and
       p_pds_old_atd is not null   -- Bug 1854968
    then
      --
      if g_debug then
        hr_utility.set_location('Assignment being deleted', 10);
      end if;
      l_delete_benass := true;
      --
    end if;
    --
  end if;
  --
  if l_delete_benass then
    --
    open c2;
      --
      fetch c2 into l_c2;
      --
    close c2;
    --
    -- WWBUG API fix , only delete if benefit assignment exists
    --
    if l_c2.assignment_id is not null then
      --
      -- We can remove the benefit assignment since a reverse termination
      -- must have taken place.
      -- Bug : 3865655 Changed datetrack mode from ZAP to 3865655

      dt_api.Find_DT_Del_Modes
        (p_effective_date        => l_c2.effective_start_date,
           p_base_table_name     => 'PER_ALL_ASSIGNMENTS_F',
           p_base_key_column     => 'ASSIGNMENT_ID',
           p_base_key_value      => l_c2.assignment_id,
           p_zap                 => l_zap_mode,
           p_delete              => l_delete_mode,
           p_future_change       => l_future_change_mode,
           p_delete_next_change  => l_delete_next_change_mode);
      --
      -- The case of p_future_change to be true would not arise, because
      -- if there is a third date track assignment record, then deletion of
      -- benefit assignment is prevented by the validation due to Cursor C1 above
      --
      if l_delete_next_change_mode = true then
        -- Refer steps to reproduce of bug 3865655 to find the Scenario under which
        -- this condition will be true
        l_asg_delete_mode := 'DELETE_NEXT_CHANGE';
      else
        l_asg_delete_mode := 'ZAP';
      end if;
      --
      ben_assignment_api.delete_ben_asg
        (p_datetrack_mode        => l_asg_delete_mode
        ,p_assignment_id         => l_c2.assignment_id
        ,p_object_version_number => l_c2.object_version_number
        ,p_effective_date        => l_c2.effective_start_date
        ,p_effective_start_date  => l_effective_start_date
        ,p_effective_end_date    => l_effective_end_date);
      --
    end if;
    --
  end if;
  --
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end periods_of_service;
--
-- overloaded for per patchset A.
--
procedure bnfts_bal
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_val                IN NUMBER
,p_bnfts_bal_id       in NUMBER
)
is
  --
  l_proc        varchar2(72):=g_package||'bnfts_bal';
  --

cursor get_old_pbb(p_rowid in VARCHAR2) is
select PERSON_ID
       ,null
       ,BUSINESS_GROUP_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
       ,VAL
       ,BNFTS_BAL_ID
from ben_per_bnfts_bal_f
where rowid = p_rowid;
--
l_old_rec ben_pbb_ler.g_pbb_ler_rec;
l_new_rec ben_pbb_ler.g_pbb_ler_rec;
--
begin

--
  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_pbb(p_rowid);
  fetch get_old_pbb into l_old_rec;
  close get_old_pbb;
  -- get new record
  l_new_rec.person_id := p_person_id;
  l_new_rec.val := p_val;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.bnfts_bal_id := p_bnfts_bal_id;
  --
  ben_pbb_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end bnfts_bal;

procedure bnfts_bal
(p_rowid              in VARCHAR2
,p_per_bnfts_bal_id   in NUMBER
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_val                IN NUMBER
,p_bnfts_bal_id       in NUMBER
)
is
  --
  l_proc        varchar2(72):=g_package||'bnfts_bal';
  --

cursor get_old_pbb(p_rowid in VARCHAR2) is
select PERSON_ID
       ,PER_BNFTS_BAL_ID
       ,BUSINESS_GROUP_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
       ,VAL
       ,BNFTS_BAL_ID
from ben_per_bnfts_bal_f
where rowid = p_rowid;
--
l_old_rec ben_pbb_ler.g_pbb_ler_rec;
l_new_rec ben_pbb_ler.g_pbb_ler_rec;
begin
--
  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_pbb(p_rowid);
  fetch get_old_pbb into l_old_rec;
  close get_old_pbb;
  -- get new record
  l_new_rec.person_id := p_person_id;
  l_new_rec.val := p_val;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.bnfts_bal_id := p_bnfts_bal_id;
  -- 9999 l_new_rec.per_bnfts_bal_id := l_old_rec.per_bnfts_bal_id;
  l_new_rec.per_bnfts_bal_id := p_bnfts_bal_id;
  --
  ben_pbb_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end bnfts_bal;
--
-- Overloaded for Per patchset A
--
procedure elig_cvrd_dpnt
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_dpnt_person_id     IN NUMBER
,p_prtt_enrt_rslt_id  IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_cvg_strt_dt        IN DATE
,p_cvg_thru_dt        in DATE
,p_ovrdn_flag         in VARCHAR2
,p_ovrdn_thru_dt      in DATE
)
is
  --
  l_proc        varchar2(72):=g_package||'elig_cvrd_dpnt';
  --

cursor get_old_ecd(p_rowid in VARCHAR2) is
select PRTT_ENRT_RSLT_ID
       ,null
       ,DPNT_PERSON_ID
       ,BUSINESS_GROUP_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
       ,CVG_STRT_DT
       ,CVG_THRU_DT
       ,ovrdn_flag
       ,ovrdn_thru_dt
from ben_elig_cvrd_dpnt_f
where rowid = p_rowid;
--
l_old_rec ben_ecd_ler.g_ecd_ler_rec;
l_new_rec ben_ecd_ler.g_ecd_ler_rec;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_ecd(p_rowid);
  fetch get_old_ecd into l_old_rec;
  close get_old_ecd;
  -- get new record
  l_new_rec.prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.dpnt_person_id    := p_dpnt_person_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.cvg_strt_dt := p_cvg_strt_dt;
  l_new_rec.cvg_thru_dt := p_cvg_thru_dt;
  l_new_rec.ovrdn_flag := p_ovrdn_flag;
  l_new_rec.ovrdn_thru_dt := p_ovrdn_thru_dt;
  --
  ben_ecd_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
  end if;
  --
end elig_cvrd_dpnt;

procedure elig_cvrd_dpnt
(p_rowid              in VARCHAR2
,p_elig_cvrd_dpnt_id  in number
,p_business_group_id  IN NUMBER
,p_dpnt_person_id     in NUMBER
,p_prtt_enrt_rslt_id  IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_cvg_strt_dt        IN DATE
,p_cvg_thru_dt        in DATE
,p_ovrdn_flag         in VARCHAR2
,p_ovrdn_thru_dt      in DATE
)
is
  --
  l_proc        varchar2(72):=g_package||'elig_cvrd_dpnt';
  --

cursor get_old_ecd(p_rowid in VARCHAR2) is
select PRTT_ENRT_RSLT_ID
       ,elig_cvrd_dpnt_id
       ,dpnt_person_id
       ,BUSINESS_GROUP_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
       ,CVG_STRT_DT
       ,CVG_THRU_DT
       ,ovrdn_flag
       ,ovrdn_thru_dt
from ben_elig_cvrd_dpnt_f
where rowid = p_rowid;
--
l_old_rec ben_ecd_ler.g_ecd_ler_rec;
l_new_rec ben_ecd_ler.g_ecd_ler_rec;
--
begin
--
--
 g_debug := hr_utility.debug_enabled;
 if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_ecd(p_rowid);
  fetch get_old_ecd into l_old_rec;
  close get_old_ecd;
  -- get new record
  l_new_rec.prtt_enrt_rslt_id := p_prtt_enrt_rslt_id;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.dpnt_person_id    := p_dpnt_person_id;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  l_new_rec.cvg_strt_dt := p_cvg_strt_dt;
  l_new_rec.cvg_thru_dt := p_cvg_thru_dt;
  l_new_rec.ovrdn_flag := p_ovrdn_flag;
  l_new_rec.ovrdn_thru_dt := p_ovrdn_thru_dt;
  l_new_rec.elig_cvrd_dpnt_id := p_elig_cvrd_dpnt_id;
  -- 9999 l_new_rec.elig_cvrd_dpnt_id := l_old_rec.elig_cvrd_dpnt_id;
  --
  ben_ecd_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date );
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end elig_cvrd_dpnt;
--
-- Overloaded for per patchset A
--
procedure prtt_enrt_rslt
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_enrt_cvg_strt_dt   in DATE
,p_enrt_cvg_thru_dt in DATE
,p_bnft_amt                IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
)
is
  --
  l_proc        varchar2(72):=g_package||'prtt_enrt_rslt';
  --

cursor get_old_pen(p_rowid in VARCHAR2) is
select PERSON_ID
       ,null
       ,BUSINESS_GROUP_ID
       ,ENRT_CVG_STRT_DT
       ,ENRT_CVG_THRU_DT
       ,BNFT_AMT
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
from ben_prtt_enrt_rslt_f
where rowid = p_rowid;
--
l_old_rec ben_pen_ler.g_pen_ler_rec;
l_new_rec ben_pen_ler.g_pen_ler_rec;
--
begin
--
--
  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_pen(p_rowid);
  fetch get_old_pen into l_old_rec;
  close get_old_pen;
  -- get new record
  l_new_rec.person_id := p_person_id;
  l_new_rec.bnft_amt := p_bnft_amt;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
  l_new_rec.enrt_cvg_thru_dt := p_enrt_cvg_thru_dt;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  --
  ben_pen_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
 end if;
  --
end prtt_enrt_rslt;


procedure prtt_enrt_rslt
(p_rowid              in VARCHAR2
,p_prtt_enrt_rslt_id  in number
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_enrt_cvg_strt_dt   in DATE
,p_enrt_cvg_thru_dt in DATE
,p_bnft_amt                IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
)
is
  --
  l_proc        varchar2(72):=g_package||'prtt_enrt_rslt';
  --

cursor get_old_pen(p_rowid in VARCHAR2) is
select PERSON_ID
       ,prtt_enrt_rslt_id
       ,BUSINESS_GROUP_ID
       ,ENRT_CVG_STRT_DT
       ,ENRT_CVG_THRU_DT
       ,BNFT_AMT
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
from ben_prtt_enrt_rslt_f
where rowid = p_rowid;
--
l_old_rec ben_pen_ler.g_pen_ler_rec;
l_new_rec ben_pen_ler.g_pen_ler_rec;
--
begin
--
  g_debug := hr_utility.debug_enabled;
  if hr_general.g_data_migrator_mode not in ( 'Y','P') then
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_pen(p_rowid);
  fetch get_old_pen into l_old_rec;
  close get_old_pen;
  -- get new record
  l_new_rec.person_id := p_person_id;
  l_new_rec.bnft_amt := p_bnft_amt;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.enrt_cvg_strt_dt := p_enrt_cvg_strt_dt;
  l_new_rec.enrt_cvg_thru_dt := p_enrt_cvg_thru_dt;
  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;
  -- 9999 l_new_rec.PRTT_ENRT_RSLT_ID := l_old_rec.PRTT_ENRT_RSLT_ID;
  l_new_rec.PRTT_ENRT_RSLT_ID := p_PRTT_ENRT_RSLT_ID;
  --
  ben_pen_ler.ler_chk(l_old_rec,l_new_rec,p_effective_start_date);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
end if;
--
end prtt_enrt_rslt;

/******** procedure elem_entry_values
  (p_rowid in VARCHAR2
  ,p_element_entry_value_id IN NUMBER
  ,p_screen_entry_value IN VARCHAR2
  )
is
  --
  l_proc        varchar2(72):=g_package||'elem_entry_values';
  --

cursor get_old_eev(p_rowid in VARCHAR2) is
select ELEMENT_ENTRY_VALUE_ID
       ,SCREEN_ENTRY_VALUE
from pay_element_entry_values_f
where rowid = p_rowid;
--
l_old_rec ben_eev_ler.g_eev_ler_rec;
l_new_rec ben_eev_ler.g_eev_ler_rec;
--
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_eev(p_rowid);
  fetch get_old_eev into l_old_rec;
  close get_old_eev;
  -- get new record
  l_new_rec.element_entry_value_id := p_element_entry_value_id;
  l_new_rec.screen_entry_value := p_screen_entry_value;
  --
  ben_eev_ler.ler_chk(l_old_rec,l_new_rec);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
end elem_entry_values:       ******************/

/*******procedure asgn_budget_values
  (p_rowid in VARCHAR2
  ,p_assignment_id IN NUMBER
  ,p_business_group_id  IN NUMBER
  ,p_value IN NUMBER
  ,p_assignment_budget_value_id IN NUMBER
***  ,p_effective_start_date IN DATE
  ,p_effective_end_date IN DATE  ***
  )
is
  --
  l_proc        varchar2(72):=g_package||'asgn_budget_values';
  --

cursor get_old_abv(p_rowid in VARCHAR2) is
select ASSIGNMENT_ID
       ,BUSINESS_GROUP_ID
       ,VALUE
       ,ASSIGNMENT_BUDGET_VALUE_ID
       ,EFFECTIVE_START_DATE
       ,EFFECTIVE_END_DATE
from per_assignment_budget_values_f
where rowid = p_rowid;
--
l_old_rec ben_abv_ler.g_abv_ler_rec;
l_new_rec ben_abv_ler.g_abv_ler_rec;
--
begin
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  -- get old record
  open get_old_abv(p_rowid);
  fetch get_old_abv into l_old_rec;
  close get_old_abv;
  -- get new record
  l_new_rec.assignment_id := p_assignment_id;
  l_new_rec.business_group_id := p_business_group_id;
  l_new_rec.value := p_value;
  l_new_rec.assignment_budget_value_id := p_assignment_budget_value_id;
********  l_new_rec.effective_start_date := p_effective_start_date;
  l_new_rec.effective_end_date := p_effective_end_date;   ******
  --
  ben_abv_ler.ler_chk(l_old_rec,l_new_rec);
  if g_debug then
    hr_utility.set_location('Leaving:'|| l_proc, 100);
  end if;
end asgn_budget_values;
********************************/

end ben_dt_trgr_handle;

/
