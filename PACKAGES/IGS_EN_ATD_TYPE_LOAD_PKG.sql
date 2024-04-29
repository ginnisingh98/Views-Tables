--------------------------------------------------------
--  DDL for Package IGS_EN_ATD_TYPE_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ATD_TYPE_LOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI19S.pls 120.1 2005/09/08 15:05:20 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
  x_cal_type IN VARCHAR2,
  x_attendance_type IN VARCHAR2
  )
RETURN BOOLEAN;
PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
  x_attendance_type IN VARCHAR2
  );
PROCEDURE GET_FK_IGS_CA_TYPE (
  x_cal_type IN VARCHAR2
  );

procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_lower_enr_load_range IN NUMBER DEFAULT NULL,
    x_upper_enr_load_range IN NUMBER DEFAULT NULL,
    x_default_eftsu IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_EN_ATD_TYPE_LOAD_PKG;

 

/
