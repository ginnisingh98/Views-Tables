--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ELEMENTS_PKG" AS
/* $Header: PATSKT1B.pls 120.1.12010000.2 2009/07/21 14:32:33 anuragar ship $ */

PROCEDURE Insert_Row(
X_ROW_ID                IN OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
X_PROJ_ELEMENT_ID       IN OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
X_PROJECT_ID	      IN    NUMBER,
X_OBJECT_TYPE	      IN    VARCHAR2,
X_ELEMENT_NUMBER        IN	VARCHAR2,
X_NAME                  IN	VARCHAR2,
X_DESCRIPTION	      IN    VARCHAR2,
X_STATUS_CODE	      IN    VARCHAR2,
X_WF_STATUS_CODE        IN	VARCHAR2,
X_PM_PRODUCT_CODE       IN	VARCHAR2,
X_PM_TASK_REFERENCE     IN	VARCHAR2,
X_CLOSED_DATE	      IN    DATE,
X_LOCATION_ID	      IN    NUMBER,
X_MANAGER_PERSON_ID	IN    NUMBER,
X_CARRYING_OUT_ORGANIZATION_ID            IN NUMBER,
X_TYPE_ID  	            IN    NUMBER,
X_PRIORITY_CODE 	      IN    VARCHAR2,
X_INC_PROJ_PROGRESS_FLAG  IN	VARCHAR2,
X_REQUEST_ID	        IN  NUMBER,
X_PROGRAM_APPLICATION_ID  IN  NUMBER,
X_PROGRAM_ID	        IN  NUMBER,
X_PROGRAM_UPDATE_DATE	  IN  DATE,
X_LINK_TASK_FLAG          IN  VARCHAR2,
X_ATTRIBUTE_CATEGORY	  IN VARCHAR2,
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
 x_task_weighting_deriv_code  IN VARCHAR2,
 x_work_item_code             IN VARCHAR2,
 x_uom_code                   IN VARCHAR2,
 x_wq_actual_entry_code       IN VARCHAR2,
 x_task_progress_entry_page_id IN NUMBER,
 x_parent_structure_id         IN NUMBER,
 x_phase_code                  IN VARCHAR,
 x_phase_version_id            IN NUMBER,
 x_progress_weight             IN NUMBER :=NULL,             -- 3279978 :: Added x_progress_weight Parameter
 x_function_code               IN VARCHAR2 := NULL,           -- 3279978 :: Added x_function_code Parameter
 x_Base_Perc_Comp_Deriv_Code     IN      VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Added for FP_M changes 3305199
-- Bug#3491609 : Workflow Chanegs FP M
x_wf_item_type          IN VARCHAR2 :=NULL,
x_wf_process            IN VARCHAR2 :=NULL,
x_wf_lead_days          IN NUMBER :=NULL,
x_wf_enabled_flag       IN VARCHAR2 :=NULL,
 -- Bug#3491609 : Workflow Chanegs FP M
x_source_object_id      IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,     --Bug No 3594635 SMukka
x_source_object_type    IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   --Bug No 3594635 SMukka
,x_task_status_code      IN VARCHAR2 := NULL --Changes for 8566495 anuragag
) IS
    CURSOR cur_tasks_seq
        IS
          SELECT pa_tasks_s.nextval
            FROM sys.dual;

