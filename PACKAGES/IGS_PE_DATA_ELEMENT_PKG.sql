--------------------------------------------------------
--  DDL for Package IGS_PE_DATA_ELEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DATA_ELEMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI44S.pls 115.6 2002/11/29 01:24:27 nsidana ship $ */
  /*************************************************************
  Created By : nalkumar
  Date Created By : 2000/05/11
  Purpose : To create Table Handler.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_TABLE_NAME IN VARCHAR2,
       x_COLUMN_NAME IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_TABLE_NAME IN VARCHAR2,
       x_COLUMN_NAME IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_TABLE_NAME IN VARCHAR2,
       x_COLUMN_NAME IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_TABLE_NAME IN VARCHAR2,
       x_COLUMN_NAME IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_data_element IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_table_name IN VARCHAR2 DEFAULT NULL,
    x_column_name IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_pe_data_element_pkg;

 

/
