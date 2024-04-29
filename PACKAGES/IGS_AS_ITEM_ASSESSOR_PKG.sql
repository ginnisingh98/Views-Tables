--------------------------------------------------------
--  DDL for Package IGS_AS_ITEM_ASSESSOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ITEM_ASSESSOR_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI02S.pls 120.0 2005/07/05 13:06:48 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ASS_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_ASS_ASSESSOR_TYPE in VARCHAR2,
  X_PRIMARY_ASSESSOR_IND in VARCHAR2,
  X_ITEM_LIMIT in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_ass_id IN NUMBER,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_ASSESSMNT_ITM (
    x_ass_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_ASSESSOR_TYPE (
    x_ass_assessor_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    );





PROCEDURE Check_Constraints (





	Column_Name	IN	VARCHAR2	DEFAULT NULL,





	Column_Value 	IN	VARCHAR2	DEFAULT NULL





);

















  PROCEDURE Before_DML (





    p_action IN VARCHAR2,





    x_rowid IN VARCHAR2 DEFAULT NULL,





    x_person_id IN NUMBER DEFAULT NULL,





    x_sequence_number IN NUMBER DEFAULT NULL,





    x_ass_assessor_type IN VARCHAR2 DEFAULT NULL,





    x_primary_assessor_ind IN VARCHAR2 DEFAULT NULL,





    x_item_limit IN NUMBER DEFAULT NULL,





    x_location_cd IN VARCHAR2 DEFAULT NULL,





    x_unit_mode IN VARCHAR2 DEFAULT NULL,





    x_unit_class IN VARCHAR2 DEFAULT NULL,





    x_comments IN VARCHAR2 DEFAULT NULL,





    x_ass_id IN NUMBER DEFAULT NULL,





    x_creation_date IN DATE DEFAULT NULL,





    x_created_by IN NUMBER DEFAULT NULL,





    x_last_update_date IN DATE DEFAULT NULL,





    x_last_updated_by IN NUMBER DEFAULT NULL,





    x_last_update_login IN NUMBER DEFAULT NULL





  ) ;













end IGS_AS_ITEM_ASSESSOR_PKG;

 

/
