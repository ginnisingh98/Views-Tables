--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_ITEMS_PKG" AS
--$Header: PACICITB.pls 120.3.12010000.7 2010/05/06 12:00:56 rrambati ship $


procedure INSERT_ROW (
         p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2
        ,p_owner_id             IN  NUMBER
        ,p_highlighted_flag     IN  VARCHAR2
        ,p_progress_status_code IN  VARCHAR2
        ,p_progress_as_of_date  IN  DATE
        ,p_classification_code  IN  NUMBER
        ,p_reason_code          IN  NUMBER
        ,p_project_id           IN  NUMBER
        ,p_last_modified_by_id  IN  NUMBER
     := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id) -- 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_ci_number            IN  VARCHAR2   := NULL
        ,p_date_required        IN  DATE       := NULL
        ,p_date_closed          IN  DATE      := NULL
        ,p_closed_by_id         IN  NUMBER    := NULL


        ,p_description          IN  VARCHAR2   := NULL
        ,p_status_overview      IN  VARCHAR2   := NULL
        ,p_resolution           IN  VARCHAR2   := NULL
        ,p_resolution_code      IN  NUMBER     := NULL
        ,p_priority_code        IN  VARCHAR2   := NULL
        ,p_effort_level_code    IN  VARCHAR2   := NULL
        ,p_open_action_num      IN  NUMBER    := NULL

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

  	,px_ci_id               IN  OUT  NOCOPY NUMBER
  	,x_return_status         OUT  NOCOPY VARCHAR2
  	,x_msg_count             OUT  NOCOPY NUMBER
 	,x_msg_data              OUT  NOCOPY VARCHAR2
        ,p_orig_system_code     IN VARCHAR2 := NULL
        ,p_orig_system_reference IN VARCHAR2 := NULL
        ,p_change_approver       IN varchar2 DEFAULT NULL --Added for bug 9108474

) is



   l_rowid ROWID;
   l_ci_id NUMBER;
   l_number_prefix varchar2(50) := NULL;
   l_vers_num NUMBER :=3;
   l_Current_Version_flag varchar2(1) := 'Y';

   cursor C is select ROWID from PA_CONTROL_ITEMS
     where ci_id = px_ci_id;

   cursor vn_csr is select max(version_number) from PA_CONTROL_ITEMS
     where Original_ci_id = p_Original_ci_id;

	cursor curr_prefix is select prefix_auto_number from pa_ci_types_v
	  where ci_type_id = p_ci_type_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --get the unique control item id from the Oracle Sequence
  IF (px_ci_id is null) THEN
	  SELECT pa_control_items_s.nextval
	  INTO l_ci_id
	  FROM DUAL;
	  px_ci_id := l_ci_id;
  END IF;

 IF (nvl(p_version_number,1) = 1) THEN

  open curr_prefix;
  fetch curr_prefix into l_number_prefix;
  if (curr_prefix%notfound) then
    close curr_prefix;
    raise no_data_found;
  end if;
  close curr_prefix;

  l_number_prefix := l_number_prefix || p_ci_number;

 ELSE

  l_number_prefix := p_ci_number;

 END IF;
  insert into PA_CONTROL_ITEMS (
        ci_id
        ,ci_type_id
        ,summary
        ,status_code
        ,owner_id
        ,highlighted_flag
        ,progress_status_code
        ,progress_as_of_date
        ,classification_code_id
        ,reason_code_id
        ,RECORD_VERSION_NUMBER
        ,project_id
        ,LAST_MODIFICATION_DATE
        ,LAST_MODIFIED_BY_ID
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN

        ,object_type
        ,object_id
        ,ci_number
        ,date_required
        ,date_closed
        ,closed_by_id
        ,description
        ,status_overview
        ,resolution
        ,resolution_code_id
        ,priority_code
        ,effort_level_code
        ,open_action_num
        ,price
        ,price_currency_code
        ,source_type_code
        ,source_comment
        ,source_number
        ,source_date_received
        ,source_organization
        ,source_person

	,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,orig_system_code
        ,orig_system_reference

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,PCO_STATUS_CODE
        ,APPROVAL_TYPE_CODE
        ,LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,Version_number
        ,Current_Version_flag
        ,Version_Comments
        ,Original_ci_id
        ,Source_ci_id
        ,CHANGE_APPROVER -- Added for bug 9108474

  ) VALUES (
         px_ci_id
        ,p_ci_type_id
        ,p_summary
        ,p_status_code
        ,p_owner_id
        ,p_highlighted_flag
        ,p_progress_status_code
        ,p_progress_as_of_date
        ,p_classification_code
        ,p_reason_code
        ,1                      --record_version_number
        ,p_project_id
        ,sysdate                --last_modification_date
        ,p_last_modified_by_id  --hz_parties.party_id
        ,sysdate                --creation_date
        ,fnd_global.user_id     --created_by
        ,sysdate                --last_update_date
        ,fnd_global.user_id     --last_updated_by
        ,fnd_global.user_id     --last_update_login
        ,p_object_type
        ,p_object_id
        ,l_number_prefix
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
        ,p_orig_system_code
        ,p_orig_system_reference

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_PCO_STATUS_CODE
        ,p_APPROVAL_TYPE_CODE
        ,p_LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        ,nvl(p_version_number,1)
        ,'Y'
        ,p_Version_Comments
        ,nvl(p_Original_ci_id,px_ci_id)
        ,nvl(p_source_ci_id,px_ci_id)
        ,p_change_approver
    );


  -- PA_CHNGE_DOC_POLICY_PVT.SET_CHNGE_DOC_VERS;

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
 /*  px_ci_id := l_ci_id;  */  /* Bug#3297238 */

   --PA_CHNGE_DOC_POLICY_PVT.RESET_CHNGE_DOC_VERS;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end INSERT_ROW;

