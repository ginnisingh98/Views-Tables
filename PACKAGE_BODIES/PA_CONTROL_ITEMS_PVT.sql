--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_PVT" AS
--$Header: PACICIVB.pls 120.4.12010000.4 2009/07/23 22:56:39 cklee ship $


procedure ADD_CONTROL_ITEM(
 	 p_api_version          IN     NUMBER   := 1.0
 	,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
 	,p_commit               IN     VARCHAR2 := FND_API.g_false
 	,p_validate_only        IN     VARCHAR2 := FND_API.g_true
 	,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2
        ,p_owner_id             IN  NUMBER
        ,p_highlighted_flag     IN  VARCHAR2 := 'N'
        ,p_progress_status_code IN  VARCHAR2 := NULL
        ,p_progress_as_of_date  IN  DATE     := NULL
        ,p_classification_code  IN  NUMBER
        ,p_reason_code          IN  NUMBER
        ,p_project_id           IN  NUMBER
        ,p_last_modified_by_id  IN  NUMBER
     := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id) -- 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_ci_number            IN  VARCHAR2   := NULL
        ,p_date_required        IN  DATE       := NULL
        ,p_date_closed          IN DATE   := NULL
        ,p_closed_by_id         IN NUMBER := NULL
        ,p_description          IN  VARCHAR2   := NULL
        ,p_status_overview      IN  VARCHAR2   := NULL
        ,p_resolution           IN  VARCHAR2   := NULL
        ,p_resolution_code      IN  NUMBER     := NULL
        ,p_priority_code        IN  VARCHAR2   := NULL
        ,p_effort_level_code    IN  VARCHAR2   := NULL
        ,p_open_action_num      IN NUMBER := NULL
        ,p_price                IN  NUMBER     := NULL
        ,p_price_currency_code  IN  VARCHAR2   := NULL
        ,p_source_type_code     IN  VARCHAR2   := NULL
        ,p_source_comment       IN  VARCHAR2   := NULL
        ,p_source_number        IN  VARCHAR2   := NULL
        ,p_source_date_received IN  DATE       := NULL
        ,p_source_organization  IN  VARCHAR2  := NULL
        ,p_source_person        IN  VARCHAR2  := NULL
        ,p_attribute_category    IN  VARCHAR2 := NULL
        ,p_attribute1            IN  VARCHAR2  := NULL
        ,p_attribute2            IN  VARCHAR2  := NULL
        ,p_attribute3            IN  VARCHAR2 := NULL
        ,p_attribute4            IN  VARCHAR2 := NULL
        ,p_attribute5            IN  VARCHAR2 := NULL
        ,p_attribute6            IN  VARCHAR2 := NULL
        ,p_attribute7            IN  VARCHAR2 := NULL
        ,p_attribute8            IN  VARCHAR2 := NULL
        ,p_attribute9            IN  VARCHAR2 := NULL
        ,p_attribute10           IN  VARCHAR2 := NULL
        ,p_attribute11           IN  VARCHAR2 := NULL
        ,p_attribute12           IN  VARCHAR2 := NULL
        ,p_attribute13           IN  VARCHAR2 := NULL
        ,p_attribute14           IN  VARCHAR2 := NULL
        ,p_attribute15           IN  VARCHAR2 := NULL

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE         IN  VARCHAR2 := NULL
        ,p_APPROVAL_TYPE_CODE      IN  VARCHAR2 := NULL
        ,p_LOCKED_FLAG             IN  VARCHAR2 := 'N'
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number        IN number    := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
  	,px_ci_id               IN  OUT NOCOPY NUMBER
        ,x_ci_number             OUT NOCOPY VARCHAR2
  	,x_return_status         OUT NOCOPY VARCHAR2
  	,x_msg_count             OUT NOCOPY NUMBER
 	,x_msg_data              OUT NOCOPY VARCHAR2
) is

  l_ci_number_num NUMBER(15) 	:= NULL;
