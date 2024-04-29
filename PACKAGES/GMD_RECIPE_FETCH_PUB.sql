--------------------------------------------------------
--  DDL for Package GMD_RECIPE_FETCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_FETCH_PUB" AUTHID CURRENT_USER AS
/* $Header: GMDPRCFS.pls 120.4.12010000.2 2009/03/23 17:13:30 rnalla ship $ */
/*#
 * This interface is used to fetch information related to recipes like
 * recipe id, formula id, routing id, routing step details, step dependencies,
 * operation activity and resource details, process parameters etc.
 * This package defines and implements the procedures and datatypes
 * required to fetch the above mentioned information.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Recipe Fetch package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_RECIPE
 */



TYPE recipe_validity_tbl IS TABLE OF gmd_recipe_validity_rules%rowtype
        INDEX BY BINARY_INTEGER;

TYPE recipe_rout_matl_tbl IS TABLE OF gmd_recipe_step_materials%rowtype
        INDEX BY BINARY_INTEGER;

TYPE recipe_form_matl_tbl IS TABLE OF fm_matl_dtl%rowtype
        INDEX BY BINARY_INTEGER;

TYPE routing_depd_tbl IS TABLE OF fm_rout_dep%rowtype
        INDEX BY BINARY_INTEGER;

TYPE recipe_rout_tbl IS TABLE OF fm_rout_hdr%rowtype
        INDEX BY BINARY_INTEGER;


TYPE recipe_step_out IS RECORD

(recipe_id		gmd_recipes.recipe_id%type      	,
rowid 		        varchar2(18)				,
routingstep_no     	fm_rout_dtl.routingstep_no%type		,
routingstep_id     	fm_rout_dtl.routingstep_id%type		,
step_qty 		fm_rout_dtl.step_qty%type		,
steprelease_type 	fm_rout_dtl.steprelease_type%type	,
minimum_transfer_qty    fm_rout_dtl.minimum_transfer_qty%type,
oprn_id            	gmd_operations_vl.oprn_id%type		,
oprn_no            	gmd_operations_vl.oprn_no%type		,
oprn_desc           	gmd_operations_vl.oprn_desc%type	,
oprn_vers           	gmd_operations_vl.oprn_vers%type	,
process_qty_uom 	gmd_operations_vl.process_qty_uom%type	,
max_capacity            cr_rsrc_mst.max_capacity%type  		,
capacity_uom		cr_rsrc_dtl.capacity_um%type 		,
/* Bug 1683702 Thomas Daniel */
/* Added the charges column to the table to be able to pass back */
/* the charges also in the recipe step detail fetch */
charge			integer					,
text_code		fm_rout_dtl.text_code%type		,
creation_date		fm_rout_dtl.creation_date%type		,
created_by		fm_rout_dtl.created_by%type		,
last_updated_by		fm_rout_dtl.last_updated_by%type	,
last_update_date	fm_rout_dtl.last_update_date%type	,
last_update_login	fm_rout_dtl.last_update_login%type	,
attribute_category	fm_rout_dtl.attribute_category%type	,
attribute1		fm_rout_dtl.attribute1%type		,
attribute2  		fm_rout_dtl.attribute2%type		,
attribute3		fm_rout_dtl.attribute3%type		,
attribute4		fm_rout_dtl.attribute4%type		,
attribute5		fm_rout_dtl.attribute5%type		,
attribute6		fm_rout_dtl.attribute6%type		,
attribute7		fm_rout_dtl.attribute7%type		,
attribute8		fm_rout_dtl.attribute8%type		,
attribute9		fm_rout_dtl.attribute9%type		,
attribute10		fm_rout_dtl.attribute10%type		,
attribute11		fm_rout_dtl.attribute11%type		,
attribute12		fm_rout_dtl.attribute12%type		,
attribute13		fm_rout_dtl.attribute13%type		,
attribute14		fm_rout_dtl.attribute14%type		,
attribute15		fm_rout_dtl.attribute15%type		,
attribute16		fm_rout_dtl.attribute16%type		,
attribute17		fm_rout_dtl.attribute17%type		,
attribute18		fm_rout_dtl.attribute18%type		,
attribute19		fm_rout_dtl.attribute19%type		,
attribute20		fm_rout_dtl.attribute20%type		,
attribute21		fm_rout_dtl.attribute21%type		,
attribute22		fm_rout_dtl.attribute22%type		,
attribute23		fm_rout_dtl.attribute23%type		,
attribute24		fm_rout_dtl.attribute24%type		,
attribute25		fm_rout_dtl.attribute25%type		,
attribute26		fm_rout_dtl.attribute26%type		,
attribute27		fm_rout_dtl.attribute27%type		,
attribute28		fm_rout_dtl.attribute28%type		,
attribute29		fm_rout_dtl.attribute29%type		,
attribute30		fm_rout_dtl.attribute30%type            ,
/* Bug 3612365 Thomas Daniel */
/* Added the Resources column to the table to be able to pass back */
/* the resource causing the charge to recipe step detail fetch */
resources		gmd_operation_resources.resources%type
);
TYPE recipe_step_tbl IS TABLE OF recipe_step_out
	INDEX BY BINARY_INTEGER;

