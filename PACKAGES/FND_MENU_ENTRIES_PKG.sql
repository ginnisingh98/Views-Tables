--------------------------------------------------------
--  DDL for Package FND_MENU_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_MENU_ENTRIES_PKG" AUTHID CURRENT_USER as
/* $Header: AFMNENTS.pls 120.3.12010000.2 2009/05/13 15:04:25 jvalenti ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
);
procedure UPDATE_ROW (
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
/* Overloaded version below */
procedure LOAD_ROW (
  X_MODE in VARCHAR2,
  X_ENT_SEQUENCE VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_SUB_MENU_NAME in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
);
procedure DELETE_ROW (
  X_MENU_ID in NUMBER,
  X_ENTRY_SEQUENCE in NUMBER
);
procedure ADD_LANGUAGE;

/* Overloaded version below */
procedure TRANSLATE_ROW (
  X_MENU_ID     in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2
);
/* Overloaded version above */
procedure LOAD_ROW (
  X_MODE in VARCHAR2,
  X_ENT_SEQUENCE VARCHAR2,
  X_MENU_NAME in VARCHAR2,
  X_SUB_MENU_NAME in VARCHAR2,
  X_FUNCTION_NAME in VARCHAR2,
  X_GRANT_FLAG in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);
/* Overloaded version above */
procedure TRANSLATE_ROW (
  X_MENU_ID     in NUMBER,
  X_SUB_MENU_ID in NUMBER,
  X_FUNCTION_ID in NUMBER,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_CUSTOM_MODE in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2
);

/* SUBMIT_COMPILE- Submit a concurrent request to compile the menu/entries*/
/* This routine must be called after loading, inserting, updating, or */
/* deleting data in the menu entries table.  It will submit a concurrent */
/* request which will compile that data into the */
/* FND_COMPILED_MENU_FUNCTIONS table.  This can be called just once at */
/* the end of loading a number or menu entries.  */
/* This routine will check to see if a request has been submitted and */
/* is pending, and will submit one if there is not one pending. */
/* RETURNs:  status- 'P' if the request is already pending */
/*                   'S' if the request was submitted */
/*                   'E' if an error prevented request from being submitted*/
function SUBMIT_COMPILE return varchar2;

end FND_MENU_ENTRIES_PKG;

/
