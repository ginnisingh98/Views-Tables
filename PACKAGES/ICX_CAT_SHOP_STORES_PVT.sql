--------------------------------------------------------
--  DDL for Package ICX_CAT_SHOP_STORES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_SHOP_STORES_PVT" AUTHID CURRENT_USER AS
    /* $Header: ICXVSTRS.pls 120.1 2005/10/21 14:21:08 srmani noship $ */

    PROCEDURE INSERT_ROW(X_ROWID                    IN OUT NOCOPY VARCHAR2,
                         X_STORE_ID          IN NUMBER,
                         X_SEQUENCE          IN NUMBER,
                         X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                         X_NAME              IN VARCHAR2,
                         X_DESCRIPTION       IN VARCHAR2,
                         X_LONG_DESCRIPTION  IN VARCHAR2,
                         X_IMAGE             IN VARCHAR2,
                         X_CREATION_DATE     IN DATE,
                         X_CREATED_BY        IN NUMBER,
                         X_LAST_UPDATE_DATE  IN DATE,
                         X_LAST_UPDATED_BY   IN NUMBER,
                         X_LAST_UPDATE_LOGIN IN NUMBER);

    PROCEDURE UPDATE_ROW(X_STORE_ID          IN NUMBER,
                         X_SEQUENCE          IN NUMBER,
                         X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                         X_NAME              IN VARCHAR2,
                         X_DESCRIPTION       IN VARCHAR2,
                         X_LONG_DESCRIPTION  IN VARCHAR2,
                         X_IMAGE             IN VARCHAR2,
                         X_LAST_UPDATE_DATE  IN DATE,
                         X_LAST_UPDATED_BY   IN NUMBER,
                         X_LAST_UPDATE_LOGIN IN NUMBER);

    PROCEDURE TRANSLATE_ROW(X_STORE_ID         IN VARCHAR2,
                            X_OWNER            IN VARCHAR2,
                            X_NAME             IN VARCHAR2,
                            X_DESCRIPTION      IN VARCHAR2,
                            X_LONG_DESCRIPTION IN VARCHAR2,
                            X_IMAGE            IN VARCHAR2,
                            X_CUSTOM_MODE      IN VARCHAR2,
                            X_LAST_UPDATE_DATE IN VARCHAR2);

    PROCEDURE LOAD_ROW(X_STORE_ID         IN VARCHAR2,
                       X_OWNER            IN VARCHAR2,
                       X_SEQUENCE         IN VARCHAR2,
                       X_LOCAL_CONTENT_FIRST_FLAG IN VARCHAR2,
                       X_NAME             IN VARCHAR2,
                       X_DESCRIPTION      IN VARCHAR2,
                       X_LONG_DESCRIPTION IN VARCHAR2,
                       X_IMAGE            IN VARCHAR2,
                       X_CUSTOM_MODE      IN VARCHAR2,
                       X_LAST_UPDATE_DATE IN VARCHAR2);

    PROCEDURE ADD_LANGUAGE;

END ICX_CAT_SHOP_STORES_PVT;

 

/
