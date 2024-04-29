--------------------------------------------------------
--  DDL for Package FTE_ESTIMATE_FREIGHT_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTE_ESTIMATE_FREIGHT_RATE" AUTHID CURRENT_USER AS
/* $Header: FTEEFRES.pls 120.0 2005/05/26 17:28:38 appldev noship $ */
/*
-- Global constants
-- +======================================================================+
--   Procedure :
--          Freight Estimate Rate Search
--
--   Description:
--    Call the Service Search and Pricing API to get the rates
--    for the given inputs
--   Inputs:
--   Output:
--           No direct
--   DB:
-- +======================================================================+
*/
PROCEDURE RATE_SEARCH(
      p_init_msg_list           IN  VARCHAR2 default fnd_api.g_false,
      p_api_version_number      IN  NUMBER  default 1.0,
      p_origin                  IN  VARCHAR2,
      p_destination             IN  VARCHAR2,
      p_org_location_id         IN  NUMBER,
      p_dest_location_id        IN  NUMBER,
      p_org_country             IN  VARCHAR2,
      p_dest_country            IN  VARCHAR2,
      p_weight                  IN  NUMBER,
      p_weight_uom              IN  VARCHAR2,
      p_volume                  IN  NUMBER,
      p_volume_uom              IN  VARCHAR2,
      p_distance                IN  NUMBER,
      p_distance_uom            IN  VARCHAR2,
      p_show_ltl_rates_flag     IN  VARCHAR2,
      p_show_tl_rates_flag      IN  VARCHAR2,
      p_show_parcel_rates_flag  IN  VARCHAR2,
      p_ship_date               IN  VARCHAR2,
      p_del_date                IN  VARCHAR2,
      p_carrier_id              IN  NUMBER,
      p_service_level           IN  VARCHAR2,
      p_md_type                 IN  VARCHAR2,  -- Markup / Discount Type (M/D)
      p_md_percent              IN  NUMBER,
      p_commodity_catg_id       IN  NUMBER,
      p_vehicle_type_id         IN  NUMBER,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      x_return_status          OUT NOCOPY VARCHAR2);

/*  This API will be used to split city_state_zip into city state zip
INPUTS can be maximum 3 values seperated by comma
if there are 3, it will be converted city, state, zip
if there are 2, it will be converted state, zip
if there are 1, it will be converted zip
*/

PROCEDURE SPLIT_CITY_STATE_ZIP (
  p_city_state_zip IN VARCHAR2,
  x_city           OUT NOCOPY VARCHAR2,
  x_state          OUT NOCOPY VARCHAR2,
  x_zip            OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2);

END FTE_ESTIMATE_FREIGHT_RATE;

 

/
