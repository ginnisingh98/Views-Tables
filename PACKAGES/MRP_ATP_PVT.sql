--------------------------------------------------------
--  DDL for Package MRP_ATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_ATP_PVT" AUTHID CURRENT_USER AS
/* $Header: MRPGATPS.pls 120.6 2006/04/28 04:24:33 anbansal noship $  */

INFINITE_NUMBER         CONSTANT NUMBER := 1.0e+10;

TYPE Atp_Source_Typ is RECORD (
Organization_Id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Instance_Id			MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Supplier_Id                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Supplier_Site_Id                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Rank			        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Source_Type                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Lead_Time                       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
Ship_Method                     MRP_ATP_PUB.char30_arr := MRP_ATP_PUB.char30_arr(),
Preferred                       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
make_flag                       MRP_ATP_PUB.char1_arr := MRP_ATP_PUB.char1_arr(),
-- ship_rec_cal
Sup_Cap_Type                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
);

TYPE AtpRec is RECORD (
instance_id		NUMBER,
identifier              NUMBER,
demand_source_line	VARCHAR2(30),
demand_source_header_id NUMBER,
demand_source_delivery  VARCHAR2(30),
demand_source_type      NUMBER,
inventory_item_id	NUMBER,
request_item_id		NUMBER,
customer_id		NUMBER,
organization_id		NUMBER,
supplier_id		NUMBER,
supplier_site_id	NUMBER,
quantity_ordered	NUMBER,
quantity_uom		VARCHAR2(3),
requested_ship_date	DATE,
requested_arrival_date	DATE,
latest_acceptable_date	DATE,
delivery_lead_time	NUMBER,
freight_carrier		VARCHAR2(30),
ship_method		VARCHAR2(30),
demand_class		VARCHAR2(200),
override_flag		VARCHAR2(1),
ship_date		DATE,
Arrival_date		DATE,
available_quantity	NUMBER,
requested_date_quantity NUMBER,
action			NUMBER,
insert_flag		NUMBER,
to_location_id          NUMBER,
to_organization_id      NUMBER,
to_instance_id		NUMBER,
error_code		NUMBER,
refresh_number          NUMBER,
atp_lead_time		NUMBER,
origination_type        NUMBER,
order_number            NUMBER,
combined_requested_date_qty NUMBER,
calling_module		NUMBER,
component_identifier    NUMBER,
stolen_flag             VARCHAR2(1),
--subst
substitution_type       NUMBER,
req_item_detail_flag    NUMBER,
req_item_req_date_qty   NUMBER,
req_item_available_date DATE,
req_item_available_date_qty NUMBER,
request_item_name       VARCHAR2(40),  -- Rewind to 40 Bug 2408159
inventory_item_name     VARCHAR2(40),  -- Rewind to 40 Bug 2408159
original_item_flag      NUMBER,
top_tier_org_flag       NUMBER,
substitution_window     NUMBER,
old_demand_id           NUMBER,
--diag_atp
plan_name               VARCHAR2(80),
reverse_cumulative_yield number,
children_type		NUMBER,
-- 2462661 -- atp flag value from MSC_BOM_TEMP passsed by CTO
src_atp_flag            VARCHAR2(1),
--s_cto_rearch
Top_Model_line_id       NUMBER,
ATO_Parent_Model_Line_Id       NUMBER,
ATO_Model_Line_Id       NUMBER,
Parent_line_id          NUMBER,
wip_supply_type         NUMBER,
parent_atp_flag         varchar2(1),
parent_atp_comp_flag    varchar2(1),
parent_repl_order_flag  varchar2(1),
parent_bom_item_type   number,
parent_item_id         number,
base_model_id           number,
bom_item_type           number,
rep_ord_flag            varchar2(1),
mand_comp_flag          number,
parent_so_quantity      number,
--e_cto_rearch
-- time_phased_atp
atf_date                DATE,
atf_date_quantity       NUMBER,
original_item_id        NUMBER,
original_item_name      VARCHAR2(40),
used_available_quantity NUMBER, --bug3409973
--plan by request
original_request_ship_date DATE,
original_request_date 	DATE,
ship_set_name		varchar2(30),
arrival_set_name	varchar2(30),
-- ship_rec_cal
receiving_cal_code      VARCHAR2(14),
intransit_cal_code      VARCHAR2(14),
shipping_cal_code       VARCHAR2(14),
manufacturing_cal_code  VARCHAR2(14),
session_id              number,
last_cap_date           Date,    -- Enforce Pur LT
OE_Flag                 varchar2(1),--
internal_org_id         number, --3409286
--4570421
scaling_type            number,
scale_multiple          number,
scale_rounding_variance number,
rounding_direction      number,
component_yield_factor  number, --4570421
usage_qty               number, --4775920
organization_type       number, --4775920
bill_seq_id             number, --4741012
subs_demand_id          number  --5088719
);



