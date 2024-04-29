--------------------------------------------------------
--  DDL for Package IGS_PS_STDNT_SPL_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_STDNT_SPL_REQ_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI66S.pls 120.0 2005/06/01 21:36:00 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPECIAL_REQUIREMENT_CD in VARCHAR2,
  X_COMPLETED_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_EXPIRY_DT in DATE,
  X_REFERENCE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);
FUNCTION Get_PK_For_Validation (
  x_person_id IN NUMBER,
  x_course_cd IN VARCHAR2,
  x_special_requirement_cd IN VARCHAR2,
  x_completed_dt IN DATE
 ) RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
  x_person_id IN NUMBER,
  x_course_cd IN VARCHAR2
);

PROCEDURE GET_FK_IGS_GE_SPL_REQ (
  x_special_requirement_cd IN VARCHAR2
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
    x_special_requirement_cd IN VARCHAR2 DEFAULT NULL,
    x_completed_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_reference IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_PS_STDNT_SPL_REQ_PKG;

 

/
