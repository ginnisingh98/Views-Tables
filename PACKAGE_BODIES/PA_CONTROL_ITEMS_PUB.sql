--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_PUB" AS
--$Header: PACICIPB.pls 120.1.12010000.4 2009/07/23 22:55:50 cklee ship $


procedure getPartyIdFromName(
         p_project_id            IN  NUMBER
        ,p_name                  IN  VARCHAR2
        ,x_party_id              OUT NOCOPY NUMBER
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
) is

   l_party_id       NUMBER := NULL;

BEGIN
       x_return_status := 'S';
      BEGIN
        SELECT DISTINCT ppp.resource_source_id party_id
        INTO l_party_id
        FROM hz_parties hzp,
 	     pa_project_parties ppp
        WHERE hzp.party_name = p_name
          AND hzp.party_type = 'PERSON'
          AND ppp.resource_source_id = hzp.party_id
          AND ppp.resource_type_id = 112
          AND ppp.project_id = p_project_id
          AND (TRUNC(SYSDATE) BETWEEN TRUNC(ppp.start_date_active)
                                  AND TRUNC(NVL(ppp.end_date_active, SYSDATE)));


      EXCEPTION
         when TOO_MANY_ROWS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OWNER_NAME_MULTIPLE');
           x_return_status := 'E';
         when NO_DATA_FOUND then
           l_party_id := NULL;
         when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CI_NO_OWNER');
           x_return_status := 'E';
       END;

       IF (x_return_status = 'S' AND l_party_id is NULL) THEN
         SELECT DISTINCT ppf.party_id party_id
         INTO l_party_id
         FROM pa_project_parties ppp,
              per_all_people_f ppf
         WHERE ppf.full_name = p_name
	   AND (TRUNC(SYSDATE) BETWEEN TRUNC(ppf.effective_start_date)
                                   AND TRUNC(ppf.effective_end_date))
	   AND ppp.resource_source_id = ppf.person_id
           AND ppp.resource_type_id = 101
           AND ppp.project_id = p_project_id
           AND (TRUNC(SYSDATE) BETWEEN TRUNC(ppp.start_date_active)
                                   AND TRUNC(NVL(ppp.end_date_active, SYSDATE)));
       END IF;

 x_party_id := l_party_id;

 exception when TOO_MANY_ROWS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OWNER_NAME_MULTIPLE');
           x_return_status := 'E';

 when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_CI_NO_OWNER');
           x_return_status := 'E';

end getPartyIdFromName;


procedure ADD_CONTROL_ITEM(
 	 p_api_version          IN     NUMBER :=  1.0
 	,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
 	,p_commit               IN     VARCHAR2 := FND_API.g_false
 	,p_validate_only        IN     VARCHAR2 := FND_API.g_true
 	,p_max_msg_count        IN     NUMBER := FND_API.g_miss_num

        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2
        ,p_owner_id             IN  NUMBER    := NULL
        ,p_owner_name           IN  VARCHAR2  := NULL
        ,p_highlighted_flag     IN  VARCHAR2  := 'N'
        ,p_progress_status_code IN  VARCHAR2  := NULL
        ,p_progress_as_of_date  IN  DATE      := NULL
        ,p_classification_code  IN  NUMBER
        ,p_reason_code          IN  NUMBER
        ,p_project_id           IN  NUMBER
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_object_name          IN  VARCHAR2   := NULL
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
        ,p_open_action_num      IN  NUMBER     := NULL

        ,p_price                IN  NUMBER     := NULL
        ,p_price_currency_code  IN  VARCHAR2   := NULL
        ,p_source_type_code     IN  VARCHAR2   := NULL
        ,p_source_comment       IN  VARCHAR2   := NULL
        ,p_source_number        IN  VARCHAR2   := NULL
        ,p_source_date_received IN  DATE       := NULL
        ,p_source_organization  IN  VARCHAR2  := NULL
        ,p_source_person        IN  VARCHAR2  := NULL
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

   l_msg_index_out        NUMBER;

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
   l_last_modified_by_id  NUMBER := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id);
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
   l_owner_id             NUMBER := NULL;
   l_object_id            NUMBER;
   l_debug_mode                    VARCHAR2(1);
   l_debug_level6                   CONSTANT NUMBER := 6;
   g_module_name      VARCHAR2(100) := 'pa.plsql.CreateCI,Add_Control_Item';
   l_classification_code  NUMBER;   /*Bug 4049588*/
   l_reason_code          NUMBER;   /* Bug 4049588*/

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.Add_Control_Item');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --get hz_parties.party_id of the logged in user
--  l_last_modified_by_id := nvl(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id);
-- 26-Jun-2009    cklee     Modified for the Bug# 8633676
  l_owner_id            := p_owner_id;
  l_object_id           := p_object_id;


  -- check mandatory owner_id
  IF (l_owner_id IS NULL) THEN
     IF (p_owner_name is not null) then
     getPartyIdFromName(
         p_project_id     => p_project_id
        ,p_name           => p_owner_name
        ,x_party_id       => l_owner_id
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data);
     ELSE
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_CI_NO_OWNER');
        x_return_status := 'E';
     END IF;
  END IF;

    --Bug 4049588. Check if Classification Code and Reason Code are null.
    l_classification_code := p_classification_code ;
    l_reason_code := p_reason_code;
    IF (l_classification_code IS NULL OR l_reason_code IS NULL )
       THEN
         IF (l_classification_code IS NULL) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_NO_CLASSIFICATION_CODE');
             x_return_status := 'E';
          END IF;
         IF (l_reason_code IS NULL) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_NO_REASON_CODE');
             x_return_status := 'E';
         END IF;
    END IF;


  IF (l_object_id IS NULL AND p_object_name is not null) THEN
     -- try to get object id  from name - as of now we're only handling PA_TASKS objects
       begin
       select proj_element_id
          into l_object_id
          from PA_FIN_LATEST_PUB_TASKS_V
          where element_name = p_object_name
          and project_id     = p_project_id;

        exception when TOO_MANY_ROWS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_MULTIPLE');
           x_return_status := 'E';

        when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_INV');
           x_return_status := 'E';
       end;

  END IF;


