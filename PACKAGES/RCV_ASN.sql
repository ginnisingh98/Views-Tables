--------------------------------------------------------
--  DDL for Package RCV_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ASN" AUTHID CURRENT_USER as
/* $Header: RCVRASNS.pls 120.0 2005/06/02 02:03:08 appldev noship $*/
procedure derive_asn_rcv_line (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           x_header_record      in rcv_roi_preprocessor.header_rec_type);

procedure derive_asn_rcv_line_qty (
           x_cascaded_table		in out	nocopy rcv_roi_preprocessor.cascaded_trans_tab_type,
           n				    in out  nocopy binary_integer,
           temp_cascaded_table  in out  nocopy rcv_roi_preprocessor.cascaded_trans_tab_type);

PROCEDURE default_asn_rcv_line(
      x_cascaded_table   IN OUT NOCOPY   rcv_roi_preprocessor.cascaded_trans_tab_type,
      n                  IN              BINARY_INTEGER,
      x_header_id        IN              rcv_headers_interface.header_interface_id%TYPE,
      x_header_record    IN              rcv_roi_preprocessor.header_rec_type
   );

PROCEDURE validate_asn_rcv_line (
           X_cascaded_table	    IN OUT	NOCOPY rcv_roi_preprocessor.cascaded_trans_tab_type,
		   n				    IN binary_integer,
		   X_header_record      IN      rcv_roi_preprocessor.header_rec_type);

END RCV_ASN;


 

/
