--------------------------------------------------------
--  DDL for Package Body MSC_ATP_PEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_PEG" AS
/* $Header: MSCAPEGB.pls 120.2.12010000.2 2009/12/23 11:05:14 sbnaik ship $  */

MAXVALUE                CONSTANT NUMBER := 999999;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_PEG';

-- Bug 3344102 Allocation related global variables.
G_ALLOC_ATP                     VARCHAR2(1);
G_CLASS_HRCHY                   NUMBER;
G_ALLOC_METHOD                  NUMBER;
-- End Bug 3344102

-- Bug 3701093 Constants to mark how the Forecasts have been consumed.
C_CONFIG_FCST_CONSUMED          NUMBER := 2;
C_MODEL_FCST_CONSUMED           NUMBER := 1;
C_NO_FCST_CONSUMED              NUMBER := 0;
-- End Bug 3701093
-- Control for stopping calculation of relief_quantities.
C_ZERO_APPROXIMATOR             NUMBER := 0.000001;

/* Currently the ATP Pegging Record Types will be defined local to this package. */
-- This record will hold the ATP simplified Pegging Data.
-- Corresponds to the table msc_atp_pegging
TYPE ATP_Simple_Peg_Typ is RECORD (
     reference_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     base_item_id            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     inventory_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     plan_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sr_instance_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     organization_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     bom_item_type           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fixed_lt                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     variable_lt             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sales_order_qty         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sales_order_line_id     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_source_type      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),--cmro
     transaction_date        MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     demand_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     disposition_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_class            MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
     consumed_qty            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     overconsumption_qty     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     allocated_quantity      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     tot_relief_qty          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     resource_id             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     department_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     resource_hours          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     daily_resource_hours    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     start_date              MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     end_date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     relief_type             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     relief_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     daily_relief_qty        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     end_pegging_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     pegging_id              MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     prev_pegging_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- CTO_PF_PRJ changes.
     end_demand_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- CTO-PF
     atf_date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     product_family_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- Bug 3805136 -- Add end_item_usage to handle no forecast consumption.
     end_item_usage          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- Exclude flag helps in excluding supplies
     -- during relef data calculation.
     exclude_flag            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
     -- End Bug 3805136
   );

-- This record will hold the Detailed ATP Pegging Data.
-- Corresponds to the table msc_atp_detail_peg_temp
TYPE ATP_Detail_Peg_Typ is RECORD (
     reference_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     base_item_id            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     inventory_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     plan_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sr_instance_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     organization_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     end_item_usage          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     bom_item_type           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fixed_lt                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     variable_lt             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sales_order_line_id     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_source_type      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),--cmro
     sales_order_qty         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_date             MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     demand_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     disposition_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     demand_class            MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
     demand_type             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     original_demand_id      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fcst_organization_id    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     forecast_qty            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     consumed_qty            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     overconsumption_qty     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     process_seq_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_date             MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     supply_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     allocated_quantity      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     tot_relief_qty          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_type             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     firm_planned_type       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     release_status          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     exclude_flag            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     order_number            MRP_ATP_PUB.char62_arr := MRP_ATP_PUB.char62_arr(),
     end_pegging_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     pegging_id              MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     prev_pegging_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- CTO_PF_PRJ changes.
     end_demand_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- CTO-PF
     atf_date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     product_family_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
   );

-- This record is for holding data obtained from msc_forecast_updates
-- and msc_system_items.
TYPE ATP_Fcst_Cons_Typ is RECORD (
     plan_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sr_instance_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     inventory_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     parent_item_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     organization_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fcst_organization_id    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fcst_demand_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sales_order_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sales_order_qty         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     forecast_qty            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     consumed_qty            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     overconsumption_qty     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     bom_item_type           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     fixed_lt                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     variable_lt             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     -- Bug 3701093 Flag to indicate if config item's forecast is consumed (2)
     -- or if model's forecast is overconsumed (1) or no forecast consumption (0).
     cons_config_mod_flag    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
    );

-- This record holds data resource_requirements
-- and corrsponding relief data.
TYPE ATP_Res_Peg_Typ is RECORD (
     plan_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     sr_instance_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     organization_id         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     inventory_item_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     supply_id               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     resource_id             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     department_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     resource_hours          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     daily_resource_hours    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     start_date              MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     end_date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
     relief_type             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     relief_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
     daily_relief_qty        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
    );

-- Bug 3750638
-- Fix for Multiple (N) Level of Config Items using Loop
-- Define Record Type to correspond to a specific Sales Order Demand.
-- This corresponds to the CURSOR defined in Procedure Generate_Simplified_Pegging.

TYPE ATP_End_Config_Dmd_Typ is RECORD (
   ITEM_NAME                VARCHAR2(256),
   INVENTORY_ITEM_ID        NUMBER,
   SR_INVENTORY_ITEM_ID     NUMBER,
   SR_INSTANCE_ID           NUMBER,
   BASE_ITEM_ID             NUMBER,
   SALES_ORDER_LINE_ID      NUMBER,
   DEMAND_SOURCE_TYPE       NUMBER,
   DEMAND_CLASS             VARCHAR2(34),
   DEMAND_ID                NUMBER
  );

-- Bug 3750638
-- Fix for Multiple (N) Level of Config Items using Loop
-- Define PL/SQL Record of Arrays Type to correspond to
-- Config Item Supplies being processed in the Pegging Retrieval loop.
TYPE ATP_Config_Sup_Typ is RECORD (
   INVENTORY_ITEM_ID        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   SR_INSTANCE_ID           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   BASE_ITEM_ID             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   SALES_ORDER_LINE_ID      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   DEMAND_SOURCE_TYPE       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   END_DEMAND_ID            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   SUPPLY_ID                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   PEGGING_ID               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
   END_PEGGING_ID           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
  );
-- End Bug 3750638

/* Procedures for CTO Re-architecture and Resource Capacity Enhancements */

-- Procedure to update the summary flag for a plan.
PROCEDURE Update_Summary_Flag (
        p_plan_id       IN      number,
        p_status        IN      number,
        x_return_status OUT NOCOPY    varchar2
) IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
    msc_util.msc_log ('*****--- Update_Summary_Flag ---*****');
    msc_util.msc_log (' Plan ID : '|| p_plan_id || '   Status : ' || p_status);
   END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    update msc_plans
       set summary_flag = p_status
     where plan_id = p_plan_id;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Cannot Update. Error : ' || sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Summary_Flag;

--p_index is the length by which the record has to be extended, default is 1.
-- This procedure extends the ATP Simple Peg Record of Tables by p_index.
PROCEDURE Extend_Atp_Peg (atp_peg_tab      IN  OUT NOCOPY ATP_Simple_Peg_Typ,
                          x_return_status  OUT NOCOPY     VARCHAR2,
                          p_index          IN             NUMBER := 1
                         )
IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** Begin Extend_Atp_Peg Procedure *****');
      msc_util.msc_log ('p_index : ' || p_index);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   atp_peg_tab.reference_item_id.Extend(p_index);
   atp_peg_tab.base_item_id.Extend(p_index);
   atp_peg_tab.inventory_item_id.Extend(p_index);
   atp_peg_tab.plan_id.Extend(p_index);
   atp_peg_tab.sr_instance_id.Extend(p_index);
   atp_peg_tab.organization_id.Extend(p_index);
   atp_peg_tab.bom_item_type.Extend(p_index);
   atp_peg_tab.fixed_lt.Extend(p_index);
   atp_peg_tab.variable_lt.Extend(p_index);
   atp_peg_tab.sales_order_qty.Extend(p_index);
   atp_peg_tab.sales_order_line_id.Extend(p_index);
   atp_peg_tab.demand_source_type.Extend(p_index);--cmro
   atp_peg_tab.transaction_date.Extend(p_index);
   atp_peg_tab.demand_id.Extend(p_index);
   atp_peg_tab.demand_quantity.Extend(p_index);
   atp_peg_tab.disposition_id.Extend(p_index);

   atp_peg_tab.demand_class.Extend(p_index);

   atp_peg_tab.consumed_qty.Extend(p_index);
   atp_peg_tab.overconsumption_qty.Extend(p_index);
   atp_peg_tab.supply_id.Extend(p_index);
   atp_peg_tab.supply_quantity.Extend(p_index);
   atp_peg_tab.allocated_quantity.Extend(p_index);
   atp_peg_tab.tot_relief_qty.Extend(p_index);

   atp_peg_tab.resource_id.Extend(p_index);
   atp_peg_tab.department_id.Extend(p_index);
   atp_peg_tab.resource_hours.Extend(p_index);
   atp_peg_tab.daily_resource_hours.Extend(p_index);
   atp_peg_tab.start_date.Extend(p_index);
   atp_peg_tab.end_date.Extend(p_index);
   atp_peg_tab.relief_type.Extend(p_index);
   atp_peg_tab.relief_quantity.Extend(p_index);

   atp_peg_tab.daily_relief_qty.Extend(p_index);

   atp_peg_tab.end_pegging_id.Extend(p_index);
   atp_peg_tab.pegging_id.Extend(p_index);
   atp_peg_tab.prev_pegging_id.Extend(p_index);
   -- CTO_PF_PRJ changes.
   atp_peg_tab.end_demand_id.Extend(p_index);
   -- CTO-PF
   atp_peg_tab.atf_date.Extend(p_index);
   atp_peg_tab.product_family_id.Extend(p_index);
   -- Bug 3805136 -- Add end_item_usage to handle no forecast consumption.
   atp_peg_tab.end_item_usage.Extend(p_index);
   -- Exclude flag helps in excluding supplies
   -- during relef data calculation.
   atp_peg_tab.exclude_flag.Extend(p_index);
   -- End Bug 3805136

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** End Extend_Atp_Peg Procedure *****');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log ('Extend_Atp_Peg: Problems in Extending record ERROR:'|| sqlerrm);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Extend_Atp_Peg;

-- This procedure initializes the ATP PEgging PL/SQL Array
PROCEDURE Init_Atp_Peg (atp_peg_tab      IN  OUT NOCOPY ATP_Simple_Peg_Typ,
                          x_return_status  OUT NOCOPY     VARCHAR2
                         )
IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** Begin Extend_Atp_Peg Procedure *****');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

     atp_peg_tab.reference_item_id    :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.base_item_id         :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.inventory_item_id    :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.plan_id              :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.sr_instance_id       :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.organization_id      :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.bom_item_type        :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.fixed_lt             :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.variable_lt          :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.sales_order_qty      :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.sales_order_line_id  :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.demand_source_type   :=   MRP_ATP_PUB.number_arr();--cmro
     atp_peg_tab.transaction_date     :=   MRP_ATP_PUB.date_arr();
     atp_peg_tab.demand_id            :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.demand_quantity      :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.disposition_id       :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.demand_class         :=   MRP_ATP_PUB.char30_arr();
     atp_peg_tab.consumed_qty         :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.overconsumption_qty  :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.supply_id            :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.supply_quantity      :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.allocated_quantity   :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.tot_relief_qty       :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.resource_id          :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.department_id        :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.resource_hours       :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.daily_resource_hours :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.start_date           :=   MRP_ATP_PUB.date_arr();
     atp_peg_tab.end_date             :=   MRP_ATP_PUB.date_arr();
     atp_peg_tab.relief_type          :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.relief_quantity      :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.daily_relief_qty     :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.end_pegging_id       :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.pegging_id           :=   MRP_ATP_PUB.number_arr();
     atp_peg_tab.prev_pegging_id      :=   MRP_ATP_PUB.number_arr();
     -- CTO_PF_PRJ changes.
     atp_peg_tab.end_demand_id        :=   MRP_ATP_PUB.number_arr();
     -- CTO-PF
     atp_peg_tab.atf_date             :=   MRP_ATP_PUB.date_arr();
     atp_peg_tab.product_family_id    :=   MRP_ATP_PUB.number_arr();
     -- Bug 3805136 -- Add end_item_usage to handle no forecast consumption.
     atp_peg_tab.end_item_usage       :=   MRP_ATP_PUB.number_arr();
     -- Exclude flag helps in excluding supplies
     -- during relef data calculation.
     atp_peg_tab.exclude_flag         :=   MRP_ATP_PUB.number_arr();
     -- End Bug 3805136

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** End Init_Atp_Peg Procedure *****');
      msc_util.msc_log('Init_Atp_Peg Rowcount is ' || atp_peg_tab.reference_item_id.COUNT);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log ('Init_Atp_Peg: Problems in Extending record ERROR:'|| sqlerrm);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Init_Atp_Peg;

-- This procedure extends the ATP Detail Peg Record of Tables by p_index.
PROCEDURE Extend_Atp_Peg_Det (atp_peg_det      IN  OUT NOCOPY ATP_Detail_Peg_Typ,
                              x_return_status  OUT NOCOPY     VARCHAR2,
                              p_index          IN             NUMBER := 1
                              )
IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** Begin Extend_Atp_Peg_Det Procedure *****');
      msc_util.msc_log ('p_index : ' || p_index);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   atp_peg_det.reference_item_id.Extend(p_index);
   atp_peg_det.base_item_id.Extend(p_index);
   atp_peg_det.inventory_item_id.Extend(p_index);
   atp_peg_det.plan_id.Extend(p_index);
   atp_peg_det.sr_instance_id.Extend(p_index);
   atp_peg_det.organization_id.Extend(p_index);
   atp_peg_det.bom_item_type.Extend(p_index);
   atp_peg_det.end_item_usage.Extend(p_index);
   atp_peg_det.fixed_lt.Extend(p_index);
   atp_peg_det.variable_lt.Extend(p_index);
   atp_peg_det.sales_order_qty.Extend(p_index);
   atp_peg_det.sales_order_line_id.Extend(p_index);
   atp_peg_det.demand_source_type.Extend(p_index); --cmro
   atp_peg_det.demand_id.Extend(p_index);
   atp_peg_det.demand_date.Extend(p_index);
   atp_peg_det.demand_quantity.Extend(p_index);
   atp_peg_det.disposition_id.Extend(p_index);

   atp_peg_det.demand_class.Extend(p_index);
   atp_peg_det.demand_type.Extend(p_index);
   atp_peg_det.original_demand_id.Extend(p_index);

   atp_peg_det.fcst_organization_id.Extend(p_index);
   atp_peg_det.forecast_qty.Extend(p_index);
   atp_peg_det.consumed_qty.Extend(p_index);
   atp_peg_det.overconsumption_qty.Extend(p_index);

   atp_peg_det.process_seq_id.Extend(p_index);
   atp_peg_det.supply_id.Extend(p_index);
   atp_peg_det.supply_date.Extend(p_index);
   atp_peg_det.supply_quantity.Extend(p_index);
   atp_peg_det.allocated_quantity.Extend(p_index);
   atp_peg_det.tot_relief_qty.Extend(p_index);

   atp_peg_det.supply_type.Extend(p_index);
   atp_peg_det.firm_planned_type.Extend(p_index);
   atp_peg_det.release_status.Extend(p_index);
   atp_peg_det.exclude_flag.Extend(p_index);

   atp_peg_det.order_number.Extend(p_index);

   atp_peg_det.end_pegging_id.Extend(p_index);
   atp_peg_det.pegging_id.Extend(p_index);
   atp_peg_det.prev_pegging_id.Extend(p_index);
   -- CTO_PF_PRJ changes.
   atp_peg_det.end_demand_id.Extend(p_index);
   --CTO-PF
   atp_peg_det.atf_date.Extend(p_index);
   atp_peg_det.product_family_id.Extend(p_index);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log('***** End Extend_Atp_Peg_Det Procedure *****');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log ('Extend_Atp_Peg_Det: Problems in Extending record ERROR:'|| sqlerrm);
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Extend_Atp_Peg_Det;


-- This procedure calculates the relief quantities for items.
PROCEDURE Calculate_Relief_Quantities ( x_atp_peg_tab         IN  OUT NoCopy ATP_Simple_Peg_Typ,
                                        p_pegging_id          IN             NUMBER,
                                        p_fixed_lt            IN             NUMBER,
                                        p_variable_lt         IN             NUMBER,
                                        p_tot_relief_qty      IN             NUMBER,
                                        -- Bug 3701093 Introducte relief ratio for pegging path.
                                        p_peg_relief_ratio    IN             NUMBER,
                                        -- Bug 3805136 Introduce offset_qty to alloc_qty ratio
                                        p_peg_alloc_rel_ratio IN             NUMBER,
                                        p_peg_tot_rel_qty     IN             NUMBER,
                                        p_end_item_usage      IN             NUMBER,
                                        -- End Bug 3805136
                                        -- Bug 3761805 Introduce inventory_item_id for
                                        -- config item, end_pegging_id, supply_id to be processed.
                                        p_inventory_item_id   IN             NUMBER,
                                        p_end_pegging_id      IN             NUMBER,
                                        p_supply_id           IN             NUMBER,
                                        -- End Bug 3761805
                                        p_transaction_date    IN             DATE,
                                        x_return_status       IN OUT NoCopy  VARCHAR2  )
IS
l_prev_peg_id             NUMBER;
i                         NUMBER;
j                         NUMBER;
l_sales_order_qty         NUMBER;
l_inventory_item_id       NUMBER;
l_relief_quantity         NUMBER;
l_tot_relief_qty          NUMBER;
l_rem_relief_qty          NUMBER;
l_row_count               NUMBER;
l_process_lt              NUMBER;

-- Bug 3761805 Introduce a variable to track how much offsets have already been
-- accounted for already.
l_proc_relief_tot         NUMBER;
l_peg_relief_ratio        NUMBER;
-- Bug 3805136 Ratio of Relief Qty to Allocated Qty.
l_peg_alloc_rel_ratio     NUMBER;
l_proc_supply_flag        NUMBER;  -- Values 0 False 1 True
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('***** Begin Calculate_Relief_Quantities Procedure *****');
       msc_util.msc_log (' p_pegging_id : '|| p_pegging_id);
       msc_util.msc_log (' p_fixed_lt : '|| p_fixed_lt);
       msc_util.msc_log (' p_variable_lt : '|| p_variable_lt);
       msc_util.msc_log (' p_tot_relief_qty : '|| p_tot_relief_qty);
       msc_util.msc_log (' p_inventory_item_id : '|| p_inventory_item_id);
       msc_util.msc_log (' p_end_pegging_id : '|| p_end_pegging_id);
       msc_util.msc_log (' p_supply_id : '|| p_supply_id);
       msc_util.msc_log (' Calculate_Relief_Quantities Transaction Date for Config : '
                                                                  || p_transaction_date);
       msc_util.msc_log (' Relief Ratio for this Pegging Path p_peg_relief_ratio: '
                                                                  || p_peg_relief_ratio);
       msc_util.msc_log (' Relief_Qty to Alloc_Qty Ratio for Pegging Path p_peg_alloc_rel_ratio: '
                                                                  || p_peg_alloc_rel_ratio);
       msc_util.msc_log (' Total Relief_Qty of parent for Pegging Path p_peg_tot_rel_qty: '
                                                                  || p_peg_tot_rel_qty);
       msc_util.msc_log (' End Item Usage of parent -- p_end_item_usage: '
                                                                  || p_end_item_usage);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_row_count := x_atp_peg_tab.pegging_id.COUNT;

    IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log (' l_row_count : '|| l_row_count);
    END IF;

    FOR  i in 1..l_row_count
    LOOP

       IF (x_atp_peg_tab.pegging_id(i) = p_pegging_id AND
           -- Bug 3761805
           -- Adhere to End Peg Path
           x_atp_peg_tab.end_pegging_id(i) = p_end_pegging_id AND
           --- Only process the top level pegging in supply chain
           x_atp_peg_tab.prev_pegging_id(i) IS NULL ) THEN

          -- if the item is a configuration item
          -- First set the inventory_item_id to be processed.
          l_inventory_item_id := x_atp_peg_tab.inventory_item_id(i);
          -- Set the total relief_quantity
          -- Bug 3701093
          l_tot_relief_qty := p_tot_relief_qty;
          --l_tot_relief_qty := x_atp_peg_tab.tot_relief_qty(i);
          -- Reset the current relief_quantity to 0
          l_relief_quantity := 0;
          -- Initilize the remaining relief_qty
          l_rem_relief_qty := l_tot_relief_qty ;

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_util.msc_log (' Pegging Id Match : ' || p_pegging_id);
             msc_util.msc_log (' l_inventory_item_id : '|| l_inventory_item_id);
             msc_util.msc_log (' l_tot_relief_qty : '|| l_tot_relief_qty);
             msc_util.msc_log (' x_atp_peg_tab.consumed_qty(i) : '||
                                                x_atp_peg_tab.consumed_qty(i));
             msc_util.msc_log (' x_atp_peg_tab.allocated_quantity(i) : '||
                                                x_atp_peg_tab.allocated_quantity(i));
          END IF;

          IF (x_atp_peg_tab.relief_type(i) = 2 ) THEN

               x_atp_peg_tab.relief_quantity(i) :=
                  GREATEST(l_rem_relief_qty,
                     -- Bug 3827097 Pick smallest of consumption - allocated_qty
                     -- and relief_quantity for this path.
                     p_peg_tot_rel_qty,
                   NVL(x_atp_peg_tab.consumed_qty(i), 0) -
                   x_atp_peg_tab.allocated_quantity(i) );

          ELSIF (x_atp_peg_tab.relief_type(i) = 3 ) THEN

                IF (l_rem_relief_qty = 0) THEN
                   x_atp_peg_tab.relief_quantity(i) :=  -1 * x_atp_peg_tab.demand_quantity(i);
                ELSE
                   x_atp_peg_tab.relief_quantity(i) :=
                          GREATEST(l_rem_relief_qty,
                                -1 * x_atp_peg_tab.demand_quantity(i) );
                END IF;

          END IF;
          -- Update the current relief_quantity
          l_relief_quantity := l_relief_quantity + x_atp_peg_tab.relief_quantity(i);
          -- Update the remaining relief_qty.
          l_rem_relief_qty := l_tot_relief_qty - l_relief_quantity;

          IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log (' Relief type : '|| x_atp_peg_tab.relief_type(i));
               msc_util.msc_log (' l_relief_quantity : '|| l_relief_quantity);
               msc_util.msc_log (' l_rem_relief_qty : '|| l_rem_relief_qty);
          END IF;
       ELSIF (NVL(x_atp_peg_tab.prev_pegging_id(i), -1) = p_pegging_id AND
              -- Bug 3761805 Honor the End Pegging Path.
              x_atp_peg_tab.end_pegging_id(i) = p_end_pegging_id) THEN

          -- First set the inventory_item_id to be processed.
          l_inventory_item_id := x_atp_peg_tab.inventory_item_id(i);
          -- Set the total relief_quantity
          -- Bug 3805136 Handle absence of forecast data.
          IF (x_atp_peg_tab.tot_relief_qty(i) IS NULL ) THEN
              -- x_atp_peg_tab.inventory_item_id(i) <> p_inventory_item_id) THEN
             IF (x_atp_peg_tab.bom_item_type(i) = 4 AND
                  x_atp_peg_tab.base_item_id(i) IS NOT NULL ) THEN
                -- Bug 3827097 Use the offset_qty/total_offset_qty ratio consistently.
                l_tot_relief_qty := p_tot_relief_qty *  p_peg_relief_ratio *
                                       x_atp_peg_tab.end_item_usage(i)/ p_end_item_usage;
                                    -- The Yield and Usage will be factored later.
                                    --x_atp_peg_tab.end_item_usage(i) * p_peg_relief_ratio;
                l_peg_alloc_rel_ratio := p_peg_alloc_rel_ratio;
                x_atp_peg_tab.tot_relief_qty(i) := p_tot_relief_qty *
                                       x_atp_peg_tab.end_item_usage(i)/ p_end_item_usage;
             ELSE
                -- Bug 3827097 Use the offset_qty/total_offset_qty ratio  consistently.
                l_tot_relief_qty := p_tot_relief_qty * p_peg_relief_ratio *
                                       x_atp_peg_tab.end_item_usage(i)/ p_end_item_usage;
                l_peg_alloc_rel_ratio := p_peg_alloc_rel_ratio;
             END IF;
          ELSE
             l_peg_alloc_rel_ratio := p_peg_alloc_rel_ratio;
             -- Bug 3827097 Dealing with Supply, Use Configuration Item's total_relief_qty
             IF (x_atp_peg_tab.relief_type(i) = 2) THEN
                l_tot_relief_qty := x_atp_peg_tab.tot_relief_qty(i) * p_peg_relief_ratio;
             ELSE  -- Dealing with Demand, Use parent Configuration Item's total_relief_qty
                -- Bug 3827097 Use the offset_qty/total_offset_qty ratio  consistently.
                l_tot_relief_qty := p_tot_relief_qty * p_peg_relief_ratio *
                                       x_atp_peg_tab.end_item_usage(i)/ p_end_item_usage;
             END IF;
             -- End Bug 3827097
          END IF;
          -- Config Item Forecast completely consumes demand
          IF (l_tot_relief_qty = 0) THEN
             -- estimate total relief_quantity.
             -- Bug 3827097 Use the offset_qty/total_offset_qty ratio  consistently.
             l_tot_relief_qty := p_tot_relief_qty *  p_peg_relief_ratio *
                                       x_atp_peg_tab.end_item_usage(i)/ p_end_item_usage;
             l_proc_supply_flag := 0; -- Flag that supplies should not get offset.
          ELSE
             -- Default create offsets for supply.
             l_proc_supply_flag := 1;
          END IF;
          -- Bug 3805136
          -- Reset the current relief_quantity to 0
          l_relief_quantity := 0;
          -- Initilize the remaining relief_qty
          l_rem_relief_qty := l_tot_relief_qty ;
          -- Bug 3761805
          -- Initialize the proc relief total
          l_proc_relief_tot := 0;

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_util.msc_log (' Previous Pegging_id Match : ' || x_atp_peg_tab.prev_pegging_id(i));
             msc_util.msc_log (' Pegging_id is : ' || x_atp_peg_tab.pegging_id(i));
             msc_util.msc_log (' l_inventory_item_id : '|| l_inventory_item_id);
             msc_util.msc_log (' Total Relief For Item : '|| x_atp_peg_tab.tot_relief_qty(i));
             msc_util.msc_log (' l_tot_relief_qty : '|| l_tot_relief_qty);
             msc_util.msc_log (' l_proc_supply_flag : '|| l_proc_supply_flag);
             msc_util.msc_log (' l_peg_alloc_rel_ratio : '|| l_peg_alloc_rel_ratio);
             msc_util.msc_log (' Relief_Type : '|| x_atp_peg_tab.relief_type(i) );
             msc_util.msc_log (' Relief_Quantity : '|| x_atp_peg_tab.relief_quantity(i) );
          END IF;
          -- Bug 3701093
          -- If the total relief quantity for the config Item Id is 0
          -- then set the relief quantity to 0 for the component.
          IF (p_tot_relief_qty = 0) THEN
             x_atp_peg_tab.relief_quantity(i) := 0;
             -- Re-set the total relief_quantity as well.
             -- so that any config item below this level will also not be offset
             x_atp_peg_tab.tot_relief_qty(i) := 0;
             IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log (' Force set of Relief_Qty : '||
                                           x_atp_peg_tab.relief_quantity(i));
               msc_util.msc_log (' Force Set of Tot Relief_Qty : '||
                                           x_atp_peg_tab.tot_relief_qty(i));
             END IF;
          -- End Bug 3701093 Changed IF to ELSIF below.
          -- Bug 3761805 Added relief_qty filter for performance.
          ELSIF (l_tot_relief_qty <> 0 AND x_atp_peg_tab.relief_quantity(i) IS NULL) THEN
          --ELSIF (l_tot_relief_qty <> 0 ) THEN
            -- nothing needs to be done if total relief qty is 0.
            FOR  j in 1..l_row_count
            -- Same item may show up multiple times hence two loops are needed.
            LOOP
              IF (x_atp_peg_tab.prev_pegging_id(j) = p_pegging_id AND
                  -- Bug 3761805 Honor the End Pegging Path.
                  x_atp_peg_tab.end_pegging_id(j) = p_end_pegging_id AND
                  x_atp_peg_tab.relief_type(j) = x_atp_peg_tab.relief_type(i) AND
                  ABS(l_tot_relief_qty) > ABS(l_proc_relief_tot) AND
                 -- End Bug 3761805
                  x_atp_peg_tab.inventory_item_id(j) = l_inventory_item_id AND
                  -- Bug 3362558 We need to calculate relief_quantity only if it
                  -- has not been already calculated.
                  x_atp_peg_tab.relief_quantity(j) IS NULL) THEN
                  -- The above conditions ensures that we are processing
                  -- the same item identified in the outer loop.
                  -- Hence even though i and j refer to different indexes
                  -- the item being processed is the same.


                 IF (x_atp_peg_tab.bom_item_type(i) = 4 AND
                     x_atp_peg_tab.base_item_id(i) IS NOT NULL ) THEN

                    -- if the item is a configuration item

                    IF (x_atp_peg_tab.relief_type(i) = 2
                       ) THEN

                      -- Bug 3805136 Once the complete offsets have been applied
                      IF (ABS(l_tot_relief_qty - l_relief_quantity) < C_ZERO_APPROXIMATOR) OR
                         -- Do not process excluded supplies
                         (NVL(x_atp_peg_tab.exclude_flag(j),0) = 1) OR
                         (l_proc_supply_flag = 0) THEN
                         -- Set the rest to 0 for rest of the peggings.
                         x_atp_peg_tab.relief_quantity(j) := 0;
                      ELSE
                        x_atp_peg_tab.relief_quantity(j) :=
                          GREATEST(l_rem_relief_qty,
                             NVL(x_atp_peg_tab.consumed_qty(j), 0) -
                                x_atp_peg_tab.allocated_quantity(j) )
                                -- Bug 3805136 Apply relief/alloc ratio
                                * l_peg_alloc_rel_ratio;
                      END IF;
                      -- End Bug 3805136
                      IF PG_DEBUG in ('Y', 'C') THEN
                         msc_util.msc_log (' x_atp_peg_tab.relief_quantity(j) : '||
                                                          x_atp_peg_tab.relief_quantity(j));
                      END IF;

                    ELSIF (x_atp_peg_tab.relief_type(i) = 3 ) THEN

                      -- Bug 3805136 Once the complete offsets have been applied
                      IF ABS(l_tot_relief_qty - l_relief_quantity) < C_ZERO_APPROXIMATOR THEN
                         -- Set the rest to 0 for rest of the peggings.
                         x_atp_peg_tab.relief_quantity(j) := 0;
                      ELSE
                        x_atp_peg_tab.relief_quantity(j) :=
                          GREATEST(l_rem_relief_qty,
                                -1 * x_atp_peg_tab.demand_quantity(j),
                                -- Bug 3362558 Get the mininimum of
                                -- demand_quantity and allocated_quantity
                                -1 * x_atp_peg_tab.allocated_quantity(j) )
                                -- Bug 3805136 Apply relief/alloc ratio
                                * l_peg_alloc_rel_ratio;
                      END IF;
                      -- End Bug 3805136

                    END IF;

                 ELSE -- for all others we are processing just the demands

                   -- Note Greatest is used against negative values
                   IF (x_atp_peg_tab.bom_item_type(i) in (1, 2) AND   -- Model or OC.
                       x_atp_peg_tab.disposition_id(i) = p_supply_id ) THEN
                       -- Bug 3362558 Also relieve Option Classes
                     IF PG_DEBUG in ('Y', 'C') THEN
                       msc_util.msc_log (' x_atp_peg_tab.consumed_qty(j) : '||
                                                           x_atp_peg_tab.consumed_qty(j));
                     END IF;
                     -- Bug 3805136 Once the complete offsets have been applied
                     IF ABS(l_tot_relief_qty - l_relief_quantity) < C_ZERO_APPROXIMATOR THEN
                        -- Set the rest to 0 for rest of the peggings.
                        x_atp_peg_tab.relief_quantity(j) := 0;
                     ELSE
                      x_atp_peg_tab.relief_quantity(j) :=
                         GREATEST(l_rem_relief_qty,
                          -1 * (NVL(x_atp_peg_tab.consumed_qty(j), 0) +
                         NVL(x_atp_peg_tab.overconsumption_qty(j), 0) ) )
                          -- Bug 3805136 Apply relief/alloc ratio
                                * l_peg_alloc_rel_ratio;
                     END IF;
                     -- End Bug 3805136

                   ELSIF x_atp_peg_tab.disposition_id(i) = p_supply_id THEN

                     -- Bug 3805136 Once the complete offsets have been applied
                     IF ABS(l_tot_relief_qty - l_relief_quantity) < C_ZERO_APPROXIMATOR THEN
                        -- Set the rest to 0 for rest of the peggings.
                        x_atp_peg_tab.relief_quantity(j) := 0;
                     ELSE
                       -- Otherwise Calculate the offset_quantity
                       x_atp_peg_tab.relief_quantity(j) :=
                          GREATEST(l_rem_relief_qty,
                                -1 * x_atp_peg_tab.demand_quantity(j),
                                -- Bug 3362558 Get the mininimum of
                                -- demand_quantity and allocated_quantity
                                -1 * x_atp_peg_tab.allocated_quantity(j) )
                          -- Bug 3805136 Apply relief/alloc ratio
                                * l_peg_alloc_rel_ratio;
                     END IF;
                     -- End Bug 3805136

                   END IF;
                 END IF;

                 -- Bug 3445664 Fix transaction date calculation

                 IF (x_atp_peg_tab.bom_item_type(j) = 2 OR  -- option class
                     x_atp_peg_tab.transaction_date(j) IS NULL) THEN -- phantom
                     -- Apply offset.
                     -- Old stuff l_process_lt := CEIL((p_fixed_lt +
                     -- Commented out                  (p_variable_lt
                     l_process_lt := CEIL((x_atp_peg_tab.fixed_lt(j) +
                                       (x_atp_peg_tab.variable_lt(j)
                                        * ABS(x_atp_peg_tab.relief_quantity(j)) ))
                                          -- Ensure Processing Lead Time calculation is
                                          -- consistent for both +ve and -ve reliefs
                                         * (1 + MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR));

                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log (' Calculate_Relief_Quantities Before calc. '
                            || 'Transaction Date for Item: ' || x_atp_peg_tab.transaction_date(j));
                     END IF;
                     x_atp_peg_tab.transaction_date(j) :=
                              MSC_CALENDAR.DATE_OFFSET
                                       (x_atp_peg_tab.organization_id(i),
                                        x_atp_peg_tab.sr_instance_id(i),
                                        1,
                                        p_transaction_date, -- Config Item's Transaction Date
                                         -1 * l_process_lt); -- negative offset

                     IF PG_DEBUG in ('Y', 'C') THEN
                        msc_util.msc_log('Calculate_Relief_Quantities: '
                            || 'l_mso_lead_time_factor := ' || MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR);
                        msc_util.msc_log('Calculate_Relief_Quantities: '
                            || 'Inventory Item Id := ' || x_atp_peg_tab.inventory_item_id(j));
                        msc_util.msc_log('Calculate_Relief_Quantities: '
                            || 'fixed_lt : = ' || x_atp_peg_tab.fixed_lt(j));
                        msc_util.msc_log('Calculate_Relief_Quantities: '
                            || 'variable_lt : = ' || x_atp_peg_tab.variable_lt(j));
                        msc_util.msc_log('Calculate_Relief_Quantities: '
                            || 'l_process_lt : = ' || l_process_lt);
                        msc_util.msc_log (' Calculate_Relief_Quantities '
                            || 'Transaction Date for Item: ' || x_atp_peg_tab.transaction_date(j));
                     END IF;
                 END IF;
                 --  End Bug 3445664 Fix transaction date calculation

                -- Update the current relief_quantity
                l_relief_quantity := l_relief_quantity + x_atp_peg_tab.relief_quantity(j);
                -- Update the remaining relief_qty.
                l_rem_relief_qty := l_tot_relief_qty - l_relief_quantity;

                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_util.msc_log (' l_relief_quantity : '|| l_relief_quantity);
                   msc_util.msc_log (' l_rem_relief_qty : '|| l_rem_relief_qty);
                END IF;
                -- Changed the exit condition to account for relief_ratio.
                -- Bug 3701093
                -- EXIT WHEN l_tot_relief_qty = l_relief_quantity;
                -- Bug 3805136 EXIT statement commented out.
                -- EXIT WHEN ABS(l_tot_relief_qty - l_relief_quantity) < C_ZERO_APPROXIMATOR;
                -- Once the total offsets are reached, rest is set to 0 above.
                -- End Bug 3805136
              -- Bug 3761805 Track the already processed reliefs.
              ELSIF (x_atp_peg_tab.prev_pegging_id(j) = p_pegging_id AND
                  x_atp_peg_tab.end_pegging_id(j) = p_end_pegging_id AND
                  x_atp_peg_tab.relief_type(j) = x_atp_peg_tab.relief_type(i) AND
                  x_atp_peg_tab.inventory_item_id(j) = l_inventory_item_id AND
                  x_atp_peg_tab.demand_id(j) = x_atp_peg_tab.demand_id(i) AND
                  x_atp_peg_tab.supply_id(j) = x_atp_peg_tab.supply_id(i) AND
                  x_atp_peg_tab.relief_quantity(j) IS NOT NULL) THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_util.msc_log (' l_proc_relief_tot Before : '|| l_proc_relief_tot);
                   msc_util.msc_log (' l_rem_relief_qty Before : '|| l_rem_relief_qty);
                END IF;
                -- Update the already processed relief_total.
                l_proc_relief_tot := l_proc_relief_tot + x_atp_peg_tab.relief_quantity(j);
                -- Update the remaining relief_qty.
                l_rem_relief_qty := l_tot_relief_qty - x_atp_peg_tab.relief_quantity(j);
                IF PG_DEBUG in ('Y', 'C') THEN
                   msc_util.msc_log (' l_proc_relief_tot After : '|| l_proc_relief_tot);
                   msc_util.msc_log (' l_rem_relief_qty After : '|| l_rem_relief_qty);
                END IF;
              -- End Bug 3761805
              END IF;


            END LOOP;

           -- Bug 3805136 (Config Item Forecast completely consumes balance SO QTY)
          ELSE

             -- Create adjustments against Config Demands but none against Config supply.
             IF (x_atp_peg_tab.bom_item_type(i) = 4 AND
                 x_atp_peg_tab.base_item_id(i) IS NOT NULL AND
                 x_atp_peg_tab.relief_type(i) = 3  AND
                 x_atp_peg_tab.disposition_id(i) = p_supply_id AND
                 l_tot_relief_qty = 0 AND x_atp_peg_tab.relief_quantity(i) IS NULL ) THEN

                 x_atp_peg_tab.relief_quantity(i) :=
                      GREATEST(
                             -1 * x_atp_peg_tab.demand_quantity(i),
                             -- Bug 3362558 Get the mininimum of
                             -- demand_quantity and allocated_quantity
                             -1 * x_atp_peg_tab.allocated_quantity(i) )
                             -- Bug 3805136 Apply relief/alloc ratio
                             * l_peg_alloc_rel_ratio ;
                -- If the total passed down relief_quantity is less than
                -- that calculated then set the offset to be the same as that passed down.
                IF ABS(x_atp_peg_tab.relief_quantity(i)) >
                                                ABS(p_tot_relief_qty * l_peg_alloc_rel_ratio) THEN
                    x_atp_peg_tab.relief_quantity(i) := p_tot_relief_qty * l_peg_alloc_rel_ratio;
                END IF;
                -- End Bug 3805136
                IF PG_DEBUG in ('Y', 'C') THEN
                  msc_util.msc_log (' Config Item Forecast consumes Demand');
                  msc_util.msc_log (' x_atp_peg_tab.relief_quantity ' || x_atp_peg_tab.relief_quantity(i));
                END IF;
             END IF;
             -- End Bug 3805136

          END IF;
          -- If the current item is a configuration item then
          -- Call the procedure recursively.
          IF (x_atp_peg_tab.bom_item_type(i) = 4 AND
              x_atp_peg_tab.base_item_id(i) IS NOT NULL AND
              x_atp_peg_tab.pegging_id(i) IS NOT NULL ) THEN

              -- Bug 3761805
              -- Process Top Config at lower levels of Pegging only if it is the parameter
              -- Adhere to the End Pegging Path.
              IF (x_atp_peg_tab.end_pegging_id(i) = p_end_pegging_id AND
                  ABS(NVL(x_atp_peg_tab.relief_quantity(i), 0)) > 0 AND
                  -- Bug 3805136 Do not process excluded supplies
                  NVL(x_atp_peg_tab.exclude_flag(i),0) <> 1 AND
                  x_atp_peg_tab.relief_type(i) = 2 ) THEN
                IF x_atp_peg_tab.inventory_item_id(i) = x_atp_peg_tab.reference_item_id(i) THEN
                   -- Top level Config Item, Carry the same ratio.
                   l_peg_alloc_rel_ratio := 1;
                   -- Bug 3827097 The ratio needs to be re-calculated
                   -- just in case here the demand is pegged to multiple supplies
                   -- either in the same org or different one.
                   l_peg_relief_ratio := x_atp_peg_tab.relief_quantity(i) / x_atp_peg_tab.tot_relief_qty(i) ;
                   -- Bug 3805136
                ELSE
                   -- Ratio gets implicity applied since only
                   -- part of lower level config is relieved if parent is partly offset.
                   -- Bug 3805136
                   l_peg_relief_ratio := 1;
                   -- Bug 3805136 Apply the relief/alloc ratio to config comps.
                   /*
                   IF ((x_atp_peg_tab.allocated_quantity(i) < ABS(l_tot_relief_qty))
                       -- OR (x_atp_peg_tab.allocated_quantity(i) > ABS(l_tot_relief_qty) AND
                       --ABS( x_atp_peg_tab.relief_quantity(i) ) < x_atp_peg_tab.allocated_quantity(i) )
                      ) THEN
                       l_peg_alloc_rel_ratio := ABS( x_atp_peg_tab.relief_quantity(i) ) /
                                                 x_atp_peg_tab.allocated_quantity(i);
                       l_peg_relief_ratio := 1;
                   ELSE
                       l_peg_alloc_rel_ratio := 1;
                       l_peg_relief_ratio := p_peg_relief_ratio;
                   END IF;
                   */
                   -- Bug 3827097 Coment out old code above.
                   -- The ratio now gets used consistently, it was also
                   -- used for the sales order reference config item.
                   l_peg_alloc_rel_ratio := 1; -- This ratio no longer needed now.
                   l_peg_relief_ratio := x_atp_peg_tab.relief_quantity(i) / x_atp_peg_tab.tot_relief_qty(i);
                   -- End Bug 3827097
                END IF;
                IF PG_DEBUG in ('Y', 'C') THEN
                  msc_util.msc_log (' Calling Calculate_Relief_Quantities again');
                  msc_util.msc_log (' x_atp_peg_tab.consumed_qty ' || x_atp_peg_tab.consumed_qty(i));
                  msc_util.msc_log (' x_atp_peg_tab.relief_quantity ' || x_atp_peg_tab.relief_quantity(i));
                  msc_util.msc_log (' x_atp_peg_tab.tot_relief_quantity ' || x_atp_peg_tab.tot_relief_qty(i));
                  msc_util.msc_log (' x_atp_peg_tab.allocated_quantity ' || x_atp_peg_tab.allocated_quantity(i));
                  msc_util.msc_log (' x_atp_peg_tab.exclude_flag ' || x_atp_peg_tab.exclude_flag(i));
                  msc_util.msc_log (' l_peg_relief_ratio ' || l_peg_relief_ratio);
                END IF;
                Calculate_Relief_Quantities(x_atp_peg_tab,
                                        x_atp_peg_tab.pegging_id(i),
                                        x_atp_peg_tab.fixed_lt(i),
                                        x_atp_peg_tab.variable_lt(i),
                                        -- Bug 3701093
                                        x_atp_peg_tab.tot_relief_qty(i),
                                        l_peg_relief_ratio,
                                        -- End Bug 3701093
                                        -- Bug 3805136 relief/alloc ratio
                                        l_peg_alloc_rel_ratio,
                                        x_atp_peg_tab.relief_quantity(i),
                                        x_atp_peg_tab.end_item_usage(i),
                                        -- End Bug 3805136
                                        -- Bug 3761805 Change in Signature
                                        x_atp_peg_tab.inventory_item_id(i),
                                        p_end_pegging_id,
                                        x_atp_peg_tab.supply_id(i),
                                        -- End Bug 3761805
                                        x_atp_peg_tab.transaction_date(i),
                                        x_return_status
                                        );
              END IF;
              -- End Bug 3761805
          END IF;
       ELSE
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_util.msc_log (' Non Match Item ' || x_atp_peg_tab.inventory_item_id(i) ||
                                ' Pegging ' || x_atp_peg_tab.pegging_id(i) ||
                                ' Prev Pegging ' || x_atp_peg_tab.prev_pegging_id(i));
          END IF;
       END IF;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log (' ***** END Calculate_Relief_Quantities. ***** ');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Calculate_Relief_Quantities. '|| sqlcode || ': ' || sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Calculate_Relief_Quantities;

-- This procedure creates the pegging for resources and also
-- calculates the relief quantities.

PROCEDURE  Generate_Resource_Pegging (atp_peg_tab  IN OUT NoCopy  ATP_Simple_Peg_Typ,
                                      x_return_status OUT NOCOPY  varchar2)
IS

i                    NUMBER;
j                    NUMBER;
l_relief_quantity    NUMBER;

l_loop_count         NUMBER;
l_res_count          NUMBER;
l_new_count          NUMBER;
l_return_status      VARCHAR2(10);
l_tot_count          NUMBER;

res_peg_tab          ATP_Res_Peg_Typ;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('***** Begin Generate_Resource_Pegging Procedure *****');
    END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_loop_count := atp_peg_tab.inventory_item_id.COUNT;
      l_new_count := l_loop_count ;

      -- PSEUDOCODE
      -- Loop for all the items in the pegging
      -- Obtain Resource pegging and relief data
      -- Append the resource data for each config item to the
      -- the original pegging array.

      -- cannot use FORALL and BULK COLLECT INTO together in SELECT statements
      -- Loop for all the items in the pegging
      FOR i in 1..l_loop_count LOOP
       -- Obtain Resource pegging and relief data
       SELECT
               req.plan_id, req.sr_instance_id,
               req.organization_id, req.assembly_item_id, req.transaction_id,
               req.resource_id,
               req.department_id,
               -- Bug 3321897 For Line Based Resources,
               -- Resource_ID is not NULL but -1
               DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                             REQ.RESOURCE_HOURS)  RESOURCE_HOURS,
               -- Bug 3321897 For Line Based Resources,
               -- Resource_ID is not NULL but -1
               DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                      DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                   -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) DAILY_RESOURCE_HOURS,
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
               TRUNC(start_date) start_date,
               TRUNC(end_date) end_date,
               -- Bug 3321897 For Line Based Resources,
               -- Resource_ID is not NULL but -1
               -- Bug 3455997
               -- For lot based resources either the complete req. is relieved or none at all.
               ( DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                   REQ.RESOURCE_HOURS)  * decode (atp_peg_tab.supply_quantity(i),0 ,0,
                                             decode(basis_type,
                   1, ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity(i),
                   2, FLOOR (ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity(i) )))
                   * SIGN (atp_peg_tab.relief_quantity(i)) ) RELIEF_QUANTITY,
               -- End Bug 3455997
               -- Bug 3321897 For Line Based Resources,
               -- Resource_ID is not NULL but -1
               -- Bug 3455997
               -- For lot based resources either the complete req. is relieved or none at all.
               ( DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                      DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                   -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS)))
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
                            * decode (atp_peg_tab.supply_quantity(i),0 ,0,
                            Decode (basis_type,
                    1, ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity (i),
                    2, FLOOR(ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity(i))))
                   * SIGN (atp_peg_tab.relief_quantity(i)) ) DAILY_RELIEF_QTY
               -- End Bug 3455997
       BULK COLLECT
       INTO    res_peg_tab.plan_id, res_peg_tab.sr_instance_id, res_peg_tab.organization_id,
               res_peg_tab.inventory_item_id, res_peg_tab.supply_id, res_peg_tab.resource_id,
               res_peg_tab.department_id, res_peg_tab.resource_hours, res_peg_tab.daily_resource_hours,
               res_peg_tab.start_date, res_peg_tab.end_date, res_peg_tab.relief_quantity,
               res_peg_tab.daily_relief_qty
       FROM    msc_resource_requirements req
       WHERE   req.plan_id = atp_peg_tab.plan_id(i)
       AND     req.sr_instance_id = atp_peg_tab.sr_instance_id(i)
       AND     req.organization_id = atp_peg_tab.organization_id(i)
       AND     req.supply_id = atp_peg_tab.supply_id(i)
       AND     req.assembly_item_id = atp_peg_tab.inventory_item_id(i)
               -- Bug 3362558 Exclude Department Id -1
               -- No need to fetch resource_consumption that is 0.
       AND     REQ.DEPARTMENT_ID <> -1
       AND     ( DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                             REQ.RESOURCE_HOURS) > 0
                 OR
                 DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                      DECODE(REQ.END_DATE, NULL, REQ.RESOURCE_HOURS,
                   -- Bug 3348095
                        DECODE(REQ.record_source, 2, REQ.RESOURCE_HOURS,
                                 REQ.DAILY_RESOURCE_HOURS))) > 0
                   -- For ATP created records use resource_hours
                   -- End Bug 3348095
               )
               -- End Bug 3362558
               -- Bug 3455997 Ensure that relief_quantity is greater than 0.
               -- For lot based resources either the complete req. is relieved or none at all.
       AND     ( DECODE(REQ.RESOURCE_ID, -1, REQ.LOAD_RATE,
                   REQ.RESOURCE_HOURS)  * decode (atp_peg_tab.supply_quantity(i),0 ,0,
                                             decode(basis_type,
                   1, ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity(i),
                   2, FLOOR (ABS(atp_peg_tab.relief_quantity(i))/atp_peg_tab.supply_quantity(i) )))
               ) > 0
               -- Here the SIGN multiplier is not used to
               -- Ensure that relief_quantity is greater than 0.
               -- End Bug 3455997
       AND     atp_peg_tab.bom_item_type(i) = 4
       AND     atp_peg_tab.base_item_id(i) IS NOT NULL
       AND     atp_peg_tab.relief_type(i) = 2
               ;

       l_res_count := res_peg_tab.resource_id.COUNT  ;

       IF (l_res_count > 0) THEN
          -- Append the resource data for each config item to the
          -- the original pegging array.
          -- First extend the pegging array by the resource data count.
          Extend_Atp_Peg (atp_peg_tab, l_return_status, l_res_count);

          FOR j in 1..l_res_count LOOP

               l_new_count := l_new_count + 1;
               -- Append to the array
               -- Uses data from the assembly items
               -- and the data from resources
               -- while creating the information.
               atp_peg_tab.reference_item_id(l_new_count) := atp_peg_tab.reference_item_id(i);
               atp_peg_tab.inventory_item_id(l_new_count) := atp_peg_tab.inventory_item_id(i);
               atp_peg_tab.plan_id(l_new_count) := atp_peg_tab.plan_id(i);
               atp_peg_tab.sr_instance_id(l_new_count) := atp_peg_tab.sr_instance_id(i);
               atp_peg_tab.organization_id(l_new_count) := atp_peg_tab.organization_id(i);
               atp_peg_tab.bom_item_type(l_new_count) := atp_peg_tab.bom_item_type(i);
               atp_peg_tab.sales_order_qty(l_new_count) := atp_peg_tab.sales_order_qty(i);
               atp_peg_tab.sales_order_line_id(l_new_count) := atp_peg_tab.sales_order_line_id(i);
               atp_peg_tab.demand_source_type(l_new_count) := atp_peg_tab.demand_source_type(i);--cmro
               atp_peg_tab.transaction_date(l_new_count) := atp_peg_tab.transaction_date(i);
               atp_peg_tab.demand_class(l_new_count) := atp_peg_tab.demand_class(i);
               atp_peg_tab.supply_id(l_new_count) := res_peg_tab.supply_id(j);
               atp_peg_tab.supply_quantity(l_new_count) := atp_peg_tab.supply_quantity(i);
               atp_peg_tab.allocated_quantity(l_new_count) := atp_peg_tab.allocated_quantity(i);
               atp_peg_tab.pegging_id(l_new_count) := atp_peg_tab.pegging_id(i);
               atp_peg_tab.end_pegging_id(l_new_count) := atp_peg_tab.end_pegging_id(i);
               atp_peg_tab.prev_pegging_id(l_new_count) := atp_peg_tab.prev_pegging_id(i);

               atp_peg_tab.resource_id(l_new_count) := res_peg_tab.resource_id(j);
               atp_peg_tab.department_id(l_new_count) := res_peg_tab.department_id(j);
               atp_peg_tab.resource_hours(l_new_count) := res_peg_tab.resource_hours(j);
               atp_peg_tab.daily_resource_hours(l_new_count) := res_peg_tab.daily_resource_hours(j);
               atp_peg_tab.start_date(l_new_count) := res_peg_tab.start_date(j);
               atp_peg_tab.end_date(l_new_count) := res_peg_tab.end_date(j);
               atp_peg_tab.relief_type(l_new_count) := 4;   -- RES
               atp_peg_tab.transaction_date(l_new_count) := res_peg_tab.start_date(j);
               atp_peg_tab.relief_quantity(l_new_count) := res_peg_tab.relief_quantity(j);
               atp_peg_tab.daily_relief_qty(l_new_count) := res_peg_tab.daily_relief_qty(j);

               -- CTO_PF_PRJ changes.
               atp_peg_tab.end_demand_id(l_new_count) := atp_peg_tab.end_demand_id(i);

          END LOOP;

       END IF; --IF (l_res_count > 0)

      END LOOP;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Generate_Resource_Pegging. Error : ' || sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Generate_Resource_Pegging ;

