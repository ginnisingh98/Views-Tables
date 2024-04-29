--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_NEAR_MTCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_NEAR_MTCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB2S.pls 115.12 2003/05/22 13:17:28 npalanis ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_NEAR_MTCH_ID IN OUT NOCOPY NUMBER,
       x_INTERFACE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MATCH_IND IN VARCHAR2,
       x_ACTION IN VARCHAR2,
       x_ADDR_TYPE IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R',
      x_party_site_id IN NUMBER  ,
      X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_NEAR_MTCH_ID IN NUMBER,
       x_INTERFACE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MATCH_IND IN VARCHAR2,
       x_ACTION IN VARCHAR2,
       x_ADDR_TYPE IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
       x_party_site_id IN NUMBER ,
      X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL);

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_NEAR_MTCH_ID IN NUMBER,
       x_INTERFACE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MATCH_IND IN VARCHAR2,
       x_ACTION IN VARCHAR2,
       x_ADDR_TYPE IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R',
      x_party_site_id IN NUMBER  ,
      X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_NEAR_MTCH_ID IN OUT NOCOPY NUMBER,
       x_INTERFACE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MATCH_IND IN VARCHAR2,
       x_ACTION IN VARCHAR2,
       x_ADDR_TYPE IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R',
      x_party_site_id IN NUMBER   ,
      X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
  ) ;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
    );

  FUNCTION Get_PK_For_Validation (
    x_near_mtch_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Interface (
    x_interface_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Co_Addr_Type (
    x_addr_type IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Pe_Match_Sets (
    x_match_set_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_near_mtch_id IN NUMBER DEFAULT NULL,
    x_interface_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_match_ind IN VARCHAR2 DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_addr_type IN VARCHAR2 DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_party_site_id IN NUMBER DEFAULT NULL,
    X_INTERFACE_RELATIONS_ID IN NUMBER DEFAULT NULL
 );
END igs_ad_imp_near_mtch_pkg;

 

/
