--------------------------------------------------------
--  DDL for Package Body PA_CI_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_TYPES_PVT" AS
/* $Header: PACITYVB.pls 120.2.12010000.11 2009/10/28 19:34:13 cklee ship $ */

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
  p_status_list_id		IN NUMBER
)
IS
  l_rowid VARCHAR2(30);
  l_obj_sl_rowid VARCHAR2(30);
  l_obj_status_list_id NUMBER;
  l_dist_list_id NUMBER; -- Bug 4565156.
  l_approval_required_flag varchar2(1) := p_approval_required_flag; --28-oct-2009  cklee fxied bug: 9063248

BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPES_PVT.CREATE_CI_TYPE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT create_ci_type;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

-- start: 28-oct-2009  cklee fxied bug: 9063248
  IF P_APPROVAL_TYPE_CODE = 'AUTOMATIC_APPROVAL' THEN
    l_approval_required_flag := 'N';
  ELSE
    l_approval_required_flag := 'Y';
  END IF;
-- end: 28-oct-2009  cklee fxied bug: 9063248
  -- Validate the name and short name uniqueness
  IF (pa_ci_types_util.check_ci_type_name_exists(p_name, p_short_name)) THEN
    x_return_status := 'E';
    fnd_message.set_name('PA', 'PA_CI_TYPE_NAME_NOT_UNIQUE');
    fnd_msg_pub.add();
  END IF;

  -- Resolution Category is required when Resolution Required Flag is checked
  IF p_resolution_required_flag = 'Y' AND
     p_resolution_category IS NULL THEN
    x_return_status := 'E';
    fnd_message.set_name('PA', 'PA_CI_TYPE_RESO_CAT_MISSING');
    fnd_msg_pub.add();
  END IF;

  -- End Date Active must be later than Start Date Active
  IF p_start_date_active > p_end_date_active THEN
    x_return_status := 'E';
    fnd_message.set_name('PA', 'PA_CI_TYPE_INVALID_DATES');
    fnd_msg_pub.add();
  END IF;

  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    SELECT pa_ci_types_b_s.NEXTVAL
    INTO x_ci_type_id
    FROM sys.dual;

    pa_ci_types_pkg.insert_row(
      x_rowid => l_rowid,
      x_ci_type_id => x_ci_type_id,
      x_ci_type_class_code => p_ci_type_class_code,
      x_auto_number_flag => p_auto_number_flag,
      x_resolution_required_flag => p_resolution_required_flag,
      x_approval_required_flag => l_approval_required_flag, --28-oct-2009  cklee fxied bug: 9063248--p_approval_required_flag,
      x_source_attrs_enabled_flag => p_source_attrs_enabled_flag,
      x_allow_all_usage_flag => p_allow_all_usage_flag,
      x_record_version_number => 0,
      x_start_date_active => p_start_date_active,
      x_end_date_active => p_end_date_active,
      x_classification_category => p_classification_category,
      x_reason_category => p_reason_category,
      x_resolution_category => p_resolution_category,
      x_attribute_category => p_attribute_category,
      x_attribute1 => p_attribute1,
      x_attribute2 => p_attribute2,
      x_attribute3 => p_attribute3,
      x_attribute4 => p_attribute4,
      x_attribute5 => p_attribute5,
      x_attribute6 => p_attribute6,
      x_attribute7 => p_attribute7,
      x_attribute8 => p_attribute8,
      x_attribute9 => p_attribute9,
      x_attribute10 => p_attribute10,
      x_attribute11 => p_attribute11,
      x_attribute12 => p_attribute12,
      x_attribute13 => p_attribute13,
      x_attribute14 => p_attribute14,
      x_attribute15 => p_attribute15,
      x_name => p_name,
      x_short_name => p_short_name,
      x_description => p_description,
      x_creation_date => p_creation_date,
      x_created_by => p_created_by,
      x_last_update_date => p_creation_date,
      x_last_updated_by => p_created_by,
      x_last_update_login => p_last_update_login,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
      X_APPROVAL_TYPE_CODE => P_APPROVAL_TYPE_CODE,
      X_SUBCONTRACTOR_REPORTING_FLAG => P_SUBCONTRACTOR_REPORTING_FLAG,
      X_PREFIX_AUTO_NUMBER => P_PREFIX_AUTO_NUMBER,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
--|start   29-APR-2009  cklee  R12.1.2 setup ehancement v2
  X_IMPACT_BUDGET_TYPE_CODE       => P_IMPACT_BUDGET_TYPE_CODE,
  X_COST_COL_FLAG                 => P_COST_COL_FLAG,
  X_REV_COL_FLAG                  => P_REV_COL_FLAG,
  X_DIR_COST_REG_FLAG             => P_DIR_COST_REG_FLAG,
  X_SUPP_COST_REG_FLAG            => P_SUPP_COST_REG_FLAG,
  X_DIR_REG_REV_COL_FLAG          => P_DIR_REG_REV_COL_FLAG);
