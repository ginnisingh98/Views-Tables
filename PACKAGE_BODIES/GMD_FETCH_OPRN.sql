--------------------------------------------------------
--  DDL for Package Body GMD_FETCH_OPRN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FETCH_OPRN" AS
/* $Header: GMDPOPNB.pls 120.1 2006/02/01 10:10:54 txdaniel noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'gmd_fetch_oprn';
PROCEDURE fetch_oprn
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN        NUMBER                        ,
        p_orgn_code             IN      VARCHAR2                        ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER                         ,
        X_oprn_act_out          OUT NOCOPY      gmd_recipe_fetch_pub.oprn_act_tbl,
        X_oprn_resc_rec         OUT NOCOPY      gmd_recipe_fetch_pub.oprn_resc_tbl,
        X_oprn_resc_proc_param_tbl   OUT NOCOPY     gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
) IS

 CURSOR Cur_validate_record IS
    SELECT 1
    FROM   gmd_operations_vl
    WHERE  oprn_id = p_oprn_id;
 X_count NUMBER;
 INVALID_OPERATION           EXCEPTION;
-- Bug #2415756 (JKB) Added cursor above.

/*  local Variables */
 l_api_name      VARCHAR2(30) := 'fetch_oprn';
 l_api_version    NUMBER  := 1.0;
 i NUMBER := 0;
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    OPEN Cur_validate_record;
    FETCH Cur_validate_record INTO X_count;
    IF (Cur_validate_record%NOTFOUND) THEN
      CLOSE Cur_validate_record;
      RAISE INVALID_OPERATION;
    END IF;
    CLOSE Cur_validate_record;
-- Bug #2415756 (JKB) Added validation above.


    gmd_fetch_oprn.get_oprn_act(p_api_version => p_api_version,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_oprn_id => p_oprn_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_return_code => x_return_code,
                                x_oprn_act_out => x_oprn_act_out);

    IF X_return_status = FND_API.g_ret_sts_success THEN
      gmd_fetch_oprn.get_oprn_resc(p_api_version => p_api_version,
                                 p_init_msg_list => FND_API.G_FALSE,
                                 p_oprn_id => p_oprn_id,
                                 p_orgn_code => p_orgn_code,
                                 x_return_status => x_return_status,
                                 x_msg_count => x_msg_count,
                                 x_msg_data => x_msg_data,
                                 x_return_code => x_return_code,
                                 x_oprn_resc_rec => x_oprn_resc_rec,
                                 X_oprn_resc_proc_param_tbl => X_oprn_resc_proc_param_tbl);
    END IF;
    /*standard call to get msge cnt, and if cnt is 1, get mesg info*/
    FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN INVALID_OPERATION THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'FM_INVOPRN');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
  END fetch_oprn;


 PROCEDURE get_oprn_act
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN       NUMBER                         ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        x_return_code           OUT NOCOPY       NUMBER                         ,
        x_oprn_act_out          OUT NOCOPY      gmd_recipe_fetch_pub.oprn_act_tbl
) IS
 /*  local Variables */
 l_api_name      VARCHAR2(30) := 'get_oprn_act';
 l_api_version    NUMBER  := 1.0;
 i NUMBER := 0;

 CURSOR get_oprn_act1 IS
  select  o.oprn_no, o.oprn_desc, o.oprn_vers,o.oprn_id,
         a.activity,fm.activity_desc, a.oprn_line_id, a.activity_factor,a.offset_interval,
         a.sequence_dependent_ind, a.break_ind, a.max_break, a.text_code, a.creation_date,
         o.minimum_transfer_qty, a.material_ind, a.created_by,a.last_updated_by,
         a.last_update_date, a.last_update_login, a.attribute_category,
         a.attribute1,  a.attribute2, a.attribute3,  a.attribute4,
         a.attribute5, a.attribute6, a.attribute7,  a.attribute8,
         a.attribute9, a.attribute10, a.attribute11,  a.attribute12,
         a.attribute13, a.attribute14, a.attribute15,  a.attribute16,
         a.attribute17, a.attribute18, a.attribute19,  a.attribute20,
         a.attribute21, a.attribute22, a.attribute23,  a.attribute24,
         a.attribute25, a.attribute26, a.attribute27,  a.attribute28,
         a.attribute29, a.attribute30
  from     gmd_operations_vl o, gmd_operation_activities a, fm_actv_mst fm
  where   a.oprn_id = p_oprn_id
     and  a.oprn_id = o.oprn_id
     and  a.activity = fm.activity

  ORDER BY a.oprn_line_id;

