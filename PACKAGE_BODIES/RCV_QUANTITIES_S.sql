--------------------------------------------------------
--  DDL for Package Body RCV_QUANTITIES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_QUANTITIES_S" AS
/* $Header: RCVTXQUB.pls 120.5.12010000.20 2014/06/06 08:15:46 yuzzhang ship $*/

g_asn_debug        VARCHAR2(1)  := asn_debug.is_debug_on; -- Bug 9152790

/*
** Forward declarations of all the local procedures and functions called
** by get_available_quantity().
*/

PROCEDURE get_receive_quantity(p_parent_id           IN  NUMBER,
			       p_receipt_source_code IN  VARCHAR2,
			       p_available_quantity  IN OUT NOCOPY NUMBER,
			       p_tolerable_quantity  IN OUT NOCOPY NUMBER,
			       p_unit_of_measure     IN OUT NOCOPY VARCHAR2,
			       p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_po_quantity(p_line_location_id      IN  NUMBER,
			  p_available_quantity IN OUT NOCOPY NUMBER,
			  p_tolerable_quantity IN OUT NOCOPY NUMBER,
			  p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
			  p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_rma_quantity(p_oe_order_line_id        IN            NUMBER,
                           p_available_quantity      IN OUT NOCOPY NUMBER,
                           p_tolerable_quantity      IN OUT NOCOPY NUMBER,
                           p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
                           p_secondary_available_qty IN OUT NOCOPY NUMBER);

PROCEDURE get_shipment_quantity(p_shipment_line_id      IN  NUMBER,
				p_available_quantity IN OUT NOCOPY NUMBER,
				p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
				p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_transaction_quantity(p_transaction_id        IN  NUMBER,
				   p_available_quantity IN OUT NOCOPY NUMBER,
				   p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
				   p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_correction_quantity(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_parent_id                  IN  NUMBER,
				  p_grand_parent_id            IN  NUMBER,
				  p_available_quantity      IN OUT NOCOPY NUMBER,
				  p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				  p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
				  p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_deliver_quantity(p_transaction_id         IN  NUMBER,
			       p_available_quantity  IN OUT NOCOPY NUMBER,
			       p_unit_of_measure     IN OUT NOCOPY VARCHAR2,
			       p_secondary_available_qty IN OUT NOCOPY NUMBER );

PROCEDURE get_po_dist_quantity(p_po_distribution_id  IN NUMBER,
			       p_available_quantity  IN OUT NOCOPY NUMBER,
                               p_tolerable_quantity  IN OUT NOCOPY NUMBER,  -- 1337787
			       p_unit_of_measure     IN OUT NOCOPY VARCHAR2);

--add for bug 17998528
PROCEDURE get_lcm_dist_quantity(p_po_distribution_id  IN NUMBER,
                                p_rcv_shipment_line_id in number,
                                p_available_quantity  IN OUT NOCOPY NUMBER,
                                p_tolerable_quantity  IN OUT NOCOPY NUMBER,
                                p_unit_of_measure     IN OUT NOCOPY VARCHAR2);
--end of bug 17998528
PROCEDURE get_rcv_dist_quantity(p_po_distribution_id  IN NUMBER,
				p_transaction_id      IN NUMBER,
				p_available_quantity  IN OUT NOCOPY NUMBER,
			        p_unit_of_measure     IN OUT NOCOPY VARCHAR2 );

PROCEDURE get_receive_amount(p_parent_id           IN  NUMBER,
			       p_receipt_source_code IN  VARCHAR2,
			       p_available_amount  IN OUT NOCOPY NUMBER,
			       p_tolerable_amount  IN OUT NOCOPY NUMBER );

PROCEDURE get_po_amount(p_line_location_id      IN  NUMBER,
			  p_available_amount IN OUT NOCOPY NUMBER,
			  p_tolerable_amount IN OUT NOCOPY NUMBER );

PROCEDURE get_correction_amount(p_correction_type            IN  VARCHAR2,
				  p_parent_transaction_type    IN  VARCHAR2,
				  p_receipt_source_code        IN  VARCHAR2,
				  p_parent_id                  IN  NUMBER,
				  p_grand_parent_id            IN  NUMBER,
				  p_available_amount      IN OUT NOCOPY NUMBER,
				  p_tolerable_amount      IN OUT NOCOPY NUMBER );

PROCEDURE get_deliver_amount(p_transaction_id         IN  NUMBER,
			       p_available_amount  IN OUT NOCOPY NUMBER );

PROCEDURE get_transaction_amount(p_transaction_id        IN  NUMBER,
				   p_available_amount IN OUT NOCOPY NUMBER );

PROCEDURE get_po_dist_amount(p_po_distribution_id  IN NUMBER,
			       p_available_amount  IN OUT NOCOPY NUMBER,
                               p_tolerable_amount  IN OUT NOCOPY NUMBER);

/*===========================================================================

  PROCEDURE NAME:	get_available_quantity()

  ALGORITHM     :

  The following is the overall stucture for the entire quantity validation
  program. Details of each procedure are given in the individual procedures
  themselves. This structure explodes all functions to all the relevant
  functions calls within them.
  e.g.
  get_receive_quantity() is exploded to show that it calls get_po_quantity()
  and get_shipment_quantity().

  IF (p_transaction_type IN ('RECEIVE', 'MATCH')) THEN

     get_receive_quantity();

	IF (p_receipt_source_code = 'VENDOR') THEN

	    get_po_quantity();

	ELSIF (p_receipt_source_code in ('INVENTORY', 'INTERNAL ORDER')) THEN

	    get_shipment_quantity();

	ELSE

	    return invalid receipt_source_code.

	END IF;

  ELSIF (p_transaction_type IN ('TRANSFER', 'INSPECT', 'DELIVER')) THEN

     get_transaction_quantity();

  ELSIF (p_transaction_type IN ('CORRECT', 'RETURN TO VENDOR',
				  'RETURN TO RECEIVING'))  THEN

     get_correction_quantity();

     	IF p_correction_type = 'NEGATIVE' THEN

	    IF (p_parent_transaction_type IN ('UNORDERED', 'RECEIVE', 'MATCH',
					'TRANSFER', 'ACCEPT', 'REJECT')) THEN

		get_transaction_quantity();

	    ELSIF (p_parent_transaction_type IN
				('RETURN TO VENDOR', 'DELIVER')) THEN

		get_deliver_quantity();

	    ELSE

		return invalid parent transaction type.

	    END IF;

	ELSIF p_correction_type = 'POSITIVE' THEN

	    IF (p_parent_transaction_type IN ('RECEIVE', 'MATCH')) THEN

		get_receive_quantity();

	    ELSIF (p_parent_transaction_type IN ('TRANSFER', 'ACCEPT',
				'REJECT', 'DELIVER', 'RETURN TO VENDOR')) THEN

		get_transaction_quantity();

	    ELSE

		raise invalid parent transaction type.

	    END IF;

	END IF;

  ELSE

     return invalid transaction type.

  END IF;

  Please fix any bug in both the get_available_quantity procedures since this is overloaded.
===========================================================================================*/

PROCEDURE get_available_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2) IS

x_progress 			VARCHAR2(3) := NULL;

invalid_transaction_type 	EXCEPTION;
x_secondary_available_qty	NUMBER :=0;

BEGIN

   x_progress := '005';

   IF (p_transaction_type IN ('RECEIVE', 'MATCH')) THEN

	get_receive_quantity(p_parent_id, p_receipt_source_code,
			     p_available_quantity, p_tolerable_quantity,
			     p_unit_of_measure, x_secondary_available_qty);

   ELSIF (p_transaction_type IN ('TRANSFER', 'INSPECT', 'DELIVER')) THEN

	get_transaction_quantity(p_parent_id, p_available_quantity,
			  	 p_unit_of_measure,x_secondary_available_qty);

   ELSIF (p_transaction_type IN ('CORRECT', 'RETURN TO VENDOR',
				 'RETURN TO CUSTOMER',
				 'RETURN TO RECEIVING'))  THEN

	get_correction_quantity(p_correction_type, p_parent_transaction_type,
				p_receipt_source_code, p_parent_id,
				p_grand_parent_id, p_available_quantity,
				p_tolerable_quantity,p_unit_of_measure,x_secondary_available_qty);

   ELSIF (p_transaction_type = 'DIRECT RECEIPT')  THEN

	get_po_dist_quantity(p_parent_id, p_available_quantity,
			     p_tolerable_quantity, p_unit_of_measure);

   ELSIF (p_transaction_type = 'STANDARD DELIVER')  THEN

	get_rcv_dist_quantity(p_parent_id, p_grand_parent_id,
			      p_available_quantity, p_unit_of_measure);

   ELSE

	/*
	** The function was called with the wrong p_transaction_type
	** parameter. Raise an invalid transaction type exception.
	*/

	RAISE invalid_transaction_type;

   END IF;

EXCEPTION

   WHEN invalid_transaction_type THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_available_quantity', x_progress, sqlcode);

   	RAISE;

END get_available_quantity;

/*==========================================================================
  Over loaded Procedure
============================================================================
This procedure performs the same funciton as the one above
It is overloaded for comon receiving project as this is called from
POXPOVPO2.pld to calculate quantity_due and in order not to hhave PO library
dependednt on a  receivcing package this was overloaded.
===========================================================================*/

PROCEDURE get_available_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
				 p_secondary_available_qty IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) := NULL;

invalid_transaction_type 	EXCEPTION;

BEGIN

   x_progress := '005';

   IF (p_transaction_type IN ('RECEIVE', 'MATCH')) THEN

	get_receive_quantity(p_parent_id, p_receipt_source_code,
			     p_available_quantity, p_tolerable_quantity,
			     p_unit_of_measure, p_secondary_available_qty);

   ELSIF (p_transaction_type IN ('TRANSFER', 'INSPECT', 'DELIVER')) THEN

	get_transaction_quantity(p_parent_id, p_available_quantity,
			  	 p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_transaction_type IN ('CORRECT', 'RETURN TO VENDOR',
				 'RETURN TO CUSTOMER',
				 'RETURN TO RECEIVING'))  THEN

	get_correction_quantity(p_correction_type, p_parent_transaction_type,
				p_receipt_source_code, p_parent_id,
				p_grand_parent_id, p_available_quantity,
				p_tolerable_quantity,p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_transaction_type = 'DIRECT RECEIPT')  THEN

	get_po_dist_quantity(p_parent_id, p_available_quantity,
			     p_tolerable_quantity, p_unit_of_measure);
   --add for bug 17998528
   ELSIF (p_transaction_type = 'LCM DIRECT RECEIPT')  THEN
        get_lcm_dist_quantity(p_parent_id, p_grand_parent_id, p_available_quantity,
                              p_tolerable_quantity, p_unit_of_measure);
   --end of bug 17998528
   ELSIF (p_transaction_type = 'STANDARD DELIVER')  THEN

	get_rcv_dist_quantity(p_parent_id, p_grand_parent_id,
			      p_available_quantity, p_unit_of_measure);

   ELSE

	/*
	** The function was called with the wrong p_transaction_type
	** parameter. Raise an invalid transaction type exception.
	*/

	RAISE invalid_transaction_type;

   END IF;

EXCEPTION

   WHEN invalid_transaction_type THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_available_quantity', x_progress, sqlcode);

   	RAISE;

END get_available_quantity;
/*===========================================================================*/

/*===========================================================================

  PROCEDURE NAME:	get_available_amount()

===========================================================================*/
PROCEDURE get_available_amount(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_available_amount        IN OUT NOCOPY NUMBER,
				 p_tolerable_amount        IN OUT NOCOPY NUMBER) IS

x_progress 			VARCHAR2(3) := NULL;

invalid_transaction_type 	EXCEPTION;

BEGIN

   x_progress := '005';

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_transaction_type '||p_transaction_type);
		asn_debug.put_line('p_parent_id '||p_parent_id);
		asn_debug.put_line('p_parent_transaction_type '||p_parent_transaction_type);
		asn_debug.put_line('p_grand_parent_id '||p_grand_parent_id);
		asn_debug.put_line('p_correction_type '||p_correction_type);
	END IF;
   IF p_transaction_type = 'RECEIVE' THEN

	get_receive_amount(p_parent_id, p_receipt_source_code,
			     p_available_amount, p_tolerable_amount);

   ELSIF p_transaction_type = 'DELIVER' THEN

        get_transaction_amount(p_parent_id, p_available_amount);

   ELSIF (p_transaction_type = 'DIRECT RECEIPT')  THEN

	get_po_dist_amount(p_parent_id, p_available_amount,
			     p_tolerable_amount);

   ELSIF p_transaction_type = 'CORRECT'  THEN

	get_correction_amount(p_correction_type, p_parent_transaction_type,
				p_receipt_source_code, p_parent_id,
				p_grand_parent_id, p_available_amount,
				p_tolerable_amount);

   ELSE

	/*
	** The function was called with the wrong p_transaction_type
	** parameter. Raise an invalid transaction type exception.
	*/

	RAISE invalid_transaction_type;

   END IF;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('Exit get_available_amt '||p_transaction_type);
		asn_debug.put_line('p_available_amt '||p_available_amount);
		asn_debug.put_line('p_tolerable_amount '||p_tolerable_amount);
	end if;
EXCEPTION

   WHEN invalid_transaction_type THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;

   WHEN OTHERS THEN

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('When others exception in get_available_amt' );
	end if;
      	po_message_s.sql_error('get_available_amount', x_progress, sqlcode);

   	RAISE;

END get_available_amount;
/*===========================================================================

  PROCEDURE NAME:	get_receive_quantity()

===========================================================================*/

PROCEDURE get_receive_quantity(p_parent_id           IN  NUMBER,
			       p_receipt_source_code IN  VARCHAR2,
			       p_available_quantity  IN OUT NOCOPY NUMBER,
			       p_tolerable_quantity  IN OUT NOCOPY NUMBER,
			       p_unit_of_measure     IN OUT NOCOPY VARCHAR2,
			       p_secondary_available_qty IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) := NULL;

x_return_status                 VARCHAR2(80);
x_msg_count			NUMBER;
x_msg_data			VARCHAR2(240);

invalid_receipt_source_code	EXCEPTION;

BEGIN

   IF (p_receipt_source_code = 'VENDOR') THEN

	get_po_quantity(p_parent_id, p_available_quantity,
			p_tolerable_quantity, p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_receipt_source_code = 'CUSTOMER') THEN

        get_rma_quantity(p_parent_id, p_available_quantity,
                         p_tolerable_quantity, p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_receipt_source_code in ('INTERNAL', 'INVENTORY', 'INTERNAL ORDER')) THEN

	get_shipment_quantity(p_parent_id, p_available_quantity,
			      p_unit_of_measure,p_secondary_available_qty);

   ELSE

	/*
	** The function was called with the wrong p_receipt_source_code
	** parameter. Raise an invalid source code exception.
	*/

	RAISE invalid_receipt_source_code;

   END IF;

EXCEPTION

   WHEN invalid_receipt_source_code THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_receive_quantity', x_progress, sqlcode);

	RAISE;

END get_receive_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_receive_amount()

===========================================================================*/

PROCEDURE get_receive_amount(p_parent_id           IN  NUMBER,
			       p_receipt_source_code IN  VARCHAR2,
			       p_available_amount  IN OUT NOCOPY NUMBER,
			       p_tolerable_amount  IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) := NULL;

x_return_status                 VARCHAR2(80);
x_msg_count			NUMBER;
x_msg_data			VARCHAR2(240);

invalid_receipt_source_code	EXCEPTION;

BEGIN
	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('in get_receive_amount ' );
		asn_debug.put_line('p_parent_id '||p_parent_id);
		asn_debug.put_line('p_receipt_source_code '||p_receipt_source_code);
	END IF;

   IF (p_receipt_source_code = 'VENDOR') THEN
	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('before get_po_amount ' );
	end if;

	get_po_amount(p_parent_id, p_available_amount,
			p_tolerable_amount);

   ELSE

	/*
	** The function was called with the wrong p_receipt_source_code
	** parameter. Raise an invalid source code exception.
	*/

	RAISE invalid_receipt_source_code;

   END IF;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_available_amount '||p_available_amount);
		asn_debug.put_line('p_tolerable_amount '||p_tolerable_amount);
	END IF;
EXCEPTION

   WHEN invalid_receipt_source_code THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;

   WHEN OTHERS THEN

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('Exception get_receive_amount ' );
	end if;
      	po_message_s.sql_error('get_receive_amount', x_progress, sqlcode);

	RAISE;

END get_receive_amount;

/*===========================================================================

  PROCEDURE NAME:	get_available_rma_quantity()

===========================================================================*/

PROCEDURE get_available_rma_quantity(p_transaction_type        IN  VARCHAR2,
				 p_parent_id               IN  NUMBER,
				 p_receipt_source_code     IN  VARCHAR2,
				 p_parent_transaction_type IN  VARCHAR2,
				 p_grand_parent_id         IN  NUMBER,
				 p_correction_type         IN  VARCHAR2,
				 p_oe_order_header_id	   IN  NUMBER,
				 p_oe_order_line_id	   IN  NUMBER,
				 p_available_quantity      IN OUT NOCOPY NUMBER,
				 p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				 p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
			         p_secondary_available_qty IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3)	:= NULL;
x_quantity_ordered		NUMBER		:= 0;
x_quantity_received		NUMBER		:= 0;
x_interface_quantity  		NUMBER		:= 0; /* in primary_uom */
x_quantity_cancelled		NUMBER		:= 0;
x_qty_rcv_tolerance		NUMBER		:= 0;
x_qty_rcv_exception_code	VARCHAR2(26);
x_po_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
x_interface_qty_in_po_uom	NUMBER		:= 0;
invalid_transaction_type 	EXCEPTION;

BEGIN

   IF (p_transaction_type IN ('RECEIVE', 'MATCH')) THEN

	get_receive_quantity(p_oe_order_line_id, p_receipt_source_code,
			     p_available_quantity, p_tolerable_quantity,
			     p_unit_of_measure, p_secondary_available_qty );

   ELSIF (p_transaction_type IN ('TRANSFER', 'INSPECT', 'DELIVER')) THEN

	get_transaction_quantity(p_parent_id, p_available_quantity,
			  	 p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_transaction_type IN ('CORRECT', 'RETURN TO VENDOR',
				  'RETURN TO RECEIVING'))  THEN

	get_correction_quantity(p_correction_type, p_parent_transaction_type,
				p_receipt_source_code, p_parent_id,
				p_grand_parent_id, p_available_quantity,
				p_tolerable_quantity,p_unit_of_measure,p_secondary_available_qty);

   ELSIF (p_transaction_type = 'DIRECT RECEIPT')  THEN

	get_po_dist_quantity(p_parent_id, p_available_quantity,
			     p_tolerable_quantity, p_unit_of_measure);

   ELSIF (p_transaction_type = 'STANDARD DELIVER')  THEN

	get_rcv_dist_quantity(p_parent_id, p_grand_parent_id,
			      p_available_quantity, p_unit_of_measure);

   ELSE

	/*
	** The function was called with the wrong p_transaction_type
	** parameter. Raise an invalid transaction type exception.
	*/

	RAISE invalid_transaction_type;

   END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_rma_quantity', x_progress, sqlcode);

	RAISE;


END get_available_rma_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_po_quantity()

===========================================================================*/

PROCEDURE get_po_quantity(p_line_location_id      IN  NUMBER,
			  p_available_quantity IN OUT NOCOPY NUMBER,
			  p_tolerable_quantity IN OUT NOCOPY NUMBER,
			  p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
			  p_secondary_available_qty IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3)	:= NULL;
x_quantity_ordered		NUMBER		:= 0;
x_quantity_received		NUMBER		:= 0;
x_interface_quantity  		NUMBER		:= 0; /* in primary_uom */
x_quantity_cancelled		NUMBER		:= 0;

x_qty_rcv_tolerance		NUMBER		:= 0;
x_qty_rcv_exception_code	VARCHAR2(26);
x_po_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
x_interface_qty_in_po_uom	NUMBER		:= 0;

/*Bug# 1548597*/
x_secondary_qty_ordered		NUMBER		:= 0;
x_secondary_qty_received		NUMBER		:= 0;
x_secondary_interface_qty  	NUMBER		:= 0;
x_secondary_qty_cancelled		NUMBER		:= 0;
x_secondary_uom				VARCHAR2(26);
--end bug 1548597

-- <Bug 9342280 : Added for CLM project>
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>



BEGIN

   x_progress := '005';

   /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.quantity, 0),
	  nvl(pll.quantity_received, 0),
	  nvl(pll.quantity_cancelled,0),
	  nvl(pll.secondary_quantity, 0),
	  nvl(pll.secondary_quantity_received, 0),
	  nvl(pll.secondary_quantity_cancelled,0),
	  1 + (nvl(pll.qty_rcv_tolerance,0)/100),
	  pll.qty_rcv_exception_code,
	  pl.item_id,
	  pl.unit_meas_lookup_code
   INTO   x_quantity_ordered,
	  x_quantity_received,
	  x_quantity_cancelled,
	  /*Bug# 1548597*/
	  x_secondary_qty_ordered,
	  x_secondary_qty_received,
	  x_secondary_qty_cancelled,
	  --end bug 1548597
	  x_qty_rcv_tolerance,
	  x_qty_rcv_exception_code,
	  x_item_id,
	  x_po_uom
   FROM   po_line_locations_all pll,  --<Shared Proc FPJ>
	  po_lines_all pl  --<Shared Proc FPJ>
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;

   x_progress := '010';

   /*
   ** Get any unprocessed receipt or match transaction against the
   ** PO shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

  /* Bug# 2347348 : Primary Unit of Measure cannot have value
     for One time Items. So Added a decode statement to fetch
     unit_of_measure in case of One Time Items and Primary
     Unit of Measure for Inventory Items.
  */


   SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
	  decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface rti
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')  -- bug 657347 should include 'SHIP'
                                                                     -- when calculating total quantity
                                                                     -- in the interface table
   AND NOT EXISTS(SELECT 1 FROM rcv_transactions rt                  -- bug 9583207 should not include
                  WHERE rt.transaction_type='DELIVER'                -- Correction to Deliver transaction
		              AND rt.transaction_id = rti.parent_transaction_id
		              AND rti.transaction_type = 'CORRECT')
   AND    po_line_location_id = p_line_location_id;
/*
   SELECT nvl(sum(primary_quantity),0),
	  decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
*/
   /*
   ** Modified by Subhajit on 09/06/95
   ** Earlier transaction type were ('RECEIVE','MATCH')
   ** CORRECT transaction were not taken into consideration
   AND    transaction_type IN ('RECEIVE', 'MATCH')
   */
/*
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')  -- bug 657347 should include 'SHIP'
                                                                     -- when calculating total quantity
                                                                     -- in the interface table
   AND    po_line_location_id = p_line_location_id;
*/

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_po_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_po_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the PO uom
	** so that the available quantity can be calculated in the PO uom
	*/

        x_progress := '015';
	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			     x_po_uom, x_interface_qty_in_po_uom);

   END IF;

   /*bug 1548597*/
   SELECT nvl(sum(secondary_quantity),0),
	  min(secondary_unit_of_measure)
   INTO   x_secondary_interface_qty,
	  x_secondary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT','SHIP')
   AND    po_line_location_id = p_line_location_id;
   /*bug 1548597*/

   /*
   ** Calculate the quantity available to be received.
   */

    -- <Bug 9342280 : Added for CLM project>
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
      END IF;

      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => p_line_location_id,
                                                p_po_distribution_id  => NULL);

      l_partial_funded_flag := 'N';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('line_location_id : ' || p_line_location_id);
         asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;

      IF l_is_clm_po = 'Y' THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('before calling po_clm_intg_grp.get_funding_info()');
         END IF;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => p_line_location_id,
                                             p_po_distribution_id      => NULL,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status

                                    );

          IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
            asn_debug.put_line('l_quantity_funded: ' || l_quantity_funded);
            asn_debug.put_line('l_quantity_received : ' || l_quantity_received);
            asn_debug.put_line('l_quantity_cancelled: ' || l_quantity_cancelled);
          END IF;

         IF l_partial_funded_flag = 'Y' THEN

            x_quantity_ordered := l_quantity_funded;

         END IF;

      END IF;
    -- <CLM END>

   p_available_quantity := x_quantity_ordered - x_quantity_received -
			   x_quantity_cancelled - x_interface_qty_in_po_uom;

   /*bug 1548597*/
   p_secondary_available_qty := x_secondary_qty_ordered - x_secondary_qty_received -
			   x_secondary_qty_cancelled - x_secondary_interface_qty;
   /*bug 1548597*/




   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_quantity < 0) THEN

	p_available_quantity := 0;

   END IF;

   /*bug 1548597*/
   IF (p_secondary_available_qty < 0) THEN
	p_secondary_available_qty := 0;
   END IF;
   /*bug 1548597*/

   /*
   ** Calculate the maximum quantity that can be received allowing for
   ** tolerance.
   */
   -- <Bug 9342280 : Added for CLM project>
   IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_quantity for clm po');
      END IF;

      p_tolerable_quantity := p_available_quantity;

   ELSE
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_quantity for non-clm po');
      END IF;
   -- <CLM END>
   p_tolerable_quantity := (x_quantity_ordered * x_qty_rcv_tolerance) -
			    x_quantity_received - x_quantity_cancelled -
			    x_interface_qty_in_po_uom;

   END IF; -- <Bug 9342280 : Added for CLM project>
   /*
   ** p_tolerable_quantity can be negative if this shipment has been over
   ** received. In this case, the tolerable quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_tolerable_quantity < 0) THEN

	p_tolerable_quantity := 0;

   END IF;

   /*
   ** Return the PO unit of measure
   */

   p_unit_of_measure := x_po_uom;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_po_quantity', x_progress, sqlcode);

	RAISE;

