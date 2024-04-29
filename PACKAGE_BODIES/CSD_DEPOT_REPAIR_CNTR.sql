--------------------------------------------------------
--  DDL for Package Body CSD_DEPOT_REPAIR_CNTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DEPOT_REPAIR_CNTR" as
/* $Header: csddrclb.pls 115.36 2003/05/01 23:00:05 sangigup ship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'CSD_DEPOT_REPAIR_CNTR';
G_FILE_NAME CONSTANT VARCHAR2(30) := 'csddrclb.pls';
g_debug NUMBER := csd_gen_utility_pvt.g_debug_level;
-------------------------------------------
-- Get txn billing type
-------------------------------------------
PROCEDURE get_txn_billing_type
          (p_line_id   IN NUMBER,
           p_header_id IN NUMBER,
           x_repair_number  OUT NOCOPY VARCHAR2,
           x_repair_line_id OUT NOCOPY NUMBER,
           x_txn_billing_type_id OUT NOCOPY NUMBER,
           x_quantity            OUT NOCOPY NUMBER
           ) IS

  l_quit_flag BOOLEAN := FALSE;
  l_line_id   NUMBER  := p_line_id;
  l_header_id NUMBER  := p_header_id;

BEGIN

  WHILE NOT(l_quit_flag) LOOP

   BEGIN
    SELECT a.txn_billing_type_id,
           b.repair_number,
           b.repair_line_id,
           b.quantity
    INTO   x_txn_billing_type_id,
           x_repair_number ,
           x_repair_line_id,
           x_quantity
    FROM  cs_estimate_details a,
          csd_repairs b
    WHERE ((a.original_source_id = b.repair_line_id
            AND  a.original_source_code = 'DR') OR
           (a.source_id = b.repair_line_id
            AND a.source_code = 'DR'))
     AND  a.order_header_id    = l_header_id
     AND  a.order_line_id      = l_line_id;
      l_quit_flag := TRUE;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
         SELECT
           split_from_line_id
         INTO l_line_id
         FROM oe_order_lines_all
         WHERE line_id  = l_line_id
         AND  header_id = l_header_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_txn_billing_type_id := -1;
             x_repair_number  := '';
             x_repair_line_id := -1;
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('Could not find the split_from_line_id for line_id ='||TO_CHAR(p_line_id));
END IF;

            l_quit_flag := TRUE;
      END;

    WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('Found more than one row in cs_estimate_details for line_id ='||TO_CHAR(p_line_id));
END IF;

        l_quit_flag := TRUE;
   END;
 END LOOP; -- end of while loop

END;
-----------------------------------
-- Convert to primary uom
-----------------------------------
procedure convert_to_primary_uom
          (p_item_id  in number,
           p_organization_id in number,
           p_from_uom in varchar2,
           p_from_quantity in number,
           p_result_quantity OUT NOCOPY number)
is

v_primary_uom_code varchar2(30);
p_from_uom_code varchar2(3);

Begin

    Begin
    select uom_code
    into p_from_uom_code
    from mtl_units_of_measure
    where unit_of_measure = p_from_uom;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('no_data_found error for unit_of_measure ='||p_from_uom);
END IF;

     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('More than one row found for unit_of_measure ='||p_from_uom);
END IF;

    End;

    Begin
    select primary_uom_code
    into v_primary_uom_code
    from mtl_system_items
    where organization_id   = p_organization_id
    and   inventory_item_id = p_item_id;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('no_data_found error(primary UOM) for inventory_item_id ='||TO_CHAR(p_item_id));
END IF;

     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('More than one row found(Primary UOM) for inventory_item_id ='||TO_CHAR(p_item_id));
END IF;

    End;

    BEGIN
       p_result_quantity :=inv_convert.inv_um_convert(
                         p_item_id ,2,
                         p_from_quantity,p_from_uom_code,v_primary_uom_code,null,null);
    EXCEPTION
     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('inv_convert returned with error message');
END IF;

    END;

End;

------------------------------------
--  Depot RMA Receipts
------------------------------------

procedure  depot_rma_receipts
             (errbuf              OUT NOCOPY    varchar2,
              retcode             OUT NOCOPY    number,
              p_repair_line_id    in     number)

is
  v_total_records number;
  /**** Added Organization name in Select columns to fix bug 2760279
  ****  Added hr_organization_units in from clause
  ****  Added one joing with hr_organization_units ******************/

  Cursor RMA_RECEIPT_LINES( p_repair_line_id number ) is
  SELECT /*+ CHOOSE */ oeh.order_number rma_number,
       oeh.header_id rma_header_id,
       oel.line_id ,
       oel.split_from_line_id,
       oel.line_number rma_line_number,
       oel.inventory_item_id,
       rcvt.organization_id,
       rcvt.unit_of_measure,
       oel.line_type_id,
       rcvt.quantity received_quantity,
       rcvt.subinventory received_subinventory,
       rcvt.transaction_date received_date,
       rcvt.transaction_id,
       rcvt.last_updated_by who_col,
       rcvt.subinventory,
	  hou.name organization_name
  FROM rcv_transactions rcvt,
       oe_order_headers_all oeh,
       oe_order_lines_all oel,
	  hr_organization_units hou
  WHERE oel.header_id = oeh.header_id
  AND rcvt.oe_order_line_id = oel.line_id
  AND rcvt.transaction_type = 'RECEIVE'
  AND rcvt.source_document_code = 'RMA'
  And rcvt.organization_id = hou.organization_id
  AND rcvt.transaction_id NOT IN
       (SELECT paramn1
         FROM csd_Repair_history crh,
              csd_repairs cra
         WHERE crh.repair_line_id = cra.repair_line_id
          AND event_code='RR'
          AND cra.repair_line_id = nvl(p_repair_line_id,cra.repair_line_id)) -- travi 020903 change
  AND EXISTS (SELECT ced.order_header_id
               FROM csd_repairs cra,
                    cs_estimate_details ced
               WHERE ((cra.repair_line_id = ced.original_source_id
                      AND ced.original_source_code = 'DR') OR
                     (cra.repair_line_id = ced.source_id
                      AND ced.source_code = 'DR'))
             AND oeh.header_id = ced.order_header_id
                AND cra.repair_line_id = nvl(p_repair_line_id,cra.repair_line_id));  -- travi 020903 change

  v_repair_history_id number;

  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  p_rep_hist_id number;
  p_result_quantity number;
  v_skip_record boolean;
  v_depot_Repair_flag varchar2(1);
  v_transaction_type_id number;
  l_repair_number       VARCHAR2(30);
  l_repair_line_id      NUMBER;
  l_txn_billing_type_id NUMBER;
  l_quantity            NUMBER;

-- travi 012502
  Cursor c_prd_txn_serial_num ( p_rep_line_id number ) is
  select cpt.serial_number pt_sl_number
         , dra.serial_number dr_sl_number
         , cpt.inventory_item_id pt_item_id
         , dra.inventory_item_id dr_item_id
  from csd_product_txns_v cpt
       , csd_repairs dra
  where action_type = 'RMA'
  and dra.repair_line_id = p_rep_line_id
  and cpt.repair_line_id = dra.repair_line_id
  and nvl(cpt.serial_number_control_code,1) > 1;

  Cursor c_rcv_slnum_txn ( p_txn_id number ) is
  select transaction_id
  from rcv_transactions
  where parent_transaction_id = p_txn_id;

  Cursor c_rcv_txn_serial_num ( p_txn_id number ) is
  select serial_num
  from rcv_serial_transactions
  where transaction_id = p_txn_id;

  Cursor c_prod_txn_stat_upd ( p_rep_line_id number) is
  Select product_transaction_id
  from csd_product_txns_v
  where repair_line_id = p_rep_line_id
  and action_type in ( 'RMA','WALK_IN_RECEIPT')
  and repair_quantity = quantity_rcvd;

  l_pt_serial_num varchar2(30);
  l_st_serial_num varchar2(30);
  l_dr_serial_num varchar2(30);
  l_pt_item_id    number;
  l_dr_item_id    number;
  l_sl_txn_id     number;
  l_prod_txn_stat varchar2(30) := 'RECEIVED';

