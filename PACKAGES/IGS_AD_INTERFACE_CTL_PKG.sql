--------------------------------------------------------
--  DDL for Package IGS_AD_INTERFACE_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_INTERFACE_CTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA8S.pls 115.11 2003/12/09 12:44:51 pbondugu ship $ */
  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_INTERFACE_RUN_ID IN OUT NOCOPY NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
 );

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_INTERFACE_RUN_ID IN NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2
   );

 procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_INTERFACE_RUN_ID IN NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_INTERFACE_RUN_ID IN OUT NOCOPY NUMBER,
    x_SOURCE_TYPE_ID IN NUMBER,
    x_BATCH_ID IN NUMBER,
    x_MATCH_SET_ID IN NUMBER,
    x_STATUS IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
  ) ;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  ) ;

  FUNCTION Get_PK_For_Validation (
    x_interface_run_id IN NUMBER
  ) RETURN BOOLEAN ;


  PROCEDURE Get_FK_Igs_Pe_Src_Types (
    x_source_type_id IN NUMBER
  );


  PROCEDURE Get_FK_Igs_Pe_Match_Sets (
    x_match_set_id IN NUMBER
  );


  PROCEDURE Check_Constraints (
	  Column_Name IN VARCHAR2  DEFAULT NULL,
	  Column_Value IN VARCHAR2  DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_interface_run_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_batch_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_status IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );

END igs_ad_interface_ctl_pkg;

 

/
