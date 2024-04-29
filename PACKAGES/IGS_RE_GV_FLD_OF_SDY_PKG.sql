--------------------------------------------------------
--  DDL for Package IGS_RE_GV_FLD_OF_SDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_GV_FLD_OF_SDY_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI07S.pls 115.3 2002/11/29 03:33:04 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_govt_field_of_study IN VARCHAR2
    ) RETURN BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_govt_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_res_fcd_class_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER  DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_RE_GV_FLD_OF_SDY_PKG;

 

/