Begin

  v_total_records := 0;
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('At the Begin of Depot RMA receipt update');
END IF;


  For I in rma_receipt_lines( p_repair_line_id )
  loop

     v_skip_record := false;
     v_transaction_type_id  := null;
     v_depot_Repair_flag := null;
     l_repair_number  := '';
     l_repair_line_id := NULL ;
     l_txn_billing_type_id := NULL;

	IF (g_debug > 0 ) THEN
	     csd_gen_utility_pvt.add('----------------------------------------------' );
	     csd_gen_utility_pvt.add('Rma Number ='||I.rma_number );
	END IF;
     -- travi comment to concurrent log
     fnd_file.put_line(fnd_file.log, 'Selecting RMA Number : '||I.rma_number );

	IF (g_debug > 0 ) THEN
	     csd_gen_utility_pvt.add('Rma Header Id ='||TO_CHAR(I.rma_header_id) );
	     csd_gen_utility_pvt.add('Rma Line Id ='||TO_CHAR(I.Line_id ));
	     csd_gen_utility_pvt.add('Split from Line Id ='||TO_CHAR(I.split_from_line_id));
	END IF;


     get_txn_billing_type
        (p_line_id     => i.line_id,
         p_header_id   => i.rma_header_id,
         x_repair_number       => l_repair_number,
         x_repair_line_id      => l_repair_line_id,
         x_txn_billing_type_id => l_txn_billing_type_id,
         x_quantity            => l_quantity);

		IF (g_debug > 0 ) THEN
		     csd_gen_utility_pvt.add('l_txn_billing_type_id='||TO_CHAR(l_txn_billing_type_id));
		     csd_gen_utility_pvt.add('l_repair_number='||l_repair_number);
		     csd_gen_utility_pvt.add('l_repair_line_id='||TO_CHAR(l_repair_line_id));
		END IF;



     Begin
       Select transaction_type_id
       into v_transaction_type_id
       from cs_txn_billing_types
       where txn_billing_type_id = l_txn_billing_type_id;
     Exception
     When no_data_found then
       v_transaction_type_id := null;
       v_skip_record := true;
		IF (g_debug > 0 ) THEN
		       csd_gen_utility_pvt.add('No Row found for the txn_billing_type_id='||TO_CHAR(l_txn_billing_type_id));
		END IF;

     when others then
		IF (g_debug > 0 ) THEN
		       csd_gen_utility_pvt.add('When others exception at - Transaction type id');
		END IF;

     End;

     if v_transaction_type_id is not null then
       Begin
         Select depot_Repair_flag
         into v_depot_repair_flag
         from cs_transaction_types_b
         where transaction_type_id = v_transaction_type_id;

        Exception
         when no_Data_found then
           V_skip_record := true;
			IF (g_debug > 0 ) THEN
			       csd_gen_utility_pvt.add('No row found for the transaction_type_id ='||TO_CHAR(v_transaction_type_id));
			END IF;

         End;
       End if;


       if v_depot_repair_flag = 'Y' then
          v_skip_record := false;
       else
          v_skip_record := true;
       End if;


     if not v_skip_record then

       BEGIN

		IF (g_debug > 0 ) THEN
		         csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - prd_txn_serial_num : repair_line_id '||to_char(l_repair_line_id));
		END IF;


         if (l_quantity = 1) then
			IF (g_debug > 0 ) THEN
			           csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - prd_txn_serial_num : qty '||to_char(l_quantity));
			END IF;


           open c_prd_txn_serial_num ( l_repair_line_id );

           fetch c_prd_txn_serial_num into l_pt_serial_num, l_dr_serial_num, l_pt_item_id, l_dr_item_id;

             if (c_prd_txn_serial_num%FOUND) then

				IF (g_debug > 0 ) THEN
	               csd_gen_utility_pvt.add('pt_serial_num '||l_dr_serial_num);
	               csd_gen_utility_pvt.add('pt_Item_id '||to_char(l_dr_item_id));
	               csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - prd_txn_serial_num : pt_serial_num '||l_pt_serial_num||' dr_serial_num '||l_dr_serial_num);
	               csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - prd_txn_item_id : pt_item_id '||to_char(l_pt_item_id)||' dr_item_id '||to_char(l_dr_item_id));
				END IF;


               if (l_pt_item_id <> l_dr_item_id) then

					IF (g_debug > 0 ) THEN
		                 csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - l_pt_item_id <> l_dr_item_id ');
					END IF;

		             l_pt_serial_num := l_dr_serial_num;

               end if;

				IF (g_debug > 0 ) THEN
	               csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - transaction_id '||to_char(i.transaction_id));
				END IF;


               open c_rcv_slnum_txn  ( i.transaction_id );

               fetch c_rcv_slnum_txn into l_sl_txn_id;

				IF (g_debug > 0 ) THEN
	               csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - parent_transaction_id '||to_char(l_sl_txn_id));
				END IF;


               if (l_sl_txn_id is not null) then
                  open c_rcv_txn_serial_num ( l_sl_txn_id );

                  fetch c_rcv_txn_serial_num into l_st_serial_num;

                  if (c_rcv_txn_serial_num%FOUND) then
						IF (g_debug > 0 ) THEN
							csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - rcv_txn_serial_num'||l_st_serial_num);
						END IF;


						IF (g_debug > 0 ) THEN
						    csd_gen_utility_pvt.add('l_st_serial_num '||l_st_serial_num);
						    csd_gen_utility_pvt.add('l_pt_serial_num '||l_pt_serial_num);
						END IF;



                     if(l_pt_serial_num <> l_st_serial_num) then
						IF (g_debug > 0 ) THEN
							csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - l_pt_serial_num <> l_st_serial_num ');
							csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for RSC event');
							csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write ');
						END IF;


                       CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
                       P_Api_Version_Number          => 1.0,
                       P_Init_Msg_List               => 'F',
                       P_Commit                      => 'F',
                       p_validation_level            => null,
                       p_action_code                 => 0  ,
                       px_REPAIR_HISTORY_ID          => p_rep_hist_id,
                       p_OBJECT_VERSION_NUMBER       => null,                     -- travi ovn validation
                       p_REQUEST_ID                  => null,
                       p_PROGRAM_ID                  => null,
                       p_PROGRAM_APPLICATION_ID      => null,
                       p_PROGRAM_UPDATE_DATE         => null,
                       p_CREATED_BY                  => -1,
                       p_CREATION_DATE               => sysdate,
                       p_LAST_UPDATED_BY             =>  -1,
                       p_LAST_UPDATE_DATE            => sysdate,
                       p_REPAIR_LINE_ID              => l_repair_line_id,
                       p_EVENT_CODE                  => 'RSC',                     -- RMA serial number changed
                       p_EVENT_DATE                  => I.received_date,
                       p_QUANTITY                    => I.received_quantity,
                       p_PARAMN1                     => i.transaction_id,
                       p_PARAMN2                     => i.rma_line_number,
                       p_PARAMN3                     => i.line_type_id,
                       p_PARAMN4                     => l_txn_billing_type_id,
                       p_PARAMN5                     => i.who_col,
                       p_PARAMN6                     => i.rma_header_id,
                       p_PARAMN7                     => null,
                       p_PARAMN8                     => null,
                       p_PARAMN9                     => null,
                       p_PARAMN10                    => null,
                       p_PARAMC1                     => i.subinventory,
                       p_PARAMC2                     => i.rma_number,
                       p_PARAMC3                     => l_pt_serial_num,             -- prd txn ser num
                       p_PARAMC4                     => l_st_serial_num,             -- rcv ser txn ser num
                       p_PARAMC5                     => null,
                       p_PARAMC6                     => null,
                       p_PARAMC7                     => null,
                       p_PARAMC8                     => null,
                       p_PARAMC9                     => null,
                       p_PARAMC10                    => null,
                       p_PARAMD1                     => null,
                       p_PARAMD2                     => null,
                       p_PARAMD3                     => null,
                       p_PARAMD4                     => null,
                       p_PARAMD5                     => null,
                       p_PARAMD6                     => null,
                       p_PARAMD7                     => null,
                       p_PARAMD8                     => null,
                       p_PARAMD9                     => null,
                       p_PARAMD10                    => null,
                       p_ATTRIBUTE_CATEGORY          => null,
                       p_ATTRIBUTE1                  => null,
                       p_ATTRIBUTE2                  => null,
                       p_ATTRIBUTE3                  => null,
                       p_ATTRIBUTE4                  => null,
                       p_ATTRIBUTE5                  => null,
                       p_ATTRIBUTE6                  => null,
                       p_ATTRIBUTE7                  => null,
                       p_ATTRIBUTE8                  => null,
                       p_ATTRIBUTE9                  => null,
                       p_ATTRIBUTE10                 => null,
                       p_ATTRIBUTE11                 => null,
                       p_ATTRIBUTE12                 =>null,
                       p_ATTRIBUTE13                 => null,
                       p_ATTRIBUTE14                 => null,
                       p_ATTRIBUTE15                 => null,
                       p_LAST_UPDATE_LOGIN           => null,
                       X_Return_Status               => l_return_status,
                       X_Msg_Count                   => l_msg_count,
                       X_Msg_Data                    => l_msg_data
                       );

						IF (g_debug > 0 ) THEN
						    csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
						END IF;

                       v_total_records := v_total_records + 1;

						IF (g_debug > 0 ) THEN
						    csd_gen_utility_pvt.add('Successfully updated the history');
						END IF;

					     -- travi comment to concurrent log
					     fnd_file.put_line(fnd_file.log, 'Successfully updated the history');

						IF (g_debug > 0 ) THEN
						   csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS - Repair Line ID : '||to_char(l_repair_line_id));
						   csd_gen_utility_pvt.add('Inserted into Repairs History Table for Serial number Change');
						   csd_gen_utility_pvt.add('Product Txn Serial number : '||l_pt_serial_num||' Recv Ser Txn Serial number : '||l_st_serial_num);
						END IF;


                    end if;

                  end if;

               end if; -- l_sl_txn_id is not null

             end if;

         end if;

     Exception
     When no_data_found then
		IF (g_debug > 0 ) THEN
		    csd_gen_utility_pvt.add('No data found exception,in check for serial number change');
		END IF;

     When others then
		IF (g_debug > 0 ) THEN
		   csd_gen_utility_pvt.add('When others exception,in check for serial number change');
		END IF;

     END;

     End if;

