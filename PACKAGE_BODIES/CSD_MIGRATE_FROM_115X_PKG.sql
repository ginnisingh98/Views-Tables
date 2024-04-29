--------------------------------------------------------
--  DDL for Package Body CSD_MIGRATE_FROM_115X_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_MIGRATE_FROM_115X_PKG" AS
/* $Header: csdmig1b.pls 115.10 2004/05/07 02:21:38 saupadhy ship $ */

PROCEDURE csd_repairs_mig(p_slab_number IN NUMBER DEFAULT 1) IS

  Type NumTabType is VARRAY(10000) of NUMBER;
  repair_line_id_mig             NumTabType;

  Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
  rowid_mig                      RowidTabtype;

  v_min                    NUMBER;
  v_max                    NUMBER;
  v_error_text             VARCHAR2(2000);
  MAX_BUFFER_SIZE          NUMBER := 500;

  error_process             exception;

  CURSOR csd_repairs_cursor (p_start number, p_end number) is
  select cr.repair_line_id,
         cr.rowid
  from   csd_repairs cr
  where  cr.repair_mode IS NULL
   and   cr.repair_line_id >= p_start
   and   cr.repair_line_id <= p_end;

BEGIN

  -- Get the Slab Number for the table
  Begin
	   CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CSD_REPAIRS'
      							  ,'CSD'
							       ,p_slab_number
							       ,v_min
							       ,v_max);
        if v_min is null then
            return;
    	   end if;
  End;

  -- Migration code for CSD_REPAIRS
   OPEN csd_repairs_cursor(v_min,v_max);
   LOOP
      FETCH csd_repairs_cursor bulk collect into
                     repair_line_id_mig,
                     rowid_mig
                     LIMIT MAX_BUFFER_SIZE;

        FOR j in 1..repair_line_id_mig.count
	   LOOP
          SAVEPOINT CSD_REPAIRS;
          Begin
               UPDATE csd_repairs
               SET   repair_mode = 'WIP',
	                auto_process_rma    = 'N',
				 last_update_date    = sysdate,
				 last_updated_by     = fnd_global.user_id,
				 last_update_login   = fnd_global.login_id
               WHERE  rowid = rowid_mig(j);
               IF SQL%NOTFOUND then
                  Raise error_process;
			End If;
          Exception
		  When error_process then
                 ROLLBACK to CSD_REPAIRS;
                 v_error_text := substr(sqlerrm,1,1000)||'Repair Line Id:'||repair_line_id_mig(j);
                 INSERT INTO CSD_UPG_ERRORS
		          (ORIG_SYSTEM_REFERENCE,
          	      TARGET_SYSTEM_REFERENCE,
		           ORIG_SYSTEM_REFERENCE_ID,
		           UPGRADE_DATETIME,
		           ERROR_MESSAGE,
		           MIGRATION_PHASE)
                 VALUES( 'CSD_REPAIRS'
          	     ,'CSD_REPAIRS'
	     	     ,repair_line_id_mig(j)
		          ,sysdate
	               ,v_error_text
	      	     ,'11.5.8'  );

				  commit;

                  raise_application_error( -20000, 'Error while migrating CSD_REPAIRS table data: Error while updating CSD_REPAIRS. '|| v_error_text);


          End;
	   END LOOP;

      COMMIT;
      EXIT WHEN csd_repairs_cursor%notfound;
    END LOOP;

    if csd_repairs_cursor%isopen then
       close csd_repairs_cursor;
    end if;

    COMMIT;

END csd_repairs_mig;


