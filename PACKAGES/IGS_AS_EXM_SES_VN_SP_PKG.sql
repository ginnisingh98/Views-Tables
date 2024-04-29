--------------------------------------------------------
--  DDL for Package IGS_AS_EXM_SES_VN_SP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_EXM_SES_VN_SP_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSDI13S.pls 115.4 2002/11/28 23:13:40 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_ESE_ID in NUMBER,
  X_EXAM_SUPERVISOR_TYPE in VARCHAR2,
  X_OVERRIDE_START_TIME in DATE,
  X_OVERRIDE_END_TIME in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_venue_cd IN VARCHAR2,
    x_start_time IN DATE,
    x_end_time IN DATE
    ) RETURN BOOLEAN ;


  PROCEDURE GET_FK_IGS_AS_EXM_SPRVSRTYP (
    x_exam_supervisor_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AS_EXM_SUPRVISOR (
    x_person_id IN NUMBER
    );

  PROCEDURE GET_UFK_IGS_AS_EXAM_SESSION (
    x_ese_id IN NUMBER
   );




	PROCEDURE Check_Constraints (




	Column_Name	IN	VARCHAR2	DEFAULT NULL,




	Column_Value 	IN	VARCHAR2	DEFAULT NULL




	);



















PROCEDURE Before_DML (




    p_action IN VARCHAR2,




    x_rowid  IN VARCHAR2 DEFAULT NULL,




    x_person_id IN NUMBER DEFAULT NULL,




    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,




    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,




    x_dt_alias IN VARCHAR2 DEFAULT NULL,




    x_dai_sequence_number IN NUMBER DEFAULT NULL,




    x_start_time IN DATE DEFAULT NULL,




    x_end_time IN DATE DEFAULT NULL,




    x_ese_id IN NUMBER DEFAULT NULL,




    x_venue_cd IN VARCHAR2 DEFAULT NULL,




    x_exam_supervisor_type IN VARCHAR2 DEFAULT NULL,




    x_override_start_time IN DATE DEFAULT NULL,




    x_override_end_time IN DATE DEFAULT NULL,




    x_creation_date IN DATE DEFAULT NULL,




    x_created_by IN NUMBER DEFAULT NULL,




    x_last_update_date IN DATE DEFAULT NULL,




    x_last_updated_by IN NUMBER DEFAULT NULL,




    x_last_update_login IN NUMBER DEFAULT NULL




  ) ;












end IGS_AS_EXM_SES_VN_SP_PKG;

 

/
