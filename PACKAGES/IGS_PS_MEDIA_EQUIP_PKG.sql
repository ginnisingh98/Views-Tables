--------------------------------------------------------
--  DDL for Package IGS_PS_MEDIA_EQUIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_MEDIA_EQUIP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0DS.pls 115.7 2002/11/29 01:55:53 nsidana ship $ */
/*************************************************************
  Created By : sbeerell
  Date Created By : 10-MAY-2000
  Purpose : Created for DLD Version 2
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MEDIA_CODE IN VARCHAR2,
       x_MEDIA_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID IN NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_MEDIA_CODE IN VARCHAR2,
       x_MEDIA_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_MEDIA_CODE IN VARCHAR2,
       x_MEDIA_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_MEDIA_CODE IN VARCHAR2,
      x_MEDIA_DESCRIPTION IN VARCHAR2,
      x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID IN NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_media_code IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_media_code IN VARCHAR2 DEFAULT NULL,
    x_media_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL
 );
END igs_ps_media_equip_pkg;

 

/
