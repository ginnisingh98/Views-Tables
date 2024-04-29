--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_REF_CD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1HS.pls 115.7 2003/05/09 06:39:12 sarakshi ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_UNIT_SECTION_REFERENCE_CD_ID IN OUT NOCOPY NUMBER,
      x_UNIT_SECTION_REFERENCE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'  ,
      x_reference_code_type  IN VARCHAR2 DEFAULT NULL,
      x_reference_code       IN VARCHAR2 DEFAULT NULL,
      x_reference_code_desc  IN VARCHAR2 DEFAULT NULL
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
      x_UNIT_SECTION_REFERENCE_CD_ID IN NUMBER,
      x_UNIT_SECTION_REFERENCE_ID IN NUMBER ,
      x_reference_code_type  IN VARCHAR2 DEFAULT NULL,
      x_reference_code       IN VARCHAR2 DEFAULT NULL,
      x_reference_code_desc  IN VARCHAR2 DEFAULT NULL);
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
      x_UNIT_SECTION_REFERENCE_CD_ID IN NUMBER,
      x_UNIT_SECTION_REFERENCE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'  ,
      x_reference_code_type  IN VARCHAR2 DEFAULT NULL,
      x_reference_code       IN VARCHAR2 DEFAULT NULL,
      x_reference_code_desc  IN VARCHAR2 DEFAULT NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_UNIT_SECTION_REFERENCE_CD_ID IN OUT NOCOPY NUMBER,
      x_UNIT_SECTION_REFERENCE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'  ,
      x_reference_code_type  IN VARCHAR2 DEFAULT NULL,
      x_reference_code       IN VARCHAR2 DEFAULT NULL,
      x_reference_code_desc  IN VARCHAR2 DEFAULT NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_reference_cd_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_unit_section_reference_id IN NUMBER,
    x_reference_code_type IN VARCHAR2,
    x_reference_code IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Usec_Ref (
    x_unit_section_reference_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ge_Ref_Cd_Type (
    x_reference_code_type IN VARCHAR2
    );

  PROCEDURE Get_UFK_Igs_Ge_Ref_Cd (
    x_reference_code_type IN VARCHAR2,
    x_reference_code  IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_reference_cd_id IN NUMBER DEFAULT NULL,
    x_unit_section_reference_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_reference_code_type  IN VARCHAR2 DEFAULT NULL,
    x_reference_code       IN VARCHAR2 DEFAULT NULL,
    x_reference_code_desc  IN VARCHAR2 DEFAULT NULL
 );
END igs_ps_usec_ref_cd_pkg;

 

/
