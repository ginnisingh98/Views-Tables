--------------------------------------------------------
--  DDL for Package Body POR_RCV_TRANSACTION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_RCV_TRANSACTION_SV" AS
/* $Header: PORRCVTB.pls 120.4.12010000.10 2014/03/31 02:15:14 aacai ship $*/

/******************************************************************
 **  Function :     insert_transaction_interface
 **  Description :  This is a function called from Java layer
 **                 currently used by return items and correction on the web.
 ******************************************************************/
procedure insert_row(p_transaction_date      in date,
                     p_parent_transaction_id in number,
                     p_group_id              in number,
                     p_txn_qty               in number,
                     p_txn_uom               in varchar2,
                     p_primary_qty           in number,
                     p_primary_uom           in varchar2,
                     p_transaction_type      in varchar2,
                     p_Receiving_Location_Id in number,
                     p_Return_Reason_Id      in number,
                     p_subinventory          in varchar2,
                     p_RMA_Reference         in varchar2,
                     p_employee_id           in number,
				p_Comments              in varchar2,
				x_parent_interface_txn_id IN OUT NOCOPY number);

PROCEDURE  insert_interface_errors ( rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
 	                   X_column_name IN VARCHAR2,
 	                   X_err_message IN VARCHAR2);

function get_rtv_id(p_transaction_id     in number) return number;

function insert_transaction_interface(
		p_Transaction_Type       in varchar2,
                p_caller                 in varchar2,
		p_Parent_Transaction_Id  in number,
                p_Quantity               in number,   -- if correction, pass +/- qty.
                p_Group_Id               in number,
                p_Group_Id2              in number,
                p_Transaction_Date       in date      default sysdate,
                p_Unit_Of_Measure        in varchar2  default null,
                p_Return_Reason_Id       in number    default null,
                p_RMA_reference          in varchar2  default null,
                p_Subinventory           in varchar2  default null,
                p_Receiving_Location_Id  in number    default null,
		p_Comments		 in varchar2  default null) return number is

  x_user_id        number;
  x_employee_id    number;

  x_item_id        number;
  x_txn_uom        varchar2(25) := p_Unit_Of_Measure;
  x_primary_uom    varchar2(25);
  x_txn_qty        number := p_Quantity;
  x_primary_qty    number;

  x_parent_type        varchar2(25);
  x_grandparent_type   varchar2(25);
  x_grandparent_id     number;
  x_txn_org_id         number;
  x_user_org_id        number;
  x_parent_interface_txn_id number := NULL;
