--------------------------------------------------------
--  DDL for Package IGS_CA_DA_OFST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DA_OFST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI09S.pls 115.3 2002/11/28 23:01:48 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_DAY_OFFSET in NUMBER,
  X_WEEK_OFFSET in NUMBER,
  X_MONTH_OFFSET in NUMBER,
  X_YEAR_OFFSET in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
    FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_offset_dt_alias IN VARCHAR2
    )RETURN BOOLEAN;

    PROCEDURE Check_Constraints (
    column_name  IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL);

	PROCEDURE Before_DML (
	    p_action IN VARCHAR2,
	    x_rowid IN VARCHAR2 DEFAULT NULL,
	    x_dt_alias IN VARCHAR2 DEFAULT NULL,
	    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
	    x_day_offset IN NUMBER DEFAULT NULL,
	    x_week_offset IN NUMBER DEFAULT NULL,
	    x_month_offset IN NUMBER DEFAULT NULL,
	    x_year_offset IN NUMBER DEFAULT NULL,
	    x_creation_date IN DATE DEFAULT NULL,
	    x_created_by IN NUMBER DEFAULT NULL,
	    x_last_update_date IN DATE DEFAULT NULL,
	    x_last_updated_by IN NUMBER DEFAULT NULL,
	    x_last_update_login IN NUMBER DEFAULT NULL
    );

    PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    );
end IGS_CA_DA_OFST_PKG;

 

/
