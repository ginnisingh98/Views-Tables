--------------------------------------------------------
--  DDL for Package Body INVPULI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPULI2" AS
/* $Header: INVPUL2B.pls 120.14.12010000.8 2010/08/27 09:45:00 ccsingh ship $ */
FUNCTION copy_template_attributes(
   org_id     IN            NUMBER
  ,all_org    IN            NUMBER  := 2
  ,prog_appid IN            NUMBER  := -1
  ,prog_id    IN            NUMBER  := -1
  ,request_id IN            NUMBER  := -1
  ,user_id    IN            NUMBER  := -1
  ,login_id   IN            NUMBER  := -1
  ,xset_id    IN            NUMBER  := -999
  ,err_text   IN OUT NOCOPY VARCHAR2
) RETURN INTEGER IS

   CURSOR item_rec IS
      SELECT inventory_item_id,
             organization_id,
             item_catalog_group_id,
             template_id,
         template_name,
         transaction_id,
         transaction_type,
             rowid,
         style_item_flag
      FROM MTL_SYSTEM_ITEMS_INTERFACE
      WHERE process_flag = 1
      AND   set_process_id = xset_id
      AND  ((organization_id = org_id) or (all_org = 1));

   CURSOR check_template_name (cp_template_name VARCHAR2) IS
      SELECT template_id,
             context_organization_id
      FROM   mtl_item_templates
      WHERE  template_name = cp_template_name;

   CURSOR check_template_id (cp_template_id NUMBER) IS
      SELECT template_id,
             context_organization_id
      FROM   mtl_item_templates
      WHERE  template_id = cp_template_id;

   /*Added for bug 8848620 fp for 7581972 and 8808831 */

    CURSOR get_icc_id ( cp_inventory_item_id NUMBER, cp_organization_id NUMBER)  /* 8808831 FP added cursor */
    IS
      select item_catalog_group_id
      from   mtl_system_items_b
      where  inventory_item_id = cp_inventory_item_id
      and    organization_id = cp_organization_id;


    CURSOR check_template_name_icc (cp_template_name VARCHAR2,cp_cat_grp_id NUMBER) IS
    SELECT TEMPLATE_ID,
           CONTEXT_ORGANIZATION_ID
    FROM   MTL_ITEM_TEMPLATES MIT
    WHERE  TEMPLATE_NAME = CP_TEMPLATE_NAME
           AND EXISTS (SELECT 1
                       FROM   EGO_CAT_GRP_TEMPLATES
                       WHERE  CATALOG_GROUP_ID IN (SELECT ITEM_CATALOG_GROUP_ID
                                                   FROM   MTL_ITEM_CATALOG_GROUPS_B
                                                   START WITH ITEM_CATALOG_GROUP_ID = CP_CAT_GRP_ID
                                                   CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID)
                              AND TEMPLATE_ID = MIT.TEMPLATE_ID);

    CURSOR check_template_id_icc (cp_template_id NUMBER,cp_cat_grp_id NUMBER) IS
    SELECT TEMPLATE_ID,
           CONTEXT_ORGANIZATION_ID
    FROM   MTL_ITEM_TEMPLATES MIT
    WHERE  TEMPLATE_ID = CP_TEMPLATE_ID
           AND EXISTS (SELECT 1
                       FROM   EGO_CAT_GRP_TEMPLATES
                       WHERE  CATALOG_GROUP_ID IN (SELECT ITEM_CATALOG_GROUP_ID
                                                   FROM   MTL_ITEM_CATALOG_GROUPS_B
                                                   START WITH ITEM_CATALOG_GROUP_ID = CP_CAT_GRP_ID
                                                   CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID)
                              AND TEMPLATE_ID = MIT.TEMPLATE_ID);

    /*End of bug 8848620 */



   CURSOR get_template_values(cp_template_id NUMBER) IS
      SELECT attribute_name,
             attribute_value
      FROM   mtl_item_templ_attributes
      WHERE  template_id = cp_template_id
      AND    enabled_flag = 'Y'
      AND    attribute_name IN
               (SELECT  a.attribute_name
                FROM  mtl_item_attributes  a
                WHERE  NVL(a.status_control_code, 3) <> 1
                  AND  a.control_level IN (1, 2)
                  AND  a.attribute_group_id_gui IS NOT NULL);


   CURSOR global_flex(cp_template_id NUMBER) IS
      SELECT
         GLOBAL_ATTRIBUTE_CATEGORY,
         GLOBAL_ATTRIBUTE1,
         GLOBAL_ATTRIBUTE2,
         GLOBAL_ATTRIBUTE3,
         GLOBAL_ATTRIBUTE4,
         GLOBAL_ATTRIBUTE5,
         GLOBAL_ATTRIBUTE6,
         GLOBAL_ATTRIBUTE7,
         GLOBAL_ATTRIBUTE8,
         GLOBAL_ATTRIBUTE9,
         GLOBAL_ATTRIBUTE10,
         GLOBAL_ATTRIBUTE11,
         GLOBAL_ATTRIBUTE12,
         GLOBAL_ATTRIBUTE13,
         GLOBAL_ATTRIBUTE14,
         GLOBAL_ATTRIBUTE15,
         GLOBAL_ATTRIBUTE16,
         GLOBAL_ATTRIBUTE17,
         GLOBAL_ATTRIBUTE18,
         GLOBAL_ATTRIBUTE19,
         GLOBAL_ATTRIBUTE20
      FROM MTL_ITEM_TEMPLATES MIT
      WHERE MIT.template_id = cp_template_id;

   --Bug:6282388
   CURSOR isMasterOrg(cp_orgid NUMBER)
   IS
     SELECT COUNT(1)
       FROM mtl_parameters mp
      WHERE mp.master_organization_id = cp_orgid
        AND rownum = 1;

   l_isMasterOrg   NUMBER;
   AttRec          MTL_SYSTEM_ITEMS_B%ROWTYPE;
   context_orgid   mtl_item_templates.context_organization_id%TYPE;
   l_template_id   mtl_item_templates.template_id%TYPE := NULL;
   rtn_status      number := 0;
   dumm_status     number := 0;
   LOGGING_ERR     EXCEPTION;
   l_error_exists  BOOLEAN := FALSE;
   l_column_name   VARCHAR2(200);
   l_message_name  VARCHAR2(200);
   l_cat_templ_count NUMBER := 0;
   l_icc_id          mtl_system_items_b.item_catalog_group_id%TYPE := NULL;

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452

   TYPE template_id_type IS TABLE OF
     mtl_item_templates.template_id%TYPE
   INDEX BY BINARY_INTEGER;

   --Bug 4456453
   TYPE transaction_table_type IS TABLE OF
     mtl_system_items_interface.transaction_type%TYPE;

   template_table  template_id_type;
   transaction_table  transaction_table_type;  --Bug: 4456453

   l_ego_cat_grp_flag VARCHAR2(10); --Bug:7033786

  /* bug 10064010
   --serial_tagging enh -- bug 9913552
   x_ret_sts VARCHAR2(1);*/

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPULI2: begin copy_template_attributes');
   END IF;

   --added for bug: 7033786
   l_ego_cat_grp_flag := INV_ITEM_UTIL.Object_Exists(p_object_type => 'SYNONYM',p_object_name => 'EGO_CAT_GRP_TEMPLATES');


   -- Populate Template Ids.
   FOR cur IN item_rec LOOP

      l_template_id  := NULL;
      l_error_exists := FALSE;
      l_column_name  := NULL;
      l_message_name := NULL;
      --l_transaction_type := cur.transaction_type;  --Bug: 4456453 Get transaction_id

       /*Added for bug 8848620 fp for 7581972 and 8808831 */

       IF cur.item_catalog_group_id IS NOT NULL THEN
        SELECT COUNT(1)
        INTO   L_CAT_TEMPL_COUNT
        FROM   EGO_CAT_GRP_TEMPLATES
        WHERE  CATALOG_GROUP_ID IN (SELECT ITEM_CATALOG_GROUP_ID
                                    FROM   MTL_ITEM_CATALOG_GROUPS_B
                                    START WITH ITEM_CATALOG_GROUP_ID = CUR.ITEM_CATALOG_GROUP_ID
                                    CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID);

       ELSIF cur.item_catalog_group_id IS NULL AND cur.transaction_type = 'UPDATE' THEN

         FOR rec_get_icc_id IN get_icc_id(cur.inventory_item_id, cur.organization_id)
         LOOP
           l_icc_id := rec_get_icc_id.item_catalog_group_id;
         END LOOP;

        SELECT COUNT(1)
        INTO   L_CAT_TEMPL_COUNT
        FROM   EGO_CAT_GRP_TEMPLATES
        WHERE  CATALOG_GROUP_ID IN (SELECT ITEM_CATALOG_GROUP_ID
                                    FROM   MTL_ITEM_CATALOG_GROUPS_B
                                    START WITH ITEM_CATALOG_GROUP_ID = (SELECT NVL(ITEM_CATALOG_GROUP_ID,0)
                                                                        FROM   MTL_SYSTEM_ITEMS_B
                                                                        WHERE  INVENTORY_ITEM_ID = CUR.INVENTORY_ITEM_ID
                                                                                      AND  ORGANIZATION_ID = CUR.ORGANIZATION_ID)
                                    CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID = ITEM_CATALOG_GROUP_ID);
       END IF;

       /*End of bug 8848620 */

      IF cur.template_id IS NULL AND  cur.template_name IS NOT NULL AND l_cat_templ_count=0 THEN

            OPEN  check_template_name(cur.template_name);
            FETCH check_template_name INTO l_template_id,context_orgid;
            CLOSE check_template_name;

             IF l_template_id IS NULL THEN
                    l_error_exists := TRUE;
                    l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                    l_message_name := 'INV_TEMPLATE_ERROR';
             END IF;

             IF context_orgid IS NOT NULL AND context_orgid <> cur.organization_id THEN
                    l_error_exists := TRUE;
                    l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                    l_message_name := 'INV_ORG_TEMPLATE_ERROR';
             END IF;

      ELSIF cur.template_id IS NOT NULL AND cur.template_id > 0 AND l_cat_templ_count = 0
            AND cur.template_id <> FND_API.G_MISS_NUM THEN /*bug8942177*/

             OPEN  check_template_id(cur.template_id);
             FETCH check_template_id INTO l_template_id,context_orgid;
             CLOSE check_template_id;

             IF l_template_id IS NULL THEN
                    l_error_exists := TRUE;
                    l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                    l_message_name := 'INV_TEMPLATE_ERROR';
                 END IF;

             IF context_orgid IS NOT NULL AND context_orgid <> cur.organization_id THEN
                    l_error_exists := TRUE;
                    l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                    l_message_name := 'INV_ORG_TEMPLATE_ERROR';
             END IF;
      ELSIF cur.template_id IS NULL AND  cur.template_name IS NOT NULL AND l_cat_templ_count <> 0 THEN /*When ICC has defined Templates*/

              OPEN  check_template_name_icc(cur.template_name,NVL(cur.item_catalog_group_id,l_icc_id)); /* 8808831 FP added NVL */
              FETCH check_template_name_icc INTO l_template_id,context_orgid;
              CLOSE check_template_name_icc;

              IF l_template_id IS NULL THEN
                         l_error_exists := TRUE;
                         l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                         l_message_name := 'INV_TEMPLATE_ERROR';
              END IF;

              IF context_orgid IS NOT NULL AND context_orgid <> cur.organization_id THEN
                 l_error_exists := TRUE;
                 l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                 l_message_name := 'INV_ORG_TEMPLATE_ERROR';
              END IF;

      ELSIF cur.template_id IS NOT NULL AND cur.template_id > 0 AND l_cat_templ_count <> 0
            AND cur.template_id <> FND_API.G_MISS_NUM THEN /*bug8942177*/ /*When ICC has defined Templates*/

              OPEN  check_template_id_icc(cur.template_id,NVL(cur.item_catalog_group_id,l_icc_id)); /* 8808831 FP added NVL */
              FETCH check_template_id_icc INTO l_template_id,context_orgid;
              CLOSE check_template_id_icc;

              IF l_template_id IS NULL THEN
                         l_error_exists := TRUE;
                         l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                         l_message_name := 'INV_TEMPLATE_ERROR';
              END IF;

              IF context_orgid IS NOT NULL AND context_orgid <> cur.organization_id THEN
                                 l_error_exists := TRUE;
                                 l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
                                 l_message_name := 'INV_ORG_TEMPLATE_ERROR';
              END IF;


      ELSIF  (cur.template_id IS NULL)
         AND (cur.TRANSACTION_TYPE = 'CREATE')
         AND (cur.ITEM_CATALOG_GROUP_ID IS NOT NULL)
     AND (INV_ITEM_UTIL.Appl_Inst_EGO > 0)
     --AND (INV_ITEM_UTIL.Object_Exists(p_object_type => 'SYNONYM', p_object_name => 'EGO_CAT_GRP_TEMPLATES') = 'Y')
     --end added for bug: 7033786
         AND (l_ego_cat_grp_flag = 'Y')
       -- Adding the below clause to prevent application of default templates in the case of SKU Item
         AND ( cur.style_item_flag IS NULL OR cur.style_item_flag = 'Y')
      THEN
         --Bug 6282388
         OPEN  isMasterOrg(cur.organization_id);
     FETCH isMasterOrg INTO l_isMasterOrg;
     CLOSE isMasterOrg;
     IF ( l_isMasterOrg = 1 ) THEN
            l_template_id := INV_EGO_REVISION_VALIDATE.get_default_template(cur.ITEM_CATALOG_GROUP_ID);
     END IF;

      ELSIF (cur.template_id IS NULL)
        AND (cur.TRANSACTION_TYPE = 'CREATE')
        -- Adding the below clause to prevent application of default templates in the case of SKU Item
        AND ( cur.style_item_flag IS NULL OR cur.style_item_flag = 'Y')
      THEN
         --Bug 6282388
         OPEN  isMasterOrg(cur.organization_id);
     FETCH isMasterOrg INTO l_isMasterOrg;
     CLOSE isMasterOrg;
     IF ( l_isMasterOrg = 1 ) THEN
            INVPROFL.inv_pr_get_profile('INV',
                                    'INV_ITEM_DEFAULT_TEMPLATE',
                                     user_id,
                                     -1,
                                     -1,
                                     l_template_id,
                                     rtn_status,
                                     err_text);

        IF rtn_status <> -9999 AND rtn_status <> 0 THEN
               l_error_exists := TRUE;
               l_column_name  := 'TEMPLATE_NAME/TEMPLATE_ID';
               l_message_name := 'INV_TEMPLATE_ERROR';
        END IF;
     END IF;
      END IF;


      IF l_error_exists THEN

         UPDATE mtl_system_items_interface
         SET    process_flag = 3
         WHERE  rowid = cur.rowid ;
     dumm_status := INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cur.transaction_id,
                                err_text,
                l_column_name,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                l_message_name,
                err_text);
         if dumm_status < 0 then
            raise LOGGING_ERR;
         end if;

      ELSIF l_template_id IS NOT NULL AND l_template_id <> NVL (cur.template_id,0) THEN
         UPDATE mtl_system_items_interface
     SET    template_id = l_template_id
     WHERE  rowid       = cur.rowid;
      END IF;
     /* bug 10064010, instead of this we will call in process phase invupd2b
     -- serial_Tagging enh -- bug 9913552
     IF (l_template_id IS NOT NULL) AND (cur.inventory_item_id IS NOT NULL) THEN

         IF  (INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_template_id => l_template_id)=2) THEN
              INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
	                                        p_from_template_id => l_template_id,
	                                        p_to_item_id       => cur.inventory_item_id,
	                                        p_to_org_id        => cur.organization_id,
	                                        x_return_status    =>  x_ret_sts);

            IF x_ret_sts <>FND_API.G_RET_STS_SUCCESS THEN

                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                cur.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cur.transaction_id,
                                err_text,
                                'SERIAL_TAGGING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_COPY_SER_FAIL_UNEXP',
                                err_text);
                  if dumm_status < 0 then
                     raise LOGGING_ERR;
                  end if;


            END IF;
         END IF ;
     END IF ;*/


   END LOOP;

   --We bulk collect distinct template Ids and update all the items
   --with a template id in one go. template_id > 0 since, when called
   --from ego_item_pub, it would have already applied the template.

   SELECT DISTINCT template_id, transaction_type BULK COLLECT INTO template_table, transaction_table
   FROM   mtl_system_items_interface
   WHERE process_flag = 1
   AND   set_process_id = xset_id
   AND  ((organization_id = org_id) or (all_org = 1))
   AND  template_id > 0 ;

   IF template_table.COUNT > 0 THEN
   FOR I IN template_table.FIRST .. template_table.LAST LOOP

     context_orgid := NULL;

     OPEN  check_template_id(template_table(i));
     FETCH check_template_id INTO l_template_id,context_orgid;
     CLOSE check_template_id;

     ------------------------------------
     -- Set item record attribute values
     ------------------------------------
     AttRec := NULL;
     FOR cr IN get_template_values(template_table(i)) LOOP
