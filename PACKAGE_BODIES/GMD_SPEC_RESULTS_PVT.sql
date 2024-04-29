--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_RESULTS_PVT" AS
/* $Header: GMDVSRSB.pls 115.4 2002/12/03 11:10:41 hverddin ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSREB.pls                                        |
--| Package Name       : GMD_SPEC_RESULTS_PVT                                |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Results                  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     09-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (p_spec_results IN  GMD_SPEC_RESULTS%ROWTYPE)
RETURN BOOLEAN IS
BEGIN

  INSERT INTO GMD_SPEC_RESULTS
   (
    EVENT_SPEC_DISP_ID
   ,RESULT_ID
   ,IN_SPEC_IND
   ,EVALUATION_IND
   ,ACTION_CODE
   ,UPDATE_INSTANCE_ID
   ,VALUE_IN_REPORT_PRECISION
   ,ADDITIONAL_TEST_IND
   ,WF_RESPONSE
   ,DELETE_MARK
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   )
   VALUES
   (
    p_spec_results.EVENT_SPEC_DISP_ID
   ,p_spec_results.RESULT_ID
   ,p_spec_results.IN_SPEC_IND
   ,p_spec_results.EVALUATION_IND
   ,p_spec_results.ACTION_CODE
   ,p_spec_results.UPDATE_INSTANCE_ID
   ,p_spec_results.VALUE_IN_REPORT_PRECISION
   ,p_spec_results.ADDITIONAL_TEST_IND
   ,p_spec_results.WF_RESPONSE
   ,p_spec_results.DELETE_MARK
   ,p_spec_results.CREATION_DATE
   ,p_spec_results.CREATED_BY
   ,p_spec_results.LAST_UPDATE_DATE
   ,p_spec_results.LAST_UPDATED_BY
   ,p_spec_results.LAST_UPDATE_LOGIN
   )
   ;

  IF SQL%FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg ('GMD_SPEC_RESULTS_PVT', 'INSERT_ROW');
    RETURN FALSE;

END insert_row;





FUNCTION delete_row
(
  p_event_spec_disp_id IN NUMBER
, p_result_id          IN NUMBER
)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL AND
     p_result_id          IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_spec_results
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    result_id          = p_result_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_spec_results
    SET    delete_mark = 1
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    result_id          = p_result_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SPEC_RESULTS');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SPEC_RESULTS');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SPEC_RESULTS',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SPEC_RESULTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row
(
  p_event_spec_disp_id IN NUMBER
, p_result_id          IN NUMBER
)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL AND
     p_result_id          IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_spec_results
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    result_id          = p_result_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SPEC_RESULTS');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SPEC_RESULTS',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SPEC_RESULTS_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_spec_results IN  gmd_spec_results%ROWTYPE
, x_spec_results OUT NOCOPY gmd_spec_results%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF p_spec_results.event_spec_disp_id IS NOT NULL AND
     p_spec_results.result_id          IS NOT NULL THEN
    SELECT *
    INTO   x_spec_results
    FROM   gmd_spec_results
    WHERE  event_spec_disp_id = p_spec_results.event_spec_disp_id
    AND    result_id          = p_spec_results.result_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SPEC_RESULTS');
    RETURN FALSE;
  END IF;

 -- BUG 2690469
 -- Added Missing Return Statement.

 RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SPEC_RESULTS');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_SPEC_RESULTS_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_SPEC_RESULTS_PVT;

/
