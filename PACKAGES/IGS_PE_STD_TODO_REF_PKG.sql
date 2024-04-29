--------------------------------------------------------
--  DDL for Package IGS_PE_STD_TODO_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_STD_TODO_REF_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI37S.pls 115.4 2003/04/30 06:00:25 svanukur ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R' ,
  X_UOO_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_UOO_ID in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
 FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_s_student_todo_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PE_STD_TODO (
    x_person_id IN NUMBER,
    x_s_student_todo_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );
  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
 PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_person_id IN NUMBER DEFAULT NULL,

    x_s_student_todo_type IN VARCHAR2 DEFAULT NULL,

    x_sequence_number IN NUMBER DEFAULT NULL,

    x_reference_number IN NUMBER DEFAULT NULL,

    x_cal_type IN VARCHAR2 DEFAULT NULL,

    x_ci_sequence_number IN NUMBER DEFAULT NULL,

    x_course_cd IN VARCHAR2 DEFAULT NULL,

    x_unit_cd IN VARCHAR2 DEFAULT NULL,

    x_other_reference IN VARCHAR2 DEFAULT NULL,

    x_logical_delete_dt IN DATE DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL,

    x_uoo_id IN NUMBER DEFAULT NULL

  );

end IGS_PE_STD_TODO_REF_PKG;

 

/