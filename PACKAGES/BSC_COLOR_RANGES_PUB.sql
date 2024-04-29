--------------------------------------------------------
--  DDL for Package BSC_COLOR_RANGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_RANGES_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCRNS.pls 120.2.12000000.1 2007/07/17 07:43:53 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCRNS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Public Spec version.                                            |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_COLOR_RANGES_B related table      |
 |                                                                                      |
 |  26-JUN-2007 ankgoel   Bug#6132361 - Handled PL objectives                          |
 +======================================================================================+
*/

G_PKG_NAME           CONSTANT    VARCHAR2(30) := 'BSC_COLOR_RANGES_PUB';

TYPE BSC_COLOR_RANGE_OBJ IS RECORD (
     color_range_id         bsc_color_ranges.color_range_id%TYPE
    ,color_range_sequence   bsc_color_ranges.color_range_sequence%TYPE
    ,low                    bsc_color_ranges.low%TYPE
    ,high                   bsc_color_ranges.high%TYPE
    ,color_id               bsc_color_ranges.color_id%TYPE
    ,user_id                NUMBER
);

TYPE BSC_COLOR_RANGE_REC  IS TABLE OF BSC_COLOR_RANGE_OBJ
  INDEX BY BINARY_INTEGER;
/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            VARCHAR2 := NULL
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE create_def_color_prop_ranges (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

PROCEDURE create_pl_def_clr_prop_ranges (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_cascade_shared      IN            BOOLEAN
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            VARCHAR2
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_color_range_id      IN            NUMBER
 ,p_threshold_color     IN            VARCHAR2
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Save_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            VARCHAR2
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Save_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            NUMBER := NULL
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Delete_Color_Prop_Ranges (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_objective_id        IN             NUMBER
 ,p_kpi_measure_id      IN             NUMBER  := NULL
 ,p_cascade_shared      IN             BOOLEAN
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Color_Prop_Ranges (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_color_range_id      IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
FUNCTION Get_Next_Token(
  p_token_string      IN OUT NOCOPY  VARCHAR2
 ,p_tokenizer         IN             VARCHAR2
 ,x_value             OUT    NOCOPY  VARCHAR2
) RETURN BOOLEAN ;

FUNCTION Get_Color_Method(
  p_objective_id       IN     NUMBER
 ,p_kpi_measure_id     IN     NUMBER
) RETURN NUMBER;

END BSC_COLOR_RANGES_PUB;
 

/
