--------------------------------------------------------
--  DDL for Package IGS_GR_AWD_CEREMONY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_AWD_CEREMONY_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI02S.pls 115.7 2003/06/09 03:38:34 smvk ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWC_ID in out NOCOPY NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID  in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AWC_ID in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2

);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AWC_ID in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'

  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWC_ID in out NOCOPY NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_ORDER_IN_CEREMONY in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID  in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
        x_AWC_ID IN NUMBER
    ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
        x_grd_cal_type IN VARCHAR2,
        x_grd_ci_sequence_number IN NUMBER,
        x_ceremony_number IN NUMBER,
        x_award_course_cd IN VARCHAR2,
        x_award_crs_version_number IN NUMBER,
        x_award_cd IN VARCHAR2
    ) RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_GR_CRMN (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER
    );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_AWC_ID IN NUMBER DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_order_in_ceremony IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID  in NUMBER DEFAULT NULL
  );

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

end IGS_GR_AWD_CEREMONY_PKG;

 

/
