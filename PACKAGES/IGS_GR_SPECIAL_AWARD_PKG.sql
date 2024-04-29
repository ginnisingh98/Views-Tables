--------------------------------------------------------
--  DDL for Package IGS_GR_SPECIAL_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_SPECIAL_AWARD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI16S.pls 120.1 2005/07/06 23:22:10 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID  in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2

);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'

  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_DT in DATE,
  X_CEREMONY_ANNOUNCED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID  in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_award_cd IN VARCHAR2,
    x_award_dt IN DATE
    ) RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    );

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_dt IN DATE DEFAULT NULL,
    x_ceremony_announced_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID  in NUMBER DEFAULT NULL
  );

end IGS_GR_SPECIAL_AWARD_PKG;

 

/
