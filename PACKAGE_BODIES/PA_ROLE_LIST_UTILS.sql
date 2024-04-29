--------------------------------------------------------
--  DDL for Package Body PA_ROLE_LIST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_LIST_UTILS" AS
 /* $Header: PARLSTUB.pls 120.1 2005/08/19 16:55:46 mwasowic noship $ */

--Public procedure to check role list name and id
PROCEDURE check_role_list_name_or_id(
  p_role_list_id IN NUMBER,
  p_role_list_name IN VARCHAR2,
  p_check_id_flag IN VARCHAR2,
  x_role_list_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_message_code OUT NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
  l_sysdate DATE := TRUNC(sysdate);
BEGIN
  pa_debug.init_err_stack ('pa_role_list_utils.check_role_list_name_or_id');

  IF p_role_list_id IS NOT NULL AND p_role_list_id <> FND_API.G_MISS_NUM THEN
    IF p_check_id_flag <> 'N' THEN
      SELECT role_list_id
      INTO x_role_list_id
      FROM pa_role_lists
      WHERE role_list_id = p_role_list_id
      AND TRUNC(start_date_active) <= l_sysdate
      AND (end_date_active IS NULL OR l_sysdate <= TRUNC(end_date_active));
    ELSE
      x_role_list_id := p_role_list_id;
    END IF;
  ELSE
    SELECT role_list_id
    INTO x_role_list_id
    FROM pa_role_lists
    WHERE name = p_role_list_name
    AND TRUNC(start_date_active) <= l_sysdate
    AND (end_date_active IS NULL OR l_sysdate <= TRUNC(end_date_active));
  END IF;
  x_return_status := fnd_api.g_ret_sts_success;
  x_error_message_code := NULL;
  pa_debug.reset_err_stack;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_ROLE_LIST_INVALID_AMBIGOUS';
  WHEN TOO_MANY_ROWS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_ROLE_LIST_INVALID_AMBIGOUS';
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_ROLE_LIST_UTILS',
       p_procedure_name => pa_debug.g_err_stack );
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END check_role_list_name_or_id;

END PA_ROLE_LIST_UTILS;

/
