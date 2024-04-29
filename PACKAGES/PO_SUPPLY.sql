--------------------------------------------------------
--  DDL for Package PO_SUPPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SUPPLY" AUTHID CURRENT_USER AS
/* $Header: RCVRCSUS.pls 120.2.12010000.1 2008/07/24 14:36:36 appldev ship $ */

  -- Switchboard for PO and Requisition Actions

  FUNCTION po_req_supply(p_docid         IN NUMBER,
                         p_lineid        IN NUMBER,
                         p_shipid        IN NUMBER,
                         p_action        IN VARCHAR2,
                         p_recreate_flag IN BOOLEAN,
                         p_qty           IN NUMBER,
                         p_receipt_date  IN DATE,
                         p_reservation_action IN VARCHAR2 DEFAULT NULL --<R12 PLAN CROSS DOCK>
                        ,p_ordered_uom        IN VARCHAR2 DEFAULT NULL --5253916
                         ) RETURN BOOLEAN;


  -- Update mtl_supply for an Approve PO Action

  FUNCTION approve_po_supply(p_docid IN NUMBER) RETURN BOOLEAN;


  -- Update mtl_supply for an Approve Blanket Release Action

  FUNCTION approve_blanket_supply(p_docid IN NUMBER) RETURN BOOLEAN;


  -- Update mtl_supply for an Approve Planned Release Action

  FUNCTION approve_planned_supply(p_docid IN NUMBER) RETURN BOOLEAN;


  -- Create PO Supply

  FUNCTION create_po_supply(p_entity_id   IN NUMBER,
                            p_entity_type IN VARCHAR2) RETURN BOOLEAN;


  -- Delete Supply for PO Header or PO Release

  FUNCTION delete_supply(p_entity_id   IN NUMBER,
                         p_entity_type IN VARCHAR2) RETURN BOOLEAN;


  -- Update Supply for PO Line, Shipment or Release Shipment

  FUNCTION update_supply(p_entity_id   IN NUMBER,
                         p_entity_type IN VARCHAR2,
                         p_shipid      IN NUMBER DEFAULT 0) RETURN BOOLEAN;


  -- Cancel Supply for PO Header, Line or Shipment

  FUNCTION cancel_supply(p_entity_id   IN NUMBER,
                         p_entity_type IN VARCHAR2,
                         p_shipid      IN NUMBER DEFAULT 0) RETURN BOOLEAN;


  -- Cancel Planned Release or Planned Shipment

  FUNCTION cancel_planned(p_entity_id     IN NUMBER,
                          p_entity_type   IN VARCHAR2,
                          p_shipid        IN NUMBER DEFAULT 0,
                          p_recreate_flag IN BOOLEAN) RETURN BOOLEAN;


  -- Maintain mtl_supply

  FUNCTION maintain_mtl_supply RETURN BOOLEAN;


  -- Get Debug Information

  FUNCTION get_debug RETURN VARCHAR2;

 -- Create Requisition Header, Line Supply
 -- The following function will not check the authorization status.

  FUNCTION create_req(p_entity_id   IN NUMBER,
                      p_entity_type IN VARCHAR2) RETURN BOOLEAN;

  --<Bug 2752584 mbhargav>
  FUNCTION explode(p_lineid IN NUMBER) RETURN BOOLEAN;

END PO_SUPPLY;

/
