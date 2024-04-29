--------------------------------------------------------
--  DDL for Package IGS_FI_ENCMB_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ENCMB_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI17S.pls 115.6 2003/02/19 05:45:40 adhawan ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENCUMBRANCE_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_org_id in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENCUMBRANCE_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENCUMBRANCE_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENCUMBRANCE_CAT in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  x_org_id in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );

Function GET_PK_For_Validation (
    x_encumbrance_type IN VARCHAR2
)
return Boolean;
Procedure Check_Constraints (
	Column_name 	IN	VARCHAR2 DEFAULT NULL,
	COLUMN_VALUE	IN	VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_encumbrance_cat IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_FI_ENCMB_TYPE_PKG;

 

/
