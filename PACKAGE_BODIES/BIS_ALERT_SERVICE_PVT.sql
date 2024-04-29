--------------------------------------------------------
--  DDL for Package Body BIS_ALERT_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ALERT_SERVICE_PVT" AS
/* $Header: BISVALRB.pls 120.1 2005/11/18 05:51:18 ankgoel noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVALRS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for Alert Services
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM |  24-MAY-2000 jradhakr Added a new procedure Retrieve_All_Request_Rows
REM |                       to retrieve all rows from Alert registration
REM |                       tables
REM |  20-SEP-2003 mahrao   Changed for bug# 2649486
REM |                       Change ensures that a new request ID is generated
REM |                       for each of the requests. This helps in decoupling
REM |                       the requestor from the requests he doesn't want.
REM |                       Got rid of the call to
REM |                       BIS_PMF_ALERT_REG_PVT.Retrieve_Notifiers_Code in
REM |                       Retrieve_All_Request_Rows as this was causing a
REM |                       single notifiers code when the requestor resquests
REM |                       for the alert.
REM | 23-JAN-03   mahrao    For having different local variables for IN and OUT
REM |                       parameters.
REM | 05-APR-03   mahrao    Filter criterion was missing while populating
REM |                       x_Alert_request_Tbl from l_Param_Set_tbl while
REM |                       l_param_set_tbl already contains the required record.
REM | 11-APR-03   mahrao    Filter criterion is corrected in procedure
REM |                       Retrieve_All_Request_Rows
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM | 18-Nov-2005 ankgoel bug# 4675515 DBI Actuals for previous time period |
REM +=======================================================================+
*/

--
-- Constants
--

l_debug_text             VARCHAR2(32000);
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_ALERT_SERVICE_PVT';

-----------------------------------------------------
-- Procedures Forward declarations
-----------------------------------------------------

Procedure Submit_Planning_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	          IN VARCHAR2 := NULL
, p_alert_level	          IN VARCHAR2 := NULL
);

Procedure Submit_Planning_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_primary_dim_level_rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_notify_set	          IN VARCHAR2
, p_alert_type	          IN VARCHAR2
, p_alert_level	          IN VARCHAR2
);

Procedure Form_Planning_Request
( p_measure_id				IN NUMBER  := NULL
, p_measure_short_name			IN VARCHAR2 := NULL
, p_target_level_id			IN NUMBER
, p_target_level_short_name		IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id			IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id			IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id			IN NUMBER := NULL
, p_dim6_level_short_name		IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_id			IN NUMBER := NULL
, p_dim7_level_short_name		IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, p_target_id				IN NUMBER := NULL
, p_target				IN NUMBER := NULL
, p_actual_id				IN NUMBER := NULL
, p_actual				IN NUMBER := NULL
, p_primary_dim_level_id		IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type				IN VARCHAR2 := NULL
, p_alert_level				IN VARCHAR2 := NULL
, x_measure_instance	  OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
, x_Dim_Level_Value_Tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
);

-- For future enhencements
--
Procedure Form_Planning_Request
( p_measure_id				IN NUMBER := NULL
, p_measure_short_name			IN VARCHAR2 := NULL
, p_target_level_id			IN NUMBER
, p_target_level_short_name		IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id			IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id			IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id			IN NUMBER := NULL
, p_dim6_level_short_name		IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_id			IN NUMBER := NULL
, p_dim7_level_short_name		IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, p_target_id				IN NUMBER := NULL
, p_target				IN NUMBER := NULL
, p_actual_id				IN NUMBER := NULL
, p_actual    				IN NUMBER := NULL
, p_primary_dim_level_id		IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type				IN VARCHAR2 := NULL
, p_alert_level				IN VARCHAR2 := NULL
, x_measure_instance	  OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
, x_Dim_Level_Value_Tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_primary_dim_level_rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_notify_set		  OUT NOCOPY VARCHAR2
, x_alert_type		  OUT NOCOPY VARCHAR2
, x_alert_level		  OUT NOCOPY VARCHAR2
);

-- Retrieve rows from the Alert Registration Repository
-- and any new targets that might have been created
--
PROCEDURE Retrieve_All_Request_Rows
( p_api_version          IN  NUMBER
 ,p_perf_measure_id      IN  NUMBER
 ,p_time_dim_level_id    IN  NUMBER
 ,p_current_row          IN VARCHAR2 := NULL
 ,p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, p_alert_type	    	 IN VARCHAR2 := NULL
, p_alert_level	    	 IN VARCHAR2 := NULL
 ,x_Alert_request_Tbl    OUT NOCOPY  BIS_ALERT_SERVICE_PVT.Alert_request_Tbl_type
 ,x_return_status        OUT NOCOPY VARCHAR2
 ,x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);

-----------------------------------------------------
-- Procedures
-----------------------------------------------------