-- travi 012502

     if not v_skip_record then

       csd_depot_repair_cntr.convert_to_primary_uom
         (i.inventory_item_id,
         i.organization_id,
         i.unit_of_measure,
         i.received_quantity,
         p_result_quantity);

		IF (g_debug > 0 ) THEN
		   csd_gen_utility_pvt.add('p_result_quantity='|| TO_CHAR(p_result_quantity));
		END IF;


         update csd_repairs
         set quantity_rcvd = nvl(quantity_rcvd,0)+nvl(p_result_quantity,0)
         where repair_line_id = l_repair_line_id;

         For P in c_prod_txn_stat_upd ( l_repair_line_id )
         Loop

           Update csd_product_transactions
           set prod_txn_status = l_prod_txn_stat
           where product_transaction_id = P.product_transaction_id;

         End Loop;

         fnd_message.set_name('CSD','CSD_DRC_RMA_RECEIPT');
         fnd_message.set_token('RMA_NO',i.rma_number);
         fnd_message.set_token('REP_NO',l_repair_number);
         fnd_message.set_token('QTY_RCVD',to_char(i.received_quantity));
			IF (g_debug > 0 ) THEN
			      csd_gen_utility_pvt.add(fnd_message.get);
			END IF;


IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for RR event');
END IF;


IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write ');
END IF;


         CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
            P_Api_Version_Number       => 1.0,
            P_Init_Msg_List            => 'F',
            P_Commit                   => 'F',
            p_validation_level         => null,
            p_action_code              => 0  ,
            px_REPAIR_HISTORY_ID       => p_rep_hist_id,
            p_OBJECT_VERSION_NUMBER    => null,                     -- travi ovn validation
            p_REQUEST_ID               => null,
            p_PROGRAM_ID               => null,
            p_PROGRAM_APPLICATION_ID   => null,
            p_PROGRAM_UPDATE_DATE      => null,
            p_CREATED_BY       => -1,
            p_CREATION_DATE    => sysdate,
            p_LAST_UPDATED_BY  =>  -1,
            p_LAST_UPDATE_DATE => sysdate,
            p_REPAIR_LINE_ID   => l_repair_line_id,
            p_EVENT_CODE       => 'RR',
            p_EVENT_DATE       => I.received_date,
            p_QUANTITY         => I.received_quantity,
            p_PARAMN1          => i.transaction_id,
            p_PARAMN2    =>    i.rma_line_number,
            p_PARAMN3    => i.line_type_id,
            p_PARAMN4    => l_txn_billing_type_id,
            p_PARAMN5    => i.who_col,
            p_PARAMN6    => i.rma_header_id,
            p_PARAMN7    => null,
            p_PARAMN8    => null,
            p_PARAMN9    => null,
            p_PARAMN10   => null,
            p_PARAMC1    => i.subinventory,
            p_PARAMC2    => i.rma_number,
            p_PARAMC3    => i.Organization_Name, -- Bug No 2760279
            p_PARAMC4    => null,
            p_PARAMC5    => null,
            p_PARAMC6    => null,
            p_PARAMC7    => null,
            p_PARAMC8    => null,
            p_PARAMC9    => null,
            p_PARAMC10   => null,
            p_PARAMD1    => null,
            p_PARAMD2    => null,
            p_PARAMD3    => null,
            p_PARAMD4    => null,
            p_PARAMD5    => null,
            p_PARAMD6    => null,
            p_PARAMD7    => null,
            p_PARAMD8    => null,
            p_PARAMD9    => null,
            p_PARAMD10   => null,
            p_ATTRIBUTE_CATEGORY => null,
            p_ATTRIBUTE1         => null,
            p_ATTRIBUTE2         => null,
            p_ATTRIBUTE3         => null,
            p_ATTRIBUTE4         => null,
            p_ATTRIBUTE5         => null,
            p_ATTRIBUTE6         => null,
            p_ATTRIBUTE7         => null,
            p_ATTRIBUTE8         => null,
            p_ATTRIBUTE9         => null,
            p_ATTRIBUTE10        => null,
            p_ATTRIBUTE11        => null,
            p_ATTRIBUTE12        => null,
            p_ATTRIBUTE13        => null,
            p_ATTRIBUTE14        => null,
            p_ATTRIBUTE15        => null,
            p_LAST_UPDATE_LOGIN  => null,
            X_Return_Status      => l_return_status  ,
            X_Msg_Count          => l_msg_count,
            X_Msg_Data           => l_msg_data
           );


IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
END IF;


IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Successfully completed Depot RMA receipt update ');
END IF;

     -- travi comment to concurrent log
     fnd_file.put_line(fnd_file.log, 'Successfully completed Depot RMA receipt update');

          commit;

          v_total_records := v_total_records + 1;

      End if;

End loop;

  fnd_message.set_name('CSD','CSD_DRC_WIP_TOT_REC_PROC');
  fnd_message.set_token('TOT_REC',to_char(v_total_records));
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add(fnd_message.get);
END IF;


  -- travi check for call from tools
  if ( p_repair_line_id is not null ) then
IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_RMA_RECEIPTS : Call from Depot Repair Form Tools Menu');
END IF;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('Repair Line ID ='||to_char(p_repair_line_id));
END IF;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('Total Records inserted into Repairs History Table ='||to_char(v_total_records));
END IF;

  end if;

End;

-------------------------------------------
-- Get WIP Job Completed Quantity
-------------------------------------------

procedure get_wip_job_completed_quantity(p_wip_entity_id in number,
                                         x_wip_completed_qty OUT NOCOPY number,
                                        x_COMPLETION_SUBINVENTORY OUT NOCOPY varchar2,
                                         x_DATE_COMPLETED OUT NOCOPY date,
                                      x_ORGANIZATION_ID OUT NOCOPY number,
                                       x_routing_reference_id OUT NOCOPY number,
                                       x_LAST_UPDATED_BY OUT NOCOPY number)

is

v_quantity_completed number;
p_old_complete number;
v_wip_entity_id number;


