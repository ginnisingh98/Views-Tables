--------------------------------------------------------
--  DDL for Package ICX_CAT_CONTENT_ZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_CONTENT_ZONES_PVT" AUTHID CURRENT_USER AS
    /* $Header: ICXVZNES.pls 120.6 2006/05/17 20:04:41 rwidjaja noship $ */

    PROCEDURE INSERT_ROW(X_ROWID                  IN OUT NOCOPY VARCHAR2,
                         X_ZONE_ID                    IN NUMBER,
                         X_TYPE                       IN VARCHAR2,
                         X_URL                        IN VARCHAR2,
                         X_IMAGE                      IN VARCHAR2,
                         X_NAME                       IN VARCHAR2,
                         X_DESCRIPTION                IN VARCHAR2,
                         X_SUPPLIER_ATTRIBUTE_ACTION  IN VARCHAR2,
                         X_CATEGORY_ATTRIBUTE_ACTION  IN VARCHAR2,
                         X_ITEMS_WITHOUT_SUPPLIER     IN VARCHAR2,
                         X_ITEMS_WITHOUT_SHOP_CATG    IN VARCHAR2,
                         X_SECURITY_ASSIGNMENT_FLAG IN VARCHAR2,
                         X_CREATION_DATE              IN DATE,
                         X_CREATED_BY                 IN NUMBER,
                         X_LAST_UPDATE_DATE           IN DATE,
                         X_LAST_UPDATED_BY            IN NUMBER,
                         X_LAST_UPDATE_LOGIN          IN NUMBER);

    PROCEDURE UPDATE_ROW(X_ZONE_ID                        IN NUMBER,
                         X_TYPE                           IN VARCHAR2,
                         X_URL                            IN VARCHAR2,
                         X_IMAGE                          IN VARCHAR2,
                         X_NAME                           IN VARCHAR2,
                         X_DESCRIPTION                    IN VARCHAR2,
                         X_SUPPLIER_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_CATEGORY_ATTRIBUTE_ACTION IN VARCHAR2,
                         X_ITEMS_WITHOUT_SUPPLIER    IN VARCHAR2,
                         X_ITEMS_WITHOUT_SHOP_CATG   IN VARCHAR2,
                         X_SECURITY_ASSIGNMENT_FLAG     IN VARCHAR2,
                         X_LAST_UPDATE_DATE               IN DATE,
                         X_LAST_UPDATED_BY                IN NUMBER,
                         X_LAST_UPDATE_LOGIN              IN NUMBER);

    PROCEDURE TRANSLATE_ROW(X_ZONE_ID          IN VARCHAR2,
                            X_OWNER            IN VARCHAR2,
                            X_NAME             IN VARCHAR2,
                            X_DESCRIPTION      IN VARCHAR2,
			    X_IMAGE            IN VARCHAR2,
                            X_CUSTOM_MODE      IN VARCHAR2,
                            X_LAST_UPDATE_DATE IN VARCHAR2);

    PROCEDURE LOAD_ROW(X_ZONE_ID                        IN VARCHAR2,
                       X_OWNER                          IN VARCHAR2,
                       X_NAME                           IN VARCHAR2,
                       X_DESCRIPTION                    IN VARCHAR2,
                       X_TYPE                           IN VARCHAR2,
                       X_URL                            IN VARCHAR2,
                       X_IMAGE                          IN VARCHAR2,
                       X_SUPPLIER_ATTRIBUTE_ACTION IN VARCHAR2,
                       X_CATEGORY_ATTRIBUTE_ACTION IN VARCHAR2,
                       X_ITEMS_WITHOUT_SUPPLIER    IN VARCHAR2,
                       X_ITEMS_WITHOUT_SHOP_CATG   IN VARCHAR2,
                       X_SECURITY_ASSIGNMENT_FLAG     IN VARCHAR2,
                       X_CUSTOM_MODE                    IN VARCHAR2,
                       X_LAST_UPDATE_DATE               IN VARCHAR2);

    PROCEDURE ADD_LANGUAGE;

END ICX_CAT_CONTENT_ZONES_PVT;

 

/
