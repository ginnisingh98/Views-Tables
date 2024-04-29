--------------------------------------------------------
--  DDL for Package Body MSC_ATP_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_FUNC" AS
/* $Header: MSCFATPB.pls 120.1.12010000.2 2009/05/16 12:48:57 sbnaik ship $  */
G_PKG_NAME 		CONSTANT VARCHAR2(30) := 'MSC_ATP_FUNC';


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

FUNCTION get_atp_flag (p_instance_id            IN  NUMBER,
                       p_plan_id                IN  NUMBER,
                       p_inventory_item_id      IN  NUMBER,
                       p_organization_id        IN  NUMBER)
RETURN VARCHAR2
IS
l_atp_flag	VARCHAR2(1);
l_bom_item_type         NUMBER;
l_atp_check             NUMBER;

BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('inside get_atp_flag');
   msc_sch_wb.atp_debug('get_atp_flag: ' || 'sr_inventory_item_id = '||p_inventory_item_id);
   msc_sch_wb.atp_debug('get_atp_flag: ' || 'organization_id = '||p_organization_id);
   msc_sch_wb.atp_debug('get_atp_flag: ' || 'plan_id = '||p_plan_id);
   msc_sch_wb.atp_debug('get_atp_flag: ' || 'sr_instance_id = '||p_instance_id);
END IF;

    -- Changed on 1/23/2001 by ngoel. In case of multi-level/multi-org CTO
    -- we need to set this flag to No in case the atp check flag is set to
    -- No for the bom.
/*
    SELECT atp_flag
    INTO   l_atp_flag
    FROM   msc_system_items
    WHERE  sr_inventory_item_id = p_inventory_item_id
    AND    organization_id = p_organization_id
    AND    plan_id = p_plan_id
    AND    sr_instance_id = p_instance_id;
*/

    SELECT i.atp_flag, i.bom_item_type, b.atp_check
    INTO   l_atp_flag, l_bom_item_type, l_atp_check
    FROM   msc_system_items i, msc_bom_temp b
    WHERE  i.sr_inventory_item_id = p_inventory_item_id
    AND    i.organization_id = p_organization_id
    AND    i.plan_id = p_plan_id
    AND    i.sr_instance_id = p_instance_id
    AND    b.component_item_id (+) = i.sr_inventory_item_id
    AND    b.component_identifier (+) = MSC_ATP_PVT.G_COMP_LINE_ID
    AND    b.session_id (+) = MSC_ATP_PVT.G_SESSION_ID;

    IF l_bom_item_type = 4 AND NVL(l_atp_check, -1) = 2 THEN
       l_atp_flag := 'N';
    END IF;

    MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := NULL;
    return l_atp_flag;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       MSC_ATP_PVT.G_SR_INVENTORY_ITEM_ID := p_inventory_item_id;
       return 'N';
END get_atp_flag;


FUNCTION get_atp_comp_flag (p_instance_id            IN  NUMBER,
                            p_plan_id                IN  NUMBER,
                            p_inventory_item_id      IN  NUMBER,
                            p_organization_id        IN  NUMBER)
RETURN VARCHAR2
IS
l_atp_comp_flag      VARCHAR2(1);
l_bom_item_type      NUMBER;
l_pick_comp_flag     VARCHAR2(1);
l_replenish_flag     VARCHAR2(1);
l_cto_bom            NUMBER := 0;
l_atp_check          NUMBER;
BEGIN

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('inside get_atp_comp_flag');
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'sr_inventory_item_id = '||p_inventory_item_id);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'organization_id = '||p_organization_id);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'plan_id = '||p_plan_id);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'sr_instance_id = '||p_instance_id);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'G_ORDER_LINE_ID = '||MSC_ATP_PVT.G_ORDER_LINE_ID);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'G_ASSEMBLY_LINE_ID = '||MSC_ATP_PVT.G_ASSEMBLY_LINE_ID);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'G_COMP_LINE_ID = '||MSC_ATP_PVT.G_COMP_LINE_ID);
END IF;

    -- Fix for Bug 1413039 9/22/00 - NGOEL
    -- Since we don't support multi-level ATP for ODS, set
    -- return ATP component flag as N in case of ODS.

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'G_INV_CTP = '||MSC_ATP_PVT.G_INV_CTP);
END IF;
  IF MSC_ATP_PVT.G_INV_CTP = 5 THEN
       l_atp_comp_flag := 'N';

