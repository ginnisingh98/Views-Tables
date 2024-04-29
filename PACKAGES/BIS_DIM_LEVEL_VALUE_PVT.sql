--------------------------------------------------------
--  DDL for Package BIS_DIM_LEVEL_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIM_LEVEL_VALUE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDMVS.pls 115.14 2002/12/16 10:25:22 rchandra ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDMVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing dimension level valuesfor the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM | 01.23.02 sashaik Modified Is_Current_Time_Period and Is_Previous_Time_Period |
REM | 		       for 1740789					    |
REM | 13-NOV-2002   mahrao   Fix for 2665526                                |
REM |                                                                       |
REM +=======================================================================+
*/
--
--
PROCEDURE Retrieve_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Responsibility_Tbl  IN  BIS_RESPONSIBILITY_PVT.Responsibility_Tbl_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Responsibility_ID   IN NUMBER
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_Org_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_Time_Dim_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Dim_Level_Value_Rec IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_DimensionX_Values
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Remove_Dup_Dim_Level_Values
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Tbl IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Dim_Level_Value_Tbl OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_Start_Date
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_start_period        IN  VARCHAR2
, x_start_date          OUT NOCOPY DATE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Get_End_Date
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_end_period          IN  VARCHAR2
, x_end_date            OUT NOCOPY DATE
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Org_ID_to_Value
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Org_Value_to_ID
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Time_ID_to_Value
( p_api_version         IN  NUMBER
, p_Org_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE Time_Value_to_ID
( p_api_version         IN  NUMBER
, p_Org_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE DimensionX_ID_to_Value
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_set_of_books_id     IN  VARCHAR2 := NULL
, x_Dim_Level_Value_Rec IN OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
PROCEDURE DimensionX_Value_to_ID
( p_api_version         IN  NUMBER
, p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_Dim_Level_Value_Rec OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Function Is_Current_Time_Period
( p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Org_Level_ID        IN  VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, x_current_time_id     OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;


Function Is_Previous_Time_Period
( p_Dim_Level_Value_Rec IN  BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type
, p_Org_Level_ID        IN  VARCHAR2
, p_Org_Level_Short_name IN   VARCHAR2
, x_Previous_time_id    OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

--
--
END BIS_DIM_LEVEL_VALUE_PVT;

 

/
