--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_SPNSRSHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_SPNSRSHP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1DS.pls 115.6 2002/11/29 02:05:35 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_SPONSORSHIP_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_SPONSORSHIP_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_SPONSORSHIP_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_SPONSORSHIP_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_sponsorship_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER,
    x_organization_code IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_sponsorship_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_organization_code IN VARCHAR2 DEFAULT NULL,
    x_sponsorship_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_spnsrshp_pkg;

 

/
