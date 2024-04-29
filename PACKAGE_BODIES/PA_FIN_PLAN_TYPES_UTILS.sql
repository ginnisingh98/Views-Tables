--------------------------------------------------------
--  DDL for Package Body PA_FIN_PLAN_TYPES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FIN_PLAN_TYPES_UTILS" as
/* $Header: PAFTYPUB.pls 120.1 2005/08/19 16:32:29 mwasowic noship $ */

/*********************************************************************
 Important : The appropriate procedures that make a call to the below
 procedures must make a call to FND_MSG_PUB.initialize.
**********************************************************************/

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_fin_plan_types_utils';

procedure name_val
    (p_name                         IN     pa_fin_plan_types_tl.name%TYPE,
     p_fin_plan_type_id             IN
 pa_fin_plan_types_tl.fin_plan_type_id%TYPE,
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  is
 l_exists VARCHAR2(1);
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
 l_name_exists     boolean;--for bug  2625505



 l_language_code   FND_LANGUAGES.LANGUAGE_CODE%TYPE ;
 l_curr_language   FND_LANGUAGES.LANGUAGE_CODE%TYPE ;


begin

    if p_name is NULL then
        /* Name must be entered */
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_MANDATORY_INFO_MISSING');
    end if;

    /*Commenting out this code as it is not used any more (bug 2625505) and
 initialising
     l_name_exists to false*/
    /*
    l_msg_count := FND_MSG_PUB.count_msg; --For bug 2625505
    */
    l_name_exists:=false;

    Begin
      select 'Y'
      into   l_exists
      from   pa_fin_plan_types_vl
      where  upper(name) = upper(p_name)
      and    fin_plan_type_id <> p_fin_plan_type_id
      and    rownum < 2;

      /* Duplicate Name should not be entered */
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_ALL_UNIQUE_NAME_EXISTS');
      /*Initialise the boolean variable here. bug 2625505)*/
      l_name_exists:=true;
    exception
      when NO_DATA_FOUND then
        null;
    end;
  --  26-SEP-2002

    Select language_code
           ,userenv('LANG')
     into  l_language_code
           ,l_curr_language
     from  fnd_languages
    where  installed_flag = 'B';

    /*Display this message only if the budget type is not already upgraded and a plan
 type for
      that budget type already exists. Modifed the if below for this check(bug
 2625505)
    */

    /*IF  (upper(l_language_code) = upper(l_curr_language)) THEN
    */
    IF ( (upper(l_language_code) = upper(l_curr_language)) AND
      /*   (FND_MSG_PUB.count_msg = l_msg_count) )THEN*/ --This condition is not used any  more (bug 2625505)
         (l_name_exists=false)) THEN
     -- This comparison is only required when the
     -- currently installed language is same as
     -- base language.

    BEGIN
      /* Bug 2755795 - We should checking if the fin plan type name is
         being updated for an upgraded budget type. The check should be
         done in such a way to exclude checking the budget type from
         which this plan type was upgraded */

      /*Commented out the sql for bug  2774573 */
      /*
      SELECT 'Y'
      INTO    l_exists
      FROM    pa_budget_types a, pa_fin_plan_types_b b
      WHERE   upper(budget_type) = upper(p_name)
      AND     b.fin_plan_type_id = p_fin_plan_type_id
      AND     a.budget_type_code <> b.migrated_frm_bdgt_typ_code;
      */
      /* The error should be thrown when
          1. A budget type exists with the name of the plan type about to be created
         The error should not be thrown when
           1. updating an upgraded plan type
      */
      SELECT 'Y'
      INTO  l_exists
      FROM  pa_budget_types a
      WHERE upper(a.budget_type) = upper(p_name)
      AND NOT EXISTS( SELECT 'x'
                      FROM   pa_fin_plan_types_b f
                      WHERE  f.fin_plan_type_id=p_fin_plan_type_id
                      AND    nvl
 (f.migrated_frm_bdgt_typ_code,'-99')=a.budget_type_code);

      /* Duplicate Name should not be entered */
      x_return_status := FND_API.G_RET_STS_ERROR;
      PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            =>
 'PA_FP_RESERVED_PLAN_TYPE_NAME');/*Changed the message name (bug 2625505)*/
    EXCEPTION
      when NO_DATA_FOUND then
        null;
    END;
    END IF;

  -- 26-SEP-2002
    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;


