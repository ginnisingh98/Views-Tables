--------------------------------------------------------
--  DDL for Package PO_DOC_STYLE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOC_STYLE_LINES_PKG" AUTHID CURRENT_USER AS
  /* $Header: PO_DOC_STYLE_LINES_PKG.pls 120.2 2005/12/05 05:04:51 scolvenk noship $ */


PROCEDURE TRANSLATE_ROW(
               X_STYLE_ID IN NUMBER,
	       X_DOCUMENT_SUBTYPE in VARCHAR2,
	       X_DISPLAY_NAME in VARCHAR2,
	       X_OWNER     in VARCHAR2,
	       X_LAST_UPDATE_DATE in VARCHAR2,
	       X_CUSTOM_MODE in VARCHAR2);

PROCEDURE LOAD_ROW(
                      X_STYLE_ID         in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_OWNER            in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_CUSTOM_MODE      in VARCHAR2);

procedure UPDATE_ROW(
                      X_STYLE_ID       in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY  in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER);


procedure INSERT_ROW(
                      X_STYLE_ID       in NUMBER,
	              X_DOCUMENT_SUBTYPE in VARCHAR2,
                      X_ENABLED_FLAG     in VARCHAR2,
		      X_DISPLAY_NAME     in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER);

 PROCEDURE ADD_LANGUAGE;

END PO_DOC_STYLE_LINES_PKG;


 

/
