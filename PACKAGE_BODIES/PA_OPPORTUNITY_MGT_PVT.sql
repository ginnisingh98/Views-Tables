--------------------------------------------------------
--  DDL for Package Body PA_OPPORTUNITY_MGT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OPPORTUNITY_MGT_PVT" as
/* $Header: PAYOPVTB.pls 120.6.12010000.2 2009/12/29 08:46:40 amehrotr ship $ */

--
-- Procedure     : debug
-- Purpose       :
--
--
PROCEDURE debug(p_msg IN VARCHAR2) IS
BEGIN
	 --dbms_output.put_line('pa_opportunity_mgt_pvt'|| ' : ' || p_msg);

		 PA_DEBUG.WRITE(
		 x_module => 'pa.plsql.pa_opportunity_mgt_pvt',
		 x_msg => p_msg,
		 x_log_level => 3);
   		pa_debug.write_file('LOG', p_msg);
END debug;

--
-- Procedure     : modify_project_attributes
-- Purpose       :
--
--
PROCEDURE modify_project_attributes
(       p_project_id                 IN   NUMBER   ,
        p_opportunity_value          IN   NUMBER   ,
        p_opp_value_currency_code    IN   VARCHAR2 ,
        p_expected_approval_date     IN   DATE     ,
        p_update_project             IN   VARCHAR2 := 'N',
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
 CURSOR c1 IS
   SELECT projfunc_currency_code, project_currency_code, org_id, probability_member_id
   FROM pa_projects_all  -- Bug#3807805 Modified pa_projects to pa_projects_all
   WHERE project_id = p_project_id;

  v_c1 c1%ROWTYPE;
  l_opp_value_currency_code FND_CURRENCIES_VL.currency_code%TYPE;
  l_conversion_date DATE;
  l_date DATE;
  l_default_rate_type VARCHAR2(30);
  l_type VARCHAR2(30);
  l_projfunc_opp_value NUMBER;
  l_project_opp_value NUMBER;
  l_status VARCHAR2(80);
  l_dummy_number NUMBER;
  --Bug: 4537865
  l_new_msg_data	VARCHAR2(2000);
  l_tmp_number		NUMBER;
  l_new1_dummy_number	NUMBER;
  l_new2_dummy_number   NUMBER;
  --Bug: 4537865
  l_msg_index_out NUMBER;
  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode            VARCHAR2(10);
  --Bug:4469336

  l_can_not_convert_currency EXCEPTION;
  l_prob_exp_date_valid_error EXCEPTION;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
  --Bug:4469336

 --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
 IF l_debug_mode = 'Y' then

  debug('p_project_id = '||p_project_id);
  debug('p_opportunity_value = ' || p_opportunity_value);
  debug('p_opp_value_currency_code = '|| p_opp_value_currency_code );
  debug('p_expected_approval_date = '||p_expected_approval_date);
END IF;

  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;

  -- 2449770: Added cross field validation between probability and expected
  -- approval date when creating projects.
  IF p_update_project = 'N' AND
    ((v_c1.probability_member_id IS NULL AND p_expected_approval_date IS NOT NULL)     OR
     (v_c1.probability_member_id IS NOT NULL AND p_expected_approval_date IS NULL))  AND
     is_proj_opp_associated(p_project_id)= 'Y' THEN  /* Added for bug 3330438 */
    RAISE l_prob_exp_date_valid_error;
  END IF;

  -- 2331568: Added code below because check_currency API
  -- fails if currency is null.  Therefore, we bypass the call in the
  -- case that currency is null.
  IF p_opportunity_value IS NULL THEN

       --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

      IF l_debug_mode = 'Y' then
        debug('p_opportunity_value is null');
      END IF;

      l_projfunc_opp_value := NULL;
      PA_PROJ_OPP_ATTRS_PKG.update_row (p_project_id => p_project_id,
        p_opportunity_value          => NULL,
        p_opp_value_currency_code    => NULL,
        p_projfunc_opp_value         => NULL,
        p_projfunc_opp_rate_type     => NULL,
        p_projfunc_opp_rate_date     => NULL,
        p_project_opp_value          => NULL,
        p_project_opp_rate_type      => NULL,
        p_project_opp_rate_date      => NULL,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);
  ELSIF p_opportunity_value = 0 THEN

      --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
      IF l_debug_mode = 'Y' THEN
         debug('p_opportunity_value = 0');
      END IF;

      l_projfunc_opp_value := 0;
      PA_PROJ_OPP_ATTRS_PKG.update_row (p_project_id => p_project_id,
        p_opportunity_value          => 0,
        p_opp_value_currency_code    => p_opp_value_currency_code, --changed from NULL to p_opp_value_currency_code for BUg 4129683
        p_projfunc_opp_value         => 0,
        p_projfunc_opp_rate_type     => NULL,
        p_projfunc_opp_rate_date     => NULL,
        p_project_opp_value          => 0,
        p_project_opp_rate_type      => NULL,
        p_project_opp_rate_date      => NULL,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);
  ELSE

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      PA_OPPORTUNITY_MGT_PVT.validate_value_fields(p_opportunity_value => p_opportunity_value,
      p_opp_value_currency_code =>  p_opp_value_currency_code,
      p_projfunc_currency_code  =>  v_c1.projfunc_currency_code,
      p_project_currency_code   =>  v_c1.project_currency_code,
      x_return_status           =>  x_return_status,
      x_msg_count               =>  x_msg_count,
      x_msg_data                =>  x_msg_data);

      --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
      IF l_debug_mode = 'Y' THEN
         debug('After validate_value_fields: x_return_status = ' || x_return_status);
      END IF;

    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      PA_PROJECTS_MAINT_UTILS.check_currency_name_or_code (
      p_agreement_currency      => p_opp_value_currency_code,
      p_agreement_currency_name => NULL,
      p_check_id_flag           => 'Y',
      x_agreement_currency      => l_opp_value_currency_code,
      x_return_status           => x_return_status,
      x_error_msg_code          => x_msg_data);

      -- This if condition is Added for Bug 5214782
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 	PA_UTILS.ADD_MESSAGE('PA', x_msg_data);
      END IF ;
      -- End of 5214782
      --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
       IF l_debug_mode = 'Y' THEN
       		 debug('l_opp_value_currency_code = ' || l_opp_value_currency_code);
        	 debug('After check_currency_name_or_code: x_return_status = ' || x_return_status);
       END IF;

    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF l_opp_value_currency_code = v_c1.projfunc_currency_code AND l_opp_value_currency_code = v_c1.project_currency_code THEN

         --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
         IF l_debug_mode = 'Y' THEN
           debug('SAME currency codes');
         END IF;

        l_projfunc_opp_value := p_opportunity_value;
        PA_PROJ_OPP_ATTRS_PKG.update_row (p_project_id => p_project_id,
         p_opportunity_value          => p_opportunity_value,
         p_opp_value_currency_code    => l_opp_value_currency_code,
         p_projfunc_opp_value         => p_opportunity_value,
         p_projfunc_opp_rate_type     => NULL,
         p_projfunc_opp_rate_date     => NULL,
         p_project_opp_value          => p_opportunity_value,
         p_project_opp_rate_type      => NULL,
         p_project_opp_rate_date      => NULL,
         x_return_status           =>  x_return_status,
         x_msg_count               =>  x_msg_count,
         x_msg_data                =>  x_msg_data);
      ELSIF PA_OPPORTUNITY_MGT_PVT.is_opp_multi_currency_setup = 'Y' THEN

        --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

          IF l_debug_mode = 'Y' THEN
        	debug('is_opp_multi_currency_setup = Y');
        	debug('Need currency conversion');
        	debug('opp_value_currency_code = '|| l_opp_value_currency_code);
        	debug('projfunc_currency_code = '|| v_c1.projfunc_currency_code);
        	debug('project_currency_code = '|| v_c1.project_currency_code);
          END IF;

        -- Get default rate type.
        PA_OPPORTUNITY_MGT_PVT.get_opp_multi_currency_setup(
            x_default_rate_type            => l_default_rate_type,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data);

        --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

        IF l_debug_mode = 'Y' THEN
        	debug('l_default_rate_type = '|| l_default_rate_type);
        END IF;

        -- Get conversion date.
        l_conversion_date := PA_UTILS2.get_pa_date(
             p_ei_date => p_expected_approval_date,
             p_gl_date => sysdate,
             p_org_id  => v_c1.org_id);

        --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

          IF l_debug_mode = 'Y' THEN
        	debug('l_conversion_date = '|| l_conversion_date);
	  END IF;

        -- 2410298: p_conversion_date and p_conversion_type are IN/OUT params.
        l_date := l_conversion_date;
        l_type := l_default_rate_type;
        -- Convert p_opportunity_value to projfunc_currency_code.
        -- Bug: 4537865
	l_tmp_number := l_dummy_number ;
	l_new1_dummy_number := l_tmp_number;
	l_new2_dummy_number := l_tmp_number;
   	-- Bug: 4537865
        PA_MULTI_CURRENCY.convert_amount(
          p_from_currency              => l_opp_value_currency_code,
          p_to_currency                => v_c1.projfunc_currency_code,
          p_conversion_date            => l_date,
          p_conversion_type            => l_type,
          p_amount                     => p_opportunity_value,
          p_user_validate_flag         => 'Y',
          p_handle_exception_flag      => 'Y',
          p_converted_amount           => l_projfunc_opp_value,
          p_denominator                => l_dummy_number,
        --p_numerator                  => l_dummy_number,	Bug: 4537865
          p_numerator		       => l_new1_dummy_number,  --Bug: 4537865
        --p_rate                       => l_dummy_number,	Bug: 4537865
          p_rate		       => l_new2_dummy_number,  --Bug: 4537865
          x_status                     => l_status);

        --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

          IF l_debug_mode = 'Y' THEN
         	debug('l_status = '|| l_status);
          END IF;

        IF l_status IS NOT NULL AND l_status <> 'N' THEN

          --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

          IF l_debug_mode = 'Y' THEN
          	debug('Raise l_can_not_convert_currency :1');
          END IF;

          PA_UTILS.add_message('PA', l_status);
          RAISE l_can_not_convert_currency;
        END IF;

        -- Convert p_opportunity_value to project_currency_code.
        l_date := l_conversion_date;
        l_type := l_default_rate_type;
	-- Bug: 4537865
        l_new1_dummy_number := l_tmp_number;
        l_new2_dummy_number := l_tmp_number;
        -- Bug: 4537865

        PA_MULTI_CURRENCY.convert_amount(
          p_from_currency              => l_opp_value_currency_code,
          p_to_currency                => v_c1.project_currency_code,
          p_conversion_date            => l_date,
          p_conversion_type            => l_type,
          p_amount                     => p_opportunity_value,
          p_user_validate_flag         => 'Y',
          p_handle_exception_flag      => 'Y',
          p_converted_amount           => l_project_opp_value,
          p_denominator                => l_dummy_number,
        --p_numerator                  => l_dummy_number,       Bug: 4537865
          p_numerator                  => l_new1_dummy_number,  --Bug: 4537865
        --p_rate                       => l_dummy_number,       Bug: 4537865
          p_rate                       => l_new2_dummy_number,  --Bug: 4537865
          x_status                     => l_status);

        --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file

          IF l_debug_mode = 'Y' THEN
	        debug('l_project_opp_value = '|| l_project_opp_value);
        	debug('l_status = '|| l_status);
          END IF;

        IF l_status IS NOT NULL AND l_status <> 'N' THEN

          --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
          IF l_debug_mode = 'Y' THEN
          	debug('Raise l_can_not_convert_currency :2');
 	  END IF;

          PA_UTILS.add_message('PA', l_status);
          RAISE l_can_not_convert_currency;
        END IF;

        PA_PROJ_OPP_ATTRS_PKG.update_row (p_project_id => p_project_id,
          p_opportunity_value          => p_opportunity_value,
          p_opp_value_currency_code    => l_opp_value_currency_code,
          p_projfunc_opp_value         => l_projfunc_opp_value,
          p_projfunc_opp_rate_type     => l_default_rate_type,
          p_projfunc_opp_rate_date     => l_conversion_date,
          p_project_opp_value          => l_project_opp_value,
          p_project_opp_rate_type      => l_default_rate_type,
          p_project_opp_rate_date      => l_conversion_date,
          x_return_status           =>  x_return_status,
          x_msg_count               =>  x_msg_count,
          x_msg_data                =>  x_msg_data);

	--Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
        IF l_debug_mode = 'Y' THEN
        	debug('After update_row');
	END IF;
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN l_can_not_convert_currency THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_CAN_NOT_CONVERT_CURRENCY';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count = 1 THEN
		  pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
        --Bug: 4537865
		End IF;
  WHEN l_prob_exp_date_valid_error THEN
    PA_UTILS.add_message('PA', 'PA_PROB_EXP_DATE_VALID_ERROR');
    x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data      := 'PA_OPP_MULTI_CURRENCY_ERROR';
		x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count = 1 THEN
		  pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
			              --p_data           => x_msg_data,		* Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
	--Bug: 4537865
	x_msg_data := l_new_msg_data;
	--Bug: 4537865
		End IF;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'modify_project_attributes');
   raise;

