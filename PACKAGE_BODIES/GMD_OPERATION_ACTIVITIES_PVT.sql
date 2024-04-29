--------------------------------------------------------
--  DDL for Package Body GMD_OPERATION_ACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATION_ACTIVITIES_PVT" AS
/*  $Header: GMDVOPAB.pls 120.0 2005/05/25 19:18:18 appldev noship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDVOPAB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private definitions for  			   |
 |     creating and modifying operation activities                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     22-SEPT-2002  Sandra Dulyk    Created                               |
 | 27-DEC-2002 S.Dulyk    Bug 2669986 Added break_ind and max_break cols   |
 | 20-FEB-2004  NSRIVAST  Bug# 3222090,Removed call to                     |
 |                        FND_PROFILE.VALUE('AFLOG_ENABLED')               |
 +=========================================================================+
  API Name  : GMD_OPERATION_ACTIVITIES_PVT
  Type      : Private
  Function  : This package contains private procedures used to create, modify, and delete operation activties
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
   insert_operation_activity
Description
  This particular procedure is used to insert an operation activity
Parameters
================================================ */
 PROCEDURE insert_operation_activity
 ( p_oprn_id		IN	gmd_operations.oprn_id%TYPE
 , p_oprn_activity		IN	gmd_operation_activities%ROWTYPE
 , x_message_count 		OUT NOCOPY  	NUMBER
 , x_message_list 		OUT NOCOPY  	VARCHAR2
 , x_return_status		OUT NOCOPY  	VARCHAR2)  IS

   v_activity	gmd_operation_activities.activity%TYPE;
   v_oprn_line_id	gmd_operation_activities.oprn_line_id%TYPE;
   l_errmsg     		VARCHAR2(240);
   setup_failure  		EXCEPTION;
   l_mesg_count NUMBER;
   l_mesg_list NUMBER;
   l_retn_status VARCHAR2(30);

 BEGIN
   IF (l_debug = 'Y') THEN
     gmd_debug.put_line('In insert_operation_activity private.');
   END IF;

   /* Initially let us assign the return status to success */
   x_return_status := FND_API.g_ret_sts_success;

   /* get values for row who cols */
   IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
   END IF;
   IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
   END IF;

   /* insert operation activities */
   IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Begin Loop - in insert_operation_activity loop (private). '||
                         ' Curr Activity is ' || p_oprn_activity.activity);
   END IF;

   insert into GMD_OPERATION_ACTIVITIES (
               OPRN_LINE_ID,
               OPRN_ID,
               ACTIVITY ,
               OFFSET_INTERVAL,
               ACTIVITY_FACTOR,
               DELETE_MARK ,
               SEQUENCE_DEPENDENT_IND,
               BREAK_IND,
               MAX_BREAK,
               MATERIAL_IND,
               ATTRIBUTE1,
               ATTRIBUTE2,
               ATTRIBUTE3,
               ATTRIBUTE4,
               ATTRIBUTE5,
               ATTRIBUTE6,
               ATTRIBUTE7,
               ATTRIBUTE8,
               ATTRIBUTE9,
               ATTRIBUTE10,
               ATTRIBUTE11,
               ATTRIBUTE12,
               ATTRIBUTE13,
               ATTRIBUTE14,
               ATTRIBUTE15,
               ATTRIBUTE16,
               ATTRIBUTE17,
               ATTRIBUTE18,
               ATTRIBUTE19,
               ATTRIBUTE20,
               ATTRIBUTE21,
               ATTRIBUTE30,
               ATTRIBUTE_CATEGORY,
               ATTRIBUTE25,
               ATTRIBUTE26,
               ATTRIBUTE27,
               ATTRIBUTE28,
               ATTRIBUTE29,
               ATTRIBUTE22,
               ATTRIBUTE23,
               ATTRIBUTE24,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_LOGIN      )
        values (
               p_oprn_activity.OPRN_LINE_ID,
               NVL(p_oprn_id, p_oprn_activity.OPRN_ID),
               p_oprn_activity.ACTIVITY ,
               p_oprn_activity.OFFSET_INTERVAL,
               p_oprn_activity.ACTIVITY_FACTOR,
               0 ,
               p_oprn_activity.SEQUENCE_DEPENDENT_IND,
               p_oprn_activity.break_ind,
               p_oprn_activity.max_break,
               p_oprn_activity.material_ind,
               p_oprn_activity.ATTRIBUTE1,
               p_oprn_activity.ATTRIBUTE2,
               p_oprn_activity.ATTRIBUTE3,
               p_oprn_activity.ATTRIBUTE4,
               p_oprn_activity.ATTRIBUTE5,
               p_oprn_activity.ATTRIBUTE6,
               p_oprn_activity.ATTRIBUTE7,
               p_oprn_activity.ATTRIBUTE8,
               p_oprn_activity.ATTRIBUTE9,
               p_oprn_activity.ATTRIBUTE10,
               p_oprn_activity.ATTRIBUTE11,
               p_oprn_activity.ATTRIBUTE12,
               p_oprn_activity.ATTRIBUTE13,
               p_oprn_activity.ATTRIBUTE14,
               p_oprn_activity.ATTRIBUTE15,
               p_oprn_activity.ATTRIBUTE16,
               p_oprn_activity.ATTRIBUTE17,
               p_oprn_activity.ATTRIBUTE18,
               p_oprn_activity.ATTRIBUTE19,
               p_oprn_activity.ATTRIBUTE20,
               p_oprn_activity.ATTRIBUTE21,
               p_oprn_activity.ATTRIBUTE30,
               p_oprn_activity.ATTRIBUTE_CATEGORY,
               p_oprn_activity.ATTRIBUTE25,
               p_oprn_activity.ATTRIBUTE26,
               p_oprn_activity.ATTRIBUTE27,
               p_oprn_activity.ATTRIBUTE28,
               p_oprn_activity.ATTRIBUTE29,
               p_oprn_activity.ATTRIBUTE22,
               p_oprn_activity.ATTRIBUTE23,
               p_oprn_activity.ATTRIBUTE24,
               sysdate,
               gmd_api_grp.user_id,
               sysdate,
               gmd_api_grp.user_id,
               gmd_api_grp.user_id);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('End insert_operation_activity private');
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
  END insert_operation_activity;

  /*===============================================
  Procedure
     update_operation_activity
  Description
    This particular procedure is used to update an
    operation activity Parameters
  ================================================ */
  PROCEDURE update_operation_activity
  ( p_oprn_line_id	IN	gmd_operation_activities.oprn_line_id%TYPE
  , p_update_table	IN	gmd_operation_activities_pub.update_tbl_type
  , x_message_count 	OUT NOCOPY  	NUMBER
  , x_message_list 	OUT NOCOPY  	VARCHAR2
  , x_return_status	OUT NOCOPY  	VARCHAR2)    IS

    CURSOR retrieve_oprn_actv( p_oprn_line_id	gmd_operation_activities.oprn_line_id%TYPE ) IS
       SELECT *
       FROM gmd_operation_activities
       WHERE oprn_line_Id = p_oprn_line_id;

    v_oprn_actv_update_rec   gmd_operation_activities%ROWTYPE;
    l_errmsg     		VARCHAR2(240);
    setup_failure  		EXCEPTION;
   BEGIN
     IF (l_debug = 'Y') THEN
       gmd_debug.put_line(' In update_operation_activity private');
     END IF;

     /* Initially let us assign the return status to success */
     x_return_status := FND_API.g_ret_sts_success;

     OPEN retrieve_oprn_actv(p_oprn_line_id);
     FETCH retrieve_oprn_actv INTO v_oprn_actv_update_rec;
     CLOSE retrieve_oprn_actv;

     FOR i IN 1 .. p_update_table.count LOOP
       IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Begin Loop - in update_operation_activity loop (private). '||
                            'Col to update is ' || p_update_table(i).p_col_to_update);
       END IF;

       IF  UPPER(p_update_table(i).p_col_to_update) = 'OFFSET_INTERVAL' THEN
        	     v_oprn_actv_update_rec.offset_interval := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ACTIVITY_FACTOR' THEN
        	     v_oprn_actv_update_rec.activity_factor := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ACTIVITY' THEN
        	     v_oprn_actv_update_rec.activity := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'SEQUENCE_DEPENDENT_IND' THEN
        	     v_oprn_actv_update_rec.sequence_dependent_ind := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'BREAK_IND' THEN
        	     v_oprn_actv_update_rec.break_ind := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'MAX_BREAK' THEN
                   v_oprn_actv_update_rec.max_break := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'MATERIAL_IND' THEN
                   v_oprn_actv_update_rec.material_ind := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK' THEN
        	     v_oprn_actv_update_rec.delete_mark := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1' THEN
                      v_oprn_actv_update_rec.attribute1 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2' THEN
        	     v_oprn_actv_update_rec.attribute2 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3' THEN
        	     v_oprn_actv_update_rec.attribute3 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4' THEN
        	     v_oprn_actv_update_rec.attribute4 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5' THEN
        	     v_oprn_actv_update_rec.attribute5 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6' THEN
        	     v_oprn_actv_update_rec.attribute6 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7' THEN
        	     v_oprn_actv_update_rec.attribute7 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8' THEN
        	     v_oprn_actv_update_rec.attribute8 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9' THEN
        	     v_oprn_actv_update_rec.attribute9 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10' THEN
        	     v_oprn_actv_update_rec.attribute10 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11' THEN
        	     v_oprn_actv_update_rec.attribute11 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12' THEN
        	     v_oprn_actv_update_rec.attribute12 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13' THEN
        	     v_oprn_actv_update_rec.attribute13 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14' THEN
        	     v_oprn_actv_update_rec.attribute14 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15' THEN
        	     v_oprn_actv_update_rec.attribute15 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16' THEN
        	     v_oprn_actv_update_rec.attribute16 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17' THEN
        	     v_oprn_actv_update_rec.attribute17 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18' THEN
        	     v_oprn_actv_update_rec.attribute18 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19' THEN
        	     v_oprn_actv_update_rec.attribute19 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20' THEN
        	     v_oprn_actv_update_rec.attribute20 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21' THEN
        	     v_oprn_actv_update_rec.attribute21 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22' THEN
        	     v_oprn_actv_update_rec.attribute22 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23' THEN
        	     v_oprn_actv_update_rec.attribute23 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24' THEN
        	     v_oprn_actv_update_rec.attribute24 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25' THEN
        	     v_oprn_actv_update_rec.attribute25 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26' THEN
        	     v_oprn_actv_update_rec.attribute26 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27' THEN
        	     v_oprn_actv_update_rec.attribute27 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28' THEN
        	     v_oprn_actv_update_rec.attribute28 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29' THEN
        	     v_oprn_actv_update_rec.attribute29 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30' THEN
        	     v_oprn_actv_update_rec.attribute30 := p_update_table(i).p_value;
       ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY' THEN
        	     v_oprn_actv_update_rec.attribute_category := p_update_table(i).p_value;
       END IF;


      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Update_operation_activity private - after set cols for activities tbl.  Col to update is ' || p_update_table(i).p_col_to_update);
      END IF;

     END LOOP;

     IF x_return_status = 'S' THEN
        /* Set row who columns */
        IF NOT gmd_api_grp.setup_done THEN
           gmd_api_grp.setup_done := gmd_api_grp.setup;
        END IF;
        IF NOT gmd_api_grp.setup_done THEN
           RAISE setup_failure;
        END IF;

        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('before update table -  update_operation_activity private');
        END IF;

       	update  GMD_OPERATION_ACTIVITIES
       	set     ACTIVITY   = v_oprn_actv_update_rec.activity,
                OFFSET_INTERVAL = v_oprn_actv_update_rec.offset_interval,
                ACTIVITY_FACTOR = v_oprn_actv_update_rec.activity_factor,
                DELETE_MARK = v_oprn_actv_update_rec.delete_mark,
                SEQUENCE_DEPENDENT_IND = v_oprn_actv_update_rec.sequence_dependent_ind,
                BREAK_IND = v_oprn_actv_update_rec.break_ind,
                MAX_BREAK = v_oprn_actv_update_rec.max_break,
                MATERIAL_IND = v_oprn_actv_update_rec.material_ind,
                ATTRIBUTE1 = v_oprn_actv_update_rec.attribute1,
            	ATTRIBUTE2 = v_oprn_actv_update_rec.attribute2,
            	ATTRIBUTE3 = v_oprn_actv_update_rec.attribute3,
            	ATTRIBUTE4 = v_oprn_actv_update_rec.attribute4,
            	ATTRIBUTE5 = v_oprn_actv_update_rec.attribute5,
            	ATTRIBUTE6 = v_oprn_actv_update_rec.attribute6,
            	ATTRIBUTE7 = v_oprn_actv_update_rec.attribute7,
            	ATTRIBUTE8 = v_oprn_actv_update_rec.attribute8,
            	ATTRIBUTE9 = v_oprn_actv_update_rec.attribute9,
            	ATTRIBUTE10 = v_oprn_actv_update_rec.attribute10,
            	ATTRIBUTE11 = v_oprn_actv_update_rec.attribute11,
            	ATTRIBUTE12 = v_oprn_actv_update_rec.attribute12,
            	ATTRIBUTE13 = v_oprn_actv_update_rec.attribute13,
            	ATTRIBUTE14 = v_oprn_actv_update_rec.attribute14,
            	ATTRIBUTE15 = v_oprn_actv_update_rec.attribute15,
            	ATTRIBUTE16 = v_oprn_actv_update_rec.attribute16,
            	ATTRIBUTE17 = v_oprn_actv_update_rec.attribute17,
            	ATTRIBUTE18 = v_oprn_actv_update_rec.attribute18,
            	ATTRIBUTE19 = v_oprn_actv_update_rec.attribute19,
            	ATTRIBUTE20 = v_oprn_actv_update_rec.attribute20,
            	ATTRIBUTE21 = v_oprn_actv_update_rec.attribute21,
            	ATTRIBUTE30 = v_oprn_actv_update_rec.attribute30,
         	ATTRIBUTE_CATEGORY = v_oprn_actv_update_rec.attribute_category,
        	ATTRIBUTE25 = v_oprn_actv_update_rec.attribute25,
            	ATTRIBUTE26 = v_oprn_actv_update_rec.attribute26,
            	ATTRIBUTE27 = v_oprn_actv_update_rec.attribute27,
            	ATTRIBUTE28 = v_oprn_actv_update_rec.attribute28,
            	ATTRIBUTE29 = v_oprn_actv_update_rec.attribute29,
            	ATTRIBUTE22 = v_oprn_actv_update_rec.attribute22,
            	ATTRIBUTE23 = v_oprn_actv_update_rec.attribute23,
            	ATTRIBUTE24 = v_oprn_actv_update_rec.attribute24,
            	LAST_UPDATE_DATE = sysdate,
            	LAST_UPDATED_BY = gmd_api_grp.user_id,
            	LAST_UPDATE_LOGIN  = gmd_api_grp.user_id
          where oprn_line_id = p_oprn_line_id;
     END IF;

     IF (l_debug = 'Y') THEN
       gmd_debug.put_line('END of update_operation_activity private');
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

  END update_operation_activity;

  /*===========================================================================================
  Procedure
     delete_operation_activity
  Description
    This particular procedure is used to delete an operation activity
  Parameters
  ================================================ */
  PROCEDURE delete_operation_activity
  ( p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2) IS

          setup_failure  		EXCEPTION;
          l_errmsg     		VARCHAR2(240);

  BEGIN
    /* begin delete operation activity PVT*/
    DELETE from GMD_OPERATION_ACTIVITIES
    WHERE oprn_line_id = p_oprn_line_id;

    /* delete associated operation resources */
    DELETE from GMD_OPERATION_RESOURCES
    WHERE oprn_line_id = p_oprn_line_id;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('END of delete_operation_activity PVT');
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

           l_errmsg := sqlerrm;


END delete_operation_activity;

END GMD_OPERATION_ACTIVITIES_PVT;

/
