--------------------------------------------------------
--  DDL for Package IGS_RE_THS_PNL_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_THS_PNL_TYPE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI24S.pls 115.4 2003/02/19 12:28:29 kpadiyar ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_RECOMMENDED_PANEL_SIZE in NUMBER,
  X_TRACKING_TYPE in VARCHAR2,
  X_SELECTION_CRITERIA in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_RECOMMENDED_PANEL_SIZE in NUMBER,
  X_TRACKING_TYPE in VARCHAR2,
  X_SELECTION_CRITERIA in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_RECOMMENDED_PANEL_SIZE in NUMBER,
  X_TRACKING_TYPE in VARCHAR2,
  X_SELECTION_CRITERIA in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_THESIS_PANEL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_RECOMMENDED_PANEL_SIZE in NUMBER,
  X_TRACKING_TYPE in VARCHAR2,
  X_SELECTION_CRITERIA in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_thesis_panel_type IN VARCHAR2
    )RETURN BOOLEAN ;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_thesis_panel_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_recommended_panel_size IN NUMBER DEFAULT NULL,
    x_tracking_type IN VARCHAR2 DEFAULT NULL,
    x_selection_criteria IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_RE_THS_PNL_TYPE_PKG;

 

/
