--------------------------------------------------------
--  DDL for Package Body GMD_WIP_SPEC_VRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_WIP_SPEC_VRS_PVT" AS
/* $Header: GMDVWVRB.pls 120.3.12010000.2 2009/03/18 16:14:26 rnalla ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVWVRB.pls                                        |
--| Package Name       : GMD_WIP_SPEC_VRS_PVT                                |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for WIP VR.                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     07-Aug-2002     Created.                             |
--|                                                                          |
--|SaiKiran Vankadari   13-Apr-2004     BUG# 3464772                         |
--|                     Added column AUTO_SAMPLE_IND in the INSERT statement |
--|                                                                          |
--|SaiKiran Vankadari   04-May-2004     ENHANCEMENT#3476560                  |
--|                     Added column DELAYED_LOT_ENTRY  in the INSERT        |
--|                     statement.                                           |
--|SaiKiran Vankadari   13-Apr-2005   Convergence Changes                    |
--|SaiKiran Vankadari   04-Oct-2005  Added migrated_ind to the insert statement|
--|S. Feinstein         18-Oct-2005  Added material_detail_id to samples and vr
--|RLNAGARA LPN ME 7027149 08-May-2008  Added Delayed_LPN_Entry in the INSERT   |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_wip_spec_vrs IN  GMD_WIP_SPEC_VRS%ROWTYPE
, x_wip_spec_vrs OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE) RETURN BOOLEAN IS
BEGIN

    x_wip_spec_vrs := p_wip_spec_vrs;

    INSERT INTO GMD_WIP_SPEC_VRS
     (
      SPEC_VR_ID
     ,SPEC_ID
     ,ORGANIZATION_ID
     ,BATCH_ID
     ,RECIPE_ID
     ,RECIPE_NO
     ,RECIPE_VERSION
     ,FORMULA_ID
     ,FORMULALINE_ID
     ,MATERIAL_DETAIL_ID
     ,FORMULA_NO
     ,FORMULA_VERS
     ,ROUTING_ID
     ,ROUTING_NO
     ,ROUTING_VERS
     ,STEP_ID
     ,STEP_NO
     ,OPRN_ID
     ,OPRN_NO
     ,OPRN_VERS
     ,CHARGE
     ,SPEC_VR_STATUS
     ,START_DATE
     ,END_DATE
     ,SAMPLING_PLAN_ID
     ,SAMPLE_INV_TRANS_IND
     ,LOT_OPTIONAL_ON_SAMPLE
     ,CONTROL_LOT_ATTRIB_IND
     ,OUT_OF_SPEC_LOT_STATUS_ID
     ,IN_SPEC_LOT_STATUS_ID
     ,COA_TYPE
     ,CONTROL_BATCH_STEP_IND
     ,COA_AT_SHIP_IND
     ,COA_AT_INVOICE_IND
     ,COA_REQ_FROM_SUPL_IND
     ,DELETE_MARK
     ,TEXT_CODE
     ,ATTRIBUTE_CATEGORY
     ,ATTRIBUTE1
     ,ATTRIBUTE2
     ,ATTRIBUTE3
     ,ATTRIBUTE4
     ,ATTRIBUTE5
     ,ATTRIBUTE6
     ,ATTRIBUTE7
     ,ATTRIBUTE8
     ,ATTRIBUTE9
     ,ATTRIBUTE10
     ,ATTRIBUTE11
     ,ATTRIBUTE12
     ,ATTRIBUTE13
     ,ATTRIBUTE14
     ,ATTRIBUTE15
     ,ATTRIBUTE16
     ,ATTRIBUTE17
     ,ATTRIBUTE18
     ,ATTRIBUTE19
     ,ATTRIBUTE20
     ,ATTRIBUTE21
     ,ATTRIBUTE22
     ,ATTRIBUTE23
     ,ATTRIBUTE24
     ,ATTRIBUTE25
     ,ATTRIBUTE26
     ,ATTRIBUTE27
     ,ATTRIBUTE28
     ,ATTRIBUTE29
     ,ATTRIBUTE30
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
     ,AUTO_SAMPLE_IND
     ,DELAYED_LOT_ENTRY
     ,AUTO_COMPLETE_BATCH_STEP -- Bug# 5440347
     ,MIGRATED_IND     --To differentiate R12 data from previous data during migration
     ,DELAYED_LPN_ENTRY  --RLNAGARA LPN ME 7027149
     )
     VALUES
     (
      gmd_qc_spec_vr_id_s.NEXTVAL
     ,x_wip_spec_vrs.SPEC_ID
     ,x_wip_spec_vrs.ORGANIZATION_ID
     ,x_wip_spec_vrs.BATCH_ID
     ,x_wip_spec_vrs.RECIPE_ID
     ,x_wip_spec_vrs.RECIPE_NO
     ,x_wip_spec_vrs.RECIPE_VERSION
     ,x_wip_spec_vrs.FORMULA_ID
     ,x_wip_spec_vrs.FORMULALINE_ID
     ,x_wip_spec_vrs.MATERIAL_DETAIL_ID
     ,x_wip_spec_vrs.FORMULA_NO
     ,x_wip_spec_vrs.FORMULA_VERS
     ,x_wip_spec_vrs.ROUTING_ID
     ,x_wip_spec_vrs.ROUTING_NO
     ,x_wip_spec_vrs.ROUTING_VERS
     ,x_wip_spec_vrs.STEP_ID
     ,x_wip_spec_vrs.STEP_NO
     ,x_wip_spec_vrs.OPRN_ID
     ,x_wip_spec_vrs.OPRN_NO
     ,x_wip_spec_vrs.OPRN_VERS
     ,x_wip_spec_vrs.CHARGE
     ,x_wip_spec_vrs.SPEC_VR_STATUS
     ,x_wip_spec_vrs.START_DATE
     ,x_wip_spec_vrs.END_DATE
     ,x_wip_spec_vrs.SAMPLING_PLAN_ID
     ,x_wip_spec_vrs.SAMPLE_INV_TRANS_IND
     ,x_wip_spec_vrs.LOT_OPTIONAL_ON_SAMPLE
     ,x_wip_spec_vrs.CONTROL_LOT_ATTRIB_IND
     ,x_wip_spec_vrs.OUT_OF_SPEC_LOT_STATUS_ID
     ,x_wip_spec_vrs.IN_SPEC_LOT_STATUS_ID
     ,x_wip_spec_vrs.COA_TYPE
     ,x_wip_spec_vrs.CONTROL_BATCH_STEP_IND
     ,x_wip_spec_vrs.COA_AT_SHIP_IND
     ,x_wip_spec_vrs.COA_AT_INVOICE_IND
     ,x_wip_spec_vrs.COA_REQ_FROM_SUPL_IND
     ,x_wip_spec_vrs.DELETE_MARK
     ,x_wip_spec_vrs.TEXT_CODE
     ,x_wip_spec_vrs.ATTRIBUTE_CATEGORY
     ,x_wip_spec_vrs.ATTRIBUTE1
     ,x_wip_spec_vrs.ATTRIBUTE2
     ,x_wip_spec_vrs.ATTRIBUTE3
     ,x_wip_spec_vrs.ATTRIBUTE4
     ,x_wip_spec_vrs.ATTRIBUTE5
     ,x_wip_spec_vrs.ATTRIBUTE6
     ,x_wip_spec_vrs.ATTRIBUTE7
     ,x_wip_spec_vrs.ATTRIBUTE8
     ,x_wip_spec_vrs.ATTRIBUTE9
     ,x_wip_spec_vrs.ATTRIBUTE10
     ,x_wip_spec_vrs.ATTRIBUTE11
     ,x_wip_spec_vrs.ATTRIBUTE12
     ,x_wip_spec_vrs.ATTRIBUTE13
     ,x_wip_spec_vrs.ATTRIBUTE14
     ,x_wip_spec_vrs.ATTRIBUTE15
     ,x_wip_spec_vrs.ATTRIBUTE16
     ,x_wip_spec_vrs.ATTRIBUTE17
     ,x_wip_spec_vrs.ATTRIBUTE18
     ,x_wip_spec_vrs.ATTRIBUTE19
     ,x_wip_spec_vrs.ATTRIBUTE20
     ,x_wip_spec_vrs.ATTRIBUTE21
     ,x_wip_spec_vrs.ATTRIBUTE22
     ,x_wip_spec_vrs.ATTRIBUTE23
     ,x_wip_spec_vrs.ATTRIBUTE24
     ,x_wip_spec_vrs.ATTRIBUTE25
     ,x_wip_spec_vrs.ATTRIBUTE26
     ,x_wip_spec_vrs.ATTRIBUTE27
     ,x_wip_spec_vrs.ATTRIBUTE28
     ,x_wip_spec_vrs.ATTRIBUTE29
     ,x_wip_spec_vrs.ATTRIBUTE30
     ,x_wip_spec_vrs.CREATION_DATE
     ,x_wip_spec_vrs.CREATED_BY
     ,x_wip_spec_vrs.LAST_UPDATED_BY
     ,x_wip_spec_vrs.LAST_UPDATE_DATE
     ,x_wip_spec_vrs.LAST_UPDATE_LOGIN
     ,x_wip_spec_vrs.AUTO_SAMPLE_IND
     ,x_wip_spec_vrs.DELAYED_LOT_ENTRY
     ,x_wip_spec_vrs.AUTO_COMPLETE_BATCH_STEP -- Bug# 5440347
     ,0
     ,x_wip_spec_vrs.DELAYED_LPN_ENTRY      --RLNAGARA LPN ME 7027149
     )
        RETURNING spec_vr_id INTO x_wip_spec_vrs.spec_vr_id
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_WIP_SPEC_VRS_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;





FUNCTION delete_row (p_spec_vr_id        IN NUMBER,
                     p_last_update_date  IN  DATE     ,
                     p_last_updated_by 	 IN  NUMBER   ,
                     p_last_update_login IN  NUMBER   )
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_spec_vr_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_wip_spec_vrs
    WHERE  spec_vr_id = p_spec_vr_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_wip_spec_vrs
    SET    delete_mark = 1,
           last_update_date  = NVL(p_last_update_date,SYSDATE),
           last_updated_by   = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
           last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID)
    WHERE  spec_vr_id = p_spec_vr_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_WIP_SPEC_VRS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_WIP_SPEC_VRS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_WIP_SPEC_VRS',
                            'RECORD','WIP Spec Validity Rule',
                            'KEY', p_spec_vr_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_WIP_SPEC_VRS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row (p_spec_vr_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_spec_vr_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_wip_spec_vrs
    WHERE  spec_vr_id = p_spec_vr_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_WIP_SPEC_VRS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_WIP_SPEC_VRS',
                            'RECORD','WIP Spec Validity Rule',
                            'KEY', p_spec_vr_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_WIP_SPEC_VRS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_wip_spec_vrs IN  gmd_wip_spec_vrs%ROWTYPE
, x_wip_spec_vrs OUT NOCOPY gmd_wip_spec_vrs%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_wip_spec_vrs.spec_vr_id IS NOT NULL) THEN
    SELECT *
    INTO   x_wip_spec_vrs
    FROM   gmd_wip_spec_vrs
    WHERE  spec_vr_id = p_wip_spec_vrs.spec_vr_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_WIP_SPEC_VRS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_WIP_SPEC_VRS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_WIP_SPEC_VRS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_WIP_SPEC_VRS_PVT;

/
