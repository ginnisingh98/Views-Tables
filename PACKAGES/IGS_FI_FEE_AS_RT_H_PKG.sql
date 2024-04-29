--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_AS_RT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_AS_RT_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI21S.pls 120.1 2005/06/05 20:11:55 appldev  $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 DEFAULT NULL,
  X_COURSE_CD  in VARCHAR2 DEFAULT NULL,
  X_VERSION_NUMBER in NUMBER DEFAULT NULL,
  X_ORG_PARTY_ID in NUMBER DEFAULT NULL,
  X_CLASS_STANDING  in VARCHAR2 DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
  x_us_version_number   IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL
  );

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 DEFAULT NULL,
  X_COURSE_CD  in VARCHAR2 DEFAULT NULL,
  X_VERSION_NUMBER in NUMBER DEFAULT NULL,
  X_ORG_PARTY_ID in NUMBER DEFAULT NULL,
  X_CLASS_STANDING  in VARCHAR2 DEFAULT NULL,
  x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
  x_us_version_number   IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL
);

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 DEFAULT NULL,
  X_COURSE_CD  in VARCHAR2 DEFAULT NULL,
  X_VERSION_NUMBER in NUMBER DEFAULT NULL,
  X_ORG_PARTY_ID in NUMBER DEFAULT NULL,
  X_CLASS_STANDING  in VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
  x_us_version_number   IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL
  );

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 DEFAULT NULL,
  X_COURSE_CD  in VARCHAR2 DEFAULT NULL,
  X_VERSION_NUMBER in NUMBER DEFAULT NULL,
  X_ORG_PARTY_ID in NUMBER DEFAULT NULL,
  X_CLASS_STANDING  in VARCHAR2 DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
  x_us_version_number   IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL
  );

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

Function GET_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_rate_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
return Boolean;

Procedure Check_Constraints (
        Column_name     IN      VARCHAR2 DEFAULT NULL,
        COLUMN_VALUE    IN      VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_chg_rate IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_rate_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_order_of_precedence IN NUMBER DEFAULT NULL,
    x_govt_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_cntrbtn_band IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_residency_status_cd  IN VARCHAR2 DEFAULT NULL,
    x_course_cd  IN VARCHAR2 DEFAULT NULL,
    x_version_number  IN NUMBER DEFAULT NULL,
    x_org_party_id  IN NUMBER DEFAULT NULL,
    x_class_standing  IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
    x_us_version_number   IN NUMBER   DEFAULT NULL,
    x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number         IN NUMBER   DEFAULT NULL,
    x_unit_level                  IN VARCHAR2 DEFAULT NULL,
    x_unit_type_id                IN NUMBER   DEFAULT NULL,
    x_unit_mode                   IN VARCHAR2 DEFAULT NULL
  ) ;

Function GET_UK_FOR_VALIDATION (
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_rate_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL
)Return Boolean;

END igs_fi_fee_as_rt_h_pkg;

 

/
