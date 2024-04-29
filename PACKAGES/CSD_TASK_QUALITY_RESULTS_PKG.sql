--------------------------------------------------------
--  DDL for Package CSD_TASK_QUALITY_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_TASK_QUALITY_RESULTS_PKG" AUTHID CURRENT_USER as
/* $Header: csdttqrs.pls 120.0 2005/06/27 16:09:51 sangigup noship $ csdtacts.pls */

PROCEDURE Insert_Row(
              px_TASK_QUALITY_RESULT_ID   IN OUT NOCOPY NUMBER
	     ,p_TASK_ID       NUMBER
             ,p_QA_COLLECTION_ID    NUMBER
	     ,p_PLAN_ID        NUMBER
	     ,p_OBJECT_VERSION_NUMBER    NUMBER
             ,p_CREATED_BY    NUMBER
             ,p_CREATION_DATE    DATE
             ,p_LAST_UPDATED_BY    NUMBER
             ,p_LAST_UPDATE_DATE    DATE
             ,p_LAST_UPDATE_LOGIN    NUMBER
         );

PROCEDURE Update_Row(
 	  px_TASK_QUALITY_RESULT_ID NUMBER
         ,p_TASK_ID    NUMBER
	 ,p_QA_COLLECTION_ID NUMBER
	 ,p_PLAN_ID 	     NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER
         ,p_CREATED_BY    NUMBER
         ,p_CREATION_DATE    DATE
         ,p_LAST_UPDATED_BY    NUMBER
         ,p_LAST_UPDATE_DATE    DATE
         ,p_LAST_UPDATE_LOGIN    NUMBER
        );

PROCEDURE Lock_Row(
          p_TASK_QUALITY_RESULT_ID   NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER);


PROCEDURE Delete_Row(
          p_TASK_ID    NUMBER
         );

End CSD_TASK_QUALITY_RESULTS_PKG;
 

/