-- This procedures obtains the forecast consumption for Configuration Items
-- and ATO models.
-- It also fetches the phantom items that were included in the Sales Order
-- and their corresponding consumption and overconsumption used for estimating demands.

PROCEDURE Get_Forecast_Consumption (atp_peg_tab        IN            ATP_Detail_Peg_Typ ,
                                    p_array_idx        IN            NUMBER,
                                    x_fcst_data_tab    IN OUT NoCopy ATP_Fcst_Cons_Typ,
                                 -- Bug 3417410 Name change from fcst_data_tab to x_fcst_data_tab
                                    x_return_status    OUT NOCOPY    VARCHAR2)
IS
i                   PLS_INTEGER;
k                   PLS_INTEGER;
l_item_typ          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_process_seq_id    NUMBER;
l_routing_seq_id    NUMBER;
l_bill_seq_id       NUMBER;

-- Bug 3417410 Use local record of table
l_fcst_data_tab     ATP_Fcst_Cons_Typ;
l_fcst_mod_flag     NUMBER := 0;
l_fcst_cnt          PLS_INTEGER;
BEGIN

    k := p_array_idx;  -- assign to a variable for simplicity.

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('***** Begin Get_Forecast_Consumption Procedure *****');
       msc_util.msc_log(' Instance Id atp_peg_tab.sr_instance_id(k) : ' ||
                                                      atp_peg_tab.sr_instance_id(k) );
       msc_util.msc_log(' Plan Id : ' || atp_peg_tab.plan_id(k) );
       msc_util.msc_log(' Organization Id : ' || atp_peg_tab.organization_id(k) );
       msc_util.msc_log(' Sales Order/Origianl Demand Id : ' ||
                                                  atp_peg_tab.original_demand_id(k) );
       msc_util.msc_log(' Parent(Config) Item Id : ' ||
                                                  atp_peg_tab.inventory_item_id(k) );
       msc_util.msc_log(' Base Model Id : ' || atp_peg_tab.base_item_id(k) );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize Variables
    l_fcst_mod_flag := 0;

    /* Commented SQL for Bug 6046524
    -- Bug 3562722 Setup a SUM and group by since SO could get consumed
    -- through combination of several forecasts.
    SELECT msi.plan_id, msi.sr_instance_id,
           fcst.inventory_item_id, fcst.parent_item_id,
           msi.organization_id, fcst.organization_id fcst_organization_id,
           -- Bug 3562722 forecast_demand_id is immaterial since SO will get
           -- get consumed against one forecast set.
           -1 forecast_demand_id, fcst.sales_order_id, sales_order_qty,
           -- Forecast Qty is not used in ATP Post Plan Pegging computation
           SUM(fcst.forecast_qty) forecast_qty, SUM(fcst.consumed_qty) consumed_qty,
           SUM(NVL(fcst.overconsumption_qty, 0)) overconsumption_qty,
           msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
           -- Bug 3701093
           1, -- Overconsumption of Model Forecast happens
           decode(fcst.inventory_item_id, fcst.parent_item_id, 0, -- config first
                                     atp_peg_tab.base_item_id(k), 1, -- model second
                                     fcst.inventory_item_id)  -- others later
    -- End Bug 3562722
    BULK COLLECT
           -- Bug 3417410 Collect into return record.
    INTO   x_fcst_data_tab.plan_id, x_fcst_data_tab.sr_instance_id,
           x_fcst_data_tab.inventory_item_id, x_fcst_data_tab.parent_item_id,
           x_fcst_data_tab.organization_id, x_fcst_data_tab.fcst_organization_id,
           x_fcst_data_tab.fcst_demand_id, x_fcst_data_tab.sales_order_id,
           x_fcst_data_tab.sales_order_qty, x_fcst_data_tab.forecast_qty,
           x_fcst_data_tab.consumed_qty, x_fcst_data_tab.overconsumption_qty,
           x_fcst_data_tab.bom_item_type, x_fcst_data_tab.fixed_lt,
           x_fcst_data_tab.variable_lt,
           -- Bug 3701093, flag overconsumption
           x_fcst_data_tab.cons_config_mod_flag, l_item_typ
           -- End Bug 3417410 Collect into return record.
    FROM   msc_forecast_updates fcst, msc_system_items msi
    WHERE  fcst.sr_instance_id = atp_peg_tab.sr_instance_id(k)
    AND    fcst.plan_id = atp_peg_tab.plan_id(k)
    AND    (fcst.organization_id = atp_peg_tab.organization_id(k)
            OR    fcst.organization_id = -1)
           -- First check for local forecast
           -- CTO_PF_PRJ changes. Use end_demand_id
    AND    (fcst.sales_order_id = atp_peg_tab.original_demand_id(k)
            OR
            fcst.sales_order_id = atp_peg_tab.end_demand_id(k)
           )
           -- CTO_PF_PRJ
    AND    fcst.parent_item_id = atp_peg_tab.inventory_item_id(k)
    AND    msi.plan_id = fcst.plan_id
    AND    msi.sr_instance_id = fcst.sr_instance_id
    AND    msi.organization_id = atp_peg_tab.organization_id(k)
    AND    (msi.wip_supply_type = 6 or msi.bom_item_type = 1)
         -- only phantom items or models are obtained
         -- forecast updates may contain lower level models and configuration
         -- items. Ensure that they are not obtained
    AND    msi.inventory_item_id = decode(msi.bom_item_type,
                                         --1, atp_peg_tab.base_item_id(k),
                                         4, decode(msi.base_item_id,
                                              NULL, fcst.inventory_item_id,
                                                        fcst.parent_item_id),
                                         fcst.inventory_item_id )
    -- Bug 3562722 Setup a SUM and group by since SO could get consumed
    -- through combination of several forecasts.
    GROUP  BY msi.plan_id, msi.sr_instance_id,
           fcst.inventory_item_id, fcst.parent_item_id,
           msi.organization_id, fcst.organization_id ,
           -1 , fcst.sales_order_id, sales_order_qty,
           msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
           -- Bug 3701093
           1, -- Overconsumption of Model/OC Forecast happens
           decode(fcst.inventory_item_id, fcst.parent_item_id, 0, -- config first
                                     atp_peg_tab.base_item_id(k), 1, -- model second
                                     fcst.inventory_item_id)  -- others later
      -- End Bug 3562722
    ORDER BY decode(fcst.inventory_item_id, fcst.parent_item_id, 0,
                                     atp_peg_tab.base_item_id(k), 1,
                                     fcst.inventory_item_id)
    ;
        */
    --Start Modified SQL for Bug 6046524
    SELECT fcst1.plan_id,
      fcst1.sr_instance_id,
      fcst1.inventory_item_id,
      fcst1.parent_item_id,
      fcst1.organization_id,
      fcst1.fcst_organization_id fcst_organization_id,
      -1 forecast_demand_id,
      fcst1.sales_order_id,
      fcst1.sales_order_qty,
      SUM(fcst1.forecast_qty) forecast_qty,
      SUM(fcst1.consumed_qty) consumed_qty,
      SUM(nvl(fcst1.overconsumption_qty,   0)) overconsumption_qty,
      fcst1.bom_item_type,
      fcst1.fixed_lead_time,
      fcst1.variable_lead_time,
      1,
      decode(fcst1.inventory_item_id,   fcst1.parent_item_id,   0,   atp_peg_tab.base_item_id(k),   1,   fcst1.inventory_item_id)
    BULK COLLECT
    INTO   x_fcst_data_tab.plan_id,
           x_fcst_data_tab.sr_instance_id,
           x_fcst_data_tab.inventory_item_id,
           x_fcst_data_tab.parent_item_id,
           x_fcst_data_tab.organization_id,
           x_fcst_data_tab.fcst_organization_id,
           x_fcst_data_tab.fcst_demand_id,
           x_fcst_data_tab.sales_order_id,
           x_fcst_data_tab.sales_order_qty,
           x_fcst_data_tab.forecast_qty,
           x_fcst_data_tab.consumed_qty,
           x_fcst_data_tab.overconsumption_qty,
           x_fcst_data_tab.bom_item_type,
           x_fcst_data_tab.fixed_lt,
           x_fcst_data_tab.variable_lt,
           x_fcst_data_tab.cons_config_mod_flag,
           l_item_typ
    FROM
      (SELECT msi.plan_id,
         msi.sr_instance_id,
         fcst.inventory_item_id,
         fcst.parent_item_id,
         msi.organization_id,
         fcst.organization_id fcst_organization_id,
         -1 forecast_demand_id,
         fcst.sales_order_id,
         sales_order_qty,
         fcst.forecast_qty forecast_qty,
         fcst.consumed_qty consumed_qty,
         nvl(fcst.overconsumption_qty,    0) overconsumption_qty,
         msi.bom_item_type,
         msi.fixed_lead_time,
         msi.variable_lead_time,
         1,
         decode(fcst.inventory_item_id,    fcst.parent_item_id,    0,    atp_peg_tab.base_item_id(k),    1,    fcst.inventory_item_id)
       FROM msc_forecast_updates fcst,
         msc_system_items msi
       WHERE fcst.sr_instance_id = atp_peg_tab.sr_instance_id(k)
       AND fcst.plan_id = atp_peg_tab.plan_id(k)
       AND(fcst.organization_id = atp_peg_tab.organization_id(k) OR fcst.organization_id = -1)
       AND(fcst.sales_order_id = atp_peg_tab.original_demand_id(k) OR fcst.sales_order_id = atp_peg_tab.end_demand_id(k))
       AND fcst.parent_item_id = atp_peg_tab.inventory_item_id(k)
       AND msi.plan_id = fcst.plan_id
       AND msi.sr_instance_id = fcst.sr_instance_id
       AND msi.organization_id = atp_peg_tab.organization_id(k)
       AND(msi.bom_item_type = 1  --bug 9184226
	 OR(msi.wip_supply_type = 6
		 AND msi.bom_item_type <> 1
		 AND (msi.bom_item_type <> 4 OR  (msi.bom_item_type = 4 AND msi.base_item_id IS NULL)) )
          )
       AND msi.inventory_item_id = fcst.inventory_item_id
       UNION ALL
       SELECT msi.plan_id,
         msi.sr_instance_id,
         fcst.inventory_item_id,
         fcst.parent_item_id,
         msi.organization_id,
         fcst.organization_id fcst_organization_id,
         -1 forecast_demand_id,
         fcst.sales_order_id,
         sales_order_qty,
         fcst.forecast_qty forecast_qty,
         fcst.consumed_qty consumed_qty,
         nvl(fcst.overconsumption_qty,    0) overconsumption_qty,
         msi.bom_item_type,
         msi.fixed_lead_time,
         msi.variable_lead_time,
         1,
         decode(fcst.inventory_item_id,    fcst.parent_item_id,    0,    atp_peg_tab.base_item_id(k),    1,    fcst.inventory_item_id)
       FROM msc_forecast_updates fcst,
         msc_system_items msi
       WHERE fcst.sr_instance_id = atp_peg_tab.sr_instance_id(k)
       AND fcst.plan_id = atp_peg_tab.plan_id(k)
       AND(fcst.organization_id = atp_peg_tab.organization_id(k) OR fcst.organization_id = -1)
       AND(fcst.sales_order_id = atp_peg_tab.original_demand_id(k) OR fcst.sales_order_id = atp_peg_tab.end_demand_id(k))
       AND fcst.parent_item_id = atp_peg_tab.inventory_item_id(k)
       AND msi.plan_id = fcst.plan_id
       AND msi.sr_instance_id = fcst.sr_instance_id
       AND msi.organization_id = atp_peg_tab.organization_id(k)
       AND msi.wip_supply_type = 6
       AND msi.bom_item_type = 4  --bug 9184226
       AND msi.base_item_id IS NOT NULL
       AND msi.inventory_item_id = fcst.parent_item_id) fcst1
    GROUP BY fcst1.plan_id,
      fcst1.sr_instance_id,
      fcst1.inventory_item_id,
      fcst1.parent_item_id,
      fcst1.organization_id,
      fcst1.fcst_organization_id,
      -1,
      fcst1.sales_order_id,
      sales_order_qty,
      fcst1.bom_item_type,
      fcst1.fixed_lead_time,
      fcst1.variable_lead_time,
      1,
      decode(fcst1.inventory_item_id,   fcst1.parent_item_id,   0,   atp_peg_tab.base_item_id(k),   1,   fcst1.inventory_item_id)
    ORDER BY decode(fcst1.inventory_item_id,   fcst1.parent_item_id,   0,   atp_peg_tab.base_item_id(k),   1,   fcst1.inventory_item_id);
    --End Modified SQL for Bug 6046524
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log(' Count After Model Overconsumption Check : ' ||
                            x_fcst_data_tab.inventory_item_id.COUNT);
    END IF;

    -- Bug 3701093 pure Config Item consumption data only when Model overconsumption
    -- data is not found.
    IF x_fcst_data_tab.inventory_item_id.COUNT = 0 THEN
       SELECT msi.plan_id, msi.sr_instance_id,
              fcst.inventory_item_id, fcst.parent_item_id,
              msi.organization_id, fcst.organization_id fcst_organization_id,
              -1 forecast_demand_id, fcst.sales_order_id, sales_order_qty,
              SUM(fcst.forecast_qty) forecast_qty, SUM(fcst.consumed_qty) consumed_qty,
              SUM(NVL(fcst.overconsumption_qty,0)) overconsumption_qty,
              msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
              2 -- only config item is consumed
       BULK COLLECT
       INTO   x_fcst_data_tab.plan_id, x_fcst_data_tab.sr_instance_id,
              x_fcst_data_tab.inventory_item_id, x_fcst_data_tab.parent_item_id,
              x_fcst_data_tab.organization_id, x_fcst_data_tab.fcst_organization_id,
              x_fcst_data_tab.fcst_demand_id, x_fcst_data_tab.sales_order_id,
              x_fcst_data_tab.sales_order_qty, x_fcst_data_tab.forecast_qty,
              x_fcst_data_tab.consumed_qty, x_fcst_data_tab.overconsumption_qty,
              x_fcst_data_tab.bom_item_type, x_fcst_data_tab.fixed_lt,
              x_fcst_data_tab.variable_lt, x_fcst_data_tab.cons_config_mod_flag
       FROM   msc_forecast_updates fcst, msc_system_items msi
       WHERE  fcst.sr_instance_id = atp_peg_tab.sr_instance_id(k)
       AND    fcst.plan_id = atp_peg_tab.plan_id(k)
       AND    (fcst.organization_id = atp_peg_tab.organization_id(k)
                 OR    fcst.organization_id = -1)
                -- First check for local forecast
                -- CTO_PF_PRJ changes. Use end_demand_id
       AND    (fcst.sales_order_id = atp_peg_tab.original_demand_id(k)
                 OR
                 fcst.sales_order_id = atp_peg_tab.end_demand_id(k)
                )
                -- CTO_PF_PRJ
       AND    fcst.inventory_item_id = atp_peg_tab.inventory_item_id(k)
       -- Only get records where config item's forecast is consumed
       AND    fcst.forecast_qty > 0
       AND    (fcst.consumed_qty + NVL(fcst.overconsumption_qty,0)) > 0
                                     -- Bug 3805136        atp_peg_tab.allocated_quantity(k)
       -- and there is no overconsumption of corresponding base model's forecast.
       AND    msi.plan_id = fcst.plan_id
       AND    msi.sr_instance_id = fcst.sr_instance_id
       AND    msi.organization_id = atp_peg_tab.organization_id(k)
       AND    msi.inventory_item_id =  fcst.inventory_item_id
       GROUP  BY msi.plan_id, msi.sr_instance_id,
                fcst.inventory_item_id, fcst.parent_item_id,
                msi.organization_id, fcst.organization_id ,
                -1 , fcst.sales_order_id, sales_order_qty,
                msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
                2 -- only config item is consumed
       -- Bug 3805136 (Uncomment HAVING clause)
       HAVING SUM(fcst.consumed_qty) + SUM(NVL(fcst.overconsumption_qty, 0))
                                                          >= fcst.sales_order_qty
       ;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log(' Count After Config Check : ' ||
                              x_fcst_data_tab.inventory_item_id.COUNT);
          msc_util.msc_log(' Allocated Quantity : ' || atp_peg_tab.allocated_quantity(k));
       END IF;
       -- End Bug 3701093
    END IF;
    -- End Bug 3701093


    -- Bug 3362558
    -- Global forecasting situation, org_id is -1.
    -- CTO_PF_PRJ Query present below removed. The use of
    -- end_demand_id obviates the need for SQL that joins with msc_atp_detail_peg_temp.
    -- Changes here in relation to Bug 3362558 not needed anymore.
    -- End Bug 3362558

        -- Bug 3362499
        -- No data in msc_forecast_updates.
    -- Bug 3417410 Determine if model line is present in data
    IF x_fcst_data_tab.inventory_item_id.COUNT = 0 THEN
       l_fcst_mod_flag := 0;
    ELSE
       FOR i in 1..x_fcst_data_tab.inventory_item_id.COUNT
       LOOP
          IF ( (x_fcst_data_tab.inventory_item_id(i) =
                               atp_peg_tab.base_item_id(k) ) OR
               (x_fcst_data_tab.inventory_item_id(i) =
                               atp_peg_tab.inventory_item_id(k) ) ) THEN
             -- The config item or model has been forecast
             l_fcst_mod_flag := 1;
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Get_Fcst_Cons: Model or Config in Forecast Data');
                msc_util.msc_log('Get_Fcst_Cons: Forecast Inventory_Item_id : '||
                                                    x_fcst_data_tab.inventory_item_id(i));
             END IF;
          END IF;
       END LOOP;
    END IF;
    -- End Bug 3417410 Determine if model line is present in data

    IF l_fcst_mod_flag = 0 THEN -- Bug 3417410 If no model line is present in forecast
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Get Data from msc_system_items for base_item_id');
          msc_util.msc_log('Provide default values for other forecast fields ');
       END IF;
        -- Get data from msc_system_items for the base_item_id
        -- and provide default values for other forecast related fields.
        -- Note Local forecast is assumed as a default.
        SELECT msi.plan_id, msi.sr_instance_id,
               msi.inventory_item_id, atp_peg_tab.inventory_item_id(k),
               msi.organization_id, msi.organization_id fcst_organization_id,
               -1 forecast_demand_id, atp_peg_tab.original_demand_id(k) sales_order_id,
               0 sales_order_qty, 0 forecast_qty, 0 consumed_qty,
               atp_peg_tab.allocated_quantity(k)  overconsumption_qty,
               msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
               -- Bug 3701093
               0  -- No forecast Consumption Happens,
                                   -- Generating data based on allocated quantities.
        BULK COLLECT
             -- Bug 3417410 Collect into local record.
        INTO   l_fcst_data_tab.plan_id, l_fcst_data_tab.sr_instance_id,
               l_fcst_data_tab.inventory_item_id, l_fcst_data_tab.parent_item_id,
               l_fcst_data_tab.organization_id, l_fcst_data_tab.fcst_organization_id,
               l_fcst_data_tab.fcst_demand_id, l_fcst_data_tab.sales_order_id,
               l_fcst_data_tab.sales_order_qty, l_fcst_data_tab.forecast_qty,
               l_fcst_data_tab.consumed_qty, l_fcst_data_tab.overconsumption_qty,
               l_fcst_data_tab.bom_item_type, l_fcst_data_tab.fixed_lt,
               l_fcst_data_tab.variable_lt,
               -- Bug 3701093 Model overconsumption does not happen
               l_fcst_data_tab.cons_config_mod_flag
               -- Just get the data from msc_system_items
               -- and default the rest of the values.
             -- End Bug 3417410 Collect into local record.
        FROM   msc_system_items msi
        WHERE  msi.plan_id = atp_peg_tab.plan_id(k)
        AND    msi.sr_instance_id = atp_peg_tab.sr_instance_id(k)
        AND    msi.organization_id = atp_peg_tab.organization_id(k)
        AND    (msi.wip_supply_type = 6 or msi.bom_item_type = 1)
               -- only phantom model info is obtained
        AND    msi.inventory_item_id =  atp_peg_tab.base_item_id(k)
        ;

        -- Bug 3417410 Assign the default model data into the output record.
        x_fcst_data_tab.plan_id.EXTEND;
        x_fcst_data_tab.sr_instance_id.EXTEND;
        x_fcst_data_tab.inventory_item_id.EXTEND;
        x_fcst_data_tab.parent_item_id.EXTEND;
        x_fcst_data_tab.organization_id.EXTEND;
        x_fcst_data_tab.fcst_organization_id.EXTEND;
        x_fcst_data_tab.fcst_demand_id.EXTEND;
        x_fcst_data_tab.sales_order_id.EXTEND;
        x_fcst_data_tab.sales_order_qty.EXTEND;
        x_fcst_data_tab.forecast_qty.EXTEND;
        x_fcst_data_tab.consumed_qty.EXTEND;
        x_fcst_data_tab.overconsumption_qty.EXTEND;
        x_fcst_data_tab.bom_item_type.EXTEND;
        x_fcst_data_tab.fixed_lt.EXTEND;
        x_fcst_data_tab.variable_lt.EXTEND;
        -- Bug 3701093 Extend the new field.
        x_fcst_data_tab.cons_config_mod_flag.EXTEND;

        l_fcst_cnt :=  x_fcst_data_tab.inventory_item_id.COUNT;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Get_Fcst_Cons-Total Forecasted Items : '|| l_fcst_cnt);
        END IF;

        -- Bug 3701093 COUNT > 0 check only, changed from <>
        IF l_fcst_data_tab.inventory_item_id.COUNT > 0 THEN
           x_fcst_data_tab.plan_id(l_fcst_cnt)           := l_fcst_data_tab.plan_id(1);
           x_fcst_data_tab.sr_instance_id(l_fcst_cnt)    := l_fcst_data_tab.sr_instance_id(1);
           x_fcst_data_tab.inventory_item_id(l_fcst_cnt) := l_fcst_data_tab.inventory_item_id(1);
           x_fcst_data_tab.parent_item_id(l_fcst_cnt)    := l_fcst_data_tab.parent_item_id(1);
           x_fcst_data_tab.organization_id(l_fcst_cnt)   := l_fcst_data_tab.organization_id(1);
           x_fcst_data_tab.fcst_organization_id(l_fcst_cnt) :=
                                                      l_fcst_data_tab.fcst_organization_id(1);
           x_fcst_data_tab.fcst_demand_id(l_fcst_cnt)    := l_fcst_data_tab.fcst_demand_id(1);
           x_fcst_data_tab.sales_order_id(l_fcst_cnt)    := l_fcst_data_tab.sales_order_id(1);
           x_fcst_data_tab.sales_order_qty(l_fcst_cnt)   := l_fcst_data_tab.sales_order_qty(1);
           x_fcst_data_tab.forecast_qty(l_fcst_cnt)      := l_fcst_data_tab.forecast_qty(1);
           x_fcst_data_tab.consumed_qty(l_fcst_cnt)      := l_fcst_data_tab.consumed_qty(1);
           x_fcst_data_tab.overconsumption_qty(l_fcst_cnt) :=
                                                      l_fcst_data_tab.overconsumption_qty(1);
           -- Bug 3805136
           -- Lower Level Config No Forecast .
           IF (atp_peg_tab.inventory_item_id(k) <> atp_peg_tab.reference_item_id(k) ) THEN
              x_fcst_data_tab.forecast_qty(l_fcst_cnt)      := NULL;
              x_fcst_data_tab.consumed_qty(l_fcst_cnt)      := NULL;
              x_fcst_data_tab.overconsumption_qty(l_fcst_cnt) := NULL;
           END IF;
           -- End Bug 3805136
           x_fcst_data_tab.bom_item_type(l_fcst_cnt)     := l_fcst_data_tab.bom_item_type(1);
           x_fcst_data_tab.fixed_lt(l_fcst_cnt)          := l_fcst_data_tab.fixed_lt(1);
           x_fcst_data_tab.variable_lt(l_fcst_cnt)       := l_fcst_data_tab.variable_lt(1);
           -- Bug 3701093
           x_fcst_data_tab.cons_config_mod_flag(l_fcst_cnt) := C_NO_FCST_CONSUMED;
           -- Bug 3701093 Model and Config forecast consumption does not happen
        ELSE
           -- No data in msc_system_items for the base model
           -- Print out a Warning message.
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_util.msc_log ( 'No plan data for Base Model ' ||
                                                        atp_peg_tab.base_item_id(k)  );
              msc_util.msc_log('Get_Fcst_Cons-No plan data for Base Model : '||
                                                        atp_peg_tab.base_item_id(k) );
           END IF;
           x_fcst_data_tab.plan_id(l_fcst_cnt)           := atp_peg_tab.plan_id(k);
           x_fcst_data_tab.sr_instance_id(l_fcst_cnt)    := atp_peg_tab.sr_instance_id(k);
           x_fcst_data_tab.inventory_item_id(l_fcst_cnt) := atp_peg_tab.base_item_id(k);
           x_fcst_data_tab.parent_item_id(l_fcst_cnt)    := atp_peg_tab.inventory_item_id(k);
           x_fcst_data_tab.organization_id(l_fcst_cnt)   := atp_peg_tab.organization_id(k);
           x_fcst_data_tab.fcst_organization_id(l_fcst_cnt) :=
                                                      atp_peg_tab.organization_id(k);
           x_fcst_data_tab.fcst_demand_id(l_fcst_cnt)    := -1;
           x_fcst_data_tab.sales_order_id(l_fcst_cnt)    := atp_peg_tab.original_demand_id(k);
           x_fcst_data_tab.sales_order_qty(l_fcst_cnt)   := 0;
           x_fcst_data_tab.forecast_qty(l_fcst_cnt)      := 0;
           x_fcst_data_tab.consumed_qty(l_fcst_cnt)      := 0;
           x_fcst_data_tab.overconsumption_qty(l_fcst_cnt) :=
                                                      atp_peg_tab.allocated_quantity(k);
           -- Bug 3805136
           -- Lower Level Config No Forecast .
           IF (atp_peg_tab.inventory_item_id(k) <> atp_peg_tab.reference_item_id(k) ) THEN
              x_fcst_data_tab.forecast_qty(l_fcst_cnt)      := NULL;
              x_fcst_data_tab.consumed_qty(l_fcst_cnt)      := NULL;
              x_fcst_data_tab.overconsumption_qty(l_fcst_cnt) := NULL;
           END IF;
           x_fcst_data_tab.bom_item_type(l_fcst_cnt)     := 1;
           x_fcst_data_tab.fixed_lt(l_fcst_cnt)          := 0;
           x_fcst_data_tab.variable_lt(l_fcst_cnt)       := 0;
           -- Bug 3701093
           x_fcst_data_tab.cons_config_mod_flag(l_fcst_cnt) := C_NO_FCST_CONSUMED;
           -- Bug 3701093 Model and Config forecast consumption does not happen
        END IF;
        -- Bug 3417410 Assign the default model data into the output record.

    END IF;
    -- End Bug 3362499

  /* Old code that links to the BOM DELETED
   */

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Get_Forecast_Consumption. Error : ' || sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Forecast_Consumption;

