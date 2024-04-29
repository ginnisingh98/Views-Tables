--------------------------------------------------------
--  DDL for Package Body CSTPSCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSCHK" AS
/* $Header: CSTSCHKB.pls 120.1.12010000.3 2010/10/28 20:38:03 hyu ship $ */

-- FUNCTION
--  std_cost_dist_hook		Cover routine to allow users to customize.
--				They will be able to circumvent the
--				standard cost distribution process.  This is
--                              called by inltcp.ppc.
--
--
-- RETURN VALUES
--  integer		1	Hook has been used.
--			0	Continue cost distribution for this transaction
--				as usual.
--
function std_cost_dist_hook(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer  IS
BEGIN
  o_err_code := '';
  o_err_num := 0;
  o_err_msg := '';

  return 0;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPSCHK.STD_COST_DIST_HOOK:' || substrb(SQLERRM,1,150);
    return 0;

END std_cost_dist_hook;



-- FUNCTION
--  std_cost_update_hook        Cover routine to allow users to customize.
--                              They will be able to circumvent the
--                              standard cost update process.  This is
--                              called by cmlicu.ppc.
--
--
-- RETURN VALUES
--  integer             1       Hook has been used.
--                      0       Continue cost distribution for this transaction
--                              as ususal.
--
FUNCTION std_cost_update_hook(
  i_org_id              IN      NUMBER,
  i_cost_update_id      IN      NUMBER,
  i_user_id             IN      NUMBER,
  i_login_id            IN      NUMBER,
  i_req_id              IN      NUMBER,
  i_prg_appl_id         IN      NUMBER,
  i_prg_id              IN      NUMBER,
  o_err_num             OUT NOCOPY     NUMBER,
  o_err_code            OUT NOCOPY     VARCHAR2,
  o_err_msg             OUT NOCOPY     VARCHAR2
)
RETURN integer  IS
BEGIN
  o_err_code := '';
  o_err_num := 0;
  o_err_msg := '';

  return 0;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPSCHK.STD_COST_UPDATE_HOOK:' || substrb(SQLERRM,1,150);
    return 0;

END std_cost_update_hook;



-- FUNCTION
--  std_get_account_id		Cover routine to allow users the flexbility
--				in determining the account they want to
--				post the inventory transaction to.
--
--
-- RETURN VALUES
--  integer		>0	User selected account number.
--			-1  	Use the default account for distribution.
--
function std_get_account_id(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_DEBIT_CREDIT	IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_COST_ELEMENT_ID	IN	NUMBER,
  I_RESOURCE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_CG_ID		IN	NUMBER,
  I_EXP			IN	NUMBER,
  I_SND_RCV_ORG		IN	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer  IS
l_account_num number := -1;
l_txn_type_id number;
l_txn_act_id number;
l_txn_src_type_id number;
l_item_id number;
wf_err_num number := 0;
wf_err_code varchar2(500) ;
wf_err_msg varchar2(500) ;

BEGIN

  wf_err_code := '';
  wf_err_msg := '';
  o_err_num := 0;
  o_err_code := '';
  o_err_msg := '';

  SELECT transaction_type_id,
         transaction_action_id,
         transaction_source_type_id,
         inventory_item_id
  INTO   l_txn_type_id,
         l_txn_act_id,
         l_txn_src_type_id,
         l_item_id
  FROM   MTL_MATERIAL_TRANSACTIONS
  WHERE  transaction_id = I_TXN_ID;

   l_account_num := CSTPSCWF.START_STD_WF(i_txn_id, l_txn_type_id,l_txn_act_id,
                                          l_txn_src_type_id, i_org_id,
                                          l_item_id,
                                          i_cost_element_id,i_acct_line_type,
                                          i_subinv,i_cg_id,i_resource_id,
                                         wf_err_num, wf_err_code, wf_err_msg);
    o_err_num := NVL(wf_err_num, 0);
    o_err_code := NVL(wf_err_code, 'No Error in CSTPSWF.START_STD_WF');
    o_err_msg := NVL(wf_err_msg, 'No Error in CSTPSWF.START_STD_WF');

-- if -1 then use default account, else use this account for distribution
   return l_account_num;

EXCEPTION

  when others then
    o_err_num := -1;
    o_err_code := to_char(SQLCODE);
    o_err_msg := 'Error in CSTPSCHK.STD_GET_ACCOUNT_ID:' || substrb(SQLERRM,1,150);
    return 0;

END std_get_account_id;

-- FUNCTION
--  std_get_update_acct_id	Cover routine to allow users the flexbility
--				in determining the account they want to
--				post the Update transaction to.
--
--
-- RETURN VALUES
--  integer		>0	User selected account number
--			-1  	Use the default account for distribution.
--
function std_get_update_acct_id(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID            	IN      NUMBER,
  I_TXN_TYPE_ID	        IN      NUMBER,
  I_TXN_ACT_ID          IN      NUMBER,
  I_TXN_SRC_TYPE_ID     IN      NUMBER,
  I_ITEM_ID	        IN      NUMBER,
  I_UPDATE_ID		IN 	NUMBER,
  I_DEBIT_CREDIT	IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_COST_ELEMENT_ID	IN	NUMBER,
  I_RESOURCE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_CG_ID		IN	NUMBER,
  I_EXP			IN	NUMBER,
  I_SND_RCV_ORG		IN	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code		OUT NOCOPY	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer  IS

l_account_num number := -1;
wf_err_num number := 0;
wf_err_code varchar2(500) ;
wf_err_msg varchar2(500) ;

BEGIN
   o_err_num := 0;
   o_err_code := '';
   o_err_msg := '';
   wf_err_code := '';
   wf_err_msg := '';

   l_account_num := CSTPSCWF.START_STD_WF(i_txn_id,
                                          i_txn_type_id,
                                          i_txn_act_id,
                                          i_txn_src_type_id,
                                          i_org_id,
                                          i_item_id,
                                          i_cost_element_id,
                                          i_acct_line_type,
                                          i_subinv,
                                          i_cg_id,
                                          i_resource_id,
                                          wf_err_num,
                                          wf_err_code,
                                          wf_err_msg);
   o_err_num := NVL(wf_err_num, 0);
   o_err_code := NVL(wf_err_code, 'No Error in CSTPSWF.START_STD_WF');
   o_err_msg := NVL(wf_err_msg, 'No Error in CSTPSWF.START_STD_WF');

   return l_account_num;

EXCEPTION

  when others then
    o_err_num := SQLCODE;
    o_err_msg := 'CSTPSCHK.STD_GET_UPDATE_ACCT_ID:' || substrb(SQLERRM,1,150);
    return -1;

END std_get_update_acct_id;

-- FUNCTION
-- std_get_update_scrap_acct_id         Routine to allow users to select the account
--                                      to be used for posting scrap adjustments in the
--                                      std cost update process for standard lot based jobs
--
-- INPUT PARAMETERS
-- I_ORG_ID
-- I_UPDATE_ID
-- I_WIP_ENTITY_ID        wip_entity_id of the work order
-- I_DEPT_ID              department_id of the department that runs the operation
-- I_OPERATION_SEQ_NUM    operation sequence number of the operation
--
-- RETURN VALUES
-- integer            -1        Use the department scrap account
--                              else use the value returned by this function
--
-- NOTE THE USE OF RESTRICT_REFERERENCES PRAGMA in the function declaration in the pkg spec.
-- This pragma is needed because this function is being called directly in a SQL statement.
-- Hence make sure you do not use any DML statements in this function and in any other
--  procedure or function called by this function
-- Error messages will not be printed in the standard cost update concurrent  log file
--  since out variables are not permitted in this function. So make sure you return valid
--  account numbers when you use this function.

function std_get_update_scrap_acct_id(
   I_ORG_ID             IN      NUMBER,
   I_UPDATE_ID          IN      NUMBER,
   I_WIP_ENTITY_ID      IN      NUMBER,
   I_DEPT_ID            IN      NUMBER,
   I_OPERATION_SEQ_NUM  IN      NUMBER
)
return integer IS
   l_err_num                    NUMBER := 0;
   l_err_msg                    VARCHAR2(240);
   l_est_scrap_acct_flag        NUMBER := 0;
   l_cost_adj_acct              NUMBER := 0;
BEGIN

   l_err_msg := '';

   /* Bug #3447776. Check to see if the organization is ESA disabled or if the job is
      non-standard. If so, return the WIP standard cost adjustment account. */
   l_est_scrap_acct_flag := WSMPUTIL.WSM_ESA_ENABLED(i_wip_entity_id, l_err_num, l_err_msg);

   IF l_est_scrap_acct_flag = 1 THEN
      return -1;
   ELSE
      SELECT WDJ.std_cost_adjustment_account
      INTO   l_cost_adj_acct
      FROM   wip_discrete_jobs WDJ
      WHERE  WDJ.wip_entity_id          = I_WIP_ENTITY_ID
      AND    WDJ.organization_id        = I_ORG_ID;

      return l_cost_adj_acct;
   END IF;


EXCEPTION
  when others then
    return -1;

END std_get_update_scrap_acct_id;

-- FUNCTION
-- std_get_est_scrap_rev_acct_id        Routine to allow users to select the account
--                                      to be used for posting estimated scrap reversal in the
--                                      Operation Yield Processor for scrap transactions.
--
-- INPUT PARAMETERS
-- I_ORG_ID
-- I_WIP_ENTITY_ID        wip_entity_id of the work order
-- I_DEPT_ID              department_id of the department that runs the operation
-- I_OPERATION_SEQ_NUM    operation sequence number of the operation
--
-- RETURN VALUES
-- integer            -1        Use the department scrap account
--                              else use the value returned by this function
--

function std_get_est_scrap_rev_acct_id(
   I_ORG_ID             IN      NUMBER,
   I_WIP_ENTITY_ID      IN      NUMBER,
   I_OPERATION_SEQ_NUM  IN      NUMBER
)
return integer IS
BEGIN

   return -1;

EXCEPTION
  when others then
    return -1;

END std_get_est_scrap_rev_acct_id;

--
-- OPM INVCONV umoogala  Process-Discrete Xfers Enh.
-- Hook to get transfer price
--
procedure Get_xfer_price_user_hook
  ( p_api_version                       IN            NUMBER
  , p_init_msg_list                     IN            VARCHAR2

  , p_transaction_uom                   IN            VARCHAR2
  , p_inventory_item_id                 IN            NUMBER
  , p_transaction_id                    IN            NUMBER
  , p_from_organization_id              IN            NUMBER
  , p_to_organization_id                IN            NUMBER
  , p_from_ou                           IN            NUMBER
  , p_to_ou                             IN            NUMBER

  , x_return_status                     OUT NOCOPY    NUMBER
  , x_msg_data                          OUT NOCOPY    VARCHAR2
  , x_msg_count                         OUT NOCOPY    NUMBER

  , x_transfer_price                    OUT NOCOPY    NUMBER
  , x_currency_code                     OUT NOCOPY    VARCHAR2
  )
IS

BEGIN
 x_return_status := -1;
 x_msg_count     := 0;
END;

/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    FUNCTION cg_or_subinv RETURN VARCHAR2                                   |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This hook controls the value return to mtl_category_accounts join       |
 |    Condition for Subledger Accounting part of the enhancement to           |
 |    permanent invnetory accounting for PJM and WMS organizations            |
 |                                                                            |
 |    The logic is:                                                           |
 |    -------------                                                           |
 |    For inventory organizations using perpectual actual cost method         |
 |    (average or fifo) the join condition to get category accounts is        |
 |    based on Cost Group                                                     |
 |                                                                            |
 |    For inventory organizations using perpectual standard cost method       |
 |    the join condition to get the category accounts is                      |
 |    based on Cost Group under the following setup:                          |
 |    1) The organization is Project Reference-able - PJM organization        |
 |    2) The PJM organization Cost Group Option is by Project                 |
 |    3) The Profile Option "CST: Category Account Level" is Cost Group       |
 |                                                                            |
 |    If the above setup is different, for standard costing organization      |
 |    the category account join condition is base on sub-inventories for      |
 |    backward compatibility reason to 11i Global Accounting Engine           |
 |                                                                            |
 | PARAMETERS:                                                                |
 |   INPUT:                                                                   |
 |     p_organization_id       organization id of the material transaction    |
 |                             being accounted                                |
 |     p_primary_cost_method   costing method of the organization             |
 |     p_wms_enabled           Indicator of Warehouse management organization |
 |     p_pjm_reference         Indicator of project reference-organization    |
 |     p_cost_group_accounting Indicator of accounting by project or inventory|
 |     p_cost_group_id         Cost Group Identifier                          |
 |     p_subinv                Subinventory code                              |
 |     p_ship_recv             For interorg transaction accounting            |
 |                             this flag will tell data passed is for         |
 |                             TRANSFER_ORGANIZATION_ID or                    |
 |                             ORGANIZATION_ID                                |
 |     p_mmt_id                Material transaction being accounted Identifier|
 |                                                                            |
 |                                                                            |
 | CALLED FROM                                                                |
 |     CST SLA extract cst_xla_inv_headers_v and cst_xla_pla_category_ref_v   |
 |                                                                            |
 | RETURN:                                                                    |
 |     Either: Cost Group ID or SUNINV_CODE                                   |
 | HISTORY                                                                    |
 |     04-Jun-2010   Herve Yu   Created                                       |
 *----------------------------------------------------------------------------*/
