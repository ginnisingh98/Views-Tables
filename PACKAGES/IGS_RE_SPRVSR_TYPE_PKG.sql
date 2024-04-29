--------------------------------------------------------
--  DDL for Package IGS_RE_SPRVSR_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_SPRVSR_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI14S.pls 115.3 2002/11/29 03:35:24 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRINCIPAL_SUPERVISOR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRINCIPAL_SUPERVISOR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRINCIPAL_SUPERVISOR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RESEARCH_SUPERVISOR_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_PRINCIPAL_SUPERVISOR_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_research_supervisor_type IN VARCHAR2
    )
  RETURN BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_research_supervisor_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_principal_supervisor_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_RE_SPRVSR_TYPE_PKG;

 

/