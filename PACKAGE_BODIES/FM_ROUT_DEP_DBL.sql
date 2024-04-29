--------------------------------------------------------
--  DDL for Package Body FM_ROUT_DEP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FM_ROUT_DEP_DBL" AS
/* $Header: GMDPRDDB.pls 115.2 2002/11/08 23:04:56 txdaniel noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMDPRDDB.pls
 |
 |   DESCRIPTION
 |      Package body for FM_ROUT_DEP table handlers
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |      - create_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      insert_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Insert_Row will insert a row in fm_rout_dep
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in fm_rout_dep
 |
 |
 |
 |   PARAMETERS
 |     p_out_dep IN  fm_rout_dep%ROWTYPE
 |     x_out_dep OUT fm_rout_dep%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

  FUNCTION insert_row (
    p_out_dep	IN FM_ROUT_DEP%ROWTYPE) RETURN BOOLEAN IS
  BEGIN

    INSERT INTO FM_ROUT_DEP
     (
      ROUTINGSTEP_NO
     ,DEP_ROUTINGSTEP_NO
     ,ROUTING_ID
     ,DEP_TYPE
     ,REWORK_CODE
     ,STANDARD_DELAY
     ,MINIMUM_DELAY
     ,MAX_DELAY
     ,TRANSFER_QTY
     ,ITEM_UM
     ,TEXT_CODE
     ,LAST_UPDATED_BY
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,CREATION_DATE
     ,LAST_UPDATE_LOGIN
     ,TRANSFER_PCT
     )
     VALUES
     (
      p_out_dep.ROUTINGSTEP_NO
     ,p_out_dep.DEP_ROUTINGSTEP_NO
     ,p_out_dep.ROUTING_ID
     ,p_out_dep.DEP_TYPE
     ,p_out_dep.REWORK_CODE
     ,p_out_dep.STANDARD_DELAY
     ,p_out_dep.MINIMUM_DELAY
     ,p_out_dep.MAX_DELAY
     ,p_out_dep.TRANSFER_QTY
     ,p_out_dep.ITEM_UM
     ,p_out_dep.TEXT_CODE
     ,p_out_dep.LAST_UPDATED_BY
     ,p_out_dep.CREATED_BY
     ,p_out_dep.LAST_UPDATE_DATE
     ,p_out_dep.CREATION_DATE
     ,p_out_dep.LAST_UPDATE_LOGIN
     ,p_out_dep.TRANSFER_PCT
     );
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      RETURN FALSE;
  END insert_row;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      fetch_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Fetch_Row will fetch a row in fm_rout_dep
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in fm_rout_dep
 |
 |
 |
 |   PARAMETERS
 |     p_out_dep IN  fm_rout_dep%ROWTYPE
 |     x_out_dep OUT fm_rout_dep%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

  FUNCTION fetch_row (
    p_out_dep	IN FM_ROUT_DEP%ROWTYPE
,   x_out_dep	OUT NOCOPY FM_ROUT_DEP%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    IF p_out_dep.routingstep_no IS NOT NULL
    AND   p_out_dep.dep_routingstep_no IS NOT NULL
    AND   p_out_dep.routing_id IS NOT NULL
    THEN
      SELECT
        ROUTINGSTEP_NO
       ,DEP_ROUTINGSTEP_NO
       ,ROUTING_ID
       ,DEP_TYPE
       ,REWORK_CODE
       ,STANDARD_DELAY
       ,MINIMUM_DELAY
       ,MAX_DELAY
       ,TRANSFER_QTY
       ,ITEM_UM
       ,TEXT_CODE
       ,LAST_UPDATED_BY
       ,CREATED_BY
       ,LAST_UPDATE_DATE
       ,CREATION_DATE
       ,LAST_UPDATE_LOGIN
       ,TRANSFER_PCT
      INTO
        x_out_dep.ROUTINGSTEP_NO
       ,x_out_dep.DEP_ROUTINGSTEP_NO
       ,x_out_dep.ROUTING_ID
       ,x_out_dep.DEP_TYPE
       ,x_out_dep.REWORK_CODE
       ,x_out_dep.STANDARD_DELAY
       ,x_out_dep.MINIMUM_DELAY
       ,x_out_dep.MAX_DELAY
       ,x_out_dep.TRANSFER_QTY
       ,x_out_dep.ITEM_UM
       ,x_out_dep.TEXT_CODE
       ,x_out_dep.LAST_UPDATED_BY
       ,x_out_dep.CREATED_BY
       ,x_out_dep.LAST_UPDATE_DATE
       ,x_out_dep.CREATION_DATE
       ,x_out_dep.LAST_UPDATE_LOGIN
       ,x_out_dep.TRANSFER_PCT
      FROM fm_rout_dep
      WHERE routingstep_no = p_out_dep.routingstep_no
      AND   dep_routingstep_no = p_out_dep.dep_routingstep_no
      AND   routing_id = p_out_dep.routing_id
      ;
    ELSE
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_KEY_VALUES');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_DEPEND_GIVEN_KEYS');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      RETURN FALSE;
  END fetch_row;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Row will delete a row in fm_rout_dep
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in fm_rout_dep
 |
 |
 |
 |   PARAMETERS
 |     p_out_dep IN  fm_rout_dep%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

  FUNCTION delete_row (
    p_out_dep	IN FM_ROUT_DEP%ROWTYPE) RETURN BOOLEAN IS
  BEGIN
    IF p_out_dep.routingstep_no IS NOT NULL
    AND   p_out_dep.dep_routingstep_no IS NOT NULL
    AND   p_out_dep.routing_id IS NOT NULL
    THEN
      DELETE FROM fm_rout_dep
      WHERE routingstep_no = p_out_dep.routingstep_no
      AND   dep_routingstep_no = p_out_dep.dep_routingstep_no
      AND   routing_id = p_out_dep.routing_id
      ;
    ELSE
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_KEY_VALUES');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_DEPEND_GIVEN_KEYS');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      RETURN FALSE;
  END delete_row;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      update_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Update_Row will update a row in fm_rout_dep
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in fm_rout_dep
 |
 |
 |
 |   PARAMETERS
 |     p_out_dep IN  fm_rout_dep%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

  FUNCTION update_row (
    p_out_dep	IN FM_ROUT_DEP%ROWTYPE) RETURN BOOLEAN IS
    l_dummy			NUMBER;
    locked_by_other_user	EXCEPTION;
    PRAGMA EXCEPTION_INIT	(locked_by_other_user, -54);
  BEGIN
    IF p_out_dep.routingstep_no IS NOT NULL
    AND   p_out_dep.dep_routingstep_no IS NOT NULL
    AND   p_out_dep.routing_id IS NOT NULL
    THEN
      SELECT 1 INTO l_dummy FROM fm_rout_dep
      WHERE routingstep_no = p_out_dep.routingstep_no
      AND   dep_routingstep_no = p_out_dep.dep_routingstep_no
      AND   routing_id = p_out_dep.routing_id
      FOR UPDATE NOWAIT;

      UPDATE fm_rout_dep
      SET
        ROUTINGSTEP_NO		= p_out_dep.ROUTINGSTEP_NO
       ,DEP_ROUTINGSTEP_NO		= p_out_dep.DEP_ROUTINGSTEP_NO
       ,ROUTING_ID		= p_out_dep.ROUTING_ID
       ,DEP_TYPE		= p_out_dep.DEP_TYPE
       ,REWORK_CODE		= p_out_dep.REWORK_CODE
       ,STANDARD_DELAY		= p_out_dep.STANDARD_DELAY
       ,MINIMUM_DELAY		= p_out_dep.MINIMUM_DELAY
       ,MAX_DELAY		= p_out_dep.MAX_DELAY
       ,TRANSFER_QTY		= p_out_dep.TRANSFER_QTY
       ,ITEM_UM		= p_out_dep.ITEM_UM
       ,TEXT_CODE		= p_out_dep.TEXT_CODE
       ,LAST_UPDATED_BY		= p_out_dep.LAST_UPDATED_BY
       ,CREATED_BY		= p_out_dep.CREATED_BY
       ,LAST_UPDATE_DATE		= p_out_dep.LAST_UPDATE_DATE
       ,CREATION_DATE		= p_out_dep.CREATION_DATE
       ,LAST_UPDATE_LOGIN		= p_out_dep.LAST_UPDATE_LOGIN
       ,TRANSFER_PCT		= p_out_dep.TRANSFER_PCT
      WHERE routingstep_no = p_out_dep.routingstep_no
      AND   dep_routingstep_no = p_out_dep.dep_routingstep_no
      AND   routing_id = p_out_dep.routing_id
      AND last_update_date = p_out_dep.last_update_date;
    ELSE
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_KEY_VALUES');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      FND_MESSAGE.SET_NAME('GMD', 'GMD_NO_DEPEND_GIVEN_KEYS');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_DEPEND_LOCK_FAILURE');
      FND_MSG_PUB.ADD;
      RETURN FALSE;
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
      FND_MSG_PUB.ADD;
      RETURN FALSE;
  END update_row;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      lock_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Lock_Row will lock a row in fm_rout_dep
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in fm_rout_dep
 |
 |
 |
 |   PARAMETERS
 |     p_out_dep IN  fm_rout_dep%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   20-MAR-01	Thomas Daniel	 Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

  FUNCTION lock_row (
    p_out_dep	IN FM_ROUT_DEP%ROWTYPE) RETURN BOOLEAN IS
    l_dummy			NUMBER;
  BEGIN
    IF p_out_dep.routingstep_no IS NOT NULL
    AND   p_out_dep.dep_routingstep_no IS NOT NULL
    AND   p_out_dep.routing_id IS NOT NULL
    THEN
      SELECT 1 INTO l_dummy FROM fm_rout_dep
      WHERE routingstep_no = p_out_dep.routingstep_no
      AND   dep_routingstep_no = p_out_dep.dep_routingstep_no
      AND   routing_id = p_out_dep.routing_id
      FOR UPDATE NOWAIT;
    END IF;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END lock_row;


END FM_ROUT_DEP_DBL;

/