-- This procedure transforms a flat combined supply/demand pegging into a two
-- level pegging that contains supplies and demands separately.
PROCEDURE Create_Simple_Pegging (atp_peg_det      IN            ATP_Detail_Peg_Typ,
                                 atp_peg_tab      IN OUT NoCopy ATP_Simple_Peg_Typ,
                                 x_return_status  OUT NOCOPY    VARCHAR2)
IS
n                  NUMBER;
l_return_status    VARCHAR2(1);
l_count            NUMBER := 0;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('***** Begin Create_Simple_Pegging Procedure *****');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF PG_DEBUG in ('Y', 'C') THEN
    msc_util.msc_log(' atp_peg_det.reference_item_id.COUNT ' ||
                                     atp_peg_det.reference_item_id.COUNT);
    msc_util.msc_log('atp_peg_tab.reference_item_id.COUNT ' ||
                                      atp_peg_tab.reference_item_id.COUNT);
  END IF;

  l_count := atp_peg_tab.reference_item_id.COUNT;

  FOR n in 1..atp_peg_det.inventory_item_id.COUNT LOOP
    -- First Call to extend the tables in atp_peg_tab.
    Extend_Atp_Peg (atp_peg_tab, l_return_status, 1);

   IF PG_DEBUG in ('Y', 'C') THEN
    msc_util.msc_log(' Item Id  ' || atp_peg_det.inventory_item_id(n));
    msc_util.msc_log(' atp_peg_tab.pegging_id ' ||
                                      atp_peg_det.pegging_id(n));
   END IF;
    l_count := l_count + 1;

    -- The detail data is divided into two simplified pegging records.
    -- one for demand and one for supply.
    -- Assign Common Data

    atp_peg_tab.reference_item_id(l_count) := atp_peg_det.reference_item_id(n);
    atp_peg_tab.base_item_id(l_count) := atp_peg_det.base_item_id(n);
    atp_peg_tab.inventory_item_id(l_count) := atp_peg_det.inventory_item_id(n);
    atp_peg_tab.plan_id(l_count) := atp_peg_det.plan_id(n);
    atp_peg_tab.sr_instance_id(l_count) := atp_peg_det.sr_instance_id(n);
    atp_peg_tab.organization_id(l_count) := atp_peg_det.organization_id(n);
    atp_peg_tab.bom_item_type(l_count) := atp_peg_det.bom_item_type(n);
    atp_peg_tab.fixed_lt(l_count) := atp_peg_det.fixed_lt(n);
    atp_peg_tab.variable_lt(l_count) := atp_peg_det.variable_lt(n);
    atp_peg_tab.sales_order_line_id(l_count) := atp_peg_det.sales_order_line_id(n);
    atp_peg_tab.demand_source_type(l_count) := atp_peg_det.demand_source_type(n);--cmro
    atp_peg_tab.end_pegging_id(l_count) := atp_peg_det.end_pegging_id(n);
    atp_peg_tab.pegging_id(l_count) := atp_peg_det.pegging_id(n);
    atp_peg_tab.prev_pegging_id(l_count) := atp_peg_det.prev_pegging_id(n);
    atp_peg_tab.sales_order_qty(l_count) := atp_peg_det.sales_order_qty(n);
    atp_peg_tab.tot_relief_qty(l_count) := atp_peg_det.tot_relief_qty(n);
    -- CTO_PF_PRJ changes.
    atp_peg_tab.end_demand_id(l_count) := atp_peg_det.end_demand_id(n);
    -- CTO-PF
    atp_peg_tab.atf_date(l_count) := atp_peg_det.atf_date(n);
    atp_peg_tab.product_family_id(l_count) := atp_peg_det.product_family_id(n);

    atp_peg_tab.demand_class(l_count) := atp_peg_det.demand_class(n);
    -- Bug 3805136 -- Add end_item_usage to handle no forecast consumption.
    atp_peg_tab.end_item_usage(l_count) := atp_peg_det.end_item_usage(n);
    -- Exclude flag helps in excluding supplies
    -- during relef data calculation.
    atp_peg_tab.exclude_flag(l_count) := atp_peg_det.exclude_flag(n);
    -- End Bug 3805136

    -- Assign Demand Data
    atp_peg_tab.transaction_date(l_count) := TRUNC(atp_peg_det.demand_date(n));
    atp_peg_tab.demand_id(l_count) := atp_peg_det.demand_id(n);
    atp_peg_tab.demand_quantity(l_count) := atp_peg_det.demand_quantity(n);
    atp_peg_tab.disposition_id(l_count) := atp_peg_det.disposition_id(n);
    atp_peg_tab.consumed_qty(l_count) := atp_peg_det.consumed_qty(n);
    atp_peg_tab.overconsumption_qty(l_count) := atp_peg_det.overconsumption_qty(n);
    atp_peg_tab.allocated_quantity(l_count) := atp_peg_det.allocated_quantity(n);

    -- Auxiliary Data for CTO_PF_PRJ_2, Track the supply data.
    atp_peg_tab.supply_id(l_count) := atp_peg_det.supply_id(n);
    atp_peg_tab.supply_quantity(l_count) := atp_peg_det.supply_quantity(n);

    -- Determine Relief Type
    IF atp_peg_det.demand_type(n) = 6 or atp_peg_det.demand_type(n) = 30 THEN
       atp_peg_tab.relief_type(l_count) := 1;   -- Relief Type is SO.
    ELSIF atp_peg_det.demand_type(n) = 1 THEN
       atp_peg_tab.relief_type(l_count) := 3;   -- Relief Type is POD.
    END IF;


    -- Now create the supply simplified pegging data.
    IF (atp_peg_det.base_item_id(n) IS NOT NULL AND
        atp_peg_det.supply_id(n) IS NOT NULL ) THEN
       Extend_Atp_Peg (atp_peg_tab, l_return_status, 1);

       l_count  := l_count + 1;

      -- Assign Common Data
      atp_peg_tab.reference_item_id(l_count) := atp_peg_det.reference_item_id(n);
      atp_peg_tab.base_item_id(l_count) := atp_peg_det.base_item_id(n);
      atp_peg_tab.inventory_item_id(l_count) := atp_peg_det.inventory_item_id(n);
      atp_peg_tab.plan_id(l_count) := atp_peg_det.plan_id(n);
      atp_peg_tab.sr_instance_id(l_count) := atp_peg_det.sr_instance_id(n);
      atp_peg_tab.organization_id(l_count) := atp_peg_det.organization_id(n);
      atp_peg_tab.bom_item_type(l_count) := atp_peg_det.bom_item_type(n);
      atp_peg_tab.fixed_lt(l_count) := atp_peg_det.fixed_lt(n);
      atp_peg_tab.variable_lt(l_count) := atp_peg_det.variable_lt(n);
      atp_peg_tab.sales_order_line_id(l_count) := atp_peg_det.sales_order_line_id(n);
      atp_peg_tab.demand_source_type(l_count) := atp_peg_det.demand_source_type(n);--cmro
      atp_peg_tab.end_pegging_id(l_count) := atp_peg_det.end_pegging_id(n);
      atp_peg_tab.pegging_id(l_count) := atp_peg_det.pegging_id(n);
      atp_peg_tab.prev_pegging_id(l_count) := atp_peg_det.prev_pegging_id(n);
      atp_peg_tab.sales_order_qty(l_count) := atp_peg_det.sales_order_qty(n);
      atp_peg_tab.tot_relief_qty(l_count) := atp_peg_det.tot_relief_qty(n);
      -- CTO_PF_PRJ changes.
      atp_peg_tab.end_demand_id(l_count) := atp_peg_det.end_demand_id(n);
      --CTO-PF
      atp_peg_tab.atf_date(l_count) := atp_peg_det.atf_date(n);
      atp_peg_tab.product_family_id(l_count) := atp_peg_det.product_family_id(n);
      -- Bug 3805136 -- Add end_item_usage to handle no forecast consumption.
      atp_peg_tab.end_item_usage(l_count) := atp_peg_det.end_item_usage(n);
      -- Exclude flag helps in excluding supplies
      -- during relef data calculation.
      atp_peg_tab.exclude_flag(l_count) := atp_peg_det.exclude_flag(n);
      -- End Bug 3805136

      -- Assign corresponding supply_data
      atp_peg_tab.transaction_date(l_count) := TRUNC(atp_peg_det.supply_date(n));
      atp_peg_tab.consumed_qty(l_count) := atp_peg_det.consumed_qty(n);
      atp_peg_tab.overconsumption_qty(l_count) := atp_peg_det.overconsumption_qty(n);
      atp_peg_tab.supply_id(l_count) := atp_peg_det.supply_id(n);
      atp_peg_tab.supply_quantity(l_count) := atp_peg_det.supply_quantity(n);
      atp_peg_tab.allocated_quantity(l_count) := atp_peg_det.allocated_quantity(n);


     IF PG_DEBUG in ('Y', 'C') THEN
      msc_util.msc_log(' atp_peg_tab.allocated_quantity ' ||
                                     atp_peg_det.allocated_quantity(n));
     END IF;
      -- Determine Relief Type
      -- For material supplies the relief type is POs
      atp_peg_tab.relief_type(l_count) := 2;   -- Relief Type is PO.
    END IF;
  END LOOP;
    msc_util.msc_log(' atp_peg_tab.reference_item_id.COUNT ' ||
                                     atp_peg_tab.reference_item_id.COUNT);
EXCEPTION
    WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Create_Simple_Pegging. Error : ' || sqlerrm);
     END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END  Create_Simple_Pegging;

-- Bug 3344102 Procedure begin
-- This procedure creates the ATP simplified pegging for allocated ATP case
-- and stores it into the msc_atp_pegging table after plan run.
PROCEDURE Create_Pre_Allocation_Reliefs (p_plan_id         IN          NUMBER,
                                         p_insert_table    IN          VARCHAR2,
                                         p_user_id         IN          NUMBER,
                                         p_sysdate         IN          DATE,
                                         x_return_status   OUT NOCOPY  VARCHAR2
                                        )
IS

l_sql_stmt                      VARCHAR2(800);
l_sql_stmt_1                    VARCHAR2(8000);
l_relief_type                   NUMBER;

-- Default Demand Class
l_def_dmd_class                 VARCHAR2(3) := '-1';

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log('***** Begin Create_Pre_Allocation_Reliefs Procedure *****');
     msc_util.msc_log(' Plan Id : ' || p_plan_id );
     msc_util.msc_log(' Insert Table parameter : ' || p_insert_table );
     msc_util.msc_log(' User Id Paramenter : ' || p_user_id );
     msc_util.msc_log(' Date Parameter : ' || p_sysdate );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Set the relief type for only demands with Allocated ATP on.
    l_relief_type := 5;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log(' Inserting Demands');
    END IF;

    l_sql_stmt_1 := 'INSERT INTO  ' || p_insert_table || -- actually the insert table parameter.
             ' (reference_item_id, inventory_item_id, plan_id,
             sr_instance_id, organization_id, sales_order_line_id,
             demand_source_type, end_demand_id, bom_item_type,
             sales_order_qty, transaction_date, demand_id,
             demand_quantity, disposition_id, demand_class,
             consumed_qty, overconsumption_qty, supply_id, supply_quantity,
             allocated_quantity,
             relief_type, relief_quantity,
             pegging_id, prev_pegging_id, end_pegging_id,
             created_by, creation_date, last_updated_by, last_update_date,
             customer_id, customer_site_id)
    SELECT   mapt.reference_item_id, mapt.inventory_item_id, mapt.plan_id,
             mapt.sr_instance_id, mapt.organization_id,
             mapt.sales_order_line_id, mapt.demand_source_type, mapt.end_demand_id,
             mapt.bom_item_type, mapt.sales_order_qty, mapt.transaction_date,
             mapt.demand_id , mapt.demand_quantity,
             mapt.disposition_id,
             NVL(mv.demand_class, :l_def_dmd_class) demand_class ,
             mapt.consumed_qty, mapt.overconsumption_qty,
             mapt.supply_id, mapt.supply_quantity,
             mapt.allocated_quantity ,  :l_relief_type,
             mapt.relief_quantity ,
             mapt.pegging_id, mapt.prev_pegging_id, mapt.end_pegging_id,
             :p_user_id, :p_sysdate, :p_user_id, :p_sysdate,
             mv.partner_id, mv.partner_site_id customer_site_id
    FROM    msc_atp_peg_temp mapt, msc_item_hierarchy_mv mv
    WHERE   mapt.plan_id = :p_plan_id
    AND     mapt.relief_type = 3
    AND     mapt.inventory_item_id = mv.inventory_item_id(+)
    AND     mapt.organization_id = mv.organization_id (+)
    AND     mapt.sr_instance_id = mv.sr_instance_id (+)
    AND     mapt.transaction_date >=  mv.effective_date (+)
    AND     mapt.transaction_date <=  mv.disable_date (+)
    AND     mapt.demand_class = mv.demand_class (+)
    AND     mv.level_id (+) = -1 '
    ;

    EXECUTE IMMEDIATE l_sql_stmt_1 USING
                        l_def_dmd_class, l_relief_type,
                        p_user_id, p_sysdate, p_user_id, p_sysdate, p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Create_Pre_Allocation_Reliefs:  Number of Demand rows inserted '||
                               SQL%ROWCOUNT);
    END IF;

    -- Set the relief type for only supplies with Allocated ATP on.
    l_relief_type := 6;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log(' Inserting Supplies');
  END IF;

    l_sql_stmt_1 := 'INSERT INTO  ' || p_insert_table || -- actually the insert table parameter.
             ' (reference_item_id, inventory_item_id, plan_id,
             sr_instance_id, organization_id, sales_order_line_id,
             demand_source_type, end_demand_id, bom_item_type,
             sales_order_qty, transaction_date, demand_id,
             demand_quantity, disposition_id, demand_class,
             consumed_qty, overconsumption_qty, supply_id, supply_quantity,
             allocated_quantity,
             relief_type, relief_quantity,
             pegging_id, prev_pegging_id, end_pegging_id,
             created_by, creation_date, last_updated_by, last_update_date,
             customer_id, customer_site_id)
    SELECT   mapt.reference_item_id, mapt.inventory_item_id, mapt.plan_id,
             mapt.sr_instance_id, mapt.organization_id,
             mapt.sales_order_line_id, mapt.demand_source_type, mapt.end_demand_id,
             mapt.bom_item_type, mapt.sales_order_qty, mapt.transaction_date,
             mapt.demand_id , mapt.demand_quantity,
             mapt.disposition_id,
             NVL(mv.demand_class, :l_def_dmd_class) demand_class ,
             mapt.consumed_qty, mapt.overconsumption_qty,
             mapt.supply_id, mapt.supply_quantity,
             mapt.allocated_quantity ,  :l_relief_type,
             mapt.relief_quantity ,
             mapt.pegging_id, mapt.prev_pegging_id, mapt.end_pegging_id,
             :p_user_id, :p_sysdate, :p_user_id, :p_sysdate,
             mv.partner_id, mv.partner_site_id customer_site_id
    FROM    msc_atp_peg_temp mapt, msc_item_hierarchy_mv mv
    WHERE   mapt.plan_id = :p_plan_id
    AND     mapt.relief_type = 2
    AND     mapt.inventory_item_id = mv.inventory_item_id(+)
    AND     mapt.organization_id = mv.organization_id (+)
    AND     mapt.sr_instance_id = mv.sr_instance_id (+)
    AND     mapt.transaction_date >=  mv.effective_date (+)
    AND     mapt.transaction_date <=  mv.disable_date (+)
    AND     mapt.demand_class = mv.demand_class (+)
    AND     mv.level_id (+) = -1 '
    ;

    EXECUTE IMMEDIATE l_sql_stmt_1 USING
                        l_def_dmd_class, l_relief_type,
                        p_user_id, p_sysdate, p_user_id, p_sysdate, p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Create_Pre_Allocation_Reliefs:  Number of Supply rows inserted '||
                               SQL%ROWCOUNT);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Inside main exception of Create_Pre_Allocation_Reliefs');
        msc_util.msc_log ('Create_Pre_Allocation_Reliefs. Error : ' || sqlcode || ': '|| sqlerrm);
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Pre_Allocation_Reliefs;
-- Bug 3344102 Procedure End

-- Bug 3750638 Move all the pegging releated SQLs into this procedure.
-- This procedure fetches pegging data for a Sales Order
-- from MSC_FULL_PEGGING in a loop.
PROCEDURE Get_Pegging_Data_Loop (p_plan_id       IN          NUMBER,
                                 c_items_rec     IN          ATP_End_Config_Dmd_Typ,
                                 x_return_status OUT  NoCopy VARCHAR2   )
IS

l_sql_stmt_1                    varchar2(8000);
l_timestamp                     NUMBER;
l_hash_size                     NUMBER := -1;
l_sort_size                     NUMBER := -1;
l_parallel_degree               NUMBER := 1;

