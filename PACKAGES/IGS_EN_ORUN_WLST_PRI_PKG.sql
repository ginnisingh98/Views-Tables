--------------------------------------------------------
--  DDL for Package IGS_EN_ORUN_WLST_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ORUN_WLST_PRI_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI34S.pls 115.7 2003/05/30 10:44:41 ptandon ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_PRI_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_PRI_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_WLST_ID IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_org_unit_wlst_pri_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_En_Or_Unit_Wlst (
    x_org_unit_wlst_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_priority_value IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_wlst_pri_id IN NUMBER DEFAULT NULL,
    x_org_unit_wlst_id IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_en_orun_wlst_pri_pkg;

 

/
