--------------------------------------------------------
--  DDL for Package IGS_OR_UNIT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_UNIT_REL_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSOI14S.pls 115.4 2002/11/29 01:40:46 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in out NOCOPY DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in out NOCOPY DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );


  FUNCTION Get_PK_For_Validation (
    x_parent_org_unit_cd IN VARCHAR2,
    x_parent_start_dt IN DATE,
    x_child_org_unit_cd IN VARCHAR2,
    x_child_start_dt IN DATE,
    x_create_dt IN DATE
    ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    );

procedure Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) ;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_parent_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_parent_start_dt IN DATE DEFAULT NULL,
    x_child_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_child_start_dt IN DATE DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_OR_UNIT_REL_PKG;

 

/
