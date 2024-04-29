--------------------------------------------------------
--  DDL for Package Body INV_ITEM_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_EVENTS_PVT" AS
/* $Header: INVVEVEB.pls 120.12.12010000.3 2009/06/22 03:29:34 iyin ship $ */

------------------------------------------------------------------------
--Package for debugging purposes
------------------------------------------------------------------------
  procedure insert_log(msg varchar2,dt date:=SYSDATE) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
  --  INSERT INTO LUX_events(event_name) VALUES(MSG);
  --    COMMIT;
  NULL;
  END INSERT_LOG;

-- ----------------------------------------------------------------------
--  API Name:        Get organization info
--
--  Type:            Private
--
--  Description:     Get orgnization Code and Master Org Flag
-------------------------------------------------------------------------
Procedure get_Org_Info(
         p_organization_id   IN  NUMBER
        ,x_organization_code OUT NOCOPY VARCHAR2
        ,x_master_org_flag   OUT NOCOPY VARCHAR2) IS
BEGIN
   SELECT DECODE(master_organization_id, p_organization_id, 'Y', 'N'),
           organization_code
    INTO   x_master_org_flag,
           x_organization_code
    FROM MTL_PARAMETERS
    WHERE organization_id = p_organization_id;

END get_Org_Info;


-- ----------------------------------------------------------------------
--  API Name:        Get item info
--
--  Type:            Private
--
--  Description:     Get Item name and description
-------------------------------------------------------------------------

Procedure get_Item_Info(
           p_inventory_item_id IN  NUMBER
          ,p_organization_id   IN  NUMBER
          ,x_item_description  OUT NOCOPY VARCHAR2
          ,x_item_number       OUT NOCOPY VARCHAR2) IS
BEGIN
   SELECT CONCATENATED_SEGMENTS, DESCRIPTION
   INTO   x_item_number, x_item_description
   FROM MTL_SYSTEM_ITEMS_KFV
   WHERE inventory_item_id = p_inventory_item_id
     AND organization_id   = p_organization_id;
END get_Item_Info;

-- ----------------------------------------------------------------------
--  API Name:        Get Category info
--
--  Type:            Private
--
--  Description:     Get Category Name
-------------------------------------------------------------------------

Procedure get_Category_Info(
           p_category_id    IN  NUMBER
          ,x_category_name  OUT NOCOPY VARCHAR2) IS
BEGIN
   SELECT CONCATENATED_SEGMENTS
   INTO   x_category_name
   FROM   MTL_CATEGORIES_KFV
   WHERE category_id = p_category_id;

END get_Category_Info;


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
--        p_mfg_part_num         IN         VARCHAR2 DEFAULT NULL
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
    ,p_old_category_id      IN         NUMBER   DEFAULT NULL--add 8310065 with base bug 8351807
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
    ,p_category_name        IN         VARCHAR2 DEFAULT NULL) IS

/* Cursors to check if a concurrent request resulted in atleast one
   update to the tables by checking the records with process_flag=7 */

    CURSOR c_raise_item_change_event(cp_request_id NUMBER
                                    ,cp_xset_id    NUMBER) IS
       SELECT 'x' FROM dual
       WHERE EXISTS( SELECT NULL
                     FROM   mtl_system_items_interface
                     WHERE  set_process_id   = cp_xset_id
                     AND    process_flag     = 7
                     AND    request_id       = cp_request_id
                     AND    transaction_type in ('UPDATE','CREATE'));

    CURSOR c_raise_revision_event(cp_request_id NUMBER
                                 ,cp_xset_id    NUMBER) IS
       SELECT 'x' FROM dual
       WHERE EXISTS(SELECT NULL
                    FROM   mtl_item_revisions_interface
                    WHERE  set_process_id   = cp_xset_id
                    AND    process_flag     = 7
                    AND    request_id       = cp_request_id);

    CURSOR c_raise_item_categories_event(cp_request_id NUMBER
                                        ,cp_xset_id    NUMBER) IS
       SELECT 'x' FROM dual
       WHERE EXISTS(SELECT NULL
                    FROM   mtl_item_categories_interface
                    WHERE  set_process_id   = cp_xset_id
                    AND    process_flag     = 7
                    AND    request_id       = cp_request_id);

   l_msg_data          VARCHAR2(2000);
   l_raise_event       VARCHAR2(1);
   l_ret_status        VARCHAR2(1);
   l_organization_code VARCHAR2(2000);
   l_item_description  VARCHAR2(2000);
   l_item_number       VARCHAR2(2000);
   l_category_name     VARCHAR2(2000);
   l_master_org_flag   VARCHAR2(1);
   l_item_entity_bus_event VARCHAR2(1);
   l_is_master_attr_modified VARCHAR2(1) := INV_ITEM_PVT.Get_Is_Master_Attr_Modified ;
   /*Bug 6407303 Added the attribute to get whether teh master attribute is modified */

