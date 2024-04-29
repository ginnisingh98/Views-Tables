--------------------------------------------------------
--  DDL for Package MSC_ATP_DB_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_DB_UTILS" AUTHID CURRENT_USER AS
/* $Header: MSCDATPS.pls 120.2.12010000.3 2009/08/24 06:46:01 sbnaik ship $  */


SYS_YES                      CONSTANT NUMBER := 1;
SYS_NO                       CONSTANT NUMBER := 2;
REQUEST_MODE                 CONSTANT NUMBER := 1;
RESULTS_MODE                 CONSTANT NUMBER := 2;


--bug 3766179
TYPE Supply_Rec_Typ is RECORD (
        instance_id                NUMBER,
        plan_id                    NUMBER,
        inventory_item_id          NUMBER,
        organization_id            NUMBER,
        schedule_date              DATE,
        order_quantity             NUMBER,
        supplier_id                NUMBER,
        supplier_site_id           NUMBER,
        demand_class               VARCHAR2(80),
        source_organization_id     NUMBER,
        source_sr_instance_id      NUMBER,
        process_seq_id             NUMBER,
        refresh_number             VARCHAR2(80),
        shipping_cal_code          VARCHAR2(20), -- For ship_rec_cal
        receiving_cal_code         VARCHAR2(20), -- For ship_rec_cal
        intransit_cal_code         VARCHAR2(20), -- For ship_rec_cal
        new_ship_date              DATE,     -- For ship_rec_cal
        new_dock_date              DATE,     -- For ship_rec_cal
        start_date                 DATE,     -- Bug 3241766
        order_date                 DATE,     -- Bug 3241766
        ship_method                VARCHAR2(30), -- For ship_rec_cal
        transaction_id             NUMBER,
        return_status              VARCHAR2(10),
        request_item_id            NUMBER,
        atf_date                   DATE,
        Supply_type                Number,
        disposition_status_type    Number,
        firm_planned_type          Number,
        record_source              Number,
        disposition_id             Number,
        intransit_lead_time        NUMBER --4127630

       );


PROCEDURE Add_Mat_Demand(
        p_atp_rec                       IN      MRP_ATP_PVT.AtpRec,
        p_plan_id                       IN      NUMBER,
        p_dc_flag			IN 	NUMBER,
        x_demand_id                     OUT     NoCopy NUMBER
);


PROCEDURE Add_Pegging(
        p_pegging_rec                   IN      mrp_atp_details_temp%ROWTYPE,
        x_pegging_id                    OUT     NoCopy number
);


PROCEDURE Add_Planned_Order(
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_inventory_item_id             IN      NUMBER,
        p_organization_id               IN      NUMBER,
        p_schedule_date                 IN      DATE,
        p_order_quantity                IN      NUMBER,
        p_supplier_id                   IN      NUMBER,
        p_supplier_site_id              IN      NUMBER,
        p_demand_class                  IN      VARCHAR2,
        -- rajjain 02/19/2003 Bug 2788302 Begin
        p_source_organization_id        IN      NUMBER,
        p_source_sr_instance_id         IN      NUMBER,
        p_process_seq_id                IN      NUMBER,
        -- rajjain 02/19/2003 Bug 2788302 End
        p_refresh_number                IN      VARCHAR2, -- for summary enhancement
        p_shipping_cal_code             IN      VARCHAR2, -- For ship_rec_cal
        p_receiving_cal_code            IN      VARCHAR2, -- For ship_rec_cal
        p_intransit_cal_code            IN      VARCHAR2, -- For ship_rec_cal
        p_new_ship_date                 IN      DATE,     -- For ship_rec_cal
        p_new_dock_date                 IN      DATE,     -- For ship_rec_cal
        p_start_date                    IN      DATE,     -- Bug 3241766
        p_order_date                    IN      DATE,     -- Bug 3241766
        p_ship_method                   IN      VARCHAR2, -- For ship_rec_cal
        x_transaction_id                OUT     NoCopy NUMBER,
        x_return_status                 OUT     NoCopy VARCHAR2,
        p_intransit_lead_time           IN      NUMBER, --4127630
        p_request_item_id               IN      NUMBER := NULL, -- for time_phased_atp
        p_atf_date                      IN      DATE := NULL -- for time_phased_atp

);


