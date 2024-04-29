--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCT_MAP_DTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCT_MAP_DTL_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHGEMDS.pls 120.2 2005/09/01 20:00:54 baianand noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_loc_seq_num                           IN            NUMBER,
    x_loc_component                         IN            VARCHAR2,
    x_geography_type                        IN            VARCHAR2,
    x_geo_element_col                       IN            VARCHAR2
);

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_loc_seq_num                           IN            NUMBER,
    x_loc_component                         IN            VARCHAR2,
    x_geography_type                        IN            VARCHAR2,
    x_geo_element_col                       IN            VARCHAR2
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_loc_seq_num                           IN            NUMBER,
    x_loc_component                         IN            VARCHAR2,
    x_geography_type                        IN            VARCHAR2,
    x_geo_element_col                       IN            VARCHAR2
);

PROCEDURE Select_Row (
    x_map_id                                IN OUT NOCOPY NUMBER,
    x_loc_seq_num                           OUT    NOCOPY NUMBER,
    x_loc_component                         OUT    NOCOPY VARCHAR2,
    x_geography_type                        OUT    NOCOPY VARCHAR2,
    x_geo_element_col                       OUT    NOCOPY VARCHAR2
);

PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER
);
-- This API can use to delete only one record in mapping detail table.
PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER,
    x_geography_type                IN     VARCHAR2
);
END HZ_GEO_STRUCT_MAP_DTL_PVT;

 

/
