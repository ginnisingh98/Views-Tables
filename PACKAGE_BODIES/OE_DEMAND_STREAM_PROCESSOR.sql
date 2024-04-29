--------------------------------------------------------
--  DDL for Package Body OE_DEMAND_STREAM_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEMAND_STREAM_PROCESSOR" AS
/* $Header: OEXDSPXB.pls 115.0 99/07/16 08:12:20 porting ship $ */

--
--  NAME:    Order_Info.
--
--  DESCRIPTION:
--
--  This routine takes an order number and order type name
--  and returns the header_id, order_type_id, customer_id and open_flag
--  for that order.
--
--  Also, the entry status is returned which has the following values:
--
--  'BOOKED', 'ENTERED', 'PARTIAL' or the value of the s1 column if users
--  define something other than the above.
--
--  RETURN VALUES:
--
--  x_result:  'Y' if success, 'N' if failure.

--  x_sqlcode: The SQLCODE for the statement that failed.  Typically, this
--             will be NO_DATA_FOUND if the order_number, order_type
--             combination does not exist in the database.
--
--   NOTE: x_sqlcode is not applicable when x_result is 'Y'
--

PROCEDURE order_info
  (
   x_order_number      IN    NUMBER,
   x_order_type_name   IN    VARCHAR2,
   x_header_id         OUT   NUMBER,
   x_order_type_id     OUT   NUMBER,
   x_customer_id       OUT   NUMBER,
   x_open_flag         OUT   VARCHAR2,
   x_entry_status      OUT   VARCHAR2,
   x_po_number         OUT   VARCHAR2,
   x_result            OUT   VARCHAR2,
   x_sqlcode           OUT   NUMBER
   ) IS
BEGIN

   -- Initialize results

   x_header_id     := NULL;
   x_order_type_id := NULL;
   x_customer_id   := NULL;
   x_open_flag     := NULL;
   x_entry_status  := NULL;
   x_po_number     := NULL;

   SELECT soh.header_id,
          soh.order_type_id,
          soh.customer_id,
          soh.open_flag,
	  decode (soh.s1,
			15, 'ENTERED',
			 5, 'PARTIAL',
			 1, 'BOOKED',
		  to_char(soh.s1)),
	  purchase_order_num
   INTO
          x_header_id,
          x_order_type_id,
          x_customer_id,
          x_open_flag,
	  x_entry_status,
	  x_po_number
   FROM
          so_headers     soh,
          so_order_types sot
   WHERE
          sot.order_type_id = soh.order_type_id
     AND  sot.name          = x_order_type_name
     AND  soh.order_number  = x_order_number;

   -- Return success

   x_result  := 'Y';
   x_sqlcode := 0;
   RETURN;

EXCEPTION
   WHEN OTHERS THEN

      -- Return failure

      x_result  := 'N';
      x_sqlcode := SQLCODE;
      x_header_id     := NULL;
      x_order_type_id := NULL;
      x_customer_id   := NULL;
      x_open_flag     := NULL;
      x_entry_status  := NULL;
      x_po_number     := NULL;

      RETURN;

END order_info;

--
--  NAME:    Order_Info.
--
--  DESCRIPTION:
--
--  This routine takes a header_id and returns the order number, order type
--  and open_flag for that order.
--
--  Also, the entry status is returned which has the following values:
--
--  'BOOKED', 'ENTERED', 'PARTIAL' or the value of the s1 column if users
--  define something other than the above.
--
--  RETURN VALUES:
--
--  x_result:  'Y' if success, 'N' if failure.

--  x_sqlcode: The SQLCODE for the statement that failed.  Typically, this
--             will be NO_DATA_FOUND if the order_number, order_type
--             combination does not exist in the database.
--
--   NOTE: x_sqlcode is not applicable when x_result is 'Y'
--

PROCEDURE order_info
  (
   x_header_id         IN     NUMBER,
   x_order_number      OUT    NUMBER,
   x_order_type_name   OUT    VARCHAR2,
   x_open_flag         OUT   VARCHAR2,
   x_entry_status      OUT   VARCHAR2,
   x_po_number         OUT   VARCHAR2,
   x_result            OUT   VARCHAR2,
   x_sqlcode           OUT   NUMBER
   ) is
