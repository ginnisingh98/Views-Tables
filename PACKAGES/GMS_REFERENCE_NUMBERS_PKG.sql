--------------------------------------------------------
--  DDL for Package GMS_REFERENCE_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_REFERENCE_NUMBERS_PKG" AUTHID CURRENT_USER as
-- $Header: gmsawrfs.pls 120.1 2005/07/26 14:20:55 appldev ship $
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_ROWID in VARCHAR2  -- Bug 2652987, Added
);
procedure UPDATE_ROW (
  X_ROW_ID in VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_AWARD_ID in NUMBER,
  X_TYPE in VARCHAR2,
  X_VALUE in VARCHAR2, -- Bug 2652987, Added
  X_ROWID in VARCHAR2 -- Bug 2652987, Added
 );
end GMS_REFERENCE_NUMBERS_PKG;

 

/
