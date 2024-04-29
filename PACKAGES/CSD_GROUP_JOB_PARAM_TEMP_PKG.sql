--------------------------------------------------------
--  DDL for Package CSD_GROUP_JOB_PARAM_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GROUP_JOB_PARAM_TEMP_PKG" AUTHID CURRENT_USER as
/* $Header: csdtjprs.pls 115.4 2002/12/02 23:43:17 takwong noship $ */
-- Start of Comments
-- Package name     : CSD_GROUP_JOB_PARAM_TEMP_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_GROUP_JOB_ID   IN OUT NOCOPY NUMBER
         ,p_REPAIR_GROUP_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_ORGANIZATION_ID    NUMBER
         ,p_JOB_TYPE    NUMBER
         ,p_ROUTING_REFERENCE_ID    NUMBER
         ,p_ALTERNATE_DESIGNATOR_CODE    VARCHAR2
         ,p_JOB_STATUS_TYPE    VARCHAR2
         ,p_ACCOUNTING_CLASS    VARCHAR2
         ,p_START_DATE    DATE
         ,p_COMPLETION_DATE    DATE
         ,p_QUANTITY_RECEIVED    NUMBER
         ,p_QUANTITY_SUBMITTED    NUMBER
         ,p_ITEM_REVISION    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_INCIDENT_ID    NUMBER
         ,p_PROCESS_ID    NUMBER);

PROCEDURE Update_Row(
          p_GROUP_JOB_ID    NUMBER
         ,p_REPAIR_GROUP_ID    NUMBER
         ,p_INVENTORY_ITEM_ID    NUMBER
         ,p_ORGANIZATION_ID    NUMBER
         ,p_JOB_TYPE    NUMBER
         ,p_ROUTING_REFERENCE_ID    NUMBER
         ,p_ALTERNATE_DESIGNATOR_CODE    VARCHAR2
         ,p_JOB_STATUS_TYPE    VARCHAR2
         ,p_ACCOUNTING_CLASS    VARCHAR2
         ,p_START_DATE    DATE
         ,p_COMPLETION_DATE    DATE
         ,p_QUANTITY_RECEIVED    NUMBER
         ,p_QUANTITY_SUBMITTED    NUMBER
         ,p_ITEM_REVISION    VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_LOGIN    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_INCIDENT_ID    NUMBER
         ,p_PROCESS_ID    NUMBER);

PROCEDURE Lock_Row(
          p_GROUP_JOB_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);

PROCEDURE Delete_Row(
    p_GROUP_JOB_ID  NUMBER);
End CSD_GROUP_JOB_PARAM_TEMP_PKG;

 

/
