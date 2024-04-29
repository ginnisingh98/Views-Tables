--------------------------------------------------------
--  DDL for Package Body GML_OPM_ROI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OPM_ROI_GRP" AS
/* $Header: GMLGROIB.pls 115.9 2004/06/03 20:23:28 mchandak ship $*/

g_asn_debug VARCHAR2(1):= NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');
g_opm_restrict_rma_lots		VARCHAR2(100) ;
g_opm_rma_lot_info_exists	BOOLEAN ;

PROCEDURE print_debug(p_err_msg VARCHAR2, p_level NUMBER) IS
BEGIN
   inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg, p_module => 'GML_OPM_ROI_GRP', p_level => p_level);
END print_debug;

PROCEDURE  insert_errors(p_rti_id		IN NUMBER,
			 p_group_id		IN NUMBER,
			 p_header_interface_id	IN NUMBER,
			 p_column_name		IN VARCHAR2,
                         p_table_name           IN VARCHAR2,
                         p_mesg_owner		IN VARCHAR2,
                         p_Error_Message	IN VARCHAR2,
                         p_Error_Message_name   IN VARCHAR2,
                         p_TokenName1		IN VARCHAR2 DEFAULT NULL,
                         p_TokenValue1		IN VARCHAR2 DEFAULT NULL,
                         p_TokenName2		IN VARCHAR2 DEFAULT NULL,
                         p_TokenValue2		IN VARCHAR2 DEFAULT NULL,
                         p_TokenName3		IN VARCHAR2 DEFAULT NULL,
                         p_TokenValue3		IN VARCHAR2 DEFAULT NULL,
                         p_TokenName4		IN VARCHAR2 DEFAULT NULL,
                         p_TokenValue4		IN VARCHAR2 DEFAULT NULL
                          )

IS

PRAGMA AUTONOMOUS_TRANSACTION;

l_interface_type   	VARCHAR2(25) := 'RCV-856';
l_error_message		po_interface_errors.error_message%TYPE ;
l_group_id		NUMBER;
l_header_interface_id	NUMBER;
BEGIN

       l_error_message := p_error_message;

       IF l_error_message IS NULL THEN

           IF p_mesg_owner IS NOT NULL AND p_error_message_name IS NOT NULL THEN

               fnd_message.set_name(p_mesg_owner, p_error_message_name);

               IF (p_TokenName1 IS NOT NULL AND p_TokenValue1 IS NOT NULL) THEN
                   fnd_message.set_token(p_TokenName1, p_TokenValue1);
               END IF;
               IF (p_TokenName2 IS NOT NULL AND p_TokenValue2 IS NOT NULL) THEN
                   fnd_message.set_token(p_TokenName2, p_TokenValue2);
               END IF;
               IF (p_TokenName3 IS NOT NULL AND p_TokenValue3 IS  NOT NULL) THEN
                   fnd_message.set_token(p_TokenName3, p_TokenValue3);
               END IF;
               IF (p_TokenName4 IS NOT NULL AND p_TokenValue4 IS NOT NULL) THEN
                   fnd_message.set_token(p_TokenName4, p_TokenValue4);
               END IF;

               l_error_message := Fnd_message.get;

           END IF;

       END IF;

       IF p_group_id IS NULL THEN
       	    SELECT group_id,header_interface_id
       	    INTO   l_group_id,l_header_interface_id
       	    FROM rcv_transactions_interface
       	    WHERE  interface_transaction_id = p_rti_id ;

       END IF;

       INSERT INTO po_interface_errors(Interface_Type,
                                Interface_Transaction_Id,
				column_name,
				table_name,
				error_message,
                                Error_Message_name,
                                processing_date,
				Creation_Date,
                                Created_By,
                                Last_Update_Date,
                                Last_Updated_by,
                                Last_Update_Login,
                                Interface_Header_ID,
                                Interface_Line_Id,
                                Interface_Distribution_Id,
                                Request_Id,
                                Program_Application_id,
                                Program_Id,
                                Program_Update_date,
                                BATCH_ID)
                             VALUES
                              (l_interface_type,
                               po_interface_errors_s.NEXTVAL,
			       p_column_name,
                               p_table_name,
                               l_error_message,
                               p_Error_Message_name,
                               SYSDATE,
                               SYSDATE,
			       fnd_global.user_id,
			       SYSDATE,
                               fnd_global.user_id,
                               fnd_global.login_id,
                               NVL(p_header_interface_id,l_header_interface_id),
                               p_rti_id,
                               null,
                               fnd_global.conc_request_id,
                               fnd_global.prog_appl_id,
                               fnd_global.conc_program_id,
                               SYSDATE,
                               nvl(p_group_id,l_group_id));

-- Have to commit at the end of a successful autonomous transaction
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
     IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Unhandled exception in gml_opm_roi_grp.insert_errors=>'||substr(sqlerrm,1,200));
     END IF;
END insert_errors;



-- This procedure validates the onhand quantity for the returns and negative corrections
-- to deliver transactions. If the return quantity or the correction quantity is more than
-- what is avaliable for that item,warehouse,location combination then raise an error

PROCEDURE validate_quantity_onhand(p_lot_id  		IN NUMBER,
				   p_opm_item_id	IN NUMBER,
				   p_organization_id	IN NUMBER,
				   p_locator_id		IN NUMBER,
				   p_primary_quantity	IN NUMBER,
				   p_rti_id		IN NUMBER,
				   x_return_status      OUT NOCOPY VARCHAR2) IS

l_loct_onhand		NUMBER	:= 0;
l_default_location	VARCHAR2(16);

Cursor Cr_qoh_loct_not_null Is
Select	sum(loct_onhand)
From	ic_loct_inv ilv,ic_loct_mst ilm,ic_whse_mst iwm
Where	ilv.item_id 	= p_opm_item_id
and	ilv.whse_code 	= iwm.whse_code
and	ilv.location 	= ilm.location
and	iwm.mtl_organization_id    = p_organization_id
and	ilm.inventory_location_id  = p_locator_id
and	ilv.lot_id 	= nvl(p_lot_id,ilv.lot_id)
having	sum(loct_onhand) > 0;

Cursor Cr_qoh_loct_null Is
Select	sum(loct_onhand)
From	ic_loct_inv ilv,ic_whse_mst iwm
Where	ilv.item_id 	= p_opm_item_id
and	ilv.whse_code 	= iwm.whse_code
and	ilv.location 	= l_default_location
and	iwm.mtl_organization_id = p_organization_id
and	ilv.lot_id 	= nvl(p_lot_id,ilv.lot_id)
having	sum(loct_onhand)> 0;

/*Bug 3117947*/
Cursor Cr_check_noninv IS
Select noninv_ind
From   ic_item_mst
Where  item_id = p_opm_item_id;

l_noninv_ind NUMBER :=0;
l_table_name	VARCHAR2(35);
l_progress	VARCHAR2(4) := '010';

--Bug# 3664014
V_allow_neg_inv NUMBER;

BEGIN

	x_return_status  := fnd_api.g_ret_sts_success;

	IF (p_lot_id IS NULL) AND (g_asn_debug = 'Y') THEN
             asn_debug.put_line('lotid=>'||p_lot_id||'item id=>'||p_opm_item_id||'orgid=>'||p_organization_id||'locatorid=>'||p_locator_id||'qty=>'||p_primary_quantity);
        END IF;


        IF p_opm_item_id IS NULL THEN
           RETURN;
        END IF;

	--Fetch the GMI Allow negative inv profile option
        --Bug# 3664014
        V_allow_neg_inv      := nvl(fnd_profile.value('IC$ALLOWNEGINV'),0);

        IF (p_lot_id IS NULL) AND (g_asn_debug = 'Y') THEN
             asn_debug.put_line('-veinv profile=>'||v_allow_neg_inv);
        END IF;


        --Negative inv is allowed so return.
        IF V_allow_neg_inv = 1 THEN
           RETURN;
        END IF;

        Open Cr_check_noninv;
        Fetch Cr_check_noninv into l_noninv_ind;
        IF Cr_check_noninv%NOTFOUND THEN
           Close Cr_check_noninv;
           RETURN;
        END IF;
        Close Cr_check_noninv;

        l_progress	:= '020';


        IF l_noninv_ind = 1 THEN
           RETURN;
        END IF;

        IF p_locator_id is not null THEN
        	Open 	Cr_qoh_loct_not_null;
		Fetch	Cr_qoh_loct_not_null into l_loct_onhand;

		IF (p_lot_id IS NULL) AND (g_asn_debug = 'Y') THEN
        	    asn_debug.put_line('inventory onhand for locator=>'||l_loct_onhand);
        	END IF;

		IF (Cr_qoh_loct_not_null%NOTFOUND) OR (abs(p_primary_quantity) > nvl(l_loct_onhand,0))
		THEN
		     Close Cr_qoh_loct_not_null;
			--If do not allow negative inv then give error
              		--Bug# 3664014
              	     IF V_allow_neg_inv = 0 THEN
                 	FND_MESSAGE.SET_NAME('GMI','IC_INVQTYNEG');
			FND_MSG_PUB.Add;
     			x_return_status  := fnd_api.g_ret_sts_error;
     			RETURN ;
         	     --If set to 2 then give warning.
              	     ELSIF V_allow_neg_inv = 2 THEN
              	        FND_MESSAGE.SET_NAME('GMI','IC_WARNINVQTYNEG');
			FND_MSG_PUB.Add;
     			x_return_status  := 'W';
     			RETURN ;
	             END IF;
         	END IF;
		Close Cr_qoh_loct_not_null;
	ELSE
		l_default_location	:= fnd_profile.value('IC$DEFAULT_LOCT');

		Open 	Cr_qoh_loct_null;
		Fetch	Cr_qoh_loct_null into l_loct_onhand;

		IF (p_lot_id IS NULL) AND (g_asn_debug = 'Y') THEN
        	    asn_debug.put_line('inventory onhand for default locator=>'||l_loct_onhand);
        	END IF;

		IF (Cr_qoh_loct_null%NOTFOUND) OR (abs(p_primary_quantity) > nvl(l_loct_onhand,0))
		THEN
		      Close Cr_qoh_loct_null;
		      -- bug# 3664014
		      IF V_allow_neg_inv = 0 THEN
                 	  FND_MESSAGE.SET_NAME('GMI','IC_INVQTYNEG');
			  FND_MSG_PUB.Add;
     			  x_return_status  := fnd_api.g_ret_sts_error;
     			  RETURN ;
         	     --If set to 2 then give warning.
              	      ELSIF V_allow_neg_inv = 2 THEN
              	          FND_MESSAGE.SET_NAME('GMI','IC_WARNINVQTYNEG');
			  FND_MSG_PUB.Add;
     			  x_return_status  := 'W';
     			  RETURN ;
	              END IF;
     		END IF;
		Close Cr_qoh_loct_null;
	END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF p_lot_id IS NULL THEN
         l_table_name  := 'RCV_TRANSACTIONS_INTERFACE';
    ELSE
    	 l_table_name  := 'MTL_TRANSACTION_LOTS_INTERFACE';
    END IF;

    insert_errors(	 p_rti_id		=> p_rti_id,
			 p_group_id		=> NULL,
			 p_header_interface_id	=> NULL,
			 p_column_name		=> 'PRIMARY_QUANTITY',
                         p_table_name           => l_table_name,
			 p_error_message 	=> 'UNHANDLED EXCEPTION IN GML_OPM_ROI_GRP.VALIDATE_QUANTITY_ONHAND :' || l_progress||'-' ||
			 				substr(sqlerrm,1,1000),
                         p_mesg_owner		=> NULL,
                         p_Error_Message_name   => NULL);

    IF p_lot_id IS NULL THEN
    	IF (g_asn_debug = 'Y') THEN
       	     asn_debug.put_line('Unhandled exception in validate_quantity_onhand=>'||l_progress||'-'||substr(sqlerrm,1,200));
    	END IF;
    ELSE
      	IF NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0) = 1 THEN
	    print_debug('VALIDATE_QUANTITY_ONHAND:UNHANDLED EXCEPTION'||l_progress||'-'||substr(sqlerrm,1,100), 1);
	END IF;
    END IF;
END validate_quantity_onhand;


PROCEDURE validate_opm_parameters(x_opm_record	IN OUT NOCOPY gml_opm_roi_grp.opm_record_type) IS
   l_item_um2			VARCHAR2(4);
   l_return_status		VARCHAR2(1);
   l_msg_count    		BINARY_INTEGER;
   l_msg_data  			VARCHAR2(2000);
   l_progress			VARCHAR2(4) := '010' ;
   l_locator_id			NUMBER;
   l_opm_item_id		NUMBER ;

BEGIN

   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('Validating Process Item'||l_progress);
   END IF;

   -- bug# 3664014
   -- added some more parameters in x_opm_record type.
   -- validate_opm_parameters API was reading these extra parameters from
   -- rcv_transactions_interface table which does hold the latest data. All the latest data
   -- are in the cascaded table. Removed the select from RTI table.

   l_progress   := '020';

   IF x_opm_record.receipt_source_code IN ('VENDOR','INTERNAL ORDER','CUSTOMER') THEN
       BEGIN
      	   IF x_opm_record.item_num is not null THEN
           	select item_um2,item_id into l_item_um2,l_opm_item_id from ic_item_mst
           	where item_no = x_opm_record.item_num ;
      	   ELSE
           	select iim.item_no , iim.item_um2 , iim.item_id into x_opm_record.item_num,l_item_um2 , l_opm_item_id
           	from mtl_system_items_b msi,ic_item_mst iim
           	where msi.inventory_item_id = x_opm_record.item_id
	   	and   msi.organization_id = x_opm_record.to_organization_id
	   	and   msi.segment1 = iim.item_no ;
      	   END IF;

       EXCEPTION WHEN NO_DATA_FOUND THEN
