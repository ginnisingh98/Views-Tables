--------------------------------------------------------
--  DDL for Package Body INVTVTUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVTVTUS" as
/* $Header: INVTVTUB.pls 120.1 2006/03/08 03:57:02 rkatoori noship $ */

 procedure item_only_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	orgloctype number,
	invid mtl_system_items.inventory_item_id%TYPE,
	rev mtl_item_revisions.revision%TYPE,
	uom mtl_system_items.primary_uom_code%TYPE,
	puom mtl_system_items.primary_uom_code%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE)
 is
		cratio number := 1;
		prc number := 1;
		msgbuf varchar2(200);

	begin
		delete from mtl_summary_temp
		where session_id = sessionid;

/*Bug4950410 : Added the following query to get the currency precision to round the inventory value.
  Also rounding the net_val and abs_val based on the currency precision of the organization. */
		select fc.precision into prc
		from org_organization_definitions ood,
		gl_sets_of_books sob,
		fnd_currencies fc
		where ood.organization_id = orgid
		and ood.set_of_books_id = sob.set_of_books_id
		and fc.currency_code = sob.currency_code;

		if (puom <> uom) then
		    cratio := inv_convert.inv_um_convert(invid,5,null,puom,uom,null,null);
		end if;

		/* Source Type and Txn Type Summary */
		/* We are also storing transaction action here
		   for future use */
/*Bug2712883 : The insert statements having cg_id in their where clause is modified so as to include NVL's on both sides */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_source_type_name,
		 transaction_type_name,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SRCTYPE_TXNTYPE_SUMMARY',
		mtst.transaction_source_type_name,
		mtt.transaction_type_name,
		ml.meaning,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt,
			mfg_lookups ml,
			mtl_txn_source_types mtst,
			mtl_transaction_types mtt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
		and mmt.transaction_date >= NVL(sdate,mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mtst.transaction_source_type_id = mmt.transaction_source_type_id
		and mtt.transaction_type_id = mmt.transaction_type_id
		and ml.lookup_code = mmt.transaction_action_id + 0
		and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mtst.transaction_source_type_name,
		 mtt.transaction_type_name, ml.meaning;

		/* Source Type Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_source_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SOURCE_TYPES_SUMMARY',
		mst.transaction_source_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_source_type_name;

		/* Transaction type summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'TXN_TYPES_SUMMARY',
		mst.transaction_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_type_name;

		/* Action Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'TXN_ACTION_SUMMARY',
		mst.transaction_action_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_action_name;

		/* Subinventory Summary */
	    if (orgloctype = 1) then
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_SUMMARY',
		mmt.subinventory_code,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.subinventory_code;
	     else
		/* Subinventory - Locator Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 locator_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_LOCATOR_SUMMARY',
		mmt.subinventory_code,
		mmt.locator_id,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
		and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.subinventory_code, mmt.locator_id;

		/* Subinventory Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_SUMMARY',
		mst.subinventory,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUBINVENTORY_LOCATOR_SUMMARY'
		and session_id = sessionid
		group by mst.subinventory;
	     end if;

		/* subinventory cost group summary */
		/* changes for zone/rearchitecture project */
		/* ssia 06/02/00 */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUB_COST_GROUP_SUMMARY',
		mmt.subinventory_code,
		mmt.cost_group_id,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.subinventory_code, mmt.cost_group_id;

		/* Cost_group_summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'COST_GROUP_SUMMARY',
		mst.cost_group_id,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUB_COST_GROUP_SUMMARY'
		and session_id = sessionid
		group by mst.cost_group_id;

		/* Totals Summary */
		/* Total In */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		nvl(cratio*sum(mmt.primary_quantity),0),
		round(nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),prc),
		nvl(sum(1),0),
		1
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

		/* Total Out */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		nvl(abs(cratio*sum(mmt.primary_quantity)),0),
		round(nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),prc),
		nvl(sum(1),0),
		2
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

		/* Total Net */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		sum(mst.net_qty),
		sum(mst.net_val),
		null,
		3
		from mtl_summary_temp mst
		where mst.summary_type='TXN_ACTION_SUMMARY'
		and session_id = sessionid;
		/* TXN_ACTION_SUMMARY is most likely to be a smaller
		set of rows */
	exception
	 when others then
		raise_application_error(-20001, sqlerrm||'---'||msgbuf);
	end item_only_summaries;

  procedure sub_only_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
	locid mtl_item_locations.inventory_location_id%TYPE,
	catsetid mtl_category_sets.category_set_id%TYPE,
	catid mtl_categories.category_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE)
        is
		msgbuf varchar2(200);
		prc number := 1;
		cratio number := 1;
	begin
		delete from mtl_summary_temp where session_id = sessionid;

