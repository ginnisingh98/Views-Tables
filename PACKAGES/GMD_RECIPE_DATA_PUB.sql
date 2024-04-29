--------------------------------------------------------
--  DDL for Package GMD_RECIPE_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_DATA_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPRDTS.pls 120.1 2005/07/21 02:48:40 kkillams noship $ */

-- Start of commments
-- API name     : get_recipe_data
-- Type         :
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version           IN      NUMBER   Required
--                      p_init_msg_list         IN      Varchar2 Optional
--                      p_recipe_id             IN      NUMBER
--                      x_return_status         OUT     varchar2(1)
--                      x_msg_count             OUT     Number
--                      x_msg_data              OUT     varchar2(2000)
--                      x_recipe_validity_tbl   OUT     recipe_validity_tbl
--                      x_recipe_rout_matl_tbl  OUT     recipe_rout_matl_tbl
--                      x_recipe_step_out       OUT     recipe_step_tbl
--                      x_routing_depd_tbl      OUT     routing_depd_tbl
--                      x_oprn_act_out          OUT     oprn_act_tbl
--                      X_oprn_resc_rec         OUT     oprn_resc_tbl

-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

PROCEDURE get_recipe_data
(       p_api_version           IN              NUMBER                                          ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE                     ,
        p_recipe_id             IN              NUMBER                                          ,
        p_organization_id       IN              NUMBER  DEFAULT NULL                            ,
        p_date                  IN              DATE    DEFAULT NULL                            , --Bug 4479101
        x_return_status         OUT NOCOPY      VARCHAR2                                        ,
        x_msg_count             OUT NOCOPY      NUMBER                                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                                        ,
        x_return_code           OUT NOCOPY      NUMBER                                          ,
        x_recipe_rout_tbl       OUT NOCOPY      gmd_recipe_fetch_pub.recipe_rout_tbl            ,
        x_recipe_rout_matl_tbl  OUT NOCOPY      gmd_recipe_fetch_pub.recipe_rout_matl_tbl       ,
        x_recipe_step_out       OUT NOCOPY      gmd_recipe_fetch_pub.recipe_step_tbl            ,
        x_routing_depd_tbl      OUT NOCOPY      gmd_recipe_fetch_pub.routing_depd_tbl           ,
        x_oprn_act_out          OUT NOCOPY      gmd_recipe_fetch_pub.oprn_act_tbl               ,
        x_oprn_resc_rec         OUT NOCOPY      gmd_recipe_fetch_pub.oprn_resc_tbl              ,
        x_formula_header_rec    OUT NOCOPY      fm_form_mst%ROWTYPE                             ,
        x_formula_dtl_tbl       OUT NOCOPY      gmdfmval_pub.formula_detail_tbl                 ,
        x_recp_resc_proc_param_tbl OUT NOCOPY   gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
);

END GMD_RECIPE_DATA_PUB;

 

/
