--------------------------------------------------------
--  DDL for Package Body OE_ORDER_IMPORT_INTEROP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_IMPORT_INTEROP_PUB" AS
/* $Header: OEXPIMIB.pls 120.4.12010000.4 2009/12/23 07:25:29 spothula ship $ */

/*
---------------------------------------------------------------
--  Start of Comments
--  API name    OE_ORDER_IMPORT_INTEROP_PUB
--  Type        Public
--  Purpose 	To support PO's existing functionality.
--  Function
--  Pre-reqs
--  Parameters
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes: These APIs first check if old OE is installed or new OE.
--  If new OE (called ONT) is installed then we use the fixed value
--  for p_order_source_id (= 10 since this is the value fixed for
--  internal orders in OE_ORDER_SOURCES table) otherwise we use the
--  p_order_source_id passed by the caller.
--
--  End of Comments
------------------------------------------------------------------
*/

/* ------------------------------------------------------------------
   Function: Get_Open_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total open quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Open_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2
)
RETURN NUMBER
IS
   x_open_qty                 NUMBER;
   l_orig_sys_document_ref    VARCHAR2(50);
   l_orig_sys_line_ref        VARCHAR2(50);
   -- Fix for bug 2469894
   l_header_id                NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   -- Fix for bug 3217280
   l_org_id                    NUMBER;
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN

        /* bsadri performance fixes for bug 1807599 so that the
           indexes on oe_order_headers and oe_order_lines are
           used again
        */

        SELECT segment1
        INTO   l_orig_sys_document_ref
        FROM   po_requisition_headers_all
        WHERE  requisition_header_id = to_number(p_orig_sys_document_ref);

        -- Fix for bug 3217280 = Added table org_organization_definitions to get org_id
        SELECT rl.LINE_NUM, nvl(org.operating_unit,-1)
        INTO   l_orig_sys_line_ref, l_org_id
        FROM   po_requisition_lines_all rl,
               org_organization_definitions org
        WHERE  rl.requisition_line_id = to_number(p_orig_sys_line_ref)
        AND    rl.requisition_header_id = to_number(p_orig_sys_document_ref)
        AND    rl.source_organization_id = org.organization_id
        AND    rownum = 1;


        -- Fix for bug 2469894,2641565
        -- { Start
	-- 8555888
        SELECT h.header_id
        INTO   l_header_id
        FROM   oe_order_headers_all h,
		oe_order_lines_all l
        WHERE  h.order_source_id         = nvl(p_order_source_id,10)
	AND    h.header_id=l.header_id
        AND    l.source_document_line_id = p_orig_sys_line_ref --bug 9233983
        AND    h.orig_sys_document_ref   = l_orig_sys_document_ref
        AND    h.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    NVL(h.org_id,-1)          = l_org_id
	AND rownum=1; --bug 9233983

        Select sum(nvl(l.ordered_quantity, 0))
        INTO   x_open_qty
        FROM   oe_order_lines_all l
        WHERE  l.header_id               = l_header_id
        AND    l.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    l.source_document_line_id = to_number(p_orig_sys_line_ref)
        AND    NVL(l.shipped_quantity,0) =0
        AND    l.shippable_flag = 'Y'
        AND    nvl(l.cancelled_flag, 'N') = 'N'
        AND    NVL(l.org_id,-1)           = l_org_id
        GROUP BY l.source_document_line_id;

        -- End of bug 2469894,2641565 }
   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
	SELECT nvl(l.ordered_quantity, 0)
  	     - nvl(l.shipped_quantity,0)
	     - nvl(l.cancelled_quantity,0)
	  INTO x_open_qty
	  FROM so_headers h, so_lines l
         WHERE h.original_system_source_code    = p_order_source_id
	   AND h.original_system_reference      = p_orig_sys_document_ref
	   AND h.header_id		        = l.header_id
	   AND l.original_system_line_reference	= p_orig_sys_line_ref
	   AND nvl(l.open_flag,'N')  	        = 'Y';

   END IF;

   RETURN x_open_qty;

   EXCEPTION
      WHEN OTHERS THEN RETURN('');

END Get_Open_Qty;


