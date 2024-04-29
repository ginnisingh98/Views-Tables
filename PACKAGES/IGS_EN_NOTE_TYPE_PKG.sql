--------------------------------------------------------
--  DDL for Package IGS_EN_NOTE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_NOTE_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI21S.pls 120.1 2005/09/08 14:27:09 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENR_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENR_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENR_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENR_NOTE_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENR_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENR_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENR_NOTE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_ENR_NOTE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
  x_enr_note_type IN VARCHAR2
  )
RETURN BOOLEAN;
PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
  x_s_enr_note_type IN VARCHAR2
  );
procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enr_note_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_enr_note_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );
end IGS_EN_NOTE_TYPE_PKG;

 

/
