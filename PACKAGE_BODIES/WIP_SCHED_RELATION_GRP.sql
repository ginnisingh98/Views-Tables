--------------------------------------------------------
--  DDL for Package Body WIP_SCHED_RELATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SCHED_RELATION_GRP" AS
/* $Header: wipgwlkb.pls 115.3 2003/10/14 15:26:44 amgarg noship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : wipgwlkb.pls                                               |
|                                                                           |
| DESCRIPTION  : This package, is a Group API, which contains functions     |
|              to Create and Delete relationships for Work Order Scheduling.|
|                                                                           |
| Coders       : Amit Garg                                                  |
+===========================================================================*/


/************************************************************************
 *  PACKAGE VARIABLES                                                   *
 ************************************************************************/


/******************************************************************************
* PROCEDURE INSERTROW                                                         *
*  This procedure is used to validate AND create Relationships to be          *
*  inserted in WIP_SCHED_RELATIONSHIPS Table                                  *
*  The input parameters for this procedure are:                               *
*   p_parentObjectID       :  Parent Object Idetifier                         *
*   p_parentObjectTypeID   :  Parent Object type Idetifier                    *
*   p_childObjectID        :  Child Object Idetifier                          *
*   p_childObjectTypeID    :  Child Object type Idetifier                     *
*   p_relationshipType     :  Type of relationship between parent and child   *
*   p_relationshipStatus   :  Relationship status,                            *
*                                  pending     : 0                            *
*                                  processing  : 1                            *
*                                  valid       : 2                            *
*                                  invalid     : 3                            *
*   x_return_status        :  out parameter to indicate success, failure or   *
*                             error for this procedure                        *
*   x_msg_count            :  out parameter indicating number of messages in  *
*                             msg list                                        *
*   x_msg_data             :  message in encoded form is returned             *
*   p_api_version          :  parameter indicating api version, to check for  *
*                             valid API version                               *
*   p_init_msg_list        :  Parameter to indicate whether public msg list   *
*                             is required to be initialised                   *
*   p_commit               :  Parameter to indicate if commit is required     *
*                             by this proc                                    *
******************************************************************************/
PROCEDURE insertRow(p_parentObjectID        IN NUMBER,
                      p_parentObjectTypeID  IN NUMBER,
                      p_childObjectID       IN NUMBER,
                      p_childObjectTypeID   IN NUMBER,
                      p_relationshipType    IN NUMBER,
                      p_relationshipStatus  IN NUMBER,
                      x_return_status       OUT NOCOPY VARCHAR2,
                      x_msg_count           OUT NOCOPY NUMBER,
                      x_msg_data            OUT NOCOPY VARCHAR2,
                      p_api_version         IN  NUMBER,
                      p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                      p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE)
IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'WIP_SCHED_RELATION_GRP';
  l_api_version       CONSTANT NUMBER         := 1.0;

  CURSOR top_level_object_cur IS
    SELECT  top_level_object_id,
            top_level_object_type_id
    FROM    wip_sched_relationships
    WHERE   child_object_id = p_parentObjectID
    AND     relationship_type = 1;

  CURSOR top_id_rel2_parent_cur IS
    SELECT  top_level_object_id,
            top_level_object_type_id
    FROM    wip_sched_relationships
    WHERE   child_object_id = p_parentObjectID
    AND     relationship_type = 1;

  CURSOR top_id_rel2_child_cur IS
    SELECT  top_level_object_id,
            top_level_object_type_id
    FROM    wip_sched_relationships
    WHERE   child_object_id = p_childObjectID
    AND     relationship_type = 1;

  l_top_level_object_id         NUMBER;
  l_top_level_object_id_tmp1    NUMBER := NULL;
  l_top_level_object_id_tmp2    NUMBER := NULL;
  l_top_level_object_type_id    NUMBER;
  l_Creation_Date         DATE;
  l_Created_By            NUMBER;
  l_last_UPDATE_date      DATE;
  l_last_UPDATEd_by       NUMBER;
  l_last_UPDATE_login     NUMBER;

  l_count_a   Number := 0;
  l_count_b   Number := 0;


  INVALID_OBJ_TYPE_EXCEPTION          EXCEPTION;
  INVALID_REL_TYPE_EXCEPTION          EXCEPTION;
  DEP_REL_EXIST_EXCEPTION             EXCEPTION;
  CONST_REL_EXIST_EXCEPTION           EXCEPTION;
  DUPLICATE_PARENT_EXCEPTION          EXCEPTION;
  LOOP_FOUND_EXCEPTION                EXCEPTION;
  INSERT_FAIL_EXCEPTION               EXCEPTION;
  PARENT_CHILD_SAME_EXCEPTION         EXCEPTION;
  BAD_REL_STATUS_EXCEPTION            EXCEPTION;

