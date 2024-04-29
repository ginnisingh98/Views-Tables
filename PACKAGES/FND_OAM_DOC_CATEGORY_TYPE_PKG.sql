--------------------------------------------------------
--  DDL for Package FND_OAM_DOC_CATEGORY_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DOC_CATEGORY_TYPE_PKG" AUTHID CURRENT_USER AS
  /* $Header: AFOAMDCTS.pls 120.2 2005/10/19 10:39:31 ilawler noship $ */
  procedure LOAD_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_OWNER               in  VARCHAR2);

  procedure LOAD_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_OWNER               in  VARCHAR2,
    x_custom_mode         in  varchar2,
    x_last_update_date    in  varchar2);

  procedure INSERT_ROW (
    X_ROWID               IN OUT NOCOPY VARCHAR2,
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_CREATED_BY          in  NUMBER,
    X_CREATION_DATE       in  DATE,
    X_LAST_UPDATED_BY     in  NUMBER,
    X_LAST_UPDATE_DATE    in  DATE,
    X_LAST_UPDATE_LOGIN   in  NUMBER);

  procedure UPDATE_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2,
    X_CATEGORY_TYPE_NAME  in  VARCHAR2,
    X_CATALOG_DOC_ID      in  VARCHAR2,
    X_CATALOG_ATTCH_ID    in  VARCHAR2,
    X_LAST_UPDATE_DATE    in  DATE,
    X_LAST_UPDATED_BY     in  NUMBER,
    X_LAST_UPDATE_LOGIN   in  NUMBER);

  procedure DELETE_ROW (
    X_CATEGORY_TYPE       in  VARCHAR2);

END fnd_oam_doc_category_type_pkg;

 

/
