--------------------------------------------------------
--  DDL for Package Body PA_PERCENT_COMPLETES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERCENT_COMPLETES_PKG" as
/* $Header: PAPCPKGB.pls 120.1 2005/08/05 03:38:26 lveerubh noship $*/

procedure INSERT_ROW( p_TASK_ID                 IN    NUMBER,
                      p_DATE_COMPUTED           IN    DATE,
                      p_LAST_UPDATE_DATE        IN    DATE,
                      p_LAST_UPDATED_BY         IN    NUMBER,
                      p_CREATION_DATE           IN    DATE,
                      p_CREATED_BY              IN    NUMBER,
                      p_LAST_UPDATE_LOGIN       IN    NUMBER,
                      p_COMPLETED_PERCENTAGE    IN    NUMBER,
                      p_DESCRIPTION             IN    VARCHAR2,
                      p_PROJECT_ID              IN    NUMBER,
                      p_PM_PRODUCT_CODE         IN    VARCHAR2,
                      p_CURRENT_FLAG            IN    VARCHAR2,
                      p_OBJECT_TYPE             IN    VARCHAR2,
                      p_OBJECT_ID               IN    NUMBER,
                      p_OBJECT_VERSION_ID       IN    NUMBER,
                      p_PROGRESS_STATUS_CODE    IN    VARCHAR2,
                      p_ACTUAL_START_DATE       IN    DATE,
                      p_ACTUAL_FINISH_DATE      IN    DATE,
                      p_ESTIMATED_START_DATE    IN    DATE,
                      p_ESTIMATED_FINISH_DATE   IN    DATE,
                      p_PUBLISHED_FLAG          IN    VARCHAR2,
                      p_PUBLISHED_BY_PARTY_ID   IN    NUMBER,
                      p_PROGRESS_COMMENT        IN    VARCHAR2,
                      p_HISTORY_FLAG            IN    VARCHAR2,
                      p_status_code             IN    VARCHAR2,
                      x_PERCENT_COMPLETE_ID     IN OUT  NOCOPY  NUMBER
 ,p_ATTRIBUTE_CATEGORY              IN VARCHAR2
 ,p_ATTRIBUTE1                      IN VARCHAR2
 ,p_ATTRIBUTE2                      IN VARCHAR2
 ,p_ATTRIBUTE3                      IN VARCHAR2
 ,p_ATTRIBUTE4                      IN VARCHAR2
 ,p_ATTRIBUTE5                      IN VARCHAR2
 ,p_ATTRIBUTE6                      IN VARCHAR2
 ,p_ATTRIBUTE7                      IN VARCHAR2
 ,p_ATTRIBUTE8                      IN VARCHAR2
 ,p_ATTRIBUTE9                      IN VARCHAR2
 ,p_ATTRIBUTE10                     IN VARCHAR2
 ,p_ATTRIBUTE11                     IN VARCHAR2
 ,p_ATTRIBUTE12                     IN VARCHAR2
 ,p_ATTRIBUTE13                     IN VARCHAR2
 ,p_ATTRIBUTE14                     IN VARCHAR2
 ,p_ATTRIBUTE15                     IN VARCHAR2
 ,p_structure_type		    IN VARCHAR2
) IS
l_percent_complete_id NUMBER;
BEGIN
l_percent_complete_id := x_percent_complete_id;
    IF l_PERCENT_COMPLETE_ID IS NULL
    THEN
      select PA_PERCENT_COMPLETES_S.nextval
        into l_percent_complete_id
        from dual;
    END IF;
      insert into pa_percent_completes(TASK_ID,
                      DATE_COMPUTED,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_LOGIN,
                      COMPLETED_PERCENTAGE,
                      DESCRIPTION,
                      PROJECT_ID,
                      PM_PRODUCT_CODE,
                      CURRENT_FLAG,
                      PERCENT_COMPLETE_ID,
                      object_VERSION_ID,
                      OBJECT_TYPE,
                      OBJECT_id,
                      PROGRESS_STATUS_CODE,
                      ACTUAL_START_DATE,
                      ACTUAL_FINISH_DATE,
                      ESTIMATED_START_DATE,
                      ESTIMATED_FINISH_DATE,
                      PUBLISHED_FLAG,
                      published_BY_party_ID,
                      PROGRESS_COMMENT,
                      history_flag,
                      status_code,
                      RECORD_VERSION_NUMBER
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
		   ,structure_type
) values
                      ( p_TASK_ID,
                      p_DATE_COMPUTED,
                      p_LAST_UPDATE_DATE,
                      p_LAST_UPDATED_BY,
                      p_CREATION_DATE,
                      p_CREATED_BY,
                      p_LAST_UPDATE_LOGIN,
                      p_COMPLETED_PERCENTAGE,
                      p_DESCRIPTION,
                      p_PROJECT_ID,
                      p_PM_PRODUCT_CODE,
                      p_CURRENT_FLAG,
                      l_percent_complete_id,
                      p_object_VERSION_ID,
                      p_OBJECT_TYPE,
                      p_OBJECT_ID,
                      p_PROGRESS_STATUS_CODE,
                      p_ACTUAL_START_DATE,
                      p_ACTUAL_FINISH_DATE,
                      p_ESTIMATED_START_DATE,
                      p_ESTIMATED_FINISH_DATE,
                      p_published_FLAG,
                      p_published_BY_party_ID,
                      p_PROGRESS_COMMENT,
                      p_history_flag,
                      p_status_code,
                      1
                   ,p_ATTRIBUTE_CATEGORY
                   ,p_ATTRIBUTE1
                   ,p_ATTRIBUTE2
                   ,p_ATTRIBUTE3
                   ,p_ATTRIBUTE4
                   ,p_ATTRIBUTE5
                   ,p_ATTRIBUTE6
                   ,p_ATTRIBUTE7
                   ,p_ATTRIBUTE8
                   ,p_ATTRIBUTE9
                   ,p_ATTRIBUTE10
                   ,p_ATTRIBUTE11
                   ,p_ATTRIBUTE12
                   ,p_ATTRIBUTE13
                   ,p_ATTRIBUTE14
                   ,p_ATTRIBUTE15
		   ,p_structure_type
);
x_percent_complete_id := l_percent_complete_id;
exception when others then
x_percent_complete_id := NULL;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PERCENT_COMPLETES_PKG',
                            p_procedure_name => 'INSERT_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
