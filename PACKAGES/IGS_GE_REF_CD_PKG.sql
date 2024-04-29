--------------------------------------------------------
--  DDL for Package IGS_GE_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_REF_CD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSMI16S.pls 115.6 2002/11/29 01:13:17 nsidana ship $ */
/*************************************************************
  Created By : sbeerell
  Date Created By : 09-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
***************************************************************/

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_REFERENCE_CODE_ID IN OUT NOCOPY NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_REFERENCE_CODE_ID IN NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_REFERENCE_CODE_ID IN NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_REFERENCE_CODE_ID IN OUT NOCOPY NUMBER,
       x_REFERENCE_CD_TYPE IN VARCHAR2,
       x_REFERENCE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_reference_code_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_reference_cd_type IN VARCHAR2,
    x_reference_cd IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ge_Ref_Cd_Type (
    x_reference_cd_type IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_code_id IN NUMBER DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_default_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ge_ref_cd_pkg;

 

/