Begin

  Begin
  Select  WIP_ENTITY_ID,
      QUANTITY_COMPLETED,
          COMPLETION_SUBINVENTORY,
          DATE_COMPLETED,
      ORGANIZATION_ID,
      routing_reference_id,
      LAST_UPDATED_BY
  into    v_wip_entity_id,
          x_wip_completed_qty,
          x_COMPLETION_SUBINVENTORY,
          x_DATE_COMPLETED,
      x_ORGANIZATION_ID,
      x_routing_reference_id,
      x_LAST_UPDATED_BY
  from   WIP_DISCRETE_JOBS
  where WIP_ENTITY_ID=p_WIP_ENTITY_ID;
  Exception
  When no_data_found then
IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('No WIP Job found for the wip_entity_id '||TO_CHAR(p_WIP_ENTITY_ID));
END IF;

  when others then
IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('when other exception at - get_wip_job_completed_quantity');
END IF;

  End;


 End;



--------------------------------------
-- Depot WIP Update
--------------------------------------
procedure  depot_wip_update
              (errbuf             OUT NOCOPY    varchar2,
               retcode            OUT NOCOPY    varchar2,
           p_repair_line_id   in     number)
is
  v_total_rec number;
  p_rep_hist_id number;
  v_remaining_qty number;
  v_transaction_quantity number;
  v_old_wip_entity_id number;
  v_wip_entity_name varchar2(100);

  v_wei     number;        -- travi new
  v_wen     varchar2(100); -- travi new

  p_wip_entity_id number;
  x_wip_completed_qty number;
  x_COMPLETION_SUBINVENTORY varchar2(30);
  x_DATE_COMPLETED date;
  x_ORGANIZATION_ID number;
  x_routing_reference_id number;
  x_LAST_UPDATED_BY number;

  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  v_new_completion_quantity number;
  SumOfROCompQty number;
    v_completed_qty number;

  -- travi change get the group_id
  Cursor REPAIR_JOBS( p_repair_line_id number )
  is
    SELECT CRJ.REPAIR_JOB_XREF_ID,
      CRJ.WIP_ENTITY_ID,
      CRJ.GROUP_ID,
      CRJ.REPAIR_LINE_ID,
      csr.repair_number,
      crj.quantity_completed,
      crj.quantity,
      csr.promise_date,
      crj.organization_id
    from CSD_REPAIR_JOB_XREF CRJ
    ,CSD_REPAIRS csr
    where
    csr.repair_line_id = crj.repair_line_id
    and
    nvl(crj.quantity_completed,0) < crj.quantity
    and csr.repair_line_id = nvl(p_repair_line_id, csr.repair_line_id) -- travi 121801 change
    order by crj.wip_entity_id, csr.promise_date;
    --,csr.promise_date; -- travi change
      -- travi change for update;
      -- if you do for update then your update should be where current of cursor

   Begin

      v_total_rec := 0;
      v_old_wip_entity_id := -1000;

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('At the begin of Depot Repair WIP Job update');
END IF;


      -- travi code to update wip_entity_id for the repair_job_xref
      For K in Repair_Jobs( p_repair_line_id )
        loop

        if(K.WIP_ENTITY_ID = K.GROUP_ID) then

         v_wen := 'CSD'||K.GROUP_ID;

         Begin
           Select wip_entity_id
             into v_wei
            from wip_entities
           where wip_entity_name = v_wen
           and wip_entities.organization_id = K.organization_id;---- 0430 bug number- sangita to fix duplicate wip name problem.
         Exception
           When no_data_found then
		 v_wei := NULL;
IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.add('Invalid WIP_ENTITY_NAME : '||v_wen);
END IF;

           when others then
IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.add('Others exception WIP_ENTITY_NAME : '||v_wen);
END IF;

         End;

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Updating csd_repair_job_xref for wip_entity_name : '||v_wen);
END IF;

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('wip_entity_id  ='||TO_CHAR(K.wip_entity_id));
END IF;

         -- Updating Null Value for v_wei when WIP Mass load program is not completed
	    -- so should not update when v_wei is null bug# 2770713 saupadhy
         Begin
            update csd_repair_job_xref
               set wip_entity_id      = v_wei
             where repair_line_id     = K.repair_line_id
               and repair_job_xref_id = K.repair_job_xref_id
			and v_wei is not null;
         Exception
           when others then
            null;
         End;

     end if;

      end loop;
      -- end of travi code

      For I in Repair_Jobs( p_repair_line_id )
        loop

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('-------------------------------------------');
	  csd_gen_utility_pvt.add('wip_entity_id  ='||TO_CHAR(i.wip_entity_id));
	  csd_gen_utility_pvt.add('repair_line_id ='||TO_CHAR(i.repair_line_id));
	  csd_gen_utility_pvt.add('quantity_completed ='||TO_CHAR(i.quantity_completed));
	  csd_gen_utility_pvt.add('quantity ='||TO_CHAR(i.quantity));
    END IF;

          if i.wip_entity_id <> v_old_wip_entity_id then
        -- get wip_comp_qty for the wip_entity_id
             get_wip_job_completed_quantity(i.wip_entity_id,x_wip_completed_qty,x_completion_subinventory,
                                        x_date_completed,x_organization_id,x_routing_reference_id,x_last_updated_by);


        IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('x_wip_completed_qty  ='||TO_CHAR(x_wip_completed_qty));
        END IF;

		 -- get SIGMA ro_completed_qty
           Select nvl(sum(quantity_completed),0) into SumOfROCompQty from csd_repair_job_xref  where wip_entity_id = i.wip_entity_id;

           v_transaction_quantity := nvl(x_wip_completed_qty,0) - nvl(SumOfROCompQty,0);
           if (v_transaction_quantity + nvl(i.quantity_completed,0)) > nvl(i.quantity,0) then
            v_transaction_quantity := nvl(i.quantity,0) - nvl(i.quantity_completed,0);
            end if;
             IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add(' i.quantity_complted  ='||TO_CHAR( i.quantity_completed));
            END IF;
            IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add(' v_transaction_quantity  ='||TO_CHAR( v_transaction_quantity));
            END IF;
            v_completed_qty := nvl(i.quantity_completed,0) + v_transaction_quantity;
            if (v_completed_qty > i.quantity) then
                v_completed_qty := i.quantity;
                END if;

        Begin
          Select wip_entity_name
              into v_wip_entity_name
              from wip_entities
              where wip_entity_id = i.wip_entity_id;
            Exception
                 When no_data_found then
                    fnd_message.set_name('CSD','CSD_INVALID_WIP_ENTITY');
                    fnd_message.set_token('REP_NO',i.repair_number);
                    fnd_message.set_token('WIP_JOB_ID',i.wip_entity_id);
                    if (g_debug > 0) then
                        csd_gen_utility_pvt.add(fnd_message.get);
                     end if;
                    v_completed_qty := 0;
                    when others then
                         if (g_debug > 0) then
                         csd_gen_utility_pvt.add('When others exception at - Wip entity name');
                        end if;
                     End;
                 end if;
