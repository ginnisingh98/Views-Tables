--------------------------------------------------------
--  DDL for Package IGS_RE_SCHL_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_SCHL_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI10S.pls 115.4 2002/11/29 03:33:53 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCHOLARSHIP_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_UNIT_CD_FROM in VARCHAR2,
  X_OU_START_DT_FROM in DATE,
  X_PERSON_ID_FROM in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_scholarship_type IN VARCHAR2
    )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    );

PROCEDURE Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scholarship_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd_from IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt_from IN DATE DEFAULT NULL,
    x_person_id_from IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
  ) ;

end IGS_RE_SCHL_TYPE_PKG;

 

/
