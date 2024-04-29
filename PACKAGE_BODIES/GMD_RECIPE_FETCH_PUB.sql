--------------------------------------------------------
--  DDL for Package Body GMD_RECIPE_FETCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RECIPE_FETCH_PUB" AS
/* $Header: GMDPRCFB.pls 120.10.12010000.6 2009/06/03 09:27:34 kannavar ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'GMD_FETCH_PUB';

/*  IN Parameters:
    P_api_version   - standard parameter
    P_init_msg_list - standard parameter Should be FND_API.G_FALSE
    P_commit        - standard parameter.  Should be FND_API.G_FALSE
                             This procedure does no insert/update/delete
    P_validation_level - standard parameter
  OUT Parameters:
  x_return_status - standard parameter.  S=success,E=expected error,
                                         U=unexpected error
  x_msg_count     - standard parameter.  Num of messages generated
  x_msg_data      - standard parameter.  If only1 msg, here it is
  x_return_code   - num rows returned or SQLCODE (Database error number)*/
/*******************************************************************************
* Procedure get_recipe_id
*
* Procedure:-  This returns the recipe_id  based on the validity_rules_id
*               passed to it.
*
* Author :Pawan Kumar
*
*********************************************************************************/
PROCEDURE get_recipe_id(
        p_api_version                   IN              NUMBER          ,
        p_init_msg_list                 IN              VARCHAR2        ,
        p_recipe_validity_rule_id       IN              NUMBER          ,
        x_return_status                 OUT NOCOPY      VARCHAR2        ,
        x_msg_count                     OUT NOCOPY      NUMBER          ,
        x_msg_data                      OUT NOCOPY      VARCHAR2        ,
        x_return_code                   OUT NOCOPY      NUMBER          ,
        X_recipe_id                     OUT NOCOPY      NUMBER
) IS

/** local cursor to fetch the recipe_id from recipe_validity_rules table  **/
CURSOR get_recp IS
  SELECT recipe_id
  FROM   gmd_recipe_validity_rules
  WHERE  recipe_Validity_rule_id = p_recipe_Validity_rule_id ;


 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_recipe_id';
 l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
 IF (NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME)) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN  get_recp;
 FETCH get_recp into x_recipe_id;
 IF get_recp%NOTFOUND THEN
   RAISE fnd_api.g_exc_error;
 END IF;
 CLOSE get_recp;

 -- standard call to get msge cnt, and if cnt is 1, get mesg info
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_recipe_id;


/*******************************************************************************
* Procedure get_routing_id
*
* Procedure:-  This returns the routing_id attached to the given recipe_id
*
*
* Author :Pawan Kumar
*
*********************************************************************************/

PROCEDURE get_routing_id
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2      ,
        p_recipe_no             IN      Varchar2                        ,
        p_recipe_version        IN       NUMBER                         ,
        p_recipe_id             IN      NUMBER                          ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_id            OUT NOCOPY     NUMBER
) IS

-- local cursor to fetch the routing_id from gmd_recipes table

CURSOR get_rout IS
      SELECT routing_id
        FROM gmd_recipes_b
       WHERE recipe_id      = p_recipe_id  OR
             (recipe_no = p_recipe_no AND recipe_version = p_recipe_version);


 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_routing_id';
 l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN  get_rout;
 FETCH get_rout into x_routing_id;
 IF get_rout%NOTFOUND THEN
   RAISE fnd_api.g_exc_error;
 END IF;
 CLOSE get_rout;

 -- standard call to get msge cnt, and if cnt is 1, get mesg info
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_routing_id;

/*******************************************************************************
* Procedure get_rout_hdr
*
* Procedure:-  This returns the total rout header information  based on the
*              recipe_id passed to it.
*
*
* Author :Pawan Kumar
*
*********************************************************************************/


 PROCEDURE get_rout_hdr
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2     ,
        p_recipe_id             IN       NUMBER                         ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_rout_out	        OUT NOCOPY     recipe_rout_tbl
)
IS

 /* local Variables */
 l_api_name      VARCHAR2(30) := 'get_rout_hdr';
 l_api_version    NUMBER  := 1.0;
 i NUMBER := 0;

 CURSOR cur_rout_hdr IS

   select routing_id, routing_no,routing_vers, routing_desc, routing_class, routing_qty,
	  routing_uom, delete_mark,text_code,inactive_ind,enforce_step_dependency,in_use,creation_date,created_by,
	  last_update_login, last_update_date , last_updated_by,process_loss, contiguous_ind,
	  effective_start_date, effective_end_date,owner_id,routing_status,OWNER_ORGANIZATION_ID,attribute_category,attribute1,
	  attribute2, attribute3,attribute4, attribute5, attribute6,
          attribute7,  attribute8, attribute9, attribute10,
          attribute11,  attribute12, attribute13, attribute14,
          attribute15,  attribute16, attribute17, attribute18,
          attribute19,  attribute20, attribute21, attribute22,
          attribute23,  attribute24, attribute25, attribute26,
          attribute27,  attribute28, attribute29, attribute30
   from fm_rout_hdr
   where routing_id = (select routing_id from gmd_recipes_b where recipe_id = p_recipe_id)

  ORDER BY routing_id;

begin

 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;

  For get_rec IN cur_rout_hdr LOOP
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    i := i + 1;

         x_rout_out(i).routing_id        		:= get_rec.routing_id   	;
         x_rout_out(i).routing_no         	 	:= get_rec.routing_no  		;
         x_rout_out(i).routing_vers           		:= get_rec.routing_vers 	;
         x_rout_out(i).routing_desc           		:= get_rec.routing_desc 	;
         x_rout_out(i).routing_class              	:= get_rec.routing_class 	;
         x_rout_out(i).routing_qty           		:= get_rec.routing_qty		;
         x_rout_out(i).routing_uom             		:= get_rec.routing_uom 		;
         x_rout_out(i).delete_mark            		:= get_rec.delete_mark		;
   	 x_rout_out(i).process_loss     		:= get_rec.process_loss 	;
   	 x_rout_out(i).effective_start_date    		:= get_rec.effective_start_date	;
         x_rout_out(i).effective_end_date       	:= get_rec.effective_end_date 	;
         x_rout_out(i).owner_id           		:= get_rec.owner_id 		;
         x_rout_out(i).routing_status             	:= get_rec.routing_status       ;
         x_rout_out(i).OWNER_ORGANIZATION_ID      	:= get_rec.owner_organization_id ;
         x_rout_out(i).inactive_ind           		:= get_rec.inactive_ind		;
         x_rout_out(i).enforce_step_dependency     	:= get_rec.enforce_step_dependency ;
         x_rout_out(i).contiguous_ind     	        := get_rec.contiguous_ind       ;
         x_rout_out(i).text_code      	 		:= get_rec.text_code   		;
         x_rout_out(i).creation_date   			:= get_rec.creation_date 	;
         x_rout_out(i).created_by      			:= get_rec.created_by    	;
       	 x_rout_out(i).last_updated_by 			:= get_rec.last_updated_by 	;
 	 x_rout_out(i).last_update_date 		:= get_rec.last_update_date 	;
 	 x_rout_out(i).last_update_login 		:= get_rec.last_update_login	;
 	 x_rout_out(i).attribute_category 		:= get_rec.attribute_category	;
         x_rout_out(i).attribute1 			:= get_rec.attribute1		;
  	 x_rout_out(i).attribute2 			:= get_rec.attribute2		;
  	 x_rout_out(i).attribute3 			:= get_rec.attribute3		;
  	 x_rout_out(i).attribute4 			:= get_rec.attribute4		;
  	 x_rout_out(i).attribute5 			:= get_rec.attribute5		;
  	 x_rout_out(i).attribute6 			:= get_rec.attribute6		;
  	 x_rout_out(i).attribute7 			:= get_rec.attribute7		;
  	 x_rout_out(i).attribute8 			:= get_rec.attribute8		;
  	 x_rout_out(i).attribute9 			:= get_rec.attribute9		;
  	 x_rout_out(i).attribute10 			:= get_rec.attribute10		;
         x_rout_out(i).attribute11 			:= get_rec.attribute11		;
  	 x_rout_out(i).attribute12 			:= get_rec.attribute12		;
  	 x_rout_out(i).attribute13 			:= get_rec.attribute13		;
  	 x_rout_out(i).attribute14 			:= get_rec.attribute14		;
  	 x_rout_out(i).attribute15 			:= get_rec.attribute15		;
  	 x_rout_out(i).attribute16 			:= get_rec.attribute16		;
  	 x_rout_out(i).attribute17 			:= get_rec.attribute17		;
  	 x_rout_out(i).attribute18 			:= get_rec.attribute18		;
  	 x_rout_out(i).attribute19 			:= get_rec.attribute19		;
  	 x_rout_out(i).attribute20 			:= get_rec.attribute20		;
  	 x_rout_out(i).attribute21 			:= get_rec.attribute21		;
  	 x_rout_out(i).attribute22 			:= get_rec.attribute22		;
  	 x_rout_out(i).attribute23 			:= get_rec.attribute23		;
  	 x_rout_out(i).attribute24 			:= get_rec.attribute24		;
  	 x_rout_out(i).attribute25 			:= get_rec.attribute25		;
  	 x_rout_out(i).attribute26 			:= get_rec.attribute26		;
  	 x_rout_out(i).attribute27 			:= get_rec.attribute27		;
  	 x_rout_out(i).attribute28 			:= get_rec.attribute28		;
  	 x_rout_out(i).attribute29 			:= get_rec.attribute29		;
  	 x_rout_out(i).attribute30 			:= get_rec.attribute30		;

  END LOOP;

 IF i= 0  THEN
   RAISE fnd_api.g_exc_error;
 END IF;

 -- standard call to get msge cnt, and if cnt is 1, get mesg info
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_rout_hdr;

/*******************************************************************************
* Procedure get_formula_id
*
* Procedure:-  This returns the formula_id  information based on the
*              recipe_id passed to it.
*
*
* Author :Pawan Kumar
*
*********************************************************************************/

PROCEDURE get_formula_id

(       p_api_version           IN              NUMBER          ,
        p_init_msg_list         IN              VARCHAR2        ,
        p_recipe_no             IN              VARCHAR2        ,
        p_recipe_version        IN              NUMBER          ,
        p_recipe_id             IN              NUMBER          ,
        x_return_status         OUT NOCOPY      VARCHAR2        ,
        x_msg_count             OUT NOCOPY      NUMBER          ,
        x_msg_data              OUT NOCOPY      VARCHAR2        ,
        x_return_code           OUT NOCOPY      NUMBER          ,
        x_formula_id            OUT NOCOPY      NUMBER
) IS

-- local cursor to fetch the formula_id from gmd_recipes table

CURSOR get_form IS
      select formula_id
        from gmd_recipes_b
       where  recipe_id      = p_recipe_id OR
              (recipe_no = p_recipe_no and recipe_version = p_recipe_version);

 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_formula_id';
 l_api_version    CONSTANT  NUMBER  := 1.0;

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN  get_form;
 FETCH get_form into x_formula_id;

 IF get_form%NOTFOUND THEN
   RAISE fnd_api.g_exc_error;
 END IF;  -- end if formula_id not found

 CLOSE get_form;

 -- standard call to get msge cnt, and if cnt is 1, get mesg info
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_formula_id;

