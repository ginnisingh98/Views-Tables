--------------------------------------------------------
--  DDL for Package Body INVPULI4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPULI4" AS
/* $Header: INVPUL4B.pls 120.6.12010000.3 2009/07/17 10:17:02 vggarg ship $ */

/*NP 31AUG94 Note for future release: Have removed reference to all expense accounts
**in assign_master_defaults and assign_item_defaults.
**We let INVPASGI take care of assigning it if null.
**The validation will take place in validation module.
**IMPORTANT: Might have to do the same with copy_item, copy_template etc...
**This needs some serious thought when we work towards releasing template and
**copy item features
*/

/*NP 06SEP94: Function assign_status_attributes has been majorly changed to
**enforce interdependencies. Now, even though default values might be given to
**status attributes in the assign_item_defaults and assign_master_defaults,
**they will be changed if necessary to enforce interdependencies
**for all status attributes which are under status cntrl or under default
**status ctrl
*/

-- bug 7137702 : new variables for caching purpose
g_item_status_code      mtl_item_status.inventory_item_status_code%TYPE;
g_attribute_names       dbms_sql.varchar2s;
g_attribute_values      dbms_sql.varchar2s;
g_status_control_codes  dbms_sql.number_table;
g_control_levels        dbms_sql.number_table;
-- end bug 7137702

FUNCTION assign_status_attributes(
   item_id               number,
   org_id                number,
   err_text  OUT NOCOPY  varchar2,
   xset_id               number DEFAULT -999,
   p_rowid               rowid,
   master_org_id        NUMBER DEFAULT NULL) RETURN INTEGER IS

   /*NP 06SEP94 Comment: Cursor cc selects the attr_name and value
   **for those attributes which are under default or under stat control ie. status_control_code = 1 or 2
   **These are the ones which will be affected by status.NP 06MAY96 Added xset_id logic
   */

   -- CURSOR cc is
   CURSOR cc(p_status_code VARCHAR2) is    -- bug 7137702
        select v.attribute_name,
               v.attribute_value,
               a.status_control_code,
               a.control_level
        from mtl_item_status s,
             mtl_status_attribute_values v,
             mtl_item_attributes a
        --      mtl_system_items_interface m
        -- where s.inventory_item_status_code = m.inventory_item_status_code
        -- and   m.rowid = p_rowid
        where s.inventory_item_status_code = p_status_code    -- bug 7137702
        and   s.inventory_item_status_code = v.inventory_item_status_code
        and   DECODE(s.disable_date,NULL,SYSDATE + 1,s.disable_date) > SYSDATE
        and   v.attribute_name = a.attribute_name
        and   a.STATUS_CONTROL_CODE in ( 1,2,3 )
        order by v.attribute_name desc;


   CURSOR master_cur is
   select B.STOCK_ENABLED_FLAG,
          B.PURCHASING_ENABLED_FLAG,
          B.CUSTOMER_ORDER_ENABLED_FLAG,
          B.INTERNAL_ORDER_ENABLED_FLAG,
          B.MTL_TRANSACTIONS_ENABLED_FLAG,
          B.BOM_ENABLED_FLAG,
          B.BUILD_IN_WIP_FLAG,
          B.INVOICE_ENABLED_FLAG,
          B.RECIPE_ENABLED_FLAG,
          B.PROCESS_EXECUTION_ENABLED_FLAG
    FROM  MTL_SYSTEM_ITEMS B
    WHERE B.INVENTORY_ITEM_ID   = item_id
    AND   B.ORGANIZATION_ID     = nvl(master_org_id,(select MASTER_ORGANIZATION_ID
						     from MTL_PARAMETERS
						     where ORGANIZATION_ID = org_id));
/* Fix for bug 4670905 - Added below cursor to fetch the status attribute values of an exisitng item.*/
    CURSOR org_cur is
     select B.STOCK_ENABLED_FLAG,B.PURCHASING_ENABLED_FLAG,
	    B.CUSTOMER_ORDER_ENABLED_FLAG,B.INTERNAL_ORDER_ENABLED_FLAG,
	    B.MTL_TRANSACTIONS_ENABLED_FLAG,B.BOM_ENABLED_FLAG,
	    B.BUILD_IN_WIP_FLAG,B.INVOICE_ENABLED_FLAG,
	    B.RECIPE_ENABLED_FLAG,B.PROCESS_EXECUTION_ENABLED_FLAG
      from  MTL_SYSTEM_ITEMS B
      where INVENTORY_ITEM_ID = item_id
      and   ORGANIZATION_ID =   org_id;

   /*NP 05AUG94  IMPORTANT NOTE: Have put in an order by clause in
   **cursor cc because in the logic below we need to have the record with the
   **STOCK_ENABLED_FLAG attribute be processed before the MTL_TRANSACTIONS_ENABLED_FLAG record
   **since the logic of the latter is depenent on the former
   */

   AttRec             MTL_SYSTEM_ITEMS_INTERFACE%ROWTYPE;
   master_rec         master_cur%ROWTYPE;
   Master_Org         char(1);
   Master_status_code varchar2(10);
   l_inv_debug_level	NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
 /* Fix for bug 4670905 - Added below record variable to hold values fetched by cursor org_rec.*/
   org_rec org_cur%ROWTYPE;

   cr cc%ROWTYPE;    -- bug 7137702