--  l_ci_number_char VARCHAR2(30) := NULL;
  l_ci_number_char PA_CONTROL_ITEMS.ci_number%type  := NULL;
  l_ci_number number;

  l_system_number_id NUMBER(15) := NULL;
  cursor c_system_stat is
        Select project_system_status_code
        From PA_PROJECT_STATUSES
        Where project_status_code = p_status_code;
  cp_stat_code c_system_stat%ROWTYPE;

  cursor c_item_type is
  	Select ci_type_class_code, auto_number_flag,
               start_date_active,end_date_active
        From   PA_CI_TYPES_B
        Where  ci_type_id = p_ci_type_id;

  cp_type  c_item_type%ROWTYPE;
  l_type_class_code PA_CI_TYPES_B.CI_TYPE_CLASS_CODE%TYPE;
  l_system_status_code pa_project_statuses.project_system_status_code%TYPE;
  DRAFT_STATUS pa_project_statuses.project_system_status_code%TYPE := 'CI_DRAFT';

  API_ERROR                           EXCEPTION;
  l_auto_number           VARCHAR2(1);
  l_type_start_date       DATE;
  l_type_end_date         DATE;
  l_rowid                 ROWID;

  -- Bug 3297238. FP M changes.
  l_item_key              pa_wf_processes.item_key%TYPE;
  l_debug_mode                    VARCHAR2(1);
   l_debug_level6                   CONSTANT NUMBER := 6;
   g_module_name      VARCHAR2(100) := 'pa.plsql.CreateCI,Add_Control_Item';

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Add_Control_Item');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT add_control_item;
  END IF;


  IF (p_price_currency_code is not null) THEN
      begin
        select ROWID
        into l_rowid
        from fnd_currencies_tl
        where currency_code   = p_price_currency_code
        AND   language        = USERENV('LANG');
        exception when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CURRENCY_CODE_INV');
           x_return_status := 'E';
       end;
  END IF;

  IF has_null_data(
         p_ci_type_id
        ,p_project_id
        ,p_status_code
        ,p_owner_id
     --   ,l_ci_number_char
        ,p_summary)     THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     PA_DEBUG.Reset_Err_Stack;
     RETURN;
  END IF;


  -- verify type is valid, get numbering options and code
  open c_item_type;
        fetch c_item_type into cp_type;
        if (c_item_type%notfound) then
                close c_item_type;
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_CI_INVALID_TYPE_ID');
                x_return_status := FND_API.G_RET_STS_ERROR;
                --PA_DEBUG.RESET_ERR_STACK;
               -- return;
        end if;
        l_type_class_code   	:= cp_type.ci_type_class_code;
        l_auto_number   	:= cp_type.auto_number_flag;
        l_type_start_date       := cp_type.start_date_active;
        l_type_end_date         := cp_type.end_date_active;

        close c_item_type;

    open c_system_stat;
        fetch c_system_stat into cp_stat_code;
        if (c_system_stat%notfound) then
                close c_system_stat;
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_CI_INVALID_STATUS_CODE');
                x_return_status := FND_API.G_RET_STS_ERROR;
               -- PA_DEBUG.RESET_ERR_STACK;
               -- return;
        end if;
   l_system_status_code := cp_stat_code.project_system_status_code;
   close c_system_stat;

  IF (x_return_status <> 'S') THEN
     PA_DEBUG.RESET_ERR_STACK;
     return;
  END IF;


  IF l_auto_number = 'Y' and l_system_status_code <> DRAFT_STATUS THEN
    LOOP
	PA_SYSTEM_NUMBERS_PKG.GET_NEXT_NUMBER (
        	p_object1_pk1_value     => p_project_id
        	,p_object1_type         => 'PA_PROJECTS'
        	,p_object2_pk1_value    => p_ci_type_id
        	,p_object2_type         => l_type_class_code
        	,x_system_number_id     => l_system_number_id
        	,x_next_number          => l_ci_number_num
        	,x_return_status        => x_return_status
        	,x_msg_count            => x_msg_count
        	,x_msg_data             => x_msg_data);

  	IF  x_return_status <> FND_API.g_ret_sts_success THEN
     		PA_DEBUG.Reset_Err_Stack;
     		 raise API_ERROR;
  	END IF;
        l_ci_number_char := TO_CHAR(l_ci_number_num);

	-- call Client Extension here
        PA_CI_NUMBER_CLIENT_EXTN.GET_NEXT_NUMBER (
             p_object1_pk1_value    => p_project_id
            ,p_object1_type         => 'PA_PROJECTS'
            ,p_object2_pk1_value    => p_ci_type_id
            ,p_object2_type         => l_type_class_code
            ,p_next_number          => l_ci_number_char
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data);

        EXIT WHEN ci_number_exists(p_project_id, l_ci_number_char
                                  ,p_ci_type_id) = FALSE;
    END LOOP;
  ELSE
        l_ci_number_char := p_ci_number;

        if ci_number_exists(p_project_id, l_ci_number_char  ,p_ci_type_id) = TRUE then
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_CI_DUPLICATE_CI_NUMBER');
                x_return_status := FND_API.G_RET_STS_ERROR;
                PA_DEBUG.RESET_ERR_STACK;
                return;

        end if;
  END IF;


 IF l_ci_number_char is NULL and l_system_status_code <> DRAFT_STATUS THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name      => 'PA_CI_NO_CI_NUMBER');
     x_return_status := FND_API.G_RET_STS_ERROR;
     PA_DEBUG.Reset_Err_Stack;
     RETURN;

  END IF;

  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
	  IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'About to call the table handler';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level6);
	  END IF;


  --Validate all PA_LOOKUPS values

  IF (x_return_status <> 'E') THEN
      PA_CONTROL_ITEMS_PKG.INSERT_ROW (
         p_ci_type_id
        ,p_summary
        ,p_status_code
        ,p_owner_id
        ,p_highlighted_flag
        ,NVL(p_progress_status_code, 'PROGRESS_STAT_ON_TRACK')
        ,NVL(p_progress_as_of_date,sysdate)
        ,p_classification_code
        ,p_reason_code
        ,p_project_id
       -- ,sysdate
        ,p_last_modified_by_id
        ,p_object_type
        ,p_object_id
        ,l_ci_number_char
        ,p_date_required
        ,p_date_closed
        ,p_closed_by_id
        ,p_description
        ,p_status_overview
        ,p_resolution
        ,p_resolution_code
        ,p_priority_code
        ,p_effort_level_code
        ,nvl(p_open_action_num,0)
        ,p_price
        ,p_price_currency_code
        ,p_source_type_code
        ,p_source_comment
        ,p_source_number
        ,p_source_date_received
        ,p_source_organization
        ,p_source_person

        ,p_attribute_category

        ,p_attribute1
        ,p_attribute2
        ,p_attribute3
        ,p_attribute4
        ,p_attribute5
        ,p_attribute6
        ,p_attribute7
        ,p_attribute8
        ,p_attribute9
        ,p_attribute10
        ,p_attribute11
        ,p_attribute12
        ,p_attribute13
        ,p_attribute14
        ,p_attribute15

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE
        ,p_APPROVAL_TYPE_CODE
        ,p_LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number
        ,p_Current_Version_flag
        ,p_Version_Comments
        ,p_Original_ci_id
        ,p_Source_ci_id
        ,px_ci_id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        );
   END IF;

   l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
	  IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'Table handler called';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level6);
	  END IF;

   -- Launch the workflow notification if it is not validate only mode and no errors occured till now.
   -- Bug 3297238. FP M changes.
   IF ( p_validate_only = FND_API.G_FALSE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
          pa_control_items_workflow.START_NOTIFICATION_WF
                  (  p_item_type		=> 'PAWFCISC'
                    ,p_process_name	=> 'PA_CI_OWNER_CHANGE_FYI'
                    ,p_ci_id		     => px_ci_id
                    ,p_action_id		=> NULL
                    ,x_item_key		=> l_item_key
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data );

          IF  x_return_status <> FND_API.g_ret_sts_success THEN
                    PA_DEBUG.Reset_Err_Stack;
                    raise API_ERROR;
          END IF;
   END IF;

     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;


 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
  WHEN API_ERROR THEN
   x_return_status := x_return_status;

    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO add_control_item;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.add_control_item'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end ADD_CONTROL_ITEM;

procedure UPDATE_CONTROL_ITEM (
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num

        ,p_ci_id                IN  NUMBER
        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2 := NULL
        ,p_owner_id             IN  NUMBER
        ,p_highlighted_flag     IN  VARCHAR2  := 'N'
        ,p_progress_status_code IN  VARCHAR2
        ,p_progress_as_of_date  IN  DATE      := NULL
        ,p_classification_code  IN  NUMBER
        ,p_reason_code          IN  NUMBER
        ,p_record_version_number IN  NUMBER
        ,p_project_id           IN  NUMBER
        ,p_last_modified_by_id  IN  NUMBER
     := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id) -- 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_ci_number            IN  VARCHAR2   := NULL
        ,p_date_required        IN  DATE       := NULL
        ,p_date_closed          IN  DATE       := NULL
        ,p_closed_by_id         IN  NUMBER     := NULL

        ,p_description          IN  VARCHAR2   := NULL
        ,p_status_overview      IN  VARCHAR2   := NULL
        ,p_resolution           IN  VARCHAR2   := NULL
        ,p_resolution_code      IN  NUMBER     := NULL
        ,p_priority_code        IN  VARCHAR2   := NULL
        ,p_effort_level_code    IN  VARCHAR2   := NULL
        ,p_open_action_num      IN  NUMBER    := NULL
        ,p_price                IN  NUMBER         := NULL
        ,p_price_currency_code  IN  VARCHAR2   := NULL
        ,p_source_type_code     IN  VARCHAR2   := NULL
        ,p_source_comment       IN  VARCHAR2   := NULL
        ,p_source_number        IN  VARCHAR2   := NULL
        ,p_source_date_received IN  DATE           := NULL
        ,p_source_organization  IN  VARCHAR2  := NULL
        ,p_source_person        IN  VARCHAR2       := NULL

        ,p_attribute_category    IN  VARCHAR2 := NULL

        ,p_attribute1            IN  VARCHAR2 := NULL
        ,p_attribute2            IN  VARCHAR2 := NULL
        ,p_attribute3            IN  VARCHAR2 := NULL
        ,p_attribute4            IN  VARCHAR2 := NULL
        ,p_attribute5            IN  VARCHAR2 := NULL
        ,p_attribute6            IN  VARCHAR2 := NULL
        ,p_attribute7            IN  VARCHAR2 := NULL
        ,p_attribute8            IN  VARCHAR2 := NULL
        ,p_attribute9            IN  VARCHAR2 := NULL
        ,p_attribute10           IN  VARCHAR2 := NULL
        ,p_attribute11           IN  VARCHAR2 := NULL
        ,p_attribute12           IN  VARCHAR2 := NULL
        ,p_attribute13           IN  VARCHAR2 := NULL
        ,p_attribute14           IN  VARCHAR2 := NULL
        ,p_attribute15           IN  VARCHAR2 := NULL

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE         IN  VARCHAR2 := NULL
        ,p_APPROVAL_TYPE_CODE      IN  VARCHAR2 := NULL
        ,p_LOCKED_FLAG             IN  VARCHAR2 := 'N'
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number        IN number := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
		,p_change_approver       IN varchar2 := NULL
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
) is
     CURSOR curr_row is
     SELECT *
       FROM  pa_control_items
      WHERE  ci_id = p_ci_id;

     cp    curr_row%rowtype;
     l_ROWID ROWID;

     cursor C is select ROWID from PA_CONTROL_ITEMS
     where    project_id = p_project_id
          and ci_number  = p_ci_number
          and ci_id      <> p_ci_id
          and ci_type_id = p_ci_type_id;

     l_as_of_date DATE := sysdate;
     l_status_code pa_control_items.status_code%TYPE;
     l_new_status_code pa_control_items.status_code%TYPE;   /* Bug#5676037: Code changes for AMG APIs */
     l_ci_system_status pa_project_statuses.project_system_status_code%TYPE := NULL ;
     l_auto_numbers   VARCHAR2(1) := 'N';
     l_ci_number     pa_control_items.ci_number%TYPE := NULL;

     --bug 3297238
     l_item_key              pa_wf_processes.item_key%TYPE;
     l_prev_owner_id         pa_control_items.owner_id%TYPE;

  cursor c_auto_num is
        Select type.auto_number_flag
        From   PA_CI_TYPES_B     type
               ,pa_control_items ci
        Where  ci.ci_id = p_ci_id
           AND ci.ci_type_id = type.ci_type_id;

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
    l_locked_flag VARCHAR2(1) := p_LOCKED_FLAG;
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676


begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Update_Control_Item');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT update_control_item;
  END IF;

  OPEN curr_row;
  FETCH curr_row INTO cp;
  if curr_row%NOTFOUND then
       close curr_row;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
       PA_DEBUG.Reset_Err_Stack;
  end if;

/*Commenting  for 4065728
  IF cp.progress_status_code is NULL
      OR cp.progress_status_code <> p_progress_status_code THEN
	  l_as_of_date := sysdate;
  ELSE
     IF cp.progress_as_of_date is NOT NULL THEN
         l_as_of_date := cp.progress_as_of_date;
     END IF;
  END IF;
*/

/*Added for Bug 4065728 */

  IF p_progress_as_of_date is NOT NULL THEN
	 l_as_of_date := p_progress_as_of_date;
  END IF;

/* End for Bug 4065728 */

  --bug 3297238.
  l_prev_owner_id := cp.owner_id;

  --separate API to update status
  l_status_code := cp.status_code;
  l_new_status_code := p_status_code; --Bug 5676037
  l_ci_number   := cp.ci_number;
  close curr_row;

   IF (p_price_currency_code is not null) THEN
      begin
        select ROWID
        into l_ROWID
        from fnd_currencies_tl
        where currency_code   = p_price_currency_code
        AND   language        = USERENV('LANG');
        exception when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CURRENCY_CODE_INV');
           x_return_status := 'E';
       end;
  END IF;

  OPEN c_auto_num;
   FETCH c_auto_num INTO l_auto_numbers;
  if c_auto_num%NOTFOUND then
     PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INVALID_TYPE_ID');
         x_return_status := 'E';
    close c_auto_num;
    PA_DEBUG.Reset_Err_Stack;
    return;
  end if ;
  close c_auto_num;