/*******************************************************************************
* Procedure get_process_loss
*
* Procedure:-  This returns the process  loss for a particular recipe if a
*              routing is attached to a given recipe.
*
*
* Author :Pawan Kumar
*
*********************************************************************************/

  PROCEDURE get_process_loss
(       p_api_version           IN              NUMBER          ,
        p_init_msg_list         IN              VARCHAR2        ,
        p_recipe_no             IN              VARCHAR2        ,
        p_recipe_version        IN              NUMBER          ,
        p_recipe_id             IN              NUMBER          ,
        p_organization_id       IN              NUMBER          ,
        x_return_status         OUT NOCOPY      VARCHAR2        ,
        x_msg_count             OUT NOCOPY      NUMBER          ,
        x_msg_data              OUT NOCOPY      VARCHAR2        ,
        x_return_code           OUT NOCOPY      NUMBER          ,
        x_process_loss          OUT NOCOPY      NUMBER
) IS

-- local cursor to fetch the process_loss from gmd_recipe_process_loss table

CURSOR get_proc IS
  SELECT process_loss
  FROM   gmd_recipe_process_loss
  WHERE  recipe_id = p_recipe_id
  AND    organization_id = p_organization_id ;

--  local Variables
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_process_loss';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 l_routing_id     NUMBER;
 l_return_status  VARCHAR2(30);
 l_msg_count      NUMBER ;
 l_return_code    NUMBER ;
 l_msg_data       VARCHAR2(2000) ;

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- call the get_routing_id procedure to check the routing exists or not
     get_routing_id
     (  p_api_version           => 1.0                         ,
        p_recipe_no             => p_recipe_no                 ,
        p_recipe_version        => p_recipe_version            ,
        p_recipe_id             => p_recipe_id                 ,
        x_return_status         => l_return_status             ,
        x_msg_count             => l_msg_count                 ,
        x_msg_data              => l_msg_data                  ,
        x_return_code           => l_return_code               ,
        x_routing_id            => l_routing_id
               ) ;

       -- check for process loss only if a routing is attached to the recipe
   IF l_routing_id IS not null then
       OPEN  get_proc;
       FETCH get_proc into x_process_loss;
   ELSE
       RAISE fnd_api.g_exc_error;
   END IF;
  /* IF get_proc%NOTFOUND THEN
      RAISE fnd_api.g_exc_error;
   END IF;  -- end if recipe_id not found */

 CLOSE get_proc;

  /* standard call to get msge cnt, and if cnt is 1, get mesg info */
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_process_loss;

/*******************************************************************************
* Procedure get_rout_material
*
* Procedure:-  This returns the material - step  information based on the
*              recipe_id passed to it.
*
*
* Author :Pawan Kumar
*        --Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
*
*********************************************************************************/

  PROCEDURE get_rout_material

(       p_api_version           IN              NUMBER          ,
        p_init_msg_list         IN              VARCHAR2        ,
        p_recipe_id             IN              NUMBER          ,
        x_return_status         OUT NOCOPY      VARCHAR2        ,
        x_msg_count             OUT NOCOPY      NUMBER          ,
        x_msg_data              OUT NOCOPY      VARCHAR2        ,
        x_return_code           OUT NOCOPY      NUMBER          ,
        x_recipe_rout_matl_tbl  OUT NOCOPY      recipe_rout_matl_tbl
)  IS


CURSOR get_matl IS
        SELECT recipe_id, formulaline_id, routingstep_id, text_code,
               creation_date, created_by,last_updated_by,
               --Sriram.S   APS K Enhancements   03March2004   Bug# 3410379
               --Added the following columns to the select statement
               minimum_transfer_qty, minimum_delay, maximum_delay,
               last_update_date, last_update_login    ,
         --Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
               ATTRIBUTE_CATEGORY,
               ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
               ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
               ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, ATTRIBUTE16, ATTRIBUTE17, ATTRIBUTE18,
               ATTRIBUTE19, ATTRIBUTE20, ATTRIBUTE21, ATTRIBUTE22, ATTRIBUTE23, ATTRIBUTE24,
               ATTRIBUTE25, ATTRIBUTE26, ATTRIBUTE27, ATTRIBUTE28, ATTRIBUTE29, ATTRIBUTE30
          FROM gmd_recipe_step_materials
         WHERE recipe_id = p_recipe_id  ;

 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_rout_material';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 i NUMBER := 0;

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
-- x_return_status := FND_API.G_RET_STS_SUCCESS;


  FOR get_rec IN get_matl LOOP
  x_return_status := FND_API.G_RET_STS_SUCCESS;
    i := i + 1;

  	 x_recipe_rout_matl_tbl(i).recipe_id        := get_rec.recipe_id;
   	 x_recipe_rout_matl_tbl(i).formulaline_id   := get_rec.formulaline_id ;
 	 x_recipe_rout_matl_tbl(i).routingstep_id   := get_rec.routingstep_id  ;
 	 x_recipe_rout_matl_tbl(i).text_code        := get_rec.text_code        ;
 	 x_recipe_rout_matl_tbl(i).creation_date    := get_rec.creation_date     ;
 	 x_recipe_rout_matl_tbl(i).created_by       := get_rec.created_by      ;
 	 x_recipe_rout_matl_tbl(i).last_updated_by  := get_rec.last_updated_by ;
 	 x_recipe_rout_matl_tbl(i).last_update_date := get_rec.last_update_date ;
 	 x_recipe_rout_matl_tbl(i).last_update_login := get_rec.last_update_login;

  	 --Sriram.S   APS K Enhancements  03March2004  Bug# 3410379
         x_recipe_rout_matl_tbl(i).minimum_transfer_qty := get_rec.minimum_transfer_qty;
         x_recipe_rout_matl_tbl(i).minimum_delay        := get_rec.minimum_delay;
         x_recipe_rout_matl_tbl(i).maximum_delay        := get_rec.maximum_delay;

         --Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
         x_recipe_rout_matl_tbl(i).ATTRIBUTE_CATEGORY   := get_rec.ATTRIBUTE_CATEGORY ;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE1       := get_rec.ATTRIBUTE1;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE2       := get_rec.ATTRIBUTE2;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE3       := get_rec.ATTRIBUTE3;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE4       := get_rec.ATTRIBUTE4;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE5       := get_rec.ATTRIBUTE5;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE6       := get_rec.ATTRIBUTE6;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE7       := get_rec.ATTRIBUTE7;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE8       := get_rec.ATTRIBUTE8;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE9       := get_rec.ATTRIBUTE9;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE10      := get_rec.ATTRIBUTE10;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE11      := get_rec.ATTRIBUTE11;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE12      := get_rec.ATTRIBUTE12;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE13      := get_rec.ATTRIBUTE13;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE14      := get_rec.ATTRIBUTE14;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE15      := get_rec.ATTRIBUTE15;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE16      := get_rec.ATTRIBUTE16;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE17      := get_rec.ATTRIBUTE17;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE18      := get_rec.ATTRIBUTE18;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE19      := get_rec.ATTRIBUTE19;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE20      := get_rec.ATTRIBUTE20;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE21      := get_rec.ATTRIBUTE21;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE22      := get_rec.ATTRIBUTE22;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE23      := get_rec.ATTRIBUTE23;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE24      := get_rec.ATTRIBUTE24;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE25      := get_rec.ATTRIBUTE25;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE26      := get_rec.ATTRIBUTE26;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE27      := get_rec.ATTRIBUTE27;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE28      := get_rec.ATTRIBUTE28;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE29      := get_rec.ATTRIBUTE29;
         x_recipe_rout_matl_tbl(i).ATTRIBUTE30      := get_rec.ATTRIBUTE30;

  END LOOP;

 IF i = 0  THEN
   RAISE fnd_api.g_exc_error;
 END IF;  -- end if recipe_id not found

 /* standard call to get msge cnt, and if cnt is 1, get mesg info*/
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_rout_material;

  /*******************************************************************************
* Procedure get_routing_step_details
*
* Procedure:-  This returns the routing step  information based on the
*              routing_id passed to it.This information is for populating
*              the data before the recipe_id is created.
*
*
* Author :Pawan Kumar
*
* History
*         James Bernard 07-NOV-2002 BUG#2330056
*         Code is commented so that text code of the routing step does not get
*         fetched and copied to the newly created recipe.
*********************************************************************************/


  PROCEDURE get_routing_step_details
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2      ,
        p_routing_id            IN       NUMBER                         ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_step_out             OUT NOCOPY     routing_step_tbl
) IS

 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_step_details';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 i NUMBER := 0;


 --BUG#2330056 James Bernard
 --Removed "d.text_code" from the following Select Statement as it was not being used anywhere.
 CURSOR get_routing_step IS
  SELECT o.process_qty_uom ,d.routing_id,d.routingstep_id, d.routingstep_no, d.oprn_id, step_qty,
         d.steprelease_type,d.minimum_transfer_qty, o.oprn_no, o.oprn_vers, o.oprn_desc, d.creation_date,
         d.created_by,d.last_updated_by, d.last_update_date, d.last_update_login,
         d.attribute_category,d.attribute1,  d.attribute2, d.attribute3,
         d.attribute4, d.attribute5, d.attribute6,
         d.attribute7,  d.attribute8, d.attribute9, d.attribute10,
         d.attribute11,  d.attribute12, d.attribute13, d.attribute14,
         d.attribute15,  d.attribute16, d.attribute17, d.attribute18,
         d.attribute19,  d.attribute20, d.attribute21, d.attribute22,
         d.attribute23,  d.attribute24, d.attribute25, d.attribute26,
         d.attribute27,  d.attribute28, d.attribute29, d.attribute30
  FROM   fm_rout_dtl d, gmd_operations_vl o
  WHERE  d.routing_id = p_routing_id
  AND    d.oprn_id = o.oprn_id ;
   --END BUG#2330056

 BEGIN
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

   For get_rec IN get_routing_step LOOP
   x_return_status := FND_API.G_RET_STS_SUCCESS;
    i := i + 1;

   	 x_routing_step_out(i).routingstep_no  	:= get_rec.routingstep_no ;
   	 x_routing_step_out(i).routingstep_id  	:= get_rec.routingstep_id ;
	 x_routing_step_out(i).oprn_id  	:= get_rec.oprn_id  ;
	 x_routing_step_out(i).oprn_no 		:= get_rec.oprn_no  ;
	 x_routing_step_out(i).oprn_vers 	:= get_rec.oprn_vers  ;
	 x_routing_step_out(i).oprn_desc 	:= get_rec.oprn_desc  ;
	 x_routing_step_out(i).process_qty_uom  := get_rec.process_qty_uom  ;
	 x_routing_step_out(i).minimum_transfer_qty := get_rec.minimum_transfer_qty;

 	 x_routing_step_out(i).step_qty  	:= get_rec.step_qty  ;
	 x_routing_step_out(i).steprelease_type := get_rec.steprelease_type  ;
         --BEGIN BUG#2330056 James Bernard
         --Text code should not be copied over to newly created Recipe, commenting
         --following assignment as text_code is not getting fetched in the cursor now.
         --x_routing_step_out(i).text_code      := get_rec.text_code        ;
         --END BUG#2330056
       	 x_routing_step_out(i).last_updated_by	:= get_rec.last_updated_by ;
 	 x_routing_step_out(i).created_by     	:= get_rec.created_by      ;
 	 x_routing_step_out(i).last_update_date := get_rec.last_update_date ;
 	 x_routing_step_out(i).creation_date  	:= get_rec.creation_date     ;
 	 x_routing_step_out(i).last_update_login := get_rec.last_update_login;
 	 x_routing_step_out(i).attribute1 	:= get_rec.attribute1;
  	 x_routing_step_out(i).attribute2 	:= get_rec.attribute2;
  	 x_routing_step_out(i).attribute3 	:= get_rec.attribute3;
  	 x_routing_step_out(i).attribute4 	:= get_rec.attribute4;
  	 x_routing_step_out(i).attribute5 	:= get_rec.attribute5;
  	 x_routing_step_out(i).attribute6 	:= get_rec.attribute6;
  	 x_routing_step_out(i).attribute7 	:= get_rec.attribute7;
  	 x_routing_step_out(i).attribute8 	:= get_rec.attribute8;
  	 x_routing_step_out(i).attribute9 	:= get_rec.attribute9;
  	 x_routing_step_out(i).attribute10 	:= get_rec.attribute10;
         x_routing_step_out(i).attribute11 	:= get_rec.attribute11;
  	 x_routing_step_out(i).attribute12 	:= get_rec.attribute12;
  	 x_routing_step_out(i).attribute13 	:= get_rec.attribute13;
  	 x_routing_step_out(i).attribute14 	:= get_rec.attribute14;
  	 x_routing_step_out(i).attribute15 	:= get_rec.attribute15;
  	 x_routing_step_out(i).attribute16 	:= get_rec.attribute16;
  	 x_routing_step_out(i).attribute17 	:= get_rec.attribute17;
  	 x_routing_step_out(i).attribute18 	:= get_rec.attribute18;
  	 x_routing_step_out(i).attribute19 	:= get_rec.attribute19;
  	 x_routing_step_out(i).attribute20 	:= get_rec.attribute20;
  	 x_routing_step_out(i).attribute21 	:= get_rec.attribute21;
  	 x_routing_step_out(i).attribute22 	:= get_rec.attribute22;
  	 x_routing_step_out(i).attribute23 	:= get_rec.attribute23;
  	 x_routing_step_out(i).attribute24 	:= get_rec.attribute24;
  	 x_routing_step_out(i).attribute25 	:= get_rec.attribute25;
  	 x_routing_step_out(i).attribute26 	:= get_rec.attribute26;
  	 x_routing_step_out(i).attribute27 	:= get_rec.attribute27;
  	 x_routing_step_out(i).attribute28 	:= get_rec.attribute28;
  	 x_routing_step_out(i).attribute29 	:= get_rec.attribute29;
  	 x_routing_step_out(i).attribute30 	:= get_rec.attribute30;
  END LOOP;

