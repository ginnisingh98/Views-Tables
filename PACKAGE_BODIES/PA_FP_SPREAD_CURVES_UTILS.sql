--------------------------------------------------------
--  DDL for Package Body PA_FP_SPREAD_CURVES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_SPREAD_CURVES_UTILS" as
/* $Header: PAFPSCUB.pls 120.1.12010000.2 2010/01/29 00:18:17 snizam ship $ */

g_module_name   VARCHAR2(100) := 'pa.plsql.pa_fp_spread_curves_utils';

/* This function checks whether the spread curve is in use in Budgeting and Forecasting or not */

FUNCTION is_spread_curve_in_use ( p_spread_curve_id IN Pa_spread_curves_b.spread_curve_id%TYPE ) RETURN VARCHAR2 IS

   /* Start of Commenting code for bug 9036322
   Cursor C1 IS
    Select 'Y' from pa_resource_assignments
    where spread_curve_id = p_spread_curve_id;
    End of Commenting code for bug 9036322 */

   -- start of new code for  bug 9036322
   Cursor C1 IS
   select distinct spread_curve_id
   from pa_resource_assignments;
   -- end  of new code for  bug 9036322

   l_return_flag varchar2(1) := 'Y';
BEGIN
     /* Start of Commenting code for bug 9036322
     open C1;
     fetch C1 into l_return_flag;

     if C1%NOTFOUND then
       l_return_flag := 'N';
     else
       close C1;
       return 'Y';
     end if;

     close C1;
     End of Commenting code for bug 9036322 */

     -- start of new code for  bug 9036322
	 if G_is_first_call = 'Y' then
	 OPEN c1;
     FETCH c1 BULK COLLECT INTO G_curve_id_tbl;
     CLOSE c1 ;

     G_is_first_call := 'N'  ;
     end if;
     for i in G_curve_id_tbl.first .. G_curve_id_tbl.last loop
      if p_spread_curve_id = G_curve_id_tbl(i) then
      return 'Y';
      end if;
     end loop;
     -- End of new code for  bug 9036322

     /* flow will come only if spread curve is not used in resource assignment */
     l_return_flag := 'N';

     if (PA_PLANNING_RESOURCE_UTILS.chk_spread_curve_in_use( p_spread_curve_id)) then
        return 'Y';
     else
        return 'N';
     end if;
END is_spread_curve_in_use;

/*==================================================================
   This api validates the following attributes of Spread Curves
   before inserting or updating
	1. Name - uniqueness.
	2. Dates - Start date is entered
	           end date if entered should be later than start date
        3. Amount in buckets should not be less than 0
 ==================================================================*/

PROCEDURE validate (
        p_spread_curve_id       IN              Pa_spread_curves_b.spread_curve_id%TYPE,
	p_name                  IN              Pa_spread_curves_tl.name%TYPE,
	P_effective_from        IN              Pa_spread_curves_b.effective_Start_date%TYPE,
	P_effective_to		IN              Pa_spread_curves_b.effective_end_date%TYPE,
	P_point1                IN              Pa_spread_curves_b.point1%TYPE,
	P_point2                IN              Pa_spread_curves_b.point2%TYPE,
	P_point3                IN              Pa_spread_curves_b.point3%TYPE,
	P_point4                IN              Pa_spread_curves_b.point4%TYPE,
	P_point5                IN              Pa_spread_curves_b.point5%TYPE,
	P_point6                IN              Pa_spread_curves_b.point6%TYPE,
	P_point7                IN              Pa_spread_curves_b.point7%TYPE,
	P_point8                IN              Pa_spread_curves_b.point8%TYPE,
	P_point9                IN              Pa_spread_curves_b.point9%TYPE,
	P_point10               IN              Pa_spread_curves_b.point10%TYPE,
	x_return_status	        OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_data              OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_msg_count             OUT             NOCOPY number	 ) --File.Sql.39 bug 4440895
