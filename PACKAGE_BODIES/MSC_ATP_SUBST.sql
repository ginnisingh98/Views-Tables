--------------------------------------------------------
--  DDL for Package Body MSC_ATP_SUBST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_SUBST" AS
/* $Header: MSCSUBAB.pls 120.4 2007/12/12 10:40:07 sbnaik ship $  */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_SUBST';

MATERIAL_CONSTRAINT 	CONSTANT NUMBER := 1;
PTF_CONSTRAINT 		CONSTANT NUMBER := 2;
TRANSIT_LT_CONSTRAINT 	CONSTANT NUMBER := 5;

NOSOURCES_NONCONSTRAINT CONSTANT NUMBER := -1;
DIAGNOSTIC_ATP		CONSTANT NUMBER := 1;
ORG_DEMAND_PEG_TYP	CONSTANT NUMBER := 1;
ORG_SUPPLY_PEG_TYP	CONSTANT NUMBER := 3;
TRANSFER_PEG_TYP	CONSTANT NUMBER := 6;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE top_org_supply_qty(
   p_org_avail_info     IN OUT NoCopy MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
   p_org_idx            IN NUMBER
) IS
   j                    number;
   l_qty                number;
   l_parent             number;
   l_PO_qty             number;
BEGIN
   j := p_org_idx;

   while j <> 1 loop
        l_parent := p_org_avail_info.parent_org_idx(j);
        l_qty := p_org_avail_info.rnding_leftover(j)
                    / p_org_avail_info.conversion_rate(j);
        IF nvl(p_org_avail_info.rounding_flag(l_parent), 2) = 1 THEN
           l_qty := FLOOR(l_qty);
           p_org_avail_info.rnding_leftover(j) := p_org_avail_info.rnding_leftover(j)
              - (l_qty * p_org_avail_info.conversion_rate(j));
           l_PO_qty := FLOOR(ROUND(p_org_avail_info.demand_quantity(j)
                                   / p_org_avail_info.conversion_rate(j), 10));
        ELSE
           l_PO_qty := p_org_avail_info.demand_quantity(j);
           p_org_avail_info.rnding_leftover(j) := 0;
        END IF;
        p_org_avail_info.rnding_leftover(l_parent) :=
           nvl(p_org_avail_info.rnding_leftover(l_parent), 0) + l_qty;

        p_org_avail_info.quantity_from_children(l_parent) :=
           nvl(p_org_avail_info.quantity_from_children(l_parent), 0)
               + least(l_qty, l_PO_qty);
        --bug3467631
        --Adding the atf_date_quantity got through the supply chain.
        IF p_org_avail_info.requested_ship_date(l_parent) <=
           p_org_avail_info.atf_date(l_parent) THEN
         p_org_avail_info.Atf_Date_Quantity(l_parent) :=
           nvl(p_org_avail_info.Atf_Date_Quantity(l_parent), 0) +
           least(l_qty, l_PO_qty);
        END IF;
        --bug3467631
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('qty_from_children(' ||l_parent||'): ' ||
                p_org_avail_info.quantity_from_children(l_parent));
           msc_sch_wb.atp_debug('rnding_leftover(' ||j||'): ' ||
                p_org_avail_info.rnding_leftover(j));
        END IF;
        j := l_parent;
   end loop;

END top_org_supply_qty;

FUNCTION org_req_dmd_qty(
   p_qty                IN NUMBER,
   p_org_avail_info     IN MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
   p_org_idx            IN NUMBER
) RETURN NUMBER IS
   l_qty                number;
   l_parent             number;
BEGIN
   IF p_org_idx = 1 THEN
      msc_sch_wb.atp_debug('req_dmd_qty1: ' || p_qty);
      return p_qty;
   END IF;

   l_parent := p_org_avail_info.parent_org_idx(p_org_idx);
   l_qty := org_req_dmd_qty(p_qty, p_org_avail_info, l_parent);
   IF nvl(p_org_avail_info.rounding_flag(l_parent), 2) = 1 THEN
      l_qty := CEIL(l_qty);
   END IF;

   msc_sch_wb.atp_debug('req_dmd_qty0: ' || l_qty);
   l_qty := l_qty * p_org_avail_info.conversion_rate(p_org_idx);
   l_qty := l_qty - nvl(p_org_avail_info.rnding_leftover(p_org_idx),0);

msc_sch_wb.atp_debug('rnding_leftover('||p_org_idx||'): ' || nvl(p_org_avail_info.rnding_leftover(p_org_idx),0));
   msc_sch_wb.atp_debug('req_dmd_qty: ' || l_qty);
   return l_qty;
END org_req_dmd_qty;

PROCEDURE Extend_Org_Avail_Info_Rec (
  p_org_avail_info         IN OUT NOCOPY  MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
  x_return_status          OUT      NoCopy VARCHAR2)
IS
Begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ----
    p_org_avail_info.Organization_Id.extend;
    p_org_avail_info.Parent_Org_Idx.extend;
    p_org_avail_info.Requested_ship_date.extend;
    p_org_avail_info.Request_date_Quantity.extend;
    p_org_avail_info.demand_quantity.extend;
    p_org_avail_info.Demand_Pegging_id.extend;
    p_org_avail_info.Supply_pegging_id.extend;
    p_org_avail_info.PO_pegging_id.extend;
    p_org_avail_info.Demand_ID.extend;
    p_org_avail_info.org_code.extend;
    p_org_avail_info.Lead_time.extend;
    p_org_avail_info.Quantity_from_children.extend;
    p_org_avail_info.Atp_Flag.extend;
    p_org_avail_info.atp_comp_flag.extend;
    p_org_avail_info.post_pro_lt.extend;
    p_org_avail_info.plan_id.extend;
    p_org_avail_info.assign_set_id.extend;
    p_org_avail_info.location_id.extend;
    p_org_avail_info.demand_Class.extend;
    p_org_avail_info.steal_qty.extend;

    -- dsting diagnostic atp
    p_org_avail_info.pre_pro_lt.extend;
    p_org_avail_info.fixed_lt.extend;
    p_org_avail_info.variable_lt.extend;
    p_org_avail_info.ship_method.extend;
    p_org_avail_info.plan_name.extend;
    p_org_avail_info.rounding_flag.extend;
    p_org_avail_info.unit_weight.extend;
    p_org_avail_info.weight_uom.extend;
    p_org_avail_info.unit_volume.extend;
    p_org_avail_info.volume_uom.extend;
    p_org_avail_info.ptf_date.extend;
    p_org_avail_info.substitution_window.extend;
    p_org_avail_info.allocation_rule.extend;
    p_org_avail_info.infinite_time_fence.extend;
    p_org_avail_info.atp_rule_name.extend;
    p_org_avail_info.constraint_type.extend;
    p_org_avail_info.constraint_date.extend;

    -- 2754446
    p_org_avail_info.conversion_rate.extend;
    p_org_avail_info.primary_uom.extend;
    p_org_avail_info.req_date_unadj_qty.extend;
    p_org_avail_info.rnding_leftover.extend;

    --time_phased_atp
    p_org_avail_info.Family_sr_id.EXTEND;
    p_org_avail_info.Family_dest_id.EXTEND;
    p_org_avail_info.Family_item_name.EXTEND;
    p_org_avail_info.Atf_Date.EXTEND;
    p_org_avail_info.Atf_Date_Quantity.EXTEND;

    -- ship_rec_cal
    p_org_avail_info.shipping_cal_code.EXTEND;
    p_org_avail_info.receiving_cal_code.EXTEND;
    p_org_avail_info.intransit_cal_code.EXTEND;
    p_org_avail_info.manufacturing_cal_code.EXTEND;
    --Extend only once
    --p_org_avail_info.intransit_cal_code.EXTEND;
    --p_org_avail_info.manufacturing_cal_code.EXTEND;
    p_org_avail_info.new_ship_date.EXTEND;
    p_org_avail_info.new_dock_date.EXTEND;
    p_org_avail_info.new_start_date.EXTEND;     -- Bug 3241766
    p_org_avail_info.new_order_date.EXTEND;     -- Bug 3241766


END Extend_Org_Avail_Info_Rec;

/*------------------------- PEGGING_REC PROCEDURES ------------------------- */

PROCEDURE Prep_Common_Pegging_Rec(
	x_pegging_rec		OUT NOCOPY mrp_atp_details_temp%ROWTYPE,
	p_atp_record		IN	MRP_ATP_PVT.AtpRec,
	ORG_AVAIL_INFO   IN	MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
	p_org_idx		IN	NUMBER,
	Item_Availability_Info  IN      Item_Info_Rec_Typ,
	p_item_idx		In	NUMBER
) IS
	l_parent_org_idx	NUMBER;
BEGIN

        x_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
        x_pegging_rec.order_line_id := MSC_ATP_PVT.G_ORDER_LINE_ID;

        x_pegging_rec.organization_id := org_avail_info.organization_id(p_org_idx);

        x_pegging_rec.organization_code := org_avail_info.org_code(p_org_idx);
        x_pegging_rec.identifier1:= p_atp_record.instance_id;

        x_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(p_item_idx);
        x_pegging_rec.inventory_item_name := item_availability_info.item_name(p_item_idx);
        x_pegging_rec.resource_id := NULL;
        x_pegging_rec.resource_code := NULL;
        x_pegging_rec.department_id := NULL;
        x_pegging_rec.department_code := NULL;
        x_pegging_rec.supplier_id := NULL;
        x_pegging_rec.supplier_name := NULL;
        x_pegging_rec.supplier_site_id := NULL;
        x_pegging_rec.supplier_site_name := NULL;
	x_pegging_rec.substitution_window := item_availability_info.substitution_window(p_item_idx);

        x_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;
        --bug3467631 start
        x_pegging_rec.aggregate_time_fence_date:= org_avail_info.Atf_Date(p_org_idx);
        --populating atf date in pegging as records are deleted from alloc table
        --based on atf date also.
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Prep_Common_Pegging_Rec: ' || 'Atf_Date ' || org_avail_info.Atf_Date(p_org_idx));
           msc_sch_wb.atp_debug('Prep_Common_Pegging_Rec: ' || 'inventory_item_id ' || x_pegging_rec.inventory_item_id);
           msc_sch_wb.atp_debug('Prep_Common_Pegging_Rec: ' || 'inventory_item_name ' || x_pegging_rec.inventory_item_name);
        END IF;
        --bug3467631 end
END Prep_Common_Pegging_Rec;


PROCEDURE Prep_Demand_Pegging_Rec(
	x_pegging_rec		OUT NOCOPY mrp_atp_details_temp%ROWTYPE,
	p_atp_record		IN	MRP_ATP_PVT.AtpRec,
	ORG_AVAIL_INFO   IN	MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
	p_org_idx		IN	NUMBER,
	Item_Availability_Info  IN      Item_Info_Rec_Typ,
	p_item_idx		In	NUMBER
) IS
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec');
	END IF;

	Prep_Common_pegging_rec(x_pegging_rec,
				p_atp_record,
				org_avail_info,
				p_org_idx,
				item_availability_info,
				p_item_idx);

        IF p_org_idx = 1 THEN
		x_pegging_rec.parent_pegging_id:= null;
        ELSE
                x_pegging_rec.parent_pegging_id:= org_avail_info.PO_pegging_id(p_org_idx);
        END IF;

        --bug3467631 In Old PF case we always want to show family item else member
        IF ((item_availability_info.sr_inventory_item_id(p_item_idx) <>
                org_avail_info.family_sr_id(p_org_idx))
            and org_avail_info.atf_date(p_org_idx) is null)
        THEN
                x_pegging_rec.inventory_item_id:= org_avail_info.family_sr_id(p_org_idx);
                x_pegging_rec.inventory_item_name := org_avail_info.family_item_name(p_org_idx);
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec: ' || 'inventory_item_name ' || org_avail_info.family_item_name(p_org_idx));
           msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec: ' || 'x_pegging_rec.inventory_item_id ' || org_avail_info.family_sr_id(p_org_idx));
         END IF;
        END IF;
        --bug3467631
        x_pegging_rec.pegging_id := org_avail_info.demand_pegging_id(p_org_idx);
        x_pegging_rec.end_pegging_id := org_avail_info.demand_pegging_id(1);

        x_pegging_rec.identifier2 := org_avail_info.plan_id(p_org_idx);
        x_pegging_rec.identifier3 := org_avail_info.demand_id(p_org_idx);
        x_pegging_rec.supply_demand_source_type:= 6;

        x_pegging_rec.supply_demand_type:= 1;
        x_pegging_rec.source_type := null;
        x_pegging_rec.supply_demand_date:= org_avail_info.requested_ship_date(p_org_idx);
        x_pegging_rec.required_date:= org_avail_info.requested_ship_date(p_org_idx);

        -- for demo:1153192
        x_pegging_rec.constraint_flag := 'N';
	x_pegging_rec.component_identifier :=
             NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);

        --- bug 2152184: For PF based ATP inventory_item_id field contains id for PF item
        --- cto looks at pegging tree to place their demands. Since CTO expects to find
        --  id for the requested item, we add the following column. CTO will now read from this column
        --bug3467631
        x_pegging_rec.request_item_id := NVL(p_atp_record.request_item_id,
                                             p_atp_record.inventory_item_id);

	x_pegging_rec.pegging_type := ORG_DEMAND_PEG_TYP;

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec: ' || 'pegging_id ' || x_pegging_rec.pegging_id);
	   msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec: ' || 'parent_pegging_id ' || x_pegging_rec.parent_pegging_id);
	   msc_sch_wb.atp_debug('Prep_Demand_Pegging_Rec: ' || 'end_pegging_id ' || x_pegging_rec.end_pegging_id);
	END IF;

END Prep_Demand_Pegging_Rec;

/*
 * dsting 10/18/02
 *
 * Adds the relevant information from the
 *   - AtpRec
 *   - Org_Info_Rec_Type
 *   - Item_Info_Rec_Typ
 *   - item availabile quantity
 *
 * source_type is always TRANSFER
 * supply_demand_type is always 2
 *
 */
PROCEDURE Prep_PO_Pegging_Rec(
	x_pegging_rec		OUT NOCOPY mrp_atp_details_temp%ROWTYPE,
	p_atp_record		IN	MRP_ATP_PVT.AtpRec,
	ORG_AVAIL_INFO   IN	MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
	p_org_idx		IN	NUMBER,
	Item_Availability_Info  IN      Item_Info_Rec_Typ,
	p_item_idx		In	NUMBER,
	p_PO_qty                IN	NUMBER,
	p_transaction_id	IN	NUMBER
) IS
	l_parent_idx	NUMBER;
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec');
	END IF;

	l_parent_idx := org_avail_info.parent_org_idx(p_org_idx);

	Prep_Common_pegging_rec(x_pegging_rec,
				p_atp_record,
				org_avail_info,
				p_org_idx,
				item_availability_info,
				p_item_idx);

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'parent_idx ' || l_parent_idx);
           msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'p_org_idx ' || p_org_idx);
        END IF;

        -- time_phased_atp changes begin
        --bug3467631 start
        /*IF (item_availability_info.sr_inventory_item_id(p_item_idx) <>
                item_availability_info.family_sr_id(p_item_idx))
            and org_avail_info.requested_ship_date(l_parent_idx) > item_availability_info.atf_date(p_item_idx)
        THEN
                x_pegging_rec.inventory_item_id:= item_availability_info.family_sr_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.family_item_name(p_item_idx);
        ELSE
                x_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.item_name(p_item_idx);
        END IF;*/
        --Commenting out as atf_date and family_id are item-org attributes . A member can have
        --different family in different orgs across supply chain and similarly atf_date.
        --Handling OLD PF cases also .
        IF ((item_availability_info.sr_inventory_item_id(p_item_idx) <>
                org_avail_info.family_sr_id(p_org_idx))
            and ((org_avail_info.requested_ship_date(l_parent_idx) > org_avail_info.atf_date(p_org_idx)) OR
                 org_avail_info.atf_date(p_org_idx) is null))
        THEN
                x_pegging_rec.inventory_item_id:= org_avail_info.family_sr_id(p_org_idx);
                x_pegging_rec.inventory_item_name := org_avail_info.family_item_name(p_org_idx);
        ELSE
                x_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.item_name(p_item_idx);
        END IF;
        --bug3467631 end
        -- time_phased_atp changes end

        x_pegging_rec.parent_pegging_id:= org_avail_info.demand_pegging_id(l_parent_idx);
        x_pegging_rec.end_pegging_id := org_avail_info.demand_pegging_id(1);
        x_pegging_rec.pegging_id := org_avail_info.po_pegging_id(p_org_idx);

        x_pegging_rec.organization_id := org_avail_info.organization_id(l_parent_idx);
        x_pegging_rec.organization_code := org_avail_info.org_code(p_org_idx);

        x_pegging_rec.identifier2:= org_avail_info.plan_id(l_parent_idx);
        x_pegging_rec.identifier3 := p_transaction_id;
        x_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.TRANSFER;

        x_pegging_rec.supply_demand_quantity := p_PO_qty;
        x_pegging_rec.supply_demand_type:= 2;
        x_pegging_rec.supply_demand_date:= org_avail_info.requested_ship_date(l_parent_idx);
        x_pegging_rec.source_type :=  MSC_ATP_PVT.TRANSFER;

        -- for demo:1153192
        x_pegging_rec.component_identifier :=
                         NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);
        --bug3467631
        x_pegging_rec.request_item_id := NVL(p_atp_record.request_item_id,
                                             p_atp_record.inventory_item_id);

	-- additional columns from pegging enhancement
	x_pegging_rec.Postprocessing_lead_time := org_avail_info.post_pro_lt(l_parent_idx);
	x_pegging_rec.Intransit_lead_time := org_avail_info.Lead_time(p_org_idx);
	IF( NVL(org_avail_info.ship_method(p_org_idx), '@@@') <> '@@@' ) THEN
		x_pegging_rec.ship_method := org_avail_info.ship_method(p_org_idx);
	END IF;
	x_pegging_rec.ptf_date := org_avail_info.ptf_date(p_org_idx);

	x_pegging_rec.weight_capacity := org_avail_info.unit_weight(p_org_idx);
	x_pegging_rec.volume_capacity := org_avail_info.unit_volume(p_org_idx);

	x_pegging_rec.weight_uom := org_avail_info.weight_uom(p_org_idx);
	x_pegging_rec.volume_uom := org_avail_info.volume_uom(p_org_idx);

	x_pegging_rec.plan_name := org_avail_info.plan_name(p_org_idx);
	x_pegging_rec.rounding_control := org_avail_info.rounding_flag(p_org_idx);
        -- 2754446
	x_pegging_rec.required_quantity := org_avail_info.demand_quantity(p_org_idx)
                    / org_avail_info.conversion_rate(p_org_idx);
        IF org_avail_info.rounding_flag(l_parent_idx) = 1 THEN
           x_pegging_rec.required_quantity := CEIL(ROUND(x_pegging_rec.required_quantity,10));
        END IF;
	x_pegging_rec.required_date := org_avail_info.requested_ship_date(p_org_idx);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'required_quantity: ' || x_pegging_rec.required_quantity);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'required_date: ' || x_pegging_rec.required_date);
	END IF;

	x_pegging_rec.pegging_type := 6;
	-- Bug 3826234
	x_pegging_rec.shipping_cal_code := org_avail_info.shipping_cal_code(p_org_idx);
	x_pegging_rec.receiving_cal_code := org_avail_info.receiving_cal_code(p_org_idx);
	x_pegging_rec.intransit_cal_code := org_avail_info.intransit_cal_code(p_org_idx);
	x_pegging_rec.manufacturing_cal_code := org_avail_info.manufacturing_cal_code(p_org_idx);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'pegging_id ' || x_pegging_rec.pegging_id);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'parent_pegging_id ' || x_pegging_rec.parent_pegging_id);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'end_pegging_id ' || x_pegging_rec.end_pegging_id);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'shipping_cal_code ' || x_pegging_rec.shipping_cal_code);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'receiving_cal_code ' || x_pegging_rec.receiving_cal_code);
	   msc_sch_wb.atp_debug('Prep_PO_Pegging_Rec: ' || 'intransit_cal_code ' || x_pegging_rec.intransit_cal_code);
	END IF;

END Prep_PO_Pegging_Rec;

PROCEDURE Prep_Supply_Pegging_Rec(
	x_pegging_rec		OUT NOCOPY mrp_atp_details_temp%ROWTYPE,
	p_atp_record		IN	MRP_ATP_PVT.AtpRec,
	ORG_AVAIL_INFO   IN	MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
	p_org_idx		IN	NUMBER,
	Item_Availability_Info  IN      Item_Info_Rec_Typ,
	p_item_idx		In	NUMBER,
	p_transaction_id	IN	NUMBER
) IS
	l_parent_idx	NUMBER;
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec');
	END IF;

	l_parent_idx := org_avail_info.parent_org_idx(p_org_idx);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'parent_idx ' || l_parent_idx);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'p_org_idx ' || p_org_idx);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'item_availability_info.sr_inventory_item_id(p_item_idx) ' || item_availability_info.sr_inventory_item_id(p_item_idx));
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'item_availability_info.family_sr_id(p_item_idx) ' || item_availability_info.family_sr_id(p_item_idx));
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'org_avail_info.requested_ship_date(p_org_idx) ' || org_avail_info.requested_ship_date(p_org_idx));
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'item_availability_info.atf_date(p_item_idx) ' || item_availability_info.atf_date(p_item_idx));
	END IF;

	Prep_Common_pegging_rec(x_pegging_rec,
				p_atp_record,
				org_avail_info,
				p_org_idx,
				item_availability_info,
				p_item_idx);

        -- time_phased_atp changes begin
        --bug3467631 start
        /*IF (item_availability_info.sr_inventory_item_id(p_item_idx) <>
                item_availability_info.family_sr_id(p_item_idx))
            and org_avail_info.requested_ship_date(p_org_idx) > item_availability_info.atf_date(p_item_idx)
        THEN
                x_pegging_rec.inventory_item_id:= item_availability_info.family_sr_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.family_item_name(p_item_idx);
        ELSE
                x_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.item_name(p_item_idx);
        END IF;*/
        --Commenting out as atf_date and family_id are item-org attributes . A member can have
        --different family in different orgs across supply chain and similarly atf_date.
        --Handling OLD PF cases also .
        IF ((item_availability_info.sr_inventory_item_id(p_item_idx) <>
                org_avail_info.family_sr_id(p_org_idx))
            and ((org_avail_info.requested_ship_date(p_org_idx) > org_avail_info.atf_date(p_org_idx)) OR
                 org_avail_info.atf_date(p_org_idx) is null ))
        THEN
                x_pegging_rec.inventory_item_id:= org_avail_info.family_sr_id(p_org_idx);
                x_pegging_rec.inventory_item_name := org_avail_info.family_item_name(p_org_idx);
        ELSE
                x_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(p_item_idx);
                x_pegging_rec.inventory_item_name := item_availability_info.item_name(p_item_idx);
        END IF;
        --bug3467631 end
        -- time_phased_atp changes end

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'x_pegging_rec.inventory_item_id ' || x_pegging_rec.inventory_item_id);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'x_pegging_rec.inventory_item_name ' || x_pegging_rec.inventory_item_name);
	END IF;

        x_pegging_rec.parent_pegging_id:= org_avail_info.demand_pegging_id(p_org_idx);
        x_pegging_rec.pegging_id := org_avail_info.supply_pegging_id(p_org_idx);
        x_pegging_rec.end_pegging_id := org_avail_info.demand_pegging_id(1);
        x_pegging_rec.organization_id:= org_avail_info.organization_id(p_org_idx);
        x_pegging_rec.organization_code := org_avail_info.org_code(p_org_idx);
        x_pegging_rec.identifier2 := org_avail_info.plan_id(p_org_idx);
        x_pegging_rec.identifier3 := p_transaction_id;
        x_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
        -- dsting 2754446
--        x_pegging_rec.supply_demand_quantity:= org_avail_info.request_date_quantity(p_org_idx);
        x_pegging_rec.supply_demand_quantity:= org_avail_info.req_date_unadj_qty(p_org_idx);
        x_pegging_rec.supply_demand_date:= org_avail_info.requested_ship_date(p_org_idx);
        x_pegging_rec.supply_demand_type:= 2;
        x_pegging_rec.source_type := 0;
	x_pegging_rec.component_identifier :=
	        NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);

	IF NVL(org_avail_info.constraint_type(p_org_idx), NOSOURCES_NONCONSTRAINT)
	   <> NOSOURCES_NONCONSTRAINT
	THEN
		x_pegging_rec.constraint_type := org_avail_info.constraint_type(p_org_idx);
		x_pegging_rec.constraint_date := org_avail_info.constraint_date(p_org_idx);
	END IF;

        x_pegging_rec.request_item_id := NVL(p_atp_record.request_item_id, --bug3467631
                                             p_atp_record.inventory_item_id);

	-- dsting additional columns for diagnostic ATP
	x_pegging_rec.weight_capacity := org_avail_info.unit_weight(p_org_idx);
	x_pegging_rec.volume_capacity := org_avail_info.unit_volume(p_org_idx);
	x_pegging_rec.weight_uom := org_avail_info.weight_uom(p_org_idx);
	x_pegging_rec.volume_uom := org_avail_info.volume_uom(p_org_idx);
	x_pegging_rec.variable_lead_time := org_avail_info.variable_lt(p_org_idx);
	x_pegging_rec.fixed_lead_time := org_avail_info.fixed_lt(p_org_idx);
	x_pegging_rec.postprocessing_lead_time := org_avail_info.post_pro_lt(p_org_idx);
	x_pegging_rec.preprocessing_lead_time := org_avail_info.pre_pro_lt(p_org_idx);

	x_pegging_rec.plan_name := org_avail_info.plan_name(p_org_idx);
	x_pegging_rec.atp_flag := org_avail_info.atp_flag(p_org_idx);
	x_pegging_rec.atp_component_flag := org_avail_info.atp_comp_flag(p_org_idx);
	x_pegging_rec.rounding_control := org_avail_info.rounding_flag(p_org_idx);
	x_pegging_rec.required_quantity := org_avail_info.demand_quantity(p_org_idx);
	x_pegging_rec.required_date := org_avail_info.requested_ship_date(p_org_idx);
	x_pegging_rec.atp_rule_name := org_avail_info.atp_rule_name(p_org_idx);
	x_pegging_rec.infinite_time_fence := org_avail_info.infinite_time_fence(p_org_idx);
	x_pegging_rec.allocation_rule := org_avail_info.allocation_rule(p_org_idx);

	-- Bug 3826234
	x_pegging_rec.shipping_cal_code := org_avail_info.shipping_cal_code(p_org_idx);
	x_pegging_rec.receiving_cal_code := org_avail_info.receiving_cal_code(p_org_idx);
	x_pegging_rec.intransit_cal_code := org_avail_info.intransit_cal_code(p_org_idx);
	x_pegging_rec.manufacturing_cal_code := org_avail_info.manufacturing_cal_code(p_org_idx);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'required_quantity ' || x_pegging_rec.required_quantity);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'required_date ' || x_pegging_rec.required_date);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'infinite_time_fence ' || x_pegging_rec.infinite_time_fence);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'pegging_id ' || x_pegging_rec.pegging_id);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'parent_pegging_id ' || x_pegging_rec.parent_pegging_id);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'end_pegging_id ' || x_pegging_rec.end_pegging_id);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'shipping_cal_code ' || x_pegging_rec.shipping_cal_code);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'receiving_cal_code ' || x_pegging_rec.receiving_cal_code);
	   msc_sch_wb.atp_debug('Prep_Supply_Pegging_Rec: ' || 'intransit_cal_code ' || x_pegging_rec.intransit_cal_code);
	END IF;

	x_pegging_rec.pegging_type := ORG_SUPPLY_PEG_TYP;

END Prep_Supply_Pegging_Rec;

/*------------------------- END PEGGING_REC PROCEDURES ------------------------- */


PROCEDURE ATP_Check_Subst
              (p_atp_record                     IN OUT   NoCopy MRP_ATP_PVT.AtpRec,
               p_item_substitute_rec            IN       Item_Info_Rec_Typ,
               p_requested_ship_date            IN       DATE,
               p_plan_id                        IN       NUMBER,
               p_level                          IN       NUMBER,
               p_scenario_id                    IN       NUMBER,
               p_search                         IN       NUMBER,
               p_refresh_number                 IN       NUMBER,
               p_parent_pegging_id              IN       NUMBER,
               p_assign_set_id                  IN       NUMBER,
               x_atp_period                     OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_supply_demand              OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_return_status                  OUT      NoCopy VARCHAR2
) IS

l_parent_org_cntr       number;
l_process_org_cntr      number;
l_sources               MRP_ATP_PVT.Atp_source_typ;
l_null_sources          MRP_ATP_PVT.Atp_source_typ;
l_ship_method           varchar2(50);
l_from_location_id      number;
l_delivery_lead_time    number;
l_inventory_item_id     number;
l_requested_ship_date   date;
L_substitution_type     number;
L_ATP_FLAG              varchar2(1);
l_atp_comp_flag         varchar2(1);
l_item_cntr             number;
l_sysdate               date;
l_net_demand            number;
l_period_begin_idx      number;
l_sd_begin_idx          number;
ORG_AVAILABILITY_INFO   MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ;
l_null_org_avail_info   MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ;
l_return_status         VARCHAR2(1);
l_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
L_NULL_ATP_PERIOD       MRP_ATP_PUB.ATP_Period_Typ;
l_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
L_NULL_ATP_SUPPLY_DEMAND MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_all_atp_period        MRP_ATP_PUB.ATP_Period_Typ;
l_all_atp_supply_demand MRP_ATP_PUB.ATP_Supply_Demand_Typ;
l_org_code              VARCHAR2(7);
l_top_tier_org_code     VARCHAR2(7);
L_REQUESTED_DATE_QUANTITY number;
--bug3467631 not needed
--L_PRE_PRO_LT            number;
--L_POST_PRO_LT           number;
l_atp_insert_rec        MRP_ATP_PVT.AtpRec;
L_DEMAND_ID             number;
l_fixed_lt              number;
--L_INV_ITEM_NAME         varchar2(255);
L_ATP_DATE_THIS_LEVEL   date;
L_DEMAND_CLASS_FLAG     NUMBER := 0;
L_PEGGING_ID            number;
L_ATP_DATE_QUANTITY_THIS_LEVEL number;
L_VARIABLE_LT          number;
L_PARENT_INDEX         number;
j                      number;
i                      number;
l_period_end_idx       number;
l_sd_end_idx           number;
l_sources_found        number;
l_transfer_found       number;
L_AVAILABLE_QUANTITY   number;
l_pegging_rec          mrp_atp_details_temp%ROWTYPE;
L_PTF_DATE             date;
L_START_DATE           date;
l_dock_date            date;
l_req_ship_date        date;
L_COUNT                number;
L_TRANSACTION_ID       number;
L_DEMAND_SATISFIED_FLAG number;
l_org_item_detail_flag  number;
l_item_ctp_info         Item_Info_Rec_Typ;
l_null_item_avail_info  Item_Info_Rec_Typ;
l_item_attribute_rec    MSC_ATP_PVT.item_attribute_rec;
l_plan_info_rec         MSC_ATP_PVT.plan_info_rec;    --- for bug 2392456

L_HIGHEST_REV_ITEM_ID   number;
L_ITEM_COUNT            number;
L_ASSIGN_SET_ID         number;
l_plan_id               number;
L_SUBSTITUTION_WINDOW   number;
L_CREATE_SUPPLY_FLAG    number;
L_CREATE_SUPPLY_ON_ORIG_ITEM number;
L_NET_DEMAND_AFTER_OH_CHECK  number;
L_SATISFIED_BY_SUBST_FLAG    number;
L_ITEM_IDX                   number;
L_HIGHEST_REV_ITEM_INDEX     number;
l_atp_rec                    MRP_ATP_PVT.AtpRec;
l_atp_date                   date;
Item_Availability_Info       Item_Info_Rec_Typ;
l_item_name                  varchar2(250);
L_TO_LOCATION_ID             number;
l_insert_flag                number;
l_demand_pegging_id          number;
l_sys_date_top_org            date;

--- alloc ATP
g_atp_record                  MRP_ATP_PVT.AtpRec;
l_stealing_requested_date_qty   NUMBER := 0.0;
l_stealing_qty                  NUMBER := 0.0;
l_demand_class                  varchar2(30);

--forward steal
l_atp_pegging_tab               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_fwd_atp_pegging_tab           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();

-- dsting diag_atp
l_make_buy_cd			NUMBER;
l_ptf_due_date			DATE;
l_lt_due_date			DATE;
l_get_mat_in_rec		MSC_ATP_REQ.get_mat_in_rec;
l_get_mat_out_rec		MSC_ATP_REQ.get_mat_out_rec;

-- dsting for balancing planned orders
l_diag_supply_qty	NUMBER;
l_diag_transaction_id 	NUMBER;

-- dsting 2754446 in parent org's uom
l_PO_qty                NUMBER;
l_post_stealing_dmd     NUMBER;
l_avail_qty_top_uom     NUMBER;
l_orig_net_dmd          NUMBER;
l_addt_qty              NUMBER;
l_process_org_dmd       NUMBER;

--s_cto_rearch
l_null_item_sourcing_info_rec  MSC_ATP_CTO.item_sourcing_info_rec;
l_item_sourcing_info_rec  MSC_ATP_CTO.item_sourcing_info_rec;

-- time_phased_atp
l_mat_atp_info_rec              MSC_ATP_REQ.Atp_Info_Rec;
l_atf_date_qty                  NUMBER;
l_time_phased_atp               VARCHAR2(1) := 'N';
l_mem_stealing_qty              NUMBER;
l_pf_stealing_qty               NUMBER;
l_used_available_quantity       NUMBER; --bug3409973

-- ship_rec_cal changes
l_shipping_cal_code		VARCHAR2(14);
l_receiving_cal_code		VARCHAR2(14);
l_manufacturing_cal_code	VARCHAR2(14);
l_intransit_cal_code		VARCHAR2(14);
l_dest_mfg_cal_code             VARCHAR2(14);
l_new_ship_date                 DATE;
l_new_dock_date                 DATE;
l_planned_order_date            DATE;
l_order_date                    DATE;   -- Bug 3241766

-- To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
l_item_to_use                   NUMBER;

--bug3583705
l_encoded_text                  varchar2(4000);
l_msg_app                       varchar2(50);
l_msg_name                      varchar2(30);
-- bug3578083 - PTF constraint should be added only if plan is PTF enabled
l_ptf_enabled                   NUMBER;
l_trunc_sysdate                 DATE := TRUNC(sysdate); --bug3578083

-- ATP4drp Declare a variable for creating Planned Arrival.
l_supply_rec                    MSC_ATP_DB_UTILS.supply_rec_typ;
-- End ATP4drp

