--------------------------------------------------------
--  DDL for Package IGS_PR_STDNT_PR_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STDNT_PR_PS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI16S.pls 120.0 2005/07/05 12:34:18 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);

 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_spo_course_cd IN VARCHAR2,
    x_spo_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PR_STDNT_PR_OU (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    );
PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PR_STDNT_PR_PS_PKG;

 

/
