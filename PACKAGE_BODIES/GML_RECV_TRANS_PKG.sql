--------------------------------------------------------
--  DDL for Package Body GML_RECV_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_RECV_TRANS_PKG" AS
/* $Header: GMLRTRNB.pls 120.1 2005/08/15 09:23:47 rakulkar noship $ */


/*========================================================================+
 | PROCEDURE    gml_insert_recv_interface                                 |
 |                                                                        |
 | DESCRIPTION  The procedure inserts data into the                       |
 |              RCV_HEADERS_INTERFACE and                                 |
 |              RCV_TRANSACTIONS_INTERFACE tables                         |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   10-MAR-99  Tony Ricci    Created.                                    |
 |   03-NOV-99  NC   Modified the opm_vendor_cur to get of_vendor_id based|
 |		     on shipvend_id from po_ordr_hdr instead of po_recv_hdr.
 |                   The original code was populating the rcv_headers_interface
 |                   table with blank vendor_id and causing the Receipt   |
 |		     Transaction Processor to fail.                       |
 |   31-MAY-00  NC   Added code to create deliveries on apps side.        |
 |		     A delivery transaction is now created automatically  |	 |	             with each receipt transaction. Bug#1098066           |
 |   12-OCT-00  NC  Pay on receipt enhancements. Bug#1518114.Replaced the |      |                  INSERTS into rcv_headers_interface and rcv_transactions_
 |	            interface by calles to gml_new_rcv_trans_insert in an |
 |		    effort to eliminated redundancy in code.
 |   10-DEC-01  Uday Phadtare Bug#2007945 Added parameter p_dtl_recv_date to procedure
 |              gml_insert_recv_interface so that transaction_date in rcv_transactions_interface
 |              is populated with this date.
 +========================================================================*/

  PROCEDURE gml_insert_recv_interface(p_recv_id IN NUMBER, p_line_id IN NUMBER,
                                      p_po_id IN NUMBER, p_poline_id IN NUMBER,
                                p_opm_item_id IN NUMBER, p_recv_qty1 IN NUMBER,
                                p_recv_um1 IN VARCHAR2,  p_dtl_recv_date IN DATE DEFAULT SYSDATE) AS

    v_po_id             po_ordr_hdr.po_id%TYPE;
    v_poline_id         po_ordr_dtl.line_id%TYPE;

    v_recv_id           po_recv_hdr.recv_id%TYPE;
    v_recv_no           po_recv_hdr.recv_no%TYPE;
    v_created_by        po_recv_hdr.created_by%TYPE;
    v_last_updated_by   po_recv_hdr.last_updated_by%TYPE;

    v_line_id           po_recv_dtl.line_id%TYPE;
    v_recv_qty1         po_recv_dtl.recv_qty1%TYPE;
    v_recv_um1          po_recv_dtl.recv_um1%TYPE;
    v_dtl_recv_date     po_recv_dtl.recv_date%TYPE;

    v_apps_po_header_id          po_headers_all.po_header_id%TYPE;
    v_apps_po_line_id            po_lines_all.po_line_id%TYPE;
    v_apps_po_line_location_id  po_line_locations_all.line_location_id%TYPE;
    v_ship_to_organization_id   po_line_locations_all.ship_to_organization_id%TYPE;

    new_header_interface_id      rcv_headers_interface.header_interface_id%TYPE;
    new_group_id                 rcv_headers_interface.group_id%TYPE;
    new_interface_transaction_id rcv_transactions_interface.interface_transaction_id%TYPE;

    retcode         NUMBER;

    err_num         NUMBER;
    err_msg         VARCHAR2(100);

  CURSOR RCV_HEADER_INT_CUR IS
    SELECT RCV_HEADERS_INTERFACE_S.nextval
    FROM   sys.dual;

  CURSOR RCV_TRANS_INT_CUR IS
    SELECT RCV_TRANSACTIONS_INTERFACE_S.nextval
    FROM   sys.dual;

  CURSOR RCV_INT_GROUPS_CUR IS
    SELECT RCV_INTERFACE_GROUPS_S.nextval
    FROM   sys.dual;

    v_rcv_receipt_num 	po_recv_hdr.recv_no%TYPE;
    v_recv_exists	VARCHAR2(100);

   CURSOR opm_oragems_cur(vc_po_id NUMBER, vc_poline_id NUMBER) IS
    SELECT po_header_id, po_line_id, po_line_location_id
    FROM   cpg_oragems_mapping
    WHERE  po_id = vc_po_id AND
           line_id = vc_poline_id;

   CURSOR po_line_loc_cur(vc_apps_po_header_id NUMBER,
                           vc_apps_po_line_id NUMBER,
                           vc_apps_po_line_location_id NUMBER) IS
   SELECT ship_to_organization_id
   FROM   po_line_locations_all
   WHERE  po_header_id = vc_apps_po_header_id AND
           po_line_id = vc_apps_po_line_id AND
           line_location_id = vc_apps_po_line_location_id;

    CURSOR check_map_table  IS
    SELECT group_id,rcv_receipt_num
    FROM   gml_recv_trans_map
    WHERE  recv_id = v_recv_id
    AND	   organization_id = v_ship_to_organization_id
    AND    rcv_receipt_num is not null;

    CURSOR Get_recv_no IS
    SELECT to_char(next_receipt_num + 1 )
    FROM   rcv_parameters
    WHERE  organization_id = v_ship_to_organization_id;

    x_header_interface_id	NUMBER;
    x_group_id			NUMBER;
    NO_MAPPING			EXCEPTION;

  BEGIN

    v_po_id := p_po_id;
    v_poline_id := p_poline_id;
    v_recv_id := p_recv_id;
    v_line_id := p_line_id;
    v_recv_qty1 := p_recv_qty1;
    v_recv_um1 := p_recv_um1;
    v_dtl_recv_date := p_dtl_recv_date;

    v_created_by             := FND_PROFILE.VALUE ('USER_ID');
    v_last_updated_by        := FND_PROFILE.VALUE ('USER_ID');

    /* Do not process Stock Receipts */
    IF v_po_id IS NULL THEN
	RETURN;
    END IF;

    OPEN   opm_oragems_cur(v_po_id, v_poline_id);
    FETCH  opm_oragems_cur  INTO  v_apps_po_header_id, v_apps_po_line_id,
                                  v_apps_po_line_location_id;
    CLOSE  opm_oragems_cur;


    OPEN   po_line_loc_cur(v_apps_po_header_id, v_apps_po_line_id,
                                  v_apps_po_line_location_id);
    FETCH  po_line_loc_cur  INTO  v_ship_to_organization_id;
    CLOSE  po_line_loc_cur;

    BEGIN
     IF G_recv_id = v_recv_id  THEN

    	Open   check_map_table;
        Fetch  check_map_table into x_group_id,v_rcv_receipt_num;
    	if     check_map_table%NOTFOUND
    	then
    		Close 	check_map_table ;

    		OPEN 	get_recv_no ;
    		FETCH 	get_recv_no into v_rcv_receipt_num;
    		IF 	get_recv_no%NOTFOUND
    		THEN
    			Close get_recv_no;
			Raise NO_MAPPING;
		end if;
		Close get_recv_no;


    		UPDATE rcv_parameters
   		set next_receipt_num  = v_rcv_receipt_num
   		where organization_id = v_ship_to_organization_id ;

        else
     		Close 	check_map_table ;

     		select 	header_interface_id
     		into 	x_header_interface_id
     		from 	rcv_headers_interface
     		where 	group_id = x_group_id;

     		/* B2007945 v_dtl_recv_date added to call */
     		gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,
						   p_line_id,
                                                   p_po_id, p_poline_id,
                                                   p_opm_item_id, p_recv_qty1,0,
                                                   p_recv_um1,NULL,0,NULL,
                                                   x_header_interface_id,
                                                   x_group_id,
                                                   v_rcv_receipt_num,0,v_dtl_recv_date);
       		RETURN;
     	end if;

    ELSE

    		OPEN 	get_recv_no ;
    		FETCH 	get_recv_no into v_rcv_receipt_num;
    		IF 	get_recv_no%NOTFOUND
    		THEN
    			Close get_recv_no;
			Raise NO_MAPPING;
		end if;
		Close get_recv_no;


    		UPDATE rcv_parameters
   		set next_receipt_num = v_rcv_receipt_num
   		where organization_id = v_ship_to_organization_id ;


    END IF;

      	Exception
   	When NO_MAPPING then
	  err_msg := 'Receiving Parameters not setup for this Inventory Organization '|| to_char(v_ship_to_organization_id);
      	  RAISE_APPLICATION_ERROR(-20000, err_msg);

   	When Others then
   	  err_num := SQLCODE;
	  err_msg := SUBSTRB(SQLERRM, 1, 100);
      	  RAISE_APPLICATION_ERROR(-20000, err_msg);

    END;

      OPEN   RCV_HEADER_INT_CUR;
      FETCH  RCV_HEADER_INT_CUR INTO new_header_interface_id;
      CLOSE  RCV_HEADER_INT_CUR;

      OPEN   RCV_INT_GROUPS_CUR;
      FETCH  RCV_INT_GROUPS_CUR INTO new_group_id;
      CLOSE  RCV_INT_GROUPS_CUR;

     /* Header Insert */
     gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,
                                                   p_line_id,
                                                   p_po_id, p_poline_id,
                                                   p_opm_item_id, p_recv_qty1,0,
                                                   p_recv_um1,NULL,0,NULL,
                                                   new_header_interface_id,
                                                   new_group_id,
                                                   v_rcv_receipt_num,1);
     /* Transaction Insert */
       /* B2007945 v_dtl_recv_date added to call */

     gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,
                                                   p_line_id,
                                                   p_po_id, p_poline_id,
                                                   p_opm_item_id, p_recv_qty1,0,
                                                   p_recv_um1,NULL,0,NULL,
                                                   new_header_interface_id,
                                                   new_group_id,
                                                   v_rcv_receipt_num,0,v_dtl_recv_date);

    /* IF G_rows_inserted = 1 THEN
  	gml_recv_trans_pkg.gml_process_adjust_errors(retcode);
    END IF; */

  EXCEPTION

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTRB(SQLERRM, 1, 100);
      RAISE_APPLICATION_ERROR(-20000, err_msg);

  END gml_insert_recv_interface;