/*        if(transaction_table(i) = 'UPDATE') then Commented for bug 6394546 as this feature should work both for 'CREATE' and 'UPDATE' modes of IOI */
           if cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_EARLY_DAYS'             then AttRec.ACCEPTABLE_EARLY_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_DECREASE'       then AttRec.ACCEPTABLE_RATE_DECREASE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_INCREASE'       then AttRec.ACCEPTABLE_RATE_INCREASE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCOUNTING_RULE_ID'             then AttRec.ACCOUNTING_RULE_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOWED_UNITS_LOOKUP_CODE'      then AttRec.ALLOWED_UNITS_LOOKUP_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_EXPRESS_DELIVERY_FLAG'    then AttRec.ALLOW_EXPRESS_DELIVERY_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_ITEM_DESC_UPDATE_FLAG'    then AttRec.ALLOW_ITEM_DESC_UPDATE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_SUBSTITUTE_RECEIPTS_FLAG' then AttRec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_UNORDERED_RECEIPTS_FLAG'  then AttRec.ALLOW_UNORDERED_RECEIPTS_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CATEGORY_ID'              then AttRec.ASSET_CATEGORY_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_COMPONENTS_FLAG'            then AttRec.ATP_COMPONENTS_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_FLAG'                       then AttRec.ATP_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_RULE_ID'                    then AttRec.ATP_RULE_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_LOT_ALPHA_PREFIX'          then AttRec.AUTO_LOT_ALPHA_PREFIX  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_REDUCE_MPS'                then AttRec.AUTO_REDUCE_MPS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_SERIAL_ALPHA_PREFIX'       then AttRec.AUTO_SERIAL_ALPHA_PREFIX  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG'               then AttRec.BOM_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE'                  then AttRec.BOM_ITEM_TYPE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG'              then AttRec.BUILD_IN_WIP_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUYER_ID'                       then AttRec.BUYER_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CARRYING_COST'                  then AttRec.CARRYING_COST  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COLLATERAL_FLAG'                then AttRec.COLLATERAL_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG'           then AttRec.COSTING_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COVERAGE_SCHEDULE_ID'           then AttRec.COVERAGE_SCHEDULE_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUMULATIVE_TOTAL_LEAD_TIME'     then AttRec.CUMULATIVE_TOTAL_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUM_MANUFACTURING_LEAD_TIME'    then AttRec.CUM_MANUFACTURING_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG'    then AttRec.CUSTOMER_ORDER_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG'            then AttRec.CUSTOMER_ORDER_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CYCLE_COUNT_ENABLED_FLAG'       then AttRec.CYCLE_COUNT_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_EARLY_RECEIPT_ALLOWED'     then AttRec.DAYS_EARLY_RECEIPT_ALLOWED  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_LATE_RECEIPT_ALLOWED'      then AttRec.DAYS_LATE_RECEIPT_ALLOWED  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_INCLUDE_IN_ROLLUP_FLAG' then AttRec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SHIPPING_ORG'           then AttRec.DEFAULT_SHIPPING_ORG  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_CODE'         then AttRec.DEMAND_TIME_FENCE_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_DAYS'         then AttRec.DEMAND_TIME_FENCE_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.END_ASSEMBLY_PEGGING_FLAG'      then AttRec.END_ASSEMBLY_PEGGING_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENFORCE_SHIP_TO_LOCATION_CODE'  then AttRec.ENFORCE_SHIP_TO_LOCATION_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT'                then AttRec.EXPENSE_ACCOUNT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_BILLABLE_FLAG'          then AttRec.EXPENSE_BILLABLE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_DAYS_SUPPLY'              then AttRec.FIXED_DAYS_SUPPLY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LEAD_TIME'                then AttRec.FIXED_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LOT_MULTIPLIER'           then AttRec.FIXED_LOT_MULTIPLIER  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_ORDER_QUANTITY'           then AttRec.FIXED_ORDER_QUANTITY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FULL_LEAD_TIME'                 then AttRec.FULL_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARD_CLASS_ID'                then AttRec.HAZARD_CLASS_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INSPECTION_REQUIRED_FLAG'       then AttRec.INSPECTION_REQUIRED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG'    then AttRec.INTERNAL_ORDER_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG'            then AttRec.INTERNAL_ORDER_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG'           then AttRec.INVENTORY_ASSET_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_FLAG'            then AttRec.INVENTORY_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE'     then AttRec.INVENTORY_ITEM_STATUS_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_PLANNING_CODE'        then AttRec.INVENTORY_PLANNING_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG'          then AttRec.INVOICEABLE_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_CLOSE_TOLERANCE'        then AttRec.INVOICE_CLOSE_TOLERANCE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG'           then AttRec.INVOICE_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICING_RULE_ID'              then AttRec.INVOICING_RULE_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ITEM_TYPE'                      then AttRec.ITEM_TYPE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LEAD_TIME_LOT_SIZE'             then AttRec.LEAD_TIME_LOT_SIZE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT'            then AttRec.LIST_PRICE_PER_UNIT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE'          then AttRec.LOCATION_CONTROL_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE'               then AttRec.LOT_CONTROL_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MARKET_PRICE'                   then AttRec.MARKET_PRICE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATERIAL_BILLABLE_FLAG'         then AttRec.MATERIAL_BILLABLE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_ORDER_QUANTITY'         then AttRec.MAXIMUM_ORDER_QUANTITY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_MINMAX_QUANTITY'            then AttRec.MAX_MINMAX_QUANTITY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_WARRANTY_AMOUNT'            then AttRec.MAX_WARRANTY_AMOUNT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_ORDER_QUANTITY'         then AttRec.MINIMUM_ORDER_QUANTITY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MIN_MINMAX_QUANTITY'            then AttRec.MIN_MINMAX_QUANTITY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_CALCULATE_ATP_FLAG'         then AttRec.MRP_CALCULATE_ATP_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_PLANNING_CODE'              then AttRec.MRP_PLANNING_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_CODE'          then AttRec.MRP_SAFETY_STOCK_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_PERCENT'       then AttRec.MRP_SAFETY_STOCK_PERCENT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG'  then AttRec.MTL_TRANSACTIONS_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MUST_USE_APPROVED_VENDOR_FLAG'  then AttRec.MUST_USE_APPROVED_VENDOR_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEGATIVE_MEASUREMENT_ERROR'     then AttRec.NEGATIVE_MEASUREMENT_ERROR  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEW_REVISION_CODE'              then AttRec.NEW_REVISION_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDER_COST'                     then AttRec.ORDER_COST  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_FLAG'         then AttRec.OUTSIDE_OPERATION_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_UOM_TYPE'     then AttRec.OUTSIDE_OPERATION_UOM_TYPE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERRUN_PERCENTAGE'             then AttRec.OVERRUN_PERCENTAGE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PAYMENT_TERMS_ID'               then AttRec.PAYMENT_TERMS_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICKING_RULE_ID'                then AttRec.PICKING_RULE_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICK_COMPONENTS_FLAG'           then AttRec.PICK_COMPONENTS_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_MAKE_BUY_CODE'         then AttRec.PLANNING_MAKE_BUY_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_CODE'       then AttRec.PLANNING_TIME_FENCE_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_DAYS'       then AttRec.PLANNING_TIME_FENCE_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSITIVE_MEASUREMENT_ERROR'     then AttRec.POSITIVE_MEASUREMENT_ERROR  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSTPROCESSING_LEAD_TIME'       then AttRec.POSTPROCESSING_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPROCESSING_LEAD_TIME'        then AttRec.PREPROCESSING_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREVENTIVE_MAINTENANCE_FLAG'    then AttRec.PREVENTIVE_MAINTENANCE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRICE_TOLERANCE_PERCENT'        then AttRec.PRICE_TOLERANCE_PERCENT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_SPECIALIST_ID'          then AttRec.PRIMARY_SPECIALIST_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRORATE_SERVICE_FLAG'           then AttRec.PRORATE_SERVICE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG'        then AttRec.PURCHASING_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ITEM_FLAG'           then AttRec.PURCHASING_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_EXCEPTION_CODE'         then AttRec.QTY_RCV_EXCEPTION_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_TOLERANCE'              then AttRec.QTY_RCV_TOLERANCE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_DAYS_EXCEPTION_CODE'    then AttRec.RECEIPT_DAYS_EXCEPTION_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_REQUIRED_FLAG'          then AttRec.RECEIPT_REQUIRED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVE_CLOSE_TOLERANCE'        then AttRec.RECEIVE_CLOSE_TOLERANCE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVING_ROUTING_ID'           then AttRec.RECEIVING_ROUTING_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPETITIVE_PLANNING_FLAG'       then AttRec.REPETITIVE_PLANNING_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPLENISH_TO_ORDER_FLAG'        then AttRec.REPLENISH_TO_ORDER_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE'                then AttRec.RESERVABLE_TYPE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_PERIOD_CODE'      then AttRec.RESPONSE_TIME_PERIOD_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_VALUE'            then AttRec.RESPONSE_TIME_VALUE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE'         then AttRec.RESTRICT_LOCATORS_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_SUBINVENTORIES_CODE'   then AttRec.RESTRICT_SUBINVENTORIES_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURNABLE_FLAG'                then AttRec.RETURNABLE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURN_INSPECTION_REQUIREMENT'  then AttRec.RETURN_INSPECTION_REQUIREMENT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE'      then AttRec.REVISION_QTY_CONTROL_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RFQ_REQUIRED_FLAG'              then AttRec.RFQ_REQUIRED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_CONTROL_TYPE'          then AttRec.ROUNDING_CONTROL_TYPE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_FACTOR'                then AttRec.ROUNDING_FACTOR  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SAFETY_STOCK_BUCKET_DAYS'       then AttRec.SAFETY_STOCK_BUCKET_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_SPECIALIST_ID'        then AttRec.SECONDARY_SPECIALIST_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE'     then AttRec.SERIAL_NUMBER_CONTROL_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_COMPONENT_FLAG'     then AttRec.SERVICEABLE_COMPONENT_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_ITEM_CLASS_ID'      then AttRec.SERVICEABLE_ITEM_CLASS_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_PRODUCT_FLAG'       then AttRec.SERVICEABLE_PRODUCT_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION'               then AttRec.SERVICE_DURATION  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION_PERIOD_CODE'   then AttRec.SERVICE_DURATION_PERIOD_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_STARTING_DELAY'         then AttRec.SERVICE_STARTING_DELAY  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE'                then AttRec.SHELF_LIFE_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_DAYS'                then AttRec.SHELF_LIFE_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG'            then AttRec.SHIPPABLE_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIP_MODEL_COMPLETE_FLAG'       then AttRec.SHIP_MODEL_COMPLETE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHRINKAGE_RATE'                 then AttRec.SHRINKAGE_RATE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_ORGANIZATION_ID'         then AttRec.SOURCE_ORGANIZATION_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_SUBINVENTORY'            then AttRec.SOURCE_SUBINVENTORY  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_TYPE'                    then AttRec.SOURCE_TYPE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG'           then AttRec.SO_TRANSACTIONS_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_LOT_NUMBER'          then AttRec.START_AUTO_LOT_NUMBER  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_SERIAL_NUMBER'       then AttRec.START_AUTO_SERIAL_NUMBER  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STD_LOT_SIZE'                   then AttRec.STD_LOT_SIZE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG'             then AttRec.STOCK_ENABLED_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAXABLE_FLAG'                   then AttRec.TAXABLE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_TAX_CODE'            then AttRec.PURCHASING_TAX_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAX_CODE'                       then AttRec.TAX_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TIME_BILLABLE_FLAG'             then AttRec.TIME_BILLABLE_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_OF_ISSUE'                  then AttRec.UNIT_OF_ISSUE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_VOLUME'                    then AttRec.UNIT_VOLUME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WEIGHT'                    then AttRec.UNIT_WEIGHT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UN_NUMBER_ID'                   then AttRec.UN_NUMBER_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VARIABLE_LEAD_TIME'             then AttRec.VARIABLE_LEAD_TIME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOLUME_UOM_CODE'                then AttRec.VOLUME_UOM_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WARRANTY_VENDOR_ID'             then AttRec.WARRANTY_VENDOR_ID  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE'                then AttRec.WEIGHT_UOM_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_TYPE'                then AttRec.WIP_SUPPLY_TYPE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATO_FORECAST_CONTROL'           then AttRec.ATO_FORECAST_CONTROL  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DESCRIPTION'                    then AttRec.DESCRIPTION  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_CODE'        then AttRec.RELEASE_TIME_FENCE_CODE  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_DAYS'        then AttRec.RELEASE_TIME_FENCE_DAYS  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_ITEM_FLAG'            then AttRec.CONTAINER_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_TYPE_CODE'            then AttRec.CONTAINER_TYPE_CODE  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_VOLUME'                then AttRec.INTERNAL_VOLUME  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_LOAD_WEIGHT'            then AttRec.MAXIMUM_LOAD_WEIGHT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_FILL_PERCENT'           then AttRec.MINIMUM_FILL_PERCENT  := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VEHICLE_ITEM_FLAG'              then AttRec.VEHICLE_ITEM_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHECK_SHORTAGES_FLAG'           then AttRec.CHECK_SHORTAGES_FLAG  := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EFFECTIVITY_CONTROL'            then AttRec.EFFECTIVITY_CONTROL  := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_TYPE'  then AttRec.OVERCOMPLETION_TOLERANCE_TYPE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_VALUE' then AttRec.OVERCOMPLETION_TOLERANCE_VALUE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_SHIPMENT_TOLERANCE'        then AttRec.OVER_SHIPMENT_TOLERANCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_SHIPMENT_TOLERANCE'       then AttRec.UNDER_SHIPMENT_TOLERANCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_RETURN_TOLERANCE'          then AttRec.OVER_RETURN_TOLERANCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_RETURN_TOLERANCE'         then AttRec.UNDER_RETURN_TOLERANCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EQUIPMENT_TYPE'                 then AttRec.EQUIPMENT_TYPE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECOVERED_PART_DISP_CODE'       then AttRec.RECOVERED_PART_DISP_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFECT_TRACKING_ON_FLAG'        then AttRec.DEFECT_TRACKING_ON_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EVENT_FLAG'                     then AttRec.EVENT_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ELECTRONIC_FLAG'                then AttRec.ELECTRONIC_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DOWNLOADABLE_FLAG'              then AttRec.DOWNLOADABLE_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOL_DISCOUNT_EXEMPT_FLAG'       then AttRec.VOL_DISCOUNT_EXEMPT_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COUPON_EXEMPT_FLAG'             then AttRec.COUPON_EXEMPT_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG'        then AttRec.COMMS_NL_TRACKABLE_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CREATION_CODE'            then AttRec.ASSET_CREATION_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_ACTIVATION_REQD_FLAG'     then AttRec.COMMS_ACTIVATION_REQD_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDERABLE_ON_WEB_FLAG'          then AttRec.ORDERABLE_ON_WEB_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BACK_ORDERABLE_FLAG'            then AttRec.BACK_ORDERABLE_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEB_STATUS'                     then AttRec.WEB_STATUS := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INDIVISIBLE_FLAG'               then AttRec.INDIVISIBLE_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIMENSION_UOM_CODE'             then AttRec.DIMENSION_UOM_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_LENGTH'                    then AttRec.UNIT_LENGTH := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WIDTH'                     then AttRec.UNIT_WIDTH := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_HEIGHT'                    then AttRec.UNIT_HEIGHT := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BULK_PICKED_FLAG'               then AttRec.BULK_PICKED_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_STATUS_ENABLED'             then AttRec.LOT_STATUS_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_LOT_STATUS_ID'          then AttRec.DEFAULT_LOT_STATUS_ID := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_STATUS_ENABLED'          then AttRec.SERIAL_STATUS_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SERIAL_STATUS_ID'       then AttRec.DEFAULT_SERIAL_STATUS_ID := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SPLIT_ENABLED'              then AttRec.LOT_SPLIT_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_MERGE_ENABLED'              then AttRec.LOT_MERGE_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_CARRY_PENALTY'        then AttRec.INVENTORY_CARRY_PENALTY := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OPERATION_SLACK_PENALTY'        then AttRec.OPERATION_SLACK_PENALTY := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FINANCING_ALLOWED_FLAG'         then AttRec.FINANCING_ALLOWED_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           -- Primary Unit of Measure is now maintained via the PRIMARY_UOM_CODE column.
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE'               then AttRec.PRIMARY_UOM_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE'                  then AttRec.EAM_ITEM_TYPE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_TYPE_CODE'         then AttRec.EAM_ACTIVITY_TYPE_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_CAUSE_CODE'        then AttRec.EAM_ACTIVITY_CAUSE_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_NOTIFICATION_FLAG'      then AttRec.EAM_ACT_NOTIFICATION_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_SHUTDOWN_STATUS'        then AttRec.EAM_ACT_SHUTDOWN_STATUS := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_CONTROL'               then AttRec.DUAL_UOM_CONTROL := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE'             then AttRec.SECONDARY_UOM_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH'        then AttRec.DUAL_UOM_DEVIATION_HIGH := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW'         then AttRec.DUAL_UOM_DEVIATION_LOW := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTRACT_ITEM_TYPE_CODE'        then AttRec.CONTRACT_ITEM_TYPE_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_REQ_ENABLED_CODE'          then AttRec.SERV_REQ_ENABLED_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_BILLING_ENABLED_FLAG'      then AttRec.SERV_BILLING_ENABLED_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNED_INV_POINT_FLAG'         then AttRec.PLANNED_INV_POINT_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_TRANSLATE_ENABLED'          then AttRec.LOT_TRANSLATE_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SO_SOURCE_TYPE'         then AttRec.DEFAULT_SO_SOURCE_TYPE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CREATE_SUPPLY_FLAG'             then AttRec.CREATE_SUPPLY_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_CODE'       then AttRec.SUBSTITUTION_WINDOW_CODE := nvl(cr.ATTRIBUTE_VALUE, -999999);
           -- UT bug fix 4654527
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_DAYS'       then AttRec.SUBSTITUTION_WINDOW_DAYS := nvl(cr.ATTRIBUTE_VALUE, -999999);
       -- Added as part of 11.5.9 ENH
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SUBSTITUTION_ENABLED'       then AttRec.LOT_SUBSTITUTION_ENABLED := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_LICENSE_QUANTITY'       then AttRec.MINIMUM_LICENSE_QUANTITY := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_SOURCE_CODE'       then AttRec.EAM_ACTIVITY_SOURCE_CODE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.IB_ITEM_INSTANCE_CLASS'         then AttRec.IB_ITEM_INSTANCE_CLASS := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MODEL_TYPE'              then AttRec.CONFIG_MODEL_TYPE := nvl(cr.ATTRIBUTE_VALUE, '!');
           -- Added as part of 11.5.10 ENH
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND'          then AttRec.TRACKING_QUANTITY_IND := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ONT_PRICING_QTY_SOURCE'         then AttRec.ONT_PRICING_QTY_SOURCE := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND'          then AttRec.SECONDARY_DEFAULT_IND := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_CREATED_CONFIG_FLAG'       then AttRec.AUTO_CREATED_CONFIG_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_ORGS'                    then AttRec.CONFIG_ORGS := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MATCH'                   then AttRec.CONFIG_MATCH := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_UNITS'              then AttRec.VMI_MINIMUM_UNITS := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_DAYS'               then AttRec.VMI_MINIMUM_DAYS := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_UNITS'              then AttRec.VMI_MAXIMUM_UNITS := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_DAYS'               then AttRec.VMI_MAXIMUM_DAYS := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FIXED_ORDER_QUANTITY'       then AttRec.VMI_FIXED_ORDER_QUANTITY := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_AUTHORIZATION_FLAG'          then AttRec.SO_AUTHORIZATION_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONSIGNED_FLAG'                 then AttRec.CONSIGNED_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASN_AUTOEXPIRE_FLAG'            then AttRec.ASN_AUTOEXPIRE_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FORECAST_TYPE'              then AttRec.VMI_FORECAST_TYPE := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FORECAST_HORIZON'               then AttRec.FORECAST_HORIZON := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXCLUDE_FROM_BUDGET_FLAG'       then AttRec.EXCLUDE_FROM_BUDGET_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_SUPPLY'            then AttRec.DAYS_TGT_INV_SUPPLY := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_WINDOW'            then AttRec.DAYS_TGT_INV_WINDOW := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_SUPPLY'            then AttRec.DAYS_MAX_INV_SUPPLY := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_WINDOW'            then AttRec.DAYS_MAX_INV_WINDOW := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DRP_PLANNED_FLAG'               then AttRec.DRP_PLANNED_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CRITICAL_COMPONENT_FLAG'        then AttRec.CRITICAL_COMPONENT_FLAG := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTINOUS_TRANSFER'             then AttRec.CONTINOUS_TRANSFER := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONVERGENCE'                    then AttRec.CONVERGENCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIVERGENCE'                     then AttRec.DIVERGENCE := nvl(cr.ATTRIBUTE_VALUE, -999999);
       /* Start Bug 3713912 */
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_DIVISIBLE_FLAG'                     then AttRec.LOT_DIVISIBLE_FLAG         := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG'                     then AttRec.GRADE_CONTROL_FLAG         := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_GRADE'                          then AttRec.DEFAULT_GRADE          := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG'                         then AttRec.CHILD_LOT_FLAG         := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PARENT_CHILD_GENERATION_FLAG'           then AttRec.PARENT_CHILD_GENERATION_FLAG   := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_PREFIX'                       then AttRec.CHILD_LOT_PREFIX       := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_STARTING_NUMBER'              then AttRec.CHILD_LOT_STARTING_NUMBER      := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_VALIDATION_FLAG'              then AttRec.CHILD_LOT_VALIDATION_FLAG      := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COPY_LOT_ATTRIBUTE_FLAG'                then AttRec.COPY_LOT_ATTRIBUTE_FLAG    := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG'                    then AttRec.RECIPE_ENABLED_FLAG            := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_QUALITY_ENABLED_FLAG'           then AttRec.PROCESS_QUALITY_ENABLED_FLAG   := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG'         then AttRec.PROCESS_EXECUTION_ENABLED_FLAG := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_COSTING_ENABLED_FLAG'           then AttRec.PROCESS_COSTING_ENABLED_FLAG   := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_SUBINVENTORY'            then AttRec.PROCESS_SUPPLY_SUBINVENTORY    := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_LOCATOR_ID'              then AttRec.PROCESS_SUPPLY_LOCATOR_ID      := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_SUBINVENTORY'             then AttRec.PROCESS_YIELD_SUBINVENTORY     := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_LOCATOR_ID'               then AttRec.PROCESS_YIELD_LOCATOR_ID   := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARDOUS_MATERIAL_FLAG'                then AttRec.HAZARDOUS_MATERIAL_FLAG    := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CAS_NUMBER'                             then AttRec.CAS_NUMBER             := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETEST_INTERVAL'                        then AttRec.RETEST_INTERVAL        := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_INTERVAL'             then AttRec.EXPIRATION_ACTION_INTERVAL     := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_CODE'                 then AttRec.EXPIRATION_ACTION_CODE     := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATURITY_DAYS'                          then AttRec.MATURITY_DAYS          := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HOLD_DAYS'                              then AttRec.HOLD_DAYS              := nvl(cr.ATTRIBUTE_VALUE, -999999);
           /* End Bug 3713912 */
       --Org specific attributes
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_ITEM_ID'                           then AttRec.BASE_ITEM_ID                      := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID'               then AttRec.BASE_WARRANTY_SERVICE_ID          := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT'                  then AttRec.COST_OF_SALES_ACCOUNT             := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT'                    then AttRec.ENCUMBRANCE_ACCOUNT               := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT'                        then AttRec.EXPENSE_ACCOUNT                   := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNER_CODE'                           then AttRec.PLANNER_CODE                      := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET'                 then AttRec.PLANNING_EXCEPTION_SET            := nvl(cr.ATTRIBUTE_VALUE, '!');
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SALES_ACCOUNT'                          then AttRec.SALES_ACCOUNT                     := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID'                  then AttRec.WIP_SUPPLY_LOCATOR_ID             := nvl(cr.ATTRIBUTE_VALUE, -999999);
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY'                then AttRec.WIP_SUPPLY_SUBINVENTORY           := nvl(cr.ATTRIBUTE_VALUE, '!');
       --R12 Enhancement
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHARGE_PERIODICITY_CODE'                then AttRec.CHARGE_PERIODICITY_CODE           := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_LEADTIME'                        then AttRec.REPAIR_LEADTIME                   := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_YIELD'                           then AttRec.REPAIR_YIELD                      := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPOSITION_POINT'                      then AttRec.PREPOSITION_POINT                 := nvl(cr.ATTRIBUTE_VALUE, '!');
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_PROGRAM'                         then AttRec.REPAIR_PROGRAM                    := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBCONTRACTING_COMPONENT'               then AttRec.SUBCONTRACTING_COMPONENT          := nvl(cr.ATTRIBUTE_VALUE, -999999);
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSOURCED_ASSEMBLY'                    then AttRec.OUTSOURCED_ASSEMBLY               := nvl(cr.ATTRIBUTE_VALUE, -999999);
       end if;
