--------------------------------------------------------
--  DDL for Package IGS_PS_GENERIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GENERIC_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPS89S.pls 120.3 2006/01/17 05:53:33 sommukhe noship $ */
/*#
 * A public API to import data from external system to OSS for unit section and its details. This API to be used to import scheduled data to OSS, also can be used for generic imports of unit section and details.
 * This can also this can be used to import legacy related data.
 * @rep:scope public
 * @rep:product IGS
 * @rep:displayname Program Structure and Planning Import
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGS_UNIT
 */

/***********************************************************************************************
Created By:         Sanjeeb Rakshit
Date Created By:    20-Nov-2002
Purpose:            A public API to import data from external system to OSS is declared along with
                    several PL-SQL table types to be used in the API.
Known limitations,enhancements,remarks:

Change History

Who         When           What

***********************************************************************************************/
-- Start of Comments
-- API Name               : psp_import
-- Type                   : Public
-- Pre-reqs               : None
-- Function               : Imports Unit Section and occurrence related data from external System to OSS
-- Parameters
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- OUT                      x_return_status
-- OUT                      x_msg_count
-- OUT                      x_msg_data
-- IN OUT                   p_usec_tbl
--                              This parameter holds values for unit section table
-- IN OUT                   p_usec_gs_tbl
--                              This parameter holds values for unit section grading schema table
-- IN OUT                   p_uso_tbl
--                              This parameter holds values for unit section occurrence table
-- IN OUT                   p_unit_ref_tbl
--                              This parameter holds values for unit/unit section/unit section occurrence reference table
-- IN OUT                   p_uso_ins_tbl
--                              This parameter holds values for unit section occurrence instructor table
-- IN OUT                   p_usec_occurs_facility_tbl
--                              This parameter holds values for unit section occurrence facilities table
-- IN OUT                   p_usec_teach_resp_ovrd_tbl
--                              This parameter holds values for unit section Teaching Responsibility Override table
-- IN OUT                   p_usec_notes_tbl
--                              This parameter holds values for unit section Notes table
-- IN OUT                   p_usec_assmnt_tbl
--                              This parameter holds values for unit section Assessment(Exam Details) table
-- IN OUT                   p_usec_plus_hr_tbl
--                              This parameter holds values for unit section Plus Hour table
-- IN OUT                   p_usec_cat_tbl
--                              This parameter holds values for unit section Categories table
-- IN OUT                   p_usec_rule_tbl
--                              This parameter holds values for unit section Rules table
-- IN OUT                   p_usec_cross_group_tbl
--                              This parameter holds values for unit section Cross Listed Group table
-- IN OUT                   p_usec_meet_with_tbl
--                              This parameter holds values for unit section MeetWith Class Group table
-- IN OUT                   p_usec_waitlist_tbl
--                              This parameter holds values for unit section Waitlist table
-- IN OUT                   p_usec_res_seat_tbl
--                              This parameter holds values for unit section Reserve Seating table
-- IN OUT                   p_usec_sp_fee_tbl
--                              This parameter holds values for unit section special fees table
-- IN OUT                   p_usec_ret_tbl
--                              This parameter holds values for unit section Retention table
-- IN OUT                   p_usec_ret_dtl_tbl
--                              This parameter holds values for unit section Retention Details table
-- IN OUT                   p_usec_enr_dead_tbl
--                              This parameter holds values for unit section Enrollment Deadline table
-- IN OUT                   p_usec_enr_dis_tbl
--                              This parameter holds values for unit section Discontinuation Deadline table
-- IN OUT                   p_usec_teach_resp_tbl
--                              This parameter holds values for unit section Teaching Responsibility (update only) table
-- IN OUT                   p_usec_ass_item_grp_tbl
--                              This parameter holds values for unit section Assessment Item Group table
-- IN OUT                   p_usec_ass_item_tbl
--                              This parameter holds values for unit section Assessment Item table
-- OUT                      p_usec_status
--                              This parameter returns the import status of unit section table
-- OUT                      p_usec_gs_status
--                              This parameter returns the import status of unit section grading schema table
-- OUT                      p_uso_status
--                              This parameter returns the import status of unit section occurrence table
-- OUT                      p_uso_ins_status
--                              This parameter returns the import status of unit section instructor table
-- OUT                      p_uso_facility_status
--                              This parameter returns the import status of unit section facility table
-- OUT                      p_unit_ref_status
--                              This parameter returns the import status of unit section/unit section occurrence reference code table
-- OUT                      p_usec_teach_resp_ovrd_status
--                              This parameter returns the import status of unit section teaching responsibility override table
-- OUT                      p_usec_notes_status
--                              This parameter returns the import status of unit section Note table
-- OUT                      p_usec_assmnt_status
--                              This parameter returns the import status of unit section Assessment table
-- OUT                      p_usec_plus_hr_status
--                              This parameter returns the import status of unit section plus hour table
-- OUT                      p_usec_cat_status
--                              This parameter returns the import status of unit section categories table
-- OUT                      p_usec_rule_status
--                              This parameter returns the import status of unit section rules table
-- OUT                      p_usec_cross_group_status
--                              This parameter returns the import status of unit section cross listed group table
-- OUT                      p_usec_meet_with_status
--                              This parameter returns the import status of unit section MeetWith listed group table
-- OUT                      p_usec_waitlist_status
--                              This parameter returns the import status of unit section waitlist table
-- OUT                      p_usec_res_seat_status
--                              This parameter returns the import status of unit section Reserve Seating table
-- OUT                      p_usec_sp_fee_status
--                              This parameter returns the import status of unit section special fees table
-- OUT                      p_usec_ret_status
--                              This parameter returns the import status of unit section retention table
-- OUT                      p_usec_ret_dtl_status
--                              This parameter returns the import status of unit section retention details table
-- OUT                      p_usec_enr_dead_status
--                              This parameter returns the import status of unit section deadline table
-- OUT                      p_usec_enr_dis_status
--                              This parameter returns the import status of unit section discontinuation table
-- OUT                      p_usec_teach_resp_status
--                              This parameter returns the import status of unit section teaching responsibility table
-- OUT                      p_usec_ass_item_grp_status
--                              This parameter returns the import status of unit section assessment items group table
-- OUT                      p_usec_ass_item_status
--                              This parameter returns the import status of unit section assessment items table


-- Version: Current Version  1.0
--          Previous Version
--          Initial Version  1.0
-- End of Comments


