--------------------------------------------------------
--  DDL for Package ICX_CAT_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_ATTRIBUTES_PVT" AUTHID CURRENT_USER AS
    /* $Header: ICXVATRS.pls 120.1 2005/10/22 05:19:12 srmani noship $ */

    PROCEDURE INSERT_ROW(X_ROWID                  IN OUT NOCOPY VARCHAR2,
                         X_ATTRIBUTE_ID           IN NUMBER,
                         X_KEY                    IN VARCHAR2,
                         X_ATTRIBUTE_NAME         IN VARCHAR2,
                         X_DESCRIPTION            IN VARCHAR2,
                         X_RT_CATEGORY_ID         IN NUMBER,
                         X_TYPE                   IN NUMBER,
                         X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                         X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                         X_SEARCHABLE             IN NUMBER,
                         X_SEQUENCE               IN NUMBER,
                         X_CREATED_BY             IN NUMBER,
                         X_CREATION_DATE          IN DATE,
                         X_LAST_UPDATED_BY        IN NUMBER,
                         X_LAST_UPDATE_DATE       IN DATE,
                         X_LAST_UPDATE_LOGIN      IN NUMBER,
                         X_REQUEST_ID             IN NUMBER,
                         X_PROGRAM_APPLICATION_ID IN NUMBER,
                         X_PROGRAM_ID             IN NUMBER,
                         X_STORED_IN_TABLE        IN VARCHAR2,
                         X_STORED_IN_COLUMN       IN VARCHAR2,
                         X_SECTION_TAG            IN NUMBER);

    PROCEDURE LOCK_ROW(X_ATTRIBUTE_ID           IN NUMBER,
                       X_KEY                    IN VARCHAR2,
                       X_ATTRIBUTE_NAME         IN VARCHAR2,
                       X_DESCRIPTION            IN VARCHAR2,
                       X_RT_CATEGORY_ID         IN NUMBER,
                       X_TYPE                   IN NUMBER,
                       X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                       X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                       X_SEARCHABLE             IN NUMBER,
                       X_SEQUENCE               IN NUMBER);

    PROCEDURE UPDATE_ROW(X_ATTRIBUTE_ID           IN NUMBER,
                         X_KEY                    IN VARCHAR2,
                         X_ATTRIBUTE_NAME         IN VARCHAR2,
                         X_DESCRIPTION            IN VARCHAR2,
                         X_RT_CATEGORY_ID         IN NUMBER,
                         X_TYPE                   IN NUMBER,
                         X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                         X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                         X_SEARCHABLE             IN NUMBER,
                         X_SEQUENCE               IN NUMBER,
                         X_LAST_UPDATED_BY        IN NUMBER,
                         X_LAST_UPDATE_DATE       IN DATE,
                         X_LAST_UPDATE_LOGIN      IN NUMBER,
                         X_REQUEST_ID             IN NUMBER,
                         X_PROGRAM_APPLICATION_ID IN NUMBER,
                         X_PROGRAM_ID             IN NUMBER,
                         X_STORED_IN_TABLE        IN VARCHAR2,
                         X_STORED_IN_COLUMN       IN VARCHAR2,
                         X_SECTION_TAG            IN NUMBER);

    PROCEDURE DELETE_ROW(X_ATTRIBUTE_ID IN NUMBER);

    PROCEDURE TRANSLATE_ROW(X_ATTRIBUTE_ID      IN VARCHAR2,
                            X_OWNER             IN VARCHAR2,
                            X_ATTRIBUTE_NAME    IN VARCHAR2,
                            X_DESCRIPTION       IN VARCHAR2,
                            X_CUSTOM_MODE       IN VARCHAR2,
                            X_LAST_UPDATE_DATE  IN VARCHAR2);

    PROCEDURE LOAD_ROW(X_ATTRIBUTE_ID           IN VARCHAR2,
                       X_OWNER                  IN VARCHAR2,
                       X_KEY                    IN VARCHAR2,
                       X_ATTRIBUTE_NAME         IN VARCHAR2,
                       X_DESCRIPTION            IN VARCHAR2,
                       X_CATEGORY_ID            IN VARCHAR2,
                       X_TYPE                   IN VARCHAR2,
                       X_SEARCH_RESULTS_VISIBLE IN VARCHAR2,
                       X_ITEM_DETAIL_VISIBLE    IN VARCHAR2,
                       X_SEARCHABLE             IN VARCHAR2,
                       X_SEQUENCE               IN VARCHAR2,
                       X_STORED_IN_TABLE        IN VARCHAR2,
                       X_STORED_IN_COLUMN       IN VARCHAR2,
                       X_SECTION_TAG            IN NUMBER,
                       X_CUSTOM_MODE            IN VARCHAR2,
                       X_LAST_UPDATE_DATE       IN VARCHAR2);

    PROCEDURE ADD_LANGUAGE;

END ICX_CAT_ATTRIBUTES_PVT;


 

/
