--------------------------------------------------------
--  DDL for Package IGS_PS_CATLG_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_CATLG_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0QS.pls 115.8 2002/11/29 01:59:40 nsidana ship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_CATALOG_NOTE_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID IN NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_CATALOG_NOTE_ID IN NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2
      );


 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_CATALOG_NOTE_ID IN NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CATALOG_NOTE_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_CREATE_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEQUENCE IN NUMBER,
       x_NOTE_TEXT IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID IN NUMBER
  ) ;


procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;

  FUNCTION Get_PK_For_Validation (
    x_catalog_note_id IN NUMBER
    ) RETURN BOOLEAN ;


  FUNCTION Get_UK_For_Validation (
    x_catalog_version_id IN NUMBER,
    x_note_type_id IN NUMBER,
    x_sequence IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Catlg_Vers (
    x_catalog_version_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ps_Note_Types (
    x_note_type_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_catalog_note_id IN NUMBER DEFAULT NULL,
    x_catalog_version_id IN NUMBER DEFAULT NULL,
    x_note_type_id IN NUMBER DEFAULT NULL,
    x_create_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_sequence IN NUMBER DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
 );
END igs_ps_catlg_notes_pkg;

 

/
