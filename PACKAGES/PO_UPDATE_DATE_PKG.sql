--------------------------------------------------------
--  DDL for Package PO_UPDATE_DATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_UPDATE_DATE_PKG" AUTHID CURRENT_USER AS
/* $Header: POXUPDTS.pls 120.0.12010000.2 2013/10/25 09:22:20 swvyamas noship $*/

  /* update_promised_date
   * --------------------
   */
  PROCEDURE update_promised_date(p_line_location_id  NUMBER,
                                 p_new_promised_date DATE);

  /* update_need_by_date
   * -------------------
   */
  PROCEDURE update_need_by_date(p_line_location_id NUMBER,
                                p_new_need_by_date DATE);

  /* update_req_need_by_date
   * -----------------------
   */
  PROCEDURE update_req_need_by_date(p_requisition_line_id NUMBER,
                                    p_new_need_by_date    DATE);

  /* update_promised_date_lead_time
   * -----------------------
   * Update the promised date of the shipment based on the lead time of source document.
   */
  PROCEDURE update_promised_date_lead_time(p_po_header_id NUMBER );


END PO_UPDATE_DATE_PKG;


/
