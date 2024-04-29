--------------------------------------------------------
--  DDL for Package Body INV_ITEM_STATUS_CP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_STATUS_CP" AS
/* $Header: INVCIPSB.pls 120.10.12010000.5 2010/02/11 01:01:32 mshirkol ship $ */

   G_STATUS_CODE           VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';
   G_STOCK_ENABLED         VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG';
   G_TRANSACTIONS_ENABLED  VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG';
   G_PURCHASING_ENABLED    VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG';
   G_INVOICE_ENABLED       VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG';
   G_BUILD_IN_WIP          VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG';
   G_CUSTOMER_ENABLED      VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG';
   G_INTERNAL_ENABLED      VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG';
   G_BOM_ENABLED           VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG';
   G_PKG_NAME              VARCHAR2(50) := 'INV_ITEM_STATUS_CP';

   G_ITEM                  NUMBER  := 1;
   G_ITEM_ORG              NUMBER  := 2;
   G_PWIDTH                NUMBER  := 132;
   G_SO_RESERVABLE         NUMBER  := 1;
   G_BOM_STANDARD          NUMBER  := 4;
   G_BOM_MODEL             NUMBER  := 1;
   G_UNDER_STATUS_CONTROL  NUMBER  := 1;
   G_DEFAULT_CONTROL       NUMBER  := 2;
   G_NO_CONTROL            NUMBER  := 3;  -- Added for Bug-6531777
   G_ARG_ORGANIZATION_ID   NUMBER  := 1;
   G_ARG_ITEM_ID           NUMBER  := 2;

   G_USER_ID               NUMBER  :=  -1;
   G_LOGIN_ID              NUMBER  :=  -1;
   G_PROG_APPID            NUMBER  :=  -1;
   G_PROG_ID               NUMBER  :=  -1;
   G_REQUEST_ID            NUMBER  :=  -1;

   G_SUCCESS     CONSTANT  NUMBER  :=  0;
   G_WARNING     CONSTANT  NUMBER  :=  1;
   G_ERROR       CONSTANT  NUMBER  :=  2;

   --Added for 5230429
   G_transactable_status   BOOLEAN :=  FALSE;
   --commented for bug 5479302
-- G_BOM_status            NUMBER  :=  0;

/* Start Bug 3713912 */
   G_RECIPE_ENABLED        VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG';
   G_PROCESS_EXECUTION_ENABLED    VARCHAR2(50) := 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG';
/* End Bug 3713912 */

   -- Added for bug 5230594
   G_TRANSACTABLE          NUMBER := 0;
   G_ORDERABLE             NUMBER := 0;
   G_PURCHASABLE           NUMBER := 0;



PROCEDURE  update_item_attributes(p_pending_status IN  VARCHAR2
			         ,p_control_level  IN  NUMBER
			         ,p_Org_Id         IN  NUMBER
			         ,p_Item_id        IN  NUMBER
                                 ,p_commit         IN  VARCHAR2:=  FND_API.g_TRUE
			         ,p_return_status  OUT NOCOPY BOOLEAN)

IS
/* Start Bug#7454766
Declaring Cursor c_get_values_from_msib to fetch values of INVENTORY_ITEM_STATUS_CODE, INTERNAL_ORDER_ENABLED_FLAG, PURCHASING_ENABLED_FLAG,
from mtl_system_items_b table.
*/

 CURSOR c_get_values_from_msib (p_item_id number,p_org_id number)
    IS
       SELECT  INVENTORY_ITEM_STATUS_CODE, INTERNAL_ORDER_ENABLED_FLAG, PURCHASING_ENABLED_FLAG
       FROM mtl_system_items_b msib
       WHERE msib.inventory_item_id = p_Item_Id
    AND msib.organization_id   = p_Org_Id;

   l_status_code  mtl_system_items_b.INVENTORY_ITEM_STATUS_CODE%TYPE;
   l_purch_enbl  mtl_system_items_b.PURCHASING_ENABLED_FLAG%TYPE;
   l_int_ordr_enbl  mtl_system_items_b.INTERNAL_ORDER_ENABLED_FLAG%TYPE;

