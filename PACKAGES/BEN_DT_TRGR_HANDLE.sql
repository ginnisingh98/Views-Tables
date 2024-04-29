--------------------------------------------------------
--  DDL for Package BEN_DT_TRGR_HANDLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DT_TRGR_HANDLE" AUTHID CURRENT_USER as
/*$Header: bendttrg.pkh 120.1 2005/06/01 11:52:20 ikasire noship $*/
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
);
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
);
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
  );
/*
procedure person_type_usages(p_rowid in VARCHAR2
,p_person_id IN NUMBER
,p_person_type_id IN NUMBER
-- ,p_effective_start_date in DATE
--p_effective_end_date in DATE
);
*/
procedure periods_of_service
(p_rowid              in VARCHAR2
,p_person_id          IN NUMBER
,p_pds_atd            IN date
,p_pds_leaving_reason in VARCHAR2
,p_pds_fpd            IN date
,p_pds_old_atd        IN date default null
);
procedure bnfts_bal
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_val                IN NUMBER
,p_bnfts_bal_id       in NUMBER
);
--
procedure bnfts_bal
(p_rowid              in VARCHAR2
,p_per_bnfts_bal_id   in NUMBER
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_val                IN NUMBER
,p_bnfts_bal_id       in NUMBER
);

procedure elig_cvrd_dpnt
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_dpnt_person_id     IN NUMBER
,p_prtt_enrt_rslt_id IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_cvg_strt_dt        IN DATE
,p_cvg_thru_dt        in DATE
,p_ovrdn_flag         in VARCHAR2
,p_ovrdn_thru_dt      in DATE
);
--
procedure elig_cvrd_dpnt
(p_rowid              in VARCHAR2
,p_elig_cvrd_dpnt_id  in number
,p_business_group_id  IN NUMBER
,p_dpnt_person_id     IN NUMBER
,p_prtt_enrt_rslt_id IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
,p_cvg_strt_dt        IN DATE
,p_cvg_thru_dt        in DATE
,p_ovrdn_flag         in VARCHAR2
,p_ovrdn_thru_dt      in DATE
);

procedure prtt_enrt_rslt
(p_rowid              in VARCHAR2
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_enrt_cvg_strt_dt   in DATE
,p_enrt_cvg_thru_dt   in DATE
,p_bnft_amt                IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
);
--
procedure prtt_enrt_rslt
(p_rowid              in VARCHAR2
,p_prtt_enrt_rslt_id  in number
,p_business_group_id  IN NUMBER
,p_person_id          IN NUMBER
,p_enrt_cvg_strt_dt   in DATE
,p_enrt_cvg_thru_dt   in DATE
,p_bnft_amt                IN NUMBER
,p_effective_start_date in DATE
,p_effective_end_date in DATE
);

--procedure elem_entry_values
--  (p_rowid in VARCHAR2
--  ,p_element_entry_value_id IN NUMBER
--  ,p_screen_entry_value IN VARCHAR2
--);

--procedure asgn_budget_values
--  (p_rowid in VARCHAR2
--  ,p_assignment_id IN NUMBER
--  ,p_business_group_id  IN NUMBER
--  ,p_value IN NUMBER
--  ,p_assignment_budget_value_id IN NUMBER
--/***  ,effective_start_date DATE
--  ,effective_end_date DATE  ***/
--);

end  ben_dt_trgr_handle;

 

/