END get_po_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_po_amount()

===========================================================================*/

PROCEDURE get_po_amount(p_line_location_id      IN  NUMBER,
			  p_available_amount IN OUT NOCOPY NUMBER,
			  p_tolerable_amount IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3)	:= NULL;
x_amount_ordered		NUMBER		:= 0;
x_amount_received		NUMBER		:= 0;
x_interface_amount  		NUMBER		:= 0;
x_amount_cancelled		NUMBER		:= 0;

x_qty_rcv_tolerance		NUMBER		:= 0;
x_qty_rcv_exception_code	VARCHAR2(26);

-- <Bug 9342280 : Added for CLM project>
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>

BEGIN

   x_progress := '005';

   /*
   ** Get PO quantity information.
   */

   SELECT nvl(pll.amount, 0),
	  nvl(pll.amount_received, 0),
	  nvl(pll.amount_cancelled,0),
	  1 + (nvl(pll.qty_rcv_tolerance,0)/100),
	  pll.qty_rcv_exception_code
   INTO   x_amount_ordered,
	  x_amount_received,
	  x_amount_cancelled,
	  x_qty_rcv_tolerance,
	  x_qty_rcv_exception_code
   FROM   po_line_locations_all pll,  --<Shared Proc FPJ>
	  po_lines_all pl  --<Shared Proc FPJ>
   WHERE  pll.line_location_id = p_line_location_id
   AND    pll.po_line_id = pl.po_line_id;

   x_progress := '010';

   SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))),0)
   INTO   x_interface_amount
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type IN ('RECEIVE', 'MATCH','CORRECT')
   AND    po_line_location_id = p_line_location_id;

    -- <Bug 9342280 : Added for CLM project>
      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
      END IF;

      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => p_line_location_id,
                                                p_po_distribution_id  => NULL);

      l_partial_funded_flag := 'N';

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('line_location_id : ' || p_line_location_id);
         asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;

      IF l_is_clm_po = 'Y' THEN
         IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('before calling po_clm_intg_grp.get_funding_info()');
         END IF;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => p_line_location_id,
                                             p_po_distribution_id      => NULL,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status

                                    );

          IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
            asn_debug.put_line('l_amount_funded: ' || l_amount_funded);
            asn_debug.put_line('l_amount_received : ' || l_amount_received);
            asn_debug.put_line('l_amount_cancelled: ' || l_amount_cancelled);
          END IF;

         IF l_partial_funded_flag = 'Y' THEN

            x_amount_ordered := l_amount_funded;

         END IF;

      END IF;
    -- <CLM END>

   /*
   ** Calculate the quantity available to be received.
   */

   p_available_amount := x_amount_ordered - x_amount_received -
			   x_amount_cancelled - x_interface_amount;

   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_amount < 0) THEN
	p_available_amount := 0;
   END IF;

   /*
   ** Calculate the maximum quantity that can be received allowing for
   ** tolerance.
   */

   -- <Bug 9342280 : Added for CLM project>
   IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_amount for clm po');
      END IF;

      p_tolerable_amount := p_available_amount;

   ELSE
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_amount for non-clm po');
      END IF;
   -- <CLM END>

   p_tolerable_amount := (x_amount_ordered * x_qty_rcv_tolerance) -
			    x_amount_received - x_amount_cancelled -
			    x_interface_amount;
   END IF; -- <Bug 9342280 : Added for CLM project>

   /*
   ** p_tolerable_quantity can be negative if this shipment has been over
   ** received. In this case, the tolerable quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_tolerable_amount < 0) THEN
	p_tolerable_amount := 0;
   END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_po_amount', x_progress, sqlcode);

	RAISE;

END get_po_amount;

/*===========================================================================

  PROCEDURE NAME:       get_rma_quantity()

===========================================================================*/

   PROCEDURE get_rma_quantity(
      p_oe_order_line_id        IN            NUMBER,
      p_available_quantity      IN OUT NOCOPY NUMBER,
      p_tolerable_quantity      IN OUT NOCOPY NUMBER,
      p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
      p_secondary_available_qty IN OUT NOCOPY NUMBER
   ) IS
      x_progress                VARCHAR2(3)   := NULL;
      x_return_status           VARCHAR2(80);
      x_msg_count               NUMBER;
      x_msg_data                VARCHAR2(240);
      x_interface_quantity      NUMBER        := 0;   /* in primary_uom */
      x_qty_rcv_tolerance       NUMBER        := 0;
      x_oe_uom                  VARCHAR2(26);
      x_item_id                 NUMBER;
      x_primary_uom             VARCHAR2(26);
      x_interface_qty_in_oe_uom NUMBER        := 0;
      x_secondary_qty_ordered   NUMBER        := 0;
      x_secondary_qty_received  NUMBER        := 0;
      x_secondary_interface_qty NUMBER        := 0;
      x_secondary_qty_cancelled NUMBER        := 0;
      x_secondary_uom           VARCHAR2(26);

      CURSOR get_lines IS
         SELECT NVL(quantity, interface_transaction_qty) quantity,
                unit_of_measure,
                secondary_quantity,
                secondary_unit_of_measure
         FROM   rcv_transactions_interface
         WHERE  (    transaction_status_code = 'PENDING'
                 AND processing_status_code <> 'ERROR')
         AND    transaction_type IN('RECEIVE', 'MATCH', 'CORRECT', 'SHIP')
         AND    oe_order_line_id = p_oe_order_line_id;
   BEGIN
      asn_debug.put_line('***BEGIN*** get_po_quantity');
      asn_debug.put_line('p_oe_order_line_id = ' || p_oe_order_line_id);
      asn_debug.put_line('p_available_quantity = ' || p_available_quantity);
      asn_debug.put_line('p_tolerable_quantity = ' || p_tolerable_quantity);
      asn_debug.put_line('p_unit_of_measure = ' || p_unit_of_measure);
      asn_debug.put_line('p_secondary_available_qty = ' || p_secondary_available_qty);
      x_progress                 := '010';

      SELECT NVL(oel.ordered_quantity2, 0),
             NVL(oel.shipped_quantity2, 0),
             NVL(oel.cancelled_quantity2, 0),
             NVL(oel.ship_tolerance_above, 0),
             oel.inventory_item_id,
             uom.unit_of_measure
      INTO   x_secondary_qty_ordered,
             x_secondary_qty_received,
             x_secondary_qty_cancelled,
             x_qty_rcv_tolerance,
             x_item_id,
             x_oe_uom
      FROM   oe_order_lines_all oel,
             mtl_units_of_measure uom
      WHERE  oel.line_id = p_oe_order_line_id
      AND    uom.uom_code = oel.order_quantity_uom;

      x_progress                 := '020';
      oe_rma_receiving.get_rma_available_quantity(p_oe_order_line_id,
                                                  p_available_quantity,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data
                                                 );
      x_progress                 := '030';

      FOR c_lines IN get_lines LOOP
         po_uom_s.uom_convert(c_lines.quantity,
                              c_lines.unit_of_measure,
                              x_item_id,
                              x_oe_uom,
                              x_interface_quantity
                             );
         x_interface_qty_in_oe_uom  := NVL(x_interface_qty_in_oe_uom, 0) + NVL(x_interface_quantity, 0);
         x_secondary_interface_qty  := NVL(x_secondary_interface_qty, 0) + NVL(c_lines.secondary_quantity, 0);
         x_secondary_uom            := NVL(x_secondary_uom, c_lines.secondary_unit_of_measure);
      END LOOP;

      x_progress                 := '040';
      p_available_quantity       := p_available_quantity - NVL(x_interface_qty_in_oe_uom, 0);
      p_secondary_available_qty  := x_secondary_qty_ordered - x_secondary_qty_received - x_secondary_qty_cancelled - NVL(x_secondary_interface_qty, 0);

      /*
      ** Calculate the maximum quantity that can be received allowing for
      ** tolerance.
      */
      p_tolerable_quantity       := p_available_quantity + x_qty_rcv_tolerance;

      /*
      ** p_available_quantity can be negative if this shipment has been over
      ** received. In this case, the available quantity that needs to be passed
      ** back should be 0.
      */
      IF (p_available_quantity < 0) THEN
         p_available_quantity  := 0;
      END IF;

      IF (p_secondary_available_qty < 0) THEN
         p_secondary_available_qty  := 0;
      END IF;

      /*
      ** p_tolerable_quantity can be negative if this shipment has been over
      ** received. In this case, the tolerable quantity that needs to be passed
      ** back should be 0.
      */
      IF (p_tolerable_quantity < 0) THEN
         p_tolerable_quantity  := 0;
      END IF;

      /*
      ** Return the PO unit of measure
      */
      p_unit_of_measure          := x_oe_uom;
      asn_debug.put_line('p_oe_order_line_id = ' || p_oe_order_line_id);
      asn_debug.put_line('p_available_quantity = ' || p_available_quantity);
      asn_debug.put_line('p_tolerable_quantity = ' || p_tolerable_quantity);
      asn_debug.put_line('p_unit_of_measure = ' || p_unit_of_measure);
      asn_debug.put_line('p_secondary_available_qty = ' || p_secondary_available_qty);
      asn_debug.put_line('***END*** get_po_quantity');
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('get_rma_quantity',
                                x_progress,
                                SQLCODE
                               );
         RAISE;
   END get_rma_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_shipment_quantity()

