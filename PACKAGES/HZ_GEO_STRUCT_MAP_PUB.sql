--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCT_MAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCT_MAP_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHGNRMS.pls 120.4 2005/09/02 17:39:54 baianand noship $ */

TYPE geo_struct_map_rec_type IS RECORD
  (country_code            VARCHAR2(2),
   loc_tbl_name            VARCHAR2(30),
   address_style           VARCHAR2(30)
   );
TYPE geo_struct_map_dtl_rec_type IS RECORD
  (loc_seq_num             NUMBER,
   loc_comp                VARCHAR2(30),
   geo_type                VARCHAR2(30)
   );
TYPE geo_struct_map_dtl_tbl_type IS TABLE of geo_struct_map_dtl_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE create_geo_struct_mapping
  (p_geo_struct_map_rec IN geo_struct_map_rec_type,
   p_geo_struct_map_dtl_tbl IN geo_struct_map_dtl_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_map_id                  OUT    NOCOPY   NUMBER,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  );
PROCEDURE delete_geo_struct_mapping(
    p_map_id               IN         NUMBER,
    p_location_table_name  IN         VARCHAR2,
    p_country              IN         VARCHAR2,
    p_address_style        IN         VARCHAR2,
    p_geo_struct_map_dtl_tbl  IN      geo_struct_map_dtl_tbl_type,
    p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2);
PROCEDURE create_geo_struct_map_dtls
  (p_map_id                  IN              NUMBER,
   p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  );
PROCEDURE update_geo_struct_map_dtls
  (p_map_id                  IN              NUMBER,
   p_geo_struct_map_dtl_tbl  IN              geo_struct_map_dtl_tbl_type,
   p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
   x_return_status           OUT    NOCOPY   VARCHAR2,
   x_msg_count               OUT    NOCOPY   NUMBER,
   x_msg_data                OUT    NOCOPY   VARCHAR2
  );

END;

 

/