BEGIN
/* Logic for onhand search:
   Table item_availability_info : Stores information about item and its substitutes
   Table Org_availability_info  : Stores information about an item in organizations in supply chain

*/

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Point 2');
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || '****  Begin Check_ATP_Subst ***');
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || '********** INPUT DATA: p_atp_record **********');
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Inventory_Item_Id:' || to_char(p_atp_record.Inventory_Item_Id) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_id:' || to_char(p_atp_record.request_item_id) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'organization_id:' || to_char(p_atp_record.organization_id) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Quantity_Ordered:' || to_char(p_atp_record.Quantity_Ordered) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Quantity_UOM:' || p_atp_record.Quantity_UOM );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Requested_Ship_Date:' || to_char(p_atp_record.Requested_Ship_Date) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Requested_Arrival_Date:' || to_char(p_atp_record.Requested_Arrival_Date) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Latest_Acceptable_Date:' || to_char(p_atp_record.Latest_Acceptable_Date) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Delivery_Lead_Time:' || to_char(p_atp_record.Delivery_Lead_Time) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Freight_Carrier:' || p_atp_record.Freight_Carrier );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Ship_Method:' || p_atp_record.Ship_Method );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Demand_Class:' || p_atp_record.Demand_Class );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Override_Flag:' || p_atp_record.Override_Flag );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Action:' || to_char(p_atp_record.Action) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Ship_Date:' || to_char(p_atp_record.Ship_Date) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Available_Quantity:' || to_char(p_atp_record.Available_Quantity) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Requested_Date_Quantity:' || to_char(p_atp_record.Requested_Date_Quantity) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'supplier_id:' || to_char(p_atp_record.supplier_id) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'supplier_site_id:' || to_char(p_atp_record.supplier_site_id) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Insert_Flag:' || to_char(p_atp_record.Insert_Flag) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error_Code:' || to_char(p_atp_record.Error_Code) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Order_Number:' || to_char(p_atp_record.Order_Number) );
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'P_scenario_id := ' || p_scenario_id);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'G_DIAGNOSTIC_ATP ' || MSC_ATP_PVT.G_DIAGNOSTIC_ATP);
      -- Bug 3826234
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'shipping_cal_code ' || p_atp_record.shipping_cal_code);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'manufacturing_cal_code ' || p_atp_record.manufacturing_cal_code);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'receiving_cal_code ' || p_atp_record.receiving_cal_code);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'intransit_cal_code ' || p_atp_record.intransit_cal_code);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'to_organization_id ' || p_atp_record.to_organization_id);
   END IF;
   --- first we set the Request Item's sr_inv_id to a global variable
   --bug3467631 In PF cases request_item_id has member_id
   --MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID := p_atp_record.inventory_item_id;
   MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID := NVL(p_atp_record.request_item_id,
                                                p_atp_record.inventory_item_id);
   item_availability_info := p_item_substitute_rec;

   IF PG_DEBUG in ('Y', 'C') THEN
      FOR i in 1..item_availability_info.inventory_item_id.count LOOP
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Sr Item ID : ' || item_availability_info.sr_inventory_item_id(i) ||
                           ',  item name : ' || item_availability_info.item_name(i) ||
                           ',  atp_flag := ' || item_availability_info.atp_flag(i)  ||
                           ', atp_comp_flag := ' || item_availability_info.atp_comp_flag(i) ||
                           ', create supply flag := ' || item_availability_info.create_supply_flag(i));
      END LOOP;
   END IF;
   l_requested_ship_date := p_requested_ship_date;

   l_substitution_type := p_atp_record.substitution_type;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'substitution_type := ' || l_substitution_type);
   END IF;

   l_org_item_detail_flag := NVL(p_atp_record.req_item_detail_flag, 2);
   l_substitution_type := ALL_OR_NOTHING;
   --l_org_item_detail_flag := 1;

   l_item_count := item_availability_info.inventory_item_id.count;
   l_inventory_item_id := item_availability_info.inventory_item_id(l_item_count);
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_inventory_item_id := ' || l_inventory_item_id);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_count := ' || l_item_count);
   END IF;
   IF item_availability_info.inventory_item_id.count > 0 THEN
      l_highest_rev_item_id := NVL(item_availability_info.highest_revision_item_id(1),
                                   item_availability_info.inventory_item_id(l_item_count));
   ELSE
      l_highest_rev_item_id := l_inventory_item_id;
   END IF;

   -- dsting If we do not create supply on the original item then set the flag to 0
   IF (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG not in (G_DEMANDED_ITEM, G_ITEM_ATTRIBUTE) AND
       NOT (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM AND
             l_highest_rev_item_id = item_availability_info.inventory_item_id(l_item_count)))
      OR item_availability_info.create_supply_flag(l_item_count) <> 1
   THEN
	l_create_supply_on_orig_item := 0;
   ELSE
	l_create_supply_on_orig_item := 1;
   END IF;

   l_sys_date_top_org := NVL(MSC_ATP_FUNC.prev_work_day(p_atp_record.organization_id,
                                              p_atp_record.instance_id,
                                              sysdate), sysdate);
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sys_date_top_org := ' ||l_sys_date_top_org);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_substitution_type := ' || NVL(l_substitution_type, -1));
   END IF;

   --- now check how do we need to process the request
   IF NVL(l_substitution_type, 4) = 3 THEN
      --- we look at item attribute to see what kind of substitution do we need to do
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'look at item attribute');
      END IF;
      If item_availability_info.inventory_item_id.count > 1 THEN
         -- substitutes exist
         l_substitution_type := item_availability_info.partial_fulfillment_flag(1);
      Else
         --- we dont have any substitute. we will process it as 'All or nothing'
         l_substitution_type := ALL_OR_NOTHING;
      END IF;
   ELSIF NVL(l_substitution_type, 4) = NO_SUBSTITUTION THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Not doing substitution');
         END IF;
         -- in this case also we process it as 'All or nothing'
         l_substitution_type := ALL_OR_NOTHING;
   END IF;

   l_net_demand := p_atp_record.quantity_ordered;
   -- 2754446
   l_orig_net_dmd := l_net_demand;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand := ' || l_net_demand);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_substitution_type := ' || NVL(l_substitution_type,-1));
   END IF;
   --- this is done for testing
   l_substitution_type :=  ALL_OR_NOTHING;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sysdate_top_org := ' || l_sys_date_top_org);
      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_substitution_type := ' || NVL(l_substitution_type,-1));
   END IF;
   IF l_substitution_type = ALL_OR_NOTHING THEN

      --- first check on-hand/scheduled receipt by request date
      --WHILE l_item_cntr <= item_availability_info.inventory_item_id.count AND
      --      l_net_demand > 0 LOOP  --- item loop
      FOR l_item_cntr in reverse 1..item_availability_info.inventory_item_id.count LOOP
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Processing item := ' || item_availability_info.inventory_item_id(l_item_cntr) || '  '
                                                    || item_availability_info.item_name(l_item_cntr));
         END IF;

         IF l_net_demand <= 0 THEN
              EXIT;
         END IF;
         --- reste the net demand
         l_net_demand := p_atp_record.quantity_ordered ;
         l_parent_org_cntr := 1;
         l_process_org_cntr := 1;
         -- dsting 2754446
         l_parent_index := 1;
         l_orig_net_dmd := l_net_demand;

         --add the supply demand and period details to output table
         IF l_item_cntr = l_item_count THEN

            l_period_begin_idx := 1;
            l_sd_begin_idx := 1;

         ELSE
            l_period_begin_idx := l_all_atp_period.level.count + 1;
            l_sd_begin_idx     := l_all_atp_supply_demand.level.count + 1;
         END IF;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_period_begin_idx := ' || l_period_begin_idx);
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sd_begin_idx := ' || l_sd_begin_idx);
         END IF;

         item_availability_info.period_detail_begin_idx(l_item_cntr) := l_period_begin_idx;
         item_availability_info.sd_detail_begin_idx(l_item_cntr) := l_sd_begin_idx;

         ---for each item we reset the org_availability_info record of tables
         org_availability_info := l_null_org_avail_info;

         MSC_ATP_SUBST.Extend_Org_Avail_Info_Rec(org_availability_info, l_return_status);
         org_availability_info.organization_id(1) := p_atp_record.organization_id;
         org_availability_info.requested_ship_date(1) := l_requested_ship_date ;
         -- Bug 3371817 - assigning calendars
         org_availability_info.shipping_cal_code(1)   := p_atp_record.shipping_cal_code;
         org_availability_info.receiving_cal_code(1)  := p_atp_record.receiving_cal_code;
         org_availability_info.intransit_cal_code(1)  := p_atp_record.intransit_cal_code;
         org_availability_info.manufacturing_cal_code(1)  := p_atp_record.manufacturing_cal_code; -- Bug 3826234

         -- dsting 2754446
         org_availability_info.primary_uom(1) := p_atp_record.quantity_uom;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Top org uom: ' || p_atp_record.quantity_uom);
         END IF;


         --- loop through all orgs in supply chain to find item's availability in each org by request
         --- date

         WHILE l_parent_org_cntr <= org_availability_info.organization_id.count and l_net_demand > 0 LOOP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand : = ' || l_net_demand);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'org count := ' || org_availability_info.organization_id.count);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_org_cntr := ' || l_parent_org_cntr);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_process org cntr := ' || l_process_org_cntr);
            END IF;
            --- get plan_id in for each item org combo
            IF l_item_cntr = l_item_count and l_process_org_cntr = 1 THEN
               l_plan_id := p_plan_id;
               l_assign_set_id := p_assign_set_id;
               org_availability_info.plan_name(1) := item_availability_info.plan_name(1);
            ELSE
               /*
	        MSC_ATP_PROC.Get_Plan_Info(p_atp_record.instance_id,
                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                            org_availability_info.organization_id(l_process_org_cntr),
                            p_atp_record.demand_class,
                            l_plan_id,
                            l_assign_set_id);
		*/
		-- changes start for bug 2392456
                /*MSC_ATP_PROC.Get_Plan_Info(p_atp_record.instance_id,
                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                            org_availability_info.organization_id(l_process_org_cntr),
                            p_atp_record.demand_class,
                            l_plan_info_rec);*/
                IF l_process_org_cntr = 1 THEN
                   --bug3510475 Same Org different Item.Switch plan
                   MSC_ATP_PROC.Get_Plan_Info(p_atp_record.instance_id,
                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                            org_availability_info.organization_id(l_process_org_cntr),
                            p_atp_record.demand_class,
                            l_plan_info_rec,
                            NULL);
                ELSE
                   --bug3510475 Same Item, different Org. use parent plan id
                   MSC_ATP_PROC.Get_Plan_Info(p_atp_record.instance_id,
                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                            org_availability_info.organization_id(l_process_org_cntr),
                            p_atp_record.demand_class,
                            l_plan_info_rec,
                            p_plan_id);
                END IF;
                l_plan_id               := l_plan_info_rec.plan_id;
                l_assign_set_id         := l_plan_info_rec.assignment_set_id;
                -- changes end for bug 2392456

               IF l_plan_id in (-1, -100) THEN
                  --- this should not happen but if we do not find plan for this item then
                  --- we do atp in requested item's plan
                  l_plan_id := p_plan_id;
                  l_assign_set_id := p_assign_set_id;
               END IF;

	       -- dsting diagnostic atp
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'plan_name: ' || l_plan_info_rec.plan_name || ' process org: ' || l_process_org_cntr);
               END IF;
	       org_availability_info.plan_name(l_process_org_cntr) := l_plan_info_rec.plan_name;

            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_plan_id := ' || l_plan_id);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_assign_set_id := ' || l_assign_set_id);
            END IF;
            --- get org code for pegging purpose
            -- store this info for top org
            -- we will use this info for CTP
            IF l_process_org_cntr = 1 THEN
               item_availability_info.plan_id(l_item_cntr) := l_plan_id;
               item_availability_info.assign_set_id(l_item_cntr) := l_assign_set_id;
            END IF;
            org_availability_info.plan_id(l_process_org_cntr) := l_plan_id;
            org_availability_info.assign_set_id(l_process_org_cntr) := l_assign_set_id;

            l_org_code := MSC_ATP_FUNC.get_org_code(p_atp_record.instance_id,
                                       org_availability_info.organization_id(l_process_org_cntr));
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_org_code := ' || l_org_code);
            END IF;
            IF l_process_org_cntr = 1 THEN
               l_top_tier_org_code := l_org_code;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_top_tier_org_code := ' || l_top_tier_org_code);
               END IF;
            END IF;
            org_availability_info.org_code(l_process_org_cntr) := l_org_code;

            -- ATP4drp Do not fetch family data for DRP plans.
            IF l_plan_info_rec.plan_type <> 5 THEN
               /* time_phased_atp
                  populate family_id and atf_date*/
               MSC_ATP_PF.Get_Family_Item_Info(
                  p_atp_record.instance_id,
                  l_plan_id,
                  item_availability_info.inventory_item_id(l_item_cntr),
                  org_availability_info.organization_id(l_process_org_cntr),
                  org_availability_info.family_dest_id(l_process_org_cntr),
                  org_availability_info.family_sr_id(l_process_org_cntr),
                  org_availability_info.atf_date(l_process_org_cntr),
                  --bug3700564
                  org_availability_info.family_item_name(l_process_org_cntr),
                  l_return_status
               );
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Get_Family_Item_Info');
                   END IF;
                   RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE -- DRP plan re-set variables.
               -- Allocated and PF ATP de-supported for DRP Plans.
               MSC_ATP_PVT.G_ALLOCATED_ATP := 'N';
               org_availability_info.family_sr_id(l_process_org_cntr)  :=
                                        item_availability_info.sr_inventory_item_id(l_item_cntr);
               org_availability_info.family_dest_id(l_process_org_cntr)  :=
                                        item_availability_info.inventory_item_id(l_item_cntr);
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'PF and Allocated ATP not supported for DRP Plans');
                  msc_sch_wb.atp_debug('Re-Set Family sr ITEM ID : ' || org_availability_info.family_sr_id(l_process_org_cntr));
                  msc_sch_wb.atp_debug('Re-Set Family ITEM ID: ' || org_availability_info.family_dest_id(l_process_org_cntr));
                  msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
               END IF;
            END IF;
            -- End ATP4drp

            /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
               Set global variable. This is used in Get_Item_Demand_Alloc_Percent function*/
            IF org_availability_info.atf_date(l_process_org_cntr) is not null THEN
                   /* Set global variable. This is used in Get_Item_Demand_Alloc_Percent function*/
                   MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'Y';
            ELSE
                   MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'N';
            END IF;

            -- dsting 2754446 Add uom conversion
            -- l_net_demand and demand_quantity stays in request org's uom
            IF l_process_org_cntr = 1 THEN
                       org_availability_info.conversion_rate(l_process_org_cntr) := 1;
            ELSE
               MSC_ATP_PROC.inv_primary_uom_conversion(p_atp_record.instance_id,
                         org_availability_info.organization_id(l_process_org_cntr),
                         item_availability_info.sr_inventory_item_id(l_item_cntr),
                         org_availability_info.primary_uom(l_parent_index),
                         org_availability_info.primary_uom(l_process_org_cntr),
                         org_availability_info.conversion_rate(l_process_org_cntr));
            END IF;
            -- 2754446
            org_availability_info.demand_quantity(l_process_org_cntr) :=
                org_req_dmd_qty(l_net_demand, org_availability_info, l_process_org_cntr);
--            org_availability_info.demand_quantity(l_process_org_cntr) := l_net_demand;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('process org: ' || org_availability_info.organization_id(l_process_org_cntr));
               msc_sch_wb.atp_debug('UOM process org: ' || org_availability_info.primary_uom(l_process_org_cntr));
               msc_sch_wb.atp_debug('conversion rate: ' || org_availability_info.conversion_rate(l_process_org_cntr));
               msc_sch_wb.atp_debug('demand_quantity ' ||  l_org_code || ' ' || org_availability_info.demand_quantity(l_process_org_cntr));
            END IF;
            --- get item attributes
            IF l_process_org_cntr = 1 and l_item_cntr = l_item_count THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'No Need to get item attributes');
               END IF;
               --we have already got values for requested item in top org
               org_availability_info.atp_flag(l_process_org_cntr) := item_availability_info.atp_flag(l_item_cntr);
               org_availability_info.atp_comp_flag(l_process_org_cntr) := item_availability_info.atp_comp_flag(l_item_cntr);
               org_availability_info.post_pro_lt(l_process_org_cntr) := item_availability_info.post_pro_lt(l_item_cntr);
               org_availability_info.pre_pro_lt(l_process_org_cntr) := item_availability_info.pre_pro_lt(l_item_cntr);
               org_availability_info.variable_lt(l_process_org_cntr) := item_availability_info.variable_lt(l_item_cntr);
               org_availability_info.fixed_lt(l_process_org_cntr) := item_availability_info.fixed_lt(l_item_cntr);
               --- if it the req item then we dont want to consider substitution window
               l_substitution_window := 0;
               l_create_supply_flag := item_availability_info.create_supply_flag(l_item_cntr);

	       -- dsting for diagnostic atp
	       org_availability_info.rounding_flag(l_process_org_cntr) := item_availability_info.rounding_control_type(l_item_cntr);
	       org_availability_info.weight_uom(l_process_org_cntr) := item_availability_info.weight_uom(l_item_cntr);
	       org_availability_info.unit_weight(l_process_org_cntr) := item_availability_info.unit_weight(l_item_cntr);
	       org_availability_info.unit_volume(l_process_org_cntr) := item_availability_info.unit_volume(l_item_cntr);
	       org_availability_info.volume_uom(l_process_org_cntr) := item_availability_info.volume_uom(l_item_cntr);
            ELSE
               /*MSC_ATP_PROC.get_item_attributes(p_atp_record.instance_id,
                                            -1,
                                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                                            org_availability_info.organization_id(l_process_org_cntr),
                                            l_item_attribute_rec);*/
               MSC_ATP_PROC.get_global_item_info(p_atp_record.instance_id,
                                            --bug 3917625: Read item attributes from planned data
                                            -- -1,
                                            l_plan_id,
                                            item_availability_info.sr_inventory_item_id(l_item_cntr),
                                            org_availability_info.organization_id(l_process_org_cntr),
                                            l_item_attribute_rec);--bug3298426

               l_item_attribute_rec := MSC_ATP_PVT.G_ITEM_INFO_REC;--bug3298426
               -- store values
               org_availability_info.atp_flag(l_process_org_cntr) := l_item_attribute_rec.atp_flag;
               org_availability_info.atp_comp_flag(l_process_org_cntr) := l_item_attribute_rec.atp_comp_flag;
               org_availability_info.post_pro_lt(l_process_org_cntr) := l_item_attribute_rec.post_pro_lt;
               org_availability_info.pre_pro_lt(l_process_org_cntr) := l_item_attribute_rec.pre_pro_lt;
               org_availability_info.fixed_lt(l_process_org_cntr) := l_item_attribute_rec.fixed_lt;
               org_availability_info.variable_lt(l_process_org_cntr) := l_item_attribute_rec.variable_lt;
	       -- dsting diagnostic atp
	       org_availability_info.rounding_flag(l_process_org_cntr) := l_item_attribute_rec.rounding_control_type;
	       org_availability_info.weight_uom(l_process_org_cntr) := l_item_attribute_rec.weight_uom;
	       org_availability_info.unit_weight(l_process_org_cntr) := l_item_attribute_rec.unit_weight;
	       org_availability_info.unit_volume(l_process_org_cntr) := l_item_attribute_rec.unit_volume;
	       org_availability_info.volume_uom(l_process_org_cntr) := l_item_attribute_rec.volume_uom;
               -- dsting 2754446
	       org_availability_info.primary_uom(l_process_org_cntr) := l_item_attribute_rec.uom_code;

               l_substitution_window := l_item_attribute_rec.substitution_window;
               IF l_process_org_cntr > 1 or (l_process_org_cntr = 1 and l_item_cntr = l_item_count) THEN
                  -- we reset subst_window to zero for org lower than the top org
                  -- because in Get mat atp info we do not want to offset req date by subts window
                  -- to compare the resultant with x_atp_date this level as we need this
                  -- in top org only
                  -- also we set the substitution window to be zero for the req item
                  l_substitution_window := 0;
               END IF;
               l_create_supply_flag := l_item_attribute_rec.create_supply_flag;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_substitution_window := ' || l_substitution_window);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_create_supply_flag := '||l_create_supply_flag);
            END IF;

            IF l_process_org_cntr = 1 and l_item_cntr <> l_item_count THEN
               item_availability_info.atp_flag(l_item_cntr) := l_item_attribute_rec.atp_flag;
               item_availability_info.atp_comp_flag(l_item_cntr)
                                              := l_item_attribute_rec.atp_comp_flag;
               item_availability_info.substitution_window(l_item_cntr) := l_substitution_window;
               item_availability_info.create_supply_flag(l_item_cntr) := l_create_supply_flag;

		-- diag_atp
               item_availability_info.post_pro_lt(l_item_cntr) := l_item_attribute_rec.post_pro_lt;
               item_availability_info.pre_pro_lt(l_item_cntr) := l_item_attribute_rec.pre_pro_lt;
               item_availability_info.variable_lt(l_item_cntr) := l_item_attribute_rec.variable_lt;
               item_availability_info.fixed_lt(l_item_cntr) := l_item_attribute_rec.fixed_lt;
               item_availability_info.volume_uom(l_item_cntr) := l_item_attribute_rec.volume_uom;
               item_availability_info.unit_volume(l_item_cntr) := l_item_attribute_rec.unit_volume;
               item_availability_info.weight_uom(l_item_cntr) := l_item_attribute_rec.weight_uom;
               item_availability_info.unit_weight(l_item_cntr) := l_item_attribute_rec.unit_weight;

            END IF;
            ---alloc
            IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') THEN
               /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
                  Making changes to support new allocation logic for time_phased_atp changes too that were missed
                  out earlier as part of this exercise*/
               IF org_availability_info.atf_date(l_process_org_cntr) is not null THEN
                      MSC_ATP_PF.Set_Alloc_Rule_Variables(
                          item_availability_info.inventory_item_id(l_item_cntr),
                          --bug3467631 family_dest_id is item-org attribute
                          --item_availability_info.family_dest_id(l_item_cntr),
                          org_availability_info.family_dest_id(l_process_org_cntr),
                          org_availability_info.organization_id(l_process_org_cntr),
                          p_atp_record.instance_id,
                          p_atp_record.demand_class,
                          org_availability_info.atf_date(l_process_org_cntr),
                          l_return_status
                      );
                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Set_Alloc_Rule_Variables');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                      END IF;

                      IF l_requested_ship_date <= org_availability_info.atf_date(l_process_org_cntr) THEN
                          IF MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' THEN
                              l_item_to_use := item_availability_info.inventory_item_id(l_item_cntr);
                          ELSE
                              --bug3467631 family_dest_id is item-org attribute
                              --l_item_to_use := item_availability_info.family_dest_id(l_item_cntr);
                              l_item_to_use := org_availability_info.family_dest_id(l_process_org_cntr);
                          END IF;
                      ELSE
                          IF MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y' THEN
                              --bug3467631 family_dest_id is item-org attribute
                              --l_item_to_use := item_availability_info.family_dest_id(l_item_cntr);
                              l_item_to_use := org_availability_info.family_dest_id(l_process_org_cntr);
                          ELSE
                              l_item_to_use := item_availability_info.inventory_item_id(l_item_cntr);
                          END IF;
                      END IF;
               ELSE
                      l_item_to_use := item_availability_info.inventory_item_id(l_item_cntr);
               END IF;
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_requested_ship_date = '||l_requested_ship_date);
                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Item to be used = '||l_item_to_use);
               END IF;
               /* New allocation logic for time_phased_atp changes end */

               --- get the demand class
               l_demand_class :=
                  MSC_AATP_FUNC.Get_Hierarchy_Demand_Class(MSC_ATP_PVT.G_PARTNER_ID,
                           MSC_ATP_PVT.G_PARTNER_SITE_ID,
                           l_item_to_use,
                           org_availability_info.organization_id(l_process_org_cntr),
                           p_atp_record.instance_id,
                           l_requested_ship_date,
                           NULL, -- level_id
                           p_atp_record.demand_class);
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'after getting the dummy demand class');
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand_class = '|| l_demand_class);
               END IF;

               org_availability_info.demand_class(l_process_org_cntr) := l_demand_class;
	       org_availability_info.allocation_rule(l_process_org_cntr) := MSC_ATP_PVT.G_ALLOCATION_RULE_NAME;

               --- we store demand class for top org so that we can use it during CTP/ Forward search etc
               IF l_process_org_cntr = 1 THEN
                  item_availability_info.demand_class(l_item_cntr) := l_demand_class;
               END IF;
            END IF;
            --Do material check
            l_atp_flag := org_availability_info.atp_flag(l_process_org_cntr);
            l_atp_comp_flag := org_availability_info.atp_comp_flag(l_process_org_cntr);
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_flag := ' || l_atp_flag);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_comp_flag := ' || l_atp_comp_flag);
            END IF;
            IF l_atp_flag = 'N' and l_atp_comp_flag = 'N' THEN
               IF l_process_org_cntr = 1
                   and org_availability_info.requested_ship_date(l_process_org_cntr) < l_sys_date_top_org THEN
                  l_requested_date_quantity := 0;
               ELSE
                  ---request date > sys date and process_org > 1
                  --- if request date < sysdate and process_org > 1: This would never happen as we
                  --- would never add this org to the list of orgs
                  -- 2754446
                  --l_requested_date_quantity := l_net_demand;
                  l_requested_date_quantity := org_availability_info.demand_quantity(l_process_org_cntr);
                  l_net_demand := 0;
               END IF;
               org_availability_info.request_date_quantity(l_process_org_cntr) := l_requested_date_quantity;

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Item is not atpable');
               END IF;
            ELSE
		l_get_mat_in_rec.rounding_control_flag := org_availability_info.rounding_flag(l_process_org_cntr);
		l_get_mat_in_rec.dest_inv_item_id := item_availability_info.inventory_item_id(l_item_cntr);
               IF l_atp_flag in ('Y', 'C') THEN

                   -- 2754446
                   --l_PO_qty := l_net_demand * org_availability_info.conversion_rate(l_parent_index);
                   l_PO_qty := org_req_dmd_qty(l_net_demand, org_availability_info, l_parent_index);
                   IF nvl(org_availability_info.rounding_flag(l_process_org_cntr), 2) = 1 THEN
                      l_PO_qty := CEIL(l_PO_qty);
                   END IF;
                   -- time_phased_atp changes begin
                   l_mat_atp_info_rec.instance_id               := p_atp_record.instance_id;
                   l_mat_atp_info_rec.plan_id                   := l_plan_id;
                   l_mat_atp_info_rec.level                     := p_level;
                   l_mat_atp_info_rec.identifier                := p_atp_record.identifier;
                   l_mat_atp_info_rec.scenario_id               := p_scenario_id;
                   l_mat_atp_info_rec.inventory_item_id         := org_availability_info.family_sr_id(l_process_org_cntr);
                   l_mat_atp_info_rec.request_item_id           := item_availability_info.sr_inventory_item_id(l_item_cntr);
                   l_mat_atp_info_rec.organization_id           := org_availability_info.organization_id(l_process_org_cntr);
                   l_mat_atp_info_rec.requested_date            := org_availability_info.requested_ship_date(l_process_org_cntr);
                   l_mat_atp_info_rec.quantity_ordered          := l_PO_qty * org_availability_info.conversion_rate(l_process_org_cntr);
                   l_mat_atp_info_rec.demand_class              := l_demand_Class;
                   l_mat_atp_info_rec.insert_flag               := p_atp_record.insert_flag;
                   l_mat_atp_info_rec.rounding_control_flag     := l_get_mat_in_rec.rounding_control_flag;
                   l_mat_atp_info_rec.dest_inv_item_id          := l_get_mat_in_rec.dest_inv_item_id;
                   l_mat_atp_info_rec.infinite_time_fence_date  := l_get_mat_in_rec.infinite_time_fence_date;
                   l_mat_atp_info_rec.plan_name                 := l_get_mat_in_rec.plan_name;
                   l_mat_atp_info_rec.optimized_plan            := l_get_mat_in_rec.optimized_plan;
                   ---since it is a backward material check we pass window as zero
                   l_mat_atp_info_rec.substitution_window       := 0;
                   l_mat_atp_info_rec.refresh_number            := p_refresh_number;
                   l_mat_atp_info_rec.atf_date                  := org_availability_info.atf_date(l_process_org_cntr);
                   l_mat_atp_info_rec.shipping_cal_code         := org_availability_info.shipping_cal_code(l_process_org_cntr); -- Bug 3371817

                   MSC_ATP_REQ.Get_Material_Atp_Info(
                           l_mat_atp_info_rec,
                           l_atp_period,
                           l_atp_supply_demand,
                           l_return_status);

                   l_requested_date_quantity                    := l_mat_atp_info_rec.requested_date_quantity;
                   l_atf_date_qty                               := l_mat_atp_info_rec.atf_date_quantity;
                   l_atp_date_this_level                        := l_mat_atp_info_rec.atp_date_this_level;
                   l_atp_date_quantity_this_level               := l_mat_atp_info_rec.atp_date_quantity_this_level;
                   l_get_mat_out_rec.atp_rule_name              := l_mat_atp_info_rec.atp_rule_name;
                   l_get_mat_out_rec.infinite_time_fence_date   := l_mat_atp_info_rec.infinite_time_fence_date;

                   --bug3467631 start
                   IF (l_mat_atp_info_rec.inventory_item_id <> l_mat_atp_info_rec.request_item_id)
                      and (l_mat_atp_info_rec.atf_date is not null) --added atf_date constraint
                      --also while setting l_time_phased_atp := 'Y'
                   THEN
                      l_time_phased_atp := 'Y';
                   ELSE
                      l_time_phased_atp := 'N';
                   END IF;

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'atf_date := ' || l_mat_atp_info_rec.atf_date);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_time_phased_atp := ' || l_time_phased_atp);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atf_date_qty := ' || l_atf_date_qty);
                   END IF;
                   --bug3467631 end
                   -- time_phased_atp changes end

                   -- dsting 2754446
                   org_availability_info.req_date_unadj_qty(l_process_org_cntr) := l_requested_date_quantity;
                   org_availability_info.rnding_leftover(l_process_org_cntr) :=
                      nvl(org_availability_info.rnding_leftover(l_process_org_cntr),0)
                      + greatest(0,l_requested_date_quantity);
                   --bug3467631 setting atf_date_quantity to be passed correctly to top_org_supply_qty
                   org_availability_info.atf_date_quantity(l_process_org_cntr) := l_atf_date_qty;
                   top_org_supply_qty(org_availability_info, l_process_org_cntr);
                   -- dsting 2754446 round down l_requested_date_quantity so it can open a
                   -- whole numbered PO in the parent org

                   IF nvl(org_availability_info.rounding_flag(l_process_org_cntr), 2) = 1 THEN
                      l_requested_date_quantity := FLOOR(ROUND(l_requested_date_quantity
                               / org_availability_info.conversion_rate(l_process_org_cntr), 10)
                          ) * org_availability_info.conversion_rate(l_process_org_cntr);
                   ELSE
                      l_requested_date_quantity := l_requested_date_quantity;
                   END IF;

		   -- dsting diagnostic atp
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('rounding_flag: ' || org_availability_info.rounding_flag(l_process_org_cntr));
                      msc_sch_wb.atp_debug('parent index: ' || l_parent_index);
                      msc_sch_wb.atp_debug('process org cntr: ' || l_process_org_cntr);
                      msc_sch_wb.atp_debug('parent conversion rate: ' || org_availability_info.conversion_rate(l_parent_index));
                      msc_sch_wb.atp_debug('process org conversion rate: ' || org_availability_info.conversion_rate(l_process_org_cntr));
                      msc_sch_wb.atp_debug('l_requested_date_quantity: ' || l_requested_date_quantity);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'after get_material_atp_info');
		      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'infinite_time_fenc_date ' || l_get_mat_out_rec.infinite_time_fence_date ||
			' atp_rule_name ' || l_get_mat_out_rec.atp_rule_name);
		   END IF;
   		   org_availability_info.infinite_time_fence(l_process_org_cntr) := l_get_mat_out_rec.infinite_time_fence_date;
   		   org_availability_info.atp_rule_name(l_process_org_cntr) := l_get_mat_out_rec.atp_rule_name;

                  org_availability_info.request_date_quantity(l_process_org_cntr) := l_requested_date_quantity;
                  /*IF l_process_org_cntr = 1 THEN
                     --- for top org we store the atp date on which requested quantity is available
                     item_availability_info.future_atp_date(l_item_cntr) := l_atp_date_this_level;
                     item_availability_info.atp_date_quantity(l_item_cntr) := l_atp_date_quantity_this_level;
                  END IF; */
               ELSE
                  org_availability_info.request_date_quantity(l_process_org_cntr) := 0;
                  l_requested_date_quantity := 0;
               END IF; -- IF l_atp_flag = 'Y'
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_requested_date_quantity := ' || l_requested_date_quantity);
               END IF;

               ---add material demand

               l_atp_insert_rec.instance_id := p_atp_record.instance_id;

               -- time_phased_atp changes begin
               IF l_time_phased_atp = 'Y' THEN
                   --Commented out as a part of bug3467631 as family_dest_id,atf_date,atf_date_quantity
                   -- are item org attribites
                   /*l_atp_insert_rec.inventory_item_id := item_availability_info.family_dest_id(l_item_cntr);
                   l_atp_insert_rec.request_item_id := item_availability_info.inventory_item_id(l_item_cntr);
                   l_atp_insert_rec.atf_date := item_availability_info.atf_date(l_item_cntr);
                   l_atp_insert_rec.atf_date_quantity := l_atf_date_qty;*/
                   --bug3467631 start
                   l_atp_insert_rec.inventory_item_id := org_availability_info.family_dest_id(l_process_org_cntr);
                   l_atp_insert_rec.request_item_id := item_availability_info.inventory_item_id(l_item_cntr);
                   l_atp_insert_rec.atf_date := org_availability_info.atf_date(l_process_org_cntr);
                   l_atp_insert_rec.atf_date_quantity := org_availability_info.atf_date_quantity(l_process_org_cntr);
                   l_atp_insert_rec.requested_date_quantity := org_availability_info.request_date_quantity(l_process_org_cntr);
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.inventory_item_id := ' || l_atp_insert_rec.inventory_item_id);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.request_item_id := ' || l_atp_insert_rec.request_item_id);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.atf_date := ' || l_atp_insert_rec.atf_date);
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.atf_date_quantity := ' || l_atp_insert_rec.atf_date_quantity);
                   END IF;
                   --bug3467631 end
               ELSE
                   l_atp_insert_rec.request_item_id := item_availability_info.inventory_item_id(l_item_cntr);
                   l_atp_insert_rec.inventory_item_id := item_availability_info.inventory_item_id(l_item_cntr);
               END IF;
               -- time_phased_atp changes end

               l_atp_insert_rec.organization_id := org_availability_info.organization_id(l_process_org_cntr);
               l_atp_insert_rec.identifier := p_atp_record.identifier;
               l_atp_insert_rec.demand_source_type:=nvl(p_atp_record.demand_source_type, 2);
               l_atp_insert_rec.demand_source_header_id :=
                               nvl(p_atp_record.demand_source_header_id, -1);
               l_atp_insert_rec.demand_source_delivery :=
                               p_atp_record.demand_source_delivery;

               l_atp_insert_rec.requested_ship_date :=
                          org_availability_info.requested_ship_date(l_process_org_cntr);
               l_atp_insert_rec.demand_class := l_demand_class;
               l_atp_insert_rec.order_number := p_atp_record.order_number;

               -- for performance reason, we call these function here and
               -- then populate the pegging tree with the values


               l_org_code := MSC_ATP_FUNC.get_org_code(p_atp_record.instance_id,
                                          p_atp_record.organization_id);


               IF l_process_org_cntr = 1 THEN
                  --- top level demand
                  -- Modified by ngoel on 1/12/2001 for origination_type = 30
                  --l_atp_insert_rec.origination_type := 6;
                  l_atp_insert_rec.origination_type := 30;

                  l_atp_insert_rec.demand_source_line := p_atp_record.demand_source_line;

                  IF MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y' and l_atp_flag in ('Y', 'C')  and l_net_demand > 0 THEN
                     --- if we are doing allocated atp then we would need to do stealing
                     --- In case of stealing we would need to put only demand for available quantity
                     --- If we put ordered quantity then we would need to readjust this demand again
                     ----Instea we just put how the available qty so that we do not need to re-adjust the demand

                     --- bug 2346439: Place demand on least of req_date_qty and net demand
                     -- dsting 2754446
                     l_atp_insert_rec.quantity_ordered := least(greatest(0, l_requested_date_quantity),
                                                                                          l_net_demand);

                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Alloc ATP, top org,We put demand for := ' ||
                                                          l_atp_insert_rec.quantity_ordered);
                     END IF;
                  ELSE

                     l_atp_insert_rec.quantity_ordered := p_atp_record.quantity_ordered;
                  END IF;

                  l_atp_insert_rec.refresh_number := p_atp_record.refresh_number;
               ELSE
                  -- dependent demand
                  -- this is not the top level demand, which we should consider it
                  -- as planned order demand
                  IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) <> 5) THEN  --4686870
                      l_atp_insert_rec.origination_type := 1;
                  ELSE
                      l_atp_insert_rec.origination_type := -200;
                  END IF; --4686870

                  l_atp_insert_rec.demand_source_line := null;

                  -- dsting diag_atp
                  IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('place full dmd: ' || l_net_demand);
                     END IF;
                     -- dsting 2754446
