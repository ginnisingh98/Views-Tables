--------------------------------------------------------
--  DDL for Package Body OEXPURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXPURGE" AS
/* $Header: OEXPURGB.pls 115.6 99/07/16 08:15:25 porting ship  $ */

PROCEDURE select_purge_orders
	(dummy_1             VARCHAR2,
	 dummy_2             VARCHAR2,
	 p_low_order_number  NUMBER,
	 p_high_order_number NUMBER,
         p_low_cdate         DATE,
         p_high_cdate        DATE,
         p_low_ddate         DATE,
         p_high_ddate        DATE,
         p_order_category    VARCHAR2,
         p_order_type_id     NUMBER,
         p_customer_id       NUMBER)
IS

a_id NUMBER := 0;
a_number NUMBER := 0;
a_name  VARCHAR2(30);
return_status NUMBER := 0;
v_error_message VARCHAR2(2000);

CURSOR acursor IS
	SELECT so.header_id
	,      so.order_number
	,      sot.name
	FROM   so_order_types sot,
	       so_headers     so
	WHERE  so.order_number  BETWEEN NVL(p_low_order_number,so.order_number)
				AND NVL( p_high_order_number, so.order_number )
--	The time component in Order Date and Creation Date has been stripped off
-- 	before making comparision. Bug# 916858 - propagated from Rel. 11
--	( Bug# 914321 ).
	AND    TRUNC(so.creation_date) BETWEEN
				NVL( TRUNC(p_low_cdate),  TRUNC(so.creation_date) )
			AND 	NVL( TRUNC(p_high_cdate), TRUNC(so.creation_date) )
	AND    TRUNC(so.date_ordered)  BETWEEN
				NVL( TRUNC(p_low_ddate),  TRUNC(so.date_ordered) )
			AND 	NVL( TRUNC(p_high_ddate), TRUNC(so.date_ordered) )
	AND    so.order_category = NVL( p_order_category, so.order_category )
	AND    so.order_type_id  = NVL( p_order_type_id,  so.order_type_id )
	AND    so.customer_id    = NVL( p_customer_id,    so.customer_id )
	AND    sot.order_type_id = so.order_type_id
	AND    so.open_flag is null;

BEGIN

	DELETE FROM SO_PURGE_ORDERS
	WHERE REQUEST_ID IS NULL;

/*  commit; */

	OPEN ACURSOR;
	LOOP
	    FETCH ACURSOR INTO a_id, a_number, a_name;
	    EXIT WHEN ACURSOR%NOTFOUND OR ACURSOR%NOTFOUND IS NULL;

            return_status := 0;

	    IF return_status = 0 THEN
	        v_error_message := 'Open demand exists for order number: ';
	        return_status := OEXPURGE.so_check_open_demand_orders
                               ( TO_CHAR(a_number), a_name );
	    END IF;

	    IF return_status = 0 THEN
	        v_error_message:='Open orders exist in WIP for order number: ';
	        return_status := OEXPURGE.so_check_open_orders
                                 ( TO_CHAR(a_number), a_name );
	    END IF;

	    IF return_status = 0 THEN
	        v_error_message := 'Open invoices exist for order number: ';
	        return_status := OEXPURGE.so_check_open_invoiced_orders
                                   ( TO_CHAR(a_number), a_name );
	    END IF;

	    IF return_status = 0 THEN
	        v_error_message := 'Open returns exist for order number: ';
	        return_status := OEXPURGE.so_check_open_returns(a_number,
								a_name);
	    END IF;

	    IF return_status = 0 THEN

	        INSERT INTO SO_PURGE_ORDERS
		    (HEADER_ID,
		    CREATION_DATE,
		    CREATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATED_BY,
		    LAST_UPDATE_LOGIN,
		    REQUEST_ID,
		    PROGRAM_ID,
		    PROGRAM_APPLICATION_ID)
	        VALUES (a_id,
		    sysdate,
		    -1,
		    sysdate,
		    -1,
		    NULL,
		    NULL,
		    0,
		    300);

	    END IF;

	    IF return_status > 0 THEN
	        v_error_message := v_error_message || TO_CHAR(a_number);
	    ELSE
	        IF return_status < 0 THEN
                null;
	        END IF;
	    END IF;

	END LOOP;
	CLOSE ACURSOR;

	COMMIT;

	IF a_id = 0 THEN
	    v_error_message := 'No Open Orders To Purge';
	    -- dbms_output.put_line(v_error_message);
	END IF;

END select_purge_orders;

FUNCTION so_check_open_demand_orders
           ( p_order_number     VARCHAR2,
             p_order_type_name  VARCHAR2 )  RETURN NUMBER IS

CURSOR SO_PROBLEM_CHECK IS
	SELECT 'Open demand for this sales order'
	FROM   mtl_sales_orders  mso,
	       mtl_demand        md
	WHERE  mso.segment1 = p_order_number
	AND    mso.segment2 = p_order_type_name
	AND    mso.sales_order_id = md.demand_source_header_id
	AND    md.demand_source_type IN (2,8)
	AND    md.primary_uom_quantity > NVL( md.completed_quantity, 0 )
	AND    md.row_status_flag = 1;

	x_fetch_value	varchar2(80);
	x_records_exists	boolean;

BEGIN
	OPEN SO_PROBLEM_CHECK;
	FETCH SO_PROBLEM_CHECK INTO x_fetch_value;
	x_records_exists := SO_PROBLEM_CHECK%FOUND;
	CLOSE SO_PROBLEM_CHECK;

	if (not x_records_exists) then
		return (0);
	end if;

	return (1);

EXCEPTION
	WHEN  OTHERS  THEN  RETURN (-1);
END so_check_open_demand_orders;


FUNCTION so_check_open_invoiced_orders
        ( p_order_number     VARCHAR2,
          p_order_type_name  VARCHAR2 )  RETURN NUMBER IS

CURSOR SO_PROBLEM_CHECK IS
	SELECT 'Open invoices for this sales order'
	FROM   ra_customer_trx_lines rctl,
	       ra_customer_trx       rct
	WHERE  rctl.interface_line_attribute1 = p_order_number
	AND    rctl.interface_line_attribute2 = p_order_type_name
	AND    rctl.customer_trx_id = rct.customer_trx_id
	AND    rct.complete_flag    = 'N';

	x_fetch_value     varchar2(80);
	x_records_exists  boolean;
BEGIN

	OPEN SO_PROBLEM_CHECK;
	FETCH SO_PROBLEM_CHECK INTO x_fetch_value;
	x_records_exists := SO_PROBLEM_CHECK%FOUND;
	CLOSE SO_PROBLEM_CHECK;

	if (not x_records_exists) then
	    return (0);
	end if;

	return (1);

EXCEPTION
	WHEN  OTHERS  THEN  RETURN (-1);
END so_check_open_invoiced_orders;


FUNCTION so_check_open_orders
        ( p_order_number     VARCHAR2,
          p_order_type_name  VARCHAR2 )  RETURN NUMBER IS

CURSOR SO_PROBLEM_CHECK IS
	SELECT 'Open work orders for this sales order'
	FROM   mtl_sales_orders   mso,
	       wip_so_allocations wsa,
	       wip_discrete_jobs  wdj
	WHERE  mso.segment1 = p_order_number
	AND    mso.segment2 = p_order_type_name
	AND    mso.sales_order_id = wsa.demand_source_header_id
	AND    wsa.wip_entity_id  = wdj.wip_entity_id
	AND    wdj.date_closed IS NULL
	AND    wdj.status_type = 1;

	x_fetch_value     varchar2(80);
	x_records_exists  boolean;
BEGIN
	OPEN SO_PROBLEM_CHECK;
	FETCH SO_PROBLEM_CHECK INTO x_fetch_value;
	x_records_exists := SO_PROBLEM_CHECK%FOUND;
	CLOSE SO_PROBLEM_CHECK;

	if (not x_records_exists) then
	    return (0);
	end if;

	return (1);

EXCEPTION
	WHEN  OTHERS  THEN  RETURN (-1);
END so_check_open_orders;


FUNCTION so_check_open_returns( p_order_number  NUMBER,
				p_order_type_name VARCHAR2 )  RETURN NUMBER IS

CURSOR SO_PROBLEM_CHECK IS
	SELECT 'Open return for this sales order'
	FROM   so_lines    sl1,
	       so_lines    sl2,
	       so_headers  sh,
	       so_order_types ot
	WHERE  sh.order_number = p_order_number
	AND    sh.order_type_id = ot.order_type_id
	AND    ot.name = p_order_type_name
	AND    sl1.header_id    = sh.header_id
	AND    sl2.return_reference_id = sl1.line_id
	AND    sl2.line_type_code = 'RETURN'
	AND    sl2.return_reference_type_code IN ( 'ORDER', 'PO' )
	AND    nvl(sl2.open_flag, 'N') = 'Y';

	x_fetch_value     varchar2(80);
	x_records_exists  boolean;
BEGIN
	OPEN SO_PROBLEM_CHECK;
	FETCH SO_PROBLEM_CHECK INTO x_fetch_value;
	x_records_exists := SO_PROBLEM_CHECK%FOUND;
	CLOSE SO_PROBLEM_CHECK;

	if (not x_records_exists) then
	    return (0);
	end if;

	return (1);

EXCEPTION
	WHEN  OTHERS  THEN  RETURN (-1);
END so_check_open_returns;



PROCEDURE so_order_purge
		( p_dummy_1      VARCHAR2,
		  p_dummy_2	 VARCHAR2,
		  p_commit_point NUMBER )

/*=========================================================================*
 |                                                                         |
 | NAME                                                                    |
 |   so_order_purge          purge process                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This procedure drives the order purge process.                        |
 |   It locks all of the records within is request_id to be                |
 |   purged.  For each order to be purged, it executes the various purge   |
 |   functions deleting all related sales order rows.  The purged orders   |
 |   are committed based on the commit_point parameter.                    |
 |                                                                         |
 |   If a database error is detected during the execution of any purge     |
 |   function, all uncommitted rows are rolled back and an error message   |
 |   is written to SO_EXCEPTIONS; using OEPUR as the context prefix.       |
 |                                                                         |
 | ARGUMENTS                                                               |
 |   Input: p_request_id    NUMBER  Identifies orders to be purged by this |
 |                                  sub-process.                           |
 |          p_commit_point  NUMBER  Identifies the number of orders to be  |
 |                                  purged prior to committing.            |
 |                                                                         |
 | HISTORY                                                                 |
 |   Date    Author   Comments                                             |
 | --------- -------- ---------------------------------------------------- |
 | 28-Feb-96 tgoldsmi Created                                              |
 *=========================================================================*/

IS

v_header_id   NUMBER := 0;
commit_ctr    NUMBER := 0;
return_status NUMBER := 0;
p_request_id  NUMBER := 0;

CURSOR purging IS SELECT header_id FROM so_purge_orders;

BEGIN

p_request_id := FND_GLOBAL.CONC_REQUEST_ID;

	OPEN purging;

	LOOP

	    FETCH purging INTO  v_header_id;

	    EXIT WHEN purging%NOTFOUND OR purging%NOTFOUND IS NULL;
	    -- end of fetch or empty cursor

        /*********************************************************************
         *  return_status                                                    *
         *         Success: Any positive value.  Processing continues..      *
         *                  0 = Success, rows deleted/purged                 *
         *                  100, 1403 are considered to be successful        *
         *         Failure: Any negative value.  Processing is rolled back.  *
         *                  Error has already been recorded in so_exceptions *
         *********************************************************************/

	    return_status := OEXPURGE.so_purge_headers( v_header_id,
							p_request_id);

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_line_approvals( v_header_id,
	                                                        p_request_id );
	    END IF;

            IF return_status > -1 THEN
                return_status := OEXPURGE.so_purge_backorder_cancelled(
                                                                v_header_id,
                                                                p_request_id );
            END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_lines( v_header_id,
	                                                  p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_note_references(v_header_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_order_approvals(v_header_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_order_cancellations(
								 v_header_id,
	                                                         p_request_id);
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_order_holds( v_header_id,
	                                                    p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_picking_headers(v_header_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_picking_rules( v_header_id,
	                                                      p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status:=OEXPURGE.so_purge_price_adjustments(v_header_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		return_status := OEXPURGE.so_purge_sales_credits( v_header_id,
	                                                      p_request_id );
	    END IF;

--	    dbms_output.put_line('before delete');

         IF return_status > -1 THEN                -- Success !
             DELETE FROM so_purge_orders    --    Delete the purge record
		   WHERE  header_id = v_header_id;

--		   dbms_output.put_line('after delete');

		   commit_ctr := commit_ctr + 1;
		   IF commit_ctr > p_commit_point THEN  -- Commit purged orders if
		       COMMIT;                          -- threshold is exceeded
		       commit_ctr := 0;
		   END IF;
         ELSE  commit_ctr := 0;            -- Failure, error has already
         END IF;                           --          been recorded

	END LOOP;

	CLOSE purging;

/*	IF commit_ctr > p_commit_point
	THEN  COMMIT;           --  Commit remaining purged orders
	ELSE  ROLLBACK;         --  Rollback to release any remaining resources
--	    dbms_output.put_line('rollback1');
	END IF;
*/
	COMMIT;
EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
         ROLLBACK;
--	    dbms_output.put_line('rollback 2');
         so_record_errors( return_status, p_request_id, v_header_id,
                           'OEPUR: SO_PURGE_ORDERS', NULL );
	    CLOSE purging;
END so_order_purge;



FUNCTION so_purge_freight_charges
		( p_picking_header_id  NUMBER,
		  p_request_id         NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT picking_header_id
	FROM   so_freight_charges
	WHERE  picking_header_id = p_picking_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM so_freight_charges       -- Delete all rows to be purged
	WHERE  picking_header_id = p_picking_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_picking_header_id,
                              'OEPUR: SO_FREIGHT_CHARGES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_freight_charges;


FUNCTION so_purge_headers
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER  := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock all rows to be purged
	FROM   so_headers
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM so_headers
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_HEADERS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_headers;


FUNCTION so_purge_hold_releases
           ( p_release_id  NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT hold_release_id      --  Lock rows to be purged
	FROM   so_hold_releases
	WHERE  hold_release_id = p_release_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM so_hold_releases
	WHERE  hold_release_id = p_release_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_release_id,
                              'OEPUR: SO_HOLD_RELEASES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_hold_releases;


FUNCTION so_purge_hold_sources
             ( p_source_id    NUMBER,
               p_request_id   NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT hold_source_id       --  Lock rows to be purged
	FROM   so_hold_sources
	WHERE  hold_source_id = p_source_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_hold_sources
	WHERE  hold_source_id = p_source_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_source_id,
                              'OEPUR: SO_HOLD_SOURCES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_hold_sources;


FUNCTION so_purge_line_approvals
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_line_approvals
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_line_approvals
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_LINE_APPROVALS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_line_approvals;


FUNCTION so_purge_line_details
            ( p_line_id     NUMBER,
              p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT line_id
	FROM   so_line_details
	WHERE  line_id = p_line_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_line_details
	WHERE  line_id = p_line_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_line_id,
                              'OEPUR: SO_LINE_DETAILS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
	    RETURN return_status;

END so_purge_line_details;


FUNCTION so_purge_line_service_details
          ( p_line_id     NUMBER,
            p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT line_id
	FROM   so_line_service_details
	WHERE  line_id = p_line_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;                   --  Lock all rows to be purged
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_line_service_details
	WHERE  line_id = p_line_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_line_id,
                              'OEPUR: SO_LINE_SERVICE_DETAILS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_line_service_details;


FUNCTION so_purge_lines
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;
v_line_id        NUMBER := 0;

CURSOR purge_lines IS
	SELECT DISTINCT line_id   -- Select the unique line_ids to be purged
	FROM   so_lines
	WHERE  header_id = p_header_id;
BEGIN
	OPEN purge_lines;

	LOOP
	    FETCH purge_lines INTO  v_line_id;

	    EXIT WHEN purge_lines%NOTFOUND           -- end of fetch
	           OR purge_lines%NOTFOUND IS NULL;  -- empty cursor

	    SELECT line_id
	    INTO   syntax_required
	    FROM   so_lines
	    WHERE  line_id = v_line_id
	    FOR UPDATE NOWAIT;

	    return_status := so_purge_line_details( v_line_id,
	                                            p_request_id );
	    IF return_status > -1 THEN
	        return_status := so_purge_line_service_details( v_line_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
	        return_status := so_purge_order_cancel_lines( v_line_id,
	                                                      p_request_id );
	    END IF;

	    /* bug 683844 -- clean mtl_so_rma_interface table */
            IF return_status > -1 THEN
	        return_status := so_purge_mtl_so_rma_interface( v_line_id,
	                                                        p_request_id );
	    END IF;

	    IF return_status > -1 THEN
	        DELETE FROM   so_lines
	        WHERE  line_id = v_line_id;
	    ELSE
	        EXIT;  -- abort additional processing
	    END IF;

	END LOOP;

	CLOSE purge_lines;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              v_line_id,
                              'OEPUR: SO_LINES',
                              NULL );
	    CLOSE purge_lines;
            RETURN return_status;

END so_purge_lines;


FUNCTION so_purge_note_references
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_note_references
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_note_references
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_NOTE_REFERENCES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_note_references;


FUNCTION so_purge_order_approvals
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_order_approvals
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_order_approvals
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_ORDER_APPROVALS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_order_approvals;


/*************************************************************
 * The lines are purged in this case because before 9.4.2 we *
 * used to leave the header_id null and only fill in the     *
 * line_id and the data was never changed during upgrade.    *
 *************************************************************/

FUNCTION so_purge_order_cancel_lines
           ( p_line_id     NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT line_id            --  Lock rows to be purged
	FROM   so_order_cancellations
	WHERE  line_id = p_line_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_order_cancellations
	WHERE  line_id = p_line_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_line_id,
                              'OEPUR: SO_ORDER_CANCELLATIONS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_order_cancel_lines;

/*************************************************************
 * The mtl_so_rma_interface needs to be cleaned when the     *
 * corresponding returns lines are purged for the following  *
 * reasons:                                                  *
 * 1. the reference to line_id becomes dangling pointer      *
 * 2. Inventory can't delete the item with error message:    *
 *    RMA's exist for this item in the interface table       *
 *    (MTL_SO_RMA_INTERFACE)                                 *
 *************************************************************/

FUNCTION so_purge_mtl_so_rma_interface
           ( p_line_id     NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
v_rma_interface_id   NUMBER := 0;

CURSOR purge_mtl_so_rma_interface IS
	SELECT rma_interface_id            --  Lock rows to be purged
	FROM   mtl_so_rma_interface
	WHERE  rma_line_id = p_line_id;
BEGIN
	OPEN purge_mtl_so_rma_interface;
        LOOP
            FETCH purge_mtl_so_rma_interface into v_rma_interface_id;
            EXIT WHEN purge_mtl_so_rma_interface%NOTFOUND           -- end of fetch
                 OR purge_mtl_so_rma_interface%NOTFOUND IS NULL;  -- empty cursor

            return_status := so_purge_mtl_so_rma_receipts( v_rma_interface_id,
							   p_request_id );
            IF return_status > -1 THEN
         	    DELETE FROM mtl_so_rma_interface
        	    WHERE  rma_interface_id = v_rma_interface_id;
            ELSE
		EXIT;
            END IF;

        END LOOP;
        CLOSE purge_mtl_so_rma_interface;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_line_id,
                              'OEPUR: MTL_SO_RMA_INTERFACE',
                              NULL );
	    CLOSE purge_mtl_so_rma_interface;
            RETURN return_status;

END so_purge_mtl_so_rma_interface;

/*************************************************************
 * The mtl_so_rma_receipts needs to be cleaned when the      *
 * corresponding rma_interface line is purged for the        *
 * following reasons:                                        *
 * 1. the reference to rma_interface_id becomes dangling     *
 * 2. when a return line is purged, corresponding interfaced *
 *    line needs to be purged because:                       *
 *    Inventory can't delete the item with error message:    *
 *    RMA's exist for this item in the interface table       *
 *    (MTL_SO_RMA_INTERFACE)                                 *
 *************************************************************/

FUNCTION so_purge_mtl_so_rma_receipts
           ( p_rma_interface_id     NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
v_rma_receipt_id   NUMBER := 0;

CURSOR purge_mtl_so_rma_receipts IS
	SELECT rma_receipt_id            --  Lock rows to be purged
	FROM   mtl_so_rma_receipts
	WHERE  rma_interface_id = p_rma_interface_id;
BEGIN
	OPEN purge_mtl_so_rma_receipts;
        LOOP
            FETCH purge_mtl_so_rma_receipts into v_rma_receipt_id;
            EXIT WHEN purge_mtl_so_rma_receipts%NOTFOUND           -- end of fetch
                 OR purge_mtl_so_rma_receipts%NOTFOUND IS NULL;  -- empty cursor

            DELETE FROM mtl_so_rma_receipts
        	WHERE  rma_receipt_id = v_rma_receipt_id;

        END LOOP;
        CLOSE purge_mtl_so_rma_receipts;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_rma_interface_id,
                              'OEPUR: MTL_SO_RMA_RECEIPTS',
                              NULL );
	    CLOSE purge_mtl_so_rma_receipts;
            RETURN return_status;

END so_purge_mtl_so_rma_receipts;

FUNCTION so_purge_order_cancellations
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_order_cancellations
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_order_cancellations
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_ORDER_CANCELLATIONS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_order_cancellations;

FUNCTION so_purge_order_holds
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status    NUMBER := 0;
syntax_required  NUMBER := 0;
v_release_id     NUMBER := 0;
v_source_id      NUMBER := 0;
v_order_hold_id  NUMBER := 0;

CURSOR purge_holds IS
	SELECT DISTINCT NVL( hold_release_id, 0 ),
               NVL( hold_source_id,  0 ),
	       order_hold_id
	FROM   so_order_holds
	WHERE  header_id = p_header_id;
BEGIN
	OPEN purge_holds;

	LOOP
	    FETCH purge_holds INTO  v_release_id, v_source_id, v_order_hold_id;

	    EXIT WHEN purge_holds%NOTFOUND           -- end of fetch
	         OR purge_holds%NOTFOUND IS NULL;  -- empty cursor


	    IF v_release_id > 0 THEN
	        return_status := so_purge_hold_releases( v_release_id,
	                                                 p_request_id );
	    END IF;

	    IF return_status > -1 AND v_source_id  >  0 THEN
	        return_status := so_purge_hold_sources( v_source_id,
	                                                p_request_id );
	    END IF;

	    IF return_status > -1 THEN
		SELECT header_id
		INTO   syntax_required
		FROM   so_order_holds
		WHERE  order_hold_id = v_order_hold_id
		FOR UPDATE NOWAIT;

	        DELETE FROM   so_order_holds
	        WHERE  order_hold_id = v_order_hold_id;
	    ELSE
	        EXIT;  -- abort additional processing
	    END IF;

	END LOOP;

	CLOSE purge_holds;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              v_order_hold_id,
                              'OEPUR: SO_ORDER_HOLDS',
                              NULL );
	    CLOSE purge_holds;
            RETURN return_status;

  END so_purge_order_holds;


FUNCTION so_purge_picking_batches
           ( p_batch_id    NUMBER,
             p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT batch_id             --  Lock rows to be purged
	FROM   so_picking_batches
	WHERE  batch_id  = p_batch_id
	AND    header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_picking_batches
	WHERE  batch_id  = p_batch_id
	AND    header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_batch_id,
                              'OEPUR: SO_PICKING_BATCHES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_picking_batches;

FUNCTION so_purge_picking_cancellations
           ( p_picking_line_id  NUMBER,
             p_request_id       NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT picking_line_id      --  Lock rows to be purged
	FROM   so_picking_cancellations
	WHERE  picking_line_id = p_picking_line_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_picking_cancellations
	WHERE  picking_line_id = p_picking_line_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_picking_line_id,
                              'OEPUR: SO_PICKING_CANCELLATIONS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_picking_cancellations;


FUNCTION so_purge_picking_headers
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

syntax_required      NUMBER := 0;
return_status        NUMBER := 0;
v_batch_id           NUMBER := 0;
v_picking_header_id  NUMBER := 0;

CURSOR purge_picking IS
	SELECT picking_header_id,
	       batch_id
	FROM   so_picking_headers
	WHERE  order_header_id = p_header_id;
BEGIN
	OPEN purge_picking;

	LOOP
	    FETCH purge_picking INTO  v_picking_header_id, v_batch_id;

	    EXIT WHEN purge_picking%NOTFOUND           -- end of fetch
	           OR purge_picking%NOTFOUND IS NULL;  -- empty cursor

	    SELECT order_header_id    --  Lock rows to be purged
	    INTO   syntax_required
	    FROM   so_picking_headers
	    WHERE  picking_header_id = v_picking_header_id
	    AND    batch_id          = v_batch_id
	    FOR UPDATE NOWAIT;

	    return_status := so_purge_picking_batches( v_batch_id,
	                                               p_header_id,
	                                               p_request_id );

	    IF return_status > -1 THEN
	        return_status := so_purge_picking_lines( v_picking_header_id,
	                                                 p_request_id );
	    END IF;

	    IF return_status > -1 THEN
	        return_status := so_purge_freight_charges( v_picking_header_id,
	                                                   p_request_id );
	    END IF;

	    IF return_status > -1 THEN
	        DELETE FROM   so_picking_headers
	        WHERE  picking_header_id = v_picking_header_id
	        AND    batch_id          = v_batch_id;
	    ELSE
	        EXIT;  -- abort additional processing
	    END IF;

	END LOOP;

	CLOSE purge_picking;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              v_picking_header_id,
                              'OEPUR: SO_PICKING_HEADERS',
                              NULL );
	    CLOSE purge_picking;
            RETURN return_status;

END so_purge_picking_headers;

FUNCTION so_purge_picking_line_details
           ( p_picking_line_id  NUMBER,
             p_request_id       NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT picking_line_id      --  Lock rows to be purged
	FROM   so_picking_line_details
	WHERE  picking_line_id = p_picking_line_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_picking_line_details
	WHERE  picking_line_id = p_picking_line_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_picking_line_id,
                              'OEPUR: SO_PICKING_LINE_DETAILS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_picking_line_details;


FUNCTION so_purge_picking_lines
           ( p_picking_header_id  NUMBER,
             p_request_id         NUMBER )  RETURN NUMBER IS

return_status      NUMBER := 0;
syntax_required    NUMBER := 0;
v_picking_line_id  NUMBER := 0;

CURSOR purge_lines IS
	SELECT picking_line_id
	FROM   so_picking_lines
	WHERE  picking_header_id = p_picking_header_id;
BEGIN

	OPEN purge_lines;

	LOOP
	    FETCH purge_lines
	    INTO  v_picking_line_id;

	    EXIT WHEN purge_lines%NOTFOUND           -- end of fetch
	           OR purge_lines%NOTFOUND IS NULL;  -- empty cursor

	    SELECT picking_line_id     -- Lock rows to be purged
	    INTO   syntax_required
	    FROM   so_picking_lines
	    WHERE  picking_line_id = v_picking_line_id
	    FOR UPDATE NOWAIT;

	    return_status := so_purge_picking_line_details( v_picking_line_id,
	                                                    p_request_id );
	    IF return_status > -1 THEN
	       return_status:=so_purge_picking_cancellations(v_picking_line_id,
	                                                     p_request_id );
	    END IF;

	    IF return_status > -1 THEN
	        DELETE FROM   so_picking_lines
	        WHERE  picking_line_id = v_picking_line_id;
	    ELSE
	        EXIT;  -- abort additional processing
	    END IF;

	END LOOP;

	CLOSE purge_lines;
	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              v_picking_line_id,
                              'OEPUR: SO_PICKING_LINES',
                              NULL );
	    CLOSE purge_lines;
            RETURN return_status;

END so_purge_picking_lines;


FUNCTION so_purge_backorder_cancelled
           ( p_header_id          NUMBER,
             p_request_id         NUMBER )  RETURN NUMBER IS

return_status      NUMBER := 0;
syntax_required    NUMBER := 0;
v_picking_line_id  NUMBER := 0;

CURSOR purge_backorder_lines IS
        SELECT picking_line_id
        FROM   so_picking_lines spl, so_lines sl
        WHERE  spl.picking_header_id = -1
        AND    sl.line_id            = spl.order_line_id
	   AND    sl.header_id          = p_header_id;
BEGIN

        OPEN purge_backorder_lines;

        LOOP
            FETCH purge_backorder_lines
            INTO  v_picking_line_id;

            EXIT WHEN purge_backorder_lines%NOTFOUND           -- end of fetch
                   OR purge_backorder_lines%NOTFOUND IS NULL;  -- empty cursor

            SELECT picking_line_id     -- Lock rows to be purged
            INTO   syntax_required
            FROM   so_picking_lines
            WHERE  picking_line_id = v_picking_line_id
            FOR UPDATE NOWAIT;

            return_status := so_purge_picking_line_details( v_picking_line_id,
                                                            p_request_id );
            IF return_status > -1 THEN
               return_status:=so_purge_picking_cancellations(v_picking_line_id,
                                                             p_request_id );
            END IF;
            IF return_status > -1 THEN
                DELETE FROM   so_picking_lines
                WHERE  picking_line_id = v_picking_line_id;
            ELSE
                EXIT;  -- abort additional processing
            END IF;

        END LOOP;

        CLOSE purge_backorder_lines;
        RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
        WHEN OTHERS THEN
            return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              v_picking_line_id,
                              'OEPUR: SO_PICKING_LINES',
                              NULL );
            CLOSE purge_backorder_lines;
            RETURN return_status;

END so_purge_backorder_cancelled;


FUNCTION so_purge_picking_rules
             ( p_header_id   NUMBER,
               p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_picking_rules
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_picking_rules
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_PICKING_RULES',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_picking_rules;


FUNCTION so_purge_price_adjustments
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_price_adjustments
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM   so_price_adjustments
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_PRICE_ADJUSTMENTS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_price_adjustments;


FUNCTION so_purge_sales_credits
           ( p_header_id   NUMBER,
             p_request_id  NUMBER )  RETURN NUMBER IS

return_status   NUMBER := 0;
syntax_required  NUMBER := 0;

CURSOR SO_LOCK_RECORDS IS
	SELECT header_id            --  Lock rows to be purged
	FROM   so_sales_credits
	WHERE  header_id = p_header_id
	FOR UPDATE NOWAIT;
BEGIN
	OPEN SO_LOCK_RECORDS;
	CLOSE SO_LOCK_RECORDS;

	DELETE FROM so_sales_credits
	WHERE  header_id = p_header_id;

	RETURN SQLCODE;

EXCEPTION                   --  Exception handler to record error
	WHEN OTHERS THEN
	    return_status := SQLCODE;
            ROLLBACK;
            so_record_errors( return_status,
                              p_request_id,
                              p_header_id,
                              'OEPUR: SO_SALES_CREDITS',
                              NULL );
	    CLOSE SO_LOCK_RECORDS;
            RETURN return_status;

END so_purge_sales_credits;

PROCEDURE so_record_errors
		( p_return_status          IN NUMBER,
		  p_request_id             IN NUMBER,
		  p_id_number              IN NUMBER,
		  p_context                IN VARCHAR2,
		  p_error_message          IN VARCHAR2 ) IS

return_status     NUMBER   := 0;  -- success/failue from called routine
v_exception_id    NUMBER   := 0;  -- next exception_id
v_application_id  NUMBER   := 0;  -- fnd_application id for OE
v_message_text    VARCHAR2(512);  -- SQL error text corresponding to
                                  -- return_status from called routine
v_uid             NUMBER   := 0;  -- User identification
v_program_id      NUMBER;

BEGIN
	IF p_return_status = 0 THEN
	    v_message_text := p_error_message;
	ELSE
	    v_message_text := SQLERRM( p_return_status );
	END IF;

	SELECT so_exceptions_s.NEXTVAL
	INTO   v_exception_id
	FROM   DUAL;

	SELECT UID
	INTO   v_uid
	FROM   dual;

	SELECT application_id
	INTO   v_application_id
	FROM   fnd_application
	WHERE  application_short_name = 'OE';


        SELECT concurrent_program_id
        INTO v_program_id
        FROM fnd_concurrent_programs
        WHERE application_id=v_application_id
        AND concurrent_program_name='OEXPURGE';

	INSERT INTO   so_exceptions         -- record an error
	VALUES ( v_exception_id,     -- sequence number
	         SYSDATE,            -- creation date
	         v_uid,              -- created by
	         SYSDATE,            -- last updated date
	         v_uid,              -- last updated by
	         v_uid,              -- last update login
	         p_request_id,       -- request id
	         v_application_id,   -- program application id
	         v_program_id,                  -- program_id
	         SYSDATE,            -- last date changed by current pgm
	         p_context,          -- object on which exception occurred
	         p_id_number,        -- id number,
	         v_message_text );   -- SQLERRM

	IF p_return_status <> 0  -- If writting a SQL error
	THEN                     -- then commit the record
	     COMMIT;             -- else (assume) it is commited by the caller
	END IF;

END so_record_errors;

END OEXPURGE;   /* end of OEXPURGE package */

/
