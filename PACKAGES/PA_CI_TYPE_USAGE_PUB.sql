--------------------------------------------------------
--  DDL for Package PA_CI_TYPE_USAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_TYPE_USAGE_PUB" AUTHID CURRENT_USER AS
/* $Header: PACITUPS.pls 120.1 2005/08/19 16:18:51 mwasowic noship $ */

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
);

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
);

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
);

END pa_ci_type_usage_pub;
 

/