IF i = 0 THEN
   RAISE fnd_api.g_exc_error;
END IF;  -- end if recipe_id not found

 -- standard call to get msge cnt, and if cnt is 1, get mesg info
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_routing_step_details;

 /*******************************************************************************
* Procedure get_recipe_step_details
*
* Procedure:- This returns the recipe step  information based on the
*              recipe_id passed to it.This information is for populating
*              the data after the recipe_id is created.
*
*
* Author :Pawan Kumar
*
*********************************************************************************/


PROCEDURE get_recipe_step_details
(       p_api_version           IN              NUMBER                  ,
        p_init_msg_list         IN              VARCHAR2                ,
        p_recipe_id             IN              NUMBER                  ,
        p_organization_id       IN              NUMBER  DEFAULT NULL    ,
        x_return_status         OUT NOCOPY      VARCHAR2                ,
        x_msg_count             OUT NOCOPY      NUMBER                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                ,
        x_return_code           OUT NOCOPY      NUMBER                  ,
        x_recipe_step_out       OUT NOCOPY      recipe_step_tbl         ,
        p_val_scale_factor	IN	        NUMBER			,
        p_process_loss		IN	        NUMBER,
	p_routing_id            IN      	NUMBER  DEFAULT NULL
)
    IS

  /*** local Variables ***/
  l_api_name       CONSTANT  VARCHAR2(30) := 'get_step_details';
  l_api_version    CONSTANT  NUMBER  := 1.0;

  l_routing_id    	NUMBER;
  l_return_status     	VARCHAR2(30);
  l_msg_count      	NUMBER ;
  l_return_code      	NUMBER ;
  i			NUMBER(10) DEFAULT 0;
  l_msg_data          	VARCHAR2(2000) ;
  l_charge_tbl  	gmd_common_val.charge_tbl ;
  l_step_tbl		gmd_auto_step_calc.step_rec_tbl;
  l_calculate_step_qty	NUMBER(5);
  l_rout_scale_factor	NUMBER;
  l_orgn_code           VARCHAR2(4);

  CURSOR Cur_get_recipe IS
    SELECT routing_id, calculate_step_quantity
    FROM   gmd_recipes_b
    WHERE  recipe_id = p_recipe_id;

  CURSOR get_recipe_step (l_auto_calc NUMBER) IS
  SELECT dtl.routingstep_no, oprn.oprn_id, oprn.oprn_no, oprn.oprn_desc, oprn.oprn_vers,
         stp.step_qty, oprn.process_qty_uom, stp.text_code, stp.routingstep_id, dtl.steprelease_type,
         dtl.minimum_transfer_qty, stp.recipe_id, stp.creation_date, stp.created_by,stp.last_updated_by,
         stp.last_update_date, stp.last_update_login, stp.attribute_category,
         stp.attribute1, stp.attribute2, stp.attribute3,  stp.attribute4,
         stp.attribute5, stp.attribute6, stp.attribute7,  stp.attribute8,
         stp.attribute9, stp.attribute10, stp.attribute11,  stp.attribute12,
         stp.attribute13, stp.attribute14, stp.attribute15,  stp.attribute16,
         stp.attribute17, stp.attribute18, stp.attribute19,  stp.attribute20,
         stp.attribute21, stp.attribute22, stp.attribute23,  stp.attribute24,
         stp.attribute25, stp.attribute26, stp.attribute27,  stp.attribute28,
         stp.attribute29, stp.attribute30
  FROM  gmd_recipe_routing_steps stp, fm_rout_dtl dtl, gmd_operations_vl oprn
  WHERE l_auto_calc = 0
        AND stp.recipe_id = p_recipe_id
        AND dtl.routingstep_id = stp.routingstep_id
        AND dtl.oprn_id = oprn.oprn_id
  UNION
  SELECT dtl.routingstep_no, oprn.oprn_id, oprn.oprn_no, oprn.oprn_desc, oprn.oprn_vers,
         dtl.step_qty, oprn.process_qty_uom,
         -- dtl.text_code,
          nvl(grrs.text_code,dtl.text_code),
         dtl.routingstep_id,dtl.steprelease_type,
         dtl.minimum_transfer_qty, 0 RECIPE_ID,
         /*dtl.creation_date, dtl.created_by,dtl.last_updated_by,
         dtl.last_update_date, dtl.last_update_login,  dtl.attribute_category,
         dtl.attribute1,  dtl.attribute2, dtl.attribute3,  dtl.attribute4,
         dtl.attribute5, dtl.attribute6, dtl.attribute7,  dtl.attribute8,
         dtl.attribute9, dtl.attribute10, dtl.attribute11,  dtl.attribute12,
         dtl.attribute13, dtl.attribute14, dtl.attribute15,  dtl.attribute16,
         dtl.attribute17, dtl.attribute18, dtl.attribute19,  dtl.attribute20,
         dtl.attribute21, dtl.attribute22, dtl.attribute23,  dtl.attribute24,
         dtl.attribute25, dtl.attribute26, dtl.attribute27,  dtl.attribute28,
         dtl.attribute29, dtl.attribute30*/
         nvl(grrs.creation_date,dtl.creation_date),
         nvl(grrs.created_by,dtl.created_by),
         nvl(grrs.last_updated_by,dtl.last_updated_by),
         nvl(grrs.last_update_date,dtl.last_update_date),
         nvl(grrs.last_update_login,dtl.last_update_login),
         nvl(grrs.attribute_category,dtl.attribute_category),
       nvl(grrs.attribute1,dtl.attribute1),
       nvl(grrs.attribute2,dtl.attribute2),
       nvl(grrs.attribute3,dtl.attribute3),
       nvl(grrs.attribute4,dtl.attribute4),
       nvl(grrs.attribute5,dtl.attribute5),
       nvl(grrs.attribute6,dtl.attribute6),
       nvl(grrs.attribute7,dtl.attribute7),
       nvl(grrs.attribute8,dtl.attribute8),
       nvl(grrs.attribute9,dtl.attribute9),
       nvl(grrs.attribute10,dtl.attribute10),
       nvl(grrs.attribute11,dtl.attribute11),
       nvl(grrs.attribute12,dtl.attribute12),
       nvl(grrs.attribute13,dtl.attribute13),
       nvl(grrs.attribute14,dtl.attribute14),
       nvl(grrs.attribute15,dtl.attribute15),
       nvl(grrs.attribute16,dtl.attribute16),
       nvl(grrs.attribute17,dtl.attribute17),
       nvl(grrs.attribute18,dtl.attribute18),
       nvl(grrs.attribute19,dtl.attribute19),
       nvl(grrs.attribute20,dtl.attribute20),
       nvl(grrs.attribute21,dtl.attribute21),
       nvl(grrs.attribute22,dtl.attribute22),
       nvl(grrs.attribute23,dtl.attribute23),
       nvl(grrs.attribute24,dtl.attribute24),
       nvl(grrs.attribute25,dtl.attribute25),
       nvl(grrs.attribute26,dtl.attribute26),
       nvl(grrs.attribute27,dtl.attribute27),
       nvl(grrs.attribute28,dtl.attribute28),
       nvl(grrs.attribute29,dtl.attribute29),
       nvl(grrs.attribute30,dtl.attribute30)
  FROM   fm_rout_dtl dtl, gmd_recipes_b recp ,  gmd_operations_vl oprn,
  gmd_recipe_routing_steps grrs /* Added in Bug No.8428182 */
  WHERE  recp.recipe_id = p_recipe_id
         AND grrs.recipe_id(+) = p_recipe_id /* Added in Bug No.8428182 */
         AND grrs.routingstep_id(+) = dtl.routingstep_id /* Added in Bug No.8428182 */
         AND dtl.routing_id = l_routing_id
         AND oprn.oprn_id = dtl.oprn_id
         AND  dtl.routingstep_id NOT IN (SELECT routingstep_id
                                           FROM gmd_recipe_routing_steps
                                          WHERE recipe_id   = p_recipe_id
                                            AND l_auto_calc = 0)
  ORDER BY routingstep_no;

  /*Bug# 3612365 - Thomas Daniel */
  /*Added the following cursor to pass back the resource causing the charge on the step */

  CURSOR Cur_get_charge_resource (V_routingstep_id NUMBER, V_max_capacity NUMBER) IS
    SELECT resources
    FROM   gmd_recipe_orgn_resources
    WHERE  routingstep_id = V_routingstep_id
    AND    recipe_id = p_recipe_id
    AND    organization_id = P_organization_id
    AND    max_capacity = V_max_capacity
    UNION
    SELECT r.resources
    FROM   fm_rout_dtl d, gmd_operation_resources r,
           gmd_operation_activities a, cr_rsrc_dtl d
    WHERE  d.routingstep_id = V_routingstep_id
    AND    d.oprn_id = a.oprn_id
    AND    a.oprn_line_id = r.oprn_line_id
    AND    r.resources = d.resources
    AND    organization_id = P_organization_id
    AND    d.max_capacity = V_max_capacity
    AND    capacity_constraint = 1
    UNION
    SELECT r.resources
    FROM   fm_rout_dtl d, gmd_operation_resources r,
           gmd_operation_activities a, cr_rsrc_mst m
    WHERE  d.routingstep_id = V_routingstep_id
    AND    d.oprn_id = a.oprn_id
    AND    a.oprn_line_id = r.oprn_line_id
    AND    r.resources = m.resources
    AND    m.max_capacity = V_max_capacity
    AND    capacity_constraint = 1;

