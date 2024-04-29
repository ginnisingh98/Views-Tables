--------------------------------------------------------
--  DDL for Package Body PORCPTWF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PORCPTWF" AS
/* $Header: PORCPWFB.pls 120.20.12010000.10 2014/04/04 06:59:00 shindeng ship $*/

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

-- Added parameter to check if distribution data updation is to be skipped
Function  Populate_Order_Info(itemtype  in varchar2,
                          itemkey in varchar2,
			  skip_distribution_updation in varchar2 default 'N') Return number;


/*===========================================================================
  PROCEDURE NAME:	Select_Orders

  DESCRIPTION:          This server procedure is defined as a concurrent
			PL/SQL executable program and is scheduled to run
			from the Concurrent Manager at a regular intervals
			(e.g. every day).

                        This procedure does the following:
			- Open a cursor on RCV_CONFIRM_RECEIPT_V table to
			  select open PO shipments.  The records are grouped
			  by PO number, Requester ID and Due date.

                        - For each unique PO number, Requester ID and Due date
		 	  it calls the Start_Rcpt_Process to initiate the
		 	  Confirm Receipt workflow process.

  CHANGE HISTORY:       WLAU       1/15/1997     Created
                        WLAU       2/25/1997     Added WF_PURGE.total to delete
                                                 the completed WF activities
===========================================================================*/

TYPE rcpt_record IS RECORD (

  line_number        NUMBER,
  expected_qty       NUMBER,
  quantity_received  NUMBER,
  ordered_qty NUMBER,
  unit_of_measure    VARCHAR2(25),
  item_description   VARCHAR2(240),
  currency_code  VARCHAR2(15),
  unit_price NUMBER,
  po_distribution_id NUMBER);

/*===========================================================================
  FUNCTION NAME:	get_txn_error_message

  DESCRIPTION:          Get the Receiving transaction processor error message

  CHANGE HISTORY:       nwang       10/8/1998     Created
                        svasamse    28-May-05   This method is modified to
			                        return the message name instead of
						message text. JRAD Notification
						enhancement.
===========================================================================*/

PROCEDURE get_txn_error_message(x_group_id         IN number,
                                x_RCV_txns_rc      IN number,
                                x_rcv_trans_status IN OUT NOCOPY varchar2,
                                x_message_token  IN OUT NOCOPY varchar2) IS

BEGIN
   x_message_token := NULL;

   IF x_RCV_txns_rc = 1 THEN

      -- Receiving Transaction Manager was timed out
      x_rcv_trans_status:= 'RCV_RCPT_NO_RCV_MANAGER';

   ELSIF x_RCV_txns_rc = 2 THEN

      -- Receiving Transaction Manager is not active
      x_rcv_trans_status:= 'RCV_RCPT_NO_RCV_MANAGER';

   ELSIF x_RCV_txns_rc = 99 THEN

       -- Create Receiving Shipment Headers failed
       x_rcv_trans_status:= 'RCV_RCPT_CREATE_RCVSHIP_FAILED';

   ELSIF x_RCV_txns_rc = 98 THEN

      -- Receiving Transaction Interface records validation failed
      x_rcv_trans_status:= 'RCV_RCPT_VALIDATION_FAILED';

      BEGIN

        -- Try to get the retrieve the first error message
        SELECT int_err.error_message_name
          INTO x_message_token
          FROM po_interface_errors int_err
         WHERE int_err.batch_id = x_group_id
           AND int_err.interface_transaction_id =
               (SELECT MIN(int_err2.interface_transaction_id)
                  FROM po_interface_errors int_err2
                 WHERE int_err2.batch_id = x_group_id);

      EXCEPTION
        when no_data_found then
             x_message_token := null;
      END;

   ELSE

      -- Receiving Transaction Manager failed, return code ...
      x_message_token :=  to_char(x_RCV_txns_rc);
      x_rcv_trans_status := 'RCV_RCPT_RCV_MGR_ERROR';

   END IF;

END get_txn_error_message;


 /*===========================================================================
  PROCEDURE NAME:	Process_Auto_Receive

  DESCRIPTION:          This procedure auto-receives the shipments that have
			auto_receive_flag = 'Y'

  CHANGE HISTORY:       NWANG       10/7/1998     Created
===========================================================================*/

  PROCEDURE Process_Auto_Receive(x_po_header_id		IN NUMBER,
	  			 x_requester_id		IN NUMBER,
				 x_exp_receipt_date	IN DATE) IS

  x_group_id                  NUMBER;
  x_inserted_txn              BOOLEAN;
  x_insert_txns_count         NUMBER := 0;
  x_RCV_txns_rc               NUMBER := 0;
  x_line_location_id	      NUMBER;
  x_po_distribution_id        NUMBER;
  x_expected_receipt_qty      NUMBER;
  x_primary_uom               VARCHAR2(25);
  x_primary_uom_class	      VARCHAR2(10);
  x_item_id		      NUMBER;
  x_org_id		      NUMBER;
  x_rcv_trans_status          VARCHAR2(500) := NULL;
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
  x_insert_txns_status        NUMBER;
  x_auto_receive_flag   VARCHAR2(1);

  t_po_header_id		rcvNumberArray;
  t_line_location_id		rcvNumberArray;
  t_expected_receipt_qty  	rcvNumberArray;
  t_ordered_uom			rcvVarcharArray;
  -- bug 4672728 - the non translated UOM values.
  t_ordered_uom_non_tl          rcvVarcharArray;
  t_item_id			rcvNumberArray;
  t_primary_uom_class		rcvVarcharArray;
  t_org_id			rcvNumberArray;
  t_po_distribution_id		rcvNumberArray;
  t_Comments			rcvVarcharArray;
  t_PackingSlip			rcvVarcharArray;
  t_WayBillNum			rcvVarcharArray;

  type select_shipments_Cursor is ref cursor ;
  Porcpt_Shipment select_shipments_Cursor;

  x_message_token VARCHAR2(2000);

  BEGIN

      SELECT rcv_interface_groups_s.nextval
        INTO   x_group_id
        FROM   sys.dual;

      if x_allow_inv_dest_receipts is NULL then
         x_allow_inv_dest_receipts := 'N';
      end if;

       -- <R12 Confirm Receipt and JRAD Conversion Start>
       -- added condition to retrive the inovice matched lines
       if x_allow_inv_dest_receipts = 'N' then

          OPEN  Porcpt_Shipment for
          	SELECT rcv.po_header_id,
		  po_line_location_id,
                  expected_receipt_qty,
		  primary_uom,
                  -- Bug 4672728
                  primary_uom_non_tl,
		  item_id,
                  primary_uom_class,
                  to_organization_id,
		  po_distribution_id,
		  null,
		  null,
		  null
             FROM  POR_RCV_ALL_ITEMS_V1 rcv
            WHERE ((expected_receipt_date is not NULL
                  AND trunc(rcv.expected_receipt_date + 1) <=
							trunc(SYSDATE))
                 OR EXISTS (SELECT 1 FROM ap_holds aph
                      WHERE aph.line_location_id = rcv.po_line_location_id
		        AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
		        AND aph.release_lookup_code IS NULL
		        AND rcv.quantity_invoiced > quantity_delivered
		       --AND rcv.quantity_invoiced <= ordered_qty    -- Bug 18421821
                        ))
              AND NVL(receipt_required_flag,'N') = 'Y'
              AND destination_type_code = 'EXPENSE'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND po_header_ID = x_po_header_ID
              AND requestor_ID = x_requester_ID;
       else
           OPEN  Porcpt_Shipment for
          	SELECT po_header_id,
		  po_line_location_id,
                  expected_receipt_qty,
		  primary_uom,
                  -- Bug 4672728
                  primary_uom_non_tl,
		  item_id,
                  primary_uom_class,
                  to_organization_id,
		  po_distribution_id,
		  null,
		  null,
		  null
            FROM  POR_RCV_ALL_ITEMS_V1 rcv
            WHERE ((expected_receipt_date is not NULL
                  AND trunc(rcv.expected_receipt_date + 1) <=
							trunc(SYSDATE))
                 OR EXISTS (SELECT 1 FROM ap_holds aph
                      WHERE aph.line_location_id = rcv.po_line_location_id
		        AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
		        AND aph.release_lookup_code IS NULL
		        AND rcv.quantity_invoiced > quantity_delivered
		        --AND rcv.quantity_invoiced <= ordered_qty  -- Bug 18421821
                        ))
              AND NVL(receipt_required_flag,'N') = 'Y'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND po_header_ID = x_po_header_ID
              AND requestor_ID = x_requester_ID;

        end if; /** AllowInvDest Receipt Check **/
        -- <R12 Confirm Receipt and JRAD Conversion End>

              FETCH porcpt_Shipment BULK COLLECT into t_po_header_id,
					 t_line_location_id,
					 t_expected_receipt_qty,
					 t_ordered_uom,
                                         -- Bug 4672728
                                         t_ordered_uom_non_tl,
					 t_item_id,
					 t_primary_uom_class,
					 t_org_id,
					 t_po_distribution_id,
					 t_Comments,
                            		 t_PackingSlip,
                            		 t_WayBillNum;

	 	x_insert_txns_status := POR_RCV_ORD_SV.groupPoTransaction( t_po_header_id,
					 t_line_location_id,
					 t_expected_receipt_qty,
                                         -- Bug 4672728 - We need to pass the
					 -- non translated UOM for standard UOM conversion
					 --t_ordered_uom,
					 t_ordered_uom_non_tl,
					 SYSDATE,
					 t_item_id,
					 t_primary_uom_class,
					 t_org_id,
					 t_po_distribution_id,
					 x_group_id,
					 'AUTO_RECEIVE',
					 t_Comments,
                            		 t_PackingSlip,
                            		 t_WayBillNum);

                CLOSE Porcpt_Shipment;

	IF x_insert_txns_status = 0 THEN
            x_RCV_txns_rc :=  por_rcv_ord_sv.process_transactions(X_group_id, 'AUTO_RECEIVE');

           IF x_RCV_txns_rc is NOT NULL AND
	      x_RCV_txns_rc > 0 THEN

             get_txn_error_message(x_group_id, x_RCV_txns_rc, x_rcv_trans_status, x_message_token);
           /* IF (x_rcv_trans_status = 'RCV_RCPT_VALIDATION_FAILED') then
                fnd_message.set_name ('PO',x_rcv_trans_status);
                x_rcv_trans_status:= fnd_message.get;
                fnd_message.set_name ('PO',x_message_token);
                x_rcv_trans_status := x_rcv_trans_status || fnd_message.get;
              ELSE IF (x_rcv_trans_status = 'RCV_RCPT_RCV_MGR_ERROR') then
                 fnd_message.set_name ('PO',x_rcv_trans_status);
                 x_rcv_trans_status:= fnd_message.get || x_message_token;
              END IF;
             ash_debug.debug('process auto receive' , x_rcv_trans_status);
             */

          END IF;

        END IF;
  END Process_Auto_Receive;

/*===========================================================================
  PROCEDURE NAME:	Select_Orders

  DESCRIPTION:          This server procedure is defined as a concurrent
			PL/SQL executable program and is scheduled to run
			from the Concurrent Manager at a regular intervals
			(e.g. every day).

                        This procedure does the following:
			- Open a cursor on RCV_CONFIRM_RECEIPT_V table to
			  select open PO shipments.  The records are grouped
			  by PO number, Requester ID and Due date.

                        - For each unique PO number, Requester ID and Due date
		 	  it calls the Start_Rcpt_Process to initiate the
		 	  Confirm Receipt workflow process.

  CHANGE HISTORY:       WLAU       1/15/1997     Created
                        WLAU       2/25/1997     Added WF_PURGE.total to delete
                                                 the completed WF activities
===========================================================================*/

 PROCEDURE Select_Orders  IS


   -- Define cursor for selecting records to start the Purchasing
   -- Confirm Receipt workflow process.  Records are retrieved from
   -- the RCV_CONFIRM_RECEIPT_V view which is shared by the
     -- Receive Orders Web Page.

     type select_orders_Cursor is ref cursor ;

    Porcpt_c select_orders_Cursor;

    x_po_header_id	NUMBER;
    x_po_distribution_id	NUMBER;
  x_requester_id 	NUMBER;
  x_exp_receipt_date	DATE;
  x_WF_ItemKey		VARCHAR2(100);
  x_WF_ItemKey_save     VARCHAR2(100);
  x_auto_receive_flag   VARCHAR2(1);
  x_WF_process_exists   BOOLEAN;
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
  x_wf_itemtype  varchar2(6) := 'PORCPT';
  x_revision_num number;
  x_internal_req_rcpt   Varchar2(1) := FND_PROFILE.value('POR_INTERNAL_CONFIRM_RECEIPT');
  x_sys_date DATE;
  x_item_key_count number;
  x_po_num_rel_num POR_RCV_ALL_ITEMS_V1.PO_NUM_REL_NUM%type;

  BEGIN

   x_WF_ItemKey 	:= ' ';
   x_WF_ItemKey_save 	:= ' ';

   -- Call WF purge API to remove any existing Confirm Receipts WF items
   -- which are completed with an END_DATE less than or equal to
   -- SYSDATE (default).  This is to ensure that the Selection
   -- process can start the workflow process for the same item key value.
   --
   -- The WF purge API will not remove any WF items which are still
   -- opened with END_DATE = NULL;


   WF_PURGE.total ('PORCPT');

   -- Start the Confirm Receipts workflow Selection process


   if x_allow_inv_dest_receipts is NULL then
       x_allow_inv_dest_receipts := 'N';
   end if;


   -- Start the Confirm Receipts workflow Selection process

   if x_allow_inv_dest_receipts = 'N' then
      -- <R12 Confirm Receipt and JRAD Conversion Start>
      -- Modified the query to retrive the lines if an invoice
      -- is matched for the line. Joined with AP_HOLDS
      OPEN  Porcpt_c for
        SELECT rcv.po_header_ID,  rcv.requestor_ID,
               rcv.expected_receipt_date, rcv.revision_num,
               rcv.po_distribution_id, po_num_rel_num
        FROM  POR_RCV_ALL_ITEMS_V1 rcv
        WHERE ( (rcv.expected_receipt_date is not NULL
                AND trunc(rcv.expected_receipt_date + 1) <=
                                                trunc(SYSDATE)
                 )
	       OR EXISTS (SELECT 1 FROM ap_holds aph
                 WHERE aph.line_location_id = rcv.po_line_location_id
	           AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	           AND aph.release_lookup_code IS NULL
	           AND rcv.quantity_invoiced > quantity_delivered
	           --AND rcv.quantity_invoiced <= ordered_qty   --Bug 18421821
                  )
               )
          AND is_complex_po(rcv.po_header_ID)<>'Y' -- Bug 15921367
          AND NVL(receipt_required_flag,'N') = 'Y'
          AND destination_type_code = 'EXPENSE'
          AND requestor_ID is not NULL
	  AND expected_receipt_qty > 0
        GROUP BY rcv.po_header_ID, rcv.requestor_ID,
                 rcv.expected_receipt_date, rcv.revision_num,
                 rcv.po_distribution_id, po_num_rel_num
        /* bug 18075024: add ORDER BY clause, alongside with the
                         x_WF_ItemKey <> x_WF_ItemKey_save condition below,
                         preventing duplicate workflow itemkey to be submitted */
        ORDER BY rcv.po_header_ID, rcv.requestor_ID;
   else
      OPEN  Porcpt_c for
        SELECT rcv.po_header_ID, rcv.requestor_ID,
               rcv.expected_receipt_date, rcv.revision_num,
               rcv.po_distribution_id, po_num_rel_num
	FROM  POR_RCV_ALL_ITEMS_V1 rcv
        WHERE ( (rcv.expected_receipt_date is not NULL
                AND trunc(rcv.expected_receipt_date + 1) <=
                                                trunc(SYSDATE)
                 )
	       OR EXISTS (SELECT 1 FROM ap_holds aph
                 WHERE aph.line_location_id = rcv.po_line_location_id
	           AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	           AND aph.release_lookup_code IS NULL
	           AND rcv.quantity_invoiced > quantity_delivered
	           --AND rcv.quantity_invoiced <= ordered_qty      --Bug 18421821
                  )
               )
          AND is_complex_po(rcv.po_header_ID)<>'Y' -- Bug 15921367
          AND NVL(receipt_required_flag,'N') = 'Y'
          AND requestor_ID is not NULL
	  AND expected_receipt_qty > 0
        GROUP BY rcv.po_header_ID, rcv.requestor_ID,
                 rcv.expected_receipt_date, rcv.revision_num,
                 rcv.po_distribution_id, po_num_rel_num
        /* bug 18075024: add ORDER BY clause, alongside with the
                         x_WF_ItemKey <> x_WF_ItemKey_save condition below,
                         preventing duplicate workflow itemkey to be submitted */
        ORDER BY rcv.po_header_ID, rcv.requestor_ID;
        -- <R12 Confirm Receipt and JRAD Conversion End>
      end if; /** AllowInvDest Receipt Check */

   LOOP

   	FETCH Porcpt_c into 	x_po_header_id,
		       		x_requester_id,
				x_exp_receipt_date,
	                        x_revision_num,
	                        x_po_distribution_id,
				x_po_num_rel_num;

        -- Contruct Confirm Receipt workflow Item Key in the combination of:
        --     PO_Header_ID + Requester_ID + Sysdate
        --

	EXIT WHEN Porcpt_c%NOTFOUND;


	 BEGIN
     		select PORL.auto_receive_flag
     		into  x_auto_receive_flag
                from  PO_REQUISITION_LINES PORL,
                      PO_REQ_DISTRIBUTIONS PORD,
		      PO_DISTRIBUTIONS pod
                where PORD.DISTRIBUTION_ID = POD.REQ_DISTRIBUTION_ID AND
		  PORD.REQUISITION_LINE_ID = PORL.requisition_line_id AND
		  POD.PO_DISTRIBUTION_ID = x_po_distribution_id;


          EXCEPTION
           when no_data_found then
              x_auto_receive_flag := null;
           END;

	 IF Porcpt_c%FOUND AND
	   (NVL(x_auto_receive_flag,'N') = 'Y') THEN


	     -- Process the auto receive shipments

	     Process_Auto_Receive(x_po_header_id,
				  x_requester_id,
				  x_exp_receipt_date);
         ELSE
             select sysdate into x_sys_date from dual;

   	     x_WF_ItemKey := to_char(x_po_header_id) ||  ';' ||
		 	     to_char(x_requester_id) || ';' ||
  		   	     to_char(x_sys_date,'DD-MON-YYYY:HH24:MI');
             IF Porcpt_c%FOUND AND
                x_WF_ItemKey <> x_WF_ItemKey_save THEN

	        -- <R12 Confirm Receipt and JRAD Conversion Start>

                -- Requirement - We should not send the notification if
	        -- there are any active processes for the po_header_id and
	        -- requester_id combination.
                SELECT count(1) into x_item_key_count
                FROM wf_items
                WHERE item_type = 'PORCPT'
	          AND item_key like x_po_header_id||';'|| x_requester_id||';%'
   	          AND END_DATE is null;

                -- <R12 Confirm Receipt and JRAD Conversion End>

                IF x_item_key_count = 0 THEN

                   -- Workflow item does not exist
                   -- Invoke the Confirm Receive workflow starting procedure
                   -- for every unique workflow Item key.

		   -- <R12 Confirm Receipt and JRAD Conversion Start>

	           -- Clean the po distribtions table
		   -- set the wf_item_key column with null value
		   -- if there are any existing distribtion lines with
		   -- old match.
		   update po_distributions
		   set wf_item_key = ''
		   where po_header_id = x_po_header_ID
		     and wf_item_key like x_po_header_ID||';'||x_requester_id||';%';

                   -- <R12 Confirm Receipt and JRAD Conversion End>
    	           PORCPTWF.Start_Rcpt_Process(x_po_header_id,
    	  	  		    	       x_requester_id,
    					       x_exp_receipt_date,
    					       x_wf_itemkey,
					       x_revision_num,
					       'N',
					       '-1',
					       x_po_num_rel_num);


                   COMMIT;

                 END IF;

                -- Save the ItemKey for the next comparison
    	        x_WF_ItemKey_Save := x_WF_ItemKey;

             END IF;

	  END IF;


   EXIT WHEN Porcpt_c%NOTFOUND;

   END LOOP;

   CLOSE porcpt_c;



   if x_internal_req_rcpt is not null and x_internal_req_rcpt = 'Y' then
	Select_Internal_Orders;
   end if;

    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Select_Orders','No data found');
   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Select_Orders','SQL error ' || sqlcode);
    RAISE;


  END Select_Orders;



