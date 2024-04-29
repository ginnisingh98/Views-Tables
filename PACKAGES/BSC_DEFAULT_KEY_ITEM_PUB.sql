--------------------------------------------------------
--  DDL for Package BSC_DEFAULT_KEY_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DEFAULT_KEY_ITEM_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPDKIS.pls 120.2.12000000.1 2007/07/17 07:43:57 appldev noship $ */

PROCEDURE Update_Key_Item(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
);

PROCEDURE Cascade_Key_Item_Changes(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
);

PROCEDURE Update_Default_Key_Items(
  p_kpi_id         IN             VARCHAR2
, p_params         IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
);

FUNCTION get_table_column_value(
  p_table_name            IN    VARCHAR2
 ,p_column_name           IN    VARCHAR2
 ,p_where_cond            IN    VARCHAR2
) RETURN VARCHAR2;

PROCEDURE Set_Key_Item_Value
(
    p_indicator        IN           BSC_KPIS_B.indicator%TYPE
  , p_dim_id           IN           BSC_KPI_DIM_SETS_VL.dim_set_id%TYPE
  , p_dim_obj_sht_name IN           BSC_SYS_DIM_LEVELS_VL.short_name%TYPE
  , p_key_value        IN           BSC_KPI_DIM_LEVEL_PROPERTIES.default_key_value%TYPE
  , x_return_status    OUT  NOCOPY  VARCHAR2
  , x_msg_count        OUT  NOCOPY  NUMBER
  , x_msg_data         OUT  NOCOPY  VARCHAR2
);

END BSC_DEFAULT_KEY_ITEM_PUB;

 

/
