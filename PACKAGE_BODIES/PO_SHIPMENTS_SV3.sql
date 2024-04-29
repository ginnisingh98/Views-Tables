--------------------------------------------------------
--  DDL for Package Body PO_SHIPMENTS_SV3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SHIPMENTS_SV3" as
/* $Header: POXPOS3B.pls 120.4 2005/07/01 03:06:19 manram noship $*/

/*===========================================================================

  FUNCTION NAME:	get_line_location_id

===========================================================================*/
   FUNCTION get_line_location_id
		      (X_po_line_id           IN     NUMBER,
		       X_shipment_type        IN     VARCHAR2) RETURN NUMBER IS

      X_progress          VARCHAR2(3) := '';
      X_line_location_id  NUMBER      := '';

      BEGIN

	 X_progress := '010';

	 -- Note that this routine is only called if there is only one
         -- shipment.
	 SELECT line_location_id
	 INTO   X_line_location_id
         FROM   po_line_locations PLL
         WHERE  PLL.po_line_id = X_po_line_id
	 AND    PLL.shipment_type = X_shipment_type;

	-- togeorge 10/26/2000 commented out due to the problems while arcs in.
	 --dbms_output.put_line ('Line Location Id  = '||X_line_location_id);

         RETURN(X_line_location_id);

      EXCEPTION
	when others then
	-- togeorge 10/26/2000 commented out due to the problems while arcs in.
	-- dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_line_location_id', X_progress, sqlcode);
          raise;
      END get_line_location_id;

/*===========================================================================

  PROCEDURE NAME:	get_po_line_location_id()

===========================================================================*/

 PROCEDURE get_po_line_location_id
                (X_po_line_location_id_record		IN OUT	NOCOPY rcv_shipment_line_sv.po_line_location_id_rtype) IS

 BEGIN

   SELECT max(line_location_id) into x_po_line_location_id_record.po_line_location_id
   from   po_lines_all pol, --<R12.MOAC>
	  po_line_locations poll
   where  pol.po_line_id = poll.po_line_id
   and    NVL(X_po_line_location_id_record.item_id, pol.item_id)	= pol.item_id
   and    NVL(X_po_line_location_id_record.po_line_id, pol.po_line_id)	= pol.po_line_id
   and    pol.po_header_id						= X_po_line_location_id_record.po_header_id
   order  by nvl(poll.promised_date, poll.need_by_date);

   if (x_po_line_location_id_record.po_line_location_id is null) then
	x_po_line_location_id_record.error_record.error_status	:= 'F';
	x_po_line_location_id_record.error_record.error_message := 'RCV_ITEM_PO_LINE_LOCATION_ID';
   end if;

 exception
   when others then
	x_po_line_location_id_record.error_record.error_status	:= 'U';

 END get_po_line_location_id;

/*===========================================================================

  FUNCTION NAME:	get_planned_qty_ordered

===========================================================================*/

  -- DEBUG.  Not currently being called from source line number.
  --		This is a bug.
  FUNCTION get_planned_qty_ordered
		      (X_po_line_id                  IN     NUMBER,
		       X_shipment_type               IN     VARCHAR2) RETURN NUMBER IS

     /* DEBUG Why pass X_shipment_type if this is always going to be
     **       PLANNED? */

      X_progress            VARCHAR2(3) := '';
      X_quantity_ordered    NUMBER      := '';
      X_planned_shipment_id NUMBER      := '';

      BEGIN
	 X_progress := '010';

	 -- Get the sum of the quantity of all shipments.
         SELECT sum(PLL.quantity - nvl(PLL.quantity_cancelled,0))
	 INTO   X_quantity_ordered
         FROM   po_line_locations PLL
         WHERE  PLL.po_line_id = X_po_line_id
	 AND    PLL.shipment_type = 'PLANNED' ;

	-- togeorge 10/26/2000 commented out due to the problems while arcs in.
        -- dbms_output.put_line ('Quantity Ordered (ord - can) = '||X_quantity_ordered);

         RETURN(X_quantity_ordered);

      EXCEPTION
	when others then
	-- togeorge 10/26/2000 commented out due to the problems while arcs in.
	-- dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_planned_qty_ordered', X_progress, sqlcode);
          raise;
      END get_planned_qty_ordered;

