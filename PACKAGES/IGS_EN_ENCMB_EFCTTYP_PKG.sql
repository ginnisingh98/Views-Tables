--------------------------------------------------------
--  DDL for Package IGS_EN_ENCMB_EFCTTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ENCMB_EFCTTYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI32S.pls 115.6 2003/02/17 12:30:48 adhawan ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

FUNCTION Get_PK_For_Validation (
    x_s_encmb_effect_type IN VARCHAR2
    )
RETURN BOOLEAN;
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_apply_to_course_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
end IGS_EN_ENCMB_EFCTTYP_PKG;

 

/
