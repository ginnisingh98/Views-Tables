--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_VER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_VER_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI92S.pls 120.2 2005/11/28 21:44:46 appldev ship $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
 PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_UNIT_CD IN VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_START_DT IN DATE,
  X_REVIEW_DT IN DATE,
  X_EXPIRY_DT IN DATE,
  X_END_DT IN DATE,
  X_UNIT_STATUS IN VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE IN VARCHAR2,
  X_TITLE_OVERRIDE_IND IN VARCHAR2,
  X_ABBREVIATION IN VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR IN VARCHAR2,
  X_ENROLLED_CREDIT_POINTS IN NUMBER,
  X_POINTS_OVERRIDE_IND IN VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND IN VARCHAR2,
  X_COORD_PERSON_ID IN NUMBER,
  X_OWNER_ORG_UNIT_CD IN VARCHAR2,
  X_OWNER_OU_START_DT IN DATE,
  X_AWARD_COURSE_ONLY_IND IN VARCHAR2,
  X_RESEARCH_UNIT_IND IN VARCHAR2,
  X_INDUSTRIAL_IND IN VARCHAR2,
  X_PRACTICAL_IND IN VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id                       IN     NUMBER DEFAULT NULL,
  x_work_load_other                   IN     NUMBER DEFAULT NULL,
  x_contact_hrs_lecture               IN     NUMBER DEFAULT NULL,
  x_contact_hrs_lab                   IN     NUMBER DEFAULT NULL,
  x_contact_hrs_other                 IN     NUMBER DEFAULT NULL,
  x_non_schd_required_hrs             IN     NUMBER DEFAULT NULL,
  x_exclude_from_max_cp_limit         IN     VARCHAR2 DEFAULT NULL,
  x_record_exclusion_flag             IN     VARCHAR2 DEFAULT NULL,
  x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
  x_cal_type_enrol_load_cal           IN     VARCHAR2 DEFAULT NULL,
  x_sequence_num_enrol_load_cal       IN     NUMBER DEFAULT NULL,
  x_cal_type_offer_load_cal           IN     VARCHAR2 DEFAULT NULL,
  x_sequence_num_offer_load_cal       IN     NUMBER DEFAULT NULL,
  x_curriculum_id                     IN     VARCHAR2 DEFAULT NULL,
  x_override_enrollment_max           IN     NUMBER DEFAULT NULL,
  x_rpt_fmly_id                       IN     NUMBER DEFAULT NULL,
  x_unit_type_id                      IN     NUMBER DEFAULT NULL,
  x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER,
  X_SS_ENROL_IND IN Varchar2 DEFAULT 'N',
  X_IVR_enrol_ind IN Varchar2 DEFAULT 'N',
  x_claimable_hours  IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_auditable_ind IN VARCHAR2 DEFAULT 'N',
  x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  x_max_auditors_allowed IN NUMBER DEFAULT NULL,
  x_billing_credit_points IN NUMBER DEFAULT NULL,
  x_ovrd_wkld_val_flag    IN VARCHAR2 DEFAULT 'N',
  x_workload_val_code     IN VARCHAR2 DEFAULT NULL,
  x_billing_hrs           IN NUMBER DEFAULT NULL
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
  PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 IN VARCHAR2,
  X_ATTRIBUTE2 IN VARCHAR2,
  X_ATTRIBUTE3 IN VARCHAR2,
  X_ATTRIBUTE4 IN VARCHAR2,
  X_ATTRIBUTE5 IN VARCHAR2,
  X_ATTRIBUTE6 IN VARCHAR2,
  X_ATTRIBUTE7 IN VARCHAR2,
  X_ATTRIBUTE8 IN VARCHAR2,
  X_ATTRIBUTE9 IN VARCHAR2,
  X_ATTRIBUTE10 IN VARCHAR2,
  X_ATTRIBUTE11 IN VARCHAR2,
  X_ATTRIBUTE12 IN VARCHAR2,
  X_ATTRIBUTE13 IN VARCHAR2,
  X_ATTRIBUTE14 IN VARCHAR2,
  X_ATTRIBUTE15 IN VARCHAR2,
  X_ATTRIBUTE16 IN VARCHAR2,
  X_ATTRIBUTE17 IN VARCHAR2,
  X_ATTRIBUTE18 IN VARCHAR2,
  X_ATTRIBUTE19 IN VARCHAR2,
  X_ATTRIBUTE20 IN VARCHAR2,
  x_subtitle_id                       IN     NUMBER DEFAULT NULL,
  x_work_load_other                   IN     NUMBER DEFAULT NULL,
  x_contact_hrs_lecture               IN     NUMBER DEFAULT NULL,
  x_contact_hrs_lab                   IN     NUMBER DEFAULT NULL,
  x_contact_hrs_other                 IN     NUMBER DEFAULT NULL,
  x_non_schd_required_hrs             IN     NUMBER DEFAULT NULL,
  x_exclude_from_max_cp_limit         IN     VARCHAR2 DEFAULT NULL,
  x_record_exclusion_flag             IN     VARCHAR2 DEFAULT NULL,
  x_ss_display_ind       IN     VARCHAR2 DEFAULT NULL,
  x_cal_type_enrol_load_cal           IN     VARCHAR2 DEFAULT NULL,
  x_sequence_num_enrol_load_cal    IN     NUMBER DEFAULT NULL,
  x_cal_type_offer_load_cal           IN     VARCHAR2 DEFAULT NULL,
  x_sequence_num_offer_load_cal    IN     NUMBER DEFAULT NULL,
  x_curriculum_id                     IN     VARCHAR2 DEFAULT NULL,
  x_override_enrollment_max           IN     NUMBER DEFAULT NULL,
  x_rpt_fmly_id                       IN     NUMBER DEFAULT NULL,
  x_unit_type_id                      IN     NUMBER DEFAULT NULL,
  x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
  X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  X_IVR_ENROL_IND IN VARCHAR2  DEFAULT 'N',
  x_claimable_hours  IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_auditable_ind IN VARCHAR2 DEFAULT 'N',
  x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  x_max_auditors_allowed IN NUMBER DEFAULT NULL ,
  x_billing_credit_points IN NUMBER DEFAULT NULL,
  x_ovrd_wkld_val_flag    IN VARCHAR2 DEFAULT 'N',
  x_workload_val_code     IN VARCHAR2 DEFAULT NULL,
  x_billing_hrs           IN NUMBER DEFAULT NULL
);
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
 PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id                       IN     NUMBER DEFAULT NULL,
  x_work_load_other                   IN     NUMBER DEFAULT NULL,
    x_contact_hrs_lecture               IN     NUMBER DEFAULT NULL,
    x_contact_hrs_lab                   IN     NUMBER DEFAULT NULL,
    x_contact_hrs_other                 IN     NUMBER DEFAULT NULL,
    x_non_schd_required_hrs             IN     NUMBER DEFAULT NULL,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 DEFAULT NULL,
    x_record_exclusion_flag             IN     VARCHAR2 DEFAULT NULL,
    x_ss_display_ind       IN     VARCHAR2 DEFAULT NULL,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 DEFAULT NULL,
    x_sequence_num_enrol_load_cal    IN     NUMBER DEFAULT NULL,
    x_cal_type_offer_load_cal           IN     VARCHAR2 DEFAULT NULL,
    x_sequence_num_offer_load_cal    IN     NUMBER DEFAULT NULL,
    x_curriculum_id                     IN     VARCHAR2 DEFAULT NULL,
    x_override_enrollment_max           IN     NUMBER DEFAULT NULL,
    x_rpt_fmly_id                       IN     NUMBER DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER DEFAULT NULL,
    x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  X_IVR_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_claimable_hours  IN NUMBER DEFAULT NULL,
  x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_auditable_ind IN VARCHAR2 DEFAULT 'N',
  x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  x_max_auditors_allowed IN NUMBER DEFAULT NULL,
  x_billing_credit_points IN NUMBER DEFAULT NULL,
  x_ovrd_wkld_val_flag    IN VARCHAR2 DEFAULT 'N',
  x_workload_val_code     IN VARCHAR2 DEFAULT NULL,
  x_billing_hrs           IN NUMBER DEFAULT NULL
  );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id                       IN   NUMBER DEFAULT NULL,
  x_work_load_other                   IN   NUMBER DEFAULT NULL,
    x_contact_hrs_lecture             IN   NUMBER DEFAULT NULL,
    x_contact_hrs_lab                 IN   NUMBER DEFAULT NULL,
    x_contact_hrs_other               IN   NUMBER DEFAULT NULL,
    x_non_schd_required_hrs           IN   NUMBER DEFAULT NULL,
    x_exclude_from_max_cp_limit       IN   VARCHAR2 DEFAULT NULL,
    x_record_exclusion_flag           IN   VARCHAR2 DEFAULT NULL,
    x_ss_display_ind                  IN   VARCHAR2 DEFAULT NULL,
    x_cal_type_enrol_load_cal         IN   VARCHAR2 DEFAULT NULL,
    x_sequence_num_enrol_load_cal     IN   NUMBER DEFAULT NULL,
    x_cal_type_offer_load_cal         IN   VARCHAR2 DEFAULT NULL,
    x_sequence_num_offer_load_cal     IN   NUMBER DEFAULT NULL,
    x_curriculum_id                   IN   VARCHAR2 DEFAULT NULL,
    x_override_enrollment_max         IN   NUMBER DEFAULT NULL,
    x_rpt_fmly_id                     IN   NUMBER DEFAULT NULL,
    x_unit_type_id                    IN   NUMBER DEFAULT NULL,
    x_special_permission_ind          IN   VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER ,
  X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  X_IVR_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  x_claimable_hours IN NUMBER DEFAULT NULL,
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_auditable_ind IN VARCHAR2 DEFAULT 'N',
  x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  x_max_auditors_allowed IN NUMBER DEFAULT NULL ,
  x_billing_credit_points IN NUMBER DEFAULT NULL,
  x_ovrd_wkld_val_flag    IN VARCHAR2 DEFAULT 'N',
  x_workload_val_code     IN VARCHAR2 DEFAULT NULL,
  x_billing_hrs           IN NUMBER DEFAULT NULL
  );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:
     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2
);
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PS_CR_PT_DSCR (
    x_credit_point_descriptor IN VARCHAR2
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PS_UNIT_INT_LVL (
    x_unit_int_course_level_cd IN VARCHAR2
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PS_UNIT_STAT (
    x_unit_status IN VARCHAR2
    );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE GET_FK_IGS_PS_RPT_FMLY_ALL(
    x_rpt_fmly_id IN NUMBER
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE get_fk_igs_ps_unit_subtitle (
    x_subtitle_id  IN     NUMBER
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE get_fk_igs_ps_unt_crclm_all(
    x_curriculum_id IN VARCHAR2
    );
  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE get_fk_igs_ca_inst_all(
  x_cal_type    IN VARCHAR2,
  x_sequence_number   IN NUMBER
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE get_fk_igs_ca_inst_all1(
  x_cal_type    IN VARCHAR2,
  x_sequence_number   IN NUMBER
  );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:
  Purpose:
     1.
  Usage: (e.g. restricted, unrestricted, where to call from)
     1.
  Known limitations/enhancements/remarks:     -
  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  msrinivi        18 Jul,2001     Added a new col : revenue_account_cd
  *******************************************************************************/
PROCEDURE Before_DML (
  P_ACTION IN VARCHAR2,
  X_ROWID IN VARCHAR2 DEFAULT NULL,
  X_UNIT_CD in VARCHAR2 DEFAULT NULL,
  X_VERSION_NUMBER in NUMBER DEFAULT NULL,
  X_START_DT in DATE DEFAULT NULL,
  X_REVIEW_DT in DATE DEFAULT NULL,
  X_EXPIRY_DT in DATE DEFAULT NULL,
  X_END_DT in DATE DEFAULT NULL,
  X_UNIT_STATUS in VARCHAR2 DEFAULT NULL,
  X_TITLE in VARCHAR2 DEFAULT NULL,
  X_SHORT_TITLE in VARCHAR2 DEFAULT NULL,
  X_TITLE_OVERRIDE_IND in VARCHAR2 DEFAULT NULL,
  X_ABBREVIATION in VARCHAR2 DEFAULT NULL,
  X_UNIT_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2 DEFAULT NULL,
  X_ENROLLED_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_POINTS_OVERRIDE_IND in VARCHAR2 DEFAULT NULL,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2 DEFAULT NULL,
  X_COORD_PERSON_ID in NUMBER DEFAULT NULL,
  X_OWNER_ORG_UNIT_CD in VARCHAR2 DEFAULT NULL,
  X_OWNER_OU_START_DT in DATE DEFAULT NULL,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2 DEFAULT NULL,
  X_RESEARCH_UNIT_IND in VARCHAR2 DEFAULT NULL,
  X_INDUSTRIAL_IND in VARCHAR2 DEFAULT NULL,
  X_PRACTICAL_IND in VARCHAR2 DEFAULT NULL,
  X_REPEATABLE_IND in VARCHAR2 DEFAULT NULL,
  X_ASSESSABLE_IND in VARCHAR2 DEFAULT NULL,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_POINTS_INCREMENT in NUMBER DEFAULT NULL,
  X_POINTS_MIN in NUMBER DEFAULT NULL,
  X_POINTS_MAX in NUMBER DEFAULT NULL,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2 DEFAULT NULL,
  X_SUBTITLE in VARCHAR2 DEFAULT NULL,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2 DEFAULT NULL,
  X_APPROVAL_DATE in DATE DEFAULT NULL,
  X_LECTURE_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_LAB_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_OTHER_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_CLOCK_HOURS in NUMBER DEFAULT NULL,
  X_WORK_LOAD_CP_LECTURE in NUMBER DEFAULT NULL,
  X_WORK_LOAD_CP_LAB in NUMBER DEFAULT NULL,
  X_CONTINUING_EDUCATION_UNITS in NUMBER DEFAULT NULL,
  X_ENROLLMENT_EXPECTED in NUMBER DEFAULT NULL,
  X_ENROLLMENT_MINIMUM in NUMBER DEFAULT NULL,
  X_ENROLLMENT_MAXIMUM in NUMBER DEFAULT NULL,
  X_ADVANCE_MAXIMUM in NUMBER DEFAULT NULL,
  X_STATE_FINANCIAL_AID in VARCHAR2 DEFAULT NULL,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2 DEFAULT NULL,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2 DEFAULT NULL,
  X_SAME_TEACHING_PERIOD in VARCHAR2 DEFAULT NULL,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER DEFAULT NULL,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER DEFAULT NULL,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER DEFAULT NULL,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER DEFAULT NULL,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19 in VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20 in VARCHAR2 DEFAULT NULL,
  x_subtitle_id                       IN     NUMBER DEFAULT NULL,
  x_work_load_other                   IN     NUMBER DEFAULT NULL,
    x_contact_hrs_lecture               IN     NUMBER DEFAULT NULL,
    x_contact_hrs_lab                   IN     NUMBER DEFAULT NULL,
    x_contact_hrs_other                 IN     NUMBER DEFAULT NULL,
    x_non_schd_required_hrs             IN     NUMBER DEFAULT NULL,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 DEFAULT NULL,
    x_record_exclusion_flag             IN     VARCHAR2 DEFAULT NULL,
    x_ss_display_ind       IN     VARCHAR2 DEFAULT NULL,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 DEFAULT NULL,
    x_sequence_num_enrol_load_cal    IN     NUMBER DEFAULT NULL,
    x_cal_type_offer_load_cal           IN     VARCHAR2 DEFAULT NULL,
    x_sequence_num_offer_load_cal    IN     NUMBER DEFAULT NULL,
    x_curriculum_id                     IN     VARCHAR2 DEFAULT NULL,
    x_override_enrollment_max           IN     NUMBER DEFAULT NULL,
    x_rpt_fmly_id                       IN     NUMBER DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER DEFAULT NULL,
    x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
  X_CREATED_BY in NUMBER DEFAULT NULL,
  X_CREATION_DATE in DATE DEFAULT NULL,
  X_LAST_UPDATED_BY in NUMBER DEFAULT NULL,
  X_LAST_UPDATE_DATE in DATE DEFAULT NULL,
  X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL,
  X_ORG_ID IN NUMBER DEFAULT NULL,
  X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  X_IVR_ENROL_IND IN VARCHAR2 DEFAULT 'N',
  x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
  x_claimable_hours IN NUMBER DEFAULT NULL,
  x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
  x_auditable_ind IN VARCHAR2 DEFAULT 'N',
  x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
  x_max_auditors_allowed IN NUMBER DEFAULT NULL,
  x_billing_credit_points IN NUMBER DEFAULT NULL,
  x_ovrd_wkld_val_flag    IN VARCHAR2 DEFAULT 'N',
  x_workload_val_code     IN VARCHAR2 DEFAULT NULL,
  x_billing_hrs           IN NUMBER DEFAULT NULL
  );

PROCEDURE update_row_subtitle_id(X_RowId  IN  VARCHAR2,X_Subtitle_Id  IN  NUMBER);
/*******************************************************************************
  Created by  : Sommukhe, Oracle IDC
  Date created:
  Purpose:

  Known limitations/enhancements/remarks:
     -
  Change History:
  Who             When            What
  *******************************************************************************/

END IGS_PS_UNIT_VER_PKG;

 

/
