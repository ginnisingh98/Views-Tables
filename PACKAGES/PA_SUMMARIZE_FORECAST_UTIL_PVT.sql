--------------------------------------------------------
--  DDL for Package PA_SUMMARIZE_FORECAST_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SUMMARIZE_FORECAST_UTIL_PVT" 
-- $Header: PARRFCVS.pls 115.4 2002/03/04 04:51:08 pkm ship     $
AUTHID CURRENT_USER AS

 PROCEDURE Summarize_Forecast_Util;
 PROCEDURE Insert_Fcst_Into_Tmp_PA;
 PROCEDURE Insert_Fcst_Into_Tmp_GL;
 PROCEDURE Insert_Fcst_Into_Tmp_GE;
 PROCEDURE Insert_Fcst_Into_Tmp_PAGL;
 PROCEDURE Insert_Fcst_Into_Tmp_PAGE;
 PROCEDURE Insert_Fcst_Into_Tmp_GLGE;
 PROCEDURE Insert_Fcst_Into_Tmp_PAGLGE;

END PA_SUMMARIZE_FORECAST_UTIL_PVT;

 

/
