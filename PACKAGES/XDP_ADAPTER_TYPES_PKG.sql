--------------------------------------------------------
--  DDL for Package XDP_ADAPTER_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_ADAPTER_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: XDPATYPS.pls 120.1 2005/06/15 21:55:16 appldev  $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);
procedure LOCK_ROW (
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
);
procedure UPDATE_ROW (
  X_ADAPTER_TYPE in VARCHAR2,
  X_ADAPTER_CLASS in VARCHAR2,
  X_BASE_ADAPTER_TYPE in VARCHAR2,
  X_APPLICATION_MODE in VARCHAR2,
  X_INBOUND_REQUIRED_FLAG in VARCHAR2,
  X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
  X_MAX_BUFFER_SIZE in NUMBER,
  X_CMD_LINE_OPTIONS in VARCHAR2,
  X_CMD_LINE_ARGS in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);
procedure DELETE_ROW (
  X_ADAPTER_TYPE in VARCHAR2
);
procedure ADD_LANGUAGE;

PROCEDURE LOAD_ROW (
	X_ADAPTER_TYPE in VARCHAR2,
	X_ADAPTER_CLASS in VARCHAR2,
	X_BASE_ADAPTER_TYPE in VARCHAR2,
	X_APPLICATION_MODE in VARCHAR2,
	X_INBOUND_REQUIRED_FLAG in VARCHAR2,
	X_CONNECTION_REQUIRED_FLAG in VARCHAR2,
	X_CMD_LINE_OPTIONS in VARCHAR2,
	X_CMD_LINE_ARGS in VARCHAR2,
	X_MAX_BUFFER_SIZE in NUMBER,
	X_DISPLAY_NAME in VARCHAR2,
	X_OWNER in VARCHAR2);

PROCEDURE TRANSLATE_ROW (
   X_ADAPTER_TYPE in VARCHAR2,
   X_DISPLAY_NAME in VARCHAR2,
   X_OWNER in VARCHAR2);

end XDP_ADAPTER_TYPES_PKG;

 

/