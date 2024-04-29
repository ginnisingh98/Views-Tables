--------------------------------------------------------
--  DDL for Package IGS_PR_OU_UNIT_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_OU_UNIT_SET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI08S.pls 115.4 2002/11/29 03:15:51 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_pro_sequence_number IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PR_RU_OU (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
  );
PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	);

end IGS_PR_OU_UNIT_SET_PKG;

 

/