BEGIN
     CASE
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT' AND
             EGO_WF_WRAPPER_PVT.Get_PostAml_Change_Event = FND_API.g_true
        THEN
           EXECUTE IMMEDIATE
           'BEGIN                                                          '||
           '  EGO_WF_WRAPPER_PVT.Raise_AML_Event(                          '||
           '  p_event_name        => EGO_WF_WRAPPER_PVT.G_AML_CHANGE_EVENT '||
           ' ,p_dml_type          => :p_dml_type                           '||
           ' ,p_Inventory_Item_Id => :p_inventory_item_id                  '||
           ' ,p_Organization_Id   => :p_organization_id                    '||
           ' ,p_Manufacturer_Id   => :p_manufacturer_id                    '||
           ' ,p_Mfg_Part_Num      => :p_mfg_part_num                       '||
           ' ,x_msg_data          => :l_msg_data                           '||
           ' ,x_return_status     => :l_ret_status);                       '||
           'END;'
           USING  IN p_dml_type,
                  IN p_inventory_item_id,
                  IN p_organization_id,
                  IN p_manufacturer_id,
                  IN p_mfg_part_num,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_APPROVED_EVENT' THEN
           EXECUTE IMMEDIATE
           'BEGIN                                                          '||
           '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                         '||
           '  p_event_name     => EGO_WF_WRAPPER_PVT.G_ITEM_APPROVED_EVENT '||
           ' ,p_Inventory_Item_Id => :p_inventory_item_id                  '||
           ' ,p_Organization_Id   => :p_organization_id                    '||
           ' ,x_msg_data          => :l_msg_data                           '||
           ' ,x_return_status     => :l_ret_status);                       '||
           'END;'
           USING  IN p_inventory_item_id,
                  IN p_organization_id,
                 OUT l_msg_data,
                 OUT l_ret_status;

        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT' AND
             EGO_WF_WRAPPER_PVT.Get_Rev_Change_Bus_Event = FND_API.g_true
        THEN
           IF p_request_id IS NOT NULL THEN
              OPEN c_raise_revision_event(p_request_id, p_xset_id);
              FETCH c_raise_revision_event INTO l_raise_event;
              CLOSE c_raise_revision_event;
           END IF;
           IF p_request_id IS NULL OR l_raise_event = 'x' THEN
              EXECUTE IMMEDIATE
              'BEGIN                                                       '||
              '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                      '||
              '  p_event_name     => EGO_WF_WRAPPER_PVT.G_REV_CHANGE_EVENT '||
              ' ,p_dml_type          => :p_dml_type                        '||
              ' ,p_Inventory_Item_Id => :p_inventory_item_id               '||
              ' ,p_Organization_Id   => :p_organization_id                 '||
              ' ,p_Revision_id       => :p_revision_id                     '||
              ' ,p_request_id        => :p_request_id                      '||
              ' ,x_msg_data          => :l_msg_data                        '||
              ' ,x_return_status     => :l_ret_status);                    '||
              'END;'
              USING  IN p_dml_type,
                     IN p_inventory_item_id,
                     IN p_organization_id,
                     IN p_revision_id,
		     IN p_request_id,
                    OUT l_msg_data,
                    OUT l_ret_status;
           END IF;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT' THEN
           -- Populate Item and Orgnanization Information
           get_Org_Info(
               p_organization_id   => p_organization_id
              ,x_organization_code => l_organization_code
              ,x_master_org_flag   => l_master_org_flag);
           get_Item_Info(
               p_inventory_item_id
              ,p_organization_id
              ,l_item_description
              ,l_item_number);
           -- Populate Item and Orgnanization Information

           EXECUTE IMMEDIATE
           'BEGIN                                                           '||
           '  EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(            '||
           '  p_event_name        => EGO_WF_WRAPPER_PVT.G_ITEM_UPDATE_EVENT '||
           ' ,p_request_id        => :p_request_id                          '||
           ' ,p_Organization_Id   => :p_organization_id                     '||
           ' ,p_organization_code => :l_organization_code                   '||
           ' ,p_Inventory_Item_Id => :p_inventory_item_id                   '||
           ' ,p_item_number       => :l_item_number                         '||
           ' ,p_item_description  => :l_item_description                    '||
	   ' ,p_is_master_attr_modified  => :l_is_master_attr_modified      '|| /* Added for bug 6407303*/
           ' ,x_msg_data          => :l_msg_data                            '||
           ' ,x_return_status     => :l_ret_status);                        '||
           'END;'
           USING  IN p_request_id,
                  IN p_organization_id,
                  IN l_organization_code,
                  IN p_inventory_item_id,
                  IN l_item_number,
                  IN l_item_description,
		  IN l_is_master_attr_modified,  /* Added for bug 6407303*/
                 OUT l_msg_data,
                 OUT l_ret_status;
	INV_ITEM_PVT.Set_Is_Master_Attr_Modified('N'); /*Added for bug 6407303*/
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT' THEN
           -- Populate Item and Orgnanization Information
           get_Org_Info(
               p_organization_id   => p_organization_id
              ,x_organization_code => l_organization_code
              ,x_master_org_flag   => l_master_org_flag);
           get_Item_Info(
               p_inventory_item_id
              ,p_organization_id
              ,l_item_description
              ,l_item_number);
           -- Populate Item and Orgnanization Information

           EXECUTE IMMEDIATE
           'BEGIN                                                           '||
           '  EGO_WF_WRAPPER_PVT.Raise_Item_Create_Update_Event(            '||
           '  p_event_name        => EGO_WF_WRAPPER_PVT.G_ITEM_CREATE_EVENT '||
           ' ,p_request_id        => :p_request_id                          '||
           ' ,p_Organization_Id   => :p_organization_id                     '||
           ' ,p_organization_code => :l_organization_code                   '||
           ' ,p_Inventory_Item_Id => :p_inventory_item_id                   '||
           ' ,p_item_number       => :l_item_number                         '||
           ' ,p_item_description  => :l_item_description                    '||
           ' ,x_msg_data          => :l_msg_data                            '||
           ' ,x_return_status     => :l_ret_status);                        '||
           'END;'
           USING  IN p_request_id,
                  IN p_organization_id,
                  IN l_organization_code,
                  IN p_inventory_item_id,
                  IN l_item_number,
                  IN l_item_description,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT' AND
             EGO_WF_WRAPPER_PVT.Get_Category_Assign_Bus_Event = FND_API.g_true
        THEN
           IF p_request_id IS NOT NULL THEN
              OPEN  c_raise_item_categories_event(p_request_id, p_xset_id );
              FETCH c_raise_item_categories_event INTO l_raise_event;
              CLOSE c_raise_item_categories_event;
           END IF;
           IF p_request_id IS NULL OR l_raise_event = 'x' THEN
              EXECUTE IMMEDIATE
              'BEGIN  '||
              '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                       '||
              '  p_event_name => EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT '||
              ' ,p_dml_type          => :p_dml_type                         '||
              ' ,p_request_id        => :p_request_id                       '||
              ' ,p_Inventory_Item_Id => :p_inventory_item_id                '||
              ' ,p_Organization_Id   => :p_organization_id                  '||
              ' ,p_catalog_id        => :p_category_set_id                  '||
              ' ,p_category_id       => :p_category_id                      '||
              ' ,p_old_category_id   => :p_old_category_id                  '||--add 8310065 with base bug 8351807
              ' ,x_msg_data          => :l_msg_data                         '||
              ' ,x_return_status     => :l_ret_status);                     '||
              'END;'
              USING  IN p_dml_type,
                     IN p_request_id,
                     IN p_inventory_item_id,
                     IN p_organization_id,
                     IN p_category_set_id,
                     IN p_category_id,
                     IN p_old_category_id,--add 8310065 with base bug 8351807
                    OUT l_msg_data,
                    OUT l_ret_status;
           END IF;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_PRE_ATTR_CHANGE_EVENT' THEN
          NULL;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_GTIN_ATTR_CHANGE_EVENT' THEN
          NULL;

        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_Xref_CHANGE_EVENT' THEN
           EXECUTE IMMEDIATE
           'BEGIN                                                          '||
           '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                         '||
           '  p_event_name       => EGO_WF_WRAPPER_PVT.G_Xref_CHANGE_EVENT '||
           ' ,p_dml_type             => :p_dml_type                        '||
           ' ,p_Inventory_Item_Id    => :p_inventory_item_id               '||
           ' ,p_Organization_Id      => :p_organization_id                 '||
           ' ,p_cross_reference_type => :p_cross_reference_type            '||
           ' ,p_cross_reference      => :p_cross_reference                 '||
           ' ,x_msg_data             => :l_msg_data                        '||
           ' ,x_return_status        => :l_ret_status);                    '||
           'END;'
           USING  IN p_dml_type,
                  IN p_inventory_item_id,
                  IN p_organization_id,
                  IN p_cross_reference_type,
                  IN p_cross_reference,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_CUST_ITEM_XREF_CHANGE_EVENT' THEN
           NULL;
      /* Commenting the call to hide the event
         EXECUTE IMMEDIATE
         'BEGIN  '||
         '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                         '||
         '  p_event_name => EGO_WF_WRAPPER_PVT.G_CUST_ITEM_XREF_CHANGE_EVENT '||
         ' ,p_dml_type          => :p_dml_type                           '||
         ' ,p_Inventory_Item_Id => :p_inventory_item_id                  '||
         ' ,p_Organization_Id   => :p_organization_id                    '||
         ' ,p_customer_item_id  => :p_customer_item_id                   '||
         ' ,x_msg_data          => :l_msg_data                           '||
         ' ,x_return_status     => :l_ret_status);                       '||
         'END;'
         USING  IN p_dml_type,
                IN p_inventory_item_id,
                IN p_organization_id,
                IN p_customer_item_id,
               OUT l_msg_data,
               OUT l_ret_status;
      */

        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_REL_ITEM_CHANGE_EVENT' THEN
           NULL;
      /* Commenting the call to hide the event
         EXECUTE IMMEDIATE
         'BEGIN  '||
         '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                         '||
         '  p_event_name   => EGO_WF_WRAPPER_PVT.G_REL_ITEM_CHANGE_EVENT '||
         ' ,p_dml_type             => :p_dml_type                        '||
         ' ,p_Inventory_Item_Id    => :p_inventory_item_id               '||
         ' ,p_Organization_Id      => :p_organization_id                 '||
         ' ,p_related_item_id      => :p_related_item_id                 '||
         ' ,p_relationship_type_id => :p_relationship_type_id            '||
         ' ,x_msg_data             => :l_msg_data                        '||
         ' ,x_return_status        => :l_ret_status);                    '||
         'END;'
         USING  IN p_dml_type,
                IN p_inventory_item_id,
                IN p_organization_id,
                IN p_related_item_id,
                IN p_relationship_type_id,
               OUT l_msg_data,
               OUT l_ret_status;
     */

        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_ROLE_CHANGE_EVENT' THEN
           EXECUTE IMMEDIATE
           'BEGIN  '||
           '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                         '||
           '  p_event_name  => EGO_WF_WRAPPER_PVT.G_ITEM_ROLE_CHANGE_EVENT '||
           ' ,p_dml_type          => :p_dml_type                           '||
           ' ,p_Inventory_Item_Id => :p_inventory_item_id                  '||
           ' ,p_Organization_Id   => :p_organization_id                    '||
           ' ,p_role_id           => :p_role_id                            '||
           ' ,p_party_type        => :p_party_type                         '||
           ' ,p_party_id          => :p_party_id                           '||
           ' ,p_start_date        => :p_start_date                         '||
           ' ,x_msg_data          => :l_msg_data                           '||
           ' ,x_return_status     => :l_ret_status);                       '||
           'END;'
           USING  IN p_dml_type,
                  IN p_inventory_item_id,
                  IN p_organization_id,
                  IN p_role_id,
                  IN p_party_type,
                  IN p_party_id,
                  IN p_start_date,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_VALID_CAT_CHANGE_EVENT' THEN
           EXECUTE IMMEDIATE
           'BEGIN                                                          '||
           '  EGO_WF_WRAPPER_PVT.Raise_Categories_Event(                   '||
           '  p_event_name  => EGO_WF_WRAPPER_PVT.G_VALID_CHANGE_EVENT     '||
           ' ,p_dml_type          => :p_dml_type                           '||
           ' ,p_category_set_id   => :p_category_set_id                    '||
           ' ,p_category_id       => :p_category_id                        '||
           ' ,x_msg_data          => :l_msg_data                           '||
           ' ,x_return_status     => :l_ret_status);                       '||
           'END;'
           USING  IN p_dml_type,
                  IN p_category_set_id,
                  IN p_category_id,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_CAT_CATEGORY_CHANGE_EVENT' THEN
            -- Populate Category Information
            get_category_info(
                p_category_id   => p_category_id
               ,x_category_name => l_category_name);
            -- Populate Category Information

            EXECUTE IMMEDIATE
           'BEGIN                                                          '||
           '  EGO_WF_WRAPPER_PVT.Raise_Categories_Event(                   '||
           '  p_event_name => EGO_WF_WRAPPER_PVT.G_CAT_CATEGORY_CHANGE_EVENT '||
           ' ,p_dml_type          => :p_dml_type                           '||
           ' ,p_category_name     => :l_category_name                      '||
           ' ,p_category_id       => :p_category_id                        '||
           ' ,x_msg_data          => :l_msg_data                           '||
           ' ,x_return_status     => :l_ret_status);                       '||
           'END;'
           USING  IN p_dml_type,
                  IN l_category_name,
                  IN p_category_id,
                 OUT l_msg_data,
                 OUT l_ret_status;
        WHEN p_event_name = 'EGO_WF_WRAPPER_PVT.G_ITEM_BULKLOAD_EVENT' AND
             EGO_WF_WRAPPER_PVT.Get_Item_Bulkload_Bus_Event = FND_API.g_true
        THEN
           OPEN  c_raise_item_change_event(p_request_id, p_xset_id);
           FETCH c_raise_item_change_event INTO l_raise_event;
           close c_raise_item_change_event;
           IF l_raise_event = 'x' THEN
              EXECUTE IMMEDIATE
             'BEGIN  '||
             '  EGO_WF_WRAPPER_PVT.Raise_Item_Event(                       '||
             '  p_event_name   => EGO_WF_WRAPPER_PVT.G_ITEM_BULKLOAD_EVENT '||
             ' ,p_request_id      => :p_request_id                         '||
             ' ,x_msg_data        => :l_msg_data                           '||
             ' ,x_return_status   => :l_ret_status);                       '||
             'END;'
             USING  IN p_request_id,
                   OUT l_msg_data,
                   OUT l_ret_status;
           END IF;
     END CASE;

   EXCEPTION
      WHEN OTHERS THEN
        NULL;

