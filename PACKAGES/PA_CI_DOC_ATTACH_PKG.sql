--------------------------------------------------------
--  DDL for Package PA_CI_DOC_ATTACH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_DOC_ATTACH_PKG" AUTHID CURRENT_USER AS
/* $Header: PACIDOCS.pls 120.1 2005/08/19 16:18:04 mwasowic noship $ */

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
);

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
);

END pa_ci_doc_attach_pkg;
 

/
