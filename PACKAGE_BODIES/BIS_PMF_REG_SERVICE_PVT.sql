--------------------------------------------------------
--  DDL for Package Body BIS_PMF_REG_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_REG_SERVICE_PVT" as
/* $Header: BISVARSB.pls 120.0 2005/05/31 18:29:21 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_PMF_REG_SERVICE_PVT';

l_debug_text             VARCHAR2(32000);

TYPE report_data_tbl_type IS TABLE OF VARCHAR2(32000)
  INDEX BY BINARY_INTEGER;


--
-- Procedure Which Accepts the parameters Performance measure
-- and all dimension level ids  from the Alert
-- Registration screen and determines which level is time.
-- then submits concurrent request.
--
PROCEDURE  submit_parameter_set_request
( p_StartTime            IN  varchar2   default null
, p_EndTime              IN  varchar2   default null
, p_frequencyInterval    IN  varchar2   default null
, p_frequencyUnits       IN  varchar2   default null
, p_request_id           OUT NOCOPY varchar2
, p_perf_measure_id      IN  varchar2   default null
, p_time_level_id        IN  varchar2   default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_session_id           IN  varchar2   default null
, p_alert_type           IN  varchar2   default null
, p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
, p_alert_based_on       IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
) ;

--
-- Procedure Which Accepts the parameters Performance measure
-- and time dimension level id  from the Alert
-- Schedulling screen, processes the information
-- and submits the concurrent request.
--
PROCEDURE  submit_parameter_set_request
( p_StartTime            IN  varchar2   default null
 ,p_EndTime              IN  varchar2   default null
 ,p_frequencyInterval    IN  varchar2   default null
 ,p_frequencyUnits       IN  varchar2   default null
 ,p_request_id           OUT NOCOPY varchar2
 ,p_perf_measure_id      IN  varchar2   default null
 ,p_time_dim_level_id    IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
 ,p_alert_based_on       IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
);

--
-- Procedure Which Accepts the parameters Performance measure
-- and dimension level value id  from the Alert
-- Request screen, processes the information
-- and adds the user to the request.
--
PROCEDURE  add_parameter_request
( p_perf_measure_id      IN  varchar2   default null
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
 ,p_alert_type           IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_current_row          IN  VARCHAR2 := 'N'
 ,p_notify_owner_flag    IN  VARCHAR2
 ,x_request_id           OUT NOCOPY varchar2
);

--
-- Procedure Which Accepts the parameters Performance measure
-- and time dimension level id  from the BIS Report
-- processes the information and submits the concurrent request.
--
PROCEDURE  process_report_set_request
( p_StartTime            IN  varchar2   default null
 ,p_EndTime              IN  varchar2   default null
 ,p_frequencyInterval    IN  varchar2   default null
 ,p_frequencyUnits       IN  varchar2   default null
 ,p_perf_measure_id      IN  varchar2   default null
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
, p_viewby_level_id      IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
 ,p_current_row          IN  VARCHAR2 := 'N'
 ,x_request_id           OUT NOCOPY varchar2
);

--
-- Procedure Which Accepts the parameters Performance measure,
-- dimension level and value ids from the BIS Report parameter page
-- and requests the reports to be generated in the background.
--
PROCEDURE  process_batch_report_request
( p_StartTime            IN  varchar2   default null
, p_EndTime              IN  varchar2   default null
, p_frequencyInterval    IN  varchar2   default null
, p_frequencyUnits       IN  varchar2   default null
, p_perf_measure_id      IN  varchar2   default null
, p_time_dim_level_id    IN  varchar2   default null
, p_notifiers            IN  varchar2   default null
, p_plan_id              IN  varchar2   default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter1_value     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter2_value     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter3_value     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter4_value     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter5_value     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter6_value     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_parameter7_value     IN  varchar2   default null
 ,p_viewby_level_id      IN  varchar2   default null
, p_session_id           IN  varchar2   default null
, p_alert_type           IN  varchar2   default null
, p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
, x_request_id           OUT NOCOPY varchar2
);

-- compares new to orig.  if a row in new is not in orig, that row is
-- added to the diff table.  all rows (including new) is put into
-- all table.
--
PROCEDURE Compare_param_sets
( p_param_set_tbl_orig IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, p_param_set_tbl_new  IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_param_set_tbl_all  OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_param_set_tbl_diff OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
);

Procedure Get_current_Target
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
--, p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
);

Procedure Get_Previous_Target
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
);


Procedure update_total_time
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
--, p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
);

--
-- retrieves data based on BIS Report Generator reports
--
PROCEDURE Retrieve_Report_Info
( p_measure_id           IN  NUMBER
, p_time_level_id        IN  NUMBER     default null
 ,p_plan_id              IN  NUMBER     default null
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
, p_viewby_level_id      IN  varchar2   default null
, x_target_level_tbl     OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_type
, x_target_tbl           OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
-- Helper routine which calls fnd_request APIs
-- For scheduled alerts
--
PROCEDURE submit_conc_request
( p_request_id              OUT NOCOPY varchar2
, p_StartTime               IN  varchar2   default null
, p_EndTime                 IN  varchar2   default null
, p_frequencyInterval       IN  varchar2   default null
, p_frequencyUnits          IN  varchar2   default null
, p_performance_measure_id  IN  NUMBER     default null
, p_time_dimension_level_id IN  NUMBER     default null
, p_session_id              IN  varchar2   default null
, p_current_row             IN  varchar2   default null
, p_alert_type              IN  varchar2   default null
, p_alert_based_on          IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
);

--
-- Helper routine which calls fnd_request APIs
-- For scheduled reports
--
PROCEDURE submit_Concurrent_Request
( p_report_data_Tbl         IN   report_data_tbl_type
 ,p_performance_measure_id  IN      NUMBER   default null
 ,p_time_dimension_level_id IN      NUMBER   default null
 ,p_session_id              IN  varchar2   default null
 ,p_StartTime            IN  varchar2   default null
 ,p_EndTime              IN  varchar2   default null
 ,p_frequencyInterval    IN  varchar2   default null
 ,p_frequencyUnits       IN  varchar2   default null
 ,p_current_row          IN  varchar2   default null
, x_request_id           OUT NOCOPY  VARCHAR2
);

-- helper procedure to determine if target owners should
-- be notified depending on the type of alert
--
Procedure Set_Notify_Owners
( p_alert_type         IN VARCHAR2
, x_notify_owners_flag OUT NOCOPY VARCHAR2
);


PROCEDURE Add_Subscribers
( p_Param_Set_rec  IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_id     OUT NOCOPY varchar2
, x_return_status  OUT NOCOPY varchar2
);

Procedure Form_Concurrent_Request
( p_request_desc            IN VARCHAR2
, p_Start_Time              IN VARCHAR2
, p_measure_id              IN NUMBER
, p_Measure_short_name      IN VARCHAR2
, p_time_level_id           IN NUMBER
, p_alert_type              IN VARCHAR2
, p_current_row             IN VARCHAR2
, p_alert_based_on          IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_Concurrent_Request_rec
    OUT NOCOPY BIS_CONCURRENT_MANAGER_PVT.PMF_Request_rec_Type
);

PROCEDURE Verify_Target_Level
( p_Target_Level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
, x_Target_Level_rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
);

PROCEDURE Verify_Target
( p_Target_rec       IN  BIS_Target_PUB.Target_Rec_Type
, p_parameter1_value IN  varchar2   default null
, p_parameter2_value IN  varchar2   default null
, p_parameter3_value IN  varchar2   default null
, p_parameter4_value IN  varchar2   default null
, p_parameter5_value IN  varchar2   default null
, p_parameter6_value IN  varchar2   default null
, p_parameter7_value IN  varchar2   default null
, x_Target_rec       OUT NOCOPY BIS_Target_PUB.Target_Rec_Type
);

FUNCTION has_Dimension_Levels
( p_Target_Level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
)
RETURN BOOLEAN;

FUNCTION has_Dimension_Level_Values
( p_Target_rec       IN  BIS_Target_PUB.Target_Rec_Type
, p_parameter1_value IN  varchar2   default null
, p_parameter2_value IN  varchar2   default null
, p_parameter3_value IN  varchar2   default null
, p_parameter4_value IN  varchar2   default null
, p_parameter5_value IN  varchar2   default null
, p_parameter6_value IN  varchar2   default null
, p_parameter7_value IN  varchar2   default null
)
RETURN BOOLEAN;

PROCEDURE check_View_by
( p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
, sameViewBy         OUT NOCOPY BOOLEAN
, viewByLevelNum     OUT NOCOPY NUMBER
);

FUNCTION is_time_level
(p_Dimension_Level_rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_rec_Type)
RETURN BOOLEAN;

--
PROCEDURE filter_duplicates (
  p_target_tbl IN BIS_TARGET_PUB.target_tbl_type
 ,x_target_tbl OUT NOCOPY BIS_TARGET_PUB.target_tbl_type
);

--
PROCEDURE filter_alert_based_on (
   p_target_tbl     IN BIS_TARGET_PUB.target_tbl_type
  ,p_alert_based_on IN VARCHAR2
  ,x_target_tbl	    OUT NOCOPY BIS_TARGET_PUB.target_tbl_type
  ,x_return_status  OUT NOCOPY VARCHAR2
) ;

--
-- Procedure Which Accepts all the parameters from the Alert
-- Registration screen, processes the information
-- and submits the request.
--
PROCEDURE  process_parameter_full_set
( p_request_id           OUT NOCOPY varchar2
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
)
IS

  l_report_data_tbl    report_data_tbl_type;
  l_target_level_rec   BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_number NUMBER;
  l_param_set_rec      BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl_new  BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_orig BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_all  BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_diff BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;

  l_target_level_id    NUMBER;
  l_notify_owners_flag VARCHAR2(100);
  -- l_user_id            VARCHAR2(100);
  l_return_status      VARCHAR2(1000);
  l_return_msg         VARCHAR2(32000);
  l_request_id         VARCHAR2(32000);
  l_debug              VARCHAR2(32000);
  l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version        NUMBER := 1;
  l_object_tbl         BIS_COMPUTED_ACTUAL_PVT.object_tbl_type;
  l_Measure_Rec        BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_short_name VARCHAR2(32000);
  l_measure_name       VARCHAR2(32000);
  l_Measure_Rec_p      BIS_MEASURE_PUB.Measure_Rec_Type;
  l_target_level_rec_p BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_error_Tbl_p        BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_alert_based_on     VARCHAR2(10);
BEGIN

  l_alert_based_on := p_alert_based_on;
  IF (l_alert_based_on IS NULL) THEN
    l_alert_based_on := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET;
  END IF;

  -- Debug messages should not be printed (irrespective of debug profile option).
  bis_utilities_pvt.set_debug_log_flag (  -- 2715218
    p_is_true         => FALSE
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  ) ;


  BIS_UTILITIES_PUB.put_line(p_text =>'alert type: '||p_alert_type);


  IF p_perf_measure_id IS NOT NULL THEN
    l_measure_rec.measure_id := p_perf_measure_id;
    l_measure_rec_p := l_measure_rec;
		BIS_Measure_PVT.Retrieve_Measure
    ( p_api_version        => l_api_version
    , p_measure_rec        => l_measure_rec_p
    , p_all_info           => FND_API.G_FALSE
    , x_measure_rec        => l_measure_rec
    , x_return_status      => l_return_status
    , x_error_Tbl          => l_error_Tbl
    );
    l_measure_short_name := l_measure_rec.measure_short_name;
    l_measure_name := l_measure_rec.measure_name;

    -- dbms_output.put_line('bisvarsb. process_parameter full set 0002 ');


  ELSIF p_target_level_id IS NOT NULL THEN
    l_Target_Level_rec.Target_Level_id := p_target_level_id;
    l_Target_Level_rec_p := l_Target_Level_rec;
		BIS_Target_Level_PVT.Retrieve_Target_Level
    ( p_api_version        => l_api_version
    , p_Target_Level_rec   => l_Target_Level_rec_p
    , p_all_info           => FND_API.G_TRUE
    , x_Target_Level_rec   => l_Target_Level_rec
    , x_return_status      => l_return_status
    , x_error_Tbl          => l_error_Tbl
    );
    l_measure_short_name := l_Target_Level_rec.measure_short_name;
    l_measure_name := l_Target_Level_rec.measure_name;

    -- dbms_output.put_line('bisvarsb. process_parameter full set 0003 ');

  END IF;

  -- checking if AK region for this measure is defined.
  -- if not, simply return with message telling user the proble.
  -- if so, continue
  --
  BIS_COMPUTED_ACTUAL_PVT.Get_Related_Objects
  ( p_measure_short_name => l_measure_short_name
  , x_object_tbl         => l_object_tbl
  , x_return_status      => l_return_status
  );

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0004 ');

  IF l_object_tbl.COUNT < 1 THEN
    --p_request_id := '-1';
      p_request_id
        := BIS_UTILITIES_PVT.Get_FND_Message
        ( p_message_name   => 'BIS_AK_NOT_SET_UP_MSG'
        , p_msg_param1     => 'MEASURE_NAME'
        , p_msg_param1_val => bis_utilities_pvt.escape_html(l_measure_name)
        );

    -- dbms_output.put_line('bisvarsb. process_parameter full set 0005 ');

    return;
  ELSE

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0002 ');

  -- l_user_id := ICX_SEC.getID(ICX_SEC.PV_USER_ID, p_session_id);

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0006 ');

  Set_Notify_Owners
  ( p_alert_type         => p_alert_type
  , x_notify_owners_flag => l_notify_owners_flag
  );

   -- dbms_output.put_line('bisvarsb. process_parameter full set 0007 ');

  IF UPPER(p_alert_type) = G_TARGET_LEVEL
  OR p_alert_type IS NULL THEN

    l_debug := l_debug ||', 1: '||p_parameter1_level
               ||', 2: '||p_parameter2_level||' ';
    submit_parameter_set_request
    ( p_StartTime          => p_StartTime
    , p_EndTime            => p_EndTime
    , p_frequencyInterval  => p_frequencyInterval
    , p_frequencyUnits     => p_frequencyUnits
    , p_request_id         => l_request_id
    , p_perf_measure_id    => p_perf_measure_id
    , p_time_level_id      => p_time_dim_level_id
    , p_parameter1_level   => p_parameter1_level
    , p_parameter2_level   => p_parameter2_level
    , p_parameter3_level   => p_parameter3_level
    , p_parameter4_level   => p_parameter4_level
    , p_parameter5_level   => p_parameter5_level
    , p_parameter6_level   => p_parameter6_level
    , p_parameter7_level   => p_parameter7_level
    , p_session_id         => p_session_id
    , p_alert_type         => p_alert_type
    , p_notify_owners_flag => l_notify_owners_flag
    , p_current_row        => p_current_row
    , p_alert_based_on     => l_alert_based_on
    );

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0008 ');

  ELSIF UPPER(p_alert_type) = G_ALL_TARGET THEN

    add_parameter_request
    ( p_perf_measure_id      => p_perf_measure_id
    , p_target_level_id      => p_target_level_id
    , p_time_dim_level_id    => p_time_dim_level_id
    , p_notifiers            => p_notifiers
    , p_plan_id              => p_plan_id
    , p_parameter1_level     => p_parameter1_level
    , p_parameter1_value     => p_parameter1_value
    , p_parameter2_level     => p_parameter2_level
    , p_parameter2_value     => p_parameter2_value
    , p_parameter3_level     => p_parameter3_level
    , p_parameter3_value     => p_parameter3_value
    , p_parameter4_level     => p_parameter4_level
    , p_parameter4_value     => p_parameter4_value
    , p_parameter5_level     => p_parameter5_level
    , p_parameter5_value     => p_parameter5_value
    , p_parameter6_level     => p_parameter6_level
    , p_parameter6_value     => p_parameter6_value
    , p_parameter7_level     => p_parameter7_level
    , p_parameter7_value     => p_parameter7_value
    , p_alert_type           => p_alert_type
    , p_session_id           => p_session_id
    , p_current_row          => p_current_row
    , p_notify_owner_flag    => l_notify_owners_flag
    , x_request_id           => l_request_id
    );

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0009 ');

  ELSIF UPPER(p_alert_type) = G_REPORT_GEN THEN

    process_report_set_request
    ( p_StartTime          => p_StartTime
    , p_EndTime            => p_EndTime
    , p_frequencyInterval  => p_frequencyInterval
    , p_frequencyUnits     => p_frequencyUnits
    , p_perf_measure_id    => p_perf_measure_id
    , p_time_dim_level_id  => p_time_dim_level_id
    , p_notifiers          => p_notifiers
    , p_plan_id            => p_plan_id
    , p_parameter1_level   => p_parameter1_level
    , p_parameter1_value   => p_parameter1_value
    , p_parameter2_level   => p_parameter2_level
    , p_parameter2_value   => p_parameter2_value
    , p_parameter3_level   => p_parameter3_level
    , p_parameter3_value   => p_parameter3_value
    , p_parameter4_level   => p_parameter4_level
    , p_parameter4_value   => p_parameter4_value
    , p_parameter5_level   => p_parameter5_level
    , p_parameter5_value   => p_parameter5_value
    , p_parameter6_level   => p_parameter6_level
    , p_parameter6_value   => p_parameter6_value
    , p_parameter7_level   => p_parameter7_level
    , p_parameter7_value   => p_parameter7_value
    , p_viewBy_level_id    => p_view_by_level_id
    , p_session_id         => p_session_id
    , p_alert_type         => p_alert_type
    , p_notify_owners_flag => l_notify_owners_flag
    , p_current_row        => p_current_row
    , x_request_id         => l_request_id
    );

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0002 ');

  ELSIF UPPER(p_alert_type) = G_REPORT_BATCH THEN

   -- not done.  waiting for Reports Gen team
   --
   process_batch_report_request
    ( p_StartTime          => p_StartTime
    , p_EndTime            => p_EndTime
    , p_frequencyInterval  => p_frequencyInterval
    , p_frequencyUnits     => p_frequencyUnits
    , p_perf_measure_id    => p_perf_measure_id
    , p_time_dim_level_id  => p_time_dim_level_id
    , p_notifiers          => p_notifiers
    , p_plan_id            => p_plan_id
    , p_parameter1_level   => p_parameter1_level
    , p_parameter1_value   => p_parameter1_value
    , p_parameter2_level   => p_parameter2_level
    , p_parameter2_value   => p_parameter2_value
    , p_parameter3_level   => p_parameter3_level
    , p_parameter3_value   => p_parameter3_value
    , p_parameter4_level   => p_parameter4_level
    , p_parameter4_value   => p_parameter4_value
    , p_parameter5_level   => p_parameter5_level
    , p_parameter5_value   => p_parameter5_value
    , p_parameter6_level   => p_parameter6_level
    , p_parameter6_value   => p_parameter6_value
    , p_parameter7_level   => p_parameter7_level
    , p_parameter7_value   => p_parameter7_value
    , p_viewBy_level_id    => p_view_by_level_id
    , p_session_id         => p_session_id
    , p_alert_type         => p_alert_type
    , p_notify_owners_flag => l_notify_owners_flag
    , p_current_row        => p_current_row
    , x_request_id         => l_request_id
    );

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0002 ');

  END IF;

  -- dbms_output.put_line('bisvarsb. process_parameter full set 0002 ');

  --p_request_id := l_request_id ||l_debug;
  p_request_id := l_request_id;

  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    l_debug :=l_debug||' exception 1 at process_parameter_full_set. '||sqlerrm;
    p_request_id := l_request_id ||l_debug;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 2 at process_parameter_full_set. '||sqlerrm;
    p_request_id := l_request_id ||l_debug;
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 3 at process_parameter_full_set. '||sqlerrm;
    p_request_id := l_request_id ||l_debug;
    l_error_tbl_p := l_error_tbl;
		BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'Process_Parameter_set'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

end process_parameter_full_set;

--
-- Procedure Which Accepts the parameters Performance measure
-- and all dimension level ids  from the Alert
-- Registration screen and determines which level is time.
-- then submits concurrent request.
--
PROCEDURE  submit_parameter_set_request
( p_StartTime            IN  varchar2   default null
, p_EndTime              IN  varchar2   default null
, p_frequencyInterval    IN  varchar2   default null
, p_frequencyUnits       IN  varchar2   default null
, p_request_id           OUT NOCOPY varchar2
, p_perf_measure_id      IN  varchar2   default null
, p_time_level_id        IN  varchar2   default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_session_id           IN  varchar2   default null
, p_alert_type           IN  varchar2   default null
, p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
, p_alert_based_on       IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
)
IS

  l_time_level_id        NUMBER := NULL;
  l_Dimension_Level_Tbl  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type;
  l_debug                VARCHAR2(32000);
  l_request_id           VARCHAR2(32000);

BEGIN

  l_debug := l_debug || ', in submit_parameter_set_request2.';

  IF p_parameter1_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(1).Dimension_Level_Id
      :=TO_NUMBER(p_parameter1_level);
  END IF;
  IF p_parameter2_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(2).Dimension_Level_Id
      :=TO_NUMBER(p_parameter2_level);
  END IF;
  IF p_parameter3_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(3).Dimension_Level_Id
      :=TO_NUMBER(p_parameter3_level);
  END IF;
  IF p_parameter4_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(4).Dimension_Level_Id
      :=TO_NUMBER(p_parameter4_level);
  END IF;
  IF p_parameter5_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(5).Dimension_Level_Id
      :=TO_NUMBER(p_parameter5_level);
  END IF;
  IF p_parameter6_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(6).Dimension_Level_Id
      :=TO_NUMBER(p_parameter6_level);
  END IF;
  IF p_parameter7_level IS NOT NULL THEN
    l_Dimension_Level_Tbl(7).Dimension_Level_Id
      :=TO_NUMBER(p_parameter7_level);
  END IF;

  IF p_time_level_id IS NOT NULL THEN
    l_time_level_id := TO_NUMBER(p_time_level_id);
    BIS_UTILITIES_PUB.put_line(p_text =>'Passed time: '||l_time_level_id);
  ELSE
    FOR i IN 1..l_Dimension_Level_Tbl.COUNT LOOP
    l_debug := l_debug || ', D'||i
    ||': '||l_Dimension_Level_Tbl(i).Dimension_Level_Id;
      IF is_time_level(l_Dimension_Level_Tbl(i)) THEN
        l_debug := l_debug || ', E.';
        l_time_level_id := l_Dimension_Level_Tbl(i).Dimension_Level_Id;
        l_debug := l_debug || ', F: '||l_time_level_id;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  l_debug := l_debug || '  Got time level: '||l_time_level_id;
  submit_parameter_set_request
  ( p_StartTime          => p_StartTime
   ,p_EndTime            => p_EndTime
   ,p_frequencyInterval  => p_frequencyInterval
   ,p_frequencyUnits     => p_frequencyUnits
   ,p_request_id         => l_request_id
   ,p_perf_measure_id    => p_perf_measure_id
   ,p_time_dim_level_id  => l_time_level_id
   ,p_session_id         => p_session_id
   ,p_alert_type         => p_alert_type
   ,p_notify_owners_flag => p_notify_owners_flag
  , p_current_row        => p_current_row
   ,p_alert_based_on     => p_alert_based_on
  );
  --p_request_id := l_request_id ||l_debug;
  p_request_id := l_request_id;

EXCEPTION
  WHEN OTHERS THEN
    l_debug :=l_debug||' exception at submit_parameter_set_request2 '||sqlerrm;
    p_request_id := l_request_id ||l_debug;

END submit_parameter_set_request;

--
-- Procedure Which Accepts the parameters Performance measure
-- and time dimension level id  from the Alert
-- Registration screen and submit  a concurrent request.
--
PROCEDURE  submit_parameter_set_request
( p_StartTime            IN  varchar2   default null
 ,p_EndTime              IN  varchar2   default null
 ,p_frequencyInterval    IN  varchar2   default null
 ,p_frequencyUnits       IN  varchar2   default null
 ,p_request_id           OUT NOCOPY varchar2
 ,p_perf_measure_id      IN  varchar2   default null
 ,p_time_dim_level_id    IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
 ,p_alert_based_on       IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
)
IS

  l_param_set_rec     BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl     BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
  l_return_status     VARCHAR2(1000);
  l_request_scheduled VARCHAR2(1000);
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version       NUMBER := 1;
  l_Conc_exist        BOOLEAN := FALSE;
  l_request_id        VARCHAR2(32000);
  l_debug             VARCHAR2(32000);
  l_debug2            VARCHAR2(32000);
  l_error_Tbl_p       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_debug_text := l_debug_text||': perf measure id: '||p_perf_measure_id
                  ||', time lev id: '||p_time_dim_level_id||'--  ';
  IF p_perf_measure_id IS NOT NULL THEN
    l_param_set_Rec.PERFORMANCE_MEASURE_ID  := to_number(p_perf_measure_id);
  END IF;
  IF p_time_dim_level_id IS NOT NULL THEN
    l_param_set_Rec.TIME_DIMENSION_LEVEL_ID := to_number(p_time_dim_level_id);
  END IF;

  l_debug_text := l_debug_text||': perf measure id REC: '
                  ||l_param_set_Rec.PERFORMANCE_MEASURE_ID
                  ||', time lev id: '
                  ||l_param_set_Rec.TIME_DIMENSION_LEVEL_ID
                  ||'--  ';

  BIS_UTILITIES_PUB.put_line(p_text =>'Managing measure registrations');
  BIS_PMF_ALERT_REG_PVT.Manage_Alert_Registrations
  ( p_Param_Set_rec    => l_Param_Set_rec
  , x_request_scheduled => l_request_scheduled
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  );
  l_debug_text := l_debug_text||': '
    ||'Manage_Alert_Registration Target level '||l_request_scheduled
    ||' , '||l_return_status;
  --BIS_UTILITIES_PUB.put_line(p_text =>'ARSB: after managing reg: '||l_debug_text);

  IF l_request_scheduled = FND_API.G_TRUE THEN

    --BIS_UTILITIES_PUB.put_line(p_text =>'Request exist');
    l_debug_text := l_debug_text||': '||G_REQUEST_EXIST;
    l_request_id := G_REQUEST_EXIST;

  ELSE

    --BIS_UTILITIES_PUB.put_line(p_text =>'Request does not exist');
    process_parameter_set
    ( p_request_id        => l_request_id
    -- , p_request_id              => l_debug2
    , p_perf_measure_id   => l_param_set_Rec.performance_measure_id
    , p_time_dim_level_id => l_param_set_Rec.time_dimension_level_id
    , p_session_id        => p_session_id
    , p_alert_type        => p_alert_type
    , p_notify_owners_flag => p_notify_owners_flag
    , p_current_row        => p_current_row
    );
    l_debug_text := l_debug_text||l_debug2;

    submit_conc_request
    ( p_request_id              => l_request_id
    -- , p_request_id              => l_debug2
    , p_StartTime               => p_StartTime
    , p_EndTime                 => p_EndTime
    , p_frequencyInterval       => p_frequencyInterval
    , p_frequencyUnits          => p_frequencyUnits
    , p_performance_measure_id  => l_Param_Set_Rec.performance_measure_id
    , p_time_dimension_level_id => l_Param_Set_Rec.time_dimension_level_id
    , p_session_id              => p_session_id
    , p_current_row             => p_current_row
    , p_alert_type              => p_alert_type
    , p_alert_based_on          => p_alert_based_on
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Detailed alert request submitted.');
    l_debug_text := l_debug_text||l_debug2;

    --p_request_id := l_request_id;

  END IF;

  p_request_id := l_request_id;
  --p_request_id := l_request_id||' ..debug..'||l_debug_text;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    p_request_id := l_request_id
      ||' exception 1 in submit_parameter_set_request ';
    BIS_UTILITIES_PUB.put_line(p_text =>'debug: '||l_debug_text);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id
      ||' exception 2 in submit_parameter_set_request ';
    BIS_UTILITIES_PUB.put_line(p_text =>'debug: '||l_debug_text);
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id||', debug: '||l_debug_text
      ||' exception 3 in submit_parameter_set_request '||sqlerrm;
    BIS_UTILITIES_PUB.put_line(p_text =>'debug: '||l_debug_text);
    l_error_Tbl_p := l_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'submit_parameter_set_request'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

END  submit_parameter_set_request;

--
-- Procedure Which Accepts the parameters Performance measure
-- and dimension level value id  from the Alert
-- Request screen, processes the information
-- and adds the user to the request.
--
PROCEDURE  add_parameter_request
( p_perf_measure_id      IN  varchar2   default null
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
 ,p_alert_type           IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_current_row          IN  VARCHAR2 := 'N'
 ,p_notify_owner_flag    IN  varchar2
 ,x_request_id           OUT NOCOPY varchar2
)
IS

  l_target_level_rec   BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_number NUMBER;
  l_param_set_rec      BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl_new  BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_orig BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_all  BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_diff BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;

  l_target_level_id    NUMBER;
  l_notify_owners_flag VARCHAR2(100);
  -- l_user_id            VARCHAR2(100);
  l_return_status      VARCHAR2(1000);
  l_request_id         VARCHAR2(32000);
  l_debug              VARCHAR2(32000);
  l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version        NUMBER := 1;
  l_error_Tbl_p        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    IF p_target_level_id IS NOT NULL THEN
      l_target_level_id := p_target_level_id ;
    ELSE
      -- Assign the appropriate values to TL table and
      -- get the target_level_id
      --
      IF p_perf_measure_id IS NOT NULL AND p_perf_measure_id <> '' THEN
        l_target_level_rec.Measure_ID         := to_number(p_perf_measure_id);
      END IF;

      IF p_parameter1_level IS NOT NULL AND p_parameter1_level <> '' THEN
        l_target_level_rec.Dimension1_Level_ID:= to_number(p_parameter1_level);
      END IF;

      IF p_parameter2_level IS NOT NULL AND p_parameter2_level <> '' THEN
        l_target_level_rec.Dimension2_Level_ID:= to_number(p_parameter2_level);
      END IF;

      IF p_parameter3_level IS NOT NULL AND p_parameter3_level <> '' THEN
        l_target_level_rec.Dimension3_Level_ID:= to_number(p_parameter3_level);
      END IF;

      IF p_parameter4_level IS NOT NULL AND p_parameter4_level <> '' THEN
        l_target_level_rec.Dimension4_Level_ID:= to_number(p_parameter4_level);
      END IF;

      IF p_parameter5_level IS NOT NULL AND p_parameter5_level <> '' THEN
        l_target_level_rec.Dimension5_Level_ID:= to_number(p_parameter5_level);
      END IF;

      IF p_parameter6_level IS NOT NULL AND p_parameter6_level <> '' THEN
        l_target_level_rec.Dimension6_Level_ID:= to_number(p_parameter6_level);
      END IF;

      IF p_parameter7_level IS NOT NULL AND p_parameter7_level <> '' THEN
        l_target_level_rec.Dimension7_Level_ID:= to_number(p_parameter7_level);
      END IF;

      l_debug := l_debug||' target level rec assigned. ';

      l_target_level_id
        :=BIS_TARGET_LEVEL_PVT.Get_Level_Id_From_Dimlevels(l_target_level_rec);
      l_debug := l_debug||' got target level id: '||l_target_level_id ||'!';

    END IF;

    l_Target_Level_Rec.target_level_id := l_target_level_id;

    BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
    ( p_api_version         => 1.0
    , p_Target_Level_Rec    => l_Target_Level_Rec
    , x_Dimension_Level_Rec => l_Dimension_Level_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status       => l_return_status
    , x_error_Tbl           => l_error_Tbl
    );

    BIS_UTILITIES_PUB.put_line(p_text =>'Time level retrieved: '
    ||l_Dimension_Level_Rec.dimension_level_short_name
    ||', dimension level number: '||l_dimension_level_number);

    l_debug := l_debug||' target level id: '||l_target_level_id;
    -- Assign all values to parameter set Rec.
    --

    IF p_perf_measure_id IS NOT NULL THEN
      l_param_set_Rec.PERFORMANCE_MEASURE_ID  := to_number(p_perf_measure_id);
    END IF;
    IF l_target_level_id IS NOT NULL THEN
      l_param_set_Rec.TARGET_LEVEL_ID          := to_number(l_target_level_id);
    END IF;

    l_param_set_Rec.TIME_DIMENSION_LEVEL_ID
      := l_Dimension_Level_Rec.Dimension_Level_id;

    IF p_plan_id IS NOT NULL THEN
      l_param_set_Rec.PLAN_ID                  := to_number(p_plan_id);
    END IF;
    l_param_set_Rec.PARAMETER1_VALUE         := p_parameter1_value;
    l_param_set_Rec.PARAMETER2_VALUE         := p_parameter2_value;
    l_param_set_Rec.PARAMETER3_VALUE         := p_parameter3_value;
    l_param_set_Rec.PARAMETER4_VALUE         := p_parameter4_value;
    l_param_set_Rec.PARAMETER5_VALUE         := p_parameter5_value;
    l_param_set_Rec.PARAMETER6_VALUE         := p_parameter6_value;
    l_param_set_Rec.PARAMETER7_VALUE         := p_parameter7_value;
    l_param_set_rec.notify_owner_flag        := p_notify_owner_flag;  --mahesh
    l_param_set_tbl_new(l_param_set_tbl_new.COUNT+1) := l_param_set_rec;

    BIS_PMF_ALERT_REG_PVT.Retrieve_Parameter_set
     ( p_api_version             => 1.0
     , p_measure_id              => p_perf_measure_id
     , p_time_dimension_level_id => p_time_dim_level_id
     , p_current_row             => p_current_row
     , x_Param_Set_Tbl           => l_Param_Set_Tbl_orig
     , x_return_status           => l_return_status
     , x_error_Tbl               => l_error_Tbl
     );
    BIS_UTILITIES_PUB.put_line(p_text =>'Original number of parameter sets: '|| l_Param_Set_Tbl_orig.count);

    -- Check if new target;
    -- if new, register alert into ART
    -- if not new, add subscribers
    --
    Compare_param_Sets
    ( p_param_set_tbl_orig => l_param_set_tbl_orig
    , p_param_set_tbl_new  => l_param_set_tbl_new
    , x_param_set_tbl_all  => l_param_set_tbl_all
    , x_param_set_tbl_diff => l_param_set_tbl_diff
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Parameter set comparison results: '
    ||' Original: '||l_param_set_tbl_orig.COUNT
    ||', new: '||l_param_set_tbl_new.COUNT
    ||', difference: '||l_param_set_tbl_diff.COUNT
    ||', all: '||l_param_set_tbl_all.COUNT
    );
    l_debug := l_debug
    ||' Original: '||l_param_set_tbl_orig.COUNT
    ||', new: '||l_param_set_tbl_new.COUNT
    ||', difference: '||l_param_set_tbl_diff.COUNT
    ||', all: '||l_param_set_tbl_all.COUNT;


    IF l_param_set_tbl_diff.COUNT > 0 THEN
      FOR i IN 1..l_param_set_tbl_diff.COUNT LOOP
        Register_Parameter_set
        ( p_api_version    => l_api_version
        --, p_Param_Set_Rec  => l_Param_Set_tbl_diff(i)
        , p_Param_Set_Rec  => l_Param_Set_rec
        , p_request_id     => l_request_id
        , x_return_status  => l_return_status
        , x_error_Tbl      => l_error_Tbl
        );
        Add_Subscribers
        ( p_Param_Set_Rec  => l_Param_Set_rec
        --( p_Param_Set_rec => l_Param_Set_tbl_diff(i)
        , x_request_id    => l_request_id
        , x_return_status => l_return_status
        );
        l_debug := l_debug
        ||' Register_Parameter_set status '||l_return_status ;
        l_debug := l_debug||' ---- '||l_request_id;
      END LOOP;

      BIS_UTILITIES_PUB.put_line(p_text =>'New parameter sets registeration status: '||l_return_status);
    ELSE
      Add_Subscribers
      ( p_Param_Set_rec => l_Param_Set_rec
      , x_request_id    => l_request_id
      , x_return_status => l_return_status
      );
      l_debug := l_debug||' Register_Parameter_set status '||l_return_status ;
      l_debug := l_debug||' ---- '||l_request_id;
    END IF;

    x_request_id := l_request_id;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    l_debug :=l_debug||' exception 1 at add_parameter_set. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 2 at add_parameter_set. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 3 at add_parameter_set. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
    l_error_tbl_p := l_error_tbl;
		BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'Add_Parameter_set'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

END add_parameter_request;

--
-- Procedure Which Accepts the parameters Performance measure,
-- dimension level and value ids from the BIS Report
-- processes the information and submits the concurrent request.
--
PROCEDURE  process_report_set_request
( p_StartTime            IN  varchar2   default null
, p_EndTime              IN  varchar2   default null
, p_frequencyInterval    IN  varchar2   default null
, p_frequencyUnits       IN  varchar2   default null
, p_perf_measure_id      IN  varchar2   default null
, p_time_dim_level_id    IN  varchar2   default null
, p_notifiers            IN  varchar2   default null
, p_plan_id              IN  varchar2   default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter1_value     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter2_value     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter3_value     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter4_value     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter5_value     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter6_value     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_parameter7_value     IN  varchar2   default null
 ,p_viewby_level_id      IN  varchar2   default null
, p_session_id           IN  varchar2   default null
, p_alert_type           IN  varchar2   default null
, p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
, x_request_id           OUT NOCOPY varchar2
)
IS

  l_target_tbl          BIS_TARGET_PUB.Target_Tbl_type;
  l_target_level_tbl    BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_type;
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_Alert_Request_rec   BIS_ALERT_SERVICE_PVT.Alert_Request_rec_Type;
  l_Alert_Request_tbl   BIS_ALERT_SERVICE_PVT.Alert_Request_tbl_Type;
  l_Concurrent_Request_Tbl BIS_CONCURRENT_MANAGER_PVT.PMF_Request_Tbl_Type;
  l_return_status       VARCHAR2(1000);
  l_request_id_tbl      BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;
  l_debug               VARCHAR2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_errbuf              VARCHAR2(32000);
  l_retcode             VARCHAR2(32000);
  l_perf_measure_id     NUMBER;
  l_time_dim_level_id   NUMBER;
  l_plan_id             NUMBER;
  l_error_Tbl_p         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'report alert');

  IF p_perf_measure_id IS NOT NULL THEN
    l_perf_measure_id := to_number(p_perf_measure_id);
  END IF;
  IF p_time_dim_level_id IS NOT NULL THEN
    l_time_dim_level_id := to_number(p_time_dim_level_id);
  END IF;
  IF p_plan_id IS NOT NULL THEN
    l_plan_id := to_number(p_plan_id);
  END IF;

  Retrieve_Report_Info
  ( p_measure_id         => l_perf_measure_id
  , p_time_level_id      => l_time_dim_level_id
  , p_plan_id            => l_plan_id
  , p_parameter1_level   => p_parameter1_level
  , p_parameter1_value   => p_parameter1_value
  , p_parameter2_level   => p_parameter2_level
  , p_parameter2_value   => p_parameter2_value
  , p_parameter3_level   => p_parameter3_level
  , p_parameter3_value   => p_parameter3_value
  , p_parameter4_level   => p_parameter4_level
  , p_parameter4_value   => p_parameter4_value
  , p_parameter5_level   => p_parameter5_level
  , p_parameter5_value   => p_parameter5_value
  , p_parameter6_level   => p_parameter6_level
  , p_parameter6_value   => p_parameter6_value
  , p_parameter7_level   => p_parameter7_level
  , p_parameter7_value   => p_parameter7_value
  , p_viewby_level_id    => p_viewby_level_id
  , x_target_level_tbl   => l_Target_Level_Tbl
  , x_target_tbl         => l_target_tbl
  , x_return_status      => l_return_status
  , x_error_Tbl          => l_error_Tbl
  );
  BIS_UTILITIES_PUB.put_line(p_text =>'retrieved report target rows: '||l_target_tbl.count);

  FOR i IN 1..l_target_level_tbl.COUNT LOOP
  --BIS_UTILITIES_PUB.put_line(p_text =>'Target level id: '||l_target_level_tbl(i).target_level_id);
    FOR j IN 1..l_target_tbl.COUNT LOOP
      IF l_target_level_tbl(i).Target_level_id=l_target_tbl(j).Target_level_id
      THEN
        BIS_ALERT_SERVICE_PVT.Form_Alert_Request_rec
        ( p_target_level_rec     => l_target_level_tbl(i)
        , p_target_rec           => l_target_tbl(j)
        , p_dimension_level_rec  => l_dimension_level_rec
        , p_notify_set	         => p_notifiers
        , p_alert_type	         => p_alert_type
        , x_Alert_Request_rec    => l_Alert_Request_rec
        );
        BIS_UTILITIES_PUB.put_line(p_text =>'Target level ID in Alert request rec: '
        ||l_Alert_Request_rec.target_level_id);
        l_Alert_Request_tbl(l_Alert_Request_tbl.COUNT+1):=l_Alert_Request_rec;
      END IF;
    END LOOP;
  END LOOP;

  BIS_ALERT_SERVICE_PVT.Form_Concurrent_Request
  ( p_Alert_Request_Tbl      => l_Alert_Request_Tbl
  , x_Concurrent_Request_Tbl => l_Concurrent_Request_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Submit concurrent requests for Detial Alert Service');
  --
  BIS_CONCURRENT_MANAGER_PVT.Submit_Concurrent_Request
  ( p_Concurrent_Request_Tbl => l_Concurrent_Request_Tbl
  , x_request_id_tbl         => l_request_id_tbl
  , x_errbuf                 => l_errbuf
  , x_retcode                => l_retcode
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'report request submitted. id: '||x_request_id);
  IF l_request_id_tbl.COUNT > 0 THEN
    x_request_id := l_request_id_tbl(l_request_id_tbl.FIRST);
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    l_debug :=l_debug||' exception 1 at process_report_set_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 2 at process_report_set_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug||' exception 3 at process_report_set_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  	l_error_tbl_p := l_error_Tbl;
		BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'process_report_set_request'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );
END process_report_set_request;

--
-- Procedure Which Accepts the parameters Performance measure,
-- dimension level and value ids from the BIS Report parameter page
-- and requests the reports to be generated in the background.
--
PROCEDURE  process_batch_report_request
( p_StartTime            IN  varchar2   default null
, p_EndTime              IN  varchar2   default null
, p_frequencyInterval    IN  varchar2   default null
, p_frequencyUnits       IN  varchar2   default null
, p_perf_measure_id      IN  varchar2   default null
, p_time_dim_level_id    IN  varchar2   default null
, p_notifiers            IN  varchar2   default null
, p_plan_id              IN  varchar2   default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter1_value     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter2_value     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter3_value     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter4_value     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter5_value     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter6_value     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_parameter7_value     IN  varchar2   default null
 ,p_viewby_level_id      IN  varchar2   default null
, p_session_id           IN  varchar2   default null
, p_alert_type           IN  varchar2   default null
, p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
, x_request_id           OUT NOCOPY varchar2
)
IS

  l_return_status      VARCHAR2(1000);
  l_request_id         VARCHAR2(32000);
  l_debug              VARCHAR2(32000);
  l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_Tbl_p        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'IN process_batch_report_request');

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    l_debug :=l_debug
    ||' exception 1 at process_batch_report_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug
    ||' exception 2 at process_batch_report_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_debug :=l_debug
    ||' exception 3 at process_batch_report_request. '||sqlerrm;
    x_request_id := x_request_id ||l_debug;
    l_error_tbl_p := l_error_tbl;
		BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'process_batch_report_request'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

END process_batch_report_request;

--
-- Procedure Which Accepts the parameters Performance measure
-- and time dimension level id  from the Alert
-- Registration screen and submit the request for the needed once
--
PROCEDURE  process_parameter_set
 (p_request_id           OUT NOCOPY varchar2
 ,p_perf_measure_id      IN  varchar2   default null
 ,p_time_dim_level_id    IN  varchar2   default null
 ,p_session_id           IN  varchar2   default null
 ,p_alert_type           IN  varchar2   default null
 ,p_notify_owners_flag   IN  varchar2   default null
, p_current_row          IN  VARCHAR2 := 'N'
)
IS
  l_notifiers_code    VARCHAR2(32000);
  l_request_id        VARCHAR2(32000);
  l_param_set_rec     BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl     BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
  l_report_data_tbl   report_data_tbl_type;
  l_return_status     VARCHAR2(1000);
  l_request_scheduled VARCHAR2(1000);
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version       NUMBER := 1;
  l_debug             VARCHAR2(32000);
  l_perf_measure_id     NUMBER;
  l_time_dim_level_id   NUMBER;
  l_error_Tbl_p       BIS_UTILITIES_PUB.Error_Tbl_Type;

Begin

  -- register main request
  --
  IF p_perf_measure_id IS NOT NULL THEN
    l_perf_measure_id := to_number(p_perf_measure_id);
  END IF;
  IF p_time_dim_level_id IS NOT NULL THEN
    l_time_dim_level_id := to_number(p_time_dim_level_id);
  END IF;

  l_param_set_Rec.PERFORMANCE_MEASURE_ID  := l_perf_measure_id;
  l_param_set_Rec.TIME_DIMENSION_LEVEL_ID := l_time_dim_level_id;
  l_param_set_rec.notify_owner_flag := p_notify_owners_flag;

  BIS_UTILITIES_PUB.put_line(p_text =>'Processing parameter_set. measure id: '||p_perf_measure_id
  ||', time level id: '||p_time_dim_level_id);

  Register_Parameter_set
  ( p_api_version    => l_api_version
  , p_Param_Set_Rec  => l_Param_Set_Rec
  , p_session_id     => p_session_id
  , p_alert_type     => p_alert_type
  , p_request_id     => l_request_id
  , x_return_status  => l_return_status
  , x_error_Tbl      => l_error_Tbl
  );
  --BIS_UTILITIES_PUB.put_line(p_text =>'AFTER register param set: '||l_request_id);

  --p_request_id := p_request_id||l_debug_text;
  p_request_id := l_request_id;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'process_parameter_set exception1: '||sqlerrm);
    p_request_id := l_request_id
     ||' exception 1 in process_parameter_set ';
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id
     ||' exception 2 in process_parameter_set ';
    BIS_UTILITIES_PUB.put_line(p_text =>'process_parameter_set exception2: '||sqlerrm);
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id
     ||' exception 3 in process_parameter_set ';
    BIS_UTILITIES_PUB.put_line(p_text =>'process_parameter_set exception3: '||sqlerrm);
    l_error_tbl_p := l_error_tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => 'Process_Parameter_set'
     , p_error_table       => l_error_tbl_p
     , x_error_table       => l_error_tbl
     );

end process_parameter_set;

--
-- Procedure which insert the needed parameters to the alert
-- registration repository and invoke the submit request procedure
--
PROCEDURE Register_Parameter_Set
( p_api_version     IN  NUMBER
, p_Param_Set_Rec   IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, p_session_id      IN  varchar2   default null
, p_alert_type      IN  varchar2   default null
, p_request_id      OUT NOCOPY varchar2
, x_return_status   OUT NOCOPY VARCHAR2
, x_error_Tbl       OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Conc_exist        BOOLEAN := FALSE;
  l_param_exist       BOOLEAN := FALSE;
  l_request_id        VARCHAR2(32000);
  l_debug             VARCHAR2(32000);
  l_notifiers_code    VARCHAR2(32000);
  l_commit            VARCHAR2(32000)   := FND_API.G_TRUE;
  l_Param_Set_Rec     BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  /*
    BIS_UTILITIES_PUB.put_line(p_text =>'VARSB: registering param set');
    BIS_UTILITIES_PUB.put_line(p_text =>'measure: '||p_param_set_Rec.PERFORMANCE_MEASURE_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'target level: '|| p_param_set_Rec.TARGET_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'time level: '|| p_param_set_Rec.TIME_DIMENSION_LEVEL_ID);
    BIS_UTILITIES_PUB.put_line(p_text =>'notifier: '||p_param_set_Rec.NOTIFIERS_CODE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER1: '|| p_param_set_Rec.PARAMETER1_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text =>'PARAMETER2: '|| p_param_set_Rec.PARAMETER2_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text => p_param_set_Rec.PARAMETER3_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text => p_param_set_Rec.PARAMETER4_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text => p_param_set_Rec.PARAMETER5_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text => p_param_set_Rec.PARAMETER6_VALUE);
    BIS_UTILITIES_PUB.put_line(p_text => p_param_set_Rec.PARAMETER7_VALUE);
  */
  BIS_UTILITIES_PUB.put_line(p_text =>'Registering Parameter set' );

  -- Check whether there is a concurrent program exist for
  -- the given PM and time dimension level id
  --
  l_param_exist
    := BIS_PMF_ALERT_REG_PUB.Parameter_set_Exist
       ( p_api_version    => p_api_version
       , p_Param_Set_Rec  => p_Param_Set_Rec
       , x_notifiers_code => l_notifiers_code
       , x_return_status  => x_return_status
       , x_error_Tbl      => x_error_Tbl
       );

  -- Each row will have it's own adHocRole
  -- l_param_set_rec.notifiers_code := l_notifiers_code;

  --BIS_UTILITIES_PUB.put_line(p_text =>'ARSB: parameter set exist notifier code: '||l_notifiers_code);


  IF l_param_exist THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Request has already been scheduled. Notifier code: '
    ||l_notifiers_code);
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>'Request has not been scheduled. Notifier code: '
    ||l_notifiers_code);
    l_request_id := G_NOTSUBMIT;
  END IF;

  IF NOT l_param_exist THEN
    l_Param_Set_Rec := p_Param_Set_Rec;
    BIS_PMF_ALERT_REG_PUB.Create_Parameter_set
    ( p_api_version    => p_api_version
    , p_commit         => l_commit
    , p_Param_Set_Rec  => l_Param_Set_Rec
    , x_return_status  => x_return_status
    , x_error_Tbl      => x_error_Tbl
    );
    l_debug := l_debug ||'  created parameter set. status: '||x_return_status;
  END IF;