CURSOR get_orgn_code IS
  SELECT organization_code
    FROM org_access_view
   WHERE organization_id = p_organization_id;

BEGIN
  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                      l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- call the get_routing_id procedure to check the routing exists or not
  OPEN  Cur_get_recipe;
  FETCH Cur_get_recipe INTO l_routing_id, l_calculate_step_qty;
  CLOSE Cur_get_recipe;

  IF (p_routing_id IS NOT NULL) THEN
    l_routing_id := p_routing_id;
  END IF;

  IF l_routing_id IS NOT NULL THEN

    IF l_calculate_step_qty = 1 THEN
      gmd_auto_step_calc.calc_step_qty(p_parent_id	        => P_recipe_id,
                                       p_step_tbl	        => l_step_tbl,
                                       p_msg_count    	        => l_msg_count,
                                       p_msg_stack    	        => l_msg_data,
                                       p_return_status 	        => l_return_status,
                                       p_ignore_mass_conv       => TRUE,
                                       p_ignore_vol_conv        => TRUE,
                                       p_scale_factor           => NVL(P_val_scale_factor,1),
                                       p_process_loss           => NVL(p_process_loss, 0),
                                       p_organization_id        => p_organization_id);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      l_rout_scale_factor := GMD_COMMON_VAL.Get_Routing_Scale_Factor
                             (vRecipe_Id => p_recipe_id
                             ,x_return_status => l_return_status);
    END IF; /* If l_calculate_step_qty = 1 */

    FOR get_rec IN get_recipe_step (l_calculate_step_qty) LOOP
      i := i + 1;
      x_recipe_step_out(i).recipe_id            := get_rec.recipe_id		;
      x_recipe_step_out(i).routingstep_no       := get_rec.routingstep_no	;
      x_recipe_step_out(i).routingstep_id       := get_rec.routingstep_id	;
      x_recipe_step_out(i).oprn_id              := get_rec.oprn_id  		;
      x_recipe_step_out(i).oprn_no              := get_rec.oprn_no  		;
      x_recipe_step_out(i).oprn_vers            := get_rec.oprn_vers  		;
      x_recipe_step_out(i).oprn_desc            := get_rec.oprn_desc  		;
      x_recipe_step_out(i).process_qty_uom      := get_rec.process_qty_uom  	;
      x_recipe_step_out(i).steprelease_type     := get_rec.steprelease_type 	;
      x_recipe_step_out(i).minimum_transfer_qty := get_rec.minimum_transfer_qty ;

      IF l_calculate_step_qty = 1 THEN
        x_recipe_step_out(i).step_qty := l_step_tbl(i).step_qty;
      ELSE
        IF get_rec.recipe_id = 0 THEN
          /* This implies that the step qty in get rec is from the routing */
          x_recipe_step_out(i).step_qty          := get_rec.step_qty * NVL(l_rout_scale_factor, 1)
     	                                                             * NVL(p_val_scale_factor, 1);
        ELSE
          /* This implies that the step qty in get rec is from the recipe */
          x_recipe_step_out(i).step_qty          := get_rec.step_qty * NVL(p_val_scale_factor, 1);
        END IF;

        l_step_tbl(i).step_id := x_recipe_step_out(i).routingstep_id;
        l_step_tbl(i).step_no := x_recipe_step_out(i).routingstep_no;
        l_step_tbl(i).step_qty := x_recipe_step_out(i).step_qty;
        l_step_tbl(i).step_qty_uom := x_recipe_step_out(i).process_qty_uom;
      END IF; /* If l_calculate_step_qty = 1 */

      x_recipe_step_out(i).text_code         := get_rec.text_code       	;
      x_recipe_step_out(i).last_updated_by   := get_rec.last_updated_by 	;
      x_recipe_step_out(i).created_by        := get_rec.created_by      	;
      x_recipe_step_out(i).last_update_date  := get_rec.last_update_date 	;
      x_recipe_step_out(i).creation_date     := get_rec.creation_date        ;
      x_recipe_step_out(i).last_update_login := get_rec.last_update_login	;
      x_recipe_step_out(i).attribute1 	:= get_rec.attribute1		;
      x_recipe_step_out(i).attribute2 	:= get_rec.attribute2		;
      x_recipe_step_out(i).attribute3 	:= get_rec.attribute3		;
      x_recipe_step_out(i).attribute4 	:= get_rec.attribute4		;
      x_recipe_step_out(i).attribute5 	:= get_rec.attribute5		;
      x_recipe_step_out(i).attribute6 	:= get_rec.attribute6		;
      x_recipe_step_out(i).attribute7 	:= get_rec.attribute7		;
      x_recipe_step_out(i).attribute8 	:= get_rec.attribute8		;
      x_recipe_step_out(i).attribute9 	:= get_rec.attribute9		;
      x_recipe_step_out(i).attribute10 	:= get_rec.attribute10		;
      x_recipe_step_out(i).attribute11 	:= get_rec.attribute11		;
      x_recipe_step_out(i).attribute12 	:= get_rec.attribute12		;
      x_recipe_step_out(i).attribute13 	:= get_rec.attribute13		;
      x_recipe_step_out(i).attribute14 	:= get_rec.attribute14		;
      x_recipe_step_out(i).attribute15 	:= get_rec.attribute15		;
      x_recipe_step_out(i).attribute16 	:= get_rec.attribute16		;
      x_recipe_step_out(i).attribute17 	:= get_rec.attribute17		;
      x_recipe_step_out(i).attribute18 	:= get_rec.attribute18		;
      x_recipe_step_out(i).attribute19 	:= get_rec.attribute19		;
      x_recipe_step_out(i).attribute20 	:= get_rec.attribute20		;
      x_recipe_step_out(i).attribute21 	:= get_rec.attribute21		;
      x_recipe_step_out(i).attribute22 	:= get_rec.attribute22		;
      x_recipe_step_out(i).attribute23 	:= get_rec.attribute23		;
      x_recipe_step_out(i).attribute24 	:= get_rec.attribute24		;
      x_recipe_step_out(i).attribute25 	:= get_rec.attribute25		;
      x_recipe_step_out(i).attribute26 	:= get_rec.attribute26		;
      x_recipe_step_out(i).attribute27 	:= get_rec.attribute27		;
      x_recipe_step_out(i).attribute28 	:= get_rec.attribute28		;
      x_recipe_step_out(i).attribute29 	:= get_rec.attribute29		;
      x_recipe_step_out(i).attribute30 	:= get_rec.attribute30		;
      x_recipe_step_out(i).attribute_category 	:= get_rec.attribute_category	; /* Added in Bug No.8428182 */

    END LOOP;

    IF p_organization_id IS NOT NULL THEN
            OPEN  get_orgn_code;
            FETCH get_orgn_code INTO l_orgn_code;
            CLOSE get_orgn_code;
    END IF;

    -- call the charges procedure to get the max_capacity for the step.
    gmd_common_val.Calculate_Step_Charges (
        P_recipe_id 		=> 	p_recipe_id             ,
  	P_tolerance		=>	0		        ,
  	P_orgn_id	        =>	p_organization_id     	,
  	P_step_tbl		=>	l_step_tbl	        ,
  	x_charge_tbl	        =>	l_charge_tbl	        ,
   	x_return_status		=> 	l_return_status
     ) ;

    FOR j IN 1..x_recipe_step_out.COUNT LOOP
      FOR k IN 1..l_charge_tbl.COUNT LOOP
        IF  x_recipe_step_out(j).routingstep_id = l_charge_tbl(k).routingstep_id  THEN
          x_recipe_step_out(j).max_capacity     := l_charge_tbl(k).max_capacity;
          x_recipe_step_out(j).capacity_uom     := l_charge_tbl(k).capacity_uom;
          x_recipe_step_out(j).charge           := l_charge_tbl(k).charge;

          /*Bug# 3612365 - Thomas Daniel */
          /*Added the following condition to populate the resource causing the charge */
          IF l_charge_tbl(k).max_capacity IS NOT NULL THEN
             -- Bug#5258672 use the capacity value in resource UOM
            OPEN Cur_get_charge_resource(l_charge_tbl(k).routingstep_id, l_charge_tbl(k).max_capacity_in_res_UOM);
            FETCH Cur_get_charge_resource INTO X_recipe_step_out(j).resources;
            CLOSE Cur_get_charge_resource;
          END IF;
          EXIT;
        END IF;
      END LOOP; /* FOR k IN 1..l_charge_tbl.COUNT */
    END LOOP; /* FOR j IN 1..x_recipe_step_out.COUNT */

  END IF; /* If routing id is not null */

  /* standard call to get msge cnt, and if cnt is 1, get mesg info*/
  FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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
     FND_MSG_PUB.add_exc_msg ('GMD_RECIPE_FETCH_PUB', 'GET_RECIPE_STEP_DETAILS');
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

END get_recipe_step_details;

/*******************************************************************************
* Procedure get_step_depd_details
*
* Procedure:- This returns the step dependency for information based on the
*              recipe_id passed to it.
*
*
* Author :Pawan Kumar
*
*********************************************************************************/

PROCEDURE get_step_depd_details

(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2      ,
        p_recipe_id             IN     NUMBER                           ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        x_routing_depd_tbl     OUT NOCOPY      routing_depd_tbl
)  IS


