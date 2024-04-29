--------------------------------------------------------
--  DDL for Package PQH_ASG_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ASG_WRAPPER" AUTHID CURRENT_USER as
/* $Header: peasgmup.pkh 120.1 2005/11/21 02:46:38 ayegappa noship $ */
  -- PL/SQL table declaration
  TYPE p_asgt_id is table of number index by binary_integer;
  p_asg_id p_asgt_id;
  --
  FUNCTION show_worker_number
    (p_employee_number  IN VARCHAR2
    ,p_npw_number       IN VARCHAR2
    ) RETURN VARCHAR2;
  --
  FUNCTION Is_Person_Correct_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR ;
 --
  FUNCTION Is_Type_An_Applicant_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR;
  --
  FUNCTION Is_Type_A_System_Type
    (p_person_type_id            IN per_person_types.person_type_id%TYPE)
    RETURN CHAR;
  --
  FUNCTION Is_Org_In_Hierarchy
    (p_search_org_id IN hr_organization_units.organization_id%TYPE)
    RETURN CHAR;
  --
  FUNCTION Is_Org_A_Node
    (p_search_org_id IN hr_organization_units.organization_id%TYPE
    ,p_organization_structure_id IN per_org_structure_versions_v.organization_structure_id%TYPE)
    RETURN CHAR;
  --
  FUNCTION Is_Position_In_Hierarchy
    (p_search_pos_id IN hr_all_positions_f.position_id%TYPE)
    RETURN CHAR;
  --
  FUNCTION Is_Pos_A_Node
    (p_search_pos_id         IN per_positions.position_id%TYPE
    ,p_position_structure_id IN per_pos_structure_versions_v.position_structure_id%TYPE
    ,p_effective_date        IN DATE)
    RETURN CHAR;
  --
PROCEDURE update_assignment
    (p_validate                     IN     BOOLEAN  DEFAULT FALSE
    ,p_datetrack_update_mode        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_object_version_number        IN OUT NOCOPY NUMBER
    ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute21              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute22              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute23              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute24              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute25              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute26              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute27              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute28              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute29              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute30              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_ass_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_assignment_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_assignment_status_type_id    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_change_reason                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_collective_agreement_id      IN     NUMBER   DEFAULT hr_api.g_number
    ,p_contract_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_date_probation_end           IN     DATE     DEFAULT hr_api.g_date
    ,p_default_code_comb_id         IN     NUMBER   DEFAULT hr_api.g_number
    ,p_establishment_id             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_employment_category          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_frequency                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_grade_id                     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_internal_address_line        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_job_id                       IN     NUMBER   DEFAULT hr_api.g_number
    ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_location_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_manager_flag                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_normal_hours                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_pay_basis_id                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_payroll_id                   IN     NUMBER   DEFAULT hr_api.g_number
    ,p_perf_review_period           IN     NUMBER   DEFAULT hr_api.g_number
    ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_position_id                  IN     NUMBER   DEFAULT hr_api.g_number
    ,p_probation_period             IN     NUMBER   DEFAULT hr_api.g_number
    ,p_probation_unit               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_sal_review_period            IN     NUMBER   DEFAULT hr_api.g_number
    ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_set_of_books_id              IN     NUMBER   DEFAULT hr_api.g_number
    ,p_source_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_supervisor_id                IN     NUMBER   DEFAULT hr_api.g_number
    ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT hr_api.g_number
    ,p_time_normal_finish           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_time_normal_start            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_title                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_cag_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_comments                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_concat_segments              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_effective_date               IN     DATE     DEFAULT hr_api.g_date
    ,p_segment1                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment10                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment11                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment12                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment13                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment14                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment15                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment16                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment17                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment18                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment19                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment2                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment20                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment21                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment22                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment23                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment24                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment25                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment26                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment27                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment28                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment29                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment3                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment30                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment4                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment5                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment6                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment7                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment8                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_segment9                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment21                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment22                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment23                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment24                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment25                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment26                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment27                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment28                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment29                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment30                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_scl_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_grade_ladder_pgm_id          IN     NUMBER   DEFAULT hr_api.g_number
    ,p_recruiter_id                 IN     NUMBER   DEFAULT hr_api.g_number
    ,p_person_referred_by_id        IN     NUMBER   DEFAULT hr_api.g_number
    ,p_recruitment_activity_id      IN     NUMBER   DEFAULT hr_api.g_number
    ,p_source_organization_id       IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vacancy_id                   IN     NUMBER   DEFAULT hr_api.g_number
    ,p_application_id               IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vendor_assignment_number     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_employee_number       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_vendor_id                    IN     NUMBER   DEFAULT hr_api.g_number
    ,p_vendor_site_id               IN     NUMBER   DEFAULT hr_api.g_number
    ,p_project_title                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
    ,p_projected_assignment_end     IN     DATE     DEFAULT hr_api.g_date
    ,p_organization_id              IN OUT NOCOPY NUMBER
    ,p_concatenated_segments        IN OUT NOCOPY VARCHAR2
    ,p_special_ceiling_step_id      IN OUT NOCOPY NUMBER
    ,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
    ,p_comment_id                      OUT NOCOPY NUMBER
    ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
    ,p_effective_end_date              OUT NOCOPY DATE
    ,p_effective_start_date            OUT NOCOPY DATE
    ,p_no_managers_warning             OUT NOCOPY BOOLEAN
    ,p_other_manager_warning           OUT NOCOPY BOOLEAN
    ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
    ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
    ,p_entries_changed_warning         OUT NOCOPY VARCHAR2
    ,p_group_name                      OUT NOCOPY VARCHAR2
    ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
    ,p_people_group_id                 OUT NOCOPY NUMBER
    ,p_spp_delete_warning              OUT NOCOPY BOOLEAN
    ,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN  );
