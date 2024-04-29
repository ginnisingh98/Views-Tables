--------------------------------------------------------
--  DDL for Package Body FTE_TL_COST_ALLOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TL_COST_ALLOCATION" AS
/* $Header: FTEVTLAB.pls 120.0 2005/05/26 17:46:04 appldev noship $ */



--Structure used to store outputs for bulk inserts into WSH_FREIGHT_COSTS

TYPE delivery_detail_id_typ                IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE delivery_id_typ                       IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE delivery_leg_id_typ                   IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE reprice_required_typ                  IS TABLE OF    VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE parent_delivery_detail_id_typ         IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE customer_id_typ                       IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE sold_to_contact_id_typ                IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE inventory_item_id_typ                 IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE item_description_typ                  IS TABLE OF    VARCHAR2(250) INDEX BY BINARY_INTEGER;
TYPE hazard_class_id_typ                   IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE country_of_origin_typ                 IS TABLE OF    VARCHAR2(50) INDEX BY BINARY_INTEGER;
TYPE classification_typ                    IS TABLE OF    VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE requested_quantity_typ                IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE requested_quantity_uom_typ            IS TABLE OF    VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE master_container_item_id_typ          IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE detail_container_item_id_typ          IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE customer_item_id_typ                  IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE net_weight_typ                        IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE organization_id_typ                   IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE container_flag_typ                    IS TABLE OF    VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE container_type_code_typ               IS TABLE OF    VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE container_name_typ                    IS TABLE OF    VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE fill_percent_typ                      IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE gross_weight_typ                      IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE currency_code_typ                     IS TABLE OF    VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE freight_class_cat_id_typ              IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE commodity_code_cat_id_typ             IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE weight_uom_code_typ                   IS TABLE OF    VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE volume_typ                            IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;
TYPE volume_uom_code_typ                   IS TABLE OF    VARCHAR2(3) INDEX BY BINARY_INTEGER;
TYPE tp_attribute_category_typ             IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute1_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute2_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute3_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute4_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute5_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute6_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute7_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute8_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute9_typ                     IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute10_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute11_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute12_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute13_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute14_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE tp_attribute15_typ                    IS TABLE OF    VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE attribute_category_typ                IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute1_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute2_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute3_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute4_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute5_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute6_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute7_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute8_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute9_typ                        IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute10_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute11_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute12_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute13_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute14_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE attribute15_typ                       IS TABLE OF    VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE source_type_typ                       IS TABLE OF    VARCHAR2(10) INDEX BY BINARY_INTEGER;  --new for om estimation
TYPE source_line_id_typ                    IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;        --new for om estimation
TYPE source_header_id_typ                  IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;        --new for om estimation
TYPE source_consolidation_id_typ           IS TABLE OF    NUMBER INDEX BY BINARY_INTEGER;        --new for om estimation
TYPE ship_date_typ                         IS TABLE OF    DATE INDEX BY BINARY_INTEGER;          --new for om estimation
TYPE arrival_date_typ                      IS TABLE OF    DATE INDEX BY BINARY_INTEGER;         --new for om estimation




G_B_delivery_detail_id  		    delivery_detail_id_typ;
G_B_delivery_id                 	    delivery_id_typ;
G_B_delivery_leg_id             	    delivery_leg_id_typ;
G_B_reprice_required            	    reprice_required_typ;
G_B_parent_delivery_detail_id   	    parent_delivery_detail_id_typ;
G_B_customer_id                 	    customer_id_typ;
G_B_sold_to_contact_id          	    sold_to_contact_id_typ;
G_B_inventory_item_id           	    inventory_item_id_typ;
G_B_item_description            	    item_description_typ;
G_B_hazard_class_id             	    hazard_class_id_typ;
G_B_country_of_origin           	    country_of_origin_typ;
G_B_classification              	    classification_typ;
G_B_requested_quantity          	    requested_quantity_typ;
G_B_requested_quantity_uom      	    requested_quantity_uom_typ;
G_B_master_container_item_id    	    master_container_item_id_typ;
G_B_detail_container_item_id    	    detail_container_item_id_typ;
G_B_customer_item_id            	    customer_item_id_typ;
G_B_net_weight                  	    net_weight_typ;
G_B_organization_id             	    organization_id_typ;
G_B_container_flag              	    container_flag_typ;
G_B_container_type_code         	    container_type_code_typ;
G_B_container_name              	    container_name_typ;
G_B_fill_percent                	    fill_percent_typ;
G_B_gross_weight                	    gross_weight_typ;
G_B_currency_code              	    	    currency_code_typ;
G_B_freight_class_cat_id        	    freight_class_cat_id_typ;
G_B_commodity_code_cat_id       	    commodity_code_cat_id_typ;
G_B_weight_uom_code             	    weight_uom_code_typ;
G_B_volume                      	    volume_typ;
G_B_volume_uom_code             	    volume_uom_code_typ;
G_B_tp_attribute_category       	    tp_attribute_category_typ;
G_B_tp_attribute1               	    tp_attribute1_typ;
G_B_tp_attribute2               	    tp_attribute2_typ;
G_B_tp_attribute3               	    tp_attribute3_typ;
G_B_tp_attribute4               	    tp_attribute4_typ;
G_B_tp_attribute5               	    tp_attribute5_typ;
G_B_tp_attribute6               	    tp_attribute6_typ;
G_B_tp_attribute7               	    tp_attribute7_typ;
G_B_tp_attribute8               	    tp_attribute8_typ;
G_B_tp_attribute9               	    tp_attribute9_typ;
G_B_tp_attribute10              	    tp_attribute10_typ;
G_B_tp_attribute11              	    tp_attribute11_typ;
G_B_tp_attribute12              	    tp_attribute12_typ;
G_B_tp_attribute13              	    tp_attribute13_typ;
G_B_tp_attribute14              	    tp_attribute14_typ;
G_B_tp_attribute15              	    tp_attribute15_typ;
G_B_attribute_category          	    attribute_category_typ;
G_B_attribute1                  	    attribute1_typ;
G_B_attribute2                  	    attribute2_typ;
G_B_attribute3                  	    attribute3_typ;
G_B_attribute4                  	    attribute4_typ;
G_B_attribute5                  	    attribute5_typ;
G_B_attribute6                  	    attribute6_typ;
G_B_attribute7                  	    attribute7_typ;
G_B_attribute8                  	    attribute8_typ;
G_B_attribute9                  	    attribute9_typ;
G_B_attribute10                 	    attribute10_typ;
G_B_attribute11                 	    attribute11_typ;
G_B_attribute12                 	    attribute12_typ;
G_B_attribute13                 	    attribute13_typ;
G_B_attribute14                 	    attribute14_typ;
G_B_attribute15                 	    attribute15_typ;
G_B_source_type                 	    source_type_typ;
G_B_source_line_id              	    source_line_id_typ;
G_B_source_header_id            	    source_header_id_typ;
G_B_source_consolidation_id     	    source_consolidation_id_typ;
G_B_ship_date                   	    ship_date_typ;
G_B_arrival_date                	    arrival_date_typ;







--Index for arrays
G_B_index NUMBER;

--Structures used to store outputs for bulk inserts into FTE_FREIGHT_COSTS_TEMP

TYPE T_FREIGHT_COST_ID_typ                  IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_FREIGHT_COST_TYPE_ID_typ             IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_UNIT_AMOUNT_typ                      IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_CALCULATION_METHOD_typ               IS TABLE OF                  VARCHAR2(15)    INDEX BY BINARY_INTEGER;
TYPE T_UOM_typ                              IS TABLE OF                  VARCHAR2(15)    INDEX BY BINARY_INTEGER;
TYPE T_QUANTITY_typ                         IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_TOTAL_AMOUNT_typ                     IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_CURRENCY_CODE_typ                    IS TABLE OF                  VARCHAR2(15)    INDEX BY BINARY_INTEGER;
TYPE T_CONVERSION_DATE_typ                  IS TABLE OF                  DATE            INDEX BY BINARY_INTEGER;
TYPE T_CONVERSION_RATE_typ                  IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_CONVERSION_TYPE_CODE_typ             IS TABLE OF                  VARCHAR2(30)    INDEX BY BINARY_INTEGER;
TYPE T_TRIP_ID_typ                          IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_STOP_ID_typ                          IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_DELIVERY_ID_typ                      IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_DELIVERY_LEG_ID_typ                  IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_DELIVERY_DETAIL_ID_typ               IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE_CATEGORY_typ               IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE1_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE2_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE3_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE4_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE5_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE6_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE7_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE8_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE9_typ                       IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE10_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE11_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE12_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE13_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE14_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_ATTRIBUTE15_typ                      IS TABLE OF                  VARCHAR2(150)   INDEX BY BINARY_INTEGER;
TYPE T_CREATION_DATE_typ                    IS TABLE OF                  DATE            INDEX BY BINARY_INTEGER;
TYPE T_CREATED_BY_typ                       IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_LAST_UPDATE_DATE_typ                 IS TABLE OF                  DATE            INDEX BY BINARY_INTEGER;
TYPE T_LAST_UPDATED_BY_typ                  IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_LAST_UPDATE_LOGIN_typ                IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_PROGRAM_APPLICATION_ID_typ           IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_PROGRAM_ID_typ                       IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_PROGRAM_UPDATE_DATE_typ              IS TABLE OF                  DATE            INDEX BY BINARY_INTEGER;
TYPE T_REQUEST_ID_typ                       IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_LINE_TYPE_CODE_typ                   IS TABLE OF                  VARCHAR2(30)    INDEX BY BINARY_INTEGER;
TYPE T_PRICING_LIST_HEADER_ID_typ           IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_PRICING_LIST_LINE_ID_typ             IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_APPLIED_TO_CHARGE_ID_typ             IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_CHARGE_UNIT_VALUE_typ                IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_CHARGE_SOURCE_CODE_typ               IS TABLE OF                  VARCHAR2(30)    INDEX BY BINARY_INTEGER;
TYPE T_ESTIMATED_FLAG_typ                   IS TABLE OF                  VARCHAR2(1)     INDEX BY BINARY_INTEGER;
TYPE T_COMPARISON_REQUEST_ID_typ            IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_LANE_ID_typ                          IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_SCHEDULE_ID_typ                      IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_MOVED_TO_MAIN_FLAG_typ               IS TABLE OF                  VARCHAR2(1)     INDEX BY BINARY_INTEGER;
TYPE T_SERVICE_TYPE_CODE_typ                IS TABLE OF                  VARCHAR2(30)    INDEX BY BINARY_INTEGER;
TYPE T_COMMODITY_CATEGORY_ID_typ            IS TABLE OF                  NUMBER          INDEX BY BINARY_INTEGER;
TYPE T_VEHICLE_TYPE_ID_typ 		    IS TABLE OF    		 NUMBER 	 INDEX BY BINARY_INTEGER;
TYPE T_BILLABLE_QUANTITY_typ 		    IS TABLE OF    		 NUMBER 	 INDEX BY BINARY_INTEGER;
TYPE T_BILLABLE_UOM_typ 		    IS TABLE OF    		 VARCHAR2(30) 	 INDEX BY BINARY_INTEGER;
TYPE T_BILLABLE_BASIS_typ 		    IS TABLE OF    		 VARCHAR2(30) 	 INDEX BY BINARY_INTEGER;



G_B_T_FREIGHT_COST_ID         	      T_FREIGHT_COST_ID_typ;
G_B_T_FREIGHT_COST_TYPE_ID    	      T_FREIGHT_COST_TYPE_ID_typ;
G_B_T_UNIT_AMOUNT             	      T_UNIT_AMOUNT_typ;
G_B_T_CALCULATION_METHOD      	      T_CALCULATION_METHOD_typ;
G_B_T_UOM                     	      T_UOM_typ;
G_B_T_QUANTITY                	      T_QUANTITY_typ;
G_B_T_TOTAL_AMOUNT            	      T_TOTAL_AMOUNT_typ;
G_B_T_CURRENCY_CODE           	      T_CURRENCY_CODE_typ;
G_B_T_CONVERSION_DATE         	      T_CONVERSION_DATE_typ;
G_B_T_CONVERSION_RATE         	      T_CONVERSION_RATE_typ;
G_B_T_CONVERSION_TYPE_CODE    	      T_CONVERSION_TYPE_CODE_typ;
G_B_T_TRIP_ID                 	      T_TRIP_ID_typ;
G_B_T_STOP_ID                 	      T_STOP_ID_typ;
G_B_T_DELIVERY_ID             	      T_DELIVERY_ID_typ;
G_B_T_DELIVERY_LEG_ID         	      T_DELIVERY_LEG_ID_typ;
G_B_T_DELIVERY_DETAIL_ID      	      T_DELIVERY_DETAIL_ID_typ;
G_B_T_ATTRIBUTE_CATEGORY      	      T_ATTRIBUTE_CATEGORY_typ;
G_B_T_ATTRIBUTE1              	      T_ATTRIBUTE1_typ;
G_B_T_ATTRIBUTE2              	      T_ATTRIBUTE2_typ;
G_B_T_ATTRIBUTE3              	      T_ATTRIBUTE3_typ;
G_B_T_ATTRIBUTE4              	      T_ATTRIBUTE4_typ;
G_B_T_ATTRIBUTE5              	      T_ATTRIBUTE5_typ;
G_B_T_ATTRIBUTE6              	      T_ATTRIBUTE6_typ;
G_B_T_ATTRIBUTE7              	      T_ATTRIBUTE7_typ;
G_B_T_ATTRIBUTE8              	      T_ATTRIBUTE8_typ;
G_B_T_ATTRIBUTE9              	      T_ATTRIBUTE9_typ;
G_B_T_ATTRIBUTE10             	      T_ATTRIBUTE10_typ;
G_B_T_ATTRIBUTE11             	      T_ATTRIBUTE11_typ;
G_B_T_ATTRIBUTE12             	      T_ATTRIBUTE12_typ;
G_B_T_ATTRIBUTE13             	      T_ATTRIBUTE13_typ;
G_B_T_ATTRIBUTE14             	      T_ATTRIBUTE14_typ;
G_B_T_ATTRIBUTE15             	      T_ATTRIBUTE15_typ;
G_B_T_CREATION_DATE           	      T_CREATION_DATE_typ;
G_B_T_CREATED_BY              	      T_CREATED_BY_typ;
G_B_T_LAST_UPDATE_DATE        	      T_LAST_UPDATE_DATE_typ;
G_B_T_LAST_UPDATED_BY         	      T_LAST_UPDATED_BY_typ;
G_B_T_LAST_UPDATE_LOGIN       	      T_LAST_UPDATE_LOGIN_typ;
G_B_T_PROGRAM_APPLICATION_ID  	      T_PROGRAM_APPLICATION_ID_typ;
G_B_T_PROGRAM_ID              	      T_PROGRAM_ID_typ;
G_B_T_PROGRAM_UPDATE_DATE     	      T_PROGRAM_UPDATE_DATE_typ;
G_B_T_REQUEST_ID              	      T_REQUEST_ID_typ;
G_B_T_LINE_TYPE_CODE          	      T_LINE_TYPE_CODE_typ;
G_B_T_PRICING_LIST_HEADER_ID  	      T_PRICING_LIST_HEADER_ID_typ;
G_B_T_PRICING_LIST_LINE_ID    	      T_PRICING_LIST_LINE_ID_typ;
G_B_T_APPLIED_TO_CHARGE_ID    	      T_APPLIED_TO_CHARGE_ID_typ;
G_B_T_CHARGE_UNIT_VALUE       	      T_CHARGE_UNIT_VALUE_typ;
G_B_T_CHARGE_SOURCE_CODE      	      T_CHARGE_SOURCE_CODE_typ;
G_B_T_ESTIMATED_FLAG          	      T_ESTIMATED_FLAG_typ;
G_B_T_COMPARISON_REQUEST_ID   	      T_COMPARISON_REQUEST_ID_typ;
G_B_T_LANE_ID                 	      T_LANE_ID_typ;
G_B_T_SCHEDULE_ID             	      T_SCHEDULE_ID_typ;
G_B_T_MOVED_TO_MAIN_FLAG      	      T_MOVED_TO_MAIN_FLAG_typ;
G_B_T_SERVICE_TYPE_CODE       	      T_SERVICE_TYPE_CODE_typ;
G_B_T_COMMODITY_CATEGORY_ID   	      T_COMMODITY_CATEGORY_ID_typ;
G_B_T_VEHICLE_TYPE_ID 		      T_VEHICLE_TYPE_ID_typ;
G_B_T_BILLABLE_QUANTITY 	      T_BILLABLE_QUANTITY_typ;
G_B_T_BILLABLE_UOM 		      T_BILLABLE_UOM_typ;
G_B_T_BILLABLE_BASIS 		      T_BILLABLE_BASIS_typ;




--Index for arrays
G_B_T_index NUMBER;

TYPE stop_id_tbl_type IS TABLE of wsh_trip_stops.stop_id%type INDEX BY BINARY_INTEGER;
TYPE distance_to_next_stop_tbl_type IS TABLE of wsh_trip_stops.distance_to_next_stop%type INDEX BY BINARY_INTEGER;

g_stop_id_tbl stop_id_tbl_type;
g_distance_to_next_stop_tbl distance_to_next_stop_tbl_type;

--Structure used to store charges when
--they are allocated to the dleg

TYPE TL_dleg_alloc_rec_type IS RECORD(

delivery_leg_id 	NUMBER,
delivery_id		NUMBER,
base_dist_load_chrg   NUMBER,
base_dist_load_unit_chrg NUMBER,
base_dist_unload_chrg NUMBER,
base_dist_unload_unit_chrg NUMBER,
base_unit_chrg        NUMBER,
base_unit_unit_chrg   NUMBER,
base_time_chrg        NUMBER,
base_time_unit_chrg   NUMBER,
base_flat_chrg		NUMBER,
stop_off_chrg		NUMBER,
out_of_route_chrg	NUMBER,
document_chrg		NUMBER,
handling_chrg		NUMBER,
fuel_chrg		NUMBER,
weekday_layover_chrg	NUMBER,
weekend_layover_chrg	NUMBER,
loading_chrg		NUMBER,
ast_loading_chrg	NUMBER,
unloading_chrg		NUMBER,
origin_surchrg		NUMBER,
destination_surchrg	NUMBER,
ast_unloading_chrg	NUMBER,
fac_handling_chrg	NUMBER,
fac_loading_chrg	NUMBER,
fac_ast_loading_chrg	NUMBER,
fac_unloading_chrg	NUMBER,
fac_ast_unloading_chrg	NUMBER,
fac_loading_currency	VARCHAR2(30),
fac_unloading_currency	VARCHAR2(30),
fac_handling_currency	VARCHAR2(30),
total_dleg_charge NUMBER--FOR MDC
);



TYPE TL_dleg_alloc_TAB_TYPE IS TABLE OF TL_dleg_alloc_rec_type INDEX BY
BINARY_INTEGER;

TYPE TL_detail_alloc_rec_type IS RECORD(
total_detail_charge NUMBER
);

--This will be indexed by the delivery detail id
TYPE TL_detail_alloc_TAB_TYPE IS TABLE OF TL_detail_alloc_rec_type INDEX BY
BINARY_INTEGER;



