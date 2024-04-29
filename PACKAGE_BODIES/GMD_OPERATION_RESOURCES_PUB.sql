--------------------------------------------------------
--  DDL for Package Body GMD_OPERATION_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATION_RESOURCES_PUB" AS
/*  $Header: GMDPOPRB.pls 120.1.12010000.2 2008/11/06 21:48:32 rpatangy ship $
 +=========================================================================+
 | FILENAME                                                                |
 |     GMDPOPRB.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains public definitions for  			   |
 |     creating, modifying, deleting operation resources                   |
 |                                                                         |
 | HISTORY                                                                 |
 |     22-AUG-2002  Sandra Dulyk    Created                                |
 |     25-NOV-2002  Thomas Daniel   Bug# 2679110                           |
 |                                  Rewrote the procedures to handle the   |
 |                                  errors properly and also to handle     |
 |                                  further validations                    |
 |     20-FEB-2004  NSRIVAST        Bug# 3222090, Removed call to          |
 |                                  FND_PROFILE.VALUE('AFLOG_ENABLED')     |
 |     20-APR-2006  KMOTUPAL        Bug# 5172254  Closed the cursors before|
 |                                  raising the exception if a validation  |
 |                                  fails.                                 |
 |     26-MAY-2008  KBANDDYO       Bug#7118558: column um_code is replaced |
 |                                 with uom_code and table sy_uoms_mst is  |
 |                                 replaced with mtl_units_of_measure      |
 +=========================================================================+
  API Name  : GMD_OPERATION_RESOURCES_PUB
  Type      : Public
  Function  : This package contains public procedures used to create, modify, and delete operation resources
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

  Previous Vers : 1.0

  Initial Vers  : 1.0
  Notes
*/

  /* Global Cursors */
  CURSOR check_oprn_line_id(V_oprn_line_id NUMBER) IS
     SELECT 1
     FROM gmd_operation_activities
     WHERE oprn_line_id = v_oprn_line_id;


     --Bug#7118558
  CURSOR check_uom(v_uom VARCHAR2) IS
     SELECT 1
     FROM mtl_units_of_measure
     WHERE uom_Code = v_uom
       AND (disable_date IS NULL or disable_date > SYSDATE);    /* pku */


  CURSOR check_cost_cmpntcls_id(v_cost_cmpntcls_id NUMBER) IS
      SELECT 1
      FROM cm_cmpt_mst
      WHERE COST_CMPNTCLS_id = v_cost_cmpntcls_id
                      AND delete_mark = 0;

  CURSOR check_cost_analysis_code(v_cost_analysis_code VARCHAR2) IS
      SELECT 1
      FROM cm_alys_mst
      WHERE cost_analysis_code = v_cost_analysis_code
                      AND delete_mark = 0;

  CURSOR check_Resource(p_oprn_line_id NUMBER, p_resources VARCHAR2)  IS
      SELECT 1
      FROM gmd_operation_resources
      WHERE oprn_line_id = p_oprn_line_id
      AND  resources = p_resources;

  CURSOR check_one_prim_rsrc (V_oprn_line_id NUMBER) IS
      SELECT COUNT(1)
      FROM gmd_operation_resources
      WHERE oprn_line_id = V_oprn_line_id
      AND prim_rsrc_ind  = 1;

  CURSOR check_atleast_one (V_oprn_line_id NUMBER, V_resources VARCHAR2) IS
      SELECT COUNT(1)
      FROM gmd_operation_resources
      WHERE oprn_line_id = V_oprn_line_id
      AND  (V_resources IS NULL OR resources <> V_resources)
      AND  prim_rsrc_ind = 1;


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

  /*================================================
  Procedure
     insert_operation_resources
  Description
    This particular procedure is used to insert an
    operation resources Parameters
  ================================================ */
  PROCEDURE insert_operation_resources
  ( p_api_version 	IN 	    NUMBER
  , p_init_msg_list	IN 	    BOOLEAN
  , p_commit		IN 	    BOOLEAN
  , p_oprn_line_id	IN	    gmd_operation_activities.oprn_line_id%TYPE
  , p_oprn_rsrc_tbl	IN 	    gmd_operation_resources_pub.gmd_oprn_resources_tbl_type
  , x_message_count 	OUT NOCOPY  NUMBER
  , x_message_list 	OUT NOCOPY  VARCHAR2
  , x_return_status	OUT NOCOPY  VARCHAR2)  IS

    v_resources		   gmd_operation_resources.resources%TYPE;
    v_uom     		   gmd_operation_resources.resource_usage_uom%TYPE;
    v_cost_cmpntcls_id	   gmd_operation_resources.cost_cmpntcls_id%TYPE;
    v_cost_analysis_code   gmd_operation_resources.cost_analysis_code%TYPE;
    v_count		   NUMBER DEFAULT 0;
    l_return_status	   VARCHAR2(1);
    l_api_version          NUMBER := 1.0;

    setup_failure  	EXCEPTION;
    invalid_version	EXCEPTION;
    ins_oprn_rsrc_err	EXCEPTION;
    inv_resource_ind	EXCEPTION;

    CURSOR get_oprn_id(V_oprn_line_id NUMBER) IS
      SELECT oprn_id
      FROM   gmd_operation_activities
      WHERE  oprn_line_id = V_oprn_line_id;

    CURSOR fetch_proc_uom (V_oprn_line_id NUMBER) IS
      SELECT process_qty_uom
      FROM   gmd_operations a, gmd_operation_activities b
      WHERE  a.oprn_id = b.oprn_id
      AND    b.oprn_line_id = V_oprn_line_id;

    CURSOR get_resource_det (V_resources VARCHAR2) IS
      SELECT cr.cost_cmpntcls_id
      FROM   cr_rsrc_mst cr, cm_cmpt_mst cm
      WHERE  cr.cost_cmpntcls_id = cm.cost_cmpntcls_id
      AND    cr.resources = V_resources
      AND    cr.delete_mark = 0
      AND    cm.delete_mark = 0
      AND    cm.usage_ind = 3;

    CURSOR get_cost_analysis_code (V_oprn_line_id NUMBER) IS
      SELECT cost_analysis_code
      FROM   fm_actv_mst a, gmd_operation_activities o
      WHERE  o.activity = a.activity
      AND    o.oprn_line_id = V_oprn_line_id;