PROCEDURE csd_product_txn_lines_mig (p_slab_number IN NUMBER DEFAULT 1) IS

  l_booked_flag            BOOLEAN;
  l_skip_flag              BOOLEAN;
  l_estimate_status        varchar2(30);
  l_uom                    varchar2(30) := 'DAY';
  l_dummy                  varchar2(1);
  v_min                    NUMBER;
  v_max                    NUMBER;

  Type NumTabType is VARRAY(10000) of NUMBER;
  estimate_detail_id_mig             NumTabType;
  source_id_mig                      NumTabType;
  order_header_id_mig                NumTabType;
  order_line_id_mig                  NumTabType;
  quantity_required_mig              NumTabType;
  repair_type_id_mig                 NumTabType;

  Type DateTabType is VARRAY(1000) of Date;
    creation_date_mig           DateTabType;

  Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
  rowid_mig                      RowidTabtype;


  l_repair_estimate_id     CSD_REPAIR_ESTIMATE_LINES.REPAIR_ESTIMATE_ID%TYPE;
  l_estimate_detail_id     CSD_REPAIR_ESTIMATE_LINES.ESTIMATE_DETAIL_ID%TYPE;
  l_creation_date          DATE;

  l_rma                    varchar2(30) := 'RMA';
  l_ship                   varchar2(30) := 'SHIP';
  l_cust_prod              varchar2(30) := 'CUST_PROD';

  l_ACTION_TYPE            CSD_PRODUCT_TRANSACTIONS.ACTION_TYPE%TYPE;
  l_ACTION_CODE            CSD_PRODUCT_TRANSACTIONS.ACTION_CODE%TYPE;
  l_INTERFACE_TO_OM_FLAG   CSD_PRODUCT_TRANSACTIONS.INTERFACE_TO_OM_FLAG%TYPE;
  l_BOOK_SALES_ORDER_FLAG  CSD_PRODUCT_TRANSACTIONS.BOOK_SALES_ORDER_FLAG%TYPE;
  l_RELEASE_SALES_ORDER_FLAG CSD_PRODUCT_TRANSACTIONS.RELEASE_SALES_ORDER_FLAG%TYPE;
  l_SHIP_SALES_ORDER_FLAG  CSD_PRODUCT_TRANSACTIONS.SHIP_SALES_ORDER_FLAG%TYPE;
  l_PROD_TXN_STATUS        CSD_PRODUCT_TRANSACTIONS.PROD_TXN_STATUS%TYPE;
  l_PROD_TXN_CODE          CSD_PRODUCT_TRANSACTIONS.PROD_TXN_CODE%TYPE;

  l_repair_line_id         Number;
  l_released_status        varchar2(1);
  l_repair_type_ref        varchar2(30);
  l_ENTERED                varchar2(30) := 'ENTERED';
  l_SUBMITTED              varchar2(30) := 'SUBMITTED';
  l_BOOKED                 varchar2(30) := 'BOOKED';
  l_RELEASED               varchar2(30) := 'RELEASED';
  l_SHIPPED                varchar2(30) := 'SHIPPED';

  error_process             exception;
  v_error_text             VARCHAR2(2000);
  MAX_BUFFER_SIZE          NUMBER := 500;

  CURSOR PRODUCT_TXN_LINES (p_start number,
       		             p_end   number ) IS
  select ced.estimate_detail_id,
         ced.source_id,
         ced.order_header_id,
         ced.order_line_id,
         ced.quantity_required,
         ced.creation_date,
         cra.repair_type_id,
	    ced.rowid
    from cs_estimate_details ced,
         csd_repairs cra
   where ced.source_id = cra.repair_line_id
     and ced.inventory_item_id = cra.inventory_item_id
     and ced.source_code = 'DR'
     and not exists ( select '*' from csd_product_transactions cpt
                      where cpt.estimate_detail_id = ced.estimate_detail_id)
     and not exists ( select '*' from csd_repair_estimate_lines crel
                      where crel.estimate_detail_id = ced.estimate_detail_id)
     and ced.estimate_detail_id >= p_start
	and ced.estimate_detail_id <= p_end;
      -- Shiv Ragunathan, 11/19/03, Added the above 'not exists' clause to
     -- prevent data in cs_estimate_details from being migrated,
     -- if this was created from Depot Repair in 11.5.8. IN 11.5.7, this
     -- was not possible. This is introduced as this code is also run,
     -- when upgrading from 11.5.8 ( or 11.5.9 ) as well.

-- Following cursor gets all the delivery line for a given order header id and order line id
-- Bug# 3615184
 Cursor Delivery_line_Status_cur( p_Order_Header_id Number, p_Order_line_id Number) Is
    Select Released_Status
    From Wsh_Delivery_Details
    Where source_header_id = p_order_Header_id
    and   source_line_id   = p_order_line_id ;
   l_prod_txn_line_released_flag Varchar2(1) ;
   l_prod_txn_line_shipped_flag Varchar2(1) ;

