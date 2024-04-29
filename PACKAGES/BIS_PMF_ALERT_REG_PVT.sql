--------------------------------------------------------
--  DDL for Package BIS_PMF_ALERT_REG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_ALERT_REG_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVARTS.pls 120.0 2005/06/01 17:30:31 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVARTS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Alert Registration Repository
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 17-May-2000  jradhakr Creation
REM | Jun-2000     irchen   added manage_alert_registeration
REM | 27-Oct-2004  aguwalan Bug#3909131, added Add_Users_To_Role            |
REM +=======================================================================+
*/

G_BIS_ALERT_ROLE CONSTANT VARCHAR2(30):='BIS_ALERT';

--
-- PROCEDUREs
--

--
-- creates one parameter set
--
PROCEDURE Create_Parameter_set
( p_api_version      IN     NUMBER
, p_commit           IN     VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY    VARCHAR2
, x_error_Tbl        OUT NOCOPY    BIS_UTILITIES_PUB.Error_Tbl_Type
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

PROCEDURE Delete_Parameter_Set
( p_registration_ID  IN NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
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

PROCEDURE Retrieve_Parameter_set
( p_api_version              IN  NUMBER
, p_Param_Set_Rec            IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, p_current_row              IN  VARCHAR2 := NULL
, x_Param_Set_Tbl            OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Retrieves the adHocRole
--
PROCEDURE Retrieve_Notifiers_Code
( p_api_version              IN NUMBER
, p_performance_measure_id   IN NUMBER   := NULL
, p_target_level_id          IN NUMBER   := NULL
, p_time_dimension_level_id  IN NUMBER   := NULL
, p_plan_id                  IN NUMBER   := NULL
, p_parameter1_value         IN VARCHAR2 := NULL
, p_parameter2_value         IN VARCHAR2 := NULL
, p_parameter3_value         IN VARCHAR2 := NULL
, p_parameter4_value         IN VARCHAR2 := NULL
, p_parameter5_value         IN VARCHAR2 := NULL
, p_parameter6_value         IN VARCHAR2 := NULL
, p_parameter7_value         IN VARCHAR2 := NULL
, p_current_row              IN VARCHAR2 := NULL
, x_Notifiers_Code           OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
);

--
-- Retrieves the adHocRole
--
PROCEDURE Retrieve_Notifiers_Code
( p_api_version              IN NUMBER
, p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_Notifiers_Code           OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
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

PROCEDURE Manage_Alert_Registrations
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

Procedure Form_Param_Set_Rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, x_Param_Set_Rec         OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
);

Procedure Form_Param_Set_Rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Param_Set_Rec         OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
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


PROCEDURE Validate_Parameter_set
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE BuildAlertRegistrationURL
( p_measure_id                 IN   NUMBER
, p_target_level_id            IN   NUMBER   := NULL
, p_plan_id		       IN   VARCHAR2 := NULL
, p_parameter1levelId	       IN   NUMBER   := NULL
, p_parameter1ValueId	       IN   VARCHAR2 := NULL
, p_parameter2levelId	       IN   NUMBER   := NULL
, p_parameter2ValueId	       IN   VARCHAR2 := NULL
, p_parameter3levelId          IN   NUMBER   := NULL
, p_parameter3ValueId          IN   VARCHAR2 := NULL
, p_parameter4levelId          IN   NUMBER   := NULL
, p_parameter4ValueId          IN   VARCHAR2 := NULL
, p_parameter5levelId          IN   NUMBER   := NULL
, p_parameter5ValueId          IN   VARCHAR2 := NULL
, p_parameter6levelId          IN   NUMBER   := NULL
, p_parameter6ValueId          IN   VARCHAR2 := NULL
, p_parameter7levelId          IN   NUMBER   := NULL
, p_parameter7ValueId          IN   VARCHAR2 := NULL
, p_viewByLevelId              IN   VARCHAR2 := NULL
, p_alertTip                   IN   VARCHAR2 := NULL
, p_returnPageUrl              IN   VARCHAR2 := NULL
, x_alert_url                  OUT NOCOPY  VARCHAR2
);

PROCEDURE BuildAlertRegistrationURL
( p_measure_id	       IN   NUMBER
, p_timelevel_id       IN   NUMBER
, p_viewByLevelId      IN   VARCHAR2 := NULL
, p_alertTip           IN   VARCHAR2 := NULL
, p_returnPageUrl      IN   VARCHAR2 := NULL
, x_alert_url          OUT NOCOPY  VARCHAR2
);

PROCEDURE BuildScheduleReportURL
( p_RegionCode                 IN   VARCHAR2
, p_FunctionName               IN   VARCHAR2
, p_ApplicationId              IN   VARCHAR2 := NULL
, p_plan_id		       IN   VARCHAR2 := NULL
, p_parameter1levelId	       IN   NUMBER   := NULL
, p_parameter1ValueId	       IN   VARCHAR2 := NULL
, p_parameter2levelId	       IN   NUMBER   := NULL
, p_parameter2ValueId	       IN   VARCHAR2 := NULL
, p_parameter3levelId          IN   NUMBER   := NULL
, p_parameter3ValueId          IN   VARCHAR2 := NULL
, p_parameter4levelId          IN   NUMBER   := NULL
, p_parameter4ValueId          IN   VARCHAR2 := NULL
, p_parameter5levelId          IN   NUMBER   := NULL
, p_parameter5ValueId          IN   VARCHAR2 := NULL
, p_parameter6levelId          IN   NUMBER   := NULL
, p_parameter6ValueId          IN   VARCHAR2 := NULL
, p_parameter7levelId          IN   NUMBER   := NULL
, p_parameter7ValueId          IN   VARCHAR2 := NULL
, p_viewByLevelId              IN   VARCHAR2 := NULL
, p_alertTip                   IN   VARCHAR2 := NULL
, p_returnPageUrl              IN   VARCHAR2 := NULL
, x_alert_url                  OUT NOCOPY  VARCHAR2
);


PROCEDURE Add_Users_To_Role
( p_role_name                  IN   VARCHAR2
, p_user_names                 IN   VARCHAR2
);

END  BIS_PMF_ALERT_REG_PVT;

 

/