===========================================================================*/

PROCEDURE get_shipment_quantity(p_shipment_line_id      IN  NUMBER,
				p_available_quantity IN OUT NOCOPY NUMBER,
				p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
				p_secondary_available_qty IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3)	:= NULL;
x_quantity_shipped		NUMBER		:= 0;
x_quantity_received		NUMBER		:= 0;
x_interface_quantity  		NUMBER		:= 0; /* in primary_uom */
x_shipment_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
x_interface_qty_in_ship_uom NUMBER	:= 0;


/*Bug# 1548597*/
x_secondary_qty_shipped		NUMBER		:= 0;
x_secondary_qty_received		NUMBER		:= 0;
x_secondary_interface_qty  	NUMBER		:= 0;
x_secondary_uom				VARCHAR2(26);
--end bug 1548597


BEGIN

   x_progress := '005';

   /*
   ** Get shipment quantity information.
   */

   SELECT nvl(rsl.quantity_shipped, 0),
	  nvl(rsl.quantity_received, 0),
	  rsl.item_id,
	  rsl.unit_of_measure,
	  /*Bug# 1548597 */
	  nvl(rsl.secondary_quantity_shipped, 0),
	  nvl(rsl.secondary_quantity_received, 0)
	  --End Bug 1548597
   INTO   x_quantity_shipped,
	  x_quantity_received,
	  x_item_id,
	  x_shipment_uom,
	  x_secondary_qty_shipped,
	  x_secondary_qty_received
   FROM   rcv_shipment_lines rsl
   WHERE  rsl.shipment_line_id = p_shipment_line_id;

   x_progress := '010';

   /*
   ** Get any unprocessed receipt transaction against the
   ** shipment. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

      SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
	  min(primary_unit_of_measure)
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type  = 'RECEIVE'
   AND    shipment_line_id = p_shipment_line_id;

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_ship_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_ship_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the shipment uom
	** so that the available quantity can be calculated in the shipment uom
	*/
        x_progress := '015';

	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    x_shipment_uom, x_interface_qty_in_ship_uom);

   END IF;

   /*
   ** Calculate the quantity available to be received.
   */

   p_available_quantity := x_quantity_shipped - x_quantity_received -
			   x_interface_qty_in_ship_uom;

   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_available_quantity < 0) THEN

	p_available_quantity := 0;

   END IF;

   /*
   ** Return the SHIPMENT unit of measure
   */

   p_unit_of_measure := x_shipment_uom;


   /*Bug # 1548597 */
   SELECT nvl(sum(secondary_quantity),0),
	  min(secondary_unit_of_measure)
   INTO   x_secondary_interface_qty,
	  x_secondary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type  = 'RECEIVE'
   AND    shipment_line_id = p_shipment_line_id;

   /*
   ** Calculate the quantity available to be received.
   */

   p_secondary_available_qty := x_secondary_qty_shipped - x_secondary_qty_received -
			   		x_secondary_interface_qty;

   /*
   ** p_available_quantity can be negative if this shipment has been over
   ** received. In this case, the available quantity that needs to be passed
   ** back should be 0.
   */

   IF (p_secondary_available_qty < 0) THEN

	p_secondary_available_qty := 0;

   END IF;
   /*End Bug # 1548597 */

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_shipment_quantity', x_progress, sqlcode);

	RAISE;

END get_shipment_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_transaction_quantity()

===========================================================================*/

PROCEDURE get_transaction_quantity(p_transaction_id        IN  NUMBER,
				   p_available_quantity IN OUT NOCOPY NUMBER,
				   p_unit_of_measure    IN OUT NOCOPY VARCHAR2,
				   p_secondary_available_qty IN OUT NOCOPY NUMBER  ) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_transaction_quantity		NUMBER		:= 0;
x_interface_quantity		NUMBER		:= 0;  /* in primary uom */
x_transaction_uom		VARCHAR2(26);
x_primary_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_interface_qty_in_trx_uom      NUMBER;

/*Bug # 1548597 */
x_secondary_transaction_qty		NUMBER		:= 0;
x_secondary_interface_qty			NUMBER		:= 0;
x_secondary_uom					VARCHAR2(26);
--end bug 1548597

BEGIN

   x_progress := '005';

   /*
   ** Get available supply quantity information.
   */

   /*
   ** There may be no supply quantity hence the exception no data found
   ** needs to be trapped here
   */

   -- bug 4873207
   IF (g_asn_debug = 'Y') THEN
     asn_debug.put_line('get_transaction_quantity >> ' || x_progress );
     asn_debug.put_line('p_transaction_id ' || p_transaction_id);
   END IF;
   -- bug 4873207

   BEGIN

    /*
       Bug#5369121 - Fetching the primary uom from rcv_supply or rcv_transactions
       rather than RTI since it could be null in RTI
    */

   	SELECT 	quantity,
                secondary_quantity, /*Bug#9159988 selecting the secondary quantity from rcv_supply*/
	  	unit_of_measure,
	  	item_id,
                to_org_primary_uom
   	INTO   	x_transaction_quantity,
   	        x_secondary_transaction_qty,
	  	x_transaction_uom,
	  	x_item_id,
                x_primary_uom
   	FROM   	rcv_supply
   	WHERE  	supply_type_code = 'RECEIVING'
   	AND    	supply_source_id = p_transaction_id;

   	/* Bug# 1548597 */
/*   	select  SUM(decode(transaction_type,
		'RECEIVE',	Secondary_Quantity,
		'CORRECT',DECODE(Secondary_Quantity/DECODE(ABS(Secondary_Quantity),0,1,ABS(Secondary_Quantity)),
				1,Secondary_Quantity,
				-1,-1*Secondary_Quantity,
				Secondary_Quantity),
		'RETURN TO VENDOR', Secondary_Quantity,
		'RETURN TO RECEIVING', Secondary_Quantity,
		'ACCEPT', Secondary_Quantity,
		'REJECT', Secondary_Quantity,
		'DELIVER',-1*Secondary_Quantity,
		 'UNORDERED', Secondary_Quantity,
		 'MATCH',Secondary_Quantity,
		'TRANSFER',Secondary_quantity,0))
	into 	x_secondary_transaction_qty
 	from  	rcv_transactions
	start  with  transaction_id = p_transaction_id
	connect by parent_transaction_id  =  prior transaction_id;*/
	-- Bug# 1548597

   EXCEPTION

	WHEN NO_DATA_FOUND THEN

	 	x_transaction_quantity := 0;

                -- bug 4873207
                SELECT  rt.unit_of_measure,
                        rsl.item_id,
                        rt.primary_unit_of_measure
                INTO    x_transaction_uom,
                        x_item_id,
                        x_primary_uom
                FROM    rcv_transactions rt,
                        rcv_shipment_lines rsl
                WHERE   rsl.shipment_line_id = rt.shipment_line_id
                AND     rt.transaction_id = p_transaction_id;
                -- bug 4873207


	WHEN OTHERS THEN RAISE;

   END;

   -- bug 4873207
   IF (g_asn_debug = 'Y') THEN
     asn_debug.put_line('get_transaction_quantity >> ');
     asn_debug.put_line('x_transaction_quantity '||x_transaction_quantity);
     asn_debug.put_line('x_transaction_uom '||x_transaction_uom);
     asn_debug.put_line('item_id '||x_item_id);
     asn_debug.put_line('x_secondary_transaction_qty '||x_secondary_transaction_qty);
   END IF;
   -- bug 4873207


   x_progress := '010';

   /*
   ** Get any unprocessed receipt transaction against the
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */
		    /*Bug#9159988 */
   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0),
          nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * secondary_quantity,
                          secondary_quantity))
                  ,0)


   INTO   x_interface_quantity,
          x_secondary_interface_qty
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id;

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_trx_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_trx_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the transaction uom
	** so that the available quantity can be calculated in the trx uom
	*/
        IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Before uom_convert:');
                asn_debug.put_line('x_interface_quantity:' || x_interface_quantity);
                asn_debug.put_line('x_primary_uom:' || x_primary_uom);
                asn_debug.put_line('x_transaction_uom:' || x_transaction_uom);
                asn_debug.put_line('x_item_id:' || x_item_id);
        END IF;

        x_progress := '015';
	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    x_transaction_uom, x_interface_qty_in_trx_uom);

   END IF;



   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_quantity := x_transaction_quantity - x_interface_qty_in_trx_uom;

   /*
   ** Return the parent transactions unit of measure
   */

   p_unit_of_measure := x_transaction_uom;

   /*dbms_output.put_line ('get_transaction_quantity.p_available_quantity = '||
			 to_char(p_available_quantity));

	dbms_output.put_line ('get_transaction_quantity.p_unit_of_measure = '||
        p_unit_of_measure);*/

    /* Bug 1548597 */
 /*  SELECT nvl(sum(decode(transaction_type,
			 'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),
-999,primary_quantity,nvl(interface_transaction_qty,0))),
			 secondary_quantity)),0),
	  min(secondary_unit_of_measure)
   INTO   x_secondary_interface_qty,
	  x_secondary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id; */

   p_secondary_available_qty := x_secondary_transaction_qty - x_secondary_interface_qty;
   -- end bug 1548597


EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_transaction_quantity', x_progress, sqlcode);

   	RAISE;

END get_transaction_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_transaction_amount()

  p_transaction_id => RECEIVE transaction

  Called when:
   txn type = NEGATIVE CORRECT AND parent type = RECEIVE => get_txn_amt(parent_id)
   txn type = POSITIVE CORRECT AND parent type = DELIVER => get_txn_amt(grand_parent_id)

===========================================================================*/

