--------------------------------------------------------
--  DDL for Package BIS_GRAPH_REGION_UI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_GRAPH_REGION_UI" AUTHID CURRENT_USER AS
/* $Header: BISCHRUS.pls 120.1 2006/02/02 02:06:51 nbarik noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISCHRUS.pls
---
---  DESCRIPTION
---     Package Specification File with data manipulation functions
---     for the three html forms in which to
---     enter parameters to be stored for a PHP Chart
---
---  NOTES
---
---  HISTORY
---
---  20-Jun-2000 Walid.Nasrallah Created
---  05-Oct-2000 Walid.Nasrallah moved "WHO" column defintion to database
---  10-Oct-2000 Walid.Nasrallah defined cookie domain name as global const
---
---
---
---===========================================================================

G_COOKIE_NAME     constant varchar2(100) := 'BIS_GRAPH_REGION_DEFINE';
G_COOKIE_PREFIX   constant varchar2(100) := 'GOOD_COOKIE';
G_SEP             constant varchar2(10)  := '*';
G_DOMAIN          constant varchar2(2000) := '.oracle.com';

-- *********************************************
-- PROCEDURES to preserve session_user state
-- *****************************************

FUNCTION def_mode_query
  return boolean;

PROCEDURE def_mode_set
  (cookie_code   IN pls_integer);

PROCEDURE def_mode_get
  (  p_session_id    IN PLS_INTEGER
   , x_record        OUT NOCOPY BIS_USER_TREND_PLUGS%ROWTYPE
    );

PROCEDURE def_mode_clear
  (p_coded_string  IN  varchar2);


PROCEDURE Review_Chart_Action
  (  p_where               in  PLS_INTEGER
   , p_plug_id             in  PLS_INTEGER
   , p_user_id             in  PLS_INTEGER
   , p_function_id         in  PLS_INTEGER
   , p_responsibility_id   in  PLS_INTEGER
   , p_chart_user_title    in  VARCHAR2
   , p_parameter_string    in  VARCHAR2
     );

END BIS_GRAPH_REGION_UI;

 

/