--|end   29-APR-2009  cklee  R12.1.2 setup ehancement v2


    --Creating the distribution list
    SELECT pa_distribution_lists_s.NEXTVAL
    INTO x_dist_list_id
    FROM sys.dual;

    l_dist_list_id := x_dist_list_id; -- Bug 4565156.

    pa_distribution_lists_pvt.create_dist_list (
	p_validate_only => p_validate_only,
	p_list_id => l_dist_list_id, -- Bug 4565156.
	p_name => x_dist_list_id,
	p_description => NULL,
	p_creation_date => p_creation_date,
	p_created_by => p_created_by,
	p_last_update_date => p_creation_date,
	p_last_updated_by => p_created_by,
	p_last_update_login => p_last_update_login,
	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);

   x_dist_list_id := l_dist_list_id; -- Bug 4565156.

   -- Inserting record in pa_obj_status_lists
    SELECT pa_obj_status_lists_s.NEXTVAL
    INTO l_obj_status_list_id
    FROM sys.dual;

    pa_obj_status_lists_pkg.INSERT_ROW (
	  X_ROWID => l_obj_sl_rowid,
	  X_OBJ_STATUS_LIST_ID => l_obj_status_list_id,
	  X_OBJECT_TYPE => 'PA_CI_TYPES',
	  X_OBJECT_ID => x_ci_type_id,
	  X_STATUS_LIST_ID => p_status_list_id,
	  X_STATUS_TYPE => 'CONTROL_ITEM',
	  X_CREATION_DATE => p_creation_date,
	  X_CREATED_BY => p_created_by,
	  X_LAST_UPDATE_DATE => p_creation_date,
	  X_LAST_UPDATED_BY => p_created_by,
	  X_LAST_UPDATE_LOGIN => p_last_update_login
	);
  END IF;

  --Associating the dist list to the CI type
  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_object_dist_lists_pvt.create_object_dist_list (
	p_validate_only => p_validate_only,
	p_list_id => x_dist_list_id,
	p_object_type => 'PA_CI_TYPES',
        p_object_id => x_ci_type_id,
	p_creation_date => p_creation_date,
	p_created_by => p_created_by,
	p_last_update_date => p_creation_date,
	p_last_updated_by => p_created_by,
	p_last_update_login => p_last_update_login,
	x_return_status => x_return_status,
	x_msg_count => x_msg_count,
	x_msg_data => x_msg_data);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO create_ci_type;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION

  WHEN G_EXCEPTION_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO create_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO create_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);
  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO create_ci_type;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPES_PVT',
                            p_procedure_name => 'CREATE_CI_TYPE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_ci_type;


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
  p_status_list_id		IN NUMBER,
  p_obj_status_list_id		IN NUMBER
)
IS
  l_temp VARCHAR2(1);
  l_classification_category VARCHAR2(150);
  l_reason_category VARCHAR2(150);
  l_resolution_category VARCHAR2(150);

-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
-- if the current change request approval type code is EXTERNAL_APPROVAL and control item's pco status
-- has been recorded, then user is not allowed to change the approval type.
  cursor c_pco_st_exists is
      select 1
      from pa_control_items ci,
	       pa_ci_types_b cip
	  where ci.ci_type_id = cip.ci_type_id
	  and cip.ci_type_class_code = 'CHANGE_REQUEST'
       and cip.ci_type_id = p_ci_type_id
       and cip.approval_type_code = 'EXTERNAL_APPROVAL'
        and ci.pco_status_code is not null;
    l_pco_st_exists number;
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

