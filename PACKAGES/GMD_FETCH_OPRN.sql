--------------------------------------------------------
--  DDL for Package GMD_FETCH_OPRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FETCH_OPRN" AUTHID CURRENT_USER AS
/* $Header: GMDPOPNS.pls 115.11 2002/10/24 19:41:49 santunes noship $ */

-- Start of commments
-- API name     : get_oprn_act
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version      IN   NUMBER      Required
--                      p_init_msg_list    IN   Varchar2    Optional
--                      p_oprn_id          IN   Number      Required
--                      x_return_status    OUT NOCOPY   varchar2(1)
--                      x_msg_count        OUT NOCOPY   Number
--                      x_msg_data         OUT NOCOPY   varchar2(2000)
--                      x_return_code      OUT NOCOPY   Number
--                      X_oprn_act_tbl     OUT NOCOPY   oprn_act_out
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

PROCEDURE get_oprn_act
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN       NUMBER                         ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER                         ,
        x_oprn_act_out          OUT NOCOPY      gmd_recipe_fetch_pub.oprn_act_tbl
);


-- Start of commments
-- API name     : get_oprn_resc
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version      IN NUMBER   Required
--                      p_init_msg_list    IN Varchar2 Optional
--                      p_oprn_id          IN Number
--                      x_return_status    OUT NOCOPY  varchar2(1)
--                      x_msg_count        OUT NOCOPY  Number
--                      x_msg_data         OUT NOCOPY  varchar2(2000)
--                      x_return_code      OUT NOCOPY       NUMBER
--                      x_oprn_resc_tbl    OUT NOCOPY  oprn_resc_out
--                      x_oprn_resc_proc_param_tbl   OUT NOCOPY    recp_resc_proc_param_rec
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

PROCEDURE get_oprn_resc
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN      NUMBER                          ,
        p_orgn_code             IN      VARCHAR2                        ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER                         ,
        X_oprn_resc_rec         OUT NOCOPY     gmd_recipe_fetch_pub.oprn_resc_tbl,
        X_oprn_resc_proc_param_tbl   OUT NOCOPY     gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
);

	-- Start of commments
-- API name     : fetch_oprn
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version      IN    NUMBER       Required
--                      p_init_msg_list    IN    Varchar2   Optional
--                      p_oprn_id          IN    Number      Required
--                      x_return_status    OUT NOCOPY    Varchar2(1)
--                      x_msg_count        OUT NOCOPY    Number
--                      x_msg_data         OUT NOCOPY    Varchar2(2000)
--                      x_return_code      OUT NOCOPY    Number
--                      X_oprn_act_tbl     OUT NOCOPY   oprn_act_out
--                      x_oprn_resc_tbl   OUT NOCOPY    oprn_resc_out
--                      x_oprn_resc_proc_param_tbl   OUT NOCOPY    recp_resc_proc_param_rec
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments



PROCEDURE fetch_oprn
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN        NUMBER                        ,
         p_orgn_code             IN      VARCHAR2                       ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER                         ,
        X_oprn_act_out           OUT NOCOPY      gmd_recipe_fetch_pub.oprn_act_tbl ,
        X_oprn_resc_rec         OUT NOCOPY      gmd_recipe_fetch_pub.oprn_resc_tbl,
        X_oprn_resc_proc_param_tbl   OUT NOCOPY     gmd_recipe_fetch_pub.recp_resc_proc_param_tbl);

	-- Start of commments
-- API name     : get_oprn_process_param_detl
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version      IN    NUMBER       Required
--                      p_init_msg_list    IN    Varchar2   Optional
--                      p_oprn_id          IN    Number      Required
--                      x_return_status    OUT NOCOPY    Varchar2(1)
--                      x_msg_count        OUT NOCOPY    Number
--                      x_msg_data         OUT NOCOPY    Varchar2(2000)
--                      x_return_code      OUT NOCOPY    Number
--                      x_oprn_resc_proc_param_tbl   OUT NOCOPY    recp_resc_proc_param_rec
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

PROCEDURE get_oprn_process_param_detl
(       p_api_version              IN      NUMBER                          ,
        p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_line_id             IN      NUMBER                          ,
        p_resources                IN      VARCHAR2                        ,
        x_return_status            OUT NOCOPY      VARCHAR2                        ,
        x_msg_count                OUT NOCOPY      NUMBER                          ,
        x_msg_data                 OUT NOCOPY      VARCHAR2                        ,
        X_oprn_resc_proc_param_tbl OUT NOCOPY      gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
);



 END GMD_FETCH_OPRN;

 

/
