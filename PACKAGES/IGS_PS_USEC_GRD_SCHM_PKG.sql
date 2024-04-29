--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_GRD_SCHM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_GRD_SCHM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0NS.pls 120.1 2005/10/04 00:39:48 appldev ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_GRAD_SCHEMA_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRD_SCHM_VERSION_NUMBER IN NUMBER,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_GRAD_SCHEMA_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRD_SCHM_VERSION_NUMBER IN NUMBER,
       x_DEFAULT_FLAG IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_GRAD_SCHEMA_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRD_SCHM_VERSION_NUMBER IN NUMBER,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_GRAD_SCHEMA_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_GRD_SCHM_VERSION_NUMBER IN NUMBER,
       x_DEFAULT_FLAG IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_grad_schema_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_grading_schema_code IN VARCHAR2,
    x_grd_schm_version_number IN NUMBER,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_As_Grd_Schema (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_grad_schema_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_grd_schm_version_number IN NUMBER DEFAULT NULL,
    x_default_flag IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_grd_schm_pkg;

 

/
