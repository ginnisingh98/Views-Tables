--------------------------------------------------------
--  DDL for Package IGS_ST_GVT_SPSHT_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_GVT_SPSHT_CTL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSVI08S.pls 115.5 2002/11/29 04:32:45 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
  x_org_id in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    )
RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_EN_ST_SPSHT_CTL (
    x_ess_snapshot_dt_time IN DATE
    );

-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_ess_snapshot_dt_time IN DATE DEFAULT NULL,
    x_completion_dt IN DATE DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_ST_GVT_SPSHT_CTL_PKG;

 

/
