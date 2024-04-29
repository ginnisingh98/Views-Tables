--------------------------------------------------------
--  DDL for Package Body INV_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_DRT_PKG" AS
/* $Header: INVDRTPB.pls 120.0.12010000.18 2018/06/26 10:39:13 ksuleman noship $ */
l_package varchar2(33) DEFAULT 'INV_DRT_PKG. ';

PROCEDURE write_log
    (message       IN         varchar2
    ,stage       IN                 varchar2) IS
  BEGIN
                if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
                    fnd_log.string(fnd_log.level_procedure,message,stage);
                end if;
  END write_log;



---
--- Procedure: INV_HR_DRC
--- For a given HR Person, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Person comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE INV_HR_DRC
  (person_id       IN         varchar2
  ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type) IS

  l_proc varchar2(72) := l_package|| 'INV_HR_DRC';
  p_person_id number(20);
  l_count number;
  l_temp varchar2(20);

BEGIN
  write_log ('Entering:'|| l_proc,'10');
  p_person_id := person_id;
  write_log ('p_person_id: '|| p_person_id,'20');
  BEGIN
    --
    --- Check if person exist as planner for any item
    --
    write_log ('starting check for PLANNER_CODE in mtl_system_items_b'|| p_person_id,'20');

    l_count := 0;
/*
    SELECT 1 into l_count
      FROM MTL_SYSTEM_ITEMS_B
     WHERE PLANNER_CODE in (
	  SELECT PLANNER_CODE
		FROM MTL_PLANNERS
	   WHERE EMPLOYEE_ID = p_person_id
	  )
       AND ROWNUM = 1;
*/

SELECT 1 into l_count
  FROM (
  select distinct organization_id, planner_code
    from MTL_PLANNERS planners
   where EMPLOYEE_ID = p_person_id) p
 WHERE EXISTS (
   SELECT 'x'
     FROM MTL_SYSTEM_ITEMS_B b
    WHERE organization_id = p.organization_id
      AND planner_code    = p.planner_code
  )
AND ROWNUM = 1;


	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'W'
		,msgcode => 'INV_DRC_PLN_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
          write_log ('p_person_id found in mtl_system_items_b' ,'20');
	end if;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      write_log ('p_person_id not exists as planner in mtl_system_items_b','20');

    WHEN OTHERS THEN
      write_log ('In exceptions block msi - when others : SQLCODE: ' || SUBSTR(SQLERRM, 1, 100),'20');

  END;

  BEGIN
    --
    --- Check if person exist as planner for any item in interface table
    --

    l_count := 0;

    SELECT 1 into l_count
      FROM MTL_SYSTEM_ITEMS_INTERFACE
     WHERE PLANNER_CODE in (
	  SELECT PLANNER_CODE
		FROM MTL_PLANNERS
	   WHERE EMPLOYEE_ID = p_person_id
	  )
       AND ROWNUM = 1;