Procedure Service_Alert_Request
( ERRBUF			        OUT NOCOPY VARCHAR2
, RETCODE			        OUT NOCOPY VARCHAR2
, p_measure_id				IN NUMBER
, p_measure_short_name			IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id		        IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id			IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id		        IN NUMBER := NULL
, p_dim6_level_short_name	        IN VARCHAR2 := NULL
, p_dim6_level_value_id		        IN VARCHAR2 := NULL
, p_dim7_level_id		        IN NUMBER := NULL
, p_dim7_level_short_name	        IN VARCHAR2 := NULL
, p_dim7_level_value_id		        IN VARCHAR2 := NULL
, p_primary_dim_level_id	        IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type	                        IN VARCHAR2 := NULL
, p_alert_level	                        IN VARCHAR2 := NULL
, p_current_row                         IN VARCHAR2 := 'N'
, p_alert_based_on                      IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
)
IS

  l_alert_request_tbl       BIS_ALERT_SERVICE_PVT.Alert_Request_Tbl_Type;
  l_Concurrent_Request_Tbl  BIS_CONCURRENT_MANAGER_PVT.PMF_Request_Tbl_Type;
  l_request_id_tbl          BIS_UTILITIES_PUB.BIS_VARCHAR_TBL;

  l_return_status     VARCHAR2(1000);
  l_error_Tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_api_version       NUMBER := 1;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'Servicing main alert request ');
  BIS_UTILITIES_PUB.put_line(p_text =>'alert type: '||p_alert_type);

  BIS_UTILITIES_PUB.put_line(p_text =>'Time level : '||p_time_level_id);

  -- Retrieves all rows from ART for this request
  --
  Retrieve_All_Request_Rows
  ( p_api_version               => l_api_version
  , p_perf_measure_id           => p_measure_id
  , p_time_dim_level_id         => p_time_level_id
  , p_current_row               => p_current_row
  , p_alert_based_on            => p_alert_based_on
  , p_alert_type                => p_alert_type
  , p_alert_level               => p_alert_level
  , x_Alert_Request_Tbl         => l_alert_request_tbl
  , x_return_status             => l_return_status
  , x_error_Tbl                 => l_error_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Number of request rows: '||l_alert_request_tbl.count);

  Form_Concurrent_Request
  ( p_Alert_Request_Tbl      => l_Alert_Request_Tbl
  , x_Concurrent_Request_Tbl => l_Concurrent_Request_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Submit concurrent requests for Detial Alert Service');
  --
  BIS_CONCURRENT_MANAGER_PVT.Submit_Concurrent_Request
  ( p_Concurrent_Request_Tbl => l_Concurrent_Request_Tbl
  , x_request_id_tbl         => l_request_id_tbl
  , x_errbuf                 => ERRBUF
  , x_retcode                => RETCODE
  );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      BIS_UTILITIES_PUB.put_line(p_text =>'service alert req error 1');
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      BIS_UTILITIES_PUB.put_line(p_text =>'service alert req error 2');
      RETURN;
   when others then
      RETCODE := 1;
      BIS_UTILITIES_PUB.put_line(p_text =>'service alert req error 3: '||SQLERRM);

      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      RETURN;

END Service_Alert_Request;

Procedure Service_Alert_Request_Pvt
( ERRBUF			        OUT NOCOPY VARCHAR2
, RETCODE			        OUT NOCOPY VARCHAR2
, p_measure_id				IN NUMBER := NULL
, p_measure_short_name			IN VARCHAR2 := NULL
, p_target_level_id			IN NUMBER
, p_target_level_short_name		IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id			IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id	 		IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id			IN NUMBER := NULL
, p_dim6_level_short_name		IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_id			IN NUMBER := NULL
, p_dim7_level_short_name		IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, p_target_id				IN NUMBER := NULL
, p_target				IN NUMBER := NULL
, p_actual_id				IN NUMBER := NULL
, p_actual				IN NUMBER := NULL
, p_primary_dim_level_id		IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type	                        IN VARCHAR2 := NULL
, p_alert_level	                        IN VARCHAR2 := NULL
, p_current_row                         IN VARCHAR2 := NULL
)
IS

  l_Measure_Instance BIS_MEASURE_PUB.Measure_Instance_type;
  l_Dim_Level_Value_Tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_alert_request_tbl BIS_ALERT_SERVICE_PVT.Alert_Request_Tbl_Type;
  l_alert_request_rec BIS_ALERT_SERVICE_PVT.Alert_Request_Rec_Type;
  l_return_status      VARCHAR2(1000);
  l_return_msg         VARCHAR2(32000);

BEGIN

  -- Debug messages should be printed irrespective of profile option.
  bis_utilities_pvt.set_debug_log_flag (  -- 2715218
    p_is_true         => TRUE
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  ) ;

  -- fnd_file.put_line(fnd_file.log, ' Return status is = ' || nvl(l_return_status, 'X!!' ));

  BIS_UTILITIES_PUB.put_line(p_text =>' ------- Begin log file for SONAR child request. ------- ');

  BIS_UTILITIES_PUB.put_line(p_text =>'Servicing detailed alert request.');

  -- Form generic planning request record
  --
  Form_Planning_Request
  ( p_measure_id		=> p_measure_id
  , p_measure_short_name	=> p_measure_short_name
  , p_target_level_id		=> p_target_level_id
  , p_target_level_short_name	=> p_target_level_short_name
  , p_plan_id			=> p_plan_id
  , p_org_level_id		=> p_org_level_id
  , p_org_level_short_name	=> p_org_level_short_name
  , p_organization_id		=> p_organization_id
  , p_time_level_id		=> p_time_level_id
  , p_time_level_short_name	=> p_time_level_short_name
  , p_time_level_value_id	=> p_time_level_value_id
  , p_dim1_level_id		=> p_dim1_level_id
  , p_dim1_level_short_name	=> p_dim1_level_short_name
  , p_dim1_level_value_id	=> p_dim1_level_value_id
  , p_dim2_level_id		=> p_dim2_level_id
  , p_dim2_level_short_name	=> p_dim2_level_short_name
  , p_dim2_level_value_id	=> p_dim2_level_value_id
  , p_dim3_level_id		=> p_dim3_level_id
  , p_dim3_level_short_name	=> p_dim3_level_short_name
  , p_dim3_level_value_id	=> p_dim3_level_value_id
  , p_dim4_level_id		=> p_dim4_level_id
  , p_dim4_level_short_name	=> p_dim4_level_short_name
  , p_dim4_level_value_id	=> p_dim4_level_value_id
  , p_dim5_level_id		=> p_dim5_level_id
  , p_dim5_level_short_name	=> p_dim5_level_short_name
  , p_dim5_level_value_id	=> p_dim5_level_value_id
  , p_dim6_level_id		=> p_dim6_level_id
  , p_dim6_level_short_name	=> p_dim6_level_short_name
  , p_dim6_level_value_id	=> p_dim6_level_value_id
  , p_dim7_level_id		=> p_dim7_level_id
  , p_dim7_level_short_name	=> p_dim7_level_short_name
  , p_dim7_level_value_id	=> p_dim7_level_value_id
  , p_target_id                 => p_target_id
  , p_target    		=> p_target
  , p_actual_id 		=> p_actual_id
  , p_actual    		=> p_actual
  , p_primary_dim_level_id	=> p_primary_dim_level_id
  , p_primary_dim_level_short_name => p_primary_dim_level_short_name
  , P_notify_set		=> P_notify_set
  , p_alert_type		=> p_alert_type
  , p_alert_level		=> p_alert_level
  , x_measure_instance	        => l_Measure_Instance
  , x_Dim_Level_Value_Tbl	=> l_Dim_Level_Value_Tbl
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Target level id: '||l_Measure_Instance.target_level_id);

  -- submit generic planning request
  --
  Submit_Planning_Request
  ( p_measure_instance     => l_Measure_Instance
  , p_dim_level_value_tbl  => l_Dim_Level_Value_Tbl
  , p_alert_type           => p_alert_type
  , p_alert_level          => p_alert_level
  );

  BIS_UTILITIES_PUB.put_line(p_text => ' ------- End log file for SONAR child request. ------- ');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      RETURN;
   when others then
      RETCODE := 1;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request_pvt'
      );
      RETURN;
END Service_Alert_Request_Pvt;

Procedure Submit_Planning_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	          IN VARCHAR2 := NULL
, p_alert_level	          IN VARCHAR2 := NULL
)
IS

BEGIN

  BIS_GENERIC_PLANNER_PVT.Service_Planner_Request
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_Dim_Level_Value_Tbl
  , p_alert_type	   => p_alert_type
  , p_alert_level	   => p_alert_level
  );

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      RETURN;

