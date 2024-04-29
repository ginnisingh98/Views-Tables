--------------------------------------------------------
--  DDL for Package Body MSC_CL_SUPPLIER_RESP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_SUPPLIER_RESP" AS
/* $Header: MSCXCSRB.pls 120.2 2006/02/27 21:36:16 shwmathu noship $ */

   PROCEDURE LOG_MESSAGE( pBUFF     IN  VARCHAR2)
   IS
   BEGIN

     IF fnd_global.conc_request_id > 0 THEN   -- concurrent program

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

     ELSE

        --DBMS_OUTPUT.PUT_LINE( pBUFF);
        null;

     END IF;

   END LOG_MESSAGE;

PROCEDURE PULL_SUPPLIER_RESP(   p_dblink  IN VARCHAR2,
			        p_instance_id IN      NUMBER,
				p_return_status OUT NOCOPY BOOLEAN,
				p_supplier_response_flag IN NUMBER,
				p_refresh_id	IN NUMBER,
				p_lrn		IN NUMBER,
				p_in_org_str	IN VARCHAR2
			    ) IS

v_sql_stmt VARCHAR2(15000);

BEGIN
    p_return_status := TRUE;

    IF (p_supplier_response_flag = SYS_YES) THEN

    v_sql_stmt:=
    ' insert into MSC_ST_SUPPLIES'
    ||'   (   INVENTORY_ITEM_ID,'
    ||'       ORGANIZATION_ID,'
    ||'       DISPOSITION_ID,'
    ||'       SUPPLIER_ID,'
    ||'       SUPPLIER_SITE_ID,'
    ||'       ORDER_TYPE,'
    ||'       NEW_ORDER_QUANTITY,'
    ||'       ORDER_LINE_NUMBER,'
    ||'       PO_LINE_ID,'
    ||'       NEW_DOCK_DATE,'
    ||'       ORDER_NUMBER,' -- Supplier Sales Order Number
    ||'       REFRESH_ID,'
    ||'       NEW_ORDER_PLACEMENT_DATE,'
    ||'	      END_ORDER_NUMBER,'
    ||'	      END_ORDER_LINE_NUMBER,'
    ||'	      END_ORDER_RELEASE_NUMBER,'
    ||'	      END_ORDER_SHIPMENT_NUMBER,'
    ||'	      UOM_CODE,'
	||'       SR_MTL_SUPPLY_ID,'
    ||'       DELETED_FLAG,'
    ||'       NEED_BY_DATE,'
    ||'       ACCEPTANCE_REQUIRED_FLAG,'
    ||'       ACK_REFERENCE_NUMBER,'
    ||'       SR_INSTANCE_ID)'
    ||'  select'
    ||'         x.INVENTORY_ITEM_ID,'
    ||'         x.ORGANIZATION_ID,'
    ||'         x.PO_HEADER_ID,'
    ||'         x.VENDOR_ID,'
    ||'         x.VENDOR_SITE_ID,'
    ||'         :v_order_type,'
    ||'         x.QUANTITY,'
    ||'		x.SUPPLIER_ORDER_LINE_NUMBER,'
    ||'		x.PO_LINE_ID,'
    ||'		x.PROMISED_DATE,'
    ||'		x.SUPPLIER_ORDER_NUMBER,'
    ||'		:v_refresh_id,'
    ||'		x.NEW_ORDER_PLACEMENT_DATE,'
    ||'		x.END_ORDER_NUMBER,'
    ||'		x.END_ORDER_LINE_NUMBER,'
    ||'		x.END_ORDER_RELEASE_NUMBER,'
    ||'		x.END_ORDER_SHIPMENT_NUMBER,'
    ||'		x.UOM_CODE,'
	||'         1,'
    ||'         2,'
	||'     x.PO_NEED_BY_DATE,'
	||'     x.REJECTED_FLAG,'
	||'     to_char(nvl(x.RN2, -999)),'
    ||'         :v_instance_id'
    ||'  from MRP_AP_SUPPLIER_RESPONSE_V'||p_dblink||' x'
    ||'  where x.ORGANIZATION_ID'||p_in_org_str
    ||'   AND (    x.RN1>'||p_lrn
    ||'         OR x.RN2>'||p_lrn
    ||'         OR x.RN3>'||p_lrn
    ||'         OR x.RN4>'||p_lrn||')';

    BEGIN
         /* Debug
	            LOG_MESSAGE('THE POAK PULL IS');
		               LOG_MESSAGE(v_sql_stmt); */

        EXECUTE IMMEDIATE v_sql_stmt
    	    USING
    		    G_MRP_PO_ACK,
    		    p_refresh_id,
    		    p_instance_id;

        COMMIT;

        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while populating msc_st_supplies from MRP_AP_SUPPLIER_RESPONSE_V');
			LOG_MESSAGE(SQLERRM);
            p_return_status := FALSE;
    END;


    END IF;

 END;

PROCEDURE LOAD_SUPPLIER_RESPONSE(p_instance_id NUMBER,
				 p_is_complete_refresh BOOLEAN,
				 p_is_partial_refresh BOOLEAN,
				 p_is_incremental_refresh BOOLEAN,
				 p_temp_supply_table VARCHAR2,
				 p_user_id NUMBER,
				 p_last_collection_id NUMBER) IS
CURSOR supplierResponse IS
select  G_PLAN_ID,
	miil.INVENTORY_ITEM_ID,
	mss.sr_instance_id,
	mss.ORGANIZATION_ID,
	mss.DISPOSITION_ID,
	mss.ORDER_TYPE,
	mtil.tp_ID,
	mtsil.tp_SITE_ID,
	mss.NEW_ORDER_QUANTITY,
	mss.NEW_ORDER_PLACEMENT_DATE,
	mss.ORDER_LINE_NUMBER,
	mss.NEW_DOCK_DATE,
	mss.ORDER_NUMBER,
	mss.END_ORDER_NUMBER,
	mss.END_ORDER_RELEASE_NUMBER,
	mss.END_ORDER_LINE_NUMBER,
	mss.END_ORDER_SHIPMENT_NUMBER,
	mss.ACCEPTANCE_REQUIRED_FLAG,
	mss.NEED_BY_DATE,
	mss.ACK_REFERENCE_NUMBER
from    msc_st_supplies mss,
	msc_tp_id_lid mtil,
	msc_tp_site_id_lid mtsil,
	msc_item_id_lid miil
where   mss.order_type = G_MRP_PO_ACK
and     mss.sr_instance_id = p_instance_id
and     mss.supplier_id = mtil.sr_tp_id
and     mss.sr_instance_id = mtil.sr_instance_id
and     mtil.partner_type = decode(mss.SR_MTL_SUPPLY_ID,-1,2,1)
and     mss.sr_instance_id = mtsil.sr_instance_id
and     mss.supplier_site_id = mtsil.sr_tp_site_id
and     mtsil.partner_type = decode(mss.SR_MTL_SUPPLY_ID,-1,2,1)
and     mss.inventory_item_id = miil.sr_inventory_item_id
and     mss.sr_instance_id = miil.sr_instance_id
order by mss.END_ORDER_NUMBER,
		 mss.END_ORDER_LINE_NUMBER,
		 mss.END_ORDER_RELEASE_NUMBER,
		 mss.END_ORDER_SHIPMENT_NUMBER,
		 mss.ACK_REFERENCE_NUMBER desc;