-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
  IF nvl(cp.LOCKED_FLAG, 'N') = 'Y' AND p_LOCKED_FLAG <> 'X' THEN
      PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_CONTROL_ITEM_IS_LOCKED'
        ,p_token1          => 'TOKEN'
	   ,p_value1          => cp.ci_number);

         x_return_status := 'E';
      PA_DEBUG.Reset_Err_Stack;
      return;
  END IF;

  IF p_LOCKED_FLAG = 'X' THEN
    l_locked_flag := 'N';
  END IF;
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676


  if l_auto_numbers  is NOT NULL and l_auto_numbers <> 'Y' then
      if p_ci_number is NOT NULL then
        l_ci_number := p_ci_number;
        open C;
        fetch C into l_ROWID;
        if (C%notfound) then
         close C;
        else
         close C;
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_DUPLICATE_CI_NUMBER');
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_DEBUG.Reset_Err_Stack;
         return;
        end if;
     else
      -- ci number may not be NULL in non CI_DRAFT status
      l_ci_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_status_code);
      if l_ci_system_status is NULL then
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_STATUS');
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_DEBUG.Reset_Err_Stack;
         return;
      end if;
      if 'CI_DRAFT' <> l_ci_system_status then
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_CI_NUMBER');
         x_return_status := FND_API.G_RET_STS_ERROR;
         PA_DEBUG.Reset_Err_Stack;
         return;
      end if;
    end if;
  end if; --if manual numbers


  IF (x_return_status <> 'E') THEN
      PA_CONTROL_ITEMS_PKG.UPDATE_ROW(
         p_ci_id
        ,p_ci_type_id
        ,p_summary
        ,l_new_status_code
        ,p_owner_id
        ,p_highlighted_flag
        ,p_progress_status_code
        ,l_as_of_date --p_progress_as_of_date
        ,p_classification_code
        ,p_reason_code
        ,p_record_version_number
        ,p_project_id
        ,p_last_modified_by_id
        ,p_object_type
        ,p_object_id
        ,l_ci_number --p_ci_number
        ,p_date_required
        ,p_date_closed
        ,p_closed_by_id
        ,p_description
        ,p_status_overview
        ,p_resolution
        ,p_resolution_code
        ,p_priority_code
        ,p_effort_level_code
        ,p_open_action_num
        ,p_price
        ,p_price_currency_code
        ,p_source_type_code
        ,p_source_comment
        ,p_source_number
        ,p_source_date_received
        ,p_source_organization
        ,p_source_person

        ,p_attribute_category

        ,p_attribute1
        ,p_attribute2
        ,p_attribute3
        ,p_attribute4
        ,p_attribute5
        ,p_attribute6
        ,p_attribute7
        ,p_attribute8
        ,p_attribute9
        ,p_attribute10
        ,p_attribute11
        ,p_attribute12
        ,p_attribute13
        ,p_attribute14
        ,p_attribute15

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE
        ,p_APPROVAL_TYPE_CODE
        ,l_locked_flag -- p_LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number
        ,p_Current_Version_flag
        ,p_Version_Comments
        ,p_Original_ci_id
        ,p_Source_ci_id
        ,p_change_approver
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
       );
   END IF;

   -- Launch the workflow notification if it is not validate only mode and no errors occured till now and
   -- the owner is getting changed.
   -- Bug 3297238. FP M Changes.
   IF ( p_validate_only = FND_API.G_FALSE AND
        x_return_status = FND_API.g_ret_sts_success AND
        l_prev_owner_id <> p_owner_id )THEN  -- owner id cannot be null as it is validated in public API.

          pa_control_items_workflow.START_NOTIFICATION_WF
                  (  p_item_type		=> 'PAWFCISC'
                    ,p_process_name	=> 'PA_CI_OWNER_CHANGE_FYI'
                    ,p_ci_id		     => p_ci_id
                    ,p_action_id		=> NULL
                    ,x_item_key		=> l_item_key
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data );

   END IF;

     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;


 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO update_control_item;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.update_control_item'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_CONTROL_ITEM;



procedure DELETE_CONTROL_ITEM (
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num

  	,p_ci_id                IN     NUMBER
        ,p_record_version_number   IN  NUMBER
  	,x_return_status        OUT    NOCOPY VARCHAR2
  	,x_msg_count            OUT    NOCOPY NUMBER
  	,x_msg_data             OUT    NOCOPY VARCHAR2

) is
   l_status_code          pa_project_statuses.project_system_status_code%type;
   cursor valid_ci is
     select pps.project_system_status_code --status_code
       from pa_control_items ci
            ,pa_project_statuses pps
      where ci.ci_id = p_ci_id
        and ci.status_code = pps.project_status_code;
begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Delete_Control_Item');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT delete_control_item;
  END IF;

  IF p_ci_id is NULL THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
      open valid_ci;
      fetch valid_ci into l_status_code;
      if (valid_ci%notfound) then
         --- invalid ci_id error
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
          x_return_status := FND_API.G_RET_STS_ERROR;
      else
         if (l_status_code <> 'CI_DRAFT') then
         --- invalid status error
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_ONLY_DRAFT_DEL');
           x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      end if;
      close valid_ci;
   END IF;
   IF  x_return_status = FND_API.g_ret_sts_success THEN
       --- delete all actions
       pa_ci_actions_pvt.delete_all_actions(p_validate_only => 'F',
                                        p_init_msg_list => 'F',
                                        p_ci_id         => p_ci_id,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);
       --- delete all impacts
       pa_ci_impacts_util.delete_All_impacts(p_validate_only  => 'F',
                                        p_init_msg_list => 'F',
                                        p_ci_id         => p_ci_id,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);

       ---  change status for any included 'CR' to 'APPROVED'
       ---  call procedure change_included_cr_status
       change_included_cr_status(p_ci_id         => p_ci_id
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data);

       ---  delete all related items
       delete_all_related_items (p_validate_only => 'F',
                                 p_init_msg_list => 'F',
                                 p_ci_id         => p_ci_id,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data);

       ---  delete all included crs
       delete_all_included_crs (p_validate_only => 'F',
                                p_init_msg_list => 'F',
                                p_ci_id         => p_ci_id,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data);

       ---  delete doc attachments
       pa_ci_doc_attach_pkg.delete_all_attachments (p_validate_only => 'F',
                                        p_init_msg_list => 'F',
                                        p_ci_id         => p_ci_id,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data);

       --- delete control_item
       PA_CONTROL_ITEMS_PKG.DELETE_ROW(
         p_ci_id
        ,p_record_version_number
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
       );
   END IF;
     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO delete_control_item;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.delete_control_item'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_CONTROL_ITEM;

procedure DELETE_ALL_CONTROL_ITEMS(
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num

        ,p_project_id           IN     NUMBER
        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2

) is
   l_msg_index_out        NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Delete_ALL_Control_Items');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT delete_all_control_items;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  FOR ci_rec IN( SELECT ci_id, record_version_number
                FROM pa_control_items
                WHERE project_id = p_project_id  ) LOOP
        DELETE_CONTROL_ITEM(
        p_api_version
        ,'F'
        ,'F'
        ,'F'
        ,p_max_msg_count

        ,ci_rec.ci_id
        ,ci_rec.record_version_number
        ,x_return_status
        ,x_msg_count
        ,x_msg_data );

        EXIT WHEN x_return_status <> FND_API.g_ret_sts_success;
  END LOOP;

  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;
   -- Commit if the flag is set and there is no error
 IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
 END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO delete_all_control_items;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.delete_all_control_items'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_ALL_CONTROL_ITEMS;

procedure COPY_CONTROL_ITEM (
         p_api_version          IN     NUMBER :=  1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER := FND_API.g_miss_num

        ,p_project_id           IN  NUMBER
        ,p_ci_id_from           IN  NUMBER   -- copy from this
        ,p_ci_type_id           IN  NUMBER   -- copy to this
        ,p_classification_code_id IN  NUMBER
        ,p_reason_code_id         IN  NUMBER

        ,p_include              IN  VARCHAR2 := 'N'
        ,p_record_version_number_from  IN     NUMBER
        ,x_ci_id                       OUT NOCOPY NUMBER
        ,x_ci_number                   OUT NOCOPY VARCHAR2
        ,x_return_status               OUT NOCOPY VARCHAR2
        ,x_msg_count                   OUT NOCOPY NUMBER
        ,x_msg_data                    OUT NOCOPY VARCHAR2

) is

   l_reason      NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   l_class_code  NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   p_reason      NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   p_class_code  NUMBER := NULL; -- mwxx VARCHAR2(30):= NULL;
   l_msg_index_out        NUMBER;
   l_from_type_id         NUMBER;
   l_relationship_id      NUMBER;
   l_commit          VARCHAR2(1) := 'N';
   copy_from_row          pa_control_items%ROWTYPE;

   CURSOR c_from_item
	is
	   SELECT * FROM pa_control_items
	   WHERE ci_id = p_ci_id_from;