begin

   -- Initialize results

   x_order_number     := NULL;
   x_order_type_name := NULL;
   x_open_flag     := NULL;
   x_entry_status  := NULL;
   x_po_number     := NULL;


   SELECT soh.order_number,
          sot.name,
          soh.open_flag,
	  decode (soh.s1,
			15, 'ENTERED',
			 5, 'PARTIAL',
			 1, 'BOOKED',
		  to_char(soh.s1)),
	  soh.purchase_order_num
   INTO
          x_order_number,
          x_order_type_name,
          x_open_flag,
	  x_entry_status,
	  x_po_number
   FROM
          so_headers     soh,
          so_order_types sot
   WHERE
          sot.order_type_id = soh.order_type_id
     AND  soh.header_id     = x_header_id;

   -- Return success

   x_result  := 'Y';
   x_sqlcode := 0;
   RETURN;

EXCEPTION
   WHEN OTHERS THEN

      -- Return failure

      x_result  := 'N';
      x_sqlcode := SQLCODE;
      x_order_number    := NULL;
      x_order_type_name := NULL;
      x_open_flag       := NULL;
      x_entry_status  := NULL;
      x_po_number     := NULL;

      RETURN;

end order_info;


PROCEDURE delete_interface_records
   (
	x_order_source_id		IN	NUMBER,
	x_original_system_reference	IN	VARCHAR2,
	x_request_id			IN	NUMBER		Default	NULL
   ) is
begin

	delete
	from	so_lines_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

	delete
	from	so_line_details_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

	delete
	from	so_price_adjustments_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

	delete
	from	so_sales_credits_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

	delete
	from	so_service_details_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

	delete
	from	so_headers_interface
	where	order_source_id			= x_order_source_id
	and	original_system_reference	= x_original_system_reference
	and	nvl(request_id, -99999)		= nvl(x_request_id, nvl(request_id, -99999));

exception
	when others then
		Raise;

end delete_interface_records;





--
--   NAME:  Lock_Demand_Stream
--
--   DESCRIPTION:  This routine will obtain all the locks necessary for a particular
--   Releaese Accounting Demand Stream.   The following data gets locked for the
--   demand_stream_id passed in as the argument.
--
--   * Open ATO Lines that have not yet been manufacturing released.
--   * Other open  Lines that have not yet been fully pick released.
--   * Unreleased Line Details for these lines.
--   * Backordered picking lines for this demand_stream_id that have not been
--     fully backorder released.
--   * Unreleased backordered picking line details for these backordered
--     picking lines.
--
--   RETURN VALUES:
--
--   Returns the SQLCODE of the locking statement.  This should be checked to
--   see what was the reason for lock failure, or whether the lock request succeeded.
--

FUNCTION lock_demand_stream
   (
    x_demand_stream_id IN    NUMBER
    ) RETURN NUMBER IS

   CURSOR lock_lin_and_det(p_demand_stream_id NUMBER) IS
      SELECT
	     lin.line_id,
	     det.line_detail_id
      FROM
             so_line_details         det,
             so_lines                lin
      WHERE
             Nvl(det.released_flag, 'N') = 'N'
	AND  lin.line_id                 = det.line_id (+)
	AND  Decode(lin.s27,                     -- Manufacturing Release
		    NULL, 'LOCK',                  -- Lock if not reached
		    18,   'LOCK',                  -- Lock if eligible
		    8,    'LOCK',                  -- Lock if not applicable
		    'DONT_LOCK')         = 'LOCK'  -- Don't lock otherwise
	AND lin.open_flag || '' = 'Y'
	AND lin.demand_stream_id = p_demand_stream_id
      FOR UPDATE OF lin.line_id, det.line_detail_id NOWAIT;

   CURSOR lock_backordered_lin_and_det(p_order_line_id NUMBER) IS
      SELECT
	     pln.picking_line_id,
             pld.picking_line_detail_id
      FROM
             so_picking_lines pln,
             so_picking_line_details pld
      WHERE
	     pln.picking_header_id = 0
	AND  nvl(pld.released_flag, 'N') = 'N'
	AND  pln.picking_line_id = pld.picking_line_id
	AND  pln.order_line_id = p_order_line_id
      FOR UPDATE OF pln.picking_line_id, pld.picking_line_detail_id NOWAIT;


   temp_line_id                NUMBER := NULL;
   temp_line_detail_id         NUMBER := NULL;

   prev_line_id                NUMBER := NULL;

   return_code                 NUMBER := 0;