PROCEDURE Clear_Bulk_Arrays(
	x_return_status OUT NOCOPY Varchar2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Clear_Bulk_Arrays','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	G_B_delivery_detail_id.delete;
	G_B_delivery_id.delete;
	G_B_delivery_leg_id.delete;
	G_B_reprice_required.delete;
	G_B_parent_delivery_detail_id.delete;
	G_B_customer_id.delete;
	G_B_sold_to_contact_id.delete;
	G_B_inventory_item_id.delete;
	G_B_item_description.delete;
	G_B_hazard_class_id.delete;
	G_B_country_of_origin.delete;
	G_B_classification.delete;
	G_B_requested_quantity.delete;
	G_B_requested_quantity_uom.delete;
	G_B_master_container_item_id.delete;
	G_B_detail_container_item_id.delete;
	G_B_customer_item_id.delete;
	G_B_net_weight.delete;
	G_B_organization_id.delete;
	G_B_container_flag.delete;
	G_B_container_type_code.delete;
	G_B_container_name.delete;
	G_B_fill_percent.delete;
	G_B_gross_weight.delete;
	G_B_currency_code.delete;
	G_B_freight_class_cat_id.delete;
	G_B_commodity_code_cat_id.delete;
	G_B_weight_uom_code.delete;
	G_B_volume.delete;
	G_B_volume_uom_code.delete;
	G_B_tp_attribute_category.delete;
	G_B_tp_attribute1.delete;
	G_B_tp_attribute2.delete;
	G_B_tp_attribute3.delete;
	G_B_tp_attribute4.delete;
	G_B_tp_attribute5.delete;
	G_B_tp_attribute6.delete;
	G_B_tp_attribute7.delete;
	G_B_tp_attribute8.delete;
	G_B_tp_attribute9.delete;
	G_B_tp_attribute10.delete;
	G_B_tp_attribute11.delete;
	G_B_tp_attribute12.delete;
	G_B_tp_attribute13.delete;
	G_B_tp_attribute14.delete;
	G_B_tp_attribute15.delete;
	G_B_attribute_category.delete;
	G_B_attribute1.delete;
	G_B_attribute2.delete;
	G_B_attribute3.delete;
	G_B_attribute4.delete;
	G_B_attribute5.delete;
	G_B_attribute6.delete;
	G_B_attribute7.delete;
	G_B_attribute8.delete;
	G_B_attribute9.delete;
	G_B_attribute10.delete;
	G_B_attribute11.delete;
	G_B_attribute12.delete;
	G_B_attribute13.delete;
	G_B_attribute14.delete;
	G_B_attribute15.delete;
	G_B_source_type.delete;
	G_B_source_line_id.delete;
	G_B_source_header_id.delete;
	G_B_source_consolidation_id.delete;
	G_B_ship_date.delete;
	G_B_arrival_date.delete;





	G_B_index:=1;


	G_B_T_FREIGHT_COST_ID.delete;
	G_B_T_FREIGHT_COST_TYPE_ID.delete;
	G_B_T_UNIT_AMOUNT.delete;
	G_B_T_CALCULATION_METHOD.delete;
	G_B_T_UOM.delete;
	G_B_T_QUANTITY.delete;
	G_B_T_TOTAL_AMOUNT.delete;
	G_B_T_CURRENCY_CODE.delete;
	G_B_T_CONVERSION_DATE.delete;
	G_B_T_CONVERSION_RATE.delete;
	G_B_T_CONVERSION_TYPE_CODE.delete;
	G_B_T_TRIP_ID.delete;
	G_B_T_STOP_ID.delete;
	G_B_T_DELIVERY_ID.delete;
	G_B_T_DELIVERY_LEG_ID.delete;
	G_B_T_DELIVERY_DETAIL_ID.delete;
	G_B_T_ATTRIBUTE_CATEGORY.delete;
	G_B_T_ATTRIBUTE1.delete;
	G_B_T_ATTRIBUTE2.delete;
	G_B_T_ATTRIBUTE3.delete;
	G_B_T_ATTRIBUTE4.delete;
	G_B_T_ATTRIBUTE5.delete;
	G_B_T_ATTRIBUTE6.delete;
	G_B_T_ATTRIBUTE7.delete;
	G_B_T_ATTRIBUTE8.delete;
	G_B_T_ATTRIBUTE9.delete;
	G_B_T_ATTRIBUTE10.delete;
	G_B_T_ATTRIBUTE11.delete;
	G_B_T_ATTRIBUTE12.delete;
	G_B_T_ATTRIBUTE13.delete;
	G_B_T_ATTRIBUTE14.delete;
	G_B_T_ATTRIBUTE15.delete;
	G_B_T_CREATION_DATE.delete;
	G_B_T_CREATED_BY.delete;
	G_B_T_LAST_UPDATE_DATE.delete;
	G_B_T_LAST_UPDATED_BY.delete;
	G_B_T_LAST_UPDATE_LOGIN.delete;
	G_B_T_PROGRAM_APPLICATION_ID.delete;
	G_B_T_PROGRAM_ID.delete;
	G_B_T_PROGRAM_UPDATE_DATE.delete;
	G_B_T_REQUEST_ID.delete;
	G_B_T_LINE_TYPE_CODE.delete;
	G_B_T_PRICING_LIST_HEADER_ID.delete;
	G_B_T_PRICING_LIST_LINE_ID.delete;
	G_B_T_APPLIED_TO_CHARGE_ID.delete;
	G_B_T_CHARGE_UNIT_VALUE.delete;
	G_B_T_CHARGE_SOURCE_CODE.delete;
	G_B_T_ESTIMATED_FLAG.delete;
	G_B_T_COMPARISON_REQUEST_ID.delete;
	G_B_T_LANE_ID.delete;
	G_B_T_SCHEDULE_ID.delete;
	G_B_T_MOVED_TO_MAIN_FLAG.delete;
	G_B_T_SERVICE_TYPE_CODE.delete;
	G_B_T_COMMODITY_CATEGORY_ID.delete;

	G_B_T_index:=1;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Clear_Bulk_Arrays');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Clear_Bulk_Arrays',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Clear_Bulk_Arrays');

END Clear_Bulk_Arrays;


PROCEDURE Insert_Into_Bulk_Array(
	p_freight_cost_rec IN FTE_FREIGHT_PRICING.shipment_line_rec_type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Into_Bulk_Array','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	G_B_index:=G_B_index+1;

	G_B_delivery_detail_id(G_B_index):=p_freight_cost_rec.delivery_detail_id;
	G_B_delivery_id(G_B_index):=p_freight_cost_rec.delivery_id;
	G_B_delivery_leg_id(G_B_index):=p_freight_cost_rec.delivery_leg_id;
	G_B_reprice_required(G_B_index):=p_freight_cost_rec.reprice_required;
	G_B_parent_delivery_detail_id(G_B_index):=p_freight_cost_rec.parent_delivery_detail_id;
	G_B_customer_id(G_B_index):=p_freight_cost_rec.customer_id;
	G_B_sold_to_contact_id(G_B_index):=p_freight_cost_rec.sold_to_contact_id;
	G_B_inventory_item_id(G_B_index):=p_freight_cost_rec.inventory_item_id;
	G_B_item_description(G_B_index):=p_freight_cost_rec.item_description;
	G_B_hazard_class_id(G_B_index):=p_freight_cost_rec.hazard_class_id;
	G_B_country_of_origin(G_B_index):=p_freight_cost_rec.country_of_origin;
	G_B_classification(G_B_index):=p_freight_cost_rec.classification;
	G_B_requested_quantity(G_B_index):=p_freight_cost_rec.requested_quantity;
	G_B_requested_quantity_uom(G_B_index):=p_freight_cost_rec.requested_quantity_uom;
	G_B_master_container_item_id(G_B_index):=p_freight_cost_rec.master_container_item_id;
	G_B_detail_container_item_id(G_B_index):=p_freight_cost_rec.detail_container_item_id;
	G_B_customer_item_id(G_B_index):=p_freight_cost_rec.customer_item_id;
	G_B_net_weight(G_B_index):=p_freight_cost_rec.net_weight;
	G_B_organization_id(G_B_index):=p_freight_cost_rec.organization_id;
	G_B_container_flag(G_B_index):=p_freight_cost_rec.container_flag;
	G_B_container_type_code(G_B_index):=p_freight_cost_rec.container_type_code;
	G_B_container_name(G_B_index):=p_freight_cost_rec.container_name;
	G_B_fill_percent(G_B_index):=p_freight_cost_rec.fill_percent;
	G_B_gross_weight(G_B_index):=p_freight_cost_rec.gross_weight;
	G_B_currency_code(G_B_index):=p_freight_cost_rec.currency_code;
	G_B_freight_class_cat_id(G_B_index):=p_freight_cost_rec.freight_class_cat_id;
	G_B_commodity_code_cat_id(G_B_index):=p_freight_cost_rec.commodity_code_cat_id;
	G_B_weight_uom_code(G_B_index):=p_freight_cost_rec.weight_uom_code;
	G_B_volume(G_B_index):=p_freight_cost_rec.volume;
	G_B_volume_uom_code(G_B_index):=p_freight_cost_rec.volume_uom_code;
	G_B_tp_attribute_category(G_B_index):=p_freight_cost_rec.tp_attribute_category;
	G_B_tp_attribute1(G_B_index):=p_freight_cost_rec.tp_attribute1;
	G_B_tp_attribute2(G_B_index):=p_freight_cost_rec.tp_attribute2;
	G_B_tp_attribute3(G_B_index):=p_freight_cost_rec.tp_attribute3;
	G_B_tp_attribute4(G_B_index):=p_freight_cost_rec.tp_attribute4;
	G_B_tp_attribute5(G_B_index):=p_freight_cost_rec.tp_attribute5;
	G_B_tp_attribute6(G_B_index):=p_freight_cost_rec.tp_attribute6;
	G_B_tp_attribute7(G_B_index):=p_freight_cost_rec.tp_attribute7;
	G_B_tp_attribute8(G_B_index):=p_freight_cost_rec.tp_attribute8;
	G_B_tp_attribute9(G_B_index):=p_freight_cost_rec.tp_attribute9;
	G_B_tp_attribute10(G_B_index):=p_freight_cost_rec.tp_attribute10;
	G_B_tp_attribute11(G_B_index):=p_freight_cost_rec.tp_attribute11;
	G_B_tp_attribute12(G_B_index):=p_freight_cost_rec.tp_attribute12;
	G_B_tp_attribute13(G_B_index):=p_freight_cost_rec.tp_attribute13;
	G_B_tp_attribute14(G_B_index):=p_freight_cost_rec.tp_attribute14;
	G_B_tp_attribute15(G_B_index):=p_freight_cost_rec.tp_attribute15;
	G_B_attribute_category(G_B_index):=p_freight_cost_rec.attribute_category;
	G_B_attribute1(G_B_index):=p_freight_cost_rec.attribute1;
	G_B_attribute2(G_B_index):=p_freight_cost_rec.attribute2;
	G_B_attribute3(G_B_index):=p_freight_cost_rec.attribute3;
	G_B_attribute4(G_B_index):=p_freight_cost_rec.attribute4;
	G_B_attribute5(G_B_index):=p_freight_cost_rec.attribute5;
	G_B_attribute6(G_B_index):=p_freight_cost_rec.attribute6;
	G_B_attribute7(G_B_index):=p_freight_cost_rec.attribute7;
	G_B_attribute8(G_B_index):=p_freight_cost_rec.attribute8;
	G_B_attribute9(G_B_index):=p_freight_cost_rec.attribute9;
	G_B_attribute10(G_B_index):=p_freight_cost_rec.attribute10;
	G_B_attribute11(G_B_index):=p_freight_cost_rec.attribute11;
	G_B_attribute12(G_B_index):=p_freight_cost_rec.attribute12;
	G_B_attribute13(G_B_index):=p_freight_cost_rec.attribute13;
	G_B_attribute14(G_B_index):=p_freight_cost_rec.attribute14;
	G_B_attribute15(G_B_index):=p_freight_cost_rec.attribute15;
	G_B_source_type(G_B_index):=p_freight_cost_rec.source_type;
	G_B_source_line_id(G_B_index):=p_freight_cost_rec.source_line_id;
	G_B_source_header_id(G_B_index):=p_freight_cost_rec.source_header_id;
	G_B_source_consolidation_id(G_B_index):=p_freight_cost_rec.source_consolidation_id;
	G_B_ship_date(G_B_index):=p_freight_cost_rec.ship_date;
	G_B_arrival_date(G_B_index):=p_freight_cost_rec.arrival_date;







        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Bulk_Array');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Into_Bulk_Array',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Bulk_Array');

END Insert_Into_Bulk_Array;


PROCEDURE Insert_Into_Temp_Bulk_Array(
	p_freight_cost_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	x_return_status OUT NOCOPY Varchar2) IS


	CURSOR C_Next_Freight_Cost_Id
	IS
	SELECT fte_freight_costs_temp_s.nextval
	FROM sys.dual;

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Into_Temp_Bulk_Array','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	G_B_T_index:=G_B_T_index+1;

        OPEN C_Next_Freight_Cost_Id;
        FETCH C_Next_Freight_Cost_Id INTO G_B_T_FREIGHT_COST_ID(G_B_T_index);
        CLOSE C_Next_Freight_Cost_Id;


	--G_B_T_FREIGHT_COST_ID(G_B_T_index):=p_freight_cost_rec.FREIGHT_COST_ID;
	G_B_T_FREIGHT_COST_TYPE_ID(G_B_T_index):=p_freight_cost_rec.FREIGHT_COST_TYPE_ID;
	G_B_T_UNIT_AMOUNT(G_B_T_index):=p_freight_cost_rec.UNIT_AMOUNT;
	G_B_T_CALCULATION_METHOD(G_B_T_index):=p_freight_cost_rec.CALCULATION_METHOD;
	G_B_T_UOM(G_B_T_index):=p_freight_cost_rec.UOM;
	G_B_T_QUANTITY(G_B_T_index):=p_freight_cost_rec.QUANTITY;
	G_B_T_TOTAL_AMOUNT(G_B_T_index):=p_freight_cost_rec.TOTAL_AMOUNT;
	G_B_T_CURRENCY_CODE(G_B_T_index):=p_freight_cost_rec.CURRENCY_CODE;
	G_B_T_CONVERSION_DATE(G_B_T_index):=p_freight_cost_rec.CONVERSION_DATE;
	G_B_T_CONVERSION_RATE(G_B_T_index):=p_freight_cost_rec.CONVERSION_RATE;
	G_B_T_CONVERSION_TYPE_CODE(G_B_T_index):=p_freight_cost_rec.CONVERSION_TYPE_CODE;
	G_B_T_TRIP_ID(G_B_T_index):=p_freight_cost_rec.TRIP_ID;
	G_B_T_STOP_ID(G_B_T_index):=p_freight_cost_rec.STOP_ID;
	G_B_T_DELIVERY_ID(G_B_T_index):=p_freight_cost_rec.DELIVERY_ID;
	G_B_T_DELIVERY_LEG_ID(G_B_T_index):=p_freight_cost_rec.DELIVERY_LEG_ID;
	G_B_T_DELIVERY_DETAIL_ID(G_B_T_index):=p_freight_cost_rec.DELIVERY_DETAIL_ID;
	G_B_T_ATTRIBUTE_CATEGORY(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE_CATEGORY;
	G_B_T_ATTRIBUTE1(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE1;
	G_B_T_ATTRIBUTE2(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE2;
	G_B_T_ATTRIBUTE3(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE3;
	G_B_T_ATTRIBUTE4(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE4;
	G_B_T_ATTRIBUTE5(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE5;
	G_B_T_ATTRIBUTE6(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE6;
	G_B_T_ATTRIBUTE7(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE7;
	G_B_T_ATTRIBUTE8(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE8;
	G_B_T_ATTRIBUTE9(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE9;
	G_B_T_ATTRIBUTE10(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE10;
	G_B_T_ATTRIBUTE11(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE11;
	G_B_T_ATTRIBUTE12(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE12;
	G_B_T_ATTRIBUTE13(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE13;
	G_B_T_ATTRIBUTE14(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE14;
	G_B_T_ATTRIBUTE15(G_B_T_index):=p_freight_cost_rec.ATTRIBUTE15;
	G_B_T_CREATION_DATE(G_B_T_index):=p_freight_cost_rec.CREATION_DATE;
	G_B_T_CREATED_BY(G_B_T_index):=p_freight_cost_rec.CREATED_BY;
	G_B_T_LAST_UPDATE_DATE(G_B_T_index):=p_freight_cost_rec.LAST_UPDATE_DATE;
	G_B_T_LAST_UPDATED_BY(G_B_T_index):=p_freight_cost_rec.LAST_UPDATED_BY;
	G_B_T_LAST_UPDATE_LOGIN(G_B_T_index):=p_freight_cost_rec.LAST_UPDATE_LOGIN;
	G_B_T_PROGRAM_APPLICATION_ID(G_B_T_index):=p_freight_cost_rec.PROGRAM_APPLICATION_ID;
	G_B_T_PROGRAM_ID(G_B_T_index):=p_freight_cost_rec.PROGRAM_ID;
	G_B_T_PROGRAM_UPDATE_DATE(G_B_T_index):=p_freight_cost_rec.PROGRAM_UPDATE_DATE;
	G_B_T_REQUEST_ID(G_B_T_index):=p_freight_cost_rec.REQUEST_ID;
	G_B_T_LINE_TYPE_CODE(G_B_T_index):=p_freight_cost_rec.LINE_TYPE_CODE;
	G_B_T_PRICING_LIST_HEADER_ID(G_B_T_index):=p_freight_cost_rec.PRICING_LIST_HEADER_ID;
	G_B_T_PRICING_LIST_LINE_ID(G_B_T_index):=p_freight_cost_rec.PRICING_LIST_LINE_ID;
	G_B_T_APPLIED_TO_CHARGE_ID(G_B_T_index):=p_freight_cost_rec.APPLIED_TO_CHARGE_ID;
	G_B_T_CHARGE_UNIT_VALUE(G_B_T_index):=p_freight_cost_rec.CHARGE_UNIT_VALUE;
	G_B_T_CHARGE_SOURCE_CODE(G_B_T_index):=p_freight_cost_rec.CHARGE_SOURCE_CODE;
	G_B_T_ESTIMATED_FLAG(G_B_T_index):=p_freight_cost_rec.ESTIMATED_FLAG;
	G_B_T_COMPARISON_REQUEST_ID(G_B_T_index):=p_freight_cost_rec.COMPARISON_REQUEST_ID;
	G_B_T_LANE_ID(G_B_T_index):=p_freight_cost_rec.LANE_ID;
	G_B_T_SCHEDULE_ID(G_B_T_index):=p_freight_cost_rec.SCHEDULE_ID;
	G_B_T_MOVED_TO_MAIN_FLAG(G_B_T_index):=p_freight_cost_rec.MOVED_TO_MAIN_FLAG;
	G_B_T_SERVICE_TYPE_CODE(G_B_T_index):=p_freight_cost_rec.SERVICE_TYPE_CODE;
	G_B_T_COMMODITY_CATEGORY_ID(G_B_T_index):=p_freight_cost_rec.COMMODITY_CATEGORY_ID;

	G_B_T_VEHICLE_TYPE_ID(G_B_T_index):=p_freight_cost_rec.VEHICLE_TYPE_ID;
	G_B_T_BILLABLE_QUANTITY(G_B_T_index):=p_freight_cost_rec.BILLABLE_QUANTITY;
	G_B_T_BILLABLE_UOM(G_B_T_index):=p_freight_cost_rec.BILLABLE_UOM;
	G_B_T_BILLABLE_BASIS(G_B_T_index):=p_freight_cost_rec.BILLABLE_BASIS;






        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Temp_Bulk_Array');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Into_Temp_Bulk_Array',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Into_Temp_Bulk_Array');

END Insert_Into_Temp_Bulk_Array;


PROCEDURE Bulk_Insert_Temp(
	x_return_status OUT NOCOPY Varchar2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
	i NUMBER;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Bulk_Insert_Temp','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	SAVEPOINT Bulk_Insert_Temp;

	IF (G_B_T_FREIGHT_COST_ID.first IS NOT NULL)
	THEN

		FORALL i IN G_B_T_FREIGHT_COST_ID.first .. G_B_T_FREIGHT_COST_ID.last
			INSERT INTO FTE_FREIGHT_COSTS_TEMP (
				freight_cost_id,
				freight_cost_type_id,
				unit_amount,
				calculation_method,
				uom,
				quantity,
				total_amount,
				currency_code,
				conversion_date,
				conversion_rate,
				conversion_type_code,
				trip_id,
				stop_id,
				delivery_id,
				delivery_leg_id,
				delivery_detail_id,
				attribute_category,
				attribute1,
				attribute2,
				attribute3,
				attribute4,
				attribute5,
				attribute6,
				attribute7,
				attribute8,
				attribute9,
				attribute10,
				attribute11,
				attribute12,
				attribute13,
				attribute14,
				attribute15,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				program_application_id,
				program_id,
				program_update_date,
				request_id,
				line_type_code,
				charge_unit_value,
				charge_source_code,
				estimated_flag,
				comparison_request_id,
				lane_id,
				schedule_id,
				moved_to_main_flag,
				service_type_code,  -- bug2741467
				commodity_category_id,
				vehicle_type_id,
				billable_quantity,
				billable_uom,
				billable_basis

			)
			VALUES
				(
				G_B_T_FREIGHT_COST_ID(i),
				G_B_T_FREIGHT_COST_TYPE_ID(i),
				G_B_T_UNIT_AMOUNT(i),
				G_B_T_CALCULATION_METHOD(i),
				G_B_T_UOM(i),
				G_B_T_QUANTITY(i),
				G_B_T_TOTAL_AMOUNT(i),
				G_B_T_CURRENCY_CODE(i),
				G_B_T_CONVERSION_DATE(i),
				G_B_T_CONVERSION_RATE(i),
				G_B_T_CONVERSION_TYPE_CODE(i),
				G_B_T_TRIP_ID(i),
				G_B_T_STOP_ID(i),
				G_B_T_DELIVERY_ID(i),
				G_B_T_DELIVERY_LEG_ID(i),
				G_B_T_DELIVERY_DETAIL_ID(i),
				G_B_T_ATTRIBUTE_CATEGORY(i),
				G_B_T_ATTRIBUTE1(i),
				G_B_T_ATTRIBUTE2(i),
				G_B_T_ATTRIBUTE3(i),
				G_B_T_ATTRIBUTE4(i),
				G_B_T_ATTRIBUTE5(i),
				G_B_T_ATTRIBUTE6(i),
				G_B_T_ATTRIBUTE7(i),
				G_B_T_ATTRIBUTE8(i),
				G_B_T_ATTRIBUTE9(i),
				G_B_T_ATTRIBUTE10(i),
				G_B_T_ATTRIBUTE11(i),
				G_B_T_ATTRIBUTE12(i),
				G_B_T_ATTRIBUTE13(i),
				G_B_T_ATTRIBUTE14(i),
				G_B_T_ATTRIBUTE15(i),
				G_B_T_CREATION_DATE(i),
				G_B_T_CREATED_BY(i),
				G_B_T_LAST_UPDATE_DATE(i),
				G_B_T_LAST_UPDATED_BY(i),
				G_B_T_LAST_UPDATE_LOGIN(i),
				G_B_T_PROGRAM_APPLICATION_ID(i),
				G_B_T_PROGRAM_ID(i),
				G_B_T_PROGRAM_UPDATE_DATE(i),
				G_B_T_REQUEST_ID(i),
				G_B_T_LINE_TYPE_CODE(i),
				--G_B_T_PRICING_LIST_HEADER_ID(i),
				--G_B_T_PRICING_LIST_LINE_ID(i),
				--G_B_T_APPLIED_TO_CHARGE_ID(i),
				G_B_T_CHARGE_UNIT_VALUE(i),
				G_B_T_CHARGE_SOURCE_CODE(i),
				G_B_T_ESTIMATED_FLAG(i),
				G_B_T_COMPARISON_REQUEST_ID(i),
				G_B_T_LANE_ID(i),
				G_B_T_SCHEDULE_ID(i),
				G_B_T_MOVED_TO_MAIN_FLAG(i),
				G_B_T_SERVICE_TYPE_CODE(i),
				G_B_T_COMMODITY_CATEGORY_ID(i),
				G_B_T_VEHICLE_TYPE_ID(i),
				G_B_T_BILLABLE_QUANTITY(i),
				G_B_T_BILLABLE_UOM(i),
				G_B_T_BILLABLE_BASIS(i)
				);
	END IF;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Bulk_Insert_Temp');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        ROLLBACK TO Bulk_Insert_Temp;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Bulk_Insert_Temp',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Bulk_Insert_Temp');

END Bulk_Insert_Temp;



PROCEDURE Bulk_Insert(
	x_return_status OUT NOCOPY Varchar2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Bulk_Insert','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;





        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Bulk_Insert');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Bulk_Insert',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Bulk_Insert');

END Bulk_Insert;


PROCEDURE Get_Cost_Allocation_Parameters(
	x_cost_allocation_parameters IN OUT NOCOPY TL_allocation_params_rec_type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_return_status VARCHAR2(1);
	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	CURSOR get_cost_alloc_params IS
	SELECT TL_PRIN_COST_ALLOC_BASIS,TL_DISTANCE_ALLOC_BASIS,TL_STOP_COST_ALLOC_BASIS
	FROM WSH_GLOBAL_PARAMETERS;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Cost_Allocation_Parameters','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	OPEN get_cost_alloc_params;
	FETCH get_cost_alloc_params
	INTO 	x_cost_allocation_parameters.principal_alloc_basis,
		x_cost_allocation_parameters.distance_alloc_method,
		x_cost_allocation_parameters.tl_stop_alloc_method;

	IF get_cost_alloc_params%NOTFOUND
	THEN

		FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'Get_Cost_Allocation_Parameters',
			p_exc=>'g_tl_fetch_alloc_param_fail');

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_fetch_alloc_param_fail;
	END IF;

	IF (   (x_cost_allocation_parameters.principal_alloc_basis IS NULL)
	    OR ((x_cost_allocation_parameters.principal_alloc_basis <> FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND (x_cost_allocation_parameters.principal_alloc_basis <> FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS))
	    OR (x_cost_allocation_parameters.distance_alloc_method IS NULL)
	    OR ((x_cost_allocation_parameters.distance_alloc_method <> FTE_RTG_GLOBALS.G_CA_DIRECT_DISTANCE )
	    	AND (x_cost_allocation_parameters.distance_alloc_method <> FTE_RTG_GLOBALS.G_CA_TOTAL_DISTANCE ))
	    OR (x_cost_allocation_parameters.tl_stop_alloc_method IS NULL)
	    OR ( (x_cost_allocation_parameters.tl_stop_alloc_method <> FTE_RTG_GLOBALS.G_CA_PICKUP_STOP)
	       AND (x_cost_allocation_parameters.tl_stop_alloc_method <> FTE_RTG_GLOBALS.G_CA_DELIVERY_STOP))

	    )
	THEN

		FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'Get_Cost_Allocation_Parameters',
			p_exc=>'g_tl_fetch_alloc_param_fail');

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_fetch_alloc_param_fail;

	END IF;


	--x_cost_allocation_parameters.distance_alloc_method:=FTE_RTG_GLOBALS.G_CA_TOTAL_DISTANCE;
	--x_cost_allocation_parameters.tl_stop_alloc_method:=FTE_RTG_GLOBALS.G_CA_PICKUP_STOP;
	--x_cost_allocation_parameters.output_type:='T';
	--x_cost_allocation_parameters.comparison_request_id:=102;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_cost_allocation_parameters.principal_alloc_basis='||x_cost_allocation_parameters.principal_alloc_basis);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_cost_allocation_parameters.distance_alloc_method='||x_cost_allocation_parameters.distance_alloc_method);
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_cost_allocation_parameters.tl_stop_alloc_method='||x_cost_allocation_parameters.tl_stop_alloc_method);

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Cost_Allocation_Parameters');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fetch_alloc_param_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Cost_Allocation_Parameters',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fetch_alloc_param_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Cost_Allocation_Parameters');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Cost_Allocation_Parameters',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Cost_Allocation_Parameters');

END Get_Cost_Allocation_Parameters;



PROCEDURE DisplayCostRec(
	p_output_cost_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type) IS


	l_warning_count 	NUMBER:=0;
BEGIN



	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'FREIGHT_REC Freight_cost_id:'||p_output_cost_rec.freight_cost_id||
	'Freight_Cost_type:'||p_output_cost_rec.freight_cost_type_id||
	' UnitAmount:'||p_output_cost_rec.unit_amount||
	'Calculation_Method:'||p_output_cost_rec.calculation_method||
	'UOM:'||p_output_cost_rec.uom||
	'Quantity:'||p_output_cost_rec.quantity||
	'Total_Amount:'||p_output_cost_rec.total_amount||
	' CurrencyCode:'||p_output_cost_rec.currency_code||
	'Conversion_Date:'||p_output_cost_rec.conversion_date||
	' ConversionRate:'||p_output_cost_rec.conversion_rate||
	' Conversion TypeCode:'||p_output_cost_rec.conversion_type_code||
	' TripID:'||p_output_cost_rec.trip_id||
	' StopID:'||p_output_cost_rec.stop_id||
	' DeliveryID:'||p_output_cost_rec.delivery_id||
	' Delivery LegID:'||p_output_cost_rec.delivery_leg_id||
	' Delivery detailID:'||p_output_cost_rec.delivery_detail_id||
	' requestID:'||p_output_cost_rec.request_id||
	' line typecode:'||p_output_cost_rec.line_type_code||
	' Charge unitvalue:'||p_output_cost_rec.charge_unit_value||
	' Charge SourceCode:'||p_output_cost_rec.charge_source_code||
	' EstiamtedFlag:'||p_output_cost_rec.estimated_flag||
	' Comparison RequestID:'||p_output_cost_rec.comparison_request_id||
	' LaneID:'||p_output_cost_rec.lane_id||
	' ScheduleID:'||p_output_cost_rec.schedule_id||
	' Move to mainFlag:'||p_output_cost_rec.moved_to_main_flag);


END DisplayCostRec;

--	Caches in all the freight codes so that they dont have to be queried
--	repeatedly when the price records are created

PROCEDURE Initialize_Freight_Codes(
	x_return_status OUT NOCOPY Varchar2)IS

	l_freight_code_rec	TL_freight_code_rec_type;
	i NUMBER;

	CURSOR	get_fc_price_codes(c_name IN VARCHAR2) IS
	SELECT f.freight_cost_type_id
	FROM WSH_FREIGHT_COST_TYPES f
	WHERE f.freight_cost_type_code='FTEPRICE' AND f.name=c_name;

	CURSOR get_fc_charge_codes(c_name IN VARCHAR2) IS
	SELECT f.freight_cost_type_id
	FROM WSH_FREIGHT_COST_TYPES f
	WHERE f.freight_cost_type_code='FTECHARGE' AND f.name=c_name;

	CURSOR get_fc_summary_codes(c_name IN VARCHAR2) IS
	SELECT f.freight_cost_type_id
	FROM WSH_FREIGHT_COST_TYPES f
	WHERE f.freight_cost_type_code='FTESUMMARY'AND f.name=c_name;

	CURSOR get_fc_discount_codes(c_name IN VARCHAR2) IS
	SELECT f.freight_cost_type_id
	FROM WSH_FREIGHT_COST_TYPES f
	WHERE f.freight_cost_type_code='FTEDISCOUNT'AND f.name=c_name;


l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Initialize_Freight_Codes','start');
	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	g_tl_freight_codes(C_LOADED_DISTANCE_RT):=
		l_freight_code_rec;
	g_tl_freight_codes(C_LOADED_DISTANCE_RT).name:=
		'LOADED DISTANCE RATE';

	g_tl_freight_codes(C_LOADED_DISTANCE_RT).summary_name:=
		'LOADED DISTANCE RATE SUMMARY';

	g_tl_freight_codes(C_UNLOADED_DISTANCE_RT):=l_freight_code_rec;

	g_tl_freight_codes(C_UNLOADED_DISTANCE_RT).name:=
		'UNLOADED DISTANCE RATE';

	g_tl_freight_codes(C_UNLOADED_DISTANCE_RT).summary_name:=
		'UNLOADED DISTANCE RATE SUMMARY';

	g_tl_freight_codes(C_UNIT_WEIGHT_RT):=l_freight_code_rec;
	g_tl_freight_codes(C_UNIT_WEIGHT_RT).name:='UNIT WEIGHT RATE';

	g_tl_freight_codes(C_UNIT_WEIGHT_RT).summary_name:=
		'UNIT WEIGHT RATE SUMMARY';

	g_tl_freight_codes(C_UNIT_VOLUME_RT):=l_freight_code_rec;
	g_tl_freight_codes(C_UNIT_VOLUME_RT).name:='UNIT VOLUME RATE';

	g_tl_freight_codes(C_UNIT_VOLUME_RT).summary_name:=
		'UNIT VOLUME RATE SUMMARY';

	g_tl_freight_codes(C_UNIT_CONTAINER_RT):=l_freight_code_rec;
	-- g_tl_freight_codes(C_UNIT_CONTAINER_RT).name:='UNIT CONTAINER RATE';
	g_tl_freight_codes(C_UNIT_CONTAINER_RT).name:='UNIT PIECE RATE';

	-- g_tl_freight_codes(C_UNIT_CONTAINER_RT).summary_name:=
	-- 	'UNIT CONTAINER RATE SUMMARY';
	g_tl_freight_codes(C_UNIT_CONTAINER_RT).summary_name:=
		'UNIT PIECE RATE SUMMARY';


	g_tl_freight_codes(C_UNIT_PALLET_RT):=l_freight_code_rec;
	g_tl_freight_codes(C_UNIT_PALLET_RT).name:='UNIT PALLET RATE';

	g_tl_freight_codes(C_UNIT_PALLET_RT).summary_name:=
		'UNIT PALLET RATE SUMMARY';

	g_tl_freight_codes(C_TIME_RT):=l_freight_code_rec;
	g_tl_freight_codes(C_TIME_RT).name:='TIME RATE';
	g_tl_freight_codes(C_TIME_RT).summary_name:='TIME RATE SUMMARY';

	g_tl_freight_codes(C_FLAT_RT):=l_freight_code_rec;
	g_tl_freight_codes(C_FLAT_RT).name:='FLAT RATE';
	g_tl_freight_codes(C_FLAT_RT).summary_name:='FLAT RATE SUMMARY';


	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISTANCE_RT):=l_freight_code_rec;

	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISTANCE_RT).name:=
		'CONTINUOUS MOVE DISTANCE RATE';

	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISTANCE_RT).summary_name:=
		'CONTINUOUS MOVE DISTANCE RATE SUMMARY';

	-- g_tl_freight_codes(C_MIN_DISTANCE_CHRG):=l_freight_code_rec;
	-- g_tl_freight_codes(C_MIN_DISTANCE_CHRG).name:='C_MIN_DISTANCE_CHRG';

	-- g_tl_freight_codes(C_MIN_DISTANCE_CHRG).summary_name:=
        --      'C_MIN_DISTANCE_CHRG_SUM';

	-- g_tl_freight_codes(C_MIN_UNIT_CHRG):=l_freight_code_rec;
	-- g_tl_freight_codes(C_MIN_UNIT_CHRG).name:='C_MIN_UNIT_CHRG';
	-- g_tl_freight_codes(C_MIN_UNIT_CHRG).summary_name:='C_MIN_UNIT_CHRG_SUM';


	-- g_tl_freight_codes(C_MIN_TIME_CHRG):=l_freight_code_rec;
	-- g_tl_freight_codes(C_MIN_TIME_CHRG).name:='C_MIN_TIME_CHRG';
	-- g_tl_freight_codes(C_MIN_TIME_CHRG).summary_name:='C_MIN_TIME_CHRG_SUM';

	g_tl_freight_codes(C_STOP_OFF_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_STOP_OFF_CHRG).name:='STOP OFF CHARGE';
	g_tl_freight_codes(C_STOP_OFF_CHRG).summary_name:='STOP OFF CHARGE SUMMARY';

	g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG).name:='OUT OF ROUTE CHARGE';

	g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG).summary_name:=
		'OUT OF ROUTE CHARGE SUMMARY';

	-- g_tl_freight_codes(C_DOCUMENT_CHRG):=l_freight_code_rec;
	-- g_tl_freight_codes(C_DOCUMENT_CHRG).name:='C_DOCUMENT_CHRG';
	-- g_tl_freight_codes(C_DOCUMENT_CHRG).summary_name:='C_DOCUMENT_CHRG_SUM';

	g_tl_freight_codes(C_HANDLING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_HANDLING_CHRG).name:='HANDLING CHARGE';
	g_tl_freight_codes(C_HANDLING_CHRG).summary_name:='HANDLING CHARGE SUMMARY';

	g_tl_freight_codes(C_LOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_LOADING_CHRG).name:='LOADING CHARGE';
	g_tl_freight_codes(C_LOADING_CHRG).summary_name:='LOADING CHARGE SUMMARY';

	g_tl_freight_codes(C_AST_LOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_AST_LOADING_CHRG).name:='ASSISTED LOADING CHARGE';

	g_tl_freight_codes(C_AST_LOADING_CHRG).summary_name:=
		'ASSISTED LOADING CHARGE SUMMARY';

	g_tl_freight_codes(C_UNLOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_UNLOADING_CHRG).name:='UNLOADING CHARGE';

	g_tl_freight_codes(C_UNLOADING_CHRG).summary_name:=
		'UNLOADING CHARGE SUMMARY';

	g_tl_freight_codes(C_AST_UNLOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_AST_UNLOADING_CHRG).name:='ASSISTED UNLOADING CHARGE';

	g_tl_freight_codes(C_AST_UNLOADING_CHRG).summary_name:=
		'ASSISTED UNLOADING CHARGE SUMMARY';

	g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG):=l_freight_code_rec;

	g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG).name:=
		'WEEKEND LAYOVER CHARGE';

	g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG).summary_name:=
		'WEEKEND LAYOVER CHARGE SUMMARY';

	g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG):=l_freight_code_rec;

	g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG).name:=
		'WEEKDAY LAYOVER CHARGE';

	g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG).summary_name:=
		'WEEKDAY LAYOVER CHARGE SUMMARY';

	g_tl_freight_codes(C_ORIGIN_SURCHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_ORIGIN_SURCHRG).name:='ORIGIN SURCHARGE';

	g_tl_freight_codes(C_ORIGIN_SURCHRG).summary_name:=
		'ORIGIN SURCHARGE SUMMARY';

	g_tl_freight_codes(C_DESTINATION_SURCHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_DESTINATION_SURCHRG).name:='DESTINATION SURCHARGE';

	g_tl_freight_codes(C_DESTINATION_SURCHRG).summary_name:=
		'DESTINATION SURCHARGE SUMMARY';

	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT):=l_freight_code_rec;

	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT).name:=
		'CONTINUOUS MOVE DISCOUNT';
	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT).summary_name:=
		'CONTINUOUS MOVE DISCOUNT';

	g_tl_freight_codes(F_LOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(F_LOADING_CHRG).name:='FACILITY LOADING CHARGE';
	g_tl_freight_codes(F_LOADING_CHRG).summary_name:='FACILITY LOADING CHARGE SUMMARY';

	g_tl_freight_codes(F_AST_LOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(F_AST_LOADING_CHRG).name:='FACILITY ASSISTED LOADING CHARGE';

	g_tl_freight_codes(F_AST_LOADING_CHRG).summary_name:=
		'FACILITY ASSISTED LOADING CHARGE SUMMARY';

	g_tl_freight_codes(F_UNLOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(F_UNLOADING_CHRG).name:='FACILITY UNLOADING CHARGE';

	g_tl_freight_codes(F_UNLOADING_CHRG).summary_name:=
		'FACILITY UNLOADING CHARGE SUMMARY';

	g_tl_freight_codes(F_AST_UNLOADING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(F_AST_UNLOADING_CHRG).name:='FACILITY ASSISTED UNLOADING CHARGE';

	g_tl_freight_codes(F_AST_UNLOADING_CHRG).summary_name:=
		'FACILITY ASSISTED UNLOADING CHARGE SUMMARY';

	g_tl_freight_codes(F_HANDLING_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(F_HANDLING_CHRG).name:='FACILITY HANDLING CHARGE';
	g_tl_freight_codes(F_HANDLING_CHRG).summary_name:='FACILITY HANDLING CHARGE SUMMARY';


	g_tl_freight_codes(C_FUEL_CHRG):=l_freight_code_rec;
	g_tl_freight_codes(C_FUEL_CHRG).name:='FUEL SURCHARGE';
	g_tl_freight_codes(C_FUEL_CHRG).summary_name:='FUEL SURCHARGE SUMMARY';


	g_tl_freight_codes(C_SUMMARY):=l_freight_code_rec;
	g_tl_freight_codes(C_SUMMARY).name:='SUMMARY';
	g_tl_freight_codes(C_SUMMARY).summary_name:='SUMMARY';

	i:=g_tl_freight_codes.FIRST;
	WHILE (i IS NOT NULL)
	LOOP

		OPEN get_fc_price_codes(g_tl_freight_codes(i).name);
		FETCH get_fc_price_codes INTO
		g_tl_freight_codes(i).fte_price_code_id;
		CLOSE get_fc_price_codes;


		OPEN get_fc_charge_codes(g_tl_freight_codes(i).name);
		FETCH get_fc_charge_codes INTO
		g_tl_freight_codes(i).fte_charge_code_id;
		CLOSE get_fc_charge_codes;


		IF (g_tl_freight_codes(i).summary_name IS NOT NULL)
		THEN
			OPEN
			get_fc_summary_codes(g_tl_freight_codes(i).summary_name)
			;
			FETCH get_fc_summary_codes INTO
			g_tl_freight_codes(i).fte_summary_code_id;
			CLOSE get_fc_summary_codes;
		END IF;
		i:=g_tl_freight_codes.NEXT(i);

	END LOOP;

	OPEN get_fc_discount_codes(g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT).name);
	FETCH get_fc_discount_codes INTO g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT).fte_summary_code_id;
	CLOSE get_fc_discount_codes;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Freight_Codes');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Initialize_Freight_Codes',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Initialize_Freight_Codes');



END Initialize_Freight_Codes;


--Multiplies all the charges by the discount factor

PROCEDURE Scale_Trip_Charges(
	p_discount IN NUMBER,
	x_trip_charges_rec IN OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2) IS

	l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Scale_Trip_Charges','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_trip_charges_rec.base_dist_load_chrg:=x_trip_charges_rec.base_dist_load_chrg *p_discount;
	x_trip_charges_rec.base_dist_load_unit_chrg:=x_trip_charges_rec.base_dist_load_unit_chrg *p_discount;
	x_trip_charges_rec.base_dist_unload_chrg:=x_trip_charges_rec.base_dist_unload_chrg *p_discount;
	x_trip_charges_rec.base_dist_unload_unit_chrg:=x_trip_charges_rec.base_dist_unload_unit_chrg *p_discount;
	x_trip_charges_rec.base_unit_chrg:=x_trip_charges_rec.base_unit_chrg *p_discount;
	x_trip_charges_rec.base_unit_unit_chrg:=x_trip_charges_rec.base_unit_unit_chrg *p_discount;
	x_trip_charges_rec.base_time_chrg:=x_trip_charges_rec.base_time_chrg *p_discount;
	x_trip_charges_rec.base_time_unit_chrg:=x_trip_charges_rec.base_time_unit_chrg *p_discount;
	x_trip_charges_rec.base_flat_chrg:=x_trip_charges_rec.base_flat_chrg *p_discount;
	x_trip_charges_rec.stop_off_chrg:=x_trip_charges_rec.stop_off_chrg *p_discount;
	x_trip_charges_rec.out_of_route_chrg:=x_trip_charges_rec.out_of_route_chrg *p_discount;
	x_trip_charges_rec.document_chrg:=x_trip_charges_rec.document_chrg *p_discount;
	x_trip_charges_rec.handling_chrg:=x_trip_charges_rec.handling_chrg *p_discount;

	x_trip_charges_rec.fuel_chrg:=x_trip_charges_rec.fuel_chrg *p_discount;

FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Scale_Trip_Charges');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Scale_Trip_Charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Scale_Trip_Charges');


END Scale_Trip_Charges;


--Multiplies all the stop charges by the discount factor

PROCEDURE Scale_Stop_Charges(
	p_discount IN NUMBER,
	x_stop_charges_rec IN OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_OUTPUT_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Scale_Stop_Charges','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_stop_charges_rec.weekday_layover_chrg :=x_stop_charges_rec.weekday_layover_chrg *p_discount;
	x_stop_charges_rec.weekend_layover_chrg :=x_stop_charges_rec.weekend_layover_chrg *p_discount;
	x_stop_charges_rec.loading_chrg :=x_stop_charges_rec.loading_chrg *p_discount;
	x_stop_charges_rec.ast_loading_chrg :=x_stop_charges_rec.ast_loading_chrg *p_discount;
	x_stop_charges_rec.unloading_chrg :=x_stop_charges_rec.unloading_chrg *p_discount;
	x_stop_charges_rec.ast_unloading_chrg :=x_stop_charges_rec.ast_unloading_chrg *p_discount;
	x_stop_charges_rec.origin_surchrg :=x_stop_charges_rec.origin_surchrg *p_discount;
	x_stop_charges_rec.destination_surchrg :=x_stop_charges_rec.destination_surchrg *p_discount;
	x_stop_charges_rec.fac_loading_chrg :=x_stop_charges_rec.fac_loading_chrg *p_discount;
	x_stop_charges_rec.fac_ast_loading_chrg :=x_stop_charges_rec.fac_ast_loading_chrg *p_discount;
	x_stop_charges_rec.fac_unloading_chrg :=x_stop_charges_rec.fac_unloading_chrg *p_discount;
	x_stop_charges_rec.fac_ast_unloading_chrg :=x_stop_charges_rec.fac_ast_unloading_chrg *p_discount;
	x_stop_charges_rec.fac_handling_chrg :=x_stop_charges_rec.fac_handling_chrg *p_discount;

FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Scale_Stop_Charges');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Scale_Stop_Charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Scale_Stop_Charges');


END Scale_Stop_Charges;





--Determines the fraction of the stop level loading(carrier,ast,fac) charge to
--be allocated to a delivery leg

PROCEDURE Get_Loading_Fraction(
	p_dleg_rec IN FTE_TL_CACHE.TL_delivery_leg_rec_type,
	p_stop_rec IN FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE,
	p_basis IN NUMBER,
	p_alloc_params TL_allocation_params_rec_type,
	x_fraction IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Loading_Fraction','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_fraction:=0;

	IF ((p_basis =  FTE_RTG_GLOBALS.G_WEIGHT_BASIS) AND
	(p_stop_rec.pickup_weight>0))
	THEN
		x_fraction:=p_dleg_rec.weight/p_stop_rec.pickup_weight;

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_VOLUME_BASIS)
	AND(p_stop_rec.pickup_volume>0))
	THEN
		x_fraction:=p_dleg_rec.volume/p_stop_rec.pickup_volume;

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_CONTAINER_BASIS)AND
	(p_stop_rec.pickup_containers>0))
	THEN
		x_fraction:=p_dleg_rec.containers/p_stop_rec.pickup_containers;

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_PALLET_BASIS)
	AND(p_stop_rec.pickup_pallets>0))
	THEN
		x_fraction:=p_dleg_rec.pallets/p_stop_rec.pickup_pallets;

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_TIME_BASIS) OR (p_basis =
	FTE_RTG_GLOBALS.G_FLAT_BASIS))
	THEN
	--	if basis is not wt/vol/container/pallet then use cost allocation
	--basis(Step 3 of CA algorithm)

		IF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND(p_stop_rec.pickup_weight>0))
		THEN
			x_fraction:=p_dleg_rec.weight/p_stop_rec.pickup_weight;

		ELSIF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND(p_stop_rec.pickup_volume>0))
		THEN

			x_fraction:=p_dleg_rec.volume/p_stop_rec.pickup_volume;

		ELSE

			x_fraction:=0;
		END IF;


	ELSE
		x_fraction:=0;
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis;


	END IF;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Loading_Fraction');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Loading_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_invalid_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Loading_Fraction');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Loading_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Loading_Fraction');



