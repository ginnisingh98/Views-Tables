--------------------------------------------------------
--  DDL for Package Body CS_KB_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SECURITY_PVT" AS
/* $Header: cskvksb.pls 120.1 2005/10/05 15:08:34 mkettle noship $ */

/*=======================================================================+
 |                      Private Security Apis                            |
 |                   *****    Visibility    *****                        |
 | - Does_Visibility_Name_Exist                                          |
 | - Create_Visibility                                                   |
 | - Update_Visibility                                                   |
 | - Delete_Visibility                                                   |
 +=======================================================================*/

-- Start of comments
--	API name 	: DOES_VISIBILITY_NAME_EXIST
--	Type		: Private Function
--	Function	: Validates if the Visibility Name is duplicate
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  24-Sep-03 Matt Kettle   Changed Check_Name_Exists to check dates
--
--
--
--	Notes		:
--  1) We only validate duplicate Name NOT description as well
--
-- End of comments

FUNCTION DOES_VISIBILITY_NAME_EXIST (
  P_VISIBILITY_ID NUMBER,
  P_NAME          VARCHAR2
) RETURN VARCHAR2 IS

  CURSOR Check_Name_Exists IS
   SELECT count(*)
   FROM CS_KB_VISIBILITIES_VL
   WHERE name = P_NAME
   AND sysdate BETWEEN nvl(Start_Date_Active, SYSDATE-1)
                   AND nvl(End_Date_Active, SYSDATE+1)
   AND visibility_id <> P_VISIBILITY_ID;

  l_count NUMBER :=0;
  l_return VARCHAR2(10) := 'TRUE';

BEGIN
  OPEN  Check_Name_Exists;
  FETCH Check_Name_Exists INTO l_count;
  CLOSE Check_Name_Exists;
  --dbms_output.put_line('Dup Count ='||l_count);

  IF l_count <> 0 THEN
    l_return := 'TRUE';
  ELSE
    l_return := 'FALSE';
  END IF;
  --dbms_output.put_line('Return ='||l_return);
  RETURN l_return;

END DOES_VISIBILITY_NAME_EXIST;

---------------------------------------------------------------------
-- Visibilities are setup as follows:
--
--  Id    Name       Position
---------------------------------------------------------------------
--  2     External   3000       --> Least Restrictive (Public)
--  4     Limited    2000
--  1     Internal   1000       --> Most Restrictive  (Private)
--
--  Therefore the lower the Position the More Restrictive (Sensitive)
---------------------------------------------------------------------
-- Start of comments
--	API name 	: CREATE_VISIBILITY
--	Type		: Private
--	Function	: Create New Visibility Levels
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Optional
--            P_ADD_BEFORE_POSITION NUMBER  Optional
--            P_ADD_AFTER_POSITION  NUMBER  Required
--            P_START_DATE_ACTIVE   DATE    Optional
--            P_END_DATE_ACTIVE     DATE    Optional
--            P_NAME                VARCHAR Required
--            P_DESCRIPTION         VARCHAR Optional
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  15-Aug-03 Matt Kettle added call to CS_KB_SYNC_INDEX_PKG
--                        to request_mark_idx_on_sec_change
--  18-Sep-03 Matt Kettle Visibility UI now shows most public
--            at the top. There I have switched the add before
--            and after logic
--
--	Notes		:
--  1) If P_VISIBILITY_ID is passed as null it will be
--     generated via the sequence
--  2) Pass the visibility_id into P_ADD_BEFORE_VISIBILITY or
--     P_ADD_AFTER_VISIBILITY to enable creating the Visibility
--     in the correct place in the linear scale. If both these
--     params are null, the visibility will be added at the end.
--
--  Validations :
--  1) Required Parameters
--  2) Check Duplicate Visibility Name
-- End of comments

PROCEDURE CREATE_VISIBILITY (
  P_VISIBILITY_ID         IN          NUMBER,
  P_ADD_BEFORE_VISIBILITY IN          NUMBER,
  P_ADD_AFTER_VISIBILITY  IN          NUMBER,
  P_START_DATE_ACTIVE     IN          DATE,
  P_END_DATE_ACTIVE       IN          DATE,
  P_NAME                  IN          VARCHAR2,
  P_DESCRIPTION           IN          VARCHAR2,
  P_ATTRIBUTE_CATEGORY    IN VARCHAR2,
  P_ATTRIBUTE1            IN VARCHAR2,
  P_ATTRIBUTE2            IN VARCHAR2,
  P_ATTRIBUTE3            IN VARCHAR2,
  P_ATTRIBUTE4            IN VARCHAR2,
  P_ATTRIBUTE5            IN VARCHAR2,
  P_ATTRIBUTE6            IN VARCHAR2,
  P_ATTRIBUTE7            IN VARCHAR2,
  P_ATTRIBUTE8            IN VARCHAR2,
  P_ATTRIBUTE9            IN VARCHAR2,
  P_ATTRIBUTE10           IN VARCHAR2,
  P_ATTRIBUTE11           IN VARCHAR2,
  P_ATTRIBUTE12           IN VARCHAR2,
  P_ATTRIBUTE13           IN VARCHAR2,
  P_ATTRIBUTE14           IN VARCHAR2,
  P_ATTRIBUTE15           IN VARCHAR2,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS

  l_check          NUMBER        := 0;
  l_current_position NUMBER;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;
  l_new_position   NUMBER;
  l_position       NUMBER;
  l_position_check NUMBER        :=0;
  l_rowid          VARCHAR2(30)  := null;
  l_seq            NUMBER;
  l_request_id     NUMBER;
  l_return_status  VARCHAR2(1);

  CURSOR Check_Insert (v_vis_id NUMBER) IS
   SELECT COUNT(*)
   FROM CS_KB_VISIBILITIES_B
   WHERE VISIBILITY_ID = v_vis_id;

  CURSOR Get_Max_Position IS
   SELECT nvl(max(position),0)+1
   FROM CS_KB_VISIBILITIES_B;

  CURSOR Check_Position (v_position NUMBER) IS
   SELECT COUNT(*)
   FROM CS_KB_VISIBILITIES_B
   WHERE position = v_position;

  CURSOR Get_Position (v_vis NUMBER) IS
   SELECT position
   FROM CS_KB_VISIBILITIES_B
   WHERE visibility_id = v_vis;

BEGIN

  SAVEPOINT	Create_Visibility_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_NAME is null OR
     P_ADD_BEFORE_VISIBILITY IS NOT NULL  AND
     P_ADD_AFTER_VISIBILITY IS NOT NULL  THEN

     RAISE INVALID_IN_PARAMETERS;

  ELSE

     -- If Visibility is null (Not called from OA) then generate from
     -- the sequence.
     IF P_VISIBILITY_ID IS NULL THEN
        SELECT CS_KB_VISIBILITIES_B_S.nextval INTO l_seq from dual;
     ELSE
        l_seq := P_VISIBILITY_ID;
     END IF;
     --dbms_output.put_line('Sequence is ='||l_seq);
     -- Validate that the Visibility Name is not duplicate
     IF (DOES_VISIBILITY_NAME_EXIST(l_seq, P_NAME) = 'TRUE')  THEN
        -- Visibility Name is Duplicate
        RAISE DUPLICATE_VISIBILITY;
     ELSE
        --dbms_output.put_line('Before Vis:='||P_ADD_BEFORE_VISIBILITY);

        IF P_ADD_BEFORE_VISIBILITY IS NULL AND
           P_ADD_AFTER_VISIBILITY IS NULL THEN
           -- If No Position Specified, add at the End i.e. Highest Visibility
           OPEN  Get_Max_Position;
           FETCH Get_Max_Position INTO l_position;
           CLOSE Get_Max_Position;
        ELSE
           -- Set new Position
           IF P_ADD_BEFORE_VISIBILITY IS NOT NULL THEN

              OPEN  Get_Position (P_ADD_BEFORE_VISIBILITY);
              FETCH Get_Position INTO l_current_position;
              CLOSE Get_Position;

              l_new_position := l_current_position+1;
              IF l_new_position is null THEN
                 RAISE INVALID_IN_PARAMETERS;
              END IF;

           ELSE
              OPEN  Get_Position (P_ADD_AFTER_VISIBILITY);
              FETCH Get_Position INTO l_current_position;
              CLOSE Get_Position;

              l_new_position := l_current_position;
              IF l_new_position is null THEN
                 RAISE INVALID_IN_PARAMETERS;
              END IF;
           END IF;
           --dbms_output.put_line('New proposed position='||l_new_position);
           -- Check if requested position is used yet or not
           OPEN  Check_Position (l_new_position);
           FETCH Check_Position INTO l_position_check;
           CLOSE Check_Position;
           --dbms_output.put_line('Check Position='||l_position_check);
           -- If position not used then Use it
           IF l_position_check = 0 THEN
              l_position := l_new_position;
           ELSE
              -- If position is used already, Move all Visibilities
              -- from that position onwards down the list by one.
              -- i.e. Update their positions by Adding 1
              --dbms_output.put_line('Else Upd');

              UPDATE CS_KB_VISIBILITIES_B
              SET Position = Position + 1
              WHERE Position >= l_new_position;

              UPDATE CS_KB_CAT_GROUP_DENORM
              SET Visibility_Position = Visibility_Position + 1
              WHERE Visibility_Position >= l_new_position;

              l_position := l_new_position;
           END IF; --Check if Position already used

        END IF; -- Check new VL positioning

        --dbms_output.put_line('New Sequence-'||l_seq);
        CS_KB_VISIBILITIES_PKG.INSERT_ROW(
               X_ROWID             => l_rowid,
               X_VISIBILITY_ID     => l_seq ,
               X_POSITION          => l_position,
               X_START_DATE_ACTIVE => p_start_date_active,
               X_END_DATE_ACTIVE   => p_end_date_active,
               X_NAME              => p_name,
               X_DESCRIPTION       => p_description,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY        => l_current_user,
               X_LAST_UPDATE_DATE  => l_date,
               X_LAST_UPDATED_BY   => l_current_user,
               X_LAST_UPDATE_LOGIN => l_login,
               X_ATTRIBUTE_CATEGORY => p_attribute_category,
               X_ATTRIBUTE1 => p_attribute1,
               X_ATTRIBUTE2 => p_attribute2,
               X_ATTRIBUTE3 => p_attribute3,
               X_ATTRIBUTE4 => p_attribute4,
               X_ATTRIBUTE5 => p_attribute5,
               X_ATTRIBUTE6 => p_attribute6,
               X_ATTRIBUTE7 => p_attribute7,
               X_ATTRIBUTE8 => p_attribute8,
               X_ATTRIBUTE9 => p_attribute9,
               X_ATTRIBUTE10 => p_attribute10,
               X_ATTRIBUTE11 => p_attribute11,
               X_ATTRIBUTE12 => p_attribute12,
               X_ATTRIBUTE13 => p_attribute13,
               X_ATTRIBUTE14 => p_attribute14,
               X_ATTRIBUTE15 => p_attribute15 );

        -- Query DB to check the Insert was Successful
        OPEN  Check_Insert (l_seq);
        FETCH Check_Insert INTO l_check;
        CLOSE Check_Insert;
        --dbms_output.put_line('Insert Check-'||l_check);
        IF l_check <> 1 THEN
           RAISE INSERT_FAILED;
        ELSE
           IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.insert',
                            'Visibility Insert Successfull='||l_seq);
           END IF;
           --X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

           CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                ( 'ADD_VIS',
                                  l_position,
                                  null,
                                  l_request_id,
                                  l_return_status );

           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           ELSE
             RAISE INDEX_SYNC_FAILED;
           END IF;


        END IF; -- Insert Successful Check

     END IF; --Validate duplicate Visibility Name

  END IF; -- Validate Required Parameters Passed

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.end',
                   'Status='||X_RETURN_STATUS);
  END IF;


EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.invparam',
                     'P_NAME='||P_NAME||
                     'P_ADD_BEFORE_POSITION='||P_ADD_BEFORE_VISIBILITY||
                     'P_ADD_AFTER_POSITION='||P_ADD_AFTER_VISIBILITY);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INSERT_FAILED THEN
    ROLLBACK TO	Create_Visibility_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.insertcheck',
                     'Insert Row has failed='||l_check);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_CREATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DUPLICATE_VISIBILITY THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.dupcheck',
                     'Visibility Name is a Duplicate='||P_NAME);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_VIS_DUP_ERROR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INDEX_SYNC_FAILED THEN
    ROLLBACK TO	Create_Visibility_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.indexsync',
                     'Index Sync failed='||l_request_id);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Create_Visibility_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END CREATE_VISIBILITY;


-- Start of comments
--	API name 	: UPDATE_VISIBILITY
--	Type		: Private
--	Function	: Update Existing Visibility Levels
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER   Required
--            P_POSITION            NUMBER   Required
--            P_START_DATE_ACTIVE   DATE     Optional
--            P_END_DATE_ACTIVE     DATE     Optional
--            P_NAME                VARCHAR2 Required
--            P_DESCRIPTION         VARCHAR2 Optional

--
--	OUT		:	x_return_status		VARCHAR2(1)
--				x_msg_count			NUMBER
--				x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--
--  Validations :
--  1) Required Parameters
--  2) Check not updating Visibility Name to a Duplicate
-- End of comments

PROCEDURE UPDATE_VISIBILITY (
  P_VISIBILITY_ID         IN          NUMBER,
  P_POSITION              IN          NUMBER,
  P_START_DATE_ACTIVE     IN          DATE,
  P_END_DATE_ACTIVE       IN          DATE,
  P_NAME                  IN          VARCHAR2,
  P_DESCRIPTION           IN          VARCHAR2,
  P_ATTRIBUTE_CATEGORY    IN VARCHAR2,
  P_ATTRIBUTE1            IN VARCHAR2,
  P_ATTRIBUTE2            IN VARCHAR2,
  P_ATTRIBUTE3            IN VARCHAR2,
  P_ATTRIBUTE4            IN VARCHAR2,
  P_ATTRIBUTE5            IN VARCHAR2,
  P_ATTRIBUTE6            IN VARCHAR2,
  P_ATTRIBUTE7            IN VARCHAR2,
  P_ATTRIBUTE8            IN VARCHAR2,
  P_ATTRIBUTE9            IN VARCHAR2,
  P_ATTRIBUTE10           IN VARCHAR2,
  P_ATTRIBUTE11           IN VARCHAR2,
  P_ATTRIBUTE12           IN VARCHAR2,
  P_ATTRIBUTE13           IN VARCHAR2,
  P_ATTRIBUTE14           IN VARCHAR2,
  P_ATTRIBUTE15           IN VARCHAR2,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS

  l_check          NUMBER        := 0;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

  CURSOR Check_Update (v_vis_id NUMBER,
                       v_name VARCHAR2,
                       v_desc VARCHAR2 ) IS
   SELECT COUNT(*)
   FROM CS_KB_VISIBILITIES_VL
   WHERE visibility_id = v_vis_id
   AND   name = v_name;

BEGIN

  SAVEPOINT	Update_Visibility_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_NAME is null OR
     P_VISIBILITY_ID is null OR
     P_POSITION IS NULL THEN

     RAISE INVALID_IN_PARAMETERS;

  ELSE

     -- Validate that the Visibility Name is not being updated to a duplicate
     IF (DOES_VISIBILITY_NAME_EXIST(P_VISIBILITY_ID, P_NAME) = 'TRUE')  THEN
        -- Visibility Name is Duplicate
        RAISE DUPLICATE_VISIBILITY;
     ELSE
        --dbms_output.put_line('New Sequence-'||l_seq);
        CS_KB_VISIBILITIES_PKG.UPDATE_ROW(
               X_VISIBILITY_ID     => P_VISIBILITY_ID ,
               X_POSITION          => P_POSITION,
               X_START_DATE_ACTIVE => P_START_DATE_ACTIVE,
               X_END_DATE_ACTIVE   => P_END_DATE_ACTIVE,
               X_NAME              => P_NAME,
               X_DESCRIPTION       => P_DESCRIPTION,
               X_LAST_UPDATE_DATE  => l_date,
               X_LAST_UPDATED_BY   => l_current_user,
               X_LAST_UPDATE_LOGIN => l_login,
               X_ATTRIBUTE_CATEGORY => P_ATTRIBUTE_CATEGORY,
               X_ATTRIBUTE1 => P_ATTRIBUTE1,
               X_ATTRIBUTE2 => P_ATTRIBUTE2,
               X_ATTRIBUTE3 => P_ATTRIBUTE3,
               X_ATTRIBUTE4 => P_ATTRIBUTE4,
               X_ATTRIBUTE5 => P_ATTRIBUTE5,
               X_ATTRIBUTE6 => P_ATTRIBUTE6,
               X_ATTRIBUTE7 => P_ATTRIBUTE7,
               X_ATTRIBUTE8 => P_ATTRIBUTE8,
               X_ATTRIBUTE9 => P_ATTRIBUTE9,
               X_ATTRIBUTE10 => P_ATTRIBUTE10,
               X_ATTRIBUTE11 => P_ATTRIBUTE11,
               X_ATTRIBUTE12 => P_ATTRIBUTE12,
               X_ATTRIBUTE13 => P_ATTRIBUTE13,
               X_ATTRIBUTE14 => P_ATTRIBUTE14,
               X_ATTRIBUTE15 => P_ATTRIBUTE15
               );

           -- Query DB to check the Insert was Successful
           OPEN  Check_Update (P_VISIBILITY_ID, P_NAME, P_DESCRIPTION);
           FETCH Check_Update INTO l_check;
           CLOSE Check_Update;
           --dbms_output.put_line('Insert Check-'||l_check);

           IF l_check <> 1 THEN
              RAISE UPDATE_FAILED;
           ELSE
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.update',
                               'Visibility Update Successfull='||P_VISIBILITY_ID);
              END IF;

              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           END IF; -- Update Successful Check

     END IF; --Validate duplicate Visibility Name

  END IF; -- Validate Required Parameters Passed

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_VISIBILITY.end',
                   'Status='||X_RETURN_STATUS);
  END IF;


EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.invparam',
                     'P_NAME='||P_NAME||
                     'P_VISIBILITY='||P_VISIBILITY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN UPDATE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.updcheck',
                     'Update Row has failed='||l_check);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UPDATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DUPLICATE_VISIBILITY THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.dupcheck',
                     'Visibility Name is a Duplicate='||P_NAME);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_VIS_DUP_ERROR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Update_Visibility_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_VISIBILITY.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END UPDATE_VISIBILITY;

-- Start of comments
--	API name 	: DELETE_VISIBILITY
--	Type		: Private
--	Function	: Delete Existing Visibility Levels
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER   Required
--
--
--	OUT		:	x_return_status		VARCHAR2(1)
--				x_msg_count			NUMBER
--				x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  15-Aug-03 Matt Kettle added call to CS_KB_SYNC_INDEX_PKG
--                        to request_mark_idx_on_sec_change
--
--
--
--	Notes		:
--  1) This api performs a 'Soft' Delete - i.e The Visibility is End-Dated
--
--  Validations:
--  1) Required Parameters
--  2) Check if the Visibility is used by a Category
--  3) Check if the Visibility is used by a Solution
-- End of comments
PROCEDURE DELETE_VISIBILITY (
  P_VISIBILITY_ID       IN          NUMBER,
  X_RETURN_STATUS       OUT NOCOPY  VARCHAR2,
  X_MSG_DATA            OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT           OUT NOCOPY  NUMBER
) IS

 CURSOR USED_IN_SOLUTION IS
  SELECT count(*)
  FROM CS_KB_SETS_B
  WHERE visibility_id = P_VISIBILITY_ID
  AND STATUS <> 'OBS'
  AND LATEST_VERSION_FLAG = 'Y';


 CURSOR USED_IN_CATEGORY IS
  SELECT count(*)
  FROM CS_KB_SOLN_CATEGORIES_B
  WHERE visibility_id = P_VISIBILITY_ID;

 CURSOR CHECK_VISIBILITY IS
  SELECT count(*)
  FROM CS_KB_VISIBILITIES_B
  WHERE visibility_id = P_VISIBILITY_ID
  AND sysdate between nvl(Start_Date_Active, sysdate -1)
                  and nvl(End_Date_Active, sysdate +1);

 CURSOR GET_POSITION IS
  SELECT Position
  FROM CS_KB_VISIBILITIES_B
  WHERE visibility_id = P_VISIBILITY_ID;


  l_cat_count NUMBER;
  l_soln_count NUMBER;
  l_vis_count NUMBER;
  l_position  NUMBER;
  l_request_id     NUMBER;
  l_return_status  VARCHAR2(1);
  l_current_user   NUMBER        := FND_GLOBAL.user_id;

BEGIN
  SAVEPOINT	Delete_Visibility_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.begin',
                   'User='||l_current_user);
  END IF;

  OPEN  CHECK_VISIBILITY;
  FETCH CHECK_VISIBILITY INTO l_vis_count;
  CLOSE CHECK_VISIBILITY;

  -- Validate Required Parameters have been passed into api
  IF P_VISIBILITY_ID is null OR
     l_vis_count = 0 THEN
     RAISE INVALID_IN_PARAMETERS;
  ELSE
     -- Validate if Visibility is used in Categories
     OPEN  USED_IN_CATEGORY;
     FETCH USED_IN_CATEGORY INTO l_cat_count;
     CLOSE USED_IN_CATEGORY;
     -- Validate if Visibility is used in Solutions
     OPEN  USED_IN_SOLUTION;
     FETCH USED_IN_SOLUTION INTO l_soln_count;
     CLOSE USED_IN_SOLUTION;

     IF l_cat_count <> 0 OR l_soln_count <> 0 THEN
        RAISE UNABLE_TO_DELETE_VIS;
     ELSE

        -- We will nolonger Delete the Visibility - We will End Date it instead
        UPDATE CS_KB_VISIBILITIES_B
        SET End_Date_Active = sysdate - 0.001,
            Last_Update_date = sysdate,
            Last_updated_By = FND_GLOBAL.User_id
        WHERE Visibility_Id = P_VISIBILITY_ID;
--dbms_output.put_line('before vis count = '||l_vis_count);
        OPEN  CHECK_VISIBILITY;
        FETCH CHECK_VISIBILITY INTO l_vis_count;
        CLOSE CHECK_VISIBILITY;
--dbms_output.put_line('after vis count = '||l_vis_count);
        IF l_vis_count = 0 THEN
           OPEN  GET_POSITION;
           FETCH GET_POSITION INTO l_position;
           CLOSE GET_POSITION;

           CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                ( 'REM_VIS',
                                  l_position,
                                  null,
                                  l_request_id,
                                  l_return_status );

           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           ELSE
             RAISE INDEX_SYNC_FAILED;
           END IF;


        ELSE
           X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
           RAISE DELETE_FAILED;
        END IF;
     END IF;

  END IF; -- Valid Param Check

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.end',
                   'Status='||X_RETURN_STATUS);
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.invparam',
                     'P_VISIBILITY_ID='||P_VISIBILITY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN UNABLE_TO_DELETE_VIS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.invdel',
                     'P_VISIBILITY_ID='||P_VISIBILITY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_VIS_INV_DEL');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN DELETE_FAILED THEN
    ROLLBACK TO	Delete_Visibility_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.deletefail',
                     'Delete Row has failed='||l_vis_count);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_DELETE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN INDEX_SYNC_FAILED THEN
    ROLLBACK TO	Delete_Visibility_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.indexsync',
                     'Index Sync failed='||l_request_id);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Delete_Visibility_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_VISIBILITY.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END DELETE_VISIBILITY;


