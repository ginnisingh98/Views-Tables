--------------------------------------------------------
--  DDL for Package FND_OAM_DOC_CATEGORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DOC_CATEGORY_PKG" AUTHID CURRENT_USER as
 /* $Header: AFOAMDCS.pls 120.0 2005/08/05 01:05:27 appldev noship $ */
 procedure LOAD_ROW(
    X_CATEGORY_KEY in VARCHAR2,
    X_CATEGORY_TYPE in VARCHAR2,
    X_CATEGORY_NAME in VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER);


 procedure UPDATE_ROW(
    X_CATEGORY_KEY    in   VARCHAR2,
    X_CATEGORY_TYPE     in   VARCHAR2,
    X_CATEGORY_NAME  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER);


 procedure INSERT_ROW(
    X_CATEGORY_KEY    in   VARCHAR2,
    X_CATEGORY_TYPE     in   VARCHAR2,
    X_CATEGORY_NAME  in  VARCHAR2,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER);


end FND_OAM_DOC_CATEGORY_PKG;

 

/