END Submit_Planning_Request;

-- for future enhencements
--
Procedure Submit_Planning_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_primary_dim_level_rec IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, P_notify_set	          IN VARCHAR2
, p_alert_type	          IN VARCHAR2
, p_alert_level	          IN VARCHAR2
)
IS

BEGIN

null;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      RETURN;
END Submit_Planning_Request;

Procedure Form_Concurrent_Request
( p_Alert_Request_Tbl      IN Alert_Request_Tbl_Type
, x_Concurrent_Request_Tbl
    OUT NOCOPY BIS_CONCURRENT_MANAGER_PVT.PMF_Request_Tbl_Type
)
IS

  l_Concurrent_Request_Tbl
    BIS_CONCURRENT_MANAGER_PVT.PMF_Request_Tbl_Type;
  l_count NUMBER := 0;

BEGIN

  l_Concurrent_Request_Tbl := x_Concurrent_Request_Tbl;
  BIS_UTILITIES_PUB.put_line(p_text =>'Forming concurrent requests. Number of alert requests: '
  ||p_Alert_Request_Tbl.COUNT );

  FOR i IN 1..p_Alert_Request_Tbl.COUNT LOOP
    --BIS_UTILITIES_PUB.put_line(p_text =>'in form concurrent request: target level id: '
    --||p_Alert_Request_Tbl(i).target_level_id);

    l_count := l_Concurrent_Request_Tbl.COUNT+1;

    l_Concurrent_Request_Tbl(l_count).application_short_name
      := BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME;
    l_Concurrent_Request_Tbl(l_count).program
      := BIS_CONCURRENT_MANAGER_PVT.G_ALERT_PROGRAM_PVT;
    l_Concurrent_Request_Tbl(l_count).start_time   := NULL;
    l_Concurrent_Request_Tbl(l_count).description
      := 'BIS Alert Detail: '||p_alert_request_tbl(i).target_level_id;
    l_Concurrent_Request_Tbl(l_count).argument1
      := p_alert_request_tbl(i).measure_id;
    l_Concurrent_Request_Tbl(l_count).argument2
      := p_alert_request_tbl(i).measure_short_name;
    l_Concurrent_Request_Tbl(l_count).argument3
      := p_alert_request_tbl(i).target_level_id;
    l_Concurrent_Request_Tbl(l_count).argument4
      := p_alert_request_tbl(i).target_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument5
      := p_alert_request_tbl(i).plan_id;

    l_Concurrent_Request_Tbl(l_count).argument6
      := p_alert_request_tbl(i).org_level_id;
    l_Concurrent_Request_Tbl(l_count).argument7
      := p_alert_request_tbl(i).org_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument8
      := p_alert_request_tbl(i).organization_id;

    l_Concurrent_Request_Tbl(l_count).argument9
      := p_alert_request_tbl(i).time_level_id;
    l_Concurrent_Request_Tbl(l_count).argument10
      := p_alert_request_tbl(i).time_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument11
      := p_alert_request_tbl(i).time_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument12
      := p_alert_request_tbl(i).dim1_level_id;
    l_Concurrent_Request_Tbl(l_count).argument13
      := p_alert_request_tbl(i).dim1_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument14
      := p_alert_request_tbl(i).dim1_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument15
       := p_alert_request_tbl(i).dim2_level_id;
    l_Concurrent_Request_Tbl(l_count).argument16
      := p_alert_request_tbl(i).dim2_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument17
      := p_alert_request_tbl(i).dim2_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument18
      := p_alert_request_tbl(i).dim3_level_id;
    l_Concurrent_Request_Tbl(l_count).argument19
      := p_alert_request_tbl(i).dim3_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument20
      := p_alert_request_tbl(i).dim3_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument21
      := p_alert_request_tbl(i).dim4_level_id;
    l_Concurrent_Request_Tbl(l_count).argument22
      := p_alert_request_tbl(i).dim4_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument23
      := p_alert_request_tbl(i).dim4_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument24
      := p_alert_request_tbl(i).dim5_level_id;
    l_Concurrent_Request_Tbl(l_count).argument25
      := p_alert_request_tbl(i).dim5_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument26
      := p_alert_request_tbl(i).dim5_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument27
      := p_alert_request_tbl(i).dim6_level_id;
    l_Concurrent_Request_Tbl(l_count).argument28
      := p_alert_request_tbl(i).dim6_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument29
      := p_alert_request_tbl(i).dim6_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument30
      := p_alert_request_tbl(i).dim7_level_id;
    l_Concurrent_Request_Tbl(l_count).argument31
      := p_alert_request_tbl(i).dim7_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument32
      := p_alert_request_tbl(i).dim7_level_value_id;

    l_Concurrent_Request_Tbl(l_count).argument33
      := p_alert_request_tbl(i).target_id;
    l_Concurrent_Request_Tbl(l_count).argument34
      := p_alert_request_tbl(i).target;
    l_Concurrent_Request_Tbl(l_count).argument35
      := p_alert_request_tbl(i).actual_id;

    l_Concurrent_Request_Tbl(l_count).argument36
      := p_alert_request_tbl(i).actual;
    l_Concurrent_Request_Tbl(l_count).argument37
      := p_alert_request_tbl(i).primary_dim_level_id;
    l_Concurrent_Request_Tbl(l_count).argument38
      := p_alert_request_tbl(i).primary_dim_level_short_name;
    l_Concurrent_Request_Tbl(l_count).argument39
      := p_alert_request_tbl(i).notify_set;
    l_Concurrent_Request_Tbl(l_count).argument40
      := p_alert_request_tbl(i).alert_type;
    l_Concurrent_Request_Tbl(l_count).argument41
      := p_alert_request_tbl(i).alert_level;
    l_Concurrent_Request_Tbl(l_count).argument42
      := p_alert_request_tbl(i).current_row;    -- current row
    l_Concurrent_Request_Tbl(l_count).argument43
      := p_alert_request_tbl(i).alert_based_on;
  END LOOP;

  x_Concurrent_Request_Tbl := l_Concurrent_Request_Tbl;
  BIS_UTILITIES_PUB.put_line(p_text =>'Number of request successfully formed: '
  ||x_Concurrent_Request_Tbl.COUNT);

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