/* Bug 2560037 S.Dulyk 20-SEP-2002 Added minimum_transfer_qty */
TYPE routing_step_out IS RECORD

(
routing_id 		fm_rout_dtl.routing_id%type		,
routingstep_no     	fm_rout_dtl.routingstep_no%type		,
routingstep_id     	fm_rout_dtl.routingstep_id%type		,
step_qty 		fm_rout_dtl.step_qty%type		,
steprelease_type 	fm_rout_dtl.steprelease_type%type	,
oprn_id			fm_rout_dtl.oprn_id%type		,
oprn_no            	gmd_operations_vl.oprn_no%type		,
oprn_desc           	gmd_operations_vl.oprn_desc%type	,
oprn_vers           	gmd_operations_vl.oprn_vers%type	,
process_qty_uom        	gmd_operations_vl.process_qty_uom%type	,
minimum_transfer_qty    fm_rout_dtl.minimum_transfer_qty%type   ,
max_capacity            cr_rsrc_mst.max_capacity%type  		,
capacity_uom		cr_rsrc_dtl.capacity_um%type 		,
text_code		fm_rout_dtl.text_code%type		,
creation_date		fm_rout_dtl.creation_date%type		,
created_by		fm_rout_dtl.created_by%type		,
last_updated_by		fm_rout_dtl.last_updated_by%type	,
last_update_date	fm_rout_dtl.last_update_date%type	,
last_update_login	fm_rout_dtl.last_update_login%type	,
attribute_category	fm_rout_dtl.attribute_category%type	,
attribute1		fm_rout_dtl.attribute1%type		,
attribute2  		fm_rout_dtl.attribute2%type		,
attribute3		fm_rout_dtl.attribute3%type		,
attribute4		fm_rout_dtl.attribute4%type		,
attribute5		fm_rout_dtl.attribute5%type		,
attribute6		fm_rout_dtl.attribute6%type		,
attribute7		fm_rout_dtl.attribute7%type		,
attribute8		fm_rout_dtl.attribute8%type		,
attribute9		fm_rout_dtl.attribute9%type		,
attribute10		fm_rout_dtl.attribute10%type		,
attribute11		fm_rout_dtl.attribute11%type		,
attribute12		fm_rout_dtl.attribute12%type		,
attribute13		fm_rout_dtl.attribute13%type		,
attribute14		fm_rout_dtl.attribute14%type		,
attribute15		fm_rout_dtl.attribute15%type		,
attribute16		fm_rout_dtl.attribute16%type		,
attribute17		fm_rout_dtl.attribute17%type		,
attribute18		fm_rout_dtl.attribute18%type		,
attribute19		fm_rout_dtl.attribute19%type		,
attribute20		fm_rout_dtl.attribute20%type		,
attribute21		fm_rout_dtl.attribute21%type		,
attribute22		fm_rout_dtl.attribute22%type		,
attribute23		fm_rout_dtl.attribute23%type		,
attribute24		fm_rout_dtl.attribute24%type		,
attribute25		fm_rout_dtl.attribute25%type		,
attribute26		fm_rout_dtl.attribute26%type		,
attribute27		fm_rout_dtl.attribute27%type		,
attribute28		fm_rout_dtl.attribute28%type		,
attribute29		fm_rout_dtl.attribute29%type		,
attribute30		fm_rout_dtl.attribute30%type
);

