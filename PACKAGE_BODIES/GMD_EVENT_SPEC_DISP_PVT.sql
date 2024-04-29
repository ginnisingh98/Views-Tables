--------------------------------------------------------
--  DDL for Package Body GMD_EVENT_SPEC_DISP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_EVENT_SPEC_DISP_PVT" AS
/* $Header: GMDVESDB.pls 115.3 2002/11/04 10:35:41 kxhunt ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVESDB.pls                                        |
--| Package Name       : GMD_EVENT_SPEC_DISP_PVT                             |
--| Type               : Private                                             |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains private layer APIs for Event Spec Disposition   |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     09-Aug-2002     Created.                             |
--|                                                                          |
--+==========================================================================+
-- End of comments


FUNCTION insert_row (
  p_event_spec_disp IN  GMD_EVENT_SPEC_DISP%ROWTYPE
, x_event_spec_disp OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
)
RETURN BOOLEAN IS
BEGIN

  x_event_spec_disp := p_event_spec_disp;

  INSERT INTO GMD_EVENT_SPEC_DISP
   (
    EVENT_SPEC_DISP_ID
   ,SAMPLING_EVENT_ID
   ,SPEC_ID
   ,SPEC_VR_ID
   ,DISPOSITION
   ,SPEC_USED_FOR_LOT_ATTRIB_IND
   ,DELETE_MARK
   ,CREATION_DATE
   ,CREATED_BY
   ,LAST_UPDATE_DATE
   ,LAST_UPDATED_BY
   ,LAST_UPDATE_LOGIN
   )
   VALUES
   (
    gmd_qc_event_spec_disp_id_s.NEXTVAL
   ,x_event_spec_disp.SAMPLING_EVENT_ID
   ,x_event_spec_disp.SPEC_ID
   ,x_event_spec_disp.SPEC_VR_ID
   ,x_event_spec_disp.DISPOSITION
   ,x_event_spec_disp.SPEC_USED_FOR_LOT_ATTRIB_IND
   ,x_event_spec_disp.DELETE_MARK
   ,x_event_spec_disp.CREATION_DATE
   ,x_event_spec_disp.CREATED_BY
   ,x_event_spec_disp.LAST_UPDATE_DATE
   ,x_event_spec_disp.LAST_UPDATED_BY
   ,x_event_spec_disp.LAST_UPDATE_LOGIN
   )
      RETURNING event_spec_disp_id INTO x_event_spec_disp.event_spec_disp_id
   ;

  IF SQL%FOUND THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg ('GMD_EVENT_SPEC_DISP_PVT', 'INSERT_ROW');
    RETURN FALSE;

END insert_row;





FUNCTION delete_row (p_event_spec_disp_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_event_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    FOR UPDATE NOWAIT;

    DELETE gmd_event_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    ;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_EVENT_SPEC_DISP');
    RETURN FALSE;
  END IF;

  IF (SQL%FOUND) THEN
    RETURN TRUE;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_EVENT_SPEC_DISP');
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_EVENT_SPEC_DISP',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_EVENT_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END delete_row;




FUNCTION lock_row (p_event_spec_disp_id IN NUMBER)
RETURN BOOLEAN IS

  dummy       PLS_INTEGER;

  locked_by_other_user          EXCEPTION;
  PRAGMA EXCEPTION_INIT         (locked_by_other_user,-54);

BEGIN
  IF p_event_spec_disp_id IS NOT NULL THEN
    SELECT 1
    INTO   dummy
    FROM   gmd_event_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp_id
    FOR UPDATE NOWAIT;
  ELSE
    GMD_API_PUB.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_EVENT_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN locked_by_other_user THEN
    GMD_API_PUB.log_message('GMD_RECORD_LOCKED',
                            'TABLE_NAME', 'GMD_EVENT_SPEC_DISP',
                            'RECORD','Result',
                            'KEY', p_event_spec_disp_id);
    RETURN FALSE;

  WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg ('GMD_EVENT_SPEC_DISP_PVT', 'DELETE_ROW');
      RETURN FALSE;

END lock_row;



FUNCTION fetch_row (
  p_event_spec_disp IN  gmd_event_spec_disp%ROWTYPE
, x_event_spec_disp OUT NOCOPY gmd_event_spec_disp%ROWTYPE
)
RETURN BOOLEAN
IS
BEGIN

  IF (p_event_spec_disp.event_spec_disp_id IS NOT NULL) THEN
    SELECT *
    INTO   x_event_spec_disp
    FROM   gmd_event_spec_disp
    WHERE  event_spec_disp_id = p_event_spec_disp.event_spec_disp_id
    ;
  ELSE
    gmd_api_pub.log_message('GMD_NO_KEYS','TABLE_NAME', 'GMD_EVENT_SPEC_DISP');
    RETURN FALSE;
  END IF;

  RETURN TRUE;

EXCEPTION
 WHEN NO_DATA_FOUND
   THEN
     gmd_api_pub.log_message('GMD_NO_DATA_FOUND','TABLE_NAME', 'GMD_EVENT_SPEC_DISP');
     RETURN FALSE;
 WHEN OTHERS
   THEN
     fnd_msg_pub.add_exc_msg ('GMD_EVENT_SPEC_DISP_PVT', 'FETCH_ROW');
     RETURN FALSE;

END fetch_row;

END GMD_EVENT_SPEC_DISP_PVT;

/