Procedure Form_Planning_Request
( p_measure_id				IN NUMBER := NULL
, p_measure_short_name			IN VARCHAR2 := NULL
, p_target_level_id			IN NUMBER
, p_target_level_short_name		IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id			IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id			IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id			IN NUMBER := NULL
, p_dim6_level_short_name		IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_id			IN NUMBER := NULL
, p_dim7_level_short_name		IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, p_target_id				IN NUMBER := NULL
, p_target				IN NUMBER := NULL
, p_actual_id				IN NUMBER := NULL
, p_actual				IN NUMBER := NULL
, p_primary_dim_level_id		IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type				IN VARCHAR2 := NULL
, p_alert_level				IN VARCHAR2 := NULL
, x_measure_instance	  OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
, x_Dim_Level_Value_Tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
)
IS

  l_measure_instance BIS_MEASURE_PUB.measure_instance_Type;
  l_Dim_Level_Value_Tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;

BEGIN

  l_measure_instance := x_measure_instance;
  l_Dim_Level_Value_Tbl := x_Dim_Level_Value_Tbl;

  l_measure_instance.measure_id := p_measure_id ;
  l_measure_instance.measure_short_name := p_measure_short_name;
  l_measure_instance.target_level_id := p_target_level_id ;
  l_measure_instance.target_level_short_name := p_target_level_short_name;
  l_measure_instance.plan_id := p_plan_id ;

  l_Dim_Level_Value_Tbl(1).dimension_level_id := p_dim1_level_id ;
  l_Dim_Level_Value_Tbl(1).dimension_level_short_name
    := p_dim1_level_short_name;
  l_Dim_Level_Value_Tbl(1).Dimension_Level_Value_ID := p_dim1_level_value_id;

  l_Dim_Level_Value_Tbl(2).dimension_level_id := p_dim2_level_id ;
  l_Dim_Level_Value_Tbl(2).dimension_level_short_name
    := p_dim2_level_short_name;
  l_Dim_Level_Value_Tbl(2).dimension_level_value_id := p_dim2_level_value_id;