/*========================================================================+
 | PROCEDURE    gml_adjust_recv_trans                                     |
 |                                                                        |
 | DESCRIPTION  The procedure updates data into the                       |
 |              RCV_TRANSACTIONS, RCV_SHIPMENT_LINES and                  |
 |              RCV_SUPPLY tables                                         |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   04-MAY-99  Tony Ricci    Created.                                    |
 |   23-NOV-99  NC	Modified.
 |   12-OCT-00  NC  Pay on receipt enhancements Bug#1518144.
 |		    Replaced direct INSERT into rcv_transactions by calls
 |		    to gml_new_rcv_trans_insert() by passing appropriate  |
 |	            parameters for different types of adjustments.
 +========================================================================*/

  PROCEDURE gml_adjust_recv_trans(p_recv_id IN NUMBER, p_line_id IN NUMBER,
                                  p_po_id IN NUMBER, p_poline_id IN NUMBER,
                                p_opm_item_id IN NUMBER, p_recv_qty1 IN NUMBER,
                                p_old_recv_qty1 IN NUMBER,
                                p_recv_um1 IN VARCHAR2,
                                p_return_ind IN NUMBER,
                                p_recv_status IN NUMBER,
                                p_net_price IN NUMBER,
				p_rtrn_void_ind IN NUMBER) AS


    X_interface_transaction_id  rcv_transactions_interface.interface_transaction_id%TYPE;
    v_deliver_transaction_id    rcv_transactions.transaction_id%TYPE;
    v_transaction_id    	rcv_transactions.transaction_id%TYPE;
    v_void_ret_parent_id        rcv_transactions.transaction_id%TYPE;
    v_return_quantity           rcv_transactions.quantity%TYPE;
    v_return_adj_qty            rcv_transactions.quantity%TYPE DEFAULT 0;
    v_trans_id1			rcv_transactions.transaction_id%TYPE;
    v_trans_id2			rcv_transactions.transaction_id%TYPE;
    v_destination_type1		rcv_transactions.destination_type_code%TYPE;
    v_destination_type2		rcv_transactions.destination_type_code%TYPE;
    v_recv_qty1      		rcv_transactions.quantity%TYPE;
    v_old_recv_qty1      		rcv_transactions.quantity%TYPE;

    adjust_err_ind  NUMBER DEFAULT 0;
    X_progress      VARCHAR2(4);

    CURSOR get_trans_id_cur(vc_recv_id NUMBER, vc_line_id NUMBER) IS
    SELECT interface_transaction_id
    FROM   gml_recv_trans_map
    WHERE  recv_id = vc_recv_id AND
           line_id = vc_line_id;

    CURSOR RCV_TRANS_DELIVER_CUR(v_transaction_id NUMBER,
				 v_transaction_type VARCHAR2,
				 v_interface_transaction_id NUMBER) IS
    SELECT transaction_id
    FROM   rcv_transactions
    WHERE  parent_transaction_id = v_transaction_id AND
           transaction_type = v_transaction_type AND
           interface_transaction_id = v_interface_transaction_id;

    CURSOR RCV_TRANS_VOID_RET_CUR(v_transaction_id NUMBER,
				 v_transaction_type VARCHAR2) IS
    SELECT transaction_id,quantity
    FROM   rcv_transactions
    WHERE  parent_transaction_id = v_transaction_id AND
           transaction_type = v_transaction_type;

    CURSOR trans_cur(X_interface_transaction_id NUMBER) IS
    SELECT transaction_id
    FROM   rcv_transactions
    WHERE  interface_transaction_id = X_interface_transaction_id AND
           transaction_type = 'RECEIVE';

  BEGIN

    /* Do not process Stock Receipts */
    IF p_po_id IS NULL THEN
	RETURN;
    END IF;

    OPEN   get_trans_id_cur(p_recv_id, p_line_id);
    FETCH  get_trans_id_cur  INTO  X_interface_transaction_id;

    IF get_trans_id_cur%NOTFOUND THEN
	adjust_err_ind	:= 1;
    END IF;

    CLOSE  get_trans_id_cur;

    OPEN  trans_cur(X_interface_transaction_id);
    FETCH  trans_cur  INTO  v_transaction_id;
    IF trans_cur%NOTFOUND THEN
       adjust_err_ind := 1;
    END IF;

    CLOSE trans_cur;

    IF adjust_err_ind = 1 THEN
	IF G_adjust_mode = 'NORMAL' THEN

	     gml_recv_trans_pkg.gml_insert_adjust_error(p_recv_id, p_line_id,
                                                   p_recv_qty1, p_old_recv_qty1,
                                                   p_recv_um1,p_return_ind,
						   p_recv_status,
						   p_rtrn_void_ind);
	END IF;

	RETURN;
    END IF;

    X_progress	             := '010';

   fnd_global.APPS_INITIALIZE (1001, 50003, 201);
   /* fnd_global.APPS_INITIALIZE (X_created_by, 50003, 201); */

   OPEN RCV_TRANS_DELIVER_CUR(v_transaction_id, 'DELIVER', X_interface_transaction_id);
   FETCH RCV_TRANS_DELIVER_CUR INTO v_deliver_transaction_id;
   CLOSE RCV_TRANS_DELIVER_CUR;

   IF(p_return_ind = 2) THEN /* If this is a correction to return */
     v_return_adj_qty :=  p_old_recv_qty1 - p_recv_qty1;
   END IF;

   /* If this is a void return or a -ve adjustment to the return */

   IF(p_rtrn_void_ind = 1 OR (p_return_ind = 2 AND v_return_adj_qty > 0 ) ) THEN

   	  OPEN RCV_TRANS_VOID_RET_CUR(v_transaction_id, 'RETURN TO VENDOR');
   	  FETCH RCV_TRANS_VOID_RET_CUR INTO v_void_ret_parent_id, v_return_quantity;
   	  CLOSE RCV_TRANS_VOID_RET_CUR;

          IF(v_return_adj_qty >0 ) THEN
	       v_return_quantity := v_return_adj_qty;
	  END IF;

    /* We will in this case, post Two transactions,
		1) One As a  -ve correction to return back to Receiving.
		2) Second to deliver that correction back to Inventory. */

            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
				p_po_id,p_poline_id,
		             	p_opm_item_id,-(v_return_quantity),0,
			     	p_recv_um1,'CORRECT',v_void_ret_parent_id,
				'RECEIVING',0,0,NULL,0);
            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
			    	 p_po_id,p_poline_id,
		             	 p_opm_item_id,v_return_quantity,0,
			     	 p_recv_um1,'DELIVER',v_transaction_id,
				'INVENTORY',0,0,NULL,0);

          /* For voiding of receipts we'll post two transactions.
	     1) First a -ve correction from Inventory
  	     2) Second, a  -ve 'Correction' for Receiving.
          */
     ELSIF (p_recv_status = -1 ) THEN
            v_recv_qty1 := - (p_recv_qty1);
            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
				p_po_id,p_poline_id,
		             	p_opm_item_id,v_recv_qty1,0,
			     	p_recv_um1,'CORRECT',v_deliver_transaction_id,
				'INVENTORY',0,0,NULL,0);
            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
			    	 p_po_id,p_poline_id,
		             	 p_opm_item_id,v_recv_qty1,0,
			     	 p_recv_um1,'CORRECT',v_transaction_id,
				'RECEIVING',0,0,NULL,0);

           /*  Return is pretty straight forward. We insert one
	       transaction 'Return To Vendor' from Inventory. and This
               creates  1) Return to Receiving from Inventory and
			2) Return to vendor from Receiving  in rcv_transactions.
           */

     ELSIF (p_return_ind = 1)  THEN

            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
				p_po_id,p_poline_id,
		             	p_opm_item_id,p_recv_qty1,0,
			     	p_recv_um1,'RETURN TO VENDOR',v_deliver_transaction_id,
				'INVENTORY',0,0,NULL,0);

     ELSE /* Normal Correction to receipt and deliver transactions */
          /* Or a +ve adjustment to return	                   */
          /* If the correction is -ve then post the Inventory Correction
		 first and Receiving Correction Later */

            IF ( (p_recv_qty1 - p_old_recv_qty1) < 0 OR p_return_ind = 2 ) THEN
               v_destination_type1 := 'INVENTORY';
               v_trans_id1 := v_deliver_transaction_id;
               v_destination_type2 := 'RECEIVING';
               v_trans_id2  := v_transaction_id;
            ELSE
               v_destination_type1 := 'RECEIVING';
               v_trans_id1  := v_transaction_id;
               v_destination_type2 := 'INVENTORY';
               v_trans_id2  := v_deliver_transaction_id;
            END IF;

            IF(p_return_ind = 2) THEN /* Negate the quantities if this a a return */
		v_recv_qty1 := -(p_recv_qty1);
		v_old_recv_qty1 := -(p_old_recv_qty1);
            ELSE
		v_recv_qty1 := p_recv_qty1;
		v_old_recv_qty1 := p_old_recv_qty1;
 	    END IF;

            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
			    	 p_po_id,p_poline_id,
		             	 p_opm_item_id,v_recv_qty1,v_old_recv_qty1,
			     	 p_recv_um1,'CORRECT',v_trans_id1,
				v_destination_type1,0,0,NULL,0);

            gml_recv_trans_pkg.gml_new_rcv_trans_insert(p_recv_id,p_line_id,
				p_po_id,p_poline_id,
		             	p_opm_item_id,v_recv_qty1,v_old_recv_qty1,
			     	p_recv_um1,'CORRECT',v_trans_id2,
				v_destination_type2,0,0,NULL,0 );
         END IF;

  EXCEPTION

  WHEN others THEN
       po_message_s.sql_error('gml_adjust_recv_trans', X_progress,
				sqlcode);
       RAISE;

  END gml_adjust_recv_trans;

