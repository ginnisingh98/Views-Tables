--------------------------------------------------------
--  DDL for Package Body GMF_PO_AP_MATCH_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_PO_AP_MATCH_DATA" AS
/* $Header: gmfmtchb.pls 115.0 99/07/16 04:21:03 porting shi $ */
  CURSOR po_send_ap(poheaderid number)  IS
        SELECT   po_l_l.quantity,
              po_l_l.quantity_received,
              po_l_l.quantity_billed,
              po_l_l.quantity_cancelled,
              po_l_l.quantity_accepted,
              ap_i_d.invoice_id
             FROM  po_line_locations_all po_l_l,
              po_distributions_all po_d,
            ap_invoice_distributions_all ap_i_d
          WHERE po_d.po_header_id = poheaderid    AND
              ap_i_d.po_distribution_id =
                po_d.po_distribution_id   AND
              po_d.line_location_id =
                po_l_l.line_location_id;
  PROCEDURE po_send_ap_match_data(
          poheaderid      number,
          qty       out   number,
          qty_rcvd     out   number,
          qty_bill     out   number,
          qty_canl     out   number,
          qty_acpt     out   number,
          inv_num     in out  number,
          row_to_fetch in out number,
          statuscode  out  number) is
  Begin  /* Beginning of procedure po_send_ap_match_data */
    IF NOT po_send_ap%ISOPEN THEN
      OPEN po_send_ap(poheaderid);
    End if;

    FETCH   po_send_ap
    INTO     qty,
          qty_rcvd,
          qty_bill,
          qty_canl,
          qty_acpt,
          inv_num;
    IF po_send_ap%NOTFOUND or row_to_fetch = 1 THEN
      CLOSE po_send_ap;
      if po_send_ap%NOTFOUND then
         statuscode := 100;
         end if;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        statuscode := SQLCODE;
  End;  /* End of procedure po_send_ap_match_data */
END GMF_PO_AP_MATCH_DATA;  -- End po_send_ap_match_data

/
