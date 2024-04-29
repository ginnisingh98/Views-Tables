--------------------------------------------------------
--  DDL for Package Body GMF_INTERNAL_ORDERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_INTERNAL_ORDERS" AS
/* $Header: GMFINORB.pls 115.5 2004/01/22 20:46:54 sschinch noship $ */


/*===============================================================================
 *Package: GMF_INTERNAL_ORDERS
 * Procedure: GET_INTERNAL_ORDER_STS
 * Description: This procedure returns status to indicate how to book an entry
 *
 * Inputs:
 * 1. p_req_line_id    - requisition_line_id
 * 2. p_entry_type     - entry type
 *	M -- Indicates Middle Entry.
 * Output:
 *  Status of the row if it is old or new or a middle entry.
 *	Old 	-- O	0	Invoiced	Not Invoiced         Not Invoiced but Processed
 *	New 	-- N	1	     3			2			6
 *	Middle 	-- X	4
 =================================================================================*/


 FUNCTION  GET_INTERNAL_ORDER_STS(preq_line_id NUMBER,
    				  pentry_type VARCHAR2) RETURN VARCHAR2 IS
 	l_flag_posted VARCHAR2(2);
 	l_invoiced_flag NUMBER := 0;
 	l_flag_value 	NUMBER := 1;

 	CURSOR Cur_Get_flags (c_req_line_id NUMBER,
 				c_entry_type VARCHAR2) IS
 		SELECT  DECODE(min(nvl(t.intorder_posted_ind,-1)),-1,DECODE(c_entry_type,'M','X','O'),'N'),
     	   		DECODE(NVL(min(t.invoiced_flag),'-1'),'-1',0,'P',2,1)
        	FROM  po_requisition_headers_all prh,
              		po_requisition_lines_all prl,
              		oe_order_lines_all oel,
              		ic_tran_pnd t
       		WHERE  prl.requisition_header_id = prh.requisition_header_id
          		and prh.segment1 		= oel.orig_sys_document_ref
          		and prl.requisition_line_id 	= oel.source_document_line_id
          		and oel.order_source_id 	= 10
          		and oel.line_id 		= t.line_id
          		and t.doc_type 			= 'OMSO'
          		and t.completed_ind 		= 1
          		and t.delete_mark 		= 0
          		and prl.requisition_line_id 	= c_req_line_id;

  BEGIN
	IF (preq_line_id IS NOT NULL)
        THEN
		OPEN Cur_get_flags(preq_line_id,pentry_type);
		FETCH Cur_get_flags INTO l_flag_posted,l_invoiced_flag;
		IF (Cur_get_flags%NOTFOUND) THEN
			l_flag_value := 1;
			l_flag_posted := 'N';
			l_invoiced_flag := 0;
		END IF;
		CLOSE Cur_Get_flags;
		IF (l_flag_posted = 'N') THEN
			l_flag_value := 1;	/* New Entry */
		ELSIF(l_flag_posted = 'O') THEN
			l_flag_value := 0;	/* Old Entry */
		ELSIF (l_flag_posted = 'X') THEN
			l_flag_value := 4;	/* Discard Entry*/
		END IF;

		IF (l_invoiced_flag = 0 AND l_flag_value = 1) THEN
			l_flag_value := l_flag_value + 1;	/* Not Invoiced and New */
		ELSIF (l_invoiced_flag = 1 AND l_flag_value = 1) THEN
			l_flag_value := l_flag_value + 2;	/* Invoiced and New*/
		ELSIF(l_invoiced_flag = 2 AND l_flag_value = 1) THEN
		      l_flag_value := l_flag_value + 5;		/* Processed and New */
		END IF;
    	ELSE
    		RETURN('2');
    	END IF;

  	RETURN (TO_CHAR(l_flag_value));

 END  GET_INTERNAL_ORDER_STS;


 /*===============================================================================
 *Package: GMF_INTERNAL_ORDERS
 * Procedure: GET_TRANSFER_PRICE
 * Description: This procedure returns transfer price in shipping operation unit
 *		currency.
 *
 * Inputs:
 * 1. p_ship_ou_id    - Shipping Operating Unit
 * 2. p_recv_ou_id    - Receiving Operating Unit
 * 3. p_trans_um      -  Transaction Unit Of Measure.
 * 4. p_inv_item_id   -  Inventory Item Id
 * 5. p_currency_code - Shipping Company Currency
 * 6. p_trans_date    -  the date for which the conversion rate is used
 * Output:
 *  1. x_return_status - return status
 *  2. x_transfer_price -- transfer price.
 =================================================================================*/

 PROCEDURE GET_TRANSFER_PRICE(p_ship_ou_id		IN NUMBER
   			     ,p_recv_ou_id		IN NUMBER
   			     ,p_trans_um		IN VARCHAR2
   			     ,p_inv_item_id		IN NUMBER
   			     ,p_trans_id		IN NUMBER
   			     ,p_currency_code	        IN VARCHAR2
   			     ,p_trans_date		IN DATE
			     ,p_inv_org_id		IN NUMBER
      			     ,x_return_status 	        OUT NOCOPY VARCHAR2
   			     ,x_transfer_price 	OUT NOCOPY NUMBER)
 IS

 	CURSOR Cur_get_trans(cp_inv_item_id NUMBER,
 			     cp_trans_id  NUMBER) IS
          SELECT max(t.trans_id)
            FROM    po_requisition_headers_all prh,
             	    po_requisition_lines_all prl,
              	    oe_order_lines_all oel,
              	    ic_tran_pnd t
       	   WHERE   prl.requisition_header_id    = prh.requisition_header_id
          	   and prh.segment1 		= oel.orig_sys_document_ref
          	   and prl.requisition_line_id 	= oel.source_document_line_id
          	   and oel.order_source_id 	= 10
          	   and oel.line_id 		= t.line_id
          	   and t.doc_type 		= 'OMSO'
          	   and t.completed_ind 		= 1
          	   and t.delete_mark 		= 0
		   and oel.inventory_item_id    = cp_inv_item_id
          	   and prl.requisition_line_id 	= (SELECT  t.requisition_line_id
   						     FROM rcv_transactions t
 	    						 ,ic_tran_pnd pnd
 	    					    WHERE t.shipment_header_id  = pnd.doc_id
							  and t.transaction_id  = pnd.line_id
							  and pnd.doc_type      = 'PORC'
							  and pnd.completed_ind = 1
							  and pnd.delete_mark   = 0
							  and pnd.trans_id      = cp_trans_id
						  );

	l_api_version  	 NUMBER := 1.0;
   	x_msg_count 	 NUMBER;
   	x_msg_data	 VARCHAR2(2000);
   	l_currency_code	 VARCHAR2(10);
   	l_transfer_price NUMBER;
   	l_return_status VARCHAR2(2);
   	l_func_currency_code VARCHAR2(10);
   	l_inv_transfer_price NUMBER;
   	l_inv_currency_code  VARCHAR2(4);
   	l_trans_id 	     NUMBER := NULL;
 BEGIN

 	OPEN cur_get_trans(p_inv_item_id,p_trans_id);
 	FETCH Cur_get_trans INTO l_trans_id;
 	CLOSE Cur_get_trans;

 	IF (l_trans_id IS NULL) THEN
 	  l_trans_id := p_trans_id;
 	END IF;



  	INV_TRANSACTION_FLOW_PUB.GET_TRANSFER_PRICE
	  		(x_return_status		=> x_return_status
			,x_msg_data			=> x_msg_data
			,x_msg_count			=> x_msg_count
			,x_transfer_price		=> x_transfer_price
			,x_currency_code		=> l_currency_code
			,x_incr_transfer_price		=> l_inv_transfer_price
			,x_incr_currency_code		=> l_inv_currency_code
			,p_api_version         		=> l_api_version
			,p_init_msg_list	        => 'T'
			,p_from_org_id			=> p_ship_ou_id
			,p_to_org_id			=> p_recv_ou_id
			,p_transaction_uom		=> p_trans_um
			,p_inventory_item_id		=> p_inv_item_id
			,p_from_organization_id		=> p_inv_org_id
			,p_transaction_id		=> l_trans_id
			,p_global_procurement_flag 	=> 'N');


	IF (l_currency_code IS NOT NULL) THEN
		IF (l_currency_code <> p_currency_code) THEN
			l_transfer_price := x_transfer_price;

			x_transfer_price :=INV_TRANSACTION_FLOW_PUB.CONVERT_CURRENCY (
						  p_org_id       	       	=> p_ship_ou_id
        					, p_transfer_price      	=> l_transfer_price
        					, p_currency_code     		=> l_currency_code
        					, p_transaction_date   		=> p_trans_date
        					, x_functional_currency_code 	=> l_func_currency_code
        					, x_return_status      		=> l_return_status
        					, x_msg_data   			=> x_msg_data
        					, x_msg_count          		=> x_msg_count);

        		IF (l_return_status = 'S') THEN
        			x_transfer_price := l_transfer_price;
        			x_return_status := 'S';
        		ELSE
        			x_transfer_price := 0;
        			x_return_status := 'E';
        		END IF;
        	END IF;
        END IF;

 END GET_TRANSFER_PRICE;

END GMF_INTERNAL_ORDERS;

/
