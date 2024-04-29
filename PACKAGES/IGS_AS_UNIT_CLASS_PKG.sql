--------------------------------------------------------
--  DDL for Package IGS_AS_UNIT_CLASS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_UNIT_CLASS_PKG" AUTHID CURRENT_USER as
/* $Header: IGSDI34S.pls 120.0 2005/07/05 12:49:42 appldev noship $ */


--
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DAY_OF_WEEK in VARCHAR2,
  X_START_TIME in DATE,
  X_END_TIME in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
FUNCTION Get_PK_For_Validation (
    x_unit_class IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    );
 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_day_of_week IN VARCHAR2 DEFAULT NULL,
    x_start_time IN DATE DEFAULT NULL,
    x_end_time IN DATE DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER  DEFAULT NULL,
    x_last_update_date IN DATE  DEFAULT NULL,
    x_last_updated_by IN NUMBER  DEFAULT NULL,
    x_last_update_login IN NUMBER  DEFAULT NULL
  );

end IGS_AS_UNIT_CLASS_PKG;

 

/
