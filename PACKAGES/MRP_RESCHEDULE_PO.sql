--------------------------------------------------------
--  DDL for Package MRP_RESCHEDULE_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RESCHEDULE_PO" AUTHID CURRENT_USER AS
/*$Header: MRPRSPOS.pls 120.0.12010000.3 2010/03/19 18:59:46 cnazarma ship $ */

PROCEDURE reschedule_po_program
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_old_need_by_date IN DATE,
p_new_need_by_date IN DATE,
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_qty IN NUMBER);

FUNCTION reschedule_po( X_old_need_by_dates      po_tbl_date,
                         X_new_need_by_dates      po_tbl_date,
                         X_po_header_id           number,
                         X_po_line_ids            po_tbl_number,
                         X_po_number              varchar2,
                         X_shipment_nums          po_tbl_number,
                         X_estimated_pickup_dates po_tbl_date,
                         X_ship_methods           po_tbl_varchar30,
                         l_derived_status IN OUT NOCOPY number)
return boolean;

FUNCTION get_request_status(
                           x_error_messages po_tbl_varchar2000)
return number;


FUNCTION set_result(p_result boolean,
                    l_derived_output number)
return number;


END mrp_reschedule_po;

/