/*=======================================================================+
 |                      Private Security Apis                            |
 |                 *****    Category Group    *****                      |
 | - Does_Category_Group_Name_Exist                                      |
 | - Create_Category_Group                                               |
 | - Update_Category_Group                                               |
 | - Delete_Category_Group                                               |
 +=======================================================================*/

-- Start of comments
--	API name 	: DOES_CATEGORY_GROUP_NAME_EXIST
--	Type		: Private Function
--	Function	: Validates if the Category Group Name is duplicate
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID   NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) We only validate duplicate Name NOT description as well
--
-- End of comments
FUNCTION DOES_CATEGORY_GROUP_NAME_EXIST (
  P_CATEGORY_GROUP_ID NUMBER,
  P_NAME          VARCHAR2
) RETURN VARCHAR2 IS

  CURSOR Check_Name_Exists IS
   SELECT count(*)
   FROM CS_KB_CATEGORY_GROUPS_VL
   WHERE name = P_NAME
   AND category_group_id <> P_CATEGORY_GROUP_ID;

  l_count NUMBER :=0;
  l_return VARCHAR2(10) := 'TRUE';

BEGIN

  OPEN  Check_Name_Exists;
  FETCH Check_Name_Exists INTO l_count;
  CLOSE Check_Name_Exists;
  --dbms_output.put_line('Dup Count ='||l_count);
  IF l_count <> 0 THEN
    l_return := 'TRUE';
  ELSE
    l_return := 'FALSE';
  END IF;
  --dbms_output.put_line('Return ='||l_return);
  RETURN l_return;

END DOES_CATEGORY_GROUP_NAME_EXIST;

-- Start of comments
--	API name 	: CREATE_CATEGORY_GROUP
--	Type		: Private
--	Function	: Create new Category Groups
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Optional
--            P_START_DATE_ACTIVE     DATE     Optional
--            P_END_DATE_ACTIVE       DATE     Optional
--            P_NAME                  VARCHAR  Required
--            P_DESCRIPTION           VARCHAR  Optional
--
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) If P_CATEGORY_GROUP_ID is passed as null it will be
--     generated via the sequence
--
--  Validations:
--  1) Required Parameters
--  2) Checks that the Category Group Name is not duplicate
-- End of comments
PROCEDURE CREATE_CATEGORY_GROUP (
  P_CATEGORY_GROUP_ID     IN          NUMBER,
  P_START_DATE_ACTIVE     IN          DATE,
  P_END_DATE_ACTIVE       IN          DATE,
  P_NAME                  IN          VARCHAR,
  P_DESCRIPTION           IN          VARCHAR,
  P_ATTRIBUTE_CATEGORY    IN          VARCHAR2,
  P_ATTRIBUTE1            IN          VARCHAR2,
  P_ATTRIBUTE2            IN          VARCHAR2,
  P_ATTRIBUTE3            IN          VARCHAR2,
  P_ATTRIBUTE4            IN          VARCHAR2,
  P_ATTRIBUTE5            IN          VARCHAR2,
  P_ATTRIBUTE6            IN          VARCHAR2,
  P_ATTRIBUTE7            IN          VARCHAR2,
  P_ATTRIBUTE8            IN          VARCHAR2,
  P_ATTRIBUTE9            IN          VARCHAR2,
  P_ATTRIBUTE10           IN          VARCHAR2,
  P_ATTRIBUTE11           IN          VARCHAR2,
  P_ATTRIBUTE12           IN          VARCHAR2,
  P_ATTRIBUTE13           IN          VARCHAR2,
  P_ATTRIBUTE14           IN          VARCHAR2,
  P_ATTRIBUTE15           IN          VARCHAR2,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS

  l_check          NUMBER;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;
  l_rowid          VARCHAR2(30)  := null;
  l_seq            NUMBER;

  CURSOR Check_Insert (v_cg_id NUMBER) IS
   SELECT COUNT(*)
   FROM CS_KB_CATEGORY_GROUPS_B
   WHERE CATEGORY_GROUP_ID = v_cg_id;

BEGIN

  SAVEPOINT	Create_Category_Group_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_NAME IS NULL THEN
     RAISE INVALID_IN_PARAMETERS;
  ELSE

     IF P_CATEGORY_GROUP_ID IS NULL THEN
        SELECT CS_KB_CATEGORY_GROUPS_B_S.nextval INTO l_seq from dual;
     ELSE
        l_seq := P_CATEGORY_GROUP_ID;
     END IF;

     -- Validate that the Category Group Name is not duplicate
     IF (DOES_CATEGORY_GROUP_NAME_EXIST(l_seq, P_NAME) = 'TRUE')  THEN
        -- Visibility Name is Duplicate
        RAISE DUPLICATE_CATEGORY_GROUP;
     ELSE

       CS_KB_CATEGORY_GROUPS_PKG.INSERT_ROW (
               X_ROWID => l_rowid,
               X_CATEGORY_GROUP_ID => l_seq ,
               X_START_DATE_ACTIVE => p_start_date_active,
               X_END_DATE_ACTIVE   => p_end_date_active,
               X_NAME              => p_name,
               X_DESCRIPTION       => p_description,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY        => l_current_user,
               X_LAST_UPDATE_DATE  => l_date,
               X_LAST_UPDATED_BY   => l_current_user,
               X_LAST_UPDATE_LOGIN => l_login,
               X_ATTRIBUTE_CATEGORY => p_attribute_category,
               X_ATTRIBUTE1         => p_attribute1,
               X_ATTRIBUTE2         => p_attribute2,
               X_ATTRIBUTE3         => p_attribute3,
               X_ATTRIBUTE4         => p_attribute4,
               X_ATTRIBUTE5         => p_attribute5,
               X_ATTRIBUTE6         => p_attribute6,
               X_ATTRIBUTE7         => p_attribute7,
               X_ATTRIBUTE8         => p_attribute8,
               X_ATTRIBUTE9         => p_attribute9,
               X_ATTRIBUTE10        => p_attribute10,
               X_ATTRIBUTE11        => p_attribute11,
               X_ATTRIBUTE12        => p_attribute12,
               X_ATTRIBUTE13        => p_attribute13,
               X_ATTRIBUTE14        => p_attribute14,
               X_ATTRIBUTE15        => p_attribute15);

           -- Query DB to check the Insert was Successful
           OPEN  Check_Insert (l_seq);
           FETCH Check_Insert INTO l_check;
           CLOSE Check_Insert;
           --dbms_output.put_line('Insert Check-'||l_check);
           IF l_check <> 1 THEN
              RAISE INSERT_FAILED;
           ELSE
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.insert',
                               'Visibility Insert Successfull='||l_seq);
              END IF;

              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           END IF; -- Insert Successful Check
     END IF; -- Check Name Dup
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.end',
                   'Status='||X_RETURN_STATUS);
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.invparam',
                     'P_NAME='||P_NAME||
                     'P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INSERT_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.insertcheck',
                     'Insert Row has failed='||l_check);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_CREATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DUPLICATE_CATEGORY_GROUP THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.dupcheck',
                     'Category Group Name is a Duplicate='||P_NAME);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_CG_DUP_ERROR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Create_Category_Group_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);

END CREATE_CATEGORY_GROUP;

-- Start of comments
--	API name 	: UPDATE_CATEGORY_GROUP
--	Type		: Private
--	Function	: Update Existing Category Groups
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Required
--            P_START_DATE_ACTIVE     DATE     Optional
--            P_END_DATE_ACTIVE       DATE     Optional
--            P_NAME                  VARCHAR  Required
--            P_DESCRIPTION           VARCHAR  Optional
--
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--
--  Validations:
--  1) Required Parameters
--  2) Checks that the Category Group Name is not being updated duplicate
-- End of comments
PROCEDURE UPDATE_CATEGORY_GROUP (
  P_CATEGORY_GROUP_ID     IN          NUMBER,
  P_START_DATE_ACTIVE     IN          DATE,
  P_END_DATE_ACTIVE       IN          DATE,
  P_NAME                  IN          VARCHAR,
  P_DESCRIPTION           IN          VARCHAR,
  P_ATTRIBUTE_CATEGORY    IN          VARCHAR2,
  P_ATTRIBUTE1            IN          VARCHAR2,
  P_ATTRIBUTE2            IN          VARCHAR2,
  P_ATTRIBUTE3            IN          VARCHAR2,
  P_ATTRIBUTE4            IN          VARCHAR2,
  P_ATTRIBUTE5            IN          VARCHAR2,
  P_ATTRIBUTE6            IN          VARCHAR2,
  P_ATTRIBUTE7            IN          VARCHAR2,
  P_ATTRIBUTE8            IN          VARCHAR2,
  P_ATTRIBUTE9            IN          VARCHAR2,
  P_ATTRIBUTE10           IN          VARCHAR2,
  P_ATTRIBUTE11           IN          VARCHAR2,
  P_ATTRIBUTE12           IN          VARCHAR2,
  P_ATTRIBUTE13           IN          VARCHAR2,
  P_ATTRIBUTE14           IN          VARCHAR2,
  P_ATTRIBUTE15           IN          VARCHAR2,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS

  l_check          NUMBER;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

  CURSOR Check_Update IS
   SELECT COUNT(*)
   FROM CS_KB_CATEGORY_GROUPS_VL
   WHERE CATEGORY_GROUP_ID = P_CATEGORY_GROUP_ID
   AND   NAME = P_NAME;

BEGIN
  SAVEPOINT	Update_Category_Group_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_NAME IS NULL OR P_CATEGORY_GROUP_ID IS NULL THEN
     RAISE INVALID_IN_PARAMETERS;
  ELSE

     -- Validate that the Category Group Name is not duplicate
     IF (DOES_CATEGORY_GROUP_NAME_EXIST(P_CATEGORY_GROUP_ID, P_NAME) = 'TRUE')  THEN
        -- Visibility Name is Duplicate
        RAISE DUPLICATE_CATEGORY_GROUP;
     ELSE

       CS_KB_CATEGORY_GROUPS_PKG.UPDATE_ROW (
               X_CATEGORY_GROUP_ID => P_CATEGORY_GROUP_ID ,
               X_START_DATE_ACTIVE => p_start_date_active,
               X_END_DATE_ACTIVE   => p_end_date_active,
               X_NAME              => p_name,
               X_DESCRIPTION       => p_description,
               X_LAST_UPDATE_DATE  => l_date,
               X_LAST_UPDATED_BY   => l_current_user,
               X_LAST_UPDATE_LOGIN => l_login,
               X_ATTRIBUTE_CATEGORY => p_attribute_category,
               X_ATTRIBUTE1         => p_attribute1,
               X_ATTRIBUTE2         => p_attribute2,
               X_ATTRIBUTE3         => p_attribute3,
               X_ATTRIBUTE4         => p_attribute4,
               X_ATTRIBUTE5         => p_attribute5,
               X_ATTRIBUTE6         => p_attribute6,
               X_ATTRIBUTE7         => p_attribute7,
               X_ATTRIBUTE8         => p_attribute8,
               X_ATTRIBUTE9         => p_attribute9,
               X_ATTRIBUTE10        => p_attribute10,
               X_ATTRIBUTE11        => p_attribute11,
               X_ATTRIBUTE12        => p_attribute12,
               X_ATTRIBUTE13        => p_attribute13,
               X_ATTRIBUTE14        => p_attribute14,
               X_ATTRIBUTE15        => p_attribute15);

           -- Query DB to check the Update was Successful
           OPEN  Check_Update;
           FETCH Check_Update INTO l_check;
           CLOSE Check_Update;
           --dbms_output.put_line('Update Check-'||l_check);
           IF l_check <> 1 THEN
              RAISE UPDATE_FAILED;
           ELSE
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.update',
                               'Cat Grp Update Successfull='||P_CATEGORY_GROUP_ID);
              END IF;

              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           END IF; -- Update Successful Check
     END IF; -- Check Name Dup

  END IF; -- Valid Params Passed

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.end',
                   'Status='||X_RETURN_STATUS);
  END IF;
EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.invparam',
                     'P_NAME='||P_NAME||
                     'P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DUPLICATE_CATEGORY_GROUP THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.dupcheck',
                     'Update is Duplicate='||p_name);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_CG_DUP_ERROR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN UPDATE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.updatecheck',
                     'Update Row has failed='||l_check);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UPDATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN OTHERS THEN
    ROLLBACK TO	Update_Category_Group_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_GROUP.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END UPDATE_CATEGORY_GROUP;

-- Start of comments
--	API name 	: DELETE_CATEGORY_GROUP
--	Type		: Private
--	Function	: Delete an Existing Category Group
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Required
--
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  07-Apr-04 Matt Kettle   Added valdn to check flows (3559443)
--
--
--	Notes		:
--  1) This performs a 'Hard' Delete i.e. Row is removed
--
--  Validations:
--  1) Required Parameters
--  2) Checks if the Category Group has any Members
--  3) Checks if the Category Group has any Flows
-- End of comments
PROCEDURE DELETE_CATEGORY_GROUP (
  P_CATEGORY_GROUP_ID     IN          NUMBER,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS


 CURSOR CHECK_DELETE IS
  SELECT count(*)
  FROM CS_KB_CATEGORY_GROUPS_VL
  WHERE category_group_id = P_CATEGORY_GROUP_ID;

 CURSOR CHECK_MEMBERS IS
  SELECT count(*)
  FROM CS_KB_CAT_GROUP_MEMBERS
  WHERE category_group_id = P_CATEGORY_GROUP_ID;

 CURSOR CHECK_FLOWS IS
  SELECT count(*)
  FROM CS_KB_CAT_GROUP_FLOWS
  WHERE category_group_id = P_CATEGORY_GROUP_ID;

  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_member_count   NUMBER;
  l_flow_count   NUMBER;
  l_valid NUMBER;

BEGIN
  SAVEPOINT	Delete_Category_Group_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.begin',
                   'User='||l_current_user);
  END IF;

  OPEN  CHECK_DELETE;
  FETCH CHECK_DELETE INTO l_valid;
  CLOSE CHECK_DELETE;

  -- Validate Required Parameters have been passed into api
  IF P_CATEGORY_GROUP_ID is null OR
     l_valid = 0 THEN
     RAISE CG_NOT_FOUND;
  ELSE
     OPEN  CHECK_MEMBERS;
     FETCH CHECK_MEMBERS INTO l_member_count;
     CLOSE CHECK_MEMBERS;

     IF l_member_count <> 0 THEN
        RAISE CG_MEMBERS_EXIST;
     ELSE

        OPEN  CHECK_FLOWS;
        FETCH CHECK_FLOWS INTO l_flow_count;
        CLOSE CHECK_FLOWS;

        IF l_flow_count <> 0 THEN
          RAISE CG_FLOWS_EXIST;
        ELSE

          -- No Members or Flows exist so proceed with Delete
          CS_KB_CATEGORY_GROUPS_PKG.DELETE_ROW (X_CATEGORY_GROUP_ID => P_CATEGORY_GROUP_ID);

          OPEN  CHECK_DELETE;
          FETCH CHECK_DELETE INTO l_valid;
          CLOSE CHECK_DELETE;
          IF l_valid = 0 THEN
            X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
          ELSE
            RAISE DELETE_FAILED;
          END IF;

        END IF;

     END IF;

  END IF; -- Valid Param Check

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.end',
                   'Status='||X_RETURN_STATUS);
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.invparam',
                     'P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

  WHEN CG_NOT_FOUND THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.invdel',
                     'P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_CG_NOT_FOUND');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DELETE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.deletefail',
                     'Delete Row has failed='||l_valid);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_DELETE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN CG_MEMBERS_EXIST THEN
    ROLLBACK TO	Delete_Category_Group_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.memexist',
                     'Members Exist for Cat Grp='||l_member_count);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_DEL_CG');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN CG_FLOWS_EXIST THEN
    ROLLBACK TO	Delete_Category_Group_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.flowexist',
                     'Flows Exist for Cat Grp='||l_flow_count);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_DEL_CG');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Delete_Category_Group_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);

END DELETE_CATEGORY_GROUP;


/*=======================================================================+
 |                      Private Security Apis                            |
 |             *****    Category Group Member    *****                   |
 | - Does_Cat_Group_Member_Exist                                         |
 | - Create_Category_Group_Member                                        |
 | - Delete_Category_Group_Member                                        |
 +=======================================================================*/



-- Start of comments
--	API name 	: DOES_CAT_GROUP_MEMBER_EXIST
--	Type		: Private Function
--	Function	: Validates if a CG Member exists already
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Required
--            P_CATEGORY_ID           NUMBER   Required
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) Validates if a CG Member exists already - ie if the
--     Category Exists or if the Category is included already
--     by a Parent
--  Validations:
--
-- End of comments
FUNCTION DOES_CAT_GROUP_MEMBER_EXIST (
  P_CATEGORY_GROUP_ID NUMBER,
  P_CATEGORY_ID NUMBER
) RETURN VARCHAR2 IS

 CURSOR CHECK_PARENT IS
  SELECT count(m.category_id)
  FROM CS_KB_CAT_GROUP_MEMBERS m
  WHERE m.category_group_id = P_CATEGORY_GROUP_ID
  AND category_id in (
  SELECT b.category_id
  FROM cs_kb_soln_categories_b  b
  START WITH b.category_id = P_CATEGORY_ID
  CONNECT BY PRIOR b.parent_category_id = b.category_id);

  l_count NUMBER;
  l_return VARCHAR2(10) := 'FALSE';

BEGIN
  OPEN  CHECK_PARENT;
  FETCH CHECK_PARENT INTO l_count;
  CLOSE CHECK_PARENT;
  --dbms_output.put_line('count-'||l_count);
  IF l_count = 0 THEN
    l_return := 'FALSE';
  ELSE
    l_return := 'TRUE';
  END IF;
  --dbms_output.put_line('return-'||l_return);
  RETURN l_return;
END DOES_CAT_GROUP_MEMBER_EXIST;



-- Start of comments
--	API name 	: CREATE_CATEGORY_GROUP_MEMBER
--	Type		: Private
--	Function	: Creaye a New Category Group Member
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Required
--            P_CATEGORY_ID           NUMBER   Required
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  15-Aug-03 Matt Kettle added call to CS_KB_SYNC_INDEX_PKG
--                        to request_mark_idx_on_sec_change
--
--
--
--	Notes		:
--  1)
--
--  Validations:
--  1) Required Parameters
--  2) Checks if the Category Group is a Valid Identifier
--  3) Checks if the Category is a Valid Identifier
--  4) Validate that the Record we are trying to insert is not a duplicate
-- End of comments
PROCEDURE CREATE_CATEGORY_GROUP_MEMBER (
  P_CATEGORY_GROUP_ID     IN          NUMBER,
  P_CATEGORY_ID           IN          NUMBER,
  P_ATTRIBUTE_CATEGORY    IN          VARCHAR2,
  P_ATTRIBUTE1            IN          VARCHAR2,
  P_ATTRIBUTE2            IN          VARCHAR2,
  P_ATTRIBUTE3            IN          VARCHAR2,
  P_ATTRIBUTE4            IN          VARCHAR2,
  P_ATTRIBUTE5            IN          VARCHAR2,
  P_ATTRIBUTE6            IN          VARCHAR2,
  P_ATTRIBUTE7            IN          VARCHAR2,
  P_ATTRIBUTE8            IN          VARCHAR2,
  P_ATTRIBUTE9            IN          VARCHAR2,
  P_ATTRIBUTE10           IN          VARCHAR2,
  P_ATTRIBUTE11           IN          VARCHAR2,
  P_ATTRIBUTE12           IN          VARCHAR2,
  P_ATTRIBUTE13           IN          VARCHAR2,
  P_ATTRIBUTE14           IN          VARCHAR2,
  P_ATTRIBUTE15           IN          VARCHAR2,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS

  l_check          NUMBER;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;
  l_rowid          VARCHAR2(30)  := null;
  l_valid_cg       NUMBER;
  l_valid_cat      NUMBER;
  l_request_id     NUMBER;
  l_return_status  VARCHAR2(1);

  CURSOR Check_Insert (v_cg_id NUMBER, v_cat_id NUMBER) IS
   SELECT COUNT(*)
   FROM CS_KB_CAT_GROUP_MEMBERS
   WHERE CATEGORY_GROUP_ID = v_cg_id
   AND   CATEGORY_ID = v_cat_id;

  CURSOR Validate_Category_Group IS
   SELECT count(*)
   FROM CS_KB_CATEGORY_GROUPS_B
   WHERE category_group_id = P_CATEGORY_GROUP_ID;

  CURSOR Validate_Category IS
   SELECT count(*)
   FROM CS_KB_SOLN_CATEGORIES_B
   WHERE category_id = P_CATEGORY_ID;

BEGIN
  --dbms_output.put_line('In api-'||P_CATEGORY_GROUP_ID||' - '||P_CATEGORY_ID);
  SAVEPOINT	Create_Cat_Group_Member_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP_MEMBER.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_CATEGORY_GROUP_ID IS NULL OR
     P_CATEGORY_ID IS NULL THEN
     RAISE INVALID_IN_PARAMETERS;
  ELSE
     --dbms_output.put_line('params passed-');
     -- check valid params
     OPEN  Validate_Category_Group;
     FETCH Validate_Category_Group INTO l_valid_cg;
     CLOSE Validate_Category_Group;

     OPEN  Validate_Category;
     FETCH Validate_Category INTO l_valid_cat;
     CLOSE Validate_Category;

     IF l_valid_cg = 0 OR
        l_valid_cat = 0 THEN
        RAISE INVALID_IN_PARAMETERS;
     ELSE

        -- Validate that the Record we are trying to insert is not a duplicate
        IF (DOES_CAT_GROUP_MEMBER_EXIST(P_CATEGORY_GROUP_ID, P_CATEGORY_ID) = 'TRUE')  THEN
           -- Category Group Member already exists
           RAISE DUP_CATEGORY_GROUP_MEMBER;
        ELSE
           --dbms_output.put_line('before insert-');
           CS_KB_CAT_GROUP_MEMBERS_PKG.INSERT_ROW (
               X_ROWID => l_rowid,
               X_CATEGORY_GROUP_ID => P_CATEGORY_GROUP_ID ,
               X_CATEGORY_ID => P_CATEGORY_ID ,
               X_CREATION_DATE     => l_date,
               X_CREATED_BY        => l_current_user,
               X_LAST_UPDATE_DATE  => l_date,
               X_LAST_UPDATED_BY   => l_current_user,
               X_LAST_UPDATE_LOGIN => l_login,
               X_ATTRIBUTE_CATEGORY => p_attribute_category,
               X_ATTRIBUTE1         => p_attribute1,
               X_ATTRIBUTE2         => p_attribute2,
               X_ATTRIBUTE3         => p_attribute3,
               X_ATTRIBUTE4         => p_attribute4,
               X_ATTRIBUTE5         => p_attribute5,
               X_ATTRIBUTE6         => p_attribute6,
               X_ATTRIBUTE7         => p_attribute7,
               X_ATTRIBUTE8         => p_attribute8,
               X_ATTRIBUTE9         => p_attribute9,
               X_ATTRIBUTE10        => p_attribute10,
               X_ATTRIBUTE11        => p_attribute11,
               X_ATTRIBUTE12        => p_attribute12,
               X_ATTRIBUTE13        => p_attribute13,
               X_ATTRIBUTE14        => p_attribute14,
               X_ATTRIBUTE15        => p_attribute15);

           -- Query DB to check the Insert was Successful
           OPEN  Check_Insert (P_CATEGORY_GROUP_ID, P_CATEGORY_ID);
           FETCH Check_Insert INTO l_check;
           CLOSE Check_Insert;
           --dbms_output.put_line('Insert Check-'||l_check);
           IF l_check <> 1 THEN
              RAISE INSERT_FAILED;
           ELSE

              --> Validate if any children already exist - if yes then remove !!!!
              DELETE FROM CS_KB_CAT_GROUP_MEMBERS
              WHERE CATEGORY_GROUP_ID = P_CATEGORY_GROUP_ID
              AND   CATEGORY_ID IN (SELECT b.category_id
                                    FROM cs_kb_soln_categories_b  b
                                    START WITH b.parent_category_id = P_CATEGORY_ID
                                    CONNECT BY PRIOR b.category_id = b.parent_category_id);


              --dbms_output.put_line('insert success-');

              -- Populate the New Category Member and its children to the Denorm table
              ADD_CAT_GRP_MEMBER_TO_DENORM(P_CATEGORY_GROUP_ID, P_CATEGORY_ID);

              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP_MEMBER.insert',
                               'CG Member Insert Successfull='||P_CATEGORY_GROUP_ID||'-'||P_CATEGORY_ID);
              END IF;

              CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                   ( 'ADD_CAT_TO_CAT_GRP',
                                     P_CATEGORY_GROUP_ID,
                                     P_CATEGORY_ID,
                                     l_request_id,
                                     l_return_status );
              --dbms_output.put_line('sync success-'||l_return_status||l_request_id);


              IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
              ELSE
                RAISE INDEX_SYNC_FAILED;
              END IF;

           END IF; -- Insert Successful Check
        END IF; -- Check Name Dup

     END IF;-- valid params check

  END IF; --Params passed in

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP_MEMBER.end',
                   'Status='||X_RETURN_STATUS);
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN

    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP_MEMBER.invparam',
                     'P_CATEGORY_ID='||P_CATEGORY_ID||
                     '+P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INSERT_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.insertcheck',
                     'Insert Row has failed='||l_check);
    END IF;
    ROLLBACK TO	Create_Cat_Group_Member_PVT;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_CREATE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DUP_CATEGORY_GROUP_MEMBER THEN

    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.dupcheck',
                     'Member already included: P_CATEGORY_ID='||P_CATEGORY_ID||
                     '+P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_CGM_DUP_ERROR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INDEX_SYNC_FAILED THEN
    ROLLBACK TO	Create_Cat_Group_Member_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP.indexsync',
                     'Index Sync failed='||l_request_id);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Create_Cat_Group_Member_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.CREATE_CATEGORY_GROUP_MEMBER.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);

