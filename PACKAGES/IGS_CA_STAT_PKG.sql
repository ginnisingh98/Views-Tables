--------------------------------------------------------
--  DDL for Package IGS_CA_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI14S.pls 115.4 2002/11/28 23:03:08 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_cal_status IN VARCHAR2
   ) RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
	x_s_cal_status IN VARCHAR2
    );

PROCEDURE Check_Constraints (
   	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
   	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_cal_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_cal_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );

end IGS_CA_STAT_PKG;

 

/