/* ------------------------------------------------------------------
   Function: Get_Shipped_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total shipped quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Shipped_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2
)
RETURN NUMBER
IS
   x_shipped_qty              NUMBER;
   l_orig_sys_document_ref    VARCHAR2(50);
   l_orig_sys_line_ref        VARCHAR2(50);
   -- Fix for bug 2469894
   l_header_id                NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   -- Fix for bug 3217280
   l_org_id                    NUMBER;
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
        /* bsadri performance fixes for bug 1807599 so that the
           indexes on oe_order_headers and oe_order_lines are
           used again
        */

        SELECT segment1
        INTO l_orig_sys_document_ref
        FROM po_requisition_headers_all
        WHERE requisition_header_id = to_number(p_orig_sys_document_ref);

        -- Fix for bug 3217280 = Added table org_organization_definitions to get org_id
        SELECT rl.LINE_NUM, nvl(org.operating_unit,-1)
        INTO   l_orig_sys_line_ref, l_org_id
        FROM   po_requisition_lines_all rl,
               org_organization_definitions org
        WHERE  rl.requisition_line_id = to_number(p_orig_sys_line_ref)
        AND    rl.requisition_header_id = to_number(p_orig_sys_document_ref)
        AND    rl.source_organization_id = org.organization_id
        AND    rownum = 1;

        -- Fix for bug 2469894
        -- { Start
        --8555888
        SELECT h.header_id
        INTO   l_header_id
        FROM   oe_order_headers_all h,
	       oe_order_lines_all l
        WHERE  h.order_source_id         = nvl(p_order_source_id,10)
	AND    h.header_id=l.header_id
	AND    l.source_document_line_id = p_orig_sys_line_ref --bug 9233983
        AND    h.orig_sys_document_ref   = l_orig_sys_document_ref
        AND    h.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    h.org_id                  = l_org_id
	AND rownum=1; --bug 9233983

        Select sum(nvl(l.shipped_quantity,0))
        INTO   x_shipped_qty
        FROM   oe_order_lines_all l
        WHERE  l.header_id               = l_header_id
        AND    l.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    l.source_document_line_id = to_number(p_orig_sys_line_ref)
        AND    l.org_id                  = l_org_id
        GROUP BY l.source_document_line_id;

        -- End of bug 2469894 }

        /* Commented as part of above fix
	SELECT nvl(l.shipped_quantity,0)
	  INTO x_shipped_qty
-- Following is changed to _all tables because of change in PO to multi-org
	  FROM oe_order_headers_all h, oe_order_lines_all l
-- Following is changed to _all tables because of change in PO to multi-org
       WHERE h.order_source_id       	= nvl(p_order_source_id,10)
	   --AND h.source_document_id    	= p_orig_sys_document_ref
           AND h.orig_sys_document_ref        = l_orig_sys_document_ref
-- aksingh adding this for internal order multi-org change duplicate issue
-- Bug 1794206 fix
           AND h.source_document_id     = p_orig_sys_document_ref
	   AND h.header_id		          = l.header_id
	   --AND l.source_document_line_id   = p_orig_sys_line_ref;
            AND l.orig_sys_line_ref   = l_orig_sys_line_ref;
         */

   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
	SELECT nvl(l.shipped_quantity,0)
	  INTO x_shipped_qty
	  FROM so_headers h, so_lines l
         WHERE h.original_system_source_code    = p_order_source_id
	   AND h.original_system_reference      = p_orig_sys_document_ref
	   AND h.header_id		        = l.header_id
	   AND l.original_system_line_reference = p_orig_sys_line_ref;

   END IF;

   RETURN x_shipped_qty;

   EXCEPTION
      WHEN OTHERS THEN RETURN('');

END Get_Shipped_Qty;


