--------------------------------------------------------
--  DDL for Package BIS_BUSINESS_PLAN_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_BUSINESS_PLAN_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVBPVS.pls 115.4 99/09/17 19:17:17 porting ship  $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVBPVS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for validating items in the Business Plans record
REM | NOTES                                                                 |
REM |     07/14/99    irchen   Creation                                     |
REM |
REM +=======================================================================+
*/
--
--
--
PROCEDURE Validate_Record
( p_api_version       IN  NUMBER
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Business_Plan_Rec IN  BIS_BUSINESS_PLAN_PUB.Business_Plan_Rec_Type
, x_return_status     OUT VARCHAR2
, x_error_Tbl         OUT BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
--
END BIS_BUSINESS_PLAN_VALIDATE_PVT;

 

/