/*===========================================================================
  PROCEDURE NAME:	Process_Auto_Receive_Internal

  DESCRIPTION:          This procedure auto-receives the shipments for Internal Order
			that have auto_receive_flag = 'Y'

  CHANGE HISTORY:       ASABADRA       03/05/2002     Created
===========================================================================*/
  PROCEDURE Process_Auto_Receive_Internal (x_header_id		IN NUMBER,
	  			  x_requester_id		IN NUMBER,
		 		  x_exp_receipt_date		IN DATE) IS

  x_group_id                  NUMBER;
  x_inserted_txn_status              NUMBER := 0;
  x_RCV_txns_rc               NUMBER := 0;
  x_rcv_trans_status          VARCHAR2(500) := NULL;
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');

  t_req_line_id			rcvNumberArray;
  t_expected_receipt_qty	rcvNumberArray;
  t_ordered_uom			rcvVarcharArray;
  t_item_id			rcvNumberArray;
  t_primary_uom_class		rcvVarcharArray;
  t_org_id			rcvNumberArray;
  t_waybillNum			rcvVarcharArray;
  t_comments			rcvVarcharArray;
  t_packingSlip			rcvVarcharArray;



  type select_shipments_Cursor is ref cursor ;
  Porcpt_Shipment select_shipments_Cursor;

  x_message_token VARCHAR2(2000);

  BEGIN

      SELECT rcv_interface_groups_s.nextval
        INTO   x_group_id
        FROM   sys.dual;

      if x_allow_inv_dest_receipts is NULL then
         x_allow_inv_dest_receipts := 'N';
      end if;

       if x_allow_inv_dest_receipts = 'N' then
          OPEN  Porcpt_Shipment for
		SELECT REQUISITION_LINE_ID,
			EXPECTED_RECEIPT_QTY,
			PRIMARY_UOM,
			ITEM_ID,
			PRIMARY_UOM_CLASS,
			TO_ORGANIZATION_ID,
			COMMENTS,
 			PACKING_SLIP,
 			WAYBILL_AIRBILL_NUM
            FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
            WHERE expected_receipt_date is not NULL
              AND expected_receipt_date = x_exp_receipt_date
              AND destination_type_code = 'EXPENSE'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND so_header_ID = x_header_ID
              AND requestor_ID = x_requester_ID;
       else
           OPEN  Porcpt_Shipment for
		SELECT REQUISITION_LINE_ID,
			EXPECTED_RECEIPT_QTY,
			PRIMARY_UOM,
			ITEM_ID,
			PRIMARY_UOM_CLASS,
			TO_ORGANIZATION_ID,
			COMMENTS,
 			PACKING_SLIP,
 			WAYBILL_AIRBILL_NUM
            FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
            WHERE expected_receipt_date is not NULL
              AND expected_receipt_date = x_exp_receipt_date
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND so_header_ID = x_header_ID
              AND requestor_ID = x_requester_ID;

        end if; /** AllowInvDest Receipt Check **/

             FETCH porcpt_Shipment BULK COLLECT into t_req_line_id,
                        t_expected_receipt_qty,
                        t_ordered_uom,
                        t_item_id,
			t_primary_uom_class,
			t_org_id,
                        t_comments,
                        t_packingSlip,
                        t_waybillNum;

	     CLOSE Porcpt_Shipment;

       --ash_debug.debug('process auto receive' , '01');


             x_inserted_txn_status :=   POR_RCV_ORD_SV.groupInternalTransaction (t_req_line_id,
                        t_expected_receipt_qty,
                        t_ordered_uom,
                        t_item_id,
			t_primary_uom_class,
			t_org_id,
                        t_comments,
                        t_packingSlip,
                        t_waybillNum,
			x_group_id,
			x_exp_receipt_date,
			'WP4_CONFIRM');

      --ash_debug.debug('process auto receive x_inserted_txn_status' , x_inserted_txn_status);



	IF x_inserted_txn_status = 0 THEN

            x_RCV_txns_rc :=  por_rcv_ord_sv.process_transactions(X_group_id, 'AUTO_RECEIVE');

           IF x_RCV_txns_rc is NOT NULL AND
	      x_RCV_txns_rc > 0 THEN

             get_txn_error_message(x_group_id, x_RCV_txns_rc, x_rcv_trans_status, x_message_token);
          /* IF (x_rcv_trans_status = 'RCV_RCPT_VALIDATION_FAILED') then
                fnd_message.set_name ('PO',x_rcv_trans_status);
                x_rcv_trans_status:= fnd_message.get;
                fnd_message.set_name ('PO',x_message_token);
                x_rcv_trans_status := x_rcv_trans_status || fnd_message.get;
              ELSE IF (x_rcv_trans_status = 'RCV_RCPT_RCV_MGR_ERROR') then
                fnd_message.set_name ('PO',x_rcv_trans_status);
                x_rcv_trans_status:= fnd_message.get || x_message_token;
              END IF;
              ash_debug.debug('process auto receive' , x_rcv_trans_status);
             */

          END IF;

        END IF;
  END Process_Auto_Receive_Internal;


PROCEDURE Select_Internal_Orders  IS


   -- Define cursor for selecting records to start the Purchasing
   -- Confirm Receipt workflow process.  Records are retrieved from
   -- the RCV_CONFIRM_RECEIPT_V view which is shared by the
     -- Receive Orders Web Page.

     type select_orders_Cursor is ref cursor ;

    Porcpt_c select_orders_Cursor;

    x_header_id	NUMBER;
    x_requisition_line_id	NUMBER;
    x_requisition_header_id	NUMBER;

    --po_header_id	NUMBER;
    --po_distribution_id	NUMBER;
  x_requester_id 	NUMBER;
  x_exp_receipt_date	DATE;
  x_WF_ItemKey		VARCHAR2(100);
  x_WF_ItemKey_save     VARCHAR2(100);
  x_auto_receive_flag   VARCHAR2(1);
  x_WF_process_exists   BOOLEAN;
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
  ssp_version VARCHAR2(30) := FND_PROFILE.value('POR_SSP_VERSION');
  x_ssp_version_gt4 VARCHAR2(10) := 'Y';
  x_wf_itemtype  varchar2(6) := 'PORCPT';
  x_revision_num number;
  x_item_key_count number;

  BEGIN

   po_debug.set_file_io(true);

   x_WF_ItemKey 	:= ' ';
   x_WF_ItemKey_save 	:= ' ';

   -- Call WF purge API to remove any existing Confirm Receipts WF items
   -- which are completed with an END_DATE less than or equal to
   -- SYSDATE (default).  This is to ensure that the Selection
   -- process can start the workflow process for the same item key value.
   --
   -- The WF purge API will not remove any WF items which are still
   -- opened with END_DATE = NULL;


   WF_PURGE.total ('PORCPT');

   -- Start the Confirm Receipts workflow Selection process

   if x_allow_inv_dest_receipts is NULL then
       x_allow_inv_dest_receipts := 'N';
   end if;

   -- Start the Confirm Receipts workflow Selection process

      if x_allow_inv_dest_receipts = 'N' then

          OPEN  Porcpt_c for
             SELECT 	so_header_ID,
			requestor_ID,
			expected_receipt_date,
			requisition_line_ID,
			requisition_header_ID
              FROM POR_CONFIRM_INTERNAL_RECEIPT_V
             WHERE expected_receipt_date is not NULL
               AND trunc(expected_receipt_date + 1) <= trunc(SYSDATE)
 	       AND destination_type_code = 'EXPENSE'
               AND requestor_ID is not NULL
	       AND expected_receipt_qty > 0
            GROUP BY so_header_ID, requestor_ID,  expected_receipt_date, requisition_line_ID, requisition_header_ID
            /* bug 18075024: add ORDER BY clause, alongside with the
                             x_WF_ItemKey <> x_WF_ItemKey_save condition below,
                             preventing duplicate workflow itemkey to be submitted */
            ORDER BY so_header_ID, requestor_ID;

       else

           OPEN  Porcpt_c for
             SELECT 	so_header_ID,
			requestor_ID,
			expected_receipt_date,
			requisition_line_ID,
			requisition_header_ID
              FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
              WHERE expected_receipt_date is not NULL
                AND trunc(expected_receipt_date + 1) <= trunc(SYSDATE)
 	        AND requestor_ID is not NULL
		  AND expected_receipt_qty > 0
             GROUP BY so_header_ID, requestor_ID,  expected_receipt_date, requisition_line_ID, requisition_header_ID
            /* bug 18075024: add ORDER BY clause, alongside with the
                             x_WF_ItemKey <> x_WF_ItemKey_save condition below,
                             preventing duplicate workflow itemkey to be submitted */
             ORDER BY so_header_ID, requestor_ID;

      end if; /** AllowInvDest Receipt Check */



   LOOP

   	FETCH Porcpt_c into 	x_header_id,
		       		x_requester_id,
				x_exp_receipt_date,
	                        x_requisition_line_ID,
				x_requisition_header_ID;


        -- Contruct Confirm Receipt workflow Item Key in the combination of:
        --     PO_Header_ID + Requester_ID + Due_Date
        --

	EXIT WHEN Porcpt_c%NOTFOUND;

        --ash_debug.debug('select order :in the loop',x_header_id || ':' || x_requisition_line_ID);

	 BEGIN
     		select PORL.auto_receive_flag
     		into  x_auto_receive_flag
                from  PO_REQUISITION_LINES PORL
                where PORL.requisition_line_id = x_requisition_line_ID;


          EXCEPTION
           when no_data_found then
              x_auto_receive_flag := null;
           END;

        --ash_debug.debug('select order :auto rec flag',x_auto_receive_flag);


	 IF Porcpt_c%FOUND AND
	   (NVL(x_auto_receive_flag,'N') = 'Y') THEN

        --ash_debug.debug('select order :auto rec flag 1',x_auto_receive_flag);

	     -- Process the auto receive shipments

	     Process_Auto_Receive_Internal(x_header_id,
				  x_requester_id,
				  x_exp_receipt_date);

         ELSE

         --ash_debug.debug('select order :auto rec else loop 2',x_auto_receive_flag);

  	     x_WF_ItemKey := to_char(x_header_id) ||  ';' ||
		 		     to_char(x_requester_id) || ';' ||
  		   	             to_char(x_exp_receipt_date,'DD-MON-YYYY');

             IF Porcpt_c%FOUND AND
                x_WF_ItemKey <> x_WF_ItemKey_save THEN

               -- Check if there is any active workflow process running
	       -- for the so_header_id and requester_id combination
               SELECT count(1) into x_item_key_count
               FROM wf_items
               WHERE item_type = 'PORCPT'
	         AND item_key like x_header_id||';'|| x_requester_id||';%'
	         AND END_DATE is null;

--ash_debug.debug('select order : value of x_WF_process_exists ','1');

		IF x_item_key_count = 0 THEN
                   -- Workflow item does not exist
                   -- Invoke the Confirm Receive workflow starting procedure
                   -- for every unique workflow Item key.

-- ash_debug.debug('select order : Just before Start_Rcpt_Process','2');

    	           PORCPTWF.Start_Rcpt_Process(x_header_id,
    	  	  		    	       x_requester_id,
    					       x_exp_receipt_date,
    					       x_wf_itemkey,
					       x_revision_num,
					       'Y',
					       x_requisition_header_id);


                   COMMIT;

                 END IF;

                -- Save the ItemKey for the next comparison
    	        x_WF_ItemKey_Save := x_WF_ItemKey;

             END IF;

	  END IF;


   EXIT WHEN Porcpt_c%NOTFOUND;

   END LOOP;

   CLOSE porcpt_c;

    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Select_Internal_Orders','No data found');
   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Select_Internal_Orders','SQL error ' || sqlcode);
    RAISE;


  END Select_Internal_Orders;