TYPE Atp_Res_Typ is RECORD (
department_id                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
owning_department_id          MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
resource_id                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
basis_type                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
resource_usage                MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
requested_date		      MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
lead_time                     MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
efficiency                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
utilization                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
batch_flag                    MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
max_capacity                  MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
required_unit_capacity        MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
required_capacity_uom         MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
res_uom 		      MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(),
res_uom_type		      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
std_op_code                   MRP_ATP_PUB.char7_arr := MRP_ATP_PUB.char7_arr(),
resource_offset_percent       MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
operation_sequence            MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
actual_resource_usage         MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
reverse_cumulative_yield      MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
department_code               MRP_ATP_PUB.char10_arr := MRP_ATP_PUB.char10_arr(),
resource_code                 MRP_ATP_PUB.char16_arr := MRP_ATP_PUB.char16_arr()--4774169


);

TYPE Atp_Comp_Typ is RECORD (
inventory_item_id             MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
comp_usage                    MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
requested_date                MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr(),
lead_time                     MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
wip_supply_type               MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
assembly_identifier           MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
component_identifier          MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
pre_process_lead_time         MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
--diag_atp
reverse_cumulative_yield      MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
-- 2462661 -- atp flag value from MSC_BOM_TEMP passsed by CTO
src_atp_flag                  MRP_ATP_PUB.char1_arr:=MRP_ATP_PUB.char1_arr(),
--s_cto_rearch
match_item_id                 MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
bom_item_type                 MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
parent_line_id                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
top_model_line_id             MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
ato_parent_model_line_id      MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
ato_model_line_id             MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
MAND_COMP_FLAG                 MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
parent_so_quantity            MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
fixed_lt                      MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
variable_lt                   MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
oss_error_code                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
atp_flag                      MRP_ATP_PUB.char1_arr:= MRP_ATP_PUB.char1_arr(),
atp_components_flag                      MRP_ATP_PUB.char1_arr:= MRP_ATP_PUB.char1_arr(),
-- time_phased_atp
request_item_id               MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
atf_date                      MRP_ATP_PUB.date_arr:=MRP_ATP_PUB.date_arr(),
match_item_family_id          MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
dest_inventory_item_id        MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
parent_item_id                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
comp_uom                      MRP_ATP_PUB.char3_arr := MRP_ATP_PUB.char3_arr(), --bug3110023
--4570421
scaling_type                  MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
scale_multiple                MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
scale_rounding_variance       MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
rounding_direction            MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(),
component_yield_factor        MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(), --4570421
usage_qty                     MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr(), --4775920
organization_type             MRP_ATP_PUB.number_arr:=MRP_ATP_PUB.number_arr()  --4775920
);

TYPE ATP_COMP_REC IS RECORD
(
inventory_item_id             number,
comp_usage                    number,
requested_date                date,
lead_time                     number,
wip_supply_type               number,
assembly_identifier           number,
component_identifier          number,
--diag_atp
reverse_cumulative_yield      number,
--s_cto_rearch
match_item_id                 number,
bom_item_type                 number,
parent_line_id                number,
top_model_line_id             number,
ato_parent_model_line_id      number,
ato_model_line_id             number,
MAND_COMP_FLAG                number,
parent_so_quantity            number,
fixed_lt                      number,
variable_lt                   number,
oss_error_code                number,
model_flag                    number,
requested_quantity            number,
atp_flag                      varchar2(1),
atp_components_flag           varchar2(1),
-- time_phased_atp
request_item_id               number,
atf_date                      date,
match_item_family_id          number,
dest_inventory_item_id        number,
parent_repl_ord_flag          varchar2(1),
comp_uom                      varchar2(3), --bug3110023
--4570421
scaling_type                  number,
scale_multiple                number,
scale_rounding_variance       number,
rounding_direction            number,
component_yield_factor        number, --4570421
usage_qty                     NUMBER, --4775920
organization_type             NUMBER  --4775920
);



TYPE SourceCurTyp IS REF CURSOR;

TYPE Atp_Info is RECORD (
atp_period                MRP_ATP_PUB.date_arr := MRP_ATP_PUB.date_arr(),
atp_qty                   MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(),
limit_qty                 MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr()
);


PROCEDURE Extend_Atp (
  p_atp_tab             IN OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
);


PROCEDURE Assign_Atp_Input_Rec (
  p_atp_table           IN       MRP_ATP_PUB.ATP_Rec_Typ,
  p_index               IN       NUMBER,
  x_atp_table           IN OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
);

PROCEDURE Assign_Atp_Output_Rec (
  p_atp_table           IN       MRP_ATP_PUB.ATP_Rec_Typ,
  x_atp_table           IN OUT   NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
  x_return_status       OUT      NoCopy VARCHAR2
);


END MRP_ATP_PVT;

 

/
