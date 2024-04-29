--------------------------------------------------------
--  DDL for Package WSH_DCP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DCP_PVT" AUTHID CURRENT_USER as
/* $Header: WSHDCPPS.pls 120.0 2005/05/26 19:32:18 appldev noship $ */


TYPE g_dc_rec_type IS RECORD(
  source_header_number VARCHAR2(100),
  source_header_id NUMBER,
  source_line_number VARCHAR2(100),
  source_line_id NUMBER,
  delivery_detail_id NUMBER,
  dcp_script VARCHAR2(32767));



TYPE g_dc_tbl_type IS TABLE OF g_dc_rec_type INDEX BY BINARY_INTEGER;

TYPE t_dc_columns_rec_type IS RECORD(
       wdd_source_header_number wsh_delivery_details.source_header_number%TYPE,
       wdd_source_line_number   wsh_delivery_details.source_line_number%TYPE,
       wdd_delivery_detail_id   wsh_delivery_details.delivery_detail_id%TYPE,
       wdd_released_status      wsh_delivery_details.released_status%TYPE,
       wdd_requested_quantity   wsh_delivery_details.requested_quantity%TYPE,
       wdd_source_code          wsh_delivery_details.source_code%TYPE,
       wdd_batch_id             wsh_delivery_details.batch_id%TYPE,
       wdd_source_line_id       wsh_delivery_details.source_line_id%TYPE,
       wdd_source_header_id     wsh_delivery_details.source_header_id%TYPE,
       wdd_oe_interfaced_flag   wsh_delivery_details.oe_interfaced_flag%TYPE,
       wdd_inv_interfaced_flag  wsh_delivery_details.inv_interfaced_flag%TYPE,
       wdd_ship_set_id          wsh_delivery_details.ship_set_id%TYPE,
       wdd_date_requested       wsh_delivery_details.date_requested%TYPE,
       wdd_date_scheduled       wsh_delivery_details.date_scheduled%TYPE,
       wdd_ship_to_contact_id   wsh_delivery_details.ship_to_contact_id%TYPE,
       wdd_ship_to_site_use_id  wsh_delivery_details.ship_to_site_use_id%TYPE,
       wdd_org_id               wsh_delivery_details.org_id%TYPE,
       wdd_organization_id      wsh_delivery_details.organization_id%TYPE,
       wdd_ship_tolerance_above wsh_delivery_details.ship_tolerance_above%TYPE,
       wdd_ship_tolerance_below wsh_delivery_details.ship_tolerance_below%TYPE,
       wdd_picked_quantity      wsh_delivery_details.picked_quantity%TYPE,
       wdd_cycle_count_quantity wsh_delivery_details.cycle_count_quantity%TYPE,
       wdd_shipped_quantity     wsh_delivery_details.shipped_quantity%TYPE,
       ol_line_id               oe_order_lines_all.line_id%TYPE,
       --Line number here is a concatenation of five different numbers
       ol_line_number           VARCHAR2(32767),
       ol_ordered_quantity      oe_order_lines_all.ordered_quantity%TYPE,
       ol_cancelled_flag        oe_order_lines_all.cancelled_flag%TYPE,
       ol_ship_set_id           oe_order_lines_all.ship_set_id%TYPE,
       ol_shipped_quantity      oe_order_lines_all.shipped_quantity%TYPE,
       ol_flow_status_code      oe_order_lines_all.flow_status_code%TYPE,
       ol_open_flag             oe_order_lines_all.open_flag%TYPE,
       ol_ship_from_org_id      oe_order_lines_all.ship_from_org_id%TYPE,
       ol_org_id                oe_order_lines_all.org_id%TYPE,
       ol_schedule_ship_date    oe_order_lines_all.schedule_ship_date%TYPE,
       ol_request_date          oe_order_lines_all.request_date%TYPE,
       ol_shipping_interfaced_flag oe_order_lines_all.shipping_interfaced_flag%TYPE,
       ol_header_id             oe_order_lines_all.header_id%TYPE,
       ol_ship_to_contact_id    oe_order_lines_all.ship_to_contact_id%TYPE,
       ol_ship_to_org_id        oe_order_lines_all.ship_to_org_id%TYPE,
       ol_fulfilled_quantity    oe_order_lines_all.fulfilled_quantity%TYPE,
       ol_invoiced_quantity     oe_order_lines_all.invoiced_quantity%TYPE,
       oh_order_number          oe_order_headers_all.order_number%TYPE,
       oh_ship_from_org_id      oe_order_headers_all.ship_from_org_id%TYPE,
       wnd_delivery_id          wsh_new_deliveries.delivery_id%TYPE,
       wnd_status_code          wsh_new_deliveries.status_code%TYPE,
       wts_status_code          wsh_trip_stops.status_code%TYPE,
       wdl_delivery_leg_id      wsh_delivery_legs.delivery_leg_id%TYPE
       );


