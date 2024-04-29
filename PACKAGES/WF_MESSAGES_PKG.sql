--------------------------------------------------------
--  DDL for Package WF_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MESSAGES_PKG" AUTHID CURRENT_USER as
/* $Header: wfmsgs.pls 120.2 2005/10/05 00:20:37 anachatt ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
);
procedure LOCK_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
);
procedure UPDATE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2,
  X_PROTECT_LEVEL in NUMBER,
  X_CUSTOM_LEVEL in NUMBER,
  X_DEFAULT_PRIORITY in NUMBER,
  X_READ_ROLE in VARCHAR2,
  X_WRITE_ROLE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBJECT in VARCHAR2,
  X_BODY in VARCHAR2,
  X_HTML_BODY in VARCHAR2
);
procedure DELETE_ROW (
  X_TYPE in VARCHAR2,
  X_NAME in VARCHAR2
);
procedure ADD_LANGUAGE;
end WF_MESSAGES_PKG;

 

/