BEGIN
     IF X_PROJ_ELEMENT_ID IS NULL
     THEN
        OPEN cur_tasks_seq;
        FETCH cur_tasks_seq INTO X_PROJ_ELEMENT_ID;
        CLOSE cur_tasks_seq;
     END IF;
     INSERT INTO pa_proj_elements(
                  PROJ_ELEMENT_ID
                 ,PROJECT_ID
                 ,OBJECT_TYPE
                 ,ELEMENT_NUMBER
                 ,NAME
                 ,DESCRIPTION
                 ,STATUS_CODE
                 ,WF_STATUS_CODE
                 ,PM_SOURCE_CODE
                 ,PM_SOURCE_REFERENCE
                 ,CLOSED_DATE
                 ,LOCATION_ID
                 ,MANAGER_PERSON_ID
                 ,CARRYING_OUT_ORGANIZATION_ID
                 ,TYPE_ID
                 ,PRIORITY_CODE
                 ,INC_PROJ_PROGRESS_FLAG
                 ,CREATION_DATE
                 ,CREATED_BY
                 ,LAST_UPDATE_DATE
                 ,LAST_UPDATED_BY
                 ,LAST_UPDATE_LOGIN
                 ,RECORD_VERSION_NUMBER
                 ,REQUEST_ID
                 ,PROGRAM_APPLICATION_ID
                 ,PROGRAM_ID
                 ,PROGRAM_UPDATE_DATE
                 ,LINK_TASK_FLAG
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
--                 ,task_weighting_deriv_code
                 ,wq_item_code
                 ,wq_uom_code
                 ,wq_actual_entry_code
                 ,task_progress_entry_page_id
                 ,parent_structure_id
                 ,phase_code
                 ,phase_version_id
                 ,progress_weight                   -- 3279978 :: Added x_progress_weight Parameter
                 -- ,prog_rollup_method                -- 3279978 :: Added x_prog_rollup_method Parameter
                 ,function_code                     -- 3279978 :: Added x_function_code Parameter
		       ,Base_Percent_Comp_Deriv_Code
                 ,wf_item_type
                 ,wf_process
                 ,wf_start_lead_days
                 ,enable_wf_flag
                 ,source_object_id                  --Bug No 3594635 SMukka
                 ,source_object_type                --Bug No 3594635 SMukka
				 ,task_status --Changes for 8566495 anuragag
              )
        VALUES(
                  X_PROJ_ELEMENT_ID
                 ,X_PROJECT_ID
                 ,X_OBJECT_TYPE
                 ,X_ELEMENT_NUMBER
                 ,X_NAME
                 ,X_DESCRIPTION
                 ,X_STATUS_CODE
                 ,X_WF_STATUS_CODE
                 ,X_PM_PRODUCT_CODE
                 ,X_PM_TASK_REFERENCE
                 ,X_CLOSED_DATE
                 ,X_LOCATION_ID
                 ,X_MANAGER_PERSON_ID
                 ,X_CARRYING_OUT_ORGANIZATION_ID
                 ,X_TYPE_ID
                 ,X_PRIORITY_CODE
                 ,X_INC_PROJ_PROGRESS_FLAG
                 ,SYSDATE                      --X_CREATION_DATE
                 ,FND_GLOBAL.USER_ID           --CREATED_BY
                 ,SYSDATE                      --LAST_UPDATE_DATE
                 ,FND_GLOBAL.USER_ID           --LAST_UPDATED_BY
                 ,FND_GLOBAL.LOGIN_ID
                 ,1                            --RECORD_VERSION_NUMBER
                 ,X_REQUEST_ID
                 ,X_PROGRAM_APPLICATION_ID
                 ,X_PROGRAM_ID
                 ,X_PROGRAM_UPDATE_DATE
                 ,X_LINK_TASK_FLAG
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
--                 ,x_task_weighting_deriv_code
                 ,x_work_item_code
                 ,x_uom_code
                 ,x_wq_actual_entry_code
                 ,x_task_progress_entry_page_id
                 ,x_parent_structure_id
                 ,x_phase_code
                 ,x_phase_version_id
                 ,x_progress_weight                   -- 3279978 :: Added x_progress_weight Parameter
                 -- ,x_prog_rollup_method                -- 3279978 :: Added x_prog_rollup_method Parameter
                 ,x_function_code                     -- 3279978 :: Added x_function_code Parameter
      		  ,x_Base_Perc_Comp_Deriv_Code	-- 3305199 : Added for FP_M changes
                 ,x_wf_item_type
                 ,x_wf_process
                 ,x_wf_lead_days
                 ,x_wf_enabled_flag
                 ,x_source_object_id               --Bug No 3594635 SMukka
                 ,x_source_object_type             --Bug No 3594635 SMukka
				 ,x_task_status_code --Changes for 8566495 anuragag
);

END Insert_Row;

