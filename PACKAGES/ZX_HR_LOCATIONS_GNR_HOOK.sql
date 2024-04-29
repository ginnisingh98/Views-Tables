--------------------------------------------------------
--  DDL for Package ZX_HR_LOCATIONS_GNR_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_HR_LOCATIONS_GNR_HOOK" AUTHID CURRENT_USER AS
/* $Header: zxlocgnrs.pls 120.1 2006/05/18 22:31:47 sachandr ship $*/

  PROCEDURE create_gnr (p_location_id IN NUMBER,
                        p_country     IN VARCHAR2,
                        p_region_1    IN VARCHAR2,
                        p_region_2    IN VARCHAR2,
                        p_region_3    IN VARCHAR2,
                        p_town_or_city  IN VARCHAR2,
                        p_postal_code IN VARCHAR2,
                        p_style       IN VARCHAR2
);

  PROCEDURE update_gnr (p_location_id IN NUMBER,
                        p_country     IN VARCHAR2,
                        p_region_1    IN VARCHAR2,
                        p_region_2    IN VARCHAR2,
                        p_region_3    IN VARCHAR2,
                        p_town_or_city  IN VARCHAR2,
                        p_postal_code IN VARCHAR2,
                        p_style_o     IN VARCHAR2,
                        p_country_o   IN VARCHAR2,
                        p_region_1_o  IN VARCHAR2,
                        p_region_2_o  IN VARCHAR2,
                        p_region_3_o  IN VARCHAR2,
                        p_town_or_city_o IN VARCHAR2,
                        p_postal_code_o  IN VARCHAR2);

END zx_hr_locations_gnr_hook;

 

/
