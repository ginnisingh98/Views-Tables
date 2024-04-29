--------------------------------------------------------
--  DDL for Package MSC_X_CVMI_REPLENISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_CVMI_REPLENISH" AUTHID CURRENT_USER AS
/* $Header: MSCXCFVS.pls 120.1 2005/12/12 02:49:12 shwmathu noship $ */

-- constants used for SCE order type code
REPLENISHMENT CONSTANT NUMBER := 19;
REQUISITION CONSTANT NUMBER := 20;
SUPPLY_SCHEDULE CONSTANT NUMBER := 2;
ALLOCATED_ONHAND CONSTANT NUMBER := 9;
UNALLOCATED_ONHAND CONSTANT NUMBER := 10;
ASN CONSTANT NUMBER := 15;
SHIPMENT_RECEIPT CONSTANT NUMBER := 16;
PURCHASE_ORDER CONSTANT NUMBER := 13;
CONSUMPTION_ADVICE CONSTANT NUMBER := 28;

CP_PLAN_ID CONSTANT NUMBER := -1;
INTERNAL_REQ CONSTANT NUMBER := 30;
INTERNAL_SALES_ORDER CONSTANT NUMBER := 29;
SALES_ORDER CONSTANT NUMBER := 14;
SYS_YES CONSTANT NUMBER := 1;
SYS_NO CONSTANT NUMBER := 2;
FUTURE_DATE CONSTANT NUMBER := 30000;
VMI_PLANNING_METHOD CONSTANT NUMBER := 7;
NOT_EXISTS NUMBER := -1;
REFRESHED NUMBER := 1;
NOT_REFRESHED NUMBER := 0;

UNRELEASED CONSTANT NUMBER := 0;
RELEASED CONSTANT NUMBER := 1;
REJECTED CONSTANT NUMBER := 2;

VMI_PLAN_ID CONSTANT NUMBER := -1;
REORDER_POINT_CODE CONSTANT NUMBER := 1;
MIN_MAX_CODE CONSTANT NUMBER := 2;
AUTO_RELEASE_YES CONSTANT NUMBER := 1;

CUSTOMER_OF  CONSTANT NUMBER  := 1;
COMPANY_MAPPING CONSTANT NUMBER := 1;
ORGANIZATION_MAPPING CONSTANT NUMBER := 2;
SITE_MAPPING CONSTANT NUMBER := 3;

OEM_COMPANY_ID CONSTANT NUMBER := 1;
UNCONSIGNED CONSTANT NUMBER := 2;
CONSIGNED CONSTANT NUMBER := 1;

TYPE number_arr   IS TABLE of NUMBER;
TYPE date_arr     IS TABLE of DATE;

TYPE ordernumList IS TABLE OF msc_sup_dem_entries.order_number%TYPE;
TYPE releasenumList  IS TABLE OF msc_sup_dem_entries.release_number%TYPE;
TYPE linenumList  IS TABLE OF    msc_sup_dem_entries.line_number%TYPE;
TYPE companynameList IS TABLE of msc_companies.company_name%TYPE;
TYPE companysitenameList is TABLE of msc_company_sites.company_site_name%TYPE;
TYPE itemnameList is TABLE of msc_items.item_name%TYPE;
TYPE uomcodeList is TABLE of msc_system_items.uom_code%TYPE;
TYPE itemdescriptionList is TABLE of msc_system_items.description%TYPE;
-- TYPE suppliercontactList is TABLE of msc_planners.user_name%TYPE;
TYPE plannerCodeList is TABLE of msc_system_items.planner_code%TYPE;
-- TYPE customercontactList is TABLE of msc_partner_contacts.name%TYPE;

-- This procedure will be called by Concurrent Program to perform
-- SCE VMI replenishment
  PROCEDURE vmi_replenish_concurrent
    (
     p_replenish_time_fence IN NUMBER DEFAULT 1
    );

  -- This procedure is associated with the 'Create Replenishment' Workflow
  -- activity and will create a VMI replenishment if there is a shortage
  -- of supply
  PROCEDURE vmi_replenish(l_last_max_refresh_number IN NUMBER,
			  l_repl_time_fence IN NUMBER);


  -- This procesure prints out message to user
  PROCEDURE vmi_reject
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  );

