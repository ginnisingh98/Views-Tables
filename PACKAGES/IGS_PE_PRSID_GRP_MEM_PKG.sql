--------------------------------------------------------
--  DDL for Package IGS_PE_PRSID_GRP_MEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PRSID_GRP_MEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI22S.pls 115.9 2003/02/18 08:42:40 npalanis ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE
  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_group_id IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
 );
END igs_pe_prsid_grp_mem_pkg;

 

/
