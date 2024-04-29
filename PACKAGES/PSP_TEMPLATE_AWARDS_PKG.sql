--------------------------------------------------------
--  DDL for Package PSP_TEMPLATE_AWARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_TEMPLATE_AWARDS_PKG" AUTHID CURRENT_USER as
 /* $Header: PSPERAWS.pls 115.5 2002/11/18 12:26:50 lveerubh ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2
);
procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_AWARD_ID in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
);
end PSP_TEMPLATE_AWARDS_PKG;

 

/
