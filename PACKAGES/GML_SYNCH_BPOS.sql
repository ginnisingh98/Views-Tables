--------------------------------------------------------
--  DDL for Package GML_SYNCH_BPOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_SYNCH_BPOS" AUTHID CURRENT_USER AS
/* $Header: GMLPBPOS.pls 115.7 2002/12/04 19:07:00 gmangari ship $ */

PROCEDURE next_bpo_id
  (new_bpo_id            OUT NOCOPY PO_BPOS_HDR.BPO_ID%TYPE,
   p_orgn_code           IN  SY_ORGN_MST.ORGN_CODE%TYPE,
   v_next_id_status      OUT NOCOPY BOOLEAN);

FUNCTION  bpo_exist
  (v_bpo_no 	         IN  PO_BPOS_HDR.BPO_NO%TYPE) RETURN	BOOLEAN;

FUNCTION  bpo_line_exist
  (v_po_header_id        IN  CPG_PURCHASING_INTERFACE.PO_HEADER_ID%TYPE,
   v_po_line_id	         IN  CPG_PURCHASING_INTERFACE.PO_LINE_ID%TYPE,
   v_po_line_location_id IN  CPG_PURCHASING_INTERFACE.PO_LINE_LOCATION_ID%TYPE)
  RETURN BOOLEAN;

FUNCTION  get_bpo_line_no
  (v_bpo_id                  IN  NUMBER,
   v_po_header_id            IN  NUMBER,
   v_po_line_id              IN  NUMBER) RETURN NUMBER;

PROCEDURE cpg_bint2gms
  ( retcode               OUT NOCOPY NUMBER);

END GML_SYNCH_BPOS;

 

/
