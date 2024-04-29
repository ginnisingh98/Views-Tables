--------------------------------------------------------
--  DDL for Package EGO_LIFECYCLE_USER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_LIFECYCLE_USER_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPLCUS.pls 120.2 2007/05/30 10:47:53 srajapar ship $ */

FUNCTION get_change_name  (p_change_id  IN   NUMBER) return VARCHAR2;

PROCEDURE Check_Delete_Project_OK
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_init_msg_list           IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , x_delete_ok               OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Policy_For_Revise
(
     p_api_version             IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_curr_phase_id           IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);


PROCEDURE Get_Policy_For_Phase_Change
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER   DEFAULT NULL
   , p_inventory_item_id       IN      NUMBER   DEFAULT NULL
   , p_organization_id         IN      NUMBER   DEFAULT NULL
   , p_curr_phase_id           IN      NUMBER
   , p_future_phase_id         IN      NUMBER
   , p_phase_change_code       IN      VARCHAR2
   , p_lifecycle_id            IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Get_Policy_For_Phase_Change
(
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_curr_phase_id           IN      NUMBER
   , p_future_phase_id         IN      NUMBER
   , p_phase_change_code       IN      VARCHAR2
   , p_lifecycle_id            IN      NUMBER
   , x_policy_code             OUT     NOCOPY VARCHAR2
   , x_error_message           OUT     NOCOPY VARCHAR2
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);


PROCEDURE Check_Lc_Tracking_Project
 (
     p_api_version             IN     NUMBER
   , p_project_id              IN     NUMBER
   , x_is_lifecycle_tracking   OUT    NOCOPY VARCHAR2
   , x_return_status           OUT    NOCOPY VARCHAR2
   , x_errorcode               OUT    NOCOPY NUMBER
   , x_msg_count               OUT    NOCOPY NUMBER
   , x_msg_data                OUT    NOCOPY VARCHAR2
);

PROCEDURE Delete_All_Item_Assocs
 (
     p_api_version             IN     NUMBER
   , p_project_id              IN     NUMBER
   , p_commit                  IN     VARCHAR2   DEFAULT FND_API.G_FALSE
   , x_return_status           OUT    NOCOPY VARCHAR2
   , x_errorcode               OUT    NOCOPY NUMBER
   , x_msg_count               OUT    NOCOPY NUMBER
   , x_msg_data                OUT    NOCOPY VARCHAR2
);

PROCEDURE Sync_Phase_Change
 (
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_lifecycle_id            IN      NUMBER
   , p_phase_id                IN      NUMBER
   , p_effective_date          IN      DATE
   , p_init_msg_list           IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Sync_Phase_Change
 (
     p_api_version             IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_revision                IN      VARCHAR2   DEFAULT NULL
   , p_lifecycle_id            IN      NUMBER
   , p_phase_id                IN      NUMBER
   , p_effective_date          IN      DATE
   , p_init_msg_list           IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2   DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);


PROCEDURE Create_Project_Item_Assoc
 (
     p_api_version             IN      NUMBER
   , p_project_id              IN      NUMBER
   , p_organization_id         IN      NUMBER
   , p_inventory_item_id       IN      NUMBER
   , p_revision                IN      VARCHAR2  DEFAULT NULL
   , p_revision_id             IN      NUMBER    DEFAULT NULL
   , p_task_id                 IN      NUMBER    DEFAULT NULL
   , p_association_type        IN      VARCHAR2
   , p_association_code        IN      VARCHAR2
   , p_organization_specific   IN      VARCHAR2  DEFAULT FND_API.G_FALSE
                                                          -- Currently not used
   , p_check_privileges        IN      VARCHAR2  DEFAULT FND_API.G_TRUE
   , p_init_msg_list           IN      VARCHAR2  DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2  DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY VARCHAR2
   , x_errorcode               OUT     NOCOPY NUMBER
   , x_msg_count               OUT     NOCOPY NUMBER
   , x_msg_data                OUT     NOCOPY VARCHAR2
);

PROCEDURE Copy_Project
(
     p_api_version             IN      NUMBER
   , p_init_msg_list           IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_commit                  IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , p_source_item_id          IN      NUMBER
   , p_source_org_id           IN      NUMBER
   , p_source_rev_id           IN      NUMBER
   , p_association_type        IN      VARCHAR2
   , p_association_code        IN      VARCHAR2
   , p_dest_item_id            IN      NUMBER
   , p_dest_org_id             IN      NUMBER
   , p_dest_rev_id             IN      NUMBER
   , p_check_privileges        IN      VARCHAR2 DEFAULT FND_API.G_FALSE
   , x_return_status           OUT     NOCOPY  VARCHAR2
   , x_error_code              OUT     NOCOPY  NUMBER
   , x_msg_count               OUT     NOCOPY  NUMBER
   , x_msg_data                OUT     NOCOPY  VARCHAR2
);

PROCEDURE Copy_Item_Assocs
(
      p_api_version            IN      NUMBER
     ,p_project_id_from        IN      NUMBER
     ,p_project_id_to          IN      NUMBER
     ,p_init_msg_list          IN      VARCHAR2   DEFAULT FND_API.G_FALSE
     ,p_commit                 IN      VARCHAR2   DEFAULT FND_API.G_FALSE
     ,x_return_status          OUT     NOCOPY VARCHAR2
     ,x_errorcode              OUT     NOCOPY NUMBER
     ,x_msg_count              OUT     NOCOPY NUMBER
     ,x_msg_data               OUT     NOCOPY VARCHAR2
);

FUNCTION Has_LC_Tracking_Project (
      p_organization_id         IN      NUMBER
    , p_inventory_item_id       IN      NUMBER
    , p_revision                IN      VARCHAR2   DEFAULT NULL
) RETURN VARCHAR2;

END EGO_LIFECYCLE_USER_PUB;


/