/*
  l_Dim_Level_Value_Tbl(1).dimension_level_id := p_org_level_id ;
  l_Dim_Level_Value_Tbl(1).dimension_level_short_name
    := p_org_level_short_name;
  l_Dim_Level_Value_Tbl(1).Dimension_Level_Value_ID := p_organization_id;

  l_Dim_Level_Value_Tbl(2).dimension_level_id := p_time_level_id ;
  l_Dim_Level_Value_Tbl(2).dimension_level_short_name
    := p_time_level_short_name;
  l_Dim_Level_Value_Tbl(2).dimension_level_value_id := p_time_level_value_id;
*/

  l_Dim_Level_Value_Tbl(3).dimension_level_id := p_dim3_level_id ;
  l_Dim_Level_Value_Tbl(3).dimension_level_short_name
    := p_dim3_level_short_name;
  l_Dim_Level_Value_Tbl(3).dimension_level_value_id := p_dim3_level_value_id;

  l_Dim_Level_Value_Tbl(4).dimension_level_id := p_dim4_level_id ;
  l_Dim_Level_Value_Tbl(4).dimension_level_short_name
    := p_dim4_level_short_name;
  l_Dim_Level_Value_Tbl(4).dimension_level_value_id := p_dim4_level_value_id;

  l_Dim_Level_Value_Tbl(5).dimension_level_id := p_dim5_level_id ;
  l_Dim_Level_Value_Tbl(5).dimension_level_short_name
    := p_dim5_level_short_name;
  l_Dim_Level_Value_Tbl(5).dimension_level_value_id := p_dim5_level_value_id;

  l_Dim_Level_Value_Tbl(6).dimension_level_id := p_dim6_level_id ;
  l_Dim_Level_Value_Tbl(6).dimension_level_short_name
    := p_dim6_level_short_name;
  l_Dim_Level_Value_Tbl(6).dimension_level_value_id := p_dim6_level_value_id;

  l_Dim_Level_Value_Tbl(7).dimension_level_id := p_dim7_level_id ;
  l_Dim_Level_Value_Tbl(7).dimension_level_short_name
    := p_dim7_level_short_name;
  l_Dim_Level_Value_Tbl(7).dimension_level_value_id := p_dim7_level_value_id;

  l_measure_instance.target_id := p_target_id ;
  l_measure_instance.target := p_target ;

  l_measure_instance.actual_id := p_actual_id ;
  l_measure_instance.actual := p_actual ;

  /* not used
  l_Dim_Level_Value_Tbl(1).primary_dim_level_id
    := p_dimension_level_rec.dimension_level_id;
  l_Dim_Level_Value_Tbl(1).primary_dim_level_short_name
    := p_dimension_level_rec.dimension_level_short_name;

  l_measure_instance.notify_set := p_notify_set;
  l_measure_instance.alert_type := p_alert_type;
  l_measure_instance.alert_level := p_alert_level;
  */

  x_measure_instance := l_measure_instance;
  x_Dim_Level_Value_Tbl := l_Dim_Level_Value_Tbl;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Form_Planning_Request'
      );
      RETURN;

END Form_Planning_Request;

-- for future enhencements
--
Procedure Form_Planning_Request
( p_measure_id				IN NUMBER := NULL
, p_measure_short_name			IN VARCHAR2 := NULL
, p_target_level_id			IN NUMBER
, p_target_level_short_name		IN VARCHAR2
, p_plan_id				IN NUMBER := NULL
, p_org_level_id		        IN NUMBER := NULL
, p_org_level_short_name	        IN VARCHAR2 := NULL
, p_organization_id			IN VARCHAR2 := NULL
, p_time_level_id		        IN NUMBER := NULL
, p_time_level_short_name		IN VARCHAR2 := NULL
, p_time_level_value_id			IN VARCHAR2 := NULL
, p_dim1_level_id		        IN NUMBER := NULL
, p_dim1_level_short_name	        IN VARCHAR2 := NULL
, p_dim1_level_value_id			IN VARCHAR2 := NULL
, p_dim2_level_id			IN NUMBER := NULL
, p_dim2_level_short_name		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_id			IN NUMBER := NULL
, p_dim3_level_short_name		IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_id			IN NUMBER := NULL
, p_dim4_level_short_name		IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_id			IN NUMBER := NULL
, p_dim5_level_short_name		IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_id			IN NUMBER := NULL
, p_dim6_level_short_name		IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_id			IN NUMBER := NULL
, p_dim7_level_short_name		IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, p_target_id				IN NUMBER := NULL
, p_target				IN NUMBER := NULL
, p_actual_id				IN NUMBER := NULL
, p_actual    				IN NUMBER := NULL
, p_primary_dim_level_id		IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type				IN VARCHAR2 := NULL
, p_alert_level				IN VARCHAR2 := NULL
, x_measure_instance	  OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
, x_Dim_Level_Value_Tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_primary_dim_level_rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_notify_set		  OUT NOCOPY VARCHAR2
, x_alert_type		  OUT NOCOPY VARCHAR2
, x_alert_level		  OUT NOCOPY VARCHAR2
)
IS

