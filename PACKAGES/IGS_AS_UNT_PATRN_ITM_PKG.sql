--------------------------------------------------------
--  DDL for Package IGS_AS_UNT_PATRN_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_UNT_PATRN_ITM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSDI32S.pls 120.0 2005/07/05 11:24:54 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_ID in NUMBER,
  X_UAI_SEQUENCE_NUMBER in NUMBER,
  X_APPORTIONMENT_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER,
    x_ass_id IN NUMBER,
    x_uai_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_UNITASS_ITEM (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_id IN NUMBER,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_UNTAS_PATTERN (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER
    );

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_id IN NUMBER DEFAULT NULL,
    x_uai_sequence_number IN NUMBER DEFAULT NULL,
    x_apportionment_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_AS_UNT_PATRN_ITM_PKG;

 

/
