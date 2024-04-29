--------------------------------------------------------
--  DDL for Package IGR_I_A_CHARTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_A_CHARTYP_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRH14S.pls 120.0 2005/06/01 15:47:09 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER,
    x_enquiry_characteristic_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGR_I_APPL (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER
    );

  PROCEDURE IGR_I_E_CHARTYP (
    x_enquiry_characteristic_type IN VARCHAR2
    );

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGR_I_A_CHARTYP_PKG;

 

/
