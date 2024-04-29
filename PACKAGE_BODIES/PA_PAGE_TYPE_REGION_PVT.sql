--------------------------------------------------------
--  DDL for Package Body PA_PAGE_TYPE_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_TYPE_REGION_PVT" as
/* $Header: PAPLPTVB.pls 120.1 2005/08/19 16:41:42 mwasowic noship $ */

PROCEDURE Create_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2,

 P_VIEW_REGION_CODE in VARCHAR2,
 P_EDIT_REGION_CODE in VARCHAR2,
 P_REGION_STYLE in VARCHAR2 := null,
 P_DISPLAY_ORDER in NUMBER := null,
 P_MANDATORY_FLAG in VARCHAR2 := null,
 P_DEFAULT_REGION_POSITION in VARCHAR2 := null,
 P_PLACEHOLDER_REGION_FLAG in VARCHAR2:=null,
 P_START_DATE_ACTIVE in DATE,
 P_END_DATE_ACTIVE in DATE,
 P_DOCUMENT_SOURCE in VARCHAR2 := null,
 P_PAGE_FUNCTION_NAME in VARCHAR2 := null,
 P_SECURITY_FUNCTION_NAME in VARCHAR2 := null,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

   CURSOR get_template_type
        is
           SELECT meaning FROM pa_lookups pl
             WHERE lookup_type = 'PA_PAGE_TYPES'
             AND lookup_code = p_page_type_code;

   l_type VARCHAR2(250);

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PVT.Create_Page_Type_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PAGE_TYPE_REGION_PVT_CREATE;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;



  -- check the page type is not null
  IF (p_page_type_code IS NULL  OR p_page_type_code = FND_API.g_miss_char)THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_PAGE_TYPE_INV'
			   , p_token1 => 'TEMPLATE_TYPE'
			   , p_value1 => l_type);
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- check the end date and start date
  IF (p_end_date_active IS NOT NULL AND p_end_date_active < p_start_date_active) THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			   ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');

     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

	pa_page_type_region_pkg.Insert_page_type_region_Row
	  (
	   p_page_type_code => p_page_type_code,
	   P_REGION_SOURCE_TYPE => p_region_source_type,
	   P_REGION_SOURCE_CODE => p_region_source_code,

	   P_VIEW_REGION_CODE => p_view_region_code,
	   P_EDIT_REGION_CODE => p_edit_region_code,
	   P_REGION_STYLE => p_region_style,
	   P_DISPLAY_ORDER => p_display_order,
	   P_MANDATORY_FLAG => p_mandatory_flag,
	   P_DEFAULT_REGION_POSITION => p_default_region_position,
	   P_PLACEHOLDER_REGION_FLAG => p_placeholder_region_flag,
	   P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
	   P_END_DATE_ACTIVE => p_end_date_active,
	   p_document_source=> P_DOCUMENT_SOURCE,
           P_PAGE_FUNCTION_NAME => p_page_function_name,
           P_SECURITY_FUNCTION_NAME => p_security_function_name
	   );

  END IF;


  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PAGE_TYPE_REGION_PVT_CREATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_TYPE_REGION_PVT.Create_Page_Type_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END create_page_type_region;



PROCEDURE Update_Page_type_region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2,

 P_VIEW_REGION_CODE in VARCHAR2,
 P_EDIT_REGION_CODE in VARCHAR2,
 P_REGION_STYLE in VARCHAR2 := '^',
 P_DISPLAY_ORDER in NUMBER := 1.7E20,
 P_MANDATORY_FLAG in VARCHAR2 := '^',
 P_DEFAULT_REGION_POSITION in VARCHAR2 := '^',
 P_PLACEHOLDER_REGION_FLAG in VARCHAR2 := '^',
 P_START_DATE_ACTIVE in DATE,
 P_END_DATE_ACTIVE in DATE,
 P_DOCUMENT_SOURCE in VARCHAR2 := null,
 P_PAGE_FUNCTION_NAME in VARCHAR2 := null,
 P_SECURITY_FUNCTION_NAME in VARCHAR2 := null,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS


BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PVT.Update_Page_Type_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT page_type_REGION_PVT_UPDATE;
  END IF;


  IF (p_end_date_active IS NOT NULL AND p_end_date_active < p_start_date_active) THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');

	x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


 IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

	pa_page_type_region_pkg.Update_page_type_region_Row
	  (
	   p_page_type_code => p_page_type_code,
	   P_REGION_SOURCE_TYPE => p_region_source_type,
	   P_REGION_SOURCE_CODE => p_region_source_code,

	   P_VIEW_REGION_CODE => p_view_region_code,
	   P_EDIT_REGION_CODE => p_edit_region_code,
	   P_REGION_STYLE => p_region_style,
	   P_DISPLAY_ORDER => p_display_order,
	   P_MANDATORY_FLAG => p_mandatory_flag,
	   P_DEFAULT_REGION_POSITION => p_default_region_position,
	   P_PLACEHOLDER_REGION_FLAG => p_placeholder_region_flag,
	   P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
	   P_END_DATE_ACTIVE => p_end_date_active,
	   p_document_source =>  P_DOCUMENT_SOURCE,
           P_PAGE_FUNCTION_NAME => p_page_function_name,
           P_SECURITY_FUNCTION_NAME => p_security_function_name
	   );

  END IF;

 -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.g_ret_sts_success) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN NO_DATA_FOUND then
     PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO PAGE_TYPE_REGION_PVT_UPDATE;
     END IF;
     --RAISE;
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PAGE_TYPE_REGION_PVT_UPDATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_TYPE_REGION_PVT.Update_Page_Type_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END update_page_type_region;



PROCEDURE Delete_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_rowid                       IN     VARCHAR2 := NULL,
 P_PAGE_TYPE_CODE in VARCHAR2 := NULL,
 P_REGION_SOURCE_TYPE in VARCHAR2 := NULL,
 P_REGION_SOURCE_CODE in VARCHAR2 := NULL,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PVT.Delete_Page_Type_Region');


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PAGE_TYPE_REGION_PVT_DELETE;
  END IF;


  IF (p_validate_only = FND_API.g_false) THEN
     PA_PAGE_TYPE_REGION_PKG.Delete_page_type_region_Row
       (
	 p_rowid => p_rowid,
	 p_page_type_code => p_page_type_code,
	 P_REGION_SOURCE_TYPE => p_region_source_type,
	 P_REGION_SOURCE_CODE => p_region_source_code
	 );
  END IF;



  -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


 EXCEPTION
   WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PAGE_TYPE_REGION_PVT_DELETE;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PAGE_TYPE_REGION_PVT.Delete_Page_Type_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END delete_page_type_region;


END  PA_PAGE_TYPE_REGION_PVT;


/
