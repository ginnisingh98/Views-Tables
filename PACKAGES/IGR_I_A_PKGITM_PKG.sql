--------------------------------------------------------
--  DDL for Package IGR_I_A_PKGITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_A_PKGITM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRH18S.pls 120.0 2005/06/01 14:43:55 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL ,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENQUIRY_APPL_NUMBER in NUMBER,
  X_PACKAGE_ITEM_ID in NUMBER,
  X_MAILED_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL,
  X_ACTION IN VARCHAR2,
  X_ret_status     OUT NOCOPY VARCHAR2,
  X_msg_data       OUT NOCOPY VARCHAR2,
  X_msg_count      OUT NOCOPY NUMBER
  );
procedure DELETE_ROW (
 X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER,
    x_PACKAGE_ITEM_ID IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGR_I_APPL (
    x_person_id IN NUMBER,
    x_enquiry_appl_number IN NUMBER
    );

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_enquiry_appl_number IN NUMBER DEFAULT NULL,
    x_package_item_id IN NUMBER DEFAULT NULL,
    x_mailed_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_DONOT_MAIL_IND IN VARCHAR2 DEFAULT NULL
  );

end IGR_I_A_PKGITM_PKG;

 

/
