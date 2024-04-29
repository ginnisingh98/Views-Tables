--------------------------------------------------------
--  DDL for Package MST_GEOCODING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_GEOCODING" AUTHID CURRENT_USER AS
/*$Header: MSTGEOCS.pls 115.5 2004/01/13 01:24:54 jnhuang noship $*/


Function Get_local_time(p_location_id IN number,
                        p_server_time IN date) return DATE;

Function Get_server_time(p_location_id IN number,
                         p_local_time IN date) return DATE;

Function Get_timezone_code(p_location_id IN number,
                           p_date IN date) return VARCHAR2;

Function Get_server_timezone_code(p_date IN date) return VARCHAR2;

Procedure Get_facility_parameters(p_api_version IN NUMBER
, p_init_msg_list IN VARCHAR2 default fnd_api.g_false
, x_pallet_load_rate OUT NOCOPY NUMBER
, x_pallet_unload_rate OUT NOCOPY NUMBER
, x_non_pallet_load_rate OUT NOCOPY NUMBER
, x_non_pallet_unload_rate OUT NOCOPY NUMBER
, x_pallet_handling_uom OUT NOCOPY VARCHAR2
, x_non_pallet_handling_uom OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
);


END MST_GEOCODING;


 

/