-- Fix for Multiple (N) Level of Config Items using Loop
-- Define PL/SQL Variable of Record of Arrays Type to correspond to
-- Config Item Supplies being processed in the Pegging Retrieval loop.
L_Config_Sup                    ATP_Config_Sup_Typ;
l_multi_config_count            NUMBER;
n_idx                           NUMBER; -- Index for Items
n_row_count                     NUMBER;
l_config_level                  NUMBER;
i                               NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
    msc_util.msc_log('***** Begin Get_Pegging_Data_Loop (Get_Pegging_Loop) *****');
    msc_util.msc_log('Get_Pegging_Loop : p_plan_id ' || p_plan_id);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize variables;
  -- First get the performance parameters.

  BEGIN
     SELECT      NVL(pre_alloc_hash_size, -1),
                 NVL(pre_alloc_sort_size, -1),
                 NVL(pre_alloc_parallel_degree, 1)
     INTO        l_hash_size,
                 l_sort_size,
                 l_parallel_degree
     FROM        msc_atp_parameters
     WHERE       rownum = 1;
     EXCEPTION
         WHEN others THEN
         msc_util.msc_log('Error getting performance param: ' || sqlcode || ': ' || sqlerrm);
         l_hash_size := -1;
         l_sort_size := -1;
         l_parallel_degree := 1;
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log('Hash: ' || l_hash_size || ' Sort: ' || l_sort_size ||
                         ' Parallel: ' || l_parallel_degree);
  END IF;

  IF NVL(l_hash_size, -1) <> -1 THEN
        l_sql_stmt_1 := 'alter session set hash_area_size = ' || to_char(l_hash_size);
        msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
        execute immediate l_sql_stmt_1;
  END IF;

  IF NVL(l_sort_size, -1) <> -1 THEN
         l_sql_stmt_1 := 'alter session set sort_area_size = ' || to_char(l_sort_size);
         msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
         execute immediate l_sql_stmt_1;
  END IF;

  -- Now obtain the pegging data into Global Temporary Table in a Loop.

      -- Obtain the supplies info for the config item.
      INSERT INTO MSC_ATP_DETAIL_PEG_TEMP (
              reference_item_id, base_item_id,
              inventory_item_id,
              plan_id,
              sr_instance_id,
              organization_id,
              end_item_usage,
              bom_item_type, fixed_lt, variable_lt,
              sales_order_line_id,
              demand_source_type,--cmro
              -- CTO_PF_PRJ changes.
              end_demand_id,
              sales_order_qty,
              process_seq_id, supply_id,
              supply_date,
              supply_quantity,
              allocated_quantity, tot_relief_qty,
              supply_type,
              firm_planned_type,
              release_status,
              exclude_flag,    -- All other cases exclude
              end_pegging_id, pegging_id,  prev_pegging_id,
              fcst_organization_id, forecast_qty,
              consumed_qty, overconsumption_qty )
      SELECT  DISTINCT
              c_items_rec.inventory_item_id, msi.base_item_id,
              peg2.inventory_item_id,
              peg2.plan_id,
              peg2.sr_instance_id,
              peg2.organization_id,
              peg2.end_item_usage,
              msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
              c_items_rec.sales_order_line_id,
              c_items_rec.demand_source_type, --cmro
              -- CTO_PF_PRJ changes.
              NVL(d1.original_demand_id, d1.demand_id),
              NULL sales_order_qty, -- will be used to factor sales_order_qty,
              SUP.process_seq_id, SUP.transaction_id supply_id,
              SUP.new_schedule_date supply_date,
              SUP.new_order_quantity supply_qty,
              peg2.allocated_quantity, NULL tot_relief_qty,
              SUP.order_type,
              SUP.firm_planned_type,
              SUP.release_status, -- 1 released
              DECODE (SUP.order_type, 5,
                     -- order type is 5 proceed with further checks
                        (DECODE(SUP.firm_planned_type, 1, 1, -- 1 firm, others not firm
                          -- order is not firmed proceed with further checks
                          -- Bug 3717618 Use "quantity_in_process"
                          -- instead of incorrect release_status
                            (DECODE(SIGN (NVL(SUP.implemented_quantity, 0) +
                                          NVL(SUP.quantity_in_process, 0) -
                                          NVL(SUP.firm_quantity,SUP.new_order_quantity)),
                             0, 1, -- equal then flag as released
                             1, 1, -- positive then flag as released
                             0)) -- 0 otherwise not released.
                          -- End Bug 3717618
                         )),
                      1) exclude_flag,    -- All other cases exclude
              peg2.end_pegging_id, peg2.pegging_id,  peg2.prev_pegging_id,
              NULL fcst_organization_id, NULL forecast_qty,
              NULL consumed_qty, NULL overconsumption_qty
      FROM
              msc_demands d1,
              msc_full_pegging peg1 ,
              msc_full_pegging peg2 ,
              msc_supplies SUP,
              msc_system_items msi
      WHERE   d1.plan_id = p_plan_id
      AND     d1.sr_instance_id = c_items_rec.sr_instance_id
      AND     d1.inventory_item_id = c_items_rec.inventory_item_id
      AND     d1.origination_type IN (6,30)
      AND     d1.sales_order_line_id = c_items_rec.sales_order_line_id
      AND     decode(d1.demand_source_type,100,d1.demand_source_type,-1)
              =decode(c_items_rec.demand_source_type,
                                                100,
                                                c_items_rec.demand_source_type,
                                                -1) --cmro
      AND     peg1.plan_id = d1.plan_id
      AND     peg1.sr_instance_id = d1.sr_instance_id
      AND     peg1.organization_id = d1.organization_id
      AND     peg1.demand_id = d1.demand_id
      AND     peg2.plan_id = peg1.plan_id
      AND     peg2.end_pegging_id = peg1.pegging_id
      -- Bug 3344032 On further investigation the outer join will not be needed.
      -- since the sr_instance_id join can be commented out.
      --AND     peg2.sr_instance_id = peg1.sr_instance_id (+) -- outer join to get all instances
      --  Bug 3319810 Match the item_id as well.
      AND     peg2.inventory_item_id = peg1.inventory_item_id
              -- Get the supplies corresponding to pegging
      AND     SUP.transaction_id = peg2.transaction_id
      AND     SUP.plan_id = peg2.plan_id
      AND     SUP.sr_instance_id = peg2.sr_instance_id
      AND     SUP.organization_id = peg2.organization_id
              -- Join to msc_system_items to filter out items
              -- from the pegging.
      AND     msi.plan_id = SUP.plan_id
      AND     msi.sr_instance_id = SUP.sr_instance_id
      AND     msi.inventory_item_id = SUP.inventory_item_id
      AND     msi.organization_id  = SUP.organization_id
              -- Restrict supplies to items that are configuration items
      AND     msi.bom_item_type = 4
      AND     msi.base_item_id is not null
      AND     msi.replenish_to_order_flag = 'Y'
      -- Bug 3717618 Remove exclusion of firmed or released supplies here.
      -- This will be handled during creation of Offset Data.
      -- This data is needed for getting the pegging chain.
      -- AND     DECODE (SUP.order_type, 5,
                     -- order type is 5 proceed with further checks
      --                   (DECODE(SUP.firm_planned_type, 1, 1, -- 1 firm, others not firm
                          -- order is not firmed proceed with further checks
      --                       (DECODE(SIGN (NVL(SUP.implemented_quantity, 0) +
      --                                     NVL(SUP.quantity_in_process, 0) -
      --                                     NVL(SUP.firm_quantity,SUP.new_order_quantity)),
      --                        0, 1, -- equal then flag as released
      --                        1, 1, -- positive then flag as released
      --                        0)) -- 0 otherwise not released.
      --                    )),
      --                 1)  <> 1   -- Exclude un-necessary supplies.
      -- End Bug 3717618
      ;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Stage 1 ' );
        msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
      END IF;

      -- Update Pegging data with End demand Id. Information
      -- CTO_PF_PRJ changes.

      UPDATE MSC_ATP_DETAIL_PEG_TEMP madpt -- outer table
       SET
       (end_demand_id
       ) =
       (  SELECT  end_demand_id
          FROM    msc_atp_detail_peg_temp madpti -- Inner table
          WHERE   madpti.plan_id = madpt.plan_id
          AND     madpti.sr_instance_id = madpt.sr_instance_id
          AND     madpti.reference_item_id =  madpt.inventory_item_id
          AND     madpti.sales_order_line_id = madpt.sales_order_line_id
          AND     madpti.demand_source_type = madpt.demand_source_type
          AND     madpti.pegging_id = madpt.end_pegging_id
          AND     madpti.prev_pegging_id IS NULL
       )
       WHERE   madpt.plan_id = p_plan_id
       AND     madpt.sr_instance_id = c_items_rec.sr_instance_id
       AND     madpt.reference_item_id =  c_items_rec.inventory_item_id
       AND     madpt.sales_order_line_id = c_items_rec.sales_order_line_id
       AND     madpt.demand_source_type
               =decode(c_items_rec.demand_source_type,
                                                100,
                                                c_items_rec.demand_source_type,
                                                -1)  -- CMRO
      ;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
      END IF;

      -- Update Pegging data with demand Information

      UPDATE MSC_ATP_DETAIL_PEG_TEMP madpt
       SET
       (demand_id,
       demand_date,
       demand_quantity,
       disposition_id,
       demand_class,
       demand_type,
       original_demand_id,
       order_number
       ) =
       -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
       -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
       (  SELECT d.demand_id,
          decode(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
                 2, NVL(D.PLANNED_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE),
                    NVL(D.SCHEDULE_SHIP_DATE,D.USING_ASSEMBLY_DEMAND_DATE)) demand_date,
                    -- plan by request date
          decode(d.origination_type, 4, d.daily_demand_rate,
                              d.using_requirement_quantity) demand_quantity,
          -- Bug 3319810 Set the disposition_id for top level supply pegging.
          NVL(d.disposition_id, peg.transaction_id) disposition_id,
          NVL(d.demand_class, '-1') demand_class,
          d.origination_type,
          NVL(d.original_demand_id, d.demand_id) original_demand_id,
          decode(d.origination_type, 1,
                    to_char(d.disposition_id), d.order_number)
          FROM       --msc_atp_detail_peg_temp madpt,
              msc_full_pegging peg,
              msc_demands d
          WHERE   madpt.plan_id = p_plan_id
          AND     madpt.sr_instance_id = c_items_rec.sr_instance_id
          AND     madpt.reference_item_id =  c_items_rec.inventory_item_id
          AND     madpt.sales_order_line_id = c_items_rec.sales_order_line_id
          AND     decode(madpt.demand_source_type,100,madpt.demand_source_type,-1)
                  = decode(c_items_rec.demand_source_type,
                                                100,
                                                c_items_rec.demand_source_type,
                                                -1) --CMRO
          AND     peg.plan_id = madpt.plan_id
          AND     peg.sr_instance_id = madpt.sr_instance_id
          AND     peg.organization_id = madpt.organization_id
          AND     peg.pegging_id = madpt.pegging_id
          AND     peg.end_pegging_id = madpt.end_pegging_id
          AND     peg.inventory_item_id = madpt.inventory_item_id
              -- Get the demands corresponding to pegging
          AND     d.plan_id = peg.plan_id
          AND     d.sr_instance_id = peg.sr_instance_id
          AND     d.organization_id = peg.organization_id
          AND     d.inventory_item_id = peg.inventory_item_id
          AND     d.demand_id = peg.demand_id)
       WHERE   madpt.plan_id = p_plan_id
       AND     madpt.sr_instance_id = c_items_rec.sr_instance_id
       AND     madpt.reference_item_id =  c_items_rec.inventory_item_id
       AND     madpt.sales_order_line_id = c_items_rec.sales_order_line_id
       AND     decode(madpt.demand_source_type,100,madpt.demand_source_type,-1)
               =decode(c_items_rec.demand_source_type,
                                                100,
                                                c_items_rec.demand_source_type,
                                                -1)  -- CMRO
       -- Bug 3750638
       -- Collect Supplies into Supplies PL/SQL Array.
       RETURNING
                 inventory_item_id,
                 sr_instance_id,
                 base_item_id,
                 sales_order_line_id,
                 demand_source_type,
                 end_demand_id,
                 supply_id,
                 pegging_id,
                 end_pegging_id
       BULK COLLECT INTO
                 L_Config_Sup.INVENTORY_ITEM_ID,
                 L_Config_Sup.SR_INSTANCE_ID,
                 L_Config_Sup.BASE_ITEM_ID,
                 L_Config_Sup.SALES_ORDER_LINE_ID,
                 L_Config_Sup.DEMAND_SOURCE_TYPE,
                 L_Config_Sup.END_DEMAND_ID,
                 L_Config_Sup.SUPPLY_ID,
                 L_Config_Sup.PEGGING_ID,
                 L_Config_Sup.END_PEGGING_ID
       ;
       -- End Bug 3750638
       -- Bug 3362558 Fetch the original_demand_id
       -- CTO_PF_PRJ changes.
       -- RETURNING madpt.original_demand_id BULK COLLECT INTO l_original_demand_ids;
       -- Commented out, since with the introduction of end_demand_id field,
       -- fetch into l_original_demand_id is not necessary.


      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Stage 2 ' );
        msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
      END IF;


      -- Bug 3750638 Initialize the Count of Items to be processed.
      l_multi_config_count := L_Config_Sup.INVENTORY_ITEM_ID.COUNT;
      l_config_level := 1;

      -- Bug 3750638 Place the next couple of SQLs in a LOOP for processing
      -- N levels of Configuration Items.
      WHILE l_multi_config_count > 0 LOOP
         -- Bug 3750638 Introduce FORALL loop for processing Config Items.
        IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Gen_Atp_Pegging : Total Config Items ' ||
                        'l_multi_config_count ' || l_multi_config_count);
        END IF;
        FOR n_idx IN 1..l_multi_config_count LOOP
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log('Gen_Atp_Pegging : Config Instance_Id ' ||
                                        L_Config_Sup.SR_INSTANCE_ID(n_idx) );
               msc_util.msc_log('Gen_Atp_Pegging : Config Item_Id ' ||
                                        L_Config_Sup.INVENTORY_ITEM_ID(n_idx) );
               msc_util.msc_log('Gen_Atp_Pegging : Config Supply_Id ' ||
                                        L_Config_Sup.SUPPLY_ID(n_idx) );
               msc_util.msc_log('Gen_Atp_Pegging : Config Base_Item_Id ' ||
                                        L_Config_Sup.BASE_ITEM_ID(n_idx) );
               msc_util.msc_log('Gen_Atp_Pegging : Config Pegging_Id ' ||
                                        L_Config_Sup.PEGGING_ID(n_idx) );
               msc_util.msc_log('Gen_Atp_Pegging : Config End_Pegging_Id ' ||
                                        L_Config_Sup.END_PEGGING_ID(n_idx) );
            END IF;
        END LOOP;

        -- First obtain transfers if any.
        FORALL n_idx IN 1..l_multi_config_count
           INSERT INTO MSC_ATP_DETAIL_PEG_TEMP (
                 reference_item_id, base_item_id,
                 inventory_item_id,
                 plan_id,
                 sr_instance_id,
                 organization_id,
                 end_item_usage,
                 bom_item_type, fixed_lt, variable_lt,
                 sales_order_line_id,
                 demand_source_type,--cmro
                 -- CTO_PF_PRJ changes.
                 end_demand_id,
                 -- CTO-PF
                 atf_date,
                 product_family_id,
                 sales_order_qty,
                 demand_id,
                 demand_date,
                 demand_quantity,
                 disposition_id,
                 demand_class,
                 demand_type,
                 original_demand_id,
                 process_seq_id, supply_id,
                 supply_date,
                 supply_quantity,
                 allocated_quantity, tot_relief_qty,
                 supply_type,
                 firm_planned_type,
                 release_status,
                 exclude_flag,    -- All other cases exclude
                 order_number,
                 end_pegging_id, pegging_id,  prev_pegging_id,
                 fcst_organization_id, forecast_qty,
                 consumed_qty, overconsumption_qty )
         SELECT
                 adpt.reference_item_id, msi.base_item_id,
                 peg1.inventory_item_id,
                 peg1.plan_id,
                 peg1.sr_instance_id,
                 peg1.organization_id,
                 peg1.end_item_usage,
                 msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
                 adpt.sales_order_line_id,
                 adpt.demand_source_type,--cmro
                 -- CTO_PF_PRJ changes.
                 adpt.end_demand_id,
                 -- CTO-PF
                 msi.aggregate_time_fence_date,
                 msi.product_family_id,
                 NULL sales_order_qty, -- will be used to factor sales_order_qty,
                 d1.demand_id,
                 -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                 -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                 DECODE(
                         d1.RECORD_SOURCE,
                         2,
             	         NVL(d1.SCHEDULE_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE),
               	         DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
              	         2,
              	         (NVL(d1.IMPLEMENT_SHIP_DATE,NVL(d1.FIRM_DATE,NVL(d1.PLANNED_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE)))),
                         NVL(d1.SCHEDULE_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE))), --plan by request Date, Promise Date Scheduled Date
                 decode(d1.origination_type, 4, d1.daily_demand_rate,
                                     d1.using_requirement_quantity) demand_quantity,
                 d1.disposition_id,
                 NVL(d1.demand_class, adpt.demand_class) demand_class,
                 d1.origination_type,
                 -- Bug 3362558 use pegging's original demand_id
                 NVL(d1.original_demand_id, adpt.original_demand_id) original_demand_id,
                 -- Begin Bug 3319810
                 -- Use pegging's supply data instead of msc_atp_detail_peg_temp.
                 adpt.process_seq_id,
                 --adpt.supply_id,
                 --adpt.supply_date,
                 --adpt.supply_quantity,
                 --adpt.allocated_quantity, NULL tot_relief_qty,
                 --adpt.supply_type,
                 peg1.transaction_id supply_id,
                 -- Bug 3750638 Keep the supply date NULL for configs.
                 DECODE(NVL(msi.base_item_id, -2353), -2353,  peg1.supply_date, NULL) supply_date,
                 peg1.supply_quantity,
                 peg1.allocated_quantity, NULL tot_relief_qty,
                 peg1.supply_type,
                 -- End Bug 3319810
                 adpt.firm_planned_type,
                 adpt.release_status, -- 1 released
                 0 exclude_flag,    -- Include the demands as a default.
                 decode(d1.origination_type, 1, to_char(d1.disposition_id), d1.order_number) order_number,
                 peg1.end_pegging_id, peg1.pegging_id,  peg1.prev_pegging_id,
                 NULL fcst_organization_id, NULL forecast_qty,
                 NULL consumed_qty, NULL overconsumption_qty
         FROM
                 msc_atp_detail_peg_temp adpt,
                 msc_full_pegging peg1 ,
                 msc_demands d1,
                 msc_system_items msi
         WHERE   adpt.plan_id = p_plan_id
         AND     adpt.reference_item_id = c_items_rec.inventory_item_id
         AND     adpt.sales_order_line_id = c_items_rec.sales_order_line_id
         AND     decode(adpt.demand_source_type,100,adpt.demand_source_type,-1)
                 =decode(c_items_rec.demand_source_type,
                                                   100,
                                                   c_items_rec.demand_source_type,
                                                   -1) --CMRO
         -- Bug 3750638 Apply Config Item Array Filters
         AND     adpt.sr_instance_id = L_Config_Sup.SR_INSTANCE_ID(n_idx) -- outer join to get all instances
         AND     adpt.inventory_item_id = L_Config_Sup.INVENTORY_ITEM_ID(n_idx)
         AND     adpt.supply_id = L_Config_Sup.SUPPLY_ID(n_idx)
         AND     adpt.end_demand_id = L_Config_Sup.END_DEMAND_ID(n_idx)
         AND     adpt.pegging_id = L_Config_Sup.PEGGING_ID(n_idx)
         AND     adpt.end_pegging_id = L_Config_Sup.END_PEGGING_ID(n_idx)
         AND     adpt.base_item_id = L_Config_Sup.BASE_ITEM_ID(n_idx)
         AND     adpt.inventory_item_id <> adpt.reference_item_id
         -- End Bug 3750638
                 -- Link up pegging with config_item info in msc_atp_detail_peg_temp.
         AND     peg1.plan_id = adpt.plan_id
         AND     peg1.sr_instance_id = adpt.sr_instance_id
         AND     peg1.end_pegging_id = adpt.end_pegging_id
         AND     peg1.prev_pegging_id = adpt.pegging_id
         AND     peg1.inventory_item_id = adpt.inventory_item_id
         -- End Bug 3750638 Supply filter
         -- AND     peg1.supply_type = 5
                 -- Further control if necessary for performance will be added later.
                 -- AND peg1.transaction_id = adpt.supply_id
                 -- Get the demands corresponding to pegging
         AND     d1.plan_id = peg1.plan_id
         AND     d1.sr_instance_id = peg1.sr_instance_id
         AND     d1.organization_id = peg1.organization_id
         AND     d1.demand_id = peg1.demand_id
         -- Bug 3750638 The lower level item could also be sourced from muliple orgs.
         -- AND     d1.inventory_item_id <> adpt.inventory_item_id
                 -- Get all the items which peg to the supply using the disposition_id.
         AND     d1.disposition_id = adpt.supply_id
         AND     d1.using_requirement_quantity > 0
                 -- Join to msc_system_items to get items data
         AND     msi.plan_id = d1.plan_id
         AND     msi.sr_instance_id = d1.sr_instance_id
         AND     msi.inventory_item_id = d1.inventory_item_id
         AND     msi.organization_id  = d1.organization_id
         ;

         n_row_count := SQL%ROWCOUNT;
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging : Transfer of config n_row_count ' || n_row_count);
         END IF;
           -- Obtain the data for the components of the lower level configuration item(s)
           -- in the sales order.
        FORALL n_idx IN 1..l_multi_config_count
           INSERT INTO MSC_ATP_DETAIL_PEG_TEMP (
                 reference_item_id, base_item_id,
                 inventory_item_id,
                 plan_id,
                 sr_instance_id,
                 organization_id,
                 end_item_usage,
                 bom_item_type, fixed_lt, variable_lt,
                 sales_order_line_id,
                 demand_source_type,--cmro
                 -- CTO_PF_PRJ changes.
                 end_demand_id,
                 -- CTO-PF
                 atf_date,
                 product_family_id,
                 sales_order_qty,
                 demand_id,
                 demand_date,
                 demand_quantity,
                 disposition_id,
                 demand_class,
                 demand_type,
                 original_demand_id,
                 process_seq_id, supply_id,
                 supply_date,
                 supply_quantity,
                 allocated_quantity, tot_relief_qty,
                 supply_type,
                 firm_planned_type,
                 release_status,
                 exclude_flag,    -- All other cases exclude
                 order_number,
                 end_pegging_id, pegging_id,  prev_pegging_id,
                 fcst_organization_id, forecast_qty,
                 consumed_qty, overconsumption_qty )
         SELECT
                 adpt.reference_item_id, msi.base_item_id,
                 peg1.inventory_item_id,
                 peg1.plan_id,
                 peg1.sr_instance_id,
                 peg1.organization_id,
                 peg1.end_item_usage,
                 msi.bom_item_type, msi.fixed_lead_time, msi.variable_lead_time,
                 adpt.sales_order_line_id,
                 adpt.demand_source_type,--cmro
                 -- CTO_PF_PRJ changes.
                 adpt.end_demand_id,
                 -- CTO-PF
                 msi.aggregate_time_fence_date,
                 msi.product_family_id,
                 NULL sales_order_qty, -- will be used to factor sales_order_qty,
                 d1.demand_id,
                 -- Bug 3550296 and 3574164. IMPLEMENT_DATE AND DMD_SATISFIED_DATE are changed to
                 -- IMPLEMENT_SHIP_DATE and PLANNED_SHIP_DATE resp.
                 DECODE(
                         d1.RECORD_SOURCE,
                         2,
             	         NVL(d1.SCHEDULE_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE),
               	         DECODE(MSC_ATP_PVT.G_HP_DEMAND_BUCKETING_PREF,
              	         2,
              	         (NVL(d1.IMPLEMENT_SHIP_DATE,NVL(d1.FIRM_DATE,NVL(d1.PLANNED_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE)))),
                         NVL(d1.SCHEDULE_SHIP_DATE,d1.USING_ASSEMBLY_DEMAND_DATE))), --plan by request Date, Promise Date Scheduled Date
                 decode(d1.origination_type, 4, d1.daily_demand_rate,
                                     d1.using_requirement_quantity) demand_quantity,
                 d1.disposition_id,
                 NVL(d1.demand_class, adpt.demand_class) demand_class,
                 d1.origination_type,
                 -- Bug 3362558 use pegging's original demand_id
                 NVL(d1.original_demand_id, adpt.original_demand_id) original_demand_id,
                 -- Begin Bug 3319810
                 -- Use pegging's supply data instead of msc_atp_detail_peg_temp.
                 adpt.process_seq_id,
                 --adpt.supply_id,
                 --adpt.supply_date,
                 --adpt.supply_quantity,
                 --adpt.allocated_quantity, NULL tot_relief_qty,
                 --adpt.supply_type,
                 peg1.transaction_id supply_id,
                 -- Bug 3750638 Keep the supply date NULL for configs.
                 DECODE(NVL(msi.base_item_id, -2353), -2353,  peg1.supply_date, NULL) supply_date,
                 peg1.supply_quantity,
                 peg1.allocated_quantity, NULL tot_relief_qty,
                 peg1.supply_type,
                 -- End Bug 3319810
                 adpt.firm_planned_type,
                 adpt.release_status, -- 1 released
                 0 exclude_flag,    -- Include the demands as a default.
                 decode(d1.origination_type, 1, to_char(d1.disposition_id), d1.order_number) order_number,
                 peg1.end_pegging_id, peg1.pegging_id,  peg1.prev_pegging_id,
                 NULL fcst_organization_id, NULL forecast_qty,
                 NULL consumed_qty, NULL overconsumption_qty
         FROM
                 msc_atp_detail_peg_temp adpt,
                 msc_full_pegging peg1 ,
                 msc_demands d1,
                 msc_system_items msi,
                 msc_process_effectivity proc,
                 msc_bom_components mbc
         WHERE   adpt.plan_id = p_plan_id
         AND     adpt.reference_item_id = c_items_rec.inventory_item_id
         AND     adpt.sales_order_line_id = c_items_rec.sales_order_line_id
         AND     decode(adpt.demand_source_type,100,adpt.demand_source_type,-1)
                 =decode(c_items_rec.demand_source_type,
                                                   100,
                                                   c_items_rec.demand_source_type,
                                                   -1) --CMRO
         -- Bug 3750638 Apply Config Item Array Filters
         AND     adpt.sr_instance_id = L_Config_Sup.SR_INSTANCE_ID(n_idx) -- outer join to get all instances
         AND     adpt.inventory_item_id = L_Config_Sup.INVENTORY_ITEM_ID(n_idx)
         AND     adpt.supply_id = L_Config_Sup.SUPPLY_ID(n_idx)
         AND     adpt.end_demand_id = L_Config_Sup.END_DEMAND_ID(n_idx)
         AND     adpt.pegging_id = L_Config_Sup.PEGGING_ID(n_idx)
         AND     adpt.end_pegging_id = L_Config_Sup.END_PEGGING_ID(n_idx)
         AND     adpt.base_item_id = L_Config_Sup.BASE_ITEM_ID(n_idx)
         AND     adpt.supply_date is not NULL
         -- End Bug 3750638
                 -- Link up pegging with config_item info in msc_atp_detail_peg_temp.
         AND     peg1.plan_id = adpt.plan_id
         AND     peg1.sr_instance_id = adpt.sr_instance_id
         AND     peg1.end_pegging_id = adpt.end_pegging_id
         AND     peg1.prev_pegging_id = adpt.pegging_id
         AND     peg1.inventory_item_id <> adpt.reference_item_id
         -- End Bug 3750638 Supply filter
         -- AND     peg1.supply_type = 5
                 -- Further control if necessary for performance will be added later.
                 -- AND peg1.transaction_id = adpt.supply_id
                 -- Get the demands corresponding to pegging
         AND     d1.plan_id = peg1.plan_id
         AND     d1.sr_instance_id = peg1.sr_instance_id
         AND     d1.organization_id = peg1.organization_id
         AND     d1.demand_id = peg1.demand_id
         -- Bug 3750638 The lower level item could also be sourced from muliple orgs.
         -- AND     d1.inventory_item_id <> adpt.inventory_item_id
                 -- Get all the items which peg to the supply using the disposition_id.
         AND     d1.disposition_id = adpt.supply_id
         AND     d1.using_requirement_quantity > 0
                 -- Join to msc_system_items to get items data
         AND     msi.plan_id = d1.plan_id
         AND     msi.sr_instance_id = d1.sr_instance_id
         AND     msi.inventory_item_id = d1.inventory_item_id
         AND     msi.organization_id  = d1.organization_id
         --   Join to msc_process_effectivity to get the bill sequence
         AND     proc.plan_id = adpt.plan_id
         AND     proc.process_sequence_id = adpt.process_seq_id
         --   Join to msc_bom_components to exclude any exploded items underneath phantoms
         AND     mbc.plan_id = msi.plan_id
         AND     mbc.sr_instance_id = msi.sr_instance_id
         AND     mbc.organization_id = msi.organization_id
         AND     mbc.bill_sequence_id = proc.bill_sequence_id
                     -- manufacture in same org.
         AND     mbc.inventory_item_id = msi.inventory_item_id
         AND     mbc.using_assembly_id = adpt.inventory_item_id
         AND     mbc.organization_id = adpt.organization_id
         ;
         -- End Bug 3750638 -- FORALL loop

       select hsecs
       into   l_timestamp
       from   v$timer;

         -- Bug 3750638 Get the total number of records.
         n_row_count := SQL%ROWCOUNT;

         IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging : Stage 3 ' );
           msc_util.msc_log('Gen_Atp_Pegging : Components of config n_row_count ' || n_row_count);
           msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 2 ' || l_timestamp);
         END IF;


         -- update the supplies for the new demands
         UPDATE MSC_ATP_DETAIL_PEG_TEMP madpt
          SET
          ( process_seq_id, supply_id,
            supply_date,
            supply_quantity,
            allocated_quantity, tot_relief_qty,
            supply_type,
            firm_planned_type,
            release_status,
            exclude_flag
          ) =
          (  SELECT SUP.process_seq_id, SUP.transaction_id supply_id,
                    SUP.new_schedule_date supply_date,
                    SUP.new_order_quantity supply_qty,
                    peg.allocated_quantity, NULL tot_relief_qty,
                    SUP.order_type,
                    SUP.firm_planned_type,
                    SUP.release_status, -- 1 released
                    DECODE (SUP.order_type, 5,
                        -- order type is 5 proceed with further checks
                        (DECODE(SUP.firm_planned_type, 1, 1, -- 1 firm, others not firm
                        -- order is not firmed proceed with further checks
                             -- Bug 3717618 Use "quantity_in_process"
                             -- instead of incorrect release_status
                             (DECODE(SIGN (NVL(SUP.implemented_quantity, 0) +
                                           NVL(SUP.quantity_in_process, 0) -
                                           NVL(SUP.firm_quantity,SUP.new_order_quantity)),
                                0, 1, -- equal then flag as released
                                1, 1, -- positive then flag as released
                                0)) -- 0 otherwise not released.
                             -- End Bug 3717618
                          )),
                        1) exclude_flag
             FROM       --msc_atp_detail_peg_temp madpt,
                 msc_full_pegging peg,
                 msc_supplies SUP
             WHERE   madpt.plan_id = p_plan_id
             AND     madpt.sr_instance_id = c_items_rec.sr_instance_id
             AND     madpt.reference_item_id =  c_items_rec.inventory_item_id
             AND     madpt.sales_order_line_id = c_items_rec.sales_order_line_id
             AND     decode(madpt.demand_source_type,100,madpt.demand_source_type,-1)
                     =decode(c_items_rec.demand_source_type,
                                                   100,
                                                   c_items_rec.demand_source_type,
                                                   -1) --CMRO
             AND     madpt.inventory_item_id <> madpt.reference_item_id
             -- Bug 3750638
             -- Date is used to filter out other records.
             AND     madpt.supply_date IS NULL
             AND     peg.plan_id = madpt.plan_id
             AND     peg.sr_instance_id = madpt.sr_instance_id
             AND     peg.organization_id = madpt.organization_id
             AND     peg.pegging_id = madpt.pegging_id
             AND     peg.end_pegging_id = madpt.end_pegging_id
             AND     peg.inventory_item_id = madpt.inventory_item_id
                     -- Bug 3750638 also filter on supply_id
             AND     peg.transaction_id = madpt.supply_id
                     -- Get the supplies corresponding to pegging
             AND     SUP.plan_id = peg.plan_id
             AND     SUP.sr_instance_id = peg.sr_instance_id
             AND     SUP.organization_id = peg.organization_id
             AND     SUP.inventory_item_id = peg.inventory_item_id
             AND     SUP.order_type = 5
             AND     SUP.transaction_id = peg.transaction_id )
          WHERE   madpt.plan_id = p_plan_id
          -- Bug 3750638 Comment out sr_instance_id to support multi-instance plans.
          AND     madpt.sr_instance_id = c_items_rec.sr_instance_id
          AND     madpt.reference_item_id =  c_items_rec.inventory_item_id
          AND     madpt.sales_order_line_id = c_items_rec.sales_order_line_id
          AND     decode(madpt.demand_source_type,100,madpt.demand_source_type,-1)
                  =decode(c_items_rec.demand_source_type,
                                                   100,
                                                   c_items_rec.demand_source_type,
                                                   -1) --CMRO;
          AND     madpt.inventory_item_id <> madpt.reference_item_id
          -- Bug 3750638
          -- Date is used to filter out other records.
          AND     madpt.supply_date IS NULL
          AND     madpt.supply_type = 5
          -- Other filtering conditions that may potentially be added include end_demand_id
          -- Collect Supplies into Supplies PL/SQL Array.
          RETURNING
                  inventory_item_id,
                  sr_instance_id,
                  base_item_id,
                  sales_order_line_id,
                  demand_source_type,
                  end_demand_id,
                  supply_id,
                  pegging_id,
                  end_pegging_id
          BULK COLLECT INTO
                  L_Config_Sup.INVENTORY_ITEM_ID,
                  L_Config_Sup.SR_INSTANCE_ID,
                  L_Config_Sup.BASE_ITEM_ID,
                  L_Config_Sup.SALES_ORDER_LINE_ID,
                  L_Config_Sup.DEMAND_SOURCE_TYPE,
                  L_Config_Sup.END_DEMAND_ID,
                  L_Config_Sup.SUPPLY_ID,
                  L_Config_Sup.PEGGING_ID,
                  L_Config_Sup.END_PEGGING_ID
          ;
          -- End Bug 3750638

          -- Bug 3750638 Re-set the Count of Items to be processed.
          l_multi_config_count := L_Config_Sup.INVENTORY_ITEM_ID.COUNT;
          l_config_level := l_config_level + 1;

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('Gen_Atp_Pegging : Stage 4 ' );
            msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
            -- Bug 3750638 Print Out value of variables.
            msc_util.msc_log('Gen_Atp_Pegging : l_multi_config_count ' || l_multi_config_count );
            msc_util.msc_log('Gen_Atp_Pegging : l_config_level ' || l_config_level );
          END IF;

      END LOOP;
      -- End Bug 3750638

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Get_Pegging_Data_Loop. Error : ' || sqlcode || ': ' || sqlerrm);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Pegging_Data_Loop;
-- End Bug 3750638 Move all the pegging releated SQLs into this procedure.

-- This procedure is the main procedure that creates the ATP simplified pegging
-- and stores it into the msc_atp_pegging table after plan run.
PROCEDURE Generate_Simplified_Pegging(p_plan_id         IN          NUMBER,
                                      p_share_partition IN          VARCHAR2,
                                      p_applsys_schema  IN          VARCHAR2,
                                      RETCODE           OUT  NoCopy NUMBER   )
IS

l_count                         number;
l_row_count                     number;
l_tot_count                     NUMBER;
l_partition_name                varchar2(30);
l_sql_stmt                      varchar2(800); -- Bug 3344012 expand size.
l_sql_stmt_1                    varchar2(8000);
l_sql_stmt_2                    varchar2(8000); --CTO-PF
l_ret_code                      NUMBER;
l_err_msg                       VARCHAR2(1000);
l_ind_tbspace                   VARCHAR2(30);
l_insert_stmt                   VARCHAR2(8000);
l_msc_schema                    VARCHAR2(30);
l_sysdate                       date;
l_user_id                       number;
l_table_name                    VARCHAR2(30);
l_tbspace                       VARCHAR2(30);
l_temp_table                    VARCHAR2(30);
atp_simple_peg_tab              MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(
                                                                'ATP_PEGGING');
l_share_partition               VARCHAR2(1);
l_plan_id                       NUMBER;
l_plan_name                     varchar2(10);

/* Currently the ATP Pegging Record Types will be defined local to this package. */
-- Records for carrying ATP Pegging information
atp_peg_tab                     ATP_Simple_Peg_Typ;
atp_peg_det                     ATP_Detail_Peg_Typ;
fcst_data_tab                   ATP_Fcst_Cons_Typ;
l_pegging_id                    NUMBER;

-- Bug 3362558 Store the original_demand_id
-- CTO_PF_PRJ. This array is not needed anymore.
l_original_demand_ids            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
-- CTO-PF
l_time_phased_atp               VARCHAR2(1) := 'N';
-- This cursor fetches the list of configuration_items.
CURSOR config_items IS
   SELECT distinct msi.item_name, msi.inventory_item_id, msi.sr_inventory_item_id,
          msi.sr_instance_id, msi.base_item_id, d.sales_order_line_id,
          decode(d.demand_source_type, 100,  -- cmro fix
                       d.demand_source_type, -1) demand_source_type, -- cmro fix
          d.demand_class, d.demand_id  -- Bug 3319810 Add the sales_order demand class
   FROM   msc_system_items msi, msc_demands d
   WHERE  msi.plan_id = p_plan_id
   AND    msi.bom_item_type = 4
   AND    msi.base_item_id is NOT NULL
   AND    msi.replenish_to_order_flag = 'Y'
   AND    d.plan_id = msi.plan_id
   AND    d.sr_instance_id = msi.sr_instance_id
   AND    d.inventory_item_id = msi.inventory_item_id
   AND    d.organization_id = msi.organization_id
   AND    d.using_requirement_quantity > 0
   AND    d.origination_type in (6, 30)
 ;
      -- conditions to filter out records to be added
      -- using replenish_to_order_flag and pick_components_flag
-- Define a corresponding record.
c_items_rec                     ATP_End_Config_Dmd_Typ;

l_order_org_ratio               NUMBER;

i                               NUMBER;
j                               NUMBER;
k                               NUMBER;
n                               NUMBER;
rows_processed                  NUMBER;
l_hash_size                     NUMBER := -1;
l_sort_size                     NUMBER := -1;
l_parallel_degree               NUMBER := 1;
l_total_relief_qty              NUMBER;
l_return_status                 VARCHAR2(1);

l_timestamp                     NUMBER;

-- Bug 3344102 Use Global Temporary table to store intermediate data.
l_global_temp_table               VARCHAR2(30);
l_insert_temp_table               VARCHAR2(30);
l_ins_sql_stmt                    VARCHAR2(8000);
  -- For use as a switch between tables.

-- Bug 3701093 Flag to control creation of offsets/reliefs/adjustments
-- Values 1 TRUE, otherwise FALSE
G_ADJUST_FLAG                   NUMBER;
-- A Sales Order could be pegged to multiple Plan Orders with
-- multiple end pegging ids.
-- This variable is introduced for better control of the Adjustment process.
L_TOT_RELIEF_QTY                NUMBER;
l_peg_relief_qty                NUMBER;
--bug 3950208
l_err_buf                      varchar2(4000);
l_call_status boolean;