/*===========================================================================

  PROCEDURE NAME:	insert_rel_shipment

===========================================================================*/
   FUNCTION insert_rel_shipment
		      (X_Rowid                          IN OUT NOCOPY VARCHAR2,
                       X_Line_Location_Id               IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Po_Header_Id                   NUMBER,
                       X_Po_Line_Id                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Quantity                       NUMBER,
                       X_Quantity_Received              NUMBER,
                       X_Quantity_Accepted              NUMBER,
                       X_Quantity_Rejected              NUMBER,
                       X_Quantity_Billed                NUMBER,
                       X_Quantity_Cancelled             NUMBER,
                       X_Unit_Meas_Lookup_Code          VARCHAR2,
                       X_Po_Release_Id                  NUMBER,
                       X_Ship_To_Location_Id            NUMBER,
                       X_Ship_Via_Lookup_Code           VARCHAR2,
                       X_Need_By_Date                   DATE,
                       X_Promised_Date                  DATE,
                       X_Last_Accept_Date               DATE,
                       X_Price_Override                 NUMBER,
                       X_Encumbered_Flag                VARCHAR2,
                       X_Encumbered_Date                DATE,
                       X_Fob_Lookup_Code                VARCHAR2,
                       X_Freight_Terms_Lookup_Code      VARCHAR2,
                       X_Taxable_Flag                   VARCHAR2,
                       X_Tax_Code_Id                    NUMBER,
		       X_Tax_User_Override_Flag		VARCHAR2,
		       X_Calculate_Tax_Flag		VARCHAR2,
                       X_From_Header_Id                 NUMBER,
                       X_From_Line_Id                   NUMBER,
                       X_From_Line_Location_Id          NUMBER,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Lead_Time                      NUMBER,
                       X_Lead_Time_Unit                 VARCHAR2,
                       X_Price_Discount                 NUMBER,
                       X_Terms_Id                       NUMBER,
                       X_Approved_Flag                  VARCHAR2,
                       X_Approved_Date                  DATE,
                       X_Closed_Flag                    VARCHAR2,
                       X_Cancel_Flag                    VARCHAR2,
                       X_Cancelled_By                   NUMBER,
                       X_Cancel_Date                    DATE,
                       X_Cancel_Reason                  VARCHAR2,
                       X_Firm_Status_Lookup_Code        VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Inspection_Required_Flag       VARCHAR2,
                       X_Receipt_Required_Flag          VARCHAR2,
                       X_Qty_Rcv_Tolerance              NUMBER,
                       X_Qty_Rcv_Exception_Code         VARCHAR2,
                       X_Enforce_Ship_To_Location       VARCHAR2,
                       X_Allow_Substitute_Receipts      VARCHAR2,
                       X_Days_Early_Receipt_Allowed     NUMBER,
                       X_Days_Late_Receipt_Allowed      NUMBER,
                       X_Receipt_Days_Exception_Code    VARCHAR2,
                       X_Invoice_Close_Tolerance        NUMBER,
                       X_Receive_Close_Tolerance        NUMBER,
                       X_Ship_To_Organization_Id        NUMBER,
                       X_Shipment_Num                   NUMBER,
                       X_Source_Shipment_Id             NUMBER,
                       X_Shipment_Type                  VARCHAR2,
                       X_Closed_Code                    VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Government_Context             VARCHAR2,
                       X_Receiving_Routing_Id           NUMBER,
                       X_Accrue_On_Receipt_Flag         VARCHAR2,
                       X_Closed_Reason                  VARCHAR2,
                       X_Closed_Date                    DATE,
                       X_Closed_By                      NUMBER,
                       X_Global_Attribute_Category          VARCHAR2,
                       X_Global_Attribute1                  VARCHAR2,
                       X_Global_Attribute2                  VARCHAR2,
                       X_Global_Attribute3                  VARCHAR2,
                       X_Global_Attribute4                  VARCHAR2,
                       X_Global_Attribute5                  VARCHAR2,
                       X_Global_Attribute6                  VARCHAR2,
                       X_Global_Attribute7                  VARCHAR2,
                       X_Global_Attribute8                  VARCHAR2,
                       X_Global_Attribute9                  VARCHAR2,
                       X_Global_Attribute10                 VARCHAR2,
                       X_Global_Attribute11                 VARCHAR2,
                       X_Global_Attribute12                 VARCHAR2,
                       X_Global_Attribute13                 VARCHAR2,
                       X_Global_Attribute14                 VARCHAR2,
                       X_Global_Attribute15                 VARCHAR2,
                       X_Global_Attribute16                 VARCHAR2,
                       X_Global_Attribute17                 VARCHAR2,
                       X_Global_Attribute18                 VARCHAR2,
                       X_Global_Attribute19                 VARCHAR2,
                       X_Global_Attribute20                 VARCHAR2,
		       X_Invoice_Match_Option		    VARCHAR2,  --bgu, Dec. 7, 98
		       X_Country_of_Origin_Code		    VARCHAR2,
		       --togeorge 10/12/2000
		       --Bug# 1433282
		       --added note to receiver
		       X_note_to_receiver	            VARCHAR2,
-- Mahesh Chandak(GML) Add 7 process related fields.Bug# 1548597
-- start of 1548597
                       X_Secondary_Unit_Of_Measure        VARCHAR2 default null,
                       X_Secondary_Quantity               NUMBER default null ,
                       X_Preferred_Grade                  VARCHAR2 default null,
                       X_Secondary_Quantity_Received      NUMBER default null,
                       X_Secondary_Quantity_Accepted      NUMBER default null,
                       X_Secondary_Quantity_Rejected      NUMBER default null,
                       X_Secondary_Quantity_Cancelled     NUMBER default null,
-- end of 1548597
                       X_amount                           NUMBER default null, -- <SERVICES FPJ>
                       p_manual_price_change_flag         VARCHAR2 default null,  -- <Manual Price Override FPJ>
                       p_org_id                     IN     NUMBER       -- <R12.MOAC>
                       ,p_outsourced_assembly       IN NUMBER default 2
) RETURN BOOLEAN IS

      X_progress                VARCHAR2(3)  := '';
      X_Val_Qty_Released_True   BOOLEAN;
      X_Entity_Level            VARCHAR2(25) := 'SHIPMENT';
      X_orig_quantity           NUMBER;

      -- <Complex Work R12 Start>
      l_value_basis             PO_LINES_ALL.order_type_lookup_code%TYPE;
      l_matching_basis          PO_LINES_ALL.matching_basis%TYPE;
      -- <Complex Work R12 End>

      BEGIN

        -- verify that the shipment number is unique.
        -- Otherwise, display a message to the user and
        -- abort insert_row.

        X_progress := '005';
        po_line_locations_pkg_s3.check_unique(
		X_rowid,
		X_shipment_num,
		X_po_line_id,
                X_po_release_id,
                X_shipment_type);

         X_progress := '010';

         X_orig_quantity := 0; /* This is always zero for new releases
                                  that get created . You would have to
                                  fetch from the db for update cases alone */

	 -- Check if you have released more than is available on the
         -- planned purchase order.  If you have released more than
         -- is available,the routine being called will display a message
	 -- to the user and prevent the user from continuing.
         po_shipments_sv7.check_available_quantity(X_Source_Shipment_Id,
                                                   X_orig_quantity,
                                                   X_quantity);

         --  Get the line_location_id for this release shipment.
         X_progress := '020';

         SELECT po_line_locations_s.nextval
         INTO   X_line_location_id
         FROM   sys.dual;

         -- <Complex Work R12 Start>
         -- Get value_basis and matching_basis from line
         X_progress := '025';

         SELECT pol.order_type_lookup_code, pol.matching_basis
         INTO l_value_basis, l_matching_basis
         FROM po_lines_all pol
         WHERE pol.po_line_id = X_Po_Line_Id;

         X_progress := '030';
         -- <Complex Work R12 End>


         -- Call the insert row routine with all parameters.
	 po_line_locations_pkg_s0.insert_row(
		       X_Rowid,
                       X_Line_Location_Id,
                       X_Last_Update_Date,
                       X_Last_Updated_By,
                       X_Po_Header_Id,
                       X_Po_Line_Id,
                       X_Last_Update_Login,
                       X_Creation_Date,
                       X_Created_By,
                       X_Quantity,
                       X_Quantity_Received,
                       X_Quantity_Accepted,
                       X_Quantity_Rejected,
                       X_Quantity_Billed,
                       X_Quantity_Cancelled,
                       X_Unit_Meas_Lookup_Code,
                       X_Po_Release_Id,
                       X_Ship_To_Location_Id,
                       X_Ship_Via_Lookup_Code,
                       X_Need_By_Date,
                       X_Promised_Date,
                       X_Last_Accept_Date,
                       X_Price_Override,
                       X_Encumbered_Flag,
                       X_Encumbered_Date,
                       X_Fob_Lookup_Code,
                       X_Freight_Terms_Lookup_Code,
                       X_Taxable_Flag,
                       NULL,          --<R12 eTax Integration>
		                   NULL,          --<R12 eTax Integration>
		       X_Calculate_Tax_Flag,
                       X_From_Header_Id,
                       X_From_Line_Id,
                       X_From_Line_Location_Id,
                       X_Start_Date,
                       X_End_Date,
                       X_Lead_Time,
                       X_Lead_Time_Unit,
                       X_Price_Discount,
                       X_Terms_Id,
                       X_Approved_Flag,
                       X_Approved_Date,
                       X_Closed_Flag,
                       X_Cancel_Flag,
                       X_Cancelled_By,
                       X_Cancel_Date,
                       X_Cancel_Reason,
                       X_Firm_Status_Lookup_Code,
                       X_Attribute_Category,
                       X_Attribute1,
                       X_Attribute2,
                       X_Attribute3,
                       X_Attribute4,
                       X_Attribute5,
                       X_Attribute6,
                       X_Attribute7,
                       X_Attribute8,
                       X_Attribute9,
                       X_Attribute10,
                       X_Attribute11,
                       X_Attribute12,
                       X_Attribute13,
                       X_Attribute14,
                       X_Attribute15,
                       X_Inspection_Required_Flag,
                       X_Receipt_Required_Flag,
                       X_Qty_Rcv_Tolerance,
                       X_Qty_Rcv_Exception_Code,
                       X_Enforce_Ship_To_Location,
                       X_Allow_Substitute_Receipts,
                       X_Days_Early_Receipt_Allowed,
                       X_Days_Late_Receipt_Allowed,
                       X_Receipt_Days_Exception_Code,
                       X_Invoice_Close_Tolerance,
                       X_Receive_Close_Tolerance,
                       X_Ship_To_Organization_Id,
                       X_Shipment_Num,
                       X_Source_Shipment_Id,
                       X_Shipment_Type,
                       X_Closed_Code,
                       NULL, --<R12 SLA>
                       X_Government_Context,
                       X_Receiving_Routing_Id,
                       X_Accrue_On_Receipt_Flag,
                       X_Closed_Reason,
                       X_Closed_Date,
                       X_Closed_By,
	               X_Global_Attribute_Category,
        	       X_Global_Attribute1,
        	       X_Global_Attribute2,
	               X_Global_Attribute3,
	               X_Global_Attribute4,
	               X_Global_Attribute5,
	               X_Global_Attribute6,
	               X_Global_Attribute7,
	               X_Global_Attribute8,
	               X_Global_Attribute9,
	               X_Global_Attribute10,
	               X_Global_Attribute11,
	               X_Global_Attribute12,
	               X_Global_Attribute13,
	               X_Global_Attribute14,
	               X_Global_Attribute15,
	               X_Global_Attribute16,
	               X_Global_Attribute17,
	               X_Global_Attribute18,
	               X_Global_Attribute19,
	               X_Global_Attribute20,
		       X_Country_of_Origin_Code,
		       X_Invoice_Match_Option,  --bgu, Dec. 7, 98
                       l_value_basis,      -- <Complex Work R12>
                       l_matching_basis,   -- <Complex Work R12>
		       --togeorge 10/12/2000
		       --Bug# 1433282
		       --added note to receiver
		       X_note_to_receiver,
--Start of Bug# 1548597.
                       X_Secondary_Unit_Of_Measure,
                       X_Secondary_Quantity,
                       X_Preferred_Grade,
                       X_Secondary_Quantity_Received,
                       X_Secondary_Quantity_Accepted,
                       X_Secondary_Quantity_Rejected,
                       X_Secondary_Quantity_Cancelled,
-- end of Bug# 1548597
                       null,     -- <SERVICES FPJ>
                       X_amount,  -- <SERVICES FPJ>
                       NULL, --transaction_flow_header_id
                       p_manual_price_change_flag,  -- <Manual Price Override FPJ>
		       p_org_id                   -- <R12.MOAC>
                   ,p_outsourced_assembly --<SHIKYU R12>
		       );

	/*
        ** Call the routine to update release header approval status
        */
        UPDATE po_releases
        SET   approved_flag        = 'R',
              authorization_status = 'REQUIRES REAPPROVAL'
        WHERE po_release_id = X_po_release_id
	AND   nvl(approved_flag,'N') not in ('N', 'R');

	/*
        ** Call the routine to attempt to update the quantity on
	** the purchase order line for blanket agreement releaeses.
	*/
        IF X_shipment_type = 'BLANKET' THEN

	/* Bug 482679
	 * problem with null quantity; replaced with following call.
	 */
          po_lines_sv.update_released_quantity('INSERT',
                                        	'BLANKET',
                                        	x_po_line_id,
                                        	x_orig_quantity,
                                        	x_quantity);
        END IF;

	return(TRUE);

      EXCEPTION
	WHEN OTHERS THEN
	-- togeorge 10/26/2000 commented out due to the problems while arcs in.
	-- dbms_output.put_line('In exception');
	  po_message_s.sql_error('insert_rel_shipment', X_progress, sqlcode);
          raise;
      END insert_rel_shipment;


END  PO_SHIPMENTS_SV3;

/
