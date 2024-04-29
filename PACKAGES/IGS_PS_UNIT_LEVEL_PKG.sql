--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_LEVEL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI81S.pls 115.6 2003/06/05 13:12:39 sarakshi ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_WAM_WEIGHTING in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );

 FUNCTION Get_PK_For_Validation (
    x_unit_level IN VARCHAR2
    ) RETURN BOOLEAN;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_wam_weighting IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );


end IGS_PS_UNIT_LEVEL_PKG;

 

/