-- start: cklee 09/30/09	bug: 8974414
-- get budget update method before user make changes
   CURSOR budget_options_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
     select ci.IMPACT_BUDGET_TYPE_CODE,
            ci.COST_COL_FLAG,
            ci.REV_COL_FLAG,
            ci.DIR_COST_REG_FLAG,
            ci.SUPP_COST_REG_FLAG,
            ci.DIR_REG_REV_COL_FLAG
	 from  pa_ci_types_b ci
	 where ci.ci_type_id = p_ci_type_id;

    budget_options_rec budget_options_csr%ROWTYPE;

-- check if impacts exists for control item type
   CURSOR validate_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
     select 1
	 from  pa_control_items  pci,
		   pa_ci_impacts pc
     where pci.ci_type_id = p_ci_type_id
	   and pci.ci_id = pc.ci_id;

    l_impacts_exists boolean := false;
    l_impacts_dummy number;

   CURSOR budget_method(p_lookup_code varchar2) is
     select meaning
     from pa_lookups
     where lookup_type = 'PA_CI_IMPACT_BUDGET_TYPES'
       and lookup_code = p_lookup_code;

    l_update_budget_method varchar2(30);
--EDIT_PLANNED_AMOUNTS
--'DIRECT_COST_ENTRY'


-- end: cklee 09/30/09	bug: 8974414

   CURSOR val_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type,
                                p_impact_type_code varchar2) is
     select pc.impact_type_code,
	        luk.meaning impact_type_name
	 from  pa_control_items  pci,
		   pa_ci_impacts pc,
		   pa_lookups luk
     where pci.ci_type_id = p_ci_type_id
	   and pci.ci_id = pc.ci_id
	   and pc.impact_type_code = luk.lookup_code
	   and luk.lookup_type = 'PA_CI_IMPACT_TYPES'
         and pc.impact_type_code = p_impact_type_code;

    val_impacts_rec val_impacts_csr%ROWTYPE;
/* future use
   CURSOR val_Dir_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type,
                                p_impact_type_code varchar2) is
     select pc.impact_type_code,
	        luk.meaning impact_type_name
	 from  pa_control_items  pci,
		   pa_ci_impacts pc,
		   pa_lookups luk,
              pa_budget_versions pbv,
            pa_resource_assignments pra
     where pci.ci_type_id = p_ci_type_id
	   and pci.ci_id = pc.ci_id
	   and pc.impact_type_code = luk.lookup_code
	   and luk.lookup_type = 'PA_CI_IMPACT_TYPES'
         and pc.impact_type_code = p_impact_type_code
         and pbv.ci_id = pci.ci_id
         and pra.budget_version_id = pbv.budget_version_id
         and total_plan_raw_cost is not null
         and not exists (select 1
                    from pa_ci_supplier_details sup_det
                    where sup_det.ci_id=pbv.ci_id
              		and sup_det.task_id=pra.task_id
		            and sup_det.resource_list_member_id=pra.resource_list_member_id);

    val_Dir_impacts_rec val_Dir_impacts_csr%ROWTYPE;

   CURSOR val_Supp_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type,
                                p_impact_type_code varchar2) is
     select pc.impact_type_code,
	        luk.meaning impact_type_name
	 from  pa_control_items  pci,
		   pa_ci_impacts pc,
		   pa_lookups luk,
              pa_budget_versions pbv,
            pa_resource_assignments pra
     where pci.ci_type_id = p_ci_type_id
	   and pci.ci_id = pc.ci_id
	   and pc.impact_type_code = luk.lookup_code
	   and luk.lookup_type = 'PA_CI_IMPACT_TYPES'
         and pc.impact_type_code = p_impact_type_code
         and pbv.ci_id = pci.ci_id
         and pra.budget_version_id = pbv.budget_version_id
         and total_plan_raw_cost is not null
         and exists (select 1
                    from pa_ci_supplier_details sup_det
                    where sup_det.ci_id=pbv.ci_id
              		and sup_det.task_id=pra.task_id
		            and sup_det.resource_list_member_id=pra.resource_list_member_id);

    val_Supp_impacts_rec val_Supp_impacts_csr%ROWTYPE;
*/

   -- Check if direct/supplier cost regions have been created in budgets?
   CURSOR new_fin_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
        select 1
           from pa_ci_types_v pct,
                pa_control_items pci,
                pa_budget_versions pbv
        where pct.ci_type_id = pci.ci_type_id
         and   pci.ci_id = pbv.ci_id
         and pct.ci_type_id = p_ci_type_id;

    l_new_fin_imp_exists boolean := false;
    l_new_fin_imp_dummy number;

    CURSOR imp_code_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type,
                                p_impact_type_code varchar2) is
     select luk.meaning impact_type_name
	 from  pa_lookups luk
	   where luk.lookup_type = 'PA_CI_IMPACT_TYPES'
         and luk.lookup_code = p_impact_type_code;

    imp_code_rec imp_code_csr%ROWTYPE;
  l_approval_required_flag varchar2(1) := p_approval_required_flag; --28-oct-2009  cklee fxied bug: 9063248

BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPES_PVT.UPDATE_CI_TYPE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT update_ci_type;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

-- start: 28-oct-2009  cklee fxied bug: 9063248
  IF P_APPROVAL_TYPE_CODE = 'AUTOMATIC_APPROVAL' THEN
    l_approval_required_flag := 'N';
  ELSE
    l_approval_required_flag := 'Y';
  END IF;
-- end: 28-oct-2009  cklee fxied bug: 9063248

-- start: cklee 09/30/09	bug: 8974414
-- 1. get budget update method before user make changes
-- 2. check if impacts exists for control item type
-- 3. raise error if impact exists and user try to change
--    the update budget method

-- 1. get budget update method before user make changes

   FOR budget_options_rec IN budget_options_csr (p_ci_type_id)
        LOOP
          -- user try to switch update budget method
          -- 1.1 Direct Cost (budget and forecast) -> NA
          -- 1.2 Direct Cost (budget and forecast) -> Edit plan amounts
          IF (budget_options_rec.IMPACT_BUDGET_TYPE_CODE = 'DIRECT_COST_ENTRY') THEN
            IF (P_IMPACT_BUDGET_TYPE_CODE <> 'DIRECT_COST_ENTRY') THEN
              OPEN validate_impacts_csr(p_ci_type_id);
              FETCH validate_impacts_csr INTO l_impacts_dummy;
              IF validate_impacts_csr%FOUND THEN
                l_impacts_exists := TRUE;
              END IF;
              CLOSE validate_impacts_csr;

              IF l_impacts_exists THEN

                OPEN budget_method(budget_options_rec.IMPACT_BUDGET_TYPE_CODE);
                FETCH budget_method INTO l_update_budget_method;
                CLOSE budget_method;

                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
						   ,p_token1          => 'IMPACT'
						   ,p_value1          => l_update_budget_method);

                RAISE G_EXCEPTION_UNEXPECTED_ERROR;

              END IF;
            --END IF;
            -- start:|   05-Oct-2009  cklee  Fixed bug: 8947080
            ELSIF (P_IMPACT_BUDGET_TYPE_CODE = 'DIRECT_COST_ENTRY') THEN
            -- validation for supplier/direct cost region:
            -- 1. if ci_type_id exists in pa_budget_versions then
            --    -- user cannot remove any options
            --    -- user cannot add options
            -- 2. if ci_type_id not exists in pa_budget_versions then
            --    -- user free to make changes
              OPEN new_fin_impacts_csr(p_ci_type_id);
              FETCH new_fin_impacts_csr INTO l_new_fin_imp_dummy;
              IF new_fin_impacts_csr%FOUND THEN
                l_new_fin_imp_exists := TRUE;
              END IF;
              CLOSE new_fin_impacts_csr;

              IF l_new_fin_imp_exists THEN

                -- Revenue modification:
                IF (budget_options_rec.DIR_REG_REV_COL_FLAG = 'Y' AND P_DIR_REG_REV_COL_FLAG = 'N') THEN

                  FOR imp_code_rec IN imp_code_csr (p_ci_type_id, 'FINPLAN_REVENUE')
                    LOOP
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	           ,p_token1          => 'IMPACT'
						               ,p_value1          => imp_code_rec.impact_type_name);

                      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                  END LOOP;

                ELSIF (budget_options_rec.DIR_REG_REV_COL_FLAG = 'N' AND P_DIR_REG_REV_COL_FLAG = 'Y') THEN
                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_NO_REV_IMPACT');

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;

                -- Supplier cost region modification
                IF (budget_options_rec.SUPP_COST_REG_FLAG = 'Y' AND P_SUPP_COST_REG_FLAG = 'N') THEN
                  FOR imp_code_rec IN imp_code_csr (p_ci_type_id, 'FINPLAN_SUPPLIER_COST')
                    LOOP
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	           ,p_token1          => 'IMPACT'
						               ,p_value1          => imp_code_rec.impact_type_name);

                      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                  END LOOP;
                ELSIF (budget_options_rec.SUPP_COST_REG_FLAG = 'N' AND P_SUPP_COST_REG_FLAG = 'Y') THEN
                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_NO_COST_IMPACT');

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;

                -- Direct cost region modification
                IF (budget_options_rec.DIR_COST_REG_FLAG = 'Y' AND P_DIR_COST_REG_FLAG = 'N') THEN
                  FOR imp_code_rec IN imp_code_csr (p_ci_type_id, 'FINPLAN_DIRECT_COST')
                    LOOP
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	           ,p_token1          => 'IMPACT'
						               ,p_value1          => imp_code_rec.impact_type_name);

                      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                  END LOOP;
                ELSIF (budget_options_rec.DIR_COST_REG_FLAG = 'N' AND P_DIR_COST_REG_FLAG = 'Y') THEN
                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_NO_COST_IMPACT');

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;

              END IF;

