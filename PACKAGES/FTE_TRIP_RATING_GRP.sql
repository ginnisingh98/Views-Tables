--------------------------------------------------------
--  DDL for Package FTE_TRIP_RATING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TRIP_RATING_GRP" AUTHID CURRENT_USER AS
/* $Header: FTEGTRRS.pls 120.2 2005/07/15 14:10:20 susurend ship $ */


TYPE Sort_Value_Rec_Type IS RECORD(
value dbms_utility.number_array
);

TYPE Sort_Value_Tab_Type IS TABLE OF  Sort_Value_Rec_Type INDEX BY BINARY_INTEGER;



   TYPE action_param_rec IS RECORD (
     caller         VARCHAR2(30),
     event          VARCHAR2(30),
     action         VARCHAR2(30),
     trip_id_list   WSH_UTIL_CORE.id_tab_type);   -- list of trip_ids





PROCEDURE Sort(
	p_values_tab IN Sort_Value_Tab_Type,
	p_sort_type IN VARCHAR2,--To support variations in the future
	x_sorted_index  OUT NOCOPY dbms_utility.number_array,
	x_return_status OUT NOCOPY VARCHAR2);



 -- Public Procedures --



-- +======================================================================+
--   Procedure :
--           Rate_Trip
--
--   Description:
--           Rate Trip from various event points
--   Inputs:
--           p_action_params            => parameters identifying the
--                                         action to be performed
--                    -> caller -> 'FTE','WSH'
--                    -> event  -> 'TP-RELEASE','SHIP-CONFIRM','RE-RATING'
--                    -> action -> 'RATE'
--                    -> trip_id -> valid wsh trip_id
--           p_commit                   => FND_API.G_FALSE / G_TRUE
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+


   PROCEDURE Rate_Trip (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_action_params            IN  FTE_TRIP_RATING_GRP.action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2);

--      This API is called directly from the trip re-rating concurrent program
--      The input to it should be either wsh trip id or wsh trip name

PROCEDURE Rate_Trip_conc (
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_trip_id             IN     NUMBER   DEFAULT NULL,
        p_trip_name           IN     VARCHAR2 DEFAULT NULL );

-- +======================================================================+
--   Procedure :
--           Move_Records_To_Main
--
--   Description:
--           Move rates from temp table to main table
--   Inputs:
--           p_trip_id          => trip_id (required)
--           p_lane_id          => lane_id  (either lane_id or schedule_id
--                                           required)
--           p_schedule_id      => schedule_id
--           p_service_type_code  => service_type_code
--           p_comparison_request_id => comparison_request_id (required)
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+


PROCEDURE Move_Records_To_Main(
	p_trip_id           IN NUMBER,
	p_lane_id           IN NUMBER,
	p_schedule_id       IN NUMBER,
        p_service_type_code IN VARCHAR2 DEFAULT NULL,
	p_comparison_request_id IN NUMBER,
	p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	x_return_status OUT NOCOPY VARCHAR2);



-- +======================================================================+
--   Procedure :
--           Delete Main Records
--
--   Description:
--           Deletes all rates for a trip from WSH_FREIGHT_COSTS table
--   Inputs:
--           p_trip_id          => trip_id
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+


PROCEDURE Delete_Main_Records(
	p_trip_id IN NUMBER,
	p_init_prc_log IN VARCHAR2 DEFAULT 'Y',
	x_return_status OUT NOCOPY VARCHAR2);


-- +======================================================================+
--   Procedure :
--           Compare_Trip_Rates
--
--   Description:
--           Compare trip rates
--   Inputs:
--           p_trip_id  IN NUMBER       => a valid wsh trip id
--           p_lane_sched_id_tab        => lane_ids or schedule_ids
--           p_lane_sched_tab           => 'L' or 'S'  (Lane or Schedule)
--           p_service_type_tab         => service type codes
--           p_vehicle_id_tab           => vehicle item ids
--           p_event                    => Default 'FTE_TRIP_COMP'
--           p_commit                   => FND_API.G_FALSE / G_TRUE
--   Output:
--           x_request_id               => handle to table fte_freight_costs_temp
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+


PROCEDURE Compare_Trip_Rates (
	             p_api_version              IN  NUMBER DEFAULT 1.0,
	             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	             p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	             p_trip_id                  IN  NUMBER DEFAULT NULL,
	             p_lane_sched_id_tab        IN  FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	             p_lane_sched_tab           IN  FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	             p_mode_tab                 IN  FTE_CODE_TAB_TYPE,
	             p_service_type_tab         IN  FTE_CODE_TAB_TYPE,
	      	     p_vehicle_type_tab      	IN  FTE_ID_TAB_TYPE,
	             p_dep_date                 IN  DATE  DEFAULT sysdate,
	             p_arr_date                 IN  DATE  DEFAULT sysdate,
	             p_event                    IN  VARCHAR2 DEFAULT 'FTE_TRIP_COMP',
	             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	             x_request_id               OUT NOCOPY NUMBER,
	             x_lane_sched_id_tab        OUT  NOCOPY FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	             x_lane_sched_tab           OUT  NOCOPY FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	             x_vehicle_type_tab    	OUT  NOCOPY FTE_ID_TAB_TYPE,--Vehicle Type Id
	             x_mode_tab                 OUT  NOCOPY FTE_CODE_TAB_TYPE,
	             x_service_type_tab         OUT NOCOPY FTE_CODE_TAB_TYPE,
	             x_sum_rate_tab             OUT NOCOPY FTE_ID_TAB_TYPE,
	             x_sum_rate_curr_tab        OUT NOCOPY FTE_CODE_TAB_TYPE,
	             x_return_status            OUT NOCOPY  VARCHAR2,
	             x_msg_count                OUT NOCOPY  NUMBER,
	             x_msg_data                 OUT NOCOPY  VARCHAR2);



PROCEDURE	Search_Rate_Sort(
		p_api_version	IN  NUMBER DEFAULT 1.0,
		p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_event                    IN  VARCHAR2 DEFAULT 'FTE_TRIP_COMP',
		p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_init_prc_log		   IN     VARCHAR2 DEFAULT 'Y',
		p_ss_rate_sort_tab	   IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		p_ss_rate_sort_atr_rec IN  FTE_SS_ATTR_REC,
		x_ss_rate_sort_tab OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		x_rating_request_id               OUT NOCOPY NUMBER,
		x_return_status            OUT NOCOPY  VARCHAR2,
		x_msg_count                OUT NOCOPY  NUMBER,
		x_msg_data                 OUT NOCOPY  VARCHAR2);



PROCEDURE Display_Rank_Rec(p_rank_rec IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec);


END FTE_TRIP_RATING_GRP;

 

/