TYPE routing_step_tbl IS TABLE OF routing_step_out
	INDEX BY BINARY_INTEGER;

 TYPE oprn_act_out IS RECORD
 ( recipe_id               gmd_recipes.recipe_id%type				,
  routingstep_id           fm_rout_dtl.routingstep_id%type			,
  routingstep_no           fm_rout_dtl.routingstep_no%type			,
  oprn_no                  gmd_operations_vl.oprn_no%type			,
  oprn_vers                gmd_operations_vl.oprn_vers%type			,
  oprn_desc                gmd_operations_vl.oprn_desc%type			,
  oprn_id                  gmd_operations_vl.oprn_id%type                       ,
  minimum_transfer_qty     gmd_operations_b.minimum_transfer_qty%type           ,
  oprn_line_id             gmd_operation_resources.oprn_line_id%type		,
  activity                 gmd_operation_activities.activity%type		,
   activity_desc           fm_actv_mst.activity_desc%type			,
  activity_factor	   gmd_operation_activities.activity_factor%type	,
  sequence_dependent_ind  gmd_operation_activities.sequence_dependent_ind%type	,
  recipe_override	   NUMBER(5)						,
  offset_interval	   gmd_operation_activities.offset_interval%type 	,
  break_ind                gmd_operation_activities.break_ind%type,
  max_break                gmd_operation_activities.max_break%type DEFAULT NULL,
  material_ind             gmd_operation_activities.material_ind%type,
  text_code                 gmd_operation_resources.text_code%type		,
  created_by                gmd_operation_resources.created_by%type		,
  last_updated_by           gmd_operation_resources.last_updated_by%type	,
  last_update_date          gmd_operation_resources.last_update_date%type	,
  creation_date             gmd_operation_resources.creation_date%type		,
  last_update_login         gmd_operation_resources.last_update_login%type	,
  attribute_category        gmd_operation_resources.attribute_category%type	,
  attribute1		   gmd_operation_resources.attribute1%type		,
  attribute2  		   gmd_operation_resources.attribute2%type		,
  attribute3		   gmd_operation_resources.attribute3%type		,
 attribute4		   gmd_operation_resources.attribute4%type		,
 attribute5		   gmd_operation_resources.attribute5%type		,
 attribute6		   gmd_operation_resources.attribute6%type		,
attribute7		   gmd_operation_resources.attribute7%type		,
attribute8		   gmd_operation_resources.attribute8%type		,
attribute9		   gmd_operation_resources.attribute9%type		,
attribute10		   gmd_operation_resources.attribute10%type		,
attribute11		   gmd_operation_resources.attribute11%type		,
attribute12		   gmd_operation_resources.attribute12%type		,
attribute13		   gmd_operation_resources.attribute13%type		,
attribute14		   gmd_operation_resources.attribute14%type		,
attribute15		   gmd_operation_resources.attribute15%type		,
attribute16		  gmd_operation_resources.attribute16%type		,
attribute17		gmd_operation_resources.attribute17%type		,
attribute18		gmd_operation_resources.attribute18%type		,
attribute19		gmd_operation_resources.attribute19%type		,
attribute20		gmd_operation_resources.attribute20%type		,
attribute21		gmd_operation_resources.attribute21%type		,
attribute22		gmd_operation_resources.attribute22%type		,
attribute23		gmd_operation_resources.attribute23%type		,
attribute24		gmd_operation_resources.attribute24%type		,
attribute25		gmd_operation_resources.attribute25%type		,
attribute26		gmd_operation_resources.attribute26%type		,
attribute27		gmd_operation_resources.attribute27%type		,
attribute28		gmd_operation_resources.attribute28%type		,
attribute29		gmd_operation_resources.attribute29%type		,
attribute30		gmd_operation_resources.attribute30%type

  );

  TYPE oprn_act_tbl IS TABLE OF oprn_act_out
	INDEX BY BINARY_INTEGER;





  /* BUG#2621411 RajaSekhar  Added capacity_tolerance field */

 TYPE oprn_resc_rec IS RECORD
 (
  recipe_id                gmd_recipes.recipe_id%type				,
  routingstep_id           fm_rout_dtl.routingstep_id%type			,
  routingstep_no           fm_rout_dtl.routingstep_no%type			,
  oprn_id                  gmd_operations_vl.oprn_id%type  			,
  oprn_no                  gmd_operations_vl.oprn_no%type				,
  oprn_vers                gmd_operations_vl.oprn_vers%type			,
  oprn_desc                gmd_operations_vl.oprn_desc%type			,
  activity                 gmd_operation_activities.activity%type		,
  oprn_line_id             gmd_operation_resources.oprn_line_id%type		,
  resources                gmd_operation_resources.resources%type		,
  resource_usage           gmd_operation_resources.resource_usage%type		,
  resource_count           gmd_operation_resources.resource_count%type		,
  process_qty              gmd_operation_resources.process_qty%type		,
  process_uom              gmd_operation_resources.resource_process_uom%type		,
  prim_rsrc_ind            gmd_operation_resources.prim_rsrc_ind%type		,
  scale_type               gmd_operation_resources.scale_type%type		,
  cost_analysis_code       gmd_operation_resources.cost_analysis_code%type	,
  cost_cmpntcls_id         gmd_operation_resources.cost_cmpntcls_id%type	,
  usage_um                 gmd_operation_resources.resource_usage_uom%type		,
  offset_interval 	   gmd_operation_resources.offset_interval%type		,
  max_capacity             cr_rsrc_mst.max_capacity%type			,
  min_capacity             cr_rsrc_mst.min_capacity%type			,
  capacity_constraint      cr_rsrc_mst.capacity_constraint%type			,
  capacity_tolerance       cr_rsrc_dtl.capacity_tolerance%type			,
  capacity_uom             cr_rsrc_dtl.capacity_um%type,

  process_parameter_1       gmd_operation_resources.process_parameter_1%type	,
  process_parameter_2       gmd_operation_resources.process_parameter_2%type	,
  process_parameter_3       gmd_operation_resources.process_parameter_3%type	,
  process_parameter_4       gmd_operation_resources.process_parameter_4%type	,
  process_parameter_5       gmd_operation_resources.PROCESS_PARAMETER_5%type	,

  recipe_override	    NUMBER(5)	,
  text_code                 gmd_operation_resources.text_code%type		,
  created_by                gmd_operation_resources.created_by%type		,
  last_updated_by           gmd_operation_resources.last_updated_by%type	,
  last_update_date          gmd_operation_resources.last_update_date%type	,
  creation_date             gmd_operation_resources.creation_date%type		,
  last_update_login         gmd_operation_resources.last_update_login%type	,
  attribute_category        gmd_operation_resources.attribute_category%type	,
  attribute1		   gmd_operation_resources.attribute1%type		,
  attribute2  		   gmd_operation_resources.attribute2%type		,
  attribute3		   gmd_operation_resources.attribute3%type		,
 attribute4		   gmd_operation_resources.attribute4%type		,
 attribute5		   gmd_operation_resources.attribute5%type		,
 attribute6		   gmd_operation_resources.attribute6%type		,
attribute7		   gmd_operation_resources.attribute7%type		,
attribute8		   gmd_operation_resources.attribute8%type		,
attribute9		   gmd_operation_resources.attribute9%type		,
attribute10		   gmd_operation_resources.attribute10%type		,
attribute11		   gmd_operation_resources.attribute11%type		,
attribute12		   gmd_operation_resources.attribute12%type		,
attribute13		   gmd_operation_resources.attribute13%type		,
attribute14		   gmd_operation_resources.attribute14%type		,
attribute15		   gmd_operation_resources.attribute15%type		,
attribute16		  gmd_operation_resources.attribute16%type		,
attribute17		gmd_operation_resources.attribute17%type		,
attribute18		gmd_operation_resources.attribute18%type		,
attribute19		gmd_operation_resources.attribute19%type		,
attribute20		gmd_operation_resources.attribute20%type		,
attribute21		gmd_operation_resources.attribute21%type		,
attribute22		gmd_operation_resources.attribute22%type		,
attribute23		gmd_operation_resources.attribute23%type		,
attribute24		gmd_operation_resources.attribute24%type		,
attribute25		gmd_operation_resources.attribute25%type		,
attribute26		gmd_operation_resources.attribute26%type		,
attribute27		gmd_operation_resources.attribute27%type		,
attribute28		gmd_operation_resources.attribute28%type		,
attribute29		gmd_operation_resources.attribute29%type		,
attribute30		gmd_operation_resources.attribute30%type

  );
  TYPE oprn_resc_tbl IS TABLE OF oprn_resc_rec
	INDEX BY BINARY_INTEGER;


 TYPE recp_resc_proc_param_rec IS RECORD
 (
  recipe_id                gmd_recipes.recipe_id%type				,
  routingstep_id           fm_rout_dtl.routingstep_id%type			,
  routingstep_no           fm_rout_dtl.routingstep_no%type			,
  oprn_line_id             gmd_operation_resources.oprn_line_id%type		,
  resources                gmd_operation_resources.resources%type		,
  parameter_id		   gmp_process_parameters.parameter_id%type		,
  parameter_name	   gmp_process_parameters.parameter_name%type		,
  parameter_description    gmp_process_parameters.parameter_description%type	,
  units                    gmp_process_parameters.units%type			,
  target_value		   gmd_recipe_process_parameters.target_value%type	,
  minimum_value		   NUMBER						,
  maximum_value            NUMBER						,
  parameter_type	   gmp_process_parameters.parameter_type%type		,
  sequence_no		   gmp_resource_parameters.sequence_no%type		,
  created_by               gmd_recipe_process_parameters.created_by%type	,
  last_updated_by          gmd_recipe_process_parameters.last_updated_by%type	,
  last_update_date         gmd_recipe_process_parameters.last_update_date%type	,
  creation_date            gmd_recipe_process_parameters.creation_date%type	,
  last_update_login        gmd_recipe_process_parameters.last_update_login%type	,
  recipe_override	   NUMBER(5)
  );

 TYPE recp_resc_proc_param_tbl IS TABLE OF recp_resc_proc_param_rec
 INDEX BY BINARY_INTEGER;