BEGIN

null;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      RETURN;
END Form_Planning_Request;

Procedure Form_Alert_Request_rec
( p_target_level_rec       IN BIS_Target_level_PUB.Target_level_Rec_Type
, p_target_rec             IN BIS_Target_PUB.Target_rec_Type
, p_dimension_level_rec    IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_notify_set	           IN VARCHAR2 := NULL
, p_alert_type	           IN VARCHAR2 := NULL
, p_alert_level	           IN VARCHAR2 := NULL
, x_Alert_Request_rec      OUT NOCOPY Alert_Request_rec_Type
)
IS

  l_Alert_Request_rec BIS_ALERT_SERVICE_PVT.Alert_Request_rec_Type;

BEGIN
  --BIS_UTILITIES_PUB.put_line(p_text =>'in form alert request: target id: '||p_target_rec.target_id);

  l_Alert_Request_rec := x_Alert_Request_rec;

  l_alert_request_rec.measure_id
    := p_target_level_rec.measure_id ;
  l_alert_request_rec.target_level_id
    := p_target_level_rec.target_level_id ;
  l_alert_request_rec.target_level_short_name
    := p_target_level_rec.target_level_short_name;
  l_alert_request_rec.plan_id
    := p_target_rec.plan_id ;

  l_alert_request_rec.org_level_id
    := p_target_level_rec.org_level_id ;
  l_alert_request_rec.org_level_short_name
    := p_target_level_rec.org_level_short_name;
  l_alert_request_rec.organization_id
    := p_target_rec.org_level_value_id;
  l_alert_request_rec.time_level_id
    := p_target_level_rec.time_level_id ;
  l_alert_request_rec.time_level_short_name
    := p_target_level_rec.time_level_short_name;
  l_alert_request_rec.time_level_value_id
    := p_target_rec.time_level_value_id;

  l_alert_request_rec.dim1_level_id
    := p_target_level_rec.dimension1_level_id ;
  l_alert_request_rec.dim1_level_short_name
    := p_target_level_rec.dimension1_level_short_name;
  l_alert_request_rec.dim1_level_value_id
    := p_target_rec.dim1_level_value_id;

  l_alert_request_rec.dim2_level_id
    := p_target_level_rec.dimension2_level_id ;
  l_alert_request_rec.dim2_level_short_name
    := p_target_level_rec.dimension2_level_short_name;
  l_alert_request_rec.dim2_level_value_id
    := p_target_rec.dim2_level_value_id;

  l_alert_request_rec.dim3_level_id
    := p_target_level_rec.dimension3_level_id;
  l_alert_request_rec.dim3_level_short_name
    := p_target_level_rec.dimension3_level_short_name;
  l_alert_request_rec.dim3_level_value_id
    := p_target_rec.dim3_level_value_id;

  l_alert_request_rec.dim4_level_id
    := p_target_level_rec.dimension4_level_id ;
  l_alert_request_rec.dim4_level_short_name
    := p_target_level_rec.dimension4_level_short_name;
  l_alert_request_rec.dim4_level_value_id
    := p_target_rec.dim4_level_value_id ;

  l_alert_request_rec.dim5_level_id
    := p_target_level_rec.dimension5_level_id;
  l_alert_request_rec.dim5_level_short_name
    := p_target_level_rec.dimension5_level_short_name ;
  l_alert_request_rec.dim5_level_value_id
    := p_target_rec.dim5_level_value_id ;

  l_alert_request_rec.dim6_level_id
    := p_target_level_rec.dimension6_level_id;
  l_alert_request_rec.dim6_level_short_name
    := p_target_level_rec.dimension6_level_short_name;
  l_alert_request_rec.dim6_level_value_id
    := p_target_rec.dim6_level_value_id;

  l_alert_request_rec.dim7_level_id
    := p_target_level_rec.dimension7_level_id;
  l_alert_request_rec.dim7_level_short_name
    := p_target_level_rec.dimension7_level_short_name;
  l_alert_request_rec.dim7_level_value_id
    := p_target_rec.dim7_level_value_id;

  l_alert_request_rec.target_id := p_target_rec.target_id ;
  l_alert_request_rec.target := p_target_rec.target ;

  /*
  l_alert_request_rec.primary_dim_level_id
    := p_dimension_level_rec.dimension_level_id;
  l_alert_request_rec.primary_dim_level_short_name
    := p_dimension_level_rec.dimension_level_short_name;
  */

  l_alert_request_rec.notify_set := p_notify_set;
  l_alert_request_rec.alert_type := p_alert_type;
  l_alert_request_rec.alert_level := p_alert_level;

  x_Alert_Request_rec := l_Alert_Request_rec;

  --BIS_UTILITIES_PUB.put_line(p_text =>'target reqest formed : target id : '
  --||x_Alert_Request_rec.target_id);

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Form alert request error: '||sqlerrm);
    return;