/* End Bug#7454766 */



    CURSOR c_get_status_control (cp_attrib_name VARCHAR2)
    IS
       SELECT status_control_code
       FROM   mtl_item_attributes
       WHERE  attribute_name = cp_attrib_name;

    l_stock_cntrl_level    mtl_item_attributes.status_control_code%TYPE;
    l_trans_cntrl_level    mtl_item_attributes.status_control_code%TYPE;
    l_purch_cntrl_level    mtl_item_attributes.status_control_code%TYPE;
    l_invoice_cntrl_level  mtl_item_attributes.status_control_code%TYPE;
    l_wip_cntrl_level      mtl_item_attributes.status_control_code%TYPE;
    l_cust_cntrl_level     mtl_item_attributes.status_control_code%TYPE;
    l_int_cntrl_level      mtl_item_attributes.status_control_code%TYPE;
    l_bom_cntrl_level      mtl_item_attributes.status_control_code%TYPE;
    l_row_temp             NUMBER :=0;
    /* Start Bug 3713912 */
    l_recipe_cntrl_level      mtl_item_attributes.status_control_code%TYPE;
    l_process_exec_cntrl_level     mtl_item_attributes.status_control_code%TYPE;
/* End Bug 3713912 */
    is_transactable_upd    NUMBER;
    is_bom_enabled_upd     NUMBER;

BEGIN

   p_return_status := FALSE;

   OPEN  c_get_status_control(cp_attrib_name => G_STOCK_ENABLED);
   FETCH c_get_status_control INTO l_stock_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_TRANSACTIONS_ENABLED);
   FETCH c_get_status_control INTO l_trans_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_PURCHASING_ENABLED);
   FETCH c_get_status_control INTO l_purch_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_INVOICE_ENABLED);
   FETCH c_get_status_control INTO l_invoice_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_BUILD_IN_WIP);
   FETCH c_get_status_control INTO l_wip_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_CUSTOMER_ENABLED);
   FETCH c_get_status_control INTO l_cust_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_INTERNAL_ENABLED);
   FETCH c_get_status_control INTO l_int_cntrl_level;
   CLOSE c_get_status_control;

   OPEN  c_get_status_control(cp_attrib_name => G_BOM_ENABLED);
   FETCH c_get_status_control INTO l_bom_cntrl_level;
   CLOSE c_get_status_control;
   /* Start Bug 3713912 */
   OPEN  c_get_status_control(cp_attrib_name => G_RECIPE_ENABLED);
   FETCH c_get_status_control INTO l_recipe_cntrl_level;
   CLOSE c_get_status_control;
   OPEN  c_get_status_control(cp_attrib_name => G_PROCESS_EXECUTION_ENABLED);
   FETCH c_get_status_control INTO l_process_exec_cntrl_level;
   CLOSE c_get_status_control;
/* End Bug 3713912 */

   /* Check to see wether the row is locked */

    SELECT 1 INTO l_row_temp
    FROM   mtl_system_items msi
    WHERE  inventory_item_id = p_Item_Id
    AND    ((p_control_level = G_ITEM_ORG  and msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                         (SELECT p2.organization_id
                          FROM   mtl_parameters p1,
                                 mtl_parameters p2
                          WHERE  p1.organization_id        = p_Org_Id
                          AND    p1.master_organization_id =  p2.master_organization_id)))
   AND    rownum < 2
   FOR UPDATE NOWAIT;

	  /* 5523531 - Condition only applies when Transactable flag of item is changed by the status */
   SELECT count(*) INTO is_transactable_upd
     FROM DUAL
    WHERE EXISTS
      (SELECT 'X' FROM mtl_system_items
        WHERE inventory_item_id = p_item_id
	  AND organization_id = p_org_id
	  AND mtl_transactions_enabled_flag <>
	        (SELECT attribute_value FROM mtl_status_attribute_values
		  WHERE attribute_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG'
		    AND inventory_item_status_code = p_pending_status));

--Added for Bug: 5230429
if (l_trans_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL) AND is_transactable_upd = 1) then
   G_transactable_status := INV_ATTRIBUTE_CONTROL_PVT.transactable_uncheck(p_Org_Id,p_Item_Id);
end if;
	  /* 5523531 - Condition only applies when Transactable flag of item is changed by the status */
     SELECT count(*) INTO is_bom_enabled_upd
       FROM mtl_status_attribute_values
      WHERE attribute_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG'
        AND attribute_value = 'N'
        AND inventory_item_status_code = p_pending_status;

/*commented for bug 5479302
if(l_bom_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL) AND is_bom_enabled_upd = 1) then
   select count(*)
     into G_BOM_status
     from dual
    where exists
      ( select 'x'
          from bom_bill_of_materials bom
         where  bom.assembly_item_id = p_Item_Id
           and  bom.organization_id in
                 ( select organization_id
                     from  mtl_parameters
                    where  master_organization_id = p_Org_Id
                      and  1 = l_bom_cntrl_level
                    union all
                    select organization_id
                      from  mtl_parameters
                      where  organization_id = p_Org_Id
                      and 2 =l_bom_cntrl_level));
  end if; */