/*========================================================================+
 | PROCEDURE    gml_store_return_qty                                      |
 |                                                                        |
 | DESCRIPTION  The procedure stores the return_qty1 and                  |
 |              return_um1 values into global package vars for use in     |
 |              gml_adjust_recv_trans proc                                |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   17-MAY-99  Tony Ricci    Created.                                    |
 |                                                                        |
 +========================================================================*/

  PROCEDURE gml_store_return_qty(p_return_qty1 IN NUMBER,
                                 p_return_um1 IN VARCHAR2) AS

    X_progress      VARCHAR2(4);

  BEGIN
        X_progress	:= '010';
	G_return_qty1	:= p_return_qty1;
	G_return_um1	:= p_return_um1;

  EXCEPTION

	WHEN others THEN
        po_message_s.sql_error('gml_store_return_qty', X_progress, sqlcode);

        RAISE;

  END gml_store_return_qty;

/*========================================================================+
 | PROCEDURE    gml_insert_adjust_error                                   |
 |                                                                        |
 | DESCRIPTION  The procedure inserts a row into the                      |
 |              GML_RECV_ADJUST_ERRORS table to indicate that an          |
 |              adjustment/return was made in OPM to a receipt that does  |
 |              not have a corresponding transaction in Oracle Receiving  |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   18-MAY-99  Tony Ricci    Created.                                    |
 |   12-OCT-00  NC Pay on receipt enhancements.Bug#1518114  Added  new    |
 |		parameters and columns in insert statement to reflect     |
 |		the added columns in gml_recv_adjust_errors table.        |
 |   20-AUG-01  P. Arvind Dath BUG#1938430                                |
 |              Modified code to retrieve the max sequence number for a   |
 |              given recv_id and line_id combination, to avoid primary   |
 |              key voilation errors on the 'gml_recv_adjust_errors' table|
 +========================================================================*/

  PROCEDURE gml_insert_adjust_error(p_recv_id IN NUMBER, p_line_id IN NUMBER,
                                    p_recv_qty1 IN NUMBER,
                                    p_old_recv_qty1 IN NUMBER,
                                    p_recv_um1 IN VARCHAR2,
				    p_return_ind IN NUMBER,
				    p_recv_status IN NUMBER,
				    p_rtrn_void_ind IN NUMBER) AS

    X_progress      VARCHAR2(4);
    X_seq_no        gml_recv_adjust_errors.seq_no%TYPE DEFAULT 0;

    v_created_by        gml_recv_adjust_errors.created_by%TYPE;
    v_last_updated_by   gml_recv_adjust_errors.last_updated_by%TYPE;

    -- BEGIN BUG#1938430 P. Arvind Dath

    CURSOR get_seq_no_cur(vc_recv_id NUMBER, vc_line_id NUMBER) IS
    SELECT nvl(max(seq_no),0)
    FROM   gml_recv_adjust_errors
    WHERE  recv_id = vc_recv_id AND
           line_id = vc_line_id;

    -- END BUG#1938430

  BEGIN
        X_progress	:= '010';

    OPEN   get_seq_no_cur(p_recv_id, p_line_id);
    FETCH  get_seq_no_cur  INTO  X_seq_no;


    -- BEGIN BUG#1938430 P. Arvind Dath

    /*IF get_seq_no_cur%NOTFOUND THEN
	X_seq_no	:= 0;
    END IF;*/

    -- END BUG#1938430

    CLOSE  get_seq_no_cur;

    v_created_by             := FND_PROFILE.VALUE ('USER_ID');
    v_last_updated_by        := FND_PROFILE.VALUE ('USER_ID');

    X_seq_no	:= X_seq_no + 1;

    INSERT INTO gml_recv_adjust_errors
    (recv_id, line_id, seq_no,recv_qty1, old_recv_qty1, recv_um1,
     return_ind,recv_status,void_return_ind,
     creation_date,created_by,last_update_date,last_updated_by,
     last_update_login,processed_ind)
    VALUES
    (p_recv_id, p_line_id, X_seq_no, p_recv_qty1, p_old_recv_qty1, p_recv_um1,
     p_return_ind,p_recv_status,p_rtrn_void_ind,
     SYSDATE,v_created_by, SYSDATE,v_last_updated_by,NULL,'N');

  EXCEPTION

	WHEN others THEN
        po_message_s.sql_error('gml_insert_adjust_error', X_progress, sqlcode);

        RAISE;

  END gml_insert_adjust_error;

