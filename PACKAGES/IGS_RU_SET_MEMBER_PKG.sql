--------------------------------------------------------
--  DDL for Package IGS_RU_SET_MEMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_SET_MEMBER_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI13S.pls 115.4 2002/11/29 04:28:29 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSIONS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_RS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSIONS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_rs_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2
)return BOOLEAN;

PROCEDURE Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE GET_FK_IGS_RU_SET (
    x_sequence_number IN NUMBER
    );

  PROCEDURE Before_DML (

	p_action IN VARCHAR2,
	x_rowid IN VARCHAR2 DEFAULT NULL,
	x_rs_sequence_number IN NUMBER DEFAULT NULL,
	x_unit_cd IN VARCHAR2 DEFAULT NULL,
	x_versions IN VARCHAR2 DEFAULT NULL,
	x_creation_date IN DATE DEFAULT NULL,
	x_created_by IN NUMBER DEFAULT NULL,
	x_last_update_date IN DATE DEFAULT NULL,
	x_last_updated_by IN NUMBER DEFAULT NULL,
	x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_RU_SET_MEMBER_PKG;

 

/
