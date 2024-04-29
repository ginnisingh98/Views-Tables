--------------------------------------------------------
--  DDL for Package IGS_CA_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI12S.pls 120.0 2005/06/01 18:52:11 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_CAL_STATUS in VARCHAR2,
  X_ALTERNATE_CODE in VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND in VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_SS_DISPLAYED in VARCHAR2 default 'N' ,
  X_DESCRIPTION  IN VARCHAR2  ,
  X_IVR_DISPLAY_IND in VARCHAR2 default 'N',
  X_TERM_INSTRUCTION_TIME IN NUMBER DEFAULT NULL,
  X_PLANNING_FLAG in VARCHAR2 default 'N',
  X_SCHEDULE_FLAG in VARCHAR2 default 'N',
  X_ADMIN_FLAG in VARCHAR2 default 'N'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_CAL_STATUS in VARCHAR2,
  X_ALTERNATE_CODE in VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND in VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER in NUMBER,
  X_SS_DISPLAYED in VARCHAR2 default 'N',
  X_DESCRIPTION  IN VARCHAR2  ,
  X_IVR_DISPLAY_IND in VARCHAR2 default 'N',
  X_TERM_INSTRUCTION_TIME IN NUMBER DEFAULT NULL,
  X_PLANNING_FLAG in VARCHAR2 default 'N',
  X_SCHEDULE_FLAG in VARCHAR2 default 'N',
  X_ADMIN_FLAG in VARCHAR2 default 'N'
  );
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_CAL_STATUS in VARCHAR2,
  X_ALTERNATE_CODE in VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND in VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_SS_DISPLAYED in VARCHAR2 default NULL,
  X_DESCRIPTION  IN VARCHAR2  ,
  X_IVR_DISPLAY_IND in VARCHAR2 default 'N',
  X_TERM_INSTRUCTION_TIME IN NUMBER DEFAULT NULL,
  X_PLANNING_FLAG in VARCHAR2 default 'N',
  X_SCHEDULE_FLAG in VARCHAR2 default 'N',
  X_ADMIN_FLAG in VARCHAR2 default 'N'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_CAL_STATUS in VARCHAR2,
  X_ALTERNATE_CODE in VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND in VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_SS_DISPLAYED in VARCHAR2 default 'N',
  X_DESCRIPTION  IN VARCHAR2  ,
  X_IVR_DISPLAY_IND in VARCHAR2 default 'N',
  X_TERM_INSTRUCTION_TIME IN NUMBER DEFAULT NULL ,
  X_PLANNING_FLAG in VARCHAR2 default 'N',
  X_SCHEDULE_FLAG in VARCHAR2 default 'N',
  X_ADMIN_FLAG in VARCHAR2 default 'N'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    )RETURN BOOLEAN ;

  FUNCTION Get_UK2_For_Validation (
    x_cal_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
   );

  PROCEDURE GET_FK_IGS_CA_STAT (
    x_cal_status IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CA_INST (
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
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_cal_status IN VARCHAR2 DEFAULT NULL,
    x_alternate_code IN VARCHAR2 DEFAULT NULL,
    x_sup_cal_status_differ_ind IN VARCHAR2 DEFAULT NULL,
    x_prior_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id in NUMBER default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_ss_displayed IN VARCHAR2 DEFAULT 'N',
    x_description  IN VARCHAR2  DEFAULT NULL,
    x_ivr_display_ind IN VARCHAR2 DEFAULT 'N',
    x_term_instruction_time IN NUMBER  DEFAULT NULL,
    x_planning_flag in varchar2 default 'N',
    x_schedule_flag in varchar2 default 'N',
    x_admin_flag in varchar2 default 'N'
  );

END igs_ca_inst_pkg;

 

/
