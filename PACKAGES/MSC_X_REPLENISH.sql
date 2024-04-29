--------------------------------------------------------
--  DDL for Package MSC_X_REPLENISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_REPLENISH" AUTHID CURRENT_USER AS
/* $Header: MSCXSFVS.pls 120.2 2008/02/25 10:34:08 hbinjola ship $ */

-- constants used for SCE order type code
REPLENISHMENT CONSTANT NUMBER := 19;
REQUISITION CONSTANT NUMBER := 20;
SUPPLY_SCHEDULE CONSTANT NUMBER := 2;
ALLOCATED_ONHAND CONSTANT NUMBER := 9;
UNALLOCATED_ONHAND CONSTANT NUMBER := 10;
ASN CONSTANT NUMBER := 15;
SHIPMENT_RECEIPT CONSTANT NUMBER := 16;
PURCHASE_ORDER CONSTANT NUMBER := 13;

-- constants used for replenishment status
UNRELEASED CONSTANT NUMBER := 0;
RELEASED CONSTANT NUMBER := 1;
REJECTED CONSTANT NUMBER := 2;

VMI_PLAN_ID CONSTANT NUMBER := -1;
REORDER_POINT_CODE CONSTANT NUMBER := 1;
MIN_MAX_CODE CONSTANT NUMBER := 2;
AUTO_RELEASE_YES CONSTANT NUMBER := 1;

COMPANY_MAPPING CONSTANT NUMBER := 1;
ORGANIZATION_MAPPING CONSTANT NUMBER := 2;
SITE_MAPPING CONSTANT NUMBER := 3;

OEM_COMPANY_ID CONSTANT NUMBER := 1;

-- This procedure will be called by Concurrent Program to perform
-- VMI replenishment
PROCEDURE vmi_replenish_wrapper
  ( errbuf OUT NOCOPY VARCHAR2
    , retcode OUT NOCOPY VARCHAR2
    , p_supplier_replenish_flag IN VARCHAR2
    , p_supplier_time_fence IN NUMBER
    , p_customer_replenish_flag IN VARCHAR2
    , p_customer_time_fence IN NUMBER
    );

  -- This procedure will be called by Concurrent Program to perform
  -- SCE VMI replenishment
  PROCEDURE vmi_replenish_concurrent
    ( p_supplier_time_fence IN NUMBER
    );

  -- This procedure will start the Workflow process for VMI replenishment
  PROCEDURE vmi_replenish_wf
    ( p_supplier_time_fence IN NUMBER
    , p_inventory_item_id IN NUMBER
    , p_organization_id IN NUMBER
    , p_plan_id IN NUMBER
    , p_sr_instance_id IN NUMBER
    , p_supplier_id IN NUMBER
    , p_supplier_site_id IN NUMBER
    );

  -- This procedure is associated with the 'Create Replenishment' Workflow
  -- activity and will create a VMI replenishment if there is a shortage
  -- of supply
  PROCEDURE vmi_replenish
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This procedure is associated with the 'Release Replenishment' Workflow
  -- activity and will create a VMI requsition if there is a shortage
  -- of supply
  PROCEDURE vmi_release
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This procedure is associated with the 'Reject Replenishment' Workflow
  -- activity and will change the replenishment status from 0 (unrealeased)
  -- to 2 (rejected)
  PROCEDURE vmi_reject
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This function is used to check if an item is a VMI item
  FUNCTION is_vmi_item (
      p_inventory_item_id IN NUMBER
    , p_organization_id IN NUMBER
    , p_plan_id IN NUMBER
    , p_sr_instance_id IN NUMBER
    , p_supplier_id IN NUMBER DEFAULT NULL
    , p_supplier_site_id IN NUMBER DEFAULT NULL
    ) RETURN BOOLEAN;

  -- This procedure is associated with the 'Is Auto Release' Workflow
  -- activity
  PROCEDURE is_auto_release
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This procedure is associated with the 'Is Auto Release' Workflow
  -- activity
  PROCEDURE is_seller_approve
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

  -- This procesure prints out debug info.
  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

  -- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

  FUNCTION aps_to_sce(
      p_tp_key IN NUMBER
    , p_map_type IN NUMBER
    , p_sr_instance_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION sce_to_aps(
      p_company_key IN NUMBER
    , p_map_type IN NUMBER
    ) RETURN NUMBER;

  PROCEDURE create_requisition
  ( p_item_id                   NUMBER
  , p_quantity                 NUMBER
  , p_need_by_date             VARCHAR2
  , p_customer_id                NUMBER
  , p_customer_site_id         NUMBER
  , p_supplier_id                  NUMBER
  , p_supplier_site_id           NUMBER
  , p_uom_code VARCHAR2 DEFAULT NULL
  , p_error_msg         out nocopy varchar2
  , p_sr_instance_id       NUMBER  DEFAULT NULL
  );

PROCEDURE temp_tables;
  --This is to create temp tables.

  END MSC_X_REPLENISH;

/