/* ------------------------------------------------------------------
   Function: Get_Cancelled_Qty
   ------------------------------------------------------------------
   This accepts order source id, original system document reference and
   original system line reference and returns the total cancelled quantity.
   ------------------------------------------------------------------
*/
FUNCTION Get_Cancelled_Qty (
   p_order_source_id		IN  NUMBER
  ,p_orig_sys_document_ref    	IN  VARCHAR2
  ,p_orig_sys_line_ref    	IN  VARCHAR2

)
RETURN NUMBER
IS
   x_cancelled_qty            NUMBER;
   l_orig_sys_document_ref    VARCHAR2(50);
   l_orig_sys_line_ref        VARCHAR2(50);
   -- Fix for bug 2469894
   l_header_id                NUMBER;
   l_sum_of_quantity          NUMBER;
   l_diff_ship_cancel         NUMBER;

   -- Fix for bug 3217280
   l_org_id                    NUMBER;
   Cursor Cancelled_Qty_Cur Is
        Select sum(l.cancelled_quantity) cancelled_quantity,
               sum( l.shipped_quantity) shipped_quantity,
               sum(l.ordered_quantity) ordered_quantity
        FROM   oe_order_lines_all l
        WHERE  l.header_id               = l_header_id
        AND    l.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    l.source_document_line_id = to_number(p_orig_sys_line_ref)
        AND    l.org_id                  = l_org_id
        GROUP BY l.source_document_line_id;


   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
        /* bsadri performance fixes for bug 1807599 so that the
           indexes on oe_order_headers and oe_order_lines are
           used again
        */

        SELECT segment1
        INTO l_orig_sys_document_ref
        FROM po_requisition_headers_all
        WHERE requisition_header_id = to_number(p_orig_sys_document_ref);

        -- Fix for bug 3217280 = Added table org_organization_definitions to get org_id
        SELECT rl.LINE_NUM, nvl(org.operating_unit,-1)
        INTO   l_orig_sys_line_ref, l_org_id
        FROM   po_requisition_lines_all rl,
               org_organization_definitions org
        WHERE  rl.requisition_line_id = to_number(p_orig_sys_line_ref)
        AND    rl.requisition_header_id = to_number(p_orig_sys_document_ref)
        AND    rl.source_organization_id = org.organization_id
        AND    rownum = 1;

        -- Fix for bug 2469894,2641565
        -- { Start
	-- 8555888
        SELECT h.header_id
        INTO   l_header_id
        FROM   oe_order_headers_all h,
	       oe_order_lines_all l
        WHERE  h.order_source_id         = nvl(p_order_source_id,10)
	AND    h.header_id=l.header_id
	AND    l.source_document_line_id = p_orig_sys_line_ref --bug 9233983
        AND    h.orig_sys_document_ref   = l_orig_sys_document_ref
        AND    h.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    h.org_id                  = l_org_id
	AND ROWNUM =1; --bug 9233983

        l_sum_of_quantity := 0;

        For Cancelled_Qty_Rec In Cancelled_Qty_Cur Loop
           If Cancelled_Qty_Rec.Cancelled_Quantity Is Not Null Then
              l_sum_of_quantity := l_sum_of_quantity +
                                   Cancelled_Qty_Rec.Cancelled_Quantity;
            End If;

            If Cancelled_Qty_Rec.Shipped_Quantity > 0 Then
               l_diff_ship_cancel := Cancelled_Qty_Rec.Ordered_Quantity -
                                     Cancelled_Qty_Rec.Shipped_Quantity;
               If l_diff_ship_cancel > 0 Then
                  l_sum_of_quantity := l_sum_of_quantity + l_diff_ship_cancel;
               End If;
             End If;
        End Loop;

        x_cancelled_qty := l_sum_of_quantity;
        -- End of bug 2469894,2641565 }

   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
	SELECT l.cancelled_quantity
	  INTO x_cancelled_qty
	  FROM so_headers h, so_lines l
         WHERE h.original_system_source_code    = p_order_source_id
	   AND h.original_system_reference 	= p_orig_sys_document_ref
	   AND h.header_id		        = l.header_id
	   AND l.original_system_line_reference = p_orig_sys_line_ref;

   END IF;

   RETURN x_cancelled_qty;

   EXCEPTION
      WHEN OTHERS THEN RETURN('');

END Get_Cancelled_Qty;


