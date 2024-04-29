--------------------------------------------------------
--  DDL for Package IGS_PS_UOFR_WLST_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UOFR_WLST_PRF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI97S.pls 115.6 2002/11/29 02:43:52 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_OFR_WL_PREF_ID IN OUT NOCOPY NUMBER,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_OFR_WL_PREF_ID IN NUMBER,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_OFR_WL_PREF_ID IN NUMBER,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_OFR_WL_PREF_ID IN OUT NOCOPY NUMBER,
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_ofr_wl_pref_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_preference_code IN VARCHAR2,
    x_preference_version IN VARCHAR2,
    x_unit_ofr_wl_priority_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Uofr_Wlst_Pri (
    x_unit_ofr_wl_priority_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_ofr_wl_pref_id IN NUMBER DEFAULT NULL,
    x_unit_ofr_wl_priority_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_uofr_wlst_prf_pkg;

 

/