/*
  IF p_alert_type = G_ALL_TARGET THEN
    Add_Subscribers
    ( p_Param_Set_rec => l_Param_Set_rec
    , x_request_id    => l_request_id
    , x_return_status => x_return_status
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Add subscriber status: '||x_return_status);
  END IF;
*/
   p_request_id := l_request_id||l_debug;
  --p_request_id := l_request_id;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_return_status := ' exception 1 in Register_Parameter_Set '||sqlerrm;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := ' exception 2 in Register_Parameter_Set '||sqlerrm;
    BIS_UTILITIES_PUB.put_line(p_text =>'register_parameter_set exception2: '||sqlerrm);
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := ' exception 3 in Register_Parameter_Set '||sqlerrm;
    BIS_UTILITIES_PUB.put_line(p_text =>'register_parameter_set exception3: '||sqlerrm);
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => 'Register_Parameter_Set'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
End Register_Parameter_Set;

PROCEDURE Add_Subscribers
( p_Param_Set_rec  IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_id     OUT NOCOPY varchar2
, x_return_status  OUT NOCOPY varchar2
)
IS

  l_debug             VARCHAR2(32000);
  l_notifiers_code    VARCHAR2(32000);
  l_user_tbl          wf_directory.UserTable;
  l_user              VARCHAR2(32000);
  l_user_exist        BOOLEAN := FALSE;
  l_request_id        VARCHAR2(32000);