begin

 IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
            l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;
 IF FND_API.to_Boolean(p_init_msg_list) THEN
   FND_MSG_PUB.initialize;
 END IF;

  For get_rec IN get_oprn_act1 LOOP
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    i := i + 1;

         x_oprn_act_out(i).oprn_no               := get_rec.oprn_no   		;
         x_oprn_act_out(i).oprn_desc             := get_rec.oprn_desc		;
         x_oprn_act_out(i).oprn_vers             := get_rec.oprn_vers 		;
         x_oprn_act_out(i).oprn_id             	 := get_rec.oprn_id		;
         x_oprn_act_out(i).activity              := get_rec.activity 		;
         x_oprn_act_out(i).activity_desc         := get_rec.activity_desc  	;
   	 x_oprn_act_out(i).oprn_line_id    	 := get_rec.oprn_line_id 	;
   	 x_oprn_act_out(i).activity_factor       := get_rec.activity_factor	;
   	 x_oprn_act_out(i).sequence_dependent_ind       := get_rec.sequence_dependent_ind	;
   	 x_oprn_act_out(i).offset_interval       := get_rec.offset_interval	;
         x_oprn_act_out(i).break_ind             := get_rec.break_ind	;
         x_oprn_act_out(i).max_break             := get_rec.max_break	;
         x_oprn_act_out(i).minimum_transfer_qty  := get_rec.minimum_transfer_qty	;
         x_oprn_act_out(i).material_ind             := get_rec.material_ind	;
         x_oprn_act_out(i).text_code       	 := get_rec.text_code       	;
         x_oprn_act_out(i).creation_date   	 := get_rec.creation_date  	;
         x_oprn_act_out(i).created_by      	 := get_rec.created_by    	;
       	 x_oprn_act_out(i).last_updated_by 	:= get_rec.last_updated_by 	;
 	 x_oprn_act_out(i).last_update_date 	:= get_rec.last_update_date 	;
 	 x_oprn_act_out(i).last_update_login 	:= get_rec.last_update_login	;
 	 x_oprn_act_out(i).attribute_category 	:= get_rec.attribute_category	;
         x_oprn_act_out(i).attribute1 		:= get_rec.attribute1		;
  	 x_oprn_act_out(i).attribute2 		:= get_rec.attribute2		;
  	 x_oprn_act_out(i).attribute3 		:= get_rec.attribute3		;
  	 x_oprn_act_out(i).attribute4 		:= get_rec.attribute4		;
  	 x_oprn_act_out(i).attribute5 		:= get_rec.attribute5		;
  	 x_oprn_act_out(i).attribute6 		:= get_rec.attribute6		;
  	 x_oprn_act_out(i).attribute7 		:= get_rec.attribute7		;
  	 x_oprn_act_out(i).attribute8 		:= get_rec.attribute8		;
  	 x_oprn_act_out(i).attribute9 		:= get_rec.attribute9		;
  	 x_oprn_act_out(i).attribute10 		:= get_rec.attribute10		;
         x_oprn_act_out(i).attribute11 		:= get_rec.attribute11		;
  	 x_oprn_act_out(i).attribute12 		:= get_rec.attribute12		;
  	 x_oprn_act_out(i).attribute13 		:= get_rec.attribute13		;
  	 x_oprn_act_out(i).attribute14 		:= get_rec.attribute14		;
  	 x_oprn_act_out(i).attribute15 		:= get_rec.attribute15		;
  	 x_oprn_act_out(i).attribute16 		:= get_rec.attribute16		;
  	 x_oprn_act_out(i).attribute17 		:= get_rec.attribute17		;
  	 x_oprn_act_out(i).attribute18 		:= get_rec.attribute18		;
  	 x_oprn_act_out(i).attribute19 		:= get_rec.attribute19		;
  	 x_oprn_act_out(i).attribute20 		:= get_rec.attribute20		;
  	 x_oprn_act_out(i).attribute21 		:= get_rec.attribute21		;
  	 x_oprn_act_out(i).attribute22 		:= get_rec.attribute22		;
  	 x_oprn_act_out(i).attribute23 		:= get_rec.attribute23		;
  	 x_oprn_act_out(i).attribute24 		:= get_rec.attribute24		;
  	 x_oprn_act_out(i).attribute25 		:= get_rec.attribute25		;
  	 x_oprn_act_out(i).attribute26 		:= get_rec.attribute26		;
  	 x_oprn_act_out(i).attribute27 		:= get_rec.attribute27		;
  	 x_oprn_act_out(i).attribute28 		:= get_rec.attribute28		;
  	 x_oprn_act_out(i).attribute29 		:= get_rec.attribute29		;
  	 x_oprn_act_out(i).attribute30 		:= get_rec.attribute30		;

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

   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  END get_oprn_act;




