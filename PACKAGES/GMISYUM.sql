--------------------------------------------------------
--  DDL for Package GMISYUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMISYUM" AUTHID CURRENT_USER AS
/* $Header: GMISYUMS.pls 115.2 99/07/16 04:49:18 porting ship  $ */
  FUNCTION sy_uom_find(V_uom VARCHAR2, V_um_type IN OUT VARCHAR2, V_std_factor IN OUT NUMBER) RETURN NUMBER;
  FUNCTION sy_cnv_find(V_item_id NUMBER, V_lot_id NUMBER, V_um_type VARCHAR2, V_cnv_factor IN OUT NUMBER) RETURN NUMBER;
  FUNCTION sy_lab_find (V_item_id NUMBER, V_lot_id NUMBER, V_lab_type VARCHAR2, V_cnv_factor IN OUT NUMBER) RETURN NUMBER;
  FUNCTION sy_uomcv(V_item_id NUMBER, V_lot_id NUMBER, V_cur_qty NUMBER,
   V_cur_uom VARCHAR2, V_inv_uom VARCHAR2, V_new_qty IN OUT NUMBER,
   V_new_uom VARCHAR2, V_perform_lab NUMBER DEFAULT 0,
   V_density_conv_factor NUMBER DEFAULT 0, V_def_lab VARCHAR2 DEFAULT NULL) RETURN NUMBER;
END gmisyum;

 

/