END Form_Alert_Request_rec;

-- Procedure to retrieve rows from alert registration repository.
--
PROCEDURE Retrieve_All_Request_Rows
( p_api_version          IN NUMBER
 ,p_perf_measure_id      IN NUMBER
 ,p_time_dim_level_id    IN NUMBER
 ,p_current_row          IN VARCHAR2 := NULL
 ,p_alert_based_on       IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
, p_alert_type	    	 IN VARCHAR2 := NULL
, p_alert_level	    	 IN VARCHAR2 := NULL
 ,x_Alert_request_Tbl    OUT NOCOPY BIS_ALERT_SERVICE_PVT.Alert_request_Tbl_type
 ,x_return_status        OUT NOCOPY VARCHAR2
 ,x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_param_set_tbl_orig BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_param_set_tbl      BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_request_scheduled  VARCHAR2(1000);
  l_request_id         VARCHAR2(32000);
  l_debug_text         VARCHAR2(32000);

  l_count              NUMBER := 0;
  l_target_tbl         BIS_TARGET_PUB.Target_Tbl_type;
  l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
  c_num                NUMBER := -9999;
  c_var                VARCHAR2(5) := '-9999';
	l_flag               BOOLEAN := FALSE;
	l_count_param_set_tbl NUMBER := 0;
Begin

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving all request rows. Current row? '||p_current_row);
  BIS_UTILITIES_PUB.put_line(p_text =>'alert type: '||p_alert_type);

  BIS_PMF_ALERT_REG_PUB.Retrieve_Parameter_set
   ( p_api_version             => p_api_version
   , p_measure_id              => p_perf_measure_id
   , p_time_dimension_level_id => p_time_dim_level_id
   , p_current_row             => p_current_row
   , x_Param_Set_Tbl           => l_Param_Set_Tbl_orig
   , x_return_status           => x_return_status
   , x_error_Tbl               => x_error_Tbl
   );
  BIS_UTILITIES_PUB.put_line(p_text =>'Original number of parameter sets: '|| l_Param_Set_Tbl_orig.count);

  BIS_PMF_REG_SERVICE_PVT.Retrieve_target_info
  ( p_api_version    => p_api_version
  , p_measure_id     => p_perf_measure_id
  , p_time_dimension_level_id => p_time_dim_level_id
  , p_current_row    => p_current_row
  , p_alert_based_on => p_alert_based_on
  , x_target_tbl     => l_target_tbl
  , x_return_status  => x_return_status
  , x_error_Tbl      => x_error_Tbl
  );


  -- Assign all the target info to the Parameter Set Rec and Call
  -- Register_parameter_set procedure

  FOR i IN 1..l_Target_tbl.COUNT LOOP
    BIS_PMF_REG_SERVICE_PVT.Form_Parameter_Set
    ( p_measure_id          => p_perf_measure_id
    , p_time_level_id       => p_time_dim_level_id
    , p_target_tbl          => l_Target_tbl
    , p_Notifiers_Code      => NULL
    , x_Parameter_Set_tbl   => l_param_set_tbl
    );
  END LOOP;

  FOR i IN 1..l_Param_Set_tbl.COUNT LOOP
    BIS_UTILITIES_PUB.put_line(p_text =>'Managing '||i||'th TARGET registrations: '
    ||l_Param_Set_tbl(i).Target_Level_ID);
    BIS_PMF_ALERT_REG_PVT.Manage_Alert_Registrations
    ( p_Param_Set_rec    => l_Param_Set_tbl(i)
    , x_request_scheduled => l_request_scheduled
    , x_return_status    => x_return_status
    , x_error_Tbl        => x_error_Tbl
    );
    --l_debug_text := l_debug_text||': '
    --||'Manage_Alert_Registration Measure: '||l_request_scheduled
    --||' , '||l_return_status;
    BIS_UTILITIES_PUB.put_line(p_text =>'after manag: '||l_debug_text);

    IF l_request_scheduled = FND_API.G_TRUE THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'Request exist');
      l_debug_text := l_debug_text ||': '
        ||BIS_PMF_REG_SERVICE_PVT.G_REQUEST_EXIST;
      l_request_id := BIS_PMF_REG_SERVICE_PVT.G_REQUEST_EXIST;
    ELSE
      --l_debug_text := l_debug_text ||'--process param set debug--'
      --||x_return_status;
      BIS_UTILITIES_PUB.put_line(p_text =>'Managing alert registration by Target result: '
      ||x_return_status);

      BIS_PMF_REG_SERVICE_PVT.Register_Parameter_set
      ( p_api_version    => p_api_version
      , p_Param_Set_Rec  => l_Param_Set_tbl(i)
      , p_request_id     => l_request_id
      , x_return_status  => x_return_status
      , x_error_Tbl      => x_error_Tbl
      );
      ---_debug_text := l_debug_text ||l_request_id;
       BIS_UTILITIES_PUB.put_line(p_text =>'registering target row: '||i||', status: '||x_return_status);
    END IF;
  END LOOP;
