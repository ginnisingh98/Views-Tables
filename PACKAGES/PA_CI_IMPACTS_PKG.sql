--------------------------------------------------------
--  DDL for Package PA_CI_IMPACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACTS_PKG" AUTHID CURRENT_USER as
/* $Header: PACIIPTS.pls 120.0 2005/06/03 13:41:01 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID out NOCOPY VARCHAR2,
  X_CI_IMPACT_ID out NOCOPY NUMBER,

  x_ci_id IN NUMBER,
  x_impact_type_code IN varchar2,
  x_status_code IN VARCHAR2,
  x_description IN VARCHAR2,
  x_implementation_date IN DATE,
  x_implemented_by IN NUMBER,
  x_implementation_comment IN VARCHAR2,
  x_impacted_task_id IN NUMBER,
  X_CREATION_DATE in DATE default null,
  X_CREATED_BY in NUMBER default null,
  X_LAST_UPDATE_DATE in DATE default null,
  X_LAST_UPDATED_BY in NUMBER default null,
  X_LAST_UPDATE_LOGIN in NUMBER default null
);

procedure UPDATE_ROW (
  X_CI_IMPACT_ID NUMBER,

  x_ci_id IN NUMBER,
  x_impact_type_code IN varchar2,
  x_status_code IN VARCHAR2,
  x_description IN VARCHAR2,
  x_implementation_date IN DATE,
  x_implemented_by IN NUMBER,
  x_implementation_comment IN VARCHAR2,
  x_impacted_task_id IN NUMBER,

  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_record_version_number IN number
		      );
/*
procedure LOCK_ROW (
  X_CI_IMPACT_ID in NUMBER,
  x_impact_type_code IN varchar2,
  X_CI_ID in NUMBER
);*/

procedure DELETE_ROW (
		      X_CI_IMPACT_ID in NUMBER,
		      X_record_version_number in NUMBER
);

end PA_CI_IMPACTS_PKG;

 

/