PROCEDURE Add_Resource_Demand(
        p_instance_id                   IN  NUMBER,
        p_plan_id                       IN  NUMBER,
        p_supply_id                     IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_resource_id                   IN  NUMBER,
        p_department_id                 IN  NUMBER,
        -- Bug 3348095
        -- Now both start and end dates will be stored for
        -- ATP created resource requirements.
        p_start_date                    IN  DATE,
        p_end_date                      IN  DATE,
        -- End Bug 3348095
        p_resource_hours                IN  NUMBER,
        p_unadj_resource_hours     IN  NUMBER, --5093604
        p_touch_time                    IN  NUMBER, --5093604
        p_std_op_code                   IN  VARCHAR2,
        p_resource_cap_hrs              IN  NUMBER,
        p_item_id                       IN  NUMBER,   -- Need to store assembly_item_id CTO ODR
        p_basis_type                    IN  NUMBER,   -- Need to store basis_type CTO ODR
        p_op_seq_num                    IN  NUMBER,   -- Need to store op_seq_num CTO ODR
        p_refresh_number                IN  VARCHAR2, -- for summary enhancement
        x_transaction_id                OUT NoCopy NUMBER,
        x_return_status                 OUT NoCopy VARCHAR2
);


PROCEDURE Delete_Pegging(
        p_pegging_id                    IN      number
);


PROCEDURE Delete_Row(
        p_identifier                    IN      NUMBER,
	p_config_line_id                IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_refresh_number                IN      NUMBER,
                                                -- Bug 2831298 Ensure that the refresh_number is updated
        p_order_number                  IN      NUMBER, -- Bug 2840734 : krajan
        p_time_phased_atp               IN      VARCHAR2,                       -- For time_phased_atp
        p_ato_model_line_id             IN      number,
        p_demand_source_type            IN    Number,  --cmro
        p_source_organization_Id        IN      NUMBER,  --Bug 7118988
        x_demand_id                     OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_inv_item_id                   OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_copy_demand_id                OUT     NoCopy MRP_ATP_PUB.Number_Arr,  -- For summary enhancement
        x_atp_peg_items                 OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_atp_peg_demands               OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_atp_peg_supplies              OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_atp_peg_res_reqs              OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_demand_instance_id            OUT     NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
        x_supply_instance_id            OUT     NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
        x_res_instance_id               OUT     NoCopy MRP_ATP_PUB.Number_Arr, --Bug 3629191
        x_ods_cto_demand_ids            OUT     NoCopy MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        x_ods_cto_inv_item_ids          OUT     NoCopy MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        x_ods_atp_refresh_no            OUT     NoCopy MRP_ATP_PUB.Number_Arr,
        x_ods_cto_atp_refresh_no        OUT     NoCopy MRP_ATP_PUB.Number_Arr
        -- End CTO ODR and Simplified Pegging

);


PROCEDURE Remove_Invalid_SD_Rec(
        p_identifier                    IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_mode                          IN      NUMBER,
        p_dc_flag                       IN      NUMBER,
        x_return_status                 OUT     NoCopy VARCHAR2
);


PROCEDURE Update_Pegging(
        p_pegging_id                    IN      NUMBER,
        p_date                          IN      DATE,
        p_quantity                      IN      NUMBER
);


PROCEDURE Update_Planned_Order(
        p_pegging_id                    IN      NUMBER,
        p_plan_id                       IN      NUMBER,
        p_date                          IN      DATE,
        p_quantity                      IN      NUMBER,
        p_supplier_id                   IN      NUMBER,
        p_supplier_site_id              IN      NUMBER,
        p_dock_date                     IN      Date,
        p_ship_date                     IN      DATE,     -- Bug 3241766
        p_start_date                    IN      DATE,     -- Bug 3241766
        p_order_date                    IN      DATE,     -- Bug 3241766
        p_mem_item_id                   IN      NUMBER,   -- Bug 3293163
        p_pf_item_id                    IN      NUMBER,
        p_mode				IN	NUMBER := MSC_ATP_PVT.UNDO,
        p_uom_conv_rate                 IN      NUMBER := NULL
);


PROCEDURE Update_SD_Date(
        p_identifier                    IN      NUMBER,
        p_instance_id                   IN      NUMBER,
        p_supply_demand_date            IN      DATE,
        p_plan_id                       IN      NUMBER,
        p_supply_demand_qty             IN      NUMBER,
        p_dc_flag			IN      NUMBER,
        p_old_demand_date		IN 	DATE,
        p_old_demand_qty		IN      NUMBER,
        p_dmd_satisfied_date		IN 	DATE, -- bug 2795053-reopen
        p_sd_date_quantity              IN      NUMBER,   -- For time_phased_atp
        p_atf_date                      IN      DATE,     -- For time_phased_atp
        p_atf_date_quantity             IN      NUMBER,   -- For time_phased_atp
        p_sch_arrival_date              IN      DATE,     -- For ship_rec_cal
        p_order_date_type               IN      NUMBER,   -- For ship_rec_cal
        p_lat_date                      IN      DATE,      -- For ship_rec_cal
        p_ship_set_name			IN      VARCHAR2, --plan by request date
        p_arrival_set_name 		IN      VARCHAR2, --plan by request date
        p_override_flag			IN      VARCHAR2, --plan by request date
        p_request_arrival_date		IN      DATE, --plan by request date
        p_bkwd_pass_atf_date_qty         IN      NUMBER,    -- For time_phased_atp bug3397904
        p_atp_rec                       IN      MRP_ATP_PVT.AtpRec := NULL -- For bug 3226083
        );



