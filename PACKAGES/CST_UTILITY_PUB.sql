--------------------------------------------------------
--  DDL for Package CST_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_UTILITY_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTUTILS.pls 120.3 2006/02/22 12:54:23 visrivas noship $ */


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   writeLogMessages                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API loops through the message stack and writes the messages to  --
-- log file                                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.4                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    10/12/00     Anitha B       Created                                 --
----------------------------------------------------------------------------
PROCEDURE writeLogMessages (p_api_version       IN   NUMBER,
                            p_msg_count         IN   NUMBER,
                            p_msg_data          IN   VARCHAR2,

                            x_return_status     OUT NOCOPY  VARCHAR2);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   getTxnCategoryId                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API loops through the message stack and writes the messages to  --
-- log file                                                               --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.4                                        --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    11/03/00     Hemant G       Created                                 --
----------------------------------------------------------------------------
PROCEDURE getTxnCategoryId (p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                  := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                  := FND_API.G_VALID_LEVEL_FULL,


                            p_txn_id		 IN   NUMBER,
                            p_txn_action_id      IN   NUMBER,
                            p_txn_source_type_id IN   NUMBER,
                            p_txn_source_id      IN   NUMBER,
                            p_item_id            IN   NUMBER,
                            p_organization_id    IN   NUMBER,

                            x_category_id        OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 );

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Std_CG_Acct_Flag                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API determines if the standard costing organization follows     --
-- cost group accounting. If yes, then it has PJM support. If the         --
-- organization ID provided is not standard costing organization, the     --
-- API will raise an error                                                --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
-- PJM support for Standard Costing Organizations                         --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    11/03/00     Anitha Dixit      Created                              --
----------------------------------------------------------------------------
PROCEDURE get_Std_CG_Acct_Flag (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,

                            p_organization_id    IN   NUMBER DEFAULT NULL,
                            p_organization_code  IN   VARCHAR2 DEFAULT NULL,

                            x_cg_acct_flag       OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2 );

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  insert_MTA      Function to ensure correct insertion of data into MTA  --
--                  Can be called from user code including the             --
--                  cst_dist_hook functions.  It derives the values for    --
--                  populating the table from what the user provides.      --
--                                                                         --
-- VERSION 1.0                                                             --
--                                                                         --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_ORG_ID           Organization ID - REQUIRED                          --
--  P_TXN_ID           Transaction ID - REQUIRED: should exist in MMT      --
--  P_USER_ID          User ID - REQUIRED                                  --
--  P_LOGIN_ID         Login ID                                            --
--  P_REQ_ID           Request ID                                          --
--  P_PRG_APPL_ID      Program Application ID                              --
--  P_PRG_ID           Program ID                                          --
--  P_ACCOUNT          Reference account - should correspond to            --
--                     gl_code_combinations.code_combination_id            --
--  P_DBT_CRDT         Debit / Credit flag - enter 1 for debit             --
--                                                -1 for credit            --
--                     will be used to set the sign for both base_txn_value--
--                     and primary_quantity in MTA                         --
--  P_LINE_TYP         Accounting line type - should correspond to a       --
--                     lookup for CST_ACCOUNTING_LINE_TYPE                 --
--  P_BS_TXN_VAL       Total txn value in base currency - Enter a positive --
--                     value, the sign will be determined by the value of  --
--                     P_DBT_CRDT                                          --
--  P_CST_ELEMENT      Cost element ID (1-5) - 1=material, 2=MOH, ...      --
--  P_RESOURCE_ID      Resource ID from BOM_RESOURCES - should correspond  --
--                     to bom_resources.resource_id                        --
--  P_ENCUMBR_ID       Encumbrance type ID - should correspond to          --
--                     gl_encumbrance_types.encumbrance_type_id            --
--                                                                         --
-- HISTORY:                                                                --
--    09/25/02     Bryan Kuntz      Created                                --
-- End of comments
-----------------------------------------------------------------------------
procedure insert_MTA (
  P_API_VERSION    IN         NUMBER,
  P_INIT_MSG_LIST  IN         VARCHAR2 default FND_API.G_FALSE,
  P_COMMIT         IN         VARCHAR2 default FND_API.G_FALSE,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT      OUT NOCOPY NUMBER,
  X_MSG_DATA       OUT NOCOPY VARCHAR2,
  P_ORG_ID         IN         NUMBER,
  P_TXN_ID         IN         NUMBER,
  P_USER_ID        IN         NUMBER,
  P_LOGIN_ID       IN         NUMBER default NULL,
  P_REQ_ID         IN         NUMBER default NULL,
  P_PRG_APPL_ID    IN         NUMBER default NULL,
  P_PRG_ID         IN         NUMBER default NULL,
  P_ACCOUNT        IN         NUMBER default NULL,
  P_DBT_CRDT       IN         NUMBER,
  P_LINE_TYP       IN         NUMBER,
  P_BS_TXN_VAL     IN         NUMBER,
  P_CST_ELEMENT    IN         NUMBER default NULL,
  P_RESOURCE_ID    IN         NUMBER default NULL,
  P_ENCUMBR_ID     IN         NUMBER default NULL
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_success              returns constant G_RET_STS_SUCCESS from--
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_success return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_error                returns constant G_RET_STS_ERROR from  --
--                                  fnd_api package                        --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_error return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_ret_sts_unexp_error          returns constant G_RET_STS_UNEXP_ERROR --
--                                  from fnd_api package                   --
-----------------------------------------------------------------------------
FUNCTION get_ret_sts_unexp_error return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_true                   returns constant G_TRUE from fnd_api package --
-----------------------------------------------------------------------------
FUNCTION get_true return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_false                  returns constant G_FALSE from fnd_api package--
-----------------------------------------------------------------------------
FUNCTION get_false return varchar2;

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- get_log                    returns constant LOG from fnd_file package   --
-----------------------------------------------------------------------------
FUNCTION get_log return number;

-----------------------------------------------------------------------------
-- PROCEDURE                                                               --
--  get_ZeroCost_Flag							   --
--                                                                         --
-- DESCRIPTION								   --
--  Transaction ID and organization ID are passed in to this procedure.	   --
--  With this information, check to see if:				   --
--    organization_id is EAM-enabled,					   --
--    transaction_source_type = 5,					   --
--    transaction_action_id = 1, 27, 33, 34				   --
--    subinventory_code is an expense subinventory			   --
--    inventory item is an asset item					   --
--    entity_type of wip_entity_id = 6, 7				   --
--  If any of these conditions are not passed, then return 0		   --
--  After checking that all these conditions pass, then check the	   --
--    issue_zero_cost_flag in wip_discrete_jobs of the work order;	   --
--    return the value of the flag					   --
--									   --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  P_COMMIT           Should the API commit before returning? True/False  --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
--  P_TXN_ID           Transaction ID - REQUIRED: should exist in MMT      --
--  P_ORG_ID           Organization ID - REQUIRED                          --
--  X_ZERO_COST_FLAG   Return 0 if none of the above conditions are met;   --
--		       Otherwise return the value of issue_zero_cost_flag  --
--		       of the work order				   --
--                                                                         --
-- HISTORY:                                                                --
--    07/01/03	Linda Soo	Created					   --
-----------------------------------------------------------------------------
PROCEDURE get_ZeroCostIssue_Flag (
  P_API_VERSION    IN         NUMBER,
  P_INIT_MSG_LIST  IN         VARCHAR2 default FND_API.G_FALSE,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT      OUT NOCOPY NUMBER,
  X_MSG_DATA       OUT NOCOPY VARCHAR2,
  P_TXN_ID         IN         NUMBER,
  X_ZERO_COST_FLAG OUT NOCOPY NUMBER
);

----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   get_Direct_Item_Charge_Acct                                          --
--                                                                        --
-- DESCRIPTION                                                            --
--  This API is from CST_eamCost_PUB package. Moved the API to this
--  package to minimuze the dependencies PO would have on the API.
--  Changes starting from J should be made to this API.
--
--  This API returns the account number given a EAM job
--  (entity type = 6,7) and purchasing category.  If the wip identity
--  doesn't refer to an EAM job type then -1 is returned, -1 is also
--  returned if no account is defined for that particular wip entity.
--
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11i.6                                        --
--   Costing Support for EAM                                              --
--   Called by the PO account generator
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    08/28/03		Linda Soo		Created
----------------------------------------------------------------------------
PROCEDURE get_Direct_Item_Charge_Acct (
                            p_api_version        IN   NUMBER,
                            p_init_msg_list      IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_commit             IN   VARCHAR2
                                                := FND_API.G_FALSE,
                            p_validation_level   IN   NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                            p_wip_entity_id      IN   NUMBER DEFAULT NULL,
			    x_material_acct	 OUT NOCOPY  NUMBER,
                            x_return_status      OUT NOCOPY  VARCHAR2,
                            x_msg_count          OUT NOCOPY  NUMBER,
                            x_msg_data           OUT NOCOPY  VARCHAR2,
			    p_category_id	 IN   NUMBER := -1);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- FUNCTION                                                                --
-- check_db_version         returns 1 if database version is 9i or greater --
-- PARAMETERS                                                              --
--  P_API_VERSION      API Version # - REQUIRED: enter 1.0                 --
--  P_INIT_MSG_LIST    Initialize message list? True/False                 --
--  X_RETURN_STATUS    Success/Error/Unexplained error - 'S','E', or 'U'   --
--  X_MSG_COUNT        Message Count - # of messages placed in message list--
--  X_MSG_DATA         Message Text - returns msg contents if msg_count = 1--
-----------------------------------------------------------------------------
FUNCTION check_db_version (
  P_API_VERSION    IN         NUMBER,
  P_INIT_MSG_LIST  IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
  X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
  X_MSG_COUNT      OUT NOCOPY NUMBER,
  X_MSG_DATA       OUT NOCOPY VARCHAR2
) return NUMBER;

----------------------------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
-- Get_Context_Value  Returns the Operating unit, Legal entity and ledger
--                    Associated with an organization.
-- PARAMETERS
-- p_api_version       API version Required
-- p_init_mes_list     Initilaize Message List (True/False)
-- p_commit            Whether to commit inside the API or Not
-- p_validation_level  Validation Level
-- x_return_status     Success/Error/Unexplained Error
-- x_msg_count         Message Count
-- x_msg_data          Message Text
-- p_org_id            Organization ID
-- p_ledger_id         Ledger associated with Organization
-- p_le_id             Legal Entity ID
-- p_ou_id             Operating Unit ID
-------------------------------------------------------------------------------
Procedure Get_Context_Value (
 p_api_version       IN          NUMBER,
 p_init_msg_list     IN          VARCHAR2 ,
 p_commit            IN          VARCHAR2 ,
 p_validation_level  IN          NUMBER  ,
 x_return_status     OUT NOCOPY  VARCHAR2,
 x_msg_count         OUT NOCOPY  NUMBER,
 x_msg_data          OUT NOCOPY  VARCHAR2,
 p_org_id            IN          NUMBER,
 p_ledger_id         OUT NOCOPY  NUMBER,
 p_le_id             OUT NOCOPY  NUMBER,
 p_ou_id             OUT NOCOPY  NUMBER);

----------------------------------------------------------------------------
-- Start of Comments
--
-- PROCEDURE
-- Get_Receipt_Event_Info:
-- API provides the name of the event class and entity code for a
-- receiving transaction type
-- PARAMETERS
-- p_api_version       API version Required
-- p_transaction_type  Receiving Transaction Type (from RCV_TRANSACTIONS)
-- p_entity_code       XLA Entity Code (RCV_ACCOUNTING_EVENTS)
-- p_application_id    Application Identifier for Cost Management
-- p_event_class_code  XLA Event Class Code
--------------------------------------------------------------------------

Procedure Get_Receipt_Event_Info (
  p_api_version      IN NUMBER,
  p_transaction_type IN VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_entity_code      OUT NOCOPY VARCHAR2,
  p_application_id   OUT NOCOPY NUMBER,
  p_event_class_code OUT NOCOPY VARCHAR2
);

END CST_Utility_PUB;

 

/
