--------------------------------------------------------
--  DDL for Package Body PA_CI_IMPACT_TYPE_USAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_IMPACT_TYPE_USAGE_PVT" AS
/* $Header: PACIIMVB.pls 120.0.12010000.4 2009/10/06 21:58:32 cklee ship $ */

PROCEDURE create_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_impact_type_code IN VARCHAR2  := null,
  p_ci_type_class_code IN VARCHAR2  := null,
  p_CI_TYPE_ID in NUMBER := null,

  p_created_by			IN NUMBER DEFAULT fnd_global.user_id,
  p_creation_date		IN DATE DEFAULT SYSDATE,
  p_last_update_login		IN NUMBER DEFAULT fnd_global.login_id,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

  x_ci_impact_type_usage_id		OUT NOCOPY NUMBER,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_rowid VARCHAR2(30);
   CURSOR check_exists is
     SELECT 'Y' FROM dual
     WHERE exists (SELECT ci_impact_type_usage_id FROM
		   pa_ci_impact_type_usage
--		   WHERE ci_type_class_code = p_ci_type_class_code
		   WHERE nvl(ci_type_class_code, 1) = nvl(p_ci_type_class_code, 1) -- cklee
		   AND ci_type_id = p_ci_type_id
		   AND impact_type_code = p_impact_type_code);

   l_dummy VARCHAR2(1);

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PVT.CREATE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT create_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  OPEN check_exists;
  FETCH check_exists INTO l_dummy;
  IF check_exists%found THEN
     -- record already exists
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_IMPACT_TU_EXIST');

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  CLOSE check_exists;

  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACT_TYPE_USAGE_pkg.insert_row(
      x_rowid => l_rowid,
      x_ci_impact_type_usage_id => x_ci_impact_type_usage_id,
      x_impact_type_code => p_impact_type_code,
      x_ci_type_class_code => p_ci_type_class_code,
      x_ci_type_id => p_ci_type_id,
      x_creation_date => p_creation_date,
      x_created_by => p_created_by,
      x_last_update_date => p_creation_date,
      x_last_updated_by => p_created_by,
      x_last_update_login => p_last_update_login,
 --start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
      X_IMPACT_TYPE_CODE_ORDER => P_IMPACT_TYPE_CODE_ORDER);
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

  END IF;

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO create_ci_impact_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO create_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPE_USAGE_PVT',
                            p_procedure_name => 'CREATE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END create_ci_impact_type_usage;

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

PROCEDURE update_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  P_IMPACT_TYPE_CODE_ORDER IN NUMBER,
  p_ci_impact_type_usage_id		IN NUMBER,

  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
is

BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PVT.UPDATE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT update_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';
  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACT_TYPE_USAGE_pkg.update_row(
      x_ci_impact_type_usage_id => p_ci_impact_type_usage_id,
      X_IMPACT_TYPE_CODE_ORDER => P_IMPACT_TYPE_CODE_ORDER);

  END IF;

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO update_ci_impact_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO update_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPE_USAGE_PVT',
                            p_procedure_name => 'UPDATE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);

end update_ci_impact_type_usage;
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement


PROCEDURE delete_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ci_impact_type_usage_id	IN NUMBER := null,
  p_impact_type_code            IN VARCHAR2 := null,
  p_ci_type_class_code          IN VARCHAR2 := null,
  p_ci_type_id                  IN NUMBER := null,
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  P_IMPACT_TYPE_CODE_ORDER IN NUMBER  default null,
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS
   l_temp VARCHAR2(1);
   CURSOR check_exists is
     SELECT 'Y' FROM dual
     WHERE exists (SELECT ci_impact_type_usage_id FROM
		   pa_ci_impact_type_usage
		   WHERE ci_impact_type_usage_id = p_ci_impact_type_usage_id
		   );
--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
   CURSOR c_impact_type is
     SELECT MEANING FROM pa_lookups
	 WHERE LOOKUP_TYPE = 'PA_CI_IMPACT_TYPES'
	 AND LOOKUP_CODE = p_impact_type_code;

   l_impact_type_meaning pa_lookups.MEANING%type;
--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement


   l_dummy VARCHAR2(1);
BEGIN
  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PVT.DELETE_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT delete_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';

  OPEN check_exists;
  FETCH check_exists INTO l_dummy;
  IF check_exists%notfound THEN
     -- record already exists
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_TU_NO_EXIST');

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  CLOSE check_exists;

  -- bug 2606472
  -- if the impact is in use in a control item, the user cannot remove the
  -- impact type usage

  IF p_ci_type_id IS NOT NULL
    AND p_impact_type_code IS NOT NULL
      THEN

     l_dummy := pa_ci_impact_type_usage_pub.delete_impact_type_usage_ok
       (p_impact_type_code, p_ci_type_id);

     IF l_dummy = 'N' THEN