--  IF p_plan_id = -1 THEN

  ELSE
    SELECT atp_components_flag , bom_item_type,
           pick_components_flag, replenish_to_order_flag
    INTO   l_atp_comp_flag, l_bom_item_type,
           l_pick_comp_flag, l_replenish_flag
    FROM   msc_system_items
    WHERE  sr_inventory_item_id = p_inventory_item_id
    AND    organization_id = p_organization_id
    AND    plan_id = -1
    AND    sr_instance_id = p_instance_id;

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'l_bom_item_type = '||l_bom_item_type);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'l_pick_comp_flag = '||l_pick_comp_flag);
   msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'l_replenish_flag = '||l_replenish_flag);
END IF;

    IF l_bom_item_type in (1, 2) THEN
      -- since bom team does the explosion for the model and option class
      -- already, we don't want to do components one more time.  so we need to
      -- change the components flag based on the followings
      --  value from database            what get return
      --          Y                             N
      --          N                             N
      --          C                             R
      --          R                             R

      -- Bug 1562754, use G_ASSEMBLY_LINE_ID instead of G_COMP_LINE_ID, to make sure that
      -- in case of CTO, we try to get the BOM correctly from msc_bom_temp_table.-NGOEL 02/01/2001

      -- ngoel 9/24/2001, added to identify if current line is a MATO line, no need to run this select again.

      IF (NVL(MSC_ATP_PVT.G_CTO_LINE, 'N') = 'N') THEN
        SELECT   count(assembly_identifier)
        INTO     l_cto_bom
        FROM     msc_bom_temp mbt
        WHERE    mbt.session_id = MSC_ATP_PVT.G_SESSION_ID
        AND      mbt.assembly_identifier = MSC_ATP_PVT.G_COMP_LINE_ID
        AND      mbt.assembly_item_id = p_inventory_item_id;

        IF l_cto_bom > 0 THEN
	   MSC_ATP_PVT.G_CTO_LINE := 'Y';
        END IF;
      END IF;

      -- FOR CTO Models, pick_components_flag shall be 'N' and replenish_to_order
      -- flag shall be 'Y'. Modify flag only for PTO model or an option class.
      -- When a BOM exists in MSC_BOM_TEMP table, modify flags to always check for
      -- material.

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'l_cto_bom = '||l_cto_bom);
         msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'G_CTO_LINE = '||MSC_ATP_PVT.G_CTO_LINE);
      END IF;

      IF ((NVL(l_pick_comp_flag, 'N') = 'N') AND (NVL(l_replenish_flag, 'N') = 'Y')) AND
         (NVL(MSC_ATP_PVT.G_CTO_LINE, 'N') = 'Y') AND (l_bom_item_type = 1) THEN
         IF l_atp_comp_flag = 'N' THEN
             l_atp_comp_flag := 'Y';
         ELSIF l_atp_comp_flag = 'R' THEN
             l_atp_comp_flag := 'C';
         END IF;
      ELSE
         IF l_atp_comp_flag = 'Y' THEN
             l_atp_comp_flag := 'N';
         ELSIF l_atp_comp_flag = 'C' THEN
             l_atp_comp_flag := 'R';
         END IF;
      END IF;
    ELSIF l_bom_item_type = 4 THEN
      BEGIN
          SELECT atp_check
          INTO   l_atp_check
          FROM   msc_bom_temp
          WHERE  component_item_id = p_inventory_item_id
          AND    component_identifier = MSC_ATP_PVT.G_COMP_LINE_ID
          AND    session_id = MSC_ATP_PVT.G_SESSION_ID;

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'l_atp_check : '||l_atp_check);
          END IF;

          IF l_bom_item_type = 4 AND NVL(l_atp_check, -1) = 2 THEN
             l_atp_comp_flag := 'N';
          END IF;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
       END;

    END IF;

  END IF;

  return l_atp_comp_flag;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'sqlcode : '||sqlcode);
          msc_sch_wb.atp_debug('get_atp_comp_flag: ' || 'sqlerr : '||sqlerrm);
       END IF;
       return 'N';
END get_atp_comp_flag;


FUNCTION get_location_id (p_instance_id         IN  NUMBER,
			  p_organization_id     IN  NUMBER,
                          p_customer_id         IN  NUMBER,
                          p_customer_site_id    IN  NUMBER,
                          p_supplier_id         IN  NUMBER,
                          p_supplier_site_id    IN  NUMBER)
