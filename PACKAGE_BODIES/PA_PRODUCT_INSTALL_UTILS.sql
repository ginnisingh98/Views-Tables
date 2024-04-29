--------------------------------------------------------
--  DDL for Package Body PA_PRODUCT_INSTALL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PRODUCT_INSTALL_UTILS" AS
/* $Header: PAPIUTLB.pls 120.1.12010000.3 2009/08/05 12:36:34 vchilla ship $ */

Function check_object_licensed ( p_object_type  IN  VARCHAR2,
                                 p_object_code  IN VARCHAR2)
   RETURN VARCHAR2
   is

   /* l_licensed_flag  VARCHAR2(1):= 'Y';  Bug# 8719060 */

   l_licensed_ycnt NUMBER :=0;
   l_licensed_ncnt NUMBER :=0;

   /* Commenting for bug 6352484
   Cursor C is
    Select 'Y'
    from PA_PRODUCT_FUNCTIONS PF,
         pa_product_installation_v pi
    where PF.object_type = p_object_type
    and PF.object_code = p_object_code
    and PF.product_code=pi.product_short_code
    and pi.installed_flag='Y';

   Cursor C2 is
    Select 'N'
    from PA_PRODUCT_FUNCTIONS PF,
         pa_product_installation_v pi
    where PF.object_type = p_object_type
    and PF.object_code = p_object_code
    and PF.product_code=pi.product_short_code
    and pi.installed_flag='N';
*/
  /* Modified CNEW for bug# 8719060 */
  Cursor CNEW is
     Select SUM(DECODE(nvl(pi.installed_flag,'Y'),'Y',1,0)) YCnt,
            SUM(DECODE(nvl(pi.installed_flag,'N'),'N',1,0)) NCnt
     from PA_PRODUCT_FUNCTIONS PF,
          pa_product_installation_v pi
     where PF.object_type = p_object_type
     and PF.object_code = p_object_code
     and PF.product_code=pi.product_short_code;

   BEGIN
    /*commenting the below code w.r.t bug 6352484
    open C;
    fetch C into l_licensed_flag;
    if (C%FOUND) then
	close C;
	return l_licensed_flag;
    end if;
    close C;

    open C2;
    fetch C2 into l_licensed_flag;
    if (C2%FOUND) then
	close C2;
	return l_licensed_flag;
    end if;
    close C2;
*/
   open CNEW;
   fetch CNEW into l_licensed_ycnt,l_licensed_ncnt;
   close CNEW;

   /* If product is not available in PA_PRODUCT_INSTALLATIONS,
      we need to return Y.

      IF product is available, we need to check for Y cnt and N cnt to return the value
      We had cursors C, C2 for this purpose only.
   */

   IF (nvl(l_licensed_ycnt,0) = 0 AND nvl(l_licensed_ncnt,0) = 0) THEN
      RETURN 'Y';
   ELSIF (nvl(l_licensed_ycnt,0) > 0) THEN
      RETURN 'Y';
   ELSIF (nvl(l_licensed_ncnt,0) > 0 AND nvl(l_licensed_ycnt,0) = 0) THEN
      RETURN 'N';
   END IF;

   RETURN 'Y';
/*
   if (CNEW%FOUND) then
     close CNEW;
     return l_licensed_flag;
   end if;
   close CNEW;
   return l_licensed_flag;
   EXCEPTION
    When others then
    l_licensed_flag := 'Y';
    return l_licensed_flag;*/

