--------------------------------------------------------
--  DDL for Package IGS_PE_MTCH_SET_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_MTCH_SET_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI67S.pls 115.6 2002/11/29 01:29:08 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MATCH_SET_DATA_ID IN OUT NOCOPY NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_MATCH_SET_DATA_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2

 );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_MATCH_SET_DATA_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'

  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MATCH_SET_DATA_ID IN OUT NOCOPY NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_match_set_data_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_match_set_data_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_exact_include IN VARCHAR2 DEFAULT NULL,
    x_partial_include IN VARCHAR2 DEFAULT NULL,
    x_DROP_IF_NULL IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
 );
END igs_pe_mtch_set_data_pkg;

 

/
