--------------------------------------------------------
--  DDL for Package FND_SVC_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SVC_COMPONENTS_PKG" authid current_user as
/* $Header: AFSVCMTS.pls 115.2 2002/12/10 21:10:24 ankung noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER default 1,
  X_CREATION_DATE in DATE default sysdate,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE default sysdate,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER);

procedure LOCK_ROW (
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  X_COMPONENT_ID in NUMBER,
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CONCURRENT_QUEUE_ID in NUMBER,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAST_UPDATE_DATE in DATE default sysdate,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
);

procedure DELETE_ROW (
  X_COMPONENT_ID in NUMBER
);

procedure LOAD_ROW (
  X_COMPONENT_NAME in VARCHAR2,
  X_COMPONENT_STATUS in VARCHAR2,
  X_COMPONENT_TYPE in VARCHAR2,
  X_STARTUP_MODE in VARCHAR2,
  X_CONTAINER_TYPE in VARCHAR2,
  X_CUSTOMIZATION_LEVEL in VARCHAR2,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_CONCURRENT_QUEUE_NAME in VARCHAR2,
  X_STANDALONE_CONTAINER_NAME in VARCHAR2,
  X_INBOUND_AGENT_NAME in VARCHAR2,
  X_OUTBOUND_AGENT_NAME in VARCHAR2,
  X_CORRELATION_ID in VARCHAR2,
  X_MAX_IDLE_TIME in NUMBER,
  X_COMPONENT_STATUS_INFO in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
);


end FND_SVC_COMPONENTS_PKG;

 

/