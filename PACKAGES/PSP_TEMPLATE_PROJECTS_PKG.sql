--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_PROJECTS_PKG" AUTHID CURRENT_USER as
 /* $Header: PSPERPRS.pls 115.5 2002/11/18 12:41:03 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2
);
procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_PROJECT_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
);
end PSP_TEMPLATE_PROJECTS_PKG;

 

/
