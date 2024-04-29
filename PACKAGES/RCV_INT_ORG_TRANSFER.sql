--------------------------------------------------------
--  DDL for Package RCV_INT_ORG_TRANSFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_INT_ORG_TRANSFER" AUTHID CURRENT_USER as
/* $Header: RCVIOTFS.pls 120.0.12000000.1 2007/01/16 23:29:24 appldev ship $*/
procedure derive_int_org_rcv_line (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           x_header_record      in rcv_roi_preprocessor.header_rec_type);

procedure derive_int_org_rcv_line_qty (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type);

PROCEDURE default_int_org_rcv_line (
           X_cascaded_table	    IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
		   n				    IN binary_integer);

procedure derive_int_org_trans_del (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           x_header_record      in rcv_roi_preprocessor.header_rec_type);

procedure derive_trans_del_line_quantity (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type);

PROCEDURE default_int_org_trans_del (
           X_cascaded_table	    IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
		   n				    IN binary_integer);

PROCEDURE derive_int_org_cor_line(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      x_header_record       IN              rcv_roi_preprocessor.header_rec_type);

PROCEDURE derive_int_org_cor_line_qty(
      x_cascaded_table      IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                     IN OUT NOCOPY   BINARY_INTEGER,
      temp_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type)      ;

PROCEDURE default_int_org_cor_line(
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER);

PROCEDURE validate_int_org_rcv_line (
           X_cascaded_table	    IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
		   n				    IN binary_integer,
		   X_header_record      IN      rcv_roi_preprocessor.header_rec_type);

/* Bug 3735972.
 * We used to call validate_ref_integrity that had code only for PO.
 * We need to have a similar one to validate internal orders and
 * inter-org shipments.
*/

PROCEDURE validate_ref_integrity (
           x_cascaded_table             IN OUT  NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
           n                                IN binary_integer,
           X_header_record      IN rcv_roi_preprocessor.header_rec_type);

END RCV_INT_ORG_TRANSFER;


 

/