END modify_project_attributes;


--
-- Procedure     : copy_project_attributes
-- Purpose       :
--
--
PROCEDURE copy_project_attributes
(       p_source_project_id          IN   NUMBER   ,
        p_dest_project_id            IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  CURSOR c1 IS
    SELECT opportunity_value, opp_value_currency_code, projfunc_opp_value, projfunc_opp_rate_type, projfunc_opp_rate_date, project_opp_value, project_opp_rate_type, project_opp_rate_date
    FROM pa_project_opp_attrs
    WHERE project_id = p_source_project_id;

  v_c1 c1%ROWTYPE;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;

  PA_PROJ_OPP_ATTRS_PKG.insert_row ( p_project_id => p_dest_project_id,
        p_opportunity_value          => v_c1.opportunity_value,
        p_opp_value_currency_code    => v_c1.opp_value_currency_code,
        p_projfunc_opp_value         => v_c1.projfunc_opp_value,
        p_projfunc_opp_rate_type     => v_c1.projfunc_opp_rate_type,
        p_projfunc_opp_rate_date     => v_c1.projfunc_opp_rate_date,
        p_project_opp_value          => v_c1.project_opp_value,
        p_project_opp_rate_type      => v_c1.project_opp_rate_type,
        p_project_opp_rate_date      => v_c1.project_opp_rate_date,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'copy_project_attributes');
   raise;

END copy_project_attributes;


--
-- Procedure     : create_project_attributes
-- Purpose       :
--
--
PROCEDURE create_project_attributes
(       p_project_id                 IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  CURSOR c1 IS
    SELECT project_value, projfunc_currency_code, project_currency_code, expected_approval_date, org_id
      FROM pa_projects
      WHERE project_id = p_project_id;

  v_c1 c1%ROWTYPE;

  l_default_rate_type VARCHAR2(30);
  l_conversion_date DATE;
  l_converted_amount NUMBER;
  l_status VARCHAR2(80);
  l_dummy_number NUMBER;
  --Bug: 4537865
  l_tmp_number	      NUMBER;
  l_new1_dummy_number NUMBER;
  l_new2_dummy_number NUMBER;
  l_new_msg_data      VARCHAR2(2000);
  -- Bug: 4537865
  l_msg_index_out NUMBER;

  l_can_not_convert_currency EXCEPTION;

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode            VARCHAR2(10);
  --Bug:4469336

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
  --Bug:4469336

  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;

  IF v_c1.project_value IS NULL THEN
    PA_PROJ_OPP_ATTRS_PKG.insert_row ( p_project_id => p_project_id,
        p_opportunity_value          => NULL,
        p_opp_value_currency_code    => NULL,
        p_projfunc_opp_value         => NULL,
        p_projfunc_opp_rate_type     => NULL,
        p_projfunc_opp_rate_date     => NULL,
        p_project_opp_value          => NULL,
        p_project_opp_rate_type      => NULL,
        p_project_opp_rate_date      => NULL,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);
  ELSIF v_c1.projfunc_currency_code = v_c1.project_currency_code THEN
    PA_PROJ_OPP_ATTRS_PKG.insert_row ( p_project_id => p_project_id,
        p_opportunity_value          => v_c1.project_value,
        p_opp_value_currency_code    => v_c1.projfunc_currency_code,
        p_projfunc_opp_value         => v_c1.project_value,
        p_projfunc_opp_rate_type     => NULL,
        p_projfunc_opp_rate_date     => NULL,
        p_project_opp_value          => v_c1.project_value,
        p_project_opp_rate_type      => NULL,
        p_project_opp_rate_date      => NULL,
        x_return_status           =>  x_return_status,
        x_msg_count               =>  x_msg_count,
        x_msg_data                =>  x_msg_data);
  ELSIF PA_OPPORTUNITY_MGT_PVT.is_opp_multi_currency_setup = 'Y' THEN
     -- Get default rate type.
     PA_OPPORTUNITY_MGT_PVT.get_opp_multi_currency_setup(
            x_default_rate_type            => l_default_rate_type,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data);
    l_conversion_date := PA_UTILS2.get_pa_date(
             p_ei_date => v_c1.expected_approval_date,
             p_gl_date => sysdate,
             p_org_id  => v_c1.org_id);
    -- Convert pa_projects_all.project_value to prject_currency_code and
    -- store it in pa_project_opp_attrs.project_opp_value.
    -- Bug: 4537865

    l_tmp_number := l_dummy_number ;
    l_new1_dummy_number := l_tmp_number;
    l_new2_dummy_number := l_tmp_number;
    -- Bug: 4537865
    PA_MULTI_CURRENCY.convert_amount(
          p_from_currency              => v_c1.projfunc_currency_code,
          p_to_currency                => v_c1.project_currency_code,
          p_conversion_date            => l_conversion_date,
          p_conversion_type            => l_default_rate_type,
          p_amount                     => v_c1.project_value,
          p_user_validate_flag         => 'Y',
          p_handle_exception_flag      => 'Y',
          p_converted_amount           => l_converted_amount,
          p_denominator                => l_dummy_number,
        --p_numerator                  => l_dummy_number,       Bug: 4537865
          p_numerator                  => l_new1_dummy_number,  --Bug: 4537865
        --p_rate                       => l_dummy_number,       Bug: 4537865
          p_rate                       => l_new2_dummy_number,  --Bug: 4537865
          x_status                     => l_status);

    --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
    IF l_debug_mode = 'Y' THEN
    	debug('l_converted_amount = ' || l_converted_amount);
    	debug('l_status = '|| l_status);
    END IF;

    IF l_status IS NOT NULL AND l_status <> 'N' THEN
      PA_UTILS.add_message('PA', l_status);
        RAISE l_can_not_convert_currency;
    END IF;

    PA_PROJ_OPP_ATTRS_PKG.insert_row ( p_project_id => p_project_id,
            p_opportunity_value          => v_c1.project_value,
            p_opp_value_currency_code    => v_c1.projfunc_currency_code,
            p_projfunc_opp_value         => v_c1.project_value,
            p_projfunc_opp_rate_type     => NULL,
            p_projfunc_opp_rate_date     => NULL,
            p_project_opp_value          => l_converted_amount,
            p_project_opp_rate_type      => l_default_rate_type,
            p_project_opp_rate_date      => l_conversion_date,
            x_return_status           =>  x_return_status,
            x_msg_count               =>  x_msg_count,
            x_msg_data                =>  x_msg_data);
  ELSE
    PA_PROJ_OPP_ATTRS_PKG.insert_row ( p_project_id => p_project_id,
          p_opportunity_value          => v_c1.project_value,
          p_opp_value_currency_code    => v_c1.projfunc_currency_code,
          p_projfunc_opp_value         => v_c1.project_value,
          p_projfunc_opp_rate_type     => NULL,
          p_projfunc_opp_rate_date     => NULL,
          p_project_opp_value          => NULL,
          p_project_opp_rate_type      => NULL,
          p_project_opp_rate_date      => NULL,
          x_return_status           =>  x_return_status,
          x_msg_count               =>  x_msg_count,
          x_msg_data                =>  x_msg_data);
  END IF;

EXCEPTION
  WHEN l_can_not_convert_currency THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_CAN_NOT_CONVERT_CURRENCY';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count = 1 THEN
		  pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		End IF;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'create_project_attributes');
   raise;

END create_project_attributes;


--
-- Procedure     : delete_project_attributes
-- Purpose       :
--
--
PROCEDURE delete_project_attributes
(       p_project_id                 IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
  CURSOR c1 IS
    SELECT object_id_from1 request_id
    FROM pa_object_relationships
    WHERE relationship_type = 'A'
    AND object_type_from = 'PA_PROJECT_REQUESTS'
    AND object_type_to = 'PA_PROJECTS'
    AND object_id_to1 = p_project_id;

  l_request_id NUMBER;

  CURSOR c2 IS
    SELECT object_relationship_id, record_version_number
    FROM pa_object_relationships
    WHERE ((object_type_from = 'PA_PROJECT_REQUESTS'
           AND object_type_to = 'PA_PROJECTS'
           AND object_id_from1 = l_request_id
           AND object_id_to1 = p_project_id) OR
          (object_type_from = 'PA_PROJECTS'
           AND object_type_to = 'PA_PROJECT_REQUESTS'
           AND object_id_from1 = p_project_id
           AND object_id_to1 = l_request_id))
    AND relationship_type = 'A'
    AND relationship_subtype = 'PROJECT_REQUEST';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Delete attributes from pa_proj_opportunity_attributes.
  PA_PROJ_OPP_ATTRS_PKG.delete_row(p_project_id => p_project_id,
       x_return_status           =>  x_return_status,
       x_msg_count               =>  x_msg_count,
       x_msg_data                =>  x_msg_data);

  -- If the project has a project request associated with it, then revert the status of the
  -- project request to 'OPEN'.
  -- Delete the object relationships between the project and the project request.
  FOR v_c1 IN c1 LOOP
    -- Change project request status.
    PA_PROJECT_REQUEST_PKG.update_row(p_request_id => v_c1.request_id,
       p_request_status_code     => '121',
       x_return_status           =>  x_return_status,
       x_msg_count               =>  x_msg_count,
       x_msg_data                =>  x_msg_data);

    -- Delete relationship.
    l_request_id := v_c1.request_id;
    FOR v_c2 IN c2 LOOP
      PA_OBJECT_RELATIONSHIPS_PKG.delete_row (
        p_object_relationship_id => v_c2.object_relationship_id,
        p_object_type_from       => NULL,
        p_object_id_from1        => NULL,
        p_object_id_from2        => NULL,
        p_object_id_from3        => NULL,
        p_object_id_from4        => NULL,
        p_object_id_from5        => NULL,
        p_object_type_to         => NULL,
        p_object_id_to1          => NULL,
        p_object_id_to2          => NULL,
        p_object_id_to3          => NULL,
        p_object_id_to4          => NULL,
        p_object_id_to5          => NULL,
	      p_record_version_number  => v_c2.record_version_number,
        p_pm_product_code        => NULL,
	      x_return_status		       => x_return_status);
    END LOOP;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'delete_project_attributes');
   raise;

END delete_project_attributes;


--
-- Procedure     : validate_value_fields
-- Purpose       :
--
--
PROCEDURE validate_value_fields
(       p_opportunity_value          IN   NUMBER   := NULL,
        p_opp_value_currency_code    IN   VARCHAR2 := NULL,
        p_projfunc_currency_code     IN   VARCHAR2 ,
        p_project_currency_code      IN   VARCHAR2 ,
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
 l_opp_value_currency_missing  EXCEPTION;
 l_opp_multi_currency_error    EXCEPTION;
 l_msg_index_out NUMBER;
 --Bug: 4537865
 l_new_msg_data	 VARCHAR2(2000);
 --Bug: 4537865

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_opportunity_value IS NULL THEN
    RETURN;
  ELSIF p_opp_value_currency_code IS NULL THEN
    RAISE l_opp_value_currency_missing;
  ELSIF p_opp_value_currency_code = p_projfunc_currency_code AND p_opp_value_currency_code = p_project_currency_code THEN
    RETURN;
  ELSIF PA_OPPORTUNITY_MGT_PVT.is_opp_multi_currency_setup = 'N' THEN
    RAISE l_opp_multi_currency_error;
  END IF;

EXCEPTION
  WHEN l_opp_value_currency_missing THEN
    PA_UTILS.add_message('PA', 'PA_OPP_VALUE_CURRENCY_MISSING');
    x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data      := 'PA_OPP_VALUE_CURRENCY_MISSING';
		x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count = 1 THEN
		  pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		End IF;
  WHEN l_opp_multi_currency_error THEN
    PA_UTILS.add_message('PA', 'PA_OPP_MULTI_CURRENCY_ERROR');
    x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data      := 'PA_OPP_MULTI_CURRENCY_ERROR';
		x_msg_count := FND_MSG_PUB.Count_Msg;
    IF x_msg_count = 1 THEN
		  pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* Bug: 4537865
					p_data		 => l_new_msg_data,	--Bug: 4537865
					p_msg_index_out  => l_msg_index_out );
		--Bug: 4537865
		x_msg_data := l_new_msg_data;
		--Bug: 4537865
		End IF;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'validate_value_fields');
   raise;