-- In case of RMA,discrete item under process org is a valid transaction and it falls
-- under Discrete.To classify a given RMA transaction as OPM RMA transaction,item and
-- organization both should be process.
            IF x_opm_record.receipt_source_code = 'CUSTOMER' THEN
		x_opm_record.secondary_uom_code := NULL;
       	 	x_opm_record.secondary_unit_of_measure := NULL;
       	 	x_opm_record.secondary_quantity := NULL;
       	 	x_opm_record.qc_grade        := NULL ;
       	 	RETURN ;
       	    ELSE
            	x_opm_record.error_record.error_status := 'F' ;
            	x_opm_record.error_record.error_message := 'GML_OPM_ITEM_NOT_EXIST';

            	insert_errors(p_rti_id		=> x_opm_record.rti_id,
			 p_group_id		=> x_opm_record.group_id,
			 p_header_interface_id	=> x_opm_record.header_interface_id,
			 p_column_name		=> 'ITEM_ID',
                         p_table_name           => 'RCV_TRANSACTIONS_INTERFACE',
			 p_error_message 	=> NULL,
                         p_mesg_owner		=> 'GML',
                         p_Error_Message_name   => 'GML_OPM_ITEM_NOT_EXIST' );
            	RETURN ;
            END IF;
       END ;

       l_progress    := '030' ;

       --If its a negative correction or a return to a deliver transaction then
       --validate the onhand quantities in OPM.

       IF ((x_opm_record.transaction_type = 'CORRECT' AND x_opm_record.quantity < 0)
         OR (x_opm_record.transaction_type IN ('RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER'))
          )
         AND ( x_opm_record.destination_type_code = 'INVENTORY') THEN

	     IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validation primary qty against onhand'||l_progress);
             END IF;

	     l_locator_id := x_opm_record.from_locator_id ;

	     validate_quantity_onhand(p_lot_id 		=> NULL,
				p_opm_item_id		=> l_opm_item_id,
				p_organization_id	=> x_opm_record.to_organization_id,
				p_locator_id		=> l_locator_id,
				p_primary_quantity	=> x_opm_record.primary_quantity,
				p_rti_id		=> x_opm_record.rti_id,
				x_return_status		=> l_return_status );

	     IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('validate_quantity_onhand done'||l_return_status);
             END IF;

	     IF l_return_status <> 'S' THEN
-- bug 3664014 insert into po_interface_error even if its warning.
	        IF l_return_status <> 'U' THEN
	            insert_errors(p_rti_id	=> x_opm_record.rti_id,
			 p_group_id		=> x_opm_record.group_id,
			 p_header_interface_id	=> x_opm_record.header_interface_id,
			 p_column_name		=> 'PRIMARY_QUANTITY',
                         p_table_name           => 'RCV_TRANSACTIONS_INTERFACE',
			 p_error_message 	=> FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F'),
                         p_mesg_owner		=> NULL,
                         p_Error_Message_name   => NULL );
                END IF;

                IF l_return_status <> 'W' THEN
                   x_opm_record.error_record.error_status := 'F' ;
                   IF l_return_status <> 'U' THEN
                      x_opm_record.error_record.error_message := 'IC_INVQTYNEG';
                   END IF;
                   RETURN;
                ELSE
                    l_return_status := 'S' ;
                END IF;
       	     END IF;
       END IF;

       l_progress    := '040' ;

       IF l_item_um2 IS NOT NULL THEN
	   IF  (x_opm_record.secondary_unit_of_measure IS NULL
  	   And x_opm_record.secondary_uom_code IS NOT NULL ) THEN
  	      BEGIN
  	      	SELECT muom.unit_of_measure INTO  x_opm_record.secondary_unit_of_measure
            	FROM   mtl_units_of_measure muom
            	WHERE  muom.uom_code = x_opm_record.secondary_uom_code ;

	      EXCEPTION WHEN NO_DATA_FOUND THEN
        	 x_opm_record.error_record.error_status := 'F' ;
	         x_opm_record.error_record.error_message := 'PO_PDOI_INVALID_UOM_CODE';
	         RETURN;
              END ;
            END IF;

 	    IF (g_asn_debug = 'Y') THEN
                 asn_debug.put_line('Validating Secondary Qty' || l_progress);
            END IF;

	     -- if secondary quantity is present, validate it else calculate it.
	     -- if secondary_unit_of_measure is not null,validate it else derive it.

	     l_progress    := '050' ;

	     GML_ValidateDerive_GRP.Secondary_Qty
		( p_api_version          => '1.0'
		, p_init_msg_list        => 'F'
		, p_validate_ind	 => 'Y'
		, p_item_no	 	 => x_opm_record.item_num
		, p_unit_of_measure 	 => x_opm_record.unit_of_measure
		, p_secondary_unit_of_measure => x_opm_record.secondary_unit_of_measure
		, p_quantity	 	 => x_opm_record.quantity
		, p_secondary_quantity   => x_opm_record.secondary_quantity
		, x_return_status        => l_return_status
		, x_msg_count            => l_msg_count
		, x_msg_data             => l_msg_data ) ;

	      IF (g_asn_debug = 'Y') THEN
                  asn_debug.put_line('Status of Validating Secondary Qty' || l_return_status);
                  asn_debug.put_line('secondary unit' || x_opm_record.secondary_unit_of_measure);
                  asn_debug.put_line('secondary qty' || x_opm_record.secondary_quantity);
              END IF;

	      IF l_return_status <> 'S' THEN
		  x_opm_record.error_record.error_status  := 'F';
	          x_opm_record.error_record.error_message := 'GML_SEC_QTY_VAL_FAILED' ;

	          IF l_msg_data IS NULL THEN
	              l_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F');
	          END IF ;

	          insert_errors(p_rti_id	=> x_opm_record.rti_id,
			 p_group_id		=> x_opm_record.group_id,
			 p_header_interface_id	=> x_opm_record.header_interface_id,
			 p_column_name		=> 'SECONDARY_QUANTITY',
                         p_table_name           => 'RCV_TRANSACTIONS_INTERFACE',
			 p_error_message 	=> l_msg_data,
                         p_mesg_owner		=> NULL,
                         p_Error_Message_name   => NULL );

		  RETURN;
	      END IF;

	      l_progress    := '060' ;

	      SELECT muom.uom_code INTO x_opm_record.secondary_uom_code
	      FROM   mtl_units_of_measure muom
 	      WHERE muom.unit_of_measure = x_opm_record.secondary_unit_of_measure ;
	 ELSE
	 	x_opm_record.secondary_uom_code := NULL;
       	 	x_opm_record.secondary_unit_of_measure := NULL;
       	 	x_opm_record.secondary_quantity := NULL;

         END IF; -- IF l_item_um2 IS NOT NULL THEN
      END IF; -- IF x_opm_record.receipt_source_code

EXCEPTION WHEN OTHERS THEN
    x_opm_record.error_record.error_status := 'U' ;
    insert_errors( p_rti_id		=> x_opm_record.rti_id,
		   p_group_id		=> x_opm_record.group_id,
	 	   p_header_interface_id => x_opm_record.header_interface_id,
		   p_column_name	=> 'OPM_COLUMNS',
                   p_table_name         => 'RCV_TRANSACTIONS_INTERFACE',
		   p_error_message 	=> 'UNHANDLED EXCEPTION IN VALIDATE_OPM_PARAMETERS :' || l_progress||'-' ||
		 				substr(sqlerrm,1,1000),
                   p_mesg_owner		=> NULL,
                   p_Error_Message_name   => NULL);
    IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('Unhandled exception in validate_opm_parameters=>'|| l_progress||'-'||substr(sqlerrm,1,200));
    END IF;

END validate_opm_parameters;

PROCEDURE validate_lot_attributes(p_lot_attribute_rec  	IN OUT NOCOPY gml_opm_roi_grp.lot_attributes_rec_type,
   	    			  p_inventory_item_id	IN NUMBER,
   	    			  p_organization_id	IN NUMBER,
   	    			  p_trans_date		IN DATE,
   	    			  p_rti_id		IN NUMBER,
   	    			  x_return_status 	IN OUT NOCOPY VARCHAR2 ) IS

l_temp		VARCHAR2(1);
l_inv_debug 	NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress	VARCHAR2(4) := '010' ;

CURSOR Cur_lot_ctrl_lot IS
SELECT  lot_id,inactive_ind,delete_mark
FROM    ic_lots_mst
WHERE   lot_no  = p_lot_attribute_rec.lot_no
AND     item_id = p_lot_attribute_rec.opm_item_id ;


CURSOR Cur_sublot_ctrl_lot IS
SELECT  lot_id,inactive_ind,delete_mark
FROM    ic_lots_mst
WHERE   lot_no  = p_lot_attribute_rec.lot_no
AND     item_id = p_lot_attribute_rec.opm_item_id
AND     sublot_no = p_lot_attribute_rec.sublot_no ;


l_sublot_ctl		BINARY_INTEGER;
l_inactive_ind		BINARY_INTEGER;
l_delete_mark		BINARY_INTEGER;
l_shelf_life_code	NUMBER;
l_shelf_life		NUMBER;
l_expire_date		DATE ;

BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

    g_default_lot := nvl(FND_PROFILE.VALUE('IC$DEFAULT_LOT'),'0') ;

    IF l_inv_debug =  1 THEN
       print_debug('Default Lot=>'||g_default_lot, 1);
    END IF;

    IF p_lot_attribute_rec.lot_no = G_DEFAULT_LOT THEN
     	 FND_MESSAGE.SET_NAME('GMI','IC_INVALID_LOT');
     	 FND_MSG_PUB.Add;
     	 x_return_status  := fnd_api.g_ret_sts_error;
     	 RETURN ;
    END IF;

    SELECT sublot_ctl,shelf_life
    INTO   l_sublot_ctl,l_shelf_life
    FROM   ic_item_mst_b
    WHERE  item_id = p_lot_attribute_rec.opm_item_id ;


    IF p_lot_attribute_rec.sublot_no IS NOT NULL AND l_sublot_ctl = 0 THEN
  	    FND_MESSAGE.SET_NAME('GMI','IC_INVALID_LOT/SUBLOT');
     	    FND_MSG_PUB.Add;
     	    x_return_status  := fnd_api.g_ret_sts_error;
     	    RETURN ;
    END IF;

    l_progress	:= '020' ;

    IF p_lot_attribute_rec.reason_code IS NOT NULL THEN
    BEGIN
	select 'x' into l_temp
	from sy_reas_cds
	where reason_code = p_lot_attribute_rec.reason_code
	and  delete_mark = 0 ;

    EXCEPTION WHEN OTHERS THEN
	FND_MESSAGE.SET_NAME('GMI','IC_API_INVALID_REASON_CODE');
	FND_MESSAGE.SET_TOKEN('REASON_CODE',p_lot_attribute_rec.reason_code);
        FND_MSG_PUB.Add;
        x_return_status  := fnd_api.g_ret_sts_error;
        RETURN ;
    END ;
    END IF;

    l_progress	:= '030' ;

    IF p_lot_attribute_rec.new_lot = 'N' THEN
    	IF p_lot_attribute_rec.sublot_no IS NULL THEN
	    OPEN  Cur_lot_ctrl_lot ;
  	    FETCH Cur_lot_ctrl_lot INTO p_lot_attribute_rec.lot_id,l_inactive_ind,l_delete_mark;
  	    IF Cur_lot_ctrl_lot%NOTFOUND THEN
  	    	CLOSE Cur_lot_ctrl_lot;
  	    	FND_MESSAGE.SET_NAME('GMI','IC_INVALID_LOT');
     	    	FND_MSG_PUB.Add;
     	    	x_return_status  := fnd_api.g_ret_sts_error;
     	    	RETURN ;
  	    END IF;
  	    CLOSE Cur_lot_ctrl_lot ;
  	ELSE
  	    OPEN  Cur_sublot_ctrl_lot ;
  	    FETCH Cur_sublot_ctrl_lot INTO p_lot_attribute_rec.lot_id,l_inactive_ind,l_delete_mark;
  	    IF Cur_sublot_ctrl_lot%NOTFOUND THEN
  	    	CLOSE Cur_sublot_ctrl_lot;
  	    	FND_MESSAGE.SET_NAME('GMI','IC_INVALID_LOT');
     	    	FND_MSG_PUB.Add;
     	    	x_return_status  := fnd_api.g_ret_sts_error;
     	    	RETURN ;
  	    END IF;
  	    CLOSE Cur_sublot_ctrl_lot ;
  	END IF;

  	l_progress	:= '040' ;

        IF l_inactive_ind = 1 THEN
           FND_MESSAGE.SET_NAME('GML','PO_INACTIVE_LOT');
           FND_MSG_PUB.Add;
     	   x_return_status  := fnd_api.g_ret_sts_error;
     	   RETURN ;
        ELSIF l_delete_mark = 1 THEN
           FND_MESSAGE.SET_NAME('GML', 'PO_LOT_DELETED');
           FND_MSG_PUB.Add;
     	   x_return_status  := fnd_api.g_ret_sts_error;
     	   RETURN ;
        END IF;

    ELSE -- LOT IS NEW
    	-- validate expiration date.
    	SELECT shelf_life_code INTO l_shelf_life_code
    	FROM   mtl_system_items_b
    	WHERE  inventory_item_id = p_inventory_item_id
    	AND    organization_id = p_organization_id ;

    	l_progress	:= '050' ;

    	IF l_shelf_life_code = 4 and p_lot_attribute_rec.expiration_date IS NULL THEN
    	    FND_MESSAGE.SET_NAME('GMI','IC_INVALID_EXPIRE_DATE');
            FND_MSG_PUB.Add;
     	    x_return_status  := fnd_api.g_ret_sts_error;
     	    RETURN ;
     	ELSIF l_shelf_life_code = 2 THEN

     	    SELECT p_trans_date + l_shelf_life  into l_expire_date  FROM DUAL ;

     	    -- if expiration date specified by user is different than system calculated date
     	    -- enter record into error table saying expiration date will be over-written.

            IF p_lot_attribute_rec.expiration_date <> l_expire_date THEN

            	insert_errors( p_rti_id	=> p_rti_id,
		   p_group_id		=> null,
	 	   p_header_interface_id => null,
		   p_column_name	=> 'EXPIRATION_DATE',
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> null,
                   p_mesg_owner		=> 'GML',
                   p_Error_Message_name   => 'GML_OVERRIDE_EXP_DATE',
                   p_TokenName1		=> 'LOT_NO',
                   p_Tokenvalue1	=> p_lot_attribute_rec.lot_no,
                   p_TokenName2		=> 'SUBLOT_NO',
                   p_Tokenvalue2	=> p_lot_attribute_rec.sublot_no);
            END IF;
            p_lot_attribute_rec.expiration_date := l_expire_date ;

        ELSIF l_shelf_life_code = 1 and p_lot_attribute_rec.expiration_date IS NOT NULL THEN
             p_lot_attribute_rec.expiration_date := NULL ;
             insert_errors( p_rti_id	=> p_rti_id,
		   p_group_id		=> null,
	 	   p_header_interface_id => null,
		   p_column_name	=> 'EXPIRATION_DATE',
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> null,
                   p_mesg_owner		=> 'GML',
                   p_Error_Message_name   => 'GML_OVERRIDE_EXP_DATE',
                   p_TokenName1		=> 'LOT_NO',
                   p_Tokenvalue1	=> p_lot_attribute_rec.lot_no,
                   p_TokenName2		=> 'SUBLOT_NO',
                   p_Tokenvalue2	=> p_lot_attribute_rec.sublot_no);
        END IF;
    END IF;