-- Start of commments
-- API name     : get_validity_rules
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Number
--                      p_item_no      IN Varchar2
--                      p_orgn_code   IN Varchar2
--                      p_recipe_qty  IN Number
--                      P_recipe_id   IN Number
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_return_code           OUT NOCOPY      NUMBER
--                      x_recipe_validity_tbl        OUT NOCOPY recipe_validity_tbl
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*
 PROCEDURE get_validity_rules
(       p_api_version              	IN      NUMBER                          ,
        p_init_msg_list            	IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id             	IN      NUMBER                          ,
        p_item_id                	IN      NUMBER             		,
        p_orgn_code             	IN      Varchar2          		,
        p_product_qty            	IN      NUMBER                          ,
        p_recipe_use                    IN      VARCHAR2			,
        x_return_status         	OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             	OUT NOCOPY     NUMBER                          ,
        x_msg_data              	OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        X_recipe_validity_tbl         	OUT NOCOPY     recipe_validity_tbl
);  */


-- Start of commments
-- API name     : get_recipe_id
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_validity_rule_id    IN  NUMBER
--                      p_delete_mark  IN NUMBER  Required
--
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_recipe_id        OUT NOCOPY NUMBER
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

/*#
 * Fetches the recipe id
 * This is a PL/SQL procedure to fetch recipe_id from  gmd_recipe_validity_rules
 * based on the validity_rule_id passed
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_validity_rule_id Vailidity Rule ID
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_recipe_id Recipe ID for the corresponding Validity Rule ID passed
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Recipe ID procedure
 * @rep:compatibility S
 */