BEGIN

  l_user := FND_GLOBAL.USER_NAME;
  BIS_UTILITIES_PUB.put_line(p_text =>'Adding user to subscription list: '||l_user);
  l_debug := l_debug ||' Adding user to subscription list: '||l_user;

  BIS_PMF_ALERT_REG_PVT.Retrieve_Notifiers_Code
  ( p_api_version   => 1.0
  , p_Param_Set_rec => p_Param_Set_rec
  , x_Notifiers_Code => l_Notifiers_Code
  , x_return_status  => x_return_status
  );
  l_debug := l_debug ||' notifier code: '||l_Notifiers_Code;

  IF l_notifiers_code IS NOT NULL THEN
    wf_directory.GetRoleUsers(l_notifiers_code,l_user_tbl);

    BIS_UTILITIES_PUB.put_line(p_text =>'Number of subscribers so far: '||l_user_tbl.COUNT);
    l_debug := l_debug ||' Number of subscribers so far: '||l_user_tbl.COUNT;

    FOR i IN 1..l_user_tbl.COUNT LOOP
      BIS_UTILITIES_PUB.put_line(p_text =>'Subscriber '||i||': '||l_user_tbl(i));
      IF (l_user_tbl(i) = l_user) THEN
        l_user_exist := TRUE;
      END IF;
    END LOOP;

    IF l_user_exist THEN
      l_request_id := G_USER_EXIST;
    ELSE
     -- wf_directory.AddUsersToAdHocRole(l_notifiers_code,l_user);
     wf_local_synch.propagateUserRole(p_role_name => l_notifiers_code, p_user_name => l_user);
      l_request_id
        := BIS_UTILITIES_PVT.Get_FND_Message
        ( p_message_name   => 'BIS_NOTIFIER_ADDED'
        , p_msg_param1     => 'USER_NAME'
        , p_msg_param1_val => l_user
        );
    END IF;
  END IF;

    x_request_id := l_request_id;
  --x_request_id := l_request_id||'--'||l_debug;
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
  WHEN OTHERS THEN
    x_request_id := 'Exception while adding user. '||sqlerrm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Add_Subscribers;