EXCEPTION WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   insert_errors(  p_rti_id		=> p_rti_id,
		   p_group_id		=> null,
	 	   p_header_interface_id => null,
		   p_column_name	=> null,
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> 'UNHANDLED EXCEPTION IN VALIDATE_LOT_ATTRIBUTES :' || l_progress||'-' ||
		 				substr(sqlerrm,1,1000),
                   p_mesg_owner		=> NULL,
                   p_Error_Message_name   => NULL);
   IF l_inv_debug =  1 THEN
       print_debug('Unhandled exception in validate_lot_attributes'||l_progress||'-'||substr(sqlerrm,1,100), 1);
   END IF;

END validate_lot_attributes ;


PROCEDURE check_lot_status(p_lot_attribute_rec  IN OUT NOCOPY gml_opm_roi_grp.lot_attributes_rec_type,
			   p_organization_id	IN NUMBER,
			   p_locator_id		IN NUMBER,
			   p_trans_date		IN DATE,
			   p_rti_id		IN NUMBER,
			   x_return_status      OUT NOCOPY VARCHAR2) IS

l_location              VARCHAR2(20);
l_whse_code             VARCHAR2(5);
l_inv_lot_status        VARCHAR2(5) := NULL;
l_inv_loct_onhand       NUMBER := 0;
l_default_lot_status	VARCHAR2(4);

l_trans_rec             GMIGAPI.qty_rec_typ ;

l_ic_jrnl_mst_row       ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1      ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2      ic_adjs_jnl%ROWTYPE;
l_count                 NUMBER;
l_data                  VARCHAR2(2000);
l_count_msg             NUMBER;
l_dummy_cnt             NUMBER  :=0;
l_reason_code_security  VARCHAR2(1) := 'N';

l_message_data          VARCHAR2(2000);

l_inv_debug 		NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress		VARCHAR2(4) := '010' ;

Cursor Get_Reason_Code IS
select reason_code
From   sy_reas_cds
Where  delete_mark = 0
and  (l_reason_code_security = 'Y')
       AND (reason_code in (select reason_code from gma_reason_code_security
       where (doc_type = 'PORC' or doc_type IS NULL) and
       (responsibility_id = FND_GLOBAL.RESP_id or responsibility_id IS NULL)))
Union all
Select  reason_code
From    sy_reas_cds
Where   delete_mark = 0;

l_item_status_ctl	NUMBER(5);

BEGIN

    x_return_status  := fnd_api.g_ret_sts_success;

    SELECT whse_code INTO l_whse_code
    FROM   IC_WHSE_MST
    WHERE  mtl_organization_id = p_organization_id;


    SELECT lot_status,status_ctl
    INTO   l_default_lot_status,l_item_status_ctl
    FROM   IC_ITEM_MST
    WHERE  item_id    = p_lot_attribute_rec.opm_item_id;

    IF l_inv_debug =  1 THEN
       print_debug('Item lot status '||l_default_lot_status, 1);
    END IF;

    l_progress := '020';

    -- check if item is status control. If not , return
    IF l_item_status_ctl = 0 THEN
       RETURN;
    END IF;

    IF p_locator_id is not null  THEN
    BEGIN
        SELECT location  INTO l_location
        FROM   IC_LOCT_MST
        WHERE  inventory_location_id = p_locator_id;

        EXCEPTION
        WHEN OTHERS THEN
           l_location := NULL;
        END;
    ELSE
      l_location := fnd_profile.value('IC$DEFAULT_LOCT');
    END IF;


    BEGIN
      SELECT    lot_status, loct_onhand
      INTO      l_inv_lot_status, l_inv_loct_onhand
      FROM      ic_loct_inv ilv
      WHERE     ilv.item_id     = p_lot_attribute_rec.opm_item_id
      AND       ilv.lot_id      = p_lot_attribute_rec.lot_id
      AND       ilv.whse_code   = l_whse_code
      AND       ilv.location    = l_location;

      EXCEPTION
         WHEN OTHERS THEN
           l_inv_lot_status := NULL;
    END;

    l_progress := '030';

    IF l_inv_debug =  1 THEN
       print_debug('Inventory lot status and Profile Value for Diff_status'||l_inv_lot_status||'-'||g_moved_diff_stat, 1);
    END IF;

    IF g_moved_diff_stat = 0 THEN
      IF (l_inv_lot_status IS NOT NULL) AND (l_inv_lot_status <> l_default_lot_status) THEN
         FND_MESSAGE.SET_NAME('GML', 'GML_CANT_RECV_DIFF_STATUS');
         FND_MSG_PUB.Add;
     	 x_return_status  := fnd_api.g_ret_sts_error;
     	 RETURN ;
      END IF;
    ELSIF g_moved_diff_stat = 2 THEN
      IF l_inv_lot_status IS NOT NULL AND l_inv_lot_status <> l_default_lot_status
          AND l_inv_loct_onhand = 0 THEN

          SELECT s.co_code,w.orgn_code  INTO l_trans_rec.co_code,l_trans_rec.orgn_code
          FROM   IC_WHSE_MST W,SY_ORGN_MST S
          WHERE  w.whse_code = l_whse_code
          and    w.orgn_code = s.orgn_code;

          IF l_inv_debug =  1 THEN
       		print_debug('Inventory lot status is different than item lot status with onhand as 0', 1);
    	  END IF;

          l_trans_rec.trans_type      := 4;
          l_trans_rec.item_no         := p_lot_attribute_rec.item_no;
          l_trans_rec.lot_no          := p_lot_attribute_rec.lot_no;
          l_trans_rec.sublot_no       := p_lot_attribute_rec.sublot_no;
          l_trans_rec.from_whse_code  := l_whse_code;
          l_trans_rec.from_location   := l_location;
          l_trans_rec.lot_status      := l_default_lot_status;

          l_progress := '040';

          If p_lot_attribute_rec.reason_code IS NOT NULL THEN
             l_trans_rec.reason_code := p_lot_attribute_rec.reason_code ;
          Else
             l_reason_code_security := nvl(fnd_profile.value('GMA_REASON_CODE_SECURITY'), 'N');
             Open Get_Reason_Code;
             Fetch Get_Reason_Code into l_trans_rec.reason_code;
             If Get_Reason_Code%NOTFOUND Then
                Close Get_Reason_Code;

                Update IC_LOCT_INV
                Set    lot_status = l_default_lot_status
                Where  item_id = p_lot_attribute_rec.opm_item_id
                And    whse_code = l_whse_code
                And    location = l_location
                And    lot_id = p_lot_attribute_rec.lot_id;

                IF l_inv_debug =  1 THEN
       		   print_debug('Reason Code not found exit', 1);
    	  	END IF;

                RETURN;
             End If;/*Get_Reason_Code%NOTFOUND*/

             Close Get_Reason_Code;

          End If;

          l_progress := '050';

          l_trans_rec.trans_qty       := NULL;

          l_trans_rec.trans_date      := p_trans_date ;

          IF l_trans_rec.trans_date IS NULL
          THEN
            l_trans_rec.trans_date    := SYSDATE;
          END IF;

          l_trans_rec.user_name       := FND_GLOBAL.USER_NAME;

          -- Set the context for the GMI APIs
          IF( NOT Gmigutl.Setup(l_trans_rec.user_name))
          THEN
               x_return_status  := fnd_api.g_ret_sts_error;
               IF l_inv_debug =  1 THEN
       		   print_debug('Inventory API SETUP Failed for User Name=>'|| l_trans_rec.user_name, 1);
    	       END IF;
               RETURN ;
          END IF;

	  l_progress := '060';

           Gmipapi.Inventory_Posting
           ( p_api_version         => 3.0
           , p_init_msg_list       => 'F'
           , p_commit              => 'F'
           , p_validation_level    => 100
           , p_qty_rec             => l_trans_rec
           , x_ic_jrnl_mst_row     => l_ic_jrnl_mst_row
           , x_ic_adjs_jnl_row1    => l_ic_adjs_jnl_row1
           , x_ic_adjs_jnl_row2    => l_ic_adjs_jnl_row2
           , x_return_status       => x_return_status
           , x_msg_count           => l_count
           , x_msg_data            => l_data
           );

           IF l_inv_debug =  1 THEN
       		print_debug('Inventory Posting API status => '||x_return_status, 1);
    	   END IF;

    	   IF ( x_return_status <> 'S' )
           THEN
               RETURN;
           END IF;

      ELSIF l_inv_lot_status IS NOT NULL AND l_inv_lot_status <> l_default_lot_status
          AND l_inv_loct_onhand <> 0 THEN
              FND_MESSAGE.SET_NAME('GML', 'GML_CANT_RECV_DIFF_STATUS');
              FND_MSG_PUB.Add;
     	      x_return_status  := fnd_api.g_ret_sts_error;
     	      RETURN ;
      END IF; -- IF l_inv_lot_status IS NOT NULL
   END IF; -- IF g_moved_diff_stat = 0 THEN

EXCEPTION WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   insert_errors(  p_rti_id		=> p_rti_id,
		   p_group_id		=> null,
	 	   p_header_interface_id => null,
		   p_column_name	=> null,
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> 'UNHANDLED EXCEPTION IN CHECK_LOT_STATUS :' || l_progress||'-' ||
		 				substr(sqlerrm,1,1000),
                   p_mesg_owner		=> NULL,
                   p_Error_Message_name   => NULL);
   IF l_inv_debug =  1 THEN
       print_debug('Unhandled exception in check_lot_status'||l_progress||'-'||substr(sqlerrm,1,100), 1);
   END IF;

END check_lot_status;


PROCEDURE create_new_lot(p_new_lot_rec     	IN  GMIGAPI.lot_rec_typ,
			 p_organization_id 	IN NUMBER,
			 p_vendor_id	   	IN  NUMBER,
	    		 p_vendor_site_id  	IN  NUMBER,
	    		 p_from_unit_of_measure	IN VARCHAR2,
                         p_to_unit_of_measure   IN VARCHAR2,
                         p_type_factor	   	IN NUMBER,
                         p_rti_id	   	IN NUMBER,
			 x_return_status   	OUT NOCOPY VARCHAR2 ) IS

l_new_lot_rec      	GMIGAPI.lot_rec_typ;
l_ic_lots_mst_rec  	ic_lots_mst%ROWTYPE;
l_ic_lots_cpg_rec  	ic_lots_cpg%ROWTYPE;
l_msg_count		NUMBER(3);
l_msg_data		VARCHAR2(2000);
l_inv_debug 		NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress		VARCHAR2(4) := '010' ;
l_to_um_type		VARCHAR2(10);
l_to_um_code		VARCHAR2(4);
l_from_um_type		VARCHAR2(10);
l_from_um_code		VARCHAR2(4);
l_dualum_ind		NUMBER(1);