/*========================================================================+
 | PROCEDURE    gml_process_adjust_errors                                 |
 |                                                                        |
 | DESCRIPTION  The procedure attempts to process rows in the             |
 |              GML_RECV_ADJUST_ERRORS table to indicate that an          |
 |              adjustment/return was made in OPM to a receipt that does  |
 |              not have a corresponding transaction in Oracle Receiving  |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 |   27-MAY-99  Tony Ricci    Created.                                    |
 |   12-OCT-00  NC  Pay on receipt enhancements Bug#1518114. Added new    |
 |	            variables and modified the cursors and procedure call |
 |	            to reflect the new columns added to gml_recv_adjust_errors
 |                                                                        |
 |  19-OCT-01  Uday Phadtare  Bug# 2065300  If get_trans_id_cur fails by any chance
 |             no more records after that are getting processed because adjust_err_ind
 |             is not getting reset. setting back adjust_err_ind to zero.
 +========================================================================*/

  PROCEDURE gml_process_adjust_errors(retcode OUT NOCOPY NUMBER) AS

    X_progress      VARCHAR2(4);
    X_seq_no        gml_recv_adjust_errors.seq_no%TYPE DEFAULT 0;

    adjust_err_ind  NUMBER;

    X_interface_transaction_id rcv_transactions_interface.interface_transaction_id%TYPE;
    X_po_id			po_recv_dtl.po_id%TYPE;
    X_poline_id			po_recv_dtl.poline_id%TYPE;
    X_opm_item_id		po_recv_dtl.item_id%TYPE;
    X_return_ind		po_recv_dtl.return_ind%TYPE;
    X_recv_status		po_recv_dtl.recv_status%TYPE;
    X_net_price			po_recv_dtl.net_price%TYPE;

    CURSOR adjust_error_cur IS
	select 	recv_id,
		line_id,
		seq_no,
		recv_qty1,
		old_recv_qty1,
		recv_um1,
		return_ind,
		recv_status,
		void_return_ind
	from GML_RECV_ADJUST_ERRORS
	where processed_ind = 'N'
	/*PB 22-JUN-2000 order by added*/
	order by seq_no;

  error_rec adjust_error_cur%ROWTYPE;

    CURSOR get_trans_id_cur(vc_recv_id NUMBER, vc_line_id NUMBER) IS
    SELECT interface_transaction_id
    FROM   gml_recv_trans_map
    WHERE  recv_id = vc_recv_id AND
           line_id = vc_line_id;

    CURSOR get_recv_dtl_cur(vc_recv_id NUMBER, vc_line_id NUMBER) IS
    SELECT po_id, poline_id, item_id, recv_status, return_ind, net_price
    FROM   po_recv_dtl
    WHERE  recv_id = vc_recv_id AND
           line_id = vc_line_id;

  BEGIN
        X_progress	:= '010';
	adjust_err_ind	:= 0;


  OPEN  adjust_error_cur;

  FETCH  adjust_error_cur  INTO  error_rec;

  WHILE  adjust_error_cur%FOUND
  LOOP

    /* Uday Phadtare Bug 2065300 */
    adjust_err_ind	:= 0;

    OPEN   get_trans_id_cur(error_rec.recv_id, error_rec.line_id);
    FETCH  get_trans_id_cur  INTO  X_interface_transaction_id;

    IF get_trans_id_cur%NOTFOUND THEN
	adjust_err_ind	:= 1;
    END IF;

    CLOSE  get_trans_id_cur;

    IF adjust_err_ind = 0 THEN

    OPEN   get_recv_dtl_cur(error_rec.recv_id, error_rec.line_id);
    FETCH  get_recv_dtl_cur  INTO  X_po_id, X_poline_id, X_opm_item_id,
				   X_return_ind, X_recv_status, X_net_price;
    CLOSE  get_recv_dtl_cur;

	G_adjust_mode := 'ERRORS';
	gml_recv_trans_pkg.gml_adjust_recv_trans(error_rec.recv_id,
                           error_rec.line_id,
                           X_po_id, X_poline_id,
                           X_opm_item_id, error_rec.recv_qty1,
                           error_rec.old_recv_qty1,
                           error_rec.recv_um1,
                           error_rec.return_ind,
                           error_rec.recv_status,
                           X_net_price,
			   error_rec.void_return_ind);

	G_adjust_mode := 'NORMAL';

        update gml_recv_adjust_errors
	set processed_ind = 'Y',
	    last_update_date = SYSDATE
	where recv_id = error_rec.recv_id
	and   line_id = error_rec.line_id
	and   seq_no = error_rec.seq_no;

    END IF;

    FETCH  adjust_error_cur  INTO  error_rec;

  END LOOP;

  CLOSE adjust_error_cur;

  EXCEPTION

	WHEN others THEN
        po_message_s.sql_error('gml_process_adjust_errors', X_progress,sqlcode);

        RAISE;

  END gml_process_adjust_errors;

