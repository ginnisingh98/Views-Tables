--------------------------------------------------------
--  DDL for Package IGS_EN_UNITSETPSTYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_UNITSETPSTYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSEI03S.pls 115.4 2003/06/05 13:03:14 sarakshi ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_COURSE_TYPE in VARCHAR2
);

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_course_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_EN_UNITSETPSTYPE_PKG;

 

/
