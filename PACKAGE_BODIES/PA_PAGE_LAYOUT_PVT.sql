--------------------------------------------------------
--  DDL for Package Body PA_PAGE_LAYOUT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_LAYOUT_PVT" as
/* $Header: PAPRPLVB.pls 120.1 2005/08/19 16:44:50 mwasowic noship $ */

--History
--    16-Feb-2004    svenketa - Modified, Added a parameter p_function_name for create and update.
--    17-Feb-2004    svenketa - Modified the DELETE_PAGE_LAYOUT api.


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

 p_start_date                  IN     date,

 p_end_date                    IN     date,
 p_shortcut_menu_id            IN     number,
 p_shortcut_menu_name          IN     VARCHAR2,
 p_function_name	       IN     VARCHAR2,
 x_page_id                     OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS

      l_dummy VARCHAR2(1);

      CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups pl
	     WHERE lookup_type = 'PA_PAGE_TYPES'
	     AND lookup_code = p_page_type;

      CURSOR is_menu_id_required
	IS
	   select 'Y' from dual
	     where exists(
			  select  'Required'
                          from pa_lookups l
			  where l.lookup_type = 'PA_PAGE_TYPES'
			  and l.lookup_code = p_page_type
			  AND L.attribute2 = 'Y'
			  );

      CURSOR get_menu_id
	IS
	   SELECT MENU_ID
	     FROM FND_MENUS_VL
	     where user_menu_name = p_shortcut_menu_name;

      cursor get_menu_name
        is
            select page_id
            from pa_page_layouts
            where page_name = p_page_name and
            page_type_code = p_page_type;

      l_type VARCHAR2(250);
      l_menu_id NUMBER;
      l_page_id number;


BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PAGE_LAYOUT_PVT_CREATE;
  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;


  IF p_shortcut_menu_id IS NOT NULL AND p_shortcut_menu_id <> -99 THEN
     l_menu_id := p_shortcut_menu_id;
   ELSE

     OPEN is_menu_id_required;
     FETCH is_menu_id_required INTO l_dummy;
     IF is_menu_id_required%notfound THEN
	CLOSE is_menu_id_required;
	l_menu_id := p_shortcut_menu_id;
      ELSE
	CLOSE is_menu_id_required;

	OPEN get_menu_id;
	FETCH get_menu_id INTO l_menu_id;

	IF get_menu_id%notfound THEN
	   CLOSE get_menu_id;
	   PA_UTILS.Add_Message( p_app_short_name => 'PA'
				 ,p_msg_name       => 'PA_MENU_NAME_INV'
				 );
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   RETURN;
	 ELSE
	   CLOSE get_menu_id;
	END IF;

     END IF;
  END IF;


  -- check the mandatory page_name
  IF (p_page_name IS NULL OR p_page_name = FND_API.g_miss_char) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PAGE_NAME_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE

     -- added by syao check if the name already exists
     open get_menu_name;
     fetch get_menu_name into l_page_id;


     IF get_menu_name%found THEN
	CLOSE get_menu_name;
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_PAGE_NAME_NOT_UNIQUE'
			      );
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
     end if;
     close get_menu_name;
     -- end


     -- check the page type is not null
     IF (p_page_type IS NULL  OR p_page_type = FND_API.g_miss_char)THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_PAGE_TYPE_INV'
			      , p_token1 => 'TEMPLATE_TYPE'
			      , p_value1 => l_type);
	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- check the end date and start date


     IF (p_end_date IS NOT NULL AND p_end_date < p_start_date) THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');

	x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


     IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

--debug_msg ('shore menu id = ' ||  to_char(p_shortcut_menu_id));
	pa_page_layout_pkg.Insert_page_layout_Row
	  (
	   p_page_name               => p_page_name,
	   p_page_type               => p_page_type,
	   p_description             => p_description,
	   p_start_date              => p_start_date,
	   p_end_date                => p_end_date,
           p_shortcut_menu_id        => l_menu_id,
           p_function_name           => p_function_name,
	   x_page_id                 => x_page_id,
	   x_return_status           => x_return_status,
	   x_msg_count               => x_msg_count,
	   x_msg_data                => x_msg_data
	   );

     END IF;


     -- Commit if the flag is set and there is no error
     IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
	COMMIT;
     END IF;

  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PAGE_LAYOUT_PVT_CREATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_PVT.Create_Page_Layout'
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

 p_page_id                     IN     number,

 p_page_name                   IN     VARCHAR2  := FND_API.g_miss_char,

