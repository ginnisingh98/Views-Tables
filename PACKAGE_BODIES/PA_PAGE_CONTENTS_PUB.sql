--------------------------------------------------------
--  DDL for Package Body PA_PAGE_CONTENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_CONTENTS_PUB" AS
--$Header: PAPGCTPB.pls 120.1 2006/02/24 02:33:46 appldev noship $

--Bug 5020365.When this API is called from paxstcvb.Generate_Error_Page, some messages
--added in publish flow might already be there in fnd_msg_pub. In this case, this API
--should not raise error and let the calling API take care of it. Made changes to not
--raise error if the error message is not added to the msg pub by this API

procedure CREATE_PAGE_CONTENTS (

         p_api_version          IN	NUMBER   :=  1.0
        ,p_init_msg_list        IN     	VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     	VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     	VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN     	NUMBER   := FND_API.g_miss_num

  	,P_OBJECT_TYPE    	IN 	VARCHAR2
  	,P_PK1_VALUE      	IN 	VARCHAR2
  	,P_PK2_VALUE      	IN 	VARCHAR2 :=NULL
  	,P_PK3_VALUE      	IN 	VARCHAR2 :=NULL
  	,P_PK4_VALUE      	IN 	VARCHAR2 :=NULL
  	,P_PK5_VALUE      	IN 	VARCHAR2 :=NULL

  	,x_page_content_id      OUT    	NOCOPY NUMBER
  	,x_return_status        OUT    	NOCOPY VARCHAR2
  	,x_msg_count            OUT    	NOCOPY NUMBER
  	,x_msg_data             OUT    	NOCOPY VARCHAR2
) is

   	l_rowid 	ROWID;
   	l_content_id 	NUMBER;
   	l_msg_index_out NUMBER;
    l_init_msg_count NUMBER;--Bug 5020365


	CURSOR existing_record IS
		SELECT PAGE_CONTENT_ID
		FROM   PA_PAGE_CONTENTS
		WHERE  OBJECT_TYPE	= P_OBJECT_TYPE
  		AND    NVL(PK1_VALUE,0)	= NVL(P_PK1_VALUE,0)
        	AND    NVL(PK2_VALUE,0) = NVL(P_PK2_VALUE,0)
        	AND    NVL(PK3_VALUE,0) = NVL(P_PK3_VALUE,0)
        	AND    NVL(PK4_VALUE,0) = NVL(P_PK4_VALUE,0)
        	AND    NVL(PK5_VALUE,0) = NVL(P_PK5_VALUE,0);



BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_CONTENTS_PUB.Save_Page_Contents');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Bug 5020365. Keep track of the messages that are there in the stack at the begining.
  l_init_msg_count:=0;
  l_init_msg_count := fnd_msg_pub.count_msg;

  OPEN existing_record;
  FETCH existing_record INTO l_content_id;

  IF existing_record%NOTFOUND THEN
    	PA_PAGE_CONTENTS_PVT.ADD_PAGE_CONTENTS (
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

    	,P_OBJECT_TYPE
    	,P_PK1_VALUE
    	,P_PK2_VALUE
    	,P_PK3_VALUE
    	,P_PK4_VALUE
    	,P_PK5_VALUE
	,x_page_content_id
    	,x_return_status
    	,x_msg_count
    	,x_msg_data
    	);
   ELSE
 	x_page_content_id := l_content_id;
	CLOSE existing_record;

        PA_PAGE_CONTENTS_PVT.CLEAR_PAGE_CONTENTS (
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

        ,x_page_content_id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data
        );

   END IF;


  -- IF the number of messages is 1 then fetch the message code from the stack
  -- and return its text
  -- Bug 5020365. Get the message only if the message is added to stack in this procedure.
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF (l_init_msg_count <>1 AND x_msg_count = 1) THEN
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
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_CONTENTS_PUB.SAVE_PAGE_CONTENTS'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end CREATE_PAGE_CONTENTS;

procedure DELETE_PAGE_CONTENTS (
         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

  	,P_PAGE_CONTENT_ID      IN 	NUMBER   :=NULL
        ,P_OBJECT_TYPE          IN      VARCHAR2 :=NULL
        ,P_PK1_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK2_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK3_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK4_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK5_VALUE            IN      VARCHAR2 :=NULL

  --      ,x_page_content_id      OUT     NUMBER
        ,x_return_status        OUT     NOCOPY VARCHAR2
        ,x_msg_count            OUT     NOCOPY NUMBER
        ,x_msg_data             OUT     NOCOPY VARCHAR2
) is
        l_rowid         ROWID;
        l_content_id    NUMBER;
        l_msg_index_out NUMBER;


        CURSOR existing_record IS
                SELECT PAGE_CONTENT_ID
                FROM   PA_PAGE_CONTENTS
                WHERE  OBJECT_TYPE      = P_OBJECT_TYPE
                AND    NVL(PK1_VALUE,0) = NVL(P_PK1_VALUE,0)
                AND    NVL(PK2_VALUE,0) = NVL(P_PK2_VALUE,0)
                AND    NVL(PK3_VALUE,0) = NVL(P_PK3_VALUE,0)
                AND    NVL(PK4_VALUE,0) = NVL(P_PK4_VALUE,0)
                AND    NVL(PK5_VALUE,0) = NVL(P_PK5_VALUE,0);

begin
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PAGE_CONTENTS_PUB.Delete_Page_Contents');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  l_content_id := P_PAGE_CONTENT_ID;

  --Retrieve Page_Content_id from key values
  IF P_PAGE_CONTENT_ID is NULL THEN
      IF P_OBJECT_TYPE is NOT NULL THEN
         OPEN existing_record;
         FETCH existing_record INTO l_content_id;
         IF existing_record%NOTFOUND THEN
           CLOSE existing_record;
           return;
         END IF;
         CLOSE existing_record;
      ELSE
         return;
      END IF;
  END IF;

  PA_PAGE_CONTENTS_PVT.DELETE_PAGE_CONTENTS (
         p_api_version
        ,p_init_msg_list
        ,p_commit
        ,p_validate_only
        ,p_max_msg_count

        ,l_content_id
        ,x_return_status
        ,x_msg_count
        ,x_msg_data);

  -- IF the number of messages is 1 then fetch the message code from the stack
  -- and return its text
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
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PAGE_CONTENTS_PUB.DELETE_PAGE_CONTENTS'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_PAGE_CONTENTS;

END  PA_PAGE_CONTENTS_PUB;

/