PROCEDURE get_recipe_id
(       p_api_version                   IN              NUMBER                          ,
        p_init_msg_list                 IN              VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_validity_rule_id       IN              NUMBER                          ,
        x_return_status                 OUT NOCOPY      VARCHAR2                        ,
        x_msg_count                     OUT NOCOPY      NUMBER                          ,
        x_msg_data                      OUT NOCOPY      VARCHAR2                        ,
        x_return_code                   OUT NOCOPY      NUMBER                          ,
        x_recipe_id                     OUT NOCOPY      NUMBER
);


-- Start of commments
-- API name     : get_routing_id
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Varchar2
--                      p_recipe_id        IN      NUMBER
--                      p_delete_mark  IN NUMBER  Required
--
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_routing_id            OUT NOCOPY NUMBER
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

/*#
 * Fetches the routing id
 * This is a PL/SQL procedure to return the routing_id attached to the recipe_id
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_no Recipe Number field
 * @param p_recipe_version Version of the Recipe
 * @param p_recipe_id ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_routing_id Routing ID corresponding to the Recipe ID passed
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Routing ID procedure
 * @rep:compatibility S
 */
PROCEDURE get_routing_id
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_no             IN      Varchar2 ,
        p_recipe_version        IN       NUMBER ,
        p_recipe_id             IN      NUMBER                          ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_id                 OUT NOCOPY     NUMBER
);
-- Start of commments
-- API name     : get_rout_hdr
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_id        IN      NUMBER
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_return_code      OUT NOCOPY number
--                      x_rout_out          OUT NOCOPY NUMBER
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

