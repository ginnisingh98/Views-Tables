--------------------------------------------------------
--  DDL for Package Body GMD_OPERATION_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATION_RESOURCES_PVT" AS
/*  $Header: GMDVOPRB.pls 120.0 2005/05/26 01:03:54 appldev noship $ */
/*
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVOPRB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating, modifying, deleting operation resources                   |
 |                                                                         |
 | HISTORY                                                                 |
 |     27-SEP-2002  Sandra Dulyk    Created                                |
 |     25-NOV-2002  Thomas Daniel   Bug# 2679110                           |
 |                                  Added checks to handle the errors and  |
 |                                  also added further validations         |
 |    20-FEB-2004  NSRIVAST         Bug# 3222090,Removed call to           |
 |                                  FND_PROFILE.VALUE('AFLOG_ENABLED')     |
 +=========================================================================+
  API Name  : GMD_OPERATION_RESOURCES_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete operation resources
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

/*===========================================================================================
Procedure
   insert_operation_resources
Description
  This particular procedure is used to insert an operation resources
Parameters
================================================ */
PROCEDURE insert_operation_resources
(p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
, p_oprn_rsrc_tbl		IN GMD_OPERATION_RESOURCES_PUB.gmd_oprn_resources_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2)       IS

  CURSOR Cur_check_resource (V_oprn_line_id NUMBER, V_resources VARCHAR2) IS
    SELECT activity
    FROM   gmd_operation_resources a, gmd_operation_activities b
    WHERE  a.oprn_line_id = V_oprn_line_id
    AND    resources = V_resources
    AND    a.oprn_line_id = b.oprn_line_id;

   l_mesg_count		NUMBER;
   l_mesg_list		VARCHAR2(240);
   l_retn_status	VARCHAR2(1);
   l_activity		gmd_activities.activity%TYPE;

