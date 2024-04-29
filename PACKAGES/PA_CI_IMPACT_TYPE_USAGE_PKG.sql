--------------------------------------------------------
--  DDL for Package PA_CI_IMPACT_TYPE_USAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_IMPACT_TYPE_USAGE_PKG" AUTHID CURRENT_USER as
/* $Header: PACIIMTS.pls 120.0.12010000.2 2009/06/08 18:52:23 cklee ship $ */
procedure INSERT_ROW (
  X_ROWID out NOCOPY VARCHAR2,
  X_CI_IMPACT_TYPE_USAGE_ID out NOCOPY NUMBER,

  x_impact_type_code IN varchar2,
  x_ci_type_class_code IN VARCHAR2,
  X_CI_TYPE_ID in NUMBER,
  X_CREATION_DATE in DATE default null,
  X_CREATED_BY in NUMBER default null,
  X_LAST_UPDATE_DATE in DATE  default null,
  X_LAST_UPDATED_BY in NUMBER default null,
  X_LAST_UPDATE_LOGIN in NUMBER default null,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
);

procedure LOCK_ROW (
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER,
  x_impact_type_code IN varchar2,
  x_ci_type_class_code IN VARCHAR2,
  X_CI_TYPE_ID in NUMBER,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
);

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
procedure UPDATE_ROW (
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER,
--  x_impact_type_code IN varchar2,
--  x_ci_type_class_code IN VARCHAR2,
--  X_CI_TYPE_ID in NUMBER,
  X_IMPACT_TYPE_CODE_ORDER IN NUMBER
);
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

procedure DELETE_ROW (
  X_CI_IMPACT_TYPE_USAGE_ID in NUMBER
);

end PA_CI_IMPACT_TYPE_USAGE_PKG;

/