Exception
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'name_val');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end name_val;

/****************************************************************************************
 Commented as part of Dusan changes and moved the api to PA_FIN_PLAN_UTILS
procedure end_date_active_val
    (p_start_date_active              IN
 pa_fin_plan_types_b.start_date_active%type,
     p_end_date_active                IN
 pa_fin_plan_types_b.end_date_active%type,
     x_return_status              OUT    VARCHAR2,
     x_msg_count                  OUT    NUMBER,
     x_msg_data                   OUT    VARCHAR2)
  is
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
begin

  if p_start_date_active is null then
        -- Start date must be entered
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_MANDATORY_INFO_MISSING');
  end if;

  if p_start_date_active > nvl(p_end_date_active,p_start_date_active) then
        -- The End Date cannot be earlier than the Start Date.
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_INVALID_END_DATE');
  end if;

    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

exception
    when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'end_date_active_val');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end end_date_active_val;
***********************************************************************************/

/************************************************************************************
*
Commented since generated_flag and used_in_billing_flag
are obsolete after change in functionality

procedure generated_flag_val
    (p_fin_plan_type_id               IN
 pa_fin_plan_types_b.fin_plan_type_id%type,
     p_generated_flag                 IN     pa_fin_plan_types_b.generated_flag%type,
     p_pre_defined_flag               IN
 pa_fin_plan_types_b.pre_defined_flag%type,
     p_fin_plan_type_code             IN
 pa_fin_plan_types_b.fin_plan_type_code%type,
     p_name                           IN     pa_fin_plan_types_tl.name%type,
     x_return_status              OUT    VARCHAR2,
     x_msg_count                  OUT    NUMBER,
     x_msg_data                   OUT    VARCHAR2)
  is
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
begin

  if p_fin_plan_type_code = 'ORG_FORECAST' and
     p_pre_defined_flag   = 'Y'            and
     p_generated_flag     = 'N' then
     -- Generated_flag should be 'Y' for ORG_FORECAST finplantype
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FPTYPE_GENFLAG_NOUPD',
                             p_token1              => 'PLAN_TYPE',
                             p_value1              => p_name);

  end if;

    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

exception
  when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'generated_flag_val');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end generated_flag_val;

procedure used_in_billing_flag_val
    (p_fin_plan_type_id               IN
 pa_fin_plan_types_b.fin_plan_type_id%type,
     p_used_in_billing_flag           IN
 pa_fin_plan_types_b.used_in_billing_flag%type,
     x_return_status              OUT    VARCHAR2,
     x_msg_count                  OUT    NUMBER,
     x_msg_data                   OUT    VARCHAR2)
  is
 l_count NUMBER;
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
begin

  Select count(*)
  into   l_count
  from   pa_fin_plan_types_b
  where  fin_plan_type_id <> p_fin_plan_type_id
  and    used_in_billing_flag = 'Y';

  if p_used_in_billing_flag = 'Y' and l_count > 0 then
        -- Only one financial plan type should have USED_IN_BILLING_FLAG as 'Y'
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            =>
 'PA_FPTYPE_USED_IN_BILL_NOUPD');
  end if;

    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

exception
  when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'used_in_billing_flag_val');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end used_in_billing_flag_val;

************************************************************************************/

procedure delete_val
    (p_fin_plan_type_id               IN
 pa_fin_plan_types_b.fin_plan_type_id%type,
     x_return_status              OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                   OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  is
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
begin

  if pa_fin_plan_types_utils.isfptypeused(p_fin_plan_type_id => p_fin_plan_type_id) =
 'Y' then
    /* If a plan type has already been used by a project, that plan type should not
 be deleted */
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FPTYPE_IN_USE');
  end if;

    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    end if;

exception
  when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'delete_val');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end delete_val;