BEGIN

   --
   -- Establish a savepoint, so that if there is any locking error, we can
   -- rollback to this savepoint, hence releasing all locks obtained by
   -- this routine.
   --

   SAVEPOINT lock_dem_str;

   --
   -- Lock the lines and details for this demand_stream_id. The open statement
   -- will do this for you.
   --

   OPEN lock_lin_and_det(x_demand_stream_id);

   --
   -- Loop through the above cursor and for each new line_id, lock all of its
   -- backordered, unreleased  picking lines and details.
   --

   FETCH lock_lin_and_det INTO temp_line_id, temp_line_detail_id;

   WHILE lock_lin_and_det%FOUND LOOP

      --
      -- We do not need to fetch anything from this cursor. The open
      -- statement will obtain the lock for us.
      --

     OPEN  lock_backordered_lin_and_det(temp_line_id);
     CLOSE lock_backordered_lin_and_det;

     prev_line_id := temp_line_id;

     WHILE prev_line_id = temp_line_id AND lock_lin_and_det%FOUND LOOP
	FETCH lock_lin_and_det INTO temp_line_id, temp_line_detail_id;
     END LOOP;

   END LOOP;


   CLOSE lock_lin_and_det;

   -- At this point, we have successfully locked all four tables, return 0 for success.

   RETURN 0;

EXCEPTION

   -- If any of the cursors find nothing, it is still a success.

   WHEN NO_DATA_FOUND THEN

      IF lock_lin_and_det%isopen THEN
	 CLOSE lock_lin_and_det;
      END IF;

      IF lock_backordered_lin_and_det%isopen THEN
	 CLOSE lock_backordered_lin_and_det;
      END IF;


      RETURN 0;

   --
   -- If there are any other exceptions, including locks not obtained,
   -- return the SQLCODE after rolling back to the savepoint.
   --

   WHEN OTHERS THEN

      return_code := SQLCODE;

      IF lock_lin_and_det%ISOPEN THEN
	 CLOSE lock_lin_and_det;
      END IF;

      IF lock_backordered_lin_and_det%ISOPEN THEN
	 CLOSE lock_backordered_lin_and_det;
      END IF;

      ROLLBACK TO lock_dem_str;

      RETURN return_code;

END lock_demand_stream;


--
--   NAME: next_line_number
--
--   DESCRIPTION: This routine takes a header_id for an order and returns the
--                next line number for the lines of that order.  This will be
--                used by release accounting to get new line number when they
--                are inserting lines in interface tables.
--
--   NOTE:        This routine assumes that the header_id exists in the
--                database.
--
--   RETURN VALUES:
--     x_result:  'Y' if success, 'N' if failure.
--     x_sqlcode: The SQLCODE for the statement that failed.
--
--   NOTE: x_sqlcode is not applicable when x_result is 'Y'
--

PROCEDURE next_line_number
   (
    x_header_id        IN    NUMBER,
    x_line_number      OUT   NUMBER,
    x_result           OUT   VARCHAR2,
    x_sqlcode          OUT   NUMBER
    ) IS
BEGIN

   x_line_number := NULL;
   x_sqlcode := 0;
   x_result := 'Y';

   SELECT
          Nvl(MAX(line_number), 0) + 1
   INTO
          x_line_number
   FROM
          so_lines
   WHERE
          header_id = x_header_id
     AND  shipment_schedule_line_id IS NULL
     AND  parent_line_id IS NULL
     AND  service_parent_line_id IS NULL;

   RETURN;


EXCEPTION
   WHEN OTHERS THEN

      x_sqlcode := SQLCODE;
      x_result := 'N';
      x_line_number := NULL;

      RETURN;


END next_line_number;



--
--  NAME: set_original_system_reference
--
--  DESCRIPTION: This routine takes a header_id and updates the
--  original_system_source_code and original_system_reference information
--  as specified by the x_order_source_id and x_original_system_reference.
--
--  If no original_system_reference is passed, the system generates an
--  automatic original_system_reference by concatening Order Number, Order
--  Type.
--
--   Raises an exception OE_DEMAND_STREAM_PROCESSOR.Original_Sys_Ref_Exists
--   if the eventual combination of original_system_source_code and
--   original_system_reference already exist in the database.
--   The calling program must handle this exception.
--
--   RETURN_VALUES:
--     x_result:  'Y' if success, 'N' if failure.
--     x_sqlcode: The SQLCODE for the statement that failed.
--

FUNCTION set_original_system_reference
   (
    x_header_id                     IN      NUMBER,
    x_order_source_id 		    IN      NUMBER,
    x_original_system_reference     IN      VARCHAR2 DEFAULT NULL,
    x_result                        OUT     VARCHAR2,
    x_sqlcode                       OUT     NUMBER
    ) RETURN VARCHAR2 IS

       l_original_system_reference	VARCHAR2(50) := NULL;
       l_original_system_source_code	VARCHAR2(30) := NULL;
       l_order_number			NUMBER	     := NULL;
       l_order_type			VARCHAR2(30) := NULL;
