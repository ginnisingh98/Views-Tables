--------------------------------------------------------
--  DDL for Package IGS_PS_DSCP_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_DSCP_HIST_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSPI53S.pls 115.4 2002/11/29 02:30:58 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_discipline_group_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    )RETURN BOOLEAN;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_funding_index_1 IN NUMBER DEFAULT NULL,
    x_funding_index_2 IN NUMBER DEFAULT NULL,
    x_funding_index_3 IN NUMBER DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_DSCP_HIST_PKG;

 

/
