--------------------------------------------------------
--  DDL for Package IGW_PROP_LOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_LOCATIONS_PKG" AUTHID CURRENT_USER as
 /* $Header: igwpr30s.pls 115.5 2002/03/28 19:13:28 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
end IGW_PROP_LOCATIONS_PKG;

 

/
