--------------------------------------------------------
--  DDL for Package BSC_COLOR_RANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_RANGE_PVT" AUTHID CURRENT_USER as
/* $Header: BSCVCRNS.pls 120.2.12000000.1 2007/07/17 07:44:41 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCRNS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      November 02, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Private Spec version.                                           |
 |                      This package is to manage Range Properties properties           |
 |                      and provide CRUD APIs for BSC_SYS_COLOR_RANGES_B and related tbl|
 |                                                                                      |
 |  26-JUN-2007 ankgoel   Bug#6132361 - Handled PL objectives                          |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_RANGE_PVT';


/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2
 ,p_color_range_id      IN            NUMBER
 ,p_property_value      IN            VARCHAR2 := NULL
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Range (
  p_commit                      IN            VARCHAR2 := FND_API.G_FALSE
 ,p_range_id                    IN            NUMBER
 ,p_Bsc_Kpi_Color_Range_Rec     IN            BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec
 ,p_user_id                     IN            FND_USER.user_id%TYPE
 ,x_return_status               OUT NOCOPY    VARCHAR2
 ,x_msg_count                   OUT NOCOPY    NUMBER
 ,x_msg_data                    OUT NOCOPY    VARCHAR2
);

/************************************************************************************
 ************************************************************************************/

PROCEDURE Delete_Color_Ranges (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_color_range_id      IN             NUMBER
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

END BSC_COLOR_RANGE_PVT;

 

/
