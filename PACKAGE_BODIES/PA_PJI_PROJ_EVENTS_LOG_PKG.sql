--------------------------------------------------------
--  DDL for Package Body PA_PJI_PROJ_EVENTS_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PJI_PROJ_EVENTS_LOG_PKG" AS
/* $Header: PAPJITHB.pls 120.1 2005/08/19 16:40:56 mwasowic noship $ */

PROCEDURE Insert_Row(
X_ROW_ID                OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
X_EVENT_ID       	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
X_EVENT_TYPE		IN VARCHAR2,
X_EVENT_OBJECT	      	IN    VARCHAR2,
X_OPERATION_TYPE	IN    VARCHAR2,
X_STATUS        	IN	VARCHAR2,
X_ATTRIBUTE_CATEGORY	IN VARCHAR2,
X_ATTRIBUTE1	        IN VARCHAR2,
X_ATTRIBUTE2	        IN VARCHAR2,
X_ATTRIBUTE3	        IN VARCHAR2,
X_ATTRIBUTE4	        IN VARCHAR2,
X_ATTRIBUTE5	        IN VARCHAR2,
X_ATTRIBUTE6	        IN VARCHAR2,
X_ATTRIBUTE7	        IN VARCHAR2,
X_ATTRIBUTE8	        IN VARCHAR2,
X_ATTRIBUTE9	        IN VARCHAR2,
X_ATTRIBUTE10	        IN VARCHAR2,
X_ATTRIBUTE11	        IN VARCHAR2,
X_ATTRIBUTE12	        IN VARCHAR2,
X_ATTRIBUTE13	        IN VARCHAR2,
X_ATTRIBUTE14	        IN VARCHAR2,
X_ATTRIBUTE15	        IN VARCHAR2,
X_ATTRIBUTE16	        IN VARCHAR2,
X_ATTRIBUTE17	        IN VARCHAR2,
X_ATTRIBUTE18	        IN VARCHAR2,
X_ATTRIBUTE19	        IN VARCHAR2,
X_ATTRIBUTE20	        IN VARCHAR2
) IS
    CURSOR cur_PJI_PROJ_EVENTS_seq
        IS
          SELECT pa_pji_proj_events_log_s.nextval
            FROM sys.dual;

BEGIN
    -- If product PJI installed, insert
    IF (PA_INSTALL.is_pji_licensed()='Y') THEN

	OPEN cur_PJI_PROJ_EVENTS_seq;
	FETCH cur_PJI_PROJ_EVENTS_seq INTO X_EVENT_ID;
     	CLOSE cur_PJI_PROJ_EVENTS_seq;

     	INSERT INTO pa_pji_proj_events_log(
   		  EVENT_TYPE
  		 ,EVENT_ID
  		 ,EVENT_OBJECT
  		 ,OPERATION_TYPE
		 ,STATUS
                 ,CREATION_DATE
                 ,CREATED_BY
                 ,LAST_UPDATE_DATE
                 ,LAST_UPDATED_BY
                 ,LAST_UPDATE_LOGIN
                 ,ATTRIBUTE_CATEGORY
                 ,ATTRIBUTE1
                 ,ATTRIBUTE2
                 ,ATTRIBUTE3
                 ,ATTRIBUTE4
                 ,ATTRIBUTE5
                 ,ATTRIBUTE6
                 ,ATTRIBUTE7
                 ,ATTRIBUTE8
                 ,ATTRIBUTE9
                 ,ATTRIBUTE10
                 ,ATTRIBUTE11
                 ,ATTRIBUTE12
                 ,ATTRIBUTE13
                 ,ATTRIBUTE14
                 ,ATTRIBUTE15
                 ,ATTRIBUTE16
                 ,ATTRIBUTE17
                 ,ATTRIBUTE18
                 ,ATTRIBUTE19
                 ,ATTRIBUTE20	)
        VALUES(
		  X_EVENT_TYPE
		 ,X_EVENT_ID
		 ,X_EVENT_OBJECT
		 ,X_OPERATION_TYPE
		 ,nvl(X_STATUS,'X')
                 ,SYSDATE                      --X_CREATION_DATE
                 ,FND_GLOBAL.USER_ID           --CREATED_BY
                 ,SYSDATE                      --LAST_UPDATE_DATE
                 ,FND_GLOBAL.USER_ID           --LAST_UPDATED_BY
                 ,FND_GLOBAL.LOGIN_ID
                 ,X_ATTRIBUTE_CATEGORY
                 ,X_ATTRIBUTE1
                 ,X_ATTRIBUTE2
                 ,X_ATTRIBUTE3
                 ,X_ATTRIBUTE4
                 ,X_ATTRIBUTE5
                 ,X_ATTRIBUTE6
                 ,X_ATTRIBUTE7
                 ,X_ATTRIBUTE8
                 ,X_ATTRIBUTE9
                 ,X_ATTRIBUTE10
                 ,X_ATTRIBUTE11
                 ,X_ATTRIBUTE12
                 ,X_ATTRIBUTE13
                 ,X_ATTRIBUTE14
                 ,X_ATTRIBUTE15
                 ,X_ATTRIBUTE16
                 ,X_ATTRIBUTE17
                 ,X_ATTRIBUTE18
                 ,X_ATTRIBUTE19
                 ,X_ATTRIBUTE20	);
    END IF;
END Insert_Row;


END PA_PJI_PROJ_EVENTS_LOG_PKG;

/
