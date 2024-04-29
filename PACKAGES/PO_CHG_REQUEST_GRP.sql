--------------------------------------------------------
--  DDL for Package PO_CHG_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHG_REQUEST_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGCHGS.pls 115.2 2004/02/27 23:41:05 jmojnida noship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(30) := 'PO_CHG_REQUEST_GRP';
  G_FILE_NAME CONSTANT    VARCHAR2(30) := 'POXGCHGS.pls';


/*
This PL/SQL table will store the supplier request.  A new row will be added
for each call of the store_supplier_request.
*/
  g_po_change_table pos_chg_rec_tbl := null;

/*
  g_int_cont_num value will store the internal control number of each request.
  This will be set in the initialize call and reset on the windup call.
  Each time the API is called, it will be matched for the integrity purposes.
*/
   g_int_cont_num   varchar2(256) := null;

/*
  g_po_number, g_po_type, g_release_number, g_tp_id, g_tp_site_id is the
  global variable for the active transaction information set at valid_header.
  g_requestor is the change requestor's application login; can be 'XML USER'
  if it is defined in fnd_user.
  g_request_origin is the origin of the change request, like, XML.
  This will help in duplicate validations in consequent procedures.

*/
  g_po_number  varchar2(20);
  g_po_type    varchar2(25);
  g_release_number number;
  g_tp_id      number;
  g_tp_site_id number;
  g_requestor  varchar2(256);
  g_request_origin  varchar2(30);
  g_last_upd_date  date;

/*
  This procedure needs to be called first to initialize an inbound transaction.
  This will initialize some global variables.  This should be called from the
  pre-process of the root node.  No errors should occur here lest there is
  any weird error, processing should not continue, as it has not been
  initialized properly.
*/
procedure  initialize_chn_ack_inbound (
   	p_requestor	IN  varchar2,  -- Change requester or the acknowledging username
	p_int_cont_num	IN  varchar2,  -- ECX's ICN. Used for integrity of request
	p_request_origin	IN  varchar2,  -- XML/OTA/9iAS/OPEN
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
	x_error_id	OUT NOCOPY number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status	OUT NOCOPY VARCHAR2 -- Error message


);

/*
  This API should be called from the in process of the header level.
  This will validate the header,
  if the PO #/Release  mentioned belongs to the vendor and vendor site id,
*/
procedure validate_header (
   	p_requestor	IN  varchar2,  -- Change requester or the acknowledging username
	p_int_cont_num	IN  varchar2,  -- ECX's ICN. Used for integrity of request
	p_request_origin	IN  varchar2,  -- '9iAS'
	p_request_type	IN  varchar2,  -- 'CHANGE' or 'ACKNOWLEDGE' or CANCELLATION
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
	p_po_number	IN  varchar2,  --PO # of the PO being modified or the Blanket's PO #
	p_release_number	IN  number,   -- Release number if the PO Type is release or null
	p_po_type 	IN  varchar2,  -- PO Type??  -- RELEASE for release, STANDARD for others.
	p_revision_num	IN  number,   -- Revision number of the PO or the release
	x_error_id_in	IN  number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status_in IN  VARCHAR2, -- Error message
	x_error_id_out	OUT NOCOPY number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status_out OUT NOCOPY VARCHAR2 -- Error message


);


