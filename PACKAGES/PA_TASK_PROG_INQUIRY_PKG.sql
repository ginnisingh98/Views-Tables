--------------------------------------------------------
--  DDL for Package PA_TASK_PROG_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_PROG_INQUIRY_PKG" AUTHID CURRENT_USER as
/* $Header: PATPINQS.pls 120.1 2005/08/19 17:04:51 mwasowic noship $ */

g_action_line_audit_tbl pa_action_set_utils.insert_audit_lines_tbl_type;

PROCEDURE request_single_task(
  p_api_version	  IN NUMBER :=  1.0,
  p_init_msg_list IN VARCHAR2 := fnd_api.g_true,
  p_commit        IN VARCHAR2 := fnd_api.g_false,
  p_validate_only IN VARCHAR2 := fnd_api.g_true,
  p_max_msg_count IN NUMBER := fnd_api.g_miss_num,
  p_task_id       IN NUMBER := fnd_api.g_miss_num,
  p_project_manager_id    IN NUMBER := NULL,
  x_action_line_audit_tbl OUT NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type, --File.Sql.39 bug 4440895
  x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE request_all_tasks_in_project(
  p_api_version	  IN NUMBER :=  1.0,
  p_init_msg_list IN VARCHAR2 := FND_API.G_TRUE,
  p_commit        IN VARCHAR2 := FND_API.G_FALSE,
  p_validate_only IN VARCHAR2 := FND_API.G_TRUE,
  p_max_msg_count IN NUMBER := FND_API.G_MISS_NUM,
  p_project_id    IN  NUMBER := FND_API.G_MISS_NUM,
  x_action_line_audit_tbl OUT NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type, --File.Sql.39 bug 4440895
  x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_notification_mode(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE callback(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  command  IN VARCHAR2,
  result   IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE launch_request;
PROCEDURE launch_single_project(p_project_id IN NUMBER);
PROCEDURE launch_single_task(p_task_id IN NUMBER);

END;


 

/