/* Variables for UPDATE */
a_plan_id		number_arr := number_arr();
a_inventory_item_id	number_arr := number_arr();
a_sr_instance_id  number_arr := number_arr();
a_organization_id	number_arr := number_arr();
a_disposition_id	number_arr := number_arr();
a_order_type		number_arr := number_arr();
a_supplier_id		number_arr := number_arr();
a_supplier_site_id	number_arr := number_arr();
a_new_order_quantity	number_arr := number_arr();
a_new_order_plac_date	dates := dates();
a_order_number		order_numbers := order_numbers();
a_order_line_number	order_line_numbers := order_line_numbers();
a_new_dock_date		dates := dates();
a_end_order_number	end_order_numbers := end_order_numbers();
a_end_order_line_num	end_order_line_nums := end_order_line_nums();
a_end_order_rel_num	end_order_rel_nums := end_order_rel_nums();
a_end_order_shipment_num number_arr := number_arr();
a_po_release_id		number_arr := number_arr();
a_need_by_date		dates :=dates();
a_acceptance_required_flag acceptance_required_flags := acceptance_required_flags();
a_ack_reference_number ack_reference_numbers := ack_reference_numbers();

prev_po_number msc_st_supplies.end_order_number%TYPE;
prev_release_number msc_st_supplies.END_ORDER_RELEASE_NUMBER%TYPE;
prev_po_line_number msc_st_supplies.END_ORDER_LINE_NUMBER%TYPE;
prev_po_shipment_number msc_st_supplies.END_ORDER_SHIPMENT_NUMBER%TYPE;
prev_ack_reference msc_st_supplies.ACK_REFERENCE_NUMBER%TYPE;

curr_po_number msc_st_supplies.end_order_number%TYPE;
curr_release_number msc_st_supplies.END_ORDER_RELEASE_NUMBER%TYPE;
curr_po_line_number msc_st_supplies.END_ORDER_LINE_NUMBER%TYPE;
curr_po_shipment_number msc_st_supplies.END_ORDER_SHIPMENT_NUMBER%TYPE;
curr_ack_reference msc_st_supplies.ACK_REFERENCE_NUMBER%TYPE;

order_line_number VARCHAR2(40);
lv_temp_supply_tbl VARCHAR2(40);

/* Columns for insertion */

a_ins_count                     number_arr := number_arr();

a_ins_plan_id                   number_arr := number_arr();
a_ins_inventory_item_id         number_arr := number_arr();
a_ins_sr_instance_id            number_arr := number_arr();
a_ins_organization_id           number_arr := number_arr();
a_ins_disposition_id            number_arr := number_arr();
a_ins_order_type                number_arr := number_arr();
a_ins_supplier_id               number_arr := number_arr();
a_ins_supplier_site_id          number_arr := number_arr();
a_ins_new_order_quantity        number_arr := number_arr();
a_ins_new_order_plac_date       dates := dates();
a_ins_order_line_number         order_line_numbers := order_line_numbers();
a_ins_new_dock_date             dates := dates();
a_ins_order_number              order_numbers := order_numbers();
a_ins_end_order_number          end_order_numbers := end_order_numbers();
a_ins_end_order_line_num        end_order_line_nums := end_order_line_nums();
a_ins_need_by_date              dates :=dates();
a_ins_acceptance_required_flag 	acceptance_required_flags := acceptance_required_flags();

