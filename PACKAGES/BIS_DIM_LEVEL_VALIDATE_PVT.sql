--------------------------------------------------------
--  DDL for Package BIS_DIM_LEVEL_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIM_LEVEL_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDLVS.pls 115.4 2003/11/14 10:52:34 rchandra noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDLVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the Dimension Level record
REM | NOTES                                                                 |
REM |                                                                       |
REM |
REM +=======================================================================+
*/
--
--
--
PROCEDURE Validate_Record
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_DIM_LEVEL_VALIDATE_PVT;

 

/