/*
SELECT 1 into l_count
  FROM MTL_SYSTEM_ITEMS_INTERFACE a ,
  (SELECT DISTINCT planner_code
     FROM MTL_PLANNERS b
    WHERE employee_id = p_person_id) b
 WHERE a.PLANNER_CODE = b.planner_code
   AND ROWNUM = 1;
*/

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'E'
		,msgcode => 'INV_DRC_PLN_INT_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
          write_log ('p_person_id found in mtl_system_items_interface' ,'20');
	end if;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      write_log ('p_person_id not exists as planner in mtl_system_items_interface','20');

    WHEN OTHERS THEN
      write_log ('In exceptions block for msii - when others : SQLCODE: ' || SUBSTR(SQLERRM, 1, 100),'20');

  END;

   BEGIN
    --
    --- Check any cycle count requests pending for the person.
    --
	l_count := 0;

	  SELECT 1  into l_count
	  FROM MTL_CYCLE_COUNT_ENTRIES
	  WHERE  COUNTED_BY_EMPLOYEE_ID_CURRENT = p_person_id
	  and ENTRY_STATUS_CODE in (1,3)
	  and rownum = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'E'
		,msgcode => 'INV_DRC_CYC_ENT_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
 write_log ('p_person_id check for COUNTED_BY_EMPLOYEE_ID_CURRENT '|| p_person_id,'20');
   EXCEPTION WHEN OTHERS THEN
   l_count := 0;
   write_log ('p_person_id not exists in  MTL_CYCLE_COUNT_ENTRIES COUNTED_BY:'|| p_person_id,'20');
  END;

   BEGIN
    --
    --- Check any cycle count approval requests pending for the person.
    --
	l_count := 0;

	  SELECT 1  into l_count
	  FROM MTL_CYCLE_COUNT_ENTRIES
	  WHERE APPROVER_EMPLOYEE_ID = p_person_id
	  and ENTRY_STATUS_CODE=2
	  and rownum = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'E'
		,msgcode => 'INV_DRC_CYC_APP_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
 write_log ('p_person_id check for APPROVER_EMPLOYEE_ID '|| p_person_id,'20');
   EXCEPTION WHEN OTHERS THEN
   l_count := 0;
   write_log ('p_person_id not exists in  MTL_CYCLE_COUNT_ENTRIES :'|| p_person_id,'20');
  END;

   BEGIN
    --
    --- Check any cycle count open interface requests pending for the person.
    --
	l_count := 0;
    SELECT 1 into l_count
      FROM MTL_CC_ENTRIES_INTERFACE
	  where EMPLOYEE_ID = p_person_id
          and nvl(status_flag,4) not in (0,1)
	  and rownum = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'E'
		,msgcode => 'INV_DRC_CYC_OPEN_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
 write_log ('p_person_id check for APPROVER_EMPLOYEE_ID in Interface'|| p_person_id,'20');
  EXCEPTION WHEN OTHERS THEN
  l_count := 0;
   write_log ('p_person_id not exists in  MTL_CC_ENTRIES_INTERFACE :'|| p_person_id,'20');
  END;

  BEGIN
    --
    --- Check any phsyical adjusments pending for the person.
    --
	l_count := 0;
    SELECT 1 into l_count
      FROM mtl_physical_adjustments where nvl(APPROVAL_STATUS,0)=0
	  and APPROVED_BY_EMPLOYEE_ID = p_person_id
	  and rownum = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'HR'
		,status => 'E'
		,msgcode => 'INV_DRC_PHY_APP_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
 write_log ('p_person_id check for APPROVED_BY_EMPLOYEE_ID '|| p_person_id,'20');
 EXCEPTION WHEN OTHERS THEN
 l_count := 0;
   write_log ('p_person_id not exists in  MTL_PHYSICAL_ADJUSTMENTS :'|| p_person_id,'20');
  END;
 write_log ('Leaving:'|| l_proc,'999');
END INV_HR_DRC;


---
--- Procedure: INV_TCA_DRC
--- For a given HR Person, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Person comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE INV_TCA_DRC
  (person_id       IN         varchar2
  ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type) IS

   l_proc varchar2(72) := l_package|| 'INV_TCA_DRC';
  p_person_id number(20);
  l_count number;
  l_temp varchar2(20);

BEGIN

  write_log ('Entering:'|| l_proc,'10');
  p_person_id := person_id;
   write_log ('p_person_id: '|| p_person_id,'20');

  BEGIN
    --
    --- Check if person exist as customer in customer items interface
    --
	l_count := 0;
    SELECT 1 into l_count
      FROM MTL_CI_INTERFACE
     WHERE CUSTOMER_ID = p_person_id
       AND ROWNUM = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'INV_DRC_CI_INT_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
 write_log ('p_person_id check for CUSTOMER_ID '|| p_person_id,'20');

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      write_log ('p_person_id not exists in MTL_CI_INTERFACE','20');

    WHEN OTHERS THEN
      write_log ('In exceptions block MTL_CI_INTERFACE - when others : SQLCODE: ' || SUBSTR(SQLERRM, 1, 100),'20');


    END;

  BEGIN
    --
    --- Check if person exist as customer in customer items interface
    --
    SELECT 1 into l_count
      FROM MTL_CI_XREFS_INTERFACE
     WHERE CUSTOMER_ID = p_person_id
       AND ROWNUM = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'INV_DRC_CIXREF_INT_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
	 write_log ('p_person_id check for CUSTOMER_ID '|| p_person_id,'20');

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      l_count := 0;
      write_log ('p_person_id not exists in MTL_CI_XREFS_INTERFACE','20');

    WHEN OTHERS THEN
      write_log ('In exceptions block MTL_CI_XREFS_INTERFACE - when others : SQLCODE: ' || SUBSTR(SQLERRM, 1, 100),'20');


  END;

   BEGIN
    --
    --- Check if party exist with consigned stock exists in onhand
    --
	l_count := 0;

   SELECT 1