lv_sql_stmt              VARCHAR2(5000);

    BEGIN
        --======================================================================
        -- For the records collected from msc_st_supplies
        -- delete the corresponding previous "PO Acknowledgment" records for the
        -- following key
        --
        --	sr_instance_id,
        --	organization_id,
        --	inventory_item_id
        --	supplier_id
        --	supplier_site_id
        --	end_order_number
        --	end_order_line_number
        --	end_order_release_number
        --	end_order_shipment_number
        --======================================================================

	OPEN supplierResponse;
	FETCH supplierResponse BULK COLLECT INTO
	    a_plan_id, 			--G_PLAN_ID
	    a_inventory_item_id,	--INVENTORY_ITEM_ID
	    a_sr_instance_id,		--sr_instance_id
	    a_organization_id,		--ORGANIZATION_ID
	    a_disposition_id,		--DISPOSITION_ID
	    a_order_type,		--ORDER_TYPE
	    a_supplier_id,		--tp_ID
	    a_supplier_site_id,		--tp_SITE_ID
	    a_new_order_quantity,	--NEW_ORDER_QUANTITY
	    a_new_order_plac_date,	--NEW_ORDER_PLACEMENT_DATE
	    a_order_line_number,		--PURCH_LINE_NUM
	    a_new_dock_date,		--NEW_DOCK_DATE
	    a_order_number,		--ORDER_NUMBER
	    a_end_order_number,		--END_ORDER_NUMBER
	    a_end_order_rel_num,	--END_ORDER_RELEASE_NUMBER
	    a_end_order_line_num,	--END_ORDER_LINE_NUMBER
	    a_end_order_shipment_num,	--END_ORDER_SHIPMENT_NUMBER
		a_acceptance_required_flag, --ACCEPTANCE_REQUIRED_FLAG
		a_need_by_date,			--PO NEED BY DATE
		a_ack_reference_number;  --ACK_REFERENCE_NUMBER
	CLOSE supplierResponse;

	--==========================================================
	-- Delete the previous PO Acknowledgment records.
    -- Perform this step in case of net change collections only.
    -- In net change collections normally we update the records
    -- but in case of PO Acknowledgment we will delete previous
	-- records and re-insert new records.
	--==========================================================
        IF p_is_incremental_refresh THEN

	        IF a_plan_id.COUNT > 0 THEN
	        BEGIN
	            FORALL i in 1..a_plan_id.COUNT
	DELETE MSC_SUPPLIES MS
	WHERE
	            	    ms.plan_id = a_plan_id(i)
	and	ms.inventory_item_id = a_inventory_item_id(i)
	and ms.supplier_id = a_supplier_id(i)
	and ms.supplier_site_id = a_supplier_site_id(i)
	and ms.sr_instance_id = a_sr_instance_id(i)
	and ms.organization_id = a_organization_id(i)
	and ms.order_type = G_MRP_PO_ACK
	and ms.end_order_line_number = a_end_order_line_num(i)
	and ms.end_order_number
	= decode(a_end_order_rel_num(i) ,null, a_end_order_number(i)||'('|| ' '||')' ||'('|| a_end_order_line_num(i)||')'||'('||
	TO_CHAR(a_end_order_shipment_num(i))||')'  ,a_end_order_number(i)||'('|| a_end_order_rel_num(i)||')' ||'('||
	a_end_order_line_num(i)||')'||'('|| TO_CHAR(a_end_order_shipment_num(i))||')'      );


	/*decode(a_end_order_rel_num(i) ,
	null, a_end_order_number(i)||'('||TO_CHAR(a_end_order_shipment_num(i))||')'
	a_end_order_number(i)||'('||a_end_order_rel_num(i)||')'||'('||TO_CHAR(a_end_order_shipment_num(i))||')'	         );
	*/
                COMMIT;

	        EXCEPTION WHEN OTHERS THEN
				LOG_MESSAGE('Error while deleting PO Acknowledgment records from msc_supplies');
				RAISE;

	        END;
	        END IF;
        END IF;

	--==========================================================================
	-- Manipulate Supplier Sales Order Line numbers
	-- We  will derive Supplier Sales Order Line numbers
	-- if Supplier has not provided Sales Order line number
	-- in resposne to PO.
	-- In ISP source Supplier can have only one SO for Standard PO/ Release.
	--  For each PO / Release we will create Supplier SO line numbers starting
	--  from 1 to number of responses for that PO / Release.
	--  We will create numbers only if Supplier has not provided them.
	--==========================================================================
	       prev_po_number := NULL_STRING;
		   prev_release_number := NULL_STRING;
		   prev_po_shipment_number := null;
		   prev_po_line_number := NULL_STRING;
		   order_line_number := '0';

       IF a_plan_id.COUNT > 0 THEN

	   FOR i in 1..a_plan_id.COUNT LOOP

			       -- Get the key for End order in some variables
		       curr_po_number := nvl(a_end_order_number(i), NULL_STRING);
		       curr_release_number := nvl(a_end_order_rel_num(i), NULL_STRING);
		       curr_po_line_number := nvl(a_end_order_line_num(i), NULL_STRING);
		       curr_po_shipment_number := nvl(a_end_order_shipment_num(i), -99);
		       curr_ack_reference := nvl(a_ack_reference_number(i), NULL_STRING);

		       -- Compare the current record's key with previous record. If the everything is same
		       -- and ack_reference_number is different then it is duplicate record for the same
		       -- shipment so we need to ignore it.

		       IF NOT(curr_po_number = prev_po_number AND
			      curr_release_number = prev_release_number AND
			      curr_po_line_number = prev_po_line_number AND
			      curr_po_shipment_number = prev_po_shipment_number AND
			      curr_ack_reference <> prev_ack_reference) THEN

			   /* ============================
			      Extend columns for insertion
			      ============================ */
			   a_ins_count.EXTEND;
			   a_ins_plan_id.EXTEND;
			   a_ins_inventory_item_id.EXTEND;
			   a_ins_sr_instance_id.EXTEND;
			   a_ins_organization_id.EXTEND;
			   a_ins_disposition_id.EXTEND;
			   a_ins_order_type.EXTEND;
			   a_ins_supplier_id.EXTEND;
			   a_ins_supplier_site_id.EXTEND;
			   a_ins_new_order_quantity.EXTEND;
			   a_ins_new_order_plac_date.EXTEND;
			   a_ins_order_line_number.EXTEND;
			   a_ins_new_dock_date.EXTEND;
			   a_ins_order_number.EXTEND;
			   a_ins_end_order_number.EXTEND;
			   a_ins_end_order_line_num.EXTEND;
			   a_ins_need_by_date.EXTEND;
			   a_ins_acceptance_required_flag.EXTEND;

			   /* ===========================================
			      Assign values to the columns to be inserted
			      =========================================== */
			   a_ins_count(a_ins_count.COUNT)  := i;

			   a_ins_plan_id(a_ins_count.COUNT) := a_plan_id(i);
			   a_ins_inventory_item_id(a_ins_count.COUNT) := a_inventory_item_id(i);
			   a_ins_sr_instance_id(a_ins_count.COUNT) := a_sr_instance_id(i);
			   a_ins_organization_id(a_ins_count.COUNT):= a_organization_id(i);
			   a_ins_disposition_id(a_ins_count.COUNT) := a_disposition_id(i);
			   a_ins_order_type(a_ins_count.COUNT) := a_order_type(i);
			   a_ins_supplier_id(a_ins_count.COUNT) := a_supplier_id(i);
			   a_ins_supplier_site_id(a_ins_count.COUNT) := a_supplier_site_id(i);
			   a_ins_new_order_quantity(a_ins_count.COUNT) := a_new_order_quantity(i);
			   a_ins_new_order_plac_date(a_ins_count.COUNT) := a_new_order_plac_date(i);
			   a_ins_order_line_number(a_ins_count.COUNT) := a_order_line_number(i);
			   a_ins_new_dock_date(a_ins_count.COUNT) := a_new_dock_date(i);
			   a_ins_order_number(a_ins_count.COUNT) := a_order_number(i);
			   a_ins_end_order_number(a_ins_count.COUNT) := a_end_order_number(i);
			   a_ins_end_order_line_num(a_ins_count.COUNT) := a_end_order_line_num(i);
			   a_ins_need_by_date(a_ins_count.COUNT) := a_need_by_date(i);
			   a_ins_acceptance_required_flag(a_ins_count.COUNT) := a_acceptance_required_flag(i);

		       /* ===========================================================================
                          Create system generated Order line number only if Supplier has not rejected
                          the Shipment.
                          =========================================================================== */

		   IF (a_acceptance_required_flag(i) <> 'R') THEN

			/* For STANDARD PO Order Line Number = end_order_line_number.end_order_shipment_number
			   For BLANKET PO Order Line Number =
			          end_order_release_number.end_order_line_number.end_order_shipment_number */

			IF (nvl(a_end_order_rel_num(i), NULL_STRING) = NULL_STRING) THEN
			    order_line_number := a_end_order_line_num(i)||'.'||a_end_order_shipment_num(i) ;
			    LOG_MESSAGE('order_line_number is :'||order_line_number);
			ELSE
			    order_line_number := a_end_order_rel_num(i)||'.'||a_end_order_line_num(i)||'.'
			                          ||a_end_order_shipment_num(i) ;
			    LOG_MESSAGE('order_line_number is :'||order_line_number);
                        END IF;

		        IF (a_order_line_number(i) = NULL_STRING) THEN
			   a_ins_order_line_number(a_ins_count.COUNT) := order_line_number ;
			   LOG_MESSAGE('Assigned Order Line Number :'||order_line_number);
                        END IF;

                   END IF; --(a_acceptance_req.....

		   -- Derive the End Order Number before insertion

		   IF (nvl(a_end_order_rel_num(i), NULL_STRING) = NULL_STRING) THEN
		       a_ins_end_order_number(a_ins_count.COUNT) :=  a_end_order_number(i)||'('|| ' '||')' ||'('||
		       a_end_order_line_num(i)||')'||'('|| TO_CHAR(a_end_order_shipment_num(i))||')';
                   ELSE
		       a_ins_end_order_number(a_ins_count.COUNT) :=  a_end_order_number(i)||'('|| a_end_order_rel_num(i)||')' ||'('||
		       a_end_order_line_num(i)||')'||'('|| TO_CHAR(a_end_order_shipment_num(i))||')';
                   END IF;





		  /* IF (nvl(a_end_order_rel_num(i), NULL_STRING) = NULL_STRING) THEN
		       a_ins_end_order_number(a_ins_count.COUNT) := a_end_order_number(i)||'('||a_end_order_shipment_num(i)||')';
                   ELSE
		       a_ins_end_order_number(a_ins_count.COUNT) := a_end_order_number(i)||'('||a_end_order_rel_num(i)||')'
		                                ||'('||a_end_order_shipment_num(i)||')';
                   END IF; */

	       END IF;

		   prev_po_number          := curr_po_number;
		   prev_release_number     := curr_release_number;
		   prev_po_line_number     := curr_po_line_number;
		   prev_po_shipment_number := curr_po_shipment_number;
		   prev_ack_reference      := curr_ack_reference;


	       END LOOP;

       END IF;  --IF a_plan_id.COUNT

	--=============================================================
	-- Do the BULK Insert in case Complete and Net change refresh.
	-- In case of targeted refresh we need to use dynamic SQL since
	-- we need to insert records in temporary table.
	--=============================================================

	    IF (p_is_incremental_refresh) THEN
				lv_temp_supply_tbl := 'MSC_SUPPLIES';
            ELSIF (p_is_partial_refresh OR p_is_complete_refresh) THEN
				lv_temp_supply_tbl := p_temp_supply_table;
            END IF;

		       IF a_ins_count.COUNT > 0 THEN

				   lv_sql_stmt :=
					   ' INSERT INTO ' || lv_temp_supply_tbl
					   ||'(PLAN_ID, '
					   ||'TRANSACTION_ID, '
					   ||'INVENTORY_ITEM_ID, '
					   ||'SR_INSTANCE_ID, '
					   ||'ORGANIZATION_ID, '
					   ||'DISPOSITION_ID, '
					   ||'ORDER_TYPE, '
					   ||'SUPPLIER_ID, '
					   ||'SUPPLIER_SITE_ID, '
					   ||'NEW_ORDER_QUANTITY, '
					   ||'NEW_ORDER_PLACEMENT_DATE, '
					   ||'ORDER_LINE_NUMBER, '
					   ||'NEW_SCHEDULE_DATE, '
					   ||'NEW_DOCK_DATE, '
					   ||'ORDER_NUMBER, '
					   ||'END_ORDER_NUMBER, '
					   ||'END_ORDER_LINE_NUMBER, '
					   ||'FIRM_PLANNED_TYPE, '
					   ||'LAST_UPDATE_DATE, '
					   ||'LAST_UPDATED_BY, '
					   ||'CREATION_DATE, '
					   ||'REFRESH_NUMBER, '
					   ||'NEED_BY_DATE, '
					   ||'ACCEPTANCE_REQUIRED_FLAG, '
					   ||'CREATED_BY )'
					   ||' VALUES '
					   ||'(:PLAN_ID, '
					   ||' MSC_SUPPLIES_S.NEXTVAL, '
					   ||' :INVENTORY_ITEM_ID, '
					   ||' :SR_INSTANCE_ID, '
					   ||' :ORGANIZATION_ID, '
					   ||' :DISPOSITION_ID, '
					   ||' :ORDER_TYPE, '
					   ||' :SUPPLIER_ID, '
					   ||' :SUPPLIER_SITE_ID, '
					   ||' :NEW_ORDER_QUANTITY, '
					   ||' :NEW_ORDER_PLACEMENT_DATE, '
					   ||' :ORDER_LINE_NUMBER, '
					   ||' :NEW_SCHEDULE_DATE, '
					   ||' :NEW_DOC_DATE, '
					   ||' :ORDER_NUMBER, '
					   ||' :END_ORDER_NUMBER, '
					   ||' :END_ORDER_LINE_NUMBER, '
					   ||'  2, ' -- FIRM_PLANNED_TYPE
					   ||'  SYSDATE, '
					   ||   p_user_id ||', '
					   ||'  SYSDATE, '
					   ||   p_last_collection_id ||', '
					   ||' :NEED_BY_DATE, '
					   ||' :ACCEPTANCE_REQUIRED_FLAG, '
					   ||   p_user_id ||' )';


				   LOG_MESSAGE('Total PO Acknowledgment records for insertion :'||a_ins_count.COUNT);

				   FOR i IN 1..a_ins_count.COUNT LOOP

				   BEGIN
					   EXECUTE IMMEDIATE lv_sql_stmt
					   USING a_ins_plan_id(i),
					         a_ins_inventory_item_id(i),
						 a_ins_sr_instance_id(i),
						 a_ins_organization_id(i),
						 a_ins_disposition_id(i),
						 a_ins_order_type(i),
						 a_ins_supplier_id(i),
						 a_ins_supplier_site_id(i),
						 a_ins_new_order_quantity(i),
						 a_ins_new_order_plac_date(i),
						 a_ins_order_line_number(i),
						 a_ins_new_dock_date(i), -- New schedule Date
						 a_ins_new_dock_date(i),
						 a_ins_order_number(i),
						 a_ins_end_order_number(i),
						 a_ins_end_order_line_num(i),
						 a_ins_need_by_date(i),
						 a_ins_acceptance_required_flag(i);

					   COMMIT;

	               EXCEPTION WHEN OTHERS THEN
	                   LOG_MESSAGE('ERROR while inserting PO Acknowledgment Records in MSC_SUPPLIES');
	                   LOG_MESSAGE(SQLERRM);
	                   RAISE;
					   RETURN;
	               END;

				   END LOOP; --FOR i IN 1..a_plan_id.COUNT ....

			       END IF;

    END;

PROCEDURE PUBLISH_SUPPLIER_RESPONSE(p_refresh_number IN NUMBER,
				    p_sr_instance_id IN NUMBER,
				    p_return_status OUT NOCOPY BOOLEAN,
				    p_collection_type IN VARCHAR2,
				    p_user_id IN NUMBER,
					p_in_org_str IN VARCHAR2
				    ) IS


CURSOR supplierSalesOrders(p_language_code varchar2) IS
SELECT
        G_PLAN_ID
       ,mcr.object_id            publisher_id  -- Supplier's company_id will be used as Publisher_id
       ,mtpm1.company_key        publisher_site_id -- Supplier's company_site_id
       ,mc1.company_name         publisher_name -- Supplier's company name
       ,mcs1.company_site_name   publisher_site_name -- Supplier's company site name
       ,ms.inventory_item_id     inventory_item_id
       ,ms.new_order_quantity    quantity
       ,decode(ms.order_type, G_MRP_PO_ACK, G_SALES_ORDER)      publisher_order_type
       ,ms.new_schedule_date     receipt_date
       ,ms.order_line_number     Order_line_number
       ,ms.order_number          order_number
       ,G_OEM_ID ship_to_party_id
       ,mcsil.company_site_id    ship_to_party_site_id
       ,mc.company_name          ship_to_party_name
       ,mcs.company_site_name    ship_to_party_site_name
       ,mi.item_name            publisher_item_name
       ,mi.description          pub_item_description
       ,mi.uom_code		uom_code
       ,flv.meaning             publisher_order_type_desc
--     ,nvl(ms.new_schedule_date, ms.new_dock_date) key_date
       ,ms.supplier_id		partner_id
       ,ms.supplier_site_id	partner_site_id
       ,ms.sr_instance_id	orig_sr_instance_id
       ,ms.organization_id	organization_id
       ,decode(instr(ms.end_order_number , ')'),
					0 , ms.end_order_number,
					substr(ms.end_order_number, 1, instr(ms.end_order_number,'(') - 1))  end_order_number
       ,ms.end_order_line_number end_order_line_number
	   , substr(ms.end_order_number,instr(ms.end_order_number,'(')+1,instr(ms.end_order_number,'(',1,2)-2-
	   instr(ms.end_order_number,'(')) end_order_rel_number	   /*decode(instr(ms.end_order_number,'('),
	   0, null,  substr(end_order_number, instr(end_order_number,'('))) */
       ,ms.NEW_ORDER_PLACEMENT_DATE order_placement_date
       ,ms.NEED_BY_DATE request_date
from
       msc_supplies ms
-- Table to get org equivalent company_site_id
       ,msc_companies mc
       ,msc_company_sites mcs
       ,msc_company_site_id_lid mcsil
-- Tables to get Supplier's company_id
       ,msc_trading_partner_maps mtpm
       ,msc_company_relationships mcr
       ,msc_companies mc1
-- Tables to get Supplier's company_site_id
       ,msc_trading_partner_maps mtpm1
       ,msc_company_sites mcs1
-- Table to get global item_id
       ,msc_system_items mi
-- Table to get order type description
       ,fnd_lookup_values flv
where
       ms.sr_instance_id = p_sr_instance_id
-- =====================================================================
-- Get Supplier Sales Order related transactions and also make sure that
-- PO Acknowledgment record is not indicating rejection of PO Shipment
-- =====================================================================
and ms.order_type = G_MRP_PO_ACK
and ms.ACCEPTANCE_REQUIRED_FLAG <> 'R'
-- ====================
-- Get only ODS records
-- ====================
and ms.plan_id = G_PLAN_ID
-- =======================================================================
-- Join with msc_company_site_id_lid to get org equivalent company_site_id
-- =======================================================================
and ms.organization_id = mcsil.sr_company_site_id
and ms.sr_instance_id  = mcsil.sr_instance_id
and mcsil.partner_type = G_ORGANIZATION
and mcsil.sr_company_id = G_SR_OEM_ID
and mcsil.company_site_id = mcs.company_site_id
and mcs.company_id = mc.company_id
-- =================================================
-- Make sure that Sales Orders for OEM are published
-- =================================================
and mcs.company_id = G_OEM_ID
-- ==========================================================
-- Join with msc_system_items to get Item related information
-- ==========================================================
and ms.inventory_item_id = mi.inventory_item_id
and ms.organization_id   = mi.organization_id
and ms.sr_instance_id    = mi.sr_instance_id
and ms.plan_id       = mi.plan_id
-- =============================
-- Get the Supplier's company_id
-- =============================
and ms.supplier_id       = mtpm.tp_key
and mtpm.map_type    = 1
and mtpm.company_key     = mcr.relationship_id
and mcr.object_id    = mc1.company_id
-- ====================================================
-- Get the supplier's company_site_id. Use Outer joint
-- with msc_trading_partner_maps since some order types
-- supplier site is optional
-- ====================================================
and nvl(ms.supplier_site_id, -99) = mtpm1.tp_key
and mtpm1.map_type   = 3
and mtpm1.company_key    = mcs1.company_site_id
-- ==============================
-- Get the order type description
-- ==============================
and decode(ms.order_type, G_MRP_PO_ACK, G_SALES_ORDER ) = flv.lookup_code
and flv.lookup_type = 'MSC_X_ORDER_TYPE'
and flv.language =  p_language_code
-- ================================================
-- Get the rows according to last collection metnod
-- ================================================
and nvl(ms.refresh_number, -1) = decode(p_collection_type , 'C', nvl(ms.refresh_number, -1)
               , 'P', nvl(ms.refresh_number, -1)
               , 'I', p_refresh_number)
order by ms.end_order_number,
         ms.end_order_line_number;

--=================================================
-- Cursor for fetching Supplier related information
--=================================================

    CURSOR itemSuppliers (p_organization_id NUMBER,
                          p_sr_instance_id  NUMBER,
                          p_item_id         NUMBER,
                          p_partner_id	    NUMBER,
                          p_partner_site_id NUMBER) IS
    select supplier_item_name,
           nvl(mis.processing_lead_time, 0),
           mis.uom_code
    from  msc_item_suppliers mis
    where mis.plan_id           = G_PLAN_ID
    and   mis.organization_id   = p_organization_id
    and   mis.sr_instance_id    = p_sr_instance_id
    and   mis.inventory_item_id = p_item_id
    and   mis.supplier_id 	= p_partner_id
    and   nvl(mis.supplier_site_id, -99) = decode(mis.supplier_site_id,
    		   					     null, -99, p_partner_site_id)
    order by mis.using_organization_id, nvl(mis.supplier_site_id, -99) desc;

-- ======================================================
-- Cursor for fetching rejected PO shipments by Supplier.
-- ======================================================
CURSOR rejectedPoShipments IS
SELECT
        G_PLAN_ID
       ,mcr.object_id            publisher_id  -- Supplier's company_id will be used as Publisher_id
       ,mtpm1.company_key        publisher_site_id -- Supplier's company_site_id
       ,ms.inventory_item_id     inventory_item_id
       ,G_PO      publisher_order_type
       ,G_OEM_ID ship_to_party_id
       ,mcsil.company_site_id    ship_to_party_site_id
       ,decode(instr(ms.end_order_number , ')'),
                    0 , ms.end_order_number,
                    substr(ms.end_order_number, 1, instr(ms.end_order_number,'(') - 1))  end_order_number
       ,ms.end_order_line_number end_order_line_number
       ,decode(instr(ms.end_order_number,'('),
                     0, null,
                     substr(end_order_number, instr(end_order_number,'('))) end_order_rel_number
       ,ms.NEED_BY_DATE request_date
from
       msc_supplies ms
-- Table to get org equivalent company_site_id
       ,msc_company_site_id_lid mcsil
-- Tables to get Supplier's company_id
       ,msc_trading_partner_maps mtpm
       ,msc_company_relationships mcr
-- Tables to get Supplier's company_site_id
       ,msc_trading_partner_maps mtpm1
-- Table to get global item_id
       ,msc_system_items mi
where
       ms.sr_instance_id = p_sr_instance_id
-- =====================================================================
-- Get Supplier Sales Order related transactions and also make sure that
-- PO Acknowledgment record is not indicating rejection of PO Shipment
-- =====================================================================
and ms.order_type = G_MRP_PO_ACK
and ms.ACCEPTANCE_REQUIRED_FLAG = 'R'
-- ====================
-- Get only ODS records
-- ====================
and ms.plan_id = G_PLAN_ID
-- =======================================================================
-- Join with msc_company_site_id_lid to get org equivalent company_site_id
-- =======================================================================
and ms.organization_id = mcsil.sr_company_site_id
and ms.sr_instance_id  = mcsil.sr_instance_id
and mcsil.partner_type = G_ORGANIZATION
and mcsil.sr_company_id = G_SR_OEM_ID
-- ==========================================================
-- Join with msc_system_items to get Item related information
-- ==========================================================
and ms.inventory_item_id = mi.inventory_item_id
and ms.organization_id   = mi.organization_id
and ms.sr_instance_id    = mi.sr_instance_id
and ms.plan_id       = mi.plan_id
-- =============================
-- Get the Supplier's company_id
-- =============================
and ms.supplier_id       = mtpm.tp_key
and mtpm.map_type    = 1
and mtpm.company_key     = mcr.relationship_id
-- ====================================================
-- Get the supplier's company_site_id. Use Outer joint
-- with msc_trading_partner_maps since some order types
-- supplier site is optional
-- ====================================================
and ms.supplier_site_id = mtpm1.tp_key
and mtpm1.map_type   = 3
-- ================================================
-- Get the rows according to last collection metnod
-- ================================================
and nvl(ms.refresh_number, -1) = decode(p_collection_type , 'C', nvl(ms.refresh_number, -1)
               , 'P', nvl(ms.refresh_number, -1)
               , 'I', p_refresh_number);

/* Declare Collections variables */
a_plan_id				    number_arr := number_arr();
a_publisher_id  			number_arr:= number_arr();
a_publisher_site_id 		number_arr:= number_arr();
a_publisher_name        	company_names := company_names();
a_publisher_site_name   	company_site_names := company_site_names() ;

a_inventory_item_id  		number_arr := number_arr();
a_customer_item_name		item_names := item_names() ;
a_customer_item_description item_descriptions := item_descriptions();
a_supplier_item_name		item_names := item_names();
a_supplier_item_description item_descriptions := item_descriptions();

a_new_order_quantity 		number_arr:= number_arr();
a_order_type 				number_arr:= number_arr();
a_ship_date 				dates := dates();
a_receipt_date 				dates := dates();
a_order_line_number  		order_line_numbers := order_line_numbers();
a_order_number 				order_numbers := order_numbers();
a_ship_to_party_id  		number_arr:= number_arr();
a_ship_to_party_site_id 	number_arr:= number_arr();
a_ship_to_party_name    	company_names := company_names();
a_ship_to_party_site_name 	company_site_names := company_site_names();
a_uom_code                  tp_uom_codes := tp_uom_codes();
a_primary_uom_code			tp_uom_codes := tp_uom_codes();
a_tp_uom_code				tp_uom_codes := tp_uom_codes();
a_pub_order_type_desc		order_types  := order_types();
a_key_date  				dates := dates();
a_partner_id 				number_arr:= number_arr();
a_partner_site_id 			number_arr:= number_arr();
a_orig_sr_instance_id 		number_arr:= number_arr();
a_organization_id 			number_arr:= number_arr();
a_end_order_number			order_numbers := order_numbers();
a_end_order_line_number     order_line_numbers := order_line_numbers();
a_order_placement_date 		dates := dates();
a_primary_quantity			number_arr:= number_arr();
a_tp_quantity				number_arr:= number_arr();
a_end_order_rel_number      end_order_rel_nums := end_order_rel_nums();

a_supplier_id               number_arr := number_arr();
a_customer_id               number_arr := number_arr();
a_supplier_site_id          number_arr := number_arr();
a_customer_site_id          number_arr := number_arr();
a_need_by_date              dates := dates();
a_order_rel_number          end_order_rel_nums := end_order_rel_nums();

a_request_date				dates := dates();

l_supplier_item_name	MSC_SUP_DEM_ENTRIES.SUPPLIER_ITEM_NAME%TYPE;
l_lead_time			NUMBER;
l_supplier_uom			MSC_SUP_DEM_ENTRIES.TP_UOM_CODE%TYPE;
l_conversion_found		BOOLEAN;
l_conversion_rate		NUMBER;
v_sql_stmt				VARCHAR2(5000);
l_end_order_type_desc VARCHAR2(80);
full_language	VARCHAR2(80);
l_language_code VARCHAR2(10);

    BEGIN

        --======================
        -- Get the user language
        --======================
/*  BUG #3845796 :Using Applications Session Language in preference to ICX_LANGUAGE profile value */

        l_language_code := USERENV('LANG');

	IF(l_language_code IS NULL) THEN
        full_language := fnd_profile.value('ICX_LANGUAGE');

        IF full_language IS NOT NULL THEN
            BEGIN
                SELECT language_code
                INTO   l_language_code
                FROM   fnd_languages
                WHERE  nls_language = full_language;
           EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while fetching user language');
           END;
        ELSE
            l_language_code := 'US';
        END IF;
        END IF;
		LOG_MESSAGE('The language Code :'||l_language_code);

		-- =====================================
		-- Get the description for PO Order Type
		-- =====================================
		BEGIN
			select meaning into l_end_order_type_desc
			from fnd_lookup_values flv
			where flv.lookup_code = G_PO
			and   flv.lookup_type = 'MSC_X_ORDER_TYPE'
			and   flv.language = l_language_code ;

			LOG_MESSAGE('l_end_order_type_desc :'||l_end_order_type_desc);

		EXCEPTION WHEN OTHERS THEN
			LOG_MESSAGE('Error while fetching end order type description');
			LOG_MESSAGE(SQLERRM);
        END;

        p_return_status := TRUE;

        -- =====================================================
        -- Delete previously collected all Sales Order records
        -- in case of Complete Refresh and Targeted refresh
        -- collections.
        -- Use following filter to delete the records.
        -- 1. order_type = G_SALES_ORDER
        -- 2. customer_id = G_OEM_ID
        -- 3. ack_flag = 'Y'
        -- =====================================================

        IF (p_collection_type = 'P' OR p_collection_type = 'C') THEN
        BEGIN

			v_sql_stmt :=
            ' DELETE MSC_SUP_DEM_ENTRIES '
            ||' WHERE plan_id = -1'
            ||' and   customer_id = 1'
			||' and   customer_site_id '|| p_in_org_str
            ||' and   ack_flag = '||'''Y'''
            ||' and   publisher_order_type = 14';

            EXECUTE IMMEDIATE v_sql_stmt;

            COMMIT;

        EXCEPTION WHEN OTHERS THEN

            LOG_MESSAGE('Error while deleting records from MSC_SUP_DEM_ENTRIES');
            p_return_status := FALSE;
        END;

        END IF;

        BEGIN

            OPEN supplierSalesOrders(l_language_code);
            FETCH supplierSalesOrders BULK COLLECT INTO
                a_plan_id ,
				a_publisher_id  ,
				a_publisher_site_id ,  -- Supplier's company_site_id
				a_publisher_name,      -- Supplier's company name
				a_publisher_site_name, --   publisher_site_name -- Supplier's company site name
				a_inventory_item_id, --     inventory_item_id
				a_new_order_quantity,   -- quantity
				a_order_type,     -- publisher_order_type
				a_receipt_date, --receipt_date
				a_order_line_number,  --     Order_line_number
				a_order_number , --        order_number
				a_ship_to_party_id ,
				a_ship_to_party_site_id,
				a_ship_to_party_name,
				a_ship_to_party_site_name,
				a_customer_item_name,
				a_customer_item_description,
				a_uom_code,
				a_pub_order_type_desc,
				a_partner_id ,
				a_partner_site_id ,
				a_orig_sr_instance_id,
				a_organization_id,
				a_end_order_number,
				a_end_order_line_number,
				a_end_order_rel_number,
				a_order_placement_date,
				a_request_date;

            CLOSE supplierSalesOrders;

        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('ERROR while fetching from supplierSalesOrders cursor');
            LOG_MESSAGE(SQLERRM);
            p_return_status := FALSE;
            RAISE;
        END;

        LOG_MESSAGE('No. of Records for PO ACK :'||a_plan_id.COUNT);

        --=======================================================================
        -- Delete the previously collected Suppliers Sales Orders. We need to do
        -- this for net change type of collections.

        -- We will get end_order_number - end_order_line_number combinations from
        -- supplierSalesOrders cursor.
        -- We will delete all Supplier Sales Orders for these combination and
        -- re-insert them.

        -- Delete the PO Acknowledgment Records. Use following filter
        -- while deleting the records.
        -- 1. The order_type = 'Sales Order'
        -- 2. ack_flag = 'Y'. This indicates that the record is collected
        --    from ISP
        -- 3. Following columns are used to locate unique record.
        --    a. publisher_id
        --    b. publisher_site_id
        --    c. supplier_id
        --    d. supplier_site_id
        --    e. inventory_item_id
        --    f. customer_id
        --    g. customer_site_id
        --    h. order_type
        --    i. end_order_number
        --    j. end_order_line_number
        --================================================================

        IF (p_collection_type = 'I') THEN

        IF  a_plan_id.COUNT > 0 THEN
            BEGIN
                FORALL i IN 1..a_plan_id.COUNT
                    DELETE MSC_SUP_DEM_ENTRIES
                    WHERE plan_id = G_PLAN_ID
                    and   publisher_id = a_publisher_id(i)
                    and   publisher_site_id = a_publisher_site_id(i)
                    and   supplier_id = a_publisher_id(i)
                    and   supplier_site_id = a_publisher_site_id(i)
                    and   customer_id = a_ship_to_party_id(i)
                    and   customer_site_id = a_ship_to_party_site_id(i)
                    and   ack_flag = 'Y'
                    and   inventory_item_id = a_inventory_item_id(i)
					and   end_order_type = G_PO
                    and   end_order_number = a_end_order_number(i)
                    and   end_order_line_number = a_end_order_line_number(i)
					and   end_order_rel_number  = a_end_order_rel_number(i);

                COMMIT;

            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while deleting Supplier response records for net change collections');
                p_return_status := FALSE;
            END;

        END IF;

        END IF;

        --========================================================================
        -- Derive values of columns which are not addressed in Sales Order cursor.
        --========================================================================

        IF a_plan_id.COUNT > 0 THEN
            FOR i IN 1..a_plan_id.COUNT LOOP

            -- Initialize the variables
            a_supplier_item_name.EXTEND;
            a_primary_uom_code.EXTEND;
            a_primary_quantity.EXTEND;
            a_ship_date.EXTEND;
        	a_supplier_item_description.EXTEND;
        	a_key_date.EXTEND;


           		l_supplier_item_name	:= null;
    	   		l_lead_time := 0;
    	   		l_supplier_uom    := null;
    	   		l_conversion_rate := null;

            BEGIN

    		    OPEN itemSuppliers(a_organization_id(i),
    		             	   	   a_orig_sr_instance_id(i),
    		       		           a_inventory_item_id(i),
    		       		           a_partner_id(i),
    		        	           a_partner_site_id(i));

    		    FETCH itemSuppliers INTO l_supplier_item_name,
    		                    		 l_lead_time,
    		            		         l_supplier_uom;

		        CLOSE itemSuppliers;


		    EXCEPTION WHEN OTHERS THEN
		       LOG_MESSAGE(SQLERRM);

		       l_supplier_item_name := null;
		       l_lead_time := null;
		       l_supplier_uom := null;

		       LOG_MESSAGE('Error in ItemSupplier');
		    END;

		    a_supplier_item_name(i) := nvl(l_supplier_item_name, a_customer_item_name(i));
		    -- ASL does not contain Supplier Item Description, so defaulting it with name
     	    a_supplier_item_description.EXTEND;
		    a_supplier_item_description(i) := a_supplier_item_name(i);
    	    a_primary_uom_code.EXTEND;
		    a_primary_uom_code(i) := nvl(l_supplier_uom, a_uom_code(i));


		    --===============================================
		    -- Get the conversion rate and derive tp_quantity
		    --===============================================
		    msc_x_util.get_uom_conversion_rates
		       (a_uom_code(i),
                a_primary_uom_code(i),
                a_inventory_item_id(i),
                l_conversion_found,
                l_conversion_rate);


                IF l_conversion_found THEN
                    a_primary_quantity(i) := a_new_order_quantity(i) * l_conversion_rate;
                ELSE
                    a_primary_quantity(i) := a_new_order_quantity(i);
                END IF;

	       --====================================================
	       -- Derive the ship_date from receipt_date information.
	       --====================================================
            a_ship_date(i) := MSC_X_UTIL.UPDATE_SHIP_RCPT_DATES ( a_ship_to_party_id(i),  -- Customer
            													  a_ship_to_party_site_id(i), -- Customer Site
            													  a_publisher_id(i), -- Supplier
            													  a_publisher_site_id(i), -- Supplier Site
            													  G_PO, --a_order_type(i), -- Order Type
            													  a_inventory_item_id(i), -- Inventory Item Id
            													  NULL,
            													  a_receipt_date(i)
            													 );


           a_key_date(i) := nvl(a_ship_date(i), a_receipt_date(i));

           END LOOP;

		END IF;


        --========================
        -- Insert the records
        --========================
        IF  a_plan_id.COUNT > 0 THEN
            BEGIN
                FORALL i IN 1..a_plan_id.COUNT
                	INSERT INTO MSC_SUP_DEM_ENTRIES
                         (
                         -- Record keys / misc. columns
                         transaction_id,
                         plan_id	,
                         sr_instance_id ,
                         last_refresh_number,
                         ack_flag,

                         -- Trading Partner information.
                         publisher_id	,
                         publisher_site_id	,
                         publisher_name		,
                         publisher_site_name	,
                         customer_id	,
                         customer_name ,
                         customer_site_id,
                         customer_site_name,
                         supplier_id,
                         supplier_site_id,
                         supplier_name,
                         supplier_site_name,
                         ship_to_party_id,
       		             ship_to_party_site_id,
       		             ship_to_party_name,
       		             ship_to_party_site_name,
       		             ship_from_party_id,
       		             SHIP_FROM_PARTY_SITE_ID,
       		             SHIP_FROM_PARTY_NAME,
       		             SHIP_FROM_PARTY_SITE_NAME,
						 end_order_publisher_id,
						 end_order_publisher_site_id,
						 end_order_publisher_name,
						 end_order_publisher_site_name,

                         -- Item Related information
                         inventory_item_id	,
                         item_name 	,
                         publisher_item_name ,
                         owner_item_name,
                         supplier_item_name,
                         customer_item_name,

                         item_description,
                         pub_item_description 	,
                         owner_item_description,
                         supplier_item_description,
                         customer_item_description,

                         -- Quantity Related information
                         quantity	     ,
                         uom_code 		 ,
                         primary_quantity,
                         primary_uom	 ,
                         tp_quantity     ,
                         tp_uom_code     ,
                         bucket_type	,
                         bucket_type_desc	,

                         -- Document information
                         order_number	,
                         line_number 	,
                         comments	,
                         publisher_order_type,
                         publisher_order_type_desc	,
						 end_order_type         ,
                         tp_order_type_desc 	,
                         end_order_type_desc 	,
                         end_order_number       ,
                         end_order_line_number  ,
						 end_order_rel_number   ,

                         -- Dates
                         ship_date	,
                         receipt_date	,
                         key_date 	,
						 new_order_placement_date ,
						 request_date,

                         -- Row who columns
                         created_by 	,
                         creation_date	,
                         last_updated_by,
                         last_update_date
                		)
            			values
            			(
                 		 -- ============================
                 		 -- Record keys / misc. columns
                 		 -- ============================
                 		 msc_sup_dem_entries_s.nextval,
                 		 a_plan_id(i),
                 		 G_SR_INSTANCE_ID,
                 		 msc_cl_refresh_s.nextval, --last_refresh_number,
                 		 'Y',

						 -- ============================
                 		 -- Trading Partner information.
                 		 -- ============================
                         -- Publisher
						 a_publisher_id(i)	,
                         a_publisher_site_id(i)	,
                         a_publisher_name(i)		,
                         a_publisher_site_name(i)	,

						 -- Customer
                         a_ship_to_party_id(i), --customer_id	,
                         a_ship_to_party_name(i), --customer_name ,
                         a_ship_to_party_site_id(i), --customer_site_id,
                         a_ship_to_party_site_name(i), --customer_site_name,
						 -- Supplier
                         a_publisher_id(i), --a_supplier_id
                         a_publisher_site_id(i), --supplier_site_id,
                         a_publisher_name(i), --supplier_name,
                         a_publisher_site_name(i), --supplier_site_name,

						 -- Ship To Party
                         a_ship_to_party_id(i), --customer_id	,
                         a_ship_to_party_site_id(i), --customer_site_id,
                         a_ship_to_party_name(i), --customer_name ,
						 a_ship_to_party_site_name(i), --customer_site_name,

						 -- Ship From Party
                         a_publisher_id(i), --a_supplier_id
                         a_publisher_site_id(i), --supplier_site_id,
                         a_publisher_name(i), --supplier_name,
                         a_publisher_site_name(i), --supplier_site_name,

						 -- End Order Publisher
						 a_ship_to_party_id(i),
						 a_ship_to_party_site_id(i),
                         a_ship_to_party_name(i), --customer_name ,
						 a_ship_to_party_site_name(i), --customer_site_name,

						 -- ============================
                         -- Item related information
                 		 -- ============================
                         a_inventory_item_id(i)	,
                         a_customer_item_name(i) , -- Item Name
                         a_supplier_item_name(i) , -- Publisher Item Name
                         a_customer_item_name(i) , -- Owner Item Name
                         a_supplier_item_name(i),  -- Supplier Item Name
                         a_customer_item_name(i),  -- Customer Item Name

                         a_customer_item_description(i), -- Item Desc.
                         a_supplier_item_description(i), -- Publisher Item Desc
                         a_customer_item_description(i), -- owner_item_description,
                         a_supplier_item_description(i), -- Supplier Item
                         a_customer_item_description(i), -- Customer Item
                         -- ============================
                         -- Quantity Related information
                         -- ============================
                         a_new_order_quantity(i)	,
                         a_uom_code(i) , --uom_code
                         a_primary_quantity(i) , -- Qty corresponding to Supplier's UOM
                         a_primary_uom_code(i)	,-- Supplier's UOM in ASL, If null then from Item Master
                         a_new_order_quantity(i)	, -- TP quantity
                         a_uom_code(i)     ,
                         1 , --bucket_type
                         'Day' , --bucket_type_desc

						 -- ====================
                         -- Document information
						 -- ====================
                         a_order_number(i)	        ,
                         a_order_line_number(i) 	,
                         'PUBLISH'	                , -- comments
                         a_order_type(i)            ,
                         a_pub_order_type_desc(i)	,
						 G_PO                       ,
                         l_end_order_type_desc      ,  --a_pub_order_type_desc(i) , --tp_order_type_desc 	,
                         l_end_order_type_desc      ,  --end_order_type_desc 	,
                         a_end_order_number(i)      ,
                         a_end_order_line_number(i) ,
						 a_end_order_rel_number(i)  ,

						 -- =====
                         -- Dates
						 -- =====
                         a_ship_date(i) , --ship_date	,
                         a_receipt_date(i), --receipt_date	,
                         a_key_date(i) 	,
						 a_order_placement_date(i) ,
						 a_request_date(i),

						 --=================
                         -- Row who columns
						 --=================
                         p_user_id   , --created_by 	,
                         sysdate ,     --creation_date	,
                         p_user_id ,   --last_updated_by,
                         sysdate      --last_update_date
                         );

                         COMMIT;

            EXCEPTION WHEN OTHERS THEN
            	LOG_MESSAGE('Error while inserting Supplier Response records for net change/complete refresh collections');
				LOG_MESSAGE(SQLERRM);
            	p_return_status := FALSE;
            END;
        END IF;

        -- ===========================================================================
        -- By this time we have collected PO supplies ans Supplier responses in
        -- msc_sup_dem_entries. Now we will address rejected PO shipments by Supplier.
        --
        -- We will bulk collect all rejected type of responses and then will bulk
        -- update msc_sup_dem_entries PO records with acceptance_required_flag = 'R'
        --
        -- This flag will be used by netting engine in order to generate PO rejected
        -- exception.
        -- ===========================================================================


        BEGIN

            OPEN rejectedPoShipments;

            FETCH rejectedPoShipments BULK COLLECT INTO
                a_plan_id,
                a_supplier_id,
                a_supplier_site_id,
                a_inventory_item_id,
                a_order_type,
                a_customer_id,
                a_customer_site_id,
                a_order_number,
                a_order_line_number,
                a_order_rel_number,
                a_need_by_date;

            CLOSE rejectedPoShipments;


        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while fetching from rejectedPoShipments');
            LOG_MESSAGE(SQLERRM);
            RAISE;
        END;

        IF  a_plan_id.COUNT > 0 THEN

            BEGIN

                FORALL i IN 1..a_plan_id.COUNT

                    UPDATE MSC_SUP_DEM_ENTRIES msde
                    SET acceptance_required_flag = 'R'
                    where
                        msde.publisher_id = a_customer_id(i)
                    and msde.publisher_site_id = a_customer_site_id(i)
                    and msde.customer_id = a_customer_id(i)
                    and msde.customer_site_id = a_customer_site_id(i)
                    and msde.publisher_order_type = a_order_type(i)
                    and msde.supplier_id = a_supplier_id(i)
                    and msde.supplier_site_id = a_supplier_site_id(i)
                    and msde.order_number = a_order_number(i)
                    and msde.line_number = a_order_line_number(i)
                    and msde.release_number = a_order_rel_number(i)
                    and nvl(msde.need_by_date, to_date('01/01/1900', 'dd/mm/yyyy'))
						= nvl(a_need_by_date(i), to_date('01/01/1900', 'dd/mm/yyyy'));

                    COMMIT;

            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while updating msc_supplies for rejected PO Shipments');
                LOG_MESSAGE(SQLERRM);
                RAISE;
            END;


        END IF;

    END PUBLISH_SUPPLIER_RESPONSE;


END  MSC_CL_SUPPLIER_RESP;

/
