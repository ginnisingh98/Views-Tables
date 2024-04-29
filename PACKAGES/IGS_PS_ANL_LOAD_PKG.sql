--------------------------------------------------------
--  DDL for Package IGS_PS_ANL_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_ANL_LOAD_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI04S.pls 115.3 2002/11/29 01:53:22 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_YR_NUM in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_EFFECTIVE_END_DT in DATE,
  X_ANNUAL_LOAD_VAL in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_yr_num IN NUMBER,
    x_effective_start_dt IN DATE )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
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
    x_yr_num IN NUMBER DEFAULT NULL,
    x_effective_start_dt IN DATE DEFAULT NULL,
    x_effective_end_dt IN DATE DEFAULT NULL,
    x_annual_load_val IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_ANL_LOAD_PKG;

 

/