END Raise_Events;


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
--        p_dml_type          IN         VARCHAR2
--                                       {'INSERT', 'UPDATE', 'DELETE', 'BULK'}
--        p_inventory_item_id IN         NUMBER   DEFAULT NULL
--        p_item_number       IN         VARCHAR2 DEFAULT NULL
--        p_organization_id   IN         NUMBER   DEFAULT NULL
--        p_organization_code IN         VARCHAR2 DEFAULT NULL
--        p_master_org_flag   IN         VARCHAR2 DEFAULT NULL
--                                       {'Y', 'N'}
--        p_item_description  IN         VARCHAR2 DEFAULT NULL
--        p_category_set_id   IN         NUMBER   DEFAULT NULL
--        p_category_id       IN         NUMBER   DEFAULT NULL
--        p_old_category_id   IN         NUMBER   DEFAULT NULL
--        p_category_name     IN         VARCHAR2 DEFAULT NULL
--        p_structure_id      IN         NUMBER   DEFAULT NULL
--
--
-- ----------------------------------------------------------------------

Procedure Invoke_ICX_APIs ( p_commit            IN         BOOLEAN  DEFAULT FALSE
                           ,p_xset_id           IN         NUMBER   DEFAULT -999
                           ,p_request_id        IN         NUMBER   DEFAULT NULL
                           ,p_entity_type       IN         VARCHAR2
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
                           ,p_structure_id      IN         NUMBER   DEFAULT NULL) IS

