--------------------------------------------------------
--  DDL for Package IGS_PS_PAT_STUDY_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_PAT_STUDY_PRD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI62S.pls 115.3 2002/11/29 02:33:29 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ACAD_PERIOD_NUM in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ACAD_PERIOD_NUM in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ACAD_PERIOD_NUM in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_POS_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ACAD_PERIOD_NUM in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_pos_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_PAT_OF_STUDY (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );
PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_pos_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_acad_period_num IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 ) ;


end IGS_PS_PAT_STUDY_PRD_PKG;

 

/