PROCEDURE get_transaction_amount(p_transaction_id    IN            NUMBER,
				                 p_available_amount  IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_transaction_amount		NUMBER		:= 0;
x_interface_amount		NUMBER		:= 0;
x_interface_deliver_amount	NUMBER		:= 0;
l_deliver_id                    NUMBER;
l_receive_correct               NUMBER;
l_deliver_correct               NUMBER;

BEGIN

   x_progress := '005';

   /*
   ** Get available amount information from processed transactions.
   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('get_transaction_amount ' );
		asn_debug.put_line('p_transaction_id '||p_transaction_id );
	end if;
   BEGIN

    SELECT nvl(sum(amount),0)
    into l_receive_correct
    from rcv_transactions
    where parent_transaction_id = p_transaction_id
    and transaction_type = 'CORRECT';

    IF (g_asn_debug = 'Y') THEN
	asn_debug.put_line('l_receive_correct '||l_receive_correct);
    end if;
    select transaction_id
    into l_deliver_id
    from rcv_transactions
    where parent_transaction_id= p_transaction_id
    and transaction_type='DELIVER';

    IF (g_asn_debug = 'Y') THEN
	asn_debug.put_line('l_deliver_id '||l_deliver_id);
    end if;
    SELECT nvl(sum(amount),0)
    into l_deliver_correct
    from rcv_transactions
    where parent_transaction_id = l_deliver_id
    and transaction_type = 'CORRECT';

    IF (g_asn_debug = 'Y') THEN
	asn_debug.put_line('l_deliver_correct '||l_deliver_correct);
    end if;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	 	x_transaction_amount := 0;
   END;

   x_progress := '010';

   /*
   ** Get any unprocessed receipt transaction against the
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))),
                         decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))
                  )),0)
   INTO   x_interface_amount
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('x_interface_amount '||x_interface_amount);
	end if;

    -- do the same for the children of the receive transaction
    SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))),
                         decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))
                  )),0)
    INTO   x_interface_deliver_amount
    FROM   rcv_transactions_interface
    WHERE  (transaction_status_code = 'PENDING'
           and processing_status_code <> 'ERROR')
    AND    parent_transaction_id = l_deliver_id;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('x_interface_deliver_amount '||x_interface_deliver_amount);
    END IF;

   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_amount := l_receive_correct - l_deliver_correct - (x_interface_amount - x_interface_deliver_amount);

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_available_amount '||p_available_amount);
	end if;

EXCEPTION

   WHEN OTHERS THEN

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('Exception in get_transaction_amount');
	end if;
      	po_message_s.sql_error('get_transaction_amount', x_progress, sqlcode);

   	RAISE;

END get_transaction_amount;

/*===========================================================================

  PROCEDURE NAME:	get_correction_quantity()

===========================================================================*/

PROCEDURE get_correction_quantity(p_correction_type         IN  VARCHAR2,
				  p_parent_transaction_type IN  VARCHAR2,
				  p_receipt_source_code     IN  VARCHAR2,
				  p_parent_id               IN  NUMBER,
				  p_grand_parent_id         IN  NUMBER,
				  p_available_quantity      IN OUT NOCOPY NUMBER,
				  p_tolerable_quantity      IN OUT NOCOPY NUMBER,
				  p_unit_of_measure         IN OUT NOCOPY VARCHAR2,
				  p_secondary_available_qty      IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) := NULL;
x_parent_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom                   VARCHAR2(26);
use_primary_uom                   VARCHAR2(26) := NULL;
x_trx_quantity			NUMBER := 0;
X_interface_quantity            NUMBER := 0;
invalid_parent_trx_type		EXCEPTION;
 x_interface_qty_in_trx_uom     NUMBER := 0;
l_quantity_in_parent_uom        RCV_TRANSACTIONS.quantity%TYPE; -- Bug 2737257

/*--Bug 17180949 Begin*/
x_available_quantity             NUMBER;
x_tolerable_quantity             NUMBER;
x_secondary_available_qty        NUMBER;
x_po_line_location_id            NUMBER;
/*--Bug 17180949 End*/


-- <Bug 9342280 : Added for CLM project>
l_po_line_location_id     NUMBER;
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>

BEGIN

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' in get_correction_quantity');
	end if;
   IF p_correction_type = 'NEGATIVE' THEN

	/*
	** Return transactions and negative corrections have the
	** same logic for getting available quantity.
	*/

	IF (p_parent_transaction_type IN ('UNORDERED', 'RECEIVE', 'MATCH',
					'TRANSFER', 'ACCEPT', 'REJECT')) THEN

	   /*
	   ** All of the above transactions supply is stored in RCV_SUPPLY.
	   ** Use get_transaction_quantity logic to get the available quantity
	   ** and uom.
	   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' Before get_transaction_quantity');
	end if;
	   get_transaction_quantity(p_parent_id, p_available_quantity,
				    p_unit_of_measure,p_secondary_available_qty);


	ELSIF (p_parent_transaction_type IN
		('RETURN TO VENDOR', 'RETURN TO CUSTOMER', 'DELIVER')) THEN

	   /*
	   ** Return to Vendor and Deliver transactions do not have any
	   ** supply associated with them. You need to get the available
	   ** quantity from the actual transaction tables themselves.
	   **
	   ** Debug - Currently, (22-MAR-95) we do not support corrections
	   ** to Return To Receiving transactions. However, it is a good
	   ** candidate for an ER. If we do, we need to add to this function
	   ** to handle this case.
	   */
	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' Before get_deliver_quantity');
	end if;

	   get_deliver_quantity(p_parent_id, p_available_quantity,
				p_unit_of_measure,p_secondary_available_qty);

	  /*Bug 17180949 begin*/
			IF (p_parent_transaction_type = 'RETURN TO VENDOR') THEN
		      SELECT rt.po_line_location_id
		      INTO   x_po_line_location_id
		      FROM   rcv_transactions rt
		      WHERE  rt.transaction_id = p_parent_id;

			  	get_po_quantity(x_po_line_location_id, x_available_quantity,
					  x_tolerable_quantity, p_unit_of_measure,x_secondary_available_qty);

		      if (p_available_quantity > x_tolerable_quantity) THEN
		          p_available_quantity := x_tolerable_quantity;
		          p_secondary_available_qty := x_secondary_available_qty;
		      END if;
		  END if;
		/*Bug 17180949 end*/



	ELSE

	   /*
	   ** The function was called with the wrong p_parent_transaction_type
	   ** parameter. Raise an invalid parent transaction type exception.
	   */

	   RAISE invalid_parent_trx_type;

	END IF;  /* Matches if (p_parent_transaction_type IN .... */

   ELSIF p_correction_type = 'POSITIVE' THEN

	/*
	** In general, for +ve correction quantity, we need to calculate the
	** outstanding quantity against the grand parent transaction. e.g.
	**
	** Receipt 		100   - p_grand_parent_id
	**    Transfer   	 60   - p_parent_id
	**       Correct 	 ??   - p_transaction_type
	**
	** To do a +ve correction against the transfer, we need to calculate
	** the outstanding quantity against the Receipt (40).
	*/

	IF (p_parent_transaction_type IN ('RECEIVE', 'MATCH')) THEN

	   /*
	   ** Need to calculate the outstanding quantity to be received
	   ** either against the shipment or the PO depending on the
	   ** receipt_source_code.
	   ** This is the same logic to be used for get_receive_quantity().
	   ** p_grand_parent_id is either the po_line_location_id or the
	   ** rcv_shipment_line_id as the case may be.
	   */

	   get_receive_quantity(p_grand_parent_id, p_receipt_source_code,
			  	p_available_quantity, p_tolerable_quantity,
				p_unit_of_measure,p_secondary_available_qty);

	ELSIF (p_parent_transaction_type IN ('TRANSFER', 'ACCEPT', 'REJECT',
		'DELIVER', 'RETURN TO VENDOR', 'RETURN TO CUSTOMER')) THEN

	   /*
	   ** Need to calculate the outstanding quantity against the parent
	   ** of the above transactions. This will always be a receiving
	   ** transaction. Hence, use get_transaction_quantity() function.
	   ** p_grand_parent_id is the grand parent transaction for which
	   ** we need to get the outstanding quantity.
	   */

	   get_transaction_quantity(p_grand_parent_id, p_available_quantity,
				    p_unit_of_measure,p_secondary_available_qty);

	ELSIF (p_parent_transaction_type IN ('UNORDERED')) THEN

	   /*
	   ** Need to calculate the outstanding quantity against the parent
	   ** of the above transactions. This will always be a receiving
	   ** transaction. Hence, use get_transaction_quantity() function.
	   ** p_grand_parent_id is the grand parent transaction for which
	   ** we need to get the outstanding quantity.  The p_grand_parent_id
           ** which is set in the rcv_corrections_sv.post_query to be the
           ** parent transaction id
	   */

	   get_transaction_quantity(p_grand_parent_id, p_available_quantity,
				    p_unit_of_measure,p_secondary_available_qty);
	   /*
           ** This is kind of goofy but since there are no limits on the
           ** positive correction to the unorderded receipt we have to just
           ** make this a huge quantity.
           */

 	   p_available_quantity := 9999999999999999;

	ELSE

	   /*
	   ** The function was called with the wrong p_parent_transaction_type
	   ** parameter. Raise an invalid parent transaction type exception.
	   */

	   RAISE invalid_parent_trx_type;

	END IF;  /* Matches if p_parent_transaction_type IN .... */

   	/*
   	** Convert the available quantity and tolerable quantity to the
   	** parent's uom. This is neccessary because in the case of a +ve
   	** correction, the available quantity will be in the grand parent's
   	** unit of measure.
   	*/

   	/*
   	** Get the parent transaction's info.
   	*/

   	x_progress := '005';

   	select 	rt.unit_of_measure,
	  	rsl.item_id
   	into   	x_parent_uom,
	  	x_item_id
   	from   	rcv_transactions rt,
	  	rcv_shipment_lines rsl
   	where  	rt.transaction_id = p_parent_id
   	and    	rt.shipment_line_id = rsl.shipment_line_id;

   	/*
   	** Convert available quantity in the parent's unit of measure
   	*/

        /*dbms_output.put_line ('get_correction_qty : p_unit_of_measure : '||
          p_unit_of_measure);

        dbms_output.put_line ('get_correction_qty : x_parent_uom : '||
          x_parent_uom);*/


        /* Bug#1769067.smididud.Date:05/15/2001. */

        IF ( (p_available_quantity <> 0)  AND (p_unit_of_measure IS NOT  NULL) ) THEN

   		po_uom_s.uom_convert(p_available_quantity, p_unit_of_measure,
			     x_item_id, x_parent_uom,
                             l_quantity_in_parent_uom -- Bug 2737257
                            );
                p_available_quantity := l_quantity_in_parent_uom; -- Bug 2737257

	END IF;

   	/*
   	** Convert the tolerable quantity to the parent's unit of measure
   	*/

	IF (p_tolerable_quantity <> 0) THEN

      -- <Bug 9342280 : Added for CLM project>
      SELECT  rt.po_line_location_id
   	    INTO  l_po_line_location_id
   	    FROM  rcv_transactions rt
   	   WHERE  rt.transaction_id = p_parent_id ;


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
          asn_debug.put_line('line_location_id : ' || l_po_line_location_id);
      END IF;

      IF l_po_line_location_id IS NOT NULL THEN
      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => l_po_line_location_id,
                                                p_po_distribution_id  => NULL);
      END IF;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;

      IF l_is_clm_po = 'Y' THEN

          IF (g_asn_debug = 'Y') THEN
		         asn_debug.put_line(' before po_clm_intg_grp.get_funding_info()');
	        end if;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => l_po_line_location_id,
                                             p_po_distribution_id      => NULL,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status
                                    );

            IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
              asn_debug.put_line('l_quantity_funded: ' || l_quantity_funded);
              asn_debug.put_line('l_quantity_received : ' || l_quantity_received);
              asn_debug.put_line('l_quantity_cancelled: ' || l_quantity_cancelled);
            END IF;

      END IF;

      IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
          IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('set p_tolerable_quantity for clm po');
          END IF;

          p_tolerable_quantity := p_available_quantity;

      ELSE
          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('set p_tolerable_quantity for non-clm po');
          END IF;
      -- <CLM END>


   		po_uom_s.uom_convert(p_tolerable_quantity, p_unit_of_measure,
			     x_item_id, x_parent_uom,
                             l_quantity_in_parent_uom -- Bug 2737257
                            );
                p_tolerable_quantity := l_quantity_in_parent_uom; -- Bug 2737257

      END IF;  -- <Bug 9342280 : Added for CLM project>

	END IF;

   	/*
   	** Return parent unit of measure
   	*/

   	p_unit_of_measure := x_parent_uom;

   END IF;   /* Matches if p_correction_type = 'NEGATIVE' ....  */


EXCEPTION

   WHEN invalid_parent_trx_type THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;


   WHEN OTHERS THEN

      	po_message_s.sql_error('get_correction_quantity', x_progress, sqlcode);

   	RAISE;

END get_correction_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_correction_amount()

===========================================================================*/

PROCEDURE get_correction_amount(p_correction_type         IN  VARCHAR2,
				  p_parent_transaction_type IN  VARCHAR2,
				  p_receipt_source_code     IN  VARCHAR2,
				  p_parent_id               IN  NUMBER,
				  p_grand_parent_id         IN  NUMBER,
				  p_available_amount      IN OUT NOCOPY NUMBER,
				  p_tolerable_amount      IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) := NULL;
x_trx_amount			NUMBER := 0;
X_interface_amount            NUMBER := 0;
invalid_parent_trx_type		EXCEPTION;

-- <Bug 9342280 : Added for CLM project>
l_po_line_location_id     NUMBER;
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>

BEGIN

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_correction_type '||p_correction_type );
		asn_debug.put_line('p_parent_transaction_type '||p_parent_transaction_type );
		asn_debug.put_line('p_receipt_source_code '||p_receipt_source_code );
		asn_debug.put_line('p_parent_id '||p_parent_id );
		asn_debug.put_line('p_grand_parent_id '||p_grand_parent_id );
	end if;
   IF p_correction_type = 'NEGATIVE' THEN

	/*
	** Return transactions and negative corrections have the
	** same logic for getting available quantity.
	*/

	IF p_parent_transaction_type = 'RECEIVE' THEN

	   /*
	   ** All of the above transactions supply is stored in RCV_SUPPLY.
	   ** Use get_transaction_quantity logic to get the available quantity
	   ** and uom.
	   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' before get_transaction_amount');
	end if;
	   get_transaction_amount(p_parent_id, p_available_amount);


	ELSIF p_parent_transaction_type = 'DELIVER' THEN

	   /*
	   ** Return to Vendor and Deliver transactions do not have any
	   ** supply associated with them. You need to get the available
	   ** quantity from the actual transaction tables themselves.
	   **
	   ** Debug - Currently, (22-MAR-95) we do not support corrections
	   ** to Return To Receiving transactions. However, it is a good
	   ** candidate for an ER. If we do, we need to add to this function
	   ** to handle this case.
	   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' before get_deliver_amount');
	end if;
	   get_deliver_amount(p_parent_id, p_available_amount);

	ELSE

	   /*
	   ** The function was called with the wrong p_parent_transaction_type
	   ** parameter. Raise an invalid parent transaction type exception.
	   */

	   RAISE invalid_parent_trx_type;

	END IF;  /* Matches if (p_parent_transaction_type IN .... */

   ELSIF p_correction_type = 'POSITIVE' THEN

	/*
	** In general, for +ve correction quantity, we need to calculate the
	** outstanding quantity against the grand parent transaction. e.g.
	**
	** Receipt 		100   - p_grand_parent_id
	**    Transfer   	 60   - p_parent_id
	**       Correct 	 ??   - p_transaction_type
	**
	** To do a +ve correction against the transfer, we need to calculate
	** the outstanding quantity against the Receipt (40).
	*/

	IF p_parent_transaction_type = 'RECEIVE' THEN

	   /*
	   ** Need to calculate the outstanding quantity to be received
	   ** either against the shipment or the PO depending on the
	   ** receipt_source_code.
	   ** This is the same logic to be used for get_receive_quantity().
	   ** p_grand_parent_id is either the po_line_location_id or the
	   ** rcv_shipment_line_id as the case may be.
	   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' before get_receive_amount');
	end if;
	   get_receive_amount(p_grand_parent_id, p_receipt_source_code,
			  	p_available_amount, p_tolerable_amount);

	ELSIF p_parent_transaction_type = 'DELIVER' THEN

	   /*
	   ** Need to calculate the outstanding quantity against the parent
	   ** of the above transactions. This will always be a receiving
	   ** transaction. Hence, use get_transaction_quantity() function.
	   ** p_grand_parent_id is the grand parent transaction for which
	   ** we need to get the outstanding quantity.
	   */

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line(' before get_transaction_amount');
	end if;
	   get_transaction_amount(p_grand_parent_id, p_available_amount);

	ELSE

	   /*
	   ** The function was called with the wrong p_parent_transaction_type
	   ** parameter. Raise an invalid parent transaction type exception.
	   */

	   RAISE invalid_parent_trx_type;

	END IF;  /* Matches if p_parent_transaction_type IN .... */


  -- <Bug 9342280 : Added for CLM project>
  IF (p_tolerable_amount <> 0) THEN

      SELECT  rt.po_line_location_id
   	    INTO  l_po_line_location_id
   	    FROM  rcv_transactions rt
   	   WHERE  rt.transaction_id = p_parent_id ;


      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
          asn_debug.put_line('line_location_id : ' || l_po_line_location_id);
      END IF;

      IF l_po_line_location_id IS NOT NULL THEN
      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => l_po_line_location_id,
                                                p_po_distribution_id  => NULL);
      END IF;

      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;

      IF l_is_clm_po = 'Y' THEN

          IF (g_asn_debug = 'Y') THEN
		         asn_debug.put_line(' before po_clm_intg_grp.get_funding_info()');
	        end if;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => l_po_line_location_id,
                                             p_po_distribution_id      => NULL,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status
                                    );

            IF (g_asn_debug = 'Y') THEN
              asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
              asn_debug.put_line('l_amount_funded: ' || l_amount_funded);
              asn_debug.put_line('l_amount_received : ' || l_amount_received);
              asn_debug.put_line('l_amount_cancelled: ' || l_amount_cancelled);
            END IF;

      END IF;

      IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
          IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('set p_tolerable_amount for CLM PO');
          END IF;

          p_tolerable_amount := p_available_amount;

      END IF;


      END IF;
      -- <CLM END>

   END IF;   /* Matches if p_correction_type = 'NEGATIVE' ....  */


