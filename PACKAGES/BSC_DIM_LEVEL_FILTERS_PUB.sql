--------------------------------------------------------
--  DDL for Package BSC_DIM_LEVEL_FILTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIM_LEVEL_FILTERS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPFILS.pls 120.1.12000000.1 2007/07/17 07:44:00 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPFILS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package Filtering Dimension object at tab level      |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM | 27-Mar-07 psomesul B#5901412-Open issues of enh no. 5678943              |
REM +=======================================================================+
*/

SOURCE_TYPE_TAB      NUMBER := 1;    -- Scorecard SOURCE TYPE
SOURCE_TYPE_SYSTEM   NUMBER := 0;    -- System SOURCE TYPE

PROCEDURE save_filter
(p_tab_id                 IN                 NUMBER
,p_dim_level_id           IN                 NUMBER
,p_level_vals_list        IN  OUT NOCOPY     VARCHAR2
,p_mismatch_keyitems      OUT     NOCOPY     VARCHAR2
,p_commit                 IN                 VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT     NOCOPY     VARCHAR2
,x_msg_count              OUT     NOCOPY     NUMBER
,x_msg_data               OUT     NOCOPY     VARCHAR2
);

PROCEDURE process_filter_view
(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
);

PROCEDURE create_filter_view
(
  p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
);


FUNCTION get_new_filter_view_name(
  p_dimension_table        IN             VARCHAR2
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2

) RETURN VARCHAR2;

PROCEDURE del_filters_not_applicable(
 p_tab_id                 IN             NUMBER
,p_ch_level_id            IN             NUMBER
,p_pa_level_id            IN             NUMBER
,p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
);


PROCEDURE get_filter_dimension_SQL
( p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, x_sql                    OUT NOCOPY     VARCHAR2
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
);

PROCEDURE get_filtered_dim_values_SQL
( p_tab_id                 IN             NUMBER
, p_dim_level_id           IN             NUMBER
, x_sql                    OUT NOCOPY     VARCHAR2
, p_commit                 IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status          OUT NOCOPY     VARCHAR2
, x_msg_count              OUT NOCOPY     NUMBER
, x_msg_data               OUT NOCOPY     VARCHAR2
);

PROCEDURE update_tab_who_columns
(
 p_tab_id               IN               NUMBER
,p_commit               IN               VARCHAR2 := FND_API.G_FALSE
,x_return_status        OUT       NOCOPY VARCHAR2
,x_msg_count            OUT       NOCOPY NUMBER
,x_msg_data             OUT       NOCOPY VARCHAR2
);

PROCEDURE validate_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_level_vals_list        IN  OUT NOCOPY VARCHAR2
,p_mismatch_key_items     IN  OUT NOCOPY VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
);

PROCEDURE validate_parent_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_parent_level_id        IN             NUMBER
,p_level_vals_list        IN             VARCHAR2
,p_mismatch_key_items     IN OUT NOCOPY  VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
);

PROCEDURE validate_child_key_items(
 p_tab_id                 IN             NUMBER
,p_dim_level_id           IN             NUMBER
,p_child_level_id         IN             NUMBER
,p_level_vals_list        IN             VARCHAR2
,p_mismatch_key_items     IN OUT NOCOPY  VARCHAR2
,x_return_status          OUT NOCOPY     VARCHAR2
,x_msg_count              OUT NOCOPY     NUMBER
,x_msg_data               OUT NOCOPY     VARCHAR2
);

END BSC_DIM_LEVEL_FILTERS_PUB;

 

/
