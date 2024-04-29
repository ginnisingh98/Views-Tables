--------------------------------------------------------
--  DDL for Package IGS_AV_STND_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_STND_CONF_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSBI03S.pls 115.8 2003/01/07 07:21:08 nalkumar ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
    ) RETURN BOOLEAN ;

PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );



PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_expiry_dt_increment IN NUMBER DEFAULT NULL,
    x_adv_stnd_expiry_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adv_stnd_basis_inst IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
);

---
END igs_av_stnd_conf_pkg;

 

/