RETURN NUMBER
IS
l_location_id      NUMBER;

BEGIN

    IF (p_organization_id IS NOT NULL) THEN

        SELECT sr_tp_site_id
        INTO   l_location_id
        FROM   msc_trading_partner_sites
        WHERE  sr_tp_id = p_organization_id
        AND    sr_instance_id = p_instance_id
        AND    partner_type = 3;


    ELSIF ((p_customer_id IS NOT NULL) AND
          (p_customer_site_id IS NOT NULL)) THEN
        -- krajan:
        -- Location ID from msc_location_associations
        SELECT loc.location_id
        INTO   l_location_id
        FROM   msc_tp_site_id_lid tpsid,
               msc_location_associations loc
        -- Modified for Sony Bug 2793404
        -- Remove customer_id filter and corresponding join to msc_tp_id Bug 2816887
	WHERE  tpsid.sr_tp_site_id = p_customer_site_id
        AND    tpsid.sr_instance_id = p_instance_id
        AND    tpsid.partner_type = 2
        AND    loc.partner_site_id = tpsid.tp_site_id
        AND    loc.sr_instance_id = tpsid.sr_instance_id

	--bug 6833430 to ensure loc record is that of customer
	AND  NOT EXISTS (select NULL
	                from msc_trading_partners mtp
	                where mtp.sr_instance_id = loc.sr_instance_id AND
			mtp.partner_id = loc.partner_id AND
			mtp.partner_type = 3);

--        AND    loc.organization_id is NULL;		--bug 6833430
        -- Add organization_id is null filter.
        -- End Bug 2793404

    ELSIF ((p_supplier_id IS NOT NULL) AND
          (p_supplier_site_id IS NOT NULL)) THEN

        -- cchen: 1124206
        SELECT l.location_id
        INTO   l_location_id
        FROM   msc_location_associations l
        WHERE  l.sr_instance_id = p_instance_id
        AND    l.partner_id = p_supplier_id
        AND    l.partner_site_id = p_supplier_site_id;

    END IF;

    return l_location_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
    return null;

END get_location_id;


FUNCTION get_infinite_time_fence_date (p_instance_id        IN NUMBER,
                                       p_inventory_item_id  IN NUMBER,
                                       p_organization_id    IN NUMBER,
                                       p_plan_id            IN NUMBER)
RETURN DATE
IS

l_infinite_time_fence_date      DATE;
l_item_type		        NUMBER;

