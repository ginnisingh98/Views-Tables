--------------------------------------------------------
--  DDL for Package GMF_PO_AP_MATCH_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_PO_AP_MATCH_DATA" AUTHID CURRENT_USER AS
/* $Header: gmfmtchs.pls 115.0 99/07/16 04:21:08 porting shi $ */
  PROCEDURE po_send_ap_match_data(
          poheaderid        number,
          qty       out     number,
          qty_rcvd     out     number,
          qty_bill     out     number,
          qty_canl     out     number,
          qty_acpt     out     number,
          inv_num     in out    number,
          row_to_fetch in out number,
          statuscode  out     number);
END GMF_PO_AP_MATCH_DATA;

 

/