INTO    l_count
FROM    (
        SELECT  1 cnt
        FROM    mtl_onhand_quantities_detail
        WHERE   owning_tp_type = 1
        AND     is_consigned = 1
        AND     owning_organization_id IN
                (
                SELECT  vendor_site_id
                FROM    po_vendor_sites_all pvsa
                       ,ap_suppliers sup
                WHERE   pvsa.vendor_id = sup.vendor_id
                AND     sup.party_id = p_person_id
                ) and rownum = 1
        UNION
        SELECT  1 cnt
        FROM    mtl_consumption_transactions mct
               ,mtl_material_transactions mmt
        WHERE   mct.transaction_id = mmt.transaction_id
        AND     consumption_processed_flag = 'N'
        AND     mmt.owning_organization_id IN
                (
                SELECT  vendor_site_id
                FROM    po_vendor_sites_all pvsa
                       ,ap_suppliers sup
                WHERE   pvsa.vendor_id = sup.vendor_id
                AND     sup.party_id = p_person_id
                ) and rownum = 1
        );

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'INV_DRC_CONSIGN_OH_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;

	write_log ('p_person_id check for owning_organization_id '|| p_person_id,'20');
	EXCEPTION WHEN OTHERS THEN
	l_count := 0;
   write_log ('p_person_id not exists in  MTL_CONSUMPTION_TRANSACTIONS :'|| p_person_id,'20');

    END;

	BEGIN
    --
    --- Check any VMI Transactions pending for the supplier.
    --
       SELECT  1  into l_count
        FROM    mtl_onhand_quantities_detail
        WHERE   planning_tp_type = 1
        AND     planning_organization_id IN
                (
                SELECT  vendor_site_id
                FROM    po_vendor_sites_all pvsa
                       ,ap_suppliers sup
                WHERE   pvsa.vendor_id = sup.vendor_id
                AND     sup.party_id = p_person_id
                ) AND ROWNUM = 1;

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'INV_DRC_VMI_OH_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
	write_log ('p_person_id check for planning_organization_id '|| p_person_id,'20');
	EXCEPTION WHEN OTHERS THEN
	l_count := 0;
   write_log ('p_person_id not exists in  MTL_ONHAND_QUANTITIES_DETAIL :'|| p_person_id,'20');
  END;

     BEGIN
    --
    --- Check if party exist as supplier with kanban card pending
    --  pull sequence validation is exists in kanban cards so not adding.
	l_count := 0;

SELECT  1
INTO    l_count
FROM    (
        SELECT  1 cnt
        FROM    mtl_kanban_cards
        WHERE   source_type = 2
        AND     card_status = 1
        AND     supply_status IN (1,3,5,6)
        AND     supplier_site_id IN
                (
                SELECT  vendor_site_id
                FROM    po_vendor_sites_all pvsa
                       ,ap_suppliers sup
                WHERE   pvsa.vendor_id = sup.vendor_id
                AND     sup.party_id = p_person_id
                ) and rownum = 1
               );

	if l_count <> 0 then
	  per_drt_pkg.add_to_results(
	    person_id => p_person_id
  		,entity_type => 'TCA'
		,status => 'E'
		,msgcode => 'INV_DRC_OPEN_KAN_CARD_EXISTS'
		,msgaplid => 401
		,result_tbl => result_tbl
	  );
	end if;
	write_log ('p_person_id check for supplier_site_id '|| p_person_id,'20');
	EXCEPTION WHEN OTHERS THEN
	l_count := 0;
   write_log ('p_person_id not exists in  KANBAN tables :'|| p_person_id,'20');
    END;


END INV_TCA_DRC;


END INV_DRT_PKG;

/
