--------------------------------------------------------
--  DDL for Package IGS_PE_INCOME_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_INCOME_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI53S.pls 120.0 2005/06/02 00:19:03 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TAX_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER DEFAULT NULL,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_TAX_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER DEFAULT NULL,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE);
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_TAX_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER DEFAULT NULL,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_TAX_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_TAX_INFO IN VARCHAR2,
       x_TYPE_CODE IN VARCHAR2,
       x_TYPE_CODE_ID IN NUMBER DEFAULT NULL,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_tax_id IN NUMBER
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
    x_tax_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_tax_info IN VARCHAR2 DEFAULT NULL,
    x_type_code IN VARCHAR2 DEFAULT NULL,
    x_type_code_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );


END igs_pe_income_tax_pkg;

 

/
