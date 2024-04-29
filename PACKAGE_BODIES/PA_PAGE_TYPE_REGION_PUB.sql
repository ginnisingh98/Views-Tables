--------------------------------------------------------
--  DDL for Package Body PA_PAGE_TYPE_REGION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_TYPE_REGION_PUB" as
/* $Header: PAPLPTPB.pls 120.1 2005/08/19 16:41:35 mwasowic noship $ */

PROCEDURE Create_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2 := null,
 P_REGION_SOURCE_NAME in VARCHAR2 := null,

 P_VIEW_REGION_CODE in VARCHAR2 := null,
 P_EDIT_REGION_CODE in VARCHAR2 := null,
 P_VIEW_REGION_NAME in VARCHAR2 := null,
 P_EDIT_REGION_NAME in VARCHAR2 := null,
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

      l_msg_index_out        NUMBER;
      l_page_type            VARCHAR2(30);
      l_region_source_code VARCHAR2(250);
      l_view_region_code VARCHAR2(250);
      l_edit_region_code VARCHAR2(250);
      l_dummy varchar2(1) := 'N';

      cursor check_region_source_unique is
      select 'Y' from dual
      where exists
      (select * from pa_page_type_regions
      where page_type_code = p_page_type_code
      and region_source_type = p_region_source_type
       and region_source_code = l_region_source_code);

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PUB.Create_Page_Type_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_page_type_code IS null THEN
     l_page_type := 'PPR';
   ELSE
     l_page_type := p_page_type_code;
  END IF;

  IF p_region_source_code IS NULL THEN
      l_region_source_code := pa_page_layout_utils.get_region_source_code(p_region_source_name, P_REGION_SOURCE_TYPE, 275, 'PA_STATUS_REPORT_DESC_FLEX');

     IF  l_region_source_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_NAME_INV');


	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

      -- check if the region_source_code is used already
     open check_region_source_unique;
     fetch check_region_source_unique into l_dummy;
     if check_region_source_unique%found then
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_NAME_NOT_UNIQUE');


	x_return_status := FND_API.G_RET_STS_ERROR;

     end if;

     close check_region_source_unique;
   ELSE
     l_region_source_code := p_region_source_code;

        -- check if the region_source_code is used already
     open check_region_source_unique;
     fetch check_region_source_unique into l_dummy;
     if check_region_source_unique%found then
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_NAME_NOT_UNIQUE');


	x_return_status := FND_API.G_RET_STS_ERROR;

     end if;

     close check_region_source_unique;

  END IF;

  IF (p_view_region_code IS NULL AND x_return_status = FND_API.g_ret_sts_success  )THEN
     l_view_region_code := pa_page_layout_utils.get_ak_region_code(p_view_region_name, 275);

     IF l_view_region_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_STYLE_INV'
                          );

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSE
     l_view_region_code := p_view_region_code;
  END IF;

   IF (p_edit_region_code IS NULL  AND x_return_status = FND_API.g_ret_sts_success )THEN
     l_edit_region_code := pa_page_layout_utils.get_ak_region_code(p_edit_region_name, 275);

     IF l_edit_region_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_STYLE_INV'
                           );

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSE
     l_edit_region_code := p_edit_region_code;
  END IF;

  IF (x_return_status = FND_API.g_ret_sts_success ) THEN

  pa_page_type_region_pvt.Create_Page_Type_Region
  (
   p_api_version             => p_api_version,
   p_init_msg_list           => p_init_msg_list,
   p_commit                  => p_commit,
   p_validate_only           => p_validate_only,
   p_max_msg_count           => p_max_msg_count,

    p_page_type_code => l_page_type,
   P_REGION_SOURCE_TYPE => p_region_source_type,
   P_REGION_SOURCE_CODE => l_region_source_code,

   P_VIEW_REGION_CODE => l_view_region_code,
   P_EDIT_REGION_CODE => l_edit_region_code,
   P_REGION_STYLE => p_region_style,
   P_DISPLAY_ORDER => p_display_order,
   P_MANDATORY_FLAG => p_mandatory_flag,
   P_DEFAULT_REGION_POSITION => p_default_region_position,
   P_PLACEHOLDER_REGION_FLAG => p_placeholder_region_flag,
   P_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
   P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,
   p_document_source =>  p_document_source,
   P_PAGE_FUNCTION_NAME => p_page_function_name,
   P_SECURITY_FUNCTION_NAME  => p_security_function_name,
   x_return_status           => x_return_status,
   x_msg_count               => x_msg_count,
   x_msg_data                => x_msg_data
     );
  END IF;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  --commit;

