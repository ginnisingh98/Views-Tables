--------------------------------------------------------
--  DDL for Package Body GMF_ITEMCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ITEMCOST_PUB" AS
/* $Header: GMFPCSTB.pls 120.2.12000000.3 2007/05/11 17:46:25 pmarada ship $ */

  /*******************
  * Global variables *
  *******************/
  G_PKG_NAME      CONSTANT  VARCHAR2(30) := 'GMF_ItemCost_PUB';
  G_tmp		                  BOOLEAN := FND_MSG_PUB.Check_Msg_Level(0) ;
  G_debug_level	            NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold;
  G_header_logged           VARCHAR2(1);

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
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  END LOG_MSG ;

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
  p_header	            IN            header_rec_type
  )
  IS
  BEGIN
    IF G_header_logged = 'N'
    THEN
      G_header_logged := 'Y';
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEMCOST_HEADER');
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header.organization_id);
      FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header.organization_code);
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_header.inventory_item_id);
      FND_MESSAGE.SET_TOKEN('ITEM_NUMBER',p_header.item_number);
      FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header.period_id);
      FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header.calendar_code);
      FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header.period_code);
      FND_MESSAGE.SET_TOKEN('COSTTYPE_ID',p_header.cost_type_id);
      FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header.cost_mthd_code);
      FND_MSG_PUB.Add;
    END IF;
  END ADD_HEADER_TO_ERROR_STACK;

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPCSTB.pls                                        |
--| Package Name       : GMF_ItemCost_PUB                                    |
--| API name           : GMF_ItemCost_PUB                                    |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : Item Cost creation, updatation and deletion.        |
--|                                                                          |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 3.0                                                 |
--| Previous Vers      : 2.0                                                 |
--| Initial Vers       : 1.0                                                 |
--|                                                                          |
--| Contents                                                                 |
--|	Create_Item_Cost                                                     |
--|	Update_Item_Cost                                                     |
--|	Delete_Item_Cost                                                     |
--|	Get_Item_Cost                                                        |
--|                                                                          |
--| Notes                                                                    |
--|     This package contains public procedures relating to Item Cost        |
--|     creation, updatation and deletetion.                                 |
--|                                                                          |
--|  Pre-defined API message levels					     |
--|                                                                          |
--|     Valid values for message levels are from 1-50.			     |
--|      1 being least severe and 50 highest.				     |
--|                                                                          |
--|     The pre-defined levels correspond to standard API     		     |
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
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
--|    06/Jul/2001  Uday Moogala  Bug# 1868624                               |
--|                 Fixed Validate_Input_Params procedure to not to validate |
--|                 unique key columns when cmptcost_id is passed.           |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes. 					     |
--|	 1. remove G_MISS_xxx assignments.				     |
--|	 2. Conditionally calling debug routine.                             |
--|	 Also, fixed issues found during unit testing. Search for the bug    |
--|	 number to find the fixes.               			     |
--|    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint              |
--|    21/NOV/2002  Uday Moogala  Bug# 2681243                               |
--|      1. Return value of GMA_GLOBAL_GRP.set_who has changed to -1 from 0  |
--|         in case of invalid users.					     |
--|	 2. Removed "when others" section in validate_input_params           |
--+==========================================================================+
-- End of comments