PROCEDURE is_auto_release
  (
   itemtype  in varchar2
   , itemkey   in varchar2
   , actid     in number
   , funcmode  in varchar2
   , resultout out nocopy varchar2
   );

PROCEDURE Is_Supplier_Approval
	  (
	   itemtype  in varchar2
	   , itemkey   in varchar2
	   , actid     in number
	   , funcmode  in varchar2
	   , resultout out nocopy varchar2
	   );

	PROCEDURE vmi_release_api
	  (   p_inventory_item_id IN NUMBER
	    , p_sr_instance_id IN NUMBER
	    , p_supplier_id IN NUMBER
	    , p_supplier_site_id IN NUMBER
	    , p_customer_id IN NUMBER
	    , p_customer_site_id IN NUMBER
	    , p_release_quantity IN NUMBER
	    , p_uom IN VARCHAR2
	    , p_sr_inventory_item_id IN NUMBER
	    , p_customer_model_org_id IN NUMBER
	    , p_source_org_id IN NUMBER
	    , p_request_date IN DATE
	    , p_consigned_flag IN NUMBER
	    , p_vmi_release_type IN NUMBER
        , p_item_name VARCHAR2
        , p_item_describtion VARCHAR2
        , p_customer_name VARCHAR2
        , p_customer_site_name VARCHAR2
        , p_uom_code VARCHAR2
		, p_vmi_minimum_units IN OUT NOCOPY NUMBER
		, p_vmi_maximum_units IN OUT NOCOPY NUMBER
		, p_vmi_minimum_days NUMBER
		, p_vmi_maximum_days NUMBER
		, p_average_daily_demand NUMBER
		, p_ORDER_NUMBER  IN VARCHAR2       --Consigned CVMI Enh
		, p_RELEASE_NUMBER IN VARCHAR2
		, p_LINE_NUMBER  IN VARCHAR2
		, p_END_ORDER_NUMBER  IN VARCHAR2
		, p_END_ORDER_REL_NUMBER  IN VARCHAR2
		, p_END_ORDER_LINE_NUMBER  IN VARCHAR2
		, p_source_org_name  IN VARCHAR2
		, p_order_type IN VARCHAR2
	    );

PROCEDURE vmi_release_api_ui
  ( p_rep_transaction_id IN NUMBER
  , p_release_quantity IN NUMBER
  );

PROCEDURE vmi_release_api_load
  ( p_header_id IN NUMBER
  );

PROCEDURE vmi_replenish_wf
  (
      p_rep_transaction_id IN NUMBER
    , p_inventory_item_id IN NUMBER
    , p_supplier_id IN NUMBER
    , p_supplier_site_id IN NUMBER
    , p_sr_instance_id IN NUMBER
    , p_customer_id IN NUMBER
    , p_customer_site_id IN NUMBER
    , p_vmi_minimum_units IN NUMBER
    , p_vmi_maximum_units IN NUMBER
    , p_vmi_minimum_days IN NUMBER
    , p_vmi_maximum_days IN NUMBER
    , p_so_authorization_flag IN NUMBER
    , p_consigned_flag IN NUMBER
    , p_planner_code IN VARCHAR2 -- , p_supplier_contact IN VARCHAR2
    -- , p_customer_contact IN VARCHAR2
    , p_supplier_item_name IN VARCHAR2
    , p_supplier_item_desc IN VARCHAR2
    , p_customer_item_name IN VARCHAR2
    , p_customer_item_desc IN VARCHAR2
    , p_supplier_name IN VARCHAR2
    , p_supplier_site_name IN VARCHAR2
    , p_customer_name IN VARCHAR2
    , p_customer_site_name IN VARCHAR2
    , p_order_quantity IN VARCHAR2
    , p_onhand_quantity IN VARCHAR2
    , p_time_fence_multiplier IN NUMBER
    , p_time_fence_end_date IN VARCHAR2
    , p_uom IN VARCHAR2
    , p_source_so_org_id IN NUMBER
    , p_modeled_customer_org_id IN NUMBER
    , p_vmi_release_type IN NUMBER
    , p_sr_inventory_item_id IN NUMBER
    );

PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  );

  PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  );

PROCEDURE reset_vmi_refresh_flag;

END MSC_X_CVMI_REPLENISH;

 

/
