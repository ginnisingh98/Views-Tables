--------------------------------------------------------
--  DDL for Package HZ_GNR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GNR_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHGNRVS.pls 120.6 2006/02/09 21:10:06 nsinghai noship $ */

  /****************************************************************************
   Created By    Nishant Singhai  02-Jun-2005  Address Suggestion API
   ***************************************************************************/

  /*  Package variables */

  G_PKG_NAME   CONSTANT VARCHAR2(30):= 'HZ_GNR_PVT';

  -- Public variable to keep track of number of times user is making attempt for
  -- the address
  G_USER_ATTEMPT_COUNT VARCHAR2(30);

  -- Record for other output parameters. This can be extended in future for
  -- other out variables (added on 14-Sep-2005 by Nishant)
  TYPE geo_suggest_misc_rec IS RECORD
  ( v_suggestion_msg_text  VARCHAR2(1000)
  );

  TYPE geo_struct_rec IS RECORD
  ( v_tab_col           VARCHAR2(100),
    v_geo_type          VARCHAR2(100),
    v_element_col       VARCHAR2(100),
    v_level             NUMBER,
    v_param_value       VARCHAR2(255),
    v_valid_for_usage   VARCHAR2(10)
   );

  TYPE geo_struct_tbl_type IS TABLE OF geo_struct_rec INDEX BY BINARY_INTEGER;

  TYPE geo_suggest_rec IS RECORD
    (
      country 		   	  		 hz_locations.country%TYPE,
      country_code               hz_geographies.geography_code%TYPE,
      country_geo_id             hz_geographies.geography_id%TYPE,
      country_geo_type           hz_geographies.geography_type%TYPE,
      state                      hz_locations.state%TYPE,
      state_code                 hz_geographies.geography_code%TYPE,
      state_geo_id               hz_geographies.geography_id%TYPE,
      state_geo_type             hz_geographies.geography_type%TYPE,
      province                   hz_locations.province%TYPE,
      province_code              hz_geographies.geography_code%TYPE,
      province_geo_id			 hz_geographies.geography_id%TYPE,
	  province_geo_type          hz_geographies.geography_type%TYPE,
      county                     hz_locations.county%TYPE,
      county_geo_id				 hz_geographies.geography_id%TYPE,
      county_geo_type			 hz_geographies.geography_type%TYPE,
      city                       hz_locations.city%TYPE,
      city_geo_id				 hz_geographies.geography_id%TYPE,
      city_geo_type				 hz_geographies.geography_type%TYPE,
      postal_code                hz_locations.postal_code%TYPE,
      postal_code_geo_id		 hz_geographies.geography_id%TYPE,
      postal_code_geo_type		 hz_geographies.geography_type%TYPE,
      postal_plus4_code          hz_locations.postal_plus4_code%TYPE,
      postal_plus4_code_geo_id   hz_geographies.geography_id%TYPE,
      postal_plus4_code_geo_type hz_geographies.geography_type%TYPE,
      attribute1                 hz_locations.attribute1%TYPE,
      attribute1_geo_id			 hz_geographies.geography_id%TYPE,
      attribute1_geo_type		 hz_geographies.geography_type%TYPE,
      attribute2                 hz_locations.attribute2%TYPE,
      attribute2_geo_id			 hz_geographies.geography_id%TYPE,
      attribute2_geo_type      	 hz_geographies.geography_type%TYPE,
      attribute3                 hz_locations.attribute3%TYPE,
      attribute3_geo_id			 hz_geographies.geography_id%TYPE,
      attribute3_geo_type      	 hz_geographies.geography_type%TYPE,
      attribute4                 hz_locations.attribute4%TYPE,
      attribute4_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute4_geo_type      	 hz_geographies.geography_type%TYPE,
      attribute5                 hz_locations.attribute5%TYPE,
      attribute5_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute5_geo_type      	 hz_geographies.geography_type%TYPE,
      attribute6                 hz_locations.attribute6%TYPE,
      attribute6_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute6_geo_type      	 hz_geographies.geography_type%TYPE,
      attribute7                 hz_locations.attribute7%TYPE,
      attribute7_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute7_geo_type		 hz_geographies.geography_type%TYPE,
      attribute8                 hz_locations.attribute8%TYPE,
      attribute8_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute8_geo_type		 hz_geographies.geography_type%TYPE,
      attribute9                 hz_locations.attribute9%TYPE,
      attribute9_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute9_geo_type		 hz_geographies.geography_type%TYPE,
      attribute10                hz_locations.attribute10%TYPE,
      attribute10_geo_id      	 hz_geographies.geography_id%TYPE,
      attribute10_geo_type		 hz_geographies.geography_type%TYPE,
      suggestion_list            VARCHAR2(4000)
    );

  TYPE geo_suggest_tbl_type  IS TABLE OF geo_suggest_rec INDEX BY BINARY_INTEGER;

  PROCEDURE  search_geographies
  (
    p_table_name      	  				IN  VARCHAR2 DEFAULT 'HZ_LOCATIONS',
    p_address_style   	  				IN  VARCHAR2 DEFAULT NULL,
    p_address_usage                     IN  VARCHAR2 DEFAULT 'GEOGRAPHY',
    p_country_code     	  				IN  HZ_LOCATIONS.COUNTRY%TYPE,
    p_state           	  				IN  HZ_LOCATIONS.STATE%TYPE DEFAULT NULL,
    p_province        	  				IN  HZ_LOCATIONS.PROVINCE%TYPE DEFAULT NULL,
    p_county          	  				IN  HZ_LOCATIONS.COUNTY%TYPE DEFAULT NULL,
    p_city            	  				IN  HZ_LOCATIONS.CITY%TYPE DEFAULT NULL,
    p_postal_code     	  				IN  HZ_LOCATIONS.POSTAL_CODE%TYPE DEFAULT NULL,
    p_postal_plus4_code     	  		IN  HZ_LOCATIONS.POSTAL_PLUS4_CODE%TYPE DEFAULT NULL,
    p_attribute1                        IN  HZ_LOCATIONS.ATTRIBUTE1%TYPE DEFAULT NULL,
    p_attribute2                        IN  HZ_LOCATIONS.ATTRIBUTE2%TYPE DEFAULT NULL,
    p_attribute3                        IN  HZ_LOCATIONS.ATTRIBUTE3%TYPE DEFAULT NULL,
    p_attribute4                        IN  HZ_LOCATIONS.ATTRIBUTE4%TYPE DEFAULT NULL,
    p_attribute5                        IN  HZ_LOCATIONS.ATTRIBUTE5%TYPE DEFAULT NULL,
    p_attribute6                        IN  HZ_LOCATIONS.ATTRIBUTE6%TYPE DEFAULT NULL,
    p_attribute7                        IN  HZ_LOCATIONS.ATTRIBUTE7%TYPE DEFAULT NULL,
    p_attribute8                        IN  HZ_LOCATIONS.ATTRIBUTE8%TYPE DEFAULT NULL,
    p_attribute9                        IN  HZ_LOCATIONS.ATTRIBUTE9%TYPE DEFAULT NULL,
    p_attribute10                       IN  HZ_LOCATIONS.ATTRIBUTE10%TYPE DEFAULT NULL,
    x_mapped_struct_count 			  	OUT NOCOPY  NUMBER,
    x_records_count   	  	  		  	OUT NOCOPY  NUMBER,
    x_return_code                       OUT NOCOPY  NUMBER,
    x_validation_level                  OUT NOCOPY  VARCHAR2,
    x_geo_suggest_tbl                   OUT NOCOPY  HZ_GNR_PVT.geo_suggest_tbl_type,
    x_geo_struct_tbl					OUT NOCOPY  HZ_GNR_PVT.geo_struct_tbl_type,
    x_geo_suggest_misc_rec              OUT NOCOPY  HZ_GNR_PVT.geo_suggest_misc_rec,
    x_return_status             	  	OUT NOCOPY  VARCHAR2,
    x_msg_count                 	  	OUT NOCOPY  NUMBER,
    x_msg_data                  	  	OUT NOCOPY  VARCHAR2
  );

END HZ_GNR_PVT;

 

/
