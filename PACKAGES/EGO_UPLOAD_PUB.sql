--------------------------------------------------------
--  DDL for Package EGO_UPLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_UPLOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOPUPLS.pls 120.0.12010000.2 2010/04/19 11:48:47 vijoshi ship $ */

Procedure sync_catalog_group (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group         IN  VARCHAR2
   ,p_parent_catalog_group  IN  VARCHAR2
   ,p_description           IN  VARCHAR2
   ,p_template_name         IN  VARCHAR2
   ,p_creation_allowed      IN  VARCHAR2
   ,p_end_date              IN  DATE
   ,p_owner                 IN  VARCHAR2
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_catalog_group_id      OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );

PROCEDURE sync_cat_attr_grp_assoc (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group_id      IN  NUMBER
   ,p_catalog_group         IN  VARCHAR2
   ,p_data_level            IN  VARCHAR2
   ,p_attr_group_name       IN  VARCHAR2
   ,p_attr_group_type       IN  VARCHAR2
   ,p_enabled_flag          IN  VARCHAR2
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_association_id        OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );

PROCEDURE sync_cat_item_pages (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group_id      IN  NUMBER
   ,p_catalog_group         IN  VARCHAR2
   ,p_data_level            IN  VARCHAR2
   ,p_page_int_name         IN  VARCHAR2
   ,p_name                  IN  VARCHAR2
   ,p_desc                  IN  VARCHAR2
   ,p_sequence              IN  NUMBER
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_page_id               OUT  NOCOPY NUMBER
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );

PROCEDURE sync_cat_item_page_entries (
    p_api_version           IN  NUMBER
   ,p_commit                IN  VARCHAR2
   ,p_catalog_group         IN  VARCHAR2
   ,p_page_id               IN  NUMBER
   ,p_page_int_name         IN  VARCHAR2
   ,p_attr_group_name       IN  VARCHAR2
   ,p_attr_group_type       IN  VARCHAR2
   ,p_sequence              IN  NUMBER
   ,p_association_id        IN  NUMBER
   ,p_extra_params          IN  EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
   ,x_return_status         OUT  NOCOPY VARCHAR2
   ,x_msg_count             OUT  NOCOPY NUMBER
   ,x_msg_data              OUT  NOCOPY VARCHAR2
   );


--- exposing procedure for PIM2PIM sync bug 9586226
---
PROCEDURE createBaseAttributePages (p_catalog_group_id IN NUMBER
                                    ,x_return_status    OUT NOCOPY VARCHAR2
                                    );
END EGO_UPLOAD_PUB;

/