BEGIN

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('Inside INVPULI4.assign_status_attributes');
   END IF;

   SELECT * INTO AttRec
   FROM MTL_SYSTEM_ITEMS_INTERFACE
   WHERE ROWID = p_rowid ;

   Master_Org := 'N';

   begin
      SELECT 'Y' INTO Master_Org
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = master_organization_id
      AND ORGANIZATION_ID   = org_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         Master_Org := 'N';
   END;

   IF ((AttRec.INVENTORY_ITEM_STATUS_CODE is not null AND AttRec.TRANSACTION_TYPE = 'UPDATE' )
       OR ( AttRec.TRANSACTION_TYPE = 'CREATE' ))
   THEN

      --Start : 6531918 :  Fetching outside the attrs loop
      IF Master_Org ='N' THEN
         OPEN master_cur;
         FETCH master_cur INTO master_rec;
         CLOSE master_cur;
      END IF;

      IF AttRec.TRANSACTION_TYPE = 'UPDATE' THEN
         OPEN  org_cur;
         FETCH org_cur INTO org_rec;
         CLOSE org_cur;
      END IF;
      --End : 6531918 :  Fetching outside the attrs loop

      -- bug 7137702 : implement caching
      IF g_item_status_code = AttRec.inventory_item_status_code THEN
          --
          -- Found code in cache, nothing needs to be done, required
          -- data are available in those g_ variables fetched previously.
          --
          NULL;
      ELSE
          --
          -- Come here to fetch values if new status code doesn't match
          -- or if g_item_status_code is null it will still come in here.
          -- BULK COLLECT is used to fetch all matching values in one shot
          --
          OPEN cc(AttRec.inventory_item_status_code);
          FETCH cc BULK COLLECT INTO
              g_attribute_names,
              g_attribute_values,
              g_status_control_codes,
              g_control_levels;
          CLOSE cc;
          g_item_status_code := AttRec.inventory_item_status_code;
      END IF;
      -- end bug 7137702

      -- FOR cr in cc LOOP
      FOR i IN g_attribute_names.FIRST .. g_attribute_names.LAST LOOP    -- bug 7137702

         -- bug 7137702 : populate cr variable with correct data
         cr.attribute_name := g_attribute_names(i);
         cr.attribute_value := g_attribute_values(i);
         cr.status_control_code := g_status_control_codes(i);
         cr.control_level := g_control_levels(i);
         -- end bug 7137702

         IF ( cr.attribute_name = 'MTL_SYSTEM_ITEMS.STOCK_ENABLED_FLAG' ) THEN
            IF ( AttRec.INVENTORY_ITEM_FLAG = 'Y' ) THEN
               IF(cr.control_level=1) AND (Master_Org ='N') THEN
		  AttRec.STOCK_ENABLED_FLAG := master_rec.STOCK_ENABLED_FLAG;
               ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.STOCK_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.STOCK_ENABLED_FLAG := NVL(AttRec.STOCK_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.STOCK_ENABLED_FLAG := NVL(AttRec.STOCK_ENABLED_FLAG, 'N');
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.STOCK_ENABLED_FLAG := NVL(AttRec.STOCK_ENABLED_FLAG, master_rec.STOCK_ENABLED_FLAG);
		  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
                      AttRec.STOCK_ENABLED_FLAG := NVL(AttRec.STOCK_ENABLED_FLAG, org_rec.STOCK_ENABLED_FLAG );
                  END IF;
               END IF; -- Master_Org ='N'
            ELSIF ( AttRec.INVENTORY_ITEM_FLAG = 'N' ) THEN
              AttRec.STOCK_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF ( cr.attribute_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG' ) then
            IF ( AttRec.STOCK_ENABLED_FLAG = 'Y' ) THEN
               IF(cr.control_level=1) AND (Master_Org ='N') THEN
		  AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := master_rec.MTL_TRANSACTIONS_ENABLED_FLAG;
	       ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := NVL(AttRec.MTL_TRANSACTIONS_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := NVL(AttRec.MTL_TRANSACTIONS_ENABLED_FLAG, 'N');
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := NVL(AttRec.MTL_TRANSACTIONS_ENABLED_FLAG,master_rec.MTL_TRANSACTIONS_ENABLED_FLAG );
		  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
                     AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := NVL(AttRec.MTL_TRANSACTIONS_ENABLED_FLAG,org_rec.MTL_TRANSACTIONS_ENABLED_FLAG);
		  END IF;
	       END IF;
            ELSIF ( AttRec.STOCK_ENABLED_FLAG = 'N' ) THEN
               AttRec.MTL_TRANSACTIONS_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name = 'MTL_SYSTEM_ITEMS.PURCHASING_ENABLED_FLAG' THEN
            IF AttRec.purchasing_item_flag = 'Y'  THEN
               IF(cr.control_level=1) AND (Master_Org ='N') THEN
	          AttRec.PURCHASING_ENABLED_FLAG := master_rec.PURCHASING_ENABLED_FLAG;
               ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.PURCHASING_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.PURCHASING_ENABLED_FLAG := NVL(AttRec.PURCHASING_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.PURCHASING_ENABLED_FLAG := NVL(AttRec.PURCHASING_ENABLED_FLAG, 'N');
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.PURCHASING_ENABLED_FLAG := NVL(AttRec.PURCHASING_ENABLED_FLAG, master_rec.PURCHASING_ENABLED_FLAG);
		  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
                     AttRec.PURCHASING_ENABLED_FLAG := NVL(AttRec.PURCHASING_ENABLED_FLAG, org_rec.PURCHASING_ENABLED_FLAG );
  		  END IF;
	       END IF;
            ELSIF AttRec.purchasing_item_flag = 'N'  THEN
               AttRec.PURCHASING_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name = 'MTL_SYSTEM_ITEMS.INVOICE_ENABLED_FLAG' THEN
            IF AttRec.invoiceable_item_flag = 'Y' THEN
	       IF(cr.control_level=1) AND (Master_Org ='N') THEN
	          AttRec.INVOICE_ENABLED_FLAG := master_rec.INVOICE_ENABLED_FLAG;
               ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.INVOICE_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.INVOICE_ENABLED_FLAG := NVL(AttRec.INVOICE_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.INVOICE_ENABLED_FLAG := NVL(AttRec.INVOICE_ENABLED_FLAG, 'N');
          	  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.INVOICE_ENABLED_FLAG := NVL(AttRec.INVOICE_ENABLED_FLAG,master_rec.INVOICE_ENABLED_FLAG);
        	  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
		     AttRec.INVOICE_ENABLED_FLAG := NVL(AttRec.INVOICE_ENABLED_FLAG,org_rec.INVOICE_ENABLED_FLAG );
		  END IF;
	       END IF;
            ELSIF AttRec.invoiceable_item_flag = 'N' THEN
               AttRec.INVOICE_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name = 'MTL_SYSTEM_ITEMS.BUILD_IN_WIP_FLAG' THEN
            IF (AttRec.inventory_item_flag = 'Y' and AttRec.bom_item_type = 4) THEN
	       IF(cr.control_level=1) AND (Master_Org ='N') THEN
                  AttRec.BUILD_IN_WIP_FLAG := master_rec.BUILD_IN_WIP_FLAG;
	       ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.BUILD_IN_WIP_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.BUILD_IN_WIP_FLAG := NVL(AttRec.BUILD_IN_WIP_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
		     AttRec.BUILD_IN_WIP_FLAG := NVL(AttRec.BUILD_IN_WIP_FLAG, 'N');
		  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
		     AttRec.BUILD_IN_WIP_FLAG := NVL(AttRec.BUILD_IN_WIP_FLAG, master_rec.BUILD_IN_WIP_FLAG);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
                     AttRec.BUILD_IN_WIP_FLAG := NVL(AttRec.BUILD_IN_WIP_FLAG, org_rec.BUILD_IN_WIP_FLAG );
		  END IF;
               END IF;
            ELSIF (AttRec.inventory_item_flag = 'N' or AttRec.bom_item_type <> 4) THEN
               AttRec.BUILD_IN_WIP_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name =  'MTL_SYSTEM_ITEMS.CUSTOMER_ORDER_ENABLED_FLAG' THEN
            IF AttRec.customer_order_flag = 'Y' THEN
	       IF(cr.control_level=1) AND (Master_Org ='N') THEN
		  AttRec.CUSTOMER_ORDER_ENABLED_FLAG := master_rec.CUSTOMER_ORDER_ENABLED_FLAG;
               ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.CUSTOMER_ORDER_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.CUSTOMER_ORDER_ENABLED_FLAG := NVL(AttRec.CUSTOMER_ORDER_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.CUSTOMER_ORDER_ENABLED_FLAG := NVL(AttRec.CUSTOMER_ORDER_ENABLED_FLAG, 'N');
		  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.CUSTOMER_ORDER_ENABLED_FLAG := NVL(AttRec.CUSTOMER_ORDER_ENABLED_FLAG, master_rec.CUSTOMER_ORDER_ENABLED_FLAG);
		  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
		     AttRec.CUSTOMER_ORDER_ENABLED_FLAG := NVL(AttRec.CUSTOMER_ORDER_ENABLED_FLAG,org_rec.CUSTOMER_ORDER_ENABLED_FLAG);
		  END IF;
	        END IF;
            ELSIF AttRec.customer_order_flag = 'N' THEN
               AttRec.CUSTOMER_ORDER_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name = 'MTL_SYSTEM_ITEMS.INTERNAL_ORDER_ENABLED_FLAG' THEN
            IF AttRec.internal_order_flag = 'Y' THEN
	         IF(cr.control_level=1) AND (Master_Org ='N') THEN
		     AttRec.INTERNAL_ORDER_ENABLED_FLAG := master_rec.INTERNAL_ORDER_ENABLED_FLAG;
   	         ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.INTERNAL_ORDER_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.INTERNAL_ORDER_ENABLED_FLAG := NVL(AttRec.INTERNAL_ORDER_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.INTERNAL_ORDER_ENABLED_FLAG := NVL(AttRec.INTERNAL_ORDER_ENABLED_FLAG, 'N');
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.INTERNAL_ORDER_ENABLED_FLAG := NVL(AttRec.INTERNAL_ORDER_ENABLED_FLAG, master_rec.INTERNAL_ORDER_ENABLED_FLAG);
		  ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
		     AttRec.INTERNAL_ORDER_ENABLED_FLAG := NVL(AttRec.INTERNAL_ORDER_ENABLED_FLAG,org_rec.INTERNAL_ORDER_ENABLED_FLAG );
		  END IF;
	       END IF;
            ELSIF AttRec.internal_order_flag = 'N' THEN
               AttRec.INTERNAL_ORDER_ENABLED_FLAG := 'N';
            END IF;
         END IF;

         IF cr.attribute_name = 'MTL_SYSTEM_ITEMS.BOM_ENABLED_FLAG' THEN
	    IF(cr.control_level=1) AND (Master_Org ='N') THEN
	       AttRec.BOM_ENABLED_FLAG := master_rec.BOM_ENABLED_FLAG;
  	    ELSE
               IF ( cr.status_control_code = 1 ) THEN
                  AttRec.BOM_ENABLED_FLAG := cr.attribute_value;
               ELSIF ( cr.status_control_code = 2 ) THEN
                  AttRec.BOM_ENABLED_FLAG := NVL(AttRec.BOM_ENABLED_FLAG, cr.attribute_value);
               ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                  AttRec.BOM_ENABLED_FLAG := NVL(AttRec.BOM_ENABLED_FLAG, 'N');
               ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                  AttRec.BOM_ENABLED_FLAG := NVL(AttRec.BOM_ENABLED_FLAG, master_rec.BOM_ENABLED_FLAG);
	       ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
	          AttRec.BOM_ENABLED_FLAG := NVL(AttRec.BOM_ENABLED_FLAG,org_rec.BOM_ENABLED_FLAG );
	       END IF;
            END IF;-- Master_Org ='N'
         END IF;

         IF ( cr.attribute_name = 'MTL_SYSTEM_ITEMS.RECIPE_ENABLED_FLAG' ) THEN
            IF(cr.control_level=1) AND (Master_Org ='N') THEN
	       AttRec.RECIPE_ENABLED_FLAG := master_rec.RECIPE_ENABLED_FLAG;
  	    ELSE
               IF ( cr.status_control_code = 1 ) THEN
                  AttRec.RECIPE_ENABLED_FLAG := cr.attribute_value;
               ELSIF ( cr.status_control_code = 2 ) THEN
                  AttRec.RECIPE_ENABLED_FLAG := NVL(AttRec.RECIPE_ENABLED_FLAG, cr.attribute_value);
               ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                  AttRec.RECIPE_ENABLED_FLAG := NVL(AttRec.RECIPE_ENABLED_FLAG, 'N');
               ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                  AttRec.RECIPE_ENABLED_FLAG := NVL(AttRec.RECIPE_ENABLED_FLAG, master_rec.RECIPE_ENABLED_FLAG);
	       ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
                  AttRec.RECIPE_ENABLED_FLAG := NVL(AttRec.RECIPE_ENABLED_FLAG,org_rec.RECIPE_ENABLED_FLAG );
	       END IF;
            END IF;-- Master_Org ='N'
         END IF;

         IF ( cr.attribute_name = 'MTL_SYSTEM_ITEMS.PROCESS_EXECUTION_ENABLED_FLAG' ) THEN
            IF ( AttRec.INVENTORY_ITEM_FLAG = 'N' OR
	         AttRec.RECIPE_ENABLED_FLAG = 'N')       THEN
               AttRec.PROCESS_EXECUTION_ENABLED_FLAG := 'N';
            ELSE
               IF(cr.control_level=1) AND (Master_Org ='N') THEN
                  AttRec.PROCESS_EXECUTION_ENABLED_FLAG := master_rec.PROCESS_EXECUTION_ENABLED_FLAG;
               ELSE
                  IF ( cr.status_control_code = 1 ) THEN
                     AttRec.PROCESS_EXECUTION_ENABLED_FLAG := cr.attribute_value;
                  ELSIF ( cr.status_control_code = 2 ) THEN
                     AttRec.PROCESS_EXECUTION_ENABLED_FLAG := NVL(AttRec.PROCESS_EXECUTION_ENABLED_FLAG, cr.attribute_value);
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'Y') THEN
                     AttRec.PROCESS_EXECUTION_ENABLED_FLAG := NVL(AttRec.PROCESS_EXECUTION_ENABLED_FLAG, 'N');
                  ELSIF (AttRec.TRANSACTION_TYPE = 'CREATE' and Master_Org = 'N') THEN
                     AttRec.PROCESS_EXECUTION_ENABLED_FLAG := NVL(AttRec.PROCESS_EXECUTION_ENABLED_FLAG, master_rec.PROCESS_EXECUTION_ENABLED_FLAG);
	          ELSIF (AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
		     AttRec.PROCESS_EXECUTION_ENABLED_FLAG := NVL(AttRec.PROCESS_EXECUTION_ENABLED_FLAG,org_rec.PROCESS_EXECUTION_ENABLED_FLAG );
                  END IF;
              END IF;-- Master_Org ='N'
            END IF; --Bug: 5349389 INV AND RECIPE FLAG
         END IF;

      END LOOP;

      update MTL_SYSTEM_ITEMS_INTERFACE
      set
       STOCK_ENABLED_FLAG = AttRec.STOCK_ENABLED_FLAG,
       MTL_TRANSACTIONS_ENABLED_FLAG = AttRec.MTL_TRANSACTIONS_ENABLED_FLAG,
       PURCHASING_ENABLED_FLAG = AttRec.PURCHASING_ENABLED_FLAG,
       INVOICE_ENABLED_FLAG = AttRec.INVOICE_ENABLED_FLAG,
       BUILD_IN_WIP_FLAG = AttRec.BUILD_IN_WIP_FLAG,
       CUSTOMER_ORDER_ENABLED_FLAG = AttRec.CUSTOMER_ORDER_ENABLED_FLAG,
       INTERNAL_ORDER_ENABLED_FLAG = AttRec.INTERNAL_ORDER_ENABLED_FLAG,
       BOM_ENABLED_FLAG = AttRec.BOM_ENABLED_FLAG,
       RECIPE_ENABLED_FLAG = AttRec.RECIPE_ENABLED_FLAG,
       PROCESS_EXECUTION_ENABLED_FLAG = AttRec.PROCESS_EXECUTION_ENABLED_FLAG
      where rowid = p_rowid ;
   end if ; -- Main end if

   IF (AttRec.INVENTORY_ITEM_STATUS_CODE is null and AttRec.TRANSACTION_TYPE = 'UPDATE') THEN
      update mtl_system_items_interface
      set inventory_item_status_code = (select msi.inventory_item_status_code
                                        from mtl_system_items msi
                                        where msi.inventory_item_id = AttRec.inventory_item_id
                                        and msi.organization_id = AttRec.organization_id)
      where rowid = p_rowid;
   END IF;

   return(0);

EXCEPTION
   WHEN OTHERS THEN
      err_text := substr('INVPULI4.assign_status_attributes ' || SQLERRM, 1, 240);
      return(SQLCODE);
END assign_status_attributes;


END INVPULI4;

/
