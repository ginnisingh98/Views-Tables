--------------------------------------------------------
--  DDL for Package Body GMD_COMPOSITE_SPEC_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_COMPOSITE_SPEC_DISP_PVT" AS
/* $Header: GMDVCSDB.pls 115.2 2002/11/04 10:24:14 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVCSDB.pls                                        |
--| Package Name       : GMD_COMPOSITE_SPEC_DISP_PVT                         |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Composite Spec Disp.     |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     12-Sep-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments

FUNCTION insert_row (
  p_composite_spec_disp IN  GMD_COMPOSITE_SPEC_DISP%ROWTYPE
, x_composite_spec_disp OUT NOCOPY GMD_COMPOSITE_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN IS
BEGIN

    x_composite_spec_disp := p_composite_spec_disp;

   INSERT INTO GMD_COMPOSITE_SPEC_DISP
   (
    COMPOSITE_SPEC_DISP_ID
   ,EVENT_SPEC_DISP_ID
   ,DISPOSITION
   ,LATEST_IND
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   ,DELETE_MARK
   )
   VALUES
   (
    gmd_qc_comp_spec_disp_id_s.NEXTVAL
   ,x_composite_spec_disp.EVENT_SPEC_DISP_ID
   ,x_composite_spec_disp.DISPOSITION
   ,x_composite_spec_disp.LATEST_IND
   ,x_composite_spec_disp.CREATION_DATE
   ,x_composite_spec_disp.CREATED_BY
   ,x_composite_spec_disp.LAST_UPDATE_DATE
   ,x_composite_spec_disp.LAST_UPDATED_BY
   ,x_composite_spec_disp.LAST_UPDATE_LOGIN
   ,x_composite_spec_disp.DELETE_MARK
   )
      RETURNING composite_spec_disp_id INTO x_composite_spec_disp.composite_spec_disp_id
   ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_SPEC_DISP_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;



FUNCTION delete_row (p_composite_spec_disp_id   IN  NUMBER,
                     p_last_update_date 	IN  DATE,
                     p_last_updated_by 	        IN  NUMBER,
                     p_last_update_login 	IN  NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN

  IF p_composite_spec_disp_id IS NOT NULL THEN

    SELECT 1
    INTO   dummy
    FROM   gmd_composite_spec_disp
    WHERE  composite_spec_disp_id = p_composite_spec_disp_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_composite_spec_disp
    SET    delete_mark = 1,
           last_update_date  = NVL(p_last_update_date,SYSDATE),
           last_updated_by   = NVL(p_last_updated_by,FND_GLOBAL.USER_ID),
           last_update_login = NVL(p_last_update_login,FND_GLOBAL.LOGIN_ID)
    WHERE  composite_spec_disp_id = p_composite_spec_disp_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;



FUNCTION lock_row (p_composite_spec_disp_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_composite_spec_disp_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_composite_spec_disp
    WHERE  composite_spec_disp_id = p_composite_spec_disp_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP',
                            'RECORD','Inventory Spec Validity Rule',
                            'KEY', p_composite_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_composite_spec_disp IN  gmd_composite_spec_disp%ROWTYPE
, x_composite_spec_disp OUT NOCOPY gmd_composite_spec_disp%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_composite_spec_disp.composite_spec_disp_id IS NOT NULL) THEN
    SELECT *
    INTO   x_composite_spec_disp
    FROM   gmd_composite_spec_disp
    WHERE  composite_spec_disp_id = p_composite_spec_disp.composite_spec_disp_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_COMPOSITE_SPEC_DISP');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_COMPOSITE_SPEC_DISP_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_COMPOSITE_SPEC_DISP_PVT;

/
