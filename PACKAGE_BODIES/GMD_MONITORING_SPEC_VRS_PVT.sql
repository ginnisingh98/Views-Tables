--------------------------------------------------------
--  DDL for Package Body GMD_MONITORING_SPEC_VRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_MONITORING_SPEC_VRS_PVT" AS
/* $Header: GMDVMVRB.pls 120.2 2005/10/04 07:00:34 svankada noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVMVRB.pls                                        |
--| Package Name       : GMD_MONITORING_SPEC_VRS_PVT                         |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for MONITORING VR.           |
--|                                                                          |
--| HISTORY                                                                  |
--|    Manish Gupta     26-Jan-2004     Created.                             |
--|                                                                          |
--|SaiKiran Vankadari   13-Apr-2005   Convergence Changes.                    |
--|               Added locator_organization_id, subinventory, locator_id and|
--|              resource_organization_id to insert_row() procedure          |
--|SaiKiran Vankadari   04-Oct-2005  Added migrated_ind to the insert statement|
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_monitoring_spec_vrs IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_monitoring_spec_vrs OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN IS
BEGIN

    x_monitoring_spec_vrs := p_monitoring_spec_vrs;

    INSERT INTO GMD_MONITORING_SPEC_VRS
  (SPEC_VR_ID
  ,SPEC_ID
  ,RULE_TYPE
  ,LOCATOR_ORGANIZATION_ID
  ,SUBINVENTORY
  ,LOCATOR_ID
  ,RESOURCES
  ,RESOURCE_ORGANIZATION_ID
  ,RESOURCE_INSTANCE_ID
  ,SPEC_VR_STATUS
  ,START_DATE
  ,END_DATE
  ,SAMPLING_PLAN_ID
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
  ,MIGRATED_IND  --To differentiate R12 data from previous data during migration
  )
 VALUES
  (gmd_qc_spec_vr_id_s.NEXTVAL
  ,x_monitoring_spec_vrs.SPEC_ID
  ,x_monitoring_spec_vrs.RULE_TYPE
  ,x_monitoring_spec_vrs.LOCATOR_ORGANIZATION_ID
  ,x_monitoring_spec_vrs.SUBINVENTORY
  ,x_monitoring_spec_vrs.LOCATOR_ID
  ,x_monitoring_spec_vrs.RESOURCES
  ,x_monitoring_spec_vrs.RESOURCE_ORGANIZATION_ID
  ,x_monitoring_spec_vrs.RESOURCE_INSTANCE_ID
  ,x_monitoring_spec_vrs.SPEC_VR_STATUS
  ,x_monitoring_spec_vrs.START_DATE
  ,x_monitoring_spec_vrs.END_DATE
  ,x_monitoring_spec_vrs.SAMPLING_PLAN_ID
  ,x_monitoring_spec_vrs.DELETE_MARK
  ,x_monitoring_spec_vrs.TEXT_CODE
  ,x_monitoring_spec_vrs.ATTRIBUTE_CATEGORY
  ,x_monitoring_spec_vrs.ATTRIBUTE1
  ,x_monitoring_spec_vrs.ATTRIBUTE2
  ,x_monitoring_spec_vrs.ATTRIBUTE3
  ,x_monitoring_spec_vrs.ATTRIBUTE4
  ,x_monitoring_spec_vrs.ATTRIBUTE5
  ,x_monitoring_spec_vrs.ATTRIBUTE6
  ,x_monitoring_spec_vrs.ATTRIBUTE7
  ,x_monitoring_spec_vrs.ATTRIBUTE8
  ,x_monitoring_spec_vrs.ATTRIBUTE9
  ,x_monitoring_spec_vrs.ATTRIBUTE10
  ,x_monitoring_spec_vrs.ATTRIBUTE11
  ,x_monitoring_spec_vrs.ATTRIBUTE12
  ,x_monitoring_spec_vrs.ATTRIBUTE13
  ,x_monitoring_spec_vrs.ATTRIBUTE14
  ,x_monitoring_spec_vrs.ATTRIBUTE15
  ,x_monitoring_spec_vrs.ATTRIBUTE16
  ,x_monitoring_spec_vrs.ATTRIBUTE17
  ,x_monitoring_spec_vrs.ATTRIBUTE18
  ,x_monitoring_spec_vrs.ATTRIBUTE19
  ,x_monitoring_spec_vrs.ATTRIBUTE20
  ,x_monitoring_spec_vrs.ATTRIBUTE21
  ,x_monitoring_spec_vrs.ATTRIBUTE22
  ,x_monitoring_spec_vrs.ATTRIBUTE23
  ,x_monitoring_spec_vrs.ATTRIBUTE24
  ,x_monitoring_spec_vrs.ATTRIBUTE25
  ,x_monitoring_spec_vrs.ATTRIBUTE26
  ,x_monitoring_spec_vrs.ATTRIBUTE27
  ,x_monitoring_spec_vrs.ATTRIBUTE28
  ,x_monitoring_spec_vrs.ATTRIBUTE29
  ,x_monitoring_spec_vrs.ATTRIBUTE30
  ,x_monitoring_spec_vrs.CREATION_DATE
  ,x_monitoring_spec_vrs.CREATED_BY
  ,x_monitoring_spec_vrs.LAST_UPDATED_BY
  ,x_monitoring_spec_vrs.LAST_UPDATE_DATE
  ,x_monitoring_spec_vrs.LAST_UPDATE_LOGIN
  ,0)
        RETURNING spec_vr_id INTO x_monitoring_spec_vrs.spec_vr_id
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_MONITORING_SPEC_VRS_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;





FUNCTION delete_row (p_spec_vr_id        IN  NUMBER,
                     p_last_update_date  IN  DATE  ,
                     p_last_updated_by   IN  NUMBER,
                     p_last_update_login IN  NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_spec_vr_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_monitoring_spec_vrs
    WHERE  spec_vr_id = p_spec_vr_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_monitoring_spec_vrs
    SET  delete_mark = 1,
         last_update_date  = NVL(p_last_update_date,SYSDATE),
         last_updated_by   = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
         last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID)
    WHERE  spec_vr_id = p_spec_vr_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_MONITORING_SPEC_VRS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_MONITORING_SPEC_VRS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_MONITORING_SPEC_VRS',
                            'RECORD','monitoring Spec Validity Rule',
                            'KEY', p_spec_vr_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_MONITORING_SPEC_VRS_PVT', 'DELETE_ROW');
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
    FROM   gmd_monitoring_spec_vrs
    WHERE  spec_vr_id = p_spec_vr_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_MONITORING_SPEC_VRS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_MONITORING_SPEC_VRS',
                            'RECORD','monitoring Spec Validity Rule',
                            'KEY', p_spec_vr_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_MONITORING_SPEC_VRS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_monitoring_spec_vrs IN  GMD_monitoring_SPEC_VRS%ROWTYPE
, x_monitoring_spec_vrs OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_monitoring_spec_vrs.spec_vr_id IS NOT NULL) THEN
    SELECT *
    INTO   x_monitoring_spec_vrs
    FROM   gmd_monitoring_spec_vrs
    WHERE  spec_vr_id = p_monitoring_spec_vrs.spec_vr_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_MONITORING_SPEC_VRS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_MONITORING_SPEC_VRS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_MONITORING_SPEC_VRS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_MONITORING_SPEC_VRS_PVT;

/
