--------------------------------------------------------
--  DDL for Package Body GMF_ITEMCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ITEMCOST_PVT" AS
/* $Header: GMFVCSTB.pls 120.3.12010000.2 2009/04/16 20:51:45 uphadtar ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFVCSTB.pls                                        |
--| Package Name       : GMF_ItemCost_PVT                                    |
--| API name           : GMF_ItemCost_PVT                                    |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : Item Cost creation, updatation and deletion.        |
--|                                                                          |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 2.0                                                 |
--| Previous Vers      : 1.0                                                 |
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
--| HISTORY                                                                  |
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
--|                                                                          |
--|    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint              |
--|    05/NOV/2002  Uday Moogala  Bug# 2659435                               |
--|      Performance related fixes. 					     |
--|	 1. remove G_MISS_xxx assignments.				     |
--|	 2. Conditionally calling debug routine.                             |
--|	 Also, fixed issues found during unit testing. Search for the bug    |
--|	 number to find the fixes.               			     |
--|    24/DEC/2002  Uday Moogala  Bug# 2722404                               |
--|      Removed creation_date and created_by from update stmts. 	     |
--|  16-APR-2009 Uday Phadtare Bug 7631080.                                  |
--|    Code modified in PROCEDURE Get_Item_Cost. Joined cm_cmpt_mst and      |
--|    cm_cmpt_dtl tables to avoid cartesian product.                        |
--+==========================================================================+
-- End of comments

  /*******************
  * Global variables *
  *******************/
  G_PKG_NAME            CONSTANT        VARCHAR2(30) := 'GMF_ItemCost_PVT';
  G_debug_level                         NUMBER(2) := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere to decide to log a debug msg.

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
--|                                                                          |
--+==========================================================================+
-- Func end of comments

  PROCEDURE log_msg
  (
  p_msg_text            IN              VARCHAR2
  )
  IS
  BEGIN
    FND_MESSAGE.SET_NAME('GMF','GMF_API_DEBUG');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;
  END log_msg ;
--
-- Func start of comments
--+==========================================================================+
--|  Function Name                                                           |
--|       check_records_exist                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This procedure checks for the existance of records for a given     |
--|       organization, inventory item id, period id, cost method            |
--|       cost component class analysis code and cost level                  |
--|  USAGE                                                                   |
--|       In case of insert API, if record exists raise error.               |
--|       In case of update/delete API, if record does not exists raise error|
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_organization_id                                                  |
--|       p_inventory_item_id                                                |
--|       p_period_id                                                        |
--|       p_cost_type_id                                                     |
--|       p_cost_cmpntcls_id                                                 |
--|       p_cost_analysis_code                                               |
--|       p_cost_level                                                       |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE : If records exist                                            |
--|       FALSE : If records does not exist                                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|   10-may-07 pmarada - created, bug 5586406                               |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION check_records_exist
(
   p_organization_id   IN cm_cmpt_dtl.organization_id%TYPE,
   p_inventory_item_id IN cm_cmpt_dtl.inventory_item_id%TYPE,
   p_period_id         IN cm_cmpt_dtl.period_id%TYPE,
   p_cost_type_id      IN cm_cmpt_dtl.cost_type_id%TYPE ,
   p_cost_cmpntcls_id  IN cm_cmpt_dtl.cost_cmpntcls_id%TYPE,
   p_cost_analysis_code IN cm_cmpt_dtl.cost_analysis_code%TYPE,
   p_cost_level         IN cm_cmpt_dtl.cost_level%TYPE
)
RETURN BOOLEAN IS


    CURSOR Cur_cmpt_dtl
           ( cp_organization_id   cm_cmpt_dtl.organization_id%TYPE,
             cp_inventory_item_id cm_cmpt_dtl.inventory_item_id%TYPE,
             cp_period_id         cm_cmpt_dtl.period_id%TYPE,
             cp_cost_type_id      cm_cmpt_dtl.cost_type_id%TYPE ,
             cp_cost_cmpntcls_id  cm_cmpt_dtl.cost_cmpntcls_id%TYPE,
             cp_cost_analysis_code cm_cmpt_dtl.cost_analysis_code%TYPE,
             cp_cost_level         cm_cmpt_dtl.cost_level%TYPE
           )
    IS
    SELECT 'x'
      FROM cm_cmpt_dtl
     WHERE organization_id   = cp_organization_id
       AND inventory_item_id = cp_inventory_item_id
       AND period_id         = cp_period_id
       AND cost_type_id      = cp_cost_type_id
       AND cost_cmpntcls_id  = cp_cost_cmpntcls_id
       AND cost_analysis_code= cp_cost_analysis_code
       AND cost_level        = cp_cost_level;

      l_rec_found VARCHAR2(10);
BEGIN

   l_rec_found := NULL;
  OPEN Cur_cmpt_dtl(p_organization_id, p_inventory_item_id, p_period_id,
                      p_cost_type_id, p_cost_cmpntcls_id, p_cost_analysis_code, p_cost_level) ;
  FETCH Cur_cmpt_dtl INTO l_rec_found;
  CLOSE Cur_cmpt_dtl;
  IF (l_rec_found IS NOT NULL) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE ;
  END IF;