END validate_value_fields;


--
-- Procedure     : get_opp_multi_currency_setup
-- Purpose       :
--
--
PROCEDURE get_opp_multi_currency_setup
(       x_default_rate_type          OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

  SELECT default_rate_type
  INTO x_default_rate_type
  FROM pa_implementations;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'get_opp_multi_currency_setup');
   raise;
END get_opp_multi_currency_setup;


--
-- Procedure     : get_opp_multi_currency_setup (overloaded)
-- Purpose       :
--
--
PROCEDURE get_opp_multi_currency_setup
(       p_org_id                     IN   NUMBER   ,
        x_default_rate_type          OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

  SELECT default_rate_type
  INTO x_default_rate_type
  FROM pa_implementations_all
  WHERE org_id = p_org_id; --MOAC Changes: Bug 4363092: removed nvl usage with org_id

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'delete_project_attributes');
   raise;
END get_opp_multi_currency_setup;


--
-- Function      : is_opp_multi_currency_setup
-- Purpose       :
--
--
FUNCTION is_opp_multi_currency_setup RETURN VARCHAR2

IS
  CURSOR c1 IS
    SELECT default_rate_type
    FROM pa_implementations;

  v_c1 c1%ROWTYPE;
  l_result VARCHAR2(1);

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
	l_debug_mode            VARCHAR2(10);
  --Bug:4469336

