--------------------------------------------------------
--  DDL for Package IGS_PR_MS_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_MS_STAT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSQI04S.pls 115.4 2002/11/29 03:14:26 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_MILESTONE_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_MILESTONE_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_MILESTONE_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MILESTONE_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_MILESTONE_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

 FUNCTION Get_PK_For_Validation (
    x_milestone_status IN VARCHAR2
    )
 RETURN BOOLEAN;

 PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_milestone_status IN VARCHAR2
    );

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_milestone_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_milestone_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
  );

end IGS_PR_MS_STAT_PKG;

 

/
