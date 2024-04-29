--------------------------------------------------------
--  DDL for Package CST_PRJMFG_ACCT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PRJMFG_ACCT_HOOK" AUTHID CURRENT_USER as
/* $Header: CSTPMHKS.pls 120.0.12010000.2 2010/02/18 01:25:49 ipineda ship $*/

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
  RETURN BOOLEAN ;


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
 |	 -x_return_status						      |
 |	 -x_msg_count      					              |
 |	 -x_msg_data           					              |
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
  FUNCTION  blueprint_sla_hook(p_transaction_id	                     NUMBER,
                                     p_table_source                  VARCHAR2,
                                     x_return_status  OUT NOCOPY     VARCHAR2,
                                     x_msg_count      OUT NOCOPY     NUMBER,
                                     x_msg_data       OUT NOCOPY     VARCHAR2)

  RETURN INTEGER;


END CST_PRJMFG_ACCT_HOOK;

/
