--------------------------------------------------------
--  DDL for Package PA_CONTROL_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CONTROL_ITEMS_PKG" AUTHID CURRENT_USER AS
--$Header: PACICITS.pls 120.3.12010000.5 2010/05/06 11:59:15 rrambati ship $


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

        ,p_Version_number        IN number := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
        ,px_ci_id                IN OUT NOCOPY NUMBER
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
        ,p_orig_system_code      IN VARCHAR2 := NULL
        ,p_orig_system_reference IN VARCHAR2 := NULL
        ,p_change_approver       IN varchar2 DEFAULT NULL --Added for bug 9108474
);

procedure UPDATE_ROW (

        p_ci_id                IN  NUMBER
        ,p_ci_type_id           IN  NUMBER
        ,p_summary              IN  VARCHAR2
        ,p_status_code          IN  VARCHAR2
        ,p_owner_id             IN  NUMBER
        ,p_highlighted_flag     IN  VARCHAR2
        ,p_progress_status_code IN VARCHAR2
        ,p_progress_as_of_date  IN DATE
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

        ,p_Version_number        IN number   := null
        ,p_Current_Version_flag  IN varchar2 := 'Y'
        ,p_Version_Comments      IN varchar2 := NULL
        ,p_Original_ci_id        IN number := NULL
        ,p_Source_ci_id          IN number := NULL
		,p_change_approver       IN varchar2 := NULL
        ,x_return_status         OUT NOCOPY VARCHAR2
        ,x_msg_count             OUT NOCOPY NUMBER
        ,x_msg_data              OUT NOCOPY VARCHAR2
        ,p_last_updated_by 	 in NUMBER default fnd_global.user_id
        ,p_last_update_date 	 in DATE default sysdate
        ,p_last_update_login     in NUMBER default fnd_global.user_id
);

procedure DELETE_ROW (
  p_ci_id                IN  NUMBER
  ,p_record_version_number       IN     NUMBER
  ,x_return_status               OUT    NOCOPY VARCHAR2
  ,x_msg_count                   OUT    NOCOPY NUMBER
  ,x_msg_data                    OUT    NOCOPY VARCHAR2
);

END  PA_CONTROL_ITEMS_PKG;

/
