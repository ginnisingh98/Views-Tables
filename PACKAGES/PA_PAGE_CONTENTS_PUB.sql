--------------------------------------------------------
--  DDL for Package PA_PAGE_CONTENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAGE_CONTENTS_PUB" AUTHID CURRENT_USER AS
--$Header: PAPGCTPS.pls 115.2 2002/12/03 18:23:29 mwasowic noship $

procedure CREATE_PAGE_CONTENTS (

         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

        ,P_OBJECT_TYPE          IN      VARCHAR2
        ,P_PK1_VALUE            IN      VARCHAR2
        ,P_PK2_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK3_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK4_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK5_VALUE            IN      VARCHAR2 :=NULL

        ,x_page_content_id      OUT     NOCOPY NUMBER
        ,x_return_status        OUT     NOCOPY VARCHAR2
        ,x_msg_count            OUT     NOCOPY NUMBER
        ,x_msg_data             OUT     NOCOPY VARCHAR2
);


procedure DELETE_PAGE_CONTENTS (
         p_api_version          IN      NUMBER   :=  1.0
        ,p_init_msg_list        IN      VARCHAR2 := fnd_api.g_true
        ,p_commit               IN      VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN      VARCHAR2 := FND_API.g_true
        ,p_max_msg_count        IN      NUMBER   := FND_API.g_miss_num

        ,P_PAGE_CONTENT_ID      IN      NUMBER   :=NULL
        ,P_OBJECT_TYPE          IN      VARCHAR2 :=NULL
        ,P_PK1_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK2_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK3_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK4_VALUE            IN      VARCHAR2 :=NULL
        ,P_PK5_VALUE            IN      VARCHAR2 :=NULL

        ,x_return_status        OUT     NOCOPY VARCHAR2
        ,x_msg_count            OUT     NOCOPY NUMBER
        ,x_msg_data             OUT     NOCOPY VARCHAR2
);
END  PA_PAGE_CONTENTS_PUB;

 

/