BEGIN

  -- Get the Slab Number for the table
  Begin
	   CSD_MIG_SLABS_PKG.GET_TABLE_SLABS('CS_ESTIMATE_DETAILS'
      			                     ,'CSD'
					                ,p_slab_number
					                ,v_min
					                ,v_max);
    	   if v_min is null then
	          return;
    	   end if;
  End;


  OPEN PRODUCT_TXN_LINES(v_min,v_max);
  LOOP

      FETCH PRODUCT_TXN_LINES bulk collect into
                     estimate_detail_id_mig,
                     source_id_mig,
                     order_header_id_mig,
                     order_line_id_mig,
                     quantity_required_mig,
                     creation_date_mig,
                     repair_type_id_mig,
				 rowid_mig
                     LIMIT MAX_BUFFER_SIZE;

      -- Migrate csd_product_transactions
      FOR j in 1..estimate_detail_id_mig.count
      LOOP
         Begin

		 SAVEPOINT product_txn;

           l_repair_line_id     := source_id_mig(j);
           l_estimate_detail_id := estimate_detail_id_mig(j);
           l_action_code        := l_cust_prod;
           l_prod_txn_code      := 'PRE';
           l_creation_date      := creation_date_mig(j);

           IF quantity_required_mig(j) > 0 then
             l_action_type      := l_ship;
           Else
             l_action_type      := l_rma;
           End IF;

           IF order_header_id_mig(j) is null then
              l_INTERFACE_TO_OM_FLAG  := 'N';
              l_BOOK_SALES_ORDER_FLAG := 'N';
              l_RELEASE_SALES_ORDER_FLAG := 'N';
              l_SHIP_SALES_ORDER_FLAG := 'N';
              l_PROD_TXN_STATUS       := l_entered;
           Else
              l_INTERFACE_TO_OM_FLAG  := 'Y';
              l_PROD_TXN_STATUS       := l_submitted;
      	 END IF;

           Begin
              Select 'x'
               into  l_dummy
               from  oe_order_headers_all
              where  header_id = order_header_id_mig(j)
               and   booked_flag = 'Y';
                 l_booked_flag := TRUE;
           Exception
               When No_data_found then
                 l_booked_flag := FALSE;
           End ;

           If NOT(l_booked_flag) then
              l_BOOK_SALES_ORDER_FLAG := 'N';
              l_RELEASE_SALES_ORDER_FLAG := 'N';
              l_SHIP_SALES_ORDER_FLAG := 'N';
           Else
              l_BOOK_SALES_ORDER_FLAG := 'Y';
              l_PROD_TXN_STATUS       := l_booked;

    		    IF quantity_required_mig(j) > 0 then
                  Begin
			       -- To fix bug 3615184 added following lines.
				  -- Released_Status column can have following values in 11.5.7
				  -- Released_Status = 'Y' means Pick Released
				  -- Released_Status = 'B' means Back Ordered
				  -- Released_Status = 'S' means Released To Warehouse
				  -- Released_Status = 'C' means Interfaced or shipped
				  -- Released_Status = 'R' Ready to Release
				  -- Released_Status = 'N' Not Ready to Release
				  --
                      -- Initialize these variables to Null before using them
                      l_prod_txn_line_released_flag := Null;
                      l_prod_txn_line_shipped_flag := Null;
				  For Delivery_line_Status_Rec In Delivery_line_Status_cur
				        (Order_Header_Id_mig(j), Order_line_id_mig(j)) Loop
					If Delivery_Line_Status_Rec.Released_Status = 'C' Then
                            l_prod_txn_line_shipped_flag := 'Y';
					ElsIf Delivery_Line_Status_Rec.Released_Status in ( 'Y','B','S') Then
                            l_prod_txn_line_released_flag := 'Y';
                         End if;
			       End Loop;
                      If l_prod_txn_line_released_flag = 'Y' then
                        l_RELEASE_SALES_ORDER_FLAG := 'Y';
                        l_SHIP_SALES_ORDER_FLAG    := 'N';
                        l_PROD_TXN_STATUS          := l_released;
                      ElsIf l_prod_txn_line_Shipped_flag = 'Y' then
                        l_RELEASE_SALES_ORDER_FLAG := 'Y';
                        l_SHIP_SALES_ORDER_FLAG    := 'Y';
                        l_PROD_TXN_STATUS          := l_shipped;
                      Else
                        l_RELEASE_SALES_ORDER_FLAG := 'N';
                        l_SHIP_SALES_ORDER_FLAG    := 'N';
                        l_PROD_TXN_STATUS          := l_booked;
                      End If;
                  End ;
              End If;
              /*************
              If l_released_status = 'C' then
                l_RELEASE_SALES_ORDER_FLAG := 'Y';
                l_SHIP_SALES_ORDER_FLAG    := 'Y';
                l_PROD_TXN_STATUS          := l_shipped;
              Elsif l_released_status in ('Y','B','S') then
                l_RELEASE_SALES_ORDER_FLAG := 'Y';
                l_SHIP_SALES_ORDER_FLAG    := 'N';
                l_PROD_TXN_STATUS          := l_released;
              Else
                l_RELEASE_SALES_ORDER_FLAG := 'N';
                l_SHIP_SALES_ORDER_FLAG    := 'N';
                l_PROD_TXN_STATUS          := l_booked;
              End If;
              *************/

           End If;

        Begin
         INSERT INTO CSD_PRODUCT_TRANSACTIONS(
           PRODUCT_TRANSACTION_ID,
           REPAIR_LINE_ID,
           ESTIMATE_DETAIL_ID,
           ACTION_TYPE,
           ACTION_CODE,
           LOT_NUMBER,
           SUB_INVENTORY,
           INTERFACE_TO_OM_FLAG,
           BOOK_SALES_ORDER_FLAG,
           RELEASE_SALES_ORDER_FLAG,
           SHIP_SALES_ORDER_FLAG,
           PROD_TXN_STATUS,
           PROD_TXN_CODE,
           LAST_UPDATE_DATE,
           CREATION_DATE,
           LAST_UPDATED_BY,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CONTEXT,
           OBJECT_VERSION_NUMBER
          ) VALUES (
           CSD_PRODUCT_TRANSACTIONS_S1.nextval
           ,l_repair_line_id
           ,l_estimate_detail_id
           ,l_action_type
           ,l_action_code
           ,NULL
           ,NULL
           ,l_interface_to_om_flag
           ,l_book_sales_order_flag
           ,l_release_sales_order_flag
           ,l_ship_sales_order_flag
           ,l_prod_txn_status
           ,l_prod_txn_code
           ,sysdate
           ,l_creation_date
	      ,FND_GLOBAL.USER_ID
           ,FND_GLOBAL.USER_ID
           ,FND_GLOBAL.LOGIN_ID
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,NULL
           ,1 );

        Exception
		When OTHERS THEN
             v_error_text :=  'Error Msg :'||substr(sqlerrm,1,1000)||'est_detail_id :'||estimate_detail_id_mig(j);
             Raise error_process;
        End;

       Exception
	      When error_process then
                 ROLLBACK to product_txn;
                 INSERT INTO CSD_UPG_ERRORS
		          (ORIG_SYSTEM_REFERENCE,
          	      TARGET_SYSTEM_REFERENCE,
		           ORIG_SYSTEM_REFERENCE_ID,
		           UPGRADE_DATETIME,
		           ERROR_MESSAGE,
		           MIGRATION_PHASE)
                 VALUES(
		       	'CS_ESTIMATE_DETAILS'
          	     ,'CSD_PRODUCT_TRANSACTIONS'
	     	     ,estimate_detail_id_mig(j)
		          ,sysdate
	               ,v_error_text
	      	     ,'11.5.8'  );

			      commit;

                  raise_application_error( -20000, 'Error while migrating CSD_PRODUCT_TRANSACTIONS table data. '|| v_error_text);


	      When others then
                 ROLLBACK to product_txn;
                 v_error_text := 'Err Msg:'||substr(sqlerrm,1,1000)||'Estimate Detail Id:'||estimate_detail_id_mig(j);
                 INSERT INTO CSD_UPG_ERRORS
		          (ORIG_SYSTEM_REFERENCE,
          	      TARGET_SYSTEM_REFERENCE,
		           ORIG_SYSTEM_REFERENCE_ID,
		           UPGRADE_DATETIME,
		           ERROR_MESSAGE,
		           MIGRATION_PHASE)
                 VALUES(
		       	'CS_ESTIMATE_DETAILS'
          	     ,'CSD_PRODUCT_TRANSACTIONS'
	     	     ,estimate_detail_id_mig(j)
		          ,sysdate
	               ,v_error_text
	      	     ,'11.5.8'  );

			      commit;

                  raise_application_error( -20000, 'Error while migrating CSD_PRODUCT_TRANSACTIONS table data. '|| v_error_text);

       End;
     End Loop; --end of for loop

	commit;

	Exit when product_txn_lines%notfound;

   End Loop;

   IF product_txn_lines%isopen then
	  close product_txn_lines;
   END IF;

   COMMIT;

 End Csd_product_txn_lines_mig;


 PROCEDURE CSD_REPAIR_ESTIMATE_MIG (p_slab_number IN NUMBER DEFAULT 1) IS

  TYPE NumArray    IS VARRAY(10000) OF NUMBER;
  TYPE Char3Array  IS VARRAY(10000) OF VARCHAR2(3);
  TYPE Char240Array IS VARRAY(10000) OF VARCHAR2(240);
  TYPE Char30Array IS VARRAY(10000) OF VARCHAR2(30);
  TYPE DateArray   IS VARRAY(10000) OF DATE;

  l_rep_estimate_id_arr    NumArray    := NumArray();
  l_source_id_arr          NumArray    := NumArray();
  l_creation_date_arr      DateArray   := DateArray();
  l_promise_date_arr       DateArray   := DateArray();
  l_summary_arr            Char240Array := Char240Array();
  l_approval_status_arr    Char30Array := Char30Array();

  -- Local counters
  l_array_size             NUMBER;  -- Number of elements in varrays
  l_min_id                 NUMBER;  -- Minimum Repair Line ID
  l_max_id                 NUMBER;  -- Maximum Repair Line ID

  l_dummy                  varchar2(1);
  l_repair_estimate_id     NUMBER;
  l_repair_line_id         NUMBER;
  l_estimate_status        CSD_REPAIR_ESTIMATE.ESTIMATE_STATUS%TYPE;
  l_estimate_date          DATE;
  l_work_summary           CSD_REPAIR_ESTIMATE.WORK_SUMMARY%TYPE;
  l_lead_time              CSD_REPAIR_ESTIMATE.LEAD_TIME%TYPE;
  l_lead_time_uom          CSD_REPAIR_ESTIMATE.LEAD_TIME_UOM%TYPE := 'DAY';
  l_estimate_freeze_flag   CSD_REPAIR_ESTIMATE.ESTIMATE_FREEZE_FLAG%TYPE := 'N';

   v_error_text           VARCHAR2(2000);
   MAX_BUFFER_SIZE        NUMBER := 500;

  -- estimate header cursor
  CURSOR CUR_ESTIMATE_HEADER (p_min_id number, p_max_id number) IS
  select distinct
         ced.source_id,
         cia.summary,
         cra.creation_date,
	    NVL(cra.promise_date, cra.creation_date),
	    cra.approval_status
    from cs_estimate_details ced,
         cs_incidents_all_b cia,
         csd_repairs cra
   where ced.source_id   = cra.repair_line_id
     and ced.incident_id = cia.incident_id
     and ced.inventory_item_id <> cra.inventory_item_id
     and ced.source_code = 'DR'
     and ced.estimate_detail_id >= p_min_id                 -- slab limits
     and ced.estimate_detail_id <= p_max_id                 -- slab limits
     and not exists ( select '*' from csd_repair_estimate cre
                      where cre.repair_line_id = ced.source_id)
     and not exists ( select '*' from csd_product_transactions cpt
                      where cpt.estimate_detail_id = ced.estimate_detail_id);
     -- Shiv Ragunathan, 11/19/03, Added the above 'not exists' clause to
     -- prevent data in cs_estimate_details from being migrated,
     -- if this was created from Depot Repair in 11.5.8. IN 11.5.7, this
     -- was not possible. This is introduced as this code is also run,
     -- when upgrading from 11.5.8 ( or 11.5.9 ) as well.

