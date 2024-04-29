--------------------------------------------------------
--  DDL for Package IGS_ST_GVTSEMLOAD_CA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GVTSEMLOAD_CA_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSVI03S.pls 115.3 2002/11/29 04:31:32 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_GOVT_SEMESTER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )
RETURN BOOLEAN ;

PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

PROCEDURE GET_FK_IGS_ST_GOVT_SEMESTER (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER
    );

FUNCTION  GET_UK1_FOR_VALIDATION (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_cal_type  IN VARCHAR2,
    x_ci_sequence_number IN NUMBER )
RETURN BOOLEAN ;

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    DEFAULT NULL ,
                 Column_Value    IN   VARCHAR2    DEFAULT NULL
                                );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


end IGS_ST_GVTSEMLOAD_CA_PKG;

 

/
