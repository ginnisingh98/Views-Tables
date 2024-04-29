--------------------------------------------------------
--  DDL for Package IGS_AD_TER_ED_UNI_AT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TER_ED_UNI_AT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI51S.pls 115.3 2002/11/28 22:08:14 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ENROLLED_YR in NUMBER,
  X_RESULT_TYPE in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_CREDIT_POINTS in NUMBER,
  X_GRADE in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
function Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_te_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
)return BOOLEAN;

procedure Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE GET_FK_IGS_PS_DSCP (
    x_discipline_group_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AD_TER_EDU (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_te_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_enrolled_yr IN NUMBER DEFAULT NULL,
    x_result_type IN VARCHAR2 DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_credit_points IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_AD_TER_ED_UNI_AT_PKG;

 

/
