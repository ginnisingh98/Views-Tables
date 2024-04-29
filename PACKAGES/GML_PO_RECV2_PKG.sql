--------------------------------------------------------
--  DDL for Package GML_PO_RECV2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_RECV2_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLRCMVS.pls 115.4 1999/11/23 13:36:06 pkm ship      $ */

PROCEDURE get_oracle_id
(  v_po_id             IN  po_ordr_hdr.po_id%TYPE,
   v_line_id           IN  po_ordr_dtl.line_id%TYPE,
   v_po_header_id      OUT cpg_oragems_mapping.po_header_id%TYPE,
   v_po_line_id        OUT  cpg_oragems_mapping.po_line_id%TYPE,
   v_line_location_id  OUT cpg_oragems_mapping.po_line_location_id%TYPE,
   v_po_release_id     OUT cpg_oragems_mapping.po_release_id%TYPE);

PROCEDURE  update_header_status
( v_po_header_id     IN NUMBER,
  v_org_id           IN NUMBER,
  v_last_updated_by  IN NUMBER,
  v_last_update_date IN DATE  );
PROCEDURE  update_line_status
( v_po_header_id      IN NUMBER,
 v_po_line_id         IN NUMBER,
 v_org_id             IN NUMBER,
 v_last_updated_by    IN NUMBER,
 v_last_update_date   IN DATE  );

PROCEDURE  update_release_status
( v_po_header_id     IN NUMBER,
  v_po_release_id    IN NUMBER,
  v_org_id           IN NUMBER,
  v_last_updated_by  IN NUMBER,
  v_last_update_date IN DATE  );

PROCEDURE update_line_locations
( v_po_header_id      IN cpg_oragems_mapping.po_header_id%TYPE,
  v_po_line_id        IN cpg_oragems_mapping.po_line_id%TYPE,
  v_line_location_id  IN cpg_oragems_mapping.po_line_location_id%TYPE,
  v_po_release_id     IN cpg_oragems_mapping.po_release_id%TYPE,
  v_org_id            IN gl_plcy_mst.org_id%TYPE,
  v_po_status         IN po_ordr_dtl.po_status%TYPE,
  v_received_qty      IN po_recv_dtl.recv_qty1%TYPE,
  v_returned_qty      IN po_rtrn_dtl.return_qty1%TYPE,
  v_created_by        IN po_recv_dtl.created_by%TYPE,
  v_timestamp         IN cpg_oragems_mapping.time_stamp%TYPE);



END GML_PO_RECV2_PKG;

 

/