BEGIN

     x_return_status  := fnd_api.g_ret_sts_success;
     l_new_lot_rec     := p_new_lot_rec ;

     l_new_lot_rec.user_name	:= FND_GLOBAL.USER_NAME;

     -- the context for the GMI APIs
     IF( NOT Gmigutl.Setup(l_new_lot_rec.user_name))
     THEN
           x_return_status  := fnd_api.g_ret_sts_error;
           IF l_inv_debug =  1 THEN
       	        print_debug('Inventory API SETUP Failed for User Name=>'|| l_new_lot_rec.user_name, 1);
    	   END IF;
           RETURN ;
     END IF;

     l_progress  := '020';

     IF p_vendor_id IS NOT NULL and p_vendor_site_id IS NOT NULL THEN

	BEGIN
	      Select pvm.vendor_no INTO l_new_lot_rec.shipvendor_no
	      From   po_Vend_mst pvm,ic_whse_mst iwm,sy_orgn_mst som
	      Where  pvm.OF_VENDOR_ID = 	p_vendor_id
	      and    pvm.OF_VENDOR_SITE_ID    = p_vendor_site_id
	      and    iwm.mtl_organization_id  = p_organization_id
	      and    iwm.orgn_code            = som.orgn_code
	      and    som.co_code              = pvm.co_code;

	EXCEPTION WHEN OTHERS THEN
	      l_new_lot_rec.shipvendor_no := NULL ;
	END ;

     END IF;

     l_progress  := '030';

     GMIPAPI.Create_Lot( p_api_version      => 3.0
   	                     , p_init_msg_list     => 'F'
   	                     , p_commit            => 'F'
   	                     , p_validation_level  => FND_API.G_VALID_LEVEL_FULL
   	                     , p_lot_rec 	   => l_new_lot_rec
   	                     , x_ic_lots_mst_row   => l_ic_lots_mst_rec
   	                     , x_ic_lots_cpg_row   => l_ic_lots_cpg_rec
   	                     , x_return_status     => x_return_status
   	                     , x_msg_count         => l_msg_count
   	                     , x_msg_data          => l_msg_data
   	                     );

     IF l_inv_debug =  1 THEN
         print_debug('Create Lot status=>'|| x_return_status, 1);
     END IF;

     IF x_return_status <> 'S' THEN
     	RETURN;
     END IF;

     l_progress  := '040';

     -- create lot specific conversion for dual uom item only.
     IF p_from_unit_of_measure IS NOT NULL AND p_to_unit_of_measure IS NOT NULL  THEN
        -- check class of from and to uom. call conversion API only if they
     	-- belong to different class.Also don't create for fixed UOM type(dualum_ind = 1)
     	-- API requires OPM um_code so fetch OPM um code
     	 IF fnd_profile.value('GML_ENABLE_DYN_LOT_SPEC_CONV') = 'Y' THEN

     	     SELECT um_type , um_code INTO l_from_um_type , l_from_um_code
     	     FROM SY_UOMS_MST
     	     WHERE unit_of_measure = p_from_unit_of_measure ;

     	     l_progress  := '050';

     	     SELECT um_type , um_code INTO l_to_um_type , l_to_um_code
     	     FROM SY_UOMS_MST
     	     WHERE unit_of_measure = p_to_unit_of_measure ;

     	     SELECT dualum_ind	INTO l_dualum_ind
     	     FROM IC_ITEM_MST_B
     	     WHERE item_no = l_new_lot_rec.item_no ;


     	     IF (l_from_um_type <> l_to_um_type) AND (l_dualum_ind > 1) THEN

	 	PO_GML_DB_COMMON.CREATE_LOT_SPECIFIC_CONVERSION(
                          x_item_number    =>  l_new_lot_rec.item_no,
                          x_lot_number     =>  l_new_lot_rec.lot_no,
                          x_sublot_number  =>  l_new_lot_rec.sublot_no,
                          x_from_uom       =>  l_from_um_code,
                          x_to_uom         =>  l_to_um_code,
                          x_type_factor    =>  p_type_factor,
                          x_status         =>  x_return_status,
                          x_data           =>  l_msg_data);

		IF l_inv_debug =  1 THEN
           	    print_debug('Create Lot Specific Conversion status=>'|| x_return_status, 1);
     		END IF;

	 	IF x_return_status <> 'S' THEN
	    	    RETURN;
	 	END IF;

	     END IF ;
	 END IF ; -- IF fnd_profile.value('GML_ENABLE_DYN_LOT_SPEC_CONV') = 'Y' THEN
     END IF;


EXCEPTION
WHEN OTHERS THEN
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     insert_errors(  p_rti_id		=> p_rti_id,
		   p_group_id		=> null,
	 	   p_header_interface_id => null,
		   p_column_name	=> null,
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> 'UNHANDLED EXCEPTION IN CREATE_NEW_LOT :' || l_progress||'-' ||
		 				substr(sqlerrm,1,1000),
                   p_mesg_owner		=> NULL,
                   p_Error_Message_name   => NULL);
     IF l_inv_debug =  1 THEN
         print_debug('Unhandled exception in create_new_lot'||l_progress||'-'||substr(sqlerrm,1,100), 1);
     END IF;
END create_new_lot ;

-- ## OPM RMA ##
FUNCTION opm_rma_lot_info_exists(p_oe_header_id  IN NUMBER,
				 p_oe_line_id	 IN NUMBER) RETURN BOOLEAN
IS


l_dummy       NUMBER(1);

CURSOR Cr_lot_exists_line IS
Select  1
From	oe_lot_serial_numbers
Where	(line_id = p_oe_line_id
         or line_set_id =
              (select line_set_id
               from oe_order_lines_all
               where line_id = p_oe_line_id
               and header_id = p_oe_header_id)
         );

BEGIN

   IF p_oe_line_id IS NOT NULL THEN
   	OPEN  Cr_lot_exists_line;
   	FETCH Cr_lot_exists_line INTO l_dummy;
   	IF    Cr_lot_exists_line%NOTFOUND THEN
      	     CLOSE Cr_lot_exists_line;
      	     RETURN FALSE;
   	ELSE
      	     CLOSE Cr_lot_exists_line;
      	     RETURN TRUE;
   	END IF;
   ELSE
   	RETURN FALSE;
   END IF;

END opm_rma_lot_info_exists;

PROCEDURE opm_rma_valid_lot(p_oe_order_header_id IN NUMBER,
			   p_oe_order_line_id	IN  NUMBER,
			   p_lot_no	 	IN  VARCHAR2,
			   p_sublot_no	 	IN  VARCHAR2,
			   p_rti_id		IN  NUMBER,
			   x_line_set_id 	OUT NOCOPY NUMBER,
			   x_oe_lot_quantity	OUT NOCOPY NUMBER,
			   x_return_status	OUT NOCOPY VARCHAR2 ) IS

l_inv_debug 	NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

Cursor Cr_rma_lots Is
Select o.quantity
from   oe_lot_serial_numbers o
Where (o.line_id = p_oe_order_line_id
         OR
       o.line_set_id = x_line_set_id )
AND    o.lot_number = p_lot_no
AND    o.sublot_number = p_sublot_no ;

BEGIN

     IF g_opm_rma_lot_info_exists AND
        g_opm_restrict_rma_lots IN ('RESTRICTED_WITH_WARNING','RESTRICTED') THEN

   	  -- check whether lot specified by user is existing in the Sales Order Line.

   	  SELECT line_set_id INTO x_line_set_id
   	  FROM   oe_order_lines_all
	  WHERE  header_id = p_oe_order_header_id
	  AND    line_id = p_oe_order_line_id ;

	  IF l_inv_debug =  1 THEN
         	  print_debug('Line Set Id=>'||x_line_set_id, 1);
     	  END IF;

	  OPEN  Cr_rma_lots ;
	  FETCH Cr_rma_lots INTO x_oe_lot_quantity ;
	  IF Cr_rma_lots%NOTFOUND THEN
	      CLOSE Cr_rma_lots ;
	      x_oe_lot_quantity := NULL ;
	      IF l_inv_debug =  1 THEN
         	  print_debug('Lot Different From RMA Lot', 1);
     	      END IF;

	      IF g_opm_restrict_rma_lots IN ('RESTRICTED') THEN
	          FND_MESSAGE.SET_NAME('GML','GML_DIFF_RMA_LOT');
                  FND_MSG_PUB.Add;
     	          x_return_status  := fnd_api.g_ret_sts_error;
     	          RAISE FND_API.G_EXC_ERROR;
     	      ELSE  -- warning.put into interface table.
     	      	 insert_errors( p_rti_id	=> p_rti_id,
	              p_group_id		=> null,
	              p_header_interface_id 	=> null,
	              p_column_name		=> 'LOT_NUMBER',
                      p_table_name        	 => 'MTL_TRANSACTION_LOTS_INTERFACE',
	              p_error_message 		=> null,
                      p_mesg_owner		=> 'GML',
                      p_Error_Message_name  	=> 'GML_DIFF_RMA_LOT'
                      );
     	      END IF;
     	  ELSE
     	      CLOSE Cr_rma_lots ;
     	      IF l_inv_debug =  1 THEN
         	  print_debug('Lot Found In RMA Lot', 1);
     	      END IF;
	  END IF;
     END IF; -- IF g_opm_rma_lot_info_exists THEN

END opm_rma_valid_lot ;

PROCEDURE validate_rma_quantity(p_opm_item_id  		IN 	NUMBER,
                                p_lot_id 		IN	NUMBER,
                                p_lot_no 		IN	VARCHAR2,
                                p_sublot_no		IN	VARCHAR2,
                                p_oe_order_header_id 	IN	NUMBER,
                                p_oe_order_line_id 	IN	NUMBER,
                                p_lot_qty 		IN	NUMBER,
                                p_unit_of_measure	IN	VARCHAR2,
                                p_rma_lot_qty		IN	NUMBER,
                                p_rma_lot_uom 		IN	VARCHAR2,
                                p_line_set_id 		IN	NUMBER,
                                p_rti_id		IN      NUMBER,
                                x_allowed 		OUT NOCOPY VARCHAR2,
                                x_allowed_quantity 	OUT NOCOPY NUMBER,
                                x_return_status		OUT NOCOPY VARCHAR2 ) IS

l_inv_debug 	NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
    IF g_opm_restrict_rma_lots IN ('RESTRICTED_WITH_WARNING','RESTRICTED') AND
       g_opm_rma_lot_info_exists  AND p_rma_lot_qty IS NOT NULL THEN

         IF l_inv_debug =  1 THEN
            print_debug('parameters for validate_rma_lot_quantites lot_id=>'||p_lot_id, 1);
            print_debug('parameters for validate_rma_lot_quantites lot_qty_by_user=>'||p_lot_qty, 1);
            print_debug('parameters for validate_rma_lot_quantites rma_lot_qty=>'||p_rma_lot_qty, 1);
         END IF;
   	 gml_rcv_db_common.validate_rma_lot_quantities(
   	 			       p_init_msg_list  => 'F',
   	 			       p_api_version	=> 1.0,
				       p_opm_item_id  	=> p_opm_item_id,
                                       p_lot_id 	=> p_lot_id,
                                       p_lot_no 	=> p_lot_no,
                                       p_sublot_no	=> p_sublot_no,
                                       p_oe_header_id 	=> p_oe_order_header_id,
                                       p_oe_line_id 	=> p_oe_order_line_id ,
                                       p_trx_qty 	=> p_lot_qty ,
                                       p_trx_uom 	=> p_unit_of_measure ,
                                       p_rma_lot_qty	=> p_rma_lot_qty,
                                       p_rma_lot_uom 	=> p_rma_lot_uom,
                                       p_line_set_id 	=> p_line_set_id,
                                       X_allowed 	=> x_allowed,
                                       X_allowed_quantity => x_allowed_quantity,
                                       x_return_status   => x_return_status);

	IF l_inv_debug =  1 THEN
           print_debug('validate_rma_lot_quantites allowed and status=>'||x_allowed||'-'||x_return_status, 1);
     	END IF;

     	IF x_return_status <> 'S' THEN
     	    return;
     	END IF;

	IF x_allowed = 'N' THEN
            IF g_opm_restrict_rma_lots IN ('RESTRICTED_WITH_WARNING') THEN
                insert_errors( p_rti_id			=> p_rti_id,
		               p_group_id		=> null,
	 	               p_header_interface_id 	=> null,
		               p_column_name		=> 'TRANSACTION_QUANTITY',
                               p_table_name        	=> 'MTL_TRANSACTION_LOTS_INTERFACE',
		               p_error_message 		=> null,
                               p_mesg_owner		=> 'GML',
                               p_Error_Message_name  	=> 'GML_DIFF_RMA_QTY',
                               p_TokenName1		=> 'S1',
                               p_TokenValue1		=> x_allowed_quantity
                             );
            ELSE
                      /*Give error message that the quantity entered Is greater than the qty entered in the RMA for this lot */
                FND_MESSAGE.SET_NAME('GML', 'GML_DIFF_RMA_QTY');
                FND_MESSAGE.SET_TOKEN('S1',x_allowed_quantity);
     	        FND_MSG_PUB.Add;
     		x_return_status  := fnd_api.g_ret_sts_error;
	    END IF;
        END IF; -- IF x_allowed = 'N' THEN
    END IF; -- IF g_opm_restrict_rma_lots IN ('RESTRICTED_WITH_WARNING','RESTRICTED')

END validate_rma_quantity;

PROCEDURE validate_opm_lot( p_api_version	 	IN  NUMBER,
			    p_init_msg_lst	 	IN  VARCHAR2 := FND_API.G_FALSE,
			    p_mtlt_rowid	 	IN  ROWID,
			    p_new_lot		 	IN  VARCHAR2,
			    p_opm_item_id	 	IN  NUMBER,
			    p_item_no		 	IN  VARCHAR2,
			    p_lots_specified_on_parent	IN  VARCHAR2,
			    p_lot_id			IN  NUMBER,
			    p_parent_txn_type	 	IN  VARCHAR2 DEFAULT NULL,
			    p_grand_parent_txn_type	IN  VARCHAR2 DEFAULT NULL,
			    x_return_status      	OUT NOCOPY VARCHAR2,
			    x_msg_data           	OUT NOCOPY VARCHAR2,
			    x_msg_count          	OUT NOCOPY NUMBER
			) IS

l_api_name	CONSTANT VARCHAR2(30)	:= 'Validate_Opm_Lot';
l_api_version   CONSTANT NUMBER 	:= 1.0;
l_pkg_name	CONSTANT VARCHAR2(30)	:= 'GML_OPM_ROI_GRP';

l_transaction_type		rcv_transactions_interface.transaction_type%TYPE ;
l_source_document_code		rcv_transactions_interface.source_document_code%TYPE ;
l_item_id                       NUMBER;
l_org_id                        NUMBER;
l_to_locator_id                 NUMBER;
l_from_locator_id               NUMBER;
l_locator_id			NUMBER;
l_unit_of_measure               rcv_transactions_interface.unit_of_measure%TYPE;
l_secondary_unit_of_measure     rcv_transactions_interface.secondary_unit_of_measure%TYPE;
l_validation_flag		rcv_transactions_interface.validation_flag%TYPE;
l_lot_attribute_rec		gml_opm_roi_grp.lot_attributes_rec_type ;

l_new_lot_rec      		GMIGAPI.lot_rec_typ;
l_lot_no			ic_lots_mst.lot_no%TYPE;
l_sublot_no			ic_lots_mst.sublot_no%TYPE;
l_lot_expiration_date		DATE ;
l_lot_quantity			NUMBER;
l_lot_secondary_quantity	NUMBER;
l_reason_code			VARCHAR2(4);
l_vendor_lot_no_on_lot		ic_lots_mst.vendor_lot_no%TYPE;
l_vendor_lot_no_on_line		ic_lots_mst.vendor_lot_no%TYPE;
l_vendor_id			NUMBER;
l_vendor_site_id		NUMBER;
l_transaction_date		DATE ;
l_rti_id			NUMBER;

l_lot_desc			ic_lots_mst.lot_desc%TYPE;

