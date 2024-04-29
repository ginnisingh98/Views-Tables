--------------------------------------------------------
--  DDL for Package IGS_AD_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI08S.pls 115.5 2003/10/30 13:10:15 akadam ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_ADMISSION_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_ADMISSION_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_ADMISSION_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAC_ADMISSION_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

Function Get_PK_For_Validation (
    x_admission_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_tac_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

PROCEDURE GET_FK_IGS_AD_BASIS_FOR_AD (
    x_basis_for_admission_type IN VARCHAR2
    );

PROCEDURE GET_FK_IGS_AD_TAC_AD_CD (
    x_tac_admission_cd IN VARCHAR2
    );

end IGS_AD_CD_PKG;

 

/
