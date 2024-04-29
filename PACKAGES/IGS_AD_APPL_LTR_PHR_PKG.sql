--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_LTR_PHR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_LTR_PHR_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI11S.pls 115.3 2002/11/28 21:55:44 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2
);

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_AAL_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_PHRASE_CD in VARCHAR2,
  X_PHRASE_ORDER_NUMBER in NUMBER,
  X_LETTER_PARAMETER_TYPE in VARCHAR2,
  X_PHRASE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);


FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_aal_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    )
RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_AD_APPL_LTR (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_correspondence_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

PROCEDURE GET_FK_IGS_CO_LTR_PARM_TYPE (
    x_letter_parameter_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CO_LTR_PHR (
    x_phrase_cd IN VARCHAR2
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
    x_aal_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_phrase_cd IN VARCHAR2 DEFAULT NULL,
    x_phrase_order_number IN NUMBER DEFAULT NULL,
    x_letter_parameter_type IN VARCHAR2 DEFAULT NULL,
    x_phrase_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_AD_APPL_LTR_PHR_PKG;

 

/