BEGIN

  -- Initialize Update range boundaries
  csd_mig_slabs_pkg.get_table_slabs ( 'CS_ESTIMATE_DETAILS',
                                      'CSD',
                                       p_slab_number,
                                       l_min_id,
                                       l_max_id);


  IF l_min_id IS NULL THEN
     RETURN;
  END IF;

  -- get default values if needed into variables from cursors
  -- Migrate csd_repair_estimate
  Begin
      select 'x'
       into l_dummy
       from  fnd_lookups
      where lookup_type = 'CSD_UNIT_OF_MEASURE'
        and lookup_code = l_lead_time_uom;
  Exception
     When no_data_found then
       v_error_text := 'No Data found for lookup code'||l_lead_time_uom||'of lookup type CSD_UNIT_OF_MEASURE';
       RAISE_APPLICATION_ERROR(-20000, v_error_text);
  End;

  -- Open main cursor
  OPEN cur_estimate_header( l_min_id, l_max_id );
  LOOP
     -- Start fetch loop.  Use BULK COLLECT option.  Fetch row
     -- columns into PL/SQL arrays.
     FETCH cur_estimate_header
     BULK COLLECT INTO
          l_source_id_arr,
          l_summary_arr,
          l_creation_date_arr,
          l_promise_date_arr,
          l_approval_status_arr
     LIMIT MAX_BUFFER_SIZE;

     -- get total count
     l_array_size := l_source_id_arr.COUNT;

     FOR i IN 1..l_array_size
	LOOP

       SAVEPOINT ESTIMATE_HEADER;

       IF l_approval_status_arr(i) = 'A' then
          l_estimate_status := 'ACCEPTED';
       Elsif l_approval_status_arr(i) = 'R' then
          l_estimate_status := 'REJECTED';
       Else
          l_estimate_status := 'NEW';
       End If;


         l_repair_line_id        := l_source_id_arr(i);
         l_estimate_date         := l_creation_date_arr(i);
         l_work_summary          := NVL(l_summary_arr(i),'Migration');
         l_lead_time             := trunc(l_promise_date_arr(i)-l_creation_date_arr(i));

	    IF l_lead_time = 0 then
            l_lead_time := 1;
	    End If;

     BEGIN
     INSERT INTO CSD_REPAIR_ESTIMATE
	  (   REPAIR_ESTIMATE_ID
          ,REPAIR_LINE_ID
          ,ESTIMATE_STATUS
          ,ESTIMATE_DATE
          ,WORK_SUMMARY
          ,LEAD_TIME
          ,LEAD_TIME_UOM
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,ESTIMATE_FREEZE_FLAG)
	VALUES (
           CSD_REPAIR_ESTIMATE_S1.nextval
          ,l_repair_line_id
          ,l_estimate_status
          ,l_estimate_date
          ,l_work_summary
          ,l_lead_time
          ,l_lead_time_uom
          ,l_estimate_date
          ,FND_GLOBAL.USER_ID
          ,FND_GLOBAL.USER_ID
          ,sysdate
          ,FND_GLOBAL.LOGIN_ID
          ,1
          ,l_estimate_freeze_flag);

     EXCEPTION
        WHEN OTHERS THEN
          v_error_text := substr(SQLERRM,2000);
          ROLLBACK to ESTIMATE_HEADER;
          INSERT INTO csd_upg_errors
                      (orig_system_reference,
                      target_system_reference,
                      orig_system_reference_id,
                      upgrade_datetime,
                      error_message,
                      migration_phase)
              VALUES ('CS_ESTIMATE_DETAILS',
                      'CSD_REPAIR_ESTIMATE',
                      l_repair_line_id,
                      sysdate,
                      v_error_text,
                      '11.5.8');

			commit;

            raise_application_error( -20000, 'Error while migrating CSD_ESTIMATE_DETAILS table data: Error while inserting into CSD_REPAIR_ESTIMATE. '|| v_error_text);


     END ;

   END LOOP;-- end of inner

 COMMIT;

 EXIT WHEN cur_estimate_header%NOTFOUND;

 END LOOP;-- End of outer cursor

 IF cur_estimate_header%isopen THEN
    CLOSE cur_estimate_header;
 END IF;

 COMMIT;
   -- Api body ends here

