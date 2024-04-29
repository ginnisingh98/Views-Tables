--------------------------------------------------------
--  DDL for Package MSC_ATP_SUBST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_SUBST" AUTHID CURRENT_USER AS
/* $Header: MSCSUBAS.pls 120.2 2007/12/12 10:40:33 sbnaik ship $  */

--- new data types
-- holds org and item/org specific information
TYPE ATP_Org_Info_Rec_Typ is RECORD (
				Organization_Id		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  --- organizaton_id
                                Parent_Org_Idx          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  ---index for parent org in supply chain
                                Requested_ship_date     MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),    -- requested ship date in org
                                Request_Date_Quantity	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- request date quantity
                                demand_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- demand quantity in the org
                                Demand_Pegging_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- pegging id for demand in current org
                                Supply_pegging_id       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- supply pegging id
                                PO_pegging_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- peggeing id for PO in parent Org
                                Demand_ID               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),  -- demand id in msc_demand table
                                org_code                MRP_ATP_PUB.char7_arr := MRP_ATP_PUB.char7_arr(),
               	                Lead_time               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                Quantity_from_children 	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                atp_flag                MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
                                atp_comp_flag           MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
                                post_pro_lt             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                plan_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                assign_set_id           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                location_id             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                demand_class            MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
                                steal_qty               MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),

				-- dsting diagnostic atp
				fixed_lt		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				variable_lt		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				pre_pro_lt		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				ship_method		MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
				plan_name		MRP_ATP_PUB.char10_arr := MRP_ATP_PUB.char10_arr(),
				rounding_flag		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				unit_weight		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				weight_uom		MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
				unit_volume		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				volume_uom		MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
				ptf_date		MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
				substitution_window	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				allocation_rule		MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
				infinite_time_fence	MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
				atp_rule_name		MRP_ATP_PUB.char80_arr := MRP_ATP_PUB.char80_arr(),
				constraint_type		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				constraint_date		MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                -- dsting 2754446
                                conversion_rate         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                primary_uom             MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
                                req_date_unadj_qty      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                rnding_leftover         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),

                                -- time_phased_atp
                                Family_sr_id            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                Family_dest_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                Family_item_name        MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
                                Atf_Date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                Atf_Date_Quantity	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),

                                -- ship_rec_cal
                                shipping_cal_code       MRP_ATP_PUB.char14_arr := MRP_ATP_PUB.char14_arr(),
                                receiving_cal_code      MRP_ATP_PUB.char14_arr := MRP_ATP_PUB.char14_arr(),
                                intransit_cal_code      MRP_ATP_PUB.char14_arr := MRP_ATP_PUB.char14_arr(),
                                manufacturing_cal_code  MRP_ATP_PUB.char14_arr := MRP_ATP_PUB.char14_arr(),
                                new_ship_date           MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                new_dock_date           MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                new_start_date          MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),   -- Bug 3241766
                                new_order_date          MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr()    -- Bug 3241766
                               );

Type Item_Info_Rec_Typ is Record( inventory_item_id             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  sr_inventory_item_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  highest_revision_item_id      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  item_name                     MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
                                  End_pegging_id                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  request_date_quantity         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  partial_fulfillment_flag      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  period_detail_begin_idx       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  period_detail_end_idx	        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  sd_detail_begin_idx           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  sd_detail_end_idx             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  CTP_PRD_DETL_BEGIN_IDX        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  CTP_PRD_DETL_END_IDX          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  CTP_SD_DETL_BEGIN_IDX         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  CTP_SD_DETL_END_IDX           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_CTP_PRD_DETL_BEGIN_IDX    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_CTP_PRD_DETL_END_IDX      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_CTP_SD_DETL_BEGIN_IDX     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_CTP_SD_DETL_END_IDX       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  atp_flag                      MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
                                  atp_comp_flag                 MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
                                  pre_pro_lt                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  post_pro_lt                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  fixed_lt                      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  variable_lt                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  create_supply_flag            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  substitution_window           MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  plan_id                       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  ASSIGN_SET_ID                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  future_atp_date               MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                  atp_date_quantity             MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  demand_id                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_ATP_PRD_DETL_BEGIN_IDX    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_ATP_PRD_DETL_END_IDX      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_ATP_SD_DETL_BEGIN_IDX     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  FUT_ATP_SD_DETL_END_IDX       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  future_supply_peg_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  demand_class                  MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
                                  ---forward steal
                                  fwd_steal_peg_begin_idx       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  fwd_steal_peg_end_idx         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),

				  -- dsting diagnostic atp
				  rounding_control_type	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				  unit_weight		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				  weight_uom		MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
				  unit_volume		MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
				  volume_uom		MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
				  plan_name		MRP_ATP_PUB.char10_arr := MRP_ATP_PUB.char10_arr(),

                                  -- time_phased_atp
                                  Family_sr_id            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  Family_dest_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  Family_item_name        MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
                                  Atf_Date                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
                                  Atf_Date_Quantity	  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
                                  used_available_quantity  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr() --bug3467631 New_time_phase_logic
                                  );