--
-- Retrieve a All Target information for the given performance measure
-- and time dimension level.
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
)
IS

 l_Measure_Rec       BIS_MEASURE_PUB.Measure_Rec_Type;
 l_Target_Level_tbl  BIS_Target_Level_PUB.Target_Level_Tbl_Type;
 l_target_tbl_tmp    BIS_TARGET_PUB.Target_Tbl_type;
 l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
 l_Indicator_Region_Tbl BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;

 l_target_count      NUMBER := 1;
 l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
 l_dimension_level_number NUMBER;
 l_time_level_short_name VARCHAR2(32000);
 l_time_short_name VARCHAR2(32000);
 l_total_time_level_short VARCHAR2(32000);
 l_is_total_time     BOOLEAN := FALSE;
 l_Is_Rolling_Period_Level NUMBER := 0;	-- bug 2408906
 l_target_tbl_tmp_p  BIS_TARGET_PUB.Target_Tbl_type;
 l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_flag  BOOLEAN := FALSE;
 c_num               NUMBER := -9999;
 c_var               VARCHAR2(5) := '-9999';

Begin


  BIS_UTILITIES_PUB.put_line(p_text =>' ***************************************************** ');
  BIS_UTILITIES_PUB.put_line(p_text => ' Start Retrieving target info ' );
  BIS_UTILITIES_PUB.put_line(p_text =>' ***************************************************** ');

  BIS_UTILITIES_PUB.put_line(p_text => ' Retrieving target information ' );
  BIS_UTILITIES_PUB.put_line(p_text => ' Measure id = ' || p_measure_id );
  BIS_UTILITIES_PUB.put_line(p_text => ' Time level id = ' || p_time_dimension_level_id ) ;
  BIS_UTILITIES_PUB.put_line(p_text => ' Is curent time period = '|| p_current_row );

  BIS_UTILITIES_PUB.put_line(p_text => ' --------------------------------------------- ' );

  l_is_total_time  := FALSE;
  l_is_total_time :=  IS_TOTAL_DIM_LEVEL(p_time_dimension_level_id);

  --added to allow RSG call to let thr' for all time levels
  IF (p_time_dimension_level_id IS NOT NULL) THEN
    l_time_level_short_name := BIS_UTILITIES_PVT.GET_TIME_SHORT_NAME(p_time_dimension_level_id);
  END IF;

  l_Is_Rolling_Period_Level := BIS_UTILITIES_PVT.Is_Rolling_Period_Level(	-- bug 2408906
                                    p_level_short_name => l_time_level_short_name );	  -- BIS_UTILITIES_PUB.put_line(p_text =>'Time Level short Name  ' || l_time_level_short_name);
  IF (p_time_dimension_level_id IS NOT NULL) THEN  --added to allow RSG call to let thr' for all time levels
    l_time_short_name :=  BIS_UTILITIES_PVT.Get_Time_Dimension_Name (p_DimLevelId => p_time_dimension_level_id);    -- BIS_UTILITIES_PUB.put_line(p_text =>'Time short Name  ' || l_time_short_name);
    l_total_time_level_short :=  BIS_UTILITIES_PVT.Get_Total_Dimlevel_Name (l_time_short_name , NULL, l_time_level_short_name);    -- BIS_UTILITIES_PUB.put_line(p_text =>'Total Time Level short Name  ' || l_total_time_level_short);
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text => ' --------------------------------------------- ' );

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  l_Measure_Rec.Measure_id  := p_measure_id;
  BIS_TARGET_LEVEL_PVT.Retrieve_Target_Levels
  ( p_api_version       => p_api_version
  , p_all_info          => FND_API.G_FALSE
  , p_Measure_Rec       => l_Measure_Rec
  , x_Target_Level_tbl  => l_Target_Level_tbl
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Number of target levels retrieved for Target INFO: '
  ||l_Target_Level_tbl.COUNT );

  FOR i in 1..l_Target_Level_tbl.COUNT
  LOOP
    BIS_UTILITIES_PUB.put_line(p_text => ' Target level id # ' || i || ' is ' || l_Target_Level_tbl(i).target_level_id );
  END LOOP;


  FOR i in 1..l_Target_Level_tbl.COUNT
  LOOP

    BIS_UTILITIES_PUB.put_line(p_text => ' -------***************************************---------- ' );
    BIS_UTILITIES_PUB.put_line(p_text => ' Start retrieving targets for # ' || i || ' tgt lvl id ' || l_Target_Level_tbl(i).target_level_id) ;

						--    if l_is_total_time = FALSE then
-- In every loop for summary levels under a measure,
-- for summary level id 1793 -> finds dim levels -> finds the dimension level id corresponding to time dimension. (1219)
      BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
      ( p_api_version         => 1.0
      , p_Target_Level_Rec    => l_Target_Level_tbl(i)
      , x_Dimension_Level_Rec => l_Dimension_Level_Rec
      , x_dimension_level_number => l_dimension_level_number
      , x_return_status       => x_return_status
      , x_error_Tbl           => x_error_Tbl
      );

						--   end if;

      BIS_UTILITIES_PUB.put_line(p_text =>' Time level id for # ' || i || ' from target lvls table is ' || l_Dimension_Level_Rec.dimension_level_id);

    -- Filtering only for the time dimension passed as
    -- parameter
    --
						--    IF p_time_dimension_level_id IS NULL -- or l_is_total_time = TRUE
						--    OR l_Dimension_Level_Rec.dimension_level_id = p_time_dimension_level_id
-- Only if the time dimension passed in is null (no time dimension selected while adding dimensions) or
-- summary levels of the measure contains a time dim level which is equal to the time dim level passed in, then
-- continue with using that to spawn child requests.

    IF p_time_dimension_level_id IS NULL or (l_is_total_time = TRUE
     and (BIS_UTILITIES_PUB.Value_Missing(l_Dimension_Level_Rec.dimension_level_id) = FND_API.G_TRUE
       or  BIS_UTILITIES_PUB.Value_NULL(l_Dimension_Level_Rec.dimension_level_id)= FND_API.G_TRUE))
    OR l_Dimension_Level_Rec.dimension_level_id = p_time_dimension_level_id
    THEN

      BIS_UTILITIES_PUB.put_line(p_text => ' --------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-------- ' );
      BIS_UTILITIES_PUB.put_line(p_text => ' Begin Retrieving targets from bis_target_values ' );

      BIS_TARGET_PUB.Retrieve_targets
      ( p_api_version       => p_api_version
      , p_Target_Level_Rec  => l_Target_Level_tbl(i)
      , p_all_info          => FND_API.G_FALSE
      , x_Target_tbl        => l_Target_tbl_tmp
      , x_return_status     => x_return_status
      , x_error_Tbl         => x_error_Tbl
      );

      BIS_UTILITIES_PUB.put_line(p_text => ' End Retrieving targets from bis_target_values ' );
      BIS_UTILITIES_PUB.put_line(p_text => ' Number of targets from targets = '||l_Target_tbl_tmp.COUNT);
      BIS_UTILITIES_PUB.put_line(p_text => ' --------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-------- ' );


      BIS_UTILITIES_PUB.put_line(p_text => ' ---------.............................-------- ' );
      BIS_UTILITIES_PUB.put_line(p_text => ' Begin Retrieving targets from bis_user_ind_selections ' );

      BIS_ACTUAL_PVT.Retrieve_tl_selections
      (   p_Target_Level_Rec     => l_Target_Level_tbl(i)
        , x_Indicator_Region_Tbl => l_Indicator_Region_Tbl
        , x_return_status        => x_return_status
        , x_error_Tbl            => x_error_Tbl
      );

      l_target_count := l_Target_tbl_tmp.COUNT;

      FOR j IN 1..l_Indicator_Region_Tbl.COUNT LOOP
        l_flag := FALSE;
        FOR k IN 1..l_Target_tbl_tmp.COUNT LOOP
          IF ( (NVL(l_Target_tbl_tmp(k).Target_Level_ID, c_num)  = NVL(l_Indicator_Region_Tbl(j).Target_Level_ID, c_num)) AND
                   (NVL(l_Target_tbl_tmp(k).Plan_ID, c_num) = NVL(l_Indicator_Region_Tbl(j).Plan_ID, c_num)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim1_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim1_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim2_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim2_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim3_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim3_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim4_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim4_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim5_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim5_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim6_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim6_Level_Value_ID, c_var)) AND
                   (NVL(l_Target_tbl_tmp(k).Dim7_Level_Value_ID, c_var) = NVL(l_Indicator_Region_Tbl(j).Dim7_Level_Value_ID, c_var))
                 ) THEN
            l_flag := TRUE;
            EXIT;
          END IF;
        END LOOP;
        IF NOT (l_flag) THEN
           l_target_count := l_target_count + 1;
           l_Target_tbl_tmp(l_target_count).Target_Level_ID  :=
             l_Indicator_Region_Tbl(j).Target_Level_ID;
           l_Target_tbl_tmp(l_target_count).Plan_ID  :=
             l_Indicator_Region_Tbl(j).Plan_ID;
           l_Target_tbl_tmp(l_target_count).Dim1_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim1_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim2_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim2_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim3_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim3_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim4_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim4_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim5_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim5_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim6_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim6_Level_Value_ID;
           l_Target_tbl_tmp(l_target_count).Dim7_Level_Value_ID  :=
             l_Indicator_Region_Tbl(j).Dim7_Level_Value_ID;
	   l_Target_tbl_tmp(l_target_count).is_pm_region := BIS_TARGET_PUB.G_IS_PM_REGION; -- indicates it is a PM region entry
        END IF;
      END LOOP;

      BIS_UTILITIES_PUB.put_line(p_text => ' End Retrieving targets from bis_user_ind_selections ' );
      BIS_UTILITIES_PUB.put_line(p_text => ' Number of targets from user ind sel = '|| l_Indicator_Region_Tbl.COUNT );
      BIS_UTILITIES_PUB.put_line(p_text => ' Number of filtered targets from targets = '||l_Target_tbl_tmp.COUNT);
      BIS_UTILITIES_PUB.put_line(p_text => ' ---------.............................-------- ' );

      -- If the alert is to be target based, then the "Change based" alerts should be filtered out and vice-versa
      l_target_tbl_tmp_p := l_target_tbl_tmp;
      filter_alert_based_on(
         p_Target_tbl      => l_Target_tbl_tmp_p
	,p_alert_based_on  => p_alert_based_on
        ,x_target_tbl	   => l_target_tbl_tmp
        ,x_return_status   => x_return_status
      );

      -- get current targets if specified
      --

      -- get current targets if specified
      --
      -- get in if it is not a rolling period or not total time (check) i.e. if the input is a rolling period/total time (check), then don't filter
      --added to allow RSG call to let thr' for all time levels
      IF ( (l_time_level_short_name IS NULL AND l_total_time_level_short IS NULL) OR (    (l_time_level_short_name <> l_total_time_level_short)
           and (l_Is_Rolling_Period_Level = 0))   -- bug 2408906 (dont filter out NOCOPY rolling levels)
         ) THEN

        IF p_current_row = 'Y' THEN
          -- BIS_UTILITIES_PUB.put_line(p_text => ' call to get current target ' ) ;
          l_target_tbl_tmp_p := l_target_tbl_tmp;
	  Get_Current_Target
          ( p_Target_tbl           => l_Target_tbl_tmp_p
          , p_target_level_rec	 => l_target_level_tbl(i)
--	  , p_alert_based_on     => p_alert_based_on
          , x_target_tbl		 => l_target_tbl_tmp
          , x_return_status        => x_return_status
          );
        ELSIF p_current_row = 'N' THEN
          -- BIS_UTILITIES_PUB.put_line(p_text => ' call to get previous target ' ) ;
          l_target_tbl_tmp_p := l_target_tbl_tmp;
          Get_Previous_Target
          ( p_Target_tbl           => l_Target_tbl_tmp_p
          , p_target_level_rec	 => l_target_level_tbl(i)
          , x_target_tbl		 => l_target_tbl_tmp
          , x_return_status        => x_return_status
          );
        ELSE
          BIS_UTILITIES_PUB.put_line(p_text =>'Neither previous or current target!!');
          -- x_target_tbl := l_target_tbl;
        END IF;
      ELSE
        l_target_tbl_tmp_p := l_target_tbl_tmp;
        update_total_time
        ( p_Target_tbl           => l_Target_tbl_tmp_p
        , p_target_level_rec     => l_target_level_tbl(i)
        , x_target_tbl           => l_target_tbl_tmp
        , x_return_status        => x_return_status
        );

      END IF;

      -- Since time dimension level value gets added in get_current_target/get_previous_target for PM region values
      -- it needs to be checked for duplicates again
      l_target_tbl_tmp_p := l_target_tbl_tmp;
      filter_duplicates (
         p_target_tbl => l_target_tbl_tmp_p
        ,x_target_tbl => l_target_tbl_tmp
      );

      BIS_UTILITIES_PUB.put_line(p_text => ' --------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-------- ' );
      BIS_UTILITIES_PUB.put_line(p_text => ' Number of filtered targets from targets = '|| l_Target_tbl_tmp.COUNT);

      FOR j IN 1..l_Target_tbl_tmp.COUNT LOOP
        x_Target_tbl(x_Target_tbl.COUNT+1) := l_Target_tbl_tmp(j);
      END LOOP;

      BIS_UTILITIES_PUB.put_line(p_text =>' Total number of filtered targets retrieved for this time level SO FAR.. = ' || x_target_tbl.count);
      BIS_UTILITIES_PUB.put_line(p_text => ' --------~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-------- ' );

   END IF;

  END LOOP;
  --x_target_tbl := l_target_tbl;
  BIS_UTILITIES_PUB.put_line(p_text =>' Final number of targets retrieved ' || x_target_tbl.count);

  BIS_UTILITIES_PUB.put_line(p_text =>' ***************************************************** ');
  BIS_UTILITIES_PUB.put_line(p_text => ' Finish Retrieving target info ' );
  BIS_UTILITIES_PUB.put_line(p_text =>' ***************************************************** ');

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 at Retrieve_target_info: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 at Retrieve_target_info: '||sqlerrm);
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 at Retrieve_target_info: '||sqlerrm);
    l_error_tbl := x_error_tbl;
		BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_target_info'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