PROCEDURE Update_Row(
X_ROW_ID                IN   VARCHAR2,
X_PROJ_ELEMENT_ID       IN	NUMBER,
X_PROJECT_ID	      IN    NUMBER,
X_OBJECT_TYPE	      IN    VARCHAR2,
X_ELEMENT_NUMBER        IN	VARCHAR2,
X_NAME                  IN	VARCHAR2,
X_DESCRIPTION	      IN    VARCHAR2,
X_STATUS_CODE	      IN    VARCHAR2,
X_WF_STATUS_CODE        IN	VARCHAR2,
X_PM_PRODUCT_CODE       IN	VARCHAR2,
X_PM_TASK_REFERENCE     IN	VARCHAR2,
X_CLOSED_DATE	      IN    DATE,
X_LOCATION_ID	      IN    NUMBER,
X_MANAGER_PERSON_ID	IN    NUMBER,
X_CARRYING_OUT_ORGANIZATION_ID            IN NUMBER,
X_TYPE_ID  	            IN    NUMBER,
X_PRIORITY_CODE 	      IN    VARCHAR2,
X_INC_PROJ_PROGRESS_FLAG  IN	VARCHAR2,
X_RECORD_VERSION_NUMBER	  IN  NUMBER,
X_REQUEST_ID	        IN  NUMBER,
X_PROGRAM_APPLICATION_ID  IN  NUMBER,
X_PROGRAM_ID	        IN  NUMBER,
X_PROGRAM_UPDATE_DATE	  IN  DATE,
X_ATTRIBUTE_CATEGORY	  IN VARCHAR2,
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
X_TASK_WEIGHTING_DERIV_CODE  IN VARCHAR2,
X_WORK_ITEM_CODE             IN VARCHAR2,
X_UOM_CODE                   IN VARCHAR2,
X_WQ_ACTUAL_ENTRY_CODE       IN VARCHAR2,
X_TASK_PROGRESS_ENTRY_PAGE_ID IN NUMBER,
x_parent_structure_id         IN NUMBER,
x_phase_code                  IN VARCHAR,
x_phase_version_id            IN NUMBER,
x_progress_weight             IN NUMBER :=NULL,             -- 3279978 :: Added x_progress_weight Parameter
x_function_code               IN VARCHAR2 := NULL,           -- 3279978 :: Added x_function_code Parameter
x_Base_Perc_Comp_Deriv_Code     IN  VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR, -- Added for FP_M changes 3305199
-- Bug#3491609 : Workflow Chanegs FP M
x_wf_item_type          IN VARCHAR2 :=NULL,
x_wf_process            IN VARCHAR2 :=NULL,
x_wf_lead_days          IN NUMBER :=NULL,
x_wf_enabled_flag       IN VARCHAR2 :=NULL
 -- Bug#3491609 : Workflow Chanegs FP M
) IS
   CURSOR cur_proj_elems
   IS
     SELECT *
       FROM pa_proj_elements
      WHERE proj_element_id = X_PROJ_ELEMENT_ID;
  v_cur_proj_elems_rec cur_proj_elems%ROWTYPE;

