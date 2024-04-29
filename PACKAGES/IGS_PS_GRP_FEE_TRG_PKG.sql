--------------------------------------------------------
--  DDL for Package IGS_PS_GRP_FEE_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_GRP_FEE_TRG_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI16S.pls 115.5 2003/02/20 10:16:52 shtatiko ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_CREATE_DT in out NOCOPY DATE,
  X_COURSE_GROUP_CD in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_CREATE_DT in DATE,
  X_COURSE_GROUP_CD in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_CREATE_DT in DATE,
  X_COURSE_GROUP_CD in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_CREATE_DT in out NOCOPY DATE,
  X_COURSE_GROUP_CD in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_course_group_cd IN VARCHAR2,
    x_create_dt IN DATE
    )
  RETURN BOOLEAN;

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_course_group_cd IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_GRP_FEE_TRG_PKG;

 

/