procedure UPDATE_ROW (
        p_ci_id                IN  NUMBER
        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2
        ,p_owner_id             IN  NUMBER
        ,p_highlighted_flag     IN  VARCHAR2
        ,p_progress_status_code IN VARCHAR2
        ,p_progress_as_of_date  IN DATE
        ,p_classification_code  IN NUMBER
        ,p_reason_code          IN NUMBER
        ,p_record_version_number IN  NUMBER

        ,p_project_id           IN  NUMBER
        ,p_last_modified_by_id  IN  NUMBER
     := NVL(PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id ), fnd_global.user_id) -- 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,p_object_type          IN  VARCHAR2   := NULL
        ,p_object_id            IN  NUMBER     := NULL
        ,p_ci_number            IN  VARCHAR2   := NULL
        ,p_date_required        IN  DATE       := NULL
        ,p_date_closed          IN  DATE      := NULL
        ,p_closed_by_id         IN  NUMBER    := NULL
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

        ,p_Version_number        IN number
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
		,p_change_approver       IN varchar2 := NULL
        ,x_return_status         OUT  NOCOPY VARCHAR2
        ,x_msg_count             OUT  NOCOPY NUMBER
        ,x_msg_data              OUT  NOCOPY VARCHAR2
        ,p_last_updated_by 	 in NUMBER default fnd_global.user_id  --Added the parameter for bug# 3877985
        ,p_last_update_date 	 in DATE default sysdate               --Added the parameter for bug# 3877985
        ,p_last_update_login     in NUMBER default fnd_global.user_id  --Added the parameter for bug# 3877985

) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  update PA_CONTROL_ITEMS set
         ci_type_id			= Nvl(p_ci_type_id,ci_type_id)
        ,summary                        = Nvl(p_summary,summary)
        ,status_code                    = Nvl(p_status_code, status_code)
        ,owner_id                       = Nvl(p_owner_id,owner_id)
        ,highlighted_flag               = Nvl(p_highlighted_flag, highlighted_flag)
        ,progress_status_code           = Nvl(p_progress_status_code, progress_status_code)
        ,progress_as_of_date            = Nvl(p_progress_as_of_date, progress_as_of_date)
        ,classification_code_id         = Nvl(p_classification_code,classification_code_id)
        ,reason_code_id                 = Nvl(p_reason_code,reason_code_id)
        ,RECORD_VERSION_NUMBER          = record_version_number +1
        ,project_id			= Nvl(p_project_id,project_id)
        ,LAST_MODIFICATION_DATE         = SYSDATE
        ,last_modified_by_id            = p_last_modified_by_id
        ,LAST_UPDATE_DATE               = p_last_update_date    --Modified for bug# 3877985
        ,LAST_UPDATED_BY                = p_last_updated_by     --Modified for bug# 3877985
        ,LAST_UPDATE_LOGIN              = p_last_update_login   --Modified for bug# 3877985
        ,object_type			= p_object_type
        ,object_id			= p_object_id
        ,ci_number                      = p_ci_number
        ,date_required                  = p_date_required
        ,date_closed                    = p_date_closed
        ,closed_by_id                   = p_closed_by_id
        ,description			= p_description
        ,status_overview                = p_status_overview
        ,resolution			= p_resolution
        ,resolution_code_id             = p_resolution_code
        ,priority_code			= p_priority_code
        ,effort_level_code              = p_effort_level_code
        ,open_action_num                = nvl(p_open_action_num,open_action_num)
        ,price				= p_price
        ,price_currency_code		= p_price_currency_code
        ,source_type_code		= p_source_type_code
        ,source_comment			= p_source_comment
        ,source_number			= p_source_number
        ,source_date_received		= p_source_date_received
        ,source_organization            = p_source_organization--, source_org_id)
        ,source_person   		= p_source_person --, source_person_id)

        ,attribute_category             = p_attribute_category--, attribute1)

        ,attribute1			= p_attribute1--, attribute1)
        ,attribute2			= p_attribute2-- , attribute2)
        ,attribute3                     = p_attribute3--, attribute3)
        ,attribute4                     = p_attribute4--, attribute4)
        ,attribute5                     = p_attribute5--, attribute5)
        ,attribute6                     = p_attribute6--, attribute6)
        ,attribute7                     = p_attribute7--, attribute7)
        ,attribute8                     = p_attribute8--, attribute8)
        ,attribute9                     = p_attribute9--, attribute9)
        ,attribute10                    = p_attribute10--, attribute10)
        ,attribute11                    = p_attribute11--, attribute11)
        ,attribute12                    = p_attribute12--, attribute12)
        ,attribute13                    = p_attribute13--, attribute13)
        ,attribute14                    = p_attribute14--, attribute14)
        ,attribute15                    = p_attribute15--, attribute15)