/* Cursors to check if a concurrent request resulted in atleast one
   update to the tables by checking the records with process_flag=7 */

    CURSOR c_raise_item_change_event(cp_request_id NUMBER
                                    ,cp_xset_id    NUMBER) IS
       SELECT 'x' FROM dual
       WHERE EXISTS( SELECT NULL
                     FROM   mtl_system_items_interface
                     WHERE  set_process_id   = cp_xset_id
                     AND    process_flag     = 7
                     AND    request_id       = cp_request_id
                     AND    transaction_type in ('UPDATE','CREATE'));

    CURSOR c_raise_item_categories_event(cp_request_id NUMBER
                                        ,cp_xset_id    NUMBER) IS
       SELECT 'x' FROM dual
       WHERE EXISTS(SELECT NULL
                    FROM   mtl_item_categories_interface
                    WHERE  set_process_id   = cp_xset_id
                    AND    process_flag     = 7
                    AND    request_id       = cp_request_id);

   l_raise_event       VARCHAR2(1);
   l_ret_status        VARCHAR2(1);
   l_organization_code VARCHAR2(2000);
   l_master_org_flag   VARCHAR2(1);
   l_item_description  VARCHAR2(2000);
   l_item_number       VARCHAR2(2000);
   l_category_name     VARCHAR2(2000);
   l_commit            VARCHAR2(1);
   l_icx_migrp_exists  VARCHAR2(1);
   l_icx_catggrp_exists VARCHAR2(1);

