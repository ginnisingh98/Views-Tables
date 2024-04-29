--------------------------------------------------------
--  DDL for Package IGS_AD_PS_APPL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PS_APPL_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI17S.pls 115.4 2002/11/28 21:57:47 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
	X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
	X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    )
 RETURN BOOLEAN;

-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_course_rank_set IN VARCHAR2 DEFAULT NULL,
    x_course_rank_schedule IN VARCHAR2 DEFAULT NULL,
    x_req_for_reconsideration_ind IN VARCHAR2 DEFAULT NULL,
    x_req_for_adv_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_AD_PS_APPL_HIST_PKG;

 

/
