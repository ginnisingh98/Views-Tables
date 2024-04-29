--------------------------------------------------------
--  DDL for Package IGS_CA_INST_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_INST_REL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI13S.pls 115.4 2002/11/28 23:02:53 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_sub_cal_type IN VARCHAR2,
    x_sub_ci_sequence_number IN NUMBER,
    x_sup_cal_type IN VARCHAR2,
    x_sup_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN;

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
     x_sub_cal_type IN VARCHAR2 DEFAULT NULL,
     x_sub_ci_sequence_number IN NUMBER DEFAULT NULL,
     x_sup_cal_type IN VARCHAR2 DEFAULT NULL,
     x_sup_ci_sequence_number IN NUMBER DEFAULT NULL,
     x_load_research_percentage IN NUMBER DEFAULT NULL,
     x_creation_date IN DATE DEFAULT NULL,
     x_created_by IN NUMBER DEFAULT NULL,
     x_last_update_date IN DATE DEFAULT NULL,
     x_last_updated_by IN NUMBER DEFAULT NULL,
     x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_CA_INST_REL_PKG;

 

/
