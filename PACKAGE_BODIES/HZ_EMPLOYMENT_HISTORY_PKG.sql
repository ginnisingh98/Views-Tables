--------------------------------------------------------
--  DDL for Package Body HZ_EMPLOYMENT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EMPLOYMENT_HISTORY_PKG" as
/* $Header: ARHEHITB.pls 120.7 2005/10/30 03:52:10 appldev ship $ */


PROCEDURE Insert_Row(

                  x_EMPLOYMENT_HISTORY_ID       IN  OUT NOCOPY   NUMBER,
                  x_BEGIN_DATE                  IN      DATE,
                  x_PARTY_ID                    IN      NUMBER,
                  x_EMPLOYED_AS_TITLE           IN      VARCHAR2,
                  x_EMPLOYED_BY_DIVISION_NAME   IN      VARCHAR2,
                  x_EMPLOYED_BY_NAME_COMPANY    IN      VARCHAR2,
                  x_END_DATE                    IN      DATE,
                  x_SUPERVISOR_NAME             IN      VARCHAR2,
                  x_BRANCH                      IN      VARCHAR2,
                  x_MILITARY_RANK               IN      VARCHAR2,
                  x_SERVED                      IN      VARCHAR2,
                  x_STATION                     IN      VARCHAR2,
                  x_RESPONSIBILITY              IN      VARCHAR2,
                  x_STATUS                      IN      VARCHAR2,
    		  x_OBJECT_VERSION_NUMBER       IN      NUMBER,
    		  x_CREATED_BY_MODULE           IN      VARCHAR2,
    		  x_APPLICATION_ID              IN      NUMBER,
    		  x_EMPLOYED_BY_PARTY_ID        IN      NUMBER,
    		  x_REASON_FOR_LEAVING          IN      VARCHAR2,
    		  x_FACULTY_POSITION_FLAG       IN      VARCHAR2,
    		  x_TENURE_CODE                 IN      VARCHAR2,
    		  x_FRACTION_OF_TENURE          IN      NUMBER,
    		  x_EMPLOYMENT_TYPE_CODE        IN      VARCHAR2,
    		  x_EMPLOYED_AS_TITLE_CODE      IN      VARCHAR2,
    		  x_WEEKLY_WORK_HOURS           IN      NUMBER,
    		  x_COMMENTS                    IN      VARCHAR2

 ) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN

   INSERT INTO HZ_EMPLOYMENT_HISTORY(
           EMPLOYMENT_HISTORY_ID,
           BEGIN_DATE,
           PARTY_ID,
           EMPLOYED_AS_TITLE,
           EMPLOYED_BY_DIVISION_NAME,
           EMPLOYED_BY_NAME_COMPANY,
           END_DATE,
           SUPERVISOR_NAME,
           BRANCH,
           MILITARY_RANK,
           CREATED_BY,
           CREATION_DATE,
           SERVED,
           LAST_UPDATE_LOGIN,
           STATION,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           RESPONSIBILITY,
           STATUS,
           OBJECT_VERSION_NUMBER,
           CREATED_BY_MODULE,
           APPLICATION_ID,
           EMPLOYED_BY_PARTY_ID,
           REASON_FOR_LEAVING,
    	   FACULTY_POSITION_FLAG,
    	   TENURE_CODE,
    	   FRACTION_OF_TENURE,
    	   EMPLOYMENT_TYPE_CODE,
    	   EMPLOYED_AS_TITLE_CODE,
    	   WEEKLY_WORK_HOURS,
           COMMENTS
          ) VALUES (
           decode( x_EMPLOYMENT_HISTORY_ID, FND_API.G_MISS_NUM, HZ_EMPLOYMENT_HISTORY_S.NEXTVAL, NULL, HZ_EMPLOYMENT_HISTORY_S.NEXTVAL, x_EMPLOYMENT_HISTORY_ID ),
           decode( x_BEGIN_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_BEGIN_DATE),
           decode( x_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_PARTY_ID),
           decode( x_EMPLOYED_AS_TITLE, FND_API.G_MISS_CHAR, NULL,x_EMPLOYED_AS_TITLE),
           decode( x_EMPLOYED_BY_DIVISION_NAME, FND_API.G_MISS_CHAR, NULL,x_EMPLOYED_BY_DIVISION_NAME),
           decode( x_EMPLOYED_BY_NAME_COMPANY, FND_API.G_MISS_CHAR, NULL,x_EMPLOYED_BY_NAME_COMPANY),
           decode( x_END_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_END_DATE),
           decode( x_SUPERVISOR_NAME, FND_API.G_MISS_CHAR, NULL,x_SUPERVISOR_NAME),
           decode( x_BRANCH, FND_API.G_MISS_CHAR, NULL,x_BRANCH),
           decode( x_MILITARY_RANK, FND_API.G_MISS_CHAR, NULL,x_MILITARY_RANK),
           HZ_UTILITY_V2PUB.CREATED_BY,
           HZ_UTILITY_V2PUB.CREATION_DATE,
           decode( x_SERVED, FND_API.G_MISS_CHAR, NULL,x_SERVED),
           HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
           decode( x_STATION, FND_API.G_MISS_CHAR, NULL,x_STATION),
           HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
	   HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
	   HZ_UTILITY_V2PUB.REQUEST_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_ID,
	   HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
           decode( x_RESPONSIBILITY, FND_API.G_MISS_CHAR, NULL, x_RESPONSIBILITY),
           DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
           DECODE( x_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, x_OBJECT_VERSION_NUMBER ),
           DECODE( x_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, x_CREATED_BY_MODULE ),
           HZ_UTILITY_V2PUB.APPLICATION_ID,
           decode( x_EMPLOYED_BY_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_EMPLOYED_BY_PARTY_ID),
           decode( x_REASON_FOR_LEAVING, FND_API.G_MISS_CHAR, NULL, x_REASON_FOR_LEAVING ),
           decode( x_FACULTY_POSITION_FLAG, FND_API.G_MISS_CHAR, NULL, x_FACULTY_POSITION_FLAG ),
           decode( x_TENURE_CODE, FND_API.G_MISS_CHAR, NULL, X_TENURE_CODE ),
           decode( x_FRACTION_OF_TENURE, FND_API.G_MISS_NUM, NULL,x_FRACTION_OF_TENURE),
           decode( x_EMPLOYMENT_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, x_EMPLOYMENT_TYPE_CODE ),
           decode( x_EMPLOYED_AS_TITLE_CODE, FND_API.G_MISS_CHAR, NULL, x_EMPLOYED_AS_TITLE_CODE ),
           decode( x_WEEKLY_WORK_HOURS, FND_API.G_MISS_NUM, NULL,x_WEEKLY_WORK_HOURS),
           decode( x_COMMENTS, FND_API.G_MISS_CHAR, NULL, x_COMMENTS )
           )

             RETURNING
   	              EMPLOYMENT_HISTORY_ID
   	          INTO
   	              X_EMPLOYMENT_HISTORY_ID;

   	          l_success := 'Y';

   	      EXCEPTION
   	          WHEN DUP_VAL_ON_INDEX THEN
   	              IF INSTRB( SQLERRM, 'HZ_EMPLOYMENT_HISTORY_U1' ) <> 0 OR
   	                 INSTRB( SQLERRM, 'HZ_EMPLOYMENT_HISTORY_PK' ) <> 0
   	              THEN
   	              DECLARE
   	                  l_count             NUMBER;
   	                  l_dummy             VARCHAR2(1);
   	              BEGIN
   	                  l_count := 1;
   	                  WHILE l_count > 0 LOOP
   	                      SELECT HZ_EMPLOYMENT_HISTORY_S.NEXTVAL
   	                      INTO X_EMPLOYMENT_HISTORY_ID FROM dual;
   	                      BEGIN
   	                          SELECT 'Y' INTO l_dummy
   	                          FROM HZ_EMPLOYMENT_HISTORY
   	                          WHERE EMPLOYMENT_HISTORY_ID = EMPLOYMENT_HISTORY_ID;
   	                          l_count := 1;
   	                      EXCEPTION
   	                          WHEN NO_DATA_FOUND THEN
   	                              l_count := 0;
   	                      END;
   	                  END LOOP;
   	              END;
   	              ELSE
   	                  RAISE;
   	              END IF;

   	      END;
   	      END LOOP;

   END Insert_Row;




