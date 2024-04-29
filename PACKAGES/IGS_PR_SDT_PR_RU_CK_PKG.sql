--------------------------------------------------------
--  DDL for Package IGS_PR_SDT_PR_RU_CK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_SDT_PR_RU_CK_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI17S.pls 115.5 2002/11/29 03:18:27 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_RULE_CHECK_DT in DATE,
  X_PASSED_IND in VARCHAR2,
  X_RULE_MESSAGE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PR_RU_APPL (
    x_progression_rule_cat IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PR_STDNT_PR_CK (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_rule_check_dt IN DATE
    );

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_check_dt IN DATE DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_message_text IN VARCHAR2 DEFAULT NULL,
    x_passed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );

end IGS_PR_SDT_PR_RU_CK_PKG;

 

/
