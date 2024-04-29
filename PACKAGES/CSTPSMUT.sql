--------------------------------------------------------
--  DDL for Package CSTPSMUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPSMUT" AUTHID CURRENT_USER AS
/* $Header: CSTSMUTS.pls 120.1 2005/11/10 04:40:23 sikhanna noship $ */

 /*
  BOM PatchSet I Enhancements for OSFM Costing -
  Added Procedures:
    COST_SPLIT_TXN
    COST_MERGE_TXN
    COST_BONUS_TXN
    COST_UPDATE_QTY_TXN
    GET_WIP_TXN_ID
    INSERT_WOO
    UPDATE_JOB_QUANTITY
    GET_JOB_VALUE
  Removed Procedures:
    GET_PARAMS
    UPDATE_OP_RES_REQ_INFO
    GET_CHARGE_VAL
    GET_SCRAP_VAL
  */

PROCEDURE COST_SPLIT_TXN (p_api_version            IN NUMBER DEFAULT 1.0,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2);

PROCEDURE COST_MERGE_TXN (p_api_version            IN NUMBER DEFAULT 1.0,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2);

PROCEDURE COST_UPDATE_QTY_TXN
                         (p_api_version            IN NUMBER DEFAULT 1.0,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2);

PROCEDURE COST_BONUS_TXN (p_api_version            IN NUMBER DEFAULT 1.0,
                          p_transaction_id         IN NUMBER,
                          p_mmt_transaction_id     IN NUMBER,
                          p_transaction_date       IN DATE,
                          p_prog_application_id    IN NUMBER,
                          p_program_id             IN NUMBER,
                          p_request_id             IN NUMBER,
                          p_login_id               IN NUMBER,
                          p_user_id                IN NUMBER,
                          x_err_num                IN OUT NOCOPY NUMBER,
                          x_err_code               IN OUT NOCOPY VARCHAR2,
                          x_err_msg                IN OUT NOCOPY VARCHAR2);

PROCEDURE GET_WIP_TXN_ID( x_wip_txn_id OUT NOCOPY    NUMBER,
                          x_err_num    IN OUT NOCOPY NUMBER,
                          x_err_code   IN OUT NOCOPY VARCHAR2,
                          x_err_msg    IN OUT NOCOPY VARCHAR2 );

PROCEDURE UPDATE_JOB_QUANTITY ( p_api_version          IN      NUMBER,
                                p_txn_id               IN      NUMBER,
                                x_err_num              IN OUT NOCOPY  NUMBER,
                                x_err_code             IN OUT NOCOPY  VARCHAR2,
                                x_err_msg              IN OUT NOCOPY  VARCHAR2 );
