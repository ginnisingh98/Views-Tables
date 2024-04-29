--------------------------------------------------------
--  DDL for Package WSH_GEOCODING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_GEOCODING" AUTHID CURRENT_USER AS
/*$Header: WSHGEOCS.pls 115.1 2003/11/11 19:12:57 ndodoo noship $*/

Procedure Get_Lat_Long_and_TimeZone(p_api_version IN NUMBER
, p_init_msg_list IN VARCHAR2 default fnd_api.g_false
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
, l_location IN OUT NOCOPY WSH_LOCATIONS_PKG.LOCATION_REC_TYPE
);

END WSH_GEOCODING;


 

/
