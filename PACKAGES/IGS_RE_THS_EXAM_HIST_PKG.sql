--------------------------------------------------------
--  DDL for Package IGS_RE_THS_EXAM_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_THS_EXAM_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI19S.pls 115.4 2002/11/29 03:36:51 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_the_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_submission_dt IN DATE DEFAULT NULL,
    x_thesis_exam_type IN VARCHAR2 DEFAULT NULL,
    x_thesis_panel_type IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
  ) ;

end IGS_RE_THS_EXAM_HIST_PKG;

 

/