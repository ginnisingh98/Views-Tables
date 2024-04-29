--------------------------------------------------------
--  DDL for Package Body GMD_VAL_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_VAL_DATA_PUB" AS
/* $Header: GMDPVRDB.pls 120.2 2008/02/01 10:23:12 kannavar ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'gmd_val_data_pub';
PROCEDURE get_val_data
(			     p_api_version         IN  NUMBER				,
                             p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE	,
                             p_object_type         IN  VARCHAR2				,
                             p_recipe_no           IN  VARCHAR2 := NULL			,
                             p_recipe_version      IN  NUMBER 	:= NULL			,
                             p_recipe_id           IN  NUMBER	:= NULL			,
                             p_total_input         IN  NUMBER	:= NULL			,
                             p_total_output        IN  NUMBER	:= NULL			,
                             p_formula_id          IN  NUMBER	:= NULL			,
                             p_item_id             IN  NUMBER   := NULL			,
                             p_revision            IN  VARCHAR2 := NULL                 ,
                             p_item_no             IN  VARCHAR2 := NULL			,
                             p_product_qty         IN  NUMBER   := NULL			,
                             p_uom                 IN  VARCHAR2 := NULL			,
                             p_recipe_use          IN  VARCHAR2 := NULL			,
                             p_orgn_code           IN  VARCHAR2 := NULL			,
                             p_organization_id     IN  NUMBER   := NULL                 ,
     			     p_least_cost_validity IN  VARCHAR2 := 'F'			,
                             p_start_date          IN  DATE 	:= NULL			,
                             p_end_date            IN  DATE	:= NULL			,
                             p_status_type         IN  VARCHAR2 := NULL			,
                             p_validity_rule_id    IN  NUMBER   := NULL                 ,
                             x_return_status       OUT NOCOPY VARCHAR2			,
                             x_msg_count           OUT NOCOPY NUMBER			,
                             x_msg_data            OUT NOCOPY VARCHAR2			,
                             x_return_code         OUT NOCOPY NUMBER			,
                             X_recipe_validity_out OUT NOCOPY GMD_VALIDITY_RULES.recipe_validity_tbl)
  IS


/* local Variable*/
 p_return_status         VARCHAR2(100) := FND_API.G_RET_STS_SUCCESS;
-- lrecord_type		 gmdfmval_pub.formula_info_in;
-- x_recipe_id             gmd_recipes.recipe_id%type ;
-- x_routing_id            fm_rout_hdr.routing_id%type ;
 l_return_status 	varchar2(1);
 l_msg_count 		number;
 l_msg_data 		varchar2(240);
 l_return_code 		number;
 l_recipe_validity_tab GMD_VALIDITY_RULES.recipe_validity_tbl;
 j number default 0;


