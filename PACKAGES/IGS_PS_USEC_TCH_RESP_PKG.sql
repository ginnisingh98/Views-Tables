--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_TCH_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_TCH_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1ES.pls 120.1 2005/10/04 00:37:55 appldev ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_TEACH_RESP_ID IN OUT NOCOPY NUMBER,
       x_INSTRUCTOR_ID IN NUMBER,
       x_CONFIRMED_FLAG IN VARCHAR2,
       x_PERCENTAGE_ALLOCATION IN NUMBER,
       x_INSTRUCTIONAL_LOAD IN NUMBER,
       x_LEAD_INSTRUCTOR_FLAG IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_instructional_load_lab IN NUMBER DEFAULT NULL,
       x_instructional_load_lecture IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_TEACH_RESP_ID IN NUMBER,
       x_INSTRUCTOR_ID IN NUMBER,
       x_CONFIRMED_FLAG IN VARCHAR2,
       x_PERCENTAGE_ALLOCATION IN NUMBER,
       x_INSTRUCTIONAL_LOAD IN NUMBER,
       x_LEAD_INSTRUCTOR_FLAG IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_instructional_load_lab IN NUMBER DEFAULT NULL,
       x_instructional_load_lecture IN NUMBER DEFAULT NULL  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_SECTION_TEACH_RESP_ID IN NUMBER,
       x_INSTRUCTOR_ID IN NUMBER,
       x_CONFIRMED_FLAG IN VARCHAR2,
       x_PERCENTAGE_ALLOCATION IN NUMBER,
       x_INSTRUCTIONAL_LOAD IN NUMBER,
       x_LEAD_INSTRUCTOR_FLAG IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_instructional_load_lab IN NUMBER DEFAULT NULL,
       x_instructional_load_lecture IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_TEACH_RESP_ID IN OUT NOCOPY NUMBER,
       x_INSTRUCTOR_ID IN NUMBER,
       x_CONFIRMED_FLAG IN VARCHAR2,
       x_PERCENTAGE_ALLOCATION IN NUMBER,
       x_INSTRUCTIONAL_LOAD IN NUMBER,
       x_LEAD_INSTRUCTOR_FLAG IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_instructional_load_lab IN NUMBER DEFAULT NULL,
       x_instructional_load_lecture IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_teach_resp_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER,
    x_instructor_id IN NUMBER
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
    x_unit_section_teach_resp_id IN NUMBER DEFAULT NULL,
    x_instructor_id IN NUMBER DEFAULT NULL,
    x_confirmed_flag IN VARCHAR2 DEFAULT NULL,
    x_percentage_allocation IN NUMBER DEFAULT NULL,
    x_instructional_load IN NUMBER DEFAULT NULL,
    x_lead_instructor_flag IN VARCHAR2 DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_instructional_load_lab IN NUMBER DEFAULT NULL,
       x_instructional_load_lecture IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_tch_resp_pkg;

 

/
