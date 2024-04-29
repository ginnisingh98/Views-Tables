--------------------------------------------------------
--  DDL for Package IGS_PE_PRSID_GRP_SEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PRSID_GRP_SEC_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI23S.pls 115.5 2003/02/18 08:47:25 npalanis ship $ */



procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_INSERT_IND in VARCHAR2,
  X_UPDATE_IND in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_group_id IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_insert_ind IN VARCHAR2 DEFAULT NULL,
    x_update_ind IN VARCHAR2 DEFAULT NULL,
    x_delete_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


end IGS_PE_PRSID_GRP_SEC_PKG;

 

/
