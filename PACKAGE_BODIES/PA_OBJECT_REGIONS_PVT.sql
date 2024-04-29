--------------------------------------------------------
--  DDL for Package Body PA_OBJECT_REGIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJECT_REGIONS_PVT" AS
--$Header: PAAPORVB.pls 120.2 2005/08/19 16:16:02 mwasowic noship $

procedure create_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID                   IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  P_REPLACEMENT_REG_CODE 	IN     VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
) IS
  CURSOR check_object_page_region_exits
     IS
	SELECT 'X'
	  FROM pa_object_regions
	  WHERE object_id = p_object_id
	  AND object_type = p_object_type
	  AND placeholder_reg_code = p_placeholder_reg_code;

   CURSOR check_valid_region(p_reg_code in varchar2)
     IS
        SELECT 'X'
          FROM pa_page_layout_regions
          WHERE
          view_region_code = p_reg_code
          OR nvl(edit_region_code,view_region_code) = p_reg_code;
    l_dummy   varchar2(1);

 BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT create_object_page_region;
  END IF;

  -- Check a valid place holder region
  open check_valid_region(P_PLACEHOLDER_REG_CODE);
  fetch check_valid_region into l_dummy;
  if(check_valid_region%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PA_PAGE_REGION_INV'
			  );
    x_return_status := FND_API.G_RET_STS_ERROR;
    close check_valid_region;
    return;
  end if;
  close check_valid_region;
  -- Check prior association doesn't exists
  open check_object_page_region_exits;
  fetch check_object_page_region_exits into l_dummy;
  if (check_object_page_region_exits%NOTFOUND) then
   close check_object_page_region_exits;
   -- Insert into pa_object_regions
   IF (p_validate_only <>FND_API.g_true
       AND x_return_status = FND_API.g_ret_sts_success) THEN

       PA_OBJECT_REGIONS_PKG.insert_row(
       	P_OBJECT_ID 		,
  	P_OBJECT_TYPE 		,
  	P_PLACEHOLDER_REG_CODE  ,
  	P_REPLACEMENT_REG_CODE  ,
  	sysdate        		,
	fnd_global.user_id	,
	sysdate			,
	fnd_global.user_id	,
        fnd_global.user_id	);
   END IF;

  else
    close check_object_page_region_exits;
  end if;

   -- Commit changes if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE
      AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO create_object_page_region;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name => 'PA_OBJECT_REGIONS_PVT.create_object_page_region'
          ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
   END create_object_page_region;

procedure update_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID 			IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  P_REPLACEMENT_REG_CODE 	IN     VARCHAR2,
  p_record_version_number 	IN     NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
is
CURSOR check_object_page_region_exits
     IS
	SELECT 'X'
	  FROM pa_object_regions
	  WHERE object_id = p_object_id
	  AND object_type = p_object_type
	  AND placeholder_reg_code = p_placeholder_reg_code;

   CURSOR check_valid_region(p_reg_code in varchar2)
     IS
        SELECT 'X'
          FROM pa_page_layout_regions
          WHERE
          view_region_code = p_reg_code
          OR nvl(edit_region_code,view_region_code) = p_reg_code;
    l_dummy   varchar2(1);

 BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT update_object_page_region;
  END IF;

  -- Check a valid place holder region
  open check_valid_region(P_PLACEHOLDER_REG_CODE);
  fetch check_valid_region into l_dummy;
  if(check_valid_region%NOTFOUND) then
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
			  ,p_msg_name       => 'PA_PA_PAGE_REGION_INV'
			  );
    x_return_status := FND_API.G_RET_STS_ERROR;
    close check_valid_region;
    return;
  end if;
  close check_valid_region;
  -- Delete the association if the replacement region code is null
   IF (P_REPLACEMENT_REG_CODE IS NULL) THEN

     PA_OBJECT_REGIONS_PKG.DELETE_ROW (
  			P_OBJECT_ID ,
  			P_OBJECT_TYPE ,
  			P_PLACEHOLDER_REG_CODE );
     RETURN;
  END IF;
   -- Update pa_object_regions
   IF (p_validate_only <>FND_API.g_true
       AND x_return_status = FND_API.g_ret_sts_success) THEN

       PA_OBJECT_REGIONS_PKG.update_row(
       	P_OBJECT_ID 		,
  	P_OBJECT_TYPE 		,
  	P_PLACEHOLDER_REG_CODE  ,
  	P_REPLACEMENT_REG_CODE  ,
	p_record_version_number ,
	sysdate			,
	fnd_global.user_id	,
        fnd_global.user_id	);
   END IF;

   -- Commit changes if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE
      AND  x_return_status = FND_API.g_ret_sts_success  )THEN
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
        ROLLBACK TO update_object_page_region;
     END IF;
     RAISE;
    WHEN OTHERS THEN
     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO update_object_page_region;
     END IF;
     -- Set the excetption Message and the stack
     FND_MSG_PUB.add_exc_msg
       ( p_pkg_name => 'PA_OBJECT_REGIONS_PVT.update_object_page_region'
        ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
 End update_object_page_region;

procedure DELETE_object_page_region (
  p_api_version                 IN     NUMBER :=  1.0,
  p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
  p_commit                      IN     VARCHAR2 := FND_API.g_false,
  p_validate_only               IN     VARCHAR2 := FND_API.g_true,
  p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
  P_OBJECT_ID 			IN     NUMBER,
  P_OBJECT_TYPE 		IN     VARCHAR2,
  P_PLACEHOLDER_REG_CODE 	IN     VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				      )
IS
Begin
-- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_LAYOUT_PVT.Create_Page_Layout');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT update_object_page_region;
  END IF;

  IF (p_validate_only <>FND_API.g_true
       AND x_return_status = FND_API.g_ret_sts_success) THEN

       PA_OBJECT_REGIONS_PKG.delete_row(
       	P_OBJECT_ID 		,
  	P_OBJECT_TYPE 		,
  	P_PLACEHOLDER_REG_CODE  );
   END IF;

   -- Commit changes if the flag is set and there is no error
  IF (p_commit = FND_API.G_TRUE
      AND  x_return_status = FND_API.g_ret_sts_success  )THEN
     COMMIT;
  END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN OTHERS THEN
     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO delete_object_page_region;
     END IF;
     -- Set the excetption Message and the stack
     FND_MSG_PUB.add_exc_msg
       ( p_pkg_name => 'PA_OBJECT_REGIONS_PVT.delete_object_page_region'
        ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

End DELETE_object_page_region;

END  PA_OBJECT_REGIONS_PVT;

/
