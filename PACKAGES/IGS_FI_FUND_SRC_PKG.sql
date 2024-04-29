--------------------------------------------------------
--  DDL for Package IGS_FI_FUND_SRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FUND_SRC_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI42S.pls 115.7 2002/11/29 03:47:45 nsidana ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
   X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_funding_source IN VARCHAR2
    )RETURN BOOLEAN;
  PROCEDURE GET_FK_IGS_FI_GOVT_FUND_SRC (
    x_govt_funding_source IN NUMBER
    );
 PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_FI_FUND_SRC_PKG;

 

/
