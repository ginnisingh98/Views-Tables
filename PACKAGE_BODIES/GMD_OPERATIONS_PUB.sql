--------------------------------------------------------
--  DDL for Package Body GMD_OPERATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATIONS_PUB" AS
/*  $Header: GMDPOPSB.pls 120.3 2006/09/20 14:53:46 kmotupal noship $
 ************************************************************************************
 *                                                                                  *
 * Package  GMD_OPERATIONS_PUB                                                      *
 *                                                                                  *
 * Contents: INSERT_OPERATION	                                                    *
 *	     UPDATE_OPERATION	                                                    *
 *           DELETE_OPERATION	                                                    *
 *                                                                                  *
 * Use      This is the public layer of the GMD Operation API                       *
 *                                                                                  *
 *                                                                                  *
 * History                                                                          *
 *         Written by Sandra Dulyk, OPM Development                                 *
 *     25-NOV-2002  Thomas Daniel   Bug# 2679110                                    *
 *                                  Rewrote the procedures to handle the            *
 *                                  errors properly and also to handle              *
 *                                  further validations                             *
 *    21-OCT-2003  Shyam S          Commented section in update_operation           *
 *                                  procedure that check if p_value is              *
 *                                  passes or not                                   *
 *    20-FEB-2004  NSRIVAST         Bug# 3222090,Removed call to                    *
 *                                  FND_PROFILE.VALUE('AFLOG_ENABLED')              *
 *  Shyam S         09-14-04        Added validations in insert, update and delete  *
 *                                  that chceks for user access to owner orgn code  *
 ***********************************************************************************
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
   insert_operation
Description
  This particular procedure is used to insert an operation
Parameters
WHO        WHEN          WHAT
kkillams   10-MAR-2004   New p_oprn_rsrc_tbl input paramter is added to proceudre to pass the
                         resource details for activities. Added validation to check if default
                         status is 400/700 for the context organization then activity should have the
                         resources w.r.t. bug# 3408799
==================================================================================================== */
  PROCEDURE insert_operation (
   p_api_version 	IN 	      NUMBER
  ,p_init_msg_list 	IN 	      BOOLEAN
  ,p_commit		IN 	      BOOLEAN
  ,p_operations 	IN OUT NOCOPY gmd_operations%ROWTYPE
  ,p_oprn_actv_tbl	IN OUT NOCOPY gmd_operations_pub.gmd_oprn_activities_tbl_type
  ,x_message_count 	OUT NOCOPY    NUMBER
  ,x_message_list 	OUT NOCOPY    VARCHAR2
  ,x_return_status      OUT NOCOPY    VARCHAR2
  ,p_oprn_rsrc_tbl      IN            gmd_operation_resources_pub.gmd_oprn_resources_tbl_type) IS

     v_oprn_id                  gmd_operations.oprn_id%TYPE;
     v_oprn_no                  gmd_operations.oprn_no%TYPE;
     v_oprn_vers                gmd_operations.oprn_vers%TYPE;
     p_ret                      NUMBER;
     v_oprn_class               gmd_operations.oprn_class%TYPE;
     l_retn_status              VARCHAR2(1);
     my_rsrc_table_type         gmd_operation_resources_pub.gmd_oprn_resources_tbl_type;
     l_api_version              NUMBER := 1.0;
     l_entity_status            gmd_api_grp.status_rec_type;  ---bug# 3408799
     default_status_err         EXCEPTION;
     l_resource_count           NUMBER;

     invalid_version	EXCEPTION;
     setup_failure	EXCEPTION;
     ins_operation_err	EXCEPTION;

     CURSOR Cur_gen_oprn_id IS
        SELECT GEM5_OPRN_ID_S.NEXTVAL
        FROM   FND_DUAL;

  BEGIN
    SAVEPOINT insert_oprn;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                      ,p_api_version
                                      ,'insert_operation'
                                      ,'gmd_operations_pub') THEN
      RAISE invalid_version;
    END IF;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Intializes the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    /* Operation number must be passed, otherwise give error */
    IF p_operations.oprn_no IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation number required');
      END IF;

      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_NO');
      FND_MSG_PUB.ADD;
      RAISE ins_operation_err;
    END IF;

    /* Operation Version must be passed, otherwise give error */
    IF p_operations.oprn_vers IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation version required');
      END IF;

      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_VERS');
      FND_MSG_PUB.ADD;
      RAISE ins_operation_err;
    ELSIF p_operations.oprn_vers < 0 THEN
      gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                               'FIELD', 'OPRN_VERS');
      RAISE ins_operation_err;
    END IF;

    /* Check for duplicate oprn_no/vers */
    v_oprn_no := p_operations.oprn_no;
    v_oprn_vers := p_operations.oprn_vers;
    /* call common function which checks for duplicate operation no and vers */
    P_ret := gmdopval_pub.check_duplicate_oprn(v_oprn_no, v_oprn_vers, 'F');
    IF p_ret <> 0 THEN
      gmd_api_grp.log_message('FM_OPER_CODE_EXISTS');
      RAISE ins_operation_err;
    END IF;

    /* Description must be passed, otherwise give error */
    IF p_operations.oprn_desc IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation desc required');
      END IF;

      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_DESC');
      FND_MSG_PUB.ADD;
      RAISE ins_operation_err;
    END IF;

    /* PROCESS_QTY_UOM must be passed, otherwise give error */
    IF p_operations.PROCESS_QTY_UOM IS NULL THEN
       IF (l_debug = 'Y') THEN
         gmd_debug.put_line('process qty uom required');
       END IF;

      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'PROCESS_QTY_UOM');
      FND_MSG_PUB.ADD;
      RAISE ins_operation_err;
      /* call common function to check if um passed is valid */
    ELSIF (NOT(gmd_api_grp.validate_um(p_operations.PROCESS_QTY_UOM))) THEN
     	IF (l_debug = 'Y') THEN
       	  gmd_debug.put_line('process qty uom invalid');
      	END IF;

      FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
      FND_MSG_PUB.ADD;
      RAISE ins_operation_err;
    END IF;

    /*
     *  Convergence related fix - Shyam S
     *
     */
    --Check that organization id is not null if raise an error message
    IF (p_operations.owner_organization_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if organization is accessible to the responsibility
    IF NOT (GMD_API_GRP.OrgnAccessible (powner_orgn_id => p_operations.owner_organization_id) ) THEN
      RAISE ins_operation_err;
    END IF;

    --Check the organization id passed is process enabled if not raise an error message
    IF NOT (gmd_api_grp.check_orgn_status(p_operations.owner_organization_id)) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
      FND_MESSAGE.SET_TOKEN('ORGN_ID', p_operations.owner_organization_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Effective start date must be passed, otherwise give error */
    IF p_operations.effective_start_date IS NULL THEN
      p_operations.effective_start_date := TRUNC(SYSDATE);
    ELSE
      p_operations.effective_start_date := TRUNC(p_operations.effective_start_date);
    END IF;

    IF p_operations.effective_end_date IS NOT NULL THEN
      p_operations.effective_end_date := TRUNC(p_operations.effective_end_date);
      /* Effective end date must be greater than start date, otherwise give error */
      IF p_operations.effective_start_date > p_operations.effective_end_date THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('effective start date must be less then end date');
        END IF;
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        RAISE ins_operation_err;
      END IF;
    END IF;

    IF p_operations.minimum_transfer_qty < 0 THEN
      gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                               'FIELD', 'MINIMUM_TRANSFER_QTY');
      RAISE ins_operation_err;
    END IF;

    /* Operation Class Validation - valid operation class must be passed */
    IF p_operations.oprn_class IS NOT NULL THEN
      /* calls common funciton which checks if class is valid */
      v_oprn_class := p_operations.oprn_class;
      P_ret := gmdopval_pub.check_oprn_class(v_oprn_class, 'F');
      IF P_ret <> 0 THEN
        gmd_api_grp.log_message('FM_INV_OPRN_CLASS');
      END IF;
    END IF;

    OPEN Cur_gen_oprn_id;
    FETCH cur_gen_oprn_id into p_operations.oprn_id;
    CLOSE cur_gen_oprn_id;

    /* At least one activity must be passed to add operation */
    IF (p_oprn_actv_tbl.count = 0) THEN
      gmd_api_grp.log_message ('GMD_DETAILS_REQUIRED');
      RAISE ins_operation_err;
    END IF;

    IF x_return_status = 'S' THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('before PVT routine called');
      END IF;

      /* insert operation */
      GMD_OPERATIONS_PVT.insert_operation(p_operations =>   p_operations,
               		                  x_message_count =>   x_message_count,
        				  x_message_list  =>   x_message_list,
      				          x_return_status =>   l_retn_status);
      IF l_retn_status <> FND_API.g_ret_sts_success THEN
        RAISE ins_operation_err;
      END IF;


      /* validate oprn activity info and insert oprn activity */
      FOR i in 1.. p_oprn_actv_tbl.count LOOP
        p_oprn_actv_tbl(i).oprn_id := p_operations.oprn_id;
        --Getting the default status for the owner orgn code fo operation from parameters table w.r.t. bug#3408799
        gmd_api_grp.get_status_details(v_entity_type   => 'OPERATION'
                                      ,v_orgn_id       => p_operations.owner_organization_id  -- w.r.t. 4004501
                                      ,x_entity_status => l_entity_status);

        --Copy the all related resources for the context activity w.r.t. bug#3408799
        l_resource_count :=0;
        FOR j in 1 ..p_oprn_rsrc_tbl.count
        LOOP
          IF (p_oprn_actv_tbl(i).oprn_line_id = p_oprn_rsrc_tbl(j).oprn_line_id) OR
             (p_oprn_actv_tbl(i).activity = p_oprn_rsrc_tbl(j).activity)  THEN
             l_resource_count :=l_resource_count+1;
             my_rsrc_table_type(l_resource_count) :=p_oprn_rsrc_tbl(j);
          END IF; --p_oprn_actv_tbl(i).oprn_line_id = p_oprn_rsrc_tbl(j).oprn_line_id
        END LOOP; --j in 1 ..p_oprn_rsrc_tbl.count

        --Raise error if default status is 400/700 and no activites are attached w.r.t. bug#3408799
        IF l_entity_status.status_type IN (400,700) AND l_resource_count = 0 THEN
           gmd_api_grp.log_message('GMD_RESOURCE_NOT_ATTACH');
           RAISE ins_operation_err;
        END IF; --l_entity_status.status_type IN (400,700) AND l_resource_count = 0

        GMD_OPERATION_ACTIVITIES_PUB.insert_operation_activity(p_init_msg_list =>   FALSE,
                                                               p_oprn_activity =>   p_oprn_actv_tbl(i),
                                                               p_oprn_rsrc_tbl =>   my_rsrc_table_type,
                                                               x_message_count =>   x_message_count,
                                                               x_message_list  =>   x_message_list,
                                                               x_return_status =>   l_retn_status);

        IF l_retn_status <> FND_API.g_ret_sts_success THEN
          RAISE ins_operation_err;
        END IF;
        my_rsrc_table_type.delete;
      END LOOP; --i in 1.. p_oprn_actv_tbl.count

      IF p_commit THEN
         COMMIT;
         SAVEPOINT default_status_sp;

         /* -- Why call this again
         --Getting the default status for the owner orgn code fo operation from parameters table w.r.t. bug#3408799
         gmd_api_grp.get_status_details(v_entity_type   => 'OPERATION'
                                       ,v_orgn_code     => p_operations.owner_orgn_code
                                       ,x_entity_status => l_entity_status);

         */

          --Add this code after the call to gmd_recipes_mls.insert_row.
         IF (l_entity_status.entity_status <> 100) THEN
            Gmd_status_pub.modify_status ( p_api_version        => 1
                                         , p_init_msg_list      => TRUE
                                         , p_entity_name        => 'OPERATION'
                                         , p_entity_id          => p_operations.oprn_id
                                         , p_entity_no          => NULL
                                         , p_entity_version     => NULL
                                         , p_to_status          => l_entity_status.entity_status
                                         , p_ignore_flag        => FALSE
                                         , x_message_count      => x_message_count
                                         , x_message_list       => x_message_list
                                         , x_return_status      => l_retn_status);
            IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
               RAISE default_status_err;
            END IF; --x_return_status
         END IF; --l_entity_status.entity_status <> 100
         COMMIT;
      END IF; ---p_commit
    END IF;

    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

  EXCEPTION
    WHEN setup_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT insert_oprn;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
 	                            P_data  => x_message_list);
    WHEN ins_operation_err THEN
       ROLLBACK TO SAVEPOINT insert_oprn;
       x_return_status := FND_API.g_ret_sts_error;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
 	                          P_data  => x_message_list);
    WHEN default_status_err THEN
      ROLLBACK TO default_status_sp;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.Count_And_Get (
			p_count => x_message_count,
			p_data  => x_message_list   );
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT insert_oprn;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
 	                            P_data  => x_message_list);
  END Insert_Operation;


  /*===========================================================================================
  Procedure
    update_operation
  Description
    This particular procedure is used to update an operation
  Parameters
  ================================================ */
  PROCEDURE update_operation
  ( p_api_version 		IN 	NUMBER
  , p_init_msg_list 		IN 	BOOLEAN
  , p_commit			IN 	BOOLEAN
  , p_oprn_id			IN	gmd_operations.oprn_id%TYPE
  , p_oprn_no			IN	gmd_operations.oprn_no%TYPE
  , p_oprn_vers			IN	gmd_operations.oprn_vers%TYPE
  , p_update_table		IN	gmd_operations_pub.update_tbl_type
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2)  IS

   v_oprn_id			gmd_operations.oprn_id%TYPE;
   l_retn_status		VARCHAR2(1);
   l_api_version		NUMBER := 1.0;

   l_start_date                 VARCHAR2(30);
   l_end_date                   VARCHAR2(30);
   l_owner_orgn_id              NUMBER;

   invalid_version		EXCEPTION;
   setup_failure		EXCEPTION;
   upd_oprn_err			EXCEPTION;

  CURSOR get_oprn_id (v_oprn_no VARCHAR2, v_oprn_vers NUMBER) IS
    SELECT oprn_id
    FROM gmd_operations
    where oprn_no = v_oprn_no
    and oprn_vers = v_oprn_vers;

  CURSOR check_oprn_id (v_oprn_id NUMBER) IS
    SELECT oprn_id
    FROM gmd_operations
    where oprn_id = v_oprn_id;

  CURSOR get_orgn_id (v_oprn_id NUMBER) IS
    SELECT OWNER_ORGANIZATION_ID
    FROM gmd_operations
    where oprn_id = v_oprn_id;

    l_orgn_id NUMBER;

  BEGIN
    SAVEPOINT update_oprn;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call(l_api_version
                                      ,p_api_version
                                      ,'update_operation'
                                      ,'gmd_operations_pub') THEN
      RAISE invalid_version;
    END IF;

    /* Intializes the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('Start of update_operation PUB');
    END IF;

    /* Oprn_id or oprn_no and vers must be passed, otherwise give error */
    IF (p_oprn_id IS NULL AND (p_oprn_no IS NULL OR p_oprn_vers IS NULL ))THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('operation id or operation number and version are  required');
      END IF;

      IF (p_oprn_id IS NULL) THEN
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_ID');
        FND_MSG_PUB.ADD;
      ELSE
        FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
        FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_NO, OPRN_VERS');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE upd_oprn_err;
    ELSIF p_oprn_id IS NOT NULL THEN
      OPEN check_oprn_id(p_oprn_id);
      FETCH check_oprn_id INTO v_oprn_id;
      IF check_oprn_id%NOTFOUND THEN
        gmd_api_grp.log_message ('FM_INVOPRN');
        RAISE upd_oprn_err;
      END IF;
      CLOSE check_oprn_id;
    ELSIF ((p_oprn_no IS NOT NULL) AND (p_oprn_vers IS NOT NULL)) THEN
      OPEN get_oprn_id(p_oprn_no, p_oprn_vers);
      FETCH get_oprn_id INTO v_oprn_id;
      IF get_oprn_id%NOTFOUND THEN
        gmd_api_grp.log_message ('FM_INVOPRN');
        RAISE upd_oprn_err;
      END IF;
      CLOSE get_oprn_id;
    END IF;

        -- Bug# 5552324 Kapil M
        -- Added the check for Org Responsibility access.
    OPEN get_orgn_id(p_oprn_id);
    FETCH get_orgn_id INTO l_orgn_id;
    CLOSE get_orgn_id;
    IF NOT (GMD_API_GRP.OrgnAccessible (powner_orgn_id => l_orgn_id ) ) THEN
      RAISE upd_oprn_err;
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
        RAISE upd_oprn_err;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'PROCESS_QTY_UOM' THEN
        IF (NOT(gmd_api_grp.validate_um(p_update_table(i).p_value))) THEN
       	  IF (l_debug = 'Y') THEN
       	    gmd_debug.put_line('process qty uom invalid');
      	  END IF;
          FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
          FND_MSG_PUB.ADD;
          RAISE upd_oprn_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'MINIMUM_TRANSFER_QTY' THEN
        IF p_update_table(i).p_value < 0 THEN
          gmd_api_grp.log_message ('GMD_NEGATIVE_FIELDS',
                                   'FIELD', 'MINIMUM_TRANSFER_QTY');
          RAISE upd_oprn_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OPRN_CLASS' THEN
        IF gmdopval_pub.check_oprn_class(p_update_table(i).p_value, 'F') <> 0 THEN
          gmd_api_grp.log_message('FM_INV_OPRN_CLASS');
          RAISE upd_oprn_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OPRN_DESC' THEN
        IF p_update_table(i).p_value IS NULL THEN
          FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
          FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_DESC');
          FND_MSG_PUB.ADD;
          RAISE upd_oprn_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK' THEN
        GMDRTVAL_PUB.check_delete_mark ( Pdelete_mark    => p_update_table(i).p_value,
                                        x_return_status => l_retn_status);
        IF l_retn_status <> 'S' THEN /* it indicates that invalid value has been passed */
           FND_MESSAGE.SET_NAME('GMA', 'SY_BADDELETEMARK');
           FND_MSG_PUB.ADD;
           RAISE upd_oprn_err;
        END IF;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OWNER_ORGANIZATION_ID' THEN
        /* Validation :  Check if owner_orgn_idis valid */
        l_owner_orgn_id :=  p_update_table(i).p_value;
        IF NOT GMD_API_GRP.OrgnAccessible(l_owner_orgn_id) THEN
          RAISE upd_oprn_err;
        END IF;
      END IF;

       /* Validation : Verify Operation status is not On Hold nor Obsolete/Archived
       and Operation is not logically deleted */
      IF v_oprn_id IS NOT NULL THEN
        IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED
                           (Entity => 'OPERATION',
                            Entity_id => v_oprn_id,
                            Update_Column_name => p_update_table(i).p_col_to_update) THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_OPRN_NOT_VALID');
          FND_MSG_PUB.ADD;
          RAISE upd_oprn_err;
        END IF;
      END IF;
    END LOOP;

    IF x_return_status = 'S' THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('before PVT routine called');
      END IF;

      GMD_OPERATIONS_PVT.update_operation(p_oprn_id		=> v_oprn_id
       					, p_update_table	=> p_update_table
       					, x_message_count 	=> x_message_count
       					, x_message_list 	=> x_message_list
       					, x_return_status 	=> l_retn_status);
      IF l_retn_status <> FND_API.g_ret_sts_success THEN
        RAISE upd_oprn_err;
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
    WHEN invalid_version or setup_failure THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO SAVEPOINT update_oprn;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       	                          P_data  => x_message_list);
    WHEN upd_oprn_err THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO SAVEPOINT update_oprn;
       FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
       	                          P_data  => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_oprn;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
         	                    P_data  => x_message_list);

  END update_operation;

  /*===========================================================================================
  Procedure
    delete_operation
  Description
    This particular procedure is used to set delete_mark = 1 for an operation
  Parameters
  ================================================ */
  PROCEDURE delete_operation (
    p_api_version 		IN 	NUMBER
  , p_init_msg_list	 	IN 	BOOLEAN
  , p_commit		IN 	BOOLEAN
  , p_oprn_id		IN	gmd_operations.oprn_id%TYPE
  , p_oprn_no		IN	gmd_operations.oprn_no%TYPE
  , p_oprn_vers		IN	gmd_operations.oprn_vers%TYPE
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2 )  IS

   v_update_table   		gmd_operations_pub.update_tbl_type;
   l_retn_status		VARCHAR2(1);
   l_api_version		NUMBER := 1.0;

   upd_oprn_err		EXCEPTION;
  BEGIN
    SAVEPOINT delete_oprn;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
      fnd_msg_pub.initialize;
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('START of delete_operation PUB');
    END IF;

    /* Call update_operation and set delete mark for given activity to 1*/
    v_update_table(1).p_col_to_update := 'DELETE_MARK';
    v_update_table(1).p_value := '1';

    /* call update with oprn id if that is what is passed */
    update_operation(p_api_version	=> p_api_version
                    ,p_init_msg_list	=> FALSE
                    ,p_oprn_id	    	=> p_oprn_id
                    ,p_oprn_no		=> p_oprn_no
                    ,p_oprn_vers	=> p_oprn_vers
                    ,p_update_table     => v_update_table
                    ,x_message_count    => x_message_count
        	    ,x_message_list 	=> x_message_list
       		    ,x_return_status 	=> l_retn_status);

    IF l_retn_status <> FND_API.g_ret_sts_success THEN
      RAISE upd_oprn_err;
    END IF;

    IF p_commit THEN
      COMMIT;
    END IF;

    /* Adding message to stack indicating the success of the routine */
    gmd_api_grp.log_message ('GMD_SAVED_CHANGES');
    FND_MSG_PUB.count_and_get(p_count   => x_message_count
                             ,p_data    => x_message_list);

    IF (l_debug = 'Y') THEN
      gmd_debug.put_line('END of delete_operation PUB');
    END IF;

  EXCEPTION
    WHEN upd_oprn_err THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO SAVEPOINT delete_oprn;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
    	                         P_data  => x_message_list);
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT delete_oprn;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.COUNT_AND_GET (P_count => x_message_count,
	                         P_data  => x_message_list);

  END delete_operation;

END GMD_OPERATIONS_PUB;

/
