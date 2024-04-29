--------------------------------------------------------
--  DDL for Package PA_CI_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_TYPES_PVT" AUTHID CURRENT_USER as
/* $Header: PACITYVS.pls 120.1.12010000.3 2009/09/30 19:18:10 cklee ship $ */
--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------

G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

PROCEDURE create_ci_type (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_name			IN VARCHAR2,
  p_short_name			IN VARCHAR2,
  p_description			IN VARCHAR2,
  p_ci_type_class_code		IN VARCHAR2,
  p_auto_number_flag		IN VARCHAR2,
  p_resolution_required_flag	IN VARCHAR2,
  p_approval_required_flag	IN VARCHAR2,
  p_source_attrs_enabled_flag	IN VARCHAR2,
  p_allow_all_usage_flag        IN VARCHAR2,
  p_start_date_active		IN DATE,
  p_end_date_active		IN DATE,
  p_classification_category	IN VARCHAR2,
  p_reason_category		IN VARCHAR2,
  p_resolution_category		IN VARCHAR2,
  p_attribute_category		IN VARCHAR2,
  p_attribute1			IN VARCHAR2,
  p_attribute2			IN VARCHAR2,
  p_attribute3			IN VARCHAR2,
  p_attribute4			IN VARCHAR2,
  p_attribute5			IN VARCHAR2,
  p_attribute6			IN VARCHAR2,
  p_attribute7			IN VARCHAR2,
  p_attribute8			IN VARCHAR2,
  p_attribute9			IN VARCHAR2,
  p_attribute10			IN VARCHAR2,
  p_attribute11			IN VARCHAR2,
  p_attribute12			IN VARCHAR2,
  p_attribute13			IN VARCHAR2,
  p_attribute14			IN VARCHAR2,
  p_attribute15			IN VARCHAR2,
  p_created_by			IN NUMBER DEFAULT fnd_global.user_id,
  p_creation_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.user_id,
 --start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_APPROVAL_TYPE_CODE            IN VARCHAR2 DEFAULT 'STANDARD',
  P_SUBCONTRACTOR_REPORTING_FLAG  IN VARCHAR2 DEFAULT 'N',
  P_PREFIX_AUTO_NUMBER            IN VARCHAR2 DEFAULT NULL,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
--|start   29-APR-2009  cklee  R12.1.2 setup ehancement v2
  P_IMPACT_BUDGET_TYPE_CODE       IN VARCHAR2 DEFAULT 'NA',
  P_COST_COL_FLAG                 IN VARCHAR2 DEFAULT 'N',
  P_REV_COL_FLAG                  IN VARCHAR2 DEFAULT 'N',
  P_DIR_COST_REG_FLAG             IN VARCHAR2 DEFAULT 'N',
  P_SUPP_COST_REG_FLAG            IN VARCHAR2 DEFAULT 'N',
  P_DIR_REG_REV_COL_FLAG          IN VARCHAR2 DEFAULT 'N',
--|end   29-APR-2009  cklee  R12.1.2 setup ehancement v2
 x_ci_type_id			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_dist_list_id                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_status_list_id 		IN NUMBER
);

PROCEDURE update_ci_type (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_type_id			IN NUMBER,
  p_name			IN VARCHAR2,
  p_short_name			IN VARCHAR2,
  p_description			IN VARCHAR2,
  p_ci_type_class_code		IN VARCHAR2,
  p_auto_number_flag		IN VARCHAR2,
  p_resolution_required_flag	IN VARCHAR2,
  p_approval_required_flag	IN VARCHAR2,
  p_source_attrs_enabled_flag	IN VARCHAR2,
  p_allow_all_usage_flag        IN VARCHAR2,
  p_start_date_active		IN DATE,
  p_end_date_active		IN DATE,
  p_classification_category	IN VARCHAR2,
  p_reason_category		IN VARCHAR2,
  p_resolution_category		IN VARCHAR2,
  p_attribute_category		IN VARCHAR2,
  p_attribute1			IN VARCHAR2,
  p_attribute2			IN VARCHAR2,
  p_attribute3			IN VARCHAR2,
  p_attribute4			IN VARCHAR2,
  p_attribute5			IN VARCHAR2,
  p_attribute6			IN VARCHAR2,
  p_attribute7			IN VARCHAR2,
  p_attribute8			IN VARCHAR2,
  p_attribute9			IN VARCHAR2,
  p_attribute10			IN VARCHAR2,
  p_attribute11			IN VARCHAR2,
  p_attribute12			IN VARCHAR2,
  p_attribute13			IN VARCHAR2,
  p_attribute14			IN VARCHAR2,
  p_attribute15			IN VARCHAR2,
  p_last_updated_by		IN NUMBER DEFAULT fnd_global.user_id,
  p_last_update_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.user_id,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_APPROVAL_TYPE_CODE            IN VARCHAR2 DEFAULT 'STANDARD',
  P_SUBCONTRACTOR_REPORTING_FLAG  IN VARCHAR2 DEFAULT 'N',
  P_PREFIX_AUTO_NUMBER            IN VARCHAR2 DEFAULT NULL,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
--|start   29-APR-2009  cklee  R12.1.2 setup ehancement v2
  P_IMPACT_BUDGET_TYPE_CODE       IN VARCHAR2 DEFAULT 'NA',
  P_COST_COL_FLAG                 IN VARCHAR2 DEFAULT 'N',
  P_REV_COL_FLAG                  IN VARCHAR2 DEFAULT 'N',
  P_DIR_COST_REG_FLAG             IN VARCHAR2 DEFAULT 'N',
  P_SUPP_COST_REG_FLAG            IN VARCHAR2 DEFAULT 'N',
  P_DIR_REG_REV_COL_FLAG          IN VARCHAR2 DEFAULT 'N',
--|end   29-APR-2009  cklee  R12.1.2 setup ehancement v2
  p_record_version_number	IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_status_list_id 		IN NUMBER,
  p_obj_status_list_id		IN NUMBER
);

PROCEDURE delete_ci_type (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := fnd_api.g_true,
  p_commit			IN VARCHAR2 := FND_API.g_false,
  p_validate_only		IN VARCHAR2 := FND_API.g_true,
  p_max_msg_count		IN NUMBER := FND_API.g_miss_num,
  p_ci_type_id			IN NUMBER,
  p_record_version_number	IN NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data			OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  p_obj_status_list_id          IN NUMBER
);

END pa_ci_types_pvt;

/
