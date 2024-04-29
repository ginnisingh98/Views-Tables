--------------------------------------------------------
--  DDL for Package Body PA_CI_DOC_ATTACH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_DOC_ATTACH_PKG" AS
/* $Header: PACIDOCB.pls 120.1 2005/08/19 16:18:01 mwasowic noship $ */

PROCEDURE delete_all_attachments (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_id			IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
  pa_debug.set_err_stack ('PA_CI_DOC_ATTACH_PKG.DELETE_ALL_ATTACHMENTS');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_all_attachments;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = fnd_api.g_false THEN
    fnd_attached_documents2_pkg.delete_attachments(
      X_entity_name => 'PA_CONTROL_ITEMS',
      X_pk1_value => p_ci_id,
      X_delete_document_flag => 'Y');
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_all_attachments;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_all_attachments;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_DOC_ATTACH_PKG',
                            p_procedure_name => 'DELETE_ALL_ATTACHMENTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_all_attachments;

PROCEDURE copy_attachments (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_from_ci_id			IN NUMBER,
  p_to_ci_id			IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN
  pa_debug.set_err_stack ('PA_CI_DOC_ATTACH_PKG.COPY_ATTACHMENTS');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT copy_attachments;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  IF p_validate_only = fnd_api.g_false THEN
    fnd_attached_documents2_pkg.copy_attachments(
      X_from_entity_name => 'PA_CONTROL_ITEMS',
      X_from_pk1_value => p_from_ci_id,
      X_to_entity_name => 'PA_CONTROL_ITEMS',
      X_to_pk1_value => p_to_ci_id,
      X_created_by => fnd_global.user_id,
      X_last_update_login => fnd_global.login_id);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO copy_attachments;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO copy_attachments;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_DOC_ATTACH_PKG',
                            p_procedure_name => 'COPY_ATTACHMENTS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END copy_attachments;

END pa_ci_doc_attach_pkg;

/