/*Bug4950410 : Added the following query to get the currency precision to round the inventory value.
  Also rounding the net_val and abs_val based on the currency precision of the organization. */

		select fc.precision into prc
		from org_organization_definitions ood,
		gl_sets_of_books sob,
		fnd_currencies fc
		where ood.organization_id = orgid
		and ood.set_of_books_id = sob.set_of_books_id
		and fc.currency_code = sob.currency_code;

   -- Bug 3614951 changing the below sql to execute conditionally.
   -- Begin changes
            IF catsetid IS NULL AND catid IS NULL THEN
		/* Item, Source Type, Txn Type summary */
		/* We are inserting transaction action as well
		   for later summarization */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 transaction_source_type_name,
		 transaction_type_name,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'ITEM_SRCTYPE_TXNTYPE_SUMMARY',
		mmt.inventory_item_id,
		min(mmt.organization_id),
		mtst.transaction_source_type_name,
		mtt.transaction_type_name,
		ml.meaning,
		sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt,
			mtl_txn_source_types mtst,
			mfg_lookups ml,
			mtl_transaction_types mtt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mtst.transaction_source_type_id = mmt.transaction_source_type_id
		and mtt.transaction_type_id = mmt.transaction_type_id
		and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
		and ml.lookup_code = mmt.transaction_action_id + 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.inventory_item_id,
			mtst.transaction_source_type_name,
			mtt.transaction_type_name,
			ml.meaning;
           ELSE
	   	insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 transaction_source_type_name,
		 transaction_type_name,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'ITEM_SRCTYPE_TXNTYPE_SUMMARY',
		mmt.inventory_item_id,
		min(mmt.organization_id),
		mtst.transaction_source_type_name,
		mtt.transaction_type_name,
		ml.meaning,
		sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt,
			mtl_txn_source_types mtst,
			mfg_lookups ml,
			mtl_transaction_types mtt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and exists ( select 'X'
			from mtl_item_categories mic
			where mic.category_set_id = nvl(catsetid, mic.category_set_id)
			and mic.category_id = nvl(catid, mic.category_id)
			and mic.inventory_item_id = mmt.inventory_item_id
			and mic.organization_id = orgid)
		and mtst.transaction_source_type_id = mmt.transaction_source_type_id
		and mtt.transaction_type_id = mmt.transaction_type_id
		and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
		and ml.lookup_code = mmt.transaction_action_id + 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.inventory_item_id,
			mtst.transaction_source_type_name,
			mtt.transaction_type_name,
			ml.meaning;
	   END IF;
	   -- End changes bug 3614951
		/* Item summmary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		 select
		sessionid,
		'ITEM_SUMMARY',
		mst.inventory_item_id,
		min(mst.organization_id),
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.inventory_item_id;

		/* Item, Source Type summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 transaction_source_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'ITEM_SRCTYPE_SUMMARY',
		mst.inventory_item_id,
		min(mst.organization_id),
		mst.transaction_source_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.inventory_item_id, mst.transaction_source_type_name;

		/* Item, Txn Type summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 transaction_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'ITEM_TXN_TYPES_SUMMARY',
		mst.inventory_item_id,
		min(mst.organization_id),
		mst.transaction_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.inventory_item_id, mst.transaction_type_name;

		/* Item, Txn action summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 inventory_item_id,
		 organization_id,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'ITEM_TXN_ACTION_SUMMARY',
		mst.inventory_item_id,
		min(mst.organization_id),
		mst.transaction_action_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.inventory_item_id, mst.transaction_action_name;

		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUB_COST_GROUP_SUMMARY',
		mmt.subinventory_code,
		mmt.cost_group_id,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt
		where mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.subinventory_code, mmt.cost_group_id;

		/* Cost_group_summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'COST_GROUP_SUMMARY',
		mst.cost_group_id,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUB_COST_GROUP_SUMMARY'
		and session_id = sessionid
		group by mst.cost_group_id;
   -- Bug 3614951 changing the below sql to execute conditionally.
   -- Begin changes
            IF catsetid IS NULL AND catid IS NULL THEN
		/* Totals Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_val,
		 num_txns,
		 locator_id)
		select
		sessionid,
		'TOTALS',
		round(nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),prc),
		nvl(sum(1),0),
		1
		from mtl_material_transactions mmt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		round(nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),prc),
		nvl(sum(1),0),
		2
		from mtl_material_transactions mmt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
          ELSE
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_val,
		 num_txns,
		 locator_id)
		select
		sessionid,
		'TOTALS',
		round(nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),prc),
		nvl(sum(1),0),
		1
		from mtl_material_transactions mmt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and exists ( select 'X'
			from mtl_item_categories mic
			where mic.category_set_id = nvl(catsetid, mic.category_set_id)
			and mic.category_id = nvl(catid, mic.category_id)
			and mic.inventory_item_id = mmt.inventory_item_id
			and mic.organization_id = orgid)
		and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		round(nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),prc),
		nvl(sum(1),0),
		2
		from mtl_material_transactions mmt
		where mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and exists ( select 'X'
			from mtl_item_categories mic
			where mic.category_set_id = nvl(catsetid, mic.category_set_id)
			and mic.category_id = nvl(catid, mic.category_id)
			and mic.inventory_item_id = mmt.inventory_item_id
			and mic.organization_id = orgid)
		and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
	  END IF;
	  -- End changes bug 3614951
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		sum(mst.net_val),
		null,
		3
		from mtl_summary_temp mst
		where summary_type = 'ITEM_SUMMARY'
		and session_id = sessionid;
	exception
	 when others then
		raise_application_error(-20001, sqlerrm||'---'||msgbuf);
	end sub_only_summaries;

 procedure both_summaries (
	sessionid number,
	orgid mtl_parameters.organization_id%TYPE,
	invid mtl_system_items.inventory_item_id%TYPE,
	rev mtl_item_revisions.revision%TYPE,
	uom mtl_system_items.primary_uom_code%TYPE,
	puom mtl_system_items.primary_uom_code%TYPE,
	sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
	locid mtl_item_locations.inventory_location_id%TYPE,
	sdate mtl_material_transactions.transaction_date%TYPE,
	edate mtl_material_transactions.transaction_date%TYPE,
	cg_id mtl_secondary_inventories.default_cost_group_id%TYPE)
 	is
		cratio number := 1;
		prc number := 1;
		msgbuf varchar2(200);
	begin
		delete from mtl_summary_temp where session_id = sessionid;

/*Bug4950410 : Added the following query to get the currency precision to round the inventory value.
  Also rounding the net_val and abs_val based on the currency precision of the organization. */
		select fc.precision into prc
		from org_organization_definitions ood,
		gl_sets_of_books sob,
		fnd_currencies fc
		where ood.organization_id = orgid
		and ood.set_of_books_id = sob.set_of_books_id
		and fc.currency_code = sob.currency_code;

		if (puom <> uom) then
		    cratio := inv_convert.inv_um_convert(invid,5,null, puom,uom,null,null);
		end if;

		/* Source Type and Txn Type Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_source_type_name,
		 transaction_type_name,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SRCTYPE_TXNTYPE_SUMMARY',
		mtst.transaction_source_type_name,
		mtt.transaction_type_name,
		ml.meaning,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt,
			mtl_txn_source_types mtst,
			mtl_transaction_types mtt,
			mfg_lookups ml
		where mmt.inventory_item_id = invid
		and mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
		and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mtst.transaction_source_type_id = mmt.transaction_source_type_id
		and mtt.transaction_type_id = mmt.transaction_type_id
		and mmt.subinventory_code||'' = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and ml.lookup_code = mmt.transaction_action_id + 0
		and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mtst.transaction_source_type_name, mtt.transaction_type_name, ml.meaning;

		/* Source Type Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_source_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SOURCE_TYPES_SUMMARY',
		mst.transaction_source_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_source_type_name;

		/* */
		/* Transaction type summary */

		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_type_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'TXN_TYPES_SUMMARY',
		mst.transaction_type_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_type_name;
		/* */

		/* Action Summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 transaction_action_name,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'TXN_ACTION_SUMMARY',
		mst.transaction_action_name,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SRCTYPE_TXNTYPE_SUMMARY'
		and session_id = sessionid
		group by mst.transaction_action_name;

		/* cost group subinventory summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUB_COST_GROUP_SUMMARY',
		mmt.subinventory_code,
		mmt.cost_group_id,
		cratio*sum(mmt.primary_quantity),
		round(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),prc),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		round(sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity)),prc)
		from mtl_material_transactions mmt
		where mmt.subinventory_code = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.organization_id = orgid
		and mmt.inventory_item_id = invid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
                and mmt.transaction_action_id NOT IN (24,30,50,51,52)  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */
		group by mmt.subinventory_code, mmt.cost_group_id;

		/* Cost_group_summary */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'COST_GROUP_SUMMARY',
		mst.cost_group_id,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUB_COST_GROUP_SUMMARY'
		and session_id = sessionid
		group by mst.cost_group_id;


		/* Totals */
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		nvl(cratio*sum(mmt.primary_quantity),0),
		round(nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),prc),
		nvl(sum(1),0),
		1
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mmt.subinventory_code||'' = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */


		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		nvl(abs(cratio*sum(mmt.primary_quantity)),0),
		round(nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),prc),
		nvl(sum(1),0),
		2
		from mtl_material_transactions mmt
		where mmt.inventory_item_id = invid
		and mmt.organization_id = orgid
		and NVL(mmt.cost_group_id,-9999) = NVL(NVL(cg_id,mmt.cost_group_id),-9999)
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
		and (mmt.revision = nvl(rev, mmt.revision) or mmt.revision is null)
		and mmt.subinventory_code||'' = sub
		and (mmt.locator_id = nvl(locid, mmt.locator_id) or mmt.locator_id is null)
		and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30,50,51,52);  /* Bug #3194333 (Container Pack (50),Unpack(51) and Split(52) txns to be excluded) */

		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 net_qty,
		 net_val,
		 num_txns,
		 locator_id) /* This is populated for ordering purposes */
		select
		sessionid,
		'TOTALS',
		sum(mst.net_qty),
		sum(mst.net_val),
		null,
		3
		from mtl_summary_temp mst
		where mst.summary_type = 'TXN_ACTION_SUMMARY'
		and session_id = sessionid;

	exception
	 when others then
	      raise_application_error(-20001, sqlerrm||'---'||msgbuf);
	end both_summaries;

