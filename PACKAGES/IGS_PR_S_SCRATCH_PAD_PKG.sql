--------------------------------------------------------
--  DDL for Package IGS_PR_S_SCRATCH_PAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_S_SCRATCH_PAD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI27S.pls 115.8 2002/11/29 03:21:15 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_CREATION_DT IN DATE,
       x_KEY IN VARCHAR2,
       x_MESSAGE_NAME IN VARCHAR2,
       x_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
       x_ORG_ID IN NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_CREATION_DT IN DATE,
       x_KEY IN VARCHAR2,
       x_MESSAGE_NAME IN VARCHAR2,
       x_TEXT IN VARCHAR2
       );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_CREATION_DT IN DATE,
       x_KEY IN VARCHAR2,
       x_MESSAGE_NAME IN VARCHAR2,
       x_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_CREATION_DT IN DATE,
       x_KEY IN VARCHAR2,
       x_MESSAGE_NAME IN VARCHAR2,
       x_TEXT IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
       x_ORG_ID IN NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_key IN VARCHAR2 DEFAULT NULL,
    x_message_name IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
 );
END igs_pr_s_scratch_pad_pkg;

 

/
