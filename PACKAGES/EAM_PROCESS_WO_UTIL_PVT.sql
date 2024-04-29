--------------------------------------------------------
--  DDL for Package EAM_PROCESS_WO_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PROCESS_WO_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVPWUS.pls 120.1.12000000.1 2007/01/16 09:46:51 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVPWUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_PROCESS_WO_UTIL_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-OCT-2003    Basanth Roy     Initial Creation
***************************************************************************/


      PROCEDURE create_requisition
        (  p_api_version                 IN    NUMBER        := 1.0
          ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
          ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
          ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
          ,x_return_status               OUT NOCOPY   VARCHAR2
          ,x_msg_count                   OUT NOCOPY   NUMBER
          ,x_msg_data                    OUT NOCOPY   VARCHAR2
          ,p_wip_entity_id               IN    NUMBER        -- data
          ,p_operation_seq_num           IN    NUMBER
          ,p_organization_id             IN    NUMBER
          ,p_user_id                     IN    NUMBER
          ,p_responsibility_id           IN    NUMBER
          ,p_quantity                    IN    NUMBER
          ,p_unit_price                  IN    NUMBER
          ,p_category_id                 IN    NUMBER
          ,p_item_description            IN    VARCHAR2
          ,p_uom_code                    IN    VARCHAR2
          ,p_need_by_date                IN    DATE
          ,p_inventory_item_id           IN    NUMBER
          ,p_direct_item_id              IN    NUMBER
          ,p_suggested_vendor_id         IN    NUMBER
          ,p_suggested_vendor_name       IN    VARCHAR2
          ,p_suggested_vendor_site       IN    VARCHAR2
          ,p_suggested_vendor_phone      IN    VARCHAR2
          ,p_suggested_vendor_item_num   IN    VARCHAR2) ;


     PROCEDURE create_reqs_at_wo_rel
        (  p_api_version                 IN    NUMBER        := 1.0
          ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
          ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
          ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
          ,x_return_status               OUT NOCOPY   VARCHAR2
          ,x_msg_count                   OUT NOCOPY   NUMBER
          ,x_msg_data                    OUT NOCOPY   VARCHAR2
          ,p_user_id                     IN  NUMBER
          ,p_responsibility_id           IN  NUMBER
          ,p_wip_entity_id               IN    NUMBER        -- data
          ,p_organization_id             IN    NUMBER);


     PROCEDURE create_reqs_at_di_upd
        (  p_api_version                 IN    NUMBER        := 1.0
          ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
          ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
          ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
          ,x_return_status               OUT NOCOPY   VARCHAR2
          ,x_msg_count                   OUT NOCOPY   NUMBER
          ,x_msg_data                    OUT NOCOPY   VARCHAR2
          ,p_user_id                     IN  NUMBER
          ,p_responsibility_id           IN  NUMBER
          ,p_wip_entity_id               IN    NUMBER        -- data
          ,p_organization_id             IN    NUMBER
          ,p_direct_item_sequence_id     IN    NUMBER
          ,p_inventory_item_id           IN    NUMBER
          ,p_required_quantity           IN    NUMBER);


END EAM_PROCESS_WO_UTIL_PVT;

 

/