/*
-- get SIGMA ro_completed_qty
 Select nvl(sum(quantity_completed),0) into SumOfROCompQty from csd_repair_job_xref  where wip_entity_id = i.wip_entity_id;

	  v_transaction_quantity := nvl(x_wip_completed_qty,0) - nvl(SumOfROCompQty,0);
	   if (v_transaction_quantity + nvl(i.quantity_completed,0)) > nvl(i.quantity,0) then
     	   v_transaction_quantity := nvl(i.quantity,0) - nvl(i.quantity_completed,0);
																    end if;
																	IF (g_debug > 0 ) THEN
																	csd_gen_utility_pvt.add(' i.quantity_complted  ='||TO_CHAR( i.quantity_completed));

  																 END IF;
																  IF (g_debug > 0 ) THEN
	  csd_gen_utility_pvt.add(' v_transaction_quantity  ='||TO_CHAR( v_transaction_quantity));
																																   END IF;
																    v_completed_qty := nvl(i.quantity_completed,0) + v_transaction_quantity;
																																	if (v_completed_qty > i.quantity) then
		v_completed_qty := i.quantity;
     END if;
*/
 if (v_transaction_quantity > 0) then --0430
            update csd_repair_job_xref
            set quantity_completed =v_completed_qty
            where repair_line_id = i.repair_line_id
            and   repair_job_xref_id = i.repair_job_xref_id;

            fnd_message.set_name('CSD','CSD_DRC_WIP_JOB_UPDATE');
            fnd_message.set_token('REP_NO',i.repair_number);
            fnd_message.set_token('WIP_JOB',v_wip_entity_name);
            fnd_message.set_token('QTY_COMPLETE',to_char(v_transaction_quantity));
            IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.add(fnd_message.get);
            END IF;


            v_total_rec := v_total_rec + 1;

            IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write');
            END IF;


            IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_wip_update before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for JC event');
            END IF;


            CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
            P_Api_Version_Number      => 1.0,
            P_Init_Msg_List           => 'F',
            P_Commit                  => 'F',
            p_validation_level        => null,
            p_action_code             => 0  ,
            px_REPAIR_HISTORY_ID      => p_rep_hist_id,
            p_OBJECT_VERSION_NUMBER   => null,                     -- travi ovn validation
            p_REQUEST_ID              => null,
            p_PROGRAM_ID              => null,
            p_PROGRAM_APPLICATION_ID  => null,
            p_PROGRAM_UPDATE_DATE     => null,
            p_CREATED_BY       => -1,
            p_CREATION_DATE    => sysdate,
            p_LAST_UPDATED_BY  =>  -1,
            p_LAST_UPDATE_DATE => sysdate,
            p_REPAIR_LINE_ID   => I.repair_line_id,
            p_EVENT_CODE  => 'JC',
            p_EVENT_DATE  => nvl(x_date_completed,sysdate),
            p_QUANTITY    => v_transaction_quantity,
            p_PARAMN1     => x_organization_id,
            p_PARAMN2     => x_routing_reference_id,
            p_PARAMN3     => null,
            p_PARAMN4     => i.wip_entity_id,
            p_PARAMN5     => null,
            p_PARAMN6     => null,
            p_PARAMN7     => null,
            p_PARAMN8     => null,
            p_PARAMN9     => null,
            p_PARAMN10    => null,
            p_PARAMC1     => x_completion_subinventory,
            p_PARAMC2     => v_wip_entity_name,
            p_PARAMC3     => null,
            p_PARAMC4     => null,
            p_PARAMC5     => null,
            p_PARAMC6     => null,
            p_PARAMC7     => null,
            p_PARAMC8     => null,
            p_PARAMC9     => null,
            p_PARAMC10    => null,
            p_PARAMD1     => x_date_completed,
            p_PARAMD2     => null,
            p_PARAMD3     => null,
            p_PARAMD4     => null,
            p_PARAMD5     => null,
            p_PARAMD6     => null,
            p_PARAMD7     => null,
            p_PARAMD8     => null,
            p_PARAMD9     => null,
            p_PARAMD10    => null,
            p_ATTRIBUTE_CATEGORY  => null,
            p_ATTRIBUTE1    => null,
            p_ATTRIBUTE2    => null,
            p_ATTRIBUTE3    => null,
            p_ATTRIBUTE4    => null,
            p_ATTRIBUTE5    => null,
            p_ATTRIBUTE6    => null,
            p_ATTRIBUTE7    => null,
            p_ATTRIBUTE8    => null,
            p_ATTRIBUTE9    => null,
            p_ATTRIBUTE10   => null,
            p_ATTRIBUTE11   => null,
            p_ATTRIBUTE12   => null,
            p_ATTRIBUTE13   => null,
            p_ATTRIBUTE14   => null,
            p_ATTRIBUTE15   => null,
            p_LAST_UPDATE_LOGIN  => null,
            X_Return_Status      => l_return_status  ,
            X_Msg_Count          => l_msg_count,
            X_Msg_Data           => l_msg_data
            );

            IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_wip_update after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
            END IF;



            IF (g_debug > 0 ) THEN
             csd_gen_utility_pvt.add('Successfully completed Depot Repair WIP Job Update');
            END IF;


       End if;


       v_old_wip_entity_id := i.wip_entity_id;

      End loop;

      commit;

      fnd_message.set_name('CSD','CSD_DRC_WIP_REC_PROC');
      fnd_message.set_token('TOT_REC',to_char(v_total_rec));
        IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add(fnd_message.get);
        END IF;


      if ( p_repair_line_id is not null ) then
        IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_WIP_UPDATE : Call from Depot Repair Form Tools Menu');
        END IF;

        IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('Repair Line ID ='||to_char(p_repair_line_id));
        END IF;

        IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.add('Total Records inserted into Repairs History Table ='||to_char(v_total_rec));
        END IF;

      end if;

End;

---------------------------------------

---------------------------------------
-- Depot Shipment Update
---------------------------------------

procedure  depot_shipment_update
              (errbuf            OUT NOCOPY  varchar2,
               retcode           OUT NOCOPY  varchar2,
           p_repair_line_id  in   number)
is

  v_total_records number;

  Cursor DEPOT_SHIPMENT_LINES ( p_repair_line_id number) is
  select /*+ index(cra CSD_REPAIRS_U1)  */
    dd.serial_number sl_number,     -- travi 012502
    cra.quantity qty,                       -- travi 012502
	dd.lot_number lot_number,                    --vijay 02/03/2003
	dd.revision revision,					  --vijay 02/03/2003
	dd.subinventory subinv,				  --vijay 02/03/2003
    oeh.order_number order_number,
    oeh.header_id sales_order_header,
    oel.line_number order_line_number,
    oel.line_type_id,
    cra.repair_number,
    cra.repair_line_id,
    ced.txn_billing_type_id,
    dd.requested_quantity,
    dd.shipped_quantity,
    dl.initial_pickup_date date_shipped,
    dd.delivery_detail_id,
    dd.requested_quantity_uom shipped_uom_code,
    mtlu.unit_of_measure shipped_uom,
    dd.inventory_item_id ,
    dd.organization_id
  from
    wsh_new_deliveries      dl,
    wsh_delivery_assignments da,
    wsh_delivery_details dd ,
    oe_order_headers_all oeh,
    oe_order_lines_all oel,
    csd_Repairs cra,
    cs_estimate_Details ced,
    mtl_units_of_measure mtlu
  Where ((cra.repair_line_id = ced.original_source_id
        and  ced.original_source_code = 'DR') OR
      (cra.repair_line_id = ced.source_id
       and  ced.source_code = 'DR'))
  and dd.delivery_detail_id   = da.delivery_detail_id
  and da.delivery_id      = dl.delivery_id(+)
  and ced.order_header_id = oeh.header_id
  and ced.order_line_id   = oel.line_id
  and ced.order_header_id = oel.header_id
  and dd.source_header_id = ced.order_header_id
  and dd.source_line_id   = ced.order_line_id
  and dd.released_status  = 'C'                     -- travi 022002
  and dd.delivery_detail_id not in
     (select paramn1
      from csd_Repair_history
      where repair_line_id = cra.repair_line_id
      and event_code='PS')
  and  mtlu.uom_code = dd.requested_quantity_uom
  and  cra.repair_line_id = nvl(p_repair_line_id, cra.repair_line_id);


  v_repair_history_id number;
  l_return_status varchar2(1);
  l_msg_count number;
  l_msg_data varchar2(2000);
  l_rep_hist_id number;
  v_skip_record boolean;
  v_depot_Repair_flag varchar2(1);
  v_transaction_type_id number;
  p_result_ship_quantity number;

  l_pt_serial_num varchar2(30);

  Cursor c_prd_txn_serial_num ( p_rep_line_id number ) is
  select nvl(cpt.serial_number, dra.serial_number) serial_number
  from csd_product_txns_v cpt
    , csd_repairs dra
  where action_type = 'SHIP'
  and dra.repair_line_id = p_rep_line_id
  and cpt.repair_line_id = dra.repair_line_id
  and nvl(cpt.serial_number_control_code,1) > 1;

Begin

   v_total_records := 0;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('At the begin of Depot repair Shipping Update');
