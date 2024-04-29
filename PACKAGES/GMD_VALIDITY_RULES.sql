--------------------------------------------------------
--  DDL for Package GMD_VALIDITY_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_VALIDITY_RULES" AUTHID CURRENT_USER AS
/* $Header: GMDPRVRS.pls 120.3.12000000.1 2007/01/16 18:21:33 appldev ship $ */


TYPE gmd_val_rules_out IS RECORD
 (  recipe_validity_rule_id     gmd_recipe_validity_rules.recipe_validity_rule_id%type	,
    recipe_id     		gmd_recipe_validity_rules.recipe_id%type		,
    orgn_code      		gmd_recipe_validity_rules.orgn_code%type		,
    -- NPD Conv. Added organization_id, revision. Modified item_id to inventory_item_id.
    organization_id             gmd_recipe_validity_rules.organization_id%type          ,
    revision                    gmd_recipe_validity_rules.revision%type                 ,
    inventory_item_id        	gmd_recipe_validity_rules.inventory_item_id%type	,
    -- End NPD Conv.
    recipe_use    		gmd_recipe_validity_rules.recipe_use%type		,
    preference    		gmd_recipe_validity_rules.preference%type		,
    start_date     		gmd_recipe_validity_rules.start_date%type		,
    end_date       		gmd_recipe_validity_rules.end_date%type			,
    min_qty       		gmd_recipe_validity_rules.min_qty%type  		,
    max_qty        		gmd_recipe_validity_rules.max_qty%type			,
    std_qty        		gmd_recipe_validity_rules.std_qty%type			,
    -- NPD Conv. Changed item_um to detail_uom
    detail_uom       		gmd_recipe_validity_rules.detail_uom%type		,
    -- End NPD Conv.
    inv_min_qty   		gmd_recipe_validity_rules.inv_min_qty%type		,
    inv_max_qty    		gmd_recipe_validity_rules.inv_max_qty%type		,
    planned_process_loss	gmd_recipe_validity_rules.planned_process_loss%type	,
    validity_rule_status  	gmd_recipe_validity_rules.validity_rule_status%type	,
    --lab_type                  gmd_recipe_validity_rules.lab_type%type          	           				,
    formula_id                  NUMBER							,
    routing_id                  NUMBER							,
    unit_cost			NUMBER							,
    total_cost			NUMBER							,
    text_code                 	gmd_recipe_validity_rules.text_code%type		,
    created_by               	gmd_recipe_validity_rules.created_by%type		,
    last_updated_by           	gmd_recipe_validity_rules.last_updated_by%type		,
    last_update_date          	gmd_recipe_validity_rules.last_update_date%type		,
    creation_date             	gmd_recipe_validity_rules.creation_date%type		,
    last_update_login         	gmd_recipe_validity_rules.last_update_login%type	,
    attribute_category        	gmd_recipe_validity_rules.attribute_category%type	,
    attribute1		   	gmd_recipe_validity_rules.attribute1%type		,
    attribute2  		gmd_recipe_validity_rules.attribute2%type		,
    attribute3		   	gmd_recipe_validity_rules.attribute3%type		,
    attribute4		  	gmd_recipe_validity_rules.attribute4%type		,
    attribute5		  	gmd_recipe_validity_rules.attribute5%type		,
    attribute6		   	gmd_recipe_validity_rules.attribute6%type		,
    attribute7		   	gmd_recipe_validity_rules.attribute7%type		,
    attribute8		   	gmd_recipe_validity_rules.attribute8%type		,
    attribute9		   	gmd_recipe_validity_rules.attribute9%type		,
    attribute10		   	gmd_recipe_validity_rules.attribute10%type		,
    attribute11		   	gmd_recipe_validity_rules.attribute11%type		,
    attribute12		   	gmd_recipe_validity_rules.attribute12%type		,
    attribute13		   	gmd_recipe_validity_rules.attribute13%type		,
    attribute14		   	gmd_recipe_validity_rules.attribute14%type		,
    attribute15		   	gmd_recipe_validity_rules.attribute15%type		,
    attribute16		  	gmd_recipe_validity_rules.attribute16%type		,
    attribute17			gmd_recipe_validity_rules.attribute17%type		,
    attribute18			gmd_recipe_validity_rules.attribute18%type		,
    attribute19			gmd_recipe_validity_rules.attribute19%type		,
    attribute20			gmd_recipe_validity_rules.attribute20%type		,
    attribute21			gmd_recipe_validity_rules.attribute21%type		,
    attribute22			gmd_recipe_validity_rules.attribute22%type		,
    attribute23			gmd_recipe_validity_rules.attribute23%type		,
    attribute24			gmd_recipe_validity_rules.attribute24%type		,
    attribute25			gmd_recipe_validity_rules.attribute25%type		,
    attribute26			gmd_recipe_validity_rules.attribute26%type		,
    attribute27			gmd_recipe_validity_rules.attribute27%type		,
    attribute28			gmd_recipe_validity_rules.attribute28%type		,
    attribute29			gmd_recipe_validity_rules.attribute29%type		,
    attribute30			gmd_recipe_validity_rules.attribute30%type

  );

