--------------------------------------------------------
--  DDL for Package PA_CI_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: PACISECS.pls 120.1 2007/02/08 11:53:23 sukhanna ship $ */

FUNCTION check_proj_auth_ci(
  p_project_id NUMBER,
  p_user_id NUMBER,
  p_resp_id NUMBER)
RETURN VARCHAR2;

FUNCTION check_view_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_view_access(
  p_ci_id NUMBER,
  p_project_id NUMBER,
  p_sys_stat_code VARCHAR2,
  p_ci_type_class_code VARCHAR2,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_update_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_update_access1(
  p_ci_id NUMBER,
  p_project_id NUMBER,
  p_proj_org_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_change_owner_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_change_status_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_highlight_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id,
  p_project_id NUMBER DEFAULT NULL)
RETURN VARCHAR2;

FUNCTION check_implement_impact_access(
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_item_owner_project_auth(
            p_ci_id in NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
RETURN VARCHAR2;

FUNCTION check_open_action_assigned_to(
            p_ci_action_id  IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
RETURN VARCHAR2;

FUNCTION check_create_action(
            p_ci_id IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id,
            p_calling_context IN VARCHAR2 DEFAULT 'UI') --bug 5676037.
RETURN VARCHAR2;

FUNCTION check_updatable_comment(
            p_ci_comment_id  IN NUMBER,
            p_user_id IN NUMBER DEFAULT fnd_global.user_id)
RETURN varchar2;

FUNCTION check_create_CI(
  p_ci_type_id NUMBER,
  p_project_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_view_project(
  p_project_id NUMBER,
  p_ci_id NUMBER,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION check_view_project(
  p_project_id NUMBER,
  p_ci_id NUMBER,
  p_ci_type_class_code VARCHAR2,
  p_user_id NUMBER DEFAULT fnd_global.user_id,
  p_resp_id NUMBER DEFAULT fnd_global.resp_id)
RETURN VARCHAR2;

FUNCTION is_to_owner_allowed(
  p_ci_id NUMBER,
  p_owner_id NUMBER)
RETURN VARCHAR2;

END pa_ci_security_pkg;

/
