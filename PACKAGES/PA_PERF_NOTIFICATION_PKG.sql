--------------------------------------------------------
--  DDL for Package PA_PERF_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERF_NOTIFICATION_PKG" AUTHID CURRENT_USER AS
/* $Header: PAPFNTFS.pls 120.1 2005/08/19 16:40:32 mwasowic noship $ */

PROCEDURE START_PERF_NOTIFICATION_WF(
             p_item_type	In	VARCHAR2
	    ,p_process_name	In	VARCHAR2
	    ,p_project_id	In	pa_projects_all.project_id%TYPE
	    ,x_item_key	        Out	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	    ,x_return_status	Out     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	    ,x_msg_count 	Out     NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data 	Out     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE SET_PERF_NOTIFY_WF_ATTRIBUTES
      (  p_item_type	    In		VARCHAR2
	,p_process_name	    In		VARCHAR2
	,p_project_id	    In		pa_projects_all.project_id%TYPE
	,p_item_key	    In		NUMBER
        ,x_return_status    Out		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count	    Out		NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data	    Out		NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_PERF_NOTIFICATION_PKG;

 

/