/*===========================================================================
  PROCEDURE NAME:	Start_Rcpt_Process

  DESCRIPTION:          This procedure creates and starts the Confirm Receipt
                        workflow process.

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/

  PROCEDURE Start_Rcpt_Process (x_header_id		IN NUMBER,
	  			x_requester_id		IN NUMBER,
				x_exp_receipt_date	IN DATE,
				x_WF_ItemKey		IN VARCHAR2,
				x_revision_num 		IN NUMBER,
				x_is_int_req		IN VARCHAR2 default 'N',
				x_req_header_id         IN NUMBER   default '-1',
				x_po_num_rel_num        IN VARCHAR2 default null) IS


  l_ItemType 			VARCHAR2(100) := 'PORCPT';
  l_ItemKey  			VARCHAR2(100) := x_WF_ItemKey;

  x_requester_username		WF_USERS.NAME%TYPE;
  x_requester_disp_name		WF_USERS.DISPLAY_NAME%TYPE;
  x_buyer_username          WF_USERS.NAME%TYPE;
  x_buyer_disp_name         WF_USERS.DISPLAY_NAME%TYPE;
  x_buyer_id                    NUMBER := 0;
  x_org_id			NUMBER;

  x_requester_current         BOOLEAN ;
  dummy                       VARCHAR2(1);
  BEGIN

-- ash_debug.debug('Start_Rcpt_Process','0');



	wf_engine.createProcess	    ( ItemType  => l_ItemType,
				      ItemKey   => l_ItemKey,
				      process   => 'PO_CONFIRM_RECEIPT' );

-- ash_debug.debug('Start_Rcpt_Process','1');

        PO_WF_UTIL_PKG.SetItemAttrText(itemtype => l_ItemType,
                                  itemkey  => l_itemkey,
                                  aname    => 'WF_ITEM_KEY',
                                  avalue   => l_ItemKey);

	x_org_id := findOrgId(x_header_id,x_is_int_req);

	setOrgCtx(x_org_id);

-- ash_debug.debug('Start_Rcpt_Process org id',x_org_id);
-- ash_debug.debug('Start_Rcpt_Process int req',x_is_int_req);

	if x_is_int_req = 'Y' then

	  wf_engine.SetItemAttrNumber ( itemtype	=> l_ItemType,
			      	      itemkey  	=> l_itemkey,
  		 	      	      aname 	=> 'SO_HEADER_ID',
			      	      avalue 	=> x_header_id );

	  wf_engine.SetItemAttrNumber ( itemtype => l_ItemType,
			      	      itemkey  	=> l_itemkey,
  		 	      	      aname 	=> 'REQ_HEADER_ID',
			      	      avalue 	=> x_req_header_id);

	else --x_is_int_req = 'N'

	  wf_engine.SetItemAttrNumber (itemtype => l_ItemType,
			      	      itemkey  	=> l_itemkey,
  		 	      	      aname 	=> 'PO_HEADER_ID',
			      	      avalue 	=> x_header_id );

          PO_WF_UTIL_PKG.SetItemAttrText (itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'PO_NUM_REL_NUM',
                                   avalue   => x_po_num_rel_num );

	end if;

	wf_engine.SetItemAttrNumber ( itemtype	=> l_ItemType,
			      	      itemkey  	=> l_itemkey,
  		 	      	      aname 	=> 'REQUESTER_ID',
			      	      avalue 	=> x_requester_id );

	wf_engine.SetItemAttrText   ( itemtype	=> l_itemtype,
	      		     	      itemkey  	=> l_itemkey,
  	      		     	      aname 	=> 'IS_INT_REQ',
			     	      avalue	=> x_is_int_req );

	wf_engine.SetItemAttrText   ( itemtype	=> l_itemtype,
	      		     	      itemkey  	=> l_itemkey,
  	      		     	      aname 	=> 'ORG_ID',
			     	      avalue	=> x_org_id );


	wf_engine.SetItemAttrDate   ( itemtype	=> l_ItemType,
			      	      itemkey  	=> l_itemkey,
  		 	      	      aname 	=> 'DUE_DATE',
			      	      avalue 	=> x_exp_receipt_date );

-- ash_debug.debug('Start_Rcpt_Process int req','5');

	wf_directory.GetUserName    ( p_orig_system    => 'PER',
			   	      p_orig_system_id => x_requester_id,
			   	      p_name 	       => x_requester_username,
			              p_display_name   => x_requester_disp_name);

-- ash_debug.debug('Start_Rcpt_Process int req','6');

        /* Bug 1490215
         * If the requester is not an employee then we will not have any
         * value in the x_requester_username. In this case the notification
         * can go to the buyer.
        */

       /* Bug: 2820973 In addition to above we need to make sure by checking if
          the requester is an active person in HR table. If the requester is
          not an active employee then the notification should go to the buyer.
      */

      Begin

      	Select 'X'
        Into   dummy
      	From   per_workforce_current_x
      	Where  person_id = x_requester_id;

               x_requester_current := TRUE;

      Exception
      when no_data_found then
               x_requester_current := FALSE;
      End;

      if x_is_int_req = 'N' then

        if (x_requester_username is null) or (x_requester_current = FALSE) then

                select agent_id
                into x_buyer_id
                from po_headers
                where po_header_id=x_header_id;

                wf_directory.GetUserName    ( p_orig_system    => 'PER',
                                              p_orig_system_id => x_buyer_id,
                                              p_name           => x_buyer_username,
                                              p_display_name   => x_buyer_disp_name);
                x_requester_username  := x_buyer_username;
                x_requester_disp_name := x_buyer_disp_name;

           end if;

        end if;


	wf_engine.SetItemAttrText   ( itemtype	=> l_itemtype,
	      		     	      itemkey  	=> l_itemkey,
  	      		     	      aname 	=> 'REQUESTER_USERNAME',
			     	      avalue	=> x_requester_username );

	wf_engine.SetItemAttrText   ( itemtype	=> l_itemtype,
	      		     	      itemkey  	=> l_itemkey,
  	      		              aname 	=> 'REQUESTER_DISP_NAME',
			              avalue	=> x_requester_disp_name );

	if x_is_int_req = 'N' then

  	   wf_engine.SetItemAttrNumber   ( itemtype	=> l_itemtype,
	      		     	           itemkey  	=> l_itemkey,
  	      		                   aname 	=> 'PO_REVISION_NUM',
			                   avalue	=> x_revision_num );
        end if;

-- ash_debug.debug('Start_Rcpt_Process int req','7');

	wf_engine.StartProcess 	    ( ItemType  => l_ItemType,
				      ItemKey   => l_ItemKey );

-- ash_debug.debug('Start_Rcpt_Process int req','8');


    EXCEPTION

      	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Start_Rcpt_Process','No data found');
   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Start_Rcpt_Process','SQL error ' || sqlcode);
    RAISE;


  END Start_Rcpt_Process;



/*===========================================================================
  PROCEDURE NAME:	Get_Order_Info

  DESCRIPTION:         	This procedure retrieves the purchase order and
                        requisition information from the RCV_CONFIRM_RECEIPT_V
			table using the PO_HEADER_ID, EXPECTED_RECEIPT_DATE and
 			REQUESTER_ID as search criteria.  The retrieved data
			are used for sending the notification message which
			contains the order header and order line data.

  CHANGE HISTORY:       WLAU       1/15/1997     Created
                        WLAU       4/22/1997     475711 - Changed Quantity_
                                                 Received to Quantity_Delivered
===========================================================================*/

  PROCEDURE Get_Order_Info ( 	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funmode		in varchar2,
				result		out NOCOPY varchar2	) IS


  x_buyer_username          WF_USERS.NAME%TYPE;
  x_buyer_disp_name	      	WF_USERS.DISPLAY_NAME%TYPE;
  x_po_header_id              	NUMBER;
  x_requester_id                NUMBER;

  -- Header info
  --
  x_po_number                 	VARCHAR2(20):= NULL;
  x_supplier_name		PO_VENDORS.VENDOR_NAME%TYPE := NULL;
  x_exp_receipt_date 		DATE;
  x_note_to_receiver 	PO_HEADERS_ALL.NOTE_TO_RECEIVER%TYPE :=NULL;
  x_buyer_id 	  	      	NUMBER := 0;

  -- line info
  --
  x_line_disp 		     	NUMBER := 0;
  x_total_lines                 NUMBER := 0;

  x_qty_rcv_text                VARCHAR2(250):= 'Quantity to be received: ';
  x_qty_rcvd_todate_text        VARCHAR2(250):= 'Quantity received to date: ';
  x_on_req_text                 VARCHAR2(250):= 'on Requisition';

  x_revision_num                number;
  x_org_id                      number;

  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');


  BEGIN


   IF ( funmode = 'RUN'  ) THEN
	--
	--
	x_po_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'PO_HEADER_ID');

	x_org_id       :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'ORG_ID');
	setOrgCtx(x_org_id);


	x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'REQUESTER_ID');

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
			    			  	    itemkey   => itemkey,
			    				    aname  => 'DUE_DATE');


       -- Retrieve the purchase order header info.

       SELECT poh.segment1,
	      pov.vendor_name,
              poh.agent_id,
              poh.note_to_receiver
         INTO x_po_number,
	      x_supplier_name,
              x_buyer_id,
              x_note_to_receiver
	 FROM PO_HEADERS poh,
              PO_VENDORS pov
        WHERE po_header_id = x_po_header_id
          AND poh.vendor_id = pov.vendor_id (+);




	-- Retrieve buyer username and display name.
        -- Store them to the workflow process

	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		     	      aname 	=> 'PO_NUMBER',
			     	      avalue	=> x_po_number );

	wf_engine.SetItemAttrNumber ( itemtype	=> ItemType,
			      	      itemkey  	=> Itemkey,
  		 	      	      aname 	=> 'BUYER_ID',
			      	      avalue 	=> x_buyer_id );

	wf_directory.GetUserName    ( p_orig_system    => 'PER',
			   	      p_orig_system_id => x_buyer_id,
			   	      p_name 	       => x_buyer_username,
			              p_display_name   => x_buyer_disp_name);

	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		     	      aname 	=> 'BUYER_USERNAME',
			     	      avalue	=> x_buyer_username );

	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		              aname 	=> 'BUYER_DISP_NAME',
			              avalue	=> x_buyer_disp_name );


	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		              aname 	=> 'SUPPLIER_DISP_NAME',
			              avalue	=> x_supplier_name );


	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		              aname 	=> 'NOTE_TO_RECEIVER',
			              avalue	=> x_note_to_receiver );

       -- bug 471462
       -- Retrieve translatable text to be constructed in the notifiction body.
       --

       fnd_message.set_name ('PO','RCV_RCPT_QTY_RCV');
       x_qty_rcv_text := '      ' || fnd_message.get;

       fnd_message.set_name ('PO','RCV_RCPT_QTY_RCVD_TODATE');
       x_qty_rcvd_todate_text := '      ' || fnd_message.get;

       fnd_message.set_name ('PO','RCV_RCPT_ON_REQ');
       x_on_req_text := ' ' || fnd_message.get;

       -- <R12 Confirm Receipt and JRAD Notificaion>
       -- Inovking the call to populate_order_info() procedure (new)
       -- instead of executing the code below.
       -- The procedure gets the list of distributions match
       -- either the need by date or invoice match criteria
       -- and populates the respective item attributes

       x_total_lines := populate_order_info(itemtype, itemKey);


   ELSIF ( funmode = 'CANCEL' ) THEN
	--
	NULL;
	--
   END if;




    EXCEPTION
   	WHEN NO_DATA_FOUND THEN

             wf_core.context ('PORCPTWF','Get_Order_Info','No data found');

   	WHEN OTHERS THEN

       	     wf_core.context ('PORCPTWF','Get_Order_Info','SQL error ' || sqlcode);

    RAISE;


  END Get_Order_Info;



 PROCEDURE Is_Internal_Requisition( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result		out NOCOPY varchar2	) IS

    x_is_int_req VARCHAR2(1);


 begin

--ash_debug.debug('Is_Internal_Req','1');

   x_is_int_req :=  wf_engine.GetItemAttrText(itemtype,itemkey,'IS_INT_REQ');
-- ash_debug.debug('Is_Internal_Req value of int req ',x_is_int_req);


   if x_is_int_req = 'Y' then
--   ash_debug.debug('Is_Internal_Req value of int req 1',x_is_int_req);
	result := 'COMPLETE:Y';
	return;
   else
-- ash_debug.debug('Is_Internal_Req value of int req 2',x_is_int_req);

	result := 'COMPLETE:N';
	return;
   end if;

 END Is_Internal_Requisition;



 PROCEDURE Get_Internal_Order_Info( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funmode		in varchar2,
					result		out NOCOPY varchar2	) IS


  x_requester_id                NUMBER;
  x_org_id                      NUMBER;

  -- Header info
  x_so_number                 	VARCHAR2(20):= NULL;
  x_so_header_id                NUMBER;
  x_exp_receipt_date 		DATE;
  x_note_to_receiver    PO_HEADERS_ALL.NOTE_TO_RECEIVER%TYPE :=NULL;

  -- line info
  x_line_disp 		     	NUMBER := 0;
  x_total_lines                 NUMBER := 0;

  x_qty_rcv_text                VARCHAR2(250):= 'Quantity to be received: ';
  x_qty_rcvd_todate_text        VARCHAR2(250):= 'Quantity received to date: ';
  x_on_req_text                 VARCHAR2(250):= 'on Requisition';


  x_revision_num                number;


 x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');


  BEGIN


   IF ( funmode = 'RUN'  ) THEN
	--
	--
	x_so_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'SO_HEADER_ID');

        x_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'ORG_ID');
	setOrgCtx(x_org_id);

	x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  	itemkey   => itemkey,
			    				aname  => 'REQUESTER_ID');

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
			    			  	    itemkey   => itemkey,
			    				    aname  => 'DUE_DATE');


    select ORDER_NUMBER
      into x_so_number
      from oe_order_headers_all osh
     where osh.HEADER_ID = x_so_header_id;


--   ash_debug.debug('get_internal_order order_number',x_so_number);


	-- Retrieve buyer username and display name.
        -- Store them to the workflow process

	wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	      itemkey  	=> Itemkey,
  	      		     	      aname 	=> 'SO_NUMBER',
			     	      avalue	=> x_so_number );

       fnd_message.set_name ('PO','RCV_RCPT_QTY_RCV');
       x_qty_rcv_text := '      ' || fnd_message.get;

       fnd_message.set_name ('PO','RCV_RCPT_QTY_RCVD_TODATE');
       x_qty_rcvd_todate_text := '      ' || fnd_message.get;

       fnd_message.set_name ('PO','RCV_RCPT_ON_REQ');
       x_on_req_text := ' ' || fnd_message.get;




   ELSIF ( funmode = 'CANCEL' ) THEN
	--
	NULL;
	--
   END if;




    EXCEPTION
   	WHEN NO_DATA_FOUND THEN

             wf_core.context ('PORCPTWF','Get_Internal_Order_Info','No data found');

   	WHEN OTHERS THEN

       	     wf_core.context ('PORCPTWF','Get_Internal_Order_Info','SQL error ' || sqlcode);

    RAISE;


  END Get_Internal_Order_Info;



/*===========================================================================
  PROCEDURE NAME: 	Get_Rcv_Order_URL

  DESCRIPTION: 		This procedure retrieves the URL of the Receive Orders
			web page. The URL provides a direct link from the
  			workflow notification message to the Web Application
			Receive Orders web page for processing 'Partial/Over'
 			receipt functions.

  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/


  PROCEDURE Get_Rcv_Order_URL  (   itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    ) IS


  x_requester_ID              NUMBER;
  x_po_header_ID 	      NUMBER;
  x_exp_receipt_date	      DATE;
  x_Rcv_Order_URL             VARCHAR2(1000);
  x_org_id                    NUMBER;
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  BEGIN

    IF ( funmode = 'RUN'  ) THEN
        --
        x_requester_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'REQUESTER_ID');

        x_po_header_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'PO_HEADER_ID');

        x_org_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'ORG_ID');

	setOrgCtx(x_org_id);

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
			    			  	    itemkey   => itemkey,
			    				    aname  => 'DUE_DATE');


    x_Rcv_Order_url  := l_base_href || '/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' || 'porOrderHeaderId=' ||to_char(x_po_header_id) || '&' ||  'porMode=confirmReceipt' ;

    IF (x_requester_id is not null) THEN
      x_Rcv_Order_url := x_Rcv_Order_url || '&' || 'porRequesterId=' ||to_char(x_requester_id) || '&';
    END IF;

    IF (x_exp_receipt_date is not null) THEN
      x_Rcv_Order_url := x_Rcv_Order_url || 'porExpectedDate=' || to_char(x_exp_receipt_date,'DD-MON-YYYY') || '&';
    END IF;

      x_Rcv_Order_url := x_Rcv_Order_url || 'porOrderTypeCode=PO' || '&'
	|| 'porDestOrgId=' || to_char(x_org_id)||'&'||'NtfId=-'||'&'||'#NID-';

        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'RCV_ORDERS_URL',
                                        avalue          => x_Rcv_Order_URL );
        --
   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Get_Rcv_Order_URL','No data found');

   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Get_Rcv_Order_URL','SQL error ' || sqlcode);

    RAISE;


  END Get_Rcv_Order_URL;

 PROCEDURE Get_Rcv_Int_Order_URL  (   itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    ) IS

  x_req_header_ID              NUMBER;
  x_requester_ID              NUMBER;
  x_so_header_ID 	      NUMBER;
  x_exp_receipt_date	      DATE;
  x_Rcv_Order_URL             VARCHAR2(1000);
  x_org_id                    NUMBER;
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  BEGIN

    IF ( funmode = 'RUN'  ) THEN
        --
        x_requester_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'REQUESTER_ID');

        x_so_header_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'SO_HEADER_ID');

	x_req_header_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'REQ_HEADER_ID');

	x_org_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'ORG_ID');


        -- Setup the organization context for the multi-org environment

	setOrgCtx(x_org_id);

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
			    			  	    itemkey   => itemkey,
			    				    aname  => 'DUE_DATE');

	x_Rcv_Order_url  := l_base_href || '/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' || 'porOrderHeaderId=' || to_char(x_so_header_id) || '&' ||  'porMode=confirmReceipt' ;

        IF (x_requester_id is not null) THEN
          x_Rcv_Order_url := x_Rcv_Order_url || '&' || 'porRequesterId=' ||to_char(x_requester_id) || '&';
        END IF;

        IF (x_exp_receipt_date is not null) THEN
          x_Rcv_Order_url := x_Rcv_Order_url || 'porExpectedDate=' || to_char(x_exp_receipt_date,'DD-MON-YYYY') || '&';
        END IF;

        x_Rcv_Order_url := x_Rcv_Order_url || 'porOrderTypeCode=REQ' || '&'
	 || 'porDestOrgId=' || to_char(x_org_id)||'&'||'NtfId=-'||'&'||'#NID-';

	-- ash_debug.debug('Get_Rcv_Int_Order_URL org id',x_org_id);
        -- ash_debug.debug('Get_Rcv_Int_Order_URL org id',x_Rcv_Order_url);
        --
        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'RCV_ORDERS_URL',
                                        avalue          => x_Rcv_Order_URL );
        --
   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Get_Rcv_Int_Order_URL','No data found');

   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Get_Rcv_Int_Order_URL','SQL error ' || sqlcode);

    RAISE;


  END Get_Rcv_Int_Order_URL;


PROCEDURE initialize(x_requester_username in VARCHAR2, x_org_id IN NUMBER) IS

  x_resp_id NUMBER := -1;
  x_user_id NUMBER := -1;
  x_resp_appl_id NUMBER := -1;
/* Bug 6277620 - FP of 6054138 */
  x_ip_resp_appl_id NUMBER := 178;
  x_po_resp_appl_id NUMBER := 201;