--                     l_atp_insert_rec.quantity_ordered := l_net_demand;
                     l_atp_insert_rec.quantity_ordered := org_availability_info.demand_quantity(l_process_org_cntr);
                  ELSE
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('place partial dmd: ' || l_atp_insert_rec.quantity_ordered);
                     END IF;
                     -- dsting 2754446 rounding error?
                     l_atp_insert_rec.quantity_ordered :=
                           least(greatest(0, l_requested_date_quantity),
                                 l_PO_qty * org_availability_info.conversion_rate(l_process_org_cntr));
--                                 org_availability_info.demand_quantity(l_process_org_cntr));
--                     l_atp_insert_rec.quantity_ordered := least(greatest(0, l_requested_date_quantity), l_net_demand);
                  END IF;
                  l_atp_insert_rec.refresh_number := p_atp_record.refresh_number;   -- For summary enhancement

               END IF;

               -- time_phased_atp changes begin
               --l_atp_insert_rec.request_item_id := MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID;
               l_atp_insert_rec.original_item_id := l_inventory_item_id ; --bug 5564075
               l_atp_insert_rec.latest_acceptable_date :=p_atp_record.latest_acceptable_date;
               -- ship_rec_cal
               l_atp_insert_rec.ship_method := p_atp_record.ship_method;
               l_atp_insert_rec.ship_set_name := p_atp_record.ship_set_name; --bug3263368
   	           l_atp_insert_rec.arrival_set_name := p_atp_record.arrival_set_name; --bug3263368
               l_atp_insert_rec.Delivery_Lead_Time := p_atp_record.Delivery_Lead_Time; --bug3263368

              --bug 4568088: Pass original_request date
              l_atp_insert_rec.original_request_ship_date := nvl(p_atp_record.original_request_date,
                                                                     l_atp_insert_rec.requested_ship_date);
              --MSC_ATP_SUBST.Add_Mat_Demand(l_atp_insert_rec,
               MSC_ATP_DB_UTILS.Add_Mat_Demand(l_atp_insert_rec,
                                               l_plan_id,
                                               l_demand_class_flag,
                                               l_demand_id);
               -- time_phased_atp changes end

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_demand_id := ' || l_demand_id);
               END IF;
               -- store demand id in org_avail_info table as we would need to update the demand
               -- in lower orgs if we dont have enough quantity in the org
               org_availability_info.demand_id(l_process_org_cntr) := l_demand_id;

               --- we also store demand id  for top org in item_availability_info as well as
               --- we would need to adjust the demand before future ATP/CTP case
               IF l_process_org_cntr =1 THEN
                  item_availability_info.demand_id(l_item_cntr) := l_demand_id;
               END IF;


               ---- get pegging id for demand
               SELECT msc_full_pegging_s.nextval
               INTO   l_pegging_id
               FROM   dual;

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand pegging id := ' || l_pegging_id);
               END IF;
               org_availability_info.demand_pegging_id(l_process_org_cntr) :=  l_pegging_id;

               --- supply pegging id
               SELECT msc_full_pegging_s.nextval
               INTO   l_pegging_id
               FROM   dual;

               org_availability_info.supply_pegging_id(l_process_org_cntr) :=  l_pegging_id;

               FOR i in 1..l_atp_period.Level.COUNT LOOP
                  l_atp_period.Pegging_Id(i) := l_pegging_id;
                  l_atp_period.End_Pegging_Id(i) := org_availability_info.demand_pegging_id(1);
               END LOOP;

	       IF p_atp_record.insert_flag <> 0 THEN
	               MSC_ATP_DB_UTILS.move_SD_temp_into_mrp_details(l_pegging_id,
					org_availability_info.demand_pegging_id(1));
	       END IF;

               --- now add period and supply details
               MSC_ATP_PROC.Details_Output(l_atp_period,
                                           l_atp_supply_demand,
                                           l_all_atp_period,
                                           l_all_atp_supply_demand,
			                   l_return_status);
               ---Now do stealing

	       IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'net demand ' || l_net_demand || ' requested qty ' || l_requested_date_quantity);
	       END IF;

               -- 2754446
               -- l_net_demand := GREATEST(l_net_demand - greatest(0, l_requested_date_quantity), 0);

               l_net_demand := greatest(0,
                  l_orig_net_dmd - nvl(org_availability_info.rnding_leftover(1), 0));

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('orig_net_dmd: ' || l_orig_net_dmd);
                  msc_sch_wb.atp_debug('rnding_leftover(1): ' || org_availability_info.rnding_leftover(1));
                  msc_sch_wb.atp_debug('req_date_qty: ' || greatest(nvl(org_availability_info.request_date_quantity(1), 0),0));
                  msc_sch_wb.atp_debug('steal_qty: ' || org_availability_info.steal_qty(1));
                  msc_sch_wb.atp_debug('net_dmd: ' || l_net_demand);
               END IF;

               IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND (l_atp_flag in ('Y', 'C')) and l_net_demand > 0 THEN

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'we are in the setup for stealing');
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand := ' || l_net_demand);
                   END IF;
                   g_atp_record.error_code := MSC_ATP_PVT.ALLSUCCESS;

                   -- time_phased_atp
                   g_atp_record.inventory_item_id := org_availability_info.family_sr_id(l_process_org_cntr);

                   g_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_cntr);
                   g_atp_record.organization_id := org_availability_info.organization_id(l_process_org_cntr);
                   g_atp_record.instance_id := p_atp_record.instance_id;
                   -- dsting 2754446
--                   g_atp_record.quantity_ordered := l_net_demand;
                   g_atp_record.quantity_ordered := org_req_dmd_qty(l_net_demand,
                        org_availability_info, l_process_org_cntr);
                   g_atp_record.quantity_UOM := p_atp_record.quantity_UOM;
                   g_atp_record.requested_ship_date := org_availability_info.requested_ship_date(l_process_org_cntr);
                   g_atp_record.requested_arrival_date := null;
                   g_atp_record.latest_acceptable_date :=
                             p_atp_record.latest_acceptable_date;
                   g_atp_record.delivery_lead_time :=
                             p_atp_record.delivery_lead_time;
                   g_atp_record.freight_carrier := p_atp_record.freight_carrier;
                   g_atp_record.ship_method := p_atp_record.ship_method;
                   g_atp_record.demand_class := l_demand_class;
                   g_atp_record.override_flag := p_atp_record.override_flag;
                   g_atp_record.action := p_atp_record.action;
                   g_atp_record.ship_date := p_atp_record.ship_date;
                   g_atp_record.available_quantity :=
                             p_atp_record.available_quantity;
                   g_atp_record.requested_date_quantity :=
                             p_atp_record.requested_date_quantity;
                   g_atp_record.supplier_id := p_atp_record.supplier_id;
                   g_atp_record.supplier_site_id := p_atp_record.supplier_site_id;
                   g_atp_record.insert_flag := p_atp_record.insert_flag;
                   g_atp_record.order_number := p_atp_record.order_number;
                   g_atp_record.demand_source_line :=
                             p_atp_record.demand_source_line;
                   g_atp_record.demand_source_header_id :=
                             p_atp_record.demand_source_header_id;
                   g_atp_record.demand_source_type :=
                             p_atp_record.demand_source_type;
                   g_atp_record.shipping_cal_code := org_availability_info.shipping_cal_code(l_process_org_cntr); -- Bug 3371817
                   g_atp_record.receiving_cal_code := org_availability_info.receiving_cal_code(l_process_org_cntr); -- Bug 3826234
                   g_atp_record.intransit_cal_code := org_availability_info.intransit_cal_code(l_process_org_cntr); -- Bug 3826234
                   g_atp_record.manufacturing_cal_code := org_availability_info.manufacturing_cal_code(l_process_org_cntr); -- Bug 3826234
                   g_atp_record.to_organization_id := p_atp_record.to_organization_id;    -- Bug 3826234
                   -- for bug 1410327
                   g_atp_record.identifier :=
                             p_atp_record.identifier;

                   -- 2754446
                   l_stealing_requested_date_qty := g_atp_record.quantity_ordered;
                   -- l_stealing_requested_date_qty := l_net_demand;
                   MSC_ATP_PVT.G_DEMAND_PEGGING_ID := org_availability_info.demand_pegging_id(1);

                   -- time_phased_atp
                   g_atp_record.atf_date := org_availability_info.atf_date(l_process_org_cntr);
                   l_post_stealing_dmd := g_atp_record.quantity_ordered; --bug3467631 change done
                   -- so that l_post_stealing_dmd is not passed null which completes the fix of 2754446

                   IF PG_DEBUG in ('Y', 'C') THEN --bug3467631
                      msc_sch_wb.atp_debug('l_post_stealing_dmd: ' || g_atp_record.quantity_ordered);
                   END IF;

                   MSC_AATP_PVT.Stealing(
                            g_atp_record,
                            org_availability_info.demand_pegging_id(l_process_org_cntr),
                            p_scenario_id,
                            p_level,
                            1, -- p_search
                            l_plan_id,
                            l_post_stealing_dmd, -- dsting 2754446
                            l_mem_stealing_qty, -- For time_phased_atp
                            l_pf_stealing_qty,  -- For time_phased_atp
                            l_atp_supply_demand,
                            l_atp_period,
                            l_return_status,
                            p_refresh_number);  -- for summary enhancement

                   -- 1680212
                   -- dsting 2754446
                   l_stealing_qty := (l_stealing_requested_date_qty
                                      - greatest(l_post_stealing_dmd, 0));
                   org_availability_info.rnding_leftover(l_process_org_cntr) :=
                       nvl(org_availability_info.rnding_leftover(l_process_org_cntr),0)
                       + l_stealing_qty;
                   --bug3467631
                   org_availability_info.atf_date_quantity(l_process_org_cntr) :=
                        org_availability_info.atf_date_quantity(l_process_org_cntr)
		        + nvl(l_mem_stealing_qty, 0);
                   top_org_supply_qty(org_availability_info, l_process_org_cntr);
                   l_net_demand := greatest(0,
                      l_orig_net_dmd - nvl(org_availability_info.rnding_leftover(1),0));

--                   l_stealing_qty := l_stealing_requested_date_qty -
--                                     greatest(l_net_demand, 0);
--                   l_net_demand := l_net_demand - l_stealing_qty;

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('l_stealing_qty: ' || l_stealing_qty);
                      msc_sch_wb.atp_debug('l_net_demand: ' || l_net_demand);
                      msc_sch_wb.atp_debug('l_post_stealing_dmd: ' || l_post_stealing_dmd);
                      msc_sch_wb.atp_debug('Qty till now got: ' || org_availability_info.rnding_leftover(l_process_org_cntr)); --bug3467631
                   END IF;

                   org_availability_info.steal_qty(l_process_org_cntr) := l_stealing_qty;

		   -- dsting: Stealing proc aready puts sd details into mrp_atp_details
                   --- now add supply demand details to table
                   --- now add period and supply details
                   MSC_ATP_PROC.Details_Output(l_atp_period,
                                              l_atp_supply_demand,
                                              l_all_atp_period,
                                              l_all_atp_supply_demand,
                                              l_return_status);

                   l_stealing_requested_date_qty := l_stealing_requested_date_qty -
                                                    l_post_stealing_dmd;
--                                                l_net_demand;

                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'After Stealing :'||
                                             to_char(l_net_demand));
                   END IF;

		  -- dsting diag_atp
		  IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP <> DIAGNOSTIC_ATP THEN
                   --- now we update the demand
                   IF l_process_org_cntr =1 THEN
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Top Org, update demand');
                      END IF;
                      --- for top org we always create order for the quantity ordered
                      MSC_ATP_SUBST.UPDATE_DEMAND(org_availability_info.demand_id(l_process_org_cntr),
                                              org_availability_info.plan_id(l_process_org_cntr),
                                              p_atp_record.quantity_ordered);
                      /* time_phased_atp
                         put qty stolen upto req date ((not upto ATF) on member item */
                      IF l_time_phased_atp = 'Y' THEN
		        --using the same insert rec we prepared earlier
		        l_atp_insert_rec.quantity_ordered :=  p_atp_record.quantity_ordered;
		        l_atp_insert_rec.requested_date_quantity := org_availability_info.request_date_quantity(l_process_org_cntr)
		                                                        + nvl(l_stealing_qty, 0);
		        l_atp_insert_rec.atf_date_quantity := org_availability_info.atf_date_quantity(l_process_org_cntr);
		        MSC_ATP_PF.Increment_Bucketed_Demands_Qty(
                                l_atp_insert_rec,
                                org_availability_info.plan_id(l_process_org_cntr),
                                org_availability_info.demand_id(l_process_org_cntr),
                                l_return_status
		        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Increment_Bucketed_Demands_Qty');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        /* Reset l_atf_date_qty to 0*/ --bug3467631
                        l_atf_date_qty := 0;
                      END IF;
                      -- time_phased_atp changes end
                   ELSIF l_stealing_qty > 0 THEN
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'second or later org, update demand as there is some stolen qty');
                      END IF;
                      --- org in second or later tear. Create demand for quantity available (req date qty+steal qty)
                      MSC_ATP_SUBST.UPDATE_DEMAND(org_availability_info.demand_id(l_process_org_cntr),
                                              org_availability_info.plan_id(l_process_org_cntr),
                                              (org_availability_info.request_date_quantity(l_process_org_cntr)
                                               + l_stealing_qty
                                              ));
                      /* time_phased_atp
                         put qty stolen upto req date ((not upto ATF) on member item */
                      IF l_time_phased_atp = 'Y' THEN
		        --using the same insert rec we prepared earlier
		        l_atp_insert_rec.quantity_ordered :=  org_availability_info.request_date_quantity(l_process_org_cntr);
		        l_atp_insert_rec.requested_date_quantity := org_availability_info.request_date_quantity(l_process_org_cntr)
		                                                        + nvl(l_stealing_qty, 0);
		        --bug3467631
		        l_atp_insert_rec.atf_date_quantity := org_availability_info.atf_date_quantity(l_process_org_cntr);
		        MSC_ATP_PF.Increment_Bucketed_Demands_Qty(
                                l_atp_insert_rec,
                                org_availability_info.plan_id(l_process_org_cntr),
                                org_availability_info.demand_id(l_process_org_cntr),
                                l_return_status
		        );
                        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Increment_Bucketed_Demands_Qty');
                           END IF;
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;
                        /* Reset l_atf_date_qty to 0*/ --bug3467631
                        l_atf_date_qty := 0;
                      END IF;
                      -- time_phased_atp changes end
                   END IF;
		  END IF;
               END IF; -- end if G_ALLOCATED_ATP
            END IF; -- IF l_atp_flag = 'N' and l_atp_comp_flag = 'N' THEN

            --l_net_demand := GREATEST(l_net_demand - greatest(0, l_requested_date_quantity), 0);
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_process_org_cntr := ' || l_process_org_cntr);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_org counter 1 := ' || l_parent_org_cntr);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'org count := ' || org_availability_info.organization_id.count);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_requested_ship_date := ' || l_requested_ship_date);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sys_date_top_org := ' || l_sys_date_top_org);
            END IF;
            IF l_net_demand > 0 and l_process_org_cntr >= org_availability_info.organization_id.count
               and l_requested_ship_date >= l_sys_date_top_org THEN

               --- we still have net demand and we have run out of organizations on current level. So we
               --  will move to next set of organizations
               l_sources_found := 0;
               -- dsting
               -- l_sources found = 1 iff there is a good transfer source found that doesn't violate constraints
               -- l_transfer_found = 1 if there is any transfer source
	       l_transfer_found := 0;
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_org_cntr := ' || l_parent_org_cntr);
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_process_org_cntr := ' || l_process_org_cntr);
               END IF;
               WHILE l_sources_found = 0 AND l_parent_org_cntr <= org_availability_info.organization_id.count LOOP
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Look for sources for org :' || ORG_AVAILABILITY_INFO.organization_id(l_parent_org_cntr));
                  END IF;
                  IF org_availability_info.atp_comp_flag(l_parent_org_cntr) in ('Y', 'C') THEN
                     --s_cto_rearch
                     l_item_sourcing_info_rec := l_null_item_sourcing_info_rec;
                     l_item_sourcing_info_rec.sr_inventory_item_id.extend;
                     l_item_sourcing_info_rec.line_id.extend;
                     l_item_sourcing_info_rec.ato_line_id.extend;
                     l_item_sourcing_info_rec.match_item_id.extend;
                     --e_cto_rearch
                     l_item_sourcing_info_rec.sr_inventory_item_id(1) :=
                                            ITEM_AVAILABILITY_INFO.sr_inventory_item_id(l_item_cntr);
                     MSC_ATP_PROC.Atp_Sources(p_atp_record.instance_id,
                           org_availability_info.plan_id(l_parent_org_cntr),
                           ITEM_AVAILABILITY_INFO.sr_inventory_item_id(l_item_cntr),
                           ORG_AVAILABILITY_INFO.organization_id(l_parent_org_cntr),
                           NULL,
                           NULL,
                           org_availability_info.assign_set_id(l_parent_org_cntr),
                           l_item_sourcing_info_rec,
                           --MRP_ATP_PUB.number_arr(NULL),
                           MSC_ATP_PVT.G_SESSION_ID,
                           l_sources,
                           l_return_status);
	             IF l_sources.source_type.count = 0 THEN
			org_availability_info.constraint_type(l_parent_org_cntr) := NOSOURCES_NONCONSTRAINT;
		     END IF;
                  ELSE
                     l_sources := l_null_sources;
		     IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
			IF PG_DEBUG in ('Y', 'C') THEN
			   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'constraint type: MATERIAL_CONSTRAINT');
			   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'make_buy_code: ' || l_make_buy_cd);
			END IF;
			org_availability_info.constraint_type(l_parent_org_cntr) := MATERIAL_CONSTRAINT;
		     END IF;
                  END IF;
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  OR
                     l_sources.source_type.count = 0
		  THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'No sources Found for this org');
                     END IF;

                  ELSE
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Sources Found, process them');
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || ' source count := ' || l_sources.organization_id.count);
                     END IF;

                     FOR i in 1..l_sources.organization_id.count LOOP

                        IF l_sources.source_type(i) = MSC_ATP_PVT.TRANSFER THEN

                           -- we only consider 'Transfer' type sources in this pass

                           l_to_location_id := null;
                           l_delivery_lead_time := l_sources.lead_time(i);
                           l_ship_method := l_sources.ship_method(i);

                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_delivery_lead_time := ' || l_delivery_lead_time);
                           END IF;

                           --bug3467631 making necessary changes for ship_rec_cal
                           /* ship_rec_cal changes begin */
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('**************** Calendar Codes ******************************');
                              msc_sch_wb.atp_debug('*  ___________________Input_____________________');
                              msc_sch_wb.atp_debug('*  ');
                              msc_sch_wb.atp_debug('*  Source Type             : '|| l_sources.source_type(i) );
                              msc_sch_wb.atp_debug('*  Instance ID             : '|| p_atp_record.instance_id );
                              msc_sch_wb.atp_debug('*  Source Instance ID      : '|| l_sources.instance_id(i) );
                              msc_sch_wb.atp_debug('*  Source Org ID           : '|| l_sources.organization_id(i) );
                              msc_sch_wb.atp_debug('*  Receiving Org ID        : '|| org_availability_info.organization_id(l_parent_org_cntr) );
                              msc_sch_wb.atp_debug('*  Ship Method             : '|| l_sources.Ship_Method(i) );
                           END IF;

                           IF l_sources.source_type(i) = MSC_ATP_PVT.TRANSFER THEN
                               -- receiving party is org
                               l_receiving_cal_code := MSC_CALENDAR.Get_Calendar_Code(
                                                                    p_atp_record.instance_id,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    org_availability_info.organization_id(l_parent_org_cntr),
                                                                    l_sources.Ship_Method(i),
                                                                    MSC_CALENDAR.ORC);

                               l_intransit_cal_code := MSC_CALENDAR.Get_Calendar_Code(
                                                                    l_sources.instance_id(i),
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    4,
                                                                    null,
                                                                    l_sources.Ship_Method(i),
                                                                    MSC_CALENDAR.VIC);

                               l_shipping_cal_code := MSC_CALENDAR.Get_Calendar_Code(
                                                                    l_sources.instance_id(i),
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    l_sources.organization_id(i),
                                                                    l_sources.Ship_Method(i),
                                                                    MSC_CALENDAR.OSC);
                               l_manufacturing_cal_code := MSC_CALENDAR.Get_Calendar_Code(
                                                                    l_sources.instance_id(i),
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    l_sources.organization_id(i),
                                                                    null,
                                                                    MSC_CALENDAR.OMC);
                               l_dest_mfg_cal_code := MSC_CALENDAR.Get_Calendar_Code(
                                                                    l_sources.instance_id(i),
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    null,
                                                                    org_availability_info.organization_id(l_parent_org_cntr),
                                                                    null,
                                                                    MSC_CALENDAR.OMC);
                           END IF;
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('  ');
                              msc_sch_wb.atp_debug('*  ___________________Output____________________');
                              msc_sch_wb.atp_debug('*  ');
                              msc_sch_wb.atp_debug('*  Receiving calendar code         : ' || l_receiving_cal_code);
                              msc_sch_wb.atp_debug('*  Intransit calendar code         : ' || l_intransit_cal_code);
                              msc_sch_wb.atp_debug('*  Shipping calendar code          : ' || l_shipping_cal_code);
                              msc_sch_wb.atp_debug('*  Manufacturing calendar code     : ' || l_manufacturing_cal_code);
                              msc_sch_wb.atp_debug('**************************************************************');
                           END IF;

                           /* planned order due date as per OMC-D */
                           l_planned_order_date := MSC_CALENDAR.PREV_WORK_DAY(
                                                       l_dest_mfg_cal_code,
                                                       p_atp_record.instance_id,
                                                       l_requested_ship_date);
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('*  Planned Order Due Date as per OMC-D: ' || l_planned_order_date);
                              msc_sch_wb.atp_debug('*  post_pro_lt: ' || org_availability_info.post_pro_lt(l_parent_org_cntr));
                           END IF;
                           -- ship_rec_cal changes end

                           --- first we do a PTF check. Get start Date for PTF check
                           --- request date in source org = dock date in dest org - intransit lead time
			   -- dsting delivery lead time to not be dependent on calendar (see 2463556)
                           l_start_date := org_availability_info.Requested_ship_date(l_parent_org_cntr);

                           /* ship_rec_cal changes begin */
                           IF org_availability_info.post_pro_lt(l_parent_org_cntr) > 0 THEN
                              /* ship_rec_cal
                              l_start_date := MSC_CALENDAR.DATE_OFFSET(
                                                         org_availability_info.organization_id(l_parent_org_cntr),
                                                         p_atp_record.instance_id,
                                                         1,
                                                         l_start_date,
                                                         -1 * org_availability_info.post_pro_lt(l_parent_org_cntr));*/
                              l_start_date := MSC_CALENDAR.DATE_OFFSET(
                                                         l_dest_mfg_cal_code,
                                                         p_atp_record.instance_id,
                                                         l_start_date,
                                                         -1 * org_availability_info.post_pro_lt(l_parent_org_cntr), -1);

			   END IF;

                           l_start_date := MSC_CALENDAR.PREV_WORK_DAY(
                                                l_receiving_cal_code,
                                                p_atp_record.instance_id,
                                                l_start_date);

                           /* populating new_dock_date even for transfer orders also, this is to support requirement of supporting
                              org modeled as supplier which might come in future*/
                           l_new_dock_date := l_start_date;

                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_start_date : '||l_start_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Date after validating on ORC : '||l_new_dock_date);
                           END IF;

                           -- l_start_date := MSC_CALENDAR.DATE_OFFSET ( -- Bug 3241766: l_start_date should have dock date
                           l_atp_rec.requested_ship_date := MSC_CALENDAR.DATE_OFFSET (
                                                l_intransit_cal_code,
                                                p_atp_record.instance_id,
                                                l_start_date,
                                                -1 * NVL(l_sources.lead_time(i), 0), -1);

                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Date after subtracting DLT using VIC : '||l_atp_rec.requested_ship_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sources.lead_time(i) : '||l_sources.lead_time(i));
                           END IF;

                           l_atp_rec.requested_ship_date := MSC_CALENDAR.PREV_WORK_DAY(
                                                l_shipping_cal_code,
                                                p_atp_record.instance_id,
                                                l_atp_rec.requested_ship_date);
                           /* populating new_ship_date for transfer orders also, this is to support requirement of supporting
                              org modeled as supplier which might come in future*/
                           l_new_ship_date := l_atp_rec.requested_ship_date;
                           l_req_ship_date := l_atp_rec.requested_ship_date;
                           l_start_date := l_new_ship_date; -- Bug 3578083 -- Setting the variable that is compared with PTF date
                                                            -- This should be source org's ship date.

                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Date after validating on OSC : '||l_atp_rec.requested_ship_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'pre_pro_lt : '||org_availability_info.pre_pro_lt(l_parent_org_cntr));
                           END IF;

                           -- Add pre-PLT offset also: Bug 3241766
                           l_order_date := MSC_CALENDAR.DATE_OFFSET (
                                                         l_dest_mfg_cal_code,
                                                         p_atp_record.instance_id,
                                                         l_new_ship_date,
                                                         -1 * org_availability_info.pre_pro_lt(l_parent_org_cntr), -1);

                           --- get PTF date
                           IF l_parent_org_cntr = 1 THEN
                              l_sysdate := l_sys_date_top_org;
                           ELSE
                              /* ship_rec_cal
                              l_sysdate := MSC_CALENDAR.NEXT_WORK_DAY(
                                                    org_availability_info.organization_id(l_parent_org_cntr),
                                                    p_atp_record.instance_id,
                                                    1,
                                                    sysdate);*/
                              l_sysdate := MSC_CALENDAR.NEXT_WORK_DAY(
                                                    l_dest_mfg_cal_code,
                                                    p_atp_record.instance_id,
                                                    l_trunc_sysdate); --bug3578083 Removed unnecessary reference to sysdate
                           END IF;
                           l_ptf_date := l_sysdate;
                           -- bug3578083 - PTF constraint should be added only if plan is PTF enabled
                           l_ptf_enabled := 2;
                           BEGIN
                              Select DECODE(pl.planning_time_fence_flag,
                                1, trunc(NVL(itm.planning_time_fence_date, l_sysdate)),
                                l_sysdate),pl.planning_time_fence_flag -- Bug 3578083
                              into   l_ptf_date,l_ptf_enabled  -- Bug 3578083
                              from   msc_system_items itm,
                                     msc_plans pl
                              where  itm.plan_id = org_availability_info.plan_id(l_parent_org_cntr)
                              and    itm.sr_instance_id = p_atp_record.instance_id
                              and    itm.organization_id = org_availability_info.organization_id(l_parent_org_cntr)
                              and    itm.sr_inventory_item_id = item_availability_info.sr_inventory_item_id(l_item_cntr)
                              and    pl.plan_id = itm.plan_id
                              and    pl.sr_instance_id = itm.sr_instance_id;

                           EXCEPTION
                              WHEN OTHERS THEN
                                  IF PG_DEBUG in ('Y', 'C') THEN
                                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured while getting PTF : ' || sqlerrm);
                                  END IF;
                                  --l_ptf_date := l_sysdate; -- Bug 3578083
                           END;
                           IF PG_DEBUG in ('Y', 'C') THEN
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_ptf_date := ' || l_ptf_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_order_date := ' || l_order_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_start_date := ' || l_start_date);
                              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_ptf_enabled := ' || l_ptf_enabled);
                           END IF;

                           -- calculate the ship date if we pass the ptf check
			   -- or we're doing diagnostic atp
			   /*   ship_rec_cal: not required as ship date is already calulated
                           IF l_start_date >= l_ptf_date THEN
                              IF PG_DEBUG in ('Y', 'C') THEN
                                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Passed the PTF test');
                              END IF;
			      /* ship_rec_cal
			      l_req_ship_date := MSC_CALENDAR.prev_work_day(l_sources.organization_id(i),
									p_atp_record.instance_id,
									MSC_CALENDAR.TYPE_DAILY_BUCKET,
									l_start_date);
			      l_req_ship_date := MSC_CALENDAR.prev_work_day(
		                                                l_manufacturing_cal_code,
								p_atp_record.instance_id,
									l_start_date);

                              IF PG_DEBUG in ('Y', 'C') THEN
                                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_req_ship_date := ' || l_req_ship_date);
                              END IF;
                           END IF;
                           */

			   -- add the org to the org_availability queue if it doesn't violate
			   -- ptf date or lead time constraints
			   -- Bug 3241766: order start date should be checked with sysdate
                           --bug3578083  removed unnecessary reference to sysdate
                           IF l_order_date >= l_trunc_sysdate AND l_start_date >= l_ptf_date THEN
                                 --- since we have found the sources we set the flag to yes
                                 l_sources_found := 1;
                                 l_transfer_found := 1;
                                 ---extend the org_avail-indo
                                 MSC_ATP_SUBST.Extend_Org_Avail_Info_Rec(org_availability_info, l_return_status);
                                 l_count := org_availability_info.organization_id.count;
                                 org_availability_info.organization_id(l_count) := l_sources.organization_id(i);
                                 org_availability_info.requested_ship_date(l_count) := l_req_ship_date;
                                 org_availability_info.parent_org_idx(l_count) := l_parent_org_cntr;
                                 org_availability_info.location_id(l_count) := l_from_location_id;
                                 org_availability_info.lead_time(l_count) := l_delivery_lead_time;
			   	 org_availability_info.ship_method(l_count) := l_sources.ship_method(i);