/* mwxx
   CURSOR c_from_classification
        is
           SELECT 'Y'
             FROM pa_ci_types_b pctb, pa_class_codes pcc
            WHERE pctb.ci_type_id = p_ci_type_id
              AND pctb.classification_category = pcc.class_category
              AND pcc.class_code = p_class_code;
*/


  CURSOR c_from_classification
        is
           SELECT class_code_id
             FROM pa_class_codes pcc,pa_ci_types_b pctb
            WHERE pctb.ci_type_id = p_ci_type_id
              AND pctb.classification_category = pcc.class_category
              AND pcc.class_code in (select pcc1.class_code
                                            from pa_class_codes pcc1
                                            where pcc1.class_code_id = p_class_code);

  CURSOR c_from_reason
        is
           SELECT class_code_id
             FROM pa_class_codes pcc,pa_ci_types_b pctb
            WHERE pctb.ci_type_id = p_ci_type_id
              AND pctb.reason_category = pcc.class_category
              AND pcc.class_code in (select pcc1.class_code
                                            from pa_class_codes pcc1
                                            where pcc1.class_code_id = p_reason);
/* mwxx

   CURSOR c_from_reason
        is
           SELECT 'Y'
             FROM pa_ci_types_b pctb, pa_class_codes pcc
            WHERE pctb.ci_type_id = p_ci_type_id
              AND pctb.reason_category = pcc.class_category
              AND pcc.class_code = p_reason;
*/

   copy_class             c_from_classification%ROWTYPE;
   copy_reason            c_from_reason%ROWTYPE;
   l_ci_id number := null;
begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.COPY_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN c_from_item;
  FETCH c_from_item INTO copy_from_row;
  if c_from_item%NOTFOUND then
       close c_from_item;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_FROM_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

  ---- check that impacts of source ci_id_from should be less than or equalto the
  ---- impacts of the destination ci_type_id. (i.e. new ci)
  if (x_return_status = 'S' and p_include = 'Y') then
      if (pa_control_items_utils.IsImpactOkToInclude(p_ci_type_id, null, p_ci_id_from) <> 'Y') then
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_IMP_INCLUDE');
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
  end if;

  if p_validate_only=fnd_api.g_false AND
     x_return_status =  FND_API.G_RET_STS_SUCCESS then

     --- only copy clasification and reason if the source classification and reason
     --- code is in classificationa and reason category of the destination ci
      l_from_type_id := copy_from_row.ci_type_id;
      p_reason       := copy_from_row.reason_code_id;
      p_class_code   := copy_from_row.classification_code_id;

      if p_ci_type_id = copy_from_row.ci_type_id then
         l_reason     :=  copy_from_row.reason_code_id;
         l_class_code := copy_from_row.classification_code_id;
      else
         open c_from_classification;
         fetch c_from_classification into copy_class;
         if c_from_classification%notfound then
            l_class_code := p_classification_code_id;
         else
            l_class_code := copy_class.class_code_id; --p_class_code;
         end if;
         close c_from_classification;

         open c_from_reason;
         fetch c_from_reason into copy_reason;
         if c_from_reason%notfound then
            l_reason := p_reason_code_id;
         else
            l_reason := copy_class.class_code_id; --p_reason;
         end if;
         close c_from_reason;

      end if;

      PA_CONTROL_ITEMS_PVT.ADD_CONTROL_ITEM(
         p_api_version                => p_api_version
        ,p_init_msg_list              => p_init_msg_list
        ,p_commit                     => FND_API.g_false
        ,p_validate_only              => p_validate_only
        ,p_max_msg_count              => p_max_msg_count

        ,p_ci_type_id                 => p_ci_type_id
        ,p_summary                    => copy_from_row.summary

--        ,p_status_code                => pa_control_items_utils.get_initial_ci_status(p_ci_type_id)

-- set the initial status to Draft. When numbers are assigned manually, there is no way
-- to enter the number when an item is copied. The Number (ci_number) is a required field
-- when a control item is is any status other than "Draft".
        ,p_status_code                => 'CI_DRAFT' --because of manual numbering

        ,p_owner_id                   => copy_from_row.owner_id
        ,p_highlighted_flag           => copy_from_row.highlighted_flag
        ,p_progress_status_code       => NULL
        ,p_progress_as_of_date        => SYSDATE
        ,p_classification_code        => l_class_code
        ,p_reason_code                => l_reason
        ,p_project_id                 => p_project_id
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
--        ,p_last_modified_by_id        => PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id )
         ,p_last_modified_by_id        => NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id)
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_object_type                => copy_from_row.object_type
        ,p_object_id                  => copy_from_row.object_id
        ,p_ci_number                  => NULL
        ,p_date_required              => to_date(NULL)
        ,p_date_closed                => copy_from_row.date_closed
        ,p_closed_by_id               => copy_from_row.closed_by_id
        ,p_description                => copy_from_row.description
        ,p_status_overview            => NULL --copy_from_row.status_overview
        ,p_resolution                 => NULL --p_resolution
        ,p_resolution_code            => NULL --p_resolution_code
        ,p_priority_code              => copy_from_row.priority_code
        ,p_effort_level_code          => copy_from_row.effort_level_code
        ,p_open_action_num            => 0

        ,p_price                      => copy_from_row.price
        ,p_price_currency_code        => copy_from_row.price_currency_code
        ,p_source_type_code           => copy_from_row.source_type_code
        ,p_source_comment             => copy_from_row.source_comment
        ,p_source_number              => copy_from_row.source_number
        ,p_source_date_received       => copy_from_row.source_date_received
        ,p_source_organization        => copy_from_row.source_organization
        ,p_source_person              => copy_from_row.source_person

        ,p_attribute_category           => copy_from_row.attribute_category
        ,p_attribute1                   => copy_from_row.attribute1
        ,p_attribute2                   => copy_from_row.attribute2
        ,p_attribute3                   => copy_from_row.attribute3
        ,p_attribute4                   => copy_from_row.attribute4
        ,p_attribute5                   => copy_from_row.attribute5
        ,p_attribute6                   => copy_from_row.attribute6
        ,p_attribute7                   => copy_from_row.attribute7
        ,p_attribute8                   => copy_from_row.attribute8
        ,p_attribute9                   => copy_from_row.attribute9
        ,p_attribute10                  => copy_from_row.attribute10
        ,p_attribute11                  => copy_from_row.attribute11
        ,p_attribute12                  => copy_from_row.attribute12
        ,p_attribute13                  => copy_from_row.attribute13
        ,p_attribute14                  => copy_from_row.attribute14
        ,p_attribute15                  => copy_from_row.attribute15

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE              => copy_from_row.PCO_STATUS_CODE
        ,p_APPROVAL_TYPE_CODE           => copy_from_row.APPROVAL_TYPE_CODE
        ,p_LOCKED_FLAG                  => 'N'--copy_from_row.LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number               => 1
        ,p_Current_Version_flag         => 'Y'
        ,p_Version_Comments             => copy_from_row.Version_Comments
        ,p_Original_ci_id               => null
        ,p_Source_ci_id                 => p_ci_id_from
        ,px_ci_id                      => l_ci_id
        ,x_ci_number                  => x_ci_number
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data);

      x_ci_id := l_ci_id;
      close c_from_item;

      ------- copy impacts
      if (x_return_status = FND_API.g_ret_sts_success and p_include = 'N') then
           pa_ci_impacts_util.copy_impact(p_validate_only   => 'F',
                                     p_init_msg_list   => 'F',
                                     P_DEST_CI_ID      => x_ci_id,
                                     P_SOURCE_CI_ID    => p_ci_id_from,
                                     P_INCLUDE_FLAG    => 'N',
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data);
      end if;

      if x_return_status = FND_API.g_ret_sts_success and p_include = 'Y' THEN
        PA_CONTROL_ITEMS_PVT.INCLUDE_CONTROL_ITEM(
         p_api_version                => p_api_version
        ,p_init_msg_list              => p_init_msg_list
        ,p_commit                     => 'F'
        ,p_validate_only              => p_validate_only
        ,p_max_msg_count              => p_max_msg_count
        ,p_from_ci_id                 => x_ci_id
        ,p_to_ci_id                   => p_ci_id_from
        ,p_record_version_number_to   => p_record_version_number_from
        ,x_relationship_id            => l_relationship_id
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data);
      end if;

      --Copying document attachments
      IF x_return_status = 'S' THEN
        pa_ci_doc_attach_pkg.copy_attachments(
          p_init_msg_list => 'F',
          p_validate_only => 'F',
          p_from_ci_id    => p_ci_id_from,
          p_to_ci_id      => x_ci_id,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);
      END IF;

      --Copying related items
      IF x_return_status = 'S' THEN
        copy_related_items(
          p_init_msg_list => 'F',
          p_validate_only => 'F',
          p_from_ci_id    => p_ci_id_from,
          p_to_ci_id      => x_ci_id,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data);
      END IF;


  end if;

  -- IF the number of messages is 1 then fetch the message code from the stack
  -- and return its text
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  end if;

  if (p_commit = 'T' and x_return_status = 'S') then
      commit;
  end if;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.COPY_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end COPY_CONTROL_ITEM;

procedure INCLUDE_CONTROL_ITEM(
         p_api_version          IN     NUMBER :=  1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER := FND_API.g_miss_num

        ,p_from_ci_id             IN     NUMBER
        ,p_to_ci_id               IN     NUMBER
        ,p_record_version_number_to    IN     NUMBER
        ,x_relationship_id             OUT    NOCOPY NUMBER
        ,x_return_status               OUT    NOCOPY VARCHAR2
        ,x_msg_count                   OUT    NOCOPY NUMBER
        ,x_msg_data                    OUT    NOCOPY VARCHAR2
)

