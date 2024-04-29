--------------------------------------------------------
--  DDL for Package Body INVUPDAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVUPDAT" as
/* $Header: INVUPDAB.pls 120.1 2005/10/18 05:26:59 swshukla noship $ */

PROCEDURE  UPDATE_ATTRIBUTES(
current_attribute_name      IN    VARCHAR2,
current_attribute_value     IN    VARCHAR2   DEFAULT NULL,
input_status                IN    VARCHAR2   DEFAULT NULL
)
IS

 lock_variable VARCHAR2(1);


 CURSOR  status_cursor(input_stat_value VARCHAR2) IS
 select s.inventory_item_status_code IISC,
	v.attribute_value  AV
 from   mtl_item_status s,
	mtl_status_attribute_values v
 where  s.inventory_item_status_code = NVL(input_stat_value , s.inventory_item_status_code)
 and    s.inventory_item_status_code = v.inventory_item_status_code
 and    v.attribute_name = current_attribute_name;


  /*This code will lock only the records that may get updated below.  This prevents
 the system from hanging if an item record that needs to be updated is open and locked.*/

 CURSOR lock_records IS
 select 'x'
 from   mtl_system_items
 where  decode(current_attribute_name, 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG',            inventory_item_flag,
                                       'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG', stock_enabled_flag,
                                       'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG',       purchasing_item_flag,
                                       'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG',          invoiceable_item_flag,
                                       'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG',             inventory_item_flag,
                                       'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG',   customer_order_flag,
                                       'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG',   internal_order_flag,
                                       'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG',              bom_enabled_flag,
                                       'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG',           recipe_enabled_flag,
                                       'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG',process_execution_enabled_flag, 'N')
                                 = 'Y'
       and input_status = MTL_SYSTEM_ITEMS.inventory_item_status_code
for update of last_update_date NOWAIT;

	l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;     --Bug: 4667452
BEGIN

  OPEN lock_records;
  FETCH lock_records into lock_variable;

 /* Update the relevant attribute in the item master for all *
  * items which match the update criteria.                   *
  * while making sure that no interdependencies are violated */
   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('inside ');
   END IF;

   FOR status_cursor_row in status_cursor(input_status) LOOP
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('inside for IISC ' || status_cursor_row.IISC);
         INVPUTLI.info('current attribute is  ' ||current_attribute_name );
      END IF;
      if ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.stock_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.inventory_item_flag = 'Y'
	      and    msi.stock_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.mtl_transactions_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.stock_enabled_flag = 'Y'
	      and    msi.mtl_transactions_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.purchasing_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.purchasing_item_flag = 'Y'
	      and    msi.purchasing_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.invoice_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.invoiceable_item_flag = 'Y'
	      and    msi.invoice_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG') then
	      update mtl_system_items msi
	      set    msi.build_in_wip_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.inventory_item_flag = 'Y'
	      and    msi.build_in_wip_flag <> NVL(current_attribute_value, status_cursor_row.AV)
              and    msi.bom_item_type = 4
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.customer_order_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.customer_order_flag = 'Y'
	      and    msi.customer_order_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.internal_order_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.internal_order_flag = 'Y'
	      and    msi.internal_order_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.bom_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  --Bug: 3546140 msi.inventory_item_flag = 'Y'and
	             msi.bom_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;
      /* Jalaj Srivastava Bug 4032615 */
      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.recipe_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.recipe_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

      elsif ( current_attribute_name  = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG') then
	      update mtl_system_items msi
	      set    msi.process_execution_enabled_flag
                           = NVL(current_attribute_value, status_cursor_row.AV),
                     msi.last_updated_by = to_number(fnd_profile.value('USER_ID')),
                     msi.last_update_date = sysdate,
                     msi.last_update_login = to_number(fnd_profile.value('LOGIN_ID'))
	      where  msi.process_execution_enabled_flag <> NVL(current_attribute_value, status_cursor_row.AV)
	      and    msi.inventory_item_status_code = status_cursor_row.IISC;

     end if;
     /* intermediate commit commented out since we want the form to do
        all the commits. Might need to uncomment it if this leads to resource issues.
        commit;
     */

  END LOOP;
    /* Commented out commit
       commit;
    */
  CLOSE lock_records;
END  UPDATE_ATTRIBUTES;

END INVUPDAT;

/