--G_Org_Availability_Info ATP_Info_Details_Rec_Typ;
--Item_Availability_Info Item_Info_Rec_Typ;

G_TOP_LAST_PO_PEGGING 	NUMBER;
G_TOP_LAST_PO_QTY	NUMBER;

---Constants
ALL_OR_NOTHING  CONSTANT INTEGER := 1;
MIXED           CONSTANT INTEGER := 2;
ITEM_ATTRIBUTE  CONSTANT INTEGER := 3;
NO_SUBSTITUTION CONSTANT INTEGER := 4;
G_FUTURE_PEGGING_ID      NUMBER;
--- default to demanded item if this profile option is not set
G_CREATE_SUPPLY_FLAG NUMBER := NVL( FND_PROFILE.value('MSC_ITEM_CHOICE_FOR_SUBSTITUTE'), 701);

G_REQ_ITEM_SR_INV_ID    NUMBER;

G_DEMANDED_ITEM CONSTANT INTEGER := 701;
G_HIGHEST_REV_ITEM CONSTANT INTEGER := 702;
G_ITEM_ATTRIBUTE   CONSTANT INTEGER := 703;

PROCEDURE Extend_Org_Avail_Info_Rec (
  p_org_avail_info         IN OUT NOCOPY  MSC_ATP_SUBST.ATP_Org_Info_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2);

Procedure Extend_Item_Info_Rec_Typ(
  p_item_avail_info        IN OUT NOCOPY  MSC_ATP_SUBST.Item_Info_Rec_Typ,
  x_return_status          OUT      NoCopy VARCHAR2);

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
);

Procedure Get_Item_Substitutes(p_inventory_item_id IN       NUMBER,
                               p_item_table        IN OUT   NoCopy MSC_ATP_SUBST.Item_Info_Rec_Typ,
                               p_instance_id       IN       NUMBER,
                               p_plan_id           IN       NUMBER,
                               p_customer_id       IN       NUMBER,
                               p_customer_site_id  IN       NUMBER,
                               p_request_date      IN       DATE,
                               p_organization_id   IN       NUMBER);

Procedure Update_demand(p_demand_id             number,
                        p_plan_id               number,
                        p_quantity              number);

Procedure Delete_demand_subst(p_demand_id number,
                              p_plan_id   number);

PROCEDURE Add_Pegging(
  p_pegging_rec          IN         mrp_atp_details_temp%ROWTYPE
);

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
);

Procedure Copy_Item_Info_Rec(p_parent_item_info       IN     MSC_ATP_SUBST.Item_Info_Rec_Typ,
                             p_child_item_info         IN OUT NoCopy MSC_ATP_SUBST.Item_Info_Rec_Typ,
                             p_index                  IN     NUMBER);
/* time_phased_atp
PROCEDURE Add_Mat_Demand(
  p_atp_rec          IN         MRP_ATP_PVT.AtpRec ,
  p_plan_id          IN         NUMBER ,
  p_dc_flag          IN         NUMBER,
  x_demand_id        OUT        NoCopy NUMBER
);
*/

END MSC_ATP_SUBST;

/
