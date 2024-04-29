--------------------------------------------------------
--  DDL for Package IGS_CA_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI17S.pls 115.4 2002/11/28 23:03:23 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_ARTS_TC_CA_CD (
    x_arts_teaching_cal_type_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_cal_cat IN VARCHAR2
    );
 PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_cal_cat IN VARCHAR2 DEFAULT NULL,
    x_abbreviation IN VARCHAR2 DEFAULT NULL,
    x_arts_teaching_cal_type_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_CA_TYPE_PKG;

 

/