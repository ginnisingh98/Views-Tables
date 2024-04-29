--------------------------------------------------------
--  DDL for Package PA_PROJECT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_WF" AUTHID CURRENT_USER as
/* $Header: PAWFPRVS.pls 120.1 2005/08/19 17:07:55 mwasowic noship $ */

PROCEDURE select_project_approver ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					resultout	out NOCOPY varchar2	); --File.Sql.39 bug 4440895

PROCEDURE Start_Project_Wf (p_project_id  IN NUMBER,
                            p_err_stack  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_stage  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_code   OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE Set_Success_status
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Set_Failure_status
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Verify_status_change_rules
  (itemtype                      IN      VARCHAR2
  ,itemkey                       IN      VARCHAR2
  ,actid                         IN      NUMBER
  ,funcmode                      IN      VARCHAR2
  ,resultout                     OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Wf_Status_failure (x_project_id IN NUMBER,
                             x_failure_status_code IN VARCHAR2,
                             x_item_type IN VARCHAR2,
                             x_item_key  IN VARCHAR2,
                             x_populate_msg_yn IN VARCHAR2,
			     x_update_db_yn IN VARCHAR2,
                             x_err_code  OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895


PROCEDURE Get_proj_status_attributes (x_item_type IN VARCHAR2,
                                      x_item_key  IN VARCHAR2,
                                      x_success_proj_stus_code OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_failure_proj_stus_code OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_err_code  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_err_stage OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895


PROCEDURE  validate_changes  (x_project_id            IN NUMBER,
                              x_success_status_code   IN VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_err_stage            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_wf_enabled_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_verify_ok_flag       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

end pa_project_wf;

 

/
