--------------------------------------------------------
--  DDL for Package Body PA_PAGE_LAYOUT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_LAYOUT_PUB" as
/* $Header: PAPRPLPB.pls 120.1 2005/08/19 16:44:41 mwasowic noship $ */

--History
--    16-Feb-2004    svenketa - Modified, Added a parameter p_function_name for create and update.
--    06-Sep-2004    smekala  - Modified the Cursor c_menu_home_default to increase the performance
--                               Bug 3693907

PROCEDURE Create_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_name                   IN     VARCHAR2  := FND_API.g_miss_char,

 p_page_type                   IN     VARCHAR2 := FND_API.g_miss_char,

 p_description                 IN     VARCHAR2 := FND_API.g_miss_char,

 p_start_date                  IN     DATE ,

 p_end_date                    IN     DATE := null,
 p_shortcut_menu_id            IN     NUMBER :=  FND_API.g_miss_num,
 p_shortcut_menu_name          IN     VARCHAR2 := NULL,
 p_function_name	       IN     VARCHAR2,
 x_page_id                     OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      l_msg_index_out        NUMBER;
      l_page_type            VARCHAR2(30);


--    Bug #3302984
      prj_menu_name VARCHAR2(100) := 'PA_SHORTCUTS_MENU';
      team_menu_name VARCHAR2(100) := 'PA_SHORTCUTS_MENU_TM';
      l_prj_menu_id NUMBER;
      l_team_menu_id NUMBER;
      l_shortcut_menu_name VARCHAR2(100);
      l_shortcut_menu_id NUMBER;

/* Code Modification done to increase the performance as per Bug3693907 */

      cursor c_menu_home_default(c_menu_name varchar2) is
      select menu_id from fnd_menus where menu_name = c_menu_name;   -- #Bug 3693907

/* Code Changes for Bug 3693907 end here */

  BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_page_type = FND_API.g_miss_char THEN
     l_page_type := 'PPR';
   ELSE
     l_page_type := p_page_type;
  END IF;


  --Bug#3302984
  if ((p_page_type is not null)and(p_shortcut_menu_id is null))then
    if (p_page_type = 'PH')then
	open c_menu_home_default(prj_menu_name);
	fetch c_menu_home_default into l_prj_menu_id;
	l_shortcut_menu_name := prj_menu_name;
	l_shortcut_menu_id := l_prj_menu_id;
	close c_menu_home_default;

    elsif(p_page_type = 'TM') then
	open c_menu_home_default(team_menu_name);
	fetch c_menu_home_default into l_team_menu_id;
	l_shortcut_menu_name := team_menu_name;
	l_shortcut_menu_id := l_team_menu_id;
	close c_menu_home_default;

    end if;

  else
    l_shortcut_menu_name := p_shortcut_menu_name;
    l_shortcut_menu_id := p_shortcut_menu_id;
  end if;
  pa_page_layout_pvt.Create_Page_Layout
  (
   p_api_version             => p_api_version,
   p_init_msg_list           => p_init_msg_list,
   p_commit                  => p_commit,
   p_validate_only           => p_validate_only,
   p_max_msg_count           => p_max_msg_count,
   p_page_name               => p_page_name,
   p_page_type               => l_page_type,
   p_description             => p_description,
   p_start_date              => p_start_date,
   p_end_date                => p_end_date,
   p_shortcut_menu_id        => l_shortcut_menu_id,
   p_shortcut_menu_name      => l_shortcut_menu_name,
   p_function_name           => p_function_name,
   x_page_id                 => x_page_id,
   x_return_status           => x_return_status,
   x_msg_count               => x_msg_count,
   x_msg_data                => x_msg_data
     );

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
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_PUB.Create_Page_Layout'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END create_page_layout;



PROCEDURE Update_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,

 p_page_name                   IN     VARCHAR2  := FND_API.g_miss_char,

-- p_page_type                   IN     VARCHAR2 := FND_API.g_miss_char,

 p_description                 IN     VARCHAR2 := FND_API.g_miss_char,

 p_start_date                  IN     DATE := null,

 p_end_date                    IN     DATE := null,
 p_shortcut_menu_id            IN     NUMBER := FND_API.g_miss_num,
 p_shortcut_menu_name          IN     VARCHAR2 := NULL,
 p_record_version_number       IN NUMBER := null,
 p_function_name	       IN     VARCHAR2,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

     l_msg_index_out        NUMBER;
BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Update_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_page_layout_pvt.Update_Page_Layout
	(
	 p_api_version             => p_api_version,
	 p_init_msg_list           => p_init_msg_list,
	 p_commit                  => p_commit,
	 p_validate_only           => p_validate_only,
	 p_max_msg_count           => p_max_msg_count,
	 p_page_id                 => p_page_id,
	 p_page_name               => p_page_name,
--	 p_page_type               => p_page_type,
	 p_description             => p_description,
	 p_start_date              => p_start_date,
	 p_end_date                => p_end_date,
         p_shortcut_menu_id        => p_shortcut_menu_id,
	 p_shortcut_menu_name        => p_shortcut_menu_name,
         p_record_version_number   => p_record_version_number,
	 p_function_name           => p_function_name,
	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data
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


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
   WHEN OTHERS THEN

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PAGE_LAYOUT_PUB.Update_Page_Layout'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --

END update_page_layout;



PROCEDURE Delete_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 p_record_version_number       IN     NUMBER := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

    l_msg_index_out NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Delete_Page_Layout');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  -- Call the private API
  PA_PAGE_LAYOUT_PVT.Delete_Page_Layout
     (
      p_api_version            => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,p_commit                => p_commit
      ,p_validate_only         => p_validate_only
      ,p_max_msg_count         => p_max_msg_count
      ,p_page_id               => p_page_id
      ,p_record_version_number   => p_record_version_number
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
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PAGE_LAYOUT_PUB.Delete_Page_Layout'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

END delete_page_layout;

procedure ADD_PAGE_REGION (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  P_PAGE_ID in NUMBER := null,
  P_REGION_SOURCE_TYPE in VARCHAR2 default 'STD',
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_VIEW_REGION_CODE in VARCHAR2 := null,
  P_EDIT_REGION_CODE in VARCHAR2 := null,
  P_REGION_STYLE     in VARCHAR2 := null,
  P_DISPLAY_ORDER in NUMBER := null,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

      l_msg_index_out        NUMBER;

      l_view_region_code VARCHAR2(250) := p_view_region_code;
      l_edit_region_code VARCHAR2(250) := p_edit_region_code;
      l_region_style VARCHAR2(30) := p_region_style;

      CURSOR get_region_info IS
	 SELECT pptr.view_region_code,
	   pptr.edit_region_code,
	   pptr.region_style
	   FROM pa_page_type_regions pptr,
	   pa_page_layouts ppl
	   WHERE pptr.page_type_code = ppl.page_type_code
	   AND ppl.page_id = p_page_id
       and pptr.region_source_type = p_region_source_type
       and pptr.region_source_code = p_region_source_code;


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Add_Page_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

--debug_msg_s1('***p_view_region_code ' || p_view_region_code);
--debug_msg_s1('***p_view_region_code ' || p_region_source_type);
--debug_msg_s1('***p_view_region_code ' || p_region_source_code);


  IF (p_view_region_code IS NULL ) THEN
     OPEN get_region_info;
     FETCH get_region_info INTO l_view_region_code, l_edit_region_code, l_region_style;
--     debug_msg_s1('***p_edit_region_code ' || l_view_region_code);
--     debug_msg_s1('***p_edit_region_code ' || l_edit_region_code);
--     debug_msg_s1('p***_edit_region_code ' || l_region_style);
     CLOSE get_region_info;

  END IF;


  pa_page_layout_pvt.Add_PAGE_REGION
  (
   p_api_version             => p_api_version,
   p_init_msg_list           => p_init_msg_list,
   p_commit                  => p_commit,
   p_validate_only           => p_validate_only,
   p_max_msg_count           => p_max_msg_count,
   p_page_id                 => p_page_id,
   p_region_source_type      => p_region_source_type,
   p_region_source_code      => p_region_source_code,
   p_view_region_code        => l_view_region_code,
   p_edit_region_code        => l_edit_region_code,
   p_region_style	     => l_region_style,
   p_display_order           => p_display_order,
   x_return_status           => x_return_status,
   x_msg_count               => x_msg_count,
   x_msg_data                => x_msg_data
     );

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
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_PUB.ADD_Page_Region'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END add_page_region;

PROCEDURE Delete_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 P_REGION_SOURCE_TYPE          in     VARCHAR2 := 'STD',
 P_REGION_SOURCE_CODE          in     VARCHAR2,
 p_record_version_number       IN     NUMBER := null,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

     l_msg_index_out        NUMBER;
BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Delete_Page_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  pa_page_layout_pvt.Delete_Page_Region
	(
	 p_api_version             => p_api_version,
	 p_init_msg_list           => p_init_msg_list,
	 p_commit                  => p_commit,
	 p_validate_only           => p_validate_only,
	 p_max_msg_count           => p_max_msg_count,
	 p_page_id                 => p_page_id,
         p_region_source_type      => p_region_source_type,
         p_region_source_code      => p_region_source_code,
	 p_record_version_number   => p_record_version_number,
	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data
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


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
   WHEN OTHERS THEN

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PAGE_LAYOUT_PUB.Delete_Page_Region'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --

END delete_page_region;

PROCEDURE Delete_All_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 p_region_position             IN     VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

        l_msg_index_out        NUMBER;
BEGIN

   -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Delete_All_Page_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  pa_page_layout_pvt.Delete_All_Page_Region
	(
	 p_api_version             => p_api_version,
	 p_init_msg_list           => p_init_msg_list,
	 p_commit                  => p_commit,
	 p_validate_only           => p_validate_only,
	 p_max_msg_count           => p_max_msg_count,

	 p_page_id                 => p_page_id,
	 p_region_position         => p_region_position,

	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data
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


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
   WHEN OTHERS THEN

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PAGE_LAYOUT_PUB.Delete_All_Page_Region'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --

END delete_all_page_region;

PROCEDURE Delete_All_link_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     NUMBER := null,
 p_region_position             IN     VARCHAR2 := null,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

        l_msg_index_out        NUMBER;
BEGIN

   -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PUB.Delete_All_link_Page_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  pa_page_layout_pvt.Delete_All_link_Page_Region
	(
	 p_api_version             => p_api_version,
	 p_init_msg_list           => p_init_msg_list,
	 p_commit                  => p_commit,
	 p_validate_only           => p_validate_only,
	 p_max_msg_count           => p_max_msg_count,

	 p_page_id                 => p_page_id,
	 p_region_position         => p_region_position,

	 x_return_status           => x_return_status,
	 x_msg_count               => x_msg_count,
	 x_msg_data                => x_msg_data
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


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
   WHEN OTHERS THEN

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PAGE_LAYOUT_PUB.Delete_All_link_Page_Region'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --

END delete_all_link_page_region;


END  PA_PAGE_LAYOUT_PUB;

/