EXCEPTION

   WHEN invalid_parent_trx_type THEN

	/*
	** debug - need to define a new message and also need to understand
	** how exactly to handle application error messages. A call to
	** some generic API is needed.
	*/

	RAISE;


   WHEN OTHERS THEN

      	po_message_s.sql_error('get_correction_amount', x_progress, sqlcode);

   	RAISE;

END get_correction_amount;

/* modified for bug 13892629
 * Override this procedure by add one public precedure get_deliver_quantity
 */
PROCEDURE get_deliver_quantity(p_transaction_id            IN  NUMBER,
                               p_available_quantity        IN OUT NOCOPY NUMBER,
                               p_unit_of_measure           IN OUT NOCOPY VARCHAR2,
                               p_secondary_available_qty   IN OUT NOCOPY NUMBER ) IS
BEGIN

  get_deliver_quantity(p_transaction_id,
                       NULL,
                       p_available_quantity,
                       p_unit_of_measure,
                       p_secondary_available_qty);

END get_deliver_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_deliver_quantity()

===========================================================================*/
PROCEDURE get_deliver_quantity(p_transaction_id                IN  NUMBER,
                               p_interface_transaction_id      IN  NUMBER,    /*added in bug 13892629*/
                               p_available_quantity            IN OUT NOCOPY NUMBER,
                               p_unit_of_measure               IN OUT NOCOPY VARCHAR2,
                               p_secondary_available_qty       IN OUT NOCOPY NUMBER ) IS
x_progress 			VARCHAR2(3) 	:= NULL;
x_deliver_quantity		NUMBER		:= 0;
x_transaction_quantity		NUMBER		:= 0;
x_trx_quantity	       	        NUMBER		:= 0;  /* in primary uom */
x_interface_quantity		NUMBER		:= 0;  /* in primary uom */
primary_trx_qty			NUMBER		:= 0;  /* in primary uom */
x_deliver_uom			VARCHAR2(26);
x_primary_uom			VARCHAR2(26);
use_primary_uom			VARCHAR2(26)    := NULL;
x_item_id			NUMBER;
x_interface_qty_in_trx_uom      NUMBER;

/* Bug# 1548597 */
x_secondary_deliver_quantity		NUMBER		:= 0;
x_secondary_deliver_uom			VARCHAR2(26);
x_secondary_interface_qty		NUMBER		:= 0;
x_secondary_trx_quantity	       	NUMBER		:= 0;
-- end bug 1548597

/* Bug 3735987 Start declarations*/
l_consigned_flag                rcv_transactions.consigned_flag%TYPE;
l_org_id                        rcv_transactions.organization_id%TYPE;
l_consigned_quantity            NUMBER;
l_opm_installed                 BOOLEAN;
l_opm_process_org               VARCHAR2(1);
l_vendor_site_id                rcv_transactions.vendor_site_id%TYPE;
l_subinventory                  rcv_transactions.subinventory%TYPE;
l_locator_id                    rcv_transactions.locator_id%TYPE;
l_po_header_id                  rcv_transactions.po_header_id%TYPE;
l_po_line_id                    rcv_transactions.po_line_id%TYPE;
l_item_revision                 rcv_shipment_lines.item_revision%TYPE;
l_primary_rt_uom                rcv_transactions.primary_unit_of_measure%TYPE;

l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(2000);
l_revision_control              VARCHAR2(1);
l_quantity_on_hand              NUMBER;
l_consigned_deliver_uom_qty     NUMBER;
/* Bug 3735987 End declarations*/

x_rtv_running_qty               NUMBER; -- rtv project
x_rtv_running_sec_qty           NUMBER; -- rtv project

/* bug 13892629 */
l_lpn_id                        NUMBER;

BEGIN

   x_progress := '005';

   /*
   ** Get available transaction quantity information.
   */

   /* Bug 3735987 : If the item is consigned then we need to check the quantity
   **      available in the consigned stock. We cannot have returns or corrections
   **      on the quantity in the Regular stock.
   */

   select rt.quantity,
	  rt.unit_of_measure,
	  rsl.item_id,
	  /* bug# 1548597 */
	  rt.secondary_quantity,
	  rt.secondary_unit_of_measure,
	  --end  bug # 1548597
    /* Bug 3735987 Start  */
	  rt.consigned_flag,
	  rt.organization_id,
	  rt.vendor_site_id,
	  rt.subinventory,
	  rt.locator_id,
	  rt.po_header_id,
	  rt.po_line_id,
	  rsl.item_revision,
	  lpn_id, /*added in bug 13892629 */
	  rt.primary_unit_of_measure
   into   x_deliver_quantity,
	  x_deliver_uom,
	  x_item_id,
	  x_secondary_deliver_quantity,
	  x_secondary_deliver_uom,
 	  l_consigned_flag ,
	  l_org_id,
	  l_vendor_site_id,
	  l_subinventory ,
	  l_locator_id,
	  l_po_header_id,
	  l_po_line_id,
	  l_item_revision,
	  l_lpn_id, /*added in bug 13892629 */
	  l_primary_rt_uom
   from   rcv_transactions rt,
	  rcv_shipment_lines rsl
   where  rt.transaction_id = p_transaction_id
   and    rt.shipment_line_id = rsl.shipment_line_id;

   x_progress := '010';


   /*
   ** Get any unprocessed receipt transaction against the
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0),
	  min(primary_unit_of_measure)
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id;

   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('p_transaction_id     = ' || p_transaction_id);
       asn_debug.put_line('x_interface_quantity = ' || x_interface_quantity);
   END IF;

   -- rtv project : start
   SELECT nvl( sum(primary_quantity),0)
   INTO   x_rtv_running_qty
   FROM   rcv_transactions_interface rti
   WHERE  parent_transaction_id = p_transaction_id
   AND    processing_status_code = 'RUNNING'
   AND    transaction_type IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING')
   AND    exists ( select 1 from wsh_delivery_details wdd
                   where  wdd.delivery_detail_id = rti.interface_source_line_id
                   and    wdd.source_code = 'RTV');

   x_interface_quantity := x_interface_quantity - x_rtv_running_qty;

   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('x_rtv_running_qty     = ' || x_rtv_running_qty);
       asn_debug.put_line('x_interface_quantity  = ' || x_interface_quantity);
   END IF;

   -- rtv project : end

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_trx_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_trx_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the transaction uom
	** so that the available quantity can be calculated in the trx uom
	*/

	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    x_deliver_uom, x_interface_qty_in_trx_uom);

   END IF;

   /* Bug 1548597 */
   SELECT nvl(sum(decode(transaction_type,
			 'CORRECT', -1 * secondary_quantity,
			 secondary_quantity)),0)
   INTO   x_secondary_interface_qty
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id;

   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('x_secondary_interface_qty = ' || x_secondary_interface_qty);
   END IF;

   -- rtv project : start
   SELECT nvl(sum(secondary_quantity),0)
   INTO   x_rtv_running_sec_qty
   FROM   rcv_transactions_interface rti
   WHERE  parent_transaction_id = p_transaction_id
   AND    processing_status_code = 'RUNNING'
   AND    transaction_type IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING')
   AND    exists ( select 1 from wsh_delivery_details wdd
                   where  wdd.delivery_detail_id = rti.interface_source_line_id
                   and    wdd.source_code = 'RTV');

   x_secondary_interface_qty := x_secondary_interface_qty - (2 * x_rtv_running_sec_qty);

   IF (g_asn_debug = 'Y') THEN
       asn_debug.put_line('x_rtv_running_sec_qty      = ' || x_rtv_running_sec_qty);
       asn_debug.put_line('x_secondary_interface_qty  = ' || x_secondary_interface_qty);
   END IF;

   -- rtv project : end


   p_secondary_available_qty := x_secondary_deliver_quantity - x_secondary_interface_qty;

   -- end bug# 1548507

   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_quantity := x_deliver_quantity - x_interface_qty_in_trx_uom;

   /*
   ** Return the parent transactions unit of measure
   */

   p_unit_of_measure := x_deliver_uom;


   /*
   ** Get any rows already precessed against this transaction
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(decode(transaction_type,
			 'CORRECT', -1 * primary_quantity,
			 primary_quantity)),0),
	  min(primary_unit_of_measure)
   INTO   x_trx_quantity,
	  x_primary_uom
   FROM   rcv_transactions
   WHERE  parent_transaction_id = p_transaction_id
   AND    transaction_type in ('CORRECT','RETURN TO RECEIVING');

   IF (x_primary_uom IS NOT NULL) THEN

       use_primary_uom := x_primary_uom;

   END IF;

   /* Bug# 1548597 */
   SELECT nvl(sum(decode(transaction_type,
			 'CORRECT', -1 * secondary_quantity,
			 secondary_quantity)),0)
   INTO   x_secondary_trx_quantity
   FROM   rcv_transactions
   WHERE  parent_transaction_id = p_transaction_id
   AND    transaction_type in ('CORRECT','RETURN TO RECEIVING');
   --end  Bug# 1548597

   IF (x_trx_quantity <> 0 AND use_primary_uom IS NOT NULL) THEN

	/*
	** There is unprocessed quantity. Convert it to the transaction uom
	** so that the available quantity can be calculated in the trx uom
	*/
        /*dbms_output.put_line ('get_correction_qty : use_primary_uom: '||
          use_primary_uom);

        dbms_output.put_line ('get_correction_qty : p_unit_of_measure : '||
          p_unit_of_measure);*/


        x_progress := '015';

        /* Bug# 2274636 : UOM convert function should be called only
        ** when uoms are different. Calling the UOM convert function
        ** at this place affects the computation of available quantity
        */

        If ( use_primary_uom = p_unit_of_measure ) then
          primary_trx_qty := x_trx_quantity ;
        else
	  po_uom_s.uom_convert(x_trx_quantity,
    			       use_primary_uom, x_item_id,
			       p_unit_of_measure, primary_trx_qty);
        end if;


      /*
      ** Calculate the quantity available to be transacted
     */

      p_available_quantity :=  p_available_quantity - primary_trx_qty;

      /* Bug 1548597 */
      p_secondary_available_qty :=  p_secondary_available_qty - x_secondary_trx_quantity;
      --end  Bug# 1548597


   END IF;

   /*dbms_output.put_line ('Convert = ' || to_char(primary_trx_qty));
   dbms_output.put_line ('Avail = ' || to_char(p_available_quantity ));*/

 /*
 ** Bug#4587282
 ** Moved the following piece of code here so that the stock in
 ** consigned inventory would be checked against the actual
 ** quantity available for the parent transaction
 */
 IF (l_consigned_flag = 'Y') THEN
      /* INVCONV PBAMB BEGIN - Remove the restriction for consigned items */
      /* If item is consigned, check if OPM is installed and the organization is a
      ** OPM process organization. We do not need to check the stock availability
      ** for OPM enabled organization.
      DECLARE
    	opm_status varchar2(10);
	opm_ind varchar2(10);
	opm_ora_schema varchar2(10);
      BEGIN
         l_opm_installed    := fnd_installation.get_app_info('GMI',opm_status,opm_ind,opm_ora_schema);
	 l_opm_process_org  := PO_GML_DB_COMMON.check_process_org(l_org_id);
      END;

      IF NOT(( l_opm_installed = TRUE ) AND (l_opm_process_org = 'Y')) THEN
      */
      /* Check for the item revision control. If item is not revision controlled
      ** pass the item revision as null.
      */
        SELECT decode(msi.revision_qty_control_code,1,'F',2,'T')
          INTO   l_revision_control
          FROM   mtl_system_items_b msi
        WHERE  msi.inventory_item_id = x_item_id
          AND  msi.organization_id   = l_org_id;

        IF ( l_revision_control = 'F' ) THEN
	   l_item_revision := NULL;
        END IF;

    /*begin fix of bug 13892629 */
   IF (p_interface_transaction_id IS NOT NULL) THEN
       select    FROM_SUBINVENTORY,
                 FROM_LOCATOR_ID
         into    l_subinventory,
                 l_locator_id
         from    rcv_transactions_interface
        where    interface_transaction_id = p_interface_transaction_id;
   END IF;

	/* Call inventory API to get quantity available in consigned inventory.
	*/
  /*For WMS org, as LPN involved, we need to do different validation
    This is the same as WMSTXERE.pld does */
   IF (l_lpn_id is not null and l_lpn_id > 0) THEN

     INV_CONSIGNED_VALIDATIONS.GET_CONSIGNED_LPN_QUANTITY(
                          x_return_status => l_return_status,
                          x_return_msg => l_msg_data,
                          p_tree_mode => 2,
                          p_organization_id => l_org_id,
                          p_owning_org_id => l_vendor_site_id,
                          p_planning_org_id => NULL,
                          p_inventory_item_id => x_item_id,
                          p_is_revision_control => l_revision_control,
                          p_is_lot_control => 'F',
                          p_is_serial_control => 'F',
                          p_revision => l_item_revision,
                          p_lot_number => NULL,
                          p_lot_expiration_date => NULL,
                          p_subinventory_code => l_subinventory,
                          p_locator_id => l_locator_id,
                          p_source_type_id => 1,
                          p_demand_source_line_id => l_po_line_id,
                          p_demand_source_header_id => l_po_header_id,
                          p_demand_source_name => NULL,
                          p_onhand_source => 3,
                          p_cost_group_id => NULL,
                          p_query_mode => 1,
                          p_lpn_id => l_lpn_id,
                          x_qoh => l_quantity_on_hand,
                          x_att => l_consigned_quantity);

   ELSE

     INV_CONSIGNED_VALIDATIONS_GRP.get_consigned_quantity (
                          p_api_version_number       => 1.0,
                          p_init_msg_lst             => 'F',
                          x_return_status            => l_return_status,
                          x_msg_count                => l_msg_count,
                          x_msg_data                 => l_msg_data,
                          p_tree_mode                => NULL,
                          p_organization_id          => l_org_id,
                          p_owning_org_id            => l_vendor_site_id,
                          p_planning_org_id          => NULL,
                          p_inventory_item_id        => x_item_id,
                          p_is_revision_control      => l_revision_control,
                          p_is_lot_control           => 'F',
                          p_is_serial_control        => 'F',
                          p_revision                 => l_item_revision,
                          p_lot_number               => NULL,
                          p_lot_expiration_date      => NULL,
                          p_subinventory_code        => l_subinventory,
                          p_locator_id               => l_locator_id,
                          p_source_type_id           => 1,
                          p_demand_source_line_id    => l_po_line_id,
                          p_demand_source_header_id  => l_po_header_id,
                          p_demand_source_name       => NULL,
                          p_onhand_source            => 3,
                          p_cost_group_id            => NULL,
                          p_query_mode               => 1,
                          x_qoh                      => l_quantity_on_hand,
                          x_att                      => l_consigned_quantity);

   END IF;
   /*end fix of bug 13892629 */

	 IF (l_return_status = 'S') THEN
	 /* The Inventory API returns the quantity in primary UOM. We need to
	 ** convert the quantity in the deliver UOM.
	 */
	   IF ( l_primary_rt_uom <> x_deliver_uom ) THEN
             PO_UOM_S.uom_convert(l_consigned_quantity,
	                          l_primary_rt_uom,
	                          x_item_id,
	   	                  x_deliver_uom,
		  	          l_consigned_deliver_uom_qty );
           ELSE
  	     l_consigned_deliver_uom_qty := l_consigned_quantity;
           END IF;

	   /* If consigned quantity is greater than or equal to the delivered quantity,
	   ** then the available quantity is same as the quantity delivered. Else the
	   ** available quantity is equal to the quantity in consigned inventory.
	   */
           -- Bug 4587282 : use p_available_quantity instead of x_deliver_quantity in the IF stmt.
          /* IF ( l_consigned_deliver_uom_qty < x_deliver_quantity ) THEN
	       x_deliver_quantity :=  l_consigned_deliver_uom_qty;
           END IF;
	  */
	   IF ( l_consigned_deliver_uom_qty < p_available_quantity ) THEN
               p_available_quantity :=  l_consigned_deliver_uom_qty;
           END IF;
         ELSE
	    IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('Error in get_deliver_quantity() during call to INV consigned API');
		asn_debug.put_line('Return status : '||l_return_status);
		asn_debug.put_line('Error Message : '||SUBSTRB(l_msg_data,1,50));
            END IF;
             APP_EXCEPTION.RAISE_EXCEPTION;
          --END IF;
       END IF;
     END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_deliver_quantity', x_progress, sqlcode);

   	RAISE;