l_phase            varchar2(80);
l_status           varchar2(80);
l_dev_phase        varchar2(80);
l_dev_status       varchar2(80);
l_message          varchar2(2048);
l_request_id       number;
i                  number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
    msc_util.msc_log('***** Begin Generate_Simplified_Pegging (Gen_Atp_Pegging) *****');
    msc_util.msc_log('Gen_Atp_Pegging : p_plan_id ' || p_plan_id);
    msc_util.msc_log('Gen_Atp_Pegging : p_share_partition ' || p_share_partition);
    msc_util.msc_log('Gen_Atp_Pegging : p_applsys_schema ' || p_applsys_schema);
  END IF;

  --RETCODE := G_SUCCESS;

  -- Initialize variables;

    SELECT  a.oracle_username,
            sysdate,
            FND_GLOBAL.USER_ID
    INTO    l_msc_schema,
            l_sysdate,
            l_user_id
    FROM    fnd_oracle_userid a,
            fnd_product_installations b
    WHERE   a.oracle_id = b.oracle_id
    AND     b.application_id = 724;

  -- First get the performance parameters.

  BEGIN
     SELECT      NVL(pre_alloc_hash_size, -1),
                 NVL(pre_alloc_sort_size, -1),
                 NVL(pre_alloc_parallel_degree, 1)
     INTO        l_hash_size,
                 l_sort_size,
                 l_parallel_degree
     FROM        msc_atp_parameters
     WHERE       rownum = 1;
     EXCEPTION
         WHEN others THEN
         msc_util.msc_log('Error getting performance param: ' || sqlcode || ': ' || sqlerrm);
         l_hash_size := -1;
         l_sort_size := -1;
         l_parallel_degree := 1;
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_util.msc_log('Hash: ' || l_hash_size || ' Sort: ' || l_sort_size ||
                         ' Parallel: ' || l_parallel_degree);
  END IF;

  IF NVL(l_hash_size, -1) <> -1 THEN
        l_sql_stmt_1 := 'alter session set hash_area_size = ' || to_char(l_hash_size);
        msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
        execute immediate l_sql_stmt_1;
  END IF;

  IF NVL(l_sort_size, -1) <> -1 THEN
         l_sql_stmt_1 := 'alter session set sort_area_size = ' || to_char(l_sort_size);
         msc_util.msc_log('l_sql_stmt : ' || l_sql_stmt_1);
         execute immediate l_sql_stmt_1;
  END IF;

  -- Second set the table names.

  -- Bug 3344102
  -- Set the Global temporary table name.
  l_global_temp_table   := 'MSC_ATP_PEG_TEMP';
  -- End Bug 3344102

  FOR i in 1..atp_simple_peg_tab.count LOOP

        l_table_name := 'MSC_' || atp_simple_peg_tab(i);

        IF (p_share_partition = 'Y') THEN
           l_plan_id := MAXVALUE;
        ELSE
           l_plan_id := p_plan_id;
        END IF;

        l_partition_name :=  atp_simple_peg_tab(i)|| '_' || l_plan_id;
        IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('l_partition_name := ' || l_partition_name);
        END IF;

        BEGIN
            SELECT count(*)
            INTO   l_count
            --bug 2495962: Change refrence from dba_xxx to all_xxx tables
            --FROM   dba_tab_partitions
            FROM   all_tab_partitions
            WHERE  table_name = l_table_name
            AND    partition_name = l_partition_name
            AND    table_owner = l_msc_schema;
        EXCEPTION
            WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_util.msc_log('Inside Exception');
              END IF;
                 l_count := 0;
        END;


        IF (l_count = 0) THEN
           /* --bug 3950208: Create partitions if partitons are missing in this table
           -- Bug 2516506
           FND_MESSAGE.SET_NAME('MSC', 'MSC_ATP_PLAN_PARTITION_MISSING');
           FND_MESSAGE.SET_TOKEN('PLAN_NAME', l_plan_name);
           FND_MESSAGE.SET_TOKEN('TABLE_NAME', 'MSC_' || atp_simple_peg_tab(i));
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_util.msc_log(FND_MESSAGE.GET);
           END IF;
           msc_util.msc_log('MSC_ATP_PLAN_PARTITION_MISSING : Partition ' || l_partition_name || ' NOT FOUND');
           -- Find out presence of config items.
           SELECT 1
           INTO   l_count
           FROM   msc_system_items msi, msc_demands d
           WHERE  msi.plan_id = p_plan_id
           AND    msi.bom_item_type = 4
           AND    msi.base_item_id is NOT NULL
           AND    msi.replenish_to_order_flag = 'Y'
           AND    d.plan_id = msi.plan_id
           AND    d.sr_instance_id = msi.sr_instance_id
           AND    d.inventory_item_id = msi.inventory_item_id
           AND    d.organization_id = msi.organization_id
           AND    d.using_requirement_quantity > 0
           AND    d.origination_type in (6, 30)
           AND    ROWNUM = 1 ;

           IF l_count > 0 THEN
              msc_util.msc_log('Config Items are present, Partition needs to be created : ERROR.');
              RETCODE := G_ERROR;
           ELSE
              msc_util.msc_log('Config Items are absent, Partition not present flagged as WARNING.');
              RETCODE := G_WARNING;
           END IF;
           RETURN;
           */
           msc_util.msc_log('Partitions are not found in MSC_ATP_PEGGING. Launch request to create partitions');
           l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                        'MSC',
                                        'MSCSUPRT',
                                        NULL,   -- description
                                        NULL,   -- start time
                                        FALSE);  -- sub request

           msc_util.msc_log('Request to create partition is launched with request id := ' || l_request_id);
           commit;

           LOOP
               l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                                      ( l_request_id,
                                        NULL,
                                        NULL,
                                        l_phase,
                                        l_status,
                                        l_dev_phase,
                                        l_dev_status,
                                        l_message);


               IF (l_call_status=FALSE) THEN
                   msc_util.msc_log('Error in creating ATP partitions. Please run Create ATP Partitions program
                                     and then run ATP Post Plan Processing Again');
                   RETCODE := G_ERROR;
                   RETURN;
               END IF;

               msc_util.msc_log('l_dev_phase := ' || l_dev_phase);

               EXIT WHEN l_dev_phase = 'COMPLETE';

           END LOOP;

        END IF;
  END LOOP;

  IF p_share_partition = 'Y' THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('before deleting old ATP pegging data');
    END IF;

    DELETE MSC_ATP_PEGGING where plan_id = p_plan_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('After deleting old ATP pegging info');
    END IF;

  END IF;

  IF p_share_partition = 'Y' THEN

        l_temp_table := 'MSC_ATP_PEGGING';
  ELSE

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('not a shared plan partition, insert data into temp tables');
    END IF;

    l_temp_table := 'MSC_TEMP_ATP_PEGG_'|| to_char(l_plan_id);

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('temp table : ' || l_temp_table);
    END IF;

    SELECT  t.tablespace_name, NVL(i.def_tablespace_name, t.tablespace_name)
    INTO    l_tbspace, l_ind_tbspace
    FROM    all_tab_partitions t,
            all_part_indexes i
    WHERE   t.table_owner = l_msc_schema
    AND     t.table_name = 'MSC_ATP_PEGGING'
    AND     t.partition_name = l_partition_name
    AND     i.owner (+) = t.table_owner
    AND     i.table_name (+) = t.table_name
    AND     rownum = 1;

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('tb space : ' || l_tbspace);
        msc_util.msc_log('ind tbspace : ' || l_ind_tbspace);
    END IF;

--6113544
     l_insert_stmt := 'CREATE TABLE ' || l_temp_table
           || ' TABLESPACE ' || l_tbspace
           || ' PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)'
           || ' as select * from MSC_ATP_PEGGING where 1=2 ';

/*
    l_insert_stmt := 'CREATE TABLE ' || l_temp_table || '(
                         plan_id                 NUMBER          NOT NULL,
                         sr_instance_id          NUMBER          NOT NULL,
                         reference_item_id       NUMBER          NOT NULL,
                         inventory_item_id       NUMBER          NOT NULL,
                         organization_id         NUMBER          NOT NULL,
                         sales_order_line_id     NUMBER          NOT NULL,
                         bom_item_type           NUMBER,
                         sales_order_qty         NUMBER,
                         transaction_date        NUMBER,
                         demand_id               NUMBER,
                         demand_quantity         NUMBER,
                         disposition_id          NUMBER,
                         demand_class            VARCHAR2(34)    ,
                         consumed_qty            NUMBER,
                         overconsumption_qty     NUMBER,
                         supply_id               NUMBER,
                         supply_quantity         NUMBER,
                         allocated_quantity      NUMBER,
                         resource_id             NUMBER,
                         department_id           NUMBER,
                         resource_hours          NUMBER,
                         daily_resource_hours    NUMBER,
                         start_date              NUMBER,
                         end_date                NUMBER,
                         relief_type             NUMBER,
                         relief_quantity         NUMBER,
                         daily_relief_qty        NUMBER,
                         pegging_id              NUMBER,
                         prev_pegging_id         NUMBER,
                         end_pegging_id          NUMBER,
                         created_by              NUMBER          NOT NULL,
                         creation_date           DATE            NOT NULL,
                         last_updated_by         NUMBER          NOT NULL,
                         last_update_date        DATE            NOT NULL,
                         customer_id             NUMBER,
                         customer_site_id        NUMBER,
                         DEMAND_SOURCE_TYPE      NUMBER, --cmro
                         -- CTO_PF_PRJ changes.
                         end_demand_id           NUMBER
                         )
                            TABLESPACE ' || l_tbspace || '
           --NOLOGGING
          PCTFREE 0 STORAGE(INITIAL 40K NEXT 5M PCTINCREASE 0)';
*/
    IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('before creating table : ' || l_temp_table);
    END IF;

    BEGIN
         ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
              APPLICATION_SHORT_NAME => 'MSC',
              STATEMENT_TYPE => ad_ddl.create_table,
              STATEMENT => l_insert_stmt,
              OBJECT_NAME => l_temp_table);
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_util.msc_log('after creating table : ' || l_temp_table);
      END IF;

    EXCEPTION
       WHEN others THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log(sqlcode || ': ' || sqlerrm);
            msc_util.msc_log('Exception of create table : ' || l_temp_table);
         END IF;
            ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.drop_table,
                   STATEMENT =>  'DROP TABLE ' || l_temp_table,
                   OBJECT_NAME => l_temp_table);

         IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('After Drop table : ' ||l_temp_table);
            msc_util.msc_log('Before exception create table : ' ||l_temp_table);
         END IF;

            ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.create_table,
                   STATEMENT => l_insert_stmt,
                   OBJECT_NAME => l_temp_table);
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('After exception create table : ' ||l_temp_table);
         END IF;
    END;
  END IF;  -- p_share_partition = 'Y'

    OPEN config_items;

    select hsecs
    into   l_timestamp
    from   v$timer;

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_util.msc_log('Gen_Atp_Pegging : After opening config_items ');
       msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 1 ' || l_timestamp);
    END IF;

    LOOP  -- Begin config_items loop
      IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Gen_Atp_Pegging : Before fetch config_items Cursor');
      END IF;
      FETCH config_items INTO c_items_rec;
      EXIT WHEN config_items%NOTFOUND;

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Gen_Atp_Pegging : After fetch config_items Cursor');
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.item_name ' ||
                                                       c_items_rec.item_name);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.inventory_item_id ' ||
                                                       c_items_rec.inventory_item_id);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.sr_inventory_item_id ' ||
                                                       c_items_rec.sr_inventory_item_id);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.sr_instance_id ' ||
                                                       c_items_rec.sr_instance_id);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.base_item_id ' ||
                                                       c_items_rec.base_item_id);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.sales_order_line_id ' ||
                                                       c_items_rec.sales_order_line_id);
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.demand_source_type' ||
                                                       c_items_rec.demand_source_type);--cmro
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.demand_class' ||
                                           c_items_rec.demand_class); --Bug 3319180
          msc_util.msc_log('Gen_Atp_Pegging : c_items_rec.demand_id' ||
                                           c_items_rec.demand_id); --Bug 3750638
          msc_util.msc_log('Gen_Atp_Pegging : Plan Id ' || p_plan_id );
          msc_util.msc_log('Gen_Atp_Pegging : Stage 0 ' );
      END IF;

      -- Bug 3750638 Call the SQL statements now moved to a new procedure
      Get_Pegging_Data_Loop ( p_plan_id,
                              c_items_rec,
                              l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging: ' ||
               'Error occured in procedure Get_Pegging_Data_Loop');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- End Bug 3750638 Call the SQL statements now moved to a new procedure


    select hsecs
    into   l_timestamp
    from   v$timer;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Stage 5 ' );
        msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 3 ' || l_timestamp);
      END IF;

      -- Fetch the data into PL/SQL record of tables.
      SELECT
              reference_item_id, base_item_id,
              inventory_item_id,
              plan_id,
              sr_instance_id,
              organization_id,
              end_item_usage,
              bom_item_type, fixed_lt, variable_lt,
              sales_order_line_id,
              demand_source_type,--cmro
              sales_order_qty,
              demand_id,
              demand_date,
              demand_quantity,
              disposition_id,
              demand_class,
              demand_type,
              original_demand_id,
              process_seq_id, supply_id,
              supply_date,
              supply_quantity,
              allocated_quantity, tot_relief_qty,
              supply_type,
              firm_planned_type,
              release_status,
              exclude_flag,    -- All other cases exclude
              order_number,
              end_pegging_id, pegging_id,  prev_pegging_id,
              fcst_organization_id, forecast_qty,
              consumed_qty, overconsumption_qty,
              -- CTO_PF_PRJ changes.
              end_demand_id,
              --CTO-PF
              atf_date,
              product_family_id
      BULK COLLECT INTO
              atp_peg_det.reference_item_id, atp_peg_det.base_item_id,
              atp_peg_det.inventory_item_id, atp_peg_det.plan_id, atp_peg_det.sr_instance_id,
              atp_peg_det.organization_id, atp_peg_det.end_item_usage, atp_peg_det.bom_item_type,
              atp_peg_det.fixed_lt, atp_peg_det.variable_lt,
              atp_peg_det.sales_order_line_id,atp_peg_det.demand_source_type,atp_peg_det.sales_order_qty, --cmro
              atp_peg_det.demand_id, atp_peg_det.demand_date,
              atp_peg_det.demand_quantity, atp_peg_det.disposition_id,
              atp_peg_det.demand_class, atp_peg_det.demand_type, atp_peg_det.original_demand_id,
              atp_peg_det.process_seq_id, atp_peg_det.supply_id, atp_peg_det.supply_date,
              atp_peg_det.supply_quantity, atp_peg_det.allocated_quantity,
              atp_peg_det.tot_relief_qty, atp_peg_det.supply_type,
              atp_peg_det.firm_planned_type, atp_peg_det.release_status,
              atp_peg_det.exclude_flag, atp_peg_det.order_number,
              atp_peg_det.end_pegging_id, atp_peg_det.pegging_id, atp_peg_det.prev_pegging_id,
              atp_peg_det.fcst_organization_id, atp_peg_det.forecast_qty,
              atp_peg_det.consumed_qty, atp_peg_det.overconsumption_qty,
              -- CTO_PF_PRJ changes.
              atp_peg_det.end_demand_id,
              -- CTO-PF
              atp_peg_det.atf_date,
              atp_peg_det.product_family_id
      FROM
              msc_atp_detail_peg_temp
      WHERE   plan_id = p_plan_id
      AND     sr_instance_id (+) = c_items_rec.sr_instance_id -- outer join to get all instances
      AND     reference_item_id = c_items_rec.inventory_item_id
      AND     sales_order_line_id = c_items_rec.sales_order_line_id
      AND     Decode(demand_source_type,100,demand_source_type,-1)
              =decode(c_items_rec.demand_source_type,
                                                100,
                                                c_items_rec.demand_source_type,
                                                -1) --CMRO
      ORDER BY
               end_pegging_id, prev_pegging_id,
               demand_date, supply_date,
               pegging_id DESC     -- prev_pegging_id, pegging_id DESC ???
      ;



    select hsecs
    into   l_timestamp
    from   v$timer;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Stage 6 ' );
        msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
        msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 4 ' || l_timestamp);
      END IF;


      -- Obtain and Assign forecast consumption info.
      FOR i in 1..atp_peg_det.inventory_item_id.COUNT LOOP
         -- Obtain forecast consumption info only for config items.
         IF (atp_peg_det.bom_item_type(i) = 4 AND
             atp_peg_det.base_item_id(i) IS NOT NULL ) THEN
            -- Bug 3362558 Display the original_demand_id
            IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log('Gen_Atp_Pegging : End Demand Id for Sales Order: ' ||
                  -- CTO_PF_PRJ changes. Use end_demand_id
                                  atp_peg_det.end_demand_id(i) );
                                  --l_original_demand_ids(1) );
            END IF;
            -- End Bug 3362558
            Get_Forecast_Consumption(atp_peg_det, i, fcst_data_tab, l_return_status);
            l_total_relief_qty  := 0;
          IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('Gen_Atp_Pegging : Stage 7 ' );
            msc_util.msc_log('Gen_Atp_Pegging : Status post Fcst Consumption.' ||
                                                           l_return_status );
            msc_util.msc_log('Gen_Atp_Pegging : Fcst Data Count.' ||
                                               fcst_data_tab.inventory_item_id.Count);
          END IF;
         END IF;

         -- Re-initialize org_ratio

         l_order_org_ratio := NULL;
         -- Bug 3701093
         -- Initialize G_ADJUST_FLAG to 1, Default is to generate offsets.
         G_ADJUST_FLAG := 1;

         -- Here in this loop, the total relief quantities will also be determined.
         FOR j in 1..fcst_data_tab.inventory_item_id.COUNT LOOP
           IF (atp_peg_det.inventory_item_id(i) = fcst_data_tab.inventory_item_id(j) AND
               atp_peg_det.plan_id(i) = fcst_data_tab.plan_id(j) AND
               atp_peg_det.sr_instance_id(i) = fcst_data_tab.sr_instance_id(j) AND
               (atp_peg_det.original_demand_id(i) = fcst_data_tab.sales_order_id(j) OR
                -- Bug 3362558
                -- Global forecasting situation, org_id is -1.
                (fcst_data_tab.fcst_organization_id(j) = -1 AND
                  -- CTO_PF_PRJ changes. Use end_demand_id
                 fcst_data_tab.sales_order_id(j) = atp_peg_det.end_demand_id(i) ) OR
                atp_peg_det.demand_id(i) = fcst_data_tab.sales_order_id(j)  ) ) THEN

               atp_peg_det.forecast_qty(i) := fcst_data_tab.forecast_qty(j);
               atp_peg_det.bom_item_type(i) := fcst_data_tab.bom_item_type(j);

               -- Set the distribution of order ratio
               -- The same order can be satisfied using multiple organizations.
               -- The ratio below factors that in.

               IF (atp_peg_det.allocated_quantity(i) < fcst_data_tab.consumed_qty(j)
                                                    + NVL(fcst_data_tab.overconsumption_qty(j),0) ) THEN
                   l_order_org_ratio := atp_peg_det.allocated_quantity(i) /
                                            (fcst_data_tab.consumed_qty(j) +
                                                NVL(fcst_data_tab.overconsumption_qty(j), 0)
                                            );
               ELSE
                   l_order_org_ratio := 1;
               END IF;

               atp_peg_det.consumed_qty(i) := NVL(fcst_data_tab.consumed_qty(j), 0) *
                                                                 l_order_org_ratio;
               atp_peg_det.overconsumption_qty(i) := NVL(fcst_data_tab.overconsumption_qty(j), 0)
                                                         * l_order_org_ratio;

               -- Determine the Total relief quantity across all organizations.
               IF ((fcst_data_tab.consumed_qty(j) IS NOT NULL) AND
                   (fcst_data_tab.sales_order_qty(j) > fcst_data_tab.consumed_qty(j))) THEN

                  atp_peg_det.tot_relief_qty(i) := fcst_data_tab.consumed_qty(j) -
                                                   fcst_data_tab.sales_order_qty(j);
               ELSE

                  -- If the sales order is not greater than the consumption
                  -- nothing to relieve at the configuration item level.
                  atp_peg_det.tot_relief_qty(i) := 0;
               END IF;

               l_total_relief_qty := atp_peg_det.tot_relief_qty(i);
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_util.msc_log('Gen_Atp_Pegging :  Total Relief Qty' ||
                                                           l_total_relief_qty);
                 msc_util.msc_log('Gen_Atp_Pegging :  FC Consumtion Flag' ||
                                                   fcst_data_tab.cons_config_mod_flag(j));
               END IF;

               -- Bug 3701093
               IF (fcst_data_tab.cons_config_mod_flag(j) = C_CONFIG_FCST_CONSUMED) AND
                  (atp_peg_det.reference_item_id(i) = fcst_data_tab.inventory_item_id(j)) THEN
                  G_ADJUST_FLAG := 0;
                  -- No offset data generation generation necessary when TOP LEVEL
                  -- config item's forecast can completely satisfy the Sales Order.

               ELSE
                 FOR n in 1..atp_peg_det.inventory_item_id.COUNT LOOP

                   -- Set the total_relief_qty for components pegged to the configuration_item
                   IF (atp_peg_det.plan_id(n) = atp_peg_det.plan_id(i) AND
                     atp_peg_det.disposition_id(n) = atp_peg_det.supply_id(i) ) THEN

                      atp_peg_det.tot_relief_qty(n) := atp_peg_det.tot_relief_qty(i)
                                                   * atp_peg_det.end_item_usage(n) / atp_peg_det.end_item_usage(i);

                   END IF;

                 END LOOP;
               END IF;
           -- match with base model
           ELSIF
               (atp_peg_det.plan_id(i) = fcst_data_tab.plan_id(j) AND
               atp_peg_det.sr_instance_id(i) = fcst_data_tab.sr_instance_id(j) AND
               atp_peg_det.base_item_id(i) = fcst_data_tab.inventory_item_id(j)  AND
               atp_peg_det.organization_id(i) = fcst_data_tab.organization_id(j) AND
               -- Bug 3319810 For lower level model the demand type will not be
               -- Sales Order, hence commented out.
               -- atp_peg_det.demand_type(i) in (6, 30) AND
               (atp_peg_det.original_demand_id(i) = fcst_data_tab.sales_order_id(j) OR
                -- Bug 3362558
                -- Global forecasting situation, org_id is -1.
                (fcst_data_tab.fcst_organization_id(j) = -1 AND
                  -- CTO_PF_PRJ changes. Use end_demand_id
                 fcst_data_tab.sales_order_id(j) = atp_peg_det.end_demand_id(i) ) OR
                atp_peg_det.demand_id(i) = fcst_data_tab.sales_order_id(j) ) ) THEN

               -- Will the ratio determined using the model work as well?
               -- Set the ratio
               -- Set the distribution of order ratio
               -- The same order can be satisfied using multiple organizations.
               -- The ratio below factors that in.
               IF (l_order_org_ratio IS NULL AND
                   atp_peg_det.allocated_quantity(i) < fcst_data_tab.consumed_qty(j) +
                                                     NVL(fcst_data_tab.overconsumption_qty(j), 0) ) THEN
                   l_order_org_ratio := atp_peg_det.allocated_quantity(i) /
                                            (fcst_data_tab.consumed_qty(j) +
                                          NVL(fcst_data_tab.overconsumption_qty(j), 0));
               ELSE
                   l_order_org_ratio := 1;
               END IF;
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_util.msc_log('Gen_Atp_Pegging :  fcst_data_tab.inventory_item_id(j)' ||
                                                fcst_data_tab.inventory_item_id(j));
                 msc_util.msc_log('Gen_Atp_Pegging :  fcst_data_tab.consumed_qty(j)' ||
                                                fcst_data_tab.consumed_qty(j));
                 msc_util.msc_log('Gen_Atp_Pegging : fcst_data_tab.sales_order_id(j)' ||
                                                fcst_data_tab.sales_order_id(j));
                 msc_util.msc_log('Gen_Atp_Pegging :  l_order_org_ratio' ||
                                                             l_order_org_ratio);
                 msc_util.msc_log('Gen_Atp_Pegging :  FC Consumtion Flag' ||
                                                   fcst_data_tab.cons_config_mod_flag(j));
               END IF;
               -- Bug 3701093 Model Forecast Has been consumed,
               -- Generate Offsets for  Model.
               IF fcst_data_tab.cons_config_mod_flag(j) = C_MODEL_FCST_CONSUMED THEN
                  Extend_Atp_Peg_Det (atp_peg_det, l_return_status, 1);

                  k := atp_peg_det.reference_item_id.Count;

                  atp_peg_det.reference_item_id(k) := atp_peg_det.reference_item_id(i);
                  atp_peg_det.base_item_id(k) := NULL;
                  atp_peg_det.inventory_item_id(k) := fcst_data_tab.inventory_item_id(j);
                  atp_peg_det.plan_id(k) := atp_peg_det.plan_id(i);
                  atp_peg_det.sr_instance_id(k) := atp_peg_det.sr_instance_id(i);
                  atp_peg_det.organization_id(k) := atp_peg_det.organization_id(i);
                  atp_peg_det.bom_item_type(k) := fcst_data_tab.bom_item_type(j);
                  -- Configuration Item's lead times are used.
                  atp_peg_det.fixed_lt(k) := atp_peg_det.fixed_lt(i);
                  atp_peg_det.variable_lt(k) := atp_peg_det.variable_lt(i);
                  atp_peg_det.sales_order_qty(k) := fcst_data_tab.sales_order_qty(j);
                  atp_peg_det.sales_order_line_id(k) := atp_peg_det.sales_order_line_id(i);
                  atp_peg_det.demand_source_type(k) := atp_peg_det.demand_source_type(i);--cmro
                  atp_peg_det.demand_id(k) := fcst_data_tab.fcst_demand_id(j);
                  atp_peg_det.demand_date(k) := atp_peg_det.demand_date(i);
                  -- Set the demand_date for the model to be that
                  -- of configuration item's date, No offsets for model .
                  -- For sub-components other than models offset is applied
                  -- during calculation of relief quantities.
                  atp_peg_det.demand_quantity(k) :=  NVL(atp_peg_det.demand_quantity(i), 0) -
                                           NVL(atp_peg_det.consumed_qty (i) , 0);
                  -- Set the demand_quantity to be that of the configuration item's demand
                  -- after factoring the consumption.
                  atp_peg_det.disposition_id(k) :=  atp_peg_det.supply_id(i);

                  atp_peg_det.demand_class(k) := atp_peg_det.demand_class(i);
                  atp_peg_det.demand_type(k) := 1;  -- Plan Order Demand
                  atp_peg_det.original_demand_id(k) := atp_peg_det.original_demand_id(i);
                  -- CTO_PF_PRJ changes. Set end_demand_id
                  atp_peg_det.end_demand_id(k) := atp_peg_det.end_demand_id(i);

                  atp_peg_det.fcst_organization_id(k) :=
                                          fcst_data_tab.fcst_organization_id(j);
                  atp_peg_det.forecast_qty(k) := fcst_data_tab.forecast_qty(j) ;
                  atp_peg_det.consumed_qty(k) := NVL(fcst_data_tab.consumed_qty(j), 0) *
                                                                 l_order_org_ratio;
                  atp_peg_det.overconsumption_qty(k) :=
                                     NVL(fcst_data_tab.overconsumption_qty(j), 0)
                                                         * l_order_org_ratio;
                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_util.msc_log('Gen_Atp_Pegging : atp_peg_det.consumed_qty(k)' ||
                                                       atp_peg_det.consumed_qty(k));
                     msc_util.msc_log('Gen_Atp_Pegging : atp_peg_det.overconsumption_qty(k)' ||
                                                atp_peg_det.overconsumption_qty(k));
                  END IF;
                  -- For now the process_seq_id remains unassigned
                  -- atp_peg_det.process_seq_id(k) := atp_peg_det.process_seq_id(i) ;
                  -- What to do with the Supply for model and the components?
                  -- Currently everything is set to NULL.
                  atp_peg_det.supply_id(k) := NULL;
                  atp_peg_det.supply_date(k) := NULL;
                  atp_peg_det.supply_quantity(k) := NULL;
                  -- Bug 3805136 Set the allocated_quantity to Config's allocated_quantity
                  atp_peg_det.allocated_quantity(k) := atp_peg_det.allocated_quantity(i);
                  -- End Bug 3805136
                  atp_peg_det.supply_type(k) := NULL;
                  atp_peg_det.firm_planned_type(k) := NULL;
                  atp_peg_det.release_status(k) := NULL;

                  atp_peg_det.end_item_usage(k) := atp_peg_det.end_item_usage(i);

                  atp_peg_det.exclude_flag(k) := atp_peg_det.exclude_flag(i);

                  atp_peg_det.order_number(k) := atp_peg_det.order_number(i);

                  atp_peg_det.end_pegging_id(k) := atp_peg_det.end_pegging_id(i);
                  atp_peg_det.pegging_id(k) := NULL;
                  -- Note that the prev_pegging_id is linked to the Configuration Item's
                  -- Pegging Id.
                  atp_peg_det.prev_pegging_id(k) := atp_peg_det.pegging_id(i);
               END IF;
               -- End Bug 3701093

               -- Determine the Total relief quantity across all organizations.
               IF ((fcst_data_tab.consumed_qty(j) IS NOT NULL) OR
                   (fcst_data_tab.overconsumption_qty(j) IS NOT NULL) ) THEN

                  -- Config is relieved to the extent of consumption + overconsumption.
                  atp_peg_det.tot_relief_qty(i) := -1 * (fcst_data_tab.consumed_qty(j) +
                                                   fcst_data_tab.overconsumption_qty(j) );
               -- Bug 3805136 No forecast consumed, total_relief_qty remains NULL
               ELSIF (fcst_data_tab.cons_config_mod_flag(j) = C_NO_FCST_CONSUMED) THEN
                  atp_peg_det.tot_relief_qty(i) := NULL;  -- Remains NULL
               -- Bug 3805136
               ELSE

                  atp_peg_det.tot_relief_qty(i) := 0;
               END IF;
               -- Bug 3701093 Model Forecast Has been consumed,
               -- Generate Offsets for  Model.
               IF fcst_data_tab.cons_config_mod_flag(j) = C_MODEL_FCST_CONSUMED THEN
                  -- Set the Relief Qty for the model
                  atp_peg_det.tot_relief_qty(k) := atp_peg_det.tot_relief_qty(i);
               END IF;
               -- End Bug 3701093

               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.tot_relief_qty(i) ' ||
                                                             atp_peg_det.tot_relief_qty(i));
                 msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.inventory_item_id(i) '
                                                     ||   atp_peg_det.inventory_item_id(i));
               END IF;
               FOR n in 1..atp_peg_det.inventory_item_id.COUNT LOOP

                 -- Set the total_relief_qty for components pegged to the configuration_item
                 IF (atp_peg_det.plan_id(n) = atp_peg_det.plan_id(i) AND
                     atp_peg_det.tot_relief_qty(n) IS NULL AND
                     -- Bug 3805136 Link up the pegging.
                     atp_peg_det.prev_pegging_id(n) = atp_peg_det.pegging_id(i) AND
                     -- and forecast consumption happens
                     atp_peg_det.tot_relief_qty(i) IS NOT NULL AND
                     --  End Bug 3805136
                     atp_peg_det.disposition_id(n) = atp_peg_det.supply_id(i) ) THEN

                      atp_peg_det.tot_relief_qty(n) := atp_peg_det.tot_relief_qty(i)
                                                   * atp_peg_det.end_item_usage(n) / atp_peg_det.end_item_usage(i);

                  IF PG_DEBUG in ('Y', 'C') THEN
                    msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.tot_relief_qty(n) ' ||
                                                             atp_peg_det.tot_relief_qty(n));
                    msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.inventory_item_id(n) '
                                                     ||   atp_peg_det.inventory_item_id(n));
                    msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.pegging_id(n) '
                                                     ||   atp_peg_det.pegging_id(n));
                    msc_util.msc_log('Gen_Atp_Pegging :  ' ||
                     'atp_peg_det.allocated_quantity(n) '|| atp_peg_det.allocated_quantity(n));
                  END IF;
                 END IF;

               END LOOP;
           -- other phantom items
           -- other items only in the manufacturing organization.
           ELSIF (atp_peg_det.process_seq_id(i) is NOT NULL ) AND
                  atp_peg_det.plan_id(i) = fcst_data_tab.plan_id(j) AND
                  atp_peg_det.sr_instance_id(i) = fcst_data_tab.sr_instance_id(j) AND
                  atp_peg_det.inventory_item_id(i) = fcst_data_tab.parent_item_id(j) AND
                  -- Bug 3319810 For lower level model the demand type will not be
                  -- Sales Order, hence commented out.
                  -- atp_peg_det.demand_type(i) in (6, 30) AND
                  atp_peg_det.organization_id(i) = fcst_data_tab.organization_id(j) THEN
           -- or alternatively
           -- ELSIF (atp_peg_det.source_organization_id(i) IS NULL AND
           --   atp_peg_det.source_supplier_id(i) IS NULL)

             l_row_count :=  1 ;
             -- model has already been factored above.
             l_count :=   atp_peg_det.inventory_item_id.COUNT;

             -- Extend the array by the number of rows in Fcst array.
             Extend_Atp_Peg_Det (atp_peg_det, l_return_status, l_row_count);

             -- Update the total count.
             l_tot_count := l_count + l_row_count;

             IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log('Gen_Atp_Pegging : ATP Inventory_item_id. ' ||
                                                   atp_peg_det.inventory_item_id(i) );
               msc_util.msc_log('Gen_Atp_Pegging : FCST Inventory_item_id. ' ||
                                                 fcst_data_tab.inventory_item_id(j) );
               msc_util.msc_log('Gen_Atp_Pegging : FCST Parent_Item_id. ' ||
                                                 fcst_data_tab.Parent_Item_id(j) );
               msc_util.msc_log('Gen_Atp_Pegging : l_row_count. ' ||
                                                           l_row_count );
               msc_util.msc_log('Gen_Atp_Pegging : l_count. ' ||
                                                           l_count );
               msc_util.msc_log('Gen_Atp_Pegging : l_tot_count. ' ||
                                                           l_tot_count  );
             END IF;
             l_count := l_count + 1;
             -- Append the forecast_data for each config item to
             -- the original array with the phantom items information
             --FOR k in l_count..l_tot_count LOOP

              k:= l_count;
              IF PG_DEBUG in ('Y', 'C') THEN
                msc_util.msc_log('Gen_Atp_Pegging : Value of loop var k. ' || k  );
              END IF;

               atp_peg_det.reference_item_id(k) := atp_peg_det.reference_item_id(i);
               atp_peg_det.base_item_id(k) := NULL;
               atp_peg_det.inventory_item_id(k) := fcst_data_tab.inventory_item_id(j);
               atp_peg_det.plan_id(k) := atp_peg_det.plan_id(i);
               atp_peg_det.sr_instance_id(k) := atp_peg_det.sr_instance_id(i);
               atp_peg_det.organization_id(k) := atp_peg_det.organization_id(i);
               atp_peg_det.bom_item_type(k) := fcst_data_tab.bom_item_type(j);
               -- Individual Item's lead times are used.
               atp_peg_det.fixed_lt(k) := fcst_data_tab.fixed_lt(j);
               atp_peg_det.variable_lt(k) := fcst_data_tab.variable_lt(j);
               atp_peg_det.sales_order_qty(k) := fcst_data_tab.sales_order_qty(j);
               -- Note that the sales_order_qty gets factored in during forecast consumption
               atp_peg_det.sales_order_line_id(k) := atp_peg_det.sales_order_line_id(i);
               atp_peg_det.demand_source_type(k) := atp_peg_det.demand_source_type(i);--cmro
               atp_peg_det.demand_id(k) := fcst_data_tab.fcst_demand_id(j);
               -- Bug 3445664 The date will be NULL for phantom items.
               -- atp_peg_det.demand_date(k) := atp_peg_det.supply_date(i);
                      -- Set the demand_date for the component to be that
                      -- of configuration item's supply date for offsets later.
               -- End Bug 3445664 The date will be NULL for phantom items.
                      -- For sub-components other than models offset is applied
                      -- during calculation of relief quantities.
               atp_peg_det.demand_quantity(k) :=  fcst_data_tab.sales_order_qty(j)
                                                       * l_order_org_ratio ;
               -- Set the demand_quantity to be that of sales_order_quantity.
               -- after applying the organization ratio.
               atp_peg_det.disposition_id(k) :=  atp_peg_det.supply_id(i);

               atp_peg_det.demand_class(k) := atp_peg_det.demand_class(i);
               atp_peg_det.demand_type(k) := 1;  -- Plan Order Demand
               atp_peg_det.original_demand_id(k) := atp_peg_det.original_demand_id(i);
               -- CTO_PF_PRJ changes. Set end_demand_id
               atp_peg_det.end_demand_id(k) := atp_peg_det.end_demand_id(i);

               atp_peg_det.fcst_organization_id(k) := fcst_data_tab.fcst_organization_id(j);
               atp_peg_det.forecast_qty(k) := fcst_data_tab.forecast_qty(j) ;
               atp_peg_det.consumed_qty(k) := NVL(fcst_data_tab.consumed_qty(j), 0) *
                                                                 l_order_org_ratio;
               atp_peg_det.overconsumption_qty(k) := NVL(fcst_data_tab.overconsumption_qty(j), 0)
                                                         * l_order_org_ratio;


               -- For now the process_seq_id remains unassigned
               -- atp_peg_det.process_seq_id(k) := atp_peg_det.process_seq_id(i) ;
               -- What to do with the Supply for model and the components?
               -- Currently everything is set to NULL.
               atp_peg_det.supply_id(k) := NULL;
               atp_peg_det.supply_date(k) := NULL;
               atp_peg_det.supply_quantity(k) := NULL;
               atp_peg_det.allocated_quantity(k) := NULL;
               atp_peg_det.supply_type(k) := NULL;
               atp_peg_det.firm_planned_type(k) := NULL;
               atp_peg_det.release_status(k) := NULL;

               -- Bug 3805136
               -- Set to 1 currently as a default.
               -- Usage Quantity to estimate end_item_usage
               -- Not provided by MBP in msc_forecast_updates currently.
               atp_peg_det.end_item_usage(k) := 1;
               -- Bug 3805136

               atp_peg_det.exclude_flag(k) := atp_peg_det.exclude_flag(i);

               atp_peg_det.order_number(k) := atp_peg_det.order_number(i);

               atp_peg_det.end_pegging_id(k) := atp_peg_det.end_pegging_id(i);
               atp_peg_det.pegging_id(k) := NULL;
               -- Note that the prev_pegging_id is linked to the Configuration Item's
               -- Pegging Id.
               atp_peg_det.prev_pegging_id(k) := atp_peg_det.pegging_id(i);

               -- Determine the Total relief quantity across all organizations.
               IF ((fcst_data_tab.consumed_qty(j) IS NOT NULL) OR
                   (fcst_data_tab.overconsumption_qty(j) IS NOT NULL) ) THEN

                  -- All others also relieved to the extent of consumption + overconsumption.
                  atp_peg_det.tot_relief_qty(k) := -1 * (fcst_data_tab.consumed_qty(j) +
                                                   fcst_data_tab.overconsumption_qty(j) );
               ELSE

                  atp_peg_det.tot_relief_qty(k) := 0;
               END IF;
               -- Bug 3805136 Allocated quantity is positive
               atp_peg_det.allocated_quantity(k) :=  ABS(atp_peg_det.tot_relief_qty(k));
               IF PG_DEBUG in ('Y', 'C') THEN
                 msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.tot_relief_qty(k) ' ||
                                                           atp_peg_det.tot_relief_qty(k));
                 msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.inventory_item_id(k) '
                                                   ||   atp_peg_det.inventory_item_id(k));
                 msc_util.msc_log('Gen_Atp_Pegging :  atp_peg_det.prev_pegging_id(k) '
                                                   ||   atp_peg_det.prev_pegging_id(k));
               END IF;
             --END LOOP;

           END IF;
         END LOOP;  -- j loop for fcst_data_tab
      END LOOP;   -- i loop for atp_peg_det

      -- Initialize the Simplified Pegging PL/SQL array

      Init_Atp_Peg ( atp_peg_tab, l_return_status);
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gen_Atp_Pegging : Initialized Simple Pegging Array ' ||
                                                                    l_return_status);
      END IF;

      -- Bug 3701093
      -- Do the rest of the process only if offset data needs to be generated.
      IF G_ADJUST_FLAG = 1 THEN
         -- To Calculate_Relief_Quantities first
         -- Obtain Simplified Pegging Information
         Create_Simple_Pegging (atp_peg_det, atp_peg_tab, l_return_status);
         select hsecs
         into   l_timestamp
         from   v$timer;

         IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging : Stage 8 After obtaining Simple Pegging ');
           msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 5 ' || l_timestamp);
         END IF;

         -- Calculate and Cascade Relief Quantities
         -- will be strictly chronological.
         -- Relief will be done by traversing the simplified pegging tree.

         -- Initialize the variables
         L_TOT_RELIEF_QTY := NULL;
         l_peg_relief_qty := NULL;
         FOR i in 1..atp_peg_tab.reference_item_id.COUNT LOOP
            -- First relieve the Sales Order
            IF (L_TOT_RELIEF_QTY IS NULL) AND
               (atp_peg_tab.bom_item_type(i) = 4 AND
                atp_peg_tab.reference_item_id(i) = atp_peg_tab.inventory_item_id(i) AND
                atp_peg_tab.relief_type(i) = 2 AND
                atp_peg_tab.prev_pegging_id(i) IS NULL) THEN
               L_TOT_RELIEF_QTY := atp_peg_tab.tot_relief_qty(i);
            END IF;
            IF (atp_peg_tab.bom_item_type(i) = 4 AND
                atp_peg_tab.reference_item_id(i) = atp_peg_tab.inventory_item_id(i) AND
                atp_peg_tab.relief_type(i) = 1) THEN

             IF PG_DEBUG in ('Y', 'C') THEN
               msc_util.msc_log('Gen_Atp_Pegging : reference_item_id ' ||
                                             atp_peg_tab.reference_item_id(i) );
             END IF;
               atp_peg_tab.relief_quantity(i) := 0;

            ELSIF (atp_peg_tab.bom_item_type(i) = 4 AND
                atp_peg_tab.reference_item_id(i) = atp_peg_tab.inventory_item_id(i) AND
                atp_peg_tab.relief_type(i) = 2 AND
                -- Bug 3805136 Do not process excluded supplies
                NVL(atp_peg_tab.exclude_flag(i),0) <> 1 AND
                -- Bug 3761805 Only process the top level pegging in supply chain
                atp_peg_tab.prev_pegging_id(i) IS NULL) THEN

               IF (ABS (L_TOT_RELIEF_QTY ) > 0 ) THEN
                 -- Determine the Relief Quantity for this
                 -- specific pegging_id.
                 IF (ABS (L_TOT_RELIEF_QTY ) >= ABS(atp_peg_tab.allocated_quantity(i)) ) THEN
                     l_peg_relief_qty := -1 * ABS(atp_peg_tab.allocated_quantity(i));
                 ELSE
                     l_peg_relief_qty := L_TOT_RELIEF_QTY;
                 END IF;
                 -- Start with the planned order corresponding to the sales order
                 IF PG_DEBUG in ('Y', 'C') THEN
                   msc_util.msc_log('Gen_Atp_Pegging : reference_item_id ' ||
                                                atp_peg_tab.reference_item_id(i) );
                   msc_util.msc_log('Gen_Atp_Pegging : Pegging Id ' ||
                                             atp_peg_tab.pegging_id(i) );
                   msc_util.msc_log('Gen_Atp_Pegging : Prev Pegging Id ' ||
                                             atp_peg_tab.prev_pegging_id(i) );
                   msc_util.msc_log('Gen_Atp_Pegging : '||
                                     'Total Relief Quantity TRACK L_TOT_RELIEF_QTY   ' ||
                                             L_TOT_RELIEF_QTY );
                   msc_util.msc_log('Gen_Atp_Pegging : '||
                                     'Total Relief Quantity for this Pegged Supply  ' ||
                                             l_peg_relief_qty );
                 END IF;
                 Calculate_Relief_Quantities(atp_peg_tab,
                          atp_peg_tab.pegging_id(i),
                          atp_peg_tab.fixed_lt(i),
                          atp_peg_tab.variable_lt(i),
                          -- Introduce local peg related relief and ratio.
                          atp_peg_tab.tot_relief_qty(i),
                          l_peg_relief_qty / atp_peg_tab.tot_relief_qty(i),
                          -- Bug 3805136 offset_qty to alloc_qty ratio
                          1,
                          l_peg_relief_qty,
                          atp_peg_tab.end_item_usage(i),
                          -- End Bug 3805136
                          --atp_peg_tab.tot_relief_qty(i),
                          -- Bug 3761805 Pass Config Item Id and END PEG as a parameter
                          atp_peg_tab.inventory_item_id(i),
                          atp_peg_tab.end_pegging_id(i),
                          atp_peg_tab.supply_id(i),
                          -- End Bug 3761805
                          atp_peg_tab.transaction_date(i),
                          l_return_status
                          );

                 L_TOT_RELIEF_QTY := L_TOT_RELIEF_QTY - l_peg_relief_qty;
               END IF; --  IF (ABS (L_TOT_RELIEF_QTY ) > 0 )

            END IF; -- IF (atp_peg_tab.bom_item_type(i)
         END LOOP; -- FOR i in 1..atp_peg_t

          select hsecs
          into   l_timestamp
          from   v$timer;

         IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging : Stage 9 After Calculating Reliefs ');
           msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 6 ' || l_timestamp);
         END IF;
         -- Generate ATP Resource Pegging.

         Generate_Resource_Pegging (atp_peg_tab, l_return_status);

          select hsecs
          into   l_timestamp
          from   v$timer;

         IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging : Stage 10 After Resource Pegging ');
           msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 7 ' || l_timestamp);
         END IF;
      END IF;
      -- End Bug 3701093

      -- After obtaining all the atp simplified pegging information.

      l_row_count := atp_peg_tab.reference_item_id.COUNT ;
      IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('ATP pegging data will be inserted into ' || l_temp_table);
           msc_util.msc_log('Total Records to be inserted ' || l_row_count);
      END IF;

      -- Bug 3344102 First insert the data into the global temporary table.

      l_sql_stmt_1 := ' (
                       plan_id,
                       sr_instance_id,
                       reference_item_id,
                       inventory_item_id,
                       organization_id,
                       sales_order_line_id,
                       demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       end_demand_id,
                       bom_item_type,
                       sales_order_qty,
                       transaction_date,
                       demand_id,
                       demand_quantity,
                       disposition_id,
                       demand_class,
                       consumed_qty,
                       overconsumption_qty,
                       supply_id,
                       supply_quantity,
                       allocated_quantity,
                       resource_id,
                       department_id,
                       resource_hours,
                       daily_resource_hours,
                       start_date,
                       end_date,
                       relief_type,
                       relief_quantity,
                       daily_relief_qty,
                       pegging_id,
                       prev_pegging_id,
                       end_pegging_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date )
                    VALUES (
                       :l_plan_id,
                       :l_sr_instance_id,
                       :l_reference_item_id,
                       :l_inventory_item_id,
                       :l_organization_id,
                       :l_sales_order_line_id,
                       :l_demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       :l_end_demand_id,
                       :l_bom_item_type,
                       :l_ales_order_qty,
                       :l_transaction_date,
                       :l_demand_id,
                       :l_demand_quantity,
                       :l_disposition_id,
                       :l_demand_class,
                       :l_consumed_qty,
                       :l_overconsumption_qty,
                       :l_supply_id,
                       :l_supply_quantity,
                       :l_allocated_quantity,
                       :l_resource_id,
                       :l_department_id,
                       :l_resource_hours,
                       :l_daily_resource_hours,
                       :l_start_date,
                       :l_end_date,
                       :l_relief_type,
                       :l_relief_quantity,
                       :l_daily_relief_qty,
                       :l_pegging_id,
                       :l_prev_pegging_id,
                       :l_end_pegging_id,
                       :l_user_id,
                       :l_sysdate,
                       :l_user_id,
                       :l_sysdate )';

      l_sql_stmt_2 := ' (
                       plan_id,
                       sr_instance_id,
                       reference_item_id,
                       inventory_item_id,
                       organization_id,
                       sales_order_line_id,
                       demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       end_demand_id,
                       -- CTO-PF
                       atf_date,
                       product_family_id,
                       bom_item_type,
                       sales_order_qty,
                       transaction_date,
                       demand_id,
                       demand_quantity,
                       disposition_id,
                       demand_class,
                       consumed_qty,
                       overconsumption_qty,
                       supply_id,
                       supply_quantity,
                       allocated_quantity,
                       resource_id,
                       department_id,
                       resource_hours,
                       daily_resource_hours,
                       start_date,
                       end_date,
                       relief_type,
                       relief_quantity,
                       daily_relief_qty,
                       pegging_id,
                       prev_pegging_id,
                       end_pegging_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date )
                    VALUES (
                       :l_plan_id,
                       :l_sr_instance_id,
                       :l_reference_item_id,
                       :l_inventory_item_id,
                       :l_organization_id,
                       :l_sales_order_line_id,
                       :l_demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       :l_end_demand_id,
                       -- CTO-PF
                       :l_atf_date,
                       :l_product_family_id,
                       :l_bom_item_type,
                       :l_ales_order_qty,
                       :l_transaction_date,
                       :l_demand_id,
                       :l_demand_quantity,
                       :l_disposition_id,
                       :l_demand_class,
                       :l_consumed_qty,
                       :l_overconsumption_qty,
                       :l_supply_id,
                       :l_supply_quantity,
                       :l_allocated_quantity,
                       :l_resource_id,
                       :l_department_id,
                       :l_resource_hours,
                       :l_daily_resource_hours,
                       :l_start_date,
                       :l_end_date,
                       :l_relief_type,
                       :l_relief_quantity,
                       :l_daily_relief_qty,
                       :l_pegging_id,
                       :l_prev_pegging_id,
                       :l_end_pegging_id,
                       :l_user_id,
                       :l_sysdate,
                       :l_user_id,
                       :l_sysdate )';

      FOR i in 1..l_row_count LOOP
         IF ( ((G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1)
            -- CTO-PF
            OR atp_peg_tab.atf_date(i) is not null )
            -- Bug 3701093 Do not store records with relief_quantity 0
            -- for relief_types other than 1 i.e., SO.
            -- Bug 3761824
            AND ( ABS(NVL(atp_peg_tab.relief_quantity(i),0)) > C_ZERO_APPROXIMATOR )
            -- Use Zero_Approximator to exclude quantities below 6 levels of precision.
            -- End Bug 3761824
            AND
            atp_peg_tab.relief_type(i) in (2, 3) ) THEN

            l_insert_temp_table := l_global_temp_table;
            l_time_phased_atp := 'Y';
            l_ins_sql_stmt := 'INSERT INTO '|| l_insert_temp_table || l_sql_stmt_2;

            EXECUTE IMMEDIATE l_ins_sql_stmt USING
                   atp_peg_tab.plan_id(i),
                   atp_peg_tab.sr_instance_id(i),
                   atp_peg_tab.reference_item_id(i),
                   atp_peg_tab.inventory_item_id(i),
                   atp_peg_tab.organization_id(i),
                   atp_peg_tab.sales_order_line_id(i),
                   atp_peg_tab.demand_source_type(i),--cmro
                   -- CTO_PF_PRJ changes. use end_demand_id
                   atp_peg_tab.end_demand_id(i),
                   -- CTO-PF
                   atp_peg_tab.atf_date(i),
                   atp_peg_tab.product_family_id(i),

                   atp_peg_tab.bom_item_type(i),
                   atp_peg_tab.sales_order_qty(i),
                   atp_peg_tab.transaction_date(i),
                   atp_peg_tab.demand_id(i),
                   atp_peg_tab.demand_quantity(i),
                   atp_peg_tab.disposition_id(i),
                   atp_peg_tab.demand_class(i),
                   atp_peg_tab.consumed_qty(i),
                   atp_peg_tab.overconsumption_qty(i),
                   atp_peg_tab.supply_id(i),
                   atp_peg_tab.supply_quantity(i),
                   atp_peg_tab.allocated_quantity(i),
                   atp_peg_tab.resource_id(i),
                   atp_peg_tab.department_id(i),
                   atp_peg_tab.resource_hours(i),
                   atp_peg_tab.daily_resource_hours(i),
                   atp_peg_tab.start_date(i),
                   atp_peg_tab.end_date(i),
                   atp_peg_tab.relief_type(i),
                   atp_peg_tab.relief_quantity(i),
                   atp_peg_tab.daily_relief_qty(i),
                   atp_peg_tab.pegging_id(i),
                   atp_peg_tab.prev_pegging_id(i),
                   atp_peg_tab.end_pegging_id(i),
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate;

         ELSE
           l_insert_temp_table := l_temp_table;
           l_ins_sql_stmt := 'INSERT INTO '|| l_insert_temp_table || l_sql_stmt_1;

           -- Bug 3701093 Do not store records with relief_quantity 0
           -- for relief_types other than 1 i.e., SO.
           IF
            -- Bug 3761824
             ( ABS(NVL(atp_peg_tab.relief_quantity(i),0)) > C_ZERO_APPROXIMATOR  OR
            -- Use Zero_Approximator to exclude quantities below 6 levels of precision.
            -- End Bug 3761824
                            atp_peg_tab.relief_type(i) = 1) THEN
              EXECUTE IMMEDIATE l_ins_sql_stmt USING
                   atp_peg_tab.plan_id(i),
                   atp_peg_tab.sr_instance_id(i),
                   atp_peg_tab.reference_item_id(i),
                   atp_peg_tab.inventory_item_id(i),
                   atp_peg_tab.organization_id(i),
                   atp_peg_tab.sales_order_line_id(i),
                   atp_peg_tab.demand_source_type(i),--cmro
                   -- CTO_PF_PRJ changes. use end_demand_id
                   atp_peg_tab.end_demand_id(i),
                   atp_peg_tab.bom_item_type(i),
                   atp_peg_tab.sales_order_qty(i),
                   atp_peg_tab.transaction_date(i),
                   atp_peg_tab.demand_id(i),
                   atp_peg_tab.demand_quantity(i),
                   atp_peg_tab.disposition_id(i),
                   atp_peg_tab.demand_class(i),
                   atp_peg_tab.consumed_qty(i),
                   atp_peg_tab.overconsumption_qty(i),
                   atp_peg_tab.supply_id(i),
                   atp_peg_tab.supply_quantity(i),
                   atp_peg_tab.allocated_quantity(i),
                   atp_peg_tab.resource_id(i),
                   atp_peg_tab.department_id(i),
                   atp_peg_tab.resource_hours(i),
                   atp_peg_tab.daily_resource_hours(i),
                   atp_peg_tab.start_date(i),
                   atp_peg_tab.end_date(i),
                   atp_peg_tab.relief_type(i),
                   atp_peg_tab.relief_quantity(i),
                   atp_peg_tab.daily_relief_qty(i),
                   atp_peg_tab.pegging_id(i),
                   atp_peg_tab.prev_pegging_id(i),
                   atp_peg_tab.end_pegging_id(i),
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate;
           END IF;
           -- End Bug 3701093
         END IF;
         --CTO-PF
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('Gen_Atp_Pegging : atf_date ' || atp_peg_tab.atf_date(i));
            msc_util.msc_log('Gen_Atp_Pegging : product_family_id ' || atp_peg_tab.product_family_id(i));
            msc_util.msc_log('Gen_Atp_Pegging : reference_item_id ' || atp_peg_tab.reference_item_id(i));
            msc_util.msc_log('Gen_Atp_Pegging : inventory_item_id ' || atp_peg_tab.inventory_item_id(i));
            msc_util.msc_log('Gen_Atp_Pegging : l_time_phased_atp ' || l_time_phased_atp);
         END IF;
      END LOOP; -- Insert Loop

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
          msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 8 ' || l_timestamp);
       END IF;
      /* commented as a part of CTO-PF
      -- Bug 3344102 Second insert the data into the main table.
      l_sql_stmt_1 := 'INSERT INTO ' || l_temp_table || '(
                       plan_id,
                       sr_instance_id,
                       reference_item_id,
                       inventory_item_id,
                       organization_id,
                       sales_order_line_id,
                       demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       end_demand_id,
                       bom_item_type,
                       sales_order_qty,
                       transaction_date,
                       demand_id,
                       demand_quantity,
                       disposition_id,
                       demand_class,
                       consumed_qty,
                       overconsumption_qty,
                       supply_id,
                       supply_quantity,
                       allocated_quantity,
                       resource_id,
                       department_id,
                       resource_hours,
                       daily_resource_hours,
                       start_date,
                       end_date,
                       relief_type,
                       relief_quantity,
                       daily_relief_qty,
                       pegging_id,
                       prev_pegging_id,
                       end_pegging_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date )
               SELECT
                       plan_id,
                       sr_instance_id,
                       reference_item_id,
                       inventory_item_id,
                       organization_id,
                       sales_order_line_id,
                       demand_source_type,--cmro
                       -- CTO_PF_PRJ changes. use end_demand_id
                       end_demand_id,
                       bom_item_type,
                       sales_order_qty,
                       transaction_date,
                       demand_id,
                       demand_quantity,
                       disposition_id,
                       demand_class,
                       consumed_qty,
                       overconsumption_qty,
                       supply_id,
                       supply_quantity,
                       allocated_quantity,
                       resource_id,
                       department_id,
                       resource_hours,
                       daily_resource_hours,
                       start_date,
                       end_date,
                       relief_type,
                       relief_quantity,
                       daily_relief_qty,
                       pegging_id,
                       prev_pegging_id,
                       end_pegging_id,
                       created_by,
                       creation_date,
                       last_updated_by,
                       last_update_date
               FROM
                       msc_atp_peg_temp
               WHERE   plan_id =  :p_plan_id
               AND     end_demand_id  = :l_end_demand_id
               AND     relief_type in (2, 3)   ';

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('SQL statement to be executed ' || l_sql_stmt_1);
      END IF;

      IF l_row_count > 0 THEN
         EXECUTE IMMEDIATE l_sql_stmt_1 USING
                           p_plan_id,
                           atp_peg_tab.end_demand_id(1);
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
          msc_util.msc_log('Gen_Atp_Pegging : Rows Procesed ' || SQL%ROWCOUNT );
          msc_util.msc_log('Gen_Atp_Pegging : TIMESTAMP 9 ' || l_timestamp);
      END IF;

      -- End Bug 3344102 Secod insert the data into the main table.
      */

    END LOOP; -- End config_items loop
    -- insert into MSC_ATP_PEG_TEMP_NEW select * from MSC_ATP_PEG_TEMP; --MSC_ATP_PEG_TEMP
    -- End Bug 3344102 Call Creation of ATP Pegging Data for Allocated ATP case.
    IF  ((G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1)
          AND l_time_phased_atp = 'N') THEN
        Create_Pre_Allocation_Reliefs ( p_plan_id,
                                        l_temp_table,
                                        l_user_id,
                                        l_sysdate,
                                        l_return_status);
    -- CTO-PF start
    ELSIF (l_time_phased_atp = 'Y' AND
           (G_ALLOC_ATP = 'Y' AND G_CLASS_HRCHY = 1 AND G_ALLOC_METHOD = 1)) THEN

        MSC_ATP_PF.Create_PF_DP_Alloc_Reliefs ( p_plan_id,
                                                     l_temp_table,
                                                     l_user_id,
                                                     l_sysdate,
                                                     l_return_status);

    ELSIF (l_time_phased_atp = 'Y') THEN

        MSC_ATP_PF.Create_PF_Allocation_Reliefs ( p_plan_id,
                                                  l_temp_table,
                                                  l_user_id,
                                                  l_sysdate,
                                                  l_return_status);

    END IF;
    -- CTO-PF end
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Gen_Atp_Pegging: ' ||
               'Error occured in procedure Create_Pre_Allocation_Reliefs');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Bug 3344102 After Call to creation of Allocated ATP Pegging Data.

  IF p_share_partition = 'Y' THEN

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Analyze Plan partition for MSC_ATP_PEGGING');
      END IF;
        fnd_stats.gather_table_stats(ownname=>'MSC',tabname=>'MSC_ATP_PEGGING',
                                   partname=>'ATP_PEGGING_999999',
                                   granularity=>'PARTITION',
                                   percent =>10);

  ELSE

      -- INDEX CREATION CODE COMES HERE.

      l_sql_stmt := 'CREATE INDEX ' || l_temp_table || '_N1 ON ' || l_temp_table ||
                    '(
                     Plan_id,
                     relief_type,
                     sr_instance_id,
                     organization_id,
                     inventory_item_id,
                     Reference_Item_Id,
                     -- CTO_PF_PRJ changes use end_demand_id.
                     end_demand_id,
                     demand_id,
                     supply_id,
                     resource_id
                    )
                    STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0)
                    LOCAL TABLESPACE ' || l_ind_tbspace;

      BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Before creating index ' || l_temp_table ||
                                                '_N1 for table ');
        END IF;
           ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => l_msc_schema,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => l_sql_stmt,
                 object_name => l_temp_table );
      END ;
      l_sql_stmt := 'CREATE INDEX ' || l_temp_table || '_N2 ON ' || l_temp_table ||
                    '(
                     Plan_id,
                     relief_type,
                     sales_order_line_id,
                     demand_source_type,
                     inventory_item_id,
                     demand_id
                    )
                    STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0)
                    LOCAL TABLESPACE ' || l_ind_tbspace;

      BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Before creating index ' || l_temp_table ||
                                                '_N2 for table ');
        END IF;
           ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => l_msc_schema,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => l_sql_stmt,
                 object_name => l_temp_table );
      END ;
      l_sql_stmt := 'CREATE INDEX ' || l_temp_table || '_N3 ON ' || l_temp_table ||
                    '(
                     Plan_id,
                     relief_type,
                     sales_order_line_id,
                     demand_source_type,
                     inventory_item_id,
                     supply_id,
                     resource_id
                    )
                    STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0)
                    LOCAL TABLESPACE ' || l_ind_tbspace;

      BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Before creating index ' || l_temp_table ||
                                                '_N3 for table ');
        END IF;
           ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => l_msc_schema,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => l_sql_stmt,
                 object_name => l_temp_table );
      END ;
      -- Bug 3629191
      l_sql_stmt := 'CREATE INDEX ' || l_temp_table || '_N4 ON ' || l_temp_table ||
                    '(
                     Plan_id,
                     relief_type,
                     offset_supply_id,
                    )
                    STORAGE(INITIAL 40K NEXT 2M PCTINCREASE 0)
                    LOCAL TABLESPACE ' || l_ind_tbspace;

      BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Before creating index ' || l_temp_table ||
                                                '_N4 for table ');
        END IF;
           ad_ddl.do_ddl( applsys_schema => p_applsys_schema,
                 application_short_name => l_msc_schema,
                 statement_type => AD_DDL.CREATE_INDEX,
                 statement => l_sql_stmt,
                 object_name => l_temp_table );
      END ;
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('Gather Table Stats for MSC_ATP_PEGGING');
      END IF;

      fnd_stats.gather_table_stats('MSC', 'ATP_PEGGING' || to_char(l_plan_id),
                granularity => 'ALL');

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log('swap partition ');
      END IF;

      l_sql_stmt := 'ALTER TABLE msc_atp_pegging EXCHANGE PARTITION ' ||
                          l_partition_name  ||
           ' with table MSC_TEMP_ATP_PEGG_'|| to_char(l_plan_id) ||
           ' including indexes without validation';

           BEGIN
               IF PG_DEBUG in ('Y', 'C') THEN
                   msc_util.msc_log('Before alter table msc_atp_pegging');
               END IF;
                   ad_ddl.do_ddl(APPLSYS_SCHEMA => p_applsys_schema,
                   APPLICATION_SHORT_NAME => 'MSC',
                   STATEMENT_TYPE => ad_ddl.alter_table,
                   STATEMENT => l_sql_stmt,
                   OBJECT_NAME => 'MSC_ATP_PEGGING');
           END;

  END IF;  -- p_share_partition = 'Y'

EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Generate_Simplified_Pegging. Error : ' || sqlcode || ': ' || sqlerrm);
      END IF;
      RETCODE := G_ERROR;

END Generate_Simplified_Pegging;


PROCEDURE post_plan_pegging(
        ERRBUF          OUT     NoCopy VARCHAR2,
        RETCODE         OUT     NoCopy NUMBER,
        p_plan_id       IN      NUMBER)
IS

   l_share_partition               VARCHAR2(1);
   l_summary_flag                  NUMBER;
   l_plan_name                     VARCHAR2(10);
   l_retval                        BOOLEAN;
   l_applsys_schema                VARCHAR2(10);
   dummy1                          VARCHAR2(10);
   dummy2                          VARCHAR2(10);
   l_ret_code                      NUMBER;

   l_return_status                 VARCHAR2(40);
   l_session_id                    NUMBER;
   l_log_file                      VARCHAR2(255);

BEGIN

    msc_util.msc_log('Begin procedure post_plan_pegging');

    RETCODE := G_SUCCESS;


    l_share_partition := fnd_profile.value('MSC_SHARE_PARTITIONS');

    msc_util.msc_log('l_share_partition := ' || l_share_partition);

    SELECT NVL(summary_flag,1), compile_designator
    INTO   l_summary_flag, l_plan_name
    FROM   msc_plans
    WHERE  plan_id = p_plan_id;

    IF NVL(l_summary_flag,1) NOT IN
            (MSC_POST_PRO.G_SF_SUMMARY_NOT_RUN,
             MSC_POST_PRO.G_SF_PREALLOC_COMPLETED,
             MSC_POST_PRO.G_SF_SYNC_SUCCESS,
             MSC_POST_PRO.G_SF_SUMMARY_COMPLETED,
             MSC_POST_PRO.G_SF_ATPPEG_COMPLETED) THEN
       msc_util.msc_log('Another session is running post-plan allocation program for this plan');
       RETCODE :=  G_ERROR;
       RETURN;
    END IF;

    -- Bug 3344102 Set Alloc Related Global Variables.
    G_ALLOC_ATP := NVL(FND_PROFILE.value('MSC_ALLOCATED_ATP'),'N');
    G_CLASS_HRCHY := NVL(FND_PROFILE.VALUE('MSC_CLASS_HIERARCHY'), 2);
    G_ALLOC_METHOD := NVL(FND_PROFILE.VALUE('MSC_ALLOCATION_METHOD'), 2);

    msc_util.msc_log('G_ALLOC_ATP    := ' || G_ALLOC_ATP);
    msc_util.msc_log('G_CLASS_HRCHY  := ' || G_CLASS_HRCHY);
    msc_util.msc_log('G_ALLOC_METHOD := ' || G_ALLOC_METHOD);
    -- End Bug 3344102

    msc_util.msc_log('Deleting Existing ATP Pegging data for plan : ' || p_plan_id);

    IF l_share_partition = 'Y' THEN
      DELETE from msc_atp_pegging
      where  plan_id = p_plan_id;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('Post_Plan_Pegging:  Number of rows deleted '|| SQL%ROWCOUNT);
      END IF;
    END IF;

    l_retval := FND_INSTALLATION.GET_APP_INFO('FND', dummy1, dummy2, l_applsys_schema);

    -- Update summary flag to signify begining of pegging generation
    Update_Summary_Flag (   p_plan_id,
                            MSC_POST_PRO.G_SF_ATPPEG_RUNNING,
                            l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Post_Plan_Pegging: ' ||
               'Error occured in procedure Update_Summary_Flag');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    BEGIN
       IF fnd_global.conc_request_id > 0  THEN
          select logfile_name
          into   l_log_file
          from   fnd_concurrent_requests
          where request_id = fnd_global.conc_request_id;
         msc_util.msc_log('LOG FILE is: ' || l_log_file);
       ELSE
         BEGIN
            SELECT mrp_atp_schedule_temp_s.currval
            INTO   l_session_id
            FROM   dual;
         EXCEPTION
            WHEN OTHERS THEN
              SELECT mrp_atp_schedule_temp_s.nextval
              INTO   l_session_id
              FROM   dual;
              order_sch_wb.debug_session_id := l_session_id;
         END;

         msc_util.msc_log('Setting ATP Session ID : ' || l_session_id);
         msc_util.msc_log('LOG FILE is: session-' || l_session_id);
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN

         msc_util.msc_log('Calling Generate_Simplified_Pegging ' );
       END IF;

       MSC_ATP_PEG.Generate_Simplified_Pegging(p_plan_id, l_share_partition,
                                                 l_applsys_schema, l_ret_code);
       IF PG_DEBUG in ('Y', 'C') THEN
         msc_util.msc_log('After Call to Generate_Simplified_Pegging ' );
         msc_util.msc_log('Return Code is := ' || l_ret_code);
       END IF;
       --IF l_ret_code = G_ERROR THEN
       --      RETCODE := G_WARNING;  -- For now we are treating this as a warning
       --END IF;
    EXCEPTION
        WHEN OTHERS THEN

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_util.msc_log('ERROR IN  Generate_Simplified_Pegging ' );
            msc_util.msc_log('ERROR: ' || to_char(SQLCODE));
            msc_util.msc_log('ERROR: ' || sqlerrm);
          END IF;
          RETCODE := G_ERROR;
          ERRBUF  := sqlerrm;
    END;
    -- Update summary flag to signify end of pegging generation
    Update_Summary_Flag (   p_plan_id,
                            MSC_POST_PRO.G_SF_ATPPEG_COMPLETED,
                            l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
           msc_util.msc_log('Post_Plan_Pegging: ' ||
               'Error occured in procedure Update_Summary_Flag');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
      Update_Summary_Flag (   p_plan_id,
                            NVL(l_summary_flag, 1),
                            l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
             msc_util.msc_log('Post_Plan_Pegging: ' ||
                 'Error occured in procedure Update_Summary_Flag');
          END IF;
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
        msc_util.msc_log ('post_plan_pegging. Error : ' || sqlerrm);
      END IF;
      ERRBUF := sqlerrm;
      RETCODE := G_ERROR;

END post_plan_pegging;

PROCEDURE Add_Offset_Demands (
                     p_identifier                      IN NUMBER,
                     p_config_line_id                  IN NUMBER,
                     p_plan_id                         IN NUMBER,
                     p_refresh_number                  IN NUMBER,
                     p_order_number                    IN NUMBER,
                     p_demand_source_type              IN NUMBER,--cmro
                     x_inv_item_id                     IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_demand_id                       IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_demand_instance_id              OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_return_status                   IN OUT NoCopy VARCHAR2
                     )
IS
    l_del_rows                  NUMBER;
    i                           PLS_INTEGER;
    my_sqlcode                  NUMBER;

    l_demand_id                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_demand_qty                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_demand_date               MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
    l_reference_item_id         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_instance_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_organization_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_inventory_item_id         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_demand_class              MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
    l_customer_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_customer_site_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_ship_to_site_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_dmd_satisfied_date        MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();

    l_offset_demand_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    -- Bug 3890723 Introduce a pegging_id array to track pegging
    -- For filtering out released/firmed supplies instead of disposition_id array.
    l_disposition_id            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr(); -- Array retained as FYI for demand offsets.
    l_pegging_id                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    -- End Bug 3890723

    l_sysdate                   DATE;
    l_user_id                   number;
    l_so_line_ids               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();

    -- Bug 3344102 A variable/handle for processing reliefs/offsets.
    l_offset_type               NUMBER;
    -- CTO_PF_PRJ_2 Impacts
    l_supply_id                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_original_item_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_original_demand_date      MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
    -- End CTO_PF_PRJ_2 Impacts
    -- Bug 3717618 Add supply offset type var. for limiting adjustment to demands
    -- that are pegged to supplies that can be relieved.
    l_sup_offset_type        NUMBER;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Add_Offset_Demands *****');
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Add_Offset_Demands: ' ||
                          'Offsetting msc_demands for identifier = '
                          || p_identifier ||' : plan id = '||p_plan_id);
     msc_sch_wb.atp_debug('Add_Offset_Demands: ' || 'Config Line Id = ' || p_config_line_id );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_sysdate := sysdate;
  l_user_id := FND_GLOBAL.USER_ID;

  -- CTO_PF_PRJ_2 Impacts
  IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

     l_offset_type := 5;
     -- Bug 3717618 Set value of supply relief type.
     l_sup_offset_type := 6;
  ELSE
     l_offset_type := 3;
     -- Bug 3717618 Set value of supply relief type.
     l_sup_offset_type := 2;
  END IF;
  -- CTO_PF_PRJ_2 Impacts

  IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Add_Offset_Demands: Dmd. Offset Type Set to '|| l_offset_type);
      -- Bug 3717618 Set value of supply relief type.
      msc_sch_wb.atp_debug('Add_Offset_Demands: Sup. Offset Type Set to '|| l_sup_offset_type);
  END IF;

  -- CTO_PF_PRJ_2 Impacts
  SELECT msc_demands_s.nextval ,
         map.relief_quantity   ,
         NVL(map.original_date, map.transaction_date) transaction_date ,
         -- End CTO_PF_PRJ_2 Impacts
         map.reference_item_id,
         map.sr_instance_id,
         map.organization_id,
         -- CTO_PF_PRJ_2 Impacts
         NVL(map.original_item_id, map.inventory_item_id) inventory_item_id,
         -- End CTO_PF_PRJ_2 Impacts
         map.demand_class,
         d.customer_id,
         d.customer_site_id,
         d.ship_to_site_id,
         d.dmd_satisfied_date,
         -- Bug 3890723 Introduce a pegging_id array to track pegging
         -- For filtering out released/firmed supplies instead of disposition_id array.
         map.disposition_id,
         map.prev_pegging_id,
         -- End Bug 3890723
         map.demand_id,
         map.sales_order_line_id,
         -- CTO_PF_PRJ Impacts
         NVL(map.supply_id, -1) supply_id,
         map.ORIGINAL_ITEM_ID,
         map.ORIGINAL_DATE
         -- End CTO_PF_PRJ Impacts
  BULK COLLECT
  INTO   x_demand_id,
         l_demand_qty,
         l_demand_date,
         l_reference_item_id,
         l_instance_id, -- Bug 3629191, Return it as out parameter
         l_organization_id,
         x_inv_item_id,
         l_demand_class,
         l_customer_id,
         l_customer_site_id,
         l_ship_to_site_id,
         l_dmd_satisfied_date,
         -- Bug 3890723 Introduce a pegging_id array to track pegging
         -- For filtering out released/firmed supplies instead of disposition_id array.
         l_disposition_id, -- Array retained as FYI for demand offsets.
         l_pegging_id,
         -- End Bug 3890723
         l_offset_demand_id,
         l_so_line_ids,
         -- CTO_PF_PRJ Impacts
         l_supply_id,
         l_original_item_id,
         l_original_demand_date
         -- End CTO_PF_PRJ Impacts
  FROM
         msc_atp_pegging map,
         msc_demands d
  WHERE  map.plan_id = p_plan_id
  --AND  map.sr_instance_id = p_instance_id  -- removed to support multiple instances in plan.
  AND    map.sales_order_line_id in (p_identifier, p_config_line_id)
         -- CTO_PF_PRJ_2 Impacts
  AND    map.relief_type in (l_offset_type, 7)  -- POD
         -- End CTO_PF_PRJ_2 Impacts
  -- Bug 3890723 Use only pegging_id as a filter
  -- ATP created transactions will not have disposition_id populated.
  -- Bug 3717618 Only offset demands pegged to supplies that are relieved
  -- using filter on disposition_id
  -- AND    (map.disposition_id, map.prev_pegging_id) IN
  AND    (map.prev_pegging_id) IN
         (SELECT map2.pegging_id
  -- End Bug 3890723
          FROM   msc_atp_pegging map2
          WHERE  map2.plan_id = p_plan_id
          AND    map2.sales_order_line_id in (p_identifier, p_config_line_id)
          AND    DECODE(map2.demand_source_type,100,map2.demand_source_type,-1)
                  =decode(p_demand_source_type,
                                           100,
                                            p_demand_source_type,
                                           -1) --CMRO
          AND    map2.offset_supply_id IS NOT NULL
          AND    map2.relief_type = l_sup_offset_type
         )
  -- End Bug 3717618
  AND    ABS(map.relief_quantity) > C_ZERO_APPROXIMATOR
  -- Bug 3761824 Use Precision figure while creating ofsets.
  AND    DECODE(d.demand_source_type,100,d.demand_source_type,-1)
               =decode(p_demand_source_type,
                                           100,
                                            p_demand_source_type,
                                           -1) --CMRO
  AND    d.plan_id (+) = map.plan_id
  AND    d.organization_id (+) = map.organization_id
  AND    d.demand_id (+) = map.demand_id
  AND    d.inventory_item_id (+) = map.inventory_item_id
  ;
  -- End CTO_PF_PRJ_2 Impacts

  x_demand_instance_id := l_instance_id; --Bug 3629191

  l_del_rows := x_demand_id.COUNT;

  FORALL i in 1..l_del_rows
     INSERT INTO msc_demands (
                 DEMAND_ID,
                 USING_REQUIREMENT_QUANTITY,
                 USING_ASSEMBLY_DEMAND_DATE,
                 DEMAND_TYPE,
                 ORIGINATION_TYPE,
                 USING_ASSEMBLY_ITEM_ID,
                 PLAN_ID,
                 ORGANIZATION_ID,
                 INVENTORY_ITEM_ID,
                 DEMAND_SOURCE_TYPE,--cmro
                 SALES_ORDER_LINE_ID,
                 SR_INSTANCE_ID,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 DEMAND_CLASS,
                 REFRESH_NUMBER,
                 ORDER_NUMBER,
                 CUSTOMER_ID,
                 CUSTOMER_SITE_ID,
                 SHIP_TO_SITE_ID,
                 RECORD_SOURCE,  -- For plan order pegging
                 -- 24x7
                 ATP_SYNCHRONIZATION_FLAG,
                 DMD_SATISFIED_DATE,
                 DISPOSITION_ID
             --    ,OFFSET_DEMAND_ID
                 )
         VALUES (x_demand_id(i),
                 l_demand_qty(i),
                 --bug 3328421: Add at the end of the day
                 trunc(l_demand_date(i)) + MSC_ATP_PVT.G_END_OF_DAY ,
                 --l_demand_date(i),
                 1 ,   -- discrete demand
                 60,  -- offset demand
                 l_reference_item_id(i),  -- inventory_item_id
                 p_plan_id,
                 l_organization_id(i),
                 x_inv_item_id(i),
                 p_demand_source_type,--cmro
                 l_so_line_ids(i),
                 l_instance_id(i),
                 l_sysdate,
                 l_user_id,
                 l_sysdate,
                 l_user_id,
                 l_demand_class(i),
                 p_refresh_number,
                 p_order_number,
                 l_customer_id(i),
                 l_customer_site_id(i),
                 l_ship_to_site_id(i),
                 2,
                 0,
                 l_dmd_satisfied_date(i),
                 l_disposition_id(i)
               --  ,l_offset_demand_id(i)
                );

      IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of rows inserted '||
                               SQL%ROWCOUNT);
      END IF;

      -- Allocated ATP Based on Planning Details

      IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
          (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
          (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
          (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

         IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Add_Offset_Demands: before insert into'||
                               ' msc_alloc_demands');
         END IF;

         -- CTO_PF_PRJ2 relief_type already set above.
         -- Bug 3344102 First set offset type to 5  for alloc reliefs.
         -- l_offset_type := 5;
         -- CTO_PF_PRJ2

         -- Try to apply the offsets using alloc specific relief_type.

         FORALL i in 1..x_demand_id.COUNT
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
                       DEMAND_SOURCE_TYPE,--cmro
                       SALES_ORDER_LINE_ID,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE,
                       refresh_number,
                       -- CTO_PF_PRJ_2 Impacts
                       ORIGINAL_ITEM_ID,
                       ORIGINAL_DEMAND_DATE,
                       ORIGINAL_ORIGINATION_TYPE,
                       PF_DISPLAY_FLAG
                       -- END CTO_PF_PRJ_2 Impacts
                       )
           SELECT
                   map.plan_id,
                   map.inventory_item_id,
                   map.organization_id,
                   map.sr_instance_id,
                   map.demand_class,
                   map.transaction_date,
                   x_demand_id(i),
                   NVL(map.relief_quantity, 0),
                   Decode(map.relief_type, 7, 51, 60),
                   --60,
                   p_order_number,
                   p_demand_source_type,--cmro
                   map.sales_order_line_id,
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate,
                   p_refresh_number,
                   -- CTO_PF_PRJ_2 Impacts
                   l_original_item_id(i),
                   l_original_demand_date(i),
                   Decode(map.relief_type, 7, 60, NULL),
                   --Decode(map.relief_type, 7, 51, 60),
                   Decode(map.relief_type, 7, 1, NULL)
                   -- pf_display_flag = 1 when offseting bucketed demand.
                   -- NULL will be the default value.
                   -- END CTO_PF_PRJ_2 Impacts
           FROM    msc_atp_pegging map
           WHERE   map.sr_instance_id = l_instance_id(i)
           AND     map.plan_id = p_plan_id
           AND     DECODE(map.demand_source_type,100,map.demand_source_type,-1)
                   =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
           AND     map.sales_order_line_id in (p_identifier, p_config_line_id)
           AND     map.relief_type in (5,  7)  -- POD
           AND     NVL(map.original_item_id, map.inventory_item_id) =
                               NVL(l_original_item_id(i), x_inv_item_id(i))
           AND     map.relief_quantity = l_demand_qty(i)
           AND     NVL(map.original_date, l_sysdate) = NVL(l_original_demand_date(i), l_sysdate)
           -- FOR ATP created records only relieve PF, do not offset other demands
           -- as they are set to 0 already in Delete_Row.
           AND     NVL(map.supply_id,  100) = l_supply_id(i)
           --AND     NVL(map.supply_id, DECODE(map.relief_type, 7, -1, 100)) = l_supply_id(i)
           -- Bug 3890723 Use  pegging_id array to track pegging
           -- For filtering out released/firmed supplies instead of disposition_id array.
           -- Bug 3717618 Only offset demands pegged to supplies that are relieved
           -- using filter on disposition_id
           -- AND     map.disposition_id = l_disposition_id(i)
           AND     map.prev_pegging_id = l_pegging_id(i)
           -- End Bug 3890723
           AND     map.demand_id = l_offset_demand_id(i);

           FOR i in 1..x_demand_id.COUNT LOOP
              msc_sch_wb.atp_debug('Demand to be offset ' || l_offset_demand_id(i));
              msc_sch_wb.atp_debug('Original Item ' || l_original_item_id(i));
              msc_sch_wb.atp_debug('Actual Item ' || x_inv_item_id(i));
              msc_sch_wb.atp_debug('Original Date ' || l_original_demand_date(i));
              msc_sch_wb.atp_debug('Supply ID ' || l_supply_id(i));
              msc_sch_wb.atp_debug('New Demand ' || x_demand_id(i));
              msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of Family rows inserted '||
                  'For Demand id '|| l_offset_demand_id(i) ||
                  ' with offset/relief_type 5 or 7 is ' || SQL%BULK_ROWCOUNT(i));
           END LOOP;
         IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of Family and Alloc rows inserted '||
                      'with offset/relief_type = 7 or ' ||l_offset_type || 'is ' || SQL%ROWCOUNT);
         END IF;

         -- CTO_PF_PRJ_2
         -- Cascading SQLs no longer necessary
         --IF SQL%ROWCOUNT = 0 THEN

           -- Apply using standard demands relief_type


         -- END IF;
         -- End Bug 3344102
         -- END CTO_PF_PRJ_2

           IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Offset_Demands:  adjust stealing supplies');
                msc_sch_wb.atp_debug(' Number of SO lines to be adjusted := ' || l_so_line_ids.count);
                For i in 1..l_so_line_ids.count LOOP
                   msc_sch_wb.atp_debug('Line id # ' || i || ' := ' || l_so_line_ids(i));
                END LOOP;

           END IF;

           ---update records due to supply/demand stealing
           IF l_so_line_ids.count > 0 THEN
              update msc_alloc_supplies
              set allocated_quantity = 0
              where plan_id = p_plan_id
              and   sr_instance_id = l_instance_id(1)
              and   ato_model_line_id  = p_identifier
              and     DECODE(demand_source_type,100,demand_source_type,-1)
                      =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO;
              and   order_type in (46, 47);
           END IF;
           IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of stealing rows updated '||
                               SQL%ROWCOUNT);
           END IF;

      -- Offset Product Family Demands if any
      ELSE
         -- Try to apply the offsets using alloc specific relief_type.

         FORALL i in 1..x_demand_id.COUNT
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
                       DEMAND_SOURCE_TYPE,--cmro
                       SALES_ORDER_LINE_ID,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE,
                       refresh_number,
                       -- CTO_PF_PRJ_2 Impacts
                       ORIGINAL_ITEM_ID,
                       ORIGINAL_DEMAND_DATE,
                       ORIGINAL_ORIGINATION_TYPE,
                       PF_DISPLAY_FLAG
                       -- END CTO_PF_PRJ_2 Impacts
                       )
           SELECT
                   map.plan_id,
                   map.inventory_item_id,
                   map.organization_id,
                   map.sr_instance_id,
                   map.demand_class,
                   map.transaction_date,
                   x_demand_id(i),
                   NVL(map.relief_quantity, 0),
                   Decode(map.relief_type, 7, 51, 60),
                   --60,
                   p_order_number,
                   p_demand_source_type,--cmro
                   map.sales_order_line_id,
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate,
                   p_refresh_number,
                   -- CTO_PF_PRJ_2 Impacts
                   l_original_item_id(i),
                   l_original_demand_date(i),
                   Decode(map.relief_type, 7, 60, NULL),
                   --Decode(map.relief_type, 7, 51, 60),
                   1  -- Always 1 for PF.
                   -- END CTO_PF_PRJ_2 Impacts
           FROM    msc_atp_pegging map
           WHERE   map.sr_instance_id = l_instance_id(i)
           AND     map.plan_id = p_plan_id
           AND     DECODE(map.demand_source_type,100,map.demand_source_type,-1)
                   =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO
           AND     map.sales_order_line_id in (p_identifier, p_config_line_id)
           AND     map.relief_type = 7   -- POD for family item.
           AND     NVL(map.original_item_id, map.inventory_item_id) =
                               NVL(l_original_item_id(i), x_inv_item_id(i))
           AND     map.relief_quantity = l_demand_qty(i)
           AND     NVL(map.original_date, l_sysdate) = NVL(l_original_demand_date(i), l_sysdate)
           AND     NVL(map.supply_id, -1) = l_supply_id(i)
           -- Bug 3890723 Use  pegging_id array to track pegging
           -- For filtering out released/firmed supplies instead of disposition_id array.
           -- Bug 3717618 Only offset demands pegged to supplies that are relieved
           -- using filter on disposition_id
           -- AND     map.disposition_id = l_disposition_id(i)
           AND     map.prev_pegging_id = l_pegging_id(i)
           -- End Bug 3890723
           AND     map.demand_id = l_offset_demand_id(i);

         IF PG_DEBUG in ('Y', 'C') THEN
           FOR i in 1..x_demand_id.COUNT LOOP
              msc_sch_wb.atp_debug('Demand to be offset ' || l_offset_demand_id(i));
              msc_sch_wb.atp_debug('Original Item ' || l_original_item_id(i));
              msc_sch_wb.atp_debug('Original Date ' || l_original_demand_date(i));
              msc_sch_wb.atp_debug('Supply ID ' || l_supply_id(i));
              msc_sch_wb.atp_debug('New Demand ' || x_demand_id(i));
              msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of Family rows inserted '||
                  'For Demand id '|| l_offset_demand_id(i) ||
                  ' with offset/relief_type = 7 is ' || SQL%BULK_ROWCOUNT(i));
           END LOOP;
                msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of Family rows inserted '||
                      'with offset/relief_type = 7 is ' || SQL%ROWCOUNT);
         END IF;
      END IF; --IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND  basically, IF ALLOC

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Add_Offset_Demands *****');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Demands: ' ||
                'error in insert row: sqlcode =  '|| to_char(my_sqlcode));
           msc_sch_wb.atp_debug('Add_Offset_Demands: ERROR- ' || sqlerrm );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Add_Offset_Demands');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Offset_Demands;

