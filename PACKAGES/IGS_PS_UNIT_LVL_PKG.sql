--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_LVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_LVL_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSPI40S.pls 115.6 2003/10/16 05:39:49 nalkumar ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2 DEFAULT NULL,
  X_UNIT_LEVEL in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_COURSE_CD VARCHAR2,
  X_COURSE_VERSION_NUMBER NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_unit_cd               IN VARCHAR2,
    x_version_number        IN NUMBER,
    x_course_cd             IN VARCHAR2,
    x_course_version_number IN NUMBER)
    RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER);

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd IN VARCHAR2,
    x_course_version_number IN NUMBER);

  PROCEDURE CHECK_CONSTRAINTS (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_wam_weighting IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_course_cd VARCHAR2 DEFAULT NULL,
    x_course_version_number NUMBER DEFAULT NULL
  ) ;

end IGS_PS_UNIT_LVL_PKG;

 

/