/* procedure cost_group_summaries (
        sessionid number,
        orgid mtl_parameters.organization_id%TYPE,
	orgloctype NUMBER,
        cost_group_id mtl_secondary_inventories.default_cost_group_id%TYPE,
        sdate mtl_material_transactions.transaction_date%TYPE,
        edate mtl_material_transactions.transaction_date%TYPE)
    IS
        msgbuf varchar2(200);
		cratio number := 1;
    begin
                delete from mtl_summary_temp where session_id = sessionid;
*/
                /* Item, Source Type, Txn Type summary */
                /* We are inserting transaction action as well
                   for later summarization */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_source_type_name,
                 transaction_type_name,
                 transaction_action_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_SRCTYPE_TXNTYPE_SUMMARY',
                mmt.inventory_item_id,
                min(mmt.organization_id),
                mtst.transaction_source_type_name,
                mtt.transaction_type_name,
                ml.meaning,
                sum(mmt.primary_quantity),
                sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),
                sum(1),
                sum(abs(mmt.primary_quantity)),
                sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity))
                from mtl_material_transactions mmt,
                        mtl_txn_source_types mtst,
                        mfg_lookups ml,
                        mtl_transaction_types mtt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.cost_group_id = cost_group_id
                and mtst.transaction_source_type_id = mmt.transaction_source_type_id
                and mtt.transaction_type_id = mmt.transaction_type_id
                and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
                and ml.lookup_code = mmt.transaction_action_id + 0
                and mmt.transaction_action_id NOT IN (24,30)
                group by mmt.inventory_item_id,
                        mtst.transaction_source_type_name,
                        mtt.transaction_type_name,
                        ml.meaning;*/

                /* Item, Source Type summary */
                /*insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_source_type_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_SRCTYPE_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_source_type_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id, mst.transaction_source_type_name;
*/
                /* Item, Txn Type summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_type_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_TXN_TYPES_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_type_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id, mst.transaction_type_name;
*/
                /* Item, Txn action summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_action_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_TXN_ACTION_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_action_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id, mst.transaction_action_name;
*/
		/* Subinventory Summary */
