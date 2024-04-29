--------------------------------------------------------
--  DDL for Package DOM_DOCUMENT_REVISIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_DOCUMENT_REVISIONS_PKG" AUTHID CURRENT_USER as
/* $Header: DOMREVS.pls 120.1 2006/03/24 17:31:28 dedatta noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2
);

procedure UPDATE_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER,
  X_CATEGORY_ID in NUMBER,
  X_REVISION in VARCHAR2,
  X_CHECKOUT_STATUS in VARCHAR2,
  X_CHECKED_OUT_BY in NUMBER,
  X_CREATION_REASON in VARCHAR2,
  X_LIFECYCLE_PHASE_ID in NUMBER,
  X_LIFECYCLE_TRACKING_ID in NUMBER,
  X_COMMENTS in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_DOCUMENT_ID in NUMBER,
  X_REVISION_ID in NUMBER
);

procedure ADD_LANGUAGE;
end DOM_DOCUMENT_REVISIONS_PKG;

 

/