END CREATE_CATEGORY_GROUP_MEMBER;

-- Start of comments
--	API name 	: DELETE_CATEGORY_GROUP_MEMBER
--	Type		: Private
--	Function	: Delete an Existing Category Group Member
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID     NUMBER   Required
--            P_CATEGORY_ID           NUMBER   Required
--
--	OUT		: x_return_status		VARCHAR2(1)
--			  x_msg_count			NUMBER
--			  x_msg_data			VARCHAR2(2000)
--
--	History:
--	07-Jul-03 Matt Kettle   Created
--  15-Aug-03 Matt Kettle added call to CS_KB_SYNC_INDEX_PKG
--                        to request_mark_idx_on_sec_change
--
--
--
--	Notes		:
--  1)
--
--  Validations:
-- End of comments
PROCEDURE DELETE_CATEGORY_GROUP_MEMBER (
  P_CATEGORY_GROUP_ID     IN          NUMBER,
  P_CATEGORY_ID           IN          NUMBER,
  X_RETURN_STATUS         OUT NOCOPY  VARCHAR2,
  X_MSG_DATA              OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT             OUT NOCOPY  NUMBER
) IS


 CURSOR CHECK_DELETE IS
  SELECT count(*)
  FROM CS_KB_CAT_GROUP_MEMBERS
  WHERE category_group_id = P_CATEGORY_GROUP_ID
  AND   category_id = P_CATEGORY_ID;


  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_valid NUMBER;
  l_request_id     NUMBER;
  l_return_status  VARCHAR2(1);

BEGIN
  SAVEPOINT	Delete_Cat_Group_Member_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CAT_GROUP_MEMBER.begin',
                   'User='||l_current_user);
  END IF;

  -- Validate Required Parameters have been passed into api
  IF P_CATEGORY_GROUP_ID is null OR  P_CATEGORY_ID is null THEN
     RAISE INVALID_IN_PARAMETERS;
  ELSE

     OPEN  CHECK_DELETE;
     FETCH CHECK_DELETE INTO l_valid;
     CLOSE CHECK_DELETE;

     IF l_valid <> 0 THEN
        CS_KB_CAT_GROUP_MEMBERS_PKG.DELETE_ROW (X_CATEGORY_GROUP_ID => P_CATEGORY_GROUP_ID,
                                                X_CATEGORY_ID       => P_CATEGORY_ID);

        OPEN  CHECK_DELETE;
        FETCH CHECK_DELETE INTO l_valid;
        CLOSE CHECK_DELETE;
        IF l_valid = 0 THEN
           --Remove FK records for Member + Children from CS_KB_CAT_GROUP_DENORM
           REMOVE_CG_MEMBER_FROM_DENORM ( P_CATEGORY_GROUP_ID, P_CATEGORY_ID);

           --X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           CS_KB_SYNC_INDEX_PKG.request_mark_idx_on_sec_change
                                ( 'REM_CAT_FROM_CAT_GRP',
                                  P_CATEGORY_GROUP_ID,
                                  P_CATEGORY_ID,
                                  l_request_id,
                                  l_return_status );

           IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
           ELSE
             RAISE INDEX_SYNC_FAILED;
           END IF;



        ELSE
           X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
           RAISE DELETE_FAILED;
        END IF;

     ELSE
       -- Else Row already Deleted - ignore and return Successful
       X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
     END IF;

  END IF; -- Valid Param Check

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CAT_GROUP_MEMBER.end',
                   'Status='||X_RETURN_STATUS);
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CAT_GROUP_MEMBER.invparam',
                     'P_CATEGORY_GROUP_ID='||P_CATEGORY_GROUP_ID||
                     ' P_CATEGORY_ID='||P_CATEGORY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN DELETE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CAT_GROUP_MEMBER.deletefail',
                     'Delete Row has failed='||l_valid);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_DELETE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN INDEX_SYNC_FAILED THEN
    ROLLBACK TO	Delete_Cat_Group_Member_PVT;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CAT_GROUP_MEMBER.indexsync',
                     'Index Sync failed='||l_request_id);
    END IF;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Delete_Cat_Group_Member_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.DELETE_CATEGORY_GROUP_MEMBER.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);

END DELETE_CATEGORY_GROUP_MEMBER;

/*=======================================================================+
 |                      Private Security Apis                            |
 |             *****    Maintain  Denorm Table    *****                  |
 | - Add_Cat_Grp_Member_To_Denorm                                        |
 | - Remove_CG_Member_From_Denorm                                        |
 | - Update_Denorm_Vis_Position                                          |
 | - Add_Category_To_Denorm                                              |
 | - Update_Category_To_Denorm                                           |
 | - Remove_Category_From_Cat_Group                                      |
 | - Populate_Cat_Grp_Denorm                                             |
 +=======================================================================*/

-- Start of comments
--	API name 	: ADD_CAT_GRP_MEMBER_TO_DENORM
--	Type		: Private
--	Function	: Populates Denorm Table with new Member + Children
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID       NUMBER  Required
--            P_CATEGORY_ID             NUMBER  Required
--	OUT		:
--
--	History:
--	08-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) For every Category_Id added to the CS_KB_CAT_GROUP_MEMBERS table
--     this api populates the Denorm table with the Member Category_id
--     and all of its Children
--
--  Used By:
--  1) CREATE_CATEGORY_GROUP_MEMBER
-- End of comments
PROCEDURE ADD_CAT_GRP_MEMBER_TO_DENORM ( P_CATEGORY_GROUP_ID NUMBER,
                                         P_CATEGORY_ID       NUMBER
                                        ) IS

 CURSOR GET_CHILD_CATEGORIES IS
  SELECT New_Members.category_id, New_Members.visibility_id, v.position
  FROM (
    SELECT b.category_id, b.visibility_id
    FROM cs_kb_soln_categories_b  b
    START WITH b.parent_category_id = P_CATEGORY_ID
    CONNECT BY PRIOR b.category_id = b.parent_category_id
    UNION
    SELECT b.category_id, b.visibility_id
    FROM cs_kb_soln_categories_b  b
    WHERE b.category_id = P_CATEGORY_ID
  ) New_Members  ,
    CS_KB_VISIBILITIES_b v
  WHERE New_Members.visibility_id = v.visibility_id
  AND NOT EXISTS (SELECT 'x'
                  FROM CS_KB_CAT_GROUP_DENORM Denorm
                  WHERE Denorm.Category_Group_id = P_CATEGORY_GROUP_ID
                  AND Denorm.Child_Category_Id = New_Members.Category_Id);

  --Type NumTabType is VARRAY(10000) of NUMBER;
  Type NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  child_cat_id_list  NumTabType;
  vis_id_list        NumTabType;
  position_list      NumTabType;

  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

BEGIN
  OPEN  GET_CHILD_CATEGORIES;
  FETCH GET_CHILD_CATEGORIES BULK COLLECT INTO child_cat_id_list, vis_id_list, position_list;
  CLOSE GET_CHILD_CATEGORIES;
  --dbms_output.put_line('Before Insert dn-'||P_CATEGORY_GROUP_ID);
  --dbms_output.put_line ('Cat count:'||child_cat_id_list.count );
  --dbms_output.put_line ('Cat count:'||vis_id_list.count );
  --dbms_output.put_line ('Cat count:'||position_list.count );

  FORALL i in 1..child_cat_id_list.count

    INSERT INTO CS_KB_CAT_GROUP_DENORM (
       CATEGORY_GROUP_ID,
       CHILD_CATEGORY_ID,
       VISIBILITY_ID,
       VISIBILITY_POSITION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
    )
    Values (
       P_CATEGORY_GROUP_ID,
       child_cat_id_list(i),
       vis_id_list(i),
       position_list(i),
       l_date,
       l_current_user,
       l_date,
       l_current_user,
       l_login
    );

END ADD_CAT_GRP_MEMBER_TO_DENORM;

