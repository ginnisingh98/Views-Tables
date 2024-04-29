--------------------------------------------------------
--  DDL for Package Body GMD_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ACTIVITIES_PUB" AS
/*  $Header: GMDPACTB.pls 115.4 2004/02/25 17:42:27 nsrivast noship $
 **************************************************************************
 *                                                                         *
 * Package  GMD_ACTIVITY_PUB                                               *
 *                                                                         *
 * Contents: INSERT_ACTIVITY 	                                           *
 *	   UPDATE_ACTIVITY	                                           *
 *                   DELETE_ACTIVITY	                                   *
 *                                                                         *
 * Use      This is the public layer of the GMD Activity API               *
 *                                                                         *
 *                                                                         *
 * History                                                                 *
 *         Written by Sandra Dulyk, OPM Development                        *
 *     25-NOV-2002  Thomas Daniel   Bug# 2679110                           *
 *                                  Rewrote the procedures to handle the   *
 *                                  errors properly and also to handle     *
 *                                  further validations                    *
 *    20-FEB-2004  Bug 3222090, NSRIVAST                                   *
 *                      Removed call to FND_PROFILE.VALUE('AFLOG_ENABLED') *
 **************************************************************************
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
-- Bug 3222090, NSRIVAST, END



/*===========================================================================================
Procedure
   insert_activity
Description
  This particular procedure is used to insert an activity
Parameters
================================================ */
 PROCEDURE insert_activity (
     p_api_version 			IN 	NUMBER
   , p_init_msg_list 			IN 	BOOLEAN
   , p_commit				IN 	BOOLEAN
   , p_activity_tbl			IN 	gmd_activities_pub.gmd_activities_tbl_type
   , x_message_count	 		OUT NOCOPY  	NUMBER
   , x_message_list 			OUT NOCOPY  	VARCHAR2
   , x_return_status			OUT NOCOPY  	VARCHAR2)         IS

   l_retn_status	VARCHAR2(1);
   l_api_version	NUMBER := 1.0;
   l_exist		NUMBER(5);

     setup_failure 	EXCEPTION;
     invalid_version 	EXCEPTION;
     ins_activity_err	EXCEPTION;

  BEGIN
    SAVEPOINT insert_activity;

    IF (l_debug = 'Y') THEN
      gmd_debug.log_initialize('InsActv');
    END IF;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                       ,p_api_version
                                       ,'insert_activity'
                                       ,'gmd_activities_pub') THEN
      RAISE invalid_version;
    END IF;

    /* Loop through records in activity table and perform validations for each record*/
    FOR i IN 1 .. p_activity_tbl.count LOOP

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(' Start of LOOP.  Activity is ' || p_activity_tbl(i).activity);
      END IF;

      /* Activity must be passed, otherwise give error */
      IF p_activity_tbl(i).activity IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('activity required');
        END IF;
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'ACTIVITY');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
      END IF;

      /* Cost Analysis Code Validations - Must be passed,  otherwise give error */
      /* Also, cost analysis code must be defined in cm_alys_mst, else give error */
      IF p_activity_tbl(i).cost_analysis_code IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('cost analysis required');
        END IF;

        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'COST_ANALYSIS_CODE');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
      ELSE
        IF GMDOPVAL_PUB.check_cost_analysis (pcost_analysis_code => p_activity_tbl(i).cost_analysis_code) <> 0 THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.g_ret_sts_error;
      	END IF;
      END IF;

      /* Description must be passed, otherwise give error */
      IF p_activity_tbl(i).activity_desc IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('activity desc required');
        END IF;
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'ACTIVITY_DESC');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
      END IF;

    END LOOP;

    IF x_return_status = 'S' THEN
      GMD_ACTIVITIES_PVT.insert_activity(p_activity_tbl  =>  p_activity_tbl,
  	     				 x_message_count =>  x_message_count,
        				 x_message_list  =>  x_message_list,
      				         x_return_status =>  l_retn_status);
      IF l_retn_status <> FND_API.g_ret_sts_success THEN
        RAISE ins_activity_err;
      END IF;

      IF p_commit THEN
        COMMIT;
      END IF;

      /* Adding message to stack indicating the success of the routine */
      gmd_api_grp.log_message ('GMD_SAVED_CHANGES');
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

  EXCEPTION
    WHEN setup_failure OR invalid_version THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO SAVEPOINT insert_activity;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			 P_data  => x_message_list);
    WHEN ins_activity_err THEN
      x_return_status := l_retn_status;
      ROLLBACK TO SAVEPOINT insert_activity;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			 P_data  => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT insert_activity;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      	                         P_data  => x_message_list);
  END Insert_Activity;


  /*==========================================================
  Procedure
    update_activity
  Description
    This particular procedure is used to update an activity
  Parameters
  ================================================ */
  PROCEDURE update_activity (
   p_api_version 		IN 	NUMBER
  ,p_init_msg_list 		IN 	BOOLEAN
  ,p_commit			IN 	BOOLEAN
  ,p_activity			IN 	gmd_activities.activity%TYPE
  ,p_update_table		IN	gmd_activities_pub.update_tbl_type
  ,x_message_count 		OUT NOCOPY  	NUMBER
  ,x_message_list 		OUT NOCOPY  	VARCHAR2
  ,x_return_status		OUT NOCOPY  	VARCHAR2 )  IS

   l_retn_status		VARCHAR2(1);
   l_api_version		NUMBER := 1.0;

   setup_failure		EXCEPTION;
   invalid_version		EXCEPTION;
   upd_activity_err		EXCEPTION;

   CURSOR Cur_check_activity (v_activity VARCHAR2)  IS
     SELECT 1
     FROM   gmd_activities_b
     WHERE  activity = v_activity;

     l_exist		 NUMBER(5);

  BEGIN
    SAVEPOINT update_activity;

    IF (l_debug = 'Y') THEN
      gmd_debug.log_initialize('UpdActv');
    END IF;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                       ,p_api_version
                                       ,'update_activity'
                                       ,'gmd_activities_pub') THEN
      RAISE invalid_version;
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Start of update_activity PUB');
    END IF;

    /* Activity must be passed, otherwise give error */
    IF p_activity IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('activity required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ACTIVITY');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.g_ret_sts_error;
    ELSE
      /* Check for the existense of activity */
      OPEN Cur_check_activity(p_activity);
      FETCH Cur_check_activity INTO l_exist;
      IF (Cur_check_activity%NOTFOUND) THEN
        gmd_api_grp.log_message ('FM_INVACTIVITY');
        x_return_status := FND_API.g_ret_sts_error;
      END IF;
      CLOSE Cur_check_activity;
    END IF;

    /* Loop thru cols to be updated - verify col and value are present */
    FOR i in 1 .. p_update_table.count LOOP
      /* Col_to_update and value must be passed, otherwise give error */
      IF p_update_table(i).p_col_to_update IS NULL THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'COL_TO_UPDATE');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
      ELSIF p_update_table(i).p_value IS NULL THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'P_VALUE');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.g_ret_sts_error;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK' THEN
        GMDRTVAL_PUB.check_delete_mark ( Pdelete_mark    => p_update_table(i).p_value,
                                        x_return_status => l_retn_status);
        IF l_retn_status <> 'S' THEN /* it indicates that invalid value has been passed */
          FND_MESSAGE.SET_NAME('GMA', 'SY_BADDELETEMARK');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ACTIVITY_DESC' THEN
        IF p_update_table(i).p_value IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'ACTIVITY_DESC');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.g_ret_sts_error;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'COST_ANALYSIS_CODE' THEN
        IF p_update_table(i).p_value IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'COST_ANALYSIS_CODE');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.g_ret_sts_error;
        ELSE
          IF GMDOPVAL_PUB.check_cost_analysis (pcost_analysis_code => p_update_table(i).p_value) <> 0 THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.g_ret_sts_error;
          END IF;
        END IF;
      END IF;
    END LOOP;

    IF x_return_status = 'S' THEN
      GMD_ACTIVITIES_PVT.update_activity(p_activity	  => p_activity
         				, p_update_table  => p_update_table
        				, x_message_count => x_message_count
        				, x_message_list  => x_message_list
        				, x_return_status => l_retn_status);
      IF l_retn_status <> FND_API.g_ret_sts_success THEN
        RAISE upd_activity_err;
      END IF;

      IF p_commit THEN
         COMMIT;
      END IF;

      /* Adding message to stack indicating the success of the routine */
      gmd_api_grp.log_message ('GMD_SAVED_CHANGES');
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

  EXCEPTION
    WHEN setup_failure OR invalid_version THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK to SAVEPOINT update_activity;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      	                         P_data  => x_message_list);
    WHEN upd_activity_err THEN
      x_return_status := l_retn_status;
      ROLLBACK to SAVEPOINT update_activity;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      	                         P_data  => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK to SAVEPOINT update_activity;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      	                         P_data  => x_message_list);