END IF;


   For I in depot_shipment_lines(p_repair_line_id)
   loop


	IF (g_debug > 0 ) THEN
	     csd_gen_utility_pvt.add('-------------------------------------------');
	     csd_gen_utility_pvt.add('Order number   ='||TO_CHAR(I.order_number));
	     csd_gen_utility_pvt.add('Repair number  ='||I.repair_number);
	     csd_gen_utility_pvt.add('Txn billing type id ='||TO_CHAR(I.txn_billing_type_id));
	     csd_gen_utility_pvt.add('Shipped quantity ='||TO_CHAR(I.shipped_quantity));
	     csd_gen_utility_pvt.add('Inventory item id ='||TO_CHAR(I.inventory_item_id));
	     csd_gen_utility_pvt.add('Organization id ='||TO_CHAR(I.Organization_id));
	END IF;


     v_skip_record := false;
     v_transaction_type_id  := null;
     v_depot_Repair_flag := null;

      Begin

        Select transaction_type_id
        into v_transaction_type_id
        from cs_txn_billing_types
        where txn_billing_type_id = i.txn_billing_type_id;

      Exception
       When no_data_found then
        v_transaction_type_id := null;
        v_skip_record := true;
		IF (g_debug > 0 ) THEN
		        csd_gen_utility_pvt.add('Transaction type id not found for billing type id ='||TO_CHAR(i.txn_billing_type_id));
		END IF;

      when others then
		IF (g_debug > 0 ) THEN
		        csd_gen_utility_pvt.add('When others exception at - Transaction type id');
		END IF;

      End;


     if v_transaction_type_id is not null then
      Begin
      Select depot_Repair_flag
      into v_depot_repair_flag
      from cs_transaction_types_b
       where transaction_type_id = v_transaction_type_id;
         Exception
      when no_Data_found  then
           V_skip_record := true;
		IF (g_debug > 0 ) THEN
		           csd_gen_utility_pvt.add('Depot repair flag is not Y ');
		END IF;

      when others then
		IF (g_debug > 0 ) THEN
		           csd_gen_utility_pvt.add('When others exception at - depot repair flag');
		END IF;

      End;
     End if;

       if v_depot_repair_flag = 'Y' then
         v_skip_record := false;
       else
         v_skip_record := true;
       End if;

   -- Added jkuruvil to skip,display records with null shipped date
    IF I.date_shipped is null then
      fnd_message.set_name('CSD','CSD_DRC_SHIP_PICKUP_DATE_PROC');
      fnd_message.set_token('ORDER_NO',I.order_number);
      fnd_message.set_token('REP_NO',I.repair_number);
      fnd_message.set_token('QTY_SHIP',to_char(I.shipped_quantity));
      fnd_message.set_token('DT_SHIP',to_char(I.date_shipped));
		IF (g_debug > 0 ) THEN
		      csd_gen_utility_pvt.add(fnd_message.get);
		END IF;

      fnd_message.clear;
      v_skip_record := true;
    End if;

if not v_skip_record then

  BEGIN

  if (i.qty = 1) then

    open c_prd_txn_serial_num ( i.repair_line_id );

    fetch c_prd_txn_serial_num into l_pt_serial_num;

    if (c_prd_txn_serial_num%FOUND) then

      -- check if serial numbers are different
		IF (g_debug > 0 ) THEN
		      csd_gen_utility_pvt.add('Checking whether serial numbers are changed');
		END IF;


      if(l_pt_serial_num <> i.sl_number) then


		IF (g_debug > 0 ) THEN
		        csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_shipment_update before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for SSC event');
		        csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY');
		END IF;


        CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
        P_Api_Version_Number          => 1.0,
        P_Init_Msg_List               => 'F',
        P_Commit                      => 'F',
        p_validation_level            => null,
        p_action_code                 => 0  ,
        px_REPAIR_HISTORY_ID          => l_rep_hist_id,
        p_OBJECT_VERSION_NUMBER       => null,                     -- travi ovn validation
        p_REQUEST_ID                  => null,
        p_PROGRAM_ID                  => null,
        p_PROGRAM_APPLICATION_ID      => null,
        p_PROGRAM_UPDATE_DATE         => null,
        p_CREATED_BY                  => -1,
        p_CREATION_DATE               => sysdate,
        p_LAST_UPDATED_BY             =>  -1,
        p_LAST_UPDATE_DATE            => sysdate,
        p_REPAIR_LINE_ID              => I.repair_line_id,
        p_EVENT_CODE                  => 'SSC',                     -- Ship serial number changed
        p_EVENT_DATE                  => I.date_shipped,
    	p_QUANTITY                    => p_result_ship_quantity,
        p_PARAMN1                     => i.delivery_detail_id,
        p_PARAMN2                     => i.order_line_number,
        p_PARAMN3                     => i.line_type_id,
        p_PARAMN4                     => i.txn_billing_type_id,
        p_PARAMN5                     => null,
        p_PARAMN6                     => null,
        p_PARAMN7                     => null,
        p_PARAMN8                     => null,
        p_PARAMN9                     => null,
        p_PARAMN10                    => null,
        p_PARAMC1                     => null,
        p_PARAMC2                     => i.order_number,
        p_PARAMC3                     => l_pt_serial_num,             -- prd txn ser num
        p_PARAMC4                     => i.sl_number,             -- WDD ship ser num
        p_PARAMC5                     => null,
        p_PARAMC6                     => null,
        p_PARAMC7                     => null,
        p_PARAMC8                     => null,
        p_PARAMC9                     => null,
        p_PARAMC10                    => null,
        p_PARAMD1                     => null,
        p_PARAMD2                     => null,
        p_PARAMD3                     => null,
        p_PARAMD4                     => null,
        p_PARAMD5                     => null,
        p_PARAMD6                     => null,
        p_PARAMD7                     => null,
        p_PARAMD8                     => null,
        p_PARAMD9                     => null,
        p_PARAMD10                    => null,
        p_ATTRIBUTE_CATEGORY          => null,
        p_ATTRIBUTE1                  => null,
        p_ATTRIBUTE2                  => null,
        p_ATTRIBUTE3                  => null,
        p_ATTRIBUTE4                  => null,
        p_ATTRIBUTE5                  => null,
        p_ATTRIBUTE6                  => null,
        p_ATTRIBUTE7                  => null,
        p_ATTRIBUTE8                  => null,
        p_ATTRIBUTE9                  => null,
        p_ATTRIBUTE10                 => null,
        p_ATTRIBUTE11                 => null,
        p_ATTRIBUTE12                 => null,
        p_ATTRIBUTE13                 => null,
        p_ATTRIBUTE14                 => null,
        p_ATTRIBUTE15                 => null,
        p_LAST_UPDATE_LOGIN           => null,
        X_Return_Status               => l_return_status,
        X_Msg_Count                   => l_msg_count,
        X_Msg_Data                    => l_msg_data
       );

		IF (g_debug > 0 ) THEN
		       csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_shipment_update after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
		END IF;

        v_total_records := v_total_records + 1;

		IF (g_debug > 0 ) THEN
		       csd_gen_utility_pvt.add('Successfully updated the history');
		END IF;


		IF (g_debug > 0 ) THEN
		       csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_SHIPMENT_UPDATE - Repair Line ID : '||to_char(i.repair_line_id));
		       csd_gen_utility_pvt.add('Inserted into Repairs History Table for Serial number Change');
		       csd_gen_utility_pvt.add('Product Txn Serial number : '||l_pt_serial_num||' Ship Serial number : '||i.sl_number);
		END IF;


     end if;
   end if;
 end if;

 Exception
   When no_data_found then
	IF (g_debug > 0 ) THEN
	     csd_gen_utility_pvt.add('No data found exception,in check for serial number change');
	END IF;

   When others then
	IF (g_debug > 0 ) THEN
	     csd_gen_utility_pvt.add('When others exception,in check for serial number change');
	END IF;

 END;

end if;
-- travi 012502

