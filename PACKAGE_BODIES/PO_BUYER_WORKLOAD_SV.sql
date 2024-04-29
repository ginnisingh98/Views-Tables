--------------------------------------------------------
--  DDL for Package Body PO_BUYER_WORKLOAD_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_BUYER_WORKLOAD_SV" AS
/* $Header: POXBWMWB.pls 120.2.12010000.2 2010/12/02 04:59:40 lswamina ship $*/

G_PKG_NAME CONSTANT varchar2(30) := 'po_buyer_workload_sv';

/*===========================================================================

  PROCEDURE NAME:       get_num_unassigned

===========================================================================*/

PROCEDURE get_num_unassigned (x_needby_date_low		IN	DATE,
			x_needby_date_high		IN	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_unassigned_reqs		IN OUT	NOCOPY NUMBER,
			x_unassigned_urgent		IN OUT	NOCOPY NUMBER,
			x_unassigned_late		IN OUT	NOCOPY NUMBER,
			x_unassigned_needed		IN OUT	NOCOPY NUMBER)
IS
	x_progress	VARCHAR2(3);
BEGIN

	x_progress	:= '010';
    -- Determine the number of unassigned requisitions
    -- that meet the criteria specified.  Alse determine the number that
    -- are late, urgent and needed within the range of need by dates.

    SELECT count(*),
           sum( decode( nvl(PORL.urgent, 'N'), 'Y', 1, 0 ) ),
           sum( decode( PORL.need_by_date,
          		NULL, 0,
			decode(sign(SYSDATE-(PORL.need_by_date-
			nvl(MSI.full_lead_time,0))),-1, 0, 1))),
           sum( decode( x_needby_date_low,
                        NULL, decode(x_needby_date_high, NULL, NULL,
				     decode (PORL.need_by_date, NULL, 0,
					     decode (sign(x_needby_date_high -
                                                                    --< NBD TZ/Timestamp Start >
                                                                    --TRUNC(PORL.need_by_date)
                                                                    PORL.need_by_date
                                                                    --< NBD TZ/Timestamp End >
                                                                 ),-1, 0, 1))),
                        decode (x_needby_date_high, NULL, decode (PORL.need_by_date, NULL, 0,
								  decode (sign(
                                                                                   --< NBD TZ/Timestamp Start >
                                                                                   --TRUNC(PORL.need_by_date)
                                                                                   PORL.need_by_date
                                                                                   --< NBD TZ/Timestamp End >
                                                                                   - x_needby_date_low), -1, 0, 1)),
			        decode (PORL.need_by_date, NULL, 0,
			                decode (sign(
                                                           --< NBD TZ/Timestamp Start >
                                                           --TRUNC(PORL.need_by_date)
                                                           PORL.need_by_date
                                                           --< NBD TZ/Timestamp End >
                                                            - x_needby_date_low), -1, 0,
					        decode (sign(x_needby_date_high -
                                                                       --< NBD TZ/Timestamp Start >
                                                                       --TRUNC(PORL.need_by_date)
                                                                       PORL.need_by_date
                                                                       --< NBD TZ/Timestamp End >
                                                                  ), -1, 0, 1))))))
   INTO    x_unassigned_reqs,
     	   x_unassigned_urgent,
	   x_unassigned_late,
   	   x_unassigned_needed
   FROM    po_requisition_lines_v PORL,
	   mtl_system_items MSI,
	   financials_system_parameters FSP,
	   gl_sets_of_books	GSB
   WHERE   PORL.suggested_buyer_id is NULL
   AND     NVL(PORL.LINE_LOCATION_ID, -999) = -999
