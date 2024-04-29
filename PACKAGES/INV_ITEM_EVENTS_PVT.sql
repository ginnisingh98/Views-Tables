--------------------------------------------------------
--  DDL for Package INV_ITEM_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVEVES.pls 120.4.12010000.2 2009/05/22 06:42:04 geguo ship $ */
-- ----------------------------------------------------------------------
--  API Name:        Raise Business Event
--
--  Type:            Private
--
--  Description:     Raise Business Event
--
-- Parameters:
--   IN:
--        p_commit               IN         BOOLEAN  DEFAULT FALSE
--        p_xset_id              IN         NUMBER   DEFAULT -999
--        p_request_id           IN         NUMBER   NULL
--        p_event_name           IN         VARCHAR2
--        p_dml_type             IN         VARCHAR2
--                                       {INSERT, UPDATE, DELETE, BULK}
--        p_inventory_item_id    IN         NUMBER   DEFAULT NULL
--        p_item_number          IN         VARCHAR2 DEFAULT NULL
--        p_organization_id      IN         NUMBER   DEFAULT NULL
--        p_organization_code    IN         VARCHAR2 DEFAULT NULL
--        p_revision_id          IN         NUMBER   DEFAULT NULL
--        p_item_description     IN         VARCHAR2 DEFAULT NULL
--        p_category_set_id      IN         NUMBER   DEFAULT NULL
--        p_category_id          IN         NUMBER   DEFAULT NULL
--        p_catalog_id           IN         NUMBER   DEFAULT NULL
--        p_attr_group_name      IN         VARCHAR2 DEFAULT NULL
--        p_extension_id         IN         NUMBER   DEFAULT NULL
--        p_manufacturer_id      IN         NUMBER   DEFAULT NULL
--        p_mfg_part_num         IN         VARCHAR2   DEFAULT NULL
--        p_cross_reference_type IN         VARCHAR2 DEFAULT NULL
--        p_cross_reference      IN         VARCHAR2 DEFAULT NULL
--        p_customer_item_id     IN         NUMBER   DEFAULT NULL
--        p_related_item_id      IN         NUMBER   DEFAULT NULL
--        p_relationship_type_id IN         NUMBER   DEFAULT NULL
--        p_role_id              IN         NUMBER   DEFAULT NULL
--        p_party_type           IN         VARCHAR2 DEFAULT NULL
--        p_party_id             IN         NUMBER   DEFAULT NULL
--        p_start_date           IN         DATE     DEFAULT NULL
--        p_category_name        IN         VARCHAR2 DEFAULT NULL

--
--  OUT:
--  Removed the out parameters as we make this call inside
--  a nested block and exceptions are not required to be
--  handled there
-- ----------------------------------------------------------------------

Procedure Raise_Events (
       p_commit               IN         BOOLEAN  DEFAULT FALSE
      ,p_xset_id              IN         NUMBER   DEFAULT -999
      ,p_request_id           IN         NUMBER   DEFAULT NULL
      ,p_event_name           IN         VARCHAR2 DEFAULT NULL
      ,p_dml_type             IN         VARCHAR2
      ,p_inventory_item_id    IN         NUMBER   DEFAULT NULL
      ,p_item_number          IN         VARCHAR2 DEFAULT NULL
      ,p_organization_id      IN         NUMBER   DEFAULT NULL
      ,p_organization_code    IN         VARCHAR2 DEFAULT NULL
      ,p_revision_id          IN         NUMBER   DEFAULT NULL
      ,p_item_description     IN         VARCHAR2 DEFAULT NULL
      ,p_category_set_id      IN         NUMBER   DEFAULT NULL
      ,p_category_id          IN         NUMBER   DEFAULT NULL
      ,p_old_category_id      IN         NUMBER   DEFAULT NULL--add by geguo 8351807
      ,p_catalog_id           IN         NUMBER   DEFAULT NULL
      ,p_attr_group_name      IN         VARCHAR2 DEFAULT NULL
      ,p_extension_id         IN         NUMBER   DEFAULT NULL
      ,p_manufacturer_id      IN         NUMBER   DEFAULT NULL
      ,p_mfg_part_num         IN         VARCHAR2 DEFAULT NULL
      ,p_cross_reference_type IN         VARCHAR2 DEFAULT NULL
      ,p_cross_reference      IN         VARCHAR2 DEFAULT NULL
      ,p_customer_item_id     IN         NUMBER   DEFAULT NULL
      ,p_related_item_id      IN         NUMBER   DEFAULT NULL
      ,p_relationship_type_id IN         NUMBER   DEFAULT NULL
      ,p_role_id              IN         NUMBER   DEFAULT NULL
      ,p_party_type           IN         VARCHAR2 DEFAULT NULL
      ,p_party_id             IN         NUMBER   DEFAULT NULL
      ,p_start_date           IN         DATE     DEFAULT NULL
      ,p_category_name        IN         VARCHAR2 DEFAULT NULL);


