--------------------------------------------------------
--  DDL for Package IGS_FI_FND_SRC_RSTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FND_SRC_RSTN_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI40S.pls 115.3 2002/11/29 03:46:57 nsidana ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_funding_source IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2

    );
 PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_restricted_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  )	;
end IGS_FI_FND_SRC_RSTN_PKG;

 

/