BEGIN
/* for 1478110.  please refer to the BUG
  IF p_plan_id <> -1  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'selecting infinite_time_fence_date, MSC_ATP_PVT.G_INV_CTP = 4');
    END IF;

    SELECT curr_cutoff_date
    INTO   l_infinite_time_fence_date
    FROM   msc_plans
    WHERE  plan_id = p_plan_id;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'l_infinite_time_fence_date'||l_infinite_time_fence_date);
    END IF;
  ELSE

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'selecting infinite_time_fence_date, MSC_ATP_PVT.G_INV_CTP = 5');
    END IF;
*/

  -- Bug 1566260, in case of modle or option class for PDS ATP, return null.
  -- This way, we always will work with multi-level results rather than single level
  -- This was done so that pegging tree is always available for Mulit-org CTO and
  -- demand entries could be stored for planning purposes.

  IF p_plan_id <> -1  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'selecting item type for PDS');
    END IF;
    SELECT i.bom_item_type
    INTO   l_item_type
    FROM   msc_system_items i
    WHERE  i.plan_id = p_plan_id
    AND    i.sr_instance_id = p_instance_id
    AND    i.organization_id = p_organization_id
    AND    i.sr_inventory_item_id = p_inventory_item_id;
  END IF;

  IF nvl(l_item_type, -1) IN (1,2)  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'PDS item type is model(1) or option class(2) : '||l_item_type);
    END IF;
    l_infinite_time_fence_date := null;
  ELSE

    -- Bug 2877340, 2746213
    -- Read the Profile option to pad the user defined days
    -- to infinite Supply fence.
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: Profile value for Infinite Supply Pad');
       msc_sch_wb.atp_debug('get_infinite_time_fence_date: MSC_ATP_PVT.G_INF_SUP_TF_PAD ' || MSC_ATP_PVT.G_INF_SUP_TF_PAD);
    END IF;
    -- End Bug 2877340, 2746213
    SELECT c2.calendar_date
    INTO   l_infinite_time_fence_date
    FROM   msc_calendar_dates c2,
           msc_calendar_dates c1,
           msc_atp_rules r,
           msc_trading_partners tp,
           msc_system_items i
    WHERE  i.sr_inventory_item_id = p_inventory_item_id
    AND    i.organization_id = p_organization_id
    --AND    i.plan_id = p_plan_id
    AND    i.plan_id = -1   -- for 1478110
    AND    i.sr_instance_id = p_instance_id
    AND    tp.sr_tp_id = i.organization_id
    AND    tp.sr_instance_id = i.sr_instance_id
    AND    tp.partner_type = 3
    AND    r.sr_instance_id = tp.sr_instance_id
    AND    r.rule_id = NVL(i.atp_rule_id, NVL(tp.default_atp_rule_id,0))
    AND    c1.sr_instance_id = r.sr_instance_id
    AND    c1.calendar_date = TRUNC(sysdate)
    AND    c1.calendar_code = tp.calendar_code
    AND    c1.exception_set_id = -1
    AND    c2.sr_instance_id = c1.sr_instance_id

    -- Bug 2877340, 2746213
    -- Add Infinite Supply Time Fence PAD
    --bug3609031 adding ceil
    AND    c2.seq_num = c1.next_seq_num +
                  DECODE(r.infinite_supply_fence_code,
                  1, ceil(i.cumulative_total_lead_time) + MSC_ATP_PVT.G_INF_SUP_TF_PAD,
                  2, ceil(i.cum_manufacturing_lead_time) + MSC_ATP_PVT.G_INF_SUP_TF_PAD,
                  3, DECODE(NVL(ceil(i.preprocessing_lead_time),-1)+
                            NVL(ceil(i.full_lead_time),-1)+
                            NVL(ceil(i.postprocessing_lead_time),-1),-3,
                            NULL,              -- All are NULL so return NULL.
                            NVL(ceil(i.preprocessing_lead_time),0)+   -- Otherwise
                            NVL(ceil(i.full_lead_time),0) +           -- evaluate to
                            NVL(ceil(i.postprocessing_lead_time),0) -- NON NULL
                            + MSC_ATP_PVT.G_INF_SUP_TF_PAD),
                                               -- Bugs 1986353, 2004479.
                  4, r.infinite_supply_time_fence)
    -- End Bug 2877340, 2746213
    AND    c2.calendar_code = c1.calendar_code
    AND    c2.exception_set_id = -1;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'l_infinite_time_fence_date '||l_infinite_time_fence_date);
  END IF;
  return l_infinite_time_fence_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       -- for 1478110.  please refer to the BUG
       --IF p_plan_id = -1 THEN

       -- ngoel 2/15/2002, modified to avoid no_data_found in case call is made from
       -- View_Allocation

       IF p_plan_id IN (-1, -200) THEN
         return null;
       ELSE

         -- since this is pds, use planning's cutoff date as the infinite
         -- time fence date if no rule at item/org level, and no rule
         -- at org default.

         SELECT trunc(curr_cutoff_date)
         INTO   l_infinite_time_fence_date
         FROM   msc_plans
         WHERE  plan_id = p_plan_id;

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('get_infinite_time_fence_date: ' || 'l_infinite_time_fence_date'||l_infinite_time_fence_date);
         END IF;
         return l_infinite_time_fence_date;
       END IF;

END get_infinite_time_fence_date;


FUNCTION get_org_code (p_instance_id            IN NUMBER,
                       p_organization_id        IN NUMBER)
RETURN VARCHAR2
IS
l_org_code      VARCHAR2(7);

BEGIN

    SELECT organization_code
    INTO   l_org_code
    FROM   msc_trading_partners
    WHERE  sr_tp_id = p_organization_id
    AND    sr_instance_id = p_instance_id
    AND    partner_type = 3;

  return l_org_code;
EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_org_code;


FUNCTION get_inv_item_name (p_instance_id            IN NUMBER,
                            p_inventory_item_id      IN NUMBER,
                            p_organization_id        IN NUMBER)
RETURN VARCHAR2
IS
l_inv_item_name		VARCHAR2(40);

BEGIN

    SELECT substr(ITEM_NAME, 1, 40)
    INTO   l_inv_item_name
    FROM   msc_system_items
    WHERE  organization_id = p_organization_id
    AND    sr_inventory_item_id = p_inventory_item_id
    AND    plan_id = -1
    AND    sr_instance_id = p_instance_id;

  return l_inv_item_name;
EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_inv_item_name;


FUNCTION get_inv_item_id (p_instance_id            IN NUMBER,
                            p_inventory_item_id      IN NUMBER,
                            p_match_item_id          IN NUMBER,
                            p_organization_id        IN NUMBER)
RETURN number
IS
l_inv_item_id         NUMBER;
l_sr_inv_item_id      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_inv_item_ids        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_item_count          NUMBER;
l_count               NUMBER;  -- 4091487

BEGIN
/*
    SELECT inventory_item_id
    INTO   l_inv_item_id
    FROM   msc_system_items
    WHERE  organization_id = p_organization_id
    AND    sr_inventory_item_id = p_inventory_item_id
    AND    plan_id = -1
    AND    sr_instance_id = p_instance_id;
*/
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Inside  get_inv_item_id');
       msc_sch_wb.atp_debug('p_instance_id := ' || p_instance_id);
       msc_sch_wb.atp_debug('p_inventory_item_id := ' || p_inventory_item_id);
       msc_sch_wb.atp_debug('p_match_item_id := ' || p_match_item_id);
    END IF;
    IF p_match_item_id is not null THEN

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Match item exists');
       END IF;
       --bug 4091487 Added the if condition to drive query from  msc_system_items in case organization id is passed
       --            else go through msc_item_id_lid
       IF(p_organization_id is not null) THEN

          SELECT inventory_item_id, inventory_item_id
          bulk   collect into
                 l_sr_inv_item_id, l_inv_item_ids
          FROM   msc_system_items
          WHERE  organization_id = p_organization_id
          AND    sr_inventory_item_id in (p_inventory_item_id, p_match_item_id)
          AND    plan_id = -1
          AND    sr_instance_id = p_instance_id;

       ELSE

          select sr_inventory_item_id, inventory_item_id
          bulk   collect into
                 l_sr_inv_item_id, l_inv_item_ids
          from   msc_item_id_lid
          where  sr_inventory_item_id in (p_inventory_item_id, p_match_item_id)
          AND    sr_instance_id = p_instance_id;

       END IF;

       IF l_inv_item_ids.count = 0  THEN

          RAISE NO_DATA_FOUND;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Exception no data found');
          END IF;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Number of item found := ' || l_sr_inv_item_id.count);

       END IF;

       FOR l_item_count in 1..l_sr_inv_item_id.count LOOP
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Item # := ' || l_item_count);
              msc_sch_wb.atp_debug('Sr inv id := ' || l_sr_inv_item_id(l_item_count));
              msc_sch_wb.atp_debug('Inv Id := ' || l_inv_item_ids(l_item_count));
           END IF;
           l_inv_item_id := l_inv_item_ids(l_item_count);
           EXIT WHEN l_sr_inv_item_id(l_item_count) = p_match_item_id;
       END LOOP;
    ELSE
    --bug 4091487 Added the if condition to drive query from  msc_system_items in case organization id is passed
    --            else go through msc_item_id_lid
       IF(p_organization_id is not null) THEN

          SELECT inventory_item_id
          INTO   l_inv_item_id
          FROM   msc_system_items
          WHERE  organization_id = p_organization_id
          AND    sr_inventory_item_id = p_inventory_item_id
          AND    plan_id = -1
          AND    sr_instance_id = p_instance_id;

       ELSE

          SELECT inventory_item_id
          INTO   l_inv_item_id
          FROM   msc_item_id_lid
          WHERE  sr_inventory_item_id = p_inventory_item_id
          AND    sr_instance_id = p_instance_id;

       END IF;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('l_inv_item_id := ' || l_inv_item_id);
       msc_sch_wb.atp_debug('End get_inv_item_id');
    END IF;

  return l_inv_item_id;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  /*
  4091487 Added the if condition to see if no items are present in msc_item_id_lid
  raise TRY ATP Later other wise raise collections error.
  */
 IF(p_organization_id is null) THEN
    Select count(*) into l_count from msc_item_id_lid;
    IF l_count > 0 THEN
      return null;
    ELSE
      return -1;
    END IF;
 ELSE
    return null;
 END IF;

WHEN OTHERS THEN
 IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('error in get_inv_item_id');
   msc_sch_wb.atp_debug('get_inv_item_id: ' || 'sqlerrm : '||sqlerrm);
 END IF;
 return null;
END get_inv_item_id;


