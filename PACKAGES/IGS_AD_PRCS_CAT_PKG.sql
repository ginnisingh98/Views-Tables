--------------------------------------------------------
--  DDL for Package IGS_AD_PRCS_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PRCS_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI09S.pls 115.12 2003/10/30 13:11:07 akadam ship $ */
 PROCEDURE INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			x_ORG_ID IN NUMBER,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );

 PROCEDURE LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
       X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
       );
 PROCEDURE UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
      X_MODE in VARCHAR2 default 'R' ,
     X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  );

 PROCEDURE ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			x_ORG_ID IN NUMBER,
       x_ADMISSION_CAT IN VARCHAR2,
       x_S_ADMISSION_PROCESS_TYPE IN VARCHAR2,
       x_OFFER_RESPONSE_OFFSET IN NUMBER,
      X_MODE in VARCHAR2 default 'R'  ,
     X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) ;

PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2
) ;

  FUNCTION Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Cat (
    x_admission_cat IN VARCHAR2
    );


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_admission_process_type IN VARCHAR2
    ) ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
			x_ORG_ID IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_offer_response_offset IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
 );
END igs_ad_prcs_cat_pkg;

 

/
