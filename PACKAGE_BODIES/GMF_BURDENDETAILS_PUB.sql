--------------------------------------------------------
--  DDL for Package Body GMF_BURDENDETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_BURDENDETAILS_PUB" AS
/* $Header: GMFPBRDB.pls 120.5.12010000.2 2008/10/30 21:18:26 pkanetka ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPBRDB.pls                                        |
--| Package Name       : GMF_BurdenDetails_PUB                               |
--| API name           : GMF_BurdenDetails_PUB                               |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : Burden Details creation, updatation and deletion.   |
--|                                                                          |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 2.0                                                 |
--| Previous Vers      : 1.0                                                 |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Contents                                                                 |
--|     Create_Burden_Details                                                |
--|     Update_Burden_Details                                                |
--|     Delete_Burden_Details                                                |
--|     Get_Item_Cost                                                        |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Burden Details   |
--|     creation, updatation and deletetion.                                 |
--|                                                                          |
--|                                                                          |
--|  Pre-defined API message levels                                          |
--|                                                                          |
--|     Valid values for message levels are from 1-50.                       |
--|      1 being least severe and 50 highest.                                |
--|                                                                          |
--|     The pre-defined levels correspond to standard API                    |
--|     return status. Debug levels are used to control the amount of        |
--|      debug information a program writes to the PL/SQL message table.     |
--|                                                                          |
--| G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;                           |
--| G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;                           |
--| G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;                           |
--| G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;                           |
--| G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;                           |
--| G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;                           |
--| HISTORY                                                                  |
--|    10/Apr/2001  Uday Moogala  Created  Bug# 1418689                      |
--|    13/Aug/2001  Uday Moogala  Bug# 1935297                               |
--|                 UOM conversion fails even in case of same UOMs. This is  |
--|                 happenning since item id is not getting passed to the    |
--|                 UOM conversion routine. And this happens only when Item  |
--|                 No is passed instead of Item_Id. Fix is done to pass the |
--|                 Item_Id to UOM conversion routine.                       |
--|                                                                          |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes.                                          |
--|      1. remove G_MISS_xxx assignments.                                   |
--|      2. Conditionally calling debug routine.                             |
--|      Also, fixed issues found during unit testing. Search for the bug    |
--|      number to find the fixes.                                           |
--|    30/Oct/2002  R.Sharath Kumar Bug# 2641405 Added NOCOPY hint           |
--|    21/NOV/2002  Uday Moogala  Bug# 2681243                               |
--|      1. Return value of GMA_GLOBAL_GRP.set_who has changed to -1 from 0  |
--|         in case of invalid users.                                        |
--|      2. Removed "when others" section in validate_input_params           |
--|      3. Also made changes to query brdn details from db to use for UOM   |
--|         conversions, if not passed in case of update only                |
--|    12/May/2004 Dinesh Vadivel Bug# 3314310                               |
--|                Removed Validation code for the item BURDEN_USAGE in      |
--|                VALIDATE_INPUT_PARAMS proc so that it takes negative      |
--|                values                                                    |
--|   20-Oct-2005  Prasad marada, Bug 4689137 Modified as per convergence    |
--+==========================================================================+
-- End of comments


PROCEDURE Validate_Input_Params
(
 p_header_rec      IN  Burden_Header_Rec_Type
,p_dtl_tbl         IN  Burden_Dtl_Tbl_Type
,p_operation       IN  VARCHAR2
,x_header_rec      OUT NOCOPY Burden_Header_Rec_Type
,x_dtl_tbl         OUT NOCOPY Burden_Dtl_Tbl_Type
,x_user_id         OUT NOCOPY fnd_user.user_id%TYPE
,x_brdn_factor_tbl OUT NOCOPY GMF_BurdenDetails_PVT.Burden_factor_Tbl_Type
,x_return_status   OUT NOCOPY VARCHAR2
) ;
--
PROCEDURE log_msg       -- Bug 2659435: Removed first param for debug level
(
 p_msg_text      IN VARCHAR2
);
--
-- Bug 2659435: Added new procedure to log header message
PROCEDURE add_header_to_error_stack
(
 p_header       Burden_Header_Rec_Type
);
--

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMF_BurdenDetails_PUB';

-- Bug 2659435
G_tmp           BOOLEAN := FND_MSG_PUB.Check_Msg_Level(0) ; -- temp call to initialize the
                                                            -- msg level threshhold gobal
                                                            -- variable.
G_debug_level   NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
                                                                 -- to decide to log a debug msg.
G_header_logged VARCHAR2(1);  -- to indicate whether header is already in
                              -- error stack or not - avoid logging duplicate headers


--Start of comments
--+========================================================================+
--| API Name    : Create_Burden_Details                                    |
--| TYPE        : Public                                                   |
--| Function    : Creates a new Burden Details based on the input into table|
--|               CM_CMPT_DTL                                              |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--|               p_dtl_tbl             IN  Burden_Dtl_Tbl_Type            |
--|               p_user_id             IN  NUMBER                         |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|               x_burdenline_ids   OUT Burdenline_Ids_Tbl_Type           |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Create_Burden_Details
(
  p_api_version                 IN  NUMBER                      ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  Burden_Header_Rec_Type      ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type         ,

  x_burdenline_ids              OUT NOCOPY Burdenline_Ids_Tbl_Type
)
IS

        l_api_name              CONSTANT VARCHAR2(30)   := 'Create_Burden_Details' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_header_rec            Burden_Header_Rec_Type ;
        l_dtl_tbl               Burden_Dtl_Tbl_Type ;
        l_brdn_factor_tbl       GMF_BurdenDetails_PVT.Burden_factor_Tbl_Type ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_return_status         VARCHAR2(2) ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Create_Burden_Details_PUB ;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Beginning Create Burden details process.');
    END IF;

    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('In public API. # of Detail records : ' || p_dtl_tbl.count);
    END IF;

    IF p_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Validating  input parameters');
      END IF;
      -- Validate all the input parameters.
      Validate_Input_Params
       (
        p_header_rec      => p_header_rec
       ,p_dtl_tbl         => p_dtl_tbl
       ,p_operation       => 'INSERT'
       ,x_header_rec      => l_header_rec
       ,x_dtl_tbl         => l_dtl_tbl
       ,x_user_id         => l_user_id
       ,x_brdn_factor_tbl => l_brdn_factor_tbl
       ,x_return_status   => l_return_status
       ) ;

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2681243
        log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      -- Return if validation failures detected
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Calling private API to insert record...');
      END IF;
      GMF_BurdenDetails_PVT.Create_Burden_Details
        (
          p_api_version         => 2.0
        , p_init_msg_list       => FND_API.G_FALSE
        , p_commit              => FND_API.G_FALSE

        , x_return_status       => l_return_status
        , x_msg_count           => l_count
        , x_msg_data            => l_data

        , p_header_rec          => l_header_rec
        , p_dtl_tbl             => l_dtl_tbl
        , p_user_id             => l_user_id
        , p_burden_factor_tbl   => l_brdn_factor_tbl

        , x_burdenline_ids      => x_burdenline_ids
      );

      -- Return if insert fails for any reason
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      add_header_to_error_stack(l_header_rec); -- Bug 2659435
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_INS');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',x_burdenline_ids.count);
      FND_MSG_PUB.Add;
    ELSE
      add_header_to_error_stack(p_header_rec); -- Bug 2659435
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
      FND_MSG_PUB.Add;
    END IF ;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Create_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Create_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Create_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME      ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );

END Create_Burden_Details;


--Start of comments
--+========================================================================+
--| API Name    : Update_Burden_Details                                    |
--| TYPE        : Public                                                   |
--| Function    : Updates Burden Details based on the input in CM_BRDN_DTL |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--|               p_dtl_tbl             IN  Burden_Dtl_Tbl_Type            |
--|               p_user_id             IN  NUMBER                         |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 10-Apr-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Update_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  Burden_Header_Rec_Type      ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Update_Burden_Details' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_header_rec            Burden_Header_Rec_Type ;
        l_dtl_tbl               Burden_Dtl_Tbl_Type ;
        l_brdn_factor_tbl       GMF_BurdenDetails_PVT.Burden_factor_Tbl_Type ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_return_status         VARCHAR2(2) ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;
        l_no_rows_upd           NUMBER(10) ;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT    Update_Burden_Details_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Beginning Update Burden Details Definition process.');
    END IF;

    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('In public API. # of detail records : ' || p_dtl_tbl.count);
    END IF;

    IF p_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Validating  input parameters');
      END IF;
      -- Validate all the input parameters.
      Validate_Input_Params
       (
        p_header_rec      => p_header_rec
       ,p_dtl_tbl         => p_dtl_tbl
       ,p_operation       => 'UPDATE'
       ,x_header_rec      => l_header_rec
       ,x_dtl_tbl         => l_dtl_tbl
       ,x_user_id         => l_user_id
       ,x_brdn_factor_tbl => l_brdn_factor_tbl
       ,x_return_status   => l_return_status
       ) ;

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2681243
        log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      -- Return if validation failures detected
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Calling private API to update records...');
      END IF;
      GMF_BurdenDetails_PVT.Update_Burden_Details
        (
          p_api_version         => 2.0
        , p_init_msg_list       => FND_API.G_FALSE
        , p_commit              => FND_API.G_FALSE

        , x_return_status       => l_return_status
        , x_msg_count           => l_count
        , x_msg_data            => l_data

        , p_header_rec          => l_header_rec
        , p_dtl_tbl             => l_dtl_tbl
        , p_user_id             => l_user_id
        , p_burden_factor_tbl   => l_brdn_factor_tbl
      );

      -- Return if update fails for any reason
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      add_header_to_error_stack(l_header_rec); -- Bug 2659435
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_UPD');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_dtl_tbl.count);
      FND_MSG_PUB.Add;

    ELSE
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
      add_header_to_error_stack(p_header_rec); -- Bug 2659435
      FND_MSG_PUB.Add;
    END IF ;
    --log_msg( l_no_rows_upd  || ' rows updated.');


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Update_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME      ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );

END Update_Burden_Details ;


--Start of comments
--+========================================================================+
--| API Name    : Delete_Burden_Details                                    |
--| TYPE        : Public                                                   |
--| Function    : Deletes Burden Details based on the input from CM_BRDN_DTL|
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--|               p_dtl_tbl             IN  Burden_Dtl_Tbl_Type            |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 10-Apr-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Delete_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  Burden_Header_Rec_Type      ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Delete_Burden_Details' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_header_rec            Burden_Header_Rec_Type ;
        l_dtl_tbl               Burden_Dtl_Tbl_Type ;
        l_brdn_factor_tbl       GMF_BurdenDetails_PVT.Burden_factor_Tbl_Type ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_return_status         VARCHAR2(2) ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;
        l_no_rows_del           NUMBER(10) ;
        -- l_user_name             fnd_user.user_name%TYPE := FND_API.G_MISS_CHAR ; Bug 2659435

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Delete_Burden_Details_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Beginning Delete Burden Details process.');
    END IF;

    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('In public API. # of detail records : ' || p_dtl_tbl.count);
    END IF;

    IF p_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Validating  input parameters');
      END IF;

      -- Validate all the input parameters.
      Validate_Input_Params
       (
        p_header_rec      => p_header_rec
       ,p_dtl_tbl         => p_dtl_tbl
       ,p_operation       => 'DELETE'
       ,x_header_rec      => l_header_rec
       ,x_dtl_tbl         => l_dtl_tbl
       ,x_user_id         => l_user_id
       ,x_brdn_factor_tbl => l_brdn_factor_tbl
       ,x_return_status   => l_return_status
       ) ;

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2681243
        log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      -- Return if validation failures detected
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF l_dtl_tbl.count > 0 THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN  -- Bug 2659435
        log_msg('Calling private API to delete records...');
      END IF;

      GMF_BurdenDetails_PVT.Update_Burden_Details
        (
          p_api_version         => 2.0
        , p_init_msg_list       => FND_API.G_FALSE
        , p_commit              => FND_API.G_FALSE

        , x_return_status       => l_return_status
        , x_msg_count           => l_count
        , x_msg_data            => l_data

        , p_header_rec          => l_header_rec
        , p_dtl_tbl             => l_dtl_tbl
        , p_user_id             => l_user_id
        , p_burden_factor_tbl   => l_brdn_factor_tbl
      );

      -- Return if update fails for any reason
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(l_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      add_header_to_error_stack(l_header_rec); -- Bug 2659435
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_DEL');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_dtl_tbl.count);
      FND_MSG_PUB.Add;

    ELSE
      add_header_to_error_stack(l_header_rec); -- Bug 2659435
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
      FND_MSG_PUB.Add;
    END IF ;

    --log_msg(l_no_rows_del || ' rows deleted.');

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Delete_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Delete_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Delete_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME      ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );

END Delete_Burden_Details ;

--Start of comments
--+========================================================================+
--| API Name    : Get_Burden_Details                                       |
--| TYPE        : Public                                                   |
--| Function    : Retrieve Burden Details based on the input from CM_BRDN_DTL|
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Burden_Header_Rec_Type         |
--| OUT         :                                                          |
--|               x_return_status    OUT VARCHAR2                          |
--|               x_msg_count        OUT NUMBER                            |
--|               x_msg_data         OUT VARCHAR2                          |
--|               x_dtl_tbl          OUT Burden_Dtl_Tbl_Type               |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 26-Apr-01     Uday Moogala - Created                                   |
--| 20-Oct-2005  Prasad marada, Bug 4689137 Modified the record type as    |
--|                             per inventory convergence                  |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE Get_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                    ,
  x_msg_count                   OUT NOCOPY VARCHAR2                    ,
  x_msg_data                    OUT NOCOPY VARCHAR2                    ,

  p_header_rec                  IN  Burden_Header_Rec_Type      ,

  x_dtl_tbl                     OUT NOCOPY Burden_Dtl_Tbl_Type
)
IS
        l_api_name              CONSTANT VARCHAR2(30)   := 'Get_Burden_Details' ;
        l_api_version           CONSTANT NUMBER         := 2.0 ;

        l_return_status         VARCHAR2(2) ;
        l_count                 NUMBER(10) ;
        l_data                  VARCHAR2(2000) ;

        l_header_rec            Burden_Header_Rec_Type ;
        l_act_item_uom          cm_brdn_dtl.item_uom%TYPE ;
        l_period_status         cm_cldr_dtl.period_status%TYPE ;
        l_user_id               fnd_user.user_id%TYPE ;
        l_lc_cost_type_id       cm_mthd_mst.cost_type_id%TYPE;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT    Get_Burden_Details_PUB;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( l_api_version          ,
                                         p_api_version          ,
                                         l_api_name             ,
                                         G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg('Beginning Get Burden Details process.');
    END IF;

    G_header_logged := 'N';     -- to avoid logging duplicate header for errors

    /* Validating Header Record */
    --------------------------
    -- organization validation
    --------------------------
    -- If organization id is sent then use organization id else
    -- use organization code
    -- organization id
    IF (p_header_rec.organization_id <> FND_API.G_MISS_NUM) AND
       (p_header_rec.organization_id IS NOT NULL)  THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
           log_msg('validating organization_id : ' || p_header_rec.organization_id);
        END IF;
        IF NOT GMF_VALIDATIONS_PVT.Validate_organization_id(p_header_rec.organization_id)
        THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
          -- Log message to ignore if organization_Code is also passed
        IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND
           (p_header_rec.organization_code IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
                FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
                FND_MSG_PUB.Add;
          END IF;
        END IF;
          -- organization code
    ELSIF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND
       (p_header_rec.organization_code IS NOT NULL)  THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN -- Bug 2659435
           log_msg('validating organization_code : ' || p_header_rec.organization_code);
        END IF;

        l_header_rec.organization_id := GMF_VALIDATIONS_PVT.Validate_organization_Code(p_header_rec.organization_code);
        IF l_header_rec.organization_id IS NULL THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5589409, pmarada
             log_msg('Organization Id : ' || l_header_rec.organization_id );
          END IF;
        END IF;
    ELSE
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End organization validation
    --
    ------------------------
    -- Item Validation
    ------------------------
    -- Use inventory item_id if sent otherwise use item_number
    -- If both are sent then use only item_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --
    IF (p_header_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (p_header_rec.inventory_item_id IS NOT NULL)  THEN
        -- validate inventory_item_id
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('validating inventory_item_id : ' || p_header_rec.inventory_item_id);
        END IF;

        IF NOT (GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(p_header_rec.inventory_item_id, p_header_rec.organization_id))
        THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
          FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.inventory_item_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Log message if item_number is also passed
        IF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND
           (p_header_rec.item_number IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
                FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
                FND_MSG_PUB.Add;
          END IF;
        END IF;
    ELSIF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND
          (p_header_rec.item_number IS NOT NULL)  THEN
        -- Convert item number value into item ID.
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
           log_msg('validating item_number : ' || p_header_rec.item_number);
        END IF;
          -- If Organization id is passed as null then assign the derived organization id
        l_header_rec.organization_id := nvl(p_header_rec.organization_id,l_header_rec.organization_id) ;
        l_header_rec.inventory_item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(p_header_rec.item_number,l_header_rec.organization_id);

        IF l_header_rec.inventory_item_id IS NULL THEN       -- item_Id fetch was not successful
          -- Conversion failed.
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_header_rec.organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
             log_msg('inventory_item_id : ' || l_header_rec.inventory_item_id );
          END IF;
        END IF;
    ELSE
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Item validation


    ------------------------
    -- Cost Method Code
    ------------------------
    IF (p_header_rec.cost_type_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.cost_type_id IS NOT NULL)
    THEN
      IF (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level)
      THEN
     	log_msg('Validating Cost type Id : ' || p_header_rec.cost_type_id);
      END IF;
       -- cost type id should be standard or actual cost type because this API is for Standard and actual cost
       -- overheads only. So Call Validate_Lot_Cost_type_id to verify the cost type is lot cost type or not.
       -- If it is lot cost type id then log error message as invalid cost type
      IF GMF_VALIDATIONS_PVT.Validate_Lot_Cost_type_id(p_header_rec.cost_type_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
       -- log a message to ignore if cost method code also passed
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.cost_mthd_code IS NOT NULL) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)   THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
            FND_MESSAGE.SET_TOKEN('COST_TYPE', p_header_rec.cost_mthd_code);
            FND_MSG_PUB.Add;
          END IF;
      END IF;
       -- if cost type method code passed
    ELSE
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
        IF (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level)  THEN
          log_msg('Validating Cost type : ' || p_header_rec.cost_mthd_code);
        END IF;
          -- call validate lot cost type
         l_header_rec.cost_Type_id := GMF_VALIDATIONS_PVT.Validate_Cost_type_Code(p_header_rec.cost_mthd_code);
          -- Call validate lot cost type to check lot cost type, if it is lot cost type then log error
          -- because overheads will be created for actual and standard costs
         l_lc_cost_type_id := GMF_VALIDATIONS_PVT.Validate_Lot_Cost_Type(p_header_rec.cost_mthd_code);
         --If cost type id is null or cost type is lot cost type then log invalid cost type message
         IF (l_header_rec.cost_Type_id IS NULL)
            OR (l_lc_cost_type_id IS NOT NULL ) THEN
           add_header_to_error_stack(p_header_rec);
           FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
           FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         ELSE
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
              log_msg('Cost_Type_id : ' || l_header_rec.cost_Type_id );
           END IF;
         END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- End Cost Method Code

    ------------------------
    -- Period Id validation
    ------------------------
    IF (p_header_rec.period_id <> FND_API.G_MISS_NUM) AND (p_header_rec.period_id IS NOT NULL)
    THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
       THEN
        log_msg('validating Period Id : ' || p_header_rec.period_id);
       END IF;
       IF NOT GMF_VALIDATIONS_PVT.Validate_period_id(p_header_rec.period_id)
       THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
       -- If period code also passed then ignore period code
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
         AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL)) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
           FND_MESSAGE.SET_TOKEN('CALENDAR_CODE', p_header_rec.calendar_code);
           FND_MESSAGE.SET_TOKEN('PERIOD_CODE', p_header_rec.period_code);
           FND_MSG_PUB.Add;
         END IF;
      END IF;
      -- period code and calendar code are passed instead of period id
    ELSE
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
         THEN
            log_msg('Validating Calendar Code : '|| p_header_rec.Calendar_code||' period_code : ' || p_header_rec.period_code);
         END IF;
        -- if cost type id passed as null then  assign derived cost type id to the record
        -- and pass the derived cost type id for derving to period id
        l_header_rec.cost_type_id    := nvl(p_header_rec.cost_type_id,l_header_rec.cost_type_id) ;
        l_header_rec.organization_id := nvl(p_header_rec.organization_id,l_header_rec.organization_id) ;
         -- get the period id value
        l_header_rec.period_id := GMF_VALIDATIONS_PVT.Validate_period_code(l_header_rec.organization_id, p_header_rec.calendar_code,p_header_rec.period_code,l_header_rec.cost_type_id );
        -- if derived period id is null then log a message
        IF l_header_rec.period_id IS NULL THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CLDR_PERIOD');
          FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header_rec.calendar_code);
          FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header_rec.period_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
             log_msg('period_id : ' || l_header_rec.period_id );
          END IF;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_PERIOD_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Note: period Code
    -- No need to bother about Frozen and Closed Periods. Screen allows insert
    -- and updates even of period is Frozen and Closed.
    --
    ------------------------
    -- Populate WHO columns
    ------------------------
    IF (p_header_rec.user_name <> FND_API.G_MISS_CHAR) AND
       (p_header_rec.user_name IS NOT NULL)  THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
          log_msg('Validating user name : ' || p_header_rec.user_name);
       END IF;
            GMA_GLOBAL_GRP.Get_who( p_user_name  => p_header_rec.user_name
                                  , x_user_id    => l_user_id
                                  );

            IF l_user_id = -1 THEN      -- Bug 2681243: GMA changed return status value to -1.
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
                FND_MESSAGE.SET_TOKEN('USER_NAME',p_header_rec.user_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

    ELSE
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End User Name
    l_header_rec.organization_id   := nvl(p_header_rec.organization_id,l_header_rec.organization_id) ;
    l_header_rec.organization_code := p_header_rec.organization_code ;
    l_header_rec.inventory_item_id := nvl(p_header_rec.inventory_item_id,l_header_rec.inventory_item_id) ;
    l_header_rec.item_number       := p_header_rec.item_number ;
    l_header_rec.period_id         := nvl(p_header_rec.period_id,l_header_rec.period_id) ;
    l_header_rec.calendar_code     := p_header_rec.calendar_code ;
    l_header_rec.period_code       := p_header_rec.period_code ;
    l_header_rec.cost_type_id      := nvl(p_header_rec.cost_type_id,l_header_rec.cost_type_id) ;
    l_header_rec.cost_mthd_code    := p_header_rec.cost_mthd_code ;
    l_header_rec.user_name         := p_header_rec.user_name ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg( 'organization_id : '   || l_header_rec.organization_id ) ;
        log_msg( 'organization_code : ' || l_header_rec.organization_code ) ;
        log_msg( 'inventory_item_id : ' || l_header_rec.inventory_item_id ) ;
        log_msg( 'item_number : '   || l_header_rec.item_number ) ;
        log_msg( 'period_id : '     || l_header_rec.period_id ) ;
        log_msg( 'calendar_code : ' || l_header_rec.calendar_code ) ;
        log_msg( 'period_code : '   || l_header_rec.period_code ) ;
        log_msg( 'cost_type_id : '  || l_header_rec.cost_type_id ) ;
        log_msg( 'cost_mthd_code : ' || l_header_rec.cost_mthd_code ) ;
        log_msg( 'user_name : ' || l_header_rec.user_name ) ;
    END IF;

    /* End of Validations on Header Record */
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
       log_msg('Calling private API to retrieve records...');
    END IF;
    GMF_BurdenDetails_PVT.Get_Burden_Details
      (
        p_api_version         => 2.0
      , p_init_msg_list       => FND_API.G_FALSE

      , x_return_status       => l_return_status
      , x_msg_count           => l_count
      , x_msg_data            => l_data

      , p_header_rec          => l_header_rec
      , x_dtl_tbl             => x_dtl_tbl
    );

    -- Return if update fails for any reason
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;
    */

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (       p_count         =>      x_msg_count             ,
                p_data          =>      x_msg_data
        );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count     ,
                p_data                  =>      x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO  Get_Burden_Details_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg
                (       G_PKG_NAME      ,
                        l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
                (       p_count                 =>      x_msg_count     ,
                        p_data                  =>      x_msg_data
                );
END Get_Burden_Details ;

-- Proc start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Input_Params                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Validates all the input parameters.                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|        p_header_rec       IN  Burden_Header_Rec_Type                     |
--|        p_dtl_tbl          IN  Burden_Dtl_Tbl_Type                        |
--|        p_operation        IN  VARCHAR2                                   |
--|                                                                          |
--|        x_header_rec       OUT Burden_Header_Rec_Type                     |
--|        x_dtl_tbl          OUT Burden_Dtl_Tbl_Type                        |
--|        x_dtl_tbl          OUT Burden_Dtl_Tbl_Type                        |
--|        x_user_id          OUT fnd_user.user_id%TYPE                      |
--|        x_return_status    OUT VARCHAR2                                   |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If succesfully initialized all variables                   |
--|       FALSE - If any error                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|    27/Feb/2001  Uday Moogla - Created                                    |
--|    13/Aug/2001  Uday Moogala  Bug# 1935297                               |
--|                 UOM conversion fails even in case of same UOMs. This is  |
--|                 happenning since item id is not getting passed to the    |
--|                 UOM conversion routine. And this happens only when Item  |
--|                 No is passed instead of Item_Id. Fix is done to pass the |
--|                 Item_Id to UOM conversion routine.                       |
--|    12/May/2004  Dinesh Vadivel Bug# 3314310                              |
--|                 Removed Validation code for the item BURDEN_USAGE in     |
--|                 VALIDATE_INPUT_PARAMS proc so that it takes negative     |
--|                 values                                                   |
--|    20-Oct-2005  Prasad marada, Bug 4689137 Modified the record type as   |
--|                per inventory convergence                                 |
--|    29-Mar-2007 Prasad marada Bug 5589409, Fixed small formating issues   |
--|                                                                          |
--+==========================================================================+
-- Proc end of comments

PROCEDURE Validate_Input_Params
(
 p_header_rec      IN  Burden_Header_Rec_Type
,p_dtl_tbl         IN  Burden_Dtl_Tbl_Type
,p_operation       IN  VARCHAR2
,x_header_rec      OUT NOCOPY Burden_Header_Rec_Type
,x_dtl_tbl         OUT NOCOPY Burden_Dtl_Tbl_Type
,x_user_id         OUT NOCOPY fnd_user.user_id%TYPE
,x_brdn_factor_tbl OUT NOCOPY GMF_BurdenDetails_PVT.Burden_factor_Tbl_Type
,x_return_status   OUT NOCOPY VARCHAR2
)
IS

        l_period_status        cm_cldr_dtl.period_status%TYPE ;
        l_usage_ind            cm_cmpt_mst.usage_ind%TYPE ;
        l_cost_cmpntcls_id     cm_cmpt_mst.cost_cmpntcls_id%TYPE ;
        l_cost_cmpntcls_code   cm_cmpt_mst.cost_cmpntcls_code%TYPE ;

        l_act_item_uom         mtl_item_flexfields.primary_uom_code%TYPE ;
        l_resource_uom         cr_rsrc_mst.std_usage_uom%TYPE ;
        l_burden_uom_class     mtl_units_of_measure.uom_class%TYPE ;
        l_resource_uom_class   mtl_units_of_measure.uom_class%TYPE ;

        l_burdenline_id        cm_brdn_dtl.burdenline_id%TYPE ;
        l_burden_factor        cm_brdn_dtl.burden_factor%TYPE ;

        -- Bug 2681243
        l_resources            cm_brdn_dtl.resources%TYPE ;
        l_burden_qty           cm_brdn_dtl.burden_qty%TYPE ;
        l_burden_usage         cm_brdn_dtl.burden_usage%TYPE ;
        l_burden_uom           cm_brdn_dtl.burden_uom%TYPE ;
        l_item_qty             cm_brdn_dtl.item_qty%TYPE ;
        l_item_uom             cm_brdn_dtl.item_uom%TYPE ;
        l_lc_cost_type_id       cm_mthd_mst.cost_type_id%TYPE;

        l_converted_burden_qty NUMBER ;
        l_converted_item_qty   NUMBER ;

        l_idx                  NUMBER(10) := 0 ;
        e_brdn_dtl             EXCEPTION ;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- just to make sure no elements exist.
    x_dtl_tbl.delete ;
    x_brdn_factor_tbl.delete ;

    /* Validating Header Record */
    --
    ------------------------------
    -- Organization Id validation
    ------------------------------
    -- If organization id is sent then use organization id else
    -- use organization code
    -- organization id
    IF (p_header_rec.organization_id <> FND_API.G_MISS_NUM) AND
       (p_header_rec.organization_id IS NOT NULL)  THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
           log_msg('validating organization_id : ' || p_header_rec.organization_id);
        END IF;

        IF NOT GMF_VALIDATIONS_PVT.Validate_organization_id(p_header_rec.organization_id)
        THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

          -- Log message to ignore if organization_Code is also passed
        IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND
           (p_header_rec.organization_code IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
                FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
                FND_MSG_PUB.Add;
          END IF;
        END IF;
          -- organization code
    ELSIF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND
       (p_header_rec.organization_code IS NOT NULL)  THEN

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN -- Bug 2659435
           log_msg('validating organization_code : ' || p_header_rec.organization_code);
        END IF;
        x_header_rec.organization_id := GMF_VALIDATIONS_PVT.Validate_organization_Code(p_header_rec.organization_code);
        IF x_header_rec.organization_id IS NULL THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORG_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5589409, pmarada
             log_msg('Organization Id : ' || x_header_rec.organization_id );
          END IF;
        END IF;
    ELSE
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End organization validation
    -------------------
    -- Item Validation
    -------------------
    -- Use inventory item_id if sent otherwise use item_number
    -- If both are sent then use only item_id and ignore other params and log a message
    -- If both are not sent then raise error.
    --
    IF (p_header_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (p_header_rec.inventory_item_id IS NOT NULL)  THEN
        -- validate inventory_item_id
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
           log_msg('validating inventory_item_id : ' || p_header_rec.inventory_item_id);
        END IF;
         x_header_rec.organization_id := nvl(p_header_rec.organization_id,x_header_rec.organization_id) ;
        IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(p_header_rec.inventory_item_id, x_header_rec.organization_id)
        THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
          FND_MESSAGE.SET_TOKEN('ITEM_ID',p_header_rec.inventory_item_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Log message if item_number is also passed
        IF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND
           (p_header_rec.item_number IS NOT NULL) THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
                FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
                FND_MSG_PUB.Add;
          END IF;
        END IF;
    ELSIF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND
          (p_header_rec.item_number IS NOT NULL)  THEN
        -- Convert item number value into item ID.
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
           log_msg('validating item_number : ' || p_header_rec.item_number);
        END IF;
          -- If Organization id is passed as null then assign the derived organization id
          x_header_rec.organization_id := nvl(p_header_rec.organization_id,x_header_rec.organization_id) ;
          x_header_rec.inventory_item_id :=GMF_VALIDATIONS_PVT.Validate_Item_Number(p_header_rec.item_number, x_header_rec.organization_id);
        IF x_header_rec.inventory_item_id IS NULL THEN       -- item_Id fetch was not successful
          -- Conversion failed.
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',x_header_rec.organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
             log_msg('inventory_item_id : ' || x_header_rec.inventory_item_id );
          END IF;
        END IF;
    ELSE
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End Item validation

    -- Bug 7513552 Now Item Org is valid fetch UOM No need to handle exception

     SELECT Primary_uom_code INTO l_act_item_uom
     FROM mtl_system_items_b
     WHERE inventory_item_id = nvl(p_header_rec.inventory_item_id,x_header_rec.inventory_item_id)
       AND organization_id = nvl(p_header_rec.organization_id,x_header_rec.organization_id);


    -------------------
    -- Cost Method Code
    -------------------
    IF (p_header_rec.cost_type_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.cost_type_id IS NOT NULL)
    THEN
         IF (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level) THEN
           log_msg('Validating Cost type Id : ' || p_header_rec.cost_type_id);
         END IF;
         --validate cost type id
         -- cost type id should be standard or actual cost type because this API is for Standard and actual cost
         -- overheads only. So Call Validate_Lot_Cost_type_id to verify the cost type is lot cost type or not.
         -- If it is lot cost type id then log error message as invalid cost type
      IF GMF_VALIDATIONS_PVT.Validate_Lot_Cost_type_id(p_header_rec.cost_type_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- log a message to ignore if cost method code also passed
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.cost_mthd_code IS NOT NULL) THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)   THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
            FND_MESSAGE.SET_TOKEN('COST_TYPE', p_header_rec.cost_mthd_code);
            FND_MSG_PUB.Add;
          END IF;
      END IF;
      -- If cost type code is passed then derive the cost type id
    ELSE
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
         IF (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level) THEN
           log_msg('Validating Cost type code : ' || p_header_rec.cost_mthd_code);
         END IF;
          -- Call validate cost type
         x_header_rec.cost_Type_id := GMF_VALIDATIONS_PVT.Validate_Cost_type_Code(p_header_rec.cost_mthd_code);
          -- call validate lot cost type.. if it is lot cost type then log an error
          -- because overheads will be created for actual and standard costs
         l_lc_cost_type_id := GMF_VALIDATIONS_PVT.Validate_Lot_Cost_Type(p_header_rec.cost_mthd_code);
         --If cost type id is null or cost type is lot cost type then log invalid cost type message
         IF (x_header_rec.cost_Type_id IS NULL)
             OR (l_lc_cost_type_id IS NOT NULL ) THEN
            add_header_to_error_stack(p_header_rec);
            FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
            FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5589409, pmarada
             log_msg('Cost Type Id : ' || x_header_rec.cost_Type_id );
          END IF;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    -- End Cost Method Code

    ------------------------
    -- Period Id validation
    ------------------------
    IF (p_header_rec.period_id <> FND_API.G_MISS_NUM) AND (p_header_rec.period_id IS NOT NULL)
    THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
          log_msg('validating Period Id : ' || p_header_rec.period_id);
        END IF;
        -- validate period id
       IF NOT GMF_VALIDATIONS_PVT.Validate_period_id(p_header_rec.period_id)
       THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
       -- If period code also passed then ignore period code
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
         AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL)) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
           FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
           FND_MESSAGE.SET_TOKEN('CALENDAR_CODE', p_header_rec.calendar_code);
           FND_MESSAGE.SET_TOKEN('PERIOD_CODE', p_header_rec.period_code);
           FND_MSG_PUB.Add;
         END IF;
      END IF;
    ELSE
          -- period code and calendar code are passed instead of period id
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
         IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level  THEN
           log_msg('Validating Calendar Code : '|| p_header_rec.Calendar_code||' period_code : ' || p_header_rec.period_code);
        END IF;
        -- if cost type id passed as null then  assign derived cost type id to the record
        -- and pass the derived cost type id for derving to period id

        x_header_rec.cost_type_id := nvl(p_header_rec.cost_type_id,x_header_rec.cost_type_id) ;
        x_header_rec.organization_id := nvl(p_header_rec.organization_id,x_header_rec.organization_id) ;

        x_header_rec.period_id := GMF_VALIDATIONS_PVT.Validate_period_code(x_header_rec.organization_id, p_header_rec.calendar_code,p_header_rec.period_code,x_header_rec.cost_Type_id);
        IF x_header_rec.period_id IS NULL THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CLDR_PERIOD');
          FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header_rec.calendar_code);
          FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header_rec.period_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5589409, pmarada
             log_msg('Period Id : ' || x_header_rec.period_id );
          END IF;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_PERIOD_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Note: period Code
    -- No need to bother about Frozen and Closed Periods. Screen allows insert
    -- and updates even of period is Frozen and Closed.
    --

    -- Populate WHO columns
    IF (p_header_rec.user_name <> FND_API.G_MISS_CHAR) AND
       (p_header_rec.user_name IS NOT NULL)  THEN
       IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
         log_msg('Validating user name : ' || p_header_rec.user_name);
       END IF;
            GMA_GLOBAL_GRP.Get_who( p_user_name  => p_header_rec.user_name
                                  , x_user_id    => x_user_id
                                  );

            IF x_user_id = -1 THEN      -- Bug 2681243: GMA changed return status value to -1.
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
                FND_MESSAGE.SET_TOKEN('USER_NAME',p_header_rec.user_name);
                FND_MSG_PUB.Add;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

    ELSE
        add_header_to_error_stack(p_header_rec); -- Bug 2659435
        FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- End User Name

    x_header_rec.organization_id   := nvl(p_header_rec.organization_id,x_header_rec.organization_id) ;
    x_header_rec.organization_code := p_header_rec.organization_code ;
    x_header_rec.inventory_item_id := nvl(p_header_rec.inventory_item_id,x_header_rec.inventory_item_id) ;
    x_header_rec.item_number       := p_header_rec.item_number ;
    x_header_rec.period_id         := nvl(p_header_rec.period_id,x_header_rec.period_id) ;
    x_header_rec.calendar_code     := p_header_rec.calendar_code ;
    x_header_rec.period_code       := p_header_rec.period_code ;
    x_header_rec.cost_type_id      := nvl(p_header_rec.cost_type_id,x_header_rec.cost_type_id) ;
    x_header_rec.cost_mthd_code    := p_header_rec.cost_mthd_code ;
    x_header_rec.user_name         := p_header_rec.user_name ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
        log_msg( 'organization_id : '   || x_header_rec.organization_id ) ;
        log_msg( 'organization_code : ' || x_header_rec.organization_code ) ;
        log_msg( 'inventory_item_id : ' || x_header_rec.inventory_item_id ) ;
        log_msg( 'item_number : '    || x_header_rec.item_number ) ;
        log_msg( 'period_id : '      || x_header_rec.period_id ) ;
        log_msg( 'calendar_code : '  || x_header_rec.calendar_code ) ;
        log_msg( 'period_code : '    || x_header_rec.period_code ) ;
        log_msg( 'cost_type_id : '   || x_header_rec.cost_type_id ) ;
        log_msg( 'cost_mthd_code : ' ||x_header_rec.cost_mthd_code ) ;
        log_msg( 'user_name : '      || x_header_rec.user_name ) ;
    END IF;

    /* End of Validations on Header Record */

    /* Begin detail records validations */
    --------------------------------
    -- Validate Detail Records
    --------------------------------

    FOR i in 1..p_dtl_tbl.count
    LOOP
      BEGIN

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                log_msg('Record # : ' || i);
        END IF;

        -- initialize the local variables
        l_usage_ind            := NULL ;
        l_cost_cmpntcls_id     := NULL ;
        l_cost_cmpntcls_code   := NULL ;
        l_resource_uom         := NULL ;
        l_burden_uom_class     := NULL ;
        l_resource_uom_class   := NULL ;
        l_burdenline_id        := NULL ;
        l_burden_factor        := NULL ;
        l_converted_burden_qty := NULL ;
        l_converted_item_qty   := NULL ;

        -- Bug 2681243
        l_resources            := NULL ;
        l_burden_qty           := NULL ;
        l_burden_usage         := NULL ;
        l_burden_uom           := NULL ;
        l_item_qty             := NULL ;
        l_item_uom             := NULL ;
        --
        -- In case of delete,
        -- if burdenline_id is supplied skip all validations and use
        --   burdenline_id to delete the records
        -- If burdenline_id is not supplied then skip all validations
        --   except resource, cost_cmpntcls_id and analysis code
        --
        IF ((p_operation = 'DELETE') AND
            ((p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) OR (p_dtl_tbl(i).burdenline_id IS NOT NULL))
           ) THEN
          add_header_to_error_stack(p_header_rec); -- Bug 2659435
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_BRDN_UNIQUE_KEY');
          FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID', p_dtl_tbl(i).burdenline_id);
          FND_MSG_PUB.Add;
          l_burdenline_id := p_dtl_tbl(i).burdenline_id;
        ELSE

          --
          -- Bug# 2659435
          -- In case of update,
          -- if burdenline_id is supplied skip validations on columns
          --   of unique key i.e., cmpntcls and alys code
          -- If burdenline_id is not supplied then do all validations
          --
          -- Message is given before calling private API since it is
          -- appropriate place.
          --
          IF ((p_operation = 'UPDATE') AND
              ((p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) OR
               (p_dtl_tbl(i).burdenline_id IS NOT NULL))
             ) THEN

              l_burdenline_id := p_dtl_tbl(i).burdenline_id;
              --
              -- Bug 2681243: added new elsif block. For updates when burdenline_id is
              -- passed retrieve all burden details to use later in the program for
              -- UOM conversions.
              --
              BEGIN
                SELECT resources, burden_qty, burden_usage, burden_uom, item_qty, item_uom
                  INTO l_resources, l_burden_qty, l_burden_usage, l_burden_uom, l_item_qty, l_item_uom
                  FROM cm_brdn_dtl
                 WHERE burdenline_id = l_burdenline_id;

              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BRDN_LINE_ID');
                  FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID',p_dtl_tbl(i).burdenline_id);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
              END;

              GMF_VALIDATIONS_PVT.Validate_Resource(l_resources, l_resource_uom, l_resource_uom_class) ;

              IF (l_resource_uom IS NULL) OR (l_resource_uom_class IS NULL) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_RESOURCES');
                FND_MESSAGE.SET_TOKEN('RESOURCES',p_dtl_tbl(i).resources);
                FND_MSG_PUB.Add;
                RAISE e_brdn_dtl;
              END IF;

          ELSE
          -- End of Bug# 2659435

            ------------
            -- Resources
            ------------
             IF (p_dtl_tbl(i).resources <> FND_API.G_MISS_CHAR) AND
               (p_dtl_tbl(i).resources IS NOT NULL)  THEN

             IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
               log_msg('validating resources : '|| p_dtl_tbl(i).resources);
             END IF;

              l_resources := p_dtl_tbl(i).resources;

              GMF_VALIDATIONS_PVT.Validate_Resource(l_resources, l_resource_uom, l_resource_uom_class) ;
              IF (l_resource_uom IS NULL) OR (l_resource_uom_class IS NULL) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_RESOURCES');
                FND_MESSAGE.SET_TOKEN('RESOURCES',p_dtl_tbl(i).resources);
                FND_MSG_PUB.Add;
                RAISE e_brdn_dtl;
              END IF;
            ELSE
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_RESOURCES_REQ');
              FND_MSG_PUB.Add;
              RAISE e_brdn_dtl;
            END IF;

            --------------
            -- CmpntCls Id
            --------------
            -- Use cmpntcls_id if sent otherwise use cmpntcls_code
            -- If both are sent then use only cmpntcls_id and ignore other params and log a message
            -- If both are not sent then raise error.
            --
            IF (p_dtl_tbl(i).cost_cmpntcls_id <> FND_API.G_MISS_NUM) AND
               (p_dtl_tbl(i).cost_cmpntcls_id IS NOT NULL)  THEN
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                        log_msg('validating Cmpt Cls ID('||i||') : '||
                                                     p_dtl_tbl(i).cost_cmpntcls_id);
                END IF;

                -- validate CmpntCls Id
                GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (p_dtl_tbl(i).cost_cmpntcls_id,l_cost_cmpntcls_code,l_usage_ind);
                IF l_usage_ind IS NULL THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_dtl_tbl(i).cost_cmpntcls_id);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                ELSIF l_usage_ind <> 2 THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_USG_NOT_BRDN');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_dtl_tbl(i).cost_cmpntcls_id);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;

                l_cost_cmpntcls_id := p_dtl_tbl(i).cost_cmpntcls_id ;

                -- Log message if cost_cmpntcls_code is also passed
                IF (p_dtl_tbl(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND
                         (p_dtl_tbl(i).cost_cmpntcls_code IS NOT NULL)  THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
                    add_header_to_error_stack(p_header_rec); -- Bug 2659435
                    FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
                    FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_dtl_tbl(i).cost_cmpntcls_code);
                    FND_MSG_PUB.Add;
                  END IF;
                END IF;
            ELSIF (p_dtl_tbl(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR) AND
                        (p_dtl_tbl(i).cost_cmpntcls_code IS NOT NULL)  THEN
                l_cost_cmpntcls_code := p_dtl_tbl(i).cost_cmpntcls_code ;

                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                        log_msg('validating Cmpt Cls Code('||i||') : ' ||
                                                         p_dtl_tbl(i).cost_cmpntcls_code);

                END IF;
                -- Convert value into ID.
                GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (
                                                                  p_dtl_tbl(i).cost_cmpntcls_code,
                                                                  l_cost_cmpntcls_id,
                                                                  l_usage_ind
                                                                ) ;
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                        log_msg('Cmpt Cls Id := ' || l_cost_cmpntcls_id);
                END IF;

                IF (l_cost_cmpntcls_id IS NULL) OR (l_usage_ind IS NULL) THEN
                  -- Conversion failed.
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_dtl_tbl(i).cost_cmpntcls_code);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                ELSIF l_usage_ind <> 2 THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_USG_NOT_BRDN');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',l_cost_cmpntcls_id);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;
            ELSE
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
                FND_MSG_PUB.Add;
                RAISE e_brdn_dtl;
            END IF;
            -- End CmpntCls Id

            ----------------
            -- Analysis Code
            ----------------
            IF (p_dtl_tbl(i).cost_analysis_code <> FND_API.G_MISS_CHAR) AND
                     (p_dtl_tbl(i).cost_analysis_code IS NOT NULL)  THEN

                 IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                   log_msg('validating analysis_code('||i||') : ' || p_dtl_tbl(i).cost_analysis_code);
                 END IF;
                IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(p_dtl_tbl(i).cost_analysis_code)
                THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
                  FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE',p_dtl_tbl(i).cost_analysis_code);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;
            ELSE
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
            END IF;
            -- End Analysis Code

            IF (p_operation = 'UPDATE') THEN
              --
              -- Bug 2681243: added new elsif block. For updates when burdenline_id is
              -- passed retrieve all burden details to use later in the program for
              -- UOM conversions.
              --
               BEGIN
                 SELECT resources, burden_qty, burden_usage, burden_uom, item_qty, item_uom
                   INTO l_resources, l_burden_qty, l_burden_usage, l_burden_uom, l_item_qty, l_item_uom
                   FROM
                         cm_brdn_dtl
                  WHERE
                         organization_id    = x_header_rec.organization_id
                    AND  inventory_item_id  = x_header_rec.inventory_item_id
                    AND  period_id          = x_header_rec.period_id
                    AND  cost_type_id       = x_header_rec.cost_type_id
                    AND  resources          = l_resources
                    AND  cost_cmpntcls_id   = l_cost_cmpntcls_id
                    AND  cost_analysis_code = p_dtl_tbl(i).cost_analysis_code ;

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   add_header_to_error_stack(p_header_rec);
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_DTL_NOT_FOUND');
                   FND_MESSAGE.SET_TOKEN('RESOURCE',l_resources);
                   FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_dtl_tbl(i).cost_cmpntcls_code);
                   FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',l_cost_cmpntcls_id);
                   FND_MESSAGE.SET_TOKEN('ALYS_CODE',p_dtl_tbl(i).cost_analysis_code);
                   FND_MSG_PUB.Add;
                   RAISE e_brdn_dtl;
               END;
            END IF;

          END IF; -- Bug 2659435


          --
          -- Enough of validations for delete.
          -- For update and insert we should do all validations.
          --
          IF (p_operation <> 'DELETE') THEN
            --
            -- Burden Usage
            -- Burden Usage should be > 0
            -- In the form the format mask for this is : 999999999D999999999(999,999,999.999999999)
            -- To put that check here, the cost should not be >= 1,000,000,000
            --
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating Burden Usage : '||p_dtl_tbl(i).burden_usage);
            END IF;

            IF (p_dtl_tbl(i).burden_usage <> FND_API.G_MISS_NUM) AND
                (p_dtl_tbl(i).burden_usage IS NOT NULL)  THEN

              l_burden_usage := p_dtl_tbl(i).burden_usage; -- Bug 2681243


              /**********************************************************************
              * dvadivel Bug # 3314310 12-May-2004 Allowing negative burden_usage
              **********************************************************************/
              /*
              IF ((nvl(p_dtl_tbl(i).burden_usage,0) <= 0.000000001) OR
                  (nvl(p_dtl_tbl(i).burden_usage,0) >= 1000000000)) THEN
                 add_header_to_error_stack(p_header_rec); -- Bug 2659435
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BURDEN_USAGE');
                 FND_MESSAGE.SET_TOKEN('BURDEN_USAGE',p_dtl_tbl(i).burden_usage);
                 FND_MSG_PUB.Add;
                 RAISE e_brdn_dtl;
              END IF;
              */

            ELSIF (p_dtl_tbl(i).burden_usage = FND_API.G_MISS_NUM AND   -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_USAGE_REQ');
              FND_MSG_PUB.Add;
              RAISE e_brdn_dtl;
            END IF;
            -- End Burden Usage

            ----------------
            -- Item Quantity
            ----------------
            -- Item Quantity should be > 0
            -- In the form the format mask for this is : 999999999D999999999(999,999,999.999999999)
            -- To put that check here, the cost should not be >= 1,000,000,000
            --
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating Item Quantity : '||p_dtl_tbl(i).item_qty);
            END IF;

            IF (p_dtl_tbl(i).item_qty <> FND_API.G_MISS_NUM) AND
                (p_dtl_tbl(i).item_qty IS NOT NULL)  THEN

              l_item_qty := p_dtl_tbl(i).item_qty; -- Bug 2681243

              IF ((nvl(p_dtl_tbl(i).item_qty,0) <= 0.000000001) OR
                  (nvl(p_dtl_tbl(i).item_qty,0) >= 1000000000)) THEN
                 add_header_to_error_stack(p_header_rec); -- Bug 2659435
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_QTY');
                 FND_MESSAGE.SET_TOKEN('ITEM_QTY',p_dtl_tbl(i).item_qty);
                 FND_MSG_PUB.Add;
                 RAISE e_brdn_dtl;
              END IF;
            ELSIF (p_dtl_tbl(i).item_qty = FND_API.G_MISS_NUM AND       -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_QTY_REQ');
              FND_MSG_PUB.Add;
              RAISE e_brdn_dtl;
            END IF;
            -- End Item Quantity

            -----------------------
            -- Item Unit of Measure
            -----------------------
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating item_uom : ' || p_dtl_tbl(i).item_uom);
            END IF;

            IF (p_dtl_tbl(i).item_uom <> FND_API.G_MISS_CHAR) AND
               (p_dtl_tbl(i).item_uom IS NOT NULL)  THEN

                l_item_uom := p_dtl_tbl(i).item_uom; -- Bug 2681243
                IF NOT GMF_VALIDATIONS_PVT.Validate_Usage_Uom(p_dtl_tbl(i).item_uom) THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_UM');
                  FND_MESSAGE.SET_TOKEN('ITEM_UOM',p_dtl_tbl(i).item_uom);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;

            ELSIF (p_dtl_tbl(i).item_uom = FND_API.G_MISS_CHAR AND       -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_UM_REQ');
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
            END IF;

            --
            -- Bug 2681243: Only in case of insert or update with any one of
            -- other values is passed then do the conversion.
            --
            IF ((p_operation = 'INSERT') OR
                ( (p_operation = 'UPDATE') AND
                  (p_dtl_tbl(i).burden_qty      IS NOT NULL OR
                   p_dtl_tbl(i).burden_usage    IS NOT NULL OR
                   p_dtl_tbl(i).burden_uom      IS NOT NULL OR
                   p_dtl_tbl(i).item_qty        IS NOT NULL OR
                   p_dtl_tbl(i).item_uom        IS NOT NULL)
                )
               ) THEN

               -- Convert item quantity actual item UOM
               IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN -- Bug 2659435
                       log_msg('Converting Item Qty ' || l_item_qty ||
                       ' from UOM ' || l_item_uom || ' to UOM ' || l_act_item_uom ||
                       ' for Item_Id : ' || x_header_rec.inventory_item_id);
               END IF;

               BEGIN
               l_converted_item_qty :=inv_convert.inv_um_convert
                                      (item_id       => x_header_rec.inventory_item_id,
                                       precision     => 5,           -- precision 5
                                       from_quantity => l_item_qty,  -- initial item qty to convert
                                       from_unit     => l_item_uom,     -- initial UOM to convert
                                       to_unit       => l_act_item_uom, -- initial Burden UOM to convert from
                                       from_name     => NULL,
                                       to_name       => NULL);

                 -- Bug 7513552 Inform user incase there are any conversion issues as well.
                 IF l_converted_item_qty = -99999 THEN
                   RAISE e_brdn_dtl;
                 End IF;

                 IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN       -- Bug 2659435
                       log_msg('Converted Item Qty : ' || l_converted_item_qty);
                 END IF;

               EXCEPTION
                 WHEN OTHERS THEN
                   add_header_to_error_stack(p_header_rec); -- Bug 2659435
                   FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_UM_CONV_ERR');
                   FND_MESSAGE.SET_TOKEN('ITEM_ID', x_header_rec.inventory_item_id); --p_header_rec.item_id); Bug# 1935297
                   FND_MESSAGE.SET_TOKEN('ITEM_UM',l_item_uom);
                   FND_MESSAGE.SET_TOKEN('ITEM_ACT_UM',l_act_item_uom);
                   FND_MSG_PUB.Add;
                   RAISE e_brdn_dtl;
               END ;
            END IF ;
            -- End Item Unit of Measure

            ------------------
            -- Burden Quantity
            ------------------
            -- Burden Quantity should be > 0
            -- In the form the format mask for this is : 999999999D999999999(999,999,999.999999999)
            -- To put that check here, the cost should not be >= 1,000,000,000
            --
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating Burden Quantity : '||p_dtl_tbl(i).burden_qty);
            END IF;

            IF (p_dtl_tbl(i).burden_qty <> FND_API.G_MISS_NUM) AND
               (p_dtl_tbl(i).burden_qty IS NOT NULL)  THEN

              l_burden_qty := p_dtl_tbl(i).burden_qty; -- Bug 2681243
              IF ((nvl(p_dtl_tbl(i).burden_qty,0) <= 0.000000001) OR
                  (nvl(p_dtl_tbl(i).burden_qty,0) >= 1000000000)) THEN
                 add_header_to_error_stack(p_header_rec); -- Bug 2659435
                 FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BURDEN_QTY');
                 FND_MESSAGE.SET_TOKEN('OVERHEAD_QTY',p_dtl_tbl(i).burden_qty);
                 FND_MSG_PUB.Add;
                 RAISE e_brdn_dtl;
              END IF;
            ELSIF (p_dtl_tbl(i).burden_qty = FND_API.G_MISS_NUM AND     -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_QTY_REQ');
              FND_MSG_PUB.Add;
              RAISE e_brdn_dtl;
            END IF;
            -- End Burden Quantity

            --------------------------
            -- Burden Unit of Measure
            --------------------------
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating burden_uom : ' || p_dtl_tbl(i).burden_uom);
            END IF;

            IF (p_dtl_tbl(i).burden_uom <> FND_API.G_MISS_CHAR) AND
               (p_dtl_tbl(i).burden_uom IS NOT NULL)  THEN

                l_burden_uom := p_dtl_tbl(i).burden_uom; -- Bug 2681243
                GMF_VALIDATIONS_PVT.Validate_Usage_Uom(p_dtl_tbl(i).burden_uom, l_burden_uom_class) ;
                IF l_burden_uom_class IS NULL THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BURDEN_UM');
                  FND_MESSAGE.SET_TOKEN('OVERHEAD_UM',p_dtl_tbl(i).burden_uom);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;

                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
                   log_msg('Burden UOM Class : ' || l_burden_uom_class || ' resource UOM Class : ' || l_resource_uom_class);
                END IF;

                -- Burden UOM must be of the same type as the resource UOM
                IF (l_resource_uom_class <> l_burden_uom_class) THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_UOM_SAMETYPE_REQ');
                  FND_MESSAGE.SET_TOKEN('OVERHEAD_UM',p_dtl_tbl(i).burden_uom);
                  FND_MESSAGE.SET_TOKEN('RESOURCE_UM',l_resource_uom_class);
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
                END IF;
            ELSIF (p_dtl_tbl(i).burden_uom = FND_API.G_MISS_CHAR AND     -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_UM_REQ');
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
            END IF;
            -- End Burden Unit of Measure

            --
            -- Calculate burden factor
            -- If converted item qty is zero then burden_factor = 0 else
            -- first convert burden usage to resource uom, then use converted qty to get burden factor
            --
            IF (l_converted_item_qty  IS NOT NULL) AND   -- Bug 2681243
               (l_converted_item_qty = 0) THEN

                l_burden_factor := 0 ;

            ELSIF l_converted_item_qty  IS NOT NULL THEN

                -- Convert burden usage to resource uom.
                BEGIN
                  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN      -- Bug 2659435
                        log_msg( 'Converting Brdn Usage ' || l_burden_usage ||
                          ' from UOM ' || l_burden_uom || ' to UOM ' || l_resource_uom);
                  END IF;
                  l_converted_burden_qty :=inv_convert.inv_um_convert
                                           (item_id       => 0,         -- here item is not required
                                            precision     => 5,         -- precision 5
                                            from_quantity => l_burden_usage,  -- initial qty to convert
                                            from_unit     => l_burden_uom,    -- initial qty to convert
                                            to_unit       => l_resource_uom,  -- initial Burden UOM to convert from
                                            from_name     => NULL,
                                            to_name       => NULL);
                  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN      -- Bug 2659435
                        log_msg('Converted Burden Usage : ' || l_converted_burden_qty);
                  END IF;

                  l_burden_factor := ROUND( (l_converted_burden_qty / l_converted_item_qty) * l_burden_qty, 9 );

                  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN      -- Bug 2659435
                        log_msg('Burden Factor : ' || l_burden_factor);
                  END IF;

                EXCEPTION
                  WHEN OTHERS THEN
                    add_header_to_error_stack(p_header_rec); -- Bug 2659435
                    FND_MESSAGE.SET_NAME('GMF','GMF_API_BRDN_UM_CONV_ERR');
                    FND_MESSAGE.SET_TOKEN('RESOURCES',l_resources);  -- Bug 2681243: use local variable.
                    FND_MESSAGE.SET_TOKEN('OVERHEAD_UM',l_burden_uom);
                    FND_MESSAGE.SET_TOKEN('RESOURCE_UM',l_resource_uom);
                    FND_MSG_PUB.Add;
                    RAISE e_brdn_dtl;
                END ;
            END IF;

            --------------
            -- Delete Mark
            --------------
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN    -- Bug 2659435
                log_msg('validating delete_mark('||i||') :' ||
                                                 p_dtl_tbl(i).delete_mark);
            END IF;

            IF (p_dtl_tbl(i).delete_mark <> FND_API.G_MISS_NUM) AND
               (p_dtl_tbl(i).delete_mark IS NOT NULL)  THEN
              IF p_dtl_tbl(i).delete_mark NOT IN (0,1) THEN
                add_header_to_error_stack(p_header_rec); -- Bug 2659435
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
                FND_MESSAGE.SET_TOKEN('DELETE_MARK',p_dtl_tbl(i).delete_mark);
                FND_MSG_PUB.Add;
                RAISE e_brdn_dtl;
              END IF;
            ELSIF (p_dtl_tbl(i).delete_mark = FND_API.G_MISS_NUM AND    -- Bug 2659435
                   p_operation = 'UPDATE') OR
                  (p_operation = 'INSERT') THEN
                  add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
                  FND_MSG_PUB.Add;
                  RAISE e_brdn_dtl;
            END IF;
            IF ((p_operation = 'UPDATE') AND (p_dtl_tbl(i).delete_mark = 1)) THEN
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
              FND_MSG_PUB.Add;
              RAISE e_brdn_dtl;
            END IF;
            -- End Delete Mark

          END IF ;  -- check for delete to eliminate unneccessary validations.

     /* End of detail records validations */

          --
          -- Ignore unique key combination if burdenline_id is supplied. If not supplied then
          -- use unique key combination to update/delete the record.
          -- Private API check uses burdenline_id if supplied else uses unique key combination
          --
          IF ((p_operation = 'UPDATE') AND
              ((p_dtl_tbl(i).burdenline_id <> FND_API.G_MISS_NUM) OR (p_dtl_tbl(i).burdenline_id IS NOT NULL))
             ) THEN
            add_header_to_error_stack(p_header_rec); -- Bug 2659435
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_BRDN_UNIQUE_KEY');
            FND_MESSAGE.SET_TOKEN('OVERHEADLINE_ID', p_dtl_tbl(i).burdenline_id);
            FND_MSG_PUB.Add;
            l_burdenline_id := p_dtl_tbl(i).burdenline_id;
          END IF ;

        END IF ; -- Main if(after for loop stmt) to check for delete operation and check for burdenline_id.

        l_idx := l_idx + 1 ;
        x_dtl_tbl(l_idx).burdenline_id       := l_burdenline_id ;
        x_dtl_tbl(l_idx).resources           := l_resources ;
        x_dtl_tbl(l_idx).cost_cmpntcls_id    := nvl(p_dtl_tbl(i).cost_cmpntcls_id,l_cost_cmpntcls_id);
        x_dtl_tbl(l_idx).cost_cmpntcls_code  := nvl(p_dtl_tbl(i).cost_cmpntcls_code,l_cost_cmpntcls_code) ;
        x_dtl_tbl(l_idx).cost_analysis_code  := p_dtl_tbl(i).cost_analysis_code ;
        x_dtl_tbl(l_idx).burden_usage        := p_dtl_tbl(i).burden_usage ;
        x_dtl_tbl(l_idx).item_qty            := p_dtl_tbl(i).item_qty ;
        x_dtl_tbl(l_idx).item_uom            := p_dtl_tbl(i).item_uom ;
        x_dtl_tbl(l_idx).burden_qty          := p_dtl_tbl(i).burden_qty ;
        x_dtl_tbl(l_idx).burden_uom          := p_dtl_tbl(i).burden_uom ;
        IF p_operation in ('INSERT', 'UPDATE') THEN
          x_dtl_tbl(l_idx).delete_mark       := 0 ;
        ELSE
          x_dtl_tbl(l_idx).delete_mark       := 1 ;
        END IF ;
        x_brdn_factor_tbl(l_idx).burden_factor:= l_burden_factor ;

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 2659435
          log_msg('x_burdenline_id('||l_idx||'): '||x_dtl_tbl(l_idx).burdenline_id);
          log_msg('x_resources('||l_idx||'): '||x_dtl_tbl(l_idx).resources);
          log_msg('x_cost_cmpntcls_id('||l_idx||'): '||x_dtl_tbl(l_idx).cost_cmpntcls_id);
          log_msg('x_cost_cmpntcls_code('||l_idx||'): '|| x_dtl_tbl(l_idx).cost_cmpntcls_code)  ;
          log_msg('x_cost_analysis_code('||l_idx||'): '|| x_dtl_tbl(l_idx).cost_analysis_code)  ;
          log_msg('x_burden_usage('||l_idx||'): '||x_dtl_tbl(l_idx).burden_usage);
          log_msg('x_item_qty('||l_idx||'): '||x_dtl_tbl(l_idx).item_qty);
          log_msg('x_item_uom('||l_idx||'): '||x_dtl_tbl(l_idx).item_uom);
          log_msg('x_burden_qty('||l_idx||'): '||x_dtl_tbl(l_idx).burden_qty);
          log_msg('x_burden_uom('||l_idx||'): '||x_dtl_tbl(l_idx).burden_uom);
          log_msg('x_brdn_factor('||l_idx||'): '||x_brdn_factor_tbl(l_idx).burden_factor);
          log_msg('x_delete_mark('||l_idx||'): '||x_dtl_tbl(l_idx).delete_mark);
        END IF;

      EXCEPTION
        WHEN e_brdn_dtl THEN
         RAISE FND_API.G_EXC_ERROR;
      END ;
    END LOOP;

EXCEPTION       -- Bug 2681243: removed when others to capture ORA errors.
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Validate_Input_Params ;
--
-- Func start of comments
--+==========================================================================+
--|  Procedure Name                                                          |
--|       log_msg                                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure logs messages to message stack.                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_msg_lvl             IN NUMBER(10) - Message Level                |
--|       p_msg_text            IN NUMBER(10) - Actual Message Text          |
--|                                                                          |
--|  RETURNS                                                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|       05/nov/2002 Uday Moogala Bug 2659435                               |
--|         Removed first param for debug level                              |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE log_msg
(
p_msg_text      IN VARCHAR2
)
IS
BEGIN

  -- IF FND_MSG_PUB.Check_Msg_Level (p_msg_lvl) THEN    -- Bug 2659435
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  -- END IF;

END log_msg ;

-- Func start of comments
--+==========================================================================+
--|  Procedure Name                                                          |
--|       add_header_to_error_stack                                          |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure logs header to message stack.                       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_header            Header Record to be logged                     |
--|                                                                          |
--|  RETURNS                                                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       05/11/2001 Uday Moogla - Created Bug 2659435                       |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE add_header_to_error_stack
(
 p_header       Burden_Header_Rec_Type
)
IS
BEGIN

  IF G_header_logged = 'N' THEN
    G_header_logged := 'Y';
    FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_HEADER');
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header.organization_id);
    FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header.organization_code);
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_header.inventory_item_id);
    FND_MESSAGE.SET_TOKEN('ITEM_NUMBER',p_header.item_number);
    FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header.period_id);
    FND_MESSAGE.SET_TOKEN('CALENDAR',p_header.calendar_code);
    FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header.period_code);
    FND_MESSAGE.SET_TOKEN('COSTTYPE_ID',p_header.cost_type_id);
    FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header.cost_mthd_code);
    FND_MSG_PUB.Add;
  END IF;

END add_header_to_error_stack;

END GMF_BurdenDetails_PUB;

/
