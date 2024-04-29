--------------------------------------------------------
--  DDL for Package QA_FLEX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_FLEX_UTIL" AUTHID CURRENT_USER AS
/* $Header: qltutlfb.pls 120.3.12000000.1 2007/01/19 07:20:02 appldev ship $ */

--
-- The following two functions mimic item() and locator(), but do not
-- generate exception if ID is not found.  This emulates outer
-- join condition.  Used by qa_results_full_v for 21 CFR Part 11
-- Compliance project (ERES).  Tracking bug 3071511.
--
FUNCTION item2(p_org_id NUMBER, p_item_id NUMBER) RETURN VARCHAR2;
FUNCTION locator2(p_org_id NUMBER, p_locator_id NUMBER) RETURN VARCHAR2;

FUNCTION item(x_org_id number, x_item_id number) return varchar2;
FUNCTION get_item_id (x_org_id number, x_item VARCHAR2) return NUMBER;
-- anagarwa Wed Sep 19 17:49:08 PDT 2001
PROCEDURE get_item_category_val (p_org_id NUMBER,
                                 p_item_val VARCHAR2 default null,
                                 p_item_id NUMBER default null,
                                 x_category_val OUT NOCOPY VARCHAR2,
                                 x_category_id  OUT NOCOPY NUMBER);

FUNCTION locator(x_org_id number, x_locator_id number) return varchar2;
FUNCTION get_locator_id (x_org_id number, x_locator VARCHAR2) return NUMBER;

--
-- The following are APIs that facilitate performance tuning.  They
-- are mostly used in views to get rid of outer joins to complex tables.
--

--
-- Return project_number from pjm_projects_all_v given a project ID.
--
FUNCTION project_number(x_id number) RETURN varchar2;

--
-- Return Sales Order Number given a Sales Order ID.
--
FUNCTION sales_order(x_id number) RETURN varchar2;

--
-- Return RMA Number given a Sales Order ID.
--
FUNCTION rma_number(x_id number) RETURN number;

--
-- Return contract_number from oke_k_headers_full_v given a contract ID.
--
FUNCTION contract_number(x_id number) RETURN varchar2;

--
-- Return contract_line_number from oke_k_lines_full_v given a contract line ID.
--
FUNCTION contract_line_number(x_id number) RETURN varchar2;

--
-- Return deliverable_number from oke_k_deliverables_vl given a deliverable ID.
--
FUNCTION deliverable_number(x_id number) RETURN varchar2;


FUNCTION work_order (x_org_id NUMBER, x_work_order_id number)
        RETURN VARCHAR2;

--
-- Return the result_column_name from qa_plan_chars given a plan_id
-- and a char_id.  Return null if not found.
--
FUNCTION qpc_result_column_name(x_plan_id number, x_char_id number)
    RETURN varchar2;

--
-- Return qpc_values_exist_flag (an integer) from qa_plan_chars given a
-- plan_id and a char_id.  Return null if not found.
--
FUNCTION qpc_values_exist_flag(x_plan_id number, x_char_id number)
    RETURN number;

    cached_qpc_plan_id number := -1;
    cached_qpc_char_id number := -1;
    cached_qpc_result_column_name varchar2(60);
    cached_qpc_values_exist_flag number;


--
-- Return plan_id from qa_criteria_headers given a criteria_id.
-- Return null if not found.
--
FUNCTION qch_plan_id(x_criteria_id number) RETURN number;

--
-- Return description from mtl_categories_kfv given category_id.
-- Return null if not found.
--
FUNCTION mtl_categories_description(x_category_id number) RETURN varchar2;


--
-- Derive project id given an LPN.  Used internally.
-- bso Wed Mar 13 16:53:35 PST 2002
--
FUNCTION get_project_id_from_lpn(
    p_org_id NUMBER,
    p_lpn_id NUMBER) RETURN NUMBER;

--
-- Derive task id given an LPN.  Used internally.
-- bso Wed Mar 13 16:53:35 PST 2002
--
FUNCTION get_task_id_from_lpn(
    p_org_id NUMBER,
    p_lpn_id NUMBER) RETURN NUMBER;



--
-- Derive project number given an LPN.  Used by WMS/QA mobile integration.
-- See /qadev/qa/51.0/11.5.8/wms_pjm_dld.txt
-- bso Wed Mar 13 16:53:35 PST 2002
--
PROCEDURE get_project_number_from_lpn(
    p_org_id NUMBER,
    p_lpn_id NUMBER,
    x_project_number OUT NOCOPY VARCHAR2);


--
-- Derive task number given an LPN.  Used by WMS/QA mobile integration.
-- See /qadev/qa/51.0/11.5.8/wms_pjm_dld.txt
-- bso Wed Mar 13 16:53:35 PST 2002
--
PROCEDURE get_task_number_from_lpn(
    p_org_id NUMBER,
    p_lpn_id NUMBER,
    x_task_number OUT NOCOPY VARCHAR2);


FUNCTION get_vendor_site_id(p_vendor_site VARCHAR2) RETURN NUMBER;

--
-- Return project ID from pjm_projects_all_v given a project number.
--
FUNCTION get_project_id(p_project_number VARCHAR2) RETURN NUMBER;

--
-- Return task ID from mtl_task_v given a project ID and task number.
--
FUNCTION get_task_id(p_project_id NUMBER,p_task_number VARCHAR2) RETURN NUMBER;


-- Bug 3096256.
-- This procedures returns the Subinventory of an LPN given the LPN_ID
-- from wms_license_plate_numbers. This procedure is called from
-- getSubinventoryFromLPN() method in ContextElementTable.java.
-- For RCV/WMS Enhancements. kabalakr Mon Aug 25 04:12:48 PDT 2003.

PROCEDURE get_subinventory_from_lpn(
            p_lpn_id NUMBER,
            x_subinventory OUT NOCOPY VARCHAR2);


-- Bug 3096256.
-- This procedures returns the Locator of an LPN given the LPN_ID
-- from wms_license_plate_numbers. This procedure is called from
-- getLocatorFromLPN() method in ContextElementTable.java.
-- For RCV/WMS Enhancements. kabalakr Mon Aug 25 04:12:48 PDT 2003.

PROCEDURE get_locator_from_lpn(
            p_org_id NUMBER,
            p_lpn_id NUMBER,
            x_locator OUT NOCOPY VARCHAR2);

--dgupta: Start R12 EAM Integration. Bug 4345492
FUNCTION get_asset_group_name (org_id IN NUMBER, value IN NUMBER)
    RETURN VARCHAR2;
--dgupta: End R12 EAM Integration. Bug 4345492

--pragma restrict_references (default,WNDS);


 --
 --  Bug 4958739. R12 Performance fixes.
 --  New utility function for getting qa_lookup meaning.
 --  srhariha. Mon Jan 30 01:25:38 PST 2006
 --
 FUNCTION get_qa_lookups_meaning (p_lookup_type IN VARCHAR2,
                                  p_lookup_code IN VARCHAR2)
                                                 RETURN VARCHAR2;

 --
 --  Bug 5279941.
 --  New utility function for getting the asset instance
 --  name from the asset instance Number
 --  ntungare Wed Jun 21 01:45:43 PDT 2006
 --
 FUNCTION get_asset_instance_name (p_asset_instance_number IN VARCHAR2)
    RETURN VARCHAR2;

end QA_FLEX_UTIL;

 

/
