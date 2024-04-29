--------------------------------------------------------
--  DDL for Package Body MSC_CL_DEMAND_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_DEMAND_ODS_LOAD" AS -- body
/* $Header: MSCLDEMB.pls 120.10.12010000.4 2009/06/26 09:13:24 sbyerram ship $ */

--    SYS_YES Number:=  MSC_CL_COLLECTION.SYS_YES ;
--    SYS_NO Number:=  MSC_CL_COLLECTION.SYS_NO ;
--    SYS_TGT Number:=MSC_CL_COLLECTION.SYS_TGT;
--    SYS_INCR Number:=MSC_CL_COLLECTION.SYS_INCR;
--    G_APPS110              NUMBER := MSC_CL_COLLECTION.G_APPS110;
--    G_APPS115              NUMBER :=MSC_CL_COLLECTION.G_APPS115;
--    G_ALL_ORGANIZATIONS    VARCHAR2(6):= MSC_CL_COLLECTION.G_ALL_ORGANIZATIONS;



   ---  PREPLACE CHANGE END  ---


 -- ******************************
  -- For External SO link the transaction id of the sales orders to supplies if
  -- complete refresh is performed and complete refresh sales orderes is no.
    PROCEDURE LINK_SUPP_SO_DEMAND_EXT IS

    lv_supply_id        NUMBER;
    lv_source_organization_id number;
    lv_source_sr_instance_id number;
    lv_supply_stmt VARCHAR2(5000);


     cursor link_supply_demand is
     select ROWID,INVENTORY_ITEM_ID,CUST_PO_NUMBER, SUPPLY_ID,CUSTOMER_LINE_NUMBER,SALES_ORDER_NUMBER
     from msc_sales_orders
     where demand_source_type = 2
     and reservation_type = 1
     and cust_po_number <> '-1'
     and customer_line_number <> '-1'
     and ( source_org_instance_id is Null or source_org_instance_id = MSC_CL_COLLECTION.v_instance_id );

     BEGIN

     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '==========================================================');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Starting LINK_SUPP_SO_DEMAND_EXT ......');
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '==========================================================');

     For c_rec in link_supply_demand
     loop
       BEGIN
      lv_supply_id := NULL;
      lv_source_organization_id := NULL;
      lv_source_sr_instance_id := NULL;

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '==========================================================');
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'CUST_PO_NUMBER: '|| c_rec.CUST_PO_NUMBER);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'CUSTOMER_LINE_NUMBER: '|| c_rec.CUSTOMER_LINE_NUMBER);
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Supply ID to be updated:'|| c_rec.supply_id);

       lv_supply_stmt :=
               'SELECT /*+ index(a,MSC_SUPPLIES_N5)*/ TRANSACTION_ID ,ORGANIZATION_ID, SR_INSTANCE_ID '
               ||' FROM  MSC_SUPPLIES a '
               ||' WHERE  a.PLAN_ID = -1'
               ||' AND    a.order_number = :CUST_PO_NUMBER'
               ||' AND    to_char(a.purch_line_num)  = :CUSTOMER_LINE_NUMBER'
               ||' AND    a.order_type = 1 '
               ||' AND    a.INVENTORY_ITEM_ID = :INVENTORY_ITEM_ID '
               ||' AND    ROWNUM = 1 '
               ||' AND    NOT EXISTS (  SELECT /*+ index(b,MSC_SUPPLIES_N5)*/ 1 '
               ||'                      FROM  MSC_SUPPLIES b '
               ||'                      WHERE  b.PLAN_ID = -1 '
               ||'                      AND    b.order_number = :CUST_PO_NUMBER'
               ||'                      AND    to_char(b.purch_line_num)  = :CUSTOMER_LINE_NUMBER '
               ||'                      AND    b.order_type = 1 '
               ||'                      AND    b.INVENTORY_ITEM_ID = :INVENTORY_ITEM_ID )';
               EXECUTE IMMEDIATE lv_supply_stmt
                     INTO lv_supply_id, lv_source_organization_id, lv_source_sr_instance_id
                     USING c_rec.CUST_PO_NUMBER||'('||' )'||'('||c_rec.CUSTOMER_LINE_NUMBER||')'||'(1)', c_rec.CUSTOMER_LINE_NUMBER,c_rec.INVENTORY_ITEM_ID,
                           c_rec.CUST_PO_NUMBER||'('||' )'||'('||c_rec.CUSTOMER_LINE_NUMBER||')'||'(2)', c_rec.CUSTOMER_LINE_NUMBER,c_rec.INVENTORY_ITEM_ID;





       Update msc_sales_orders
       set supply_id = lv_supply_id,
           source_organization_id = lv_source_organization_id,
           source_org_instance_id = lv_source_sr_instance_id
       where rowid = c_rec.rowid;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'New Supply Id is: '||lv_supply_id);

       EXCEPTION WHEN NO_DATA_FOUND THEN
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'No link for External Sales Order:'||c_rec.sales_order_number||'inst='||to_char(MSC_CL_COLLECTION.v_instance_id) );

       WHEN OTHERS THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The Error Message is: '||SQLERRM);
       NULL;
       END;
     end loop;
     commit;
      EXCEPTION WHEN OTHERS THEN
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The Error Message is: '||SQLERRM);
      NULL;

 		END LINK_SUPP_SO_DEMAND_EXT;

 		-- ******************************
	-- Link the transaction id of the sales orders to supplies if
	-- complete refresh is performed and complete refresh sales orderes is no.
	PROCEDURE LINK_SUPP_SO_DEMAND_110 IS

	    lv_SUPPLY_ID        NUMBER;
	    lv_source_organization_id number;
	    lv_source_sr_instance_id number;
	    lv_supply_tbl  VARCHAR2(30);
	    lv_supply_stmt VARCHAR2(5000);

	     cursor link_supply_demand(c_instance_id number) is
	     select SR_INSTANCE_ID,INVENTORY_ITEM_ID,ORGANIZATION_ID,
		    DEMAND_SOURCE_TYPE,DEMAND_SOURCE_HEADER_ID,reservation_type,
		    original_system_reference ,original_system_line_reference, supply_id,
		    sales_order_number
	     from msc_sales_orders
	     where sr_instance_id = c_instance_id
	     and demand_source_type = 8
	     and reservation_type = 1
	     and original_system_reference  <> '-1'
	     and supply_id is not null;

	     BEGIN
	     IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
	       lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
	     ELSE
	       lv_supply_tbl:= 'MSC_SUPPLIES';
	     END IF;

	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '==========================================================');
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Starting LINK_SUPP_SO_DEMAND_110 ......');
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Supply table is: '||lv_supply_tbl);
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '==========================================================');

	     For c_rec in link_supply_demand (MSC_CL_COLLECTION.v_instance_id)
	     loop
	       BEGIN
      lv_supply_id := NULL;
      lv_source_organization_id := NULL;
      lv_source_sr_instance_id := NULL;

			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '==========================================================');
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ORIGINAL_SYSTEM_REFERENCE: '||c_rec.ORIGINAL_SYSTEM_REFERENCE);
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ORIGINAL_SYSTEM_LINE_REFERENCE: '|| c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE);
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Supply ID to be updated:'|| c_rec.supply_id);

	       lv_supply_stmt :=
		       'SELECT TRANSACTION_ID ,ORGANIZATION_ID, SOURCE_SR_INSTANCE_ID '
		       ||' FROM '||  lv_supply_tbl
		       ||' WHERE    PLAN_ID = -1 '
		       ||' AND  SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
		       ||' AND    order_number = :ORIGINAL_SYSTEM_REFERENCE '
		       ||' AND    to_char(purch_line_num) = :ORIGINAL_SYSTEM_LINE_REFERENCE '
		       ||' AND    order_type =  2 '
               ||' AND    new_order_quantity > 0' -- bug 8424335
		       ||' AND    source_organization_id is not null  ';

		       EXECUTE IMMEDIATE lv_supply_stmt
			     INTO lv_supply_id, lv_source_organization_id, lv_source_sr_instance_id
			     USING c_rec.ORIGINAL_SYSTEM_REFERENCE,c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE;

	       Update msc_sales_orders
	       set supply_id = lv_supply_id,
		   	 source_organization_id = lv_source_organization_id,
		     source_org_instance_id = lv_source_sr_instance_id
	       where sr_instance_id = MSC_CL_COLLECTION.v_instance_id
	       and demand_source_type = 8
	       and supply_id = c_rec.supply_id
	       and ORIGINAL_SYSTEM_REFERENCE = c_rec.ORIGINAL_SYSTEM_REFERENCE
	       and ORIGINAL_SYSTEM_LINE_REFERENCE = c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE ;

	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'New Supply Id is: '||lv_supply_id);

	       EXCEPTION WHEN NO_DATA_FOUND THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'No link for Internal Sales Order:'||c_rec.sales_order_number);
			 WHEN OTHERS THEN
		    MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error: '||SQLERRM);
	       END;
	     end loop;
	     commit;
	      EXCEPTION WHEN OTHERS THEN
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error : '||SQLERRM);
	       NULL;

		END LINK_SUPP_SO_DEMAND_110;

		-- Link the transaction id of the sales orders to supplies if
	-- complete refresh is performed and complete refresh sales orderes is no.
	--****************************

	-- ******************************
	-- Link the transaction id of the sales orders to supplies if
	-- complete refresh is performed and complete refresh sales orderes is no.
	PROCEDURE LINK_SUPP_SO_DEMAND_11I2 IS

	    lv_SUPPLY_ID        NUMBER;
	    lv_source_organization_id number;
	    lv_source_sr_instance_id number;
	    lv_supply_tbl  VARCHAR2(30);
	    lv_supply_stmt VARCHAR2(5000);
	     cursor link_supply_demand(c_instance_id number) is
	     select SR_INSTANCE_ID,INVENTORY_ITEM_ID,ORGANIZATION_ID,
		    DEMAND_SOURCE_TYPE,DEMAND_SOURCE_HEADER_ID,reservation_type,
		    original_system_reference ,original_system_line_reference, supply_id,
		    sales_order_number
	     from msc_sales_orders
	     where sr_instance_id = c_instance_id
	     and demand_source_type = 8
	     and reservation_type = 1
	     and original_system_reference  <> '-1'
	     and supply_id is not null;

	     BEGIN
	     IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
	       lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
	     ELSE
	       lv_supply_tbl:= 'MSC_SUPPLIES';
	     END IF;

	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '==========================================================');
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Starting LINK_SUPP_SO_DEMAND_11I2 ......');
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Supply table is: '||lv_supply_tbl);
	     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '==========================================================');

	     For c_rec in link_supply_demand (MSC_CL_COLLECTION.v_instance_id)
	     loop
	       BEGIN
      lv_supply_id := NULL;
      lv_source_organization_id := NULL;
      lv_source_sr_instance_id := NULL;

		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '==========================================================');
		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ORIGINAL_SYSTEM_REFERENCE: '||c_rec.ORIGINAL_SYSTEM_REFERENCE);
		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ORIGINAL_SYSTEM_LINE_REFERENCE: '|| c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE);
		MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Supply ID to be updated:'|| c_rec.supply_id);

	       lv_supply_stmt :=
		       'SELECT TRANSACTION_ID ,ORGANIZATION_ID, SOURCE_SR_INSTANCE_ID '
		       ||' FROM '||  lv_supply_tbl
		       ||' WHERE    PLAN_ID = -1 '
		       ||' AND  SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
		       ||' AND    disposition_id = to_number(:ORIGINAL_SYSTEM_REFERENCE) '
		       ||' AND   po_line_id = to_number(:ORIGINAL_SYSTEM_LINE_REFERENCE) '
		       ||' AND    order_type in  (2,73) '
               ||' AND    new_order_quantity > 0' -- bug 8424335
		       ||' AND    source_organization_id is not null  ';

		       EXECUTE IMMEDIATE lv_supply_stmt
			     INTO lv_supply_id, lv_source_organization_id, lv_source_sr_instance_id
			     USING c_rec.ORIGINAL_SYSTEM_REFERENCE,c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE;

	       Update msc_sales_orders
	       set supply_id = lv_supply_id,
		   source_organization_id = lv_source_organization_id,
		   source_org_instance_id = lv_source_sr_instance_id
	       where sr_instance_id = MSC_CL_COLLECTION.v_instance_id
	       and demand_source_type = 8
	       and supply_id = c_rec.supply_id
	       and ORIGINAL_SYSTEM_REFERENCE = c_rec.ORIGINAL_SYSTEM_REFERENCE
	       and ORIGINAL_SYSTEM_LINE_REFERENCE = c_rec.ORIGINAL_SYSTEM_LINE_REFERENCE ;

	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'New Supply Id is: '||lv_supply_id);



	       EXCEPTION WHEN NO_DATA_FOUND THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'No link for Internal Sales Order:'||c_rec.sales_order_number);
			 WHEN OTHERS THEN
			MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error: '||SQLERRM);
	       END;
	     end loop;
	     commit;
	      EXCEPTION WHEN OTHERS THEN
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error : '||SQLERRM);
	      NULL;

		END LINK_SUPP_SO_DEMAND_11I2;
		-- Link the transaction id of the sales orders to supplies if
		-- complete refresh is performed and complete refresh sales orderes is no.

		FUNCTION  drop_demands_tmp_ind
		RETURN boolean
		IS
		   lv_temp_sql_stmt   VARCHAR2(2000);
		   lv_ind_name        VARCHAR2(30);
		   lv_drop_index      NUMBER;

		   lv_retval boolean;
		   lv_dummy1 varchar2(32);
		   lv_dummy2 varchar2(32);

		   lv_msc_schema varchar2(32);


		BEGIN

		 lv_retval := FND_INSTALLATION.GET_APP_INFO('FND', lv_dummy1, lv_dummy2 , MSC_CL_COLLECTION.v_applsys_schema);

		 lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,lv_msc_schema);

		      EXECUTE IMMEDIATE
				          ' SELECT 1  '
				        ||' from all_indexes '
				        ||'  where owner =  :p_schema '
				        ||'  and table_owner = :p_schema '
				        ||'  and index_name = upper(''DEMANDS_NX_'||MSC_CL_COLLECTION.v_instance_code||''') '
				   INTO lv_drop_index
		                   USING lv_msc_schema,lv_msc_schema;

		      IF (lv_drop_index = 1) THEN
			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropping the index : DEMANDS_NX_'||MSC_CL_COLLECTION.v_instance_code);
		               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
		                              application_short_name => 'MSC',
		                              statement_type => AD_DDL.DROP_INDEX,
		                              statement =>
		                              'drop index demands_nx_'||MSC_CL_COLLECTION.v_instance_code,
		                              object_name => 'demands_nx_'||MSC_CL_COLLECTION.v_instance_code);

			       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropped the index : DEMANDS_NX_'||MSC_CL_COLLECTION.v_instance_code);
		      END IF;

		     RETURN true;
		  EXCEPTION
		       WHEN NO_DATA_FOUND THEN
		            RETURN true;

		       WHEN OTHERS THEN
		            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		            RETURN FALSE;
		 END drop_demands_tmp_ind;


		FUNCTION  drop_sales_orders_tmp_ind
		RETURN boolean
		IS
		   lv_drop_index      NUMBER;

		   lv_retval boolean;
		   lv_dummy1 varchar2(32);
		   lv_dummy2 varchar2(32);

		    lv_msc_schema varchar2(32);

		BEGIN

 			lv_retval := FND_INSTALLATION.GET_APP_INFO('FND', lv_dummy1, lv_dummy2 , MSC_CL_COLLECTION.v_applsys_schema);

 			lv_retval := FND_INSTALLATION.GET_APP_INFO ('MSC', lv_dummy1, lv_dummy2,lv_msc_schema);

      EXECUTE IMMEDIATE
		          ' SELECT 1  '
		        ||' from all_indexes '
		        ||'  where owner =  :p_schema '
		        ||'  and table_owner = :p_schema '
		        ||'  and index_name = upper(''SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code||''') '
		   INTO lv_drop_index
                   USING lv_msc_schema, lv_msc_schema;

      IF (lv_drop_index = 1) THEN
	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropping the index : SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code);
               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
                              application_short_name => 'MSC',
                              statement_type => AD_DDL.DROP_INDEX,
                              statement =>
                              'drop index SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code,
                              object_name => 'SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code);

	       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Dropped the index : SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code);
      END IF;

     RETURN true;
    	EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN true;

       WHEN OTHERS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
            RETURN FALSE;
		END drop_sales_orders_tmp_ind;

		/* This is a new function added to Link the Sales orders line to its immediate
   Parent sales orders line  for the project Sales Orders Pegging enhancement */
	FUNCTION LINK_PARENT_SALES_ORDERS
	RETURN BOOLEAN
	IS

	   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type -Cursor variable
	   c1              CurTyp;

	   lv_link_id_list    NUMBER;
	   lv_demand_id_list  NUMBER;

	   lv_sel_sql_stmt     VARCHAR2(2000);
	   lv_upd_sql_stmt     VARCHAR2(2000);
	   lv_tbl              VARCHAR2(30);

	   lv_refresh_no       NUMBER;
	   lv_exchange_mode    NUMBER:= MSC_UTIL.SYS_NO;
	   lv_task_start_time  DATE;
	   lv_upd_count        NUMBER := 0;

	   lv_retval boolean;
	   lv_dummy1 varchar2(32);
	   lv_dummy2 varchar2(32);
	BEGIN

   lv_task_start_time := SYSDATE;

        IF (MSC_CL_COLLECTION.v_so_exchange_mode= MSC_UTIL.SYS_YES AND MSC_CL_COLLECTION.is_msctbl_partitioned('MSC_SALES_ORDERS') ) THEN
                       lv_exchange_mode := MSC_UTIL.SYS_YES;
        END IF;

        IF lv_exchange_mode=MSC_UTIL.SYS_YES THEN
            lv_tbl:= 'SALES_ORDERS_'||MSC_CL_COLLECTION.v_instance_code;
            lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'FND', lv_dummy1, lv_dummy2, MSC_CL_COLLECTION.v_applsys_schema);

            ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
                           application_short_name => 'MSC',
                           statement_type => AD_DDL.CREATE_INDEX,
                           statement =>
                           'create index SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code
                            ||' on '||'SALES_ORDERS_'||MSC_CL_COLLECTION.v_instance_code
                            ||'(link_to_line_id,reservation_type,sr_instance_id) '
			    ||' PARALLEL  ' || MSC_CL_COLLECTION.G_DEG_PARALLEL
                            ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
                            object_name => 'SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code);

            msc_analyse_tables_pk.analyse_table( 'SALES_ORDERS_'||MSC_CL_COLLECTION.v_instance_code, MSC_CL_COLLECTION.v_instance_id, -1);

             MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Index SALES_ORDERS_NX_'||MSC_CL_COLLECTION.v_instance_code||' created.');
        ELSE
            lv_tbl:= 'MSC_SALES_ORDERS';
        END IF;

       /* select the link_to_line_id and its corresponding demand_id into Collection variables */

	  lv_sel_sql_stmt := ' SELECT  distinct mso1.link_to_line_id '
                  ||'                  ,mso2.demand_id '
                  ||'   FROM  '|| lv_tbl ||' mso1, '
                  ||              lv_tbl ||' mso2  '
                  ||'  WHERE  mso1.sr_instance_id  =  '|| MSC_CL_COLLECTION.v_instance_id
                  ||'    AND  mso1.sr_instance_id  = mso2.sr_instance_id '
                  ||'    AND  mso1.link_to_line_id = to_number(mso2.demand_source_line) '
                  ||'    AND  mso1.link_to_line_id IS NOT NULL '
                  ||'    AND  mso1.RESERVATION_TYPE = mso2.RESERVATION_TYPE '
                  ||'    AND  mso2.INVENTORY_ITEM_ID = nvl(mso2.ORDERED_ITEM_ID,mso2.INVENTORY_ITEM_ID) '
                  ||'    AND  mso2.primary_uom_quantity > 0 '
                  ||'    AND  mso1.RESERVATION_TYPE = 1 ';

        IF MSC_CL_COLLECTION.v_is_so_incremental_refresh THEN
		/* If incremental of Sales orders then select rows only for collected data */
	   lv_sel_sql_stmt := lv_sel_sql_stmt || ' AND mso1.REFRESH_NUMBER =  ' || MSC_CL_COLLECTION.v_last_collection_id;
		END IF;

        --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'The Select statement: '||lv_sel_sql_stmt);

  	OPEN  c1 FOR lv_sel_sql_stmt;        -- open the REF cursor

		 LOOP
		  FETCH c1 INTO
		         lv_link_id_list, lv_demand_id_list;

		     EXIT WHEN c1%NOTFOUND;

		          /* If the above select clause has more than 1 row , Update the PARENT_ID
		             in msc_sales_orders Table with the Demand_id of the Parent line_id */

		            EXECUTE IMMEDIATE
		                    '  UPDATE ' || lv_tbl
		                  ||'   SET  parent_id = :demand_id_value '
		                  ||' WHERE  sr_instance_id   = :instance_id '
		                  ||'   AND  link_to_line_id  = :link_id_value '
		                  ||'   AND  RESERVATION_TYPE = 1 '
		            USING lv_demand_id_list,
		                  MSC_CL_COLLECTION.v_instance_id,
		                  lv_link_id_list;

		 END LOOP;

		    COMMIT;

		  CLOSE c1;                -- close the REF cursor

		     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
		     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
		                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
		     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '   '||FND_MESSAGE.GET);

		 RETURN TRUE;

		EXCEPTION
		   WHEN OTHERS THEN
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error executing LINK_PARENT_SALES_ORDERS......');
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		   RETURN FALSE;

		END LINK_PARENT_SALES_ORDERS;

		/* This is a new function added to Link the Sales orders line in a MDS to its immediate
   Parent sales orders line  for the project Sales Orders Pegging enhancement */
		FUNCTION LINK_PARENT_SALES_ORDERS_MDS
		RETURN BOOLEAN
		IS

		   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type -Cursor variable
		   c1              CurTyp;

		   lv_link_id_list    NUMBER;
		   lv_demand_id_list  NUMBER;

		   lv_sel_sql_stmt     VARCHAR2(2000);
		   lv_upd_sql_stmt     VARCHAR2(2000);
		   lv_tbl              VARCHAR2(30);

		   lv_refresh_no       NUMBER;
		   lv_exchange_mode    NUMBER:= MSC_UTIL.SYS_NO;
		   lv_upd_count        NUMBER := 0;
		   lv_task_start_time  DATE;

		   lv_retval boolean;
		   lv_dummy1 varchar2(32);
		   lv_dummy2 varchar2(32);
		BEGIN

   lv_task_start_time := SYSDATE;

        IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
             lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
             lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'FND', lv_dummy1, lv_dummy2, MSC_CL_COLLECTION.v_applsys_schema);

               ad_ddl.do_ddl( applsys_schema => MSC_CL_COLLECTION.v_applsys_schema,
                              application_short_name => 'MSC',
                              statement_type => AD_DDL.CREATE_INDEX,
                              statement =>
                              'create index demands_nx_'||MSC_CL_COLLECTION.v_instance_code
                              ||' on '||'demands_'||MSC_CL_COLLECTION.v_instance_code
                              ||'(link_to_line_id,origination_type,sr_instance_id,plan_id) '
			      ||' PARALLEL  ' || MSC_CL_COLLECTION.G_DEG_PARALLEL
                              ||' STORAGE (INITIAL 100K NEXT 1M PCTINCREASE 0) ',
                              object_name => 'demands_nx_'||MSC_CL_COLLECTION.v_instance_code);

               msc_analyse_tables_pk.analyse_table( 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code, MSC_CL_COLLECTION.v_instance_id, -1);

               MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' Index DEMANDS_NX_'||MSC_CL_COLLECTION.v_instance_code||' created.');
        ELSE
             lv_tbl:= 'MSC_DEMANDS';
        END IF;

       /* select the link_to_line_id and its corresponding demand_id into Collection variables */

 		 lv_sel_sql_stmt := ' SELECT  distinct md1.link_to_line_id '
                  ||'                  ,md2.demand_id '
                  ||'   FROM  '|| lv_tbl ||' md1, '
                  ||              lv_tbl ||' md2  '
                  ||'  WHERE  md1.sr_instance_id   =  ' ||MSC_CL_COLLECTION.v_instance_id
                  ||'    AND  md1.plan_id          = -1 '
                  ||'    AND  md1.origination_type = 6 '
                  ||'    AND  md1.sr_instance_id   = md2.sr_instance_id '
                  ||'    AND  md1.plan_id          = md2.plan_id '
                  ||'    AND  md1.origination_type = md2.origination_type '
                  ||'    AND  md1.link_to_line_id  = md2.sales_order_line_id '
                  ||'    AND  md1.link_to_line_id IS NOT NULL ';

		/* If incremental of Sales Orders demands then select rows only for collected data */
           IF (MSC_CL_COLLECTION.v_is_cont_refresh) THEN
	       IF (MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_INCR) THEN
	             lv_sel_sql_stmt := lv_sel_sql_stmt || ' AND md1.REFRESH_NUMBER =  ' || MSC_CL_COLLECTION.v_last_collection_id;
	       END IF;
	   ELSIF (MSC_CL_COLLECTION.v_is_incremental_refresh) THEN
	             lv_sel_sql_stmt := lv_sel_sql_stmt || ' AND md1.REFRESH_NUMBER =  ' || MSC_CL_COLLECTION.v_last_collection_id;
	   END IF;

        --MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'The Select statement: '||lv_sel_sql_stmt);

	 OPEN  c1 FOR lv_sel_sql_stmt;        -- open the REF cursor

  	LOOP

     FETCH c1 INTO
              lv_link_id_list, lv_demand_id_list;

     EXIT WHEN c1%NOTFOUND;

          /* If the above select clause has more than 1 row , Update the PARENT_ID
             in msc_sales_orders Table with the Demand_id of the Parent line_id */

            EXECUTE IMMEDIATE
                    '  UPDATE ' || lv_tbl
                  ||'   SET  parent_id = :demand_id_value '
                  ||' WHERE  sr_instance_id   = :instance_id '
                  ||'   AND  plan_id = -1 '
                  ||'   AND  origination_type = 6 '
                  ||'   AND  link_to_line_id  = :link_id_value '
            USING lv_demand_id_list,
                  MSC_CL_COLLECTION.v_instance_id,
                  lv_link_id_list;

 	 END LOOP;

    COMMIT;

 	 	CLOSE c1;                -- close the REF cursor

     FND_MESSAGE.SET_NAME('MSC', 'MSC_ELAPSED_TIME');
     FND_MESSAGE.SET_TOKEN('ELAPSED_TIME',
                 TO_CHAR(CEIL((SYSDATE- lv_task_start_time)*14400.0)/10));
     MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '   '||FND_MESSAGE.GET);

 		RETURN TRUE;

		EXCEPTION
		   WHEN OTHERS THEN
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error executing LINK_PARENT_SALES_ORDERS_MDS......');
		          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);

		   RETURN FALSE;

		END LINK_PARENT_SALES_ORDERS_MDS;

		PROCEDURE LOAD_ITEM_FORECASTS IS

			CURSOR c1_d IS
			SELECT msd.SALES_ORDER_LINE_ID,
			       t1.INVENTORY_ITEM_ID,
			       msd.ORIGINATION_TYPE,
			       msd.SR_INSTANCE_ID,
			       msd.ORGANIZATION_ID
			  FROM MSC_ITEM_ID_LID t1,
			       MSC_ST_DEMANDS msd
			 WHERE msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
			   AND msd.ORIGINATION_TYPE = 29
			   AND msd.DELETED_FLAG= MSC_UTIL.SYS_YES
			   AND t1.SR_INVENTORY_ITEM_ID(+)= msd.inventory_item_id
			   AND t1.sr_instance_id(+)= MSC_CL_COLLECTION.v_instance_id;

			/* for bug: 2351354, made the changes to cursor to select the customer_id and the ship_to_site_id
			from the msc_designators, becasue the customer inform can be entered at the Forecast level on the source */

			CURSOR c1 IS
			   SELECT
			   t1.INVENTORY_ITEM_ID,
			   msd.forecast_designator,
			   msd.ORIGINATION_TYPE,
			   msd.ORGANIZATION_ID,
			   decode(t2.INVENTORY_ITEM_ID,NULL,t1.INVENTORY_ITEM_ID,t2.INVENTORY_ITEM_ID) USING_ASSEMBLY_ITEM_ID,
			   msd.USING_ASSEMBLY_DEMAND_DATE,
			   msd.USING_REQUIREMENT_QUANTITY,
			   msd.ASSEMBLY_DEMAND_COMP_DATE,
			   msd.SOURCE_ORGANIZATION_ID,
			   msd.FORECAST_MAD,
			   msd.CONFIDENCE_PERCENTAGE,
			   msd.BUCKET_TYPE,
			   md.DEMAND_CLASS,
			   msd.ORDER_PRIORITY,
			   msd.SR_INSTANCE_ID,
			   msd.PROJECT_ID,
			   msd.TASK_ID,
			   msd.PLANNING_GROUP,
			   md.DESIGNATOR_ID SCHEDULE_DESIGNATOR_ID,
			   nvl(md.FORECAST_SET_ID,md.DESIGNATOR_ID) FORECAST_SET_ID,
			   msd.SALES_ORDER_LINE_ID,
			   msd.DELETED_FLAG,
			   msd.demand_type,
			   nvl(msd.probability,md.probability) probability,
			  -- c1.tp_id customer_id,
			   md.customer_id customer_id,
			   md.ship_id CUSTOMER_SITE_ID,
			   md.ship_id SHIP_TO_SITE_ID
			FROM
			    -- msc_tp_id_lid c1,
			     MSC_ITEM_ID_LID t1,
			     MSC_ITEM_ID_LID t2,
			     MSC_DESIGNATORS md,
			     MSC_ST_DEMANDS msd
			WHERE t1.SR_INVENTORY_ITEM_ID=  msd.inventory_item_id
			  AND t1.sr_instance_id=        msd.sr_instance_id
			  AND t2.SR_INVENTORY_ITEM_ID(+)=  nvl(msd.using_assembly_item_id,msd.inventory_item_id)
			  AND t2.sr_instance_id(+)= msd.sr_instance_id
			  AND msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
			  AND md.SR_INSTANCE_ID(+)= msd.SR_INSTANCE_ID
			  AND md.DESIGNATOR(+)= msd.forecast_designator
			  AND md.Organization_ID(+)= msd.Organization_ID
			 -- AND c1.partner_type(+)  = 2
			 -- and c1.sr_tp_id(+) = msd.customer_id
			 -- and c1.sr_instance_id(+) = msd.sr_instance_id
			  and msd.origination_type= 29
			  and msd.deleted_flag = 2
			  order by msd.SOURCE_SALES_ORDER_LINE_ID;

			   c_count     NUMBER:=0;
			   lv_tbl      VARCHAR2(30);
			   lv_sql_stmt VARCHAR2(5000);
			   lv_sql_ins           VARCHAR2(5000);

			BEGIN

			IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
			   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
			ELSE
			   lv_tbl:= 'MSC_DEMANDS';
			END IF;

			IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
			  BEGIN
			lv_sql_ins :=
			' INSERT /*+ append  */ '
			|| ' INTO '||lv_tbl
			||'(  PLAN_ID,'
			||'   DEMAND_ID,'
			||'   DEMAND_TYPE,'
			||'   ORIGINATION_TYPE,'
			||'   INVENTORY_ITEM_ID,'
			||'   ORGANIZATION_ID,'
			||'   SCHEDULE_DESIGNATOR_ID,'
			||'   FORECAST_SET_ID,'
			||'   USING_ASSEMBLY_ITEM_ID,'
			||'   USING_ASSEMBLY_DEMAND_DATE,'
			||'   USING_REQUIREMENT_QUANTITY,'
			||'   ASSEMBLY_DEMAND_COMP_DATE,'
			||'   SOURCE_ORGANIZATION_ID,'
			||'   DEMAND_CLASS,'
			||'   ORDER_PRIORITY,'
			||'   FORECAST_MAD,'
			||'   CONFIDENCE_PERCENTAGE,'
			||'   PROBABiLITY,'
			||'   BUCKET_TYPE,'
			||'   SR_INSTANCE_ID,'
			||'   PROJECT_ID,'
			||'   TASK_ID,'
			||'   SALES_ORDER_LINE_ID,'
			||'   DISPOSITION_ID,'
			||'   CUSTOMER_ID,'
			||'   CUSTOMER_SITE_ID,'
			||'   SHIP_TO_SITE_ID,'
			||'   PLANNING_GROUP,'
			||'   REFRESH_NUMBER,'
			||'   LAST_UPDATE_DATE,'
			||'   LAST_UPDATED_BY,'
			||'   CREATION_DATE,'
			||'   CREATED_BY) '
			||'   SELECT '
			||'   -1,'
			||'   MSC_DEMANDS_S.nextval,'
			||'   msd.demand_type,'
			||'   msd.ORIGINATION_TYPE,'
			||'   t1.INVENTORY_ITEM_ID,'
			||'   msd.ORGANIZATION_ID,'
			||'   md.DESIGNATOR_ID,'
			||'   md.FORECAST_SET_ID,'
			||'   decode(t2.INVENTORY_ITEM_ID,NULL,t1.INVENTORY_ITEM_ID,t2.INVENTORY_ITEM_ID),'
			||'   msd.USING_ASSEMBLY_DEMAND_DATE,'
			||'   msd.USING_REQUIREMENT_QUANTITY,'
			||'   msd.ASSEMBLY_DEMAND_COMP_DATE,'
			||'   msd.SOURCE_ORGANIZATION_ID,'
			||'   md.DEMAND_CLASS,'
			||'   msd.ORDER_PRIORITY,'
			||'   msd.FORECAST_MAD,'
			||'   msd.CONFIDENCE_PERCENTAGE,'
			||'   nvl(msd.probability,md.probability),'
			||'   msd.BUCKET_TYPE,'
			||'   msd.SR_INSTANCE_ID,'
			||'   msd.PROJECT_ID,'
			||'   msd.TASK_ID,'
			||'   msd.SALES_ORDER_LINE_ID,'
			||'   msd.SALES_ORDER_LINE_ID,'
			||'   md.customer_id,'
			||'   md.ship_id,'
			||'   md.ship_id,'
			||'   msd.PLANNING_GROUP,'
			||'   :v_last_collection_id, '
			||'   :v_current_date      , '
			||'   :v_current_user      , '
			||'   :v_current_date      , '
			||'   :v_current_user        '
			||' FROM '
			||'     MSC_ITEM_ID_LID t1, '
			||'     MSC_ITEM_ID_LID t2, '
			||'     MSC_DESIGNATORS md, '
			||'     MSC_ST_DEMANDS msd '
			||'WHERE t1.SR_INVENTORY_ITEM_ID=  msd.inventory_item_id '
			||'  AND t1.sr_instance_id=        msd.sr_instance_id '
			||'  AND t2.SR_INVENTORY_ITEM_ID(+)=  nvl(msd.using_assembly_item_id,msd.inventory_item_id) '
			||'  AND t2.sr_instance_id(+)= msd.sr_instance_id '
			||'  AND msd.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id
			||'  AND md.SR_INSTANCE_ID(+)= msd.SR_INSTANCE_ID '
			||'  AND md.DESIGNATOR(+)= msd.forecast_designator '
			||'  AND md.Organization_ID(+)= msd.Organization_ID '
			||'  and msd.origination_type= 29 '
			||'  and msd.deleted_flag = 2 ';

			execute IMMEDIATE lv_sql_ins
			USING MSC_CL_COLLECTION.v_last_collection_id,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user,MSC_CL_COLLECTION.v_current_date,MSC_CL_COLLECTION.v_current_user;

			COMMIT;
			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECASTS');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECASTS');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;
			END;

			ELSE

			lv_sql_stmt:=
			'INSERT INTO '||lv_tbl
			||'(  PLAN_ID,'
			||'   DEMAND_ID,'
			||'   DEMAND_TYPE,'
			||'   ORIGINATION_TYPE,'
			||'   INVENTORY_ITEM_ID,'
			||'   ORGANIZATION_ID,'
			||'   SCHEDULE_DESIGNATOR_ID,'
			||'   FORECAST_SET_ID,'
			||'   USING_ASSEMBLY_ITEM_ID,'
			||'   USING_ASSEMBLY_DEMAND_DATE,'
			||'   USING_REQUIREMENT_QUANTITY,'
			||'   ASSEMBLY_DEMAND_COMP_DATE,'
			||'   SOURCE_ORGANIZATION_ID,'
			||'   DEMAND_CLASS,'
			||'   ORDER_PRIORITY,'
			||'   FORECAST_MAD,'
			||'   CONFIDENCE_PERCENTAGE,'
			||'   PROBABiLITY,'
			||'   BUCKET_TYPE,'
			||'   SR_INSTANCE_ID,'
			||'   PROJECT_ID,'
			||'   TASK_ID,'
			||'   SALES_ORDER_LINE_ID,'
			||'   DISPOSITION_ID,'
			||'   CUSTOMER_ID,'
			||'   CUSTOMER_SITE_ID,'
			||'   SHIP_TO_SITE_ID,'
			||'   PLANNING_GROUP,'
			||'   REFRESH_NUMBER,'
			||'   LAST_UPDATE_DATE,'
			||'   LAST_UPDATED_BY,'
			||'   CREATION_DATE,'
			||'   CREATED_BY) '
			||'VALUES'
			||'(  -1,'
			||'   MSC_DEMANDS_S.nextval,'
			||'   :DEMAND_TYPE,'
			||'   :ORIGINATION_TYPE,'
			||'   :INVENTORY_ITEM_ID,'
			||'   :ORGANIZATION_ID,'
			||'   :SCHEDULE_DESIGNATOR_ID,'
			||'   :FORECAST_SET_ID,'
			||'   :USING_ASSEMBLY_ITEM_ID,'
			||'   :USING_ASSEMBLY_DEMAND_DATE,'
			||'   :USING_REQUIREMENT_QUANTITY,'
			||'   :ASSEMBLY_DEMAND_COMP_DATE,'
			||'   :SOURCE_ORGANIZATION_ID,'
			||'   :DEMAND_CLASS,'
			||'   :ORDER_PRIORITY,'
			||'   :FORECAST_MAD,'
			||'   :CONFIDENCE_PERCENTAGE,'
			||'   :PROBABiLITY,'
			||'   :BUCKET_TYPE,'
			||'   :SR_INSTANCE_ID,'
			||'   :PROJECT_ID,'
			||'   :TASK_ID,'
			||'   :SALES_ORDER_LINE_ID,'
			||'   :SALES_ORDER_LINE_ID,'
			||'   :CUSTOMER_ID,'
			||'   :CUSTOMER_SITE_ID,'
			||'   :SHIP_TO_SITE_ID,'
			||'   :PLANNING_GROUP,'
			||'   :v_last_collection_id,'
			||'   :v_current_date,'
			||'   :v_current_user,'
			||'   :v_current_date,'
			||'   :v_current_user)';

			c_count:=0;


			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
			FOR c_rec in c1_d LOOP

			DELETE MSC_DEMANDS
			WHERE PLAN_ID=  -1
			AND SR_INSTANCE_ID=       c_rec.SR_INSTANCE_ID
			AND ORIGINATION_TYPE=     c_rec.ORIGINATION_TYPE
			AND SALES_ORDER_LINE_ID = c_rec.SALES_ORDER_LINE_ID
			AND INVENTORY_ITEM_ID =   c_rec.INVENTORY_ITEM_ID
			AND ORGANIZATION_ID   =   c_rec.ORGANIZATION_ID;

			END LOOP;
			END IF;

			FOR c_rec IN c1 LOOP

			BEGIN

			IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN
			/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
			UPDATE MSC_DEMANDS
			SET
			  INVENTORY_ITEM_ID=  c_rec.INVENTORY_ITEM_ID,
			  ORGANIZATION_ID=  c_rec.ORGANIZATION_ID,
			  OLD_USING_REQUIREMENT_QUANTITY=  USING_REQUIREMENT_QUANTITY,
			  OLD_USING_ASSEMBLY_DEMAND_DATE=  USING_ASSEMBLY_DEMAND_DATE,
			  OLD_ASSEMBLY_DEMAND_COMP_DATE=  ASSEMBLY_DEMAND_COMP_DATE,
			  USING_ASSEMBLY_ITEM_ID=  c_rec.USING_ASSEMBLY_ITEM_ID,
			  USING_ASSEMBLY_DEMAND_DATE=  c_rec.USING_ASSEMBLY_DEMAND_DATE,
			  USING_REQUIREMENT_QUANTITY=  c_rec.USING_REQUIREMENT_QUANTITY,
			  ASSEMBLY_DEMAND_COMP_DATE=  c_rec.ASSEMBLY_DEMAND_COMP_DATE,
			  SOURCE_ORGANIZATION_ID=  c_rec.SOURCE_ORGANIZATION_ID,
			  PROBABiLITY = c_rec.probability,
			  DEMAND_CLASS=  c_rec.DEMAND_CLASS,
			  ORDER_PRIORITY = c_rec.ORDER_PRIORITY,
			  PROJECT_ID=  c_rec.PROJECT_ID,
			  TASK_ID=  c_rec.TASK_ID,
			  SALES_ORDER_LINE_ID= c_rec.SALES_ORDER_LINE_ID,
			  DISPOSITION_ID= c_rec.SALES_ORDER_LINE_ID,
			  CUSTOMER_ID= c_rec.CUSTOMER_ID,
			  CUSTOMER_SITE_ID = c_rec.CUSTOMER_SITE_ID,
			  SHIP_TO_SITE_ID = c_rec.SHIP_TO_SITE_ID,
			  PLANNING_GROUP= c_rec.PLANNING_GROUP,
			  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			  LAST_UPDATE_DATE=  MSC_CL_COLLECTION.v_current_date,
			  LAST_UPDATED_BY=  MSC_CL_COLLECTION.v_current_user
			WHERE PLAN_ID=  -1
			AND SR_INSTANCE_ID=  c_rec.SR_INSTANCE_ID
			AND ORIGINATION_TYPE=  c_rec.ORIGINATION_TYPE
			AND SALES_ORDER_LINE_ID = c_rec.SALES_ORDER_LINE_ID
			AND ORGANIZATION_ID = c_rec.ORGANIZATION_ID;
			END IF;

			IF SQL%NOTFOUND THEN

			EXECUTE IMMEDIATE lv_sql_stmt
			USING
			c_rec.DEMAND_TYPE,
			c_rec.ORIGINATION_TYPE,
			c_rec.INVENTORY_ITEM_ID,
			c_rec.ORGANIZATION_ID,
			c_rec.SCHEDULE_DESIGNATOR_ID,
			c_rec.FORECAST_SET_ID,
			c_rec.USING_ASSEMBLY_ITEM_ID,
			c_rec.USING_ASSEMBLY_DEMAND_DATE,
			c_rec.USING_REQUIREMENT_QUANTITY,
			c_rec.ASSEMBLY_DEMAND_COMP_DATE,
			c_rec.SOURCE_ORGANIZATION_ID,
			c_rec.DEMAND_CLASS,
			c_rec.ORDER_PRIORITY,
			c_rec.FORECAST_MAD,
			c_rec.CONFIDENCE_PERCENTAGE,
			c_Rec.PROBABiLITY,
			c_rec.BUCKET_TYPE,
			c_rec.SR_INSTANCE_ID,
			c_rec.PROJECT_ID,
			c_rec.TASK_ID,
			c_rec.SALES_ORDER_LINE_ID,
			c_rec.SALES_ORDER_LINE_ID,
			c_rec.CUSTOMER_ID,
			c_rec.CUSTOMER_SITE_ID,
			c_rec.SHIP_TO_SITE_ID,
			c_rec.PLANNING_GROUP,
			MSC_CL_COLLECTION.v_last_collection_id,
			MSC_CL_COLLECTION.v_current_date,
			MSC_CL_COLLECTION.v_current_user,
			MSC_CL_COLLECTION.v_current_date,
			MSC_CL_COLLECTION.v_current_user;

			END IF;  --  sql%notfound

			  c_count:= c_count+1;

			  IF c_count>MSC_CL_COLLECTION.PBS THEN
			     IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
			     c_count:= 0;
			  END IF;

			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECASTS');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_ITEM_FORECASTS');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
			      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);


			/*
			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'FORECAST_DESIGNATOR');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.forecast_designator);
			*/

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'SCHEDULE_DESIGNATOR_ID');
			      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.schedule_designator_id);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);


			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
			      FND_MESSAGE.SET_TOKEN('VALUE',
			                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
			                                                   MSC_CL_COLLECTION.v_instance_id));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_TYPE');
			      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.DEMAND_TYPE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORIGINATION_TYPE');
			      FND_MESSAGE.SET_TOKEN('VALUE',
			               MSC_GET_NAME.LOOKUP_MEANING('MRP_DEMAND_ORIGINATION',
			                                           c_rec.ORIGINATION_TYPE));
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			    END IF;

			END;

			END LOOP;
			END IF;
			END LOAD_ITEM_FORECASTS;

			PROCEDURE LOAD_FORECASTS IS

					v_forecast_set_id number;

					CURSOR C1_d is
					SELECT
					MSD.DESIGNATOR,
					MSD.ORGANIZATION_ID,
					MSD.SR_INSTANCE_ID
					from MSC_ST_DESIGNATORS MSD
					WHERE msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
					AND msd.DELETED_FLAG= MSC_UTIL.SYS_YES;

					CURSOR c1 IS
					   SELECT
					   msd.DESIGNATOR,
					   msd.FORECAST_SET,
					   msd.PROBABiLITY,
					   msd.ORGANIZATION_ID,
					   msd.MPS_RELIEF,
					   msd.INVENTORY_ATP_FLAG,
					   msd.DESCRIPTION,
					   msd.DISABLE_DATE,
					   msd.DEMAND_CLASS,
					   msd.CONSUME_FORECAST,
					   msd.UPDATE_TYPE,
					   msd.FORWARD_UPDATE_TIME_FENCE FOREWARD_UPDATE_TIME_FENCE,
					   msd.BACKWARD_UPDATE_TIME_FENCE,
					   msd.OUTLIER_UPDATE_PERCENTAGE,
					   mtil.tp_id customer_id,       --msd.CUSTOMER_ID,
					   mtsila.tp_site_id ship_id,--msd.SHIP_ID,
					   mtsilb.tp_site_id bill_id,--msd.BILL_ID,
					   msd.BUCKET_TYPE,
					   msd.DELETED_FLAG,
					   msd.REFRESH_ID,
					   msd.SR_INSTANCE_ID,
					   msd.DESIGNATOR_TYPE,
					   null forecast_Set_id
					FROM MSC_ST_DESIGNATORS msd,
					     MSC_TP_ID_LID mtil,
					     MSC_TP_SITE_ID_LID mtsila,
					     MSC_TP_SITE_ID_LID mtsilb
					WHERE msd.SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
					and   msd.designator_type = 6
					and   mtil.sr_instance_id(+)  = MSC_CL_COLLECTION.v_instance_id
					and   mtil.sr_tp_id(+) = msd.customer_id
					and   mtil.partner_type(+) = 2
					and   mtsila.sr_instance_id(+)  = MSC_CL_COLLECTION.v_instance_id
					and   mtsila.sr_tp_site_id(+) = msd.ship_id
					and   mtsila.partner_type(+) = 2
					and   mtsilb.sr_instance_id(+)  = MSC_CL_COLLECTION.v_instance_id
					and   mtsilb.sr_tp_site_id(+) = msd.bill_id
					and   mtsilb.partner_type(+) = 2
					order by nvl(msd.forecast_set,'0');

				   c_count NUMBER:= 0;

				   BEGIN


				   FOR c_rec in c1_d loop

				    UPDATE MSC_DESIGNATORS
				    SET DISABLE_DATE= TRUNC(MSC_CL_COLLECTION.v_current_date),
				    REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
				    LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
				    LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
				    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
				     AND   ORGANIZATION_ID= c_rec.ORGANIZATION_ID
				     and designator = c_rec.designator
				     and designator_type = 6
				     AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

				   END LOOP;

				   COMMIT;

				c_count:= 0;

				FOR c_rec IN c1 LOOP

				BEGIN

				/* Bug 3036943 - if the forecast and set are deleted and the same forecast is
				   created under another set, we want to assign the forecast to the new set
				*/

				If c_rec.forecast_set is not null then

                Begin
                        Select distinct designator_id
                        into v_forecast_set_id
                        from msc_designators
                        where designator = c_rec.forecast_Set
                        and   organization_id = c_rec.organization_id
                        and   sr_instance_id  = MSC_CL_COLLECTION.v_instance_id;
                   Exception
                     when no_data_found
                     then
                     Select MSC_DESIGNATORS_S.Nextval
                     into v_forecast_set_id
                     from dual;
                 End;
			Elsif c_rec.forecast_set is null then

			  v_forecast_set_id := null;
			End if;


			UPDATE MSC_DESIGNATORS
			SET
			 SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id,
			 forecast_set_id = v_forecast_set_id,
			 MPS_RELIEF= c_rec.MPS_RELIEF,
			 PROBABiLITY =c_rec.PROBABiLITY,
			 INVENTORY_ATP_FLAG= c_rec.INVENTORY_ATP_FLAG,
			 DESCRIPTION= c_rec.DESCRIPTION,
			 DISABLE_DATE= c_rec.DISABLE_DATE,
			 DEMAND_CLASS= c_rec.DEMAND_CLASS,
			 CONSUME_FORECAST = c_rec.CONSUME_FORECAST,
			 UPDATE_TYPE = c_rec. UPDATE_TYPE,
			 FORWARD_UPDATE_TIME_FENCE = c_rec.FOREWARD_UPDATE_TIME_FENCE,
			 BACKWARD_UPDATE_TIME_FENCE = c_rec.BACKWARD_UPDATE_TIME_FENCE,
			 OUTLIER_UPDATE_PERCENTAGE  = c_rec.OUTLIER_UPDATE_PERCENTAGE,
			 CUSTOMER_ID                = c_rec.CUSTOMER_ID,
			 SHIP_ID                    = c_rec.SHIP_ID,
			 BILL_ID                    = c_rec.BILL_ID,
			 BUCKET_TYPE                = c_rec.BUCKET_TYPE,
			 DESIGNATOR_TYPE            = c_rec.DESIGNATOR_TYPE,
			 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
			 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
			 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
			WHERE DESIGNATOR= c_rec.DESIGNATOR
			AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
			AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
			AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

			IF SQL%NOTFOUND THEN



			INSERT INTO MSC_DESIGNATORS
			( DESIGNATOR_ID,
			  FORECAST_SET_ID,
			  DESIGNATOR,
			  DESIGNATOR_TYPE,
			  ORGANIZATION_ID,
			  MPS_RELIEF,
			  INVENTORY_ATP_FLAG,
			  DESCRIPTION,
			  DISABLE_DATE,
			  DEMAND_CLASS,
			  CONSUME_FORECAST ,
			  UPDATE_TYPE ,
			  FORWARD_UPDATE_TIME_FENCE ,
			  BACKWARD_UPDATE_TIME_FENCE,
			  OUTLIER_UPDATE_PERCENTAGE ,
			  PROBABiLITY,
			  CUSTOMER_ID               ,
			  SHIP_ID                   ,
			  BILL_ID                   ,
			  BUCKET_TYPE               ,
			  COLLECTED_FLAG,
			  SR_INSTANCE_ID,
			  REFRESH_NUMBER,
			  LAST_UPDATE_DATE,
			  LAST_UPDATED_BY,
			  CREATION_DATE,
			  CREATED_BY)
			VALUES
			( MSC_DESIGNATORS_S.NEXTVAL,
			  v_forecast_Set_id,
			  c_rec.DESIGNATOR,
			  6,
			  c_rec.ORGANIZATION_ID,
			  c_rec.MPS_RELIEF,
			  c_rec.INVENTORY_ATP_FLAG,
			  c_rec.DESCRIPTION,
			  c_rec.DISABLE_DATE,
			  c_rec.DEMAND_CLASS,
			  c_rec.CONSUME_FORECAST,
			  c_rec.UPDATE_TYPE,
			  c_rec.FOREWARD_UPDATE_TIME_FENCE,
			  c_rec.BACKWARD_UPDATE_TIME_FENCE,
			  c_rec.OUTLIER_UPDATE_PERCENTAGE,
			  c_rec.PROBABiLITY,
			  c_rec.CUSTOMER_ID,
			  c_rec.SHIP_ID,
			  c_rec.BILL_ID,
			  c_rec.BUCKET_TYPE,
			  MSC_UTIL.SYS_YES,
			  c_rec.SR_INSTANCE_ID,
			  MSC_CL_COLLECTION.v_last_collection_id,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user,
			  MSC_CL_COLLECTION.v_current_date,
			  MSC_CL_COLLECTION.v_current_user );


			END IF;

			  c_count:= c_count+1;

			  IF c_count> MSC_CL_COLLECTION.PBS THEN
			     COMMIT;
			     c_count:= 0;
			  END IF;

			EXCEPTION

			   WHEN OTHERS THEN

			    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_FORECASTS');
			      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DESIGNATORS');
			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;

			    ELSE
			      IF SQLCODE = -00001 THEN
			          MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
			          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      	  FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      	  FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_FORECASTS');
			      	  FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DESIGNATORS');
			      	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			          FND_MESSAGE.SET_NAME('MSC', 'MSC_DESIGNATOR_UNIQUE');
			       	  FND_MESSAGE.SET_TOKEN('DESIGNATOR', c_rec.DESIGNATOR);
			          FND_MESSAGE.SET_TOKEN('ORGANIZATION', MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,MSC_CL_COLLECTION.v_instance_id));
			          MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);



			      ELSE

			      	MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

			      	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
			      	FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
			      	FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_FORECASTS');
			      	FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DESIGNATORS');
			      	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      	FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      	FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
			      	FND_MESSAGE.SET_TOKEN('VALUE',
			                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
			                                                   MSC_CL_COLLECTION.v_instance_id));
			      	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      	FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
			      	FND_MESSAGE.SET_TOKEN('COLUMN', 'DESIGNATOR');
			      	FND_MESSAGE.SET_TOKEN('VALUE', c_rec.DESIGNATOR);
			      	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

			      	MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      END IF;
			    END IF;
			END;

			END LOOP;

			COMMIT;

		End load_forecasts;

