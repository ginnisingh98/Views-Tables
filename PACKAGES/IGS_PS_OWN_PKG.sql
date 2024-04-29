--------------------------------------------------------
--  DDL for Package IGS_PS_OWN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OWN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI27S.pls 120.0 2005/06/01 23:50:51 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    )RETURN BOOLEAN;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_org_unit_cd IN VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
	Column_name IN VARCHAR2 DEFAULT NULL,
	Column_value IN VARCHAR2 DEFAULT NULL
   );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_PS_OWN_PKG;

 

/