END  Get_Loading_Fraction;

--Determines the fraction of the stop level loading(carrier,ast,fac) charge to
--be allocated to a delivery leg. As per Step 1 and Step 3 of the Cost
--allocation algorithm

PROCEDURE Get_Unloading_Fraction(
	p_dleg_rec IN FTE_TL_CACHE.TL_delivery_leg_rec_type,
	p_stop_rec IN FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE,
	p_basis IN NUMBER,
	p_alloc_params TL_allocation_params_rec_type,
	x_fraction IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Unloading_Fraction','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_fraction:=0;
	IF ((p_basis =  FTE_RTG_GLOBALS.G_WEIGHT_BASIS)
	AND(p_stop_rec.dropoff_weight>0))
	THEN
		x_fraction:=p_dleg_rec.weight/p_stop_rec.dropoff_weight;

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_VOLUME_BASIS)
	AND(p_stop_rec.dropoff_volume>0))
	THEN
		x_fraction:=p_dleg_rec.volume/p_stop_rec.dropoff_volume;

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_CONTAINER_BASIS)
	AND(p_stop_rec.dropoff_containers>0))
	THEN
		x_fraction:=p_dleg_rec.containers/p_stop_rec.dropoff_containers;

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_PALLET_BASIS)
	AND(p_stop_rec.dropoff_pallets>0))
	THEN
		x_fraction:=p_dleg_rec.pallets/p_stop_rec.dropoff_pallets;

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_TIME_BASIS) OR (p_basis =
		FTE_RTG_GLOBALS.G_FLAT_BASIS))
	THEN
		--Step 3 of the CA algorithm

		IF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND(p_stop_rec.dropoff_weight>0))
		THEN
			x_fraction:=p_dleg_rec.weight/p_stop_rec.dropoff_weight;

		ELSIF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND(p_stop_rec.dropoff_volume>0))
		THEN

			x_fraction:=p_dleg_rec.volume/p_stop_rec.dropoff_volume;

		ELSE

			x_fraction:=0;
		END IF;
	ELSE
		x_fraction:=0;
		--throw an exception
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis;



	END IF;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Unloading_Fraction');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Unloading_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_invalid_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Unloading_Fraction');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Unloading_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Unloading_Fraction');



END  Get_Unloading_Fraction;



--Determines the fraction of the stop level loading+unloading (only used for fac handling) charge to
--be allocated to a delivery leg. As per Step 1 and Step 3 of the Cost
--allocation algorithm
--4045314

PROCEDURE Get_Total_Stop_Fraction(
	p_dleg_rec IN FTE_TL_CACHE.TL_delivery_leg_rec_type,
	p_stop_rec IN FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE,
	p_basis IN NUMBER,
	p_alloc_params TL_allocation_params_rec_type,
	x_fraction IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Total_Stop_Fraction','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_fraction:=0;
	IF ((p_basis =  FTE_RTG_GLOBALS.G_WEIGHT_BASIS)
	AND((p_stop_rec.dropoff_weight+p_stop_rec.pickup_weight)>0))
	THEN
		x_fraction:=p_dleg_rec.weight/(p_stop_rec.dropoff_weight+p_stop_rec.pickup_weight);

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_VOLUME_BASIS)
	AND((p_stop_rec.dropoff_volume+p_stop_rec.pickup_volume)>0))
	THEN
		x_fraction:=p_dleg_rec.volume/(p_stop_rec.dropoff_volume+p_stop_rec.pickup_volume);

	ELSIF ((p_basis =FTE_RTG_GLOBALS.G_CONTAINER_BASIS)
	AND((p_stop_rec.dropoff_containers+p_stop_rec.pickup_containers)>0))
	THEN
		x_fraction:=p_dleg_rec.containers/(p_stop_rec.dropoff_containers+p_stop_rec.pickup_containers);

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_PALLET_BASIS)
	AND((p_stop_rec.dropoff_pallets+p_stop_rec.pickup_pallets)>0))
	THEN
		x_fraction:=p_dleg_rec.pallets/(p_stop_rec.dropoff_pallets+p_stop_rec.pickup_pallets);

	ELSIF ((p_basis = FTE_RTG_GLOBALS.G_TIME_BASIS) OR (p_basis =
		FTE_RTG_GLOBALS.G_FLAT_BASIS))
	THEN
		--Step 3 of the CA algorithm

		IF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND((p_stop_rec.dropoff_weight+p_stop_rec.pickup_weight)>0))
		THEN
			x_fraction:=p_dleg_rec.weight/(p_stop_rec.dropoff_weight+p_stop_rec.pickup_weight);

		ELSIF((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND((p_stop_rec.dropoff_volume+p_stop_rec.pickup_volume)>0))
		THEN

			x_fraction:=p_dleg_rec.volume/(p_stop_rec.dropoff_volume+p_stop_rec.pickup_volume);

		ELSE

			x_fraction:=0;
		END IF;
	ELSE
		x_fraction:=0;
		--throw an exception
		--raise FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis;



	END IF;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Fraction');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Stop_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_invalid_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Fraction');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Stop_Fraction',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Fraction');



END  Get_Total_Stop_Fraction;


--Populates 2 hash structures so that the stop cache records and the stop charge
--records can be accesed using the stop_id
--The hashes hold index into the stop cache and the stop charges table

PROCEDURE Create_Stop_Hashes(
	p_trip_index IN NUMBER,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_stop_input_hash IN OUT NOCOPY DBMS_UTILITY.NUMBER_ARRAY,
	x_stop_output_hash IN OUT NOCOPY DBMS_UTILITY.NUMBER_ARRAY,
	x_return_status OUT NOCOPY Varchar2) IS

i NUMBER;
l_stop_index_first NUMBER;
l_stop_index_last NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Stop_Hashes','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--Create hash to look up stop charges from stop id
	l_stop_index_first:=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).stop_reference;
	IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
	THEN

		l_stop_index_last:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1).stop_reference;

	ELSE

		l_stop_index_last:=FTE_TL_CACHE.g_tl_trip_stop_rows.LAST+1;

	END IF;

	i:=p_stop_charges_tab.FIRST;

	WHILE(i IS NOT NULL )
	LOOP
		x_stop_output_hash(p_stop_charges_tab(i).stop_id):=i;

		i:=p_stop_charges_tab.NEXT(i);
	END LOOP;


	--Create hash to look up cached stops from stop id

	i:=l_stop_index_first;

	WHILE(( FTE_TL_CACHE.g_tl_trip_stop_rows.EXISTS(i)) AND
	(FTE_TL_CACHE.g_tl_trip_stop_rows(i).trip_id=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i <l_stop_index_last))
	LOOP
		x_stop_input_hash(FTE_TL_CACHE.g_tl_trip_stop_rows(i).stop_id):=
			i;

		i:=i+1;
	END LOOP;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Hashes');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Hashes',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Hashes');


END Create_Stop_Hashes;

