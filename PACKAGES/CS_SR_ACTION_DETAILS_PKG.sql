--------------------------------------------------------
--  DDL for Package CS_SR_ACTION_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_ACTION_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: csxtnads.pls 120.0 2005/08/12 15:28:34 aneemuch noship $ */

procedure INSERT_ROW (
  PX_EVENT_ACTION_DETAIL_ID   in out NOCOPY NUMBER,
  P_EVENT_CONDITION_ID in NUMBER,
  P_RESOLUTION_CODE in VARCHAR2,
  P_INCIDENT_STATUS_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_RELATIONSHIP_TYPE_ID in NUMBER,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_NOTIFICATION_TEMPLATE_ID in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_CREATION_DATE in DATE,
  P_CREATED_BY in NUMBER,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
);

procedure LOCK_ROW (
  P_EVENT_ACTION_DETAIL_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER
);

procedure UPDATE_ROW (
  P_EVENT_ACTION_DETAIL_ID   IN NUMBER,
  P_EVENT_CONDITION_ID in NUMBER,
  P_RESOLUTION_CODE in VARCHAR2,
  P_INCIDENT_STATUS_ID in NUMBER,
  P_START_DATE_ACTIVE in DATE,
  P_END_DATE_ACTIVE in DATE,
  P_RELATIONSHIP_TYPE_ID in NUMBER,
  P_SEEDED_FLAG in VARCHAR2,
  P_APPLICATION_ID in NUMBER,
  P_NOTIFICATION_TEMPLATE_ID in VARCHAR2,
  P_ACTION_CODE in VARCHAR2,
  P_LAST_UPDATE_DATE in DATE,
  P_LAST_UPDATED_BY in NUMBER,
  P_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER out NOCOPY NUMBER
);

procedure DELETE_ROW (
  P_EVENT_ACTION_DETAIL_ID in NUMBER
);

PROCEDURE LOAD_ROW (
  P_EVENT_CONDITION_ID       IN NUMBER,
  P_RESOLUTION_CODE          IN VARCHAR2,
  P_INCIDENT_STATUS_ID       IN NUMBER,
  P_START_DATE_ACTIVE        IN VARCHAR2,
  P_END_DATE_ACTIVE          IN VARCHAR2,
  P_RELATIONSHIP_TYPE_ID     IN NUMBER,
  P_SEEDED_FLAG              IN VARCHAR2,
  P_APPLICATION_ID           IN NUMBER,
  P_NOTIFICATION_TEMPLATE_ID IN VARCHAR2,
  P_ACTION_CODE              IN VARCHAR2,
  P_OWNER                    IN VARCHAR2,
  P_CREATION_DATE            IN VARCHAR2,
  P_CREATED_BY               IN NUMBER,
  P_LAST_UPDATE_DATE         IN VARCHAR2,
  P_LAST_UPDATED_BY          IN NUMBER,
  P_LAST_UPDATE_LOGIN        IN NUMBER,
  P_OBJECT_VERSION_NUMBER    IN NUMBER,
  P_EVENT_ACTION_DETAIL_ID   IN NUMBER
);

end CS_SR_ACTION_DETAILS_PKG;

 

/