BEGIN
   --6531763: Adding ICX install check.
   IF INV_ITEM_UTIL.Appl_Inst_ICX = 0 THEN
      RETURN;
   END IF;

   IF p_commit = TRUE THEN
     l_commit := FND_API.G_TRUE;
   ELSE
     l_commit := FND_API.G_FALSE;
   END IF;

   IF (INV_ITEM_UTIL.Object_Exists(
          p_object_type  => 'PACKAGE',
          p_object_name  => 'ICX_CAT_POPULATE_MI_GRP') = 'Y') THEN
      l_icx_migrp_exists := 'Y';
   ELSE
      l_icx_migrp_exists := 'N';
   END IF;

   IF (INV_ITEM_UTIL.Object_Exists(
          p_object_type  => 'PACKAGE',
          p_object_name  => 'ICX_CAT_POPULATE_CATG_GRP') = 'Y') THEN
      l_icx_catggrp_exists := 'Y';
   ELSE
      l_icx_catggrp_exists := 'N';
   END IF;

   CASE
      WHEN p_entity_type = 'ITEM' AND l_icx_migrp_exists = 'Y' THEN
         IF p_dml_type = 'BULK'    THEN
            OPEN  c_raise_item_change_event(p_request_id, p_xset_id );
            FETCH c_raise_item_change_event INTO l_raise_event;
            CLOSE c_raise_item_change_event;
            IF l_raise_event = 'x' THEN
               EXECUTE IMMEDIATE
               ' BEGIN                                               '||
               '   ICX_CAT_POPULATE_MI_GRP.populateBulkItemChange(   '||
               '            P_API_VERSION        => 1.0              '||
               '           ,P_COMMIT             => :l_commit        '||
               '           ,P_INIT_MSG_LIST      => NULL             '||
               '           ,P_VALIDATION_LEVEL   => NULL             '||
               '           ,P_REQUEST_ID         => :p_request_id    '||
               '           ,P_ENTITY_TYPE        => :p_entity_type   '||
               '           ,X_RETURN_STATUS      => :l_ret_status ); '||
               ' END;'
               USING  IN l_commit, IN p_request_id, IN p_entity_type
                    ,OUT l_ret_status;
            END IF;
         ELSE
            -- Populate Item and Orgnanization Information
            get_Org_Info(
                p_organization_id   => p_organization_id
               ,x_organization_code => l_organization_code
               ,x_master_org_flag   => l_master_org_flag);

            get_Item_Info(
                 p_inventory_item_id
                ,p_organization_id
                ,l_item_description
                ,l_item_number);
            -- Populate Item and Orgnanization Information

            EXECUTE IMMEDIATE
            'BEGIN                                               '||
             '  ICX_CAT_POPULATE_MI_GRP.populateItemChange(      '||
             '      P_API_VERSION        => 1.0                  '||
             '     ,P_COMMIT             => :l_commit            '||
             '     ,P_INIT_MSG_LIST      => NULL                 '||
             '     ,P_VALIDATION_LEVEL   => NULL                 '||
             '     ,P_DML_TYPE           => :p_dml_type          '||
             '     ,P_INVENTORY_ITEM_ID  => :p_inventory_item_id '||
             '     ,P_ITEM_NUMBER        => :l_item_number       '||
             '     ,P_ORGANIZATION_ID    => :p_organization_id   '||
             '     ,P_ORGANIZATION_CODE  => :l_organization_code '||
             '     ,P_MASTER_ORG_FLAG    => :l_master_org_flag   '||
             '     ,P_ITEM_DESCRIPTION   => :l_item_description  '||
             '     ,X_RETURN_STATUS      => :l_ret_status);      '||
             ' END; '
             USING IN l_commit, IN p_dml_type, IN p_inventory_item_id,
                   IN l_item_number, IN p_organization_id,
                   IN l_organization_code, IN l_master_org_flag,
                   IN l_item_description, OUT l_ret_status;
         END IF;

      WHEN p_entity_type = 'ITEM_CATEGORY' AND l_icx_migrp_exists = 'Y' THEN
         IF p_dml_type = 'BULK'             THEN
            OPEN  c_raise_item_categories_event(p_request_id, p_xset_id );
            FETCH c_raise_item_categories_event INTO l_raise_event;
            CLOSE c_raise_item_categories_event;
            IF l_raise_event = 'x' THEN
               EXECUTE IMMEDIATE
               ' BEGIN                                               '||
               '   ICX_CAT_POPULATE_MI_GRP.populateBulkItemChange(   '||
               '            P_API_VERSION        => 1.0              '||
               '           ,P_COMMIT             => :l_commit        '||
               '           ,P_INIT_MSG_LIST      => NULL             '||
               '           ,P_VALIDATION_LEVEL   => NULL             '||
               '           ,P_REQUEST_ID         => :p_request_id    '||
               '           ,P_ENTITY_TYPE        => :p_entity_type   '||
               '           ,X_RETURN_STATUS      => :l_ret_status ); '||
               ' END;'
               USING  IN l_commit, IN p_request_id, IN p_entity_type
                    ,OUT l_ret_status;
            END IF;
         ELSE
            -- Populate Item and Orgnanization Information
            get_Item_Info(
                 p_inventory_item_id
                ,p_organization_id
                ,l_item_description
                ,l_item_number);
            get_Org_Info(
                 p_organization_id   => p_organization_id
                ,x_organization_code => l_organization_code
                ,x_master_org_flag   => l_master_org_flag);
            -- Populate Item Information

            EXECUTE IMMEDIATE
            'BEGIN                                                  '||
             '  ICX_CAT_POPULATE_MI_GRP.populateItemCategoryChange( '||
             '      P_API_VERSION        => 1.0                     '||
             '     ,P_COMMIT             => :l_commit               '||
             '     ,P_INIT_MSG_LIST      => NULL                    '||
             '     ,P_VALIDATION_LEVEL   => NULL                    '||
             '     ,P_DML_TYPE           => :p_dml_type             '||
             '     ,P_INVENTORY_ITEM_ID  => :p_inventory_item_id    '||
             '     ,P_ITEM_NUMBER        => :l_item_number          '||
             '     ,P_ORGANIZATION_ID    => :p_organization_id      '||
             '     ,P_CATEGORY_SET_ID    => :p_category_set_id      '||
             '     ,P_CATEGORY_ID        => :p_category_id          '||
             '     ,P_MASTER_ORG_FLAG    => :l_master_org_flag      '||
             '     ,X_RETURN_STATUS      => :l_ret_status);         '||
             ' END; '
             USING IN l_commit, IN p_dml_type, IN p_inventory_item_id,
                   IN l_item_number,     IN p_organization_id,
                   IN p_category_set_id, IN p_category_id,
                   IN l_master_org_flag, OUT l_ret_status;
         END IF;

      WHEN p_entity_type = 'CATEGORY' AND l_icx_catggrp_exists = 'Y' THEN
         -- Populate Category Information
         get_category_info(
              p_category_id   => p_category_id
             ,x_category_name => l_category_name);
         -- Populate Category Information

         EXECUTE IMMEDIATE
         'BEGIN                                                '||
         '   ICX_CAT_POPULATE_CATG_GRP.populateCategoryChange( '||
         '        P_API_VERSION      => 1.0                    '||
         '       ,P_COMMIT           => :l_commit              '||
         '       ,P_INIT_MSG_LIST    => NULL                   '||
         '       ,P_VALIDATION_LEVEL => NULL                   '||
         '       ,P_DML_TYPE         => :p_dml_type            '||
         '       ,P_STRUCTURE_ID     => :p_structure_id        '||
         '       ,P_CATEGORY_NAME    => :l_category_name       '||
         '       ,P_CATEGORY_ID      => :p_category_id         '||
         '       ,X_RETURN_STATUS    => :l_ret_status);        '||
         'END; '
         USING IN l_commit,       IN p_dml_type,
               IN p_structure_id, IN l_category_name,
               IN p_category_id, OUT l_ret_status;

      WHEN p_entity_type = 'VALID_CATEGORY' AND l_icx_catggrp_exists = 'Y' THEN
      CASE
         WHEN p_dml_type = 'CREATE' THEN
         EXECUTE IMMEDIATE
         'BEGIN                                                        '||
         '  ICX_CAT_POPULATE_CATG_GRP.populateValidCategorySetInsert(  '||
         '        P_API_VERSION      => 1.0                            '||
         '       ,P_COMMIT           => :l_commit                      '||
         '       ,P_INIT_MSG_LIST    => NULL                           '||
         '       ,P_VALIDATION_LEVEL => NULL                           '||
         '       ,P_CATEGORY_SET_ID  => :p_category_set_id             '||
         '       ,P_CATEGORY_ID      => :p_category_id                 '||
         '       ,X_RETURN_STATUS    => :l_ret_status);                '||
         'END; '
         USING IN l_commit,       IN p_category_set_id,
               IN p_category_id, OUT l_ret_status;

         WHEN p_dml_type = 'UPDATE' THEN
         EXECUTE IMMEDIATE
         'BEGIN                                                        '||
         '  ICX_CAT_POPULATE_CATG_GRP.populateValidCategorySetDelete(  '||
         '        P_API_VERSION      => 1.0                            '||
         '       ,P_COMMIT           => :l_commit                      '||
         '       ,P_INIT_MSG_LIST    => NULL                           '||
         '       ,P_VALIDATION_LEVEL => NULL                           '||
         '       ,P_CATEGORY_SET_ID  => :p_category_set_id             '||
         '       ,P_NEW_CATEGORY_ID  => :p_category_id                 '||
         '       ,P_OLD_CATEGORY_ID  => :p_old_category_id             '||
         '       ,X_RETURN_STATUS    => :l_ret_status);                '||
         'END; '
         USING IN l_commit,       IN p_category_set_id,
               IN p_category_id,  IN p_old_category_id,
               OUT l_ret_status;

         WHEN p_dml_type = 'DELETE' THEN
         EXECUTE IMMEDIATE
         'BEGIN                                                        '||
         '  ICX_CAT_POPULATE_CATG_GRP.populateValidCategorySetDelete(  '||
         '        P_API_VERSION      => 1.0                            '||
         '       ,P_COMMIT           => :l_commit                      '||
         '       ,P_INIT_MSG_LIST    => NULL                           '||
         '       ,P_VALIDATION_LEVEL => NULL                           '||
         '       ,P_CATEGORY_SET_ID  => :p_category_set_id             '||
         '       ,P_CATEGORY_ID      => :p_category_id                 '||
         '       ,X_RETURN_STATUS    => :l_ret_status);                '||
         'END; '
         USING IN l_commit,       IN p_category_set_id,
               IN p_category_id, OUT l_ret_status;

      END CASE; -- p_dml_type
   END CASE; --p_entity_type

   EXCEPTION
      WHEN OTHERS THEN
         NULL;

