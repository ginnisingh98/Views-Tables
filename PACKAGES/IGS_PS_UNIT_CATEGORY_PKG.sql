--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_CATEGORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_CATEGORY_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI75S.pls 115.4 2002/11/29 02:37:24 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_CAT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_UNIT_CAT in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
 FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_unit_cat IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_PS_UNIT_CAT (
    x_unit_cat IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_unit_cat IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
     );

end IGS_PS_UNIT_CATEGORY_PKG;

 

/
