--------------------------------------------------------
--  DDL for Package IGS_PE_VOTE_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_VOTE_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI50S.pls 120.0 2005/06/01 22:08:01 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_VOTER_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER ,
      x_TYPE_CODE_ID IN NUMBER DEFAULT NULL
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_VOTER_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE  ,
           x_TYPE_CODE_ID IN NUMBER  DEFAULT NULL
     );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_VOTER_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'  ,
             x_TYPE_CODE_ID IN NUMBER  DEFAULT NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_VOTER_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_VOTER_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_VOTER_REGN_ST_DATE IN DATE,
       x_VOTER_REGN_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER ,
             x_TYPE_CODE_ID IN NUMBER  DEFAULT NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_voter_id IN NUMBER
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
    x_voter_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_voter_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_voter_regn_st_date IN DATE DEFAULT NULL,
    x_voter_regn_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
 );
END igs_pe_vote_info_pkg;

 

/
