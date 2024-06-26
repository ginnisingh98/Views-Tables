--------------------------------------------------------
--  DDL for Package IGS_PS_STDNT_TRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_STDNT_TRN_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI64S.pls 120.0 2005/06/01 22:55:46 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_APPROVED_DATE in DATE DEFAULT NULL,
  X_EFFECTIVE_TERM_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_EFFECTIVE_TERM_SEQUENCE_NUM in NUMBER DEFAULT NULL,
  X_DISCONTINUE_SOURCE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UOOIDS_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_SUSA_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_TRANSFER_ADV_STAND_FLAG in VARCHAR2 DEFAULT NULL,
  X_STATUS_DATE in DATE DEFAULT NULL,
  X_STATUS_FLAG in VARCHAR2 DEFAULT NULL
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_APPROVED_DATE in DATE DEFAULT NULL,
  X_EFFECTIVE_TERM_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_EFFECTIVE_TERM_SEQUENCE_NUM in NUMBER DEFAULT NULL,
  X_DISCONTINUE_SOURCE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UOOIDS_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_SUSA_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_TRANSFER_ADV_STAND_FLAG in VARCHAR2 DEFAULT NULL,
  X_STATUS_DATE in DATE DEFAULT NULL,
  X_STATUS_FLAG in VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_APPROVED_DATE in DATE DEFAULT NULL,
  X_EFFECTIVE_TERM_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_EFFECTIVE_TERM_SEQUENCE_NUM in NUMBER DEFAULT NULL,
  X_DISCONTINUE_SOURCE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UOOIDS_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_SUSA_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_TRANSFER_ADV_STAND_FLAG in VARCHAR2 DEFAULT NULL,
  X_STATUS_DATE in DATE DEFAULT NULL,
  X_STATUS_FLAG in VARCHAR2 DEFAULT NULL
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_TRANSFER_DT in DATE,
  X_COURSE_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_APPROVED_DATE in DATE DEFAULT NULL,
  X_EFFECTIVE_TERM_CAL_TYPE in VARCHAR2 DEFAULT NULL,
  X_EFFECTIVE_TERM_SEQUENCE_NUM in NUMBER DEFAULT NULL,
  X_DISCONTINUE_SOURCE_FLAG in VARCHAR2 DEFAULT NULL,
  X_UOOIDS_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_SUSA_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
  X_TRANSFER_ADV_STAND_FLAG in VARCHAR2 DEFAULT NULL,
  X_STATUS_DATE in DATE DEFAULT NULL,
  X_STATUS_FLAG in VARCHAR2 DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_transfer_course_cd IN VARCHAR2,
    x_transfer_dt IN DATE
    ) RETURN BOOLEAN;

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
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_transfer_dt IN DATE DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_APPROVED_DATE IN DATE DEFAULT NULL,
    X_EFFECTIVE_TERM_CAL_TYPE IN VARCHAR2 DEFAULT NULL,
    X_EFFECTIVE_TERM_SEQUENCE_NUM IN NUMBER DEFAULT NULL,
    X_DISCONTINUE_SOURCE_FLAG in VARCHAR2 DEFAULT NULL,
    X_UOOIDS_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
    X_SUSA_TO_TRANSFER in VARCHAR2 DEFAULT NULL,
    X_TRANSFER_ADV_STAND_FLAG in VARCHAR2 DEFAULT NULL,
    X_STATUS_DATE IN DATE DEFAULT NULL,
    X_STATUS_FLAG IN VARCHAR2 DEFAULT NULL
  ) ;



end IGS_PS_STDNT_TRN_PKG;

 

/