BEGIN
    IF p_object_type = 'P' then

        GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,null,p_orgn_code,p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,p_status_type,p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, X_recipe_validity_out);

    Elsif    p_object_type = 'F'     then
            GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,1,p_orgn_code,p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,p_status_type,p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, X_recipe_validity_out);




     Elsif    p_object_type = 'L'  then
          GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,null,p_orgn_code, p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,p_status_type,p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, X_recipe_validity_out);

          GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,NULL,p_orgn_code,p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,'400',p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, l_recipe_validity_tab);
              j :=X_recipe_validity_out.count;
              FOR i IN 1..l_recipe_validity_tab.count
             LOOP
                x_recipe_validity_out(j+i) := l_recipe_validity_tab(i);
             END LOOP;


            GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,NULL,p_orgn_code, p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,'500',p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, l_recipe_validity_tab);
              j :=X_recipe_validity_out.count;
              FOR i IN 1..l_recipe_validity_tab.count
             LOOP
                x_recipe_validity_out(j+i) := l_recipe_validity_tab(i);
             END LOOP;


             GMD_VALIDITY_RULES.get_validity_rules(p_api_version,p_init_msg_list,p_recipe_no,p_recipe_version ,
                                      p_recipe_id,p_total_input, p_total_output,p_formula_id,p_item_id,p_revision,
                                      p_item_no,p_product_qty,p_uom,null,p_orgn_code,p_organization_id, p_least_cost_validity, p_start_date,
                                      p_end_date,'600',p_validity_rule_id, x_return_status,x_msg_count, x_msg_data,
                                       x_return_code, l_recipe_validity_tab);
              j :=X_recipe_validity_out.count;
              FOR i IN 1..l_recipe_validity_tab.count
             LOOP
                x_recipe_validity_out(j+i) := l_recipe_validity_tab(i);
             END LOOP;

       /* Bug No.6788488 - Start */
       BEGIN
       DELETE FROM GMD_VAL_RULE_GTMP;
       IF x_recipe_validity_out.count > 0 THEN
         FOR i in 1..x_recipe_validity_out.count LOOP
           INSERT INTO GMD_VAL_RULE_GTMP(
	        recipe_validity_rule_id, recipe_id              , orgn_code              , recipe_use             ,
	        preference             , start_date             , end_date               , min_qty                ,
	        max_qty                , std_qty                , inv_min_qty            , inv_max_qty            ,
	        text_code              , attribute_category     , attribute1             , attribute2             ,
	        attribute3             , attribute4             , attribute5             , attribute6             ,
	        attribute7             , attribute8             , attribute9             , attribute10            ,
	        attribute11            , attribute12            , attribute13            , attribute14            ,
	        attribute15            , attribute16            , attribute17            , attribute18            ,
	        attribute19            , attribute20            , attribute21            , attribute22            ,
	        attribute23            , attribute24            , attribute25            , attribute26            ,
	        attribute27            , attribute28            , attribute29            , attribute30            ,
	        created_by             , creation_date          , last_updated_by        , last_update_date       ,
	        last_update_login      , validity_rule_status   , planned_process_loss   , organization_id        ,
	        inventory_item_id      , revision               , detail_uom             , unit_cost		  ,
	        total_cost	       , delete_mark)
           VALUES
	        (
	        x_recipe_validity_out(i).recipe_validity_rule_id, x_recipe_validity_out(i).recipe_id              ,
	        x_recipe_validity_out(i).orgn_code              , x_recipe_validity_out(i).recipe_use             ,
	        x_recipe_validity_out(i).preference             , x_recipe_validity_out(i).start_date             ,
	        x_recipe_validity_out(i).end_date               , x_recipe_validity_out(i).min_qty                ,
	        x_recipe_validity_out(i).max_qty                , x_recipe_validity_out(i).std_qty                ,
	        x_recipe_validity_out(i).inv_min_qty            , x_recipe_validity_out(i).inv_max_qty            ,
	        x_recipe_validity_out(i).text_code              , x_recipe_validity_out(i).attribute_category     ,
	        x_recipe_validity_out(i).attribute1             , x_recipe_validity_out(i).attribute2             ,
	        x_recipe_validity_out(i).attribute3             , x_recipe_validity_out(i).attribute4             ,
	        x_recipe_validity_out(i).attribute5             , x_recipe_validity_out(i).attribute6             ,
	        x_recipe_validity_out(i).attribute7             , x_recipe_validity_out(i).attribute8             ,
	        x_recipe_validity_out(i).attribute9             , x_recipe_validity_out(i).attribute10            ,
	        x_recipe_validity_out(i).attribute11            , x_recipe_validity_out(i).attribute12            ,
	        x_recipe_validity_out(i).attribute13            , x_recipe_validity_out(i).attribute14            ,
	        x_recipe_validity_out(i).attribute15            , x_recipe_validity_out(i).attribute16            ,
	        x_recipe_validity_out(i).attribute17            , x_recipe_validity_out(i).attribute18            ,
	        x_recipe_validity_out(i).attribute19            , x_recipe_validity_out(i).attribute20            ,
	        x_recipe_validity_out(i).attribute21            , x_recipe_validity_out(i).attribute22            ,
	        x_recipe_validity_out(i).attribute23            , x_recipe_validity_out(i).attribute24            ,
	        x_recipe_validity_out(i).attribute25            , x_recipe_validity_out(i).attribute26            ,
	        x_recipe_validity_out(i).attribute27            , x_recipe_validity_out(i).attribute28            ,
	        x_recipe_validity_out(i).attribute29            , x_recipe_validity_out(i).attribute30            ,
	        x_recipe_validity_out(i).created_by             , x_recipe_validity_out(i).creation_date          ,
	        x_recipe_validity_out(i).last_updated_by        , x_recipe_validity_out(i).last_update_date       ,
        	x_recipe_validity_out(i).last_update_login      , x_recipe_validity_out(i).validity_rule_status   ,
	        x_recipe_validity_out(i).planned_process_loss   , x_recipe_validity_out(i).organization_id        ,
	        x_recipe_validity_out(i).inventory_item_id      , x_recipe_validity_out(i).revision               ,
	        x_recipe_validity_out(i).detail_uom             , x_recipe_validity_out(i).unit_cost		            ,
	        x_recipe_validity_out(i).total_cost		         , 0);
           END LOOP;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
                X_return_code   := SQLCODE;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
        END;
        /* Bug No.6788488 - End */

       ELSIF p_object_type = 'G' then
         -- BEGIN BUG#2436355 RajaSekhar
         -- Added call to newly created procedure which gets all validity rules for the
         -- recipe_id/item_id
         GMD_VALIDITY_RULES.get_all_validity_rules(p_api_version,p_init_msg_list, p_recipe_id,p_item_id,p_revision,p_least_cost_validity,
                                                   x_return_status,x_msg_count, x_msg_data, x_return_code,
                                                   X_recipe_validity_out);
         -- Code which calls get_validity_rules multiple times with different statuses is removed.
         -- END BUG#2436355

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


END GMD_VAL_DATA_PUB ;

/
