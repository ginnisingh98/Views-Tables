--------------------------------------------------------
--  DDL for Package FTE_TL_COST_ALLOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TL_COST_ALLOCATION" AUTHID CURRENT_USER AS
/* $Header: FTEVTLAS.pls 120.0 2005/05/26 18:12:06 appldev noship $ */

C_LOADED_DISTANCE_RT 	NUMBER:=10;
C_UNLOADED_DISTANCE_RT	NUMBER:=11;
C_UNIT_WEIGHT_RT	NUMBER:= 12;
C_UNIT_VOLUME_RT NUMBER:=13;
C_UNIT_CONTAINER_RT	NUMBER:=14;
C_UNIT_PALLET_RT NUMBER:=15;
C_TIME_RT	NUMBER:=16;
C_FLAT_RT	NUMBER:=17;
C_CONTINUOUS_MOVE_DISTANCE_RT	NUMBER:=18;

C_MIN_DISTANCE_CHRG	NUMBER:=19;
C_MIN_UNIT_CHRG	NUMBER:=20;
C_MIN_TIME_CHRG	NUMBER:=21;

C_STOP_OFF_CHRG	NUMBER:=22;
C_OUT_OF_ROUTE_CHRG	NUMBER:=23;
C_DOCUMENT_CHRG	NUMBER:=24;
C_HANDLING_CHRG NUMBER:=25;

C_LOADING_CHRG NUMBER:=26;
C_AST_LOADING_CHRG NUMBER:=27;
C_UNLOADING_CHRG NUMBER:=28;
C_AST_UNLOADING_CHRG NUMBER:=29;
C_WEEKEND_LAYOVER_CHRG NUMBER:=30;
C_WEEKDAY_LAYOVER_CHRG NUMBER:=31;
C_ORIGIN_SURCHRG NUMBER:=32;
C_DESTINATION_SURCHRG NUMBER:=33;
C_CONTINUOUS_MOVE_DISCOUNT NUMBER:=34;
F_LOADING_CHRG NUMBER:=35;
F_AST_LOADING_CHRG NUMBER:=36;
F_UNLOADING_CHRG NUMBER:=37;
F_AST_UNLOADING_CHRG  NUMBER:=38;
F_HANDLING_CHRG NUMBER:=39;

C_FUEL_CHRG NUMBER:=40;
C_SUMMARY NUMBER:=41;



TYPE TL_allocation_params_rec_type IS RECORD(

principal_alloc_basis          VARCHAR2(30),
distance_alloc_method          VARCHAR2(30),
tl_stop_alloc_method           VARCHAR2(30),
output_type                    VARCHAR2(1),
comparison_request_id 		NUMBER);


TYPE TL_freight_code_rec_type IS RECORD(
name 			VARCHAR2(60),
summary_name		VARCHAR2(60),
fte_price_code_id	NUMBER,
fte_charge_code_id	NUMBER,
fte_summary_code_id	NUMBER);

TYPE TL_freight_code_tab_type IS TABLE OF TL_freight_code_rec_type INDEX BY BINARY_INTEGER;

g_tl_freight_codes TL_freight_code_tab_type;

PROCEDURE TL_COST_ALLOCATION(
	p_trip_index 		IN 	NUMBER,
	p_trip_charges_rec 	IN 	FTE_TL_CACHE.TL_trip_output_rec_type ,
	p_stop_charges_tab 	IN 	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	p_cost_allocation_parameters  IN	TL_allocation_params_rec_type,
	x_output_cost_tab 	IN OUT 	NOCOPY FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type,
	x_return_status 	OUT 	NOCOPY	VARCHAR2);




PROCEDURE Scale_Trip_Charges(
	p_discount IN NUMBER,
	x_trip_charges_rec IN OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Scale_Stop_Charges(
	p_discount IN NUMBER,
	x_stop_charges_rec IN OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_OUTPUT_REC_TYPE,
	x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE Get_Total_Trip_Cost(
	p_trip_index IN NUMBER,
	p_trip_charges_rec IN FTE_TL_CACHE.TL_TRIP_OUTPUT_REC_TYPE,
	p_stop_charges_tab IN FTE_TL_CACHE.TL_TRIP_STOP_OUTPUT_TAB_TYPE,
	x_charge IN OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY Varchar2);

PROCEDURE Get_Cost_Allocation_Parameters(
	x_cost_allocation_parameters IN OUT NOCOPY TL_allocation_params_rec_type,
	x_return_status OUT NOCOPY Varchar2);

PROCEDURE TEST;

END FTE_TL_COST_ALLOCATION;

 

/