IS
    l_relationship_type VARCHAR2(30) := 'CI_INCLUDED_ITEM'; --- relationship type for included items
    l_rowid             ROWID;
    l_ci_id             NUMBER;
    l_project_id        NUMBER;
    l_status_code       VARCHAR2(30);
    l_ci_type_id_to     NUMBER;
    l_ci_type_id_from   NUMBER;
    l_record_version_number NUMBER;
    l_open_actions_num  NUMBER;

     CURSOR check_params is
     SELECT  pci.ci_type_id, pctb.ci_type_class_code,
             pci.project_id, pps.project_system_status_code
       FROM  pa_control_items pci, pa_ci_types_b pctb, pa_project_statuses pps
      WHERE  pci.ci_id = l_ci_id
        and  pci.ci_type_id = pctb.ci_type_id
        and  pci.status_code = pps.project_status_code(+);

     cp    check_params%rowtype;
begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Include_Control_Item');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT include_control_item;
  END IF;

  -------Included in
  l_ci_id := p_from_ci_id;
  OPEN check_params;
  FETCH check_params INTO cp;
  if check_params%NOTFOUND then
    PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INVALID_ITEM');
  else
    l_project_id := cp.project_id;
    if (cp.ci_type_class_code <> 'CHANGE_ORDER') then
       PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INCL_CR_IN_CO');
    end if;
    l_ci_type_id_to := cp.ci_type_id;
  end if ;
  close check_params;

  ------- To be included
  l_ci_id := p_to_ci_id;
  OPEN check_params;
  FETCH check_params INTO cp;
  if check_params%NOTFOUND then
    PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_NO_INCLUDE_ITEM');
  else
    if (l_project_id <> cp.project_id) then
       PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INC_DIFF_PROJ');
       x_return_status := 'E';
    end if;

    if (cp.project_system_status_code <> 'CI_APPROVED') then
       PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INC_STAT_INV');
       x_return_status := 'E';
    end if;

    if (cp.ci_type_class_code <> 'CHANGE_REQUEST') then
       PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INCL_CR_IN_CO');
    end if;
    l_ci_type_id_from := cp.ci_type_id;
  end if ;
  close check_params;

  if (x_return_status = 'S') then
    ----- include impacts
      pa_ci_impacts_util.copy_impact(p_validate_only   => 'F',
                                     p_init_msg_list   => 'F',
                                     P_DEST_CI_ID      => p_from_ci_id,
                                     P_SOURCE_CI_ID    => p_to_ci_id,
                                     P_INCLUDE_FLAG    => 'Y',
                                     x_return_status   => x_return_status,
                                     x_msg_count       => x_msg_count,
                                     x_msg_data        => x_msg_data);


  end if;

  if (x_return_status = 'S') then
     PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
                      	p_user_id => fnd_global.user_id,
                        p_object_type_from => 'PA_CONTROL_ITEMS',
                        p_object_id_from1 => to_char(p_from_ci_id),
			p_object_id_from2 => NULL,
			p_object_id_from3 => NULL,
			p_object_id_from4 => NULL,
			p_object_id_from5 => NULL,
			p_object_type_to => 'PA_CONTROL_ITEMS',
                        p_object_id_to1 => to_char(p_to_ci_id),
			p_object_id_to2 => NULL,
			p_object_id_to3 => NULL,
			p_object_id_to4 => NULL,
			p_object_id_to5 => NULL,
                        p_relationship_type => l_relationship_type,
                        p_relationship_subtype => NULL,
			p_lag_day => NULL,
			p_imported_lag => NULL,
			p_priority => NULL,
			p_pm_product_code => NULL,
                        x_object_relationship_id => x_relationship_id,
                        x_return_status => x_return_status);
  end if;


  if (x_return_status = 'S') then
  ---------  change the status of CR from 'APPROVED' to 'CLOSED'
     SELECT record_version_number
     INTO   l_record_version_number
     FROM   PA_CONTROL_ITEMS
     WHERE  ci_id = p_to_ci_id;

     PA_CONTROL_ITEMS_UTILS.ChangeCIStatus (
        		  p_init_msg_list         => FND_API.G_TRUE
			 ,p_validate_only         => FND_API.G_FALSE
			 ,p_ci_id                 => p_to_ci_id
			 ,p_status                => 'CI_CLOSED'
			 ,p_record_version_number => l_record_version_number
			 ,x_num_of_actions        => l_open_actions_num
			 ,x_return_status         => x_return_status
			 ,x_msg_count             => x_msg_count
			 ,x_msg_data              => x_msg_data);

  end if;


  -- add code to copy the supplier information
  -- bug 2622062
  IF x_return_status = 'S' THEN
     PA_CI_SUPPLIER_UTILS.Merge_suppliers
       ( p_from_ci_item_id       => p_to_ci_id
	 ,p_to_ci_item_id         => p_from_ci_id
	 ,x_return_status          => x_return_status
	 ,x_error_msg         =>  x_msg_data
	 );

  END IF;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO include_control_item;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.include_control_item'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end INCLUDE_CONTROL_ITEM;

procedure UPDATE_NUMBER_OF_ACTIONS (
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num

        ,p_ci_id                    IN NUMBER
        ,p_num_of_actions           IN NUMBER
        ,p_record_version_number    IN NUMBER

        ,x_num_of_actions       OUT  NOCOPY NUMBER
        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
        ,p_last_updated_by 	 in NUMBER default fnd_global.user_id  --Added the parameter for bug# 3877985
        ,p_last_update_date 	 in DATE default sysdate               --Added the parameter for bug# 3877985
        ,p_last_update_login     in NUMBER default fnd_global.user_id  --Added the parameter for bug# 3877985
)IS
   l_nof_actions NUMBER(15) := 0;

   cp         pa_control_items%ROWTYPE;

   CURSOR curr_number
        is
           SELECT * FROM pa_control_items
           WHERE ci_id = p_ci_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_NUMBER_OF_ACTIONS;
  END IF;

  x_return_status := 'S';
  OPEN curr_number;
  FETCH curr_number INTO cp;
  if curr_number%NOTFOUND then
    PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INVALID_ITEM');
         x_return_status := 'E';
  else
    l_nof_actions := cp.open_action_num;
  end if ;
  close curr_number;

  if (x_return_status = 'S') then
         if l_nof_actions is NULL  or l_nof_actions < 0 then
             l_nof_actions := 0;
         end if;
         l_nof_actions := l_nof_actions + p_num_of_actions;
         if (l_nof_actions <0 ) then
             l_nof_actions := 0;
         end if;
         x_num_of_actions := l_nof_actions;

        PA_CONTROL_ITEMS_PKG.UPDATE_ROW(
         p_ci_id
        ,cp.ci_type_id
        ,cp.summary
        ,cp.status_code
        ,cp.owner_id
        ,cp.highlighted_flag
        ,cp.progress_status_code
        ,cp.progress_as_of_date
        ,cp.classification_code_id
        ,cp.reason_code_id
        ,p_record_version_number
        ,cp.project_id
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
--        ,cp.last_modified_by_id
         ,NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id)
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,cp.object_type
        ,cp.object_id
        ,cp.ci_number
        ,cp.date_required
        ,cp.date_closed
        ,cp.closed_by_id
        ,cp.description
        ,cp.status_overview
        ,cp.resolution
        ,cp.resolution_code_id
        ,cp.priority_code
        ,cp.effort_level_code
        ,l_nof_actions --open_action_num
        ,cp.price
        ,cp.price_currency_code
        ,cp.source_type_code
        ,cp.source_comment
        ,cp.source_number
        ,cp.source_date_received
        ,cp.source_organization
        ,cp.source_person

        ,cp.attribute_category

        ,cp.attribute1
        ,cp.attribute2
        ,cp.attribute3
        ,cp.attribute4
        ,cp.attribute5
        ,cp.attribute6
        ,cp.attribute7
        ,cp.attribute8
        ,cp.attribute9
        ,cp.attribute10
        ,cp.attribute11
        ,cp.attribute12
        ,cp.attribute13
        ,cp.attribute14
        ,cp.attribute15

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,cp.PCO_STATUS_CODE
        ,cp.APPROVAL_TYPE_CODE
        ,cp.LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,cp.Version_number
        ,cp.Current_Version_flag
        ,cp.Version_Comments
        ,cp.Original_ci_id
        ,cp.Source_ci_id
        ,cp.change_approver
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        ,p_last_updated_by     --Added for bug# 3877985
        ,p_last_update_date    --Added for bug# 3877985
        ,p_last_update_login   --Added for bug# 3877985
       );
   end if;


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO UPDATE_NUMBER_OF_ACTIONS;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_NUMBER_OF_ACTIONS;