CURSOR get_depd IS
        SELECT routingstep_no,dep_routingstep_no, routing_id, dep_type, rework_code,
               standard_delay, minimum_delay, max_delay, transfer_qty, RoutingStep_No_uom,
               transfer_pct, text_code, creation_date, created_by,last_updated_by,
               last_update_date, last_update_login,chargeable_ind
               --Sriram.S   APS K Enhancements   03March2004  Bug# 3410379
               --Added chargable_ind column to the select statement
        FROM   fm_rout_dep
        WHERE  routing_id = (SELECT routing_id
                               FROM gmd_recipes_b
                              WHERE recipe_id = p_recipe_id) ;


 depd_rec    fm_rout_dep%rowtype;

 /***  local Variables ***/
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_step_depd_details';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 i                          NUMBER := 0;
 l_routing_id               NUMBER;
 l_return_status            VARCHAR2(30);
 l_msg_count                NUMBER;
 l_return_code              NUMBER ;
 l_msg_data                 VARCHAR2(2000) ;

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
   /*Check for circular step dependency */
  -- call the get_routing_id procedure to check the routing exists or not

     get_routing_id (
        p_api_version           => 1.0                  ,
        p_recipe_no             => NULL                 ,
        p_recipe_version        => NULL                 ,
        p_recipe_id             => p_recipe_id          ,
        x_return_status         => l_return_status      ,
        x_msg_count             => l_msg_count          ,
        x_msg_data              => l_msg_data           ,
        x_return_code           => l_return_code        ,
        x_routing_id            => l_routing_id);

 IF l_routing_id IS NOT NULL THEN
   IF gmdrtval_pub.circular_dependencies_exist(l_routing_id) then
     x_return_status := 'U' ;

   ELSE

     FOR get_rec IN get_depd LOOP
      i := i + 1;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_routing_depd_tbl(i).dep_routingstep_no 	:= get_rec.dep_routingstep_no ;
         x_routing_depd_tbl(i).routingstep_no 	        := get_rec.routingstep_no ;
  	 x_routing_depd_tbl(i).routing_id  	        := get_rec.routing_id;
   	 x_routing_depd_tbl(i).dep_type 	        := get_rec.dep_type;
   	 x_routing_depd_tbl(i).rework_code  	        := get_rec.rework_code ;
         x_routing_depd_tbl(i).standard_delay  	        := get_rec.standard_delay ;
         x_routing_depd_tbl(i).minimum_delay 	        := get_rec.minimum_delay  ;
         x_routing_depd_tbl(i).max_delay  	        := get_rec.max_delay  ;
 	 x_routing_depd_tbl(i).transfer_qty  	        := get_rec.transfer_qty ;
 	 x_routing_depd_tbl(i).RoutingStep_No_uom       := get_rec.RoutingStep_No_uom;
 	 x_routing_depd_tbl(i).transfer_pct  	        := get_rec.transfer_pct  ;
 	 x_routing_depd_tbl(i).text_code      	        := get_rec.text_code        ;
       	 x_routing_depd_tbl(i).last_updated_by          := get_rec.last_updated_by ;
 	 x_routing_depd_tbl(i).created_by      	        := get_rec.created_by      ;
 	 x_routing_depd_tbl(i).last_update_date         := get_rec.last_update_date ;
 	 x_routing_depd_tbl(i).creation_date   	        := get_rec.creation_date     ;
 	 x_routing_depd_tbl(i).last_update_login        := get_rec.last_update_login;

         --Sriram.S   APS K Enhancements   03March2004  Bug# 3410379
         x_routing_depd_tbl(i).chargeable_ind := get_rec.chargeable_ind;
     END LOOP;

     IF  i = 0 THEN
       RAISE fnd_api.g_exc_error;
     END IF;
   END IF;
END IF;

 /* standard call to get msge cnt, and if cnt is 1, get mesg info*/
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_step_depd_details;

/*******************************************************************************
* Procedure get_oprn_act_detl
*
* Procedure:- This returns the step, operation and activities details for a given recipe
*             based on the recipe_id passed to it.
*
*
* Author :Pawan Kumar
* History
*  Rameshwar 09-DEC-2002 BUG#2686887
*  Modified  the order by clause of the cursor get_recp_act.
* S.Dulyk 11-MAR-2003 Bug 2845110 MTW enhancement - added material_ind
*********************************************************************************/


 PROCEDURE get_oprn_act_detl
(       p_api_version           IN              NUMBER          ,
        p_init_msg_list         IN              VARCHAR2        ,
        p_recipe_id             IN              NUMBER          ,
        p_organization_id       IN              NUMBER 		,
        x_return_status         OUT NOCOPY      VARCHAR2        ,
        x_msg_count             OUT NOCOPY      NUMBER          ,
        x_msg_data              OUT NOCOPY      VARCHAR2        ,
        x_return_code           OUT NOCOPY      NUMBER          ,
        x_oprn_act_out          OUT NOCOPY      oprn_act_tbl
) IS

 /*  local Variables */
 l_api_name      VARCHAR2(30) := 'get_oprn_act_detl';
 l_api_version    NUMBER  := 1.0;
 i NUMBER := 0;

--BEGIN BUG #2686887 Rameshwar
--Modified  the order by clause  from 2,9 to  1,9.
 CURSOR get_recp_act IS

  SELECT d.routingstep_no routing_step_no,d.routingstep_id, o.oprn_no, o.oprn_desc, o.oprn_vers, o.oprn_id, o.minimum_transfer_qty,
         a.activity, fm.activity_desc,  ra.oprn_line_id oprnline_id, ra.activity_factor, a.offset_interval,
         a.break_ind, a.max_break,a.material_ind, a.sequence_dependent_ind, ra.recipe_id,
         ra.text_code,ra.creation_date, ra.created_by,ra.last_updated_by,
         ra.last_update_date, ra.last_update_login, ra.attribute_category,
         ra.attribute1, ra.attribute2, ra.attribute3,  ra.attribute4,
         ra.attribute5, ra.attribute6, ra.attribute7,  ra.attribute8,
         ra.attribute9, ra.attribute10, ra.attribute11,  ra.attribute12,
         ra.attribute13, ra.attribute14, ra.attribute15,  ra.attribute16,
         ra.attribute17, ra.attribute18, ra.attribute19,  ra.attribute20,
         ra.attribute21, ra.attribute22, ra.attribute23,  ra.attribute24,
         ra.attribute25, ra.attribute26, ra.attribute27,  ra.attribute28,
         ra.attribute29, ra.attribute30, 1 recipe_override
  FROM  gmd_recipe_orgn_activities ra, fm_rout_dtl d,
        gmd_operations_vl o, gmd_operation_activities a , fm_actv_mst fm
  WHERE ra.recipe_id = p_recipe_id
        AND  d.routingstep_id = ra.routingstep_id
        AND d.oprn_id = o.oprn_id
        AND a.activity = fm.activity
        AND ra.oprn_line_id = a.oprn_line_id
        AND (p_organization_id IS NULL  OR ra.organization_id = p_organization_id)

  UNION
  SELECT d.routingstep_no routing_step_no,d.routingstep_id, o.oprn_no, o.oprn_desc, o.oprn_vers,o.oprn_id,o.minimum_transfer_qty,
         a.activity,fm.activity_desc, a.oprn_line_id oprnline_id, a.activity_factor,a.offset_interval,
         a.break_ind, a.max_break, a.material_ind,a.sequence_dependent_ind, r.RECIPE_ID,
         a.text_code, a.creation_date, a.created_by,a.last_updated_by,
         a.last_update_date, a.last_update_login, a.attribute_category,
         a.attribute1,  a.attribute2, a.attribute3,  a.attribute4,
         a.attribute5, a.attribute6, a.attribute7,  a.attribute8,
         a.attribute9, a.attribute10, a.attribute11,  a.attribute12,
         a.attribute13, a.attribute14, a.attribute15,  a.attribute16,
         a.attribute17, a.attribute18, a.attribute19,  a.attribute20,
         a.attribute21, a.attribute22, a.attribute23,  a.attribute24,
         a.attribute25, a.attribute26, a.attribute27,  a.attribute28,
         a.attribute29, a.attribute30, 0 recipe_override
  FROM   fm_rout_dtl d, gmd_recipes_b r ,  gmd_operations_vl o, gmd_operation_activities a, fm_actv_mst fm
  WHERE  r.recipe_id = p_recipe_id
         AND d.routing_id = r.routing_id
         AND o.oprn_id = d.oprn_id
         AND a.oprn_id = o.oprn_id
         AND a.activity = fm.activity
         AND  a.oprn_line_id NOT IN (SELECT oprn_line_id
                                       FROM gmd_recipe_orgn_activities
                                      WHERE recipe_id = p_recipe_id
                                        AND (p_organization_id IS NULL or organization_id = p_organization_id))
  ORDER BY routing_step_no, oprnline_id;
  -- END BUG#2686887

BEGIN

 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;

  FOR get_rec IN get_recp_act LOOP
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    i := i + 1;
         x_oprn_act_out(i).routingstep_no        := get_rec.routing_step_no  ;
         x_oprn_act_out(i).routingstep_id        := get_rec.routingstep_id   ;
         x_oprn_act_out(i).oprn_no               := get_rec.oprn_no  ;
         x_oprn_act_out(i).oprn_desc             := get_rec.oprn_desc ;
         x_oprn_act_out(i).oprn_vers             := get_rec.oprn_vers ;
         x_oprn_act_out(i).oprn_id             	 := get_rec.oprn_id;
         x_oprn_act_out(i).minimum_transfer_qty  := get_rec.minimum_transfer_qty;
         x_oprn_act_out(i).activity              := get_rec.activity  ;
         x_oprn_act_out(i).activity_desc         := get_rec.activity_desc  ;
   	 x_oprn_act_out(i).oprn_line_id    	 := get_rec.oprnline_id ;
   	 x_oprn_act_out(i).activity_factor       := get_rec.activity_factor;
   	 x_oprn_act_out(i).sequence_dependent_ind := get_rec.sequence_dependent_ind;
   	 x_oprn_act_out(i).recipe_override        := get_rec.recipe_override;
         x_oprn_act_out(i).offset_interval        := get_rec.offset_interval;
         x_oprn_act_out(i).break_ind            := get_rec.break_ind;
         x_oprn_act_out(i).max_break            := get_rec.max_break;
         x_oprn_act_out(i).material_ind         := get_rec.material_ind;
         x_oprn_act_out(i).text_code       	:= get_rec.text_code        ;
         x_oprn_act_out(i).creation_date   	:= get_rec.creation_date     ;
         x_oprn_act_out(i).created_by      	:= get_rec.created_by      ;
       	 x_oprn_act_out(i).last_updated_by 	:= get_rec.last_updated_by ;
 	 x_oprn_act_out(i).last_update_date 	:= get_rec.last_update_date ;
 	 x_oprn_act_out(i).last_update_login 	:= get_rec.last_update_login;
 	 x_oprn_act_out(i).attribute_category 	:= get_rec.attribute_category;
         x_oprn_act_out(i).attribute1 		:= get_rec.attribute1;
  	 x_oprn_act_out(i).attribute2 		:= get_rec.attribute2;
  	 x_oprn_act_out(i).attribute3 		:= get_rec.attribute3;
  	 x_oprn_act_out(i).attribute4 		:= get_rec.attribute4;
  	 x_oprn_act_out(i).attribute5 		:= get_rec.attribute5;
  	 x_oprn_act_out(i).attribute6 		:= get_rec.attribute6;
  	 x_oprn_act_out(i).attribute7 		:= get_rec.attribute7;
  	 x_oprn_act_out(i).attribute8 		:= get_rec.attribute8;
  	 x_oprn_act_out(i).attribute9 		:= get_rec.attribute9;
  	 x_oprn_act_out(i).attribute10 	:= get_rec.attribute10;
         x_oprn_act_out(i).attribute11 	:= get_rec.attribute11;
  	 x_oprn_act_out(i).attribute12 	:= get_rec.attribute12;
  	 x_oprn_act_out(i).attribute13 	:= get_rec.attribute13;
  	 x_oprn_act_out(i).attribute14 	:= get_rec.attribute14;
  	 x_oprn_act_out(i).attribute15 	:= get_rec.attribute15;
  	 x_oprn_act_out(i).attribute16 	:= get_rec.attribute16;
  	 x_oprn_act_out(i).attribute17 	:= get_rec.attribute17;
  	 x_oprn_act_out(i).attribute18 	:= get_rec.attribute18;
  	 x_oprn_act_out(i).attribute19 	:= get_rec.attribute19;
  	 x_oprn_act_out(i).attribute20 	:= get_rec.attribute20;
  	 x_oprn_act_out(i).attribute21 	:= get_rec.attribute21;
  	 x_oprn_act_out(i).attribute22 	:= get_rec.attribute22;
  	 x_oprn_act_out(i).attribute23 	:= get_rec.attribute23;
  	 x_oprn_act_out(i).attribute24 	:= get_rec.attribute24;
  	 x_oprn_act_out(i).attribute25 	:= get_rec.attribute25;
  	 x_oprn_act_out(i).attribute26 	:= get_rec.attribute26;
  	 x_oprn_act_out(i).attribute27 	:= get_rec.attribute27;
  	 x_oprn_act_out(i).attribute28 	:= get_rec.attribute28;
  	 x_oprn_act_out(i).attribute29 	:= get_rec.attribute29;
  	 x_oprn_act_out(i).attribute30 	:= get_rec.attribute30;

  END LOOP;

 IF i = 0 THEN
   RAISE fnd_api.g_exc_error;
 END IF;

 /*standard call to get msge cnt, and if cnt is 1, get mesg info*/
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_oprn_act_detl;