AS
   l_any_error_occurred_flag VARCHAR2(1) := NULL;
   l_return_status          VARCHAR2(1) := NULL;
   l_msg_count              NUMBER      := 0;
   l_data               VARCHAR2(2000) := NULL;
   l_msg_data               VARCHAR2(2000) := NULL;
   l_msg_index_out   NUMBER;
   l_debug_mode   VARCHAR2(1) := Null;

BEGIN
   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
   FND_MSG_PUB.initialize;

   IF l_debug_mode = 'Y' THEN
          pa_debug.set_curr_function( p_function   => 'validate',
                                      p_debug_mode => l_debug_mode );
   END IF;

   /* checking for business rules validate */

   l_any_error_occurred_flag := 'N';

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validating input parameters - Name';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   validate_name
    (p_name                         =>     p_name,
     p_spread_curve_id              =>     p_spread_curve_id,
     x_return_status                =>     l_return_status,
     x_msg_count                    =>     l_msg_count,
     x_msg_data                     =>     l_msg_data);

   if (l_return_status =  FND_API.G_RET_STS_ERROR or
       l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then

    l_any_error_occurred_flag := 'Y';
  end if;

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validating input parameters - Effective dates';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

   Pa_Fin_Plan_Utils.End_date_active_val
    (p_start_date_active          =>  p_effective_from,
     p_end_date_active            =>  p_effective_to,
     x_return_status              =>  l_return_status,
     x_msg_count                  =>  l_msg_count,
     x_msg_data                   =>  l_msg_data);

   if (l_return_status =  FND_API.G_RET_STS_ERROR or
       l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then

    l_any_error_occurred_flag := 'Y';
  end if;

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validating input parameters - Amount in buckets';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
   END IF;

  validate_amount_in_buckets(
	P_point1                =>        P_point1,
	P_point2                =>        P_point2,
	P_point3                =>        P_point3,
	P_point4                =>        P_point4,
	P_point5                =>        P_point5,
	P_point6                =>        P_point6,
	P_point7                =>        P_point7,
	P_point8                =>        P_point8,
	P_point9                =>        P_point9,
	P_point10               =>        P_point10,
	x_return_status         =>        l_return_status,
	x_msg_data             =>         l_msg_data,
	x_msg_count             =>        l_msg_count);

   if (l_return_status =  FND_API.G_RET_STS_ERROR or
       l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) then

    l_any_error_occurred_flag := 'Y';

  end if;

  l_msg_count := FND_MSG_PUB.count_msg;

  if (l_any_error_occurred_flag = 'Y') then

    IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Error occured while validating parameters';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
    END IF;

    raise pa_fp_constants_pkg.Invalid_Arg_Exc;
  else
    RETURN;
  end if;

EXCEPTION
WHEN  pa_fp_constants_pkg.Invalid_Arg_Exc THEN

  x_return_status := FND_API.G_RET_STS_ERROR;
  l_msg_count := FND_MSG_PUB.count_msg;

  IF l_msg_count = 1 and x_msg_data IS NULL THEN
     PA_INTERFACE_UTILS_PUB.get_messages
         (p_encoded        => FND_API.G_TRUE
         ,p_msg_index      => 1
         ,p_msg_count      => l_msg_count
         ,p_msg_data       => l_msg_data
         ,p_data           => l_data
         ,p_msg_index_out  => l_msg_index_out);
     x_msg_data := l_data;
     x_msg_count := l_msg_count;
  ELSE
     x_msg_count := l_msg_count;
  END IF;

  IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
  END IF;

  RETURN;

WHEN others THEN

  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  x_msg_count     := 1;
  x_msg_data      := SQLERRM;

  FND_MSG_PUB.add_exc_msg
     ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_UTILS'
     ,p_procedure_name  => 'VALIDATE'
     ,p_error_text      => x_msg_data);

 IF l_debug_mode = 'Y' THEN
    pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
    pa_debug.write(g_module_name,pa_debug.g_err_stage,
                           pa_fp_constants_pkg.g_debug_level5);
    pa_debug.reset_curr_function;
 END IF;

 RAISE;

END validate ;

/*==================================================================
   This api validates the Spread Curve name for uniqueness.
 ==================================================================*/

PROCEDURE validate_name
    (p_name                         IN     pa_spread_curves_tl.name%TYPE,
     p_spread_curve_id              IN     pa_spread_curves_tl.spread_curve_id%TYPE,
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  is
 l_exists VARCHAR2(1);
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
 l_debug_mode   VARCHAR2(1) := Null;
begin

   x_msg_count := 0;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

   IF l_debug_mode = 'Y' THEN
        pa_debug.set_curr_function( p_function   => 'Validate_Name',
                                    p_debug_mode => l_debug_mode );
   END IF;

   IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Validating Spread Curve Name uniqueness';
        pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                   pa_fp_constants_pkg.g_debug_level3);
   END IF;

    if p_name is NULL then
        /* Name must be entered */
        x_return_status := FND_API.G_RET_STS_ERROR;
        PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_MANDATORY_INFO_MISSING');

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Spread Curve Name is Null';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level5);
        END IF;

	raise pa_fp_constants_pkg.Invalid_Arg_Exc;
    end if;

    Begin
      select 'Y'
      into   l_exists
      from   pa_spread_curves_vl
      where  upper(name) = upper(p_name)
      and    spread_curve_id <> nvl(p_spread_curve_id,-99)
      and    rownum < 2;

      /* Duplicate Name should not be entered */

     IF l_debug_mode = 'Y' THEN
        pa_debug.g_err_stage:= 'Duplicate Spread Curve Name = '|| p_name;
        pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level5);
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;

     PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                           p_msg_name            => 'PA_ALL_UNIQUE_NAME_EXISTS');

     raise pa_fp_constants_pkg.Invalid_Arg_Exc;

    exception
      when NO_DATA_FOUND then
        null;
    end;

    RETURN;
