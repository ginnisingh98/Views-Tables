--------------------------------------------------------
--  DDL for Package IGS_FI_ENC_DFLT_EFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ENC_DFLT_EFT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI16S.pls 115.5 2003/02/19 05:44:50 adhawan ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
   X_ROWID in VARCHAR2
);

PROCEDURE GET_FK_IGS_FI_ENCMB_TYPE (
    x_encumbrance_type IN VARCHAR2
    );

Function GET_PK_For_Validation (
    x_encumbrance_type IN VARCHAR2,
    x_s_encmb_effect_type IN VARCHAR2
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
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_FI_ENC_DFLT_EFT_PKG;

 

/
