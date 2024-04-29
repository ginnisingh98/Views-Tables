--------------------------------------------------------
--  DDL for Package BIS_DIMENSION_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMENSION_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVDIVS.pls 115.2 99/09/19 11:19:58 porting ship  $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDIVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the Dimensions record
REM | NOTES                                                                 |
REM |     04/23/99    irchen   Creation                                     |
REM |
REM +=======================================================================+
*/
--
--
--
PROCEDURE Validate_Record
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Rec    IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_return_status    OUT VARCHAR2
, x_error_Tbl        OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_DIMENSION_VALIDATE_PVT;

 

/
