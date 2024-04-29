--------------------------------------------------------
--  DDL for Package IGS_AD_BASIS_FOR_AD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_BASIS_FOR_AD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI69S.pls 115.5 2003/10/30 13:16:30 akadam ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

FUNCTION Get_PK_For_Validation (
    x_basis_for_admission_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
)return BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE get_fk_igs_ad_gov_bas_fr_ty (
    x_govt_basis_for_adm_type IN VARCHAR2
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_basis_for_adm_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_AD_BASIS_FOR_AD_PKG;

 

/