begin

  /* Get info from parent transaction and Org ID*/

  SELECT RL.PRIMARY_UNIT_OF_MEASURE,
         RL.ITEM_ID,
         RT.TRANSACTION_TYPE,
         NVL(OH.ORG_ID, PH.ORG_ID)
    INTO X_PRIMARY_UOM,
         X_ITEM_ID,
         X_PARENT_TYPE,
         X_TXN_ORG_ID
    FROM RCV_TRANSACTIONS RT,
         RCV_SHIPMENT_LINES RL,
         PO_HEADERS_ALL PH,
         OE_ORDER_HEADERS_ALL OH
   WHERE RT.TRANSACTION_ID = P_PARENT_TRANSACTION_ID
     AND RT.SHIPMENT_LINE_ID = RL.SHIPMENT_LINE_ID
     AND RT.PO_HEADER_ID = PH.PO_HEADER_ID(+)
     AND RT.OE_ORDER_HEADER_ID = OH.HEADER_ID(+);

  x_user_org_id := MO_GLOBAL.get_current_org_id;

  if (x_txn_org_id <> MO_GLOBAL.get_current_org_id) then
    mo_global.set_policy_context(p_access_mode => 'S',
                                   p_org_id      => x_txn_org_id);
  end if;

  x_user_id := fnd_global.user_id;

  BEGIN
    SELECT HR.PERSON_ID
     INTO   x_employee_id
     FROM   FND_USER FND, per_people_f HR
     WHERE  FND.USER_ID = x_user_id
     AND    FND.EMPLOYEE_ID = HR.PERSON_ID
	 AND    sysdate between hr.effective_start_date AND hr.effective_end_date
     AND    ROWNUM = 1;
  EXCEPTION
   WHEN others THEN
	x_employee_id := 0;
  END;

   /* DEBUG Need to convert received qty and uom into ordered qty and uom
           Find out how to get the uom_class... see if it is           */
   /*
   **   If you're receiving a one-time item then go get the primary
   **   unit of measure based on the unit of measure class that is
   **   assigned to the base transaction unit of measure.
   */


   /**  DEBUG : Can we just call this routine if the receipt uom
    **  is different from primary_uom?   **/

   if (X_txn_uom <> X_primary_uom) then
      PO_UOM_S.UOM_CONVERT  (x_txn_qty,
			     x_txn_uom,
			     x_item_id,
		             x_primary_uom,
			     x_primary_qty);
   else
      X_primary_qty := X_txn_qty;
   end if;

   if p_transaction_type = 'RETURN TO VENDOR' then

     insert_row(p_transaction_date     ,
                p_parent_transaction_id,
                p_group_id             ,
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

  elsif p_transaction_type = 'CORRECT' and
        x_parent_type = 'DELIVER' and
        x_txn_qty > 0 then

     -- grand parent is the receive transaction
     select rt2.transaction_type,
            rt2.transaction_id
       into x_grandparent_type,
            x_grandparent_id
       from rcv_transactions rt1,
            rcv_transactions rt2
      where rt1.transaction_id = p_parent_transaction_id
        and rt2.transaction_id = rt1.parent_transaction_id;

     -- correct receive first if qty is +'ve
     insert_row(p_transaction_date     ,
                x_grandparent_id       ,
                p_group_id             ,-- Bug12529647, use the same group_id rather than 2 different ids.
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);
     insert_row(p_transaction_date     ,
                p_parent_transaction_id,
                p_group_id            ,-- Bug12529647, use the same group_id rather than 2 different ids.
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

  elsif p_transaction_type = 'CORRECT' and
        x_parent_type = 'DELIVER' and
        x_txn_qty < 0 then

     -- grand parent is the receive transaction
     select rt2.transaction_type,
            rt2.transaction_id
       into x_grandparent_type,
            x_grandparent_id
       from rcv_transactions rt1,
            rcv_transactions rt2
      where rt1.transaction_id = p_parent_transaction_id
        and rt2.transaction_id = rt1.parent_transaction_id;

     -- correct deliver first if qty is -'ve
     insert_row(p_transaction_date     ,
                p_parent_transaction_id,
                p_group_id             ,-- Bug12529647, use the same group_id rather than 2 different ids.
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

     insert_row(p_transaction_date     ,
                x_grandparent_id       ,
                p_group_id             ,-- Bug12529647, use the same group_id rather than 2 different ids.
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

  elsif p_transaction_type = 'CORRECT' and
        x_parent_type = 'RETURN TO RECEIVING' and
        x_txn_qty < 0 then

     -- grand parent is the rtv transaction
     x_grandparent_id := get_rtv_id(p_parent_transaction_id);

     -- correct rtv first where qty is -'ve
     insert_row(p_transaction_date     ,
                x_grandparent_id       ,
                p_group_id             ,
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

     insert_row(p_transaction_date     ,
                p_parent_transaction_id,
                p_group_id2            ,
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

  elsif p_transaction_type = 'CORRECT' and
        x_parent_type = 'RETURN TO RECEIVING' and
        x_txn_qty > 0 then

     -- grand parent is the rtv transaction
     x_grandparent_id := get_rtv_id(p_parent_transaction_id);

     -- correct rtr first where qty is +'ve
     insert_row(p_transaction_date     ,
                p_parent_transaction_id,
                p_group_id             ,
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);

     insert_row(p_transaction_date     ,
                x_grandparent_id       ,
                p_group_id2            ,
                x_txn_qty              ,
                x_txn_uom              ,
                x_primary_qty          ,
                x_primary_uom          ,
                p_transaction_type     ,
                p_Receiving_Location_Id,
                p_Return_Reason_Id     ,
                p_subinventory         ,
                p_RMA_Reference        ,
                x_employee_id          ,
		p_Comments				,
		x_parent_interface_txn_id);
	end if;

  if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
    mo_global.set_policy_context(p_access_mode => 'S',
                                 p_org_id      => x_user_org_id);
  end if;

  return 0;

exception
   when others THEN
          if (MO_GLOBAL.get_current_org_id <> x_user_org_id) then
            mo_global.set_policy_context(p_access_mode => 'S',
                                         p_org_id      => x_user_org_id);
          end if;
	  ERROR_STACK.PUSHMESSAGE( substr(SQLERRM,12,512),'ICX');
          return 1;

end insert_transaction_interface;

/*************************************************************
 **  Function :     Process_Transactions
 **  Description :  This is a procedure that validates
 **                 the transactions and call_txn_processor.
 **************************************************************/

function process_transactions(p_group_id  in number,
                              p_group_id2 in number,
                              p_caller    in varchar2)
return number

is
CURSOR  rcv_get_interface_rows IS
SELECT  *
FROM    rcv_transactions_interface
WHERE   group_id = p_group_id OR group_id = p_group_id2
ORDER BY interface_transaction_id;

rcv_trx     rcv_transactions_interface%ROWTYPE;
  x_return number;
valid_wip_info                  NUMBER                :=0;
X_column_name                   VARCHAR2(30);
X_err_message                   VARCHAR2(240);

BEGIN

  /*
  ** if this is a shop floor destination then make sure that the job
  ** information is still valid
  */

  OPEN rcv_get_interface_rows;
  LOOP
     FETCH rcv_get_interface_rows INTO
         rcv_trx;
     EXIT WHEN rcv_get_interface_rows%NOTFOUND;

     IF (rcv_trx.destination_type_code = 'SHOP FLOOR') THEN
        valid_wip_info := rcv_transactions_sv.val_wip_info (
                     rcv_trx.to_organization_id,
                     rcv_trx.wip_entity_id,
                     rcv_trx.wip_operation_seq_num,
                     rcv_trx.wip_resource_seq_num,
                     rcv_trx.wip_line_id,
                     rcv_trx.wip_repetitive_schedule_id,
                     rcv_trx.po_line_id);

         IF (valid_wip_info <> 0) THEN

           if valid_wip_info = 10 then

              X_column_name := 'TO_ORGANIZATION_ID';
              X_err_message := 'RCV_DEST_ORG_NA';

           elsif valid_wip_info = 20 then

              X_column_name := 'WIP_ENTITY_ID';
              X_err_message := 'RCV_WIP_ENTITY_ID_NA';

           elsif valid_wip_info = 30 then

              X_column_name := 'WIP_OP_SEQ_NUM';
              X_err_message := 'RCV_WIP_OP_SEQ_NUM_NA';

           elsif valid_wip_info = 40 then

              X_column_name := 'WIP_RES_SEQ_NUM';
              X_err_message := 'RCV_WIP_RES_SEQ_NUM_NA';

           elsif valid_wip_info = 50 then

              X_column_name := 'WIP_REPETITIVE_SCHEDULE_ID';
              X_err_message := 'RCV_WIP_REP_SCH_JOB_NOT_OPEN';

           elsif valid_wip_info = 60 then

              X_column_name := '_WIP_ENTITY_ID';
              X_err_message := 'RCV_WIP_JOB_NOT_OPEN';

           end if;

           insert_interface_errors(rcv_trx,
                                   X_column_name,
                                   X_err_message);


           EXIT;
         END IF;

      END IF;
  END LOOP;

  /* If job information is valid proceed to returns */

  IF (valid_wip_info = 0) THEN

    x_return := por_rcv_ord_SV.call_txn_processor(p_group_id, p_caller);

    if x_return = 0 then

      x_return := por_rcv_ord_SV.call_txn_processor(p_group_id2, p_caller);

    end if;

    return x_return;

  ELSE
    return 98;  /* error code for invalid job information */
  END IF;

end process_transactions;


function get_net_delivered_qty(p_txn_id in number) return number is

   X_progress            VARCHAR2(3)  := '000';

   X_delivered_quantity  NUMBER := 0;

   v_txn_id              NUMBER := 0;
   v_quantity            NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       nvl(quantity, amount),
       transaction_type,
       parent_transaction_id
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

begin

       OPEN c_txn_history(p_txn_id);

       X_progress := '003';

       --asn_debug.put_line('TXN HISTOR');
       LOOP
         FETCH c_txn_history INTO v_txn_id,
                                  v_quantity,
                                  v_transaction_type,
                                  v_parent_id;

         EXIT WHEN c_txn_history%NOTFOUND;

         X_progress := '004';
	-- asn_debug.put_line('TRANSACTION TYPE '  || v_transaction_type);
	 	-- asn_debug.put_line('QUANTITY '  || v_quantity);

         IF v_transaction_type = 'DELIVER' THEN

           X_delivered_quantity := X_delivered_quantity + v_quantity;

         ELSIF v_transaction_type = 'RETURN TO RECEIVING' THEN

           X_delivered_quantity := X_delivered_quantity - v_quantity;

         ELSIF v_transaction_type = 'CORRECT' THEN

           /* The correction function is based on parent transaction type */

           SELECT
             transaction_type
           INTO
             v_parent_type
           FROM
             rcv_transactions
           WHERE
             transaction_id = v_parent_id;

           IF v_parent_type = 'DELIVER' THEN

             X_delivered_quantity := X_delivered_quantity + v_quantity;

           ELSIF v_parent_type = 'RETURN TO RECEIVING' THEN

             X_delivered_quantity := X_delivered_quantity - v_quantity;

           END IF;
         END IF;

       END LOOP;

       CLOSE c_txn_history;

       return X_delivered_quantity;

end get_net_delivered_qty;

function get_net_returned_qty(p_txn_id in number) return number is

   X_progress            VARCHAR2(3)  := '000';

   X_returned_quantity  NUMBER := 0;

   v_txn_id              NUMBER := 0;
   v_quantity            NUMBER := 0;
   v_transaction_type    VARCHAR2(25) := '';
   v_parent_id           NUMBER := 0;
   v_parent_type         VARCHAR2(25) := '';

   CURSOR c_txn_history (c_transaction_id NUMBER) IS
     SELECT
       transaction_id,
       quantity,
       transaction_type,
       parent_transaction_id
     FROM
       rcv_transactions
     START WITH transaction_id = c_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id;

begin

       OPEN c_txn_history(p_txn_id);

       X_progress := '003';

       LOOP
         FETCH c_txn_history INTO v_txn_id,
                                  v_quantity,
                                  v_transaction_type,
                                  v_parent_id;

         EXIT WHEN c_txn_history%NOTFOUND;

         X_progress := '004';

         IF v_transaction_type in ('RETURN TO RECEIVING', 'RETURN TO VENDOR') THEN

           X_returned_quantity := X_returned_quantity + v_quantity;

         ELSIF v_transaction_type = 'CORRECT' THEN

           /* The correction function is based on parent transaction type */

           SELECT
             transaction_type
           INTO
             v_parent_type
           FROM
             rcv_transactions
           WHERE
             transaction_id = v_parent_id;

           IF v_parent_type in ('RETURN TO RECEIVING', 'RETURN TO VENDOR') THEN

             X_returned_quantity := X_returned_quantity + v_quantity;

           END IF;
         END IF;

       END LOOP;

       CLOSE c_txn_history;

       return X_returned_quantity;

end get_net_returned_qty;

procedure insert_row(p_transaction_date      in date,
                     p_parent_transaction_id in number,
                     p_group_id              in number,
                     p_txn_qty               in number,
                     p_txn_uom               in varchar2,
                     p_primary_qty           in number,
                     p_primary_uom           in varchar2,
                     p_transaction_type      in varchar2,
                     p_Receiving_Location_Id in number,
                     p_Return_Reason_Id      in number,
                     p_subinventory          in varchar2,
                     p_RMA_Reference         in varchar2,
                     p_employee_id           in number,
		     p_Comments		     in varchar2,
			 x_parent_interface_txn_id in out nocopy number) IS

x_create_debit_memo_flag varchar2(1) := null;
x_from_subinventory varchar2(240) := null;
x_from_locator_id number := null;
x_interface_id number :=null;
x_uom_code             VARCHAR2(5)  := NULL;

begin

-- for amount based lines x_uom_code is populated as currency code in RT hence NO_DATA_FOUND arises.
   BEGIN

     select uom_code  into  x_uom_code
       from mtl_units_of_measure  where unit_of_measure = p_txn_uom;

    EXCEPTION

     WHEN NO_DATA_FOUND THEN
     x_uom_code := NULL;

    END ;



   if p_transaction_type = 'RETURN TO VENDOR' then
     begin
        if fnd_profile.Value('POR_ENABLE_DEBIT_MEMO') = 'Y' then
   	  select povs.create_debit_memo_flag
            into x_create_debit_memo_flag
	    from po_vendor_sites povs, rcv_transactions rt
	   where povs.vendor_site_id = rt.vendor_site_id
	     and rt.transaction_id = p_parent_transaction_id;
        else
           x_create_debit_memo_flag := 'N';
        end if;
     exception
       when others then
        x_create_debit_memo_flag := 'N';
     end;
  end if;

  if p_transaction_type = 'RETURN TO VENDOR' or
     p_txn_qty < 0
  then
    select rt.subinventory, rt.locator_id
      into x_from_subinventory, x_from_locator_id
      from rcv_transactions rt
      where rt.transaction_id = p_parent_transaction_id;
  else
    select rt.from_subinventory, rt.from_locator_id
        into x_from_subinventory, x_from_locator_id
        from rcv_transactions rt
        where rt.transaction_id = p_parent_transaction_id;
  end if;

  -- Setting validation flag to Y for ROI
	Select RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
	   INTO x_interface_id
 	FROM DUAL;

  insert into RCV_TRANSACTIONS_INTERFACE
    (   receipt_source_code,
        interface_transaction_id,
        group_id,
        org_id,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date,
        last_update_login,
        source_document_code,
        destination_type_code,
        transaction_date,
        quantity,
        unit_of_measure,
        amount,
        shipment_header_id,
        shipment_line_id,
        substitute_unordered_code,
        employee_id,
        parent_transaction_id,
        inspection_status_code,
        inspection_quality_code,
        po_header_id,
        po_release_id,
        po_line_id,
        po_line_location_id,
        po_distribution_id,
        po_revision_num,
        po_unit_price,
        currency_code,
        currency_conversion_rate,
	currency_conversion_type,
	currency_conversion_date,
        requisition_line_id,
        routing_header_id,
        routing_step_id,
        comments,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        transaction_type,
        location_id,
        processing_status_code,
        processing_mode_code,
        transaction_status_code,
        category_id,
        vendor_lot_num,
        reason_id,
        primary_quantity,
        primary_unit_of_measure,
        item_id,
        item_revision,
        to_organization_id,
        deliver_to_location_id,
        destination_context,
        vendor_id,
        deliver_to_person_id,
        subinventory,
        from_subinventory,
        locator_id,
        from_locator_id,
        wip_entity_id,
        wip_line_id,
        wip_repetitive_schedule_id,
        wip_operation_seq_num,
        wip_resource_seq_num,
        bom_resource_id,
        from_organization_id,
        receipt_exception_flag,
        department_code,
        item_description,
        movement_id,
        use_mtl_lot,
        use_mtl_serial,
        RMA_REFERENCE,
        ussgl_transaction_code,
        government_context,
	vendor_site_id,
	create_debit_memo_flag,
        job_id,
        matching_basis, parent_interface_txn_id,
        uom_code)
      select
        rh.receipt_source_code,
        x_interface_id,
        p_group_id,
        MO_GLOBAL.get_current_org_id,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.user_id,
        SYSDATE,
        fnd_global.user_id,
        rt.source_document_code,
        rt.destination_type_code,
        p_transaction_date,
        decode(pol.matching_basis,'AMOUNT',null,p_txn_qty),
        nvl(p_txn_uom, rt.unit_of_measure),
        decode(pol.matching_basis,'AMOUNT',p_txn_qty,null),
        rt.shipment_header_id,
        rt.shipment_line_id,
        rt.substitute_unordered_code,
        p_employee_id,
        p_parent_transaction_id,
        rt.inspection_status_code,
        rt.inspection_quality_code,
        rt.po_header_id,
        rt.po_release_id,
        rt.po_line_id,
        rt.po_line_location_id,
        rt.po_distribution_id,
        rt.po_revision_num,
        rt.po_unit_price,
        rt.currency_code,
        rt.currency_conversion_rate,
        rt.currency_conversion_type,
        rt.currency_conversion_date,
        rt.requisition_line_id,
        rt.routing_header_id,
        rt.routing_step_id,
        p_Comments,
        rt.attribute_category,
        rt.attribute1,
        rt.attribute2,
        rt.attribute3,
        rt.attribute4,
        rt.attribute5,
        rt.attribute6,
        rt.attribute7,
        rt.attribute8,
        rt.attribute9,
        rt.attribute10,
        rt.attribute11,
        rt.attribute12,
        rt.attribute13,
        rt.attribute14,
        rt.attribute15,
        p_transaction_type,
        nvl(p_Receiving_Location_Id, rt.location_id),
        'PENDING',
        'ONLINE',
        'PENDING',
        rl.category_id,
        rt.vendor_lot_num,
        nvl(p_Return_Reason_Id, rt.reason_id),
        p_primary_qty,
        p_primary_uom,
        rl.item_id,
        rl.item_revision,
        rl.to_organization_id,
        rt.deliver_to_location_id,
        rt.destination_context,
        rt.vendor_id,
        rt.deliver_to_person_id,
        nvl(p_subinventory, rt.subinventory),
        x_from_subinventory,
        rt.locator_id,
        x_from_locator_id,
        rt.wip_entity_id,
        rt.wip_line_id,
        rt.wip_repetitive_schedule_id,
        rt.wip_operation_seq_num,
        rt.wip_resource_seq_num,
        rt.bom_resource_id,
        rt.organization_id,
        rt.receipt_exception_flag,
        rt.department_code,
        rl.item_description,
        null,
        msi.lot_control_code,
        msi.SERIAL_NUMBER_CONTROL_CODE,
        p_RMA_Reference,
        NULL,
        NULL,
	rt.vendor_site_id,
	x_create_debit_memo_flag,
        rt.job_id,
        pol.matching_basis,
	x_parent_interface_txn_id,
        nvl(x_uom_code,rt.uom_code)

    from rcv_transactions rt,
         rcv_shipment_lines rl,
         rcv_shipment_headers rh,
         mtl_system_items msi,
         po_Lines_all pol
   where transaction_id = p_parent_transaction_id
     and rt.shipment_line_id = rl.shipment_line_id
     and rl.shipment_header_id = rh.shipment_header_id
     and MSI.INVENTORY_ITEM_ID(+) = RL.ITEM_ID
     and NVL(MSI.ORGANIZATION_ID, RT.ORGANIZATION_ID) = RT.ORGANIZATION_ID
     and pol.po_line_id(+) = rt.po_line_id;

   x_parent_interface_txn_id := x_interface_id;

end insert_row;

function get_rtv_id(p_transaction_id     in number) return number is

  x_deliver_id   number;
  x_receive_id   number;
  x_rtv_id       number;

begin

  -- Get the receive and deliver txn first

  select rt2.transaction_id,
         rt2.parent_transaction_id
    into x_deliver_id,
         x_receive_id
    from rcv_transactions rt1,
         rcv_transactions rt2
   where rt1.parent_transaction_id = rt2.transaction_id
     and rt1.transaction_id = p_transaction_id;

  -- Get the RTV transaction

  select min(transaction_id)
    into x_rtv_id
    from rcv_transactions
   where parent_transaction_id = x_receive_id
     and transaction_type = 'RETURN TO VENDOR'
     and get_net_returned_qty(transaction_id) = get_net_returned_qty(p_transaction_id);


  return x_rtv_id;

end get_rtv_id;

function GET_SHIPMENT_NUM(p_order_type_code in varchar2,
                          p_key_id in number)

return varchar2 is

   CURSOR c_req_shipment (c_req_line_id NUMBER) IS
     SELECT
       rsh.shipment_num, rsh.shipment_header_id
     FROM
       rcv_shipment_headers rsh,
       rcv_shipment_lines rsl
     WHERE
       rsh.shipment_header_id = rsl.shipment_header_id and
       rsl.requisition_line_id = c_req_line_id;

   CURSOR c_po_shipment (c_line_location_id NUMBER) IS
     SELECT
       rsh.shipment_num, rsh.shipment_header_id
     FROM
       rcv_shipment_headers rsh,
       rcv_shipment_lines rsl
     WHERE
       rsh.shipment_header_id = rsl.shipment_header_id and
       rsl.po_line_location_id = c_line_location_id and
       rsh.asn_type is not null;

  x_shipment_num varchar2(30);
  x_counter number;
  x_shipment_header_id number;
  x_old_shipment_header_id number;

begin
  x_counter :=0;
  x_old_shipment_header_id := 0;
  x_shipment_header_id := 0;

  if (p_order_type_code = 'REQ') then
       OPEN c_req_shipment(p_key_id);

       LOOP
         FETCH c_req_shipment INTO x_shipment_num, x_shipment_header_id;
         EXIT WHEN c_req_shipment %NOTFOUND;
         if(x_counter = 0) then
           x_old_shipment_header_id := x_shipment_header_id;
           x_counter := x_counter + 1;
         elsif (x_old_shipment_header_id <> x_shipment_header_id) then
           x_shipment_num := fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE');
           exit;
         end if;

       END LOOP;

       close c_req_shipment;
   else
       OPEN c_po_shipment(p_key_id);

       LOOP
         FETCH c_po_shipment INTO x_shipment_num, x_shipment_header_id;
         EXIT WHEN c_po_shipment %NOTFOUND;
         if(x_counter = 0) then
           x_old_shipment_header_id := x_shipment_header_id;
           x_counter := x_counter + 1;
         elsif (x_old_shipment_header_id <> x_shipment_header_id) then
           x_shipment_num := fnd_message.get_string('ICX', 'ICX_POR_MULTIPLE');
           exit;
         end if;

       END LOOP;

       close c_po_shipment;
   end if;
   return x_shipment_num;
end GET_SHIPMENT_NUM;


/*===========================================================================

  PROCEDURE NAME:       Insert_Interface_Errors

===========================================================================*/

/*
**   Insert into PO_INTERFACE_ERRORS table
*/


PROCEDURE  insert_interface_errors ( rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
                                     X_column_name IN VARCHAR2,
                                     X_err_message IN VARCHAR2) as

X_progress VARCHAR2(3) := '000';

begin

  X_progress := '050';

  INSERT INTO po_interface_errors (interface_type,
                                   interface_transaction_id,
                                   column_name,
                                   error_message_name,
                                   batch_id,
                                   creation_date,
                                   created_by,
                                   last_update_date,
                                   last_updated_by,
                                   last_update_login,
                                   request_id,
                                   program_application_id,
                                   program_id,
                                   program_update_date)
                          VALUES (  rcv_trx.transaction_type,
                                    rcv_trx.interface_transaction_id,
                                    X_column_name,
                                    X_err_message,
                                    rcv_trx.group_id,
                                    rcv_trx.creation_date,
                                    rcv_trx.created_by,
                                    rcv_trx.last_update_date,
                                    rcv_trx.last_updated_by,
                                    rcv_trx.last_update_login,
                                    rcv_trx.request_id,
                                    rcv_trx.program_application_id,
                                    rcv_trx.program_id,
                                    rcv_trx.program_update_date);

  commit;

exception
    when others then
       po_message_s.sql_error('insert_interface_errors', x_progress, sqlcode);
       raise;

end insert_interface_errors;


end POR_RCV_TRANSACTION_SV;

/