-- p_page_type                   IN     VARCHAR2 := FND_API.g_miss_char,

 p_description                 IN     VARCHAR2 := FND_API.g_miss_char,

 p_start_date                  IN     date,

 p_end_date                    IN     date,
 p_shortcut_menu_id            IN     number,
 p_shortcut_menu_name          IN     VARCHAR2,
 p_record_version_number       IN NUMBER,
 p_function_name	       IN     VARCHAR2,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

      l_name_exists VARCHAR(20) := 'N';

      l_req VARCHAR2(1);

      CURSOR is_menu_id_required
	IS
	   select 'Y' from dual
	     where exists(
			  select  'Required'
                          from pa_lookups l, pa_page_layouts ppl
			  where l.lookup_type = 'PA_PAGE_TYPES'
			  and l.lookup_code = ppl.page_type_code
			  AND L.attribute2 = 'Y'
			  and ppl.page_id = p_page_id
			  );

      CURSOR get_menu_id
	IS
	   SELECT MENU_ID
	     FROM FND_MENUS_VL
	     where user_menu_name = p_shortcut_menu_name;

      CURSOR check_record_version IS
	 SELECT ROWID
	   FROM   pa_page_layouts
	   WHERE  page_id = p_page_id
	   AND    record_version_number = p_record_version_number;
      l_page_layout_row_id ROWID;

      CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups pl, pa_page_layouts ppl
	     WHERE pl.lookup_type = 'PA_PAGE_TYPES'
	     AND pl.lookup_code = ppl.PAGE_TYPE_CODE
	     AND ppl.page_id = p_page_id;

       l_menu_id NUMBER;
      l_dummy VARCHAR2(10) := 'Y';
      l_type VARCHAR2(250);

BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PAGE_LAYOUT_PVT_UPDATE;
  END IF;

   IF p_shortcut_menu_id IS NOT NULL AND p_shortcut_menu_id <> -99 THEN
     l_menu_id := p_shortcut_menu_id;
    ELSE

      OPEN is_menu_id_required;
      FETCH is_menu_id_required INTO l_req;
      IF is_menu_id_required%notfound THEN
	 CLOSE is_menu_id_required;
	 l_menu_id := p_shortcut_menu_id;
       ELSE
	 CLOSE is_menu_id_required;

	 OPEN get_menu_id;
	 FETCH get_menu_id INTO l_menu_id;

	 IF get_menu_id%notfound THEN
	    CLOSE get_menu_id;
	    PA_UTILS.Add_Message( p_app_short_name => 'PA'
				  ,p_msg_name       => 'PA_MENU_NAME_INV'
				  );
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	  ELSE
	    CLOSE get_menu_id;
	 END IF;
      END IF;

  END IF;

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  -- check the page id is not null
  IF (p_page_id IS NULL  OR p_page_id = FND_API.g_miss_num)THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PAGE_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  -- check the mandatory page name is not null
  IF (p_page_name IS NULL  OR p_page_name = FND_API.g_miss_char)THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PAGE_NAME_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type
			  );
    x_return_status := FND_API.G_RET_STS_ERROR;
  --ELSE
     -- check the page name is unique
 --    OPEN check_page_name;
   --  FETCH check_page_name INTO l_name_exists;
     --CLOSE check_page_name;

     --IF l_names_exists = 'Y' THEN
	--PA_UTILS.Add_Message( p_app_short_name => 'PA'
          --               ,p_msg_name       => 'PA_PAGE_NAME_EXISTS');
	--x_return_status := FND_API.G_RET_STS_ERROR;
     --END IF;
  END IF;

  IF (p_end_date IS NOT NULL AND p_end_date < p_start_date) THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_EFFECTIVE_ED_DATE_INV');

	x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  -- check the page type is not null