End;

procedure UPDATE_ROW( p_task_id                 IN    NUMBER,
                      p_DATE_COMPUTED           IN    DATE,
                      p_LAST_UPDATE_DATE        IN    DATE,
                      p_LAST_UPDATED_BY         IN    NUMBER,
                      p_LAST_UPDATE_LOGIN       IN    NUMBER,
                      p_COMPLETED_PERCENTAGE    IN    NUMBER,
                      p_DESCRIPTION             IN    VARCHAR2,
                      p_PM_PRODUCT_CODE         IN    VARCHAR2,
                      p_CURRENT_FLAG            IN    VARCHAR2,
                      p_PERCENT_COMPLETE_ID      IN    NUMBER,
                      p_project_id              IN     NUMBER,
                      p_OBJECT_TYPE             IN    VARCHAR2,
                      p_OBJECT_ID               IN    NUMBER,
                      p_OBJECT_VERSION_ID       IN    NUMBER,
                      p_PROGRESS_STATUS_CODE     IN    VARCHAR2,
                      p_ACTUAL_START_DATE        IN    DATE,
                      p_ACTUAL_FINISH_DATE       IN    DATE,
                      p_ESTIMATED_START_DATE     IN    DATE,
                      p_ESTIMATED_FINISH_DATE    IN    DATE,
                      p_PUBLISHED_FLAG           IN    VARCHAR2,
                      p_PUBLISHED_BY_PARTY_ID    IN    NUMBER,
                      p_PROGRESS_COMMENT         IN    VARCHAR2,
                      p_HISTORY_FLAG            IN    VARCHAR2,
                      p_status_code             IN    VARCHAR2,
                      p_RECORD_VERSION_NUMBER    IN    NUMBER
 ,p_ATTRIBUTE_CATEGORY              IN VARCHAR2
 ,p_ATTRIBUTE1                      IN VARCHAR2
 ,p_ATTRIBUTE2                      IN VARCHAR2
 ,p_ATTRIBUTE3                      IN VARCHAR2
 ,p_ATTRIBUTE4                      IN VARCHAR2
 ,p_ATTRIBUTE5                      IN VARCHAR2
 ,p_ATTRIBUTE6                      IN VARCHAR2
 ,p_ATTRIBUTE7                      IN VARCHAR2
 ,p_ATTRIBUTE8                      IN VARCHAR2
 ,p_ATTRIBUTE9                      IN VARCHAR2
 ,p_ATTRIBUTE10                     IN VARCHAR2
 ,p_ATTRIBUTE11                     IN VARCHAR2
 ,p_ATTRIBUTE12                     IN VARCHAR2
 ,p_ATTRIBUTE13                     IN VARCHAR2
 ,p_ATTRIBUTE14                     IN VARCHAR2
 ,p_ATTRIBUTE15                     IN VARCHAR2
 ,p_structure_type		    IN VARCHAR2
 ) IS