-- Start of comments
--	API name 	: REMOVE_CG_MEMBER_FROM_DENORM
--	Type		: Private
--	Function	: Deletes Categories (+Children) from Denorm Table
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_GROUP_ID       NUMBER  Required
--            P_CATEGORY_ID             NUMBER  Required
--	OUT		:
--
--	History:
--	08-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) For every Category_Id deleted from the CS_KB_CAT_GROUP_MEMBERS table
--     this api deleted the corresponding rows in the Denorm table (Member + Children)
--
--  Used By:
--  1) DELETE_CATEGORY_GROUP_MEMBER
-- End of comments
PROCEDURE REMOVE_CG_MEMBER_FROM_DENORM ( P_CATEGORY_GROUP_ID NUMBER,
                                         P_CATEGORY_ID       NUMBER
                                        ) IS

 CURSOR GET_CHILD_CATEGORIES IS
  SELECT b.category_id
  FROM cs_kb_soln_categories_b  b
  START WITH b.parent_category_id = P_CATEGORY_ID
  CONNECT BY PRIOR b.category_id = b.parent_category_id
  UNION
  SELECT b.category_id
  FROM cs_kb_soln_categories_b  b
  WHERE b.category_id = P_CATEGORY_ID;


  --Type NumTabType is VARRAY(10000) of NUMBER;
  Type NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  child_cat_id_list         NumTabType;

BEGIN


 OPEN  GET_CHILD_CATEGORIES;
 FETCH GET_CHILD_CATEGORIES BULK COLLECT INTO child_cat_id_list;
 CLOSE GET_CHILD_CATEGORIES;
 --dbms_output.put_line('Before delete dn-'||P_CATEGORY_GROUP_ID);
 --dbms_output.put_line ('Cat count:'||child_cat_id_list.count );

 FORALL i in 1..child_cat_id_list.count

     DELETE FROM CS_KB_CAT_GROUP_DENORM
     WHERE Category_Group_id = P_CATEGORY_GROUP_ID
     AND Child_Category_Id = child_cat_id_list(i);

END REMOVE_CG_MEMBER_FROM_DENORM;

-- Start of comments
--	API name 	: ADD_CATEGORY_TO_DENORM
--	Type		: Private
--	Function	: Adds new Categories to the Denorm Table
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_ID         NUMBER  Required
--            P_PARENT_CATEGORY_ID  NUMBER  Required
--            P_VISIBILITY_ID       NUMBER  Required
--
--	OUT		: X_RETURN_STATUS       VARCHAR2
--            X_MSG_DATA            VARCHAR2
--            X_MSG_COUNT           NUMBER
--
--	History:
--	08-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) If a New Category is added to CS_KB_SOLN_CATEGORIES_B then this api
--     is used to update the Denorm table with this new Category_Id if
--     any Category Groups already include its parent
--
--  Used By:
--  1) CS_KB_SOLN_CATEGORIES_PVT.createCategory
-- End of comments
PROCEDURE ADD_CATEGORY_TO_DENORM (
  P_CATEGORY_ID        IN NUMBER,
  P_PARENT_CATEGORY_ID IN NUMBER,
  P_VISIBILITY_ID      IN NUMBER,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER
) IS

 CURSOR Validate_Category IS
  SELECT Category_id
  FROM CS_KB_SOLN_CATEGORIES_B
  WHERE Category_id = P_CATEGORY_ID
  AND   Parent_Category_Id = P_PARENT_CATEGORY_ID;

 CURSOR Get_Visibility_Position IS
  SELECT Position
  FROM CS_KB_VISIBILITIES_B
  WHERE Visibility_Id = P_VISIBILITY_ID
  AND  sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                   AND nvl(End_Date_Active, sysdate+1);

 CURSOR GET_GROUPS IS
  SELECT Distinct Category_Group_Id
  FROM CS_KB_CAT_GROUP_DENORM
  WHERE CHILD_CATEGORY_ID = P_PARENT_CATEGORY_ID;

  --Type NumTabType is VARRAY(10000) of NUMBER;
  Type NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  cat_grp_id_list  NumTabType;

  l_cat_valid NUMBER;
  l_position NUMBER;
  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

BEGIN
  SAVEPOINT Add_Cat_To_Denorm_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  -- Validate Category
  OPEN  Validate_Category;
  FETCH Validate_Category INTO l_cat_valid;
  CLOSE Validate_Category;

  IF l_cat_valid IS NOT NULL THEN

    -- Retrieve Position
    OPEN  Get_Visibility_Position;
    FETCH Get_Visibility_Position INTO l_position;
    CLOSE Get_Visibility_Position;

    IF l_position IS NOT NULL THEN
      -- Add Category to Denorm Table where appropriate


      OPEN  Get_Groups;
      FETCH Get_Groups BULK COLLECT INTO cat_grp_id_list;
      CLOSE Get_Groups;

      --FOR x IN Get_Groups LOOP
      FORALL i in 1..cat_grp_id_list.count

        INSERT INTO CS_KB_CAT_GROUP_DENORM
                    ( CATEGORY_GROUP_ID,
                      CHILD_CATEGORY_ID,
                      VISIBILITY_ID,
                      VISIBILITY_POSITION,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN
                     )
             Values ( cat_grp_id_list(i), --x.Category_Group_id,
                      P_CATEGORY_ID,
                      P_VISIBILITY_ID,
                      l_position,
                      l_date,
                      l_current_user,
                      l_date,
                      l_current_user,
                      l_login
                     );
      --END LOOP;

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE
      RAISE INVALID_IN_PARAMETERS;
    END IF;

  ELSE
    RAISE INVALID_IN_PARAMETERS;
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.ADD_CATEGORY_TO_DENORM.invparam',
                     'P_CATEGORY_ID='||P_CATEGORY_ID||
                     'P_PARENT_CATEGORY_ID='||P_PARENT_CATEGORY_ID||
                     'P_VISIBILITY_ID='||P_VISIBILITY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Add_Cat_To_Denorm_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.ADD_CATEGORY_TO_DENORM.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END ADD_CATEGORY_TO_DENORM;

-- Start of comments
--	API name 	: UPDATE_CATEGORY_TO_DENORM
--	Type		: Private
--	Function	: Updates Categories in the Denorm Table
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_ID         NUMBER  Required
--            P_VISIBILITY_ID       NUMBER  Required
--
--	OUT		: X_RETURN_STATUS       VARCHAR2
--            X_MSG_DATA            VARCHAR2
--            X_MSG_COUNT           NUMBER
--
--	History:
--	08-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) This api is required to update the denormalized Visibility
--     information in CS_KB_CAT_GROUP_DENORM if a Categories associated
--     Visibility changes
--
--  Used By:
--  1) CS_KB_SOLN_CATEGORIES_PVT.updateCategory
-- End of comments
PROCEDURE UPDATE_CATEGORY_TO_DENORM (
  P_CATEGORY_ID        IN NUMBER,
  P_VISIBILITY_ID      IN NUMBER,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER
) IS

 CURSOR Validate_Category IS
  SELECT Category_id, Visibility_id
  FROM CS_KB_SOLN_CATEGORIES_B
  WHERE Category_id = P_CATEGORY_ID;

 CURSOR Get_Position IS
  SELECT Position
  FROM CS_KB_VISIBILITIES_B
  WHERE Visibility_id = P_VISIBILITY_ID;

  l_cat_id NUMBER;
  l_vis_id NUMBER;
  l_position NUMBER;

  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

BEGIN
  SAVEPOINT Upd_Cat_To_Denorm_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  OPEN  Validate_Category;
  FETCH Validate_Category INTO l_cat_id, l_vis_id;
  CLOSE Validate_Category;

  IF l_cat_id IS NOT NULL THEN

      OPEN  Get_Position;
      FETCH Get_Position INTO l_position;
      CLOSE Get_Position;

      IF l_position IS NOT NULL THEN

         UPDATE CS_KB_CAT_GROUP_DENORM
         SET Visibility_id = P_VISIBILITY_ID,
             Visibility_Position = l_position,
             Last_Update_Date = l_date,
             Last_Updated_By = l_current_user,
             Last_Update_Login = l_login
         WHERE Child_Category_Id = P_CATEGORY_ID
         AND   Visibility_id <> P_VISIBILITY_ID;

         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      ELSE
        RAISE INVALID_IN_PARAMETERS;
      END IF;

  ELSE
    RAISE INVALID_IN_PARAMETERS;
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_TO_DENORM.invparam',
                     'P_CATEGORY_ID='||P_CATEGORY_ID||
                     'P_VISIBILITY_ID='||P_VISIBILITY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Upd_Cat_To_Denorm_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.UPDATE_CATEGORY_TO_DENORM.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END UPDATE_CATEGORY_TO_DENORM;

-- Start of comments
--	API name 	: REMOVE_CATEGORY_FROM_CAT_GROUP
--	Type		: Private
--	Function	: This removes FK links to a Deleted Category
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_CATEGORY_ID         NUMBER  Required
--
--	OUT		: X_RETURN_STATUS       VARCHAR2
--            X_MSG_DATA            VARCHAR2
--            X_MSG_COUNT           NUMBER
--
--	History:
--	08-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) If a Category is deleted this api will remove the FK links in
--     CS_KB_CAT_GROUP_MEMBERS and CS_KB_CAT_GROUP_DENORM
--
--
--  Used By:
--  1) CS_KB_SOLN_CATEGORIES_PVT.removeCategory
-- End of comments
PROCEDURE REMOVE_CATEGORY_FROM_CAT_GROUP (
  P_CATEGORY_ID        IN NUMBER,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER
) IS

 CURSOR Check_Delete_Member IS
  SELECT count(*)
  FROM CS_KB_CAT_GROUP_MEMBERS
  WHERE Category_id = P_CATEGORY_ID;

 CURSOR Check_Delete_Denorm IS
  SELECT count(*)
  FROM CS_KB_CAT_GROUP_DENORM
  WHERE Child_Category_id = P_CATEGORY_ID;

  l_denorm_count NUMBER;
  l_member_count NUMBER;

BEGIN
  SAVEPOINT Remove_Cat_From_Cat_Grp_PVT;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF P_CATEGORY_ID IS NOT NULL THEN
    -- 1. Removes Category from Members table if the Category Exists
    DELETE FROM CS_KB_CAT_GROUP_MEMBERS
    WHERE Category_Id = P_CATEGORY_ID;
    -- 2. Removes Category from Denorm table if the Category Exists
    DELETE FROM CS_KB_CAT_GROUP_DENORM
    WHERE Child_Category_Id = P_CATEGORY_ID;

    OPEN  Check_Delete_Member;
    FETCH Check_Delete_Member INTO l_member_count;
    CLOSE Check_Delete_Member;

    OPEN  Check_Delete_Denorm;
    FETCH Check_Delete_Denorm INTO l_denorm_count;
    CLOSE Check_Delete_Denorm;

    IF l_member_count = 0 AND l_denorm_count = 0 THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    ELSE
      RAISE DELETE_FAILED;
    END IF;

  ELSE
    RAISE INVALID_IN_PARAMETERS;
  END IF;

EXCEPTION
 WHEN INVALID_IN_PARAMETERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.REMOVE_CATEGORY_FROM_CAT_GROUP.invparam',
                     'P_CATEGORY_ID='||P_CATEGORY_ID);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN DELETE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'cs.plsql.CS_KB_SECURITY_PVT.REMOVE_CATEGORY_FROM_CAT_GROUP.delfail',
                     'Member Count='||l_member_count||
                     'Denorm Count='||l_denorm_count);
    END IF;
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_DELETE_ERR');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    ROLLBACK TO	Remove_Cat_From_Cat_Grp_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.REMOVE_CATEGORY_FROM_CAT_GROUP.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END REMOVE_CATEGORY_FROM_CAT_GROUP;