BEGIN

   -- Put a savepoint so we can release the lock in case of errors;

   SAVEPOINT set_original_system_reference;

   -- lock the order we want to operate on.

   SELECT original_system_source_code, original_system_reference
   INTO   l_original_system_source_code, l_original_system_reference
   FROM
          so_headers
   WHERE
          header_id = x_header_id
   FOR UPDATE OF
          original_system_source_code;

   --
   -- If either original_system_source_code or original_system_reference
   -- already exist, then exit with success.
   -- Exception to the above rule, copied orders.  If you copy an
   -- order and then want to use it for automotive, we will override the
   -- source order informaiton with the automotive information.
   -- ORIGINAL_SYSTEM_SOURCE_CODE FOR COPIED ORDERS IS '2'

   IF ((l_original_system_source_code <> '2') and
	  (l_original_system_source_code IS NOT NULL or
       	   l_original_system_reference IS NOT NULL)) THEN

      x_result  := 'Y';
      x_sqlcode := 0;
      RETURN l_original_system_reference;

   END IF;

   -- Both original_system_source_code and original_system_reference is NULL.
   -- Now we get the order type information.

   SELECT  h.order_number,
           t.name
   INTO
           l_order_number,
           l_order_type
   FROM
           so_headers h,
     	   so_order_types t
   WHERE
           h.order_type_id = t.order_type_id
   AND     h.header_id = x_header_id;


   l_original_system_source_code := to_char(x_order_source_id);
   l_original_system_reference   := x_original_system_reference;

   -- If the order has no reference or it is a copied order
   IF (l_original_system_reference IS NULL
       OR
       l_original_system_source_code = '2')
      THEN

      l_original_system_reference := Substr(To_char(l_order_number) ||
					    ', ' ||
					    l_order_type, 1, 50);

      l_original_system_source_code := NULL;
      fnd_profile.get('RLA_ORDERIMPORT_SOURCE', l_original_system_source_code);

   END IF;



   --
   -- We NULL out the source header_id just to be safe.  When automotive
   -- interfaces lines into a copied order, they no longer want to track
   -- the original order that the header was copied from
   --

   UPDATE so_headers
     SET original_system_source_code = l_original_system_source_code,
	 original_system_reference   = l_original_system_reference,
	 source_header_id            = NULL
     WHERE
         header_id = x_header_id
     AND not exists
	 (SELECT 'x'
	  FROM   so_headers
          WHERE  original_system_reference = l_original_system_reference
          AND    original_system_source_code = l_original_system_source_code);

   IF SQL%NOTFOUND THEN
     RAISE OE_DEMAND_STREAM_PROCESSOR.Original_Sys_Ref_Exists;
   END IF;

   x_result := 'Y';
   x_sqlcode := 0;

   RETURN l_original_system_reference;

EXCEPTION

   WHEN OE_DEMAND_STREAM_PROCESSOR.Original_Sys_Ref_Exists THEN

     x_sqlcode := SQLCODE;
     x_result  := 'N';

     ROLLBACK TO SAVEPOINT set_original_system_reference;

     RAISE OE_DEMAND_STREAM_PROCESSOR.Original_Sys_Ref_Exists;

   WHEN OTHERS THEN

      x_sqlcode := SQLCODE;
      x_result  := 'N';

      ROLLBACK TO SAVEPOINT set_original_system_reference;

      RETURN NULL;

END set_original_system_reference;


--
--  NAME: line_scheduling_exists
--
--  DESCRIPTION: This routine takes a line_id and determines whether
--  any scheduling exists for this line or any of its components.
--
--  Release Accounting uses this information to determine whether or
--  not they can change order quantities on order lines through order
--  import.
--
--   RETURNS:
--
--  'Y'  if scheduling exists i.e. any line detail of this line or a
--  component is demanded, reserved or supply reserved.
--  Changes to quantities are not allowed
--
--  'N' if scheduling does not exist for this line or any of its
--  components.  Changes to quantities will be accepted.
--

FUNCTION line_scheduling_exists
  (
   x_line_id				IN	NUMBER
  ) RETURN VARCHAR2 is

l_scheduling_exists 	VARCHAR2(1) := 'N';

begin

   SELECT 'Y'
   INTO   l_scheduling_exists
   FROM   so_line_details
   WHERE  line_id in
   (
	SELECT line_id
	FROM   so_lines
	WHERE  (line_id = x_line_id
	OR      parent_line_id = x_line_id)
   )
   AND   schedule_status_code is NOT NULL
   AND   rownum = 1;

   return l_scheduling_exists;

exception

  WHEN NO_DATA_FOUND THEN
	return 'N';

end line_scheduling_exists;


END OE_DEMAND_STREAM_PROCESSOR;

/