END CSD_REPAIR_ESTIMATE_MIG;

PROCEDURE CSD_REPAIR_ESTIMATE_LINES_MIG (p_slab_number IN NUMBER DEFAULT 1) IS

  TYPE NumArray    IS VARRAY(10000) OF NUMBER;
  TYPE Char3Array  IS VARRAY(10000) OF VARCHAR2(3);
  TYPE Char15Array IS VARRAY(10000) OF VARCHAR2(15);
  TYPE Char30Array IS VARRAY(10000) OF VARCHAR2(30);
  TYPE DateArray   IS VARRAY(10000) OF DATE;

  l_repair_estimate_id_arr    NumArray    := NumArray();
  l_estimate_detail_id_arr    NumArray    := NumArray();
  l_source_id_arr             NumArray    := NumArray();
  l_order_header_id_arr       NumArray    := NumArray();
  l_order_line_id_arr         NumArray    := NumArray();
  l_creation_date_arr         DateArray   := DateArray();

  -- Local counters
  l_array_size             NUMBER;  -- Number of elements in varrays
  l_min_id                 NUMBER;  -- Minimum Repair Line ID
  l_max_id                 NUMBER;  -- Maximum Repair Line ID

  l_repair_estimate_id     CSD_REPAIR_ESTIMATE_LINES.REPAIR_ESTIMATE_ID%TYPE;
  l_estimate_detail_id     CSD_REPAIR_ESTIMATE_LINES.ESTIMATE_DETAIL_ID%TYPE;
  l_item_cost              CSD_REPAIR_ESTIMATE_LINES.ITEM_COST%TYPE;
  l_creation_date          DATE;

  v_error_text             VARCHAR2(2000);
  MAX_BUFFER_SIZE          NUMBER := 500;

  -- estimate line cursor
  CURSOR CUR_ESTIMATE_LINES (p_min_id number, p_max_id number) IS
  select ced.estimate_detail_id,
         ced.source_id,
         ced.order_header_id,
         ced.order_line_id,
         ced.creation_date,
         cre.repair_estimate_id
    from cs_estimate_details ced,
         csd_repairs cra,
         csd_repair_estimate cre
   where ced.source_id = cra.repair_line_id
     and cra.repair_line_id = cre.repair_line_id
     and ced.inventory_item_id <> cra.inventory_item_id
     and ced.source_code = 'DR'
     and ced.estimate_detail_id >= p_min_id                 -- slab limits
     and ced.estimate_detail_id <= p_max_id                 -- slab limits
     and not exists ( select '*' from csd_repair_estimate_lines crel
                      where crel.estimate_detail_id = ced.estimate_detail_id)
      and not exists ( select '*' from csd_product_transactions cpt
                      where cpt.estimate_detail_id = ced.estimate_detail_id);
     -- Shiv Ragunathan, 11/19/03, Added the above 'not exists' clause to
     -- prevent data in cs_estimate_details from being migrated,
     -- if this was created from Depot Repair in 11.5.8. IN 11.5.7, this
     -- was not possible. This is introduced as this code is also run,
     -- when upgrading from 11.5.8 ( or 11.5.9 ) as well.