BEGIN

  /* Standard begin of API savepoint */
  SAVEPOINT  sp_wip_wol_grp;
  /* Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_API_VERSION,
                                      l_api_name,
                                      G_PKG_NAME)

  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /*  Check p_init_msg_list */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  /*   Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  /* Object type can be WO only */
  IF p_parentObjectTypeID <> WIP_CONSTANTS.G_Obj_TYPE_WO
    OR p_childObjectTypeID <> WIP_CONSTANTS.G_Obj_TYPE_WO
  THEN
    raise INVALID_OBJ_TYPE_EXCEPTION;
  END IF;


  /* Relationship type can be Type 1(Constrained) or Type 2(Dependent) only */
  IF p_relationshipType <> WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    AND p_relationshipType <> WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
  THEN
    raise INVALID_REL_TYPE_EXCEPTION;
  END IF;


  /* Check IF ParentID NOT same as ChildID */
  IF p_parentObjectID = p_childObjectID then
    raise PARENT_CHILD_SAME_EXCEPTION;
  END IF;


  /* Check if Relationship Status is 0,1,2 and 3 only */
  IF p_relationshipStatus <> WIP_CONSTANTS.G_REL_Status_Pending
    AND p_relationshipStatus <> WIP_CONSTANTS.G_REL_Status_Processing
    AND p_relationshipStatus <> WIP_CONSTANTS.G_REL_Status_Valid
    AND p_relationshipStatus <> WIP_CONSTANTS.G_REL_Status_Invalid
  then
    raise BAD_REL_STATUS_EXCEPTION;
  END IF;


  /*----------------------------+
  | VALIDATE FOR Rel Type 1     |
  +----------------------------*/
  IF P_RELATIONSHIPTYPE = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
  THEN

    /* Check Parent AND Child don't have Dependent Relationship */

    /* Check that the Child doesn't already have an existing Parent */
    SELECT  count(*)
    INTO    l_count_a
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    AND     child_object_id = p_childObjectID;

    IF l_count_a <>0 then
      raise DUPLICATE_PARENT_EXCEPTION;
    END IF;


    l_count_a := 0;
    /* Check IF Child doesn't lie in Parent hierarchy */
    SELECT  count(*)
    INTO    l_count_a
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     child_object_id = p_childObjectID
    START WITH  parent_object_id = p_parentObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT;


    /* Check IF Parent doesn't lie in Child hierarchy */
    SELECT  count(*) INTO l_count_b
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     child_object_id = p_parentObjectID
    START WITH  parent_object_id = p_childObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT;


    /* both l_count_a AND l_count_b should be ZERO. */
    IF l_count_a <>0 OR l_count_b <>0 then
      raise DEP_REL_EXIST_EXCEPTION;
    END IF;

    l_count_a := 0;
    l_count_b := 0;


    /* Populate TOP_LEVEL_OBJECT_ID for REL TYPE 1 */

    /*  Check if Parent is CHILD in any existing Relationships */
    OPEN  top_level_object_cur;
    FETCH top_level_object_cur
    INTO  l_top_level_object_id,
          l_top_level_object_type_id;
    IF top_level_object_cur%NOTFOUND then
    /* if parent node is root node */
      l_top_level_object_id := p_parentObjectID;
      l_top_level_object_type_id := p_parentObjectTypeID;
    END IF;
    CLOSE top_level_object_cur;


    /* For Rel Type 1, UPDATE TOP_LEVEL_OBJECT_ID for all records whose parent is CHILD */
    UPDATE  wip_sched_relationships
    SET     top_level_object_id       = l_top_level_object_id,
            top_level_object_type_id  = l_top_level_object_type_id
    WHERE   top_level_object_id = p_childObjectID
    AND     relationship_type   = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED;

  END IF;
  /*----------------------------+
  | END Relationship TYPE 1     |
  +----------------------------*/

  l_count_a := 0;
  l_count_b := 0;


  /*----------------------------+
  | VALIDATE FOR Rel Type 2     |
  +----------------------------*/
  IF P_RELATIONSHIPTYPE = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
  THEN


    /* Check Parent AND Child don't have CONSTRAINED Relationship */

    /* Check if Child doesn't lie in Parent hierarchy */
    SELECT  count(*) INTO l_count_a
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    AND     child_object_id = p_childObjectID
    START WITH  parent_object_id = p_parentObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED;

    /* Check if Parent doesn't lie in Child hierarchy */
    SELECT count(*) INTO l_count_b
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    AND     child_object_id = p_parentObjectID
    START WITH  parent_object_id = p_childObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED;

    /* both l_count_a AND l_count_b should be ZERO. */
    IF l_count_a <>0 OR l_count_b <>0 then
      raise CONST_REL_EXIST_EXCEPTION;
    END IF;

    l_count_a := 0;
    l_count_b := 0;


  /*------------------------------------------------------+
  | CHECK FOR LOOP IN CASE of DEPENDENT Relationships     |
  +------------------------------------------------------*/
    /* Check if Child doesn't lie in Parent hierarchy for Rel Type 2 */
    SELECT  count(*) INTO l_count_a
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     child_object_id = p_childObjectID
    START WITH  parent_object_id = p_parentObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT;

    /* Check if Parent doesn't lie in Child hierarchy for Rel Type 2 */
    SELECT count(*) INTO l_count_b
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     child_object_id = p_parentObjectID
    START WITH  parent_object_id = p_childObjectID
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    CONNECT BY  PRIOR child_object_id = parent_object_id
    AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT;

    /* both l_count_a AND l_count_b should be ZERO. */
    IF l_count_a <>0 OR l_count_b <>0 then
      raise LOOP_FOUND_EXCEPTION;
    END IF;

  /*--------------------------------------------------+
  | Populate TOP_LEVEL_OBJECT_ID for Rel Type 2       |
  +--------------------------------------------------*/
    /* Populate TOP_LEVEL_OBJECT_ID for REL TYPE 2 */

    /*  Check if Parent is CHILD in any existing Relationships */
    OPEN  top_id_rel2_parent_cur;
    FETCH top_id_rel2_parent_cur
    INTO  l_top_level_object_id_tmp1,
          l_top_level_object_type_id;
    CLOSE top_id_rel2_parent_cur;

    /*  Check if Child is CHILD in any existing Relationships */
    OPEN  top_id_rel2_child_cur;
    FETCH top_id_rel2_child_cur
    INTO  l_top_level_object_id_tmp2,
          l_top_level_object_type_id;
    CLOSE top_id_rel2_child_cur;

    /*  Check if Both TOP_LEVEL_OBJECT_IDs, if they exits, are same */
    /*  Populate NULL, if different, otherwise, populate this ID*/
    IF  l_top_level_object_id_tmp1 = l_top_level_object_id_tmp2
    THEN
      l_top_level_object_id := l_top_level_object_id_tmp2;
    ELSE
      l_top_level_object_id := NULL;
      l_top_level_object_type_id := NULL;
    END IF;

  END IF;
  /*--------------------------------+
  | END for Relationship TYPE 2     |
  +--------------------------------*/


  /*  If NO EXCEPTIONS, INSERT THE ROW */
  l_Creation_Date     := SYSDATE;
  l_Created_By        := FND_GLOBAL.USER_ID;
  l_last_UPDATE_date  := SYSDATE;
  l_last_UPDATEd_by   := FND_GLOBAL.USER_ID;
  l_last_UPDATE_login := FND_GLOBAL.LOGIN_ID;

  INSERT  INTO WIP_SCHED_RELATIONSHIPS(
                      SCHED_RELATIONSHIP_ID,
                      PARENT_OBJECT_ID,
                      PARENT_OBJECT_TYPE_ID,
                      CHILD_OBJECT_ID,
                      CHILD_OBJECT_TYPE_ID,
                      RELATIONSHIP_TYPE,
                      RELATIONSHIP_STATUS,
                      TOP_LEVEL_OBJECT_ID,
                      TOP_LEVEL_OBJECT_TYPE_ID,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_DATE,
                      Last_UPDATE_Login)
              VALUES(
                      WIP_SCHED_RELATIONSHIPS_S.NEXTVAL,
                      p_parentObjectID,
                      p_parentObjectTypeID,
                      p_childObjectID,
                      p_childObjectTypeID,
                      p_relationshipType,
                      p_relationshipStatus,
                      l_top_level_object_id,
                      l_top_level_object_type_id,
                      l_created_by,
                      l_creation_date,
                      l_last_UPDATEd_by,
                      l_last_UPDATE_date,
                      l_last_UPDATE_login);

  IF SQL%NOTFOUND THEN
    RAISE INSERT_FAIL_EXCEPTION;
  END IF;

  /* Standard check of p_commit */

  /* Commit work if p_commit flag true */
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  /* Standard call to get message count AND IF count is 1, get message info. */
  FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

