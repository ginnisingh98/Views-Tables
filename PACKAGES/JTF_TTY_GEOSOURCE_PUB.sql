--------------------------------------------------------
--  DDL for Package JTF_TTY_GEOSOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_GEOSOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: jtftgsps.pls 120.0 2005/06/02 18:21:16 appldev ship $ */
/*#
 * This package provides a public API for inserting geographic
 * data into the JTF_TTY_GEOGRAPHIES table that is used by
 * self service geographic territories.
 * @rep:scope public
 * @rep:product JTY
 * @rep:lifecycle active
 * @rep:displayname Create Geography Data
 * @rep:category BUSINESS_ENTITY JTY_TERRITORY
 */

/*#
 * Use this API to create a geography definition that can be used
 * as a source for geographic territories.
 * @param p_geo_type Geography Type ('POSTAL_CODE', 'CITY', 'STATE',
 * 'COUNTY', 'PROVINCE', 'COUNTRY')
 * @param p_geo_name Geography Name (for example 'Sunnyvale' for the city,
 * 'United States' for the country)
 * @param p_geo_code Geography Code (for example 'SUNNYVALE' for the city, 'CA'
 * for California state)
 * @param p_country_code Country Code (for example 'US' for United States)
 * @param p_state_code State Code (for example 'NJ' for New Jersey)
 * @param p_province_code Province Code (for example 'ALBERTA' for Alberta)
 * @param p_county_code County Code (for example 'SAN_JOSE' for San Jose)
 * @param p_city_code City Code (for example 'SEATTLE' for Seattle)
 * @param p_postal_code Postal Code (for example '94065' for 94065)
 * @param x_return_status API return status stating success,
 * failure or unexpected error
 * @param x_error_msg Error message indicating why the create operation failed
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Geography
 */
PROCEDURE create_geo(
                     p_geo_type                   IN   VARCHAR2,
                     p_geo_name                   IN   VARCHAR2,
                     p_geo_code                   IN   VARCHAR2,
                     p_country_code               IN   VARCHAR2,
                     p_state_code                 IN   VARCHAR2 default null,
                     p_province_code              IN   VARCHAR2 default null,
                     p_county_code                IN   VARCHAR2 default null,
                     p_city_code                  IN   VARCHAR2 default null,
                     p_postal_code                IN   VARCHAR2 default null,
		     x_return_status              IN OUT  NOCOPY VARCHAR2,
		     x_error_msg                  IN OUT  NOCOPY VARCHAR2);
PROCEDURE update_geo(
                     p_geo_id                   IN   VARCHAR2,
                     p_geo_name                   IN   VARCHAR2,
		     x_return_status              IN OUT  NOCOPY VARCHAR2,
		     x_error_msg                  IN OUT  NOCOPY VARCHAR2);
PROCEDURE delete_geo(
                     p_geo_type                   IN   VARCHAR2,
                     p_geo_code                   IN   VARCHAR2,
                     p_country_code               IN   VARCHAR2,
                     p_state_code                 IN   VARCHAR2 default null,
                     p_province_code              IN   VARCHAR2 default null,
                     p_county_code                IN   VARCHAR2 default null,
                     p_city_code                  IN   VARCHAR2 default null,
                     p_postal_code                IN   VARCHAR2 default null,
                     p_delete_cascade_flag        IN   VARCHAR2 default 'N',
                     x_return_status              IN OUT  NOCOPY VARCHAR2,
                     x_error_msg                  IN OUT  NOCOPY VARCHAR2);
END JTF_TTY_GEOSOURCE_PUB;

 

/