/*******************************************************************************
* Procedure get_oprn_resc_detl
*
* Procedure:- This returns the step, operation and activities, resources details for\
*             a given recipe based on the recipe_id passed to it.
*
*
* Author :Pawan Kumar
* History: Teresa Wong 7/17/2002 B2221515 Changed order by clause for cursor
*		       get_recp_resc to include 9th column (oprn_line_id).
*         RajaSekhar  11/14/2002 BUG#2621411 Added code to retrieve 'capacity_tolerance'
*                     and to assign the same to X_oprn_resc_rec of oprn_resc_tbl type.
* History
*  Rameshwar 09-DEC-2002 BUG#2686887
*  Modified  the order by clause of the cursor get_recp_resc.
*  Swapna - 26-SEP-2008 Bug No.7426185
*     Changed <AND conditon> in the cursor get_recp_resc, to verify whether p_organization_id
*     is NULL
*  Kishore - 20-Jan-2009 Bug No.7652625
*     Added Routingstep_id condition for the cursor get_recp_resc in the procedure, get_oprn_resc_detl.
*********************************************************************************/



PROCEDURE get_oprn_resc_detl
(       p_api_version           IN              NUMBER          ,
        p_init_msg_list         IN              VARCHAR2        ,
        p_recipe_id             IN              NUMBER          ,
        p_organization_id       IN              NUMBER          ,
        x_return_status         OUT NOCOPY      VARCHAR2        ,
        x_msg_count             OUT NOCOPY      NUMBER          ,
        x_msg_data              OUT NOCOPY      VARCHAR2        ,
        x_return_code           OUT NOCOPY      NUMBER          ,
        X_oprn_resc_rec         OUT NOCOPY      oprn_resc_tbl
)
   IS
 /*  local Variables */
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_recipe_id';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 i NUMBER := 0;


  /* BUG#2621411 RajaSekhar  Added capacity_tolerance field */
 --BEGIN BUG #2686887 Rameshwar
 --Modified  the order by clause  from 1,9 to  1,3 ,9.
CURSOR get_recp_resc IS
  SELECT r.recipe_id recipeid,
         d.routingstep_id , d.routingstep_no routing_step_no,
         o.oprn_id,o.oprn_no,o.oprn_vers, o.oprn_desc,
         a.activity,
         ror.oprn_line_id oprnline_id,ror.resources, ror.resource_usage, res.resource_count,
         ror.process_qty, res.prim_rsrc_ind, res.scale_type, res.cost_analysis_code,
         res.cost_cmpntcls_id, ror.usage_uom , res.offset_interval,
         ror.max_capacity, ror.min_capacity, m.capacity_um,m.capacity_constraint,
         m.capacity_tolerance,
         ror.process_um process_uom,
         /*
         ror.PROCESS_PARAMETER_1, ror.PROCESS_PARAMETER_2,
         ror.PROCESS_PARAMETER_3,ror.PROCESS_PARAMETER_4, ror.PROCESS_PARAMETER_5,
         */
         ror.text_code, ror.created_by,ror.last_updated_by,
         ror.last_update_date, ror.creation_date, ror.last_update_login,
         ror.attribute_category,
         ror.attribute1,  ror.attribute2, ror.attribute3, ror.attribute4,
         ror.attribute5, ror.attribute6, ror.attribute7,  ror.attribute8,
         ror.attribute9, ror.attribute10,  ror.attribute11,  ror.attribute12,
         ror.attribute13, ror.attribute14, ror.attribute15,  ror.attribute16,
         ror.attribute17, ror.attribute18, ror.attribute19,  ror.attribute20,
         ror.attribute21, ror.attribute22,ror.attribute23,  ror.attribute24,
         ror.attribute25, ror.attribute26, ror.attribute27,  ror.attribute28,
         ror.attribute29, ror.attribute30, 1 recipe_override
  FROM  gmd_recipes_b r, fm_rout_dtl d,gmd_operations_vl o,
        gmd_operation_activities a, gmd_recipe_orgn_resources ror,
        gmd_operation_resources res, cr_rsrc_mst_b m
  WHERE r.recipe_id = p_recipe_id
    AND d.routing_id = r.routing_id
    AND d.oprn_id = o.oprn_id
    AND a.oprn_id = d.oprn_id
    AND a.oprn_line_id = res.oprn_line_id
    AND d.routingstep_id = ror.routingstep_id  -- Bug No.7652625
    AND ror.resources = res.resources
    AND res.resources = m.resources
    AND ror.oprn_line_id = res.oprn_line_id
    AND ror.recipe_id = r.recipe_id
--    AND (ror.organization_id = p_organization_id  OR organization_id IS NULL)
    AND (ror.organization_id = p_organization_id  OR p_organization_id IS NULL) /*Bug#7426185*/

  UNION

  SELECT r.recipe_id recipeid,
         d.routingstep_id , d.routingstep_no routing_step_no,
         o.oprn_id,o.oprn_no,o.oprn_vers, o.oprn_desc,
         a.activity,
         res.oprn_line_id oprnline_id,res.resources, res.resource_usage, res.resource_count,
         res.process_qty, prim_rsrc_ind, scale_type, cost_analysis_code, res.cost_cmpntcls_id,
         res.resource_usage_uom usage_uom, res.offset_interval, nvl(l.max_capacity,m.max_capacity) max_capacity,
         nvl(l.min_capacity, m.min_capacity) min_capacity,
         nvl(l.capacity_um,m.capacity_um) capacity_um,
         nvl(l.capacity_constraint, m.capacity_constraint) capacity_constraint,
         nvl(l.capacity_tolerance, m.capacity_tolerance) capacity_tolerance,
         res.resource_process_uom process_uom,
         /*
         PROCESS_PARAMETER_1, PROCESS_PARAMETER_2,
         PROCESS_PARAMETER_3,PROCESS_PARAMETER_4, PROCESS_PARAMETER_5,
         */
         res.text_code, res.created_by,res.last_updated_by,
         res.last_update_date, res.creation_date, res.last_update_login,
         res.attribute_category,
         res.attribute1,  res.attribute2, res.attribute3, res.attribute4,
         res.attribute5, res.attribute6, res.attribute7,  res.attribute8,
         res.attribute9, res.attribute10,  res.attribute11,  res.attribute12,
         res.attribute13, res.attribute14, res.attribute15,  res.attribute16,
         res.attribute17, res.attribute18, res.attribute19,  res.attribute20,
         res.attribute21, res.attribute22,res.attribute23,  res.attribute24,
         res.attribute25, res.attribute26, res.attribute27,  res.attribute28,
         res.attribute29, res.attribute30, 0 recipe_override

FROM    gmd_recipes_b r, fm_rout_dtl d, gmd_operations_vl o,gmd_operation_activities a,
        gmd_operation_resources res, cr_rsrc_mst_b m, cr_rsrc_dtl l
WHERE   r.recipe_id = p_recipe_id
AND     d.routing_id = r.routing_id
AND     d.oprn_id = o.oprn_id
AND     o.oprn_id = a.oprn_id
AND     a.oprn_line_id = res.oprn_line_id
AND     m.resources = res.resources
AND     m.resources = l.resources (+)
AND     l.organization_id (+) = p_organization_id
AND     (res.oprn_line_id, res.resources)
         NOT IN ( SELECT oprn_line_id, resources
                    FROM gmd_recipe_orgn_resources ror
                   WHERE recipe_id = p_recipe_id
                     AND (p_organization_id IS NULL OR organization_id = p_organization_id)
                     AND d.routingstep_id = ror.routingstep_id)  -- Bug No.7652625
ORDER BY recipeid, routing_step_no, oprnline_id ;

--END BUG #2686887

