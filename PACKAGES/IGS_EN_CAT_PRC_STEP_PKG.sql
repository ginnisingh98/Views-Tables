--------------------------------------------------------
--  DDL for Package IGS_EN_CAT_PRC_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_CAT_PRC_STEP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI25S.pls 115.6 2003/06/11 06:28:14 rnirwani ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_enrolment_cat IN VARCHAR2,
    x_s_student_comm_type IN VARCHAR2,
    x_enr_method_type IN VARCHAR2,
    x_s_enrolment_step_type IN VARCHAR2
    )
RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_EN_CAT_PRC_DTL (
    x_enrolment_cat IN VARCHAR2,
    x_s_student_comm_type IN VARCHAR2,
    x_enr_method_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_enrolment_step_type IN VARCHAR2
    );
procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_s_student_comm_type IN VARCHAR2 DEFAULT NULL,
    x_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_s_enrolment_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_order_num IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  );
end IGS_EN_CAT_PRC_STEP_PKG;

 

/
