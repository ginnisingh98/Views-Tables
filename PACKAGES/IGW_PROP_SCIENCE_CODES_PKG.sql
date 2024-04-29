--------------------------------------------------------
--  DDL for Package IGW_PROP_SCIENCE_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_SCIENCE_CODES_PKG" AUTHID CURRENT_USER as
 /* $Header: igwpr70s.pls 115.6 2002/03/28 19:13:34 pkm ship      $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_SCIENCE_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_SCIENCE_CODE in VARCHAR2
  );
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_SCIENCE_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_SCIENCE_CODE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

end IGW_PROP_SCIENCE_CODES_PKG;

 

/
