--------------------------------------------------------
--  DDL for Package HZ_GEO_STRUCT_MAP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_GEO_STRUCT_MAP_PVT" AUTHID CURRENT_USER AS
/*$Header: ARHGEMMS.pls 115.2 2003/02/11 19:44:36 sachandr noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_country_code                          IN            VARCHAR2,
    x_loc_tbl_name                          IN            VARCHAR2,
    x_address_style                         IN            VARCHAR2
);

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_map_id                                IN            NUMBER,
    x_country_code                          IN            VARCHAR2,
    x_loc_tbl_name                          IN            VARCHAR2,
    x_address_style                         IN            VARCHAR2
);

PROCEDURE Select_Row (
    x_map_id                                IN OUT NOCOPY NUMBER,
    x_country_code                          OUT    NOCOPY VARCHAR2,
    x_loc_tbl_name                          OUT    NOCOPY VARCHAR2,
    x_address_style                         OUT    NOCOPY VARCHAR2
);

PROCEDURE Delete_Row (
    x_map_id                        IN     NUMBER
);

END HZ_GEO_STRUCT_MAP_PVT;

 

/
