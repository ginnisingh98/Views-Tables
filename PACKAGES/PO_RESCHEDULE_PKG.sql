--------------------------------------------------------
--  DDL for Package PO_RESCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RESCHEDULE_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRSCHS.pls 120.0.12010000.4 2010/03/19 12:35:03 lswamina ship $ */
/**
 *  Parameter:
 *  (1)X_need_by_date_old: The old need_by_date for the shipment, should not be
 *     null.
 *  (2)X_need_by_date: The new need_by_date for the shipment, should not be
 *     null.
 *  (3)X_po_header_id: The header id on which the change should be made.
 *     MRP should pass in SUPPLY_HEADER_ID from view MRP_PO_SUPPLY_VIEW
 *  (4)X_po_line_id: The line id on which the change should be made. For
 *     releases, null should be passed in.
 *     MRP should pass in SUPPLY_LINE_ID from view MRP_PO_SUPPLY_VIEW
 *  (5) X_supply_number:
 *     MRP should pass in SUPPLY_NUMBER from view MRP_PO_SUPPLY_VIEW
 *     The format of it is:
 *     decode(MS.PO_RELEASE_ID, NULL,PH.SEGMENT1,
 *        PH.SEGMENT1||'('||TO_CHAR(PR.RELEASE_NUM)'||')')
 *
 *   Algorithm:
 *   The program will first validate the reschedule using existing PO
 *   form logic, if it passes the validation, then the function will
 *   change in the
 *   a) shipment level (For Standard, Planned PO).
 *   b) shipment level. (For blanket, scheduled release).
 *   Update corresponding tables, archive the changes, and launch the
 *   PO reapproval workflow process.
 *
 *   Assumption:
 *   For each po line , or release passed in by MRP, if there're more
 *   than one shipment, 'need-by-date' of all these shipments with
 *   the old need_by_date will be updated.
 */

/** Bug 922852
 *  bgu,  July 01, 1999
 *  User should not be able to reschedule encumbered PO shipments
 */
/*Bug2187544
  The need by date check should be nvl(promised_date,need_by_date) instead
  of pll.need_by_date bcos in mtl supply table PO inserts the need by
  date  using the same logic i.e nvl(poll.promised_date,pol.need_by_date)
*/

-- <PO_CHANGE_API FPJ>
-- In 115.8, changed the cursor to select only the LINE_LOCATION_ID,
-- because the other fields are unnecessary when calling the PO Change API.
-- Also, removed the restriction on encumbered shipments, because the
-- PO Change API is capable of unreserving and re-reserving shipments.

/* Bug3066274 fixed. Added trunc to the date fields in the below
   select statement.
*/

cursor po_shipment_rel_cursor (X_po_release_id number,
                               X_need_by_date_old date,
                               X_shipment_num number) is  --2279541
      select poll.line_location_id
      from   po_line_locations_all poll, po_releases_all por
      where  por.po_release_id = X_po_release_id
        and  por.po_release_id = poll.po_release_id
        and  poll.shipment_num = nvl(X_shipment_num,poll.shipment_num) --2279541
             -- <NBD TZ/Timestamp FPJ START>
             -- Remove TRUNC() on both sides
        and  nvl(poll.promised_date,poll.need_by_date) = X_need_by_date_old
             -- <NBD TZ/Timestamp FPJ END>
        for  update of poll.need_by_date;

/** Bug 885536
 *  bgu, May 07, 1999
 *  The previous definition of cursor will pick up scheduled releases too,
 *  resulting in workflow item type cannot be found for the wrong
 *  combination of document type 'PO' and document subtype 'SCHEDULED'
 */
/*Bug2187544
  The need by date check should be nvl(promised_date,need_by_date) instead
  of pll.need_by_date bcos in mtl supply table PO inserts the need by
  date  using the same logic i.e nvl(poll.promised_date,pol.need_by_date)
*/

-- <PO_CHANGE_API FPJ>
-- In 115.8, changed the cursor to select only the LINE_LOCATION_ID,
-- because the other fields are unnecessary when calling the PO Change API.
-- Also, removed the restriction on encumbered shipments, because the
-- PO Change API is capable of unreserving and re-reserving shipments.

/* Bug3066274 fixed. Added trunc to the date fields in the below
   select statement.
*/
cursor po_shipment_cursor (X_po_line_id number,
			   X_need_by_date_old date,
                           X_shipment_num number) is  -- 2279541
      select poll.line_location_id
      from   po_line_locations_all poll, po_lines_all pol
      where  pol.po_line_id = X_po_line_id
        and  poll.po_line_id = pol.po_line_id
        and  poll.shipment_num = nvl(X_shipment_num,poll.shipment_num) -- 2279541
             -- <NBD TZ/Timestamp FPJ START>
             -- Remove TRUNC() on both sides
        and  nvl(poll.promised_date,poll.need_by_date) = X_need_by_date_old
             -- <NBD TZ/Timestamp FPJ END>
        and  poll.shipment_type in ('STANDARD', 'PLANNED')   --885536
        for  update of poll.need_by_date;

Function RESCHEDULE( X_need_by_date_old date,
	             X_need_by_date date,
	             X_po_header_id number,
                     X_po_line_id number,
                     X_supply_number varchar2,
                     X_shipment_num number default null,
                     p_estimated_pickup_date DATE DEFAULT NULL, -- <APS FPJ>
                     p_ship_method VARCHAR2 DEFAULT NULL -- <APS FPJ>
)  return boolean; --2279541

-- bug 5255550 : Reschedule API rewrite
Function RESCHEDULE ( X_need_by_dates_old 	   po_tbl_date,
	              X_need_by_dates 	 	   po_tbl_date,
	              X_po_header_id	  	   number,
                      X_po_line_ids 		   po_tbl_number,
                      X_supply_number 	 	   varchar2,
                      X_shipment_nums 	 	   po_tbl_number Default NULL,
                      p_estimated_pickup_dates     po_tbl_date Default NULL,
                      p_ship_methods		   po_tbl_varchar30 Default NULL
) Return BOOLEAN;

--Bug 9372785<START> , error message required.
--Adding new parameter X_error_message
 	 Function RESCHEDULE ( X_need_by_dates_old          po_tbl_date,
 	                       X_need_by_dates                     po_tbl_date,
 	                       X_po_header_id                     number,
 	                       X_po_line_ids                po_tbl_number,
 	                       X_supply_number               varchar2,
 	                       X_shipment_nums               po_tbl_number Default NULL,
 	                       p_estimated_pickup_dates     po_tbl_date Default NULL,
 	                       p_ship_methods               po_tbl_varchar30 Default NULL,
 	                       X_error_message     OUT NOCOPY     po_tbl_varchar2000
 	 ) Return BOOLEAN;

--Bug 9372785<END>

END PO_RESCHEDULE_PKG;



/
