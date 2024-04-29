--------------------------------------------------------
--  DDL for Package CZ_LOCALIZED_TEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_LOCALIZED_TEXTS_PKG" AUTHID CURRENT_USER as
/* $Header: czilocts.pls 120.1 2005/12/02 03:59:41 amdixit ship $ */
procedure INSERT_ROW
(X_ROWID             in OUT NOCOPY VARCHAR2,
 X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_CREATED_BY        in NUMBER,
 X_LAST_UPDATED_BY   in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_SEEDED_FLAG	   IN VARCHAR2,
 X_PERSISTENT_INTL_TEXT_ID IN NUMBER,
 X_UI_PAGE_ID	   IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2);

procedure UPDATE_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_CREATED_BY        in NUMBER,
 X_LAST_UPDATED_BY   in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_PERSISTENT_INTL_TEXT_ID IN NUMBER,
 X_SEEDED_FLAG 	     IN VARCHAR2,
 X_UI_PAGE_ID	   IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2);

procedure DELETE_ROW (X_INTL_TEXT_ID in NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Translate_Row
(X_INTL_TEXT_ID    IN  NUMBER,
 X_LOCALIZED_STR   IN  VARCHAR2,
 X_OWNER           IN  VARCHAR2);

procedure LOAD_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_OWNER		   IN VARCHAR2,
 X_PERSISTENT_INTL_TEXT_ID IN NUMBER,
 X_SEEDED_FLAG	     IN VARCHAR2,
 X_UI_PAGE_ID	   IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2);

procedure LOAD_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_DELETED_FLAG      in VARCHAR2);

procedure UPDATE_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_DELETED_FLAG      in VARCHAR2);

end CZ_LOCALIZED_TEXTS_PKG;

 

/