End Retrieve_target_info;

-- Since time dimension level value gets added in get_current_target/get_previous_target for PM region values
-- it needs to be checked for duplicates again

PROCEDURE filter_duplicates (
  p_target_tbl IN BIS_TARGET_PUB.target_tbl_type
 ,x_target_tbl OUT NOCOPY BIS_TARGET_PUB.target_tbl_type
)
IS
  l_found BOOLEAN := FALSE;
  l_count NUMBER := 0;
  c_var VARCHAR2(10) := '-99999999'; -- dummy variable.
  c_num NUMBER := -9999;
BEGIN

  FOR i IN p_target_tbl.FIRST .. p_target_tbl.LAST LOOP
    l_found := FALSE;
    FOR j IN i+1 .. p_target_tbl.LAST LOOP

      IF ( (NVL(p_target_tbl(i).Target_Level_ID, c_num)  = NVL(p_target_tbl(j).Target_Level_ID, c_num)) AND
           (NVL(p_target_tbl(i).Plan_ID, c_num) = NVL(p_target_tbl(j).Plan_ID, c_num)) AND
           (NVL(p_target_tbl(i).Dim1_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim1_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim2_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim2_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim3_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim3_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim4_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim4_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim5_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim5_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim6_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim6_Level_Value_ID, c_var)) AND
           (NVL(p_target_tbl(i).Dim7_Level_Value_ID, c_var) = NVL(p_target_tbl(j).Dim7_Level_Value_ID, c_var))
        ) THEN
        l_found := TRUE;
        EXIT;
      END IF;
    END LOOP;

    IF (NOT l_found) THEN
      l_count := x_target_tbl.COUNT + 1;
      x_target_tbl(l_count) := p_target_tbl(i);
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;

-- If the alert is to be target based, then the "Change based" alerts should be filtered out
-- and vice-versa, since the input table to this method contains all the targets set (change/target based) for a measure.
--
PROCEDURE filter_alert_based_on (
   p_target_tbl     IN BIS_TARGET_PUB.target_tbl_type
  ,p_alert_based_on IN VARCHAR2
  ,x_target_tbl	    OUT NOCOPY BIS_TARGET_PUB.target_tbl_type
  ,x_return_status  OUT NOCOPY VARCHAR2
)
IS
  l_count NUMBER := 0;
BEGIN

  FOR i IN p_target_tbl.FIRST .. p_target_tbl.LAST LOOP
    IF (p_target_tbl(i).is_pm_region = BIS_TARGET_PUB.G_IS_PM_REGION) THEN
      l_count := x_target_tbl.COUNT + 1;
      x_target_tbl(l_count) := p_target_tbl(i);
    ELSIF ( (p_alert_based_on = BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET) AND (p_target_tbl(i).target IS NOT NULL) ) THEN
      l_count := x_target_tbl.COUNT + 1;
      x_target_tbl(l_count) := p_target_tbl(i);
    ELSIF ( (p_alert_based_on = BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_CHANGE) AND (p_target_tbl(i).target IS NULL) ) THEN
      l_count := x_target_tbl.COUNT + 1;
      x_target_tbl(l_count) := p_target_tbl(i);
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END filter_alert_based_on;


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
)
IS

 l_Target_Level_rec  BIS_Target_Level_PUB.Target_Level_rec_Type;
 l_target_tbl_tmp    BIS_TARGET_PUB.Target_Tbl_type;
 l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
 l_target_count      NUMBER := 0;
 l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
 l_dimension_level_number NUMBER;
 l_current_row       VARCHAR2(10);
 l_Target_Level_rec_p  BIS_Target_Level_PUB.Target_Level_rec_Type;
 l_error_tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_Target_tbl_tmp_p    BIS_TARGET_PUB.Target_Tbl_type;
Begin

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving target information 0002.'
  ||' , target level id: '||p_target_level_id
  ||', Curent row? '||p_current_row);

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  l_Target_Level_Rec.Target_Level_id  := p_Target_Level_id;
  l_Target_Level_rec_p := l_Target_Level_rec;
  BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
  ( p_api_version       => p_api_version
  , p_all_info          => FND_API.G_FALSE
  , p_Target_Level_rec  => l_Target_Level_rec_p
  , x_Target_Level_rec  => l_Target_Level_rec
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Target level retrieved for Target INFO 2: '
  ||l_Target_Level_rec.Target_Level_short_name );

  BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'time level id for target level: '
  ||l_Dimension_Level_Rec.dimension_level_id);

  -- Filtering only for the time dimension passed as
  -- parameter
  --
  IF p_time_dimension_level_id IS NULL
  OR l_Dimension_Level_Rec.dimension_level_id = p_time_dimension_level_id
  THEN

    BIS_TARGET_PUB.Retrieve_targets
    ( p_api_version       => p_api_version
    , p_Target_Level_Rec  => l_Target_Level_rec
    , p_all_info          => FND_API.G_FALSE
    , x_Target_tbl        => l_Target_tbl_tmp
    , x_return_status     => x_return_status
    , x_error_Tbl         => x_error_Tbl
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'retriving target information for target level 2: '
    ||l_Target_Level_rec.target_level_short_name
    ||'.  Number of targets ALL: '||l_Target_tbl_tmp.COUNT);

    -- Since there is no option to choose previous or current period
    -- when scheduling alerts from a report, we assume Previous.
    --
    l_current_row := 'N';

    -- get current targets if specified.  this is a BIG
    -- performance bottleneck.
    --
    IF l_current_row = 'Y' THEN
      l_Target_tbl_tmp_p := l_Target_tbl_tmp;
      Get_Current_Target
      ( p_Target_tbl           => l_Target_tbl_tmp_p
      , p_target_level_rec     => l_target_level_rec
--      , p_alert_based_on       => p_alert_based_on
      , x_target_tbl	       => l_target_tbl_tmp
      , x_return_status        => x_return_status
      );
    ELSIF l_current_row = 'N' THEN
      l_Target_tbl_tmp_p := l_Target_tbl_tmp;
      Get_Previous_Target
      ( p_Target_tbl           => l_Target_tbl_tmp_p
      , p_target_level_rec     => l_target_level_rec
      , x_target_tbl	       => l_target_tbl_tmp
      , x_return_status        => x_return_status
      );
    ELSE
      BIS_UTILITIES_PUB.put_line(p_text =>'neither previous or current target!!');

    END IF;

    FOR j IN 1..l_Target_tbl_tmp.COUNT LOOP
      x_Target_tbl(x_Target_tbl.COUNT+1) := l_Target_tbl_tmp(j);
    END LOOP;

    l_Target_tbl_tmp.delete;

  END IF;

  --x_target_tbl := l_target_tbl;
  BIS_UTILITIES_PUB.put_line(p_text =>'!!Number of targets retrieved: '||x_target_tbl.count);

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 at Retrieve_target_info: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 at Retrieve_target_info: '||sqlerrm);
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 at Retrieve_target_info: '||sqlerrm);
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_target_info'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

End Retrieve_target_info;


Procedure Get_Previous_Target
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS

 l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
 l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
 l_dimension_level_number   NUMBER;
 l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_time_id            VARCHAR2(80);
 l_target_count       NUMBER := 1;
 l_Org_Level_Value_ID VARCHAR2(40);
 l_Org_Short_Name     VARCHAR2(80);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --l_target_tbl := x_target_tbl ;

  FOR j in 1..p_Target_tbl.COUNT
  LOOP

    BIS_UTILITIES_PUB.put_line(p_text =>' --------  Target # ' || j || ' ---------- ' );

    BIS_TARGET_PVT.Retrieve_Org_level_value
    ( p_api_version          => 1.0
    , p_Target_Rec           => p_Target_tbl(j)
    , x_Dim_Level_value_Rec  => l_Dim_Level_value_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status        => x_return_status
    , x_error_Tbl            => l_error_Tbl
    );

    l_Org_Level_Value_ID := l_Dim_Level_value_Rec.Dimension_Level_Value_ID;
    l_Org_Short_Name := l_Dim_Level_value_Rec.Dimension_Level_Short_Name;

     /*
    if (
        (BIS_UTILITIES_PUB.Value_Not_Missing( l_Org_Level_Value_ID ) = FND_API.G_TRUE)
        and (BIS_UTILITIES_PUB.Value_Not_Null( l_Org_Level_Value_ID ) = FND_API.G_TRUE)
       )
    then
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level value id for prev tgt is: ' || l_Org_Level_Value_ID);
    else
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level value id is prev tgt null/missing ' );
    end if;

    if (
        (BIS_UTILITIES_PUB.Value_Not_Missing( l_Org_Short_Name ) = FND_API.G_TRUE)
        and (BIS_UTILITIES_PUB.Value_Not_Null( l_Org_Short_Name ) = FND_API.G_TRUE)
       )
    then
      BIS_UTILITIES_PUB.put_line(p_text =>' Org short name is prev tgt: ' || l_Org_Short_Name );
    else
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level short name is prev tgt null/missing ' );
    end if;
    */


    BIS_TARGET_PVT.Retrieve_Time_level_value
    ( p_api_version          => 1.0
    , p_Target_Rec           => p_Target_tbl(j)
    , x_Dim_Level_value_Rec => l_Dim_Level_value_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status        => x_return_status
    , x_error_Tbl            => l_error_Tbl
    );

    -- BIS_UTILITIES_PUB.put_line(p_text =>' Time Level dimension sequence no : ' || l_dimension_level_number);

    IF BIS_DIM_LEVEL_VALUE_PVT.Is_Previous_Time_Period
			             (  l_Dim_Level_Value_Rec
                                      , l_Org_Level_Value_ID
                                      , l_Org_Short_Name
				      , l_time_id)
    THEN
      /*
      BIS_UTILITIES_PUB.put_line(p_text => ' This time level value is PREVIOUS time period ' ) ;
      BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved previous period: '
      ||l_Dim_Level_Value_Rec.Dimension_Level_value_id );
      */

      l_target_tbl(l_target_tbl.COUNT+1) := p_target_tbl(j);
    ELSIF (p_target_tbl(j).is_pm_region = BIS_TARGET_PUB.G_IS_PM_REGION) THEN -- see Get_Current_Target

      -- BIS_UTILITIES_PUB.put_line(p_text => ' BISVARSB: this time level value is NOT PREVIOUS time period ' ) ;

      if BIS_UTILITIES_PUB.Value_Missing(p_Target_tbl(j).target) = FND_API.G_TRUE
       or  BIS_UTILITIES_PUB.Value_NULL(p_Target_tbl(j).target)= FND_API.G_TRUE
      then
          l_target_count := l_target_tbl.COUNT+1;

          l_target_tbl(l_target_count) := p_target_tbl(j);

          if l_dimension_level_number = 1 then
            l_target_tbl(l_target_count).Dim1_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 2 then
            l_target_tbl(l_target_count).Dim2_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 3 then
            l_target_tbl(l_target_count).Dim3_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 4 then
            l_target_tbl(l_target_count).Dim4_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 5 then
            l_target_tbl(l_target_count).Dim5_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 6 then
            l_target_tbl(l_target_count).Dim6_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 7 then
            l_target_tbl(l_target_count).Dim7_Level_Value_ID
                               :=  l_time_id;
          end if;

        BIS_UTILITIES_PUB.put_line(p_text =>'Time Level Replaced with the Previous Level');

      -- else
        -- null;
        -- BIS_UTILITIES_PUB.put_line(p_text =>'Failed to retrieve previous period: '  ||l_Dim_Level_value_Rec.Dimension_Level_value_id);
      end if;

    END IF;
  END LOOP;

  x_target_tbl := l_target_tbl ;

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Get_previous_Target: '||sqlerrm);

END Get_Previous_Target;



