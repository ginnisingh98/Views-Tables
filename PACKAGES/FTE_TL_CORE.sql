--------------------------------------------------------
--  DDL for Package FTE_TL_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_TL_CORE" AUTHID CURRENT_USER AS
/* $Header: FTEVTLOS.pls 120.0 2005/05/26 17:04:22 appldev noship $ */

-- Global constants

   TL_WEIGHT_BASIS NUMBER := 1;


TYPE tl_exceptions_type IS RECORD(
	trip_index 		NUMBER,
	implicit_non_dummy_cnt 	NUMBER,
	check_tlqp_ouputfail  	VARCHAR2(1),
	check_qp_ipl_fail 	VARCHAR2(1),
	not_on_pl_flag		VARCHAR2(1),
	price_req_failed	VARCHAR2(1),
	allocation_failed	VARCHAR2(1)
	);

TYPE tl_exceptions_tab_type IS TABLE OF  tl_exceptions_type INDEX BY BINARY_INTEGER;


-- +======================================================================+
--   Procedure :
--           tl_core
--
--   Description:
--           Build the call structure for the pricing engine, invoke the
--           rating engine, analyze results, return results.
--   Inputs:
--           p_trip_rec    IN TL_trip_data_input_rec_type
--           p_stop_tab          IN TL_trip_stop_data_tab_type,
--           p_carrier_pref      IN TL_trip_carrier_preferences_rec_type,
--   Output:
--           x_trip_charges_rec  OUT NOCOPY  TL_trip_data_output_rec_type,
--           x_stop_charges_tab  OUT NOCOPY TL_trip_stop_output_tab_type,
--           x_return_status     OUT NOCOPY VARCHAR2
--
--   Global dependencies:
--           No direct
--
--   DB:
--           No direct
-- +======================================================================+

  PROCEDURE tl_core (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type,
                   x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2);






PROCEDURE TL_Core_Multiple (
		    p_start_trip_index IN NUMBER,
		    p_end_trip_index IN NUMBER,
	            p_trip_tab    IN FTE_TL_CACHE.TL_trip_data_input_tab_type,
	            p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
	            p_carrier_pref_tab      IN  FTE_TL_CACHE.TL_CARRIER_PREF_TAB_TYPE,
	            x_trip_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE,
	            x_stop_charges_tab  OUT NOCOPY	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
		    x_exceptions_tab OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
	            x_return_status     OUT NOCOPY VARCHAR2);

END FTE_TL_CORE;

 

/