END get_deliver_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_deliver_amount()

 Algo: Amount available for deliver :=Total amount delivered + Corrections on delivery.
===========================================================================*/

PROCEDURE get_deliver_amount(p_transaction_id         IN  NUMBER,
			       p_available_amount  IN OUT NOCOPY NUMBER ) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_deliver_amount		NUMBER		:= 0;
x_transaction_amount		NUMBER		:= 0;
x_interface_amount		NUMBER		:= 0;

BEGIN

   x_progress := '005';

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('in get_receive_amount ' );
		asn_debug.put_line('p_transaction_id '||p_transaction_id);
	END IF;
   /*
   ** Get available transaction amount information.
   */

   select rt.amount
   into   x_deliver_amount
   from   rcv_transactions rt
   where  rt.transaction_id = p_transaction_id;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('x_deliver_amount '||x_deliver_amount );
	end if;
   x_progress := '010';

   /*
   ** Get any unprocessed receipt transaction against the
   ** parent transaction. x_interface_quantity is in primary uom.
   */

      SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))),
                         decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))
                  )),0)
   INTO   x_interface_amount
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('x_interface_amount '||x_interface_amount );
	end if;
   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_amount := x_deliver_amount - x_interface_amount;

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_available_amount '||p_available_amount );
	end if;
   /*
   ** Get any rows already precessed against this transaction
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(amount),0)
   INTO   x_transaction_amount
   FROM   rcv_transactions
   WHERE  parent_transaction_id = p_transaction_id
   AND    transaction_type = 'CORRECT';

	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('x_transaction_amount '||x_transaction_amount );
	end if;
        x_progress := '015';

      /*
      ** Calculate the quantity available to be transacted
     */

      p_available_amount :=  p_available_amount + x_transaction_amount;
	IF (g_asn_debug = 'Y') THEN
		asn_debug.put_line('p_available_amount 1 '||p_available_amount );
	end if;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_deliver_amount', x_progress, sqlcode);

   	RAISE;

END get_deliver_amount;

/*===========================================================================

  PROCEDURE NAME:	get_po_dist_quantity()

===========================================================================*/

PROCEDURE get_po_dist_quantity(p_po_distribution_id        IN  NUMBER,
				   p_available_quantity IN OUT NOCOPY NUMBER,
                                   p_tolerable_quantity IN OUT NOCOPY NUMBER,
				   p_unit_of_measure    IN OUT NOCOPY VARCHAR2) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_deliver_quantity		NUMBER		:= 0;
x_balance_receipt_quantity	NUMBER		:= 0;
x_interface_quantity		NUMBER		:= 0;  /* in primary uom */
x_primary_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_interface_qty_in_trx_uom      NUMBER;

-- 1337787
x_qty_rcv_tolerance           NUMBER := 0;
x_qty_ordered                 NUMBER := 0;
x_qty_received                NUMBER := 0;
x_qty_cancelled               NUMBER := 0;
l_quantity                    NUMBER := 0; /* Bug 1710046 */

-- <Bug 9342280 : Added for CLM project>
l_po_line_location_id     NUMBER;
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>


BEGIN

   x_progress := '005';

   BEGIN
     /* Bug 1710046 - The following sql is to get the quantity
        returned to receiving or quantity received but not delivered
        for a particular distribution for a PO having multiple
        Distribution. This quantity should not be shown in
        Enter Receipt form */

       select  nvl(sum(decode(supply_type_code,'RECEIVING',quantity,0)),0)
         into  l_quantity
         from mtl_supply
       where po_distribution_id = p_po_distribution_id;

    /* GMUDGAL - 04-FEB-98 - Bug #610897
    ** Here the problem was that if the shipment has been received
    ** within tolerance then in the C code we are removing the
    ** balance mtl_supply so the above select will raise no_data_found.
    ** We now select from po_distributions the quantity yet to be
    ** delivered so that after exploding the distributions we don't
    ** see zero quantities
    ** Also see 624832.
    */

    select (pod.QUANTITY_ORDERED - nvl(pod.QUANTITY_DELIVERED,0) -
		nvl(pod.QUANTITY_CANCELLED,0)) qty,
	   (poll.quantity - nvl(poll.quantity_received,0) -
		nvl(poll.quantity_cancelled,0)) qty_rcvd,
	   pol.UNIT_MEAS_LOOKUP_CODE,  -- should get it from po_lines actually
	   pol.item_id,
           1 + (nvl(poll.qty_rcv_tolerance,0)/100),   -- 1337787
           nvl(poll.quantity,0),
           nvl(poll.quantity_received,0),
           nvl(poll.quantity_cancelled,0),
           poll.line_location_id  -- <Bug 9342280 : Added for CLM project>
       INTO   p_available_quantity,
	   x_balance_receipt_quantity,
  	   p_unit_of_measure,
	   x_item_id,
           x_qty_rcv_tolerance,
           x_qty_ordered,
           x_qty_received,
           x_qty_cancelled,
           l_po_line_location_id -- <Bug 9342280 : Added for CLM project>
    from   po_distributions_all pod,  --<Shared Proc FPJ>
	   po_line_locations_all poll,  --<Shared Proc FPJ>
	   po_lines_all pol  --<Shared Proc FPJ>
    where  pod.line_location_id = poll.line_location_id
    and    pod.po_distribution_id = p_po_distribution_id
    and    pod.po_line_id = pol.po_line_id;

    -- <Bug 9342280 : Added for CLM project>

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
      END IF;

      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => l_po_line_location_id,
                                                p_po_distribution_id  => p_po_distribution_id);

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('line_location_id : ' || l_po_line_location_id);
         asn_debug.put_line('p_po_distribution_id : ' || p_po_distribution_id);
         asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;


      IF l_is_clm_po = 'Y' THEN
          IF (g_asn_debug = 'Y') THEN
		         asn_debug.put_line(' before po_clm_intg_grp.get_funding_info()');
	        end if;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => l_po_line_location_id,
                                             p_po_distribution_id      => p_po_distribution_id,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status
                                    );

          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
             asn_debug.put_line('l_quantity_funded: ' || l_quantity_funded);
             asn_debug.put_line('l_quantity_delivered : ' || l_quantity_delivered);
             asn_debug.put_line('l_quantity_cancelled: ' || l_quantity_cancelled);
          END IF;

       IF l_partial_funded_flag = 'Y' THEN

         p_available_quantity := l_quantity_funded - l_quantity_delivered - l_quantity_cancelled;
       END IF;

    END IF;
    -- <CLM END>

    /* Bug 1710046 - Deducting the quantity received but not delivered
    ** from the available quantity as this quantity should not be
    ** shown in Enter Receipts form */

    p_available_quantity := p_available_quantity - l_quantity;


    /*GMUDGAL 610897
    ** Check if there is some quantity which has been received
    ** but not delivered yet. In that case we want to show the
    ** quantity in the form as zero.
    */

    if (p_available_quantity > 0) and
       (x_balance_receipt_quantity <= 0) then
 	p_available_quantity := 0;
	p_unit_of_measure := '';
    end if;

  exception
    when no_data_found then
 	p_available_quantity := 0;
	p_unit_of_measure := '';

    WHEN OTHERS THEN RAISE;

  END;

   x_progress := '015';

  /* Bug# 2123470 : Primary Unit of Measure cannot have value
     for One time Items. So Added a decode statement to fetch
     unit_of_measure in case of One Time Items and Primary
     Unit of Measure for Inventory Items.
  */

  /* Bug 10384588: for direct receive ,
   * 1. positive correction in RTI should reduce available qty,
   * negative correction in RTI should add available qty
   * 2. return to vendor would add available qty
   * 3. exclude 'DELIVER FOR CORRECTION','DELIVER','RETURN TO RECEIVING' in RTI computation
   * 4. when item_is null,only the primary uom is null then get uom instead of primar uom
   */
/*
   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0),
	  decode(min(item_id),null,min(unit_of_measure),min(primary_unit_of_measure))
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND	  po_distribution_id = p_po_distribution_id;
*/

   SELECT nvl(sum(decode(transaction_type,
                         'RETURN TO VENDOR', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0),
          decode(min(item_id),null
                       ,decode(min(primary_unit_of_measure),null,min(unit_of_measure),min(primary_unit_of_measure))
                       ,min(primary_unit_of_measure))
   INTO   x_interface_quantity,
          x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND	  po_distribution_id = p_po_distribution_id
   AND NOT EXISTS (SELECT 1 FROM rcv_transactions rt
                   WHERE rt.transaction_type = 'DELIVER'
                   AND   rt.transaction_id = rcv_transactions_interface.parent_transaction_id)
   AND transaction_type NOT IN ('DELIVER','RETURN TO RECEIVING');

/* End Bug 10384588 */

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_trx_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_trx_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the transaction uom
	** so that the available quantity can be calculated in the trx uom
	*/

	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    p_unit_of_measure, x_interface_qty_in_trx_uom);

   END IF;

   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_quantity := p_available_quantity - x_interface_qty_in_trx_uom;

   IF (p_available_quantity < 0) THEN

      p_available_quantity := 0;

   END IF;

   -- <Bug 9342280 : Added for CLM project>
   IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_quantity for clm po');
      END IF;

      p_tolerable_quantity := p_available_quantity;

   ELSE
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_quantity for non-clm po');
      END IF;
   -- <CLM END>

   -- 1337787
   p_tolerable_quantity := (x_qty_ordered * x_qty_rcv_tolerance)-
                            x_qty_received - x_qty_cancelled -
                            x_interface_qty_in_trx_uom;
   END IF;  -- <Bug 9342280 : Added for CLM project>

   IF (p_tolerable_quantity < 0) THEN

       p_tolerable_quantity := 0;

   END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_po_dist_quantity',
				x_progress, sqlcode);

   	RAISE;

END get_po_dist_quantity;

--add for bug 17998528
/*===========================================================================

  PROCEDURE NAME:	get_lcm_dist_quantity()

===========================================================================*/
PROCEDURE get_lcm_dist_quantity(
    p_po_distribution_id   IN NUMBER,
    p_rcv_shipment_line_id IN NUMBER,
    p_available_quantity   IN OUT NOCOPY NUMBER,
    p_tolerable_quantity   IN OUT NOCOPY NUMBER,
    p_unit_of_measure      IN OUT NOCOPY VARCHAR2)
IS
  x_progress                 VARCHAR2(3) := NULL;
  x_interface_quantity       NUMBER      := 0;
  x_primary_uom              VARCHAR2(26);
  x_item_id                  NUMBER;
  x_interface_qty_in_trx_uom NUMBER;

BEGIN
  x_progress := '010';
  BEGIN

    SELECT SUM(quantity),  item_id, unit_of_measure
      INTO p_available_quantity,  x_item_id, p_unit_of_measure
      FROM mtl_supply
     WHERE po_distribution_id = p_po_distribution_id
       AND supply_type_code     = 'SHIPMENT'
       AND shipment_line_id     = p_rcv_shipment_line_id
  GROUP BY item_id, unit_of_measure;

  EXCEPTION
  WHEN no_data_found THEN
    p_available_quantity := 0;
    p_unit_of_measure    := '';
  WHEN OTHERS THEN
    RAISE;
  END;

  x_progress := '020';
 SELECT NVL(SUM(DECODE(transaction_type, 'RETURN TO VENDOR',
        -1 *(DECODE(NVL(order_transaction_id,-999),-999,primary_quantity, NVL(interface_transaction_qty,0))),
        DECODE(NVL(order_transaction_id,-999),-999,primary_quantity,NVL(interface_transaction_qty,0)) )),0),
        DECODE(MIN(item_id),NULL ,DECODE(MIN(primary_unit_of_measure),NULL,MIN(unit_of_measure),MIN(primary_unit_of_measure)) ,MIN(primary_unit_of_measure))
   INTO x_interface_quantity,
        x_primary_uom
   FROM rcv_transactions_interface
  WHERE (transaction_status_code = 'PENDING'
    AND processing_status_code    <> 'ERROR')
    AND po_distribution_id         = p_po_distribution_id
    AND NOT EXISTS
        (SELECT 1
        FROM rcv_transactions rt
        WHERE rt.transaction_type = 'DELIVER'
        AND rt.transaction_id     = rcv_transactions_interface.parent_transaction_id
        )
    AND transaction_type NOT IN ('DELIVER','RETURN TO RECEIVING');

  x_progress := '030';
  IF (x_interface_quantity = 0) THEN
    x_interface_qty_in_trx_uom := 0;
  ELSE
    po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id, p_unit_of_measure, x_interface_qty_in_trx_uom);
  END IF;

  x_progress := '040';
  p_available_quantity    := p_available_quantity - x_interface_qty_in_trx_uom;
  IF (p_available_quantity < 0) THEN
    p_available_quantity  := 0;
  END IF;
  p_tolerable_quantity := p_available_quantity;
EXCEPTION
WHEN OTHERS THEN
  po_message_s.sql_error('get_lcm_dist_quantity', x_progress, SQLCODE);
  RAISE;
END get_lcm_dist_quantity;
--end of bug 17998528

/*===========================================================================

  PROCEDURE NAME:	get_po_dist_amount()

===========================================================================*/

PROCEDURE get_po_dist_amount(p_po_distribution_id        IN  NUMBER,
				   p_available_amount IN OUT NOCOPY NUMBER,
                                   p_tolerable_amount IN OUT NOCOPY NUMBER) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_deliver_amount		NUMBER		:= 0;
x_balance_receipt_amount	NUMBER		:= 0;
x_interface_amount		NUMBER		:= 0;  /* in primary uom */

-- 1337787
x_amt_rcv_tolerance           NUMBER := 0;
x_amt_ordered                 NUMBER := 0;
x_amt_received                NUMBER := 0;
x_amt_cancelled               NUMBER := 0;
l_amount                    NUMBER := 0; /* Bug 1710046 */

-- <Bug 9342280 : Added for CLM project>
l_po_line_location_id     NUMBER;
l_is_clm_po               VARCHAR2(5) := 'N';
l_distribution_type       VARCHAR2(100);
l_matching_basis          VARCHAR2(100);
l_accrue_on_receipt_flag  VARCHAR2(100);
l_code_combination_id     NUMBER;
l_budget_account_id       NUMBER;
l_partial_funded_flag     VARCHAR2(5) := 'N';
l_unit_meas_lookup_code   VARCHAR2(100);
l_funded_value            NUMBER;
l_quantity_funded         NUMBER;
l_amount_funded           NUMBER;
l_quantity_received       NUMBER;
l_amount_received         NUMBER;
l_quantity_delivered      NUMBER;
l_amount_delivered        NUMBER;
l_quantity_billed         NUMBER;
l_amount_billed           NUMBER;
l_quantity_cancelled      NUMBER;
l_amount_cancelled        NUMBER;
l_return_status           VARCHAR2(100);
-- <CLM END>


