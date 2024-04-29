--------------------------------------------------------
--  DDL for Package EGO_INV_ITEM_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_INV_ITEM_CATALOG_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOITCCS.pls 120.2 2006/09/20 14:54:51 ninaraya noship $ */

Procedure Change_Item_Lifecycle(
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_NEW_CATALOG_CATEGORY_ID     IN   NUMBER,
  P_NEW_LIFECYCLE_ID            IN   NUMBER,
  P_NEW_PHASE_ID                IN   NUMBER,
  P_NEW_ITEM_STATUS_CODE        IN   VARCHAR2,
  P_COMMIT                      IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER,
  X_MSG_DATA                    OUT  NOCOPY VARCHAR2
);

Procedure Change_Item_Catalog(
  P_INVENTORY_ITEM_ID           IN   NUMBER,
  P_ORGANIZATION_ID             IN   NUMBER,
  P_CATALOG_GROUP_ID            IN   NUMBER,
  P_NEW_CATALOG_GROUP_ID        IN   NUMBER,
  P_NEW_LIFECYCLE_ID            IN   NUMBER,
  P_NEW_PHASE_ID                IN   NUMBER,
  P_NEW_ITEM_STATUS_CODE        IN   VARCHAR2,
  P_NEW_APPROVAL_STATUS         IN   VARCHAR2 DEFAULT NULL,
  P_COMMIT                      IN   VARCHAR2,
  X_RETURN_STATUS               OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT  NOCOPY NUMBER,
  X_MSG_DATA                    OUT  NOCOPY VARCHAR2
);

Procedure Validate_And_Change_Item_LC (
    p_api_version          IN   NUMBER
   ,p_commit               IN   VARCHAR2
   ,p_inventory_item_id    IN   NUMBER
   ,p_item_revision_id     IN   NUMBER
   ,p_organization_id      IN   NUMBER
   ,p_fetch_curr_values    IN   VARCHAR2
   ,p_curr_cc_id           IN   NUMBER
   ,p_new_cc_id            IN   NUMBER
   ,p_is_new_cc_in_hier    IN   VARCHAR2
   ,p_curr_lc_id           IN   NUMBER
   ,p_new_lc_id            IN   NUMBER
   ,p_curr_lcp_id          IN   NUMBER
   ,p_new_lcp_id           IN   NUMBER
   ,p_change_id            IN   NUMBER
   ,p_change_line_id       IN   NUMBER
   ,x_return_status      OUT  NOCOPY  VARCHAR2
   ,x_msg_count          OUT  NOCOPY  NUMBER
   ,x_msg_data           OUT  NOCOPY  VARCHAR2
);

Procedure Change_Item_LC_Dependecies
    (p_api_version          IN   NUMBER
    ,p_inventory_item_id    IN   NUMBER
    ,p_organization_id      IN   NUMBER
    ,p_item_revision_id     IN   NUMBER
    ,p_lifecycle_id         IN   NUMBER
    ,p_lifecycle_phase_id   IN   NUMBER
    ,p_lifecycle_changed        IN VARCHAR2
    ,p_lifecycle_phase_changed  IN VARCHAR2
    ,p_perform_sync_only        IN VARCHAR2
    ,p_new_cc_in_hier           IN BOOLEAN := FALSE
    ,x_return_status      OUT  NOCOPY  VARCHAR2
    ,x_msg_count          OUT  NOCOPY  NUMBER
    ,x_msg_data           OUT  NOCOPY  VARCHAR2
    );

PROCEDURE Create_phase_History_Record (
   p_api_version              IN  NUMBER
  ,p_commit                   IN  VARCHAR2
  ,p_inventory_item_id        IN  NUMBER
  ,p_organization_id          IN  NUMBER
  ,p_revision_id              IN  NUMBER
  ,p_lifecycle_id             IN  VARCHAR2
  ,p_lifecycle_phase_id       IN  VARCHAR2
  ,p_item_status_code         IN  VARCHAR2
  ,x_return_status       OUT  NOCOPY  VARCHAR2
  ,x_msg_count           OUT  NOCOPY  NUMBER
  ,x_msg_data            OUT  NOCOPY  VARCHAR2
  );

PROCEDURE Check_pending_Change_Orders (
   p_inventory_item_id        IN  NUMBER
  ,p_organization_id          IN  NUMBER
  ,p_revision_id              IN  NUMBER
  ,p_lifecycle_changed        IN  VARCHAR2
  ,p_lifecycle_phase_changed  IN  VARCHAR2
  ,p_change_id                IN  NUMBER
  ,p_change_line_id           IN  NUMBER
  ,x_return_status       OUT  NOCOPY  VARCHAR2
  ,x_msg_count           OUT  NOCOPY  NUMBER
  ,x_msg_data            OUT  NOCOPY  VARCHAR2
  );

END EGO_INV_ITEM_CATALOG_PVT;

 

/