/*========================================================================+
  PROCEDURE
     gml_new_recv_trans_insert()
  DESCRIPTION  The procedure inserts data into the
               RCV_HEADERS_INTERFACE ,
               RCV_TRANSACTIONS_INTERFACE and
 		gml_recv_trans_map tables

  PARAMETERS   p_recv_id    		recv_id
		....
		p_transaction_type	Transaction_type could be 'DELIVER',
					'RECEIVE', 'CORRECTION','RETURN TO VENDOR' etc.
		p_transaction_id	This is the parent_transaction_id  used
					mainly for corrections, This value is 0
					otherwise.
		p_destination_type_code Destination type of the transaction.Also
					primarily used for corrections. NULL otherwise.
				        It could be either 'INVENTORY' or 'RECEIVING'.

                p_header_interface_id   This has a valid value if the transaction is
					associated with a header.
					0 - For corrections,

		p_group_id		Same as above.
					0 -  for corrections.

		p_rcv_receipt_num	Apps receipt number.
		p_header_flag		1 - If this is a header insert
					0 - Otherwise.

   MODIFICATION HISTORY

    12-OCT-00  NC  Created.

    This procedure inserts records into both rcv_headers_interface and
    rcv_transactions_interface for receipts and all types of corrections
    to receipts (adjustment to receipts/returns, voiding of receipts/returns
    etc.) depending on the parameters passed.
    Bug#1518114.

    26-DEC-00  NC Bug#1554124  Added  v_vendor_site_id in the insert clause
			       for rcv_transactions_interface. Auto invoices
			       were failing as this column was getting
			       populated with NULL.

    10-DEC-01  Uday Phadtare Bug#2007945 Added parameter p_dtl_recv_date to procedure
               gml_new_rcv_trans_insert so that transaction_date in rcv_transactions_interface
               is populated with this date.
    26-JUL-02  Pushkar Upakare Bug 2458366
               Added waybill_no to the rcv_header_interface from po_recv_hdr
 +========================================================================*/

  PROCEDURE gml_new_rcv_trans_insert(p_recv_id IN NUMBER,
				     p_line_id IN NUMBER,
                                     p_po_id IN NUMBER,
				     p_poline_id IN NUMBER,
                                     p_opm_item_id IN NUMBER,
				     p_recv_qty1 IN NUMBER,
				     p_old_recv_qty1 IN NUMBER,
                                     p_recv_um1 IN VARCHAR2,

                                     p_transaction_type IN VARCHAR2,
				     p_transaction_id IN NUMBER,
				     p_destination_type_code IN VARCHAR2,

				     p_header_interface_id IN NUMBER,
				     p_group_id IN NUMBER,
				     p_rcv_receipt_num  IN po_recv_hdr.recv_no%TYPE,
				     p_header_flag IN NUMBER,
				     p_dtl_recv_date IN DATE DEFAULT SYSDATE) AS
    v_po_id             po_ordr_hdr.po_id%TYPE;
    v_poline_id         po_ordr_dtl.line_id%TYPE;
    v_recv_id           po_recv_hdr.recv_id%TYPE;
    v_recv_no           po_recv_hdr.recv_no%TYPE;
    v_shipvend_id       po_recv_hdr.shipvend_id%TYPE;
    v_created_by        po_recv_hdr.created_by%TYPE;
    v_last_updated_by   po_recv_hdr.last_updated_by%TYPE;
    v_to_whse           po_recv_hdr.to_whse%TYPE;
    v_recv_date         po_recv_hdr.recv_date%TYPE;
    v_gross_wt          po_recv_hdr.gross_wt%TYPE;
    v_net_wt            po_recv_hdr.net_wt%TYPE;
    v_tare_wt           po_recv_hdr.tare_wt%TYPE;
    v_bol_um            po_recv_hdr.bol_um%TYPE;
    v_billing_currency  po_recv_hdr.billing_currency%TYPE;
    v_waybill_no        po_recv_hdr.waybill_no%TYPE;
  --v_of_vendor_id      po_vend_mst.of_vendor_id%TYPE;
    v_of_vendor_id      po_headers_all.vendor_id%TYPE;

    v_line_id           po_recv_dtl.line_id%TYPE;
    v_recv_qty1         po_recv_dtl.recv_qty1%TYPE;
    v_recv_um1          po_recv_dtl.recv_um1%TYPE;
    v_dtl_recv_date     po_recv_dtl.recv_date%TYPE;

    v_line_no           po_ordr_dtl.line_no%TYPE;
    v_orgn_code         po_ordr_hdr.orgn_code%TYPE;
    v_returned_qty      po_rtrn_dtl.return_qty1%TYPE;

    v_opm_item_id       ic_item_mst.item_id%TYPE;
    v_opm_item_no       ic_item_mst.item_no%TYPE;

    v_apps_po_header_id          po_headers_all.po_header_id%TYPE;
    v_vendor_site_id             po_headers_all.vendor_site_id%TYPE;
    v_freight_terms              po_headers_all.freight_terms_lookup_code%TYPE;
    v_currency_code              po_headers_all.currency_code%TYPE;
    v_rate_type                  po_headers_all.rate_type%TYPE;
    v_rate_date                  po_headers_all.rate_date%TYPE;
    v_rate                       po_headers_all.rate%TYPE;
    v_po_revision_num            po_headers_all.revision_num%TYPE;
    v_apps_po_line_id            po_lines_all.po_line_id%TYPE;
    v_item_rev                   po_lines_all.item_revision%TYPE;
    v_org_id                     po_lines_all.org_id%TYPE;
    v_unit_price                 po_lines_all.unit_price%TYPE;

    v_apps_po_line_location_id  po_line_locations_all.line_location_id%TYPE;
    v_ship_to_location_id       po_line_locations_all.ship_to_location_id%TYPE;
    v_ship_to_organization_id   po_line_locations_all.ship_to_organization_id%TYPE;
    v_po_release_id             po_line_locations_all.po_release_id%TYPE;

    new_header_interface_id      rcv_headers_interface.header_interface_id%TYPE;
    new_group_id                 rcv_headers_interface.group_id%TYPE;
    tmp_group_id                 rcv_headers_interface.group_id%TYPE;
    new_interface_transaction_id rcv_transactions_interface.interface_transaction_id%TYPE;
    tmp_interface_transaction_id rcv_transactions_interface.interface_transaction_id%TYPE;

    v_deliver_to_person_id       po_distributions.deliver_to_person_id%TYPE;
    v_po_distribution_id         po_distributions.po_distribution_id%TYPE;
    v_auto_transact_code         rcv_transactions.transaction_type%TYPE;
    v_destination_type_code      rcv_transactions.transaction_type%TYPE;
    v_transacion_id              rcv_transactions.transaction_id%TYPE;
    v_header_interface_id        rcv_transactions_interface.header_interface_id%TYPE;

    v_item_id       mtl_system_items.inventory_item_id%TYPE;
    v_item_no       mtl_system_items.segment1%TYPE;
    v_item_desc     mtl_system_items.description%TYPE;
    v_subinventory  mtl_secondary_inventories.secondary_inventory_name%TYPE;
    v_transaction_type rcv_transactions.transaction_type%TYPE;

    v_shipment_header_id  	rcv_transactions.shipment_header_id%TYPE;
    v_shipment_line_id  	rcv_transactions.shipment_line_id%TYPE;
    v_interface_transaction_id  rcv_transactions.interface_transaction_id%TYPE;
    v_transaction_id  		rcv_transactions.transaction_id%TYPE;
    v_attribute1  		rcv_transactions.attribute1%TYPE;
    v_comment	  		rcv_transactions_interface.comments%TYPE;
    v_trans_quantity  		rcv_transactions.quantity%TYPE;
    v_document_num 		  rcv_transactions_interface.document_num%TYPE;
    v_document_line_num           rcv_transactions_interface.document_line_num%TYPE;
    v_document_shipment_line_num  rcv_transactions_interface.document_shipment_line_num%TYPE;
    v_revision_control_code 	NUMBER;


    insert_trans_row         NUMBER;

    err_num         NUMBER;
    err_msg         VARCHAR2(100);
    v_group_id	    NUMBER;

