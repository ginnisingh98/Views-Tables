--------------------------------------------------------
--  DDL for Package FND_OAM_METALINK_DOCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_METALINK_DOCS_PKG" AUTHID CURRENT_USER as
 /* $Header: AFOAMMDS.pls 120.0 2005/08/05 01:05:40 appldev noship $ */
procedure LOAD_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB);

procedure UPDATE_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB);


procedure INSERT_ROW(
    X_DOC_ID    in   VARCHAR2,
    X_TITLE     in   VARCHAR2,
    X_DOC_LAST_UPDATE_DATE  in  DATE,
    X_CREATED_BY    in  NUMBER,
    X_LAST_UPDATED_BY  in  NUMBER,
    X_LAST_UPDATE_LOGIN	in NUMBER,
    X_UPDATE_SUMMARY in CLOB);


end FND_OAM_METALINK_DOCS_PKG;

 

/