BEGIN

   x_progress := '005';

   BEGIN

    select (pod.AMOUNT_ORDERED - nvl(pod.AMOUNT_DELIVERED,0) -
		nvl(pod.AMOUNT_CANCELLED,0)) amt,
	   (poll.amount - nvl(poll.amount_received,0) -
		nvl(poll.amount_cancelled,0)) amt_rcvd,
           1 + (nvl(poll.qty_rcv_tolerance,0)/100),   -- 1337787
           nvl(poll.amount,0),
           nvl(poll.amount_received,0),
           nvl(poll.amount_cancelled,0),
           poll.line_location_id  -- <Bug 9342280 : Added for CLM project>
       INTO   p_available_amount,
	   x_balance_receipt_amount,
           x_amt_rcv_tolerance,
           x_amt_ordered,
           x_amt_received,
           x_amt_cancelled,
           l_po_line_location_id -- <Bug 9342280 : Added for CLM project>
    from   po_distributions_all pod,  --<Shared Proc FPJ>
	   po_line_locations_all poll,  --<Shared Proc FPJ>
	   po_lines_all pol  --<Shared Proc FPJ>
    where  pod.line_location_id = poll.line_location_id
    and    pod.po_distribution_id = p_po_distribution_id
    and    pod.po_line_id = pol.po_line_id;

    -- <Bug 9342280 : Added for CLM project>

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
      END IF;

      l_is_clm_po := po_clm_intg_grp.is_clm_po( p_po_header_id        => NULL,
                                                p_po_line_id          => NULL,
                                                p_po_line_location_id => l_po_line_location_id,
                                                p_po_distribution_id  => p_po_distribution_id);

      IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('line_location_id : ' || l_po_line_location_id);
         asn_debug.put_line('p_po_distribution_id : ' || p_po_distribution_id);
         asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
      END IF;


      IF l_is_clm_po = 'Y' THEN
          IF (g_asn_debug = 'Y') THEN
		         asn_debug.put_line(' Before po_clm_intg_grp.get_funding_info()');
	        end if;

          po_clm_intg_grp.get_funding_info(  p_po_header_id            => NULL,
                                             p_po_line_id              => NULL,
                                             p_line_location_id        => l_po_line_location_id,
                                             p_po_distribution_id      => p_po_distribution_id,
                                             x_distribution_type       => l_distribution_type,
                                             x_matching_basis          => l_matching_basis,
                                             x_accrue_on_receipt_flag  => l_accrue_on_receipt_flag,
                                             x_code_combination_id     => l_code_combination_id,
                                             x_budget_account_id       => l_budget_account_id,
                                             x_partial_funded_flag     => l_partial_funded_flag,
                                             x_unit_meas_lookup_code   => l_unit_meas_lookup_code,
                                             x_funded_value            => l_funded_value,
                                             x_quantity_funded         => l_quantity_funded,
                                             x_amount_funded           => l_amount_funded,
                                             x_quantity_received       => l_quantity_received,
                                             x_amount_received         => l_amount_received,
                                             x_quantity_delivered      => l_quantity_delivered,
                                             x_amount_delivered        => l_amount_delivered,
                                             x_quantity_billed         => l_quantity_billed,
                                             x_amount_billed           => l_amount_billed,
                                             x_quantity_cancelled      => l_quantity_cancelled,
                                             x_amount_cancelled        => l_amount_cancelled,
                                             x_return_status           => l_return_status
                                    );

          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
             asn_debug.put_line('l_amount_funded: ' || l_amount_funded);
             asn_debug.put_line('l_amount_delivered : ' || l_amount_delivered);
             asn_debug.put_line('l_amount_cancelled: ' || l_amount_cancelled);
          END IF;

       IF l_partial_funded_flag = 'Y' THEN

         p_available_amount := l_amount_funded - l_amount_delivered - l_amount_cancelled;
       END IF;

    END IF;
    -- <CLM END>


    if (p_available_amount > 0) and
       (x_balance_receipt_amount <= 0) then
 	p_available_amount := 0;
    end if;

  exception
    when no_data_found then
 	p_available_amount := 0;

    WHEN OTHERS THEN RAISE;

  END;

   x_progress := '015';


   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))),
                         decode(nvl(order_transaction_id,-999),-999,amount,nvl(interface_transaction_amt,0))
                  )),0)
   INTO   x_interface_amount
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND	  po_distribution_id = p_po_distribution_id;

   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_amount := p_available_amount - x_interface_amount;

   IF (p_available_amount < 0) THEN

      p_available_amount := 0;

   END IF;

   -- <Bug 9342280 : Added for CLM project>
   IF l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y' THEN
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_amount for clm po');
      END IF;

      p_tolerable_amount := p_available_amount;

   ELSE
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('set p_tolerable_amount for non-clm po');
      END IF;
   -- <CLM END>

   -- 1337787
   p_tolerable_amount := (x_amt_ordered * x_amt_rcv_tolerance)-
                            x_amt_received - x_amt_cancelled -
                            x_interface_amount;
   END IF;  -- <Bug 9342280 : Added for CLM project>

   IF (p_tolerable_amount < 0) THEN

       p_tolerable_amount := 0;

   END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_po_dist_amount',
				x_progress, sqlcode);

   	RAISE;

END get_po_dist_amount;

/*===========================================================================

  PROCEDURE NAME:	get_rcv_dist_quantity()

===========================================================================*/

PROCEDURE get_rcv_dist_quantity(p_po_distribution_id  IN  NUMBER,
				p_transaction_id      IN NUMBER,
				p_available_quantity IN OUT NOCOPY NUMBER,
				p_unit_of_measure    IN OUT NOCOPY VARCHAR2) IS

x_progress 			VARCHAR2(3) 	:= NULL;
x_deliver_quantity		NUMBER		:= 0;
x_interface_quantity		NUMBER		:= 0;  /* in primary uom */
x_primary_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_interface_qty_in_trx_uom      NUMBER;

-- <Bug 9342280 : Added for CLM project>
l_po_line_location_id       NUMBER;
l_is_clm_po                 VARCHAR2(5) := 'N';
l_distribution_type         VARCHAR2(100);
l_matching_basis            VARCHAR2(100);
l_accrue_on_receipt_flag    VARCHAR2(100);
l_code_combination_id       NUMBER;
l_budget_account_id         NUMBER;
l_partial_funded_flag       VARCHAR2(100) := 'N';
l_unit_meas_lookup_code     VARCHAR2(100);
l_funded_value              NUMBER;
l_quantity_funded           NUMBER :=0;
l_amount_funded             NUMBER;
l_quantity_received         NUMBER;
l_amount_received           NUMBER;
l_quantity_delivered        NUMBER :=0;
l_amount_delivered          NUMBER;
l_quantity_billed           NUMBER;
l_amount_billed             NUMBER;
l_quantity_cancelled        NUMBER :=0;
l_amount_cancelled          NUMBER;
l_return_status             VARCHAR2(100);
p_available_funded_quantity NUMBER;
-- <CLM END>



BEGIN

   x_progress := '005';

   /*
   ** Get available supply quantity information.
   */

   /*
   ** There may be no supply quantity hence the exception no data found
   ** needs to be trapped here
   */

   BEGIN

   	SELECT 	quantity,
	  	unit_of_measure
   	INTO   	p_available_quantity,
	  	p_unit_of_measure
   	FROM   	mtl_supply
   	WHERE  	supply_type_code = 'RECEIVING'
   	AND    	supply_source_id = p_transaction_id
	AND	po_distribution_id = p_po_distribution_id;

   EXCEPTION

	WHEN NO_DATA_FOUND THEN

	 	p_available_quantity := 0;

		p_unit_of_measure := '';

	WHEN OTHERS THEN RAISE;

   END;


   -- <Bug 9342280 : Added for CLM project>

    IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('before calling po_clm_intg_grp.is_clm_po()');
    END IF;

    l_is_clm_po := po_clm_intg_grp.is_clm_po(p_po_header_id        => NULL,
                                             p_po_line_id          => NULL,
                                             p_po_line_location_id => NULL,
                                             p_po_distribution_id  => p_po_distribution_id);


    IF (g_asn_debug = 'Y') THEN
      asn_debug.put_line('p_po_distribution_id : ' || p_po_distribution_id);
      asn_debug.put_line('l_is_clm_po: ' || l_is_clm_po);
    END IF;

    IF l_is_clm_po = 'Y' THEN
      IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('before calling po_clm_intg_grp.get_funding_info()');
      END IF;

      po_clm_intg_grp.get_funding_info(p_po_header_id           => NULL,
                                       p_po_line_id             => NULL,
                                       p_line_location_id       => NULL,
                                       p_po_distribution_id     => p_po_distribution_id,
                                       x_distribution_type      => l_distribution_type,
                                       x_matching_basis         => l_matching_basis,
                                       x_accrue_on_receipt_flag => l_accrue_on_receipt_flag,
                                       x_code_combination_id    => l_code_combination_id,
                                       x_budget_account_id      => l_budget_account_id,
                                       x_partial_funded_flag    => l_partial_funded_flag,
                                       x_unit_meas_lookup_code  => l_unit_meas_lookup_code,
                                       x_funded_value           => l_funded_value,
                                       x_quantity_funded        => l_quantity_funded,
                                       x_amount_funded          => l_amount_funded,
                                       x_quantity_received      => l_quantity_received,
                                       x_amount_received        => l_amount_received,
                                       x_quantity_delivered     => l_quantity_delivered,
                                       x_amount_delivered       => l_amount_delivered,
                                       x_quantity_billed        => l_quantity_billed,
                                       x_amount_billed          => l_amount_billed,
                                       x_quantity_cancelled     => l_quantity_cancelled,
                                       x_amount_cancelled       => l_amount_cancelled,
                                       x_return_status          => l_return_status);

      IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('l_partial_funded_flag : ' || l_partial_funded_flag);
        asn_debug.put_line('l_quantity_funded: ' || l_quantity_funded);
        asn_debug.put_line('l_quantity_delivered : ' || l_quantity_delivered);
        asn_debug.put_line('l_quantity_cancelled: ' || l_quantity_cancelled);
      END IF;

      IF (l_partial_funded_flag = 'Y') THEN

        p_available_funded_quantity := l_quantity_funded - l_quantity_delivered - l_quantity_cancelled;

        IF p_available_funded_quantity < p_available_quantity THEN

           p_available_quantity := p_available_funded_quantity;

        END IF;

      END IF;

    END IF;
    -- <CLM END>


   select nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0),
	  min(primary_unit_of_measure),
	  min(item_id) -- Bug 11833312
   INTO   x_interface_quantity,
	  x_primary_uom,
	  x_item_id
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id
   AND	  po_distribution_id = p_po_distribution_id;

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_trx_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_trx_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the transaction uom
	** so that the available quantity can be calculated in the trx uom
	*/

	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    p_unit_of_measure, x_interface_qty_in_trx_uom);

   END IF;

   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_quantity := p_available_quantity - x_interface_qty_in_trx_uom;

   IF (p_available_quantity < 0) THEN

      p_available_quantity := 0;

   END IF;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('get_rcv_dist_quantity',
				x_progress, sqlcode);

   	RAISE;

END get_rcv_dist_quantity;

/*===========================================================================

  PROCEDURE NAME:	val_quantity()

===========================================================================*/

PROCEDURE val_quantity IS

x_progress VARCHAR2(3) := NULL;

BEGIN

null;

EXCEPTION

   WHEN OTHERS THEN

      	po_message_s.sql_error('val_quantity', x_progress, sqlcode);

   	RAISE;

END val_quantity;

/*===========================================================================

  PROCEDURE NAME:	get_primary_qty_uom

===========================================================================*/
/*
** go get the primary quantity an uom for an item based on a transaction
** quantity and uom
*/

PROCEDURE get_primary_qty_uom (
X_transaction_qty IN NUMBER,
X_transaction_uom IN VARCHAR2,
X_item_id         IN NUMBER,
X_organization_id IN NUMBER,
X_primary_qty     IN OUT NOCOPY NUMBER,
X_primary_uom     IN OUT NOCOPY VARCHAR2) IS

X_progress 	VARCHAR2(4) := '000';

BEGIN

    /*dbms_output.put_line ('get_primary_qty : X_transaction_qty : '||
       TO_CHAR(X_transaction_qty));
    dbms_output.put_line ('get_primary_qty : X_transaction_uom : '||
       X_transaction_uom);
    dbms_output.put_line ('get_primary_qty : X_item_id         : '||
       TO_CHAR(X_item_id));
    dbms_output.put_line ('get_primary_qty : X_organization_Id : '||
       TO_CHAR(X_organization_id));*/
    /*
    ** Check if item_id = 0, if TRUE get primary unit of measure from
    ** MTL_UNITS_OF_MEASURE else get primary unit of measure from
    ** MTL_SYSTEM_ITEMS
    */

    IF (X_item_id IS NULL) THEN

	X_progress := '1100';

        SELECT MUOM2.unit_of_measure
        INTO   X_primary_uom
        FROM   mtl_units_of_measure MUOM1,
               mtl_units_of_measure MUOM2
        WHERE  MUOM1.unit_of_measure = X_transaction_uom
        AND    MUOM1.uom_class       = MUOM2.uom_class
        AND    MUOM2.base_uom_flag   = 'Y';

    ELSE

       X_progress := '1110';

       SELECT MSI.primary_unit_of_measure
       INTO   X_primary_uom
       FROM   mtl_system_items_kfv  MSI
       WHERE  MSI.inventory_item_id  =  X_item_id
       AND    MSI.organization_id    =  X_organization_id;

    END IF;

    /*
    ** Go get the primary quantity based on the transaction quantity and the
    ** conversions between the UOMS
    */
    X_progress := '1120';
    po_uom_s.uom_convert (X_transaction_qty,
			  X_transaction_uom,
                          X_item_id,
                          X_primary_uom,
                          X_primary_qty);

    /*dbms_output.put_line ('get_primary_qty : X_primary_qty    : '||
       TO_CHAR(X_primary_qty));
    dbms_output.put_line ('get_primary_qty : X_primary_uom     : '||
       X_primary_uom);*/

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_primary_qty_uom', X_progress, sqlcode);
   RAISE;

END get_primary_qty_uom;

/*===========================================================================

  FUNCTION NAME: get_pending_qty_

===========================================================================*/
FUNCTION get_pending_qty(p_line_location_id IN NUMBER) RETURN NUMBER IS
   x_progress                 VARCHAR2(3) := NULL;
   x_interface_quantity       NUMBER      := 0;
   x_po_uom                   VARCHAR2(26);
   x_item_id                  NUMBER;
   x_primary_uom              VARCHAR2(26);
   x_interface_qty_in_po_uom  NUMBER      := 0;

   BEGIN
      x_progress := '005';
      SELECT   PL.ITEM_ID,
               PL.UNIT_MEAS_LOOKUP_CODE
      INTO     x_item_id,
               x_po_uom
      FROM     PO_LINE_LOCATIONS       PLL,
               PO_LINES                PL
      WHERE    PLL.LINE_LOCATION_ID =  p_line_location_id AND
               PLL.PO_LINE_ID       =  PL.PO_LINE_ID;

      x_progress := '010';
      SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
               MIN(PRIMARY_UNIT_OF_MEASURE)
      INTO     x_interface_quantity,
               x_primary_uom
      FROM     RCV_TRANSACTIONS_INTERFACE
      WHERE    (TRANSACTION_STATUS_CODE = 'PENDING'
                and processing_status_code <> 'ERROR') AND
               TRANSACTION_TYPE        IN ('RECEIVE','MATCH','CORRECT') AND
               PO_LINE_LOCATION_ID     = p_line_location_id;

      IF (x_interface_quantity = 0) THEN
         /* ** There is no unprocessed quantity. Simply set the
            ** x_interface_qty_in_po_uom to 0. There is no need for uom
            ** conversion. */
         x_interface_qty_in_po_uom := 0;
      ELSE
         /* ** There is unprocessed quantity. Convert it to the PO uom
            ** so that the available quantity can be calculated in the PO uom */
         x_progress := '015';
         /*
         po_uom_s.uom_convert(x_interface_quantity,
                              x_primary_uom,
                              x_item_id,
                              x_po_uom,
                              x_interface_qty_in_po_uom);
         */
         /* Had to reverse engineer the call to po_uom_s.uom_convert */
         x_interface_qty_in_po_uom := x_interface_quantity *
                                      po_uom_s.po_uom_convert(x_primary_uom,x_po_uom,x_item_id);
      END IF;

      x_progress := '020';
      RETURN x_interface_qty_in_po_uom;

   /* Had to remove the exception handling section because it violates WNDS pragma */
   /*
   EXCEPTION
      WHEN OTHERS THEN
         po_message_s.sql_error('get_pending_qty',x_progress,SQLCODE);
         RAISE;
   */

   END get_pending_qty;