BEGIN
 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* BUG#2621411 RajaSekhar  Added capacity_tolerance field */

  FOR get_rec IN get_recp_resc LOOP
    i := i + 1;

  	 x_oprn_resc_rec(i).recipe_id  		:= get_rec.recipeid ;
         x_oprn_resc_rec(i).routingstep_id      := get_rec.routingstep_id;
         x_oprn_resc_rec(i).routingstep_no      := get_rec.routing_step_no;
         x_oprn_resc_rec(i).oprn_id             := get_rec.oprn_id;
         x_oprn_resc_rec(i).oprn_no             := get_rec.oprn_no;
 	 x_oprn_resc_rec(i).oprn_vers           := get_rec.oprn_vers;
 	 x_oprn_resc_rec(i).oprn_desc           := get_rec.oprn_desc;
 	 x_oprn_resc_rec(i).activity            := get_rec.activity;
 	 x_oprn_resc_rec(i).oprn_line_id  	:= get_rec.oprnline_id ;
   	 x_oprn_resc_rec(i).resources  		:= get_rec.resources ;
   	 x_oprn_resc_rec(i).resource_usage  	:= get_rec.resource_usage ;
   	 x_oprn_resc_rec(i).resource_count  	:= get_rec.resource_count ;
 	 x_oprn_resc_rec(i).process_qty  	:= get_rec.process_qty  ;
 	 x_oprn_resc_rec(i).prim_rsrc_ind  	:= get_rec.prim_rsrc_ind  ;
 	 x_oprn_resc_rec(i).scale_type  	:= get_rec.scale_type  ;
 	 x_oprn_resc_rec(i).cost_analysis_code  := get_rec.cost_analysis_code ;
 	 x_oprn_resc_rec(i).cost_cmpntcls_id    := get_rec.cost_cmpntcls_id  ;
 	 x_oprn_resc_rec(i).capacity_constraint := get_rec.capacity_constraint  ;
 	 x_oprn_resc_rec(i).capacity_tolerance  := get_rec.capacity_tolerance  ;
 	 x_oprn_resc_rec(i).usage_um            := get_rec.usage_uom  ;
 	 x_oprn_resc_rec(i).offset_interval  	:= get_rec.offset_interval  ;
 	 x_oprn_resc_rec(i).min_capacity 	:= get_rec.min_capacity;
 	 x_oprn_resc_rec(i).max_capacity 	:= get_rec.max_capacity;
 	 x_oprn_resc_rec(i).capacity_uom  	:= get_rec.capacity_um;
 	 x_oprn_resc_rec(i).process_uom         := get_rec.process_uom;
 	 x_oprn_resc_rec(i).offset_interval  	:= get_rec.offset_interval  ;
 	 /*
 	 x_oprn_resc_rec(i).process_parameter_1	:= get_rec.process_parameter_1  ;
 	 x_oprn_resc_rec(i).process_parameter_2 := get_rec.process_parameter_2  ;
 	 x_oprn_resc_rec(i).process_parameter_3	:= get_rec.process_parameter_3  ;
 	 x_oprn_resc_rec(i).process_parameter_4	:= get_rec.process_parameter_4 ;
 	 x_oprn_resc_rec(i).process_parameter_5 := get_rec.process_parameter_5  ;
 	 */
 	 x_oprn_resc_rec(i).recipe_override     := get_rec.recipe_override;
 	 x_oprn_resc_rec(i).text_code       	:= get_rec.text_code        ;
       	 x_oprn_resc_rec(i).last_updated_by 	:= get_rec.last_updated_by ;
 	 x_oprn_resc_rec(i).created_by      	:= get_rec.created_by      ;
 	 x_oprn_resc_rec(i).last_update_date 	:= get_rec.last_update_date ;
 	 x_oprn_resc_rec(i).creation_date   	:= get_rec.creation_date     ;
 	 x_oprn_resc_rec(i).last_update_login 	:= get_rec.last_update_login;
 	 x_oprn_resc_rec(i).attribute_category 	:= get_rec.attribute_category;
         x_oprn_resc_rec(i).attribute1 		:= get_rec.attribute1;
  	 x_oprn_resc_rec(i).attribute2 		:= get_rec.attribute2;
  	 x_oprn_resc_rec(i).attribute3 		:= get_rec.attribute3;
  	 x_oprn_resc_rec(i).attribute4 		:= get_rec.attribute4;
  	 x_oprn_resc_rec(i).attribute5 		:= get_rec.attribute5;
  	 x_oprn_resc_rec(i).attribute6 		:= get_rec.attribute6;
  	 x_oprn_resc_rec(i).attribute7 		:= get_rec.attribute7;
  	 x_oprn_resc_rec(i).attribute8 		:= get_rec.attribute8;
  	 x_oprn_resc_rec(i).attribute9 		:= get_rec.attribute9;
  	 x_oprn_resc_rec(i).attribute10 	:= get_rec.attribute10;
         x_oprn_resc_rec(i).attribute11 	:= get_rec.attribute11;
  	 x_oprn_resc_rec(i).attribute12 	:= get_rec.attribute12;
  	 x_oprn_resc_rec(i).attribute13 	:= get_rec.attribute13;
  	 x_oprn_resc_rec(i).attribute14 	:= get_rec.attribute14;
  	 x_oprn_resc_rec(i).attribute15 	:= get_rec.attribute15;
  	 x_oprn_resc_rec(i).attribute16 	:= get_rec.attribute16;
  	 x_oprn_resc_rec(i).attribute17 	:= get_rec.attribute17;
  	 x_oprn_resc_rec(i).attribute18 	:= get_rec.attribute18;
  	 x_oprn_resc_rec(i).attribute19 	:= get_rec.attribute19;
  	 x_oprn_resc_rec(i).attribute20 	:= get_rec.attribute20;
  	 x_oprn_resc_rec(i).attribute21 	:= get_rec.attribute21;
  	 x_oprn_resc_rec(i).attribute22 	:= get_rec.attribute22;
  	 x_oprn_resc_rec(i).attribute23 	:= get_rec.attribute23;
  	 x_oprn_resc_rec(i).attribute24 	:= get_rec.attribute24;
  	 x_oprn_resc_rec(i).attribute25 	:= get_rec.attribute25;
  	 x_oprn_resc_rec(i).attribute26 	:= get_rec.attribute26;
  	 x_oprn_resc_rec(i).attribute27 	:= get_rec.attribute27;
  	 x_oprn_resc_rec(i).attribute28 	:= get_rec.attribute28;
  	 x_oprn_resc_rec(i).attribute29 	:= get_rec.attribute29;
  	 x_oprn_resc_rec(i).attribute30 	:= get_rec.attribute30;


  END LOOP;

 IF i = 0  THEN
   RAISE fnd_api.g_exc_error;
 END IF;  -- end if recipe_id not found

/* standard call to get msge cnt, and if cnt is 1, get mesg info */
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

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

  END get_oprn_resc_detl;


 PROCEDURE get_recipe_process_param_detl
  (     p_api_version              IN           NUMBER                  ,
        p_init_msg_list            IN           VARCHAR2                ,
        p_recipe_id                IN           NUMBER                  ,
        p_organization_id          IN           NUMBER                  ,
        x_return_status            OUT NOCOPY   VARCHAR2                ,
        x_msg_count                OUT NOCOPY   NUMBER                  ,
        x_msg_data                 OUT NOCOPY   VARCHAR2                ,
        X_recp_resc_proc_param_tbl OUT NOCOPY   recp_resc_proc_param_tbl
 ) IS

 CURSOR Cur_get_recp_rsrc IS
   SELECT dtl.routingstep_id, dtl.routingstep_no, act.oprn_line_id, res.resources
     FROM gmd_recipes_b rcp, fm_rout_dtl dtl,
          gmd_operation_activities act , gmd_operation_resources res
    WHERE rcp.recipe_id = p_recipe_id
      AND dtl.routing_id = rcp.routing_id
      AND dtl.oprn_id = act.oprn_id
      AND act.oprn_line_id = res.oprn_line_id;


/* Parameters at the generic resource level */
 CURSOR Cur_get_gen_rsrc (V_resources VARCHAR2) IS
   SELECT p.parameter_id, parameter_name, parameter_description,
          units, r.target_value, r.minimum_value, r.maximum_value,p.parameter_type,r.sequence_no,
          r.created_by, r.creation_date, r.last_updated_by, r.last_update_date, r.last_update_login
     FROM gmp_resource_parameters r, gmp_process_parameters p
    WHERE p.parameter_id = r.parameter_id
      AND r.resources = V_resources
 ORDER BY r.sequence_no;

/* Parameters at the recipe resource level */
CURSOR Cur_get_oprn_rsrc (V_oprn_line_id NUMBER,
                          V_resources VARCHAR2, V_parameter_id NUMBER) IS
  SELECT *
  FROM   gmd_oprn_process_parameters
  WHERE  oprn_line_id = V_oprn_line_id
  AND    resources = V_resources
  AND    parameter_id = V_parameter_id;

l_oprn_rec Cur_get_oprn_rsrc%ROWTYPE;

/* Parameters at the operation resource level */
CURSOR Cur_get_rcp_rsrc (V_routingstep_id NUMBER, V_oprn_line_id NUMBER,
                         V_resources VARCHAR2, V_parameter_id NUMBER) IS
  SELECT *
  FROM   gmd_recipe_process_parameters
  WHERE  recipe_id = p_recipe_id
  AND    organization_id = p_organization_id
  AND    routingstep_id = V_routingstep_id
  AND    oprn_line_id = V_oprn_line_id
  AND    resources = V_resources
  AND    parameter_id = V_parameter_id;

l_rcp_rec Cur_get_rcp_rsrc%ROWTYPE;

    /* Parameters at the plant resource level */
    CURSOR Cur_get_plnt_rsrc (V_resources VARCHAR2, V_parameter_id NUMBER) IS
      SELECT p.*
      FROM   gmp_plant_rsrc_parameters p, cr_rsrc_dtl c
      WHERE  p.resource_id = c.resource_id
      AND    organization_id = p_organization_id
      AND    resources = V_resources
      AND    parameter_id = V_parameter_id;

    l_plnt_rec Cur_get_plnt_rsrc%ROWTYPE;

    X_row                       NUMBER DEFAULT 0;
    X_found                     NUMBER(5) DEFAULT 0;
    X_override                  NUMBER(5) DEFAULT 0;
    X_target_value	        gmd_recipe_process_parameters.target_value%type	        ;
    X_minimum_value	        NUMBER						        ;
    X_maximum_value             NUMBER						        ;
    X_created_by                gmd_recipe_process_parameters.created_by%type	        ;
    X_last_updated_by           gmd_recipe_process_parameters.last_updated_by%type      ;
    X_last_update_date          gmd_recipe_process_parameters.last_update_date%type     ;
    X_creation_date             gmd_recipe_process_parameters.creation_date%type	;
    X_last_update_login         gmd_recipe_process_parameters.last_update_login%type    ;
  BEGIN
    FOR l_rcp_res_rec IN Cur_get_recp_rsrc LOOP
      FOR l_rec IN Cur_get_gen_rsrc (l_rcp_res_rec.resources) LOOP

        X_target_value          := l_rec.target_value;
        X_minimum_value         := l_rec.minimum_value;
        X_maximum_value         := l_rec.maximum_value;
        X_created_by            := l_rec.created_by;
        X_last_updated_by       := l_rec.last_updated_by;
        X_creation_date         := l_rec.creation_date;
        X_last_update_date      := l_rec.last_update_date;
        X_last_update_login     := l_rec.last_update_login;

        /* Now let us check for overrides at recipe level */
        IF p_organization_id IS NOT NULL THEN
          OPEN Cur_get_rcp_rsrc (l_rcp_res_rec.routingstep_id, l_rcp_res_rec.oprn_line_id,
                                 l_rcp_res_rec.resources, l_rec.parameter_id);
          FETCH Cur_get_rcp_rsrc INTO l_rcp_rec;
          IF Cur_get_rcp_rsrc%FOUND THEN
            X_found     := 1;
            X_override  := 1;
            X_target_value      := l_rcp_rec.target_value;
            X_minimum_value     := l_rcp_rec.minimum_value;
            X_maximum_value     := l_rcp_rec.maximum_value;
            X_created_by        := l_rcp_rec.created_by;
            X_last_updated_by   := l_rcp_rec.last_updated_by;
            X_creation_date     := l_rcp_rec.creation_date;
            X_last_update_date  := l_rcp_rec.last_update_date;
            X_last_update_login := l_rcp_rec.last_update_login;
          END IF;
          CLOSE Cur_get_rcp_rsrc;
        END IF; /* IF p_orgn_code IS NOT NULL */

        /* Now let us check for overrides at operation level */
        IF X_found = 0 THEN
          OPEN Cur_get_oprn_rsrc (l_rcp_res_rec.oprn_line_id,
                                  l_rcp_res_rec.resources, l_rec.parameter_id);
          FETCH Cur_get_oprn_rsrc INTO l_oprn_rec;
          IF Cur_get_oprn_rsrc%FOUND THEN
            X_found             := 1;
            X_target_value      := l_oprn_rec.target_value;
            X_minimum_value     := l_oprn_rec.minimum_value;
            X_maximum_value     := l_oprn_rec.maximum_value;
            X_created_by        := l_oprn_rec.created_by;
            X_last_updated_by   := l_oprn_rec.last_updated_by;
            X_creation_date     := l_oprn_rec.creation_date;
            X_last_update_date  := l_oprn_rec.last_update_date;
            X_last_update_login := l_oprn_rec.last_update_login;
          END IF;
          CLOSE Cur_get_oprn_rsrc;
        END IF; /* IF X_found = 0 */

        /* Now let us check for overrides at plant resource level */
        IF X_found = 0 AND
           p_organization_id IS NOT NULL THEN
          OPEN Cur_get_plnt_rsrc (l_rcp_res_rec.resources, l_rec.parameter_id);
          FETCH Cur_get_plnt_rsrc INTO l_plnt_rec;
          IF Cur_get_plnt_rsrc%FOUND THEN
            X_found             := 1;
            X_target_value      := l_plnt_rec.target_value;
            X_minimum_value     := l_plnt_rec.minimum_value;
            X_maximum_value     := l_plnt_rec.maximum_value;
            X_created_by        := l_plnt_rec.created_by;
            X_last_updated_by   := l_plnt_rec.last_updated_by;
            X_creation_date     := l_plnt_rec.creation_date;
            X_last_update_date  := l_plnt_rec.last_update_date;
            X_last_update_login := l_plnt_rec.last_update_login;
          END IF;
          CLOSE Cur_get_plnt_rsrc;
        END IF; /* IF X_found = 0 */

        X_row := X_row + 1;

        X_recp_resc_proc_param_tbl(X_row).recipe_id             := p_recipe_id;
        X_recp_resc_proc_param_tbl(X_row).routingstep_id        := l_rcp_res_rec.routingstep_id;
        X_recp_resc_proc_param_tbl(X_row).routingstep_no        := l_rcp_res_rec.routingstep_no;
        X_recp_resc_proc_param_tbl(X_row).oprn_line_id          := l_rcp_res_rec.oprn_line_id;
        X_recp_resc_proc_param_tbl(X_row).resources             := l_rcp_res_rec.resources;
        X_recp_resc_proc_param_tbl(X_row).parameter_id          := l_rec.parameter_id;
        X_recp_resc_proc_param_tbl(X_row).parameter_name        := l_rec.parameter_name;
        X_recp_resc_proc_param_tbl(X_row).parameter_description := l_rec.parameter_description;
        X_recp_resc_proc_param_tbl(X_row).units                 := l_rec.units;
        X_recp_resc_proc_param_tbl(X_row).target_value          := X_target_value;
        X_recp_resc_proc_param_tbl(X_row).minimum_value         := X_minimum_value;
        X_recp_resc_proc_param_tbl(X_row).maximum_value         := X_maximum_value;
        X_recp_resc_proc_param_tbl(X_row).parameter_type        := l_rec.parameter_type;
        X_recp_resc_proc_param_tbl(X_row).sequence_no           := l_rec.sequence_no;
        X_recp_resc_proc_param_tbl(X_row).created_by            := X_created_by;
        X_recp_resc_proc_param_tbl(X_row).creation_date         := X_creation_date;
        X_recp_resc_proc_param_tbl(X_row).last_updated_by       := X_last_updated_by;
        X_recp_resc_proc_param_tbl(X_row).last_update_date      := X_last_update_date;
        X_recp_resc_proc_param_tbl(X_row).last_update_login     := X_last_update_login;
        X_recp_resc_proc_param_tbl(X_row).recipe_override       := X_override;
        X_found := 0;
      END LOOP; /* FOR l_rec IN Cur_get_gen_rsrc */
    END LOOP; /* FOR l_rcp_res_rec IN Cur_get_recp_rsrc */

  END get_recipe_process_param_detl;