EXCEPTION

WHEN  pa_fp_constants_pkg.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
        PA_INTERFACE_UTILS_PUB.get_messages
            (p_encoded        => FND_API.G_TRUE
            ,p_msg_index      => 1
            ,p_msg_count      => l_msg_count
            ,p_msg_data       => l_msg_data
            ,p_data           => l_data
            ,p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
        x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

  FND_MSG_PUB.add_exc_msg
     ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_UTILS'
     ,p_procedure_name  => 'VALIDATE_NAME'
     ,p_error_text      => x_msg_data);

 IF l_debug_mode = 'Y' THEN
    pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
    pa_debug.write(g_module_name,pa_debug.g_err_stage,
                           pa_fp_constants_pkg.g_debug_level5);
    pa_debug.reset_curr_function;
 END IF;

 RAISE;

 END validate_name;

/*==================================================================
      Amount in buckets total_weighting should not be  < 0
 ==================================================================*/

PROCEDURE validate_amount_in_buckets(
	P_point1                IN        Pa_spread_curves_b.point1%TYPE,
	P_point2                IN        Pa_spread_curves_b.point2%TYPE,
	P_point3                IN        Pa_spread_curves_b.point3%TYPE,
	P_point4                IN        Pa_spread_curves_b.point4%TYPE,
	P_point5                IN        Pa_spread_curves_b.point5%TYPE,
	P_point6                IN        Pa_spread_curves_b.point6%TYPE,
	P_point7                IN        Pa_spread_curves_b.point7%TYPE,
	P_point8                IN        Pa_spread_curves_b.point8%TYPE,
	P_point9                IN        Pa_spread_curves_b.point9%TYPE,
	P_point10               IN        Pa_spread_curves_b.point10%TYPE,
	x_return_status         OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_data             OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	X_msg_count             OUT       NOCOPY number) --File.Sql.39 bug 4440895
