--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_PRV_GRAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_PRV_GRAD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0JS.pls 115.6 2002/11/29 01:57:30 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_PREV_GRADE_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_grad_schema_version_number IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_PREV_GRADE_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_grad_schema_version_number IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_PREV_GRADE_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_grad_schema_version_number IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_PREV_GRADE_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_GRADING_SCHEMA_CODE IN VARCHAR2,
       x_grad_schema_version_number IN NUMBER,
       x_GRADING_SCHEMA_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_prev_grade_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_grading_schema_value IN VARCHAR2,
    x_grad_schema_version_number IN NUMBER,
    x_uoo_id IN NUMBER,
    x_grading_schema_code IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_As_Grd_Sch_Grade (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_prev_grade_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_grading_schema_code IN VARCHAR2 DEFAULT NULL,
    x_grad_schema_version_number IN NUMBER DEFAULT NULL,
    x_grading_schema_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_prv_grad_pkg;

 

/