/*
              -- User try to remove revenue option
              IF (budget_options_rec.DIR_REG_REV_COL_FLAG = 'Y' AND P_DIR_REG_REV_COL_FLAG = 'N') THEN
                FOR val_impacts_rec IN val_impacts_csr (p_ci_type_id, 'FINPLAN_REVENUE')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;

              -- User try to remove supplier cost region option
              IF (budget_options_rec.SUPP_COST_REG_FLAG = 'Y' AND P_SUPP_COST_REG_FLAG = 'N') THEN
                FOR val_supp_impacts_rec IN val_supp_impacts_csr (p_ci_type_id, 'FINPLAN_COST')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_supp_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;

              -- User try to remove direct cost region option
              IF (budget_options_rec.DIR_COST_REG_FLAG = 'Y' AND P_DIR_COST_REG_FLAG = 'N') THEN
                FOR val_dir_impacts_rec IN val_dir_impacts_csr (p_ci_type_id, 'FINPLAN_COST')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_dir_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;


              -- Original setting Dir=Y or/and Supp=Y
              IF (P_DIR_COST_REG_FLAG = 'N' AND P_SUPP_COST_REG_FLAG = 'N') THEN

                FOR val_impacts_rec IN val_impacts_csr (p_ci_type_id, 'FINPLAN_COST')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;
*/
            END IF;
            -- end:|   05-Oct-2009  cklee  Fixed bug: 8947080
          -- user try to switch update budget method
          -- 2.1 Edit plan amounts -> NA
          -- 2.2 Edit plan amounts -> Direct Cost (budget and forecast)
          ELSIF (budget_options_rec.IMPACT_BUDGET_TYPE_CODE = 'EDIT_PLANNED_AMOUNTS') THEN
            IF (P_IMPACT_BUDGET_TYPE_CODE <> 'EDIT_PLANNED_AMOUNTS') THEN
              OPEN validate_impacts_csr(p_ci_type_id);
              FETCH validate_impacts_csr INTO l_impacts_dummy;
              IF validate_impacts_csr%FOUND THEN
                l_impacts_exists := TRUE;
              END IF;
              CLOSE validate_impacts_csr;

              IF l_impacts_exists THEN

                OPEN budget_method(budget_options_rec.IMPACT_BUDGET_TYPE_CODE);
                FETCH budget_method INTO l_update_budget_method;
                CLOSE budget_method;

                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
						   ,p_token1          => 'IMPACT'
						   ,p_value1          => l_update_budget_method);

                RAISE G_EXCEPTION_UNEXPECTED_ERROR;

              END IF;
            --END IF;
          -- user try to switch update budget method
          -- no impact for the following scenario
          -- 3.1 NA -> Edit plan amounts
          -- 3.2 NA -> Direct Cost (budget and forecast)
            -- |   05-Oct-2009  cklee  Fixed bug: 8947080
            -- start:|   05-Oct-2009  cklee  Fixed bug: 8947080
            ELSIF (P_IMPACT_BUDGET_TYPE_CODE = 'EDIT_PLANNED_AMOUNTS') THEN
              -- User try to remove revenue option
              IF (budget_options_rec.REV_COL_FLAG = 'Y' AND P_REV_COL_FLAG = 'N') THEN

                FOR val_impacts_rec IN val_impacts_csr (p_ci_type_id, 'FINPLAN_REVENUE')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;
              IF (budget_options_rec.COST_COL_FLAG = 'Y' AND P_COST_COL_FLAG = 'N') THEN

                FOR val_impacts_rec IN val_impacts_csr (p_ci_type_id, 'FINPLAN_COST')
                  LOOP

                  PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
					    	   ,p_token1          => 'IMPACT'
						   ,p_value1          => val_impacts_rec.impact_type_name);

                  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                END LOOP;

              END IF;
            -- end:|   05-Oct-2009  cklee  Fixed bug: 8947080

            END IF;
          END IF;

   END LOOP;


