--------------------------------------------------------
--  DDL for Package BIS_ALERT_SERVICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ALERT_SERVICE_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVALRS.pls 120.1 2005/11/18 05:51:41 ankgoel noship $ */
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
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM | 18-Nov-2005 ankgoel bug# 4675515 DBI Actuals for previous time period |
REM +=======================================================================+
*/

-- Procedures
--
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
, p_dim6_level_id		        IN NUMBER := NULL
, p_dim6_level_short_name	        IN VARCHAR2 := NULL
, p_dim6_level_value_id		        IN VARCHAR2 := NULL
, p_dim7_level_id		        IN NUMBER := NULL
, p_dim7_level_short_name	        IN VARCHAR2 := NULL
, p_dim7_level_value_id		        IN VARCHAR2 := NULL
, p_primary_dim_level_id	        IN NUMBER := NULL
, p_primary_dim_level_short_name	IN VARCHAR2 := NULL
, P_notify_set				IN VARCHAR2 := NULL
, p_alert_type	                        IN VARCHAR2 default NULL
, p_alert_level	                        IN VARCHAR2 default NULL
, p_current_row                         IN VARCHAR2 := 'N'
, p_alert_based_on                      IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
);

Procedure Service_Alert_Request_Pvt
( ERRBUF			        OUT NOCOPY VARCHAR2
, RETCODE			        OUT NOCOPY VARCHAR2
, p_measure_id				IN NUMBER  := NULL
, p_measure_short_name			IN VARCHAR2  := NULL
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
, p_alert_type	                        IN VARCHAR2 default NULL
, p_alert_level	                        IN VARCHAR2 default NULL
, p_current_row                         IN VARCHAR2 := NULL
);

--
-- Data Types: Records
--
TYPE Alert_Request_Rec_Type IS RECORD
( measure_id			NUMBER
, measure_short_name		VARCHAR2(240)
, target_level_id		NUMBER
, target_level_short_name	VARCHAR2(240)
, plan_id			NUMBER
, org_level_id			NUMBER
, org_level_short_name		VARCHAR2(240)
, organization_id		VARCHAR2(240)
, time_level_id			NUMBER
, time_level_short_name		VARCHAR2(240)
, time_level_value_id		VARCHAR2(240)
, dim1_level_id			NUMBER
, dim1_level_short_name		VARCHAR2(240)
, dim1_level_value_id		VARCHAR2(240)
, dim2_level_id			NUMBER
, dim2_level_short_name		VARCHAR2(240)
, dim2_level_value_id		VARCHAR2(240)
, dim3_level_id			NUMBER
, dim3_level_short_name		VARCHAR2(240)
, dim3_level_value_id		VARCHAR2(240)
, dim4_level_id			NUMBER
, dim4_level_short_name		VARCHAR2(240)
, dim4_level_value_id		VARCHAR2(240)
, dim5_level_id			NUMBER
, dim5_level_short_name		VARCHAR2(240)
, dim5_level_value_id		VARCHAR2(240)
, dim6_level_id			NUMBER
, dim6_level_short_name		VARCHAR2(240)
, dim6_level_value_id		VARCHAR2(240)
, dim7_level_id			NUMBER
, dim7_level_short_name		VARCHAR2(240)
, dim7_level_value_id		VARCHAR2(240)
, target_id			NUMBER
, target			NUMBER
, actual_id			NUMBER
, actual			NUMBER
, primary_dim_level_id		NUMBER
, primary_dim_level_short_name 	VARCHAR2(240)
, notify_set			VARCHAR2(240)
, alert_type	                VARCHAR2(32000)
, alert_level	                VARCHAR2(32000)
, alert_based_on                VARCHAR2(32000)
, current_row                   VARCHAR2(10)
);

--
-- Data Types: Tables
--
TYPE Alert_Request_Tbl_Type IS TABLE OF Alert_Request_Rec_Type
INDEX BY BINARY_INTEGER;

Procedure Form_Alert_Request_rec
( p_target_level_rec       IN BIS_Target_level_PUB.Target_level_rec_Type
, p_target_rec             IN BIS_Target_PUB.Target_rec_Type
, p_dimension_level_rec    IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_notify_set	           IN VARCHAR2  := NULL
, p_alert_type	           IN VARCHAR2  := NULL
, p_alert_level	           IN VARCHAR2  := NULL
, x_Alert_Request_rec      OUT NOCOPY Alert_Request_rec_Type
);

Procedure Form_Concurrent_Request
( p_Alert_Request_Tbl      IN Alert_Request_Tbl_Type
, x_Concurrent_Request_Tbl
    OUT NOCOPY BIS_CONCURRENT_MANAGER_PVT.PMF_Request_Tbl_Type
);

END BIS_ALERT_SERVICE_PVT;

 

/
