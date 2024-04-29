--------------------------------------------------------
--  DDL for Package GMS_AWARDS_TC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARDS_TC_PKG" AUTHID CURRENT_USER as
-- $Header: gmsawtcs.pls 120.1 2005/07/26 14:21:05 appldev ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER
);
procedure UPDATE_ROW (
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER,
  X_OPERAND in VARCHAR2,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_AWARD_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_TERM_ID in NUMBER
);
end GMS_AWARDS_TC_PKG;

 

/
