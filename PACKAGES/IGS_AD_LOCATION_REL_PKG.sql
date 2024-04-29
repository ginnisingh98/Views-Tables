--------------------------------------------------------
--  DDL for Package IGS_AD_LOCATION_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_LOCATION_REL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI44S.pls 115.3 2002/11/28 22:06:08 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID  in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID  in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_SUB_LOCATION_CD in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
   X_ROWID  in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_location_cd IN VARCHAR2,
    x_sub_location_cd IN VARCHAR2
    )
RETURN BOOLEAN ;


PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );

PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_location_cd IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


end IGS_AD_LOCATION_REL_PKG;

 

/
