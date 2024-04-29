--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_AS_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_AS_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI76S.pls 120.5 2005/10/05 16:48:21 appldev ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FEE_ASS_ITEM_ID IN OUT NOCOPY NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER DEFAULT NULL,
       X_ORG_UNIT_CD IN VARCHAR2 DEFAULT NULL,
       X_CLASS_STANDING IN VARCHAR2 DEFAULT NULL,
       X_RESIDENCY_STATUS_CD IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R',
       X_UOO_ID IN NUMBER DEFAULT NULL,
       X_CHG_RATE IN VARCHAR2 DEFAULT NULL,
       x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
       x_us_version_number   IN NUMBER DEFAULT NULL,
       x_unit_type_id        IN NUMBER   DEFAULT NULL,
       x_unit_class          IN VARCHAR2 DEFAULT NULL,
       x_unit_mode           IN VARCHAR2 DEFAULT NULL,
       x_unit_level          IN VARCHAR2 DEFAULT NULL,
       x_scope_rul_sequence_num IN NUMBER   DEFAULT NULL,
       x_elm_rng_order_name     IN VARCHAR2 DEFAULT NULL,
       x_max_chg_elements       IN NUMBER   DEFAULT NULL
       );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_FEE_ASS_ITEM_ID IN NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER DEFAULT NULL,
       X_ORG_UNIT_CD IN VARCHAR2 DEFAULT NULL,
       X_CLASS_STANDING IN VARCHAR2 DEFAULT NULL,
       X_RESIDENCY_STATUS_CD IN VARCHAR2 DEFAULT NULL,
       X_UOO_ID IN NUMBER DEFAULT NULL,
       X_CHG_RATE IN VARCHAR2 DEFAULT NULL,
       x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
       x_us_version_number   IN NUMBER DEFAULT NULL,
       x_unit_type_id        IN NUMBER   DEFAULT NULL,
       x_unit_class          IN VARCHAR2 DEFAULT NULL,
       x_unit_mode           IN VARCHAR2 DEFAULT NULL,
       x_unit_level          IN VARCHAR2 DEFAULT NULL,
       x_scope_rul_sequence_num IN NUMBER   DEFAULT NULL,
       x_elm_rng_order_name     IN VARCHAR2 DEFAULT NULL,
       x_max_chg_elements       IN NUMBER   DEFAULT NULL
      );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_FEE_ASS_ITEM_ID IN NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER DEFAULT NULL,
       X_ORG_UNIT_CD IN VARCHAR2 DEFAULT NULL,
       X_CLASS_STANDING IN VARCHAR2 DEFAULT NULL,
       X_RESIDENCY_STATUS_CD IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'  ,
       X_UOO_ID IN NUMBER DEFAULT NULL,
       X_CHG_RATE IN VARCHAR2 DEFAULT NULL,
       x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
       x_us_version_number   IN NUMBER DEFAULT NULL,
       x_unit_type_id        IN NUMBER   DEFAULT NULL,
       x_unit_class          IN VARCHAR2 DEFAULT NULL,
       x_unit_mode           IN VARCHAR2 DEFAULT NULL,
       x_unit_level          IN VARCHAR2 DEFAULT NULL,
       x_scope_rul_sequence_num IN NUMBER   DEFAULT NULL,
       x_elm_rng_order_name     IN VARCHAR2 DEFAULT NULL,
       x_max_chg_elements       IN NUMBER   DEFAULT NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FEE_ASS_ITEM_ID IN OUT NOCOPY NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER DEFAULT NULL,
       X_ORG_UNIT_CD IN VARCHAR2 DEFAULT NULL,
       X_CLASS_STANDING IN VARCHAR2 DEFAULT NULL,
       X_RESIDENCY_STATUS_CD IN VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R' ,
       X_UOO_ID IN NUMBER DEFAULT NULL,
       X_CHG_RATE IN VARCHAR2 DEFAULT NULL,
       x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
       x_us_version_number   IN NUMBER DEFAULT NULL,
       x_unit_type_id        IN NUMBER   DEFAULT NULL,
       x_unit_class          IN VARCHAR2 DEFAULT NULL,
       x_unit_mode           IN VARCHAR2 DEFAULT NULL,
       x_unit_level          IN VARCHAR2 DEFAULT NULL,
       x_scope_rul_sequence_num IN NUMBER   DEFAULT NULL,
       x_elm_rng_order_name     IN VARCHAR2 DEFAULT NULL,
       x_max_chg_elements       IN NUMBER   DEFAULT NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;


  FUNCTION Get_PK_For_Validation (
    x_fee_ass_item_id IN NUMBER
    ) RETURN BOOLEAN ;


  FUNCTION Get_UK_For_Validation (
    x_TRANSACTION_ID IN NUMBER,
    x_person_id IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_crs_version_number IN NUMBER,
    x_fee_cal_type IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    X_UOO_ID IN NUMBER DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  DEFAULT NULL,
                 Column_Value IN VARCHAR2  DEFAULT NULL ) ;


 PROCEDURE GET_FK_IGS_FI_FEE_AS (
      x_person_id IN NUMBER,
      x_transaction_id IN NUMBER
      );


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_ass_item_id IN NUMBER DEFAULT NULL,
    x_TRANSACTION_ID IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_status IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_RUL_SEQUENCE_NUMBER IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_chg_elements IN NUMBER DEFAULT NULL,
    x_amount IN NUMBER DEFAULT NULL,
    x_fee_effective_dt IN DATE DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crs_version_number IN NUMBER DEFAULT NULL,
    x_course_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_credit_points IN NUMBER DEFAULT NULL,
    x_logical_delete_date IN DATE DEFAULT NULL,
    X_INVOICE_ID IN NUMBER DEFAULT NULL,
    X_ORG_UNIT_CD IN VARCHAR2 DEFAULT NULL,
    X_CLASS_STANDING IN VARCHAR2 DEFAULT NULL,
    X_RESIDENCY_STATUS_CD IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_UOO_ID IN NUMBER DEFAULT NULL,
    X_CHG_RATE IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd         IN VARCHAR2 DEFAULT NULL,
    x_us_version_number   IN NUMBER DEFAULT NULL,
    x_unit_type_id        IN NUMBER   DEFAULT NULL,
    x_unit_class          IN VARCHAR2 DEFAULT NULL,
    x_unit_mode           IN VARCHAR2 DEFAULT NULL,
    x_unit_level          IN VARCHAR2 DEFAULT NULL,
    x_scope_rul_sequence_num IN NUMBER   DEFAULT NULL,
    x_elm_rng_order_name     IN VARCHAR2 DEFAULT NULL,
    x_max_chg_elements       IN NUMBER   DEFAULT NULL
 );

 PROCEDURE get_fk_igs_en_unit_set_all (
           x_unit_set_cd       IN VARCHAR2,
           x_us_version_number IN NUMBER
      );

END igs_fi_fee_as_items_pkg;

 

/
