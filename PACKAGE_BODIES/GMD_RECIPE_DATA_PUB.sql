--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_DATA_PUB" AS
/* $Header: GMDPRDTB.pls 120.1 2005/07/21 02:49:36 kkillams noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'gmd_recipe_data_pub';

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
)
  IS


/* local Variable*/
 p_return_status         VARCHAR2(100) := FND_API.G_RET_STS_SUCCESS;
 lrecord_type            gmdfmval_pub.formula_info_in;
 x_recipe_id             gmd_recipes.recipe_id%TYPE ;
 x_routing_id            fm_rout_hdr.routing_id%TYPE ;
 l_return_status         VARCHAR2(1);
 l_msg_count             NUMBER;
 l_msg_data              VARCHAR2(240);
 l_return_code           NUMBER;


BEGIN

       IF p_recipe_id IS NOT NULL THEN
           gmd_recipe_val.recipe_exists(p_api_version,p_init_msg_list,NULL,NULL,p_recipe_id, NULL,NULL,
                                    x_return_status,x_msg_count, x_msg_data, x_return_code, x_recipe_id);
           IF x_return_status <> p_return_status THEN
                   x_return_code := 2;
                --   x_return_status := 2;
           Else
              lrecord_type.recipe_id := p_recipe_id;

              gmdfmval_pub.get_element(pElement_name           => 'RECIPE'
                                      ,pRecord_in              => lrecord_type
                                      ,pDate                   => p_date  --Bug 4479101
                                      ,xFormulaHeader_rec      => x_formula_header_rec
                                      ,xFormulaDetail_tbl      => x_formula_dtl_tbl
                                      ,xReturn                 => x_return_status);
               IF x_return_status <>p_return_status THEN
                       x_return_code := 3;
                     --  x_return_status := 3;
               Else
                   gmd_recipe_fetch_pub.get_rout_hdr(p_api_version,p_init_msg_list, p_recipe_id,
                                                        x_return_status, x_msg_count, x_msg_data,
                                                         x_return_code, x_recipe_rout_tbl);

                   IF x_return_status <>p_return_status THEN
                       x_return_code := 4 ;
                     --  x_return_status := 4;
                   ELSE
                     gmd_recipe_fetch_pub.get_step_depd_details( p_api_version,p_init_msg_list, p_recipe_id,
                                                               x_return_status, x_msg_count, x_msg_data,
                                                               x_return_code,  x_routing_depd_tbl);

                   IF x_return_status = 'U' THEN
                      x_return_code := 8 ;
                   ELSE
                     gmd_recipe_fetch_pub.get_rout_material( p_api_version,p_init_msg_list, p_recipe_id, x_return_status, x_msg_count, x_msg_data,
                                              x_return_code, x_recipe_rout_matl_tbl);


                          gmd_recipe_fetch_pub.get_recipe_step_details(p_api_version,p_init_msg_list, p_recipe_id,p_organization_id,
                                                                       x_return_status, x_msg_count, x_msg_data,
                                                                       x_return_code, x_recipe_step_out);
                              IF x_return_status <>p_return_status THEN
                                 x_return_code := 5;
                               -- x_return_status := 5;
                              ELSE
                                     gmd_recipe_fetch_pub.get_oprn_act_detl(p_api_version,p_init_msg_list, p_recipe_id,p_organization_id,
                                                            x_return_status, x_msg_count, x_msg_data,
                                                            x_return_code, x_oprn_act_out);
                                       IF x_return_status <>p_return_status THEN
                                               x_return_code := 6;
                                             --   x_return_status := 6;
                                        ELSE
                                              gmd_recipe_fetch_pub.get_oprn_resc_detl( p_api_version,p_init_msg_list, p_recipe_id,p_organization_id,
                                                                x_return_status, x_msg_count, x_msg_data,
                                                                x_return_code, x_oprn_resc_rec);
                                               IF x_return_status <>p_return_status THEN

                                                 x_return_code := 7;
                                                 -- x_return_status := 7;
                                               ELSE
                                                 gmd_recipe_fetch_pub.get_recipe_process_param_detl(p_api_version               => p_api_version,
                                                                                                    p_init_msg_list             => p_init_msg_list,
                                                                                                    p_recipe_id                 => p_recipe_id,
                                                                                                    p_organization_id           => p_organization_id,
                                                                                                    x_return_status             => x_return_status,
                                                                                                    x_msg_count                 => x_msg_count,
                                                                                                    x_msg_data                  => x_msg_data,
                                                                                                    x_recp_resc_proc_param_tbl  => x_recp_resc_proc_param_tbl);
                                                 IF x_return_status <> p_return_status THEN
                                                   x_return_code := 9;
                                                 END IF;
                                               END IF;

                                        END IF;
                               END IF;
                          END IF;
                      END IF;
                   END IF;

             END IF;

        ElSE
             x_return_code := 1;
          --  x_return_status := '1';

         END IF;


         IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             x_return_code := 0;
           -- x_return_status := 0;
         END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END ;

END GMD_RECIPE_DATA_PUB ;

/