procedure UPDATE_CONTROL_ITEM_STATUS (
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num

        ,p_ci_id                    IN NUMBER
        ,p_status_code              IN VARCHAR2
        ,p_record_version_number    IN NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2

) IS

   API_ERROR                           EXCEPTION;
   cp pa_control_items%ROWTYPE;

   CURSOR c_curr_item
        is
           SELECT * FROM pa_control_items
           WHERE ci_id = p_ci_id;
   l_curr_system_status_code pa_project_statuses.project_system_status_code%TYPE := NULL;
   l_new_system_status_code pa_project_statuses.project_system_status_code%TYPE := NULL;
   l_closed_date pa_control_items.date_closed%TYPE;
   l_closed_by   pa_control_items.closed_by_id%TYPE;
   l_ci_number   pa_control_items.ci_number%TYPE;
   l_ci_number_num NUMBER(15)    := NULL;
--   l_ci_number_char VARCHAR2(30) := NULL;
   l_ci_number_char PA_CONTROL_ITEMS.ci_number%type := NULL;
   l_auto_numbers VARCHAR2(1) := 'N';
   l_type_id     PA_CI_TYPES_B.ci_type_id%TYPE;
   l_type_class  PA_CI_TYPES_B.ci_type_class_code%TYPE;
   l_project_id  PA_CONTROL_ITEMS.project_Id%TYPE;
   l_ci_id  NUMBER;


  cursor c_auto_num is
        Select type.auto_number_flag, type.ci_type_id,type.ci_type_class_code
        From   PA_CI_TYPES_B     type
               ,pa_control_items ci
        Where  ci.ci_id = p_ci_id
           AND ci.ci_type_id = type.ci_type_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.UPDATE_CONTROL_ITEM_STATUS');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT UPDATE_CONTROL_ITEM_STATUS;
  END IF;

  x_return_status := 'S';

  OPEN c_curr_item  ;
  FETCH c_curr_item INTO cp;
  if c_curr_item%NOTFOUND then
     PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INVALID_ITEM');
         x_return_status := 'E';
    close c_curr_item;
    PA_DEBUG.Reset_Err_Stack;
    return;
  end if ;
  close c_curr_item;

  OPEN c_auto_num;
   FETCH c_auto_num INTO l_auto_numbers, l_type_id, l_type_class;
  if c_auto_num%NOTFOUND then
     PA_UTILS.Add_Message(
         p_app_short_name => 'PA'
        ,p_msg_name       => 'PA_CI_INVALID_TYPE_ID');
         x_return_status := 'E';
    close c_auto_num;
    PA_DEBUG.Reset_Err_Stack;
    return;
  end if ;
  close c_auto_num;


    l_closed_by       := cp.closed_by_id;
    l_closed_date     := cp.date_closed;
    l_ci_number_char  := cp.ci_number;
    l_project_id      := cp.project_id;

    l_new_system_status_code  := PA_CONTROL_ITEMS_UTILS.getSystemStatus(p_status_code);
    l_curr_system_status_code := PA_CONTROL_ITEMS_UTILS.getCISystemStatus(p_ci_id);

    --Bug 4618856 Changes start here

    if l_new_system_status_code is not NULL and l_new_system_status_code = 'CI_WORKING' then
       if l_curr_system_status_code is not null and l_curr_system_status_code = 'CI_DRAFT' then
           if l_ci_number_char is NULL AND l_auto_numbers <> 'Y' then
                    PA_UTILS.Add_Message(
                       p_app_short_name => 'PA'
                      ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := 'E';
		    PA_DEBUG.Reset_Err_Stack;
                    return;
           end if;
       end if;
    end if;
    --Bug 4618856 Changes end here

    if l_new_system_status_code is not NULL and l_new_system_status_code = 'CI_WORKING' then
       if l_curr_system_status_code is not null and l_curr_system_status_code = 'CI_DRAFT' then
           if l_ci_number_char is NULL AND l_auto_numbers = 'Y' then
                  LOOP
                     PA_SYSTEM_NUMBERS_PKG.GET_NEXT_NUMBER (
                           p_object1_pk1_value     => l_project_id
                          ,p_object1_type         => 'PA_PROJECTS'
                          ,p_object2_pk1_value    => l_type_id
                          ,p_object2_type         => l_type_class
                          ,x_system_number_id     => l_ci_id
                          ,x_next_number          => l_ci_number_num
                          ,x_return_status        => x_return_status
                          ,x_msg_count            => x_msg_count
                          ,x_msg_data             => x_msg_data);

                     IF  x_return_status <> FND_API.g_ret_sts_success THEN
                            PA_DEBUG.Reset_Err_Stack;
                            raise API_ERROR;
                    END IF;
                    l_ci_number_char := TO_CHAR(l_ci_number_num);
                    -- call Client Extension here
                    PA_CI_NUMBER_CLIENT_EXTN.GET_NEXT_NUMBER (
                           p_object1_pk1_value    => l_project_id
                          ,p_object1_type         => 'PA_PROJECTS'
                          ,p_object2_pk1_value    => l_type_id
                          ,p_object2_type         => l_type_class
                          ,p_next_number          => l_ci_number_char
                          ,x_return_status        => x_return_status
                          ,x_msg_count            => x_msg_count
                          ,x_msg_data             => x_msg_data);


                   EXIT WHEN ci_number_exists(l_project_id, l_ci_number_char
                                  ,l_type_id) = FALSE;
                 END LOOP;

                 if l_ci_number_char is NULL THEN
                     PA_UTILS.Add_Message(
                       p_app_short_name => 'PA'
                      ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := 'E';
                    PA_DEBUG.Reset_Err_Stack;
                    return;
                 end if;
           end if ;
       end if;
    end if;

    if l_new_system_status_code is not NULL and l_new_system_status_code = 'CI_CLOSED' then
           if l_curr_system_status_code is not null and l_curr_system_status_code <> 'CI_CLOSED' then
                 -- IF PA_CI_ACTIONS_UTILS.CHECK_OPEN_ACTIONS_EXIST = 'Y' then
                 --    PA_UTILS.Add_Message(
                 --      p_app_short_name => 'PA'
                 --     ,p_msg_name       => 'PA_CI_OPEN_ACTION_EXISTS');--for SUBMIT!!!
                 --      x_return_status := 'E';
                 --   PA_DEBUG.Reset_Err_Stack;
                 --   return;
                 -- END IF;
                  l_closed_by    := PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id );
                  l_closed_date  := sysdate;
           end if;
    end if;

        PA_CONTROL_ITEMS_PKG.UPDATE_ROW(
         p_ci_id
        ,cp.ci_type_id
        ,cp.summary
        ,p_status_code
        ,cp.owner_id
        ,cp.highlighted_flag
        ,cp.progress_status_code
        ,cp.progress_as_of_date
        ,cp.classification_code_id
        ,cp.reason_code_id
        ,p_record_version_number
        ,cp.project_id
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
--        ,PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ) --cp.last_modified_by_id
         ,NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id)
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,cp.object_type
        ,cp.object_id
        ,l_ci_number_char --cp.ci_number
        ,cp.date_required
        ,l_closed_date --cp.date_closed
        ,l_closed_by --cp.closed_by_id
        ,cp.description
        ,cp.status_overview
        ,cp.resolution
        ,cp.resolution_code_id
        ,cp.priority_code
        ,cp.effort_level_code
        ,cp.open_action_num
        ,cp.price
        ,cp.price_currency_code
        ,cp.source_type_code
        ,cp.source_comment
        ,cp.source_number
        ,cp.source_date_received
        ,cp.source_organization
        ,cp.source_person

        ,cp.attribute_category

        ,cp.attribute1
        ,cp.attribute2
        ,cp.attribute3
        ,cp.attribute4
        ,cp.attribute5
        ,cp.attribute6
        ,cp.attribute7
        ,cp.attribute8
        ,cp.attribute9
        ,cp.attribute10
        ,cp.attribute11
        ,cp.attribute12
        ,cp.attribute13
        ,cp.attribute14
        ,cp.attribute15

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,cp.PCO_STATUS_CODE
        ,cp.APPROVAL_TYPE_CODE
        ,cp.LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,cp.Version_number
        ,cp.Current_Version_flag
        ,cp.Version_Comments
        ,cp.Original_ci_id
        ,cp.Source_ci_id
        ,cp.change_approver
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
       );


     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
  WHEN API_ERROR THEN
   x_return_status := x_return_status;

    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO UPDATE_CONTROL_ITEM_STATUS;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.UPDATE_CONTROL_ITEM_STATUS'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_CONTROL_ITEM_STATUS;

FUNCTION ASSIGN_CONTROL_ITEM_NUMBER(
	 p_project_id  IN NUMBER
	,p_ci_type_id  IN NUMBER
) RETURN VARCHAR2

IS
   l_new_number NUMBER(15) := NULL;
   l_rowid ROWID;
   l_ci_id NUMBER;