BEGIN
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('In insert_operation_resources public.');
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    /* set row who columns */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
      IF NOT gmd_api_grp.setup_done THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    /*Before insert operation resources loop */
    FOR i in 1 .. p_oprn_rsrc_tbl.count LOOP
      /* Before inserting the resource let us check if this resource already exists */
      /* for the current operation */
      OPEN Cur_check_resource (p_oprn_line_id, p_oprn_rsrc_tbl(i).RESOURCES);
      FETCH Cur_check_resource INTO l_activity;
      IF Cur_check_resource%FOUND THEN
        CLOSE Cur_check_resource;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_DUP_ACTV_RSRC');
        FND_MESSAGE.SET_TOKEN('RESOURCE', p_oprn_rsrc_tbl(i).resources);
        FND_MESSAGE.SET_TOKEN('ACTIVITY', l_activity);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE Cur_check_resource;


            insert into GMD_OPERATION_RESOURCES (
    	                    OPRN_LINE_ID,
                                       RESOURCES ,
                                       RESOURCE_USAGE         ,
                                      RESOURCE_COUNT         ,
                                      resource_usage_uom               ,
                                      PROCESS_QTY        ,
                                      RESOURCE_PROCESS_UOM        ,
                                      PRIM_RSRC_IND       ,
                                      SCALE_TYPE             ,
                                      COST_ANALYSIS_CODE     ,
                                      COST_CMPNTCLS_ID       ,
                                      OFFSET_INTERVAL        ,
                                      DELETE_MARK            ,
                                      MIN_CAPACITY          ,
                                      MAX_CAPACITY          ,
                                      resource_capacity_uom          ,
                                      ATTRIBUTE_CATEGORY     ,
                                      ATTRIBUTE1             ,
                                      ATTRIBUTE2             ,
                                      ATTRIBUTE3             ,
                                      ATTRIBUTE4             ,
                                      ATTRIBUTE5             ,
                                      ATTRIBUTE6             ,
                                      ATTRIBUTE7             ,
                                      ATTRIBUTE8             ,
                                      ATTRIBUTE9             ,
                                      ATTRIBUTE10            ,
                                      ATTRIBUTE11            ,
                                      ATTRIBUTE12            ,
                                      ATTRIBUTE13            ,
                                      ATTRIBUTE14            ,
                                      ATTRIBUTE15            ,
                                      ATTRIBUTE16            ,
                                      ATTRIBUTE17            ,
                                      ATTRIBUTE18        ,
                                       ATTRIBUTE19        ,
                                      ATTRIBUTE20          ,
                                      ATTRIBUTE21           ,
                                      ATTRIBUTE22            ,
                                      ATTRIBUTE23            ,
                                      ATTRIBUTE24            ,
                                      ATTRIBUTE25            ,
                                      ATTRIBUTE26            ,
                                      ATTRIBUTE27            ,
                                      ATTRIBUTE28            ,
                                      ATTRIBUTE29            ,
                                      ATTRIBUTE30            ,
                                      CREATION_DATE      ,
                                      CREATED_BY             ,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY   ,
                                      LAST_UPDATE_LOGIN  )
            	     values (
       	          		       p_oprn_line_id,
                                       p_oprn_rsrc_tbl(i).RESOURCES              ,
                                       p_oprn_rsrc_tbl(i).RESOURCE_USAGE  ,
                                       p_oprn_rsrc_tbl(i).RESOURCE_COUNT   ,
                                       p_oprn_rsrc_tbl(i).resource_usage_uom               ,
                                       p_oprn_rsrc_tbl(i).PROCESS_QTY        ,
                                       p_oprn_rsrc_tbl(i).RESOURCE_PROCESS_UOM        ,
                                       p_oprn_rsrc_tbl(i).PRIM_RSRC_IND       ,
                                       p_oprn_rsrc_tbl(i).SCALE_TYPE             ,
                                      p_oprn_rsrc_tbl(i).COST_ANALYSIS_CODE     ,
                                      p_oprn_rsrc_tbl(i).COST_CMPNTCLS_ID       ,
                                      p_oprn_rsrc_tbl(i).OFFSET_INTERVAL        ,
                                      0        ,
                                      p_oprn_rsrc_tbl(i).MIN_CAPACITY          ,
                                      p_oprn_rsrc_tbl(i).MAX_CAPACITY          ,
                                      p_oprn_rsrc_tbl(i).resource_capacity_uom          ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE_CATEGORY     ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE1             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE2             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE3             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE4             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE5             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE6             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE7             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE8             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE9             ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE10            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE11            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE12            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE13            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE14            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE15            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE16            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE17            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE18        ,
                                       p_oprn_rsrc_tbl(i).ATTRIBUTE19        ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE20          ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE21           ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE22            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE23            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE24            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE25            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE26            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE27            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE28            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE29            ,
                                      p_oprn_rsrc_tbl(i).ATTRIBUTE30            ,
            	                     sysdate,
            	                     gmd_api_grp.user_id,
            	                     sysdate,
            	                     gmd_api_grp.user_id,
            	                     gmd_api_grp.user_id);
           END LOOP;
           IF (l_debug = 'Y') THEN
             gmd_debug.put_line('End insert oprn rsrc loop -  insert_operation_rsrc private');
           END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			    P_data  => x_message_list);


END insert_operation_resources;

/*===========================================================================================
Procedure
   update_operation_resources
Description
  This particular procedure is used to update operation resources
Parameters
================================================ */
PROCEDURE update_operation_resources
( p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources			IN	gmd_operation_resources.resources%TYPE
, p_update_table		IN	gmd_operation_resources_pub.update_tbl_type
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2)    IS

   l_mesg_count		NUMBER;
   l_mesg_list		VARCHAR2(240);
   l_retn_status		VARCHAR2(1);
    v_oprn_rsrc_update_rec       gmd_operation_resources%ROWTYPE;
    l_rsrc_usage 		varchar2(100);
    setup_failure EXCEPTION;

    CURSOR get_resource_info(p_oprn_line_id gmd_operation_resources.oprn_line_id%TYPE , p_resources gmd_operation_resources.resources%TYPE)  IS
       SELECT *
       FROM gmd_operation_resources
       WHERE oprn_line_id = p_oprn_line_id
         AND resources = p_resources;

