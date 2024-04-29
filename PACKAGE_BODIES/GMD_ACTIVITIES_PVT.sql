--------------------------------------------------------
--  DDL for Package Body GMD_ACTIVITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ACTIVITIES_PVT" AS
/*  $Header: GMDVACTB.pls 115.4 2004/02/25 18:12:35 nsrivast noship $
 *****************************************************************
 *                                                               *
 * Package  GMD_ACTIVITY_PVT                                     *
 *                                                               *
 * Contents: INSERT_ACTIVITY 	                                 *
 *	   UPDATE_ACTIVITY	                                 *
 *                                                               *
 * Use      This is the private layer of the GMD Activity API    *
 *                                                               *
 *                                                               *
 * History                                                       *
 *         Written by Sandra Dulyk, OPM Development              *
 *                                                               *
 * 20-FEB-2004  NSRIVAST  Bug# 3222090,Removed call to           *
 *                        FND_PROFILE.VALUE('AFLOG_ENABLED')     *
 *****************************************************************
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
      insert_activity
   Description
     This particular procedure is used to insert an activity
   Parameters
    ================================================ */
  PROCEDURE insert_activity (
      p_api_version 			IN 	NUMBER
      , p_init_msg_list 		IN 	BOOLEAN
      , p_commit			IN 	BOOLEAN
      , p_activity_tbl			IN 	gmd_activities_pub.gmd_activities_tbl_type
      , x_message_count	 	OUT NOCOPY  	NUMBER
      , x_message_list 		OUT NOCOPY  	VARCHAR2
      , x_return_status		OUT NOCOPY  	VARCHAR2 )   IS

    CURSOR Cur_check_activity (v_activity VARCHAR2)  IS
      SELECT 1
      FROM   gmd_activities_b
      WHERE  activity = v_activity;

      l_exist		 NUMBER(5);
      l_rowid 		 VARCHAR2(40);
      setup_failure 	 EXCEPTION;
      duplicate_activity EXCEPTION;
  BEGIN
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(' In insert_activity private');
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    FOR i IN 1 .. p_activity_tbl.count LOOP
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Begin Loop - in insert_activity loop (private).  Curr Activity is ' || p_activity_tbl(i).activity);
      END IF;

      /* Check for duplicate activity */
      OPEN Cur_check_activity(p_activity_tbl(i).activity);
      FETCH Cur_check_activity INTO l_exist;
      IF (Cur_check_activity%FOUND) THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('duplicate activity');
        END IF;
        gmd_api_grp.log_message ('GMD_DUPLICATE_ACTIVITY', 'ACTIVITY',p_activity_tbl(i).activity);
        CLOSE Cur_check_activity;
        RAISE duplicate_activity;
      END IF;
      CLOSE Cur_check_activity;

         GMD_ACTIVITIES_PKG.INSERT_ROW(
           X_ROWID  => l_rowid,
    	   X_ACTIVITY => p_activity_tbl(i).ACTIVITY,
    	   X_COST_ANALYSIS_CODE => p_activity_tbl(i).COST_ANALYSIS_CODE,
    	   X_DELETE_MARK => 0,
    	   X_TEXT_CODE => p_activity_tbl(i).TEXT_CODE,
    	   X_TRANS_CNT => p_activity_tbl(i).TRANS_CNT,
    	   X_ACTIVITY_DESC => p_activity_tbl(i).ACTIVITY_DESC,
    	   X_CREATION_DATE => sysdate,
    	   X_CREATED_BY => gmd_api_grp.user_id,
    	   X_LAST_UPDATE_DATE => sysdate,
    	   X_LAST_UPDATED_BY => gmd_api_grp.user_id,
    	   X_LAST_UPDATE_LOGIN => gmd_api_grp.user_id);
               IF (l_debug = 'Y') THEN
                    gmd_debug.put_line('End Loop -  insert_activity private');
               END IF;
         END LOOP;

      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('END of Insert_activity private');
      END IF;

      EXCEPTION
        WHEN setup_failure OR duplicate_activity THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
            			       P_data  => x_message_list);
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
            FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
            FND_MSG_PUB.ADD;
            FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
            			                         P_data  => x_message_list);
     END Insert_Activity;


   /*===========================================================================================
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
     ,p_activity		IN 	gmd_activities.activity%TYPE
     ,p_update_table		IN	gmd_activities_pub.update_tbl_type
     ,x_message_count 		OUT NOCOPY  	NUMBER
     ,x_message_list 		OUT NOCOPY  	VARCHAR2
     ,x_return_status		OUT NOCOPY  	VARCHAR2 )  IS

     CURSOR retrieve_activity_table_values(v_activity  VARCHAR2) IS
        SELECT *
        FROM gmd_activities
        WHERE activity = v_activity;

      v_update_rec  		gmd_activities%ROWTYPE;

     setup_failure  		EXCEPTION;
     inv_activity_err		EXCEPTION;


  BEGIN
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(' In update_activity private');
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    OPEN retrieve_activity_table_values(p_activity);
    FETCH retrieve_activity_table_values INTO v_update_rec;
    IF retrieve_activity_table_values%NOTFOUND THEN
      gmd_api_grp.log_message ('FM_INVACTIVITY');
      CLOSE retrieve_activity_table_values;
      RAISE inv_activity_err;
    END IF;
    CLOSE retrieve_activity_table_values;

    FOR i IN 1 .. p_update_table.count LOOP
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Begin Loop - in update_activity loop (private).  Col to update is ' || p_update_table(i).p_col_to_update);
      END IF;
      IF UPPER(p_update_table(i).p_col_to_update) = 'COST_ANALYSIS_CODE' THEN
        v_update_rec.cost_analysis_code := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK' THEN
        v_update_rec.delete_mark := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'TEXT_CODE' THEN
        v_update_rec.text_code := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'TRANS_CNT' THEN
        v_update_rec.trans_cnt := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ACTIVITY_DESC' THEN
        v_update_rec.activity_desc := p_update_table(i).p_value;
      END IF;
    END LOOP;

    GMD_ACTIVITIES_PKG.UPDATE_ROW(
                   X_ACTIVITY 		=> p_activity
                  ,X_COST_ANALYSIS_CODE => v_update_rec.cost_analysis_code
                  ,X_DELETE_MARK 	=> v_update_rec.delete_mark
                  ,X_TEXT_CODE 		=> v_update_rec.text_code
                  ,X_TRANS_CNT 		=> v_update_rec.trans_cnt
                  ,X_ACTIVITY_DESC 	=> v_update_rec.activity_desc
                  ,X_LAST_UPDATE_DATE 	=> sysdate
             	  ,X_LAST_UPDATED_BY 	=> gmd_api_grp.user_id
             	  ,X_LAST_UPDATE_LOGIN	=> gmd_api_grp.login_id);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('END of update_activity private');
    END IF;

  EXCEPTION
    WHEN setup_failure OR inv_activity_err THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
	                         P_data  => x_message_list);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
	                         P_data  => x_message_list);
  END update_activity;
END GMD_ACTIVITIES_PVT;

/