/* Bug: 5230594
   Following SQL checks if the pending status being applied is unchecking a status attribute which is required by an enabled
   dependent attributes and accordingly selects a value of 1 in the corresponding global variable
*/
 SELECT Sum(Decode(mav.attribute_name,G_TRANSACTIONS_ENABLED,Decode(mav.attribute_value,'N',Decode(msi.check_shortages_flag,'Y',1,0),0),0)) uncheck_transactable_err,
        Sum(Decode(mav.attribute_name,G_PURCHASING_ENABLED  ,Decode(mav.attribute_value,'N',Decode(msi.default_so_source_type,'EXTERNAL',1,0),0),0)) uncheck_purchasable_err,
        Sum(Decode(mav.attribute_name,G_CUSTOMER_ENABLED    ,Decode(mav.attribute_value,'N',Decode(msi.orderable_on_web_flag,'Y',1,0),0),0)) uncheck_orderable_err
   INTO G_TRANSACTABLE
       ,G_PURCHASABLE
       ,G_ORDERABLE
   FROM mtl_system_items_b msi
       ,mtl_status_attribute_values mav
  WHERE msi.inventory_item_id = p_Item_Id
    AND msi.organization_id   = p_Org_Id
    AND mav.inventory_item_status_code = p_pending_status
    AND mav.attribute_name IN (G_TRANSACTIONS_ENABLED,G_PURCHASING_ENABLED,G_CUSTOMER_ENABLED);

