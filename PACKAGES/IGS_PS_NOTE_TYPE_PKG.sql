--------------------------------------------------------
--  DDL for Package IGS_PS_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_NOTE_TYPE_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSPI48S.pls 120.1 2006/01/27 02:51:50 sarakshi noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_crs_note_type IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE CHECK_CONSTRAINTS (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL
  ) ;

  PROCEDURE LOAD_ROW (
    x_crs_note_type      IN VARCHAR2,
    x_description        IN VARCHAR2,
    x_owner              IN VARCHAR2,
    x_last_update_date   IN VARCHAR2,
    x_custom_mode        IN VARCHAR2
  );

  PROCEDURE LOAD_SEED_ROW (
    x_upload_mode        IN VARCHAR2, -- an extra parameter to distinguish NLS and non-NLS upload
    x_crs_note_type      IN VARCHAR2,
    x_description        IN VARCHAR2,
    x_owner              IN VARCHAR2,
    x_last_update_date   IN VARCHAR2,
    x_custom_mode        IN VARCHAR2
  );

end IGS_PS_NOTE_TYPE_PKG;

 

/