PROCEDURE Add_Offset_Supplies (
                     p_identifier                      IN NUMBER,
                     p_config_line_id                  IN NUMBER,
                     p_plan_id                         IN NUMBER,
                     p_refresh_number                  IN NUMBER,
                     p_order_number                    IN NUMBER,
                     p_demand_source_type              IN NUMBER,--cmro
                     x_inv_item_id                     IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_supply_id                       IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_supply_instance_id              OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_return_status                   IN OUT NoCopy VARCHAR2
                     )
IS
    l_del_rows                  NUMBER;
    i                           PLS_INTEGER;
    my_sqlcode                  NUMBER;

    l_supply_id                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_instance_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_organization_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_inventory_item_id         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_supply_date               MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
    l_supply_qty                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_reference_item_id         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_demand_class              MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr();
    l_supplier_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_supplier_site_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_src_supplier_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_src_supplier_site_id      MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_src_instance_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_src_org_id                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_process_seq_id            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_customer_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_ship_to_site_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_firm_planned_type         MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();

    l_offset_supply_id          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_sysdate                   DATE;
    l_user_id                   number;
    l_dock_date                 MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();
    l_ship_date                 MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr();

    -- Bug 3344102 A variable/handle for processing reliefs/offsets.
    l_offset_type               NUMBER := NULL;

    -- Bug 3381464 Array to track original supplies for updating msc_atp_pegging
    l_orig_supply_id            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    -- Bug 3717618 Introduce a pegging_id array to track pegging
    -- For filtering out released/firmed supplies and pegging both are needed.
    l_pegging_id                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Offset_Supplies *****');
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Add_Offset_Supplies: ' ||
                            'Offsetting msc_supplies for identifier = '
                            || p_identifier ||' : plan id = '||p_plan_id);
     msc_sch_wb.atp_debug('Add_Offset_Supplies: ' || 'Config Line Id = ' || p_config_line_id );
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_sysdate := sysdate;
    l_user_id := FND_GLOBAL.USER_ID;

    -- CTO_PF_PRJ_2 Changes
    IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

       l_offset_type := 6;
    ELSE
       l_offset_type := 2;
    END IF;
    -- End CTO_PF_PRJ_2 Changes

    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Add_Offset_Supplies: Offset Type Set to '|| l_offset_type);
    END IF;

    -- Insert relief quantities as a Offsets in msc_supplies

    -- CTO_PF_PRJ_2 Changes
    SELECT   msc_supplies_s.nextval,
             map.sr_instance_id,
             map.organization_id,
             map.inventory_item_id,
             map.relief_quantity relief_quantity,
             map.transaction_date,
             -- Bug 3717618 Fetch pegging as well.
             map.pegging_id,
             -- Bug 3381464 Get original supply id
             s.transaction_id orig_supply_id,
             s.supplier_id,
             s.supplier_site_id,
             s.source_supplier_id,
             s.source_supplier_site_id,
             s.source_sr_instance_id,
             s.source_organization_id,
             s.process_seq_id,
             s.firm_planned_type,
             s.demand_class,
             s.customer_id,
             s.ship_to_site_id,
             s.transaction_id,
             s.new_ship_date,
             s.new_dock_date
    BULK COLLECT
    INTO     x_supply_id,
             l_instance_id,
             l_organization_id,
             x_inv_item_id,
             l_supply_qty,
             l_supply_date,
             -- Bug 3717618 Introduce a pegging_id array to track pegging
             -- For filtering out, released/firmed supplies and pegging both are needed.
             l_pegging_id,
             -- Bug 3381464 Get original supply id
             l_orig_supply_id,
             l_supplier_id,
             l_supplier_site_id,
             l_src_supplier_id,
             l_src_supplier_site_id,
             l_src_instance_id,
             l_src_org_id,
             l_process_seq_id,
             l_firm_planned_type,
             l_demand_class,
             l_customer_id,
             l_ship_to_site_id,
             l_offset_supply_id,
             l_ship_date,
             l_dock_date
    FROM
             msc_atp_pegging map,
             msc_supplies s
    WHERE    map.plan_id = p_plan_id
    --AND    map.sr_instance_id = p_instance_id  -- removed to support multiple instances in plan.
    AND      DECODE(map.demand_source_type,100,map.demand_source_type,-1)
                =decode(p_demand_source_type,
                                        100,
                                        p_demand_source_type,
                                        -1) --CMRO;
    AND      map.sales_order_line_id in (p_identifier, p_config_line_id)
             -- CTO_PF_PRJ_2 Impacts Use the proper adjustment type.
    AND      map.relief_type = l_offset_type  -- PO
             -- End CTO_PF_PRJ_2 Impacts.
    -- Bug 3717618 Ensure that Firm or Released supplies are not included.
    AND      (map.supply_id, map.pegging_id) NOT IN
             (SELECT supply_id, pegging_id
              FROM   msc_atp_pegging mapeg1
              WHERE  plan_id = p_plan_id
              AND    DECODE(mapeg1.demand_source_type,100,mapeg1.demand_source_type,-1)
                     =decode(p_demand_source_type, 100,
                                     p_demand_source_type, -1) --CMRO
              AND    sales_order_line_id in (p_identifier, p_config_line_id)
              AND    relief_type in (1, l_offset_type)
              START WITH plan_id = p_plan_id
              AND    DECODE(mapeg1.demand_source_type,100,mapeg1.demand_source_type,-1)
                     =decode(p_demand_source_type, 100,
                                     p_demand_source_type, -1) --CMRO
              AND   sales_order_line_id in (p_identifier, p_config_line_id)
              AND   relief_type in (1, l_offset_type)
              AND   supply_id in
              (SELECT transaction_id
               FROM   msc_supplies S
               WHERE  S.plan_id = mapeg1.plan_id
               AND    S.sr_instance_id = mapeg1.sr_instance_id
               AND    S.transaction_id = mapeg1.supply_id
               AND    S.inventory_item_id = mapeg1.inventory_item_id
               AND    ((S.firm_planned_type = 1) -- firmed
                       OR -- released
                       NVL(S.implemented_quantity, 0) +
                       NVL(S.quantity_in_process, 0) >=
                       NVL(S.firm_quantity,S.new_order_quantity)
                      )
              )
              CONNECT BY prev_pegging_id = prior pegging_id
              AND   plan_id = p_plan_id
              AND   DECODE(mapeg1.demand_source_type,100,mapeg1.demand_source_type,-1)
                     =decode(p_demand_source_type, 100,
                                     p_demand_source_type, -1)
              AND   sales_order_line_id in (p_identifier, p_config_line_id)
              AND   relief_type in (1, l_offset_type)
              -- The Connect By clause sub_query traverses the pegging chain
              -- and helps in eliminating all supplies pegged to the firmed or released supply
             )
    -- End Bug 3717618
    AND      ABS(map.relief_quantity) > C_ZERO_APPROXIMATOR
    -- Bug 3761824 Use Precision figure while creating ofsets.
    AND      s.sr_instance_id = map.sr_instance_id
    AND      s.plan_id = map.plan_id
    AND      s.organization_id = map.organization_id
    AND      s.transaction_id = map.supply_id
    AND      s.inventory_item_id = map.inventory_item_id
    AND      s.order_type = 5
    ;
    -- End CTO_PF_PRJ_2 Impacts

    x_supply_instance_id := l_instance_id; --Bug 3629191

    l_del_rows := x_supply_id.COUNT;

    FORALL i in 1..l_del_rows
      INSERT into MSC_SUPPLIES (
                  plan_id,
                  transaction_id,
                  organization_id,
                  sr_instance_id,
                  inventory_item_id,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  new_schedule_date,
                  disposition_status_type,
                  order_type,
                  new_order_quantity,
                  order_number,
                  supplier_id,
                  supplier_site_id,
                  source_supplier_id,
                  source_supplier_site_id,
                  source_sr_instance_id,
                  source_organization_id,
                  process_seq_id,
                  firm_planned_type,
                  demand_class,
                  customer_id,
                  ship_to_site_id,
                  record_source,
                  refresh_number,
                  new_ship_date,
                  new_dock_date
                 -- ,offset_supply_id
                  )
      VALUES      (p_plan_id,
                  x_supply_id(i),
                  l_organization_id(i),
                  l_instance_id(i),
                  x_inv_item_id(i),
                  l_sysdate,
                  l_user_id,
                  l_sysdate,
                  l_user_id,
                  --bug 3328421: Add at the end of the day
                  TRUNC(l_supply_date(i)) + MSC_ATP_PVT.G_END_OF_DAY,
                  --l_supply_date(i),
                  1,            -- 1512366: open status.
                  60,           -- offset sypply_type
                  l_supply_qty(i),
                  p_order_number,
                  l_supplier_id(i),
                  l_supplier_site_id(i),
                  l_src_supplier_id(i),
                  l_src_supplier_site_id(i),
                  l_src_instance_id(i),
                  l_src_org_id(i),
                  l_process_seq_id(i),
                  l_firm_planned_type(i),
                  l_demand_class(i),
                  l_customer_id(i),
                  l_ship_to_site_id(i),
                  2,            -- ATP created record
                  p_refresh_number,
                  l_ship_date(i),
                  l_dock_date(i)
                --  ,l_offset_supply_id
                  );

           IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Add_Offset_Supplies:  Number of rows inserted '||
                               SQL%ROWCOUNT);
           END IF;

    -- Bug 3381464 Update offset_supply_id in msc_atp_pegging.
    FORALL i in 1..l_del_rows
      UPDATE msc_atp_pegging map1
      SET    offset_supply_id = x_supply_id(i)
      WHERE  map1.plan_id = p_plan_id
      AND    DECODE(map1.demand_source_type,100,map1.demand_source_type,-1)
                =decode(p_demand_source_type,
                                         100,
                                         p_demand_source_type,
                                         -1) --CMRO;
      AND    map1.sales_order_line_id in (p_identifier, p_config_line_id)
      AND    map1.relief_type = l_offset_type  -- PO, CTO_PF_PRJ_2
      AND    map1.inventory_item_id = x_inv_item_id(i)
             -- Bug 3717618 Use a pegging_id array to track pegging
             -- For filtering out, released/firmed supplies and pegging both are needed.
      AND    map1.pegging_id = l_pegging_id(i)
      AND    map1.supply_id = l_orig_supply_id(i);

      IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Supplies:  Number of rows Updated '|| SQL%ROWCOUNT);
           FOR i in 1..l_del_rows LOOP
              msc_sch_wb.atp_debug('Add_Offset_Supplies:  Supply Id '|| l_orig_supply_id(i) ||
                                        ' Offset Supply Id ' || x_supply_id(i));
           END LOOP;
      END IF;
    -- End Bug 3381464.


      IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
          (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
          (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
          (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

         IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Add_Offset_Supplies: ' ||
                  ' before insert into' || ' msc_alloc_supplies');
         END IF;

         -- CTO_PF_PRJ_2 relief_type already set above.
         -- Bug 3344102 First set offset type to 6 for supply alloc reliefs.
         -- l_offset_type := 6;
         -- End CTO_PF_PRJ_2

         -- Try to apply the offsets using alloc specific relief_type.
         FORALL i in 1..x_supply_id.COUNT
           INSERT INTO MSC_ALLOC_SUPPLIES(
                       PLAN_ID,
                       INVENTORY_ITEM_ID,
                       ORGANIZATION_ID,
                       SR_INSTANCE_ID,
                       DEMAND_CLASS,
                       SUPPLY_DATE,
                       PARENT_TRANSACTION_ID,
                       ALLOCATED_QUANTITY,
                       ORDER_TYPE,
                       SALES_ORDER_LINE_ID,
                       refresh_number,
                       CREATED_BY,
                       CREATION_DATE,
                       LAST_UPDATED_BY,
                       LAST_UPDATE_DATE
                       )
           SELECT
                   map.plan_id,
                   map.inventory_item_id,
                   map.organization_id,
                   map.sr_instance_id,
                   map.demand_class,
                   map.transaction_date,
                   x_supply_id(i),
                   NVL(map.relief_quantity, 0),
                   60,
                   map.sales_order_line_id,
                   p_refresh_number,
                   l_user_id,
                   l_sysdate,
                   l_user_id,
                   l_sysdate
           FROM    msc_atp_pegging map
           WHERE   map.sr_instance_id = l_instance_id(i)
           AND     map.plan_id = p_plan_id
           AND     DECODE(map.demand_source_type,100,map.demand_source_type,-1)
                   =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO;

           AND     map.sales_order_line_id in (p_identifier, p_config_line_id)
           AND     map.relief_type = l_offset_type --PO
                   -- Bug 3717618 Use a pegging_id array to track pegging
                   -- For filtering out released/firmed supplies both are needed.
           AND     map.pegging_id = l_pegging_id(i)
           AND     ABS(map.relief_quantity) > C_ZERO_APPROXIMATOR
           -- Bug 3761824 Use Precision figure while creating ofsets.
           AND     map.supply_id = l_offset_supply_id(i); -- Original Supply

         IF PG_DEBUG in ('Y', 'C') THEN
             FOR i in 1..x_supply_id.COUNT LOOP
                msc_sch_wb.atp_debug('Supply to be offset ' || l_offset_supply_id(i));
                msc_sch_wb.atp_debug('Actual Item ' || x_inv_item_id(i));
                msc_sch_wb.atp_debug('Relief Qty' || l_supply_qty(i));
                msc_sch_wb.atp_debug('New Supply ' || x_supply_id(i));
                msc_sch_wb.atp_debug('Add_Offset_Demands:  Number of rows inserted '||
                  'For Supply id '|| l_offset_supply_id(i) ||
                  ' with offset/relief_type = 6 is ' || SQL%BULK_ROWCOUNT(i));
             END LOOP;
              msc_sch_wb.atp_debug('Add_Offset_Supplies:  Number of Alloc rows inserted '||
                 'with offset/relief_type = ' ||l_offset_type || 'is ' || SQL%ROWCOUNT);
         END IF;

         -- CTO_PF_PRJ_2
         -- Cascading SQLs no longer necessary
         -- IF SQL%ROWCOUNT = 0 THEN

           -- Apply using standard supplies relief_type

         -- END IF;
         -- End Bug 3344102
         -- END CTO_PF_PRJ_2


      END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Add_Offset_Supplies *****');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       BEGIN
         -- Bug 3381464 Update offset_supply_id in msc_atp_pegging.
         FORALL i in 1..l_del_rows
            UPDATE msc_atp_pegging map1
            SET    offset_supply_id = NULL
            WHERE  map1.plan_id = p_plan_id
            AND    DECODE(map1.demand_source_type,100,map1.demand_source_type,-1)
                    =decode(p_demand_source_type,
                                         100,
                                         p_demand_source_type,
                                         -1) --CMRO;
            AND    map1.sales_order_line_id in (p_identifier, p_config_line_id)
            AND    map1.relief_type = NVL(l_offset_type, 2)  -- PO
            AND    map1.inventory_item_id = x_inv_item_id(i)
            AND    map1.supply_id = l_orig_supply_id(i);
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Supplies:  Number of rows Updated '||
                             SQL%ROWCOUNT);
         END IF;

       EXCEPTION
        WHEN OTHERS THEN
         IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Supplies: ' ||
                'error in updating offset supplies =  '|| sqlerrm );
         END IF;
       END;
       -- End Bug 3381464.

        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Supplies: ' ||
                'error in insert row: sqlcode =  '|| to_char(my_sqlcode));
           msc_sch_wb.atp_debug('Add_Offset_Supplies: ERROR- ' || sqlerrm );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Add_Offset_Supplies');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Add_Offset_Supplies;

PROCEDURE Add_Offset_Resource_Reqs (
                     p_identifier                      IN NUMBER,
                     p_config_line_id                  IN NUMBER,
                     p_plan_id                         IN NUMBER,
                     p_refresh_number                  IN NUMBER,
                     p_order_number                    IN NUMBER,
                     p_demand_source_type              IN NUMBER,--cmro
                     x_inv_item_id                     IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_res_transactions                IN OUT NoCopy MRP_ATP_PUB.Number_Arr,
                     x_res_instance_id                 OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                     x_return_status                   IN OUT NoCopy VARCHAR2
                     )
IS
    l_del_rows                  NUMBER;
    i                           PLS_INTEGER;
    my_sqlcode                  NUMBER;

    l_supply_id                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_instance_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_organization_id           MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_resource_seq_num          MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_resource_id               MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_department_id             MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_start_date                MRP_ATP_PUB.Date_Arr := MRP_ATP_PUB.Date_Arr();
    l_end_date                  MRP_ATP_PUB.Date_Arr := MRP_ATP_PUB.Date_Arr();
    l_resource_hours            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_daily_resource_hours      MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_load_rate                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_assigned_units            MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_std_op_code               MRP_ATP_PUB.char10_arr;

    l_basis_type                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_op_seq_num                MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
    l_parent_id                 MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();

    l_sysdate                   DATE;
    l_user_id                   number;

    -- CTO_PF_PRJ_2 Changes
    l_offset_type               NUMBER;
BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('***** Begin Add_Offset_Resource_Reqs *****');
     END IF;
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs: ' ||
                          'Offsetting msc_resource_requirements for identifier = '
                      || p_identifier ||' : plan id = '||p_plan_id);
     msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs: Config Line Id = ' || p_config_line_id );
     END IF ;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- CTO_PF_PRJ_2 Changes
     IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
        (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
        (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
        (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

         l_offset_type := 6;
     ELSE
         l_offset_type := 2;
     END IF;
     -- End CTO_PF_PRJ_2 Changes

     l_sysdate := sysdate;
     l_user_id := FND_GLOBAL.USER_ID;

  -- Insert demand into msc_resource_requirements
     SELECT
                  supply_id,
                  sr_instance_id,
                  msc_resource_requirements_s.nextval,
                  organization_id,
                  inventory_item_id,
                  basis_type,
                  operation_seq_num,
                  parent_id,
                  resource_seq_num,
                  resource_id,
                  department_id,
                  start_date,
                  end_date,
                  relief_quantity,
                  daily_relief_qty,
                  load_rate,
                  assigned_units,    -- 0 originally.
                  std_op_code
     BULK COLLECT
     INTO
                  l_supply_id,
                  l_instance_id,
                  x_res_transactions,
                  l_organization_id,
                  x_inv_item_id,
                  l_basis_type,
                  l_op_seq_num,
                  l_parent_id,
                  l_resource_seq_num,
                  l_resource_id,
                  l_department_id,
                  l_start_date,
                  l_end_date,
                  l_resource_hours,
                  l_daily_resource_hours,
                  l_load_rate,
                  l_assigned_units,
                  l_std_op_code
    FROM
         (SELECT  DISTINCT
                  -- Bug 3381464 Obtain the Offset Suuply_ID
                  map2.offset_supply_id supply_id,
                  -- REQ.supply_id,
                  -- This ensures that offset resource requirements are pegged to offset supplies.
                  -- End Bug 3381464.
                  map.sr_instance_id,
                  REQ.transaction_id,
                  map.organization_id,
                  map.inventory_item_id,
                  REQ.basis_type,
                  REQ.operation_seq_num,
                  REQ.parent_id,
                  REQ.resource_seq_num,
                  map.resource_id,
                  map.department_id,
                  NVL(map.start_date, REQ.start_date) start_date,
                            -- Bug 3443056, 3348095 ATP now tracks end date.
                  map.end_date,
                  map.relief_quantity,
                  map.daily_relief_qty,
                  decode(map.resource_id,-1,map.relief_quantity,to_number(null)) load_rate,
                  REQ.assigned_units,    -- 0 originally.
                  REQ.std_op_code
          FROM       msc_atp_pegging map,
                     msc_resource_requirements REQ,
                     -- Bug 3381464 -- Join to Pegging to obtain offset supply ids.
                     msc_atp_pegging map2
          WHERE   map.plan_id = p_plan_id
          --AND      map.sr_instance_id = p_instance_id  -- removed to support multiple instances in plan.
          AND      DECODE(map.demand_source_type,100,map.demand_source_type,-1)
                   =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1) --CMRO;

          AND      map.sales_order_line_id in (p_identifier, p_config_line_id)
          AND      map.relief_type = 4  -- REQ
          AND      ABS(map.relief_quantity) > C_ZERO_APPROXIMATOR
          -- Bug 3761824 Use Precision figure while creating ofsets.
          AND      REQ.sr_instance_id = map.sr_instance_id
          AND      REQ.plan_id = map.plan_id
          AND      REQ.organization_id = map.organization_id
          --AND      REQ.supply_id = map.supply_id
          AND      REQ.transaction_id = map.supply_id   -- Here resource transaction ids.
          AND      REQ.resource_id = map.resource_id
          AND      REQ.department_id = map.department_id
          AND      REQ.assembly_item_id = map.inventory_item_id
          AND      ( (NVL(REQ.record_source, 1) = 1 AND
                           TRUNC(REQ.start_date) = TRUNC(map.start_date))
                    OR (REQ.record_source = 2 AND TRUNC(REQ.end_date) = TRUNC(map.end_date)) )
                            -- Bug 3443056, 3348095 ATP now tracks end date.
          -- Bug 3381464 Get Offset Supply Data.
          AND      map2.sr_instance_id = REQ.sr_instance_id
          AND      map2.plan_id = REQ.plan_id
          AND      map2.organization_id = REQ.organization_id
          AND      map2.inventory_item_id = REQ.assembly_item_id
          AND      map2.supply_id = REQ.supply_id
          -- Bug 3717618 Ensure that supply is relieved
          -- Only those corresponding resource reqs will be offset.
          AND      map2.offset_supply_id is NOT NULL
          -- End Bug 3717618
          AND      map2.relief_type = l_offset_type -- CTO_PF_PRJ_2
          AND      map2.sales_order_line_id = map.sales_order_line_id
          AND      DECODE(map2.demand_source_type,100,map2.demand_source_type,-1)
                   = DECODE(map.demand_source_type,100,map.demand_source_type,-1)
          -- End Bug 3381464
        )
     ;

     x_res_instance_id := l_instance_id; --Bug 3629191

     l_del_rows := x_res_transactions.COUNT;

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs: ' ||
                          'Total Rows to add = ' || l_del_rows );
     END IF;
     FORALL i in 1..l_del_rows
       INSERT into msc_resource_requirements
                 (plan_id,
                  supply_id,
                  transaction_id,
                  organization_id,
                  sr_instance_id,
                  assembly_item_id,
                  basis_type,
                  operation_seq_num,
                  parent_id,
                  record_source,
                  resource_seq_num,
                  resource_id,
                  department_id,
                  refresh_number,
                  start_date,
                  end_date,
                  resource_hours,
                  daily_resource_hours,
                  load_rate,
                  assigned_units,
                  supply_type, -- 1510686
                  std_op_code, --resource batching
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by)
       VALUES     (p_plan_id,
                   l_supply_id(i),
                   x_res_transactions(i),
                   l_organization_id(i),
                   l_instance_id(i),
                   x_inv_item_id(i),
                   l_basis_type(i),
                   l_op_seq_num(i),
                   l_parent_id(i),
                   2,                 -- ATP generated record.
                   l_resource_seq_num(i),
                   l_resource_id(i),
                   l_department_id(i),
                   p_refresh_number,
                   l_start_date(i),
                   l_end_date(i),
                   l_resource_hours(i),
                   l_daily_resource_hours(i),
                   l_load_rate(i),
                   l_assigned_units(i),   -- 0 originally.
                   60,                     -- for Resources offset supply type is applicable.
                   l_std_op_code(i),
                   l_sysdate,
                   l_user_id,
                   l_sysdate,
                   l_user_id ) ;

     IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs:  Number of rows inserted '||
                               SQL%ROWCOUNT);
     END IF;


    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('***** End Add_Offset_Resource_Reqs *****');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs: ' ||
                'error in processing: sqlcode =  '|| to_char(my_sqlcode));
           msc_sch_wb.atp_debug('Add_Offset_Resource_Reqs: ' ||
                'error in processing: errmsg =  '|| sqlerrm );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Add_Offset_Resource_Reqs');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Add_Offset_Resource_Reqs;

PROCEDURE Add_Offset_Data (
                    p_identifier       IN         NUMBER,
                    p_config_line_id   IN         NUMBER,
                    p_plan_id          IN         NUMBER,
                    p_refresh_number   IN         NUMBER,
                    p_order_number     IN         NUMBER,
                    p_demand_source_type IN       NUMBER,--cmro
                    x_inv_item_id      OUT NoCopy MRP_ATP_PUB.Number_Arr,
                    x_demand_id        OUT NoCopy MRP_ATP_PUB.Number_Arr,
                    x_supply_id        OUT NoCopy MRP_ATP_PUB.Number_Arr,
                    x_res_transactions OUT NoCopy MRP_ATP_PUB.Number_Arr,
                    x_demand_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    x_supply_instance_id OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    x_res_instance_id    OUT NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    x_return_status    OUT NoCopy VARCHAR2
                    )
IS

l_inv_demand_items      MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
l_inv_supply_items      MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
j                       PLS_INTEGER;
i                       PLS_INTEGER;
match_found             NUMBER;
l_supply_instance_id    MRP_ATP_PUB.Number_Arr := MRP_ATP_PUB.Number_Arr();
BEGIN

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('**********Begin Add_Offset_Data Procedure************');
        msc_sch_wb.atp_debug('Add_Offset_Data p_identifier :' || p_identifier);
        msc_sch_wb.atp_debug('Add_Offset_Data p_config_line_id :' || p_config_line_id);
        msc_sch_wb.atp_debug('Add_Offset_Data p_plan_id :' || p_plan_id);
        msc_sch_wb.atp_debug('Add_Offset_Data p_refresh_number :' || p_refresh_number);
        msc_sch_wb.atp_debug('Add_Offset_Data p_order_number :' || p_order_number);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Bug 3717618 Flip the order of calls to
    -- Add Offset records, First call Offset Supplies and

    Add_Offset_Supplies (p_identifier, p_config_line_id, p_plan_id,
                         p_refresh_number, p_order_number,p_demand_source_type,--cmro
                         l_inv_supply_items, x_supply_id, x_supply_instance_id, x_return_status); --Bug 3629191

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Add_Offset_Supplies :' || x_return_status);
    END IF;

    -- and then call Offset Demands
    -- so that only those demands tied to offset supplies are relieved.
    Add_Offset_Demands (p_identifier, p_config_line_id, p_plan_id,
                        p_refresh_number, p_order_number,p_demand_source_type,--cmro
                        l_inv_demand_items, x_demand_id, x_demand_instance_id, x_return_status); --Bug 3629191

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Add_Offset_Demands :' || x_return_status);
    END IF;
    -- End Bug 3717618 Flip the order of calls ...

    FOR j in 1..l_inv_supply_items.COUNT LOOP

      match_found := 2;  -- match found is set to false.
      FOR i in 1..l_inv_demand_items.COUNT LOOP
        IF (l_inv_demand_items(i) = l_inv_supply_items(j)) THEN
          -- match found exit loop
          match_found:= 1;
          EXIT;
        END IF;
      END LOOP;

      -- match not found, add to list of items.
      IF (match_found = 2) THEN
         l_inv_demand_items.EXTEND;
         l_inv_demand_items(l_inv_demand_items.COUNT) := l_inv_supply_items(j);
      END IF;

    END LOOP;

    Add_Offset_Resource_Reqs (p_identifier, p_config_line_id,  p_plan_id,
                              p_refresh_number, p_order_number,p_demand_source_type,--cmro
                              l_inv_supply_items, x_res_transactions, x_res_instance_id, x_return_status); --Bug 3629191

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Add_Offset_Resource_Reqs :'
                                         || x_return_status);
    END IF;


    -- Finally assign to output list
    x_inv_item_id := l_inv_demand_items;

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('**********End Add_Offset_Data Procedure************');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Add_Offset_Data');
        END IF;

        IF PG_DEBUG in ('Y', 'C')  THEN
           msc_sch_wb.atp_debug('Add_Offset_Data: ERROR' || sqlerrm );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Add_Offset_Data;

PROCEDURE Remove_Offset_Demands (
             --p_identifiers      IN       MRP_ATP_PUB.Number_Arr,
             --p_plan_ids         IN       MRP_ATP_PUB.Number_Arr,
             p_atp_peg_demands_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
             p_inv_item_ids     IN       MRP_ATP_PUB.Number_Arr,
             p_del_demand_ids   IN       MRP_ATP_PUB.Number_Arr,
             p_demand_source_type IN     MRP_ATP_PUB.Number_Arr,--cmro
             x_return_status    IN OUT   NoCopy VARCHAR2
                                )
IS
l_del_rows          NUMBER;
i                   NUMBER;
m                   PLS_INTEGER := 1;

