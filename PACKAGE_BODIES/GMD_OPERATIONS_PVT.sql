--------------------------------------------------------
--  DDL for Package Body GMD_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OPERATIONS_PVT" AS
/*  $Header: GMDVOPSB.pls 120.0 2005/05/25 19:47:44 appldev noship $
 ********************************************************************
 *                                                                  *
 * Package  GMD_OPERATIONS_PVT                                      *
 *                                                                  *
 * Contents: INSERT_OPERATION	                                    *
 *	   UPDATE_OPERATION  	                                    *
 *                                                                  *
 * Use      This is the private layer of the GMD Operations API     *
 *                                                                  *
 *                                                                  *
 * History                                                          *
 *         Written by Sandra Dulyk, OPM Development                 *
 * 25-NOV-2002  Thomas Daniel   Bug# 2679110                        *
 *              Added more validations and fixed the update proc    *
 * 20-FEB-2004  NSRIVAST  Bug# 3222090,Removed call to              *
 *                        FND_PROFILE.VALUE('AFLOG_ENABLED')        *
 ********************************************************************
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

   /*======================================================
   Procedure
      insert_operation
   Description
     This particular procedure is used to insert an operation
   Parameters
    ================================================ */
  PROCEDURE insert_operation
  ( p_api_version 	IN 	    NUMBER
  , p_init_msg_list 	IN 	    BOOLEAN
  , p_commit		IN 	    BOOLEAN
  , p_operations 	IN 	    gmd_operations%ROWTYPE
  , x_message_count 	OUT NOCOPY  NUMBER
  , x_message_list 	OUT NOCOPY  VARCHAR2
  , x_return_status	OUT NOCOPY  VARCHAR2)   IS

    l_rowid VARCHAR2(30);
    setup_failure EXCEPTION;
  BEGIN
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(' In insert_operation private');
    END IF;

    /* Initially let us assign the return status to success */
     x_return_status := FND_API.g_ret_sts_success;

    /* Set row who columns */
     IF NOT gmd_api_grp.setup_done THEN
        gmd_api_grp.setup_done := gmd_api_grp.setup;
     END IF;
     IF NOT gmd_api_grp.setup_done THEN
        RAISE setup_failure;
     END IF;

     GMD_OPERATIONS_PKG.INSERT_ROW(
	    X_ROWID => l_rowid	,
	    X_OPRN_ID => p_operations.oprn_id,
	    X_ATTRIBUTE30 => p_operations.ATTRIBUTE30,
	    X_ATTRIBUTE_CATEGORY => p_operations.ATTRIBUTE_CATEGORY,
	    X_ATTRIBUTE25 => p_operations.ATTRIBUTE25,
	    X_ATTRIBUTE26 => p_operations.ATTRIBUTE26,
	    X_ATTRIBUTE27 => p_operations.ATTRIBUTE27,
	    X_ATTRIBUTE28 => p_operations.ATTRIBUTE28,
	    X_ATTRIBUTE29 => p_operations.ATTRIBUTE29,
	    X_ATTRIBUTE22 => p_operations.ATTRIBUTE22,
	    X_ATTRIBUTE23 => p_operations.ATTRIBUTE23,
	    X_ATTRIBUTE24 => p_operations.ATTRIBUTE24,
	    X_OPRN_NO => p_operations.OPRN_NO,
	    X_OPRN_VERS => p_operations.OPRN_VERS,
	    X_PROCESS_QTY_UOM => p_operations.PROCESS_QTY_UOM,
	    X_MINIMUM_TRANSFER_QTY => p_operations.MINIMUM_TRANSFER_QTY,
	    X_OPRN_CLASS => p_operations.OPRN_CLASS,
	    X_INACTIVE_IND => 0,
	    X_EFFECTIVE_START_DATE => p_operations.EFFECTIVE_START_DATE,
	    X_EFFECTIVE_END_DATE => p_operations.EFFECTIVE_END_DATE,
	    X_DELETE_MARK => 0,
	    X_TEXT_CODE => p_operations.TEXT_CODE,
	    X_ATTRIBUTE1 => p_operations.ATTRIBUTE1,
	    X_ATTRIBUTE2 => p_operations.ATTRIBUTE2,
	    X_ATTRIBUTE3 => p_operations.ATTRIBUTE3,
	    X_ATTRIBUTE4 => p_operations.ATTRIBUTE4,
	    X_ATTRIBUTE5 => p_operations.ATTRIBUTE5,
	    X_ATTRIBUTE6 => p_operations.ATTRIBUTE6,
	    X_ATTRIBUTE7 => p_operations.ATTRIBUTE7,
	    X_ATTRIBUTE8 => p_operations.ATTRIBUTE8,
	    X_ATTRIBUTE9 => p_operations.ATTRIBUTE9,
	    X_ATTRIBUTE10 => p_operations.ATTRIBUTE10,
	    X_ATTRIBUTE11 => p_operations.ATTRIBUTE11,
	    X_ATTRIBUTE12 => p_operations.ATTRIBUTE12,
	    X_ATTRIBUTE13 => p_operations.ATTRIBUTE13,
	    X_ATTRIBUTE14 => p_operations.ATTRIBUTE14,
	    X_ATTRIBUTE15 => p_operations.ATTRIBUTE15,
	    X_ATTRIBUTE16 => p_operations.ATTRIBUTE16,
	    X_ATTRIBUTE17 => p_operations.ATTRIBUTE17,
	    X_ATTRIBUTE18 => p_operations.ATTRIBUTE18,
	    X_ATTRIBUTE19 => p_operations.ATTRIBUTE19,
	    X_ATTRIBUTE20 => p_operations.ATTRIBUTE20,
	    X_ATTRIBUTE21 => p_operations.ATTRIBUTE21,
	    X_OPERATION_STATUS => 100,
	    X_OWNER_ORGANIZATION_ID => p_operations.OWNER_ORGANIZATION_ID,
	    X_OPRN_DESC => p_operations.OPRN_DESC,
	    X_CREATION_DATE => sysdate,
    	    X_CREATED_BY => gmd_api_grp.user_id,
    	    X_LAST_UPDATE_DATE => sysdate,
    	    X_LAST_UPDATED_BY => gmd_api_grp.user_id,
    	    X_LAST_UPDATE_LOGIN => gmd_api_grp.login_id);

     IF (l_debug = 'Y') THEN
       gmd_debug.put_line('END of Insert_operation private');
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
  , p_commit		IN 	BOOLEAN
  , p_oprn_id		IN	gmd_operations.oprn_id%TYPE
  , p_update_table		IN	gmd_operations_pub.update_tbl_type
  , x_message_count 		OUT NOCOPY  	NUMBER
  , x_message_list 		OUT NOCOPY  	VARCHAR2
  , x_return_status		OUT NOCOPY  	VARCHAR2)   IS

    CURSOR get_oprn_detail (v_oprn_id  NUMBER) IS
      SELECT *
      FROM gmd_operations
      WHERE oprn_Id = p_oprn_id
      AND delete_mark = 0;

    v_update_rec  		gmd_operations%ROWTYPE;
    l_errmsg     		VARCHAR2(240);

    setup_failure  		EXCEPTION;
    inv_operation		EXCEPTION;

    l_rt_start_date  Date;
    l_rt_end_date    Date;

   CURSOR get_rt_start_end_dates(v_oprn_id NUMBER) IS
     SELECT min(effective_start_date) effective_start_date,
            max(NVL(effective_end_date, trunc(SYSDATE + 999999) )) effective_end_date
     FROM   fm_rout_dtl d, gmd_routings_b r
     WHERE  d.oprn_id = v_oprn_id
     AND    r.routing_id = d.routing_id
     AND    r.delete_mark = 0;

  BEGIN
    IF (l_debug = 'Y') THEN
      gmd_debug.put_line(' In update_operation private');
    END IF;

    /* Initially let us assign the return status to success */
    x_return_status := FND_API.g_ret_sts_success;

    /* Set row who columns */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    OPEN get_oprn_detail(p_oprn_id);
    FETCH get_oprn_detail INTO v_update_rec;
    IF get_oprn_detail%NOTFOUND THEN
      gmd_api_grp.log_message ('FM_INVOPRN');
      RAISE inv_operation;
    END IF;
    CLOSE get_oprn_detail;

    FOR i IN 1 .. p_update_table.count LOOP
      IF UPPER(p_update_table(i).p_col_to_update) = 'PROCESS_QTY_UOM' THEN
        v_update_rec.PROCESS_QTY_UOM := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'MINIMUM_TRANSFER_QTY' THEN
        v_update_rec.minimum_transfer_qty := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OPRN_CLASS' THEN
        v_update_rec.oprn_class := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OPRN_DESC' THEN
        v_update_rec.oprn_desc := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) like '%START_DATE%' THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('The eff_start_date for operation prior to update = '||
                    p_update_table(i).p_value);
        END IF;
        v_update_rec.effective_start_date
             := FND_DATE.canonical_to_date(p_update_table(i).p_value);
      ELSIF UPPER(p_update_table(i).p_col_to_update) like '%END_DATE%' THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('The eff_end_date for operation prior to update = '||
                    p_update_table(i).p_value) ;
        END IF;
        v_update_rec.effective_end_date
             := FND_DATE.canonical_to_date(p_update_table(i).p_value);
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'OWNER_ORGANIZATION_ID' THEN
        v_update_rec.owner_organization_id := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK' THEN
        v_update_rec.delete_mark := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1' THEN
        v_update_rec.attribute1 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2' THEN
         	     v_update_rec.attribute2 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3' THEN
      	     v_update_rec.attribute3 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4' THEN
       	     v_update_rec.attribute4 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5' THEN
       	     v_update_rec.attribute5 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6' THEN
       	     v_update_rec.attribute6 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7' THEN
       	     v_update_rec.attribute7 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8' THEN
       	     v_update_rec.attribute8 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9' THEN
       	     v_update_rec.attribute9 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10' THEN
       	     v_update_rec.attribute10 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11' THEN
       	     v_update_rec.attribute11 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12' THEN
       	     v_update_rec.attribute12 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13' THEN
       	     v_update_rec.attribute13 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14' THEN
       	     v_update_rec.attribute14 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15' THEN
       	     v_update_rec.attribute15 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16' THEN
       	     v_update_rec.attribute16 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17' THEN
       	     v_update_rec.attribute17 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18' THEN
       	     v_update_rec.attribute18 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19' THEN
       	     v_update_rec.attribute19 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20' THEN
       	     v_update_rec.attribute20 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21' THEN
       	     v_update_rec.attribute21 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22' THEN
       	     v_update_rec.attribute22 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23' THEN
       	     v_update_rec.attribute23 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24' THEN
       	     v_update_rec.attribute24 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25' THEN
       	     v_update_rec.attribute25 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26' THEN
       	     v_update_rec.attribute26 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27' THEN
       	     v_update_rec.attribute27 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28' THEN
       	     v_update_rec.attribute28 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29' THEN
       	     v_update_rec.attribute29 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30' THEN
       	     v_update_rec.attribute30 := p_update_table(i).p_value;
      ELSIF UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY' THEN
       	     v_update_rec.attribute_category := p_update_table(i).p_value;
      END IF;

      -- Compare Oprn start dtae with Routing Start Dtae
      If (l_debug = 'Y') THEN
        gmd_debug.put_line('The oprn id = '||v_update_rec.oprn_id);
      END IF;

      IF UPPER(p_update_table(i).p_col_to_update) like '%START_DATE%' THEN
        OPEN get_rt_start_end_dates(v_update_rec.oprn_id);
        FETCH get_rt_start_end_dates INTO l_rt_start_date, l_rt_end_date;

        IF (l_rt_end_date = trunc(SYSDATE + 999999) ) THEN
          l_rt_end_date := Null;
        END IF;

        IF l_rt_start_date IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('In OPeration Pvt - Comparing OPrn start date '||
                             ' with routing start date '||
                             'Operation start and Rout Start date = '||
                             v_update_rec.effective_start_date||' - '||l_rt_start_date);

          END IF;

          IF (l_rt_start_date < v_update_rec.effective_start_date) THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_FROM_DATE');
            FND_MESSAGE.set_token('OPRN_NO',v_update_rec.oprn_no);
            FND_MESSAGE.set_token('VERSION_NO',v_update_rec.oprn_vers);
            FND_MESSAGE.set_token('OPRN_DATE',p_update_table(i).p_value);
            FND_MSG_PUB.ADD;
            RAISE inv_operation;
          END IF;
        END IF;
        CLOSE  get_rt_start_end_dates;
      END IF; -- comparing start dates

      -- Compare Oprn end dtae with Routing end Dtae
      IF UPPER(p_update_table(i).p_col_to_update) like '%END_DATE%' THEN
        OPEN get_rt_start_end_dates(v_update_rec.oprn_id);
        FETCH get_rt_start_end_dates INTO l_rt_start_date, l_rt_end_date;

        IF (l_rt_end_date = trunc(SYSDATE + 999999) ) THEN
          l_rt_end_date := Null;
        END IF;

        IF l_rt_start_date IS NOT NULL THEN
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line('In OPeration Pvt - Comparing Oprn end date '||
                             ' with routing end date '||
                             'Oprn end date and Rout end date =  '||
                             v_update_rec.effective_end_date||' - '||l_rt_end_date);

          END IF;

          IF ((l_rt_end_date IS NULL) AND
              (v_update_rec.effective_end_date IS NOT NULL)) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_OPER_EFF_END_DATE');
              FND_MSG_PUB.ADD;
              RAISE inv_operation;
          END IF;

          IF (l_rt_end_date > v_update_rec.effective_end_date) THEN
              FND_MESSAGE.SET_NAME('GMD', 'GMD_OPER_EFF_END_DATE');
              FND_MSG_PUB.ADD;
              RAISE inv_operation;
          END IF;
        END IF;

        CLOSE get_rt_start_end_dates;
      END IF; -- comparing end dates
    END LOOP;

    -- Comparind Start and End dates of an operation.
    IF v_update_rec.effective_end_date IS NOT NULL THEN
      /* Effective end date must be greater than start date, otherwise give error */
      IF v_update_rec.effective_start_date > v_update_rec.effective_end_date THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line('effective start date must be less then end date');
        END IF;
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        RAISE inv_operation;
      END IF;
    END IF;


    IF x_return_status = 'S' THEN
      GMD_OPERATIONS_PKG.UPDATE_ROW(
	    X_OPRN_ID =>  v_update_rec.oprn_id,
	    X_ATTRIBUTE30 => v_update_rec.ATTRIBUTE30,
	    X_ATTRIBUTE_CATEGORY =>  v_update_rec.ATTRIBUTE_CATEGORY,
	    X_ATTRIBUTE25 =>  v_update_rec.ATTRIBUTE25,
	    X_ATTRIBUTE26 =>  v_update_rec.ATTRIBUTE26,
	    X_ATTRIBUTE27 => v_update_rec.ATTRIBUTE27,
	    X_ATTRIBUTE28 => v_update_rec.ATTRIBUTE28,
	    X_ATTRIBUTE29 => v_update_rec.ATTRIBUTE29,
	    X_ATTRIBUTE22 => v_update_rec.ATTRIBUTE22,
	    X_ATTRIBUTE23 => v_update_rec.ATTRIBUTE23,
	    X_ATTRIBUTE24 => v_update_rec.ATTRIBUTE24,
	    X_OPRN_NO => v_update_rec.OPRN_NO,
	    X_OPRN_VERS =>  v_update_rec.OPRN_VERS,
	    X_PROCESS_QTY_UOM => v_update_rec.PROCESS_QTY_UOM,
	    X_MINIMUM_TRANSFER_QTY => v_update_rec.MINIMUM_TRANSFER_QTY,
	    X_OPRN_CLASS => v_update_rec.OPRN_CLASS,
	    X_INACTIVE_IND => v_update_rec.inactive_ind,
	    X_EFFECTIVE_START_DATE => v_update_rec.EFFECTIVE_START_DATE,
	    X_EFFECTIVE_END_DATE => v_update_rec.EFFECTIVE_END_DATE,
	    X_DELETE_MARK => v_update_rec.delete_mark,
	    X_TEXT_CODE => v_update_rec.TEXT_CODE,
	    X_ATTRIBUTE1 => v_update_rec.ATTRIBUTE1,
	    X_ATTRIBUTE2 => v_update_rec.ATTRIBUTE2,
	    X_ATTRIBUTE3 => v_update_rec.ATTRIBUTE3,
	    X_ATTRIBUTE4 => v_update_rec.ATTRIBUTE4,
	    X_ATTRIBUTE5 => v_update_rec.ATTRIBUTE5,
	    X_ATTRIBUTE6 => v_update_rec.ATTRIBUTE6,
	    X_ATTRIBUTE7 => v_update_rec.ATTRIBUTE7,
	    X_ATTRIBUTE8 => v_update_rec.ATTRIBUTE8,
	    X_ATTRIBUTE9 => v_update_rec.ATTRIBUTE9,
	    X_ATTRIBUTE10 => v_update_rec.ATTRIBUTE10,
	    X_ATTRIBUTE11 => v_update_rec.ATTRIBUTE11,
	    X_ATTRIBUTE12 => v_update_rec.ATTRIBUTE12,
	    X_ATTRIBUTE13 => v_update_rec.ATTRIBUTE13,
	    X_ATTRIBUTE14 => v_update_rec.ATTRIBUTE14,
	    X_ATTRIBUTE15 => v_update_rec.ATTRIBUTE15,
	    X_ATTRIBUTE16 => v_update_rec.ATTRIBUTE16,
	    X_ATTRIBUTE17 => v_update_rec.ATTRIBUTE17,
	    X_ATTRIBUTE18 => v_update_rec.ATTRIBUTE18,
	    X_ATTRIBUTE19 => v_update_rec.ATTRIBUTE19,
	    X_ATTRIBUTE20 => v_update_rec.ATTRIBUTE20,
	    X_ATTRIBUTE21 => v_update_rec.ATTRIBUTE21,
	    X_OPERATION_STATUS => v_update_rec.operation_status,
	    X_OWNER_ORGANIZATION_ID => v_update_rec.OWNER_ORGANIZATION_ID,
	    X_OPRN_DESC => v_update_rec.OPRN_DESC,
    	    X_LAST_UPDATE_DATE => sysdate,
    	    X_LAST_UPDATED_BY => gmd_api_grp.user_id,
    	    X_LAST_UPDATE_LOGIN => gmd_api_grp.login_id);

    END IF;
  EXCEPTION
    WHEN setup_failure OR inv_operation THEN
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

  END update_operation;

END GMD_OPERATIONS_PVT;

/
