--------------------------------------------------------
--  DDL for Package GMD_QA_RCV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QA_RCV_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPRECS.pls 120.0.12010000.2 2008/11/04 21:14:37 plowe ship $ */

FUNCTION get_disposition
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN VARCHAR2;

FUNCTION get_quantity
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN NUMBER;

FUNCTION get_inspection_result
( p_po_num IN VARCHAR2,
  p_po_line_num IN VARCHAR2,
  p_shipment_num IN VARCHAR2,
  p_receipt_num IN VARCHAR2,
  p_shipment_line_id IN NUMBER default null -- 7447810
) RETURN VARCHAR2;


-- The procedure has autonomous transaction pragma.
-- It inserts data into the gmd_sampling_events table

PROCEDURE store_collection_details(
						p_po_num IN VARCHAR2,
  					p_po_line_num IN VARCHAR2,
  					p_shipment_num IN VARCHAR2,
  					p_receipt_num IN VARCHAR2,
  					p_plan_name IN VARCHAR2,
  					p_collection_id IN NUMBER,
  					p_occurrence IN NUMBER);



END GMD_QA_RCV_PUB;

/