PROCEDURE get_oprn_resc
(       p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_id               IN      NUMBER                          ,
        p_orgn_code             IN      VARCHAR2                        ,
        x_return_status         OUT NOCOPY     VARCHAR2                        ,
        x_msg_count             OUT NOCOPY     NUMBER                          ,
        x_msg_data              OUT NOCOPY     VARCHAR2                        ,
        x_return_code           OUT NOCOPY      NUMBER                         ,
        X_oprn_resc_rec         OUT NOCOPY   gmd_recipe_fetch_pub.oprn_resc_tbl,
        X_oprn_resc_proc_param_tbl   OUT NOCOPY    gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
) IS

 /*  local Variables */
 l_api_name       CONSTANT  VARCHAR2(30) := 'get_oprn_resc';
 l_api_version    CONSTANT  NUMBER  := 1.0;
 l_resc_param_tbl gmd_recipe_fetch_pub.recp_resc_proc_param_tbl;
 X_row   NUMBER DEFAULT 0;
 i NUMBER := 0;

  /* BUG#2621411 RajaSekhar  Added capacity_tolerance field */

  CURSOR get_oprn_resc IS
  select
         o.oprn_id,o.oprn_no,o.oprn_vers, o.oprn_desc,
         a.activity,
         res.oprn_line_id,res.resources, res.resource_usage, res.resource_count,
         res.process_qty, prim_rsrc_ind, scale_type, cost_analysis_code, res.cost_cmpntcls_id,
         res.resource_usage_uom, res.offset_interval, nvl(l.max_capacity,m.max_capacity) max_capacity,
         nvl(l.min_capacity,m.min_capacity) min_capacity,
         nvl(l.capacity_um,m.capacity_um) capacity_uom,
         nvl(l.capacity_constraint,m.capacity_constraint) capacity_constraint,
         nvl(l.capacity_tolerance, m.capacity_tolerance) capacity_tolerance,
         res.resource_process_uom, PROCESS_PARAMETER_1, PROCESS_PARAMETER_2,PROCESS_PARAMETER_3,
         PROCESS_PARAMETER_4, PROCESS_PARAMETER_5, res.text_code, res.created_by,
         res.last_updated_by,  res.last_update_date, res.creation_date, res.last_update_login,
         res.attribute_category,
         res.attribute1,  res.attribute2, res.attribute3, res.attribute4,
         res.attribute5, res.attribute6, res.attribute7,  res.attribute8,
         res.attribute9, res.attribute10,  res.attribute11,  res.attribute12,
         res.attribute13, res.attribute14, res.attribute15,  res.attribute16,
         res.attribute17, res.attribute18, res.attribute19,  res.attribute20,
         res.attribute21, res.attribute22,res.attribute23,  res.attribute24,
         res.attribute25, res.attribute26, res.attribute27,  res.attribute28,
         res.attribute29, res.attribute30
