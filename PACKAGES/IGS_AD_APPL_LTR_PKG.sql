--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_LTR_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI06S.pls 115.3 2002/11/28 21:54:18 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_COMPOSED_IND in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_SPL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    )
RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AD_APPL (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_CO_TYPE (
    x_correspondence_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CO_S_PER_LTR  (
    x_person_id IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_letter_reference_number IN NUMBER,
    x_sequence_number IN NUMBER
    );
-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_composed_ind IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
    x_spl_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_AD_APPL_LTR_PKG;

 

/
