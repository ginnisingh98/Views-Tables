--------------------------------------------------------
--  DDL for Package IGS_EN_CAT_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_CAT_MAPPING_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI23S.pls 115.4 2002/11/28 23:37:14 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_DFLT_CAT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
  x_enrolment_cat IN VARCHAR2,
  x_admission_cat IN VARCHAR2
  )
RETURN BOOLEAN;
PROCEDURE GET_FK_IGS_AD_CAT (
  x_admission_cat IN VARCHAR2
  );
PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
  x_enrolment_cat IN VARCHAR2
  );
procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_dflt_cat_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_EN_CAT_MAPPING_PKG;

 

/