-- ===================== LOAD MDS_DEMAND ========================
-- = this procedure is called by LOAD_SUPPLY  Mar 05 2000, TWUU =
-- ==============================================================
   PROCEDURE LOAD_DEMAND IS

/* 2201791 - select substr(order_number,1,62) since order_number is
   defined as varchar(62) in msc_demands table */

   CURSOR c1 IS
		SELECT
		   t1.INVENTORY_ITEM_ID,
		   msd.ORGANIZATION_ID,
		   t2.INVENTORY_ITEM_ID USING_ASSEMBLY_ITEM_ID,
		   msd.USING_ASSEMBLY_DEMAND_DATE,
		   msd.USING_REQUIREMENT_QUANTITY,
		   msd.ASSEMBLY_DEMAND_COMP_DATE,
		   msd.DEMAND_TYPE,
		   msd.DAILY_DEMAND_RATE,
		   msd.ORIGINATION_TYPE,
		   msd.SOURCE_ORGANIZATION_ID,
		   msd.DISPOSITION_ID,
		   msd.RESERVATION_ID,
		   msd.OPERATION_SEQ_NUM,
		   msd.DEMAND_CLASS,
		   msd.PROMISE_DATE,
		   msd.LINK_TO_LINE_ID,
		   msd.REPETITIVE_SCHEDULE_ID,
		   msd.SR_INSTANCE_ID,
		   msd.PROJECT_ID,
		   msd.TASK_ID,
		   msd.PLANNING_GROUP,
		   msd.END_ITEM_UNIT_NUMBER,
		   REPLACE(REPLACE(substr(msd.ORDER_NUMBER,1,62),MSC_CL_COLLECTION.v_chr10),MSC_CL_COLLECTION.v_chr13) ORDER_NUMBER,
		   md.DESIGNATOR_ID SCHEDULE_DESIGNATOR_ID,
		   msd.SELLING_PRICE,
		   msd.DMD_LATENESS_COST,
		   msd.REQUEST_DATE,
		   msd.ORDER_PRIORITY,
		   msd.SALES_ORDER_LINE_ID,
		   msd.DEMAND_SCHEDULE_NAME,
		   msd.DELETED_FLAG,
		   c1.tp_id customer_id,
		   mtsil.tp_site_id CUSTOMER_SITE_ID,
		   mtsil.tp_site_id SHIP_TO_SITE_ID,
		   nvl(msd.ORIGINAL_SYSTEM_REFERENCE,'-1') ORIGINAL_SYSTEM_REFERENCE,
		   nvl(msd.ORIGINAL_SYSTEM_LINE_REFERENCE,'-1') ORIGINAL_SYSTEM_LINE_REFERENCE,
		   msd.demand_source_type,
		   msd.ORDER_DATE_TYPE_CODE,
		   msd.SCHEDULE_ARRIVAL_DATE,
		   msd.LATEST_ACCEPTABLE_DATE,
		   msd.SHIPPING_METHOD_CODE,
		   mtsil.location_id ship_to_location_id
		FROM
		     msc_tp_id_lid c1,
		     MSC_ITEM_ID_LID t1,
		     MSC_ITEM_ID_LID t2,
		     MSC_DESIGNATORS md,
		     MSC_TP_SITE_ID_LID mtsil,
		     MSC_ST_DEMANDS msd
		WHERE t1.SR_INVENTORY_ITEM_ID=        msd.inventory_item_id
		  AND t1.sr_instance_id= msd.sr_instance_id
		  AND t2.SR_INVENTORY_ITEM_ID= msd.using_assembly_item_id
		  AND t2.sr_instance_id= msd.sr_instance_id
		  AND msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND msd.ORIGINATION_TYPE in ( 6,7,8,15,24,42)
		  AND md.SR_INSTANCE_ID(+)= msd.SR_INSTANCE_ID
		  AND md.DESIGNATOR(+)= msd.DEMAND_SCHEDULE_NAME
		  AND md.Organization_ID(+)= msd.Organization_ID
		  AND md.Designator_Type(+)= 1
		  AND c1.partner_type(+)  = 2
		  and c1.sr_tp_id(+) = msd.customer_id
		  and c1.sr_instance_id(+) = msd.sr_instance_id
		  and mtsil.sr_instance_id(+)  = MSC_CL_COLLECTION.v_instance_id
		  and mtsil.sr_tp_site_id(+) = msd.SHIP_TO_SITE_ID
		  and mtsil.partner_type(+) = 2
		ORDER BY
		      msd.source_disposition_id, msd.DELETED_FLAG;

		   c_count     NUMBER:=0;
		   lv_tbl      VARCHAR2(30);
		   lv_sql_stmt VARCHAR2(5000);
		   lv_supply_tbl  VARCHAR2(30);
		   lv_supply_stmt VARCHAR2(5000);
		    lb_FetchComplete  Boolean;
		   ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);


		   TYPE CharTblTyp IS TABLE OF VARCHAR2(70);
		  TYPE NumTblTyp  IS TABLE OF NUMBER;
		  TYPE dateTblTyp IS TABLE OF DATE;

		lb_INVENTORY_ITEM_ID                      NumTblTyp;
		lb_ORGANIZATION_ID                        NumTblTyp;
		lb_USING_ASSEMBLY_ITEM_ID                 NumTblTyp;
		lb_USING_ASSEMBLY_DEMAND_DATE             dateTblTyp ;
		lb_USING_REQUIREMENT_QUANTITY             NumTblTyp;
		lb_ASSEMBLY_DEMAND_COMP_DATE              dateTblTyp;
		lb_DEMAND_TYPE                            NumTblTyp;
		lb_DAILY_DEMAND_RATE                      NumTblTyp;
		lb_ORIGINATION_TYPE                       NumTblTyp;
		lb_SOURCE_ORGANIZATION_ID                 NumTblTyp;
		lb_DISPOSITION_ID                         NumTblTyp;
		lb_RESERVATION_ID                         NumTblTyp;
		lb_OPERATION_SEQ_NUM                      NumTblTyp;
		lb_DEMAND_CLASS                           CharTblTyp;
		lb_PROMISE_DATE                           dateTblTyp;
		lb_REPETITIVE_SCHEDULE_ID                 NumTblTyp;
		lb_SR_INSTANCE_ID                         NumTblTyp;
		lb_PROJECT_ID                             NumTblTyp;
		lb_TASK_ID                                NumTblTyp;
		lb_PLANNING_GROUP                         CharTblTyp;
		lb_END_ITEM_UNIT_NUMBER                   CharTblTyp;
		lb_ORDER_NUMBER                           CharTblTyp;
		lb_SCHEDULE_DESIGNATOR_ID                 NumTblTyp;
		lb_SELLING_PRICE                          NumTblTyp;
		lb_DMD_LATENESS_COST                      NumTblTyp;
		lb_REQUEST_DATE                           dateTblTyp;
		lb_ORDER_PRIORITY                         NumTblTyp;
		lb_SALES_ORDER_LINE_ID                    NumTblTyp;
		lb_DEMAND_SCHEDULE_NAME                   CharTblTyp;
		lb_DELETED_FLAG                           NumTblTyp;
		lb_customer_id                            NumTblTyp;
		lb_CUSTOMER_SITE_ID                       NumTblTyp;
		lb_SHIP_TO_SITE_ID                        NumTblTyp;
		lb_OR_SYSTEM_REFERENCE              CharTblTyp;
		lb_OR_SYSTEM_LINE_REFERENCE         CharTblTyp;
		lb_demand_source_type                     NumTblTyp;
		lb_ORDER_DATE_TYPE_CODE			CharTblTyp;
		lb_SCHEDULE_ARRIVAL_DATE		dateTblTyp;
		lb_LATEST_ACCEPTABLE_DATE		dateTblTyp;
		lb_SHIPPING_METHOD_CODE			CharTblTyp;
		lb_ship_to_location_id			NumTblTyp;
		lb_LINK_TO_LINE_ID			NumTblTyp;
		   BEGIN

		IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
		   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
		   lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
		ELSE
		   lv_tbl:= 'MSC_DEMANDS';
		   lv_supply_tbl:= 'MSC_SUPPLIES';
		END IF;

		   /** PREPLACE CHANGE START **/

		   IF (MSC_CL_COLLECTION.v_is_partial_refresh            AND
		       (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_NO) AND
		       (MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_NO) AND
		       (MSC_CL_COLLECTION.v_coll_prec.po_flag = MSC_UTIL.SYS_NO)  AND
		       (MSC_CL_COLLECTION.v_coll_prec.oh_flag = MSC_UTIL.SYS_NO)  AND
		       (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_NO) ) THEN

		         lv_supply_tbl := 'MSC_SUPPLIES';

		   ELSIF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN

		         lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;

		   END IF;

		   /**  PREPLACE CHANGE END  **/

		   /* In cont. collections if any of the Supply is targeted  */
		   IF (MSC_CL_COLLECTION.v_is_cont_refresh)  THEN
			  IF (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) OR
		             (MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) OR
		             (MSC_CL_COLLECTION.v_coll_prec.po_flag  = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) OR
		             (MSC_CL_COLLECTION.v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) OR
			     (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT) THEN

		                   lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
		          ELSE
		                   lv_supply_tbl := 'MSC_SUPPLIES';
		          END IF;
		   END IF;

		lv_sql_stmt:=
		'INSERT INTO '||lv_tbl
		||'(  PLAN_ID,'
		||'   DEMAND_ID,'
		||'   INVENTORY_ITEM_ID,'
		||'   ORGANIZATION_ID,'
		||'   SCHEDULE_DESIGNATOR_ID,'
		||'   USING_ASSEMBLY_ITEM_ID,'
		||'   USING_ASSEMBLY_DEMAND_DATE,'
		||'   USING_REQUIREMENT_QUANTITY,'
		||'   ASSEMBLY_DEMAND_COMP_DATE,'
		||'   DEMAND_TYPE,'
		||'   DAILY_DEMAND_RATE,'
		||'   ORIGINATION_TYPE,'
		||'   SOURCE_ORGANIZATION_ID,'
		||'   DISPOSITION_ID,'
		||'   RESERVATION_ID,'
		||'   OP_SEQ_NUM,'
		||'   DEMAND_CLASS,'
		||'   PROMISE_DATE,'
		||'   LINK_TO_LINE_ID ,'
		||'   SR_INSTANCE_ID,'
		||'   PROJECT_ID,'
		||'   TASK_ID,'
		||'   PLANNING_GROUP,'
		||'   UNIT_NUMBER,'
		||'   ORDER_NUMBER,'
		||'   REPETITIVE_SCHEDULE_ID,'
		||'   SELLING_PRICE,'
		||'   DMD_LATENESS_COST,'
		||'   REQUEST_DATE,'
		||'   ORDER_PRIORITY,'
		||'   SALES_ORDER_LINE_ID,'
		||'   SUPPLY_ID,'
		||'   SOURCE_ORG_INSTANCE_ID,'
		||'   ORIGINAL_SYSTEM_REFERENCE,'
		||'   ORIGINAL_SYSTEM_LINE_REFERENCE,'
		||'   DEMAND_SOURCE_TYPE,'
		||'   CUSTOMER_ID,'
		||'   CUSTOMER_SITE_ID,'
		||'   SHIP_TO_SITE_ID,'
		||'   REFRESH_NUMBER,'
		||'   LAST_UPDATE_DATE,'
		||'   LAST_UPDATED_BY,'
		||'   CREATION_DATE,'
		||'   CREATED_BY,'
		||'   ORDER_DATE_TYPE_CODE,'
		||'   SCHEDULE_ARRIVAL_DATE,'
		||'   LATEST_ACCEPTABLE_DATE,'
		||'   SHIP_TO_LOCATION_ID,'
		||'   SHIPPING_METHOD_CODE)'
		||'VALUES'
		||'(  -1,'
		||'   MSC_DEMANDS_S.nextval,'
		||'   :INVENTORY_ITEM_ID,'
		||'   :ORGANIZATION_ID,'
		||'   :SCHEDULE_DESIGNATOR_ID,'
		||'   :USING_ASSEMBLY_ITEM_ID,'
		||'   :USING_ASSEMBLY_DEMAND_DATE,'
		||'   :USING_REQUIREMENT_QUANTITY,'
		||'   :ASSEMBLY_DEMAND_COMP_DATE,'
		||'   :DEMAND_TYPE,'
		||'   :DAILY_DEMAND_RATE,'
		||'   :ORIGINATION_TYPE,'
		||'   :v_source_organization_id,'
		||'   :DISPOSITION_ID,'
		||'   :RESERVATION_ID,'
		||'   :OPERATION_SEQ_NUM,'
		||'   :DEMAND_CLASS,'
		||'   :PROMISE_DATE,'
		||'   :LINK_TO_LINE_ID ,'
		||'   :SR_INSTANCE_ID,'
		||'   :PROJECT_ID,'
		||'   :TASK_ID,'
		||'   :PLANNING_GROUP,'
		||'   :END_ITEM_UNIT_NUMBER, '
		||'   :ORDER_NUMBER,'
		||'   :REPETITIVE_SCHEDULE_ID,'
		||'   :SELLING_PRICE,'
		||'   :DMD_LATENESS_COST,'
		||'   :REQUEST_DATE,'
		||'   :ORDER_PRIORITY,'
		||'   :SALES_ORDER_LINE_ID,'
		||'   :v_supply_id,'
		||'   :v_source_sr_instance_id,'
		||'   :ORIGINAL_SYSTEM_REFERENCE,'
		||'   :ORIGINAL_SYSTEM_LINE_REFERENCE,'
		||'   :DEMAND_SOURCE_TYPE,'
		||'   :CUSTOMER_ID,'
		||'   :CUSTOMER_SITE_ID,'
		||'   :SHIP_TO_SITE_ID,'
		||'   :v_last_collection_id,'
		||'   :v_current_date,'
		||'   :v_current_user,'
		||'   :v_current_date,'
		||'   :v_current_user,'
		||'   :ORDER_DATE_TYPE_CODE,'
		||'   :SCHEDULE_ARRIVAL_DATE,'
		||'   :LATEST_ACCEPTABLE_DATE,'
		||'   :SHIP_TO_LOCATION_ID,'
		||'   :SHIPPING_METHOD_CODE)';

		c_count:=0;

		OPEN  c1;

		IF (c1%ISOPEN) THEN
		LOOP

		--
		-- Retrieve the next set of rows if we are currently not in the
		-- middle of processing a fetched set or rows.
		--
		IF (lb_FetchComplete) THEN
		  EXIT;
		END IF;

		-- Fetch the next set of rows
		FETCH c1 BULK COLLECT INTO   lb_INVENTORY_ITEM_ID,
		                             lb_ORGANIZATION_ID  ,
		                             lb_USING_ASSEMBLY_ITEM_ID,
		                             lb_USING_ASSEMBLY_DEMAND_DATE,
		                             lb_USING_REQUIREMENT_QUANTITY,
		                             lb_ASSEMBLY_DEMAND_COMP_DATE,
		                             lb_DEMAND_TYPE      ,
		                             lb_DAILY_DEMAND_RATE,
		                             lb_ORIGINATION_TYPE ,
		                             lb_SOURCE_ORGANIZATION_ID,
		                             lb_DISPOSITION_ID   ,
		                             lb_RESERVATION_ID   ,
		                             lb_OPERATION_SEQ_NUM,
		                             lb_DEMAND_CLASS,
		                             lb_PROMISE_DATE,
					     lb_LINK_TO_LINE_ID,
		                             lb_REPETITIVE_SCHEDULE_ID,
		                             lb_SR_INSTANCE_ID,
		                             lb_PROJECT_ID,
		                             lb_TASK_ID,
		                             lb_PLANNING_GROUP,
		                             lb_END_ITEM_UNIT_NUMBER,
		                             lb_ORDER_NUMBER,
		                             lb_SCHEDULE_DESIGNATOR_ID,
		                             lb_SELLING_PRICE,
		                             lb_DMD_LATENESS_COST,
		                             lb_REQUEST_DATE,
		                             lb_ORDER_PRIORITY,
		                             lb_SALES_ORDER_LINE_ID,
		                             lb_DEMAND_SCHEDULE_NAME,
		                             lb_DELETED_FLAG,
		                             lb_customer_id,
		                             lb_CUSTOMER_SITE_ID ,
		                             lb_SHIP_TO_SITE_ID,
		                             lb_OR_SYSTEM_REFERENCE,
		                             lb_OR_SYSTEM_LINE_REFERENCE,
		                             lb_demand_source_type,
					     lb_ORDER_DATE_TYPE_CODE,
					     lb_SCHEDULE_ARRIVAL_DATE,
					     lb_LATEST_ACCEPTABLE_DATE,
					     lb_SHIPPING_METHOD_CODE,
					     lb_ship_to_location_id
		LIMIT ln_rows_to_fetch;

		-- Since we are only fetching records if either (1) this is the first
		-- fetch or (2) the previous fetch did not retrieve all of the
		-- records, then at least one row should always be fetched.  But
		-- checking just to make sure.
		EXIT WHEN lb_DISPOSITION_ID.count = 0;

		-- Check if all of the rows have been fetched.  If so, indicate that
		-- the fetch is complete so that another fetch is not made.
		-- Additional check is introduced for the following reasons
		-- In 9i, the table of records gets modified but in 8.1.6 the table of records is
		-- unchanged after the fetch(bug#2995144)
		IF (c1%NOTFOUND) THEN
		  lb_FetchComplete := TRUE;
		END IF;

		FOR j IN 1..lb_DISPOSITION_ID.COUNT LOOP

		BEGIN
		    --MSC_CL_COLLECTION.v_source_organization_id := c_rec.source_organization_id;

		    MSC_CL_COLLECTION.v_supply_id := Null;
		    MSC_CL_COLLECTION.v_source_organization_id := Null;
		    MSC_CL_COLLECTION.v_source_sr_instance_id := Null;
		    IF (lb_demand_source_type(j)  = 8
		        AND lb_OR_SYSTEM_REFERENCE(j) <> '-1'
		        AND lb_OR_SYSTEM_LINE_REFERENCE(j)  <> '-1' ) THEN -- Internal Sales Orders


		       IF (MSC_CL_COLLECTION.v_apps_ver =  MSC_UTIL.G_APPS110 OR MSC_CL_COLLECTION.v_is_legacy_refresh) THEN -- Version
		          BEGIN
		             MSC_CL_COLLECTION.v_supply_id := Null;
		             MSC_CL_COLLECTION.v_source_organization_id := Null;
		             MSC_CL_COLLECTION.v_source_sr_instance_id := Null;
		             lv_supply_stmt :=
		               'SELECT TRANSACTION_ID ,ORGANIZATION_ID, SOURCE_SR_INSTANCE_ID '
		               ||' FROM '||  lv_supply_tbl
		               ||' WHERE  SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
		               ||' AND    PLAN_ID = -1'
		               ||' AND    order_number = :ORIGINAL_SYSTEM_REFERENCE'
		               ||' AND    to_char(purch_line_num) = :ORIGINAL_SYSTEM_LINE_REFERENCE '
		               ||' AND    order_type =  2 '
                       ||' AND    new_order_quantity > 0' -- bug 8424335
		               ||' AND    source_organization_id is not null  ';


		               EXECUTE IMMEDIATE lv_supply_stmt
		                     INTO MSC_CL_COLLECTION.v_supply_id, MSC_CL_COLLECTION.v_source_organization_id, MSC_CL_COLLECTION.v_source_sr_instance_id
		                        USING lb_OR_SYSTEM_REFERENCE(j),lb_OR_SYSTEM_LINE_REFERENCE(j);
		               EXCEPTION
		                   WHEN NO_DATA_FOUND THEN NULL;
		                   WHEN OTHERS THEN NULL;

		          END ;
		       ELSIF MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS115 THEN --Version

		          BEGIN --R11i2
		             MSC_CL_COLLECTION.v_supply_id := Null;
		             MSC_CL_COLLECTION.v_source_organization_id := Null;
		             MSC_CL_COLLECTION.v_source_sr_instance_id := Null;
		             lv_supply_stmt :=
		               'SELECT TRANSACTION_ID ,ORGANIZATION_ID, SOURCE_SR_INSTANCE_ID '
		               ||' FROM '|| lv_supply_tbl
		               ||' WHERE  SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
		               ||' AND    PLAN_ID = -1'
		               ||' AND    disposition_id = to_number(:ORIGINAL_SYSTEM_REFERENCE) '
		               ||' AND    po_line_id = to_number(:ORIGINAL_SYSTEM_LINE_REFERENCE)      '
		               ||' AND    order_type =  2 '
                       ||' AND    new_order_quantity > 0' -- bug 8424335
		               ||' AND    source_organization_id is not null  ';

		               EXECUTE IMMEDIATE lv_supply_stmt
		               INTO   MSC_CL_COLLECTION.v_supply_id,MSC_CL_COLLECTION.v_source_organization_id, MSC_CL_COLLECTION.v_source_sr_instance_id
		                        USING lb_OR_SYSTEM_REFERENCE(j),lb_OR_SYSTEM_LINE_REFERENCE(j);

		               EXCEPTION
		                   WHEN NO_DATA_FOUND THEN NULL;
		                   WHEN OTHERS THEN NULL;
		          END ;
		        END IF; -- Version
		    END IF; -- Internal Sales Orders
		IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

		--================= mds demands ==================
		IF lb_ORIGINATION_TYPE(j) IN ( 6,7,15,24,42) THEN

		IF lb_DELETED_FLAG(j) = MSC_UTIL.SYS_YES THEN

		UPDATE MSC_DEMANDS
		   SET USING_REQUIREMENT_QUANTITY= 0,
		       DAILY_DEMAND_RATE= 0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID=  -1
		  AND DISPOSITION_ID=  lb_DISPOSITION_ID(j)
		   AND ORIGINATION_TYPE=  lb_ORIGINATION_TYPE(j)
		   AND SR_INSTANCE_ID=  lb_SR_INSTANCE_ID(j)
		   AND ORGANIZATION_ID = lb_ORGANIZATION_ID(J);

		ELSE

		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_DEMANDS
		SET
		  INVENTORY_ITEM_ID=  lb_INVENTORY_ITEM_ID(j),
		  ORGANIZATION_ID=  lb_ORGANIZATION_ID(j),
		  OLD_USING_REQUIREMENT_QUANTITY=  lb_USING_REQUIREMENT_QUANTITY(j),
		  OLD_USING_ASSEMBLY_DEMAND_DATE=  lb_USING_ASSEMBLY_DEMAND_DATE(j),
		  OLD_ASSEMBLY_DEMAND_COMP_DATE=  lb_ASSEMBLY_DEMAND_COMP_DATE(j),
		  USING_ASSEMBLY_ITEM_ID=  lb_USING_ASSEMBLY_ITEM_ID(j),
		  USING_ASSEMBLY_DEMAND_DATE=  lb_USING_ASSEMBLY_DEMAND_DATE(j),
		  USING_REQUIREMENT_QUANTITY=  lb_USING_REQUIREMENT_QUANTITY(j),
		  ASSEMBLY_DEMAND_COMP_DATE=  lb_ASSEMBLY_DEMAND_COMP_DATE(j),
		  DEMAND_TYPE= lb_DEMAND_TYPE(j),
		  DAILY_DEMAND_RATE= lb_DAILY_DEMAND_RATE(j),
		  SOURCE_ORGANIZATION_ID=  MSC_CL_COLLECTION.v_source_organization_id,
		  RESERVATION_ID=  lb_RESERVATION_ID(j),
		  OP_SEQ_NUM=  lb_OPERATION_SEQ_NUM(j),
		  DEMAND_CLASS=  lb_DEMAND_CLASS(j),
		  PROMISE_DATE = lb_PROMISE_DATE(j),
		  LINK_TO_LINE_ID = lb_LINK_TO_LINE_ID(j),
		  PROJECT_ID=  lb_PROJECT_ID(j),
		  TASK_ID=  lb_TASK_ID(j),
		  PLANNING_GROUP= lb_PLANNING_GROUP(j),
		  UNIT_NUMBER=  lb_END_ITEM_UNIT_NUMBER(j),
		  ORDER_NUMBER=  lb_ORDER_NUMBER(j),
		  SELLING_PRICE= lb_SELLING_PRICE(j),
		  DMD_LATENESS_COST= lb_DMD_LATENESS_COST(j),
		  REQUEST_DATE= lb_REQUEST_DATE(j),
		  ORDER_PRIORITY= lb_ORDER_PRIORITY(j),
		  SALES_ORDER_LINE_ID= lb_SALES_ORDER_LINE_ID(j),
		  SUPPLY_ID = MSC_CL_COLLECTION.v_supply_id,
		  SOURCE_ORG_INSTANCE_ID = MSC_CL_COLLECTION.v_source_sr_instance_id,
		   ORIGINAL_SYSTEM_REFERENCE= lb_OR_SYSTEM_REFERENCE(j),
		  ORIGINAL_SYSTEM_LINE_REFERENCE= lb_OR_SYSTEM_LINE_REFERENCE(j),
		  DEMAND_SOURCE_TYPE= lb_demand_source_type(j),
		  customer_id= lb_customer_id(j),
		  CUSTOMER_SITE_ID = lb_CUSTOMER_SITE_ID(j),
		  SHIP_TO_SITE_ID= lb_SHIP_TO_SITE_ID(j),
		  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		  LAST_UPDATE_DATE=  MSC_CL_COLLECTION.v_current_date,
		  LAST_UPDATED_BY=  MSC_CL_COLLECTION.v_current_user,
		  ORDER_DATE_TYPE_CODE=lb_ORDER_DATE_TYPE_CODE(j),
		  SCHEDULE_ARRIVAL_DATE=lb_SCHEDULE_ARRIVAL_DATE(j),
		  LATEST_ACCEPTABLE_DATE=lb_LATEST_ACCEPTABLE_DATE(j),
		  SHIP_TO_LOCATION_ID=lb_SHIP_TO_LOCATION_ID(j),
		  SHIPPING_METHOD_CODE=lb_SHIPPING_METHOD_CODE(j)
		WHERE PLAN_ID=  -1
		 AND DISPOSITION_ID=  lb_DISPOSITION_ID(j)
		  AND ORIGINATION_TYPE=  lb_ORIGINATION_TYPE(j)
		  AND SR_INSTANCE_ID=  lb_SR_INSTANCE_ID(j)
		  AND ORGANIZATION_ID = lb_ORGANIZATION_ID(J);

		END IF;  -- DELETED_FLAG

		ELSIF lb_ORIGINATION_TYPE(j)=8 THEN  /* Manual MDS */

		IF lb_DELETED_FLAG(j)= MSC_UTIL.SYS_YES THEN

		UPDATE MSC_DEMANDS
		   SET USING_REQUIREMENT_QUANTITY= 0,
		       DAILY_DEMAND_RATE= 0,
		       REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		       LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		       LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		 WHERE PLAN_ID=  -1
		   AND DISPOSITION_ID=  lb_DISPOSITION_ID(j)
		   AND ORIGINATION_TYPE IN (6,7,15,8,24)
		   AND SR_INSTANCE_ID=  lb_SR_INSTANCE_ID(j)
		   AND ORGANIZATION_ID = lb_ORGANIZATION_ID(J);

		ELSE

		/* ATP SUMMARY CHANGES Added the OLD_**** Columns */
		UPDATE MSC_DEMANDS
		SET
		  INVENTORY_ITEM_ID=  lb_INVENTORY_ITEM_ID(j),
		  ORGANIZATION_ID=  lb_ORGANIZATION_ID(j),
		  OLD_USING_REQUIREMENT_QUANTITY=  lb_USING_REQUIREMENT_QUANTITY(j),
		  OLD_USING_ASSEMBLY_DEMAND_DATE=  lb_USING_ASSEMBLY_DEMAND_DATE(j),
		  OLD_ASSEMBLY_DEMAND_COMP_DATE=  lb_ASSEMBLY_DEMAND_COMP_DATE(j),
		  USING_ASSEMBLY_ITEM_ID=  lb_USING_ASSEMBLY_ITEM_ID(j),
		  USING_ASSEMBLY_DEMAND_DATE=  lb_USING_ASSEMBLY_DEMAND_DATE(j),
		  USING_REQUIREMENT_QUANTITY=  lb_USING_REQUIREMENT_QUANTITY(j),
		  ASSEMBLY_DEMAND_COMP_DATE=  lb_ASSEMBLY_DEMAND_COMP_DATE(j),
		  DEMAND_TYPE= lb_DEMAND_TYPE(j),
		  DAILY_DEMAND_RATE= lb_DAILY_DEMAND_RATE(j),
		  SOURCE_ORGANIZATION_ID=  MSC_CL_COLLECTION.v_source_organization_id,
		 RESERVATION_ID=  lb_RESERVATION_ID(j),
		  OP_SEQ_NUM=  lb_OPERATION_SEQ_NUM(j),
		  DEMAND_CLASS=  lb_DEMAND_CLASS(j),
		  PROMISE_DATE = lb_PROMISE_DATE(j),
		  PROJECT_ID=  lb_PROJECT_ID(j),
		  TASK_ID=  lb_TASK_ID(j),
		  PLANNING_GROUP= lb_PLANNING_GROUP(j),
		  UNIT_NUMBER=  lb_END_ITEM_UNIT_NUMBER(j),
		  ORDER_NUMBER=  lb_ORDER_NUMBER(j),
		  SELLING_PRICE= lb_SELLING_PRICE(j),
		  DMD_LATENESS_COST= lb_DMD_LATENESS_COST(j),
		  REQUEST_DATE= lb_REQUEST_DATE(j),
		  ORDER_PRIORITY= lb_ORDER_PRIORITY(j),
		  SALES_ORDER_LINE_ID= lb_SALES_ORDER_LINE_ID(j),
		  SUPPLY_ID = MSC_CL_COLLECTION.v_supply_id,
		  SOURCE_ORG_INSTANCE_ID = MSC_CL_COLLECTION.v_source_sr_instance_id,
		 ORIGINAL_SYSTEM_REFERENCE= lb_OR_SYSTEM_REFERENCE(j),
		  ORIGINAL_SYSTEM_LINE_REFERENCE= lb_OR_SYSTEM_LINE_REFERENCE(j),
		  DEMAND_SOURCE_TYPE= lb_demand_source_type(j),
		  customer_id= lb_customer_id(j),
		  CUSTOMER_SITE_ID = lb_CUSTOMER_SITE_ID(j),
		  SHIP_TO_SITE_ID= lb_SHIP_TO_SITE_ID(j),
		  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		  LAST_UPDATE_DATE=  MSC_CL_COLLECTION.v_current_date,
		  LAST_UPDATED_BY=  MSC_CL_COLLECTION.v_current_user,
		  ORDER_DATE_TYPE_CODE=lb_ORDER_DATE_TYPE_CODE(j),
		  SCHEDULE_ARRIVAL_DATE=lb_SCHEDULE_ARRIVAL_DATE(j),
		  LATEST_ACCEPTABLE_DATE=lb_LATEST_ACCEPTABLE_DATE(j),
		  SHIP_TO_LOCATION_ID=lb_SHIP_TO_LOCATION_ID(j),
		  SHIPPING_METHOD_CODE=lb_SHIPPING_METHOD_CODE(j)
		WHERE PLAN_ID=  -1
		  AND DISPOSITION_ID=  lb_DISPOSITION_ID(j)
		  AND ORIGINATION_TYPE IN (6,7,15,8,24)
		  AND SR_INSTANCE_ID=  lb_SR_INSTANCE_ID(j)
		  AND ORGANIZATION_ID = lb_ORGANIZATION_ID(J);

		END IF;  -- DELETED_FLAG

		END IF;  -- ORIGINATION_TYPE

		END IF;  -- refresh mode

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR

		   ( lb_DELETED_FLAG(j)<> MSC_UTIL.SYS_YES AND SQL%NOTFOUND) THEN

		EXECUTE IMMEDIATE lv_sql_stmt
		USING
		   lb_INVENTORY_ITEM_ID(j),
		   lb_ORGANIZATION_ID(j),
		   lb_SCHEDULE_DESIGNATOR_ID(j),
		   lb_USING_ASSEMBLY_ITEM_ID(j),
		   lb_USING_ASSEMBLY_DEMAND_DATE(j),
		   lb_USING_REQUIREMENT_QUANTITY(j),
		   lb_ASSEMBLY_DEMAND_COMP_DATE(j),
		   lb_DEMAND_TYPE(j),
		   lb_DAILY_DEMAND_RATE(j),
		   lb_ORIGINATION_TYPE(j),
		   MSC_CL_COLLECTION.v_source_organization_id,
		   lb_DISPOSITION_ID(j),
		   lb_RESERVATION_ID(j),
		   lb_OPERATION_SEQ_NUM(j),
		   lb_DEMAND_CLASS(j),
		   lb_PROMISE_DATE(j),
		   lb_LINK_TO_LINE_ID(j),
		   lb_SR_INSTANCE_ID(j),
		   lb_PROJECT_ID(j),
		   lb_TASK_ID(j),
		   lb_PLANNING_GROUP(j),
		   lb_END_ITEM_UNIT_NUMBER(j),
		   lb_ORDER_NUMBER(j),
		   lb_REPETITIVE_SCHEDULE_ID(j),
		   lb_SELLING_PRICE(j),
		   lb_DMD_LATENESS_COST(j),
		   lb_REQUEST_DATE(j),
		   lb_ORDER_PRIORITY(j),
		   lb_SALES_ORDER_LINE_ID(j),
		   MSC_CL_COLLECTION.v_supply_id,
		   MSC_CL_COLLECTION.v_source_sr_instance_id,
		   lb_OR_SYSTEM_REFERENCE(j),
		   lb_OR_SYSTEM_LINE_REFERENCE(j),
		   lb_demand_source_type(j),
		   lb_customer_id(j),
		   lb_CUSTOMER_SITE_ID(j),
		   lb_SHIP_TO_SITE_ID(j),
		   MSC_CL_COLLECTION.v_last_collection_id,
		   MSC_CL_COLLECTION.v_current_date,
		   MSC_CL_COLLECTION.v_current_user,
		   MSC_CL_COLLECTION.v_current_date,
		   MSC_CL_COLLECTION.v_current_user,
		   lb_ORDER_DATE_TYPE_CODE(j),
		   lb_SCHEDULE_ARRIVAL_DATE(j),
		   lb_LATEST_ACCEPTABLE_DATE(j),
		   lb_SHIP_TO_LOCATION_ID(j),
		   lb_SHIPPING_METHOD_CODE(j);

		END IF;  -- complete_refresh, sql%notfound

		  c_count:= c_count+1;

		  IF c_count>MSC_CL_COLLECTION.PBS THEN
		     IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;
		     c_count:= 0;
		  END IF;
		  MSC_CL_COLLECTION.v_supply_id := Null;
		             MSC_CL_COLLECTION.v_source_organization_id := Null;
		             MSC_CL_COLLECTION.v_source_sr_instance_id := Null;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DEMAND');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DEMAND');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DEMANDS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
		      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.item_name( lb_INVENTORY_ITEM_ID(j)));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( lb_ORGANIZATION_ID(j),
		                                                   MSC_CL_COLLECTION.v_instance_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_TYPE');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(lb_ORGANIZATION_ID(j)));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORIGINATION_TYPE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		               MSC_GET_NAME.LOOKUP_MEANING('MRP_DEMAND_ORIGINATION',
		                                           lb_ORIGINATION_TYPE(j)));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      IF lb_DEMAND_SCHEDULE_NAME(j) IS NOT NULL THEN
		         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		         FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_SCHEDULE_NAME');
		         FND_MESSAGE.SET_TOKEN('VALUE', lb_DEMAND_SCHEDULE_NAME(j));
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
		      END IF;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;
		END LOOP;
		END IF;
		CLOSE c1;

		   IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN COMMIT; END IF;

		   IF (MSC_CL_COLLECTION.v_apps_ver >= MSC_UTIL.G_APPS115) then
		      IF (MSC_CL_COLLECTION.v_is_incremental_refresh) OR (MSC_CL_COLLECTION.v_is_cont_refresh and MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_INCR) THEN --Version
		        /* call the function to link the Demand_id and Parent_id in MSC_DEMANDS
			    if mds is incremental*/
			    MSC_CL_COLLECTION.v_exchange_mode := MSC_UTIL.SYS_NO;
		            IF  MSC_CL_DEMAND_ODS_LOAD.LINK_PARENT_SALES_ORDERS_MDS THEN
		                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Linking of Sales Order line in MDS to its Parent Sales orders is successful.....');
		            ELSE
		                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'Error in Linking Sales order line in MDS to its parent Sales order......');
		                MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;
		            END IF;
		      END IF;
		   END IF;

   END LOAD_DEMAND;



