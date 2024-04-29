--------------------------------------------------------
--  DDL for Package IGS_PS_OFR_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OFR_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI20S.pls 115.3 2002/11/29 02:11:56 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )
  RETURN BOOLEAN;

  PROCEDURE GET_UFK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    );

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    );

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_min_entry_ass_score IN NUMBER DEFAULT NULL,
    x_guaranteed_entry_ass_scr IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_OFR_INST_PKG;

 

/
