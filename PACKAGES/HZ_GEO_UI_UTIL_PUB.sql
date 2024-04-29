--------------------------------------------------------
--  DDL for Package HZ_GEO_UI_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_UI_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHGEOUS.pls 120.2 2005/09/28 20:11:53 sroychou noship $ */

TYPE tax_geo_rec_type IS RECORD (
     level_number               NUMBER,
     geography_type             VARCHAR2(360),
     loc_comp                   VARCHAR2(360),
     tax_geo_valid              VARCHAR2(10)  DEFAULT  'N'
     );

TYPE tax_geo_tbl_type IS TABLE OF tax_geo_rec_type
     INDEX BY BINARY_INTEGER;

FUNCTION check_dup_geo ( p_parent_id in NUMBER,
                         p_geo_name  in VARCHAR2,
                         p_geo_code  in VARCHAR2,
						 p_geo_type  in VARCHAR2)
RETURN VARCHAR2;

FUNCTION check_geo_tax_valid( p_map_id    in NUMBER,
                              p_geo_type  in VARCHAR2,
                              p_geo_tax  in VARCHAR2)
RETURN   VARCHAR2;

PROCEDURE  update_map_usages(p_map_id           IN    NUMBER,
                             p_tax_tbl          IN    HZ_GEO_UI_UTIL_PUB.tax_geo_tbl_type,
                             p_geo_tbl          IN    HZ_GEO_UI_UTIL_PUB.tax_geo_tbl_type,
                             p_init_msg_list    IN    VARCHAR2 := FND_API.G_FALSE,
                             x_return_status    OUT   NOCOPY     VARCHAR2,
    						 x_msg_count        OUT   NOCOPY     NUMBER,
                             x_msg_data         OUT   NOCOPY     VARCHAR2,
                             x_show_gnr         OUT   NOCOPY     VARCHAR2
                            );

FUNCTION get_geo_ref(p_geography_id IN NUMBER,
                     p_loc_table_name IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_country_name(p_geography_id IN NUMBER)
RETURN VARCHAR2;

END HZ_GEO_UI_UTIL_PUB;

 

/