-- Allocates stop-off charge assigned to a stop to the delivery legs using that
--Stop
--As per Step 3 of the cost allocation algorithm

PROCEDURE Assign_StopOff_Charge(
	p_stopoff_charge IN NUMBER,p_alloc_params IN TL_allocation_params_rec_type,
	p_pickup_stop_rec IN FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE,
	p_dropoff_stop_rec IN FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE,
	p_dleg_rec IN FTE_TL_CACHE.TL_delivery_leg_rec_type,
	x_dleg_alloc_rec IN OUT NOCOPY TL_dleg_alloc_rec_type,
	x_return_status OUT NOCOPY Varchar2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Assign_StopOff_Charge','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_dleg_alloc_rec.stop_off_chrg:=0;

	IF ((p_alloc_params.tl_stop_alloc_method=FTE_RTG_GLOBALS.G_CA_PICKUP_STOP) AND
	(p_pickup_stop_rec.pickup_weight>0))
	THEN
		IF ((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND(p_pickup_stop_rec.pickup_weight>0))
		THEN
			x_dleg_alloc_rec.stop_off_chrg:=
				p_stopoff_charge*p_dleg_rec.weight/
				p_pickup_stop_rec.pickup_weight;
		ELSIF ((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND(p_pickup_stop_rec.pickup_volume>0))
		THEN
			x_dleg_alloc_rec.stop_off_chrg:=
				p_stopoff_charge*p_dleg_rec.volume/
				p_pickup_stop_rec.pickup_volume;

		END IF;

	ELSIF ((p_alloc_params.tl_stop_alloc_method=FTE_RTG_GLOBALS.G_CA_DELIVERY_STOP) AND
	(p_dropoff_stop_rec.dropoff_weight>0))
	THEN
		IF ((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND(p_dropoff_stop_rec.dropoff_weight>0))
		THEN
			x_dleg_alloc_rec.stop_off_chrg:=
				p_stopoff_charge*p_dleg_rec.weight/
					p_dropoff_stop_rec.dropoff_weight;
		ELSIF ((p_alloc_params.principal_alloc_basis=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND(p_dropoff_stop_rec.dropoff_volume>0))
		THEN
			x_dleg_alloc_rec.stop_off_chrg:=
			p_stopoff_charge*p_dleg_rec.volume/
				p_dropoff_stop_rec.dropoff_volume;
		END IF;


	END IF;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Assign_StopOff_Charge');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Assign_StopOff_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Assign_StopOff_Charge');



END Assign_StopOff_Charge;

--Divides the Stop-off charge evenly to get a per stop charge
--Step 2 of CA algorithm

PROCEDURE Get_StopOff_Chrg_Per_Stop(
	p_stopoff_charge IN NUMBER,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	p_alloc_params IN TL_allocation_params_rec_type,
	p_stop_input_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_stop_output_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	x_stopoff_charge IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

l_stop_count NUMBER;
i NUMBER;

l_cache_index NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_StopOff_Chrg_Per_Stop','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	i:=p_stop_charges_tab.FIRST;
	l_stop_count:=0;
	WHILE(i IS NOT NULL )
	LOOP

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Loop stop id'||p_stop_charges_tab(i).stop_id|| ' i'||i);

		l_cache_index:=p_stop_input_hash(p_stop_charges_tab(i).stop_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' cache index'||l_cache_index);

		IF ((p_alloc_params.tl_stop_alloc_method=FTE_RTG_GLOBALS.G_CA_PICKUP_STOP) AND
		(FTE_TL_CACHE.g_tl_trip_stop_rows(l_cache_index).pickup_weight>
		0))
		THEN

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Pickup');
			l_stop_count:=l_stop_count+1;

		ELSIF((p_alloc_params.tl_stop_alloc_method=FTE_RTG_GLOBALS.G_CA_DELIVERY_STOP)
		AND
		(FTE_TL_CACHE.g_tl_trip_stop_rows(l_cache_index).dropoff_weight>
		0))
		THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Dropoff');
			l_stop_count:=l_stop_count+1;

		END IF;


		i:=p_stop_charges_tab.NEXT(i);
	END LOOP;

	IF (l_stop_count>0)
	THEN
		x_stopoff_charge:=p_stopoff_charge/l_stop_count;
	ELSE
		x_stopoff_charge:=0;
	END IF;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_StopOff_Chrg_Per_Stop');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_StopOff_Chrg_Per_Stop',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_StopOff_Chrg_Per_Stop');



END   Get_StopOff_Chrg_Per_Stop;


--Calculates  the trip level carrier handling charge for a given delivery leg

PROCEDURE Allocate_Handling_Charges(
	p_trip_index IN NUMBER,
	p_dleg_row IN FTE_TL_CACHE.TL_delivery_leg_rec_type,
	p_trip_rec_charges IN FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_handling_chrg IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

	l_factor NUMBER;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Allocate_Handling_Charges','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_factor:=0;

	IF ((p_trip_rec_charges.handling_chrg_basis =
	FTE_RTG_GLOBALS.G_WEIGHT_BASIS )
	AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_weight>0))
	THEN
		l_factor:=p_dleg_row.weight/
			FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_weight;

	ELSIF((p_trip_rec_charges.handling_chrg_basis =
	FTE_RTG_GLOBALS.G_VOLUME_BASIS)
	AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_volume>0))
	THEN
		l_factor:=p_dleg_row.volume/
			FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_volume;


	ELSIF((p_trip_rec_charges.handling_chrg_basis =
	FTE_RTG_GLOBALS.G_CONTAINER_BASIS)
	AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).number_of_containers>0))
	THEN
		l_factor:=p_dleg_row.containers/
			FTE_TL_CACHE.g_tl_trip_rows(
			p_trip_index).number_of_containers;

	ELSIF((p_trip_rec_charges.handling_chrg_basis =
	FTE_RTG_GLOBALS.G_PALLET_BASIS)
	AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).number_of_pallets>0))
	THEN
		l_factor:=p_dleg_row.pallets/
			FTE_TL_CACHE.g_tl_trip_rows(
				p_trip_index).number_of_pallets;

	ELSIF (p_trip_rec_charges.handling_chrg_basis = FTE_RTG_GLOBALS.G_FLAT_BASIS)
	THEN
		IF ((p_cost_allocation_parameters.principal_alloc_basis =
		FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_weight>0))
		THEN
			l_factor:=p_dleg_row.weight/
				FTE_TL_CACHE.g_tl_trip_rows(
					p_trip_index).total_weight;

		ELSIF((p_cost_allocation_parameters.principal_alloc_basis =
		FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		AND(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).total_volume>0))
		THEN
			l_factor:=p_dleg_row.volume/
				FTE_TL_CACHE.g_tl_trip_rows(
					p_trip_index).total_volume;
		ELSE
			l_factor:=0;
		END IF;

	ELSE
		l_factor:=0;
	END IF;

	x_handling_chrg:=p_trip_rec_charges.handling_chrg*l_factor;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Allocate_Handling_Charges');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Allocate_Handling_Charges',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Allocate_Handling_Charges');



END Allocate_Handling_Charges;


--Allocates all loading/unloading/handling charges, stop-off charges as well as
--origin/destination charges
--to all the dlegs . As per Step 1,2,3 of the CA algorithm

PROCEDURE Alloc_Loading_Stopoff_To_Dlegs(
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN
	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	p_stop_input_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_stop_output_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	x_dleg_alloc_tab IN OUT NOCOPY TL_dleg_alloc_TAB_TYPE  ,
	x_return_status OUT NOCOPY Varchar2) IS

l_dleg_index_first NUMBER;
l_dleg_index_last NUMBER;

i NUMBER;


l_stop_level_charge NUMBER;

--Index to FTE_TL_CACHE.g_tl_trip_stop_rows/stop input hash
--Used for pickup/loading

l_pickup_stop_ip_index NUMBER;

--Index to the stop charges tab/stop output hash
--Used for pickup/loading

l_pickup_stop_op_index NUMBER;

--Index to FTE_TL_CACHE.g_tl_trip_stop_rows/stop input hash
--Used for dropoff/unloading

l_dropoff_stop_ip_index NUMBER;

--Index to the stop charges tab/stop output hash
--Used for dropoff/unloading

l_dropoff_stop_op_index NUMBER;


l_dleg_alloc_rec TL_dleg_alloc_rec_type;

l_fraction NUMBER;

l_stopoff_charge NUMBER;

l_fac_handling_chrg NUMBER;

l_fac_handling_currency VARCHAR2(30);


l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	 Get_StopOff_Chrg_Per_Stop(
	 	p_stopoff_charge=>	p_trip_charges_rec.stop_off_chrg,
	 	p_stop_charges_tab=>	p_stop_charges_tab,
	 	p_alloc_params=>	p_cost_allocation_parameters,
	 	p_stop_input_hash=>	p_stop_input_hash,
	 	p_stop_output_hash=>	p_stop_output_hash,
	 	x_stopoff_charge=>	l_stopoff_charge,
	 	x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_stpff_per_stop_fail;
	       END IF;
	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting indices for dleg');

	--get indexes for all the dlegs,stops belonging to the trip

	l_dleg_index_first:=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).delivery_leg_reference;

	IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
	THEN
		l_dleg_index_last:=
		FTE_TL_CACHE.g_tl_trip_rows(
			p_trip_index+1
		).delivery_leg_reference;


	ELSE
		l_dleg_index_last:=FTE_TL_CACHE.g_tl_delivery_leg_rows.LAST+1;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Done Getting indices for dleg');


	i:=l_dleg_index_first;
	WHILE (( FTE_TL_CACHE.g_tl_delivery_leg_rows.EXISTS(i)) AND
	(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).trip_id=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i< l_dleg_index_last))
	LOOP


		--Get reference to pickup/dropoff stop in input/output tables
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting indices for Stops,dleg index'||i);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting index for pickup op');

		l_pickup_stop_op_index:=
		 p_stop_output_hash(FTE_TL_CACHE.g_tl_delivery_leg_rows(
				i).pickup_stop_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting indices for pickup ip');

		l_pickup_stop_ip_index:=p_stop_input_hash(
			FTE_TL_CACHE.g_tl_delivery_leg_rows(
				i).pickup_stop_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting indices for dropoff op');
		l_dropoff_stop_op_index:=
			p_stop_output_hash(FTE_TL_CACHE.g_tl_delivery_leg_rows(
			i).dropoff_stop_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Getting indices for dropoff ip');
		l_dropoff_stop_ip_index:=
			p_stop_input_hash(FTE_TL_CACHE.g_tl_delivery_leg_rows(
			i).dropoff_stop_id);

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Done Getting indices for Stops'||l_pickup_stop_op_index||':'||l_pickup_stop_ip_index||':'||l_dropoff_stop_op_index||':'||l_dropoff_stop_ip_index);
		-------LOADING Charges


		l_stop_level_charge:=
		 p_stop_charges_tab(l_pickup_stop_op_index).loading_chrg;

		 FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Got loading charges');

		Get_Loading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(l_pickup_stop_op_index).loading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_loading_chrg_fr_fail;
		       END IF;
		END IF;



		l_dleg_alloc_rec.loading_chrg:=l_stop_level_charge*l_fraction;

		----Assisted Loading

		l_stop_level_charge:=
		 p_stop_charges_tab(l_pickup_stop_op_index).ast_loading_chrg;




		Get_Loading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(
		 	l_pickup_stop_op_index).ast_loading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ast_ld_chrg_fr_fail;
		       END IF;
		END IF;

		l_dleg_alloc_rec.ast_loading_chrg:=
			l_stop_level_charge*l_fraction;

		----Facility  Loading

		l_stop_level_charge:=
		p_stop_charges_tab(l_pickup_stop_op_index).fac_loading_chrg;


		Get_Loading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(
		 	l_pickup_stop_op_index).fac_loading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ld_chrg_fr_fail;
		       END IF;
		END IF;



		l_dleg_alloc_rec.fac_loading_chrg:=
			l_stop_level_charge*l_fraction;
		l_dleg_alloc_rec.fac_loading_currency:=
			FTE_TL_CACHE.g_tl_trip_stop_rows(
				l_pickup_stop_ip_index).fac_currency;

		----Facility Assisted Loading

		l_stop_level_charge:=
		 p_stop_charges_tab(
		 	l_pickup_stop_op_index).fac_ast_loading_chrg;

		Get_Loading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(
		 		l_pickup_stop_op_index).fac_ast_loading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ast_ld_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.fac_ast_loading_chrg:=
			l_stop_level_charge*l_fraction;

		l_dleg_alloc_rec.fac_loading_currency:=
		FTE_TL_CACHE.g_tl_trip_stop_rows(
			l_pickup_stop_ip_index).fac_currency;


		---UNLOADING CHARGES


		l_stop_level_charge:=
		p_stop_charges_tab(l_dropoff_stop_op_index).unloading_chrg;

		Get_Unloading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(l_dropoff_stop_op_index).unloading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_unld_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.unloading_chrg:=
			l_stop_level_charge*l_fraction;


		----Assisted Unloading

		l_stop_level_charge:=
		p_stop_charges_tab(l_dropoff_stop_op_index).ast_unloading_chrg;


		Get_Unloading_Fraction(
			p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		 	p_basis=>	p_stop_charges_tab(
		 		l_dropoff_stop_op_index).ast_unloading_chrg_basis,
		 	p_alloc_params=>	p_cost_allocation_parameters,
		 	x_fraction=>	l_fraction,
		 	x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ast_unld_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.ast_unloading_chrg:=
			l_stop_level_charge*l_fraction;

		----Facility  Unloading

		l_stop_level_charge:=
		p_stop_charges_tab(l_dropoff_stop_op_index).fac_unloading_chrg;


		Get_Unloading_Fraction(
		 p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		 p_basis=>	p_stop_charges_tab(
		 	l_dropoff_stop_op_index).fac_unloading_chrg_basis,
		 p_alloc_params=>	p_cost_allocation_parameters,
		 x_fraction=>	l_fraction,
		 x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_unld_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.fac_unloading_chrg:=
			l_stop_level_charge*l_fraction;
		l_dleg_alloc_rec.fac_unloading_currency:=
		FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index
			).fac_currency;

		----Facility Assisted Unloading

		l_stop_level_charge:=
			p_stop_charges_tab(l_dropoff_stop_op_index
				).fac_ast_unloading_chrg;

		Get_Unloading_Fraction(
		 p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		 p_basis=>	p_stop_charges_tab(l_dropoff_stop_op_index
		 	).fac_ast_unloading_chrg_basis,
		 p_alloc_params=>	p_cost_allocation_parameters,
		 x_fraction=>	l_fraction,
		 x_return_status	=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ast_unld_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.fac_ast_unloading_chrg:=
			l_stop_level_charge*l_fraction;
		l_dleg_alloc_rec.fac_unloading_currency:=
			FTE_TL_CACHE.g_tl_trip_stop_rows(
		 l_dropoff_stop_ip_index).fac_currency;

		--StopOFF Charge


		 Assign_StopOff_Charge(
		  p_stopoff_charge=>	l_stopoff_charge,
		  p_alloc_params=>	p_cost_allocation_parameters ,
		  p_pickup_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		  p_dropoff_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		  p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		  x_dleg_alloc_rec=>	l_dleg_alloc_rec,
		  x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_assgn_stpff_chrg_fail;
		       END IF;
		END IF;


		--Facility Handling Charge


		--Handling charges at a stop are allocated to all picked up deliveries,
		--however if there are no picked up deliveries they are allocated to droppped of
		--deliveries. It is possible to have a delivery leg which has handling charges from
		--more than one facility. In which case the charge is in the currency of the
		--pickup facility
		--Added condition for volume 3958974
		--Above assumption is altered with 4045314 , the handling charge is allocated to
		--both pickup and dropoff deliveries at a stop

		l_fraction:=0;
		--IF
		--((FTE_TL_CACHE.g_tl_trip_stop_rows(
		--	l_pickup_stop_ip_index).pickup_weight>0) OR (FTE_TL_CACHE.g_tl_trip_stop_rows(
		--	l_pickup_stop_ip_index).pickup_volume>0))

		IF ((FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index).stop_type='PU')
		OR (FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index).stop_type='PD'))
		THEN
		--4045314
		 Get_Total_Stop_Fraction(
		     p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		     p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		     p_basis=>	p_stop_charges_tab(l_pickup_stop_op_index
		      ).fac_handling_chrg_basis,
		     p_alloc_params=>	p_cost_allocation_parameters,
		     x_fraction=>	l_fraction,
		     x_return_status	=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_hnd_chrg_pu_fr_fail;
		       END IF;
		END IF;


		    l_dleg_alloc_rec.fac_handling_chrg:=
			p_stop_charges_tab(l_pickup_stop_op_index
			).fac_handling_chrg*l_fraction;
		    l_dleg_alloc_rec.fac_handling_currency:=
			FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index)
			.fac_currency;
		END IF;

		--If at the dropoff stop no other deliveries are picked up
		--allocate the fac handling charge to his delivery
		--Added condition for volume 3958974
		--IF((FTE_TL_CACHE.g_tl_trip_stop_rows(
		--	l_dropoff_stop_ip_index).pickup_weight=0) AND (FTE_TL_CACHE.g_tl_trip_stop_rows(
		--	l_dropoff_stop_ip_index).pickup_volume=0))

		--4045314
		IF((FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index).stop_type='DO')
		OR ((FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index).stop_type='PD')))
		THEN

		    Get_Total_Stop_Fraction(
		    	p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		    	p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(
		    		l_dropoff_stop_ip_index),
		    	p_basis=>	p_stop_charges_tab(l_dropoff_stop_op_index
		    	).fac_handling_chrg_basis,
		    	p_alloc_params=>	p_cost_allocation_parameters,
		    	x_fraction=>	l_fraction,
		    	x_return_status	=>	l_return_status);

		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		    THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_fac_hnd_chrg_do_fr_fail;
			END IF;
		    END IF;


		    l_fac_handling_chrg:=
			p_stop_charges_tab(l_dropoff_stop_op_index
			 ).fac_handling_chrg*l_fraction;
		    l_fac_handling_currency:=
		     FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index
			).fac_currency;


		     IF (l_fac_handling_chrg > 0)
		     THEN

				l_fac_handling_chrg:=GL_CURRENCY_API.convert_amount(
					     l_fac_handling_currency,
					     l_dleg_alloc_rec.fac_handling_currency,
					     SYSDATE,
					     'Corporate',
					     l_fac_handling_chrg
					     );
		      END IF;

		      IF (l_fac_handling_chrg IS NULL)
		      THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;


		      END IF;

		      l_dleg_alloc_rec.fac_handling_chrg:=l_dleg_alloc_rec.fac_handling_chrg
		      	+l_fac_handling_chrg;


		END IF;





		--Handling Charge


		Allocate_Handling_Charges(
			p_trip_index=>	p_trip_index,
			p_dleg_row=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
			p_trip_rec_charges=>	p_trip_charges_rec,
			p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			x_handling_chrg=>	l_dleg_alloc_rec.handling_chrg,
			x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_hndl_chrg_fail;
		       END IF;
		END IF;


		--Origin Surcharge

		l_stop_level_charge:=
		 p_stop_charges_tab(l_pickup_stop_op_index).origin_surchrg;



		Get_Loading_Fraction(
		 p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_pickup_stop_ip_index),
		 p_basis=>	FTE_RTG_GLOBALS.G_FLAT_BASIS,
		 p_alloc_params=>	p_cost_allocation_parameters,
		 x_fraction=>	l_fraction,
		 x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_org_chrg_fr_fail;
		       END IF;
		END IF;


		l_dleg_alloc_rec.origin_surchrg:=
			l_stop_level_charge*l_fraction;

		--Destination Surcharge


		l_stop_level_charge:=
		 p_stop_charges_tab(l_dropoff_stop_op_index
		 	).destination_surchrg;



		Get_Unloading_Fraction(
		 p_dleg_rec=>	FTE_TL_CACHE.g_tl_delivery_leg_rows(i),
		 p_stop_rec=>	FTE_TL_CACHE.g_tl_trip_stop_rows(l_dropoff_stop_ip_index),
		 p_basis=>	FTE_RTG_GLOBALS.G_FLAT_BASIS,
		 p_alloc_params=>	p_cost_allocation_parameters,
		 x_fraction=>	l_fraction,
		 x_return_status	=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_dst_chrg_fr_fail;
		       END IF;
		END IF;

		l_dleg_alloc_rec.destination_surchrg:=
			l_stop_level_charge*l_fraction;


		--Add to output structure
		l_dleg_alloc_rec.delivery_leg_id:=
		 FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_leg_id;

		l_dleg_alloc_rec.delivery_id:=
		 FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_id;

		x_dleg_alloc_tab(FTE_TL_CACHE.g_tl_delivery_leg_rows(
			i).delivery_leg_id):=l_dleg_alloc_rec;

		i:=i+1;

	END LOOP;
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_stpff_per_stop_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_stpff_per_stop_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_loading_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_loading_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ast_ld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ast_ld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_ld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ast_ld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_ast_ld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_unld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_unld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ast_unld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ast_unld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_unld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_unld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_ast_unld_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_ast_unld_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_assgn_stpff_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_assgn_stpff_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_hnd_chrg_pu_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_hnd_chrg_pu_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_fac_hnd_chrg_do_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_fac_hnd_chrg_do_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_hndl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_alloc_hndl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_org_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_org_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_dst_chrg_fr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_dst_chrg_fr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Loading_Stopoff_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Loading_Stopoff_To_Dlegs');



END Alloc_Loading_Stopoff_To_Dlegs;


PROCEDURE Get_Top_Most_Dleg(
	p_child_dleg_id IN NUMBER,
	p_child_dleg_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_dleg_alloc_tab IN TL_dleg_alloc_TAB_TYPE,
	x_top_dleg_id OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2)
IS

l_parent_dleg_id NUMBER;
l_dleg_id NUMBER;
l_dleg_index NUMBER;
l_parent_in_cache VARCHAR2(1);

l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;


BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Top_Most_Dleg','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_top_dleg_id:=NULL;

	-- top most child dleg
	--In case of multiple levels of parent deliveries

	l_dleg_id:=p_child_dleg_id;
	WHILE(p_child_dleg_hash.EXISTS(l_dleg_id))
	LOOP
		l_dleg_index:=p_child_dleg_hash(l_dleg_id);

		l_parent_dleg_id:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(l_dleg_index).parent_dleg_id;

		l_dleg_id:=l_parent_dleg_id;

	END LOOP;

	--top parent dleg

	IF((l_dleg_id IS NOT NULL) AND (l_dleg_id <> p_child_dleg_id) AND (p_dleg_alloc_tab.EXISTS(l_dleg_id)))
	THEN

		x_top_dleg_id:=l_dleg_id;

	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Top_Most_Dleg');

EXCEPTION

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Top_Most_Dleg',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Top_Most_Dleg');



END Get_Top_Most_Dleg;

--GEts the SUMMARY cost associated with a given dleg

PROCEDURE Get_Total_Dleg_Cost(
	p_trip_index IN NUMBER,
	p_dleg_alloc_rec IN TL_dleg_alloc_rec_type,
	x_charge IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

	l_currency VARCHAR2(30);
	l_charge NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Total_Dleg_Cost','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_currency:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;
	x_charge:=0;
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.base_dist_load_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.base_dist_unload_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.base_unit_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.base_time_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.base_flat_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.stop_off_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.out_of_route_chrg,0);
	--x_charge:=x_charge+ NVL(p_dleg_alloc_rec.document_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.handling_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.fuel_chrg,0);


	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.weekday_layover_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.weekend_layover_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.loading_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.ast_loading_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.unloading_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.ast_unloading_chrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.origin_surchrg,0);
	x_charge:=x_charge+ NVL(p_dleg_alloc_rec.destination_surchrg,0);

	IF (p_dleg_alloc_rec.fac_loading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_loading_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_loading_chrg
                                     );

	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	x_charge:=x_charge+ NVL(l_charge,0);

	IF (p_dleg_alloc_rec.fac_ast_loading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                    p_dleg_alloc_rec.fac_loading_currency,
                                    l_currency,
                                    SYSDATE,
                                    'Corporate',
                                     p_dleg_alloc_rec.fac_ast_loading_chrg
                                     );
        END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	x_charge:=x_charge+ NVL(l_charge,0);

	IF ( p_dleg_alloc_rec.fac_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                    p_dleg_alloc_rec.fac_unloading_currency,
                                    l_currency,
                                    SYSDATE,
                                    'Corporate',
                                    p_dleg_alloc_rec.fac_unloading_chrg
                                    );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;
	x_charge:=x_charge+ NVL(l_charge,0);

	IF (p_dleg_alloc_rec.fac_ast_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                    p_dleg_alloc_rec.fac_unloading_currency,
                                    l_currency,
                                    SYSDATE,
                                    'Corporate',
                                    p_dleg_alloc_rec.fac_ast_unloading_chrg
                                    );

	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;
	x_charge:=x_charge+ NVL(l_charge,0);

	IF (p_dleg_alloc_rec.fac_handling_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_handling_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_handling_chrg
                                     );

        END IF;

	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;
	x_charge:=x_charge+ NVL(l_charge,0);

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Dleg_Cost');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Dleg_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Dleg_Cost');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Dleg_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Dleg_Cost');