BEGIN

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
  --Bug:4469336

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    l_result := 'N';
  ELSE
    IF v_c1.default_rate_type IS NULL THEN
      l_result := 'N';
    ELSE

      --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
	IF l_debug_mode = 'Y' THEN
      		debug('default_rate_type = '|| v_c1.default_rate_type);
    	END IF;
      l_result := 'Y';
    END IF;
  END IF;
  CLOSE c1;

  RETURN(l_result);

EXCEPTION
  WHEN OTHERS THEN
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'is_opp_multi_currency_setup');
   raise;

END is_opp_multi_currency_setup;


--
-- Function      : is_opp_multi_currency_setup (overloaded)
-- Purpose       :
--
--
FUNCTION is_opp_multi_currency_setup (p_org_id   IN   NUMBER) RETURN VARCHAR2

IS
  CURSOR c1 IS
    SELECT default_rate_type
    FROM pa_implementations_all
    WHERE org_id = p_org_id; --MOAC Changes: Bug 4363092: removed nvl usage with org_id

  v_c1 c1%ROWTYPE;
  l_result VARCHAR2(1);

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
	l_debug_mode            VARCHAR2(10);
  --Bug:4469336

BEGIN

  --Bug:4469336 Added for avoiding blind calls to pa_debug.write and pa_debug.write_file
  l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
  --Bug:4469336

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    l_result := 'N';
  ELSE
    IF v_c1.default_rate_type IS NULL THEN
      l_result := 'N';
    ELSE

      --Bug:4469336. Added the if condition for avoiding blind calls to pa_debug.write and pa_debug.write_file
      IF l_debug_mode = 'Y' then
      debug('default_rate_type = '|| v_c1.default_rate_type);
      end IF;

      l_result := 'Y';
    END IF;
  END IF;
  CLOSE c1;

  RETURN(l_result);