IF  (    (NOT G_transactable_status) --and (G_BOM_status =0)
     -- Condition OR l_trans_cntrl_level = G_NO _CONTROL added for Bug-6531777
     and (((G_TRANSACTABLE = 0) and l_trans_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL)) OR l_trans_cntrl_level = G_NO_CONTROL)
     and (((G_ORDERABLE    = 0) and l_cust_cntrl_level  in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL)) OR l_cust_cntrl_level  = G_NO_CONTROL)
     and (((G_PURCHASABLE  = 0) and l_purch_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL)) OR l_purch_cntrl_level = G_NO_CONTROL)
     ) THEN

   /* Lock is success - Update Item  status */

   UPDATE mtl_system_items msi
   SET    (inventory_item_status_code,
           last_update_date,
           last_updated_by,
           last_update_login) =
          (SELECT p_pending_status,
                  sysdate,
                  G_USER_ID,
                  G_USER_ID
           FROM   mtl_status_attribute_values v,
                  mtl_item_attributes a
           WHERE  v.inventory_item_status_code = p_pending_status
           AND    a.attribute_name = G_STOCK_ENABLED
           AND    a.attribute_name = v.attribute_name)
   WHERE   msi.inventory_item_id = p_Item_Id
   AND     ((p_control_level = G_ITEM_ORG  and msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   /* Update all the Eight Item Attributes */

   UPDATE mtl_system_items msi
   SET    msi.stock_enabled_flag =
               ( SELECT DECODE(mti.inventory_item_flag,'N','N',v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
                        mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_STOCK_ENABLED
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE  l_stock_cntrl_level IN ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL)
   AND    msi.inventory_item_id   = p_Item_Id
   AND    msi.inventory_item_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   UPDATE mtl_system_items msi
   SET    msi.mtl_transactions_enabled_flag =
               ( SELECT DECODE (mti.stock_enabled_flag,'N','N', v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
                        mtl_system_items  mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_TRANSACTIONS_ENABLED
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE l_trans_cntrl_level IN ( G_UNDER_STATUS_CONTROL, G_DEFAULT_CONTROL)
   AND    msi.inventory_item_id   = p_Item_Id
--   AND    msi.stock_enabled_flag = 'Y'       /* commented for bug 3375455 */
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   /* Updating pending Item Status */
   UPDATE mtl_system_items msi
   SET    msi.purchasing_enabled_flag =
               (SELECT DECODE(mti.purchasing_item_flag,'N','N',v.attribute_value)
                FROM   mtl_status_attribute_values v,
                       mtl_item_attributes a,
                       mtl_system_items mti
                WHERE  v.inventory_item_status_code = p_pending_status
                AND    a.attribute_name       = G_PURCHASING_ENABLED
                AND    a.attribute_name       = v.attribute_name
                AND    mti.inventory_item_id  = p_Item_Id
                AND    mti.organization_id    = p_Org_Id)
   WHERE l_purch_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id    = p_Item_Id
   AND    msi.purchasing_item_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   UPDATE mtl_system_items msi
   SET    msi.invoice_enabled_flag =
               ( SELECT DECODE(mti.invoiceable_item_flag,'N','N',v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
                        mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_INVOICE_ENABLED
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE l_invoice_cntrl_level in ( G_UNDER_STATUS_CONTROL, G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id   = p_Item_Id
   AND    msi.invoiceable_item_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   UPDATE mtl_system_items msi
   SET    msi.build_in_wip_flag =
               ( SELECT DECODE(mti.inventory_item_flag,'N','N',decode(mti.bom_item_type,4,v.attribute_value,'N'))
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
			mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_BUILD_IN_WIP
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE l_wip_cntrl_level IN ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id   = p_Item_Id
   AND    msi.inventory_item_flag = 'Y'
   AND    msi.bom_item_type = 4
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

   UPDATE mtl_system_items msi
   SET    msi.customer_order_enabled_flag =
               ( SELECT DECODE(mti.customer_order_flag,'N','N',v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
                        mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_CUSTOMER_ENABLED
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE l_cust_cntrl_level IN (G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL)
   AND    msi.inventory_item_id   = p_Item_Id
   AND    msi.customer_order_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));


   UPDATE mtl_system_items msi
   SET    msi.internal_order_enabled_flag =
               ( SELECT DECODE(mti.internal_order_flag,'N','N',v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a,
                        mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_INTERNAL_ENABLED
                 AND    a.attribute_name       = v.attribute_name
                 AND    mti.inventory_item_id  = p_Item_Id
                 AND    mti.organization_id    = p_Org_Id)
   WHERE l_int_cntrl_level IN ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id   = p_Item_Id
   AND    msi.internal_order_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));


   UPDATE mtl_system_items msi
   SET    msi.bom_enabled_flag =
               ( SELECT v.attribute_value --Bug:3546140DECODE(mti.inventory_item_flag,'N','N',v.attribute_value)
                 FROM   mtl_status_attribute_values v,
                        mtl_item_attributes a
--Bug:3546140          ,mtl_system_items mti
                 WHERE  v.inventory_item_status_code = p_pending_status
                 AND    a.attribute_name       = G_BOM_ENABLED
                 AND    a.attribute_name       = v.attribute_name
--                 AND    mti.inventory_item_id  = p_Item_Id
--                 AND    mti.organization_id    = p_Org_Id
		 )
   WHERE l_bom_cntrl_level IN ( G_UNDER_STATUS_CONTROL, G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id   = p_Item_Id
--Bug:3546140   AND    msi.inventory_item_flag = 'Y'
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

/* Start Bug 3713912 */
--update recipe enabled flag based on status
  UPDATE mtl_system_items msi
   SET   msi.recipe_enabled_flag =
               (SELECT v.attribute_value
                FROM   mtl_status_attribute_values v,
                       mtl_item_attributes a
                WHERE  v.inventory_item_status_code = p_pending_status
                AND    a.attribute_name       = G_RECIPE_ENABLED
                AND    a.attribute_name       = v.attribute_name)
   WHERE l_recipe_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id    = p_Item_Id
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

--update process_execution enabled flag based on status
--Bug 5346921 process execution enabled should not be enabled if either inventory flag is 'N' or recipe enabled is 'N'
   UPDATE mtl_system_items msi
   SET    msi.PROCESS_EXECUTION_ENABLED_FLAG =
               (SELECT decode(msi.inventory_item_flag,'N','N',
	                       decode(msi.recipe_enabled_flag,'N','N',v.attribute_value))
                FROM   mtl_status_attribute_values v,
                       mtl_item_attributes a
                WHERE  v.inventory_item_status_code = p_pending_status
                AND    a.attribute_name       = G_PROCESS_EXECUTION_ENABLED
                AND    a.attribute_name       = v.attribute_name)
   WHERE l_process_exec_cntrl_level in ( G_UNDER_STATUS_CONTROL,G_DEFAULT_CONTROL )
   AND    msi.inventory_item_id    = p_Item_Id
   AND     ((p_control_level = G_ITEM_ORG  AND msi.organization_id = p_Org_Id)
             OR
            (p_control_level = G_ITEM
             AND msi.organization_id IN
                                (SELECT p2.organization_id
                                 FROM   mtl_parameters p1,
                                        mtl_parameters p2
                                 WHERE  p1.organization_id        = p_Org_Id
                                 AND    p1.master_organization_id = p2.master_organization_id)));

/* End Bug 3713912 */
   UPDATE mtl_pending_item_status
   SET    pending_flag           = 'N' ,
          implemented_date       = SYSDATE ,
          request_id             = G_REQUEST_ID,
          program_application_id = G_PROG_APPID,
          program_id             = G_PROG_ID,
          program_update_date    = SYSDATE,
	  last_update_login      = G_LOGIN_ID,
          last_updated_by        = G_USER_ID
   WHERE  status_code            = p_pending_status
   AND    organization_id        = p_Org_Id
   AND    inventory_item_id      = p_Item_Id
   AND    effective_date        <= SYSDATE
   AND    pending_flag           = 'Y';

/*Start  Bug#7454766
Calling INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs with p_dml_type => 'DELETE', when l_status_code = 'Inactive', l_purch_enbl='N' AND  l_int_ordr_enbl='N'
*/
  OPEN  c_get_values_from_msib(p_item_id, p_org_id);
   FETCH c_get_values_from_msib
         INTO l_status_code, l_purch_enbl, l_int_ordr_enbl;
   CLOSE c_get_values_from_msib;

 if(l_status_code = 'Inactive') THEN

    if (l_purch_enbl='N' AND  l_int_ordr_enbl='N') THEN

   INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
           p_entity_type       => 'ITEM'
          ,p_dml_type          => 'DELETE'
          ,p_inventory_item_id => p_Item_Id
          ,p_organization_id   => p_org_id);
   end if;
end if;

/*End  Bug#7454766 */

   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

   p_return_status := TRUE;

-- Added for 5230429
else
  p_return_status := FALSE;
end if;

EXCEPTION
   WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
     p_return_status := FALSE;
     --Write to LOG unable to lock the Item.
     INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_LOCK_ITEM_FAILED'
                             ,p_token1    =>  'ORG_ID'
                             ,p_value1    =>  TO_CHAR(p_Org_Id)
                             ,p_token2    =>  'ITEM_ID'
                             ,p_value2    =>  TO_CHAR(p_Item_Id)
                             ,p_token3    =>  'STATUS_CODE'
                             ,p_value3    =>  p_pending_status);
   WHEN OTHERS THEN
     p_return_status := FALSE;
     --Write to LOG regarding the Exception.
     INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  SUBSTRB(SQLERRM, 1,240));

END update_item_attributes;

PROCEDURE Process_Pending_Status(ERRBUF          OUT  NOCOPY   VARCHAR2
			        ,RETCODE         OUT  NOCOPY   NUMBER
				,p_Org_Id        IN   NUMBER   := NULL
				,p_Item_Id       IN   NUMBER   := NULL
                                ,p_commit        IN   VARCHAR2 :=  FND_API.g_TRUE
                                ,p_prog_appid    IN   NUMBER   := NULL
                                ,p_prog_id       IN   NUMBER   := NULL
                                ,p_request_id    IN   NUMBER   := NULL
                                ,p_user_id       IN   NUMBER   := NULL
				,p_login_id      IN   NUMBER   :=  NULL
                                ,p_init_msg_list IN   VARCHAR2 :=  FND_API.G_TRUE
				,p_msg_logname   IN   VARCHAR2 := 'FILE')
IS
   CURSOR c_status_pending_items (cp_org_id  NUMBER
                                 ,cp_item_id NUMBER)
   IS
      SELECT   pis.status_code,
               pis.inventory_item_id,
               pis.organization_id
      FROM     mtl_pending_item_status pis,
               mtl_item_status       pit
      WHERE    pis.effective_date    <= sysdate
      AND      pis.pending_flag      = 'Y'
      AND      pis.inventory_item_id = nvl(cp_item_id,pis.inventory_item_id)
      AND      pis.organization_id   = nvl(cp_org_id,pis.organization_id)
      AND      pis.status_code       = pit.inventory_item_status_code
      AND  nvl(pit.disable_date,sysdate+1)  > sysdate
      --2800987 : When called from PLM, p_msg_logname is PLM_LOG, through CP it is FILE.
      AND  ((p_msg_logname ='FILE' AND lifecycle_id IS NULL) OR (p_msg_logname ='PLM_LOG'))
      --2772279 -last_update_date,rowid in order clause
      ORDER BY  pis.effective_date,pis.last_update_date,pis.rowid;

    CURSOR c_get_control_level
    IS
       SELECT control_level
       FROM   mtl_item_attributes
       WHERE  attribute_name = G_STATUS_CODE;

    CURSOR c_get_status_control (cp_attrib_name VARCHAR2)
    IS
       SELECT status_control_code
       FROM   mtl_item_attributes
       WHERE  attribute_name = cp_attrib_name;

    l_status_code          mtl_pending_item_status.status_code%TYPE;
    l_item_id              mtl_pending_item_status.inventory_item_id%TYPE;
    l_org_id               mtl_pending_item_status.organization_id%TYPE;
    l_control_level        mtl_item_attributes.control_level%TYPE;
    l_done                 BOOLEAN := FALSE;
    l_counter              NUMBER  := 1;

BEGIN

   G_USER_ID    := NVL(p_user_id,    FND_GLOBAL.user_id         );
   G_LOGIN_ID   := NVL(p_login_id,   FND_GLOBAL.login_id        );
   G_PROG_APPID := NVL(p_prog_appid, FND_GLOBAL.prog_appl_id    );
   G_PROG_ID    := NVL(p_prog_id,    FND_GLOBAL.conc_program_id );
   G_REQUEST_ID := NVL(p_request_id, FND_GLOBAL.conc_request_id );

   INV_ITEM_MSG.Initialize;
   INV_ITEM_MSG.set_Message_Mode (p_msg_logname);
   INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Error);

   IF FND_API.To_Boolean (p_init_msg_list) THEN
      INV_ITEM_MSG.Initialize_Error_Handler;
   END IF;

   WHILE (l_counter < 3) LOOP
      OPEN c_status_pending_items (cp_org_id  => P_Org_Id
                                  ,cp_item_id => P_Item_Id);
      LOOP
         FETCH c_status_pending_items
         INTO l_status_code, l_item_id, l_org_id;
         EXIT WHEN c_status_pending_items%NOTFOUND;

         OPEN  c_get_control_level;
         FETCH c_get_control_level INTO l_control_level;
         CLOSE c_get_control_level;


         update_item_attributes(p_pending_status => l_status_code
  	  	               ,p_control_level  => l_control_level
			       ,p_Org_Id         => l_org_id
			       ,p_item_id        => l_Item_Id
			       ,p_commit         => p_commit
			       ,p_return_status  => l_done);

         IF (l_done AND p_msg_logname = 'FILE') THEN
            --Write to the log  Updated : Org, Item id, Status Code
	    INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_UPDT_ITEM_STATUS'
                                    ,p_token1    =>  'ORG_ID'
                                    ,p_value1    =>  TO_CHAR(l_org_id)
                                    ,p_token2    =>  'ITEM_ID'
                                    ,p_value2    =>  TO_CHAR(l_Item_Id)
                                    ,p_token3    =>  'STATUS_CODE'
                                    ,p_value3    =>  l_status_code);

         END IF;

      END LOOP;

      CLOSE c_status_pending_items;
      l_counter := l_counter + 1;

   END LOOP;

   RETCODE := G_SUCCESS;
   ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_UIPS_SUCCESS');

   OPEN c_status_pending_items (cp_org_id  => P_Org_Id
                               ,cp_item_id => P_Item_Id);
   LOOP
      FETCH c_status_pending_items
      INTO l_status_code, l_item_id, l_org_id;
      EXIT WHEN c_status_pending_items%NOTFOUND;

      -- Added for Bug 5230429
      /*commented for bug 5479302
      If (G_BOM_status =1) then
      -- Write to log mentioning Couldnt not update since there are items in a Bill of Material
         INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_BOM_ITEM_TYPE_UP'
                                 ,p_token1    =>  'ORG_ID'
                                 ,p_value1    =>  TO_CHAR(l_Org_Id)
                                 ,p_token2    =>  'ITEM_ID'
                                 ,p_value2    =>  TO_CHAR(l_Item_Id)
                                 ,p_token3    =>  'STATUS_CODE'
                                 ,p_value3    =>  l_status_code);
         G_BOM_status := 0;
      end if; */

      if (G_Transactable_status) then
      -- Write to log mentioning Couldnt not update since there are Open Sales Order lines.
         INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_TRANSACTABLE_YES_NO'
                                 ,p_token1    =>  'ORG_ID'
                                 ,p_value1    =>  TO_CHAR(l_Org_Id)
                                 ,p_token2    =>  'ITEM_ID'
                                 ,p_value2    =>  TO_CHAR(l_Item_Id)
                                 ,p_token3    =>  'STATUS_CODE'
                                 ,p_value3    =>  l_status_code);
         G_Transactable_status := FALSE;
      end if;

      if (G_TRANSACTABLE = 1) then
      -- Write to log mentioning Couldnt not update since there are Open Sales Order lines.
         INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_TRANSACTABLE_UNCHECK'
                                 ,p_token1    =>  'ORG_ID'
                                 ,p_value1    =>  TO_CHAR(l_Org_Id)
                                 ,p_token2    =>  'ITEM_ID'
                                 ,p_value2    =>  TO_CHAR(l_Item_Id)
                                 ,p_token3    =>  'STATUS_CODE'
                                 ,p_value3    =>  l_status_code);
         G_TRANSACTABLE := 0;
      end if;

      if (G_ORDERABLE = 1) then
      -- Write to log mentioning Couldnt not update since there are Open Sales Order lines.
         INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_CUST_ORDERABLE_UNCHECK'
                                 ,p_token1    =>  'ORG_ID'
                                 ,p_value1    =>  TO_CHAR(l_Org_Id)
                                 ,p_token2    =>  'ITEM_ID'
                                 ,p_value2    =>  TO_CHAR(l_Item_Id)
                                 ,p_token3    =>  'STATUS_CODE'
                                 ,p_value3    =>  l_status_code);
         G_ORDERABLE := 0;
      end if;

      if (G_PURCHASABLE = 1) then
      -- Write to log mentioning Couldnt not update since there are Open Sales Order lines.
         INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_PURCHASABLE_UNCHECK'
                                 ,p_token1    =>  'ORG_ID'
                                 ,p_value1    =>  TO_CHAR(l_Org_Id)
                                 ,p_token2    =>  'ITEM_ID'
                                 ,p_value2    =>  TO_CHAR(l_Item_Id)
                                 ,p_token3    =>  'STATUS_CODE'
                                 ,p_value3    =>  l_status_code);
         G_PURCHASABLE := 0;
      end if;


      -- Write to log mentioning Couldnt not update Org, Item id, Status Code
      INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  'INV_UPDT_ITEM_STATUS_FAIL'
                              ,p_token1    =>  'ORG_ID'
                              ,p_value1    =>  TO_CHAR(l_org_id)
                              ,p_token2    =>  'ITEM_ID'
                              ,p_value2    =>  TO_CHAR(l_Item_Id)
                              ,p_token3    =>  'STATUS_CODE'
                              ,p_value3    =>  l_status_code);
      RETCODE := G_WARNING;
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_UIPS_WARNING');
   END LOOP;
   CLOSE c_status_pending_items;

   IF p_msg_logname = 'FILE' THEN
      INV_ITEM_MSG.Write_List (p_delete => TRUE);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF (c_status_pending_items%ISOPEN) THEN
         CLOSE c_status_pending_items;
      END IF;
      IF (c_get_control_level%ISOPEN) THEN
         CLOSE c_get_control_level;
      END IF;
      RETCODE := G_ERROR;
      ERRBUF  := FND_MESSAGE.Get_String('INV', 'INV_UIPS_FAILURE');
      INV_ITEM_MSG.Add_Message(p_Msg_Name  =>  SUBSTRB(SQLERRM, 1,240));

      IF p_msg_logname = 'FILE' THEN
         INV_ITEM_MSG.Write_List (p_delete => TRUE);
      END IF;