--			   	 org_availability_info.ship_method(l_count) := l_ship_method;

			         org_availability_info.new_dock_date(l_count)   := l_new_dock_date;     -- Bug 3241766
			         org_availability_info.new_ship_date(l_count)   := l_new_ship_date;     -- Bug 3241766
			         org_availability_info.new_start_date(l_count)  := l_new_ship_date;     -- Bug 3241766
			         org_availability_info.new_order_date(l_count)  := l_order_date;        -- Bug 3241766

			         -- Bug 3371817 - assigning calendars
			         org_availability_info.shipping_cal_code(l_count)   := l_shipping_cal_code;
			         org_availability_info.receiving_cal_code(l_count)  := l_receiving_cal_code;
			         org_availability_info.intransit_cal_code(l_count)  := l_intransit_cal_code;
                                 org_availability_info.manufacturing_cal_code(l_count)  := l_manufacturing_cal_code;
			         -- dsting diagnostic atp
			         org_availability_info.ptf_date(l_count) := l_ptf_date;

                                 --- get pegging ID for planned order in parent Org
                                 SELECT msc_full_pegging_s.nextval
                                 INTO   l_pegging_id
                                 FROM   dual;
                                 IF PG_DEBUG in ('Y', 'C') THEN
                                    msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'PO Pegging id := ' || l_pegging_id);
                                    msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Src Organization_id := ' || l_sources.organization_id(i));
                                 END IF;
		                 org_availability_info.PO_pegging_id(l_count) := l_pegging_id;
			   ELSIF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
                                l_transfer_found := 1;

				Prep_Common_pegging_rec(
					l_pegging_rec,
					p_atp_record,
					org_availability_info,
					l_process_org_cntr,
					item_availability_info,
					l_item_cntr
				);

				/* ship_rec_cal changes begin
				l_lt_due_date := MSC_CALENDAR.next_work_day(l_sources.organization_id(i),
                                                                          p_atp_record.instance_id,
									  MSC_CALENDAR.TYPE_DAILY_BUCKET,
                                                                          sysdate) +
						 + NVL(l_sources.lead_time(i), 0);

				l_lt_due_date := MSC_CALENDAR.next_work_day(l_sources.organization_id(i),
                                                                          p_atp_record.instance_id,
									  MSC_CALENDAR.TYPE_DAILY_BUCKET,
									  l_lt_due_date);

				l_ptf_due_date := MSC_CALENDAR.next_work_day(l_sources.organization_id(i),
                                                                          p_atp_record.instance_id,
									  MSC_CALENDAR.TYPE_DAILY_BUCKET,
									  l_ptf_date + NVL(l_sources.lead_time(i), 0));
				IF NVL(org_availability_info.post_pro_lt(l_parent_org_cntr),0) > 0 THEN
					l_lt_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       org_availability_info.organization_id(l_parent_org_cntr),
                                                       p_atp_record.instance_id,
                                                       1,
                                                       l_lt_due_date,
                                                       org_availability_info.post_pro_lt(l_parent_org_cntr));

					l_ptf_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       org_availability_info.organization_id(l_parent_org_cntr),
                                                       p_atp_record.instance_id,
                                                       1,
                                                       l_ptf_due_date,
									  l_ptf_date + NVL(l_sources.lead_time(i), 0));*/

                                -- Add pre-PLT offset also: Bug 3241766
                                l_lt_due_date := MSC_CALENDAR.DATE_OFFSET (
                                                         l_dest_mfg_cal_code,
                                                         p_atp_record.instance_id,
                                                         sysdate,
                                                         org_availability_info.pre_pro_lt(l_parent_org_cntr), 1);

                                l_lt_due_date := MSC_CALENDAR.THREE_STEP_CAL_OFFSET_DATE(
                                		l_lt_due_date, l_shipping_cal_code, +1,
                                		l_intransit_cal_code, NVL(l_sources.lead_time(i), 0), +1,
                                		l_receiving_cal_code, +1, p_atp_record.instance_id);

                                -- Add pre-PLT offset also: Bug 3241766
                                /* Bug 3578083 - Earlier ptf_due_date was calculated as
                                   ptf_due_date := ptf_date + pre-processing lead time + delivery lead time + post-processing lead time
                                   it should actually be
                                   ptf_due_date := ptf_date + delivery lead time + post-processing lead time
                                l_ptf_due_date := MSC_CALENDAR.DATE_OFFSET (
                                                         l_dest_mfg_cal_code,
                                                         p_atp_record.instance_id,
                                                         l_ptf_date,
                                                         org_availability_info.pre_pro_lt(l_parent_org_cntr), 1);*/

                                l_ptf_due_date := MSC_CALENDAR.THREE_STEP_CAL_OFFSET_DATE(
                                		l_ptf_date, l_shipping_cal_code, +1,
                                		l_intransit_cal_code, NVL(l_sources.lead_time(i), 0), +1,
                                		l_receiving_cal_code, +1, p_atp_record.instance_id);

				IF NVL(org_availability_info.post_pro_lt(l_parent_org_cntr),0) > 0 THEN
					/* ship_rec_cal
					l_lt_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       org_availability_info.organization_id(l_parent_org_cntr),
                                                       p_atp_record.instance_id,
                                                       1,
                                                       l_lt_due_date,
                                                       org_availability_info.post_pro_lt(l_parent_org_cntr));

					l_ptf_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       org_availability_info.organization_id(l_parent_org_cntr),
                                                       p_atp_record.instance_id,
                                                       1,
                                                       l_ptf_due_date,
                                                       org_availability_info.post_pro_lt(l_parent_org_cntr));*/

					l_lt_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       l_dest_mfg_cal_code,
                                                       p_atp_record.instance_id,
                                                       l_lt_due_date,
                                                       org_availability_info.post_pro_lt(l_parent_org_cntr), 1);
					l_ptf_due_date :=  MSC_CALENDAR.DATE_OFFSET (
                                                       l_dest_mfg_cal_code,
                                                       p_atp_record.instance_id,
                                                       l_ptf_due_date,
                                                       org_availability_info.post_pro_lt(l_parent_org_cntr), 1);

                                -- ship_rec_cal changes end
				END IF;
			   	-- bug3578083 - Constraint message should be added only if constraint actually exists
			   	IF PG_DEBUG in ('Y', 'C') THEN
				   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_ptf_due_date ' || l_ptf_due_date);
				   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_lt_due_date ' || l_lt_due_date);
				END IF;
			   	IF l_lt_due_date > l_requested_ship_date OR
                                 l_ptf_due_date > l_requested_ship_date THEN
                                 -- bug3578083 - PTF constraint should be added only if plan is PTF enabled
			   	 IF l_ptf_enabled=2 OR l_lt_due_date > l_ptf_due_date THEN
					IF PG_DEBUG in ('Y', 'C') THEN
					   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'diagnostic atp: TRANSIT_LT_CONSTRAINT');
					END IF;
					l_pegging_rec.constraint_type := TRANSIT_LT_CONSTRAINT;
					l_pegging_rec.constraint_date := l_lt_due_date;
				 ELSE
					IF PG_DEBUG in ('Y', 'C') THEN
					   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'diagnostic atp: PTF_CONSTRAINT');
					END IF;
					l_pegging_rec.constraint_type := PTF_CONSTRAINT;
					l_pegging_rec.constraint_date := l_ptf_due_date;
				 END IF;
				END IF;

				IF PG_DEBUG in ('Y', 'C') THEN
				   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Constraint due date: ' || l_pegging_rec.constraint_date);
				END IF;

				l_pegging_rec.parent_pegging_id:=
					org_availability_info.demand_pegging_id(l_parent_org_cntr);
				l_pegging_rec.end_pegging_id := org_availability_info.demand_pegging_id(1);

				-- dsting diag_atp
				IF PG_DEBUG in ('Y', 'C') THEN
				   msc_sch_wb.atp_debug('lt or ptf constraint end_pegging_id: ' || org_availability_info.demand_pegging_id(1));
				END IF;

				MSC_ATP_PVT.G_demand_pegging_id := org_availability_info.demand_pegging_id(1);
				l_pegging_rec.organization_id :=
					org_availability_info.organization_id(l_parent_org_cntr);
				l_pegging_rec.organization_code := MSC_ATP_FUNC.get_org_code(
									p_atp_record.instance_id,
                                        				l_sources.organization_id(i));

				l_pegging_rec.Postprocessing_lead_time := org_availability_info.post_pro_lt(l_parent_org_cntr);
				l_pegging_rec.Intransit_lead_time := l_delivery_lead_time;
				IF( NVL(l_sources.ship_method(i), '@@@') <> '@@@' ) THEN
					l_pegging_rec.ship_method := l_sources.ship_method(i);
				END IF;
				l_pegging_rec.ptf_date := l_ptf_date;

				l_pegging_rec.plan_name := org_availability_info.plan_name(l_parent_org_cntr);
				l_pegging_rec.rounding_control := item_availability_info.rounding_control_type(l_item_cntr);
				l_pegging_rec.required_quantity := l_net_demand;
				l_pegging_rec.required_date := l_req_ship_date;

				l_pegging_rec.identifier2:= org_availability_info.plan_id(l_parent_org_cntr);
				l_pegging_rec.identifier3:= l_transaction_id;

				l_pegging_rec.supply_demand_quantity := 0;
				l_pegging_rec.supply_demand_type := 2; -- supply
				l_pegging_rec.supply_demand_date:= org_availability_info.requested_ship_date(l_parent_org_cntr);
				l_pegging_rec.source_type :=  MSC_ATP_PVT.TRANSFER;

				l_pegging_rec.atp_level := p_level+1;
				l_pegging_rec.scenario_id := p_scenario_id;
				l_pegging_rec.pegging_type := TRANSFER_PEG_TYP;
				l_pegging_rec.aggregate_time_fence_date:= org_availability_info.Atf_Date(l_parent_org_cntr); --bug3467631
                                -- Bug 3826234
                                l_pegging_rec.shipping_cal_code      :=  l_shipping_cal_code;
                                l_pegging_rec.receiving_cal_code     :=  l_receiving_cal_code;
                                l_pegging_rec.intransit_cal_code     :=  l_intransit_cal_code;
                                l_pegging_rec.manufacturing_cal_code :=  l_manufacturing_cal_code;

				MSC_ATP_DB_UTILS.Add_Pegging(l_pegging_rec, l_pegging_id);
                           ELSE
                              --- we fail the PTF date test
                              IF PG_DEBUG in ('Y', 'C') THEN
                                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Fail the PTF test, dont add org to list of org to be visited');
                              END IF;
                           END IF;

                        END IF; -- IF l_sources.source_type = 'TRANSFER' THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_org_cntr := ' || l_parent_org_cntr);
                        END IF;
                     END LOOP;
                  END IF;

		  IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('highest rev: ' || l_highest_rev_item_id);
                        msc_sch_wb.atp_debug('l_sources_found: ' || l_sources_found);
                        msc_sch_wb.atp_debug('l_transfer_found: ' || l_transfer_found);
			msc_sch_wb.atp_debug('G_CREATE_SUPPLY: ' || MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG);
			msc_sch_wb.atp_debug('item create_supply: ' || item_availability_info.create_supply_flag(l_item_count));
			msc_sch_wb.atp_debug('org: ' || org_availability_info.org_code(l_parent_org_cntr));
		  END IF;

		  -- if this is diagnostic atp, and there are no transfer sources, and we cannot create
		  -- a supply on the demanded item then flag it as a material constraint.
                  IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP AND l_transfer_found <> 1 AND
		     l_create_supply_on_orig_item = 0
                  THEN
			org_availability_info.constraint_type(l_parent_org_cntr) := MATERIAL_CONSTRAINT;
                  END IF;

                  l_parent_org_cntr := l_parent_org_cntr + 1;

               END LOOP; --- WHILE l_sources_found = 0 AND l_parent_org_cntr <= org_availability_info.organization_id.count LOOP
            ELSIF l_requested_ship_date  < l_sys_date_top_org THEN
               l_parent_org_cntr := l_parent_org_cntr + 1;

            END IF; --IF l_net_demand > 0 and l_process_org_cntr >= org_availability_info.org_count THEN

            l_process_org_cntr := l_process_org_cntr + 1;

            IF l_process_org_cntr <= org_availability_info.organization_id.count THEN
               l_parent_index := org_availability_info.parent_org_idx(l_process_org_cntr);
            END IF;

         END LOOP; --- WHILE l_parent_org_cntr <= org_availability_info.organization_id.count LOOP


         --- AT this point we should have complete picture as to what is the demand availability in each org
         --- So we create planned orders and peggings in each org
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Done with ATP check, now add pegging, planned orders');
	    msc_sch_wb.atp_debug('reset Subst last PO pegging: ');
         END IF;

	 MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING := null;
	 MSC_ATP_SUBST.G_TOP_LAST_PO_QTY := 0;

	 -- dsting diag_atp
	 -- I need to know the quantity from children in advance to balance supply/demand
/* 2754446 I'm doing this in advance already
	 IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
		FOR j in reverse 2..org_availability_info.organization_id.count  LOOP
		    l_parent_index := org_availability_info.parent_org_idx(j);
                    -- 2754446
                    l_addt_qty := LEAST((GREATEST(org_availability_info.request_date_quantity(j), 0) +
                                            NVL(org_availability_info.quantity_from_children(j), 0) +
                                            NVL(org_availability_info.steal_qty(j), 0)
                                       ), org_availability_info.demand_quantity(j))
                                  / org_availability_info.conversion_rate(j);

                    -- dsting 2754446
                    IF nvl(org_availability_info.rounding_flag(l_parent_index), 2) = 1 THEN
                          l_addt_qty := FLOOR(ROUND(l_addt_qty, 10));
                    END IF;

                    msc_sch_wb.atp_debug('l_addt_qty: ' || l_addt_qty);

                    org_availability_info.quantity_from_children(l_parent_index) :=
                                     NVL(org_availability_info.quantity_from_children(l_parent_index), 0) +
                                     l_addt_qty;

                    msc_sch_wb.atp_debug('qty from children('||l_parent_index||'): ' ||
                        org_availability_info.quantity_from_children(l_parent_index));
		END LOOP;
--	 END IF;
*/

         FOR j in reverse 1..org_availability_info.organization_id.count  LOOP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Process orgination := ' || org_availability_info.organization_id(j));
            END IF;
            -- dsting 2754446
            l_parent_index := nvl(org_availability_info.parent_org_idx(j), 1);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_index := ' || l_parent_index);
            END IF;

            IF (org_availability_info.atp_flag(j) = 'N' AND org_availability_info.atp_comp_flag(j) = 'N')  THEN

               --- NON-ATPABLE ITEM item is non atpable then we add planned order in parent org
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Item is Non Atpable');
               END IF;

               -- dsting 2754446 req_date_qty and qty_from_chld should already be rounded to correct values
               -- for creating a PO in the top org's uom. so convert the uom, and round to remove float precision errs

               IF nvl(org_availability_info.rounding_flag(l_parent_index), 2) = 1 THEN
                  l_available_quantity := FLOOR(ROUND(
                                            (greatest(org_availability_info.request_date_quantity(j), 0)
                                             + NVL(org_availability_info.quantity_from_children(j), 0)
                                             + NVL(org_availability_info.steal_qty(j), 0)
                                            ) / org_availability_info.conversion_rate(j), 10)
                                          );
               ELSE
                  l_available_quantity := (greatest(org_availability_info.request_date_quantity(j), 0)
                                           + NVL(org_availability_info.quantity_from_children(j), 0)
                                           + NVL(org_availability_info.steal_qty(j), 0))
                                          / org_availability_info.conversion_rate(j);
               END IF;

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('rounding_flag: ' || org_availability_info.rounding_flag(j));
                  msc_sch_wb.atp_debug('l_available_quantity: ' || l_available_quantity);
                  msc_sch_wb.atp_debug('l_avail_qty_top_uom: ' || l_avail_qty_top_uom);
               END IF;

               IF j = 1 THEN
                  --- bug 2344501: set the error only if it is a top org
                  p_atp_record.error_code := MSC_ATP_PVT.ATP_NOT_APPL;
               END IF;

	       l_transaction_id := NULL;
               IF j > 1 AND (l_available_quantity > 0 OR MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP) THEN

		  -- dsting diag_atp
		  -- may need to adjust the PO for diagnostic atp
--		  IF l_available_quantity >0 THEN

                    -- dsting 2754446
                    l_PO_qty := org_availability_info.demand_quantity(j)
                                / org_availability_info.conversion_rate(j);
                    IF org_availability_info.rounding_flag(l_parent_index) = 1 THEN
                       l_PO_qty := CEIL(ROUND(l_PO_qty,10));
                    END IF;

                    -- Begin ATP4drp Create Planned Arrivals for DRP plans
                    IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
                       l_supply_rec.instance_id        :=   p_atp_record.instance_id;
                       l_supply_rec.plan_id            :=   org_availability_info.plan_id(l_parent_index);
                       l_supply_rec.inventory_item_id  :=  org_availability_info.family_dest_id(l_parent_index);
                                                                        -- DRP Plan re-set to member For time_phased_atp
                       l_supply_rec.organization_id    :=   org_availability_info.organization_id(l_parent_index);
                       l_supply_rec.schedule_date      :=   org_availability_info.requested_ship_date(l_parent_index);
                       l_supply_rec.order_quantity     :=   least(l_PO_qty, l_available_quantity);
                          -- null; -- l_atp_rec.supplier_id,
                          -- null; -- l_atp_rec.supplier_site_id,
                       l_supply_rec.demand_class       :=   org_availability_info.demand_class(l_parent_index);
                          -- rajjain 02/19/2003 Bug 2788302 Begin
                          -- Add Sourcing details
                       l_supply_rec.source_organization_id :=   org_availability_info.organization_id(j);
                       l_supply_rec.source_sr_instance_id  :=   p_atp_record.instance_id;
                          -- null; --process seq id (transfer case)
                          -- rajjain 02/19/2003 Bug 2788302 End
                       l_supply_rec.refresh_number     :=   p_refresh_number; -- for summary enhancement
                          -- ship_rec_cal changes begin
                       l_supply_rec.shipping_cal_code  := org_availability_info.shipping_cal_code(j);   -- |
                       l_supply_rec.receiving_cal_code := org_availability_info.receiving_cal_code(j);  -- |
                       l_supply_rec.intransit_cal_code := org_availability_info.intransit_cal_code(j);  -- |
                       l_supply_rec.new_ship_date      := org_availability_info.new_ship_date(j);       -- |  Bug 3241766
                       l_supply_rec.new_dock_date      := org_availability_info.new_dock_date(j);       -- |
                                                                       -- |  Add new columns start date and order date
                       l_supply_rec.start_date         := org_availability_info.new_start_date(j);      -- |
                                                                       -- Use values from child org rather than parent
                       l_supply_rec.order_date         := org_availability_info.new_order_date(j);      -- |
                       l_supply_rec.ship_method        :=  org_availability_info.ship_method(j);         -- |
                          -- ship_rec_cal changes end
                          -- item_availability_info.inventory_item_id(l_item_cntr); -- For time_phased_atp
                          -- org_availability_info.atf_date(l_parent_index);        -- For time_phased_atp

                       l_supply_rec.firm_planned_type := 2;
                       l_supply_rec.disposition_status_type := 1;
                       l_supply_rec.record_source := 2; -- ATP created
                       l_supply_rec.supply_type := 51; --- planned arrival
                       l_supply_rec.intransit_lead_time := org_availability_info.lead_time(j); --4127630

                       MSC_ATP_DB_UTILS.ADD_Supplies(l_supply_rec);
                       -- Asssign the output to local variables.
                       l_transaction_id := l_supply_rec.transaction_id;
                       l_return_status  := l_supply_rec.return_status;
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                          msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'DRP Plan Add Planned Inbound');
                          msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Id l_transaction_id: ' || l_transaction_id);
                          msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Type l_supply_rec.supply_type: '
                                                                                 || l_supply_rec.supply_type);
                          msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Return Status l_return_status: ' || l_return_status);
                          msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                       END IF;

                    ELSE  -- Create Planned Order otherwise.
                       IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add planned order');
                       END IF;

                       MSC_ATP_DB_UTILS.Add_Planned_Order (
                          p_atp_record.instance_id,
                          org_availability_info.plan_id(l_parent_index),
                          org_availability_info.family_dest_id(l_parent_index),  -- For time_phased_atp
                          org_availability_info.organization_id(l_parent_index),
                          org_availability_info.requested_ship_date(l_parent_index),
                          -- 2754446
                          --least(org_availability_info.demand_quantity(j), l_available_quantity),
                          least(l_PO_qty, l_available_quantity),
                          null, -- l_atp_rec.supplier_id,
                          null, -- l_atp_rec.supplier_site_id,
                          org_availability_info.demand_class(l_parent_index),
                          -- rajjain 02/19/2003 Bug 2788302 Begin
                          -- Add Sourcing details
                          org_availability_info.organization_id(j),
                          p_atp_record.instance_id,
                          null, --process seq id (transfer case)
                          -- rajjain 02/19/2003 Bug 2788302 End
                          p_refresh_number, -- for summary enhancement
                          -- ship_rec_cal changes begin
                          org_availability_info.shipping_cal_code(j),   -- \
                          org_availability_info.receiving_cal_code(j),  -- |
                          org_availability_info.intransit_cal_code(j),  -- |
                          org_availability_info.new_ship_date(j),       -- \  Bug 3241766
                          org_availability_info.new_dock_date(j),       -- /  Add new columns start date and order date
                          org_availability_info.new_start_date(j),      -- |  Use values from child org rather than parent
                          org_availability_info.new_order_date(j),      -- |
                          org_availability_info.ship_method(j),         -- /
                          -- ship_rec_cal changes end
                          l_transaction_id,
                          l_return_status,
                          org_availability_info.lead_time(j), --4127630
                          item_availability_info.inventory_item_id(l_item_cntr), -- For time_phased_atp
                          org_availability_info.atf_date(l_parent_index)         -- For time_phased_atp

                       );
                    END IF;
                    -- End ATP4drp
--		  END IF;

                  --- now add PO pegging
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add pegging for PO');
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_index := ' || l_parent_index);
                  END IF;

		  Prep_PO_Pegging_Rec(l_pegging_rec,
				p_atp_record,
				org_availability_info,
				j,
				item_availability_info,
				l_item_cntr,
				least(l_PO_qty, l_available_quantity),
				l_transaction_id);

                  l_pegging_rec.atp_level:= p_level+1;
                  l_pegging_rec.scenario_id:= p_scenario_id;

                  MSC_ATP_SUBST.Add_Pegging(l_pegging_rec);
               END IF;
            ELSIF NVL(org_availability_info.demand_id(j), -1) > 0 THEN
               ---Above condition will filter out al the orgs that we did not visit but added to org_availability_info
		-- then we remove the demand provided its not in the top org
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Current org := ' || org_availability_info.organization_id(j));
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand id in this org := ' || org_availability_info.demand_id(j));
               END IF;

               -- dsting 2754446
/*
               l_available_quantity := greatest(org_availability_info.request_date_quantity(j), 0) +
                                                NVL(org_availability_info.quantity_from_children(j), 0) +
                                                NVL(org_availability_info.steal_qty(j), 0);
*/
               IF nvl(org_availability_info.rounding_flag(l_parent_index), 2) = 1 THEN
                  l_available_quantity := FLOOR(ROUND(
                                            (greatest(org_availability_info.request_date_quantity(j), 0)
                                             + NVL(org_availability_info.quantity_from_children(j), 0)
                                             + NVL(org_availability_info.steal_qty(j), 0)
                                            ) / org_availability_info.conversion_rate(j), 10)
                                          );
               ELSE
                  l_available_quantity := (greatest(org_availability_info.request_date_quantity(j), 0)
                                           + NVL(org_availability_info.quantity_from_children(j), 0)
                                           + NVL(org_availability_info.steal_qty(j), 0))
                                          * org_availability_info.conversion_rate(l_parent_index);
               END IF;

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('l_parent_index: ' || l_parent_index);
                  msc_sch_wb.atp_debug('l_avail_qty_top_uom: ' || l_avail_qty_top_uom);
                  msc_sch_wb.atp_debug('l_available_quantity: ' || l_available_quantity);
               END IF;

	       -- dsting do not update demands for diagnostic atp
	       IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP <> DIAGNOSTIC_ATP THEN

                  IF j > 1 AND l_available_quantity <= 0
	          THEN
                     --- if we do nto get anything from this org then we remove the demand
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Delete Demand');
                     END IF;
                     MSC_ATP_SUBST.delete_demand_subst(org_availability_info.demand_id(j),
                                                    org_availability_info.plan_id(j));
                  ELSE

                     --- update demand
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_available_quantity := ' || l_available_quantity);
                     END IF;

                     -- 2754446
                     -- IF org_availability_info.demand_quantity(j) > l_available_quantity and j > 1
                     IF org_availability_info.demand_quantity(j) > l_available_quantity * org_availability_info.conversion_rate(j)
                        and j > 1
	   	     THEN
                        --- we update demands from J > 1 because we want to retain full demand in top org
                        --- as CTP is still left to be done
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Update demand');
                        END IF;
                        MSC_ATP_SUBST.UPDATE_DEMAND(org_availability_info.demand_id(j),
                                                 org_availability_info.plan_id(j),
                                                 -- dsting 2754446
                                                 l_available_quantity
                                                 * org_availability_info.conversion_rate(j));
                        /* time_phased_atp */
                        --IF l_time_phased_atp = 'Y' THEN --bug3467631
                        IF  ((item_availability_info.sr_inventory_item_id(l_item_cntr) <>
                                org_availability_info.family_sr_id(j)) and
                                org_availability_info.atf_date(j) is not null) THEN
		          --using the same insert rec we prepared earlier
		          l_atp_insert_rec.quantity_ordered :=  l_available_quantity * org_availability_info.conversion_rate(j);
		          l_atp_insert_rec.requested_date_quantity := l_available_quantity * org_availability_info.conversion_rate(j);
		          l_atp_insert_rec.atf_date_quantity := org_availability_info.atf_date_quantity(j);
		          MSC_ATP_PF.Increment_Bucketed_Demands_Qty(
                                l_atp_insert_rec,
                                org_availability_info.plan_id(l_process_org_cntr),
                                org_availability_info.demand_id(l_process_org_cntr),
                                l_return_status
		          );
                          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                             IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Increment_Bucketed_Demands_Qty');
                             END IF;
                             RAISE FND_API.G_EXC_ERROR;
                          END IF;
                        END IF;
                        -- time_phased_atp changes end

                     END IF;
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'add pegging');
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'ATP Flag := ' || org_availability_info.atp_flag(J));
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'atp_comp_flag :=' || org_availability_info.atp_comp_flag(j));
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.quantity_ordered :=' || l_atp_insert_rec.quantity_ordered);
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.requested_date_quantity :=' || l_atp_insert_rec.requested_date_quantity);
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_insert_rec.atf_date_quantity :=' || l_atp_insert_rec.atf_date_quantity);
                     END IF;

	          END IF;
              END IF; -- dsting diagnostic ATP

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add pegging after onhand pass');
              END IF;

              -- 2754446
              l_PO_qty := org_availability_info.demand_quantity(j)
                 / org_availability_info.conversion_rate(j);

              IF org_availability_info.rounding_flag(l_parent_index) = 1 THEN
                 l_PO_qty := CEIL(ROUND(l_PO_qty,10));
              END IF;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('l_PO_qty: ' || l_PO_qty);
                 msc_sch_wb.atp_debug('dmd qty: ' || org_availability_info.demand_quantity(j));
                 msc_sch_Wb.atp_debug('conv rate: ' || org_availability_info.conversion_rate(l_parent_index));
              END IF;

              IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP OR
		 (l_available_quantity > 0 or j =1)
	      THEN
                     --- now add demand pegging
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add demand Pegging');
                     END IF;

   		     Prep_Demand_Pegging_rec(l_pegging_rec,
				p_atp_record,
				org_availability_info,
				j,
				item_availability_info,
				l_item_cntr);

                     IF j =1 OR MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
                        --- if it is top org then we add complete quantity
			-- dsting or if we're doing diagnostic atp
                        -- dsting 2754446
                        l_pegging_rec.supply_demand_quantity:= org_availability_info.demand_quantity(j);
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || ' J1:= ' || j);
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'quantity := ' || l_pegging_rec.supply_demand_quantity);
                        END IF;
                     ELSE
                        --- if it is other org then we create demand for least of what we need and what is available
                        -- dsting 2754446
                        l_pegging_rec.supply_demand_quantity:=
                           least(org_availability_info.demand_quantity(j),
                                 l_available_quantity * org_availability_info.conversion_rate(j));
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || ' J:= ' || j);
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'quantity := ' ||
                                l_pegging_rec.supply_demand_quantity);
                        END IF;

                     END IF;

                     l_pegging_rec.atp_level:= p_level;
                     l_pegging_rec.scenario_id:= p_scenario_id;

                     MSC_ATP_SUBST.Add_Pegging(l_pegging_rec);

                     --- we add supply pegging only for item where atp_flag = 'Y'
                     IF org_availability_info.atp_flag(j) in ('Y', 'C') THEN
                        --- now add supply pegging
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'add Supply Pegging');
                        END IF;

			Prep_Supply_Pegging_Rec(l_pegging_rec,
					p_atp_record,
					org_availability_info,
					j,
					item_availability_info,
					l_item_cntr,
					l_diag_transaction_id);

			l_pegging_rec.atp_level:= p_level + 1;
			l_pegging_rec.scenario_id:= p_scenario_id;

                        MSC_ATP_SUBST.Add_Pegging(l_pegging_rec);
                     END IF;
--                  END IF; -- if l_available_qty > 0

                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'after adding Supply and Demand Pegging');
                  END IF;
                  --- now add planned order
		  IF j > 1 and (l_available_quantity > 0 or MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP) THEN
                     --- we create planned order for tier 2 orgs only
       	             --  we create the planned order in parent org
               	     IF PG_DEBUG in ('Y', 'C') THEN
               	        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_available_quantity > 0 or Diagnostic ATP');
		 	msc_sch_wb.atp_debug('qty from children: ' || NVL(org_availability_info.quantity_from_children(l_parent_index), 0));
			msc_sch_wb.atp_debug('l_available_quantity: '|| l_available_quantity);
               	     END IF;

		     -- We balance out the supply/demand for the parent org since it is not a constraint node
		     -- for the last transfer child of an org that gets into org_availability_info,
		     -- we add a supply for the full demand placed on the child to do this.
		     -- If the parent org is the top org and we perform ctp
		     -- then we expect the ctp check to balance it out.

		     IF ((j = org_availability_info.parent_org_idx.count OR
			 org_availability_info.parent_org_idx(j+1) <>
			 org_availability_info.parent_org_idx(j)) AND
			 NOT (l_parent_index = 1 and l_create_supply_on_orig_item = 1)
			) AND MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP
		     THEN
                        -- dsting 2754446
			l_diag_supply_qty := (org_availability_info.demand_quantity(l_parent_index) -
					     NVL(org_availability_info.quantity_from_children(l_parent_index), 0) -
					     greatest(org_availability_info.request_date_quantity(l_parent_index), 0)
                                             ) + l_available_quantity;
			IF PG_DEBUG in ('Y', 'C') THEN
				msc_sch_wb.atp_debug('remaining dmd qty of parent: ' || l_diag_supply_qty);
			END IF;
		     ELSE
                        -- dsting 2754446
