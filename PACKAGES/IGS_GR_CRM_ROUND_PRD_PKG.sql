--------------------------------------------------------
--  DDL for Package IGS_GR_CRM_ROUND_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_CRM_ROUND_PRD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI10S.pls 120.1 2005/09/30 04:18:17 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COMPLETION_YEAR in NUMBER,
  X_COMPLETION_PERIOD in out NOCOPY VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COMPLETION_YEAR in NUMBER,
  X_COMPLETION_PERIOD in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_completion_year IN NUMBER,
    x_completion_period IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_GR_CRMN_ROUND (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER
    );


  PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_completion_year IN NUMBER DEFAULT NULL,
    x_completion_period IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_GR_CRM_ROUND_PRD_PKG;

 

/