-- end: cklee 09/30/09	bug: 8974414


-- start: 26-Jun-2009    cklee     Modified for the Bug# 8633676
-- if the current change request approval type code is EXTERNAL_APPROVAL and control item's pco status
-- has been recorded, then user is not allowed to change the approval type.
  OPEN c_pco_st_exists;
   FETCH c_pco_st_exists INTO l_pco_st_exists;
  if c_pco_st_exists%FOUND then
     if (p_ci_type_class_code = 'CHANGE_REQUEST' and
            p_approval_type_code <> 'EXTERNAL_APPROVAL') then

        x_return_status := 'E';
        fnd_message.set_name('PA', 'PA_CI_PCO_APP_METHOD_IN_USE');
        fnd_msg_pub.add();
     end if;
  end if ;
  close c_pco_st_exists;
-- end: 26-Jun-2009    cklee     Modified for the Bug# 8633676

  -- Validate the name and short name uniqueness
  IF (pa_ci_types_util.check_ci_type_name_exists(p_name, p_short_name, p_ci_type_id)) THEN
    x_return_status := 'E';
    fnd_message.set_name('PA','PA_CI_TYPE_NAME_NOT_UNIQUE');
    fnd_msg_pub.add();
  END IF;


  -- Validate the record version number
  BEGIN
    SELECT classification_category,
           reason_category,
           resolution_category
    INTO l_classification_category,
         l_reason_category,
         l_resolution_category
    FROM pa_ci_types_vl
    WHERE ci_type_id = p_ci_type_id
      AND record_version_number = p_record_version_number;

    p_record_version_number := p_record_version_number+1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := 'E';
      fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
      fnd_msg_pub.add();
  END;

  -- Cannot change the category if there is a control item using the class code
  IF x_return_status = 'S' AND
     l_classification_category <> p_classification_category THEN
    BEGIN
      SELECT 'X' INTO l_temp
      FROM PA_CONTROL_ITEMS
      WHERE ci_type_id = p_ci_type_id
        AND classification_code_id IS NOT NULL
        AND ROWNUM < 2;

      x_return_status := 'E';
      fnd_message.set_name('PA','PA_CI_TYPE_CLASS_CAT_IN_USE');
      fnd_msg_pub.add();
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  IF x_return_status = 'S' AND
     l_reason_category <> p_reason_category THEN
    BEGIN
      SELECT 'X' INTO l_temp
      FROM PA_CONTROL_ITEMS
      WHERE ci_type_id = p_ci_type_id
        AND reason_code_id IS NOT NULL
        AND ROWNUM < 2;

      x_return_status := 'E';
      fnd_message.set_name('PA','PA_CI_TYPE_REASON_CAT_IN_USE');
      fnd_msg_pub.add();
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  IF x_return_status = 'S' AND
     l_resolution_category <> p_resolution_category THEN
    BEGIN
      SELECT 'X' INTO l_temp
      FROM PA_CONTROL_ITEMS
      WHERE ci_type_id = p_ci_type_id
        AND resolution_code_id IS NOT NULL
        AND ROWNUM < 2;

      x_return_status := 'E';
      fnd_message.set_name('PA','PA_CI_TYPE_RESO_CAT_IN_USE');
      fnd_msg_pub.add();
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
  END IF;

  -- Resolution Category is required when Resolution Required Flag is checked
  IF p_resolution_required_flag = 'Y' AND
     p_resolution_category IS NULL THEN
    x_return_status := 'E';
    fnd_message.set_name('PA', 'PA_CI_TYPE_RESO_CAT_MISSING');
    fnd_msg_pub.add();
  END IF;

  -- Cannot change from Manual to Automatic numbering if an item exists
  IF p_auto_number_flag = 'Y' THEN
    BEGIN
      SELECT 'X'
      INTO l_temp
      FROM pa_ci_types_b cit,
           pa_control_items ci
      WHERE cit.ci_type_id = p_ci_type_id
        AND cit.auto_number_flag <> 'Y'
        AND ci.ci_type_id = p_ci_type_id
        AND ROWNUM=1;

      x_return_status := 'E';
      fnd_message.set_name('PA', 'PA_CI_TYPE_NO_SWITCH_NUM');
      fnd_msg_pub.add();
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;

  -- End Date Active must be later than Start Date Active
  IF p_start_date_active > p_end_date_active THEN
    x_return_status := 'E';
    fnd_message.set_name('PA', 'PA_CI_TYPE_INVALID_DATES');
    fnd_msg_pub.add();
  END IF;

  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_ci_types_pkg.update_row(
      x_ci_type_id => p_ci_type_id,
      x_ci_type_class_code => p_ci_type_class_code,
      x_auto_number_flag => p_auto_number_flag,
      x_resolution_required_flag => p_resolution_required_flag,
      x_approval_required_flag => l_approval_required_flag,----28-oct-2009  cklee fxied bug: 9063248p_approval_required_flag,
      x_source_attrs_enabled_flag => p_source_attrs_enabled_flag,
      x_allow_all_usage_flag => p_allow_all_usage_flag,
      x_record_version_number => p_record_version_number,
      x_start_date_active => p_start_date_active,
      x_end_date_active => p_end_date_active,
      x_classification_category => p_classification_category,
      x_reason_category => p_reason_category,
      x_resolution_category => p_resolution_category,
      x_attribute_category => p_attribute_category,
      x_attribute1 => p_attribute1,
      x_attribute2 => p_attribute2,
      x_attribute3 => p_attribute3,
      x_attribute4 => p_attribute4,
      x_attribute5 => p_attribute5,
      x_attribute6 => p_attribute6,
      x_attribute7 => p_attribute7,
      x_attribute8 => p_attribute8,
      x_attribute9 => p_attribute9,
      x_attribute10 => p_attribute10,
      x_attribute11 => p_attribute11,
      x_attribute12 => p_attribute12,
      x_attribute13 => p_attribute13,
      x_attribute14 => p_attribute14,
      x_attribute15 => p_attribute15,
      x_name => p_name,
      x_short_name => p_short_name,
      x_description => p_description,
      x_last_update_date => p_last_update_date,
      x_last_updated_by => p_last_updated_by,
      x_last_update_login => p_last_update_login,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
      X_APPROVAL_TYPE_CODE => P_APPROVAL_TYPE_CODE,
      X_SUBCONTRACTOR_REPORTING_FLAG => P_SUBCONTRACTOR_REPORTING_FLAG,
      X_PREFIX_AUTO_NUMBER => P_PREFIX_AUTO_NUMBER,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
--|start   29-APR-2009  cklee  R12.1.2 setup ehancement v2
  X_IMPACT_BUDGET_TYPE_CODE       => P_IMPACT_BUDGET_TYPE_CODE,
  X_COST_COL_FLAG                 => P_COST_COL_FLAG,
  X_REV_COL_FLAG                  => P_REV_COL_FLAG,
  X_DIR_COST_REG_FLAG             => P_DIR_COST_REG_FLAG,
  X_SUPP_COST_REG_FLAG            => P_SUPP_COST_REG_FLAG,
  X_DIR_REG_REV_COL_FLAG          => P_DIR_REG_REV_COL_FLAG);
