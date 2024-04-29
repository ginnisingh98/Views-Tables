--------------------------------------------------------
--  DDL for Package GML_PO_RECV1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_RECV1_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLRECVS.pls 115.5 1999/12/07 09:06:14 pkm ship      $ */

 /* NC - Changed v_ to G_  for the following variable names */
  G_po_id NUMBER;
  G_poline_id NUMBER;
  G_stock_ind NUMBER DEFAULT 0;

  /* NC - added the following variables */
  G_po_no	po_ordr_hdr.po_no%TYPE;
  G_line_no	po_ordr_dtl.line_no%TYPE;
  G_org_id	gl_plcy_mst.org_id%TYPE;
  G_returned_qty	po_rtrn_dtl.return_qty1%TYPE;
  G_actual_received_qty	po_recv_dtl.recv_qty1%TYPE;
  G_po_status		po_ordr_dtl.po_status%TYPE;
  G_created_by		po_recv_dtl.created_by%TYPE;


  PROCEDURE store_id(p_po_id NUMBER, p_poline_id NUMBER);
  PROCEDURE get_no(v_po_no OUT VARCHAR2, v_line_no OUT NUMBER);
  FUNCTION  check_mapping RETURN BOOLEAN;
  PROCEDURE sum_recv;

  PROCEDURE recv_mv;

END GML_PO_RECV1_PKG;

 

/
