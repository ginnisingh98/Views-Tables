--------------------------------------------------------
--  DDL for Package MSC_ATP_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_REQ" AUTHID CURRENT_USER AS
/* $Header: MSCRATPS.pls 120.5 2007/12/12 10:39:02 sbnaik ship $  */

TYPE get_mat_in_rec IS RECORD(
           rounding_control_flag  number,
           dest_inv_item_id       number,
           infinite_time_fence_date date,
           plan_name                varchar2(10),
           optimized_plan         number, -- 2859130
           parent_bom_item_type   number,
           bom_item_type          number,
           replenish_to_ord_flag  varchar2(1),
           parent_repl_order_flag varchar2(1),
           ato_model_line_id      number,
           shipping_cal_code      VARCHAR2(14),  -- Bug 3371817
           sys_next_osc_date       date,  --bug3333114
           receiving_cal_code      VARCHAR2(14),  -- Bug 3826234
           intransit_cal_code      VARCHAR2(14),  -- Bug 3826234
           manufacturing_cal_code  VARCHAR2(14),  -- Bug 3826234
           to_organization_id      NUMBER,        -- Bug 3826234
           organization_id         NUMBER         -- Bug 3826234
);

TYPE get_mat_out_rec IS RECORD(
           atp_rule_name             varchar2(80),
           infinite_time_fence_date  date,
           demand_pegging_id         number,
            --3432341
           demand_id                 number);

TYPE GET_COMP_INFO_REC IS  RECORD(
           line_id                  number,
           bom_item_type            number,
           atp_flag                 varchar2(1),
           atp_comp_flag            varchar2(1),
           fixed_lt                 number,
           variable_lt              number,
           replenish_to_order_flag  varchar2(1),
           TOP_MODEL_LINE_ID        number,
           ATO_MODEL_LINE_ID        number,
           ATO_PARENT_MODEL_LINE_ID number,
           PARENT_LINE_ID           number,
           parent_so_quantity       number,
           check_model_capacity_flag number,
           model_sr_inv_item_id          number,
           --bug3059305
           ship_date_this_level     date
                                 );

-- New record Atp_Info_Rec defined for time_phased_atp and ship_rec_cal
TYPE Atp_Info_Rec is RECORD (
        instance_id                     NUMBER,
        plan_id                         NUMBER,
        level                           NUMBER,
        identifier                      NUMBER,
        scenario_id                     NUMBER,
        inventory_item_id               NUMBER,
        request_item_id                 NUMBER,
        organization_id                 NUMBER,
        supplier_id                     NUMBER,
        supplier_site_id                NUMBER,
        requested_date                  DATE,
        atf_date                        DATE,
        quantity_ordered                NUMBER,
        demand_class                    VARCHAR2(200),
        insert_flag                     NUMBER,
        substitution_window             NUMBER,
        requested_date_quantity         NUMBER,
        atf_date_quantity               NUMBER,
        atp_date_this_level             DATE,
        atp_date_quantity_this_level    NUMBER,
        rounding_control_flag           NUMBER,
        dest_inv_item_id                NUMBER,
        infinite_time_fence_date        DATE,
        plan_name                       VARCHAR2(10),
        optimized_plan                  NUMBER,
        atp_rule_name                   VARCHAR2(80),
        shipping_cal_code               VARCHAR2(30),
        receiving_cal_code              VARCHAR2(30),
        manufacturing_cal_code          VARCHAR2(30),
        intransit_cal_code              VARCHAR2(30),
        refresh_number                  NUMBER,          -- For summary enhancement
        sup_cap_cum_date                DATE,            -- SCLT Accumulation starts from this date
        sysdate_seq_num                 NUMBER,          -- For ship_rec_cal
        sup_cap_type                    NUMBER,          -- For ship_rec_cal, value =1 means ship, 2 means dock
        base_item_id                    NUMBER,          -- For CTO rearch
        bom_item_type                   NUMBER,          -- For CTO rearch
        rep_ord_flag                    VARCHAR2(1),     -- For CTO rearch
        last_cap_date                   DATE,             -- Enforce Pur LT
        --4570421
        scaling_type            number,
        scale_multiple          number,
        scale_rounding_variance number,
        rounding_direction      number,
        component_yield_factor  number, --4570421
        usage_qty               NUMBER, --4775920
        organization_type       NUMBER --4775920
);

