--------------------------------------------------------
--  DDL for Package JTF_UM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_TEMPLATES_PKG" AUTHID CURRENT_USER as
/* $Header: JTFUMTLS.pls 120.3 2005/11/28 08:54:14 vimohan ship $ */
procedure INSERT_ROW (
  X_TEMPLATE_ID out NOCOPY NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_EFFECTIVE_START_DATE in DATE,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_TEMPLATE_ID in NUMBER,
  X_TEMPLATE_KEY in VARCHAR2,
  X_TEMPLATE_TYPE_CODE in VARCHAR2,
  X_PAGE_NAME in VARCHAR2,
  X_TEMPLATE_HANDLER in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_EFFECTIVE_END_DATE in DATE,
  X_TEMPLATE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_TEMPLATE_ID in NUMBER
);
procedure ADD_LANGUAGE;


procedure LOAD_ROW (
    X_TEMPLATE_ID            IN NUMBER,
    X_EFFECTIVE_START_DATE   IN DATE,
    X_EFFECTIVE_END_DATE     IN DATE,
    X_OWNER                  IN VARCHAR2,
    X_APPLICATION_ID         IN NUMBER,
    X_ENABLED_FLAG           IN VARCHAR2,
    X_TEMPLATE_TYPE_CODE     IN VARCHAR2,
    X_PAGE_NAME              IN VARCHAR2,
    X_TEMPLATE_HANDLER       IN VARCHAR2,
    X_TEMPLATE_KEY           IN VARCHAR2,
    X_TEMPLATE_NAME          IN VARCHAR2,
    X_DESCRIPTION            IN VARCHAR2,
    x_last_update_date       in varchar2 default NULL,
    X_CUSTOM_MODE            in varchar2 default NULL
);

procedure TRANSLATE_ROW (
  X_TEMPLATE_ID in NUMBER, -- key field
  X_TEMPLATE_NAME in VARCHAR2, -- translated name
  X_DESCRIPTION in VARCHAR2, -- translated description
  X_OWNER in VARCHAR2, -- owner field
  x_last_update_date       in varchar2 default NULL,
  X_CUSTOM_MODE            in varchar2 default NULL
);

end JTF_UM_TEMPLATES_PKG;

 

/