/*======================================================================
--  PROCEDURE :
--   get_proc_param_desc
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    description for a given process parameter.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_routing_no (100, x_parameter_desc);
--
--===================================================================== */
PROCEDURE get_proc_param_desc(p_parameter_id IN NUMBER, x_parameter_desc OUT NOCOPY VARCHAR2) IS
 CURSOR get_proc_param_desc IS
   SELECT parameter_description
     FROM gmp_process_parameters_tl
    WHERE parameter_id = p_parameter_id
      AND language = USERENV('LANG');
BEGIN
  OPEN  get_proc_param_desc;
  FETCH get_proc_param_desc INTO x_parameter_desc;
  CLOSE get_proc_param_desc;
END get_proc_param_desc;

/*======================================================================
--  PROCEDURE :
--   get_proc_param_units
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the
--    units for a given process parameter.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_proc_param_units (100, X_units);
--
--===================================================================== */
PROCEDURE get_proc_param_units(p_parameter_id IN NUMBER, x_units OUT NOCOPY VARCHAR2) IS
CURSOR get_proc_param_units IS
 SELECT units
   FROM gmp_process_parameters_b
  WHERE parameter_id = p_parameter_id;
BEGIN
  OPEN  get_proc_param_units;
  FETCH get_proc_param_units INTO x_units;
  CLOSE get_proc_param_units;
END get_proc_param_units;

/*======================================================================
--  PROCEDURE :
--    fetch_contiguous_ind
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the contiguous indicator
--    value set at Recipe - Orgn level or at the Recipe level in order based on the
--    i/p parameters
--
--  HISTORY
--    Sriram.S  21Feb2005  Contiguous Indicator ME
--
--  SYNOPSIS:
--    fetch_contiguous_ind (p_recipe_id, p_orgn_id, p_recipe_validity_rule_id,
--    x_contiguous_ind, x_return_status);
--
--===================================================================== */

PROCEDURE FETCH_CONTIGUOUS_IND (
         p_recipe_id                    IN            	 NUMBER
        ,p_orgn_id                      IN             	 NUMBER
        ,p_recipe_validity_rule_id      IN             	 NUMBER
        ,x_contiguous_ind               OUT NOCOPY       NUMBER
        ,x_return_status                OUT NOCOPY       VARCHAR2) IS


-- Cursor to get recipe_id and organization
CURSOR get_recp_orgn_id IS
        SELECT recipe_id, organization_id
          FROM gmd_recipe_validity_rules
         WHERE recipe_validity_rule_id = p_recipe_validity_rule_id;

-- Cursor to fetch contiguous indicator at recp-orgn level
CURSOR get_recp_orgn_cont_ind( l_recp_id NUMBER, l_orgn_id NUMBER) IS
        SELECT contiguous_ind
          FROM gmd_recipe_process_loss
         WHERE recipe_id       = l_recp_id
           AND organization_id = l_orgn_id;

-- Cursor to fetch contiguous indicator at recipe level
CURSOR get_recp_cont_ind( l_recp_id NUMBER) IS
        SELECT contiguous_ind
          FROM gmd_recipes_b
         WHERE recipe_id = l_recp_id;

l_recipe_id             NUMBER;
l_orgn_id       	NUMBER;
l_cont_ind              NUMBER;

INVALID_DATA            EXCEPTION;

BEGIN

/* Set return status to success initially */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Chk. whether the recipe id or the validity rule id is passed */
IF (p_recipe_id IS NULL AND p_recipe_validity_rule_id IS NULL) THEN
        RAISE INVALID_DATA;
END IF;

-- If Validity Rule id is passed, fetch the corresponding recipe_id and orgn_id
IF p_recipe_validity_rule_id IS NOT NULL THEN
        OPEN get_recp_orgn_id;
        FETCH get_recp_orgn_id INTO l_recipe_id, l_orgn_id;
        IF get_recp_orgn_id%NOTFOUND THEN
                CLOSE get_recp_orgn_id;
                RAISE INVALID_DATA;
        END IF;
        CLOSE get_recp_orgn_id;

        -- If l_orgn_id is NULL (Global Validity rule) and if p_orgn_id is passed
        -- then use p_orgn_id to retrieve contiguous ind.
        IF (l_orgn_id IS NULL AND p_orgn_id IS NOT NULL) THEN
        l_orgn_id := p_orgn_id;
        END IF;
ELSE
-- If Validity Rule id is not passed, use the recipe and orgn id i/p parameters
        l_recipe_id := p_recipe_id;
        l_orgn_id   := p_orgn_id;
END IF;

-- Verify that recipe id is NOT NULL
IF (l_recipe_id IS NULL) THEN
        RAISE INVALID_DATA;
END IF;

IF (l_recipe_id IS NOT NULL AND l_orgn_id IS NOT NULL) THEN
        -- Try to fetch the contiguous ind set at the recipe - orgn level
        OPEN  get_recp_orgn_cont_ind(l_recipe_id, l_orgn_id);
        FETCH get_recp_orgn_cont_ind INTO l_cont_ind;
        CLOSE get_recp_orgn_cont_ind;
END IF;

IF (l_cont_ind IS NULL) THEN
        -- Cont Ind. value was not found at recipe-orgn level. Try fetching at recipe level.
        OPEN  get_recp_cont_ind(l_recipe_id);
        FETCH get_recp_cont_ind INTO l_cont_ind;
        CLOSE get_recp_cont_ind;
END IF;

IF (l_cont_ind IS NULL) THEN
        -- Cont Ind. value was not found at recipe-orgn level and recipe levels.
        x_contiguous_ind := 0;
ELSE
        -- Assign cont ind. to the OUT parameter
        x_contiguous_ind := l_cont_ind;
END IF;

EXCEPTION

WHEN INVALID_DATA THEN
        x_contiguous_ind := NULL;
        fnd_message.set_name ('GMI', 'GMI_MISSING');
        fnd_message.set_token ('MISSING', 'RECIPE_ID');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;

END FETCH_CONTIGUOUS_IND;

/*======================================================================
--  PROCEDURE :
--    fetch_enhanced_pi_ind
--
--  DESCRIPTION:
--    This PL/SQL procedure  is responsible for getting the Enhanced PI Indicator
--    value set at Recipe header level
--
--  HISTORY
--    Sriram.S  03MayFeb2005  GMD-GMO Integration
--
--  SYNOPSIS:
--    fetch_enhanced_pi_ind (p_recipe_id, p_recipe_validity_rule_id,
--    x_enhanced_pi_ind, x_return_status);
--
--===================================================================== */

PROCEDURE FETCH_ENHANCED_PI_IND (
         p_recipe_id                    IN            	NUMBER
        ,p_recipe_validity_rule_id      IN             	NUMBER
        ,x_enhanced_pi_ind              OUT NOCOPY      VARCHAR2
        ,x_return_status                OUT NOCOPY	VARCHAR2) IS

-- Cursor to get recipe_id from validity_rule_id
CURSOR get_recp_id IS
        SELECT recipe_id
          FROM gmd_recipe_validity_rules
         WHERE recipe_validity_rule_id = p_recipe_validity_rule_id;

-- Cursor to fetch enhanced PI flag at recipe level
CURSOR get_pi_flag( l_recp_id NUMBER) IS
        SELECT enhanced_pi_ind
          FROM gmd_recipes_b
         WHERE recipe_id = l_recp_id;

l_recipe_id             NUMBER;
l_pi_ind                VARCHAR2(1);

INVALID_DATA            EXCEPTION;

BEGIN

/* Set return status to success initially */
x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Chk. whether the recipe id or the validity rule id is passed */
IF (p_recipe_id IS NULL AND p_recipe_validity_rule_id IS NULL) THEN
        RAISE INVALID_DATA;
END IF;

-- If Validity Rule id is passed, fetch the corresponding recipe_id
IF p_recipe_validity_rule_id IS NOT NULL THEN
        OPEN get_recp_id;
        FETCH get_recp_id INTO l_recipe_id;
        CLOSE get_recp_id;
ELSE
-- If Validity Rule id is not passed, use the recipe id i/p parameter
        l_recipe_id := p_recipe_id;
END IF;

-- Verify that recipe id is NOT NULL
IF (l_recipe_id IS NULL) THEN
        RAISE INVALID_DATA;
END IF;

-- Get the PI flag for the recipe id
OPEN  get_pi_flag(l_recipe_id);
FETCH get_pi_flag INTO l_pi_ind;
CLOSE get_pi_flag;

IF (l_pi_ind IS NULL) THEN
        x_enhanced_pi_ind := 'N';
ELSE
        -- Assign PI indicator value to the OUT parameter
        x_enhanced_pi_ind := l_pi_ind;
END IF;

EXCEPTION

WHEN INVALID_DATA THEN
        x_enhanced_pi_ind := NULL;
        fnd_message.set_name ('GMI', 'GMI_MISSING');
        fnd_message.set_token ('MISSING', 'RECIPE_ID');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;

END FETCH_ENHANCED_PI_IND;

END GMD_RECIPE_FETCH_PUB ;

/