--  IF (p_page_type IS NULL  OR p_page_type = FND_API.g_miss_char)THEN
  --  PA_UTILS.Add_Message( p_app_short_name => 'PA'
    --                     ,p_msg_name       => 'PA_PAGE_TYPE_INV');
    --x_return_status := FND_API.G_RET_STS_ERROR;
  --END IF;

  IF x_return_status =  FND_API.g_ret_sts_success then
     -- check the record version number
     OPEN check_record_version;

     FETCH check_record_version INTO l_page_layout_row_id;

     IF check_record_version%NOTFOUND THEN
	CLOSE check_record_version;
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');

	x_return_status := FND_API.G_RET_STS_ERROR;

     ELSE
	CLOSE check_record_version;
	pa_page_layout_pkg.Update_page_layout_Row
	  (
	   p_page_id                 => p_page_id,
	   p_page_name               => p_page_name,
	   p_page_type               => null,
	   p_description             => p_description,
	   p_start_date              => p_start_date,
	   p_end_date                => p_end_date,
           p_shortcut_menu_id        => l_menu_id,
	   P_RECORD_VERSION_NUMBER   => p_record_version_number,
	   p_function_name           => p_function_name,
	   x_return_status           => x_return_status,
	   x_msg_count               => x_msg_count,
	   x_msg_data                => x_msg_data
	   );
     END IF;

  END IF;

 -- Commit if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.g_ret_sts_success) THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PAGE_LAYOUT_PVT_UPDATE;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_PVT.Update_Page_Layout'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END update_page_layout;



PROCEDURE Delete_Page_Layout
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     number,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

CURSOR check_page_layout IS
SELECT page_id
FROM   pa_page_layouts
  WHERE  (page_id = p_page_id AND p_page_id IS NOT NULL
	  AND record_version_number = Nvl(p_record_version_number, record_version_number));


CURSOR check_object_page_versions IS
SELECT page_id
FROM   pa_object_page_layouts
WHERE  (page_id = p_page_id AND p_page_id IS NOT NULL);

CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups pl,  pa_page_layouts ppl
	     WHERE pl.lookup_type = 'PA_PAGE_TYPES'
	     AND pl.lookup_code = ppl.page_type_code
	     AND ppl.page_id = p_page_id;

CURSOR get_page_type_code IS
SELECT page_type_code from pa_page_layouts
WHERE page_id = p_page_id;

l_type VARCHAR2(250);

l_page_id              NUMBER;
l_page_type_code       pa_page_layouts.page_type_code%TYPE;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Delete_Page_Layout');


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PAGE_LAYOUT_PVT_DELETE;
  END IF;

  --debug_msg('before delete');

  OPEN get_template_type;
  FETCH get_template_type INTO l_type;
  CLOSE get_template_type;

  OPEN check_page_layout;

  FETCH check_page_layout INTO l_page_id;

  IF check_page_layout%NOTFOUND THEN

     --debug_msg('before delete2');
      CLOSE check_page_layout;

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
      x_return_status := FND_API.G_RET_STS_ERROR;

  ELSE

     --debug_msg('before delete3');

     CLOSE check_page_layout;

     OPEN check_object_page_versions;

     FETCH check_object_page_versions INTO l_page_id;

     IF  check_object_page_versions%NOTFOUND THEN
	-- we can delete if this page is not used yet
	CLOSE check_object_page_versions;

	IF (p_validate_only = FND_API.g_false) THEN


	   --debug_msg('before delete 4');
        PA_PAGE_LAYOUT_PKG.Delete_page_layout_Row
        (
	 p_page_id            => p_page_id
	 ,p_record_version_number            => p_record_version_number
	 ,x_return_status         => x_return_status
	 ,x_msg_count             => x_msg_count
	 ,x_msg_data              => x_msg_data
	 );
        END IF;

	IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