EXCEPTION
  WHEN OTHERS THEN
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'is_opp_multi_currency_setup');
   raise;

END is_opp_multi_currency_setup;


--
-- Function      : is_proj_opp_associated
-- Purpose       : Check whether a project has association with an opportunity.
--
--
FUNCTION is_proj_opp_associated(p_project_id   IN   NUMBER) RETURN VARCHAR2

IS
-- Start of changes for bug 4757078
/* CURSOR c1 IS
    SELECT object_type_from, object_type_to
			 FROM pa_object_relationships
			 WHERE relationship_type = 'A'
			 AND relationship_subtype = 'PROJECT_REQUEST'
			 START WITH (object_type_from = 'PA_PROJECTS'
         AND object_type_to = 'PA_PROJECT_REQUESTS'
         AND object_id_from1 = p_project_id)
       CONNECT BY (PRIOR object_id_to1 = object_id_from1
         AND PRIOR object_id_from1 <> object_id_to1);*/

CURSOR c1 IS
    SELECT object_type_from, object_type_to
			 FROM pa_object_relationships
			 START WITH (object_type_from = 'PA_PROJECTS'
         AND object_type_to = 'PA_PROJECT_REQUESTS'
         AND object_id_from1 = p_project_id)
       CONNECT BY (PRIOR object_id_to1 = object_id_from1
         AND PRIOR object_id_from1 <> object_id_to1
         AND PRIOR object_type_to = object_type_from   -- bug 9014325
	 AND relationship_type = 'A'
	 AND relationship_subtype = 'PROJECT_REQUEST');

-- End of changes for bug 4757078

  l_flag VARCHAR2(1);

BEGIN

  l_flag := 'N';
  FOR v_c1 IN c1 LOOP
    IF v_c1.object_type_from = 'PA_PROJECT_REQUESTS' AND v_c1.object_type_to = 'AS_LEADS' THEN
      l_flag := 'Y';
      EXIT;
    END IF;
  END LOOP;

  RETURN(l_flag);

EXCEPTION
  WHEN OTHERS THEN
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_OPPORTUNITY_MGT_PVT',
                          p_procedure_name   => 'is_proj_opp_associated');
   raise;

END is_proj_opp_associated;


END PA_OPPORTUNITY_MGT_PVT;

/
