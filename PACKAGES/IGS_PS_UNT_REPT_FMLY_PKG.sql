--------------------------------------------------------
--  DDL for Package IGS_PS_UNT_REPT_FMLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNT_REPT_FMLY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0AS.pls 115.6 2002/11/29 01:55:00 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_REPEAT_FAMILY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_REPEAT_FMLY_UNIT_CODE IN VARCHAR2,
       x_REPEAT_FMLY_UNIT_VERSION_NUM IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_REPEAT_FAMILY_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_REPEAT_FMLY_UNIT_CODE IN VARCHAR2,
       x_REPEAT_FMLY_UNIT_VERSION_NUM IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_REPEAT_FAMILY_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_REPEAT_FMLY_UNIT_CODE IN VARCHAR2,
       x_REPEAT_FMLY_UNIT_VERSION_NUM IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_REPEAT_FAMILY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_REPEAT_FMLY_UNIT_CODE IN VARCHAR2,
       x_REPEAT_FMLY_UNIT_VERSION_NUM IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_repeat_family_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_repeat_fmly_unit_code IN VARCHAR2,
    x_repeat_fmly_unit_version_num IN NUMBER,
    x_unit_code IN VARCHAR2,
    x_unit_version_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_repeat_family_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_repeat_fmly_unit_code IN VARCHAR2 DEFAULT NULL,
    x_repeat_fmly_unit_version_num IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_unt_rept_fmly_pkg;

 

/