BEGIN

  -- Initialize Update range boundaries
  csd_mig_slabs_pkg.get_table_slabs ( 'CS_ESTIMATE_DETAILS',
                                      'CSD',
                                       p_slab_number,
                                       l_min_id,
                                       l_max_id);


  IF l_min_id IS NULL THEN
     RETURN;
  END IF;

  -- get default values if needed into variables from cursors
  -- Migrate csd_repair_estimate

  -- Open main cursor
  OPEN cur_estimate_lines( l_min_id, l_max_id );

  LOOP
     -- Start fetch loop.  Use BULK COLLECT option.  Fetch row
     -- columns into PL/SQL arrays.
     FETCH cur_estimate_lines
     BULK COLLECT INTO
         l_estimate_detail_id_arr,
         l_source_id_arr,
         l_order_header_id_arr,
         l_order_line_id_arr,
         l_creation_date_arr,
         l_repair_estimate_id_arr
     LIMIT MAX_BUFFER_SIZE;

     -- get total count
     l_array_size := l_estimate_detail_id_arr.COUNT;

     FOR i IN 1..l_array_size
	LOOP

       SAVEPOINT ESTIMATE_LINES;

           l_repair_estimate_id := l_repair_estimate_id_arr(i);
           l_estimate_detail_id := l_estimate_detail_id_arr(i);
           l_creation_date      := l_creation_date_arr(i);
           l_item_cost          := 1;

       BEGIN
        INSERT INTO CSD_REPAIR_ESTIMATE_LINES(
           REPAIR_ESTIMATE_LINE_ID
          ,REPAIR_ESTIMATE_ID
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATE_LOGIN
          ,OBJECT_VERSION_NUMBER
          ,ESTIMATE_DETAIL_ID
          ,ITEM_COST)
	   VALUES (
           CSD_REPAIR_ESTIMATE_LINES_S1.nextval
          ,l_repair_estimate_id
          ,l_creation_date
          ,FND_GLOBAL.USER_ID
          ,FND_GLOBAL.USER_ID
          ,sysdate
          ,FND_GLOBAL.LOGIN_ID
          ,1
          ,l_estimate_detail_id
          ,l_item_cost);
     EXCEPTION
        WHEN OTHERS THEN
          v_error_text := substr(SQLERRM,2000);
          ROLLBACK to ESTIMATE_LINES;
          INSERT INTO csd_upg_errors
                      (orig_system_reference,
                      target_system_reference,
                      orig_system_reference_id,
                      upgrade_datetime,
                      error_message,
                      migration_phase)
              VALUES ('CS_ESTIMATE_DETAILS',
                      'CSD_REPAIR_ESTIMATE_LINES',
                      l_estimate_detail_id,
                      sysdate,
                      v_error_text,
                      '11.5.8');
			commit;

            raise_application_error( -20000, 'Error while migrating CS_ESTIMATE_DETAILS table data: Error while inserting into CSD_REPAIR_ESTIMATE_LINES. '|| v_error_text);

       END;

     END LOOP;-- end of inner

     COMMIT;
     EXIT WHEN cur_estimate_lines%NOTFOUND;

  END LOOP;-- End of outer cursor

  IF cur_estimate_lines%isopen THEN
	 CLOSE cur_estimate_lines;
  END IF;

  COMMIT;
  -- Api body ends here

