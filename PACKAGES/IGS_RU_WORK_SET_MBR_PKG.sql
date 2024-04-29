--------------------------------------------------------
--  DDL for Package IGS_RU_WORK_SET_MBR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_WORK_SET_MBR_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI16S.pls 115.4 2002/11/29 04:29:20 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RWS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RWS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
   x_rws_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN VARCHAR2
)return BOOLEAN;
PROCEDURE GET_FK_IGS_RU_WORK_SET (
    x_sequence_number IN NUMBER
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_rws_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_RU_WORK_SET_MBR_PKG;

 

/
