--------------------------------------------------------
--  DDL for Package IGS_AD_AUSE_ED_OT_SC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_AUSE_ED_OT_SC_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI50S.pls 115.4 2002/11/28 22:07:57 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ASE_SEQUENCE_NUMBER in NUMBER,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_SCORE_TYPE in VARCHAR2,
  X_SCORE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);


FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ase_sequence_number IN NUMBER,
    x_result_obtained_yr IN NUMBER,
    x_score_type IN VARCHAR2
)return BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE GET_FK_IGS_AD_AUS_SEC_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_score_type IN VARCHAR2 DEFAULT NULL,
    x_score IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ase_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_AD_AUSE_ED_OT_SC_PKG;

 

/
