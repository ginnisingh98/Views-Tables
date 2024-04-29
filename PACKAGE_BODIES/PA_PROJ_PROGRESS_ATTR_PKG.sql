--------------------------------------------------------
--  DDL for Package Body PA_PROJ_PROGRESS_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_PROGRESS_ATTR_PKG" as
/* $Header: PAPPPKGB.pls 120.2 2005/08/23 02:04:55 avaithia noship $*/

procedure INSERT_ROW(
  X_PROJ_PROGRESS_ATTR_ID           IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,X_PROJECT_ID                      IN NUMBER
 ,X_OBJECT_TYPE                     IN VARCHAR2
 ,X_OBJECT_ID                       IN NUMBER
 ,X_LAST_UPDATE_DATE                IN DATE
 ,X_LAST_UPDATED_BY                 IN NUMBER
 ,X_CREATION_DATE                   IN DATE
 ,X_CREATED_BY                      IN NUMBER
 ,X_LAST_UPDATE_LOGIN               IN NUMBER
 ,X_PROGRESS_CYCLE_ID               IN NUMBER
 ,X_WQ_ENABLE_FLAG                  IN VARCHAR2
 ,X_REMAIN_EFFORT_ENABLE_FLAG       IN VARCHAR2
 ,X_PERCENT_COMP_ENABLE_FLAG        IN VARCHAR2
 ,X_NEXT_PROGRESS_UPDATE_DATE       IN DATE
 ,X_TASK_WEIGHT_BASIS_CODE          IN VARCHAR2
 ,X_ALLOW_COLLAB_PROG_ENTRY         IN VARCHAR2
 ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES         IN VARCHAR2
 ,X_STRUCTURE_TYPE                  IN VARCHAR2
) IS

BEGIN

      IF X_PROJ_PROGRESS_ATTR_ID IS NULL
      THEN
          select PA_PROJ_PROGRESS_ATTR_S.nextval
            into X_PROJ_PROGRESS_ATTR_ID
            from dual;
      END IF;

      insert into PA_PROJ_PROGRESS_ATTR(
                    PROJ_PROGRESS_ATTR_ID
                   ,OBJECT_TYPE
                   ,OBJECT_ID
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,CREATION_DATE
                   ,CREATED_BY
                   ,LAST_UPDATE_LOGIN
                   ,PROJECT_ID
                   ,PROGRESS_CYCLE_ID
                   ,WQ_ENABLE_FLAG
                   ,REMAIN_EFFORT_ENABLE_FLAG
                   ,PERCENT_COMP_ENABLE_FLAG
                   ,NEXT_PROGRESS_UPDATE_DATE
                   ,record_version_number
                   ,TASK_WEIGHT_BASIS_CODE
                   ,ALLOW_COLLAB_PROG_ENTRY
  		   ,ALLOW_PHY_PRCNT_CMP_OVERRIDES
                   ,STRUCTURE_TYPE
                 ) VALUES(
                    X_PROJ_PROGRESS_ATTR_ID
                   ,X_OBJECT_TYPE
                   ,X_OBJECT_ID
                   ,X_LAST_UPDATE_DATE
                   ,X_LAST_UPDATED_BY
                   ,X_CREATION_DATE
                   ,X_CREATED_BY
                   ,X_LAST_UPDATE_LOGIN
                   ,X_PROJECT_ID
                   ,X_PROGRESS_CYCLE_ID
                   ,X_WQ_ENABLE_FLAG
                   ,X_REMAIN_EFFORT_ENABLE_FLAG
                   ,X_PERCENT_COMP_ENABLE_FLAG
                   ,X_NEXT_PROGRESS_UPDATE_DATE
                   ,1
                   ,X_TASK_WEIGHT_BASIS_CODE
                   ,X_ALLOW_COLLAB_PROG_ENTRY
                   ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES
                   ,X_STRUCTURE_TYPE
                 );

exception when others then
    -- RESET OUT param in Exception block : 4537865 - Start
	X_PROJ_PROGRESS_ATTR_ID := NULL ;
    -- End : 4537865
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJ_PROGRESS_ATTR_PKG',
                            p_procedure_name => 'INSERT_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
End INSERT_ROW;

