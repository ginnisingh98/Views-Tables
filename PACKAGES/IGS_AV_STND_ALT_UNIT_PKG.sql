--------------------------------------------------------
--  DDL for Package IGS_AV_STND_ALT_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_STND_ALT_UNIT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSBI07S.pls 120.0 2005/07/05 11:34:19 appldev noship $ */
  procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_ALT_UNIT_CD in VARCHAR2,
  X_ALT_VERSION_NUMBER in NUMBER,
  X_OPTIONAL_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
 X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);
  FUNCTION Get_PK_For_Validation (
    x_av_stnd_unit_id IN NUMBER,
    x_alt_unit_cd IN VARCHAR2,
    x_alt_version_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AV_STND_UNIT (
      x_av_stnd_unit_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_av_stnd_unit_id IN NUMBER DEFAULT NULL,
    x_alt_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_alt_version_number IN NUMBER DEFAULT NULL,
    x_optional_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

end IGS_AV_STND_ALT_UNIT_PKG;

 

/
