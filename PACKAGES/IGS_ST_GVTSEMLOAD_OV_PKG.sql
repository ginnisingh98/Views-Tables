--------------------------------------------------------
--  DDL for Package IGS_ST_GVTSEMLOAD_OV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GVTSEMLOAD_OV_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSVI04S.pls 115.4 2002/11/29 04:31:50 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    )
RETURN BOOLEAN;

FUNCTION Get_UK1_For_Validation (
	x_submission_yr in NUMBER,
	x_submission_number IN NUMBER,
	x_cal_type IN VARCHAR2,
	x_ci_sequence_number IN NUMBER,
	x_teach_cal_type IN VARCHAR2
	)
RETURN BOOLEAN;

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

PROCEDURE GET_FK_IGS_ST_DFT_LOAD_APPO (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    );

PROCEDURE GET_FK_IGS_ST_GOVT_SEMESTER (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER
    );
end IGS_ST_GVTSEMLOAD_OV_PKG;

 

/