--5216528/5216528 Start This record will out teh values from check_subs
--5081149 Initializing the collections
TYPE get_subs_out_rec IS RECORD(
           pegging_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
           inventory_item_id   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
           sub_atp_qty         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
           demand_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
           pf_item_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(), --5283809
           atf_date_quantity   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
           quantity_ordered    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
                                );
--5216528/5216528 End
PROCEDURE Check_Substitutes(
  p_atp_record        IN OUT NoCopy MRP_ATP_PVT.AtpRec,
  p_parent_pegging_id IN     NUMBER,
  p_instance_id       IN     NUMBER,
  p_scenario_id       IN     NUMBER,
  p_level             IN     NUMBER,
  p_search            IN     NUMBER,
  p_plan_id           IN     NUMBER,
  p_inventory_item_id IN     NUMBER,
  p_organization_id   IN     NUMBER,
  p_quantity          IN     NUMBER,
  l_net_demand        IN OUT NoCopy NUMBER,
  l_supply_demand     IN OUT NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  l_atp_period        IN OUT NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  l_substitutes_rec   OUT    NoCopy MSC_ATP_REQ.get_subs_out_rec, --5216528/5216528
  l_return_status     OUT    NoCopy varchar2,
  p_refresh_number    IN     NUMBER -- For summary enhancement
);


/* time_phased_atp
   Grouped various input parameters to this procedure in a new record Atp_Info_Rec*/
PROCEDURE Get_Material_Atp_Info (
  p_mat_atp_info_rec        IN OUT      NOCOPY Atp_Info_Rec,
  x_atp_period              OUT         NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand       OUT         NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status           OUT         NoCopy VARCHAR2
);


PROCEDURE Insert_Details (
  p_instance_id 	IN    NUMBER,
  p_plan_id             IN    NUMBER,
  p_level		IN    NUMBER,
  p_identifier          IN    NUMBER,
  p_scenario_id		IN    NUMBER,
  p_request_item_id	IN    NUMBER,
  p_inventory_item_id	IN    NUMBER,
  p_organization_id     IN    NUMBER,
  p_demand_class        IN    VARCHAR2,
  p_insert_flag         IN    NUMBER,
  x_atp_period          OUT   NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand   OUT   NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status       OUT   NoCopy VARCHAR2,
  p_get_mat_in_rec      IN    MSC_ATP_REQ.get_mat_in_rec,
  p_atf_date            IN    DATE      -- For time_phased_atp
);


PROCEDURE Get_Res_Requirements (
    p_instance_id           IN  NUMBER,
    p_plan_id               IN  NUMBER,
    p_level                 IN  NUMBER,
    p_scenario_id           IN  NUMBER,
    p_inventory_item_id     IN  NUMBER,
    p_organization_id       IN  NUMBER,
    p_parent_pegging_id     IN  NUMBER,
    p_requested_quantity    IN  NUMBER,
    p_requested_date        IN  DATE,
    p_refresh_number        IN  NUMBER,
    p_insert_flag           IN  NUMBER,
    p_search                IN  NUMBER,
    p_demand_class          IN  VARCHAR2,
    --(ssurendr) Bug 2865389 Added Routing Sequence id and bill sequence id for OPM issue
    p_routing_seq_id        IN  NUMBER,
    p_bill_seq_id           IN  NUMBER,
    p_parent_ship_date      IN  DATE,       -- Bug 2814872 Cut-off Date for Resource Check
    p_line_identifier       IN  NUMBER,     -- CTO ODR  Identifies the line being processed.
    x_avail_assembly_qty    OUT NoCopy NUMBER,
    x_atp_date              OUT NoCopy DATE,
    x_atp_period            OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
    x_atp_supply_demand     OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
    x_return_status         OUT NoCopy VARCHAR2
);

