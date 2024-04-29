--------------------------------------------------------
--  DDL for Package Body PA_TASK_PROG_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_PROG_INQUIRY_PKG" as
/* $Header: PATPINQB.pls 120.1 2005/08/19 17:04:47 mwasowic noship $ */

PROCEDURE debug(p_msg IN VARCHAR2) IS
BEGIN
--  dbms_output.put_line(p_msg);
  NULL;
END;

PROCEDURE request_single_task(
  p_api_version	  IN NUMBER :=  1.0,
  p_init_msg_list IN VARCHAR2 := fnd_api.g_true,
  p_commit        IN VARCHAR2 := fnd_api.g_false,
  p_validate_only IN VARCHAR2 := fnd_api.g_true,
  p_max_msg_count IN NUMBER   := fnd_api.g_miss_num,
  p_task_id       IN NUMBER   := fnd_api.g_miss_num,
  p_project_manager_id IN NUMBER  := NULL,
  x_action_line_audit_tbl OUT NOCOPY pa_action_set_utils.insert_audit_lines_tbl_type, --File.Sql.39 bug 4440895
  x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data              OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
  NULL;
END request_single_task;

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
  x_msg_data              OUT NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
BEGIN
  NULL;
END request_all_tasks_in_project;



PROCEDURE get_notification_mode(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  funcmode IN VARCHAR2,
  result   OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
  NULL;
END get_notification_mode;

PROCEDURE callback(
  itemtype IN VARCHAR2,
  itemkey  IN VARCHAR2,
  actid    IN NUMBER,
  command  IN VARCHAR2,
  result   IN OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
  NULL;
END callback;

PROCEDURE launch_request
IS
BEGIN
  NULL;
END launch_request;

PROCEDURE launch_single_project(p_project_id IN NUMBER)
IS
BEGIN
  NULL;
END launch_single_project;

PROCEDURE launch_single_task(p_task_id IN NUMBER)
IS
BEGIN
  NULL;
END launch_single_task;

END;


/
