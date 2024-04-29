--------------------------------------------------------
--  DDL for Package IGW_PROP_PROGRAM_ADDRESSES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PROGRAM_ADDRESSES_TBH" AUTHID CURRENT_USER as
--$Header: igwtpads.pls 115.3 2002/11/15 00:43:54 ashkumar ship $
procedure INSERT_ROW (
  X_ROWID out NOCOPY ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_NUMBER_OF_COPIES in NUMBER,
  X_MAIL_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS   out NOCOPY VARCHAR2
  );

procedure UPDATE_ROW (
  X_ROWID in ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_NUMBER_OF_COPIES in NUMBER,
  X_MAIL_DESCRIPTION in VARCHAR2,
  X_RECORD_VERSION_NUMBER   IN NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS   out NOCOPY VARCHAR2
  );

procedure DELETE_ROW (
  X_ROWID in ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_RECORD_VERSION_NUMBER   IN NUMBER,
  X_RETURN_STATUS   out NOCOPY VARCHAR2
);
end IGW_PROP_PROGRAM_ADDRESSES_TBH;

 

/