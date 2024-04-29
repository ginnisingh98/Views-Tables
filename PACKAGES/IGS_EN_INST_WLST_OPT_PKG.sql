--------------------------------------------------------
--  DDL for Package IGS_EN_INST_WLST_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_INST_WLST_OPT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI16S.pls 115.8 2003/09/02 08:37:58 svanukur ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_INST_WAITLIST_ID IN OUT NOCOPY NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_INST_WAITLIST_ID IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_INST_WAITLIST_ID IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_INST_WAITLIST_ID IN OUT NOCOPY NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_inst_waitlist_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_cal_type IN VARCHAR2

    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ca_Type (
    x_cal_type IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ca_Inst (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_inst_waitlist_id IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_waitlist_alwd IN VARCHAR2 DEFAULT NULL,
    x_smlnes_waitlist_alwd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_en_inst_wlst_opt_pkg;

 

/
