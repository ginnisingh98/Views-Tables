--------------------------------------------------------
--  DDL for Package FND_OAM_METALINK_DOC_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_METALINK_DOC_ASSOC_PKG" AUTHID CURRENT_USER as
 /* $Header: AFOAMMDAS.pls 120.0 2005/08/05 01:05:33 appldev noship $ */
 procedure LOAD_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY in VARCHAR2,
    X_CATEGORY_TYPE in VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2);


 procedure UPDATE_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY     in   VARCHAR2,
    X_CATEGORY_TYPE  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2 );

 procedure INSERT_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_CATEGORY_KEY     in   VARCHAR2,
    X_CATEGORY_TYPE  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_ANCHOR in VARCHAR2 );

end FND_OAM_METALINK_DOC_ASSOC_PKG;

 

/