-- Record for finding Least Cost VR
TYPE least_cost_rec IS RECORD
 (
  recipe_validity_rule_id     gmd_recipe_validity_rules.recipe_validity_rule_id%TYPE,
  unit_cost		      NUMBER,
  total_cost		      NUMBER,
  index_no		      NUMBER);

TYPE least_cost_tbl IS TABLE OF least_cost_rec
INDEX BY BINARY_INTEGER;

TYPE recipe_validity_tbl IS TABLE OF gmd_val_rules_out
        INDEX BY BINARY_INTEGER;

-- NPD Conv. Added p_organization_id parameter.
PROCEDURE get_validity_rules(p_api_version         IN  NUMBER				,
                             p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE	,
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
                             p_organization_id     IN  NUMBER   := NULL                	,
     			     p_least_cost_validity IN  VARCHAR2 := 'F'			,
                             p_start_date          IN  DATE 	:= NULL			,
                             p_end_date            IN  DATE	:= NULL			,
                             p_status_type         IN  VARCHAR2 := NULL			,
                             p_validity_rule_id    IN  NUMBER   := NULL                 ,
                             x_return_status       OUT NOCOPY VARCHAR2			,
                             x_msg_count           OUT NOCOPY NUMBER			,
                             x_msg_data            OUT NOCOPY VARCHAR2			,
                             x_return_code         OUT NOCOPY NUMBER			,
                             X_recipe_validity_out OUT NOCOPY recipe_validity_tbl);

PROCEDURE get_output_ratio(p_formula_id     IN  NUMBER,
                           p_batch_output   IN  NUMBER,
                           p_yield_um       IN  VARCHAR2,
                           p_formula_output IN NUMBER,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           X_output_ratio   OUT NOCOPY NUMBER);

PROCEDURE get_ingredprod_ratio(p_formula_id        IN  NUMBER,
                               p_yield_um          IN  VARCHAR2,
                               X_ingred_prod_ratio OUT NOCOPY NUMBER,
                               x_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE get_batchformula_ratio(p_formula_id         IN  NUMBER,
                                 p_batch_input        IN  NUMBER,
                                 p_yield_um           IN  VARCHAR2,
                                 p_formula_input      IN  NUMBER,
                                 X_batchformula_ratio OUT NOCOPY NUMBER,
                                 X_return_status      OUT NOCOPY VARCHAR2);

PROCEDURE get_contributing_qty(p_formula_id          IN  NUMBER,
                               p_recipe_id           IN  NUMBER,
                               p_batchformula_ratio  IN  NUMBER,
                               p_yield_um            IN  VARCHAR2,
                               X_contributing_qty    OUT NOCOPY NUMBER,
                               X_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE get_input_ratio(p_formula_id       IN  NUMBER,
                          p_contributing_qty IN  NUMBER,
                          p_yield_um         IN  VARCHAR2,
                          p_formula_output   IN  NUMBER,
                          X_output_ratio     OUT NOCOPY NUMBER,
                          X_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE uom_conversion_mesg(p_item_id IN NUMBER,
                              p_from_um IN VARCHAR2,
                              p_to_um   IN VARCHAR2);
--BEGIN BUG#2436355 RajaSekhar
PROCEDURE get_all_validity_rules(p_api_version         IN  NUMBER,
                                 p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                                 p_recipe_id           IN  NUMBER	:= NULL,
                                 p_item_id             IN  NUMBER       := NULL,
                                 p_revision            IN  VARCHAR2     := NULL,
				 p_least_cost_validity IN  VARCHAR2     := 'F',
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2,
                                 x_return_code         OUT NOCOPY NUMBER,
                                 X_recipe_validity_out OUT NOCOPY recipe_validity_tbl);
--END BUG#2436355

PROCEDURE get_validity_scale_factor(p_recipe_id           IN  NUMBER ,
                                    p_item_id             IN  NUMBER ,
                                    p_std_qty             IN  NUMBER ,
                                    p_std_um              IN  VARCHAR2 ,
                                    x_scale_factor	  OUT NOCOPY NUMBER,
                                    x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE get_validity_output_factor(p_recipe_id           IN  NUMBER ,
                                     p_item_id             IN  NUMBER ,
                                     p_std_qty             IN  NUMBER ,
                                     p_std_um              IN  VARCHAR2 ,
                                     x_scale_factor	   OUT NOCOPY NUMBER,
                                     x_return_status       OUT NOCOPY VARCHAR2);

PROCEDURE insert_val_temp_tbl (p_val_rec IN GMD_RECIPE_VALIDITY_RULES%ROWTYPE
                              ,p_unit_cost IN NUMBER
                              ,p_total_cost IN NUMBER);

PROCEDURE Get_Formula_Cost (
   p_formula_id            IN  NUMBER,
   p_requested_qty         IN  NUMBER,
   p_requested_uom         IN  VARCHAR2,
   p_product_id            IN  NUMBER,
   p_organization_id       IN  NUMBER,
   X_unit_cost             OUT NOCOPY  NUMBER,
   X_total_cost            OUT NOCOPY  NUMBER,
   X_return_status         OUT NOCOPY  VARCHAR2);

END GMD_VALIDITY_RULES;

 

/
