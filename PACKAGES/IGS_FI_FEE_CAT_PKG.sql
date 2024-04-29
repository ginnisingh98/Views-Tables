--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_CAT_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI23S.pls 115.7 2002/11/29 03:44:01 nsidana ship $ */

PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CURRENCY_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE DELETE_ROW (
   X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2
    ) RETURN BOOLEAN;

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_currency_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id  in NUMBER default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
END igs_fi_fee_cat_pkg;

 

/