-- NGOEL 7/26/2001, Bug 1661545, if scheduling was unsuccessful, make sure that old demand record is
-- preserved back, as it was updated to 0 in the begining in case of reschedule in PDS.

-- RAJJAIN 11/01/2002, Now schedule procedure passes reference to del_demand_ids array to this
-- procedure

PROCEDURE Undo_Delete_Row(
        p_identifiers                   IN	MRP_ATP_PUB.Number_Arr,
        p_plan_ids                      IN	MRP_ATP_PUB.Number_Arr,
        p_instance_id                   IN	NUMBER,
        p_del_demand_ids                IN	MRP_ATP_PUB.Number_Arr,
        p_inv_item_ids                  IN	MRP_ATP_PUB.Number_Arr,
        p_copy_demand_ids               IN  MRP_ATP_PUB.Number_Arr, -- For summary enhancement
        p_copy_plan_ids                 IN  MRP_ATP_PUB.Number_Arr, -- For summary enhancement
        p_time_phased_set               IN  VARCHAR2,           -- For time_phased_atp
        -- CTO ODR and Simplified Pegging
        p_del_atp_peg_items             IN  MRP_ATP_PUB.Number_Arr,
        p_del_atp_peg_demands           IN  MRP_ATP_PUB.Number_Arr,
        p_del_atp_peg_supplies          IN  MRP_ATP_PUB.Number_Arr,
        p_del_atp_peg_res_reqs          IN  MRP_ATP_PUB.Number_Arr,
        p_demand_source_type            IN  MRP_ATP_PUB.Number_Arr,  --cmro
        p_atp_peg_demands_plan_ids   IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
        p_atp_peg_supplies_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
        p_atp_peg_res_reqs_plan_ids  IN MRP_ATP_PUB.Number_Arr, --Bug 3629191
        p_del_ods_demand_ids         IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_inv_item_ids       IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_demand_src_type    IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_cto_demand_ids     IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_cto_inv_item_ids   IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_cto_dem_src_type   IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_atp_refresh_no     IN MRP_ATP_PUB.Number_Arr, --3720018, added for support of rescheduling in ODS
        p_del_ods_cto_atp_refresh_no IN MRP_ATP_PUB.Number_Arr  --3720018, added for support of rescheduling in ODS
        -- End CTO ODR and Simplified Pegging
);

PROCEDURE DELETE_SUMMARY_ROW (p_identifier                      IN NUMBER,
                              p_plan_id                         IN NUMBER,
                              p_instance_id                     IN NUMBER,
                              p_demand_source_type            IN    Number  --cmro
                              );

-- RAJJAIN 11/05/2002 Now we pass the reference to p_identifiers and p_plan_ids array
-- and do bulk update in this procedure



/* Bug 2738280. Change the specification of these procedures.
PROCEDURE UPDATE_PLAN_SUMMARY_ROW (p_identifier                      IN NUMBER,
                                   p_plan_id                         IN NUMBER,
                                   p_instance_id                     IN NUMBER);

PROCEDURE UNDO_PLAN_SUMMARY_ROW (p_identifiers		IN MRP_ATP_PUB.Number_Arr,
                                 p_plan_ids		IN MRP_ATP_PUB.Number_Arr,
                                 p_instance_id		IN NUMBER);
*/
PROCEDURE UPDATE_PLAN_SUMMARY_ROW (p_inventory_item_id		     IN MRP_ATP_PUB.Number_Arr,
				   p_old_demand_date                 IN MRP_ATP_PUB.Date_Arr,
                                   p_old_demand_quantity	     IN MRP_ATP_PUB.Number_Arr,
				   p_organization_id		     IN MRP_ATP_PUB.Number_Arr,
				   p_plan_id                         IN NUMBER,
                                   p_instance_id                     IN NUMBER);

PROCEDURE UNDO_PLAN_SUMMARY_ROW (p_inventory_item_id		   IN MRP_ATP_PUB.Number_Arr,
				 p_using_assembly_demand_date      IN MRP_ATP_PUB.Date_Arr,
                                 p_using_requirement_quantity	   IN MRP_ATP_PUB.Number_Arr,
				 p_organization_id		   IN MRP_ATP_PUB.Number_Arr,
				 p_plan_id                         IN MRP_ATP_PUB.Number_Arr,
                                 p_instance_id                     IN NUMBER);