--|end   29-APR-2009  cklee  R12.1.2 setup ehancement v2


      pa_obj_status_lists_pkg.UPDATE_ROW (
	  X_OBJ_STATUS_LIST_ID => p_obj_status_list_id,
	  X_OBJECT_TYPE => 'PA_CI_TYPES',
	  X_OBJECT_ID => p_ci_type_id,
	  X_STATUS_LIST_ID => p_status_list_id,
	  X_STATUS_TYPE => 'CONTROL_ITEM',
	  X_LAST_UPDATE_DATE => p_last_update_date,
	  X_LAST_UPDATED_BY => p_last_updated_by,
	  X_LAST_UPDATE_LOGIN => p_last_update_login
	);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO update_ci_type;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO update_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO update_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO update_ci_type;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPES_PVT',
                            p_procedure_name => 'UPDATE_CI_TYPE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END update_ci_type;


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
  p_obj_status_list_id		IN NUMBER
)
IS
  CURSOR c_ci_type_usage IS
  SELECT *
  FROM pa_ci_type_usage
  WHERE ci_type_id = p_ci_type_id;

  CURSOR c_impact_type_usage IS
  SELECT *
  FROM pa_ci_impact_type_usage
  WHERE ci_type_id = p_ci_type_id;

  CURSOR c_obj_status_lists IS
  SELECT *
  FROM pa_obj_status_lists
  WHERE obj_status_list_id = p_obj_status_list_id;

  l_temp VARCHAR2(1);
