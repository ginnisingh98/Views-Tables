--------------------------------------------------------
--  DDL for Package Body WMS_RULES_WORKBENCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULES_WORKBENCH_PVT" AS
/* $Header: WMSRLWBB.pls 120.16.12010000.5 2009/08/21 05:50:01 kjujjuru ship $ */

-- File        : WMSRLWBS.pls
-- Content     : WMS_RULES_WORKBENCH_PVT package spec
-- Description : This API is created  to handle all the procedures, function variables to be used by Rules WorkBench

-- Notes       :
-- List of  Pl/SQL Tables,Functions and  Procedures --------------------------
-- procedure send_msg_to_pipe(p_debug_mode in Boolean, p_message in VARCHAR2)
-- function get_return_type_name(p_org_id number ,p_rule_type_code in number, p_return_type_code in varchar2, p_return_type_id in number) return varchar2;
-- function get_customer_name(p_customer_id in number) return  varchar2;
-- function get_organization_code(p_organization_id in number) return varchar2;
-- function get_freight_code_name(p_org_id in number ,p_freight_code in varchar2 ) return varchar2;
-- function get_item(p_org_id in number , p_inventory_item_id in number) return varchar2;
-- function get_abc_group_class_name(p_org_id in number , p_assignment_group_id in number, p_abc_class_id in number) return varchar2;
-- function get_category_set_name(p_org_id in number , p_category_set_id in number, p_category_id in number) return varchar2;
-- function get_order_type_name(p_transaction_type_id in number) return varchar2;
-- function get_project_name(p_project_id in number) return varchar2;
-- function get_task_name(p_project_id in number , p_task_id in number) return varchar2;
-- function get_vendor_name(p_org_id in number, p_vendor_id in number) return varchar2;
-- function get_vendor_site(p_org_id in number, p_vendor_id in number, p_vendor_site_id in number) return varchar2;
-- function get_user_name(p_user_id in number) return varchar2;
-- function get_transaction_action_name(p_transaction_action_id in number) return varchar2;
-- function get_reason_name(p_reason_id in number) return varchar2;
-- function get_transaction_source_name(p_transaction_source_type_id in number) return varchar2;
-- function get_transaction_type_name(p_transaction_type_id in number ) return varchar2;
-- function get_unit_of_measure(p_uom_code in varchar2) return varchar2;
-- function get_uom_class_name(p_uom_class in varchar2) return varchar2;
-- function get_item_type_name(p_item_type_code in varchar2) return varchar2;
-- procedure Search()
-- Function get_item_type( p_org_id IN NUMBER,p_inventory_item_id IN NUMBER )  	 return VARCHAR2;
-- Function Item_Category
-- Function get_uom_class( p_uom_code IN VARCHAR2) 				 return VARCHAR2;
-- Function get_vendor_id( p_reference IN VARCHAR2, p_reference_id  IN NUMBER)    return NUMBER;
-- Function get_order_type_id( p_move_order_line_id IN NUMBER) return NUMBER;
-- procedure send_msg_to_pipe(p_debug_mode in Boolean, p_message in VARCHAR2);
-- Procedure get_customer_freight_details()
-----------------------------------------------------------------------------

g_pkg_name constant varchar2(30) := 'WMS_Rules_workbench_pvt';
l_debug               NUMBER;

