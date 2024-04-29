--------------------------------------------------------
--  DDL for Package HZ_GEO_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_GET_PUB" AUTHID CURRENT_USER AS
/* $Header: ARHGEGES.pls 120.5 2005/08/30 18:02:51 baianand noship $ */

TYPE zone_rec_type IS RECORD(
     zone_id             NUMBER,
     zone_name           VARCHAR2(360),
     zone_code           VARCHAR2(30),
     zone_type           VARCHAR2(30));

TYPE zone_tbl_type IS TABLE OF zone_rec_type
    INDEX BY BINARY_INTEGER;

  PROCEDURE get_zone
    (p_location_table_name IN         VARCHAR2,
     p_location_id         IN         VARCHAR2,
     p_zone_type           IN         VARCHAR2,
     p_date                IN         DATE,
     p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
     x_zone_tbl            OUT NOCOPY zone_tbl_type,
     x_return_status       OUT NOCOPY VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2);

function get_conc_name(l_geo_id IN NUMBER) return VARCHAR2;
END;

 

/