/*#
 * Fetches the routing header information
 * This is a PL/SQL procedure to fetch the total routing header
 * information  based on the recipe_id passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_rout_out Table structure of Recipe header to return header information
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Routing Header procedure
 * @rep:compatibility S
 */
PROCEDURE get_rout_hdr
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id             IN       NUMBER                         ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_rout_out	        OUT NOCOPY     recipe_rout_tbl
);

-- Start of commments
-- API name     : get_formula_id
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Varchar2
--                       p_recipe_id             	IN      NUMBER
--                      p_delete_mark  IN NUMBER  Required
--
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_formula_id           OUT NOCOPY NUMBER
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments
/* Bug 2411810 - Thomas Daniel */
/* Added the default values which was present in the body to the spec */

/*#
 * Fetches the formula id
 * This is a PL/SQL procedure to return the formula_id based on the
 * recipe_id passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_no Recipe Number field
 * @param p_recipe_version Version of the Recipe
 * @param p_recipe_id ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_formula_id Formula ID corresponding the Recipe ID passed
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Formula ID procedure
 * @rep:compatibility S
 */
PROCEDURE get_formula_id
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_no             IN      Varchar2 := NULL                ,
        p_recipe_version        IN       NUMBER  := NULL                ,
        p_recipe_id             IN      NUMBER                          ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_formula_id            OUT NOCOPY     NUMBER
);

-- Start of commments
-- API name     : get_rout_material
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN  NUMBER
--                      p_recipe_id      IN number
--
--
--
--                   x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_recipe_rout_matl_tbl       OUT NOCOPY recipe_rout_matl_tbl
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the material - step information
 * This is a PL/SQL procedure to return the material - step information
 * based on the Recipe ID passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_recipe_rout_matl_tbl Table structure of routing material table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Routing material-step procedure
 * @rep:compatibility S
 */
PROCEDURE get_rout_material
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id             IN      NUMBER                          ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_recipe_rout_matl_tbl OUT NOCOPY     recipe_rout_matl_tbl
);


-- Start of commments
-- API name     : get_process_loss
-- Type         : Private
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN  NUMBER
--                      p_recipe_id  IN NUMBER
--                      p_orgn_code  IN Varchar2   Optional
--
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_process_loss     OUT NOCOPY NUMBER
-- Version :  Current Version 1.0
--
-- Notes  :
--
-- End of comments

/* Bug 2411810 - Thomas Daniel */
/* Added the default values which was present in the body to the spec */

/*#
 * Fetches the Process Loss for a Recipe
 * This is a PL/SQL procedure to return the process loss for a
 * particular recipe if a routing is attached to a given recipe
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_no Recipe Number field
 * @param p_recipe_version Version of the Recipe
 * @param p_recipe_id ID of the Recipe
 * @param p_organization_id Organiation ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_process_loss Process Loss for the Recipe
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Process Loss procedure
 * @rep:compatibility S
 */
PROCEDURE get_process_loss
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_no             IN      VARCHAR2 := NULL                ,
        p_recipe_version        IN      NUMBER  := NULL                 ,
        p_recipe_id             IN      NUMBER                          ,
        p_organization_id       IN              NUMBER                  ,
        x_return_status         OUT NOCOPY      VARCHAR2                ,
        x_msg_count             OUT NOCOPY      NUMBER                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                ,
        x_return_code           OUT NOCOPY      NUMBER                  ,
        x_process_loss          OUT NOCOPY      NUMBER
);


-- Start of commments
-- API name     : get_routing_step_details
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Varchar2
--                      p_recipe_id      IN Number
--
--
--                   x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      X_recipe_rout_step_tbl       OUT NOCOPY recipe_rout_step_out
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Routing Step information
 * This is a PL/SQL procedure to return the routing step information based on the routing_id
 * passed to it. This information is for populating the data before the recipe_id is created
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_routing_id ID of the Routing
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_routing_step_out Table structure of Routing Step table to return Routing Step details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Routing Step details procedure
 * @rep:compatibility S
 */
