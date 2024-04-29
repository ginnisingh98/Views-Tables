--------------------------------------------------------
--  DDL for Package CSD_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_TASKS_PKG" AUTHID CURRENT_USER as
/* $Header: csdttsks.pls 120.0 2005/06/26 14:56:59 sangigup noship $ csdtacts.pls */

PROCEDURE Insert_Row(
             px_repair_TASK_ID   IN OUT NOCOPY NUMBER
	     ,p_task_id       NUMBER
             ,p_REPAIR_LINE_ID    NUMBER
	     ,p_APPLICABLE_QA_PLANS VARCHAR2
	     ,p_OBJECT_VERSION_NUMBER    NUMBER
             ,p_CREATED_BY    NUMBER
             ,p_CREATION_DATE    DATE
             ,p_LAST_UPDATED_BY    NUMBER
             ,p_LAST_UPDATE_DATE    DATE
             ,p_LAST_UPDATE_LOGIN    NUMBER
         );

PROCEDURE Update_Row(
 	  px_repair_TASK_ID NUMBER
         ,p_TASK_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_REPAIR_LINE_ID    NUMBER
	 ,p_APPLICABLE_QA_PLANS VARCHAR2
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
        );

	PROCEDURE Lock_Row(
          p_REPAIR_TASK_ID    NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);


PROCEDURE Delete_Row(
          p_repair_TASK_ID    NUMBER
         );

End CSD_TASKS_PKG;
 

/