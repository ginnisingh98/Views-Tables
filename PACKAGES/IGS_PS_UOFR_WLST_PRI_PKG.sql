--------------------------------------------------------
--  DDL for Package IGS_PS_UOFR_WLST_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UOFR_WLST_PRI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI96S.pls 115.7 2003/12/05 13:22:22 sarakshi ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_OFR_WL_PRIORITY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_OFR_WL_PRIORITY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_ofr_wl_priority_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_calender_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_priority_value IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Unit_Ofr_Pat (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_ofr_wl_priority_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_calender_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_uofr_wlst_pri_pkg;

 

/