/*********************** Unit Version Record ************************/

  TYPE unit_ver_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_ver_all.unit_cd%type,
    version_number                              igs_ps_unit_ver_all.version_number%type,
    start_dt                                    igs_ps_unit_ver_all.start_dt%type,
    review_dt                                   igs_ps_unit_ver_all.review_dt%type,
    expiry_dt                                   igs_ps_unit_ver_all.expiry_dt%type,
    end_dt                                      igs_ps_unit_ver_all.end_dt%type,
    unit_status                                 igs_ps_unit_ver_all.unit_status%type,
    title                                       igs_ps_unit_ver_all.title%type,
    short_title                                 igs_ps_unit_ver_all.short_title%type,
    title_override_ind                          igs_ps_unit_ver_all.title_override_ind%type,
    abbreviation                                igs_ps_unit_ver_all.abbreviation%type,
    unit_level                                  igs_ps_unit_ver_all.unit_level%type,
    credit_point_descriptor                     igs_ps_unit_ver_all.credit_point_descriptor%type,
    enrolled_credit_points                      igs_ps_unit_ver_all.enrolled_credit_points%type,
    points_override_ind                         igs_ps_unit_ver_all. points_override_ind%type,
    supp_exam_permitted_ind                     igs_ps_unit_ver_all.supp_exam_permitted_ind%type,
    coord_person_number                         igs_pe_person_base_v.person_number%type,
    owner_org_unit_cd                           igs_ps_unit_ver_all.owner_org_unit_cd%type,
    award_course_only_ind                       igs_ps_unit_ver_all.award_course_only_ind%type,
    research_unit_ind                           igs_ps_unit_ver_all.research_unit_ind%type,
    industrial_ind                              igs_ps_unit_ver_all.industrial_ind%type,
    practical_ind                               igs_ps_unit_ver_all.practical_ind%type,
    repeatable_ind                              igs_ps_unit_ver_all.repeatable_ind%type,
    assessable_ind                              igs_ps_unit_ver_all.assessable_ind%type,
    achievable_credit_points                    igs_ps_unit_ver_all.achievable_credit_points%type,
    points_increment                            igs_ps_unit_ver_all.points_increment%type,
    points_min                                  igs_ps_unit_ver_all.points_min%type,
    points_max                                  igs_ps_unit_ver_all.points_max%type,
    unit_int_course_level_cd                    igs_ps_unit_ver_all.unit_int_course_level_cd%type,
    subtitle_modifiable_flag                    igs_ps_unit_ver_all.subtitle_modifiable_flag%type,
    approval_date                               igs_ps_unit_ver_all.approval_date%type,
    lecture_credit_points                       igs_ps_unit_ver_all.lecture_credit_points%type,
    lab_credit_points                           igs_ps_unit_ver_all.lab_credit_points%type,
    other_credit_points                         igs_ps_unit_ver_all.other_credit_points%type,
    clock_hours                                 igs_ps_unit_ver_all.clock_hours%type,
    work_load_cp_lecture                        igs_ps_unit_ver_all.work_load_cp_lecture%type,
    work_load_cp_lab                            igs_ps_unit_ver_all.work_load_cp_lab%type,
    continuing_education_units                  igs_ps_unit_ver_all.continuing_education_units%type,
    enrollment_expected                         igs_ps_unit_ver_all.enrollment_expected%type,
    enrollment_minimum                          igs_ps_unit_ver_all.enrollment_minimum%type,
    enrollment_maximum                          igs_ps_unit_ver_all.enrollment_maximum%type,
    advance_maximum                             igs_ps_unit_ver_all.advance_maximum%type,
    state_financial_aid                         igs_ps_unit_ver_all.state_financial_aid%type,
    federal_financial_aid                       igs_ps_unit_ver_all.federal_financial_aid%type,
    institutional_financial_aid                 igs_ps_unit_ver_all.institutional_financial_aid%type,
    same_teaching_period                        igs_ps_unit_ver_all.same_teaching_period%type,
    max_repeats_for_credit                      igs_ps_unit_ver_all.max_repeats_for_credit%type,
    max_repeats_for_funding                     igs_ps_unit_ver_all.max_repeats_for_funding%type,
    max_repeat_credit_points                    igs_ps_unit_ver_all.max_repeat_credit_points%type,
    same_teach_period_repeats                   igs_ps_unit_ver_all.same_teach_period_repeats%type,
    same_teach_period_repeats_cp                igs_ps_unit_ver_all.same_teach_period_repeats_cp%type,
    attribute_category                          igs_ps_unit_ver_all.attribute_category%type,
    attribute1                                  igs_ps_unit_ver_all.attribute1%type,
    attribute2                                  igs_ps_unit_ver_all.attribute2%type,
    attribute3                                  igs_ps_unit_ver_all.attribute3%type,
    attribute4                                  igs_ps_unit_ver_all.attribute4%type,
    attribute5                                  igs_ps_unit_ver_all.attribute5%type,
    attribute6                                  igs_ps_unit_ver_all.attribute6%type,
    attribute7                                  igs_ps_unit_ver_all.attribute7%type,
    attribute8                                  igs_ps_unit_ver_all.attribute8%type,
    attribute9                                  igs_ps_unit_ver_all.attribute9%type,
    attribute10                                 igs_ps_unit_ver_all.attribute10%type,
    attribute11                                 igs_ps_unit_ver_all.attribute11%type,
    attribute12                                 igs_ps_unit_ver_all.attribute12%type,
    attribute13                                 igs_ps_unit_ver_all.attribute13%type,
    attribute14                                 igs_ps_unit_ver_all.attribute14%type,
    attribute15                                 igs_ps_unit_ver_all.attribute15%type,
    attribute16                                 igs_ps_unit_ver_all.attribute16%type,
    attribute17                                 igs_ps_unit_ver_all.attribute17%type,
    attribute18                                 igs_ps_unit_ver_all.attribute18%type,
    attribute19                                 igs_ps_unit_ver_all.attribute19%type,
    attribute20                                 igs_ps_unit_ver_all.attribute20%type,
    ivr_enrol_ind                               igs_ps_unit_ver_all.ivr_enrol_ind%type,
    ss_enrol_ind                                igs_ps_unit_ver_all.ss_enrol_ind%type,
    work_load_other                             igs_ps_unit_ver_all.work_load_other%type,
    contact_hrs_lecture                         igs_ps_unit_ver_all.contact_hrs_lecture%type,
    contact_hrs_lab                             igs_ps_unit_ver_all.contact_hrs_lab%type,
    contact_hrs_other                           igs_ps_unit_ver_all.contact_hrs_other%type,
    non_schd_required_hrs                       igs_ps_unit_ver_all.non_schd_required_hrs%type,
    exclude_from_max_cp_limit                   igs_ps_unit_ver_all.exclude_from_max_cp_limit%type,
    record_exclusion_flag                       igs_ps_unit_ver_all.record_exclusion_flag%type,
    ss_display_ind                              igs_ps_unit_ver_all.ss_display_ind%type,
    enrol_load_alt_cd                           igs_ca_inst_all.alternate_code%type,
    offer_load_alt_cd                           igs_ca_inst_all.alternate_code%type,
    override_enrollment_max                     igs_ps_unit_ver_all.override_enrollment_max%type,
    repeat_code                                 igs_ps_rpt_fmly_all.repeat_code%type,
    level_code                                  igs_ps_unit_type_lvl.level_code%type,
    special_permission_ind                      igs_ps_unit_ver_all.special_permission_ind%type,
    rev_account_cd                              igs_ps_unit_ver_all.rev_account_cd%type,
    claimable_hours                             igs_ps_unit_ver_all.claimable_hours%type,
    anon_unit_grading_ind                       igs_ps_unit_ver_all.anon_unit_grading_ind%type,
    anon_assess_grading_ind                     igs_ps_unit_ver_all.anon_assess_grading_ind%type,
    subtitle                                    igs_ps_unit_subtitle.subtitle%type,
    subtitle_approved_ind                       igs_ps_unit_subtitle.approved_ind%type,
    subtitle_closed_ind                         igs_ps_unit_subtitle.closed_ind%type,
    curriculum_id                               igs_ps_unt_crclm_all.curriculum_id%type,
    curriculum_description                      igs_ps_unt_crclm_all.description%type,
    curriculum_closed_ind                       igs_ps_unt_crclm_all.closed_ind%type,
    auditable_ind                               igs_ps_unit_ver_all.auditable_ind%type,
    audit_permission_ind                        igs_ps_unit_ver_all.audit_permission_ind%type,
    max_auditors_allowed                        igs_ps_unit_ver_all.max_auditors_allowed%type,
    billing_credit_points                       igs_ps_unit_ver_all.billing_credit_points%type,
    ovrd_wkld_val_flag                          igs_ps_unit_ver_all.ovrd_wkld_val_flag%type,
    workload_val_code                           igs_ps_unit_ver_all.workload_val_code%type,
    billing_hrs                                 igs_ps_unit_ver_all.billing_hrs%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );



/*********************** Teaching Responsibility ************************/

  TYPE unit_tr_rec_type IS RECORD (
    unit_cd                                     igs_ps_tch_resp.unit_cd%type,
    version_number                              igs_ps_tch_resp.version_number%type,
    org_unit_cd                                 igs_ps_tch_resp.org_unit_cd%type,
    percentage                                  igs_ps_tch_resp.percentage%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

  TYPE unit_tr_tbl_type IS TABLE OF unit_tr_rec_type INDEX BY BINARY_INTEGER;

/*********************** Unit Discplines ************************/

  TYPE unit_dscp_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_dscp.unit_cd%type,
    version_number                              igs_ps_unit_dscp.version_number%type,
    discipline_group_cd                         igs_ps_unit_dscp.discipline_group_cd%type,
    percentage                                  igs_ps_unit_dscp.percentage%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

  TYPE unit_dscp_tbl_type IS TABLE OF unit_dscp_rec_type INDEX BY BINARY_INTEGER;

  /*********************** Unit Grading Schema ************************/

  TYPE unit_gs_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_grd_schm.unit_code%type,
    version_number                              igs_ps_unit_grd_schm.unit_version_number%type,
    grading_schema_code                         igs_ps_unit_grd_schm.grading_schema_code%type,
    grd_schm_version_number                     igs_ps_unit_grd_schm.grd_schm_version_number%type,
    default_flag                                igs_ps_unit_grd_schm.default_flag%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

  TYPE unit_gs_tbl_type IS TABLE OF unit_gs_rec_type INDEX BY BINARY_INTEGER;

/*********************** Unit Sections ************************/

  TYPE usec_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_ofr_opt_all.unit_cd%type,
    version_number                              igs_ps_unit_ofr_opt_all.version_number%type,
    teach_cal_alternate_code                    igs_ca_inst_all.alternate_code%type,
    location_cd                                 igs_ps_unit_ofr_opt_all.location_cd%type,
    unit_class                                  igs_ps_unit_ofr_opt_all.unit_class%type,
    ivrs_available_ind                          igs_ps_unit_ofr_opt_all.ivrs_available_ind%type,
    call_number                                 igs_ps_unit_ofr_opt_all.call_number%type,
    unit_section_status                         igs_ps_unit_ofr_opt_all.unit_section_status%type,
    unit_section_start_date                     igs_ps_unit_ofr_opt_all.unit_section_start_date%type,
    unit_section_end_date                       igs_ps_unit_ofr_opt_all.unit_section_end_date%type,
    offered_ind                                 igs_ps_unit_ofr_opt_all.offered_ind%type,
    state_financial_aid                         igs_ps_unit_ofr_opt_all.state_financial_aid%type,
    grading_schema_prcdnce_ind                  igs_ps_unit_ofr_opt_all.grading_schema_prcdnce_ind%type,
    federal_financial_aid                       igs_ps_unit_ofr_opt_all.federal_financial_aid%type,
    unit_quota                                  igs_ps_unit_ofr_opt_all.unit_quota%type,
    unit_quota_reserved_places                  igs_ps_unit_ofr_opt_all.unit_quota_reserved_places%type,
    institutional_financial_aid                 igs_ps_unit_ofr_opt_all.institutional_financial_aid%type,
    grading_schema_cd                           igs_ps_unit_ofr_opt_all.grading_schema_cd%type,
    gs_version_number                           igs_ps_unit_ofr_opt_all.gs_version_number%type,
    unit_contact_number                         igs_pe_person_base_v.person_number%type,
    ss_enrol_ind                                igs_ps_unit_ofr_opt_all.ss_enrol_ind%type,
    owner_org_unit_cd                           igs_ps_unit_ofr_opt_all.owner_org_unit_cd%type,
    attendance_required_ind                     igs_ps_unit_ofr_opt_all.attendance_required_ind%type,
    reserved_seating_allowed                    igs_ps_unit_ofr_opt_all.reserved_seating_allowed%type,
    special_permission_ind                      igs_ps_unit_ofr_opt_all.special_permission_ind%type,
    ss_display_ind                              igs_ps_unit_ofr_opt_all.ss_display_ind%type,
    rev_account_cd                              igs_ps_unit_ofr_opt_all.rev_account_cd%type,
    anon_unit_grading_ind                       igs_ps_unit_ofr_opt_all.anon_unit_grading_ind%type,
    anon_assess_grading_ind                     igs_ps_unit_ofr_opt_all.anon_assess_grading_ind%type,
    non_std_usec_ind                            igs_ps_unit_ofr_opt_all.non_std_usec_ind%type,
    auditable_ind                               igs_ps_unit_ofr_opt_all.auditable_ind%type,
    audit_permission_ind                        igs_ps_unit_ofr_opt_all.audit_permission_ind%type,
    waitlist_allowed                            igs_ps_unit_ofr_pat_all.waitlist_allowed%type,
    max_students_per_waitlist                   igs_ps_unit_ofr_pat_all.max_students_per_waitlist%type,
    minimum_credit_points                       igs_ps_usec_cps.minimum_credit_points%type,
    maximum_credit_points                       igs_ps_usec_cps.maximum_credit_points%type,
    variable_increment                          igs_ps_usec_cps.variable_increment%type,
    lecture_credit_points                       igs_ps_usec_cps.lecture_credit_points%type,
    lab_credit_points                           igs_ps_usec_cps.lab_credit_points%type,
    other_credit_points                         igs_ps_usec_cps.other_credit_points%type,
    clock_hours                                 igs_ps_usec_cps.clock_hours%type,
    work_load_cp_lecture                        igs_ps_usec_cps.work_load_cp_lecture%type,
    work_load_cp_lab                            igs_ps_usec_cps.work_load_cp_lab%type,
    continuing_education_units                  igs_ps_usec_cps.continuing_education_units%type,
    work_load_other                             igs_ps_usec_cps.work_load_other%type,
    contact_hrs_lecture                         igs_ps_usec_cps.contact_hrs_lecture%type,
    contact_hrs_lab                             igs_ps_usec_cps.contact_hrs_lab%type,
    contact_hrs_other                           igs_ps_usec_cps.contact_hrs_other%type,
    non_schd_required_hrs                       igs_ps_usec_cps.non_schd_required_hrs%type,
    exclude_from_max_cp_limit                   igs_ps_usec_cps.exclude_from_max_cp_limit%type,
    claimable_hours                             igs_ps_usec_cps.claimable_hours%type,
    achievable_credit_points                    igs_ps_usec_cps.achievable_credit_points%TYPE,
    enrolled_credit_points                      igs_ps_usec_cps.enrolled_credit_points%TYPE,
    billing_credit_points                       igs_ps_usec_cps.billing_credit_points%TYPE,
    reference_subtitle                          igs_ps_unit_subtitle.subtitle%type,
    reference_short_title                       igs_ps_usec_ref.short_title%type,
    reference_subtitle_mod_flag                 igs_ps_usec_ref.subtitle_modifiable_flag%type,
    reference_class_sch_excl_flag               igs_ps_usec_ref.class_schedule_exclusion_flag%type,
    reference_rec_exclusion_flag                igs_ps_usec_ref.record_exclusion_flag%type,
    reference_title                             igs_ps_usec_ref.title%type,
    reference_attribute_category                igs_ps_usec_ref.attribute_category%type,
    reference_attribute1                        igs_ps_usec_ref.attribute1%type,
    reference_attribute2                        igs_ps_usec_ref.attribute2%type,
    reference_attribute3                        igs_ps_usec_ref.attribute3%type,
    reference_attribute4                        igs_ps_usec_ref.attribute4%type,
    reference_attribute5                        igs_ps_usec_ref.attribute5%type,
    reference_attribute6                        igs_ps_usec_ref.attribute6%type,
    reference_attribute7                        igs_ps_usec_ref.attribute7%type,
    reference_attribute8                        igs_ps_usec_ref.attribute8%type,
    reference_attribute9                        igs_ps_usec_ref.attribute9%type,
    reference_attribute10                       igs_ps_usec_ref.attribute10%type,
    reference_attribute11                       igs_ps_usec_ref.attribute11%type,
    reference_attribute12                       igs_ps_usec_ref.attribute12%type,
    reference_attribute13                       igs_ps_usec_ref.attribute13%type,
    reference_attribute14                       igs_ps_usec_ref.attribute14%type,
    reference_attribute15                       igs_ps_usec_ref.attribute15%type,
    reference_attribute16                       igs_ps_usec_ref.attribute16%type,
    reference_attribute17                       igs_ps_usec_ref.attribute17%type,
    reference_attribute18                       igs_ps_usec_ref.attribute18%type,
    reference_attribute19                       igs_ps_usec_ref.attribute19%type,
    reference_attribute20                       igs_ps_usec_ref.attribute20%type,
    enrollment_expected                         igs_ps_usec_lim_wlst.enrollment_expected%TYPE,
    enrollment_minimum                          igs_ps_usec_lim_wlst.enrollment_minimum%TYPE,
    enrollment_maximum                          igs_ps_usec_lim_wlst.enrollment_maximum%TYPE,
    advance_maximum                             igs_ps_usec_lim_wlst.advance_maximum%TYPE,
    usec_waitlist_allowed                       igs_ps_usec_lim_wlst.waitlist_allowed%TYPE,
    usec_max_students_per_waitlist              igs_ps_usec_lim_wlst.max_students_per_waitlist%TYPE,
    override_enrollment_maximum                 igs_ps_usec_lim_wlst.override_enrollment_max%TYPE,
    max_auditors_allowed                        igs_ps_usec_lim_wlst.max_auditors_allowed%TYPE,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1),
    not_multiple_section_flag                   igs_ps_unit_ofr_opt_all.not_multiple_section_flag%TYPE,
    sup_unit_cd                                 igs_ps_unit_ver_all.unit_cd%type,
    sup_version_number                          igs_ps_unit_ver_all.version_number%type,
    sup_teach_cal_alternate_code                igs_ca_inst_all.alternate_code%type,
    sup_location_cd                             igs_ps_unit_ofr_opt_all.location_cd%type,
    sup_unit_class                              igs_ps_unit_ofr_opt_all.unit_class%type,
    default_enroll_flag                         igs_ps_unit_ofr_opt_all.default_enroll_flag%type,
    billing_hrs                                 igs_ps_usec_cps.billing_hrs%type
  );

  TYPE usec_tbl_type IS TABLE OF usec_rec_type INDEX BY BINARY_INTEGER;