/*	    if (orgloctype = 1) then
		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_SUMMARY',
		mmt.subinventory_code,
		cratio*sum(mmt.primary_quantity),
		sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity))
		from mtl_material_transactions mmt
		where mmt.cost_group_id = cost_group_id
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.transaction_action_id NOT IN (24,30)
		group by mmt.subinventory_code;
	     else*/
		/* Subinventory - Locator Summary */
	/*	insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 locator_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_LOCATOR_SUMMARY',
		mmt.subinventory_code,
		mmt.locator_id,
		cratio*sum(mmt.primary_quantity),
		sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity))
		from mtl_material_transactions mmt
		where mmt.cost_group_id = cost_group_id
		and mmt.organization_id = orgid
		and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.transaction_action_id NOT IN (24,30)
		group by mmt.subinventory_code, mmt.locator_id;
*/
		/* Subinventory Summary */
/*		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUBINVENTORY_SUMMARY',
		mst.subinventory,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUBINVENTORY_LOCATOR_SUMMARY'
		and session_id = sessionid
		group by mst.subinventory;
	     end if;
*/
		/* subinventory cost group summary */
		/* changes for zone/rearchitecture project */
		/* ssia 06/02/00 */
/*		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 subinventory,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'SUB_COST_GROUP_SUMMARY',
		mmt.subinventory_code,
		mmt.cost_group_id,
		cratio*sum(mmt.primary_quantity),
		sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),
		sum(1),
		cratio*sum(abs(mmt.primary_quantity)),
		sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity))
		from mtl_material_transactions mmt
		where mmt.cost_group_id = cost_group_id
		and mmt.organization_id = orgid
	        and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
		and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.transaction_action_id NOT IN (24,30)
		group by mmt.subinventory_code, mmt.cost_group_id;
*/
		/* Cost_group_summary */