FROM    gmd_operations_vl o,gmd_operation_activities a, gmd_operation_resources res,
         cr_rsrc_mst m, cr_rsrc_dtl l
where   a.oprn_id = p_oprn_id
 and    o.oprn_id = a.oprn_id
and     a.oprn_line_id = res.oprn_line_id
and     m.resources = res.resources
AND     m.resources = l.resources (+)
AND    l.orgn_code (+) = p_orgn_code
    ORDER BY res.oprn_line_id     ;


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

  For get_rec IN get_oprn_resc LOOP
    i := i + 1;

  	 x_oprn_resc_rec(i).oprn_id             := get_rec.oprn_id		;
         x_oprn_resc_rec(i).oprn_no             := get_rec.oprn_no		;
 	 x_oprn_resc_rec(i).oprn_vers           := get_rec.oprn_vers		;
 	 x_oprn_resc_rec(i).oprn_desc           := get_rec.oprn_desc		;
 	 x_oprn_resc_rec(i).activity            := get_rec.activity		;
 	 x_oprn_resc_rec(i).oprn_line_id  	:= get_rec.oprn_line_id		;
   	 x_oprn_resc_rec(i).resources  		:= get_rec.resources 		;
   	 x_oprn_resc_rec(i).resource_usage  	:= get_rec.resource_usage 	;
   	 x_oprn_resc_rec(i).resource_count  	:= get_rec.resource_count 	;
 	 x_oprn_resc_rec(i).process_qty  	:= get_rec.process_qty  	;
 	 x_oprn_resc_rec(i).prim_rsrc_ind  	:= get_rec.prim_rsrc_ind 	;
 	 x_oprn_resc_rec(i).scale_type  	:= get_rec.scale_type  		;
 	 x_oprn_resc_rec(i).cost_analysis_code  := get_rec.cost_analysis_code 	;
 	 x_oprn_resc_rec(i).cost_cmpntcls_id    := get_rec.cost_cmpntcls_id  	;
 	 x_oprn_resc_rec(i).usage_um  		:= get_rec.resource_usage_uom	;
 	 x_oprn_resc_rec(i).offset_interval  	:= get_rec.offset_interval	;
 	 x_oprn_resc_rec(i).min_capacity 	:= get_rec.min_capacity		;
 	 x_oprn_resc_rec(i).max_capacity 	:= get_rec.max_capacity		;
 	 x_oprn_resc_rec(i).capacity_uom  	:= get_rec.capacity_uom		;
 	 x_oprn_resc_rec(i).capacity_constraint := get_rec.capacity_constraint  ;
 	 x_oprn_resc_rec(i).capacity_tolerance := get_rec.capacity_tolerance    ;
 	 x_oprn_resc_rec(i).process_uom  	:= get_rec.resource_process_uom ;
 	 x_oprn_resc_rec(i).offset_interval  	:= get_rec.offset_interval	;
 	 x_oprn_resc_rec(i).process_parameter_1	:= get_rec.process_parameter_1  ;
 	 x_oprn_resc_rec(i).process_parameter_2 := get_rec.process_parameter_2  ;
 	 x_oprn_resc_rec(i).process_parameter_3	:= get_rec.process_parameter_3  ;
 	 x_oprn_resc_rec(i).process_parameter_4	:= get_rec.process_parameter_4	;
 	 x_oprn_resc_rec(i).process_parameter_5 := get_rec.process_parameter_5  ;
 	 x_oprn_resc_rec(i).text_code       	:= get_rec.text_code     	;
       	 x_oprn_resc_rec(i).last_updated_by 	:= get_rec.last_updated_by	;
 	 x_oprn_resc_rec(i).created_by      	:= get_rec.created_by     	;
 	 x_oprn_resc_rec(i).last_update_date 	:= get_rec.last_update_date 	;
 	 x_oprn_resc_rec(i).creation_date   	:= get_rec.creation_date        ;
 	 x_oprn_resc_rec(i).last_update_login 	:= get_rec.last_update_login	;
 	 x_oprn_resc_rec(i).attribute_category 	:= get_rec.attribute_category	;
         x_oprn_resc_rec(i).attribute1 		:= get_rec.attribute1		;
  	 x_oprn_resc_rec(i).attribute2 		:= get_rec.attribute2		;
  	 x_oprn_resc_rec(i).attribute3 		:= get_rec.attribute3		;
  	 x_oprn_resc_rec(i).attribute4 		:= get_rec.attribute4		;
  	 x_oprn_resc_rec(i).attribute5 		:= get_rec.attribute5		;
  	 x_oprn_resc_rec(i).attribute6 		:= get_rec.attribute6		;
  	 x_oprn_resc_rec(i).attribute7 		:= get_rec.attribute7		;
  	 x_oprn_resc_rec(i).attribute8 		:= get_rec.attribute8		;
  	 x_oprn_resc_rec(i).attribute9 		:= get_rec.attribute9		;
  	 x_oprn_resc_rec(i).attribute10 	:= get_rec.attribute10		;
         x_oprn_resc_rec(i).attribute11 	:= get_rec.attribute11		;
  	 x_oprn_resc_rec(i).attribute12 	:= get_rec.attribute12		;
  	 x_oprn_resc_rec(i).attribute13 	:= get_rec.attribute13		;
  	 x_oprn_resc_rec(i).attribute14 	:= get_rec.attribute14		;
  	 x_oprn_resc_rec(i).attribute15 	:= get_rec.attribute15		;
  	 x_oprn_resc_rec(i).attribute16 	:= get_rec.attribute16		;
  	 x_oprn_resc_rec(i).attribute17 	:= get_rec.attribute17		;
  	 x_oprn_resc_rec(i).attribute18 	:= get_rec.attribute18		;
  	 x_oprn_resc_rec(i).attribute19 	:= get_rec.attribute19		;
  	 x_oprn_resc_rec(i).attribute20 	:= get_rec.attribute20		;
  	 x_oprn_resc_rec(i).attribute21 	:= get_rec.attribute21		;
  	 x_oprn_resc_rec(i).attribute22 	:= get_rec.attribute22		;
  	 x_oprn_resc_rec(i).attribute23 	:= get_rec.attribute23		;
  	 x_oprn_resc_rec(i).attribute24 	:= get_rec.attribute24		;
  	 x_oprn_resc_rec(i).attribute25 	:= get_rec.attribute25		;
  	 x_oprn_resc_rec(i).attribute26 	:= get_rec.attribute26		;
  	 x_oprn_resc_rec(i).attribute27 	:= get_rec.attribute27		;
  	 x_oprn_resc_rec(i).attribute28 	:= get_rec.attribute28		;
  	 x_oprn_resc_rec(i).attribute29 	:= get_rec.attribute29		;
  	 x_oprn_resc_rec(i).attribute30 	:= get_rec.attribute30		;

      gmd_fetch_oprn.get_oprn_process_param_detl
      (p_api_version => p_api_version
      ,p_init_msg_list => p_init_msg_list
      ,p_oprn_line_id => get_rec.oprn_line_id
      ,p_resources => get_rec.resources
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      ,X_oprn_resc_proc_param_tbl => l_resc_param_tbl);

      X_row := X_oprn_resc_proc_param_tbl.count;

      FOR K in 1.. l_resc_param_tbl.count loop
        X_row := X_row + 1;
        X_oprn_resc_proc_param_tbl(X_row) := l_resc_param_tbl(K);
      END LOOP;
  END LOOP;

  IF i = 0  THEN
    RAISE fnd_api.g_exc_error;
  END IF;

