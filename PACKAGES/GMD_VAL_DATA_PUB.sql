--------------------------------------------------------
--  DDL for Package GMD_VAL_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_VAL_DATA_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPVRDS.pls 120.1 2005/07/25 10:07:27 srsriran noship $ */




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
                             X_recipe_validity_out OUT NOCOPY GMD_VALIDITY_RULES.recipe_validity_tbl);

END GMD_VAL_DATA_PUB;

 

/
