--------------------------------------------------------
--  DDL for Package BSC_COMMON_DIM_LEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_COMMON_DIM_LEVELS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCDLS.pls 120.2 2007/02/20 17:03:45 psomesul ship $ */
/*-------------------------------------------------------------------------------------------------------------------
   Check_Common_Dim_Levels
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Check_Common_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

-------------------------------------------------------------------------------------------------------------------
--   Check_Common_Dim_Levels
--            Return x_return_status = 'DISABLE'  if it disables one or more common
--                                                Dimension in the Checking.
-------------------------------------------------------------------------------------------------------------------
PROCEDURE  Check_Common_Dim_Levels_DL(
  p_Dim_Level_Id        IN  number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		    OUT NOCOPY	number
 ,x_msg_data		    OUT NOCOPY	varchar2
);


/*------------------------------------------------------------------------------
 Check_Common_Dim_Levels_by_Dim
    Top be use when a Dimension (Dimension Group )is updated
---------------------------------------------------------------------------------*/
PROCEDURE Check_Common_Dim_Levels_by_Dim(
  p_Dimension_Id        IN  number
 ,x_return_status       OUT NOCOPY  varchar2
 ,x_msg_count		    OUT NOCOPY	number
 ,x_msg_data		    OUT NOCOPY	varchar2
);

/*-------------------------------------------------------------------------------------------------------------------
   Find_Common_Dim_Levels
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Find_Common_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_Dim_Level_Tbl 	OUT NOCOPY	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);
/*-------------------------------------------------------------------------------------------------------------------
   Retrieve_Common_Dim_Levels
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Retrieve_Common_Dim_Levels(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_Dim_Level_Tbl 	OUT NOCOPY	BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Tbl_Type
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);
/*-------------------------------------------------------------------------------------------------------------------
   Check_Dim_Level_Default_Value
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Check_Dim_Level_Default_Value(
  p_commit              IN      varchar2 := FND_API.G_FALSE
 ,p_Tab_Id        	IN      number
 ,x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count		OUT NOCOPY	number
 ,x_msg_data		OUT NOCOPY	varchar2
);

/*************************************************************************
  This procedure validates the List Button.
/*************************************************************************/
PROCEDURE Validate_List_Button
(
  p_Kpi_Id		IN		BSC_KPIS_B.indicator%TYPE :=NULL
 ,p_Dim_Level_Id	IN		NUMBER :=NULL
 ,x_return_status       OUT NOCOPY      VARCHAR2
 ,x_msg_count		OUT NOCOPY	NUMBER
 ,x_msg_data		OUT NOCOPY	VARCHAR2
);



END BSC_COMMON_DIM_LEVELS_PUB;

/