END update_activity;

  /*===========================================================================================
  Procedure
    delete_activity
  Description
    This particular procedure is used to set delete_mark = 1 for an activity
  Parameters
  ================================================ */
  PROCEDURE delete_activity (
     p_api_version 		IN 	NUMBER
    ,p_init_msg_list 		IN 	BOOLEAN
    ,p_commit			IN 	BOOLEAN
    ,p_activity			IN 	gmd_activities.activity%TYPE
    ,x_message_count 		OUT NOCOPY  	NUMBER
    ,x_message_list 		OUT NOCOPY  	VARCHAR2
    ,x_return_status		OUT NOCOPY  	VARCHAR2  )  IS

    v_update_table   gmd_activities_pub.update_tbl_type;
    l_retn_status		VARCHAR2(1);
    del_activity_err	EXCEPTION;
  BEGIN
    SAVEPOINT delete_activity;

    IF (l_debug = 'Y') THEN
      gmd_debug.log_initialize('DelActv');
     END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    v_update_table(1).p_col_to_update := 'DELETE_MARK';
    v_update_table(1).p_value := '1';

    update_activity(p_api_version    => p_api_version
                   ,p_init_msg_list  => p_init_msg_list
                   ,p_activity	     => p_activity
       		   ,p_update_table   => v_update_table
                   , x_message_count => x_message_count
       		   , x_message_list  => x_message_list
       		   , x_return_status => l_retn_status);
    IF l_retn_status <> FND_API.g_ret_sts_success THEN
      RAISE del_activity_err;
    END IF;

    IF p_commit THEN
      COMMIT;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

  EXCEPTION
    WHEN del_activity_err THEN
      x_return_status := l_retn_status;
      ROLLBACK to SAVEPOINT delete_activity;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
                                 P_data  => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK to SAVEPOINT delete_activity;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
                                 P_data  => x_message_list);

END delete_activity;

END GMD_ACTIVITIES_PUB;

/
