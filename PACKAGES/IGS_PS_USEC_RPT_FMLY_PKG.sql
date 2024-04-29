--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_RPT_FMLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_RPT_FMLY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0IS.pls 115.6 2002/11/29 01:57:14 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_RPT_FAMILY_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_REPEAT_FAMILY_UNIT_CD IN VARCHAR2,
       x_RPT_FAMILY_VER_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_RPT_FAMILY_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_REPEAT_FAMILY_UNIT_CD IN VARCHAR2,
       x_RPT_FAMILY_VER_NUMBER IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_RPT_FAMILY_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_REPEAT_FAMILY_UNIT_CD IN VARCHAR2,
       x_RPT_FAMILY_VER_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_RPT_FAMILY_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_REPEAT_FAMILY_UNIT_CD IN VARCHAR2,
       x_RPT_FAMILY_VER_NUMBER IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_UNIT_SECTION_RPT_FAMILY_ID IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_repeat_family_unit_cd IN VARCHAR2,
    x_RPT_FAMILY_VER_NUMBER IN NUMBER,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    );

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
    x_UNIT_SECTION_RPT_FAMILY_ID IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_repeat_family_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_RPT_FAMILY_VER_NUMBER IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_rpt_fmly_pkg;

 

/
