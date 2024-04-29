--------------------------------------------------------
--  DDL for Package Body GMD_SAMPLE_SPEC_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SAMPLE_SPEC_DISP_PVT" AS
/* $Header: GMDVSSDB.pls 115.3 2002/11/04 11:05:16 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVSSDB.pls                                        |
--| Package Name       : GMD_SAMPLE_SPEC_DISP_PVT                            |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Sample Spec Disposition  |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     14-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (p_sample_spec_disp IN  GMD_SAMPLE_SPEC_DISP%ROWTYPE)
RETURN BOOLEAN IS
BEGIN

    INSERT INTO GMD_SAMPLE_SPEC_DISP
     (
      EVENT_SPEC_DISP_ID
     ,SAMPLE_ID
     ,DISPOSITION
     ,DELETE_MARK
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     )
     VALUES
     (
      p_sample_spec_disp.EVENT_SPEC_DISP_ID
     ,p_sample_spec_disp.SAMPLE_ID
     ,p_sample_spec_disp.DISPOSITION
     ,p_sample_spec_disp.DELETE_MARK
     ,p_sample_spec_disp.CREATION_DATE
     ,p_sample_spec_disp.CREATED_BY
     ,p_sample_spec_disp.LAST_UPDATE_DATE
     ,p_sample_spec_disp.LAST_UPDATED_BY
     ,p_sample_spec_disp.LAST_UPDATE_LOGIN
     )
     ;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg ('GMD_SAMPLE_SPEC_DISP_PVT', 'INSERT_ROW');
      RETURN FALSE;

END insert_row;





FUNCTION delete_row
(
  p_event_spec_disp_id IN NUMBER
, p_sample_id          IN NUMBER
)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL AND
     p_sample_id          IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_sample_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    sample_id          = p_sample_id
    FOR UPDATE NOWAIT;

    UPDATE gmd_sample_spec_disp
    SET    delete_mark = 1
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    sample_id          = p_sample_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLE_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row
(
  p_event_spec_disp_id IN NUMBER
, p_sample_id          IN NUMBER
)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL AND
     p_sample_id          IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_sample_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    AND    sample_id          = p_sample_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLE_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_sample_spec_disp IN  gmd_sample_spec_disp%ROWTYPE
, x_sample_spec_disp OUT NOCOPY gmd_sample_spec_disp%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF p_sample_spec_disp.event_spec_disp_id IS NOT NULL AND
     p_sample_spec_disp.sample_id          IS NOT NULL THEN
    SELECT *
    INTO   x_sample_spec_disp
    FROM   gmd_sample_spec_disp
    WHERE  event_spec_disp_id = p_sample_spec_disp.event_spec_disp_id
    AND    sample_id          = p_sample_spec_disp.sample_id
    ;
      RETURN TRUE;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_SAMPLE_SPEC_DISP');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_SAMPLE_SPEC_DISP_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_SAMPLE_SPEC_DISP_PVT;

/
