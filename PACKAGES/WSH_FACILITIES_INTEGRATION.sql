--------------------------------------------------------
--  DDL for Package WSH_FACILITIES_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_FACILITIES_INTEGRATION" AUTHID CURRENT_USER as
/* $Header: WSHFACIS.pls 115.0 2003/09/05 01:33:33 arguha noship $ */

-- Procedure : Create_Facilities
-- Purpose   : Create facilities using the location ids in p_location_ids.
PROCEDURE Create_Facilities (p_location_ids   IN   WSH_LOCATIONS_PKG.ID_Tbl_Type,
                             p_company_names  IN   WSH_LOCATIONS_PKG.Address_Tbl_Type,
			     p_site_names     IN   WSH_LOCATIONS_PKG.LocationCode_Tbl_Type,
			     x_return_status  OUT  NOCOPY  VARCHAR2,
                             x_error_msg      OUT  NOCOPY  VARCHAR2);

-- +======================================================================+

END WSH_FACILITIES_INTEGRATION;


 

/
