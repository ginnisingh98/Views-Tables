--------------------------------------------------------
--  DDL for Package CS_SR_SAVED_SEARCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SAVED_SEARCHES_PKG" AUTHID CURRENT_USER as
/* $Header: csxtssms.pls 120.0 2006/01/10 11:37:05 jngeorge noship $*/

procedure INSERT_ROW (  X_ROWID in out nocopy VARCHAR2,
                                            X_SEARCH_ID in out nocopy NUMBER,
                                            X_OBJECT_VERSION_NUMBER in NUMBER,
                                            X_USER_ID in VARCHAR2,
                                            X_NAME in VARCHAR2,
                                            X_CREATION_DATE in DATE,
                                            X_CREATED_BY in NUMBER,
                                            X_LAST_UPDATE_DATE in DATE,
                                            X_LAST_UPDATED_BY in NUMBER,
                                            X_LAST_UPDATE_LOGIN in NUMBER);

procedure DELETE_ROW (  X_SEARCH_ID in NUMBER);

procedure ADD_LANGUAGE;
end CS_SR_SAVED_SEARCHES_PKG;

 

/
