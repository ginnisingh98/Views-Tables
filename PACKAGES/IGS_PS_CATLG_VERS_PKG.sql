--------------------------------------------------------
--  DDL for Package IGS_PS_CATLG_VERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_CATLG_VERS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1JS.pls 115.7 2002/11/29 02:07:20 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CATALOG_VERSION_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_CATALOG_SCHEDULE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID IN NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_CATALOG_VERSION IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_CATALOG_SCHEDULE IN VARCHAR2
       );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_CATALOG_VERSION_ID IN NUMBER,
       x_CATALOG_VERSION IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_CATALOG_SCHEDULE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CATALOG_VERSION_ID IN OUT NOCOPY NUMBER,
       x_CATALOG_VERSION IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_CATALOG_SCHEDULE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID IN NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_catalog_version_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_catalog_schedule IN VARCHAR2,
    x_catalog_version IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_catalog_version_id IN NUMBER DEFAULT NULL,
    x_catalog_version IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_catalog_schedule IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
 );
END igs_ps_catlg_vers_pkg;

 

/