BEGIN
	begin
	/*  Changed the method signature to accept the requester username
	    instead of the employee id. The requester username is set to the buyer's
	    username if the requester is not a user. Otherwise, it is set to the requester's
	    username.
	*/
	SELECT FND.user_id
	       INTO   x_user_id
	       FROM   FND_USER FND
	       WHERE  FND.USER_NAME = x_requester_username
	       AND    FND.START_DATE < sysdate
	       AND    nvl(FND.END_DATE, sysdate + 1) >= sysdate
	       AND    ROWNUM = 1;
	EXCEPTION
	WHEN OTHERS THEN
	 x_user_id := -1;
	END;

       BEGIN
        select MIN(fr.responsibility_id)
        into x_resp_id
        from fnd_user_resp_groups fur,
             fnd_responsibility_vl fr,
             financials_system_parameters fsp
          where fur.user_id = x_user_id
            and fur.responsibility_application_id in (x_ip_resp_appl_id, x_po_resp_appl_id)
            and fur.responsibility_id = fr.responsibility_id
            and fr.start_date < sysdate
            and nvl(fr.end_date, sysdate +1) >= sysdate
            and fur.start_date < sysdate
            and nvl(fur.end_date, sysdate +1) >= Sysdate
            AND nvl(fnd_profile.value_specific('ORG_ID', NULL,
                fr.responsibility_id, fur.responsibility_application_id),-1) = nvl(x_org_id,-1)
                and nvl(fsp.org_id,-1) = nvl(x_org_id,-1)
                and nvl(fsp.business_group_id,-1) =
                    nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL,
                        fr.responsibility_id, fur.responsibility_application_id),-1);
   EXCEPTION
     when others then
	x_resp_id := -1;
       END;
  /* Bug 6277620- FP of 6054138 - Select the ip/po responsibility first and if not found then look for custom responsibilities*/
   if ((x_resp_id = -1) or (x_resp_id is null)) THEN
      BEGIN
        select MIN(fr.responsibility_id)
        into x_resp_id
        from fnd_user_resp_groups fur,
             fnd_responsibility_vl fr,
             financials_system_parameters fsp
          where fur.user_id = x_user_id
	          and fur.responsibility_id = fr.responsibility_id
            and fr.start_date < sysdate
            and nvl(fr.end_date, sysdate +1) >= sysdate
            and fur.start_date < sysdate
            and nvl(fur.end_date, sysdate +1) >= Sysdate
            AND nvl(fnd_profile.value_specific('ORG_ID', NULL,
                fr.responsibility_id, fur.responsibility_application_id),-1) = nvl(x_org_id,-1)
                and nvl(fsp.org_id,-1) = nvl(x_org_id,-1)
                and nvl(fsp.business_group_id,-1) =
                    nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL,
                        fr.responsibility_id, fur.responsibility_application_id),-1);
   EXCEPTION
     when others then
	      x_resp_id := -1;
       END;
   END IF;

   if(x_resp_id <> -1) then
     BEGIN
       SELECT MIN(responsibility_application_id)
       INTO x_resp_appl_id
       FROM fnd_user_resp_groups  fur,
            fnd_responsibility_vl fr,
            financials_system_parameters fsp
       WHERE
            fur.responsibility_id = fr.responsibility_id and
            fr.responsibility_id = x_resp_id and
            fur.user_id = x_user_id and
            fr.start_date < sysdate and
            nvl(fr.end_date, sysdate +1) >= sysdate and
            fur.start_date < sysdate and
            nvl(fur.end_date, sysdate +1) >= Sysdate AND
            nvl(fnd_profile.value_specific('ORG_ID', NULL, fr.responsibility_id,
                fur.responsibility_application_id),-1) = nvl(x_org_id,-1) and
            nvl(fsp.org_id,-1) = nvl(x_org_id,-1) and
            nvl(fsp.business_group_id,-1) =
            nvl(fnd_profile.value_specific('PER_BUSINESS_GROUP_ID', NULL,
            fr.responsibility_id, fur.responsibility_application_id),-1);
       EXCEPTION
         WHEN OTHERS THEN
           x_resp_appl_id := -1;
       END;
    end if;

    FND_GLOBAL.APPS_INITIALIZE(x_user_id,x_resp_id,x_resp_appl_id);


END initialize;



/*===========================================================================
  PROCEDURE NAME:	Process_Rcv_Trans

  DESCRIPTION:          This procedure processes the Receiving Transaction
			interface when the workflow notification is reponsed
			as 'Fully Received'.

			It checks to ensure that the shipment(s) is/are still
			opened.  It invokes the Receiving Transaction interface
			procedure to insert the receipt records into the
			receiving transaction interface table.

			The Receiving Transaction Manager is then called in
			'ON-LINE' mode to process the receipt records immediately.

                        If there are errors returned from the Receiving
			Transaction Manager, the error status is set the
			workflow item attribute for notifying the buyer and
			requester of the error.


  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/


  PROCEDURE   Process_Rcv_Trans 	 (   itemtype        in varchar2,
                                             itemkey         in varchar2,
                                             actid           in number,
                                             funmode         in varchar2,
                                             result          out NOCOPY varchar2    ) IS
       TYPE shipment_orders_cursor IS ref CURSOR;
       	Porcpt_Shipment shipment_orders_cursor;

  x_group_id                  NUMBER;
  x_inserted_txn              BOOLEAN;
  x_insert_txns_count         NUMBER := 0;
  x_RCV_txns_rc               NUMBER := 0;
  x_exp_receipt_date	      DATE;
  x_po_header_id              NUMBER;
  x_requester_id   	      NUMBER;

  x_org_id		      NUMBER;
  x_requester_username        WF_USERS.NAME%TYPE; --Using the username in the initialize api
  x_rcv_trans_status          VARCHAR2(500) := NULL;
  X_tmp_count                 NUMBER;
  X_tmp_count1                NUMBER;
  X_tmp_approve               VARCHAR2(20);
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
  x_insert_txns_status        NUMBER;

  t_po_header_id		rcvNumberArray;
  t_line_location_id		rcvNumberArray;
  t_expected_receipt_qty	rcvNumberArray;
  t_ordered_uom			rcvVarcharArray;
  t_item_id			rcvNumberArray;
  t_primary_uom_class		rcvVarcharArray;
  t_org_id			rcvNumberArray;
  t_po_distribution_id		rcvNumberArray;
  t_Comments			rcvVarcharArray;
  t_PackingSlip			rcvVarcharArray;
  t_WayBillNum			rcvVarcharArray;

  x_progress  varchar2(1000):= '001';
  x_ntf_trigerred_date  varchar2(40);
  x_message_token VARCHAR2(2000);

  BEGIN

   IF  ( funmode = 'RUN'  ) THEN
        --
        x_po_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'PO_HEADER_ID');

	-- Setup the organization context for the multi-org environment

       	x_org_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'ORG_ID');

        -- Setup the organization context for the multi-org environment

	setOrgCtx(x_org_id);

        --Use the requester username to be passed to the initalize api
        x_requester_username := wf_engine.GetItemAttrText   ( itemtype	=> itemtype,
	                                                      itemkey 	=> itemkey,
  	                                                      aname 	=> 'REQUESTER_USERNAME');
	initialize(x_requester_username,x_org_id);

        /** rewrite after initialize **/
  	x_allow_inv_dest_receipts := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');

        x_requester_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'REQUESTER_ID');


        x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'DUE_DATE');

        -- <R12 Confirm Receipt and JRAD Notificaion>
        -- To retrieve notification triggered date
        x_ntf_trigerred_date :=  PO_WF_UTIL_PKG.GetItemAttrText(
                                          itemtype  => itemtype,
                                          itemkey   => itemkey,
                                          aname  => 'NTF_TRIGGERED_DATE');

          SELECT rcv_interface_groups_s.nextval
          INTO   x_group_id
	    FROM   sys.dual;


       if x_allow_inv_dest_receipts is NULL then
          x_allow_inv_dest_receipts := 'N';
       end if;

       if x_allow_inv_dest_receipts = 'N' then

          OPEN  Porcpt_Shipment for
          	SELECT po_header_id,
		  po_line_location_id,
                  expected_receipt_qty,
		  primary_uom,
		  item_id,
                  primary_uom_class,
                  to_organization_id,
		  po_distribution_id,
		  null,
		  null,
		  null
             FROM  POR_RCV_ALL_ITEMS_V1 rcv
            WHERE ((expected_receipt_date is not NULL
				    AND trunc(expected_receipt_date+1)<=    --bug 16556483
			           trunc(to_date(x_ntf_trigerred_date, 'DD/MM/YYYY')))
                OR EXISTS (SELECT 1 FROM ap_holds aph
                WHERE aph.line_location_id = rcv.po_line_location_id
                  AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	          AND aph.release_lookup_code IS NULL
	          AND rcv.quantity_invoiced > quantity_delivered
                  --AND rcv.quantity_invoiced <= ordered_qty     --Bug 18421821
                  ))
              AND NVL(receipt_required_flag,'N') = 'Y'
              AND destination_type_code = 'EXPENSE'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND po_header_ID = x_po_header_ID
              AND requestor_ID = x_requester_ID;
       else
           OPEN  Porcpt_Shipment for
          	SELECT po_header_id,
		  po_line_location_id,
                  expected_receipt_qty,
		  primary_uom,
		  item_id,
                  primary_uom_class,
                  to_organization_id,
		  po_distribution_id,
		  null,
		  null,
		  null
            FROM  POR_RCV_ALL_ITEMS_V1 rcv
            WHERE ((expected_receipt_date is not NULL
				  AND trunc(expected_receipt_date+1)<=     --bug 16556483
			           trunc(to_date(x_ntf_trigerred_date, 'DD/MM/YYYY')))
                OR EXISTS (SELECT 1 FROM ap_holds aph
                WHERE aph.line_location_id = rcv.po_line_location_id
                  AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	          AND aph.release_lookup_code IS NULL
	          AND rcv.quantity_invoiced > quantity_delivered
                  --AND rcv.quantity_invoiced <= ordered_qty   --Bug 18421821
                  ))
              AND NVL(receipt_required_flag,'N') = 'Y'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND po_header_ID = x_po_header_ID
              AND requestor_ID = x_requester_ID;

        end if; /** AllowInvDest Receipt Check **/

              FETCH porcpt_Shipment BULK COLLECT into t_po_header_id,
					 t_line_location_id,
					 t_expected_receipt_qty,
					 t_ordered_uom,
					 t_item_id,
					 t_primary_uom_class,
					 t_org_id,
					 t_po_distribution_id,
					 t_Comments,
                            		 t_PackingSlip,
                            		 t_WayBillNum;

                CLOSE Porcpt_Shipment;

	     for i in 1..t_po_header_id.count loop
       		  x_progress := 'poheaderid*' || to_char(t_po_header_id(i)) || '*t_line_location_id*' || to_char(t_line_location_id(i)) || '*ex_rcpt_qty*' || t_expected_receipt_qty(i) || '*uom*' || t_ordered_uom(i)
			|| '*itemid*' || to_char(t_item_id(i)) || '*uom_class*' || t_primary_uom_class(i) || '*org_id*' || to_char(t_org_id(i))  || '*t_po_distribution_id*' || to_char(t_po_distribution_id(i))
			|| '*comments*' || t_comments(i)  || '*pkgSlip*' || t_packingSlip(i) || '*waybillnum*'  || t_waybillNum(i);

	     x_progress := x_progress || '*x_group_id*' || to_char(x_group_id);

	     IF (g_po_wf_debug = 'Y') THEN
   	     po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
	     END IF;

      end loop;


		x_insert_txns_status := POR_RCV_ORD_SV.groupPoTransaction( t_po_header_id,
					 t_line_location_id,
					 t_expected_receipt_qty,
					 t_ordered_uom,
					 SYSDATE,
					 t_item_id,
					 t_primary_uom_class,
					 t_org_id,
					 t_po_distribution_id,
					 x_group_id,
					 'WP4_CONFIRM',
					 t_Comments,
                            		 t_PackingSlip,
                            		 t_WayBillNum);

        IF x_insert_txns_status = 0 THEN
  	   x_RCV_txns_rc :=  por_rcv_ord_sv.process_transactions(X_group_id, 'WF');

           -- At least one of the receiving transactions inserted

           IF x_RCV_txns_rc is NULL OR
	      x_RCV_txns_rc = 0 THEN

	      -- Clean the po distribtions table
	      update po_distributions
	      set wf_item_key = ''
	      where po_header_id = x_po_header_ID
		and wf_item_key like x_po_header_ID||';'||x_requester_id||';%';

              RESULT := 'PASSED';

           ELSE
              get_txn_error_message(x_group_id, x_RCV_txns_rc, x_rcv_trans_status, x_message_token);

              wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                            itemkey  	=> Itemkey,
                                            aname 	=> 'RCV_TRANS_STATUS',
                                            avalue	=> x_rcv_trans_status );

              wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                            itemkey  	=> Itemkey,
                                            aname 	=> 'RCV_ERR_MSG_TOKEN',
                                            avalue	=> x_message_token );

              RESULT := 'FAILED';

           END IF;


        ELSE

           -- 513490 change where condition to expected_receipt_qty = 0 to
           -- see if the shipment has already been fully received

           -- will come down here only if either all shipments are fully received
           -- or some shipments are fully received while the rest of shipment
           -- require reapproval

           /* bug 601806 */

	   if (x_allow_inv_dest_receipts = 'N') then
		SELECT count(*)
            	 INTO x_tmp_count
             	FROM POR_RCV_ALL_ITEMS_V1
            	WHERE expected_receipt_date is not NULL
             	 AND NVL(receipt_required_flag,'N') = 'Y'
              	AND destination_type_code = 'EXPENSE'
             	 AND requestor_id is not NULL
              	AND po_header_ID = x_po_header_ID;

           	 SELECT count(*)
           	  INTO x_tmp_count1
            	 FROM POR_RCV_ALL_ITEMS_V1 rcv
           	 WHERE ((expected_receipt_date is not NULL
					   AND trunc(expected_receipt_date+1)<=     --bug 16556483
			           trunc(to_date(x_ntf_trigerred_date, 'DD/MM/YYYY')))
                     OR EXISTS (SELECT 1 FROM ap_holds aph
                     WHERE aph.line_location_id = rcv.po_line_location_id
                       AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	               AND aph.release_lookup_code IS NULL
	               AND rcv.quantity_invoiced > quantity_delivered
                       --AND rcv.quantity_invoiced <= ordered_qty     --Bug 18421821
                       ))
            	   AND NVL(receipt_required_flag,'N') = 'Y'
            	   AND destination_type_code = 'EXPENSE'
            	   AND requestor_id is not NULL
            	   AND expected_receipt_qty = 0
           	   AND po_header_ID = x_po_header_ID
           	   AND requestor_ID = x_requester_ID;
         else
		SELECT count(*)
            	 INTO x_tmp_count
             	FROM POR_RCV_ALL_ITEMS_V1
            	WHERE expected_receipt_date is not NULL
             	 AND NVL(receipt_required_flag,'N') = 'Y'
             	 AND requestor_id is not NULL
              	AND po_header_ID = x_po_header_ID;

           	 SELECT count(*)
           	  INTO x_tmp_count1
            	 FROM POR_RCV_ALL_ITEMS_V1 rcv
           	 WHERE ((expected_receipt_date is not NULL
                       AND trunc(expected_receipt_date+1)<=	  --bug 16556483
			           trunc(to_date(x_ntf_trigerred_date, 'DD/MM/YYYY')))
                     OR EXISTS (SELECT 1 FROM ap_holds aph
                     WHERE aph.line_location_id = rcv.po_line_location_id
                       AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	               AND aph.release_lookup_code IS NULL
	               AND rcv.quantity_invoiced > quantity_delivered
                       --AND rcv.quantity_invoiced <= ordered_qty    --Bug 18421821
                       ))
            	   AND NVL(receipt_required_flag,'N') = 'Y'
            	   AND requestor_id is not NULL
            	   AND expected_receipt_qty = 0
           	   AND po_header_ID = x_po_header_ID
           	   AND requestor_ID = x_requester_ID;
          end if;

           IF (x_tmp_count1 > 0) THEN
              -- will come down here if all the eligible shipments
              -- have been fully received order has already been received
              x_rcv_trans_status := 'RCV_RCPT_ORDER_RECEIVED';

           ELSIF (x_tmp_count = 0) THEN
              -- if it doesn't satify four basic criteria
              --   1. make the RCV_CONFIRM_RECEIPT_V
              --   2. receipt_required
              --   3. destination_type_code = 'EXPENSE'
              --   4. expected_receipt_date and requestor_id not NULL
              -- then, it doesn't qualify for confirm receipt
              x_rcv_trans_status := 'RCV_RCPT_APPROVAL_FAILED';

           ELSIF (x_tmp_count > 0) THEN
              -- either the requestor or the expected_receipt_date has changed
             x_rcv_trans_status := 'RCV_RCPT_RQTR_DATE_CHANGED';

           ELSE
               -- Insert to Receiving Transaction Interface failed
             x_rcv_trans_status := 'RCV_RCPT_INSERT_FAILED';
           END IF;

	     wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	           itemkey  	=> Itemkey,
  	      		                   aname 	=> 'RCV_TRANS_STATUS',
			                   avalue	=> x_rcv_trans_status );

           RESULT :='FAILED';

        END IF;

   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Process_Rcv_Trans','No data found');

   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Process_Rcv_Trans','SQL error ' || sqlcode);

    RAISE;


  END  Process_Rcv_Trans;


