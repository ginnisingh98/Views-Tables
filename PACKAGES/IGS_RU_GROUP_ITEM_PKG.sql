--------------------------------------------------------
--  DDL for Package IGS_RU_GROUP_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GROUP_ITEM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI05S.pls 115.4 2002/11/29 04:26:07 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID  	in VARCHAR2,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_rug_sequence_number IN NUMBER,
    x_description_number IN NUMBER,
    x_description_type IN VARCHAR2
    ) RETURN BOOLEAN ;

PROCEDURE GET_FK_IGS_RU_GROUP (
    x_sequence_number IN NUMBER
    );

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    DEFAULT NULL ,
                 Column_Value    IN   VARCHAR2    DEFAULT NULL
                                )  ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_rug_sequence_number IN NUMBER DEFAULT NULL,
    x_description_number IN NUMBER DEFAULT NULL,
    x_description_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


end IGS_RU_GROUP_ITEM_PKG;

 

/
