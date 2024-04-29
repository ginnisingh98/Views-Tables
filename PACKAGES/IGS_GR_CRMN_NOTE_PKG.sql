--------------------------------------------------------
--  DDL for Package IGS_GR_CRMN_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_CRMN_NOTE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI09S.pls 115.5 2002/11/29 00:36:00 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID  in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2

);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'

  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_GRD_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID  in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_reference_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_GR_CRMN (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_GR_NOTE_TYPE (
    x_grd_note_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    );

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_grd_note_type IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID  in NUMBER DEFAULT NULL
  );

end IGS_GR_CRMN_NOTE_PKG;

 

/
