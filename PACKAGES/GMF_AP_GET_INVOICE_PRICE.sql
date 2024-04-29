--------------------------------------------------------
--  DDL for Package GMF_AP_GET_INVOICE_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AP_GET_INVOICE_PRICE" AUTHID CURRENT_USER AS
/* $Header: gmfinvps.pls 115.3 2002/12/04 17:04:28 umoogala ship $ */
  PROCEDURE proc_ap_get_invoice_price (
    start_date          in      date,
    end_date            in      date,
    invoicenum         in out nocopy  varchar2,
    invoice_line_no     in out nocopy  number,
    invoiceid          in out nocopy  number,
    vendor_id           in out nocopy  number,
    invoice_type        in out nocopy  varchar2,
    previous_invoice_num   out nocopy  varchar2,
    invoice_status      in out nocopy  varchar2,
    po_header_id        in out nocopy  number,
    po_line_id          in out nocopy  number,
    po_line_location_id in out nocopy  number,
    line_type           in out nocopy  varchar2,
    item_no                out nocopy  varchar2,
    item_desc              out nocopy  varchar2,
    invoice_qty            out nocopy  number,
    invoice_uom            out nocopy  varchar2,
    invoice_amount         out nocopy  number,
    invoice_base_amount    out nocopy  number,
    base_unit_price        out nocopy  number,
    unit_price             out nocopy  number,
    billing_currency       out nocopy  varchar2,
    base_currency          out nocopy  varchar2,
    exchange_rate          out nocopy  number,
    invoice_date           out nocopy  date,
    gl_date                out nocopy  date,
    creation_date           out nocopy  date,
    created_by             out nocopy  number,
    last_update_date       out nocopy  date,
    last_updated_by        out nocopy  number,
		t_cancelled_date    in out nocopy  date,
		t_match_status_flag in out nocopy  varchar2,
    t_hold_count        in out nocopy  number,
		approval               out nocopy  varchar2,
    statuscode             out nocopy  number,
    rowtofetch          in out nocopy  number);
END GMF_AP_GET_INVOICE_PRICE;

 

/
