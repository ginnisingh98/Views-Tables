--------------------------------------------------------
--  DDL for Package BIS_PMV_SESSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_SESSION_PVT" AUTHID CURRENT_USER as
/* $Header: BISVSESS.pls 115.5 2002/10/31 03:21:10 amkulkar noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE
TYPE session_rec_type IS RECORD
(function_name		VARCHAR2(32000)
,region_code     	VARCHAR2(32000)
,page_id                VARCHAR2(32000)
,session_id             VARCHAR2(32000)
,user_id 	        VARCHAR2(32000)
,responsibility_id      VARCHAR2(32000)
,schedule_id            NUMBER
);
end BIS_PMV_SESSION_PVT;

 

/