END Invoke_ICX_APIs;

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
		   ,p_structure_id      IN         NUMBER   DEFAULT NULL) IS
l_commit BOOLEAN;
BEGIN
   IF p_commit = 1 THEN
      l_commit := TRUE;
   ELSE
      l_commit := FALSE;
   END IF;
   Invoke_ICX_APIs (
       p_commit            => l_commit
      ,p_xset_id           => p_xset_id
      ,p_request_id        => p_request_id
      ,p_entity_type       => p_entity_type
      ,p_dml_type          => p_dml_type
      ,p_inventory_item_id => p_inventory_item_id
      ,p_item_number       => p_item_number
      ,p_organization_id   => p_organization_id
      ,p_organization_code => p_organization_code
      ,p_master_org_flag   => p_master_org_flag
      ,p_item_description  => p_item_description
      ,p_category_set_id   => p_category_set_id
      ,p_category_id       => p_category_id
      ,p_old_category_id   => p_old_category_id
      ,p_category_name     => p_category_name
      ,p_structure_id      => p_structure_id);

END Invoke_ICX_wrapper;


-- ----------------------------------------------------------------------
--  API Name:        Invoke_JAI_API
--
--  Type:            Private
--
--  Description:     Call India Localization API
--
-- Parameters:
--   IN:
--      pv_action_type     IN    VARCHAR2  {'COPY','ASSIGN','IMPORT','DELETE'}
--      pt_item_data       IN    DBMS_UTILITY.UNCL_ARRAY
--      pn_set_process_id  IN    NUMBER
--      pv_called_from     IN    VARCHAR2
--
-- ----------------------------------------------------------------------

  Procedure Invoke_JAI_API (
        p_action_type                IN    VARCHAR2
       ,p_organization_id            IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
       ,p_inventory_item_id          IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
       ,p_source_organization_id     IN    MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
       ,p_source_inventory_item_id   IN    MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE
       ,p_set_process_id             IN    NUMBER
       ,p_called_from                IN    VARCHAR2 ) IS

   l_country_code   VARCHAR2(4) := NULL;
   l_product_code   VARCHAR2(4) := NULL;
   l_jai_object     VARCHAR2(1);

  BEGIN
    --Bug: 4880971
    --l_country_code := fnd_profile.value('JGZZ_COUNTRY_CODE');
    --l_product_code := fnd_profile.value('JGZZ_PRODUCT_CODE');
    l_jai_object   := INV_ITEM_UTIL.Object_Exists(
                          p_object_type  => 'PACKAGE'
                         ,p_object_name  => 'JAI_INV_ITEMS_PKG');


    --Bug: 4880971
    Invoke_JG_ZZ_API( p_organization_id => p_organization_id
                     ,p_country_code    => l_country_code
		     ,p_product_code    => l_product_code);

    IF  l_product_code  = 'JA'
    AND l_country_code  = 'IN'
    AND l_jai_object    = 'Y'
    THEN

        EXECUTE IMMEDIATE
        'BEGIN                                                                  '||
        '  JAI_INV_ITEMS_PKG.PROPAGATE_ITEM_ACTION (                            '||
        '          pv_action_type               => :p_action_type              '||
        '        , pn_organization_id           => :p_organization_id          '||
        '        , pn_inventory_item_id         => :p_inventory_item_id        '||
        '        , pn_source_organization_id    => :p_source_organization_id   '||
        '        , pn_source_inventory_item_id  => :p_source_inventory_item_id '||
        '        , pn_set_process_id            => :p_set_process_id           '||
        '        , pv_called_from               => :p_called_from              '||
        '  );                                                                   '||
        'END; '
        USING IN p_action_type
            , IN p_organization_id
            , IN p_inventory_item_id
            , IN p_source_organization_id
            , IN p_source_inventory_item_id
            , IN p_set_process_id
            , IN p_called_from ;

    END IF;
 EXCEPTION
    WHEN OTHERS THEN
       NULL;
  END Invoke_JAI_API;