if not v_skip_record then

	IF (g_debug > 0 ) THEN
	  csd_gen_utility_pvt.add('Calling the convert to primary uom ');
	END IF;


   csd_depot_repair_cntr.convert_to_primary_uom
   (i.inventory_item_id,
    i.organization_id,
    i.shipped_uom,
    i.shipped_quantity,
    p_result_ship_quantity);

    update csd_repairs
    set quantity_shipped = nvl(quantity_shipped,0)+nvl(p_result_ship_quantity,0)
    where repair_line_id = I.repair_line_id;

	--Vijay 2/3/03  Begin
	update csd_product_transactions
	set sub_inventory = i.subinv,
		lot_number   = i.lot_number
	where
		repair_line_id = i.repair_line_id;

	--Vijay 2/3/03  End

	IF (g_debug > 0 ) THEN
	    csd_gen_utility_pvt.add('Updated csd_repairs table');
	END IF;


    fnd_message.set_name('CSD','CSD_DRC_QTY_SHIPPED');
    fnd_message.set_token('ORDER_NO',i.order_number);
    fnd_message.set_token('REP_NO',i.repair_number);
    fnd_message.set_token('QTY_SHIP',to_char(p_result_ship_quantity));
	IF (g_debug > 0 ) THEN
	    csd_gen_utility_pvt.add(fnd_message.get);
	    csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_shipment_update before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for PS event');
	    csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write');
	END IF;


    CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
      P_Api_Version_Number       => 1.0,
      P_Init_Msg_List            => 'F',
      P_Commit                   => 'F',
      p_validation_level         => null,
      p_action_code              => 0  ,
      px_REPAIR_HISTORY_ID       => l_rep_hist_id,
      p_OBJECT_VERSION_NUMBER    => null,                     -- travi ovn validation
      p_REQUEST_ID    => null,
      p_PROGRAM_ID    => null,
      p_PROGRAM_APPLICATION_ID  => null,
      p_PROGRAM_UPDATE_DATE     => null,
      p_CREATED_BY       => -1,
      p_CREATION_DATE    => sysdate,
      p_LAST_UPDATED_BY  =>  -1,
      p_LAST_UPDATE_DATE => sysdate,
      p_REPAIR_LINE_ID   => I.repair_line_id,
      p_EVENT_CODE       => 'PS',
      p_EVENT_DATE       => I.date_shipped,
      p_QUANTITY         =>   p_result_ship_quantity,
      p_PARAMN1    =>   i.delivery_detail_id,
      p_PARAMN2    =>    i.order_line_number,
      p_PARAMN3    =>    i.line_type_id,
      p_PARAMN4    =>    i.txn_billing_type_id,
      p_PARAMN5    => null,
      p_PARAMN6    => null,
      p_PARAMN7    => null,
      p_PARAMN8    => null,
      p_PARAMN9    => null,
      p_PARAMN10   => null,
      p_PARAMC1    => null,
      p_PARAMC2    => i.order_number,
      p_PARAMC3    => null,
      p_PARAMC4    => null,
      p_PARAMC5    => null,
      p_PARAMC6    => null,
      p_PARAMC7    => null,
      p_PARAMC8    => null,
      p_PARAMC9    => null,
      p_PARAMC10   => null,
      p_PARAMD1    => null,
      p_PARAMD2    => null,
      p_PARAMD3    => null,
      p_PARAMD4    => null,
      p_PARAMD5    => null,
      p_PARAMD6    => null,
      p_PARAMD7    => null,
      p_PARAMD8    => null,
      p_PARAMD9    => null,
      p_PARAMD10   => null,
      p_ATTRIBUTE_CATEGORY  => null,
      p_ATTRIBUTE1    => null,
      p_ATTRIBUTE2    => null,
      p_ATTRIBUTE3    => null,
      p_ATTRIBUTE4    => null,
      p_ATTRIBUTE5    => null,
      p_ATTRIBUTE6    => null,
      p_ATTRIBUTE7    => null,
      p_ATTRIBUTE8    => null,
      p_ATTRIBUTE9    => null,
      p_ATTRIBUTE10   => null,
      p_ATTRIBUTE11   => null,
      p_ATTRIBUTE12   =>null,
      p_ATTRIBUTE13   => null,
      p_ATTRIBUTE14   => null,
      p_ATTRIBUTE15   => null,
      p_LAST_UPDATE_LOGIN  => null,
      X_Return_Status      => l_return_status  ,
      X_Msg_Count          => l_msg_count,
      X_Msg_Data           => l_msg_data
     );

	IF (g_debug > 0 ) THEN
	      csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_shipment_update after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
	      csd_gen_utility_pvt.add('Successfully completed Depot repair Shipping Update');
	END IF;

      commit;

      v_total_records := v_total_records + 1;

  End if;

End loop;

  fnd_message.set_name('CSD','CSD_DRC_SHIP_TOTAL_REC_PROC');
  fnd_message.set_token('TOT_REC',to_char(v_total_records));
	IF (g_debug > 0 ) THEN
	  csd_gen_utility_pvt.add(fnd_message.get);
	END IF;


  if ( p_repair_line_id is not null ) then
	IF (g_debug > 0 ) THEN
	    csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_SHIPMENT_UPDATE : Call from Depot Repair Form Tools Menu');
	    csd_gen_utility_pvt.add('Repair Line ID ='||to_char(p_repair_line_id));
	    csd_gen_utility_pvt.add('Total Records inserted into Repairs History Table ='||to_char(v_total_records));
	END IF;

  end if;


End;

-- travi changes
------------------------------------------------------------------
-- procedure name: depot_update_task_hist
-- description   : procedure used to Update Repair Order history
--                 for task creation from concurrent program
------------------------------------------------------------------
PROCEDURE  depot_update_task_hist
(
  errbuf                  OUT NOCOPY    varchar2,
  retcode                 OUT NOCOPY    number,
  p_repair_line_id        in     number
)
is
      l_api_name               CONSTANT VARCHAR2(30)   := 'VALIDATE_AND_WRITE';
      l_api_version            CONSTANT NUMBER         := 1.0;
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_msg_index              NUMBER;

      x_return_status          VARCHAR2(1);
      x_msg_count              NUMBER;
      x_msg_data               VARCHAR2(2000);

      l_return_status          VARCHAR2(1);
      l_repair_history_id      NUMBER;

     v_total_records          number;
      l_event_code             VARCHAR2(30) := '';

      l_task_id                number;
      l_repair_line_id         number;
      l_rep_hist_id            number;

      l_paramn1                NUMBER;
      l_paramn2                NUMBER;
      l_paramn3                NUMBER;
      l_paramn4                NUMBER;
      l_paramn5                NUMBER;
      l_paramc1                VARCHAR2(240);
      l_paramc2                VARCHAR2(240);
      l_paramc3                VARCHAR2(240);
      l_paramc4                VARCHAR2(240);
      l_paramc5                VARCHAR2(240);
      l_paramc6                VARCHAR2(240);
      l_paramd1                DATE;
      l_paramd2                DATE;
      l_paramd3                DATE;
      l_paramd4                DATE;
      l_owner                  VARCHAR2(240);
      l_task_status            VARCHAR2(240);

         CURSOR  c_updated_tasks( p_repair_line_id number ) is
         select  tsk.task_id
                 ,rep.repair_line_id
                 --,max(hist.repair_history_id) repair_history_id
           from  csd_repair_tasks_v tsk
                ,csd_repair_history hist
                ,csd_repairs rep
          where  rep.repair_line_id = tsk.source_object_id
            and tsk.source_object_id = hist.repair_line_id
           and tsk.task_id = hist.paramn1
            and ( tsk.task_status_id <> hist.paramn5 or tsk.owner_id <> hist.paramn3)
          and  rep.repair_line_id = nvl(p_repair_line_id, rep.repair_line_id)  -- travi 181201 change
       group by tsk.task_id, rep.repair_line_id;

         CURSOR  c_tasks_to_updt(l_task_id number, l_repair_line_id number, l_rep_hist_id number) is
         Select  tsk.task_id,            -- hist.paramn1
                 tsk.last_updated_by,    -- hist.paramn2
                 tsk.owner_id,           -- hist.paramn3
                 tsk.assigned_by_id,        -- hist.paramn4
                 tsk.task_status_id,     -- hist.paramn5
                 tsk.task_number,        -- hist.paramc1
                 tsk.owner_type,         -- hist.paramc2
                 tsk.owner,              -- hist.paramc3
                 null assignee_type,      -- hist.paramc4
                 null assignee_name,      -- hist.paramc5
                 tsk.task_status,        -- hist.paramc6
                 tsk.planned_start_date, -- hist.paramd1
                 tsk.actual_start_date,  -- hist.paramd2
                 tsk.actual_end_date,    -- hist.paramd3
                 tsk.last_update_date,   -- hist.paramd4
                 hist.paramc3,           -- tsk.owner
                 hist.paramc6            -- tsk.task_status
           from  CSD_REPAIR_TASKS_V tsk
                ,csd_repair_history hist
          where  tsk.source_object_type_code = 'DR'
            and  tsk.task_id                 = l_task_id
            and  tsk.source_object_id        = l_repair_line_id
            and  hist.repair_history_id      = l_rep_hist_id
            and  hist.paramn1                = tsk.task_id
            and  hist.repair_line_id         = tsk.source_object_id
            and ( tsk.task_status_id <> hist.paramn5 or tsk.owner_id <> hist.paramn3);

                -- travi 020402 commented out old code
                 -- tsk.assignee_id,        -- hist.paramn4
                 -- tsk.assignee_type,      -- hist.paramc4
                 -- tsk.assignee_name,      -- hist.paramc5

