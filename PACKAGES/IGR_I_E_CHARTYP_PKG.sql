--------------------------------------------------------
--  DDL for Package IGR_I_E_CHARTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_E_CHARTYP_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRH04S.pls 120.0 2005/06/01 15:37:04 appldev noship $ */

PROCEDURE insert_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE lock_row (
  X_ROWID in VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
PROCEDURE update_row (
  X_ROWID in VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE add_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

FUNCTION get_pk_for_validation (
    x_enquiry_characteristic_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN;

 PROCEDURE check_constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

END igr_i_e_chartyp_pkg;

 

/