FUNCTION cg_or_subinv
   (p_organization_id       IN NUMBER
   ,p_primary_cost_method   IN NUMBER
   ,p_wms_enabled           IN VARCHAR2
   ,p_pjm_reference         IN NUMBER
   ,p_cost_group_accounting IN NUMBER
   ,p_cost_group_id         IN NUMBER
   ,p_subinv                IN VARCHAR2
   ,p_ship_recv             IN VARCHAR2
   ,p_mmt_id                IN NUMBER DEFAULT NULL)
RETURN VARCHAR2
IS
  FUNCTION cat_acc_level_value
  RETURN VARCHAR2
  IS
  BEGIN
    -- 1: Subinv
    -- 2: Cost Group
    IF g_cat_acc_level = '00' THEN
       g_cat_acc_level := FND_PROFILE.value('CST_CAT_ACC_LEVEL');
    END IF;
    RETURN g_cat_acc_level;
  END;
BEGIN
   --If you want to always use SUBINV, you can uncommented the next instruction
   --  RETURN  p_subinv
   --If you want to always use CostGroup, you can uncommented the next instruction
   --  RETURN TO_CHAR(p_cost_group_id);
   --You can use the parameter passed in the function to control the value you want to return
   --
   IF p_primary_cost_method <> 1 THEN
     RETURN TO_CHAR(p_cost_group_id);
   END IF;
   IF p_wms_enabled = 'Y' THEN
     RETURN TO_CHAR(p_cost_group_id);
   END IF;
   IF p_pjm_reference = 1 AND p_cost_group_accounting = 1 AND cat_acc_level_value = '2' THEN
     RETURN TO_CHAR(p_cost_group_id);
   END IF;
   RETURN p_subinv;
END;







END CSTPSCHK;

/
