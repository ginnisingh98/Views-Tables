--------------------------------------------------------
--  DDL for Package Body WSH_SC_DEL_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SC_DEL_LINES_PVT" as
/* $Header: WSHSDLNB.pls 115.4 99/07/16 08:21:17 porting ship $ */


  -- routine to unassign the delivery line from the delivery
  -- parameter pld_id is picking_line_detail_id
  FUNCTION unassign_delivery_line( pld_id		IN NUMBER,
				   original_detail_id	IN NUMBER,
				   del_id		IN NUMBER,
				   so_reservations	IN VARCHAR2)
  RETURN BOOLEAN IS
    cannot_transfer		EXCEPTION;
    online_no_manager		EXCEPTION;
    online_error		EXCEPTION;
    ret_val			NUMBER := 0;
    success		        BOOLEAN;
    outcome              	VARCHAR2(30);
    message           		VARCHAR2(128);
    a1                		VARCHAR2(80);
    a2                		VARCHAR2(30);
    a3                		VARCHAR2(30);
    a4                		VARCHAR2(30);
    a5                		VARCHAR2(30);
    a6                		VARCHAR2(30);
    a7                		VARCHAR2(30);
    a8                		VARCHAR2(30);
    a9                		VARCHAR2(30);
    a10               		VARCHAR2(30);
    a11               		VARCHAR2(30);
    a12               		VARCHAR2(30);
    a13               		VARCHAR2(30);
    a14               		VARCHAR2(30);
    a15               		VARCHAR2(30);
    a16               		VARCHAR2(30);
    a17               		VARCHAR2(30);
    a18               		VARCHAR2(30);
    a19               		VARCHAR2(30);
    a20               		VARCHAR2(30);
    CURSOR c1( pld_id  	IN NUMBER) IS
      SELECT REQUESTED_QUANTITY
      FROM so_picking_line_details
      WHERE picking_line_detail_id = pld_id;
    transfer_qty		NUMBER;
  BEGIN

    IF (( original_detail_id > 0) AND
        ( so_reservations = 'Y')) THEN
      -- call transaction manager for demand / reservation transfer
      -- The transfer routine need to update so_picking_line_details
      -- and delete rows from so_freight_charges also.
      -- but we raise a exception for now

      transfer_qty := 0;
      OPEN c1( pld_id);
      FETCH c1 INTO transfer_qty;
      CLOSE c1;
      ret_val := Fnd_Transaction.synchronous( 1000,
                                   outcome,
                                   message,
                                   'OE',
                                   'WSHURTF',
                                   TO_CHAR(original_detail_id),
                                   TO_CHAR(pld_id),
				   TO_CHAR(transfer_qty),
				   TO_CHAR(del_id));
      If (ret_val = 2) then
        RAISE online_no_manager;
      elsif (ret_val <> 0) then
        RAISE online_error;
      else
        if (message = 'FAILURE') then
          RAISE cannot_transfer;
        end if;
      END IF;
    ELSE

      UPDATE so_picking_line_details
      SET delivery_id = NULL,
          departure_id = NULL,
          shipped_quantity = NULL,
	  dpw_assigned_flag = 'N',
          load_seq_number = NULL
  --	  transaction_temp_id = NULL
      WHERE picking_line_detail_id = pld_id;

      DELETE FROM so_freight_charges
      WHERE delivery_id = del_id
      AND picking_line_detail_id = pld_id;

      COMMIT;
    END IF;

    RETURN TRUE;
  EXCEPTION
    WHEN online_no_manager THEN
      FND_MESSAGE.SET_NAME('OE','SHP_ONLINE_NO_MANAGER');
      RETURN FALSE;
    WHEN online_error THEN
      FND_MESSAGE.SET_NAME('OE','SHP_AOL_ONLINE_FAILED');
      FND_MESSAGE.SET_TOKEN('PROGRAM', 'WSHURTF');
      RETURN FALSE;
    WHEN cannot_transfer THEN
       ret_val := Fnd_Transaction.get_values( a1, a2, a3, a4, a5, a6,
                               a7, a8, a9, a10, a11, a12, a13, a14,
                               a15, a16, a17, a18, a19, a20);
      FND_MESSAGE.Set_Name('OE','WSH_SC_CANNOT_TRANSFER_PLD');
      FND_MESSAGE.Set_Token('PLD_ID', TO_CHAR(pld_id));
      FND_MESSAGE.Set_Token('REASON', a1);
      RETURN FALSE;
    WHEN others THEN
      ROLLBACK TO before_unassign;
      WSH_UTIL.Default_Handler('WSH_SC_DEL_LINES.unassign_delivery_line',SQLERRM);
  END unassign_delivery_line;

  FUNCTION Trx_Id(
			X_Mode		    IN     VARCHAR2,
			X_Pk_Hdr_Id 	    IN     NUMBER,
			X_Pk_Line_Id	    IN     NUMBER,
			X_Order_Category    IN     VARCHAR2
                       )
  RETURN NUMBER
  IS
    X_Stmt_Num 		NUMBER;
    X_Dest_Type		VARCHAR2(25);
    X_From_Org		NUMBER;
    X_To_Org		NUMBER;
  BEGIN
	X_Stmt_Num := 100;
	If (X_Order_Category = 'R') then
	  If (X_Mode = 'TRX_ACTION_ID') then
	  	Return(1); /* 1 = Issue */
	  Elsif (X_Mode = 'TRX_TYPE_ID') then
		Return(33); /* 33 = Sales Order Issue */
 	  End If;
	Elsif (X_Order_Category = 'P') then
     	  SELECT nvl(destination_type_code,'@'),source_organization_id,
           destination_organization_id
	  INTO X_Dest_Type,X_From_Org,X_To_Org
    	  FROM   po_requisition_lines_all pl,po_requisition_headers_all ph,
           po_req_distributions_all pd,so_lines_all sol,so_headers_all soh,
	   so_picking_lines_all pkl,so_picking_headers_all pkh
    	  WHERE pl.line_num = to_number(sol.original_system_line_reference)
    	  AND pl.requisition_header_id = ph.requisition_header_id
    	  AND pd.requisition_line_id = pl.requisition_line_id
    	  AND ph.segment1 = soh.original_system_reference
     	  AND soh.header_id = pkh.order_header_id
    	  AND sol.line_id = pkl.order_line_id
    	  AND pkh.picking_header_id = X_Pk_Hdr_Id
    	  AND pkl.picking_line_id = X_Pk_Line_Id;

	   If (X_Mode = 'TRX_TYPE_ID') then
	   	If (X_Dest_Type = 'EXPENSE') then
			Return(34); /* 34 = Stores Issue */
	   	Elsif (X_From_Org = X_To_Org) then
			Return(50); /* 50 = */
	   	Elsif (X_From_Org <> X_To_Org) then
			Return(62); /* 62 = Transit Shipment */
        	End If;
	   Elsif (X_Mode = 'TRX_ACTION_ID') then
	   	If (X_Dest_Type = 'EXPENSE') then
			Return(1); /* 1 = Issue */
	   	Elsif (X_From_Org = X_To_Org) then
			Return(2); /* 2 = Subinv transfer*/
	   	Elsif (X_From_Org <> X_To_Org) then
			Return(21); /* 62 = Interorg Transfer */
        	End If;
	   End If;
	End If;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	Return(0);
    WHEN OTHERS THEN
	Return(0);
  END;

END WSH_SC_DEL_LINES_PVT;

/