/*
   cursor C is select ROWID from PA_SYSTEM_NUMBERS
     where object1_pk1_value = p_project_id
          and nvl(object2_pk1_value,0) = nvl(p_ci_type_id,0)
          and object1_type = p_object_type
          and object2_type = p_ci_type_code;
*/
BEGIN
NULL;--	RETURN PA_SYSTEM_NUMBERS_PKG.get_next_number(;
end ASSIGN_CONTROL_ITEM_NUMBER;
--
FUNCTION has_null_data (
           p_ci_type_id  IN  NUMBER
          ,p_project_id  IN  NUMBER
          ,p_status_code IN  VARCHAR2
          ,p_owner_id    IN  NUMBER
          ,p_summary     IN  VARCHAR2

   )
RETURN BOOLEAN
IS
        l_null_data BOOLEAN := FALSE;
BEGIN

  IF p_ci_type_id is NULL THEN
  	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_TYPE');
  	l_null_data := TRUE;
  END IF;
  IF p_project_id is NULL THEN
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_NO_PROJECT_ID');
     	l_null_data := TRUE;
  END IF;
  IF p_status_code  is NULL THEN
       	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name      => 'PA_CI_NO_STATUS');
     	l_null_data := TRUE;
  END IF;
  IF p_owner_id   is NULL THEN
       	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name      => 'PA_CI_NO_OWNER');
     	l_null_data := TRUE;
  END IF;

  IF p_summary    is NULL THEN
       	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name      => 'PA_CI_NO_SUMMARY');
     	l_null_data := TRUE;
  END IF;

  RETURN l_null_data;

 EXCEPTION
    WHEN OTHERS THEN
    -- Set the exception Message and the stack
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_CONTROL_ITEMS_PVT.has_null_data'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );

    RAISE;

END has_null_data;

-- checks whether a control item number already exists for this project/control item type

FUNCTION ci_number_exists(p_project_id  IN  NUMBER
                ,p_ci_number            IN  VARCHAR2
                ,p_ci_type_id           IN  NUMBER)

RETURN BOOLEAN
IS
   l_ROWID ROWID;
   cursor C is select ROWID from PA_CONTROL_ITEMS
     where    project_id = p_project_id
          and ci_number  = p_ci_number
          and ci_type_id = p_ci_type_id;

BEGIN
  if p_ci_number is NULL then
     return FALSE;
  end if;

  open C;
  fetch C into l_ROWID;
  if (C%notfound) then
      close C;
      return FALSE;
  else
     close C;
     return TRUE;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END ci_number_exists;

-- Validates pa_lookups which has p_lookup_type and p_lookup_code
--
FUNCTION is_lookup_valid (p_lookup_type  IN  VARCHAR2
                            ,p_lookup_code  IN  VARCHAR2)
RETURN BOOLEAN
IS
	l_meaning VARCHAR2(80);
BEGIN

 SELECT meaning
 INTO  l_meaning
 FROM  pa_lookups
 WHERE lookup_type = p_lookup_type
 AND   lookup_code = p_lookup_code;

 return TRUE;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return FALSE;
    WHEN OTHERS THEN
    -- Set the exception Message and the stack
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_CONTROL_ITEMS_PVT.is_lookup_valid'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );

    RAISE;

END is_lookup_valid;

PROCEDURE change_included_cr_status(p_ci_id         IN  NUMBER
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2)
IS
   l_open_actions_num    NUMBER;

   CURSOR items_c IS
   SELECT obj.object_id_to1 included_ci_id
         ,ci.record_version_number record_version_number
   FROM pa_object_relationships obj, pa_control_items ci
   WHERE obj.object_type_from = 'PA_CONTROL_ITEMS'
     AND obj.object_type_to = 'PA_CONTROL_ITEMS'
     AND obj.relationship_type = 'CI_INCLUDED_ITEM'
     AND obj.object_id_from1 = p_ci_id
     AND obj.object_id_to1 = ci.ci_id;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR cur in items_c LOOP
       PA_CONTROL_ITEMS_UTILS.ChangeCIStatus (
                              p_init_msg_list         => FND_API.G_TRUE
                             ,p_validate_only         => FND_API.G_FALSE
                             ,p_ci_id                 => cur.included_ci_id
                             ,p_status                => 'CI_APPROVED'
                             ,p_record_version_number => cur.record_version_number
                             ,x_num_of_actions        => l_open_actions_num
                             ,x_return_status         => x_return_status
                             ,x_msg_count             => x_msg_count
                             ,x_msg_data              => x_msg_data);

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message (p_app_short_name => 'PA'
                               ,p_msg_name       => x_msg_data);
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END LOOP;

END change_included_cr_status;


PROCEDURE add_related_item (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_id			IN NUMBER,
  p_related_ci_id		IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
  l_object_relationship_id NUMBER;
BEGIN
  pa_debug.set_err_stack ('PA_CONTROL_ITEMS_PVT.ADD_RELATED_ITEM');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT add_related_item;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = FND_API.G_TRUE THEN
    RETURN;
  END IF;

     PA_OBJECT_RELATIONSHIPS_PKG.INSERT_ROW(
	p_user_id => fnd_global.user_id,
	p_object_type_from => 'PA_CONTROL_ITEMS',
	p_object_id_from1 => to_char(p_ci_id),
	p_object_id_from2 => NULL,
	p_object_id_from3 => NULL,
	p_object_id_from4 => NULL,
	p_object_id_from5 => NULL,
	p_object_type_to => 'PA_CONTROL_ITEMS',
	p_object_id_to1 => to_char(p_related_ci_id),
	p_object_id_to2 => NULL,
	p_object_id_to3 => NULL,
	p_object_id_to4 => NULL,
	p_object_id_to5 => NULL,
	p_relationship_type => 'CI_REFERENCED_ITEM',
	p_relationship_subtype => NULL,
	p_lag_day => NULL,
	p_imported_lag => NULL,
	p_priority => NULL,
	p_pm_product_code => NULL,
	x_object_relationship_id => l_object_relationship_id,
	x_return_status => x_return_status);

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO add_related_item;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO add_related_item;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_PVT',
                            p_procedure_name => 'ADD_RELATED_ITEM',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END add_related_item;


PROCEDURE delete_related_item (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_id			IN NUMBER,
  p_related_ci_id		IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
  l_object_relationship_id NUMBER;
  l_record_version_number NUMBER;
BEGIN
  pa_debug.set_err_stack ('PA_CONTROL_ITEMS_PVT.DELETE_RELATED_ITEM');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_related_item;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  SELECT object_relationship_id, record_version_number
  INTO l_object_relationship_id, l_record_version_number
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_REFERENCED_ITEM'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND (   (    object_id_to1 = p_related_ci_id
             AND object_id_from1 = p_ci_id)
         OR (    object_id_to1 = p_ci_id
             AND object_id_from1 = p_related_ci_id));

  IF p_validate_only = FND_API.G_TRUE THEN
    RETURN;
  END IF;

  pa_object_relationships_pkg.delete_row(
	p_object_relationship_id => l_object_relationship_id,
	p_object_type_from => 'PA_CONTROL_ITEMS',
	p_object_id_from1 => to_char(p_ci_id),
	p_object_id_from2 => NULL,
	p_object_id_from3 => NULL,
	p_object_id_from4 => NULL,
	p_object_id_from5 => NULL,
	p_object_type_to => 'PA_CONTROL_ITEMS',
	p_object_id_to1 => to_char(p_related_ci_id),
	p_object_id_to2 => NULL,
	p_object_id_to3 => NULL,
	p_object_id_to4 => NULL,
	p_object_id_to5 => NULL,
	p_pm_product_code => NULL,
	p_record_version_number => l_record_version_number,
	x_return_status => x_return_status);

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_related_item;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_related_item;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_PVT',
                            p_procedure_name => 'DELETE_RELATED_ITEM',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_related_item;