--Records are added to this table g_dc_table for each instance
--of data inconsistency detection.
g_dc_table g_dc_tbl_type;

--This global g_add_to_debug determines whether the contents of g_dc_table
--are added to the debug file.
--For cases where rollback is allowed and transaction is re-run, this global
--will have 0 in the first run and when the exception is raised, this is
--incremented.
g_add_to_debug NUMBER := 0;

--This global is used by Pick-Release and by OM. This is to make sure that
--there are no duplicate or there are no unnecessary calls to dcp procedure.
G_CALL_DCP_CHECK VARCHAR2(1) := 'Y';

--Whenever DCP code starts debugger, this global is set.
--Value of Y means debug is started
--Value of R means debug is reset.
G_DEBUG_STARTED VARCHAR2(1):= 'N';

--This global holds the message count
--This is used by Delivery Detail and Delivery Group APIs and also by
--Procedure Processs_Stop_to_OM in WSHDDSHB.pls for ITS.
--This global is used to compare the initial count of messages with the
--count of messages after first run(where re-run is possible) and to remove
--the duplicate set of messages from the message stack.
G_INIT_MSG_COUNT NUMBER := 0;

G_CHECK_DCP NUMBER;

G_EMAIL_SERVER VARCHAR2(32767);
G_EMAIL_ADDRESS VARCHAR2(32767);

--This is the exception raised by outer-level DCP procedures and is used
--by callers like delivery-detail and delivery group APIs, ITS code etc.
data_inconsistency_exception EXCEPTION;

dcp_caught EXCEPTION;

Procedure Send_Mail(sender IN VARCHAR2 DEFAULT NULL,
                    recipient1 IN VARCHAR2 DEFAULT NULL,
                    recipient2 IN VARCHAR2 DEFAULT NULL,
                    recipient3 IN VARCHAR2 DEFAULT NULL,
                    recipient4 IN VARCHAR2 DEFAULT NULL,
                    message IN VARCHAR2);

Procedure check_ITS(p_bulk_mode IN VARCHAR2,
                    p_start_index IN NUMBER DEFAULT NULL,
                    p_end_index IN NUMBER DEFAULT NULL,
                    p_its_rec IN OE_Ship_Confirmation_Pub.Ship_Line_Rec_Type,
                    p_raise_exception IN VARCHAR2 DEFAULT 'Y');

Procedure Check_Detail(p_action_code IN VARCHAR2,
                      p_dtl_table IN wsh_glbl_var_strct_grp.Delivery_Details_Attr_Tbl_Type);

Procedure Check_Delivery(p_action_code IN VARCHAR2,
                    p_dlvy_table IN  WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type);

Procedure Check_Pick_Release(p_batch_id IN NUMBER);


Procedure Check_Scripts(p_source_header_id IN NUMBER DEFAULT NULL,
                        p_source_line_id IN NUMBER DEFAULT NULL,
                        p_delivery_id IN NUMBER DEFAULT NULL,
                        p_batch_id IN NUMBER DEFAULT NULL,
                        x_data_inconsistent OUT NOCOPY VARCHAR2);

PROCEDURE Post_Process(p_action_code IN VARCHAR2 DEFAULT NULL,
                       p_raise_exception IN VARCHAR2 DEFAULT 'Y');

FUNCTION Is_dcp_enabled RETURN NUMBER;

END WSH_DCP_PVT;

 

/