--			l_diag_supply_qty := least(org_availability_info.demand_quantity(j),
			l_diag_supply_qty := least(l_PO_qty,
					           greatest(0,l_available_quantity));
			IF PG_DEBUG in ('Y', 'C') THEN
                                msc_sch_Wb.atp_debug('l_PO_qty: ' || l_PO_qty);
				msc_sch_wb.atp_debug('l_PO_qty - avail qty: ' || l_diag_supply_qty);
			END IF;
		     END IF;

		     -- dsting set G_TOP_LAST_PO_PEGGING and G_TOP_LAST_PO_QTY in case the ctp
		     -- pass needs to adjust the PO from the onhand pass
		     IF l_parent_index = 1 AND MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING is NULL THEN
			MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING := org_availability_info.PO_Pegging_id(j);
			MSC_ATP_SUBST.G_TOP_LAST_PO_QTY := l_diag_supply_qty;
			IF PG_DEBUG in ('Y', 'C') THEN
				msc_sch_wb.atp_debug('Subst last PO pegging: ' || MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING);
			END IF;
		     END IF;

		     IF l_diag_supply_qty > 0
			OR MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING = org_availability_info.PO_Pegging_id(j)
		     THEN

                       -- Begin ATP4drp Create Planned Arrivals for DRP plans
                       IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
                          l_supply_rec.instance_id        :=   p_atp_record.instance_id;
                          l_supply_rec.plan_id            :=   org_availability_info.plan_id(l_parent_index);
                          l_supply_rec.inventory_item_id  :=  org_availability_info.family_dest_id(l_parent_index);
                                                                        -- DRP Plan re-set to member For time_phased_atp
                          l_supply_rec.organization_id    :=   org_availability_info.organization_id(l_parent_index);
                          l_supply_rec.schedule_date      :=   org_availability_info.requested_ship_date(l_parent_index);
                          l_supply_rec.order_quantity     :=   l_diag_supply_qty;
                             -- null; -- l_atp_rec.supplier_id,
                             -- null; -- l_atp_rec.supplier_site_id,
                          l_supply_rec.demand_class       :=   org_availability_info.demand_class(l_parent_index);
                          -- rajjain 02/19/2003 Bug 2788302 Begin
                          -- Add Sourcing details
                          l_supply_rec.source_organization_id :=   org_availability_info.organization_id(j);
                          l_supply_rec.source_sr_instance_id  :=   p_atp_record.instance_id;
                          -- null; --process seq id (transfer case)
                          -- rajjain 02/19/2003 Bug 2788302 End
                          l_supply_rec.refresh_number     :=   p_refresh_number; -- for summary enhancement
                          -- ship_rec_cal changes begin
                          l_supply_rec.shipping_cal_code  := org_availability_info.shipping_cal_code(j);   -- |
                          l_supply_rec.receiving_cal_code := org_availability_info.receiving_cal_code(j);  -- |
                          l_supply_rec.intransit_cal_code := org_availability_info.intransit_cal_code(j);  -- |
                          l_supply_rec.new_ship_date      := org_availability_info.new_ship_date(j);       -- |  Bug 3241766
                          l_supply_rec.new_dock_date      := org_availability_info.new_dock_date(j);       -- |
                                                                       -- |  Add new columns start date and order date
                          l_supply_rec.start_date         := org_availability_info.new_start_date(j);      -- |
                                                                       -- Use values from child org rather than parent
                          l_supply_rec.order_date         := org_availability_info.new_order_date(j);      -- |
                          l_supply_rec.ship_method        :=  org_availability_info.ship_method(j);         -- |
                          -- ship_rec_cal changes end
                          -- item_availability_info.inventory_item_id(l_item_cntr); -- For time_phased_atp
                          -- org_availability_info.atf_date(l_parent_index);        -- For time_phased_atp

                          l_supply_rec.firm_planned_type := 2;
                          l_supply_rec.disposition_status_type := 1;
                          l_supply_rec.record_source := 2; -- ATP created
                          l_supply_rec.supply_type := 51; --- planned arrival
                          l_supply_rec.intransit_lead_time := org_availability_info.lead_time(j); --4127630

                          MSC_ATP_DB_UTILS.ADD_Supplies(l_supply_rec);
                          -- Asssign the output to local variables.
                          l_transaction_id := l_supply_rec.transaction_id;
                          l_return_status  := l_supply_rec.return_status;
                          IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'DRP Plan Add Planned Inbound');
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Id l_transaction_id: ' || l_transaction_id);
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Type l_supply_rec.supply_type: '
                                                                                 || l_supply_rec.supply_type);
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Return Status l_return_status: ' || l_return_status);
                             msc_sch_wb.atp_debug('----- ATP4drp Specific Debug Messages -----');
                          END IF;

                       ELSE  -- Create Planned Order otherwise.
               	          IF PG_DEBUG in ('Y', 'C') THEN
               	             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add planned order');
                          END IF;
	                  MSC_ATP_DB_UTILS.Add_Planned_Order(
                                        p_atp_record.instance_id,
                                        org_availability_info.plan_id(l_parent_index),
                                        org_availability_info.family_dest_id(l_parent_index),  -- For time_phased_atp
                                        org_availability_info.organization_id(l_parent_index),
                                        org_availability_info.requested_ship_date(l_parent_index),
                                        l_diag_supply_qty,
                                        null, -- l_atp_rec.supplier_id,
                                        null, -- l_atp_rec.supplier_site_id,
                                        org_availability_info.demand_class(l_parent_index),
                                        -- rajjain 02/19/2003 Bug 2788302 Begin
                                        -- Add Sourcing details
                                        org_availability_info.organization_id(j),
                                        p_atp_record.instance_id,
                                        null, --process seq id (transfer case)
                                        -- rajjain 02/19/2003 Bug 2788302 End
                                        p_refresh_number, -- for summary enhancement
                                        -- ship_rec_cal changes begin
                                        org_availability_info.shipping_cal_code(j),   -- \
                                        org_availability_info.receiving_cal_code(j),  -- |
                                        org_availability_info.intransit_cal_code(j),  -- |
                                        org_availability_info.new_ship_date(j),       -- \  Bug 3241766
                                        org_availability_info.new_dock_date(j),       -- /  Add new columns start date and order date
                                        org_availability_info.new_start_date(j),      -- |  Use values from child org rather than parent
                                        org_availability_info.new_order_date(j),      -- |
                                        org_availability_info.ship_method(j),         -- /
                                        -- ship_rec_cal changes end
                                        l_transaction_id,
                                        l_return_status,
                                        org_availability_info.lead_time(j), --4127630
                                        item_availability_info.inventory_item_id(l_item_cntr), -- For time_phased_atp
                                        org_availability_info.atf_date(l_parent_index)         -- For time_phased_atp

               	          );
                       END IF;
                       -- End ATP4drp
		     END IF;

		     -- dsting open a planned order supply in the org to balance the
		     -- demand if it is not a constraint node and its demand is greater than the supply
		     IF org_availability_info.constraint_type(j) = NOSOURCES_NONCONSTRAINT AND
		        org_availability_info.demand_quantity(j) > l_available_quantity AND
		        MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP
		     THEN

		       IF PG_DEBUG in ('Y', 'C') THEN
		          msc_sch_wb.atp_debug('balance supply/demand for nonconstrained node');
		       END IF;
                       -- Begin ATP4drp Create Planned Arrivals for DRP plans
                       IF (NVL(MSC_ATP_PVT.G_PLAN_INFO_REC.plan_type,1) = 5) THEN
                          l_supply_rec.instance_id        :=   p_atp_record.instance_id;
                          l_supply_rec.plan_id            :=   org_availability_info.plan_id(l_parent_index);
                          l_supply_rec.inventory_item_id  :=   org_availability_info.family_dest_id(l_parent_index);
                                                                        -- DRP Plan re-set to member For time_phased_atp
                          l_supply_rec.organization_id    :=   org_availability_info.organization_id(l_parent_index);
                          l_supply_rec.schedule_date      :=   org_availability_info.requested_ship_date(l_parent_index);
                          l_supply_rec.order_quantity     :=
                                                           org_availability_info.demand_quantity(j) - l_available_quantity;
                             -- null; -- l_atp_rec.supplier_id,
                             -- null; -- l_atp_rec.supplier_site_id,
                          l_supply_rec.demand_class       :=   org_availability_info.demand_class(l_parent_index);
                          -- rajjain 02/19/2003 Bug 2788302 Begin
                          -- Add Sourcing details
                          l_supply_rec.source_organization_id :=   org_availability_info.organization_id(j);
                          l_supply_rec.source_sr_instance_id  :=   p_atp_record.instance_id;
                          -- null; --process seq id (transfer case)
                          -- rajjain 02/19/2003 Bug 2788302 End
                          l_supply_rec.refresh_number     :=   p_refresh_number; -- for summary enhancement
                          -- ship_rec_cal changes begin
                          l_supply_rec.shipping_cal_code  := org_availability_info.shipping_cal_code(j);   -- |
                          l_supply_rec.receiving_cal_code := org_availability_info.receiving_cal_code(j);  -- |
                          l_supply_rec.intransit_cal_code := org_availability_info.intransit_cal_code(j);  -- |
                          l_supply_rec.new_ship_date      := org_availability_info.new_ship_date(j);       -- |  Bug 3241766
                          l_supply_rec.new_dock_date      := org_availability_info.new_dock_date(j);       -- |
                                                                       -- |  Add new columns start date and order date
                          l_supply_rec.start_date         := org_availability_info.new_start_date(j);      -- |
                                                                       -- Use values from child org rather than parent
                          l_supply_rec.order_date         := org_availability_info.new_order_date(j);      -- |
                          l_supply_rec.ship_method        :=  org_availability_info.ship_method(j);         -- |
                          -- ship_rec_cal changes end
                          -- item_availability_info.inventory_item_id(l_item_cntr); -- For time_phased_atp
                          -- org_availability_info.atf_date(l_parent_index);        -- For time_phased_atp

                          l_supply_rec.firm_planned_type := 2;
                          l_supply_rec.disposition_status_type := 1;
                          l_supply_rec.record_source := 2; -- ATP created
                          l_supply_rec.supply_type := 51; --- planned arrival
                          l_supply_rec.intransit_lead_time := org_availability_info.lead_time(j); --4127630

                          MSC_ATP_DB_UTILS.ADD_Supplies(l_supply_rec);
                          -- Asssign the output to local variables.
                          l_transaction_id := l_supply_rec.transaction_id;
                          l_return_status  := l_supply_rec.return_status;
                          IF PG_DEBUG in ('Y', 'C') THEN
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Id l_transaction_id: ' || l_transaction_id);
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Supply Type l_supply_rec.supply_type: '
                                                                                 || l_supply_rec.supply_type);
                             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Return Status l_return_status: ' || l_return_status);
                          END IF;

                       ELSE  -- Create Planned Order otherwise.
	                  MSC_ATP_DB_UTILS.Add_Planned_Order(
                                p_atp_record.instance_id,
               	                org_availability_info.plan_id(l_parent_index),
                               	org_availability_info.family_dest_id(j),               -- For time_phased_atp
                               	org_availability_info.organization_id(j),
                                org_availability_info.requested_ship_date(j),
                                org_availability_info.demand_quantity(j) - l_available_quantity,
               	                null, -- l_atp_rec.supplier_id,
                       	        null, -- l_atp_rec.supplier_site_id,
                               	org_availability_info.demand_class(l_parent_index),
                                -- rajjain 02/19/2003 Bug 2788302 Begin
                                -- Add Sourcing details
                                org_availability_info.organization_id(j),
                                p_atp_record.instance_id,
                                null, --process seq id (transfer case)
                                -- rajjain 02/19/2003 Bug 2788302 End
                                p_refresh_number, -- for summary enhancement
                                -- ship_rec_cal changes begin
                                org_availability_info.shipping_cal_code(j),
                                org_availability_info.receiving_cal_code(j),
                                org_availability_info.intransit_cal_code(j),
                                org_availability_info.new_ship_date(j),
                                org_availability_info.new_dock_date(j),
                                org_availability_info.new_start_date(j),        -- Bug 3241766
                                org_availability_info.new_order_date(j),        -- Bug 3241766
                                org_availability_info.ship_method(j),
                                -- ship_rec_cal changes end
                                l_diag_transaction_id,
                                l_return_status,
                                org_availability_info.lead_time(j), --4127630
                                item_availability_info.inventory_item_id(l_item_cntr), -- For time_phased_atp
                                org_availability_info.atf_date(j)                      -- For time_phased_atp

               	          );
                       END IF;
                       -- End ATP4drp

		     END IF;

                     --- now add PO pegging
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add pegging for PO');
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_parent_index := ' || l_parent_index);
                     END IF;

		     Prep_PO_Pegging_Rec(l_pegging_rec,
				p_atp_record,
				org_availability_info,
				j,
				item_availability_info,
				l_item_cntr,
                                least(l_PO_qty, l_available_quantity),  -- dsting 2754446
--				l_available_quantity,
				l_transaction_id);

                     l_pegging_rec.atp_level:= p_level+1;
                     l_pegging_rec.scenario_id:= p_scenario_id;

                     MSC_ATP_SUBST.Add_Pegging(l_pegging_rec);

                  END IF;
               END IF; -- <<ADD_ONHAND_PEGGING>>
            END IF; -- IF NVL(org_availability_info.demand_id(j), -1) > 0  THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'after adding pegging for supplies, demand and planned order');
            END IF;



