--------------------------------------------------------
--  DDL for Package BIS_PMF_REG_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_REG_SERVICE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVARSS.pls 115.27 2003/12/15 14:15:34 arhegde ship $ */

G_TARGET_LEVEL           VARCHAR2(80)   := 'FROMTARGETLEVEL';
G_ALL_TARGET             VARCHAR2(80)   := 'ALLTARGET';
G_REPORT_GEN             VARCHAR2(80)   := 'GENERATED_REPORT';
G_REPORT_BATCH           VARCHAR2(80)   := 'REPORT_BATCH';
G_ALERT_CONC_REQ_NAME  CONSTANT VARCHAR2(1000) := 'BIS_PMF_ALERT';

G_NOTSUBMIT VARCHAR2(10000) := fnd_message.get_string('BIS','BIS_NO_CONC');
G_FAILED_MSG CONSTANT VARCHAR2(10000) := 'BIS_CONC_FAILED';
G_SUCCESS_MSG CONSTANT VARCHAR2(10000) := 'BIS_CONC_SUCCESS';
G_REQUEST_ID_TOK CONSTANT VARCHAR2(10000) := 'REQUEST_ID';
G_USER_EXIST VARCHAR2(10000) := fnd_message.get_string('BIS','BIS_USER_EXIST');
G_REQUEST_EXIST VARCHAR2(10000)
  := fnd_message.get_string('BIS','BIS_REQUEST_EXIST');

--
-- Procedure Which accepts all the parameters from the Alert
-- Registration screen, processes the information and submits the request
--

PROCEDURE  process_parameter_full_set
 (p_request_id           OUT NOCOPY varchar2
 ,p_StartTime            IN  varchar2   default null
 ,p_EndTime              IN  varchar2   default null
 ,p_frequencyInterval    IN  varchar2   default null
 ,p_frequencyUnits       IN  varchar2   default null
 ,p_perf_measure_id      IN  varchar2   default null
 ,p_target_level_id      IN  varchar2   default null
 ,p_time_dim_level_id    IN  varchar2   default null
 ,p_notifiers            IN  varchar2   default null
 ,p_plan_id              IN  varchar2   default null
 ,p_parameter1_level     IN  varchar2   default null
 ,p_parameter1_value     IN  varchar2   default null
 ,p_parameter2_level     IN  varchar2   default null
 ,p_parameter2_value     IN  varchar2   default null
 ,p_parameter3_level     IN  varchar2   default null
 ,p_parameter3_value     IN  varchar2   default null
 ,p_parameter4_level     IN  varchar2   default null
 ,p_parameter4_value     IN  varchar2   default null
 ,p_parameter5_level     IN  varchar2   default null
 ,p_parameter5_value     IN  varchar2   default null
 ,p_parameter6_level     IN  varchar2   default null
 ,p_parameter6_value     IN  varchar2   default null
 ,p_parameter7_level     IN  varchar2   default null
 ,p_parameter7_value     IN  varchar2   default null
 ,p_view_by_level_id     IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
 ,p_alert_based_on       IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
);

--
-- Procedure Which Accepts the parameters Performance measure
-- and time dimension level id  from the Alert
-- Registration screen and processes the request
--

PROCEDURE  process_parameter_set
 (p_request_id           OUT NOCOPY varchar2
 ,p_perf_measure_id      IN  varchar2   default null
 ,p_time_dim_level_id    IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
);

--
-- Retrieve all Target information for the given performance measure
-- and time dimension level id.
--
PROCEDURE Retrieve_target_info
( p_api_version              IN  NUMBER
, p_measure_id               IN  NUMBER
, p_time_dimension_level_id  IN  NUMBER
, p_current_row              IN  VARCHAR2 := NULL
, p_alert_based_on           IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl               OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Retrieve a All Target information for the given target level
--
PROCEDURE Retrieve_target_info
( p_api_version              IN  NUMBER
, p_target_level_id          IN  NUMBER
, p_time_dimension_level_id  IN  NUMBER := NULL
, p_current_row              IN  VARCHAR2 := NULL
--, p_alert_based_on           IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl               OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

PROCEDURE Form_Parameter_Set
( p_measure_id             IN NUMBER
, p_time_level_id          IN NUMBER := NULL
, p_target_tbl             IN BIS_TARGET_PUB.Target_Tbl_type
, p_Notifiers_Code         IN VARCHAR2 := NULL
, x_parameter_set_tbl      OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
);

--
-- Procedure which insert the needed parameters to the alert
-- registration repository
--
PROCEDURE Register_Parameter_Set
( p_api_version      IN  NUMBER
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, p_session_id       IN  varchar2   default null
, p_alert_type       IN  varchar2   default null
, p_request_id       OUT NOCOPY varchar2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

FUNCTION IS_TOTAL_DIM_LEVEL
(p_DimLevelId IN NUMBER := NULL
)
RETURN BOOLEAN;


END BIS_PMF_REG_SERVICE_PVT;

 

/