PROCEDURE get_routing_step_details
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_routing_id            IN       NUMBER                         ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_step_out             OUT NOCOPY     routing_step_tbl
);
-- Start of commments
-- API name     : get_recipe_step_details
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Varchar2
--                      p_recipe_id      IN Number
--
--
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      X_recipe_rout_step_tbl       OUT NOCOPY recipe_rout_step_out
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Recipe Step details
 * This is a PL/SQL procedure to return the recipe step details  based on the recipe_id
 * passed to it. This information is for populating the data after the recipe_id is created
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id ID of the Recipe
 * @param P_organization_id Orgnanization ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_recipe_step_out Table structure of Recipe Step table to return Recipe Step details
 * @param p_val_scale_factor Scaling factor
 * @param p_process_loss Process loss
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Recipe Step details procedure
 * @rep:compatibility S
 */
PROCEDURE get_recipe_step_details
(       p_api_version           IN              NUMBER                       ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE  ,
        p_recipe_id             IN              NUMBER                       ,
        p_organization_id       IN              NUMBER  DEFAULT NULL         ,
        x_return_status         OUT NOCOPY      VARCHAR2                     ,
        x_msg_count             OUT NOCOPY      NUMBER                       ,
        x_msg_data              OUT NOCOPY      VARCHAR2                     ,
        x_return_code           OUT NOCOPY      NUMBER                       ,
        x_recipe_step_out       OUT NOCOPY      recipe_step_tbl              ,
        p_val_scale_factor	IN	        NUMBER	DEFAULT 1	     ,
        p_process_loss		IN	        NUMBER	DEFAULT 0,
	p_routing_id            IN      	NUMBER  DEFAULT NULL
);

-- Start of commments
-- API name     : get_step_depd_details
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN Varchar2
--                      p_recipe_id      IN Number
--
--                   x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                    x_routing_depd_out      OUT NOCOPY routing_depd_tbl
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Recipe Step Dependency details
 * This is a PL/SQL procedure to return the step dependency information based on the
 * recipe_id passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id  ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_routing_depd_tbl Table structure to return Recipe Step dependency details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Recipe Step Dependency details procedure
 * @rep:compatibility S
 */
PROCEDURE get_step_depd_details
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id            IN       NUMBER                         ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_depd_tbl            OUT NOCOPY     routing_depd_tbl
);



-- Start of commments
-- API name     : get_oprn_act_detl
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                     p_recipe_id        IN Number
--                     p_organization_id  IN Number
--                     x_return_status    OUT NOCOPY varchar2(1)
--                     x_msg_count        OUT NOCOPY Number
--                     x_msg_data         OUT NOCOPY varchar2(2000)
--                     X_oprn_act_tbl     OUT NOCOPY oprn_act_out
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Operation activity details
 * This is a PL/SQL procedure to return the step, operation and activities details
 * for a given recipe based on the recipe_id passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id  ID of the Recipe
 * @param P_organization_id Orgnanization ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param x_oprn_act_out Table structure to return Operation activities details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Operation activity details procedure
 * @rep:compatibility S
 */
PROCEDURE get_oprn_act_detl
(       p_api_version           IN              NUMBER                          ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id             IN              NUMBER                          ,
        p_organization_id       IN              NUMBER  DEFAULT NULL 		,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                          ,
        x_oprn_act_out          OUT NOCOPY      oprn_act_tbl
);


-- Start of commments
-- API name     : get_oprn_resc_detl
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version IN NUMBER   Required
--                      p_init_msg_list IN Varchar2 Optional
--
--                      p_recipe_no   IN Varchar2
--                      p_recipe_version   IN  NUMBER
--                      p_recipe_id      IN Number
--                      x_return_status    OUT NOCOPY varchar2(1)
--                      x_msg_count        OUT NOCOPY Number
--                      x_msg_data         OUT NOCOPY varchar2(2000)
--                      x_oprn_resc_tbl   OUT NOCOPY oprn_resc_out
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Operation resource details
 * This is a PL/SQL procedure to return the step, operation and activities,
 * resources details for a given recipe based on the recipe_id passed to it
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id  ID of the Recipe
 * @param P_organization_id Orgnanization ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param x_return_code SQLCODE returned
 * @param X_oprn_resc_rec Table structure to return Operation resource details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Operation resource details procedure
 * @rep:compatibility S
 */
PROCEDURE get_oprn_resc_detl
(       p_api_version           IN              NUMBER                          ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id             IN              NUMBER                          ,
        p_organization_id       IN              NUMBER  DEFAULT NULL            ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                          ,
        X_oprn_resc_rec         OUT NOCOPY      oprn_resc_tbl
);


