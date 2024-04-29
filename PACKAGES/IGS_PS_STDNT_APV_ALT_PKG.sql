--------------------------------------------------------
--  DDL for Package IGS_PS_STDNT_APV_ALT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_STDNT_APV_ALT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI65S.pls 120.1 2005/06/14 00:26:41 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_exit_course_cd IN VARCHAR2,
    x_exit_version_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PE_ALTERNATV_EXT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exit_course_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    );
PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_version_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rqrmnts_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_STDNT_APV_ALT_PKG;

 

/