procedure UPDATE_ROW(
  X_PROJ_PROGRESS_ATTR_ID           IN NUMBER
 ,X_PROJECT_ID                      IN NUMBER
 ,X_OBJECT_TYPE                     IN VARCHAR2
 ,X_OBJECT_ID                       IN NUMBER
 ,X_LAST_UPDATE_DATE                IN DATE
 ,X_LAST_UPDATED_BY                 IN NUMBER
 ,X_LAST_UPDATE_LOGIN               IN NUMBER
 ,X_PROGRESS_CYCLE_ID               IN NUMBER
 ,X_WQ_ENABLE_FLAG                  IN VARCHAR2
 ,X_REMAIN_EFFORT_ENABLE_FLAG       IN VARCHAR2
 ,X_PERCENT_COMP_ENABLE_FLAG        IN VARCHAR2
 ,X_NEXT_PROGRESS_UPDATE_DATE       IN DATE
 ,X_RECORD_VERSION_NUMBER           IN NUMBER
 ,X_TASK_WEIGHT_BASIS_CODE          IN VARCHAR2
 ,X_ALLOW_COLLAB_PROG_ENTRY         IN VARCHAR2
 ,X_ALLW_PHY_PRCNT_CMP_OVERRIDES         IN VARCHAR2
 ,X_STRUCTURE_TYPE                  IN VARCHAR2
) IS

BEGIN
     UPDATE PA_PROJ_PROGRESS_ATTR
        SET
            OBJECT_TYPE            = DECODE( X_OBJECT_TYPE, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             OBJECT_TYPE, X_OBJECT_TYPE )
           ,OBJECT_ID              = DECODE( X_OBJECT_ID, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                             OBJECT_ID, X_OBJECT_ID )
           ,LAST_UPDATE_DATE       = X_LAST_UPDATE_DATE
           ,LAST_UPDATED_BY        = X_LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN      = X_LAST_UPDATE_LOGIN
           ,PROJECT_ID             = DECODE( X_PROJECT_ID, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                             PROJECT_ID, X_PROJECT_ID )
           ,PROGRESS_CYCLE_ID      = DECODE( X_PROGRESS_CYCLE_ID, PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                             PROGRESS_CYCLE_ID, X_PROGRESS_CYCLE_ID )
           ,WQ_ENABLE_FLAG         = DECODE( X_WQ_ENABLE_FLAG, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             WQ_ENABLE_FLAG, X_WQ_ENABLE_FLAG )
           ,REMAIN_EFFORT_ENABLE_FLAG  = DECODE( X_REMAIN_EFFORT_ENABLE_FLAG, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             REMAIN_EFFORT_ENABLE_FLAG, X_REMAIN_EFFORT_ENABLE_FLAG )
           ,PERCENT_COMP_ENABLE_FLAG   = DECODE( X_PERCENT_COMP_ENABLE_FLAG, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             PERCENT_COMP_ENABLE_FLAG, X_PERCENT_COMP_ENABLE_FLAG )
           ,NEXT_PROGRESS_UPDATE_DATE  = DECODE( X_NEXT_PROGRESS_UPDATE_DATE, PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
                                             NEXT_PROGRESS_UPDATE_DATE, X_NEXT_PROGRESS_UPDATE_DATE )
           ,record_version_number      = NVL( record_version_number, 1 ) + 1
           ,TASK_WEIGHT_BASIS_CODE = DECODE(X_TASK_WEIGHT_BASIS_CODE, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             TASK_WEIGHT_BASIS_CODE, X_TASK_WEIGHT_BASIS_CODE)
           ,ALLOW_COLLAB_PROG_ENTRY = DECODE(X_ALLOW_COLLAB_PROG_ENTRY, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             ALLOW_COLLAB_PROG_ENTRY, X_ALLOW_COLLAB_PROG_ENTRY)
           ,ALLOW_PHY_PRCNT_CMP_OVERRIDES = DECODE(X_ALLW_PHY_PRCNT_CMP_OVERRIDES, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             ALLOW_PHY_PRCNT_CMP_OVERRIDES, X_ALLW_PHY_PRCNT_CMP_OVERRIDES)
           ,STRUCTURE_TYPE = DECODE(X_STRUCTURE_TYPE, PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
                                             STRUCTURE_TYPE, X_STRUCTURE_TYPE)
       WHERE PROJ_PROGRESS_ATTR_ID =  X_PROJ_PROGRESS_ATTR_ID
       AND record_version_number =  X_RECORD_VERSION_NUMBER
;


/*       if (sql%notfound) then
          x_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
          fnd_msg_pub.add;
       end if;*/


exception when others then
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJ_PROGRESS_ATTR_PKG',
                            p_procedure_name => 'UPDATE_ROW',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    raise;
End;

Procedure DELETE_ROW(
 p_row_id  VARCHAR2 ) IS
BEGIN
     DELETE FROM PA_PROJ_PROGRESS_ATTR
      WHERE rowid = p_row_id;
END DELETE_ROW;

end PA_PROJ_PROGRESS_ATTR_PKG;


/
