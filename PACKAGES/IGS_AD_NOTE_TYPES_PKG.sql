--------------------------------------------------------
--  DDL for Package IGS_AD_NOTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_NOTE_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI76S.pls 120.0 2005/06/01 19:32:00 appldev noship $ */
  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_NOTES_TYPE_ID IN OUT NOCOPY NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2 default NULL
  );

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_NOTES_TYPE_ID IN NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2
  );

  procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_NOTES_TYPE_ID IN NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2 default NULL
  );

  procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_NOTES_TYPE_ID IN  OUT NOCOPY NUMBER,
    x_NOTES_CATEGORY IN VARCHAR2,
    x_NOTE_TYPE IN VARCHAR2,
    x_DESCRIPTION IN VARCHAR2,
    x_CLOSED_IND IN VARCHAR2,
    X_MODE in VARCHAR2 default NULL
  ) ;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  );

  FUNCTION Get_PK_For_Validation (
    x_notes_type_id IN NUMBER,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_notes_category IN VARCHAR2,
    x_note_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

   FUNCTION Get_UK2_For_Validation (
    x_notes_type_id IN NUMBER,
    x_notes_category IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_notes_type_id IN NUMBER DEFAULT NULL,
    x_notes_category IN VARCHAR2 DEFAULT NULL,
    x_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

END igs_ad_note_types_pkg;

 

/