-- Start of commments
-- API name     : get_recipe_process_param_detl
-- Type         : Public
-- Function     :
-- Paramaters   :
-- IN           :       p_api_version 			IN NUMBER   Required
--                      p_init_msg_list 		IN Varchar2 Optional
--
--                      p_recipe_id      		IN Number
--			p_orgn_code	 		IN VARCHAR2
--                      x_return_status  		OUT NOCOPY varchar2(1)
--                      x_msg_count      		OUT NOCOPY Number
--                      x_msg_data       		OUT NOCOPY varchar2(2000)
--                      x_recp_resc_proc_param_tbl  	OUT NOCOPY recp_resc_proc_param_tbl
-- Version :  Current Version 1.0
--
-- Notes  :
-- End of comments

/*#
 * Fetches the Recipe Process Parameters details
 * This is a PL/SQL procedure to the process parameters for a recipe
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_recipe_id  ID of the Recipe
 * @param P_organization_id Orgnanization ID of the Recipe
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param X_recp_resc_proc_param_tbl Table structure to return Process parameter details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Process parameters procedure
 * @rep:compatibility S
 */
PROCEDURE get_recipe_process_param_detl
(       p_api_version              IN           NUMBER                          ,
        p_init_msg_list            IN           VARCHAR2 := FND_API.G_FALSE     ,
        p_recipe_id                IN           NUMBER                          ,
        p_organization_id          IN           NUMBER  DEFAULT NULL            ,
        x_return_status            OUT NOCOPY   VARCHAR2                        ,
        x_msg_count                OUT NOCOPY   NUMBER                          ,
        x_msg_data                 OUT NOCOPY   VARCHAR2                        ,
        X_recp_resc_proc_param_tbl OUT NOCOPY   recp_resc_proc_param_tbl
);

/*#
 * Fetches the Process Parameter description
 * This is a PL/SQL procedure is responsible for getting the
 * description for a given process parameter.
 * @param p_parameter_id ID of the process parameter
 * @param x_parameter_desc Description of the process parameter is returned
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Process parameter Description procedure
 * @rep:compatibility S
 */
PROCEDURE get_proc_param_desc(p_parameter_id IN NUMBER, x_parameter_desc OUT NOCOPY VARCHAR2);

/*#
 * Fetches the Process Parameter Units
 * This PL/SQL procedure  is responsible for getting the
 * units for a given process parameter
 * @param p_parameter_id ID of the process parameter
 * @param x_units Units for the process parameter is returned
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Process parameter Units procedure
 * @rep:compatibility S
 */
PROCEDURE get_proc_param_units(p_parameter_id IN NUMBER, x_units OUT NOCOPY VARCHAR2);

/*#
 * Fetches the Contiguous Indicator Value
 * This PL/SQL procedure  is responsible for getting the contiguous indicator
 * value set at Recipe - Orgn level or at the Recipe level in order
 * for the given input parameters
 * @param p_recipe_id Recipe ID for which cont ind setting is requested
 * @param p_orgn_id Organization ID for which cont ind setting is requested
 * @param p_recipe_validity_rule_id Validity Rule ID for which cont ind setting is requested
 * @param x_contiguous_ind Contiguous Ind value out parameter
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Contiguous Indicator Value procedure
 * @rep:compatibility S
 */
 PROCEDURE fetch_contiguous_ind(  p_recipe_id                   IN              NUMBER
                                , p_orgn_id                     IN              NUMBER
                                , p_recipe_validity_rule_id     IN              NUMBER
                                , x_contiguous_ind              OUT NOCOPY      NUMBER
                                , x_return_status               OUT NOCOPY      VARCHAR2);

/*#
 * Fetches the Enhanced PI Indicator value at recipe header level
 * This PL/SQL procedure  is responsible for getting the PI indicator
 * value set at Recipe header level
 * @param p_recipe_id Recipe ID for which Enhanced PI ind value is requested
 * @param p_recipe_validity_rule_id Validity Rule ID
 * @param x_enhanced_pi_ind Enhanced PI Ind value out parameter
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Enhanced PI Indicator Value procedure
 * @rep:compatibility S
 */
PROCEDURE FETCH_ENHANCED_PI_IND (
			 p_recipe_id                    IN            	NUMBER
			,p_recipe_validity_rule_id      IN             	NUMBER
			,x_enhanced_pi_ind              OUT NOCOPY      VARCHAR2
			,x_return_status                OUT NOCOPY	VARCHAR2);

END GMD_RECIPE_FETCH_PUB;

/