BEGIN
     update pa_percent_completes
     set
     OBJECT_VERSION_ID = decode(P_OBJECT_VERSION_ID,FND_API.G_MISS_NUM,OBJECT_VERSION_ID,P_OBJECT_VERSION_ID),
     OBJECT_TYPE = decode(p_OBJECT_TYPE,FND_API.G_MISS_CHAR,OBJECT_TYPE,p_OBJECT_TYPE),
     OBJECT_ID = decode(p_OBJECT_ID,FND_API.G_MISS_NUM,OBJECT_ID,p_OBJECT_ID),
     task_ID = decode(p_task_ID,FND_API.G_MISS_NUM,task_ID,p_task_ID),
     project_ID = decode(p_project_ID,FND_API.G_MISS_NUM,project_ID,p_project_ID),
     DATE_COMPUTED = decode(p_DATE_COMPUTED,FND_API.G_MISS_DATE,DATE_COMPUTED,p_DATE_COMPUTED),
     LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
     LAST_UPDATED_BY = p_LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
     COMPLETED_PERCENTAGE = decode(p_COMPLETED_PERCENTAGE,FND_API.G_MISS_NUM,COMPLETED_PERCENTAGE,p_COMPLETED_PERCENTAGE),
     DESCRIPTION = decode(p_DESCRIPTION,FND_API.G_MISS_CHAR,DESCRIPTION,p_DESCRIPTION),
     CURRENT_FLAG = decode(p_CURRENT_FLAG,FND_API.G_MISS_CHAR,CURRENT_FLAG,p_CURRENT_FLAG),
     PROGRESS_STATUS_CODE = decode(p_PROGRESS_STATUS_CODE,FND_API.G_MISS_CHAR,PROGRESS_STATUS_CODE,p_PROGRESS_STATUS_CODE),
     ACTUAL_START_DATE = decode(p_ACTUAL_START_DATE,FND_API.G_MISS_DATE,ACTUAL_START_DATE,p_ACTUAL_START_DATE),
     ACTUAL_FINISH_DATE = decode(p_ACTUAL_FINISH_DATE,FND_API.G_MISS_DATE,ACTUAL_FINISH_DATE,p_ACTUAL_FINISH_DATE),
     ESTIMATED_START_DATE = decode(p_ESTIMATED_START_DATE,FND_API.G_MISS_DATE,ESTIMATED_START_DATE,p_ESTIMATED_START_DATE),
     ESTIMATED_FINISH_DATE = decode(p_ESTIMATED_FINISH_DATE,FND_API.G_MISS_DATE,ESTIMATED_FINISH_DATE,p_ESTIMATED_FINISH_DATE),
     published_FLAG = decode(p_published_FLAG,FND_API.G_MISS_CHAR,published_FLAG,p_published_FLAG),
     PUBLISHED_BY_PARTY_ID = decode(PUBLISHED_BY_PARTY_ID,FND_API.G_MISS_NUM,PUBLISHED_BY_PARTY_ID,p_PUBLISHED_BY_PARTY_ID),
     PROGRESS_COMMENT = decode(p_PROGRESS_COMMENT,FND_API.G_MISS_CHAR,PROGRESS_COMMENT,p_PROGRESS_COMMENT),
     HISTORY_FLAG = decode(p_HISTORY_FLAG,FND_API.G_MISS_CHAR,HISTORY_FLAG,p_HISTORY_FLAG),
     status_code = decode(p_status_code,FND_API.G_MISS_CHAR,status_code,p_status_code),
     RECORD_VERSION_NUMBER = RECORD_VERSION_NUMBER + 1
           ,ATTRIBUTE_CATEGORY           = DECODE( P_ATTRIBUTE_CATEGORY, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY )
           ,ATTRIBUTE1                   = DECODE( P_ATTRIBUTE1, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE1, P_ATTRIBUTE1 )
           ,ATTRIBUTE2                   = DECODE( P_ATTRIBUTE2, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE2, P_ATTRIBUTE2 )
           ,ATTRIBUTE3                   = DECODE( P_ATTRIBUTE3, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE3, P_ATTRIBUTE3 )
           ,ATTRIBUTE4                   = DECODE( P_ATTRIBUTE4, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE4, P_ATTRIBUTE4 )
           ,ATTRIBUTE5                   = DECODE( P_ATTRIBUTE5, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE5, P_ATTRIBUTE5 )
           ,ATTRIBUTE6                   = DECODE( P_ATTRIBUTE6, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE6, P_ATTRIBUTE6 )
           ,ATTRIBUTE7                   = DECODE( P_ATTRIBUTE7, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE7, P_ATTRIBUTE7 )
           ,ATTRIBUTE8                   = DECODE( P_ATTRIBUTE8, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE8, P_ATTRIBUTE8 )
           ,ATTRIBUTE9                   = DECODE( P_ATTRIBUTE9, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE9, P_ATTRIBUTE9 )
           ,ATTRIBUTE10                  = DECODE( P_ATTRIBUTE10, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE10, P_ATTRIBUTE10 )
           ,ATTRIBUTE11                  = DECODE( P_ATTRIBUTE11, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE11, P_ATTRIBUTE11 )
           ,ATTRIBUTE12                  = DECODE( P_ATTRIBUTE12, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE12, P_ATTRIBUTE12 )
           ,ATTRIBUTE13                  = DECODE( P_ATTRIBUTE13, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE13, P_ATTRIBUTE13 )
           ,ATTRIBUTE14                  = DECODE( P_ATTRIBUTE14, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE14, P_ATTRIBUTE14 )
           ,ATTRIBUTE15                  = DECODE( P_ATTRIBUTE15, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                                   ATTRIBUTE15, P_ATTRIBUTE15 )
	   ,structure_type		 = DECODE( p_structure_type,PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
						   structure_type,p_structure_type)

     where  percent_complete_id = p_percent_complete_id
       and  record_version_number = p_record_version_number;

       if (sql%notfound) then
          fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
          fnd_msg_pub.add;
       end if;

exception when others then
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PERCENT_COMPLETES_PKG',
                            p_procedure_name => 'UPDATE_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
End UPDATE_ROW;

Procedure DELETE_ROW(
 p_row_id  VARCHAR2 ) IS
BEGIN
     DELETE FROM pa_percent_completes
      WHERE rowid = p_row_id;
END DELETE_ROW;

end;


/