BEGIN
  pa_debug.set_err_stack ('PA_CI_TYPES_PVT.DELETE_CI_TYPE');

  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT delete_ci_type;
  END IF;

  IF p_init_msg_list = FND_API.G_TRUE THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  -- Validate the record version number
  BEGIN
    SELECT 'X' INTO l_temp
    FROM pa_ci_types_vl
    WHERE ci_type_id = p_ci_type_id
      AND record_version_number = p_record_version_number;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := 'E';
      fnd_message.set_name('PA','PA_XC_RECORD_CHANGED');
      fnd_msg_pub.add();
  END;

  -- Cannot delete CI Type if CI exists
  BEGIN
    SELECT 'X' INTO l_temp
    FROM pa_control_items
    WHERE ci_type_id = p_ci_type_id
      AND ROWNUM=1;

    x_return_status := 'E';
    fnd_message.set_name('PA','PA_CI_TYPE_NO_DELETE_IN_USE');
    fnd_msg_pub.add();
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  /* Changes for the bug# 3941304 starts here */
  -- Cannot Delete CI Type if it has some selected statuses
  -- for financial imapct implementation/inclusion
  if Pa_Fp_Control_Items_Utils.validate_fp_ci_type_delete( p_ci_type_id) <> 'Y' then
     x_return_status := 'E';
     fnd_message.set_name('PA','FP_CI_TYPE_DEL_NOT_ALLOWED');
     fnd_msg_pub.add();
  end if;
  /* Changes for the bug# 3941304 ends here */

  --Deleting the associated distribution list
  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_object_dist_lists_pvt.delete_assoc_dist_lists (
      p_validate_only => p_validate_only,
      p_object_type => 'PA_CI_TYPES',
      p_object_id => p_ci_type_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
  END IF;

  --Deleting the CI type usage
  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    FOR rec IN c_ci_type_usage LOOP
      pa_ci_type_usage_pvt.delete_ci_type_usage (
        p_validate_only => p_validate_only,
        p_ci_type_usage_id => rec.ci_type_usage_id,
        p_project_type_id => rec.project_type_id,
        p_ci_type_id => p_ci_type_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

      EXIT WHEN x_return_status<>'S';
    END LOOP;
  END IF;

  --Deleting the impact type usage
  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    FOR rec IN c_impact_type_usage LOOP
      pa_ci_impact_type_usage_pvt.delete_ci_impact_type_usage (
        p_validate_only => p_validate_only,
        p_ci_impact_type_usage_id => rec.ci_impact_type_usage_id,
        p_impact_type_code => rec.impact_type_code,
        p_ci_type_class_code => NULL,
        p_ci_type_id => p_ci_type_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

      EXIT WHEN x_return_status<>'S';
    END LOOP;
  END IF;

  --Deleting the CI type itself
  IF (p_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN
    pa_ci_types_pkg.delete_row(
      x_ci_type_id => p_ci_type_id);

  --Deleting the association from pa_obj_status_lists
    pa_obj_status_lists_pkg.delete_row(
      x_obj_status_list_id => p_obj_status_list_id);
  END IF;

  IF p_commit = fnd_api.g_true THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_ci_type;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO delete_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO delete_ci_type;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
    IF p_commit = fnd_api.g_true THEN
      ROLLBACK TO delete_ci_type;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_TYPES_PVT',
                            p_procedure_name => 'DELETE_CI_TYPE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_ci_type;

END pa_ci_types_pvt;

/
