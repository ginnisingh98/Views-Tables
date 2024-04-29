--------------------------------------------------------
--  DDL for Package IGS_PE_DELIVERY_CDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DELIVERY_CDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI47S.pls 115.7 2002/11/29 01:25:13 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DELIVERY_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DELIVERY_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2
        );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DELIVERY_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'

  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DELIVERY_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_delivery_code IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_delivery_code IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
 );
END igs_pe_delivery_cds_pkg;

 

/