PROCEDURE INSERT_SUMMARY_SD_ROW( p_plan_id           IN NUMBER,
                                 p_instance_id       IN NUMBER,
                                 p_organization_id   IN NUMBER,
 				 p_inventory_item_id IN NUMBER,
 				 p_date		     IN DATE,
                                 p_quantity          IN NUMBER,
                                 p_demand_class      IN VARCHAR2);

/* New procedure for Allocated ATP Based on Planning Details for Agilent */

PROCEDURE Add_Stealing_Supply_Details (
                p_plan_id                IN NUMBER,
                p_identifier             IN NUMBER,
                p_inventory_item_id      IN NUMBER,
                p_organization_id        IN NUMBER,
                p_sr_instance_id         IN NUMBER,
                p_stealing_quantity      IN NUMBER,
                p_stealing_demand_class  IN VARCHAR2,
                p_stolen_demand_class    IN VARCHAR2,
                p_ship_date              IN DATE,
                p_transaction_id         OUT NoCopy NUMBER,
                p_refresh_number         IN NUMBER,
                p_ato_model_line_id        IN NUMBER,
                p_demand_source_type      IN    Number,  --cmro
                --bug3684383
                p_order_number           IN    Number
                ); -- For summary enhancement


PROCEDURE Remove_Invalid_Future_SD(
        p_future_pegging_tab            IN      MRP_ATP_PUB.Number_Arr
);

-- supply/demand perf enh
PROCEDURE move_SD_temp_into_mrp_details(
  p_pegging_id     IN NUMBER,
  p_end_pegging_id IN NUMBER);

PROCEDURE Clear_SD_Details_Temp;

-- for summary enhancement
PROCEDURE Delete_Copy_Demand (
                p_copy_demand_ids           IN  MRP_ATP_PUB.Number_Arr,
                p_copy_plan_ids             IN  MRP_ATP_PUB.Number_Arr,
                p_time_phased_set           IN  VARCHAR2,
                x_return_status             OUT NOCOPY VARCHAR2
);

-- New procedure added for ship_rec_cal project
PROCEDURE Flush_Data_In_Pds(
	p_ship_arrival_date_rec     IN          MSC_ATP_PVT.ship_arrival_date_rec_typ,
	x_return_status             OUT NOCOPY  VARCHAR2
);
PROCEDURE Flush_Data_In_Ods(
	p_ship_arrival_date_rec     IN          MSC_ATP_PVT.ship_arrival_date_rec_typ,
	x_return_status             OUT NOCOPY  VARCHAR2
);

--bug 3766179
PROCEDURE Add_Supplies ( p_supply_rec_type IN OUT NOCOPY MSC_ATP_DB_UTILS.supply_rec_typ);

--3720018, new procedure to call delete_row for set or request level.
Procedure call_delete_row (
p_instance_id              IN    NUMBER,
p_atp_table                IN    MRP_ATP_PUB.ATP_Rec_Typ,
p_refresh_number           IN    NUMBER,
x_delete_atp_rec           OUT   NoCopy MSC_ATP_PVT.DELETE_ATP_REC,
x_return_status      	   OUT   NoCopy VARCHAR2
);

--optional_fw
/*--Hide_SD_Rec-------------------------------------------------
|  o  This procedure is called from Schedule to hide the
|       demands/supplies for particular call of ATP_CHECK
+---------------------------------------------------------------*/
PROCEDURE Hide_SD_Rec(
        p_identifier          IN      NUMBER,
        x_return_status       OUT     NoCopy VARCHAR2
);

/*--Restore_SD_Rec-----------------------------------------------
|  o  This procedure is called from Schedule to restore the
|       demands/supplies for particular call of ATP_CHECK
+---------------------------------------------------------------*/
PROCEDURE Restore_SD_Rec(
        p_pegging_tab           IN      MRP_ATP_PUB.Number_Arr,
        x_return_status       OUT     NoCopy VARCHAR2
);

/*--Delete_SD_Rec-----------------------------------------------
|  o  This procedure is called from Schedule to delete the
|       demands/supplies for particular call of ATP_CHECK
|  0  New Procedure needed as inventory item id is -ve.
+---------------------------------------------------------------*/
PROCEDURE Delete_SD_Rec(
        p_pegging_tab           IN      MRP_ATP_PUB.Number_Arr,
        x_return_status       OUT     NoCopy VARCHAR2
);

END MSC_ATP_DB_UTILS;

/