-- Not Used
FUNCTION POPULATE_CAT_GRP_DENORM (
  P_CATEGORY_GROUP_ID NUMBER
) RETURN VARCHAR2 IS

 CURSOR GET_CHILD_CATEGORIES ( v_cg NUMBER) IS
  SELECT b.category_id, b.visibility_id , v.position
  FROM cs_kb_soln_categories_b  b , CS_KB_VISIBILITIES_b v
  WHERE b.visibility_id = v.visibility_id
  START WITH b.parent_category_id in (select m.category_id
                                      FROM CS_KB_CAT_GROUP_MEMBERS m
                                      where m.category_group_id = v_cg)
  CONNECT BY PRIOR b.category_id = b.parent_category_id
  UNION
  SELECT b.category_id, b.visibility_id, v.position
  FROM cs_kb_soln_categories_b  b, CS_KB_VISIBILITIES_b v
  WHERE b.category_id in (select m.category_id
                          FROM CS_KB_CAT_GROUP_MEMBERS m
                          where m.category_group_id = v_cg)
  AND b.visibility_id = v.visibility_id;

  --Type NumTabType is VARRAY(10000) of NUMBER;
  Type NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  child_cat_id_list         NumTabType;
  vis_id_list         NumTabType;
  position_list       NumTabType;


  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

--  l_count NUMBER :=0;
  l_return VARCHAR2(10) := 'TRUE';

BEGIN
  --dbms_output.put_line('In pop denorm');
  DELETE FROM CS_KB_CAT_GROUP_DENORM
  WHERE category_group_id = P_CATEGORY_GROUP_ID;
  --dbms_output.put_line('After Delete');



  OPEN  GET_CHILD_CATEGORIES (P_CATEGORY_GROUP_ID);
  FETCH GET_CHILD_CATEGORIES BULK COLLECT INTO child_cat_id_list, vis_id_list, position_list;
  CLOSE GET_CHILD_CATEGORIES;
  --dbms_output.put_line('Before Insert dn-'||P_CATEGORY_GROUP_ID);
  --dbms_output.put_line ('Cat count:'||child_cat_id_list.count );
  --dbms_output.put_line ('Cat count:'||vis_id_list.count );
  --dbms_output.put_line ('Cat count:'||position_list.count );

  FORALL i in 1..child_cat_id_list.count --LOOP

     INSERT INTO CS_KB_CAT_GROUP_DENORM (
       CATEGORY_GROUP_ID,
       CHILD_CATEGORY_ID,
       VISIBILITY_ID,
       VISIBILITY_POSITION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
     )
     Values (
       P_CATEGORY_GROUP_ID, --x.category_group_id,
       child_cat_id_list(i),
       vis_id_list(i),
       position_list(i), --x.position --position_list(i) --,
       l_date,
       l_current_user,
       l_date,
       l_current_user,
       l_login
       );

    l_return := 'TRUE';
    --dbms_output.put_line('Return ='||l_return);

  RETURN l_return;

END POPULATE_CAT_GRP_DENORM;

FUNCTION REPOPULATE_CAT_GRP_DENORM
 RETURN VARCHAR2 IS

 CURSOR GET_CHILD_CATEGORIES ( v_cg NUMBER) IS
  SELECT b.category_id, b.visibility_id , v.position
  FROM cs_kb_soln_categories_b  b , CS_KB_VISIBILITIES_b v
  WHERE b.visibility_id = v.visibility_id
  START WITH b.parent_category_id in (select m.category_id
                                      FROM CS_KB_CAT_GROUP_MEMBERS m
                                      where m.category_group_id = v_cg)
  CONNECT BY PRIOR b.category_id = b.parent_category_id
  UNION
  SELECT b.category_id, b.visibility_id, v.position
  FROM cs_kb_soln_categories_b  b, CS_KB_VISIBILITIES_b v
  WHERE b.category_id in (select m.category_id
                          FROM CS_KB_CAT_GROUP_MEMBERS m
                          where m.category_group_id = v_cg)
  AND b.visibility_id = v.visibility_id;

 CURSOR GET_CATEGORY_GROUPS IS
  SELECT Category_Group_Id
  FROM  CS_KB_CATEGORY_GROUPS_B
  WHERE sysdate BETWEEN nvl(start_date_active, sysdate-1)
                    AND nvl(end_date_active, sysdate+1);

  --Type NumTabType is VARRAY(10000) of NUMBER;
  Type NumTabType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  child_cat_id_list         NumTabType;
  vis_id_list         NumTabType;
  position_list       NumTabType;
  child_grp_id_list   NumTabType;

  l_current_user   NUMBER        := FND_GLOBAL.user_id;
  l_date           DATE          := SYSDATE;
  l_login          NUMBER        := FND_GLOBAL.login_id;

--  l_count NUMBER :=0;
  l_return VARCHAR2(10) := 'TRUE';

BEGIN
  --dbms_output.put_line('In pop denorm');
  DELETE FROM CS_KB_CAT_GROUP_DENORM;
  --dbms_output.put_line('After Delete');

  FOR x IN  GET_CATEGORY_GROUPS LOOP


  OPEN  GET_CHILD_CATEGORIES (x.Category_Group_id);
  FETCH GET_CHILD_CATEGORIES BULK COLLECT INTO child_cat_id_list, vis_id_list, position_list;
  CLOSE GET_CHILD_CATEGORIES;
  --dbms_output.put_line('Before Insert dn-'||P_CATEGORY_GROUP_ID);
  --dbms_output.put_line ('Cat count:'||child_cat_id_list.count );
  --dbms_output.put_line ('Cat count:'||vis_id_list.count );
  --dbms_output.put_line ('Cat count:'||position_list.count );

  FORALL i in 1..child_cat_id_list.count --LOOP

     INSERT INTO CS_KB_CAT_GROUP_DENORM (
       CATEGORY_GROUP_ID,
       CHILD_CATEGORY_ID,
       VISIBILITY_ID,
       VISIBILITY_POSITION,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN
     )
     Values (
       x.category_group_id,
       child_cat_id_list(i),
       vis_id_list(i),
       position_list(i), --x.position --position_list(i) --,
       l_date,
       l_current_user,
       l_date,
       l_current_user,
       l_login
       );

  END LOOP;

  l_return := 'TRUE';
  --dbms_output.put_line('Return ='||l_return);

  RETURN l_return;

END REPOPULATE_CAT_GRP_DENORM;



/*=======================================================================+
 |                      Private Security Apis                            |
 |               *****    Utility Functions    *****                     |
 | - Get_Category_Group_id                                               |
 | - Get_Soln_Visibility_Position                                        |
 | - Get_Stmt_Visibility_Position                                        |
 | - Get_Security_Profiles                                               |
 +=======================================================================*/

-- Start of comments
--	API name 	: Get_Category_Group_Id
--	Type		: Private Function
--	Function	: Function to return the Current Users Category Group
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	10-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) The Category Group Id will only be returned if the User has an
--     active (not end-dated) Category Group set in his Profile
--
-- End of comments
FUNCTION Get_Category_Group_Id
 RETURN NUMBER IS

 CURSOR GET_CATEGORY_GROUP IS
  SELECT Category_Group_Id
  FROM CS_KB_CATEGORY_GROUPS_B
  WHERE Category_Group_id = fnd_profile.value('CS_KB_ASSIGNED_CATEGORY_GROUP')
  AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

  id NUMBER ;
BEGIN

 OPEN  GET_CATEGORY_GROUP;
 FETCH GET_CATEGORY_GROUP INTO id;
 CLOSE GET_CATEGORY_GROUP;

 RETURN id;
END Get_Category_Group_Id;

-- Start of comments
--	API name 	: Get_Soln_Visibility_Position
--	Type		: Private Function
--	Function	: Function to return the Current Users Solution Visibility Position
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	10-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) The Solution Visibility Position will only be returned if the User has an
--     active (not end-dated) Visibility set in his Profile
--
-- End of comments
FUNCTION Get_Soln_Visibility_Position
 RETURN NUMBER IS

 CURSOR GET_POSITION IS
  SELECT Position
  FROM CS_KB_VISIBILITIES_B
  WHERE VISIBILITY_ID = fnd_profile.value('CS_KB_ASSIGNED_SOLUTION_VISIBILITY_LEVEL')
  AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

  id number;
BEGIN
  OPEN  GET_POSITION;
  FETCH GET_POSITION INTO id;
  CLOSE GET_POSITION;

  RETURN id;

END Get_Soln_Visibility_Position;

-- Start of comments
--	API name 	: Get_Stmt_Visibility_Position
--	Type		: Private Function
--	Function	: Function to return the Current Users Statement Visibility Position
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	10-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) The Statement Visibility Position will only be returned if the User has an
--     active (not end-dated) Visibility set in his Profile
--
-- End of comments
FUNCTION Get_Stmt_Visibility_Position
 RETURN NUMBER IS

 CURSOR GET_STMT_VISIBILITY IS
  SELECT lookup_code
  FROM cs_lookups
  WHERE lookup_type = 'CS_KB_ACCESS_LEVEL'
  AND  lookup_code = fnd_profile.value('CS_KB_ASSIGNED_STATEMENT_VISIBILITY_LEVEL')
  AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

  id number;
BEGIN

     OPEN  GET_STMT_VISIBILITY;
     FETCH GET_STMT_VISIBILITY INTO id;
     CLOSE GET_STMT_VISIBILITY;

  RETURN id;

END Get_Stmt_Visibility_Position;

-- Start of comments
--	API name 	: GET_SECURITY_PROFILES
--	Type		: Private Function
--	Function	: Api to return all the Security Profiles
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_VISIBILITY_ID       NUMBER  Required
--            P_NAME                VARCHAR Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	10-Jul-03 Matt Kettle   Created
--
--
--
--	Notes		:
--  1) This api returns all the Valid Security Profiles for a User.
--     If any are set incorrectly an Exception will be thrown.
--
-- End of comments
PROCEDURE GET_SECURITY_PROFILES (
  X_CATEGORY_GROUP_ID        OUT NOCOPY NUMBER,
  X_SOLN_VISIBILITY_POSITION OUT NOCOPY NUMBER,
  X_STMT_VISIBILITY_POSITION OUT NOCOPY NUMBER,
  X_RETURN_STATUS            OUT NOCOPY  VARCHAR2,
  X_MSG_DATA                 OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT                OUT NOCOPY  NUMBER
) IS

  l_cat_group_id      NUMBER;
  l_Soln_Vis_Position NUMBER;
  l_Stmt_Vis_Position NUMBER;

BEGIN
 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

 l_cat_group_id := Get_Category_Group_id;

 IF l_cat_group_id is null THEN
   RAISE INV_SEC_CAT_GRP;
 ELSE

   l_Soln_Vis_Position := Get_Soln_Visibility_Position;

   IF l_Soln_Vis_Position is null THEN
     RAISE INV_SEC_SOLN_VIS;
   ELSE

     l_Stmt_Vis_Position := Get_Stmt_Visibility_Position;

     IF l_Stmt_Vis_Position is null THEN
       RAISE INV_SEC_STMT_VIS;
     ELSE
       X_RETURN_STATUS            := FND_API.G_RET_STS_SUCCESS;
       X_CATEGORY_GROUP_ID        := l_cat_group_id;
       X_SOLN_VISIBILITY_POSITION := l_Soln_Vis_Position;
       X_STMT_VISIBILITY_POSITION := l_Stmt_Vis_Position;
     END IF;

   END IF;

 END IF;

EXCEPTION
 WHEN INV_SEC_CAT_GRP THEN
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_SEC_CG');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN INV_SEC_SOLN_VIS THEN
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_SEC_SOL_VIS');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 WHEN INV_SEC_STMT_VIS THEN
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_SEC_STM_VIS');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);

 WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.GET_SECURITY_PROFILES.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);

END GET_SECURITY_PROFILES;

