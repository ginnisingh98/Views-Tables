--------------------------------------------------------
--  DDL for Package CN_COMP_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLAN_PUB" AUTHID CURRENT_USER AS
/* $Header: cnpcps.pls 120.2.12010000.2 2008/08/30 08:00:06 ramchint ship $ */
/*#
 * This package is used to create compensation plans.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Create Compensation Plan
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- Comp Plan Data type for single plan element
TYPE comp_plan_rec_type IS RECORD
  (
   name              cn_comp_plans.name%TYPE            := CN_API.G_MISS_CHAR,
   description       cn_comp_plans.description%TYPE     := CN_API.G_MISS_CHAR ,
   start_date        cn_comp_plans.start_date%TYPE      := CN_API.G_MISS_DATE,
   end_date          cn_comp_plans.end_date%TYPE        := CN_API.G_MISS_DATE,
   status            cn_comp_plans.status_code%TYPE     := CN_API.G_MISS_CHAR,
   rc_overlap        cn_comp_plans.ALLOW_REV_CLASS_OVERLAP%TYPE
                                                        := CN_API.G_MISS_CHAR,
   sum_trx           cn_comp_plans.sum_trx_flag%TYPE    := CN_API.G_MISS_CHAR,
   plan_element_name cn_quotas.name%TYPE                := CN_API.G_MISS_CHAR,
   attribute_category   cn_comp_plans.attribute_category%TYPE
                                                        := CN_API.G_MISS_CHAR,
   attribute1           cn_comp_plans.attribute1%TYPE   := CN_API.G_MISS_CHAR,
   attribute2           cn_comp_plans.attribute2%TYPE   := CN_API.G_MISS_CHAR,
   attribute3           cn_comp_plans.attribute3%TYPE   := CN_API.G_MISS_CHAR,
   attribute4           cn_comp_plans.attribute4%TYPE   := CN_API.G_MISS_CHAR,
   attribute5           cn_comp_plans.attribute5%TYPE   := CN_API.G_MISS_CHAR,
   attribute6           cn_comp_plans.attribute6%TYPE   := CN_API.G_MISS_CHAR,
   attribute7           cn_comp_plans.attribute7%TYPE   := CN_API.G_MISS_CHAR,
   attribute8           cn_comp_plans.attribute8%TYPE   := CN_API.G_MISS_CHAR,
   attribute9           cn_comp_plans.attribute9%TYPE   := CN_API.G_MISS_CHAR,
   attribute10          cn_comp_plans.attribute10%TYPE  := CN_API.G_MISS_CHAR,
   attribute11          cn_comp_plans.attribute11%TYPE  := CN_API.G_MISS_CHAR,
   attribute12          cn_comp_plans.attribute12%TYPE  := CN_API.G_MISS_CHAR,
   attribute13          cn_comp_plans.attribute13%TYPE  := CN_API.G_MISS_CHAR,
   attribute14          cn_comp_plans.attribute14%TYPE  := CN_API.G_MISS_CHAR,
   attribute15          cn_comp_plans.attribute15%TYPE  := CN_API.G_MISS_CHAR,
   ORG_ID               CN_COMP_PLANS.ORG_ID%TYPE := NULL  /* ADDED OAFWK */
   );

-- Global variable that represent missing values.
G_MISS_COMP_PLAN_REC  comp_plan_rec_type;

-- Comments for datatype, global constant or variables
TYPE plan_element_tbl_type IS TABLE OF cn_quotas.name%TYPE
  INDEX BY BINARY_INTEGER;

G_MISS_PE_LIST plan_element_tbl_type;

