--------------------------------------------------------
--  DDL for Package GML_RECV_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RECV_TRANS_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLRTRNS.pls 115.5 2002/12/04 19:13:57 gmangari ship $ */

  PROCEDURE gml_insert_recv_interface(p_recv_id NUMBER, p_line_id NUMBER,
                                      p_po_id NUMBER, p_poline_id NUMBER,
                                p_opm_item_id NUMBER, p_recv_qty1 NUMBER,
                                p_recv_um1 VARCHAR2,  p_dtl_recv_date DATE DEFAULT SYSDATE);

  PROCEDURE gml_adjust_recv_trans(p_recv_id IN NUMBER, p_line_id IN NUMBER,
                                      p_po_id IN NUMBER, p_poline_id IN NUMBER,
                                p_opm_item_id IN NUMBER, p_recv_qty1 IN NUMBER,
                                p_old_recv_qty1 IN NUMBER,
                                p_recv_um1 IN VARCHAR2,
                                p_return_ind IN NUMBER,
                                p_recv_status IN NUMBER,
                                p_net_price IN NUMBER,
				p_rtrn_void_ind IN NUMBER);

  PROCEDURE gml_store_return_qty(p_return_qty1 IN NUMBER,
                                 p_return_um1 IN VARCHAR2);

  PROCEDURE gml_insert_adjust_error(p_recv_id IN NUMBER, p_line_id IN NUMBER,
                                    p_recv_qty1 IN NUMBER,
                                    p_old_recv_qty1 IN NUMBER,
                                    p_recv_um1 IN VARCHAR2,
				    p_return_ind IN NUMBER,
				    p_recv_status IN NUMBER,
				    p_rtrn_void_ind IN NUMBER);

  PROCEDURE gml_new_rcv_trans_insert(p_recv_id IN NUMBER, p_line_id IN NUMBER,
				    p_po_id IN NUMBER,p_poline_id IN NUMBER,
                                    p_opm_item_id IN NUMBER,
                                    p_recv_qty1 IN NUMBER,
                                    p_old_recv_qty1 IN NUMBER,
                                    p_recv_um1 IN VARCHAR2,
				    p_transaction_type IN VARCHAR2,
				    p_transaction_id IN NUMBER,
				    p_destination_type_code IN VARCHAR2,
				    p_header_interface_id IN NUMBER,
				    p_group_id IN NUMBER,
				    p_rcv_receipt_num IN po_recv_hdr.recv_no%TYPE,
				    p_header_flag IN NUMBER,
				    p_dtl_recv_date DATE DEFAULT SYSDATE);

  PROCEDURE gml_process_adjust_errors(retcode OUT NOCOPY NUMBER);


/* package variables */
G_header_interface_id      rcv_headers_interface.header_interface_id%TYPE;
G_group_id                 rcv_headers_interface.group_id%TYPE;
G_interface_transaction_id rcv_transactions_interface.interface_transaction_id%TYPE;
G_recv_id                  NUMBER DEFAULT 0;
G_ship_to_organization_id  po_line_locations_all.ship_to_organization_id%TYPE;
G_return_qty1              po_rtrn_dtl.return_qty1%TYPE;
G_return_um1               po_rtrn_dtl.return_um1%TYPE;
G_adjust_mode              VARCHAR2(6) DEFAULT 'NORMAL';
G_rows_inserted            NUMBER DEFAULT 0;

END GML_RECV_TRANS_PKG;

 

/