BEGIN

/* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF (l_debug = 'Y') THEN

      gmd_debug.put_line('Start of update_operation_rsrc PVT');
    END IF;

    OPEN get_resource_info(p_oprn_line_id, p_resources);
    FETCH get_resource_info INTO v_oprn_rsrc_update_rec;
    CLOSE get_resource_info;

      FOR i IN 1 .. p_update_table.count LOOP
        IF (l_debug = 'Y') THEN

          gmd_debug.put_line('Begin Loop - in update_operation_rsrc loop (private).  Col to update is ' || p_update_table(i).p_col_to_update);
        END IF;

         IF UPPER(p_update_table(i).p_col_to_update) = 'RESOURCE_USAGE' THEN
    	     v_oprn_rsrc_update_rec.resource_usage := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'RESOURCES' THEN
    	     v_oprn_rsrc_update_rec.resources := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'resource_usage_uom' THEN
          	     v_oprn_rsrc_update_rec.resource_usage_uom := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'PROCESS_QTY' THEN
          	     v_oprn_rsrc_update_rec.process_qty := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'SCALE_TYPE' THEN
          	     v_oprn_rsrc_update_rec.scale_type := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'COST_CMPNTCLS_ID' THEN
          	     v_oprn_rsrc_update_rec.cost_cmpntcls_id := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'COST_ANALYSIS_CODE' THEN
          	     v_oprn_rsrc_update_rec.cost_analysis_code := p_update_table(i).p_value;
        ELSIF UPPER(p_update_table(i).p_col_to_update) = 'PRIM_RSRC_IND' THEN
          	     v_oprn_rsrc_update_rec.prim_rsrc_ind := p_update_table(i).p_value;
        ELSIF UPPER(p_update_table(i).p_col_to_update) = 'RESOURCE_COUNT' THEN
          	     v_oprn_rsrc_update_rec.resource_count := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OFFSET_INTERVAL' THEN
          	     v_oprn_rsrc_update_rec.offset_interval := p_update_table(i).p_value;
        ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1' THEN
                        v_oprn_rsrc_update_rec.attribute1 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2' THEN
          	     v_oprn_rsrc_update_rec.attribute2 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3' THEN
          	     v_oprn_rsrc_update_rec.attribute3 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4' THEN
          	     v_oprn_rsrc_update_rec.attribute4 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5' THEN
          	     v_oprn_rsrc_update_rec.attribute5 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6' THEN
          	     v_oprn_rsrc_update_rec.attribute6 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7' THEN
          	     v_oprn_rsrc_update_rec.attribute7 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8' THEN
          	     v_oprn_rsrc_update_rec.attribute8 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9' THEN
          	     v_oprn_rsrc_update_rec.attribute9 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10' THEN
          	     v_oprn_rsrc_update_rec.attribute10 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11' THEN
          	     v_oprn_rsrc_update_rec.attribute11 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12' THEN
          	     v_oprn_rsrc_update_rec.attribute12 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13' THEN
          	     v_oprn_rsrc_update_rec.attribute13 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14' THEN
          	     v_oprn_rsrc_update_rec.attribute14 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15' THEN
          	     v_oprn_rsrc_update_rec.attribute15 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16' THEN
          	     v_oprn_rsrc_update_rec.attribute16 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17' THEN
          	     v_oprn_rsrc_update_rec.attribute17 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18' THEN
          	     v_oprn_rsrc_update_rec.attribute18 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19' THEN
          	     v_oprn_rsrc_update_rec.attribute19 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20' THEN
          	     v_oprn_rsrc_update_rec.attribute20 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21' THEN
          	     v_oprn_rsrc_update_rec.attribute21 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22' THEN
          	     v_oprn_rsrc_update_rec.attribute22 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23' THEN
          	     v_oprn_rsrc_update_rec.attribute23 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24' THEN
          	     v_oprn_rsrc_update_rec.attribute24 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25' THEN
          	     v_oprn_rsrc_update_rec.attribute25 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26' THEN
          	     v_oprn_rsrc_update_rec.attribute26 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27' THEN
          	     v_oprn_rsrc_update_rec.attribute27 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28' THEN
          	     v_oprn_rsrc_update_rec.attribute28 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29' THEN
          	     v_oprn_rsrc_update_rec.attribute29 := p_update_table(i).p_value;
         ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30' THEN
          	     v_oprn_rsrc_update_rec.attribute30 := p_update_table(i).p_value;
        ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY' THEN
          	     v_oprn_rsrc_update_rec.attribute_category := p_update_table(i).p_value;
         END IF;

      IF (l_debug = 'Y') THEN

        gmd_debug.put_line('Update_operation_rsrc private - after set cols for rsrc tbl.  Col to update is ' || p_update_table(i).p_col_to_update);
      END IF;

    END LOOP;

     IF x_return_status = 'S' THEN

         /* Set row who columns */
         FND_PROFILE.put('USER_ID', 2060);
         IF NOT gmd_api_grp.setup_done THEN
            gmd_api_grp.setup_done := gmd_api_grp.setup;
         END IF;
         IF NOT gmd_api_grp.setup_done THEN
           RAISE setup_failure;
         END IF;

      IF (l_debug = 'Y') THEN

        gmd_debug.put_line('before update table -  update_operation_rsrc private');
      END IF;

   	update GMD_OPERATION_RESOURCES
       	set           RESOURCE_USAGE       = v_oprn_rsrc_update_rec.resource_usage,
        RESOURCES           = v_oprn_rsrc_update_rec.resources,
 		RESOURCE_COUNT      = v_oprn_rsrc_update_rec.resource_count,
 		resource_usage_uom            = v_oprn_rsrc_update_rec.resource_usage_uom,
 		PROCESS_QTY         = v_oprn_rsrc_update_rec.process_qty,
 		RESOURCE_PROCESS_UOM         = v_oprn_rsrc_update_rec.RESOURCE_PROCESS_UOM,
 		PRIM_RSRC_IND       = v_oprn_rsrc_update_rec.prim_rsrc_ind,
 		SCALE_TYPE          = v_oprn_rsrc_update_rec.scale_type,
 		COST_ANALYSIS_CODE  = v_oprn_rsrc_update_rec.cost_analysis_code,
 		COST_CMPNTCLS_ID    = v_oprn_rsrc_update_rec.cost_cmpntcls_id,
 		OFFSET_INTERVAL     = v_oprn_rsrc_update_rec.offset_interval,
  	                     ATTRIBUTE1 = v_oprn_rsrc_update_rec.attribute1,
            	                     ATTRIBUTE2 = v_oprn_rsrc_update_rec.attribute2,
            	                     ATTRIBUTE3 = v_oprn_rsrc_update_rec.attribute3,
            	                     ATTRIBUTE4 = v_oprn_rsrc_update_rec.attribute4,
            	                     ATTRIBUTE5 = v_oprn_rsrc_update_rec.attribute5,
            	                     ATTRIBUTE6 = v_oprn_rsrc_update_rec.attribute6,
            	                     ATTRIBUTE7 = v_oprn_rsrc_update_rec.attribute7,
            	                     ATTRIBUTE8 = v_oprn_rsrc_update_rec.attribute8,
            	                     ATTRIBUTE9 = v_oprn_rsrc_update_rec.attribute9,
            	                     ATTRIBUTE10 = v_oprn_rsrc_update_rec.attribute10,
            	                     ATTRIBUTE11 = v_oprn_rsrc_update_rec.attribute11,
            	                     ATTRIBUTE12 = v_oprn_rsrc_update_rec.attribute12,
            	                     ATTRIBUTE13 = v_oprn_rsrc_update_rec.attribute13,
            	                     ATTRIBUTE14 = v_oprn_rsrc_update_rec.attribute14,
            	                     ATTRIBUTE15 = v_oprn_rsrc_update_rec.attribute15,
            	                     ATTRIBUTE16 = v_oprn_rsrc_update_rec.attribute16,
            	                     ATTRIBUTE17 = v_oprn_rsrc_update_rec.attribute17,
            	                     ATTRIBUTE18 = v_oprn_rsrc_update_rec.attribute18,
            	                     ATTRIBUTE19 = v_oprn_rsrc_update_rec.attribute19,
            	                     ATTRIBUTE20 = v_oprn_rsrc_update_rec.attribute20,
            	                     ATTRIBUTE21 = v_oprn_rsrc_update_rec.attribute21,
            	                     ATTRIBUTE30 = v_oprn_rsrc_update_rec.attribute30,
         	                     ATTRIBUTE_CATEGORY = v_oprn_rsrc_update_rec.attribute_category,
        		  ATTRIBUTE25 = v_oprn_rsrc_update_rec.attribute25,
            	                     ATTRIBUTE26 = v_oprn_rsrc_update_rec.attribute26,
            	                     ATTRIBUTE27 = v_oprn_rsrc_update_rec.attribute27,
            	                     ATTRIBUTE28 = v_oprn_rsrc_update_rec.attribute28,
            	                     ATTRIBUTE29 = v_oprn_rsrc_update_rec.attribute29,
            	                     ATTRIBUTE22 = v_oprn_rsrc_update_rec.attribute22,
            	                     ATTRIBUTE23 = v_oprn_rsrc_update_rec.attribute23,
            	                     ATTRIBUTE24 = v_oprn_rsrc_update_rec.attribute24,
            	                     LAST_UPDATE_DATE = sysdate,
            	                     LAST_UPDATED_BY = gmd_api_grp.user_id,
            	                     LAST_UPDATE_LOGIN  = gmd_api_grp.user_id
            	        where oprn_line_id = p_oprn_line_id
            	              and resources = p_resources;

       END IF;


   IF (l_debug = 'Y') THEN

     gmd_debug.put_line('END of update_operation_resource PVT');
   END IF;

   EXCEPTION
     WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			                         P_data  => x_message_list);


