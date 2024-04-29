--------------------------------------------------------
--  DDL for Package MRP_PO_RESCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_PO_RESCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRPPORES.pls 120.4.12010000.3 2008/10/17 12:12:30 lsindhur ship $ */

PROCEDURE log_message( p_user_info IN VARCHAR2);
PROCEDURE debug_message( p_user_info IN VARCHAR2);
PROCEDURE debug_number_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_number );
PROCEDURE debug_date_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_date );
PROCEDURE debug_varchar30_tbl( p_msg IN VARCHAR2, p_tbl IN po_tbl_varchar30 );

PROCEDURE transfer_to_temp_table (
   p_dblink       IN VARCHAR2,
   p_instance_id  IN NUMBER,
   p_batch_id     IN NUMBER
);

PROCEDURE init( p_batch_id IN NUMBER , p_instance_id IN NUMBER , p_instance_code IN varchar2 , p_dblink IN varchar2);
PROCEDURE init_instance(p_user_name IN VARCHAR2,
                        p_resp_name IN VARCHAR2);
PROCEDURE cleanup_destination( p_batch_id IN NUMBER,
                               p_dblink   IN VARCHAR2 );

FUNCTION same_record(idx1 NUMBER, idx2 NUMBER) RETURN BOOLEAN;

FUNCTION get_next_record (
   x_po_header_id      OUT nocopy NUMBER,
   x_po_number         OUT nocopy VARCHAR2,
   x_operating_unit    OUT nocopy NUMBER,
   x_po_line_ids       OUT nocopy po_tbl_number,
   x_line_location_ids OUT nocopy po_tbl_number,
   x_distribution_ids  OUT nocopy po_tbl_number,
   x_qtys              OUT nocopy po_tbl_number,
   x_promise_dates     OUT nocopy po_tbl_date,
   x_uoms              OUT nocopy po_tbl_varchar30
) RETURN BOOLEAN;

PROCEDURE change_operating_unit( p_org_id NUMBER );

PROCEDURE msc_resched_po(
   errbuf        OUT NOCOPY VARCHAR2,
   retcode       OUT NOCOPY VARCHAR2,
   p_batch_id    IN         NUMBER,
   p_instance_id IN NUMBER,
   p_instance_code IN varchar2,
   p_dblink IN varchar2
);

PROCEDURE launch_reschedule_po(
   p_user_name   IN VARCHAR2,
   p_resp_name   IN VARCHAR2,
   p_batch_id    IN  NUMBER,
   p_instance_id IN NUMBER,
    p_instance_code IN varchar2,
   p_dblink IN varchar2,
   x_req_id      OUT NOCOPY NUMBER
);


END mrp_po_reschedule;

/
