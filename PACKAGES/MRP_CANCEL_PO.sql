--------------------------------------------------------
--  DDL for Package MRP_CANCEL_PO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_CANCEL_PO" AUTHID CURRENT_USER AS
/*$Header: MRPCNPOS.pls 120.0.12010000.1 2008/07/28 04:47:24 appldev ship $ */

PROCEDURE cancel_po_program
(
p_po_header_id IN NUMBER,
p_po_line_id IN NUMBER,
p_po_number IN VARCHAR2,
p_po_ship_num IN NUMBER,
p_doc_type    IN VARCHAR2,
p_doc_subtype IN VARCHAR2);

END mrp_cancel_po;

/
