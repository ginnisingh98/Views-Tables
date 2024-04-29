--------------------------------------------------------
--  DDL for Package IGS_FI_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ACC_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI02S.pls 115.12 2003/02/17 05:20:26 pathipat ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACCOUNT_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );

Function GET_PK_For_Validation (
       x_account_cd IN VARCHAR2
    )
return Boolean;

Procedure Check_Constraints (
	Column_name 	IN	VARCHAR2 DEFAULT NULL,
	COLUMN_VALUE	IN	VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_account_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_FI_ACC_PKG;

 

/