PROCEDURE link_ISO_IR(pSOtbl varchar2,pSupplyTbl varchar2) IS
lv_sql VARCHAR2(4000);
BEGIN
IF (MSC_CL_COLLECTION.v_apps_ver =  MSC_UTIL.G_APPS110 OR MSC_CL_COLLECTION.v_is_legacy_refresh) THEN -- Version
 lv_sql:=
 'UPDATE '||pSOtbl||' a
  SET (SUPPLY_ID, SOURCE_ORGANIZATION_ID, SOURCE_ORG_INSTANCE_ID)
  = (SELECT b.TRANSACTION_ID ,b.ORGANIZATION_ID, b.SOURCE_SR_INSTANCE_ID
       FROM '||pSupplyTbl||' b
      WHERE  b.SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id||'
      AND    b.PLAN_ID = -1
      AND    b.order_number = a.ORIGINAL_SYSTEM_REFERENCE
      AND    to_char(b.purch_line_num) = a.ORIGINAL_SYSTEM_LINE_REFERENCE
      AND    b.order_type = 2
      AND    b.new_order_quantity > 0
      AND    b.source_organization_id is not null
        )
  WHERE a.SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
  ||' AND a.demand_source_type = 8
  AND a.original_system_reference <> ''-1''
  AND a.original_system_line_reference <> ''-1''
  AND a.REFRESH_NUMBER = '||MSC_CL_COLLECTION.v_last_collection_id;

