--------------------------------------------------------
--  DDL for Package IGS_PS_ANL_LOAD_U_LN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_ANL_LOAD_U_LN_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI05S.pls 115.3 2002/11/29 01:53:38 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_YR_NUM in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_EFFECTIVE_START_DT in DATE,
  X_YR_NUM in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_yr_num IN NUMBER,
    x_effective_start_dt IN DATE,
    x_unit_cd IN VARCHAR2,
    x_uv_version_number IN NUMBER  )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_ANL_LOAD (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_yr_num IN NUMBER,
    x_effective_start_dt IN DATE
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
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
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_yr_num IN NUMBER DEFAULT NULL,
    x_effective_start_dt IN DATE DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_ANL_LOAD_U_LN_PKG;

 

/
