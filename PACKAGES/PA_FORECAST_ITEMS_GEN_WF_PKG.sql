--------------------------------------------------------
--  DDL for Package PA_FORECAST_ITEMS_GEN_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_ITEMS_GEN_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: PARFIWFS.pls 120.1 2005/08/19 16:52:01 mwasowic noship $ */

PROCEDURE Launch_WorkFlow_Fi_Gen          ( p_assignment_id     IN     NUMBER,
                                            p_resource_id       IN     NUMBER,
                                            p_start_date        IN     DATE,
                                            p_end_date          IN     DATE,
                                            p_process_mode      IN     VARCHAR2,
                                            x_return_status     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                            x_msg_count         OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                            x_msg_data          OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


--
-- Procedure            : Launch_WorkFlow_Fi_Gen
-- Purpose              : This procedure will launch the work flow for forecast item generation.
-- Parameters           :
--


PROCEDURE Start_Forecast_WF ( p_item_type	IN 	VARCHAR2,
                              p_item_key	IN 	VARCHAR2,
                              p_actid	        IN 	NUMBER,
                              p_funcmode	IN 	VARCHAR2,
                              p_result	        OUT 	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



--
-- Procedure            : Start_Forecast_WF
-- Purpose              : This procedure will start the work flow processing.
-- Parameters           :
--


END PA_FORECAST_ITEMS_GEN_WF_PKG;
 

/