procedure validate
    (p_fin_plan_type_id               IN
 pa_fin_plan_types_b.fin_plan_type_id%type,
     p_name                           IN     pa_fin_plan_types_tl.name%type,
     p_start_date_active              IN
 pa_fin_plan_types_b.start_date_active%type,
     p_end_date_active                IN
 pa_fin_plan_types_b.end_date_active%type,
     p_generated_flag                 IN     pa_fin_plan_types_b.generated_flag%type,
     p_used_in_billing_flag           IN     pa_fin_plan_types_b.used_in_billing_flag%type,
     p_record_version_number          IN
 pa_fin_plan_types_b.record_version_number%type,
     p_fin_plan_type_code             IN
 pa_fin_plan_types_b.fin_plan_type_code%type,
     p_pre_defined_flag               IN
 pa_fin_plan_types_b.pre_defined_flag%type,
     x_return_status              OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                   OUT    NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
begin

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    pa_fin_plan_types_utils.name_val
    (p_name                      => p_name,
     p_fin_plan_type_id          => p_fin_plan_type_id,
     x_return_status             => x_return_status,
     x_msg_count                 => x_msg_count,
     x_msg_data                  => x_msg_data);

    pa_fin_plan_utils.end_date_active_val
    (p_start_date_active         => p_start_date_active,
     p_end_date_active           => p_end_date_active,
     x_return_status             => x_return_status,
     x_msg_count                 => x_msg_count,
     x_msg_data                  => x_msg_data);

/***********************************************************************
Commented since generated_flag and used_in_billing_flag
are obsolete after change in functionality

    pa_fin_plan_types_utils.generated_flag_val
    (p_fin_plan_type_id          => p_fin_plan_type_id,
     p_generated_flag            => p_generated_flag,
     p_pre_defined_flag          => p_pre_defined_flag,
     p_fin_plan_type_code        => p_fin_plan_type_code,
     p_name                      => p_name,
     x_return_status             => x_return_status,
     x_msg_count                 => x_msg_count,
     x_msg_data                  => x_msg_data);

    pa_fin_plan_types_utils.used_in_billing_flag_val
    (p_fin_plan_type_id         => p_fin_plan_type_id,
     p_used_in_billing_flag     => p_used_in_billing_flag,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data);

***********************************************************************/
    l_msg_count := FND_MSG_PUB.count_msg;

    if l_msg_count > 0 then
        if l_msg_count = 1 then
             PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE,
                  p_msg_index      => 1,
                  p_msg_count      => l_msg_count,
                  p_msg_data       => l_msg_data,
                  p_data           => l_data,
                  p_msg_index_out  => l_msg_index_out);
             x_msg_data  := l_data;
             x_msg_count := l_msg_count;
        else
             x_msg_count := l_msg_count;
        end if;
        return;
    end if;
exception
  when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                               p_procedure_name   => 'validate');
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
end validate;

function isfptypeused
   (p_fin_plan_type_id  IN pa_fin_plan_types_b.fin_plan_type_id%type)
   return VARCHAR2 is
  l_return VARCHAR2(1) := 'N';
begin

-- Modified SQL below for perf fix - 3961675.

  BEGIN
  SELECT 'Y'
    INTO l_return
    FROM DUAL
   WHERE EXISTS (SELECT 1
                   FROM PA_PROJ_FP_OPTIONS
                  WHERE FIN_PLAN_TYPE_ID = p_fin_plan_type_id);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       l_return := 'N';

  END;

  return l_return;

end;

/* FP M -  dbora - Function to check for any partially implemented COs in a plan type
*/
FUNCTION partially_impl_cos_exist
      (p_fin_plan_type_id     IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE,
       p_ci_type_id           IN     pa_control_items.ci_type_id%TYPE)
       RETURN VARCHAR2 is

      l_return_flag           VARCHAR2(1);
      l_partial_cos_exist     VARCHAR2(1);

      l_debug_mode            VARCHAR2(1);
      l_debug_level3          CONSTANT NUMBER := 3;
      l_module_name           VARCHAR2(100) := 'partially_impl_cos_exist:' || g_module_name;

