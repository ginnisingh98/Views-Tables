--------------------------------------------------------
--  DDL for Package PA_TIME_CHART_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIME_CHART_PKG" AUTHID CURRENT_USER as
/*$Header: PARLPKGS.pls 120.1 2005/08/19 16:55:33 mwasowic noship $*/

/*
PROCEDURE insert_row (p_time_chart_tab  PA_TIMELINE_GLOB.TimeChartTabTyp,
            x_return_status     OUT VARCHAR2,
            x_msg_count         OUT NUMBER,
            x_msg_data          OUT VARCHAR2);
*/

PROCEDURE delete_row ( x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_TIME_CHART_PKG;

 

/