l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
	  IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'About to call the private method';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level6);
	  END IF;

  IF (x_return_status <> 'E')THEN
      PA_CONTROL_ITEMS_PVT.ADD_CONTROL_ITEM(
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

        ,p_ci_type_id
        ,p_summary
        ,p_status_code
        ,l_owner_id
        ,nvl(p_highlighted_flag,'N')
        ,p_progress_status_code
        ,p_progress_as_of_date
        ,p_classification_code
        ,p_reason_code
        ,p_project_id
        ,l_last_modified_by_id
        ,p_object_type
        ,l_object_id
        ,p_ci_number
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
        ,p_LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,p_Version_number
        ,p_Current_Version_flag
        ,p_Version_Comments
        ,p_Original_ci_id
        ,p_Source_ci_id
        ,px_ci_id
        ,x_ci_number
        ,x_return_status
        ,x_msg_count
        ,x_msg_data

        );
    END IF;

  IF l_debug_mode = 'Y' THEN
	          pa_debug.g_err_stage:= 'private method called';
	          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     l_debug_level6);
	  END IF;


  -- IF the number of messages is 1 then fetch the message code from the stack
  -- and return its text
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.ADD_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end ADD_CONTROL_ITEM;

procedure UPDATE_CONTROL_ITEM (
         p_api_version          IN     NUMBER :=  1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER := FND_API.g_miss_num
        ,p_ci_id                IN  NUMBER
        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2  := NULL

        ,p_owner_id             IN  NUMBER    := NULL
        ,p_owner_name           IN  VARCHAR2  := NULL
        ,p_highlighted_flag     IN  VARCHAR2  := 'N'
        ,p_progress_status_code IN  VARCHAR2
        ,p_progress_as_of_date  IN  DATE
        ,p_classification_code  IN  NUMBER
        ,p_reason_code          IN  NUMBER
        ,p_record_version_number IN  NUMBER
        ,p_project_id           IN  NUMBER
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_object_name          IN  VARCHAR2   := NULL
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

        ,p_Version_number        IN number    := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
		,p_change_approver       IN varchar2 := NULL
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
) is

   l_msg_index_out        NUMBER;
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
   l_last_modified_by_id  NUMBER := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id);
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676
   l_owner_id             NUMBER;
   l_object_id            NUMBER;
   l_chgowner_allowed     VARCHAR2(1);   /* Bug3297238 */
   l_curr_owner_id        NUMBER;
   l_to_owner_allowed     VARCHAR2(1);   /* Bug#4050242 */
   l_classification_code  NUMBER;   /* Bug 4049588.*/
   l_reason_code          NUMBER;   /* Bug 4049588.*/

   cursor c_curr_owner is
     select owner_id from pa_control_items
      where ci_id = p_ci_id;
begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --get hz_parties.party_id of the logged in user
--  l_last_modified_by_id := nvl(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id);
 --26-Jun-2009    cklee     Modified for the Bug# 8633676
  l_owner_id            := p_owner_id;
  l_object_id           := p_object_id;

  -- check mandatory owner_id
  IF (l_owner_id IS NULL) THEN
     IF (p_owner_name is not null) then
     getPartyIdFromName(
         p_project_id     => p_project_id
        ,p_name           => p_owner_name
        ,x_party_id       => l_owner_id
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data);
     ELSE
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_CI_NO_OWNER');
        x_return_status := 'E';
     END IF;
  END IF;

    --Bug 4049588. Check if Classification Code and Reason Code are null.
    l_classification_code := p_classification_code ;
    l_reason_code := p_reason_code;
    IF (l_classification_code IS NULL OR l_reason_code IS NULL )
       THEN
         IF (l_classification_code IS NULL) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_NO_CLASSIFICATION_CODE');
             x_return_status := 'E';
          END IF;
         IF (l_reason_code IS NULL) THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_NO_REASON_CODE');
             x_return_status := 'E';
         END IF;
    END IF;

  /* Code added for Bug#3297238, starts here */
    open c_curr_owner;
    fetch c_curr_owner into l_curr_owner_id;
    close c_curr_owner;

   if (l_owner_id <> l_curr_owner_id) then
      l_chgowner_allowed := pa_ci_security_pkg.check_change_owner_access(p_ci_id);
      if (l_chgowner_allowed <> 'T') then
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_OWNER_CHG_NOT_ALLOWED');
          x_return_status := 'E';
      /* Code added for Bug#4050242, starts here */
      else
          l_to_owner_allowed := pa_ci_security_pkg.is_to_owner_allowed(p_ci_id, l_owner_id);
	  if (l_to_owner_allowed <> 'T') then
		  PA_UTILS.Add_Message( p_app_short_name => 'PA'
				       ,p_msg_name       => 'PA_CI_TO_OWNER_NOT_ALLOWED');
		  x_return_status := 'E';
          end if;
      /* Code added for Bug#4050242, ends here */
      end if;

 --  Bug 3650877: Commneted this check for the owner id.

   --elsif (l_owner_id = l_curr_owner_id) then
   --       PA_UTILS.Add_Message( p_app_short_name => 'PA'
   --                           ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
   --       x_return_status := 'E';
   end if;
  /* Code added for Bug#3297238, ends here */

  IF (l_object_id IS NULL AND p_object_name is not null) THEN
    -- try to get object id  from name - as of now we're only handling PA_TASKS objects
       begin
       select proj_element_id
          into l_object_id
          from PA_FIN_LATEST_PUB_TASKS_V
          where element_name = p_object_name
          and project_id     = p_project_id;

        exception when TOO_MANY_ROWS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_MULTIPLE');
           x_return_status := 'E';

        when OTHERS then
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_INV');
           x_return_status := 'E';
       end;

  END IF;


  IF (x_return_status <> 'E')THEN
      PA_CONTROL_ITEMS_PVT.UPDATE_CONTROL_ITEM(
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

        ,p_ci_id
        ,p_ci_type_id
        ,p_summary
        ,p_status_code
        ,l_owner_id
        ,nvl(p_highlighted_flag,'N')
        ,p_progress_status_code
        ,p_progress_as_of_date
        ,p_classification_code
        ,p_reason_code
        ,p_record_version_number
        ,p_project_id
        ,l_last_modified_by_id
        ,p_object_type
        ,l_object_id
        ,p_ci_number
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
        ,p_LOCKED_FLAG
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

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_CONTROL_ITEM;



procedure DELETE_CONTROL_ITEM (
         p_api_version          IN     NUMBER :=  1.0
        ,p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     NUMBER := FND_API.g_miss_num

  	,p_ci_id                IN  NUMBER
        ,p_record_version_number       IN     NUMBER
  	,x_return_status               OUT NOCOPY    VARCHAR2
  	,x_msg_count                   OUT NOCOPY    NUMBER
  	,x_msg_data                    OUT NOCOPY    VARCHAR2

) is

   l_msg_index_out        NUMBER;
--   l_status_code          pa_control_items.status_code%type;

--   cursor valid_ci is
--     select status_code
--       from pa_control_items
--      where ci_id = p_ci_id;

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.DELETE_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
/*
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


  if (x_return_status = 'S') then */

   PA_CONTROL_ITEMS_PVT.DELETE_CONTROL_ITEM(
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

        ,p_ci_id
        ,p_record_version_number
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
       );
--  end if;


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

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.DELETE_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_CONTROL_ITEM;

procedure COPY_CONTROL_ITEM (
         p_api_version            IN     NUMBER :=  1.0
        ,p_init_msg_list          IN     VARCHAR2 := fnd_api.g_true
        ,p_commit                 IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only          IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count          IN     NUMBER := FND_API.g_miss_num

        ,p_project_id             IN  NUMBER
        ,p_ci_id_from             IN  NUMBER   -- copy from this
        ,p_ci_type_id             IN  NUMBER   -- copy to this
        ,p_classification_code_id IN  NUMBER
        ,p_reason_code_id         IN  NUMBER
        ,p_include                IN  VARCHAR2 := 'N'
        ,p_record_version_number_from  IN     NUMBER
        ,x_ci_id                       OUT NOCOPY NUMBER
        ,x_ci_number                   OUT NOCOPY VARCHAR2
        ,x_return_status               OUT NOCOPY    VARCHAR2
        ,x_msg_count                   OUT NOCOPY    NUMBER
        ,x_msg_data                    OUT NOCOPY    VARCHAR2

) is

   l_msg_index_out   NUMBER;

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.COPY_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

     pa_control_items_pvt.COPY_CONTROL_ITEM (
         p_commit             => p_commit
        ,p_validate_only      => p_validate_only

        ,p_project_id         => p_project_id
        ,p_ci_id_from         => p_ci_id_from   -- copy from this
        ,p_ci_type_id         => p_ci_type_id   -- copy to this
        ,p_classification_code_id => p_classification_code_id
        ,p_reason_code_id     => p_reason_code_id
        ,p_include            => p_include
        ,p_record_version_number_from  => p_record_version_number_from
        ,x_ci_id                       => x_ci_id
        ,x_ci_number                   => x_ci_number
        ,x_return_status               => x_return_status
        ,x_msg_count                   => x_msg_count
        ,x_msg_data                    => x_msg_data);

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
        ,p_record_version_number_to    IN  NUMBER
        ,x_relationship_id             OUT NOCOPY NUMBER
        ,x_return_status               OUT NOCOPY    VARCHAR2
        ,x_msg_count                   OUT NOCOPY    NUMBER
        ,x_msg_data                    OUT NOCOPY    VARCHAR2
) is

   l_relationship_id      NUMBER;
   l_msg_index_out        NUMBER;

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.INCLUDE_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  if (x_return_status = FND_API.G_RET_STS_SUCCESS) then
     PA_CONTROL_ITEMS_PVT.INCLUDE_CONTROL_ITEM(
         p_api_version                => p_api_version
        ,p_init_msg_list              => p_init_msg_list
        ,p_commit                     => p_commit
        ,p_validate_only              => p_validate_only
        ,p_max_msg_count              => p_max_msg_count
        ,p_from_ci_id                   => p_from_ci_id
        ,p_to_ci_id                     => p_to_ci_id
        ,p_record_version_number_to     => p_record_version_number_to
        ,x_relationship_id            => l_relationship_id
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data);
   end if;

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

  if (p_commit = 'T' and x_return_status = 'S') then
      commit;
  end if;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.INCLUDE_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end INCLUDE_CONTROL_ITEM;


function GET_OBJECT_NAME(p_object_id   IN  NUMBER
                        ,p_object_type IN  VARCHAR2
) return VARCHAR2 is

begin
   null;
end GET_OBJECT_NAME;

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
procedure LOCK_CONTROL_ITEM (
         p_api_version          IN  NUMBER   := 1.0
        ,p_init_msg_list        IN  VARCHAR2 := fnd_api.g_true
        ,p_commit               IN  VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN  VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN  NUMBER   := FND_API.g_miss_num
 	,p_ci_id                IN  NUMBER
  	,x_return_status        OUT NOCOPY VARCHAR2
  	,x_msg_count            OUT NOCOPY NUMBER
  	,x_msg_data             OUT NOCOPY VARCHAR2
) is

   l_msg_index_out        NUMBER;

begin

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PUB.LOCK_CONTROL_ITEM');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT lock_control_item;
  END IF;


   PA_CONTROL_ITEMS_PVT.LOCK_CONTROL_ITEM(
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count
        ,p_ci_id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
       );

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

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
      rollback to lock_control_item;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CONTROL_ITEMS_PUB.LOCK_CONTROL_ITEM'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end LOCK_CONTROL_ITEM;
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676


END  PA_CONTROL_ITEMS_PUB;

/