/*===========================================================================
  PROCEDURE NAME:	Open_RCV_Orders

  DESCRIPTION:     	This procedure provides a direct link to the Web Application
			Receive Orders web page when user clicks the web page URL
			from the workflow notification.


  CHANGE HISTORY:       WLAU       1/15/1997     Created
===========================================================================*/


  PROCEDURE Open_RCV_Orders        (p1       in varchar2,
                                    p2       in varchar2,
                                    p3       in varchar2,
				    p11      in varchar2 ) IS


  l_param		VARCHAR2(1000) := '';
  l_session_id	 	NUMBER;

  BEGIN

    -- Construct the Receive Orders Web page parameters
    -- Note: ~ is translated to = sign.

    --htp.p ('Begin Open_RCV_orders p1= ' || icx_call.decrypt (p1));
    --htp.p ('Begin Open_RCV_orders p2= ' || icx_call.decrypt (p2));
    --htp.p ('Begin Open_RCV_orders p3= ' || icx_call.decrypt (p3));

  -- bug 475711
  -- set date format to be the same in Web date format mask

  IF icx_sec.validateSession THEN


    l_param := 'W*178*ICX_EMPLOYEES*178*ICX_RCV_CONFIRM_RECEIPT*' ||
               'PO_HEADER_ID ~ '        || icx_call.decrypt (p1) ||
               ' and REQUESTOR_ID ~ '   || icx_call.decrypt (p2) ||
               ' and DESTINATION_TYPE_CODE ~ '|| '''EXPENSE''' ||
               ' and EXPECTED_RECEIPT_DATE ~ '''|| to_char(to_date(icx_call.decrypt (p3),'DD/MM/YYYY'),icx_sec.getID(icx_sec.pv_date_format)) ||'''' ||
               '**]';



    l_session_id := icx_sec.getID (icx_sec.PV_Session_ID);

    IF icx_call.decrypt(p11) is not NULL THEN

       -- Set multi-org context with the correct organization id
       icx_sec.set_org_context(l_session_id, icx_call.decrypt(p11));
    END IF;

    IF   l_session_id is NULL THEN

         OracleOn.IC (Y => icx_call.encrypt2 (l_param,-999));

    ELSE

         OracleOn.IC (Y => icx_call.encrypt2 (l_param,l_session_id));

    END IF;

  END IF;

    EXCEPTION

   	WHEN OTHERS THEN

             -- htp.p (SQLERRM);
       	     wf_core.context ('PORCPTWF','Get_Requester_Manager','SQL error ' || sqlcode);

    RAISE;


  END  Open_RCV_Orders;

/*===========================================================================
  FUNCTION NAME:	FindOrgId

  DESCRIPTION:          This procedure return the correct org_id if workflow
			is running under the multi-org environment.


  CHANGE HISTORY:       WLAU       2/11/1997     Created
===========================================================================*/
FUNCTION findOrgId(x_header_id  IN number,
		   x_is_int_req IN VARCHAR2 default 'N' ) return number is

  cursor chkmtlorg is
    select multi_org_flag
    from fnd_product_groups
    where rownum < 2;

  cursor getorgid is
    select org_id
    from po_headers_all
    where po_header_id = x_header_id;

  cursor getorgid_int is
    select org_id
    from oe_order_headers_all
    where header_id = x_header_id;

  chk_flg varchar2(5);
  v_org_id number    := NULL;

 BEGIN

  open chkmtlorg;
  fetch chkmtlorg into chk_flg;
  close chkmtlorg;

  if chk_flg is not NULL and chk_flg = 'Y' then

    if  x_is_int_req = 'Y' then
        open getorgid_int;
     	  fetch getorgid_int into v_org_id;
     	close getorgid_int;
    else
        open getorgid;
     	  fetch getorgid into v_org_id;
     	close getorgid;
    end if;

     return v_org_id;

  else

     return NULL;

  end if;

END findOrgId;

function  po_revised ( x_po_header_id IN number , x_revision_num  IN number,x_wf_itemtype IN varchar2 ,x_wf_itemkey IN varchar2)
    return boolean is
    old_rev_num number;
    x_item_exists varchar2(1) := 'Y';
  begin
         begin
         /**  get the attribute for that notification.**/
           old_rev_num := wf_engine.GetItemAttrNumber   ( itemtype	=> x_wf_itemtype,
	      		     	           		 itemkey  	=> x_wf_itemkey,
  	      		                   		 aname 		=> 'PO_REVISION_NUM');
           x_item_exists := 'Y';
         exception
           when others then
               /** This will handle the case where the notifications have been created without the revision_num attribute **/
               x_item_exists := 'N';
               old_rev_num := -1;
         end;

         /**  compare the attributes.  **/
          if old_rev_num <> x_revision_num then
             return TRUE;
          else
             return FALSE;
          end if;
  exception
   	when no_data_found then
             return TRUE;
   	when others then
       	     wf_core.context ('PORCPTWF','po_revised','SQL error ' || sqlcode);
             raise;

end po_revised;



PROCEDURE purge_Orders  IS

    type purge_orders_Cursor is ref cursor ;

    Porcpt_c purge_orders_Cursor;



  x_po_header_id	NUMBER;
  x_requester_id 	NUMBER;
  x_exp_receipt_date	DATE;
  x_WF_ItemKey		VARCHAR2(100);
  x_WF_ItemKey_save     VARCHAR2(100);
  x_auto_receive_flag   VARCHAR2(1);
  x_WF_process_exists   BOOLEAN;
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');

  x_wf_itemtype  varchar2(6) := 'PORCPT';
  x_revision_num number;

  BEGIN


   x_WF_ItemKey 	:= ' ';
   x_WF_ItemKey_save 	:= ' ';

   -- Call WF purge API to remove any existing Confirm Receipts WF items
   -- which are completed with an END_DATE less than or equal to
   -- SYSDATE (default).  This is to ensure that the Selection
   -- process can start the workflow process for the same item key value.
   --
   -- The WF purge API will not remove any WF items which are still
   -- opened with END_DATE = NULL;


   WF_PURGE.total ('PORCPT');


   if x_allow_inv_dest_receipts is NULL then
       x_allow_inv_dest_receipts := 'N';
   end if;

   -- Start the Confirm Receipts workflow Selection process
   -- Open cursor for selecting records to that need to be cleaned up.
   -- Records are retrieved from POR_RECEIVE_ORDERS_V or  RCV_CONFIRM_RECEIPT_V
   -- which are shared by the Receive Orders Web Pages

       if x_allow_inv_dest_receipts = 'N' then

          OPEN  Porcpt_c for
             SELECT po_header_ID,  requestor_ID,
                    expected_receipt_date,
                    revision_num
             FROM  POR_RCV_ALL_ITEMS_V1
             WHERE expected_receipt_date is not NULL
               AND expected_receipt_date + 1 <= SYSDATE
               AND NVL(receipt_required_flag,'N') = 'Y'
 	       AND destination_type_code = 'EXPENSE'
               AND requestor_ID is not NULL
               AND expected_receipt_qty > 0
            GROUP BY po_header_ID, requestor_ID,  expected_receipt_date, revision_num;

       else
           OPEN  Porcpt_c for
              SELECT po_header_ID,  requestor_ID, expected_receipt_date, revision_num
              FROM  POR_RCV_ALL_ITEMS_V1
              WHERE expected_receipt_date is not NULL
                AND expected_receipt_date + 1 <= SYSDATE
                AND NVL(receipt_required_flag,'N') = 'Y'
 	        AND requestor_ID is not NULL
                AND expected_receipt_qty > 0
             GROUP BY po_header_ID, requestor_ID,  expected_receipt_date, revision_num;

        end if; /** AllowInvDest Receipt Check **/

   LOOP

   	FETCH Porcpt_c into 	x_po_header_id,
		       		x_requester_id,
				x_exp_receipt_date,
                                x_revision_num;

        -- Contruct Confirm Receipt workflow Item Key in the combination of:
        --     PO_Header_ID + Requester_ID + Due_Date
        --



   	     x_WF_ItemKey := to_char(x_po_header_id) ||  ';' ||
		 		     to_char(x_requester_id) ||  ';' ||
  		   	             to_char(x_exp_receipt_date,'DD-MON-YYYY');

             IF Porcpt_c%FOUND AND
               x_WF_ItemKey <> x_WF_ItemKey_save THEN

               begin

                -- Call Workflow to check if the itemkey already exists
                -- Note: WF_item.item_exist is for internal use.  This procedure
                --       will be replaced by an API in a later Workflow release.

                x_WF_process_exists := WF_item.item_exist ('PORCPT',
                                                           x_WF_ItemKey);

                IF x_WF_process_exists THEN

                   -- Workflow item exists and is still opened
                   -- Bypass this one


                   /** If the revision number of the PO is different then cancel the
                       open notifications ; we need to remove the ELSE below since we
                       need to start_recpt_process for such cases too. **/
                  if po_revised(x_po_header_id, x_revision_num , x_wf_itemtype,x_WF_ItemKey ) then
		    --This will abort and purge the process
		    wf_purge.items(itemtype => x_WF_ItemType,
                      itemkey  => x_WF_ItemKey,
                      enddate  => sysdate,
                      docommit => true,
                      force    => true);

                      COMMIT;

		  end if;

              END IF;

	      EXCEPTION
              when others then
                wf_core.context ('PORCPTWF','purge_Orders','SQL error ' || sqlcode);
                IF (g_po_wf_debug = 'Y') THEN
                  po_wf_debug_pkg.insert_debug(x_wf_itemtype,x_wf_itemkey,'purge_orders SQL error ' || sqlcode || ' error message: ' || substr(sqlerrm,1,512));
                END IF;
              END;

                -- Save the ItemKey for the next comparison
    	        x_WF_ItemKey_Save := x_WF_ItemKey;

             END IF;




   EXIT WHEN Porcpt_c%NOTFOUND;

   END LOOP;

   CLOSE porcpt_c;

    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','purge_orders','No data found');
   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','purge_Orders','SQL error ' || sqlcode);
    RAISE;


END purge_Orders;


FUNCTION get_count(x_item_type IN VARCHAR2,
		   x_item_key IN VARCHAR2,
		   skip_distribution_updation in varchar2 default 'N') RETURN NUMBER IS

x_count NUMBER := 0;
x_org_id              	NUMBER;
x_requester_id                NUMBER;
x_exp_receipt_date 		DATE;
x_allow_inv_dest_receipts  varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
x_is_int_req              VARCHAR2(1);
x_so_header_id         NUMBER;
x_po_header_id         NUMBER;
x_progress      VARCHAR2(1000):= '001';
BEGIN


        x_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => x_item_type,
			    			  	itemkey   => x_item_key,
			    				aname  => 'ORG_ID');

        -- Setup the organization context for the multi-org environment
        setOrgCtx(x_org_id);

	x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => x_item_type,
			    			  	itemkey   => x_item_key,
			    				aname  => 'REQUESTER_ID');

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => x_item_type,
			    			  	    itemkey   => x_item_key,
			    				    aname  => 'DUE_DATE');

        x_is_int_req :=  wf_engine.GetItemAttrText ( itemtype  => x_item_type,
			    			  	    itemkey   => x_item_key,
			    				    aname  => 'IS_INT_REQ');
     begin
    x_progress := '002 x_is_int_req is ' || x_is_int_req || 'x_allow_inv_dest_receipts: '|| x_allow_inv_dest_receipts;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(x_item_type, x_item_key, x_progress);
    END IF;
          if x_is_int_req = 'Y' then

	   x_so_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => x_item_type,
			    			  	itemkey   => x_item_key,
			    				aname  => 'SO_HEADER_ID');
           -- ash_debug.debug('get_count  x_so_header_id ',  x_so_header_id);

           if x_allow_inv_dest_receipts = 'N' then
	          SELECT COUNT(*) INTO
		  X_COUNT
                  FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
                  WHERE expected_receipt_date is not NULL
                  AND expected_receipt_date = x_exp_receipt_date
                  AND NVL(receipt_required_flag,'N') = 'Y'
 	          AND destination_type_code = 'EXPENSE'
                  AND requestor_ID is not NULL
                  AND expected_receipt_qty > 0
                  AND so_header_ID = x_so_header_id
		  AND requestor_ID = x_requester_id;
	    else
	          SELECT  COUNT(*)
		  INTO X_COUNT
		  FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
		  WHERE expected_receipt_date is not NULL
		  AND expected_receipt_date = x_exp_receipt_date
		  AND NVL(receipt_required_flag,'N') = 'Y'
		  AND requestor_ID is not NULL
		  AND expected_receipt_qty > 0
		  AND so_header_ID = x_so_header_id
		  AND requestor_ID = x_requester_id;
	   end if;

          -- ash_debug.debug('get_count  x_so_header_id ',  x_count);

          else

           x_po_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => x_item_type,
			    			  	itemkey   => x_item_key,
			    				aname  => 'PO_HEADER_ID');

	   -- <R12 Confirm Receipt and JRAD Conversion>
	   --  Removing the query execution from this place and
           --  calling populate_order_info function to populate the
           --  latest distributions list.
       x_progress := 'get_count 002 else x_po_header_id: ' || x_po_header_id ;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(x_item_type, x_item_key, x_progress);
    END IF;

	   x_count := populate_order_info(x_item_type, x_item_key, skip_distribution_updation);
       x_progress := 'get_count 003 populate_order_info count: ' || x_count ;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(x_item_type, x_item_key, x_progress);
    END IF;
           end if; -- is internal item
       x_progress := 'get_count 004 final return x_count: ' || x_count ;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(x_item_type, x_item_key, x_progress);
    END IF;
	   RETURN x_count;

     EXCEPTION
	WHEN OTHERS THEN
	   RETURN 0;
     END;
END get_count;

PROCEDURE DOES_ITEM_EXIST (itemtype        in varchar2,
		      itemkey         in varchar2,
		      actid           in number,
		      funcmode        in varchar2,
		      resultout       out NOCOPY varchar2) is

x_proress  varchar2(100):= '001';
x_resultout varchar2(30);
x_count NUMBER := 0;
x_disp_count NUMBER :=0;
x_skip_distribution_updation varchar2(2);
x_progress      VARCHAR2(1000):= '001';
BEGIN
    -- Get the activity attribute text. This value would be 'Y' only if called from receive upto
    -- amount invoiced notification. Pass the value toto get_count which would get percolated down
    x_skip_distribution_updation := wf_engine.GetActivityAttrText(itemtype,
                                                                  itemkey,
                                                                  actid,
							         'IS_FROM_RCV_UPTO_AMT_INVOICED');

    x_count := get_count(itemtype,itemkey,x_skip_distribution_updation);
	x_progress       := 'DOES_ITEM_EXIST 002 x_count: ' || x_count;
	  IF (g_po_wf_debug = 'Y') THEN
		po_wf_debug_pkg.insert_debug(itemtype, itemkey, x_progress);
	  END IF;
-- ash_debug.debug('does_item_exist x_count ' , x_count);

     IF  x_count = 0 THEN
     resultout := wf_engine.eng_completed || ':' ||  'N';
     x_resultout := 'N';
    ELSE /* the reminder should have an updated line count */

-- ash_debug.debug('does_item_exist x_count 1' , x_count);

     resultout := wf_engine.eng_completed || ':' ||  'Y';
     x_resultout := 'Y';

-- ash_debug.debug('does_item_exist resultut ' , resultout);
   END IF;
-- ash_debug.debug('does_item_exist resultout ' , resultout);

EXCEPTION

   WHEN OTHERS THEN
      WF_CORE.context('PORCPTWF' , 'DOES_ITEM_EXIST', 'ERROR IN DOES_ITEM_EXIST');
      RAISE;
END does_item_exist;

FUNCTION get_req_number(x_po_distribution_id IN NUMBER) RETURN VARCHAR2 is
  x_req_number VARCHAR2(20);

  BEGIN


       select prh.segment1
       INTO x_req_number
       from po_requisition_headers prh,
            po_requisition_lines prl,po_distributions pod,
            po_req_distributions pord
       where pod.po_distribution_id  = x_po_distribution_id    and
       pord.distribution_id      = pod.req_distribution_id     and
       pord.requisition_line_id  = prl.requisition_line_id     and
       prl.requisition_header_id = prh.requisition_header_id;

     RETURN x_req_number;

  EXCEPTION
     WHEN OTHERS THEN
	RETURN NULL;

END get_req_number;


  PROCEDURE Get_Rcv_Internal_Order_URL  (   itemtype        in varchar2,
                                            itemkey         in varchar2,
                                            actid           in number,
                                            funmode         in varchar2,
                                            result          out NOCOPY varchar2    ) IS


  x_requester_ID              NUMBER;
  x_header_ID 	      NUMBER;
  x_exp_receipt_date	      DATE;
  x_Rcv_Order_URL             VARCHAR2(1000);
  x_org_id                    NUMBER;
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');

  BEGIN

    IF ( funmode = 'RUN'  ) THEN
        --
        x_requester_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'REQUESTER_ID');

        x_header_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'SO_HEADER_ID');

        x_org_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'ORG_ID');
        setOrgCtx(x_org_id);

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
			    			  	    itemkey   => itemkey,
			    				    aname  => 'DUE_DATE');


        x_Rcv_Order_url  := l_base_href || '/OA_HTML/OA.jsp?OAFunc=ICX_POR_LAUNCH_IP' || '&' || 'porOrderHeaderId=' || to_char(x_header_id) || '&' ||  'porMode=confirmReceipt' ;

        IF (x_requester_id is not null) THEN
          x_Rcv_Order_url := x_Rcv_Order_url || '&' || 'porRequesterId=' ||to_char(x_requester_id) || '&';
        END IF;

        IF (x_exp_receipt_date is not null) THEN
          x_Rcv_Order_url := x_Rcv_Order_url || 'porExpectedDate=' || to_char(x_exp_receipt_date,'DD-MON-YYYY') || '&';
        END IF;

        x_Rcv_Order_url := x_Rcv_Order_url || 'porOrderTypeCode=REQ' || '&'
	 || 'porDestOrgId=' || to_char(x_org_id);

        wf_engine.SetItemAttrText (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'RCV_ORDERS_URL',
                                        avalue          => x_Rcv_Order_URL );
        --
   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Get_Rcv_Internal_Order_URL','No data found');

   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Get_Rcv_Internal_Order_URL','SQL error ' || sqlcode);

    RAISE;


  END Get_Rcv_Internal_Order_URL;


  /*===========================================================================
  PROCEDURE NAME:	Get_Requester_Manager

  DESCRIPTION:   	This procedure determines who the requester's manager is.
			The manger's username is used to notify the manager
			of the workflow timeout function.


  CHANGE HISTORY:       WLAU       1/15/1997     Created
			ASABADRA   03/01/2002    Get org id from parameter and
						 use the org id to set context
===========================================================================*/


  PROCEDURE Get_Requester_Manager      (itemtype        in varchar2,
                                        itemkey         in varchar2,
                                        actid           in number,
                                        funmode         in varchar2,
                                        result          out NOCOPY varchar2 ) IS

  x_org_id                    NUMBER;
  x_requester_id              NUMBER;
  x_manager_id	      	      NUMBER;
  x_manager_username          WF_USERS.NAME%TYPE;
  x_manager_disp_name         WF_USERS.DISPLAY_NAME%TYPE;

  x_requester_current         BOOLEAN ;
  dummy                       VARCHAR2(1);

  BEGIN


   IF  ( funmode = 'RUN'  ) THEN

        x_org_id :=  wf_engine.GetItemAttrNumber(itemtype  => itemtype,
                                                       itemkey   => itemkey,
                                                       aname  => 'ORG_ID');

        -- Setup the organization context for the multi-org environment
        setOrgCtx(x_org_id);

/* Bug: 2820973 Check if the requester is an active employee. If yes then get
   the requester's manager and send the time out notification. If the requester
   is not an active employee then the notification had been sent to the buyer
   and in that case get the buyer's manager for time out notification.
*/

x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                itemkey  => itemkey,
                                                aname  => 'REQUESTER_ID');
      Begin

      	Select 'X'
        Into   dummy
      	From  per_workforce_current_x
      	Where  person_id = x_requester_id;

               x_requester_current := TRUE;

      Exception
      when no_data_found then
               x_requester_current := FALSE;
      End;

      If (x_requester_current = FALSE) then
        x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'BUYER_ID');
      Else
        x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'REQUESTER_ID');
     End if;

     Begin

	Select 	cwk.supervisor_id
        into	x_manager_id
	From	per_workforce_current_x cwk
	Where	cwk.person_id = x_requester_id;

     Exception
        When no_data_found then null;
     End;

   	wf_engine.SetItemAttrNumber ( itemtype	=> ItemType,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'MANAGER_ID',
			      	      avalue 	=> x_manager_id );


       wf_directory.GetUserName     ( p_orig_system    => 'PER',
			   	      p_orig_system_id => x_manager_id,
			   	      p_name 	       => x_manager_username,
			              p_display_name   => x_manager_disp_name);

	wf_engine.SetItemAttrText   ( itemtype	=> itemtype,
	      		     	      itemkey  	=> itemkey,
  	      		     	      aname 	=> 'MANAGER_USERNAME',
			     	      avalue	=> x_manager_username );

	wf_engine.SetItemAttrText   ( itemtype	=> itemtype,
	      		     	      itemkey  	=> itemkey,
  	      		              aname 	=> 'MANAGER_DISP_NAME',
			              avalue	=> x_manager_disp_name );


   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;

END Get_Requester_Manager;


  PROCEDURE   Process_Rcv_Trans_Int 	 (   itemtype        in varchar2,
                                             itemkey         in varchar2,
                                             actid           in number,
                                             funmode         in varchar2,
                                             result          out NOCOPY varchar2    ) IS
       TYPE shipment_orders_cursor IS ref CURSOR;
       	Porcpt_Shipment shipment_orders_cursor;

  x_group_id                  NUMBER;
  x_RCV_txns_rc               NUMBER := 0;

  x_exp_receipt_date	      DATE;
  x_header_id              NUMBER;
  x_requester_id   	      NUMBER;
  x_requester_username	      WF_USERS.NAME%TYPE; --Use the requester username to be passed to initialize
  x_rcv_trans_status          VARCHAR2(500) := NULL;
  X_tmp_count                 NUMBER;
  X_tmp_count1                NUMBER;
  X_tmp_approve               VARCHAR2(20);
  x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');

  x_inserted_txn_status         NUMBER;
  x_org_id                      NUMBER;

  t_req_line_id			rcvNumberArray;
  t_expected_receipt_qty	rcvNumberArray;
  t_ordered_uom			rcvVarcharArray;
  t_item_id			rcvNumberArray;
  t_primary_uom_class		rcvVarcharArray;
  t_org_id			rcvNumberArray;
  t_waybillNum			rcvVarcharArray;
  t_comments			rcvVarcharArray;
  t_packingSlip			rcvVarcharArray;
  x_requestor_id		NUMBER;

  x_progress  varchar2(1000):= '001';
  x_message_token VARCHAR2(2000);

  BEGIN

   IF  ( funmode = 'RUN'  ) THEN
        --

	x_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'SO_HEADER_ID');
        -- Setup the organization context for the multi-org environment

        x_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'ORG_ID');

	-- Use the requester username to be passed to initialize
        x_requester_username := wf_engine.GetItemAttrText   ( itemtype	=> itemtype,
	      		     	                              itemkey 	=> itemkey,
  	      		     	                              aname 	=> 'REQUESTER_USERNAME');

	PORCPTWF.initialize(x_requester_username,x_org_id);

        /** rewrite after initialize **/
  	x_allow_inv_dest_receipts := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');


        x_requester_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'REQUESTER_ID');


        x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => itemtype,
                                                        itemkey   => itemkey,
                                                        aname  => 'DUE_DATE');


          SELECT rcv_interface_groups_s.nextval
          INTO   x_group_id
	    FROM   sys.dual;


       if x_allow_inv_dest_receipts is NULL then
          x_allow_inv_dest_receipts := 'N';
       end if;

              if x_allow_inv_dest_receipts = 'N' then
          OPEN  Porcpt_Shipment for
		SELECT REQUISITION_LINE_ID,
			EXPECTED_RECEIPT_QTY,
			ORDERED_UOM,
			ITEM_ID,
			PRIMARY_UOM_CLASS,
			TO_ORGANIZATION_ID,
			COMMENTS,
 			PACKING_SLIP,
 			WAYBILL_AIRBILL_NUM
            FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
            WHERE expected_receipt_date is not NULL
              AND expected_receipt_date = x_exp_receipt_date
              AND destination_type_code = 'EXPENSE'
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND so_header_ID = x_header_ID
              AND requestor_ID = x_requester_ID;
       else
           OPEN  Porcpt_Shipment for
		SELECT REQUISITION_LINE_ID,
			EXPECTED_RECEIPT_QTY,
			ORDERED_UOM,
			ITEM_ID,
			PRIMARY_UOM_CLASS,
			TO_ORGANIZATION_ID,
			COMMENTS,
 			PACKING_SLIP,
 			WAYBILL_AIRBILL_NUM
            FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
            WHERE expected_receipt_date is not NULL
              AND expected_receipt_date = x_exp_receipt_date
              AND requestor_id is not NULL
              AND expected_receipt_qty > 0
              AND so_header_ID = x_header_ID
              AND requestor_ID = x_requester_ID;

        end if; /** AllowInvDest Receipt Check **/

             FETCH porcpt_Shipment BULK COLLECT into t_req_line_id,
                        t_expected_receipt_qty,
                        t_ordered_uom,
                        t_item_id,
			t_primary_uom_class,
			t_org_id,
                        t_comments,
                        t_packingSlip,
                        t_waybillNum;

	     CLOSE Porcpt_Shipment;

             for i in 1..t_req_line_id.count loop
       		  x_progress := 'reqlineid*' || to_char(t_req_line_id(i)) || '*ex_rcpt_qty*' || t_expected_receipt_qty(i)
		|| '*uom*' || t_ordered_uom(i) || '*itemid*' || to_char(t_item_id(i)) || '*uom_class*' || t_primary_uom_class(i) || '*org_id*' || to_char(t_org_id(i))  || '*comments*' || t_comments(i)
		|| '*pkgSlip*' || t_packingSlip(i) || '*waybillnum*'  || t_waybillNum(i);

	     x_progress := x_progress || '*x_group_id*' || to_char(x_group_id);

	        IF (g_po_wf_debug = 'Y') THEN
   	        po_wf_debug_pkg.insert_debug(itemtype,itemkey,x_progress);
	        END IF;
	     end loop;

             x_inserted_txn_status :=   POR_RCV_ORD_SV.groupInternalTransaction (t_req_line_id,
                        t_expected_receipt_qty,
                        t_ordered_uom,
                        t_item_id,
			t_primary_uom_class,
			t_org_id,
                        t_comments,
                        t_packingSlip,
                        t_waybillNum,
			x_group_id,
			SYSDATE,
			'WP4_CONFIRM');

	IF x_inserted_txn_status = 0 THEN

  	   x_RCV_txns_rc :=  por_rcv_ord_sv.process_transactions(X_group_id, 'WF');


           -- At least one of the receiving transactions inserted

           IF x_RCV_txns_rc is NULL OR
	      x_RCV_txns_rc = 0 THEN

              RESULT := 'PASSED';

           ELSE
              get_txn_error_message(x_group_id, x_RCV_txns_rc, x_rcv_trans_status, x_message_token);

              wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                            itemkey  	=> Itemkey,
                                            aname 	=> 'RCV_TRANS_STATUS',
                                            avalue	=> x_rcv_trans_status );

              wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                            itemkey  	=> Itemkey,
                                            aname 	=> 'RCV_ERR_MSG_TOKEN',
                                            avalue	=> x_message_token );

              RESULT := 'FAILED';

           END IF;

        ELSE

	   if (x_allow_inv_dest_receipts = 'N') then
		SELECT count(*)
            	 INTO x_tmp_count
             	FROM POR_CONFIRM_INTERNAL_RECEIPT_V
            	WHERE expected_receipt_date is not NULL
             	 AND NVL(receipt_required_flag,'N') = 'Y'
              	AND destination_type_code = 'EXPENSE'
             	 AND requestor_id is not NULL
              	AND so_header_ID = x_header_ID;

           	SELECT count(*)
           	  INTO x_tmp_count1
            	  FROM POR_CONFIRM_INTERNAL_RECEIPT_V
           	 WHERE expected_receipt_date is not NULL
           	   AND expected_receipt_date = x_exp_receipt_date
            	   AND NVL(receipt_required_flag,'N') = 'Y'
            	   AND destination_type_code = 'EXPENSE'
            	   AND requestor_id is not NULL
            	   AND expected_receipt_qty = 0
           	   AND so_header_ID = x_header_ID
           	   AND requestor_ID = x_requester_id;
         else
	       SELECT count(*)
            	 INTO x_tmp_count
             	 FROM POR_CONFIRM_INTERNAL_RECEIPT_V
            	WHERE expected_receipt_date is not NULL
             	  AND NVL(receipt_required_flag,'N') = 'Y'
             	  AND requestor_id is not NULL
              	  AND so_header_ID = x_header_ID;

           	SELECT count(*)
           	  INTO x_tmp_count1
            	  FROM POR_CONFIRM_INTERNAL_RECEIPT_V
           	 WHERE expected_receipt_date is not NULL
           	   AND expected_receipt_date = x_exp_receipt_date
            	   AND NVL(receipt_required_flag,'N') = 'Y'
            	   AND requestor_id is not NULL
            	   AND expected_receipt_qty = 0
           	   AND so_header_ID = x_header_ID
           	   AND requestor_ID = X_REQUESTER_ID;
          end if;

           IF (x_tmp_count1 > 0) THEN
              -- will come down here if all the eligible shipments
              -- have been fully received order has already been received
              x_rcv_trans_status := 'RCV_RCPT_ORDER_RECEIVED';

           ELSIF (x_tmp_count = 0) THEN
              -- if it doesn't satify four basic criteria
              --   1. make the RCV_CONFIRM_RECEIPT_V
              --   2. receipt_required
              --   3. destination_type_code = 'EXPENSE'
              --   4. expected_receipt_date and requestor_id not NULL
              -- then, it doesn't qualify for confirm receipt

              x_rcv_trans_status := 'RCV_RCPT_APPROVAL_FAILED';

           ELSIF (x_tmp_count > 0) THEN
              -- either the requestor or the expected_receipt_date has changed
              x_rcv_trans_status := 'RCV_RCPT_RQTR_DATE_CHANGED';

           ELSE
               -- Insert to Receiving Transaction Interface failed
               x_rcv_trans_status := 'RCV_RCPT_INSERT_FAILED';

           END IF;

	     wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
	      		     	           itemkey  	=> Itemkey,
  	      		                   aname 	=> 'RCV_TRANS_STATUS',
			                   avalue	=> x_rcv_trans_status );

           RESULT :='FAILED';

   END IF;

   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    EXCEPTION
   	WHEN NO_DATA_FOUND THEN
             wf_core.context ('PORCPTWF','Process_Rcv_Trans_Int','No data found');

   	WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','Process_Rcv_Trans_Int','SQL error ' || sqlcode);

    RAISE;


  END  Process_Rcv_Trans_Int;

PROCEDURE generate_html_header(x_item_type IN VARCHAR2,
			       x_item_key IN VARCHAR2 ,
			       x_count IN NUMBER,
			       x_document IN OUT NOCOPY VARCHAR2) IS

  l_document VARCHAR2(32000) := '';
  x_number                 	VARCHAR2(20):= NULL;
  x_supplier_name		PO_VENDORS.VENDOR_NAME%TYPE := NULL;
  x_due_date	DATE;
  x_buyer_name   WF_USERS.DISPLAY_NAME%TYPE := NULL;
  x_note_to_receiver 	      	PO_HEADERS_ALL.NOTE_TO_RECEIVER%TYPE :=NULL;
  x_disp_count NUMBER := 0;
  x_confirm_rcpt_inst VARCHAR2(2000);
  x_is_int_req  VARCHAR2(1);

  nl VARCHAR2(1) := fnd_global.newline;
  l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');
BEGIN

    x_is_int_req :=  wf_engine.GetItemAttrText( itemtype  => x_item_type,
			    			  	itemkey   => x_item_key,
			    				aname  => 'IS_INT_REQ');

   if x_is_int_req is NULL then
	x_is_int_req := 'N';
   end if;

   if x_is_int_req = 'Y' then

      x_number := wf_engine.GetItemAttrText( itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
  	      		     	      aname 	=> 'SO_NUMBER');

   else -- Purchase Requisition


       x_number := wf_engine.GetItemAttrText( itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
  	      		     	      aname 	=> 'PO_NUMBER');

	x_buyer_name := wf_engine.GetItemAttrText(itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
  	      		              aname 	=> 'BUYER_DISP_NAME');


	x_supplier_name := wf_engine.GetItemAttrText( itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
  	      		              aname 	=> 'SUPPLIER_DISP_NAME');

    end if;

	x_note_to_receiver := wf_engine.GetItemAttrText( itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
				      aname 	=> 'NOTE_TO_RECEIVER');

	x_due_date := wf_engine.GetItemAttrDate( itemtype => x_item_type,
	      		     	      itemkey  	=> x_item_key,
						 aname 	=> 'DUE_DATE');


      IF x_count > 5 THEN
	 x_disp_count := 5;
      ELSE
	 x_disp_count := x_count;
      END IF;



	l_document := l_document || '<TABLE width="90%" border=0 cellpadding=0 cellspacing=0 SUMMARY="">';


     if x_is_int_req = 'Y' then

     l_document :=  l_document || '<tr><td class=fieldtitle align=right nowrap>' || fnd_message.get_string('ICX','ICX_POR_PRMPT_ORDER_TYPE') || ' &nbsp &nbsp</td> <td align=left class=fielddatabold > '
 || fnd_message.get_string('ICX','ICX_POR_INT_ORDER_TYPE') || ' </td> </tr>' || nl;

	l_document :=  l_document || '<tr><td class=fieldtitle align=right nowrap>' || fnd_message.get_string('ICX','ICX_POR_PRMPT_SO_NUMBER') || ' &nbsp &nbsp</td> <td align=left class=fielddatabold > '
 || x_number|| ' </td> </tr>' || nl;


     else -- purchase requisition

	l_document :=  l_document || '<tr><td class=fieldtitle align=right nowrap>' || fnd_message.get_string('ICX','ICX_POR_PRMPT_PO_NUMBER') || ' &nbsp &nbsp</td> <td align=left class=fielddatabold > '
 || x_number|| ' </td> </tr>' || nl;

	l_document :=  l_document || '<tr><td class=fieldtitle align=right nowrap>' || fnd_message.get_string('ICX','ICX_POR_PRMPT_SUPPLIER') || ' &nbsp &nbsp</td> <td align=left class=fielddatabold > '
 || x_supplier_name || ' </td> </tr>' || nl;

    end if;

	l_document :=  l_document || '<tr><td class=fieldtitle nowrap align=right> ' || fnd_message.get_string('ICX','ICX_POR_PRMPT_DUE_DATE') || ' &nbsp &nbsp</td> ';

	l_document :=  l_document || '<td align=left class=fielddatabold > ' || to_char(x_due_date,'DD-MON-YYYY') || '</td> </tr>' || nl;

    if x_is_int_req = 'N' then -- purchase

      l_document :=  l_document || '<tr><td class=fieldtitle nowrap align=right>' || fnd_message.get_string('ICX','ICX_POR_PRMPT_BUYER_DISP')  || ' &nbsp &nbsp </td> <td align=left  class=fielddatabold > ' || x_buyer_name  || ' </td> </tr>' || nl;

    end if;

      l_document := l_document || '<TR><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR><P>' || nl;

      l_document :=  l_document || '<tr><td class=fieldtitle nowrap align=right>' || fnd_message.get_string('ICX','ICX_POR_NOTE_TO_RCV') || ' &nbsp &nbsp </td> <td  class=fielddatabold align=left>' ||  x_note_to_receiver  || ' </td> </tr> ' || nl;

      l_document := l_document || '<TR><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR><P>' || nl;

      l_document := l_document || '<TR><TD></TD><TD class=subheader1> ' || fnd_message.get_string('ICX','ICX_POR_ITEMS_TO_RECEIVE') || '</TD></TR>' || nl;
       l_document := l_document || '<TR><TD></TD><TD colspan=2 height=1 bgcolor=#cccc99><img src=' || l_base_href || '/OA_MEDIA/FNDITPNT.gif ALT=""></TD></TR>' || nl;
      l_document := l_document || '<TR><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR>' || nl;


      fnd_message.set_name('ICX','ICX_POR_CONFIRM_RCPT_INSTR');
      fnd_message.set_token('LINES_DISP',to_char(x_disp_count));
      fnd_message.set_token('TOTAL_LINES',to_char(x_count));

      x_confirm_rcpt_inst := fnd_message.get;

      l_document := l_document || '<TR><TD></TD> <TD class=instructiontext>' || x_confirm_rcpt_inst || ' </TD></TR> ';

       l_document := l_document || '<TR><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR>' || nl;

      x_document := x_document || l_document;

END;

PROCEDURE get_receipt_lines(x_header_id IN NUMBER,
			    x_requester_id IN NUMBER,
			    x_exp_receipt_date IN DATE,
			    x_is_int_req IN   VARCHAR2,
			    x_document IN OUT NOCOPY VARCHAR2) IS

type select_line_info_Cursor is ref cursor ;
Porcpt_LineInfo select_line_info_Cursor;
l_document VARCHAR2(32000) := '';
i NUMBER:=0;
l_rcpt_record  rcpt_record ;
x_req_number VARCHAR2(20);

x_allow_inv_dest_receipts  varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
NL                VARCHAR2(1) := fnd_global.newline;

BEGIN

        if x_is_int_req = 'Y' then

        if x_allow_inv_dest_receipts = 'N' then
            OPEN Porcpt_LineInfo  for
                 SELECT so_line_number,
			expected_receipt_qty,
	                quantity_delivered,
	                ordered_qty,
                        primary_uom,
	                item_description,
	                currency_code,
	                unit_price,
			req_number
                FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
                WHERE expected_receipt_date is not NULL
                  AND trunc(expected_receipt_date) = trunc(x_exp_receipt_date)
                  AND NVL(receipt_required_flag,'N') = 'Y'
 	          AND destination_type_code = 'EXPENSE'
                  AND requestor_ID is not NULL
                  AND expected_receipt_qty > 0
                  AND so_header_ID = x_header_id
	          AND requestor_ID = x_requester_id
                ORDER BY so_line_number;

         else
             OPEN Porcpt_LineInfo for
                 SELECT so_line_number,
			expected_receipt_qty,
	                quantity_delivered,
	                ordered_qty,
                        primary_uom,
	                item_description,
	                currency_code,
	                unit_price,
			req_number
             FROM  POR_CONFIRM_INTERNAL_RECEIPT_V
             WHERE expected_receipt_date is not NULL
               AND trunc(expected_receipt_date) = trunc(x_exp_receipt_date)
               AND NVL(receipt_required_flag,'N') = 'Y'
 	       AND requestor_ID is not NULL
               AND expected_receipt_qty > 0
               AND so_header_ID = x_header_id
	       AND requestor_ID = x_requester_id
             ORDER BY so_line_number;

       end if;


        else -- purchase requisition

         if x_allow_inv_dest_receipts = 'N' then
            OPEN Porcpt_LineInfo  for
                 SELECT po_line_number,
                        expected_receipt_qty,
	                quantity_delivered,
	                ordered_qty,
                        primary_uom,
	                item_description,
	                currency_code,
	                unit_price,
	                po_distribution_id
                FROM  POR_RCV_ALL_ITEMS_V1
                WHERE expected_receipt_date is not NULL
                  AND trunc(expected_receipt_date) = trunc(x_exp_receipt_date)
                  AND NVL(receipt_required_flag,'N') = 'Y'
 	          AND destination_type_code = 'EXPENSE'
                  AND requestor_ID is not NULL
                  AND expected_receipt_qty > 0
                  AND po_header_ID = x_header_id
	          AND requestor_ID = x_requester_id
                ORDER BY po_line_number;

         else
             OPEN Porcpt_LineInfo for
             SELECT po_line_number,
                    expected_receipt_qty,
	            quantity_delivered,
	            ordered_qty,
                    primary_uom,
	            item_description,
	            currency_code,
	            unit_price,
	            po_distribution_id
             FROM  POR_RCV_ALL_ITEMS_V1
             WHERE expected_receipt_date is not NULL
               AND trunc(expected_receipt_date) = trunc(x_exp_receipt_date)
               AND NVL(receipt_required_flag,'N') = 'Y'
 	       AND requestor_ID is not NULL
               AND expected_receipt_qty > 0
               AND po_header_ID = x_header_id
	       AND requestor_ID = x_requester_id
             ORDER BY po_line_number;

       end if;

     end if; -- check for internal requisition

   LOOP
      FETCH porcpt_lineinfo INTO l_rcpt_record;

	if x_is_int_req = 'N' then

            x_req_number := get_req_number(l_rcpt_record.po_distribution_id);

	else

	     x_req_number := l_rcpt_record.po_distribution_id;
	end if;


      EXIT WHEN porcpt_lineinfo%notfound;

      i := i + 1;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD class=tabledata  align=left headers="catLine_1">' ||
	nvl(to_char(l_rcpt_record.line_number), '&nbsp') || '</TD>' || NL;


      l_document := l_document || '<TD class=tabledata  align=left headers="itemDesc_1">' ||
	nvl(l_rcpt_record.item_description, '&nbsp') || '</TD>' || NL;

       l_document := l_document || '<TD class=tabledata   align=left headers="catUnit_1">' ||
                    nvl(l_rcpt_record.unit_of_measure, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata  align=left headers="qtyReceived_1">' ||
	nvl(to_char(l_rcpt_record.quantity_received), '&nbsp') || '</TD>' || NL;


      l_document := l_document || '<TD class=tabledata   align=left headers="qtyOrdered_1">' ||
	nvl(to_char(l_rcpt_record.ordered_qty), '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata   align=left headers="currency_1">' ||
	nvl(l_rcpt_record.currency_code, '&nbsp') || '</TD>' || NL;

      l_document := l_document || '<TD class=tabledata   align=left headers="catPrice_1">' ||
                    nvl(to_char(l_rcpt_record.unit_price), '&nbsp') || '</TD>' || NL;


      l_document := l_document || '<TD class=tabledata  align=left headers="order_1">' ||
	nvl(x_req_number, '&nbsp') || '</TD>' || NL;


      l_document := l_document || '</TR>' || NL;

      exit when i = 5;

   END LOOP;
   l_document := l_document || '</TABLE>' || NL;
   x_document := l_document;

EXCEPTION
   WHEN OTHERS THEN
        RAISE;

END;


PROCEDURE GET_PO_RCV_NOTIF_MSG(document_id	in	varchar2,
                               display_type	in	varchar2,
                               document	in out	NOCOPY varchar2,
			       document_type	in out	NOCOPY varchar2) IS

l_item_type    wf_items.item_type%TYPE;
l_item_key     wf_items.item_key%TYPE;

l_document         VARCHAR2(32000) := '';
l_document_1         VARCHAR2(32000) := '';
l_document_2         VARCHAR2(32000) := '';
x_header_id              	NUMBER;
x_requester_id                NUMBER;
x_exp_receipt_date  DATE;
x_count NUMBER;
l_rcv_items_url VARCHAR2(1000) := '';

x_is_int_req       VARCHAR2(1);
x_org_id           NUMBER;
l_temp VARCHAR2(100);
l_display_url VARCHAR2(20) := 'Y';

type select_line_info_Cursor is ref cursor ;
 Porcpt_LineInfo select_line_info_Cursor;

 x_allow_inv_dest_receipts  Varchar2(20) := FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');

NL                VARCHAR2(1) := fnd_global.newline;
 l_base_href       VARCHAR(2000) := fnd_profile.value('APPS_FRAMEWORK_AGENT');


BEGIN

   l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
   l_temp := substr(document_id, instr(document_id, ':') + 1,
		    length(document_id) - 2);
   l_item_key :=        substr(l_temp, 1, instr(l_temp, ':') - 1);
   l_display_url := substr(l_temp, instr(l_temp, ':') + 1,
			   length(l_temp) - 2);


   x_is_int_req :=  wf_engine.GetItemAttrText( itemtype  => l_item_type,
			    			  	itemkey   => l_item_key,
			    				aname  => 'IS_INT_REQ');

-- ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of IS_INT_REQ', x_is_int_req);

   if x_is_int_req = 'Y' then

   x_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => l_item_type,
			    			  	itemkey   => l_item_key,
			    				aname  => 'SO_HEADER_ID');

   else

   x_header_id :=  PO_WF_UTIL_PKG.GetItemAttrNumber( itemtype  => l_item_type,
			    			itemkey   => l_item_key,
			    			aname  => 'PO_NUM_REL_NUM');
                                                -- aname  => 'PO_NUMBER');

   end if;

-- ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of header_is', x_header_id);

   x_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => l_item_type,
			    			  	itemkey   => l_item_key,
			    				aname  => 'ORG_ID');

   setOrgCtx(x_org_id);

-- ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of org_id', x_org_id);

	x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => l_item_type,
			    			  	itemkey   => l_item_key,
			    				aname  => 'REQUESTER_ID');

	x_exp_receipt_date :=  wf_engine.GetItemAttrDate  ( itemtype  => l_item_type,
			    			  	    itemkey   => l_item_key,
			    				    aname  => 'DUE_DATE');



	x_count := get_count(l_item_type,l_item_key);

-- ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of x_count', x_count);

	l_rcv_items_url := wf_engine.GetItemAttrText (itemtype => l_item_type,
                                        itemkey => l_item_key,
                                        aname => 'RCV_ORDERS_URL');

	l_rcv_items_url := '<a href="'|| l_rcv_items_url || '">' ||
                             fnd_message.get_string('ICX', 'ICX_POR_GO_TO_RCV') || '</a>';


--ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of l_rcv_items_url', l_rcv_items_url);
--ash_debug.debug('GET_PO_RCV_NOTIF_MSG value of display_type', display_type);

  if (display_type = 'text/html') then

    -- style sheet
    IF (x_count > 0)  then
    --l_document := '<base href="' || l_base_href || '">' || nl || '<!---CONFIRM RECEIPT NOTIFICATION-->';
      l_document := l_document || '<LINK REL=STYLESHEET HREF="' || l_base_href || '/OA_HTML/PORSTYL2.css" TYPE=text/css>' || NL;


    generate_html_header(l_item_type,l_item_key,x_count,l_document);

--ash_debug.debug('GET_PO_RCV_NOTIF_MSG doc1:', l_document);


    l_document := l_document || '<TR><TD></TD><TD><TABLE border=0 width=100% cellpadding=5 cellspacing=1 summary="' || fnd_message.get_string('ICX','ICX_POR_TBL_CONFIRM_RECEIPT') ||'">' || nl;


    l_document := l_document || '<TH class="tableheader" align=left id="catLine_1" >' ||
		fnd_message.get_string('ICX','ICX_POR_CAT_LINE') || '&nbsp&nbsp</TH>' || NL;


    l_document := l_document || NL;
    l_document := l_document || '<TH class="tableheader" align=left id="itemDesc_1" >' ||
                  fnd_message.get_string('ICX','ICX_POR_PRMPT_ITEM_DESCRIPTION') ||
                  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="catUnit_1" >' ||
      fnd_message.get_string('ICX','ICX_POR_CAT_UNIT') ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="qtyReceived_1" >' ||
     fnd_message.get_string('ICX','ICX_POR_PRMPT_QTY_RECEIVED')   ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="qtyOrdered_1" >' ||
      fnd_message.get_string('ICX','ICX_POR_PRMPT_QTY_ORDERED')   ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="currency_1" >' ||
      fnd_message.get_string('ICX','ICX_POR_PRMPT_CURRENCY')  ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="catPrice_1" >' ||
                    fnd_message.get_string('ICX','ICX_POR_CAT_PRICE') ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '<TH class="tableheader" align=left id="order_1" >' ||
                   fnd_message.get_string('ICX','ICX_POR_PRMPT_ORDER') ||  '&nbsp&nbsp</TH>' || NL;

    l_document := l_document || '</TR>' ;
    l_document_1 := NULL;

--ash_debug.debug('GET_PO_RCV_NOTIF_MSG doc2:', l_document);

    get_receipt_lines(x_header_id,x_requester_id,x_exp_receipt_date,x_is_int_req,l_document_1);

    l_document_1:= l_document_1 || '<TR><TD></TD><TD colspan=8 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR>' || nl;


    l_document_1 := l_document_1  || '<TR><TD></TD><TD class=instructiontext colspan=8> ' || fnd_message.get_string('ICX','icx_por_prmpt_confirm_note')  ||  ' </TD></TR>'|| nl;

    l_document_1 := l_document_1  || '<TR><TD></TD><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR>' || nl;

    IF (l_display_url = 'Y') then
       l_document_1:= l_document_1 || '<tr> <td></td><td colspan=2 align=left > ' || l_rcv_items_url || '</td></tr>' || NL;
     END IF;


    l_document := l_document || l_document_1 || '</P></TR> ' ;

    l_document := l_document  || '<TR><TD></TD><TD colspan=2 height=20><img src=' || l_base_href || '/OA_MEDIA/PORTRANS.gif ALT=""></TD></TR>' || nl;


      l_document := l_document || '</TABLE> ' || nl;

   ELSE  /* x_count =0 */

       l_document := l_document || '<TABLE width="90%" border=0 cellpadding=0 cellspacing=0 SUMMARY="">' ||  nl;
 l_document := l_document || '<TR> <TD  class=confirmationtext align=left>' || fnd_message.get_string('ICX','ICX_POR_CONFIRM_NO_ACTION_REQD') || '&nbsp&nbsp</TD></tr> </table>' || NL;


   END IF;  /* end of x_count */


  end if;

  document := l_document;
EXCEPTION
   WHEN OTHERS THEN
       	     wf_core.context ('PORCPTWF','GET_PO_RCV_NOTIF','SQL error ' || sqlcode);

 END;


procedure setOrgCtx (x_org_id IN NUMBER) is

begin

     if x_org_id is not NULL then
       PO_MOAC_UTILS_PVT.set_org_context(x_org_id);
     end if;

end setOrgCtx;

/*===========================================================================
  PROCEDURE NAME:	Populate_Order_Info

  DESCRIPTION:          This function is to populate the laster distribution list

  CHANGE HISTORY:       SVASAMSE  13/05/2003   Created
===========================================================================*/
Function  Populate_Order_Info(itemtype  in varchar2,
                          itemkey in varchar2,
			  skip_distribution_updation in varchar2 default 'N') Return number
IS
  x_allow_inv_dest_receipts  Varchar2(20) :=
             FND_PROFILE.value('POR_ALLOW_INV_DEST_RECEIPTS');
  x_po_header_id  NUMBER;
  x_org_id        NUMBER;
  x_requester_id  NUMBER;
  x_exp_receipt_date     DATE;
  x_dist_id   NUMBER;
  x_qty_inv  NUMBER;
  l_ntf_trig  VARCHAR2(25);
  conf_item_key  VARCHAR2(100);
  line_count NUMBER :=0;
  x_qty_rec NUMBER;
  x_progress      VARCHAR2(1000):= '001';
  type select_line_info_Cursor is ref cursor ;
  Porcpt_LineInfo select_line_info_Cursor;

BEGIN
     x_po_header_id :=  wf_engine.GetItemAttrNumber(
                                 itemtype  => itemtype,
			   	 itemkey   => itemkey,
				 aname  => 'PO_HEADER_ID');

     x_org_id       :=  wf_engine.GetItemAttrNumber(
	 			 itemtype  => itemtype,
  			    	 itemkey   => itemkey,
				 aname  => 'ORG_ID');
     setOrgCtx(x_org_id);

     x_requester_id :=  wf_engine.GetItemAttrNumber(
	  			 itemtype  => itemtype,
  			    	 itemkey   => itemkey,
  				 aname  => 'REQUESTER_ID');

     x_exp_receipt_date :=  wf_engine.GetItemAttrDate  (
				 itemtype  => itemtype,
  			  	 itemkey   => itemkey,
   			    	 aname  => 'DUE_DATE');

     if x_allow_inv_dest_receipts is NULL then
       x_allow_inv_dest_receipts := 'N';
     end if;
    x_progress := 'Populate_Order_Info 002 x_po_header_id: ' || x_po_header_id || ' x_org_id: ' || x_org_id ||
				  ' x_requester_id: '|| x_requester_id || ' x_exp_receipt_date: ' || x_exp_receipt_date ||
				  ' x_allow_inv_dest_receipts: ' || x_allow_inv_dest_receipts;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype, itemkey, x_progress);
    END IF;
     if x_allow_inv_dest_receipts = 'N' then

       OPEN Porcpt_LineInfo  for

	 -- query to retrieve only the distribution
	 -- id's and invoiced quantity. And adding new query
	 -- to retrieve the Invoiced matched lines.

	 /*16697591
	 Add condition to avoid the case that expected_receipt_date is not null,
	 trunc(rcv.expected_receipt_date + 1) > trunc(SYSDATE)) and
	 ELECT 1 FROM ap_holds has value.
	 */

	 SELECT rcv.po_distribution_id,
  	        rcv.quantity_invoiced,
                rcv.quantity_delivered
	 FROM  POR_RCV_ALL_ITEMS_V1 rcv, po_headers_all poh
	 WHERE poh.PO_HEADER_ID = x_po_header_id AND rcv.po_header_ID = x_po_header_ID
	   AND rcv.requestor_ID = x_requester_ID
           AND ((rcv.expected_receipt_date is not null
	      AND trunc(rcv.expected_receipt_date + 1) <= trunc(SYSDATE))
	      OR (rcv.expected_receipt_date is  null -- add for 16697591
			AND EXISTS (SELECT 1 FROM ap_holds aph
              WHERE aph.line_location_id = rcv.po_line_location_id
	        AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	        AND aph.release_lookup_code IS NULL
	        AND rcv.quantity_invoiced > quantity_delivered
	        --AND rcv.quantity_invoiced <= ordered_qty     --Bug 18421821
                )))
		AND NVL(rcv.receipt_required_flag,'N') = 'Y'
	    AND rcv.destination_type_code = 'EXPENSE'
	    AND rcv.expected_receipt_qty > 0
		AND NVL (poh.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY_CLOSED')
          ORDER BY po_distribution_id;
     else
       OPEN Porcpt_LineInfo  for

	 -- query to retrieve only the distribution
	 -- id's and invoiced quantity. And adding new query
	 -- to retrieve the Invoiced matched lines.

	 SELECT rcv.po_distribution_id,
  	        rcv.quantity_invoiced,
                rcv.quantity_delivered
	 FROM  POR_RCV_ALL_ITEMS_V1 rcv, po_headers_all poh
	 WHERE poh.PO_HEADER_ID = x_po_header_id AND rcv.po_header_ID = x_po_header_ID
	   AND rcv.requestor_ID = x_requester_ID
           AND ((rcv.expected_receipt_date is not null
	      AND trunc(rcv.expected_receipt_date + 1) <= trunc(SYSDATE))
	       OR (rcv.expected_receipt_date is  null -- add for 16697591
		    AND EXISTS (SELECT 1 FROM ap_holds aph
              WHERE aph.line_location_id = rcv.po_line_location_id
	        AND aph.hold_lookup_code in ('QTY REC', 'AMT REC')
	        AND aph.release_lookup_code IS NULL
	        AND rcv.quantity_invoiced > quantity_delivered
	        --AND rcv.quantity_invoiced <= ordered_qty    --Bug 18421821
                )))
  	    AND NVL(rcv.receipt_required_flag,'N') = 'Y'
	    AND rcv.expected_receipt_qty > 0
		AND NVL (poh.closed_code,'OPEN') NOT IN ('CLOSED','FINALLY_CLOSED')
          ORDER BY po_distribution_id;

     end if;  /** inv dest receipts allowed check **/

     FOR I IN 1..200 LOOP
       FETCH Porcpt_LineInfo
          INTO x_dist_id, x_qty_inv, x_qty_rec;

       EXIT WHEN Porcpt_LineInfo%NOTFOUND;

       -- If atleast one line has invoice match then we should
       -- display the 'Receive Up To Amount Invoiced' button.
       -- The variable l_ntf_trig is set to INV_MATCH if qty is > 0
       -- By default the value of it is 'NBD_TRIG'
       If (x_qty_inv > x_qty_rec ) then
         l_ntf_trig := 'INV_MATCH';
       end if;

      -- update the distribution data only if the skip validation param is not Y
      if (skip_distribution_updation <> 'Y') then
         -- Get the wf_item_key item attribute value
         conf_item_key := PO_WF_UTIL_PKG.GetItemAttrText(
	       		    itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'WF_ITEM_KEY');

         -- Update the PO_DISTRIBUTIONS_ALL table with this
         -- item key value and qty invoiced value
         UPDATE PO_DISTRIBUTIONS_ALL
         SET    WF_ITEM_KEY = conf_item_key,
	        invoiced_val_in_ntfn = x_qty_inv
         WHERE po_distribution_id = x_dist_id;
       end if;

       line_count := line_count+1;

     END LOOP;
    x_progress := 'Populate_Order_Info 003 line_count: ' || line_count ;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype, itemkey, x_progress);
    END IF;
   CLOSE Porcpt_LineInfo;

     PO_WF_UTIL_PKG.SetItemAttrText (itemtype	=> itemtype,
				itemkey  	=> itemkey,
				aname 	=> 'NTF_TRIGGERED_BY',
			        avalue	=> l_ntf_trig);

     -- set the current date. This is used to verify for need by
     -- date trigerred lines during 'Receive in full' action
     PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
				itemkey  => itemkey,
				aname 	=> 'NTF_TRIGGERED_DATE',
			    avalue	=> (to_char(sysdate, 'DD/MM/YYYY')));  --bug 16556483
	x_progress := 'Populate_Order_Info 004 l_ntf_trig: ' || l_ntf_trig || ' line_count: ' || line_count;
    IF (g_po_wf_debug = 'Y') THEN
        po_wf_debug_pkg.insert_debug(itemtype, itemkey, x_progress);
    END IF;
  return line_count;
END Populate_Order_Info;

/*===========================================================================
  PROCEDURE NAME:	Process_rcv_amt_billed

  DESCRIPTION:          This procedure processes the Receiving Transaction
			interface when the workflow notification is reponsed
			as 'Receive Upto Amount Billed'.

			It checks to ensure that the shipment(s) is/are still
			opened.  It invokes the Receiving Transaction interface
			procedure to insert the receipt records into the
			receiving transaction interface table.

			The Receiving Transaction Manager is then called in
			'ON-LINE' mode to process the receipt records immediately.

                        If there are errors returned from the Receiving
			Transaction Manager, the error status is set the
			workflow item attribute for notifying the buyer and
			requester of the error.

  CHANGE HISTORY:       SVASAMSE  13/05/2003   Created
===========================================================================*/

PROCEDURE  Process_rcv_amt_billed(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          result    out NOCOPY varchar2)
IS
 TYPE shipment_orders_cursor IS ref CURSOR;
 Porcpt_Shipment shipment_orders_cursor;

  x_group_id                  NUMBER;
  x_RCV_txns_rc               NUMBER := 0;
  x_po_header_id              NUMBER;
  x_requester_id   	      NUMBER;

  x_org_id		      NUMBER;
  x_requester_username	      WF_USERS.NAME%TYPE; -- Use the requester username to be passed to initialize
  x_rcv_trans_status          VARCHAR2(500) := NULL;
  x_insert_txns_status        NUMBER;

  t_po_header_id		rcvNumberArray;
  t_line_location_id		rcvNumberArray;
  t_expected_receipt_qty	rcvNumberArray;
  t_ordered_uom			rcvVarcharArray;
  t_item_id			rcvNumberArray;
  t_primary_uom_class		rcvVarcharArray;
  t_org_id			rcvNumberArray;
  t_po_distribution_id		rcvNumberArray;
  t_Comments			rcvVarcharArray;
  t_PackingSlip			rcvVarcharArray;
  t_WayBillNum			rcvVarcharArray;

  x_message_token VARCHAR2(2000);
  x_progress  varchar2(1000):= '001';
BEGIN

  IF  ( funmode = 'RUN'  ) THEN
    --
    x_po_header_id :=  wf_engine.GetItemAttrNumber(
                            itemtype  => itemtype,
                            itemkey   => itemkey,
                            aname  => 'PO_HEADER_ID');

    -- Setup the organization context for the multi-org environment

    x_org_id :=  wf_engine.GetItemAttrNumber(
			        itemtype => itemtype,
			        itemkey  => itemkey,
			        aname  => 'ORG_ID');

    -- Setup the organization context for the multi-org environment
    setOrgCtx(x_org_id);
    --Use the requester username to be passed to initialize
	x_requester_username := wf_engine.GetItemAttrText   ( itemtype	=> itemtype,
	      		     	                              itemkey 	=> itemkey,
  	      		     	                              aname 	=> 'REQUESTER_USERNAME');

	PORCPTWF.initialize(x_requester_username,x_org_id);

    /** rewrite after initialize **/
    x_requester_id := wf_engine.GetItemAttrNumber(
				  itemtype  => itemtype,
                                  itemkey   => itemkey,
                                  aname  => 'REQUESTER_ID');

    SELECT rcv_interface_groups_s.nextval
    INTO   x_group_id
    FROM   sys.dual;

    OPEN  Porcpt_Shipment for
      SELECT po_header_id,
             po_line_location_id,
             decode(SIGN(invoiced_val_in_ntfn-quantity_delivered),1,
		     (invoiced_val_in_ntfn-quantity_delivered),0)
					expected_receipt_qty,
             primary_uom,
             item_id,
             primary_uom_class,
             to_organization_id,
             po_distribution_id,
             null,
             null,
             null
      FROM  POR_RCV_ALL_ITEMS_V1
      WHERE po_header_ID = x_po_header_ID
        AND wf_item_key = itemKey;

    FETCH porcpt_Shipment BULK COLLECT into t_po_header_id,
            t_line_location_id,
            t_expected_receipt_qty,
            t_ordered_uom,
            t_item_id,
            t_primary_uom_class,
            t_org_id,
            t_po_distribution_id,
            t_Comments,
            t_PackingSlip,
            t_WayBillNum;

    CLOSE Porcpt_Shipment;

    for i in 1..t_po_header_id.count loop
      x_progress := 'poheaderid*' ||to_char(t_po_header_id(i))
 	     || '*t_line_location_id*' ||to_char(t_line_location_id(i))
	     || '*ex_rcpt_qty*' || t_expected_receipt_qty(i)
	     || '*uom*' || t_ordered_uom(i)
	     || '*itemid*' ||  to_char(t_item_id(i))
	     || '*uom_class*' ||  t_primary_uom_class(i)
	     || '*org_id*' || to_char(t_org_id(i))
             || '*t_po_distribution_id*' || to_char(t_po_distribution_id(i))
             || '*comments*' || t_comments(i)
	     || '*pkgSlip*' || t_packingSlip(i)
             || '*waybillnum*'  || t_waybillNum(i);
      x_progress := x_progress || '*x_group_id*' || to_char(x_group_id);

      IF (g_po_wf_debug = 'Y') THEN
	  po_wf_debug_pkg.insert_debug(itemtype, itemkey, x_progress);
      END IF;
    end loop;

    x_insert_txns_status := POR_RCV_ORD_SV.groupPoTransaction(
                               t_po_header_id,
                               t_line_location_id,
                               t_expected_receipt_qty,
                               t_ordered_uom,
                               SYSDATE,
                               t_item_id,
                               t_primary_uom_class,
                               t_org_id,
                               t_po_distribution_id,
                               x_group_id,
                               'WP4_CONFIRM',
                               t_Comments,
                               t_PackingSlip,
                               t_WayBillNum);

    IF x_insert_txns_status = 0 THEN
      x_RCV_txns_rc := por_rcv_ord_sv.process_transactions(X_group_id, 'WF');

      -- At least one of the receiving transactions inserted
      IF x_RCV_txns_rc is NULL OR x_RCV_txns_rc = 0 THEN
        RESULT := 'PASSED';

	-- Clean the po distribtions table
	update po_distributions
	set wf_item_key = ''
	where wf_item_key = itemKey;

      ELSE
        get_txn_error_message(x_group_id, x_RCV_txns_rc, x_rcv_trans_status, x_message_token);

        wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                      itemkey  	=> Itemkey,
                                      aname 	=> 'RCV_TRANS_STATUS',
                                      avalue	=> x_rcv_trans_status );

        wf_engine.SetItemAttrText   ( itemtype	=> Itemtype,
                                      itemkey  	=> Itemkey,
                                      aname 	=> 'RCV_ERR_MSG_TOKEN',
                                      avalue	=> x_message_token );
        RESULT := 'FAILED';
      END IF;
    ELSE

      x_rcv_trans_status := 'RCV_RCPT_INSERT_FAILED';
      wf_engine.SetItemAttrText(itemtype     => Itemtype,
                                itemkey      => Itemkey,
                                aname => 'RCV_TRANS_STATUS',
                                avalue => x_rcv_trans_status );
      RESULT := 'FAILED';
    END IF;
  ELSIF ( funmode = 'CANCEL' ) THEN
    null;
  END IF;
END Process_rcv_amt_billed;

/*===========================================================================
  PROCEDURE NAME:	Restart_rcpt_process

  DESCRIPTION:   	This procedure is to restart the confirm receipt
                        workflow process.

  CHANGE HISTORY:       SVASAMSE   13/05/2005    Created
===========================================================================*/
PROCEDURE  Restart_rcpt_process(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          result    out NOCOPY varchar2)
IS
x_po_header_id number;
x_requester_id number;
x_sys_date date;
x_exp_receipt_date date;
x_WF_ItemKey varchar2(240);
x_revision_num number;
x_po_num_rel_num POR_RCV_ALL_ITEMS_V1.PO_NUM_REL_NUM%type;
BEGIN
  x_po_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
 		    			  	  itemkey   => itemkey,
			    			  aname  => 'PO_HEADER_ID');

  x_requester_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname  => 'REQUESTER_ID');

  x_exp_receipt_date :=  wf_engine.GetItemAttrDate ( itemtype  => itemtype,
			    			     itemkey   => itemkey,
			    			     aname  => 'DUE_DATE');

  x_revision_num :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname  => 'PO_REVISION_NUM');

  x_po_num_rel_num := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'PO_NUM_REL_NUM');
  select sysdate
  into x_sys_date
  from dual;

  -- Create a new item key
  x_WF_ItemKey := to_char(x_po_header_id) ||  ';' ||
			  to_char(x_requester_id) ||  ';' ||
			  to_char(x_sys_date,'DD-MON-YYYY:HH24:MI');

  -- Start the Rcpt Process with the new item key
  Start_Rcpt_Process(x_po_header_id, x_requester_id, x_exp_receipt_date,
		x_WF_ItemKey, x_revision_num, 'N', '-1', x_po_num_rel_num);

END Restart_rcpt_process;

/*===========================================================================
  PROCEDURE NAME:	Does_invoice_match_exist

  DESCRIPTION:   	This procedure is used to check if there are invoice
                        matched lines in the notification.
			Retruns true if the invoice match exists.

  CHANGE HISTORY:       SVASAMSE   13/05/2005    Created
===========================================================================*/
PROCEDURE  Does_invoice_match_exist(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funmode   in varchar2,
                          resultout out NOCOPY varchar2)
IS
 l_ntf_trig_by varchar2(25);
begin

 l_ntf_trig_by :=  PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
		 	          itemkey  => itemkey,
			          aname    => 'NTF_TRIGGERED_BY');

 If l_ntf_trig_by = 'INV_MATCH' then
   resultout := wf_engine.eng_completed || ':' ||  'Y';
 else
   resultout := wf_engine.eng_completed || ':' ||  'N';
 end if;

END Does_invoice_match_exist;


-- Bug 15921367
/*===========================================================================
  FUNCTION NAME:	is_complex_po

  DESCRIPTION:   	This function is used to check if the po is complex po
                        or not.
			Retruns Y if is complex po.

  CHANGE HISTORY:       Lucky   14/12/2012    Created
===========================================================================*/

FUNCTION is_complex_po(x_po_header_id IN NUMBER) RETURN VARCHAR
IS
BEGIN
  IF(PO_COMPLEX_WORK_PVT.IS_COMPLEX_WORK_PO(x_po_header_id)) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF ;
END is_complex_po;
-- Bug 15921367


END PORCPTWF;

/
