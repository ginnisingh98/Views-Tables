--------------------------------------------------------
--  DDL for Package Body BIS_ALERT_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_ALERT_SERVICE_PUB" AS
/* $Header: BISPALRB.pls 115.16 2003/12/15 14:15:43 arhegde ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPALRB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for Alert Services
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM| 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM|                   parameters (bug#2758428)              	           |
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM +=======================================================================+
*/
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_ALERT_SERVICE_PUB';
--
-- Procedures
--
Procedure Service_Alert_Request
( ERRBUF			        OUT NOCOPY VARCHAR2
, RETCODE			        OUT NOCOPY VARCHAR2
, p_measure_id				IN NUMBER
, p_measure_short_name			IN VARCHAR2
, p_plan_id				IN NUMBER default NULL
, p_org_level_id		        IN NUMBER default NULL
, p_org_level_short_name	        IN VARCHAR2 default NULL
, p_organization_id			IN VARCHAR2 default NULL
, p_time_level_id		        IN NUMBER default NULL
, p_time_level_short_name		IN VARCHAR2 default NULL
, p_time_level_value_id			IN VARCHAR2 default NULL
, p_dim1_level_id		        IN NUMBER default NULL
, p_dim1_level_short_name	        IN VARCHAR2 default NULL
, p_dim1_level_value_id			IN VARCHAR2 default NULL
, p_dim2_level_id			IN NUMBER default NULL
, p_dim2_level_short_name		IN VARCHAR2 default NULL
, p_dim2_level_value_id			IN VARCHAR2 default NULL
, p_dim3_level_id			IN NUMBER default NULL
, p_dim3_level_short_name		IN VARCHAR2 default NULL
, p_dim3_level_value_id			IN VARCHAR2 default NULL
, p_dim4_level_id			IN NUMBER default NULL
, p_dim4_level_short_name		IN VARCHAR2 default NULL
, p_dim4_level_value_id			IN VARCHAR2 default NULL
, p_dim5_level_id			IN NUMBER default NULL
, p_dim5_level_short_name		IN VARCHAR2 default NULL
, p_dim5_level_value_id			IN VARCHAR2 default NULL
, p_dim6_level_id		        IN NUMBER := NULL
, p_dim6_level_short_name	        IN VARCHAR2 := NULL
, p_dim6_level_value_id		        IN VARCHAR2 := NULL
, p_dim7_level_id		        IN NUMBER := NULL
, p_dim7_level_short_name	        IN VARCHAR2 := NULL
, p_dim7_level_value_id		        IN VARCHAR2 := NULL
, p_primary_dim_level_id		IN NUMBER default NULL
, p_primary_dim_level_short_name	IN VARCHAR2 default NULL
, P_notify_set				IN VARCHAR2 default NULL
, p_alert_type	                        IN VARCHAR2 default NULL
, p_alert_level	                        IN VARCHAR2 default NULL
, p_current_row                         IN VARCHAR2 default NULL
, p_alert_based_on                      IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
)
IS

  l_Measure_Rec   BIS_MEASURE_PUB.Measure_Rec_Type;
  l_measure_rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
  l_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status      VARCHAR2(1000);
  l_return_msg         VARCHAR2(32000);

BEGIN

  -- Debug messages should be printed irrespective of debug profile option.
  bis_utilities_pvt.set_debug_log_flag (  -- 2715218
    p_is_true         => TRUE
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  ) ;

  -- fnd_file.put_line(fnd_file.log, ' Return status is = ' || nvl(l_return_status, 'X!!') );


  BIS_UTILITIES_PUB.put_line(p_text => ' ------- Begin log file for SONAR parent request. ------- ');

  l_Measure_Rec.Measure_id := p_measure_id;
  l_Measure_Rec.Measure_short_name := p_measure_short_name;

  IF (BIS_UTILITIES_PUB.Value_Missing
         (l_Measure_Rec.Measure_id) = FND_API.G_TRUE
     OR BIS_UTILITIES_PUB.Value_NULL(l_Measure_Rec.Measure_id)
                                    = FND_API.G_TRUE) then
     l_measure_rec_p := l_measure_rec;
     BIS_Measure_PVT.Value_ID_Conversion
         ( p_api_version   => 1.0
	 , p_Measure_Rec   => l_measure_rec_p
	 , x_Measure_Rec   => l_Measure_Rec
	 , x_return_status => l_return_status
	 , x_error_Tbl     => l_error_Tbl
	 );
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text => 'Requested Measure short name : '||l_Measure_Rec.Measure_short_name );

  BIS_ALERT_SERVICE_PVT.Service_Alert_Request
  ( ERRBUF                          => ERRBUF
  , RETCODE                         => RETCODE
  , p_measure_id                    => l_Measure_Rec.Measure_id
  , p_measure_short_name            => l_Measure_Rec.measure_short_name
  , p_plan_id                       => p_plan_id
  , p_org_level_id                  => p_org_level_id
  , p_org_level_short_name          => p_org_level_short_name
  , p_organization_id               => p_organization_id
  , p_time_level_id                 => p_time_level_id
  , p_time_level_short_name         => p_time_level_short_name
  , p_time_level_value_id           => p_time_level_value_id
  , p_dim1_level_id                 => p_dim1_level_id
  , p_dim1_level_short_name         => p_dim1_level_short_name
  , p_dim1_level_value_id           => p_dim1_level_value_id
  , p_dim2_level_id                 => p_dim2_level_id
  , p_dim2_level_short_name         => p_dim2_level_short_name
  , p_dim2_level_value_id           => p_dim2_level_value_id
  , p_dim3_level_id                 => p_dim3_level_id
  , p_dim3_level_short_name         => p_dim3_level_short_name
  , p_dim3_level_value_id           => p_dim3_level_value_id
  , p_dim4_level_id                 => p_dim4_level_id
  , p_dim4_level_short_name         => p_dim4_level_short_name
  , p_dim4_level_value_id           => p_dim4_level_value_id
  , p_dim5_level_id                 => p_dim5_level_id
  , p_dim5_level_short_name         => p_dim5_level_short_name
  , p_dim5_level_value_id           => p_dim5_level_value_id
  , p_dim6_level_id                 => p_dim6_level_id
  , p_dim6_level_short_name         => p_dim6_level_short_name
  , p_dim6_level_value_id           => p_dim6_level_value_id
  , p_dim7_level_id                 => p_dim7_level_id
  , p_dim7_level_short_name         => p_dim7_level_short_name
  , p_dim7_level_value_id           => p_dim7_level_value_id
  , p_primary_dim_level_id          => p_primary_dim_level_id
  , p_primary_dim_level_short_name  => p_primary_dim_level_short_name
  , P_notify_set                    => P_notify_set
  , p_alert_type                    => p_alert_type
  , p_alert_level                   => p_alert_level
  , p_current_row                   => p_current_row
  , p_alert_based_on                => p_alert_based_on
  );

  BIS_UTILITIES_PUB.put_line(p_text => ' ------- End log file for SONAR parent request. ------- ');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      return;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      return;
   when others then
      RETCODE := 1;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      return;

END Service_Alert_Request;

END BIS_ALERT_SERVICE_PUB;

/