--	   DELETE FROM pa_object_page_layouts
	--     WHERE page_id = p_page_id;

           -- if (sql%notfound) then
	   --       RAISE no_data_found;
	   -- end if;


	   DELETE FROM pa_page_layout_regions
	     WHERE page_id = p_page_id;

	END IF;
    ELSE --Bug#3302984 added this part of code.
        OPEN get_page_type_code;
	FETCH get_page_type_code INTO l_page_type_code;
	CLOSE get_page_type_code;

	IF (l_page_type_code = 'PPR') THEN
		CLOSE check_object_page_versions;

		PA_UTILS.Add_Message( p_app_short_name => 'PA'
			      ,p_msg_name       => 'PA_PAGE_IN_USE'
			      , p_token1 => 'TEMPLATE_TYPE'
			      , p_value1 => l_type);
		x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		PA_PAGE_LAYOUT_PKG.Delete_page_layout_Row
		(
		 p_page_id            => p_page_id
		 ,p_record_version_number            => p_record_version_number
		 ,x_return_status         => x_return_status
		 ,x_msg_count             => x_msg_count
		 ,x_msg_data              => x_msg_data
		 );

		 DELETE FROM pa_page_layout_regions
		 WHERE page_id = p_page_id;
	END IF;

	CLOSE check_object_page_versions;
     END IF;


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
          ROLLBACK TO PAGE_LAYOUT_PVT_DELETE;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PAGE_LAYOUT_PVT.Delete_Page_Layout'
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
  P_PAGE_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_SOURCE_CODE in VARCHAR2,
  P_VIEW_REGION_CODE in VARCHAR2,
  P_EDIT_REGION_CODE in VARCHAR2,
  P_REGION_STYLE     in VARCHAR2,
  P_DISPLAY_ORDER in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_view_region_code VARCHAR2(250);
   l_edit_region_code VARCHAR2(250);

   CURSOR get_edit_region_code
     IS
	SELECT view_region_code, edit_region_code
	  FROM pa_page_type_regions pptr, pa_page_layouts ppl
	  WHERE pptr.page_type_code = ppl.page_type_code
	  AND ppl.page_id = p_page_id
	  AND pptr.region_source_type = P_REGION_SOURCE_TYPE
	  AND pptr.view_region_code = P_VIEW_REGION_CODE;

   CURSOR get_template_type
	is
	   SELECT meaning FROM pa_lookups pl, pa_page_layouts ppl
	     WHERE pl.lookup_type = 'PA_PAGE_TYPES'
	     AND pl.lookup_code = ppl.page_type_code
	     AND ppl.page_id = p_page_id;

   l_type VARCHAR2(250);

BEGIN

    -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Add_Page_Region');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PVT_ADD_PAGE_REGION;
  END IF;

  -- check the mandatory page_id
  IF (p_page_id IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PAGE_ID_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_region_source_code IS null) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_REGION_CODE_INV'
			  , p_token1 => 'TEMPLATE_TYPE'
			  , p_value1 => l_type);
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF (p_edit_region_code IS NULL OR p_view_region_code IS NULL) THEN

     OPEN get_edit_region_code;
     FETCH get_edit_region_code INTO l_view_region_code, l_edit_region_code;

     /*
     IF (get_edit_region_code%notfound ) THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_REGION_REF_INV');
	x_return_status := FND_API.G_RET_STS_ERROR;

      ELSE

	NULL;
       END IF;*/

     CLOSE get_edit_region_code;
   ELSE
     l_view_region_code := p_view_region_code;
     l_edit_region_code := p_edit_region_code;
  END IF;


  IF (p_display_order IS NULL) then
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_DISPLAY_ORDER_INV');
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  IF (p_validate_only <>FND_API.g_true AND x_return_status = FND_API.g_ret_sts_success) then

	pa_page_layout_pkg.Insert_page_region_Row
	  (
	   p_page_id                 => p_page_id,
           p_region_source_type      => p_region_source_type,
           p_region_source_code      => p_region_source_code,
	   p_view_region_code             => p_view_region_code,
	   p_edit_region_code             => l_edit_region_code,
           p_region_style            => p_region_style,
	   p_display_order           => p_display_order,
	   x_return_status           => x_return_status,
	   x_msg_count               => x_msg_count,
	   x_msg_data                => x_msg_data
	   );


     -- Commit if the flag is set and there is no error
	IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
	   COMMIT;
	END IF;

  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO PVT_ADD_PAGE_REGION;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_LAYOUT_PVT.Add_Page_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is option

END add_page_region;


