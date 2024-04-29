--------------------------------------------------------
--  DDL for Package IGS_PS_OFR_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OFR_NOTE_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSPI21S.pls 115.3 2002/11/29 02:12:12 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CRS_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_reference_number IN NUMBER
    )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_NOTE_TYPE (
    x_crs_note_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_GE_NOTE (
    x_reference_number IN NUMBER
    );

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_crs_note_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_OFR_NOTE_PKG;

 

/