-- CTO_PF_PRJ_2 Impacts
l_offset_type               NUMBER;
-- End CTO_PF_PRJ_2 Impacts

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Remove_Offset_Demands Procedure************');
    END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
       FOR i in 1..p_del_demand_ids.COUNT LOOP
            msc_sch_wb.atp_debug('Remove_Offset_Demands: ' ||
                             'p_del_demand_ids('||i||') = '|| p_del_demand_ids(i)||
                             --'p_inv_item_ids('||i||') = '|| p_inv_item_ids(i)||
                             'p_atp_peg_demands_plan_ids('||i||') = '|| p_atp_peg_demands_plan_ids(i)
                             --'p_plan_ids('||i||') = '|| p_plan_ids(i)||
                             --'p_identifiers('||i||') = '|| p_identifiers(i)
                             );
       END LOOP;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- CTO_PF_PRJ_2 Impacts
   IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
       (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
       (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
       (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

      l_offset_type := 5;
   ELSE
      l_offset_type := 3;
   END IF;
   -- End CTO_PF_PRJ_2

   --Bug 3629191
   FORALL m IN 1..p_del_demand_ids.COUNT
      DELETE msc_demands
      WHERE
      -- Bug 3629191 :All where clause except plan_id and demand_id are commmented
      /* sr_instance_id  = p_instance_id
      (SELECT sr_instance_id
       FROM   msc_atp_pegging
       WHERE  plan_id = p_plan_ids(m)
       AND    sales_order_line_id = p_identifiers(m)
       AND     DECODE(demand_source_type,100,demand_source_type,-1)
                      =decode(p_demand_source_type(m),
                              100,
                              p_demand_source_type(m),
                              -1)  --CMRO;
       AND    inventory_item_id = p_inv_item_ids(m)
       -- CTO_PF_PRJ_2 Impacts
       AND    relief_type in (l_offset_type, 7)
       -- End CTO_PF_PRJ_2
      )
      AND */
             plan_id = p_atp_peg_demands_plan_ids(m)
      --AND  inventory_item_id = p_inv_item_ids(m) -- Bug 3629191
      AND    demand_id = p_del_demand_ids(m);

   -- Count how many rows were updated for each demand id
   IF PG_DEBUG in ('Y', 'C') THEN
        FOR m IN 1..p_del_demand_ids.COUNT LOOP
           msc_sch_wb.atp_debug('For Demand id '|| p_del_demand_ids(m)||': updated '||
                        SQL%BULK_ROWCOUNT(m)||' records');
        END LOOP;
   END IF;

   --    (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN
   -- Allocation Profiles check that was there before has been removed
   -- with the introduction of CTO_PF_PRJ_2 impacts.
   -- Relief_Type 7 can get created irrespective of allocation profiles.

      IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Remove_Offset_Demands: before delete from ' ||
                              ' msc_alloc_demands');
      END IF;

      --Bug 3629191
      FORALL m IN 1..p_del_demand_ids.COUNT
         DELETE msc_alloc_demands
         WHERE
         -- Bug 3629191 :All where clause except plan_id and parent_demand_id are commmented
         /*sr_instance_id IN
         (SELECT sr_instance_id
          FROM   msc_atp_pegging
          WHERE  plan_id = p_plan_ids(m)
          AND    sales_order_line_id = p_identifiers(m)
          AND    DECODE(demand_source_type,100,demand_source_type,-1)
                 =decode(p_demand_source_type(m),
                         100,
                         p_demand_source_type(m),
                         -1) --CMRO;
          AND    inventory_item_id = p_inv_item_ids(m)
          -- CTO_PF_PRJ_2 Impacts
          AND    relief_type in (l_offset_type, 7)
          -- End CTO_PF_PRJ_2
         )
         AND */
                plan_id = p_atp_peg_demands_plan_ids(m)
         --AND  inventory_item_id = p_inv_item_ids(m) -- Bug 3629191
         AND    parent_demand_id = p_del_demand_ids(m)
;

         -- Count how many rows were updated for each demand id
      IF PG_DEBUG in ('Y', 'C') THEN
           FOR m IN 1..p_del_demand_ids.COUNT LOOP
              msc_sch_wb.atp_debug('For Demand id '|| p_del_demand_ids(m)||': updated '||
                      SQL%BULK_ROWCOUNT(m)||' records');
           END LOOP;
      END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Remove_Offset_Demands Procedure************');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Remove_Offset_Demands');
        END IF;

        IF PG_DEBUG in ('Y', 'C')  THEN
           msc_sch_wb.atp_debug('Remove_Offset_Demands: ERROR' || sqlerrm );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Remove_Offset_Demands;

PROCEDURE Remove_Offset_Supplies (
             --p_identifiers      IN       MRP_ATP_PUB.Number_Arr,
             --p_plan_ids         IN       MRP_ATP_PUB.Number_Arr,
             p_atp_peg_supplies_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
             p_inv_item_ids     IN       MRP_ATP_PUB.Number_Arr,
             p_del_supply_ids   IN       MRP_ATP_PUB.Number_Arr,
             p_demand_source_type IN     MRP_ATP_PUB.Number_Arr,--cmro
             x_return_status    IN OUT   NoCopy VARCHAR2
                                )
IS
l_del_rows          NUMBER;
i                   NUMBER;
m                   PLS_INTEGER := 1;

-- CTO_PF_PRJ_2 Impacts
l_offset_type               NUMBER;
-- End CTO_PF_PRJ_2 Impacts

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Remove_Offset_Supplies Procedure************');
    END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
       FOR i in 1..p_del_supply_ids.COUNT LOOP
            msc_sch_wb.atp_debug('Remove_Offset_Supplies: ' ||
                             'p_del_supply_ids('||i||') = '|| p_del_supply_ids(i)||
                             --'p_inv_item_ids('||i||') = '|| p_inv_item_ids(i)||
                             --'p_plan_ids('||i||') = '|| p_plan_ids(i)||
                             'p_atp_peg_supplies_plan_ids('||i||') = '|| p_atp_peg_supplies_plan_ids(i)
                             --'p_identifiers('||i||') = '|| p_identifiers(i)
                             );
       END LOOP;
   END IF;


   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- CTO_PF_PRJ_2 Changes Set Relief Type
    IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

       l_offset_type := 6;
    ELSE
       l_offset_type := 2;
    END IF;
    -- End CTO_PF_PRJ_2 Changes

   -- Bug 3381464 Update offset_supply_id in msc_atp_pegging.
   --Bug 3629191
   FORALL m in 1..p_del_supply_ids.COUNT
      UPDATE msc_atp_pegging map1
      SET    offset_supply_id = NULL
      WHERE  map1.plan_id = p_atp_peg_supplies_plan_ids(m)
      -- Bug 3629191: where clause on demand_source_type, sales_order_line_id
      -- and inventory_item_id are removed
      /*AND    DECODE(map1.demand_source_type,100,map1.demand_source_type,-1)
                      =decode(p_demand_source_type(m),
                              100,
                              p_demand_source_type(m),
                              -1) --CMRO;
      AND    map1.sales_order_line_id = p_identifiers(m) */
      AND    map1.relief_type = l_offset_type  -- PO
      --AND  map1.inventory_item_id = p_inv_item_ids(m) -- Bug 3629191
      AND    map1.offset_supply_id = p_del_supply_ids(m);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Remove_Offset_Supplies:  Number of rows Updated '||
                             SQL%ROWCOUNT);
      END IF;
   -- End Bug 3381464.

   -- CTO_PF_PRJ_2 Changes Set Relief Type
    IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

       l_offset_type := 6;
    ELSE
       l_offset_type := 2;
    END IF;
    -- End CTO_PF_PRJ_2 Changes

   --Bug 3629191
   FORALL m IN 1..p_del_supply_ids.COUNT
      DELETE msc_supplies
      WHERE
      -- Bug 3629191 :All where clause except and transaction_id are commmented
      /* sr_instance_id = p_instance_id
      (SELECT sr_instance_id
       FROM   msc_atp_pegging
       WHERE  plan_id = p_plan_ids(m)
       AND    sales_order_line_id = p_identifiers(m)
       AND     DECODE(demand_source_type,100,demand_source_type,-1)
                      =decode(p_demand_source_type(m),
                              100,
                              p_demand_source_type(m),
                              -1) --CMRO;
       -- CTO_PF_PRJ_2 Changes Use Relief Type
       AND    relief_type = l_offset_type
       -- End CTO_PF_PRJ_2 Changes
       AND    inventory_item_id = p_inv_item_ids(m)
      )
      AND */
             plan_id = p_atp_peg_supplies_plan_ids(m)
      --AND  inventory_item_id = p_inv_item_ids(m) --Bug 3629191
      AND    transaction_id = p_del_supply_ids(m);

   -- Count how many rows were updated for each supply id
   IF PG_DEBUG in ('Y', 'C') THEN
        FOR m IN 1..p_del_supply_ids.COUNT LOOP
           msc_sch_wb.atp_debug('For Supply id '|| p_del_supply_ids(m)||': updated '||
                        SQL%BULK_ROWCOUNT(m)||' records');
        END LOOP;
   END IF;

   IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
       (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
       (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
       (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

      IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Remove_Offset_Supplies: before delete from ' ||
                              ' msc_alloc_supplies');
      END IF;

      --Bug 3629191
      FORALL m IN 1..p_del_supply_ids.COUNT
         DELETE msc_alloc_supplies
         WHERE
         -- Bug 3629191 :All where clause except and parent_transaction_id are commmented
         /* sr_instance_id = p_instance_id
         (SELECT sr_instance_id
          FROM   msc_atp_pegging
          WHERE  plan_id = p_plan_ids(m)
          -- CTO_PF_PRJ_2 Changes Use Relief Type
          AND    relief_type = l_offset_type
          -- End CTO_PF_PRJ_2 Changes
          AND    sales_order_line_id = p_identifiers(m)
          AND     DECODE(demand_source_type,100,demand_source_type,-1)
                         =decode(p_demand_source_type(m),
                                 100,
                                 p_demand_source_type(m),
                                 -1) --CMRO;
          AND    inventory_item_id = p_inv_item_ids(m)
         )
         AND */
                plan_id = p_atp_peg_supplies_plan_ids(m)
         --AND  inventory_item_id = p_inv_item_ids(m) --Bug 3629191
         AND    parent_transaction_id = p_del_supply_ids(m)
         ;

         -- Count how many rows were updated for each supply id
      IF PG_DEBUG in ('Y', 'C') THEN
           FOR m IN 1..p_del_supply_ids.COUNT LOOP
              msc_sch_wb.atp_debug('For Supply id '|| p_del_supply_ids(m)||': updated '||
                      SQL%BULK_ROWCOUNT(m)||' records');
           END LOOP;
      END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Remove_Offset_Supplies Procedure************');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Remove_Offset_Supplies');
        END IF;

        IF PG_DEBUG in ('Y', 'C')  THEN
           msc_sch_wb.atp_debug('Remove_Offset_Supplies: ERROR' || sqlerrm );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Remove_Offset_Supplies;


PROCEDURE Remove_Offset_Resource_Reqs (
             --p_identifiers      IN       MRP_ATP_PUB.Number_Arr,
             --p_plan_ids         IN       MRP_ATP_PUB.Number_Arr,
             p_atp_peg_res_reqs_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
             p_inv_item_ids     IN       MRP_ATP_PUB.Number_Arr,
             p_del_resrc_reqs   IN       MRP_ATP_PUB.Number_Arr,
             p_demand_source_type IN     MRP_ATP_PUB.Number_Arr,--cmro
             x_return_status    IN OUT   NoCopy VARCHAR2
                                )
IS
l_del_rows          NUMBER;
i                   NUMBER;
m                   PLS_INTEGER := 1;
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Remove_Offset_Resource_Reqs Procedure************');
    END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
       FOR i in 1..p_del_resrc_reqs.COUNT LOOP
            msc_sch_wb.atp_debug('Remove_Offset_Resource_Reqs: ' ||
                             'p_del_resrc_reqs('||i||') = '|| p_del_resrc_reqs(i)||
                             --'p_inv_item_ids('||i||') = '|| p_inv_item_ids(i)||
                             --'p_plan_ids('||i||') = '|| p_plan_ids(i)||
                             --'p_identifiers('||i||') = '|| p_identifiers(i)
                             'p_atp_peg_res_reqs_plan_ids('||i||') = '|| p_atp_peg_res_reqs_plan_ids(i)
                             );
       END LOOP;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Bug 3629191
   FORALL m IN 1..p_del_resrc_reqs.COUNT
      DELETE msc_resource_requirements
      WHERE
      -- Bug 3629191 :All where clause except and transaction_id are commmented
      /*sr_instance_id = p_instance_id
      (SELECT sr_instance_id
       FROM   msc_atp_pegging
       WHERE  plan_id = p_plan_ids(m)
       AND    sales_order_line_id = p_identifiers(m)
       AND     DECODE(demand_source_type,100,demand_source_type,-1)
                      =decode(p_demand_source_type(m),
                              100,
                              p_demand_source_type(m),
                              -1) --CMRO;
       AND    inventory_item_id = p_inv_item_ids(m)
       AND    relief_type = 4
      )
      AND */
             plan_id = p_atp_peg_res_reqs_plan_ids(m) --Bug 3629191
      --AND  assembly_item_id = p_inv_item_ids(m)
      AND    transaction_id = p_del_resrc_reqs(m);

   -- Count how many rows were updated for each resource transaction id
   IF PG_DEBUG in ('Y', 'C') THEN
        FOR m IN 1..p_del_resrc_reqs.COUNT LOOP
           msc_sch_wb.atp_debug('For Transaction id '|| p_del_resrc_reqs(m)||': updated '||
                        SQL%BULK_ROWCOUNT(m)||' records');
        END LOOP;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********End Remove_Offset_Resource_Reqs Procedure************');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Remove_Offset_Resource_Reqs');
        END IF;

        IF PG_DEBUG in ('Y', 'C')  THEN
           msc_sch_wb.atp_debug('Remove_Offset_Supplies: ERROR' || sqlerrm );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Remove_Offset_Resource_Reqs;

PROCEDURE Remove_Offset_Data (
                    --p_identifiers      IN         MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    --p_plan_ids         IN         MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    p_inv_item_ids     IN         MRP_ATP_PUB.Number_Arr,
                    p_del_demand_ids   IN         MRP_ATP_PUB.Number_Arr,
                    p_del_supply_ids   IN         MRP_ATP_PUB.Number_Arr,
                    p_del_resrc_reqs   IN         MRP_ATP_PUB.Number_Arr,
                    p_demand_source_type IN       MRP_ATP_PUB.Number_Arr,--cmro
                    p_atp_peg_demands_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    p_atp_peg_supplies_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    p_atp_peg_res_reqs_plan_ids IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
                    x_return_status    OUT NoCopy VARCHAR2
                    )
IS
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('**********Begin Remove_Offset_Data Procedure************');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Remove_Offset_Demands ( --p_identifiers, p_plan_ids,
                           p_atp_peg_demands_plan_ids, --Bug 3629191
                           p_inv_item_ids, p_del_demand_ids,p_demand_source_type, x_return_status);--cmro

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Remove_Offset_Demands :'
                                                        || x_return_status);
    END IF;

    Remove_Offset_Supplies ( --p_identifiers, p_plan_ids,
                            p_atp_peg_supplies_plan_ids, --Bug 3629191
                            p_inv_item_ids, p_del_supply_ids,p_demand_source_type,x_return_status);--cmro

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Remove_Offset_Supplies :'
                                                        || x_return_status);
    END IF;

    Remove_Offset_Resource_Reqs ( --p_identifiers, p_plan_ids,
                           p_atp_peg_res_reqs_plan_ids, --Bug 3629191
                           p_inv_item_ids, p_del_resrc_reqs,p_demand_source_type,x_return_status);--cmro

    IF PG_DEBUG in ('Y', 'C')  THEN
        msc_sch_wb.atp_debug('Status After Call to Remove_Offset_Resource_Reqs :'
                                                        || x_return_status);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , 'Remove_Offset_Data');
        END IF;

        IF PG_DEBUG in ('Y', 'C')  THEN
           msc_sch_wb.atp_debug('Remove_Offset_Data: ERROR' || sqlerrm );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Bug 3319810 Enable exception generation.
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Remove_Offset_Data;

-- Create Simplified pegging data for PF ATP Scenario.
-- CTO_PF_PRJ_2 New procedure for CTO PF Cross Project Impacts.
PROCEDURE Create_PF_Atp_Pegging(
  p_reference_item_id      IN         NUMBER,
  p_model_order_line_id    IN         NUMBER,
  p_config_order_line_id   IN         NUMBER,
  p_demand_source_type     IN         NUMBER,--cmro
  p_end_demand_id          IN         NUMBER,
  p_plan_id                IN         NUMBER,
  x_return_status          IN OUT     NoCopy VARCHAR2
)
IS

my_sqlcode                NUMBER;
l_dmd_offset_typ          NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Create_PF_Atp_Pegging Procedure *****');
     msc_sch_wb.atp_debug('Reference Item Id : ' || p_reference_item_id);
     msc_sch_wb.atp_debug('Model Line Id p_model_order_line_id : ' || p_model_order_line_id);
     msc_sch_wb.atp_debug('Config. Line Id p_config_order_line_id : ' || p_config_order_line_id);
     msc_sch_wb.atp_debug('Demand Source Type : ' || p_demand_source_type);
     msc_sch_wb.atp_debug('SO End Demand Id : ' || p_end_demand_id);
     msc_sch_wb.atp_debug('Plan Id : ' || p_plan_id);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

     l_dmd_offset_typ := 5;
   ELSE
     l_dmd_offset_typ := 3;
   END IF;
  -- First create the demand records for component members and component family items.

  INSERT INTO msc_atp_pegging
          (reference_item_id, inventory_item_id, plan_id, sr_instance_id,
           organization_id, sales_order_line_id, demand_source_type, bom_item_type, --cmro
           transaction_date, demand_id, demand_quantity,
           disposition_id, demand_class, supply_id, supply_quantity,
           allocated_quantity, relief_type, relief_quantity, daily_relief_qty,
           pegging_id, prev_pegging_id, end_pegging_id, end_demand_id,
           created_by, creation_date, last_updated_by, last_update_date,
           original_item_id, original_date,
           customer_id, customer_site_id)
  SELECT mapt.reference_item_id, alocd.inventory_item_id, alocd.plan_id,
         alocd.sr_instance_id, alocd.organization_id,
         mapt.sales_order_line_id, mapt.demand_source_type,
         msi.bom_item_type, alocd.demand_date transaction_date,
         alocd.parent_demand_id demand_id, alocd.demand_quantity, mapt.disposition_id,
         alocd.demand_class, mapt.supply_id,
         mapt.supply_quantity, alocd.allocated_quantity, 7 relief_type,
         LEAST(ABS(mapt.relief_quantity), alocd.allocated_quantity) * SIGN(mapt.relief_quantity) *
         alocd.allocated_quantity/NVL(mapt.allocated_quantity,alocd.allocated_quantity) relief_quantity,
         LEAST(ABS(mapt.daily_relief_qty), alocd.allocated_quantity) * SIGN(mapt.relief_quantity) *
         alocd.allocated_quantity/NVL(mapt.allocated_quantity,alocd.allocated_quantity) daily_relief_qty,
         mapt.pegging_id, mapt.prev_pegging_id, mapt.end_pegging_id, mapt.end_demand_id,
         mapt.created_by, mapt.creation_date, mapt.last_updated_by, mapt.last_update_date,
         mapt.inventory_item_id, mapt.transaction_date,
         alocd.customer_id, alocd.ship_to_site_id
  FROM   msc_atp_peg_temp mapt, msc_alloc_demands alocd,
         msc_system_items msi
  WHERE  mapt.reference_item_id = p_reference_item_id
  AND    mapt.plan_id = p_plan_id
  AND    mapt.sales_order_line_id = NVL(p_config_order_line_id, p_model_order_line_id)
  --AND    mapt.demand_source_type = p_demand_source_type
  AND    mapt.end_demand_id = p_end_demand_id
  AND    mapt.relief_type = l_dmd_offset_typ
  AND    alocd.plan_id = mapt.plan_id
  AND    alocd.sr_instance_id = mapt.sr_instance_id
  AND    alocd.organization_id = mapt.organization_id
  AND    alocd.original_item_id = mapt.inventory_item_id
  AND    alocd.parent_demand_id = mapt.demand_id
  AND    msi.plan_id = alocd.plan_id
  AND    msi.sr_instance_id = alocd.sr_instance_id
  AND    msi.organization_id = alocd.organization_id
  AND    msi.inventory_item_id = alocd.inventory_item_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Create_PF_Atp_Pegging:  Number of rows inserted Stage-1 '||
                               SQL%ROWCOUNT);
  END IF;

  -- Now Create Rest of the Records.
  INSERT INTO msc_atp_pegging
          (reference_item_id, inventory_item_id, plan_id, sr_instance_id,
           organization_id, sales_order_line_id, demand_source_type, bom_item_type, --cmro
           transaction_date, demand_id, demand_quantity,
           disposition_id, demand_class, supply_id, supply_quantity,
           allocated_quantity,
           resource_id, department_id, resource_hours, end_date,
           relief_type, relief_quantity, daily_relief_qty,
           pegging_id, prev_pegging_id, end_pegging_id, end_demand_id,
           created_by, creation_date, last_updated_by, last_update_date,
           customer_id, customer_site_id)
  SELECT  reference_item_id, inventory_item_id, plan_id, sr_instance_id,
          organization_id, sales_order_line_id, demand_source_type, bom_item_type, --cmro
          transaction_date, demand_id, demand_quantity,
          disposition_id, demand_class, supply_id, supply_quantity,
          allocated_quantity,
          resource_id, department_id, resource_hours, end_date,
          relief_type, relief_quantity, daily_relief_qty,
          pegging_id, prev_pegging_id, end_pegging_id, end_demand_id,
          created_by, creation_date, last_updated_by, last_update_date,
          customer_id, customer_site_id
  FROM    msc_atp_peg_temp mapt
  WHERE   mapt.reference_item_id = p_reference_item_id
  AND     mapt.plan_id = p_plan_id
  AND     mapt.sales_order_line_id = NVL(p_config_order_line_id, p_model_order_line_id)
  --AND     mapt.demand_source_type = p_demand_source_type
  AND     mapt.end_demand_id = p_end_demand_id
          -- Process everything except PF member and family demands.
  AND     mapt.inventory_item_id NOT IN
          (SELECT NVL(original_item_id, inventory_item_id)
           FROM   msc_atp_pegging
           WHERE  reference_item_id = p_reference_item_id
           AND    plan_id = p_plan_id
           AND    sales_order_line_id = NVL(p_config_order_line_id, p_model_order_line_id)
           --AND    demand_source_type = p_demand_source_type
           AND    end_demand_id = p_end_demand_id
           AND    relief_type = 7
          );

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Create_PF_Atp_Pegging:  Number of rows inserted Stage-2 '||
                               SQL%ROWCOUNT);
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Create_PF_Atp_Pegging Procedure *****');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Create_PF_Atp_Pegging: ' || my_sqlcode ||
                ' error encountered while creating ATP Pegging : ERROR =  '|| sqlerrm);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Create_PF_Atp_Pegging');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_PF_Atp_Pegging;
-- End CTO_PF_PRJ_2

-- Create Simplified pegging data using ATP Pegging information.
PROCEDURE Create_Atp_Pegging(
  p_identifier             IN      NUMBER,
  p_instance_id            IN      NUMBER,
  p_old_plan_id            IN      NUMBER,
  p_model_order_line_id    IN      NUMBER,
  p_config_order_line_id   IN      NUMBER,
  p_demand_source_type     IN      NUMBER,--cmro
  x_return_status          OUT     NoCopy VARCHAR2
)
IS

l_reference_item_id       NUMBER;
i                         NUMBER;
atp_peg_rec               msc_atp_pegging%ROWTYPE;
my_sqlcode                NUMBER;
-- Bug 3334643 Track the plan_id
l_plan_id                 NUMBER;

-- CTO_PF_PRJ Get End Demand Id
l_end_demand_id                 NUMBER;
-- CTO_PF_PRJ_2 Impacts
l_session_id                    NUMBER;
l_insert_temp_table             VARCHAR2(30);
l_sql_stmt                      VARCHAR2(800);
l_sql_stmt_1                    VARCHAR2(8000);
l_sup_offset_typ                NUMBER;
l_dmd_offset_typ                NUMBER;
l_peg_type                      NUMBER;
-- End CTO_PF_PRJ_2 Impacts

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** Begin Create_Atp_Pegging Procedure *****');
     msc_sch_wb.atp_debug('End Pegging Id p_identifier : ' || p_identifier);
     msc_sch_wb.atp_debug('Instance Id p_instance_id : ' || p_instance_id);
     msc_sch_wb.atp_debug('Old Plan Id : ' || p_old_plan_id);
     msc_sch_wb.atp_debug('Model Line Id p_model_order_line_id : ' || p_model_order_line_id);
     msc_sch_wb.atp_debug('Config. Line Id p_config_order_line_id : ' || p_config_order_line_id);
     msc_sch_wb.atp_debug('Demand. Source Type p_demand_source_type : ' || p_demand_source_type);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- CTO_PF_PRJ_2 Impacts
   IF (MSC_ATP_PVT.G_CTO_PF_ATP = 'Y') THEN
      l_insert_temp_table := 'MSC_ATP_PEG_TEMP';
   ELSE
      l_insert_temp_table := 'MSC_ATP_PEGGING';
   END IF;

   IF ((MSC_ATP_PVT.G_INV_CTP = 4) AND
      (MSC_ATP_PVT.G_ALLOCATED_ATP = 'Y') AND
      (MSC_ATP_PVT.G_HIERARCHY_PROFILE = 1) AND
      (MSC_ATP_PVT.G_ALLOCATION_METHOD = 1)) THEN

     l_sup_offset_typ := 6;
     l_dmd_offset_typ := 5;
   ELSE
     l_sup_offset_typ := 2;
     l_dmd_offset_typ := 3;
   END IF;
   -- CTO_PF_PRJ_2 Impacts

   -- First Delete old pegging data.
   BEGIN

         DELETE from msc_atp_pegging
         WHERE  plan_id = p_old_plan_id
         AND    relief_type > 0
         AND    sales_order_line_id in (NVL(p_config_order_line_id, -1), p_model_order_line_id)
         AND     decode(demand_source_type,100,demand_source_type,-1)
                =decode(p_demand_source_type,
                                                100,
                                                p_demand_source_type,
                                                -1); --CMRO
      IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Create_Atp_Pegging:  Number of rows deleted '||
                               SQL%ROWCOUNT);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Create_Atp_Pegging:  Error '|| sqlerrm);
        END IF;

   END;

   -- CTO_PF_PRJ_2 Impacts SQL are changed to Dynamic Ones
   --  first insert the sales order line to the ATP simplified pegging.
   l_sql_stmt_1 := 'INSERT INTO ' || l_insert_temp_table ||
               '(reference_item_id, inventory_item_id, plan_id, sr_instance_id,
                organization_id, sales_order_line_id,demand_source_type, bom_item_type, --cmro
                transaction_date, demand_id, demand_quantity,
                disposition_id, demand_class, supply_id, supply_quantity,
                allocated_quantity,
                resource_id, department_id, resource_hours, end_date, -- start_date,
                            -- Bug 3443056, 3348095 ATP now tracks end date.
                relief_type, relief_quantity, daily_relief_qty,
                pegging_id, prev_pegging_id, end_pegging_id, end_demand_id,
                created_by, creation_date, last_updated_by, last_update_date,
                customer_id, customer_site_id)
         SELECT dest_inv_item_id , NVL(DEST_INV_ITEM_ID, INVENTORY_ITEM_ID),
                identifier2 plan_id, identifier1 sr_instance_id,
                NVL(RECEIVING_ORGANIZATION_ID, organization_id) ,
                NVL(:p_config_order_line_id, :p_model_order_line_id) sales_order_line_id,
                :p_demand_source_type,--cmro
                --bug 3328421
                --NULL bom_item_type, NVL(required_date, supply_demand_date) transaction_date,
                NULL bom_item_type, NVL(actual_supply_demand_date, supply_demand_date) transaction_date,
                -- identifier3 contains the demand_id
                -- supply_demand_quantity contains the demand_quantity
                DECODE (pegging_type, :l_peg_type1,
                         identifier3, NULL) demand_id,
                DECODE (pegging_type, :l_peg_type2,
                         supply_demand_quantity, NULL) supply_demand_quantity,
                NULL disposition_id, demand_class,
                -- identifier3 contains the transaction_id
                -- supply_demand_quantity contains the supply_quantitiy
                -- For ATP created pegging the allocated_qty is the same as supply_qty
                DECODE (pegging_type,
                         :l_peg_type3, identifier3,
                         :l_peg_type4, identifier3,
                         :l_peg_type5, identifier3,
                          NULL) supply_id,
                DECODE (pegging_type,
                         :l_peg_type6, supply_demand_quantity,
                         :l_peg_type7, supply_demand_quantity,
                         :l_peg_type8, supply_demand_quantity,
                          NULL) supply_quantity,
                DECODE (pegging_type,
                         :l_peg_type9, supply_demand_quantity,
                         :l_peg_type10, supply_demand_quantity,
                         :l_peg_type11, supply_demand_quantity,
                          NULL) allocated_quantity,
                resource_id, department_id,
                DECODE (pegging_type,
                         :l_peg_type12, supply_demand_quantity,
                         NULL) resource_hours,
                --bug 3328421
                --NVL(required_date, supply_demand_date) start_date,
                NVL(actual_supply_demand_date, supply_demand_date) end_date, -- start_date,
                            -- Bug 3443056, 3348095 ATP now tracks end date.
                DECODE (pegging_type,
                        :l_peg_type13,
                          decode(pegging_id, end_pegging_id, 1, :l_dmd_offset_typ),
                           -- pegging_id is same as end_pegging_id then SO
                           -- otherwise POD
                         :l_peg_type14, :l_sup_offset_typ,      -- PO
                         :l_peg_type15, :l_sup_offset_typ,  -- PO
                         :l_peg_type16, 4 , -- REQ
                         :l_peg_type17, :l_sup_offset_typ )
                          relief_type,
                decode(pegging_id, end_pegging_id, 0,
                      -1 *  supply_demand_quantity ) relief_quantity,
                NULL daily_relief_qty,
                pegging_id, parent_pegging_id, end_pegging_id,
                DECODE (pegging_type, :l_peg_type18,
                         identifier3, NULL) end_demand_id,
                created_by, creation_date, last_updated_by, last_update_date,
                customer_id, customer_site_id
         FROM   mrp_atp_details_temp
         WHERE  pegging_id = :p_identifier
         AND    identifier1 = :p_instance_id
         AND    record_type = 3
         and    session_id = :l_session_id
         and    model_sd_flag = 1' -- ensure that we only obtain pegging for things in the order.
         ;

  IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Create_Atp_Pegging:  Insert SQL Statement '||
                               l_sql_stmt_1);
  END IF;

    EXECUTE IMMEDIATE l_sql_stmt_1 USING
           p_config_order_line_id,
           p_model_order_line_id,
           p_demand_source_type,
           MSC_ATP_PVT.ORG_DEMAND,
           MSC_ATP_PVT.ORG_DEMAND,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.RESOURCE_DEMAND,
           MSC_ATP_PVT.ORG_DEMAND,
           l_dmd_offset_typ,
           MSC_ATP_PVT.MAKE_SUPPLY,
           l_sup_offset_typ,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           l_sup_offset_typ,
           MSC_ATP_PVT.RESOURCE_DEMAND,
           MSC_ATP_PVT.BUY_SUPPLY,
           l_sup_offset_typ,
           MSC_ATP_PVT.ORG_DEMAND,
           p_identifier,
           p_instance_id,
           MSC_ATP_PVT.G_SESSION_ID;
   -- End CTO_PF_PRJ_2 Impacts SQL are changed to Dynamic Ones

  IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Create_Atp_Pegging:  Number of rows inserted-1 '||
                               SQL%ROWCOUNT);
  END IF;

   SELECT       DEST_INV_ITEM_ID, identifier2,
                -- Bug 3334643 Track the plan_id
                -- CTO_PF_PRJ Get End Demand Id
                DECODE (pegging_type, MSC_ATP_PVT.ORG_DEMAND,
                         identifier3, NULL) end_demand_id
   INTO         l_reference_item_id, l_plan_id, l_end_demand_id
                -- End CTO_PF_PRJ Get End Demand Id
                -- Bug 3334643 Track the plan_id
   FROM         mrp_atp_details_temp
   WHERE        pegging_id = p_identifier
   AND          identifier1 = p_instance_id
   AND          record_type = 3
   AND          model_sd_flag = 1
   AND          session_id = MSC_ATP_PVT.G_SESSION_ID;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('Create_Atp_Pegging: l_reference_item_id ' ||
                                   l_reference_item_id);
                -- Bug 3334643 Track the plan_id
     msc_sch_wb.atp_debug('Create_Atp_Pegging: l_plan_id ' ||
                                   l_plan_id);
                -- CTO_PF_PRJ Get End Demand Id
     msc_sch_wb.atp_debug('Create_Atp_Pegging: End Demand Id ' ||
                                   l_end_demand_id);
                -- End CTO_PF_PRJ Get End Demand Id
  END IF;

  -- ORG_DEMAND             CONSTANT NUMBER := 1; POD, SO
  -- SUPPLIER_DEMAND        CONSTANT NUMBER := 2;
  -- ATP_SUPPLY             CONSTANT NUMBER := 3;
  -- MAKE_SUPPLY            CONSTANT NUMBER := 4; PO
  -- BUY_SUPPLY             CONSTANT NUMBER := 5; PO
  -- TRANSFER_SUPPLY        CONSTANT NUMBER := 6; PO
  -- ATP_SUPPLIER           CONSTANT NUMBER := 7;
  -- RESOURCE_DEMAND        CONSTANT NUMBER := 8; RES REQ
  -- RESOURCE_SUPPLY        CONSTANT NUMBER := 9;

  -- CTO_PF_PRJ_2 Impacts SQL are changed to Dynamic Ones
  -- Then Add all other lines in the pegging.
  l_sql_stmt_1 := 'INSERT INTO ' || l_insert_temp_table ||
               '(reference_item_id, inventory_item_id, plan_id, sr_instance_id,
                organization_id, sales_order_line_id,demand_source_type,bom_item_type, --cmro
                transaction_date, demand_id, demand_quantity,
                disposition_id, demand_class, supply_id, supply_quantity,
                allocated_quantity,
                resource_id, department_id, resource_hours, end_date, -- start_date,
                            -- Bug 3443056, 3348095 ATP now tracks end date.
                relief_type, relief_quantity, daily_relief_qty,
                pegging_id, prev_pegging_id, end_pegging_id, end_demand_id,
                created_by, creation_date, last_updated_by, last_update_date,
                customer_id, customer_site_id)
         SELECT :l_reference_item_id , NVL(DEST_INV_ITEM_ID, INVENTORY_ITEM_ID),
                identifier2 plan_id, identifier1 sr_instance_id,
                NVL(RECEIVING_ORGANIZATION_ID, organization_id),
                NVL(:p_config_order_line_id, :p_model_order_line_id) sales_order_line_id,
                :p_demand_source_type, --cmro
                --3328421
                --NULL bom_item_type, NVL(required_date, supply_demand_date) transaction_date,
                NULL bom_item_type, NVL(actual_supply_demand_date, supply_demand_date) transaction_date,
                -- identifier3 contains the demand_id
                -- supply_demand_quantity contains the demand_quantity
                DECODE (pegging_type, :l_peg_type1,
                         identifier3, NULL) demand_id,
                DECODE (pegging_type, :l_peg_type2,
                         supply_demand_quantity, NULL) supply_demand_quantity,
                NULL disposition_id, demand_class,
                -- identifier3 contains the transaction_id
                -- supply_demand_quantity contains the supply_quantitiy
                -- For ATP created pegging the allocated_qty is the same as supply_qty
                DECODE (pegging_type,
                         :l_peg_type3, identifier3,
                         :l_peg_type4, identifier3,
                         :l_peg_type5, identifier3,
                         :l_peg_type6, identifier3, -- REQ
                          NULL) supply_id,
                DECODE (pegging_type,
                         :l_peg_type7, supply_demand_quantity,
                         :l_peg_type8, supply_demand_quantity,
                         :l_peg_type9, supply_demand_quantity,
                          NULL) supply_quantity,
                DECODE (pegging_type,
                         :l_peg_type10, supply_demand_quantity,
                         :l_peg_type11, supply_demand_quantity,
                         :l_peg_type12, supply_demand_quantity,
                          NULL) allocated_quantity,
                resource_id, department_id,
                DECODE (pegging_type,
                         :l_peg_type13, supply_demand_quantity,
                         NULL) resource_hours,
                --bug 3328421
                --NVL(required_date, supply_demand_date) start_date,
                NVL(actual_supply_demand_date, supply_demand_date) end_date, -- start_date,
                            -- Bug 3443056, 3348095 ATP now tracks end date.
                DECODE (pegging_type,
                        :l_peg_type14,
                          decode(pegging_id, end_pegging_id, 1, :l_dmd_offset_typ),
                           -- pegging_id is same as end_pegging_id then SO
                           -- otherwise POD
                         :l_peg_type15, :l_sup_offset_typ,      -- PO
                         :l_peg_type16, :l_sup_offset_typ,  -- PO
                         :l_peg_type17, 4 , -- REQ
                         :l_peg_type18, :l_sup_offset_typ )
                          relief_type,
                decode(pegging_id, end_pegging_id, 0,
                      -1 *  supply_demand_quantity ) relief_quantity,
                NULL daily_relief_qty,
                pegging_id, parent_pegging_id, end_pegging_id, :l_end_demand_id,
                created_by, creation_date, last_updated_by, last_update_date,
                customer_id, customer_site_id
         FROM   mrp_atp_details_temp
         WHERE  pegging_id <> :p_identifier
         AND    record_type in (3, 4)
         and    session_id = :l_session_id
         and    model_sd_flag = 1  -- ensure that we only obtain pegging for things in the order.
         -- Bug 3334643 Ensure that line is a PDS line.
         and    identifier2 > 0
         START  WITH pegging_id = :p_identifier
         AND    session_id = :l_session_id
         AND    record_type = 3
         CONNECT BY parent_pegging_id = prior pegging_id
         AND    session_id = prior session_id
         AND    record_type in (3,4)';

  IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Create_Atp_Pegging:  Insert SQL Statement '||
                               l_sql_stmt_1);
  END IF;

    EXECUTE IMMEDIATE l_sql_stmt_1 USING
           l_reference_item_id,
           p_config_order_line_id,
           p_model_order_line_id,
           p_demand_source_type,
           MSC_ATP_PVT.ORG_DEMAND,
           MSC_ATP_PVT.ORG_DEMAND,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.RESOURCE_DEMAND,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.MAKE_SUPPLY,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           MSC_ATP_PVT.BUY_SUPPLY,
           MSC_ATP_PVT.RESOURCE_DEMAND,
           MSC_ATP_PVT.ORG_DEMAND,
           l_dmd_offset_typ,
           MSC_ATP_PVT.MAKE_SUPPLY,
           l_sup_offset_typ,
           MSC_ATP_PVT.TRANSFER_SUPPLY,
           l_sup_offset_typ,
           MSC_ATP_PVT.RESOURCE_DEMAND,
           MSC_ATP_PVT.BUY_SUPPLY,
           l_sup_offset_typ,
           l_end_demand_id,
           p_identifier,
           MSC_ATP_PVT.G_SESSION_ID,
           p_identifier,
           MSC_ATP_PVT.G_SESSION_ID;
   -- End CTO_PF_PRJ_2 Impacts SQL are changed to Dynamic Ones

  IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Create_Atp_Pegging:  Number of rows inserted '||
                               SQL%ROWCOUNT);
  END IF;

  -- CTO_PF_PRJ Impacts
  IF (MSC_ATP_PVT.G_CTO_PF_ATP = 'Y') THEN
      -- Call Procedure to insert data from temp table to main table
      -- For PF items, PF related processing will be done.
      Create_PF_Atp_Pegging ( l_reference_item_id   ,
                              p_model_order_line_id ,
                              p_config_order_line_id,
                              p_demand_source_type  ,
                              l_end_demand_id       ,
                              l_plan_id             ,
                              x_return_status        );
  END IF;
  -- CTO_PF_PRJ Impacts

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('***** End Create_Atp_Pegging Procedure *****');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        my_sqlcode := SQLCODE;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Create_Atp_Pegging: ' || my_sqlcode ||
                ' error encountered while creating ATP Pegging : ERROR =  '|| sqlerrm);
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME , 'Create_Atp_Pegging');
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Atp_Pegging;

END MSC_ATP_PEG;

/
