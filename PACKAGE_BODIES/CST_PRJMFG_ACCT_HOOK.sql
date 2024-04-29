--------------------------------------------------------
--  DDL for Package Body CST_PRJMFG_ACCT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PRJMFG_ACCT_HOOK" as
/* $Header: CSTPMHKB.pls 120.0.12010000.2 2010/02/18 01:24:35 ipineda ship $*/
/* FND Logging Constants */
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'CST_XLA_PVT';
G_DEBUG              CONSTANT VARCHAR2(1)  :=  NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_LOG_HEAD           CONSTANT VARCHAR2(40) := 'cst.plsql.'||G_PKG_NAME;
G_LOG_LEVEL          CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


/*----------------------------------------------------------------------------*
 |  PRIVATE FUNCTION/PROCEDURES                                               |
 *----------------------------------------------------------------------------*/



/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    pm_use_hook_acct                                                        |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This function is an indicator to the cost collector program as to       |
 |    whether the accounting hook is to be used or not.  In order to use      |
 |    the accounting hook, this function should return the value 'TRUE'       |
 |    and code should be written. The function should never pass NULL values  |
 |    to the OUT arguments. 						      |
 |							                      |
 | PARAMETERS                                                                 |
 |       p_transaction_id,                                                    |
 |       p_transaction_action_id,	                                      |
 |       p_transaction_source_type_id,                                        |
 |       p_organization_id,                                                   |
 |       p_inventory_item_id,                                                 |
 |       p_cost_element_id,                                                   |
 |       p_resource_id,                                                       |
 |	 p_primary_quantity,						      |
 |	 p_transfer_organization_id,					      |
 |	 p_fob_point,						              |
 |	 p_wip_entity_id, 						      |
 |	 p_basis_resource_id,						      |
 |	 O_dr_code_combination_id,					      |
 |	 O_cr_code_combination_id					      |
 |                                                                            |
 |                                                                            |
 | CALLED FROM							              |
 |	 CST_PRJMFG_COST_COLLECTOR.PM_PROCESS_TXN_MMT                         |
 |	 CST_PRJMFG_COST_COLLECTOR.PM_PROCESS_TXN_WT                          |
 | HISTORY                                                                    |
 |    	 30-JUL-97  Hemant Gosain Created.                                    |
 *----------------------------------------------------------------------------*/
  FUNCTION  pm_use_hook_acct (  p_transaction_id 		NUMBER,
				p_transaction_action_id		NUMBER,
				p_transaction_source_type_id	NUMBER,
				p_organization_id		NUMBER,
				p_inventory_item_id		NUMBER,
				p_cost_element_id		NUMBER,
				p_resource_id			NUMBER,
				p_primary_quantity		NUMBER,
				p_transfer_organization_id	NUMBER,
				p_fob_point			NUMBER,
				p_wip_entity_id			NUMBER,
				p_basis_resource_id		NUMBER,
				O_dr_code_combination_id IN OUT NOCOPY	NUMBER,
				O_cr_code_combination_id IN OUT NOCOPY NUMBER)
  RETURN BOOLEAN
  IS
  BEGIN
	/* ----- PUT YOUR CODE HERE and RETURN TRUE ---------*/
	/* ----- END YOUR CODE HERE and RETURN TRUE ---------*/
  	RETURN FALSE;
  END pm_use_hook_acct;