FUNCTION get_supplier_name (p_instance_id            IN NUMBER,
                            p_supplier_id            IN NUMBER)
RETURN VARCHAR2
IS
l_supplier_name         VARCHAR2(80);

BEGIN

        SELECT partner_name
        INTO   l_supplier_name
        FROM   msc_trading_partners s
        WHERE  s.partner_id = p_supplier_id;

  return l_supplier_name;

EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_supplier_name;


FUNCTION get_supplier_site_name (p_instance_id            IN NUMBER,
                                 p_supplier_site_id       IN NUMBER)
RETURN VARCHAR2
IS
l_supplier_site_name         VARCHAR2(80);

BEGIN

    SELECT TP_SITE_CODE
    INTO   l_supplier_site_name
    FROM   msc_trading_partner_sites
    WHERE  PARTNER_SITE_ID = p_supplier_site_id;

  return l_supplier_site_name;
EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_supplier_site_name;


FUNCTION get_location_code (p_instance_id            IN NUMBER,
                            p_location_id            IN NUMBER)
RETURN VARCHAR2
IS
l_location_code         VARCHAR2(20);

BEGIN

  return null;

EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_location_code;


FUNCTION get_sd_source_name (p_instance_id            IN NUMBER,
                             p_sd_type                IN NUMBER,
                             p_sd_source_type         IN NUMBER)
RETURN VARCHAR2
IS
l_sd_source_name         VARCHAR2(80);

BEGIN
  SELECT MEANING
  into l_sd_source_name
  FROM MFG_LOOKUPS
  WHERE LOOKUP_TYPE = DECODE(p_sd_type, 2, 'MRP_ORDER_TYPE',
                             DECODE(p_sd_source_type,
                                    1, 'MRP_PLANNED_ORDER_DEMAND',
                                    3, 'MRP_PLANNED_ORDER_DEMAND',
                                   25, 'MRP_PLANNED_ORDER_DEMAND',
                                    'MRP_DEMAND_ORIGINATION'))
  AND LOOKUP_CODE = p_sd_source_type   ;

  return l_sd_source_name;

EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END get_sd_source_name;


FUNCTION prev_work_day(p_organization_id        IN  NUMBER,
                       p_instance_id            IN  NUMBER,
                       p_date                   IN  DATE)
RETURN DATE
IS
l_date      DATE;

BEGIN
    SELECT  cal.prior_date
    INTO    l_date
    FROM    msc_calendar_dates  cal,
            msc_trading_partners tp
    WHERE   cal.exception_set_id = tp.calendar_exception_set_id
    AND     cal.calendar_code = tp.calendar_code
    AND     cal.calendar_date = TRUNC(p_date)
    AND     cal.sr_instance_id = tp.sr_instance_id
    AND     tp.sr_instance_id = p_instance_id
    AND     tp.partner_type = 3
    AND     tp.sr_tp_id = p_organization_id;

  return l_date;
EXCEPTION WHEN NO_DATA_FOUND THEN
  return null;
END prev_work_day;


FUNCTION MPS_ATP(p_desig_id        IN  NUMBER)

RETURN NUMBER
IS

l_valid		PLS_INTEGER := 0;
BEGIN

    BEGIN
        SELECT  '1'
        INTO    l_valid
        FROM    MSC_DESIGNATORS
        WHERE   INVENTORY_ATP_FLAG = 1
        AND     DESIGNATOR_TYPE = 2
        AND     DESIGNATOR_ID = p_desig_id;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_valid := 0;
    END;

    RETURN l_valid;
END MPS_ATP;


FUNCTION Get_Designator(p_desig_id        IN  NUMBER)

RETURN VARCHAR2
IS

l_designator         VARCHAR2(10);
BEGIN

    BEGIN
        SELECT  designator
        INTO    l_designator
        FROM    MSC_DESIGNATORS
        WHERE   DESIGNATOR_ID = p_desig_id;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_designator := NULL;
    END;

    return l_designator;
END Get_Designator;


FUNCTION Get_MPS_Demand_Class(p_desig_id        IN  NUMBER)
RETURN VARCHAR2

IS
l_demand_class	 VARCHAR2(34);

BEGIN
    BEGIN
        SELECT  demand_class
        INTO    l_demand_class
        FROM    MSC_DESIGNATORS
        WHERE   DESIGNATOR_ID = p_desig_id;
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_demand_class := NULL;
    END;

    return l_demand_class;
END Get_MPS_Demand_Class;