/* ------------------------------------------------------------------
   Function: Get_Order_Number
   ------------------------------------------------------------------
   This accepts Order Source Id, Original System Reference and
   Original System Line Reference and returns the corresponding
   Order Number.
   ------------------------------------------------------------------
*/
FUNCTION Get_Order_Number (
   p_order_source_id   		IN  NUMBER
  ,p_orig_sys_document_ref   	IN  VARCHAR2
  ,p_orig_sys_line_ref   	IN  VARCHAR2
)
RETURN NUMBER
IS
   x_order_number            	NUMBER;
   l_orig_sys_document_ref    VARCHAR2(50);
   l_orig_sys_line_ref        VARCHAR2(50);
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   -- Fix for bug 3217280
   l_org_id                    NUMBER;
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
        /* bsadri performance fixes for bug 1807599 so that the
           indexes on oe_order_headers and oe_order_lines are
           used again
        */

        SELECT segment1
        INTO l_orig_sys_document_ref
        FROM po_requisition_headers_all
        WHERE requisition_header_id = to_number(p_orig_sys_document_ref);

        -- Fix for bug 3217280 = Added table org_organization_definitions to get org_id
        SELECT rl.LINE_NUM, nvl(org.operating_unit,-1)
        INTO   l_orig_sys_line_ref, l_org_id
        FROM   po_requisition_lines_all rl,
               org_organization_definitions org
        WHERE  rl.requisition_line_id = to_number(p_orig_sys_line_ref)
        AND    rl.requisition_header_id = to_number(p_orig_sys_document_ref)
        AND    rl.source_organization_id = org.organization_id
        AND    rownum = 1;

        -- Fix 7031428, added distinct for split lines from partial shipment

        SELECT distinct h.order_number
        INTO   x_order_number
        FROM   oe_order_headers_all h,oe_order_lines_all l
        WHERE  h.order_source_id         = nvl(p_order_source_id,10)
        AND    h.orig_sys_document_ref   = l_orig_sys_document_ref
	AND    h.header_id=l.header_id
        AND    h.source_document_id      = to_number(p_orig_sys_document_ref)
        AND    l.orig_sys_document_ref   = l_orig_sys_document_ref
        AND    l.orig_sys_line_ref       = l_orig_sys_line_ref
        AND    h.source_document_id      = l.source_document_id
        AND    nvl(h.org_id, -1)          = l_org_id;

   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
	SELECT h.order_number
	  INTO x_order_number
	  FROM so_headers h, so_lines l
         WHERE h.original_system_source_code    = p_order_source_id
	   AND h.original_system_reference 	= p_orig_sys_document_ref
	   AND h.header_id		        = l.header_id
	   AND l.original_system_line_reference = p_orig_sys_line_ref;

   END IF;

   RETURN x_order_number;

   EXCEPTION
     WHEN OTHERS THEN RETURN('');

END Get_Order_Number;