--start:|   16-FEB-2009  cklee  R12.1.2 setup ehancement
       OPEN c_impact_type;
       FETCH c_impact_type INTO l_impact_type_meaning;
       CLOSE c_impact_type;

       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
						   ,p_token1          => 'IMPACT'
						   ,p_value1          => l_impact_type_meaning);

--end:|   16-FEB-2009  cklee  R12.1.2 setup ehancement

        x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;


  END IF;


  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN
    PA_CI_IMPACT_TYPE_USAGE_pkg.delete_row(
      x_ci_impact_type_usage_id => p_ci_impact_type_usage_id);
  END IF;



  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO delete_ci_impact_type_usage;
    END IF;
  END IF;

  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
    IF p_commit = 'T' THEN
      ROLLBACK TO delete_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPES_PVT',
                            p_procedure_name => 'DELETE_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);
END delete_ci_impact_type_usage;

PROCEDURE apply_ci_impact_type_usage (
  p_api_version			IN NUMBER :=  1.0,
  p_init_msg_list		IN VARCHAR2 := 'T',
  p_commit			    IN VARCHAR2 := 'F',
  p_validate_only		IN VARCHAR2 := 'T',
  p_max_msg_count		IN NUMBER := null,

  p_ui_mode             IN VARCHAR2,
  p_ci_class_code		IN VARCHAR2,
  p_ci_type_id          IN NUMBER,
  p_impact_tbl          IN impact_tbl_type,

--  x_impact_tbl          OUT NOCOPY impact_tbl_type,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS

   l_rowid VARCHAR2(30);
   l_ci_impact_type_usage_id pa_ci_impact_type_usage.ci_impact_type_usage_id%type;

   CURSOR validate_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
     select pc.impact_type_code,
	        luk.meaning impact_type_name
	 from  pa_control_items  pci,
		   pa_ci_impacts pc,
		   pa_lookups luk
     where pci.ci_type_id = p_ci_type_id
	   and pci.ci_id = pc.ci_id
	   and pc.impact_type_code = luk.lookup_code
	   and luk.lookup_type = 'PA_CI_IMPACT_TYPES'
	   and pc.impact_type_code <> 'FINPLAN' -- cklee 4/23/09
	   and not exists
	        (select 1
			 from pa_ci_impact_type_usage pcu
			 where pcu.impact_type_code = pc.impact_type_code
			   and pcu.ci_type_id = pci.ci_type_id);

    validate_impacts_rec validate_impacts_csr%ROWTYPE;

	l_cost_exists boolean := false;
--	l_rev_exists boolean := false;
	l_direct_cost_exists boolean := false;
	l_supplier_cost_exists boolean := false;
	l_supplier_exists boolean := false;


   CURSOR delete_impacts_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
     select pu.ci_impact_type_usage_id
	 from  pa_ci_impact_type_usage pu
	 where pu.ci_type_id = p_ci_type_id;

    delete_impacts_rec delete_impacts_csr%ROWTYPE;
--cklee 5/1/09
   CURSOR sync_budget_options_csr (p_ci_type_id pa_ci_types_b.CI_TYPE_ID%type) is
     select ci.IMPACT_BUDGET_TYPE_CODE,
            ci.COST_COL_FLAG,
            ci.REV_COL_FLAG,
            ci.DIR_COST_REG_FLAG,
            ci.SUPP_COST_REG_FLAG,
            ci.DIR_REG_REV_COL_FLAG
	 from  pa_ci_types_b ci
	 where ci.ci_type_id = p_ci_type_id;

    l_direct_cost_RN_exists boolean := false;
    sync_cnt number := 0;
    sync_budget_options_rec sync_budget_options_csr%ROWTYPE;

	l_impact_tbl          impact_tbl_type := p_impact_tbl;
--Cost, Revenue and Direct Cost are mutually exclusive. Please choose the correct impact sections.

    l_finplan_cost_flag boolean := false; -- cklee 06/18/09

BEGIN


  pa_debug.set_err_stack ('PA_CI_IMPACT_TYPE_USAGE_PVT.APPLY_CI_IMPACT_TYPE_USAGE');

  IF p_commit = 'T' THEN
    SAVEPOINT apply_ci_impact_type_usage;
  END IF;

  IF p_init_msg_list = 'T' THEN
    fnd_msg_pub.initialize;
  END IF;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := '';
/*
This is the simplest way to implement the shuttle bean activities. The main reason we put the
validation at last because we can by pass the TAPI to validate for each individual impact
deletion and we validate after all database transactions (delete and insert new lists) are done;
if however, any list is missing from the pa_ci_impacts, we can list all missing list in once
so that user can fix on UI in once.

Also notice that this list is expected to be very small. So no performance concern for the implementation
1. delete * from pa_ci_impact_type_usage where ci_type_id = p_ci_type;
2: Cost, Revenue and Direct Cost are mutually exclusive. Please choose the correct impact sections.
3. insert into pa_ci_impact_type_usage with passed in impact lists
4. validate if existing impact list is missing from the new impact list and raise error
*/
--1. delete * from pa_ci_impact_type_usage where ci_type_id = p_ci_type;
  -- 1.1 user may rearrange the selected list in update control item only
  -- 1.2 Issue class doesn't have impact region, hence no action needed
  IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN

    IF p_ui_mode = 'UPDATE' AND p_ci_class_code <> 'ISSUE' THEN

      FOR delete_impacts_rec IN delete_impacts_csr (p_ci_type_id)
        LOOP
             PA_CI_IMPACT_TYPE_USAGE_pvt.delete_CI_IMPACT_TYPE_USAGE(
                  --p_api_version			   => p_api_version,
                  --p_init_msg_list		   => p_init_msg_list,
                  --p_commit			       => p_commit,
                  p_validate_only		   => p_validate_only,
                  --p_max_msg_count		   => p_max_msg_count,

                  p_ci_impact_type_usage_id => delete_impacts_rec.ci_impact_type_usage_id,
                  x_return_status		    => x_return_status,
                  x_msg_count			    => x_msg_count,
                  x_msg_data			    => x_msg_data);


 	          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		        RAISE G_EXCEPTION_ERROR;
	          END IF;
      END LOOP;
      --delete from pa_ci_impact_type_usage where ci_type_id = p_ci_type_id;
    END IF;

--
-- 2: Cost, Revenue and Direct Cost are mutually exclusive. Please choose the correct impact sections.
--
/****
    IF p_ui_mode <> 'VIEW' AND p_ci_class_code <> 'ISSUE' THEN

      IF p_impact_tbl.COUNT > 0 THEN

    	FOR i in p_impact_tbl.FIRST..p_impact_tbl.LAST LOOP

          IF p_impact_tbl(i).impact_type_code = 'FINPLAN_COST' THEN
		    l_cost_exists := TRUE;
		  ELSIF p_impact_tbl(i).impact_type_code = 'FINPLAN_DIRECT_COST' THEN
		    l_direct_cost_exists := TRUE;
		  ELSIF p_impact_tbl(i).impact_type_code = 'SUPPLIER' THEN
		    l_supplier_exists := TRUE;
		  ELSIF p_impact_tbl(i).impact_type_code = 'FINPLAN_SUPPLIER_COST' THEN
		    l_supplier_cost_exists := TRUE;
		  END IF;

        END LOOP;

        -- check error
		IF l_supplier_cost_exists = TRUE AND l_supplier_exists = TRUE THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_SUPP_SUPP_CONFLICT');

          RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		ELSIF l_supplier_cost_exists = TRUE AND l_cost_exists = TRUE THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_SUPP_COST_CONFLICT');

          RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		ELSIF l_direct_cost_exists = TRUE AND l_supplier_exists = TRUE THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_DIR_SUPP_CONFLICT');

          RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		ELSIF l_direct_cost_exists = TRUE AND l_cost_exists = TRUE THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_DIR_COST_CONFLICT');

          RAISE G_EXCEPTION_UNEXPECTED_ERROR;

		END IF;

      END IF;
    END IF;
***/
    -- pre-req: UI has already take care of the FINPLAN exists in p_impact_tbl
    -- so no additional check needed here.
    --
    -- note: In order to sync with pa_ci_impacts budget cost and revenue implementation logic
    --    modify the code logic as below:
    --    1. remove add additional new lookup codes for direct cost and supplier region
    --    2. in case if it's direct cost or/and supplier cost region user selected, add
    --       'FINPLAN_COST' as a lookup code for both -- only one lookup code
    --    3. in case if user choose to include revenue for direct or/and supplier cost
    --       region, add 'FINPLAN_REVENUE' as a lookup code for both -- only one lookup code
    --
   IF p_ui_mode <> 'VIEW' AND p_ci_class_code <> 'ISSUE' THEN

      IF l_impact_tbl.COUNT > 0 THEN
        sync_cnt := l_impact_tbl.LAST + 1;
        -- only one row will be executed...
        FOR sync_budget_options_rec IN sync_budget_options_csr (p_ci_type_id)
        LOOP
          IF (sync_budget_options_rec.IMPACT_BUDGET_TYPE_CODE = 'DIRECT_COST_ENTRY') THEN
            IF (sync_budget_options_rec.DIR_COST_REG_FLAG = 'Y') THEN
                l_direct_cost_RN_exists := true;
                --l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_DIRECT_COST';
                l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_COST';
                l_finplan_cost_flag := true;
                sync_cnt := sync_cnt + 1;
            END IF;
            IF (sync_budget_options_rec.SUPP_COST_REG_FLAG = 'Y') THEN
                l_direct_cost_RN_exists := true;
                --l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_SUPPLIER_COST';
                IF NOT l_finplan_cost_flag THEN
                  l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_COST';
                  sync_cnt := sync_cnt + 1;
                END IF;
            END IF;
            IF (sync_budget_options_rec.DIR_REG_REV_COL_FLAG = 'Y' AND l_direct_cost_RN_exists) THEN
                --l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_DIRECT_INC_REV';
                l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_REVENUE';
                sync_cnt := sync_cnt + 1;
            END IF;

          ELSIF (sync_budget_options_rec.IMPACT_BUDGET_TYPE_CODE = 'EDIT_PLANNED_AMOUNTS') THEN
            IF (sync_budget_options_rec.COST_COL_FLAG = 'Y') THEN
                l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_COST';
                sync_cnt := sync_cnt + 1;
            END IF;
            IF (sync_budget_options_rec.REV_COL_FLAG = 'Y') THEN
                l_impact_tbl(sync_cnt).impact_type_code := 'FINPLAN_REVENUE';
                --sync_cnt := sync_cnt + 1;
            END IF;

          END IF;

        END LOOP;

      END IF;
    END IF;

--3. insert into pa_ci_impact_type_usage with passed in impact lists

    -- 2.1 user may re-assemble the selected list in create/update control item
    -- 2.2 Issue class doesn't have impact region, hence no action needed
    IF p_ui_mode <> 'VIEW' AND p_ci_class_code <> 'ISSUE' THEN

      IF l_impact_tbl.COUNT > 0 THEN

    	FOR i in l_impact_tbl.FIRST..l_impact_tbl.LAST LOOP


              PA_CI_IMPACT_TYPE_USAGE_pvt.CREATE_CI_IMPACT_TYPE_USAGE(
                  --p_api_version			   => p_api_version,
                  --p_init_msg_list		   => p_init_msg_list,
                  --p_commit			       => p_commit,
                  p_validate_only		   => p_validate_only,
                  --p_max_msg_count		   => p_max_msg_count,

                  p_impact_type_code       => l_impact_tbl(i).impact_type_code,
                  p_ci_type_class_code     => NULL,
                  p_ci_type_id             => p_ci_type_id,

                  p_created_by			   => fnd_global.user_id,
                  p_creation_date		   => SYSDATE,
                  p_last_update_login	   => fnd_global.login_id,
                  P_IMPACT_TYPE_CODE_ORDER => i,

                  x_ci_impact_type_usage_id	=> l_ci_impact_type_usage_id,
                  x_return_status		    => x_return_status,
                  x_msg_count			    => x_msg_count,
                  x_msg_data			    => x_msg_data);


 	          IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	          ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		        RAISE G_EXCEPTION_ERROR;
	          END IF;
        END LOOP;
      END IF;
    END IF;

--4 validate if existing impact list is missing from the new impact list and raise error
--  |   05-Oct-2009  cklee  Fixed bug: 8947080
--  move below logic to pa_ci_types_pvt.update_ci_type API
/*   IF p_ui_mode = 'UPDATE' AND p_ci_class_code <> 'ISSUE' THEN

        FOR validate_impacts_rec IN validate_impacts_csr (p_ci_type_id)
        LOOP

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name        => 'PA_CI_IMPACT_TU_IN_USE'
						   ,p_token1          => 'IMPACT'
						   ,p_value1          => validate_impacts_rec.impact_type_name);

          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
        END LOOP;
      END IF;
*/

  END IF; -- end of IF (p_validate_only <> 'T' AND x_return_status = 'S') THEN

  IF p_commit = 'T' THEN
    IF  x_return_status = 'S' THEN
      COMMIT;
    ELSE
      ROLLBACK TO apply_ci_impact_type_usage;
    END IF;
  END IF;

    -- Get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get(p_count => x_msg_count,
                            p_data  => x_msg_data);

  pa_debug.reset_err_stack;

EXCEPTION
  WHEN G_EXCEPTION_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO apply_ci_impact_type_usage;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO apply_ci_impact_type_usage;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);


  WHEN OTHERS THEN

    IF p_commit = 'T' THEN
      ROLLBACK TO apply_ci_impact_type_usage;
    END IF;

    x_return_status := 'U';
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_IMPACT_TYPE_USAGE_PVT',
                            p_procedure_name => 'APPLY_CI_IMPACT_TYPE_USAGE',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data  => x_msg_data);



END apply_ci_impact_type_usage;

END PA_CI_IMPACT_TYPE_USAGE_pvt;

/
