--------------------------------------------------------
--  DDL for Package CSTPSCHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSCHK" AUTHID CURRENT_USER AS
/* $Header: CSTSCHKS.pls 120.1.12010000.2 2010/06/04 20:40:22 hyu ship $ */

/*-------------------------------------------------------------+
 | Public variable                                             |
 +-------------------------------------------------------------*/
g_cat_acc_level       VARCHAR2(2) := '00';

-- FUNCTION
--  std_cost_dist_hook		Cover routine to allow users to customize.
--				They will be able to circumvent the
--				standard cost distribution process.  This is
--                              called by inltcp.ppc.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_TXN_ID
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Err_Num
--  O_Err_Code
--  O_Err_Msg
--
-- RETURN VALUES
--  integer		1	Hook has been used.
--			0	Continue cost distribution for this transaction
--				as ususal.
--
FUNCTION std_cost_dist_hook(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Err_Num		OUT NOCOPY	NUMBER,
  O_Err_Code            OUT NOCOPY 	VARCHAR2,
  O_Err_Msg		OUT NOCOPY	VARCHAR2
)
return integer  ;



-- FUNCTION
--  std_cost_update_hook        Cover routine to allow users to customize.
--                              They will be able to circumvent the
--                              standard cost update process.  This is
--                              called by cmlicu.ppc.
--
-- INPUT PARAMETERS
--  i_org_id
--  i_cost_update_id
--  i_user_id
--  i_login_id
--  i_req_id
--  i_prg_appl_id
--  i_prg_id
--  o_err_num
--  o_err_code
--  o_err_msg
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
RETURN integer  ;


-- FUNCTION
--  std_get_account_id		Cover routine to allow users the flexbility
--				in determining the account they want to
--				post the inventory transaction to.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_TXN_ID
--  I_DEBIT_CREDIT		1 for debit and -1 for credit.
--  I_ACCT_LINE_TYPE		The accounting line type.
--  I_COST_ELEMENT_ID
--  I_RESOURCE_ID
--  I_SUBINV			The subinventory involved if there is one.
--  I_CG_ID			The cost group involved.
--  I_EXP			Indicates that the cost distributor is looking
--				for an expense account. 1 is exp account and 0
--                              is asset account.
--  I_SND_RCV_ORG		Indicates whether this is an sending or
--				receiving organization for interorg txns.
--                              1 is send and 2 is recv.
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Err_Num
--  O_Err_Code
--  O_Err_Msg
--
-- RETURN VALUES
--  integer		>0	Workflow returned account
--			-1  	Use the default account for distribution:.
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
return integer;

-- FUNCTION
--  std_get_update_acct_id	Cover routine to allow users the flexbility
--				in determining the account they want to
--				post the inventory transaction to.
--
-- INPUT PARAMETERS
--  I_ORG_ID
--  I_UPDATE_ID
--  I_DEBIT_CREDIT		1 for debit and -1 for credit.
--  I_ACCT_LINE_TYPE		The accounting line type.
--  I_COST_ELEMENT_ID
--  I_SUBINV			The subinventory involved if there is one.
--  I_CG_ID			The cost group involved.
--  I_EXP			Indicates that the cost distributor is looking
--				for an expense account. 1 is exp account and 0
--                              is asset account.
--  I_SND_RCV_ORG		Indicates whether this is an sending or
--				receiving organization for interorg txns.
--                              1 is send and 2 is recv.
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Err_Num
--  O_Err_Code
--  O_Err_Msg
--
-- RETURN VALUES
--  integer		>0	User selected account number
--			-1  	Use the default account for distribution.
--
function std_get_update_acct_id(
  I_ORG_ID		IN      NUMBER,
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
return integer;

-- FUNCTION
-- std_get_update_scrap_acct_id  	Routine to allow users to select the account
--          				to be used for posting scrap adjustments in the
--					std cost update process for standard lot based jobs
--
-- INPUT PARAMETERS
-- I_ORG_ID
-- I_UPDATE_ID
-- I_WIP_ENTITY_ID        wip_entity_id of the work order
-- I_DEPT_ID              department_id of the department that runs the operation
-- I_OPERATION_SEQ_NUM    operation sequence number of the operation
--
-- RETURN VALUES
-- integer            -1 	Use the department scrap account
--		       		else use the value returned by this function
--
-- NOTE THE USE OF RESTRICT_REFERERENCES PRAGMA
-- This pragma is needed because this function is being called directly in a SQL statement

function std_get_update_scrap_acct_id(
   I_ORG_ID		IN	NUMBER,
   I_UPDATE_ID		IN	NUMBER,
   I_WIP_ENTITY_ID	IN	NUMBER,
   I_DEPT_ID		IN	NUMBER,
   I_OPERATION_SEQ_NUM	IN	NUMBER
)
return integer;

-- FUNCTION
-- std_get_est_scrap_rev_acct_id   Routine to allow users to select the account
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
return integer;

-- Removing this restriction. This is not neccessary for database version 8i and higher.
-- PRAGMA RESTRICT_REFERENCES (std_get_update_scrap_acct_id, WNDS);


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
;

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
RETURN VARCHAR2;

END CSTPSCHK;

/