END Process_Pending_Status;

-- Fix for bug#9297937
-- ERES in Deferred during Item Creation
PROCEDURE Create_Item_ERES_Event ( p_commit             IN  VARCHAR2  := fnd_api.g_false,
                                   p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
                                   p_event_name         IN  VARCHAR2,
                                   p_event_key          IN  VARCHAR2,
                                   p_caller_type        IN  VARCHAR2,
                                   p_org_id             IN  NUMBER,
                                   p_inventory_item_id  IN  NUMBER)
AS

l_return_status varchar2(3);
l_msg_count     number;
l_msg_data      varchar2(2000);

BEGIN

  Create_Item_ERES_Event
  (
    p_commit             => p_commit,
    p_init_msg_list      => p_init_msg_list,
    p_event_name         => p_event_name,
    p_event_key          => p_event_key,
    p_caller_type        => p_caller_type,
    p_org_id             => p_org_id,
    p_inventory_item_id  => p_inventory_item_id,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data );
END;

-- Fix for bug#9297937
-- ERES in Deferred during Item Creation
PROCEDURE Create_Item_ERES_Event
(
  p_commit             IN  VARCHAR2  := fnd_api.g_false,
  p_init_msg_list      IN  VARCHAR2  := fnd_api.g_false,
  p_event_name         IN  VARCHAR2,
  p_event_key          IN  VARCHAR2,
  p_caller_type        IN  VARCHAR2,
  p_org_id             IN  NUMBER,
  p_inventory_item_id  IN  NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2 )

