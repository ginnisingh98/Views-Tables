--------------------------------------------------------
--  DDL for Package Body PA_CI_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_TYPES_UTIL" AS
/* $Header: PACITYUB.pls 120.2 2005/08/22 05:17:26 sukhanna noship $ */

FUNCTION check_ci_type_name_exists(
  p_name VARCHAR2,
  p_short_name VARCHAR2,
  p_ci_type_id NUMBER default NULL
) RETURN BOOLEAN
IS
  l_temp VARCHAR2(1);
BEGIN
  SELECT 'X'
  INTO l_temp
  FROM pa_ci_types_vl
  WHERE (name = p_name
         OR short_name = p_short_name)
    AND (p_ci_type_id IS NULL
         OR ci_type_id <> p_ci_type_id);

  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END check_ci_type_name_exists;

PROCEDURE check_ci_type_name_or_id(
  p_name IN VARCHAR2,
  p_ci_type_id IN NUMBER,
  p_check_id_flag IN VARCHAR2 := pa_startup.G_check_id_flag,
  x_ci_type_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_message_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_sysdate DATE := TRUNC(sysdate);
  l_ci_type_id  NUMBER(15); --Added for bug#4565156
BEGIN
  pa_debug.init_err_stack ('pa_ci_types_util.check_ci_type_name_or_id');

  x_return_status := 'S';
  x_error_message_code := NULL;

  l_ci_type_id := x_ci_type_id; --Added for bug#4565156

  IF p_ci_type_id IS NOT NULL THEN
    IF p_check_id_flag <> 'N' THEN
      SELECT ci_type_id
      INTO x_ci_type_id
      FROM pa_ci_types_b
      WHERE ci_type_id = p_ci_type_id
        AND l_sysdate BETWEEN TRUNC(start_date_active)
                          AND TRUNC(NVL(end_date_active, sysdate));
    ELSE
      x_ci_type_id := p_ci_type_id;
    END IF;
  ELSE
    SELECT ci_type_id
    INTO x_ci_type_id
    FROM pa_ci_types_vl
    WHERE name like p_name
      AND l_sysdate BETWEEN TRUNC(start_date_active)
                        AND TRUNC(NVL(end_date_active, sysdate));
  END IF;

  pa_debug.reset_err_stack;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_CI_TYPE_INVALID_AMBIGUOUS';
  WHEN TOO_MANY_ROWS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_CI_TYPE_INVALID_AMBIGUOUS';
  WHEN OTHERS THEN
    x_ci_type_id := l_ci_type_id; --Added for bug#4565156
    fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_CI_TYPES_UTIL',
       p_procedure_name => pa_debug.g_err_stack );
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
END check_ci_type_name_or_id;

END pa_ci_types_util;

/