BEGIN

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
             pa_debug.set_curr_function( p_function   => 'partially_impl_cos_exist',
                                         p_debug_mode => l_debug_mode );
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering PARTIALLY_IMPL_COS_ESIST';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'The plan type Id : ' || p_fin_plan_type_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                           l_debug_level3);
      END IF;

      IF p_fin_plan_type_id IS NULL THEN
            pa_debug.reset_curr_function;
            RETURN 'N';

      ELSIF p_ci_type_id IS NOT NULL THEN

            BEGIN
                  SELECT 'Y'
                  INTO    l_partial_cos_exist
                  FROM    DUAL
                  WHERE
                  EXISTS  (SELECT 'X'
                           FROM   pa_budget_versions bv,
                                  pa_control_items  ci
                           WHERE  ci.ci_id=bv.ci_id
                           AND    bv.fin_plan_type_id= p_fin_plan_type_id
                           AND    bv.rev_partially_impl_flag='Y'
                           AND    ci.ci_type_id = p_ci_type_id);

            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                        l_return_flag := 'N';

                  pa_debug.reset_curr_function;
                  RETURN l_return_flag;
            END;

            IF l_partial_cos_exist IS NULL THEN
                  IF l_debug_mode= 'Y' THEN
                       pa_debug.reset_curr_function;
                  END IF;

                  RETURN 'N';
            ELSE
                  IF l_debug_mode='Y' THEN
                        pa_debug.reset_curr_function;
                  END IF;

                  RETURN 'Y' ;
            END IF;

      ELSE
            BEGIN

                  SELECT 'Y'
                  INTO   l_return_flag
                  FROM   pa_budget_versions
                  WHERE  fin_plan_type_id = p_fin_plan_type_id
                  AND    rev_partially_impl_flag = 'Y'
                  AND    ci_id is not null
                  AND    ROWNUM = 1;

                  IF l_debug_mode= 'Y' THEN
                    pa_debug.reset_curr_function;
                  END IF;

                  RETURN l_return_flag;

             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_return_flag := 'N';

                        IF l_debug_mode= 'Y' THEN
                              pa_debug.reset_curr_function;
                        END IF;

                     RETURN l_return_flag;
             END;
      END IF;

      IF l_debug_mode= 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

      IF l_debug_mode= 'Y' THEN
           pa_debug.g_err_stage:= 'Leaving PARTIALLY_IMPL_COS_EXIST' ;
              pa_debug.write(l_module_name,pa_debug.g_err_stage,
                             l_debug_level3);
      END IF;

END partially_impl_cos_exist;

/* FP M - dbora - Returns the concatenated string containing all the cost/rev
 statuses.
*/

FUNCTION GET_CONCAT_STATUSES
      (p_fin_plan_type_id     IN    pa_fin_plan_types_b.fin_plan_type_id%TYPE,
       p_ci_type_id           IN    pa_pt_co_impl_statuses.ci_type_id%TYPE,
       p_impact_type_code     IN    pa_pt_co_impl_statuses.version_type%TYPE)
       RETURN VARCHAR2 IS

      l_concat_status         VARCHAR2(2000);

      l_debug_mode            VARCHAR2(1);
      l_debug_level3          CONSTANT NUMBER := 3;
      l_module_name           VARCHAR2(100) := 'GET_CONCAT_STATUSES' || g_module_name;

      CURSOR c_status_csr (c_impact_type_code VARCHAR2) IS
            SELECT   ci.project_status_name
            FROM     PA_CI_STATUSES_V ci,
                     PA_PT_CO_IMPL_STATUSES ptco
            WHERE    ptco.ci_type_id=p_ci_type_id
            AND      ptco.fin_plan_type_id=p_fin_plan_type_id
            AND      ptco.version_type=c_impact_type_code
            AND      ci.ci_type_id = ptco.ci_type_id
            AND      ci.project_status_code = ptco.status_code;

      c_status_rec          c_status_csr%ROWTYPE;

BEGIN

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
           pa_debug.set_curr_function( p_function   => 'get_concat_statuses',
                                       p_debug_mode => l_debug_mode );
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_CONCAT_STATUSES';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      OPEN c_status_csr(p_impact_type_code);

      LOOP
            FETCH c_status_csr INTO c_status_rec;
            EXIT WHEN c_status_csr%NOTFOUND;

            IF l_concat_status IS NOT NULL THEN
                  l_concat_status := l_concat_status || ',' ;
            END IF;

            l_concat_status := l_concat_status || c_status_rec.project_status_name;
      END LOOP;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'The concatened status : ' || l_concat_status;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                           l_debug_level3);
      END IF;

      CLOSE c_status_csr;

      IF l_debug_mode = 'Y' THEN
            pa_debug.reset_curr_function;
      END IF;

      RETURN l_concat_status;

EXCEPTION
      WHEN OTHERS THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.reset_curr_function;
            END IF;

            FND_MSG_PUB.add_exc_msg( p_pkg_name
                                     => 'PA_FIN_PLAN_TYPES_UTILS'
                                    ,p_procedure_name
                                     => 'Get_concate_statuses');
            RAISE;

       IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving GET_CONCAT_STATUSES';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

