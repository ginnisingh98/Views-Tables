--------------------------------------------------------
--  DDL for Package IGS_RE_THESIS_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_THESIS_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI17S.pls 115.4 2002/11/29 03:36:19 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CA_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TITLE in VARCHAR2,
  X_FINAL_TITLE_IND in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_ABBREVIATED_TITLE in VARCHAR2,
  X_THESIS_RESULT_CD in VARCHAR2,
  X_EXPECTED_SUBMISSION_DT in DATE,
  X_DATE_OF_LIBRARY_LODGEMENT in DATE,
  X_LIBRARY_CATALOGUE_NUMBER in VARCHAR2,
  X_EMBARGO_EXPIRY_DT in DATE,
  X_THESIS_FORMAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_EMBARGO_DETAILS in VARCHAR2,
  X_THESIS_TOPIC in VARCHAR2,
  X_CITATION in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_ca_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
  RETURN BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_ca_sequence_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_title IN VARCHAR2 DEFAULT NULL,
    x_final_title_ind IN VARCHAR2 DEFAULT NULL,
    x_short_title IN VARCHAR2 DEFAULT NULL,
    x_abbreviated_title IN VARCHAR2 DEFAULT NULL,
    x_thesis_result_cd IN VARCHAR2 DEFAULT NULL,
    x_expected_submission_dt IN DATE DEFAULT NULL,
    x_date_of_library_lodgement IN DATE DEFAULT NULL,
    x_library_catalogue_number IN VARCHAR2 DEFAULT NULL,
    x_embargo_expiry_dt IN DATE DEFAULT NULL,
    x_thesis_format IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_embargo_details IN VARCHAR2 DEFAULT NULL,
    x_thesis_topic IN VARCHAR2 DEFAULT NULL,
    x_citation IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
  );


end IGS_RE_THESIS_HIST_PKG;

 

/