Procedure Get_Current_Target
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
--, p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS

 l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
 l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
 l_dimension_level_number   NUMBER;
 l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_time_id            VARCHAR2(80);
 l_target_count       NUMBER := 1;
 l_Org_Level_Value_ID VARCHAR2(40);-- := '204';
 l_Org_Short_Name     VARCHAR2(80);


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --l_target_tbl := x_target_tbl ;
  --BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving current target.');

  FOR j in 1..p_Target_tbl.COUNT
  LOOP

    BIS_UTILITIES_PUB.put_line(p_text =>' --------  Target # ' || j || ' ---------- ' );

    BIS_TARGET_PVT.Retrieve_Org_level_value
    ( p_api_version          => 1.0
    , p_Target_Rec           => p_Target_tbl(j)
    , x_Dim_Level_value_Rec  => l_Dim_Level_value_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status        => x_return_status
    , x_error_Tbl            => l_error_Tbl
    );


    l_Org_Level_Value_ID := l_Dim_Level_value_Rec.Dimension_Level_Value_ID;
    l_Org_Short_Name := l_Dim_Level_value_Rec.Dimension_Level_Short_Name;

    /*
    if (
        (BIS_UTILITIES_PUB.Value_Not_Missing( l_Org_Level_Value_ID ) = FND_API.G_TRUE)
        and (BIS_UTILITIES_PUB.Value_Not_Null( l_Org_Level_Value_ID ) = FND_API.G_TRUE)
       )
    then
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level value id current target is: ' || l_Org_Level_Value_ID);
    else
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level value id is current target null/missing ' );
    end if;

    if (
        (BIS_UTILITIES_PUB.Value_Not_Missing( l_Org_Short_Name ) = FND_API.G_TRUE)
        and (BIS_UTILITIES_PUB.Value_Not_Null( l_Org_Short_Name ) = FND_API.G_TRUE)
       )
    then
      BIS_UTILITIES_PUB.put_line(p_text =>' Org short name is current target : ' || l_Org_Short_Name );
    else
      BIS_UTILITIES_PUB.put_line(p_text =>' Org level short name is current target  null/missing ' );
    end if;
    */


    BIS_TARGET_PVT.Retrieve_Time_level_value
    ( p_api_version          => 1.0
    , p_Target_Rec           => p_Target_tbl(j)
    , x_Dim_Level_value_Rec  => l_Dim_Level_value_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status        => x_return_status
    , x_error_Tbl            => l_error_Tbl
    );
    -- BIS_UTILITIES_PUB.put_line(p_text =>' Time Level value no : ' || l_dimension_level_number);

    IF BIS_DIM_LEVEL_VALUE_PVT.Is_Current_Time_Period
                               (  l_Dim_Level_Value_Rec
                                , l_Org_Level_Value_ID
                                , l_Org_Short_Name
				, l_time_id)
    THEN
      /*
      BIS_UTILITIES_PUB.put_line(p_text => ' This time period is in current period ' ) ;

      BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved current period: '
      ||l_Dim_Level_Value_Rec.Dimension_Level_value_id );
      */

      l_target_tbl(l_target_tbl.COUNT+1) := p_target_tbl(j);

    -- The condition below, with targets missing, to be used to identify pm region entries will not be satisfied
    -- for "set targets" anymore after change based alerting (bug# 3148615) since change does not have targets-only tolerance
    ELSIF (p_target_tbl(j).is_pm_region = BIS_TARGET_PUB.G_IS_PM_REGION) THEN

      -- BIS_UTILITIES_PUB.put_line(p_text => ' This time period is not in current period ' ) ;

      -- Following step is for the records retrieved
      -- from user_ind_selection table

      if BIS_UTILITIES_PUB.Value_Missing(p_Target_tbl(j).target) = FND_API.G_TRUE
       or  BIS_UTILITIES_PUB.Value_NULL(p_Target_tbl(j).target)= FND_API.G_TRUE
      then
          l_target_count := l_target_tbl.COUNT+1;

          l_target_tbl(l_target_count) := p_target_tbl(j);

          if l_dimension_level_number = 1 then
            l_target_tbl(l_target_count).Dim1_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 2 then
            l_target_tbl(l_target_count).Dim2_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 3 then
            l_target_tbl(l_target_count).Dim3_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 4 then
            l_target_tbl(l_target_count).Dim4_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 5 then
            l_target_tbl(l_target_count).Dim5_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 6 then
            l_target_tbl(l_target_count).Dim6_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 7 then
            l_target_tbl(l_target_count).Dim7_Level_Value_ID
                               :=  l_time_id;
          end if;

        BIS_UTILITIES_PUB.put_line(p_text =>'Dim 6 Value ' || l_target_tbl(l_target_count).Dim6_Level_Value_ID);

        BIS_UTILITIES_PUB.put_line(p_text =>'Time Level Replaced with the Current Level');

      -- else
        -- null;
        -- BIS_UTILITIES_PUB.put_line(p_text =>'Failed to retrieve current period: '  ||l_Dim_Level_value_Rec.Dimension_Level_value_id);
      end if;

    END IF;
  END LOOP;

  x_target_tbl := l_target_tbl ;

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Get_current_Target: '||sqlerrm);

END Get_current_Target;



Procedure update_total_time
( p_Target_tbl           IN BIS_TARGET_PUB.Target_Tbl_type
, p_target_level_rec     IN BIS_Target_Level_PUB.Target_Level_rec_Type
--, p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_target_tbl           IN OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS

 l_target_tbl        BIS_TARGET_PUB.Target_Tbl_type;
 l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
 l_dimension_level_number   NUMBER;
 l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
 l_time_id            VARCHAR2(80);
 l_target_count       NUMBER := 1;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --l_target_tbl := x_target_tbl ;
  BIS_UTILITIES_PUB.put_line(p_text =>'Total Record in  ' || p_Target_tbl.count);

  FOR j in 1..p_Target_tbl.COUNT
  LOOP

    BIS_TARGET_PVT.Retrieve_Time_level_value
    ( p_api_version          => 1.0
    , p_Target_Rec           => p_Target_tbl(j)
    , x_Dim_Level_value_Rec => l_Dim_Level_value_Rec
    , x_dimension_level_number => l_dimension_level_number
    , x_return_status        => x_return_status
    , x_error_Tbl            => l_error_Tbl
    );

  BIS_UTILITIES_PUB.put_line(p_text =>'L Total Time Level value no : ' || l_dimension_level_number);
   if substr(l_Dim_Level_Value_Rec.Dimension_Level_short_name,1,3) = 'EDW' then
      l_time_id := 1;
      BIS_UTILITIES_PUB.put_line(p_text =>'EDW Total Time ');
   else
      l_time_id := -1;
      BIS_UTILITIES_PUB.put_line(p_text =>'OLTP Total Time ');
   end if;
    -- Explained in Get_Current_Target() above.
    IF ( (p_Target_tbl(j).is_pm_region = BIS_TARGET_PUB.G_IS_PM_REGION) AND
        ((BIS_UTILITIES_PUB.Value_Missing(p_Target_tbl(j).target) = FND_API.G_TRUE) OR (BIS_UTILITIES_PUB.Value_NULL(p_Target_tbl(j).target)= FND_API.G_TRUE)) ) THEN

          l_target_count := l_target_tbl.COUNT+1;

          l_target_tbl(l_target_count) := p_target_tbl(j);

          if l_dimension_level_number = 1 then
            l_target_tbl(l_target_count).Dim1_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 2 then
            l_target_tbl(l_target_count).Dim2_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 3 then
            l_target_tbl(l_target_count).Dim3_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 4 then
            l_target_tbl(l_target_count).Dim4_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 5 then
            l_target_tbl(l_target_count).Dim5_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 6 then
            l_target_tbl(l_target_count).Dim6_Level_Value_ID
                               :=  l_time_id;
          elsif l_dimension_level_number = 7 then
            l_target_tbl(l_target_count).Dim7_Level_Value_ID
                               :=  l_time_id;
          end if;

        BIS_UTILITIES_PUB.put_line(p_text =>'Dim 6 Value ' || l_target_tbl(l_target_count).Dim6_Level_Value_ID);
        BIS_UTILITIES_PUB.put_line(p_text =>'Time Level Replaced with the Current Level');

    ELSE
          l_target_count := l_target_tbl.COUNT+1;
          l_target_tbl(l_target_count) := p_target_tbl(j);

    END IF;
  END LOOP;

  x_target_tbl := l_target_tbl ;

  BIS_UTILITIES_PUB.put_line(p_text =>'Total Record out NOCOPY  ' || x_Target_tbl.count);

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Get_current_Target: '||sqlerrm);

END update_total_time;

--
-- Obsolete
--
-- Following procedure to retrieve the repeating interval for
-- the concurrent request need to be changed. This is temparory till
-- we put the repeating interval option in the Alert registration
-- Page.
--
PROCEDURE get_repeating_interval
( p_time_dimension_level_id   IN  varchar2
, x_repeat_interval           OUT NOCOPY NUMBER
, x_repeat_unit               OUT NOCOPY varchar2
)
IS
   l_view_name  varchar2(100);
   l_start_date date;
   l_end_date   date;
   l_sql_stmnt  varchar2(32000);
   type c1_cursor is ref cursor;
   c1           c1_cursor;

BEGIN

    select LEVEL_VALUES_VIEW_NAME
    into l_view_name
    from bisbv_dimension_levels
    where DIMENSION_LEVEL_ID = p_time_dimension_level_id;

    l_sql_stmnt := 'select distinct start_date, end_date from '
    || l_view_name
    ||'  where sysdate between nvl(start_date,sysdate) '
    ||'  and nvl(end_date,sysdate) ';

    open c1 for l_sql_stmnt;
    fetch c1 into l_start_date, l_end_date;
    if last_day(sysdate) = l_end_date
    and last_day(add_months(sysdate,-1)) + 1 = l_start_date
    then
        x_repeat_interval := 1;
        x_repeat_unit := 'MONTHS';
    elsif  round(months_between(l_end_date,l_start_date),1) = 3
    then
        x_repeat_interval := 3;
        x_repeat_unit := 'MONTHS';
    elsif  round(months_between(l_end_date,l_start_date),1) = 12
    then
        x_repeat_interval := 12;
        x_repeat_unit := 'MONTHS';
    else
        x_repeat_interval := l_end_date - l_start_date;
        x_repeat_unit := 'DAYS';
    end if;

EXCEPTION
  WHEN OTHERS THEN
     x_repeat_interval := 0;
     x_repeat_unit :=  SQLERRM;

END get_repeating_interval;

--
-- Helper routin which calls fnd_request APIs
-- For scheduled alerts
--
PROCEDURE submit_conc_request
( p_request_id                OUT NOCOPY varchar2
, p_StartTime                 IN  varchar2   default null
, p_EndTime                   IN  varchar2   default null
, p_frequencyInterval         IN  varchar2   default null
, p_frequencyUnits            IN  varchar2   default null
, p_performance_measure_id    IN  NUMBER     default null
, p_time_dimension_level_id   IN  NUMBER     default null
, p_session_id                IN  varchar2   default null
, p_current_row               IN  varchar2   default null
, p_alert_type                IN  varchar2   default null
, p_alert_based_on            IN  VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
)
IS
  l_request_id VARCHAR2(32000);
  l_repeat_result  VARCHAR2(32000);
  l_submit_result       varchar2(32000);
  l_request_desc        varchar2(32000);
  l_measure_rec         BIS_MEASURE_PUB.measure_rec_type;
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_return_status     VARCHAR2(1000);
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version       NUMBER := 1;
  l_Concurrent_Request_rec BIS_CONCURRENT_MANAGER_PVT.PMF_Request_rec_Type;
  ERRBUF              VARCHAR2(32000);
  RETCODE             VARCHAR2(32000);
  l_error_Tbl_p       BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec_p     BIS_MEASURE_PUB.measure_rec_type;
  l_dimension_level_rec_p BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;

begin

  BIS_UTILITIES_PUB.put_line(p_text =>'Submitting detailed concurrent request');
  BIS_UTILITIES_PUB.put_line(p_text =>'alert type: '||p_alert_type);
  l_debug_text := p_request_id||l_request_id;

  l_measure_rec.measure_id := p_performance_measure_id;
  l_measure_rec_p := l_measure_rec;
	BIS_MEASURE_PUB.Retrieve_Measure
  ( p_api_version   => l_api_version
  , p_measure_rec   => l_measure_rec_p
  , p_all_info      => FND_API.G_FALSE
  , x_Measure_rec   => l_measure_rec
  , x_return_status => l_return_status
  , x_error_Tbl     => l_error_tbl
  );

  l_debug_text:= l_debug_text||' retrieve measure: '||l_return_status
                 ||', short name: '||l_measure_rec.measure_short_Name;


  l_dimension_level_rec.dimension_level_id := p_time_dimension_level_id ;
  l_dimension_level_rec_p := l_dimension_level_rec;
	BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_dimension_Level_Rec => l_dimension_level_rec_p
  , x_dimension_Level_rec => l_dimension_level_rec
  , x_return_status       => l_return_status
  , x_error_tbl           => l_error_tbl
  );
  l_debug_text:= l_debug_text||' retrieve dimension level: '||l_return_status
                 ||', short name: '
                 ||l_dimension_level_rec.dimension_level_short_Name;


  /*  Obsoleted.

  -- Following procedure to retrieve the repeating interval for
  -- the concurrent request need to be changed. This is temparory till
  -- we put the repeating interval option in the Alert registration
  -- Page.
  get_repeating_interval( p_time_dimension_level_id
                        , l_repeat_interval
                        , l_repeat_unit);
  */

  BIS_CONCURRENT_MANAGER_PVT.Set_Repeat_Options
  ( p_repeat_interval   => p_frequencyInterval
  , p_repeat_units      => p_frequencyUnits
  , P_Start_time        => p_StartTime
  , P_end_time          => p_EndTime
  , x_result            => l_repeat_result
  );
  commit;
  BIS_UTILITIES_PUB.put_line(p_text =>'Setting repeat result: '||l_repeat_result);
  l_debug_text:= l_debug_text||' Setting repeat result: '||l_repeat_result;

  l_request_desc
    := BIS_UTILITIES_PVT.Get_FND_Message
       ( p_message_name   => G_ALERT_CONC_REQ_NAME
       , p_msg_param1     => 'MEASURE_NAME'
       , p_msg_param1_val => l_measure_rec.MEASURE_NAME
       , p_msg_param2     => 'TIME_LEVEL'
       , p_msg_param2_val => l_dimension_level_rec.Dimension_Level_Name
       );

  Form_Concurrent_Request
  ( p_request_desc            => l_request_desc
  , p_Start_Time              => p_startTime
  , p_measure_id              => l_measure_rec.measure_id
  , p_Measure_short_name      => l_measure_rec.measure_short_name
  , p_time_level_id           => l_dimension_level_rec.Dimension_Level_id
  , p_alert_type              => p_alert_type
  , p_current_row             => p_current_row
  , p_alert_based_on          => p_alert_based_on
  , x_Concurrent_Request_rec  => l_Concurrent_Request_rec
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Submit concurrent requests for Detail Alert Service');
  --
  BIS_CONCURRENT_MANAGER_PVT.Submit_Concurrent_Request
  ( p_Concurrent_Request_rec => l_Concurrent_Request_rec
  , x_request_id             => l_request_id
  , x_errbuf                 => ERRBUF
  , x_retcode                => RETCODE
  );
  l_debug_text:= l_debug_text||' Submit concurrent requests result: '
                 ||ERRBUF||', code: '||RETCODE;

  IF ((l_request_id = 0) OR (l_request_id IS NULL)) THEN -- 2568688
    l_submit_result := BIS_UTILITIES_PVT.Get_FND_Message
                      ( p_message_name => G_FAILED_MSG)
					  || ' ' || ERRBUF ;
  ELSE
    l_submit_result := BIS_UTILITIES_PVT.Get_FND_Message
                      ( p_message_name   => G_SUCCESS_MSG
                      , p_msg_param1     => G_REQUEST_ID_TOK
                      , p_msg_param1_val => l_request_id
                      );
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text =>'Submission result: '||l_submit_result);
  --p_request_id := l_submit_result||'--submit_conc_request debug--'
  --||l_request_id ||' -- debug -- '||l_debug_text;

  p_request_id := l_submit_result;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    l_return_status := FND_API.G_RET_STS_ERROR ;
    p_request_id := l_request_id
      ||' exception 1 in submit_conc_request '||sqlerrm;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id
      ||' exception 2 in submit_conc_request '||sqlerrm;
  when others then
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    p_request_id := l_request_id
      ||' exception 3 in submit_conc_request '||sqlerrm;
     l_error_tbl_p := l_error_tbl;
		 BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => 'submit_conc_request'
     , p_error_table       => l_error_tbl_p
     , x_error_table       => l_error_tbl
     );

end submit_conc_request;

--
-- Helper routin which calls fnd_request APIs
-- For scheduled alerts
--
PROCEDURE submit_Concurrent_Request
( p_report_data_Tbl         IN   report_data_tbl_type
 ,p_performance_measure_id  IN      NUMBER   default null
 ,p_time_dimension_level_id IN      NUMBER   default null
 ,p_session_id              IN  varchar2   default null
 ,p_StartTime               IN  varchar2   default null
 ,p_EndTime                 IN  varchar2   default null
 ,p_frequencyInterval       IN  varchar2   default null
 ,p_frequencyUnits          IN  varchar2   default null
 ,p_current_row          IN  varchar2   default null
, x_request_id              OUT NOCOPY  VARCHAR2
)
IS

  l_request_id VARCHAR2(2000);
  l_result  BOOLEAN;
  l_request_desc        varchar2(32000);
  l_user_name           VARCHAR2(32000);
  l_measure_rec         BIS_MEASURE_PUB.measure_rec_type;
  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_return_status     VARCHAR2(1000);
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version       NUMBER := 1;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'submitting report data concurrent request');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 in submit_Concurrent_Request');
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 in submit_Concurrent_Request');
   when others then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 submit_Concurrent_Request: '||sqlerrm);

END submit_Concurrent_Request;

