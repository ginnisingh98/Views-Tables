--------------------------------------------------------
--  DDL for Package IGS_OR_ORG_ACCR_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_ORG_ACCR_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI21S.pls 115.6 2002/11/29 01:42:22 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_AGENCY_ID IN VARCHAR2,
       x_ORG_ACCR_STATUS IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_AGENCY_ID IN VARCHAR2,
       x_ORG_ACCR_STATUS IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_AGENCY_ID IN VARCHAR2,
       x_ORG_ACCR_STATUS IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_STRUCTURE_ID IN VARCHAR2,
       x_ORG_STRUCTURE_TYPE IN VARCHAR2,
       x_ORG_AGENCY_ID IN VARCHAR2,
       x_ORG_ACCR_STATUS IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_org_accr_status IN VARCHAR2,
    x_org_agency_id IN VARCHAR2,
    x_org_structure_id IN VARCHAR2,
    x_org_structure_type IN VARCHAR2,
    x_start_date IN DATE
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Or_Org_Accr_Stat (
    x_org_accr_status IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Or_Institution (
    x_institution_cd IN VARCHAR2
    );

  PROCEDURE Get_Fk_Igs_Or_Unit (
    x_org_unit_cd IN VARCHAR2
    ) ;


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_structure_id IN VARCHAR2 DEFAULT NULL,
    x_org_structure_type IN VARCHAR2 DEFAULT NULL,
    x_org_agency_id IN VARCHAR2 DEFAULT NULL,
    x_org_accr_status IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_or_org_accr_dtls_pkg;

 

/
