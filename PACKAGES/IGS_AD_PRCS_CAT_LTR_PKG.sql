--------------------------------------------------------
--  DDL for Package IGS_AD_PRCS_CAT_LTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PRCS_CAT_LTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI36S.pls 115.4 2002/11/28 22:03:49 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_CORRESPONDENCE_TYPE in VARCHAR2,
  X_LETTER_REFERENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_correspondence_type IN VARCHAR2
    )
RETURN BOOLEAN;

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_correspondence_type IN VARCHAR2 DEFAULT NULL,
    x_letter_reference_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CO_S_LTR (
    x_correspondence_type IN VARCHAR2,
    x_letter_reference_number IN NUMBER
    );
end IGS_AD_PRCS_CAT_LTR_PKG;

 

/