/* ------------------------------------------------------------------
   Function: Get_Header_Id
   ------------------------------------------------------------------
   This accepts a Requisition Line Id and returns the corresponding
   Order Header Id.

   p_type='S' will get it from so_headers/oe_order_headers table and
         ='D' will get it from so_drop_ship_sources/oe_drop_ship_sources
   ------------------------------------------------------------------
*/
-- aksingh question ask whether they are sending id in ref column ????? 11/28
FUNCTION Get_Header_Id (
   p_order_source_id   		IN  NUMBER
  ,p_orig_sys_document_ref   	IN  VARCHAR2
  ,p_requisition_header_id    IN  NUMBER
  ,p_type			          IN  VARCHAR2
  ,p_requisition_line_id      IN  NUMBER
)
RETURN NUMBER
IS
   x_header_id                NUMBER;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   -- Fix for bug 3217280
   l_org_id                    NUMBER;
   l_orig_sys_line_ref         VARCHAR2(50);
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
      IF p_type = 'H' THEN
        /* bsadri performance fixes for bug 1807599 so that the
           indexes on oe_order_headers and oe_order_lines are
           used again
        */

        -- Fix for bug 3217280 = Added table org_organization_definitions to get org_id
        SELECT rl.LINE_NUM, nvl(org.operating_unit,-1)
        INTO   l_orig_sys_line_ref, l_org_id
        FROM   po_requisition_lines_all rl,
               org_organization_definitions org
        WHERE  rl.requisition_line_id    = p_requisition_line_id
        AND    rl.requisition_header_id  = p_requisition_header_id
        AND    rl.source_organization_id = org.organization_id
        AND    rownum = 1;

        SELECT h.header_id
        INTO   x_header_id
        FROM   oe_order_headers_all h,
	       oe_order_lines_all l
        WHERE  h.order_source_id         = nvl(p_order_source_id,10)
	AND    h.header_id=l.header_id
	AND    l.source_document_line_id       = p_requisition_line_id
        AND    h.orig_sys_document_ref   = p_orig_sys_document_ref
        AND    h.source_document_id      = p_requisition_header_id
        AND    nvl(h.org_id,-1)          = l_org_id
	AND rownum=1;--bug 9233983   --added nvl for bug5394855

      ELSIF p_type = 'D' THEN
	SELECT max(d.header_id)
	  INTO x_header_id
	  FROM oe_drop_ship_sources d
         WHERE d.requisition_header_id  = p_requisition_header_id
           AND d.requisition_line_id    =
               nvl(p_requisition_line_id, d.requisition_line_id);
      END IF;

   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
      IF p_type = 'H' THEN
	SELECT h.header_id
	  INTO x_header_id
	  FROM so_headers h
         WHERE h.original_system_source_code = p_order_source_id
	   AND h.original_system_reference   = p_orig_sys_document_ref;

      ELSIF p_type = 'D' THEN
	SELECT max(d.header_id)
	  INTO x_header_id
	  FROM so_drop_ship_sources d
         WHERE d.requisition_header_id  = p_requisition_header_id;
      END IF;

   END IF;

   RETURN x_header_id;

     EXCEPTION
      WHEN OTHERS THEN RETURN('');

END Get_Header_Id;


/* ------------------------------------------------------------------
   Function: Get_Req_Header_Id
   ------------------------------------------------------------------
   This accepts a Order Header Id and returns the corresponding
   Requisition Header Id.

   p_type='S' will get it from so_headers/oe_order_headers table and
         ='D' will get it from so_drop_ship_sources/oe_drop_ship_sources
   ------------------------------------------------------------------
*/
FUNCTION Get_Req_Header_Id (
   p_header_id   		IN  NUMBER
  ,p_type			IN  VARCHAR2
)
RETURN NUMBER IS
x_req_header_id              NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF OE_INSTALL.Get_Active_Product = 'ONT' THEN
      IF p_type = 'H' THEN		/* From oe_order_headers */
         -- Following change is made to support the multi-org PO functionality
         --     SELECT r.requisition_header_id
         --	  INTO x_req_header_id
         --	  FROM oe_order_headers	h, po_requisition_headers r
         --     WHERE h.header_id    		= p_header_id
         --     AND h.orig_sys_document_ref	= r.segment1;

         SELECT source_document_id
         INTO   x_req_header_id
         FROM   oe_order_headers_all
         WHERE  header_id = p_header_id;
      ELSIF p_type = 'D' THEN		/* From oe_drop_ship_sources */
         SELECT max(d.requisition_header_id)
	 INTO   x_req_header_id
	 FROM   oe_drop_ship_sources d
         WHERE  d.header_id = p_header_id;
      END IF;
   ELSIF OE_INSTALL.Get_Active_Product = 'OE' THEN
      IF p_type = 'H' THEN		/* From oe_order_headers */
     	 SELECT r.requisition_header_id
	 INTO x_req_header_id
	 FROM so_headers h, po_requisition_headers r
         WHERE h.header_id    		   = p_header_id
         AND h.original_system_reference = r.segment1;
      ELSIF p_type = 'D' THEN		/* From oe_drop_ship_sources */
         SELECT d.requisition_header_id
	 INTO x_req_header_id
	 FROM so_drop_ship_sources d
         WHERE d.header_id = p_header_id;
      END IF;
   END IF;
   RETURN x_req_header_id;

   EXCEPTION
      WHEN OTHERS THEN RETURN('');