l_same_lot_count		BINARY_INTEGER;
l_parent_transaction_id		NUMBER;
l_shipment_header_id		NUMBER;
l_shipment_line_id		NUMBER;
l_net_received_lot_qty		NUMBER;
l_comment			rcv_transactions.comments%TYPE;
l_lot_primary_quantity		NUMBER;
l_old_recv_qty			NUMBER;
l_recv_id			NUMBER;
l_recvline_id			NUMBER;
l_old_rtrn_qty			NUMBER;
l_cr_avaliable_qty		NUMBER;
l_temp				VARCHAR2(1);
l_rti_primary_qty		NUMBER;

l_inv_debug 			NUMBER 	:= NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress			VARCHAR2(4) := '010' ;
l_update_lot_qty		BOOLEAN := FALSE;

l_oe_order_header_id		NUMBER;
l_oe_order_line_id       	NUMBER;
l_line_set_id			NUMBER;
l_oe_lot_quantity		NUMBER := NULL;
l_allowed			VARCHAR2(1);
l_allowed_quantity		NUMBER;
l_total_no_of_lots		NUMBER;
l_rti_quantity			NUMBER;
l_rti_secondary_quantity	NUMBER;

Cursor Cr_get_total_qty_available IS
SELECT sum(itp.trans_qty)
FROM   rcv_transactions rt , ic_tran_pnd itp
WHERE
     rt.shipment_header_id = l_shipment_header_id
AND  rt.shipment_line_id   = l_shipment_line_id
AND  itp.doc_id 	   = rt.shipment_header_id
AND  itp.line_id	   = rt.transaction_id
AND  itp.doc_type          = 'PORC'
AND  itp.lot_id	           = p_lot_id ;


Cursor Cr_old_recv_qty Is
Select	sum(itp.trans_qty),
	itp.doc_id,
	itp.line_id
from 	rcv_transactions rcv,
	gml_recv_trans_map grm,
	ic_tran_pnd itp
where 	rcv.transaction_id = l_parent_transaction_id
and 	rcv.comments 	= 'OPM RECEIPT'
and	rcv.interface_transaction_id = grm.interface_transaction_id
and	itp.doc_type 	= 'RECV'
and	grm.recv_id 	= itp.doc_id
and	grm.line_id 	= itp.line_id
and	itp.lot_id	= p_lot_id
group by itp.doc_id,itp.line_id
having sum(itp.trans_qty) > 0 ;

Cursor Cr_old_rtrn_qty Is
Select	sum(itp.trans_qty) qty
from	ic_tran_pnd itp,
 	po_Rtrn_dtl d,
 	po_rtrn_hdr h
where 	h.return_id	= d.return_id
and	d.recv_id 	= l_recv_id
and 	d.recvline_id	= l_recvline_id
and	h.delete_mark	<> -1
and	d.return_id 	= itp.doc_id
and	d.line_id	= itp.line_id
and	itp.doc_type	= 'RTRN'
and	itp.lot_id 	= p_lot_id
and 	itp.delete_mark	<> 1;

