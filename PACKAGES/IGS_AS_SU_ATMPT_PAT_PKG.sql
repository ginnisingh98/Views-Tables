--------------------------------------------------------
--  DDL for Package IGS_AS_SU_ATMPT_PAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SU_ATMPT_PAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI07S.pls 120.0 2005/07/05 11:27:45 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_UOO_ID in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_CREATION_DT in DATE,
  X_S_DEFAULT_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

 FUNCTION get_pk_for_validation(
    x_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ass_pattern_id IN NUMBER,
    x_creation_dt IN DATE,
    x_uoo_id IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
    );

  PROCEDURE GET_UFK_IGS_AS_UNTAS_PATTERN (
    x_ass_pattern_id IN NUMBER
    );

	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_s_default_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL
  ) ;



end IGS_AS_SU_ATMPT_PAT_PKG;

 

/