-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_TYPE_REGION_PUB.Create_Page_Type_Region'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END create_page_type_region;



PROCEDURE Update_Page_Type_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 1.7E20,

 P_PAGE_TYPE_CODE in VARCHAR2,
 P_REGION_SOURCE_TYPE in VARCHAR2,
 P_REGION_SOURCE_CODE in VARCHAR2 := null,
 P_REGION_SOURCE_NAME in VARCHAR2 := null,

 P_VIEW_REGION_CODE in VARCHAR2 := null,
 P_EDIT_REGION_CODE in VARCHAR2 := null,
 P_VIEW_REGION_NAME in VARCHAR2 := null,
 P_EDIT_REGION_NAME in VARCHAR2 := null,
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

     l_msg_index_out        NUMBER;
      l_region_source_code VARCHAR2(250);
      l_view_region_code VARCHAR2(250);
      l_edit_region_code VARCHAR2(250);
BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PUB.Update_Page_Type_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

 IF (p_region_source_code IS NULL AND x_return_status = FND_API.g_ret_sts_success )THEN
      l_region_source_code := pa_page_layout_utils.get_region_source_code(p_region_source_name, P_REGION_SOURCE_TYPE, 275, 'PA_STATUS_REPORT_DESC_FLEX');

     IF  l_region_source_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_NAME_INV'
                          );

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   ELSE
     l_region_source_code := p_region_source_code;
  END IF;

  IF (p_view_region_code IS NULL AND x_return_status = FND_API.g_ret_sts_success )THEN
     l_view_region_code := pa_page_layout_utils.get_ak_region_code(p_view_region_name, 275);

     IF l_view_region_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_STYLE_INV'
                           );

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSE
     l_view_region_code := p_view_region_code;
  END IF;

   IF (p_edit_region_code IS NULL AND x_return_status = FND_API.g_ret_sts_success )THEN
     l_edit_region_code := pa_page_layout_utils.get_ak_region_code(p_edit_region_name, 275);

     IF l_edit_region_code IS NULL THEN
	 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_UDS_SETUP_STYLE_INV'
			       );

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   ELSE
     l_edit_region_code := p_edit_region_code;
  END IF;

  IF (x_return_status = FND_API.g_ret_sts_success ) THEN

  pa_page_type_region_pvt.Update_Page_Type_Region
	(
	 p_api_version             => p_api_version,
	 p_init_msg_list           => p_init_msg_list,
	 p_commit                  => p_commit,
	 p_validate_only           => p_validate_only,
	 p_max_msg_count           => p_max_msg_count,

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
	 P_END_DATE_ACTIVE => P_END_DATE_ACTIVE,

	 P_DOCUMENT_SOURCE =>  p_document_source,
         P_PAGE_FUNCTION_NAME => p_page_function_name,
         P_SECURITY_FUNCTION_NAME => p_security_function_name,

	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data
	 );

  END IF;


  --
  -- IF the number of messaages is 1 then fetch the message code from the
  -- stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
   WHEN OTHERS THEN

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PAGE_TYPE_REGION_PUB.Update_Page_Type_Region'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --

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

    l_msg_index_out NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_TYPE_REGION_PUB.Delete_Page_Type_Region');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- Call the private API
  PA_PAGE_TYPE_REGION_PVT.Delete_Page_Type_Region
     (
      p_api_version            => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,p_commit                => p_commit
      ,p_validate_only         => p_validate_only
      ,p_max_msg_count         => p_max_msg_count

      ,p_page_type_code => p_page_type_code
      ,P_REGION_SOURCE_TYPE => p_region_source_type
      ,P_REGION_SOURCE_CODE => p_region_source_code

      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      );

 --
  -- IF the number of messaages is 1 then fetch the message code from the
  -- stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


 EXCEPTION
   WHEN OTHERS THEN

         rollback;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PAGE_TYPE_REGION_PUB.Delete_Page_Type_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END delete_page_type_region;

END  PA_PAGE_TYPE_REGION_PUB;

/
