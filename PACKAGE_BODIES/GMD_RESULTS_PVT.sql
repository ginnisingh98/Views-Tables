--------------------------------------------------------
--  DDL for Package Body GMD_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_RESULTS_PVT" AS
/* $Header: GMDVRESB.pls 120.1 2006/06/26 12:57:12 ragsriva noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVRESB.pls                                        |
--| Package Name       : GMD_RESULTS_PVT                                     |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Results                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     09-Aug-2002     Created.                             |
--|    Ravi Boddu       17-Mar-2005     Results Convergence Changes done     |
--|    RAGSRIVA         23-Jun-2006     set migrated_ind to 0 in insert_row  |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_results IN  GMD_RESULTS%ROWTYPE
, x_results OUT NOCOPY GMD_RESULTS%ROWTYPE) RETURN BOOLEAN IS
BEGIN

    x_results := p_results;

    INSERT INTO GMD_RESULTS
     (
      RESULT_ID
     ,SAMPLE_ID
     ,TEST_ID
     ,TEST_QTY
     ,TEST_QTY_UOM
     ,TEST_METHOD_ID
     ,CONSUMED_QTY
     ,RESERVE_SAMPLE_ID
     ,TEST_REPLICATE_CNT
     ,LAB_ORGANIZATION_ID
     ,RESULT_VALUE_NUM
     ,RESULT_VALUE_CHAR
     ,RESULT_DATE
     ,TEST_KIT_INV_ITEM_ID
     ,TEST_KIT_LOT_NUMBER
     ,TESTER_ID
     ,TEST_PROVIDER_ID
     ,ASSAY_RETEST
     ,AD_HOC_PRINT_ON_COA_IND
     ,SEQ
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
     ,UPDATE_INSTANCE_ID
     ,PLANNED_RESOURCE
     ,PLANNED_RESOURCE_INSTANCE
     ,ACTUAL_RESOURCE
     ,ACTUAL_RESOURCE_INSTANCE
     ,PLANNED_RESULT_DATE
     ,TEST_BY_DATE
     ,MIGRATED_IND
     )
     VALUES
     (
      gmd_qc_result_id_s.NEXTVAL
     ,x_results.SAMPLE_ID
     ,x_results.TEST_ID
     ,x_results.TEST_QTY
     ,x_results.TEST_QTY_UOM
     ,x_results.TEST_METHOD_ID
     ,x_results.CONSUMED_QTY
     ,x_results.RESERVE_SAMPLE_ID
     ,x_results.TEST_REPLICATE_CNT
     ,x_results.LAB_ORGANIZATION_ID
     ,x_results.RESULT_VALUE_NUM
     ,x_results.RESULT_VALUE_CHAR
     ,x_results.RESULT_DATE
     ,x_results.TEST_KIT_INV_ITEM_ID
     ,x_results.TEST_KIT_LOT_NUMBER
     ,x_results.TESTER_ID
     ,x_results.TEST_PROVIDER_ID
     ,x_results.ASSAY_RETEST
     ,x_results.AD_HOC_PRINT_ON_COA_IND
     ,x_results.SEQ
     ,x_results.DELETE_MARK
     ,x_results.TEXT_CODE
     ,x_results.ATTRIBUTE_CATEGORY
     ,x_results.ATTRIBUTE1
     ,x_results.ATTRIBUTE2
     ,x_results.ATTRIBUTE3
     ,x_results.ATTRIBUTE4
     ,x_results.ATTRIBUTE5
     ,x_results.ATTRIBUTE6
     ,x_results.ATTRIBUTE7
     ,x_results.ATTRIBUTE8
     ,x_results.ATTRIBUTE9
     ,x_results.ATTRIBUTE10
     ,x_results.ATTRIBUTE11
     ,x_results.ATTRIBUTE12
     ,x_results.ATTRIBUTE13
     ,x_results.ATTRIBUTE14
     ,x_results.ATTRIBUTE15
     ,x_results.ATTRIBUTE16
     ,x_results.ATTRIBUTE17
     ,x_results.ATTRIBUTE18
     ,x_results.ATTRIBUTE19
     ,x_results.ATTRIBUTE20
     ,x_results.ATTRIBUTE21
     ,x_results.ATTRIBUTE22
     ,x_results.ATTRIBUTE23
     ,x_results.ATTRIBUTE24
     ,x_results.ATTRIBUTE25
     ,x_results.ATTRIBUTE26
     ,x_results.ATTRIBUTE27
     ,x_results.ATTRIBUTE28
     ,x_results.ATTRIBUTE29
     ,x_results.ATTRIBUTE30
     ,x_results.CREATION_DATE
     ,x_results.CREATED_BY
     ,x_results.LAST_UPDATED_BY
     ,x_results.LAST_UPDATE_DATE
     ,x_results.LAST_UPDATE_LOGIN
     ,x_results.UPDATE_INSTANCE_ID
     ,x_results.PLANNED_RESOURCE
     ,x_results.PLANNED_RESOURCE_INSTANCE
     ,x_results.ACTUAL_RESOURCE
     ,x_results.ACTUAL_RESOURCE_INSTANCE
     ,x_results.PLANNED_RESULT_DATE
     ,x_results.TEST_BY_DATE
     ,0
     )
        RETURNING result_id INTO x_results.result_id
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_RESULTS_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;





FUNCTION delete_row (p_result_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_result_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_results
    WHERE  result_id = p_result_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_results
    SET    delete_mark = 1,
	   last_updated_by = fnd_global.user_id,
	   last_update_date = SYSDATE
    WHERE  result_id = p_result_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_RESULTS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_RESULTS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_RESULTS',
                            'RECORD','Result',
                            'KEY', p_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_RESULTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row (p_result_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_result_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_results
    WHERE  result_id = p_result_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_RESULTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_RESULTS',
                            'RECORD','Result',
                            'KEY', p_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_RESULTS_PVT', 'LOCK_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_results IN  gmd_results%ROWTYPE
, x_results OUT NOCOPY gmd_results%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_results.result_id IS NOT NULL) THEN
     SELECT *
     INTO   x_results
     FROM   gmd_results
     WHERE  result_id = p_results.result_id;

  ELSIF (p_results.test_id IS NOT NULL AND
         p_results.sample_id IS NOT NULL AND
         p_results.test_replicate_cnt IS NOT NULL ) THEN

     -- ADDED FOR BUG 2696353
     -- TEST_ID, SAMPLE_ID and test_replicate_cnt
     -- Should be the unique FK's to find a result record.

     SELECT *
     INTO   x_results
     FROM   gmd_results
     WHERE  test_id    = p_results.test_id
     AND    sample_id  = p_results.sample_id
     AND    test_replicate_cnt  = p_results.test_replicate_cnt;

  ELSE
     gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_RESULTS');
     RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_RESULTS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_RESULTS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_RESULTS_PVT;

/