ELSE
lv_sql:=
'UPDATE '||pSOtbl||' a
  SET (SUPPLY_ID, SOURCE_ORGANIZATION_ID, SOURCE_ORG_INSTANCE_ID)
  = (SELECT b.TRANSACTION_ID ,b.ORGANIZATION_ID, b.SOURCE_SR_INSTANCE_ID
       FROM '||pSupplyTbl||' b
      WHERE  b.SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id||'
      AND    b.PLAN_ID = -1
      AND    b.disposition_id = to_number(a.ORIGINAL_SYSTEM_REFERENCE)
      AND    b.po_line_id = to_number(a.ORIGINAL_SYSTEM_LINE_REFERENCE)
      AND    b.order_type IN  (2,73)
      AND    b.new_order_quantity > 0
      AND    b.source_organization_id is not null
        )
  WHERE a.SR_INSTANCE_ID = '||MSC_CL_COLLECTION.v_instance_id
  ||' AND a.demand_source_type = 8
  AND a.original_system_reference <> ''-1''
  AND a.original_system_line_reference <> ''-1''
  AND a.REFRESH_NUMBER = '||MSC_CL_COLLECTION.v_last_collection_id;
END IF;

  EXECUTE IMMEDIATE lv_sql;
  commit;
 MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'link_ISO_IR: Rows updated - '||SQL%ROWCOUNT);