/*********************** Unit Section Grading Schema ************************/

  TYPE usec_gs_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_ver_all.unit_cd%type,
    version_number                              igs_ps_unit_ver_all.version_number%type,
    teach_cal_alternate_code                    igs_ca_inst_all.alternate_code%type,
    location_cd                                 igs_ps_unit_ofr_opt_all.location_cd%type,
    unit_class                                  igs_ps_unit_ofr_opt_all.unit_class%type,
    grading_schema_code                         igs_ps_usec_grd_schm.grading_schema_code%type,
    grd_schm_version_number                     igs_ps_usec_grd_schm.grd_schm_version_number%type,
    default_flag                                igs_ps_usec_grd_schm.default_flag%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

TYPE usec_gs_tbl_type IS TABLE OF usec_gs_rec_type INDEX BY BINARY_INTEGER;


/*********************** Unit Section Occurrences ************************/


  TYPE uso_rec_type IS RECORD (
    unit_cd                                     igs_ps_unit_ver_all.unit_cd%type,
    version_number                              igs_ps_unit_ver_all.version_number%type,
    teach_cal_alternate_code                    igs_ca_inst_all.alternate_code%type,
    location_cd                                 igs_ps_unit_ofr_opt_all.location_cd%type,
    unit_class                                  igs_ps_unit_ofr_opt_all.unit_class%type,
    occurrence_identifier                       igs_ps_usec_occurs_all.occurrence_identifier%type,
    to_be_announced                             igs_ps_usec_occurs_all.to_be_announced%type,
    monday                                      igs_ps_usec_occurs_all.monday%type,
    tuesday                                     igs_ps_usec_occurs_all.tuesday%type,
    wednesday                                   igs_ps_usec_occurs_all.wednesday%type,
    thursday                                    igs_ps_usec_occurs_all.thursday%type,
    friday                                      igs_ps_usec_occurs_all.friday%type,
    saturday                                    igs_ps_usec_occurs_all.saturday%type,
    sunday                                      igs_ps_usec_occurs_all.sunday%type,
    start_date                                  igs_ps_usec_occurs_all.start_date%type,
    end_date                                    igs_ps_usec_occurs_all.end_date%type,
    start_time                                  igs_ps_usec_occurs_all.start_time%type,
    end_time                                    igs_ps_usec_occurs_all.end_time%type,
    building_code                               igs_ad_building_all.building_cd%type,
    room_code                                   igs_ad_room_all.room_cd%type,
    dedicated_building_code                     igs_ad_building_all.building_cd%type,
    dedicated_room_code                         igs_ad_room_all.room_cd%type,
    preferred_building_code                     igs_ad_building_all.building_cd%type,
    preferred_room_code                         igs_ad_room_all.room_cd%type,
    no_set_day_ind                              igs_ps_usec_occurs_all.no_set_day_ind%type,
    preferred_region_code                       igs_ps_usec_occurs_all.preferred_region_code%type,
    attribute_category                          igs_ps_usec_occurs_all.attribute_category%type,
    attribute1                                  igs_ps_usec_occurs_all.attribute1%type,
    attribute2                                  igs_ps_usec_occurs_all.attribute2%type,
    attribute3                                  igs_ps_usec_occurs_all.attribute3%type,
    attribute4                                  igs_ps_usec_occurs_all.attribute4%type,
    attribute5                                  igs_ps_usec_occurs_all.attribute5%type,
    attribute6                                  igs_ps_usec_occurs_all.attribute6%type,
    attribute7                                  igs_ps_usec_occurs_all.attribute7%type,
    attribute8                                  igs_ps_usec_occurs_all.attribute8%type,
    attribute9                                  igs_ps_usec_occurs_all.attribute9%type,
    attribute10                                 igs_ps_usec_occurs_all.attribute10%type,
    attribute11                                 igs_ps_usec_occurs_all.attribute11%type,
    attribute12                                 igs_ps_usec_occurs_all.attribute12%type,
    attribute13                                 igs_ps_usec_occurs_all.attribute13%type,
    attribute14                                 igs_ps_usec_occurs_all.attribute14%type,
    attribute15                                 igs_ps_usec_occurs_all.attribute15%type,
    attribute16                                 igs_ps_usec_occurs_all.attribute16%type,
    attribute17                                 igs_ps_usec_occurs_all.attribute17%type,
    attribute18                                 igs_ps_usec_occurs_all.attribute18%type,
    attribute19                                 igs_ps_usec_occurs_all.attribute19%type,
    attribute20                                 igs_ps_usec_occurs_all.attribute20%type,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

TYPE uso_tbl_type IS TABLE OF uso_rec_type INDEX BY BINARY_INTEGER;

/*********************** Reference Codes ************************/

TYPE unit_ref_rec_type IS RECORD (
    production_uso_id                           igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE,
    unit_cd                                     igs_ps_unit_ver_all.unit_cd%type,
    version_number                              igs_ps_unit_ver_all.version_number%type,
    data_type                                   varchar2(10),
    teach_cal_alternate_code                    igs_ca_inst_all.alternate_code%type,
    location_cd                                 igs_ps_unit_ofr_opt_all.location_cd%type,
    unit_class                                  igs_ps_unit_ofr_opt_all.unit_class%type,
    occurrence_identifier                       igs_ps_usec_occurs_all.occurrence_identifier%type,
    reference_cd_type                           igs_ps_unit_ref_cd.reference_cd_type%type,
    reference_cd                                igs_ge_ref_cd.reference_cd%type,
    description                                 igs_ge_ref_cd.description%type,
    gen_ref_flag                                igs_ps_lgcy_ur_int.GEN_REF_FLAG%TYPE,
    interface_id                                NUMBER(15),
    msg_from                                    NUMBER(6),
    msg_to                                      NUMBER(6),
    status                                      VARCHAR2(1)
  );

TYPE unit_ref_tbl_type IS TABLE OF unit_ref_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Occurrence Instructor  ************/
TYPE uso_ins_rec_type IS RECORD (
      instructor_person_number                  hz_parties.party_number%TYPE,
      production_uso_id                         igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE,
      unit_cd                                   igs_ps_unit_ver_all.unit_cd%TYPE,
      version_number                            igs_ps_unit_ver_all.version_number%TYPE,
      teach_cal_alternate_code                  igs_ca_inst_all.alternate_code%TYPE,
      location_cd                               igs_ps_unit_ofr_opt_all.location_cd%TYPE,
      unit_class                                igs_ps_unit_ofr_opt_all.unit_class%TYPE,
      occurrence_identifier                     igs_ps_usec_occurs_all.occurrence_identifier%type,
      confirmed_flag                            igs_ps_usec_tch_resp.confirmed_flag%TYPE,
      wl_percentage_allocation                  igs_ps_usec_tch_resp.percentage_allocation%TYPE,
      instructional_load_lecture                igs_ps_usec_tch_resp.instructional_load_lecture%TYPE,
      instructional_load_laboratory             igs_ps_usec_tch_resp.instructional_load_lab%TYPE,
      instructional_load_other                  igs_ps_usec_tch_resp.instructional_load%TYPE,
      lead_instructor_flag                      igs_ps_usec_tch_resp.lead_instructor_flag%TYPE,
      system_uoo_id                             NUMBER,
      system_uso_id                             NUMBER,
      system_instructor_id                      NUMBER,
      interface_id                              NUMBER(15),
      msg_from                                  NUMBER(6),
      msg_to                                    NUMBER(6),
      status                                    VARCHAR2(1)
 );

TYPE uso_ins_tbl_type IS TABLE OF uso_ins_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Occurrence facilities  ************/
TYPE usec_occurs_facility_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     production_uso_id                igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE,
     occurrence_identifier            igs_ps_usec_occurs_all.occurrence_identifier%TYPE,
     facility_code                    igs_ps_uso_facility.facility_code%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_occurs_facility_tbl_type IS TABLE OF usec_occurs_facility_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Teaching Responsibility Overrides  ************/
TYPE usec_teach_resp_ovrd_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     org_unit_cd                      igs_ps_tch_resp_ovrd_all.org_unit_cd%TYPE,
     ou_start_dt                      igs_ps_tch_resp_ovrd_all.ou_start_dt%TYPE,
     percentage                       igs_ps_tch_resp_ovrd_all.percentage%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_teach_resp_ovrd_tbl_type IS TABLE OF usec_teach_resp_ovrd_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Notes  ************/
TYPE usec_notes_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     reference_number                 igs_ps_unt_ofr_opt_n.reference_number%TYPE,
     crs_note_type		      igs_ps_unt_ofr_opt_n.crs_note_type%TYPE,
     note_text			      igs_ge_note.note_text%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_notes_tbl_type IS TABLE OF usec_notes_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Assessment   ************/
TYPE usec_assmnt_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     final_exam_date		      igs_ps_usec_as.final_exam_date%TYPE,
     exam_start_time	  	      VARCHAR2(5),--igs_ps_usec_as.exam_start_time%TYPE,
     exam_end_time		      VARCHAR2(5),--igs_ps_usec_as.exam_end_time%TYPE,
     exam_location_cd		      igs_ps_usec_as.location_cd%TYPE,
     building_code		      igs_ad_building_all.building_cd%TYPE,
     room_code			      igs_ad_room_all.room_cd%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_assmnt_tbl_type IS TABLE OF usec_assmnt_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Plus Hours   ************/
TYPE usec_plus_hr_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     activity_type_code        	      igs_ps_usec_act_type.activity_type_code%TYPE,
     activity_location_cd             igs_ad_location.location_cd%TYPE,
     building_cd                      igs_ad_building.building_cd%TYPE,
     room_cd                          igs_ad_room.room_cd%TYPE,
     number_of_students      	      igs_ps_us_unsched_cl.number_of_students%TYPE,
     hours_per_student       	      igs_ps_us_unsched_cl.hours_per_student%TYPE,
     hours_per_faculty       	      igs_ps_us_unsched_cl.hours_per_faculty%TYPE,
     instructor_number		      hz_parties.party_number%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_plus_hr_tbl_type IS TABLE OF usec_plus_hr_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section categories   ************/
TYPE usec_cat_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     unit_cat                         igs_ps_usec_category.unit_cat%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_cat_tbl_type IS TABLE OF usec_cat_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Rules   ************/
TYPE usec_rule_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     s_rule_call_cd		      igs_ps_usec_ru.s_rule_call_cd%TYPE,
     rule_text			      VARCHAR2(4000),
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_rule_tbl_type IS TABLE OF usec_rule_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Cross Listed Groups   ************/
TYPE usec_cross_group_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     usec_x_listed_group_name         igs_ps_usec_x_grp.usec_x_listed_group_name%TYPE,
     location_inheritance             igs_ps_usec_x_grp.location_inheritance%TYPE,
     max_enr_group                    NUMBER,--igs_ps_usec_x_grp.max_enr_group%TYPE,
     max_ovr_group                    NUMBER,--igs_ps_usec_x_grp.max_ovr_group%TYPE,
     parent                           igs_ps_usec_x_grpmem.parent%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_cross_group_tbl_type IS TABLE OF usec_cross_group_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Meet With Groups   ************/
TYPE usec_meet_with_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     class_meet_group_name            igs_ps_uso_cm_grp.class_meet_group_name%TYPE,
     max_enr_group                    NUMBER,--igs_ps_uso_cm_grp.max_enr_group%TYPE,
     max_ovr_group                    NUMBER,--igs_ps_uso_cm_grp.max_ovr_group%TYPE,
     host                             igs_ps_uso_clas_meet.host%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_meet_with_tbl_type IS TABLE OF usec_meet_with_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Waitlist Priorities and Preferences  ************/
TYPE usec_waitlist_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     priority_number		      igs_ps_usec_wlst_pri.priority_number%TYPE,
     priority_value		      igs_ps_usec_wlst_pri.priority_value%TYPE,
     preference_order		      igs_ps_usec_wlst_prf.preference_order%TYPE,
     preference_code		      igs_ps_usec_wlst_prf.preference_code%TYPE,
     preference_version		      igs_ps_usec_wlst_prf.preference_version%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_waitlist_tbl_type IS TABLE OF usec_waitlist_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Reserve Seating Priorities and Preferences  ************/
TYPE usec_res_seat_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     priority_order                   igs_ps_rsv_usec_pri.priority_order%TYPE,
     priority_value                   igs_ps_rsv_usec_pri.priority_value%TYPE,
     preference_order                 igs_ps_rsv_usec_prf.preference_order%TYPE,
     preference_code                  igs_ps_rsv_usec_prf.preference_code%TYPE,
     preference_version               igs_ps_rsv_usec_prf.preference_version%TYPE,
     percentage_reserved              igs_ps_rsv_usec_prf.percentage_reserved%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_res_seat_tbl_type IS TABLE OF usec_res_seat_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Special Fees  ************/
TYPE usec_sp_fee_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     fee_type                         igs_ps_usec_sp_fees.fee_type%TYPE,
     sp_fee_amt                       igs_ps_usec_sp_fees.sp_fee_amt%TYPE,
     closed_flag                      igs_ps_usec_sp_fees.closed_flag%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_sp_fee_tbl_type IS TABLE OF usec_sp_fee_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Retention  ************/
TYPE usec_ret_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     definition_level                 igs_ps_nsus_rtn.definition_code%TYPE,
     fee_type                         igs_ps_nsus_rtn.fee_type%TYPE,
     formula_method                   igs_ps_nsus_rtn.formula_method%TYPE,
     round_method                     igs_ps_nsus_rtn.round_method%TYPE,
     incl_wkend_duration_flag         igs_ps_nsus_rtn.incl_wkend_duration_flag%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_ret_tbl_type IS TABLE OF usec_ret_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Retention Details  ************/
TYPE usec_ret_dtl_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     definition_level                 igs_ps_nsus_rtn.definition_code%TYPE,
     fee_type                         igs_ps_nsus_rtn.fee_type%TYPE,
     offset_value                     igs_ps_nsus_rtn_dtl.offset_value%TYPE,
     retention_percent                igs_ps_nsus_rtn_dtl.retention_percent%TYPE,
     retention_amount                 igs_ps_nsus_rtn_dtl.retention_amount%TYPE,
     override_date_flag               igs_ps_nsus_rtn_dtl.override_date_flag%TYPE,
     offset_date                      igs_ps_nsus_rtn_dtl.offset_date%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_ret_dtl_tbl_type IS TABLE OF usec_ret_dtl_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Enrollment Deadline  ************/
TYPE usec_enr_dead_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     function_name                    igs_en_nstd_usec_dl.function_name%TYPE,
     enr_dl_date                      igs_en_nstd_usec_dl.enr_dl_date%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_enr_dead_tbl_type IS TABLE OF usec_enr_dead_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Enrollment Discontinuation  ************/
TYPE usec_enr_dis_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     administrative_unit_status       igs_en_usec_disc_dl.administrative_unit_status%TYPE,
     usec_disc_dl_date                igs_en_usec_disc_dl.usec_disc_dl_date%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_enr_dis_tbl_type IS TABLE OF usec_enr_dis_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Teaching Responsibility  ************/
TYPE usec_teach_resp_rec_type IS RECORD (
     unit_cd                          igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                   igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code         igs_ca_inst_all.alternate_code%TYPE,
     location_cd                      igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                       igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     instructor_person_number         hz_parties.party_number%TYPE,
     confirmed_flag                   igs_ps_usec_tch_resp.confirmed_flag%TYPE,
     wl_percentage_allocation         NUMBER, --igs_ps_usec_tch_resp.percentage_allocation%TYPE,
     instructional_load_lecture       NUMBER, --igs_ps_usec_tch_resp.instructional_load_lecture%TYPE,
     instructional_load_laboratory    NUMBER, --igs_ps_usec_tch_resp.instructional_load_lab%TYPE,
     instructional_load_other         NUMBER, --igs_ps_usec_tch_resp.instructional_load%TYPE,
     lead_instructor_flag             igs_ps_usec_tch_resp.lead_instructor_flag%TYPE,
     msg_from                         NUMBER(6),
     msg_to                           NUMBER(6),
     status                           VARCHAR2(1)
  );

TYPE usec_teach_resp_tbl_type IS TABLE OF usec_teach_resp_rec_type INDEX BY BINARY_INTEGER;

/********************** Unit Section Assessment Item Group  ************/
TYPE usec_ass_item_grp_rec_type IS RECORD (
     unit_cd                                     igs_ps_unit_ver_all.unit_cd%TYPE,
     version_number                              igs_ps_unit_ver_all.version_number%TYPE,
     teach_cal_alternate_code                    igs_ca_inst_all.alternate_code%TYPE,
     location_cd                                 igs_ps_unit_ofr_opt_all.location_cd%TYPE,
     unit_class                                  igs_ps_unit_ofr_opt_all.unit_class%TYPE,
     group_name                                  igs_as_us_ai_group.group_name%TYPE,
     midterm_formula_code                        igs_as_us_ai_group.midterm_formula_code%TYPE,
     midterm_formula_qty                         NUMBER,--igs_as_us_ai_group.midterm_formula_qty%TYPE,
     midterm_weight_qty                          NUMBER,--igs_as_us_ai_group.midterm_weight_qty%TYPE,
     final_formula_code                          igs_as_us_ai_group.final_formula_code%TYPE,
     final_formula_qty                           NUMBER,--igs_as_us_ai_group.final_formula_qty%TYPE,
     final_weight_qty                            NUMBER,--igs_as_us_ai_group.final_weight_qty%TYPE,
     assessment_id                                      igs_ps_unitass_item.ass_id%TYPE,
     sequence_number                             igs_ps_unitass_item.sequence_number%TYPE,
     due_dt                                      igs_ps_unitass_item.due_dt%TYPE,
     reference                                   igs_ps_unitass_item.reference%TYPE,
     dflt_item_ind                               igs_ps_unitass_item.dflt_item_ind%TYPE,
     logical_delete_dt                           igs_ps_unitass_item.logical_delete_dt%TYPE,
     exam_cal_alternate_code                     igs_ca_inst_all.alternate_code%TYPE,
     description                                 igs_ps_unitass_item.description%TYPE,
     grading_schema_cd                           igs_ps_unitass_item.grading_schema_cd%TYPE,
     gs_version_number                           igs_ps_unitass_item.gs_version_number%TYPE,
     release_date                                igs_ps_unitass_item.release_date%TYPE,
     midterm_mandatory_type_code                 igs_ps_unitass_item.midterm_mandatory_type_code%TYPE,
     midterm_weight_qty_item                     NUMBER,--igs_ps_unitass_item.midterm_weight_qty%TYPE,
     final_mandatory_type_code                   igs_ps_unitass_item.final_mandatory_type_code%TYPE,
     final_weight_qty_item                       NUMBER,--igs_ps_unitass_item.final_weight_qty%TYPE,
     msg_from                                    NUMBER(6),
     msg_to                                      NUMBER(6),
     status                                      VARCHAR2(1)
  );
 TYPE usec_ass_item_grp_tbl_type IS TABLE OF usec_ass_item_grp_rec_type INDEX BY BINARY_INTEGER;


/*#
 * A public API to import data from external system to OSS for unit section and its details. This API to be used to import scheduled data to OSS, also can be used for generic imports of unit section and details.
 * This can also this can be used to import legacy related data.
 * @param p_API_VERSION API Version Number
 * @param p_INIT_MSG_LIST Initialize Message List
 * @param p_COMMIT Commit Transaction
 * @param p_VALIDATION_LEVEL Validation Level
 * @param X_RETURN_STATUS Return Status
 * @param X_MSG_COUNT Message Count
 * @param X_MSG_DATA Message Data
 * @param p_CALLING_CONTEXT Calling Context of the API
 * @param p_USEC_STATUS Unit Section Return Status
 * @param p_USEC_GS_STATUS Unit Section Grading Schema Return Status
 * @param p_USO_STATUS Ocurrence Return Status
 * @param p_USO_INS_STATUS Occurrence Instructor Return Status
 * @param p_USO_FACILITY_STATUS Occurrence Facility Return Status
 * @param p_UNIT_REF_STATUS Reference Return Status
 * @param p_USEC_TEACH_RESP_OVRD_STATUS Unit Section Teaching Responsibility Override Return Status
 * @param p_USEC_NOTES_STATUS Unit Section Notes Return Status
 * @param p_USEC_ASSMNT_STATUS Unit Section Assessment Return Status
 * @param p_USEC_PLUS_HR_STATUS Unit Section Plus Hours Return Status
 * @param p_USEC_CAT_STATUS Unit Section Categories Return Status
 * @param p_USEC_RULE_STATUS Unit Section Rules Return Status
 * @param p_USEC_CROSS_GROUP_STATUS Unit Section Crosslisted Group Return Status
 * @param p_USEC_MEET_WITH_STATUS Unit Section Meetwith Group Return Status
 * @param p_USEC_WAITLIST_STATUS Unit Section Waitlist Return Status
 * @param p_USEC_RES_SEAT_STATUS Unit Section Reserve Seating Return Status
 * @param p_USEC_SP_FEE_STATUS Unit Section Special Fee Return Status
 * @param p_USEC_RET_STATUS Unit Section Retention Return Status
 * @param p_USEC_RET_DTL_STATUS Unit Section Retention Details Return Status
 * @param p_USEC_ENR_DEAD_STATUS Unit Section Enrollment Deadline Return Status
 * @param p_USEC_ENR_DIS_STATUS Unit Section Enrollment Discontinuation Return Status
 * @param p_USEC_TEACH_RESP_STATUS Unit Section Teaching Responsibility Return Status
 * @param p_USEC_ASS_ITEM_GRP_STATUS Unit Section Assessment Item Return Status
 * @param p_UNIT_VER_REC Unit Version Records
 * @param p_UNIT_TR_TBL Unit Teaching Responsibility Records
 * @param p_UNIT_DSCP_TBL Unit Discipline Records
 * @param p_UNIT_GS_TBL Unit Grading Schema Records
 * @param p_USEC_TBL Unit Section Records
 * @param p_USEC_GS_TBL Unit Section Grading Schema Records
 * @param p_USO_TBL Unit Section Occurrence Records
 * @param p_UNIT_REF_TBL Unit Reference Records
 * @param p_USO_INS_TBL Unit Section Occurrence Instructor Records
 * @param p_USEC_OCCURS_FACILITY_TBL Unit Section Occurrence Facility Records
 * @param p_USEC_TEACH_RESP_OVRD_TBL Unit Section Teaching Responsibility Override Records
 * @param p_USEC_NOTES_TBL Unit Section Notes Records
 * @param p_USEC_ASSMNT_TBL Unit Section Assessment Records
 * @param p_USEC_PLUS_HR_TBL Unit Section Plus Hours Records
 * @param p_USEC_CAT_TBL Unit Section Categorizations Records
 * @param p_USEC_RULE_TBL Unit Section Rule Records
 * @param p_USEC_CROSS_GROUP_TBL Unit Section Cross-Listed Groups Records
 * @param p_USEC_MEET_WITH_TBL Unit Section Meet-With Records
 * @param p_USEC_WAITLIST_TBL Unit Section Waitlist Records
 * @param p_USEC_RES_SEAT_TBL Unit Section Reserved Seating Records
 * @param p_USEC_SP_FEE_TBL Unit Section Special Fee Records
 * @param p_USEC_RET_TBL Unit Section Retention Records
 * @param p_USEC_RET_DTL_TBL Unit Section Retention Detail Records
 * @param p_USEC_ENR_DEAD_TBL Unit Section Enrollment Deadline Records
 * @param p_USEC_ENR_DIS_TBL  Unit Section Enrollment Disconinuation Records
 * @param p_USEC_TEACH_RESP_TBL Unit Section Teaching Responsibility Records
 * @param p_USEC_ASS_ITEM_GRP_TBL Unit Section Assessment Item Group Records
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Program Structure and Planning Import
 */
PROCEDURE psp_import (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status			      OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_calling_context		      IN VARCHAR2,
p_unit_ver_rec			      IN OUT NOCOPY unit_ver_rec_type,
p_unit_tr_tbl			      IN OUT NOCOPY unit_tr_tbl_type,
p_unit_dscp_tbl			      IN OUT NOCOPY unit_dscp_tbl_type,
p_unit_gs_tbl			      IN OUT NOCOPY unit_gs_tbl_type,
p_usec_tbl			      IN OUT NOCOPY usec_tbl_type,
p_usec_gs_tbl			      IN OUT NOCOPY usec_gs_tbl_type,
p_uso_tbl			      IN OUT NOCOPY uso_tbl_type,
p_unit_ref_tbl			      IN OUT NOCOPY unit_ref_tbl_type,
p_uso_ins_tbl			      IN OUT NOCOPY uso_ins_tbl_type,
p_usec_occurs_facility_tbl	      IN OUT NOCOPY usec_occurs_facility_tbl_type,
p_usec_teach_resp_ovrd_tbl	      IN OUT NOCOPY usec_teach_resp_ovrd_tbl_type,
p_usec_notes_tbl		      IN OUT NOCOPY usec_notes_tbl_type,
p_usec_assmnt_tbl		      IN OUT NOCOPY usec_assmnt_tbl_type,
p_usec_plus_hr_tbl		      IN OUT NOCOPY usec_plus_hr_tbl_type,
p_usec_cat_tbl			      IN OUT NOCOPY usec_cat_tbl_type,
p_usec_rule_tbl			      IN OUT NOCOPY usec_rule_tbl_type,
p_usec_cross_group_tbl		      IN OUT NOCOPY usec_cross_group_tbl_type,
p_usec_meet_with_tbl		      IN OUT NOCOPY usec_meet_with_tbl_type,
p_usec_waitlist_tbl		      IN OUT NOCOPY usec_waitlist_tbl_type,
p_usec_res_seat_tbl		      IN OUT NOCOPY usec_res_seat_tbl_type,
p_usec_sp_fee_tbl		      IN OUT NOCOPY usec_sp_fee_tbl_type,
p_usec_ret_tbl			      IN OUT NOCOPY usec_ret_tbl_type,
p_usec_ret_dtl_tbl		      IN OUT NOCOPY usec_ret_dtl_tbl_type,
p_usec_enr_dead_tbl		      IN OUT NOCOPY usec_enr_dead_tbl_type,
p_usec_enr_dis_tbl		      IN OUT NOCOPY usec_enr_dis_tbl_type,
p_usec_teach_resp_tbl		      IN OUT NOCOPY usec_teach_resp_tbl_type,
p_usec_ass_item_grp_tbl		      IN OUT NOCOPY usec_ass_item_grp_tbl_type,
p_usec_status			      OUT NOCOPY VARCHAR2,
p_usec_gs_status		      OUT NOCOPY VARCHAR2,
p_uso_status			      OUT NOCOPY VARCHAR2,
p_uso_ins_status		      OUT NOCOPY VARCHAR2,
p_uso_facility_status		      OUT NOCOPY VARCHAR2,
p_unit_ref_status		      OUT NOCOPY VARCHAR2,
p_usec_teach_resp_ovrd_status	      OUT NOCOPY VARCHAR2,
p_usec_notes_status		      OUT NOCOPY VARCHAR2,
p_usec_assmnt_status		      OUT NOCOPY VARCHAR2,
p_usec_plus_hr_status		      OUT NOCOPY VARCHAR2,
p_usec_cat_status		      OUT NOCOPY VARCHAR2,
p_usec_rule_status		      OUT NOCOPY VARCHAR2,
p_usec_cross_group_status	      OUT NOCOPY VARCHAR2,
p_usec_meet_with_status		      OUT NOCOPY VARCHAR2,
p_usec_waitlist_status		      OUT NOCOPY VARCHAR2,
p_usec_res_seat_status		      OUT NOCOPY VARCHAR2,
p_usec_sp_fee_status		      OUT NOCOPY VARCHAR2,
p_usec_ret_status		      OUT NOCOPY VARCHAR2,
p_usec_ret_dtl_status		      OUT NOCOPY VARCHAR2,
p_usec_enr_dead_status		      OUT NOCOPY VARCHAR2,
p_usec_enr_dis_status		      OUT NOCOPY VARCHAR2,
p_usec_teach_resp_status	      OUT NOCOPY VARCHAR2,
p_usec_ass_item_grp_status	      OUT NOCOPY VARCHAR2 ) ;


END igs_ps_generic_pub;

 

/