PROCEDURE delete_all_related_items (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_id			IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
  CURSOR items_c IS
  SELECT object_id_to1 related_ci_id
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_REFERENCED_ITEM'
    AND object_id_from1 = p_ci_id
  UNION ALL
  SELECT object_id_from1 related_ci_id
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_REFERENCED_ITEM'
    AND object_id_to1 = p_ci_id;



BEGIN
  pa_debug.set_err_stack ('PA_CONTROL_ITEMS_PVT.DELETE_ALL_RELATED_ITEMS');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_all_related_items;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = FND_API.G_TRUE THEN
    RETURN;
  END IF;

  FOR cur in items_c LOOP
    delete_related_item(
	p_init_msg_list => FND_API.G_FALSE,
	p_commit => FND_API.G_FALSE,
	p_validate_only => FND_API.G_FALSE,
        p_max_msg_count => p_max_msg_count,
        p_ci_id => p_ci_id,
        p_related_ci_id => cur.related_ci_id,
	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
  	x_msg_data => x_msg_data);
  END LOOP;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_all_related_items;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_all_related_items;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_PVT',
                            p_procedure_name => 'DELETE_ALL_RELATED_ITEMS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_all_related_items;


PROCEDURE delete_all_included_crs (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_id			IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
  CURSOR items_c IS
  SELECT object_relationship_id, object_id_to1, record_version_number
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_INCLUDED_ITEM'
    AND object_id_from1 = p_ci_id;

BEGIN
  pa_debug.set_err_stack ('PA_CONTROL_ITEMS_PVT.DELETE_ALL_INCLUDED_CRS');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_all_included_crs;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = FND_API.G_TRUE THEN
    RETURN;
  END IF;

  FOR cur in items_c LOOP

      pa_object_relationships_pkg.delete_row(
        p_object_relationship_id => cur.object_relationship_id,
        p_object_type_from => 'PA_CONTROL_ITEMS',
        p_object_id_from1 => to_char(p_ci_id),
        p_object_id_from2 => NULL,
        p_object_id_from3 => NULL,
        p_object_id_from4 => NULL,
        p_object_id_from5 => NULL,
        p_object_type_to => 'PA_CONTROL_ITEMS',
        p_object_id_to1 => to_char(cur.object_id_to1),
        p_object_id_to2 => NULL,
        p_object_id_to3 => NULL,
        p_object_id_to4 => NULL,
        p_object_id_to5 => NULL,
        p_pm_product_code => NULL,
        p_record_version_number => cur.record_version_number,
        x_return_status => x_return_status);

  END LOOP;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_all_included_crs;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_all_included_crs;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_PVT',
                            p_procedure_name => 'DELETE_ALL_INCLUDED_CRS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_all_included_crs;

PROCEDURE copy_related_items (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_from_ci_id			IN NUMBER,
  p_to_ci_id			IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
  CURSOR items_c IS
  SELECT object_id_to1 related_ci_id
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_REFERENCED_ITEM'
    AND object_id_from1 = p_from_ci_id
  UNION ALL
  SELECT object_id_from1 related_ci_id
  FROM pa_object_relationships
  WHERE object_type_from = 'PA_CONTROL_ITEMS'
    AND object_type_to = 'PA_CONTROL_ITEMS'
    AND relationship_type = 'CI_REFERENCED_ITEM'
    AND object_id_to1 = p_from_ci_id;


BEGIN
  pa_debug.set_err_stack ('PA_CONTROL_ITEMS_PVT.COPY_RELATED_ITEMS');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT copy_related_items;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = FND_API.G_TRUE THEN
    RETURN;
  END IF;

  FOR cur in items_c LOOP
    pa_control_items_pvt.add_related_item(
	p_init_msg_list => FND_API.G_FALSE,
	p_commit => FND_API.G_FALSE,
	p_validate_only => FND_API.G_FALSE,
        p_max_msg_count => p_max_msg_count,
        p_ci_id => p_to_ci_id,
        p_related_ci_id => cur.related_ci_id,
	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
  	x_msg_data => x_msg_data);
  END LOOP;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO copy_related_items;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO copy_related_items;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_ITEMS_PVT',
                            p_procedure_name => 'COPY_RELATED_ITEMS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END copy_related_items;

-- start:   26-Jun-2009    cklee     Modified for the Bug# 8633676
procedure LOCK_CONTROL_ITEM (
         p_api_version          IN     NUMBER   := 1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER   := FND_API.g_miss_num
  	,p_ci_id                IN     NUMBER
  	,x_return_status        OUT    NOCOPY VARCHAR2
  	,x_msg_count            OUT    NOCOPY NUMBER
  	,x_msg_data             OUT    NOCOPY VARCHAR2

) is
   l_status_code          pa_project_statuses.project_system_status_code%type;
   cursor valid_ci is
     select pps.project_system_status_code --status_code
       from pa_control_items ci
            ,pa_project_statuses pps
      where ci.ci_id = p_ci_id
        and ci.status_code = pps.project_status_code;

     CURSOR curr_row is
     SELECT
 CI_ID
 ,CI_TYPE_ID
 ,SUMMARY
 ,STATUS_CODE
 ,OWNER_ID
 ,HIGHLIGHTED_FLAG
 ,PROGRESS_STATUS_CODE
 ,PROGRESS_AS_OF_DATE
 ,CLASSIFICATION_CODE_ID
 ,REASON_CODE_ID
 ,RECORD_VERSION_NUMBER
 ,PROJECT_ID
 ,LAST_MODIFICATION_DATE
 ,LAST_MODIFIED_BY_ID
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,LAST_UPDATE_LOGIN
 ,OBJECT_TYPE
 ,OBJECT_ID
 ,CI_NUMBER
 ,DATE_REQUIRED
 ,DATE_CLOSED
 ,CLOSED_BY_ID
 ,DESCRIPTION
 ,STATUS_OVERVIEW
 ,RESOLUTION
 ,RESOLUTION_CODE_ID
 ,PRIORITY_CODE
 ,EFFORT_LEVEL_CODE
 ,OPEN_ACTION_NUM
 ,PRICE
 ,PRICE_CURRENCY_CODE
 ,SOURCE_TYPE_CODE
 ,SOURCE_COMMENT
 ,SOURCE_NUMBER
 ,SOURCE_DATE_RECEIVED
 ,SOURCE_ORGANIZATION
 ,SOURCE_PERSON
 ,LAST_ACTION_NUMBER
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
 ,ORIG_SYSTEM_CODE
 ,ORIG_SYSTEM_REFERENCE
 ,VERSION_NUMBER
 ,CURRENT_VERSION_FLAG
 ,ORIGINAL_CI_ID
 ,SOURCE_CI_ID
 ,VERSION_COMMENTS
 ,CHANGE_APPROVER
 ,PCO_STATUS_CODE
 ,APPROVAL_TYPE_CODE
 ,LOCKED_FLAG
 ,PCO_SEQUENCE
      FROM  pa_control_items
      WHERE  ci_id = p_ci_id;

     cp    curr_row%rowtype;
     l_ROWID ROWID;

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Lock_Control_Item');

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT lock_control_item;
  END IF;

  IF p_ci_id is NULL THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
      open valid_ci;
      fetch valid_ci into l_status_code;
      if (valid_ci%notfound) then
         --- invalid ci_id error
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
          x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      close valid_ci;
   END IF;
   IF  x_return_status = FND_API.g_ret_sts_success THEN

  OPEN curr_row;
  FETCH curr_row INTO cp;
  if curr_row%NOTFOUND then
       close curr_row;
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name      => 'PA_CI_INVALID_ITEM');
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
       PA_DEBUG.Reset_Err_Stack;
  end if;

       PA_CONTROL_ITEMS_PKG.UPDATE_ROW(
        p_ci_id                 => p_ci_id
        ,p_ci_type_id           => cp.ci_type_id
        ,p_summary              => cp.summary
        ,p_status_code          => cp.status_code
        ,p_owner_id             => cp.owner_id
        ,p_highlighted_flag     => cp.highlighted_flag
        ,p_progress_status_code => cp.progress_status_code
        ,p_progress_as_of_date  => cp.progress_as_of_date
        ,p_classification_code  => cp.classification_code_id
        ,p_reason_code          => cp.reason_code_id
        ,p_record_version_number=> cp.record_version_number
        ,p_project_id           => cp.project_id
        ,p_last_modified_by_id  => NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id ) --cp.last_modified_by_id
        ,p_object_type          => cp.object_type
        ,p_object_id            => cp.object_id
        ,p_ci_number            => cp.ci_number
        ,p_date_required        => cp.date_required
        ,p_date_closed          => cp.date_closed
        ,p_closed_by_id         => cp.closed_by_id
        ,p_description          => cp.description
        ,p_status_overview      => cp.status_overview
        ,p_resolution           => cp.resolution
        ,p_resolution_code      => cp.resolution_code_id
        ,p_priority_code        => cp.priority_code
        ,p_effort_level_code    => cp.effort_level_code
        ,p_open_action_num      => cp.open_action_num
        ,p_price                => cp.price
        ,p_price_currency_code  => cp.price_currency_code
        ,p_source_type_code     => cp.source_type_code
        ,p_source_comment       => cp.source_comment
        ,p_source_number        => cp.source_number
        ,p_source_date_received => cp.source_date_received
        ,p_source_organization  => cp.source_organization
        ,p_source_person        => cp.source_person
        ,p_attribute_category   => cp.attribute_category
        ,p_attribute1           => cp.attribute1
        ,p_attribute2           => cp.attribute2
        ,p_attribute3           => cp.attribute3
        ,p_attribute4           => cp.attribute4
        ,p_attribute5           => cp.attribute5
        ,p_attribute6           => cp.attribute6
        ,p_attribute7           => cp.attribute7
        ,p_attribute8           => cp.attribute8
        ,p_attribute9           => cp.attribute9
        ,p_attribute10          => cp.attribute10
        ,p_attribute11          => cp.attribute11
        ,p_attribute12          => cp.attribute12
        ,p_attribute13          => cp.attribute13
        ,p_attribute14          => cp.attribute14
        ,p_attribute15          => cp.attribute15
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE      => cp.PCO_STATUS_CODE
        ,p_APPROVAL_TYPE_CODE   => cp.APPROVAL_TYPE_CODE
        ,p_LOCKED_FLAG          => 'Y' --cp.LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_Version_number       => cp.Version_number
        ,p_Current_Version_flag => cp.Current_Version_flag
        ,p_Version_Comments     => cp.Version_Comments
        ,p_Original_ci_id       => cp.Original_ci_id
        ,p_Source_ci_id         => cp.Source_ci_id
		,p_change_approver  => cp.change_approver
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
        ,p_last_updated_by 	   => fnd_global.user_id
        ,p_last_update_date 	  => sysdate
        ,p_last_update_login    => fnd_global.user_id
       );

   END IF;
     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO locked_control_item;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PVT.lock_control_item'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end LOCK_CONTROL_ITEM;
-- end   26-Jun-2009    cklee     Modified for the Bug# 8633676


END  PA_CONTROL_ITEMS_PVT;

/
