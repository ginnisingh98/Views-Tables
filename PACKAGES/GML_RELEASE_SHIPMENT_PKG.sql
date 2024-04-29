--------------------------------------------------------
--  DDL for Package GML_RELEASE_SHIPMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_RELEASE_SHIPMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLRLSHS.pls 115.3 2003/03/26 15:42:46 pupakare noship $ */
  TYPE t_inv_rec_tbl IS RECORD( item_id    NUMBER,
 			        whse_code  ic_whse_mst.whse_code%TYPE,
				Lot_id     NUMBER,
				Location   ic_loct_inv.location%TYPE,
				Trans_qty  NUMBER,
				Valid_flag NUMBER);

  TYPE t_loct_inv_tbl IS TABLE OF t_inv_rec_tbl
       INDEX BY BINARY_INTEGER;

  FUNCTION Check_negative_inv(v_bol_id NUMBER) RETURN NUMBER;
END GML_RELEASE_SHIPMENT_PKG;

 

/