/*		insert into mtl_summary_temp
		(session_id,
		 summary_type,
		 cost_group_id,
		 net_qty,
		 net_val,
		 num_txns,
		 abs_qty,
		 abs_val)
		select
		sessionid,
		'COST_GROUP_SUMMARY',
		mst.cost_group_id,
		sum(mst.net_qty),
		sum(mst.net_val),
		sum(mst.num_txns),
		sum(mst.abs_qty),
		sum(mst.abs_val)
		from mtl_summary_temp mst
		where mst.summary_type = 'SUB_COST_GROUP_SUMMARY'
		and session_id = sessionid
		group by mst.cost_group_id;
*/
                /* Totals Summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)
                select
                sessionid,
                'TOTALS',
                nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),
                nvl(sum(1),0),
                1
                from mtl_material_transactions mmt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.cost_group_id = cost_group_id
                and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30);

                insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)*/ /* This is populated for ordering purposes */
               /* select
                sessionid,
                'TOTALS',
                nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),
                nvl(sum(1),0),
                2
                from mtl_material_transactions mmt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.cost_group_id = cost_group_id
                and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30);

                insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)*/ /* This is populated for ordering purposes */
               /* select
                sessionid,
                'TOTALS',
                sum(mst.net_val),
                null,
                3
                from mtl_summary_temp mst
                where summary_type = 'ITEM_SUMMARY'
                and session_id = sessionid;
        exception
         when others then
                raise_application_error(-20001, sqlerrm||'---'||msgbuf);
	end cost_group_summaries;

   procedure sub_cost_group_summaries(
        sessionid NUMBER,
        orgid mtl_parameters.organization_id%TYPE,
        sub mtl_secondary_inventories.secondary_inventory_name%TYPE,
        cost_group_id mtl_secondary_inventories.default_cost_group_id%TYPE,
        sdate mtl_material_transactions.transaction_date%TYPE,
        edate mtl_material_transactions.transaction_date%TYPE)
   IS
        msgbuf varchar2(200);
   begin

                delete from mtl_summary_temp where session_id = sessionid;
*/
                /* Item, Source Type, Txn Type summary */
                /* We are inserting transaction action as well
                   for later summarization */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_source_type_name,
                 transaction_type_name,
                 transaction_action_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_SRCTYPE_TXNTYPE_SUMMARY',
                mmt.inventory_item_id,
                min(mmt.organization_id),
                mtst.transaction_source_type_name,
                mtt.transaction_type_name,
                ml.meaning,
                sum(mmt.primary_quantity),
                sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),
                sum(1),
                sum(abs(mmt.primary_quantity)),
                sum(nvl(mmt.actual_cost,0)*abs(mmt.primary_quantity))
                from mtl_material_transactions mmt,
                        mtl_txn_source_types mtst,
                        mfg_lookups ml,
                        mtl_transaction_types mtt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.cost_group_id = cost_group_id
		and mmt.subinventory_code = sub
                and mtt.transaction_type_id = mmt.transaction_type_id
                and ml.lookup_type = 'MTL_TRANSACTION_ACTION'
                and ml.lookup_code = mmt.transaction_action_id + 0
                and mmt.transaction_action_id NOT IN (24,30)
                group by mmt.inventory_item_id,
                        mtst.transaction_source_type_name,
                        mtt.transaction_type_name,
                        ml.meaning;
