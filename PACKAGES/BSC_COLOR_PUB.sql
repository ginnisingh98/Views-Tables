--------------------------------------------------------
--  DDL for Package BSC_COLOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCOLS.pls 120.1.12000000.1 2007/07/17 07:43:50 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCOLS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Public Spec version.                                            |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_SYS_COLORS_B and related table    |
 |                                                                                      |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_PUB';

TYPE BSC_COLOR_REC IS RECORD (
     color_id                bsc_sys_colors_b.color_id%TYPE
    ,short_name              bsc_sys_colors_b.short_name%TYPE
    ,name                    bsc_sys_colors_tl.name%TYPE
    ,prototype_label         bsc_sys_colors_tl.prototype_label%TYPE
    ,description             bsc_sys_colors_tl.description%TYPE
    ,perf_sequence           bsc_sys_colors_b.perf_sequence%TYPE
    ,color                   bsc_sys_colors_b.color%TYPE
    ,user_color              bsc_sys_colors_b.user_color%TYPE
    ,forecast_color          bsc_sys_colors_b.forecast_color%TYPE
    ,user_forecast_color     bsc_sys_colors_b.user_forecast_color%TYPE
    ,numeric_equivalent      bsc_sys_colors_b.numeric_equivalent%TYPE
    ,user_numeric_equivalent bsc_sys_colors_b.user_numeric_equivalent%TYPE
    ,image                   bsc_sys_colors_b.user_image_id%TYPE
    ,created_by              bsc_sys_colors_b.created_by%TYPE
    ,last_updated_by         bsc_sys_colors_b.last_updated_by%TYPE
    ,last_update_login       bsc_sys_colors_b.last_update_login%TYPE
    ,last_update_date        bsc_sys_colors_b.last_update_date%TYPE
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN            BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Color(
  p_commit             IN             VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Tbl      IN             COLOR_ARRAY
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Id        IN             NUMBER
 ,p_Bsc_Color_SN        IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) ;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Default_Color_Count(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_color_count         IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

END BSC_COLOR_PUB;
 

/
