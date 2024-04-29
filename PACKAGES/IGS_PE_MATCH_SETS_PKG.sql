--------------------------------------------------------
--  DDL for Package IGS_PE_MATCH_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_MATCH_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI66S.pls 120.0 2005/06/01 21:31:16 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MATCH_SET_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_EXCLUDE_INACTIVE_IND IN VARCHAR2 default 'N',
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER,
       X_primary_addr_flag IN VARCHAR2 DEFAULT 'N'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_primary_addr_flag IN VARCHAR2 DEFAULT 'N',
       x_exclude_inactive_ind IN VARCHAR2 DEFAULT 'N'
  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_MATCH_SET_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_primary_addr_flag IN VARCHAR2 DEFAULT 'N',
       x_EXCLUDE_INACTIVE_IND IN VARCHAR2 DEFAULT 'N',
      X_MODE in VARCHAR2 default 'R'

  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MATCH_SET_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       X_EXCLUDE_INACTIVE_IND IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER,
       x_primary_addr_flag IN VARCHAR2 DEFAULT 'N'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_match_set_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_PE_SRC_TYPES (
      X_source_type_id in number
      );

PROCEDURE GET_FK_IGS_PE_DUP_PAIRS (
      X_duplicate_pair_id in number
     );

FUNCTION Get_UK1_For_Validation (
    x_match_set_name IN VARCHAR2
    )
   RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_match_set_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_PARTIAL_IF_NULL IN VARCHAR2 DEFAULT NULL,
    x_EXCLUDE_INACTIVE_IND IN VARCHAR2 DEFAULT 'N',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_primary_addr_flag IN VARCHAR2 DEFAULT 'N',
    X_ORG_ID in NUMBER default NULL
  );
END igs_pe_match_sets_pkg;

 

/