FUNCTION NEXT_WORK_DAY_SEQNUM(p_organization_id        IN  NUMBER,
                       p_instance_id            IN  NUMBER,
                       p_date                   IN  DATE)
RETURN number
IS
l_seq_num      number;

BEGIN
    SELECT C.NEXT_SEQ_NUM
    INTO   l_seq_num
    FROM   MSC_CALENDAR_DATES C,
           MSC_TRADING_PARTNERS TP
    WHERE  TP.SR_TP_ID = p_organization_id
    AND    TP.SR_INSTANCE_ID = p_instance_id
    AND    TP.PARTNER_TYPE = 3
    AND    C.CALENDAR_CODE = TP.CALENDAR_CODE
    AND    C.EXCEPTION_SET_ID = TP.CALENDAR_EXCEPTION_SET_ID
    AND    C.SR_INSTANCE_ID = TP.SR_INSTANCE_ID
    AND    C.CALENDAR_DATE = TRUNC(p_date);

    return l_seq_num;
END NEXT_WORK_DAY_SEQNUM;


FUNCTION get_tolerance_percentage(
                                   p_instance_id        IN NUMBER,
                                   p_plan_id            IN NUMBER,
                                   p_inventory_item_id  IN NUMBER,
                                   p_organization_id    IN NUMBER,
                                   p_supplier_id        IN NUMBER,
                                   p_supplier_site_id   IN NUMBER,
                                   p_seq_num_difference  IN NUMBER -- For ship_rec_cal
                                 )
RETURN NUMBER
IS

v_tolerance_percent     NUMBER;
v_fence_days 		NUMBER;

BEGIN

-- Rewriting the SQL as part of ship_rec_cal project.
SELECT tolerance_percentage
INTO   v_tolerance_percent
FROM   (SELECT  tolerance_percentage
	FROM   msc_supplier_flex_fences
	WHERE  fence_days <= p_seq_num_difference
	AND    sr_instance_id = p_instance_id
	AND    plan_id = p_plan_id
	AND    organization_id = p_organization_id
	AND    inventory_item_id = p_inventory_item_id
	AND    supplier_id = p_supplier_id
	AND    NVL(supplier_site_id, -1) = NVL(p_supplier_site_id, -1)
	ORDER BY fence_days desc
	)
WHERE  ROWNUM = 1;

return v_tolerance_percent/100;

EXCEPTION WHEN NO_DATA_FOUND THEN
  return NULL;
END get_tolerance_percentage ;


FUNCTION Get_Order_Number(p_supply_id        IN  NUMBER,
                          p_plan_id          IN  NUMBER)

RETURN VARCHAR2

IS

l_order_number         VARCHAR2(62);
BEGIN

    BEGIN
        SELECT  order_number
        INTO    l_order_number
        FROM    MSC_SUPPLIES
        WHERE   plan_id = p_plan_id
        AND     transaction_id = p_supply_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_order_number := NULL;
    END;

    return l_order_number;
END Get_Order_Number;


FUNCTION Get_Order_Type(p_supply_id        IN  NUMBER,
                          p_plan_id          IN  NUMBER)

RETURN NUMBER

IS

l_order_type         number;
BEGIN

    BEGIN
        SELECT  order_type
        INTO    l_order_type
        FROM    MSC_SUPPLIES
        WHERE   plan_id = p_plan_id
        AND     transaction_id = p_supply_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_order_type := NULL;
    END;

    return l_order_type;
END Get_Order_Type;

-- savirine added parameters p_session_id and p_partner_site_id on Sep 24, 2001.

FUNCTION get_interloc_transit_time (p_from_location_id IN NUMBER,
                                    p_from_instance_id IN NUMBER,
                                    p_to_location_id   IN NUMBER,
                                    p_to_instance_id   IN NUMBER,
                                    p_ship_method      IN VARCHAR2,
                                    p_session_id IN NUMBER,
                                    p_partner_site_id IN NUMBER)
return NUMBER IS

l_intransit_time	NUMBER;
l_level			NUMBER;

-- ngoel 9/25/2001, need to select most specific lead time based on regions
CURSOR	c_lead_time
IS
SELECT  intransit_time,
	((10 * (10 - mrt.region_type)) + DECODE(mrt.zone_flag, 'Y', 1, 0)) region_level
FROM    msc_interorg_ship_methods mism,
	msc_regions_temp mrt
