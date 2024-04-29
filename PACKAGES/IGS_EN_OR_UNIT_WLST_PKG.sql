--------------------------------------------------------
--  DDL for Package IGS_EN_OR_UNIT_WLST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_OR_UNIT_WLST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI33S.pls 115.9 2003/09/18 03:39:07 svanukur ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
       x_MODE in VARCHAR2 default 'R'  ,
       x_org_id IN NUMBER,
      x_CLOSED_FLAG IN VARCHAR2 DEFAULT 'N'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
       x_CLOSED_FLAG IN VARCHAR2 DEFAULT 'N'
         );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       x_CLOSED_FLAG IN VARCHAR2 DEFAULT 'N'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_CD IN VARCHAR2,
       x_START_DT IN DATE,
       x_CAL_TYPE IN VARCHAR2,
       x_MAX_STUD_PER_WLST IN NUMBER,
       x_SMTANUS_WLST_UNIT_ENR_ALWD IN VARCHAR2,
       x_ASSES_CHRG_FOR_WLST_STUD IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'  ,
       x_org_id IN NUMBER,
       x_CLOSED_FLAG IN VARCHAR2 DEFAULT 'N'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_org_unit_wlst_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Or_Unit (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    );

  PROCEDURE Get_FK_Igs_Ca_Inst (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ca_Type (
    x_cal_type IN VARCHAR2
       );
  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_wlst_id IN NUMBER DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_max_stud_per_wlst IN NUMBER DEFAULT NULL,
    x_smtanus_wlst_unit_enr_alwd IN VARCHAR2 DEFAULT NULL,
    x_asses_chrg_for_wlst_stud IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_closed_flag IN VARCHAR2 DEFAULT 'N'
 );
END igs_en_or_unit_wlst_pkg;

 

/
