--------------------------------------------------------
--  DDL for Package FTE_LANE_SEARCH_QUERY_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LANE_SEARCH_QUERY_GEN" AUTHID CURRENT_USER AS
/* $Header: FTELNQYS.pls 120.0 2005/05/26 17:27:27 appldev noship $ */

-- ----------------------------------------------------------------------------------------
--
-- Tables and records for input
--

g_varchar2	CONSTANT	VARCHAR2(10) := 'VARCHAR2';
g_number	CONSTANT	VARCHAR2(10) := 'NUMBER';
g_date		CONSTANT	VARCHAR2(10) := 'DATE';

TYPE fte_regions_types IS RECORD
(region_id	NUMBER,
 region_type	NUMBER,
 country	VARCHAR2(100),
 country_code	VARCHAR2(10),
 state		VARCHAR2(100),
 state_code	VARCHAR2(10),
 city		VARCHAR2(100),
 city_code	VARCHAR2(10),
 postal_code_from VARCHAR2(30),
 postal_code_to	  VARCHAR2(30));

TYPE fte_lane_search_regions_tab IS TABLE OF fte_regions_types INDEX BY BINARY_INTEGER;

TYPE fte_lane_search_criteria_rec IS RECORD
(relax_flag		VARCHAR2(1), -- will dictate if relaxation occurs
 origin_zip_request	VARCHAR2(30), -- postal code entered
 dest_zip_request	VARCHAR2(30), -- postal code entered
 mode_of_transport	VARCHAR2(30),
 lane_number		VARCHAR2(30),
 carrier_id		NUMBER,
 carrier_name		VARCHAR2(360),
 commodity_catg_id	NUMBER,
 commodity		VARCHAR2(240),
 service_code		VARCHAR2(30),
 service		VARCHAR2(80),
-- equipment_code		VARCHAR2(30),
-- equipment		VARCHAR2(80),
 schedule_only_flag	VARCHAR2(1),
 dep_date_from		DATE,
 dep_date_to		DATE,
 arr_date_from		DATE,
 arr_date_to		DATE,
 lane_ids_list		VARCHAR2(2000),
 vehicle_id             NUMBER,
 effective_date         DATE,
 effective_date_type    VARCHAR2(10),
 tariff_name VARCHAR2(80)
 );

-- [08/30]Add check for Vehicle_id

TYPE bindvar_type IS RECORD
(bindvar	VARCHAR2(30),
 bindtype	VARCHAR2(10),
 bindvarindex	NUMBER);

TYPE bindvars IS TABLE OF bindvar_type INDEX BY BINARY_INTEGER;


--
-- Tables and records for output
--

PROCEDURE Create_Lane_Query(p_search_criteria		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_criteria_rec,
		       	    p_origins			IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
		       	    p_destinations		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
		       	    p_parent_origins		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes origins
		       	    p_parent_destinations	IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes dests
                            p_source_type               IN      VARCHAR2,
		       	    x_query1			OUT NOCOPY	VARCHAR2,
		       	    x_query2			OUT NOCOPY	VARCHAR2,
		       	    x_bindvars1			OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	    x_bindvars2			OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	    x_bindvars_common		OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	    x_bindvars_orderby		OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	    x_return_message		OUT NOCOPY	VARCHAR2,
		       	    x_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE Create_Schedule_Query(p_search_criteria	IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_criteria_rec,
		       	    p_origins			IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
		       	    p_destinations		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
		       	    p_parent_origins		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes origins
		       	    p_parent_destinations	IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes dests
		       	    x_query			OUT NOCOPY	VARCHAR2,
		       	    x_bindvars			OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	    x_return_message		OUT NOCOPY	VARCHAR2,
		       	    x_return_status		OUT NOCOPY	VARCHAR2);

PROCEDURE Create_Schedule_Clause(p_dep_date_from	IN	DATE,
	      			 p_dep_date_to		IN	DATE,
		       		 p_arr_date_from	IN	DATE,
		       	 	 p_arr_date_to		IN	DATE,
		       	 	 x_query		OUT NOCOPY	VARCHAR2,
		       	 	 x_bindvars		IN OUT	NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars,
		       	 	 x_return_message	OUT NOCOPY	VARCHAR2,
		       	 	 x_return_status	OUT NOCOPY	VARCHAR2);


  PROCEDURE Create_Rate_Chart_Query(p_parent_origins		IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
				    p_parent_destinations	IN	FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
				    p_origin_zip_request	IN	VARCHAR2,
				    p_dest_zip_request		IN	VARCHAR2,
				    p_carrier_name		IN	VARCHAR2,
				    p_tariff_name		IN	VARCHAR2,
				    x_query			OUT NOCOPY	VARCHAR2,
				    x_bindvars			OUT NOCOPY	FTE_LANE_SEARCH_QUERY_GEN.bindvars);

END FTE_LANE_SEARCH_QUERY_GEN;

 

/