-- records from bis_pmf_alert_parameters are retrieved into
-- l_Param_Set_tbl_orig table.
  FOR i IN 1..l_Param_Set_tbl_orig.COUNT LOOP
    BIS_UTILITIES_PUB.put_line(p_text =>'stuffing l_Param_Set_tbl.  i: '||i
      ||', tbl count: '||l_Param_Set_tbl.COUNT);
-- Filter out duplicate records while they are added to l_Param_Set_tbl table
-- from l_Param_Set_tbl_Orig table
-- reset the flag for every record of l_Param_Set_tbl_Orig table
    l_flag := FALSE;
    FOR k IN 1..l_Param_Set_tbl.COUNT LOOP
      IF ( (NVL(l_Param_Set_tbl(k).Target_Level_ID, c_num)  =
            NVL(l_Param_Set_tbl_orig(i).Target_Level_ID, c_num)) AND
           (NVL(l_Param_Set_tbl(k).Plan_ID, c_num) =
            NVL(l_Param_Set_tbl_orig(i).Plan_ID, c_num)) AND
           (NVL(l_Param_Set_tbl(k).TIME_DIMENSION_LEVEL_ID, c_num) =
            NVL(l_Param_Set_tbl_orig(i).TIME_DIMENSION_LEVEL_ID, c_num)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER1_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER1_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER2_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER2_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER3_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER3_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER4_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER4_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER5_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER5_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER6_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER6_VALUE, c_var)) AND
           (NVL(l_Param_Set_tbl(k).PARAMETER7_VALUE, c_var) =
            NVL(l_Param_Set_tbl_orig(i).PARAMETER7_VALUE, c_var))
         ) THEN
        l_flag := TRUE;
        EXIT;
      END IF;
    END LOOP;
    IF NOT (l_flag) THEN
      l_count_param_set_tbl := l_Param_Set_tbl.COUNT+1;
      l_Param_Set_tbl(l_count_param_set_tbl) := l_Param_Set_tbl_orig(i);
    END IF;
  END LOOP;

	BIS_UTILITIES_PUB.put_line(p_text =>'l_Param_Set_tbl_orig.COUNT='||l_Param_Set_tbl_orig.COUNT);
	BIS_UTILITIES_PUB.put_line(p_text =>'l_Param_Set_tbl.COUNT='||l_Param_Set_tbl.COUNT);
	BIS_UTILITIES_PUB.put_line(p_text =>'x_Alert_request_Tbl.COUNT='||x_Alert_request_Tbl.COUNT);

  l_count := x_Alert_request_Tbl.COUNT;
  FOR i IN 1..l_Param_Set_tbl.COUNT LOOP
    IF l_Param_Set_tbl(i).TARGET_LEVEL_ID IS NOT NULL THEN
        l_count := l_count+1;
        x_Alert_request_Tbl(l_count).measure_id  := l_Param_Set_tbl(i).PERFORMANCE_MEASURE_ID;
        x_Alert_request_Tbl(l_count).target_level_id := l_Param_Set_tbl(i).TARGET_LEVEL_ID;
        x_Alert_request_Tbl(l_count).time_level_id := l_Param_Set_tbl(i).TIME_DIMENSION_LEVEL_ID;
        x_Alert_request_Tbl(l_count).plan_id := l_Param_Set_tbl(i).PLAN_ID;
        x_Alert_request_Tbl(l_count).dim1_level_value_id := l_Param_Set_tbl(i).PARAMETER1_VALUE;
        x_Alert_request_Tbl(l_count).dim2_level_value_id := l_Param_Set_tbl(i).PARAMETER2_VALUE;
        x_Alert_request_Tbl(l_count).dim3_level_value_id := l_Param_Set_tbl(i).PARAMETER3_VALUE;
        x_Alert_request_Tbl(l_count).dim4_level_value_id := l_Param_Set_tbl(i).PARAMETER4_VALUE;
        x_Alert_request_Tbl(l_count).dim5_level_value_id := l_Param_Set_tbl(i).PARAMETER5_VALUE;
        x_Alert_request_Tbl(l_count).dim6_level_value_id := l_Param_Set_tbl(i).PARAMETER6_VALUE;
        x_Alert_request_Tbl(l_count).dim7_level_value_id := l_Param_Set_tbl(i).PARAMETER7_VALUE;
        x_Alert_request_Tbl(l_count).alert_type := p_alert_type;
        x_Alert_request_Tbl(l_count).alert_level := p_alert_level;
	x_Alert_request_Tbl(l_count).alert_based_on := p_alert_based_on;
	x_Alert_request_Tbl(l_count).current_row := p_current_row;
    END IF;
  END LOOP;
    BIS_UTILITIES_PUB.put_line(p_text =>'Total number of requests to be submitted: '
    ||x_Alert_request_Tbl.count);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      BIS_UTILITIES_PUB.put_line(p_text =>'Exception at Retrieve_All_Request_Rows: '||sqlerrm);
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PUB.put_line(p_text =>'Exception at Retrieve_All_Request_Rows: '||sqlerrm);
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      BIS_UTILITIES_PUB.put_line(p_text =>'Exception at Retrieve_All_Request_Rows: '||sqlerrm);
			l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => 'Retrieve_All_Request_Rows'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
End Retrieve_All_Request_Rows;


END BIS_ALERT_SERVICE_PVT;

/