BEGIN

     v_total_records := 0;
 -- travi added p_repair_line_id
 FOR R in c_updated_tasks( p_repair_line_id )
 loop

    l_event_code := '';
    l_task_id        := '';
    l_repair_line_id := '';
    l_rep_hist_id    := '';
    l_paramn1        := ''; -- task id
    l_paramn2        := ''; -- last updated by
    l_paramn3        := ''; -- owner id
    l_paramn4        := ''; -- assigned by id
    l_paramn5        := ''; -- status id
    l_paramc1        := ''; -- task number
    l_paramc2        := ''; -- owner type
    l_paramc3        := ''; -- owner name
    l_paramc4        := ''; -- null assignee type
    l_paramc5        := ''; -- null assignee name
    l_paramc6        := ''; -- status
    l_paramd1        := ''; -- planned start date
    l_paramd2        := ''; -- actual start date
    l_paramd3        := ''; -- actual end date
    l_paramd4        := ''; -- last updated date
    l_owner          := ''; -- tsk.owner
    l_task_status    := ''; -- tsk.task_status

     select max(hist2.repair_history_id)
     into l_rep_hist_id
     from CSD_REPAIR_HISTORY hist2
     where hist2.repair_line_id = R.repair_line_id
     and hist2.paramn1         = R.task_id;

     l_task_id        := R.task_id;
     l_repair_line_id := R.repair_line_id;


     IF (l_rep_hist_id is not null) then

         OPEN c_tasks_to_updt(l_task_id, l_repair_line_id, l_rep_hist_id);

         FETCH c_tasks_to_updt
          INTO   l_paramn1, -- task id
               l_paramn2, -- last updated by
               l_paramn3, -- owner id
               l_paramn4, -- assigned by id
               l_paramn5, -- status id
               l_paramc1, -- task number
               l_paramc2, -- owner type
               l_paramc3, -- owner name
               l_paramc4, -- null assignee type
               l_paramc5, -- null assignee name
               l_paramc6, -- status
               l_paramd1, -- planned start date
               l_paramd2, -- actual start date
               l_paramd3, -- actual end date
               l_paramd4, -- last updated date
               l_owner,   -- tsk.owner
                 l_task_status;  -- -- tsk.task_status

         CLOSE c_tasks_to_updt;

           if (l_task_status <> l_paramc6) then
             l_event_code := 'TSC';
           elsif (l_owner <> l_paramc3) then
             l_event_code := 'TOC';
           end if;

   -- ---------------------------------------------------------
   -- Repair history row inserted for TOC or TSC only
   -- ---------------------------------------------------------
      if (l_event_code in ('TOC', 'TSC')) then

      -- --------------------------------
      -- Begin Update repair task history
      -- --------------------------------
      -- Standard Start of API savepoint
         SAVEPOINT  Update_rep_task_hist;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- ---------------
      -- Api body starts
      -- ---------------
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_update_task_hist before CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write call for TOC or TSC event');
END IF;


        CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
      (p_Api_Version_Number       => 1.0 ,
       p_init_msg_list            => 'F',
       p_commit                   => 'F',
       p_validation_level         => NULL,
       p_action_code              => 0,
       px_REPAIR_HISTORY_ID       => l_repair_history_id,
           p_OBJECT_VERSION_NUMBER    => null,                     -- travi ovn validation
       p_REQUEST_ID               => null,
       p_PROGRAM_ID               => null,
       p_PROGRAM_APPLICATION_ID   => null,
       p_PROGRAM_UPDATE_DATE      => null,
       p_CREATED_BY               => FND_GLOBAL.USER_ID,
       p_CREATION_DATE            => sysdate,
       p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
       p_LAST_UPDATE_DATE         => sysdate,
       p_repair_line_id           => l_repair_line_id,
       p_EVENT_CODE               => l_event_code,
       p_EVENT_DATE               => sysdate,
       p_QUANTITY                 => null,
       p_PARAMN1                  => l_paramn1,
       p_PARAMN2                  => l_paramn2,
       p_PARAMN3                  => l_paramn3,
       p_PARAMN4                  => l_paramn4,
       p_PARAMN5                  => l_paramn5,
       p_PARAMN6                  => null,
       p_PARAMN7                  => null,
       p_PARAMN8                  => null,
       p_PARAMN9                  => null,
       p_PARAMN10                 => FND_GLOBAL.USER_ID,
       p_PARAMC1                  => l_paramc1,
       p_PARAMC2                  => l_paramc2,
       p_PARAMC3                  => l_paramc3,
       p_PARAMC4                  => l_paramc4,
       p_PARAMC5                  => l_paramc5,
       p_PARAMC6                  => l_paramc6,
       p_PARAMC7                  => null,
       p_PARAMC8                  => null,
       p_PARAMC9                  => null,
       p_PARAMC10                 => null,
       p_PARAMD1                  => l_paramd1,
       p_PARAMD2                  => l_paramd1,
       p_PARAMD3                  => l_paramd1,
       p_PARAMD4                  => l_paramd1,
       p_PARAMD5                  => null,
       p_PARAMD6                  => null,
       p_PARAMD7                  => null,
       p_PARAMD8                  => null,
       p_PARAMD9                  => null,
       p_PARAMD10                 => null,
       p_ATTRIBUTE_CATEGORY       => null,
       p_ATTRIBUTE1               => null,
       p_ATTRIBUTE2               => null,
       p_ATTRIBUTE3               => null,
       p_ATTRIBUTE4               => null,
       p_ATTRIBUTE5               => null,
       p_ATTRIBUTE6               => null,
       p_ATTRIBUTE7               => null,
       p_ATTRIBUTE8               => null,
       p_ATTRIBUTE9               => null,
       p_ATTRIBUTE10              => null,
       p_ATTRIBUTE11              => null,
       p_ATTRIBUTE12              => null,
       p_ATTRIBUTE13              => null,
       p_ATTRIBUTE14              => null,
       p_ATTRIBUTE15              => null,
       p_LAST_UPDATE_LOGIN        => FND_GLOBAL.CONC_LOGIN_ID,
       X_Return_Status            => x_return_status,
       X_Msg_Count                => x_msg_count,
       X_Msg_Data                 => x_msg_data
      );
    --
IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.depot_update_task_hist after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write x_return_status'||x_return_status);
END IF;

      -- -------------------
      -- Api body ends here
      -- -------------------

      -- Standard check of p_commit.
        IF FND_API.To_Boolean( 'F' ) THEN
             COMMIT WORK;
        END IF;

      -- Standard call to get message count and IF count is  get message info.
        FND_MSG_PUB.Count_And_Get
             (p_count  =>  x_msg_count,
              p_data   =>  x_msg_data );

        v_total_records := v_total_records + 1;

    end if; -- End of TOC/TSC check

   commit;

  end if; -- End of check for l_rep_hist_id

 end loop;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('Completed depot_update_task_hist with Success..');
END IF;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('Inserted into CSD_REPAIR_HISTORY table '||to_char(v_total_records)||' Records');
END IF;


   -- travi check for call from tools
   if ( p_repair_line_id is not null ) then
IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('CSD_DEPOT_REPAIR_CNTR.DEPOT_UPDATE_TASK_HIST : Call from Depot Repair Form Tools Menu');
END IF;

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('Repair Line ID ='||to_char(p_repair_line_id));
END IF;

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('Total Records inserted into Repairs History Table ='||to_char(v_total_records));
END IF;

   end if;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_rep_task_hist;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data
                );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Update_rep_task_hist;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data
                );
      when no_data_found then
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('ndf');
END IF;

      when too_many_rows then
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('tmf');
END IF;

      when value_error then
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('ve');
END IF;


      WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Update_rep_task_hist;
              IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
              END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('others '||sqlerrm||to_char(sqlcode));
END IF;


END depot_update_task_hist;

end CSD_DEPOT_REPAIR_CNTR;

/
