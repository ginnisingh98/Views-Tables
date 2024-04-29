--------------------------------------------------------
--  DDL for Package IGS_PE_PERS_RELATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERS_RELATION_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI31S.pls 120.0 2005/06/01 22:33:28 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_PERSON_ID_ALSO_RELATED_TO in NUMBER,
  X_PERSON_RELATION_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_PERSON_ID_ALSO_RELATED_TO in NUMBER,
  X_PERSON_RELATION_TYPE in VARCHAR2
);

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_person_id_also_related_to IN NUMBER,
    x_person_relation_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PE_PERS_RELN_TYP (
    x_person_relation_type IN VARCHAR2
    );
 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_person_id_also_related_to IN NUMBER DEFAULT NULL,
    x_person_relation_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PE_PERS_RELATION_PKG;

 

/