/** MC BUG# 1554088 **/
/** create a variable and a cursor to select apps side uom code  **/
    v_bol_uom_code                mtl_units_of_measure.uom_code%TYPE :=NULL;
    v_recv_unit_of_measure        mtl_units_of_measure.unit_of_measure%TYPE;
    CURSOR UOM_CODE(v_um_code VARCHAR2 ) IS
    SELECT b.UOM_CODE
    FROM   sy_uoms_mst a,mtl_units_of_measure b
    WHERE  a.um_code = v_um_code
    AND    a.unit_of_measure = b.unit_of_measure;

 CURSOR UNIT_OF_MEASURE(v_um_code VARCHAR2 ) IS
    SELECT UNIT_OF_MEASURE
    FROM   sy_uoms_mst
    WHERE  um_code = v_um_code;


    CURSOR RCV_TRANS_INT_CUR IS
    SELECT RCV_TRANSACTIONS_INTERFACE_S.nextval
    FROM   sys.dual;

    CURSOR RCV_INT_GROUPS_CUR IS
    SELECT RCV_INTERFACE_GROUPS_S.nextval
    FROM   sys.dual;

    CURSOR opm_recv_no_cur(vc_recv_id NUMBER) IS
    SELECT recv_no, shipvend_id,to_whse,recv_date,gross_wt,net_wt,tare_wt, substrb(waybill_no, 1, 20), /* Bug 2458366 - added waybill_no*/
           bol_um,billing_currency
    FROM   po_recv_hdr
    WHERE  recv_id = vc_recv_id;
/*
    CURSOR opm_vendor_cur(vc_shipvend_id NUMBER) IS
    SELECT of_vendor_id
    FROM   po_vend_mst
    WHERE  vendor_id = vc_shipvend_id;
*/
    CURSOR opm_vendor_cur(vc_po_id NUMBER) IS
    SELECT of_vendor_id
    FROM   po_vend_mst
    WHERE  vendor_id = (SELECT shipvend_id
			FROM   po_ordr_hdr
			WHERE  po_id = vc_po_id);

    CURSOR opm_oragems_cur(vc_po_id NUMBER, vc_poline_id NUMBER) IS
    SELECT po_header_id, po_line_id, po_line_location_id
    FROM   cpg_oragems_mapping
    WHERE  po_id = vc_po_id AND
           line_id = vc_poline_id;

    CURSOR headers_all_cur(vc_apps_po_header_id NUMBER) IS
    SELECT vendor_site_id,freight_terms_lookup_code,currency_code,rate_type,
           rate_date,rate,revision_num
    FROM   po_headers_all
    WHERE  po_header_id = vc_apps_po_header_id;

    CURSOR po_dist_cur(vc_apps_po_header_id NUMBER,
                       vc_apps_po_line_id NUMBER,
                       vc_apps_po_line_location_id NUMBER) IS
    SELECT deliver_to_person_id,po_distribution_id
    FROM   po_distributions
    WHERE  po_header_id = vc_apps_po_header_id AND
           po_line_id = vc_apps_po_line_id AND
           line_location_id = vc_apps_po_line_location_id;

    CURSOR opm_item_cur(vc_opm_item_id NUMBER) IS
    SELECT item_no
    FROM   ic_item_mst
    WHERE  item_id = vc_opm_item_id;

    CURSOR app_item_cur(vc_opm_item_no VARCHAR2) IS
    SELECT inventory_item_id,description
    FROM   mtl_system_items
    WHERE  segment1 = vc_opm_item_no;

    /* Uday Phadtare B1785880 removed unit_price from select */
    CURSOR app_po_line_cur(vc_apps_po_header_id NUMBER,
                           vc_apps_po_line_id NUMBER) IS
    SELECT item_revision,org_id
    FROM   po_lines_all
    WHERE  po_header_id = vc_apps_po_header_id AND
           po_line_id = vc_apps_po_line_id;

    /* Uday Phadtare B1785880 select price_override from po_line_locations_all */
    CURSOR po_line_loc_cur(vc_apps_po_header_id NUMBER,
                           vc_apps_po_line_id NUMBER,
                           vc_apps_po_line_location_id NUMBER) IS
    SELECT ship_to_location_id,po_release_id,ship_to_organization_id,price_override
    FROM   po_line_locations_all
    WHERE  po_header_id = vc_apps_po_header_id AND
           po_line_id = vc_apps_po_line_id AND
           line_location_id = vc_apps_po_line_location_id;

    /* Bug #1470411*/
    CURSOR rev_control_code_cur(vc_inventory_item_id IN NUMBER,
				vc_ship_to_organization_id IN NUMBER) IS
    SELECT revision_qty_control_code
    FROM   mtl_system_items
    WHERE  inventory_item_id = vc_inventory_item_id AND
	   organization_id = vc_ship_to_organization_id;


    CURSOR rcv_transactions_cur(v_transaction_id NUMBER) IS
    SELECT shipment_header_id,
	   shipment_line_id,
	   po_distribution_id,
           attribute1,
           interface_transaction_id
    FROM   rcv_transactions
    WHERE  transaction_id = v_transaction_id;

   /* Bug#1098066 */
    CURSOR app_subinventory_cur(vc_ship_to_organization_id VARCHAR2) IS
    SELECT secondary_inventory_name
    FROM   mtl_secondary_inventories
    WHERE  organization_id = vc_ship_to_organization_id AND
 	   NVL(disable_date,sysdate+1) > sysdate ;

    /* Bug 1969740 */
    CURSOR get_subinventory_code_cur(vc_ship_to_organization_id NUMBER,
                                     vc_inventory_location_id NUMBER) IS
    SELECT subinventory_code
    FROM   mtl_item_locations
    WHERE  organization_id = vc_ship_to_organization_id
    AND    inventory_location_id = vc_inventory_location_id
    AND    (disable_date > sysdate or disable_date is null);


   /* PB */
    v_rcv_receipt_num	NUMBER;

    /* Begin Bug 1685307 */
    CURSOR  get_location IS
    SELECT  whse_code, loct_ctl
    FROM    ic_whse_mst
    WHERE   mtl_organization_id = v_ship_to_organization_id
    AND     delete_mark = 0;

    CURSOR   locid_whse(p_whse_code VARCHAR2) IS
    SELECT   inventory_location_id
    FROM     ic_loct_mst
    WHERE    whse_code = p_whse_code
    AND	     inventory_location_id is not null
    AND      delete_mark = 0
    ORDER BY inventory_location_id;

    /* Uday Phadtare B1858899 */
    CURSOR doc_nums_cur(vc_apps_po_header_id NUMBER,
                        vc_apps_po_line_id NUMBER,
                        vc_apps_po_line_location_id NUMBER) IS
    select po.segment1, lines.line_num, shipments.shipment_num
    from   po_headers_all po, po_lines_all lines, po_line_locations_all shipments
    where  po.po_header_id            = vc_apps_po_header_id
    and	   lines.po_header_id  	      = po.po_header_id
    and    lines.po_line_id           = vc_apps_po_line_id
    and	   shipments.po_header_id     = po.po_header_id
    and	   shipments.po_line_id       = lines.po_line_id
    and    shipments.line_location_id = vc_apps_po_line_location_id;

    v_get_location get_location%ROWTYPE;
    v_loct_id NUMBER := NULL;
    /* End Bug 1685307 */