/*  else   --Bug: 4456453 transaction type is 'CREATE'
           if cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_EARLY_DAYS'             then AttRec.ACCEPTABLE_EARLY_DAYS  := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_DECREASE'       then AttRec.ACCEPTABLE_RATE_DECREASE  := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCEPTABLE_RATE_INCREASE'       then AttRec.ACCEPTABLE_RATE_INCREASE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ACCOUNTING_RULE_ID'             then AttRec.ACCOUNTING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOWED_UNITS_LOOKUP_CODE'      then AttRec.ALLOWED_UNITS_LOOKUP_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_EXPRESS_DELIVERY_FLAG'    then AttRec.ALLOW_EXPRESS_DELIVERY_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_ITEM_DESC_UPDATE_FLAG'    then AttRec.ALLOW_ITEM_DESC_UPDATE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_SUBSTITUTE_RECEIPTS_FLAG' then AttRec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ALLOW_UNORDERED_RECEIPTS_FLAG'  then AttRec.ALLOW_UNORDERED_RECEIPTS_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CATEGORY_ID'              then AttRec.ASSET_CATEGORY_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_COMPONENTS_FLAG'            then AttRec.ATP_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_FLAG'                       then AttRec.ATP_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATP_RULE_ID'                    then AttRec.ATP_RULE_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_LOT_ALPHA_PREFIX'          then AttRec.AUTO_LOT_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_REDUCE_MPS'                then AttRec.AUTO_REDUCE_MPS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_SERIAL_ALPHA_PREFIX'       then AttRec.AUTO_SERIAL_ALPHA_PREFIX  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG'               then AttRec.BOM_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BOM_ITEM_TYPE'                  then AttRec.BOM_ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG'              then AttRec.BUILD_IN_WIP_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BUYER_ID'                       then AttRec.BUYER_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CARRYING_COST'                  then AttRec.CARRYING_COST  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COLLATERAL_FLAG'                then AttRec.COLLATERAL_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COSTING_ENABLED_FLAG'           then AttRec.COSTING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COVERAGE_SCHEDULE_ID'           then AttRec.COVERAGE_SCHEDULE_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUMULATIVE_TOTAL_LEAD_TIME'     then AttRec.CUMULATIVE_TOTAL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUM_MANUFACTURING_LEAD_TIME'    then AttRec.CUM_MANUFACTURING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG'    then AttRec.CUSTOMER_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_FLAG'            then AttRec.CUSTOMER_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CYCLE_COUNT_ENABLED_FLAG'       then AttRec.CYCLE_COUNT_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_EARLY_RECEIPT_ALLOWED'     then AttRec.DAYS_EARLY_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_LATE_RECEIPT_ALLOWED'      then AttRec.DAYS_LATE_RECEIPT_ALLOWED  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_INCLUDE_IN_ROLLUP_FLAG' then AttRec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SHIPPING_ORG'           then AttRec.DEFAULT_SHIPPING_ORG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_CODE'         then AttRec.DEMAND_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEMAND_TIME_FENCE_DAYS'         then AttRec.DEMAND_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.END_ASSEMBLY_PEGGING_FLAG'      then AttRec.END_ASSEMBLY_PEGGING_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENFORCE_SHIP_TO_LOCATION_CODE'  then AttRec.ENFORCE_SHIP_TO_LOCATION_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT'                then AttRec.EXPENSE_ACCOUNT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_BILLABLE_FLAG'          then AttRec.EXPENSE_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_DAYS_SUPPLY'              then AttRec.FIXED_DAYS_SUPPLY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LEAD_TIME'                then AttRec.FIXED_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_LOT_MULTIPLIER'           then AttRec.FIXED_LOT_MULTIPLIER  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FIXED_ORDER_QUANTITY'           then AttRec.FIXED_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FULL_LEAD_TIME'                 then AttRec.FULL_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARD_CLASS_ID'                then AttRec.HAZARD_CLASS_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INSPECTION_REQUIRED_FLAG'       then AttRec.INSPECTION_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG'    then AttRec.INTERNAL_ORDER_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_FLAG'            then AttRec.INTERNAL_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ASSET_FLAG'           then AttRec.INVENTORY_ASSET_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_FLAG'            then AttRec.INVENTORY_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE'     then AttRec.INVENTORY_ITEM_STATUS_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_PLANNING_CODE'        then AttRec.INVENTORY_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICEABLE_ITEM_FLAG'          then AttRec.INVOICEABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_CLOSE_TOLERANCE'        then AttRec.INVOICE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG'           then AttRec.INVOICE_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVOICING_RULE_ID'              then AttRec.INVOICING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ITEM_TYPE'                      then AttRec.ITEM_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LEAD_TIME_LOT_SIZE'             then AttRec.LEAD_TIME_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT'            then AttRec.LIST_PRICE_PER_UNIT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOCATION_CONTROL_CODE'          then AttRec.LOCATION_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_CONTROL_CODE'               then AttRec.LOT_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MARKET_PRICE'                   then AttRec.MARKET_PRICE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATERIAL_BILLABLE_FLAG'         then AttRec.MATERIAL_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_ORDER_QUANTITY'         then AttRec.MAXIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_MINMAX_QUANTITY'            then AttRec.MAX_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAX_WARRANTY_AMOUNT'            then AttRec.MAX_WARRANTY_AMOUNT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_ORDER_QUANTITY'         then AttRec.MINIMUM_ORDER_QUANTITY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MIN_MINMAX_QUANTITY'            then AttRec.MIN_MINMAX_QUANTITY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_CALCULATE_ATP_FLAG'         then AttRec.MRP_CALCULATE_ATP_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_PLANNING_CODE'              then AttRec.MRP_PLANNING_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_CODE'          then AttRec.MRP_SAFETY_STOCK_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MRP_SAFETY_STOCK_PERCENT'       then AttRec.MRP_SAFETY_STOCK_PERCENT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG'  then AttRec.MTL_TRANSACTIONS_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MUST_USE_APPROVED_VENDOR_FLAG'  then AttRec.MUST_USE_APPROVED_VENDOR_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEGATIVE_MEASUREMENT_ERROR'     then AttRec.NEGATIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.NEW_REVISION_CODE'              then AttRec.NEW_REVISION_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDER_COST'                     then AttRec.ORDER_COST  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_FLAG'         then AttRec.OUTSIDE_OPERATION_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSIDE_OPERATION_UOM_TYPE'     then AttRec.OUTSIDE_OPERATION_UOM_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERRUN_PERCENTAGE'             then AttRec.OVERRUN_PERCENTAGE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PAYMENT_TERMS_ID'               then AttRec.PAYMENT_TERMS_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICKING_RULE_ID'                then AttRec.PICKING_RULE_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PICK_COMPONENTS_FLAG'           then AttRec.PICK_COMPONENTS_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_MAKE_BUY_CODE'         then AttRec.PLANNING_MAKE_BUY_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_CODE'       then AttRec.PLANNING_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_TIME_FENCE_DAYS'       then AttRec.PLANNING_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSITIVE_MEASUREMENT_ERROR'     then AttRec.POSITIVE_MEASUREMENT_ERROR  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.POSTPROCESSING_LEAD_TIME'       then AttRec.POSTPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPROCESSING_LEAD_TIME'        then AttRec.PREPROCESSING_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREVENTIVE_MAINTENANCE_FLAG'    then AttRec.PREVENTIVE_MAINTENANCE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRICE_TOLERANCE_PERCENT'        then AttRec.PRICE_TOLERANCE_PERCENT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_SPECIALIST_ID'          then AttRec.PRIMARY_SPECIALIST_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRORATE_SERVICE_FLAG'           then AttRec.PRORATE_SERVICE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG'        then AttRec.PURCHASING_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_ITEM_FLAG'           then AttRec.PURCHASING_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_EXCEPTION_CODE'         then AttRec.QTY_RCV_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.QTY_RCV_TOLERANCE'              then AttRec.QTY_RCV_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_DAYS_EXCEPTION_CODE'    then AttRec.RECEIPT_DAYS_EXCEPTION_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIPT_REQUIRED_FLAG'          then AttRec.RECEIPT_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVE_CLOSE_TOLERANCE'        then AttRec.RECEIVE_CLOSE_TOLERANCE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECEIVING_ROUTING_ID'           then AttRec.RECEIVING_ROUTING_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPETITIVE_PLANNING_FLAG'       then AttRec.REPETITIVE_PLANNING_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPLENISH_TO_ORDER_FLAG'        then AttRec.REPLENISH_TO_ORDER_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESERVABLE_TYPE'                then AttRec.RESERVABLE_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_PERIOD_CODE'      then AttRec.RESPONSE_TIME_PERIOD_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESPONSE_TIME_VALUE'            then AttRec.RESPONSE_TIME_VALUE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_LOCATORS_CODE'         then AttRec.RESTRICT_LOCATORS_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RESTRICT_SUBINVENTORIES_CODE'   then AttRec.RESTRICT_SUBINVENTORIES_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURNABLE_FLAG'                then AttRec.RETURNABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETURN_INSPECTION_REQUIREMENT'  then AttRec.RETURN_INSPECTION_REQUIREMENT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REVISION_QTY_CONTROL_CODE'      then AttRec.REVISION_QTY_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RFQ_REQUIRED_FLAG'              then AttRec.RFQ_REQUIRED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_CONTROL_TYPE'          then AttRec.ROUNDING_CONTROL_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ROUNDING_FACTOR'                then AttRec.ROUNDING_FACTOR  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SAFETY_STOCK_BUCKET_DAYS'       then AttRec.SAFETY_STOCK_BUCKET_DAYS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_SPECIALIST_ID'        then AttRec.SECONDARY_SPECIALIST_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_NUMBER_CONTROL_CODE'     then AttRec.SERIAL_NUMBER_CONTROL_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_COMPONENT_FLAG'     then AttRec.SERVICEABLE_COMPONENT_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_ITEM_CLASS_ID'      then AttRec.SERVICEABLE_ITEM_CLASS_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICEABLE_PRODUCT_FLAG'       then AttRec.SERVICEABLE_PRODUCT_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION'               then AttRec.SERVICE_DURATION  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_DURATION_PERIOD_CODE'   then AttRec.SERVICE_DURATION_PERIOD_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERVICE_STARTING_DELAY'         then AttRec.SERVICE_STARTING_DELAY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_CODE'                then AttRec.SHELF_LIFE_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHELF_LIFE_DAYS'                then AttRec.SHELF_LIFE_DAYS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIPPABLE_ITEM_FLAG'            then AttRec.SHIPPABLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHIP_MODEL_COMPLETE_FLAG'       then AttRec.SHIP_MODEL_COMPLETE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SHRINKAGE_RATE'                 then AttRec.SHRINKAGE_RATE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_ORGANIZATION_ID'         then AttRec.SOURCE_ORGANIZATION_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_SUBINVENTORY'            then AttRec.SOURCE_SUBINVENTORY  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SOURCE_TYPE'                    then AttRec.SOURCE_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_TRANSACTIONS_FLAG'           then AttRec.SO_TRANSACTIONS_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_LOT_NUMBER'          then AttRec.START_AUTO_LOT_NUMBER  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.START_AUTO_SERIAL_NUMBER'       then AttRec.START_AUTO_SERIAL_NUMBER  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STD_LOT_SIZE'                   then AttRec.STD_LOT_SIZE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG'             then AttRec.STOCK_ENABLED_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAXABLE_FLAG'                   then AttRec.TAXABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PURCHASING_TAX_CODE'            then AttRec.PURCHASING_TAX_CODE := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TAX_CODE'                       then AttRec.TAX_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TIME_BILLABLE_FLAG'             then AttRec.TIME_BILLABLE_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_OF_ISSUE'                  then AttRec.UNIT_OF_ISSUE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_VOLUME'                    then AttRec.UNIT_VOLUME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WEIGHT'                    then AttRec.UNIT_WEIGHT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UN_NUMBER_ID'                   then AttRec.UN_NUMBER_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VARIABLE_LEAD_TIME'             then AttRec.VARIABLE_LEAD_TIME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOLUME_UOM_CODE'                then AttRec.VOLUME_UOM_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WARRANTY_VENDOR_ID'             then AttRec.WARRANTY_VENDOR_ID  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEIGHT_UOM_CODE'                then AttRec.WEIGHT_UOM_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_TYPE'                then AttRec.WIP_SUPPLY_TYPE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ATO_FORECAST_CONTROL'           then AttRec.ATO_FORECAST_CONTROL  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DESCRIPTION'                    then AttRec.DESCRIPTION  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_CODE'        then AttRec.RELEASE_TIME_FENCE_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RELEASE_TIME_FENCE_DAYS'        then AttRec.RELEASE_TIME_FENCE_DAYS  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_ITEM_FLAG'            then AttRec.CONTAINER_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTAINER_TYPE_CODE'            then AttRec.CONTAINER_TYPE_CODE  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INTERNAL_VOLUME'                then AttRec.INTERNAL_VOLUME  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MAXIMUM_LOAD_WEIGHT'            then AttRec.MAXIMUM_LOAD_WEIGHT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_FILL_PERCENT'           then AttRec.MINIMUM_FILL_PERCENT  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VEHICLE_ITEM_FLAG'              then AttRec.VEHICLE_ITEM_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHECK_SHORTAGES_FLAG'           then AttRec.CHECK_SHORTAGES_FLAG  := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EFFECTIVITY_CONTROL'            then AttRec.EFFECTIVITY_CONTROL  := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_TYPE'  then AttRec.OVERCOMPLETION_TOLERANCE_TYPE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVERCOMPLETION_TOLERANCE_VALUE' then AttRec.OVERCOMPLETION_TOLERANCE_VALUE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_SHIPMENT_TOLERANCE'        then AttRec.OVER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_SHIPMENT_TOLERANCE'       then AttRec.UNDER_SHIPMENT_TOLERANCE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OVER_RETURN_TOLERANCE'          then AttRec.OVER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNDER_RETURN_TOLERANCE'         then AttRec.UNDER_RETURN_TOLERANCE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EQUIPMENT_TYPE'                 then AttRec.EQUIPMENT_TYPE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECOVERED_PART_DISP_CODE'       then AttRec.RECOVERED_PART_DISP_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFECT_TRACKING_ON_FLAG'        then AttRec.DEFECT_TRACKING_ON_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EVENT_FLAG'                     then AttRec.EVENT_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ELECTRONIC_FLAG'                then AttRec.ELECTRONIC_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DOWNLOADABLE_FLAG'              then AttRec.DOWNLOADABLE_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VOL_DISCOUNT_EXEMPT_FLAG'       then AttRec.VOL_DISCOUNT_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COUPON_EXEMPT_FLAG'             then AttRec.COUPON_EXEMPT_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_NL_TRACKABLE_FLAG'        then AttRec.COMMS_NL_TRACKABLE_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASSET_CREATION_CODE'            then AttRec.ASSET_CREATION_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COMMS_ACTIVATION_REQD_FLAG'     then AttRec.COMMS_ACTIVATION_REQD_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ORDERABLE_ON_WEB_FLAG'          then AttRec.ORDERABLE_ON_WEB_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BACK_ORDERABLE_FLAG'            then AttRec.BACK_ORDERABLE_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WEB_STATUS'                     then AttRec.WEB_STATUS := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INDIVISIBLE_FLAG'               then AttRec.INDIVISIBLE_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIMENSION_UOM_CODE'             then AttRec.DIMENSION_UOM_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_LENGTH'                    then AttRec.UNIT_LENGTH := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_WIDTH'                     then AttRec.UNIT_WIDTH := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.UNIT_HEIGHT'                    then AttRec.UNIT_HEIGHT := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BULK_PICKED_FLAG'               then AttRec.BULK_PICKED_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_STATUS_ENABLED'             then AttRec.LOT_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_LOT_STATUS_ID'          then AttRec.DEFAULT_LOT_STATUS_ID := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERIAL_STATUS_ENABLED'          then AttRec.SERIAL_STATUS_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SERIAL_STATUS_ID'       then AttRec.DEFAULT_SERIAL_STATUS_ID := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SPLIT_ENABLED'              then AttRec.LOT_SPLIT_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_MERGE_ENABLED'              then AttRec.LOT_MERGE_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.INVENTORY_CARRY_PENALTY'        then AttRec.INVENTORY_CARRY_PENALTY := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OPERATION_SLACK_PENALTY'        then AttRec.OPERATION_SLACK_PENALTY := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FINANCING_ALLOWED_FLAG'         then AttRec.FINANCING_ALLOWED_FLAG := cr.ATTRIBUTE_VALUE;
           -- Primary Unit of Measure is now maintained via the PRIMARY_UOM_CODE column.
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PRIMARY_UOM_CODE'               then AttRec.PRIMARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ITEM_TYPE'                  then AttRec.EAM_ITEM_TYPE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_TYPE_CODE'         then AttRec.EAM_ACTIVITY_TYPE_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_CAUSE_CODE'        then AttRec.EAM_ACTIVITY_CAUSE_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_NOTIFICATION_FLAG'      then AttRec.EAM_ACT_NOTIFICATION_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACT_SHUTDOWN_STATUS'        then AttRec.EAM_ACT_SHUTDOWN_STATUS := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_CONTROL'               then AttRec.DUAL_UOM_CONTROL := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_UOM_CODE'             then AttRec.SECONDARY_UOM_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_HIGH'        then AttRec.DUAL_UOM_DEVIATION_HIGH := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DUAL_UOM_DEVIATION_LOW'         then AttRec.DUAL_UOM_DEVIATION_LOW := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTRACT_ITEM_TYPE_CODE'        then AttRec.CONTRACT_ITEM_TYPE_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_REQ_ENABLED_CODE'          then AttRec.SERV_REQ_ENABLED_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SERV_BILLING_ENABLED_FLAG'      then AttRec.SERV_BILLING_ENABLED_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNED_INV_POINT_FLAG'         then AttRec.PLANNED_INV_POINT_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_TRANSLATE_ENABLED'          then AttRec.LOT_TRANSLATE_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_SO_SOURCE_TYPE'         then AttRec.DEFAULT_SO_SOURCE_TYPE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CREATE_SUPPLY_FLAG'             then AttRec.CREATE_SUPPLY_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_CODE'       then AttRec.SUBSTITUTION_WINDOW_CODE := cr.ATTRIBUTE_VALUE;
           -- UT bug fix 4654527
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBSTITUTION_WINDOW_DAYS'       then AttRec.SUBSTITUTION_WINDOW_DAYS := cr.ATTRIBUTE_VALUE;
       -- Added as part of 11.5.9 ENH
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_SUBSTITUTION_ENABLED'       then AttRec.LOT_SUBSTITUTION_ENABLED := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MINIMUM_LICENSE_QUANTITY'       then AttRec.MINIMUM_LICENSE_QUANTITY := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EAM_ACTIVITY_SOURCE_CODE'       then AttRec.EAM_ACTIVITY_SOURCE_CODE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.IB_ITEM_INSTANCE_CLASS'         then AttRec.IB_ITEM_INSTANCE_CLASS := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MODEL_TYPE'              then AttRec.CONFIG_MODEL_TYPE := cr.ATTRIBUTE_VALUE;
           -- Added as part of 11.5.10 ENH
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.TRACKING_QUANTITY_IND'          then AttRec.TRACKING_QUANTITY_IND := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ONT_PRICING_QTY_SOURCE'         then AttRec.ONT_PRICING_QTY_SOURCE := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SECONDARY_DEFAULT_IND'          then AttRec.SECONDARY_DEFAULT_IND := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.AUTO_CREATED_CONFIG_FLAG'       then AttRec.AUTO_CREATED_CONFIG_FLAG := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_ORGS'                    then AttRec.CONFIG_ORGS := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONFIG_MATCH'                   then AttRec.CONFIG_MATCH := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_UNITS'              then AttRec.VMI_MINIMUM_UNITS := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MINIMUM_DAYS'               then AttRec.VMI_MINIMUM_DAYS := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_UNITS'              then AttRec.VMI_MAXIMUM_UNITS := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_MAXIMUM_DAYS'               then AttRec.VMI_MAXIMUM_DAYS := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FIXED_ORDER_QUANTITY'       then AttRec.VMI_FIXED_ORDER_QUANTITY := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SO_AUTHORIZATION_FLAG'          then AttRec.SO_AUTHORIZATION_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONSIGNED_FLAG'                 then AttRec.CONSIGNED_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ASN_AUTOEXPIRE_FLAG'            then AttRec.ASN_AUTOEXPIRE_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.VMI_FORECAST_TYPE'              then AttRec.VMI_FORECAST_TYPE := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.FORECAST_HORIZON'               then AttRec.FORECAST_HORIZON := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXCLUDE_FROM_BUDGET_FLAG'       then AttRec.EXCLUDE_FROM_BUDGET_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_SUPPLY'            then AttRec.DAYS_TGT_INV_SUPPLY := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_TGT_INV_WINDOW'            then AttRec.DAYS_TGT_INV_WINDOW := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_SUPPLY'            then AttRec.DAYS_MAX_INV_SUPPLY := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DAYS_MAX_INV_WINDOW'            then AttRec.DAYS_MAX_INV_WINDOW := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DRP_PLANNED_FLAG'               then AttRec.DRP_PLANNED_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CRITICAL_COMPONENT_FLAG'        then AttRec.CRITICAL_COMPONENT_FLAG := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONTINOUS_TRANSFER'             then AttRec.CONTINOUS_TRANSFER := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CONVERGENCE'                    then AttRec.CONVERGENCE := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DIVERGENCE'                     then AttRec.DIVERGENCE := cr.ATTRIBUTE_VALUE;
       -- Start Bug 3713912
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.LOT_DIVISIBLE_FLAG'                     then AttRec.LOT_DIVISIBLE_FLAG         := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.GRADE_CONTROL_FLAG'                     then AttRec.GRADE_CONTROL_FLAG         := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.DEFAULT_GRADE'                          then AttRec.DEFAULT_GRADE                  := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_FLAG'                         then AttRec.CHILD_LOT_FLAG                 := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PARENT_CHILD_GENERATION_FLAG'           then AttRec.PARENT_CHILD_GENERATION_FLAG      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_PREFIX'                       then AttRec.CHILD_LOT_PREFIX       := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_STARTING_NUMBER'              then AttRec.CHILD_LOT_STARTING_NUMBER      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHILD_LOT_VALIDATION_FLAG'              then AttRec.CHILD_LOT_VALIDATION_FLAG      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COPY_LOT_ATTRIBUTE_FLAG'                then AttRec.COPY_LOT_ATTRIBUTE_FLAG            := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG'                    then AttRec.RECIPE_ENABLED_FLAG            := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_QUALITY_ENABLED_FLAG'           then AttRec.PROCESS_QUALITY_ENABLED_FLAG      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG'         then AttRec.PROCESS_EXECUTION_ENABLED_FLAG    := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_COSTING_ENABLED_FLAG'           then AttRec.PROCESS_COSTING_ENABLED_FLAG      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_SUBINVENTORY'            then AttRec.PROCESS_SUPPLY_SUBINVENTORY       := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_SUPPLY_LOCATOR_ID'              then AttRec.PROCESS_SUPPLY_LOCATOR_ID      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_SUBINVENTORY'             then AttRec.PROCESS_YIELD_SUBINVENTORY     := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PROCESS_YIELD_LOCATOR_ID'               then AttRec.PROCESS_YIELD_LOCATOR_ID   := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HAZARDOUS_MATERIAL_FLAG'                then AttRec.HAZARDOUS_MATERIAL_FLAG            := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CAS_NUMBER'                             then AttRec.CAS_NUMBER             := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.RETEST_INTERVAL'                        then AttRec.RETEST_INTERVAL                := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_INTERVAL'             then AttRec.EXPIRATION_ACTION_INTERVAL     := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPIRATION_ACTION_CODE'                 then AttRec.EXPIRATION_ACTION_CODE             := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.MATURITY_DAYS'                          then AttRec.MATURITY_DAYS                  := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.HOLD_DAYS'                              then AttRec.HOLD_DAYS              := cr.ATTRIBUTE_VALUE;
           -- End Bug 3713912
       --Org specific attributes
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_ITEM_ID'                           then AttRec.BASE_ITEM_ID                      := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.BASE_WARRANTY_SERVICE_ID'               then AttRec.BASE_WARRANTY_SERVICE_ID          := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.COST_OF_SALES_ACCOUNT'                  then AttRec.COST_OF_SALES_ACCOUNT             := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.ENCUMBRANCE_ACCOUNT'                    then AttRec.ENCUMBRANCE_ACCOUNT               := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.EXPENSE_ACCOUNT'                        then AttRec.EXPENSE_ACCOUNT                   := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNER_CODE'                           then AttRec.PLANNER_CODE                      := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PLANNING_EXCEPTION_SET'                 then AttRec.PLANNING_EXCEPTION_SET            := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SALES_ACCOUNT'                          then AttRec.SALES_ACCOUNT                     := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_LOCATOR_ID'                  then AttRec.WIP_SUPPLY_LOCATOR_ID             := cr.ATTRIBUTE_VALUE;
       elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.WIP_SUPPLY_SUBINVENTORY'                then AttRec.WIP_SUPPLY_SUBINVENTORY           := cr.ATTRIBUTE_VALUE;
       --R12 Enhancement
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.CHARGE_PERIODICITY_CODE'                then AttRec.CHARGE_PERIODICITY_CODE           := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_LEADTIME'                        then AttRec.REPAIR_LEADTIME                   := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_YIELD'                           then AttRec.REPAIR_YIELD                      := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.PREPOSITION_POINT'                      then AttRec.PREPOSITION_POINT                 := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.REPAIR_PROGRAM'                         then AttRec.REPAIR_PROGRAM                    := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.SUBCONTRACTING_COMPONENT'               then AttRec.SUBCONTRACTING_COMPONENT          := cr.ATTRIBUTE_VALUE;
           elsif cr.ATTRIBUTE_NAME = 'MTL_SYSTEM_ITEMS.OUTSOURCED_ASSEMBLY'                    then AttRec.OUTSOURCED_ASSEMBLY               := cr.ATTRIBUTE_VALUE;
       end if;
    end if;  --Bug: 4456453 transaction_type
    commented for bug 6417006 */
     END LOOP;  -- cursor cc

     UPDATE MTL_SYSTEM_ITEMS_INTERFACE
     SET
    DESCRIPTION             = nvl(DESCRIPTION  , AttRec.DESCRIPTION),
    ACCEPTABLE_EARLY_DAYS       = nvl(ACCEPTABLE_EARLY_DAYS  , AttRec.ACCEPTABLE_EARLY_DAYS),
    ACCEPTABLE_RATE_DECREASE    = nvl(ACCEPTABLE_RATE_DECREASE  , AttRec.ACCEPTABLE_RATE_DECREASE),
    ACCEPTABLE_RATE_INCREASE    = nvl(ACCEPTABLE_RATE_INCREASE  , AttRec.ACCEPTABLE_RATE_INCREASE),
    ACCOUNTING_RULE_ID      = nvl(ACCOUNTING_RULE_ID  , AttRec.ACCOUNTING_RULE_ID),
    ALLOWED_UNITS_LOOKUP_CODE   = nvl(ALLOWED_UNITS_LOOKUP_CODE  , AttRec.ALLOWED_UNITS_LOOKUP_CODE),
    ALLOW_EXPRESS_DELIVERY_FLAG     = nvl(ALLOW_EXPRESS_DELIVERY_FLAG  , AttRec.ALLOW_EXPRESS_DELIVERY_FLAG),
    ALLOW_ITEM_DESC_UPDATE_FLAG     = nvl(ALLOW_ITEM_DESC_UPDATE_FLAG  , AttRec.ALLOW_ITEM_DESC_UPDATE_FLAG),
    ALLOW_SUBSTITUTE_RECEIPTS_FLAG  = nvl(ALLOW_SUBSTITUTE_RECEIPTS_FLAG  , AttRec.ALLOW_SUBSTITUTE_RECEIPTS_FLAG),
    ALLOW_UNORDERED_RECEIPTS_FLAG   = nvl(ALLOW_UNORDERED_RECEIPTS_FLAG  , AttRec.ALLOW_UNORDERED_RECEIPTS_FLAG),
    ASSET_CATEGORY_ID       = nvl(ASSET_CATEGORY_ID  , AttRec.ASSET_CATEGORY_ID),
    ATP_COMPONENTS_FLAG         = nvl(ATP_COMPONENTS_FLAG  , AttRec.ATP_COMPONENTS_FLAG),
    ATP_FLAG            = nvl(ATP_FLAG  , AttRec.ATP_FLAG),
    ATP_RULE_ID             = nvl(ATP_RULE_ID  , AttRec.ATP_RULE_ID),
    AUTO_LOT_ALPHA_PREFIX       = nvl(AUTO_LOT_ALPHA_PREFIX  , AttRec.AUTO_LOT_ALPHA_PREFIX),
    AUTO_REDUCE_MPS         = nvl(AUTO_REDUCE_MPS  , AttRec.AUTO_REDUCE_MPS),
    AUTO_SERIAL_ALPHA_PREFIX    = nvl(AUTO_SERIAL_ALPHA_PREFIX  , AttRec.AUTO_SERIAL_ALPHA_PREFIX),
    BOM_ENABLED_FLAG        = nvl(BOM_ENABLED_FLAG  , AttRec.BOM_ENABLED_FLAG),
    BOM_ITEM_TYPE           = nvl(BOM_ITEM_TYPE  , AttRec.BOM_ITEM_TYPE),
    BUILD_IN_WIP_FLAG       = nvl(BUILD_IN_WIP_FLAG  , AttRec.BUILD_IN_WIP_FLAG),
    BUYER_ID            = nvl(BUYER_ID  , AttRec.BUYER_ID),
    CARRYING_COST           = nvl(CARRYING_COST  , AttRec.CARRYING_COST),
    COLLATERAL_FLAG         = nvl(COLLATERAL_FLAG  , AttRec.COLLATERAL_FLAG),
    COSTING_ENABLED_FLAG        = nvl(COSTING_ENABLED_FLAG  , AttRec.COSTING_ENABLED_FLAG),
    COVERAGE_SCHEDULE_ID        = nvl(COVERAGE_SCHEDULE_ID  , AttRec.COVERAGE_SCHEDULE_ID),
    CUMULATIVE_TOTAL_LEAD_TIME  = nvl(CUMULATIVE_TOTAL_LEAD_TIME  , AttRec.CUMULATIVE_TOTAL_LEAD_TIME),
    CUM_MANUFACTURING_LEAD_TIME     = nvl(CUM_MANUFACTURING_LEAD_TIME  , AttRec.CUM_MANUFACTURING_LEAD_TIME),
    CUSTOMER_ORDER_ENABLED_FLAG     = nvl(CUSTOMER_ORDER_ENABLED_FLAG  , AttRec.CUSTOMER_ORDER_ENABLED_FLAG),
    CUSTOMER_ORDER_FLAG         = nvl(CUSTOMER_ORDER_FLAG  , AttRec.CUSTOMER_ORDER_FLAG),
    CYCLE_COUNT_ENABLED_FLAG    = nvl(CYCLE_COUNT_ENABLED_FLAG  , AttRec.CYCLE_COUNT_ENABLED_FLAG),
    DAYS_EARLY_RECEIPT_ALLOWED  = nvl(DAYS_EARLY_RECEIPT_ALLOWED  , AttRec.DAYS_EARLY_RECEIPT_ALLOWED),
    DAYS_LATE_RECEIPT_ALLOWED   = nvl(DAYS_LATE_RECEIPT_ALLOWED  , AttRec.DAYS_LATE_RECEIPT_ALLOWED),
    DEFAULT_INCLUDE_IN_ROLLUP_FLAG  = nvl(DEFAULT_INCLUDE_IN_ROLLUP_FLAG  , AttRec.DEFAULT_INCLUDE_IN_ROLLUP_FLAG),
    DEFAULT_SHIPPING_ORG        = nvl(DEFAULT_SHIPPING_ORG  , AttRec.DEFAULT_SHIPPING_ORG),
    DEMAND_TIME_FENCE_CODE      = nvl(DEMAND_TIME_FENCE_CODE  , AttRec.DEMAND_TIME_FENCE_CODE),
    DEMAND_TIME_FENCE_DAYS      = nvl(DEMAND_TIME_FENCE_DAYS  , AttRec.DEMAND_TIME_FENCE_DAYS),
    END_ASSEMBLY_PEGGING_FLAG   = nvl(END_ASSEMBLY_PEGGING_FLAG  , AttRec.END_ASSEMBLY_PEGGING_FLAG),
    ENFORCE_SHIP_TO_LOCATION_CODE   = nvl(ENFORCE_SHIP_TO_LOCATION_CODE  , AttRec.ENFORCE_SHIP_TO_LOCATION_CODE),
    EXPENSE_BILLABLE_FLAG       = nvl(EXPENSE_BILLABLE_FLAG  , AttRec.EXPENSE_BILLABLE_FLAG),
    FIXED_DAYS_SUPPLY       = nvl(FIXED_DAYS_SUPPLY  , AttRec.FIXED_DAYS_SUPPLY),
    FIXED_LEAD_TIME         = nvl(FIXED_LEAD_TIME  , AttRec.FIXED_LEAD_TIME),
    FIXED_LOT_MULTIPLIER        = nvl(FIXED_LOT_MULTIPLIER  , AttRec.FIXED_LOT_MULTIPLIER),
    FIXED_ORDER_QUANTITY        = nvl(FIXED_ORDER_QUANTITY  , AttRec.FIXED_ORDER_QUANTITY),
    FULL_LEAD_TIME          = nvl(FULL_LEAD_TIME  , AttRec.FULL_LEAD_TIME),
    HAZARD_CLASS_ID         = nvl(HAZARD_CLASS_ID  , AttRec.HAZARD_CLASS_ID),
    INSPECTION_REQUIRED_FLAG    = nvl(INSPECTION_REQUIRED_FLAG  , AttRec.INSPECTION_REQUIRED_FLAG),
    INTERNAL_ORDER_ENABLED_FLAG     = nvl(INTERNAL_ORDER_ENABLED_FLAG  , AttRec.INTERNAL_ORDER_ENABLED_FLAG),
    INTERNAL_ORDER_FLAG         = nvl(INTERNAL_ORDER_FLAG  , AttRec.INTERNAL_ORDER_FLAG),
    INVENTORY_ASSET_FLAG        = nvl(INVENTORY_ASSET_FLAG  , AttRec.INVENTORY_ASSET_FLAG),
    INVENTORY_ITEM_FLAG         = nvl(INVENTORY_ITEM_FLAG  , AttRec.INVENTORY_ITEM_FLAG),
    INVENTORY_ITEM_STATUS_CODE  = nvl(INVENTORY_ITEM_STATUS_CODE  , AttRec.INVENTORY_ITEM_STATUS_CODE),
    INVENTORY_PLANNING_CODE     = nvl(INVENTORY_PLANNING_CODE  , AttRec.INVENTORY_PLANNING_CODE),
    INVOICEABLE_ITEM_FLAG       = nvl(INVOICEABLE_ITEM_FLAG  , AttRec.INVOICEABLE_ITEM_FLAG),
    INVOICE_CLOSE_TOLERANCE     = nvl(INVOICE_CLOSE_TOLERANCE  , AttRec.INVOICE_CLOSE_TOLERANCE),
    INVOICE_ENABLED_FLAG        = nvl(INVOICE_ENABLED_FLAG  , AttRec.INVOICE_ENABLED_FLAG),
    INVOICING_RULE_ID       = nvl(INVOICING_RULE_ID  , AttRec.INVOICING_RULE_ID),
    ITEM_TYPE           = nvl(ITEM_TYPE  , AttRec.ITEM_TYPE),
    LEAD_TIME_LOT_SIZE      = nvl(LEAD_TIME_LOT_SIZE  , AttRec.LEAD_TIME_LOT_SIZE),
    LIST_PRICE_PER_UNIT         = nvl(LIST_PRICE_PER_UNIT  , AttRec.LIST_PRICE_PER_UNIT),
    LOCATION_CONTROL_CODE       = nvl(LOCATION_CONTROL_CODE  , AttRec.LOCATION_CONTROL_CODE),
    LOT_CONTROL_CODE        = nvl(LOT_CONTROL_CODE  , AttRec.LOT_CONTROL_CODE),
    MARKET_PRICE            = nvl(MARKET_PRICE  , AttRec.MARKET_PRICE),
    MATERIAL_BILLABLE_FLAG      = nvl(MATERIAL_BILLABLE_FLAG  , AttRec.MATERIAL_BILLABLE_FLAG),
    MAXIMUM_ORDER_QUANTITY      = nvl(MAXIMUM_ORDER_QUANTITY  , AttRec.MAXIMUM_ORDER_QUANTITY),
    MAX_MINMAX_QUANTITY         = nvl(MAX_MINMAX_QUANTITY  , AttRec.MAX_MINMAX_QUANTITY),
    MAX_WARRANTY_AMOUNT     = nvl(MAX_WARRANTY_AMOUNT  , AttRec.MAX_WARRANTY_AMOUNT),
    MINIMUM_ORDER_QUANTITY      = nvl(MINIMUM_ORDER_QUANTITY  , AttRec.MINIMUM_ORDER_QUANTITY),
    MIN_MINMAX_QUANTITY         = nvl(MIN_MINMAX_QUANTITY  , AttRec.MIN_MINMAX_QUANTITY),
    MRP_CALCULATE_ATP_FLAG      = nvl(MRP_CALCULATE_ATP_FLAG  , AttRec.MRP_CALCULATE_ATP_FLAG),
    MRP_PLANNING_CODE       = nvl(MRP_PLANNING_CODE  , AttRec.MRP_PLANNING_CODE),
    MRP_SAFETY_STOCK_CODE       = nvl(MRP_SAFETY_STOCK_CODE  , AttRec.MRP_SAFETY_STOCK_CODE),
    MRP_SAFETY_STOCK_PERCENT    = nvl(MRP_SAFETY_STOCK_PERCENT  , AttRec.MRP_SAFETY_STOCK_PERCENT),
    MTL_TRANSACTIONS_ENABLED_FLAG   = nvl(MTL_TRANSACTIONS_ENABLED_FLAG  , AttRec.MTL_TRANSACTIONS_ENABLED_FLAG),
    MUST_USE_APPROVED_VENDOR_FLAG   = nvl(MUST_USE_APPROVED_VENDOR_FLAG  , AttRec.MUST_USE_APPROVED_VENDOR_FLAG),
    NEGATIVE_MEASUREMENT_ERROR  = nvl(NEGATIVE_MEASUREMENT_ERROR  , AttRec.NEGATIVE_MEASUREMENT_ERROR),
    NEW_REVISION_CODE       = nvl(NEW_REVISION_CODE  , AttRec.NEW_REVISION_CODE),
    ORDER_COST          = nvl(ORDER_COST  , AttRec.ORDER_COST),
    OUTSIDE_OPERATION_FLAG      = nvl(OUTSIDE_OPERATION_FLAG  , AttRec.OUTSIDE_OPERATION_FLAG),
    OUTSIDE_OPERATION_UOM_TYPE  = nvl(OUTSIDE_OPERATION_UOM_TYPE  , AttRec.OUTSIDE_OPERATION_UOM_TYPE),
    OVERRUN_PERCENTAGE      = nvl(OVERRUN_PERCENTAGE  , AttRec.OVERRUN_PERCENTAGE),
    PAYMENT_TERMS_ID        = nvl(PAYMENT_TERMS_ID  , AttRec.PAYMENT_TERMS_ID),
    PICKING_RULE_ID         = nvl(PICKING_RULE_ID  , AttRec.PICKING_RULE_ID),
    PICK_COMPONENTS_FLAG        = nvl(PICK_COMPONENTS_FLAG  , AttRec.PICK_COMPONENTS_FLAG),
    PLANNING_MAKE_BUY_CODE      = nvl(PLANNING_MAKE_BUY_CODE  , AttRec.PLANNING_MAKE_BUY_CODE),
    PLANNING_TIME_FENCE_CODE    = nvl(PLANNING_TIME_FENCE_CODE  , AttRec.PLANNING_TIME_FENCE_CODE),
    PLANNING_TIME_FENCE_DAYS    = nvl(PLANNING_TIME_FENCE_DAYS  , AttRec.PLANNING_TIME_FENCE_DAYS),
    POSITIVE_MEASUREMENT_ERROR  = nvl(POSITIVE_MEASUREMENT_ERROR  , AttRec.POSITIVE_MEASUREMENT_ERROR),
    POSTPROCESSING_LEAD_TIME    = nvl(POSTPROCESSING_LEAD_TIME  , AttRec.POSTPROCESSING_LEAD_TIME),
    PREPROCESSING_LEAD_TIME     = nvl(PREPROCESSING_LEAD_TIME  , AttRec.PREPROCESSING_LEAD_TIME),
    PREVENTIVE_MAINTENANCE_FLAG     = nvl(PREVENTIVE_MAINTENANCE_FLAG  , AttRec.PREVENTIVE_MAINTENANCE_FLAG),
    PRICE_TOLERANCE_PERCENT     = nvl(PRICE_TOLERANCE_PERCENT  , AttRec.PRICE_TOLERANCE_PERCENT),
    PRIMARY_SPECIALIST_ID       = nvl(PRIMARY_SPECIALIST_ID  , AttRec.PRIMARY_SPECIALIST_ID),
    PRORATE_SERVICE_FLAG        = nvl(PRORATE_SERVICE_FLAG  , AttRec.PRORATE_SERVICE_FLAG),
    PURCHASING_ENABLED_FLAG     = nvl(PURCHASING_ENABLED_FLAG  , AttRec.PURCHASING_ENABLED_FLAG),
    PURCHASING_ITEM_FLAG        = nvl(PURCHASING_ITEM_FLAG  , AttRec.PURCHASING_ITEM_FLAG),
    QTY_RCV_EXCEPTION_CODE      = nvl(QTY_RCV_EXCEPTION_CODE  , AttRec.QTY_RCV_EXCEPTION_CODE),
    QTY_RCV_TOLERANCE       = nvl(QTY_RCV_TOLERANCE  , AttRec.QTY_RCV_TOLERANCE),
    RECEIPT_DAYS_EXCEPTION_CODE     = nvl(RECEIPT_DAYS_EXCEPTION_CODE  , AttRec.RECEIPT_DAYS_EXCEPTION_CODE),
    RECEIPT_REQUIRED_FLAG       = nvl(RECEIPT_REQUIRED_FLAG  , AttRec.RECEIPT_REQUIRED_FLAG),
    RECEIVE_CLOSE_TOLERANCE     = nvl(RECEIVE_CLOSE_TOLERANCE  , AttRec.RECEIVE_CLOSE_TOLERANCE),
    RECEIVING_ROUTING_ID        = nvl(RECEIVING_ROUTING_ID  , AttRec.RECEIVING_ROUTING_ID),
    REPETITIVE_PLANNING_FLAG    = nvl(REPETITIVE_PLANNING_FLAG  , AttRec.REPETITIVE_PLANNING_FLAG),
    REPLENISH_TO_ORDER_FLAG     = nvl(REPLENISH_TO_ORDER_FLAG  , AttRec.REPLENISH_TO_ORDER_FLAG),
    RESERVABLE_TYPE         = nvl(RESERVABLE_TYPE  , AttRec.RESERVABLE_TYPE),
    RESPONSE_TIME_PERIOD_CODE   = nvl(RESPONSE_TIME_PERIOD_CODE  , AttRec.RESPONSE_TIME_PERIOD_CODE),
    RESPONSE_TIME_VALUE         = nvl(RESPONSE_TIME_VALUE  , AttRec.RESPONSE_TIME_VALUE),
    RESTRICT_LOCATORS_CODE      = nvl(RESTRICT_LOCATORS_CODE  , AttRec.RESTRICT_LOCATORS_CODE),
    RESTRICT_SUBINVENTORIES_CODE    = nvl(RESTRICT_SUBINVENTORIES_CODE  , AttRec.RESTRICT_SUBINVENTORIES_CODE),
    RETURNABLE_FLAG         = nvl(RETURNABLE_FLAG  , AttRec.RETURNABLE_FLAG),
    RETURN_INSPECTION_REQUIREMENT   = nvl(RETURN_INSPECTION_REQUIREMENT  , AttRec.RETURN_INSPECTION_REQUIREMENT),
    REVISION_QTY_CONTROL_CODE   = nvl(REVISION_QTY_CONTROL_CODE  , AttRec.REVISION_QTY_CONTROL_CODE),
    RFQ_REQUIRED_FLAG       = nvl(RFQ_REQUIRED_FLAG  , AttRec.RFQ_REQUIRED_FLAG),
    ROUNDING_CONTROL_TYPE       = nvl(ROUNDING_CONTROL_TYPE  , AttRec.ROUNDING_CONTROL_TYPE),
    ROUNDING_FACTOR         = nvl(ROUNDING_FACTOR  , AttRec.ROUNDING_FACTOR),
    SAFETY_STOCK_BUCKET_DAYS    = nvl(SAFETY_STOCK_BUCKET_DAYS  , AttRec.SAFETY_STOCK_BUCKET_DAYS),
    SECONDARY_SPECIALIST_ID     = nvl(SECONDARY_SPECIALIST_ID  , AttRec.SECONDARY_SPECIALIST_ID),
    SERIAL_NUMBER_CONTROL_CODE  = nvl(SERIAL_NUMBER_CONTROL_CODE  , AttRec.SERIAL_NUMBER_CONTROL_CODE),
    SERVICEABLE_COMPONENT_FLAG  = nvl(SERVICEABLE_COMPONENT_FLAG  , AttRec.SERVICEABLE_COMPONENT_FLAG),
    SERVICEABLE_ITEM_CLASS_ID   = nvl(SERVICEABLE_ITEM_CLASS_ID  , AttRec.SERVICEABLE_ITEM_CLASS_ID),
    SERVICEABLE_PRODUCT_FLAG    = nvl(SERVICEABLE_PRODUCT_FLAG  , AttRec.SERVICEABLE_PRODUCT_FLAG),
    SERVICE_DURATION        = nvl(SERVICE_DURATION  , AttRec.SERVICE_DURATION),
    SERVICE_DURATION_PERIOD_CODE    = nvl(SERVICE_DURATION_PERIOD_CODE  , AttRec.SERVICE_DURATION_PERIOD_CODE),
    SERVICE_STARTING_DELAY      = nvl(SERVICE_STARTING_DELAY  , AttRec.SERVICE_STARTING_DELAY),
    SHELF_LIFE_CODE         = nvl(SHELF_LIFE_CODE  , AttRec.SHELF_LIFE_CODE),
    SHELF_LIFE_DAYS         = nvl(SHELF_LIFE_DAYS  , AttRec.SHELF_LIFE_DAYS),
    SHIPPABLE_ITEM_FLAG         = nvl(SHIPPABLE_ITEM_FLAG  , AttRec.SHIPPABLE_ITEM_FLAG),
    SHIP_MODEL_COMPLETE_FLAG    = nvl(SHIP_MODEL_COMPLETE_FLAG  , AttRec.SHIP_MODEL_COMPLETE_FLAG),
    SHRINKAGE_RATE          = nvl(SHRINKAGE_RATE  , AttRec.SHRINKAGE_RATE),
    SOURCE_ORGANIZATION_ID      = nvl(SOURCE_ORGANIZATION_ID  , AttRec.SOURCE_ORGANIZATION_ID),
    SOURCE_SUBINVENTORY         = nvl(SOURCE_SUBINVENTORY  , AttRec.SOURCE_SUBINVENTORY),
    SOURCE_TYPE             = nvl(SOURCE_TYPE  , AttRec.SOURCE_TYPE),
    SO_TRANSACTIONS_FLAG        = nvl(SO_TRANSACTIONS_FLAG  , AttRec.SO_TRANSACTIONS_FLAG),
    START_AUTO_LOT_NUMBER       = nvl(START_AUTO_LOT_NUMBER  , AttRec.START_AUTO_LOT_NUMBER),
    START_AUTO_SERIAL_NUMBER    = nvl(START_AUTO_SERIAL_NUMBER  , AttRec.START_AUTO_SERIAL_NUMBER),
    STD_LOT_SIZE            = nvl(STD_LOT_SIZE  , AttRec.STD_LOT_SIZE),
    STOCK_ENABLED_FLAG      = nvl(STOCK_ENABLED_FLAG  , AttRec.STOCK_ENABLED_FLAG),
    TAXABLE_FLAG            = nvl(TAXABLE_FLAG  , AttRec.TAXABLE_FLAG),
    PURCHASING_TAX_CODE         = nvl(PURCHASING_TAX_CODE  , AttRec.PURCHASING_TAX_CODE),
    TAX_CODE            = nvl(TAX_CODE  , AttRec.TAX_CODE),
    TIME_BILLABLE_FLAG      = nvl(TIME_BILLABLE_FLAG  , AttRec.TIME_BILLABLE_FLAG),
    UNIT_OF_ISSUE           = nvl(UNIT_OF_ISSUE  , AttRec.UNIT_OF_ISSUE),
    UNIT_VOLUME             = nvl(UNIT_VOLUME  , AttRec.UNIT_VOLUME),
    UNIT_WEIGHT             = nvl(UNIT_WEIGHT  , AttRec.UNIT_WEIGHT),
    UN_NUMBER_ID            = nvl(UN_NUMBER_ID  , AttRec.UN_NUMBER_ID),
    VARIABLE_LEAD_TIME      = nvl(VARIABLE_LEAD_TIME  , AttRec.VARIABLE_LEAD_TIME),
    VOLUME_UOM_CODE         = nvl(VOLUME_UOM_CODE  , AttRec.VOLUME_UOM_CODE),
    WARRANTY_VENDOR_ID      = nvl(WARRANTY_VENDOR_ID  , AttRec.WARRANTY_VENDOR_ID),
    WEIGHT_UOM_CODE         = nvl(WEIGHT_UOM_CODE  , AttRec.WEIGHT_UOM_CODE),
    WIP_SUPPLY_TYPE         = nvl(WIP_SUPPLY_TYPE  , AttRec.WIP_SUPPLY_TYPE),
    ATO_FORECAST_CONTROL        = nvl(ATO_FORECAST_CONTROL  , AttRec.ATO_FORECAST_CONTROL),
    RELEASE_TIME_FENCE_CODE     = nvl(RELEASE_TIME_FENCE_CODE  , AttRec.RELEASE_TIME_FENCE_CODE),
    RELEASE_TIME_FENCE_DAYS     = nvl(RELEASE_TIME_FENCE_DAYS  , AttRec.RELEASE_TIME_FENCE_DAYS),
        CONTAINER_ITEM_FLAG         = nvl(CONTAINER_ITEM_FLAG  , AttRec.CONTAINER_ITEM_FLAG),
    CONTAINER_TYPE_CODE         = nvl(CONTAINER_TYPE_CODE  , AttRec.CONTAINER_TYPE_CODE),
    INTERNAL_VOLUME         = nvl(INTERNAL_VOLUME  , AttRec.INTERNAL_VOLUME),
    MAXIMUM_LOAD_WEIGHT         = nvl(MAXIMUM_LOAD_WEIGHT  , AttRec.MAXIMUM_LOAD_WEIGHT),
    MINIMUM_FILL_PERCENT        = nvl(MINIMUM_FILL_PERCENT  , AttRec.MINIMUM_FILL_PERCENT),
    VEHICLE_ITEM_FLAG       = nvl(VEHICLE_ITEM_FLAG  , AttRec.VEHICLE_ITEM_FLAG),
    CHECK_SHORTAGES_FLAG        = nvl(CHECK_SHORTAGES_FLAG,AttRec.CHECK_SHORTAGES_FLAG),
    EFFECTIVITY_CONTROL         = nvl(EFFECTIVITY_CONTROL, AttRec.EFFECTIVITY_CONTROL),
        OVERCOMPLETION_TOLERANCE_TYPE   = nvl(OVERCOMPLETION_TOLERANCE_TYPE , AttRec.OVERCOMPLETION_TOLERANCE_TYPE ),
        OVERCOMPLETION_TOLERANCE_VALUE  = nvl(OVERCOMPLETION_TOLERANCE_VALUE , AttRec.OVERCOMPLETION_TOLERANCE_VALUE ),
        OVER_SHIPMENT_TOLERANCE         = nvl(OVER_SHIPMENT_TOLERANCE , AttRec.OVER_SHIPMENT_TOLERANCE ),
        UNDER_SHIPMENT_TOLERANCE        = nvl(UNDER_SHIPMENT_TOLERANCE , AttRec.UNDER_SHIPMENT_TOLERANCE ),
        OVER_RETURN_TOLERANCE           = nvl(OVER_RETURN_TOLERANCE , AttRec.OVER_RETURN_TOLERANCE ),
        UNDER_RETURN_TOLERANCE          = nvl(UNDER_RETURN_TOLERANCE , AttRec.UNDER_RETURN_TOLERANCE ),
        EQUIPMENT_TYPE                  = nvl(EQUIPMENT_TYPE , AttRec.EQUIPMENT_TYPE ),
        RECOVERED_PART_DISP_CODE        = nvl(RECOVERED_PART_DISP_CODE , AttRec.RECOVERED_PART_DISP_CODE ),
        DEFECT_TRACKING_ON_FLAG         = nvl(DEFECT_TRACKING_ON_FLAG , AttRec.DEFECT_TRACKING_ON_FLAG ),
        EVENT_FLAG                      = nvl(EVENT_FLAG , AttRec.EVENT_FLAG ),
        ELECTRONIC_FLAG                 = nvl(ELECTRONIC_FLAG , AttRec.ELECTRONIC_FLAG ),
        DOWNLOADABLE_FLAG               = nvl(DOWNLOADABLE_FLAG , AttRec.DOWNLOADABLE_FLAG ),
        VOL_DISCOUNT_EXEMPT_FLAG        = nvl(VOL_DISCOUNT_EXEMPT_FLAG , AttRec.VOL_DISCOUNT_EXEMPT_FLAG ),
        COUPON_EXEMPT_FLAG              = nvl(COUPON_EXEMPT_FLAG , AttRec.COUPON_EXEMPT_FLAG ),
        COMMS_NL_TRACKABLE_FLAG         = nvl(COMMS_NL_TRACKABLE_FLAG , AttRec.COMMS_NL_TRACKABLE_FLAG ),
        ASSET_CREATION_CODE             = nvl(ASSET_CREATION_CODE , AttRec.ASSET_CREATION_CODE ),
        COMMS_ACTIVATION_REQD_FLAG      = nvl(COMMS_ACTIVATION_REQD_FLAG , AttRec.COMMS_ACTIVATION_REQD_FLAG ),
        ORDERABLE_ON_WEB_FLAG           = nvl(ORDERABLE_ON_WEB_FLAG , AttRec.ORDERABLE_ON_WEB_FLAG ),
        BACK_ORDERABLE_FLAG             = nvl(BACK_ORDERABLE_FLAG , AttRec.BACK_ORDERABLE_FLAG ),
        WEB_STATUS                      = nvl(WEB_STATUS, AttRec.WEB_STATUS ),
        INDIVISIBLE_FLAG                = nvl(INDIVISIBLE_FLAG, AttRec.INDIVISIBLE_FLAG ),
        DIMENSION_UOM_CODE              = nvl(DIMENSION_UOM_CODE , AttRec.DIMENSION_UOM_CODE ),
        UNIT_LENGTH                     = nvl(UNIT_LENGTH , AttRec.UNIT_LENGTH ),
        UNIT_WIDTH                      = nvl(UNIT_WIDTH , AttRec.UNIT_WIDTH ),
        UNIT_HEIGHT                     = nvl(UNIT_HEIGHT , AttRec.UNIT_HEIGHT ),
        BULK_PICKED_FLAG                = nvl(BULK_PICKED_FLAG , AttRec.BULK_PICKED_FLAG ),
        LOT_STATUS_ENABLED              = nvl(LOT_STATUS_ENABLED , AttRec.LOT_STATUS_ENABLED ),
        -- bug 9004676
        -- DEFAULT_LOT_STATUS_ID           = nvl(DEFAULT_LOT_STATUS_ID , AttRec.DEFAULT_LOT_STATUS_ID ),
        DEFAULT_LOT_STATUS_ID           = nvl(DEFAULT_LOT_STATUS_ID, DECODE(NVL(LOT_STATUS_ENABLED,AttRec.LOT_STATUS_ENABLED),NULL,NULL,'N',NULL,AttRec.DEFAULT_LOT_STATUS_ID)),
        SERIAL_STATUS_ENABLED           = nvl(SERIAL_STATUS_ENABLED , AttRec.SERIAL_STATUS_ENABLED ),
        DEFAULT_SERIAL_STATUS_ID        = nvl(DEFAULT_SERIAL_STATUS_ID , AttRec.DEFAULT_SERIAL_STATUS_ID ),
        LOT_SPLIT_ENABLED               = nvl(LOT_SPLIT_ENABLED , AttRec.LOT_SPLIT_ENABLED ),
        LOT_MERGE_ENABLED               = nvl(LOT_MERGE_ENABLED , AttRec.LOT_MERGE_ENABLED ),
        INVENTORY_CARRY_PENALTY         = nvl(INVENTORY_CARRY_PENALTY , AttRec.INVENTORY_CARRY_PENALTY ),
        OPERATION_SLACK_PENALTY         = nvl(OPERATION_SLACK_PENALTY , AttRec.OPERATION_SLACK_PENALTY ),
        FINANCING_ALLOWED_FLAG          = nvl(FINANCING_ALLOWED_FLAG , AttRec.FINANCING_ALLOWED_FLAG ),
        -- Primary Unit of Measure is now maintained via the PRIMARY_UOM_CODE column.
        PRIMARY_UOM_CODE                = decode(PRIMARY_UOM_CODE, NULL,decode(PRIMARY_UNIT_OF_MEASURE,NULL,AttRec.PRIMARY_UOM_CODE ),PRIMARY_UOM_CODE),
        EAM_ITEM_TYPE                   = nvl(EAM_ITEM_TYPE, AttRec.EAM_ITEM_TYPE ),
        EAM_ACTIVITY_TYPE_CODE          = nvl(EAM_ACTIVITY_TYPE_CODE, AttRec.EAM_ACTIVITY_TYPE_CODE ),
        EAM_ACTIVITY_CAUSE_CODE         = nvl(EAM_ACTIVITY_CAUSE_CODE, AttRec.EAM_ACTIVITY_CAUSE_CODE ),
        EAM_ACT_NOTIFICATION_FLAG       = nvl(EAM_ACT_NOTIFICATION_FLAG, AttRec.EAM_ACT_NOTIFICATION_FLAG ),
        EAM_ACT_SHUTDOWN_STATUS         = nvl(EAM_ACT_SHUTDOWN_STATUS, AttRec.EAM_ACT_SHUTDOWN_STATUS ),
        SECONDARY_UOM_CODE              = nvl(SECONDARY_UOM_CODE, AttRec.SECONDARY_UOM_CODE ),
        DUAL_UOM_DEVIATION_HIGH         = nvl(DUAL_UOM_DEVIATION_HIGH, AttRec.DUAL_UOM_DEVIATION_HIGH ),
        DUAL_UOM_DEVIATION_LOW          = nvl(DUAL_UOM_DEVIATION_LOW, AttRec.DUAL_UOM_DEVIATION_LOW ),
        CONTRACT_ITEM_TYPE_CODE         = nvl(CONTRACT_ITEM_TYPE_CODE, AttRec.CONTRACT_ITEM_TYPE_CODE ),
        SERV_REQ_ENABLED_CODE       = nvl(SERV_REQ_ENABLED_CODE, AttRec.SERV_REQ_ENABLED_CODE ),
        SERV_BILLING_ENABLED_FLAG   = nvl(SERV_BILLING_ENABLED_FLAG, AttRec.SERV_BILLING_ENABLED_FLAG ),
        PLANNED_INV_POINT_FLAG      = nvl(PLANNED_INV_POINT_FLAG, AttRec.PLANNED_INV_POINT_FLAG ),
        LOT_TRANSLATE_ENABLED       = nvl(LOT_TRANSLATE_ENABLED, AttRec.LOT_TRANSLATE_ENABLED ),
        DEFAULT_SO_SOURCE_TYPE      = nvl(DEFAULT_SO_SOURCE_TYPE, AttRec.DEFAULT_SO_SOURCE_TYPE ),
        CREATE_SUPPLY_FLAG      = nvl(CREATE_SUPPLY_FLAG, AttRec.CREATE_SUPPLY_FLAG ),
        SUBSTITUTION_WINDOW_CODE    = nvl(SUBSTITUTION_WINDOW_CODE, AttRec.SUBSTITUTION_WINDOW_CODE ),
        SUBSTITUTION_WINDOW_DAYS    = nvl(SUBSTITUTION_WINDOW_DAYS, AttRec.SUBSTITUTION_WINDOW_DAYS ),
        --Added as part of 11.5.9
        LOT_SUBSTITUTION_ENABLED        = nvl(LOT_SUBSTITUTION_ENABLED, AttRec.LOT_SUBSTITUTION_ENABLED ),
        MINIMUM_LICENSE_QUANTITY        = nvl(MINIMUM_LICENSE_QUANTITY, AttRec.MINIMUM_LICENSE_QUANTITY ),
        EAM_ACTIVITY_SOURCE_CODE        = nvl(EAM_ACTIVITY_SOURCE_CODE, AttRec.EAM_ACTIVITY_SOURCE_CODE ),
        IB_ITEM_INSTANCE_CLASS          = nvl(IB_ITEM_INSTANCE_CLASS, AttRec.IB_ITEM_INSTANCE_CLASS   ),
        CONFIG_MODEL_TYPE               = nvl(CONFIG_MODEL_TYPE, AttRec.CONFIG_MODEL_TYPE        ),
         --Added as part of 11.5.10
        TRACKING_QUANTITY_IND           = nvl(TRACKING_QUANTITY_IND , AttRec.TRACKING_QUANTITY_IND  ),
        ONT_PRICING_QTY_SOURCE          = nvl(ONT_PRICING_QTY_SOURCE, AttRec.ONT_PRICING_QTY_SOURCE ),
        SECONDARY_DEFAULT_IND           = nvl(SECONDARY_DEFAULT_IND , AttRec.SECONDARY_DEFAULT_IND  ),
        AUTO_CREATED_CONFIG_FLAG        = nvl(AUTO_CREATED_CONFIG_FLAG, AttRec.AUTO_CREATED_CONFIG_FLAG),
        CONFIG_ORGS                     = nvl(CONFIG_ORGS, AttRec.CONFIG_ORGS),
        CONFIG_MATCH                    = nvl(CONFIG_MATCH, AttRec.CONFIG_MATCH),
        VMI_MINIMUM_UNITS               = nvl(VMI_MINIMUM_UNITS, AttRec.VMI_MINIMUM_UNITS),
        VMI_MINIMUM_DAYS            = nvl(VMI_MINIMUM_DAYS, AttRec.VMI_MINIMUM_DAYS),
        VMI_MAXIMUM_UNITS           = nvl(VMI_MAXIMUM_UNITS, AttRec.VMI_MAXIMUM_UNITS),
        VMI_MAXIMUM_DAYS            = nvl(VMI_MAXIMUM_DAYS, AttRec.VMI_MAXIMUM_DAYS),
        VMI_FIXED_ORDER_QUANTITY        = nvl(VMI_FIXED_ORDER_QUANTITY, AttRec.VMI_FIXED_ORDER_QUANTITY),
        SO_AUTHORIZATION_FLAG       = nvl(SO_AUTHORIZATION_FLAG, AttRec.SO_AUTHORIZATION_FLAG),
        CONSIGNED_FLAG              = nvl(CONSIGNED_FLAG, AttRec.CONSIGNED_FLAG),
        ASN_AUTOEXPIRE_FLAG         = nvl(ASN_AUTOEXPIRE_FLAG, AttRec.ASN_AUTOEXPIRE_FLAG),
        VMI_FORECAST_TYPE           = nvl(VMI_FORECAST_TYPE, AttRec.VMI_FORECAST_TYPE),
        FORECAST_HORIZON            = nvl(FORECAST_HORIZON, AttRec.FORECAST_HORIZON),
        EXCLUDE_FROM_BUDGET_FLAG        = nvl(EXCLUDE_FROM_BUDGET_FLAG, AttRec.EXCLUDE_FROM_BUDGET_FLAG),
        DAYS_TGT_INV_SUPPLY         = nvl(DAYS_TGT_INV_SUPPLY, AttRec.DAYS_TGT_INV_SUPPLY),
        DAYS_TGT_INV_WINDOW         = nvl(DAYS_TGT_INV_WINDOW, AttRec.DAYS_TGT_INV_WINDOW),
        DAYS_MAX_INV_SUPPLY         = nvl(DAYS_MAX_INV_SUPPLY, AttRec.DAYS_MAX_INV_SUPPLY),
        DAYS_MAX_INV_WINDOW         = nvl(DAYS_MAX_INV_WINDOW, AttRec.DAYS_MAX_INV_WINDOW),
        DRP_PLANNED_FLAG            = nvl(DRP_PLANNED_FLAG, AttRec.DRP_PLANNED_FLAG),
        CRITICAL_COMPONENT_FLAG         = nvl(CRITICAL_COMPONENT_FLAG, AttRec.CRITICAL_COMPONENT_FLAG),
        CONTINOUS_TRANSFER          = nvl(CONTINOUS_TRANSFER, AttRec.CONTINOUS_TRANSFER),
        CONVERGENCE             = nvl(CONVERGENCE, AttRec.CONVERGENCE),
        DIVERGENCE              = nvl(DIVERGENCE, AttRec.DIVERGENCE)   ,
        --Start Bug 3713912
        LOT_DIVISIBLE_FLAG      = nvl(LOT_DIVISIBLE_FLAG,AttRec.LOT_DIVISIBLE_FLAG),
        GRADE_CONTROL_FLAG      = nvl(GRADE_CONTROL_FLAG,AttRec.GRADE_CONTROL_FLAG),
        DEFAULT_GRADE               = nvl(DEFAULT_GRADE,AttRec.DEFAULT_GRADE),
        CHILD_LOT_FLAG              = nvl(CHILD_LOT_FLAG,AttRec.CHILD_LOT_FLAG),
        PARENT_CHILD_GENERATION_FLAG    = nvl(PARENT_CHILD_GENERATION_FLAG,AttRec.PARENT_CHILD_GENERATION_FLAG),
        CHILD_LOT_PREFIX        = nvl(CHILD_LOT_PREFIX,AttRec.CHILD_LOT_PREFIX),
        CHILD_LOT_STARTING_NUMBER   = nvl(CHILD_LOT_STARTING_NUMBER,AttRec.CHILD_LOT_STARTING_NUMBER),
        CHILD_LOT_VALIDATION_FLAG   = nvl(CHILD_LOT_VALIDATION_FLAG,AttRec.CHILD_LOT_VALIDATION_FLAG),
        COPY_LOT_ATTRIBUTE_FLAG         = nvl(COPY_LOT_ATTRIBUTE_FLAG,AttRec.COPY_LOT_ATTRIBUTE_FLAG),
        RECIPE_ENABLED_FLAG         = nvl(RECIPE_ENABLED_FLAG,AttRec.RECIPE_ENABLED_FLAG),
        PROCESS_QUALITY_ENABLED_FLAG    = nvl(PROCESS_QUALITY_ENABLED_FLAG,AttRec.PROCESS_QUALITY_ENABLED_FLAG),
        PROCESS_EXECUTION_ENABLED_FLAG  = nvl(PROCESS_EXECUTION_ENABLED_FLAG,AttRec.PROCESS_EXECUTION_ENABLED_FLAG),
        PROCESS_COSTING_ENABLED_FLAG    = nvl(PROCESS_COSTING_ENABLED_FLAG,AttRec.PROCESS_COSTING_ENABLED_FLAG),
        HAZARDOUS_MATERIAL_FLAG         = nvl(HAZARDOUS_MATERIAL_FLAG,AttRec.HAZARDOUS_MATERIAL_FLAG),
        CAS_NUMBER          = nvl(CAS_NUMBER,AttRec.CAS_NUMBER),
        RETEST_INTERVAL             = nvl(RETEST_INTERVAL,AttRec.RETEST_INTERVAL),
        EXPIRATION_ACTION_INTERVAL  = nvl(EXPIRATION_ACTION_INTERVAL,AttRec.EXPIRATION_ACTION_INTERVAL),
        EXPIRATION_ACTION_CODE          = nvl(EXPIRATION_ACTION_CODE,AttRec.EXPIRATION_ACTION_CODE),
        MATURITY_DAYS               = nvl(MATURITY_DAYS,AttRec.MATURITY_DAYS),
        HOLD_DAYS           = nvl(HOLD_DAYS,AttRec.HOLD_DAYS),
        --End Bug 3713912
    --R12 Enhancement
    CHARGE_PERIODICITY_CODE         = nvl(CHARGE_PERIODICITY_CODE,AttRec.CHARGE_PERIODICITY_CODE),
    REPAIR_LEADTIME                 = nvl(REPAIR_LEADTIME,AttRec.REPAIR_LEADTIME),
        REPAIR_YIELD                    = nvl(REPAIR_YIELD,AttRec.REPAIR_YIELD),
    PREPOSITION_POINT               = nvl(PREPOSITION_POINT,AttRec.PREPOSITION_POINT),
        REPAIR_PROGRAM                  = nvl(REPAIR_PROGRAM,AttRec.REPAIR_PROGRAM),
    SUBCONTRACTING_COMPONENT        = nvl(SUBCONTRACTING_COMPONENT,AttRec.SUBCONTRACTING_COMPONENT),
    OUTSOURCED_ASSEMBLY             = nvl(OUTSOURCED_ASSEMBLY,AttRec.OUTSOURCED_ASSEMBLY)
     WHERE  process_flag    = 1
     AND   set_process_id   = xset_id
     AND  ((organization_id = org_id) or (all_org = 1))
     AND  template_id       = template_table(i)
     AND  transaction_type  = transaction_table(i);

     IF context_orgid IS NOT NULL THEN

        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
        SET
       BASE_ITEM_ID         =   nvl(BASE_ITEM_ID                , AttRec.BASE_ITEM_ID),
       BASE_WARRANTY_SERVICE_ID     =   nvl(BASE_WARRANTY_SERVICE_ID    , AttRec.BASE_WARRANTY_SERVICE_ID),
       COST_OF_SALES_ACCOUNT    =   nvl(COST_OF_SALES_ACCOUNT       , AttRec.COST_OF_SALES_ACCOUNT),
       EXPENSE_ACCOUNT      =   nvl(EXPENSE_ACCOUNT             , AttRec.EXPENSE_ACCOUNT),
       ENCUMBRANCE_ACCOUNT      =   nvl(ENCUMBRANCE_ACCOUNT         , AttRec.ENCUMBRANCE_ACCOUNT),
       PLANNING_EXCEPTION_SET   =   nvl(PLANNING_EXCEPTION_SET      , AttRec.PLANNING_EXCEPTION_SET),
       PLANNER_CODE         =   nvl(PLANNER_CODE                , AttRec.PLANNER_CODE),
       SALES_ACCOUNT        =   nvl(SALES_ACCOUNT               , AttRec.SALES_ACCOUNT),
       WIP_SUPPLY_LOCATOR_ID    =   nvl(WIP_SUPPLY_LOCATOR_ID       , AttRec.WIP_SUPPLY_LOCATOR_ID),
       WIP_SUPPLY_SUBINVENTORY  =   nvl(WIP_SUPPLY_SUBINVENTORY     , AttRec.WIP_SUPPLY_SUBINVENTORY),
       --Start Bug 3713912
       PROCESS_SUPPLY_SUBINVENTORY  =       nvl(PROCESS_SUPPLY_SUBINVENTORY , AttRec.PROCESS_SUPPLY_SUBINVENTORY),
           PROCESS_SUPPLY_LOCATOR_ID    =       nvl(PROCESS_SUPPLY_LOCATOR_ID   , AttRec.PROCESS_SUPPLY_LOCATOR_ID),
           PROCESS_YIELD_SUBINVENTORY   =       nvl(PROCESS_YIELD_SUBINVENTORY  , AttRec.PROCESS_YIELD_SUBINVENTORY),
           PROCESS_YIELD_LOCATOR_ID =       nvl(PROCESS_YIELD_LOCATOR_ID    , AttRec.PROCESS_YIELD_LOCATOR_ID)
           --End Bug 3713912
        WHERE process_flag    = 1
        AND   set_process_id  = xset_id
        AND   organization_id = context_orgid
        AND   template_id     = template_table(i)
    AND   transaction_type = transaction_table(i);

     END IF;


     FOR cr IN global_flex(template_table(i)) LOOP
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE
        SET
           Global_attribute_Category = nvl(Global_attribute_Category,CR.Global_attribute_category),
           Global_attribute1 = nvl(Global_attribute1,CR.Global_attribute1),
           Global_attribute2 = nvl(Global_attribute2,CR.Global_attribute2),
           Global_attribute3 = nvl(Global_attribute3,CR.Global_attribute3),
           Global_attribute4 = nvl(Global_attribute4,CR.Global_attribute4),
           Global_attribute5 = nvl(Global_attribute5,CR.Global_attribute5),
           Global_attribute6 = nvl(Global_attribute6,CR.Global_attribute6),
           Global_attribute7 = nvl(Global_attribute7,CR.Global_attribute7),
           Global_attribute8 = nvl(Global_attribute8,CR.Global_attribute8),
           Global_attribute9 = nvl(Global_attribute9,CR.Global_attribute9),
           Global_attribute10 = nvl(Global_attribute10,CR.Global_attribute10),
           Global_attribute11 = nvl(Global_attribute11,CR.Global_attribute11),
           Global_attribute12 = nvl(Global_attribute12,CR.Global_attribute12),
           Global_attribute13 = nvl(Global_attribute13,CR.Global_attribute13),
           Global_attribute14 = nvl(Global_attribute14,CR.Global_attribute14),
           Global_attribute15 = nvl(Global_attribute15,CR.Global_attribute15),
           Global_attribute16 = nvl(Global_attribute16,CR.Global_attribute16),
           Global_attribute17 = nvl(Global_attribute17,CR.Global_attribute17),
           Global_attribute18 = nvl(Global_attribute18,CR.Global_attribute18),
           Global_attribute19 = nvl(Global_attribute19,CR.Global_attribute19),
           Global_attribute20 = nvl(Global_attribute20,CR.Global_attribute20)

        WHERE  process_flag    = 1
        AND   set_process_id   = xset_id
        AND  ((organization_id = org_id) or (all_org = 1))
        AND  template_id       = template_table(i)
    AND  transaction_type  = transaction_table(i);
     END LOOP;

   END LOOP; -- FIRST .. LAST LOOP
   END IF;

   return(0);