-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
        ,PCO_STATUS_CODE                = p_PCO_STATUS_CODE
        ,APPROVAL_TYPE_CODE             = p_APPROVAL_TYPE_CODE
        ,LOCKED_FLAG                    = p_LOCKED_FLAG
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

        --,Version_number                 = p_Version_number--, attribute15)
        --,Current_Version_flag           = p_Current_Version_flag--, attribute15)
        ,Version_Comments               = p_Version_Comments--, attribute15)
        --,Original_ci_id                 = p_Original_ci_id--, attribute15)
        --,Source_ci_id                   = p_Source_ci_id--, attribute15)
		,Change_approver                  = p_change_approver
where ci_id     = p_ci_id
    AND record_version_number = Nvl(p_record_version_number, record_version_number);

   if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_ROW;



procedure DELETE_ROW (
  p_ci_id                IN  NUMBER
  ,p_record_version_number       IN     NUMBER
  ,x_return_status               OUT    NOCOPY  VARCHAR2
  ,x_msg_count                   OUT    NOCOPY  NUMBER
  ,x_msg_data                    OUT    NOCOPY  VARCHAR2

) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  PA_CONTROL_ITEMS
    where ci_id = p_ci_id
      and record_version_number = p_record_version_number;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_ROW;

END  PA_CONTROL_ITEMS_PKG;

/
