--------------------------------------------------------
--  DDL for Package Body GMD_COMPOSITE_RESULT_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMPOSITE_RESULT_ASSOC_PVT" AS
/* $Header: GMDVCRAB.pls 115.1 2002/11/04 10:19:45 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCRAB.pls                                        |
--| Package Name       : GMD_COMPOSITE_RESULT_ASSOC_PVT                      |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Composite Result Assoc.  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     12-Sep-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_composite_result_assoc IN  GMD_COMPOSITE_RESULT_ASSOC%ROWTYPE
) RETURN BOOLEAN IS
BEGIN

    INSERT INTO GMD_COMPOSITE_RESULT_ASSOC
     (
      COMPOSITE_RESULT_ID
     ,RESULT_ID
     ,EXCLUDE_IND
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     )
     VALUES
     (
      p_composite_result_assoc.COMPOSITE_RESULT_ID
     ,p_composite_result_assoc.RESULT_ID
     ,p_composite_result_assoc.EXCLUDE_IND
     ,p_composite_result_assoc.CREATION_DATE
     ,p_composite_result_assoc.CREATED_BY
     ,p_composite_result_assoc.LAST_UPDATE_DATE
     ,p_composite_result_assoc.LAST_UPDATED_BY
     ,p_composite_result_assoc.LAST_UPDATE_LOGIN
     )
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULT_ASSOC_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;




/*
FUNCTION delete_row (p_composite_result_id   IN  NUMBER,
                     p_result_id             IN  NUMBER,
                     p_last_update_date      IN  DATE,
                     p_last_updated_by 	     IN  NUMBER,
                     p_last_update_login     IN  NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN

  IF p_composite_result_id IS NOT NULL AND
     p_result_id IS NOT NULL THEN

    SELECT 1
    INTO   dummy
    FROM   gmd_composite_result_assoc
    WHERE  composite_result_id = p_composite_result_id
    AND    result_id           = p_result_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_composite_result_assoc
    SET    delete_mark = 1,
           last_update_date  = NVL(p_last_update_date,SYSDATE),
           last_updated_by   = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
           last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID)
    WHERE  composite_result_id = p_composite_result_id
    AND    result_id           = p_result_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULT_ASSOC_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;
*/



FUNCTION lock_row (p_composite_result_id   IN  NUMBER,
                   p_result_id             IN  NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_composite_result_id IS NOT NULL AND
     p_result_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_composite_result_assoc
    WHERE  composite_result_id = p_composite_result_id
    AND    result_id           = p_result_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_result_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULT_ASSOC_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_composite_result_assoc IN  gmd_composite_result_assoc%ROWTYPE
, x_composite_result_assoc OUT NOCOPY gmd_composite_result_assoc%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF p_composite_result_assoc.composite_result_id IS NOT NULL AND
     p_composite_result_assoc.result_id IS NOT NULL THEN
    SELECT *
    INTO   x_composite_result_assoc
    FROM   gmd_composite_result_assoc
    WHERE  composite_result_id = p_composite_result_assoc.composite_result_id
    AND    result_id           = p_composite_result_assoc.result_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_RESULT_ASSOC');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_RESULT_ASSOC_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_COMPOSITE_RESULT_ASSOC_PVT;

/
