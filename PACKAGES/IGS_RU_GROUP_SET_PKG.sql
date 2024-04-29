--------------------------------------------------------
--  DDL for Package IGS_RU_GROUP_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GROUP_SET_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI06S.pls 115.4 2002/11/29 04:26:25 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_rug_sequence_number IN NUMBER,
    x_rud_sequence_number IN NUMBER
    ) RETURN BOOLEAN ;

PROCEDURE GET_FK_IGS_RU_DESCRIPTION (
    x_sequence_number IN NUMBER
    );

PROCEDURE GET_FK_IGS_RU_GROUP (
    x_sequence_number IN NUMBER
    );

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    DEFAULT NULL ,
                 Column_Value    IN   VARCHAR2    DEFAULT NULL
                                );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_rug_sequence_number IN NUMBER DEFAULT NULL,
    x_rud_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_RU_GROUP_SET_PKG;

 

/
