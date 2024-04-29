--------------------------------------------------------
--  DDL for Package IGS_AD_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CAT_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSAI07S.pls 115.5 2003/10/30 13:10:12 akadam ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CITIZENSHIP_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

Function Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_s_citizenship_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_AD_CAT_PKG;

 

/
