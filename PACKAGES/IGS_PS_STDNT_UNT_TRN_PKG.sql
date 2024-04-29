--------------------------------------------------------
--  DDL for Package IGS_PS_STDNT_UNT_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_STDNT_UNT_TRN_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI67S.pls 115.5 2003/05/20 05:53:16 svanukur ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_UOO_ID in NUMBER
);

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE,
    x_uoo_id IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_STDNT_TRN (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE
    );

  PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
    );
  PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
   );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  );



end IGS_PS_STDNT_UNT_TRN_PKG;

 

/