PROCEDURE Get_Comp_Requirements (
  p_instance_id                         IN    NUMBER,
  p_plan_id                             IN    NUMBER,
  p_level                               IN    NUMBER,
  p_scenario_id                         IN    NUMBER,
  p_inventory_item_id                   IN    NUMBER,
  p_organization_id                     IN    NUMBER,
  p_parent_pegging_id                   IN    NUMBER,
  p_demand_class                        IN    VARCHAR2,
  p_requested_quantity                  IN    NUMBER,
  p_requested_date                      IN    DATE,
  p_refresh_number                      IN    NUMBER,
  p_insert_flag                         IN    NUMBER,
  p_search                              IN    NUMBER,
  p_assign_set_id			IN    NUMBER,
  --(ssurendr) Bug 2865389 Added Routing Sequence id and bill sequence id for OPM issue
  p_routing_seq_id                      IN    NUMBER, --Bug2745055
  p_bill_seq_id                         IN    NUMBER,
  p_family_id                           IN    NUMBER,   -- For time_phased_atp
  p_atf_date                            IN    DATE,     -- For time_phased_atp
  p_manufacturing_cal_code              IN    VARCHAR2, -- For ship_rec_cal
  x_avail_assembly_qty                  OUT   NoCopy NUMBER,
  x_atp_date                            OUT   NoCopy DATE,
  x_atp_period                          OUT NOCOPY MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT   NoCopy VARCHAR2,
  p_comp_info_rec                       IN OUT NOCOPY MSC_ATP_REQ.get_comp_info_rec,
  p_order_number                        IN    NUMBER := NULL,
  p_op_seq_id                           IN    NUMBER --4570421
        -- Add new parameter with default value to support creation of
        -- Sales Orders for CTO components in a MATO case.
);


PROCEDURE Get_Supplier_Atp_Info (
  p_sup_atp_info_rec                    IN OUT  NOCOPY  MSC_ATP_REQ.Atp_Info_Rec,
  x_atp_period                          OUT     NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT     NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT     NOCOPY  VARCHAR2
);


PROCEDURE Get_Transport_Cap_Atp_Info (
  p_plan_id                             IN    NUMBER,
  p_from_organization_id                IN    NUMBER,
  p_to_organization_id                  IN    NUMBER,
  p_ship_method                         IN    VARCHAR2,
  p_inventory_item_id                   IN    NUMBER,
  p_source_org_instance_id              IN    NUMBER,
  p_dest_org_instance_id                IN    NUMBER,
  p_requested_date                      IN    DATE,
  p_quantity_ordered                    IN    NUMBER,
  p_insert_flag                         IN    NUMBER,
  p_level                               IN    NUMBER,
  p_scenario_id                         IN    NUMBER,
  p_identifier                          IN    NUMBER,
  p_parent_pegging_id                   IN    NUMBER,
  x_requested_date_quantity             OUT   NoCopy NUMBER,
  x_atp_date_this_level                 OUT   NoCopy DATE,
  x_atp_date_quantity_this_level        OUT   NoCopy NUMBER,
  x_atp_period                          OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
  x_atp_supply_demand                   OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
  x_return_status                       OUT   NoCopy VARCHAR2
);

--supplier_capacity changes
G_PURCHASE_ORDER_PREFERENCE             NUMBER;
G_PROMISE_DATE                          CONSTANT NUMBER := 1;


--s_cto_rearch
procedure Extend_Atp_Comp_Typ ( P_Atp_Comp_Typ IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ);

Procedure Add_To_Comp_List(p_explode_comp_rec          IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                           p_component_rec             IN OUT NOCOPY MRP_ATP_PVT.Atp_Comp_Typ,
                           p_atp_comp_rec              IN MRP_ATP_PVT.ATP_COMP_REC);

--e_cto_rearch


END MSC_ATP_REQ;

/