END Get_Total_Dleg_Cost;


PROCEDURE Alloc_Charges_To_Chld_Dlegs(
	p_trip_index 		IN 	NUMBER,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	x_dleg_alloc_tab IN OUT NOCOPY TL_dleg_alloc_TAB_TYPE ,
	x_return_status OUT NOCOPY Varchar2)
IS

l_parent_dleg_hash DBMS_UTILITY.NUMBER_ARRAY;
l_child_dleg_hash DBMS_UTILITY.NUMBER_ARRAY;
l_child_dleg_index_first NUMBER;
l_child_dleg_index_last NUMBER;
l_dleg_index_first NUMBER;
l_dleg_index_last NUMBER;
i NUMBER;
l_top_dleg_id NUMBER;
l_parent_dleg_index NUMBER;
l_factor NUMBER;

l_child_dleg_alloc_rec TL_dleg_alloc_rec_TYPE;
l_parent_dleg_alloc_rec TL_dleg_alloc_rec_TYPE;

l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
l_return_status	VARCHAR2(1);

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Alloc_Charges_To_Chld_Dlegs','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_child_dleg_index_first:=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).child_dleg_reference;

	IF(l_child_dleg_index_first IS NOT NULL)
	THEN

		IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
		THEN
			l_child_dleg_index_last:=
				FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1
				).child_dleg_reference;


		ELSE
			l_child_dleg_index_last:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows.LAST+1;

		END IF;


		i:=l_child_dleg_index_first;
		WHILE (( FTE_TL_CACHE.g_tl_chld_delivery_leg_rows.EXISTS(i)) AND
		(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).trip_id=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i < l_child_dleg_index_last))
		LOOP

			l_child_dleg_hash(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id):=i;

			i:=i+1;
		END LOOP;


		l_dleg_index_first:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).delivery_leg_reference;

		IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
		THEN
			l_dleg_index_last:=
				FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1
				).delivery_leg_reference;


		ELSE
			l_dleg_index_last:=FTE_TL_CACHE.g_tl_delivery_leg_rows.LAST+1;

		END IF;


		i:=l_dleg_index_first;
		WHILE (( FTE_TL_CACHE.g_tl_delivery_leg_rows.EXISTS(i)) AND
		(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).trip_id=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i < l_dleg_index_last))
		LOOP

			l_parent_dleg_hash(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_leg_id):=i;

			i:=i+1;
		END LOOP;



		i:=l_child_dleg_index_first;
		WHILE (( FTE_TL_CACHE.g_tl_chld_delivery_leg_rows.EXISTS(i)) AND
		(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).trip_id=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i < l_child_dleg_index_last))
		LOOP


			Get_Top_Most_Dleg(
				p_child_dleg_id=>FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id,
				p_child_dleg_hash=>l_child_dleg_hash,
				p_dleg_alloc_tab=>x_dleg_alloc_tab,
				x_top_dleg_id=>l_top_dleg_id,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_top_dleg_fail;
			       END IF;
			END IF;
			IF (l_top_dleg_id IS NULL)
			THEN

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No top dleg for :'||FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id);
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_top_dleg_fail;
			END IF;

			l_parent_dleg_index:=l_parent_dleg_hash(l_top_dleg_id);


			--Calculate allocation factor

			l_factor:=0;

			IF(p_cost_allocation_parameters.principal_alloc_basis=
				FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
			THEN
				IF (FTE_TL_CACHE.g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight > 0)
				THEN
					l_factor:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).weight/
						FTE_TL_CACHE.g_tl_delivery_leg_rows(l_parent_dleg_index).children_weight;
				END IF;

			ELSIF(p_cost_allocation_parameters.principal_alloc_basis=
				FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
			THEN
				IF (FTE_TL_CACHE.g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume > 0)
				THEN
					l_factor:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).volume/
						FTE_TL_CACHE.g_tl_delivery_leg_rows(l_parent_dleg_index).children_volume;
				END IF;


			END IF;


			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Alloc factor for child dleg:'||
			FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id||' factor:'||l_factor);


			l_parent_dleg_alloc_rec:=x_dleg_alloc_tab(l_top_dleg_id);
			l_child_dleg_alloc_rec.delivery_leg_id:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id;
			l_child_dleg_alloc_rec.delivery_id:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_id;

			l_child_dleg_alloc_rec.base_dist_load_chrg:=
			 l_parent_dleg_alloc_rec.base_dist_load_chrg * l_factor;

			l_child_dleg_alloc_rec.base_dist_load_unit_chrg:=
			 l_parent_dleg_alloc_rec.base_dist_load_unit_chrg * l_factor;

			l_child_dleg_alloc_rec.base_dist_unload_chrg:=
			 l_parent_dleg_alloc_rec.base_dist_unload_chrg * l_factor;

			l_child_dleg_alloc_rec.base_dist_unload_unit_chrg:=
			 l_parent_dleg_alloc_rec.base_dist_unload_unit_chrg *
			 l_factor;

			l_child_dleg_alloc_rec.base_unit_chrg:=
			 l_parent_dleg_alloc_rec.base_unit_chrg*l_factor;

			l_child_dleg_alloc_rec.base_unit_unit_chrg:=
			 l_parent_dleg_alloc_rec.base_unit_unit_chrg*l_factor;

			l_child_dleg_alloc_rec.base_time_chrg:=
			 l_parent_dleg_alloc_rec.base_time_chrg*l_factor;

			l_child_dleg_alloc_rec.base_time_unit_chrg:=
			 l_parent_dleg_alloc_rec.base_time_unit_chrg*l_factor;

			l_child_dleg_alloc_rec.base_flat_chrg:=
			 l_parent_dleg_alloc_rec.base_flat_chrg*l_factor;


			l_child_dleg_alloc_rec.stop_off_chrg:=
			 l_parent_dleg_alloc_rec.stop_off_chrg*l_factor;


			l_child_dleg_alloc_rec.out_of_route_chrg:=
			 l_parent_dleg_alloc_rec.out_of_route_chrg*l_factor;


			l_child_dleg_alloc_rec.document_chrg:=
			 l_parent_dleg_alloc_rec.document_chrg*l_factor;


			l_child_dleg_alloc_rec.handling_chrg:=
			 l_parent_dleg_alloc_rec.handling_chrg*l_factor;

			l_child_dleg_alloc_rec.fuel_chrg:=
			 l_parent_dleg_alloc_rec.fuel_chrg*l_factor;

			l_child_dleg_alloc_rec.weekday_layover_chrg:=
			 l_parent_dleg_alloc_rec.weekday_layover_chrg*l_factor;

			l_child_dleg_alloc_rec.weekend_layover_chrg:=
			 l_parent_dleg_alloc_rec.weekend_layover_chrg*l_factor;


			l_child_dleg_alloc_rec.loading_chrg:=
			 l_parent_dleg_alloc_rec.loading_chrg*l_factor;


			l_child_dleg_alloc_rec.ast_loading_chrg:=
			 l_parent_dleg_alloc_rec.ast_loading_chrg*l_factor;


			l_child_dleg_alloc_rec.unloading_chrg:=
			 l_parent_dleg_alloc_rec.unloading_chrg*l_factor;

			l_child_dleg_alloc_rec.origin_surchrg:=
			 l_parent_dleg_alloc_rec.origin_surchrg*l_factor;

			l_child_dleg_alloc_rec.destination_surchrg:=
			 l_parent_dleg_alloc_rec.destination_surchrg*l_factor;


			l_child_dleg_alloc_rec.ast_unloading_chrg:=
			 l_parent_dleg_alloc_rec.ast_unloading_chrg*l_factor;

			l_child_dleg_alloc_rec.fac_handling_chrg:=
			 l_parent_dleg_alloc_rec.fac_handling_chrg*l_factor;

			l_child_dleg_alloc_rec.fac_loading_chrg:=
			 l_parent_dleg_alloc_rec.fac_loading_chrg*l_factor;


			l_child_dleg_alloc_rec.fac_ast_loading_chrg:=
			 l_parent_dleg_alloc_rec.fac_ast_loading_chrg*l_factor;

			l_child_dleg_alloc_rec.fac_unloading_chrg:=
			 l_parent_dleg_alloc_rec.fac_unloading_chrg*l_factor;

			l_child_dleg_alloc_rec.fac_ast_unloading_chrg:=
			 l_parent_dleg_alloc_rec.fac_ast_unloading_chrg*l_factor;

			l_child_dleg_alloc_rec.fac_loading_currency:=
			 l_parent_dleg_alloc_rec.fac_loading_currency;

			l_child_dleg_alloc_rec.fac_unloading_currency:=
			 l_parent_dleg_alloc_rec.fac_unloading_currency;

			l_child_dleg_alloc_rec.fac_handling_currency:=
			 l_parent_dleg_alloc_rec.fac_handling_currency;


			Get_Total_Dleg_Cost(
				p_trip_index=>p_trip_index,
				p_dleg_alloc_rec=>l_child_dleg_alloc_rec,
				x_charge=>l_child_dleg_alloc_rec.total_dleg_charge,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail;
			       END IF;
			END IF;



			x_dleg_alloc_tab(l_child_dleg_alloc_rec.delivery_leg_id):=
				l_child_dleg_alloc_rec;

			i:=i+1;
		END LOOP;


	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Chld_Dlegs');

EXCEPTION

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_top_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Chld_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_mdc_top_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Chld_Dlegs');


  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Chld_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_to_dleg_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Chld_Dlegs');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Chld_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Chld_Dlegs');


END Alloc_Charges_To_Chld_Dlegs;




--Allocate all remaining charges (besides stopoff,unloading/loading,handling,
--origin/dest) to delivery legs
--As per Step 4 of the CA algorithm

PROCEDURE Alloc_Charges_To_Dlegs(
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN
	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	p_stop_input_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_stop_output_hash IN DBMS_UTILITY.NUMBER_ARRAY,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	x_dleg_alloc_tab IN OUT NOCOPY TL_dleg_alloc_TAB_TYPE ,
	x_return_status OUT NOCOPY Varchar2) IS


	l_weekday_layover NUMBER;
	l_weekend_layover NUMBER;
	l_origin_chrg NUMBER;
	l_destination_chrg NUMBER;

	l_fac_handling_chrg NUMBER;

	i NUMBER;
	l_sum NUMBER;
	l_dleg_index_first NUMBER;
	l_dleg_index_last NUMBER;
	l_factor NUMBER;
	l_dleg_id NUMBER;
	l_distance NUMBER;
	l_value	NUMBER;
	l_dtl_charges_tab TL_detail_alloc_tab_type;
	l_dtl_charges_rec TL_detail_alloc_rec_type;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Alloc_Charges_To_Dlegs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_weekday_layover:=0;
	l_weekend_layover:=0;

	--Sum up all the stop level charges to the trip level
	i:=p_stop_charges_tab.FIRST;
	WHILE (i IS NOT NULL)
	LOOP

		l_weekday_layover:=l_weekday_layover+
			NVL(p_stop_charges_tab(i).weekday_layover_chrg,0);

		l_weekend_layover:=l_weekend_layover+
			NVL(p_stop_charges_tab(i).weekend_layover_chrg,0);

		i:=p_stop_charges_tab.NEXT(i);
	END LOOP;


	--Find Sum of delivery* distance


	l_dleg_index_first:=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).delivery_leg_reference;

	IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
	THEN
		l_dleg_index_last:=
			FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1
			).delivery_leg_reference;


	ELSE
		l_dleg_index_last:=FTE_TL_CACHE.g_tl_delivery_leg_rows.LAST+1;

	END IF;
	l_sum:=0;
	i:=l_dleg_index_first;

	WHILE (( FTE_TL_CACHE.g_tl_delivery_leg_rows.EXISTS(i)) AND
	(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).trip_id=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i < l_dleg_index_last))
	LOOP
		IF(p_cost_allocation_parameters.principal_alloc_basis=
			FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
		THEN
			l_value:=FTE_TL_CACHE.g_tl_delivery_leg_rows(i).weight;

		ELSIF(p_cost_allocation_parameters.principal_alloc_basis=
			FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
		THEN
			l_value:=FTE_TL_CACHE.g_tl_delivery_leg_rows(i).volume;

		END IF;

		IF(p_cost_allocation_parameters.distance_alloc_method=
			FTE_RTG_GLOBALS.G_CA_DIRECT_DISTANCE)
		THEN
			l_distance:=
			FTE_TL_CACHE.g_tl_delivery_leg_rows(i).direct_distance;

		ELSIF(p_cost_allocation_parameters.distance_alloc_method=
			FTE_RTG_GLOBALS.G_CA_TOTAL_DISTANCE)
		THEN
			l_distance:=
			FTE_TL_CACHE.g_tl_delivery_leg_rows(i).distance;

		END IF;

		l_sum:=l_sum+l_distance*l_value;



		i:=i+1;
	END LOOP;

	--Allocate to each dleg

	IF (l_sum >0 )
	THEN



		i:=l_dleg_index_first;
		WHILE (( FTE_TL_CACHE.g_tl_delivery_leg_rows.EXISTS(i)) AND
		(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).trip_id=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND i < l_dleg_index_last)
		LOOP
			IF(p_cost_allocation_parameters.principal_alloc_basis=
			FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
			THEN
				l_value:=
				FTE_TL_CACHE.g_tl_delivery_leg_rows(i).weight;

			ELSIF(p_cost_allocation_parameters.principal_alloc_basis
			=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
			THEN

				l_value:=
				FTE_TL_CACHE.g_tl_delivery_leg_rows(i).volume;
			ELSE
				l_value:=0;

			END IF;

			IF(p_cost_allocation_parameters.distance_alloc_method=
			FTE_RTG_GLOBALS.G_CA_DIRECT_DISTANCE)
			THEN
				l_distance:=
				FTE_TL_CACHE.g_tl_delivery_leg_rows(i
					).direct_distance;

			ELSIF(p_cost_allocation_parameters.distance_alloc_method
			=FTE_RTG_GLOBALS.G_CA_TOTAL_DISTANCE)
			THEN

				l_distance:=
				FTE_TL_CACHE.g_tl_delivery_leg_rows(i).distance;
			ELSE
				l_distance:=0;

			END IF;

			IF (l_sum>0)
			THEN
				l_factor:=l_value*l_distance/l_sum;
			ELSE
				l_factor:=0;
			END IF;

			l_dleg_id:=
			FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_leg_id;

			x_dleg_alloc_tab(l_dleg_id).base_dist_load_chrg:=
			 p_trip_charges_rec.base_dist_load_chrg * l_factor;
			x_dleg_alloc_tab(l_dleg_id).base_dist_load_unit_chrg:=
			 p_trip_charges_rec.base_dist_load_unit_chrg * l_factor;

			x_dleg_alloc_tab(l_dleg_id).base_dist_unload_chrg:=
			 p_trip_charges_rec.base_dist_unload_chrg * l_factor;
			x_dleg_alloc_tab(l_dleg_id).base_dist_unload_unit_chrg:=
			 p_trip_charges_rec.base_dist_unload_unit_chrg *
			 l_factor;

			x_dleg_alloc_tab(l_dleg_id).base_unit_chrg:=
			 p_trip_charges_rec.base_unit_chrg*l_factor;
			x_dleg_alloc_tab(l_dleg_id).base_unit_unit_chrg:=
			 p_trip_charges_rec.base_unit_unit_chrg*l_factor;

			x_dleg_alloc_tab(l_dleg_id).base_time_chrg:=
			 p_trip_charges_rec.base_time_chrg*l_factor;
			x_dleg_alloc_tab(l_dleg_id).base_time_unit_chrg:=
			 p_trip_charges_rec.base_time_unit_chrg*l_factor;

			x_dleg_alloc_tab(l_dleg_id).base_flat_chrg:=
			 p_trip_charges_rec.base_flat_chrg*l_factor;
			x_dleg_alloc_tab(l_dleg_id).out_of_route_chrg:=
			 p_trip_charges_rec.out_of_route_chrg*l_factor;
			x_dleg_alloc_tab(l_dleg_id).document_chrg:=
			 p_trip_charges_rec.document_chrg*l_factor;


			x_dleg_alloc_tab(l_dleg_id).weekday_layover_chrg:=
			 l_weekday_layover*l_factor;
			x_dleg_alloc_tab(l_dleg_id).weekend_layover_chrg:=
			 l_weekend_layover*l_factor;

			x_dleg_alloc_tab(l_dleg_id).fuel_chrg:=
			 p_trip_charges_rec.fuel_chrg*l_factor;



			Get_Total_Dleg_Cost(
				p_trip_index=>p_trip_index,
				p_dleg_alloc_rec=>x_dleg_alloc_tab(l_dleg_id),
				x_charge=>x_dleg_alloc_tab(l_dleg_id).total_dleg_charge,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail;
			       END IF;
			END IF;



			i:=i+1;
		END LOOP;

		Alloc_Charges_To_Chld_Dlegs(
			p_trip_index=>p_trip_index,
			p_cost_allocation_parameters=>p_cost_allocation_parameters,
			x_dleg_alloc_tab=>x_dleg_alloc_tab,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_alloc_chld_dleg_fail;
		       END IF;
		END IF;



	END IF;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Dlegs');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION



  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_alloc_chld_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_mdc_alloc_chld_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Dlegs');


  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_to_dleg_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Dlegs');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Dlegs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Dlegs');



END Alloc_Charges_To_Dlegs;

-- Copies the same information into a different record type
--
PROCEDURE Copy_Freight_Rec_Temp_To_Main(
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	x_freight_rec IN OUT NOCOPY WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type,
	x_return_status OUT NOCOPY Varchar2) IS

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Copy_Freight_Rec_Temp_To_Main','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	x_freight_rec.freight_cost_id:=p_freight_rec.freight_cost_id;
	x_freight_rec.freight_cost_type_id:=p_freight_rec.freight_cost_type_id;
	x_freight_rec.unit_amount:=p_freight_rec.unit_amount;
	x_freight_rec.calculation_method:=p_freight_rec.calculation_method;
	x_freight_rec.uom:=p_freight_rec.uom;
	x_freight_rec.quantity:=p_freight_rec.quantity;
	x_freight_rec.total_amount:=p_freight_rec.total_amount;
	x_freight_rec.currency_code:=p_freight_rec.currency_code;
	x_freight_rec.conversion_date:=p_freight_rec.conversion_date;
	x_freight_rec.conversion_rate:=p_freight_rec.conversion_rate;
	x_freight_rec.conversion_type_code:=p_freight_rec.conversion_type_code;
	x_freight_rec.trip_id:=p_freight_rec.trip_id;

	x_freight_rec.stop_id:=p_freight_rec.stop_id;
	x_freight_rec.delivery_id:=p_freight_rec.delivery_id;
	x_freight_rec.delivery_leg_id:=p_freight_rec.delivery_leg_id;
	x_freight_rec.delivery_detail_id:=p_freight_rec.delivery_detail_id;
	x_freight_rec.request_id:=p_freight_rec.request_id;
	x_freight_rec.line_type_code:=p_freight_rec.line_type_code;
	x_freight_rec.pricing_list_header_id:=
	 p_freight_rec.pricing_list_header_id;
	x_freight_rec.pricing_list_line_id:=p_freight_rec.pricing_list_line_id;
	x_freight_rec.applied_to_charge_id:=p_freight_rec.applied_to_charge_id;
	x_freight_rec.charge_unit_value:=p_freight_rec.charge_unit_value;
	x_freight_rec.charge_source_code:=p_freight_rec.charge_source_code;
	x_freight_rec.estimated_flag:=p_freight_rec.estimated_flag;
	x_freight_rec.creation_date:=p_freight_rec.creation_date;
        x_freight_rec.created_by:= p_freight_rec.created_by;
        x_freight_rec.last_update_date:= p_freight_rec.last_update_date;
        x_freight_rec.last_updated_by:=p_freight_rec.last_updated_by;
        x_freight_rec.last_update_login:= p_freight_rec.last_update_login;
        x_freight_rec.program_application_id:=
         p_freight_rec.program_application_id;
        x_freight_rec.program_id:= p_freight_rec.program_id;
        x_freight_rec.program_update_date:= p_freight_rec.program_update_date;


        --Dimension parameters

        x_freight_rec.billable_quantity:=p_freight_rec.billable_quantity;
        x_freight_rec.billable_uom:=p_freight_rec.billable_uom;
        x_freight_rec.billable_basis:=p_freight_rec.billable_basis;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_Freight_Rec_Temp_To_Main');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Copy_Freight_Rec_Temp_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_Freight_Rec_Temp_To_Main');



END  Copy_Freight_Rec_Temp_To_Main;


-- Inserts a record for a specific charge at a specific level into the temp
--table, the main table or the pl/sql table
--
PROCEDURE Insert_Charge_Rec(
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_freight_cost_id IN OUT NOCOPY NUMBER,
	x_return_status IN OUT NOCOPY VARCHAR2) IS

	l_freight_rec_main WSH_FREIGHT_COSTS_PVT.Freight_Cost_Rec_Type;
	l_rowid VARCHAR2(30);
	l_freight_rec FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Charge_Rec','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	SAVEPOINT Insert_Charge_Rec;

	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		l_freight_rec:=p_freight_rec;
		l_freight_rec.comparison_request_id:=
		 p_cost_allocation_parameters.comparison_request_id;

		DisplayCostRec(l_freight_rec);
		--3756411
		Insert_Into_Temp_Bulk_Array(
			p_freight_cost_rec =>l_freight_rec,
			x_return_status=>x_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tmp_bulk_arr_fail;
		       END IF;
		END IF;


/*
		FTE_FREIGHT_PRICING.Create_Freight_Cost_Temp(
			l_freight_rec,
			x_freight_cost_id,
			x_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
		          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_temp_fail;
		       END IF;
		END IF;
*/


	ELSIF(p_cost_allocation_parameters.output_type='M')
	THEN

		 Copy_Freight_Rec_Temp_To_Main(
		 	p_freight_rec=>	p_freight_rec,
		 	x_freight_rec=>	l_freight_rec_main,
		 	x_return_status          =>  l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				raise FTE_FREIGHT_PRICING_UTIL.g_tl_copy_fr_rec_fail;
			END IF;
		END IF;

	--delivery leg summary always exists, just update it

		 IF ((l_freight_rec_main.delivery_leg_id IS NOT NULL)
				 AND(l_freight_rec_main.delivery_detail_id IS NULL)
			 AND (l_freight_rec_main.line_type_code='SUMMARY'))
		THEN
			l_freight_rec_main.freight_cost_id:=FTE_FREIGHT_PRICING.get_fc_id_from_dleg(l_freight_rec_main.delivery_leg_id);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail;
				END IF;
			END IF;


		      WSH_FREIGHT_COSTS_PVT.Update_Freight_Cost(
			 p_rowid                  =>  l_rowid,
			 p_freight_cost_info      =>  l_freight_rec_main,
			 x_return_status          =>  l_return_status);

			 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
			    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
				FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'Update_Freight_Cost');
				raise FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed;
			    ELSE
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_WRN,'Update_Freight_Cost returned warning ');
			    END IF;
			 END IF;

		ELSE

			 WSH_FREIGHT_COSTS_PVT.Create_Freight_Cost(
			  p_freight_cost_info      =>  l_freight_rec_main,
			  x_rowid                  =>  l_rowid,
			  x_freight_cost_id        =>  x_freight_cost_id,
			  x_return_status          =>  l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail;
				END IF;
			END IF;

		END IF;

	ELSIF(p_cost_allocation_parameters.output_type='P')
	THEN
		IF(x_output_cost_tab.LAST IS NULL)
		THEN
			x_freight_cost_id:=1;
		ELSE
			x_freight_cost_id:=x_output_cost_tab.LAST+1;
		END IF;
		x_output_cost_tab(x_freight_cost_id):=p_freight_rec;
		x_output_cost_tab(x_freight_cost_id).freight_cost_id:=
			x_freight_cost_id;
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	ELSE
		--throw an exception
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_output_type;

	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tmp_bulk_arr_fail THEN
    	 ROLLBACK TO Insert_Charge_Rec;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_tmp_bulk_arr_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');


    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_fc_id_fail THEN
    	 ROLLBACK TO Insert_Charge_Rec;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_fc_id_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_update_freight_cost_failed THEN
    	 ROLLBACK TO Insert_Charge_Rec;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_update_freight_cost_failed');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_temp_fail THEN
    	 ROLLBACK TO Insert_Charge_Rec;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_fr_cost_temp_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_copy_fr_rec_fail THEN
    	  ROLLBACK TO Insert_Charge_Rec;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_copy_fr_rec_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_fr_cost_fail THEN
    	  ROLLBACK TO Insert_Charge_Rec;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_fr_cost_fail');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

    WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_invalid_output_type THEN
    	  ROLLBACK TO Insert_Charge_Rec;
          x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
          FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_invalid_output_type');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');

   WHEN others THEN
    	ROLLBACK TO Insert_Charge_Rec;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Charge_Rec',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Charge_Rec');



END Insert_Charge_Rec;

--Inserts a delivery detail level charge record

PROCEDURE Insert_Dlv_Dtl_Level_Charge(
	p_charge_type IN NUMBER,
	p_line_type_code IN VARCHAR2,
	p_charge IN NUMBER,
	p_unit_charge IN NUMBER,
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_output_cost_tab IN  OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
	x_return_status OUT NOCOPY Varchar2) IS

	l_freight_rec  FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_cost_type_id NUMBER;
	l_freight_cost_id NUMBER;
	l_return_status VARCHAR2(1);


	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Dlv_Dtl_Level_Charge','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_freight_rec:=p_freight_rec;
	l_freight_rec.freight_cost_type_id:=p_charge_type;
	l_freight_rec.unit_amount:=p_charge;
	l_freight_rec.total_amount:=p_charge;
	l_freight_rec.line_type_code:=p_line_type_code;
	l_freight_rec.charge_unit_value:=p_unit_charge;

	Insert_Charge_Rec(
		p_freight_rec=>	l_freight_rec,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab ,
		x_freight_cost_id=>	l_freight_cost_id,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail;
	       END IF;
	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dlv_Dtl_Level_Charge');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Dlv_Dtl_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_charge_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dlv_Dtl_Level_Charge');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Dlv_Dtl_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dlv_Dtl_Level_Charge');



END Insert_Dlv_Dtl_Level_Charge;

--Inserts a trip level charge record

PROCEDURE Insert_Trip_Level_Charge(
	p_charge_type IN NUMBER,
	p_line_type_code IN VARCHAR2,
	p_charge IN NUMBER,
	p_unit_charge IN NUMBER,
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_output_cost_tab IN  OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_freight_rec  FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_cost_type_id NUMBER;
	l_freight_cost_id NUMBER;
	l_return_status VARCHAR2(1);


	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Trip_Level_Charge','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_freight_rec:=p_freight_rec;
	l_freight_rec.freight_cost_type_id:=p_charge_type;
	l_freight_rec.unit_amount:=p_charge;
	l_freight_rec.total_amount:=p_charge;
	l_freight_rec.line_type_code:=p_line_type_code;
	l_freight_rec.charge_unit_value:=p_unit_charge;

	Insert_Charge_Rec(
		p_freight_rec=>	l_freight_rec,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab ,
		x_freight_cost_id=>	l_freight_cost_id,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Trip_Level_Charge');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Trip_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_charge_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Trip_Level_Charge');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Trip_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Trip_Level_Charge');



END Insert_Trip_Level_Charge;

-- Inserta a stop level charge record

PROCEDURE Insert_Stop_Level_Charge(
	p_charge_type IN NUMBER,
	p_line_type_code IN VARCHAR2,
	p_charge IN NUMBER,
	p_unit_charge IN NUMBER,
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_output_cost_tab IN  OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type ,
	x_return_status OUT NOCOPY Varchar2) IS

	l_freight_rec  FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_cost_type_id NUMBER;
	l_freight_cost_id NUMBER;
	l_return_status VARCHAR2(1);


	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Stop_Level_Charge','start');


	l_freight_rec:=p_freight_rec;
	l_freight_rec.freight_cost_type_id:=p_charge_type;
	l_freight_rec.unit_amount:=p_charge;
	l_freight_rec.total_amount:=p_charge;
	l_freight_rec.line_type_code:=p_line_type_code;
	l_freight_rec.charge_unit_value:=p_unit_charge;

	Insert_Charge_Rec(
		p_freight_rec=>	l_freight_rec,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab ,
		x_freight_cost_id=>	l_freight_cost_id,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Stop_Level_Charge');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Stop_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_charge_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Stop_Level_Charge');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Stop_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Stop_Level_Charge');



END Insert_Stop_Level_Charge;


--Inserts a delivery leg level charge record

PROCEDURE Insert_Dleg_Level_Charge(
	p_charge_type IN NUMBER,
	p_line_type_code IN VARCHAR2,
	p_charge IN NUMBER,
	p_unit_charge IN NUMBER,
	p_freight_rec IN FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type,
	p_cost_allocation_parameters IN TL_allocation_params_rec_type,
	x_output_cost_tab IN  OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_freight_rec  FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_cost_type_id NUMBER;
	l_freight_cost_id NUMBER;
	l_return_status VARCHAR2(1);


	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Insert_Dleg_Level_Charge','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_freight_rec:=p_freight_rec;
	l_freight_rec.freight_cost_type_id:=p_charge_type;
	l_freight_rec.unit_amount:=p_charge;
	l_freight_rec.total_amount:=p_charge;
	l_freight_rec.line_type_code:=p_line_type_code;
	l_freight_rec.charge_unit_value:=p_unit_charge;

	Insert_Charge_Rec(
		p_freight_rec=>	l_freight_rec,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab ,
		x_freight_cost_id=>	l_freight_cost_id,
		x_return_status=>	l_return_status);

       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
       THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dleg_Level_Charge');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_charge_rec_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Dleg_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_charge_rec_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dleg_Level_Charge');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Insert_Dleg_Level_Charge',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Insert_Dleg_Level_Charge');



END Insert_Dleg_Level_Charge;

--Gets the SUMMARY cost associated with a given stop

PROCEDURE Get_Total_Stop_Cost(
	p_stop_charges_rec IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_REC_TYPE,
	p_currency IN VARCHAR2,
	x_charge IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

	l_charge NUMBER;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Total_Stop_Cost','start');


		x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-1');
		x_charge:=0;
		x_charge:=x_charge+
			NVL(p_stop_charges_rec.weekday_layover_chrg,0);
		x_charge:=x_charge+
			NVL(p_stop_charges_rec.weekend_layover_chrg,0);
		x_charge:=x_charge+ NVL(p_stop_charges_rec.loading_chrg,0);
		x_charge:=x_charge+ NVL(p_stop_charges_rec.ast_loading_chrg,0);
		x_charge:=x_charge+ NVL(p_stop_charges_rec.unloading_chrg,0);
		x_charge:=x_charge+
			NVL(p_stop_charges_rec.ast_unloading_chrg,0);
		x_charge:=x_charge+ NVL(p_stop_charges_rec.origin_surchrg,0);
		x_charge:=x_charge+
			NVL(p_stop_charges_rec.destination_surchrg,0);

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-2');
		IF (p_stop_charges_rec.fac_loading_chrg = 0)
		THEN
			l_charge:=0;
		ELSE
			l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     p_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_loading_chrg
                                     );
                END IF;

        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-3');
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;


		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-4');
		x_charge:=x_charge+ NVL(l_charge,0);

		IF (p_stop_charges_rec.fac_ast_loading_chrg =0)
		THEN
			l_charge:=0;
		ELSE
			l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     p_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_ast_loading_chrg
                                     );
                END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-5');
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;


		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-6');
		x_charge:=x_charge+ NVL(l_charge,0);

		IF (p_stop_charges_rec.fac_unloading_chrg = 0)
		THEN
			l_charge:=0;
		ELSE
			l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     p_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_unloading_chrg
                                     );
                END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-7');
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;


		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-8');
		x_charge:=x_charge+ NVL(l_charge,0);

		IF (p_stop_charges_rec.fac_ast_unloading_chrg = 0)
		THEN
			l_charge:=0;
		ELSE
			l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     p_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_ast_unloading_chrg
                                     );

		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-9');
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-10');
		x_charge:=x_charge+ NVL(l_charge,0);

		IF ( p_stop_charges_rec.fac_handling_chrg = 0)
		THEN
			l_charge:=0;

		ELSE

			l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     p_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_handling_chrg
                                     );

		END IF;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-11');
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

		END IF;
		x_charge:=x_charge+ NVL(l_charge,0);

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Cost');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Stop_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Cost');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Stop_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Stop_Cost');


