--------------------------------------------------------
--  DDL for Package IGS_CA_DA_INST_PAIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DA_INST_PAIR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI07S.pls 115.3 2002/11/28 23:01:15 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_RELATED_DT_ALIAS in VARCHAR2,
  X_RELATED_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RELATED_CAL_TYPE in VARCHAR2,
  X_RELATED_CI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_RELATED_DT_ALIAS in VARCHAR2,
  X_RELATED_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RELATED_CAL_TYPE in VARCHAR2,
  X_RELATED_CI_SEQUENCE_NUMBER in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_related_dt_alias IN VARCHAR2,
    x_related_dai_sequence_number IN NUMBER,
    x_related_cal_type IN VARCHAR2,
    x_related_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
	Column_Name	      IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);

 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_related_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_related_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_related_cal_type IN VARCHAR2 DEFAULT NULL,
    x_related_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_CA_DA_INST_PAIR_PKG;

 

/
