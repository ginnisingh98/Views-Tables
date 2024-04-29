--------------------------------------------------------
--  DDL for Package BEN_WHATIF_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_WHATIF_ELIG" AUTHID CURRENT_USER as
/* $Header: benwatif.pkh 115.8 2003/05/08 10:47:22 glingapp ship $ */

--
-- Global variables to keep the temporal values like compensation
-- as entered by the user on weatif form.
--
-- Variables to hold the compensation values.
--
 g_stat_comp         number := null;
 g_bnft_bal_comp     number := null;
 g_bal_comp          number := null;

--
-- Variables to hours worked.
--
 g_bnft_bal_hwf_val  number := null;
 g_bal_hwf_val       number := null;

 procedure p_rollback;

 procedure WATIF_ABSENCE_ATTENDANCES_API(
   p_person_id                      in  number
  ,p_ABSENCE_ATTENDANCE_TYPE_ID     in  varchar2
  ,p_ABS_ATTENDANCE_REASON_ID       in  varchar2
  ,p_DATE_END                       in  date
  ,p_DATE_START                     in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );



 procedure WATIF_ADDRESSES_API(
   p_person_id                      in  number
  ,p_POSTAL_CODE                    in  varchar2
  ,p_PRIMARY_FLAG                   in  varchar2
  ,p_REGION_2                       in  varchar2
  ,p_ADDRESS_TYPE                   in  varchar2
  ,p_DATE_FROM                      in  date
  ,p_DATE_TO                        in  date
  ,p_effective_date                 in  date
  );


 procedure WATIF_ALL_ASSIGNMENTS_F_API(
   p_person_id                      in  number
  ,p_PAY_BASIS_ID                   in number
  ,p_EMPLOYMENT_CATEGORY            in varchar2
  ,p_LABOUR_UNION_MEMBER_FLAG       in varchar2
  ,p_JOB_ID                         in number
  ,p_PAYROLL_ID                     in number
  ,p_PRIMARY_FLAG                   in varchar2
  ,p_LOCATION_ID                    in number
  ,p_CHANGE_REASON                  in varchar2
  ,p_ASSIGNMENT_TYPE                in varchar2
  ,p_ORGANIZATION_ID                in number
  ,p_POSITION_ID                    in number
  ,p_BARGAINING_UNIT_CODE           in varchar2
  ,p_NORMAL_HOURS                   in number
  ,p_FREQUENCY                      in varchar2
  ,p_ASSIGNMENT_STATUS_TYPE_ID      in number
  ,p_GRADE_ID                       in number
   ,p_PEOPLE_GROUP_ID               in  NUMBER
   ,p_HOURLY_SALARIED_CODE          in varchar2
   ,p_ASS_ATTRIBUTE_CATEGORY        in varchar2
   ,p_ASS_ATTRIBUTE1                in  VARCHAR2
   ,p_ASS_ATTRIBUTE10                in  VARCHAR2
   ,p_ASS_ATTRIBUTE11                in  VARCHAR2
   ,p_ASS_ATTRIBUTE12                in  VARCHAR2
   ,p_ASS_ATTRIBUTE13                in  VARCHAR2
   ,p_ASS_ATTRIBUTE14                in  VARCHAR2
   ,p_ASS_ATTRIBUTE15                in  VARCHAR2
   ,p_ASS_ATTRIBUTE16                in  VARCHAR2
   ,p_ASS_ATTRIBUTE17                in  VARCHAR2
   ,p_ASS_ATTRIBUTE18                in  VARCHAR2
   ,p_ASS_ATTRIBUTE19                in  VARCHAR2
   ,p_ASS_ATTRIBUTE2                in  VARCHAR2
   ,p_ASS_ATTRIBUTE20                in  VARCHAR2
   ,p_ASS_ATTRIBUTE21                in  VARCHAR2
   ,p_ASS_ATTRIBUTE22                in  VARCHAR2
   ,p_ASS_ATTRIBUTE23                in  VARCHAR2
   ,p_ASS_ATTRIBUTE24                in  VARCHAR2
   ,p_ASS_ATTRIBUTE25                in  VARCHAR2
   ,p_ASS_ATTRIBUTE26                in  VARCHAR2
   ,p_ASS_ATTRIBUTE27                in  VARCHAR2
   ,p_ASS_ATTRIBUTE28                in  VARCHAR2
   ,p_ASS_ATTRIBUTE29                in  VARCHAR2
   ,p_ASS_ATTRIBUTE3                in  VARCHAR2
   ,p_ASS_ATTRIBUTE30                in  VARCHAR2
   ,p_ASS_ATTRIBUTE4                in  VARCHAR2
   ,p_ASS_ATTRIBUTE5                in  VARCHAR2
   ,p_ASS_ATTRIBUTE6                in  VARCHAR2
   ,p_ASS_ATTRIBUTE7                in  VARCHAR2
   ,p_ASS_ATTRIBUTE8                in  VARCHAR2
   ,p_ASS_ATTRIBUTE9                in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 procedure WATIF_ALL_PEOPLE_F_API(
   p_person_id                      in  number
  ,p_STUDENT_STATUS                 in varchar2
  ,p_MARITAL_STATUS                 in varchar2
  ,p_DATE_OF_DEATH                  in date
  ,p_DATE_OF_BIRTH                  in date
  ,p_COORD_BEN_NO_CVG_FLAG          in varchar2
  ,p_ON_MILITARY_SERVICE            in varchar2
  ,p_REGISTERED_DISABLED_FLAG       in varchar2
  ,p_USES_TOBACCO_FLAG              in varchar2
  ,p_BENEFIT_GROUP_ID               in number
  ,p_PER_INFORMATION10              in varchar2
  ,p_COORD_BEN_MED_PLN_NO           in varchar2
  ,p_DPDNT_VLNTRY_SVCE_FLAG         in varchar2
  ,p_RECEIPT_OF_DEATH_CERT_DATE     in date
  ,p_sex			    in varchar2
   ,p_ATTRIBUTE1                     in VARCHAR2
   ,p_ATTRIBUTE10                    in VARCHAR2
   ,p_ATTRIBUTE11                    in VARCHAR2
   ,p_ATTRIBUTE12                    in VARCHAR2
   ,p_ATTRIBUTE13                    in VARCHAR2
   ,p_ATTRIBUTE14                    in VARCHAR2
   ,p_ATTRIBUTE15                    in VARCHAR2
   ,p_ATTRIBUTE16                    in VARCHAR2
   ,p_ATTRIBUTE17                    in VARCHAR2
   ,p_ATTRIBUTE18                    in VARCHAR2
   ,p_ATTRIBUTE19                    in VARCHAR2
   ,p_ATTRIBUTE2                     in VARCHAR2
   ,p_ATTRIBUTE20                    in VARCHAR2
   ,p_ATTRIBUTE21                    in VARCHAR2
   ,p_ATTRIBUTE22                    in VARCHAR2
   ,p_ATTRIBUTE23                    in VARCHAR2
   ,p_ATTRIBUTE24                    in VARCHAR2
   ,p_ATTRIBUTE25                    in VARCHAR2
   ,p_ATTRIBUTE26                    in VARCHAR2
   ,p_ATTRIBUTE27                    in VARCHAR2
   ,p_ATTRIBUTE28                    in VARCHAR2
   ,p_ATTRIBUTE29                    in VARCHAR2
   ,p_ATTRIBUTE3                     in VARCHAR2
   ,p_ATTRIBUTE30                    in VARCHAR2
   ,p_ATTRIBUTE4                     in VARCHAR2
   ,p_ATTRIBUTE5                     in VARCHAR2
   ,p_ATTRIBUTE6                     in VARCHAR2
   ,p_ATTRIBUTE7                     in VARCHAR2
   ,p_ATTRIBUTE8                     in VARCHAR2
   ,p_ATTRIBUTE9                     in VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 procedure WATIF_CONTACT_RELATIONSHIP_API(
   p_person_id                      in  number
  ,p_contact_person_id              in  number
  ,p_DATE_START                     in  date
  ,p_DATE_END                       in  date
  ,p_CONTACT_TYPE                   in  VARCHAR2
  ,p_PERSONAL_FLAG                  in  VARCHAR2
  ,p_START_LIFE_REASON_ID           in  NUMBER
  ,p_END_LIFE_REASON_ID             in  NUMBER
  ,p_RLTD_PER_RSDS_W_DSGNTR_FLAG    in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 procedure WATIF_PERIODS_OF_SERVICE_API(
   p_person_id                      in  number
  ,p_per_object_version_number      in  number
  ,p_DATE_START                     in  date
  ,p_LEAVING_REASON                 in  varchar2
  ,p_ADJUSTED_SVC_DATE              in  date
  ,p_ACTUAL_TERMINATION_DATE        in  date
  ,p_FINAL_PROCESS_DATE		    in  date
  ,p_ATTRIBUTE1                     in  VARCHAR2
  ,p_ATTRIBUTE2                     in  VARCHAR2
  ,p_ATTRIBUTE3                     in  VARCHAR2
  ,p_ATTRIBUTE4                     in  VARCHAR2
  ,p_ATTRIBUTE5                     in  VARCHAR2
  ,p_ATTRIBUTE6                     in  VARCHAR2
  ,p_ATTRIBUTE7                     in  VARCHAR2
  ,p_ATTRIBUTE8                     in  VARCHAR2
  ,p_ATTRIBUTE9                     in  VARCHAR2
  ,p_ATTRIBUTE10                    in  VARCHAR2
  ,p_ATTRIBUTE11                    in  VARCHAR2
  ,p_ATTRIBUTE12                    in  VARCHAR2
  ,p_ATTRIBUTE13                    in  VARCHAR2
  ,p_ATTRIBUTE14                    in  VARCHAR2
  ,p_ATTRIBUTE15                    in  VARCHAR2
  ,p_ATTRIBUTE16                    in  VARCHAR2
  ,p_ATTRIBUTE17                    in  VARCHAR2
  ,p_ATTRIBUTE18                    in  VARCHAR2
  ,p_ATTRIBUTE19                    in  VARCHAR2
  ,p_ATTRIBUTE20                    in  VARCHAR2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 procedure WATIF_PERSON_TYPE_USAGES_F_API(
   p_person_id                      in  number
  ,p_PERSON_TYPE_ID                 in  varchar2
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );


 procedure WATIF_PER_BNFTS_BAL_F_API(
   p_person_id                      in  number
  ,p_BNFTS_BAL_ID                   in  number
  ,p_VAL                            in  number
  ,p_EFFECTIVE_START_DATE           in  date
  ,p_EFFECTIVE_END_DATE             in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 procedure WATIF_PER_ASG_BUDG_VAL_F_API(
   p_person_id                      in  number
  ,p_ASSIGNMENT_BUDGET_VALUE_ID     in  number
  ,p_VALUE                          in  number
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );


 procedure WATIF_ELIG_CVRD_DPNT_F_API(
   p_person_id                      in  number
  ,p_CVG_STRT_DT                    in  date
  ,p_CVG_THRU_DT                    in  date
  ,p_EFFECTIVE_START_DATE           in  date
  ,p_EFFECTIVE_END_DATE             in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );


 procedure WATIF_CRT_ORDR_API(
   p_person_id                      in  number
  ,p_pl_id                          in  number
  ,p_CRT_ORDR_TYP_CD                in  varchar2
  ,p_APLS_PERD_STRTG_DT             in  date
  ,p_APLS_PERD_ENDG_DT              in  date
  ,p_business_group_id              in  number
  ,p_effective_date                 in  date
  );

 --
 procedure WATIF_TEMPORAL_LF_EVT_API(
   p_person_id                       in number
   ,p_business_group_id              in  number
   ,p_ler_id                         in  number
   ,p_temporal_lf_evt                in  varchar2
   ,p_lf_evt_ocrd_dt                 in  date
   ,p_effective_date                 in  date
   ,p_tpf_val                        in  number default null
   ,p_cmp_val                        in  number default null
   ,p_cmp_bnft_val                   in  number default null
   ,p_cmp_bal_val                    in  number default null
   ,p_hwf_val                        in  number default null
   ,p_hwf_bnft_val                   in  number default null
   );
--

--Bug 2831804 Qualification
 procedure WATIF_PER_QUALIFICATIONS_API(
    p_person_id                      in number
   ,p_qualification_type_id          in number
   ,p_title			     in varchar2
   ,p_start_date  		     in date
   ,p_end_date			     in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_business_group_id              in number
   ,p_effective_date                 in date
);
--Bug 2831804 Qualification

--Bug 2831804 Competence
 procedure WATIF_PER_COMPETENCE_API(
    p_person_id                      in number
   ,p_competence_id                  in number
   ,p_proficiency_level_id	     in number
   ,p_effective_date_from	     in date
   ,p_effective_date_to		     in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_business_group_id              in number
   ,p_effective_date                 in date
);
--Bug 2831804 Competence

--Bug 2831804 Performance

 procedure WATIF_PER_PERFORMANCE_API(
    p_person_id                      in number
   ,p_performance_rating             in varchar2
   ,p_event_id			     in number
   ,p_review_date		     in date
   ,p_attribute1		     in varchar2
   ,p_attribute2		     in varchar2
   ,p_attribute3		     in varchar2
   ,p_attribute4		     in varchar2
   ,p_attribute5         	     in varchar2
   ,p_attribute6		     in varchar2
   ,p_attribute7		     in varchar2
   ,p_attribute8		     in varchar2
   ,p_attribute9		     in varchar2
   ,p_attribute10		     in varchar2
   ,p_attribute11        	     in varchar2
   ,p_attribute12		     in varchar2
   ,p_attribute13		     in varchar2
   ,p_attribute14        	     in varchar2
   ,p_attribute15		     in varchar2
   ,p_attribute16		     in varchar2
   ,p_attribute17        	     in varchar2
   ,p_attribute18		     in varchar2
   ,p_attribute19		     in varchar2
   ,p_attribute20		     in varchar2
   ,p_attribute21		     in varchar2
   ,p_attribute22		     in varchar2
   ,p_attribute23		     in varchar2
   ,p_attribute24		     in varchar2
   ,p_attribute25         	     in varchar2
   ,p_attribute26		     in varchar2
   ,p_attribute27		     in varchar2
   ,p_attribute28		     in varchar2
   ,p_attribute29		     in varchar2
   ,p_attribute30		     in varchar2
);

--Bug 2831804 Performance


--Bug 2868775 Pay Proposal

procedure WATIF_PAY_PROPOSAL_API(
	    p_person_id                      in number
	   ,p_approved			     in varchar2
	   ,p_change_date                    in date
	   ,p_event_id                       in number
	   ,p_forced_ranking                 in number
	   ,p_last_change_date               in date
	   ,p_multiple_components            in varchar2
	   ,p_next_sal_review_date	     in date
	   ,p_next_perf_review_date	     in date
	   ,p_performance_rating             in varchar2
	   ,p_performance_review_id          in number
	   ,p_proposal_reason                in varchar2
	   ,p_proposed_salary_n              in number
	   ,p_review_date		     in date
	   ,p_attribute1		     in varchar2
	   ,p_attribute2		     in varchar2
	   ,p_attribute3		     in varchar2
	   ,p_attribute4		     in varchar2
	   ,p_attribute5         	     in varchar2
	   ,p_attribute6		     in varchar2
	   ,p_attribute7		     in varchar2
	   ,p_attribute8		     in varchar2
	   ,p_attribute9		     in varchar2
	   ,p_attribute10		     in varchar2
	   ,p_attribute11        	     in varchar2
	   ,p_attribute12		     in varchar2
	   ,p_attribute13		     in varchar2
	   ,p_attribute14        	     in varchar2
	   ,p_attribute15		     in varchar2
	   ,p_attribute16		     in varchar2
	   ,p_attribute17        	     in varchar2
	   ,p_attribute18		     in varchar2
	   ,p_attribute19		     in varchar2
	   ,p_attribute20		     in varchar2
	   ,p_business_group_id              in number
	   ,p_effective_date                 in date
	);

--Bug 2868775 Pay Proposal

 --
 -- Bug 3961/1182908 : Initialise any temporal globals before
 -- each run of the benmngle.
 --
 procedure p_init_watif_globals;
 --
END ben_whatif_elig;

 

/