EXCEPTION
   WHEN LOGGING_ERR THEN
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPULI2:LOGGING_ERR : ');
      END IF;
      RETURN(dumm_status);
  WHEN OTHERS THEN
     err_text := substr('INVPULI2.copy_template_attributes ' || SQLERRM , 1, 240);
     return(SQLCODE);
END copy_template_attributes;

/*---------------------------------------------------------------------------------

   Procedure for Applying the specfied template to the specified interface row.

----------------------------------------------------------------------------------*/

FUNCTION apply_multiple_template( p_template_tbl IN Import_Template_Tbl_Type
                                 ,p_org_id       IN NUMBER
                                 ,p_all_org      IN NUMBER  := 2
                                 ,p_prog_appid   IN NUMBER  := -1
                                 ,p_prog_id      IN NUMBER  := -1
                                 ,p_request_id   IN NUMBER  := -1
                                 ,p_user_id      IN NUMBER  := -1
                                 ,p_login_id     IN NUMBER  := -1
                                 ,p_xset_id      IN NUMBER  := -999
                                 ,x_err_text     IN OUT NOCOPY VARCHAR2)
RETURN INTEGER
IS
   l_ret_status  NUMBER;
   dumm_status   NUMBER := 0;
   l_template_id NUMBER;
   l_index       NUMBER;
