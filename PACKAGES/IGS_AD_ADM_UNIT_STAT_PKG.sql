--------------------------------------------------------
--  DDL for Package IGS_AD_ADM_UNIT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ADM_UNIT_STAT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI01S.pls 115.7 2003/10/30 13:10:08 akadam ship $ */

PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE LOCK_ROW (
  X_ROWID   in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHOW_ON_OFFIC_NTFCTN_IND in VARCHAR2,
  X_EFFECTIVE_PROGRESSION_IND in VARCHAR2,
  X_EFFECTIVE_TIME_ELAPSED_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

 FUNCTION Get_PK_For_Validation(
    x_administrative_unit_status IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    ) RETURN BOOLEAN;

 PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_unit_attempt_status IN VARCHAR2
    );
 PROCEDURE Check_Constraints (
			Column_Name IN VARCHAR2 DEFAULT NULL,
			Column_Value IN VARCHAR2 DEFAULT NULL
			);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_show_on_offic_ntfctn_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_progression_ind IN VARCHAR2 DEFAULT NULL,
    x_effective_time_elapsed_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

END IGS_AD_ADM_UNIT_STAT_PKG;

 

/