PROCEDURE GET_JOB_VALUE
	(p_api_version          in              number,
         p_lot_size             in		number,
         p_run_mode             in              number,
	 p_entity_id	        in		number,
	 p_intraop_step		in		number,
	 p_operation_seq_num	in		number,
         p_transaction_id       in              number,
         p_txn_type             in              number,
	 p_org_id		in		number,
	 x_err_num	        in OUT NOCOPY	number,
	 x_err_code	        in OUT NOCOPY	varchar2,
	 x_err_msg	    	in OUT NOCOPY	varchar2,
	 x_pl_mtl_cost		in OUT NOCOPY	number,
	 x_pl_mto_cost		in OUT NOCOPY	number,
	 x_pl_res_cost		in OUT NOCOPY	number,
	 x_pl_ovh_cost		in OUT NOCOPY	number,
	 x_pl_osp_cost		in OUT NOCOPY	number,
	 x_tl_res_cost		in OUT NOCOPY	number,
	 x_tl_ovh_cost		in OUT NOCOPY	number,
	 x_tl_osp_cost		in OUT NOCOPY	number);

 /*
  BOM PatchSet I Enhancements for OSFM Costing - End
  */


    /*------------------------------------------------------------------+
     | PROCEDURE BALANCE_MTA to balance any variance in MTA             |
    -------------------------------------------------------------------*/

    PROCEDURE BALANCE_ACCOUNTING (p_mtl_txn_id   IN NUMBER,
                                  p_wip_txn_id   IN NUMBER,
                                  p_txn_type     IN NUMBER,
                                  p_err_msg IN   OUT NOCOPY VARCHAR2,
                                  p_err_code IN  OUT NOCOPY VARCHAR2,
                                  p_err_num IN   OUT NOCOPY NUMBER);


    /*------------------------------------------------------------------+
    | INSERT_MAT_TXN: procedure to enter a dummy transaction in		|
    | mtl_material_transaction for cost processor:			|
    |		x_sm_txn_id => WIP lot split/merge transaction id	|
    |       p_mtl_txn_id => material transaction id			|
    |   	x_user_id, x_login_id, x_request_id, x_prog_appl_id,	|
    |		x_program_id => standard who columns			|
    |		x_acct_period_id => current accouting period id 	|
    |	    x_txn_qty => transaction quantity: starting lot quantity or |
    |				 resulting lot quantity			|
    |		x_action_id => transaction_action_id			|
    |			   cost processor: 40 (Split Issue), 41 (Split  |
    |   	 	      Return), 42 (Merge Issue), 43 (Merge      |
    |			Return), 44 (Translate Issue),  		|
    |			45 (Translate Return)				|
    |			   cost update: 46 Split/Merge Cost Update	|
    |	    x_source_type_id => transaction source type (5-job/schedule)|
    |	    p_txn_type_name => cost processor: Split Resulting, Split   |
    |				    Starting, Merge Resulting, Merge    |
    |			 	    Starting, Translate Resulting,      |
    |				Translate Starting			|
    |			       cost update: Split/Merge Cost Update     |
    |  	    p_wip_entity_id => Starting or resulting lot wip entity id, |
    |			       used to populate transaction_source_id   |
    +------------------------------------------------------------------*/
    PROCEDURE INSERT_MAT_TXN(   p_date              IN DATE,
				p_sm_txn_id         IN NUMBER,
				p_mtl_txn_id        IN NUMBER,
				p_acct_period_id    IN NUMBER,
				p_txn_qty           IN NUMBER,
				p_action_id         IN NUMBER,
				p_source_type_id    IN NUMBER,
				p_txn_type_name     IN VARCHAR2,
				p_wip_entity_id     IN NUMBER,
				p_operation_seq_num IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER,
                                p_request_id        IN NUMBER,
                                p_prog_appl_id      IN NUMBER,
                                p_program_id        IN NUMBER,
                                p_debug             IN VARCHAR2,
                                p_err_num           IN OUT NOCOPY NUMBER,
                                p_err_code          IN OUT NOCOPY VARCHAR2,
                                p_err_msg           IN OUT NOCOPY VARCHAR2);

    /*------------------------------------------------------------------+
    | INSERT_MAT_TXN: procedure to enter a dummy transaction in		|
    | mtl_material_transaction for cost processor:			|
    |		p_sm_txn_id => WIP lot split/merge transaction id	|
    |       p_wip_txn_id => wip transaction id			        |
    |   	x_user_id, x_login_id, x_request_id, x_prog_appl_id,	|
    |		x_program_id => standard who columns			|
    |		p_acct_period_id => current accouting period id 	|
    |	p_txn_type_name => cost processor: Split Resulting, Split       |
    |			 	    Starting, Merge Resulting, Merge    |
    |				    Starting, Translate Resulting,      |
    |				Translate Starting			|
    |	    p_wip_entity_id => Starting or resulting lot wip entity id, |
    |		               used to populate transaction_source_id   |
    |       p_txn_id => added to get UOM Bug#4307365                    |
    +------------------------------------------------------------------*/
    PROCEDURE INSERT_WIP_TXN(	p_date              IN DATE,
				p_sm_txn_id         IN NUMBER,
				p_wip_txn_id        IN NUMBER,
				p_acct_period_id    IN NUMBER,
				p_wip_entity_id     IN NUMBER,
				p_operation_seq_num IN NUMBER,
                                p_lookup_code       IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER,
                                p_request_id        IN NUMBER,
                                p_prog_appl_id      IN NUMBER,
                                p_program_id        IN NUMBER,
                                p_debug             IN VARCHAR2,
                                p_err_num           IN OUT NOCOPY NUMBER,
                                p_err_code          IN OUT NOCOPY VARCHAR2,
                                p_err_msg           IN OUT NOCOPY VARCHAR2,
                                p_txn_id            IN NUMBER);

    PROCEDURE INSERT_MTA(p_date            IN DATE,
                         p_min_acct_unit   IN NUMBER,
                         p_ext_prec        IN NUMBER,
                         p_sm_txn_type     IN NUMBER,
                         p_mtl_txn_id      IN NUMBER,
                         p_org_id          IN NUMBER,
                         p_wip_id          IN NUMBER,
                         p_acct_ltype      IN NUMBER,
                         p_txn_qty         IN NUMBER,
                         p_tl_mtl_cost     IN NUMBER,
                         p_tl_mto_cost     IN NUMBER,
                         p_tl_res_cost     IN NUMBER,
                         p_tl_ovh_cost     IN NUMBER,
                         p_tl_osp_cost     IN NUMBER,
                         p_cost_element_id IN NUMBER,
                         p_user_id         IN NUMBER,
                         p_login_id        IN NUMBER,
                         p_request_id      IN NUMBER,
                         p_prog_appl_id    IN NUMBER,
                         p_program_id      IN NUMBER,
                         p_debug           IN VARCHAR2,
                         p_err_num         IN OUT NOCOPY NUMBER,
                         p_err_code        IN OUT NOCOPY VARCHAR2,
                         p_err_msg         IN OUT NOCOPY VARCHAR2);

    /*------------------------------------------------------------------+
    | INSERT_MAT_TXN_ACCT: Procedure to enter the allocated total       |
    | mtl_material_transaction for cost processor 			|
    +------------------------------------------------------------------*/
    PROCEDURE INSERT_MAT_TXN_ACCT(p_date          IN DATE,
                                  p_min_acct_unit IN NUMBER,
				  p_ext_prec      IN NUMBER,
				  p_sm_txn_type   IN NUMBER,
				  p_mtl_txn_id    IN NUMBER,
			  	  p_org_id        IN NUMBER,
				  p_wip_id        IN NUMBER,
				  p_acct_ltype    IN NUMBER,
                                  p_txn_qty       IN NUMBER,
				  p_tl_mtl_cost   IN NUMBER,
				  p_tl_mto_cost   IN NUMBER,
				  p_tl_res_cost   IN NUMBER,
				  p_tl_ovh_cost   IN NUMBER,
				  p_tl_osp_cost   IN NUMBER,
                                  p_user_id       IN NUMBER,
                                  p_login_id      IN NUMBER,
                                  p_request_id    IN NUMBER,
                                  p_prog_appl_id  IN NUMBER,
                                  p_program_id    IN NUMBER,
                                  p_debug         IN VARCHAR2,
                                  p_err_num       IN OUT NOCOPY NUMBER,
                                  p_err_code      IN OUT NOCOPY VARCHAR2,
                                  p_err_msg       IN OUT NOCOPY VARCHAR2);

    PROCEDURE BONUS_MAT_TXN_ACCT(p_date          IN DATE,
				 p_ext_prec      IN NUMBER,
				 p_min_acct_unit IN NUMBER,
				 p_sm_txn_type   IN NUMBER,
				 p_sm_txn_id     IN NUMBER,
                                 p_mtl_txn_id    IN NUMBER,
                                 p_org_id        IN NUMBER,
                                 p_wip_id        IN NUMBER,
                                 p_acct_ltype    IN NUMBER,
                                 p_total_cost    IN NUMBER,
                                 p_user_id       IN NUMBER,
                                 p_login_id      IN NUMBER,
                                 p_request_id    IN NUMBER,
                                 p_prog_appl_id  IN NUMBER,
                                 p_program_id    IN NUMBER,
                                 p_debug         IN VARCHAR2,
                                 p_err_num       IN OUT NOCOPY NUMBER,
                                 p_err_code      IN OUT NOCOPY VARCHAR2,
                                 p_err_msg       IN OUT NOCOPY VARCHAR2);

    PROCEDURE INSERT_WIP_TXN_ACCT(p_date          IN DATE,
				  p_min_acct_unit IN NUMBER,
				  p_ext_prec      IN NUMBER,
				  p_sm_txn_id     IN NUMBER,
				  p_sm_txn_type   IN NUMBER,
				  p_wip_txn_id    IN NUMBER,
				  p_org_id        IN NUMBER,
				  p_wip_id        IN NUMBER,
				  p_acct_ltype    IN NUMBER,
                                  p_txn_qty       IN NUMBER,
				  p_pl_mtl_cost   IN NUMBER,
                                  p_pl_mto_cost   IN NUMBER,
                                  p_pl_res_cost   IN NUMBER,
                                  p_pl_ovh_cost   IN NUMBER,
                                  p_pl_osp_cost   IN NUMBER,
                                  p_user_id       IN NUMBER,
                                  p_login_id      IN NUMBER,
                                  p_request_id    IN NUMBER,
                                  p_prog_appl_id  IN NUMBER,
                                  p_program_id    IN NUMBER,
                                  p_debug         IN VARCHAR2,
                                  p_err_num       IN OUT NOCOPY NUMBER,
                                  p_err_code      IN OUT NOCOPY VARCHAR2,
                                  p_err_msg       IN OUT NOCOPY VARCHAR2);

    PROCEDURE BONUS_WIP_TXN_ACCT(p_date          IN DATE,
                                 p_ext_prec      IN NUMBER,
				 p_min_acct_unit IN NUMBER,
                                 p_sm_txn_id     IN NUMBER,
                                 p_sm_txn_type   IN NUMBER,
                                 p_wip_txn_id    IN NUMBER,
                                 p_org_id        IN NUMBER,
                                 p_wip_id        IN NUMBER,
                                 p_acct_ltype    IN NUMBER,
                                 p_total_cost    IN NUMBER,
                                 p_user_id       IN NUMBER,
                                 p_login_id      IN NUMBER,
                                 p_request_id    IN NUMBER,
                                 p_prog_appl_id  IN NUMBER,
                                 p_program_id    IN NUMBER,
                                 p_debug         IN VARCHAR2,
                                 p_err_num       IN OUT NOCOPY NUMBER,
                                 p_err_code      IN OUT NOCOPY VARCHAR2,
                                 p_err_msg       IN OUT NOCOPY VARCHAR2);