--
--Procedures for logging messages
PROCEDURE log_event(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace(p_message, l_module, 9);
END log_event;

PROCEDURE log_error(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace(p_message, l_module, 9);

END log_error;

PROCEDURE log_error_msg(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace('', l_module, 9);

END log_error_msg;

PROCEDURE log_procedure(
        p_api_name      VARCHAR2,
        p_label         VARCHAR2,
        p_message       VARCHAR2) IS

l_module VARCHAR2(255);

BEGIN
  l_module := g_pkg_name || p_label;
  inv_log_util.trace(p_message, l_module, 9);

END log_procedure;

---- Function to get Return type name ( Strategy / Rule name )
----          to be used in the view wms_selection_criteria_txn_v

Function get_return_type_name(p_org_id IN NUMBER,
                    p_rule_type_code   IN NUMBER,
                    p_return_type_code IN VARCHAR2,
                    p_return_type_id   IN NUMBER)
Return VARCHAR2 is

g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
l_api_name constant VARCHAR2(30)   := 'GET_RETURN_TYPE_NAME';

l_return_type_name VARCHAR2(80)    := NULL;


 BEGIN
   IF (p_return_type_code = 'V' ) then
	 IF(p_rule_type_code = 10) THEN
		 SELECT criterion_name
		    INTO l_return_type_name
		 FROM wms_crossdock_criteria_vl
		 WHERE  criterion_id=p_return_type_id
		 AND criterion_type = 1  ;
	    return l_return_type_name;
	 ELSIF (p_rule_type_code = 11) THEN
		 SELECT criterion_name
		    INTO l_return_type_name
		 FROM wms_crossdock_criteria_vl
		 WHERE  criterion_id=p_return_type_id
		 AND criterion_type = 2;
	    return l_return_type_name;
	 ELSIF (p_rule_type_code = 5) THEN
		SELECT cost_group
		INTO l_return_type_name
		FROM  CST_COST_GROUPS
		WHERE cost_group_id=p_return_type_id
		AND organization_id = p_org_id;
  	   return l_return_type_name;
	 ELSIF (p_rule_type_code = 12) THEN  -- Bug : 6682436
      SELECT meaning
      INTO l_return_type_name
      FROM mfg_lookups_v
      WHERE lookup_type = 'WMS_CARTONIZATION_ALGORITHMS'
      AND lookup_code = p_return_type_id;
	   return l_return_type_name;
    END IF;

   ELSIF (p_return_type_code = 'S' ) then

      select distinct name into l_return_type_name
        from wms_strategies_vl
       where organization_id in (p_org_id, -1)
          and type_code   = p_rule_type_code
          and strategy_id = p_return_type_id;
      return l_return_type_name;
  ElSIF (p_return_type_code = 'R') THEN
        select name into l_return_type_name
        from wms_rules_vl
       where organization_id in (p_org_id, -1)
         and rule_id = p_return_type_id;
      return l_return_type_name;
   ELSE
        l_return_type_name := '';
  End If;
       return l_return_type_name;
 Exception
    When others then
       Return  null;
 End get_return_type_name;

----- Function to get customer name, used in sthe view
-----

 Function get_customer_name(p_customer_id IN NUMBER)
 Return  VARCHAR2 is
 /* TCA changes : replaced ra_customer by
    hz_parties party,
    hz_cust_accounts cust_acct
 */
  g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
  l_api_name constant VARCHAR2(30)   := 'GET_CUSTOMER_NAME';

  l_customer_name  HZ_PARTIES.PARTY_NAME%TYPE := NULL;
Begin

 /*select rc.customer_name
   into l_customer_name
        from ra_customers      rc
        where rc.customer_id  = p_customer_id;*/

/*   SELECT  distinct substrb ( PARTY.PARTY_NAME,  1,  50 )
     INTO l_customer_name
     FROM HZ_PARTIES PARTY,
          HZ_CUST_ACCOUNTS CUST_ACCT
   WHERE  CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
    AND  PARTY.PARTY_ID = p_customer_id;   */


    SELECT  distinct substrb ( PARTY.PARTY_NAME,  1,  50 )
     INTO l_customer_name
     FROM HZ_PARTIES PARTY,
          HZ_CUST_ACCOUNTS CUST_ACCT
   WHERE  CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
    AND CUST_ACCT.CUST_ACCOUNT_ID  = p_customer_id;

 Return l_customer_name;
 Exception
     When others then
      Return  null;
End get_customer_name;

----------

---  function to get the organization_code based on the organization_id
---
Function get_organization_code(p_organization_id IN NUMBER)
Return VARCHAR2 is

g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
l_api_name constant VARCHAR2(30)   := 'GET_ORGANIZATION_CODE';

l_organization_code VARCHAR2(30)   := NULL;

Begin

select ood.organization_code
  into l_organization_code
          from org_organization_definitions ood
         where sysdate < nvl(ood.disable_date,sysdate+1)
           and ood.organization_id = p_organization_id ;

 Return  l_organization_code;
 exception
     when others then
      return  null;

End get_organization_code;
----------------------
-----
Function get_freight_code_name(p_org_id       IN NUMBER,
                               p_freight_code IN VARCHAR2 )
 Return VARCHAR2 is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_FREIGHT_CODE_NAME';

 l_freight_code_name VARCHAR2(30);

Begin
 select ofv.freight_code_tl
  into l_freight_code_name
   from org_freight ofv
  where ofv.organization_id = p_org_id
    and ofv.freight_code    = p_freight_code
    and sysdate < nvl(ofv.disable_date,sysdate+1);

  Return l_freight_code_name;

 Exception
     When others then
          Return  null;
End get_freight_code_name;

---------
---
Function get_item(p_org_id            IN NUMBER,
                  p_inventory_item_id IN NUMBER)
Return VARCHAR2 is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_ITEM';

 l_item 	     VARCHAR2(80);

Begin

select msik.concatenated_segments into l_item
from mtl_system_items_kfv msik
where msik.organization_id = p_org_id
  and msik.inventory_item_id = p_inventory_item_id;

Return l_item;
 Exception
     When others then
          Return  null;
End get_item;
---
---

Function get_abc_group_class(p_org_id 			IN NUMBER,
                             p_assignment_group_id 	IN NUMBER,
                             p_class_id 		IN NUMBER )
  Return VARCHAR2 is

  g_pkg_name constant 	VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
  l_api_name constant 	VARCHAR2(30)   := ' GET_ASSIGNMENT_GROUP_CLASS';

  l_abc_group_class     	VARCHAR2(500) := '';

Begin

      select maag.assignment_group_name||' / '|| mac.abc_class_name
        into l_abc_group_class
      from mtl_abc_classes mac,
           mtl_abc_assignment_groups maag ,
           MTL_ABC_ASSGN_GROUP_CLASSES magc
      where  maag.organization_id 	= mac.organization_id
        and  magc.assignment_group_id 	= maag.assignment_group_id
        and  magc.abc_class_id 		= mac.abc_class_id
        and  mac.organization_id 	= p_org_id
        and  maag.assignment_group_id 	= p_assignment_group_id
        and  mac.abc_class_id 		= p_class_id ;

    Return   l_abc_group_class;

 Exception
     When others then
       Return  null;
End get_abc_group_class;
---
---
Function get_category_set_name(p_org_id 		IN NUMBER,
			       p_category_set_id 	IN NUMBER,
			       p_category_id 		IN NUMBER)
Return VARCHAR2  is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_CATEGORY_SET_NAME';

 l_category_set_name VARCHAR2(500)   :=  NULL;

Begin

/*
 Select mcs.category_set_name||' / '||mck.concatenated_segments into l_category_set_name
   From mtl_categories_kfv mck
       ,mtl_category_sets_vl mcs
       ,mtl_category_set_valid_cats mcsvc
  Where mcs.category_set_id = mcsvc.category_set_id
    and mck.category_id = mcsvc.category_id
    and mcsvc.category_set_id = p_category_set_id
    and mcsvc.category_id =  p_category_id; */

-- Bug # 3271041

SELECT mcs.CATEGORY_SET_NAME||' / '|| mck.CONCATENATED_SEGMENTS  into l_category_set_name
    FROM MTL_CATEGORIES_KFV mck
    ,MTL_CATEGORIES_VL mc
    ,MTL_CATEGORY_SETS_VL mcs
    ,( SELECT mic.ORGANIZATION_ID
    ,mic.CATEGORY_SET_ID
    ,mic.CATEGORY_ID
    FROM MTL_ITEM_CATEGORIES mic
    WHERE mic.ORGANIZATION_ID = p_org_id
    GROUP BY mic.ORGANIZATION_ID
    ,mic.CATEGORY_SET_ID
    ,mic.CATEGORY_ID ) x
    WHERE mcs.CATEGORY_SET_ID = x.CATEGORY_SET_ID
    AND mc.CATEGORY_ID = mck.CATEGORY_ID
    AND mck.CATEGORY_ID = x.CATEGORY_ID
    AND x.CATEGORY_SET_ID = p_category_set_id
    AND x.CATEGORY_ID =  p_category_id;

    Return l_category_set_name;

 Exception
     When others then
          Return  null;
End get_category_set_name;
---------------------
---------------------
Function get_order_type_name(p_transaction_type_id in number)
  Return VARCHAR2  is

 g_pkg_name constant   VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant   VARCHAR2(30)   := 'GET_ORDER_TYPE_NAME';

 l_order_type_name     VARCHAR2(80)   := NULL;

Begin

select ottv.name into l_order_type_name
  from oe_transaction_types_vl ottv
 where ottv.transaction_type_id = p_transaction_type_id;

Return l_order_type_name;
 Exception
     When others then
         Return  null;
End get_order_type_name;
----
----
Function get_project_name(p_project_id IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_PROJECT_NAME';

 l_project_name      VARCHAR2(80)   := NULL;

Begin

 select  distinct ppov.project_name into l_project_name
  from pjm_projects_mtll_v ppov
 where ppov.project_id = p_project_id;

Return l_project_name;
 Exception
     When others then
        Return  null;
End get_project_name;
----
---
Function get_task_name(p_project_id IN NUMBER ,
                       p_task_id    IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_TASK_NAME';

 l_task_name  VARCHAR2(80)          := NULL;

Begin

 -------------------
 SELECT  nvl(p.project_number, '') || ' / ' || nvl(ptev.TASK_NUMBER, '')   into l_task_name
 FROM  pjm_tasks_mtll_v  ptev,  pjm_projects_mtll_v p
 where p.project_id = ptev.project_id
   and ptev.project_id  =  p_project_id
   and ptev.task_id  = p_task_id;
 -------------
/* select ppev.project_name||' / '||ptev.indented_task_name
  into l_task_name
  from pa_tasks_expend_v ptev
      ,pa_projects_expend_v ppev
 where ptev.project_id = ppev.project_id
   and ppev.project_id = p_project_id
   and ptev.task_id    = p_task_id; */

Return l_task_name;
 Exception
     When others then
          Return  null;
End get_task_name;
---------
--------
Function get_vendor_name(p_org_id 	IN NUMBER,
                         p_vendor_id 	IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant VARCHAR2(30)   := 'GET_VENDOR_NAME';

 l_vendor_name       VARCHAR2(80)   := NULL;

Begin

  SELECT  pv.vendor_name
    INTO  l_vendor_name
    FROM PO_VENDORS pv
	,PO_VENDOR_SITES_ALL pvsa
	,ORG_ORGANIZATION_DEFINITIONS ood
   WHERE ood.ORGANIZATION_ID =  p_org_id
     AND nvl(pvsa.ORG_ID,-99) = nvl(ood.OPERATING_UNIT,-99)
     AND pvsa.PURCHASING_SITE_FLAG = 'Y'
     AND sysdate < nvl(pvsa.INACTIVE_DATE, sysdate + 1)
     AND pv.VENDOR_ID = pvsa.VENDOR_ID
     AND pvsa.vendor_id  = p_vendor_id
   GROUP BY pv.VENDOR_NAME;

Return l_vendor_name ;
 Exception
     When others then
        Return  null;
End get_vendor_name;
-------

---
Function get_user_name(p_user_id IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant VARCHAR2(50)   := 'wms_selection_criteria_pvt';
 l_api_name constant VARCHAR2(30)   := 'get_user_name';

 l_user_name         VARCHAR2(80)   := NULL;

Begin

  select fu.user_name
    into l_user_name
    from fnd_user fu
   where sysdate < nvl(fu.end_date,sysdate+1)
     and fu.user_id = p_user_id;

   Return l_user_name;
 Exception
     When others then
          Return  null;
End get_user_name;
---
---
Function get_transaction_action_name(p_transaction_action_id IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant 		VARCHAR2(50)   	:= 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 		VARCHAR2(30)   	:= 'GET_TRANSACTION_ACTION_NAME';

 l_transaction_action_name 	VARCHAR2(80) 	:= NULL;

Begin

 select ml.meaning
   into l_transaction_action_name
   from mfg_lookups ml
  where ml.lookup_type = 'MTL_TRANSACTION_ACTION'
    and ml.lookup_code = p_transaction_action_id ;

 Return l_transaction_action_name;

 Exception
     when others then
          Return  null;
END get_transaction_action_name;
---
---
Function get_reason_name(p_reason_id IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant 	VARCHAR2(50)   	:= 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 	VARCHAR2(30)   	:= 'GET_REASON_NAME';

 l_reason_name 	 	VARCHAR2(80)  	:= NULL;

Begin

  select mtr.reason_name
    into l_reason_name
  from mtl_transaction_reasons mtr
  where sysdate < nvl(mtr.disable_date,sysdate+1)
    and mtr.reason_id = p_reason_id;

Return l_reason_name;
 Exception
     When others then
      Return  null;
End get_reason_name;
---
---
Function get_transaction_source_name(p_transaction_source_type_id IN NUMBER)
  Return VARCHAR2  is

 g_pkg_name constant 		VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 		VARCHAR2(30)   := 'GET_TRANSACTION_SOURCE_NAME';

 l_transaction_source_name     VARCHAR2(80)   :=  NULL;

Begin

   select mtst.transaction_source_type_name
     into l_transaction_source_name
     from mtl_txn_source_types mtst
    where sysdate < nvl(mtst.disable_date,sysdate+1)
      and mtst.transaction_source_type_id =  p_transaction_source_type_id;

   Return l_transaction_source_name ;
 Exception
     when others then
          Return  null;
End get_transaction_source_name;
---
---
Function get_transaction_type_name(p_transaction_type_id IN NUMBER )
  Return VARCHAR2  is

 g_pkg_name constant 		VARCHAR2(50)   	:= 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 		VARCHAR2(30)   	:= 'GET_TRANSACTION_TYPE_NAME';

 l_transaction_type_name  	VARCHAR2(80)  	:=  NULL;

Begin

  select mtt.transaction_type_name
    into l_transaction_type_name
    from mtl_transaction_types mtt
   where sysdate < nvl(mtt.disable_date,sysdate+1)
     and mtt.transaction_type_id =  p_transaction_type_id;

Return l_transaction_type_name;

 Exception
     When others then
          return  null;
End get_transaction_type_name;
---
---
Function get_unit_of_measure(p_uom_code IN VARCHAR2)
  Return VARCHAR2  is

 g_pkg_name constant 	VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 	VARCHAR2(30)   := 'GET_UNIT_OF_MEASURE';

 l_unit_of_measure   	VARCHAR2(80)   := NULL;

Begin

 select muom.unit_of_measure_tl
   into l_unit_of_measure
 from mtl_units_of_measure muom
where sysdate < nvl(muom.disable_date,sysdate+1)
  and muom.uom_code =  p_uom_code;

Return l_unit_of_measure ;
 Exception
     When others then
          Return  null;
End get_unit_of_measure;
----
----
Function get_uom_class_name(p_uom_class IN VARCHAR2)
  Return VARCHAR2  is

 g_pkg_name constant 	 VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 	 VARCHAR2(30)   := 'GET_UOM_CLASS_NAME';

 l_UOM_class_name        VARCHAR2(80)   :=  NULL;

Begin

  select muc.uom_class_tl
    into l_uom_class_name
    from mtl_uom_classes muc
    where muc.uom_class = p_uom_class;

Return l_uom_class_name ;
 Exception
     When others then
       Return  null;
End get_uom_class_name;
---
---

Function get_item_type_name(p_item_type_code IN VARCHAR2)
  Return VARCHAR2 is

 g_pkg_name constant 	 VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
 l_api_name constant 	 VARCHAR2(30)   := 'GET_ITEM_TYPE';

 l_item_type             VARCHAR2(80)   :=  NULL;

Begin
 select ml.meaning into l_item_type
   from fnd_common_lookups ml
where ml.lookup_type = 'ITEM_TYPE'
  and ml.lookup_code = p_item_type_code;

Return l_item_type;
 Exception
     When others then
          Return  null;
End get_item_type_name;
----------
----------
procedure Search
  ( p_api_version          IN   	NUMBER
   ,p_init_msg_list        IN   	VARCHAR2
   ,p_validation_level     IN   	NUMBER
   ,x_return_status        OUT  NOCOPY	VARCHAR2
   ,x_msg_count            OUT  NOCOPY	NUMBER
   ,x_msg_data             OUT  NOCOPY	VARCHAR2
   ,p_transaction_temp_id  IN   NUMBER
   ,p_type_code            IN   NUMBER
   ,x_return_type          OUT  NOCOPY	VARCHAR2
   ,x_return_type_id       OUT  NOCOPY	NUMBER
   ,p_organization_id      IN   	NUMBER
   ,x_sequence_number      OUT  NOCOPY  NUMBER
   )  is

   g_pkg_name constant 	 VARCHAR2(50)    := 'WMS_SELECTION_CRITERIA_PVT';
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name constant 	 VARCHAR2(30)    := 'SEARCH';

   l_debug_mode  	 BOOLEAN := inv_pp_debug.is_debug_mode;


   l_rec_wsct   WMS_SELECTION_CRITERIA_TXN%ROWTYPE;
   l_rec_mtrl   MTL_TXN_REQUEST_LINES%ROWTYPE;


   l_sequence_number 		wms_selection_criteria_txn.sequence_number%type;
   l_return_type_code		wms_selection_criteria_txn.return_type_code%type;
   l_return_type_id		wms_selection_criteria_txn.return_type_id%type;
   l_from_organization_id	wms_selection_criteria_txn.from_organization_id%type;
   l_from_subinventory_name	wms_selection_criteria_txn.from_subinventory_name%type default null;
   l_to_organization_id      	wms_selection_criteria_txn.to_organization_id%type;
   l_to_subinventory_name	wms_selection_criteria_txn.to_subinventory_name%type;
   l_customer_id 		wms_selection_criteria_txn.customer_id%type;
   l_freight_code 		wms_selection_criteria_txn.freight_code%type;
   l_inventory_item_id 		wms_selection_criteria_txn.inventory_item_id%type;
   l_item_type 			wms_selection_criteria_txn.item_type%type;
   l_order_type_id		wms_selection_criteria_txn.order_type_id%type;
   l_vendor_id			wms_selection_criteria_txn.vendor_id%type;
   l_project_id			wms_selection_criteria_txn.project_id%type;
   l_task_id			wms_selection_criteria_txn.task_id%type;
   l_user_id			wms_selection_criteria_txn.user_id%type;
   l_transaction_action_id	wms_selection_criteria_txn.transaction_action_id%type;
   l_reason_id 			wms_selection_criteria_txn.reason_id%type;
   l_transaction_source_type_id wms_selection_criteria_txn.transaction_source_type_id%type;
   l_transaction_type_id	wms_selection_criteria_txn.transaction_type_id%type;
   l_uom_code 			wms_selection_criteria_txn.uom_code%type;
   l_uom_class			wms_selection_criteria_txn.uom_class%type default null;

   l_return_value		BOOLEAN;

    --8809951 start
   l_category_id    wms_selection_criteria_txn.category_id%type;
   l_category_set_id  wms_selection_criteria_txn.category_set_id%type;
   l_assignment_group_id  wms_selection_criteria_txn.assignment_group_id%type;
   l_abc_class_id  wms_selection_criteria_txn.abc_class_id%type;
   TYPE mtrl_line_tabtype IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   mtrl_line_tab mtrl_line_tabtype;

 CURSOR SIMILAR_MTRL_LINES IS
      SELECT line_id FROM MTL_TXN_REQUEST_LINES mtrl1
              WHERE line_id IN (
	     /*The sub query is to filter out the eligible records with the constant values that we have so that the
             PL/SQL function calls like get_order_type(), get_item_type() etc will have to be executed only for the eligible records )	*/
		                     select mtrl.line_id
			              from mtl_txn_request_lines mtrl
			              where mtrl.header_id                       = l_rec_mtrl.header_id
			               AND mtrl.organization_id                   = l_from_organization_id
			               AND NVL(mtrl.from_subinventory_code,'###') =
				                 NVL(l_from_subinventory_name,NVL(mtrl.from_subinventory_code,'###'))
			               AND NVL(mtrl.to_organization_id ,-999)     = NVL(l_to_organization_id, NVL(mtrl.to_organization_id,-999))
			               AND NVL(mtrl.to_subinventory_code, '###')  = NVL(l_to_subinventory_name, NVL(mtrl.to_subinventory_code,'###'))
			               AND mtrl.inventory_item_id             = NVL(l_inventory_item_id , mtrl.inventory_item_id )
			               AND NVL(mtrl.project_id ,-999)         = NVL(l_project_id , NVL(mtrl.project_id ,-999) )
			               AND NVL(mtrl.task_id  ,-999)           = NVL(l_task_id , NVL(mtrl.task_id  ,-999) )
			               AND NVL(mtrl.reason_id ,-999)          = NVL(l_reason_id ,NVL(mtrl.reason_id ,-999)  )
			               AND mtrl.transaction_source_type_id    = NVL(l_transaction_source_type_id,mtrl.transaction_source_type_id)
			               AND mtrl.transaction_type_id           = NVL(l_transaction_type_id,mtrl.transaction_type_id)
			               AND NVL(mtrl.uom_code,'##')            = NVL(l_uom_code ,nvl(mtrl.uom_code,'##'))
			               AND mtrl.last_updated_by	              = NVL(l_user_id, mtrl.last_updated_by)
		                     )
	              AND EXISTS (SELECT  1
                            FROM wsh_delivery_details wdd,
                            wsh_carriers wc,
                            wsh_carrier_services wcs
                            WHERE wdd.move_order_line_id = mtrl1.line_id
                            AND   wdd.move_order_line_id is NOT NULL
                            AND   wdd.ship_method_code = wcs.ship_method_code (+)
                            AND   wcs.carrier_id       = wc.carrier_id (+)
                            AND   Nvl(wdd.customer_id,-999) = Nvl(l_customer_id, -999)
                            AND   NVL(wc.freight_code,'###') = NVL(l_freight_code,'###')
                            )
	              AND NVL(WMS_RULES_WORKBENCH_PVT.get_item_type(mtrl1.organization_id,mtrl1.inventory_item_id),'###') =
									  NVL(l_item_type,'###')
	              AND NVL(WMS_RULES_WORKBENCH_PVT.get_uom_class(mtrl1.uom_code),'##') = NVL(l_uom_class,'##' )
                AND NVL(WMS_RULES_WORKBENCH_PVT.get_order_type_id(mtrl1.line_id),-999) = NVL(l_order_type_id ,-999)
	             AND (mtrl1.transaction_source_type_id <> 1 OR
     	              NVL(WMS_RULES_WORKBENCH_PVT.get_vendor_id(mtrl1.reference,mtrl1.reference_id),-999) =
									  NVL(l_vendor_id,-999)
	                  )
	              AND (l_category_id IS NULL  OR WMS_RULES_WORKBENCH_PVT.get_Item_Cat(mtrl1.organization_id,
									              mtrl1.inventory_item_id,
									              l_category_set_id,
									              l_category_id )='Y'
	                  )
	              AND (l_abc_class_id IS NULL OR WMS_RULES_WORKBENCH_PVT.get_group_class(mtrl1.inventory_item_id,
									              l_assignment_group_id,
									              l_abc_class_id)='Y'
	                  );


   --8809951 end

    --- Cursor for Strategy /Rule /Value Selection based on the current move order line
    -- 8809951 Added columns for High Volume Project Phase-2
    cursor cur_stg_selection is
      select return_type_code
      ,return_type_id
      ,sequence_number
      ,from_subinventory_name
      ,	to_organization_id
      ,	to_subinventory_name
      ,	Nvl(customer_id,l_customer_id)    --8809951
      ,	Nvl(freight_code,l_freight_code)   --8809951
      , inventory_item_id
      , Nvl(item_type,l_item_type)     --8809951
      , Nvl(order_type_id,l_order_type_id)   --8809951
      , Nvl(vendor_id, l_vendor_id)   --8809951
      ,	project_id
      ,	task_id
      ,	user_id
      ,	transaction_action_id
      ,	reason_id
      ,	transaction_source_type_id
      ,	transaction_type_id
      ,	uom_code
      , Nvl(uom_class, l_uom_class) --8809951
      ,	category_id
      ,	category_set_id
      , assignment_group_id
      ,	abc_class_id
      from wms_selection_criteria_txn
     where  from_organization_id = l_from_organization_id
       	and rule_type_code = p_type_code
       	and enabled_flag = 1
       	and nvl(from_subinventory_name, l_from_subinventory_name) 	= l_from_subinventory_name
 	and nvl(to_organization_id, 	l_to_organization_id) 		= l_to_organization_id
 	and nvl(to_subinventory_name,	l_to_subinventory_name ) 	= l_to_subinventory_name
 	and nvl(customer_id,		l_customer_id) 			= l_customer_id
 	and nvl(freight_code,		l_freight_code) 		= l_freight_code
 	and nvl(inventory_item_id, 	l_inventory_item_id) 		= l_inventory_item_id
 	and nvl(item_type, 		l_item_type) 			= l_item_type
 	and nvl(order_type_id, 		l_order_type_id) 		= l_order_type_id
 	and nvl(vendor_id, 		l_vendor_id) 			= l_vendor_id
 	and nvl(project_id, 		l_project_id) 			= l_project_id
 	and nvl(task_id, 		l_task_id )			= l_task_id
 	and nvl(user_id, 		l_user_id ) 			= l_user_id
 	and nvl(transaction_action_id, 	l_transaction_action_id ) 	= l_transaction_action_id
 	and nvl(reason_id , 		l_reason_id ) 			= l_reason_id
 	and nvl(transaction_source_type_id, l_transaction_source_type_id) = l_transaction_source_type_id
 	and nvl(transaction_type_id, 	l_transaction_type_id) 		= l_transaction_type_id
 	and nvl(uom_code, 		l_uom_code) 			= l_uom_code
	and nvl(uom_class, 		l_uom_class) 			= l_uom_class
	and nvl(effective_from,to_date('01011900','ddmmyyyy')) 		<= trunc(sysdate)
        and nvl(effective_to,to_date('31124000','ddmmyyyy')) 		>= trunc(sysdate)
	and wms_datecheck_pvt.date_valid(l_from_organization_id,date_type_code,date_type_from,date_type_to,effective_from,effective_to) = 'Y' --Added bug 4081657
        and decode(category_id,null,'N', 'Y') =   decode(category_id,null,'N', WMS_RULES_WORKBENCH_PVT.get_Item_Cat(l_rec_mtrl.organization_id,
	                                                                                                            l_rec_mtrl.inventory_item_id,
	                              	                                                                            category_set_id,
	                              	                                                                            category_id )
	                              	                                                                            )
        and decode(abc_class_id,null,'N', 'Y') =  decode(abc_class_id,null,'N', WMS_RULES_WORKBENCH_PVT.get_group_class(l_rec_mtrl.inventory_item_id,
		                              	                                                 assignment_group_id,
		                              	                                                 abc_class_id)
		                              	                                                  )

	order by sequence_number;


    begin
          l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
           -- Bug #  2935052 -----
           -- Call custom-specific strategy search stub procedure
           wms_re_Custom_PUB.SearchForStrategy (
                            p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,p_transaction_temp_id
                           ,p_type_code
                           ,l_return_type_code
                           ,l_return_type_id
                           );
           -- leave the actual procedure, if stub procedure already found a strategy
        if    x_return_status = fnd_api.g_ret_sts_success then
                 if l_debug = 1 then
                    log_event(l_api_name, 'Custom Type is  found : ',l_return_type_code);
                    log_event(l_api_name, 'Custom Strategy/Rule/value found : ',l_return_type_id);
                 end if;

	         --- reassign the l_strategy_id to the new variables
	        x_return_type      := l_return_type_code;
		x_return_type_id   := l_return_type_id;
		x_sequence_number  := 0;

             return;
             -- leave the actual procedure, if stub procedure got an unexpected error
        elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
             raise fnd_api.g_exc_unexpected_error;
           -- continue strategy search, if stub procedure didn't find strategy already
        elsif x_return_status = fnd_api.g_ret_sts_error then
             -- Re-Initialize API return status to success
             x_return_status := fnd_api.g_ret_sts_success;
           -- every other return status seems to be unexpected: leave
        else
              fnd_message.set_name('WMS','WMS_INVALID_RETURN_STATUS');
              -- WMS_re_Custom_PUB.SearchForStrategy returned wrong status
              fnd_msg_pub.add;
              log_error_msg(l_api_name, 'bad_return_status');
              raise fnd_api.g_exc_unexpected_error;
       end if;
       --- end of Bug # 2935052 -----

       if l_debug = 1 then
          log_procedure(l_api_name,'','Start selection Criteria ');
	  log_event(l_api_name,'Move order line: ', p_transaction_temp_id);
       end if;
        -- Initialize message list if p_init_msg_list is set to TRUE
       if fnd_api.to_boolean( p_init_msg_list ) then
          fnd_msg_pub.initialize;
       end if;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

      -- Bug 5264987 - Fetching the MO_lines from the Cache instead of querying ,

	l_return_value := INV_CACHE.set_mol_rec(p_transaction_temp_id);
	IF NOT l_return_value THEN
		If l_debug = 1 THEN
			 log_event(l_api_name,'','Move order line cursor not found ');
		End If;
	raise fnd_api.g_exc_unexpected_error;
	END IF;
        log_event(l_api_name,'','test:Move order line fetched from cache');
	l_rec_mtrl := INV_CACHE.mol_rec;


      if l_debug = 1 then
         log_event(l_api_name,'','fetching move order line');
         log_event(l_api_name,'from org ', to_char(l_rec_mtrl.organization_id));
         log_event(l_api_name,'dest org ', to_char(l_rec_mtrl.organization_id));
      end if;

     If (l_return_value) Then
        --- For all the null values below, Functions need to be written
        ---
       if l_debug = 1then
          log_event(l_api_name,'','Setting all variables');
       end if;
    -- Bug #3178127
    -- modified the l_form_organization_id

     	l_from_organization_id		:= nvl(p_organization_id, l_rec_mtrl.organization_id);
     	l_from_subinventory_name	:= nvl(l_rec_mtrl.from_subinventory_code, 'aaa');
     	l_to_organization_id      	:= nvl(l_rec_mtrl.organization_id, -999);
     	l_to_subinventory_name		:= nvl(l_rec_mtrl.to_subinventory_code, 'aaa');
     	l_customer_id 			:= l_customer_id;
     	l_freight_code 			:= l_freight_code;
     	l_inventory_item_id 		:= nvl(l_rec_mtrl.inventory_item_id, -999);
     	l_item_type 			:= nvl(get_item_type( l_rec_mtrl.organization_id ,l_rec_mtrl.inventory_item_id), '1');
     	l_order_type_id			:= nvl(get_order_type_id( l_rec_mtrl.line_id), -999);
       	l_project_id			:= nvl(l_rec_mtrl.project_id, -999);
     	l_task_id			:= nvl(l_rec_mtrl.task_id, -999);
     	l_user_id			:= nvl(l_rec_mtrl.last_updated_by, -999);
     	l_transaction_action_id		:= -999;
     	l_reason_id 			:= nvl(l_rec_mtrl.reason_id, -999);
     	l_transaction_source_type_id 	:= nvl(l_rec_mtrl.transaction_source_type_id, -999);
     	l_transaction_type_id		:= nvl(l_rec_mtrl.transaction_type_id, -999);
     	l_uom_code 			:= nvl(l_rec_mtrl.uom_code, 'aaa');
     	l_uom_class			:= nvl(get_uom_class(l_rec_mtrl.uom_code), 'aaaaaaaaaa');

     	if l_debug = 1 then
     	   log_event(l_api_name,'','Setting of the variables is done');
     	   log_event(l_api_name,'','copy Vendor Id');
     	end if;

     	if ( l_rec_mtrl.transaction_source_type_id = 1) then
     	     l_VENDOR_ID := get_vendor_id(l_rec_mtrl.reference, l_rec_mtrl.reference_id);
     	end if;

        l_vendor_id := nvl(l_vendor_id, -999);

        ---- Setting  customer_id and freigth details
        if l_debug = 1 then
           log_event(l_api_name,'','Setting Customer_id and freight details ');
        end if;
        get_customer_freight_details(p_transaction_temp_id, l_customer_id, l_freight_code);

        l_customer_id := nvl(l_customer_id, -999);
        l_freight_code := nvl(l_freight_code, 'AAA');

        ------------ Setting Variables ---------------------------------------------------------
        if l_debug = 1 then
	   log_event(l_api_name,'l_from_organization_id         ',l_from_organization_id);
	   log_event(l_api_name,'l_from_subinventory_name 	',l_from_subinventory_name);
	   log_event(l_api_name,'l_to_organization_id 		',l_to_organization_id);
	   log_event(l_api_name,'l_to_subinventory_name 	',l_to_subinventory_name);
	   log_event(l_api_name,'l_customer_id 	 		',l_customer_id 	);
	   log_event(l_api_name,'l_freight_code 	 	',l_freight_code 	);
	   log_event(l_api_name,'l_inventory_item_id 		',l_inventory_item_id );
	   log_event(l_api_name,'l_item_type 			',l_item_type );
	   log_event(l_api_name,'l_order_type_id 		',l_order_type_id);
	   log_event(l_api_name,'l_project_id 			',l_project_id);
	   log_event(l_api_name,'l_task_id			',l_task_id);
	   log_event(l_api_name,'l_user_id 			',l_user_id);
	   log_event(l_api_name,'l_transaction_action_id 	',l_transaction_action_id);
	   log_event(l_api_name,'l_reason_id  			',l_reason_id );
	   log_event(l_api_name,'l_reason_id 			',l_reason_id );
	   log_event(l_api_name,'l_transaction_source_type_id 	',l_transaction_source_type_id );
	   log_event(l_api_name,'l_transaction_type_id	 	',l_transaction_type_id	);
	   log_event(l_api_name,'l_uom_code			',l_uom_code);
	   log_event(l_api_name,'l_uom_class			',l_uom_class);
	   log_event(l_api_name,'l_VENDOR_ID			',l_VENDOR_ID);

        end if;
       ------------------------------------------------------------------------------------------
        -- 8809951 Added columns for High Volume Project Phase-2
	OPEN cur_stg_selection;
        FETCH cur_stg_selection
        INTO
	l_return_type_code,
        l_return_type_id,
        l_sequence_number,
        l_from_subinventory_name,
        l_to_organization_id,
        l_to_subinventory_name,
        l_customer_id,
        l_freight_code,
        l_inventory_item_id,
        l_item_type,
        l_order_type_id,
        l_vendor_id,
        l_project_id,
        l_task_id,
        l_user_id,
        l_transaction_action_id,
        l_reason_id,
        l_transaction_source_type_id,
        l_transaction_type_id,
        l_uom_code,
        l_uom_class,
        l_category_id,
        l_category_set_id,
        l_assignment_group_id,
        l_abc_class_id;

        If (cur_stg_selection%NOTFOUND) Then
            --3224420close cur_stg_selection;
            if l_debug = 1 then
               log_event(l_api_name,'','stg_selection cursor not found ');
            end if;
             l_return_type_code := NULL;
             l_return_type_id   := NULL;
             l_sequence_number  := NULL;
             x_return_status := fnd_api.g_ret_sts_success;

             --- setting global variables used by Rules simulator and trace execution forms
             IF  p_type_code = 1 THEN
	     	 wms_search_order_globals_pvt.g_putaway_strategy_id 	:= -999;
	     	 wms_search_order_globals_pvt.g_putaway_seq_num 	:= -999;
	     ELSIF p_type_code = 2 THEN
	     	 wms_search_order_globals_pvt.g_pick_strategy_id 	:= -999;
	     	 wms_search_order_globals_pvt.g_pick_seq_num 		:= -999;
	     ELSIF p_type_code = 5 THEN
	     	   wms_search_order_globals_pvt.g_costgroup_strategy_id := -999;
	     	   wms_search_order_globals_pvt.g_costgroup_seq_num     := -999;
             END IF; --- end of globol variables section
         End if;

         If (cur_stg_selection%FOUND) Then

             if l_debug =1 then
                log_event(l_api_name,'',' Open/fetching stg_selection cursor');
             end if;

             x_return_type      := l_return_type_code;
             x_return_type_id   := l_return_type_id;
             x_sequence_number  := l_sequence_number;
             x_return_status := fnd_api.g_ret_sts_success;

             --- setting global variables used by Rules simulator and trace execution forms

	     IF  l_return_type_code = 'S' THEN
	         IF  p_type_code = 1 THEN
	  	     wms_search_order_globals_pvt.g_putaway_strategy_id := l_return_type_id;
	  	     wms_search_order_globals_pvt.g_putaway_seq_num := l_sequence_number;

		    -- 8809951 start
		    OPEN SIMILAR_MTRL_LINES;
                    FETCH SIMILAR_MTRL_LINES BULK COLLECT INTO mtrl_line_tab;
                    CLOSE SIMILAR_MTRL_LINES;

                    FORALL i IN mtrl_line_tab.first..mtrl_line_tab.last
                    UPDATE mtl_txn_request_lines
                    SET put_away_strategy_id = l_return_type_id
                    WHERE line_id = mtrl_line_tab(i);

                    -- 8809951 end


	         ELSIF p_type_code = 2 THEN
	  	     wms_search_order_globals_pvt.g_pick_strategy_id := l_return_type_id;
	  	     wms_search_order_globals_pvt.g_pick_seq_num := l_sequence_number;

		     -- 8809951 start
	             OPEN SIMILAR_MTRL_LINES;
                    FETCH SIMILAR_MTRL_LINES BULK COLLECT INTO mtrl_line_tab;
                    CLOSE SIMILAR_MTRL_LINES;

                    FORALL i IN mtrl_line_tab.first..mtrl_line_tab.last
                    UPDATE mtl_txn_request_lines
                    SET pick_strategy_id = l_return_type_id
                    WHERE line_id = mtrl_line_tab(i);

                     -- 8809951 end

	         ELSIF p_type_code = 5 THEN
	   	   wms_search_order_globals_pvt.g_costgroup_strategy_id := l_return_type_id;
	  	   wms_search_order_globals_pvt.g_costgroup_seq_num := l_sequence_number;
                 ELSIF p_type_code = 10 THEN
                    NULL;
                 ELSIF p_type_code = 11 THEN
	       	     NULL;
                 END IF;

	    ELSIF  l_return_type_code = 'R' THEN
	         IF  p_type_code = 1 THEN
	  	     wms_search_order_globals_pvt.g_putaway_rule_id := l_return_type_id;
	  	     wms_search_order_globals_pvt.g_putaway_seq_num := l_sequence_number;

	         ELSIF p_type_code = 2 THEN
	  	     wms_search_order_globals_pvt.g_pick_rule_id := l_return_type_id;
	  	     wms_search_order_globals_pvt.g_pick_seq_num := l_sequence_number;

	         ELSIF p_type_code = 5 THEN
	   	   wms_search_order_globals_pvt.g_costgroup_rule_id := l_return_type_id;
	  	   wms_search_order_globals_pvt.g_costgroup_seq_num := l_sequence_number;
                 ELSIF p_type_code = 10 THEN
			NULL;
                 ELSIF p_type_code = 11 THEN
			NULL;
                 END IF;
  	   ELSIF  l_return_type_code = 'V' THEN

	  	 IF p_type_code = 5 THEN
	   	   wms_search_order_globals_pvt.g_costgroup_id := l_return_type_id;
	  	   wms_search_order_globals_pvt.g_costgroup_seq_num := l_sequence_number;
                 ELSIF p_type_code = 10 THEN
			NULL;
                 ELSIF p_type_code = 11 THEN
			NULL;
                 END IF;

           END IF;

	     --- end of globol variables section

             if l_debug = 1 then
                log_event(l_api_name,'Strategy / Rule =>',l_return_type_code);
                log_event(l_api_name,'Strategy Id / Rule Id  => ' ,l_return_type_id);
             end if;

             If cur_stg_selection%ISOPEN then
                CLOSE cur_stg_selection;
             End if;
       END If;
       If cur_stg_selection%ISOPEN then
                 CLOSE cur_stg_selection;
       End if; --added for 3224420

      End if;
      Exception

       WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
          If cur_stg_selection%ISOPEN then
              CLOSE cur_stg_selection;
           End if;


          fnd_msg_pub.Count_And_Get
             ( p_count => x_msg_count
               ,p_data => x_msg_data);
               log_error(l_api_name, 'error', 'Error in selection Criteria - ' ||
      		x_msg_data);
            --
       WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

         If cur_stg_selection%ISOPEN then
              CLOSE cur_stg_selection;
          End if;

          fnd_msg_pub.Count_And_Get
              ( p_count => x_msg_count
               ,p_data => x_msg_data);
            log_error(l_api_name, 'unexp_error', 'Unexpected error ' ||
		'in selection Criteria - ' || x_msg_data);
       WHEN OTHERS THEN
           if l_debug = 1 then
               log_event(l_api_name,'',' Exception in selection Criteria');
           end if;
           x_return_status := fnd_api.g_ret_sts_unexp_error;

         If cur_stg_selection%ISOPEN then
              CLOSE cur_stg_selection;
           End if;

          if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
                  fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
          end if;
   End Search;
  ----------
  ----------
  procedure cg_mmtt_search
    ( p_api_version          IN   		NUMBER
     ,p_init_msg_list        IN   		VARCHAR2
     ,p_validation_level     IN   		NUMBER
     ,x_return_status        OUT  NOCOPY	VARCHAR2
     ,x_msg_count            OUT  NOCOPY	NUMBER
     ,x_msg_data             OUT  NOCOPY	VARCHAR2
     ,p_transaction_temp_id  IN   		NUMBER
     ,p_type_code            IN   		NUMBER
     ,x_return_type          OUT  NOCOPY	VARCHAR2
     ,x_return_type_id       OUT  NOCOPY	NUMBER
     ,p_organization_id      IN   		NUMBER
     ,x_sequence_number      OUT  NOCOPY        NUMBER
     )  is

     g_pkg_name constant 	 VARCHAR2(50)    := 'WMS_SELECTION_CRITERIA_PVT';
     l_api_version         	 CONSTANT NUMBER := 1.0;
     l_api_name constant 	 VARCHAR2(30)    := 'CG_MMTT_SEARCH';

     l_debug_mode  	 	 BOOLEAN := inv_pp_debug.is_debug_mode;

     l_rec_wsct   WMS_SELECTION_CRITERIA_TXN%ROWTYPE;
    -- l_rec_mtrl   MTL_TXN_REQUEST_LINES%ROWTYPE;

      TYPE rec_mmtt is RECORD (
        line_id  		 mtl_material_transactions_temp.transaction_temp_id%TYPE,
        organization_id 	 mtl_material_transactions_temp.organization_id%TYPE,
        inventory_item_id  	 mtl_material_transactions_temp.inventory_item_id%TYPE,
        revision                 mtl_material_transactions_temp.revision%TYPE,
        from_subinventory_code 	 mtl_material_transactions_temp.subinventory_code%TYPE,
        to_subinventory_code 	 mtl_material_transactions_temp.subinventory_code%TYPE,
        uom_code      		 mtl_material_transactions_temp.transaction_uom%TYPE,
        reason_id                mtl_material_transactions_temp.reason_id%TYPE,
        project_id               mtl_material_transactions_temp.project_id%TYPE,
        task_id                  mtl_material_transactions_temp.task_id%type,
        transaction_type_id      mtl_material_transactions_temp.transaction_type_id%TYPE,
        transaction_source_type_id mtl_material_transactions_temp.transaction_source_type_id%TYPE,
        to_organization_id       mtl_material_transactions_temp.organization_id%TYPE,
        reference                mtl_material_transactions_temp.transaction_reference%TYPE,
	reference_id             mtl_material_transactions_temp.rcv_transaction_id%TYPE,
	transaction_action_id    mtl_material_transactions_temp.transaction_action_id%TYPE,
        last_updated_by          mtl_material_transactions_temp.last_updated_by%TYPE
      );

     l_rec_mtrl rec_mmtt;

     l_sequence_number 		wms_selection_criteria_txn.sequence_number%type;
     l_return_type_code		wms_selection_criteria_txn.return_type_code%type;
     l_return_type_id		wms_selection_criteria_txn.return_type_id%type;
     l_from_organization_id	wms_selection_criteria_txn.from_organization_id%type;
     l_from_subinventory_name	wms_selection_criteria_txn.from_subinventory_name%type default null;
     l_to_organization_id      	wms_selection_criteria_txn.to_organization_id%type;
     l_to_subinventory_name	wms_selection_criteria_txn.to_subinventory_name%type;
     l_customer_id 		wms_selection_criteria_txn.customer_id%type;
     l_freight_code 		wms_selection_criteria_txn.freight_code%type;
     l_inventory_item_id 	wms_selection_criteria_txn.inventory_item_id%type;
     l_item_type 		wms_selection_criteria_txn.item_type%type;
     l_order_type_id		wms_selection_criteria_txn.order_type_id%type;
     l_vendor_id		wms_selection_criteria_txn.vendor_id%type;
     l_project_id		wms_selection_criteria_txn.project_id%type;
     l_task_id			wms_selection_criteria_txn.task_id%type;
     l_user_id			wms_selection_criteria_txn.user_id%type;
     l_transaction_action_id	wms_selection_criteria_txn.transaction_action_id%type;
     l_reason_id 		wms_selection_criteria_txn.reason_id%type;
     l_transaction_source_type_id wms_selection_criteria_txn.transaction_source_type_id%type;
     l_transaction_type_id	wms_selection_criteria_txn.transaction_type_id%type;
     l_uom_code 		wms_selection_criteria_txn.uom_code%type;
     l_uom_class		wms_selection_criteria_txn.uom_class%type default null;

      --- Cursor for Strategy /Rule /Value Selection based on the current move order line
      --
      cursor cur_stg_selection is
        select return_type_code, return_type_id, sequence_number
        from wms_selection_criteria_txn
      where  from_organization_id = l_from_organization_id
       	and rule_type_code = p_type_code
       	and enabled_flag = 1
   	and nvl(from_subinventory_name, l_from_subinventory_name) 	= l_from_subinventory_name
   	and nvl(to_organization_id, 	l_to_organization_id) 		= l_to_organization_id
   	and nvl(to_subinventory_name,	l_to_subinventory_name ) 	= l_to_subinventory_name
   	and nvl(customer_id,		l_customer_id) 			= l_customer_id
   	and nvl(freight_code,		l_freight_code) 		= l_freight_code
   	and nvl(inventory_item_id, 	l_inventory_item_id) 		= l_inventory_item_id
   	and nvl(item_type, 		l_item_type) 			= l_item_type
     	and nvl(order_type_id, 		l_order_type_id) 		= l_order_type_id
   	and nvl(vendor_id, 		l_vendor_id) 			= l_vendor_id
   	and nvl(project_id, 		l_project_id) 			= l_project_id
   	and nvl(task_id, 		l_task_id )			= l_task_id
   	and nvl(user_id, 		l_user_id ) 			= l_user_id
   	and nvl(transaction_action_id, 	l_transaction_action_id ) 	= l_transaction_action_id
   	and nvl(reason_id , 		l_reason_id ) 			= l_reason_id
   	and nvl(transaction_source_type_id, l_transaction_source_type_id) = l_transaction_source_type_id
   	and nvl(transaction_type_id, 	l_transaction_type_id) 		= l_transaction_type_id
   	and nvl(uom_code, 		l_uom_code) 			= l_uom_code
  	and nvl(uom_class, 		l_uom_class) 			= l_uom_class
  	and nvl(effective_from,to_date('01011900','ddmmyyyy')) 		<= trunc(sysdate)
        and nvl(effective_to,to_date('31124000','ddmmyyyy')) 		>= trunc(sysdate)
	and wms_datecheck_pvt.date_valid(l_from_organization_id,date_type_code,date_type_from,date_type_to,effective_from,effective_to) = 'Y' --Added bug 4081657
        and decode(category_id,null, 'N', 'Y') =   decode(category_id, null, 'N', WMS_RULES_WORKBENCH_PVT.get_Item_Cat(l_rec_mtrl.organization_id,
	                                                                                                              l_rec_mtrl.inventory_item_id ,
	                              	                                                                              category_set_id,
	                              	                                                                              category_id ))
  	and decode(abc_class_id,null,'N', 'Y') =   decode(abc_class_id,null,'N',  WMS_RULES_WORKBENCH_PVT.get_group_class(l_rec_mtrl.inventory_item_id,
												                          assignment_group_id,
												                          abc_class_id))
  	order by sequence_number;

         --- Cursor to fetch all the values for the current MMTT record
         cursor cur_mmt is
           SELECT
  	    mmtt.transaction_temp_id ,
            mmtt.organization_id,
  	    mmtt.inventory_item_id,
  	    mmtt.revision,
  	    decode(  mmtt.transaction_action_id,
  	           1,mmtt.subinventory_code,
  	           2,mmtt.subinventory_code,
  	           3,mmtt.subinventory_code,
  	           21,mmtt.subinventory_code,
  	           28,mmtt.subinventory_code,
  	           29,mmtt.subinventory_code,
  	           32,mmtt.subinventory_code,
  	           34,mmtt.subinventory_code,
                   NULL),
   	    decode(transaction_action_id, 1,
                                    NULL, 2,
                   transfer_subinventory, 3,
                   transfer_subinventory, 21,
                                NULL, 28,
                   transfer_subinventory,
                                      29, NULL, 32, NULL,34, NULL, subinventory_code),
  	    mmtt.transaction_uom,
  	    mmtt.reason_id,
  	    mmtt.project_id,
  	    mmtt.task_id,
  	    mmtt.transaction_type_id,
  	    mmtt.transaction_source_type_id,
  	    decode(mmtt.transaction_action_id, 3, mmtt.transfer_organization, 21, mmtt.transfer_organization, mmtt.organization_id),
  	    mmtt.transaction_reference,
	    decode(mmtt.source_code,'RCV', mmtt.rcv_transaction_id,to_number(NULL)),
	    mmtt.transaction_action_id,
  	    mmtt.last_updated_by
  	    from mtl_material_transactions_temp mmtt
  	    where mmtt.transaction_temp_id  = p_transaction_temp_id;

        begin
           l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
           -- Bug #  2935052 -----
	   -- Call custom-specific strategy search stub procedure
	   wms_re_Custom_PUB.SearchForStrategy (
			      p_init_msg_list
			     ,x_return_status
			     ,x_msg_count
			     ,x_msg_data
			     ,p_transaction_temp_id
			     ,p_type_code
			     ,l_return_type_code
			     ,l_return_type_id
			     );
	   -- leave the actual procedure, if stub procedure already found a strategy
	   if x_return_status = fnd_api.g_ret_sts_success then
              log_event(l_api_name,'custom Type is d', l_return_type_code);
	      log_event(l_api_name,'custom strategyRule/Value found', l_return_type_id);
	      --- reassign the l_strategy_id to the new variables
	      x_return_type      := l_return_type_code;
	      x_return_type_id   := l_return_type_id;
	      x_sequence_number  := 0;
	      return;
	     -- leave the actual procedure, if stub procedure got an unexpected error
	   elsif x_return_status = fnd_api.g_ret_sts_unexp_error then
	       raise fnd_api.g_exc_unexpected_error;
	     -- continue strategy search, if stub procedure didn't find strategy already
	   elsif x_return_status = fnd_api.g_ret_sts_error then
	       -- Re-Initialize API return status to success
	       x_return_status := fnd_api.g_ret_sts_success;
	     -- every other return status seems to be unexpected: leave
	   else
		fnd_message.set_name('WMS','WMS_INVALID_RETURN_STATUS');
		-- WMS_re_Custom_PUB.SearchForStrategy returned wrong status
		fnd_msg_pub.add;
		log_error_msg(l_api_name, 'bad_return_status');
		raise fnd_api.g_exc_unexpected_error;
	   end if;
	    ---- end of Bug # 2935052 -----
          if l_debug = 1 then
             log_event(l_api_name,'','Start');
             log_event(l_api_name,'MMTT line id: ', to_char(p_transaction_temp_id));
          end if;

          -- Initialize message list if p_init_msg_list is set to TRUE
          if fnd_api.to_boolean( p_init_msg_list ) then
              fnd_msg_pub.initialize;
          end if;
           -- Initialize API return status to success
          x_return_status := fnd_api.g_ret_sts_success;

          open cur_mmt;
          fetch cur_mmt into l_rec_mtrl;

          if l_debug = 1 then
             log_event(l_api_name,'','fetching MMTT  cursor ');
             log_event(l_api_name,'from org' , to_char(l_rec_mtrl.organization_id));
             log_event(l_api_name,'dest  org' ,to_char(l_rec_mtrl.to_organization_id));
          end if;

          If (cur_mmt%NOTFOUND) Then
              close cur_mmt;
          End if;

          If (cur_mmt%FOUND) Then
          --- For all the null values below, Functions need to be written
          ---
          if l_debug = 1 then
             log_event(l_api_name,'','Setting all variables');
          end if;

          --l_from_organization_id		:= nvl(l_rec_mtrl.organization_id, -999);
        l_from_organization_id          := nvl(p_organization_id, l_rec_mtrl.organization_id);
       	l_from_subinventory_name	:= nvl(l_rec_mtrl.from_subinventory_code, 'aaa');
       	l_to_organization_id      	:= nvl(l_rec_mtrl.to_organization_id, -999);
       	l_to_subinventory_name		:= nvl(l_rec_mtrl.to_subinventory_code, 'aaa');
       	l_customer_id 			:= -999;
       	l_freight_code 			:= 'XXX';
       	l_inventory_item_id 		:= nvl(l_rec_mtrl.inventory_item_id, -999);
       	l_item_type 			:= nvl(get_item_type( l_rec_mtrl.organization_id ,l_rec_mtrl.inventory_item_id), '1');
        l_order_type_id			:= nvl(get_order_type_id( l_rec_mtrl.line_id), -999);
        l_project_id			:= nvl(l_rec_mtrl.project_id, -999);
       	l_task_id			:= nvl(l_rec_mtrl.task_id, -999);
       	l_user_id			:= nvl(l_rec_mtrl.last_updated_by, -999);
       	l_transaction_action_id		:= nvl(l_rec_mtrl.transaction_action_id, -999);
       	l_reason_id 			:= nvl(l_rec_mtrl.reason_id, -999);
       	l_transaction_source_type_id 	:= nvl(l_rec_mtrl.transaction_source_type_id, -999);
       	l_transaction_type_id		:= nvl(l_rec_mtrl.transaction_type_id, -999);
       	l_uom_code 			:= nvl(l_rec_mtrl.uom_code, 'aaa');
       	l_uom_class			:= nvl(get_uom_class(l_rec_mtrl.uom_code), 'aaaaaaaaaa');
       	--
       	if ( l_rec_mtrl.transaction_source_type_id = 1) then
       	     l_VENDOR_ID := get_vendor_id(l_rec_mtrl.reference, l_rec_mtrl.reference_id);
       	end if;
        l_vendor_id := nvl(l_vendor_id, -999);

         --- Setting  customer_id and freigth details

        get_customer_freight_details(p_transaction_temp_id,
                                 l_customer_id    ,
                                 l_freight_code);

        l_customer_id := nvl(l_customer_id, -999);
        l_freight_code := nvl(l_freight_code, 'AAA');
        ------------- Setting Variables ---------------------------------------------------------
        if l_debug = 1 then
       	   log_event(l_api_name,'l_from_organization_id 		' ,l_from_organization_id);
       	   log_event(l_api_name,'l_from_subinventory_name 		' ,l_from_subinventory_name);
       	   log_event(l_api_name,'l_to_organization_id 		' ,l_to_organization_id);
       	   log_event(l_api_name,'l_to_subinventory_name 		' ,l_to_subinventory_name);
       	   log_event(l_api_name,'l_customer_id 	 		' ,l_customer_id 	);
	   log_event(l_api_name,'l_freight_code 	 		' ,l_freight_code 	);
      	   log_event(l_api_name,'l_inventory_item_id 		' ,l_inventory_item_id );
       	   log_event(l_api_name,'l_item_type 			' ,l_item_type );
       	   log_event(l_api_name,'l_order_type_id 			' ,l_order_type_id);
       	   log_event(l_api_name,'l_project_id 			' ,l_project_id);
       	   log_event(l_api_name,'l_task_id				' ,l_task_id);
       	   log_event(l_api_name,'l_user_id 			' ,l_user_id);
       	   log_event(l_api_name,'l_transaction_action_id 		' ,l_transaction_action_id);
       	   log_event(l_api_name,'l_reason_id  			' ,l_reason_id );
       	   log_event(l_api_name,'l_reason_id 			' ,l_reason_id );
       	   log_event(l_api_name,'l_transaction_source_type_id 	' ,l_transaction_source_type_id );
       	   log_event(l_api_name,'l_transaction_type_id	 	' ,l_transaction_type_id	);
       	   log_event(l_api_name,'l_uom_code			' ,l_uom_code);
       	   log_event(l_api_name,'l_uom_class			' ,l_uom_class);
       	   log_event(l_api_name,'l_vendor_id			' ,l_vendor_id);
       	 end if;
       	------------------------------------------------------------------------------------------

           OPEN cur_stg_selection;
           FETCH cur_stg_selection INTO  l_return_type_code, l_return_type_id, l_sequence_number;

            If (cur_stg_selection%NOTFOUND) Then
               --commenting out for 3224420 close cur_stg_selection;
               if l_debug = 1 then
                  log_event(l_api_name,'','stg_selection cursor not found ');
               end if;
               l_return_type_code := NULL;
               l_return_type_id   := NULL;
               l_sequence_number  := NULL;

               IF p_type_code = 5 THEN
	       	  wms_search_order_globals_pvt.g_costgroup_strategy_id := -999;
                  wms_search_order_globals_pvt.g_costgroup_seq_num     := -999;
               END IF;
               x_return_status := fnd_api.g_ret_sts_success;
           End if;

            If (cur_stg_selection%FOUND) Then
               x_return_type      := l_return_type_code;
               x_return_type_id   := l_return_type_id;
               x_sequence_number  := l_sequence_number;
               x_return_status := fnd_api.g_ret_sts_success;

               if l_debug = 1 then
                  log_event(l_api_name, '',' Open/fetching  stg_selection cursor');
               end if;
	       --- setting global variables used by Rules simulator and trace execution forms
	       IF p_type_code = 5 THEN
		        IF  l_return_type_code = 'S' THEN
			      wms_search_order_globals_pvt.g_costgroup_strategy_id := l_return_type_id;
			      wms_search_order_globals_pvt.g_costgroup_seq_num 	   := l_sequence_number;
			ELSIF( l_return_type_code = 'R' ) THEN
			     wms_search_order_globals_pvt.G_COSTGROUP_RULE_ID  := l_return_type_id;
			     wms_search_order_globals_pvt.g_costgroup_seq_num  := l_sequence_number;
			ELSIF( l_return_type_code = 'V' ) THEN
			      wms_search_order_globals_pvt.G_COSTGROUP_ID	   := l_return_type_id;
 			      wms_search_order_globals_pvt.g_costgroup_seq_num  := l_sequence_number;
			END IF;
		END IF;
                --- end of globol variables section
               if l_debug = 1 then
                  log_event(l_api_name,'Strategy / Rule =>' ,l_return_type_code);
                  log_event(l_api_name,'Strategy Id / Rule Id  => ' ,l_return_type_id);
               end if;
               IF cur_stg_selection%ISOPEN then
                  CLOSE cur_stg_selection;
               End if;
            End IF;
            IF cur_mmt%ISOPEN then
               CLOSE cur_mmt;
            End if;
	    IF (cur_stg_selection%ISOPEN) then
	     CLOSE cur_stg_selection;
	     END IF; --Added ofr 3224420
        End if;
        Exception
         WHEN fnd_api.g_exc_error THEN
              x_return_status := fnd_api.g_ret_sts_error;
             IF cur_mmt%ISOPEN then
                CLOSE cur_mmt;
             End if;

              IF cur_stg_selection%ISOPEN then
                 CLOSE cur_stg_selection;
              End if;
              fnd_msg_pub.Count_And_Get
                ( p_count => x_msg_count
                 ,p_data => x_msg_data);
              log_error(l_api_name, 'error', 'Error in selection Criteria - ' ||
        		x_msg_data);
         WHEN fnd_api.g_exc_unexpected_error THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF cur_mmt%ISOPEN then
                CLOSE cur_mmt;
             End if;

             IF cur_stg_selection%ISOPEN then
                 CLOSE cur_stg_selection;
              End if;
              fnd_msg_pub.Count_And_Get
                ( p_count => x_msg_count
                 ,p_data => x_msg_data);
              log_error(l_api_name, 'unexp_error', x_msg_data);
         WHEN OTHERS THEN
              IF cur_mmt%ISOPEN then
                CLOSE cur_mmt;
             End if;
              IF cur_stg_selection%ISOPEN then
                 CLOSE cur_stg_selection;
              End if;

            if l_debug = 1 then
             log_event(l_api_name,'',' Exception in selection Criteria');
            end if;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
                    fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            end if;
   End cg_mmtt_search;
   ---
   ---
     Function get_item_type( p_org_id 			IN NUMBER,
                             p_inventory_item_id 	IN NUMBER )
       Return VARCHAR2 is
        g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
        l_api_name constant VARCHAR2(30)   := 'GET_ITEM_TYPE';
        l_item_type  VARCHAR2(30) 	   := NULL;  --Bug#8367746 Changed size from 10 to 30
	l_return_value    BOOLEAN; -- 8809951

        begin
          if l_debug = 1 then
             log_event(l_api_name,' Enter' ,l_api_name);
          end if;

          -- 8809951 start
           l_return_value :=   inv_cache.set_item_rec(p_org_id,p_inventory_item_id);
	       IF NOT l_return_value THEN
		        If l_debug = 1 THEN
			        log_event(l_api_name,'','Item not found ');
		        END IF;
		      RAISE fnd_api.g_exc_unexpected_error;
	       END IF;

           l_item_type:=inv_cache.item_rec.item_type;
	   -- 8809951 end

	   if l_debug = 1 then
              log_event(l_api_name,'End','get_item_type');
           end if;
          return l_item_type;
        Exception
                When others then
                     Return  NULL;
     end get_item_type;

   ---
   ---

  Function get_item_cat( p_org_id IN NUMBER,
                         p_inventory_item_id IN NUMBER,
                         p_category_set_id   IN NUMBER,
                         p_category_id       IN NUMBER)
   return VARCHAR2 is
    g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
    l_api_name constant VARCHAR2(30)   := 'GET_ITEM_CATEGORY';
    l_category_exist    VARCHAR2(10)  := 'N';
    --8809951 start
    l_hash_value        NUMBER;
    l_hash_string       VARCHAR2(200);
    -- 8809951 end
   Begin

     if l_debug = 1 then
	log_event(l_api_name,'Enter ', l_api_name);
     end if;

     if ( p_org_id 		IS NOT NULL AND
	  p_inventory_item_id 	IS NOT NULL AND
	  p_category_set_id   	IS NOT NULL AND
	  p_category_id       	IS NOT NULL ) then

        -- 8809951 start
       l_hash_string := p_org_id || '-' || p_inventory_item_id || '-' || p_category_set_id  || '-' || p_category_id ;
       l_hash_value := DBMS_UTILITY.get_hash_value
	                                     (name      => l_hash_string
                		                     , base      => g_hash_base
                                         , hash_size => g_hash_size );

	IF g_item_cat_table.EXISTS(l_hash_value) THEN
	        l_category_exist    :=g_item_cat_table(l_hash_value);
        ELSE
   	      select 'Y' INTO l_category_exist
	          from mtl_item_categories mic
                    where mic.organization_id       = p_org_id
	              and mic.inventory_item_id = p_inventory_item_id
	              and mic.category_set_id   = p_category_set_id
	              and mic.category_id       = p_category_id
                and rownum<2;
		      g_item_cat_table(l_hash_value) := l_category_exist    ;
	 END IF;
     end if;
      -- 8809951 end
     Return l_category_exist;

   Exception
       When others then
       return   l_category_exist;
   End get_item_cat;
   ---
   ---
   Function get_group_class( p_inventory_item_id   IN NUMBER,
                             p_assignment_group_id IN NUMBER,
                             p_class_id 	   IN NUMBER ) return VARCHAR2 is
    g_pkg_name constant VARCHAR2(50)    := 'WMS_SELECTION_CRITERIA_PVT';
    l_api_name constant VARCHAR2(30)    := 'GET_GROUP_CLASS';
    l_group_class_exist    VARCHAR2(10) := 'N';

   Begin
     if l_debug = 1 then
	log_event(l_api_name,'Enter ',l_api_name);
     end if;

    if (  p_inventory_item_id 	IS NOT NULL AND
	  p_assignment_group_id IS NOT NULL AND
	  p_class_id      	IS NOT NULL ) then


       -- 8809951 Modified the query
      select 'Y' INTO l_group_class_exist FROM mtl_abc_assignments
	     where inventory_item_id    = p_inventory_item_id
	       and assignment_group_id  = p_assignment_group_id
	       and abc_class_id         = p_class_id;

    end if;

    return  l_group_class_exist ;

   Exception
    When others then
      return   l_group_class_exist ;
  End get_group_class;
   ---
   ----
       Function get_uom_class( p_uom_code IN VARCHAR2)
         Return VARCHAR2 is

            g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
	    l_api_name constant VARCHAR2(30)   := 'GET_UOM_CLASS';
	    l_uom_class         VARCHAR2(10)   := NULL;
	    -- 8809951 start
	    l_hash_value        NUMBER;
            l_hash_string       VARCHAR2(200);
	    -- 8809951 end
	    Begin
	       if l_debug = 1 then
	        log_event(l_api_name,' Enter',l_api_name);
	       end if;

	       -- 8809951 start
	       l_hash_string := p_uom_code;
  	       l_hash_value := DBMS_UTILITY.get_hash_value
	                                     (name      => l_hash_string
                		                     , base      => g_hash_base
                                         , hash_size => g_hash_size          );

	      IF g_uom_class_tbl.EXISTS(l_hash_value) THEN
	        l_uom_class    :=g_uom_class_tbl(l_hash_value);
              ELSE
	           select  muom.uom_class  into l_uom_class
	             from MTL_UNITS_OF_MEASURE muom
	            where  muom.uom_code = p_uom_code;
              END IF;
	      -- 8809951 end
               Return l_uom_class;
	     Exception
	        When others then
	     	     Return  null;
     End get_uom_class;

   ----
   ----
    Function get_vendor_id( p_reference 	IN VARCHAR2,
                            p_reference_id 	IN NUMBER)
      Return NUMBER is

     g_pkg_name constant VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
     l_api_name constant VARCHAR2(30)   := 'GET_VENDOR_ID';

     l_vendor_id         NUMBER   	:= NULL;

     Begin
           if l_debug = 1 then
            log_event(l_api_name,' Enter' ,l_api_name);
           end if;
           if (p_reference = 'PO_LINE_LOCATION_ID' ) then

            -- MOAC: _ALL tables replace views in next three select statements
            -- existing where clauses sufficient to stripe by OU

	    select   poh.vendor_id  into l_vendor_id
	     from po_headers_all poh,
	          po_lines_all pol,
	          po_line_locations_all pll
	              where poh.po_header_id = pol.po_header_id
	              and pll.po_header_id = pol.po_header_id
	              and pll.po_line_id   = pol.po_line_id
	              and pll.shipment_type = 'STANDARD'
                      and pll.line_location_id = p_reference_id ;

        elsif (p_reference = 'PO_DISTRIBUTION_ID' ) then
           select  poh.vendor_id  into l_vendor_id
	     from po_headers_all poh,
	          po_lines_all pol,
	          po_distributions_all pod,
	          po_line_locations_all pll
	              where poh.po_header_id = pol.po_header_id
	              and pll.po_header_id = pol.po_header_id
	              and pll.po_line_id   = pol.po_line_id
	              and pod.po_header_id = pll.po_header_id
	              and pod.po_line_id   = pll.po_line_id
	              and pod.line_location_id = pll.line_location_id
	              and pll.shipment_type = 'STANDARD'
                      and pod.po_distribution_id = p_reference_id;
         Else
             select  poh.vendor_id  into l_vendor_id
	       from po_headers_all poh,
	            po_lines_all pol,
	            rcv_transactions rct,
	            po_line_locations_all pll
	                where poh.po_header_id = pol.po_header_id
	                and pll.po_header_id = pol.po_header_id
	                and pll.po_line_id   = pol.po_line_id
	                and rct.po_header_id = pll.po_header_id
	                and rct.po_line_id   = pll.po_line_id
	                and rct.po_line_location_id = pll.line_location_id
	                and pll.shipment_type = 'STANDARD'
                        and rct.transaction_id  = p_reference_id;
         End if;
    	 Return l_vendor_id;
     Exception
    	 When others then
              Return  null;
     End get_vendor_id;
     ---
     ---
      Function get_order_type_id( p_move_order_line_id IN NUMBER)
        Return NUMBER is

            g_pkg_name constant 	VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
      	    l_api_name constant 	VARCHAR2(30)   := 'GET_ORDER_TYPE_ID';

      	    l_order_type_id        	VARCHAR2(10)   := NULL;
      	    l_transaction_source_type_id NUMBER ;
            l_reference_id               NUMBER;
	    l_return_value		 BOOLEAN;  --8809951

      	    Begin
      	       if l_debug = 1 then
	          log_event(l_api_name,' Enter' ,l_api_name);
	          log_event(l_api_name,' Move order Line :' , p_move_order_line_id);
      	       end if;

	       --8809951 start
	        l_return_value :=   inv_cache.set_mol_rec(p_move_order_line_id);
	            IF NOT l_return_value THEN
		                IF l_debug = 1 THEN
			                log_event(l_api_name,'','Move order line not found ');
		                END IF;
		              RAISE fnd_api.g_exc_unexpected_error;
	            END IF;

      	    /* -- Bug #3387877
      	        select nvl(mtrl.transaction_source_type_id,0) , nvl(mtrl.reference_id, 0)
      	            into  l_transaction_source_type_id, l_reference_id
	            from mtl_txn_request_lines  mtrl
	            where mtrl.line_id = p_move_order_line_id;  */

	     l_transaction_source_type_id := inv_cache.mol_rec.transaction_source_type_id;
             l_reference_id               := inv_cache.mol_rec.reference_id;

	     --8809951 end
	       if l_debug = 1 then
	     	   log_event(l_api_name,' Txn_source_type_id ' ,l_transaction_source_type_id);
	     	   log_event(l_api_name,' l_reference_id :' ,   l_reference_id);
      	       end if;

              if l_transaction_source_type_id in (2,8)  then

               -- MOAC : changed oe_order_headers to oe_order_headers_all

              /* added the index hint with the suggestion of apps performance team */
               select /*+index (WDD WSH_DELIVERY_DETAILS_N7)*/ oh.order_type_id  into l_order_type_id
	         from oe_order_headers_all oh,
	              wsh_delivery_details wdd
	         where oh.header_id = wdd.source_header_id
	           and wdd.released_status = 'S'
	           and wdd.source_code = 'OE'
                   and wdd.move_order_line_id = p_move_order_line_id;

              -- Bug #3387877
              -- to get the sales order type at header level

              -- MOAC : changed oe_order_headers to oe_order_headers_all
              -- MOAC : and oe_order_lines to oe_order_lines_all

              elsif l_transaction_source_type_id = 12  then
                 select oh.order_type_id  into l_order_type_id
		   from oe_order_headers_all oh ,
		        oe_order_lines_all ol
		         where oh.header_id = ol.header_id
		         and ol.line_id =  l_reference_id ;

               end if;
               return l_order_type_id;

      	     Exception
      	        When others then
          	     Return  null;
      End get_order_type_id;

     ---
     ---
     Procedure get_customer_freight_details(p_transaction_temp_id IN NUMBER,
                                        x_customer_id        OUT NOCOPY NUMBER,
                                        x_freight_code       OUT NOCOPY VARCHAR2) is

        g_pkg_name constant 	VARCHAR2(50)   := 'WMS_SELECTION_CRITERIA_PVT';
        l_api_name constant 	VARCHAR2(30)   := 'GET_CUSTOMER_FREIGHT_DETAILS';
        l_customer_id       	NUMBER;
        l_freight_code      	VARCHAR2(30);
        l_trx_source_line_id  NUMBER;
       begin
          if l_debug = 1 then
             log_event(l_api_name,' Enter',l_api_name);
          end if;
          if l_debug = 1 then
             log_event(l_api_name,'p_transaction_temp_id:'|| p_transaction_temp_id,l_api_name);
          end if;

          BEGIN
             SELECT nvl(trx_source_line_id, -999)
             INTO l_trx_source_line_id
             FROM mtl_material_Transactions_temp
             WHERE transaction_temp_id = p_transaction_temp_id
             AND transaction_source_type_id = INV_GLOBALS.G_SOURCETYPE_RMA
             AND transaction_action_id = INV_GLOBALS.G_ACTION_RECEIPT;

             if l_debug = 1 then
               log_event(l_api_name,'l_trx_source_line_id:'|| l_trx_source_line_id,l_api_name);
             end if;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN
	          l_trx_source_line_id := -999 ;
             END;
         BEGIN
             select customer_id, freight_carrier_code into l_customer_id, l_freight_code
             from WMS_TXN_CONTEXT_TEMP
             where line_id = p_transaction_temp_id;

            if l_debug = 1 then
              log_event(l_api_name,' Values from wms_txn_context_temp:l_customer_id:'||l_customer_id||
                       'l_freight_code' || l_freight_code,l_api_name);
            end if;
         EXCEPTION
          WHEN NO_DATA_FOUND THEN
	     if l_debug = 1 then
                log_event(l_api_name,' In the no_data_found exception for wms_txn_context_temp',l_api_name);
              end if;

              IF l_trx_source_line_id <>-999 THEN
	        if l_debug = 1 then
	         log_event(l_api_name,' In no_data_found_exception with trx_source_line_id having value',l_api_name);
                end if;

		 SELECT
		  hz.PARTY_ID,
		  oola.freight_carrier_code
	        INTO  l_customer_id,
	             l_freight_code
	        FROM  oe_order_lines_all oola,
		HZ_PARTIES hz
		WHERE oola.line_id = l_trx_source_line_id
		AND hz.party_id = oola.sold_to_org_id;

               if l_debug = 1 then
                 log_event(l_api_name,' Values from the mmtt query: l_customer_id:'||l_customer_id||
                          ' l_freight_code' || l_freight_code,l_api_name);
               end if;

             END IF;

        END;
	 x_customer_id   := l_customer_id;
         x_freight_code  := l_freight_code;

      Exception
          When others then
                 x_customer_id   := NULL;
                 x_freight_code  := NULL;
      End get_customer_freight_details;



 --*******************************************************************************
 /**
	This function will returns the location name for a specified locationID
 */
   Function  get_location_name(p_location_id   IN NUMBER)
	 Return VARCHAR2 is

	l_location_code    VARCHAR2(50);
	g_pkg_name constant 	VARCHAR2(50)   := 'WMS_RULES_WORKBENCH_PVT';
	l_api_name constant 	VARCHAR2(30)    := 'GET_LOCATION_NAME';
      begin
          if l_debug = 1 then
              log_event(l_api_name,' Enter',l_api_name);
          end if;
	select location_code into l_location_code
	 from hr_locations
	 where location_id=p_location_id;
       RETURN l_location_code;
       Exception
          When others then
                 l_location_code   := NULL;
		 RETURN l_location_code;
   End GET_LOCATION_NAME;


   /*
     This procedure will search for an appropriate Cross Dock rule(value)
     for the input businees object.
     Following are the codes for the Crossdock rule Types
     For Supply-Initiated Crossdock	rule_type_code=	 10
     For Demand -Initiated Crossdock	rule_type_code=	 11
    */

  Procedure cross_dock_search(
	p_rule_type_code         IN NUMBER,
	p_organization_id	 IN NUMBER,
	p_customer_id		 IN NUMBER,
	p_inventory_item_id	 IN NUMBER,
	p_item_type		 IN VARCHAR,
	p_vendor_id		 IN NUMBER,
	p_location_id		 IN NUMBER,
	p_project_id		 IN NUMBER,
	p_task_id		 IN NUMBER,
	p_user_id		 IN NUMBER,
	p_uom_code		 IN VARCHAR,
	p_uom_class		 IN VARCHAR,
	x_return_type		 OUT  NOCOPY VARCHAR2,
	x_return_type_id	 OUT  NOCOPY NUMBER, --criterion_id
	x_sequence_number	 OUT  NOCOPY NUMBER,
	x_return_status		 OUT  NOCOPY VARCHAR2)
	is

   	g_pkg_name constant 	 VARCHAR2(50)    := 'WMS_RULES_WORKBENCH_PVT';
	l_api_version         CONSTANT NUMBER := 1.0;
	l_api_name constant 	 VARCHAR2(30)    := 'cross_dock_search';
	l_debug_mode  	 BOOLEAN := inv_pp_debug.is_debug_mode;

	l_sequence_number 		wms_selection_criteria_txn.sequence_number%type;
	l_return_type_code		wms_selection_criteria_txn.return_type_code%type;
	l_return_type_id		wms_selection_criteria_txn.return_type_id%type;
	l_msg_count            	NUMBER;
	l_msg_data            	VARCHAR2(2000);

	CURSOR cur_crossdock_value_selection IS
	   SELECT return_type_code, return_type_id, sequence_number
	     FROM wms_selection_criteria_txn
           WHERE from_organization_id = p_organization_id
       	     AND rule_type_code = p_rule_type_code
       	     AND enabled_flag = 1
	     AND NVL(customer_id, NVL(p_customer_id, -9))     = NVL(p_customer_id, -9)
	     AND NVL(inventory_item_id, p_inventory_item_id)  = p_inventory_item_id
	     AND NVL(item_type, NVL(p_item_type, '#'))	      = NVL(p_item_type, '#')
	     AND NVL(vendor_id, NVL(p_vendor_id, -9))         = NVL(p_vendor_id, -9)
	     AND NVL(location_id, NVL(p_location_id, -9))     = NVL(p_location_id, -9)
	     AND NVL(project_id, NVL(p_project_id, -9))       = NVL(p_project_id, -9)
	     AND NVL(task_id, NVL(p_task_id, -9))             = NVL(p_task_id, -9)
	     AND NVL(user_id, NVL(p_user_id, -9))             = NVL(p_user_id, -9)
	     AND NVL(uom_code, NVL(p_uom_code, '#'))          = NVL(p_uom_code, '#')
	     AND NVL(uom_class, NVL(p_uom_class, '#'))        = NVL(p_uom_class, '#')
	     AND DECODE(abc_class_id, NULL, 'N', 'Y')         = DECODE(abc_class_id, NULL,'N',
		    WMS_RULES_WORKBENCH_PVT.get_group_class(p_inventory_item_id,
							    assignment_group_id,
							    abc_class_id))
	     ORDER BY sequence_number;

   BEGIN
      -- Initialize the return status
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN cur_crossdock_value_selection;
      FETCH cur_crossdock_value_selection INTO l_return_type_code, l_return_type_id, l_sequence_number;

      IF (cur_crossdock_value_selection%NOTFOUND) THEN
	 l_return_type_code := NULL;
	 l_return_type_id   := NULL;
	 l_sequence_number  := NULL;
       ELSE
	 x_return_type      := l_return_type_code;
	 x_return_type_id   := l_return_type_id;
	 x_sequence_number  := l_sequence_number;
      END IF;

      IF cur_crossdock_value_selection%ISOPEN THEN
	 CLOSE cur_crossdock_value_selection;
      END IF;

      IF l_debug = 1 THEN
	 log_event(l_api_name, 'Cross Dock Type: =====> ', l_return_type_code);
	 log_event(l_api_name, 'Cross Dock value ID: => ', l_return_type_id);
      END IF;

   EXCEPTION

      WHEN fnd_api.g_exc_error THEN
	 x_return_status := fnd_api.g_ret_sts_error;
	 If cur_crossdock_value_selection%ISOPEN then
	    CLOSE cur_crossdock_value_selection;
	 End if;

	 fnd_msg_pub.Count_And_Get
	    ( p_count => l_msg_count
	      ,p_data => l_msg_data);
	 log_error(l_api_name, 'error', 'Error in Cross selection Criteria - ' ||l_msg_data);

          WHEN fnd_api.g_exc_unexpected_error THEN
	   x_return_status := fnd_api.g_ret_sts_unexp_error;
   	   If cur_crossdock_value_selection%ISOPEN then
	      CLOSE cur_crossdock_value_selection;
	    End if;
	   fnd_msg_pub.Count_And_Get
	     ( p_count => l_msg_count
	      ,p_data => l_msg_data);
	    log_error(l_api_name, 'unexp_error', 'Unexpected error ' ||' in selection Criteria - ' || l_msg_data);

	    WHEN OTHERS THEN
		 if l_debug = 1 then
		      log_event(l_api_name,'',' Exception in cross selection Criteria');
		   end if;
	      x_return_status := fnd_api.g_ret_sts_unexp_error;

	    If cur_crossdock_value_selection%ISOPEN then
	       CLOSE cur_crossdock_value_selection;
	     End if;
	   if (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) then
		  fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
	  end if;
   End CROSS_DOCK_SEARCH;

 --*******************************************************************************


END WMS_RULES_WORKBENCH_PVT;

/
