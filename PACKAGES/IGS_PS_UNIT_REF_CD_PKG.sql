--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_REF_CD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI88S.pls 115.6 2003/05/09 06:50:59 sarakshi ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_REFERENCE_CD_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_REFERENCE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
 FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_GE_REF_CD_TYPE (
    x_reference_cd_type IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_GE_REF_CD (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );


FUNCTION Get_UK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_reference_cd_type IN VARCHAR2
    )RETURN BOOLEAN;


PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PS_UNIT_REF_CD_PKG;

 

/
