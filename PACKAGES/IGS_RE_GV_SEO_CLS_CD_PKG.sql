--------------------------------------------------------
--  DDL for Package IGS_RE_GV_SEO_CLS_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_GV_SEO_CLS_CD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI08S.pls 115.3 2002/11/29 03:33:22 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_SEO_CLASS_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_SEO_CLASS_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_SEO_CLASS_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_SEO_CLASS_CD in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_RES_FCD_CLASS_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_govt_seo_class_cd IN NUMBER
    )
   RETURN BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_govt_seo_class_cd IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_res_fcd_class_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_RE_GV_SEO_CLS_CD_PKG;

 

/
