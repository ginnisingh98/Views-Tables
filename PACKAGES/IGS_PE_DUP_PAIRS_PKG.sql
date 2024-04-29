--------------------------------------------------------
--  DDL for Package IGS_PE_DUP_PAIRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DUP_PAIRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI68S.pls 115.8 2002/11/29 01:29:25 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DUPLICATE_PAIR_ID IN OUT NOCOPY NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DUPLICATE_PAIR_ID IN NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DUPLICATE_PAIR_ID IN NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DUPLICATE_PAIR_ID IN OUT NOCOPY NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_duplicate_pair_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_duplicate_pair_id IN NUMBER DEFAULT NULL,
    x_batch_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_actual_person_id IN NUMBER DEFAULT NULL,
    x_duplicate_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id IN NUMBER DEFAULT NULL,
    x_match_category IN VARCHAR2 DEFAULT NULL,
    x_dup_status IN VARCHAR2 DEFAULT NULL,
    x_address_type IN VARCHAR2 DEFAULT NULL,
    x_location_id IN NUMBER DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_pe_dup_pairs_pkg;

 

/
