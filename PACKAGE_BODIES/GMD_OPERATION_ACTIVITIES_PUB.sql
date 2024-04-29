--------------------------------------------------------
--  DDL for Package Body GMD_OPERATION_ACTIVITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATION_ACTIVITIES_PUB" AS
/*  $Header: GMDPOPAB.pls 120.0.12010000.2 2009/03/16 06:34:37 kannavar ship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDPOPAB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for  			   |
 |     creating, modifying, deleting operation activities                  |
 |                                                                         |
 | HISTORY                                                                 |
 |     21-AUG-2002  Sandra Dulyk    Created                                |
 | 20-FEB-2004 NSRIVAST  Bug# 3222090                                      |
 |                       Removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')|
 +=========================================================================+
  API Name  : GMD_OPERATION_ACTIVITIES_PUB
  Type      : Public
  Function  : This package contains public procedures used to create, modify, and delete operation activties
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

  /*==============================================
  Procedure
     insert_operation_activity
  Description
    This particular procedure is used to insert an
    operation activity Parameters
  ================================================ */
  PROCEDURE insert_operation_activity
  ( p_api_version 	IN              NUMBER
  , p_init_msg_list	IN              BOOLEAN
  , p_commit		IN              BOOLEAN
  , p_oprn_no		IN              gmd_operations.oprn_no%TYPE
  , p_oprn_vers		IN              gmd_operations.oprn_vers%TYPE
  , p_oprn_activity	IN OUT NOCOPY 	gmd_operation_activities%ROWTYPE
  , p_oprn_rsrc_tbl	IN              gmd_operation_resources_pub.gmd_oprn_resources_tbl_type
  , x_message_count 	OUT NOCOPY  	NUMBER
  , x_message_list 	OUT NOCOPY  	VARCHAR2
  , x_return_status	OUT NOCOPY  	VARCHAR2)    IS

    v_activity	        gmd_operation_activities.activity%TYPE;
    v_oprn_line_Id 	gmd_operation_activities.oprn_line_id%TYPE;
    v_oprn_id	        gmd_operation_activities.oprn_id%TYPE;
    v_count	        NUMBER;

   l_retn_status	VARCHAR2(1);
   l_api_version	NUMBER := 1.0;

   setup_failure  	EXCEPTION;
   invalid_version  	EXCEPTION;
   ins_oprn_actv_err	EXCEPTION;

   CURSOR check_oprn_id (p_oprn_id gmd_operations.oprn_id%TYPE)IS
      SELECT 1
      FROM gmd_operations_b
      WHERE oprn_id = p_oprn_id
       AND delete_mark = 0;

   CURSOR check_oprn_no_vers(p_oprn_no gmd_operations.oprn_no%TYPE
                           , p_oprn_vers gmd_operations.oprn_vers%TYPE ) IS
     SELECT oprn_id
     FROM gmd_operations_b
     WHERE oprn_No = p_oprn_no
         AND oprn_vers = p_oprn_vers
         and delete_Mark = 0;

   CURSOR check_activity(v_activity gmd_operation_activities.activity%TYPE) IS
     SELECT 1
     FROM gmd_activities
     WHERE activity = v_activity
     and delete_mark = 0;

   CURSOR Cur_gen_oprnline_id IS
      SELECT GEM5_OPRNLINE_ID_S.NEXTVAL
      FROM   FND_DUAL;

 BEGIN
   SAVEPOINT insert_oprn_actv;

   /* Initialize message list and count if needed */
   IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
   END IF;

   IF (l_debug = 'Y') THEN
     gmd_debug.put_line('In insert_operation_activity public.');
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
                                ,'insert_operation_activity'
                                ,'gmd_operation_activities_pub') THEN
      RAISE invalid_version;
   END IF;

   /* Operation number ID must be passed, otherwise give error, also check operation exists */
   IF (p_oprn_activity.oprn_id IS NULL) THEN
      IF ((p_oprn_no IS NULL) OR (p_oprn_vers IS NULL)) THEN
     	FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_NO');
        FND_MSG_PUB.ADD;
      ELSE
        OPEN check_oprn_no_vers(p_oprn_no, p_oprn_vers);
        FETCH check_oprn_no_vers INTO v_oprn_id;
         IF check_oprn_no_vers%NOTFOUND  THEN
            /* must pass existing operation no and vers */
            FND_MESSAGE.SET_NAME('GMD','FM_INVOPRN');
            FND_MSG_PUB.ADD;
            RAISE ins_oprn_actv_err;
         END IF;
        CLOSE check_oprn_no_vers;
      END IF;
   ELSE
     v_oprn_id := p_oprn_activity.oprn_id;
   END IF;

   /* Operation Security Validation */
   /* Validation: Check if this users performing update has access to this
      operation owner orgn code */
   IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                       ,Entity_id  => v_oprn_id) THEN
     RAISE ins_oprn_actv_err;
   END IF;

   /* Activity must be passed, otherwise give error */
   IF p_oprn_activity.activity IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation activity required');
      END IF;

      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ACTIVITY');
      FND_MSG_PUB.ADD;
      RAISE ins_oprn_actv_err;
   ELSE
      v_activity := p_oprn_activity.activity;
      OPEN check_activity(v_activity);
      FETCH check_activity INTO v_count;
      IF check_activity%NOTFOUND THEN
        /* must pass existing activity */
        FND_MESSAGE.SET_NAME('GMD','FM_INVACTIVITY');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_actv_err;
      END IF;
      CLOSE check_activity;
   END IF;

   /* check activity factor has a value else default */
   IF p_oprn_activity.activity_factor IS NULL THEN
       p_oprn_activity.activity_factor := 1;
   ELSIF p_oprn_activity.activity_factor < 0 THEN
       gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                                'FIELD', 'ACTIVITY_FACTOR');
       RAISE ins_oprn_actv_err;
   END IF;

   /* check offset interval has a value else default */
   IF p_oprn_activity.offset_interval IS NULL THEN
       p_oprn_activity.offset_interval := 0;
   ELSIF p_oprn_activity.offset_interval < 0 THEN
       gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                                'FIELD','OFFSET_INTERVAL');
       RAISE ins_oprn_actv_err;
   END IF;

   /* check sequence_dependent_ind has a value else default */
   IF p_oprn_activity.sequence_dependent_ind IS NULL THEN
       p_oprn_activity.sequence_dependent_ind := 0;
   ELSIF p_oprn_activity.sequence_dependent_ind NOT IN (1,0) THEN
       FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_SEQ_DEP_IND');
       FND_MSG_PUB.ADD;
       RAISE ins_oprn_actv_err;
   END IF;

   /* generate oprnline_id */
   OPEN Cur_gen_oprnline_id;
   FETCH Cur_gen_oprnline_id INTO p_oprn_activity.oprn_line_id;
   CLOSE Cur_gen_oprnline_id;

   IF x_return_status = 'S' THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('before PVT insert_oprn_activity routine called');
      END IF;

      /* call insert operation activity routine using oprn_id */
      GMD_OPERATION_ACTIVITIES_PVT.insert_operation_activity(
           	                   p_oprn_id       => v_oprn_id,
           	                   p_oprn_activity => p_oprn_activity,
      		                   x_message_count => x_message_count,
      		                   x_message_list  => x_message_list,
      		                   x_return_status => l_retn_status);

      IF l_retn_status <> FND_API.g_ret_sts_success THEN
        RAISE ins_oprn_actv_err;
      END IF;

      /* Added the below call in Bug No.8316321 */
      GMD_API_GRP.set_activity_sequence_num (P_oprn_id => v_oprn_id,
                                           P_user_id => fnd_global.user_id,
                                           P_login_id => fnd_global.login_id);


      IF p_oprn_rsrc_tbl.count > 0  THEN
         /* call insert operation resources */
         GMD_OPERATION_RESOURCES_PUB.insert_operation_resources(
                                   p_init_msg_list => FALSE,
		                   p_oprn_line_id  => p_oprn_activity.oprn_line_id,
		                   p_oprn_rsrc_tbl => p_oprn_rsrc_tbl,
            	                   x_message_count => x_message_count,
        	                   x_message_list  => x_message_list,
      		                   x_return_status => l_retn_status);
         IF l_retn_status <> FND_API.g_ret_sts_success THEN
           RAISE ins_oprn_actv_err;
         END IF;
      END IF;

      IF p_commit THEN
         COMMIT;
      END IF;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                              ,p_data    => x_message_list);
  EXCEPTION
    WHEN setup_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT insert_oprn_actv;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       			        P_data  => x_message_list);
    WHEN ins_oprn_actv_err THEN
          ROLLBACK TO SAVEPOINT insert_oprn_actv;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      	                             P_data  => x_message_list);
     WHEN OTHERS THEN
          ROLLBACK TO SAVEPOINT insert_oprn_actv;
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
    This particular procedure is used to update
    an operation activity Parameters
  ================================================ */
  PROCEDURE update_operation_activity
  ( p_api_version 	IN          NUMBER
  , p_init_msg_list 	IN          BOOLEAN
  , p_commit		IN          BOOLEAN
  , p_oprn_line_id	IN          gmd_operation_activities.oprn_line_id%TYPE
  , p_update_table	IN          gmd_operation_activities_pub.update_tbl_type
  , x_message_count 	OUT NOCOPY  NUMBER
  , x_message_list 	OUT NOCOPY  VARCHAR2
  , x_return_status	OUT NOCOPY  VARCHAR2)    IS

    v_oprn_id           gmd_operations.oprn_id%TYPE;
    l_retn_status       VARCHAR2(1);
    l_api_version       NUMBER := 1.0;

    invalid_version	EXCEPTION;
    setup_failure	EXCEPTION;
    upd_oprn_actv_err   EXCEPTION;

    CURSOR get_oprn_id(p_oprN_line_id gmd_operation_activities.oprn_line_id%TYPE) IS
    SELECT oprn_id
    FROM   gmd_operation_activities
    WHERE  oprn_line_id = p_oprn_line_id
      AND  delete_mark = 0;

  BEGIN
    SAVEPOINT upd_oprn_actv;

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
                                      ,'update_operation_activity'
                                      ,'gmd_operation_activities_pub') THEN
      RAISE invalid_version;
    END IF;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Start of update_operation_activity PUB');
    END IF;

    /* Oprn_line_id must be passed, otherwise give error */
    IF p_oprn_line_id IS NULL THEN
       IF (l_debug = 'Y') THEN
         gmd_debug.put_line('operation line id is required');
       END IF;

       FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
       FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_LINE_ID');
       FND_MSG_PUB.ADD;
       RAISE upd_oprn_actv_err;
    END IF;

         /* Loop thru cols to be updated - verify col and value are present */
    FOR i in 1 .. p_update_table.count LOOP
        /* Col_to_update and value must be passed, otherwise give error */
      IF p_update_table(i).p_col_to_update IS NULL THEN
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line('col_to_update required');
         END IF;

         FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
         FND_MESSAGE.SET_TOKEN ('MISSING', 'COL_TO_UPDATE');
         FND_MSG_PUB.ADD;
         RAISE upd_oprn_actv_err;
      ELSIF p_update_table(i).p_value IS NULL THEN
         IF (l_debug = 'Y') THEN
           gmd_debug.put_line('value required');
         END IF;

         FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
         FND_MESSAGE.SET_TOKEN ('MISSING', 'P_VALUE');
         FND_MSG_PUB.ADD;
         RAISE upd_oprn_actv_err;
      END IF;
     END LOOP;

     /* Validation : Verify Operation status is not On Hold nor Obsolete/Archived
       and Operation is not logically deleted */
     OPEN get_oprn_id(p_oprn_line_id);
     FETCH get_oprn_id INTO v_oprn_id;
     IF get_oprn_id%NOTFOUND THEN
       gmd_api_grp.log_message('GMD_INVALID_OPRNLINE_ID');
       x_return_status := FND_API.g_ret_sts_error;
     END IF;
     CLOSE get_oprn_id;

     /* Operation Security Validation */
     /* Validation: Check if this users performing update has access to this
          operation owner orgn code */
     IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                     ,Entity_id  => v_oprn_id) THEN
       RAISE upd_oprn_actv_err;
     END IF;

     IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'OPERATION',
                                        Entity_id => v_oprn_id ) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_OPRN_NOT_VALID');
         FND_MSG_PUB.ADD;
         RAISE upd_oprn_actv_err;
     END IF;

         /* delete_mark validation */
     FOR a IN 1 .. p_update_table.count  LOOP
        /* check activity factor has a value else default */
       IF (UPPER(p_update_table(a).p_col_to_update) = 'ACTIVITY_FACTOR' AND
           p_update_table(a).p_value < 0) THEN
          gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                                        'FIELD', p_update_table(a).p_col_to_update);
          RAISE upd_oprn_actv_err;
       /* check offset interval has a value else default */
       ELSIF (UPPER(p_update_table(a).p_col_to_update) = 'OFFSET_INTERVAL' AND
          p_update_table(a).p_value < 0) THEN
          gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                                        'FIELD', p_update_table(a).p_col_to_update);
          RAISE upd_oprn_actv_err;
       ELSIF (UPPER(p_update_table(a).p_col_to_update) = 'SEQUENCE_DEPENDENT_IND' AND
          p_update_table(a).p_value NOT IN (1,0)) THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_SEQ_DEP_IND');
          FND_MSG_PUB.ADD;
          RAISE upd_oprn_actv_err;
       END IF;
     END LOOP;

     IF x_return_status = 'S' THEN
        GMD_OPERATION_ACTIVITIES_PVT.update_operation_activity(p_oprn_line_id => p_oprn_line_id
        					, p_update_table	=> p_update_table
        					, x_message_count => x_message_count
        					, x_message_list 	=> x_message_list
        					, x_return_status 	=> l_retn_status);
        IF l_retn_status <> FND_API.g_ret_sts_success THEN
          RAISE upd_oprn_actv_err;
        END IF;

        /* Added the below call in Bug No.8316321 */
        GMD_API_GRP.set_activity_sequence_num (P_oprn_id => v_oprn_id,
                                           P_user_id => fnd_global.user_id,
                                           P_login_id => fnd_global.login_id);

        IF p_commit THEN
           COMMIT;
        END IF;

     END IF;

     FND_MSG_PUB.count_and_get(p_count   => x_message_count
                              ,p_data    => x_message_list);

  EXCEPTION
    WHEN setup_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT upd_oprn_actv;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      			      P_data  => x_message_list);
    WHEN upd_oprn_actv_err THEN
         ROLLBACK TO SAVEPOINT upd_oprn_actv;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      			      P_data  => x_message_list);

    WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT upd_oprn_actv;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
        			     P_data  => x_message_list);


  END update_operation_activity;

  /*================================================
  Procedure
     delete_operation_activity
  Description
    This particular procedure is used to delete an
    operation activity Parameters
  ================================================ */
  PROCEDURE delete_operation_activity
  ( p_api_version 		IN 	NUMBER
  , p_init_msg_list	 	IN 	BOOLEAN
  , p_commit		IN 	BOOLEAN
  , p_oprn_line_id		IN	gmd_operation_activities.oprn_line_id%TYPE
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2)  IS

    v_update_table   		gmd_operation_activities_pub.update_tbl_type;
    v_count		NUMBER;
    l_retn_status		VARCHAR2(1);
    l_api_version		NUMBER := 1.0;
    l_oprn_id		NUMBER(15);

    invalid_version		EXCEPTION;
    setup_failure		EXCEPTION;
    del_oprn_actv_err		EXCEPTION;

    CURSOR chk_oprn_line_id(v_oprN_line_id NUMBER) IS
      SELECT oprn_id
      FROM gmd_operation_activities
      WHERE oprn_line_id = v_oprn_line_id;

    CURSOR get_activity_count (v_oprn_id NUMBER) IS
      SELECT COUNT(1)
      FROM gmd_operation_activities a
      WHERE a.oprn_id = v_oprn_id;

  BEGIN
    SAVEPOINT delete_oprn_actv;

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
                                       ,'delete_operation_activity'
                                       ,'gmd_operation_activities_pvt') THEN
       RAISE invalid_version;
    END IF;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('START of delete_operation_activity PUB');
    END IF;


    /* Operation Line ID must be passed, otherwise give error */
    IF p_oprn_line_id IS NULL  THEN
       IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Operation Line id is required');
       END IF;

       FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
       FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_LINE_ID');
       FND_MSG_PUB.ADD;
       RAISE del_oprn_actv_err;
    ELSE
       OPEN chk_oprn_line_id(p_oprn_line_id);
       FETCH chk_oprn_line_Id INTO l_oprn_id;
       IF chk_oprn_line_ID%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_OPRNLINE_ID');
          FND_MSG_PUB.ADD;
          RAISE del_oprn_actv_err;
       ELSE
         OPEN get_activity_count (l_oprn_id);
         FETCH get_activity_count INTO v_count;
         CLOSE get_activity_count;
         IF v_count = 1 THEN
           gmd_api_grp.log_message ('GMD_DETAILS_REQUIRED');
           RAISE del_oprn_actv_err;
         END IF;
       END IF;
       CLOSE chk_oprN_line_id;
    END IF;

    /* Operation Security Validation */
    /* Validation: Check if this users performing update has access to this
       operation owner orgn code */
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                        ,Entity_id  => l_oprn_id) THEN
      RAISE del_oprn_actv_err;
    END IF;

    IF x_return_status = 'S' THEN
       gmd_operation_activities_pvt.delete_operation_activity
                                   (p_oprn_line_id  => p_oprn_line_id
                                  , x_message_count => x_message_count
                                  , x_message_list  => x_message_list
                                  , x_return_status => l_retn_status);
       IF l_retn_status <> FND_API.g_ret_sts_success THEN
         RAISE del_oprn_actv_err;
       END IF;

       IF p_commit THEN
         COMMIT;
       END IF;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                              ,p_data    => x_message_list);

  EXCEPTION
      WHEN setup_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT delete_oprn_actv;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
        			      P_data  => x_message_list);
      WHEN del_oprn_actv_err THEN
           ROLLBACK TO SAVEPOINT delete_oprn_actv;
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
        			      P_data  => x_message_list);
      WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT delete_oprn_actv;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         			                         P_data  => x_message_list);
  END delete_operation_activity;

END GMD_OPERATION_ACTIVITIES_PUB;

/