-- from WSMJBUDS

     PROCEDURE START_LOT (
	 		  p_sl_mtl_txn_id IN NUMBER,
			  p_sl_wip_txn_id IN NUMBER,
			  p_sl_wip_id IN NUMBER,
			  p_acct_period_id IN NUMBER,
                          p_user_id      IN NUMBER,
                          p_login_id     IN NUMBER,
                          p_request_id   IN NUMBER,
                          p_prog_appl_id IN NUMBER,
                          p_program_id   IN NUMBER,
                          p_err_num in OUT NOCOPY number,
                          p_err_code in OUT NOCOPY varchar2,
                          p_err_msg in OUT NOCOPY varchar2);

     PROCEDURE RESULT_LOT(
			  p_rl_mtl_txn_id  IN NUMBER,
			  p_rl_wip_txn_id  IN NUMBER,
			  p_rl_wip_id      IN NUMBER,
			  p_acct_period_id IN NUMBER,
                          p_user_id        IN NUMBER,
                          p_login_id       IN NUMBER,
                          p_request_id     IN NUMBER,
                          p_prog_appl_id   IN NUMBER,
                          p_program_id     IN NUMBER,
                          p_debug          IN VARCHAR2,
                          p_err_num        IN OUT NOCOPY NUMBER,
                          p_err_code       IN OUT NOCOPY VARCHAR2,
                          p_err_msg        IN OUT NOCOPY VARCHAR2);


END CSTPSMUT;

 

/
