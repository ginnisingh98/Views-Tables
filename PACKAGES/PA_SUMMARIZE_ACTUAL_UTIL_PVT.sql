--------------------------------------------------------
--  DDL for Package PA_SUMMARIZE_ACTUAL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SUMMARIZE_ACTUAL_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: PARRACVS.pls 115.4 2002/03/04 04:51:02 pkm ship     $ */

  PROCEDURE summarize_actual_util;
  PROCEDURE insert_act_into_tmp_PA;
  PROCEDURE insert_act_into_tmp_GL;
  PROCEDURE insert_act_into_tmp_GE;
  PROCEDURE insert_act_into_tmp_PAGL;
  PROCEDURE insert_act_into_tmp_PAGE;
  PROCEDURE insert_act_into_tmp_GLGE;
  PROCEDURE insert_act_into_tmp_PAGLGE;

END PA_SUMMARIZE_ACTUAL_UTIL_PVT;

 

/