PROCEDURE Delete_Page_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_page_id                     IN     number,
 p_region_source_type          IN     VARCHAR2,
 p_region_source_code          IN     VARCHAR2,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

    l_row_id ROWID;

CURSOR check_page_region IS
SELECT rowid
FROM   pa_page_layout_regions
  WHERE  (page_id = p_page_id
          AND region_source_type = p_region_source_type
          AND region_source_code = p_region_source_code
	  AND record_version_number = Nvl(p_record_version_number, record_version_number));


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Delete_Page_Region');


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT PVT_DELETE_PAGE_REGION;
  END IF;


  OPEN check_page_region;

  FETCH check_page_region INTO l_row_id;

  IF check_page_region%NOTFOUND THEN

      CLOSE check_page_region;

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
      x_return_status := FND_API.G_RET_STS_ERROR;

  ELSE

     CLOSE check_page_region;

     IF (p_validate_only = FND_API.g_false) THEN


        PA_PAGE_LAYOUT_PKG.Delete_page_region_Row
        (
	 p_page_id                => p_page_id
	 ,p_region_source_type    => p_region_source_type
	 ,p_region_source_code    => p_region_source_code
	 ,p_record_version_number => p_record_version_number
	 ,x_return_status         => x_return_status
	 ,x_msg_count             => x_msg_count
	 ,x_msg_data              => x_msg_data
	 );
	END IF;

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
          ROLLBACK TO PVT_DELETE_PAGE_REGION;
         END IF;

         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PAGE_LAYOUT_PVT.Delete_Page_Region'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs

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

     CURSOR get_region IS
	  SELECT distinct pplr.page_id
             , pplr.region_source_type
             , pplr.region_source_code
             , pplr.record_version_number
        FROM pa_page_layout_regions pplr
           , pa_page_layouts ppl
           , pa_page_type_regions pptr
       WHERE pplr.page_id = p_page_id
       and ppl.page_id = pplr.page_id
       and ppl.page_type_code = pptr.page_type_code
       and pplr.region_source_type =  pptr.region_source_type
       and pplr.view_region_code =  pptr.view_region_code
       and nvl(pptr.default_region_position, 'L')
	    = nvl('L', nvl(pptr.default_region_position, 'L'))
	          AND Nvl(pplr.region_style, 'N') <> 'LINK';

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

  FOR reg_rec IN get_region loop
     PA_PAGE_LAYOUT_PKG.DELETE_PAGE_REGION_ROW
	(
	 p_page_id                 => p_page_id,
	 p_region_source_type        => reg_rec.region_source_type,
	 p_region_source_code        => reg_rec.region_source_code,
	 p_record_version_number   => reg_rec.record_version_number,

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
	-- break out of the loop;
	EXIT;
     END IF;

  END LOOP;

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

     CURSOR get_region is
        SELECT distinct pplr.page_id
             , pplr.region_source_type
             , pplr.region_source_code
             , pplr.record_version_number
        FROM pa_page_layout_regions pplr
       WHERE pplr.page_id = p_page_id
      AND Nvl(pplr.region_style, 'N') = 'LINK';
       --and pptr.default_region_position =
       --nvl(p_region_position, pptr.default_region_position);

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

  FOR reg_rec IN get_region loop
     PA_PAGE_LAYOUT_PKG.DELETE_PAGE_REGION_ROW
	(
	 p_page_id                 => p_page_id,
	 p_region_source_type        => reg_rec.region_source_type,
	 p_region_source_code        => reg_rec.region_source_code,
	 p_record_version_number   => reg_rec.record_version_number,

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
	-- break out of the loop;
	EXIT;
     END IF;

  END LOOP;

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

FUNCTION IS_REGION_DELETE_OK(p_region_source_type  in   varchar2,
                             p_region_source_code  in   varchar2) return varchar2 IS
 l_ret    varchar2(1) := 'N';
BEGIN
   select 'N'
     into l_ret
     from pa_page_layout_regions
    where region_source_type = p_region_source_type
      and region_source_code = p_region_source_code;
   return l_ret;
exception
   when no_data_found then
     return 'Y';
   when others then
     return 'N';
END IS_REGION_DELETE_OK;

END  PA_PAGE_LAYOUT_PVT;


/