Exception

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO sp_wip_wol_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  /* Take Appropriate Action, AND message */
  WHEN INVALID_OBJ_TYPE_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_INVALID_OBJ_TYPE');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN INVALID_REL_TYPE_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_INVALID_REL_TYPE');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN PARENT_CHILD_SAME_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_PARENT_CHILD_SAME');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN BAD_REL_STATUS_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_BAD_REL_STATUS');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN DEP_REL_EXIST_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_DEPENDENT_REL_EXIST');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN CONST_REL_EXIST_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_CONSTRAINED_REL_EXIST');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN DUPLICATE_PARENT_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_PARENT_EXIST');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN LOOP_FOUND_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_LOOP_FOUND');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN INSERT_FAIL_EXCEPTION
  THEN
    ROLLBACK to sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_name('WIP', 'WIP_WOL_INSERT_FAIL');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

  WHEN OTHERS THEN
    ROLLBACK TO sp_wip_wol_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name
            );
    END IF;
    FND_MSG_PUB.Count_AND_Get
    (   p_count             =>      x_msg_count,
        p_data              =>      x_msg_data
    );

END insertRow;




/************************************************************************
* PROCEDURE DELETEROW                                                   *
*  This procedure is used to validate AND DELETE Relationships FROM     *
*  WIP_SCHED_RELATIONSHIPS Table                                        *
*  The input parameters for this procedure are:                         *
*   p_relationshipID   :  Relationship idetifier to be deleted          *
*   x_return_status    :  To indicate procedure success, failure, error *
*   x_msg_count        :  To indicate number of msgs in msg list        *
*   x_msg_data         :  Return message in encoded form                *
*   p_api_version      :  To validate API version to be used            *
*   p_init_msg_list    :  Whether to intialize public msg list          *
*   p_commit           :  Whether to commit transaction                 *
************************************************************************/
PROCEDURE deleteRow(p_relationshipID      IN NUMBER,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2,
              p_api_version         IN  NUMBER,
              p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
              p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE)
IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'WIP_SCHED_RELATION_GRP';
  l_api_version       CONSTANT NUMBER         := 1.0;

  l_count_a           NUMBER := 0;
  l_child_object_id   NUMBER := 0;
  l_parent_object_id  NUMBER := 0;
  l_relationship_type NUMBER := 0;
  l_relationship_id_tmp       NUMBER := NULL;
  l_top_level_object_id_tmp1  NUMBER := NULL;
  l_top_level_object_id_tmp2  NUMBER := NULL;
  l_top_level_object_id       NUMBER;
  l_top_level_object_type_id  NUMBER;


  DEP_REL_EXIST_EXCEPTION   EXCEPTION;
  NO_SUCH_RELID_EXCEPTION   EXCEPTION;
  DELETE_FAIL_EXCEPTION     EXCEPTION;

  CURSOR dependent_rels_cur IS
    SELECT  distinct sched_relationship_id
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     sched_relationship_id
    IN
      (SELECT       SCHED_RELATIONSHIP_ID
      FROM          wip_sched_relationships
      START WITH    parent_object_id = l_parent_object_id
      CONNECT BY    PRIOR child_object_id = parent_object_id);

  CURSOR top_id_rel2_parent_cur IS
    SELECT  top_level_object_id,
            top_level_object_type_id
    FROM    wip_sched_relationships
    WHERE   relationship_type = 1
    AND     child_object_id =
      (SELECT   parent_object_id
      FROM      wip_sched_relationships
      WHERE     sched_relationship_id =
                l_relationship_id_tmp);

  CURSOR top_id_rel2_child_cur IS
    SELECT  top_level_object_id,
            top_level_object_type_id
    FROM    wip_sched_relationships
    WHERE   relationship_type = 1
    AND     child_object_id =
      (SELECT   child_object_id
      FROM      wip_sched_relationships
      WHERE     sched_relationship_id =
                l_relationship_id_tmp);