-- -------------------------------------------------------------------------
--  API Name:        Sync IP Intermedia Index
--
--  Type:            Private
--
--  Description:     Calls IProcurement Intermedia index rebuild after
--                   commiting as it is a DDL.
-----------------------------------------------------------------------------

Procedure Sync_IP_IM_Index IS
   l_api_version                NUMBER;
   x_ret_status                 VARCHAR2(1);

   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN
   --6531763: Adding ICX install check.
   IF ((INV_ITEM_UTIL.Appl_Inst_ICX <> 0)
   AND (INV_ITEM_UTIL.Object_Exists(
          p_object_type  => 'PACKAGE',
          p_object_name  => 'ICX_CAT_POPULATE_ITEM_GRP') = 'Y'))
   THEN

      l_api_version := 1.0;
      EXECUTE IMMEDIATE
      ' BEGIN                                                  '||
      '    ICX_CAT_POPULATE_ITEM_GRP.rebuildIPIntermediaIndex( '||
      '           p_api_version    => :l_api_version           '||
      '          ,x_return_status  => :x_ret_status);          '||
      ' END;'
      USING l_api_version, OUT x_ret_status;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF l_inv_debug_level IN(101, 102) THEN
	    INVPUTLI.info('INVVEVEB: Exception in Sync_IP_IM_Index');
	 END IF;

