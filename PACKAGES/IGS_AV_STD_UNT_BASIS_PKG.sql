--------------------------------------------------------
--  DDL for Package IGS_AV_STD_UNT_BASIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_STD_UNT_BASIS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSBI05S.pls 120.0 2005/07/05 12:46:52 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_BASIS_COURSE_TYPE in VARCHAR2,
  X_BASIS_YEAR in NUMBER,
  X_BASIS_COMPLETION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_BASIS_COURSE_TYPE in VARCHAR2,
  X_BASIS_YEAR in NUMBER,
  X_BASIS_COMPLETION_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_BASIS_COURSE_TYPE in VARCHAR2,
  X_BASIS_YEAR in NUMBER,
  X_BASIS_COMPLETION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AV_STND_UNIT_ID IN NUMBER,
  X_BASIS_COURSE_TYPE in VARCHAR2,
  X_BASIS_YEAR in NUMBER,
  X_BASIS_COMPLETION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);
FUNCTION Get_PK_For_Validation (
  x_av_stnd_unit_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_AV_STND_UNIT (
    x_av_stnd_unit_id IN NUMBER
    );

---
  PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
    );

 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_av_stnd_unit_id IN NUMBER DEFAULT NULL,
    x_basis_course_type IN VARCHAR2 DEFAULT NULL,
    x_basis_year IN NUMBER DEFAULT NULL,
    x_basis_completion_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) ;
---
end IGS_AV_STD_UNT_BASIS_PKG;

 

/
