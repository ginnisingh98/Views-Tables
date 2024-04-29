--------------------------------------------------------
--  DDL for Package IGS_AS_EXAM_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_EXAM_SESSION_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI12S.pls 115.4 2002/11/28 23:13:23 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_ESE_ID in NUMBER,
  X_EXAM_SESSION_NUMBER in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

FUNCTION Get_PK_For_Validation (
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE
    )RETURN BOOLEAN;

FUNCTION Get_UK_For_Validation (
    x_ese_id IN NUMBER
    )RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );






	PROCEDURE CHECK_UNIQUENESS;

	PROCEDURE Check_Constraints (






	Column_Name	IN	VARCHAR2	DEFAULT NULL,






	Column_Value 	IN	VARCHAR2	DEFAULT NULL






	);













PROCEDURE Before_DML (






    p_action IN VARCHAR2,






    x_rowid IN  VARCHAR2 DEFAULT NULL,

     x_org_id in NUMBER DEFAULT NULL,




    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,






    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,






    x_dt_alias IN VARCHAR2 DEFAULT NULL,






    x_dai_sequence_number IN NUMBER DEFAULT NULL,






    x_ci_start_dt IN DATE DEFAULT NULL,






    x_ci_end_dt IN DATE DEFAULT NULL,






    x_start_time IN DATE DEFAULT NULL,






    x_end_time IN DATE DEFAULT NULL,






    x_ese_id IN NUMBER DEFAULT NULL,






    x_exam_session_number IN NUMBER DEFAULT NULL,






    x_comments IN VARCHAR2 DEFAULT NULL,






    x_creation_date IN DATE DEFAULT NULL,






    x_created_by IN NUMBER DEFAULT NULL,






    x_last_update_date IN DATE DEFAULT NULL,






    x_last_updated_by IN NUMBER DEFAULT NULL,






    x_last_update_login IN NUMBER DEFAULT NULL






  ) ;
end IGS_AS_EXAM_SESSION_PKG;

 

/
