--------------------------------------------------------
--  DDL for Package IGS_GR_APRV_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_APRV_STAT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI01S.pls 115.4 2003/02/25 10:08:06 ddey ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_GRADUAND_APPR_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_GRADUAND_APPR_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_GRADUAND_APPR_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_GRADUAND_APPR_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

FUNCTION Get_PK_For_Validation (
  x_graduand_appr_status IN VARCHAR2
) RETURN BOOLEAN ;

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_graduand_appr_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_graduand_appr_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_GR_APRV_STAT_PKG;

 

/
