--------------------------------------------------------
--  DDL for Package BIS_PMF_ALERT_REG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_ALERT_REG_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPARTS.pls 115.18 2002/12/20 11:26:01 mahrao ship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPMEAS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for managing Alert Registration Repository
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 17-May-2000  jradhakr Creation
REM |
REM +=======================================================================+
*/


-- Data Types: Records

TYPE parameter_set_rec_type IS RECORD
( REGISTRATION_ID             NUMBER
, PERFORMANCE_MEASURE_ID      NUMBER
, TARGET_LEVEL_ID             NUMBER
, TIME_DIMENSION_LEVEL_ID     NUMBER
, PLAN_ID                     NUMBER
, NOTIFIERS_CODE              VARCHAR2(250)
, PARAMETER1_VALUE            VARCHAR2(80)
, PARAMETER2_VALUE            VARCHAR2(80)
, PARAMETER3_VALUE            VARCHAR2(80)
, PARAMETER4_VALUE            VARCHAR2(80)
, PARAMETER5_VALUE            VARCHAR2(80)
, PARAMETER6_VALUE            VARCHAR2(80)
, PARAMETER7_VALUE            VARCHAR2(80)
, NOTIFY_OWNER_FLAG           VARCHAR2(1)
);

-- Data Types: Tables
--
TYPE parameter_set_tbl_type IS TABLE of parameter_set_rec_type
        INDEX BY BINARY_INTEGER;
--
-- Global Missing Composite Types
--
--
-- PROCEDUREs
--
-- creates one parameter set


PROCEDURE Create_Parameter_set
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Delete one parameter set.
--
PROCEDURE Delete_Parameter_set
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Retrieve a Table of parmeter set.
--
PROCEDURE Retrieve_Parameter_set
( p_api_version              IN  NUMBER
, p_measure_id               IN  NUMBER
, p_time_dimension_level_id  IN  NUMBER
, p_current_row              IN  VARCHAR2 := NULL
, x_Param_Set_Tbl            OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Checks if request is scheduled to run again.  If not, the request
-- is deleted from the Registration table and the ad hoc workflow role
-- is removed.
--
PROCEDURE Manage_Alert_Registrations
( p_Param_Set_Tbl            IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Manage_Alert_Registrations
( p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Function which will return a boolean varible, if parameter set exist
-- and will also return the notifiers_code
--

FUNCTION  Parameter_set_exist
( p_api_version      IN  NUMBER
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_notifiers_code   OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) return boolean;

END  BIS_PMF_ALERT_REG_PUB;

 

/