BEGIN
   /*OPEN cur_proj_elems;
   FETCH cur_proj_elems INTO v_cur_proj_elems_rec;
   CLOSE cur_proj_elems;

    if v_cur_proj_elems_rec.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;  moved to private API */

     UPDATE pa_proj_elements
        SET PROJ_ELEMENT_ID                  = X_PROJ_ELEMENT_ID
           ,PROJECT_ID	                     = X_PROJECT_ID
           ,OBJECT_TYPE		               = X_OBJECT_TYPE
           ,ELEMENT_NUMBER		         = X_ELEMENT_NUMBER
           ,NAME	         	               = X_NAME
           ,DESCRIPTION		               = X_DESCRIPTION
           ,STATUS_CODE	   	               = X_STATUS_CODE
           ,WF_STATUS_CODE		         = X_WF_STATUS_CODE
           ,PM_SOURCE_CODE	 	         = X_PM_PRODUCT_CODE
           ,PM_SOURCE_REFERENCE	         = X_PM_TASK_REFERENCE
           ,CLOSED_DATE		               = X_CLOSED_DATE
           ,LOCATION_ID		               = X_LOCATION_ID
           ,MANAGER_PERSON_ID	 	         = X_MANAGER_PERSON_ID
           ,CARRYING_OUT_ORGANIZATION_ID 	   = X_CARRYING_OUT_ORGANIZATION_ID
           ,TYPE_ID  	 	               = X_TYPE_ID
           ,PRIORITY_CODE 			   = X_PRIORITY_CODE
           ,INC_PROJ_PROGRESS_FLAG 	         = X_INC_PROJ_PROGRESS_FLAG
           ,LAST_UPDATE_DATE		         = SYSDATE
           ,LAST_UPDATED_BY	 	    = FND_GLOBAL.USER_ID
           ,LAST_UPDATE_LOGIN		    = FND_GLOBAL.LOGIN_ID
           ,RECORD_VERSION_NUMBER       = NVL( RECORD_VERSION_NUMBER, 0 ) + 1
           ,REQUEST_ID		          = X_REQUEST_ID
           ,PROGRAM_APPLICATION_ID      = X_PROGRAM_APPLICATION_ID
           ,PROGRAM_ID		          = X_PROGRAM_ID
           ,PROGRAM_UPDATE_DATE         = X_PROGRAM_UPDATE_DATE
           ,ATTRIBUTE_CATEGORY	    = X_ATTRIBUTE_CATEGORY
           ,ATTRIBUTE1		          = X_ATTRIBUTE1
           ,ATTRIBUTE2		          = X_ATTRIBUTE2
           ,ATTRIBUTE3		          = X_ATTRIBUTE3
           ,ATTRIBUTE4		          = X_ATTRIBUTE4
           ,ATTRIBUTE5		          = X_ATTRIBUTE5
           ,ATTRIBUTE6		          = X_ATTRIBUTE6
           ,ATTRIBUTE7		          = X_ATTRIBUTE7
           ,ATTRIBUTE8		          = X_ATTRIBUTE8
           ,ATTRIBUTE9		          = X_ATTRIBUTE9
           ,ATTRIBUTE10		          = X_ATTRIBUTE10
           ,ATTRIBUTE11		          = X_ATTRIBUTE11
           ,ATTRIBUTE12		          = X_ATTRIBUTE12
           ,ATTRIBUTE13		          = X_ATTRIBUTE13
           ,ATTRIBUTE14		          = X_ATTRIBUTE14
           ,ATTRIBUTE15		          = X_ATTRIBUTE15
 --        ,TASK_WEIGHTING_DERIV_CODE = X_TASK_WEIGHTING_DERIV_CODE
           ,wq_item_code            = x_work_item_code
           ,wq_uom_code             = x_uom_code
           ,wq_actual_entry_code    = x_wq_actual_entry_code
           ,task_progress_entry_page_id = x_task_progress_entry_page_id
           ,parent_structure_id         = x_parent_structure_id
           ,phase_code                  = x_phase_code
           ,phase_version_id            = x_phase_version_id
           ,progress_weight             = x_progress_weight             -- 3279978 :: Added x_progress_weight Parameter
           -- ,prog_rollup_method          = x_prog_rollup_method          -- 3279978 :: Added x_prog_rollup_method Parameter
           ,function_code               = x_function_code               -- 3279978 :: Added x_function_code Parameter
	      ,Base_Percent_Comp_Deriv_Code = x_Base_Perc_Comp_Deriv_Code	-- 3305199 : Added for FP_M changes
           ,wf_item_type        = x_wf_item_type
           ,wf_process          = x_wf_process
           ,wf_start_lead_days  = x_wf_lead_days
           ,enable_wf_flag     = x_wf_enabled_flag
       WHERE rowid = x_row_id;
END Update_Row;

PROCEDURE Delete_Row(
X_ROW_ID                   IN VARCHAR2
) IS
BEGIN
    DELETE FROM pa_proj_elements
      WHERE rowid = x_row_id;
END delete_row;

END PA_PROJ_ELEMENTS_PKG;

/
