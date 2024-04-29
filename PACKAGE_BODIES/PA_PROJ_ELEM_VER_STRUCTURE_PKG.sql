--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ELEM_VER_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ELEM_VER_STRUCTURE_PKG" as
/*$Header: PAXSVATB.pls 120.2 2005/08/25 23:24:29 avaithia noship $*/

-- API name                      : insert_row
-- Type                          : Table Handlers
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure insert_row
  (
     X_ROWID                                    IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , X_PEV_STRUCTURE_ID                         IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   , X_ELEMENT_VERSION_ID                       NUMBER
   , X_VERSION_NUMBER                           NUMBER
   , X_NAME                                     VARCHAR2
   , X_PROJECT_ID                               NUMBER
   , X_PROJ_ELEMENT_ID                          NUMBER
   , X_DESCRIPTION                              VARCHAR2
   , X_EFFECTIVE_DATE                           DATE
   , X_PUBLISHED_DATE                           DATE
   , X_PUBLISHED_BY                             NUMBER
   , X_CURRENT_BASELINE_DATE                    DATE
   , X_CURRENT_BASELINE_FLAG                    VARCHAR2
   , X_CURRENT_BASELINE_BY                      NUMBER
   , X_ORIGINAL_BASELINE_DATE                   DATE
   , X_ORIGINAL_BASELINE_FLAG                   VARCHAR2
   , X_ORIGINAL_BASELINE_BY                     NUMBER
   , X_LOCK_STATUS_CODE                         VARCHAR2
   , X_LOCKED_BY                                NUMBER
   , X_LOCKED_DATE                              DATE
   , X_STATUS_CODE                              VARCHAR2
   , X_WF_STATUS_CODE                           VARCHAR2
   , X_LATEST_EFF_PUBLISHED_FLAG                VARCHAR2
   , X_CHANGE_REASON_CODE                       VARCHAR2
   , X_RECORD_VERSION_NUMBER                    NUMBER
   , X_CURRENT_WORKING_FLAG                     VARCHAR2  := 'N'  --FPM changes bug 3301192
   , x_source_object_id      IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM        --Bug No 3594635 SMukka
   , x_source_object_type    IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     --Bug No 3594635 SMukka
  )
  IS
     cursor c is select rowid from PA_PROJ_ELEM_VER_STRUCTURE
                  where pev_structure_id = X_PEV_STRUCTURE_ID;
     cursor c2 is select pa_proj_elem_ver_structure_s.nextval from sys.dual;

	-- 4537865 : Start
  l_incoming_rowid NUMBER ;
  l_incoming_pev_structure_id NUMBER ;
	-- 4537865 : End

  BEGIN
	-- 4537865 : Start
     l_incoming_rowid := X_ROWID ;
     l_incoming_pev_structure_id := X_PEV_STRUCTURE_ID ;
	-- 4537865 : End

     if (X_PEV_STRUCTURE_ID IS NULL) then
       open c2;
       fetch c2 into X_PEV_STRUCTURE_ID;
       close c2;
     end if;

     INSERT INTO PA_PROJ_ELEM_VER_STRUCTURE(
         PEV_STRUCTURE_ID
        ,ELEMENT_VERSION_ID
        ,VERSION_NUMBER
        ,NAME
        ,PROJECT_ID
        ,PROJ_ELEMENT_ID
        ,DESCRIPTION
        ,EFFECTIVE_DATE
        ,PUBLISHED_DATE
        ,PUBLISHED_BY_PERSON_ID
        ,CURRENT_BASELINE_DATE
        ,CURRENT_FLAG
        ,CURRENT_BASELINE_PERSON_ID
        ,ORIGINAL_BASELINE_DATE
        ,ORIGINAL_FLAG
        ,ORIGINAL_BASELINE_PERSON_ID
        ,LOCK_STATUS_CODE
        ,LOCKED_BY_PERSON_ID
        ,LOCKED_DATE
        ,STATUS_CODE
        ,WF_STATUS_CODE
        ,LATEST_EFF_PUBLISHED_FLAG
        ,RECORD_VERSION_NUMBER
        ,WBS_RECORD_VERSION_NUMBER
        ,CHANGE_REASON_CODE
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,process_update_wbs_flag
        ,CURRENT_WORKING_FLAG
        ,source_object_id               --Bug No 3594635 SMukka
        ,source_object_type             --Bug No 3594635 SMukka
       ) VALUES (
         X_PEV_STRUCTURE_ID
        ,X_ELEMENT_VERSION_ID
        ,X_VERSION_NUMBER
        ,X_NAME
        ,X_PROJECT_ID
        ,X_PROJ_ELEMENT_ID
        ,X_DESCRIPTION
        ,X_EFFECTIVE_DATE
        ,X_PUBLISHED_DATE
        ,X_PUBLISHED_BY
        ,X_CURRENT_BASELINE_DATE
        ,X_CURRENT_BASELINE_FLAG
        ,X_CURRENT_BASELINE_BY
        ,X_ORIGINAL_BASELINE_DATE
        ,X_ORIGINAL_BASELINE_FLAG
        ,X_ORIGINAL_BASELINE_BY
        ,X_LOCK_STATUS_CODE
        ,X_LOCKED_BY
        ,X_LOCKED_DATE
        ,X_STATUS_CODE
        ,X_WF_STATUS_CODE
        ,X_LATEST_EFF_PUBLISHED_FLAG
        ,X_RECORD_VERSION_NUMBER
        ,1
        ,X_CHANGE_REASON_CODE
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,sysdate
        ,FND_GLOBAL.USER_ID
        ,FND_GLOBAL.LOGIN_ID
        ,'N'
        ,X_CURRENT_WORKING_FLAG
        ,x_source_object_id             --Bug No 3594635 SMukka
        ,x_source_object_type           --Bug No 3594635 SMukka
       );

    OPEN c;
    FETCH c into X_ROWID;
    if (C%NOTFOUND) then
      CLOSE c;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE c;
	-- 4537865 : Included Exception block
  EXCEPTION
	WHEN OTHERS THEN

		-- Restore the IN OUT params to original values
		X_ROWID := l_incoming_rowid ;
		x_pev_structure_id := l_incoming_pev_structure_id ;

		-- Add the xception message to stack and RAISE
		fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJ_ELEM_VER_STRUCTURE_PKG',
                              p_procedure_name => 'Insert_Row',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
		RAISE ;
  END;