BEGIN
   x_return_status   := fnd_api.g_ret_sts_success;

   IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	       p_api_version,
   	       	    	 	       l_api_name,
		    	    	       l_pkg_name )
   THEN
	RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_lst ) THEN
	FND_MSG_PUB.initialize;
   END IF;

   l_progress	:= '020' ;

   SELECT product_transaction_id,
               Ltrim(Rtrim(lot_number)) ,
      	       Ltrim(Rtrim(sublot_num)) ,
      	       lot_expiration_date,
      	       transaction_quantity,
      	       primary_quantity,
	       secondary_quantity,
	       reason_code,
	       substr(ltrim(rtrim(supplier_lot_number)),1,32),
	       substr(description,1,40)
   INTO   l_rti_id			,
	  l_lot_no                 ,
	  l_sublot_no              ,
	  l_lot_expiration_date    ,
	  l_lot_quantity           ,
	  l_lot_primary_quantity   ,
	  l_lot_secondary_quantity ,
	  l_reason_code            ,
	  l_vendor_lot_no_on_lot	,
	  l_lot_desc
   FROM MTL_TRANSACTION_LOTS_TEMP
   WHERE rowid = p_mtlt_rowid ;

   l_progress	:= '030' ;

   IF l_inv_debug =  1 THEN
       print_debug('Lot record fetched with quantity =>'||l_lot_no||'-'||l_sublot_no||'-'||l_lot_quantity, 1);
   END IF;

   SELECT TRANSACTION_TYPE
	, SOURCE_DOCUMENT_CODE
	, item_id
	, TO_ORGANIZATION_ID
	, locator_id
	, from_locator_id
	, unit_of_measure
	, secondary_unit_of_measure
	, transaction_date
	, vendor_lot_num
	, vendor_id
	, vendor_site_id
	, parent_transaction_id
	, shipment_header_id
	, shipment_line_id
	, Nvl(primary_quantity, quantity)
	, validation_flag
	, oe_order_header_id
	, oe_order_line_id
	, quantity
	, secondary_quantity
   INTO L_TRANSACTION_TYPE
        , L_SOURCE_DOCUMENT_CODE
        , l_item_id
        , l_org_id
        , l_to_locator_id
        , l_from_locator_id
        , l_unit_of_measure
        , l_secondary_unit_of_measure
        , l_transaction_date
        , l_vendor_lot_no_on_line
        , l_vendor_id
        , l_vendor_site_id
        , l_parent_transaction_id
        , l_shipment_header_id
        , l_shipment_line_id
        , l_rti_primary_qty
        , l_validation_flag
        , l_oe_order_header_id
	, l_oe_order_line_id
	, l_rti_quantity
	, l_rti_secondary_quantity
   FROM RCV_TRANSACTIONS_INTERFACE
   WHERE INTERFACE_TRANSACTION_ID = l_rti_id;

   IF l_inv_debug =  1 THEN
       print_debug('Interface Record fetched =>'||l_rti_id, 1);
       print_debug('Source Document Code =>'||l_source_document_code, 1);
       print_debug('to_Locator Id and from_locator_id =>'||l_to_locator_id||'-'||l_from_locator_id, 1);
       print_debug('Transaction Type =>'||l_transaction_type, 1);
       print_debug('Secondary UOM =>'||l_secondary_unit_of_measure, 1);
       print_debug('Shipment header/line Id =>'||l_shipment_header_id||'-'||l_shipment_line_id, 1);
   END IF;

   IF nvl(l_validation_flag,'N') = 'N' THEN
       IF l_inv_debug =  1 THEN
           print_debug('Return back. Coming from Desktop. No need to validate the lots', 1);
       END IF;
       RETURN ;
   END IF;

   l_progress	:= '040' ;
   -- check for duplicate lots.

   SELECT count(1) INTO l_same_lot_count
   FROM MTL_TRANSACTION_LOTS_TEMP
   WHERE
        PRODUCT_CODE = 'RCV'
   AND  PRODUCT_TRANSACTION_ID = l_rti_id
   AND  Ltrim(Rtrim(lot_number)) = l_lot_no
   AND  ((sublot_num IS NULL AND l_sublot_no IS NULL) OR (Ltrim(Rtrim(sublot_num)) = l_sublot_no )) ;

   IF l_same_lot_count > 1 THEN
        FND_MESSAGE.SET_NAME('GML', 'GML_LOT_SUBLOT_USED');
        FND_MSG_PUB.Add;
     	x_return_status  := fnd_api.g_ret_sts_error;
     	RAISE FND_API.G_EXC_ERROR;
   END IF;

   SELECT count(1) INTO l_total_no_of_lots
   FROM MTL_TRANSACTION_LOTS_TEMP
   WHERE
        PRODUCT_CODE = 'RCV'
   AND  PRODUCT_TRANSACTION_ID = l_rti_id ;

   -- IF there is only one lot for the receipt line and receipt line qty = lot qty
   -- default the secondary qty from line to lot record if secondary lot qty is null.
   IF l_total_no_of_lots = 1 and (l_rti_quantity = l_lot_quantity) AND l_lot_secondary_quantity IS NULL
   	AND l_rti_secondary_quantity IS NOT NULL THEN

       IF l_inv_debug =  1 THEN
           print_debug('Defaulting Lot Secondary Qty from Receipt Line=>'||l_rti_secondary_quantity, 1);
       END IF;

       l_lot_secondary_quantity := l_rti_secondary_quantity ;

       UPDATE mtl_transaction_lots_temp
       SET    secondary_quantity  = l_lot_secondary_quantity
       WHERE  rowid = p_mtlt_rowid ;

   END IF;


   l_lot_attribute_rec.opm_item_id 	:= p_opm_item_id ;
   l_lot_attribute_rec.item_no     	:= p_item_no ;
   l_lot_attribute_rec.lot_no  	  	:= l_lot_no;
   l_lot_attribute_rec.sublot_no  	:= l_sublot_no;
   l_lot_attribute_rec.expiration_date	:= l_lot_expiration_date;
   l_lot_attribute_rec.reason_code	:= l_reason_code ;
   l_lot_attribute_rec.new_lot	  	:= p_new_lot ;

   l_progress	:= '050' ;

   IF l_source_document_code = 'RMA' THEN
   	g_opm_restrict_rma_lots := fnd_profile.value('GMI_RMA_LOT_RESTRICT') ;
   	IF l_inv_debug =  1 THEN
       	    print_debug('GMI_RMA_LOT_RESTRICT =>'||g_opm_restrict_rma_lots, 1);
       	END IF;
   	IF g_opm_restrict_rma_lots IN ('RESTRICTED_WITH_WARNING','RESTRICTED') THEN
   	    	-- check whether lot is specified for the Sales ORder Line.
   	    	-- If there is no lot , then user can receive into any valid lot.
   	    	g_opm_rma_lot_info_exists := opm_rma_lot_info_exists(
   	    	     					p_oe_header_id => l_oe_order_header_id ,
	                                                p_oe_line_id   => l_oe_order_line_id );
	ELSE
		g_opm_rma_lot_info_exists := FALSE ;
	END IF;
   END IF;

   IF (l_transaction_type IN ('RECEIVE','ACCEPT','REJECT','TRANSFER','DELIVER'))
      OR (l_transaction_type = 'SHIP' and l_source_document_code = 'PO') THEN
   	IF l_source_document_code = 'RMA' THEN
   	   -- lots can be entered at any time - receive,accept, reject , transfer, deliver.
	      opm_rma_valid_lot(p_oe_order_header_id	=> l_oe_order_header_id ,
	   			p_oe_order_line_id	=> l_oe_order_line_id,
	   			p_lot_no	 	=> l_lot_no,
	   			p_sublot_no	 	=> l_sublot_no,
	   			p_rti_id		=> l_rti_id,
	   			x_line_set_id 		=> l_line_set_id,
	   			x_oe_lot_quantity	=> l_oe_lot_quantity,
	   			x_return_status		=> x_return_status );

        -- no need to check x_return_status since the above API will raise exception in case of error.

        END IF; -- IF l_source_document_code = 'RMA' THEN

   	l_progress	:= '060' ;

   	-- lot attributes will return lot_id in case of existing lot.
   	validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   				p_inventory_item_id => l_item_id,
   				p_organization_id => l_org_id,
   				p_trans_date => l_transaction_date,
   				p_rti_id     => l_rti_id,
   				x_return_status => x_return_status
   				);

	IF l_inv_debug =  1 THEN
       	     print_debug('Validate lot attribute status for transaction type '||l_transaction_type||' =>'||x_return_status, 1);
       	     print_debug('lot id=>'||l_lot_attribute_rec.lot_id, 1);
       	END IF;

	IF x_return_status <> 'S' THEN
	    RAISE FND_API.G_EXC_ERROR;
	END IF;

	l_progress	:= '065' ;

	-- for restricted , it will come here only if lots are valid.
	-- for restricted with warning, it can come here even if lot specified
	-- by user is different than RMA lots. So validate the quantity
	-- only if user lot is existing in RMA by using l_oe_lot_quantity IS NOT NULL

	IF l_source_document_code = 'RMA' AND l_transaction_type IN ('RECEIVE','DELIVER') THEN
	    l_progress	:= '066' ;
	    -- always call validate_rma_quantity before validate_lot_attributes.
	    -- validate_lot_attributes gives a lot_id which in turn is used in validate_rma_quantity

	    validate_rma_quantity(p_opm_item_id  		=> p_opm_item_id,
		                      p_lot_id 		        => l_lot_attribute_rec.lot_id,
		                      p_lot_no 		        => l_lot_no,
		                      p_sublot_no		=> l_sublot_no,
		                      p_oe_order_header_id      => l_oe_order_header_id,
		                      p_oe_order_line_id        => l_oe_order_line_id ,
		                      p_lot_qty 		=> l_lot_quantity ,
		                      p_unit_of_measure	        => l_unit_of_measure ,
		                      p_rma_lot_qty		=> l_oe_lot_quantity,
		                      p_rma_lot_uom 		=> NULL,
		                      p_line_set_id 		=> l_line_set_id,
		                      p_rti_id		        => l_rti_id,
		                      x_allowed 		=> l_allowed,
		                      x_allowed_quantity        => l_allowed_quantity,
	   			      x_return_status		=> x_return_status );

	    IF x_return_status <> 'S' THEN
	        RAISE FND_API.G_EXC_ERROR;
	    END IF;
	END IF; -- IF l_source_document_code = 'RMA' THEN


	-- validate/derive secondary quantity.
	l_progress	:= '070' ;

   	IF l_secondary_unit_of_measure IS NOT NULL THEN
           IF l_lot_secondary_quantity IS NULL THEN
           	l_update_lot_qty := TRUE ;
           END IF;

           GML_ValidateDerive_GRP.Secondary_Qty
		( p_api_version          => '1.0'
		, p_init_msg_list        => 'F'
		, p_validate_ind	 => 'Y'
		, p_item_no	 	 => p_item_no
		, p_lot_id		 => nvl(l_lot_attribute_rec.lot_id,0)
		, p_unit_of_measure 	 => l_unit_of_measure
		, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		, p_quantity	 	 => l_lot_quantity
		, p_secondary_quantity   => l_lot_secondary_quantity
		, x_return_status        => x_return_status
		, x_msg_count            => x_msg_count
		, x_msg_data             => x_msg_data ) ;

	   IF l_inv_debug =  1 THEN
       	   	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       	    	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       	   END IF;

    	   IF x_return_status <> 'S' THEN
	       RAISE FND_API.G_EXC_ERROR;
    	   END IF;

    	   IF l_update_lot_qty THEN
    	        update mtl_transaction_lots_temp
    	        set    secondary_quantity  = l_lot_secondary_quantity
    	        where  rowid = p_mtlt_rowid ;
    	   END IF;
        END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN

	l_progress	:= '080' ;

	IF p_new_lot = 'N' THEN
	    l_progress	:= '070' ;
	    IF l_transaction_type = 'DELIVER' THEN
	    	-- validate lot status depending upon the profile option.
	        g_moved_diff_stat := fnd_profile.value('IC$MOVEDIFFSTAT');
	        IF g_moved_diff_stat in (0,2) THEN
	             l_locator_id := l_to_locator_id ;
	             check_lot_status(p_lot_attribute_rec => l_lot_attribute_rec,
	    	      		      p_organization_id => l_org_id,
	    	      		      p_trans_date	=> l_transaction_date,
	    	  		      p_locator_id	=> l_locator_id,
	    	  		      p_rti_id		=> l_rti_id,
				      x_return_status => x_return_status
   	    				);

		     IF l_inv_debug =  1 THEN
       	     		print_debug('Check Lot Status for old lot for transaction type '||l_transaction_type||' =>'||x_return_status, 1);
        	     END IF;

		     IF x_return_status <> 'S' THEN
	        	  RAISE FND_API.G_EXC_ERROR;
	             END IF;
	    	END IF;
	    END IF ;
   	ELSE -- IF p_new_lot =  'N' THEN

            -- validate_lot_attributes API may return expiration date depending upon the settings.

            l_new_lot_rec.item_no		:= p_item_no ;
   	    l_new_lot_rec.lot_no  		:= l_lot_no;
   	    l_new_lot_rec.sublot_no 		:= l_sublot_no;
   	    l_new_lot_rec.expire_date		:= l_lot_attribute_rec.expiration_date;
   	    l_new_lot_rec.lot_desc		:= l_lot_desc ;
	    l_new_lot_rec.qc_grade        	:= NULL ;
	    l_new_lot_rec.lot_created		:= l_transaction_date;
	    l_new_lot_rec.origination_type	:= 3;
	    l_new_lot_rec.vendor_lot_no		:= nvl(l_vendor_lot_no_on_lot,l_vendor_lot_no_on_line);

	    l_progress	:= '085' ;

	    create_new_lot(p_new_lot_rec   	=> l_new_lot_rec,
	    		   p_organization_id 	=> l_org_id,
	    		   p_vendor_id	   	=> l_vendor_id,
	    		   p_vendor_site_id 	=> l_vendor_site_id,
	    		   p_from_unit_of_measure => l_unit_of_measure,
                           p_to_unit_of_measure => l_secondary_unit_of_measure,
                           p_type_factor    	=>  l_lot_secondary_quantity/l_lot_quantity,
                           p_rti_id		=> l_rti_id,
	    		   x_return_status 	=> x_return_status );

	    IF l_inv_debug =  1 THEN
       	    	 print_debug(' Create new lot status for transaction type '||l_transaction_type||' =>'||x_return_status, 1);
       	    END IF;

	    IF x_return_status <> 'S' THEN
	      	 RAISE FND_API.G_EXC_ERROR;
	    END IF;
   	END IF; -- IF p_new_lot = 'N'

   ELSIF (l_transaction_type IN ('CORRECT','RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER')) THEN

      IF (l_shipment_header_id IS NULL) OR (l_shipment_line_id IS NULL) THEN
   	  SELECT shipment_header_id, shipment_line_id
   	  INTO l_shipment_header_id , l_shipment_line_id
   	  FROM  rcv_transactions
   	  WHERE transaction_id = l_parent_transaction_id ;

      END IF;

      l_progress	:= '090' ;

      IF (l_transaction_type IN ('RETURN TO RECEIVING','RETURN TO VENDOR','RETURN TO CUSTOMER'))
          OR (l_transaction_type = 'CORRECT' AND l_rti_primary_qty < 0)  THEN

   	    IF p_new_lot = 'N' THEN
            	 l_progress	:= '100' ;
                 IF p_parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN
	   	    IF (p_grand_parent_txn_type = 'DELIVER') THEN
	   	    	IF l_inv_debug =  1 THEN
       	    		    print_debug(' Combination not possible trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		END IF;
	   	    -- this combination not possible.
	   	        RETURN;
	   	    ELSE

	   	        -- -ve correction to RTV,RTC means adding +ve quantity to RECEIVE
	   	        -- lots other than existing in RECEIVE can be specified.
	   	        -- validate the lots in case of RMA.

	   	    	IF l_source_document_code = 'RMA' THEN
	   	    	     l_progress	:= '101' ;
   	   		     opm_rma_valid_lot(p_oe_order_header_id	=> l_oe_order_header_id ,
	   			p_oe_order_line_id	=> l_oe_order_line_id,
	   			p_lot_no	 	=> l_lot_no,
	   			p_sublot_no	 	=> l_sublot_no,
	   			p_rti_id		=> l_rti_id,
	   			x_line_set_id 		=> l_line_set_id,
	   			x_oe_lot_quantity	=> l_oe_lot_quantity,
	   			x_return_status		=> x_return_status );


        		END IF; -- IF l_source_document_code = 'RMA' THEN

	   	        validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   				p_inventory_item_id => l_item_id,
   				p_organization_id => l_org_id,
   				p_trans_date => l_transaction_date,
   				p_rti_id     => l_rti_id,
   				x_return_status => x_return_status
   				);

	   	    	IF l_inv_debug =  1 THEN
       	    		    print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		END IF;

		        IF x_return_status <> 'S' THEN
	    		     RAISE fnd_api.g_exc_error;
		        END IF;

		        IF l_source_document_code = 'RMA' THEN
   	    		     l_progress	:= '102' ;

   	    		     validate_rma_quantity(p_opm_item_id => p_opm_item_id,
		                      p_lot_id 		        => l_lot_attribute_rec.lot_id,
		                      p_lot_no 		        => l_lot_no,
		                      p_sublot_no		=> l_sublot_no,
		                      p_oe_order_header_id      => l_oe_order_header_id,
		                      p_oe_order_line_id        => l_oe_order_line_id ,
		                      p_lot_qty 		=> l_lot_quantity ,
		                      p_unit_of_measure	        => l_unit_of_measure ,
		                      p_rma_lot_qty		=> l_oe_lot_quantity,
		                      p_rma_lot_uom 		=> NULL,
		                      p_line_set_id 		=> l_line_set_id,
		                      p_rti_id		        => l_rti_id,
		                      x_allowed 		=> l_allowed,
		                      x_allowed_quantity        => l_allowed_quantity,
	   			      x_return_status		=> x_return_status );

			     IF x_return_status <> 'S' THEN
	        		  RAISE FND_API.G_EXC_ERROR;
	    		     END IF;

	    		END IF; -- IF l_source_document_code = 'RMA'


		        -- validate/derive secondary quantity.
			l_progress	:= '103' ;

   			IF l_secondary_unit_of_measure IS NOT NULL THEN
           		    IF l_lot_secondary_quantity IS NULL THEN
                               	l_update_lot_qty := TRUE ;
                               END IF;

                               GML_ValidateDerive_GRP.Secondary_Qty
		                    ( p_api_version          => '1.0'
		                    , p_init_msg_list        => 'F'
		                    , p_validate_ind	     => 'Y'
		                    , p_item_no	 	     => p_item_no
		                    , p_lot_id		     => nvl(l_lot_attribute_rec.lot_id,0)
		                    , p_unit_of_measure      => l_unit_of_measure
		                    , p_secondary_unit_of_measure => l_secondary_unit_of_measure
		                    , p_quantity	 	 => l_lot_quantity
		                    , p_secondary_quantity   => l_lot_secondary_quantity
		                    , x_return_status        => x_return_status
		                    , x_msg_count            => x_msg_count
		                    , x_msg_data             => x_msg_data ) ;

	                       IF l_inv_debug =  1 THEN
       	                       	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       	                        	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       	                       END IF;

    	                       IF x_return_status <> 'S' THEN
	                           RAISE FND_API.G_EXC_ERROR;
    	                       END IF;

    	                       IF l_update_lot_qty THEN
    	                            update mtl_transaction_lots_temp
    	                            set    secondary_quantity  = l_lot_secondary_quantity
    	                            where  rowid = p_mtlt_rowid ;
    	                       END IF;
        		END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN
	   	    END IF ;
	   	 ELSIF p_parent_txn_type IN ('RETURN TO RECEIVING') THEN
	   	 	IF l_inv_debug =  1 THEN
       	    		    print_debug(' Combination not possible trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		END IF;
	   	 	-- this combination not possible.
	   	        RETURN;
	   	 ELSE
	   	 	l_progress	:= '110' ;
	   	 	validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   				p_inventory_item_id => l_item_id,
   				p_organization_id => l_org_id,
   				p_trans_date => l_transaction_date,
   				p_rti_id     => l_rti_id,
   				x_return_status => x_return_status
   				);

			IF l_inv_debug =  1 THEN
       	    		    print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		END IF;

		        IF x_return_status <> 'S' THEN
	    		    RAISE fnd_api.g_exc_error;
		        END IF;

		        -- validate/derive secondary quantity.
		        l_progress	:= '112' ;

   		        IF l_secondary_unit_of_measure IS NOT NULL THEN
        	           IF l_lot_secondary_quantity IS NULL THEN
        	           	l_update_lot_qty := TRUE ;
        	           END IF;

        	           GML_ValidateDerive_GRP.Secondary_Qty
		        	( p_api_version          => '1.0'
		        	, p_init_msg_list        => 'F'
		        	, p_validate_ind	 => 'Y'
		        	, p_item_no	 	 => p_item_no
		        	, p_lot_id		 => nvl(l_lot_attribute_rec.lot_id,0)
		        	, p_unit_of_measure 	 => l_unit_of_measure
		        	, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		        	, p_quantity	 	 => l_lot_quantity
		        	, p_secondary_quantity   => l_lot_secondary_quantity
		        	, x_return_status        => x_return_status
		        	, x_msg_count            => x_msg_count
		        	, x_msg_data             => x_msg_data ) ;

		           IF l_inv_debug =  1 THEN
       		           	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       		            	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       		           END IF;

    		           IF x_return_status <> 'S' THEN
		               RAISE FND_API.G_EXC_ERROR;
    		           END IF;

    		           IF l_update_lot_qty THEN
    		                update mtl_transaction_lots_temp
    		                set    secondary_quantity  = l_lot_secondary_quantity
    		                where  rowid = p_mtlt_rowid ;
    		           END IF;
        	        END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN

	   	 	IF p_parent_txn_type = 'DELIVER' THEN
	   	 	   -- to check if it is an OLD OPM RECEIPT(Common Purchasing)
	   	 	   BEGIN
			        select	rcv.comments
			        into	l_comment
			        from	rcv_transactions rcv
			        where	rcv.transaction_id = l_parent_transaction_id;

			   EXCEPTION
			 	WHEN OTHERS THEN
			    	l_comment := null;
			   END ;

			   l_progress	:= '120' ;

			   IF l_inv_debug =  1 THEN
       	    		    	print_debug('-ve correction Old/new receipt=>'||nvl(l_comment,'NEW RECEIPT'), 1);
       	    		   END IF;

			   BEGIN
			   IF nvl(l_comment,'NOT OPM RECEIPT') <> 'OPM RECEIPT' THEN
			   -- check the lot specified by the user is existing in the DELIVER transaction.
		    	       SELECT 'X' INTO l_temp
		    	       FROM   ic_tran_pnd itp
		    	       WHERE
     				    itp.doc_id = l_shipment_header_id
		    	       and  itp.line_id = l_parent_transaction_id
		    	       and  itp.doc_type = 'PORC'
		    	       and  itp.lot_id = p_lot_id ;

		    	   ELSE
		    	       SELECT 'X' INTO l_temp
			       FROM   rcv_transactions rcv,gml_recv_trans_map grm,ic_tran_pnd itp
			       WHERE  rcv.transaction_id = l_parent_transaction_id
				and   rcv.interface_transaction_id = grm.interface_transaction_id
				and   grm.recv_id  = itp.doc_id
				and   itp.doc_type = 'RECV'
				and   grm.line_id  = itp.line_id
			        and   itp.lot_id   = p_lot_id ;

		    	   END IF;

		    	   EXCEPTION WHEN NO_DATA_FOUND THEN
		    	   	IF l_inv_debug =  1 THEN
       	    		    	    print_debug(' Lot does not exist for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    			END IF;
       	    			FND_MESSAGE.SET_NAME('GML','GML_RECV_INVALID_LOT');
       	    			FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
       	    			FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_sublot_no);
        			FND_MSG_PUB.Add;
     				x_return_status  := fnd_api.g_ret_sts_error;
     				RAISE FND_API.G_EXC_ERROR;
		    	   END ;

                    	   l_progress	:= '130' ;

		    	-- check that return quantity cannot be greater than received quantity.
		      	   -- find total net quantity received against the lot

		    	   IF nvl(l_comment,'NOT OPM RECEIPT') <> 'OPM RECEIPT' THEN

		    	       Open 	Cr_get_total_qty_available;
			       Fetch	Cr_get_total_qty_available into l_net_received_lot_qty;
			       Close 	Cr_get_total_qty_available;

			       IF l_lot_primary_quantity > l_net_received_lot_qty THEN
			       	    IF l_inv_debug =  1 THEN
       	    		    		print_debug(' Qty more than received for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    			    END IF;
			    	    FND_MESSAGE.SET_NAME('GML', 'PO_RETURN_MORE_RECEIVE');
		        	    FND_MESSAGE.SET_TOKEN('AVAILABLE_QTY',l_net_received_lot_qty);
				    FND_MSG_PUB.Add;
     				    x_return_status  := fnd_api.g_ret_sts_error;
     				    RAISE FND_API.G_EXC_ERROR;
			       END IF;

			    ELSE
			    		/*Total received quantity for that lot*/
			        Open	Cr_old_recv_qty;
			        Fetch	Cr_old_recv_qty into l_old_recv_qty,l_recv_id,l_recvline_id;
			        Close	Cr_old_recv_qty;

			        /*Total return quantity for that lot*/
			        Open 	Cr_old_rtrn_qty;
			        Fetch	Cr_old_rtrn_qty into l_old_rtrn_qty;
			        Close 	Cr_old_rtrn_qty;

			        /*Corrections and Returns done using common receiving for that lot*/
			        Open 	Cr_get_total_qty_available;
			        Fetch	Cr_get_total_qty_available into l_cr_avaliable_qty;
			        Close 	Cr_get_total_qty_available;

			        IF  (nvl(l_old_recv_qty,0) - nvl(l_old_rtrn_qty,0) + nvl(l_cr_avaliable_qty,0)) < l_lot_primary_quantity THEN
			             FND_MESSAGE.SET_NAME('GML', 'PO_RETURN_MORE_RECEIVE');
			             FND_MESSAGE.SET_TOKEN('AVAILABLE_QTY',nvl(l_old_recv_qty,0) - nvl(l_old_rtrn_qty,0) + nvl(l_cr_avaliable_qty,0));
				     FND_MSG_PUB.Add;
     				     x_return_status  := fnd_api.g_ret_sts_error;
     				     RAISE FND_API.G_EXC_ERROR;
			        END IF;

			    END IF; -- IF nvl(l_comment,'NOT OPM RECEIPT') <> 'OPM RECEIPT' THEN

			    l_progress	:= '140' ;

			    -- for -ve corrections and returns to a DELIVER transaction
			    -- take from_locator_id - source location.
			    -- to_locator_id - destination location.
			    -- in the above case ,source location is DELIVER and destination is RECEIVE.
			    l_locator_id := l_from_locator_id ;
			    -- check for onhand quantity in the inventory
			    validate_quantity_onhand(p_lot_id 		=> p_lot_id,
			    			p_rti_id		=> l_rti_id,
			    	                p_opm_item_id		=> p_opm_item_id,
				                p_organization_id	=> l_org_id,
				                p_locator_id		=> l_locator_id,
				                p_primary_quantity	=> l_lot_primary_quantity,
				                x_return_status		=> x_return_status );

			    IF l_inv_debug =  1 THEN
       	    		    	print_debug(' validate_quantity_onhand status for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		    END IF;

			    IF x_return_status NOT IN ('S','W') THEN
	    			RAISE fnd_api.g_exc_error;
		    	    END IF;

--Bug# 3664014 -- insert record in po_interface_error in case of warning.

		    	    IF x_return_status = 'W' THEN
		    	         insert_errors(p_rti_id		=> l_rti_id,
		  			  p_group_id		=> NULL,
		  			  p_header_interface_id	=> NULL,
		  			  p_column_name		=> 'TRANSACTION_QUANTITY',
                  			  p_table_name          => 'MTL_TRANSACTION_LOTS_INTERFACE',
		  			  p_error_message 	=> FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F'),
                  			  p_mesg_owner		=> NULL,
                  			  p_error_message_name  => NULL );

                  		-- reset warning to success otherwise ROI c routine will fail the transaction
				 x_return_status  := 'S';
                            END IF;

			END IF; -- IF p_parent_txn_type = 'DELIVER' THEN

	   	   END IF; -- IF p_parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN

	       ELSE -- new lot
	       	    IF p_parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER') THEN
	       	    	l_progress	:= '150' ;
	   	   	IF (p_grand_parent_txn_type = 'DELIVER') THEN
	   	   	     IF l_inv_debug =  1 THEN
       	    		          print_debug(' Combination not possible trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		     END IF;
	   	    	     -- this combination not possible.
	   	             RETURN;
	   	    	ELSE

	   	    	     IF l_source_document_code = 'RMA' THEN
	   	    	     	l_progress	:= '151' ;
   	   		     	opm_rma_valid_lot(p_oe_order_header_id	=> l_oe_order_header_id ,
	   				p_oe_order_line_id	=> l_oe_order_line_id,
	   				p_lot_no	 	=> l_lot_no,
	   				p_sublot_no	 	=> l_sublot_no,
	   				p_rti_id		=> l_rti_id,
	   				x_line_set_id 		=> l_line_set_id,
	   				x_oe_lot_quantity	=> l_oe_lot_quantity,
	   			        x_return_status		=> x_return_status );

   			     END IF; -- IF l_source_document_code = 'RMA' THEN

	   	    	    -- this is only possible for a -ve correction.
	   	    	    -- doing -ve correction to RTV , RTC  means adding to RECEIVING
	   	    	    -- so new lots can be created.

	   	    		-- it is a new lot. create it.
	   	             validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   					p_inventory_item_id => l_item_id,
   					p_organization_id => l_org_id,
   					p_trans_date => l_transaction_date,
   					p_rti_id     => l_rti_id,
   					x_return_status => x_return_status
   					);

			     IF l_inv_debug =  1 THEN
       	    		     	 print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		     END IF;

		             IF x_return_status <> 'S' THEN
	    		         RAISE fnd_api.g_exc_error;
		             END IF;

		             IF l_source_document_code = 'RMA' THEN
   	    		     	l_progress	:= '152' ;

   	    		        validate_rma_quantity(p_opm_item_id => p_opm_item_id,
		                      p_lot_id 		        => l_lot_attribute_rec.lot_id,
		                      p_lot_no 		        => l_lot_no,
		                      p_sublot_no		=> l_sublot_no,
		                      p_oe_order_header_id      => l_oe_order_header_id,
		                      p_oe_order_line_id        => l_oe_order_line_id ,
		                      p_lot_qty 		=> l_lot_quantity ,
		                      p_unit_of_measure	        => l_unit_of_measure ,
		                      p_rma_lot_qty		=> l_oe_lot_quantity,
		                      p_rma_lot_uom 		=> NULL,
		                      p_line_set_id 		=> l_line_set_id,
		                      p_rti_id		        => l_rti_id,
		                      x_allowed 		=> l_allowed,
		                      x_allowed_quantity        => l_allowed_quantity,
	   			      x_return_status		=> x_return_status );

	   			IF x_return_status <> 'S' THEN
	        		    RAISE FND_API.G_EXC_ERROR;
	    		        END IF;

	    		     END IF; -- IF l_source_document_code = 'RMA'

		             -- validate/derive secondary quantity.
		             l_progress	:= '155' ;

   		             IF l_secondary_unit_of_measure IS NOT NULL THEN
        	                IF l_lot_secondary_quantity IS NULL THEN
        	                	l_update_lot_qty := TRUE ;
        	                END IF;

        	                GML_ValidateDerive_GRP.Secondary_Qty
		             	( p_api_version          => '1.0'
		             	, p_init_msg_list        => 'F'
		             	, p_validate_ind	 => 'Y'
		             	, p_item_no	 	 => p_item_no
		             	, p_unit_of_measure 	 => l_unit_of_measure
		             	, p_lot_id		 => 0
		             	, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		             	, p_quantity	 	 => l_lot_quantity
		             	, p_secondary_quantity   => l_lot_secondary_quantity
		             	, x_return_status        => x_return_status
		             	, x_msg_count            => x_msg_count
		             	, x_msg_data             => x_msg_data ) ;

		                IF l_inv_debug =  1 THEN
       		                	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       		                 	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       		                END IF;

    		                IF x_return_status <> 'S' THEN
		                    RAISE FND_API.G_EXC_ERROR;
    		                END IF;

    		                IF l_update_lot_qty THEN
    		                     update mtl_transaction_lots_temp
    		                     set    secondary_quantity  = l_lot_secondary_quantity
    		                     where  rowid = p_mtlt_rowid ;
    		                END IF;
        	             END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN

		             l_new_lot_rec.item_no		:= p_item_no ;
   	    		     l_new_lot_rec.lot_no  		:= l_lot_no;
   	    		     l_new_lot_rec.sublot_no 		:= l_sublot_no;
   	    		     l_new_lot_rec.expire_date		:= l_lot_attribute_rec.expiration_date;
   	    		     l_new_lot_rec.lot_desc		:= l_lot_desc ;
	    		     l_new_lot_rec.qc_grade        	:= NULL ;
	    		     l_new_lot_rec.lot_created		:= l_transaction_date;
	    		     l_new_lot_rec.origination_type	:= 3;
	    		     l_new_lot_rec.vendor_lot_no	:= nvl(l_vendor_lot_no_on_lot,l_vendor_lot_no_on_line);

	    		     l_progress	:= '160' ;

	    		     create_new_lot(p_new_lot_rec  	=> l_new_lot_rec,
	    		               p_organization_id 	=> l_org_id,
	    		               p_vendor_id	   	=> l_vendor_id,
	    		               p_vendor_site_id 	=> l_vendor_site_id,
	    		               p_from_unit_of_measure 	=> l_unit_of_measure,
                                       p_to_unit_of_measure 	=> l_secondary_unit_of_measure,
                                       p_type_factor    	=>  l_lot_secondary_quantity/l_lot_quantity,
                                       p_rti_id			=> l_rti_id,
	    		               x_return_status 	=> x_return_status );

			     IF l_inv_debug =  1 THEN
       	    		    	print_debug('Create_new_lot status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		     END IF;

	                     IF x_return_status <> 'S' THEN
	      	 	         RAISE FND_API.G_EXC_ERROR;
	    		     END IF;
	    		 END IF ;
	   	    ELSIF p_parent_txn_type IN ('RETURN TO RECEIVING') THEN
	   	    	l_progress	:= '170' ;
 		   	IF l_inv_debug =  1 THEN
       	    		    print_debug(' Combination not possible trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		END IF;

	   	 	-- this combination not possible.
	   	        RETURN;
	   	    ELSE
			 IF l_inv_debug =  1 THEN
       	    		    print_debug(' WMS errors out for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		 END IF;
			 -- wms will error out in this condition.
			 -- new lots cannot be created for -ve correction and returns to RECEIVE/DELIVER transactions.

			 FND_MESSAGE.SET_NAME('GML','GML_RECV_INVALID_LOT');
       	    		 FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
       	    		 FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_sublot_no);
        		 FND_MSG_PUB.Add;
     			 x_return_status  := fnd_api.g_ret_sts_error;
     			 RAISE FND_API.G_EXC_ERROR;

	   	    END IF ;
	    END IF; -- IF p_new_lot = 'N' THEN

	ELSIF (l_transaction_type = 'CORRECT' AND l_rti_primary_qty > 0) THEN
	    IF p_parent_txn_type IN ('RETURN TO VENDOR','RETURN TO CUSTOMER','RETURN TO RECEIVING') THEN
	    	 l_progress	:= '180' ;
	   	 IF (p_grand_parent_txn_type = 'DELIVER') THEN
	   	      IF l_inv_debug =  1 THEN
       	    		    print_debug(' Combination not possible trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    	      END IF;
	   	    -- this combination not possible.
	   	      RETURN;
	   	 ELSE


	   	      validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   				p_inventory_item_id => l_item_id,
   				p_organization_id => l_org_id,
   				p_trans_date => l_transaction_date,
   				p_rti_id     => l_rti_id,
   				x_return_status => x_return_status
   				);

     		      IF l_inv_debug =  1 THEN
       	    		     print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    	      END IF;

		      IF x_return_status <> 'S' THEN
	    	          RAISE fnd_api.g_exc_error;
		      END IF;

		      -- validate/derive secondary quantity.
		      l_progress	:= '181' ;

   		      IF l_secondary_unit_of_measure IS NOT NULL THEN
        	         IF l_lot_secondary_quantity IS NULL THEN
        	         	l_update_lot_qty := TRUE ;
        	         END IF;

        	         GML_ValidateDerive_GRP.Secondary_Qty
		      	( p_api_version          => '1.0'
		      	, p_init_msg_list        => 'F'
		      	, p_validate_ind	 => 'Y'
		      	, p_item_no	 	 => p_item_no
		      	, p_unit_of_measure 	 => l_unit_of_measure
		      	, p_lot_id		 => nvl(l_lot_attribute_rec.lot_id,0)
		      	, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		      	, p_quantity	 	 => l_lot_quantity
		      	, p_secondary_quantity   => l_lot_secondary_quantity
		      	, x_return_status        => x_return_status
		      	, x_msg_count            => x_msg_count
		      	, x_msg_data             => x_msg_data ) ;

		         IF l_inv_debug =  1 THEN
       		         	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       		          	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       		         END IF;

    		         IF x_return_status <> 'S' THEN
		             RAISE FND_API.G_EXC_ERROR;
    		         END IF;

    		         IF l_update_lot_qty THEN
    		              update mtl_transaction_lots_temp
    		              set    secondary_quantity  = l_lot_secondary_quantity
    		              where  rowid = p_mtlt_rowid ;
    		         END IF;
        	      END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN
	   	 END IF ; -- IF (p_grand_parent_txn_type = 'DELIVER') THEN
	    ELSE
	    	IF p_new_lot = 'N' THEN
	    	     l_progress	:= '190' ;

	    	     IF l_source_document_code = 'RMA' THEN
	   	    	     l_progress	:= '191' ;

   	   		     opm_rma_valid_lot(p_oe_order_header_id	=> l_oe_order_header_id ,
	   			p_oe_order_line_id	=> l_oe_order_line_id,
	   			p_lot_no	 	=> l_lot_no,
	   			p_sublot_no	 	=> l_sublot_no,
	   			p_rti_id		=> l_rti_id,
	   			x_line_set_id 		=> l_line_set_id,
	   			x_oe_lot_quantity	=> l_oe_lot_quantity,
	   			x_return_status		=> x_return_status );

   		     END IF; -- IF l_source_document_code = 'RMA' THEN

	    	     validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   				p_inventory_item_id => l_item_id,
   				p_organization_id => l_org_id,
   				p_trans_date => l_transaction_date,
   				p_rti_id     => l_rti_id,
   				x_return_status => x_return_status
   				);

		     IF l_inv_debug =  1 THEN
       	    		     print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    	     END IF;

		     IF x_return_status <> 'S' THEN
	    	          RAISE fnd_api.g_exc_error;
		     END IF;

		     IF l_source_document_code = 'RMA' THEN
   	    		  l_progress	:= '192' ;

   	    		  validate_rma_quantity(p_opm_item_id => p_opm_item_id,
		                   p_lot_id 		=> l_lot_attribute_rec.lot_id,
		                   p_lot_no 		=> l_lot_no,
		                   p_sublot_no		=> l_sublot_no,
		                   p_oe_order_header_id => l_oe_order_header_id,
		                   p_oe_order_line_id   => l_oe_order_line_id ,
		                   p_lot_qty 		=> l_lot_quantity ,
		                   p_unit_of_measure	=> l_unit_of_measure ,
		                   p_rma_lot_qty	=> l_oe_lot_quantity,
		                   p_rma_lot_uom 	=> NULL,
		                   p_line_set_id 	=> l_line_set_id,
		                   p_rti_id		=> l_rti_id,
		                   x_allowed 		=> l_allowed,
		                   x_allowed_quantity   => l_allowed_quantity,
	   			   x_return_status	=> x_return_status );

	   		  IF x_return_status <> 'S' THEN
	        	      RAISE FND_API.G_EXC_ERROR;
	    		  END IF;
	    	     END IF; -- IF l_source_document_code = 'RMA'

		     -- validate/derive secondary quantity.
		     l_progress	:= '195' ;

   		     IF l_secondary_unit_of_measure IS NOT NULL THEN
        	        IF l_lot_secondary_quantity IS NULL THEN
        	        	l_update_lot_qty := TRUE ;
        	        END IF;

        	        GML_ValidateDerive_GRP.Secondary_Qty
		     	( p_api_version          => '1.0'
		     	, p_init_msg_list        => 'F'
		     	, p_validate_ind	 => 'Y'
		     	, p_item_no	 	 => p_item_no
		     	, p_unit_of_measure 	 => l_unit_of_measure
		     	, p_lot_id		 => nvl(l_lot_attribute_rec.lot_id,0)
		     	, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		     	, p_quantity	 	 => l_lot_quantity
		     	, p_secondary_quantity   => l_lot_secondary_quantity
		     	, x_return_status        => x_return_status
		     	, x_msg_count            => x_msg_count
		     	, x_msg_data             => x_msg_data ) ;

		        IF l_inv_debug =  1 THEN
       		        	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       		         	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       		        END IF;

    		        IF x_return_status <> 'S' THEN
		            RAISE FND_API.G_EXC_ERROR;
    		        END IF;

    		        IF l_update_lot_qty THEN
    		             update mtl_transaction_lots_temp
    		             set    secondary_quantity  = l_lot_secondary_quantity
    		             where  rowid = p_mtlt_rowid ;
    		        END IF;
        	     END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN

		-- for correction to deliver transaction,lot specified must be same as in deliver transaction.
	    	     IF p_parent_txn_type = 'DELIVER' THEN
	    	     	   l_progress	:= '200' ;
	   	 	   -- to check if it is an OLD OPM RECEIPT(Common Purchasing)
	   	 	   BEGIN
			        select	rcv.comments
			        into	l_comment
			        from	rcv_transactions rcv
			        where	rcv.transaction_id = l_parent_transaction_id;

			   EXCEPTION
			 	WHEN OTHERS THEN
			    	l_comment := null;
			   END ;

			   IF l_inv_debug =  1 THEN
       	    		    	print_debug('+ve correction Old/new receipt=>'||l_comment, 1);
       	    		   END IF;

			   BEGIN
			   IF nvl(l_comment,'NOT OPM RECEIPT') <> 'OPM RECEIPT' THEN
			   -- check the lot specified by the user is existing in the DELIVER transaction.
		    	       SELECT 'X' INTO l_temp
		    	       FROM   ic_tran_pnd itp
		    	       WHERE
     				    itp.doc_id = l_shipment_header_id
		    	       and  itp.line_id = l_parent_transaction_id
		    	       and  itp.doc_type = 'PORC'
		    	       and  itp.lot_id = p_lot_id ;

		    	   ELSE
		    	       SELECT 'X' INTO l_temp
			       FROM   rcv_transactions rcv,gml_recv_trans_map grm,ic_tran_pnd itp
			       WHERE  rcv.transaction_id = l_parent_transaction_id
				and   rcv.interface_transaction_id = grm.interface_transaction_id
				and   grm.recv_id  = itp.doc_id
				and   itp.doc_type = 'RECV'
				and   grm.line_id  = itp.line_id
			        and   itp.lot_id   = p_lot_id ;

		    	   END IF;

		    	   EXCEPTION WHEN NO_DATA_FOUND THEN
		    	        IF l_inv_debug =  1 THEN
       	    		    	    print_debug(' Lot does not exist for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    			END IF;
		    	       	FND_MESSAGE.SET_NAME('GML','GML_RECV_INVALID_LOT');
       	    			FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
       	    			FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_sublot_no);
        			FND_MSG_PUB.Add;
     				x_return_status  := fnd_api.g_ret_sts_error;
     				RAISE FND_API.G_EXC_ERROR;
		    	   END ;
		    	   l_progress	:= '210' ;
		      END IF ; -- IF p_parent_txn_type = 'DELIVER'

	    	ELSE -- IF p_new_lot = 'N' THEN
	    		l_progress	:= '220' ;

	    		IF p_parent_txn_type = 'DELIVER' THEN
	    		     IF l_inv_debug =  1 THEN
       	    		          print_debug(' new lots not allowed for trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type, 1);
       	    		     END IF;
       	    		     -- new lots not allowed for correction to deliver transaction.
       	    		     FND_MESSAGE.SET_NAME('GML','GML_RECV_INVALID_LOT');
       	    		     FND_MESSAGE.SET_TOKEN('LOT_NO',l_lot_no);
       	    		     FND_MESSAGE.SET_TOKEN('SUBLOT_NO',l_sublot_no);
        		     FND_MSG_PUB.Add;
     			     x_return_status  := fnd_api.g_ret_sts_error;
     			     RAISE FND_API.G_EXC_ERROR;
	    		END IF;

	    		IF l_source_document_code = 'RMA' THEN
	   	    	     l_progress	:= '221' ;

   	   		     opm_rma_valid_lot(p_oe_order_header_id	=> l_oe_order_header_id ,
	   			p_oe_order_line_id	=> l_oe_order_line_id,
	   			p_lot_no	 	=> l_lot_no,
	   			p_sublot_no	 	=> l_sublot_no,
	   			p_rti_id		=> l_rti_id,
	   			x_line_set_id 		=> l_line_set_id,
	   			x_oe_lot_quantity	=> l_oe_lot_quantity,
	   			x_return_status		=> x_return_status );

   		        END IF; -- IF l_source_document_code = 'RMA' THEN

		        -- it is a new lot. create it.
	   	        validate_lot_attributes(p_lot_attribute_rec => l_lot_attribute_rec,
   					p_inventory_item_id => l_item_id,
   					p_organization_id => l_org_id,
   					p_trans_date => l_transaction_date,
   					p_rti_id     => l_rti_id,
   					x_return_status => x_return_status
   					);

			 IF l_inv_debug =  1 THEN
       	    		 	 print_debug(' Validate lot attributes status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		 END IF;

		         IF x_return_status <> 'S' THEN
	    		     RAISE fnd_api.g_exc_error;
		         END IF;

		         IF l_source_document_code = 'RMA' THEN
   	    		     l_progress	:= '223' ;

   	    		     validate_rma_quantity(p_opm_item_id => p_opm_item_id,
		                      p_lot_id 		        => l_lot_attribute_rec.lot_id,
		                      p_lot_no 		        => l_lot_no,
		                      p_sublot_no		=> l_sublot_no,
		                      p_oe_order_header_id      => l_oe_order_header_id,
		                      p_oe_order_line_id        => l_oe_order_line_id ,
		                      p_lot_qty 		=> l_lot_quantity ,
		                      p_unit_of_measure	        => l_unit_of_measure ,
		                      p_rma_lot_qty		=> l_oe_lot_quantity,
		                      p_rma_lot_uom 		=> NULL,
		                      p_line_set_id 		=> l_line_set_id,
		                      p_rti_id		        => l_rti_id,
		                      x_allowed 		=> l_allowed,
		                      x_allowed_quantity        => l_allowed_quantity,
	   			      x_return_status		=> x_return_status );

	   		     IF x_return_status <> 'S' THEN
	        		  RAISE FND_API.G_EXC_ERROR;
	    		     END IF;

	    		 END IF; -- IF l_source_document_code = 'RMA'

		         -- validate/derive secondary quantity.
		         l_progress	:= '225' ;

   		         IF l_secondary_unit_of_measure IS NOT NULL THEN
        	            IF l_lot_secondary_quantity IS NULL THEN
        	            	l_update_lot_qty := TRUE ;
        	            END IF;

        	            GML_ValidateDerive_GRP.Secondary_Qty
		         	( p_api_version          => '1.0'
		         	, p_init_msg_list        => 'F'
		         	, p_validate_ind	 => 'Y'
		         	, p_item_no	 	 => p_item_no
		         	, p_unit_of_measure 	 => l_unit_of_measure
		         	, p_lot_id		 => 0
		         	, p_secondary_unit_of_measure => l_secondary_unit_of_measure
		         	, p_quantity	 	 => l_lot_quantity
		         	, p_secondary_quantity   => l_lot_secondary_quantity
		         	, x_return_status        => x_return_status
		         	, x_msg_count            => x_msg_count
		         	, x_msg_data             => x_msg_data ) ;

		            IF l_inv_debug =  1 THEN
       		            	print_debug('Validate Secondary qty  status trx_type=>'||l_transaction_type||'-'||x_return_status, 1);
       		             	print_debug('Secondary qty=>'||l_lot_secondary_quantity, 1);
       		            END IF;

    		            IF x_return_status <> 'S' THEN
		                RAISE FND_API.G_EXC_ERROR;
    		            END IF;

    		            IF l_update_lot_qty THEN
    		                 update mtl_transaction_lots_temp
    		                 set    secondary_quantity  = l_lot_secondary_quantity
    		                 where  rowid = p_mtlt_rowid ;
    		            END IF;
        	         END IF; -- IF l_secondary_unit_of_measure IS NOT NULL THEN

		         l_progress	:= '230' ;

		         l_new_lot_rec.item_no		:= p_item_no ;
   	    		 l_new_lot_rec.lot_no  		:= l_lot_no;
   	    		 l_new_lot_rec.sublot_no 	:= l_sublot_no;
   	    		 l_new_lot_rec.expire_date	:= l_lot_attribute_rec.expiration_date;
   	    		 l_new_lot_rec.lot_desc		:= l_lot_desc ;
	    		 l_new_lot_rec.qc_grade        	:= NULL ;
	    		 l_new_lot_rec.lot_created	:= l_transaction_date;
	    		 l_new_lot_rec.origination_type	:= 3;
	    		 l_new_lot_rec.vendor_lot_no	:= nvl(l_vendor_lot_no_on_lot,l_vendor_lot_no_on_line);

	    		 create_new_lot(p_new_lot_rec  	=> l_new_lot_rec,
	    		               p_organization_id 	=> l_org_id,
	    		               p_vendor_id	   	=> l_vendor_id,
	    		               p_vendor_site_id 	=> l_vendor_site_id,
	    		               p_from_unit_of_measure 	=> l_unit_of_measure,
                                       p_to_unit_of_measure 	=> l_secondary_unit_of_measure,
                                       p_type_factor    	=>  l_lot_secondary_quantity/l_lot_quantity,
                                       p_rti_id			=> l_rti_id,
	    		               x_return_status 	=> x_return_status );

			 IF l_inv_debug =  1 THEN
       	    		     	 print_debug(' Create_new_lot status trx_type,parent_trx_type,grand_parent_trx_type=>'||l_transaction_type||'-'||p_parent_txn_type||'-'||p_grand_parent_txn_type||'-'||x_return_status, 1);
       	    		 END IF;

	                 IF x_return_status <> 'S' THEN
	      	 	     RAISE FND_API.G_EXC_ERROR;
	    		 END IF;
	    	END IF; -- IF p_new_lot = 'N'
	    END IF;
	END IF; -- ELSIF (l_transaction_type = 'CORRECT' AND l_rti_primary_qty > 0) THEN
    END IF; -- IF (l_transaction_type IN ('RECEIVE'


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status  := fnd_api.g_ret_sts_error;
    insert_errors(p_rti_id		=> l_rti_id,
		  p_group_id		=> NULL,
		  p_header_interface_id	=> NULL,
		  p_column_name		=> NULL,
                  p_table_name           => 'MTL_TRANSACTION_LOTS_INTERFACE',
		  p_error_message 	=> FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F'),
                  p_mesg_owner		=> NULL,
                  p_Error_Message_name   => NULL );

    IF l_inv_debug =  1 THEN
         print_debug(' Main exception in validate_opm_lot'||l_progress||'-'||substr(FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,p_encoded => 'F'),1,100), 1);
    END IF;
    fnd_msg_pub.count_and_get(p_count  => x_msg_count, p_data   => x_msg_data);

WHEN OTHERS THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   insert_errors(  p_rti_id		=>  l_rti_id,
		   p_group_id		=>  null,
	 	   p_header_interface_id => null,
		   p_column_name	=>  null,
                   p_table_name         => 'MTL_TRANSACTION_LOTS_INTERFACE',
		   p_error_message 	=> 'UNHANDLED EXCEPTION IN VALIDATE_OPM_LOT :' || l_progress||'-' ||
		 				substr(sqlerrm,1,1000),
                   p_mesg_owner		=> NULL,
                   p_Error_Message_name   => NULL);
   IF l_inv_debug =  1 THEN
         print_debug('Unhandled exception in validate_opm_lot'||l_progress||'-'||substr(sqlerrm,1,100), 1);
   END IF;
   fnd_msg_pub.count_and_get(  p_count  => x_msg_count, p_data   => x_msg_data);
END validate_opm_lot;

END GML_OPM_ROI_GRP ;

/
