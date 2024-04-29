--------------------------------------------------------
--  DDL for Package IGS_PS_USEC_LIM_WLST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USEC_LIM_WLST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1LS.pls 120.1 2005/10/04 00:36:57 appldev ship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_unit_section_limit_wlst_id IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER DEFAULT NULL,
       x_max_auditors_allowed IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
       X_ROWID in  VARCHAR2,
       x_unit_section_limit_wlst_id IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER DEFAULT NULL,
       x_max_auditors_allowed IN NUMBER DEFAULT NULL
       );
 procedure UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_unit_section_limit_wlst_id IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER DEFAULT NULL,
       x_max_auditors_allowed IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_unit_section_limit_wlst_id IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ENROLLMENT_EXPECTED IN NUMBER,
       x_ENROLLMENT_MINIMUM IN NUMBER,
       x_ENROLLMENT_MAXIMUM IN NUMBER,
       x_ADVANCE_MAXIMUM IN NUMBER,
       x_WAITLIST_ALLOWED IN VARCHAR2,
       x_MAX_STUDENTS_PER_WAITLIST IN NUMBER,
       X_OVERRIDE_ENROLLMENT_MAX IN NUMBER DEFAULT NULL,
       x_max_auditors_allowed IN NUMBER DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_unit_section_limit_wlst_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER
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
    x_unit_section_limit_wlst_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_enrollment_expected IN NUMBER DEFAULT NULL,
    x_enrollment_minimum IN NUMBER DEFAULT NULL,
    x_enrollment_maximum IN NUMBER DEFAULT NULL,
    x_advance_maximum IN NUMBER DEFAULT NULL,
    x_waitlist_allowed IN VARCHAR2 DEFAULT NULL,
    x_max_students_per_waitlist IN NUMBER DEFAULT NULL,
    X_OVERRIDE_ENROLLMENT_MAX IN NUMBER DEFAULT NULL,
    x_max_auditors_allowed IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_usec_lim_wlst_pkg;

 

/