END Sync_IP_IM_Index;

--Bug: 4880971
PROCEDURE Invoke_JG_ZZ_API(
      p_organization_id             IN   MTL_SYSTEM_ITEMS.ORGANIZATION_ID%TYPE
     ,p_country_code                OUT NOCOPY VARCHAR2
     ,p_product_code                OUT NOCOPY VARCHAR2)
IS
   l_jg_zz_object     VARCHAR2(1);
   l_operating_unit   ORG_ORGANIZATION_DEFINITIONS.OPERATING_UNIT%TYPE;
BEGIN
    l_jg_zz_object := INV_ITEM_UTIL.Object_Exists(
			  p_object_type => 'PACKAGE',
			  p_object_name => 'JG_ZZ_SHARED_PKG');

    IF l_jg_zz_object = 'Y' THEN

       --Perf Issue : Replaced org_organizations_definitions view.
       select DECODE(ORG_INFORMATION_CONTEXT,
                     'Accounting Information',
                     TO_NUMBER(ORG_INFORMATION3),
                     TO_NUMBER(NULL))
       into l_operating_unit
       from   hr_organization_information
       where  organization_id = p_organization_id
       and (org_information_context|| '') ='Accounting Information';

       EXECUTE IMMEDIATE
       'BEGIN                                                                                   '||
       '   :p_country_code := JG_ZZ_SHARED_PKG.GET_COUNTRY( p_org_id => :l_operating_unit );    '||
       'END;                                                                                    '
       USING OUT p_country_code, IN l_operating_unit;

       EXECUTE IMMEDIATE
       'BEGIN                                                                                   '||
       '   :p_product_code := JG_ZZ_SHARED_PKG.GET_PRODUCT( p_org_id => :l_operating_unit );    '||
       'END;                                                                                    '
       USING OUT p_product_code, IN l_operating_unit;

    END IF;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END Invoke_JG_ZZ_API;


END inv_item_events_pvt;

/
