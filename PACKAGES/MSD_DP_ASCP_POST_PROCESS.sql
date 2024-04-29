--------------------------------------------------------
--  DDL for Package MSD_DP_ASCP_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_DP_ASCP_POST_PROCESS" AUTHID CURRENT_USER AS
/* $Header: msddapps.pls 120.0 2005/05/25 19:01:54 appldev noship $ */

  procedure launch   (p_plan_id  in NUMBER,
		      p_calc_liability in NUMBER);



END MSD_DP_ASCP_POST_PROCESS;

 

/