--Bug#7118558
    CURSOR Cur_get_resource_usage_uom(V_resources VARCHAR2)  IS
      SELECT std_usage_uom
      FROM   cr_rsrc_mst
      WHERE  resources = V_resources;

    l_cost_cmpntcls_id	cm_cmpt_mst.cost_cmpntcls_id%TYPE;
    l_oprn_id           NUMBER;
    l_oprn_rsrc_tbl 	gmd_operation_resources_pub.gmd_oprn_resources_tbl_type;
    l_rsrc_count	NUMBER(5);
    l_usage_uom         VARCHAR2(4);
  BEGIN
    SAVEPOINT insert_oprn_rsrc;

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
                                       ,'insert_operation_resources'
                                       ,'gmd_operation_resources_pub') THEN
      RAISE invalid_version;
    END IF;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('In insert_operation_resources public.');
    END IF;

    /* Operation Line ID must be passed, otherwise give error, also check operation line id exists */
    IF p_oprn_line_id IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation line ID is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_LINE_ID');
      FND_MSG_PUB.ADD;
      RAISE ins_oprn_rsrc_err;
    ELSIF p_oprn_line_id IS NOT NULL THEN
      /* check to see that it is valid id */
      OPEN check_oprn_line_id(p_oprn_line_id);
      FETCH check_oprn_line_id INTO v_count;
      IF check_oprn_line_id%NOTFOUND THEN
        /* must pass existing operation line id */
        FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_OPRNLINE_ID');
        FND_MSG_PUB.ADD;
      CLOSE check_oprn_line_id;
        RAISE ins_oprn_rsrc_err;
      END IF;
      CLOSE check_oprn_line_id;
    END IF;

    /* Operation Security Validation */
    OPEN get_oprn_id(p_oprn_line_id);
    FETCH get_oprn_id INTO l_oprn_id;
    CLOSE get_oprn_id;

    /* Operation Security Validation */
    /* Validation: Chcek if this users performing update has access to this
       operation owner orgn code */
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                        ,Entity_id  => l_oprn_id) THEN
      RAISE ins_oprn_rsrc_err;
    END IF;

    FOR i in 1 .. p_oprn_rsrc_tbl.count LOOP
      /* Lets initialize the local structure which will be passed to private layer */
      l_oprn_rsrc_tbl(i) := p_oprn_rsrc_tbl(i);

      /* Resource must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).resources IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('operation resource required');
        END IF;
  	FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'RESOURCES');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      ELSE   /* check resource exists */
        v_resources := l_oprn_rsrc_tbl(i).resources;
        OPEN get_resource_det(v_resources);
        FETCH get_resource_det INTO l_cost_cmpntcls_id;
        IF get_resource_det%NOTFOUND THEN
          /* must pass valid resource */
          FND_MESSAGE.SET_NAME('GMD','FM_BAD_RESOURCE');
          FND_MSG_PUB.ADD;
        CLOSE get_resource_det;
          RAISE ins_oprn_rsrc_err;
        END IF;
        CLOSE get_resource_det;
      END IF;

      /* Process_Qty must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).process_qty IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('resource process qty required');
        END IF;
	FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'PROCESS_QTY');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      ELSIF l_oprn_rsrc_tbl(i).process_qty < 0 THEN
        FND_MESSAGE.SET_TOKEN('GMD', 'FM_PROCQTYERR');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* resource usagemust be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).resource_usage IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('resource usage required');
        END IF;

        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'RESOURCE_USAGE');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      END IF;

      -- Negative usage
      IF l_oprn_rsrc_tbl(i).resource_usage < 0 THEN
        FND_MESSAGE.SET_NAME('GMD', 'FM_RESUSGERR');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* If Usage is not passed, derive the default from resource */
      IF l_oprn_rsrc_tbl(i).resource_usage_uom IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('resource usage uom required');
        END IF;
        OPEN Cur_get_resource_usage_uom(l_oprn_rsrc_tbl(i).resources);
      	FETCH Cur_get_resource_usage_uom INTO l_oprn_rsrc_tbl(i).resource_usage_uom;
      	  IF Cur_get_resource_usage_uom%NOTFOUND THEN
      	     FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
             FND_MESSAGE.SET_TOKEN ('MISSING', 'resource_usage_uom');
             FND_MSG_PUB.ADD;
        CLOSE Cur_get_resource_usage_uom;
             RAISE ins_oprn_rsrc_err;
          END IF;
        CLOSE Cur_get_resource_usage_uom;
      ELSE  /* check uom exists */
        v_uom := l_oprn_rsrc_tbl(i).resource_usage_uom;
        OPEN check_uom(v_uom);
        FETCH check_uom INTO v_count;
        IF check_uom%NOTFOUND THEN
          /* must pass existing uom */
          FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
          FND_MSG_PUB.ADD;
        CLOSE check_uom;
          RAISE ins_oprn_rsrc_err;
        END IF;
        CLOSE check_uom;
      END IF;

      /* cost component id, otherwise give error */
      IF l_oprn_rsrc_tbl(i).cost_cmpntcls_id IS NULL THEN
        l_oprn_rsrc_tbl(i).cost_cmpntcls_id := l_cost_cmpntcls_id;
      ELSE   /* check cost_cmpntcls_id exists */
        v_cost_cmpntcls_id := l_oprn_rsrc_tbl(i).cost_cmpntcls_id;
        OPEN check_cost_cmpntcls_id(v_cost_cmpntcls_id);
        FETCH check_cost_cmpntcls_id INTO v_count;
        IF check_cost_cmpntcls_id%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_CMPNTCLS_ID');
          FND_MSG_PUB.ADD;
        CLOSE check_cost_cmpntcls_id;
          RAISE ins_oprn_rsrc_err;
        END IF;
        CLOSE check_cost_cmpntcls_id;
      END IF;

      /* Cost Analysis code must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).cost_analysis_code IS NULL THEN
        OPEN get_cost_analysis_code (P_oprn_line_id);
        FETCH get_cost_analysis_code INTO l_oprn_rsrc_tbl(i).cost_analysis_code;
        CLOSE get_cost_analysis_code;
      ELSE   /* check cost_analysis_code exists */
        v_cost_analysis_code := l_oprn_rsrc_tbl(i).cost_analysis_code;
        OPEN check_cost_analysis_code(v_cost_analysis_code);
        FETCH check_cost_analysis_code INTO v_count;
        IF check_cost_analysis_code%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
          FND_MSG_PUB.ADD;
        CLOSE check_cost_analysis_code;
          RAISE ins_oprn_rsrc_err;
        END IF;
        CLOSE check_cost_analysis_code;
      END IF;

      IF l_oprn_rsrc_tbl(i).prim_rsrc_ind IS NULL THEN
        l_oprn_rsrc_tbl(i).prim_rsrc_ind := 0;
      END IF;
      /* Plan Type/Resource Indicator should be valid */
      IF l_oprn_rsrc_tbl(i).prim_rsrc_ind NOT IN (0,1,2) THEN
        gmd_api_grp.log_message ('FM_RSRCINDERR');
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* Resource Count must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).resource_count IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Resource Count required');
 	END IF;
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'RESOURCE_COUNT');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      ELSIF l_oprn_rsrc_tbl(i).resource_count < 0 THEN
        gmd_api_grp.log_message ('FM_RESCOUNTERR');
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* Offset Interval must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).offset_interval IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Offset interval required');
        END IF;
	FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'OFFSET_INTERVAL');
        FND_MSG_PUB.ADD;
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* Scale Type must be passed, otherwise give error */
      IF l_oprn_rsrc_tbl(i).scale_type IS NULL THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Scale Type is null assigning default 1');
 	END IF;
        l_oprn_rsrc_tbl(i).scale_type := 1;
      ELSIF l_oprn_rsrc_tbl(i).scale_type NOT IN (0, 1, 2) THEN
        gmd_api_grp.log_message ('FM_SCALETYPERR');
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* Lets initialialize the default values */
      IF x_return_status = FND_API.g_ret_sts_success THEN
        OPEN fetch_proc_uom (p_oprn_line_id);
        FETCH fetch_proc_uom INTO l_oprn_rsrc_tbl(i).resource_process_uom;
        CLOSE fetch_proc_uom;
      END IF;
    END LOOP;

    IF x_return_status = 'S' THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('before PVT routine called');
      END IF;

      GMD_OPERATION_RESOURCES_PVT.insert_operation_resources(p_oprn_line_id 	=> p_oprn_line_id,
							     p_oprn_rsrc_tbl 	=> l_oprn_rsrc_tbl,
         				  		     x_message_count 	=>   x_message_count,
        				  		     x_message_list     =>   x_message_list,
       				  			     x_return_status    =>   l_return_status);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE ins_oprn_rsrc_err;
      END IF;

      /* Let us check if their are more than one resource marked as primary */
      OPEN  check_one_prim_rsrc (p_oprn_line_id);
      FETCH check_one_prim_rsrc INTO v_count;
      CLOSE check_one_prim_rsrc;
      IF v_count > 1 THEN
        gmd_api_grp.log_message ('GMD_ONE_PRIMARY_RESOURCE');
        RAISE inv_resource_ind;
      END IF;

      /* This implies that we are setting this current resource as secondary or auxillary */
      /* so let us check if their exists atleast one primary resource */
      OPEN  check_atleast_one (p_oprn_line_id, NULL);
      FETCH check_atleast_one INTO v_count;
      CLOSE check_atleast_one;
      IF v_count = 0 THEN
        gmd_api_grp.log_message ('GMD_MIN_ONE_PRIMARY_RESOURCE');
        RAISE inv_resource_ind;
      END IF;

      IF p_commit THEN
        COMMIT;
      END IF;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('End of insert_operation_resource PUB');
    END IF;
  EXCEPTION
    WHEN setup_failure OR invalid_version OR inv_resource_ind THEN
      ROLLBACK TO SAVEPOINT insert_oprn_rsrc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       		                 P_data  => x_message_list);
    WHEN ins_oprn_rsrc_err THEN
      ROLLBACK TO SAVEPOINT insert_oprn_rsrc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       		                 P_data  => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT insert_oprn_rsrc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
                                 P_data  => x_message_list);
  END insert_operation_resources;

  /*========================================================
  Procedure
     update_operation_resources
  Description
    This particular procedure is used to update operation resources
    Parameters
  ================================================ */
  PROCEDURE update_operation_resources
  ( p_api_version 		IN 	NUMBER
  , p_init_msg_list 		IN 	BOOLEAN
  , p_commit			IN 	BOOLEAN
  , p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
  , p_resources			IN	gmd_operation_resources.resources%TYPE
  , p_update_table		IN	gmd_operation_resources_pub.update_tbl_type
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2)    IS

     v_oprn_id 			gmd_operations.oprn_id%TYPE;
     l_return_status		VARCHAR2(1);
     l_api_version		NUMBER := 1.0;
     l_exist			NUMBER(5);

     invalid_version		EXCEPTION;
     setup_failure		EXCEPTION;

    CURSOR get_oprn_id (p_oprN_line_id gmd_operation_resources.oprn_line_id%TYPE) IS
      SELECT oprn_id
      FROM gmd_operation_activities
      WHERE oprn_line_id = p_oprn_line_id;

    upd_oprn_rsrc_err	EXCEPTION;
  BEGIN
    SAVEPOINT update_oprn_rsrc;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                       ,p_api_version
                                       ,'update_operation_resources'
                                       ,'gmd_operation_resources_pub') THEN
      RAISE invalid_version;
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

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Start of update_operation_activity PUB');
    END IF;

    /* Oprn_line_id must be passed, otherwise give error */
    IF p_oprn_line_id IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_LINE_ID');
      FND_MSG_PUB.ADD;
      RAISE upd_oprn_rsrc_err;
    ELSE   /* check oprn_line_id exists */
      OPEN check_oprn_line_id(p_oprn_line_id);
      FETCH check_oprn_line_id INTO l_exist;
      IF check_oprn_line_id%NOTFOUND THEN
      	FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_OPRNLINE_ID');
        FND_MSG_PUB.ADD;
      CLOSE check_oprn_line_id;
	RAISE upd_oprn_rsrc_err;
      END IF;
      CLOSE check_oprn_line_id;
    END IF;

    /* Resources must be passed, otherwise give error */
    IF p_resources IS NULL THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'P_RESOURCES');
      FND_MSG_PUB.ADD;
      RAISE upd_oprn_rsrc_err;
    ELSE   /* check resource exists */
      OPEN check_resource(p_oprn_line_id, p_resources);
      FETCH check_resource INTO l_exist;
      IF check_resource%NOTFOUND THEN
        /* must pass valid resource */
    	FND_MESSAGE.SET_NAME('GMD','FM_BAD_RESOURCE');
        FND_MSG_PUB.ADD;
      CLOSE check_resource;
	RAISE upd_oprn_rsrc_err;
      END IF;
      CLOSE check_resource;
    END IF;

    /* Loop thru cols to be updated - verify col and value are present */
    FOR i in 1 .. p_update_table.count LOOP
      /* Col_to_update and value must be passed, otherwise give error */
      IF p_update_table(i).p_col_to_update IS NULL THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'P_COL_TO_UPDATE');
        FND_MSG_PUB.ADD;
        RAISE upd_oprn_rsrc_err;
      ELSIF p_update_table(i).p_value IS NULL THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'P_VALUE');
        FND_MSG_PUB.ADD;
        RAISE upd_oprn_rsrc_err;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'COST_ANALYSIS_CODE' THEN
        OPEN check_cost_analysis_code(p_update_table(i).p_value);
        FETCH check_cost_analysis_code INTO l_exist;
        IF check_cost_analysis_code%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_ANLYS_CODE');
          FND_MSG_PUB.ADD;
        CLOSE check_cost_analysis_code;
          RAISE upd_oprn_rsrc_err;
        END IF;
        CLOSE check_cost_analysis_code;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'RESOURCE_USAGE' THEN
        IF p_update_table(i).p_value < 0 THEN
          gmd_api_grp.log_message('FM_RESUSGERR');
          RAISE upd_oprn_rsrc_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'PROCESS_QTY' THEN
        IF p_update_table(i).p_value < 0 THEN
          gmd_api_grp.log_message('FM_PROCQTYERR');
          RAISE upd_oprn_rsrc_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'resource_usage_uom' THEN
        OPEN check_uom(p_update_table(i).p_value);
        FETCH check_uom INTO l_exist;
        IF check_uom%NOTFOUND THEN
          /* must pass existing uom */
          FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
          FND_MSG_PUB.ADD;
        CLOSE check_uom;
          RAISE upd_oprn_rsrc_err;
        END IF;
        CLOSE check_uom;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'COST_CMPNTCLS_ID' THEN
        OPEN check_cost_cmpntcls_id(p_update_table(i).p_value);
        FETCH check_cost_cmpntcls_id INTO l_exist;
        IF check_cost_cmpntcls_id%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_COST_CMPNTCLS_ID');
          FND_MSG_PUB.ADD;
        CLOSE check_cost_cmpntcls_id;
          RAISE upd_oprn_rsrc_err;
        END IF;
        CLOSE check_cost_cmpntcls_id;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'PRIM_RSRC_IND' THEN
        IF p_update_table(i).p_value NOT IN (0, 1, 2) THEN
          gmd_api_grp.log_message ('FM_RSRCINDERR');
          RAISE upd_oprn_rsrc_err;
        ELSIF p_update_table(i).p_value = 1 THEN
          /* This implies that we are setting this current resource as primary */
          /* so let us check if their are any other primaries already existing */
          OPEN  check_one_prim_rsrc (p_oprn_line_id);
          FETCH check_one_prim_rsrc INTO l_exist;
          CLOSE check_one_prim_rsrc;
          IF l_exist > 0 THEN
            gmd_api_grp.log_message ('GMD_ONE_PRIMARY_RESOURCE');
            RAISE upd_oprn_rsrc_err;
          END IF;
        ELSIF p_update_table(i).p_value IN (0,2) THEN
          /* This implies that we are setting this current resource as secondary or auxillary */
          /* so let us check if their exists atleast one primary resource */
          OPEN  check_atleast_one (p_oprn_line_id, p_resources);
          FETCH check_atleast_one INTO l_exist;
          CLOSE check_atleast_one;
          IF l_exist = 0 THEN
            gmd_api_grp.log_message ('GMD_MIN_ONE_PRIMARY_RESOURCE');
            RAISE upd_oprn_rsrc_err;
          END IF;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'RESOURCE_COUNT' THEN
        IF p_update_table(i).p_value < 0 THEN
          gmd_api_grp.log_message ('FM_RESCOUNTERR');
          RAISE upd_oprn_rsrc_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OFFSET_INTERVAL' THEN
        IF p_update_table(i).p_value < 0 THEN
          gmd_api_grp.log_message('GMD_INVALID_OFFSET');
          RAISE upd_oprn_rsrc_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'SCALE_TYPE' THEN
        IF p_update_table(i).p_value NOT IN (0, 1, 2) THEN
          gmd_api_grp.log_message ('FM_SCALETYPERR');
          RAISE upd_oprn_rsrc_err;
        END IF;
      END IF;
    END LOOP;

    OPEN get_oprn_id(p_oprn_line_id);
    FETCH get_oprn_id INTO v_oprn_id;
    CLOSE get_oprn_id;

    /* Operation Security Validation */
    /* Validation: Chcek if this users performing update has access to this
       operation owner orgn code */
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                    ,Entity_id  => v_oprn_id) THEN
      RAISE upd_oprn_rsrc_err;
    END IF;

    /* Validation : Verify Operation status is not On Hold nor Obsolete/Archived
    and Operation is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'OPERATION',
                                         Entity_id => v_oprn_id ) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_OPRN_NOT_VALID');
      FND_MSG_PUB.ADD;
      RAISE upd_oprn_rsrc_err;
    END IF;

    IF x_return_status = 'S' THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('before PVT routine called');
      END IF;

      GMD_OPERATION_RESOURCES_PVT.update_operation_resources(p_oprn_line_id 	=> p_oprn_line_id
       							, p_resources 		=> p_resources
       							, p_update_table	=> p_update_table
       							, x_message_count 	=> x_message_count
       							, x_message_list 	=> x_message_list
       							, x_return_status 	=> l_return_status);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE upd_oprn_rsrc_err;
      END IF;
      IF p_commit THEN
        COMMIT;
      END IF;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                              ,p_data    => x_message_list);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('END of update_operation_resource PUB');
    END IF;

  EXCEPTION
    WHEN invalid_version OR setup_failure THEN
      ROLLBACK TO SAVEPOINT update_oprn_rsrc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
      		                 P_data  => x_message_list);
    WHEN upd_oprn_rsrc_err THEN
      ROLLBACK TO SAVEPOINT update_oprn_rsrc;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       		                 P_data  => x_message_list);
     WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT update_oprn_rsrc;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
		                  P_data  => x_message_list);
  END update_operation_resources;

  /*=============================================================
  Procedure
   delete_operation_resources
  Description
    This particular procedure is used to delete operation resources
    Parameters
  ================================================ */
  PROCEDURE delete_operation_resources
  ( p_api_version 		IN 	NUMBER
  , p_init_msg_list 		IN 	BOOLEAN
  , p_commit		IN 	BOOLEAN
  , p_oprn_line_id		IN	gmd_operation_resources.oprn_line_id%TYPE
  , p_resources		IN 	gmd_operation_resources.resources%TYPE
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2)  IS

   v_update_table   		gmd_operation_resources_pub.update_tbl_type;
   v_count			NUMBER;
   l_return_status		VARCHAR2(1);
   l_api_version		NUMBER := 1.0;
   v_oprn_id                    NUMBER;

   invalid_version		EXCEPTION;
   setup_failure		EXCEPTION;
   del_oprn_rsrc_err		EXCEPTION;
   inv_resource_ind		EXCEPTION;

   CURSOR check_oprn_line_id(p_oprn_line_id NUMBER) IS
     SELECT 1
     FROM gmd_operation_activities
     WHERE oprn_line_id = p_oprn_line_id;

   CURSOR check_Resource(p_oprn_line_id NUMBER, p_resources VARCHAR2)  IS
     SELECT 1
     FROM gmd_operation_resources
     WHERE oprn_line_id = p_oprn_line_id
     AND   resources = p_resources;

    CURSOR get_oprn_id (p_oprN_line_id gmd_operation_resources.oprn_line_id%TYPE) IS
      SELECT oprn_id
      FROM gmd_operation_activities
      WHERE oprn_line_id = p_oprn_line_id;

  BEGIN
    SAVEPOINT delete_oprn_rsrc;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                       ,p_api_version
                                       ,'delete_operation_resources'
                                       ,'gmd_operation_resources_pub') THEN
      RAISE invalid_version;
    END IF;

    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('START of delete_operation_resources PUB');
    END IF;

    /* Operation Line ID must be passed, otherwise give error */
    IF (p_oprn_line_id IS NULL OR p_resources IS NULL) THEN
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'P_OPRN_LINE_ID');
      FND_MSG_PUB.ADD;
      RAISE del_oprn_rsrc_err;
    ELSE   /* check oprn_line_id and resource exist */
      OPEN check_oprn_line_id(p_oprn_line_id);
      FETCH check_oprn_line_id INTO v_count;
      IF check_oprn_line_id%NOTFOUND THEN
        /* must pass valid oprn_line_id */
      	FND_MESSAGE.SET_NAME('GMD','GMD_INVALID_OPRNLINE_ID');
        FND_MSG_PUB.ADD;
        CLOSE check_oprn_line_id;   /* pku */
        RAISE del_oprn_rsrc_err;
      ELSE
        OPEN check_resource(p_oprn_line_id, p_resources);
        FETCH check_resource INTO v_count;
        IF check_resource%NOTFOUND THEN
          /* must pass valid resource */
          FND_MESSAGE.SET_NAME('GMD','FM_BAD_RESOURCE');
          FND_MSG_PUB.ADD;
          CLOSE check_resource;
          CLOSE check_oprn_line_id; /* pku */
	  RAISE del_oprn_rsrc_err;
        END IF;
        CLOSE check_resource;
      END IF;
      CLOSE check_oprn_line_id;
    END IF;

    /* get the oprn_id */
    OPEN get_oprn_id(p_oprn_line_id);
    FETCH get_oprn_id INTO v_oprn_id;
    CLOSE get_oprn_id;

    /* Operation Security Validation */
    /* Validation: Chcek if this users performing update has access to this
       operation owner orgn code */
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'OPERATION'
                                    ,Entity_id  => v_oprn_id) THEN
      RAISE del_oprn_rsrc_err;
    END IF;


    IF x_return_status = FND_API.g_ret_sts_success THEN
      /* Call PVT delete_operation_resources */
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('before call to delete_operation_resource PVT');
      END IF;
      gmd_operation_resources_pvt.delete_operation_resource(p_oprn_line_id    => p_oprn_line_id
            						   ,p_resources    => p_resources
                       					   , x_message_count => x_message_count
		       					   , x_message_list 	=> x_message_list
       							   , x_return_status 	=> l_return_status);
      IF l_return_status <> FND_API.g_ret_sts_success THEN
        RAISE del_oprn_rsrc_err;
      END IF;

      /* This implies that we are setting this current resource as secondary or auxillary */
      /* so let us check if their exists atleast one primary resource */
      OPEN  check_atleast_one (p_oprn_line_id, NULL);
      FETCH check_atleast_one INTO v_count;
      CLOSE check_atleast_one;
      IF v_count = 0 THEN
        gmd_api_grp.log_message ('GMD_MIN_ONE_PRIMARY_RESOURCE');
        RAISE inv_resource_ind;
      END IF;

      IF p_commit THEN
        COMMIT;
      END IF;
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                              ,p_data    => x_message_list);

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('END of delete_operation_resources PUB');
    END IF;

  EXCEPTION
     WHEN invalid_version OR setup_failure OR inv_resource_ind THEN
        ROLLBACK TO SAVEPOINT delete_oprn_rsrc;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
        	                   P_data  => x_message_list);
     WHEN del_oprn_rsrc_err THEN
        ROLLBACK TO SAVEPOINT delete_oprn_rsrc;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
        		           P_data  => x_message_list);
     WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_oprn_rsrc;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         		            P_data  => x_message_list);
  END delete_operation_resources;

END GMD_OPERATION_RESOURCES_PUB;

/