END check_records_exist;

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
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--| 10-may-07 Prasad marada Bug 5586406 Added duplicate record check       |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Create_Item_Cost
  (
  p_api_version		          IN              NUMBER,
  p_init_msg_list	          IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		              IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	              OUT NOCOPY  VARCHAR2,
  x_msg_count		                OUT NOCOPY  NUMBER,
  x_msg_data		                OUT NOCOPY  VARCHAR2,
  p_header_rec		          IN              GMF_ItemCost_PUB.Header_Rec_Type,
  p_this_level_dtl_tbl	    IN              GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	    IN              GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type,
  p_user_id                 IN              fnd_user.user_id%TYPE,
  x_costcmpnt_ids	              OUT NOCOPY  GMF_ItemCost_PUB.costcmpnt_ids_tbl_type
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name		          CONSTANT          VARCHAR2(30)	:= 'Create_Item_Cost' ;
	  l_api_version           CONSTANT          NUMBER		:= 3.0 ;
    l_cmpntcost_id		                        cm_cmpt_dtl.cmpntcost_id%TYPE ;
    l_idx			                                NUMBER(10) := 0 ;

  BEGIN
    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 CREATE_ITEM_COST_PVT ;

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
    IF NOT FND_API.Compatible_API_Call  (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Private Create Item Cost API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
      log_msg(' Inserting Component Costs for Item ' || p_header_rec.inventory_item_id ||
              ' Organization Id ' || p_header_rec.organization_id ||
              ' Period Id ' || p_header_rec.period_id ||
              ' Cost Type Id ' || p_header_rec.cost_type_id);
    	log_msg(' This level Count : ' || p_this_level_dtl_tbl.count);
    END IF;

    FOR i in 1..p_this_level_dtl_tbl.count
    LOOP

      /*Check for duplicate record bug 5586406 */
      IF check_records_exist(
           p_organization_id    => p_header_rec.organization_id,
           p_inventory_item_id  => p_header_rec.inventory_item_id,
           p_period_id          => p_header_rec.period_id,
           p_cost_type_id       => p_header_rec.cost_type_id,
           p_cost_cmpntcls_id   => p_this_level_dtl_tbl(i).cost_cmpntcls_id,
           p_cost_analysis_code => p_this_level_dtl_tbl(i).cost_analysis_code,
           p_cost_level         => 0
           ) THEN
          FND_MESSAGE.SET_NAME('GMF','GMF_API_DUPLICATE_ITEM_COST');
          FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
          FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_header_rec.inventory_item_id);
          FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
          FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
          FND_MESSAGE.SET_TOKEN('COST_CMPNTCLS_ID',p_this_level_dtl_tbl(i).cost_cmpntcls_id);
          FND_MESSAGE.SET_TOKEN('COST_ANALYSIS_CODE',p_this_level_dtl_tbl(i).cost_analysis_code);
          FND_MESSAGE.SET_TOKEN('COST_LEVEL',0);
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      /* end duplicate record check */

      SELECT      gem5_cmpnt_cost_id_s.NEXTVAL
      INTO        l_cmpntcost_id
      FROM        DUAL ;

      /***********************************************************************************************
      * Using anonymous block to capture any error for the current record. Duplicate record check is *
      * not done in public API because of the performance considerations.                            *
      * In case of failure error msg will be logged and will continue with the next record           *
      ***********************************************************************************************/
      BEGIN
        INSERT INTO cm_cmpt_dtl
        (
          cmpntcost_id,
          inventory_item_id,
          organization_id,
          period_id,
          cost_type_id,
          cost_cmpntcls_id,
          cost_analysis_code,
          cost_level,
          cmpnt_cost,
          burden_ind,
          fmeff_id,
          rollover_ind,
          total_qty,
          costcalc_orig,
          rmcalc_type,
          rollup_ref_no,
          acproc_id,
          trans_cnt,
          text_code,
          delete_mark,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
          )
          VALUES
          (
          l_cmpntcost_id,
          p_header_rec.inventory_item_id,
          p_header_rec.organization_id,
          p_header_rec.period_id,
          p_header_rec.cost_type_id,
          p_this_level_dtl_tbl(i).cost_cmpntcls_id,
          p_this_level_dtl_tbl(i).cost_analysis_code,
          0, -- Cost Level
          p_this_level_dtl_tbl(i).cmpnt_cost,
          p_this_level_dtl_tbl(i).burden_ind,
          '',	-- effectivity id
          0,	-- rollover indicator
          decode(p_this_level_dtl_tbl(i).total_qty, FND_API.G_MISS_NUM, '', p_this_level_dtl_tbl(i).total_qty),
          decode(p_this_level_dtl_tbl(i).costcalc_orig, FND_API.G_MISS_NUM, '', p_this_level_dtl_tbl(i).costcalc_orig),
          decode(p_this_level_dtl_tbl(i).rmcalc_type, FND_API.G_MISS_NUM, '', p_this_level_dtl_tbl(i).rmcalc_type),
          '',	-- rollup ref#
          '',-- acproc_id
          '',	-- trans cnt
          '',	-- text code
          0,	--delete mark
          '',
          '',
          '',
          '',
          p_this_level_dtl_tbl(i).attribute1,
          p_this_level_dtl_tbl(i).attribute2,
          p_this_level_dtl_tbl(i).attribute3,
          p_this_level_dtl_tbl(i).attribute4,
          p_this_level_dtl_tbl(i).attribute5,
          p_this_level_dtl_tbl(i).attribute6,
          p_this_level_dtl_tbl(i).attribute7,
          p_this_level_dtl_tbl(i).attribute8,
          p_this_level_dtl_tbl(i).attribute9,
          p_this_level_dtl_tbl(i).attribute10,
          p_this_level_dtl_tbl(i).attribute11,
          p_this_level_dtl_tbl(i).attribute12,
          p_this_level_dtl_tbl(i).attribute13,
          p_this_level_dtl_tbl(i).attribute14,
          p_this_level_dtl_tbl(i).attribute15,
          p_this_level_dtl_tbl(i).attribute16,
          p_this_level_dtl_tbl(i).attribute17,
          p_this_level_dtl_tbl(i).attribute18,
          p_this_level_dtl_tbl(i).attribute19,
          p_this_level_dtl_tbl(i).attribute20,
          p_this_level_dtl_tbl(i).attribute21,
          p_this_level_dtl_tbl(i).attribute22,
          p_this_level_dtl_tbl(i).attribute23,
          p_this_level_dtl_tbl(i).attribute24,
          p_this_level_dtl_tbl(i).attribute25,
          p_this_level_dtl_tbl(i).attribute26,
          p_this_level_dtl_tbl(i).attribute27,
          p_this_level_dtl_tbl(i).attribute28,
          p_this_level_dtl_tbl(i).attribute29,
          p_this_level_dtl_tbl(i).attribute30,
          p_this_level_dtl_tbl(i).attribute_category,
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          FND_GLOBAL.LOGIN_ID
          );

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
          THEN
        	  log_msg(' 1 this level row inserted for ' ||
                    ' Cmptcls Id ' || p_this_level_dtl_tbl(i).cost_cmpntcls_id ||
                    ' Analysis Code ' || p_this_level_dtl_tbl(i).cost_analysis_code ||
                    ' Cmpntcost Id ' || l_cmpntcost_id);
          END IF;

          l_idx := l_idx + 1 ;

          x_costcmpnt_ids(l_idx).cost_cmpntcls_id   := p_this_level_dtl_tbl(i).cost_cmpntcls_id ;
          x_costcmpnt_ids(l_idx).cost_analysis_code := p_this_level_dtl_tbl(i).cost_analysis_code ;
          x_costcmpnt_ids(l_idx).cost_level         := 0 ;
          x_costcmpnt_ids(l_idx).cmpntcost_id       := l_cmpntcost_id ;

        EXCEPTION
          WHEN OTHERS THEN
            x_costcmpnt_ids.delete ;
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_THISLVL_INS_FAILED');
            FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_this_level_dtl_tbl(i).cost_cmpntcls_id);
            FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_this_level_dtl_tbl(i).cost_analysis_code);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            RAISE ;
        END ;
      END LOOP ;
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
    	  log_msg('Lower level Count : ' || p_lower_level_dtl_tbl.count);
      END IF;

      FOR i in 1..p_lower_level_dtl_tbl.count
      LOOP
         /*Check for duplicate record bug 5586406 */
         IF check_records_exist(
            p_organization_id    => p_header_rec.organization_id,
            p_inventory_item_id  => p_header_rec.inventory_item_id,
            p_period_id          => p_header_rec.period_id,
            p_cost_type_id       => p_header_rec.cost_type_id,
            p_cost_cmpntcls_id   => p_lower_level_dtl_tbl(i).cost_cmpntcls_id,
            p_cost_analysis_code => p_lower_level_dtl_tbl(i).cost_analysis_code,
            p_cost_level         => 1
            ) THEN
            FND_MESSAGE.SET_NAME('GMF','GMF_API_DUPLICATE_ITEM_COST');
            FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',p_header_rec.organization_id);
            FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',p_header_rec.inventory_item_id);
            FND_MESSAGE.SET_TOKEN('PERIOD_ID',p_header_rec.period_id);
            FND_MESSAGE.SET_TOKEN('COST_TYPE_ID',p_header_rec.cost_type_id);
            FND_MESSAGE.SET_TOKEN('COST_CMPNTCLS_ID',p_lower_level_dtl_tbl(i).cost_cmpntcls_id);
            FND_MESSAGE.SET_TOKEN('COST_ANALYSIS_CODE',p_lower_level_dtl_tbl(i).cost_analysis_code);
            FND_MESSAGE.SET_TOKEN('COST_LEVEL',1);
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
         /* end duplicate record check */

        SELECT        gem5_cmpnt_cost_id_s.NEXTVAL
        INTO          l_cmpntcost_id
        FROM          DUAL ;

        /***********************************************************************************************
        * Using anonymous block to capture any error for the current record. Duplicate record check is *
        * not done in public API because of the performance considerations.                            *
        * In case of failure error msg will be logged and will continue with the next record           *
        ***********************************************************************************************/
        BEGIN
          INSERT INTO cm_cmpt_dtl
          (
          cmpntcost_id,
          inventory_item_id,
          organization_id,
          period_id,
          cost_type_id,
          cost_cmpntcls_id,
          cost_analysis_code,
          cost_level,
          cmpnt_cost,
          burden_ind,
          fmeff_id,
          rollover_ind,
          total_qty,
          costcalc_orig,
          rmcalc_type,
          rollup_ref_no,
          acproc_id,
          trans_cnt,
          text_code,
          delete_mark,
          request_id,
          program_application_id,
          program_id,
          program_update_date,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login
          )
          VALUES
          (
          l_cmpntcost_id,
          p_header_rec.inventory_item_id,
          p_header_rec.organization_id,
          p_header_rec.period_id,
          p_header_rec.cost_type_id,
          p_lower_level_dtl_tbl(i).cost_cmpntcls_id,
          p_lower_level_dtl_tbl(i).cost_analysis_code,
          1,	-- cost level : this level
          p_lower_level_dtl_tbl(i).cmpnt_cost,
          0,	--p_lower_level_dtl_tbl(i).burden_ind
          '',	-- effectivity id
          0,	-- rollover indicator
          '',	-- total qty
          3,    -- costcalc_orig insert default value 3 as API Load
          '',	-- rmcalc_type
          '',   -- rollup ref#
          '',	--acproc_id
          '',	-- trans_cnt
          '',	-- text_code
          0,	-- delete mark
          '',	-- request id
          '',	-- appl id
          '',	-- program id
          '',	-- program_update_date
          '',	-- attribute1
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',	-- attribute30
          '',	-- attribute_category
          sysdate,
          p_user_id,
          sysdate,
          p_user_id,
          FND_GLOBAL.LOGIN_ID
          );

          IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
          THEN
        	  log_msg(' 1 lower level row inserted for ' ||
                    ' Cmptcls Id ' || p_lower_level_dtl_Tbl(i).cost_cmpntcls_id ||
                    ' Analysis Code ' || p_lower_level_dtl_Tbl(i).cost_analysis_code ||
                    ' Cmpntcost Id ' || l_cmpntcost_id);
          END IF;

          l_idx := l_idx + 1 ;

          x_costcmpnt_ids(l_idx).cost_cmpntcls_id   := p_lower_level_dtl_Tbl(i).cost_cmpntcls_id ;
          x_costcmpnt_ids(l_idx).cost_analysis_code := p_lower_level_dtl_Tbl(i).cost_analysis_code ;
          x_costcmpnt_ids(l_idx).cost_level         := 1 ;
          x_costcmpnt_ids(l_idx).cmpntcost_id       := l_cmpntcost_id ;
        EXCEPTION
          WHEN OTHERS THEN
            x_costcmpnt_ids.delete ;
            FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_LWRLVL_INS_FAILED');
            FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_lower_level_dtl_Tbl(i).cost_cmpntcls_id);
            FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_lower_level_dtl_Tbl(i).cost_analysis_code);
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            RAISE ;
        END ;
      END LOOP ;
      IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
      THEN
        log_msg( x_costcmpnt_ids.count || ' Component cost row(s) inserted');
      END IF;

      /******************************
      * Standard check of p_commit. *
      ******************************/
      IF FND_API.To_Boolean (p_commit)
      THEN
	      COMMIT WORK;
      END IF;

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get
    	(
      p_count		      =>      x_msg_count,
      p_data		      =>      x_msg_data
    	);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO  Create_Item_Cost_PVT;
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
	    );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    ROLLBACK TO  Create_Item_Cost_PVT;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
	    );
    WHEN OTHERS THEN
	    ROLLBACK TO  Create_Item_Cost_PVT;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	      FND_MSG_PUB.Add_Exc_Msg
	   	  (
        G_PKG_NAME,
			  l_api_name
		    );
	    END IF;
	    FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
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
--|               Current Version       : 2.0                              |
--|               Previous Version      : 1.0                              |
--|               Initial Version       : 1.0                              |
--|                                                                        |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--| 05-Apr-07 Prasad marada Bug 5586406, Modified the Cost level =1 in the |
--|           lower level cost update where clause                         |
--|                                                                        |
--+========================================================================+
-- End of comments

  PROCEDURE Update_Item_Cost
  (
  p_api_version		          IN              NUMBER,
  p_init_msg_list	          IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		              IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	              OUT NOCOPY  VARCHAR2,
  x_msg_count		                OUT NOCOPY  NUMBER,
  x_msg_data		                OUT NOCOPY  VARCHAR2,
  p_header_rec		          IN              GMF_ItemCost_PUB.Header_Rec_Type,
  p_this_level_dtl_tbl	    IN              GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	    IN              GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type,
  p_user_id                 IN              fnd_user.user_id%TYPE
  )
  IS

    /******************
    * Local Variables *
    ******************/
	  l_api_name              CONSTANT        VARCHAR2(30)   := 'Update_Item_Cost' ;
    l_api_version           CONSTANT        NUMBER         := 3.0 ;
  BEGIN
    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT	 UPDATE_ITEM_COST_PVT ;

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
    IF NOT FND_API.Compatible_API_Call  (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Private Update Item Cost API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg(' This level Count : ' || p_this_level_dtl_tbl.count);
    	log_msg(' Processing Component Costs for Item ' || p_header_rec.inventory_item_id ||
              ' Organization Id ' || p_header_rec.organization_id ||
              ' Period Id ' || p_header_rec.Period_id ||
              ' Cost Type Id ' || p_header_rec.cost_type_id) ;
    END IF;
    FOR i in 1..p_this_level_dtl_tbl.count
    LOOP

      /***********************************************************************************************
      * Using anonymous block to capture any error for the current record. Duplicate record check is *
      * not done in public API because of the performance considerations.                            *
      * In case of failure error msg will be logged.                                                 *
      ***********************************************************************************************/
      BEGIN
        IF (p_this_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) AND (p_this_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
        THEN
          IF p_this_level_dtl_tbl(i).delete_mark = 0
          THEN
            UPDATE        cm_cmpt_dtl
            SET           cmpnt_cost  =  decode(p_this_level_dtl_tbl(i).cmpnt_cost, FND_API.G_MISS_NUM, NULL, NULL, cmpnt_cost, p_this_level_dtl_tbl(i).cmpnt_cost),
                          burden_ind  =  decode(p_this_level_dtl_tbl(i).burden_ind, FND_API.G_MISS_NUM, NULL, NULL, burden_ind, p_this_level_dtl_tbl(i).burden_ind),
                          total_qty   =  decode(p_this_level_dtl_tbl(i).total_qty, FND_API.G_MISS_NUM, NULL, NULL, total_qty, p_this_level_dtl_tbl(i).total_qty),
                          costcalc_orig= decode(p_this_level_dtl_tbl(i).costcalc_orig, FND_API.G_MISS_NUM, NULL, NULL, costcalc_orig, p_this_level_dtl_tbl(i).costcalc_orig),
                          rmcalc_type  = decode(p_this_level_dtl_tbl(i).rmcalc_type, FND_API.G_MISS_NUM, NULL, NULL, rmcalc_type, p_this_level_dtl_tbl(i).rmcalc_type),
                          delete_mark  =  0,
                          ATTRIBUTE1  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_this_level_dtl_tbl(i).ATTRIBUTE1),
                          ATTRIBUTE2  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_this_level_dtl_tbl(i).ATTRIBUTE2),
                          ATTRIBUTE3  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_this_level_dtl_tbl(i).ATTRIBUTE3),
                          ATTRIBUTE4  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_this_level_dtl_tbl(i).ATTRIBUTE4),
                          ATTRIBUTE5  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_this_level_dtl_tbl(i).ATTRIBUTE5),
                          ATTRIBUTE6  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_this_level_dtl_tbl(i).ATTRIBUTE6),
                          ATTRIBUTE7  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_this_level_dtl_tbl(i).ATTRIBUTE7),
                          ATTRIBUTE8  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_this_level_dtl_tbl(i).ATTRIBUTE8),
                          ATTRIBUTE9  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_this_level_dtl_tbl(i).ATTRIBUTE9),
                          ATTRIBUTE10  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_this_level_dtl_tbl(i).ATTRIBUTE10),
                          ATTRIBUTE11  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_this_level_dtl_tbl(i).ATTRIBUTE11),
                          ATTRIBUTE12  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_this_level_dtl_tbl(i).ATTRIBUTE12),
                          ATTRIBUTE13  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_this_level_dtl_tbl(i).ATTRIBUTE13),
                          ATTRIBUTE14  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_this_level_dtl_tbl(i).ATTRIBUTE14),
                          ATTRIBUTE15  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_this_level_dtl_tbl(i).ATTRIBUTE15),
                          ATTRIBUTE16  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE16, p_this_level_dtl_tbl(i).ATTRIBUTE16),
                          ATTRIBUTE17  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE17, p_this_level_dtl_tbl(i).ATTRIBUTE17),
                          ATTRIBUTE18  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE18, p_this_level_dtl_tbl(i).ATTRIBUTE18),
                          ATTRIBUTE19  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE19, p_this_level_dtl_tbl(i).ATTRIBUTE19),
                          ATTRIBUTE20  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE20, p_this_level_dtl_tbl(i).ATTRIBUTE20),
                          ATTRIBUTE21  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE21, p_this_level_dtl_tbl(i).ATTRIBUTE21),
                          ATTRIBUTE22  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE22, p_this_level_dtl_tbl(i).ATTRIBUTE22),
                          ATTRIBUTE23  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE23, p_this_level_dtl_tbl(i).ATTRIBUTE23),
                          ATTRIBUTE24  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE24, p_this_level_dtl_tbl(i).ATTRIBUTE24),
                          ATTRIBUTE25  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE25, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE25, p_this_level_dtl_tbl(i).ATTRIBUTE25),
                          ATTRIBUTE26  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE26, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE26, p_this_level_dtl_tbl(i).ATTRIBUTE26),
                          ATTRIBUTE27  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE27, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE27, p_this_level_dtl_tbl(i).ATTRIBUTE27),
                          ATTRIBUTE28  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE28, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE28, p_this_level_dtl_tbl(i).ATTRIBUTE28),
                          ATTRIBUTE29  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE29, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE29, p_this_level_dtl_tbl(i).ATTRIBUTE29),
                          ATTRIBUTE30  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE30, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE30, p_this_level_dtl_tbl(i).ATTRIBUTE30),
                          attribute_category  =  decode(p_this_level_dtl_tbl(i).attribute_category, FND_API.G_MISS_CHAR, NULL, NULL, attribute_category, p_this_level_dtl_tbl(i).attribute_category),
                          last_update_date    =  sysdate,
                          last_updated_by     =  p_user_id,
                          last_update_login   =  FND_GLOBAL.LOGIN_ID
            WHERE         cmpntcost_id	     = p_this_level_dtl_tbl(i).cmpntcost_id
            AND           cost_level         = 0;
          ELSE		-- delete the record i.e mark for purge
            UPDATE        cm_cmpt_dtl
            SET           delete_mark       = 1,
                          last_update_date  = sysdate,
                          last_updated_by   = p_user_id,
                          last_update_login = FND_GLOBAL.LOGIN_ID
            WHERE         cmpntcost_id 	    = p_this_level_dtl_tbl(i).cmpntcost_id
            AND           cost_level        = 0;
          END IF ;

          IF SQL%NOTFOUND
          THEN
            IF p_this_level_dtl_tbl(i).delete_mark = 0
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_UPD_IC_NOT_FOUND_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_IC_NOT_FOUND_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
          ELSE
            IF p_this_level_dtl_tbl(i).delete_mark = 0
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg(' 1 row updated for Component Cost Id ' || p_this_level_dtl_tbl(i).cmpntcost_id);
              END IF;
            ELSE
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg(' 1 row deleted for Component Cost Id ' || p_this_level_dtl_tbl(i).cmpntcost_id);
              END IF;
            END IF ;
          END IF ;
        ELSE  -- else if cmpntcost_id is not passed
          IF p_this_level_dtl_tbl(i).delete_mark = 0
          THEN
            UPDATE        cm_cmpt_dtl
            SET           cmpnt_cost  =  decode(p_this_level_dtl_tbl(i).cmpnt_cost, FND_API.G_MISS_NUM, NULL, NULL, cmpnt_cost, p_this_level_dtl_tbl(i).cmpnt_cost),
                          burden_ind  =  decode(p_this_level_dtl_tbl(i).burden_ind, FND_API.G_MISS_NUM, NULL, NULL, burden_ind, p_this_level_dtl_tbl(i).burden_ind),
                          total_qty   =  decode(p_this_level_dtl_tbl(i).total_qty, FND_API.G_MISS_NUM, NULL, NULL, total_qty, p_this_level_dtl_tbl(i).total_qty),
                          costcalc_orig=  decode(p_this_level_dtl_tbl(i).costcalc_orig, FND_API.G_MISS_NUM, NULL, NULL, costcalc_orig, p_this_level_dtl_tbl(i).costcalc_orig),
                          rmcalc_type  =  decode(p_this_level_dtl_tbl(i).rmcalc_type, FND_API.G_MISS_NUM, NULL, NULL, rmcalc_type, p_this_level_dtl_tbl(i).rmcalc_type),
                          delete_mark  =  0,
                          ATTRIBUTE1  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE1, p_this_level_dtl_tbl(i).ATTRIBUTE1),
                          ATTRIBUTE2  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE2, p_this_level_dtl_tbl(i).ATTRIBUTE2),
                          ATTRIBUTE3  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE3, p_this_level_dtl_tbl(i).ATTRIBUTE3),
                          ATTRIBUTE4  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE4, p_this_level_dtl_tbl(i).ATTRIBUTE4),
                          ATTRIBUTE5  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE5, p_this_level_dtl_tbl(i).ATTRIBUTE5),
                          ATTRIBUTE6  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE6, p_this_level_dtl_tbl(i).ATTRIBUTE6),
                          ATTRIBUTE7  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE7, p_this_level_dtl_tbl(i).ATTRIBUTE7),
                          ATTRIBUTE8  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE8, p_this_level_dtl_tbl(i).ATTRIBUTE8),
                          ATTRIBUTE9  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE9, p_this_level_dtl_tbl(i).ATTRIBUTE9),
                          ATTRIBUTE10  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE10, p_this_level_dtl_tbl(i).ATTRIBUTE10),
                          ATTRIBUTE11  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE11, p_this_level_dtl_tbl(i).ATTRIBUTE11),
                          ATTRIBUTE12  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE12, p_this_level_dtl_tbl(i).ATTRIBUTE12),
                          ATTRIBUTE13  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE13, p_this_level_dtl_tbl(i).ATTRIBUTE13),
                          ATTRIBUTE14  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE14, p_this_level_dtl_tbl(i).ATTRIBUTE14),
                          ATTRIBUTE15  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE15, p_this_level_dtl_tbl(i).ATTRIBUTE15),
                          ATTRIBUTE16  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE16, p_this_level_dtl_tbl(i).ATTRIBUTE16),
                          ATTRIBUTE17  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE17, p_this_level_dtl_tbl(i).ATTRIBUTE17),
                          ATTRIBUTE18  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE18, p_this_level_dtl_tbl(i).ATTRIBUTE18),
                          ATTRIBUTE19  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE19, p_this_level_dtl_tbl(i).ATTRIBUTE19),
                          ATTRIBUTE20  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE20, p_this_level_dtl_tbl(i).ATTRIBUTE20),
                          ATTRIBUTE21  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE21, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE21, p_this_level_dtl_tbl(i).ATTRIBUTE21),
                          ATTRIBUTE22  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE22, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE22, p_this_level_dtl_tbl(i).ATTRIBUTE22),
                          ATTRIBUTE23  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE23, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE23, p_this_level_dtl_tbl(i).ATTRIBUTE23),
                          ATTRIBUTE24  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE24, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE24, p_this_level_dtl_tbl(i).ATTRIBUTE24),
                          ATTRIBUTE25  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE25, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE25, p_this_level_dtl_tbl(i).ATTRIBUTE25),
                          ATTRIBUTE26  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE26, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE26, p_this_level_dtl_tbl(i).ATTRIBUTE26),
                          ATTRIBUTE27  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE27, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE27, p_this_level_dtl_tbl(i).ATTRIBUTE27),
                          ATTRIBUTE28  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE28, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE28, p_this_level_dtl_tbl(i).ATTRIBUTE28),
                          ATTRIBUTE29  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE29, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE29, p_this_level_dtl_tbl(i).ATTRIBUTE29),
                          ATTRIBUTE30  =  decode(p_this_level_dtl_tbl(i).ATTRIBUTE30, FND_API.G_MISS_CHAR, NULL, NULL, ATTRIBUTE30, p_this_level_dtl_tbl(i).ATTRIBUTE30),
                          attribute_category  =  decode(p_this_level_dtl_tbl(i).attribute_category, FND_API.G_MISS_CHAR, NULL, NULL, attribute_category, p_this_level_dtl_tbl(i).attribute_category),
                          last_update_date    =  sysdate,
                          last_updated_by     =  p_user_id,
                          last_update_login   =  FND_GLOBAL.LOGIN_ID
            WHERE         inventory_item_id   =  p_header_rec.inventory_item_id
            AND           organization_id     =  p_header_rec.organization_id
            AND           period_id           =  p_header_rec.period_id
            AND           cost_type_id        =  p_header_rec.cost_type_id
            AND           cost_cmpntcls_id    = p_this_level_dtl_tbl(i).cost_cmpntcls_id
            AND           cost_analysis_code  = p_this_level_dtl_tbl(i).cost_analysis_code
            AND           cost_level          = 0;
          ELSE
            UPDATE        cm_cmpt_dtl
            SET           delete_mark         =  1,
                          last_update_date    =  sysdate,
                          last_updated_by     =  p_user_id,
                          last_update_login   =  FND_GLOBAL.LOGIN_ID
            WHERE         inventory_item_id   =  p_header_rec.inventory_item_id
            AND           organization_id     =  p_header_rec.organization_id
            AND           period_id           =  p_header_rec.period_id
            AND           cost_type_id        =  p_header_rec.cost_type_id
            AND           cost_cmpntcls_id    =  p_this_level_dtl_tbl(i).cost_cmpntcls_id
            AND           cost_analysis_code  =  p_this_level_dtl_tbl(i).cost_analysis_code
            AND           cost_level          =  0;
          END IF ;

          IF SQL%NOTFOUND THEN
            IF p_this_level_dtl_tbl(i).delete_mark = 0 THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_UPD_IC_NOT_FOUND_DTL');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_this_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_this_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_IC_NOT_FOUND_DTL');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_this_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_this_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
          ELSE
            IF p_this_level_dtl_tbl(i).delete_mark = 0
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg(' 1 row updated for Component Class Id ' || p_this_level_dtl_tbl(i).cost_cmpntcls_id ||
                        ' Analysis Code ' || p_this_level_dtl_tbl(i).cost_analysis_code);
              END IF;
            ELSE
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
               	log_msg(' 1 row deleted for Component Class Id ' || p_this_level_dtl_tbl(i).cost_cmpntcls_id ||
                        ' Analysis Code ' || p_this_level_dtl_tbl(i).cost_analysis_code);
              END IF;
            END IF ;
          END IF ;
        END IF ;
      EXCEPTION
        WHEN OTHERS THEN
          IF p_this_level_dtl_tbl(i).delete_mark = 0
          THEN
            IF (p_this_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) OR (p_this_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_UPD_FAILED_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_UPD_FAILED_DTLS');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_this_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_this_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
          ELSE
            IF (p_this_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) OR (p_this_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_DEL_FAILED_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_this_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_DEL_FAILED_DTLS');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_this_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_this_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
          END IF ;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          RAISE ;
      END ;
    END LOOP ;
    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Lower level Count : ' || p_lower_level_dtl_tbl.count);
    END IF;
    FOR i in 1..p_lower_level_dtl_tbl.count
    LOOP
      BEGIN
        IF (p_lower_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) AND (p_lower_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
        THEN
          IF p_lower_level_dtl_tbl(i).delete_mark = 0
          THEN
            UPDATE        cm_cmpt_dtl
            SET           cmpnt_cost = decode(p_lower_level_dtl_tbl(i).cmpnt_cost, FND_API.G_MISS_NUM, NULL, NULL, cmpnt_cost, p_lower_level_dtl_tbl(i).cmpnt_cost),
                          delete_mark        =  0,
                          last_update_date   =  sysdate,
                          last_updated_by    =  p_user_id,
                          last_update_login  =  FND_GLOBAL.LOGIN_ID
            WHERE         cmpntcost_id	     =  p_lower_level_dtl_tbl(i).cmpntcost_id
            AND           cost_level         =  1;
          ELSE
            UPDATE        cm_cmpt_dtl
            SET           delete_mark       =  1,
                          last_update_date  =  sysdate,
                          last_updated_by   =  p_user_id,
                          last_update_login =  FND_GLOBAL.LOGIN_ID
            WHERE         cmpntcost_id      =  p_lower_level_dtl_tbl(i).cmpntcost_id
            AND           cost_level        =  1;
          END IF ;

          IF SQL%NOTFOUND
          THEN
            IF p_lower_level_dtl_tbl(i).delete_mark = 0
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_UPD_IC_NOT_FOUND_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_IC_NOT_FOUND_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
          ELSE
            IF p_lower_level_dtl_tbl(i).delete_mark = 0
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
               	log_msg(' 1 row updated for Component Cost Id ' || p_lower_level_dtl_tbl(i).cmpntcost_id);
              END IF;
            ELSE
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
               	log_msg(' 1 row deleted for Component Cost Id ' || p_lower_level_dtl_tbl(i).cmpntcost_id);
              END IF;
            END IF ;
          END IF ;
        ELSE -- cmpntcost_id is not passed
          IF p_lower_level_dtl_tbl(i).delete_mark = 0
          THEN
            UPDATE        cm_cmpt_dtl
            SET           cmpnt_cost          =  decode(p_lower_level_dtl_tbl(i).cmpnt_cost, FND_API.G_MISS_NUM, NULL, NULL, cmpnt_cost, p_lower_level_dtl_tbl(i).cmpnt_cost ),
                          delete_mark         =  0,
                          last_update_date    =  sysdate,
                          last_updated_by     =  p_user_id,
                          last_update_login   =  FND_GLOBAL.LOGIN_ID

            WHERE         inventory_item_id   =  p_header_rec.inventory_item_id
            AND           organization_id     =  p_header_rec.organization_id
            AND           period_id           =  p_header_rec.period_id
            AND           cost_type_id        =  p_header_rec.cost_type_id
            AND           cost_cmpntcls_id    =  p_lower_level_dtl_tbl(i).cost_cmpntcls_id
            AND           cost_analysis_code  =  p_lower_level_dtl_tbl(i).cost_analysis_code
            AND           cost_level          =  1;
          ELSE
            UPDATE        cm_cmpt_dtl
            SET           delete_mark         =  1,
                          last_update_date    =  sysdate,
                          last_updated_by     =  p_user_id,
                          last_update_login   =  FND_GLOBAL.LOGIN_ID
            WHERE         inventory_item_id   =  p_header_rec.inventory_item_id
            AND           organization_id     =  p_header_rec.organization_id
            AND           period_id           =  p_header_rec.period_id
            AND           cost_type_id        =  p_header_rec.cost_type_id
            AND           cost_cmpntcls_id    =  p_lower_level_dtl_tbl(i).cost_cmpntcls_id
            AND           cost_analysis_code  =  p_lower_level_dtl_tbl(i).cost_analysis_code
            AND           cost_level          =  1;
          END IF ;
          IF SQL%NOTFOUND
          THEN
            IF p_lower_level_dtl_tbl(i).delete_mark = 0
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_UPD_IC_NOT_FOUND_DTL');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_lower_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_lower_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_DEL_IC_NOT_FOUND_DTL');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_lower_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_lower_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            EXIT ;
          ELSE
            IF p_lower_level_dtl_tbl(i).delete_mark = 0
            THEN
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg(' 1 row updated for Component Class Id ' || p_lower_level_dtl_tbl(i).cost_cmpntcls_id ||
                        ' Analysis Code ' || p_lower_level_dtl_tbl(i).cost_analysis_code);
              END IF;
            ELSE
              IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
              THEN
                log_msg(' 1 row deleted for Component Class Id ' ||p_lower_level_dtl_tbl(i).cost_cmpntcls_id ||
                        ' Analysis Code ' || p_lower_level_dtl_tbl(i).cost_analysis_code);
              END IF;
            END IF ;
          END IF ;
        END IF ;  --cmpntcost_id check
      EXCEPTION
        WHEN OTHERS THEN
          IF p_lower_level_dtl_tbl(i).delete_mark = 0
          THEN
            IF (p_lower_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) OR (p_lower_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_UPD_FAILED_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_UPD_FAILED_DTLS');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_lower_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_lower_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
          ELSE
            IF (p_lower_level_dtl_tbl(i).cmpntcost_id IS NOT NULL) OR (p_lower_level_dtl_tbl(i).cmpntcost_id <> FND_API.G_MISS_NUM)
            THEN
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_DEL_FAILED_ID');
              FND_MESSAGE.SET_TOKEN('CMPNTCOST_ID', p_lower_level_dtl_tbl(i).cmpntcost_id);
              FND_MSG_PUB.Add;
            ELSE
              FND_MESSAGE.SET_NAME('GMF','GMF_API_IC_DEL_FAILED_DTLS');
              FND_MESSAGE.SET_TOKEN('CMPNTCLS_ID', p_lower_level_dtl_tbl(i).cost_cmpntcls_id);
              FND_MESSAGE.SET_TOKEN('ALYS_CODE', p_lower_level_dtl_tbl(i).cost_analysis_code);
              FND_MSG_PUB.Add;
            END IF ;
          END IF ;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          RAISE ;
      END ;
    END LOOP ;

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
    p_count         =>      x_msg_count,
    p_data          =>      x_msg_data
    );
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  UPDATE_ITEM_COST_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
	    );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  UPDATE_ITEM_COST_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
	    );
    WHEN OTHERS THEN
      ROLLBACK TO  Update_Item_Cost_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
	    (
      p_count         =>      x_msg_count,
		  p_data          =>      x_msg_data
	    );
