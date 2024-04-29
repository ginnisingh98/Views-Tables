--------------------------------------------------------
--  DDL for Package PA_FORECAST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FORECAST_WF" AUTHID CURRENT_USER AS
/* $Header: PAWFGFCS.pls 120.1 2005/08/19 17:07:40 mwasowic noship $*/

	PROCEDURE start_forecast_workflow(p_project_id		 IN  NUMBER
                                          , x_msg_count	         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 			                  , x_msg_data	         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			                  , x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                          );

        PROCEDURE process_forecast(itemtype   IN  VARCHAR2
                                  , itemkey   IN  VARCHAR2
                                  , actid     IN  NUMBER
                                  , funcmode  IN  VARCHAR2
                                  , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  );



END pa_forecast_wf;
 

/