*/
                /* Item, Source Type summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_source_type_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_SRCTYPE_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_source_type_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id,
                        mst.transaction_source_type_name;
*/
                /* Item, Txn Type summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_type_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_TXN_TYPES_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_type_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id,
                        mst.transaction_type_name;
*/
                /* Item, Txn action summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 inventory_item_id,
                 organization_id,
                 transaction_action_name,
                 net_qty,
                 net_val,
                 num_txns,
                 abs_qty,
                 abs_val)
                select
                sessionid,
                'ITEM_TXN_ACTION_SUMMARY',
                mst.inventory_item_id,
                min(mst.organization_id),
                mst.transaction_action_name,
                sum(mst.net_qty),
                sum(mst.net_val),
                sum(mst.num_txns),
                sum(mst.abs_qty),
                sum(mst.abs_val)
                from mtl_summary_temp mst
                where summary_type='ITEM_SRCTYPE_TXNTYPE_SUMMARY'
                and session_id = sessionid
                group by mst.inventory_item_id,
                        mst.transaction_action_name;
*/
                /* Totals Summary */
 /*               insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)
                select
                sessionid,
                'TOTALS',
                nvl(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity),0),
                nvl(sum(1),0),
                1
                from mtl_material_transactions mmt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.subinventory_code = sub
                and mmt.cost_group_id = nvl(cost_Group_id, mmt.cost_Group_id)
                and mmt.primary_quantity > 0
                and mmt.transaction_action_id NOT IN (24,30);

                insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)*/ /* This is populated for ordering purposes */
                /*select
                sessionid,
                'TOTALS',
                nvl(abs(sum(nvl(mmt.actual_cost,0)*mmt.primary_quantity)),0),
                nvl(sum(1),0),
                2
                from mtl_material_transactions mmt
                where mmt.organization_id = orgid
                and mmt.transaction_date >= NVL(sdate, mmt.transaction_date - 1)
                and mmt.transaction_date <= NVL(edate, mmt.transaction_date + 1)
                and mmt.subinventory_code = sub
                and mmt.cost_group_id = nvl(cost_group_id, mmt.locator_id)
                and mmt.primary_quantity < 0
                and mmt.transaction_action_id NOT IN (24,30);

                insert into mtl_summary_temp
                (session_id,
                 summary_type,
                 net_val,
                 num_txns,
                 locator_id)*/ /* This is populated for ordering purposes */
/*                select
                sessionid,
                'TOTALS',
                sum(mst.net_val),
                null,
                3
                from mtl_summary_temp mst
                where summary_type = 'ITEM_SUMMARY'
                and session_id = sessionid;
        exception
         when others then
                raise_application_error(-20001, sqlerrm||'---'||msgbuf);
	end sub_cost_group_summaries;*/

END INVTVTUS;

/