END UPDATE_ITEM_COST ;

--Start of comments
--+========================================================================+
--| API Name	: Get_Item_Cost                                            |
--| TYPE	: Private                                           	   |
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
--|	 	  Current Version	: 2.0                              |
--|	  	  Previous Version	: 1.0                              |
--|	  	  Initial Version	: 1.0                              |
--|                                                                        |
--| Notes	:                                                          |
--|                                                                        |
--| HISTORY                                                                |
--| 01-Mar-01     Uday Moogala - Created                                   |
--|                                                                        |
--|  16-APR-2009 Uday Phadtare Bug 7631080.                                |
--|    CURSOR cm_cmpt_dtl modified. Joined cm_cmpt_mst and cm_cmpt_dtl     |
--|    tables to avoid cartesian product.                                  |
--+========================================================================+
-- End of comments
  PROCEDURE Get_Item_Cost
  (
  p_api_version		          IN              NUMBER,
  p_init_msg_list	          IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	              OUT NOCOPY  VARCHAR2,
  x_msg_count		              OUT NOCOPY  NUMBER,
  x_msg_data		              OUT NOCOPY  VARCHAR2,
  p_header_rec		          IN              GMF_ItemCost_PUB.Header_Rec_Type,
  x_this_level_dtl_tbl	              OUT NOCOPY  GMF_ItemCost_PUB.This_Level_Dtl_Tbl_Type,
  x_lower_level_dtl_Tbl	              OUT NOCOPY  GMF_ItemCost_PUB.Lower_Level_Dtl_Tbl_Type
  )
  IS

    /******************
    * Local Variables *
    ******************/
    l_api_name              CONSTANT        VARCHAR2(30)   := 'Delete_Item_Cost' ;
    l_api_version           CONSTANT        NUMBER         := 3.0 ;
    l_idx                                   NUMBER         := 0 ;
    l_idx1                                  NUMBER         := 0 ;

    /**********
    * Cursors *
    **********/
    CURSOR                  cm_cmpt_dtl
    IS
    SELECT                  cd.cmpntcost_id, cd.cost_cmpntcls_id, cm.cost_cmpntcls_code,
                            cd.cost_analysis_code, cd.cmpnt_cost, cd.burden_ind,
                            cd.total_qty, cd.costcalc_orig, cd.rmcalc_type, cd.cost_level,
                            cd.delete_mark, cd.attribute1,cd.attribute2, cd.attribute3,
                            cd.attribute4, cd.attribute5, cd.attribute6, cd.attribute7,
                            cd.attribute8, cd.attribute9, cd.attribute10, cd.attribute11,
                            cd.attribute12, cd.attribute13, cd.attribute14, cd.attribute15,
                            cd.attribute16, cd.attribute17, cd.attribute18, cd.attribute19,
                            cd.attribute20, cd.attribute21, cd.attribute22, cd.attribute23,
                            cd.attribute24, cd.attribute25, cd.attribute26, cd.attribute27,
                            cd.attribute28, cd.attribute29, cd.attribute30, cd.attribute_category
    FROM                    cm_cmpt_mst cm, cm_cmpt_dtl cd
    WHERE                   cd.inventory_item_id = p_header_rec.inventory_item_id
    AND                     cd.organization_id   = p_header_rec.organization_id
    AND                     cd.period_id         = p_header_rec.period_id
    AND                     cd.cost_type_id      = p_header_rec.cost_type_id
    AND                     cm.cost_cmpntcls_id  = cd.cost_cmpntcls_id       /* Bug 7631080 */
    ORDER BY                cd.cost_cmpntcls_id, cd.cost_analysis_code;
  BEGIN

    /**********************************
    * Standard Start of API savepoint *
    **********************************/
    SAVEPOINT    GET_ITEM_COST_PVT;

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
    IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /******************************************
    * Initialize API return status to success *
    ******************************************/
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg('Beginning Private Get Item Cost API.');
    END IF;

    IF FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW >= G_Debug_Level
    THEN
    	log_msg(' Retrieving Component Costs for Item ' || p_header_rec.inventory_item_id ||
              ' Organization id ' || p_header_rec.organization_id ||
              ' Period Id' || p_header_rec.Period_id ||
              ' Cost Type Id ' || p_header_rec.cost_type_id) ;
    END IF;

    FOR cr_rec IN cm_cmpt_dtl
    LOOP
      IF cr_rec.cost_level = 0
      THEN
        l_idx := l_idx + 1 ;
        x_this_level_dtl_tbl(l_idx).cmpntcost_id       := cr_rec.cmpntcost_id ;
        x_this_level_dtl_tbl(l_idx).cost_cmpntcls_id   := cr_rec.cost_cmpntcls_id ;
        x_this_level_dtl_tbl(l_idx).cost_cmpntcls_code := cr_rec.cost_cmpntcls_code ;
        x_this_level_dtl_tbl(l_idx).cost_analysis_code := cr_rec.cost_analysis_code ;
        x_this_level_dtl_tbl(l_idx).cmpnt_cost         := cr_rec.cmpnt_cost ;
        x_this_level_dtl_tbl(l_idx).burden_ind         := cr_rec.burden_ind ;
        x_this_level_dtl_tbl(l_idx).total_qty          := cr_rec.total_qty ;
        x_this_level_dtl_tbl(l_idx).costcalc_orig      := cr_rec.costcalc_orig ;
        x_this_level_dtl_tbl(l_idx).rmcalc_type        := cr_rec.rmcalc_type ;
        x_this_level_dtl_tbl(l_idx).delete_mark        := cr_rec.delete_mark ;
        x_this_level_dtl_tbl(l_idx).attribute1         := cr_rec.attribute1 ;
        x_this_level_dtl_tbl(l_idx).attribute2         := cr_rec.attribute2 ;
        x_this_level_dtl_tbl(l_idx).attribute3         := cr_rec.attribute3 ;
        x_this_level_dtl_tbl(l_idx).attribute4         := cr_rec.attribute4 ;
        x_this_level_dtl_tbl(l_idx).attribute5         := cr_rec.attribute5 ;
        x_this_level_dtl_tbl(l_idx).attribute6         := cr_rec.attribute6 ;
        x_this_level_dtl_tbl(l_idx).attribute7         := cr_rec.attribute7 ;
        x_this_level_dtl_tbl(l_idx).attribute8         := cr_rec.attribute8 ;
        x_this_level_dtl_tbl(l_idx).attribute9         := cr_rec.attribute9 ;
        x_this_level_dtl_tbl(l_idx).attribute10        := cr_rec.attribute10 ;
        x_this_level_dtl_tbl(l_idx).attribute11        := cr_rec.attribute11 ;
        x_this_level_dtl_tbl(l_idx).attribute12        := cr_rec.attribute12 ;
        x_this_level_dtl_tbl(l_idx).attribute13        := cr_rec.attribute13 ;
        x_this_level_dtl_tbl(l_idx).attribute14        := cr_rec.attribute14 ;
        x_this_level_dtl_tbl(l_idx).attribute15        := cr_rec.attribute15 ;
        x_this_level_dtl_tbl(l_idx).attribute16        := cr_rec.attribute16 ;
        x_this_level_dtl_tbl(l_idx).attribute17        := cr_rec.attribute17 ;
        x_this_level_dtl_tbl(l_idx).attribute18        := cr_rec.attribute18 ;
        x_this_level_dtl_tbl(l_idx).attribute19        := cr_rec.attribute19 ;
        x_this_level_dtl_tbl(l_idx).attribute20        := cr_rec.attribute20 ;
        x_this_level_dtl_tbl(l_idx).attribute21        := cr_rec.attribute21 ;
        x_this_level_dtl_tbl(l_idx).attribute22        := cr_rec.attribute22 ;
        x_this_level_dtl_tbl(l_idx).attribute23        := cr_rec.attribute23 ;
        x_this_level_dtl_tbl(l_idx).attribute24        := cr_rec.attribute24 ;
        x_this_level_dtl_tbl(l_idx).attribute25        := cr_rec.attribute25 ;
        x_this_level_dtl_tbl(l_idx).attribute26        := cr_rec.attribute26 ;
        x_this_level_dtl_tbl(l_idx).attribute27        := cr_rec.attribute27 ;
        x_this_level_dtl_tbl(l_idx).attribute28        := cr_rec.attribute28 ;
        x_this_level_dtl_tbl(l_idx).attribute29        := cr_rec.attribute29 ;
        x_this_level_dtl_tbl(l_idx).attribute30        := cr_rec.attribute30 ;
        x_this_level_dtl_tbl(l_idx).attribute_category := cr_rec.attribute_category ;
      ELSE
        l_idx1 := l_idx1 + 1 ;
        x_lower_level_dtl_tbl(l_idx1).cmpntcost_id        := cr_rec.cmpntcost_id ; x_lower_level_dtl_tbl(l_idx1).cost_cmpntcls_id    := cr_rec.cost_cmpntcls_id ;
        x_lower_level_dtl_tbl(l_idx1).cost_cmpntcls_code  := cr_rec.cost_cmpntcls_code ;
        x_lower_level_dtl_tbl(l_idx1).cost_analysis_code  := cr_rec.cost_analysis_code ;
        x_lower_level_dtl_tbl(l_idx1).cmpnt_cost          := cr_rec.cmpnt_cost ;
      END IF ;
    END LOOP ;

    /**************************************************************************
    * Standard call to get message count and if count is 1, get message info. *
    **************************************************************************/
    FND_MSG_PUB.Count_And_Get
    (
    p_count           =>        x_msg_count,
    p_data            =>        x_msg_data
    );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  GET_ITEM_COST_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
      p_count           =>        x_msg_count,
      p_data            =>        x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  GET_ITEM_COST_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
      (
      p_count           =>        x_msg_count,
      p_data            =>        x_msg_data
      );
    WHEN OTHERS THEN
      ROLLBACK TO  GET_ITEM_COST_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
    (
    p_count           =>        x_msg_count,
    p_data            =>        x_msg_data
    );
  END GET_ITEM_COST ;

END GMF_ITEMCOST_PVT;

/