BEGIN
   IF p_template_tbl IS NOT NULL THEN
     l_index := p_template_tbl.FIRST;
     WHILE l_index IS NOT NULL
     LOOP
       l_template_id  :=  p_template_tbl(l_index);
       /* Set the template id passed to the Function in the interface row */
       UPDATE mtl_system_items_interface
          SET template_id = l_template_id
        WHERE process_flag = 1
          AND set_process_id = p_xset_id
          AND((p_all_org = 1) or (organization_id = p_org_id));

       /* Call method to apply template attributes to the rows */
       l_ret_status := INVPULI2.copy_template_attributes( org_id => p_org_id
                                                         ,all_org => p_all_org
                                                             ,prog_appid => p_prog_appid
                                                           ,prog_id => p_prog_id
                                                              ,request_id => p_request_id
                                                           ,user_id => p_user_id
                                                            ,login_id => p_login_id
                                                             ,xset_id => p_xset_id
                                                              ,err_text => x_err_text);
       IF l_ret_status <> 0 THEN
         RETURN(l_ret_status);
       END IF;
       l_index := p_template_tbl.next(l_index);
     END LOOP;
  /* Set the template id back to null in the interface row to avoid reapplication */
     UPDATE mtl_system_items_interface
        SET template_id = null
      WHERE process_flag = 1
        AND set_process_id = p_xset_id
        AND((p_all_org = 1) or (organization_id = p_org_id));
   END IF;
   RETURN(0);
EXCEPTION
  WHEN others THEN
    x_err_text := SUBSTR(SQLERRM,1,240);
    RETURN(SQLCODE);
END apply_multiple_template;

END INVPULI2;

/
