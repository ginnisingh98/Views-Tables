--------------------------------------------------------
--  DDL for Package IGS_AD_CONV_GS_VALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_CONV_GS_VALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIB0S.pls 115.8 2002/11/28 22:24:21 nsidana ship $ */

  procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_VALUES_ID IN OUT NOCOPY NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure LOCK_ROW (
    X_ROWID in  VARCHAR2,
    x_CONV_GS_VALUES_ID IN NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2
  );

  procedure UPDATE_ROW (
    X_ROWID in  VARCHAR2,
    x_CONV_GS_VALUES_ID IN NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure ADD_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    x_CONV_GS_VALUES_ID IN  OUT NOCOPY NUMBER,
    x_CONV_GS_TYPES_ID IN NUMBER,
    x_FROM_GPA IN VARCHAR2,
    x_TO_GPA IN VARCHAR2,
    X_MODE in VARCHAR2 default 'R'
  );

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  );

  FUNCTION Get_PK_For_Validation (
    x_conv_gs_values_id IN NUMBER
  ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_conv_gs_types_id IN NUMBER,
    x_from_gpa IN VARCHAR2,
    x_to_gpa IN VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Conv_Gs_Types (
    x_conv_gs_types_id IN NUMBER
  );

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_conv_gs_values_id IN NUMBER DEFAULT NULL,
    x_conv_gs_types_id IN NUMBER DEFAULT NULL,
    x_from_gpa IN VARCHAR2,
    x_to_gpa IN VARCHAR2,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

END igs_ad_conv_gs_vals_pkg;

 

/