--   AND 	   PORL.line_location_id IS NULL
   AND     nvl(PORL.cancel_flag,'N')='N'
   AND     nvl(PORL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND     MSI.inventory_item_id(+) = PORL.item_id
   AND     NVL(MSI.organization_id, FSP.inventory_organization_id) =
		FSP.inventory_organization_id
   AND	   FSP.set_of_books_id = GSB.set_of_books_id
   AND     PORL.source_type_code = 'VENDOR'
   AND     nvl(PORL.modified_by_agent_flag,'N')='N'
   AND     (x_suggested_vendor IS NULL
        OR PORL.suggested_vendor_name = x_suggested_vendor)
   AND	   (x_vendor_site IS NULL
	OR PORL.suggested_vendor_location = x_vendor_site)
   AND     (x_location_id IS NULL
        OR x_location_id = PORL.deliver_to_location_id) /* bug 1623527*/
   AND     (x_item_id IS NULL
        OR PORL.item_id = x_item_id)
   AND     (x_item_revision IS NULL
        OR PORL.item_revision = x_item_revision)
   AND 	   (x_item_description IS NULL
	OR item_description LIKE x_item_description)
   AND     (x_category_id IS NULL
        OR PORL.category_id = x_category_id)
   AND     (x_line_type_id IS NULL
        OR PORL.line_type_id = x_line_type_id)
   AND     (x_approval_status_list IS NULL
   	OR x_approval_status_list = 'ALL'  /*Bug 5717983 This is to consider the 'All Statuses' option.*/
        OR x_approval_status_list =
		  (SELECT authorization_status
                     FROM PO_REQUISITION_HEADERS PORH
                    WHERE PORH.requisition_header_id =
                          PORL.requisition_header_id))
   AND     (x_requisition_header_id IS NULL
        OR PORL.requisition_header_id = x_requisition_header_id)
   AND     (x_to_person_id IS NULL
        OR PORL.to_person_id = x_to_person_id)
   AND     (x_rate_type IS NULL
        OR PORL.rate_type = x_rate_type)
   AND     (x_currency_code IS NULL
        OR nvl(PORL.currency_code, GSB.currency_code) = x_currency_code)
   AND     (x_rfq_required_list = nvl(PORL.rfq_required_flag, 'N')
   	OR x_rfq_required_list IS NULL)
   AND     (x_urgent_list = nvl(PORL.urgent, 'N')
	OR x_urgent_list IS NULL)
   AND     ((x_sourced_list = 'UNSOURCED'
		AND PORL.suggested_vendor_name is NULL)
        OR (x_sourced_list = 'SOURCED'
		AND PORL.suggested_vendor_name IS NOT NULL)
	OR x_sourced_list IS NULL)
   AND     ((x_late_list = 'N' AND
		(decode(PORL.need_by_date, NULL, sysdate+1,
		PORL.need_by_date - nvl(MSI.full_lead_time,0))
		> sysdate))
	OR (x_late_list = 'Y' AND (sysdate > decode (PORL.need_by_date,
		NULL, sysdate+1, PORL.need_by_date
		- nvl(MSI.full_lead_time,0))))
	OR x_late_list IS NULL);

  -- IF the number of unassigned reqs is 0, then the number urgent,
  -- nunber late and number needed are all 0.

  IF (x_unassigned_reqs = 0) THEN

       -- If the number of unassigned reqs is 0, then the number urgent and
       -- number late are also 0.

       x_unassigned_urgent := 0;
       x_unassigned_late := 0;

       IF (x_needby_date_high IS NOT NULL OR x_needby_date_low IS NOT NULL) THEN

          x_unassigned_needed := 0;

       END IF;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    --    dbms_output.put_line('In Exception');
        PO_MESSAGE_S.SQL_ERROR('PO_BUYER_WORKLOAD_SV.GET_NUM_UNASSIGNED', x_progress, sqlcode);
        RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       get_num_assigned

===========================================================================*/

PROCEDURE get_num_assigned (x_buyer_id			IN	NUMBER,
			x_needby_date_low		IN	DATE,
			x_needby_date_high		IN      DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_num_reqs			IN OUT	NOCOPY NUMBER,
			x_num_urgent			IN OUT	NOCOPY NUMBER,
			x_num_late			IN OUT	NOCOPY NUMBER,
			x_num_needed			IN OUT	NOCOPY NUMBER)
IS
	x_progress	VARCHAR2(3);
BEGIN
    -- Determine the number of requistions assigned to the buyer
    -- that meet the criteria specified.  Alse determine the number that
    -- are late, urgent and needed within the range of need by dates.

    x_progress := '010';
    SELECT count(*),
           sum( decode( nvl(PORL.urgent, 'N'), 'Y', 1, 0 ) ),
           sum( decode( PORL.need_by_date,
                    NULL, 0,
			decode(sign(SYSDATE-(PORL.need_by_date-
			nvl(MSI.full_lead_time,0))),-1, 0, 1))),
          sum( decode( x_needby_date_low,
                        NULL, decode(x_needby_date_high, NULL, NULL,
				     decode (PORL.need_by_date, NULL, 0,
					     decode (sign(x_needby_date_high -
                                                                    --< NBD TZ/Timestamp Start >
                                                                    --TRUNC(PORL.need_by_date)
                                                                    PORL.need_by_date
                                                                    --< NBD TZ/Timestamp End >
                                                                 ),-1, 0, 1))),
                        decode (x_needby_date_high, NULL, decode (PORL.need_by_date, NULL, 0,
								  decode (sign(
                                                                                               --< NBD TZ/Timestamp Start >
                                                                                               --TRUNC(PORL.need_by_date)
                                                                                               PORL.need_by_date
                                                                                               --< NBD TZ/Timestamp End >
                                                                                               - x_needby_date_low), -1, 0, 1)),
			        decode (PORL.need_by_date, NULL, 0,
			                decode (sign(
                                                           --< NBD TZ/Timestamp Start >
                                                           --TRUNC(PORL.need_by_date)
                                                           PORL.need_by_date
                                                           --< NBD TZ/Timestamp End >
                                                           - x_needby_date_low), -1, 0,
					        decode (sign(x_needby_date_high -
                                                                       --< NBD TZ/Timestamp Start >
                                                                       --TRUNC(PORL.need_by_date)
                                                                       PORL.need_by_date
                                                                       --< NBD TZ/Timestamp End >
                                                                  ), -1, 0, 1))))))
   INTO    x_num_reqs,
     	   x_num_urgent,
	   x_num_late,
   	   x_num_needed
   FROM    po_requisition_lines_v PORL,
	   mtl_system_items MSI,
	   financials_system_parameters FSP,
	   gl_sets_of_books	GSB
   WHERE   PORL.suggested_buyer_id = x_buyer_id
   AND     NVL(PORL.LINE_LOCATION_ID, -999) = -999
-- AND 	   PORL.line_location_id IS NULL
   AND     nvl(PORL.cancel_flag,'N')='N'
   AND     nvl(PORL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND     MSI.inventory_item_id(+) = PORL.item_id
   AND     NVL(MSI.organization_id, FSP.inventory_organization_id) =
		FSP.inventory_organization_id
   AND	   FSP.set_of_books_id = GSB.set_of_books_id
   AND     PORL.source_type_code = 'VENDOR'
   AND     nvl(PORL.modified_by_agent_flag,'N')='N'
   AND     (x_suggested_vendor IS NULL
        OR PORL.suggested_vendor_name = x_suggested_vendor)
   AND	   (x_vendor_site IS NULL
	OR PORL.suggested_vendor_location = x_vendor_site)
   AND     (x_location_id IS NULL
        OR x_location_id = PORL.deliver_to_location_id) /*bug 1623527*/
   AND     (x_item_id IS NULL
        OR PORL.item_id = x_item_id)
   AND     (x_item_revision IS NULL
        OR PORL.item_revision = x_item_revision)
   AND 	   (x_item_description IS NULL
	OR item_description LIKE x_item_description)
   AND     (x_category_id IS NULL
        OR PORL.category_id = x_category_id)
   AND     (x_line_type_id IS NULL
        OR PORL.line_type_id = x_line_type_id)
   AND     (x_approval_status_list IS NULL
	OR x_approval_status_list = 'ALL'  /*Bug 5717983 This is to consider the 'All Statuses' option.*/
        OR x_approval_status_list =
		  (SELECT authorization_status
                     FROM PO_REQUISITION_HEADERS PORH
                    WHERE PORH.requisition_header_id =
                          PORL.requisition_header_id))
   AND     (x_requisition_header_id IS NULL
        OR PORL.requisition_header_id = x_requisition_header_id)
   AND     (x_to_person_id IS NULL
        OR PORL.to_person_id = x_to_person_id)
   AND     (x_rate_type IS NULL
        OR PORL.rate_type = x_rate_type)
   AND     (x_currency_code IS NULL
        OR nvl(PORL.currency_code, GSB.currency_code) = x_currency_code)
   AND     (x_rfq_required_list = nvl(PORL.rfq_required_flag, 'N')
	OR x_rfq_required_list IS NULL)
   AND     (x_urgent_list = nvl(PORL.urgent, 'N')
	OR x_urgent_list IS NULL)
   AND     ((x_sourced_list = 'UNSOURCED'
		AND PORL.suggested_vendor_name is NULL)
        OR (x_sourced_list = 'SOURCED'
		AND PORL.suggested_vendor_name IS NOT NULL)
	OR x_sourced_list IS NULL)
   AND     ((x_late_list = 'N' AND
		(decode(PORL.need_by_date, NULL, sysdate+1,
		PORL.need_by_date - nvl(MSI.full_lead_time,0))
		> sysdate))
	OR (x_late_list = 'Y' AND (sysdate > decode (PORL.need_by_date,
		NULL, sysdate+1, PORL.need_by_date -
		nvl(MSI.full_lead_time,0))))
	OR x_late_list IS NULL);

   -- If the number of assigned reqs is 0, then the number urgent,
   -- late, and needed are also 0.

   x_progress := '020';
   IF x_num_reqs = 0 THEN

       x_num_urgent:=0;
       x_num_late:=0;

       IF (x_needby_date_low IS NOT NULL OR x_needby_date_high IS NOT NULL) THEN
		x_num_needed := 0;
       END IF;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    --    dbms_output.put_line('In Exception');
        PO_MESSAGE_S.SQL_ERROR('PO_BUYER_WORKLOAD_SV.GET_NUM_ASSIGNED', x_progress, sqlcode);
        RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       update_buyer_by_rowid

===========================================================================*/

PROCEDURE update_buyer_by_rowid(x_new_buyer_id  IN NUMBER,
				x_rowid	 	IN VARCHAR2,
				x_user_id	IN NUMBER,
				x_login_id 	IN NUMBER) IS
	x_progress	VARCHAR2(3);
BEGIN

    IF x_rowid IS NOT NULL THEN

   	x_progress := '010';
   --	dbms_output.put_line('Before update');

   	UPDATE  po_requisition_lines_all  --<R12 MOAC>
   	SET	suggested_buyer_id = x_new_buyer_id,
	   	last_update_date = sysdate,
	   	last_updated_by = x_user_id,
	   	last_update_login = x_login_id
   	WHERE   rowid = x_rowid;

   	x_progress := '020';
   --	dbms_output.put_line('After update');

    END IF;

EXCEPTION
    WHEN OTHERS THEN
    --    dbms_output.put_line('Exception in update_buyer_by_rowid');
        PO_MESSAGE_S.SQL_ERROR('PO_BUYER_WORKLOAD_SV2.UPDATE_BUYER_BY_ROWID',
	    x_progress, sqlcode);
        RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       update_buyers

===========================================================================*/

PROCEDURE update_buyers(
			x_new_buyer_id			IN	NUMBER,
			x_old_buyer_id			IN	NUMBER,
			x_needby_date_low		IN	DATE,
			x_needby_date_high		IN	DATE,
			x_suggested_vendor		IN	VARCHAR2,
			x_vendor_site			IN	VARCHAR2,
			x_location_id			IN	NUMBER,
			x_item_id			IN	NUMBER,
			x_item_revision			IN	VARCHAR2,
			x_item_description		IN	VARCHAR2,
			x_category_id			IN	NUMBER,
			x_line_type_id			IN	NUMBER,
			x_approval_status_list		IN	VARCHAR2,
			x_requisition_header_id		IN	NUMBER,
			x_to_person_id			IN	NUMBER,
			x_rate_type			IN	VARCHAR2,
			x_currency_code			IN	VARCHAR2,
			x_assigned_list			IN	VARCHAR2,
			x_rfq_required_list		IN	VARCHAR2,
			x_urgent_list			IN	VARCHAR2,
			x_sourced_list			IN	VARCHAR2,
			x_late_list			IN 	VARCHAR2,
			x_user_id			IN	NUMBER,
			x_login_id			IN 	NUMBER)
IS
	x_progress	VARCHAR2(3);
	x_rowid 	ROWID;
	x_inventory_organization_id NUMBER;
        x_sob_currency_code NUMBER;

        /* Bug 2496101. Removed financial_system_parameters and gl_sets_of_books
         * that used to be in the FROM clause in the select query below.
         * This was done due to performance problem with the cartesian
         * joins. We used to get the inventory_organization_id and
         * currency_code from these table. Now we get them in a separate
         * sql query and use it in the cursor.
        */
	CURSOR C(x_inventory_organization_id number,x_sob_currency_code number) is
	SELECT PORL.rowid
   FROM    po_requisition_lines PORL,
	   mtl_system_items MSI
   WHERE
   NVL(PORL.LINE_LOCATION_ID, -999) = -999
-- PORL.line_location_id IS NULL
   AND     PORL.source_type_code = 'VENDOR'
   AND     nvl(PORL.cancel_flag,'N')='N'
   AND     nvl(PORL.modified_by_agent_flag,'N')='N'
   AND     nvl(PORL.closed_code,'OPEN') <> 'FINALLY CLOSED'
   AND     MSI.inventory_item_id(+) = PORL.item_id
   AND     NVL(MSI.organization_id, x_inventory_organization_id)
					= x_inventory_organization_id
   AND     (x_needby_date_low IS NULL
        OR PORL.need_by_date >= x_needby_date_low)
   AND     (x_needby_date_high IS NULL
        OR PORL.need_by_date <= x_needby_date_high)
   AND	   (x_old_buyer_id IS NULL
	OR PORL.suggested_buyer_id = x_old_buyer_id)
   AND     (x_suggested_vendor IS NULL
        OR PORL.suggested_vendor_name = x_suggested_vendor)
   AND	   (x_vendor_site IS NULL
	OR PORL.suggested_vendor_location = x_vendor_site)
   AND     (x_location_id IS NULL
        OR x_location_id = PORL.deliver_to_location_id) /* bug 1623527*/
   AND     (x_item_id IS NULL
        OR PORL.item_id = x_item_id)
   AND     (x_item_revision IS NULL
        OR PORL.item_revision = x_item_revision)
   AND     (x_item_description IS NULL
        OR PORL.item_description LIKE x_item_description)
   AND     (x_category_id IS NULL
        OR PORL.category_id = x_category_id)
   AND     (x_line_type_id IS NULL
        OR PORL.line_type_id = x_line_type_id)
   AND     (x_rfq_required_list = nvl(PORL.rfq_required_flag, 'N')
	OR x_rfq_required_list IS NULL)
   AND     (x_urgent_list = nvl(PORL.urgent_flag, 'N')
	OR x_urgent_list IS NULL)
   AND     (x_approval_status_list IS NULL
      	OR x_approval_status_list = 'ALL'  /*Bug 5717983 This is to consider the 'All Statuses' option.*/
        OR x_approval_status_list =
		  (SELECT authorization_status
                     FROM PO_REQUISITION_HEADERS PORH
                    WHERE PORH.requisition_header_id =
                          PORL.requisition_header_id))
   AND     (x_requisition_header_id IS NULL
        OR PORL.requisition_header_id = x_requisition_header_id)
   AND     (x_to_person_id IS NULL
        OR PORL.to_person_id = x_to_person_id)
   AND     (x_rate_type IS NULL
        OR PORL.rate_type = x_rate_type)
   AND     (x_currency_code IS NULL
        OR nvl(PORL.currency_code, x_sob_currency_code) = x_currency_code)
   AND     ((x_assigned_list = 'Y'
		AND PORL.suggested_buyer_id is NOT NULL)
        OR (x_assigned_list = 'N'
		AND PORL.suggested_buyer_id IS NULL)
	OR x_assigned_list IS NULL)
   AND     ((x_sourced_list = 'UNSOURCED'
		AND PORL.suggested_vendor_name is NULL)
        OR (x_sourced_list = 'SOURCED'
		AND PORL.suggested_vendor_name IS NOT NULL)
	OR x_sourced_list IS NULL)
   AND     ((x_late_list = 'N' AND
		(decode(PORL.need_by_date, NULL, sysdate+1,
		PORL.need_by_date - nvl(MSI.full_lead_time,0))
		> sysdate))
	OR (x_late_list = 'Y' AND (sysdate > decode (PORL.need_by_date,
		NULL, sysdate+1, PORL.need_by_date -
		nvl(MSI.full_lead_time,0))))
	OR x_late_list IS NULL);
BEGIN
   x_progress := '010';
  -- dbms_output.put_line('Before update');
     /* Bug 2496101.Get the inventory_org and currency_code separately and
      * use it in the cursor.This is done due to performance problems
      * with the cartesian join between the tables.
     */
     SELECT fsp.inventory_organization_id,sob.currency_code
     INTO x_inventory_organization_id, x_sob_currency_code
     FROM  gl_sets_of_books sob,
     financials_system_parameters fsp
     WHERE fsp.set_of_books_id = sob.set_of_books_id;

   OPEN C(x_inventory_organization_id,x_sob_currency_code);
   LOOP
       x_progress := '020';
       FETCH C into x_rowid;
       EXIT WHEN C%NOTFOUND;

       UPDATE  po_requisition_lines PRL
       SET     PRL.suggested_buyer_id = x_new_buyer_id,
	       PRL.last_update_date = sysdate,
	       PRL.last_updated_by = x_user_id,
	       PRL.last_update_login = x_login_id
       WHERE   PRL.rowid = x_rowid;

   END LOOP;
   CLOSE C;

EXCEPTION
    WHEN OTHERS THEN
    --    dbms_output.put_line('Exception in update_buyers');
        PO_MESSAGE_S.SQL_ERROR('PO_BUYER_WORKLOAD_SV2.UPDATE_BUYERS',
	    x_progress, sqlcode);
        RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       num_open_po

===========================================================================*/

FUNCTION num_open_po (x_agent_id  IN NUMBER) return NUMBER IS
	x_progress	VARCHAR2(3);
	x_count	   	NUMBER;
BEGIN
    IF x_agent_id IS NOT NULL THEN

   	x_progress := '010';
  -- 	dbms_output.put_line('Before select');

   	SELECT  count(*)
	INTO	x_count
	FROM	po_headers POH
	WHERE   POH.agent_id = x_agent_id
        AND     type_lookup_code not in ('RFQ', 'QUOTATION')
	AND     nvl(POH.cancel_flag,'N') = 'N'
	AND     nvl(POH.closed_code, 'OPEN') not in
		('CLOSED','FINALLY CLOSED');

   	x_progress := '020';
   --	dbms_output.put_line('After select');

	return (x_count);

    ELSE

	return (-1);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
    --    dbms_output.put_line('Exception in num_open_po');
        RAISE;
END;
--<ACHTML R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: req_reassign_action_bulk
--Pre-reqs:
-- None.
--Modifies:
--  po_requisition_lines_all.
--Locks:
--  None.
--Function:
-- It takes in an array of all the req_line_ids
-- and performs a Bulk Update on po_requisition_lines_all
-- with the new buyer_id. And commits the transaction
--Parameters:
--IN:
-- p_api_version
--  version of the API
-- p_employee_id
--  The employee_id is required for updating who columns
-- p_req_line_id_tbl
--  The pl/sql table containing the req_line_ids .
-- p_new_buyer_id
--  The employee_id of the new buyer
-- OUT
-- x_return_status
--  Indicates whether the procedure was successfully executed or not
-- x_error_message
--  Variable which will hold the message in case of error
--Testing:
-- Refer the Technical Design for 'HTML Autocreate R12(IDC)'
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE req_reassign_action_bulk(p_api_version     IN NUMBER,
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_error_message   OUT NOCOPY VARCHAR2,
                                   p_employee_id     IN NUMBER,
                                   p_req_line_id_tbl IN PO_TBL_NUMBER,
                                   p_new_buyer_id    IN NUMBER)
IS
  l_api_version CONSTANT NUMBER := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'req_reassign_action_bulk';
  l_progress VARCHAR2(3);
BEGIN
    l_progress := '000';
    -- Standard Call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME)
    THEN
      x_error_message := 'API version check raised exception';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '005';
    x_return_status := FND_API.g_ret_sts_success;

    --bug10315814 last_updated_by should be the user_id of the current user and not
    --the employee_id of the new buyer

    -- update all the records with the new buyer_id
    forall i in p_req_line_id_tbl.FIRST..p_req_line_id_tbl.LAST
      UPDATE  po_requisition_lines_all
      SET suggested_buyer_id = p_new_buyer_id,
          last_update_date   = sysdate,
          last_updated_by    = fnd_global.user_id, --bug10315814
          last_update_login  = fnd_global.login_id
      WHERE requisition_line_id = p_req_line_id_tbl(i);

    l_progress := '010';
    -- If the records were successfully updated, Commit the Transaction
    commit;

EXCEPTION
    WHEN FND_API. G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF(x_error_message is NULL) then
         x_error_message := 'Unexpected Error Occured at:' ||
                             l_progress || ' in req_reassign_action_bulk';
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF(x_error_message is NULL) then
         x_error_message := 'In Others, Exception at:' ||
                             l_progress || ' in req_reassign_action_bulk';
      END IF;
END req_reassign_action_bulk;
--<ACHTML R12 End>
END;

/