-- Proc start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Input_Params                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Validates all the input parameters.                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|        p_header_rec       IN  Header_Rec_Type                            |
--|        x_header_rec       OUT Header_Rec_Type                            |
--|        x_user_id          OUT fnd_user.user_id%TYPE                      |
--|        x_return_status    OUT VARCHAR2                                   |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If succesfully initialized all variables                   |
--|       FALSE - If any error                                               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|       06/07/2001 Uday Moogala  Bug# 1868624                              |
--|                 Fixed Validate_Input_Params procedure to not to validate |
--|                 unique key columns when cmptcost_id is passed.           |
--|  06-Apr-07  Pmarada Bug 5586406, Put some log messages                   |
--|                                                                          |
--+==========================================================================+
-- Proc end of comments

  PROCEDURE validate_input_params
  (
  p_header_rec            IN              Header_Rec_Type,
  p_this_level            IN              This_Level_Dtl_Tbl_Type,
  p_lower_level           IN              Lower_Level_Dtl_Tbl_Type,
  p_operation             IN              VARCHAR2,
  x_header_rec                OUT NOCOPY  Header_Rec_Type,
  x_this_level                OUT NOCOPY  This_Level_Dtl_Tbl_Type,
  x_lower_level               OUT NOCOPY  Lower_Level_Dtl_Tbl_Type,
  x_user_id                   OUT NOCOPY  fnd_user.user_id%TYPE,
  x_return_status             OUT NOCOPY  VARCHAR2
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_period_status                       gmf_period_statuses.period_status%TYPE ;
    l_cost_type                           cm_mthd_mst.cost_type%TYPE ;
    l_prodcalc_type                       cm_mthd_mst.prodcalc_type%TYPE ;
    l_usage_ind                           cm_cmpt_mst.usage_ind%TYPE ;
    l_rmcalc_type                         cm_cmpt_dtl.rmcalc_type%TYPE ;
    l_cost_cmpntcls_id                    cm_cmpt_mst.cost_cmpntcls_id%TYPE ;
    l_cost_cmpntcls_code                  cm_cmpt_mst.cost_cmpntcls_code%TYPE ;
    l_cmpntcost_id                        cm_cmpt_dtl.cmpntcost_id%TYPE ;
    l_rollover_ind                        cm_cmpt_dtl.rollover_ind%TYPE ;
    l_idx                                 NUMBER(10) := 0 ;
    e_this_level                          EXCEPTION ;
    e_lower_level                         EXCEPTION ;

  BEGIN

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /***************************************
    * just to make sure no elements exist. *
    ***************************************/
    x_this_level.delete ;
    x_lower_level.delete ;

    /**************************
    * Organization Validation *
    **************************/
    IF (p_header_rec.organization_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.organization_id IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Organization Id :' || p_header_rec.Organization_id);
      END IF;
      IF NOT GMF_VALIDATIONS_PVT.Validate_organization_id(p_header_rec.organization_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.organization_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.organization_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
        THEN
          log_msg('Validating Organization Code :' || p_header_rec.Organization_code);
        END IF;
        x_header_rec.organization_id := GMF_VALIDATIONS_PVT.Validate_organization_Code(p_header_rec.organization_code);
        IF x_header_rec.organization_id IS NULL
        THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORG_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5586406, pmarada
             log_msg('Organization Id : ' || x_header_rec.organization_id );
           END IF;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    x_header_rec.organization_id := nvl(p_header_rec.organization_id, x_header_rec.organization_id) ;

    /***********************
    * Cost TYPE Validation *
    ***********************/
    IF (p_header_rec.cost_type_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.cost_type_id IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Cost type Id : ' || p_header_rec.cost_type_id);
      END IF;
      IF NOT GMF_VALIDATIONS_PVT.Validate_Cost_type_id(p_header_rec.cost_type_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
          FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
        THEN
          log_msg('Validating Cost type code : ' || p_header_rec.cost_mthd_code);
        END IF;
        x_header_rec.cost_Type_id := GMF_VALIDATIONS_PVT.Validate_Cost_type_Code(p_header_rec.cost_mthd_code);
        IF x_header_rec.cost_Type_id IS NULL THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
          FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5586406, pmarada
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
    x_header_rec.cost_type_id  := nvl(p_header_rec.cost_type_id, x_header_rec.cost_type_id) ;

    /***********************
    * Period Id Validation *
    ***********************/
    IF (p_header_rec.period_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.period_id IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Period Id : ' || p_header_rec.period_id);
      END IF;
      IF NOT GMF_VALIDATIONS_PVT.Validate_period_id(p_header_rec.period_id)
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
          FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header_rec.calendar_code);
          FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header_rec.period_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Calendar Code : '|| p_header_rec.Calendar_code||' period_code : ' || p_header_rec.period_code);
      END IF;
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
        x_header_rec.period_id := GMF_VALIDATIONS_PVT.Validate_Period_code(x_header_rec.organization_id, p_header_rec.calendar_code,p_header_rec.period_code, x_header_rec.cost_Type_id);
        IF nvl(x_header_rec.period_id, -1) <= 0 THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CLDR_PERIOD');
          FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header_rec.calendar_code);
          FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header_rec.period_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
           IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN        -- Bug 5586406, pmarada
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
    x_header_rec.period_id     := nvl(p_header_rec.period_id, x_header_rec.period_id) ;

    BEGIN
      SELECT    period_status
      INTO      l_period_status
      FROM      gmf_period_statuses
      WHERE     period_id = x_header_rec.period_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_period_status := NULL;
    END;
    IF l_period_status IS NULL
    THEN
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_STATUS');
      FND_MESSAGE.SET_TOKEN('PERIOD_ID',x_header_rec.period_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_period_status = 'F'
    THEN
      IF p_operation IN ('UPDATE','DELETE')
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_FROZEN_PERIOD_ID');
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',x_header_rec.period_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
    ELSIF l_period_status = 'C'
    THEN
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_CLOSED_PERIOD_ID');
      FND_MESSAGE.SET_TOKEN('PERIOD_ID',x_header_rec.period_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /******************
    * Item Validation *
    ******************/
    IF (p_header_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND (p_header_rec.inventory_item_id IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Inventory Item Id : ' || p_header_rec.inventory_item_id);
      END IF;
      IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(p_header_rec.inventory_item_id, x_header_Rec.organization_id)
      THEN
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
        FND_MESSAGE.SET_TOKEN('ITEM_ID', p_header_rec.inventory_item_id);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',x_header_Rec.organization_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSIF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Item Number : ' || p_header_rec.item_number);
      END IF;
      x_header_rec.inventory_item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(p_header_rec.item_number, x_header_Rec.organization_id);
        IF x_header_rec.inventory_item_id IS NULL
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',x_header_Rec.organization_id);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
            log_msg('Inventory Item id : ' || x_header_rec.inventory_item_id);
          END IF;
        END IF;
    ELSE
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_header_rec.inventory_item_id := nvl(p_header_rec.inventory_item_id, x_header_rec.inventory_item_id);

    IF (l_period_status = 'F') AND (p_operation = 'INSERT')
    THEN
      SELECT          NVL(MAX(rollover_ind),0)
      INTO            l_rollover_ind
      FROM            cm_cmpt_dtl
      WHERE           inventory_item_id = x_header_rec.inventory_item_id
      AND             organization_id = x_header_rec.organization_id
      AND             period_id = x_header_rec.period_id
      AND             cost_type_id = x_header_rec.cost_type_id;

      IF l_rollover_ind <> 0
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_CANNT_INSERT_CMPTS');
        FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',x_header_rec.inventory_item_id);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',x_header_rec.organization_id);
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',x_header_rec.period_id);
        FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',x_header_rec.cost_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
    END IF ;

    /***********************
    * User Name Validation *
    ***********************/
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
      log_msg('Validating user name : ' || p_header_rec.user_name);
    END IF;

    IF (p_header_rec.user_name <> FND_API.G_MISS_CHAR)
    AND (p_header_rec.user_name IS NOT NULL)
    THEN
      GMA_GLOBAL_GRP.Get_who( p_user_name  => p_header_rec.user_name, x_user_id  => x_user_id);
      IF x_user_id = -1
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
        FND_MESSAGE.SET_TOKEN('USER_NAME',p_header_rec.user_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    	END IF;
    ELSE
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_header_rec.inventory_item_id := nvl(p_header_rec.inventory_item_id, x_header_rec.inventory_item_id);
    x_header_rec.period_id         := nvl(p_header_rec.period_id, x_header_rec.period_id) ;
    x_header_rec.calendar_code     := nvl(p_header_rec.calendar_code, x_header_rec.calendar_code) ;
    x_header_rec.period_code       := nvl(p_header_rec.period_code, x_header_rec.period_code) ;
    x_header_rec.cost_type_id      := nvl(p_header_rec.cost_type_id, x_header_rec.cost_type_id) ;
    x_header_rec.cost_mthd_code    := nvl(p_header_rec.cost_mthd_code, x_header_rec.cost_mthd_code) ;
    x_header_rec.organization_id   := nvl(p_header_rec.organization_id, x_header_rec.organization_id) ;
    x_header_rec.organization_code := nvl(p_header_rec.organization_code, x_header_rec.organization_code);
    x_header_rec.item_number       := nvl(p_header_rec.item_number, x_header_rec.item_number) ;
    x_header_rec.user_name         := nvl(p_header_rec.user_name, x_header_rec.user_name) ;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg( 'period_id : ' || x_header_rec.period_id ) ;
    	log_msg( 'cost_type_id : ' || x_header_rec.cost_type_id ) ;
    	log_msg( 'Organziation_id : ' || x_header_rec.organization_id ) ;
    	log_msg( 'inventory_item_id : ' || x_header_rec.inventory_item_id ) ;
    	log_msg( 'item_number : ' || x_header_rec.item_number ) ;
    	log_msg( 'user_name : ' || x_header_rec.user_name ) ;
    END IF;

    FOR i in 1..p_this_level.count
    LOOP
      BEGIN
        l_usage_ind          := '' ;
        l_rmcalc_type        := '' ;
        l_cost_cmpntcls_id   := '' ;
        l_cost_cmpntcls_code := '' ;
        l_cmpntcost_id       := '' ;

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN	-- Bug 2659435
        	log_msg('This Level Record# : ' || i);
        END IF;

        /*****************************************************************************************
        * In case of delete, if cmpntcost_id is supplied skip all validations and use            *
        * cmpntcost_id to delete the records If cmpntcost_id is not supplied then do validations *
        * on all unique key columns only                                                         *
        *****************************************************************************************/

        IF ((p_operation = 'DELETE')
        AND ((p_this_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
        OR (p_this_level(i).cmpntcost_id IS NOT NULL)))
        THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_IC_UNIQUE_KEY');
          FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level(i).cmpntcost_id);
          FND_MSG_PUB.Add;
          l_cmpntcost_id := p_this_level(i).cmpntcost_id;
        ELSE

          /*****************************************************************************
          * In case of update,if cmpntcost_id is supplied skip validations on columns  *
          * of unique key i.e., cmpntcls and alys code If cmpntcost_id is not supplied *
          * then do all validations                                                    *
          *****************************************************************************/
          IF ((p_operation = 'UPDATE')
          AND ((p_this_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
          OR (p_this_level(i).cmpntcost_id IS NOT NULL)))
          THEN
            l_cmpntcost_id := p_this_level(i).cmpntcost_id;
	        ELSE
            /************************************************************************
            * Use cmpntcls_id if sent otherwise use cmpntcls_code, If both are sent *
            * then use only cmpntcls_id and ignore other params and log a message   *
            * If both are not sent then raise error.                                *
            ************************************************************************/
            IF (p_this_level(i).cost_cmpntcls_id <> FND_API.G_MISS_NUM)
            AND (p_this_level(i).cost_cmpntcls_id IS NOT NULL)
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg('validating this level Cmpt Cls ID('||i||') : '|| p_this_level(i).cost_cmpntcls_id);
              END IF;

              /***********************
              * Validate CmpntCls Id *
              ***********************/
              GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (p_this_level(i).cost_cmpntcls_id,l_cost_cmpntcls_code,l_usage_ind);
              IF l_usage_ind IS NULL
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_this_level(i).cost_cmpntcls_id);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF;
              l_cost_cmpntcls_id := p_this_level(i).cost_cmpntcls_id ;
              IF (p_this_level(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR)
              AND (p_this_level(i).cost_cmpntcls_code IS NOT NULL)
              THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN
          	      add_header_to_error_stack(p_header_rec); -- Bug 2659435
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_this_level(i).cost_cmpntcls_code);
                  FND_MSG_PUB.Add;
                END IF;
              END IF;
            ELSIF (p_this_level(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR)
            AND (p_this_level(i).cost_cmpntcls_code IS NOT NULL)
            THEN
              l_cost_cmpntcls_code := p_this_level(i).cost_cmpntcls_code ;
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg('validating this level Cmpt Cls Code('||i||') : ' ||p_this_level(i).cost_cmpntcls_code);
              END IF;

              /*************************
              * Convert value into ID. *
              *************************/
              GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (
                                                              p_this_level(i).cost_cmpntcls_code,
                                                              l_cost_cmpntcls_id,l_usage_ind
                                                              ) ;
              IF l_cost_cmpntcls_id IS NULL
              THEN
            	  add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_this_level(i).cost_cmpntcls_code);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              ELSE
                  IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                    log_msg('Cmpt Cls Id := ' || l_cost_cmpntcls_id);
                  END IF;
              END IF;
            ELSE
              add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;

            /****************
            * Analysis Code *
            ****************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
            	log_msg('validating this level analysis_code('||i||') : ' || p_this_level(i).cost_analysis_code);
            END IF;
            IF (p_this_level(i).cost_analysis_code <> FND_API.G_MISS_CHAR)
            AND (p_this_level(i).cost_analysis_code IS NOT NULL)
            THEN
              IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(p_this_level(i).cost_analysis_code)
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
                FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE',p_this_level(i).cost_analysis_code);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF;
            ELSE
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;
  	      END IF ;
          /******************************************************
          * Enough of validations for delete.                   *
          * For update and insert we should do all validations. *
          ******************************************************/
          IF (p_operation <> 'DELETE')
          THEN

            /*******************************************************************************************************
            * Component Cost, In the form the format mask for this is : 999999999D999999999(999,999,999.999999999) *
            * To put that check here, the cost should not be >= 1,000,000,000                                      *
            *******************************************************************************************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
              log_msg('validating this level Component Cost('||i||') for format : '||p_this_level(i).cmpnt_cost);
            END IF;

            IF (p_this_level(i).cmpnt_cost <> FND_API.G_MISS_NUM)
            AND (p_this_level(i).cmpnt_cost IS NOT NULL)
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg('before cmpnt_cost check for format...');
              END IF;
              IF p_this_level(i).cmpnt_cost >= 1000000000
              THEN
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
                THEN
                	log_msg('before raising the error...');
                END IF;
                add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNT_COST') ;
                FND_MESSAGE.SET_TOKEN('CMPNT_COST',p_this_level(i).cmpnt_cost);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF ;
            ELSIF (p_this_level(i).cmpnt_cost = FND_API.G_MISS_NUM AND p_operation = 'UPDATE')
            OR (p_operation = 'INSERT')
            THEN
              add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNT_COST_REQ');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;

            /************************************************************************************
            * Burden Indicator must be either 0 or 1                                            *
            * If Burden Indicator is 1 then Cost Component Class must have usage indicator = 2. *
            ************************************************************************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
              log_msg('validating this level Burden Indicator('||i||') : '||p_this_level(i).burden_ind);
            END IF;

            IF (p_this_level(i).burden_ind <> FND_API.G_MISS_NUM)
            AND (p_this_level(i).burden_ind IS NOT NULL)
            THEN
              IF (p_this_level(i).burden_ind NOT IN (0,1) )
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_BURDEN_IND');
                FND_MESSAGE.SET_TOKEN('BURDEN_IND',p_this_level(i).burden_ind);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF;
              IF (p_this_level(i).burden_ind = 1) AND ( l_usage_ind <>2 )
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_USAGE_IND');
                FND_MESSAGE.SET_TOKEN('BURDEN_IND',p_this_level(i).burden_ind);
                FND_MESSAGE.SET_TOKEN('CMPNT_CLS',l_cost_cmpntcls_code);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF ;
            ELSIF (p_this_level(i).burden_ind = FND_API.G_MISS_NUM AND p_operation = 'UPDATE')
            OR (p_operation = 'INSERT')
            THEN
              add_header_to_error_stack(p_header_rec); -- Bug 2659435
              FND_MESSAGE.SET_NAME('GMF','GMF_API_BURDEN_IND_REQ');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;

            /************************************************************************************************
            * Raw Material Calculation Type                                                                 *
            * If Cost Method Code =  "Actual Cost" then this field can only have either of 1, 2, 3, 4, OR 5 *
            * otherwise it will be set to 0                                                                 *
            ************************************************************************************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
            	log_msg('validating this level Raw Material Calculation Type('||i||') :'|| p_this_level(i).rmcalc_type);
            END IF;

            IF (p_this_level(i).rmcalc_type <> FND_API.G_MISS_NUM) AND (p_this_level(i).rmcalc_type IS NOT NULL)
            THEN
              IF l_cost_type = 1
              THEN
                IF ((p_this_level(i).rmcalc_type NOT IN (1, 2, 3, 4, 5)) OR (p_this_level(i).rmcalc_type IS NULL))
                THEN
          	      add_header_to_error_stack(p_header_rec);
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_RMCALC_TYPE');
                  FND_MESSAGE.SET_TOKEN('RMCALC_TYPE',p_this_level(i).rmcalc_type);
                  FND_MSG_PUB.Add;
                  RAISE e_this_level;
                ELSE
                  l_rmcalc_type := p_this_level(i).rmcalc_type ;
                END IF;
              ELSE
                l_rmcalc_type := 0 ;
              END IF ;
            END IF ;

            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
            	log_msg('validating this level delete_mark('||i||') :' || p_this_level(i).delete_mark);
            END IF;

            IF (p_this_level(i).delete_mark <> FND_API.G_MISS_NUM)
            AND (p_this_level(i).delete_mark IS NOT NULL)
            THEN
              IF p_this_level(i).delete_mark NOT IN (0,1)
              THEN
                add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
                FND_MESSAGE.SET_TOKEN('DELETE_MARK',p_this_level(i).delete_mark);
                FND_MSG_PUB.Add;
                RAISE e_this_level;
              END IF;
            ELSIF (p_this_level(i).delete_mark = FND_API.G_MISS_NUM AND p_operation = 'UPDATE')
            OR (p_operation = 'INSERT')
            THEN
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;
            IF (p_operation = 'UPDATE') AND (p_this_level(i).delete_mark = 1)
            THEN
              add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
              FND_MSG_PUB.Add;
              RAISE e_this_level;
            END IF;
          END IF ;

          /**********************************************************************************
          * Ignore unique key combination if Cmpntcost_Id is supplied. If not supplied then *
          * query the Cmpntcost_Id. This is done only in case of Update and Delete          *
          **********************************************************************************/
          IF (p_operation IN ('UPDATE','DELETE')
          AND ((p_this_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
          OR (p_this_level(i).cmpntcost_id IS NOT NULL)))
          THEN
            add_header_to_error_stack(p_header_rec);
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_IC_UNIQUE_KEY');
            FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level(i).cmpntcost_id);
            FND_MSG_PUB.Add;
            l_cmpntcost_id := p_this_level(i).cmpntcost_id;
          END IF ;
        END IF ;
        l_idx := l_idx + 1 ;
        x_this_level(l_idx).cmpntcost_id        := l_cmpntcost_id ;
        x_this_level(l_idx).cost_cmpntcls_id    := l_cost_cmpntcls_id ;
        x_this_level(l_idx).cost_cmpntcls_code  := p_this_level(i).cost_cmpntcls_code ;
        x_this_level(l_idx).cost_analysis_code  := p_this_level(i).cost_analysis_code ;
        x_this_level(l_idx).cmpnt_cost          := round(p_this_level(i).cmpnt_cost,9) ;
        x_this_level(l_idx).burden_ind          := p_this_level(i).burden_ind ;
        x_this_level(l_idx).total_qty           := p_this_level(i).total_qty ;
        x_this_level(l_idx).costcalc_orig       := 3 ;  -- insert default value 3 as API Load
        x_this_level(l_idx).rmcalc_type         := l_rmcalc_type ;
        IF p_operation = 'DELETE' THEN
          x_this_level(l_idx).delete_mark       := 1 ;
        ELSE
          x_this_level(l_idx).delete_mark       := 0 ;
        END IF;
        x_this_level(l_idx).attribute1          := p_this_level(i).attribute1 ;
        x_this_level(l_idx).attribute2          := p_this_level(i).attribute2 ;
        x_this_level(l_idx).attribute3          := p_this_level(i).attribute3 ;
        x_this_level(l_idx).attribute4          := p_this_level(i).attribute4 ;
        x_this_level(l_idx).attribute5          := p_this_level(i).attribute5 ;
        x_this_level(l_idx).attribute6          := p_this_level(i).attribute6 ;
        x_this_level(l_idx).attribute7          := p_this_level(i).attribute7 ;
        x_this_level(l_idx).attribute8          := p_this_level(i).attribute8 ;
        x_this_level(l_idx).attribute9          := p_this_level(i).attribute9 ;
        x_this_level(l_idx).attribute10         := p_this_level(i).attribute10 ;
        x_this_level(l_idx).attribute11         := p_this_level(i).attribute11 ;
        x_this_level(l_idx).attribute12         := p_this_level(i).attribute12 ;
        x_this_level(l_idx).attribute13         := p_this_level(i).attribute13 ;
        x_this_level(l_idx).attribute14         := p_this_level(i).attribute14 ;
        x_this_level(l_idx).attribute15         := p_this_level(i).attribute15 ;
        x_this_level(l_idx).attribute16         := p_this_level(i).attribute16 ;
        x_this_level(l_idx).attribute17         := p_this_level(i).attribute17 ;
        x_this_level(l_idx).attribute18         := p_this_level(i).attribute18 ;
        x_this_level(l_idx).attribute19         := p_this_level(i).attribute19 ;
        x_this_level(l_idx).attribute20         := p_this_level(i).attribute20 ;
        x_this_level(l_idx).attribute21         := p_this_level(i).attribute21 ;
        x_this_level(l_idx).attribute22         := p_this_level(i).attribute22 ;
        x_this_level(l_idx).attribute23         := p_this_level(i).attribute23 ;
        x_this_level(l_idx).attribute24         := p_this_level(i).attribute24 ;
        x_this_level(l_idx).attribute25         := p_this_level(i).attribute25 ;
        x_this_level(l_idx).attribute26         := p_this_level(i).attribute26 ;
        x_this_level(l_idx).attribute27         := p_this_level(i).attribute27 ;
        x_this_level(l_idx).attribute28         := p_this_level(i).attribute28 ;
        x_this_level(l_idx).attribute29         := p_this_level(i).attribute29 ;
        x_this_level(l_idx).attribute30         := p_this_level(i).attribute30 ;
        x_this_level(l_idx).attribute_category  := p_this_level(i).attribute_category ;

        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
        THEN
          log_msg('x_cmpntcost_id('||l_idx||'): '||l_cmpntcost_id);
          log_msg('x_cost_cmpntcls_id('||l_idx||'): '|| x_this_level(l_idx).cost_cmpntcls_id);
          log_msg('x_cost_cmpntcls_code('||l_idx||'): '|| x_this_level(l_idx).cost_cmpntcls_code)	;
          log_msg('x_cost_analysis_code('||l_idx||'): '|| x_this_level(l_idx).cost_analysis_code)	;
          log_msg('x_cmpnt_cost('||l_idx||'): '||x_this_level(l_idx).cmpnt_cost);
          log_msg('x_burden_ind('||l_idx||'): '||x_this_level(l_idx).burden_ind);
          log_msg('x_total_qty('||l_idx||'): '||x_this_level(l_idx).total_qty);
          log_msg('x_costcalc_orig('||l_idx||'): '||x_this_level(l_idx).costcalc_orig);
          log_msg('x_delete_mark('||l_idx||'): '||x_this_level(l_idx).delete_mark);
        END IF;
      EXCEPTION
        WHEN e_this_level THEN
          RAISE FND_API.G_EXC_ERROR;
      END ;
    END LOOP;

    /********************************
    * Validate Lower Level Records. *
    ********************************/

    l_idx := 0 ;
    FOR i in 1..p_lower_level.count
    LOOP
      BEGIN
        l_cost_cmpntcls_id   := '' ;
        l_cost_cmpntcls_code := '' ;
        l_cmpntcost_id       := '' ;
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
        THEN
          log_msg('Lower Level Record # : ' || i);
        END IF;

        /******************************************************************************
        * In case of delete, if cmpntcost_id is supplied skip all validations and use *
        * cmpntcost_id to delete the records, if cmpntcost_id is not supplied then    *
        * do validations on all unique key columns only                               *
        ******************************************************************************/
        IF ((p_operation = 'DELETE')
        AND ((p_lower_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
        OR (p_lower_level(i).cmpntcost_id IS NOT NULL)))
        THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_IC_UNIQUE_KEY');
          FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level(i).cmpntcost_id);
          FND_MSG_PUB.Add;
          l_cmpntcost_id := p_lower_level(i).cmpntcost_id;
        ELSE
          IF ((p_operation = 'UPDATE')
          AND ((p_lower_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
          OR (p_lower_level(i).cmpntcost_id IS NOT NULL)))
          THEN
            l_cmpntcost_id := p_lower_level(i).cmpntcost_id;
	        ELSE
            /***************************************************************************************
            * Use cmpntcls_id if sent otherwise use cmpntcls_code                                  *
            * If both are sent then use only cmpntcls_id and ignore other params and log a message *
            * If both are not sent then raise error.                                               *
            ***************************************************************************************/
            IF (p_lower_level(i).cost_cmpntcls_id <> FND_API.G_MISS_NUM)
            AND (p_lower_level(i).cost_cmpntcls_id IS NOT NULL)
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg('validating lower level Cmpt Cls ID('||i||') :'|| p_lower_level(i).cost_cmpntcls_id);
              END IF;
              IF NOT GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Id (p_lower_level(i).cost_cmpntcls_id)
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_ID');
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID',p_lower_level(i).cost_cmpntcls_id);
                FND_MSG_PUB.Add;
                RAISE e_lower_level;
              END IF;
              l_cost_cmpntcls_id := p_lower_level(i).cost_cmpntcls_id ;

              /***************************************************
              * Log message if cost_cmpntcls_code is also passed *
              ***************************************************/
              IF (p_lower_level(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR)
              AND (p_lower_level(i).cost_cmpntcls_code IS NOT NULL)
              THEN
                IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                THEN
          	      add_header_to_error_stack(p_header_rec);
                  FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_CMPNTCLS_CODE');
                  FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_lower_level(i).cost_cmpntcls_code);
                  FND_MSG_PUB.Add;
                END IF;
              END IF;
            ELSIF (p_lower_level(i).cost_cmpntcls_code <> FND_API.G_MISS_CHAR)
            AND (p_lower_level(i).cost_cmpntcls_code IS NOT NULL)
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg('validating lower level Cmpt Cls Code('||i||') : ' ||p_lower_level(i).cost_cmpntcls_code);
              END IF;
              l_cost_cmpntcls_id := GMF_VALIDATIONS_PVT.Validate_Cost_Cmpntcls_Code (p_lower_level(i).cost_cmpntcls_code);
              IF l_cost_cmpntcls_id IS NULL THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNTCLS_CODE');
                FND_MESSAGE.SET_TOKEN('CMPNTCLS_CODE',p_lower_level(i).cost_cmpntcls_code);
                FND_MSG_PUB.Add;
                RAISE e_lower_level;
              ELSE
                 IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level THEN
                    log_msg('Cmpt Cls Id := ' || l_cost_cmpntcls_id);
                  END IF;
              END IF;
            ELSE
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNTCLS_ID_REQ');
              FND_MSG_PUB.Add;
              RAISE e_lower_level;
            END IF;

            /***************************
            * Validating Analysis Code *
            ***************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
              log_msg('validating lower level analysis_code('||i||') :' || p_lower_level(i).cost_analysis_code);
            END IF;

            IF (p_lower_level(i).cost_analysis_code <> FND_API.G_MISS_CHAR)
            AND (p_lower_level(i).cost_analysis_code IS NOT NULL)
            THEN
              IF NOT GMF_VALIDATIONS_PVT.Validate_Analysis_Code(p_lower_level(i).cost_analysis_code)
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ANALYSIS_CODE');
                FND_MESSAGE.SET_TOKEN('ANALYSIS_CODE',p_lower_level(i).cost_analysis_code);
                FND_MSG_PUB.Add;
                RAISE e_lower_level;
              END IF;
            ELSE
              add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_ANALYSIS_CODE_REQ');
              FND_MSG_PUB.Add;
              RAISE e_lower_level;
            END IF;
          END IF;

          /******************************************************
          * Enough of validations for delete.                   *
          * For update and insert we should do all validations. *
          ******************************************************/
          IF (p_operation <> 'DELETE')
          THEN

            /***************************************************************************************
            * Component Cost                                                                       *
            * In the form the format mask for this is : 999999999D999999999(999,999,999.999999999) *
            * To put that check here, the cost should not be >= 1,000,000,000                      *
            ***************************************************************************************/
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
              log_msg('validating lower level Component Cost('||i||') for format : '||p_lower_level(i).cmpnt_cost);
            END IF;
            IF (p_lower_level(i).cmpnt_cost <> FND_API.G_MISS_NUM)
            AND (p_lower_level(i).cmpnt_cost IS NOT NULL)
            THEN
              IF p_lower_level(i).cmpnt_cost >= 1000000000
              THEN
                IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
                THEN
                  log_msg('before raising the error...');
                END IF;
                add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_CMPNT_COST') ;
                FND_MESSAGE.SET_TOKEN('CMPNT_COST',p_lower_level(i).cmpnt_cost);
                FND_MSG_PUB.Add;
                RAISE e_lower_level;
              END IF ;
            ELSIF (p_lower_level(i).cmpnt_cost = FND_API.G_MISS_NUM AND p_operation = 'UPDATE')
            OR (p_operation = 'INSERT')
            THEN
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CMPNT_COST_REQ');
              FND_MSG_PUB.Add;
              RAISE e_lower_level;
            END IF;
            IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
            THEN
         	    log_msg('validating lower level delete_mark('||i||') :' || p_lower_level(i).delete_mark);
            END IF;
            IF (p_lower_level(i).delete_mark <> FND_API.G_MISS_NUM)
            AND (p_lower_level(i).delete_mark IS NOT NULL)
            THEN
              IF p_lower_level(i).delete_mark NOT IN (0,1)
              THEN
          	    add_header_to_error_stack(p_header_rec);
                FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_DELETE_MARK');
                FND_MESSAGE.SET_TOKEN('DELETE_MARK',p_lower_level(i).delete_mark);
                FND_MSG_PUB.Add;
                RAISE e_lower_level;
              END IF;
            ELSIF (p_lower_level(i).delete_mark = FND_API.G_MISS_NUM AND p_operation = 'UPDATE')
            OR (p_operation = 'INSERT')
            THEN
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DELETE_MARK_REQ');
              FND_MSG_PUB.Add;
              RAISE e_lower_level;
            END IF;
            IF (p_operation = 'UPDATE') AND (p_lower_level(i).delete_mark = 1)
            THEN
          	  add_header_to_error_stack(p_header_rec);
              FND_MESSAGE.SET_NAME('GMF','GMF_API_CANT_MARK_FOR_PURGE');
              FND_MSG_PUB.Add;
              RAISE e_lower_level;
            END IF;
          END IF ;

          /**********************************************************************************
          * Ignore unique key combination if Cmpntcost_Id is supplied. If not supplied then *
          * query the Cmpntcost_Id. This is done only in case of Update and Delete          *
          **********************************************************************************/
          IF (p_operation IN ('UPDATE','DELETE')
          AND ((p_lower_level(i).cmpntcost_id <> FND_API.G_MISS_NUM)
          OR (p_lower_level(i).cmpntcost_id IS NOT NULL)))
          THEN
            add_header_to_error_stack(p_header_rec);
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_IC_UNIQUE_KEY');
            FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level(i).cmpntcost_id);
            FND_MSG_PUB.Add;
            l_cmpntcost_id := p_lower_level(i).cmpntcost_id;
          END IF ;
        END IF ;
        l_idx := l_idx + 1 ;
        x_lower_level(l_idx).cmpntcost_id        := l_cmpntcost_id ;
        x_lower_level(l_idx).cost_cmpntcls_id    := l_cost_cmpntcls_id ;
        x_lower_level(l_idx).cost_cmpntcls_code  := p_lower_level(i).cost_cmpntcls_code ;
        x_lower_level(l_idx).cost_analysis_code  := p_lower_level(i).cost_analysis_code ;
        x_lower_level(l_idx).cmpnt_cost          := round(p_lower_level(i).cmpnt_cost,9) ;
        IF p_operation = 'DELETE' THEN
          x_lower_level(l_idx).delete_mark       := 1 ;
        ELSE
          x_lower_level(l_idx).delete_mark       := 0 ;
        END IF;
        IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
        THEN
          log_msg('x_cmpntcost_id('||l_idx||'): '||l_cmpntcost_id);
          log_msg('x_cost_cmpntcls_id('||l_idx||'): ' || x_lower_level(l_idx).cost_cmpntcls_id);
          log_msg('x_cost_cmpntcls_code('||l_idx||'): ' || x_lower_level(l_idx).cost_cmpntcls_code);
          log_msg('x_cost_analysis_code('||l_idx||'): ' || x_lower_level(l_idx).cost_analysis_code);
          log_msg('x_cmpnt_cost('||l_idx||'): '||x_lower_level(l_idx).cmpnt_cost);
          log_msg('x_delete_mark('||l_idx||'): '||x_lower_level(l_idx).delete_mark);
        END IF;
      EXCEPTION
        WHEN e_lower_level THEN
          RAISE FND_API.G_EXC_ERROR ;
      END ;
    END LOOP;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  END VALIDATE_INPUT_PARAMS ;

--Start of comments
--+========================================================================+
--| API Name	: Create_Item_Cost                                         |
--| TYPE	: Public                                           	   |
--| Function	: Creates a new Item Cost based on the input into table    |
--|		  CM_CMPT_DTL                                              |
--| Pre-reqa	: None.                                                    |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|		  p_api_version         IN  NUMBER       - Required        |
--|		  p_init_msg_list       IN  VARCHAR2     - Optional        |
--|		  p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Header_Rec_Type                |
--|               p_this_level_dtl_tbl  IN  This_Level_Dtl_Tbl_Type        |
--|               p_lower_level_dtl_Tbl IN  Lower_Level_Dtl_Tbl_Type       |
--| OUT		:                                                          |
--|		  x_return_status    OUT VARCHAR2                          |
--|		  x_msg_count        OUT NUMBER                            |
--|		  x_msg_data         OUT VARCHAR2                          |
--|               x_costcmpnt_ids    OUT costcmpnt_ids_tbl_type            |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 3.0                              |
--|	  	  Previous Version	: 2.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Create_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type,
  x_costcmpnt_ids	          OUT NOCOPY  costcmpnt_ids_tbl_type
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name		      CONSTANT        VARCHAR2(30)	:= 'Create_Item_Cost' ;
	  l_api_version       CONSTANT        NUMBER		:= 3.0 ;
    l_header_rec          	            Header_Rec_Type ;
    l_this_level_dtl_tbl  	            This_Level_Dtl_Tbl_Type ;
    l_lower_level_dtl_Tbl 	            Lower_Level_Dtl_Tbl_Type ;
    l_costcmpnt_ids_tbl                 costcmpnt_ids_tbl_type ;
	  l_cost_type                         cm_mthd_mst.cost_type%TYPE ;
    l_user_id              	            fnd_user.user_id%TYPE ;
	  l_return_status        	            VARCHAR2(2) ;
	  l_count		       	                  NUMBER(10) ;
	  l_data                 	            VARCHAR2(2000) ;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 CREATE_ITEM_COST_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
	    FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Create Item Cost process.');
    END IF;

    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('In public API. This level Count : ' || p_this_level_dtl_tbl.count);
    	log_msg('In public API. Lower level Count : ' || p_lower_level_dtl_tbl.count);
    END IF;

    IF ((p_this_level_dtl_tbl.count > 0) OR (p_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
      	log_msg('Validating  input parameters');
      END IF;

      /*************************************
      * Validate all the input parameters. *
      *************************************/
      Validate_Input_Params
      (
      p_header_rec        =>      p_header_rec,
      p_this_level        =>      p_this_level_dtl_tbl,
      p_lower_level       =>      p_lower_level_dtl_tbl,
      p_operation         =>      'INSERT',
      x_header_rec        =>      l_header_rec,
      x_this_level        =>      l_this_level_dtl_tbl,
      x_lower_level       =>      l_lower_level_dtl_tbl,
      x_user_id           =>      l_user_id,
      x_return_status     =>      l_return_status
      );

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
    	  log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      /*****************************************
      * Return if validation failures detected *
      *****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF ((l_this_level_dtl_tbl.count > 0) OR (l_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Calling private API to insert record...');
      END IF;
      GMF_ITEMCOST_PVT.CREATE_ITEM_COST
      (
      p_api_version		    =>        3.0,
      p_init_msg_list	    =>        FND_API.G_FALSE,
      p_commit            =>        FND_API.G_FALSE,
      x_return_status	    =>        l_return_status,
      x_msg_count		      =>        l_count,
      x_msg_data		      =>        l_data,
      p_header_rec		    =>        l_header_rec,
      p_this_level_dtl_tbl=>        l_this_level_dtl_tbl,
      p_lower_level_dtl_Tbl=>       l_lower_level_dtl_tbl,
      p_user_id		        =>        l_user_id,
      x_costcmpnt_ids	    =>        x_costcmpnt_ids
      );

      /****************************************
      * Return if insert fails for any reason *
      ****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(l_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(l_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      add_header_to_error_stack(l_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_INS');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',x_costcmpnt_ids.count);
      FND_MSG_PUB.Add;
    ELSE
      add_header_to_error_stack(l_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_INS');
      FND_MSG_PUB.Add;
    END IF ;
    /******************************
    * Standard check of p_commit. *
    ******************************/
    IF FND_API.To_Boolean( p_commit )
    THEN
	    COMMIT WORK;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get
  	(
    p_count		        =>          x_msg_count,
    p_data		        =>          x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO  CREATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO  CREATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN OTHERS THEN
	    ROLLBACK TO  CREATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg (	G_PKG_NAME, l_api_name);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
  END CREATE_ITEM_COST;

--Start of comments
--+========================================================================+
--| API Name    : Update_Item_Cost                                         |
--| TYPE        : Public                                                   |
--| Function    : Updates Item Cost based on the input into CM_CMPT_DTL    |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN		:                                                          |
--|		  p_api_version         IN  NUMBER       - Required        |
--|		  p_init_msg_list       IN  VARCHAR2     - Optional        |
--|		  p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Header_Rec_Type                |
--|               p_this_level_dtl_tbl  IN  This_Level_Dtl_Tbl_Type        |
--|               p_lower_level_dtl_Tbl IN  Lower_Level_Dtl_Tbl_Type       |
--| OUT		:                                                          |
--|		  x_return_status       OUT VARCHAR2                       |
--|		  x_msg_count           OUT NUMBER                         |
--|		  x_msg_data            OUT VARCHAR2                       |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 3.0                              |
--|               Previous Version      : 2.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Update_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type
  )
  IS

    /******************
    * Local Variables *
    ******************/
	  l_api_name              CONSTANT    VARCHAR2(30)   := 'Update_Item_Cost' ;
    l_api_version           CONSTANT    NUMBER         := 3.0 ;
    l_header_rec                        Header_Rec_Type ;
    l_this_level_dtl_tbl                This_Level_Dtl_Tbl_Type ;
    l_lower_level_dtl_Tbl               Lower_Level_Dtl_Tbl_Type ;
	  l_cost_type                         cm_mthd_mst.cost_type%TYPE ;
    l_user_id                           fnd_user.user_id%TYPE ;
    l_return_status                     VARCHAR2(2) ;
    l_count                             NUMBER(10) ;
    l_data                              VARCHAR2(2000) ;
	  l_no_rows_upd                       NUMBER(10) ;

BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 UPDATE_ITEM_COST_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
	    FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Update Item Cost process.');
    END IF;

    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('In public API. This level Count : ' || p_this_level_dtl_tbl.count);
    	log_msg('In public API. Lower level Count : ' || p_lower_level_dtl_tbl.count);
    END IF;

    IF ((p_this_level_dtl_tbl.count > 0) OR (p_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
      	log_msg('Validating  input parameters');
      END IF;

      /*************************************
      * Validate all the input parameters. *
      *************************************/
      Validate_Input_Params
      (
      p_header_rec        =>      p_header_rec,
      p_this_level        =>      p_this_level_dtl_tbl,
      p_lower_level       =>      p_lower_level_dtl_tbl,
      p_operation         =>      'UPDATE',
      x_header_rec        =>      l_header_rec,
      x_this_level        =>      l_this_level_dtl_tbl,
      x_lower_level       =>      l_lower_level_dtl_tbl,
      x_user_id           =>      l_user_id,
      x_return_status     =>      l_return_status
      );
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
    	  log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      /*****************************************
      * Return if validation failures detected *
      *****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF ((l_this_level_dtl_tbl.count > 0) OR (l_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
      	log_msg('Calling private API to update records...');
      END IF;
      GMF_ITEMCOST_PVT.UPDATE_ITEM_COST
      (
      p_api_version		    =>        3.0,
      p_init_msg_list	    =>        FND_API.G_FALSE,
      p_commit            =>        FND_API.G_FALSE,
      x_return_status	    =>        l_return_status,
      x_msg_count		      =>        l_count,
      x_msg_data		      =>        l_data,
      p_header_rec		    =>        l_header_rec,
      p_this_level_dtl_tbl=>        l_this_level_dtl_tbl,
      p_lower_level_dtl_Tbl=>       l_lower_level_dtl_tbl,
      p_user_id		        =>        l_user_id
      );
      /****************************************
      * Return if insert fails for any reason *
      ****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_UPD');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_this_level_dtl_tbl.count+l_lower_level_dtl_tbl.count);
      FND_MSG_PUB.Add;
    ELSE
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_UPD');
      FND_MSG_PUB.Add;
    END IF ;

    /******************************
    * Standard check of p_commit. *
    ******************************/
    IF FND_API.To_Boolean( p_commit )
    THEN
	    COMMIT WORK;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get
  	(
    p_count		        =>          x_msg_count,
    p_data		        =>          x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO  UPDATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO  UPDATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN OTHERS THEN
	    ROLLBACK TO  UPDATE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg (	G_PKG_NAME, l_api_name);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
  END UPDATE_ITEM_COST ;

--Start of comments
--+========================================================================+
--| API Name    : Delete_Item_Cost                                         |
--| TYPE        : Public                                                   |
--| Function    : Deletes Item Cost based on the input from CM_CMPT_DTL    |
--| Pre-reqa    : None.                                                    |
--| Parameters  :                                                          |
--| IN          :                                                          |
--|               p_api_version         IN  NUMBER       - Required        |
--|               p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_commit              IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Header_Rec_Type                |
--|               p_this_level_dtl_tbl  IN  This_Level_Dtl_Tbl_Type        |
--|               p_lower_level_dtl_Tbl IN  Lower_Level_Dtl_Tbl_Type       |
--| OUT         :                                                          |
--|               x_return_status       OUT VARCHAR2                       |
--|               x_msg_count           OUT NUMBER                         |
--|               x_msg_data            OUT VARCHAR2                       |
--|                                                                        |
--| Version     :                                                          |
--|               Current Version       : 3.0                              |
--|               Previous Version      : 2.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Delete_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type
  )
  IS

    /******************
    * Local Variables *
    ******************/
	  l_api_name              CONSTANT    VARCHAR2(30)   := 'Delete_Item_Cost' ;
	  l_api_version           CONSTANT    NUMBER         := 3.0 ;
    l_header_rec                        Header_Rec_Type ;
    l_this_level_dtl_tbl                This_Level_Dtl_Tbl_Type ;
    l_lower_level_dtl_Tbl               Lower_Level_Dtl_Tbl_Type ;
    l_user_id                           fnd_user.user_id%TYPE ;
    l_return_status                     VARCHAR2(2) ;
    l_count                             NUMBER(10) ;
    l_data                              VARCHAR2(2000) ;
    l_no_rows_del                       NUMBER(10) ;
  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 DELETE_ITEM_COST_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
	    FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Delete Item Cost process.');
    END IF;

    G_header_logged := 'N';

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('In public API. This level Count : ' || p_this_level_dtl_tbl.count);
    	log_msg('In public API. Lower level Count : ' || p_lower_level_dtl_tbl.count);
    END IF;

    IF ((p_this_level_dtl_tbl.count > 0) OR (p_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
      	log_msg('Validating  input parameters');
      END IF;

      /*************************************
      * Validate all the input parameters. *
      *************************************/
      Validate_Input_Params
      (
      p_header_rec        =>      p_header_rec,
      p_this_level        =>      p_this_level_dtl_tbl,
      p_lower_level       =>      p_lower_level_dtl_tbl,
      p_operation         =>      'DELETE',
      x_header_rec        =>      l_header_rec,
      x_this_level        =>      l_this_level_dtl_tbl,
      x_lower_level       =>      l_lower_level_dtl_tbl,
      x_user_id           =>      l_user_id,
      x_return_status     =>      l_return_status
      );

      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
    	  log_msg('Return Status after validating : ' || l_return_status);
      END IF;

      /*****************************************
      * Return if validation failures detected *
      *****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF ((l_this_level_dtl_tbl.count > 0) OR (l_lower_level_dtl_tbl.count > 0))
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
      	log_msg('Calling private API to delete records...');
      END IF;

      GMF_ITEMCOST_PVT.UPDATE_ITEM_COST
      (
      p_api_version	              =>              3.0,
      p_init_msg_list	            =>              FND_API.G_FALSE,
      p_commit                    =>              FND_API.G_FALSE,
      x_return_status	            =>              l_return_status,
      x_msg_count		              =>              l_count,
      x_msg_data		              =>              l_data,
      p_header_rec		            =>              l_header_rec,
      p_this_level_dtl_tbl	      =>              l_this_level_dtl_tbl,
      p_lower_level_dtl_Tbl	      =>              l_lower_level_dtl_tbl,
      p_user_id		                =>              l_user_id
      );

      /****************************************
      * Return if update fails for any reason *
      ****************************************/
      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ROWS_DEL');
      FND_MESSAGE.SET_TOKEN('NUM_ROWS',l_this_level_dtl_tbl.count+l_lower_level_dtl_tbl.count);
      FND_MSG_PUB.Add;
    ELSE
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_NO_ROWS_DEL');
      FND_MSG_PUB.Add;
    END IF ;

    /******************************
    * Standard check of p_commit. *
    ******************************/
    IF FND_API.To_Boolean( p_commit )
    THEN
	    COMMIT WORK;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get
  	(
    p_count		        =>          x_msg_count,
    p_data		        =>          x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO  DELETE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO  DELETE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN OTHERS THEN
	    ROLLBACK TO  DELETE_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg (	G_PKG_NAME, l_api_name);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
  END DELETE_ITEM_COST ;

--Start of comments
--+========================================================================+
--| API Name	: Get_Item_Cost                                            |
--| TYPE	: Public                                           	   |
--| Function	: Retrieve Item Cost based on the input from table         |
--|		  CM_CMPT_DTL                                              |
--| Pre-reqa	: None.                                                    |
--| Parameters	:                                                          |
--| IN		:                                                          |
--|		  p_api_version         IN  NUMBER       - Required        |
--|		  p_init_msg_list       IN  VARCHAR2     - Optional        |
--|               p_header_rec          IN  Header_Rec_Type                |
--|               x_this_level_dtl_tbl  IN  This_Level_Dtl_Tbl_Type        |
--|               x_lower_level_dtl_Tbl IN  Lower_Level_Dtl_Tbl_Type       |
--| OUT		:                                                          |
--|		  x_return_status    OUT VARCHAR2                          |
--|		  x_msg_count        OUT NUMBER                            |
--|		  x_msg_data         OUT VARCHAR2                          |
--|                                                                        |
--| Version	:                                                          |
--|	 	  Current Version	: 3.0                              |
--|	  	  Previous Version	: 2.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 26-Apr-01     Uday Moogala - Created                                   |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Get_Item_Cost
  (
  p_api_version             IN              NUMBER,
  p_init_msg_list           IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  p_header_rec              IN              Header_Rec_Type,
  x_this_level_dtl_tbl          OUT NOCOPY  This_Level_Dtl_Tbl_Type,
  x_lower_level_dtl_Tbl         OUT NOCOPY  Lower_Level_Dtl_Tbl_Type
  )
  IS

    /******************
    * Local Variables *
    ******************/
	  l_api_name                  CONSTANT    VARCHAR2(30)   := 'Delete_Item_Cost' ;
	  l_api_version               CONSTANT    NUMBER         := 3.0 ;
    l_return_status                         VARCHAR2(2) ;
    l_count                                 NUMBER(10) ;
    l_data                                  VARCHAR2(2000) ;
    l_header_rec		                        Header_Rec_Type ;
    l_period_status                         gmf_period_statuses.period_status%TYPE ;
    l_cost_type                             cm_mthd_mst.cost_type%TYPE ;
    l_rmcalc_type                           cm_cmpt_dtl.rmcalc_type%TYPE ;
    l_prodcalc_type                         cm_mthd_mst.prodcalc_type%TYPE ;
    l_user_id              	                fnd_user.user_id%TYPE ;

  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 GET_ITEM_COST_PUB ;

    /*************************************************************
    * Initialize message list if p_init_msg_list is set to TRUE. *
    *************************************************************/
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
	    FND_MSG_PUB.initialize;
    END IF;

    /*************************************************
    * Standard call to check for call compatibility. *
    *************************************************/
    IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Get Item Cost API.');
    END IF;

    G_header_logged := 'N';

    /**************************
    * Organization Validation *
    **************************/
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Validating Organization Id :' || p_header_rec.Organization_id);
    END IF;
    IF (p_header_rec.organization_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.organization_id IS NOT NULL)
    THEN
      IF NOT GMF_VALIDATIONS_PVT.Validate_organization_id(p_header_rec.organization_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_ID');
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.organization_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF (p_header_rec.organization_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.organization_code IS NOT NULL)
      THEN
        l_header_rec.organization_id := GMF_VALIDATIONS_PVT.Validate_organization_Code(p_header_rec.organization_code);
        IF l_header_rec.organization_id IS NULL
        THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ORGN_CODE');
          FND_MESSAGE.SET_TOKEN('ORG_CODE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_ORGANIZATION_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    /***********************
    * Cost TYPE Validation *
    ***********************/
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Validating Cost type Id : ' || p_header_rec.cost_type_id);
    END IF;
    IF (p_header_rec.cost_type_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.cost_type_id IS NOT NULL)
    THEN
      IF NOT GMF_VALIDATIONS_PVT.Validate_Cost_type_id(p_header_rec.cost_type_id) THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE_ID');
        FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_COST_TYPE');
          FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.organization_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF (p_header_rec.cost_mthd_code <> FND_API.G_MISS_CHAR)
      AND (p_header_rec.cost_mthd_code IS NOT NULL)
      THEN
        l_header_rec.cost_type_id := GMF_VALIDATIONS_PVT.Validate_Cost_type_Code(p_header_rec.cost_mthd_code);
        IF l_header_rec.cost_type_id IS NULL THEN
          add_header_to_error_stack(p_header_rec);
          FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_COST_TYPE');
          FND_MESSAGE.SET_TOKEN('COST_TYPE',p_header_rec.cost_mthd_code);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_COST_TYPE_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    /***********************
    * Period Id Validation *
    ***********************/
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
      log_msg('validating Period Id : ' || p_header_rec.period_id);
    END IF;

    IF (p_header_rec.period_id <> FND_API.G_MISS_NUM)
    AND (p_header_rec.period_id IS NOT NULL)
    THEN
      IF NOT GMF_VALIDATIONS_PVT.Validate_period_id(p_header_rec.period_id)
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_PERIOD_ID');
        FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_PERIOD_CODE');
          FND_MESSAGE.SET_TOKEN('CALENDAR_CODE',p_header_rec.calendar_code);
          FND_MESSAGE.SET_TOKEN('PERIOD_CODE',p_header_rec.period_code);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSE
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Calendar Code : '|| p_header_rec.Calendar_code||' period_code : ' || p_header_rec.period_code);
      END IF;

      IF ((p_header_rec.calendar_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.calendar_code IS NOT NULL))
      AND ((p_header_rec.period_code <> FND_API.G_MISS_CHAR) AND (p_header_rec.period_code IS NOT NULL))
      THEN
        l_header_rec.period_id := GMF_VALIDATIONS_PVT.Validate_Period_code(p_header_rec.organization_id, p_header_rec.calendar_code,p_header_rec.period_code,p_header_rec.cost_type_id);
      ELSE
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_PERIOD_ID_REQ');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    /******************
    * Item Validation *
    ******************/
    IF (p_header_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND	(p_header_rec.inventory_item_id IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Inventory Item Id : ' || p_header_rec.inventory_item_id);
      END IF;
      IF NOT GMF_VALIDATIONS_PVT.Validate_inventory_item_Id(p_header_rec.inventory_item_id, p_header_rec.organization_id)
      THEN
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_ID');
        FND_MESSAGE.SET_TOKEN('ITEM_ID', p_header_rec.inventory_item_id);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
      THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_IGNORE_ITEM_NO');
          FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
          FND_MSG_PUB.Add;
        END IF;
      END IF;
    ELSIF (p_header_rec.item_number <> FND_API.G_MISS_CHAR) AND (p_header_rec.item_number IS NOT NULL)
    THEN
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Validating Item Number : ' || p_header_rec.item_number);
      END IF;
      l_header_rec.inventory_item_id := GMF_VALIDATIONS_PVT.Validate_Item_Number(p_header_rec.item_number, p_header_Rec.organization_id);
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg('Inventory Item id : ' || p_header_rec.inventory_item_id);
      END IF;
      IF l_header_rec.inventory_item_id IS NULL
      THEN
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_ITEM_NO');
        FND_MESSAGE.SET_TOKEN('ITEM_NO',p_header_rec.item_number);
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      FND_MESSAGE.SET_NAME('GMF','GMF_API_ITEM_ID_REQ');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /***********************
    * User Name Validation *
    ***********************/
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
      log_msg('Validating user name : ' || p_header_rec.user_name);
    END IF;

    IF (p_header_rec.user_name <> FND_API.G_MISS_CHAR)
    AND (p_header_rec.user_name IS NOT NULL)
    THEN
      GMA_GLOBAL_GRP.Get_who( p_user_name  => p_header_rec.user_name, x_user_id  => l_user_id);
      IF l_user_id = -1
      THEN
        add_header_to_error_stack(p_header_rec);
        FND_MESSAGE.SET_NAME('GMF','GMF_API_INVALID_USER_NAME');
        FND_MESSAGE.SET_TOKEN('USER_NAME',p_header_rec.user_name);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    	END IF;
    ELSE
      add_header_to_error_stack(p_header_rec);
      FND_MESSAGE.SET_NAME('GMF','GMF_API_USER_NAME_REQ');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_header_rec.period_id   := nvl(p_header_rec.period_id, l_header_rec.period_id);
    l_header_rec.cost_type_id  := nvl(p_header_rec.cost_type_id, l_header_rec.cost_type_id);
    l_header_rec.organization_id       := nvl(p_header_rec.organization_id, l_header_rec.organization_id);
    l_header_rec.inventory_item_id       := nvl(p_header_rec.inventory_item_id, l_header_rec.inventory_item_id);

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Calling private API to fetch records...');
    END IF;

    GMF_ITEMCOST_PVT.GET_ITEM_COST
    (
    p_api_version                 =>        3.0,
    p_init_msg_list               =>        FND_API.G_FALSE,
    x_return_status               =>        l_return_status,
    x_msg_count                   =>        l_count,
    x_msg_data                    =>        l_data,
    p_header_rec                  =>        l_header_rec,
    x_this_level_dtl_tbl          =>        x_this_level_dtl_tbl,
    x_lower_level_dtl_Tbl         =>        x_lower_level_dtl_Tbl
    );

    /****************************************
    * Return if update fails for any reason *
    ****************************************/
    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get
  	(
    p_count		        =>          x_msg_count,
    p_data		        =>          x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO  GET_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO  GET_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
    WHEN OTHERS THEN
	    ROLLBACK TO  GET_ITEM_COST_PUB;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg (	G_PKG_NAME, l_api_name);
	    END IF;
	    FND_MSG_PUB.Count_And_Get
    	(
      p_count		        =>          x_msg_count,
      p_data		        =>          x_msg_data
      );
  END GET_ITEM_COST;

END GMF_ITEMCOST_PUB;

/
