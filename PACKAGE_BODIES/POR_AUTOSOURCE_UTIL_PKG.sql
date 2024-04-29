--------------------------------------------------------
--  DDL for Package Body POR_AUTOSOURCE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_AUTOSOURCE_UTIL_PKG" AS
    /* $Header: PORSRCUB.pls 120.7.12010000.4 2012/03/14 10:28:39 rparise ship $ */

  -- Logging Static Variables
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED	       CONSTANT NUMBER	     := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT 	       CONSTANT NUMBER	     := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE	       CONSTANT NUMBER	     := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT	       CONSTANT NUMBER	     := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME 	       CONSTANT VARCHAR2(50) := 'ICX.PLSQL.POR_AUTOSOURCE_UTIL_PKG.';

    /* Check if the item is internally orderable in the destination organization */
    FUNCTION  is_internal_orderable(p_item_id           IN    NUMBER,
                                    p_organization_id   IN    NUMBER
    ) RETURN NUMBER

    IS

       l_internal_order_enabled_flag VARCHAR(1) := 'N';

    BEGIN

       select internal_order_enabled_flag
       into l_internal_order_enabled_flag
       from mtl_system_items
       where inventory_item_id = p_item_id
             and organization_id = p_organization_id;

       IF l_internal_order_enabled_flag = 'Y' THEN
          RETURN 1;
       END IF;

       RETURN 0;

       EXCEPTION
         WHEN OTHERS THEN
           RETURN 0;

    END is_internal_orderable;


    FUNCTION  is_item_purchasable(p_item_id           IN    NUMBER,
                                  p_organization_id   IN    NUMBER
    ) RETURN NUMBER

    IS

       l_purchasable_flag VARCHAR(1) := 'N';

    BEGIN

       IF fnd_profile.value('REQUISITION_TYPE') = 'INTERNAL' THEN
          RETURN 0;
       END IF;

       select purchasing_enabled_flag
       into l_purchasable_flag
       from mtl_system_items
       where inventory_item_id = p_item_id
             and organization_id = p_organization_id;

       IF l_purchasable_flag = 'Y' THEN
          RETURN 1;
       END IF;

       RETURN 0;

       EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;

    END is_item_purchasable;

    /* Used to get the unit of issue of the destination org */
    FUNCTION  get_unit_of_issue(p_item_id           IN    NUMBER,
                                p_organization_id   IN    NUMBER
    ) RETURN VARCHAR

    IS

       l_unit_of_issue VARCHAR(25);

    BEGIN
       select nvl(msi.unit_of_issue,msi.primary_unit_of_measure)
       into l_unit_of_issue
       from mtl_system_items msi
       where msi.inventory_item_id = p_item_id
             and msi.organization_id = p_organization_id;

       RETURN l_unit_of_issue;

       EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;

    END get_unit_of_issue;

    /* Used to determine if the item flags are correctly in the source org $ */
    FUNCTION  is_item_shippable(p_item_id           IN    NUMBER,
                                p_organization_id   IN    NUMBER
    ) RETURN NUMBER

    IS

       l_oe_transactable_flag VARCHAR(1);
       l_shippable_flag VARCHAR(1);
       l_mtl_transactable_flag VARCHAR(1);
       l_stockable_flag VARCHAR(1);

    BEGIN

       -- check the shippable, stockable, oe transactable and mtl_transactable flags
       select shippable_item_flag, so_transactions_flag, stock_enabled_flag, mtl_transactions_enabled_flag
       into l_shippable_flag, l_oe_transactable_flag, l_stockable_flag, l_mtl_transactable_flag
       from mtl_system_items
       where inventory_item_id = p_item_id
           and organization_id = p_organization_id;

       IF l_shippable_flag='Y' and l_oe_transactable_flag='Y' and l_stockable_flag='Y' and l_mtl_transactable_flag='Y' THEN
          RETURN 1;
       END IF;

       RETURN 0;

       EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;

    END is_item_shippable;

    /* Check if there is a valid shipping network between the source org and the destination org */
    FUNCTION  is_valid_shipping_network(p_from_organization_id     IN    NUMBER,
                                        p_to_organization_id       IN    NUMBER
    ) RETURN NUMBER

    IS

       l_is_valid_shipping_network VARCHAR(1);

    BEGIN

       IF p_from_organization_id = p_to_organization_id THEN
          RETURN 1;
       END IF;

       select 1 into l_is_valid_shipping_network
       from mtl_interorg_parameters
       where from_organization_id = p_from_organization_id
         and to_organization_id = p_to_organization_id;

       IF l_is_valid_shipping_network = '1' THEN
          RETURN 1;
       END IF;

       RETURN 0;

       EXCEPTION
         WHEN OTHERS THEN
           RETURN 0;

    END is_valid_shipping_network;

    /* Make sure the item is properly assigned to the source org */
    FUNCTION  is_item_assigned(p_item_id                  IN    NUMBER,
                               p_source_organization_id   IN    NUMBER
    ) RETURN NUMBER

    IS

       l_is_item_assigned VARCHAR(1);

    BEGIN

       SELECT 1 into l_is_item_assigned
       FROM   mtl_system_items msi
       WHERE  msi.inventory_item_id = p_item_id
         and  msi.organization_id = p_source_organization_id;

       IF l_is_item_assigned = '1' THEN
          RETURN 1;
       END IF;

       RETURN 0;

       EXCEPTION
         WHEN OTHERS THEN
           RETURN 0;

    END is_item_assigned;

    /* The main autosource API that is called by Autosource.java and SourceInfo.java.             */
    /* Contains all of the autosource logic to pick the correct source based on the sourcing      */
    /* rules and make sure the item can be sourced from that organization.  If the item can       */
    /* be sourced from the organization, then it will return the source org id, the subinventory  */
    /* and the cost price.  If there are any errors, then the api will return what error msg code */
    /* should be displayed.                                                                       */
    FUNCTION  autosource(p_item_id                    IN            NUMBER,
                         p_category_id                IN            NUMBER,
                         p_dest_organization_id       IN            NUMBER,
                         p_dest_subinventory          IN            VARCHAR2,
                         p_vendor_id                  IN            NUMBER,
                         p_vendor_site_id             IN            NUMBER,
                         p_not_purchasable_override   IN            VARCHAR2,
                         p_unit_of_issue              IN OUT NOCOPY VARCHAR2,
                         p_source_organization_id     OUT    NOCOPY NUMBER,
                         p_source_subinventory        OUT    NOCOPY VARCHAR2,
                         p_sourcing_type              OUT    NOCOPY VARCHAR2,
                         p_cost_price                 OUT    NOCOPY NUMBER,
                         p_error_msg_code             OUT    NOCOPY VARCHAR2
    ) RETURN BOOLEAN

    IS

      l_custom_package_flag BOOLEAN;
      l_is_purchasable_flag VARCHAR2(1) := 'N';
      l_set_id NUMBER;
      l_avail_quantity NUMBER;
      l_source_type NUMBER;
      l_source_organization_id NUMBER;
      l_source_subinventory VARCHAR2(10);
      l_sourcing_rule_exist_err BOOLEAN := TRUE;
      l_is_item_assigned_err BOOLEAN := TRUE;
      l_is_ship_network_assigned_err BOOLEAN := TRUE;
      --bug 2986842
      l_is_item_shippable_err BOOLEAN := TRUE;
      l_count NUMBER := 0;
      l_first_source_org_id NUMBER := -9999;

      l_vendor_id NUMBER;
      l_vendor_site_id NUMBER;

      l_procedure_name VARCHAR2(10) := 'AUTOSOURCE';

      cursor c_sourcing is
      SELECT ALL_SOURCES_V.SOURCE_ORGANIZATION_ID,
             ALL_SOURCES_V.SOURCE_TYPE,
             ALL_SOURCES_V.VENDOR_ID,
             ALL_SOURCES_V.VENDOR_SITE_ID
      FROM
      (
        SELECT SOURCE_ORGANIZATION_ID, SOURCE_TYPE, VENDOR_ID, VENDOR_SITE_ID,
               RANK, ALLOCATION_PERCENT, SOURCING_LEVEL
          FROM MRP_ITEM_SOURCING_LEVELS_V
         WHERE INVENTORY_ITEM_ID = p_item_id
           AND ORGANIZATION_ID = p_dest_organization_id
           AND ASSIGNMENT_SET_ID = l_set_id
           AND (SOURCE_TYPE = 1 OR
                (SOURCE_TYPE = 3 AND
                 'Y' = l_is_purchasable_flag AND
                 VENDOR_ID = p_vendor_id AND
                 NVL(VENDOR_SITE_ID, p_vendor_site_id) = p_vendor_site_id))
           AND SYSDATE BETWEEN EFFECTIVE_DATE AND NVL(DISABLE_DATE, SYSDATE+1)
      ) ALL_SOURCES_V
      ORDER BY ALL_SOURCES_V.SOURCING_LEVEL ASC,
               ALL_SOURCES_V.ALLOCATION_PERCENT DESC,
               NVL(ALL_SOURCES_V.RANK, 9999) ASC;

      cursor c_avail_quantity is
      SELECT msub.secondary_inventory_name,
             (nvl(mos.total_qoh,0) - sum(nvl(mrs.primary_reservation_quantity,0))) avail_quantity
      FROM mtl_secondary_inventories msub,
           mtl_onhand_sub_v mos,
           mtl_reservations mrs,
           mtl_system_items msi
      WHERE msub.organization_id = l_source_organization_id -- bug 5470125, do not bind p_source_organization_id
        and msi.organization_id = l_source_organization_id
        and msi.inventory_item_id = p_item_id
        and (trunc(sysdate) < nvl(msub.disable_date, trunc(sysdate + 1)))
        and msub.quantity_tracked = 1
        and msub.secondary_inventory_name = mos.subinventory_code (+)
        and mos.inventory_item_id = mrs.inventory_item_id (+)
        and mos.organization_id = mrs.organization_id (+)
        and mos.subinventory_code = mrs.subinventory_code (+)
        and mos.inventory_item_id (+) = p_item_id
        and mos.organization_id (+) = l_source_organization_id
        and (msi.restrict_subinventories_code = 2
             or (msi.restrict_subinventories_code = 1
                 and exists (select null
                             from mtl_item_sub_inventories mis
                             where mis.organization_id = msi.organization_id
                               and mis.inventory_item_id = msi.inventory_item_id
                               and mis.secondary_inventory = msub.secondary_inventory_name)
                 )
             )
        and msub.reservable_type=1 --  bug 2986842 need to restrict to reservable subinventory
                                   --  otherwise po creation will fail
      GROUP BY msub.secondary_inventory_name, mos.total_qoh
      ORDER BY avail_quantity DESC, msub.secondary_inventory_name ASC;

    BEGIN

      G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Start Autosource');
      END IF;

      p_error_msg_code := '';

      if is_internal_orderable(p_item_id,p_dest_organization_id) = 0 then
         p_error_msg_code := 'ICX_POR_NOT_ORDERABLE_ERROR';
         return FALSE;
      end if;

      l_custom_package_flag := por_autosource_custom_pkg.autosource(p_item_id,
                                                                    p_category_id,
                                                                    p_dest_organization_id,
                                                                    p_dest_subinventory,
                                                                    p_vendor_id,
                                                                    p_vendor_site_id,
                                                                    p_not_purchasable_override,
                                                                    p_unit_of_issue,
                                                                    p_source_organization_id,
                                                                    p_source_subinventory,
                                                                    p_sourcing_type,
                                                                    p_cost_price,
                                                                    p_error_msg_code);
      -- check if the autosource logic was customized
      if l_custom_package_flag = TRUE then

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Return Custom');
         END IF;

         return TRUE;
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Item ID: ' || to_char(p_item_id));
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Category ID: ' || to_char(p_category_id));
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Dest Org ID: ' || to_char(p_dest_organization_id));
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Dest Subinv: ' || p_dest_subinventory);
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Vendor ID: ' || to_char(p_vendor_id));
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Vendor Site ID: ' || to_char(p_vendor_site_id));
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Not Purchasable Override: ' || p_not_purchasable_override);
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Unit of Issue: ' || p_unit_of_issue);
      END IF;

      -- first find the MRP: Assignment Set profile value
      l_set_id := to_number(fnd_profile.value('MRP_DEFAULT_ASSIGNMENT_SET'));

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Assignment Set ID: ' || to_char(l_set_id));
      END IF;

      -- get the unit of issue of the destination org
      p_unit_of_issue := get_unit_of_issue(p_item_id,p_dest_organization_id);

      if l_set_id is null then
         p_error_msg_code := 'ICX_POR_SRC_SETUP_INC';
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME || l_procedure_name, 'Return F');
         END IF;
         return FALSE;
      end if;

      -- check if the item is purchasable
      --  if the not purchasable override flag is set to true, then the item cannot be purchasable.
      if p_not_purchasable_override = 'N' and is_item_purchasable(p_item_id, p_dest_organization_id) = 1 then
         l_is_purchasable_flag := 'Y';
      else
         l_is_purchasable_flag := 'N';
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Is Purchasable Flag: ' || l_is_purchasable_flag);
      END IF;

      -- run the sourcing query
      OPEN c_sourcing;
      loop fetch c_sourcing into
           l_source_organization_id,
           l_source_type,
           l_vendor_id,
           l_vendor_site_id;
       exit when c_sourcing%NOTFOUND;

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                         l_procedure_name, 'Source Org ID: ' || to_char(l_source_organization_id));
          FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                         l_procedure_name, 'Source Type: ' || l_source_type);
       END IF;

       if PO_ASL_SV.check_asl_action('2_SOURCING',l_vendor_id,
                                     l_vendor_site_id, p_item_id, -1,
                                     p_dest_organization_id ) <> 0 then

         -- if the sourcing rules say to pick the supplier, return supplier
         if l_source_type = 3 then
            p_sourcing_type := 'SUPPLIER';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                              l_procedure_name, 'Return T ' || p_sourcing_type);
            END IF;
            return true;
         end if;

         l_sourcing_rule_exist_err := FALSE;

         -- check if the item is assigned to this particular source org
         if is_item_assigned(p_item_id, l_source_organization_id) = 1 then

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                              l_procedure_name, 'Is Item Assigned: 1');
            END IF;

            l_is_item_assigned_err := FALSE;
            -- check if there is a valid shipping network betweem the destination org and this particular source org
            if is_valid_shipping_network(l_source_organization_id, p_dest_organization_id) = 1 then

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                 l_procedure_name, 'Is Valid Shipping Network: 1');
               END IF;

               l_is_ship_network_assigned_err := FALSE;
               -- check if the item flags are correctly set in this particular source org
               if is_item_shippable(p_item_id, l_source_organization_id) = 1 then

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                    l_procedure_name, 'Is Item Shippable: 1');
                  END IF;

                  l_is_item_shippable_err := FALSE;

                  PO_REQ_LINES_SV1.get_cost_price(p_item_id,l_source_organization_id,p_unit_of_issue,p_cost_price);

                  -- Explicitly rounding the price as UI automatically rounds it to 10 digits. This is treated as a
                  -- price change and charge account is regenerated. Hence, rounding it off to 10 to prevent the same
                  p_cost_price := round(p_cost_price,10);

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                    l_procedure_name, 'Cost Price:' || to_char(p_cost_price));
                  END IF;

                  OPEN c_avail_quantity;
                  fetch c_avail_quantity into
                      l_source_subinventory,
                      l_avail_quantity;
                  close c_avail_quantity;

                  -- if the available quantity is greather than 0
                  -- default to this source org and subinventory
                  -- otherwise keep search the sourcing rule

                  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                     FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                    l_procedure_name, 'Avail Qty:' || to_char(l_avail_quantity));
                  END IF;

                  if l_avail_quantity >= 0 then
                    p_sourcing_type := 'INTERNAL';
                    p_source_organization_id := l_source_organization_id;
                    p_source_subinventory := l_source_subinventory;
                    close c_sourcing;
                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                      l_procedure_name, 'Return T ' || p_sourcing_type);
                    END IF;
                    return true;
                  end if;

                  --save the first record so if the avail qty is 0 in all subinv do not
                  --populate the subinv and default the first source org if there is no error

                  if  ( (l_count = 0) and not (l_sourcing_rule_exist_err or l_is_item_assigned_err or l_is_ship_network_assigned_err or l_is_item_shippable_err) )   then

                     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                                       l_procedure_name, 'Count = 0');
                     END IF;

                     l_first_source_org_id := l_source_organization_id ;
                  end if;
                  l_count := l_count + 1;
               end if;
            end if;
         end if;
       end if;
      end loop;
      if c_sourcing%ISOPEN then
         close c_sourcing;
      end if;

      -- if l_count > 0 and l_first_source_org_id is not -9999 then
      -- it means that a source org was returned but no sub inv is there
      if ( ( l_count > 0) and (l_first_source_org_id <> -9999) ) then
         p_sourcing_type := 'INTERNAL';
         p_source_organization_id := l_first_source_org_id;
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                           l_procedure_name, 'Return T ' || p_sourcing_type);
         END IF;
         return TRUE;
      end if;

      -- if we didn't find an internal source and the item is purchasable, return Supplier
      if (l_is_purchasable_flag = 'Y') then
         p_sourcing_type := 'SUPPLIER';
         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                           l_procedure_name, 'Return T ' || p_sourcing_type);
         END IF;
         return TRUE;
      end if;

      p_sourcing_type := null;

      -- if we didn't find an internal source and the item is strictly internally
      -- orderable, select error msg code and return false
      if l_sourcing_rule_exist_err then
         p_error_msg_code := 'ICX_POR_SRC_RULE_NOEXIST';
      elsif l_is_item_assigned_err then
         p_error_msg_code := 'ICX_POR_NO_INT_SOURCES_ERR';
      elsif l_is_ship_network_assigned_err then
         p_error_msg_code := 'ICX_POR_NO_INT_SOURCES_ERR';
      elsif l_is_item_shippable_err then
         p_error_msg_code := 'ICX_POR_SRC_ITEM_SHIP_ERR';
      else
         p_error_msg_code := 'ICX_POR_NO_INT_SOURCES_ERR';
      end if;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Return F');
      END IF;

      return FALSE;

    EXCEPTION
       WHEN OTHERS THEN
          p_error_msg_code := 'Exception';
          if c_sourcing%ISOPEN then
             close c_sourcing;
          end if;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME ||
                        l_procedure_name, 'Exception Return F');
          END IF;
          RETURN FALSE;

    END autosource;

END POR_AUTOSOURCE_UTIL_PKG; -- package

/