IS
 l_msg_count       NUMBER;
 l_msg_index_out   NUMBER;
 l_data            VARCHAR2(2000);
 l_msg_data        VARCHAR2(2000);
 l_debug_mode      VARCHAR2(1);

begin
    x_msg_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

    IF l_debug_mode = 'Y' THEN
         pa_debug.set_curr_function( p_function   => 'validate_amount_in_buckets',
                                      p_debug_mode => l_debug_mode );
     END IF;

     -- Check for business rules violations

     IF l_debug_mode = 'Y' THEN
          pa_debug.g_err_stage:= 'Validating Amount in buckets';
          pa_debug.write(g_module_name,pa_debug.g_err_stage,
                                     pa_fp_constants_pkg.g_debug_level3);
     END IF;

    if (  (nvl( p_point1 ,0) < 0  or (p_point1 <> ROUND(p_point1, 0 ))) or
          (nvl( p_point2 ,0) < 0  or (p_point2 <> ROUND(p_point2, 0 ))) or
          (nvl( p_point3 ,0) < 0  or (p_point3 <> ROUND(p_point3, 0 ))) or
          (nvl( p_point4 ,0) < 0  or (p_point4 <> ROUND(p_point4, 0 ))) or
          (nvl( p_point5 ,0) < 0  or (p_point5 <> ROUND(p_point5, 0 ))) or
          (nvl( p_point6 ,0) < 0  or (p_point6 <> ROUND(p_point6, 0 ))) or
          (nvl( p_point7 ,0) < 0  or (p_point7 <> ROUND(p_point7, 0 ))) or
          (nvl( p_point8 ,0) < 0  or (p_point8 <> ROUND(p_point8, 0 ))) or
          (nvl( p_point9 ,0) < 0  or (p_point9 <> ROUND(p_point9, 0 ))) or
          (nvl( p_point10 ,0) < 0 or (p_point10 <> ROUND(p_point10, 0 )))
      ) then

	/* any point is not positive */
        x_return_status := FND_API.G_RET_STS_ERROR;
	PA_UTILS.ADD_MESSAGE(p_app_short_name      => 'PA',
                             p_msg_name            => 'PA_FP_SC_BUCK_VAL_LT_ZERO');

        IF l_debug_mode = 'Y' THEN
           pa_debug.g_err_stage:= 'Total Bucket Value is less than zero';
           pa_debug.write(g_module_name,pa_debug.g_err_stage,pa_fp_constants_pkg.g_debug_level5);
        END IF;

	raise pa_fp_constants_pkg.Invalid_Arg_Exc;

    end if;

    RETURN;
EXCEPTION

WHEN  pa_fp_constants_pkg.Invalid_Arg_Exc THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 and x_msg_data IS NULL THEN
        PA_INTERFACE_UTILS_PUB.get_messages
            (p_encoded        => FND_API.G_TRUE
            ,p_msg_index      => 1
            ,p_msg_count      => l_msg_count
            ,p_msg_data       => l_msg_data
            ,p_data           => l_data
            ,p_msg_index_out  => l_msg_index_out);
        x_msg_data := l_data;
        x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          pa_debug.reset_curr_function;
     END IF;

     RETURN;

WHEN others THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

  FND_MSG_PUB.add_exc_msg
     ( p_pkg_name        => 'PA_FP_SPREAD_CURVES_UTILS'
     ,p_procedure_name  => 'VALIDATE_AMOUNT_IN_BUCKETS'
     ,p_error_text      => x_msg_data);

 IF l_debug_mode = 'Y' THEN
    pa_debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
    pa_debug.write(g_module_name,pa_debug.g_err_stage,
                           pa_fp_constants_pkg.g_debug_level5);
    pa_debug.reset_curr_function;
 END IF;

 RAISE;

 END validate_amount_in_buckets;

END pa_fp_spread_curves_utils;

/
