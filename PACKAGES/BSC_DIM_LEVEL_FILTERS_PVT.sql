--------------------------------------------------------
--  DDL for Package BSC_DIM_LEVEL_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIM_LEVEL_FILTERS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVFILS.pls 120.0.12000000.1 2007/07/17 07:44:44 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVFILS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package Filtering Dimension object at tab level      |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/


PROCEDURE delete_filters
(
        p_tab_id         IN             NUMBER
       ,p_dim_level_id   IN             NUMBER
       ,p_commit         IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status  OUT   NOCOPY   VARCHAR2
       ,x_msg_count      OUT   NOCOPY   NUMBER
       ,x_msg_data       OUT   NOCOPY   VARCHAR2
);

PROCEDURE insert_filters
(
        p_source_type     IN             bsc_sys_filters.source_type%TYPE
       ,p_source_code     IN             bsc_sys_filters.source_code%TYPE
       ,p_dim_level_id    IN             bsc_sys_filters.dim_level_id%TYPE
       ,p_dim_level_value IN             bsc_sys_filters.dim_level_value%TYPE
       ,p_commit          IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status   OUT   NOCOPY   VARCHAR2
       ,x_msg_count       OUT   NOCOPY   NUMBER
       ,x_msg_data        OUT   NOCOPY   VARCHAR2
);

PROCEDURE delete_filters_view
(
        p_tab_id         IN             NUMBER
       ,p_dim_level_id   IN             NUMBER
       ,p_commit         IN             VARCHAR2 := FND_API.G_FALSE
       ,x_return_status  OUT   NOCOPY   VARCHAR2
       ,x_msg_count      OUT   NOCOPY   NUMBER
       ,x_msg_data       OUT   NOCOPY   VARCHAR2
);

PROCEDURE insert_filters_view
(
        p_source_type      IN            bsc_sys_filters_views.source_type%TYPE
       ,p_source_code      IN            bsc_sys_filters_views.source_code%TYPE
       ,p_dim_level_id     IN            bsc_sys_filters_views.dim_level_id%TYPE
       ,p_level_table_name IN            bsc_sys_filters_views.level_table_name%TYPE
       ,p_level_view_name  IN            bsc_sys_filters_views.level_view_name%TYPE
       ,p_commit           IN            VARCHAR2 := FND_API.G_FALSE
       ,x_return_status   OUT   NOCOPY   VARCHAR2
       ,x_msg_count       OUT   NOCOPY   NUMBER
       ,x_msg_data        OUT   NOCOPY   VARCHAR2
);

END BSC_DIM_LEVEL_FILTERS_PVT;


 

/