END update_operation_resources;

/*===========================================================================================
Procedure
   delete_operation_resources
Description
  This particular procedure is used to delete operation resources
Parameters
================================================ */
PROCEDURE delete_operation_resource
( p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
, p_resources			IN 	gmd_operation_resources.resources%TYPE
, x_message_count 		OUT NOCOPY  	NUMBER
, x_message_list 		OUT NOCOPY  	VARCHAR2
, x_return_status		OUT NOCOPY  	VARCHAR2)  IS

   l_mesg_count		NUMBER;
   l_mesg_list		VARCHAR2(240);
   l_retn_status		VARCHAR2(1);
   setup_failure        EXCEPTION;
BEGIN

   /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

   /* Set row who columns */
   FND_PROFILE.put('USER_ID', 2060);
   IF NOT gmd_api_grp.setup_done THEN
       gmd_api_grp.setup_done := gmd_api_grp.setup;
   END IF;
   IF NOT gmd_api_grp.setup_done THEN
       RAISE setup_failure;
   END IF;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('START of delete_operation_resources PVT');
    END IF;

   DELETE from GMD_OPERATION_RESOURCES
   WHERE oprn_line_id = p_oprn_line_id
        and resources = p_resources;

       IF (l_debug = 'Y') THEN

         gmd_debug.put_line('END of delete_operation_resources PVT');
       END IF;

   EXCEPTION
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			                         P_data  => x_message_list);


END delete_operation_resource;

END GMD_OPERATION_RESOURCES_PVT;

/