/* standard call to get msge cnt, and if cnt is 1, get mesg info */
 FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);

   WHEN OTHERS THEN
     X_return_code   := SQLCODE;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
  END get_oprn_resc;

  PROCEDURE get_oprn_process_param_detl
  (     p_api_version              IN      NUMBER                          ,
        p_init_msg_list            IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_oprn_line_id             IN      NUMBER                          ,
        p_resources                IN      VARCHAR2                        ,
        x_return_status            OUT NOCOPY     VARCHAR2                        ,
        x_msg_count                OUT NOCOPY     NUMBER                          ,
        x_msg_data                 OUT NOCOPY     VARCHAR2                        ,
        X_oprn_resc_proc_param_tbl OUT NOCOPY     gmd_recipe_fetch_pub.recp_resc_proc_param_tbl
  ) IS

    /* Parameters at the oprn resource level */
    CURSOR Cur_get_oprn_rsrc IS
      SELECT p.*,g.parameter_name,g.parameter_description,g.units,g.parameter_type
      FROM   gmd_oprn_process_parameters_v1 p, gmp_process_parameters g
      WHERE  p.oprn_line_id = P_oprn_line_id
      AND    p.resources = P_resources
      AND    p.parameter_id = g.parameter_id
            ORDER BY sequence_no;

    l_oprn_rec Cur_get_oprn_rsrc%ROWTYPE;
    l_api_name VARCHAR2(40) := 'get_oprn_process_param_detl';
    X_row   NUMBER DEFAULT 0;
    X_override NUMBER(5) DEFAULT 0;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR l_oprn_rec IN Cur_get_oprn_rsrc LOOP
        X_row := X_row + 1;
        X_oprn_resc_proc_param_tbl(X_row).recipe_id := NULL;
        X_oprn_resc_proc_param_tbl(X_row).routingstep_id := NULL;
        X_oprn_resc_proc_param_tbl(X_row).routingstep_no := NULL;
        X_oprn_resc_proc_param_tbl(X_row).oprn_line_id := P_oprn_line_id;
        X_oprn_resc_proc_param_tbl(X_row).resources := P_resources;
        X_oprn_resc_proc_param_tbl(X_row).parameter_id := l_oprn_rec.parameter_id;
        X_oprn_resc_proc_param_tbl(X_row).parameter_name := l_oprn_rec.parameter_name;
        X_oprn_resc_proc_param_tbl(X_row).parameter_description := l_oprn_rec.parameter_description;
        X_oprn_resc_proc_param_tbl(X_row).units := l_oprn_rec.units;
        X_oprn_resc_proc_param_tbl(X_row).target_value := l_oprn_rec.target_value;
        X_oprn_resc_proc_param_tbl(X_row).minimum_value := l_oprn_rec.minimum_value;
        X_oprn_resc_proc_param_tbl(X_row).maximum_value := l_oprn_rec.maximum_value;
        X_oprn_resc_proc_param_tbl(X_row).parameter_type := l_oprn_rec.parameter_type;
        X_oprn_resc_proc_param_tbl(X_row).sequence_no := l_oprn_rec.sequence_no;
        X_oprn_resc_proc_param_tbl(X_row).created_by := l_oprn_rec.created_by;
        X_oprn_resc_proc_param_tbl(X_row).creation_date := l_oprn_rec.creation_date;
        X_oprn_resc_proc_param_tbl(X_row).last_updated_by := l_oprn_rec.last_updated_by;
        X_oprn_resc_proc_param_tbl(X_row).last_update_date := l_oprn_rec.last_update_date;
        X_oprn_resc_proc_param_tbl(X_row).last_update_login := l_oprn_rec.last_update_login;
        X_oprn_resc_proc_param_tbl(X_row).recipe_override := X_override;
    END LOOP; /* FOR l_oprn_rec IN Cur_get_oprn_rsrc */
  EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
     FND_MSG_PUB.Count_And_Get(p_count=>x_msg_count, p_data=>x_msg_data);
  END get_oprn_process_param_detl;

END GMD_FETCH_OPRN ;

/
