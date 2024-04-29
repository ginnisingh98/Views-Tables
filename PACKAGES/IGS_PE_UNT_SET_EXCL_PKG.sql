--------------------------------------------------------
--  DDL for Package IGS_PE_UNT_SET_EXCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_UNT_SET_EXCL_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSNI35S.pls 115.3 2002/11/29 01:22:56 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PUSE_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PUSE_START_DT in DATE,
  X_EXPIRY_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PUSE_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ENCUMBRANCE_TYPE in VARCHAR2,
  X_PEN_START_DT in DATE,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_PEE_START_DT in DATE,
  X_PEE_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_PUSE_START_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_s_encmb_effect_type IN VARCHAR2,
    x_pen_start_dt IN DATE,
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_pee_start_dt IN DATE,
    x_pee_sequence_number IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER,
    x_puse_start_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PE_PERSENC_EFFCT (
    x_person_id IN NUMBER,
    x_encumbrance_type IN VARCHAR2,
    x_pen_start_dt IN DATE,
    x_s_encmb_effect_type IN VARCHAR2,
    x_pee_start_dt IN DATE,
    x_pee_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );
  PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_pee_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_puse_start_dt IN DATE DEFAULT NULL,
    x_expiry_dt IN DATE DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_encumbrance_type IN VARCHAR2 DEFAULT NULL,
    x_pen_start_dt IN DATE DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_pee_start_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PE_UNT_SET_EXCL_PKG;

 

/