WHERE   mism.plan_id = -1
AND     mism.from_location_id = p_from_location_id
AND     mism.sr_instance_id = p_from_instance_id
AND     mism.sr_instance_id2 = p_to_instance_id
AND     mism.ship_method = p_ship_method
AND     mism.to_region_id = mrt.region_id
AND     mrt.session_id = p_session_id
AND     mrt.partner_site_id = p_partner_site_id
ORDER BY 2;
BEGIN
      BEGIN
         -- bug 2958287
         SELECT  intransit_time
         INTO    l_intransit_time
         FROM    msc_interorg_ship_methods
         WHERE   plan_id = -1
         AND     from_location_id = p_from_location_id
         AND     sr_instance_id = p_from_instance_id
         AND     to_location_id = p_to_location_id
         AND     sr_instance_id2 = p_to_instance_id
         AND     ship_method = p_ship_method
         AND     to_region_id is null
         AND     rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	     -- savirine added the following select statement on Sep 24, 2001
	     OPEN c_lead_time;
	     FETCH c_lead_time INTO l_intransit_time, l_level;
	     CLOSE c_lead_time;
      END;
      return l_intransit_time;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return null;
END get_interloc_transit_time;


FUNCTION Calc_Arrival_date(
                org_id                  IN NUMBER,
                instance_id             IN NUMBER,
		customer_id		IN NUMBER,
                bucket_type             IN NUMBER,
                sch_ship_date           IN DATE,
                req_arrival_date        IN DATE,
                delivery_lead_time      IN NUMBER

) RETURN DATE IS

l_offset_date   date;

-- This function is used to calculate the arrival date based
-- on given scheduled_ship_date and del_lead_time- Used in
---USED in view MRP_ATP_SCHEDULE_TEMP_V

BEGIN
	IF (customer_id IS NOT NULL) THEN
		 RETURN SCH_SHIP_DATE + NVL(delivery_lead_time,0);
	ELSE
        	l_offset_date := MSC_CALENDAR.DATE_OFFSET (org_id,
                                                  instance_id,
                                                 bucket_type,
                                                 sch_ship_date,
                                                NVL(delivery_lead_time, 0));

        	--- If arrival date is provided and offsetted arrival date is
        	--- less than the requested_arrival_date then we return arrival date else
        	--- we return the offseted date.
        	IF ((req_arrival_date IS NOT NULL) AND (l_offset_date < req_arrival_date)) THEN

               		 RETURN req_arrival_date;
        	ELSE
                	RETURN l_offset_date;
			--RETURN '21-APR-2001';
        	END IF;
	END IF;
EXCEPTION
        WHEN OTHERS THEN
                RETURN sch_ship_date + delivery_lead_time;
END Calc_Arrival_date;


-- ngoel 9/28/2001, added this function for use in View MSC_SCATP_SOURCES_V to support
-- Region Level Sourcing.

FUNCTION Get_Session_id
RETURN NUMBER
IS
BEGIN
    RETURN order_sch_wb.debug_session_id;
END Get_Session_id;

-- rajjain 02/19/2003 Bug 2788302 Begin
--pumehta added this function to get process_sequence_id to be populated when
--adding a planned order for Make Case.
FUNCTION get_process_seq_id(
                             p_plan_id           IN NUMBER,
                             p_item_id           IN NUMBER,
                             p_organization_id   IN NUMBER,
                             p_sr_instance_id    IN NUMBER,
                             p_new_schedule_date IN DATE
) RETURN NUMBER
IS
l_process_seq_id NUMBER;
BEGIN
        msc_sch_wb.atp_debug('Selecting Process Sequence ID');
        Select process_sequence_id
        into l_process_seq_id
        from msc_process_effectivity prc
        where prc.plan_id = p_plan_id
        and   prc.item_id = p_item_id
        and   prc.organization_id = p_organization_id
        and   prc.sr_instance_id = p_sr_instance_id
        and   trunc(prc.effectivity_date) <= trunc(p_new_schedule_date)
        and   trunc(nvl(prc.disable_date,p_new_schedule_date))
               >= trunc(p_new_schedule_date)
        and   prc.preference = 1;
        RETURN l_process_seq_id;
EXCEPTION
 WHEN OTHERS THEN
       msc_sch_wb.atp_debug('Get_Process_Seq_Id: ' || 'could not find process seq id,returning null');
       return NULL;
END get_process_seq_id;
-- rajjain 02/19/2003 Bug 2788302 End

END MSC_ATP_FUNC;

/
