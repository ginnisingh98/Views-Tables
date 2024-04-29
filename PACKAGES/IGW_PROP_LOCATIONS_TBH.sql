--------------------------------------------------------
--  DDL for Package IGW_PROP_LOCATIONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_LOCATIONS_TBH" AUTHID CURRENT_USER as
--$Header: igwtplcs.pls 115.4 2002/11/15 00:38:00 ashkumar ship $
procedure INSERT_ROW (
  X_ROWID                      out NOCOPY ROWID,
  X_PROPOSAL_ID                in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_PARTY_ID                   in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS              out NOCOPY VARCHAR2
  );

procedure UPDATE_ROW (
  X_ROWID IN ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_PERFORMING_ORGANIZATION_ID in NUMBER,
  X_PARTY_ID                   in NUMBER,
  X_RECORD_VERSION_NUMBER   IN NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  );

procedure DELETE_ROW (
  X_ROWID                         IN ROWID
  ,X_PROPOSAL_ID                  IN NUMBER
  ,X_PERFORMING_ORGANIZATION_ID   IN NUMBER
  ,X_PARTY_ID                     IN NUMBER
  ,X_RECORD_VERSION_NUMBER        IN NUMBER
  ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
);

end IGW_PROP_LOCATIONS_TBH;

 

/
