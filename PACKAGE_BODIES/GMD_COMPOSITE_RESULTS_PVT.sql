--------------------------------------------------------
--  DDL for Package Body GMD_COMPOSITE_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMPOSITE_RESULTS_PVT" AS
/* $Header: GMDVCRSB.pls 115.3 2002/11/04 10:21:34 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCRSB.pls                                        |
--| Package Name       : GMD_COMPOSITE_RESULTS_PVT                           |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Composite Results.       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     12-Sep-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_composite_results IN  GMD_COMPOSITE_RESULTS%ROWTYPE
, x_composite_results OUT NOCOPY GMD_COMPOSITE_RESULTS%ROWTYPE
)
  RETURN BOOLEAN IS
BEGIN

    x_composite_results := p_composite_results;

    INSERT INTO GMD_COMPOSITE_RESULTS
     (
      COMPOSITE_RESULT_ID
     ,TEST_ID
     ,MEAN
     ,MODE_NUM
     ,MODE_CHAR
     ,LOW_NUM
     ,HIGH_NUM
     ,RANGE
     ,STANDARD_DEVIATION
     ,SAMPLE_TOTAL
     ,SAMPLE_CNT_USED
     ,NON_VALIDATED_RESULT
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
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     ,MEDIAN_NUM
     ,MEDIAN_CHAR
     ,LOW_CHAR
     ,HIGH_CHAR
     ,COMPOSITE_SPEC_DISP_ID
     ,IN_SPEC_IND
     ,VALUE_IN_REPORT_PRECISION
     ,WF_RESPONSE
     )
     VALUES
     (
      gmd_qc_comp_result_id_s.NEXTVAL
     ,x_composite_results.TEST_ID
     ,x_composite_results.MEAN
     ,x_composite_results.MODE_NUM
     ,x_composite_results.MODE_CHAR
     ,x_composite_results.LOW_NUM
     ,x_composite_results.HIGH_NUM
     ,x_composite_results.RANGE
     ,x_composite_results.STANDARD_DEVIATION
     ,x_composite_results.SAMPLE_TOTAL
     ,x_composite_results.SAMPLE_CNT_USED
     ,x_composite_results.NON_VALIDATED_RESULT
     ,x_composite_results.DELETE_MARK
     ,x_composite_results.TEXT_CODE
     ,x_composite_results.ATTRIBUTE_CATEGORY
     ,x_composite_results.ATTRIBUTE1
     ,x_composite_results.ATTRIBUTE2
     ,x_composite_results.ATTRIBUTE3
     ,x_composite_results.ATTRIBUTE4
     ,x_composite_results.ATTRIBUTE5
     ,x_composite_results.ATTRIBUTE6
     ,x_composite_results.ATTRIBUTE7
     ,x_composite_results.ATTRIBUTE8
     ,x_composite_results.ATTRIBUTE9
     ,x_composite_results.ATTRIBUTE10
     ,x_composite_results.ATTRIBUTE11
     ,x_composite_results.ATTRIBUTE12
     ,x_composite_results.ATTRIBUTE13
     ,x_composite_results.ATTRIBUTE14
     ,x_composite_results.ATTRIBUTE15
     ,x_composite_results.ATTRIBUTE16
     ,x_composite_results.ATTRIBUTE17
     ,x_composite_results.ATTRIBUTE18
     ,x_composite_results.ATTRIBUTE19
     ,x_composite_results.ATTRIBUTE20
     ,x_composite_results.ATTRIBUTE21
     ,x_composite_results.ATTRIBUTE22
     ,x_composite_results.ATTRIBUTE23
     ,x_composite_results.ATTRIBUTE24
     ,x_composite_results.ATTRIBUTE25
     ,x_composite_results.ATTRIBUTE26
     ,x_composite_results.ATTRIBUTE27
     ,x_composite_results.ATTRIBUTE28
     ,x_composite_results.ATTRIBUTE29
     ,x_composite_results.ATTRIBUTE30
     ,x_composite_results.CREATION_DATE
     ,x_composite_results.CREATED_BY
     ,x_composite_results.LAST_UPDATE_DATE
     ,x_composite_results.LAST_UPDATED_BY
     ,x_composite_results.LAST_UPDATE_LOGIN
     ,x_composite_results.MEDIAN_NUM
     ,x_composite_results.MEDIAN_CHAR
     ,x_composite_results.LOW_CHAR
     ,x_composite_results.HIGH_CHAR
     ,x_composite_results.COMPOSITE_SPEC_DISP_ID
     ,x_composite_results.IN_SPEC_IND
     ,x_composite_results.VALUE_IN_REPORT_PRECISION
     ,x_composite_results.WF_RESPONSE
     )
      RETURNING composite_result_id INTO x_composite_results.composite_result_id
   ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULTS_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;



FUNCTION delete_row (p_composite_result_id   IN  NUMBER,
                     p_last_update_date 	IN  DATE,
                     p_last_updated_by 	        IN  NUMBER,
                     p_last_update_login 	IN  NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN

  IF p_composite_result_id IS NOT NULL THEN

    SELECT 1
    INTO   dummy
    FROM   gmd_composite_results
    WHERE  composite_result_id = p_composite_result_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_composite_results
    SET    delete_mark = 1,
           last_update_date  = NVL(p_last_update_date,SYSDATE),
           last_updated_by   = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
           last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID)
    WHERE  composite_result_id = p_composite_result_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULTS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_RESULTS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_RESULTS',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;



FUNCTION lock_row (p_composite_result_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_composite_result_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_composite_results
    WHERE  composite_result_id = p_composite_result_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_RESULTS',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_composite_results IN  gmd_composite_results%ROWTYPE
, x_composite_results OUT NOCOPY gmd_composite_results%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_composite_results.composite_result_id IS NOT NULL) THEN
    SELECT *
    INTO   x_composite_results
    FROM   gmd_composite_results
    WHERE  composite_result_id = p_composite_results.composite_result_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_RESULTS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULTS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_COMPOSITE_RESULTS_PVT;

/
