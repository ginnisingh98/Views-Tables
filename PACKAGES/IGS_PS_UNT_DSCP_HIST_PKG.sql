--------------------------------------------------------
--  DDL for Package IGS_PS_UNT_DSCP_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNT_DSCP_HIST_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI77S.pls 115.4 2002/11/29 02:37:56 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);
 FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_discipline_group_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_DSCP (
    x_discipline_group_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );

end IGS_PS_UNT_DSCP_HIST_PKG;

 

/
