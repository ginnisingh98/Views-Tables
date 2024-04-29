--------------------------------------------------------
--  DDL for Package Body CSD_TASK_QUALITY_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_TASK_QUALITY_RESULTS_PKG" as
/* $Header: csdttqrb.pls 120.0 2005/06/27 16:10:51 sangigup noship $ csdtactb.pls */

    G_PKG_NAME CONSTANT  VARCHAR2(30)  := 'CSD_TASK_QUALITY_RESULTS_PKG';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdttqrb.pls';
    l_debug              NUMBER       := csd_gen_utility_pvt.g_debug_level;

    -- Global variable for storing the debug level
    G_debug_level number   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

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
         )


     IS

 CURSOR C2 IS SELECT CSD_TASK_QUALITY_RESULTS_S.nextval FROM sys.dual;
    BEGIN

        If (px_TASK_QUALITY_RESULT_ID IS NULL) OR (px_TASK_QUALITY_RESULT_ID = FND_API.G_MISS_NUM) then
         OPEN C2;
         FETCH C2 INTO px_task_quality_result_ID;
         CLOSE C2;
       End If;

       INSERT INTO CSD_TASK_QUALITY_RESULTS(
               TASK_QUALITY_RESULT_ID
	       ,TASK_ID
              ,OBJECT_VERSION_NUMBER
              ,QA_COLLECTION_ID
	      ,PLAN_ID
              ,CREATED_BY
              ,CREATION_DATE
              ,LAST_UPDATED_BY
              ,LAST_UPDATE_DATE
              ,LAST_UPDATE_LOGIN
              ) VALUES (
               px_TASK_QUALITY_RESULT_ID
	      ,decode( p_TASK_ID, FND_API.G_MISS_NUM, NULL, p_TASK_ID)
              ,decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, p_OBJECT_VERSION_NUMBER)
              ,decode( p_QA_COLLECTION_ID, FND_API.G_MISS_NUM, NULL, p_QA_COLLECTION_ID)
	      ,decode( p_PLAN_ID, FND_API.G_MISS_NUM, NULL, p_PLAN_ID)
              ,decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY)
              ,decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE)
              ,decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY)
              ,decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE)
              ,decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN)
              );
    End Insert_Row;

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
        )

    IS
    BEGIN
        Update CSD_TASK_QUALITY_RESULTS
        SET

	    TASK_ID = decode( p_TASK_ID, FND_API.G_MISS_NUM, NULL, NULL, TASK_ID, p_TASK_ID)
	   ,OBJECT_VERSION_NUMBER = decode( p_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, NULL, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER)
           ,QA_COLLECTION_ID = decode( p_QA_COLLECTION_ID, FND_API.G_MISS_NUM, NULL, NULL, QA_COLLECTION_ID, p_QA_COLLECTION_ID)
	   ,PLAN_ID = decode( p_PLAN_ID, FND_API.G_MISS_NUM, NULL, p_PLAN_ID)
           ,CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, NULL, CREATED_BY, p_CREATED_BY)
           ,CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, NULL, NULL, CREATION_DATE, p_CREATION_DATE)
           ,LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATED_BY, p_LAST_UPDATED_BY)
           ,LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL, NULL, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE)
           ,LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, NULL, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN)
            where TASK_QUALITY_RESULT_ID = px_TASK_QUALITY_RESULT_ID
	    and OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER;

        If (SQL%NOTFOUND) then
            RAISE NO_DATA_FOUND;
        End If;
    END Update_Row;

    PROCEDURE Delete_Row(
		p_TASK_ID    NUMBER)
    IS
    BEGIN
        DELETE FROM CSD_TASK_QUALITY_RESULTS
        WHERE TASK_ID = p_TASK_ID;

        If (SQL%NOTFOUND) then
            RAISE NO_DATA_FOUND;
        End If;
    END Delete_Row;

 PROCEDURE Lock_Row(
          p_TASK_QUALITY_RESULT_ID   NUMBER
         ,p_OBJECT_VERSION_NUMBER    NUMBER)


 IS
   CURSOR C IS
       SELECT *
       FROM CSD_TASK_QUALITY_RESULTS
       WHERE TASK_QUALITY_RESULT_ID =  p_TASK_QUALITY_RESULT_ID
       FOR UPDATE of TASK_QUALITY_RESULT_ID NOWAIT;
   Recinfo C%ROWTYPE;
BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (  Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER ) then
        return;
    else
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
END Lock_Row;



End CSD_TASK_QUALITY_RESULTS_PKG;

/