END;

   -- ========================= LOAD SALES ORDER ==============

   PROCEDURE LOAD_SALES_ORDER IS

			   lv_tbl      VARCHAR2(30);
			   lv_supply_tbl      VARCHAR2(30);
			   ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);
		     lv_exchange_mode  NUMBER:= MSC_UTIL.SYS_NO;
		     lv_sql_stmt VARCHAR2(5000);
        lv_sql1_1 VARCHAR2(4000);
        lv_sql1_2 VARCHAR2(1000);
        lv_sql1_3 VARCHAR2(4000);
        lv_sql2 VARCHAR2(4000);
        lv_sql3 VARCHAR2(4000);
        lv_sql4 VARCHAR2(4000);
        lv_sql5 VARCHAR2(30000);


BEGIN
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, ' LOAD_SALES_ORDER started');

			IF MSC_CL_COLLECTION.v_so_exchange_mode= MSC_UTIL.SYS_YES AND
			   MSC_CL_COLLECTION.is_msctbl_partitioned('MSC_SALES_ORDERS') THEN
			   lv_exchange_mode := MSC_UTIL.SYS_YES;
			END IF;

			IF lv_exchange_mode=MSC_UTIL.SYS_YES THEN
			   lv_tbl:= 'SALES_ORDERS_'||MSC_CL_COLLECTION.v_instance_code;
			   lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
			ELSE
			   lv_tbl:= 'MSC_SALES_ORDERS';
			   lv_supply_tbl:= 'MSC_SUPPLIES';
			END IF;

			   /** PREPLACE CHANGE START **/

			IF (MSC_CL_COLLECTION.v_is_partial_refresh            AND
			    (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_NO) AND
			    (MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_NO) AND
			    (MSC_CL_COLLECTION.v_coll_prec.po_flag = MSC_UTIL.SYS_NO)  AND
			    (MSC_CL_COLLECTION.v_coll_prec.oh_flag = MSC_UTIL.SYS_NO)  AND
			    (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_NO) ) THEN

			         lv_supply_tbl := 'MSC_SUPPLIES';

			ELSIF lv_exchange_mode=MSC_UTIL.SYS_YES THEN

			         lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;

			END IF;
			   /**  PREPLACE CHANGE END  **/


			/* In cont. collections if any of the Supply is targeted  */
			   IF (MSC_CL_COLLECTION.v_is_cont_refresh) THEN
				  IF (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) OR
			             (MSC_CL_COLLECTION.v_coll_prec.mps_flag = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.mps_sn_flag = MSC_UTIL.SYS_TGT) OR
			             (MSC_CL_COLLECTION.v_coll_prec.po_flag  = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.po_sn_flag = MSC_UTIL.SYS_TGT) OR
			             (MSC_CL_COLLECTION.v_coll_prec.oh_flag  = MSC_UTIL.SYS_YES  AND  MSC_CL_COLLECTION.v_coll_prec.oh_sn_flag = MSC_UTIL.SYS_TGT) OR
				     (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES and MSC_CL_COLLECTION.v_coll_prec.usup_sn_flag = MSC_UTIL.SYS_TGT) THEN
			                   lv_supply_tbl:= 'SUPPLIES_'||MSC_CL_COLLECTION.v_instance_code;
                               MSC_CL_COLLECTION.v_exchange_mode := MSC_UTIL.SYS_YES ;-- bug 8424335
			          ELSE
			                   lv_supply_tbl := 'MSC_SUPPLIES';
                               MSC_CL_COLLECTION.v_exchange_mode := MSC_UTIL.SYS_NO ; -- bug 8424335
			          END IF;
			   END IF;

			/* 2140727 - Insert project_id and task_id also */

