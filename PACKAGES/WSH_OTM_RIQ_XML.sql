--------------------------------------------------------
--  DDL for Package WSH_OTM_RIQ_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_RIQ_XML" AUTHID CURRENT_USER as
/* $Header: WSHGLRXS.pls 120.0.12010000.1 2008/07/29 06:08:00 appldev ship $ */

--This Procedure replaces calls to the FTE Rating(FTE_PROCESS_REQUESTS.FORMAT_CS_CALL)
--and FTE Routing Guide(FTE_FREIGHT_RATING_PUB.Get_Freight_Costs) with a call to OTM
--when OTM is installed

PROCEDURE	CALL_OTM_FOR_OM(
	x_source_line_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_TAB,
	x_source_header_tab		IN OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_TAB,
	p_source_type			IN		VARCHAR2,
	p_action			IN		VARCHAR2,
	x_source_line_rates_tab		OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_LINE_RATES_TAB,
	x_source_header_rates_tab	OUT NOCOPY	FTE_PROCESS_REQUESTS.FTE_SOURCE_HEADER_RATES_TAB,
	x_result_consolidation_id_tab  IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_carrier_id_tab        IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_service_level_tab     IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_mode_of_transport_tab IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_freight_term_tab      IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_result_transit_time_min_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_result_transit_time_max_tab	IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableNumbers,
	x_ship_method_code_tab         IN OUT NOCOPY WSH_NEW_DELIVERY_ACTIONS.TableVarchar30,
	x_return_status			OUT NOCOPY	VARCHAR2,
	x_msg_count			OUT NOCOPY	NUMBER,
	x_msg_data			OUT NOCOPY	VARCHAR2);


--For a given UOM the procedure checks in attribute15 of the mtl UOM table,
--if there is a value it returns that otherwise it returns the same UOM passed in.
--The API returns Success except when there is an unexpected error. It caches previously queried values to avoid hits to the database.

PROCEDURE Get_EBS_To_OTM_UOM(
	p_uom IN VARCHAR2,
	x_uom OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2);

--For the passed in UOM and class the procedure checks if the UOM exists for that class in the MTL UOM tables
--If not it checks if it exists in atribute15 of of a UOM for that UOM class. Otherwise returns null
--It caches previously queried values to avoid hits to the database.
--The API returns Success except when there is an unexpected error.
PROCEDURE Get_OTM_To_EBS_UOM(
	p_uom IN VARCHAR2,
	p_uom_class IN VARCHAR2,
	x_uom OUT NOCOPY VARCHAR2,
	x_return_status			OUT NOCOPY	VARCHAR2);

END WSH_OTM_RIQ_XML;




/
