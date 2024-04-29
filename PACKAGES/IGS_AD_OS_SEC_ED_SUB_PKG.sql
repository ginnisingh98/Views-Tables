--------------------------------------------------------
--  DDL for Package IGS_AD_OS_SEC_ED_SUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_OS_SEC_ED_SUB_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI40S.pls 115.3 2002/11/28 22:05:00 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID   in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID   in  VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_OSE_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SUBJECT_CD in VARCHAR2,
  X_SUBJECT_DESC in VARCHAR2,
  X_RESULT_TYPE in VARCHAR2,
  X_RESULT in VARCHAR2,
  X_SUBJECT_RESULT_YR in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );

procedure DELETE_ROW (
  X_ROWID   in  VARCHAR2
);

 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ose_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    )
RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_AD_OS_SEC_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    );

PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ose_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_subject_cd IN VARCHAR2 DEFAULT NULL,
    x_subject_desc IN VARCHAR2 DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_result IN VARCHAR2 DEFAULT NULL,
    x_subject_result_yr IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_AD_OS_SEC_ED_SUB_PKG;

 

/