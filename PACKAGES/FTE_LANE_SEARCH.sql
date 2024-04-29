--------------------------------------------------------
--  DDL for Package FTE_LANE_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LANE_SEARCH" AUTHID CURRENT_USER AS
/* $Header: FTELNSES.pls 120.1 2005/06/27 23:07:30 appldev ship $ */

  -- ----------------------------------------------------------------
  -- Name:		Search_Lanes
  -- Type:		Procedure
  --
  -- Description:	This procedure calls FTE_LANE_SEARCH_QUERY_GEN
  -- 			procedures to create the dynamic SQL.
  --			Binds the variables, executes the query, and
  --			prepares the results in SQL records and SQL
  --			types for returning to the calling procedure.
  --			Constraints checking is done for lanes if
  --			a delivery_id or delivery_leg_id is present.
  --
  -- Input:		p_search_type	'L' = lanes; 'S' = schedules
  --			p_source_type	'L' = lanes; 'R' = rating
  -- 			                <currently not used>
  -- 			p_num_results	maximum number of results
  --					desired (OA should be 200)
  -- -----------------------------------------------------------------
PROCEDURE Search_Lanes(p_search_criteria	IN fte_search_criteria_rec,
		       p_search_type		IN VARCHAR2, -- 'L' for lanes, 'S' for schedules
		       p_source_type		IN VARCHAR2, -- 'L' for lane search, 'R' for rating
		       p_num_results		IN NUMBER,
		       x_lane_results		OUT NOCOPY  fte_lane_tab,
		       x_schedule_results	OUT NOCOPY  fte_schedule_tab,
		       x_return_message		OUT NOCOPY  VARCHAR2,
		       x_return_status		OUT NOCOPY  VARCHAR2);

 -- ----------------------------------------------------------------
-- Name:		Search_Lanes
-- Type:		Procedure
--
-- Description:	OverLoaded method for the above search_lanes. This
-- will be called if we have more than one set of search criteria
-- Duplicate fetches in the search would be removed
-- p_search_type	'L' - Lanes
--                'S' - Scheduldes
-- Limitations:
--     and p_source_type = 'R'
-- -----------------------------------------------------------------

PROCEDURE Search_Lanes( p_search_criteria      IN      fte_search_criteria_tab,
                        p_num_results          IN      NUMBER,
                        p_search_type          IN      VARCHAR2,
                        x_lane_results         OUT NOCOPY      fte_lane_tab,
                        x_schedule_results     OUT NOCOPY      fte_schedule_tab,
                        x_return_message       OUT NOCOPY      VARCHAR2,
                        x_return_status        OUT NOCOPY      VARCHAR2);

PROCEDURE Get_Rate_Chart_Ids(p_search_criteria	IN fte_search_criteria_rec,
			     p_num_results	IN NUMBER,
			     x_rate_chart_ids	OUT NOCOPY  STRINGARRAY,
			     x_return_status	OUT NOCOPY  VARCHAR2);

PROCEDURE Get_Transit_Time(p_ship_from_loc_id IN  NUMBER,
                           p_ship_to_site_id  IN  NUMBER,
                           p_carrier_id       IN  NUMBER,
                           p_service_code     IN  VARCHAR2,
                           p_mode_code        IN  VARCHAR2,
                           p_from             IN  VARCHAR2,
                           x_transit_time     OUT NOCOPY NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2);

-- will cache transit time given a ship method by maintaining ship method
-- and transit time with same index for corresponding ship method-transit time
-- combination
TYPE t_ship_method_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_transit_time_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

g_ship_method_tab     t_ship_method_tab;
g_transit_time_tab    t_transit_time_tab;

END FTE_LANE_SEARCH;

 

/