BEGIN
    v_po_id := p_po_id;
    v_poline_id := p_poline_id;
    v_recv_id := p_recv_id;
    v_line_id := p_line_id;
    v_recv_qty1 := p_recv_qty1;
    v_recv_um1 := p_recv_um1;
    v_opm_item_id := p_opm_item_id;
    v_dtl_recv_date   := p_dtl_recv_date;

    v_created_by             := FND_PROFILE.VALUE ('USER_ID');
    v_last_updated_by        := FND_PROFILE.VALUE ('USER_ID');

    v_rcv_receipt_num	     := p_rcv_receipt_num;

    v_transaction_type	     := p_transaction_type;

    v_trans_quantity         := (p_recv_qty1 - p_old_recv_qty1);

    OPEN   opm_recv_no_cur(v_recv_id);
    FETCH  opm_recv_no_cur  INTO  v_recv_no, v_shipvend_id, v_to_whse,
                               v_recv_date,v_gross_wt,v_net_wt,v_tare_wt, v_waybill_no,
                               v_bol_um,v_billing_currency;
    CLOSE  opm_recv_no_cur;

/** MC BUG# 1554088  **/
    OPEN   uom_code(v_bol_um);
    FETCH  uom_code INTO v_bol_uom_code;
    CLOSE  uom_code;

    OPEN   unit_of_measure(v_recv_um1);
    FETCH  unit_of_measure INTO v_recv_unit_of_measure;
    CLOSE  unit_of_measure;


/*
    OPEN   opm_vendor_cur(v_shipvend_id);
*/
    OPEN   opm_vendor_cur(v_po_id);
    FETCH  opm_vendor_cur  INTO  v_of_vendor_id;
    CLOSE  opm_vendor_cur;

    OPEN   opm_oragems_cur(v_po_id, v_poline_id);
    FETCH  opm_oragems_cur  INTO  v_apps_po_header_id, v_apps_po_line_id,
                                  v_apps_po_line_location_id;
    CLOSE  opm_oragems_cur;

    OPEN   headers_all_cur(v_apps_po_header_id);
    FETCH  headers_all_cur  INTO  v_vendor_site_id,v_freight_terms,
                                  v_currency_code,v_rate_type,v_rate_date,
                                  v_rate,v_po_revision_num;
    CLOSE  headers_all_cur;

    OPEN   po_dist_cur(v_apps_po_header_id, v_apps_po_line_id,
                                  v_apps_po_line_location_id);
    FETCH  po_dist_cur  INTO  v_deliver_to_person_id,v_po_distribution_id;
    CLOSE  po_dist_cur;

    OPEN   opm_item_cur(v_opm_item_id);
    FETCH  opm_item_cur  INTO  v_opm_item_no;
    CLOSE  opm_item_cur;

    OPEN   app_item_cur(v_opm_item_no);
    FETCH  app_item_cur  INTO  v_item_id,v_item_desc;
    CLOSE  app_item_cur;

    OPEN   app_po_line_cur(v_apps_po_header_id, v_apps_po_line_id);
    FETCH  app_po_line_cur  INTO  v_item_rev, v_org_id;
    CLOSE  app_po_line_cur;

    /* Uday Phadtare B1785880 v_unit_price fetched from po_line_locations_all */
    OPEN   po_line_loc_cur(v_apps_po_header_id, v_apps_po_line_id,
                                  v_apps_po_line_location_id);
    FETCH  po_line_loc_cur  INTO  v_ship_to_location_id,v_po_release_id,
                                  v_ship_to_organization_id,v_unit_price;
    CLOSE  po_line_loc_cur;

    /*  Bug #1470411 */
    OPEN   rev_control_code_cur(v_item_id,v_ship_to_organization_id);
    FETCH  rev_control_code_cur INTO v_revision_control_code;
    CLOSE  rev_control_code_cur;

   /* Bug#1098066 */
    OPEN   app_subinventory_cur(v_ship_to_organization_id);
    FETCH  app_subinventory_cur  INTO v_subinventory;
    CLOSE  app_subinventory_cur;

    /* Begin Bug 1685307 */
    OPEN   get_location;
    FETCH  get_location INTO v_get_location;
    CLOSE  get_location;

    IF v_get_location.loct_ctl IN(1,2) THEN
       OPEN   locid_whse(v_get_location.whse_code);
       FETCH  locid_whse INTO v_loct_id;
       CLOSE  locid_whse;

       /* Begin Bug# 1969740 */
       OPEN   get_subinventory_code_cur(v_ship_to_organization_id, v_loct_id);
       FETCH  get_subinventory_code_cur  INTO v_subinventory;
       CLOSE  get_subinventory_code_cur;
       /* End Bug# 1969740 */
    END IF;
    /* End Bug 1685307 */

    /* Uday Phadtare B1858899 */
    OPEN   doc_nums_cur(v_apps_po_header_id, v_apps_po_line_id, v_apps_po_line_location_id);
    FETCH  doc_nums_cur INTO v_document_num, v_document_line_num, v_document_shipment_line_num;
    CLOSE  doc_nums_cur;

    IF (p_header_flag = 1) THEN  /* This is a header insert */
