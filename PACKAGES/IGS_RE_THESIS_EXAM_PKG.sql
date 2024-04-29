--------------------------------------------------------
--  DDL for Package IGS_RE_THESIS_EXAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_THESIS_EXAM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI16S.pls 120.0 2005/06/01 19:22:44 appldev noship $ */
Procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_THE_SEQUENCE_NUMBER in NUMBER,
  X_CREATION_DT in DATE,
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
  X_SUBMISSION_DT in DATE,
  X_THESIS_EXAM_TYPE in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_TRACKING_ID in NUMBER,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_the_sequence_number IN NUMBER,
    x_creation_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_RE_THS_EXAM_TYPE (
    x_thesis_exam_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_RE_THESIS (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RE_THESIS_RESULT (
    x_thesis_result_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_RE_THS_PNL_TYPE (
    x_thesis_panel_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_TR_ITEM (
    x_tracking_id IN NUMBER
    );

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
    x_submission_dt IN DATE DEFAULT NULL,
    x_thesis_exam_type IN VARCHAR2 DEFAULT NULL,
    x_thesis_panel_type IN VARCHAR2 DEFAULT NULL,
    x_tracking_id IN NUMBER DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_RE_THESIS_EXAM_PKG;

 

/