END  Get_Total_Stop_Cost;

--Gets the SUMMARY cost associated with a given trip

PROCEDURE Get_Total_Trip_Cost(
	p_trip_index IN NUMBER,
	p_trip_charges_rec IN FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_TAB_TYPE,
	x_charge IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2) IS

	i NUMBER;
	l_charge NUMBER;
	l_currency VARCHAR2(30);
	l_stop_charge	NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Total_Trip_Cost','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_currency:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;

	x_charge:=0;

	x_charge:=x_charge+ NVL(p_trip_charges_rec.base_dist_load_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.base_dist_unload_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.base_unit_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.base_time_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.base_flat_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.stop_off_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.out_of_route_chrg,0);
	--x_charge:=x_charge+ NVL(p_trip_charges_rec.document_chrg,0);
	x_charge:=x_charge+ NVL(p_trip_charges_rec.handling_chrg,0);

	x_charge:=x_charge+ NVL(p_trip_charges_rec.fuel_chrg,0);

	i:=p_stop_charges_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP


		Get_Total_Stop_Cost(
			p_stop_charges_rec=>	p_stop_charges_tab(i),
			p_currency=>	l_currency,
			x_charge=>	l_stop_charge,
			x_return_status=>	l_return_status);


	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	       THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_stop_cost_fail;
		       END IF;
		END IF;

		x_charge:=x_charge+l_stop_charge;
		i:=p_stop_charges_tab.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Trip_Cost');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_stop_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Trip_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_stop_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Trip_Cost');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Total_Trip_Cost',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Total_Trip_Cost');


END	Get_Total_Trip_Cost;


--Creates Charges at the trip level once cost allocation is complete

PROCEDURE Create_Trip_Level_Price_Recs(
	p_trip_index IN NUMBER,
	p_trip_charges_rec IN FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_TAB_TYPE,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_total_trip_charge NUMBER;
	l_unit_freight_code NUMBER;

	l_freight_rec_common FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Trip_Level_Price_Recs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	IF (p_trip_charges_rec.total_trip_rate IS NOT NULL)
	THEN

		Get_Total_Trip_Cost(
			p_trip_index=>	p_trip_index,
			p_trip_charges_rec=>	p_trip_charges_rec,
			p_stop_charges_tab=>	p_stop_charges_tab,
			x_charge=>	l_total_trip_charge,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail;
		       END IF;
		END IF;
	ELSE

		l_total_trip_charge:=p_trip_charges_rec.total_trip_rate;

	END IF;


	--Populate values that are common for all pricing records

	l_freight_rec_common.currency_code:=
		FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;
	l_freight_rec_common.trip_id:=p_trip_charges_rec.trip_id;
	l_freight_rec_common.charge_source_code:='PRICING_ENGINE';
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		l_freight_rec_common.estimated_flag:='Y';
	ELSE
		l_freight_rec_common.estimated_flag:='N';
	END IF;
	l_freight_rec_common.lane_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).lane_id;
	l_freight_rec_common.schedule_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).schedule_id;
	l_freight_rec_common.service_type_code:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).service_type;
	l_freight_rec_common.creation_date := SYSDATE;
        l_freight_rec_common.created_by    := FND_GLOBAL.USER_ID;
	l_freight_rec_common.last_update_date := sysdate;
        l_freight_rec_common.last_updated_by := FND_GLOBAL.USER_ID;
        l_freight_rec_common.last_update_login := FND_GLOBAL.LOGIN_ID;

	l_freight_rec_common.vehicle_type_id:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).vehicle_type;

	--All the common values for the records are now populated;

	--Total trip charge

	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_SUMMARY).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_total_trip_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_trp_chrg_fail;
	       END IF;
	END IF;


	--base_dist_load_chrg


	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_LOADED_DISTANCE_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.base_dist_load_chrg,
		p_unit_charge=>	p_trip_charges_rec.base_dist_load_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	x_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_trp_chrg_fail;
	       END IF;
	END IF;



	--base_dist_unload_chrg


	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_UNLOADED_DISTANCE_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.base_dist_unload_chrg,
		p_unit_charge=>	p_trip_charges_rec.base_dist_unload_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ud_trp_chrg_fail;
	       END IF;
	END IF;


	--base_unit_chrg

	IF(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_WEIGHT_BASIS
	)
	THEN
		l_unit_freight_code:=
		g_tl_freight_codes(C_UNIT_WEIGHT_RT).fte_summary_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_VOLUME_BASIS)
	THEN
		l_unit_freight_code:=
		g_tl_freight_codes(C_UNIT_VOLUME_RT).fte_summary_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_CONTAINER_BASIS)
	THEN
		l_unit_freight_code:=
		g_tl_freight_codes(C_UNIT_CONTAINER_RT).fte_summary_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_PALLET_BASIS)
	THEN
		l_unit_freight_code:=
		g_tl_freight_codes(C_UNIT_PALLET_RT).fte_summary_code_id;

	ELSE
		FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'Create_Trip_Level_Price_Recs',
			p_exc=>'g_tl_no_carr_unit_basis',
			p_carrier_id=> FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis;

	END IF;


	Insert_Trip_Level_Charge(
		p_charge_type=>	l_unit_freight_code,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.base_unit_chrg,
		p_unit_charge=>	p_trip_charges_rec.base_unit_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status
		);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_trp_chrg_fail;
	       END IF;
	END IF;

	--base_time_chrg

	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_TIME_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.base_time_chrg,
		p_unit_charge=>	p_trip_charges_rec.base_time_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_trp_chrg_fail;
	       END IF;
	END IF;


	--base_flat_chrg


	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_FLAT_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.base_flat_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_trp_chrg_fail;
	       END IF;
	END IF;

	--stop_off_chrg

	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_STOP_OFF_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.stop_off_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_trp_chrg_fail;
	       END IF;
	END IF;


	--out_of_route_chrg





	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_trip_charges_rec.out_of_route_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_trp_chrg_fail;
	       END IF;
	END IF;


	--document_chrg
	--
	/*
	Insert_Trip_Level_Charge(
		g_tl_freight_codes(C_DOCUMENT_CHRG).fte_summary_code_id,
		'SUMMARY',
		p_trip_charges_rec.document_chrg,
		NULL,
		l_freight_rec_common,
		p_cost_allocation_parameters,
		x_output_cost_tab);
	*/
	--handling_chrg



	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_HANDLING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>	p_trip_charges_rec.handling_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_trp_chrg_fail;
	       END IF;
	END IF;

	--fuel_chrg

	Insert_Trip_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_FUEL_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>	p_trip_charges_rec.fuel_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_trp_chrg_fail;
	       END IF;
	END IF;




	--cm_discount_percent
	--cm_discount_value


	Insert_Trip_Level_Charge(
	  p_charge_type=>	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISCOUNT).fte_summary_code_id,
	  p_line_type_code=>	'DISCOUNT',
	  p_charge=>	p_trip_charges_rec.cm_discount_value,
	  p_unit_charge=>	NULL,
	  p_freight_rec=>	l_freight_rec_common,
	  p_cost_allocation_parameters=>	p_cost_allocation_parameters,
	  x_output_cost_tab=>	x_output_cost_tab,
	  x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_cmdisc_trp_chrg_fail;
	       END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_trp_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_trp_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_fuel_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');



   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_tot_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dist_ld_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ud_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dist_ud_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_carr_unit_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_unit_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_time_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_flat_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_stpoff_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_outrt_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_hndl_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_cmdisc_trp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_cmdisc_trp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Trip_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Trip_Level_Price_Recs');


END  Create_Trip_Level_Price_Recs;

--Charges at the stop level once cost allocation is complete

PROCEDURE Create_Stop_Level_Price_Recs(
	p_trip_index IN NUMBER,
	p_stop_charges_rec IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_REC_TYPE,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_currency VARCHAR2(30);
	l_freight_rec_common FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_total_stop_charge NUMBER;
	l_charge NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Stop_Level_Price_Recs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_currency:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;

	--Populate values that are common for all pricing records

	l_freight_rec_common.currency_code:=
	FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;
	l_freight_rec_common.stop_id:=p_stop_charges_rec.stop_id;
	l_freight_rec_common.charge_source_code:='PRICING_ENGINE';
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		l_freight_rec_common.estimated_flag:='Y';
	ELSE
		l_freight_rec_common.estimated_flag:='N';
	END IF;
	l_freight_rec_common.lane_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).lane_id;
	l_freight_rec_common.schedule_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).schedule_id;
	l_freight_rec_common.service_type_code:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).service_type;
	l_freight_rec_common.creation_date := SYSDATE;
        l_freight_rec_common.created_by    := FND_GLOBAL.USER_ID;
	l_freight_rec_common.last_update_date := sysdate;
        l_freight_rec_common.last_updated_by := FND_GLOBAL.USER_ID;
        l_freight_rec_common.last_update_login := FND_GLOBAL.LOGIN_ID;

	l_freight_rec_common.vehicle_type_id:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).vehicle_type;

	--All the common values for the records are now populated;

	--Total Stop charges

	Get_Total_Stop_Cost(
		p_stop_charges_rec=>	p_stop_charges_rec ,
		p_currency=>	l_currency,
		x_charge=>	l_total_stop_charge,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_stop_cost_fail;
       		END IF;
	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_SUMMARY).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_total_stop_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_stp_chrg_fail;
       		END IF;
	END IF;


	--weekday_layover_chrg

	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>p_stop_charges_rec.weekday_layover_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkdayl_stp_chrg_fail;
       		END IF;
	END IF;


	--weekend_layover_chrg


	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.weekend_layover_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkendl_stp_chrg_fail;
       		END IF;
	END IF;




	--loading_chrg


	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>p_stop_charges_rec.loading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_stp_chrg_fail;
       		END IF;
	END IF;


	--ast_loading_chrg

	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_AST_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.ast_loading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ast_ld_stp_chrg_fail;
       		END IF;
	END IF;


	--unloading_chrg





	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.unloading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_stp_chrg_fail;
       		END IF;
	END IF;


	--ast_unloading_chrg

	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_AST_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.ast_unloading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ast_ud_stp_chrg_fail;
       		END IF;
	END IF;



	--origin_surchrg


	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_ORIGIN_SURCHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.origin_surchrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_stp_chrg_fail;
       		END IF;
	END IF;



	--destination_surchrg


	Insert_Stop_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_DESTINATION_SURCHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_stop_charges_rec.destination_surchrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_stp_chrg_fail;
       		END IF;
	END IF;



	--fac_loading_chrg

	IF ( p_stop_charges_rec.fac_loading_chrg=0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_loading_chrg
                                     );
        END IF;

	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>l_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>p_cost_allocation_parameters ,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_stp_chrg_fail;
       		END IF;
	END IF;


	--fac_ast_loading_chrg
	IF (p_stop_charges_rec.fac_ast_loading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_ast_loading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_AST_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>l_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>p_cost_allocation_parameters ,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_stp_chrg_fail;
       		END IF;
	END IF;


	--fac_unloading_chrg
	IF (p_stop_charges_rec.fac_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_unloading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>l_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>p_cost_allocation_parameters ,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_stp_chrg_fail;
       		END IF;
	END IF;

	--fac_ast_unloading_chrg
	IF ( p_stop_charges_rec.fac_ast_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_ast_unloading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;

	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_AST_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>l_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>p_cost_allocation_parameters ,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_stp_chrg_fail;
       		END IF;
	END IF;


	--fac_handling_chrg
	IF (p_stop_charges_rec.fac_handling_chrg=0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_stop_charges_rec.fac_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_stop_charges_rec.fac_handling_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;

	Insert_Stop_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_HANDLING_CHRG).fte_summary_code_id,
		p_line_type_code=>'SUMMARY',
		p_charge=>l_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>p_cost_allocation_parameters ,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
       		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
       		THEN
          		raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_stp_chrg_fail;
       		END IF;
	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_tot_stop_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_tot_stop_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_tot_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkdayl_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkdayl_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkendl_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkendl_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ld_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ast_ld_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ast_ld_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ud_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ast_ud_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ast_ud_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_org_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dst_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ld_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');


 WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ld_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ud_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ud_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_stp_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_hndl_stp_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');




   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Stop_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Stop_Level_Price_Recs');



END Create_Stop_Level_Price_Recs;

--Creates stop level charge recs once cost allocation is complete

PROCEDURE Create_Dleg_Level_Price_Recs(
	p_trip_index IN NUMBER,
	p_dleg_alloc_rec IN TL_dleg_alloc_rec_type,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_currency VARCHAR2(30);
	l_freight_rec_common FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_unit_freight_code NUMBER;
	l_total_dleg_charge NUMBER;
	l_charge NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Dleg_Level_Price_Recs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	--Populate values that are common for all pricing records
	l_currency:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;

	l_freight_rec_common.currency_code:=
		FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;
	l_freight_rec_common.delivery_leg_id:=p_dleg_alloc_rec.delivery_leg_id;
	l_freight_rec_common.delivery_id:=p_dleg_alloc_rec.delivery_id;
	l_freight_rec_common.charge_source_code:='PRICING_ENGINE';
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		l_freight_rec_common.estimated_flag:='Y';
	ELSE
		l_freight_rec_common.estimated_flag:='N';
	END IF;
	l_freight_rec_common.lane_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).lane_id;
	l_freight_rec_common.schedule_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).schedule_id;
	l_freight_rec_common.service_type_code:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).service_type;
	l_freight_rec_common.creation_date := SYSDATE;
        l_freight_rec_common.created_by    := FND_GLOBAL.USER_ID;
	l_freight_rec_common.last_update_date := sysdate;
        l_freight_rec_common.last_updated_by := FND_GLOBAL.USER_ID;
        l_freight_rec_common.last_update_login := FND_GLOBAL.LOGIN_ID;

	l_freight_rec_common.vehicle_type_id:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).vehicle_type;

	--All the common values for the records are now populated;

	--Total Dleg charges

	Get_Total_Dleg_Cost(
		p_trip_index=>	p_trip_index,
		p_dleg_alloc_rec=>	p_dleg_alloc_rec ,
		x_charge=>	l_total_dleg_charge,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail;
	       END IF;
	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_SUMMARY).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_total_dleg_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_dlg_chrg_fail;
	       END IF;
	END IF;