-- Start of comments
--	API name 	: IS_COMPLETE_SOLUTION_VISIBLE
--	Type		: Private Function
--	Function	: Function to determine whether the user can access
--                the complete Solution
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: P_USER_ID       NUMBER  Required
--            P_SET_ID        NUMBER Required
--	OUT		:
--  RETURN  : VARCHAR2 -> either 'TRUE' OR 'FALSE'
--
--	History:
--	16-Jul-03 Matt Kettle   Created
--      15-Sep-03 Matt Kettle   Changed cursor IS_COMPLETE_SOLN_VIEWABLE
--                to pass P_SET_ID to last subquery instead of join. Joined
--                value is currently lost ? DB issue?
--
--
--	Notes		:
--  1)   A 'Complete' Solution is as follows:
--    -------------------------------------
--  --> The Solution is associated to the Users Category Group
--  --> The Category is Visible to the User
--  --> The Solution is within the users Solution Visibility
--  --> The users Statement Visibility allows access to all of the Solutions
--      Statements
--
--  2) If P_USER_ID is passed as -1 then the api will use the current User and
--     Responsibility retrieved from FND_GLOBAL
-- Used By:
-- 1) Sending WF Notifications --> CS_KB_WF_PKG.Start_wf_processing
-- 2) Check-Out button Logic on View Solution -->
-- End of comments
FUNCTION IS_COMPLETE_SOLUTION_VISIBLE ( P_USER_ID  NUMBER,
                                        P_SET_ID   NUMBER) RETURN VARCHAR2 IS

 CURSOR GET_USER_RESPONSIBILITIES IS
  SELECT u.User_id, rg.responsibility_id, rg.responsibility_application_id
  FROM fnd_user_resp_groups rg,
       fnd_user u
  WHERE u.user_id = decode(P_USER_ID, -1, FND_GLOBAL.USER_ID, P_USER_ID)
  AND   u.user_id = rg.user_id
  AND rg.responsibility_id = decode(P_USER_ID, -1, FND_GLOBAL.RESP_ID, rg.responsibility_id)
  AND sysdate between nvl(rg.start_date, sysdate) and nvl(rg.end_date, sysdate);

 CURSOR GET_USER_SECURITY_PROFILES (v_user NUMBER, v_resp NUMBER, v_app NUMBER) IS
  SELECT TO_NUMBER(FND_PROFILE.VALUE_SPECIFIC('CS_KB_ASSIGNED_CATEGORY_GROUP',
                                              v_user,
                                              v_resp,
                                               v_app ) ),
         TO_NUMBER(FND_PROFILE.VALUE_SPECIFIC('CS_KB_ASSIGNED_SOLUTION_VISIBILITY_LEVEL',
                                              v_user,
                                              v_resp,
                                              v_app ) ),
         TO_NUMBER(FND_PROFILE.VALUE_SPECIFIC('CS_KB_ASSIGNED_STATEMENT_VISIBILITY_LEVEL',
                                              v_user,
                                              v_resp,
                                              v_app  ))
  FROM dual;

 CURSOR IS_COMPLETE_SOLN_VIEWABLE (v_cat_grp  NUMBER,
                                   v_soln_vis NUMBER) IS
                                   --v_stmt_vis NUMBER) IS
  SELECT count(*)
  FROM CS_KB_SETS_B S,
       CS_KB_VISIBILITIES_B V
  WHERE S.Set_Id = P_SET_ID
  AND   S.Visibility_id = V.Visibility_id
  AND   V.Position >= (SELECT Vis.Position
                       FROM CS_KB_VISIBILITIES_B Vis
                       WHere Vis.Visibility_id = v_soln_vis
                       AND   sysdate BETWEEN nvl(Vis.Start_Date_Active, sysdate-1)
                                         AND nvl(Vis.End_Date_Active  , sysdate+1)
                       )
  AND EXISTS (SELECT 'x'
              FROM CS_KB_SET_CATEGORIES SC,
                   CS_KB_CAT_GROUP_DENORM D
              WHERE SC.Set_id = S.Set_id
              AND   D.Category_Group_Id = v_cat_grp
              AND   SC.Category_id = D.Child_Category_id
              AND   D.Visibility_Position >= (SELECT Vis.Position
                                              FROM CS_KB_VISIBILITIES_B Vis
                                              WHERE Vis.Visibility_id = v_soln_vis
                                              AND sysdate BETWEEN nvl(Vis.Start_Date_Active, sysdate-1)
                                                              AND nvl(Vis.End_Date_Active  , sysdate+1)
                                              )

              );
-- 02-Dec-2003 Commented as sql not 8.1.7 compliant
--  AND (SELECT count(*) FROM CS_KB_SET_ELES SE WHERE SE.Set_id = S.Set_Id) =
--      (SELECT count(*)
--       FROM CS_KB_SET_ELES SE,
--            CS_KB_ELEMENTS_B E
--       WHERE SE.Set_id = P_SET_ID --S.Set_Id
--       AND   SE.Element_id = E.Element_Id
--       AND   E.Access_Level >= (SELECT lookup_code
--                                FROM cs_lookups
--                                WHERE lookup_type = 'CS_KB_ACCESS_LEVEL'
--                                AND  lookup_code = v_stmt_vis
--                                AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
--                                                AND nvl(End_Date_Active, sysdate+1)
--                                )
--      );

 CURSOR Get_Total_Soln_Statements IS
  SELECT count(*)
  FROM CS_KB_SET_ELES SE
  WHERE SE.Set_id = P_SET_ID;

 CURSOR Get_Total_Visible_Statements ( v_stmt_vis NUMBER) IS
  SELECT count(*)
  FROM CS_KB_SET_ELES SE,
       CS_KB_ELEMENTS_B E
  WHERE SE.Set_id = P_SET_ID --S.Set_Id
  AND   SE.Element_id = E.Element_Id
  AND   E.Access_Level >= (SELECT lookup_code
                           FROM cs_lookups
                           WHERE lookup_type = 'CS_KB_ACCESS_LEVEL'
                           AND  lookup_code = v_stmt_vis
                           AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                                           AND nvl(End_Date_Active, sysdate+1)
                           );

 l_cat_grp  NUMBER;
 l_soln_vis NUMBER;
 l_stmt_vis NUMBER;
 l_solution_count NUMBER;
 l_viewable VARCHAR2(10) := 'FALSE';
 l_stmt_count NUMBER;
 l_vis_stmt_count NUMBER;

BEGIN

  -- Firstly retrieve the Users Responsibilities
  FOR UserResps IN Get_User_Responsibilities LOOP

    -- Retrieve the Security Profiles for the User
    OPEN  Get_User_Security_Profiles (UserResps.User_id,
                                      UserResps.Responsibility_Id,
                                      UserResps.Responsibility_Application_id);
    FETCH Get_User_Security_Profiles INTO l_cat_grp, l_soln_vis, l_stmt_vis;
    CLOSE Get_User_Security_Profiles;

    --dbms_output.put_line('Profs->>>   '||l_cat_grp||'<-->'||l_soln_vis||'<-->'||l_stmt_vis);

    -- Call api to check complete Solution is Viewable by the User
    OPEN  IS_COMPLETE_SOLN_VIEWABLE (l_cat_grp, l_soln_vis); --, l_stmt_vis);
    FETCH IS_COMPLETE_SOLN_VIEWABLE INTO l_solution_count;
    CLOSE IS_COMPLETE_SOLN_VIEWABLE;

    OPEN  Get_Total_Soln_Statements;
    FETCH Get_Total_Soln_Statements INTO l_stmt_count;
    CLOSE Get_Total_Soln_Statements;

    OPEN  Get_Total_Visible_Statements (l_stmt_vis);
    FETCH Get_Total_Visible_Statements INTO l_vis_stmt_count;
    CLOSE Get_Total_Visible_Statements;



    --dbms_output.put_line('Solution Count: '||l_solution_count);
    -- If the Solution is Viewable return TRUE
    IF l_solution_count <> 0 AND
       l_stmt_count = l_vis_stmt_count THEN
      l_viewable := 'TRUE';
      EXIT;
    END IF;

  END LOOP;

RETURN l_viewable;

END IS_COMPLETE_SOLUTION_VISIBLE;

PROCEDURE MOVE_CATEGORY_IN_DENORM (
  P_CATEGORY_ID        IN NUMBER,
  X_RETURN_STATUS      OUT NOCOPY  VARCHAR2,
  X_MSG_DATA           OUT NOCOPY  VARCHAR2,
  X_MSG_COUNT          OUT NOCOPY  NUMBER
) IS


 CURSOR Get_Moved_Categories IS
  SELECT c.category_id, c.parent_category_id, c.visibility_id
  FROM CS_KB_SOLN_CATEGORIES_B c
  START WITH  c.category_id = P_CATEGORY_ID
  CONNECT BY PRIOR c.category_id = c.parent_category_id
  ORDER BY level asc;

 l_ret_status  VARCHAR2(1);
 l_msg_data    VARCHAR2(2000);
 l_msg_count   NUMBER;

BEGIN

  SAVEPOINT Move_Cat_In_Denorm_PVT;

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;


  -- Firstly Delete all the Records in the Denorm Table For the Moved
  -- Catageory and its Children except where this Category has been directly
  -- associated to a Category Group (via a link in CS_KB_CAT_GROUP_MEMBERS)
  DELETE FROM cs_kb_cat_group_denorm d
  WHERE d.child_category_id IN (SELECT b.category_id
                                FROM cs_kb_soln_categories_b b
                                START WITH  b.category_id = P_CATEGORY_ID
                                CONNECT BY PRIOR b.category_id =
b.parent_category_id)

  AND NOT EXISTS (SELECT 'x'
                  FROM cs_kb_cat_group_members  m
                  WHERE m.category_id IN ( SELECT b.category_id
                                           FROM cs_kb_soln_categories_b b
                                           START WITH  b.category_id =
P_CATEGORY_ID
                                           CONNECT BY PRIOR
b.category_id = b.parent_category_id)
  AND m.category_id = d.child_category_id
  AND m.category_group_id = d.category_group_id );


  -- Validate Category

  FOR x IN Get_Moved_Categories LOOP


    ADD_CATEGORY_TO_DENORM ( P_CATEGORY_ID        => x.category_id,
                             P_PARENT_CATEGORY_ID => x.parent_category_id,
                             P_VISIBILITY_ID      => x.visibility_id,
                             X_RETURN_STATUS      => l_ret_status,
                             X_MSG_DATA           => l_msg_data,
                             X_MSG_COUNT          => l_msg_count );

    IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE UPDATE_FAILED;
    END IF;

  END LOOP;

X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
 WHEN UPDATE_FAILED THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
'cs.plsql.CS_KB_SECURITY_PVT.MOVE_CAT_IN_DENORM.update',
                     'P_CATEGORY_ID='||P_CATEGORY_ID --||
                     --'P_PARENT_CATEGORY_ID='||P_PARENT_CATEGORY_ID||
                     --'P_VISIBILITY_ID='||P_VISIBILITY_ID
                     );
    END IF;
    ROLLBACK TO    Move_Cat_In_Denorm_PVT;
    X_RETURN_STATUS := l_ret_status;
    X_MSG_COUNT := l_msg_count;
    X_MSG_DATA  := l_msg_data;

 WHEN OTHERS THEN
    ROLLBACK TO    Move_Cat_In_Denorm_PVT;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KB_SECURITY_PVT.MOVE_CATEGORY_IN_DENORM.UNEXPECTED',
                     ' Error= '||sqlerrm);
    END IF;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
END MOVE_CATEGORY_IN_DENORM;

END CS_KB_SECURITY_PVT;

/