BEGIN

  /* Standard begin of API savepoint */
  SAVEPOINT   sp_wip_wol_grp;
  /*  Standard call to check for call compatibility. */
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_API_VERSION,
                                      l_api_name,
                                      G_PKG_NAME)

  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Check p_init_msg_list */
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  /*  Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  /* Check IF One Row exists for RelationshipID */
  BEGIN
    SELECT  child_object_id,
            parent_object_id,
            relationship_type
    INTO    l_child_object_id,
            l_parent_object_id,
            l_relationship_type
    FROM    WIP_SCHED_RELATIONSHIPS
    WHERE   sched_relationship_ID = p_relationshipID;
  EXCEPTION
    When NO_DATA_FOUND then
      raise NO_SUCH_RELID_EXCEPTION;
  END;

  /* IF relationship ID exists */

  /*-------------------+
  | FOR Rel Type 1     |
  +-------------------*/
  IF l_relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
  then

    /* Check CHILD not involved in any rel type 2 */
    SELECT  count(*) INTO l_count_a
    FROM    wip_sched_relationships
    WHERE   relationship_type = WIP_CONSTANTS.G_REL_TYPE_DEPENDENT
    AND     (parent_object_id = l_child_object_id
            OR  child_object_id = l_child_object_id);

    IF l_count_a <> 0
    then
      Raise DEP_REL_EXIST_EXCEPTION;
    END IF;


    /* UPDATE the TOP_LEVEL_OBJECT_ID of the subtree rooted at CHILD to be CHILD */
    UPDATE  wip_sched_relationships
    SET     top_level_object_id = l_child_object_id
    WHERE   SCHED_RELATIONSHIP_ID
    IN
      (SELECT     SCHED_RELATIONSHIP_ID FROM wip_sched_relationships
      WHERE       relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
      START WITH  parent_object_id = l_child_object_id
      AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED
      CONNECT BY  PRIOR child_object_id = parent_object_id
      AND         relationship_type = WIP_CONSTANTS.G_REL_TYPE_CONSTRAINED);


    /* UPDATE Top_level_object_id for all Rel type 2 relationships under Parent_object */
    FOR dependent_rel_cur_rec IN dependent_rels_cur
    LOOP
        l_relationship_id_tmp := dependent_rel_cur_rec.sched_relationship_id;

        OPEN top_id_rel2_parent_cur;
        FETCH top_id_rel2_parent_cur INTO l_top_level_object_id_tmp1, l_top_level_object_type_id;
        OPEN top_id_rel2_child_cur;
        FETCH top_id_rel2_child_cur INTO l_top_level_object_id_tmp2, l_top_level_object_type_id;

        /*if top_level_object_id of parent Or Child node in Rel type 2 is either NULL or Not equal */
        /* UPDATE it to NULL*/
        IF l_top_level_object_id_tmp1 <> l_top_level_object_id_tmp2
        then
          UPDATE  wip_sched_relationships
          SET     top_level_object_id = NULL
          WHERE   sched_relationship_id = l_relationship_id_tmp;
        END IF;

        CLOSE top_id_rel2_parent_cur;
        CLOSE top_id_rel2_child_cur;

    END LOOP;

  END IF;
  /*---------------------+
  | END IF for Rel type 1|
  +---------------------*/

  /* Delete the row NOW */
  DELETE FROM     WIP_SCHED_RELATIONSHIPS
  WHERE           SCHED_RELATIONSHIP_ID = p_relationshipID ;

  /* Check IF Delete fails */
  IF SQL%NOTFOUND THEN
    RAISE DELETE_FAIL_EXCEPTION;
  END IF;


  /*  Standard check of p_commit */
  /* Commit work IF p_commit flag true */
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  /*  Standard call to get message count AND IF count is 1, get message info. */
  FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO sp_wip_wol_GRP;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_wip_wol_grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

  WHEN DEP_REL_EXIST_EXCEPTION THEN
      ROLLBACK to sp_wip_wol_grp;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_name('WIP', 'WIP_WOL_CHILD_DEP_REL_EXIST');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

  WHEN NO_SUCH_RELID_EXCEPTION THEN
      ROLLBACK to sp_wip_wol_grp;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_name('WIP', 'WIP_WOL_NO_SUCH_REL_ID');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

  WHEN DELETE_FAIL_EXCEPTION
  THEN
      ROLLBACK to sp_wip_wol_grp;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_name('WIP', 'WIP_WOL_DELETE_FAIL');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

  WHEN OTHERS THEN
      ROLLBACK TO sp_wip_wol_grp;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
              FND_MSG_PUB.Add_Exc_Msg
              (       G_PKG_NAME,
                      l_api_name
              );
      END IF;
      FND_MSG_PUB.Count_AND_Get
      (   p_count             =>      x_msg_count,
          p_data              =>      x_msg_data
      );

END deleteRow;


END wip_sched_relation_grp;

/