END Get_Req_Header_Id;


   ------------------------------------------------------------------
   -- Procedure: Get_Line_Id
   ------------------------------------------------------------------
   -- This accepts a Requisition Line Id and Line Num for the requisition
   -- and return order's line id.
   ------------------------------------------------------------------
   -- Fix for bug 2520049
   -- { Start
PROCEDURE Get_Line_Id (
   p_order_source_id            IN  NUMBER
  ,p_orig_sys_document_ref      IN  VARCHAR2
  ,p_requisition_header_id      IN  NUMBER
  ,p_line_num                   IN  VARCHAR2
  ,p_requisition_line_id        IN  NUMBER
  ,x_line_id_tbl               OUT NOCOPY /* file.sql.39 change */  LineId_Tbl_Type
  ,x_return_status             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
   l_header_id                NUMBER;
   l_line_id                  NUMBER;
   l_line_id_count            NUMBER := 0;
   Cursor Line_Id_Cur Is
        Select line_id
        FROM   oe_order_lines_all l
        WHERE  l.header_id               = l_header_id
        AND    l.source_document_id      = p_requisition_header_id
        AND    l.source_document_line_id = p_requisition_line_id
        AND    l.order_source_id         = p_order_source_id
        AND    l.shipped_quantity       IS NOT NULL;
        --
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
        --
BEGIN

   oe_debug_pub.add('Entering OEXPIMIB.Get_Line_Id');

   x_return_status := fnd_api.g_ret_sts_success;

-- for bug 8555888

   SELECT h.header_id
   INTO   l_header_id
   FROM   oe_order_headers_all h,
	  oe_order_lines_all l
   WHERE  h.order_source_id         = p_order_source_id
   AND    h.header_id=l.header_id
   AND    l.source_document_line_id = p_requisition_line_id
   AND    h.orig_sys_document_ref   = p_orig_sys_document_ref
   AND    h.source_document_id      = p_requisition_header_id
   AND rownum=1; --bug 9233983

   Open Line_Id_Cur;
   Loop
     Fetch Line_Id_Cur Into l_line_id;
     Exit When Line_Id_Cur%NotFound;

     l_line_id_count := l_line_id_count + 1;
     x_line_id_tbl(l_line_id_count).line_id := l_line_id;
   End Loop;


EXCEPTION
   WHEN OTHERS THEN
     oe_debug_pub.add('Unexpected error: '||sqlerrm);
     If oe_msg_pub.check_msg_level(oe_msg_pub.g_msg_lvl_unexp_error) Then
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        oe_msg_pub.add_exc_Msg (g_pkg_name, 'oe_order_import_interop_pub');
     END IF;

END Get_Line_Id;
 -- End }


/*Bug2770121*/
/* ------------------------------------------------------------------
   Procedure: Get_Requisition_Header_Ids
   ------------------------------------------------------------------
   This accepts a Order Header Id and returns the corresponding
   Requisition Header Ids associated with the Drop ship Header id.
   ------------------------------------------------------------------
*/
Procedure Get_Requisition_Header_Ids (
   p_header_id                  IN  NUMBER
  ,x_req_header_id_tbl          OUT NOCOPY /* file.sql.39 change */  HeaderId_Tbl_Type
)
IS
   l_header_id        NUMBER;
   l_header_id_count  NUMBER := 0;
    -- Addded not null condition for the bug 3688591
    CURSOR header_id_cur is
        SELECT distinct d.requisition_header_id
        FROM   oe_drop_ship_sources d
        WHERE  d.header_id = p_header_id
        And    d.requisition_header_id  is not null;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
   oe_debug_pub.add('Entering OEXPIMIB.Get_Requisition_header_ids');
   END IF;

         Open header_Id_Cur;
         Loop
              Fetch header_Id_Cur Into l_header_id;
              Exit When header_Id_Cur%NotFound;

             l_header_id_count := l_header_id_count + 1;
             x_req_header_id_tbl(l_header_id_count).header_id := l_header_id;
         End Loop;

  EXCEPTION
     WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Unexpected error: '||sqlerrm);
      END IF;
       If oe_msg_pub.check_msg_level(oe_msg_pub.g_msg_lvl_unexp_error) Then
          oe_msg_pub.add_exc_Msg (g_pkg_name, 'oe_order_import_interop_pub');
       END IF;

END Get_Requisition_Header_Ids;

END OE_ORDER_IMPORT_INTEROP_PUB;

/