--
procedure upd_asg (
  p_ASS_ATTRIBUTE_CATEGORY       IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE1               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE10              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE11              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE12              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE13              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE14              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE15              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE16              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE17              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE18              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE19              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE2               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE20              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE21              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE22              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE23              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE24              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE25              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE26              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE27              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE28              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE29              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE3               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE30              IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE4               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE5               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE6               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE7               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE8               IN     VARCHAR2 ,
  p_ASS_ATTRIBUTE9               IN     VARCHAR2 ,
  p_ASSIGNMENT_ID                IN     NUMBER   ,
  p_ASSIGNMENT_NUMBER            IN     VARCHAR2 ,
  p_ASSIGNMENT_STATUS_TYPE_ID    IN     NUMBER   ,
  p_BARGAINING_UNIT_CODE         IN     VARCHAR2 ,
  p_CAGR_GRADE_DEF_ID            IN  OUT NOCOPY NUMBER   ,
  p_CAGR_ID_FLEX_NUM             IN     NUMBER   ,
  p_CHANGE_REASON                IN     VARCHAR2 ,
  p_COLLECTIVE_AGREEMENT_ID      IN     NUMBER   ,
  p_COMMENT_ID                      OUT NOCOPY NUMBER   ,
  p_CONTRACT_ID                  IN     NUMBER   ,
  p_DATE_PROBATION_END           IN     DATE     ,
  p_DEFAULT_CODE_COMB_ID         IN     NUMBER   ,
  p_ESTABLISHMENT_ID             IN     NUMBER   ,
  p_EMPLOYMENT_CATEGORY          IN     VARCHAR2 ,
  p_FREQUENCY                    IN     VARCHAR2 ,
  p_GRADE_ID                     IN     NUMBER  ,
  p_HOURLY_SALARIED_CODE         IN     VARCHAR2 ,
  p_INTERNAL_ADDRESS_LINE        IN     VARCHAR2 ,
  p_JOB_ID                       IN     NUMBER  ,
  p_LABOUR_UNION_MEMBER_FLAG     IN     VARCHAR2 ,
  p_LOCATION_ID                  IN     NUMBER  ,
  p_MANAGER_FLAG                 IN     VARCHAR2 ,
  p_NORMAL_HOURS                 IN     NUMBER   ,
  p_OBJECT_VERSION_NUMBER        IN OUT NOCOPY NUMBER   ,
  p_ORGANIZATION_ID              IN OUT NOCOPY NUMBER  ,
  p_PAY_BASIS_ID                 IN     NUMBER  ,
  p_PAYROLL_ID                   IN     NUMBER  ,
  p_PERF_REVIEW_PERIOD           IN     NUMBER   ,
  p_PERF_REVIEW_PERIOD_FREQUENCY IN     VARCHAR2 ,
  p_POSITION_ID                  IN     NUMBER  ,
  p_PROBATION_PERIOD             IN     NUMBER   ,
  p_PROBATION_UNIT               IN     VARCHAR2 ,
  p_SAL_REVIEW_PERIOD            IN     NUMBER   ,
  p_SAL_REVIEW_PERIOD_FREQUENCY  IN     VARCHAR2 ,
  p_SET_OF_BOOKS_ID              IN     NUMBER   ,
  p_SOFT_CODING_KEYFLEX_ID          OUT NOCOPY NUMBER   ,
  p_SOURCE_TYPE                  IN     VARCHAR2 ,
  p_SPECIAL_CEILING_STEP_ID      IN OUT NOCOPY NUMBER  ,
  p_SUPERVISOR_ID                IN     NUMBER   ,
  P_SUPERVISOR_ASSIGNMENT_ID     IN     NUMBER   ,
  p_TIME_NORMAL_FINISH           IN     VARCHAR2 ,
  p_TIME_NORMAL_START            IN     VARCHAR2 ,
  p_TITLE                        IN     VARCHAR2 ,
  p_ENTRIES_CHANGED_WARNING         OUT NOCOPY VARCHAR2,
  p_GROUP_NAME                      OUT NOCOPY VARCHAR2,
  p_ORG_NOW_NO_MANAGER_WARNING      OUT NOCOPY BOOLEAN ,
  p_PEOPLE_GROUP_ID                 OUT NOCOPY NUMBER  ,
  p_SPP_DELETE_WARNING              OUT NOCOPY BOOLEAN ,
  p_TAX_DISTRICT_CHANGED_WARNING    OUT NOCOPY BOOLEAN ,
  p_CAG_SEGMENT1                 IN     VARCHAR2 ,
  p_CAG_SEGMENT10                IN     VARCHAR2 ,
  p_CAG_SEGMENT11                IN     VARCHAR2 ,
  p_CAG_SEGMENT12                IN     VARCHAR2 ,
  p_CAG_SEGMENT13                IN     VARCHAR2 ,
  p_CAG_SEGMENT14                IN     VARCHAR2 ,
  p_CAG_SEGMENT15                IN     VARCHAR2 ,
  p_CAG_SEGMENT16                IN     VARCHAR2 ,
  p_CAG_SEGMENT17                IN     VARCHAR2 ,
  p_CAG_SEGMENT18                IN     VARCHAR2 ,
  p_CAG_SEGMENT19                IN     VARCHAR2 ,
  p_CAG_SEGMENT2                 IN     VARCHAR2 ,
  p_CAG_SEGMENT20                IN     VARCHAR2 ,
  p_CAG_SEGMENT3                 IN     VARCHAR2 ,
  p_CAG_SEGMENT4                 IN     VARCHAR2 ,
  p_CAG_SEGMENT5                 IN     VARCHAR2 ,
  p_CAG_SEGMENT6                 IN     VARCHAR2 ,
  p_CAG_SEGMENT7                 IN     VARCHAR2 ,
  p_CAG_SEGMENT8                 IN     VARCHAR2 ,
  p_CAG_SEGMENT9                 IN     VARCHAR2 ,
  p_CAGR_CONCATENATED_SEGMENTS      OUT NOCOPY VARCHAR2 ,
  p_COMMENTS                     IN     VARCHAR2 ,
  p_CONCAT_SEGMENTS              IN     VARCHAR2 ,
  p_CONCATENATED_SEGMENTS        IN OUT NOCOPY VARCHAR2 ,
  p_DATETRACK_UPDATE_MODE        IN     VARCHAR2 ,
  p_EFFECTIVE_DATE               IN     DATE     ,
  p_EFFECTIVE_END_DATE              OUT NOCOPY DATE     ,
  p_EFFECTIVE_START_DATE            OUT NOCOPY DATE     ,
  p_NO_MANAGERS_WARNING             OUT NOCOPY BOOLEAN  ,
  p_OTHER_MANAGER_WARNING           OUT NOCOPY BOOLEAN  ,
  p_GSP_POST_PROCESS_WARNING        OUT NOCOPY VARCHAR2 ,
  p_SEGMENT1                     IN     VARCHAR2 ,
  p_SEGMENT10                    IN     VARCHAR2 ,
  p_SEGMENT11                    IN     VARCHAR2 ,
  p_SEGMENT12                    IN     VARCHAR2 ,
  p_SEGMENT13                    IN     VARCHAR2 ,
  p_SEGMENT14                    IN     VARCHAR2 ,
  p_SEGMENT15                    IN     VARCHAR2 ,
  p_SEGMENT16                    IN     VARCHAR2 ,
  p_SEGMENT17                    IN     VARCHAR2 ,
  p_SEGMENT18                    IN     VARCHAR2 ,
  p_SEGMENT19                    IN     VARCHAR2 ,
  p_SEGMENT2                     IN     VARCHAR2 ,
  p_SEGMENT20                    IN     VARCHAR2 ,
  p_SEGMENT21                    IN     VARCHAR2 ,
  p_SEGMENT22                    IN     VARCHAR2 ,
  p_SEGMENT23                    IN     VARCHAR2 ,
  p_SEGMENT24                    IN     VARCHAR2 ,
  p_SEGMENT25                    IN     VARCHAR2 ,
  p_SEGMENT26                    IN     VARCHAR2 ,
  p_SEGMENT27                    IN     VARCHAR2 ,
  p_SEGMENT28                    IN     VARCHAR2 ,
  p_SEGMENT29                    IN     VARCHAR2 ,
  p_SEGMENT3                     IN     VARCHAR2 ,
  p_SEGMENT30                    IN     VARCHAR2 ,
  p_SEGMENT4                     IN     VARCHAR2 ,
  p_SEGMENT5                     IN     VARCHAR2 ,
  p_SEGMENT6                     IN     VARCHAR2 ,
  p_SEGMENT7                     IN     VARCHAR2 ,
  p_SEGMENT8                     IN     VARCHAR2 ,
  p_SEGMENT9                     IN     VARCHAR2 ,
  p_SCL_SEGMENT1                 IN     VARCHAR2 ,
  p_SCL_SEGMENT10                IN     VARCHAR2 ,
  p_SCL_SEGMENT11                IN     VARCHAR2 ,
  p_SCL_SEGMENT12                IN     VARCHAR2 ,
  p_SCL_SEGMENT13                IN     VARCHAR2 ,
  p_SCL_SEGMENT14                IN     VARCHAR2 ,
  p_SCL_SEGMENT15                IN     VARCHAR2 ,
  p_SCL_SEGMENT16                IN     VARCHAR2 ,
  p_SCL_SEGMENT17                IN     VARCHAR2 ,
  p_SCL_SEGMENT18                IN     VARCHAR2 ,
  p_SCL_SEGMENT19                IN     VARCHAR2 ,
  p_SCL_SEGMENT2                 IN     VARCHAR2 ,
  p_SCL_SEGMENT20                IN     VARCHAR2 ,
  p_SCL_SEGMENT21                IN     VARCHAR2 ,
  p_SCL_SEGMENT22                IN     VARCHAR2 ,
  p_SCL_SEGMENT23                IN     VARCHAR2 ,
  p_SCL_SEGMENT24                IN     VARCHAR2 ,
  p_SCL_SEGMENT25                IN     VARCHAR2 ,
  p_SCL_SEGMENT26                IN     VARCHAR2 ,
  p_SCL_SEGMENT27                IN     VARCHAR2 ,
  p_SCL_SEGMENT28                IN     VARCHAR2 ,
  p_SCL_SEGMENT29                IN     VARCHAR2 ,
  p_SCL_SEGMENT3                 IN     VARCHAR2 ,
  p_SCL_SEGMENT30                IN     VARCHAR2 ,
  p_SCL_SEGMENT4                 IN     VARCHAR2 ,
  p_SCL_SEGMENT5                 IN     VARCHAR2 ,
  p_SCL_SEGMENT6                 IN     VARCHAR2 ,
  p_SCL_SEGMENT7                 IN     VARCHAR2 ,
  p_SCL_SEGMENT8                 IN     VARCHAR2 ,
  p_SCL_SEGMENT9                 IN     VARCHAR2 ,
  p_GRADE_LADDER_PGM_ID          IN     NUMBER   ,
  p_VALIDATE                     IN     BOOLEAN) ;
  --
PROCEDURE update_applicant_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_recruiter_id                 in     number   default hr_api.g_number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_person_referred_by_id        in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT hr_api.g_number
  ,p_special_ceiling_step_id      in     number   default hr_api.g_number
  ,p_recruitment_activity_id      in     number   default hr_api.g_number
  ,p_source_organization_id       in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_vacancy_id                   in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_application_id               in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment21                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment22                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment23                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment24                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment25                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment26                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment27                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment28                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment29                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment30                in     varchar2 default hr_api.g_varchar2
  ,p_concatenated_segments        in out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment21                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment22                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment23                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment24                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment25                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment26                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment27                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment28                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment29                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment30                in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number   default hr_api.g_number
  ,p_establishment_id             in     number   default hr_api.g_number
  ,p_collective_agreement_id      in     number   default hr_api.g_number
  ,p_cagr_id_flex_num             in     number   default hr_api.g_number
  ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_grade_ladder_pgm_id          in     number   default hr_api.g_number
  ,p_cagr_grade_def_id            in  out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date);
  --
end;

 

/
