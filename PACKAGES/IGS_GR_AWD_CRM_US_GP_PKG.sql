--------------------------------------------------------
--  DDL for Package IGS_GR_AWD_CRM_US_GP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GR_AWD_CRM_US_GP_PKG" AUTHID CURRENT_USER as
/* $Header: IGSGI06S.pls 115.4 2002/11/29 00:35:08 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_CEREMONY_NUMBER in NUMBER,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_US_GROUP_NUMBER in NUMBER,
  X_ORDER_IN_AWARD in NUMBER,
  X_OVERRIDE_TITLE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2,
    x_us_group_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_UFK_IGS_GR_AWD_CEREMONY (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER,
    x_ceremony_number IN NUMBER,
    x_award_course_cd IN VARCHAR2,
    x_award_crs_version_number IN NUMBER,
    x_award_cd IN VARCHAR2
    );

FUNCTION get_uk_for_validation(
	x_grd_cal_type IN VARCHAR2,
  	x_grd_ci_sequence_number IN NUMBER,
        x_ceremony_number IN NUMBER,
        x_award_course_cd IN VARCHAR2,
        x_award_crs_version_number IN NUMBER,
        x_award_cd IN VARCHAR2,
        x_order_in_award IN VARCHAR2
	) RETURN BOOLEAN;

PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ceremony_number IN NUMBER DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_us_group_number IN NUMBER DEFAULT NULL,
    x_order_in_award IN NUMBER DEFAULT NULL,
    x_override_title IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_GR_AWD_CRM_US_GP_PKG;

 

/
