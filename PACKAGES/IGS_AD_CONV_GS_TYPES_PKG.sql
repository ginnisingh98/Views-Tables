--------------------------------------------------------
--  DDL for Package IGS_AD_CONV_GS_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CONV_GS_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI77S.pls 115.5 2002/11/28 22:16:00 nsidana ship $ */

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_TYPES_ID IN OUT NOCOPY NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER
  );

  procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_TYPES_ID IN OUT NOCOPY  NUMBER,
    x_FROM_CODE_ID IN NUMBER,
    x_TO_CODE_ID IN NUMBER,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  );

  FUNCTION Get_PK_For_Validation (
    x_conv_gs_types_id IN NUMBER
  ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_from_code_id IN NUMBER,
    x_to_code_id IN NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_code_id IN NUMBER DEFAULT NULL,
    x_to_code_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

END igs_ad_conv_gs_types_pkg;

 

/
