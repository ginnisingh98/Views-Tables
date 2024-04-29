--------------------------------------------------------
--  DDL for Package Body QA_MQA_MWA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_MQA_MWA_API" AS
/* $Header: qamwab.pls 120.3 2007/11/14 10:07:43 bhsankar ship $ */

/*
Context elements for QA WMS Quality Check
10: Content Item
11: Item Category
32: Customer
146: Ship To Location
173: Container Item
-- 150: License Plate Number
*/
CtxCharIds CtxElemCharIdTab := CtxElemCharIdTab(10, 11, 32, 146, 173);

--
-- Return 1 if the application p_short_name is installed.
-- Wrapper to fnd_installation.get_app_info (which, having
-- a Boolean return value, is not compatible with current
-- JDBC versions.
--
FUNCTION app_installed(p_short_name IN VARCHAR2) RETURN NUMBER IS
    l_status   varchar2(1);
    l_industry varchar2(10);
    l_schema   varchar2(30);
    dummy boolean;
BEGIN
    dummy := fnd_installation.get_app_info(p_short_name, l_status,
        l_industry, l_schema);

    --
    -- l_status will be 'I' if installed or 'N' if not.
    -- anagarwa: I added another status, 'S' because it is possible
    -- to have this status for some users. If not taken care of,
    -- this can cause the disappearnce of Quality button in WIP move.
    -- This was verified by 'infoad_us@oracle.com'
    -- For more info see bug #1716380
    --
    IF l_status = 'I'OR l_status = 'S' THEN
        RETURN 1;
    END IF;

    RETURN 0;
END app_installed;


PROCEDURE transaction_completed(collection_id IN NUMBER,
    commit_flag IN VARCHAR2 DEFAULT 'Y') IS

    l_commit VARCHAR2(1);
    l_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
BEGIN
    IF commit_flag = 'Y' THEN
        l_commit := fnd_api.g_true;
    ELSE
        l_commit := fnd_api.g_false;
    END IF;
    qa_result_grp.enable(
        p_api_version => 1.0,
        p_collection_id => collection_id,
        p_commit => l_commit,
        p_return_status => l_status,
        p_msg_count => l_msg_count,
        p_msg_data => l_msg_data);
END transaction_completed;


PROCEDURE explode_wms_lpn(
	p_lpn_id IN NUMBER,
	p_org_id IN NUMBER,
	x_content_table OUT NOCOPY WMS_CONTAINER_PUB.WMS_CONTAINER_TBL_TYPE,
	x_elements OUT NOCOPY qa_txn_grp.ElementsArray,
	x_element_ids OUT NOCOPY CtxElemIdTab) IS

	msg_count NUMBER;
	msg_data VARCHAR2(2000);
	return_status VARCHAR2(500);

        -- Bug 6622697
        -- Variables to collect cursor records.
        -- bhsankar Tue Nov 13 22:08:33 PST 2007
        --
        l_ctxid      number;
        l_ctxvalue   varchar2(2000);

	cursor ContainerItem(lpnID NUMBER, orgID NUMBER) is
		select wlpn.inventory_item_id, msik.concatenated_segments
		from wms_license_plate_numbers wlpn, mtl_system_items_kfv msik
		where wlpn.lpn_id = lpnID and
		msik.inventory_item_id = wlpn.inventory_item_id and
		msik.organization_id = orgID;

	cursor Customer(lpnID NUMBER) is
		select wdd.customer_id, rc.customer_name
		from wsh_delivery_details wdd, qa_customers_lov_v rc
		where wdd.lpn_id = lpnID and
		wdd.customer_id = rc.customer_id;

	cursor ShipToLocation(lpnID NUMBER) is
		select wdd.ship_to_location_id, tl.description
		from wsh_delivery_details wdd, hr_locations_all_tl tl
		where wdd.lpn_id = lpnID and
		wdd.ship_to_location_id = tl.location_id and
        tl.language = userenv('LANG')
		union
		select wdd.ship_to_location_id,
			substr(hz.address1,1,50) description
		from wsh_delivery_details wdd, hz_locations hz
		where wdd.lpn_id = lpnID and
		wdd.ship_to_location_id = hz.location_id;

BEGIN

	WMS_CONTAINER_PUB.Explode_LPN(
		p_api_version     =>  1.0,
		p_init_msg_list	  =>  fnd_api.g_false,
		p_commit	  =>  fnd_api.g_false,
		x_return_status	  =>  return_status,
		x_msg_count	  =>  msg_count,
		x_msg_data	  =>  msg_data,
		p_lpn_id          =>  p_lpn_id,
		p_explosion_level =>  0,
		x_content_tbl	  =>  x_content_table
	);

	open ContainerItem(p_lpn_id, p_org_id);
        -- bug 6622697
        -- If there are no records then the array element
        -- would not at all exist raising a "No data found"
        -- exception whenever it is accessed, hence
        -- fetching into the variables rather than
        -- directly into the array elements.
        -- bhsankar  Tue Nov 13 22:08:33 PST 2007
        fetch ContainerItem into l_ctxid, l_ctxvalue;
        x_element_ids(CtxCharIds(5)).ID := l_ctxid;
        x_elements(CtxCharIds(5)).value := l_ctxvalue;
        close ContainerItem;

	open Customer(p_lpn_id);
        -- bug 6622697
        -- If there are no records then the array element
        -- would not at all exist raising a "No data found"
        -- exception whenever it is accessed, hence
        -- fetching into the variables rather than
        -- directly into the array elements.
        -- bhsankar  Tue Nov 13 22:08:33 PST 2007
        l_ctxid := null;
        l_ctxvalue := null;

        fetch Customer into l_ctxid, l_ctxvalue;
        x_element_ids(CtxCharIds(3)).ID := l_ctxid;
        x_elements(CtxCharIds(3)).value := l_ctxvalue;
        close Customer;

	open ShipToLocation(p_lpn_id);
        -- bug 6622697
        -- If there are no records then the array element
        -- would not at all exist raising a "No data found"
        -- exception whenever it is accessed, hence
        -- fetching into the variables rather than
        -- directly into the array elements.
        -- bhsankar  Tue Nov 13 22:08:33 PST 2007
        l_ctxid := null;
        l_ctxvalue := null;

        fetch ShipToLocation into l_ctxid, l_ctxvalue;
        x_element_ids(CtxCharIds(4)).ID := l_ctxid;
        x_elements(CtxCharIds(4)).value := l_ctxvalue;
        close ShipToLocation;

END explode_wms_lpn;


PROCEDURE evaluate_triggers(
	p_lpn_id IN NUMBER,
	p_txn_number IN NUMBER,
	p_org_id IN NUMBER,
	x_plan_contexts_str OUT NOCOPY VARCHAR2,
	x_plan_ctxs_ids_str OUT NOCOPY VARCHAR2,
	x_plan_txn_ids_str OUT NOCOPY VARCHAR2) IS

	x_content_table WMS_CONTAINER_PUB.WMS_CONTAINER_TBL_TYPE;

	counter1 NUMBER := 0;
	counter2 NUMBER := 0;
	NoAvailablePlans NUMBER := 0;
	NoContentItems NUMBER := 0;

	AvailablePlanTxns PlanTxnTab;

	ItemCatVal VARCHAR2(122) := null;
	ItemCatID NUMBER := null;
	Item VARCHAR2(40);
	ApplicablePlanCtx VARCHAR2(1000);
	ApplicablePlanCtxId VARCHAR2(1000);

	elements qa_txn_grp.ElementsArray;
	element_ids CtxElemIdTab;

        CURSOR AvailablePlans(txn_number NUMBER, orgID NUMBER) IS
		SELECT qpt.plan_transaction_id, qp.plan_id
	        FROM   qa_plan_transactions qpt, qa_plans qp
	        WHERE  qpt.transaction_number = txn_number
	        AND    qpt.plan_id = qp.plan_id
	        AND    qp.organization_id = orgID
	        AND    qpt.enabled_flag = 1;

BEGIN
	x_plan_contexts_str := null;
	x_plan_ctxs_ids_str := null;
	x_plan_txn_ids_str := null;

	For i in AvailablePlans(p_txn_number, p_org_id) Loop
		counter1 := counter1 + 1;
		AvailablePlanTxns(counter1).PlanTxnID :=
			i.plan_transaction_id;
		AvailablePlanTxns(counter1).PlanID :=
			i.plan_id;
	End Loop;

	NoAvailablePlans := counter1;

	explode_wms_lpn(
		p_lpn_id,
		p_org_id,
		x_content_table,
		elements,
		element_ids);

	NoContentItems := x_content_table.COUNT;

	For counter1 in 1..NoContentItems Loop
          if (x_content_table(counter1).content_type = 1) and
	     (x_content_table(counter1).content_item_id is not null) then
		Item := qa_flex_util.item(
			x_org_id => p_org_id,
			x_item_id => x_content_table(counter1).content_item_id);
		elements(CtxCharIds(1)).value := Item;   -- content_item
		element_ids(CtxCharIds(1)).ID := x_content_table(counter1).content_item_id;

		QA_FLEX_UTIL.get_item_category_val(
			p_org_id => p_org_id,
			p_item_val => null,
			p_item_id => x_content_table(counter1).content_item_id,
			x_category_val => ItemCatVal,
			x_category_id => ItemCatID);
		elements(CtxCharIds(2)).value := ItemCatVal; -- item_category
		element_ids(CtxCharIds(2)).ID := ItemCatID;

		For counter2 in 1..NoAvailablePlans Loop
		        IF triggers_matched(AvailablePlanTxns(counter2).PlanTxnID,
				elements) = 'T' THEN
				/*Using 0 for plan_id */
				ApplicablePlanCtx := '0=' ||
					AvailablePlanTxns(counter2).PlanID ||
					'@' || CtxCharIds(1) || '=' ||
					 elements(CtxCharIds(1)).value ||
					'@' || CtxCharIds(2) || '=' ||
					elements(CtxCharIds(2)).value ||
					'@' || CtxCharIds(3) || '=' ||
					elements(CtxCharIds(3)).value ||
					'@' || CtxCharIds(4) || '=' ||
					elements(CtxCharIds(4)).value ||
					'@' || CtxCharIds(5) || '=' ||
					elements(CtxCharIds(5)).value;

				ApplicablePlanCtxId := '0=' ||
					AvailablePlanTxns(counter2).PlanID ||
					'@' || CtxCharIds(1) || '=' ||
					element_ids(CtxCharIds(1)).ID ||
					'@' || CtxCharIds(2) || '=' ||
					element_ids(CtxCharIds(2)).ID ||
					'@' || CtxCharIds(3) || '=' ||
					element_ids(CtxCharIds(3)).ID ||
					'@' || CtxCharIds(4) || '=' ||
					element_ids(CtxCharIds(4)).ID ||
					'@' || CtxCharIds(5) || '=' ||
					element_ids(CtxCharIds(5)).ID;

				If x_plan_txn_ids_str is not null then
					x_plan_txn_ids_str :=
						x_plan_txn_ids_str || ',' ||
						AvailablePlanTxns(counter2).PlanTxnID;
					x_plan_contexts_str :=
						x_plan_contexts_str || '%' || ApplicablePlanCtx;
					x_plan_ctxs_ids_str :=
						x_plan_ctxs_ids_str || '%' || ApplicablePlanCtxId;
				else
					x_plan_txn_ids_str := AvailablePlanTxns(counter2).PlanTxnID;
					x_plan_contexts_str := ApplicablePlanCtx;
					x_plan_ctxs_ids_str := ApplicablePlanCtxId;
				end if;
			END IF;
		End Loop;
      	   End If;
	End Loop;

END evaluate_triggers;


FUNCTION triggers_matched(p_plan_txn_id IN NUMBER, elements IN qa_txn_grp.ElementsArray)
RETURN VARCHAR2 IS

BEGIN

    FOR plan_record in (
        SELECT qpct.operator,
               qpct.Low_Value,
               qpct.High_Value ,
               qc.datatype,
               qc.char_id
        FROM   qa_plan_collection_triggers qpct,
               qa_chars qc
        WHERE  qpct.Collection_Trigger_ID = qc.char_id and
               qpct.plan_transaction_id = p_plan_txn_id) LOOP

        IF NOT elements.EXISTS(plan_record.char_id) THEN
            RETURN 'F';
        END IF;

        IF NOT qltcompb.compare(
            elements(plan_record.char_id).value,
            plan_record.operator,
            plan_record.Low_Value,
            plan_record.High_Value,
            plan_record.datatype) THEN
            RETURN 'F';
        END IF;

    END LOOP;

    RETURN 'T';
END triggers_matched;

-- Bug 4519558. Oa Fwk Integration Project. UT bug fix.
-- Return fnd_api.g_true if p_txn is a mobile txn
-- else return fnd_api.g_false.
-- Mobile transaction number will come in range [1001,1999]
-- srhariha. Mon Aug 22 02:50:35 PDT 2005.


FUNCTION is_mobile_txn(p_txn IN NUMBER) RETURN VARCHAR2 IS

BEGIN

  IF (p_txn between 1001 and 1999) THEN
     return fnd_api.g_true;
  END IF;

  return fnd_api.g_false;

END is_mobile_txn;

END qa_mqa_mwa_api;

/
