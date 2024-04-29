--------------------------------------------------------
--  DDL for Package IGS_AS_STD_EXM_INSTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_STD_EXM_INSTN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI09S.pls 120.0 2005/07/05 11:52:13 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
  X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in out NOCOPY NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
  X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in NUMBER
);
procedure UPDATE_ROW (
   X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
  X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_EXAM_CAL_TYPE in VARCHAR2,
  X_EXAM_CI_SEQUENCE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_VENUE_CD in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SEAT_NUMBER in NUMBER,
  X_TIMESLOT in DATE,
  X_TIMESLOT_DURATION in DATE,
  X_ESE_ID in NUMBER,
  X_ATTENDANCE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER,
  X_STD_EXM_INSTN_ID in out NOCOPY NUMBER
  );
procedure DELETE_ROW (
   X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R');


    FUNCTION Get_PK_For_Validation (
    x_std_exm_instn_id in NUMBER
    ) RETURN BOOLEAN;

    FUNCTION Get_UK_For_Validation (
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_creation_dt IN DATE,
    x_uoo_id in NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_EXAM_INSTANCE (
    x_ass_id IN NUMBER,
    x_exam_cal_type IN VARCHAR2,
    x_exam_ci_sequence_number IN NUMBER,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_start_time IN DATE,
    x_end_time IN DATE,
    x_venue_cd IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_AS_EXAM_SESSION (
    x_ese_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_SU_ATMPT_ITM (
    x_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_creation_dt IN DATE,
    x_uoo_id in NUMBER
    );
	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_seat_number IN NUMBER DEFAULT NULL,
    x_timeslot IN DATE DEFAULT NULL,
    x_timeslot_duration IN DATE DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_exam_cal_type IN VARCHAR2 DEFAULT NULL,
    x_exam_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_ese_id IN NUMBER DEFAULT NULL,
    x_venue_cd IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_attendance_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_uoo_id in NUMBER DEFAULT NULL,
    x_std_exm_instn_id in NUMBER DEFAULT NULL
  ) ;


end IGS_AS_STD_EXM_INSTN_PKG;

 

/