-- delete records
IF MSC_CL_COLLECTION.v_is_so_complete_refresh THEN -- complete refresh

			   IF lv_exchange_mode=MSC_UTIL.SYS_NO THEN

			      IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
			         MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SALES_ORDERS', MSC_CL_COLLECTION.v_instance_id,NULL);
			      ELSE
			         MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
			         MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_SALES_ORDERS', MSC_CL_COLLECTION.v_instance_id,NULL,MSC_CL_COLLECTION.v_sub_str);
			      END IF;

			   END IF;

      BEGIN

			IF ((MSC_CL_COLLECTION.v_coll_prec.org_group_flag <> MSC_UTIL.G_ALL_ORGANIZATIONS) AND (lv_exchange_mode=MSC_UTIL.SYS_YES)) THEN

			lv_tbl:= 'SALES_ORDERS_'||MSC_CL_COLLECTION.v_instance_code;

			lv_sql_stmt:=
			         'INSERT INTO '||lv_tbl
			          ||' SELECT * from MSC_SALES_ORDERS'
			          ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
			          ||' AND organization_id not '||MSC_UTIL.v_in_org_str;

			   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'The sql statement is '||lv_sql_stmt);
			   EXECUTE IMMEDIATE lv_sql_stmt;
			   COMMIT;
			END IF;

			EXCEPTION
			  WHEN OTHERS THEN

			      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
			      RAISE;
			END;

ELSE

        LOOP
              DELETE FROM MSC_SALES_ORDERS
              WHERE ROW_TYPE = 3
              AND sr_instance_id = MSC_CL_COLLECTION.v_instance_id
              AND SR_DEMAND_ID IN (SELECT so.DEMAND_ID
                                    FROM MSC_ST_SALES_ORDERS so
                                    WHERE so.sr_instance_id = MSC_CL_COLLECTION.v_instance_id
                                    AND so.ROW_TYPE = 2 )
              AND ROWNUM <= ln_rows_to_fetch;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'NetCHg DELETE1 ROWSDELETED :'||SQL%rowcount);
        EXIT WHEN SQL%ROWCOUNT = 0;
        COMMIT;
        END LOOP;

        LOOP
              DELETE FROM MSC_SALES_ORDERS
              WHERE SR_INSTANCE_ID = MSC_CL_COLLECTION.v_instance_id
              AND (ROW_TYPE,SR_DEMAND_ID) IN (SELECT so.ROW_TYPE,so.DEMAND_ID
                                    FROM MSC_ST_SALES_ORDERS so
                                    WHERE so.DELETED_FLAG = 1
                                    AND so.sr_instance_id = MSC_CL_COLLECTION.v_instance_id)
              AND ROWNUM <= ln_rows_to_fetch;
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'NetCHg DELETE2 ROWSDELETED :'||SQL%rowcount);
        EXIT WHEN SQL%ROWCOUNT = 0;
        COMMIT;
        END LOOP;

END IF; -- complete refresh



BEGIN

lv_sql1_1 :=
'SELECT
  t1.INVENTORY_ITEM_ID,
   so.ORGANIZATION_ID,
   so.PRIMARY_UOM_QUANTITY,
   so.RESERVATION_TYPE,
   so.RESERVATION_QUANTITY,
   so.DEMAND_SOURCE_TYPE,
   so.DEMAND_SOURCE_HEADER_ID,
   so.COMPLETED_QUANTITY,
   so.SUBINVENTORY,
   so.DEMAND_CLASS,
   decode(nvl(so.MFG_LEAD_TIME,0),0, so.REQUIREMENT_DATE,
             MSC_CALENDAR.DATE_OFFSET(so.ORGANIZATION_ID,
                                      so.SR_INSTANCE_ID,
                                      1,
				      so.REQUIREMENT_DATE,
                                      -(so.MFG_LEAD_TIME) )
		 )  REQUIREMENT_DATE,
	 so.DEMAND_ID SR_DEMAND_ID,
	 so.ROW_TYPE,
   so.DEMAND_SOURCE_LINE,
   so.DEMAND_SOURCE_DELIVERY,
   so.DEMAND_SOURCE_NAME,
   so.PARENT_DEMAND_ID,
   so.SALES_ORDER_NUMBER,
   so.FORECAST_VISIBLE ,
   so.DEMAND_VISIBLE ,
   so.SALESREP_CONTACT,
   so.SALESREP_ID,
   mtil.tp_id CUSTOMER_ID,
   mtsila.tp_site_id SHIP_TO_SITE_USE_ID,
   mtsilb.tp_site_id BILL_TO_SITE_USE_ID,
   so.REQUEST_DATE,
   so.PROJECT_ID,
   so.TASK_ID,
   so.PLANNING_GROUP,
   so.DEMAND_PRIORITY,
   so.PROMISE_DATE,
   so.LINK_TO_LINE_ID,
    so.SELLING_PRICE,
    so.END_ITEM_UNIT_NUMBER,
    so.CTO_FLAG,
    t2.INVENTORY_ITEM_ID ORIGINAL_ITEM_ID,
    decode(so.available_to_mrp,''1'',''Y'',''Y'',''Y'',''N'') available_to_mrp,
    so.SR_INSTANCE_ID,
   so.ATP_REFRESH_NUMBER,
      nvl(so.ORIGINAL_SYSTEM_REFERENCE,''-1'') ORIGINAL_SYSTEM_REFERENCE,
   nvl(so.ORIGINAL_SYSTEM_LINE_REFERENCE,''-1'') ORIGINAL_SYSTEM_LINE_REFERENCE,
    so.MFG_LEAD_TIME,
   t3.inventory_item_id ORDERED_ITEM_ID,
   '||MSC_CL_COLLECTION.v_last_collection_id||' last_collection_id,
   so.CUST_PO_NUMBER,
   so.CUSTOMER_LINE_NUMBER,
   so.ORG_FIRM_FLAG,
   so.SHIP_SET_ID,
   so.ARRIVAL_SET_ID,
   so.SHIP_SET_NAME,
   so.ARRIVAL_SET_NAME,
    '''||MSC_CL_COLLECTION.v_current_date||''' current_date1,
    '||MSC_CL_COLLECTION.v_current_user|| ' current_user1,
    '''||MSC_CL_COLLECTION.v_current_date||''' current_date2,
    '||MSC_CL_COLLECTION.v_current_user|| ' current_user2,
   so.ATO_LINE_ID,
   so.ORDER_DATE_TYPE_CODE,
   so.SCHEDULE_ARRIVAL_DATE,
   so.LATEST_ACCEPTABLE_DATE,
   mtsila.location_id ship_to_location_id,
   so.SHIPPING_METHOD_CODE,
   so.INTRANSIT_LEAD_TIME,
   so.customer_id sr_customer_acct_id ,
   so.DEMAND_SOURCE_LINE SR_SO_LINEID ';
lv_sql1_2 :=
'   ,MSC_DEMANDS_S.nextval DEMAND_ID ';

lv_sql1_3:='
FROM MSC_ITEM_ID_LID t1,
     MSC_ITEM_ID_LID t2,
     MSC_ITEM_ID_LID t3,
     MSC_ST_SALES_ORDERS so,
     MSC_TP_ID_LID mtil,
     MSC_TP_SITE_ID_LID mtsila,
     MSC_TP_SITE_ID_LID mtsilb
WHERE t1.SR_INVENTORY_ITEM_ID= so.INVENTORY_ITEM_ID
  AND t1.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id||'
  AND so.SR_INSTANCE_ID= '||MSC_CL_COLLECTION.v_instance_id||'
  AND so.ROW_TYPE= xxx_ROW_TYPE
  AND t2.SR_INVENTORY_ITEM_ID(+) = so.ORIGINAL_ITEM_ID
  AND t2.SR_INSTANCE_ID(+) = so.SR_INSTANCE_ID
  AND t3.SR_INVENTORY_ITEM_ID(+) = so.ORDERED_ITEM_ID
  AND t3.SR_INSTANCE_ID(+) = so.SR_INSTANCE_ID
  AND so.DELETED_FLAG= 2
  and mtil.sr_instance_id(+)  = '||MSC_CL_COLLECTION.v_instance_id||'
  and mtil.sr_tp_id(+) = so.customer_id
  and mtil.partner_type(+) = 2
  and mtsila.sr_instance_id(+)  = '||MSC_CL_COLLECTION.v_instance_id||'
  and mtsila.sr_tp_site_id(+) = so.SHIP_TO_SITE_USE_ID
  and mtsila.partner_type(+) = 2
  and mtsilb.sr_instance_id(+)  = '||MSC_CL_COLLECTION.v_instance_id||'
  and mtsilb.sr_tp_site_id(+) = so.BILL_TO_SITE_USE_ID
  and mtsilb.partner_type(+) = 2 ';


lv_sql2:=
') s
 ON (d.SR_INSTANCE_ID=  s.SR_INSTANCE_ID
      AND d.SR_DEMAND_ID=  s.SR_DEMAND_ID
      AND d.ROW_TYPE= s.ROW_TYPE)
WHEN MATCHED THEN
UPDATE SET
    d.OLD_PRIMARY_UOM_QUANTITY=  d.PRIMARY_UOM_QUANTITY,
    d.OLD_RESERVATION_QUANTITY=  xxx_RESERVATION_QUANTITY,
    d.OLD_COMPLETED_QUANTITY=  d.COMPLETED_QUANTITY,
    d.OLD_REQUIREMENT_DATE=  d.REQUIREMENT_DATE,
    d.PRIMARY_UOM_QUANTITY=  s.PRIMARY_UOM_QUANTITY,
    d.RESERVATION_QUANTITY=  s.RESERVATION_QUANTITY,
    d.DEMAND_SOURCE_TYPE=  s.DEMAND_SOURCE_TYPE,
    d.DEMAND_SOURCE_HEADER_ID=  s.DEMAND_SOURCE_HEADER_ID,
    d.COMPLETED_QUANTITY=  s.COMPLETED_QUANTITY,
    d.SUBINVENTORY=  s.SUBINVENTORY,
    d.DEMAND_CLASS=  s.DEMAND_CLASS,
    d.REQUIREMENT_DATE=  s.REQUIREMENT_DATE,
    --d.SR_DEMAND_ID   =  s.SR_DEMAND_ID,
    d.DEMAND_SOURCE_DELIVERY=  s.DEMAND_SOURCE_DELIVERY,
    d.DEMAND_SOURCE_NAME=  s.DEMAND_SOURCE_NAME,
    d.PARENT_DEMAND_ID=  s.PARENT_DEMAND_ID,
    d.SALES_ORDER_NUMBER= s.SALES_ORDER_NUMBER,
    d.FORECAST_VISIBLE = s.FORECAST_VISIBLE ,
    d.DEMAND_VISIBLE = s.DEMAND_VISIBLE ,
    d.SALESREP_CONTACT= s.SALESREP_CONTACT,
    d.SALESREP_ID= s.SALESREP_ID,
    d.CUSTOMER_ID = s.CUSTOMER_ID,
    d.SHIP_TO_SITE_USE_ID = s.SHIP_TO_SITE_USE_ID,
    d.BILL_TO_SITE_USE_ID = s.BILL_TO_SITE_USE_ID,
    d.REQUEST_DATE = s.REQUEST_DATE,
    d.PROJECT_ID = s.PROJECT_ID,
    d.TASK_ID = s.TASK_ID,
    d.PLANNING_GROUP = s.PLANNING_GROUP,
    d.DEMAND_PRIORITY = s.DEMAND_PRIORITY,
    d.PROMISE_DATE = s.PROMISE_DATE,
    d.LINK_TO_LINE_ID = s.LINK_TO_LINE_ID,
    d.SELLING_PRICE = s.SELLING_PRICE,
    d.END_ITEM_UNIT_NUMBER = s.END_ITEM_UNIT_NUMBER,
    d.ORIGINAL_ITEM_ID = s.ORIGINAL_ITEM_ID,
    d.AVAILABLE_TO_MRP = s.AVAILABLE_TO_MRP,
    d.ATP_REFRESH_NUMBER= s.ATP_REFRESH_NUMBER,
    d.ORIGINAL_SYSTEM_REFERENCE= s.ORIGINAL_SYSTEM_REFERENCE,
    d.ORIGINAL_SYSTEM_LINE_REFERENCE= s.ORIGINAL_SYSTEM_LINE_REFERENCE,
    d.MFG_LEAD_TIME = s.MFG_LEAD_TIME,
    d.ORDERED_ITEM_ID = s.ORDERED_ITEM_ID,
    d.REFRESH_NUMBER= '||MSC_CL_COLLECTION.v_last_collection_id||',
    d.CUST_PO_NUMBER =s.CUST_PO_NUMBER,
    d.CUSTOMER_LINE_NUMBER=s.CUSTOMER_LINE_NUMBER,
    d.ORG_FIRM_FLAG =s.ORG_FIRM_FLAG,
    d.SHIP_SET_ID = s.SHIP_SET_ID,
    d.ARRIVAL_SET_ID = s.ARRIVAL_SET_ID,
    d.SHIP_SET_NAME = s.SHIP_SET_NAME,
    d.ARRIVAL_SET_NAME = s.ARRIVAL_SET_NAME,
    d.LAST_UPDATE_DATE= '''||MSC_CL_COLLECTION.v_current_date||''',
    d.LAST_UPDATED_BY= '||MSC_CL_COLLECTION.v_current_user|| ',
    d.ATO_LINE_ID=s.ATO_LINE_ID,
    d.ORDER_DATE_TYPE_CODE=s.ORDER_DATE_TYPE_CODE,
    d.SCHEDULE_ARRIVAL_DATE=s.SCHEDULE_ARRIVAL_DATE,
    d.LATEST_ACCEPTABLE_DATE=s.LATEST_ACCEPTABLE_DATE,
    d.SHIP_TO_LOCATION_ID=s.SHIP_TO_LOCATION_ID,
    d.SHIPPING_METHOD_CODE=s.SHIPPING_METHOD_CODE,
    d.INTRANSIT_LEAD_TIME=s.INTRANSIT_LEAD_TIME,
    d.sr_customer_acct_id = s.sr_customer_acct_id,
    d.prev_coll_item_id = d.inventory_item_id,
    d.SR_SO_LINEID=s.DEMAND_SOURCE_LINE ';


