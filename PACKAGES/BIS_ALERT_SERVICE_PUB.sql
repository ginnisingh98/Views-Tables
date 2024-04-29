--------------------------------------------------------
--  DDL for Package BIS_ALERT_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_ALERT_SERVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPALRS.pls 115.12 2003/12/15 14:14:30 arhegde ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPALRS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for Alert Services
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM +=======================================================================+
*/
--
-- Constants
--
/*
G_ALERT_TYPE_REGULAR    CONSTANT VARCHAR2(100) := 'REGULAR';
G_ALERT_TYPE_EXCEPTION  CONSTANT VARCHAR2(100) := 'EXCEPTION';
*/
G_ALERT_LEVEL_PRIVATE   CONSTANT VARCHAR2(100) := 'PRIVATE';
G_ALERT_LEVEL_PUBLIC    CONSTANT VARCHAR2(100) := 'PUBLIC';

G_ALERT_TYPE_ALL_TARGET    CONSTANT VARCHAR2(32000)
  := BIS_PMF_REG_SERVICE_PVT.G_ALL_TARGET;
G_ALERT_TYPE_TARGET_LEVEL  CONSTANT VARCHAR2(32000)
  := BIS_PMF_REG_SERVICE_PVT.G_TARGET_LEVEL;
G_ALERT_TYPE_REPORT_GEN    CONSTANT VARCHAR2(32000)
  := BIS_PMF_REG_SERVICE_PVT.G_REPORT_GEN;

--
-- Procedures
--

-- Required Parameters:
--
--   Measure ID, Short Name: Identifies the Performance Measure
--
-- Other Parameters
--
--   Primary Dim Level ID, Short Name: The dimension level to retrieve
--                                     Targets/Actuals for. i.e. "Month"
--   Other parameters can be ignored for now.
--   (enh. #1270297, 1270301, 1267671, 1270314, 1270318, 1270321, 1270307)
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
, p_alert_type	                        IN VARCHAR2 := NULL
, p_alert_level	                        IN VARCHAR2 := NULL
, p_current_row                 IN VARCHAR2 default NULL
, p_alert_based_on                      IN VARCHAR2 := BIS_CONCURRENT_MANAGER_PVT.C_ALERT_BASED_ON_TARGET
);

END BIS_ALERT_SERVICE_PUB;

 

/