END check_object_licensed;

  Procedure validate_object(
   p_object_type    IN  VARCHAR2,
   p_object_code    IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
   l_object_exists  varchar2(1):= null;
   l_pa_fn_exists   varchar2(1):= null;

   Cursor valid_function is
    select 'X' from fnd_form_functions
    where function_name=p_object_code;

   Cursor valid_project_function is
    select 'X' from pa_product_functions
    where object_type = 'FND_FUNCTION'
    and   object_code = p_object_code;

    Cursor valid_region is
    select 'X' from ak_regions
    where region_code=p_object_code
    and region_application_id=275;

    Cursor valid_product_region is
    select 'X' from pa_product_functions
    where object_type = 'AK_REGION'
    and   object_code = p_object_code;
  Begin
    pa_debug.Init_err_stack ( 'Validate Object');
    x_msg_count :=0;
    x_msg_data:= null;
    x_return_status:=fnd_api.g_ret_sts_success;
    x_ret_code:= 'Y' ;

  /** Validate the IN parameter  **/
  if (p_object_type = 'FND_FUNCTION') then
    open valid_function;
    fetch valid_function into l_object_exists;
    if (valid_function%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_INV_FUNCTION');
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
     --PA_DEBUG.Reset_Err_Stack;
     --close valid_function;
     --RETURN;
    end if;
    close valid_function;
    open valid_project_function;
    fetch valid_project_function into l_pa_fn_exists;
    if (valid_project_function%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_INV_PROJECT_FUNCTION');
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
     --PA_DEBUG.Reset_Err_Stack;
     --close valid_project_function;
     --RETURN;
    end if;
    close valid_project_function;
 elsif (p_object_type = 'AK_REGION') then
    open valid_region;
    fetch valid_region into l_object_exists;
    if (valid_region%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_INV_AK_REGION');
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
     --PA_DEBUG.Reset_Err_Stack;
     --close valid_region;
     --RETURN;
    end if;
    close valid_region;
    --Check valid region per product licensing
    open valid_product_region;
    fetch valid_product_region into l_pa_fn_exists;
    if (valid_product_region%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_INV_PROJECT_REGION');
     x_msg_count := x_msg_count + 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
     /*--PA_DEBUG.Reset_Err_Stack;
     --close valid_project_function;
     --RETURN;*/
    end if;
    close valid_product_region;
  end if;
   if(x_return_status = FND_API.G_RET_STS_ERROR) then
    x_ret_code := 'N';
  end if;
    PA_DEBUG.Reset_Err_Stack;
  EXCEPTION
    When others then
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PRODUCT_INSTALL_UTILS.validate_object'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_ret_code := 'N';  -- This is optional depending on the needs
  END validate_object;

  Procedure check_function_licensed
  (
   p_function_name  IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
    l_object_type varchar2(30):='FND_FUNCTION';

  Begin
  pa_debug.Init_err_stack ( 'Check function Licensed');
  x_msg_count :=0;
  x_msg_data:= null;
  x_return_status:=fnd_api.g_ret_sts_success;
  x_ret_code:= 'N' ;

  /** Validate the parameter  **/
  validate_object(
   p_object_type    => 'FND_FUNCTION',
   p_object_code    => p_function_name,
   x_ret_code       => x_ret_code,
   x_return_status  => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data       => x_msg_data);

  if(x_return_status <> FND_API.G_RET_STS_ERROR) then
    x_ret_code := check_object_licensed ( p_object_type  => 'FND_FUNCTION',
                                          p_object_code  => p_function_name);
  end if;

  EXCEPTION
    When others then
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PRODUCT_INSTALL_UTILS.check_function_licensed'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
   END check_function_licensed;

  /************************************************************************
   This function detremines the whether it is licensed to use a function or Not
   Name of the Function : check_function_licensed
   IN PARAMETERS  p_function_name - Name of the function
   RETURN VALUE   - Y - Eligible to use , N- Not  Eligible to use
    *************************************************************************/
   Function check_function_licensed ( p_function_name  IN  VARCHAR2)
   RETURN VARCHAR2
   is
   l_fun_licensed  VARCHAR2(1):= 'Y';
   BEGIN
    l_fun_licensed := check_object_licensed ( p_object_type  => 'FND_FUNCTION',
                                              p_object_code  => p_function_name);
    return l_fun_licensed;
   EXCEPTION
    When others then
    l_fun_licensed := 'N';
    return l_fun_licensed;
   END check_function_licensed;

   Function check_region_licensed ( p_region_code  IN  VARCHAR2)
   RETURN VARCHAR2
   is
   l_fun_licensed  VARCHAR2(1):= 'Y';
   BEGIN
    l_fun_licensed := check_object_licensed ( p_object_type  => 'AK_REGION',
                                              p_object_code  => p_region_code);
    return l_fun_licensed;
   EXCEPTION
    When others then
    l_fun_licensed := 'N';
    return l_fun_licensed;
   END check_region_licensed;

   Procedure check_region_licensed
  (
   p_region_code    IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2) --File.Sql.39 bug 4440895
  is
    l_object_type varchar2(30):='AK_REGION';

  Begin
  pa_debug.Init_err_stack ( 'Check Region Licensed');
  x_msg_count :=0;
  x_msg_data:= null;
  x_return_status:=fnd_api.g_ret_sts_success;
  x_ret_code:= 'N' ;

  /** Validate the parameter  **/
  validate_object(
   p_object_type    => 'AK_REGION',
   p_object_code    => p_region_code,
   x_ret_code       => x_ret_code,
   x_return_status  => x_return_status,
   x_msg_count      => x_msg_count,
   x_msg_data       => x_msg_data);

  if(x_return_status <> FND_API.G_RET_STS_ERROR) then
    x_ret_code := check_object_licensed ( p_object_type  => 'AK_REGION',
                                          p_object_code  => p_region_code);
  end if;

  EXCEPTION
    When others then
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PRODUCT_INSTALL_UTILS.check_region_licensed'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_ret_code:= 'N' ;
       RAISE;  -- This is optional depending on the needs
   END check_region_licensed;


END PA_product_install_Utils;

/