/*----------------------------------------------------------------------------*
 | PUBLIC FUNCTION                                                            |
 |    blueprint_sla_hook                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This client extension is a function that works as an indicator to the   |
 |    cost manager program as to whether the accounting events in SLA should  |
 |    be created or not when Blue Print configuration takes place. This will  |
 |    be accomplished by customer extending this function using their custom  |
 |    logic to determine if a particular transaction should have the events   |
 |    created or not which will enable the Create Accounting for that specific|
 |    transaction.                                                            |
 |							                      |
 | PARAMETERS:                                                                |
 |       INPUT:                                                               |
 |       -p_transaction_id     Transaction ID                                 |
 |       -p_table_source       String identifying the source table of the     |
 |                             transaction that is calling the hook, the      |
 |                             possible values are:                           |
 |                             "MMT" for transaction belonging to table       |
 |                              MTL_MATERIAL_TRANSACTIONS                     |
 |                             "WCTI"  for transactions belonging to table    |
 |                              WIP_COST_TXN_INTERFACE for normal WIP         |
 |                              transactions                                  |
 |                              "WT" for wip transactions belonging to WIP    |
 |                               transactions table, but this will only be    |
 |                               called during the WIP Cost update accounting |
 |                               which is the only case were WT will exist    |
 |                               at the time the hook has been used, in other |
 |                               cases only WCTI will be there                |
 |       OUTPUT:                                                              |
 |	 -x_return_status_call						      |
 |	 -x_msg_count_call      					      |
 |	 -x_msg_data_call        					      |
 |                                                                            |
 |                                                                            |
 | CALLED FROM							              |
 |	 CST_XLA_PVT.Create_INVXLAEvent                                       |
 |	 CST_XLA_PVT.Create_WIPXLAEvent                                       |
 |	                                                                      |
 | RETURN VALUES                                                              |
 |       integer    1   Create SLA events in blue print org for this txn      |
 |                 -1   Error in the hook                                     |
 |                  0 or any other number                                     |
 |                      Do not create SLA events in blue print org for this   |
 |                      transaction  (Default)                                |
 | HISTORY                                                                    |
 |    	 04-Jan-2010   Ivan Pineda   Created                                  |
 *----------------------------------------------------------------------------*/
  FUNCTION  blueprint_sla_hook(p_transaction_id	                    NUMBER,
                               p_table_source                       VARCHAR2,
                               x_return_status       OUT NOCOPY     VARCHAR2,
                               x_msg_count           OUT NOCOPY     NUMBER,
                               x_msg_data            OUT NOCOPY     VARCHAR2)

  RETURN integer IS
  l_action_id NUMBER :=0;
  l_item_id NUMBER :=0;
  l_txn_type_mmt NUMBER :=0;
  l_txn_type_wt NUMBER :=0;
  l_api_name   	CONSTANT VARCHAR2(30)   := 'blueprint_sla_hook';
  l_api_version CONSTANT NUMBER         := 1.0;
    /* FND Logging */
   l_module   CONSTANT VARCHAR2(100)        := G_LOG_HEAD ||'.'||l_api_name;
   l_unexpLog CONSTANT BOOLEAN := (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL) AND FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);
   l_errorLog CONSTANT BOOLEAN := l_unexpLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
   l_eventLog CONSTANT BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
   l_procLog  CONSTANT BOOLEAN := l_eventLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
   l_stmtLog  CONSTANT BOOLEAN := l_procLog  and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     IF l_stmtLog THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                      'Transaction: '||p_transaction_id||
                      ': Source table: '||p_table_source );
      END IF;

     IF (p_table_source = 'MMT') THEN
     /* EXTEND  YOUR CODE FOR MATERIAL TRANSACTIONS IN MMT AND RETURN HERE*/
          return 0;
     ELSIF  (p_table_source = 'WCTI') THEN
     /* EXTEND YOUR CODE FOR WIP TRANSACTIONS IN WCTI AND RETURN HERE*/
           return 0;
     ELSIF  (p_table_source = 'WT') THEN
      /* EXTEND YOUR CODE FOR WIP TRANSACTIONS IN WT AND RETURN HERE
        ONLY IN THE CASE OF  WIP COST UPDATE ACCOUNTING WT WILL EXIST
        AT THE TIME OF CALLING THIS HOOK, FOR OTHER TRANSACTIONS WCTI
        SHOULD BE USED*/
          return 0;
      END IF;

      RETURN 0;
  EXCEPTION
      WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      x_msg_data := SQLERRM;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
       --IF l_stmtLog THEN
       -- FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
       --                'ERROR IN cst_blueprint_create_SLA');
      -- END IF;
      -- raise;
      fnd_file.put_line(FND_FILE.LOG,'Error in: CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook');
      raise_application_error(-20200, 'Error in: CST_PRJMFG_ACCT_HOOK.blueprint_sla_hook');
  END blueprint_sla_hook;

END CST_PRJMFG_ACCT_HOOK;

/
