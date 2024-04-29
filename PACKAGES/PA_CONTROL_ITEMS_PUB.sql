--------------------------------------------------------
--  DDL for Package PA_CONTROL_ITEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_ITEMS_PUB" AUTHID CURRENT_USER AS
--$Header: PACICIPS.pls 120.1.12010000.4 2009/07/23 22:56:02 cklee ship $


procedure ADD_CONTROL_ITEM (
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

        ,p_Version_number        IN number default null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
        ,px_ci_id                IN OUT NOCOPY NUMBER
        ,x_ci_number             OUT NOCOPY VARCHAR2
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
);


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

        ,p_Version_number        IN number  := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
		,p_change_approver       IN varchar2 :=NULL
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2

);

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
);
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
);


procedure COPY_CONTROL_ITEM (
         p_api_version            IN     NUMBER :=  1.0
        ,p_init_msg_list          IN     VARCHAR2 := fnd_api.g_true
        ,p_commit                 IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only          IN     VARCHAR2 := FND_API.g_true
        ,p_max_msg_count          IN     NUMBER := FND_API.g_miss_num

        ,p_project_id             IN  NUMBER
        ,p_ci_id_from             IN  NUMBER
        ,p_ci_type_id             IN  NUMBER
        ,p_classification_code_id IN  NUMBER
        ,p_reason_code_id         IN  NUMBER
        ,p_include              IN  VARCHAR2 := 'N'
        ,p_record_version_number_from  IN NUMBER
        ,x_ci_id                       OUT NOCOPY NUMBER
        ,x_ci_number                   OUT NOCOPY VARCHAR2
        ,x_return_status               OUT NOCOPY    VARCHAR2
        ,x_msg_count                   OUT NOCOPY    NUMBER
        ,x_msg_data                    OUT NOCOPY    VARCHAR2

);

function GET_OBJECT_NAME(p_object_id IN  NUMBER
        ,p_object_type   IN VARCHAR2
) return VARCHAR2;

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
);
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676


END  PA_CONTROL_ITEMS_PUB;

/