PROCEDURE Delete_Row(                  x_EMPLOYMENT_HISTORY_ID         NUMBER
 ) IS
 BEGIN
   DELETE FROM HZ_EMPLOYMENT_HISTORY
    WHERE EMPLOYMENT_HISTORY_ID = x_EMPLOYMENT_HISTORY_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                       IN  OUT NOCOPY   VARCHAR2,
                  x_EMPLOYMENT_HISTORY_ID       IN  OUT NOCOPY   NUMBER,
                  x_BEGIN_DATE                  IN      DATE,
                  x_PARTY_ID                    IN      NUMBER,
                  x_EMPLOYED_AS_TITLE           IN      VARCHAR2,
                  x_EMPLOYED_BY_DIVISION_NAME   IN      VARCHAR2,
                  x_EMPLOYED_BY_NAME_COMPANY    IN      VARCHAR2,
                  x_END_DATE                    IN      DATE,
                  x_SUPERVISOR_NAME             IN      VARCHAR2,
                  x_BRANCH                      IN      VARCHAR2,
                  x_MILITARY_RANK               IN      VARCHAR2,
                  x_SERVED                      IN      VARCHAR2,
                  x_STATION                     IN      VARCHAR2,
                  x_RESPONSIBILITY              IN      VARCHAR2,
                  x_STATUS                      IN      VARCHAR2,
    		  x_OBJECT_VERSION_NUMBER       IN      NUMBER,
    		  x_CREATED_BY_MODULE           IN      VARCHAR2,
    		  x_APPLICATION_ID              IN      NUMBER,
    		  x_EMPLOYED_BY_PARTY_ID        IN      NUMBER,
    		  x_REASON_FOR_LEAVING          IN      VARCHAR2,
    		  x_FACULTY_POSITION_FLAG        IN      VARCHAR2,
    		  x_TENURE_CODE                 IN      VARCHAR2,
    		  x_FRACTION_OF_TENURE          IN      NUMBER,
    		  x_EMPLOYMENT_TYPE_CODE        IN      VARCHAR2,
    		  x_EMPLOYED_AS_TITLE_CODE      IN      VARCHAR2,
    		  x_WEEKLY_WORK_HOURS           IN      NUMBER,
    		  x_COMMENTS                    IN      VARCHAR2
 ) IS
 BEGIN
    Update HZ_EMPLOYMENT_HISTORY
    SET
                          EMPLOYMENT_HISTORY_ID 	= decode( x_EMPLOYMENT_HISTORY_ID, NULL, EMPLOYMENT_HISTORY_ID, FND_API.G_MISS_NUM,NULL, X_EMPLOYMENT_HISTORY_ID,x_EMPLOYMENT_HISTORY_ID),
                          BEGIN_DATE 	   	        = decode( x_BEGIN_DATE, NULL,BEGIN_DATE,FND_API.G_MISS_DATE,NULL,x_BEGIN_DATE),
	                  PARTY_ID 		   	= decode( x_PARTY_ID, NULL,PARTY_ID,FND_API.G_MISS_NUM,NULL,x_PARTY_ID),
	                  EMPLOYED_AS_TITLE 	   	= decode( x_EMPLOYED_AS_TITLE, NULL,EMPLOYED_AS_TITLE, FND_API.G_MISS_CHAR,NULL,x_EMPLOYED_AS_TITLE),
	                  EMPLOYED_BY_DIVISION_NAME 	= decode( x_EMPLOYED_BY_DIVISION_NAME, NULL,EMPLOYED_BY_DIVISION_NAME, FND_API.G_MISS_CHAR,NULL,x_EMPLOYED_BY_DIVISION_NAME),
	                  EMPLOYED_BY_NAME_COMPANY 	= decode( x_EMPLOYED_BY_NAME_COMPANY, NULL,EMPLOYED_BY_NAME_COMPANY,FND_API.G_MISS_CHAR,NULL,x_EMPLOYED_BY_NAME_COMPANY),
	                  END_DATE 		   	= decode( x_END_DATE, NULL,END_DATE,FND_API.G_MISS_DATE,NULL,x_END_DATE),
	                  SUPERVISOR_NAME 	   	= decode( x_SUPERVISOR_NAME, NULL,SUPERVISOR_NAME,FND_API.G_MISS_CHAR,NULL,x_SUPERVISOR_NAME),
	                  BRANCH 		   	= decode( x_BRANCH,NULL,BRANCH, FND_API.G_MISS_CHAR,NULL, x_BRANCH),
	                  MILITARY_RANK 	   	= decode( x_MILITARY_RANK, NULL,MILITARY_RANK,FND_API.G_MISS_CHAR,NULL,x_MILITARY_RANK),
	                  SERVED 		   	= decode( x_SERVED, NULL,SERVED,FND_API.G_MISS_CHAR,NULL,x_SERVED),
	                  STATION 		   	= decode( x_STATION, NULL,STATION,FND_API.G_MISS_CHAR,NULL,x_STATION),
	                  RESPONSIBILITY 		= decode( x_RESPONSIBILITY, NULL,RESPONSIBILITY, FND_API.G_MISS_CHAR,NULL,x_RESPONSIBILITY),
	                  STATUS        		= decode( x_STATUS,NULL,STATUS, FND_API.G_MISS_CHAR,NULL,x_STATUS),
	                  OBJECT_VERSION_NUMBER 	= DECODE( x_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
	                  CREATED_BY_MODULE 	        = DECODE( x_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
	                  APPLICATION_ID 		= DECODE( x_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
	                  EMPLOYED_BY_PARTY_ID          = decode( x_EMPLOYED_BY_PARTY_ID, NULL,EMPLOYED_BY_PARTY_ID, FND_API.G_MISS_NUM, NULL,x_EMPLOYED_BY_PARTY_ID),
	                  REASON_FOR_LEAVING            = decode( x_REASON_FOR_LEAVING, NULL,REASON_FOR_LEAVING, FND_API.G_MISS_CHAR, NULL, X_REASON_FOR_LEAVING ),
	                  FACULTY_POSITION_FLAG	        = decode( x_FACULTY_POSITION_FLAG, NULL,FACULTY_POSITION_FLAG, FND_API.G_MISS_CHAR, NULL, X_FACULTY_POSITION_FLAG ),
	                  TENURE_CODE 		        = decode( x_TENURE_CODE, NULL,TENURE_CODE, FND_API.G_MISS_CHAR,NULL,X_TENURE_CODE ),
	                  FRACTION_OF_TENURE  	        = decode( x_FRACTION_OF_TENURE, NULL,FRACTION_OF_TENURE, FND_API.G_MISS_NUM, NULL, x_FRACTION_OF_TENURE),
	                  EMPLOYMENT_TYPE_CODE 	        = decode( x_EMPLOYMENT_TYPE_CODE, NULL, EMPLOYMENT_TYPE_CODE, FND_API.G_MISS_CHAR, NULL, X_EMPLOYMENT_TYPE_CODE ),
	                  EMPLOYED_AS_TITLE_CODE 	= decode( x_EMPLOYED_AS_TITLE_CODE, NULL, EMPLOYED_AS_TITLE_CODE, FND_API.G_MISS_CHAR, NULL, X_EMPLOYED_AS_TITLE_CODE ),
	                  WEEKLY_WORK_HOURS		= decode( x_WEEKLY_WORK_HOURS, NULL, WEEKLY_WORK_HOURS, FND_API.G_MISS_NUM, NULL, x_WEEKLY_WORK_HOURS),
	                  COMMENTS			= decode( x_COMMENTS, NULL, COMMENTS, FND_API.G_MISS_CHAR, NULL, X_COMMENTS ),
                    -- Bug 3032780
	            --      CREATED_BY 	   	        = HZ_UTILITY_V2PUB.CREATED_BY,
	            --      CREATION_DATE 	   	= HZ_UTILITY_V2PUB.CREATION_DATE,
	                  LAST_UPDATE_LOGIN     	= HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
	                  LAST_UPDATE_DATE 	   	= HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
	                  LAST_UPDATED_BY 	   	= HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
	                  REQUEST_ID 	   	        = HZ_UTILITY_V2PUB.REQUEST_ID,
	                  PROGRAM_APPLICATION_ID 	= HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
	                  PROGRAM_ID 	   	        = HZ_UTILITY_V2PUB.PROGRAM_ID,
	                  PROGRAM_UPDATE_DATE 	        = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE

    where rowid = X_RowId;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;
 END Update_Row;



PROCEDURE Lock_Row(
                  x_Rowid                         IN       VARCHAR2,
		  x_EMPLOYMENT_HISTORY_ID         IN       NUMBER,
		  x_BEGIN_DATE                    IN       DATE,
		  x_PARTY_ID                      IN       NUMBER,
		  x_EMPLOYED_AS_TITLE             IN       VARCHAR2,
		  x_EMPLOYED_BY_DIVISION_NAME     IN       VARCHAR2,
		  x_EMPLOYED_BY_NAME_COMPANY      IN       VARCHAR2,
		  x_END_DATE                      IN       DATE,
		  x_SUPERVISOR_NAME               IN       VARCHAR2,
		  x_BRANCH                        IN       VARCHAR2,
		  x_MILITARY_RANK                 IN       VARCHAR2,
		  x_CREATED_BY                    IN       NUMBER,
		  x_CREATION_DATE                 IN       DATE,
		  x_SERVED                        IN       VARCHAR2,
		  x_LAST_UPDATE_LOGIN             IN       NUMBER,
		  x_STATION                       IN       VARCHAR2,
		  x_LAST_UPDATE_DATE              IN       DATE,
		  x_LAST_UPDATED_BY               IN       NUMBER,
		  x_REQUEST_ID                    IN       NUMBER,
		  x_PROGRAM_APPLICATION_ID        IN       NUMBER,
		  x_PROGRAM_ID                    IN       NUMBER,
		  x_PROGRAM_UPDATE_DATE           IN       DATE,
		  x_WH_UPDATE_DATE                IN       DATE,
		  x_RESPONSIBILITY                IN       VARCHAR2,
		  x_STATUS                        IN	   VARCHAR2,
		  x_EMPLOYED_BY_PARTY_ID          IN       NUMBER,
		  x_REASON_FOR_LEAVING            IN       VARCHAR2,
		  x_FACULTY_POSITION_FLAG          IN       VARCHAR2,
		  x_TENURE_CODE                   IN       VARCHAR2,
		  x_FRACTION_OF_TENURE            IN       NUMBER,
		  x_EMPLOYMENT_TYPE_CODE          IN       VARCHAR2,
		  x_EMPLOYED_AS_TITLE_CODE        IN       VARCHAR2,
		  x_WEEKLY_WORK_HOURS             IN       NUMBER,
    		  x_COMMENTS                      IN       VARCHAR2,
    		  x_APPLICATION_ID                IN       NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM HZ_EMPLOYMENT_HISTORY
         WHERE rowid = x_Rowid
         FOR UPDATE of EMPLOYMENT_HISTORY_ID NOWAIT;
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
    if (
           (    ( Recinfo.EMPLOYMENT_HISTORY_ID = x_EMPLOYMENT_HISTORY_ID)
            OR (    ( Recinfo.EMPLOYMENT_HISTORY_ID = NULL )
                AND (  x_EMPLOYMENT_HISTORY_ID = NULL )))
       AND (    ( Recinfo.BEGIN_DATE = x_BEGIN_DATE)
            OR (    ( Recinfo.BEGIN_DATE = NULL )
                AND (  x_BEGIN_DATE = NULL )))
       AND (    ( Recinfo.PARTY_ID = x_PARTY_ID)
            OR (    ( Recinfo.PARTY_ID = NULL )
                AND (  x_PARTY_ID = NULL )))
       AND (    ( Recinfo.EMPLOYED_AS_TITLE = x_EMPLOYED_AS_TITLE)
            OR (    ( Recinfo.EMPLOYED_AS_TITLE = NULL )
                AND (  x_EMPLOYED_AS_TITLE = NULL )))
       AND (    ( Recinfo.EMPLOYED_BY_DIVISION_NAME = x_EMPLOYED_BY_DIVISION_NAME)
            OR (    ( Recinfo.EMPLOYED_BY_DIVISION_NAME = NULL )
                AND (  x_EMPLOYED_BY_DIVISION_NAME = NULL )))
       AND (    ( Recinfo.EMPLOYED_BY_NAME_COMPANY = x_EMPLOYED_BY_NAME_COMPANY)
            OR (    ( Recinfo.EMPLOYED_BY_NAME_COMPANY = NULL )
                AND (  x_EMPLOYED_BY_NAME_COMPANY = NULL )))
       AND (    ( Recinfo.END_DATE = x_END_DATE)
            OR (    ( Recinfo.END_DATE = NULL )
                AND (  x_END_DATE = NULL )))
       AND (    ( Recinfo.SUPERVISOR_NAME = x_SUPERVISOR_NAME)
            OR (    ( Recinfo.SUPERVISOR_NAME = NULL )
                AND (  x_SUPERVISOR_NAME = NULL )))
       AND (    ( Recinfo.BRANCH = x_BRANCH)
            OR (    ( Recinfo.BRANCH = NULL )
                AND (  x_BRANCH = NULL )))
       AND (    ( Recinfo.MILITARY_RANK = x_MILITARY_RANK)
            OR (    ( Recinfo.MILITARY_RANK = NULL )
                AND (  x_MILITARY_RANK = NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY = NULL )
                AND (  x_CREATED_BY = NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE = NULL )
                AND (  x_CREATION_DATE = NULL )))
       AND (    ( Recinfo.SERVED = x_SERVED)
            OR (    ( Recinfo.SERVED = NULL )
                AND (  x_SERVED = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN = NULL )
                AND (  x_LAST_UPDATE_LOGIN = NULL )))
       AND (    ( Recinfo.STATION = x_STATION)
            OR (    ( Recinfo.STATION = NULL )
                AND (  x_STATION = NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE = NULL )
                AND (  x_LAST_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY = NULL )
                AND (  x_LAST_UPDATED_BY = NULL )))
       AND (    ( Recinfo.REQUEST_ID = x_REQUEST_ID)
            OR (    ( Recinfo.REQUEST_ID = NULL )
                AND (  x_REQUEST_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_APPLICATION_ID = x_PROGRAM_APPLICATION_ID)
            OR (    ( Recinfo.PROGRAM_APPLICATION_ID = NULL )
                AND (  x_PROGRAM_APPLICATION_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_ID = x_PROGRAM_ID)
            OR (    ( Recinfo.PROGRAM_ID = NULL )
                AND (  x_PROGRAM_ID = NULL )))
       AND (    ( Recinfo.PROGRAM_UPDATE_DATE = x_PROGRAM_UPDATE_DATE)
            OR (    ( Recinfo.PROGRAM_UPDATE_DATE = NULL )
                AND (  x_PROGRAM_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.WH_UPDATE_DATE = x_WH_UPDATE_DATE)
            OR (    ( Recinfo.WH_UPDATE_DATE = NULL )
                AND (  x_WH_UPDATE_DATE = NULL )))
       AND (    ( Recinfo.RESPONSIBILITY = x_RESPONSIBILITY)
            OR (    ( Recinfo.RESPONSIBILITY = NULL )
                AND (  x_RESPONSIBILITY = NULL )))
       AND (    ( Recinfo.STATUS = x_STATUS)
            OR (    ( Recinfo.STATUS = NULL )
                AND (  x_STATUS = NULL )))
	AND (    ( Recinfo.APPLICATION_ID = x_APPLICATION_ID)
            OR (    ( Recinfo.APPLICATION_ID = NULL )
                AND (  x_APPLICATION_ID = NULL )))
	AND (    ( Recinfo.EMPLOYED_BY_PARTY_ID = x_EMPLOYED_BY_PARTY_ID)
            OR (    ( Recinfo.EMPLOYED_BY_PARTY_ID = NULL )
                AND (  x_EMPLOYED_BY_PARTY_ID = NULL )))
	AND (    ( Recinfo.REASON_FOR_LEAVING = x_REASON_FOR_LEAVING)
            OR (    ( Recinfo.REASON_FOR_LEAVING = NULL )
                AND (  x_REASON_FOR_LEAVING = NULL )))
	AND (    ( Recinfo.FACULTY_POSITION_FLAG = x_FACULTY_POSITION_FLAG)
            OR (    ( Recinfo.FACULTY_POSITION_FLAG = NULL )
                AND (  x_FACULTY_POSITION_FLAG = NULL )))
	AND (    ( Recinfo.TENURE_CODE = x_TENURE_CODE)
            OR (    ( Recinfo.TENURE_CODE = NULL )
                AND (  x_TENURE_CODE = NULL )))
	AND (    ( Recinfo.FRACTION_OF_TENURE = x_FRACTION_OF_TENURE)
            OR (    ( Recinfo.FRACTION_OF_TENURE = NULL )
                AND (  x_FRACTION_OF_TENURE = NULL )))
	AND (    ( Recinfo.EMPLOYMENT_TYPE_CODE = x_EMPLOYMENT_TYPE_CODE)
            OR (    ( Recinfo.EMPLOYMENT_TYPE_CODE = NULL )
                AND (  x_EMPLOYMENT_TYPE_CODE = NULL )))
	AND (    ( Recinfo.EMPLOYED_AS_TITLE_CODE = x_EMPLOYED_AS_TITLE_CODE)
            OR (    ( Recinfo.EMPLOYED_AS_TITLE_CODE = NULL )
                AND (  x_EMPLOYED_AS_TITLE_CODE = NULL )))
	AND (    ( Recinfo.WEEKLY_WORK_HOURS = x_WEEKLY_WORK_HOURS)
            OR (    ( Recinfo.WEEKLY_WORK_HOURS = NULL )
                AND (  x_WEEKLY_WORK_HOURS = NULL )))
	AND (    ( Recinfo.COMMENTS = x_COMMENTS)
            OR (    ( Recinfo.COMMENTS = NULL )
                AND (  x_COMMENTS = NULL )))




       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
END Lock_Row;


PROCEDURE Select_Row (
    x_employment_history_id                 IN OUT NOCOPY NUMBER,
    x_begin_date                            OUT    NOCOPY DATE,
    x_party_id                              OUT    NOCOPY NUMBER,
    x_employed_as_title                     OUT    NOCOPY VARCHAR2,
    x_employed_by_division_name             OUT    NOCOPY VARCHAR2,
    x_employed_by_name_company              OUT    NOCOPY VARCHAR2,
    x_end_date                              OUT    NOCOPY DATE,
    x_supervisor_name                       OUT    NOCOPY VARCHAR2,
    x_branch                                OUT    NOCOPY VARCHAR2,
    x_military_rank                         OUT    NOCOPY VARCHAR2,
    x_served                                OUT    NOCOPY VARCHAR2,
    x_station                               OUT    NOCOPY VARCHAR2,
    x_responsibility                        OUT    NOCOPY VARCHAR2,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_reason_for_leaving                    OUT    NOCOPY VARCHAR2,
    x_faculty_position_flag                  OUT    NOCOPY VARCHAR2,
    x_tenure_code                           OUT    NOCOPY VARCHAR2,
    x_fraction_of_tenure                    OUT    NOCOPY NUMBER,
    x_employment_type_code                  OUT    NOCOPY VARCHAR2,
    x_employed_as_title_code                OUT    NOCOPY VARCHAR2,
    x_weekly_work_hours                     OUT    NOCOPY NUMBER,
    x_comments                              OUT    NOCOPY VARCHAR2
) IS
BEGIN

    SELECT
      NVL(employment_history_id, FND_API.G_MISS_NUM),
      NVL(begin_date, FND_API.G_MISS_DATE),
      NVL(party_id, FND_API.G_MISS_NUM),
      NVL(employed_as_title, FND_API.G_MISS_CHAR),
      NVL(employed_by_division_name, FND_API.G_MISS_CHAR),
      NVL(employed_by_name_company, FND_API.G_MISS_CHAR),
      NVL(end_date, FND_API.G_MISS_DATE),
      NVL(supervisor_name, FND_API.G_MISS_CHAR),
      NVL(branch, FND_API.G_MISS_CHAR),
      NVL(military_rank, FND_API.G_MISS_CHAR),
      NVL(served, FND_API.G_MISS_CHAR),
      NVL(station, FND_API.G_MISS_CHAR),
      NVL(responsibility, FND_API.G_MISS_CHAR),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(reason_for_leaving, FND_API.G_MISS_CHAR),
      NVL(faculty_position_flag, FND_API.G_MISS_CHAR),
      NVL(tenure_code, FND_API.G_MISS_CHAR),
      NVL(fraction_of_tenure, FND_API.G_MISS_NUM),
      NVL(employment_type_code, FND_API.G_MISS_CHAR),
      NVL(employed_as_title_code, FND_API.G_MISS_CHAR),
      NVL(weekly_work_hours, FND_API.G_MISS_NUM),
      NVL(comments, FND_API.G_MISS_CHAR)
    INTO
      x_employment_history_id,
      x_begin_date,
      x_party_id,
      x_employed_as_title,
      x_employed_by_division_name,
      x_employed_by_name_company,
      x_end_date,
      x_supervisor_name,
      x_branch,
      x_military_rank,
      x_served,
      x_station,
      x_responsibility,
      x_status,
      x_application_id,
      x_created_by_module,
      x_reason_for_leaving,
      x_faculty_position_flag,
      x_tenure_code,
      x_fraction_of_tenure,
      x_employment_type_code,
      x_employed_as_title_code,
      x_weekly_work_hours,
      x_comments
    FROM HZ_EMPLOYMENT_HISTORY
    WHERE employment_history_id = x_employment_history_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'employment_history_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(x_employment_history_id));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;


END HZ_EMPLOYMENT_HISTORY_PKG;

/
