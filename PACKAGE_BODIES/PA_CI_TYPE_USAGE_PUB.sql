--------------------------------------------------------
--  DDL for Package Body PA_CI_TYPE_USAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_TYPE_USAGE_PUB" AS
/* $Header: PACITUPB.pls 120.1 2005/08/19 16:18:47 mwasowic noship $ */

PROCEDURE create_ci_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_project_type		IN VARCHAR2 := NULL,
  p_project_type_id		IN NUMBER := NULL,
  p_ci_type_name		IN VARCHAR2 := NULL,
  p_ci_type_id			IN NUMBER := NULL,
  p_created_by			IN NUMBER DEFAULT fnd_global.user_id,
  p_creation_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.login_id,
  x_ci_type_usage_id		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_error_message_code VARCHAR2(100);
  l_project_type_id NUMBER := p_project_type_id;
  l_ci_type_id NUMBER := p_ci_type_id;
BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPE_USAGE_PUB.CREATE_CI_TYPE_USAGE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT create_ci_type_usage;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_project_type_id IS NULL THEN
    BEGIN
      SELECT project_type_id
      INTO l_project_type_id
      FROM pa_project_types_all
      WHERE project_type like p_project_type
        AND TRUNC(sysdate) BETWEEN TRUNC(start_date_active)
                               AND TRUNC(NVL(end_date_active, sysdate));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
      WHEN TOO_MANY_ROWS THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
    END;
  END IF;

  IF x_return_status = 'S' THEN
    pa_ci_types_util.check_ci_type_name_or_id(
      p_name => p_ci_type_name,
      p_ci_type_id => p_ci_type_id,
      p_check_id_flag => 'N',
      x_ci_type_id => l_ci_type_id,
      x_return_status => x_return_status,
      x_error_message_code => l_error_message_code);

    IF x_return_status <> 'S' THEN
      fnd_message.set_name('PA', l_error_message_code);
      fnd_msg_pub.add();
    END IF;

  END IF;

  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_ci_type_usage_pvt.create_ci_type_usage (
      p_init_msg_list => 'F',
      p_commit => 'F',
      p_validate_only => 'F',
      p_max_msg_count => p_max_msg_count,
      p_project_type_id => l_project_type_id,
      p_ci_type_id => l_ci_type_id,
      p_created_by => p_created_by,
      p_creation_date => p_creation_date,
      p_last_update_login => p_last_update_login,
      x_ci_type_usage_id => x_ci_type_usage_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO create_ci_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO create_ci_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPE_USAGE_PUB',
                            p_procedure_name => 'CREATE_CI_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_ci_type_usage;

PROCEDURE update_ci_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_type_usage_id            IN NUMBER,
  p_project_type		IN VARCHAR2 := NULL,
  p_project_type_id		IN NUMBER := NULL,
  p_ci_type_name		IN VARCHAR2 := NULL,
  p_ci_type_id			IN NUMBER := NULL,
  p_last_updated_by     	IN NUMBER DEFAULT fnd_global.user_id,
  p_last_update_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.user_id,
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_error_message_code VARCHAR2(100);
  l_project_type_id NUMBER := p_project_type_id;
  l_ci_type_id NUMBER := p_ci_type_id;
BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPE_USAGE_PUB.UPDATE_CI_TYPE_USAGE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT update_ci_type_usage;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_project_type_id IS NULL THEN
    BEGIN
      SELECT project_type_id
      INTO l_project_type_id
      FROM pa_project_types_all
      WHERE project_type like p_project_type
        AND TRUNC(sysdate) BETWEEN TRUNC(start_date_active)
                               AND TRUNC(NVL(end_date_active, sysdate));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
      WHEN TOO_MANY_ROWS THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
    END;
  END IF;

  IF x_return_status = 'S' THEN
    pa_ci_types_util.check_ci_type_name_or_id(
      p_name => p_ci_type_name,
      p_ci_type_id => p_ci_type_id,
      p_check_id_flag => 'N',
      x_ci_type_id => l_ci_type_id,
      x_return_status => x_return_status,
      x_error_message_code => l_error_message_code);

    IF x_return_status <> 'S' THEN
      fnd_message.set_name('PA', l_error_message_code);
      fnd_msg_pub.add();
    END IF;

  END IF;

  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_ci_type_usage_pvt.update_ci_type_usage (
      p_init_msg_list => 'F',
      p_commit => 'F',
      p_validate_only => 'F',
      p_max_msg_count => p_max_msg_count,
      p_ci_type_usage_id => p_ci_type_usage_id,
      p_project_type_id => l_project_type_id,
      p_ci_type_id => l_ci_type_id,
      p_last_update_date => p_last_update_date,
      p_last_updated_by => p_last_updated_by,
      p_last_update_login => p_last_update_login,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO update_ci_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO update_ci_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPE_USAGE_PUB',
                            p_procedure_name => 'UPDATE_CI_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END update_ci_type_usage;

PROCEDURE delete_ci_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_type_usage_id		IN NUMBER,
  p_project_type		IN VARCHAR2 := NULL,
  p_project_type_id		IN NUMBER := NULL,
  p_ci_type_name		IN VARCHAR2 := NULL,
  p_ci_type_id			IN NUMBER := NULL,
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_error_message_code VARCHAR2(100);
  l_project_type_id NUMBER := p_project_type_id;
  l_ci_type_id NUMBER := p_ci_type_id;
BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPE_USAGE_PUB.DELETE_CI_TYPE_USAGE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_ci_type_usage;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';


  IF p_project_type_id IS NULL THEN
    BEGIN
      SELECT project_type_id
      INTO l_project_type_id
      FROM pa_project_types_all
      WHERE project_type like p_project_type
        AND TRUNC(sysdate) BETWEEN TRUNC(start_date_active)
                               AND TRUNC(NVL(end_date_active, sysdate));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
      WHEN TOO_MANY_ROWS THEN
        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_PROJ_TYPE_INV_AMBIGUOUS');
        fnd_msg_pub.add();
    END;
  END IF;

  IF x_return_status = 'S' THEN
    pa_ci_types_util.check_ci_type_name_or_id(
      p_name => p_ci_type_name,
      p_ci_type_id => p_ci_type_id,
      p_check_id_flag => 'N',
      x_ci_type_id => l_ci_type_id,
      x_return_status => x_return_status,
      x_error_message_code => l_error_message_code);

    IF x_return_status <> 'S' THEN
      fnd_message.set_name('PA', l_error_message_code);
      fnd_msg_pub.add();
    END IF;

  END IF;

  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_ci_type_usage_pvt.delete_ci_type_usage (
      p_init_msg_list => 'F',
      p_commit => 'F',
      p_validate_only => 'F',
      p_max_msg_count => p_max_msg_count,
      p_ci_type_usage_id => p_ci_type_usage_id,
      p_project_type_id => l_project_type_id,
      p_ci_type_id => l_ci_type_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_ci_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_ci_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPES_PUB',
                            p_procedure_name => 'DELETE_CI_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_ci_type_usage;

END pa_ci_type_usage_pub;

/