-- ----------------------------------------------------------------------
--  API Name:        Call ICX APIs
--
--  Type:            Private
--
--  Description:     Call ICX APIs
--
-- Parameters:
--   IN:
--        p_commit            IN         BOOLEAN  DEFAULT FALSE
--        p_xset_id           IN         NUMBER   DEFAULT -999
--        p_request_id        IN         NUMBER   NULL
--        p_entity_type       IN         VARCHAR2
--                                       {'ITEM','ITEM_CATEGORY'
--                                        'CATEGORY','VALID_CATEGORY'}
--        p_dml_type          IN         VARCHAR2
--                                       {'CREATE', 'UPDATE',
--                                        'DELETE', 'BULK'}
--        p_inventory_item_id IN         NUMBER   DEFAULT NULL
--        p_item_number       IN         VARCHAR2 DEFAULT NULL
--        p_organization_id   IN         NUMBER   DEFAULT NULL
--        p_organization_code IN         VARCHAR2 DEFAULT NULL
--        p_master_org_flag   IN         VARCHAR2 DEFAULT NULL
--                                       {'Y', 'N'}
--        p_item_description  IN         VARCHAR2 DEFAULT NULL
--        p_category_set_id   IN         NUMBER   DEFAULT NULL
--        p_category_id       IN         NUMBER   DEFAULT NULL
--	  p_old_category_id   IN         NUMBER   DEFAULT NULL
--        p_category_name     IN         VARCHAR2 DEFAULT NULL
--        p_structure_id      IN         NUMBER   DEFAULT NULL
--
--  OUT:
--  Removed the out parameters as we make this call inside
--  a nested block and exceptions are not required to be
--  handled there
--
-- ----------------------------------------------------------------------

Procedure Invoke_ICX_APIs (
		    p_commit            IN         BOOLEAN  DEFAULT FALSE
         ,p_xset_id           IN         NUMBER   DEFAULT -999
		   ,p_request_id        IN         NUMBER   DEFAULT NULL
		   ,p_entity_type       IN         VARCHAR2 DEFAULT NULL
		   ,p_dml_type          IN         VARCHAR2
		   ,p_inventory_item_id IN         NUMBER   DEFAULT NULL
		   ,p_item_number       IN         VARCHAR2 DEFAULT NULL
		   ,p_organization_id   IN         NUMBER   DEFAULT NULL
		   ,p_organization_code IN         VARCHAR2 DEFAULT NULL
		   ,p_master_org_flag   IN         VARCHAR2 DEFAULT NULL
		   ,p_item_description  IN         VARCHAR2 DEFAULT NULL
		   ,p_category_set_id   IN         NUMBER   DEFAULT NULL
		   ,p_category_id       IN         NUMBER   DEFAULT NULL
		   ,p_old_category_id   IN         NUMBER   DEFAULT NULL
		   ,p_category_name     IN         VARCHAR2 DEFAULT NULL
		   ,p_structure_id      IN         NUMBER   DEFAULT NULL);


-- ----------------------------------------------------------------------
--  API Name:        Call ICX APIs
--
--  Type:            Private
--
--  Description:     Wrapper on Invoke_ICX_APIs. This procedure just
--                   converts the p_commit INT parameter to boolean
--                   Added so that p_commit can be passed from java layer
--                   INTEGER p_commit = 1 >> TRUE = p_commit BOOLEAN
--
--  Parameters:      Same as Invoke_ICX_APIs except p_commit is INTEGER

Procedure Invoke_ICX_wrapper (
		    p_commit            IN         INTEGER  DEFAULT 1
                   ,p_xset_id           IN         NUMBER   DEFAULT -999
		   ,p_request_id        IN         NUMBER   DEFAULT NULL
		   ,p_entity_type       IN         VARCHAR2 DEFAULT NULL
		   ,p_dml_type          IN         VARCHAR2
		   ,p_inventory_item_id IN         NUMBER   DEFAULT NULL
		   ,p_item_number       IN         VARCHAR2 DEFAULT NULL
		   ,p_organization_id   IN         NUMBER   DEFAULT NULL
		   ,p_organization_code IN         VARCHAR2 DEFAULT NULL
		   ,p_master_org_flag   IN         VARCHAR2 DEFAULT NULL
		   ,p_item_description  IN         VARCHAR2 DEFAULT NULL
		   ,p_category_set_id   IN         NUMBER   DEFAULT NULL
		   ,p_category_id       IN         NUMBER   DEFAULT NULL
		   ,p_old_category_id   IN         NUMBER   DEFAULT NULL
		   ,p_category_name     IN         VARCHAR2 DEFAULT NULL
		   ,p_structure_id      IN         NUMBER   DEFAULT NULL);


-- -------------------------------------------------------------------------
--  API Name:        Sync IP Intermedia Index
--
--  Type:            Private
--
--  Description:     Calls IProcurement Intermedia index rebuild after
--                   commiting as it is a DDL.
-----------------------------------------------------------------------------

Procedure Sync_IP_IM_Index;


Procedure Invoke_JAI_API(
        p_action_type                IN    VARCHAR2
       ,p_organization_id            IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
       ,p_inventory_item_id          IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
       ,p_source_organization_id     IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
       ,p_source_inventory_item_id   IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
       ,p_set_process_id             IN    NUMBER
       ,p_called_from                IN    VARCHAR2);

--Bug: 4880971
 Procedure Invoke_JG_ZZ_API(
       p_organization_id             IN   MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
      ,p_country_code                OUT NOCOPY VARCHAR2
      ,p_product_code                OUT NOCOPY VARCHAR2);

END INV_ITEM_EVENTS_PVT;

/