/*
  This API should be called from the in process of the lines.
  This procedure needs to be called in the following scenarios:
1.	Modifications to a PO at the shipment level
2.	Modifications to a PO at the line level
3.	Acknowledgment at the shipment level
4.	Canceling at the shipment level
5.      Splitting a shipment  (from FPJ)
Calls to this API will be stored in a pl/sql table and will not be processed immediately.
Call process_supplier_request to process the request.
*/
procedure store_supplier_request (
	p_requestor	IN  varchar2,  -- Change requester or the acknowledging username
	p_int_cont_num	IN  varchar2,  -- ECX's ICN. Used for integrity of request
	p_request_type	IN  varchar2,  -- ??'CHANGE' or 'ACKNOWLEDGE'
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
	p_level         IN varchar2,   --  Level at which the api is called. HEADER, LINE, SHIPMENT
        p_po_number	IN  varchar2,  --PO # of the PO being modified or the Blanket's PO #
        p_release_number	IN  number,   -- Release number if the PO Type is release or null
	p_po_type 	IN  varchar2,  -- PO Type??  -- RELEASE for release, STANDARD for others.
        p_revision_num	IN  number,   -- Revision number of the PO or the release
	p_line_num	IN  number,    -- Line number being modified
	p_reason	IN  varchar2,   -- Reason for change or acknowledgment (can be null?!)
	p_shipment_num	IN  number,    -- Shipment number (can be null if the change is at the line)
	p_quantity	IN  number,    -- The new quantity (can be null)
	p_quantity_uom	IN  varchar2,  -- The UOM of the new quantity
	p_price	IN  number,    -- The new price value (can be null)
	p_price_currency	IN  varchar2,  -- The currency code of the new price (can be null)
	p_price_uom	IN  varchar2,   -- The UOM code of the new price (can be null)
	-- Note that the above two are used only for verifying if they are same as the original values.
	p_promised_date	IN  date,         -- The new promised date (can be null)
	p_supplier_part_num     IN  varchar2,   --  The new supplier part number (can be null)
	p_so_number	IN  varchar2,  --  The new sales order number (can be null)
	p_so_line_number	IN  varchar2,  --  The new sales order line number (can be null)
	p_ack_type      IN  varchar2,  --'ACCEPT' or 'REJECT' or 'MODIFICATION' or NULL

       /* Note the error messages occurred during multiple calls are concatenated.
         XML Gateway does not support IN OUT parameters.  So, this is a work around.
	*/
       x_error_id_in	IN     number,  --  Error id from the initialize procedure
  	x_error_status_in IN   varchar2,  --   Error message from the earlier API calls.
       x_error_id_out	OUT NOCOPY number,   -- The error id will be 2; errors will go to the TP sysadmin
       x_error_status_out OUT NOCOPY varchar2, -- Error message in this call concatenated with the old ones
       p_parent_shipment_number  number default NULL,
       p_SUPPLIER_DOC_REF       varchar2 default NULL,
       p_SUPPLIER_LINE_REF      varchar2 default NULL,
       p_SUPPLIER_SHIPMENT_REF  varchar2 default NULL


);

/*
  Call this procedure from the post-process before calling the wind-up API only if the
  error_id from the earlier calls is 0.  This API should not be called if the request is
  for header level acknowledgment.  This API will place the supplier request in the
  change request table and kicks-off the workflow for the approval of the change request.
*/
procedure process_supplier_request (
	p_int_cont_num	IN varchar2,
	x_error_id_in   IN number,
	x_error_status_in IN varchar2,
	x_error_id_out	OUT NOCOPY number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status_out OUT NOCOPY VARCHAR2 -- Error message


);

/*
  This procedure needs to be called from Acknowledge PO inbound at in_process of the header,
  only when the PO is acknowledged at the header level.  In case of shipment level acknowledgement
  this procedure should not be called.  The acknowledge po request will be processed immediately
  and only once per transaction.  So, no need for error_id_in and error_id_out etc.
*/
procedure acknowledge_po(
	p_requestor	IN  varchar2,  -- Change requester or the acknowledging username
	p_int_cont_num	IN  varchar2,  -- ECX's ICN. Used for integrity of request
	p_request_type	IN  varchar2,  -- ??'ACKNOWLEDGE'
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
        p_po_number	IN  varchar2,  --PO # of the PO being modified or the Blanket's PO #
        p_release_number	IN  number,   -- Release number if the PO Type is release or null
	p_po_type 	IN  varchar2,  -- PO Type??  -- RELEASE for release, STANDARD for others.
       p_revision_num	IN  number,   -- Revision number of the PO or the release
	p_ack_code	IN  number,   -- 0 for accept 2 reject
	p_ack_reason	IN  varchar2,  --  comments
	x_error_id	OUT NOCOPY number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status	OUT NOCOPY VARCHAR2 -- Error message

);
/*
  	Call this procedure at the post process stage as the last action.
  	At this point the pl/sql table will be 'delete'd.  Call this procedure
  	even if there were errors in the earlier calls.
*/
procedure  windup_chn_ack_inbound (
   	p_requestor	IN  varchar2,  -- Change requester or the acknowledging username
	p_int_cont_num	IN  varchar2,  -- ECX's ICN. Used for integrity of request
	p_request_origin	IN  varchar2,  -- '9iAS'
	p_tp_id	IN  number,    --  vendor_id
	p_tp_site_id	IN  number,    --  vendor_site_id
       x_error_id_in	IN     number,  --  Error id from the initialize procedure
  	x_error_status_in	IN     varchar2,  --   Error message from the earlier API calls.
	x_error_id_out	OUT NOCOPY number,   -- The error id will be 2, errors will go to the TP sysadmin
	x_error_status_out OUT NOCOPY VARCHAR2 --Error message



);
end PO_CHG_REQUEST_GRP;


 

/
