--------------------------------------------------------
--  DDL for Package IGS_AS_SC_ATMPT_ENR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SC_ATMPT_ENR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI18S.pls 120.0 2005/07/05 12:26:17 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_ENR_FORM_DUE_DT in DATE,
  X_ENR_PCKG_PROD_DT in DATE,
  X_ENR_FORM_RECEIVED_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_ENR_FORM_DUE_DT in DATE,
  X_ENR_PCKG_PROD_DT in DATE,
  X_ENR_FORM_RECEIVED_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_ENR_FORM_DUE_DT in DATE,
  X_ENR_PCKG_PROD_DT in DATE,
  X_ENR_FORM_RECEIVED_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_ENR_FORM_DUE_DT in DATE,
  X_ENR_PCKG_PROD_DT in DATE,
  X_ENR_FORM_RECEIVED_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );
 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
    x_enrolment_cat IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2);

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_enr_form_due_dt IN DATE DEFAULT NULL,
    x_enr_pckg_prod_dt IN DATE DEFAULT NULL,
    x_enr_form_received_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_AS_SC_ATMPT_ENR_PKG;

 

/