/*
	--base_dist_load_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_LOADED_DISTANCE_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.base_dist_load_chrg,
		p_unit_charge=>	p_dleg_alloc_rec.base_dist_load_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_dlg_chrg_fail;
	       END IF;
	END IF;



	--base_dist_unload_chrg


	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_UNLOADED_DISTANCE_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.base_dist_unload_chrg,
		p_unit_charge=>	p_dleg_alloc_rec.base_dist_unload_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_dlg_chrg_fail;
	       END IF;
	END IF;



	--base_unit_chrg

	IF(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_WEIGHT_BASIS
	)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_WEIGHT_RT).fte_price_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_VOLUME_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_VOLUME_RT).fte_price_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_CONTAINER_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_CONTAINER_RT).fte_price_code_id;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_PALLET_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_PALLET_RT).fte_price_code_id;

	ELSE
		FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'Create_Trip_Level_Price_Recs',
			p_exc=>'g_tl_no_carr_unit_basis',
			p_carrier_id=> FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).carrier_id);


		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis;

	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>l_unit_freight_code,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.base_unit_chrg,
		p_unit_charge=>	p_dleg_alloc_rec.base_unit_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_dlg_chrg_fail;
	       END IF;
	END IF;


	--base_time_chrg


	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_TIME_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.base_time_chrg,
		p_unit_charge=>	p_dleg_alloc_rec.base_time_unit_chrg,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_dlg_chrg_fail;
	       END IF;

	END IF;



	--base_flat_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_FLAT_RT).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.base_flat_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_dlg_chrg_fail;
	       END IF;

	END IF;


	--stop_off_chrg


	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_STOP_OFF_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.stop_off_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_dlg_chrg_fail;
	       END IF;

	END IF;


	--out_of_route_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.out_of_route_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_dlg_chrg_fail;
	       END IF;

	END IF;



	--document_chrg
	--

	Insert_Dleg_Level_Charge(
		g_tl_freight_codes(C_DOCUMENT_CHRG).fte_summary_code_id,
		'SUMMARY',
		p_dleg_alloc_rec.document_chrg,
		NULL,
		l_freight_rec_common,
		p_cost_allocation_parameters ,
		x_output_cost_tab);

	--handling_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_HANDLING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.handling_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_dlg_chrg_fail;
	       END IF;

	END IF;


	--fuel_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_FUEL_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.fuel_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_dlg_chrg_fail;
	       END IF;

	END IF;




	--weekday_layover_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.weekday_layover_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkdayl_dlg_chrg_fail;
	       END IF;

	END IF;


	--weekend_layover_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.weekend_layover_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkendl_dlg_chrg_fail;
	       END IF;

	END IF;



	--loading_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.loading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_dlg_chrg_fail;
	       END IF;

	END IF;

	--ast_loading_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_AST_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.ast_loading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ld_dlg_chrg_fail;
	       END IF;

	END IF;


	--unloading_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.unloading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_dlg_chrg_fail;
	       END IF;

	END IF;


	--ast_unloading_chrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_AST_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.ast_unloading_chrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ud_dlg_chrg_fail;
	       END IF;

	END IF;


	--origin_surchrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_ORIGIN_SURCHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.origin_surchrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_dlg_chrg_fail;
	       END IF;

	END IF;


	--destination_surchrg

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(C_DESTINATION_SURCHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_dleg_alloc_rec.destination_surchrg,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_dlg_chrg_fail;
	       END IF;

	END IF;


	--fac_loading_chrg
	IF (p_dleg_alloc_rec.fac_loading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_loading_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_loading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_dlg_chrg_fail;
	       END IF;

	END IF;


	--fac_ast_loading_chrg
	IF (p_dleg_alloc_rec.fac_ast_loading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_loading_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_ast_loading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_AST_LOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_dlg_chrg_fail;
	       END IF;

	END IF;


	--fac_unloading_chrg
	IF (p_dleg_alloc_rec.fac_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE

		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_unloading_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_unloading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_dlg_chrg_fail;
	       END IF;

	END IF;


	--fac_ast_unloading_chrg
	IF (p_dleg_alloc_rec.fac_ast_unloading_chrg = 0)
	THEN
		l_charge:=0;
	ELSE

		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_unloading_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_ast_unloading_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;


	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_AST_UNLOADING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_dlg_chrg_fail;
	       END IF;

	END IF;


	--fac_handling_chrg
	IF (p_dleg_alloc_rec.fac_handling_chrg= 0)
	THEN
		l_charge:=0;
	ELSE
		l_charge:=GL_CURRENCY_API.convert_amount(
                                     p_dleg_alloc_rec.fac_handling_currency,
                                     l_currency,
                                     SYSDATE,
                                     'Corporate',
                                     p_dleg_alloc_rec.fac_handling_chrg
                                     );
	END IF;
	IF (l_charge IS NULL)
	THEN
		raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
	END IF;

	Insert_Dleg_Level_Charge(
		p_charge_type=>g_tl_freight_codes(F_HANDLING_CHRG).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	l_charge,
		p_unit_charge=>	NULL,
		p_freight_rec=>	l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters ,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_dlg_chrg_fail;
	       END IF;

	END IF;
	*/

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION
  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_get_to_dleg_cost_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_get_to_dleg_cost_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_fuel_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');


  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_tot_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_tot_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dist_ld_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_carr_unit_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_unit_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_time_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_flat_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_stpoff_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_outrt_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_hndl_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkdayl_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkdayl_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkendl_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkendl_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ld_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ld_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_as_ld_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ud_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ud_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_as_ud_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_org_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dst_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ld_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ld_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ud_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ud_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_dlg_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_hndl_dlg_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');



   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dleg_Level_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dleg_Level_Price_Recs');



END Create_Dleg_Level_Price_Recs;

--Creates the delivery detail level records once cost allocation is done

PROCEDURE Create_Dlv_Dtl_Price_Recs(
	p_trip_index IN NUMBER,
	p_factor IN NUMBER,
	p_dtl_rec IN FTE_FREIGHT_PRICING.shipment_line_rec_type,
	p_dleg_alloc_rec IN TL_dleg_alloc_rec_type,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	p_dim_weight IN NUMBER,
	p_only_summary_flag IN VARCHAR2,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	l_freight_rec_common FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_rec FTE_FREIGHT_PRICING.Freight_Cost_Temp_Rec_Type;
	l_freight_cost_id NUMBER;
	l_return_status VARCHAR2(1);
	l_charge NUMBER;
	l_unit_freight_code NUMBER;
	l_sum	NUMBER;

	l_billable_basis VARCHAR2(30);
	l_billable_quantity NUMBER;
	l_billable_uom VARCHAR2(30);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Dlv_Dtl_Price_Recs','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_billable_basis:=NULL;
	l_billable_quantity:=NULL;
	l_billable_uom:=NULL;

	--Populate values that are common for all pricing records

	l_freight_rec_common.currency_code:=
		FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).currency;
	l_freight_rec_common.delivery_id:=p_dtl_rec.delivery_id;
	l_freight_rec_common.delivery_leg_id:=p_dtl_rec.delivery_leg_id;
	l_freight_rec_common.delivery_detail_id:=p_dtl_rec.delivery_detail_id;
	l_freight_rec_common.charge_source_code:='PRICING_ENGINE';
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		l_freight_rec_common.estimated_flag:='Y';
	ELSE
		l_freight_rec_common.estimated_flag:='N';
	END IF;
	l_freight_rec_common.lane_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).lane_id;
	l_freight_rec_common.schedule_id:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).schedule_id;
	l_freight_rec_common.service_type_code:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).service_type;
	l_freight_rec_common.creation_date := SYSDATE;
        l_freight_rec_common.created_by    := FND_GLOBAL.USER_ID;
	l_freight_rec_common.last_update_date := sysdate;
        l_freight_rec_common.last_updated_by := FND_GLOBAL.USER_ID;
        l_freight_rec_common.last_update_login := FND_GLOBAL.LOGIN_ID;

        l_freight_rec_common.vehicle_type_id:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).vehicle_type;

	--All the common values for the records are now populated;



	--base_unit_chrg



	IF(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_WEIGHT_BASIS
	)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_WEIGHT_RT).fte_price_code_id;

		IF (p_dim_weight IS NOT NULL)
		THEN
			l_billable_basis:='WEIGHT';
			l_billable_uom:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).weight_uom;
			l_billable_quantity:=p_dim_weight;
		END IF;

	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_VOLUME_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_VOLUME_RT).fte_price_code_id;

		--l_billable_basis:='VOLUME';
		--l_billable_uom:=FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).volume_uom;
		--l_billable_quantity:=p_volume;


	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_CONTAINER_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_CONTAINER_RT).fte_price_code_id;

		--l_billable_basis:='CONTAINER';
		--l_billable_uom:= ??? Each;
		--l_billable_quantity:=p_volume;




	ELSIF
	(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).unit_basis=FTE_RTG_GLOBALS.G_CARRIER_PALLET_BASIS)
	THEN
		l_unit_freight_code:=
		 g_tl_freight_codes(C_UNIT_PALLET_RT).fte_price_code_id;

	ELSE

		FTE_FREIGHT_PRICING_UTIL.setmsg (
			p_api=>'Create_Dlv_Dtl_Price_Recs',
			p_exc=>'g_tl_no_carr_unit_basis',
			p_carrier_id=>FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).carrier_id);

		raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis;

	END IF;

	IF ((p_only_summary_flag IS NULL ) OR (p_only_summary_flag='N'))
	THEN



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>l_unit_freight_code,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_unit_chrg,
			 p_unit_charge=>p_factor*p_dleg_alloc_rec.base_unit_unit_chrg,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_dtl_chrg_fail;
		       END IF;
		END IF;


		--base_dist_load_chrg

		IF ((FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).continuous_move='Y') AND
		(FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).cm_rate_variant='DISC
		OUNT'))
		THEN

			Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>	g_tl_freight_codes(C_CONTINUOUS_MOVE_DISTANCE_RT
				).fte_price_code_id,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_dist_load_chrg,
			 p_unit_charge=>p_factor*p_dleg_alloc_rec.base_dist_load_unit_chrg,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_cm_dist_dtl_chrg_fail;
			       END IF;
			END IF;


		ELSE


			Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_LOADED_DISTANCE_RT).fte_price_code_id,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_dist_load_chrg,
			 p_unit_charge=>p_factor*p_dleg_alloc_rec.base_dist_load_unit_chrg,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_dtl_chrg_fail;
			       END IF;
			END IF;



		END IF;

		--base_dist_unload_chrg


		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_UNLOADED_DISTANCE_RT).fte_price_code_id,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_dist_unload_chrg,
			 p_unit_charge=>p_factor*p_dleg_alloc_rec.base_dist_unload_unit_chrg,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ud_dtl_chrg_fail;
		       END IF;
		END IF;




		--base_time_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_TIME_RT).fte_price_code_id,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_time_chrg,
			 p_unit_charge=>p_factor*p_dleg_alloc_rec.base_time_unit_chrg,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_dtl_chrg_fail;
		       END IF;
		END IF;


		--base_flat_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_FLAT_RT).fte_price_code_id,
			 p_line_type_code=>	'TLPRICE',
			 p_charge=>p_factor*p_dleg_alloc_rec.base_flat_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_dtl_chrg_fail;
		       END IF;
		END IF;


		--stop_off_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_STOP_OFF_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.stop_off_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_dtl_chrg_fail;
		       END IF;
		END IF;


		--out_of_route_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_OUT_OF_ROUTE_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.out_of_route_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_dtl_chrg_fail;
		       END IF;
		END IF;


		--handling_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_HANDLING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.handling_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_dtl_chrg_fail;
		       END IF;
		END IF;


		--fuel_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_FUEL_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.fuel_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_dtl_chrg_fail;
		       END IF;
		END IF;


		--weekday_layover_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_WEEKDAY_LAYOVER_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.weekday_layover_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkday_dtl_chrg_fail;
		       END IF;
		END IF;



		--weekend_layover_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_WEEKEND_LAYOVER_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.weekend_layover_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkend_dtl_chrg_fail;
		       END IF;
		END IF;


		--loading_chrg


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
		' BEFORE INSERTING loading charge '|| g_tl_freight_codes(C_LOADING_CHRG).fte_charge_code_id|| '*');



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_LOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.loading_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_dtl_chrg_fail;
		       END IF;
		END IF;



		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
		' AFTER INSERTING loading charge '|| g_tl_freight_codes(C_LOADING_CHRG).fte_charge_code_id|| '*');
		--ast_loading_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_AST_LOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.ast_loading_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ld_dtl_chrg_fail;
		       END IF;
		END IF;


		--unloading_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_UNLOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.unloading_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_dtl_chrg_fail;
		       END IF;
		END IF;


		--ast_unloading_chrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_AST_UNLOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.ast_unloading_chrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ud_dtl_chrg_fail;
		       END IF;
		END IF;



		--origin_surchrg

		l_sum:=l_sum+p_dleg_alloc_rec.origin_surchrg;

		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_ORIGIN_SURCHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.origin_surchrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_dtl_chrg_fail;
		       END IF;
		END IF;


		--destination_surchrg



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(C_DESTINATION_SURCHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*p_dleg_alloc_rec.destination_surchrg,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);


		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_dtl_chrg_fail;
		       END IF;
		END IF;


		--fac_loading_chrg



		IF (p_dleg_alloc_rec.fac_loading_chrg=0)
		THEN
			l_charge:=0;
		ELSE


			l_charge := GL_CURRENCY_API.convert_amount(
					     p_dleg_alloc_rec.fac_loading_currency,
					     l_freight_rec_common.currency_code,
					     SYSDATE,
					     'Corporate',
					     p_dleg_alloc_rec.fac_loading_chrg
					     );
		END IF;
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
		END IF;



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(F_LOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*l_charge,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_dtl_chrg_fail;
		       END IF;
		END IF;


		--fac_ast_loading_chrg

		IF (p_dleg_alloc_rec.fac_ast_loading_chrg= 0)
		THEN
			l_charge:=0;
		ELSE
			l_charge := GL_CURRENCY_API.convert_amount(
					     p_dleg_alloc_rec.fac_loading_currency,
					     l_freight_rec_common.currency_code,
					     SYSDATE,
					     'Corporate',
					     p_dleg_alloc_rec.fac_ast_loading_chrg
					     );
		END IF;
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
		END IF;



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(F_AST_LOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*l_charge,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_dtl_chrg_fail;
		       END IF;
		END IF;


		--fac_unloading_chrg

		IF ( p_dleg_alloc_rec.fac_unloading_chrg = 0)
		THEN
			l_charge:=0;
		ELSE

			l_charge := GL_CURRENCY_API.convert_amount(
					     p_dleg_alloc_rec.fac_unloading_currency,
					     l_freight_rec_common.currency_code,
					     SYSDATE,
					     'Corporate',
					     p_dleg_alloc_rec.fac_unloading_chrg
					     );
		END IF;
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
		END IF;

		l_sum:=l_sum+l_charge;

		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(F_UNLOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*l_charge,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_dtl_chrg_fail;
		       END IF;
		END IF;


		--fac_ast_unloading_chrg

		IF (p_dleg_alloc_rec.fac_ast_unloading_chrg = 0)
		THEN
			l_charge:=0;
		ELSE
			l_charge := GL_CURRENCY_API.convert_amount(
					     p_dleg_alloc_rec.fac_unloading_currency,
					     l_freight_rec_common.currency_code,
					     SYSDATE,
					     'Corporate',
					     p_dleg_alloc_rec.fac_ast_unloading_chrg
					     );
		END IF;
		IF (l_charge IS NULL)
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
		END IF;



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(F_AST_UNLOADING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*l_charge,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_dtl_chrg_fail;
		       END IF;
		END IF;


		--fac_handling_chrg

		IF ( p_dleg_alloc_rec.fac_handling_chrg = 0)
		THEN

			l_charge:=0;
		ELSE

			l_charge := GL_CURRENCY_API.convert_amount(
					     p_dleg_alloc_rec.fac_handling_currency,
					     l_freight_rec_common.currency_code,
					     SYSDATE,
					     'Corporate',
					     p_dleg_alloc_rec.fac_handling_chrg
					     );

		END IF;
		IF (l_charge IS NULL)
		THEN

			raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
		END IF;



		Insert_Dlv_Dtl_Level_Charge(
			 p_charge_type=>g_tl_freight_codes(F_HANDLING_CHRG).fte_charge_code_id,
			 p_line_type_code=>	'TLCHARGE',
			 p_charge=>p_factor*l_charge,
			 p_unit_charge=>NULL,
			 p_freight_rec=>l_freight_rec_common,
			 p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 x_output_cost_tab=>	x_output_cost_tab,
			 x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_dtl_chrg_fail;
		       END IF;
		END IF;

	END IF;

	l_freight_rec_common.billable_basis:=l_billable_basis;
	l_freight_rec_common.billable_uom:=l_billable_uom;
	l_freight_rec_common.billable_quantity:=l_billable_quantity;

	Insert_Dlv_Dtl_Level_Charge(
		p_charge_type=>	g_tl_freight_codes(C_SUMMARY).fte_summary_code_id,
		p_line_type_code=>	'SUMMARY',
		p_charge=>	p_factor*p_dleg_alloc_rec.total_dleg_charge,
		p_unit_charge=>NULL,
		p_freight_rec=>l_freight_rec_common,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_ins_sum_dtl_chrg_fail;
	       END IF;
	END IF;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_sum_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_sum_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_fuel_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_cm_dist_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_cm_dist_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_cm_dist_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ld_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dist_ld_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dist_ud_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dist_ud_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_carr_unit_basis THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_carr_unit_basis');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_unit_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_unit_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_time_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_time_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_flat_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_flat_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_stpoff_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_stpoff_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_outrt_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_outrt_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_hndl_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_hndl_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkday_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkday_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_wkend_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_wkend_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ld_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ld_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ld_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_as_ld_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_ud_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_ud_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_as_ud_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_as_ud_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_org_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_org_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_dst_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_dst_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ld_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ld_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ld_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ld_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_ud_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_ud_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_as_ud_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_as_ud_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_ins_f_hndl_dtl_chrg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_ins_f_hndl_dtl_chrg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Dlv_Dtl_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Dlv_Dtl_Price_Recs');


END  Create_Dlv_Dtl_Price_Recs;


PROCEDURE Alloc_Charges_To_Int_Details(
	p_trip_index 		IN 	NUMBER,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	p_detail_alloc_tab IN OUT NOCOPY TL_detail_alloc_TAB_TYPE ,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2)
IS

i NUMBER;
l_dummy_dleg_alloc_rec TL_dleg_alloc_rec_type;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Alloc_Charges_To_Int_Details','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	i:=p_detail_alloc_tab.FIRST;
	WHILE( i IS NOT NULL)
	LOOP

		l_dummy_dleg_alloc_rec.total_dleg_charge:=p_detail_alloc_tab(i).total_detail_charge;

		Create_Dlv_Dtl_Price_Recs(
			p_trip_index=>p_trip_index,
			p_factor=>1,
			p_dtl_rec=>FTE_TL_CACHE.g_tl_int_shipment_line_rows(i),
			p_dleg_alloc_rec=>l_dummy_dleg_alloc_rec,
			p_cost_allocation_parameters=>p_cost_allocation_parameters,
			p_dim_weight=>NULL,
			p_only_summary_flag=>'Y',
			x_output_cost_tab=>x_output_cost_tab,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlv_dtl_fail;
		       END IF;
		END IF;

		i:=p_detail_alloc_tab.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Int_Details');

EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Int_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Int_Details');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_Charges_To_Int_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_Charges_To_Int_Details');

END Alloc_Charges_To_Int_Details;


--Allocates charges from the dleg down to the delivery details ,a s per CA
--algorithm

PROCEDURE Alloc_To_Details(
	p_trip_index IN NUMBER,
	p_dleg_alloc_tab IN TL_dleg_alloc_TAB_TYPE ,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS


	l_dleg_index_first NUMBER;
	l_dleg_index_last NUMBER;
	i NUMBER;
	l_factor NUMBER;
	l_map_index NUMBER;
	l_carrier_weight_uom VARCHAR2(30);
	l_carrier_volume_uom VARCHAR2(30);
	l_quantity NUMBER;

	l_weight NUMBER;
	l_volume NUMBER;
	l_dim_weight NUMBER;
	l_detail_summary NUMBER;
	l_parent_detail_summary NUMBER;
	l_uom VARCHAR2(30);

l_detail_alloc_tab TL_detail_alloc_TAB_TYPE;
l_detail_id NUMBER;
l_parent_detail_id NUMBER;
l_dtl_summary_only_flag VARCHAR2(1);
l_child_dleg_index_first NUMBER;
l_child_dleg_index_last NUMBER;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Alloc_To_Details','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_dleg_index_first:=
	 FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).delivery_leg_reference;
	l_carrier_weight_uom:=
	 FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).weight_uom;
	l_carrier_volume_uom:=
	 FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).volume_uom;

	IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
	THEN
		l_dleg_index_last:=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1
			).delivery_leg_reference;


	ELSE
		l_dleg_index_last:=FTE_TL_CACHE.g_tl_delivery_leg_rows.LAST + 1;

	END IF;

	i:=l_dleg_index_first;
	WHILE (( FTE_TL_CACHE.g_tl_delivery_leg_rows.EXISTS(i)) AND
	(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).trip_id=
	FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i <l_dleg_index_last))
	LOOP

		IF(NOT(FTE_TL_CACHE.g_tl_delivery_detail_hash.EXISTS(
			FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_id)))
		THEN

			--FTE_FREIGHT_PRICING_UTIL.setmsg (
			--	p_api=>'Alloc_To_Details',
			--	p_exc=>'g_tl_no_dtl_on_dleg',
			--	p_delivery_leg_id=> FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_leg_id);

			--raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_dtl_on_dleg;

			l_map_index:=NULL;

		ELSE

			l_map_index:=
			FTE_TL_CACHE.g_tl_delivery_detail_hash(
				FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_id);


		END IF;



		WHILE((l_map_index IS NOT NULL) AND (FTE_TL_CACHE.g_tl_delivery_detail_map.EXISTS(l_map_index))
		AND(FTE_TL_CACHE.g_tl_delivery_detail_map(
			l_map_index).delivery_id=
			FTE_TL_CACHE.g_tl_delivery_leg_rows(i).delivery_id))
		LOOP
			l_dim_weight:=NULL;

			IF((p_cost_allocation_parameters.principal_alloc_basis=
			FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
			AND(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).weight>0))
			THEN

				l_quantity:=
				  FTE_TL_CACHE.g_tl_shipment_line_rows(
					FTE_TL_CACHE.g_tl_delivery_detail_map(
					l_map_index).delivery_detail_id
					).gross_weight;
				l_uom:=
				 FTE_TL_CACHE.g_tl_shipment_line_rows(
				 FTE_TL_CACHE.g_tl_delivery_detail_map(
				 l_map_index).delivery_detail_id).weight_uom_code;

				l_quantity:=
				FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_uom,
				l_carrier_weight_uom,
				l_quantity,
				0);

				IF (l_quantity IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
				END IF;

				l_weight:=l_quantity;

				l_quantity:=FTE_TL_CACHE.g_tl_shipment_line_rows(
					FTE_TL_CACHE.g_tl_delivery_detail_map(
					l_map_index).delivery_detail_id).volume;
				l_uom:=
				 FTE_TL_CACHE.g_tl_shipment_line_rows(
				  FTE_TL_CACHE.g_tl_delivery_detail_map(
				  l_map_index).delivery_detail_id
				  ).volume_uom_code;

				l_quantity:=
				 FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_uom,
				l_carrier_volume_uom,
				l_quantity,
				0);

				IF (l_quantity IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
				END IF;

				l_volume:=l_quantity;



				FTE_TL_CACHE.Calculate_Dimensional_Weight(
					p_carrier_pref_rec=>FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index),
					p_weight=>l_weight,
					p_volume=>l_volume,
					x_dim_weight=>l_dim_weight,
					x_return_status=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail;
				       END IF;
				END IF;


				l_factor:=l_dim_weight/
				 FTE_TL_CACHE.g_tl_delivery_leg_rows(i).weight;

			ELSIF((
			 p_cost_allocation_parameters.principal_alloc_basis
			 =FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
			AND(FTE_TL_CACHE.g_tl_delivery_leg_rows(i).volume>0))
			THEN

				l_quantity:=
				 FTE_TL_CACHE.g_tl_shipment_line_rows(
				 FTE_TL_CACHE.g_tl_delivery_detail_map(
				 l_map_index).delivery_detail_id).volume;
				l_uom:=
				 FTE_TL_CACHE.g_tl_shipment_line_rows(
				  FTE_TL_CACHE.g_tl_delivery_detail_map(
				  l_map_index).delivery_detail_id
				  ).volume_uom_code;

				l_quantity:=
				 FTE_FREIGHT_PRICING_UTIL.convert_uom(
				l_uom,
				l_carrier_volume_uom,
				l_quantity,
				0);

				IF (l_quantity IS NULL)
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
				END IF;
				l_factor:=l_quantity/
				 FTE_TL_CACHE.g_tl_delivery_leg_rows(i).volume;

			ELSE
				l_factor:=0;

			END IF;


			IF ((FTE_TL_CACHE.g_tl_delivery_leg_rows(i).is_parent_dleg IS NULL)
			OR (FTE_TL_CACHE.g_tl_delivery_leg_rows(i).is_parent_dleg='N'))
			THEN
				l_dtl_summary_only_flag:='N';

			ELSE
				l_dtl_summary_only_flag:='Y';
			END IF;

			Create_Dlv_Dtl_Price_Recs(
			 	p_trip_index=>	p_trip_index,
			 	p_factor=>	l_factor,
			 	p_dtl_rec=>	FTE_TL_CACHE.g_tl_shipment_line_rows(
			 		FTE_TL_CACHE.g_tl_delivery_detail_map(
			 		l_map_index).delivery_detail_id),
			 	p_dleg_alloc_rec=>	p_dleg_alloc_tab(FTE_TL_CACHE.g_tl_delivery_leg_rows(
			 		i).delivery_leg_id) ,
			 	p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			 	p_dim_weight=>l_dim_weight,
				p_only_summary_flag=>l_dtl_summary_only_flag,
			 	x_output_cost_tab=>	x_output_cost_tab,
			 	x_return_status=>	l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			       THEN
				  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlv_dtl_fail;
			       END IF;
			END IF;

			l_detail_summary:=l_factor * p_dleg_alloc_tab(FTE_TL_CACHE.g_tl_delivery_leg_rows(
			 		i).delivery_leg_id).total_dleg_charge;

			l_detail_id:=FTE_TL_CACHE.g_tl_delivery_detail_map(
			 		l_map_index).delivery_detail_id;



			l_parent_detail_id:=FTE_TL_CACHE.g_tl_shipment_line_rows(l_detail_id).parent_delivery_detail_id;

			IF ((l_parent_detail_id IS NOT NULL) AND
				(FTE_TL_CACHE.g_tl_int_shipment_line_rows.EXISTS(l_parent_detail_id)))
			THEN

				IF(l_detail_alloc_tab.EXISTS(l_parent_detail_id))
				THEN
					l_detail_alloc_tab(l_parent_detail_id).total_detail_charge:=
						l_detail_alloc_tab(l_parent_detail_id).total_detail_charge+l_detail_summary;
				ELSE
					l_detail_alloc_tab(l_parent_detail_id).total_detail_charge:=l_detail_summary;

				END IF;

			END IF;

			l_map_index:=l_map_index+1;

		END LOOP;



		i:=i+1;
	END LOOP;

	-- Details of Child dlegs

	l_child_dleg_index_first:=
	 FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).child_dleg_reference;
	IF (l_child_dleg_index_first IS NOT NULL)
	THEN

		IF (FTE_TL_CACHE.g_tl_trip_rows.EXISTS(p_trip_index+1))
		THEN
			l_child_dleg_index_last:=
			FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1
				).child_dleg_reference;


		ELSE
			l_child_dleg_index_last:=FTE_TL_CACHE.g_tl_chld_delivery_leg_rows.LAST + 1;

		END IF;

		i:=l_child_dleg_index_first;
		WHILE (( FTE_TL_CACHE.g_tl_chld_delivery_leg_rows.EXISTS(i)) AND
		(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).trip_id=
		FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id) AND (i <l_child_dleg_index_last))
		LOOP

			IF(NOT(FTE_TL_CACHE.g_tl_delivery_detail_hash.EXISTS(
				FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_id)))
			THEN

				--FTE_FREIGHT_PRICING_UTIL.setmsg (
				--	p_api=>'Alloc_To_Details',
				--	p_exc=>'g_tl_no_dtl_on_dleg',
				--	p_delivery_leg_id=> FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_leg_id);


				--raise FTE_FREIGHT_PRICING_UTIL.g_tl_no_dtl_on_dleg;

				l_map_index:=NULL;
			ELSE

				l_map_index:=
				FTE_TL_CACHE.g_tl_delivery_detail_hash(
					FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_id);


			END IF;



			WHILE((l_map_index IS NOT NULL) AND (FTE_TL_CACHE.g_tl_delivery_detail_map.EXISTS(l_map_index)
			)
			AND(FTE_TL_CACHE.g_tl_delivery_detail_map(
				l_map_index).delivery_id=
				FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).delivery_id))
			LOOP
				l_dim_weight:=NULL;

				IF((p_cost_allocation_parameters.principal_alloc_basis=
				FTE_RTG_GLOBALS.G_CA_WEIGHT_BASIS)
				AND(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).weight>0))
				THEN

					l_quantity:=
					  FTE_TL_CACHE.g_tl_shipment_line_rows(
						FTE_TL_CACHE.g_tl_delivery_detail_map(
						l_map_index).delivery_detail_id
						).gross_weight;
					l_uom:=
					 FTE_TL_CACHE.g_tl_shipment_line_rows(
					 FTE_TL_CACHE.g_tl_delivery_detail_map(
					 l_map_index).delivery_detail_id).weight_uom_code;

					l_quantity:=
					FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_uom,
					l_carrier_weight_uom,
					l_quantity,
					0);

					IF (l_quantity IS NULL)
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
					END IF;

					l_weight:=l_quantity;

					l_quantity:=FTE_TL_CACHE.g_tl_shipment_line_rows(
						FTE_TL_CACHE.g_tl_delivery_detail_map(
						l_map_index).delivery_detail_id).volume;
					l_uom:=
					 FTE_TL_CACHE.g_tl_shipment_line_rows(
					  FTE_TL_CACHE.g_tl_delivery_detail_map(
					  l_map_index).delivery_detail_id
					  ).volume_uom_code;

					l_quantity:=
					 FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_uom,
					l_carrier_volume_uom,
					l_quantity,
					0);

					IF (l_quantity IS NULL)
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
					END IF;

					l_volume:=l_quantity;



					FTE_TL_CACHE.Calculate_Dimensional_Weight(
						p_carrier_pref_rec=>FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index),
						p_weight=>l_weight,
						p_volume=>l_volume,
						x_dim_weight=>l_dim_weight,
						x_return_status=>l_return_status);

					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
					THEN
					       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					       THEN
						  raise FTE_FREIGHT_PRICING_UTIL.g_tl_calc_dim_weight_fail;
					       END IF;
					END IF;


					l_factor:=l_dim_weight/
					 FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).weight;

				ELSIF((
				 p_cost_allocation_parameters.principal_alloc_basis
				 =FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS)
				AND(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).volume>0))
				THEN

					l_quantity:=
					 FTE_TL_CACHE.g_tl_shipment_line_rows(
					 FTE_TL_CACHE.g_tl_delivery_detail_map(
					 l_map_index).delivery_detail_id).volume;
					l_uom:=
					 FTE_TL_CACHE.g_tl_shipment_line_rows(
					  FTE_TL_CACHE.g_tl_delivery_detail_map(
					  l_map_index).delivery_detail_id
					  ).volume_uom_code;

					l_quantity:=
					 FTE_FREIGHT_PRICING_UTIL.convert_uom(
					l_uom,
					l_carrier_volume_uom,
					l_quantity,
					0);

					IF (l_quantity IS NULL)
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail;
					END IF;
					l_factor:=l_quantity/
					 FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).volume;

				ELSE
					l_factor:=0;

				END IF;


				IF ((FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).is_parent_dleg IS NULL)
				OR (FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(i).is_parent_dleg='N'))
				THEN
					l_dtl_summary_only_flag:='N';

				ELSE
					l_dtl_summary_only_flag:='Y';
				END IF;

				Create_Dlv_Dtl_Price_Recs(
					p_trip_index=>	p_trip_index,
					p_factor=>	l_factor,
					p_dtl_rec=>	FTE_TL_CACHE.g_tl_shipment_line_rows(
						FTE_TL_CACHE.g_tl_delivery_detail_map(
						l_map_index).delivery_detail_id),
					p_dleg_alloc_rec=>	p_dleg_alloc_tab(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(
						i).delivery_leg_id) ,
					p_cost_allocation_parameters=>	p_cost_allocation_parameters,
					p_dim_weight=>l_dim_weight,
					p_only_summary_flag=>l_dtl_summary_only_flag,
					x_output_cost_tab=>	x_output_cost_tab,
					x_return_status=>	l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
				       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				       THEN
					  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlv_dtl_fail;
				       END IF;
				END IF;

				l_detail_summary:=l_factor * p_dleg_alloc_tab(FTE_TL_CACHE.g_tl_chld_delivery_leg_rows(
						i).delivery_leg_id).total_dleg_charge;

				l_detail_id:=FTE_TL_CACHE.g_tl_delivery_detail_map(
						l_map_index).delivery_detail_id;


				l_parent_detail_id:=FTE_TL_CACHE.g_tl_shipment_line_rows(l_detail_id).parent_delivery_detail_id;

				IF ((l_parent_detail_id IS NOT NULL) AND
					(FTE_TL_CACHE.g_tl_int_shipment_line_rows.EXISTS(l_parent_detail_id)))
				THEN

					IF(l_detail_alloc_tab.EXISTS(l_parent_detail_id))
					THEN
						l_detail_alloc_tab(l_parent_detail_id).total_detail_charge:=
							l_detail_alloc_tab(l_parent_detail_id).total_detail_charge+l_detail_summary;
					ELSE
						l_detail_alloc_tab(l_parent_detail_id).total_detail_charge:=l_detail_summary;

					END IF;

				END IF;

				l_map_index:=l_map_index+1;

			END LOOP;



			i:=i+1;
		END LOOP;

	END IF;


	Alloc_Charges_To_Int_Details(
		p_trip_index=>p_trip_index,
		p_cost_allocation_parameters=>p_cost_allocation_parameters,
		p_detail_alloc_tab=>l_detail_alloc_tab,
		x_output_cost_tab=>x_output_cost_tab,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_alloc_int_dtl_fail;
	       END IF;
	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_mdc_alloc_int_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_To_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_mdc_alloc_int_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');


WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_no_dtl_on_dleg THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_To_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_no_dtl_on_dleg');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_To_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');

   WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlv_dtl_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_To_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_dlv_dtl_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Alloc_To_Details',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Alloc_To_Details');


