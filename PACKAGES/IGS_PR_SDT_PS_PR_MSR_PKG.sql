--------------------------------------------------------
--  DDL for Package IGS_PR_SDT_PS_PR_MSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_SDT_PS_PR_MSR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI20S.pls 115.3 2002/11/29 03:19:15 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_s_prg_measure_type IN VARCHAR2,
    x_calculation_dt IN DATE
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_prg_measure_type IN VARCHAR2
    );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_prg_measure_type IN VARCHAR2 DEFAULT NULL,
    x_calculation_dt IN DATE DEFAULT NULL,
    x_value IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

end IGS_PR_SDT_PS_PR_MSR_PKG;

 

/