/*            --- now set the quantity from children
	    -- dsting I already got it for diagnostic atp
            IF j > 1 AND MSC_ATP_PVT.G_DIAGNOSTIC_ATP <> DIAGNOSTIC_ATP THEN
               l_PO_qty := org_availability_info.real_dmd_qty(j)
                  * org_availability_info.conversion_rate(l_parent_index)
                  / org_availability_info.conversion_rate(j);

               IF nvl(org_availability_info.rounding_flag(l_parent_index),2) = 1 THEN
                  l_PO_qty := CEIL(ROUND(l_PO_qty,10));
               END IF;
               org_availability_info.quantity_from_children(l_parent_index) :=
                                     NVL(org_availability_info.quantity_from_children(l_parent_index), 0) +
                                     LEAST((GREATEST(org_availability_info.request_date_quantity(j), 0) +
                                            NVL(org_availability_info.quantity_from_children(j), 0) +
                                            NVL(org_availability_info.steal_qty(j), 0)),
                                            l_PO_qty/org_availability_info.conversion_rate(l_parent_index));

               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: Update children quantity in parent org: idx '
                        || l_parent_index || ' qty: ' || org_availability_info.quantity_from_children(l_parent_index));
               END IF;
            END IF;
*/
         END LOOP; -- FOR j in reverse 1..org_availability_info.organization_id.count LOOP


         --4686870 , remove the records with origination_type as -200, when the supplies have been added.
         FOR j in 1..org_availability_info.organization_id.count LOOP
            DELETE MSC_DEMANDS
            where origination_type = -200
            and   sr_instance_id   = p_atp_record.instance_id
            and   plan_id          = org_availability_info.plan_id(j)
            and   demand_id        = org_availability_info.demand_id(j)
            and   organization_id  = org_availability_info.organization_id(j);
         END LOOP;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'After getting availablity for current item in all orgs');
         END IF;
         -- now we populate item info
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'End pegging id := ' || org_availability_info.demand_pegging_id(1));
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_counter := ' || l_item_cntr);
         END IF;
         Item_availability_info.End_pegging_id(l_item_cntr) :=  org_availability_info.demand_pegging_id(1);
         Item_availability_info.request_date_quantity(l_item_cntr) :=
                                                         GREATEST(org_availability_info.request_date_quantity(1), 0) +
                                                             NVL(org_availability_info.Quantity_from_children(1), 0) +
                                                             NVL(org_availability_info.steal_qty(1), 0);
         --bug3467631
         Item_availability_info.atf_date_quantity(l_item_cntr) := org_availability_info.atf_date_quantity(1);
         --- populate the end index of period and supply detils for this item
         l_period_end_idx := l_all_atp_period.level.count;
         l_sd_end_idx := l_all_atp_supply_demand.level.count;

         IF PG_DEBUG in ('Y', 'C') THEN
            --bug3467631 start
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_date_quantity := ' || Item_availability_info.request_date_quantity(l_item_cntr));
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Atf_Date_Quantity := ' || Item_availability_info.Atf_Date_Quantity(l_item_cntr));
            --bug3467631 end
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_period_end_idx := ' || l_period_end_idx);
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sd_end_idx := ' || l_sd_end_idx);
         END IF;

         item_availability_info.period_detail_end_Idx(l_item_cntr) := l_period_end_idx;
         item_availability_info.sd_detail_end_idx(l_item_cntr) := l_sd_end_idx;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'After updating item info');
         END IF;

	 -- Set p_atp_record to the item that is used to satisfy the demand
         IF l_net_demand <= 0 THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Met the requirement using item ' || item_availability_info.item_name(l_item_cntr));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Sr inv Id for the item := ' || item_availability_info.sr_inventory_item_id(l_item_cntr));
            END IF;
            --IF item_availability_info.sr_inventory_item_id(l_item_cntr) <> p_atp_record.inventory_item_id THEN
            --bug3467631
            IF item_availability_info.sr_inventory_item_id(l_item_cntr) <>
                                               NVL(p_atp_record.request_item_id,
                                                    p_atp_record.inventory_item_id) THEN
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand is satisfied by substitute');
               END IF;
               --- set the flag
               l_satisfied_by_subst_flag := 1;
            ELSE
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand is satisfied by the original item');
               END IF;
               l_satisfied_by_subst_flag := 2;
            END IF;
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_satisfied_by_subst_flag := ' || l_satisfied_by_subst_flag);
            END IF;

            --l_demand_satisfied_by_item_id := item_availability_info.sr_inventory_item_id(l_item_cntr);
            /* time_phased_atp changes begin
               request_item_id will store substitute item id
               inventory_item_id will store substitute family id
               original item id will store demanded item id*/
               --bug3467631 added so that correct names are shown
            --bug3709707 atf_date also populated so that correct atf date is returned to schedule
            p_atp_record.atf_date := item_availability_info.atf_date(l_item_cntr);
            p_atp_record.inventory_item_id := item_availability_info.family_sr_id(l_item_cntr);
            p_atp_record.inventory_item_name := item_availability_info.family_item_name(l_item_cntr);
            p_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_cntr);
            p_atp_record.request_item_name := item_availability_info.item_name(l_item_cntr);
            p_atp_record.original_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
            p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_id := ' || p_atp_record.inventory_item_id);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_name := ' || p_atp_record.inventory_item_name);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_id := ' || p_atp_record.request_item_id);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_name := ' || p_atp_record.request_item_name);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_id := ' || p_atp_record.original_item_id);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_name := ' || p_atp_record.original_item_name);
            END IF;
            -- time_phased_atp changes end

            --p_atp_record.End_pegging_id := item_availability_info.End_pegging_id(l_item_cntr);
            --- this variable is populated in end_peggign id for this line in procedure schedule
            MSC_ATP_PVT.G_DEMAND_PEGGING_ID := item_availability_info.End_pegging_id(l_item_cntr);
            l_demand_pegging_id := item_availability_info.End_pegging_id(l_item_cntr);

            p_atp_record.requested_date_quantity := item_availability_info.request_date_quantity(l_item_cntr);
       	    p_atp_record.available_quantity :=  item_availability_info.request_date_quantity(l_item_cntr);
       	    p_atp_record.Atf_Date_Quantity := item_availability_info.Atf_Date_Quantity(l_item_cntr); --bug3467631
            IF NVL(p_atp_record.atp_lead_time, 0) > 0 THEN
       	      /*
       	      p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET
                	                 (p_atp_record.organization_id,
                        	          p_atp_record.instance_id,
                                	  1,
	                                  l_requested_ship_date,
        	                          p_atp_record.atp_lead_time);*/
       	      p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET(
                	                  p_atp_record.manufacturing_cal_code,
                        	          p_atp_record.instance_id,
	                                  l_requested_ship_date,
        	                          p_atp_record.atp_lead_time, 1);
            ELSE
       	      p_atp_record.ship_date := l_requested_ship_date;
            END IF;

            --p_atp_record.inventory_item_id := item_availability_info.sr_inventory_item_id(l_item_cntr);
            l_count := Item_availability_info.inventory_item_id.count;
            p_atp_record.req_item_req_date_qty := Item_availability_info.request_date_quantity(l_item_count);
            --bug3467631
            IF Item_availability_info.sr_inventory_item_id(l_item_cntr) = NVL(p_atp_record.request_item_id,
                                                    p_atp_record.inventory_item_id) THEN
                --- request has been fullfilled by original item
                p_atp_record.req_item_req_date_qty := item_availability_info.request_date_quantity(l_item_cntr);
                p_atp_record.req_item_available_date := l_requested_ship_date;
                p_atp_record.req_item_available_date_qty
                                    :=  item_availability_info.request_date_quantity(l_item_cntr);
            END IF;

            --- add suply demand and period details
       	    IF PG_DEBUG in ('Y', 'C') THEN
       	       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'period_detail_begin_idx := '|| item_availability_info.period_detail_begin_idx(l_item_cntr));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'period_detail_end_idx := ' || item_availability_info.period_detail_end_idx(l_item_cntr));
       	       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'sd_detail_begin_idx:= ' || item_availability_info.sd_detail_begin_idx(l_item_cntr));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'sd_detail_end_idx:= ' || item_availability_info.sd_detail_end_idx(l_item_cntr));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'p_atp_record.Atf_Date_Quantity:= ' || p_atp_record.Atf_Date_Quantity); --bug3467631
            END IF;
       	    MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                         l_all_atp_supply_demand,
                                         item_availability_info.period_detail_begin_idx(l_item_cntr),
                                         item_availability_info.period_detail_end_idx(l_item_cntr),
                                         item_availability_info.sd_detail_begin_idx(l_item_cntr),
                                         item_availability_info.sd_detail_end_idx(l_item_cntr),
                                         x_atp_period,
                                         x_atp_supply_demand,
                                         l_return_status);
            --- now remove the demands for other items
       	    FOR i in (l_item_cntr +1)..l_item_count LOOP
                IF NOT (l_org_item_detail_flag = 1 and l_satisfied_by_subst_flag = 1 and
       	             item_availability_info.sr_inventory_item_id(i) = MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID) THEN
               	   IF PG_DEBUG in ('Y', 'C') THEN
               	      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'remove demands for item ' || item_availability_info.item_name(i));
               	   END IF;
                   MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                            item_availability_info.End_pegging_id(i),
                                             null,
                                             item_availability_info.plan_id(i),
                                             MSC_ATP_PVT.UNDO,
                                             null,
                                             l_return_status);
       	        END IF;
            END LOOP;
         END IF; -- IF l_net_demand <= 0 THEN
         --- increate the item counter
         --l_item_cntr := l_item_cntr + 1;

      END LOOP; ---  WHILE item_counter <= item_availability_info.inventory_item_id.count AND
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Item Availability Picture After Onhand search');
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         For i in 1..item_availability_info.inventory_item_id.count LOOP  --bug3467631
             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || item_availability_info.item_name(i) ||' ' ||item_availability_info.sr_inventory_item_id(i) ||
                               ' ' || item_availability_info.request_date_quantity(i) ||
                               ' ' || item_availability_info.Atf_Date_Quantity(i));
             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || item_availability_info.family_sr_id(i) ||' ' ||item_availability_info.family_item_name(i));

         END LOOP;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Do backward CTP pass if needed. net demand: ' || l_net_demand);
      END IF;


      --- if demand is not met then do CTP
      --- Also if demand is met by substitute item then we will provide atp date and quantity
      --- for original item depending upon value of original_item_details_flag.
      -- Therefore we might need to do CTP even on original item even if demand is met
      --- Backward CTP
      --l_org_item_detail_flag := NVL(p_atp_record.req_item_detail_flag, 2);
      --l_org_item_detail_flag := 1;
      l_net_demand_after_oh_check := l_net_demand;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Net demand after Onhand search := ' || l_net_demand);
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_org_item_detail_flag := ' || l_org_item_detail_flag);
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_satisfied_by_subst_flag := ' || l_satisfied_by_subst_flag);
      END IF;
      IF ((l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1)) or (l_net_demand_after_oh_check > 0) THEN

         --- get create supply flag
         --- if create supply flag is null then default it to Demanded item
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Backward Ctp');
         END IF;
         l_create_supply_flag := MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG;
         l_count := item_availability_info.inventory_item_id.count;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'G_CREATE_SUPPLY_FLAG := ' || MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG);
         END IF;
         --- bug 2388707: if demand has already been met then just add req item to the list of items
         --  to do CTP on
         IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
             IF (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG in (G_DEMANDED_ITEM, G_ITEM_ATTRIBUTE))
                OR (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM AND
                     l_highest_rev_item_id = item_availability_info.inventory_item_id(l_item_count)) THEN
                MSC_ATP_SUBST.Copy_Item_Info_rec(item_availability_info, l_item_ctp_info, l_item_count);
             END IF;
         ELSIF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_DEMANDED_ITEM  THEN

             MSC_ATP_SUBST.Copy_Item_Info_rec(item_availability_info, l_item_ctp_info, l_item_count);

         ELSIF  MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM THEN
             IF item_availability_info.inventory_item_id.count = 1 THEN
                --- we will come here if there are no substitutes or we are not substituting
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'One item. highest rev ' || l_highest_rev_item_id);
                END IF;
                IF (l_highest_rev_item_id = l_inventory_item_id) AND
                               (item_availability_info.create_supply_flag(l_item_count) = 1) THEN

                    MSC_ATP_SUBST.Copy_Item_Info_rec(item_availability_info, l_item_ctp_info, l_item_count);
                END IF;
             ELSE
                --- we will come here if we have one or more substitutes and we are doing substitution
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Multiple items');
                END IF;
                For i in 1..item_availability_info.inventory_item_id.count LOOP
                    -- find highest revision item
                    IF item_availability_info.inventory_item_id(i) = l_highest_rev_item_id THEN
                       l_highest_rev_item_index := i;
                       IF PG_DEBUG in ('Y', 'C') THEN
                          msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'i := ' || i);
                       END IF;
                       EXIT;
                    END IF;

                 END LOOP;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Counter for High. rev. item := ' || l_highest_rev_item_index);
                END IF;
                MSC_ATP_SUBST.Copy_Item_Info_rec(item_availability_info, l_item_ctp_info, l_highest_rev_item_index);
             END IF; -- IF item_availability_info.inventory_item_id.count = 1 THEN
         ELSE --- item attribute
            --- look at item attributes
            IF l_net_demand_after_oh_check > 0 THEN
               --- we haven't satisfied the demand as yet
               l_item_ctp_info := item_availability_info;
            ELSE
               --- we have satisfied the demand but we need to look for original item
               MSC_ATP_SUBST.Copy_Item_Info_rec(item_availability_info, l_item_ctp_info, l_count);
            END IF;
         END IF; -- IF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = 701

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'List of items to do CTP on');
            For i in reverse 1..l_item_ctp_info.inventory_item_id.count LOOP
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || l_item_ctp_info.item_name(i) || ' ' || l_item_ctp_info.sr_inventory_item_id(i) );
            END LOOP;
	    msc_sch_wb.atp_debug('Subst last PO pegging: ' || MSC_ATP_SUBST.G_TOP_LAST_PO_PEGGING);
         END IF;

         -- AT this point we know on what item do we need to do CTP
         --l_net_demand :=
         IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
            l_net_demand := p_atp_record.quantity_ordered -
                                       item_availability_info.request_date_quantity(l_item_count);
            l_insert_flag := 0;
         ELSE
            l_insert_flag := p_atp_record.insert_flag;
         END IF;

	 IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
		MSC_ATP_PVT.G_DEMAND_PEGGING_ID := item_availability_info.end_pegging_id(1);
	 END IF;

         FOR i in reverse 1..l_item_ctp_info.inventory_item_id.count LOOP

             IF l_net_demand <= 0 or l_requested_ship_date < l_sys_date_top_org THEN
                EXIT;
             END IF;
             l_net_demand := p_atp_record.quantity_ordered - l_item_ctp_info.request_date_quantity(i);
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Do CTP on := ' || l_item_ctp_info.item_name(i) || ' '
                                                  || l_item_ctp_info.sr_inventory_item_id(i));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand := ' || l_net_demand);
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'atp_comp_flag := ' || l_item_ctp_info.atp_comp_flag(i));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'create_supply_flag := ' || l_item_ctp_info.create_supply_flag(i));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'end pegging id := ' || l_item_ctp_info.end_pegging_id(i));
             END IF;

             IF l_item_ctp_info.atp_comp_flag(i) in ('Y', 'C', 'R') and l_item_ctp_info.create_supply_flag(i) = 1 THEN

                l_atp_rec.error_code := 0;
                l_atp_rec.available_quantity := NULL;
                l_atp_rec.requested_date_quantity := NULL;



                -- no need to do uom conversion
                l_atp_rec.instance_id := p_atp_record.instance_id;
                -- what do we need to do with thie ???
                l_atp_rec.demand_source_line := null;
                l_atp_rec.identifier := MSC_ATP_PVT.G_ORDER_LINE_ID;
                l_atp_rec.component_identifier :=  null ; --l_comp_requirements.component_identifier(j);

                -- time_phased_atp bug3467631
                l_atp_rec.inventory_item_id := l_item_ctp_info.family_sr_id(i);
                /*l_atp_rec.inventory_item_id := MSC_ATP_PF.Get_Pf_Atp_Item_Id(
                                                        p_atp_record.instance_id,
                                                        l_item_ctp_info.plan_id(i),
                                                        l_item_ctp_info.sr_inventory_item_id(i),
                                                        p_atp_record.organization_id
                                               );*/
		-- dsting
		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'assigning item_name: ' ||l_item_ctp_info.item_name(i));
		   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'assigning inventory_item_id: ' ||l_atp_rec.inventory_item_id);
		END IF;
                l_atp_rec.inventory_item_name := l_item_ctp_info.item_name(i);
                l_atp_rec.request_item_id := l_item_ctp_info.sr_inventory_item_id(i);
                l_atp_rec.organization_id := p_atp_record.organization_id;
                l_atp_rec.quantity_ordered := l_net_demand;
                --setting atf_date
                l_atp_rec.Atf_Date := l_item_ctp_info.Atf_Date(i); --bug3467631
                -- l_atp_rec.quantity_uom := l_quantity_uom;
                l_atp_rec.requested_ship_date := l_requested_ship_date;
                l_atp_rec.demand_class := p_atp_record.demand_class;
                l_atp_rec.insert_flag := l_insert_flag;
                l_atp_rec.refresh_number := p_refresh_number;
                l_atp_rec.refresh_number := null;
	        l_atp_rec.ship_date := null;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand class for CTP := ' ||  l_item_ctp_info.demand_class(i));
                END IF;
                l_atp_rec.demand_class := l_item_ctp_info.demand_class(i);

                l_plan_id :=  l_item_ctp_info.plan_id(i);
                l_assign_set_id := l_item_ctp_info.assign_set_id(i);

                l_atp_rec.subs_demand_id := l_item_ctp_info.demand_id(i); --5088719
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_ctp_info.demand_id(i) ' ||  l_item_ctp_info.demand_id(i));
                END IF;

                l_atp_rec.original_item_flag := 1;
                l_atp_rec.top_tier_org_flag := 1;
                l_atp_rec.delivery_lead_time := 0;
                MSC_ATP_PVT.G_DEMAND_PEGGING_ID :=  l_item_ctp_info.end_pegging_id(i);
                --diag_atp
                l_atp_rec.plan_name := l_item_ctp_info.plan_name(i);

		-- dsting diag_atp
		MSC_ATP_PVT.G_HAVE_MAKE_BUY_PARENT := 0;

		-- bug3467631 done for ship_rec_cal
                l_atp_rec.shipping_cal_code       := p_atp_record.shipping_cal_code;
                l_atp_rec.receiving_cal_code      := p_atp_record.receiving_cal_code;
                l_atp_rec.intransit_cal_code      := p_atp_record.intransit_cal_code;
                l_atp_rec.manufacturing_cal_code  := p_atp_record.manufacturing_cal_code;

                MSC_ATP_PVT.ATP_Check(l_atp_rec,
                                     l_plan_id,
                                     p_level ,
                                     p_scenario_id,
                                     1,
                                     p_refresh_number,
                                     l_item_ctp_info.end_pegging_id(i),
                                     l_assign_set_id,
                                     l_atp_period,
                                     l_atp_supply_demand,
                                     x_return_status);
             ELSE
                 l_atp_rec.requested_date_quantity := 0;
                 --Bug 3878343 , set l_atp_period to NULL, incase CTP is not done.
                 l_atp_period := L_NULL_ATP_PERIOD;
             END IF;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_rec.requested_date_quantity := ' || l_atp_rec.requested_date_quantity);
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_rec.atf_date_quantity := ' || l_atp_rec.atf_date_quantity);
             END IF;
             l_net_demand := l_net_demand - l_atp_rec.requested_date_quantity;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand := ' || l_net_demand);
             END IF;

             IF l_item_count = 1 THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Only one item');
                END IF;
                l_item_idx := 1;
             ELSE
                --bug 2388707: If demand has already been met then we are just looking for original item
                -- therefore we set the index to be that of last item.
                IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
                   l_item_idx := l_item_count;

                ELSIF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_DEMANDED_ITEM THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'More item but we retun the index for original item');
                   END IF;
                   l_item_idx := l_item_count;
                ELSIF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Index for highest rev item');
                   END IF;
                   l_item_idx := l_highest_rev_item_index;
                ELSE

                   IF l_item_ctp_info.inventory_item_id.count = 1 THEN
                      --- this case will be true only if we have already satisfied the demand
                      --- using a substitute
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'we have alread met req. We return index for req item');
                      END IF;
                      l_item_idx := l_item_count;
                   ELSE
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Item Attib, index of current item');
                      END IF;
                      l_item_idx := i;
                   END IF;
                END IF;
             END IF;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_idx := ' || l_item_idx);
             END IF;
             l_item_ctp_info.request_date_quantity(i) :=
                        NVL(l_item_ctp_info.request_date_quantity(i), 0) + l_atp_rec.requested_date_quantity;
             item_availability_info.request_date_quantity(l_item_idx) :=
                       NVL(item_availability_info.request_date_quantity(l_item_idx), 0) +
                          l_atp_rec.requested_date_quantity;
             --bug3467631 adding atf_date_quantity from backward CTP
             l_item_ctp_info.atf_date_quantity(i) :=
                        NVL(l_item_ctp_info.atf_date_quantity(i), 0) +
                           NVL(l_atp_rec.atf_date_quantity,l_atp_rec.requested_date_quantity);
             item_availability_info.atf_date_quantity(l_item_idx) :=
                       NVL(item_availability_info.atf_date_quantity(l_item_idx), 0) +
                         + NVL(l_atp_rec.atf_date_quantity, l_atp_rec.requested_date_quantity);

             IF PG_DEBUG in ('Y', 'C') THEN --bug3467631
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item_availability_info.request_date_quantity(l_item_idx) := '|| item_availability_info.request_date_quantity(l_item_idx));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_rec.requested_date_quantity := ' || l_atp_rec.requested_date_quantity);
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_ctp_info.requested_date_quantity := ' || l_item_ctp_info.request_date_quantity(i));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item_availability_info.atf_date_quantity(l_item_idx) := '|| item_availability_info.atf_date_quantity(l_item_idx));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_rec.atf_date_quantity := ' || l_atp_rec.atf_date_quantity);
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_ctp_info.atf_date_quantity := ' || l_item_ctp_info.atf_date_quantity(i));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item_availability_info.request_date_quantity(l_item_idx) := ' || item_availability_info.request_date_quantity(l_item_idx));
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_ctp_info.Atf_Date := ' || l_item_ctp_info.Atf_Date(i));
             END IF;
             IF l_net_demand <= 0 THEN
                 IF l_net_demand_after_oh_check > 0 THEN
                   -- we have met the demand
                   --- update the p_atp_record
                   --l_ordered_item_id := p_atp_record.inventory_item_id;
                   --l_demand_satisfied_by_item_id := l_item_ctp_info.sr_inventory_item_id(i);
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Met the requirement using item ' || l_item_ctp_info.item_name(i));
                   END IF;
                   --bug3467631
                   IF l_item_ctp_info.sr_inventory_item_id(i) <> NVL(p_atp_record.request_item_id,
                                                    p_atp_record.inventory_item_id) THEN
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand is satisfied by substitute');
                      END IF;
                      --- set the flag
                      l_satisfied_by_subst_flag := 1;
                   ELSE
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand is satisfied by the original item');
                      END IF;
                      l_satisfied_by_subst_flag := 2;
                   END IF;
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_satisfied_by_subst_flag := ' || l_satisfied_by_subst_flag);
                   END IF;

                   p_atp_record.requested_date_quantity := p_atp_record.quantity_ordered;
                   p_atp_record.Atf_Date_Quantity :=
                                     l_item_ctp_info.Atf_Date_Quantity(i); --bug3467631
                   -- time_phased_atp changes begin
                   --   request_item_id will store substitute item id
                   --   inventory_item_id will store substitute family id
                   --   original item id will store demanded item id
                   --bug3709707 atf_date also populated so that correct atf date is returned to schedule
                   p_atp_record.atf_date := l_item_ctp_info.atf_date(i);
                   p_atp_record.inventory_item_id := l_item_ctp_info.family_sr_id(i);
                   p_atp_record.inventory_item_name := l_item_ctp_info.family_item_name(i);
                   p_atp_record.request_item_id := l_item_ctp_info.sr_inventory_item_id(i);
                   p_atp_record.request_item_name := l_item_ctp_info.item_name(i);
                   p_atp_record.original_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
                   p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);

                   IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_id := ' || p_atp_record.inventory_item_id);
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_name := ' || p_atp_record.inventory_item_name);
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_id := ' || p_atp_record.request_item_id);
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_name := ' || p_atp_record.request_item_name);
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_id := ' || p_atp_record.original_item_id);
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_name := ' || p_atp_record.original_item_name);
                   END IF;
                   -- time_phased_atp changes end
                   --p_atp_record.End_pegging_id := item_availability_info.End_pegging_id(l_item_cntr);
                   --- this variable is populated in end_peggign id for this line in procedure schedule
                   MSC_ATP_PVT.G_DEMAND_PEGGING_ID := l_item_ctp_info.End_pegging_id(i);
                   l_demand_pegging_id := l_item_ctp_info.End_pegging_id(i);

                   IF NVL(p_atp_record.atp_lead_time, 0) > 0 THEN
                     /* ship_rec_cal
                     p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET
                                 (p_atp_record.organization_id,
                                  p_atp_record.instance_id,
                                  1,
                                  l_requested_ship_date,
                                  p_atp_record.atp_lead_time);*/
                     p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET(
                                  p_atp_record.manufacturing_cal_code,
                                  p_atp_record.instance_id,
                                  l_requested_ship_date,
                                  p_atp_record.atp_lead_time, 1);
                   ELSE
                     p_atp_record.ship_date := l_requested_ship_date;
                   END IF;
                   p_atp_record.available_quantity :=  p_atp_record.quantity_ordered;
                   l_count := Item_availability_info.inventory_item_id.count;
                   p_atp_record.req_item_req_date_qty := Item_availability_info.request_date_quantity(l_item_count);
                   IF l_item_ctp_info.sr_inventory_item_id(i) = MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID THEN
                       --- request has been fullfilled by original item
                       p_atp_record.req_item_req_date_qty :=
                                      item_availability_info.request_date_quantity(l_item_count);
                       p_atp_record.req_item_available_date := l_requested_ship_date;
                       p_atp_record.req_item_available_date_qty
                                    :=  item_availability_info.request_date_quantity(l_item_count);
                   END IF;


                   --- now add supply demand/period details to out_put table
                   --- first add onhand/sch recp supply demand details
                   MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                         l_all_atp_supply_demand,
                                         l_item_ctp_info.period_detail_begin_idx(i),
                                         l_item_ctp_info.period_detail_end_idx(i),
                                         l_item_ctp_info.sd_detail_begin_idx(i),
                                         l_item_ctp_info.sd_detail_end_idx(i),
                                         x_atp_period,
                                         x_atp_supply_demand,
                                         l_return_status);
                   --- now add supply demand details for CTP
                   MSC_ATP_PROC.Details_Output(l_atp_period,
                                            l_atp_supply_demand,
                                            x_atp_period,
                                            x_atp_supply_demand,
                                            l_return_status);

                   --- Now remove the pegging/ supply demand for other items
                   For j in 1..item_availability_info.inventory_item_id.count LOOP
                      IF (item_availability_info.inventory_item_id(j) <> l_item_ctp_info.inventory_item_id(i)) AND
                      NOT(l_satisfied_by_subst_flag = 1 and l_org_item_detail_flag = 1 AND
                               item_availability_info.sr_inventory_item_id(j) = MSC_ATP_SUBST.G_REQ_ITEM_SR_INV_ID) THEN

                         IF PG_DEBUG in ('Y', 'C') THEN
                            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Remove Pegging for item := ' || item_availability_info.inventory_item_id(i));
                         END IF;

                         MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                         item_availability_info.End_pegging_id(j),
                                          null,
                                          item_availability_info.plan_id(j),
                                          MSC_ATP_PVT.UNDO,
                                          null,
                                          l_return_status);

                     END IF;  -- IF item_availability_info.inventory_item_id(j) <> l_item_ctp_info.inventory
                   END LOOP; -- For j in 1..item_availability_info.inventory_item_id.count LOOP

                ELSE --- IF l_net_demand_after_oh_check > 0 THEN

                   --- we had already met the deamand using on hand/sch receipts of substitute item
                   -- now we have found enough quantity for ordered item as well so we will update the columns
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'demand met by a subst,  provide detail for origninal item');
                   END IF;
                   MSC_ATP_PVT.G_DEMAND_PEGGING_ID := l_demand_pegging_id;
                   p_atp_record.req_item_req_date_qty := p_atp_record.quantity_ordered;

                   IF NVL(p_atp_record.atp_lead_time, 0) > 0 THEN
                     /* ship_rec_cal
                     p_atp_record.req_item_available_date := MSC_CALENDAR.DATE_OFFSET
                                 (p_atp_record.organization_id,
                                  p_atp_record.instance_id,
                                  1,
                                  l_requested_ship_date,
                                  p_atp_record.atp_lead_time);*/
                     p_atp_record.req_item_available_date := MSC_CALENDAR.DATE_OFFSET(
                                  p_atp_record.manufacturing_cal_code,
                                  p_atp_record.instance_id,
                                  l_requested_ship_date,
                                  p_atp_record.atp_lead_time, 1);
                   ELSE
                     p_atp_record.req_item_available_date := l_requested_ship_date;
                   END IF;

                   p_atp_record.req_item_available_date_qty := p_atp_record.quantity_ordered;
                   -- time_phased_atp
                   --p_atp_record.request_item_name := l_item_ctp_info.item_name(i);
                   --bug3467631 start added so that correct names are shown
                   --p_atp_record.original_item_name := l_item_ctp_info.item_name(i);
                   p_atp_record.requested_date_quantity := p_atp_record.quantity_ordered;
                   p_atp_record.Atf_Date_Quantity :=
                                     l_item_ctp_info.Atf_Date_Quantity(i);
                   --bug3709707 no need to populate names here
                   /*
                   p_atp_record.inventory_item_id := l_item_ctp_info.family_sr_id(i);
                   p_atp_record.inventory_item_name := l_item_ctp_info.family_item_name(i);
                   p_atp_record.request_item_id := l_item_ctp_info.sr_inventory_item_id(i);
                   p_atp_record.request_item_name := l_item_ctp_info.item_name(i);
                   p_atp_record.original_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
                   p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);
                   */
                   --bug3467631 end
                   l_satisfied_by_subst_flag := 2;
                   --- remove peggin and supply demand details


                   MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                         item_availability_info.End_pegging_id(l_item_count),
                                          null,
                                          item_availability_info.plan_id(l_item_count),
                                          MSC_ATP_PVT.UNDO,
                                          null,
                                          l_return_status);
                END IF;


             --ELSE --Bug 3878343 , donot call Details_Output() in case l_atp_period is NULL.
             ELSIF ( l_atp_period.Level IS NOT NULL AND
                     l_atp_period.Level.COUNT > 0 ) THEN

                --- add l_atp_period and l_atp_supply_demand
                l_period_begin_idx := l_all_atp_period.level.COUNT;
                l_sd_begin_idx := l_all_atp_supply_demand.level.count;

                IF l_period_begin_idx = 0 THEN
                   l_period_begin_idx := 1;
                ELSE
                   l_period_begin_idx := l_period_begin_idx +1;
                END IF;

                IF l_sd_begin_idx = 0 THEN
                   l_sd_begin_idx := 1;
                ELSE
                   l_sd_begin_idx := l_sd_begin_idx + 1;
                END IF;

                --- now add period and supply details
                MSC_ATP_PROC.Details_Output(l_atp_period,
                                            l_atp_supply_demand,
                                            l_all_atp_period,
                                            l_all_atp_supply_demand,
                                            l_return_status);
                l_period_end_idx := l_all_atp_period.level.count;
                l_sd_end_idx := l_all_atp_supply_demand.level.count;

                item_availability_info.ctp_prd_detl_begin_idx(l_item_idx) := l_period_begin_idx;
                item_availability_info.ctp_prd_detl_end_idx(l_item_idx) := l_period_end_idx;
                item_availability_info.ctp_sd_detl_begin_idx(l_item_idx) := l_sd_begin_idx;
                item_availability_info.ctp_sd_detl_end_idx(l_item_idx) := l_sd_end_idx;



             END IF;


         END LOOP;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'net demand after backward CTP := ' || l_net_demand);
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         FOR i in reverse 1..item_availability_info.inventory_item_id.count LOOP
             msc_sch_wb.atp_debug('ATP_Check_Subst: ' || item_availability_info.item_name(i) || ' ' ||
                               item_availability_info.sr_inventory_item_id(i) || ' ' ||
                               item_availability_info.request_date_quantity(i));
         END LOOP;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'p_atp_record.inventory_item_name: ' || p_atp_record.inventory_item_name );
      END IF;

      -- dsting skip Forward scheduling for diagnostic ATP
      IF MSC_ATP_PVT.G_DIAGNOSTIC_ATP = DIAGNOSTIC_ATP THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'no forward pass for diagnostic ATP');
	END IF;

	IF l_net_demand > 0 THEN
           /* time_phased_atp changes begin
              request_item_id will store substitute item id
              inventory_item_id will store substitute family id
              original item id will store demanded item id*/
           --bug3709707 atf_date also populated so that correct atf date is returned to schedule
           p_atp_record.atf_date := item_availability_info.atf_date(l_item_count);
           p_atp_record.inventory_item_id := item_availability_info.family_sr_id(l_item_count);
           p_atp_record.inventory_item_name := item_availability_info.family_item_name(l_item_count);
           p_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
           p_atp_record.request_item_name := item_availability_info.item_name(l_item_count);
           p_atp_record.original_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
           p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);
           -- time_phased_atp changes end

         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_id := ' || p_atp_record.inventory_item_id);
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'inventory_item_name := ' || p_atp_record.inventory_item_name);
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_id := ' || p_atp_record.request_item_id);
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'request_item_name := ' || p_atp_record.request_item_name);
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_id := ' || p_atp_record.original_item_id);
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'original_item_name := ' || p_atp_record.original_item_name);
         END IF;
           p_atp_record.atf_date_quantity := item_availability_info.atf_date_quantity(l_item_count);
           p_atp_record.requested_date_quantity := item_availability_info.request_date_quantity(l_item_count);
           p_atp_record.available_quantity :=  item_availability_info.request_date_quantity(l_item_count);
           p_atp_record.req_item_req_date_qty := item_availability_info.request_date_quantity(l_item_count);

	END IF;

	goto CLEANUP;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Do forward scheduling if needed. net demand: ' || l_net_demand);
      END IF;

      --- we are done with backward CTP. Now do Forward Schedulling if needed
      IF ((l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1)) or (l_net_demand > 0) THEN
         IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
            l_insert_flag := 0;
         ELSE
            l_insert_flag := p_atp_record.insert_flag;
         END IF;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Inside Forward Scheduling');
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item count := ' || item_availability_info.inventory_item_id.count);
         END IF;
         FOR i in reverse 1..item_availability_info.inventory_item_id.count LOOP
            --- look for date by which we can meet by onhand
            l_net_demand := p_atp_record.quantity_ordered - item_availability_info.request_date_quantity(i);
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Get future onhand date for item := ' ||
                                  item_availability_info.item_name(i));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Net demand future case := ' || l_net_demand);
            END IF;
            --- first update the demand so that the picture gets adjusted
            MSC_ATP_SUBST.UPDATE_DEMAND(item_availability_info.demand_id(i),
                                        item_availability_info.plan_id(i),
                                        item_availability_info.request_date_quantity(i));

            /* time_phased_atp */
            IF ((item_availability_info.sr_inventory_item_id(i) <>
                             item_availability_info.family_sr_id(i)) AND
                               item_availability_info.atf_date(i) is not null) THEN
	          --using the same insert rec we prepared earlier
	          l_atp_insert_rec.quantity_ordered :=  item_availability_info.request_date_quantity(i);
	          l_atp_insert_rec.requested_date_quantity := item_availability_info.request_date_quantity(i);
	          l_atp_insert_rec.atf_date_quantity := item_availability_info.atf_date_quantity(i);
	          --bug3467631 Inside Forward Scheduling re-initializing otherwise l_atp_insert_rec.inventory_item_id,
	          --l_atp_insert_rec.request_item_id,l_atp_insert_rec.atf_date will have substitute's values
	          --even when we are processing member item.
	          l_atp_insert_rec.inventory_item_id := item_availability_info.family_dest_id(i); --bug3467631
                  l_atp_insert_rec.request_item_id := item_availability_info.inventory_item_id(i); --bug3467631
                  l_atp_insert_rec.atf_date := item_availability_info.atf_date(i); --bug3467631
	          MSC_ATP_PF.Increment_Bucketed_Demands_Qty(
                        l_atp_insert_rec,
                        item_availability_info.plan_id(i),
                        item_availability_info.demand_id(i),
                        l_return_status
	          );
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Error occured in procedure Increment_Bucketed_Demands_Qty');
                     END IF;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
            END IF;
            -- time_phased_atp changes end

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Now get the future date');
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || item_availability_info.atp_flag(i));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'atp_flag := ' || item_availability_info.atp_flag(i));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'atp_flag := ' || item_availability_info.atp_comp_flag(i));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_sys_date_top_org := ' || l_sys_date_top_org);
            END IF;
            IF item_availability_info.atp_flag(i) = 'N' and item_availability_info.atp_comp_flag(i) = 'N' THEN
               --- we will come here only if item if req_date is passed due
               l_atp_date_quantity_this_level := p_atp_record.quantity_ordered;
               l_atp_date_this_level := l_sys_date_top_org;
               l_requested_date_quantity := 0;
               item_availability_info.future_atp_date(i) :=l_atp_date_this_level;
               item_availability_info.atp_date_quantity(i) := l_atp_date_quantity_this_level;

            ELSIF item_availability_info.atp_flag(i) in ('Y', 'C') THEN
	       l_get_mat_in_rec.rounding_control_flag := item_availability_info.rounding_control_type(i);
	       l_get_mat_in_rec.dest_inv_item_id := item_availability_info.inventory_item_id(i);
               l_get_mat_in_rec.plan_name := item_availability_info.plan_name(i);
               --bug3700564 passed shipping cal code as a part of this fix.
               l_get_mat_in_rec.shipping_cal_code := p_atp_record.shipping_cal_code;
               l_get_mat_in_rec.receiving_cal_code := p_atp_record.receiving_cal_code; -- Bug 3826234
               l_get_mat_in_rec.intransit_cal_code := p_atp_record.intransit_cal_code; -- Bug 3826234
               l_get_mat_in_rec.manufacturing_cal_code := p_atp_record.manufacturing_cal_code; -- Bug 3826234
               l_get_mat_in_rec.to_organization_id := p_atp_record.to_organization_id; -- Bug 3826234

               /* To support new logic for dependent demands allocation in time phased PF rule based AATP scenarios
                  Set global variable. This is used in Get_Item_Demand_Alloc_Percent function*/
               IF item_availability_info.atf_date(i) is not null THEN
                      /* Set global variable. This is used in Get_Item_Demand_Alloc_Percent function*/
                   MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'Y';
               ELSE
                   MSC_ATP_PVT.G_TIME_PHASED_PF_ENABLED := 'N';
               END IF;

               IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                    (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) THEN

                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Allocated ATP with demand priority');
                  END IF;
                  ---forward steal
                  MSC_ATP_PVT.G_DEMAND_PEGGING_ID :=  item_availability_info.end_pegging_id(i);

                  -- dsting setting global item_attributes so get_forward_material_atp populates the
                  -- item attributes in pegging. Since G_ITEM_INFO_REC may not be the
                  -- item we are processing (ie a substitute)
                  MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id := item_availability_info.family_dest_id(i); --bug3467631
                  MSC_ATP_PVT.G_ITEM_INFO_REC.atp_flag := item_availability_info.atp_flag(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.atp_comp_flag := item_availability_info.atp_comp_flag(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.pre_pro_lt := item_availability_info.pre_pro_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.post_pro_lt := item_availability_info.post_pro_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.fixed_lt := item_availability_info.fixed_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.variable_lt := item_availability_info.variable_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight := item_availability_info.unit_weight(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume := item_availability_info.unit_volume(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.weight_uom := item_availability_info.weight_uom(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.volume_uom := item_availability_info.volume_uom(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.substitution_window := item_availability_info.substitution_window(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.organization_id := NULL;

                  MSC_AATP_REQ.Get_Forward_Material_Atp(
                                p_atp_record.instance_id,
                                item_availability_info.plan_id(i),
                                p_level + 1,
                                p_atp_record.identifier,
                                p_atp_record.demand_source_type,--cmro
                                p_scenario_id,
                                item_availability_info.sr_inventory_item_id(i),
                                item_availability_info.family_sr_id(i), -- For time_phased_atp
                                p_atp_record.organization_id,
                                item_availability_info.item_name(i),
                                item_availability_info.family_item_name(i), -- For time_phased_atp
                                l_requested_ship_date,
                                l_net_demand,
                                item_availability_info.demand_class(i),
                                l_requested_date_quantity,
                                l_atf_date_qty, -- For time_phased_atp
                                l_atp_date_this_level,
                                l_atp_date_quantity_this_level,
                                l_atp_pegging_tab,
                                l_return_status,
                                l_used_available_quantity,--bug3409973
                                item_availability_info.substitution_window(i),
				l_get_mat_in_rec,
				l_get_mat_out_rec,
				item_availability_info.atf_date(i) -- For time_phased_atp
		  );

                  item_availability_info.fwd_steal_peg_begin_idx(i) := l_fwd_atp_pegging_tab.count +1;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Fwd peg count for curr item := ' || l_atp_pegging_tab.count);
                  END IF;
                  FOR j in 1..l_atp_pegging_tab.count LOOP
                      l_fwd_atp_pegging_tab.extend;
                      l_fwd_atp_pegging_tab(l_fwd_atp_pegging_tab.count) := l_atp_pegging_tab(j);

                  END LOOP;
                  item_availability_info.fwd_steal_peg_end_idx(i) := l_fwd_atp_pegging_tab.count;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'fwd peg count := ' || l_fwd_atp_pegging_tab.count);
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_date_this_level := ' || l_atp_date_this_level);
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_date_quantity_this_level := ' || l_atp_date_quantity_this_level);
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_used_available_quantity := ' || l_used_available_quantity); --bug3409973
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atf_date_qty := ' || l_atf_date_qty); --bug3467631
                  END IF;
               ELSE
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'ATP without demand priority allocated ATP');
                  END IF;
                  --bug3467631 Inside Forward Scheduling re-initializing MSC_ATP_PVT.G_ITEM_INFO_REC
                  --otherwise it will have substitute's values even when we are processing member item.
                  --bug3467631 start
                  MSC_ATP_PVT.G_ITEM_INFO_REC.product_family_id := item_availability_info.family_dest_id(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.inventory_item_id := item_availability_info.inventory_item_id(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.atp_flag := item_availability_info.atp_flag(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.atp_comp_flag := item_availability_info.atp_comp_flag(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.pre_pro_lt := item_availability_info.pre_pro_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.post_pro_lt := item_availability_info.post_pro_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.fixed_lt := item_availability_info.fixed_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.variable_lt := item_availability_info.variable_lt(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_weight := item_availability_info.unit_weight(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.unit_volume := item_availability_info.unit_volume(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.weight_uom := item_availability_info.weight_uom(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.volume_uom := item_availability_info.volume_uom(i);
                  MSC_ATP_PVT.G_ITEM_INFO_REC.substitution_window := item_availability_info.substitution_window(i);
                  --bug3467631 end
                  -- time_phased_atp changes begin
                  l_mat_atp_info_rec.instance_id               := p_atp_record.instance_id;
                  l_mat_atp_info_rec.plan_id                   := item_availability_info.plan_id(i);
                  l_mat_atp_info_rec.level                     := p_level;
                  l_mat_atp_info_rec.identifier                := p_atp_record.identifier;
                  l_mat_atp_info_rec.scenario_id               := p_scenario_id;
                  --bug3467631 start inventory_item_id => family id and request_item_id =>member id
                  --l_mat_atp_info_rec.request_item_id           := item_availability_info.sr_inventory_item_id(i);
                  --l_mat_atp_info_rec.inventory_item_id         := item_availability_info.family_sr_id(i);
                  l_mat_atp_info_rec.inventory_item_id         := item_availability_info.family_sr_id(i);
                  l_mat_atp_info_rec.request_item_id           := item_availability_info.sr_inventory_item_id(i);
                  --bug3467631 end
                  l_mat_atp_info_rec.organization_id           := p_atp_record.organization_id;
                  l_mat_atp_info_rec.requested_date            := l_requested_ship_date;
                  l_mat_atp_info_rec.quantity_ordered          := l_net_demand;
                  l_mat_atp_info_rec.demand_class              := item_availability_info.demand_class(i);
                  l_mat_atp_info_rec.insert_flag               := l_insert_flag;
                  l_mat_atp_info_rec.rounding_control_flag     := l_get_mat_in_rec.rounding_control_flag;
                  l_mat_atp_info_rec.dest_inv_item_id          := l_get_mat_in_rec.dest_inv_item_id;
                  l_mat_atp_info_rec.infinite_time_fence_date  := l_get_mat_in_rec.infinite_time_fence_date;
                  l_mat_atp_info_rec.plan_name                 := l_get_mat_in_rec.plan_name;
                  l_mat_atp_info_rec.optimized_plan            := l_get_mat_in_rec.optimized_plan;
                  l_mat_atp_info_rec.substitution_window       := item_availability_info.substitution_window(i);
                  l_mat_atp_info_rec.refresh_number            := p_refresh_number;
                  l_mat_atp_info_rec.shipping_cal_code         := p_atp_record.shipping_cal_code; -- Bug 3371817
                  l_mat_atp_info_rec.atf_date                  := item_availability_info.atf_date(i);

                  MSC_ATP_REQ.Get_Material_Atp_Info(
                          l_mat_atp_info_rec,
                          l_atp_period,
                          l_atp_supply_demand,
                          l_return_status);

                  l_requested_date_quantity                    := l_mat_atp_info_rec.requested_date_quantity;
                  l_atf_date_qty                               := l_mat_atp_info_rec.atf_date_quantity;
                  l_atp_date_this_level                        := l_mat_atp_info_rec.atp_date_this_level;
                  l_atp_date_quantity_this_level               := l_mat_atp_info_rec.atp_date_quantity_this_level;
                  l_get_mat_out_rec.atp_rule_name              := l_mat_atp_info_rec.atp_rule_name;
                  l_get_mat_out_rec.infinite_time_fence_date   := l_mat_atp_info_rec.infinite_time_fence_date;
                  l_used_available_quantity                    := l_mat_atp_info_rec.atp_date_quantity_this_level; --bug3409973
                  -- time_phased_atp changes end

                  -- dsting: l_period_begin_idx := l_all_atp_supply_demand.level.COUNT;
                  l_period_begin_idx := l_all_atp_period.level.COUNT;
                  l_sd_begin_idx := l_all_atp_supply_demand.level.count;

                  IF l_period_begin_idx = 0 THEN
                     l_period_begin_idx := 1;
                  ELSE
                     l_period_begin_idx := l_period_begin_idx + 1;
                  END IF;

                  IF l_sd_begin_idx = 0 THEN

                     l_sd_begin_idx := 1;
                  ELSE
                     l_sd_begin_idx := l_sd_begin_idx + 1;
                  END IF;

                  ---- get pegging id for demand
                  SELECT msc_full_pegging_s.nextval
                  INTO   l_pegging_id
                  FROM   dual;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Update with pegging info');
                  END IF;
                  item_availability_info.future_supply_peg_id(i) := l_pegging_id;
                  FOR j in 1..l_atp_period.Level.COUNT LOOP
                     l_atp_period.Pegging_Id(j) := l_pegging_id;
                     l_atp_period.End_Pegging_Id(j) := item_availability_info.end_pegging_id(i);
                  END LOOP;

                  FOR j in 1..l_atp_supply_demand.Level.COUNT LOOP
                     l_atp_supply_demand.Pegging_Id(j) := l_pegging_id;
                     l_atp_supply_demand.End_Pegging_Id(j) := item_availability_info.end_pegging_id(i);
                  END LOOP;


                  --- now add period and supply details
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add Supply demand details for the item');
                  END IF;
                  MSC_ATP_PROC.Details_Output(l_atp_period,
                                              l_atp_supply_demand,
                                              l_all_atp_period,
                                              l_all_atp_supply_demand,
                                               l_return_status);

                  l_period_end_idx := l_all_atp_period.level.count;
                  l_sd_end_idx := l_all_atp_supply_demand.level.count;

                  item_availability_info.fut_atp_prd_detl_begin_idx(i) := l_period_begin_idx;
                  item_availability_info.fut_atp_prd_detl_end_idx(i) := l_period_end_idx;
                  item_availability_info.fut_atp_sd_detl_begin_idx(i) := l_sd_begin_idx;
                  item_availability_info.fut_atp_sd_detl_end_idx(i) := l_sd_end_idx;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_used_available_quantity := ' || l_used_available_quantity); --bug3467631
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_date_this_level := ' || l_atp_date_this_level);
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atp_date_quantity_this_level := ' || l_atp_date_quantity_this_level);
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_atf_date_qty := ' || l_atf_date_qty); --bug3467631
                  END IF;
               END IF;  --- IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
               --bug3467631 start
               --added to set atf_date_quantity for item
               IF l_mat_atp_info_rec.requested_date > l_mat_atp_info_rec.atf_date THEN
                         item_availability_info.atf_date_quantity(i) :=
                                 GREATEST(NVL(item_availability_info.atf_date_quantity(i), 0), 0) +
                                 GREATEST(NVL(l_atf_date_qty, 0), 0);
               ELSE
                         item_availability_info.atf_date_quantity(i) :=
                                 GREATEST(NVL(item_availability_info.request_date_quantity(i), 0), 0) +
                                 GREATEST(NVL(l_atf_date_qty, 0), 0);
               END IF;
               --bug3467631 end
               item_availability_info.future_atp_date(i) :=l_atp_date_this_level;
               item_availability_info.atp_date_quantity(i) :=
                                     l_atp_date_quantity_this_level -
                                        GREATEST(l_requested_date_quantity, 0);
               -- time_phased_atp
               item_availability_info.used_available_quantity(i) :=
                                     LEAST(GREATEST(l_used_available_quantity, 0) +
                                           GREATEST(item_availability_info.request_date_quantity(i),0),
                                           MSC_ATP_PVT.INFINITE_NUMBER);--bug3467631
               IF PG_DEBUG in ('Y', 'C') THEN --bug3467631
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item_availability_info.atf_date_quantity(i) := ' ||
                                           item_availability_info.atf_date_quantity(i)); --bug3467631
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item_availability_info.used_available_quantity(i) := ' ||
                                           item_availability_info.used_available_quantity(i));
               END IF;
               IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1 AND  i = l_item_count) THEN
                    IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'we have met the demand, we just check for avail of req item');
                    END IF;
                    EXIT;
               END IF;
            ELSE
               l_atp_date_quantity_this_level := 0;
               l_atp_date_this_level := null;
               l_requested_date_quantity := 0;
               l_atf_date_qty := 0; -- time_phased_atp
            END IF;

         END LOOP;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Now do Forward CTP');
         END IF;
         IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1
                        and l_net_demand_after_oh_check > 0)  THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('ATP_Check_Subst: ' || ' Demand was met by a CTP on sub. reset the l_item_ctp_info table');
             END IF;
             l_item_ctp_info := l_null_item_avail_info;
             IF (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG <> G_HIGHEST_REV_ITEM) or
                (MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM and
                   l_highest_rev_item_id = item_availability_info.inventory_item_id(l_item_count)) THEN

                MSC_ATP_SUBST.Copy_Item_Info_Rec(item_availability_info, l_item_ctp_info, l_item_count);
             END IF;
         END IF;
         FOR i in reverse 1..l_item_ctp_info.inventory_item_id.count LOOP

            l_net_demand := p_atp_record.quantity_ordered - l_item_ctp_info.request_date_quantity(i);
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_ctp_info.request_date_quantity(i) := ' || l_item_ctp_info.request_date_quantity(i));
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_net_demand forward case := ' || l_net_demand);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Future atp date :=' || item_availability_info.future_atp_date(i));
            END IF;
            IF l_item_ctp_info.atp_comp_flag(i) in ('Y', 'C', 'R') and l_item_ctp_info.create_supply_flag(i) = 1 THEN
                IF l_item_count = 1 THEN
                   l_item_idx := 1;
                ELSE
                   IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
                      l_item_idx := l_item_count;

                   ELSIF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_DEMANDED_ITEM THEN

                      l_item_idx := l_item_count;
                   ELSIF MSC_ATP_SUBST.G_CREATE_SUPPLY_FLAG = G_HIGHEST_REV_ITEM THEN

                      l_item_idx := l_highest_rev_item_index;
                   ELSE

                      IF l_item_ctp_info.inventory_item_id.count = 1 THEN
                         --- this case will be true only if we have already satisfied the demand
                         --- using a substitute
                         l_item_idx := l_item_count;
                      ELSE
                         l_item_idx := i;
                      END IF;
                   END IF;
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_idx := ' || l_item_idx);
                END IF;
                l_atp_rec.error_code := 0;
                l_atp_rec.available_quantity := NULL;
                l_atp_rec.requested_date_quantity := NULL;

                -- no need to do uom conversion
                l_atp_rec.instance_id := p_atp_record.instance_id;
                -- what do we need to do with thie ???
                l_atp_rec.demand_source_line := null;
                l_atp_rec.identifier := MSC_ATP_PVT.G_ORDER_LINE_ID;
                --- what do we do with this??
                l_atp_rec.component_identifier := null; -- l_comp_requirements.component_identifier(j);

                -- time_phased_atp
                l_atp_rec.inventory_item_id := l_item_ctp_info.family_sr_id(i);

                l_atp_rec.request_item_id := l_item_ctp_info.sr_inventory_item_id(i);
                l_atp_rec.organization_id := p_atp_record.organization_id;
                l_atp_rec.quantity_ordered := l_net_demand;
                --bug3467631 setting atf_date
                l_atp_rec.Atf_Date := l_item_ctp_info.Atf_Date(i); --bug3467631
                -- l_atp_rec.quantity_uom := l_quantity_uom;
                l_atp_rec.requested_ship_date := l_requested_ship_date;
                l_atp_rec.demand_class := l_item_ctp_info.demand_class(i);
                l_atp_rec.insert_flag := l_insert_flag;
                l_atp_rec.refresh_number := p_refresh_number;
                l_atp_rec.refresh_number := null;
	        l_atp_rec.ship_date := null;


                l_plan_id :=  l_item_ctp_info.plan_id(i);
                l_assign_set_id := l_item_ctp_info.assign_set_id(i);

                l_item_attribute_rec.atp_flag := l_item_ctp_info.atp_flag(i);
                l_item_attribute_rec.atp_comp_flag := l_item_ctp_info.atp_comp_flag(i);
                l_item_attribute_rec.pre_pro_lt := l_item_ctp_info.pre_pro_lt(i);
                l_item_attribute_rec.post_pro_lt := l_item_ctp_info.post_pro_lt(i);
                l_item_attribute_rec.fixed_lt := l_item_ctp_info.fixed_lt(i);
                l_item_attribute_rec.variable_lt := l_item_ctp_info.variable_lt(i);
                l_item_attribute_rec.substitution_window := l_item_ctp_info.substitution_window(i);
                l_item_attribute_rec.create_supply_flag := l_item_ctp_info.create_supply_flag(i);

                --diag_atp: pass the plan name so that if PO are created then plan_name is used for pegging
                l_atp_rec.plan_name := l_item_ctp_info.plan_name(i);

                MSC_ATP_PVT.G_DEMAND_PEGGING_ID :=  l_item_ctp_info.end_pegging_id(i);
                l_atp_rec.top_tier_org_flag := 1;
                l_atp_rec.original_item_flag := 1;
                -- bug3467631 done for ship_rec_cal
                l_atp_rec.shipping_cal_code       := p_atp_record.shipping_cal_code;
                l_atp_rec.receiving_cal_code      := p_atp_record.receiving_cal_code;
                l_atp_rec.intransit_cal_code      := p_atp_record.intransit_cal_code;
                l_atp_rec.manufacturing_cal_code  := p_atp_record.manufacturing_cal_code;
                MSC_ATP_PVT.ATP_Check(l_atp_rec,
                                     l_plan_id,
                                     p_level ,
                                     p_scenario_id,
                                     2,  -- forward schedulling
                                     p_refresh_number,
                                     l_item_ctp_info.end_pegging_id(i),
                                     l_assign_set_id,
                                     l_atp_period,
                                     l_atp_supply_demand,
                                     x_return_status);

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Date from multi level CTP := ' || l_atp_rec.ship_date);
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Date from SRs on this level :='
                                       || item_availability_info.future_atp_date(l_item_idx));
                END IF;

                IF l_atp_rec.ship_date < item_availability_info.future_atp_date(l_item_idx) THEN
                   -- going down is better
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Going down is better. so we add the supply demand dets');
                   END IF;
                   --- add l_atp_period and l_atp_supply_demand
                   -- dsting: l_period_begin_idx := l_all_atp_supply_demand.level.COUNT;
                   l_period_begin_idx := l_all_atp_period.level.COUNT;
                   l_sd_begin_idx := l_all_atp_supply_demand.level.count;

                   IF l_period_begin_idx = 0 THEN
                      l_period_begin_idx := 1;
                   ELSE
                      l_period_begin_idx := l_period_begin_idx + 1;
                   END IF;

                   IF l_sd_begin_idx = 0 THEN

                      l_sd_begin_idx := 1;
                   ELSE
                      l_sd_begin_idx := l_sd_begin_idx + 1;
                   END IF;

                   --- now add period and supply details
                   MSC_ATP_PROC.Details_Output(l_atp_period,
                                               l_atp_supply_demand,
                                               l_all_atp_period,
                                               l_all_atp_supply_demand,
                                               l_return_status);
                   l_period_end_idx := l_all_atp_period.level.count;
                   l_sd_end_idx := l_all_atp_supply_demand.level.count;

                   item_availability_info.fut_ctp_prd_detl_begin_idx(l_item_idx) := l_period_begin_idx;
                   item_availability_info.fut_ctp_prd_detl_end_idx(l_item_idx) := l_period_end_idx;
                   item_availability_info.fut_ctp_sd_detl_begin_idx(l_item_idx) := l_sd_begin_idx;
                   item_availability_info.fut_ctp_sd_detl_end_idx(l_item_idx) := l_sd_end_idx;

                   item_availability_info.future_atp_date(l_item_idx) := l_atp_rec.ship_date;
                   item_availability_info.atp_date_quantity(l_item_idx) :=
                                                          l_atp_rec.available_quantity;
                   ---- remove forward stealing pegging
                   IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) THEN

                      --- recreate forward pegging array
                      l_atp_pegging_tab.delete;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'idemand priority alloc ATP, count := '|| l_atp_pegging_tab.count);
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'begin_Idx := ' ||item_availability_info.fwd_steal_peg_begin_idx(l_item_idx));
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'end_idx := ' || item_availability_info.fwd_steal_peg_end_idx(l_item_idx));
                      END IF;
                      FOR j in item_availability_info.fwd_steal_peg_begin_idx(l_item_idx)..item_availability_info.fwd_steal_peg_end_idx(l_item_idx) LOOP
                         l_atp_pegging_tab.extend;
                         l_atp_pegging_tab(l_atp_pegging_tab.count) := l_fwd_atp_pegging_tab(j);
                      END LOOP;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'count after recreating := ' || l_atp_pegging_tab.count);
                      END IF;

                      MSC_ATP_DB_UTILS.Remove_Invalid_Future_SD(l_atp_pegging_tab);
                   END IF;
                ELSE

                   --- going down is worse than date on this level.
                   --- we remove pegging and supply demands
                   IF PG_DEBUG in ('Y', 'C') THEN
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Staying on this level is OK. We remove pegging for current level');
                      msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'G_FUTURE_PEGGING_ID := ' ||  MSC_ATP_PVT.G_FUTURE_PEGGING_ID);
                   END IF;
                   MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                          MSC_ATP_PVT.G_FUTURE_PEGGING_ID,
                                          null,
                                          l_plan_id,
                                          MSC_ATP_PVT.UNDO,
                                          null,
                                          l_return_status);


                END IF;


            END IF;


         END LOOP;
         --- now we should know dates for all the items
         --- we can now compare the dates and give the best results back
         IF PG_DEBUG in ('Y', 'C') THEN
            For i in reverse 1..item_availability_info.inventory_item_id.count LOOP
               msc_sch_wb.atp_debug('Item :'||i || item_availability_info.sr_inventory_item_id(i) ||
                                    ', Avail Date : ' || item_availability_info.future_atp_date(i) ||
                                    ',  : used_available_quantity ' || item_availability_info.used_available_quantity(i)||
                                    ',  : Atf_Date_Quantity ' || item_availability_info.Atf_Date_Quantity(i) ||
                                    ',  : Atf_Date ' || item_availability_info.Atf_Date(i));

            END LOOP;
         END IF;

         IF (l_org_item_detail_flag = 1 AND l_satisfied_by_subst_flag = 1) THEN
             -- demand has already beed satisfied by a substitute
             --- so we just add data for original item
             MSC_ATP_PVT.G_DEMAND_PEGGING_ID := l_demand_pegging_id;
             p_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
             p_atp_record.req_item_req_date_qty := item_availability_info.request_date_quantity(l_item_count);

             --p_atp_record.req_item_available_date := item_availability_info.future_atp_date(l_item_count);
             IF NVL(p_atp_record.atp_lead_time, 0) > 0 THEN
                 /* ship_rec_cal
                 p_atp_record.req_item_available_date := MSC_CALENDAR.DATE_OFFSET
                                 (p_atp_record.organization_id,
                                  p_atp_record.instance_id,
                                  1,
                                  item_availability_info.future_atp_date(l_item_count),
                                  p_atp_record.atp_lead_time);*/

                 p_atp_record.req_item_available_date := MSC_CALENDAR.DATE_OFFSET(
                                  p_atp_record.manufacturing_cal_code,
                                  p_atp_record.instance_id,
                                  item_availability_info.future_atp_date(l_item_count),
                                  p_atp_record.atp_lead_time, 1);
             ELSE
                p_atp_record.req_item_available_date := item_availability_info.future_atp_date(l_item_count);
             END IF;

             p_atp_record.req_item_available_date_qty := item_availability_info.atp_date_quantity(l_item_count);
             --bug3709707  no need to assign name
             -- time_phased_atp
             --p_atp_record.request_item_name := item_availability_info.item_name(l_item_count); --bug3467631
             --p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);

             ---- remove forward stealing pegging
             IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) AND
                item_availability_info.atp_flag(l_item_count) in ('Y', 'C') THEN

                --- recreate forward pegging array
                l_atp_pegging_tab.delete;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'idemand priority alloc ATP, count := '|| l_atp_pegging_tab.count);
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'begin_Idx := ' ||item_availability_info.fwd_steal_peg_begin_idx(l_item_count));
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'end_idx := ' || item_availability_info.fwd_steal_peg_end_idx(l_item_count));
                END IF;
                FOR j in item_availability_info.fwd_steal_peg_begin_idx(l_item_count)..item_availability_info.fwd_steal_peg_end_idx(l_item_count) LOOP
                   l_atp_pegging_tab.extend;
                   l_atp_pegging_tab(l_atp_pegging_tab.count) := l_fwd_atp_pegging_tab(j);
                END LOOP;
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'count after recreating := ' || l_atp_pegging_tab.count);
                END IF;

                MSC_ATP_DB_UTILS.Remove_Invalid_Future_SD(l_atp_pegging_tab);
             END IF;

             --- remove pegging and supply demand details for original item
             MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                         item_availability_info.End_pegging_id(l_item_count),
                                          null,
                                          item_availability_info.plan_id(l_item_count),
                                          MSC_ATP_PVT.UNDO,
                                          null,
                                          l_return_status);

         ELSE
            --- demand has not been satisfied by any item
            --- so we try to find best date
            -- We start assuming that original item had the best date
            l_atp_date := item_availability_info.future_atp_date(l_item_count);
            l_item_idx := l_item_count;
            FOR i in reverse 1..item_availability_info.inventory_item_id.count LOOP
                If item_availability_info.future_atp_date(i) < l_atp_date THEN
                   -- we have found better date than the requested item
                   l_item_idx := i;
                   l_atp_date := item_availability_info.future_atp_date(i);
                END IF;
            END LOOP;
            --- now we have found best case scenrio
            --- so we populate the info
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_idx := ' || l_item_idx);
            END IF;

            -- time_phased_atp
            --p_atp_record.inventory_item_id := item_availability_info.sr_inventory_item_id(l_item_idx);
            --bug3467631 Old PF family shown and time_phased member shown
            p_atp_record.inventory_item_id := item_availability_info.family_sr_id(l_item_idx);
            p_atp_record.inventory_item_name := item_availability_info.family_item_name(l_item_idx);
            --bug3709707 commenting as assigned below
            --p_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_idx);
            p_atp_record.requested_date_quantity := item_availability_info.request_date_quantity(l_item_idx);
            p_atp_record.used_available_quantity := item_availability_info.used_available_quantity(l_item_idx); --bug3467631
            p_atp_record.Atf_Date_Quantity := item_availability_info.Atf_Date_Quantity(l_item_idx); --bug3467631

            IF NVL(p_atp_record.atp_lead_time, 0) > 0 THEN
               /* ship_rec_cal
               p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET
                           (p_atp_record.organization_id,
                            p_atp_record.instance_id,
                            1,
                            item_availability_info.future_atp_date(l_item_idx),
                            p_atp_record.atp_lead_time);*/

               p_atp_record.ship_date := MSC_CALENDAR.DATE_OFFSET(
                            p_atp_record.manufacturing_cal_code,
                            p_atp_record.instance_id,
                            item_availability_info.future_atp_date(l_item_idx),
                            p_atp_record.atp_lead_time, 1);
            ELSE
               p_atp_record.ship_date := item_availability_info.future_atp_date(l_item_idx);
            END IF;
            p_atp_record.ship_date := item_availability_info.future_atp_date(l_item_idx);
            p_atp_record.available_quantity := item_availability_info.atp_date_quantity(l_item_idx);
            --p_atp_record.inventory_item_name := item_availability_info.item_name(l_item_idx); --bug3467631 set above
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'p_atp_record.inventory_item_id := '|| p_atp_record.inventory_item_id);
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'end_pegging_id := ' || item_availability_info.end_pegging_id(l_item_idx));
            END IF;
            MSC_ATP_PVT.G_DEMAND_PEGGING_ID := item_availability_info.end_pegging_id(l_item_idx);

            --- now populate the info for original item
            -- time_phased_atp
            --bug3709707 atf_date also populated so that correct atf date is returned to schedule
            p_atp_record.atf_date := item_availability_info.atf_date(l_item_idx);
            p_atp_record.request_item_id := item_availability_info.sr_inventory_item_id(l_item_idx); --bug3467631
            p_atp_record.request_item_name := item_availability_info.item_name(l_item_idx); --bug3467631
            p_atp_record.original_item_id := item_availability_info.sr_inventory_item_id(l_item_count);
            p_atp_record.original_item_name := item_availability_info.item_name(l_item_count);

            p_atp_record.req_item_req_date_qty :=  item_availability_info.request_date_quantity(l_item_count);
            p_atp_record.req_item_available_date := item_availability_info.future_atp_date(l_item_count);
            p_atp_record.req_item_available_date_qty := item_availability_info.atp_date_quantity(l_item_count);

            --- now we add supply demand and period details
            --- first we add details for backward search
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add details for  pegging for backward search');
            END IF;
            MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                        l_all_atp_supply_demand,
                                        item_availability_info.period_detail_begin_idx(l_item_idx),
                                        item_availability_info.period_detail_end_idx(l_item_idx),
                                        item_availability_info.sd_detail_begin_idx(l_item_idx),
                                        item_availability_info.sd_detail_end_idx(l_item_idx),
                                        x_atp_period,
                                        x_atp_supply_demand,
                                        l_return_status);
            --- now add details for  backward CTP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add details for backward CTP');
            END IF;
            IF item_availability_info.ctp_prd_detl_begin_idx(l_item_idx) is not null and
               item_availability_info.ctp_sd_detl_begin_idx(l_item_idx) is not null THEN
               MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                            l_all_atp_supply_demand,
                                            item_availability_info.ctp_prd_detl_begin_idx(l_item_idx),
                                            item_availability_info.ctp_prd_detl_end_idx(l_item_idx),
                                            item_availability_info.ctp_sd_detl_begin_idx(l_item_idx),
                                            item_availability_info.ctp_sd_detl_end_idx(l_item_idx),
                                            x_atp_period,
                                            x_atp_supply_demand,
                                            l_return_status);
            END IF;
            --- now add future atp details
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'add details for forward search');
            END IF;
            IF NVL(item_availability_info.fut_ctp_prd_detl_begin_idx(l_item_idx), 0 ) > 0 THEN
               --- going down is better
               --- ad future period and supply demand details
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add s/d details for forward CTP');
               END IF;
               MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                         l_all_atp_supply_demand,
                                         item_availability_info.fut_ctp_prd_detl_begin_idx(l_item_idx),
                                         item_availability_info.fut_ctp_prd_detl_end_idx(l_item_idx),
                                         item_availability_info.fut_ctp_sd_detl_begin_idx(l_item_idx),
                                         item_availability_info.fut_ctp_sd_detl_end_idx(l_item_idx),
                                         x_atp_period,
                                         x_atp_supply_demand,
                                         l_return_status);

            ELSE

               --- future scheduled receipt is better than going down
               --- first we add pegging for this supply
               IF item_availability_info.atp_flag(l_item_idx) = 'N'
                             and item_availability_info.atp_flag(l_item_idx) = 'N' THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'item is non-atpable, dont do pegging');
                     END IF;
               ELSE
                  ---forward steal: demand has already been created, we dont want to create it again
                  IF NOT((MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                        (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                        (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Add pegging and s/d details for SRS');
                     END IF;

                     l_pegging_rec.session_id:= MSC_ATP_PVT.G_SESSION_ID;
                     l_pegging_rec.order_line_id:= MSC_ATP_PVT.G_ORDER_LINE_ID;
                     l_pegging_rec.parent_pegging_id:= item_availability_info.end_pegging_id(l_item_idx);
                     l_pegging_rec.pegging_id := item_availability_info.future_supply_peg_id(l_item_idx);
                     l_pegging_rec.end_pegging_id := item_availability_info.end_pegging_id(l_item_idx);
                     l_pegging_rec.atp_level:= p_level + 1;
                     l_pegging_rec.organization_id:= p_atp_record.organization_id;
                     l_pegging_rec.organization_code := l_top_tier_org_code;
                     l_pegging_rec.identifier1:= p_atp_record.instance_id;
                     l_pegging_rec.identifier2 := item_availability_info.plan_id(l_item_idx);
                     l_pegging_rec.identifier3 := NULL;

                     --bug3467631 time_phased_atp changes begin
                     IF (item_availability_info.sr_inventory_item_id(l_item_idx) <>
                                item_availability_info.family_sr_id(l_item_idx))
                        and ((item_availability_info.future_atp_date(l_item_idx) >
                                  item_availability_info.atf_date(l_item_idx)) OR
                                  item_availability_info.atf_date(l_item_idx) is null)
                     THEN
                             l_pegging_rec.inventory_item_id:= item_availability_info.family_sr_id(l_item_idx);
                             l_pegging_rec.inventory_item_name := item_availability_info.family_item_name(l_item_idx);
                     ELSE
                             l_pegging_rec.inventory_item_id:= item_availability_info.sr_inventory_item_id(l_item_idx);
                             l_pegging_rec.inventory_item_name := item_availability_info.item_name(l_item_idx);
                     END IF;
                     -- time_phased_atp changes end
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('family_sr_id: ' || item_availability_info.family_sr_id(l_item_idx));
                        msc_sch_wb.atp_debug('family_item_name: ' || item_availability_info.family_item_name(l_item_idx));
                        msc_sch_wb.atp_debug('sr_inventory_item_id: ' || item_availability_info.sr_inventory_item_id(l_item_idx));
                        msc_sch_wb.atp_debug('item_name: ' || item_availability_info.item_name(l_item_idx));
                     END IF;

                     l_pegging_rec.aggregate_time_fence_date := item_availability_info.Atf_Date(l_item_idx); --bug3467631
                     l_pegging_rec.resource_id := NULL;
                     l_pegging_rec.resource_code := NULL;
                     l_pegging_rec.department_id := NULL;
                     l_pegging_rec.department_code := NULL;
                     l_pegging_rec.supplier_id := NULL;
                     l_pegging_rec.supplier_name := NULL;
                     l_pegging_rec.supplier_site_id := NULL;
                     l_pegging_rec.supplier_site_name := NULL;
                     l_pegging_rec.scenario_id:= p_scenario_id;
                     l_pegging_rec.supply_demand_source_type:= MSC_ATP_PVT.ATP;
                     l_pegging_rec.supply_demand_quantity:= item_availability_info.atp_date_quantity(l_item_idx);
                     l_pegging_rec.supply_demand_date:= item_availability_info.future_atp_date(l_item_idx);
                     l_pegging_rec.supply_demand_type:= 2;
                     l_pegging_rec.source_type := 0;
	             l_pegging_rec.component_identifier :=
                          NVL(p_atp_record.component_identifier, MSC_ATP_PVT.G_COMP_LINE_ID);

                     l_pegging_rec.constraint_flag := 'N';


                     l_pegging_rec.summary_flag := MSC_ATP_PVT.G_SUMMARY_FLAG;
                     l_pegging_rec.request_item_id := p_atp_record.request_item_id;

                     MSC_ATP_SUBST.add_pegging(l_pegging_rec);
                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_future_supply_pegging_id :=' || l_pegging_id);
                     END IF;
                     MSC_ATP_SUBST.Details_Output(l_all_atp_period,
                                                l_all_atp_supply_demand,
                                                item_availability_info.fut_atp_prd_detl_begin_idx(l_item_idx),
                                                item_availability_info.fut_atp_prd_detl_end_idx(l_item_idx),
                                                item_availability_info.fut_atp_sd_detl_begin_idx(l_item_idx),
                                                item_availability_info.fut_atp_sd_detl_end_idx(l_item_idx),
                                                x_atp_period,
                                                x_atp_supply_demand,
                                                l_return_status);
                  END IF;
               END IF; -- IF NOT((MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
            END IF;
           --- now delete pegging and supply demand info
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_Sch_wb.atp_debug('ATP_Check_Subst: ' || 'Remove pegging and supply demand details for all items');
           END IF;
           --- now delete pegging and supply demand info
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_Sch_wb.atp_debug('ATP_Check_Subst: ' || 'Remove pegging and supply demand details for all items');
           END IF;

           For j in 1..item_availability_info.inventory_item_id.count LOOP
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'In loop for removing supply demand of all items');
                 msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_item_idx :- ' || l_item_idx);
              END IF;
              IF (item_availability_info.inventory_item_id(j)
                             <> item_availability_info.inventory_item_id(l_item_idx)) THEN


                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'Remove Pegging for item := '
                                        || item_availability_info.inventory_item_id(j));
                  END IF;
                   ---- remove forward stealing pegging
                   IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
                      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
                      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1) AND
                      (item_availability_info.atp_flag(j) in ('Y', 'C')) THEN

                      --- recreate forward pegging array
                      l_atp_pegging_tab.delete;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'idemand priority alloc ATP, count := '|| l_atp_pegging_tab.count);
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'begin_Idx := ' ||item_availability_info.fwd_steal_peg_begin_idx(j));
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'end_idx := ' || item_availability_info.fwd_steal_peg_end_idx(j));
                      END IF;
                      FOR l_item_cntr in item_availability_info.fwd_steal_peg_begin_idx(j)..item_availability_info.fwd_steal_peg_end_idx(j) LOOP
                         l_atp_pegging_tab.extend;
                         l_atp_pegging_tab(l_atp_pegging_tab.count) := l_fwd_atp_pegging_tab(l_item_cntr);
                      END LOOP;
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'count after recreating := ' || l_atp_pegging_tab.count);
                      END IF;

                      MSC_ATP_DB_UTILS.Remove_Invalid_Future_SD(l_atp_pegging_tab);
                   END IF;

                   MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(
                                  item_availability_info.End_pegging_id(j),
                                   null,
                                   item_availability_info.plan_id(j),
                                   MSC_ATP_PVT.UNDO,
                                   null,
                                   l_return_status);

              END IF;  -- IF item_availability_info.inventory_item_id(j) <> l_item_ctp_info.inventory
           END LOOP; -- For j in 1..item_availability_info.inventory_item_id.count LOOP

         END IF;
         --- now set the error code
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_org_item_detail_flag := ' || l_org_item_detail_flag);
            msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'l_satisfied_by_subst_flag := '|| l_satisfied_by_subst_flag);
         END IF;
         IF ((NVL(l_org_item_detail_flag, -1) <>1 OR NVL(l_satisfied_by_subst_flag,-1) <> 1)) THEN

            IF item_availability_info.atp_flag(l_item_idx) = 'N'
                          and item_availability_info.atp_comp_flag(l_item_idx) = 'N' THEN
               p_atp_record.error_code := MSC_ATP_PVT.ATP_NOT_APPL;
               --- if item we used to satify the demand is non-atpable then we want to show thate error
               -- we will come here only if date is apps due
            ELSE
               IF PG_DEBUG in ('Y', 'C') THEN
                  msc_Sch_wb.atp_debug('ATP_Check_Subst: ' || 'Set error code');
               END IF;
               IF p_atp_record.ship_date is not NULL THEN
                  p_atp_record.error_code :=  MSC_ATP_PVT.ATP_REQ_DATE_FAIL;

               ELSE
                  p_atp_record.error_code := MSC_ATP_PVT.ATP_REQ_QTY_FAIL;
               END IF;
            END IF;
         END IF;

      END IF;
