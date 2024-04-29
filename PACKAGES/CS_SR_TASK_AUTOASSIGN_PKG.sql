--------------------------------------------------------
--  DDL for Package CS_SR_TASK_AUTOASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_TASK_AUTOASSIGN_PKG" AUTHID CURRENT_USER as
/* $Header: csxasrts.pls 120.2 2006/01/30 20:51:53 brajasek noship $ */

TYPE SR_Task_rec_type IS RECORD
(      TASK_ID                        NUMBER,
      SERVICE_REQUEST_ID             NUMBER,
      PARTY_ID                       NUMBER,
      COUNTRY                        VARCHAR2(60),
      PARTY_SITE_ID                  NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      AREA_CODE                      VARCHAR2(10),
      COUNTY                         VARCHAR2(60),
      COMP_NAME_RANGE                VARCHAR2(360),
      PROVINCE                       VARCHAR2(60),
      NUM_OF_EMPLOYEES               NUMBER,
      TASK_TYPE_ID                   NUMBER,
      TASK_STATUS_ID                 NUMBER,
      TASK_PRIORITY_ID               NUMBER,
      INCIDENT_TYPE_ID               NUMBER,
      INCIDENT_SEVERITY_ID           NUMBER,
      INCIDENT_URGENCY_ID            NUMBER,
      PROBLEM_CODE                   VARCHAR2(60),
      INCIDENT_STATUS_ID             NUMBER,
      PLATFORM_ID                    NUMBER,
      SUPPORT_SITE_ID                NUMBER,
      CUSTOMER_SITE_ID               NUMBER,
      SR_CREATION_CHANNEL            VARCHAR2(150),
      INVENTORY_ITEM_ID              NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORGANIZATION_ID                NUMBER,
      SQUAL_NUM12                    NUMBER, --INVENTORY ITEM ID / SR PLATFORM
      SQUAL_NUM13                    NUMBER, --ORGANIZATION ID   / SR PLATFORM
      SQUAL_NUM14                    NUMBER, --CATEGORY ID       / SR PRODUCT
      SQUAL_NUM15                    NUMBER, --INVENTORY ITEM ID / SR PRODUCT
      SQUAL_NUM16                    NUMBER, --ORGANIZATION ID   / SR PRODUCT
      SQUAL_NUM17                    NUMBER, --SR GROUP OWNER
      SQUAL_NUM18                    NUMBER, --INVENTORY ITEM ID / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM19                    NUMBER, --ORGANIZATION ID   / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM30                    NUMBER, --SR LANGUAGE ... should use squal_char20 instead
      SQUAL_CHAR11                   VARCHAR2(360), --VIP CUSTOMERS
      SQUAL_CHAR12                   VARCHAR2(360), --SR PROBLEM CODE
      SQUAL_CHAR13                   VARCHAR2(360), --SR CUSTOMER CONTACT PREFERENCE
      SQUAL_CHAR20                   VARCHAR2(360),  --SR LANGUAGE ID for TERR REQ
      SQUAL_CHAR21                   VARCHAR2(360),  --SR Service Contract Coverage
      ITEM_COMPONENT                 NUMBER,
      ITEM_SUBCOMPONENT              NUMBER
    );

PROCEDURE Assign_Task_Resource
  (p_api_version            IN    NUMBER,
   p_init_msg_list          IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                 IN    VARCHAR2 DEFAULT fnd_api.g_false,
   p_incident_id            IN    NUMBER,
   p_service_request_rec    IN    CS_ServiceRequest_PUB.service_request_rec_type DEFAULT NULL,
   p_task_attribute_rec     IN    SR_Task_rec_type,
   x_owner_group_id         OUT   NOCOPY   NUMBER,
   x_group_type             OUT   NOCOPY   VARCHAR2,
   x_owner_type             OUT   NOCOPY   VARCHAR2,
   x_owner_id               OUT   NOCOPY   NUMBER,
   x_territory_id           OUT   NOCOPY   NUMBER,
   x_return_status          OUT   NOCOPY   VARCHAR2,
   x_msg_count              OUT   NOCOPY   NUMBER,
   x_msg_data               OUT   NOCOPY   VARCHAR2
  );

END CS_SR_TASK_AUTOASSIGN_PKG;

 

/