AS

  l_control_level         number;
  l_return_status         boolean;
  l_api_name    CONSTANT  varchar2(30)  :=  'Create_Item_ERES_Event';
  l_eres_status           varchar2(30);
  l_status_code           varchar2(30);

  CURSOR c_get_control_level
  IS
  SELECT control_level
  FROM   mtl_item_attributes
  WHERE  attribute_name = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  create_item_eres_event;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.g_RET_STS_SUCCESS;

  -- Derive the control level
  OPEN  c_get_control_level;
  FETCH c_get_control_level INTO l_control_level;
  CLOSE c_get_control_level;

  -- Derive the status
  EDR_STANDARD.PSIG_STATUS
      (
       p_event     => p_event_name,
       p_event_key => p_event_key,
       p_status    => l_eres_status
    );

  -- Check for caller type
  IF ( p_Caller_type = 'CREATE_ITEM_PRE_APPROVAL') THEN
    l_status_code := 'Inactive';
  ELSIF ( p_Caller_type = 'CREATE_ITEM_POST_APPROVAL') THEN
    IF (l_eres_status = 'COMPLETE') THEN
      l_status_code := NVL(fnd_profile.value('INV_STATUS_DEFER_ERES_APPROVED'),'Active');
    ELSIF (l_eres_status = 'REJECTED') THEN
      l_status_code := 'ERESReject';
    END IF;
  END IF;



  IF ((p_Caller_type = 'CREATE_ITEM_PRE_APPROVAL')
      OR (p_Caller_type = 'CREATE_ITEM_POST_APPROVAL'
          AND l_eres_status in ('COMPLETE','REJECTED'))) THEN


    -- Call the API to update the status
    update_item_attributes(p_pending_status  => l_status_code
                           ,p_control_level  => l_control_level
  			   ,p_Org_Id         => p_org_id
			   ,p_Item_id        => p_inventory_item_id
                           ,p_commit         => FND_API.g_TRUE
			   ,p_return_status  => l_return_status);

    -- Check if there are any errors
    IF ( NOT l_return_status ) THEN

      IF (G_Transactable_status) THEN

        FND_MESSAGE.SET_NAME('INV','INV_TRANSACTABLE_YES_NO');
        FND_MESSAGE.SET_TOKEN('ORG_ID',TO_CHAR(p_org_Id));
        FND_MESSAGE.SET_TOKEN('ITEM_ID',TO_CHAR(p_inventory_item_id));
        FND_MESSAGE.SET_TOKEN('STATUS_CODE',l_status_code);
        FND_MSG_PUB.Add;

        G_Transactable_status := FALSE;

      END IF;

      IF (G_TRANSACTABLE = 1) THEN

        FND_MESSAGE.SET_NAME('INV','INV_TRANSACTABLE_UNCHECK');
        FND_MESSAGE.SET_TOKEN('ORG_ID',TO_CHAR(p_org_Id));
        FND_MESSAGE.SET_TOKEN('ITEM_ID',TO_CHAR(p_inventory_item_id));
        FND_MESSAGE.SET_TOKEN('STATUS_CODE',l_status_code);
        FND_MSG_PUB.Add;

        G_TRANSACTABLE := 0;

      END IF;

      IF (G_ORDERABLE = 1) THEN

        FND_MESSAGE.SET_NAME('INV','INV_CUST_ORDERABLE_UNCHECK');
        FND_MESSAGE.SET_TOKEN('ORG_ID',TO_CHAR(p_org_Id));
        FND_MESSAGE.SET_TOKEN('ITEM_ID',TO_CHAR(p_inventory_item_id));
        FND_MESSAGE.SET_TOKEN('STATUS_CODE',l_status_code);
        FND_MSG_PUB.Add;

        G_ORDERABLE := 0;

      END IF;

      IF (G_PURCHASABLE = 1) THEN

        FND_MESSAGE.SET_NAME('INV','INV_PURCHASABLE_UNCHECK');
        FND_MESSAGE.SET_TOKEN('ORG_ID',TO_CHAR(p_org_Id));
        FND_MESSAGE.SET_TOKEN('ITEM_ID',TO_CHAR(p_inventory_item_id));
        FND_MESSAGE.SET_TOKEN('STATUS_CODE',l_status_code);
        FND_MSG_PUB.Add;

        G_PURCHASABLE := 0;

      END IF;

      RAISE FND_API.G_EXC_ERROR;

    END IF;

  END IF;

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
  (   p_count  =>  x_msg_count
  ,   p_data   =>  x_msg_data
  );


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_item_eres_event;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data  );

  WHEN OTHERS THEN
    ROLLBACK TO create_item_eres_event;
    x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

    IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME,
                   l_api_name );
    END IF;

    FND_MSG_PUB.Count_And_Get
      (p_count  =>  x_msg_count,
       p_data   =>  x_msg_data );

END Create_Item_ERES_Event;

end INV_ITEM_STATUS_CP;

/
