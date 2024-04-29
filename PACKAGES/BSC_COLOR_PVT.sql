--------------------------------------------------------
--  DDL for Package BSC_COLOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COLOR_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVCOLS.pls 120.0.12000000.1 2007/07/17 07:44:37 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCOLS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Private Spec version.                                           |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_SYS_COLORS_B and related table    |
 |                                                                                      |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        varchar2(30) := 'BSC_COLOR_PVT';


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
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
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
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Translate_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);

/************************************************************************************
 ************************************************************************************/
PROCEDURE Load_Color(
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_Bsc_Color_Rec       IN             BSC_COLOR_PUB.Bsc_Color_Rec
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
);


END BSC_COLOR_PVT;

 

/