END GET_CONCAT_STATUSES;

PROCEDURE GET_WORKPLAN_PT_DETAILS
      (x_workplan_pt_id               OUT    NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
       x_w_pt_attached_to_proj        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

      l_debug_mode            VARCHAR2(1);
      l_debug_level3          CONSTANT NUMBER := 3;
      l_module_name           VARCHAR2(100) := 'GET_WORKPLAN_PT_DETAILS' || g_module_name;

BEGIN

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      IF l_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function   => 'get_workplan_pt_details',
                                        p_debug_mode => l_debug_mode );
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering GET_WORKPLAN_PT_DETAILS';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      BEGIN

            SELECT      fin_plan_type_id
            INTO        x_workplan_pt_id
            FROM        pa_fin_plan_types_b
            WHERE       use_for_workplan_flag = 'Y';

      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  x_workplan_pt_id := -99;
                  x_w_pt_attached_to_proj := 'N';
      END;

      IF NVL(x_workplan_pt_id,-99) <> -99  THEN
            BEGIN

                  SELECT      'Y'
                  INTO         x_w_pt_attached_to_proj
                  FROM         DUAL
                  WHERE
                  EXISTS     (SELECT   'X'
                              FROM      pa_proj_fp_options
                              WHERE     fin_plan_type_id = x_workplan_pt_id);

            EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                        x_w_pt_attached_to_proj := 'N';
            END;
      END IF;


      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving GET_WORKPLAN_PT_DETAILS';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            pa_debug.reset_curr_function;
      END IF;


EXCEPTION
      WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count     := 1;
            x_msg_data      := SQLERRM;
            FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FIN_PLAN_TYPES_UTILS',
                                     p_procedure_name   => 'get_workplan_pt_details');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_WORKPLAN_PT_DETAILS;

/* The following function returns the value 'Y' or 'N' depending upon
 * if revenue impact has been implemented partially for the given CI.
 * This function is different from the function 'partially_impl_cos_exist'
 * as it checks for partial revenue implementation for CI_ID
 */
FUNCTION Is_Rev_Impl_Partially
         (p_ci_id                IN        pa_budget_versions.ci_id%TYPE,
          p_project_id           IN        pa_budget_versions.project_id%TYPE)
RETURN VARCHAR2

IS
      l_rev_partial_impl_flag    VARCHAR2(1);
      l_debug_mode               VARCHAR2(1);
      l_debug_level3             CONSTANT NUMBER := 3;
      l_module_name              VARCHAR2(100) := 'Is_Rev_Impl_Partially';

BEGIN

      l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

      pa_debug.set_curr_function( p_function   => 'Is_Rev_Impl_Partially',
                                  p_debug_mode => l_debug_mode );

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Entering Is_Rev_Impl_Partially';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'The input Ci Id : ' || p_ci_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                           l_debug_level3);
      END IF;
      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'The input Project Id : ' || p_project_id;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,
                           l_debug_level3);
      END IF;

      BEGIN
             SELECT Nvl(rev_partially_impl_flag, 'N')
             INTO   l_rev_partial_impl_flag
             FROM   pa_budget_versions
             WHERE  ci_id = p_ci_id
             AND    project_id = p_project_id
             AND    version_type IN ('REVENUE','ALL');

      EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 l_rev_partial_impl_flag := 'N';
                 IF l_debug_mode = 'Y' THEN
                      pa_debug.g_err_stage:= 'No Impact exists';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 END IF;

                 pa_debug.reset_curr_function;
                 RETURN l_rev_partial_impl_flag;
      END;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'l_rev_partial_impl_flag is: ' || l_rev_partial_impl_flag;
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;

      IF l_debug_mode = 'Y' THEN
            pa_debug.g_err_stage:= 'Leaving Is_Rev_Impl_Partially';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      END IF;
      pa_debug.reset_curr_function;
      RETURN l_rev_partial_impl_flag;

EXCEPTION
      WHEN OTHERS THEN
            IF l_debug_mode = 'Y' THEN
                  pa_debug.g_err_stage:= 'Unexpected Error' || SQLERRM;
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
            END IF;
            pa_debug.reset_curr_function;
            RAISE;


END Is_Rev_Impl_Partially;

END pa_fin_plan_types_utils;

/