END CSD_REPAIR_ESTIMATE_LINES_MIG;

-- Migration procedure for CSD_REPAIR_JOB_XREF
PROCEDURE CSD_REPAIR_JOB_XREF_MIG (p_slab_number NUMBER DEFAULT 1) IS

  Type NumTabType is VARRAY(10000) of NUMBER;
  inventory_item_id_mig          NumTabType;
  repair_job_xref_id_mig         NumTabType;

  Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
  rowid_mig                      RowidTabtype;

  CURSOR csd_repair_job_xref_cursor (p_min number,p_max number) is
  select  crjx.repair_job_xref_id,
          cr.inventory_item_id,
          crjx.rowid
  from    csd_repair_job_xref crjx,
          csd_repairs cr
  where   crjx.repair_line_id = cr.repair_line_id
  and     crjx.repair_job_xref_id >= p_min
  and     crjx.repair_job_xref_id <= p_max
  and     crjx.inventory_item_id is null;

  l_min   NUMBER;
  l_max   NUMBER;
  l_error_text           VARCHAR2(2000);

  MAX_BUFFER_SIZE        NUMBER := 500;

BEGIN

  -- Initialize the min and max limit
  csd_mig_slabs_pkg.get_table_slabs
    (p_table_name  =>'CSD_REPAIR_JOB_XREF',
     p_module      =>'CSD',
     p_slab_number => p_slab_number,
     x_start_slab  => l_min,
     x_end_slab    => l_max);

  -- Check the min and max limit
  IF l_min is null  THEN
    RETURN;
  END IF;

  -- Open the cursor and update the table
  OPEN csd_repair_job_xref_cursor(l_min,l_max);
  LOOP
    FETCH csd_repair_job_xref_cursor bulk collect into
                     repair_job_xref_id_mig,
                     inventory_item_id_mig,
                     rowid_mig
                     LIMIT MAX_BUFFER_SIZE;

    FOR j in 1..repair_job_xref_id_mig.count
    LOOP

      SAVEPOINT CSD_REPAIR_JOB_XREF;

      BEGIN
        UPDATE csd_repair_job_xref
        SET    inventory_item_id = inventory_item_id_mig(j),
               last_update_date  = sysdate,
			last_update_login = fnd_global.login_id,
			last_updated_by   = fnd_global.user_id
        WHERE  rowid = rowid_mig(j);
      EXCEPTION
       WHEN OTHERS THEN
       -- when errored rollback and insert the message into
       -- the csd upgrade errors table
        Rollback to CSD_REPAIR_JOB_XREF;
        l_error_text := 'Repair job xref updation Error '||substr(sqlerrm,1,1000);

        INSERT INTO csd_upg_errors
          (orig_system_reference,
           target_system_reference,
           orig_system_reference_id,
           upgrade_datetime,
           error_message,
           migration_phase)
        VALUES
          ('CSD_REPAIR_JOB_XREF',
           'CSD_REPAIR_JOB_XREF',
           repair_job_xref_id_mig(j),
           sysdate,
           l_error_text,
           '11.5.8');

        commit;

        raise_application_error( -20000, 'Error while migrating CSD_REPAIR_JOB_XREF table data. '|| l_error_text);


      END;

    END LOOP;

    COMMIT;

    EXIT WHEN csd_repair_job_xref_cursor%notfound;
  END LOOP;

  if csd_repair_job_xref_cursor%isopen then
    close csd_repair_job_xref_cursor;
  end if;