-- Comp Plan Data type for multiple plan element
TYPE comp_plan_list_rec_type IS RECORD
  (
   name              cn_comp_plans.name%TYPE            := CN_API.G_MISS_CHAR,
   description       cn_comp_plans.description%TYPE     := CN_API.G_MISS_CHAR ,
   start_date        cn_comp_plans.start_date%TYPE      := CN_API.G_MISS_DATE,
   end_date          cn_comp_plans.end_date%TYPE        := CN_API.G_MISS_DATE,
   status            cn_comp_plans.status_code%TYPE     := CN_API.G_MISS_CHAR,
   rc_overlap        cn_comp_plans.ALLOW_REV_CLASS_OVERLAP%TYPE
                                                        := CN_API.G_MISS_CHAR,
   sum_trx           cn_comp_plans.sum_trx_flag%TYPE    := CN_API.G_MISS_CHAR,
   plan_element_list plan_element_tbl_type              := G_MISS_PE_LIST,
   attribute_category   cn_comp_plans.attribute_category%TYPE := CN_API.G_MISS_CHAR,
   attribute1           cn_comp_plans.attribute1%TYPE   := CN_API.G_MISS_CHAR,
   attribute2           cn_comp_plans.attribute2%TYPE   := CN_API.G_MISS_CHAR,
   attribute3           cn_comp_plans.attribute3%TYPE   := CN_API.G_MISS_CHAR,
   attribute4           cn_comp_plans.attribute4%TYPE   := CN_API.G_MISS_CHAR,
   attribute5           cn_comp_plans.attribute5%TYPE   := CN_API.G_MISS_CHAR,
   attribute6           cn_comp_plans.attribute6%TYPE   := CN_API.G_MISS_CHAR,
   attribute7           cn_comp_plans.attribute7%TYPE   := CN_API.G_MISS_CHAR,
   attribute8           cn_comp_plans.attribute8%TYPE   := CN_API.G_MISS_CHAR,
   attribute9           cn_comp_plans.attribute9%TYPE   := CN_API.G_MISS_CHAR,
   attribute10          cn_comp_plans.attribute10%TYPE  := CN_API.G_MISS_CHAR,
   attribute11          cn_comp_plans.attribute11%TYPE  := CN_API.G_MISS_CHAR,
   attribute12          cn_comp_plans.attribute12%TYPE  := CN_API.G_MISS_CHAR,
   attribute13          cn_comp_plans.attribute13%TYPE  := CN_API.G_MISS_CHAR,
   attribute14          cn_comp_plans.attribute14%TYPE  := CN_API.G_MISS_CHAR,
   attribute15          cn_comp_plans.attribute15%TYPE  := CN_API.G_MISS_CHAR
   );

-- Global variable that represent missing values.
G_MISS_COMP_PLAN_LIST_REC  comp_plan_list_rec_type;

-- Start of Comments
-- API name 	: Create_Comp_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new compensation plan with passed in plan
--                element or add the passed in plan element into an existing
--                compensation plan
-- Desc 	: Procedure to create a new compensation plan or add a plan
--                element to an existing compensation plan
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_comp_plan_rec     IN             comp_plan_rec_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: p_comp_plan_rec.plan_element_list is not using in this
--                procedure
--
-- Description :
--               Create Comp Plan is a Public Package which allows us to create
-- the comp plan or assign a plan element to a comp plan.
-- The create API will internally checks wheather to add  the comp plan or assign
-- the plan element or do both.
------------------+
-- p_comp_plan_rec Input parameter to carry both comp plan and plan Element.
--   name            Comp Plan Name, Mandatory
--   description     Description , Optional
--   start_date     Start Date, Mandatory
--   end_date       End Date, Optional
--   status         Status, default 'INCOMPLETE'
--   rc_overlap     rc_overlap ( Y/N ) which will allow you to overlap the rev
--                  classes.
--   plan_element_name Plan Element Name. Optional
------------------------+
-- End of comments

/*#
 * This procedure creates a compensation plan with the given specifications.
 * It also lets the user to create a plan element assignment.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F).
 * @param p_validation_level Validation level (default 100).
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_comp_plan_rec Contents of comp plan
 * @param x_loading_status Loading Status
 * @param x_comp_plan_id Identifier of newly created compensation plan.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Compensation Plan
 */

PROCEDURE Create_Comp_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_comp_plan_rec      IN    comp_plan_rec_type := G_MISS_COMP_PLAN_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2,
   x_comp_plan_id       IN OUT NOCOPY   NUMBER
);

END CN_COMP_PLAN_PUB ;

/