END  Alloc_To_Details;


--Creates the trip,stop,dleg level price recs
--
PROCEDURE Create_Summary_Price_Recs(
	p_trip_index IN NUMBER,
	p_trip_charges_rec IN FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_TAB_TYPE,
	p_dleg_alloc_tab IN TL_dleg_alloc_tab_type,
	p_cost_allocation_parameters  IN TL_allocation_params_rec_type,
	x_output_cost_tab IN OUT NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status OUT NOCOPY Varchar2) IS

	i NUMBER;
	l_count NUMBER;
	l_stop_count NUMBER;
l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Create_Summary_Price_Recs','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	Create_Trip_Level_Price_Recs(
		p_trip_index=>	p_trip_index,
		p_trip_charges_rec=>	p_trip_charges_rec,
		p_stop_charges_tab=>	p_stop_charges_tab ,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
	          raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_trp_price_recs_fail;
	       END IF;
	END IF;

-- p_stop_charges_tab is indexed by stop_id, insert stop charges in order
-- of sequence number

        i:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).stop_reference;

	l_count:=0;
	l_stop_count:=FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).number_of_stops;
	WHILE (l_count < l_stop_count)
	LOOP

		--Multiple change dont index p_stop_charges_tab by stop id use stop index
		Create_Stop_Level_Price_Recs(
			p_trip_index=>	p_trip_index ,
			p_stop_charges_rec=>	p_stop_charges_tab(i) , --Multiple change
			p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			x_output_cost_tab=>	x_output_cost_tab,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_stp_price_recs_fail;
		       END IF;
		END IF;

		l_count:=l_count+1;
		i:=i+1;
	END LOOP;


	i:=p_dleg_alloc_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP


		Create_Dleg_Level_Price_Recs(
			p_trip_index=>	p_trip_index,
			p_dleg_alloc_rec=>	p_dleg_alloc_tab(i),
			p_cost_allocation_parameters=>p_cost_allocation_parameters,
			x_output_cost_tab=>	x_output_cost_tab,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlg_price_recs_fail;
		       END IF;
		END IF;


		i:=p_dleg_alloc_tab.NEXT(i);

	END LOOP;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Summary_Price_Recs');
	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_trp_price_recs_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Summary_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_trp_price_recs_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Summary_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_stp_price_recs_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Summary_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_stp_price_recs_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Summary_Price_Recs');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_dlg_price_recs_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Summary_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_dlg_price_recs_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Summary_Price_Recs');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Create_Summary_Price_Recs',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Create_Summary_Price_Recs');


END Create_Summary_Price_Recs;

PROCEDURE TL_COST_ALLOCATION(
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN
		FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	x_output_cost_tab 	IN OUT 	NOCOPY
		FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status 	OUT 	NOCOPY	VARCHAR2) IS


 	l_stop_input_hash DBMS_UTILITY.NUMBER_ARRAY;
	l_stop_output_hash DBMS_UTILITY.NUMBER_ARRAY;
	l_dleg_alloc_tab TL_dleg_alloc_TAB_TYPE;

l_return_status VARCHAR2(1);

	l_log_level	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;

	i NUMBER;
	l_distance_uom		WSH_TRIP_STOPS.distance_uom%type;
	l_stop_index_low	NUMBER;
	l_stop_index_high	NUMBER;

  	CURSOR c_lock_wts(c_trip_id NUMBER)
    	IS
    	SELECT stop_id
    	FROM wsh_trip_stops
    	WHERE  trip_id = c_trip_id
    	FOR UPDATE NOWAIT;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'TL_COST_ALLOCATION','start');


	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 	Initialize_Freight_Codes(
		x_return_status=>	l_return_status);


	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_init_fr_codes_fail;
	       END IF;
	END IF;

	--3756411
	--Clear bulk arrays
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		Clear_Bulk_Arrays(x_return_status=>x_return_status);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_clr_bulk_arr_fail;
		       END IF;
		END IF;


	END IF;


	Create_Stop_Hashes(
		p_trip_index=>	p_trip_index ,
		p_stop_charges_tab=>	p_stop_charges_tab ,
		x_stop_input_hash=>	l_stop_input_hash,
		x_stop_output_hash=>	l_stop_output_hash,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_stp_hash_fail;
	       END IF;
	END IF;


	IF(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).dead_head='N')
	THEN

		Alloc_Loading_Stopoff_To_Dlegs(
			p_trip_index=>	p_trip_index,
			p_trip_charges_rec=>	p_trip_charges_rec,
			p_stop_charges_tab=>	p_stop_charges_tab,
			p_stop_input_hash=>	l_stop_input_hash,
			p_stop_output_hash=>	l_stop_output_hash,
			p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			x_dleg_alloc_tab=>	l_dleg_alloc_tab,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_ld_stpoff_dleg_fail;
		       END IF;
		END IF;



		 Alloc_Charges_To_Dlegs(
			p_trip_index=>	p_trip_Index,
			p_trip_charges_rec=>	p_trip_charges_rec,
			p_stop_charges_tab=>	p_stop_charges_tab,
			p_stop_input_hash=>	l_stop_input_hash,
			p_stop_output_hash=>	l_stop_output_hash,
			p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			x_dleg_alloc_tab=>	l_dleg_alloc_tab,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_chrges_dleg_fail;
		       END IF;
		END IF;


		Alloc_To_Details(
			p_trip_index=>	p_trip_index,
			p_dleg_alloc_tab=>	l_dleg_alloc_tab,
			p_cost_allocation_parameters=>	p_cost_allocation_parameters,
			x_output_cost_tab=>	x_output_cost_tab,
			x_return_status=>	l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_to_dtls_fail;
		       END IF;
		END IF;
	END IF;

	Create_Summary_Price_Recs(
		p_trip_index=>	p_trip_index,
		p_trip_charges_rec=>	p_trip_charges_rec,
		p_stop_charges_tab=>	p_stop_charges_tab,
		p_dleg_alloc_tab=>	l_dleg_alloc_tab,
		p_cost_allocation_parameters=>	p_cost_allocation_parameters,
		x_output_cost_tab=>	x_output_cost_tab,
		x_return_status=>	l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
	       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
	       THEN
		  raise FTE_FREIGHT_PRICING_UTIL.g_tl_cr_summry_price_recs_fail;
	       END IF;
	END IF;


	--3756411
	--Clear bulk arrays
	IF (p_cost_allocation_parameters.output_type='T')
	THEN
		Bulk_Insert_Temp(x_return_status=>x_return_status);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_bulk_ins_tmp_fail;
		       END IF;
		END IF;


		Clear_Bulk_Arrays(x_return_status=>x_return_status);
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_clr_bulk_arr_fail;
		       END IF;
		END IF;


	END IF;



	FTE_FREIGHT_PRICING.print_fc_temp_rows(
	  p_fc_temp_rows  => x_output_cost_tab,
	  x_return_status => l_return_status);

	-- DBI bug3901280

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
	  'p_cost_allocation_parameters.output_type='||p_cost_allocation_parameters.output_type);
        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_trip_index='||p_trip_index);

	IF ((FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id <> FTE_TL_CACHE.FAKE_TRIP_ID) AND (p_cost_allocation_parameters.output_type='M' OR
	   (p_cost_allocation_parameters.output_type='T'
	    AND p_trip_index = FTE_TL_CACHE.g_tl_trip_rows.LAST))) THEN

          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trying to get lock of wsh_trip_stops...');
          OPEN c_lock_wts(FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).trip_id);
          CLOSE c_lock_wts;
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'got update lock of wsh_trip_stops');

	  l_stop_index_low := FTE_TL_CACHE.g_tl_trip_rows(p_trip_index).stop_reference;
	  IF p_cost_allocation_parameters.output_type='M' THEN
	    IF p_trip_index = FTE_TL_CACHE.g_tl_trip_rows.LAST THEN
	      l_stop_index_high := FTE_TL_CACHE.g_tl_trip_stop_rows.LAST - 1;
	    ELSE
	      l_stop_index_high := FTE_TL_CACHE.g_tl_trip_rows(p_trip_index+1).stop_reference - 2;
	    END IF;
	  ELSE
	    l_stop_index_high := FTE_TL_CACHE.g_tl_trip_stop_rows.LAST - 1;
	  END IF;
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_stop_index_low='||l_stop_index_low);
          FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_stop_index_high='||l_stop_index_high);

	  IF l_stop_index_low <= l_stop_index_high THEN

	    g_stop_id_tbl.DELETE;
	    g_distance_to_next_stop_tbl.DELETE;

	    FOR i in l_stop_index_low..l_stop_index_high LOOP
	      g_stop_id_tbl(i) := FTE_TL_CACHE.g_tl_trip_stop_rows(i).stop_id;
	      g_distance_to_next_stop_tbl(i) := FTE_TL_CACHE.g_tl_trip_stop_rows(i).distance_to_next_stop;
	    END LOOP;

	    l_distance_uom := FTE_TL_CACHE.g_tl_carrier_pref_rows(p_trip_index).distance_uom;

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'bulk updating wsh_trip_stops...');
	    FORALL i IN g_stop_id_tbl.FIRST..g_stop_id_tbl.LAST
	      UPDATE wsh_trip_stops
	      SET  	distance_to_next_stop = g_distance_to_next_stop_tbl(i),
	   	  	distance_uom = l_distance_uom
	      WHERE stop_id = g_stop_id_tbl(i);
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'bulk update wsh_trip_stops done');

	  ELSE -- l_stop_index_low <= l_stop_index_high
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
		'stop index range is wrong. wsh_trip_stops is not updated with distance');
	  END IF;
	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;
EXCEPTION

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_bulk_ins_tmp_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_bulk_ins_tmp_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');


  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_clr_bulk_arr_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_clr_bulk_arr_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');


  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_stp_hash_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_stp_hash_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_ld_stpoff_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_alloc_ld_stpoff_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_chrges_dleg_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_alloc_chrges_dleg_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_alloc_to_dtls_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_alloc_to_dtls_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');

  WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_cr_summry_price_recs_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_cr_summry_price_recs_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('TL_COST_ALLOCATION',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'TL_COST_ALLOCATION');


END TL_COST_ALLOCATION;


PROCEDURE TEST IS

    l_cost_allocation_parameters TL_allocation_params_rec_type;

    l_trip_rec  FTE_TL_CACHE.TL_trip_data_input_rec_type;
    l_stop_rec  FTE_TL_CACHE.TL_TRIP_STOP_INPUT_REC_TYPE;
    l_stop_tab  FTE_TL_CACHE.TL_trip_stop_input_tab_type;
    l_carrier_pref FTE_TL_CACHE.TL_carrier_pref_rec_type;
    l_dleg_rec FTE_TL_CACHE.TL_delivery_leg_rec_type;

    l_dtl_rec  FTE_FREIGHT_PRICING.shipment_line_rec_type;

    l_trip_charges_rec FTE_TL_CACHE.TL_trip_output_rec_type;
    l_stop_charges_tab FTE_TL_CACHE.TL_trip_stop_output_tab_type;
    l_stop_charges_rec FTE_TL_CACHE.TL_trip_stop_output_rec_type;

    l_return_status   VARCHAR2(1);
    l_output_cost_tab FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;
    l_map_rec FTE_TL_CACHE.TL_DLV_DETAIL_MAP_REC_TYPE;
    i NUMBER;
    l_dlv_id	NUMBER;
    l_map_index	NUMBER;


l_lane_rows dbms_utility.number_array;
l_schedule_rows dbms_utility.number_array;
l_vehicle_rows dbms_utility.number_array;

BEGIN


     -- apps initialize
     FND_GLOBAL.apps_initialize(1068,21623,660);

     -- initialize logging
     FTE_FREIGHT_PRICING_UTIL.initialize_logging(x_return_status =>
     l_return_status);





	l_lane_rows(1):=2609;
	l_schedule_rows(1):=NULL;
	l_vehicle_rows(1):=1201;

	FTE_TL_CACHE.TL_BUILD_CACHE_FOR_TRP_COMPARE(
	p_wsh_trip_id=> 1117828,
	p_lane_rows=>l_lane_rows,
	p_schedule_rows=>l_schedule_rows,
	p_vehicle_rows=>l_vehicle_rows,
	x_return_status=>l_return_status);


 	FTE_TL_CACHE.Display_Cache;



	--Populate trip charges

	 l_trip_charges_rec.trip_id:=1117828;
	 l_trip_charges_rec.base_dist_load_chrg:=75;
	 l_trip_charges_rec.base_dist_load_unit_chrg:=0.5;
	 l_trip_charges_rec.base_dist_unload_chrg:=0;
	 l_trip_charges_rec.base_dist_unload_unit_chrg:=0;
	 l_trip_charges_rec.base_unit_chrg:=200;
	 l_trip_charges_rec.base_unit_unit_chrg:=0.6;
	 l_trip_charges_rec.base_time_chrg:=75;
	 l_trip_charges_rec.base_time_unit_chrg:=0.5;
	 l_trip_charges_rec.base_flat_chrg:=150;
	 l_trip_charges_rec.stop_off_chrg:=80;
	 l_trip_charges_rec.out_of_route_chrg:=50;
	 l_trip_charges_rec.document_chrg:=0;
	 l_trip_charges_rec.handling_chrg:=130;
	 l_trip_charges_rec.handling_chrg_basis:=
	 FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	 l_trip_charges_rec.cm_discount_percent:=0;
	 l_trip_charges_rec.cm_discount_value:=0;
	 l_trip_charges_rec.currency:='USD';
	 l_trip_charges_rec.total_trip_rate:=555;
	--Populate stop charges

	l_stop_charges_rec.stop_id:=1261051;
	l_stop_charges_rec.trip_id:=1117828;
	l_stop_charges_rec.weekday_layover_chrg:=0;
	l_stop_charges_rec.weekend_layover_chrg:=0;
	l_stop_charges_rec.loading_chrg:=0;
	l_stop_charges_rec.loading_chrg_basis:=FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.ast_loading_chrg:=0;
	l_stop_charges_rec.ast_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.unloading_chrg:=0;
	l_stop_charges_rec.unloading_chrg_basis:=FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.ast_unloading_chrg:=0;
	l_stop_charges_rec.ast_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.origin_surchrg:=120;
	l_stop_charges_rec.destination_surchrg:=0;
	l_stop_charges_rec.fac_loading_chrg:=50;
	l_stop_charges_rec.fac_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_ast_loading_chrg:=0;
	l_stop_charges_rec.fac_ast_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_unloading_chrg:=0;
	l_stop_charges_rec.fac_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_ast_unloading_chrg:=0;
	l_stop_charges_rec.fac_ast_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_handling_chrg:=0;
	l_stop_charges_rec.fac_handling_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_currency:='USD';

	l_stop_charges_tab(1):=l_stop_charges_rec;


	l_stop_charges_rec.stop_id:=1261052;
	l_stop_charges_rec.trip_id:=1117828;
	l_stop_charges_rec.weekday_layover_chrg:=330;
	l_stop_charges_rec.weekend_layover_chrg:=10;
	l_stop_charges_rec.loading_chrg:=0;
	l_stop_charges_rec.loading_chrg_basis:=FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.ast_loading_chrg:=0;
	l_stop_charges_rec.ast_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.unloading_chrg:=0;
	l_stop_charges_rec.unloading_chrg_basis:=FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.ast_unloading_chrg:=25;
	l_stop_charges_rec.ast_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.origin_surchrg:=0;
	l_stop_charges_rec.destination_surchrg:=0;
	l_stop_charges_rec.fac_loading_chrg:=0;
	l_stop_charges_rec.fac_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_ast_loading_chrg:=0;
	l_stop_charges_rec.fac_ast_loading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_unloading_chrg:=55;
	l_stop_charges_rec.fac_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_ast_unloading_chrg:=0;
	l_stop_charges_rec.fac_ast_unloading_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_handling_chrg:=75;
	l_stop_charges_rec.fac_handling_chrg_basis:=
	FTE_RTG_GLOBALS.G_VOLUME_BASIS;
	l_stop_charges_rec.fac_currency:='USD';

	l_stop_charges_tab(2):=l_stop_charges_rec;





	l_cost_allocation_parameters.principal_alloc_basis:=FTE_RTG_GLOBALS.G_CA_VOLUME_BASIS;
	l_cost_allocation_parameters.distance_alloc_method:=
	FTE_RTG_GLOBALS.G_CA_DIRECT_DISTANCE;
	l_cost_allocation_parameters.tl_stop_alloc_method:=FTE_RTG_GLOBALS.G_CA_DELIVERY_STOP;
	l_cost_allocation_parameters.output_type:='T';
	l_cost_allocation_parameters.comparison_request_id:=101101;


	TL_COST_ALLOCATION(
	1,
	l_trip_charges_rec,
	l_stop_charges_tab,
	l_cost_allocation_parameters,
	l_output_cost_tab ,
	l_return_status);

	i:=l_output_cost_tab.FIRST;
	WHILE ( i IS NOT NULL)
	LOOP
		DisplayCostRec(l_output_cost_tab(i));

		i:=l_output_cost_tab.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.close_logs;
END TEST;


END  FTE_TL_COST_ALLOCATION;


/