<<CLEANUP>>
     null;
   END IF ;  --- if l_substitution_type = ALL_OR_NOTHING THEN
EXCEPTION

WHEN MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL THEN --bug3583705
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('MAtching cal date not found, in atp_check_subs');
        END IF;
        p_atp_record.error_code := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
        RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;

WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	-- dsting set error_code
	--bug3583705 start
	--p_atp_record.error_code := MSC_ATP_PVT.ATP_PROCESSING_ERROR;
	/* Check if this is actually coming from a calendar routine*/
        l_encoded_text := fnd_message.GET_ENCODED;
        IF l_encoded_text IS NULL THEN
                l_msg_app := NULL;
                l_msg_name := NULL;
        ELSE
                fnd_message.parse_encoded(l_encoded_text, l_msg_app, l_msg_name);
        END IF;

        -- Error Handling Changes
        IF (p_atp_record.error_code IS NULL) or (p_atp_record.error_code IN (0,61,150)) THEN
                IF l_msg_app='MRP' AND l_msg_name='GEN-DATE OUT OF BOUNDS' THEN
                        p_atp_record.error_code := MSC_ATP_PVT.NO_MATCHING_CAL_DATE;
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_CHECK_SUBS: NO_MATCHING_CAL_DATE');
                        END IF;
                ELSE
                        p_atp_record.error_code := MSC_ATP_PVT.ATP_PROCESSING_ERROR; -- ATP Processing Error
                        IF PG_DEBUG in ('Y', 'C') THEN
                           msc_sch_wb.atp_debug('ATP_CHECK_SUBS: ATP_PROCESSING_ERROR');
                        END IF;
                END IF;
        END IF;
        --bug3583705 end
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'ATP_CHECK_SUBST');
        END IF;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'error := ' || sqlerrm);
        END IF;

        FOR i in 1..item_availability_info.inventory_item_id.count LOOP
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('ATP_Check_Subst: ' || 'delete demand for item ' || item_availability_info.item_name(i)
                                          || ' ' || item_availability_info.sr_inventory_item_id(i));
           END IF;

           MSC_ATP_DB_UTILS.Remove_Invalid_SD_Rec(item_availability_info.end_pegging_id(i),
                                                   null,
                                                   item_availability_info.plan_id(i),
                                                   MSC_ATP_PVT.UNDO,
                                                   null,
                                                   l_return_status);

        END LOOP;

        IF l_msg_app='MRP' AND l_msg_name='GEN-DATE OUT OF BOUNDS' THEN --bug3583705
                RAISE MSC_ATP_PVT.NO_MATCHING_DATE_IN_CAL;
        ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
END ATP_Check_Subst;

Procedure Get_Item_Substitutes(p_inventory_item_id IN       NUMBER,
                               p_item_table        IN OUT   NoCopy MSC_ATP_SUBST.Item_Info_Rec_Typ,
                               p_instance_id       IN       NUMBER,
                               p_plan_id           IN       NUMBER,
                               p_customer_id       IN       NUMBER,
                               p_customer_site_id  IN       NUMBER,
                               p_request_date      IN       DATE,
                               p_organization_id   IN       NUMBER)
IS
l_item_table         MSC_ATP_SUBST.Item_Info_Rec_Typ;
l_effective_dates    MRP_ATP_PUB.date_arr;
l_disable_dates      MRP_ATP_PUB.date_arr;
i                    number;
l_count              number;
L_RETURN_STATUS      varchar2(1);
l_customer_id        number;
l_customer_site_id   number;
l_request_date       date;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('**** Begin Get_Item_Substitutes ****');
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_inventory_item_id = ' || p_inventory_item_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_instance_id := ' || p_instance_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_plan_id := ' || p_plan_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_customer_id := ' || p_customer_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_customer_site_id := ' || p_customer_site_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_request_date := ' || p_request_date);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_item_table.count := ' || p_item_table.inventory_item_id.count);
   END IF;

   l_request_date := trunc(p_request_date);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'G_HIERARCHY_PROFILE = '||MSC_ATP_PVT.G_HIERARCHY_PROFILE);
   END IF;
   IF (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 2) THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Customer class alloc atp. Set the local varibale from global var');
     END IF;
     l_customer_id := MSC_ATP_PVT.G_PARTNER_ID;
     l_customer_site_id := MSC_ATP_PVT.G_PARTNER_SITE_ID;
   ELSIF p_customer_id is not null and p_customer_site_id is not null THEN

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Convert customer/site id');
     END IF;
     BEGIN
       SELECT TP_ID
       INTO   l_customer_id
       FROM   msc_tp_id_lid tp
       WHERE  tp.SR_TP_ID = p_customer_id
       AND    tp.SR_INSTANCE_ID = p_instance_id
       AND    tp.PARTNER_TYPE = 2;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
             l_customer_id := NULL;
     END ;

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'l_customer_id = '||l_customer_id);
     END IF;

     BEGIN
       SELECT TP_SITE_ID
       INTO   l_customer_site_id
       FROM   msc_tp_site_id_lid tpsite
       WHERE  tpsite.SR_TP_SITE_ID = p_customer_site_id
       AND    tpsite.SR_INSTANCE_ID =  p_instance_id
       AND    tpsite.PARTNER_TYPE = 2;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
             l_customer_site_id := null;
     END ;
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'l_customer_site_id := ' || l_customer_site_id);
     END IF;

   ELSE
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Customer/customer site is not give');
     END IF;
     l_customer_id := null;
     l_customer_site_id := null;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'l_customer_id := ' || l_customer_id);
      msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'l_customer_site_id := ' || l_customer_site_id);
   END IF;

   IF l_customer_id is NULL or l_customer_site_id is NULL THEN
      --- no customer defined, get generic rule
      SELECT mis.higher_item_id, mis.partial_fulfillment_flag,
             msi1.sr_inventory_item_id, msi1.item_name, mis.highest_item_id,
             -- time_phased_atp changes begin
             DECODE(msi2.bom_item_type,
                 5, DECODE(msi2.atp_flag,
                     'N', msi1.sr_inventory_item_id,
                     msi2.sr_inventory_item_id),
                 msi1.sr_inventory_item_id
             ),
             DECODE(msi2.bom_item_type,
                 5, DECODE(msi2.atp_flag,
                     'N', msi1.inventory_item_id,
                     msi2.inventory_item_id),
                 msi1.inventory_item_id
             ),
             DECODE(msi2.bom_item_type,
                 5, DECODE(msi2.atp_flag,
                     'N', msi1.item_name,
                     msi2.item_name),
                 msi1.item_name
             ),
             msi2.aggregate_time_fence_date,
             0
             -- time_phased_atp changes end
      BULK COLLECT INTO
             p_item_table.inventory_item_id, p_item_table.partial_fulfillment_flag,
             p_item_table.sr_inventory_item_id, p_item_table.item_name ,
             p_item_table.highest_revision_item_id,
             -- time_phased_atp changes begin
             p_item_table.family_sr_id,
             p_item_table.family_dest_id,
             p_item_table.family_item_name,
             p_item_table.atf_date,
             p_item_table.atf_date_quantity
             -- time_phased_atp changes end
      FROM  msc_item_substitutes mis,
            msc_system_items     msi1,
            msc_system_items     msi2
      WHERE mis.plan_id = p_plan_id
      AND   mis.sr_instance_id = p_instance_id
      AND   mis.lower_item_id = p_inventory_item_id
      AND   mis.effective_date <= l_request_date
      AND   NVL(mis.disable_date, l_request_date) >= l_request_date
      ---bug 2341179 : inferred_flag is used for UI purpose only
      --AND   mis.inferred_flag = 2
      AND   NVL(mis.customer_id, -1) = -1
      AND   NVL(mis.customer_site_id, -1) = -1
      AND   msi1.inventory_item_id = mis.higher_item_id
      AND   msi1.sr_instance_id = mis.sr_instance_id
      AND   msi1.plan_id = mis.plan_id
      AND   msi1.organization_id = p_organization_id
      -- time_phased_atp changes begin
      AND   msi2.inventory_item_id = DECODE(msi1.product_family_id,
                                                NULL, msi1.inventory_item_id,
                                                -23453, msi1.inventory_item_id,
                                           msi1.product_family_id)
      AND   msi2.organization_id = msi1.organization_id
      AND   msi2.sr_instance_id = msi1.sr_instance_id
      AND   msi2.plan_id = msi1.plan_id
      -- time_phased_atp changes end
      Order By mis.rank desc;


      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_item_table.count := ' || p_item_table.inventory_item_id.count);
      END IF;
   ELSE
      SELECT count(*)
      INTO   l_count
      FROM msc_item_substitutes mis
      WHERE mis.plan_id = p_plan_id
      AND   mis.sr_instance_id = p_instance_id
      ---bug 2341179 : inferred_flag is used for UI purpose only
      --AND   mis.inferred_flag = 2
      AND   mis.customer_id = l_customer_id
      AND   mis.customer_site_id = l_customer_site_id;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Number of customer specific rule := ' || l_count);
      END IF;

      IF l_count > 0 THEN
         ---- customer specific rule
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Get Customer specific rule');
         END IF;
         SELECT mis.higher_item_id, mis.partial_fulfillment_flag,
                msi1.sr_inventory_item_id, msi1.item_name, mis.highest_item_id,
                mis.effective_date, mis.disable_date,
                -- time_phased_atp changes begin
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.sr_inventory_item_id,
                        msi2.sr_inventory_item_id),
                    msi1.sr_inventory_item_id
                ),
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.inventory_item_id,
                        msi2.inventory_item_id),
                    msi1.inventory_item_id
                ),
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.item_name,
                        msi2.item_name),
                    msi1.item_name
                ),
                msi2.aggregate_time_fence_date,
                0
                -- time_phased_atp changes end
         BULK COLLECT INTO
                --bug 2462949: collect into p_atp_table instead of l_atp_table
                p_item_table.inventory_item_id, p_item_table.partial_fulfillment_flag,
                p_item_table.sr_inventory_item_id, p_item_table.item_name,
                p_item_table.highest_revision_item_id,
	        l_effective_dates, l_disable_dates,
                -- time_phased_atp changes begin
                p_item_table.family_sr_id,
                p_item_table.family_dest_id,
                p_item_table.family_item_name,
                p_item_table.atf_date,
                p_item_table.atf_date_quantity
                -- time_phased_atp changes end
         FROM msc_item_substitutes mis,
              msc_system_items     msi1,
              msc_system_items     msi2
         WHERE mis.plan_id = p_plan_id
         AND   mis.sr_instance_id = p_instance_id
         AND   mis.lower_item_id = p_inventory_item_id
         AND   mis.effective_date <= l_request_date
         AND   NVL(mis.disable_date, l_request_date) >= l_request_date
         ---bug 2341179 : inferred_flag is used for UI purpose only
         --AND   mis.inferred_flag = 2
         AND   mis.customer_id = l_customer_id
         AND   mis.customer_site_id = l_customer_site_id
         AND   msi1.inventory_item_id = mis.higher_item_id
         AND   msi1.sr_instance_id = mis.sr_instance_id
         AND   msi1.plan_id = mis.plan_id
         AND   msi1.organization_id = p_organization_id
         -- time_phased_atp changes begin
         AND   msi2.inventory_item_id = DECODE(msi1.product_family_id,
                                                NULL, msi1.inventory_item_id,
                                                -23453, msi1.inventory_item_id,
                                           msi1.product_family_id)
         AND   msi2.organization_id = msi1.organization_id
         AND   msi2.sr_instance_id = msi1.sr_instance_id
         AND   msi2.plan_id = msi1.plan_id
         -- time_phased_atp changes end
         Order By mis.effective_date, mis.rank desc;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'p_item_table.count := ' || p_item_table.inventory_item_id.count);
         END IF;

         FOR i in 1..p_item_table.inventory_item_id.count LOOP
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'counter: Inv_id : sr_inv_id : item_name : par_full_flg :: effective dt : disbale dt ');
              msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || i || ' : ' || p_item_table.inventory_item_id(i) || ' : '
                                  || p_item_table.sr_inventory_item_id(i) || ' : '
                                  || p_item_table.item_name(i) || ' : '
                                  || p_item_table.partial_fulfillment_flag(i)
                                  || l_effective_dates(i)
                                  || l_disable_dates(i));
              msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'counter: family_sr_id : family_dest_id : family_item_name : atf_date ');
              msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || i || ' : ' || p_item_table.family_sr_id(i) || ' : '
                                  || p_item_table.family_dest_id(i) || ' : '
                                  || p_item_table.family_item_name(i) || ' : '
                                  || p_item_table.atf_date(i));
           END IF;
         END LOOP;
      ELSE
         ---generic rule

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'Get Generic rule');
         END IF;
         --- get generic rule
         --- no customer defined, get generic rule
         SELECT mis.higher_item_id, mis.partial_fulfillment_flag,
                msi1.sr_inventory_item_id, msi1.item_name, mis.highest_item_id
 		-- dsting diagnostic ATP
		,msi1.rounding_control_type
		,msi1.unit_weight
		,msi1.unit_volume
		,msi1.weight_uom
		,msi1.volume_uom,
                -- time_phased_atp changes begin
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.sr_inventory_item_id,
                        msi2.sr_inventory_item_id),
                    msi1.sr_inventory_item_id
                ),
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.inventory_item_id,
                        msi2.inventory_item_id),
                    msi1.inventory_item_id
                ),
                DECODE(msi2.bom_item_type,
                    5, DECODE(msi2.atp_flag,
                        'N', msi1.item_name,
                        msi2.item_name),
                    msi1.item_name
                ),
                msi2.aggregate_time_fence_date,
                0
                -- time_phased_atp changes end

         BULK COLLECT INTO
                p_item_table.inventory_item_id, p_item_table.partial_fulfillment_flag,
                p_item_table.sr_inventory_item_id, p_item_table.item_name, p_item_table.highest_revision_item_id
                --p_item_table.inventory_item_id, l_item_name
 		-- dsting diagnostic ATP
		,p_item_table.rounding_control_type
		,p_item_table.unit_weight
		,p_item_table.unit_volume
		,p_item_table.weight_uom
		,p_item_table.volume_uom
                -- For time_phased_atp
                ,p_item_table.family_sr_id
                ,p_item_table.family_dest_id
                ,p_item_table.family_item_name
                ,p_item_table.atf_date
                ,p_item_table.atf_date_quantity
         FROM msc_item_substitutes mis,
              msc_system_items     msi1,
              msc_system_items     msi2
         WHERE mis.plan_id = p_plan_id
         AND   mis.sr_instance_id = p_instance_id
         AND   mis.lower_item_id = p_inventory_item_id
         AND   mis.effective_date <= l_request_date
         AND   NVL(mis.disable_date, l_request_date) >= l_request_date
         ----  bug 2341179 : : inferred_flag is used for UI purpose only
         --AND   mis.inferred_flag = 2
         AND   NVL(mis.customer_id, -1) = -1
         AND   NVL(mis.customer_site_id, -1) = -1
         AND   msi1.inventory_item_id = mis.higher_item_id
         AND   msi1.sr_instance_id = mis.sr_instance_id
         AND   msi1.plan_id = mis.plan_id
         AND   msi1.organization_id = p_organization_id
         -- time_phased_atp changes begin
         AND   msi2.inventory_item_id = DECODE(msi1.product_family_id,
                                                NULL, msi1.inventory_item_id,
                                                -23453, msi1.inventory_item_id,
                                           msi1.product_family_id)
         AND   msi2.organization_id = msi1.organization_id
         AND   msi2.sr_instance_id = msi1.sr_instance_id
         AND   msi2.plan_id = msi1.plan_id
         -- time_phased_atp changes end
         Order By mis.rank desc;
      END IF;


   END IF;

   FOR i in 1..p_item_table.inventory_item_id.count LOOP
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'counter: Inv_id : sr_inv_id : item_name : par_full_flg ');
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || i || ' : ' || p_item_table.inventory_item_id(i) || ' : ' || p_item_table.sr_inventory_item_id(i) || ' : ' ||
                           p_item_table.item_name(i) || ' : ' || p_item_table.partial_fulfillment_flag(i));
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || 'counter: family_sr_id : family_dest_id : family_item_name : atf_date ');
         msc_sch_wb.atp_debug('Get_Item_Substitutes: ' || i || ' : ' || p_item_table.family_sr_id(i) || ' : '
                             || p_item_table.family_dest_id(i) || ' : '
                             || p_item_table.family_item_name(i) || ' : '
                             || p_item_table.atf_date(i));
      END IF;
   END LOOP;


END GET_ITEM_SUBSTITUTES;

Procedure Update_demand(p_demand_id   number,
                        p_plan_id     number,
                        p_quantity    number)
IS
BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('BEGIN Update_demand ');
   msc_sch_wb.atp_debug('Update_demand: ' || 'p_demand_id := ' || p_demand_id);
   msc_sch_wb.atp_debug('Update_demand: ' || 'p_plan_id := ' || p_plan_id);
   msc_sch_wb.atp_debug('Update_demand: ' || 'p_quantity := ' || p_quantity);
END IF;

      update msc_demands
      set    using_requirement_quantity = p_quantity
      where  demand_id = p_demand_id
      and    plan_id   = p_plan_id;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Update_demand: ' || 'Number of Rows Updated := ' || SQL%ROWCOUNT);
      END IF;

      IF MSC_ATP_PVT.G_INV_CTP = 4 and MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y'
           AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 1 THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_demand: ' || 'Update preallocated demand');
         END IF;
         update msc_alloc_demands
         set allocated_quantity = p_quantity
         where parent_demand_id = p_demand_id
         and   plan_id = p_plan_id;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Update_demand: ' || 'Number of Rows Updated := ' || SQL%ROWCOUNT);
         END IF;
      END IF;


END Update_demand;


Procedure Delete_demand_subst(p_demand_id   number,
                        p_plan_id     number)
IS
BEGIN
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'BEGIN delete demand subst ');
   msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'p_demand_id := ' || p_demand_id);
   msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'p_plan_id := ' || p_plan_id);
END IF;


      --- DELETE DEMAND
      delete msc_demands
      where  demand_id = p_demand_id
      and    plan_id   = p_plan_id;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'Number of Rows deleted := ' || SQL%ROWCOUNT);
      END IF;

      IF MSC_ATP_PVT.G_INV_CTP = 4 and MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y'
           AND MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1 AND MSC_ATP_PVT.G_ALLOCATION_METHOD = 1 THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'Delete Allocated demand');
         END IF;
         delete msc_alloc_demands
         where parent_demand_id = p_demand_id
         and   plan_id = p_plan_id;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Delete_demand_subst: ' || 'Number of Rows deleted := ' || SQL%ROWCOUNT);
         END IF;

      END IF;


END Delete_demand_subst;

PROCEDURE ADD_PEGGING(
         p_pegging_rec          IN         mrp_atp_details_temp%ROWTYPE)
IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('ADD_PEGGING: ' || 'Add pegging for Peg id : ' || p_pegging_rec.pegging_id);
   msc_sch_wb.atp_debug('ADD_PEGGING: ' || 'intransit lead time: ' || p_pegging_rec.INTRANSIT_LEAD_TIME);
   msc_sch_wb.atp_debug('ADD_PEGGING: ' || 'aggregate_time_fence_date: ' || p_pegging_rec.aggregate_time_fence_date); --bug3467631
END IF;

  INSERT into mrp_atp_details_temp
                 (session_id,
                  order_line_id,
	          pegging_id,
                  parent_pegging_id,
                  atp_level,
                  record_type,
                  organization_id,
                  organization_code,
                  identifier1,
                  identifier2,
                  identifier3,
		  inventory_item_id,
                  inventory_item_name,
                  resource_id,
                  resource_code,
                  department_id,
                  department_code,
                  supplier_id,
                  supplier_name,
 		  supplier_site_id,
                  supplier_site_name,
	          scenario_id,
		  source_type,
		  supply_demand_source_type,
                  supply_demand_quantity,
		  supply_demand_type,
		  supply_demand_date,
                  end_pegging_id,
                  constraint_flag,
                  allocated_quantity, -- 1527660
                  number1,
                  char1,
		  component_identifier,
                  -- resource batching
                  batchable_flag,
                  supplier_atp_date,
                  dest_inv_item_id,
                  summary_flag,
                  --- bug 2152184: For PF based ATP inventory_item_id field contains id for PF item
                  --- cto looks at pegging tree to place their demands. Since CTO expects to find
                  --  id for the requested item, we add the following column. CTO will now read from this column
                  request_item_id,
                  --- if req-date < ptf date then we update this column with PTF date
                  ptf_date
                -- dsting
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
                 --diag_atp
                ,FIXED_LEAD_TIME,
                VARIABLE_LEAD_TIME,
                PREPROCESSING_LEAD_TIME,
                PROCESSING_LEAD_TIME,
                POSTPROCESSING_LEAD_TIME,
                INTRANSIT_LEAD_TIME,
                ATP_RULE_ID,
                ALLOCATION_RULE,
                INFINITE_TIME_FENCE,
                SUBSTITUTION_WINDOW,
                REQUIRED_QUANTITY,
                ROUNDING_CONTROL,
                ATP_FLAG,
                ATP_COMPONENT_FLAG,
                REQUIRED_DATE,
                OPERATION_SEQUENCE_ID,
                SOURCING_RULE_NAME,
                OFFSET,
                EFFICIENCY,
                OWNING_DEPARTMENT,
                REVERSE_CUM_YIELD,
                BASIS_TYPE,
                USAGE,
                CONSTRAINT_TYPE,
                CONSTRAINT_DATE,
                CRITICAL_PATH,
                PEGGING_TYPE,
                UTILIZATION,
                ATP_RULE_NAME,
                PLAN_NAME,
                CONSTRAINED_PATH,
                weight_capacity,
                volume_capacity,
                weight_uom,
                volume_uom,
                ship_method,
                aggregate_time_fence_date, --bug3467631 added so that deletion from alloc
                                          --tables may take place
                shipping_cal_code,     -- Bug 3826234
                receiving_cal_code,    -- Bug 3826234
                intransit_cal_code,    -- Bug 3826234
                manufacturing_cal_code -- Bug 3826234
)
  VALUES
                 (p_pegging_rec.session_id,
                  p_pegging_rec.order_line_id,
                  p_pegging_rec.pegging_id,
                  p_pegging_rec.parent_pegging_id,
                  p_pegging_rec.atp_level,
                  3,
                  p_pegging_rec.organization_id,
                  p_pegging_rec.organization_code,
                  p_pegging_rec.identifier1,
                  p_pegging_rec.identifier2,
                  p_pegging_rec.identifier3,
                  p_pegging_rec.inventory_item_id,
                  p_pegging_rec.inventory_item_name,
                  p_pegging_rec.resource_id,
                  p_pegging_rec.resource_code,
                  p_pegging_rec.department_id,
                  p_pegging_rec.department_code,
                  p_pegging_rec.supplier_id,
                  p_pegging_rec.supplier_name,
                  p_pegging_rec.supplier_site_id,
                  p_pegging_rec.supplier_site_name,
                  p_pegging_rec.scenario_id,
		  p_pegging_rec.source_type,
                  p_pegging_rec.supply_demand_source_type,
                  p_pegging_rec.supply_demand_quantity,
                  p_pegging_rec.supply_demand_type,
                  p_pegging_rec.supply_demand_date,
                  --NVL(MSC_ATP_PVT.G_DEMAND_PEGGING_ID, msc_full_pegging_s.currval),
                  p_pegging_rec.end_pegging_id,
                  p_pegging_rec.constraint_flag,
                  p_pegging_rec.allocated_quantity, -- 1527660
                  p_pegging_rec.number1,
                  p_pegging_rec.char1,
		  p_pegging_rec.component_identifier,
                  p_pegging_rec.batchable_flag,
                  p_pegging_rec.supplier_atp_date,
                  p_pegging_rec.dest_inv_item_id,
                  p_pegging_rec.summary_flag,
                  p_pegging_rec.request_item_id,
                  p_pegging_rec.ptf_date
		  -- dsting
		  , sysdate
		  , FND_GLOBAL.USER_ID
		  , sysdate
		  , FND_GLOBAL.USER_ID
		  , FND_GLOBAL.USER_ID
                  ,p_pegging_rec.FIXED_LEAD_TIME,
                  p_pegging_rec.VARIABLE_LEAD_TIME,
                  p_pegging_rec.PREPROCESSING_LEAD_TIME,
                  p_pegging_rec.PROCESSING_LEAD_TIME,
                  p_pegging_rec.POSTPROCESSING_LEAD_TIME,
                  p_pegging_rec.INTRANSIT_LEAD_TIME,
                  p_pegging_rec.ATP_RULE_ID,
                  p_pegging_rec.ALLOCATION_RULE,
                  p_pegging_rec.INFINITE_TIME_FENCE,
                  p_pegging_rec.SUBSTITUTION_WINDOW,
                  p_pegging_rec.REQUIRED_QUANTITY,
                  p_pegging_rec.ROUNDING_CONTROL,
                  p_pegging_rec.ATP_FLAG,
                  p_pegging_rec.ATP_COMPONENT_FLAG,
		  -- p_pegging_rec.REQUIRED_DATE,
		  -- Bug 2748730. Move the required_date to day end only when the pegging is for demand line
		  -- This is applicable irrespective of whether the line is overridden or not
		  DECODE(p_pegging_rec.supply_demand_type,
				1, TRUNC(p_pegging_rec.REQUIRED_DATE) + MSC_ATP_PVT.G_END_OF_DAY,
				p_pegging_rec.REQUIRED_DATE),
                  p_pegging_rec.OPERATION_SEQUENCE_ID,
                  p_pegging_rec.SOURCING_RULE_NAME,
                  p_pegging_rec.OFFSET,
                  p_pegging_rec.EFFICIENCY,
                  p_pegging_rec.OWNING_DEPARTMENT,
                  p_pegging_rec.REVERSE_CUM_YIELD,
                  p_pegging_rec.BASIS_TYPE,
                  p_pegging_rec.USAGE,
                  p_pegging_rec.CONSTRAINT_TYPE,
                  p_pegging_rec.CONSTRAINT_DATE,
                  p_pegging_rec.CRITICAL_PATH,
                  p_pegging_rec.PEGGING_TYPE,
                  p_pegging_rec.UTILIZATION,
                  p_pegging_rec.ATP_RULE_NAME,
                  p_pegging_rec.PLAN_NAME,
                  p_pegging_rec.CONSTRAINED_PATH,
                  p_pegging_rec.weight_capacity,
                  p_pegging_rec.volume_capacity,
                  p_pegging_rec.weight_uom,
                  p_pegging_rec.volume_uom,
                  p_pegging_rec.ship_method,
                  p_pegging_rec.aggregate_time_fence_date, --bug3467631
                  p_pegging_rec.shipping_cal_code,     -- Bug 3826234
                  p_pegging_rec.receiving_cal_code,    -- Bug 3826234
                  p_pegging_rec.intransit_cal_code,    -- Bug 3826234
                  p_pegging_rec.manufacturing_cal_code -- Bug 3826234
);
 IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('ADD_PEGGING: ' || 'Number of rows : ' || SQL%ROWCOUNT);
 END IF;
END ADD_PEGGING;

Procedure Extend_Item_Info_Rec_Typ(
  p_item_avail_info        IN OUT NOCOPY  MSC_ATP_SUBST.Item_Info_Rec_Typ,
  x_return_status          OUT      NoCopy VARCHAR2)
IS
l_count number;
BEGIN

   --- first we will make length equal for all tables
   --- the tables will have unequal length as we inserted values in few columns in get_item_substitutes procedure
   l_count := p_item_avail_info.inventory_item_id.count;
   IF l_count > 0 and p_item_avail_info.End_pegging_id.count = 0 THEN

      p_item_avail_info.End_pegging_id.EXTEND(l_count);
      p_item_avail_info.request_date_quantity.EXTEND(l_count);
      p_item_avail_info.period_detail_begin_idx.EXTEND(l_count);
      p_item_avail_info.period_detail_end_idx.EXTEND(l_count);
      p_item_avail_info.sd_detail_begin_idx.EXTEND(l_count);
       p_item_avail_info.sd_detail_end_idx.EXTEND(l_count);
       p_item_avail_info.CTP_PRD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.CTP_PRD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.CTP_SD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.CTP_SD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_CTP_PRD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_CTP_PRD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_CTP_SD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_CTP_SD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.atp_flag.EXTEND(l_count);
       p_item_avail_info.atp_comp_flag.EXTEND(l_count);
       p_item_avail_info.pre_pro_lt.EXTEND(l_count);
       p_item_avail_info.post_pro_lt.EXTEND(l_count);
       p_item_avail_info.fixed_lt.EXTEND(l_count);
       p_item_avail_info.variable_lt.EXTEND(l_count);
       p_item_avail_info.create_supply_flag.EXTEND(l_count);
       p_item_avail_info.substitution_window.EXTEND(l_count);
       p_item_avail_info.plan_id.EXTEND(l_count);
       p_item_avail_info.ASSIGN_SET_ID.EXTEND(l_count);
       p_item_avail_info.future_atp_date.EXTEND(l_count);
       p_item_avail_info.atp_date_quantity.EXTEND(l_count);
       p_item_avail_info.demand_id.extend(l_count);
       p_item_avail_info.FUT_ATP_PRD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_ATP_PRD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_ATP_SD_DETL_BEGIN_IDX.EXTEND(l_count);
       p_item_avail_info.FUT_ATP_SD_DETL_END_IDX.EXTEND(l_count);
       p_item_avail_info.future_supply_peg_id.extend(l_count);
       p_item_avail_info.demand_class.extend(l_count);
       p_item_avail_info.fwd_steal_peg_begin_idx.extend(l_count);
       p_item_avail_info.fwd_steal_peg_end_idx.extend(l_count);
       p_item_avail_info.used_available_quantity.EXTEND(l_count); --bug3467631
       p_item_avail_info.Atf_Date_Quantity.EXTEND(l_count); --bug3467631

       -- dsting diag atp
       p_item_avail_info.rounding_control_type.EXTEND(l_count);
       p_item_avail_info.unit_weight.EXTEND(l_count);
       p_item_avail_info.weight_uom.EXTEND(l_count);
       p_item_avail_info.unit_volume.EXTEND(l_count);
       p_item_avail_info.volume_uom.EXTEND(l_count);
       p_item_avail_info.plan_name.EXTEND(l_count);
       p_item_avail_info.item_name.EXTEND(l_count);
   END IF;

   --- now extend the tables
   p_item_avail_info.inventory_item_id.EXTEND;
   p_item_avail_info.sr_inventory_item_id.EXTEND;
   p_item_avail_info.highest_revision_item_id.EXTEND;
   p_item_avail_info.item_name.EXTEND;
   p_item_avail_info.End_pegging_id.EXTEND;
   p_item_avail_info.request_date_quantity.EXTEND;
   p_item_avail_info.partial_fulfillment_flag.EXTEND;
   p_item_avail_info.period_detail_begin_idx.EXTEND;
   p_item_avail_info.period_detail_end_idx.EXTEND;
   p_item_avail_info.sd_detail_begin_idx.EXTEND;
    p_item_avail_info.sd_detail_end_idx.EXTEND;
    p_item_avail_info.CTP_PRD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.CTP_PRD_DETL_END_IDX.EXTEND;
    p_item_avail_info.CTP_SD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.CTP_SD_DETL_END_IDX.EXTEND;
    p_item_avail_info.FUT_CTP_PRD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.FUT_CTP_PRD_DETL_END_IDX.EXTEND;
    p_item_avail_info.FUT_CTP_SD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.FUT_CTP_SD_DETL_END_IDX.EXTEND;
    p_item_avail_info.atp_flag.EXTEND;
    p_item_avail_info.atp_comp_flag.EXTEND;
    p_item_avail_info.pre_pro_lt.EXTEND;
    p_item_avail_info.post_pro_lt.EXTEND;
    p_item_avail_info.fixed_lt.EXTEND;
    p_item_avail_info.variable_lt.EXTEND;
    p_item_avail_info.create_supply_flag.EXTEND;
    p_item_avail_info.substitution_window.EXTEND;
    p_item_avail_info.plan_id.EXTEND;
    p_item_avail_info.ASSIGN_SET_ID.EXTEND;
    p_item_avail_info.future_atp_date.EXTEND;
    p_item_avail_info.atp_date_quantity.EXTEND;
    p_item_avail_info.demand_id.extend;
    p_item_avail_info.FUT_ATP_PRD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.FUT_ATP_PRD_DETL_END_IDX.EXTEND;
    p_item_avail_info.FUT_ATP_SD_DETL_BEGIN_IDX.EXTEND;
    p_item_avail_info.FUT_ATP_SD_DETL_END_IDX.EXTEND;
    p_item_avail_info.future_supply_peg_id.extend;
    p_item_avail_info.demand_class.extend;
    p_item_avail_info.fwd_steal_peg_begin_idx.extend;
    p_item_avail_info.fwd_steal_peg_end_idx.extend;

    -- dsting diag_atp
    p_item_avail_info.rounding_control_type.EXTEND;
    p_item_avail_info.unit_weight.EXTEND;
    p_item_avail_info.weight_uom.EXTEND;
    p_item_avail_info.unit_volume.EXTEND;
    p_item_avail_info.volume_uom.EXTEND;
    p_item_avail_info.plan_name.EXTEND;

    --time_phased_atp
    p_item_avail_info.Family_sr_id.EXTEND;
    p_item_avail_info.Family_dest_id.EXTEND;
    p_item_avail_info.Family_item_name.EXTEND;
    p_item_avail_info.Atf_Date.EXTEND;
    p_item_avail_info.Atf_Date_Quantity.EXTEND;
    p_item_avail_info.used_available_quantity.EXTEND; --bug3467631

END Extend_Item_Info_Rec_Typ;

PROCEDURE Details_Output (
  p_atp_period          IN       MRP_ATP_PUB.ATP_Period_Typ,
  p_atp_supply_demand   IN       MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  p_begin_period_idx    IN       NUMBER,
  p_end_period_idx      IN       NUMBER,
  p_begin_sd_idx        IN       NUMBER,
  p_end_sd_idx          IN       NUMBER,
  x_atp_period          IN OUT   NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   IN OUT   NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
) IS

l_period_count          PLS_INTEGER;
l_sd_count              PLS_INTEGER;
l_count                 PLS_INTEGER;
i                       PLS_INTEGER;
Begin

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** Begin Details_Output Procedure *****');
       msc_sch_wb.atp_debug('Details_Output: ' || 'p_begin_period_idx : = ' || p_begin_period_idx);
       msc_sch_wb.atp_debug('Details_Output: ' || 'p_end_period_idx := ' || p_end_period_idx);
       msc_sch_wb.atp_debug('Details_Output: ' || 'p_begin_sd_idx := ' || p_begin_sd_idx);
       msc_sch_wb.atp_debug('Details_Output: ' || 'p_end_sd_idx := ' || p_end_sd_idx);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_atp_period.level.COUNT > 0 THEN

        l_count := x_atp_period.level.COUNT;
        --FOR l_period_count in 1..p_atp_period.level.COUNT LOOP
        l_period_count := 0;
        FOR i in p_begin_period_idx..p_end_period_idx LOOP
                    MSC_SATP_FUNC.Extend_Atp_Period(x_atp_period, x_return_status);
                    l_period_count := l_period_count + 1;
                    x_atp_period.Level(l_count + l_period_count) :=
                        p_atp_period.Level(i);
                    x_atp_period.Inventory_Item_Id(l_count + l_period_count) :=
                        p_atp_period.Inventory_Item_Id(i);
                    x_atp_period.Request_Item_Id(l_count + l_period_count) :=
                        p_atp_period.Request_Item_Id(i);
                    x_atp_period.Organization_Id(l_count + l_period_count) :=
                        p_atp_period.Organization_Id(i);
                    x_atp_period.Department_Id(l_count + l_period_count) :=
                        p_atp_period.Department_Id(i);
                    x_atp_period.Resource_Id(l_count + l_period_count) :=
                        p_atp_period.Resource_Id(i);
                    x_atp_period.Supplier_Id(l_count + l_period_count) :=
                        p_atp_period.Supplier_Id(i);
                    x_atp_period.Supplier_Site_Id(l_count + l_period_count) :=
                        p_atp_period.Supplier_Site_Id(i);
                    x_atp_period.From_Organization_Id(l_count + l_period_count)
                        := p_atp_period.From_Organization_Id(i);
                    x_atp_period.From_Location_Id(l_count + l_period_count) :=
                        p_atp_period.From_Location_Id(i);
                    x_atp_period.To_Organization_Id(l_count + l_period_count) :=
                        p_atp_period.To_Organization_Id(i);
                    x_atp_period.To_Location_Id(l_count + l_period_count) :=
                        p_atp_period.To_Location_Id(i);
                    x_atp_period.Ship_Method(l_count + l_period_count) :=
                        p_atp_period.Ship_Method(i);
                    x_atp_period.Uom(l_count + l_period_count) :=
                        p_atp_period.Uom(i);
                    x_atp_period.Total_Supply_Quantity(l_count + l_period_count)
                        := p_atp_period.Total_Supply_Quantity(i);
                    x_atp_period.Total_Demand_Quantity(l_count + l_period_count)
                        := p_atp_period.Total_Demand_Quantity(i);
                    x_atp_period.Period_Start_Date(l_count + l_period_count):=
                        p_atp_period.Period_Start_Date(i);
                    x_atp_period.Period_End_Date(l_count + l_period_count):=
                        p_atp_period.Period_End_Date(i);
                    x_atp_period.Period_Quantity(l_count + l_period_count):=
                        p_atp_period.Period_Quantity(i);
                    x_atp_period.Cumulative_Quantity(l_count + l_period_count):=
                        p_atp_period.Cumulative_Quantity(i);
                    x_atp_period.Identifier1(l_count + l_period_count):=
                        p_atp_period.Identifier1(i);
                    x_atp_period.Identifier2(l_count + l_period_count):=
                        p_atp_period.Identifier2(i);
                    x_atp_period.Identifier(l_count + l_period_count):=
                        p_atp_period.Identifier(i);
                    x_atp_period.scenario_Id(l_count + l_period_count) :=
                        p_atp_period.scenario_Id(i);
                    x_atp_period.pegging_id(l_count + l_period_count) :=
                        p_atp_period.pegging_id(i);
                    x_atp_period.end_pegging_id(l_count + l_period_count) :=
                        p_atp_period.end_pegging_id(i);


        END LOOP;
    END IF;

    IF p_atp_supply_demand.level.COUNT > 0 THEN
        l_count := x_atp_supply_demand.level.COUNT;

        --FOR l_sd_count in 1..p_atp_supply_demand.level.COUNT LOOP
        l_sd_count := 0;
        FOR i in p_begin_sd_idx..p_end_sd_idx LOOP
                    l_sd_count := l_sd_count + 1;
                    MSC_SATP_FUNC.Extend_Atp_Supply_Demand(x_atp_supply_demand,
                                             x_return_status);
                    x_atp_supply_demand.Level(l_count + l_sd_count):=
                        p_atp_supply_demand.Level(i);
                    x_atp_supply_demand.Inventory_Item_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Inventory_Item_Id(i);
                    x_atp_supply_demand.Request_Item_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Request_Item_Id(i);
                    x_atp_supply_demand.Organization_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Organization_Id(i);
                    x_atp_supply_demand.Department_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Department_Id(i);
                    x_atp_supply_demand.Resource_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Resource_Id(i);
                    x_atp_supply_demand.Supplier_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Supplier_Id(i);
                    x_atp_supply_demand.Supplier_Site_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Supplier_Site_Id(i);
                    x_atp_supply_demand.From_Organization_Id(l_count+l_sd_count)
                        := p_atp_supply_demand.From_Organization_Id(i);
                    x_atp_supply_demand.From_Location_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.From_Location_Id(i);
                    x_atp_supply_demand.To_Organization_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.To_Organization_Id(i);
                    x_atp_supply_demand.To_Location_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.To_Location_Id(i);
                    x_atp_supply_demand.Ship_Method(l_count+l_sd_count):=
                        p_atp_supply_demand.Ship_Method(i);
                    x_atp_supply_demand.Uom(l_count+l_sd_count):=
                        p_atp_supply_demand.Uom(i);
                    x_atp_supply_demand.Identifier1(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier1(i);
                    x_atp_supply_demand.Identifier2(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier2(i);
                    x_atp_supply_demand.Identifier3(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier3(i);
                    x_atp_supply_demand.Identifier4(l_count+l_sd_count):=
                        p_atp_supply_demand.Identifier4(i);
                    x_atp_supply_demand.Supply_Demand_Type(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Type(i);
                    x_atp_supply_demand.Supply_Demand_Source_Type(l_count+ l_sd_count)
                        := p_atp_supply_demand.Supply_Demand_Source_Type(i);
                    x_atp_supply_demand.Supply_Demand_Source_Type_Name(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Source_Type_Name(i);
                    x_atp_supply_demand.Supply_Demand_Date(l_count+l_sd_count):=
                        p_atp_supply_demand.Supply_Demand_Date(i);
                    x_atp_supply_demand.Supply_Demand_Quantity(l_count+l_sd_count) :=
                        p_atp_supply_demand.Supply_Demand_Quantity(i);
                    x_atp_supply_demand.Identifier(l_count + l_sd_count):=
                        p_atp_supply_demand.Identifier(i);
                    x_atp_supply_demand.scenario_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.scenario_Id(i);
                    x_atp_supply_demand.Disposition_Type(l_count+l_sd_count):=
                        p_atp_supply_demand.Disposition_Type(i);
                    x_atp_supply_demand.Disposition_Name(l_count+l_sd_count):=
                        p_atp_supply_demand.Disposition_Name(i);
                    x_atp_supply_demand.Pegging_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.Pegging_Id(i);
                    x_atp_supply_demand.End_Pegging_Id(l_count+l_sd_count):=
                        p_atp_supply_demand.End_Pegging_Id(i);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('Details_Output: item '||
		p_atp_supply_demand.inventory_item_id(i)||
		' : org '|| p_atp_supply_demand.organization_id(i) ||
		' : qty '|| p_atp_supply_demand.supply_demand_quantity(i) ||
		' : peg '|| p_atp_supply_demand.pegging_id(i));
	END IF;


        END LOOP;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Details_Output Procedure *****');
    END IF;

END Details_Output;

Procedure Copy_Item_Info_Rec(p_parent_item_info       IN     MSC_ATP_SUBST.Item_Info_Rec_Typ,
                             p_child_item_info         IN OUT NoCopy MSC_ATP_SUBST.Item_Info_Rec_Typ,
                             p_index                  IN     NUMBER)
IS
l_return_status varchar2(1);
l_count number;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** start Copy_Item_Info_Rec ****');
   END IF;
   MSC_ATP_SUBST.Extend_Item_Info_Rec_Typ(p_child_item_info, l_return_status);
   l_count := p_child_item_info.inventory_item_id.count;
    p_child_item_info.inventory_item_id(l_count) := p_parent_item_info.inventory_item_id(p_index);
    p_child_item_info.sr_inventory_item_id(l_count) := p_parent_item_info.sr_inventory_item_id(p_index);
    p_child_item_info.highest_revision_item_id(l_count) :=  p_parent_item_info.highest_revision_item_id(p_index);

    p_child_item_info.item_name(l_count) :=  p_parent_item_info.item_name(p_index);
    p_child_item_info.End_pegging_id(l_count) :=  p_parent_item_info.End_pegging_id(p_index);
    p_child_item_info.request_date_quantity(l_count) :=  p_parent_item_info.request_date_quantity(p_index);
    p_child_item_info.partial_fulfillment_flag(l_count) :=  p_parent_item_info.partial_fulfillment_flag(p_index);
    p_child_item_info.period_detail_begin_idx(l_count) :=  p_parent_item_info.period_detail_begin_idx(p_index);
    p_child_item_info.period_detail_end_idx(l_count) :=  p_parent_item_info.period_detail_end_idx(p_index);
    p_child_item_info.sd_detail_begin_idx(l_count) :=   p_parent_item_info.sd_detail_begin_idx(p_index);
    p_child_item_info.sd_detail_end_idx(l_count) :=  p_parent_item_info.sd_detail_end_idx(p_index);
    p_child_item_info.ctp_prd_detl_begin_idx(l_count) := p_parent_item_info.ctp_prd_detl_begin_idx(p_index);
    p_child_item_info.CTP_PRD_DETL_END_IDX(l_count) := p_parent_item_info.CTP_PRD_DETL_END_IDX(p_index);
    p_child_item_info.CTP_SD_DETL_BEGIN_IDX(l_count) := p_parent_item_info.CTP_SD_DETL_BEGIN_IDX(p_index);
    p_child_item_info.CTP_SD_DETL_END_IDX(l_count) := p_parent_item_info.CTP_SD_DETL_END_IDX(p_index);
    p_child_item_info.FUT_CTP_PRD_DETL_BEGIN_IDX(l_count) := p_parent_item_info.FUT_CTP_PRD_DETL_BEGIN_IDX(p_index);
    p_child_item_info.FUT_CTP_PRD_DETL_END_IDX(l_count) := p_parent_item_info.FUT_CTP_PRD_DETL_END_IDX(p_index);
    p_child_item_info.FUT_CTP_SD_DETL_BEGIN_IDX(l_count) := p_parent_item_info.FUT_CTP_SD_DETL_BEGIN_IDX(p_index);
    p_child_item_info.FUT_CTP_SD_DETL_END_IDX(l_count) := p_parent_item_info.FUT_CTP_SD_DETL_END_IDX(p_index);
    p_child_item_info.atp_flag(l_count) :=  p_parent_item_info.atp_flag(p_index);
    p_child_item_info.atp_comp_flag(l_count) :=  p_parent_item_info.atp_comp_flag(p_index);
    p_child_item_info.pre_pro_lt(l_count) :=   p_parent_item_info.pre_pro_lt(p_index);
    p_child_item_info.post_pro_lt(l_count) :=  p_parent_item_info.post_pro_lt(p_index);
    p_child_item_info.fixed_lt(l_count) :=    p_parent_item_info.fixed_lt(p_index);
    p_child_item_info.variable_lt(l_count) :=   p_parent_item_info.variable_lt(p_index);
    p_child_item_info.create_supply_flag(l_count) :=  p_parent_item_info.create_supply_flag(p_index);
    p_child_item_info.substitution_window(l_count) :=  p_parent_item_info.substitution_window(p_index);
    p_child_item_info.plan_id(l_count) := p_parent_item_info.plan_id(p_index);
    p_child_item_info.ASSIGN_SET_ID(l_count) := p_parent_item_info.ASSIGN_SET_ID(p_index);
    p_child_item_info.future_atp_date(l_count) := p_parent_item_info.future_atp_date(p_index);
    p_child_item_info.atp_date_quantity(l_count) := p_parent_item_info.atp_date_quantity(p_index);
    p_child_item_info.demand_id(l_count) := p_parent_item_info.demand_id(p_index);
    p_child_item_info.demand_class(l_count) := p_parent_item_info.demand_class(p_index);
    p_child_item_info.fwd_steal_peg_begin_idx(l_count) := p_parent_item_info.fwd_steal_peg_begin_idx(p_index);
    p_child_item_info.fwd_steal_peg_end_idx(l_count)   := p_parent_item_info.fwd_steal_peg_end_idx(p_index);
    p_child_item_info.rounding_control_type(l_count) := p_parent_item_info.rounding_control_type(p_index);
    --diag_atp : add the following variable for peeign enhancement
    p_child_item_info.unit_weight(l_count) := p_parent_item_info.unit_weight(p_index);
    p_child_item_info.weight_uom(l_count) := p_parent_item_info.weight_uom(p_index);
    p_child_item_info.unit_volume(l_count) := p_parent_item_info.unit_volume(p_index);
    p_child_item_info.volume_uom(l_count) := p_parent_item_info.volume_uom(p_index);
    p_child_item_info.plan_name(l_count) := p_parent_item_info.plan_name(p_index);

    --time_phased_atp
    p_child_item_info.Family_sr_id(l_count) := p_parent_item_info.Family_sr_id(p_index);
    p_child_item_info.Family_dest_id(l_count) := p_parent_item_info.Family_dest_id(p_index);
    p_child_item_info.Family_item_name(l_count) := p_parent_item_info.Family_item_name(p_index);
    p_child_item_info.Atf_Date(l_count) := p_parent_item_info.Atf_Date(p_index);
    p_child_item_info.Atf_Date_Quantity(l_count) := p_parent_item_info.Atf_Date_Quantity(p_index);


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** END Copy_Item_Info_Rec ****');
   END IF;

END Copy_Item_Info_Rec;

/* time_phased_atp
   we no longer need this procedure
   to be deleted after code review
PROCEDURE Add_Mat_Demand(
  p_atp_rec          IN         MRP_ATP_PVT.AtpRec ,
  p_plan_id          IN         NUMBER ,
  p_dc_flag          IN         NUMBER,
  x_demand_id        OUT        NoCopy NUMBER
)
IS
l_sqlfound      BOOLEAN := FALSE;
my_sqlcode      NUMBER;
l_count         NUMBER;
temp_sd_qty     number;
l_record_source number := 2; -- for plan order pegging
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** Begin SUBST Add_Mat_Demand *****');
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.quantity_ordered '||p_atp_rec.quantity_ordered);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.requested_ship_date '||p_atp_rec.requested_ship_date);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.origination_type '||p_atp_rec.origination_type);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.inventory_item_id '||p_atp_rec.inventory_item_id);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.organization_id '||p_atp_rec.organization_id);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.demand_source_line '||p_atp_rec.demand_source_line);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.instance_id '||p_atp_rec.instance_id);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_plan_id = ' || p_plan_id);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'p_atp_rec.action '||p_atp_rec.action);
      msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'request_item_id :=' || p_atp_rec.request_item_id);
   END IF;
   --IF (p_atp_rec.origination_type NOT IN (6, 30)) THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'before insert into msc_demands');
        END IF;

        INSERT INTO MSC_DEMANDS(
                DEMAND_ID,
                USING_REQUIREMENT_QUANTITY,
                USING_ASSEMBLY_DEMAND_DATE,
                DEMAND_TYPE,
                ORIGINATION_TYPE,
                USING_ASSEMBLY_ITEM_ID,
                PLAN_ID,
                ORGANIZATION_ID,
                INVENTORY_ITEM_ID,
                SALES_ORDER_LINE_ID,
                SR_INSTANCE_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                DEMAND_CLASS,
                REFRESH_NUMBER,
                ORDER_NUMBER,
                APPLIED,
                STATUS,
                CUSTOMER_ID,
                SHIP_TO_SITE_ID,
                original_item_id,
                record_source) -- For plan order pegging
                ---STOLEN_FLAG)  -- 02/16: Stealing
        VALUES(
                msc_demands_s.nextval,
                p_atp_rec.quantity_ordered,
                TRUNC(p_atp_rec.requested_ship_date) + MSC_ATP_PVT.G_END_OF_DAY , -- For bug 2259824
                1, -- discrete demand
                p_atp_rec.origination_type,
                p_atp_rec.inventory_item_id,
                p_plan_id,
                p_atp_rec.organization_id,
                p_atp_rec.inventory_item_id,
                p_atp_rec.demand_source_line,
                p_atp_rec.instance_id,
                sysdate,
                FND_GLOBAL.USER_ID,
                sysdate,
                FND_GLOBAL.USER_ID,
                p_atp_rec.demand_class,
                p_atp_rec.refresh_number,
                -- Modified by ngoel on 1/12/2001 for origination_type = 30
                decode(p_atp_rec.origination_type, 6, p_atp_rec.order_number,
                       30, p_atp_rec.order_number,
                       null),
                decode(p_atp_rec.origination_type, 6, 2, 30, 2, null),
                decode(p_atp_rec.origination_type, 6, 0, 30, 0, null),
                MSC_ATP_PVT.G_PARTNER_ID,
                MSC_ATP_PVT.G_PARTNER_SITE_ID,
                p_atp_rec.request_item_id,
                l_record_source)  -- For plan order pegging
                --1657855, remove support for min allocation
                ---p_atp_rec.stolen_flag)
        RETURNING DEMAND_ID INTO x_demand_id;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Mat_Demand: ' || 'Numbe of rows inserted := ' || SQL%ROWCOUNT);
        END IF;
        IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
             (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
             (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
             (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('Add_Mat_Demand: before insert into'||
                                ' msc_alloc_demands');
	   END IF;

           INSERT INTO MSC_ALLOC_DEMANDS(
                       PLAN_ID,
	               INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       SR_INSTANCE_ID,
                       DEMAND_CLASS,
                       DEMAND_DATE,
                       PARENT_DEMAND_ID,
                       ALLOCATED_QUANTITY,
                       ORIGINATION_TYPE,
                       ORDER_NUMBER,
		       SALES_ORDER_LINE_ID,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE
                       )
           VALUES (
                   p_plan_id,
                   p_atp_rec.inventory_item_id,
                   p_atp_rec.organization_id,
                   p_atp_rec.instance_id,
                   p_atp_rec.demand_class,
                   p_atp_rec.requested_ship_date, -- QUESTION arrival items ?
                   x_demand_id,
                   p_atp_rec.quantity_ordered,
                   p_atp_rec.origination_type,
                   p_atp_rec.order_number,
                   p_atp_rec.demand_source_line,
                   FND_GLOBAL.USER_ID,
                   sysdate,
                   FND_GLOBAL.USER_ID,
                   sysdate);
        END IF;
   --END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** End Add_Mat_Demand *****');
   END IF;

END Add_Mat_Demand;
*/
End MSC_ATP_SUBST;

/