-- API name                      : update_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure update_row
  (
     X_ROWID                                    VARCHAR2
   , X_PEV_STRUCTURE_ID                         NUMBER
   , X_ELEMENT_VERSION_ID                       NUMBER
   , X_VERSION_NUMBER                           NUMBER
   , X_NAME                                     VARCHAR2
   , X_PROJECT_ID                               NUMBER
   , X_PROJ_ELEMENT_ID                          NUMBER
   , X_DESCRIPTION                              VARCHAR2
   , X_EFFECTIVE_DATE                           DATE
   , X_PUBLISHED_DATE                           DATE
   , X_PUBLISHED_BY                             NUMBER
   , X_CURRENT_BASELINE_DATE                    DATE
   , X_CURRENT_BASELINE_FLAG                    VARCHAR2
   , X_CURRENT_BASELINE_BY                      NUMBER
   , X_ORIGINAL_BASELINE_DATE                   DATE
   , X_ORIGINAL_BASELINE_FLAG                   VARCHAR2
   , X_ORIGINAL_BASELINE_BY                     NUMBER
   , X_LOCK_STATUS_CODE                         VARCHAR2
   , X_LOCKED_BY                                NUMBER
   , X_LOCKED_DATE                              DATE
   , X_STATUS_CODE                              VARCHAR2
   , X_WF_STATUS_CODE                           VARCHAR2
   , X_LATEST_EFF_PUBLISHED_FLAG                VARCHAR2
   , X_CHANGE_REASON_CODE                       VARCHAR2
   , X_RECORD_VERSION_NUMBER                    NUMBER
   , X_CURRENT_WORKING_FLAG                     VARCHAR2  := 'N'  --FPM changes bug 3301192
  )
  IS
  BEGIN
    UPDATE PA_PROJ_ELEM_VER_STRUCTURE
    SET
     PEV_STRUCTURE_ID          = X_PEV_STRUCTURE_ID
   , ELEMENT_VERSION_ID        = X_ELEMENT_VERSION_ID
   , VERSION_NUMBER            = X_VERSION_NUMBER
   , NAME                      = X_NAME
   , PROJECT_ID                = X_PROJECT_ID
   , PROJ_ELEMENT_ID           = X_PROJ_ELEMENT_ID
   , DESCRIPTION               = X_DESCRIPTION
   , EFFECTIVE_DATE            = X_EFFECTIVE_DATE
   , PUBLISHED_DATE            = X_PUBLISHED_DATE
   , PUBLISHED_BY_PERSON_ID    = X_PUBLISHED_BY
   , CURRENT_BASELINE_DATE     = X_CURRENT_BASELINE_DATE
   , CURRENT_FLAG     = X_CURRENT_BASELINE_FLAG
   , CURRENT_BASELINE_PERSON_ID= X_CURRENT_BASELINE_BY
   , ORIGINAL_BASELINE_DATE    = X_ORIGINAL_BASELINE_DATE
   , ORIGINAL_FLAG    = X_ORIGINAL_BASELINE_FLAG
   , ORIGINAL_BASELINE_PERSON_ID = X_ORIGINAL_BASELINE_BY
   , LOCK_STATUS_CODE          = X_LOCK_STATUS_CODE
   , LOCKED_BY_PERSON_ID       = X_LOCKED_BY
   , LOCKED_DATE               = X_LOCKED_DATE
   , STATUS_CODE               = X_STATUS_CODE
   , WF_STATUS_CODE            = X_WF_STATUS_CODE
   , LATEST_EFF_PUBLISHED_FLAG = X_LATEST_EFF_PUBLISHED_FLAG
   , RECORD_VERSION_NUMBER     = NVL(X_RECORD_VERSION_NUMBER,0) + 1
   , WBS_RECORD_VERSION_NUMBER = WBS_RECORD_VERSION_NUMBER + 1
   , LAST_UPDATE_DATE          = sysdate
   , LAST_UPDATED_BY           = FND_GLOBAL.USER_ID
   , LAST_UPDATE_LOGIN         = FND_GLOBAL.LOGIN_ID
   , CHANGE_REASON_CODE        = X_CHANGE_REASON_CODE
   , CURRENT_WORKING_FLAG      = X_CURRENT_WORKING_FLAG  --FPM changes bug 3301192
    WHERE rowid = X_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END;



-- API name                      : delete_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure delete_row
  (
    X_ROWID                                    VARCHAR2
  )
  IS
  BEGIN

    DELETE FROM PA_PROJ_ELEM_VER_STRUCTURE
    WHERE ROWID = X_ROWID;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END;



end PA_PROJ_ELEM_VER_STRUCTURE_PKG;

/
