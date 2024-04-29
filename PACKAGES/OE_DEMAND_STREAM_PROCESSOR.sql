--------------------------------------------------------
--  DDL for Package OE_DEMAND_STREAM_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEMAND_STREAM_PROCESSOR" AUTHID CURRENT_USER AS
/* $Header: OEXDSPXS.pls 115.0 99/07/16 08:12:23 porting ship $ */



Original_Sys_Ref_Exists EXCEPTION;


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
   );


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
   );


PROCEDURE delete_interface_records
   (
	x_order_source_id		IN	NUMBER,
	x_original_system_reference	IN	VARCHAR2,
	x_request_id			IN	NUMBER		Default	NULL
   );

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
--   Returns the sqlcode of the locking statement.  This should be checked to
--   see what was the reason for lock failure, or whether the lock request succeeded.
--


FUNCTION lock_demand_stream
   (
    x_demand_stream_id IN    NUMBER
    ) RETURN NUMBER;

--
--   NAME: next_line_number
--
--    DESCRIPTION: This routine takes a header_id for an order and returns the
--                 next line number for the lines of that order.  This will be
--                 used by release accounting to get new line number when they
--                 are inserting lines in interface tables.
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
    );

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
    ) RETURN VARCHAR2;

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
  ) RETURN VARCHAR2;

pragma restrict_references( line_scheduling_exists, WNDS,WNPS);

END OE_DEMAND_STREAM_PROCESSOR;

 

/