EXCEPTION
WHEN OTHERS THEN
  l_error_text := substr(sqlerrm,1,1000);
  if csd_repair_job_xref_cursor%isopen then
    close csd_repair_job_xref_cursor;
  end if;
  RAISE_APPLICATION_ERROR(-20000, 'Error while migrating CSD_REPAIR_JOB_XREF table data. '||l_error_text);
END CSD_REPAIR_JOB_XREF_MIG;


-- Migration procedure for CSD_REPAIR_TYPES_B
PROCEDURE CSD_REPAIR_TYPES_B_MIG IS

  Type NumTabType is VARRAY(10000) of NUMBER;
  repair_type_id_mig             NumTabType;

  Type RowidTabType is VARRAY(1000) of VARCHAR2(30);
  rowid_mig                      RowidTabtype;

  l_repair_type_ref          CSD_REPAIR_TYPES_B.REPAIR_TYPE_REF%TYPE  := 'SR';
  l_repair_mode              CSD_REPAIR_TYPES_B.REPAIR_MODE%TYPE      := 'WIP';
  l_seeded_flag              CSD_REPAIR_TYPES_B.SEEDED_FLAG%TYPE      := 'N';
  l_auto_process_rma         CSD_REPAIR_TYPES_B.AUTO_PROCESS_RMA%TYPE := 'N';
  l_interface_to_om_flag     CSD_REPAIR_TYPES_B.INTERFACE_TO_OM_FLAG%TYPE := 'N';
  l_booK_sales_order_flag    CSD_REPAIR_TYPES_B.BOOK_SALES_ORDER_FLAG%TYPE := 'N';
  l_release_sales_order_flag CSD_REPAIR_TYPES_B.RELEASE_SALES_ORDER_FLAG%TYPE := 'N';
  l_ship_sales_order_flag    CSD_REPAIR_TYPES_B.SHIP_SALES_ORDER_FLAG%TYPE := 'N';

  CURSOR csd_repair_types_b_cursor is
  select crtb.repair_type_id,
         crtb.rowid
  from   csd_repair_types_b crtb
  where  crtb.seeded_flag IS NULL;

  l_min  NUMBER;
  l_max  NUMBER;
  l_error_text           VARCHAR2(2000);

  MAX_BUFFER_SIZE        NUMBER := 500;

BEGIN

  -- Open the cursor and update the table
  OPEN csd_repair_types_b_cursor;
  LOOP
    FETCH csd_repair_types_b_cursor bulk collect into
          repair_type_id_mig,
          rowid_mig
          LIMIT MAX_BUFFER_SIZE;

    FOR j in 1..repair_type_id_mig.count
    LOOP
      BEGIN
        SAVEPOINT CSD_REPAIR_TYPES_B;

        UPDATE csd_repair_types_b
        SET  repair_mode              = l_repair_mode,
             repair_type_ref          = l_repair_type_ref,
             auto_process_rma         = l_auto_process_rma,
             interface_to_om_flag     = l_interface_to_om_flag,
             book_sales_order_flag    = l_book_sales_order_flag,
             release_sales_order_flag = l_release_sales_order_flag,
             seeded_flag              = l_seeded_flag,
		   last_update_date         = sysdate,
		   last_update_login        = fnd_global.login_id,
		   last_updated_by          = fnd_global.user_id
        WHERE  rowid = rowid_mig(j);
      EXCEPTION
       WHEN OTHERS THEN
       -- when errored rollback and insert the message into
       -- the csd upgrade errors table
        Rollback to CSD_REPAIR_TYPES_B;
        l_error_text := 'Repair Type Updation Error'||substr(sqlerrm,1,1000);
        INSERT INTO csd_upg_errors
          (orig_system_reference,
           target_system_reference,
           orig_system_reference_id,
           upgrade_datetime,
           error_message,
           migration_phase)
        VALUES
          ('CSD_REPAIR_TYPES_B',
           'CSD_REPAIR_TYPES_B',
           repair_type_id_mig(j),
           sysdate,
           l_error_text,
           '11.5.8');

        commit;

        raise_application_error( -20000, 'Error while migrating CSD_REPAIR_TYPES_B table data. '|| l_error_text);


      END;
    END LOOP;

    COMMIT;

    EXIT WHEN csd_repair_types_b_cursor%notfound;
  END LOOP;

  if csd_repair_types_b_cursor%isopen then
      close csd_repair_types_b_cursor;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    l_error_text := substr(sqlerrm,1,1000);
    if csd_repair_types_b_cursor%isopen then
      close csd_repair_types_b_cursor;
    end if;
    RAISE_APPLICATION_ERROR(-20000, 'Error while migrating CSD_REPAIR_TYPES_B table data. '||l_error_text);
END CSD_REPAIR_TYPES_B_MIG;

END CSD_Migrate_From_115X_PKG;


/