PROCEDURE Retrieve_Report_Info
( p_measure_id           IN  NUMBER
, p_time_level_id        IN  NUMBER     default null
, p_plan_id              IN  NUMBER     default null
, p_parameter1_level     IN  varchar2   default null
, p_parameter1_value     IN  varchar2   default null
, p_parameter2_level     IN  varchar2   default null
, p_parameter2_value     IN  varchar2   default null
, p_parameter3_level     IN  varchar2   default null
, p_parameter3_value     IN  varchar2   default null
, p_parameter4_level     IN  varchar2   default null
, p_parameter4_value     IN  varchar2   default null
, p_parameter5_level     IN  varchar2   default null
, p_parameter5_value     IN  varchar2   default null
, p_parameter6_level     IN  varchar2   default null
, p_parameter6_value     IN  varchar2   default null
, p_parameter7_level     IN  varchar2   default null
, p_parameter7_value     IN  varchar2   default null
, p_viewby_level_id      IN  varchar2   default null
, x_target_level_tbl     OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_type
, x_target_tbl           OUT NOCOPY BIS_TARGET_PUB.Target_Tbl_type
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Measure_Rec          BIS_MEASURE_PUB.Measure_Rec_Type;
  l_Target_Level_tbl     BIS_Target_Level_PUB.Target_Level_Tbl_Type;
  l_Target_Level_rec     BIS_Target_Level_PUB.Target_Level_rec_Type;
  l_Target_Level_tbl_tmp BIS_Target_Level_PUB.Target_Level_Tbl_Type;
  l_target_tbl           BIS_TARGET_PUB.Target_Tbl_type;
  l_target_rec           BIS_TARGET_PUB.Target_rec_type;
  l_target_tbl_tmp       BIS_TARGET_PUB.Target_Tbl_type;
  l_return_status        VARCHAR2(32000);
  l_error_Tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_param_set_tbl        BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'retrieving report info');

  l_Measure_Rec.Measure_id  := p_measure_id;

  BIS_TARGET_LEVEL_PVT.Retrieve_Target_Levels
  ( p_api_version       => 1.0
  , p_all_info          => FND_API.G_FALSE
  , p_Measure_Rec       => l_Measure_Rec
  , x_Target_Level_tbl  => l_Target_Level_tbl_tmp
  , x_return_status     => l_return_status
  , x_error_Tbl         => l_error_Tbl
  );
  BIS_UTILITIES_PUB.put_line(p_text =>'Number of target levels retrieved TOTAL: '
  ||l_Target_Level_tbl_tmp.COUNT );

  -- Get all target levels with these dimension levels
  -- and this viewBy level
  --
  FOR i in 1..l_Target_Level_tbl_tmp.COUNT LOOP
    BIS_UTILITIES_PUB.put_line(p_text =>' l_Target_Level_tbl_TMP! target_level id: '
    ||l_Target_Level_tbl_tmp(i).Target_level_id);
    Verify_Target_Level
    ( p_Target_Level_rec   => l_Target_Level_tbl_tmp(i)
    , p_parameter1_level   => p_parameter1_level
    , p_parameter2_level   => p_parameter2_level
    , p_parameter3_level   => p_parameter3_level
    , p_parameter4_level   => p_parameter4_level
    , p_parameter5_level   => p_parameter5_level
    , p_parameter6_level   => p_parameter6_level
    , p_parameter7_level   => p_parameter7_level
    , p_viewby_level_id    => p_viewby_level_id
    , x_Target_Level_rec   => l_Target_Level_rec
    );

    IF BIS_UTILITIES_PUB.Value_NOT_Missing(l_Target_Level_rec.Target_Level_ID)
      = FND_API.G_TRUE
    AND BIS_UTILITIES_PUB.Value_NOT_Null(l_Target_Level_rec.Target_Level_ID)
      = FND_API.G_TRUE
    THEN
      l_Target_Level_tbl(l_Target_Level_tbl.COUNT+1) := l_Target_Level_rec;
      BIS_UTILITIES_PUB.put_line(p_text =>'Verified target level: '
      ||l_Target_Level_tbl(l_Target_Level_tbl.COUNT).Target_level_id);
    END IF;

  END LOOP;
  BIS_UTILITIES_PUB.put_line(p_text =>'Number of target levels retrieved for Report INFO: '
  ||l_Target_Level_tbl.COUNT );

  -- Get all targets, then filter out NOCOPY only targets with passed in
  -- dimension level values
  --
  FOR i in 1..l_Target_Level_tbl.COUNT LOOP

    BIS_UTILITIES_PUB.put_line(p_text =>'Getting targets for target level: '
    ||l_target_level_tbl(i).target_level_id);

    Retrieve_target_info
    ( p_api_version    => 1.0
    , p_target_level_id => l_target_level_tbl(i).target_level_id
    , p_time_dimension_level_id => NULL
    , p_current_row    => 'Y'
    , x_target_tbl     => l_target_tbl_tmp
    , x_return_status  => l_return_status
    , x_error_Tbl      => l_error_Tbl
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Number of Target retrieved TOTAL: '||l_Target_tbl_tmp.COUNT );

    FOR j in 1..l_Target_tbl_tmp.COUNT  LOOP
      BIS_UTILITIES_PUB.put_line(p_text =>'target for target level: '||l_Target_tbl_tmp(j).target_level_id);
      Verify_Target
      ( p_Target_rec         => l_Target_tbl_tmp(j)
      , p_parameter1_Value   => p_parameter1_Value
      , p_parameter2_Value   => p_parameter2_Value
      , p_parameter3_Value   => p_parameter3_Value
      , p_parameter4_Value   => p_parameter4_Value
      , p_parameter5_Value   => p_parameter5_Value
      , p_parameter6_Value   => p_parameter6_Value
      , p_parameter7_Value   => p_parameter7_Value
      , x_Target_rec         => l_Target_rec
      );
      BIS_UTILITIES_PUB.put_line(p_text =>'AFTER Verify: '||l_Target_rec.Target_level_id);

      IF BIS_UTILITIES_PUB.Value_NOT_Missing(l_Target_rec.Target_Level_ID)
        = FND_API.G_TRUE
      AND BIS_UTILITIES_PUB.Value_NOT_Null(l_Target_rec.Target_Level_ID)
        = FND_API.G_TRUE
      THEN
        l_Target_tbl(l_Target_tbl.COUNT+1) := l_Target_rec;
        BIS_UTILITIES_PUB.put_line(p_text =>'Verified target: '
        ||l_Target_tbl(l_Target_tbl.COUNT).Target_level_id);
      END IF;

    END LOOP;
    l_target_tbl_tmp.delete;

    BIS_UTILITIES_PUB.put_line(p_text =>'Number of targets retrieved for Report INFO: '||l_Target_tbl.COUNT);

  END LOOP;

  x_target_level_tbl := l_target_level_tbl;
  x_target_tbl := l_target_tbl;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 in Retrieve_Report_Info');
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 in Retrieve_Report_Info');
   when others then
      BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 in Retrieve_Report_Info: '||sqlerrm);

END Retrieve_Report_Info;

Procedure Set_Notify_Owners
( p_alert_type         IN VARCHAR2
, x_notify_owners_flag OUT NOCOPY VARCHAR2
)
IS
BEGIN

  IF UPPER(p_alert_type) = G_TARGET_LEVEL THEN
    x_notify_owners_flag := 'Y';
  ELSIF p_alert_type = G_ALL_TARGET THEN
    x_notify_owners_flag := 'N';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception in Set_Notify_Owners: '||sqlerrm);

END Set_Notify_Owners;

Procedure Form_Concurrent_Request
( p_request_desc            IN VARCHAR2
, p_Start_Time              IN VARCHAR2
, p_measure_id              IN NUMBER
, p_Measure_short_name      IN VARCHAR2
, p_time_level_id           IN NUMBER
, p_alert_type              IN VARCHAR2
, p_current_row             IN VARCHAR2
, p_alert_based_on          IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, x_Concurrent_Request_rec
    OUT NOCOPY BIS_CONCURRENT_MANAGER_PVT.PMF_Request_rec_Type
)
IS

  l_Concurrent_Request_rec
    BIS_CONCURRENT_MANAGER_PVT.PMF_Request_rec_Type;

BEGIN

  l_Concurrent_Request_rec := x_Concurrent_Request_rec;
  BIS_UTILITIES_PUB.put_line(p_text =>'Forming concurrent request');

  l_Concurrent_Request_rec.application_short_name
    := BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME;
  l_Concurrent_Request_rec.program
    := BIS_CONCURRENT_MANAGER_PVT.G_ALERT_PROGRAM;
  l_Concurrent_Request_rec.start_time  := p_start_time;
  l_Concurrent_Request_rec.description := p_request_desc;

  l_Concurrent_Request_rec.argument1  := p_measure_id;
  l_Concurrent_Request_rec.argument2  := p_measure_short_name;
  l_Concurrent_Request_rec.argument3  := NULL;
  l_Concurrent_Request_rec.argument4  := NULL;
  l_Concurrent_Request_rec.argument5  := NULL;
  l_Concurrent_Request_rec.argument6  := NULL;
  l_Concurrent_Request_rec.argument7  := NULL;
  l_Concurrent_Request_rec.argument8  := NULL;
  l_Concurrent_Request_rec.argument9  := p_time_level_id;
  l_Concurrent_Request_rec.argument10 := NULL;
  l_Concurrent_Request_rec.argument11 := NULL;
  l_Concurrent_Request_rec.argument12 := NULL;
  l_Concurrent_Request_rec.argument13 := NULL;
  l_Concurrent_Request_rec.argument14 := NULL;
  l_Concurrent_Request_rec.argument15 := NULL;
  l_Concurrent_Request_rec.argument16 := NULL;
  l_Concurrent_Request_rec.argument17 := NULL;
  l_Concurrent_Request_rec.argument18 := NULL;
  l_Concurrent_Request_rec.argument19 := NULL;
  l_Concurrent_Request_rec.argument20 := NULL;
  l_Concurrent_Request_rec.argument21 := NULL;
  l_Concurrent_Request_rec.argument22 := NULL;
  l_Concurrent_Request_rec.argument23 := NULL;
  l_Concurrent_Request_rec.argument24 := NULL;
  l_Concurrent_Request_rec.argument25 := NULL;
  l_Concurrent_Request_rec.argument26 := NULL;
  l_Concurrent_Request_rec.argument27 := NULL;
  l_Concurrent_Request_rec.argument28 := NULL;
  l_Concurrent_Request_rec.argument29 := NULL;
  l_Concurrent_Request_rec.argument30 := NULL;
  l_Concurrent_Request_rec.argument31 := NULL;
  l_Concurrent_Request_rec.argument32 := NULL;
  l_Concurrent_Request_rec.argument33 := NULL;

  l_Concurrent_Request_rec.argument34 := NULL;
  l_Concurrent_Request_rec.argument35 := NULL;
  l_Concurrent_Request_rec.argument36 := NULL;
  l_Concurrent_Request_rec.argument37 := NULL;
  l_Concurrent_Request_rec.argument38 := NULL;
  l_Concurrent_Request_rec.argument39 := NULL;

  l_Concurrent_Request_rec.argument40 := p_alert_type;
  l_Concurrent_Request_rec.argument41 := NULL;
  l_Concurrent_Request_rec.argument42 := p_current_row;
  l_Concurrent_Request_rec.argument43 := p_alert_based_on;

  x_Concurrent_Request_rec := l_Concurrent_Request_rec;
  BIS_UTILITIES_PUB.put_line(p_text =>'Request successfully formed.');

EXCEPTION
  when FND_API.G_EXC_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'form conc req 1');
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'form conc req 2');
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'form conc req 3: '||SQLERRM);
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Form_Concurrent_Request'
    );

END Form_Concurrent_Request;

-- compares new to orig.  if a row in new is not in orig, that row is
-- added to the diff table.  all rows (including new) is put into
-- all table.
--
PROCEDURE Compare_param_sets
( p_param_set_tbl_orig IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, p_param_set_tbl_new  IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_param_set_tbl_all  OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_param_set_tbl_diff OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
)
IS

  l_param_set_rec_new  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl_all  BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl_diff BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  in_orig BOOLEAN := FALSE;

BEGIN

  l_param_set_tbl_all := p_param_set_tbl_orig;
  BIS_UTILITIES_PUB.put_line(p_text =>'Comparing new requests');
  IF p_param_set_tbl_orig.COUNT = 0 THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'No original requests.  All new requests.');
    x_param_set_tbl_diff := p_param_set_tbl_new;
    x_param_set_tbl_all := p_param_set_tbl_new;
    RETURN;
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text =>'p_param_set_tbl_new.COUNT: '||p_param_set_tbl_new.COUNT);
  BIS_UTILITIES_PUB.put_line(p_text =>'p_param_set_tbl_orig.COUNT: '||p_param_set_tbl_orig.COUNT);

  FOR j IN 1..p_param_set_tbl_new.COUNT LOOP
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'compare_param_sets outer loop: '||j);
    BIS_UTILITIES_PUB.put_line(p_text =>'pm id: '||p_param_set_tbl_new(j).performance_measure_id );
    BIS_UTILITIES_PUB.put_line(p_text =>'tl id: '||p_param_set_tbl_new(j).target_level_id );
    BIS_UTILITIES_PUB.put_line(p_text =>'time id: '||p_param_set_tbl_new(j).time_dimension_level_id);
    BIS_UTILITIES_PUB.put_line(p_text =>'param 1 id: '||p_param_set_tbl_new(j).parameter1_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 2 id: '||p_param_set_tbl_new(j).parameter2_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 3 id: '||p_param_set_tbl_new(j).parameter3_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 4 id: '||p_param_set_tbl_new(j).parameter4_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 5 id: '||p_param_set_tbl_new(j).parameter5_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 6 id: '||p_param_set_tbl_new(j).parameter6_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 7 id: '||p_param_set_tbl_new(j).parameter7_value );
    */

    FOR i IN 1..p_param_set_tbl_orig.COUNT LOOP
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'compare_param_sets Inner loop: '||i);
    BIS_UTILITIES_PUB.put_line(p_text =>'pm id: '||p_param_set_tbl_orig(i).performance_measure_id );
    BIS_UTILITIES_PUB.put_line(p_text =>'tl id: '||p_param_set_tbl_orig(i).target_level_id );
    BIS_UTILITIES_PUB.put_line(p_text =>'time id: '||p_param_set_tbl_orig(i).time_dimension_level_id);
    BIS_UTILITIES_PUB.put_line(p_text =>'param 1 id: '||p_param_set_tbl_orig(i).parameter1_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 2 id: '||p_param_set_tbl_orig(i).parameter2_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 3 id: '||p_param_set_tbl_orig(i).parameter3_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 4 id: '||p_param_set_tbl_orig(i).parameter4_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 5 id: '||p_param_set_tbl_orig(i).parameter5_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 6 id: '||p_param_set_tbl_orig(i).parameter6_value );
    BIS_UTILITIES_PUB.put_line(p_text =>'param 7 id: '||p_param_set_tbl_orig(i).parameter7_value );
    */

      IF ((p_param_set_tbl_orig(i).performance_measure_id IS NULL
         AND p_param_set_tbl_new(j).performance_measure_id IS NULL)
         OR (p_param_set_tbl_orig(i).performance_measure_id
         = p_param_set_tbl_new(j).performance_measure_id))
      AND ((p_param_set_tbl_orig(i).target_level_id IS NULL
         AND p_param_set_tbl_new(j).target_level_id IS NULL)
         OR (p_param_set_tbl_orig(i).target_level_id
         = p_param_set_tbl_new(j).target_level_id))
      AND ((p_param_set_tbl_orig(i).time_dimension_level_id IS NULL
         AND p_param_set_tbl_new(j).time_dimension_level_id IS NULL)
         OR (p_param_set_tbl_orig(i).time_dimension_level_id
         = p_param_set_tbl_new(j).time_dimension_level_id))
      AND ((p_param_set_tbl_orig(i).parameter1_value IS NULL
         AND p_param_set_tbl_new(j).parameter1_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter1_value
         = p_param_set_tbl_new(j).parameter1_value))
      AND ((p_param_set_tbl_orig(i).parameter2_value IS NULL
         AND p_param_set_tbl_new(j).parameter2_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter2_value
         = p_param_set_tbl_new(j).parameter2_value))
      AND ((p_param_set_tbl_orig(i).parameter3_value IS NULL
         AND p_param_set_tbl_new(j).parameter3_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter3_value
         = p_param_set_tbl_new(j).parameter3_value ))
      AND ((p_param_set_tbl_orig(i).parameter4_value IS NULL
         AND p_param_set_tbl_new(j).parameter4_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter4_value
         = p_param_set_tbl_new(j).parameter4_value))
      AND ((p_param_set_tbl_orig(i).parameter5_value IS NULL
         AND p_param_set_tbl_new(j).parameter5_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter5_value
         = p_param_set_tbl_new(j).parameter5_value ))
      AND ((p_param_set_tbl_orig(i).parameter6_value IS NULL
         AND p_param_set_tbl_new(j).parameter6_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter6_value
         = p_param_set_tbl_new(j).parameter6_value ))
      AND ((p_param_set_tbl_orig(i).parameter7_value IS NULL
         AND p_param_set_tbl_new(j).parameter7_value IS NULL)
         OR (p_param_set_tbl_orig(i).parameter7_value
         = p_param_set_tbl_new(j).parameter7_value))
      THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'Original request');
        in_orig := TRUE;
        exit;
      ELSE
        l_param_set_rec_new := p_param_set_tbl_new(j);
        l_param_set_rec_new.notifiers_code
         := p_param_set_tbl_orig(i).notifiers_code;
        BIS_UTILITIES_PUB.put_line(p_text =>'New request for target level: '
        ||l_param_set_rec_new.target_level_id );
      END IF;
    END LOOP;

    IF NOT in_orig THEN
      l_param_set_tbl_diff(l_param_set_tbl_diff.COUNT+1)
         := l_param_set_rec_new;

      l_param_set_tbl_all(l_param_set_tbl_all.COUNT+1)
         := l_param_set_rec_new;
    END IF;
    in_orig := FALSE;

  END LOOP;

  BIS_UTILITIES_PUB.put_line(p_text =>'Number of new requests found: '||l_param_set_tbl_diff.COUNT);

  x_param_set_tbl_diff := l_param_set_tbl_diff;
  x_param_set_tbl_all := l_param_set_tbl_all;

EXCEPTION
  WHEN OTHERS THEN
  BIS_UTILITIES_PUB.put_line(p_text =>'exception at Compare_param_sets. '||sqlerrm);
  x_param_set_tbl_diff := l_param_set_tbl_diff;
  x_param_set_tbl_all := l_param_set_tbl_all;

END Compare_param_sets;

PROCEDURE Form_Parameter_Set
( p_measure_id             IN NUMBER
, p_time_level_id          IN NUMBER := NULL
, p_target_tbl             IN BIS_TARGET_PUB.Target_Tbl_type
, p_Notifiers_Code         IN VARCHAR2 := NULL
, x_parameter_set_tbl      OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
)
IS

  l_param_set_rec     BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_param_set_tbl     BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_Tbl_p       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  FOR i IN 1..p_Target_tbl.COUNT LOOP

    l_param_set_Rec.PERFORMANCE_MEASURE_ID := p_measure_id;
    l_param_set_Rec.TARGET_LEVEL_ID := p_target_tbl(i).Target_Level_ID;
    IF p_time_level_id IS NOT NULL THEN
      l_param_set_Rec.TIME_DIMENSION_LEVEL_ID := p_time_level_id;
    END IF;
    l_param_set_Rec.PLAN_ID := p_target_tbl(i).Plan_ID;
    l_param_set_Rec.PARAMETER1_VALUE :=p_target_tbl(i).Dim1_Level_Value_ID;
    l_param_set_Rec.PARAMETER2_VALUE :=p_target_tbl(i).Dim2_Level_Value_ID;
    l_param_set_Rec.PARAMETER3_VALUE :=p_target_tbl(i).Dim3_Level_Value_ID;
    l_param_set_Rec.PARAMETER4_VALUE :=p_target_tbl(i).Dim4_Level_Value_ID;
    l_param_set_Rec.PARAMETER5_VALUE :=p_target_tbl(i).Dim5_Level_Value_ID;
    l_param_set_Rec.PARAMETER6_VALUE :=p_target_tbl(i).Dim6_Level_Value_ID;
    l_param_set_Rec.PARAMETER7_VALUE :=p_target_tbl(i).Dim7_Level_Value_ID;
    IF p_notifiers_code IS NOT NULL THEN
      l_param_set_rec.NOTIFIERS_CODE := p_notifiers_code;
    END IF;
    l_param_set_tbl(l_param_set_tbl.COUNT+1) := l_param_set_rec;

  END LOOP;
  x_parameter_set_tbl := l_param_set_tbl;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'form_parameter_set exception1: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'form_parameter_set exception2: '||sqlerrm);
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'form_parameter_set exception3: '||sqlerrm);
    l_error_tbl_p := l_error_tbl;
     BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => 'form_parameter_set'
     , p_error_table       => l_error_tbl_p
     , x_error_table       => l_error_tbl
     );