lv_sql3:=
'      ( d.INVENTORY_ITEM_ID,
       d.ORGANIZATION_ID,
       d.PRIMARY_UOM_QUANTITY,
       d.RESERVATION_TYPE,
       d.RESERVATION_QUANTITY,
       d.DEMAND_SOURCE_TYPE,
       d.DEMAND_SOURCE_HEADER_ID,
       d.COMPLETED_QUANTITY,
       d.SUBINVENTORY,
       d.DEMAND_CLASS,
       d.REQUIREMENT_DATE,
       d.SR_DEMAND_ID,
       d.ROW_TYPE,
       d.DEMAND_SOURCE_LINE,
       d.DEMAND_SOURCE_DELIVERY,
       d.DEMAND_SOURCE_NAME,
       d.PARENT_DEMAND_ID,
       d.SALES_ORDER_NUMBER,
       d.FORECAST_VISIBLE ,
       d.DEMAND_VISIBLE ,
       d.SALESREP_CONTACT,
       d.SALESREP_ID,
       d.CUSTOMER_ID,
       d.SHIP_TO_SITE_USE_ID,
       d.BILL_TO_SITE_USE_ID,
       d.REQUEST_DATE,
       d.PROJECT_ID,
       d.TASK_ID,
       d.PLANNING_GROUP,
       d.DEMAND_PRIORITY,
       d.PROMISE_DATE,
       d.LINK_TO_LINE_ID,
       d.SELLING_PRICE,
       d.END_ITEM_UNIT_NUMBER,
       d.CTO_FLAG,
       d.ORIGINAL_ITEM_ID,
       d.AVAILABLE_TO_MRP,
       d.SR_INSTANCE_ID,
       d.ATP_REFRESH_NUMBER,
       d.ORIGINAL_SYSTEM_REFERENCE,
       d.ORIGINAL_SYSTEM_LINE_REFERENCE,
       d.MFG_LEAD_TIME,
       d.ORDERED_ITEM_ID,
       d.REFRESH_NUMBER,
       d.CUST_PO_NUMBER,
       d.CUSTOMER_LINE_NUMBER,
       d.ORG_FIRM_FLAG,
       d.SHIP_SET_ID,
       d.ARRIVAL_SET_ID,
       d.SHIP_SET_NAME,
       d.ARRIVAL_SET_NAME,
       d.LAST_UPDATE_DATE,
       d.LAST_UPDATED_BY,
       d.CREATION_DATE,
       d.CREATED_BY,
       d.ATO_LINE_ID,
       d.ORDER_DATE_TYPE_CODE,
       d.SCHEDULE_ARRIVAL_DATE,
       d.LATEST_ACCEPTABLE_DATE,
       d.SHIP_TO_LOCATION_ID,
       d.SHIPPING_METHOD_CODE,
       d.INTRANSIT_LEAD_TIME,
       d.sr_customer_acct_id,
       d.SR_SO_LINEID,
       d.DEMAND_ID )
 ';


 lv_sql4:=
 '     	VALUES
    	 (
        s.INVENTORY_ITEM_ID,
        s.ORGANIZATION_ID,
        s.PRIMARY_UOM_QUANTITY,
        s.RESERVATION_TYPE,
        s.RESERVATION_QUANTITY,
        s.DEMAND_SOURCE_TYPE,
        s.DEMAND_SOURCE_HEADER_ID,
        s.COMPLETED_QUANTITY,
        s.SUBINVENTORY,
        s.DEMAND_CLASS,
        s.REQUIREMENT_DATE,
        s.SR_DEMAND_ID,
        s.ROW_TYPE,
        s.DEMAND_SOURCE_LINE,
        s.DEMAND_SOURCE_DELIVERY,
        s.DEMAND_SOURCE_NAME,
        s.PARENT_DEMAND_ID,
        s.SALES_ORDER_NUMBER,
        s.FORECAST_VISIBLE ,
        s.DEMAND_VISIBLE ,
        s.SALESREP_CONTACT,
        s.SALESREP_ID,
        s.CUSTOMER_ID,
        s.SHIP_TO_SITE_USE_ID,
        s.BILL_TO_SITE_USE_ID,
        s.REQUEST_DATE,
        s.PROJECT_ID,
        s.TASK_ID,
        s.PLANNING_GROUP,
        s.DEMAND_PRIORITY,
        s.PROMISE_DATE,
        s.LINK_TO_LINE_ID,
        s.SELLING_PRICE,
        s.END_ITEM_UNIT_NUMBER,
        s.CTO_FLAG,
        s.ORIGINAL_ITEM_ID,
        s.AVAILABLE_TO_MRP,
        s.SR_INSTANCE_ID,
        s.ATP_REFRESH_NUMBER,
        s.ORIGINAL_SYSTEM_REFERENCE,
        s.ORIGINAL_SYSTEM_LINE_REFERENCE,
        s.MFG_LEAD_TIME,
        s.ORDERED_ITEM_ID,
        '||MSC_CL_COLLECTION.v_last_collection_id||',
        s.CUST_PO_NUMBER,
        s.CUSTOMER_LINE_NUMBER,
        s.ORG_FIRM_FLAG,
        s.SHIP_SET_ID,
        s.ARRIVAL_SET_ID,
        s.SHIP_SET_NAME,
        s.ARRIVAL_SET_NAME,
        '''||MSC_CL_COLLECTION.v_current_date||''',
        '||MSC_CL_COLLECTION.v_current_user|| ',
        '''||MSC_CL_COLLECTION.v_current_date||''',
        '||MSC_CL_COLLECTION.v_current_user|| ',
        s.ATO_LINE_ID,
        s.ORDER_DATE_TYPE_CODE,
        s.SCHEDULE_ARRIVAL_DATE,
        s.LATEST_ACCEPTABLE_DATE,
        s.SHIP_TO_LOCATION_ID,
        s.SHIPPING_METHOD_CODE,
        s.INTRANSIT_LEAD_TIME,
        s.sr_customer_acct_id,
        s.DEMAND_SOURCE_LINE,
        MSC_DEMANDS_S.nextval ) ';


-- row type1
IF MSC_CL_COLLECTION.v_is_so_incremental_refresh  THEN -- for netchg Coll
  lv_sql5 := ' MERGE   INTO '||lv_tbl||' d USING('
      || lv_sql1_1|| lv_sql1_3
      || lv_sql2
      ||' WHEN NOT MATCHED THEN
          insert '
      || lv_sql3
      ||lv_sql4;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',1);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY',' decode (s.COMPLETED_QUANTITY,
                                      													0, d.RESERVATION_QUANTITY,
                                      													d.old_reservation_quantity)  ');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS MERGED :'||SQL%ROWCOUNT);
  COMMIT;
ELSE -- for target Coll
  lv_sql5 := ' INSERT INTO '||lv_tbl||' d  '
                || lv_sql3
                || lv_sql1_1 ||lv_sql1_2 || lv_sql1_3
                ;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',1);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY',' decode (s.COMPLETED_QUANTITY,
                                      													0, d.RESERVATION_QUANTITY,
                                      													d.old_reservation_quantity)  ');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS INSERTED :'||SQL%ROWCOUNT);
  COMMIT;
END IF;
-- end row type 1

-- row type2
IF MSC_CL_COLLECTION.v_is_so_incremental_refresh  THEN -- for netchg Coll
  lv_sql5 := ' MERGE   INTO '||lv_tbl||' d USING('
      || lv_sql1_1|| lv_sql1_3
      || '    AND decode(nvl(so.MFG_LEAD_TIME,0),
                0, so.REQUIREMENT_DATE,
			          MSC_CALENDAR.DATE_OFFSET(so.ORGANIZATION_ID,so.SR_INSTANCE_ID,1,so.REQUIREMENT_DATE,-(so.MFG_LEAD_TIME))
					     ) IS NOT NULL '
      || lv_sql2
      ||' WHEN NOT MATCHED THEN
          insert '
      || lv_sql3
      ||lv_sql4;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',2);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY','d.RESERVATION_QUANTITY');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS MERGED :'||SQL%ROWCOUNT);
  COMMIT;
ELSE -- for target Coll
  lv_sql5 := ' INSERT INTO '||lv_tbl||' d  '
                || lv_sql3
                || lv_sql1_1 ||lv_sql1_2 || lv_sql1_3
                ||'    AND decode(nvl(so.MFG_LEAD_TIME,0),
                    0, so.REQUIREMENT_DATE,
    			          MSC_CALENDAR.DATE_OFFSET(so.ORGANIZATION_ID,so.SR_INSTANCE_ID,1,so.REQUIREMENT_DATE,-(so.MFG_LEAD_TIME))
    					     ) IS NOT NULL '
                ;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',2);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY','d.RESERVATION_QUANTITY');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS INSERTED :'||SQL%ROWCOUNT);
  COMMIT;
END IF;
-- Update Reservation Qty

  FOR modified_resv IN (  select distinct msso.demand_source_line
                           from   msc_st_sales_orders msso
      			               where  msso.sr_instance_id= MSC_CL_COLLECTION.v_instance_id
      			               AND    ROW_TYPE=1
      			               and    msso.demand_source_line IS NOT NULL
      			               and    msso.reservation_type = 2
      			               and    msso.deleted_flag=MSC_UTIL.SYS_NO )
  LOOP
     	    UPDATE MSC_SALES_ORDERS
			    SET    RESERVATION_QUANTITY = (	SELECT SUM(NVL(mso.primary_uom_quantity,0))
                                  			   FROM  msc_sales_orders mso
                                  			   WHERE mso.sr_instance_id= MSC_CL_COLLECTION.v_instance_id
                                  			     AND mso.reservation_type = 2
                                  			     AND ROW_TYPE=1
                                  			     AND mso.demand_source_line = modified_resv.demand_source_line ),
			           old_reservation_quantity = reservation_quantity
			    WHERE  sr_instance_id = MSC_CL_COLLECTION.v_instance_id
			    AND    RESERVATION_TYPE = 1
			    AND    AVAILABLE_TO_MRP = 'Y'
			    AND    CTO_FLAG = 2
			    AND    ROW_TYPE=2
			    AND    demand_source_line = modified_resv.demand_source_line ;
			    COMMIT;
	END LOOP;
--
-- end row type 2

-- row type3
 --always target Coll for row type 3
  lv_sql5 := ' INSERT INTO '||lv_tbl||' d  '
                || lv_sql3
                || lv_sql1_1 ||lv_sql1_2 || lv_sql1_3
                ;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',3);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY','d.RESERVATION_QUANTITY');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS INSERTED :'||SQL%ROWCOUNT);
  COMMIT;
-- end row type 3

-- row type4
IF MSC_CL_COLLECTION.v_is_so_incremental_refresh  THEN -- for netchg Coll
  lv_sql5 := ' MERGE   INTO '||lv_tbl||' d USING('
      || lv_sql1_1|| lv_sql1_3
      || lv_sql2
      ||' WHEN NOT MATCHED THEN
          insert '
      || lv_sql3
      ||lv_sql4;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',4);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY','d.RESERVATION_QUANTITY');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS MERGED :'||SQL%ROWCOUNT);
  COMMIT;
ELSE -- for target Coll
  lv_sql5 := ' INSERT INTO '||lv_tbl||' d  '
                || lv_sql3
                || lv_sql1_1 ||lv_sql1_2 || lv_sql1_3
                ;
  lv_sql5 := REPLACE (lv_sql5,'xxx_ROW_TYPE',4);
  lv_sql5 := REPLACE (lv_sql5,'xxx_RESERVATION_QUANTITY','d.RESERVATION_QUANTITY');
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Stmt Executed :'||lv_sql5);
  EXECUTE IMMEDIATE lv_sql5;
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'ROWS INSERTED :'||SQL%ROWCOUNT);
  COMMIT;
END IF;
-- end row type 4

 -- UPDATE ireq/ISO
link_ISO_IR(lv_tbl,lv_supply_tbl);
--



EXCEPTION

   WHEN OTHERS THEN

/*

      IF SQLCODE <> -54 THEN   /* NO_WAIT failed */

/*         MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
         FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
         FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_SALES_ORDER');
         FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_SALES_ORDERS');
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);*/

/*         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
         FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.item_name( c_rec.INVENTORY_ITEM_ID));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);*/

/*         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
         FND_MESSAGE.SET_TOKEN('VALUE',
                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
                                                   MSC_CL_COLLECTION.v_instance_id));*/

/*         FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'DEMAND_ID');
         FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.SR_DEMAND_ID));
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);*/

/*         IF c_rec.SALES_ORDER_NUMBER IS NOT NULL THEN
            FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'SALES_ORDER_NUMBER');
            FND_MESSAGE.SET_TOKEN('VALUE', c_rec.SALES_ORDER_NUMBER);
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);
         END IF;*/

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
         RAISE;

     /* END IF;*/

END;
END LOAD_SALES_ORDER;

--==================================================================

   PROCEDURE LOAD_HARD_RESERVATION IS

   Cursor c1 IS
		SELECT
		   t1.INVENTORY_ITEM_ID,
		   mshr.ORGANIZATION_ID,
		   mshr.TRANSACTION_ID,
		   mshr.RESERVED_QUANTITY,
		   mshr.DISPOSITION_ID,
		   mshr.DISPOSITION_TYPE,
		   mshr.RESERVATION_FLAG,
		   mshr.RESERVATION_TYPE,   -- SRP Changes For Bug 5988024
		   mshr.PARENT_DEMAND_ID,
		   mshr.REQUIREMENT_DATE,
		   mshr.DEMAND_CLASS,
		   mshr.PROJECT_ID,
		   mshr.TASK_ID,
		   mshr.SR_INSTANCE_ID,
		   mshr.SUPPLY_SOURCE_HEADER_ID,
		   mshr.SUPPLY_SOURCE_TYPE_ID,
		   mshr.REPAIR_PO_HEADER_ID                           --SRP Changes For Bug 5996327
		 FROM MSC_ITEM_ID_LID t1,     /* bug fix 1084440 */
		      MSC_ST_RESERVATIONS mshr
		WHERE mshr.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND mshr.DELETED_FLAG= MSC_UTIL.SYS_NO
		  AND t1.SR_INVENTORY_ITEM_ID= mshr.INVENTORY_ITEM_ID
		  AND t1.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id;

		   Cursor c1_d IS
		SELECT
    		   TRANSACTION_ID,
           PARENT_DEMAND_ID,
           SR_INSTANCE_ID,
           SUPPLY_SOURCE_TYPE_ID,
           ORGANIZATION_ID,
           INVENTORY_ITEM_ID,
           DISPOSITION_ID,
           DISPOSITION_TYPE
    FROM MSC_ST_RESERVATIONS mshr
    WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
      AND DELETED_FLAG= MSC_UTIL.SYS_YES ; /* Changed For Bug 6144734 */

		  c_count NUMBER:= 0;

		   BEGIN

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN
		         -- We want to delete all HARD_RESERV related data and get new stuff.

		--MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESERVATIONS', MSC_CL_COLLECTION.v_instance_id, -1);

		  IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
		    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESERVATIONS', MSC_CL_COLLECTION.v_instance_id, -1);
		  ELSE
		    MSC_CL_COLLECTION.v_sub_str :=' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;
		    MSC_CL_COLLECTION.DELETE_MSC_TABLE( 'MSC_RESERVATIONS', MSC_CL_COLLECTION.v_instance_id, -1,MSC_CL_COLLECTION.v_sub_str);
		  END IF;

		END IF;

		IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN

/*		FOR c_rec IN c1_d LOOP

		UPDATE MSC_RESERVATIONS
		SET RESERVED_QUANTITY= 0,
		    REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		    LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		    LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		WHERE PLAN_ID=  -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND TRANSACTION_ID= c_rec.TRANSACTION_ID;

		END LOOP; */

		FOR c_rec IN c1_d LOOP


		 		If  c_rec.supply_source_type_id = 86 then


    		         Delete from msc_reservations
                                Where
                                    ((reservation_type = 5 and organization_id = c_rec.organization_id)  or reservation_type = 7)
                                And sr_instance_id =c_rec.SR_INSTANCE_ID
                                And plan_id =-1
                               And REPAIR_PO_HEADER_ID  =c_rec.transaction_id ;

        Elsif  c_rec.supply_source_type_id = 1 then

                  	 Delete from msc_reservations
                                    Where  sr_instance_id =c_rec.SR_INSTANCE_ID
                                    And plan_id =-1
                                   And ((disposition_id =c_rec.transaction_id  and reservation_type = 5 and organization_id = c_rec.organization_id and disposition_type =1 )
                                   Or (transaction_id =c_rec.transaction_id  and reservation_type = 7));

        Elsif  c_rec.supply_source_type_id = 7 then

                   	 Delete from msc_reservations
                                    Where  sr_instance_id =c_rec.SR_INSTANCE_ID
                                    And plan_id =-1
                                   And  transaction_id =c_rec.transaction_id
                                   And reservation_type = 4;

        Elsif  c_rec.supply_source_type_id = 200 then

                   	 Delete from msc_reservations
                                    Where  sr_instance_id =c_rec.SR_INSTANCE_ID
                                    And plan_id =-1
                                    And ((disposition_id =c_rec.transaction_id  and reservation_type = 4 and disposition_type =200 and organization_id = c_rec.organization_id)
                                    Or (transaction_id =c_rec.transaction_id  and reservation_type = 3));



        Elsif  c_rec.supply_source_type_id = 2 then

                   	 Delete from msc_reservations
                                    Where  sr_instance_id =c_rec.SR_INSTANCE_ID
                                    And plan_id =-1
                                    And disposition_id =c_rec.transaction_id
                                    And reservation_type in (7,3)
                                    And disposition_type =2
                                    And organization_id = c_rec.organization_id  ;

        Elsif  c_rec.supply_source_type_id = 5 then

                   	 Delete from msc_reservations
                                    Where  sr_instance_id =c_rec.SR_INSTANCE_ID
                                    And plan_id =-1
                                    And transaction_id/2 = c_rec.transaction_id
                                    And reservation_type = 5 ;

        Else

             --     IF c_rec.supply_source_type_id IS NULL AND c_rec.reservation_type is NULL THEN

            	       UPDATE MSC_RESERVATIONS
                    		SET RESERVED_QUANTITY= 0,
                    		    REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
                    		    LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
                    		    LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
                    		WHERE PLAN_ID=  -1
                    		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
                    		  AND TRANSACTION_ID= c_rec.TRANSACTION_ID;

            --      END IF;
        END IF ;
		END LOOP;

		END IF;

		c_count:= 0;

		FOR c_rec IN c1 LOOP

		BEGIN

		IF MSC_CL_COLLECTION.v_is_incremental_refresh THEN



		UPDATE MSC_RESERVATIONS
		SET
		  INVENTORY_ITEM_ID=  c_rec.INVENTORY_ITEM_ID,
		  ORGANIZATION_ID=  c_rec.ORGANIZATION_ID,
		  DEMAND_CLASS=  c_rec.DEMAND_CLASS,
		  RESERVED_QUANTITY=  c_rec.RESERVED_QUANTITY,
		  NONNET_QUANTITY_RESERVED=  0,
		  DISPOSITION_ID=  c_rec.DISPOSITION_ID,
		  DISPOSITION_TYPE=  c_rec.DISPOSITION_TYPE,
		  RESERVATION_TYPE= c_rec.RESERVATION_TYPE,
		  PARENT_DEMAND_ID=  c_rec.PARENT_DEMAND_ID,
		  RESERVATION_DATE=  c_rec.REQUIREMENT_DATE,
		  REQUIREMENT_DATE=  c_rec.REQUIREMENT_DATE,
		  PROJECT_ID=  c_rec.PROJECT_ID,
		  TASK_ID=  c_rec.TASK_ID,
		  REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		  LAST_UPDATE_DATE=  MSC_CL_COLLECTION.v_current_date,
		  LAST_UPDATED_BY=  MSC_CL_COLLECTION.v_current_user,
		  SUPPLY_SOURCE_HEADER_ID = c_rec.SUPPLY_SOURCE_HEADER_ID,
		  SUPPLY_SOURCE_TYPE_ID = c_rec.SUPPLY_SOURCE_TYPE_ID,
		  REPAIR_PO_HEADER_ID = c_rec.REPAIR_PO_HEADER_ID         -- Chenges FOr Bug 5996327
		WHERE PLAN_ID=  -1
		  AND SR_INSTANCE_ID= c_rec.SR_INSTANCE_ID
		  AND TRANSACTION_ID= c_rec.TRANSACTION_ID
      AND RESERVATION_TYPE = NVL(c_rec.RESERVATION_TYPE,RESERVATION_TYPE); -- Changes FOr Bug 5988024
		                  -- Changed to NVL For Bug 6144734 as Non SRP Reservations would have Reservation_type NULL
		END IF;

		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) OR SQL%NOTFOUND THEN



		insert into MSC_RESERVATIONS
		 ( TRANSACTION_ID,
		   INVENTORY_ITEM_ID,
		   ORGANIZATION_ID,
		   PLAN_ID,
		   DEMAND_CLASS,
		   RESERVED_QUANTITY,
		   NONNET_QUANTITY_RESERVED,
		   DISPOSITION_ID,
		   DISPOSITION_TYPE,
		   RESERVATION_TYPE, -- Changes FOr Bug 5988024
		   PARENT_DEMAND_ID,
		   RESERVATION_DATE,
		   REQUIREMENT_DATE,
		   PROJECT_ID,
		   TASK_ID,
		   SR_INSTANCE_ID,
		   REFRESH_NUMBER,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATION_DATE,
		   CREATED_BY,
		   SUPPLY_SOURCE_HEADER_ID,
		   SUPPLY_SOURCE_TYPE_ID,
       REPAIR_PO_HEADER_ID )
		VALUES
		 ( c_rec.TRANSACTION_ID,
		   c_rec.INVENTORY_ITEM_ID,
		   c_rec.ORGANIZATION_ID,
		   -1,
		   c_rec.DEMAND_CLASS,
		   c_rec.RESERVED_QUANTITY,
		   0,
		   c_rec.DISPOSITION_ID,
		   c_rec.DISPOSITION_TYPE,
		   c_rec.RESERVATION_TYPE, -- Changes FOr Bug 5988024
		   c_rec.PARENT_DEMAND_ID,
		   c_rec.REQUIREMENT_DATE,
		   c_rec.REQUIREMENT_DATE,
		   c_rec.PROJECT_ID,
		   c_rec.TASK_ID,
		   c_rec.SR_INSTANCE_ID,
		   MSC_CL_COLLECTION.v_last_collection_id,
		   MSC_CL_COLLECTION.v_current_date,
		   MSC_CL_COLLECTION.v_current_user,
		   MSC_CL_COLLECTION.v_current_date,
		   MSC_CL_COLLECTION.v_current_user,
		   c_rec.SUPPLY_SOURCE_HEADER_ID,
		   c_rec.SUPPLY_SOURCE_TYPE_ID ,
       c_rec.REPAIR_PO_HEADER_ID);  -- Chengs For Bug 5996327

		END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_HARD_RESERVATION');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESERVATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE

		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_HARD_RESERVATION');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_RESERVATIONS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'MSC_CL_ITEM_ODS_LOAD.ITEM_NAME');
		      FND_MESSAGE.SET_TOKEN('VALUE', MSC_CL_ITEM_ODS_LOAD.ITEM_NAME( c_rec.INVENTORY_ITEM_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'TRANSACTION_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.TRANSACTION_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'DISPOSITION_ID');
		      FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(c_rec.DISPOSITION_ID));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

   END LOAD_HARD_RESERVATION;

--==================================================================

   PROCEDURE LOAD_DESIGNATOR IS

   CURSOR c1 IS
		SELECT
		  msd.DESIGNATOR,
		  msd.ORGANIZATION_ID,
		  msd.MPS_RELIEF,
		  msd.INVENTORY_ATP_FLAG,
		  msd.DESCRIPTION,
		  msd.DISABLE_DATE,
		  msd.DEMAND_CLASS,
		  msd.ORGANIZATION_SELECTION,
		  msd.PRODUCTION,
		  msd.RECOMMENDATION_RELEASE,
		  msd.DESIGNATOR_TYPE,
		  msd.SR_INSTANCE_ID
		FROM MSC_ST_DESIGNATORS msd
		WHERE msd.SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		AND   designator_type <> 6;

		   c_count NUMBER:= 0;
		   lv_sql_stmt 	VARCHAR2(5000);

		   BEGIN


		IF (MSC_CL_COLLECTION.v_is_complete_refresh OR MSC_CL_COLLECTION.v_is_partial_refresh) THEN

		     /*UPDATE MSC_DESIGNATORS
		     SET   DISABLE_DATE= MSC_CL_COLLECTION.v_current_date,
		           REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		           LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		           LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		     WHERE SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		     AND   designator_type <> 6             --  Added This condition for Bug# 2022521
		     AND   COLLECTED_FLAG= MSC_UTIL.SYS_YES; */


		      lv_sql_stmt:=   'UPDATE MSC_DESIGNATORS '
		                    ||' SET   DISABLE_DATE    = :v_current_date, '
		                    ||'      REFRESH_NUMBER  = :v_last_collection_id, '
		                    ||'      LAST_UPDATE_DATE= :v_current_date, '
		                    ||'      LAST_UPDATED_BY = :v_current_user '
		                    ||' WHERE SR_INSTANCE_ID  = :v_instance_id '
		                    ||' AND( (designator_type = (select decode(mds,1,1,-1) '
		                    ||'           from msc_coll_parameters '
		                    ||'           where instance_id = :v_instance_id)) '
				    ||'	OR '
				    ||'(designator_type = (select decode(mps,1,2,-1) '
		                    ||'           from msc_coll_parameters '
		                    ||'           where instance_id = :v_instance_id)) '
				    ||'	) '
		                    ||' AND   COLLECTED_FLAG  =  '||MSC_UTIL.SYS_YES;

		  if MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS then

		     EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_last_collection_id,
		                                         MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_current_user,
		                                         MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_id;
		  else
		    lv_sql_stmt :=lv_sql_stmt||' AND ORGANIZATION_ID '||MSC_UTIL.v_in_org_str;

		    EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_last_collection_id,
		                                         MSC_CL_COLLECTION.v_current_date,
		                                         MSC_CL_COLLECTION.v_current_user,
		                                         MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_id,MSC_CL_COLLECTION.v_instance_id;

		  end if;

		END IF;

		c_count:= 0;

		FOR c_rec IN c1 LOOP

		BEGIN

		UPDATE MSC_DESIGNATORS
		SET
		 SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id,
		 MPS_RELIEF= c_rec.MPS_RELIEF,
		 INVENTORY_ATP_FLAG= c_rec.INVENTORY_ATP_FLAG,
		 DESCRIPTION= c_rec.DESCRIPTION,
		 DISABLE_DATE= c_rec.DISABLE_DATE,
		 DEMAND_CLASS= c_rec.DEMAND_CLASS,
		 ORGANIZATION_SELECTION= c_rec.ORGANIZATION_SELECTION,
		 PRODUCTION= c_rec.PRODUCTION,
		 RECOMMENDATION_RELEASE= c_rec.RECOMMENDATION_RELEASE,
		 DESIGNATOR_TYPE= c_rec.DESIGNATOR_TYPE,
		 REFRESH_NUMBER= MSC_CL_COLLECTION.v_last_collection_id,
		 LAST_UPDATE_DATE= MSC_CL_COLLECTION.v_current_date,
		 LAST_UPDATED_BY= MSC_CL_COLLECTION.v_current_user
		WHERE DESIGNATOR= c_rec.DESIGNATOR
		  AND ORGANIZATION_ID= c_rec.ORGANIZATION_ID
		  AND SR_INSTANCE_ID= MSC_CL_COLLECTION.v_instance_id
		  AND COLLECTED_FLAG= MSC_UTIL.SYS_YES;

		IF SQL%NOTFOUND THEN

		INSERT INTO MSC_DESIGNATORS
		( DESIGNATOR_ID,
		  DESIGNATOR,
		  ORGANIZATION_ID,
		  MPS_RELIEF,
		  INVENTORY_ATP_FLAG,
		  DESCRIPTION,
		  DISABLE_DATE,
		  DEMAND_CLASS,
		  ORGANIZATION_SELECTION,
		  PRODUCTION,
		  RECOMMENDATION_RELEASE,
		  DESIGNATOR_TYPE,
		  COLLECTED_FLAG,
		  SR_INSTANCE_ID,
		  REFRESH_NUMBER,
		  LAST_UPDATE_DATE,
		  LAST_UPDATED_BY,
		  CREATION_DATE,
		  CREATED_BY)
		VALUES
		( MSC_DESIGNATORS_S.NEXTVAL,
		  c_rec.DESIGNATOR,
		  c_rec.ORGANIZATION_ID,
		  c_rec.MPS_RELIEF,
		  c_rec.INVENTORY_ATP_FLAG,
		  c_rec.DESCRIPTION,
		  c_rec.DISABLE_DATE,
		  c_rec.DEMAND_CLASS,
		  c_rec.ORGANIZATION_SELECTION,
		  c_rec.PRODUCTION,
		  c_rec.RECOMMENDATION_RELEASE,
		  c_rec.DESIGNATOR_TYPE,
		  MSC_UTIL.SYS_YES,
		  c_rec.SR_INSTANCE_ID,
		  MSC_CL_COLLECTION.v_last_collection_id,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user,
		  MSC_CL_COLLECTION.v_current_date,
		  MSC_CL_COLLECTION.v_current_user );

		END IF;

		  c_count:= c_count+1;

		  IF c_count> MSC_CL_COLLECTION.PBS THEN
		     COMMIT;
		     c_count:= 0;
		  END IF;

		EXCEPTION
		   WHEN OTHERS THEN

		    IF SQLCODE IN (-01683,-01653,-01650,-01562) THEN

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DESIGNATOR');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DESIGNATORS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		      RAISE;

		    ELSE
		      MSC_CL_COLLECTION.v_warning_flag := MSC_UTIL.SYS_YES;

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, '========================================');
		      FND_MESSAGE.SET_NAME('MSC', 'MSC_OL_DATA_ERR_HEADER');
		      FND_MESSAGE.SET_TOKEN('PROCEDURE', 'LOAD_DESIGNATOR');
		      FND_MESSAGE.SET_TOKEN('TABLE', 'MSC_DESIGNATORS');
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'ORGANIZATION_CODE');
		      FND_MESSAGE.SET_TOKEN('VALUE',
		                            MSC_GET_NAME.ORG_CODE( c_rec.ORGANIZATION_ID,
		                                                   MSC_CL_COLLECTION.v_instance_id));
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      FND_MESSAGE.SET_NAME('MSC','MSC_OL_DATA_ERR_DETAIL');
		      FND_MESSAGE.SET_TOKEN('COLUMN', 'DESIGNATOR');
		      FND_MESSAGE.SET_TOKEN('VALUE', c_rec.DESIGNATOR);
		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, FND_MESSAGE.GET);

		      MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		    END IF;

		END;

		END LOOP;

		COMMIT;

   END LOAD_DESIGNATOR;

   PROCEDURE LOAD_ODS_DEMAND  IS

   lv_temp_demand_tbl       VARCHAR2(30);
   lv_sql_stmt              VARCHAR2(5000);
   lv_sql_stmt1             VARCHAR2(5000);
   lv_sql_stmt2             VARCHAR2(5000);
   lv_where_clause          VARCHAR2(2000);

   BEGIN

   lv_temp_demand_tbl  := 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
   lv_sql_stmt:=
       'INSERT INTO '||lv_temp_demand_tbl
        ||' SELECT * from MSC_DEMANDS '
        ||'  WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
        ||'    AND plan_id = -1 '
        ||'    AND origination_type NOT IN (';

--   MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, 'PREC Flag is ' || TO_CHAR(MSC_CL_COLLECTION.v_coll_prec.mds_flag));

--   MSC_CL_PULL.GET_DEPOT_ORG_STRINGS(MSC_CL_COLLECTION.v_instance_id);       -- For Bug 5909379
--   MSC_UTIL.v_depot_org_str     := MSC_CL_PULL.g_depot_org_str;
--   MSC_UTIL.v_non_depot_org_str := MSC_CL_PULL.g_non_depot_org_str;


   IF MSC_CL_COLLECTION.v_coll_prec.mds_flag = MSC_UTIL.SYS_YES THEN
      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
         if (MSC_CL_COLLECTION.v_coll_prec.mds_sn_flag = MSC_UTIL.SYS_TGT) then
            lv_where_clause := '6,7,8,15,24';
         end if;
      else
         lv_where_clause := '6,7,8,15,24';
      end if;
   END IF;


   IF (MSC_CL_COLLECTION.v_coll_prec.payback_demand_supply_flag = MSC_UTIL.SYS_YES) THEN
      IF (lv_where_clause IS NULL)  THEN
           lv_where_clause :=  '27';
      ELSE
           lv_where_clause := lv_where_clause||', 27';
      END IF;
   END IF;

   IF (MSC_CL_COLLECTION.v_coll_prec.wip_flag = MSC_UTIL.SYS_YES) THEN
      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
         if (MSC_CL_COLLECTION.v_coll_prec.wip_sn_flag = MSC_UTIL.SYS_TGT) then
            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '2,3,4,25,50';
            ELSE
               lv_where_clause := lv_where_clause||', 2,3,4,25,50';
            END IF;
         end if;
      else
         IF (lv_where_clause IS NULL)  THEN
            lv_where_clause :=  '2,3,4,25,50';
         ELSE
            lv_where_clause := lv_where_clause||', 2,3,4,25,50';
         END IF;
      end if;
   END IF;

   IF (MSC_CL_COLLECTION.v_coll_prec.forecast_flag = MSC_UTIL.SYS_YES) THEN
      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
         if (MSC_CL_COLLECTION.v_coll_prec.fcst_sn_flag = MSC_UTIL.SYS_TGT) then
            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '29';
            ELSE
               lv_where_clause := lv_where_clause||', 29';
            END IF;
         end if;
      else
         IF (lv_where_clause IS NULL)  THEN
            lv_where_clause :=  '29';
         ELSE
            lv_where_clause := lv_where_clause||', 29';
         END IF;
      end if;
   END IF;

   IF (MSC_CL_COLLECTION.v_coll_prec.user_supply_demand_flag = MSC_UTIL.SYS_YES) THEN
      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
         if (MSC_CL_COLLECTION.v_coll_prec.udmd_sn_flag = MSC_UTIL.SYS_TGT) then
            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '42';
            ELSE
               lv_where_clause := lv_where_clause||', 42';
            END IF;
         end if;
      else
         IF (lv_where_clause IS NULL)  THEN
            lv_where_clause :=  '42';
         ELSE
            lv_where_clause := lv_where_clause||', 42';
         END IF;
      end if;
   END IF;




   IF (MSC_CL_COLLECTION.v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_YES) THEN

      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
            NULL;
      Else

            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '77';
            ELSE
               lv_where_clause := lv_where_clause||', 77';
            END IF;


      end if;
  END IF;     -- Additions for 5909379 for SRP

 IF (MSC_CL_COLLECTION.v_coll_prec.external_repair_flag = MSC_UTIL.SYS_YES) THEN

      if (MSC_CL_COLLECTION.v_is_cont_refresh) then
            NULL;
      Else

            IF (lv_where_clause IS NULL)  THEN
               lv_where_clause :=  '77';
            ELSE
               lv_where_clause := lv_where_clause||', 77';
            END IF;


      end if;
   END IF;     -- Additions for 5909379 for SRP

   lv_sql_stmt := lv_sql_stmt||lv_where_clause ||' )';

   IF MSC_CL_COLLECTION.v_coll_prec.org_group_flag = MSC_UTIL.G_ALL_ORGANIZATIONS THEN
      null;
   ELSE

      lv_sql_stmt1:=  ' UNION ALL '
                    ||' SELECT * from MSC_DEMANDS '
                    ||' WHERE sr_instance_id = '||MSC_CL_COLLECTION.v_instance_id
                    ||'  AND plan_id = -1 '
                    ||'  AND organization_id NOT '||MSC_UTIL.v_in_org_str
                    ||'  AND origination_type IN (';

      lv_sql_stmt1 := lv_sql_stmt1||lv_where_clause ||' )';



      if NOT (MSC_CL_COLLECTION.v_is_complete_refresh) then
        lv_sql_stmt :=lv_sql_stmt||lv_sql_stmt1;
      else
        lv_sql_stmt := lv_sql_stmt||' AND organization_id NOT '||MSC_UTIL.v_in_org_str;

        lv_sql_stmt :=lv_sql_stmt||lv_sql_stmt1;
      end if;

   END IF;


   EXECUTE IMMEDIATE lv_sql_stmt;

   COMMIT;

   -- Added For SRP Bug 5935273
   ---------------------------------------
		   IF NOT MSC_CL_COLLECTION.v_is_complete_refresh  THEN   -- This part of the code should be called only fro Targeted Colelction of repair orders



		   IF (MSC_CL_COLLECTION.v_coll_prec.external_repair_flag = MSC_UTIL.SYS_YES)  AND  (MSC_CL_COLLECTION.v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_NO) AND (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN

		      lv_sql_stmt2 := 'INSERT INTO '||lv_temp_demand_tbl
		        ||' SELECT * from MSC_DEMANDS  Where origination_type =77 and organization_id  '||MSC_UTIL.v_depot_org_str;

		       EXECUTE IMMEDIATE lv_sql_stmt2;

		      Commit ;
		   END if ;

		   IF (MSC_CL_COLLECTION.v_coll_prec.external_repair_flag = MSC_UTIL.SYS_NO)  AND  (MSC_CL_COLLECTION.v_coll_prec.internal_repair_flag = MSC_UTIL.SYS_YES) AND (MSC_UTIL.G_COLLECT_SRP_DATA = 'Y') THEN

		    lv_sql_stmt2 := 'INSERT INTO '||lv_temp_demand_tbl
		        ||' SELECT * from MSC_DEMANDS  Where origination_type =77 and organization_id  '||MSC_UTIL.v_non_depot_org_str;

		       EXECUTE IMMEDIATE lv_sql_stmt2;

		      Commit ;
		   END if ;
		 END IF;

		------------------------------------------

		   EXCEPTION
		     WHEN OTHERS THEN
		         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS, SQLERRM);
		         RAISE;

		   END LOAD_ODS_DEMAND;

PROCEDURE LOAD_PAYBACK_DEMANDS IS
   lv_tbl      VARCHAR2(30);
   lv_sql_ins  VARCHAR2(32767);
   LV_SUPPLY_TBL VARCHAR2(1000);
BEGIN

IF MSC_CL_COLLECTION.v_exchange_mode=MSC_UTIL.SYS_YES THEN
   lv_tbl:= 'DEMANDS_'||MSC_CL_COLLECTION.v_instance_code;
ELSE
   lv_tbl:= 'MSC_DEMANDS';
END IF;


lv_sql_ins :=
' INSERT INTO '||lv_tbl
||'(	PLAN_ID,
DEMAND_ID,
USING_REQUIREMENT_QUANTITY,
USING_ASSEMBLY_DEMAND_DATE,
DEMAND_TYPE,
ORIGINATION_TYPE,
USING_ASSEMBLY_ITEM_ID,
ORGANIZATION_ID,
INVENTORY_ITEM_ID,
SR_INSTANCE_ID,
PROJECT_ID,
TASK_ID,
PLANNING_GROUP,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
CREATION_DATE,
CREATED_BY)
SELECT
-1 PLAN_ID,
MSC_DEMANDS_S.nextval,
MOP. QUANTITY,
SCHEDULED_PAYBACK_DATE,
1 DEMAND_TYPE,
27 ORIGINATION_TYPE,
MIIL.INVENTORY_ITEM_ID,  -- USING_ASSEMBLY_ITEM_ID
MOP.ORGANIZATION_ID,
MIIL.INVENTORY_ITEM_ID,
MOP.SR_INSTANCE_ID,
MOP.BORROW_PROJECT_ID,
MOP.BORROW_TASK_ID,
MOP.PLANNING_GROUP,
:v_current_date,
:v_current_user,
:v_current_date,
:v_current_user
FROM 	MSC_ST_OPEN_PAYBACKS MOP, MSC_ITEM_ID_LID MIIL
WHERE MIIL.SR_INVENTORY_ITEM_ID =  MOP.inventory_item_id
  AND MIIL.sr_instance_id       =  MOP.sr_instance_id
  AND MOP.sr_instance_id 	  = :v_instance_id';
  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,lv_sql_ins);
EXECUTE IMMEDIATE lv_sql_ins
USING MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user,
      MSC_CL_COLLECTION.v_current_date,
      MSC_CL_COLLECTION.v_current_user,
      MSC_CL_COLLECTION.v_instance_id;
MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,'rows inserted :- '||SQL%ROWCOUNT);

COMMIT;

END LOAD_PAYBACK_DEMANDS;

END MSC_CL_DEMAND_ODS_LOAD;

/