/** MC BUG# 1554088  **/
/** replace v_bol_um with v_bol_uom_code in the insert **/
        INSERT INTO rcv_headers_interface
    	(header_interface_id,
    	 group_id,
    	 processing_status_code,
     	 receipt_source_code,
     	 transaction_type,
     	 auto_transact_code,
     	 last_update_date,
     	 last_updated_by,
     	 creation_date,
     	 created_by,
     	 shipment_num,
     	 receipt_num,
     	 vendor_id,
     	 vendor_site_id,
     	 ship_to_organization_id,
     	 expected_receipt_date,
     	 waybill_airbill_num,        /* Bug 2458366 */
     	 comments,
     	 gross_weight,
     	 gross_weight_uom_code,
     	 net_weight,
     	 net_weight_uom_code,
     	 tar_weight,
     	 tar_weight_uom_code,
     	 freight_terms,
     	 currency_code,
     	 conversion_rate_type,
     	 conversion_rate,
     	 conversion_rate_date,
     	 employee_id,
     	 validation_flag)
    	VALUES
	(p_header_interface_id,
	 p_group_id,
	 'PENDING',
	 'VENDOR',
	 'NEW',
         'RECEIVE',
         SYSDATE,
         v_last_updated_by,
         SYSDATE,
         v_created_by,
         to_char(p_header_interface_id),     /* 2540428 insert p_header_interface_id instead of '1' */
         v_rcv_receipt_num,                  /* v_recv_no */
         v_of_vendor_id,
         v_vendor_site_id,
         v_ship_to_organization_id,
     	 v_recv_date,
     	 v_waybill_no,                       /* Bug 2458366 */
     	 'OPM RECEIPT',
     	 v_gross_wt,
     	 v_bol_uom_code,
     	 v_net_wt,
     	 v_bol_uom_code,
     	 v_tare_wt,
     	 v_bol_uom_code,
     	 v_freight_terms,
     	 v_currency_code,
     	 v_rate_type,
     	 v_rate,
     	 v_rate_date,
     	 v_deliver_to_person_id,
     	 'Y');

        RETURN;

    END IF;

    OPEN   RCV_TRANS_INT_CUR;
    FETCH  RCV_TRANS_INT_CUR INTO new_interface_transaction_id;
    CLOSE  RCV_TRANS_INT_CUR;

    /* Only if this record is an adjustment to an existing transaction
       in rcv_transactions,will we open the following two cursors. One
       to fetch the shipment and distribution ids and the other to
       fetch a new group id */

    IF (p_header_interface_id = 0  AND p_header_flag = 0 ) THEN

        OPEN rcv_transactions_cur(p_transaction_id);
        FETCH rcv_transactions_cur INTO v_shipment_header_id,v_shipment_line_id,
				    v_po_distribution_id,v_attribute1,
				    v_interface_transaction_id;
        CLOSE rcv_transactions_cur;

        OPEN   RCV_INT_GROUPS_CUR;
        FETCH  RCV_INT_GROUPS_CUR INTO new_group_id;
        CLOSE  RCV_INT_GROUPS_CUR;

        v_auto_transact_code := NULL;
        v_subinventory       := NULL;
        v_comment            := 'OPM Receipt Correction';
        v_header_interface_id := NULL;
        v_transaction_id := p_transaction_id;
        v_destination_type_code := p_destination_type_code;

    ELSE
        /* Bug2228634 : Changed destination type code to 'Inventory'
                        as directed by Discrete po */
        /* This transaction is for an existing header. We'll use the passed
           parameters */

	new_group_id := p_group_id;
        new_header_interface_id  := p_header_interface_id;
        v_shipment_header_id := NULL;
	v_shipment_line_id  := NULL;
        v_attribute1 	     := new_interface_transaction_id;
        v_transaction_type   := 'RECEIVE';
	v_trans_quantity     := v_recv_qty1;
        v_auto_transact_code := 'DELIVER';
        v_transaction_id     := NULL; 		/* parent transaction id */
        v_destination_type_code  := 'INVENTORY'; /* Changing from NULL */
        v_comment            := 'OPM RECEIPT';
        v_header_interface_id := p_header_interface_id;

   END IF;

    /*  Bug #1470411 */
    IF (v_revision_control_code = 1) THEN /* This item is not revision controled, we'll pass NULL */
	v_item_rev := NULL;
    END IF;

/** MC BUG# 1554088  **/
/** unit_of_measure was going as v_recv_um1.Replace it with v_recv_unit_of_measure **/
   INSERT INTO rcv_transactions_interface
    (INTERFACE_TRANSACTION_ID,
     GROUP_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     TRANSACTION_TYPE,
     TRANSACTION_DATE,
     PROCESSING_STATUS_CODE,
     PROCESSING_MODE_CODE,
     TRANSACTION_STATUS_CODE,
     QUANTITY,
     UNIT_OF_MEASURE,
     ITEM_ID,
     ITEM_DESCRIPTION,
     ITEM_REVISION,
     AUTO_TRANSACT_CODE,
     SHIPMENT_HEADER_ID,
     SHIPMENT_LINE_ID,
     SHIP_TO_LOCATION_ID,
     RECEIPT_SOURCE_CODE,
     VENDOR_ID,
     VENDOR_SITE_ID,
     TO_ORGANIZATION_ID,
     SOURCE_DOCUMENT_CODE,
     PARENT_TRANSACTION_ID,
     PO_HEADER_ID,
     PO_REVISION_NUM,
     PO_RELEASE_ID,
     PO_LINE_ID,
     PO_LINE_LOCATION_ID,
     PO_UNIT_PRICE,
     CURRENCY_CODE,
     CURRENCY_CONVERSION_TYPE,
     CURRENCY_CONVERSION_RATE,
     CURRENCY_CONVERSION_DATE,
     PO_DISTRIBUTION_ID,
     DESTINATION_TYPE_CODE,
     DELIVER_TO_LOCATION_ID,
     SUBINVENTORY,
     LOCATOR_ID,
     SHIPMENT_NUM,
     EXPECTED_RECEIPT_DATE,
     COMMENTS,
     ATTRIBUTE1,
     HEADER_INTERFACE_ID,
     DOCUMENT_NUM,
     DOCUMENT_LINE_NUM,
     DOCUMENT_SHIPMENT_LINE_NUM,
     VALIDATION_FLAG)
   VALUES
    (new_interface_transaction_id,
     new_group_id,
     SYSDATE,
     v_last_updated_by,
     SYSDATE,
     v_created_by,
     v_transaction_type,
     v_dtl_recv_date,         /* B2007945 replaced SYSDATE with v_dtl_recv_date SYSDATE */
     'PENDING',
     'BATCH',
     'PENDING',
     v_trans_quantity,
     v_recv_unit_of_measure,
     v_item_id,
     v_item_desc,
     v_item_rev,
     v_auto_transact_code,
     v_shipment_header_id,
     v_shipment_line_id,
     v_ship_to_location_id,
     'VENDOR',
     v_of_vendor_id,
     v_vendor_site_id,
     v_ship_to_organization_id,
     'PO',
     v_transaction_id,
     v_apps_po_header_id,
     v_po_revision_num,
     v_po_release_id,
     v_apps_po_line_id,
     v_apps_po_line_location_id,
     v_unit_price,
     v_currency_code,
     v_rate_type,
     v_rate,
     v_rate_date,
     v_po_distribution_id,
     v_destination_type_code,
     v_ship_to_location_id,     /* B1766557 */
     v_subinventory,
     v_loct_id,                 /* B1685307 */
     '1',
     v_recv_date,
     v_comment,
     v_attribute1,
     v_header_interface_id,
     v_document_num,
     v_document_line_num,
     v_document_shipment_line_num,
     'Y');

     /* Each time a new transaction (except for adjustments ) is inserted,
	insert a row in the mapping table.
     */
     IF (p_header_interface_id <> 0  AND p_header_flag = 0 ) THEN

     	INSERT INTO gml_recv_trans_map
    		(recv_id, line_id, interface_transaction_id,group_id,
     		creation_date,created_by,last_update_date,last_updated_by,
     		last_update_login,organization_id,rcv_receipt_num)
    	VALUES
    		(v_recv_id, v_line_id,new_interface_transaction_id,new_group_id,
     		SYSDATE,v_created_by, SYSDATE,v_last_updated_by,NULL,v_ship_to_organization_id,
		v_rcv_receipt_num);

    	G_header_interface_id       := new_header_interface_id;
    	G_group_id                  := new_group_id;
    	G_interface_transaction_id  := new_interface_transaction_id;
    	G_recv_id                   := v_recv_id;
    	G_rows_inserted             := G_rows_inserted +1;
    	G_ship_to_organization_id   := v_ship_to_organization_id;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTRB(SQLERRM, 1, 100);
      RAISE_APPLICATION_ERROR(-20000, err_msg);

  END gml_new_rcv_trans_insert;

END GML_RECV_TRANS_PKG;

/