/*===========================================================================

  PROCEDURE NAME:	get_ship_qty_in_int

===========================================================================*/
/*
** get qty in RTI for a particular PO shipment and ASN shipment
*/

PROCEDURE get_ship_qty_in_int (
p_shipment_line_id IN NUMBER,
p_line_location_id IN NUMBER,
p_ship_qty_in_int  IN OUT NOCOPY NUMBER) IS

X_progress 	VARCHAR2(4) := '000';
x_interface_quantity  		NUMBER		:= 0; /* in primary_uom */
x_shipment_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_primary_uom			VARCHAR2(26);
x_interface_qty_in_ship_uom NUMBER	:= 0;

BEGIN

   SELECT rsl.item_id,
	  rsl.unit_of_measure
   INTO   x_item_id,
	  x_shipment_uom
   FROM   rcv_shipment_lines rsl
   WHERE  rsl.shipment_line_id = p_shipment_line_id;

   x_progress := '010';

   SELECT nvl(sum(decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
	  min(primary_unit_of_measure)
   INTO   x_interface_quantity,
	  x_primary_uom
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    transaction_type  = 'RECEIVE'
   AND    shipment_line_id = p_shipment_line_id
   AND    po_line_location_id = p_line_location_id;

   x_progress := '020';

   IF (x_interface_quantity = 0) THEN

	/*
	** There is no unprocessed quantity. Simply set the
	** x_interface_qty_in_ship_uom to 0. There is no need for uom
	** conversion.
	*/

	x_interface_qty_in_ship_uom := 0;

   ELSE

	/*
	** There is unprocessed quantity. Convert it to the shipment uom
	** so that the available quantity can be calculated in the shipment uom
	*/
        x_progress := '015';

	po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    x_shipment_uom, x_interface_qty_in_ship_uom);

   END IF;

   x_progress := '030';

   p_ship_qty_in_int := x_interface_qty_in_ship_uom;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_ship_qty_in_int', X_progress, sqlcode);
   RAISE;

END get_ship_qty_in_int;

PROCEDURE get_available_asn_quantity(
                                 p_transaction_type      IN  VARCHAR2,
                                 p_shipment_line_id      IN  NUMBER,
				 p_line_location_id      IN  NUMBER,
                                 p_distribution_id       IN  VARCHAR2,
                                 x_unit_of_measure       IN OUT NOCOPY VARCHAR2,
                                 x_available_quantity    IN OUT NOCOPY NUMBER,
                                 x_tolerable_quantity    IN OUT NOCOPY NUMBER,
                                 x_secondary_available_qty IN OUT NOCOPY NUMBER
) IS
l_available_qty_hold number;
l_uom_hold VARCHAR2(26);
l_secondary_available_qty_hold number;
l_quantity_shipped           NUMBER :=0;   -- ASN Phase 2
l_quantity_returned          NUMBER :=0;   -- ASN Phase 2
l_ship_qty_int            NUMBER :=0;   -- ASN Phase 2 bug 623925
l_interface_qty_in_trx_uom      NUMBER;
l_interface_quantity            NUMBER          := 0;  /* in primary uom */
l_primary_uom                   VARCHAR2(26);
l_item_id                       NUMBER;
l_qty_rcv_tolerance number :=0;
l_qty_ordered number :=0;
l_qty_received number :=0;
l_qty_cancelled number :=0;
l_progress                      VARCHAR2(3)     := NULL;
begin

  l_progress := '000';
  IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Enter get_available_asn_quantity ');
        asn_debug.put_line('p_transaction_type '||p_transaction_type);
        asn_debug.put_line('p_shipment_line_id '||p_shipment_line_id);
        asn_debug.put_line('p_line_location_id  '||p_line_location_id );
        asn_debug.put_line('p_distribution_id  '||p_distribution_id );
        asn_debug.put_line('x_unit_of_measure  '||x_unit_of_measure );
  END IF;

  IF (p_transaction_type = 'RECEIVE') then --{

		/* This part of the code is the same as in RCVRCPQB.pls
		 * where we calculate the available qty in forms.
		*/
	        rcv_quantities_s.get_available_quantity ('RECEIVE',
                p_shipment_line_id,
                'INVENTORY',
		 NULL,
		 NULL,
		 NULL,
		 x_available_quantity,
                 x_tolerable_quantity,
		 x_unit_of_measure,
		 X_secondary_available_qty);

		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('x_available_quantity '||x_available_quantity);
			asn_debug.put_line('x_tolerable_quantity '||x_tolerable_quantity);
			asn_debug.put_line('x_unit_of_measure '||x_unit_of_measure);
			asn_debug.put_line('X_secondary_available_qty '||X_secondary_available_qty);
		END IF;

		l_progress := '010';

            rcv_quantities_s.get_available_quantity ('RECEIVE',
                p_line_location_id,
                'VENDOR',
		 NULL,
		 NULL,
		 NULL,
		 l_available_qty_hold,
                 x_tolerable_quantity,
		 l_uom_hold,
		 x_secondary_available_qty);


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_available_qty_hold '||l_available_qty_hold);
			asn_debug.put_line('x_tolerable_quantity '||x_tolerable_quantity);
			asn_debug.put_line('l_uom_hold '||l_uom_hold);
			asn_debug.put_line('X_secondary_available_qty '||X_secondary_available_qty);
		END IF;

	   /* Bug 9593466
              We do not need to do any more calculation to get the available qty
              and tolerable quantity since we already take care of the quantities
              in the interface table in the above apis.
            */


           -- Handle the return to vendor here
	    l_progress := '040';

		select sum(nvl(quantity,0))
		into l_quantity_returned
		from rcv_transactions
		where shipment_line_id = p_shipment_line_id and
		transaction_type = 'RETURN TO VENDOR';


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_quantity_returned  '||l_quantity_returned );
		END IF;

		IF l_quantity_returned > 0 then --}

		     x_available_quantity := X_available_quantity - l_quantity_returned;
		     x_tolerable_quantity := x_tolerable_quantity - l_quantity_returned;

		     If x_available_quantity < 0 THEN
		       x_available_quantity := 0;
		     end if;

		     IF x_tolerable_quantity < 0 THEN
		       x_tolerable_quantity := 0;
		     end if;


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('x_available_quantity  '||x_available_quantity );
			asn_debug.put_line('x_tolerable_quantity  '||x_tolerable_quantity );
		END IF;

		END IF; --}

  elsif(p_transaction_type = 'DIRECT RECEIPT') then


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('In direct receipt of ASN  ');
		END IF;

		BEGIN

			SELECT  quantity,
			unit_of_measure
			INTO    x_available_quantity,
			x_unit_of_measure
			FROM    mtl_supply
			WHERE   supply_type_code = 'SHIPMENT'
			AND     supply_source_id = p_shipment_line_id
			AND     po_distribution_id = p_distribution_id;

		EXCEPTION

		WHEN NO_DATA_FOUND THEN

			x_available_quantity := 0;

			x_unit_of_measure := '';

		WHEN OTHERS THEN RAISE;

		END;

		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('x_available_quantity '||x_available_quantity);
		END IF;


	    l_progress := '050';

		select nvl(sum( decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),0),
                       min(primary_unit_of_measure),
                       min(item_id) -- Bug 12336493
		INTO   l_interface_quantity,
		       l_primary_uom,
                       l_item_id
		FROM   rcv_transactions_interface
		WHERE  (transaction_status_code = 'PENDING'
		AND    processing_status_code <> 'ERROR')
		AND    transaction_type = 'RECEIVE'
		AND    shipment_line_id = p_shipment_line_id
		AND    po_line_location_id = p_line_location_id
		AND    po_distribution_id = p_distribution_id;


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_interface_quantity '||l_interface_quantity);
			asn_debug.put_line('l_primary_uom '||l_primary_uom);
		END IF;

		IF (l_interface_quantity = 0) THEN

			l_interface_qty_in_trx_uom := 0;

		ELSE

		/*
		 * There is unprocessed quantity. Convert it to the
		 *  transaction uom so that the available quantity can be
		 * calculated in the trx uom
		*/

			po_uom_s.uom_convert( l_interface_quantity,
						l_primary_uom,
						l_item_id,
				                x_unit_of_measure,
						l_interface_qty_in_trx_uom);

		END IF;


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_interface_qty_in_trx_uom '||l_interface_qty_in_trx_uom);
		END IF;

		 x_available_quantity := x_available_quantity -
						 l_interface_qty_in_trx_uom;

		IF (x_available_quantity < 0) THEN

			x_available_quantity := 0;

		END IF;

		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('x_available_quantity '||x_available_quantity);
		END IF;



		select
		   1 + (nvl(poll.qty_rcv_tolerance,0)/100),   -- 1337787
		   nvl(poll.quantity,0),
		   nvl(poll.quantity_received,0),
		   nvl(poll.quantity_cancelled,0)
		INTO
		   l_qty_rcv_tolerance,
		   l_qty_ordered,
		   l_qty_received,
		   l_qty_cancelled
		from   po_distributions_all pod,  --<Shared Proc FPJ>
		   po_line_locations_all poll,  --<Shared Proc FPJ>
		   po_lines_all pol  --<Shared Proc FPJ>
		where  pod.line_location_id = poll.line_location_id
		and    pod.po_distribution_id = p_distribution_id
		and    pod.po_line_id = pol.po_line_id;


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('l_qty_rcv_tolerance '||l_qty_rcv_tolerance);
			asn_debug.put_line('l_qty_ordered '||l_qty_ordered);
			asn_debug.put_line('l_qty_received '||l_qty_received);
			asn_debug.put_line('l_qty_cancelled '||l_qty_cancelled);
		END IF;

		x_tolerable_quantity := (l_qty_ordered * l_qty_rcv_tolerance)-
				    l_qty_received - l_qty_cancelled -
				    l_interface_qty_in_trx_uom;

		IF (x_tolerable_quantity < 0) THEN

			x_tolerable_quantity := 0;

		END IF;


		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('x_tolerable_quantity '||x_tolerable_quantity);
		END IF;



  end if; --}

		IF (g_asn_debug = 'Y') THEN
			asn_debug.put_line('Leave get_available_asn_qty ');
		END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_available_asn_quantity', l_progress, sqlcode);
   RAISE;

END get_available_asn_quantity;


/*===========================================================================
  begin bug 18483380
  PROCEDURE NAME:	get_negative_correct_rtp_qty()
  DESCRIPTION:		get avialable qty for correction agaisnt receiving transaction
  via ROI.
  p_transaction_id,            receiving transaction id
  p_interface_transaction_id,  correction RTI interface transaction id
  p_available_quantity,        avaialble qty
===========================================================================*/

PROCEDURE get_negative_correct_rtp_qty(
           p_transaction_id        IN  NUMBER,
           p_tranx_interface_id IN  NUMBER,
				   p_available_quantity IN OUT NOCOPY NUMBER)
IS
x_progress 			VARCHAR2(3) 	:= NULL;
x_transaction_quantity		NUMBER		:= 0;
x_interface_quantity		NUMBER		:= 0;  /* in primary uom */
x_transaction_uom		VARCHAR2(26);
x_primary_uom			VARCHAR2(26);
x_item_id			NUMBER;
x_interface_qty_in_trx_uom      NUMBER;

BEGIN

   x_progress := '005';

   /*
   ** Get available supply quantity information.
   */

   IF (g_asn_debug = 'Y') THEN
     asn_debug.put_line('get_negative_correct_rtp_qty >> ' || x_progress );
     asn_debug.put_line('p_transaction_id ' || p_transaction_id);
   END IF;

   BEGIN

    SELECT 	quantity,
	  	unit_of_measure,
	  	item_id,
      to_org_primary_uom
   	INTO   	x_transaction_quantity,
	        	x_transaction_uom,
	  	      x_item_id,
            x_primary_uom
   	FROM   	rcv_supply
   	WHERE  	supply_type_code = 'RECEIVING'
   	AND    	supply_source_id = p_transaction_id;

   EXCEPTION

	  WHEN NO_DATA_FOUND THEN

	 	  x_transaction_quantity := 0;

                SELECT  rt.unit_of_measure,
                        rsl.item_id,
                        rt.primary_unit_of_measure
                INTO    x_transaction_uom,
                        x_item_id,
                        x_primary_uom
                FROM    rcv_transactions rt,
                        rcv_shipment_lines rsl
                WHERE   rsl.shipment_line_id = rt.shipment_line_id
                AND     rt.transaction_id = p_transaction_id;



	  WHEN OTHERS THEN RAISE;

   END;

   IF (g_asn_debug = 'Y') THEN
     asn_debug.put_line('get_negative_correct_rtp_qty >> ');
     asn_debug.put_line('x_transaction_quantity '||x_transaction_quantity);
     asn_debug.put_line('x_transaction_uom '||x_transaction_uom);
     asn_debug.put_line('item_id '||x_item_id);
   END IF;


   x_progress := '010';

   /*
   ** Get any unprocessed receipt transaction against the
   ** parent transaction. x_interface_quantity is in primary uom.
   **
   ** The min(primary_uom) is neccessary because the
   ** select may return multiple rows and we only want one value
   ** to be returned. Having a sum and min group function in the
   ** select ensures that this sql statement will not raise a
   ** no_data_found exception even if no rows are returned.
   */

   SELECT nvl(sum(decode(transaction_type,
                         'CORRECT', -1 * (decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))),
                         decode(nvl(order_transaction_id,-999),-999,primary_quantity,nvl(interface_transaction_qty,0))
                  )),0)
   INTO   x_interface_quantity
   FROM   rcv_transactions_interface
   WHERE  (transaction_status_code = 'PENDING'
          and processing_status_code <> 'ERROR')
   AND    parent_transaction_id = p_transaction_id
   AND    interface_transaction_id<>p_tranx_interface_id;

   IF (x_interface_quantity = 0) THEN

    /*
    ** There is no unprocessed quantity. Simply set the
	  ** x_interface_qty_in_trx_uom to 0. There is no need for uom
	  ** conversion.
	  */

	    x_interface_qty_in_trx_uom := 0;

   ELSE

   	/*
	  ** There is unprocessed quantity. Convert it to the transaction uom
	  ** so that the available quantity can be calculated in the trx uom
	  */
      IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Before uom_convert:');
                asn_debug.put_line('x_interface_quantity:' || x_interface_quantity);
                asn_debug.put_line('x_primary_uom:' || x_primary_uom);
                asn_debug.put_line('x_transaction_uom:' || x_transaction_uom);
                asn_debug.put_line('x_item_id:' || x_item_id);
      END IF;

      x_progress := '015';
      po_uom_s.uom_convert(x_interface_quantity, x_primary_uom, x_item_id,
			    x_transaction_uom, x_interface_qty_in_trx_uom);

   END IF;



   /*
   ** Calculate the quantity available to be transacted
   */

   p_available_quantity := x_transaction_quantity - x_interface_qty_in_trx_uom;

EXCEPTION

   WHEN OTHERS THEN

      po_message_s.sql_error('get_negative_correct_rtp_qty', x_progress, sqlcode);

   	RAISE;
END  get_negative_correct_rtp_qty;

/* end fix of bug 18483380 */



END RCV_QUANTITIES_S;

/
