--------------------------------------------------------
--  DDL for Package FTE_LOCATION_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_LOCATION_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: FTEGFACS.pls 115.7 2004/07/21 11:52:28 alksharm noship $ */

  --
  -- Package FTE_LOCATION_PARAMETERS_PKG
  --

l_debug_on     BOOLEAN := TRUE;
g_debug_set    BOOLEAN := TRUE;

TYPE Index_Varchar100_Tbl_Type  IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

--NON-INDEXED TABLES
TYPE NoIndex_Number_Tbl_Type      IS TABLE OF NUMBER;
TYPE NoIndex_Varchar100_Tbl_Type  IS TABLE OF VARCHAR2(100);

TYPE TL_FAC_INFO_REC_TYPE IS RECORD(

location_id             NUMBER,
stop_id                 NUMBER,
fac_code                VARCHAR2(60),
loading_protocol        VARCHAR2(30),
fac_charge_basis        VARCHAR2(30),
fac_handling_time       NUMBER,
fac_currency            VARCHAR2(30),
fac_modifier_id         NUMBER,
fac_pricelist_id        NUMBER,
fac_weight_uom_class    VARCHAR2(30),
fac_weight_uom          VARCHAR2(30),
fac_volume_uom_class    VARCHAR2(30),
fac_volume_uom          VARCHAR2(30),
fac_distance_uom_class  VARCHAR2(30),
fac_distance_uom        VARCHAR2(30),
fac_time_uom_class      VARCHAR2(30),
fac_time_uom            VARCHAR2(30));


TYPE TL_FAC_INFO_TAB_TYPE  IS TABLE OF  TL_FAC_INFO_REC_TYPE INDEX BY BINARY_INTEGER;

PROCEDURE Create_Facilities (p_location_ids    IN   WSH_LOCATIONS_PKG.ID_Tbl_Type,
                             p_company_names   IN   WSH_LOCATIONS_PKG.Address_Tbl_Type,
                             p_site_names      IN   WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
                             x_return_status   OUT  NOCOPY  VARCHAR2,
                             x_error_msg       OUT  NOCOPY  VARCHAR2);

PROCEDURE Create_Facility (p_location_id   IN   NUMBER,
                           p_facility_code IN   VARCHAR2  default  NULL,
                           x_return_status OUT  NOCOPY  VARCHAR2,
                           x_error_msg     OUT  NOCOPY  VARCHAR2);

PROCEDURE Get_Fac_Info (x_fac_info_rows IN OUT NOCOPY Tl_Fac_Info_Tab_Type,
                        x_return_status    OUT NOCOPY VARCHAR2 );

PROCEDURE Get_Fac_Lat_Long_and_TimeZone(p_country IN VARCHAR2,
			p_city IN VARCHAR2,
			p_postalcode IN VARCHAR2,
			p_state IN VARCHAR2,
			p_county IN VARCHAR2,
			p_province IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
			x_msg_count OUT NOCOPY VARCHAR2,
			x_msg_data OUT NOCOPY VARCHAR2,
			x_latitude OUT NOCOPY VARCHAR2,
			x_longitude OUT NOCOPY VARCHAR2,
			x_timezone OUT NOCOPY VARCHAR2,
			x_geometry OUT NOCOPY MDSYS.SDO_GEOMETRY
			);

END FTE_LOCATION_PARAMETERS_PKG;


 

/