END Form_Parameter_Set;

PROCEDURE Verify_Target_Level
( p_Target_Level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
, x_Target_Level_rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
)
IS

  l_Target_Level_rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
  sameViewBy             BOOLEAN;
  viewByLevelNum         NUMBER;
  l_viewBy_level_id      NUMBER;
  l_return_status        VARCHAR2(32000);
  l_error_Tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_Tbl_p          BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Target_Level_rec_p   BIS_Target_Level_PUB.Target_Level_Rec_Type;

BEGIN

  -- if no viewBy, check if target level's
  -- dimension levels = param1-7 level
  --
  -- if viewBy, find the param Level that is in the same dimension as
  -- the viewBy level, then check  the target levels that have
  -- dimension levels = param1-6 + viewBy level
  --
  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'In verify target level. Target level: '
  ||p_Target_Level_rec.Target_level_id
  ||', Viewby: '||p_viewby_level_id);
  */
  IF p_viewby_level_id IS NULL THEN
    IF   has_Dimension_Levels
         ( p_Target_Level_rec   => p_Target_Level_rec
         , p_parameter1_level   => p_parameter1_level
         , p_parameter2_level   => p_parameter2_level
         , p_parameter3_level   => p_parameter3_level
         , p_parameter4_level   => p_parameter4_level
         , p_parameter5_level   => p_parameter5_level
         , p_parameter6_level   => p_parameter6_level
         , p_parameter7_level   => p_parameter7_level
         , p_viewby_level_id    => p_viewby_level_id
         )
    THEN
      l_Target_Level_rec := p_Target_Level_rec;
      x_Target_Level_rec := l_Target_Level_rec;

      BIS_UTILITIES_PUB.put_line(p_text =>'In verify target level. Target level has dim levels, no viewby: '
      ||l_Target_Level_rec.Target_level_id);
    ELSE
      RETURN;
    END IF;
  ELSE
    -- if viewBy in param Level 1-7, same as above
    --
    Check_View_By
    ( p_parameter1_level   => p_parameter1_level
    , p_parameter2_level   => p_parameter2_level
    , p_parameter3_level   => p_parameter3_level
    , p_parameter4_level   => p_parameter4_level
    , p_parameter5_level   => p_parameter5_level
    , p_parameter6_level   => p_parameter6_level
    , p_parameter7_level   => p_parameter7_level
    , p_viewby_level_id    => p_viewby_level_id
    , sameViewBy           => sameViewBy
    , viewByLevelNum       => viewByLevelNum
    );
    --BIS_UTILITIES_PUB.put_line(p_text =>'view by level num: '||viewByLevelNum);

    IF sameViewBy THEN
      --BIS_UTILITIES_PUB.put_line(p_text =>' same view by!');
      IF   has_Dimension_Levels
           ( p_Target_Level_rec   => p_Target_Level_rec
           , p_parameter1_level   => p_parameter1_level
           , p_parameter2_level   => p_parameter2_level
           , p_parameter3_level   => p_parameter3_level
           , p_parameter4_level   => p_parameter4_level
           , p_parameter5_level   => p_parameter5_level
           , p_parameter6_level   => p_parameter6_level
           , p_parameter7_level   => p_parameter7_level
           , p_viewby_level_id    => p_viewby_level_id
           )
      THEN
        l_Target_Level_rec := p_Target_Level_rec;
        x_Target_Level_rec := l_Target_Level_rec;
        BIS_UTILITIES_PUB.put_line(p_text =>'In verify target level. DO have dimension levels: '
        ||l_Target_Level_rec.Target_level_id);
      ELSE
        --BIS_UTILITIES_PUB.put_line(p_text =>'In verify target level. Do NOT have dimension levels: '
        --||p_Target_Level_rec.Target_level_id);
        RETURN;
      END IF;
    ELSE
      BIS_UTILITIES_PUB.put_line(p_text =>' Different view by!');
      IF p_parameter1_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension1_Level_Id:=TO_NUMBER(p_parameter1_level);
      END IF;
      IF p_parameter2_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension2_Level_Id:=TO_NUMBER(p_parameter2_level);
      END IF;
      IF p_parameter3_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension3_Level_Id:=TO_NUMBER(p_parameter3_level);
      END IF;
      IF p_parameter4_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension4_Level_Id:=TO_NUMBER(p_parameter4_level);
      END IF;
      IF p_parameter5_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension5_Level_Id:=TO_NUMBER(p_parameter5_level);
      END IF;
      IF p_parameter6_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension6_Level_Id:=TO_NUMBER(p_parameter6_level);
      END IF;
      IF p_parameter7_level IS NOT NULL THEN
        l_Target_Level_rec.Dimension7_Level_Id:=TO_NUMBER(p_parameter7_level);
      END IF;
      IF p_viewby_level_id IS NOT NULL THEN
        l_viewby_level_id := TO_NUMBER(p_viewby_level_id);
      END IF;

      IF viewByLevelNum = 1 THEN
        l_Target_Level_rec.Dimension1_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
				BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 2 THEN
        l_Target_Level_rec.Dimension2_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 3 THEN
        l_Target_Level_rec.Dimension3_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 4 THEN
        l_Target_Level_rec.Dimension4_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 5 THEN
        l_Target_Level_rec.Dimension5_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 6 THEN
        l_Target_Level_rec.Dimension6_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSIF viewByLevelNum = 7 THEN
        l_Target_Level_rec.Dimension7_Level_Id := l_viewby_level_id;
        l_Target_Level_rec_p := l_Target_Level_rec;
        BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
        ( p_api_version       => 1.0
        , p_all_info          => FND_API.G_FALSE
        , p_Target_Level_rec  => l_Target_Level_rec_p
        , x_Target_Level_rec  => l_Target_Level_rec
        , x_return_status     => l_return_status
        , x_error_Tbl         => l_error_Tbl
        );
      ELSE
        RETURN;
      END IF;
    END IF;
  END IF;

  x_Target_Level_rec := l_Target_Level_rec;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'Verify_Target_Level exception1: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    BIS_UTILITIES_PUB.put_line(p_text =>'Verify_Target_Level exception2: '||sqlerrm);
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'Verify_Target_Level exception3: '||sqlerrm);
    l_error_Tbl_p := l_error_Tbl;
		 BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => 'Verify_Target_Level'
     , p_error_table       => l_error_tbl_p
     , x_error_table       => l_error_tbl
     );

END Verify_Target_Level;

PROCEDURE Verify_Target
( p_Target_rec       IN  BIS_Target_PUB.Target_Rec_Type
, p_parameter1_value IN  varchar2   default null
, p_parameter2_value IN  varchar2   default null
, p_parameter3_value IN  varchar2   default null
, p_parameter4_value IN  varchar2   default null
, p_parameter5_value IN  varchar2   default null
, p_parameter6_value IN  varchar2   default null
, p_parameter7_value IN  varchar2   default null
, x_Target_rec       OUT NOCOPY BIS_Target_PUB.Target_Rec_Type
)
IS

  l_Target_rec  BIS_Target_PUB.Target_Rec_Type;

BEGIN

  IF   has_Dimension_Level_Values
       ( p_Target_rec         => p_Target_rec
       , p_parameter1_value   => p_parameter1_value
       , p_parameter2_value   => p_parameter2_value
       , p_parameter3_value   => p_parameter3_value
       , p_parameter4_value   => p_parameter4_value
       , p_parameter5_value   => p_parameter5_value
       , p_parameter6_value   => p_parameter6_value
       , p_parameter7_value   => p_parameter7_value
       )
  THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'has Dimension_Level_Values');
    l_Target_rec := p_Target_rec;
  END IF;

  x_Target_rec := l_Target_rec;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception at Verify_Target: '||sqlerrm);
    x_Target_rec := NULL;

END Verify_Target;


FUNCTION has_Dimension_Levels
( p_Target_Level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
)
RETURN BOOLEAN
IS

BEGIN
  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Tdim1: '||p_Target_Level_rec.Dimension1_Level_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Pdim1: '||p_parameter1_level);

  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Tdim2: '||p_Target_Level_rec.Dimension2_Level_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Pdim2: '||p_parameter2_level);

  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Tdim3: '||p_Target_Level_rec.Dimension3_Level_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM LEV.  Pdim3: '||p_parameter3_level);
  */

  IF ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension1_Level_id)
       = FND_API.G_TRUE
    AND p_parameter1_level IS NULL)
    OR p_Target_Level_rec.Dimension1_Level_Id = TO_NUMBER(p_parameter1_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension2_Level_id)
       = FND_API.G_TRUE
    AND p_parameter2_level IS NULL)
    OR p_Target_Level_rec.Dimension2_Level_Id = TO_NUMBER(p_parameter2_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension3_Level_id)
       = FND_API.G_TRUE
    AND p_parameter3_level IS NULL)
    OR p_Target_Level_rec.Dimension3_Level_Id = TO_NUMBER(p_parameter3_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension4_Level_id)
       = FND_API.G_TRUE
    AND p_parameter4_level IS NULL)
    OR p_Target_Level_rec.Dimension4_Level_Id = TO_NUMBER(p_parameter4_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension5_Level_id)
       = FND_API.G_TRUE
    AND p_parameter5_level IS NULL)
    OR p_Target_Level_rec.Dimension5_Level_Id = TO_NUMBER(p_parameter5_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension6_Level_id)
       = FND_API.G_TRUE
    AND p_parameter6_level IS NULL)
    OR p_Target_Level_rec.Dimension6_Level_Id = TO_NUMBER(p_parameter6_level))
  AND ((BIS_UTILITIES_PUB.Value_Null(p_Target_Level_rec.Dimension7_Level_id)
       = FND_API.G_TRUE
    AND p_parameter7_level IS NULL)
    OR p_Target_Level_rec.Dimension7_Level_Id = TO_NUMBER(p_parameter7_level))
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Exception at has_Dimension_Levels: '||sqlerrm);
    RETURN FALSE;

END has_Dimension_Levels;

PROCEDURE check_View_by
( p_parameter1_level IN  varchar2   default null
, p_parameter2_level IN  varchar2   default null
, p_parameter3_level IN  varchar2   default null
, p_parameter4_level IN  varchar2   default null
, p_parameter5_level IN  varchar2   default null
, p_parameter6_level IN  varchar2   default null
, p_parameter7_level IN  varchar2   default null
, p_viewby_level_id  IN  varchar2   default null
, sameViewBy         OUT NOCOPY BOOLEAN
, viewByLevelNum     OUT NOCOPY NUMBER
)
IS

  l_sameViewBy     BOOLEAN := FALSE;
  l_viewByLevelNum NUMBER := -1;

BEGIN

  IF (p_viewby_level_id = p_parameter1_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 1;
  ELSIF (p_viewby_level_id = p_parameter2_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 2;
  ELSIF (p_viewby_level_id = p_parameter3_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 3;
  ELSIF (p_viewby_level_id = p_parameter4_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 4;
  ELSIF (p_viewby_level_id = p_parameter5_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 5;
  ELSIF (p_viewby_level_id = p_parameter6_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 6;
  ELSIF (p_viewby_level_id = p_parameter7_level) THEN
    l_sameViewBy := TRUE;
    l_viewByLevelNum := 7;
  END IF;

  sameViewBy := l_sameViewBy;
  viewByLevelNum := l_viewByLevelNum;

EXCEPTION
  WHEN OTHERS THEN
    sameViewBy := FALSE;
    viewByLevelNum := NULL;

END check_View_by;

FUNCTION has_Dimension_Level_Values
( p_Target_rec       IN  BIS_Target_PUB.Target_Rec_Type
, p_parameter1_value IN  varchar2   default null
, p_parameter2_value IN  varchar2   default null
, p_parameter3_value IN  varchar2   default null
, p_parameter4_value IN  varchar2   default null
, p_parameter5_value IN  varchar2   default null
, p_parameter6_value IN  varchar2   default null
, p_parameter7_value IN  varchar2   default null
)
RETURN BOOLEAN
IS

BEGIN

  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Tdim1: '||p_Target_rec.Dim1_level_value_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Pdim1: '||p_parameter1_value);

  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Tdim2: '||p_Target_rec.Dim2_level_value_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Pdim2: '||p_parameter2_value);

  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Tdim3: '||p_Target_rec.Dim3_level_value_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'in verify DIM VAL.  Pdim3: '||p_parameter3_value);
  */

  IF ((p_parameter1_value IS NULL)
    OR p_Target_rec.Dim1_Level_Value_Id = p_parameter1_value)
  AND ((p_parameter2_value IS NULL)
    OR p_Target_rec.Dim2_Level_Value_Id = p_parameter2_value)
  AND ((p_parameter3_value IS NULL)
    OR p_Target_rec.Dim3_Level_Value_Id = p_parameter3_value)
  AND ((p_parameter4_value IS NULL)
    OR p_Target_rec.Dim4_Level_Value_Id = p_parameter4_value)
  AND ((p_parameter5_value IS NULL)
    OR p_Target_rec.Dim5_Level_Value_Id = p_parameter5_value)
  AND ((p_parameter6_value IS NULL)
    OR p_Target_rec.Dim6_Level_Value_Id = p_parameter6_value)
  AND ((p_parameter7_value IS NULL)
    OR p_Target_rec.Dim7_Level_Value_Id = p_parameter7_value)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Exception at has_Dimension_Level_Values: '||sqlerrm);
    RETURN FALSE;

END has_Dimension_Level_Values;

FUNCTION is_time_level
(p_Dimension_Level_rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_rec_Type)
RETURN BOOLEAN

IS
  l_Dimension_Level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_rec_Type;
  l_return_status       VARCHAR2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_DIMENSION_LEVEL_PVT.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => p_dimension_Level_Rec
  , x_Dimension_Level_Rec => l_dimension_Level_Rec
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  );

  IF l_dimension_Level_Rec.dimension_short_name = BIS_UTILITIES_PVT.Get_Total_Dimlevel_Name
                     (p_dim_short_name => BIS_UTILITIES_PVT.Get_Time_Dimension_Name
                                          (p_DimLevelId => l_dimension_level_rec.Dimension_Level_Id))   THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END is_time_level;

FUNCTION IS_TOTAL_DIM_LEVEL
(p_DimLevelId IN NUMBER := NULL
)
RETURN BOOLEAN
IS


  CURSOR c_dim_id IS
  SELECT source, short_name,DIMENSION_ID
  FROM  bis_levels
  WHERE level_id = p_DimLevelId;

  CURSOR c_dim (p_dim_level_id in NUMBER) IS
   SELECT short_name
   FROM   bis_dimensions
   WHERE  dimension_id = p_dim_level_id;

  l_total_name           VARCHAR2(2000);
  l_source               VARCHAR2(2000);
  l_length               NUMBER;
  l_dimension_id         NUMBER;
  l_level_short_name     VARCHAR2(240);
  l_dim_short_name       VARCHAR2(240);
  l_return               BOOLEAN;

BEGIN

    OPEN c_dim_id;
    FETCH c_dim_id INTO l_Source,l_level_short_name, l_dimension_id;
    CLOSE c_dim_id;

    OPEN c_dim (l_dimension_id);
    FETCH c_dim  INTO l_dim_short_name;
    CLOSE c_dim;

    l_length := length(l_dim_short_name);

    IF (l_source = 'EDW')
    THEN
      l_total_name := substr(l_dim_short_name,1,(l_length-1) );
      l_total_name := l_total_name || 'A';
    END IF;
    IF (l_source = 'OLTP')
    THEN
       l_total_name := 'TOTAL_'||l_dim_short_name;
    END IF;

    if l_total_name = l_level_short_name then
       l_return := TRUE;
       BIS_UTILITIES_PUB.put_line(p_text =>'Is Total time');
    else
       l_return := FALSE;
       BIS_UTILITIES_PUB.put_line(p_text =>'Is Not Total time');
    end if;
    RETURN l_return;

 Exception
     when others then
      BIS_UTILITIES_PUB.put_line(p_text =>'Error in Procedure  IS_TOTAL_DIM_LEVEL  : '||sqlerrm);

END IS_TOTAL_DIM_LEVEL;


end BIS_PMF_REG_SERVICE_PVT;

/
