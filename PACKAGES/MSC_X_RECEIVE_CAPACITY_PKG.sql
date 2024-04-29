--------------------------------------------------------
--  DDL for Package MSC_X_RECEIVE_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_X_RECEIVE_CAPACITY_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCXRSCS.pls 115.15 2004/07/12 23:05:21 yptang ship $ */

G_MSC_CP_DEBUG VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
G_MSC_X_DEF_CALENDAR  VARCHAR2(14):=  fnd_profile.value('MSC_X_DEFAULT_CALENDAR');

SYS_YES                      CONSTANT NUMBER := 1;
SYS_NO                       CONSTANT NUMBER := 2;

SUPPLY_COMMIT        CONSTANT Number := 3;

PROCEDURE receive_capacity(p_errbuf OUT NOCOPY VARCHAR2,
        p_retcode 		OUT NOCOPY VARCHAR2,
   	p_horizon_start_date 	In VARCHAR2,
   	p_horizon_end_date 	In varchar2,
   	p_abc_class 		In Varchar2,
   	p_item_id 		In Number,
   	p_planner 		In Varchar2,
   	p_supplier_id 		IN number,
   	p_supplier_site_id 	In Number,
   	p_mps_designator_id 	IN Number,
   	p_overwrite 		IN Number default 1,
   	p_spread 		IN Number default 1
      );

PROCEDURE Calculate_Capacity(p_sr_instance_id IN Number,
   	p_organization_id 	IN Number,
   	p_supplier_id  		IN Number,
   	p_supplier_site_id 	IN Number,
   	p_mps_designator_id 	IN Number,
   	p_item_id 		IN Number,
   	p_receipt_date 		IN date,
   	p_capacity 		IN Number,
   	p_bucket_type 		IN Number,
   	p_calendar_code 	IN varchar2,
   	p_refresh_number 	IN NUmber,
   	p_lv_start_date		IN Date,
	p_lv_end_date		IN Date,
   	p_horizon_start_date 	In Date,
	p_horizon_end_date 	In date,
	p_overwrite 		IN Number,
        p_abc_class             in varchar2,
        p_planner               IN varchar2,
        p_map_supplier_id       IN number,
        p_map_supplier_site_id  IN number,
	p_rounding_control      IN number,
	p_spread 		IN Number);

PROCEDURE Populate_Capacity(p_sr_instance_id IN Number,
	p_organization_id IN Number,
	p_supplier_id	IN Number,
	p_supplier_site_id IN Number,
	p_item_id IN Number,
	p_date IN Date,
	p_capacity IN Number,
	p_refresh_number IN Number,
   	p_lv_start_date		IN Date,
	p_lv_end_date		IN Date,
	p_horizon_start_date in Date,
	p_horizon_end_date in Date,
	p_overwrite In Number);

PROCEDURE Insert_Capacity(p_sr_instance_id IN Number,
   p_organization_id IN Number,
   p_supplier_id  IN Number,
   p_supplier_site_id IN Number,
   p_item_id IN Number,
   p_from_date IN Date,
   p_to_date IN Date,
   p_capacity IN Number,
   p_refresh_number IN Number);

PROCEDURE Load_Supply_Schedule(p_sr_instance_id IN Number,
   p_organization_id IN Number,
   p_supplier_id  IN Number,
   p_supplier_site_id IN Number,
   p_mod_org_id In Number,
   p_mod_org_code IN Varchar2,
   p_mps_designator_id IN Number,
   p_item_id IN Number,
   p_date IN Date,
   p_capacity IN Number,
   p_refresh_number IN Number);

PROCEDURE Insert_MPS_Designator(p_sr_instance_id IN Number,
   p_organization_id IN Number,
   p_supplier_id IN Number,
   p_supplier_site_id IN Number,
   p_mps_designator IN Varchar2,
   p_refresh_number IN Number,
   p_mps_designator_id OUT NOCOPY Number);

PROCEDURE Insert_Supply_Schedule(p_sr_instance_id IN Number,
   p_organization_id IN Number,
   p_supplier_id  IN Number,
   p_supplier_site_id IN Number,
   p_mps_designator_id IN Number,
   p_item_id IN Number,
   p_date IN Date,
   p_capacity IN Number,
   p_refresh_number IN Number);

END MSC_X_RECEIVE_CAPACITY_PKG ;

 

/
