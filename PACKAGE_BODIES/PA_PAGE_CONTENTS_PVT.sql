--------------------------------------------------------
--  DDL for Package Body PA_PAGE_CONTENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_CONTENTS_PVT" AS
--$Header: PAPGCTVB.pls 120.0 2005/05/30 19:06:03 appldev noship $

procedure ADD_PAGE_CONTENTS (

         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

        ,P_OBJECT_TYPE          IN      VARCHAR2
        ,P_PK1_VALUE            IN      VARCHAR2
        ,P_PK2_VALUE            IN      VARCHAR2
        ,P_PK3_VALUE            IN      VARCHAR2
        ,P_PK4_VALUE            IN      VARCHAR2
        ,P_PK5_VALUE            IN      VARCHAR2

        ,x_page_content_id      OUT     NOCOPY NUMBER
        ,x_return_status        OUT     NOCOPY VARCHAR2
        ,x_msg_count            OUT     NOCOPY NUMBER
        ,x_msg_data             OUT     NOCOPY VARCHAR2

) is

   l_content_id NUMBER;

   --cursor C is select ROWID from PA_PAGE_CONTENTS
   --  where Page_content_id = l_content_id;

BEGIN

 -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_CONTENTS_PVT.Add_Page_Contents');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF P_PK1_VALUE is null  THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_ID_INV');
           x_return_status := 'E';

  END IF;

  IF P_OBJECT_TYPE is NULL  THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_INVALID_OBJECT_TYPES');
           x_return_status := 'E';
  END IF;

  IF x_return_status = 'S' THEN
      -- Issue API savepoint if the transaction is to be committed
      IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT add_page_contents;
      END IF;

      --get the unique page content id from the Oracle Sequence
      /* Commented for bug 3866224 to remove hard coded schema reference and modified as below
      SELECT pa.pa_page_contents_s.nextval */
      SELECT pa_page_contents_s.nextval
      INTO l_content_id
      FROM DUAL;

      PA_PAGE_CONTENTS_PKG.INSERT_PAGE_CONTENTS_ROW (
         l_content_id
        ,P_OBJECT_TYPE
        ,P_PK1_VALUE
        ,P_PK2_VALUE
        ,P_PK3_VALUE
        ,P_PK4_VALUE
        ,P_PK5_VALUE
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        );
      x_page_content_id := l_content_id;
   END IF;

     -- Commit if the flag is set and there is no error
   IF (p_commit = FND_API.G_TRUE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
      COMMIT;
   END IF;

 -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN OTHERS THEN
      rollback to add_page_contents;
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_CONTENTS_PVT.ADD_PAGE_CONTENTS'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end ADD_PAGE_CONTENTS;


procedure DELETE_PAGE_CONTENTS (
         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

  	,P_PAGE_CONTENT_ID      IN 	NUMBER
  	,x_return_status        OUT    	NOCOPY VARCHAR2
  	,x_msg_count            OUT    	NOCOPY NUMBER
  	,x_msg_data             OUT    	NOCOPY VARCHAR2
) is
begin
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Delete_PageContents');

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF P_PAGE_CONTENT_ID is null  THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_ID_INV');
           x_return_status := 'E';
  END IF;

  IF x_return_status = 'S' THEN
      -- Issue API savepoint if the transaction is to be committed
      IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT delete_page_contents;
      END IF;
      PA_PAGE_CONTENTS_PKG.DELETE_PAGE_CONTENTS_ROW(
         P_PAGE_CONTENT_ID
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
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
          ROLLBACK TO delete_page_contents;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_CONTENTS_PVT.delete_page_contents'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_PAGE_CONTENTS;

procedure CLEAR_PAGE_CONTENTS (
         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

        ,P_PAGE_CONTENT_ID      IN      NUMBER
        ,x_return_status        OUT     NOCOPY VARCHAR2
        ,x_msg_count            OUT     NOCOPY NUMBER
        ,x_msg_data             OUT     NOCOPY VARCHAR2
) is
begin
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CONTROL_ITEMS_PVT.Clear_Page_Contents');

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF P_PAGE_CONTENT_ID is null  THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_ID_INV');
           x_return_status := 'E';

  END IF;

  IF x_return_status = 'S' THEN
      -- Issue API savepoint if the transaction is to be committed
      IF p_commit  = FND_API.G_TRUE THEN
        SAVEPOINT clear_page_contents;
      END IF;

      PA_PAGE_CONTENTS_PKG.CLEAR_CLOB(
         P_PAGE_CONTENT_ID
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
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
          ROLLBACK TO clear_page_contents;
        END IF;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_CONTENTS_PVT.clear_page_contents'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end CLEAR_PAGE_CONTENTS;


END  PA_PAGE_CONTENTS_PVT;

/
