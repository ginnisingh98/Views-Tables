--------------------------------------------------------
--  DDL for Package CSTPACDP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPACDP" AUTHID CURRENT_USER AS
/* $Header: CSTACDPS.pls 120.2.12010000.4 2009/01/24 03:22:04 ipineda ship $ */

TYPE number_table IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

-- PROCEDURE
--  cost_txn			This processor writes cost distributions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_FOB_POINT
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_LAYER_ID		IN	NUMBER,
  I_FOB_POINT		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_COMM_ISS_FLAG	IN	NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  I_TPRICE_OPTION       IN      NUMBER,
  I_TXF_PRICE           IN      NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

procedure comm_iss_to_wip(
  I_TXN_ID              IN      NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_ORG_ID              IN      NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_TXFR_COST_GRP	IN	NUMBER,
  I_TXN_DATE            IN      DATE,
  I_P_QTY               IN      NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SOB_ID              IN      NUMBER,
  I_PRI_CURR            IN      VARCHAR2,
  I_ALT_CURR            IN      VARCHAR2,
  I_CONV_DATE           IN      DATE,
  I_CONV_RATE           IN      NUMBER,
  I_CONV_TYPE           IN      VARCHAR2,
  I_EXP_ITEM            IN      NUMBER,
  I_TXF_SUBINV		IN	VARCHAR2,
  I_TXN_ACT_ID          IN      NUMBER,
  I_TXN_SRC_ID          IN      NUMBER,
  I_SRC_TYPE_ID         IN      NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY     NUMBER,
  O_Error_Code          OUT NOCOPY     VARCHAR2,
  O_Error_Message       OUT NOCOPY     VARCHAR2
);

-- PROCEDURE
--  wip_cost_txn		This processor writes wip related
--				cost distributions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_TXN_DATE
--  I_P_QTY			Tramnsaction quantity.
--  I_SUBINV
--  I_TXN_ACT_ID
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_DIST_ACCT
--  I_SOB_ID			The set of books id.
--  I_PRI_CURR			The primary currency.
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure wip_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_DIST_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_FLOW_SCHEDULE	IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);


-- PROCEDURE
--  sub_cost_txn		This processor writes subinventory transfer
--				cost distributions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_TXN_DATE
--  I_P_QTY			Transaction quantity.
--  I_SUBINV
--  I_TXF_TXN_ID
--  I_TXN_ACT_ID
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_SOB_ID			The set of books id.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure sub_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_TXFR_COST_GRP	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXF_SUBINV		IN	VARCHAR2,
  I_TXF_TXN_ID		IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  inv_cost_txn		This processor processes distributions
--				for inventory related transactions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_TXN_DATE
--  I_P_QTY			Transaction quantity.
--  I_SUBINV
--  I_TXN_ACT_ID
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_DIST_ACCT
--  I_SOB_ID			The set of books id.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_SO_ACCOUNTING      Added for Revenue / COGS Matching: 1=COGS, 2=Def COGS
--  I_COGS_PERCENTAGE    Added for Revenue / COGS Matching
--  I_COGS_OM_LINE_ID    Added for Revenue / COGS Matching
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure inv_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_P_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_DIST_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_SO_ACCOUNTING   IN  NUMBER,
  I_COGS_PERCENTAGE IN  NUMBER,
  I_COGS_OM_LINE_ID IN  NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  interorg_cost_txn		This processor processes distributions
--				for interorg transactions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_TXN_DATE
--  I_P_QTY			Transaction quantity.
--  I_SUBINV
--  I_TXN_ORG_ID		Org id associated with this transaction.
--  I_TXF_ORG_ID		The transfer org id.
--  I_TXF_COST
--  I_TRP_COST
--  I_TXN_ACT_ID
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
-- OPM INVCONV umoogala Process-Discrete Xfer Enh.
-- Added new parameter for transfer price
procedure interorg_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_TXFR_COST_GRP	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_QTY		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_TXN_ORG_ID		IN	NUMBER,
  I_TXF_ORG_ID		IN	NUMBER,
  I_TXF_TXN_ID		IN	NUMBER,
  I_TXF_COST		IN	NUMBER,
  I_TRP_COST		IN	NUMBER,
  I_TRP_ACCT		IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_FOB_POINT		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_TXF_PRICE           IN      NUMBER,  -- OPM INVCONV umoogala
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);


-- PROCEDURE
--  avcu_cost_txn		This processor processes distributions
--				for average cost update transactions.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_TXN_DATE
--  I_QTY			Quantity adjusted.
--  I_TXN_ACT_ID
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_MAT_ACCT
--  I_MAT_OVHD_ACCT
--  I_RES_ACCT
--  I_OSP_ACCT
--  I_OVHD_ACCT
--  I_SOB_ID			The set of books id.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_EXP_ITEM
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure avcu_cost_txn(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_QTY			IN	NUMBER,
  I_TXN_ACT_ID		IN	NUMBER,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_EXP_ITEM		IN	NUMBER,
  I_ONHAND_VAR_ACCT     IN      NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  inventory_accounts		Inserts inventory debits/credits
--				to mtl_transaction_accounts.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_P_QTY			Quantity from the prespective of inventory.
--  I_SOB_ID			The set of books id.
--  I_TXN_DATE
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_EXP_ITEM
--  I_EXP_SUBINV		1 if the subinventory involved here is an
--				expense sub.  0 otherwise.
--  I_EXP_ACCT			expense account.
--  I_SUBINV
--  I_INTRANSIT			In average costing the intransit accounts
--				are the same as the inventory valuation
--				account.  Adding this flag only makes
--				it easier later if we do decide to use
--				different code.
--  I_SND_RCV			For interorg transactions, determines the
--				sending or receiving org.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure inventory_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG	IN	NUMBER,
  I_COST_TXN_ACTION_ID	IN	NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_EXP_ITEM		IN	NUMBER,
  I_EXP_SUBINV		IN	NUMBER,
  I_EXP_ACCT		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_INTRANSIT		IN	NUMBER,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  distribute_accounts		Insert elemental or one row in mtl
--				transaction_accounts using the costs
--				in mtl_cst_actual_cost_details.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_P_QTY			Quantity from the perspective of the account
--				we are posting to.
--  I_ACCT_LINE_TYPE
--  I_ELEMENTAL			1 - post elementally
--				0 - post as 1 lump sum
--  I_OVHD_ABSP			1 - materail overhead is absorbed on this
--				transaction. So exclude this level material
--				overhead costs.
--				2 - Exclude both this and previous level
--				material costs.
--  I_ACCT
--  I_MAT_ACCT
--  I_MAT_OVHD_ACCT
--  I_RES_ACCT
--  I_OSP_ACCT
--  I_OVHD_ACCT
--  I_SOB_ID			The set of books id.
--  I_TXN_DATE
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_SUBINV
--  I_SND_RCV			For interorg transactions, determines the
--				sending or receiving org.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--  I_COGS_OM_LINE_ID  Added for Revenue / COGS Matching
--
--
procedure distribute_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_COST_TXN_ACTION_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_ELEMENTAL		IN	NUMBER,
  I_OVHD_ABSP		IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2,
  I_COGS_OM_LINE_ID IN  NUMBER := 0
);

-- PROCEDURE
--  cfm_scrap_dist_accounts		Insert elemental or one row in mtl
--					transaction_accounts using the costs
--					in mtl_cst_actual_cost_details.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_P_QTY			Quantity from the perspective of the account
--				we are posting to.
--  I_ACCT_LINE_TYPE
--  I_ELEMENTAL		Don't use	1 - post elementally
--					0 - post as 1 lump sum
--  I_OVHD_ABSP		Don't use	1 - materail overhead is absorbed on this
--					transaction. So exclude this level material
--					overhead costs.
--					2 - Exclude both this and previous level
--					material costs.
--  I_ACCT
--  I_MAT_ACCT
--  I_MAT_OVHD_ACCT
--  I_RES_ACCT
--  I_OSP_ACCT
--  I_OVHD_ACCT
--  I_SOB_ID			The set of books id.
--  I_TXN_DATE
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_SUBINV
--  I_SND_RCV			For interorg transactions, determines the
--				sending or receiving org.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure cfm_scrap_dist_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_COST_GRP_ID		IN	NUMBER,
  I_COST_TXN_ACTION_ID	IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_ELEMENTAL		IN	NUMBER,
  I_OVHD_ABSP		IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_MAT_ACCT		IN	NUMBER,
  I_MAT_OVHD_ACCT	IN	NUMBER,
  I_RES_ACCT		IN	NUMBER,
  I_OSP_ACCT		IN	NUMBER,
  I_OVHD_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  ovhd_accounts		Do distribution for material overhead
--				absorption.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_P_QTY			Quantity from the perspective of the material
--				overhead subelement account.
--  I_SOB_ID			The set of books id.
--  I_TXN_DATE
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_SUBINV
--  I_SND_RCV			For interorg transactions, determines the
--				sending or receiving org.
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure ovhd_accounts(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_SUBINV		IN	VARCHAR2,
  I_SND_RCV		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  encumbrance_account		Do distribution for encumbrance amount
--
--
procedure encumbrance_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN 	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_ENC_AMOUNT		IN	NUMBER,
  I_P_QTY		IN	NUMBER,
  I_ENC_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  insert_account		Inserts one row in mtl_transaction_accounts
--				for the specified account and value.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID			The transaction to be processed.
--  I_ITEM_ID
--  I_VALUE
--  I_QTY
--  I_SOB_ID			The set of books id.
--  I_ACCT_LINE_TYPE
--  I_COST_ELEMENT_ID
--  I_RESOURCE_ID
--  I_TXN_DATE
--  I_TXN_SRC_ID
--  I_SRC_TYPE_ID
--  I_PRI_CURR			The primary currency.
--  I_ALT_CURR			The currency used on the trasaction.
--  I_CONV_DATE
--  I_CONV_RATE
--  I_CONV_TYPE
--  I_ACT_FLAG                  To indicate if encumbrance is used
--  I_USER_ID
--  I_LOGIN_ID
--  I_REQ_ID
--  I_PRG_APPL_ID
--  I_PRG_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
PROCEDURE insert_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  I_ITEM_ID		IN	NUMBER,
  I_VALUE		IN	NUMBER,
  I_QTY			IN	NUMBER,
  I_ACCT		IN	NUMBER,
  I_SOB_ID		IN	NUMBER,
  I_ACCT_LINE_TYPE	IN	NUMBER,
  I_COST_ELEMENT_ID	IN	NUMBER,
  I_RESOURCE_ID		IN	NUMBER,
  I_TXN_DATE		IN	DATE,
  I_TXN_SRC_ID		IN	NUMBER,
  I_SRC_TYPE_ID		IN	NUMBER,
  I_PRI_CURR		IN	VARCHAR2,
  I_ALT_CURR		IN	VARCHAR2,
  I_CONV_DATE		IN	DATE,
  I_CONV_RATE		IN	NUMBER,
  I_CONV_TYPE		IN	VARCHAR2,
  I_ACT_FLAG            IN      NUMBER,
  I_USER_ID		IN	NUMBER,
  I_LOGIN_ID    	IN	NUMBER,
  I_REQ_ID		IN	NUMBER,
  I_PRG_APPL_ID		IN	NUMBER,
  I_PRG_ID		IN 	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-- PROCEDURE
--  insert_accounts		Inserts one row in mtl_transaction_accounts
--				for the specified account and value.
--
-- INPUT PARAMETERS
--  I_ORG_ID			Organization id of associated with the actual
--				cost worker.
--  I_TXN_ID
--  O_Error_Num
--  O_Error_Code
--  O_Error_Message
--
--
procedure balance_account(
  I_ORG_ID		IN	NUMBER,
  I_TXN_ID		IN	NUMBER,
  O_Error_Num		OUT NOCOPY	NUMBER,
  O_Error_Code		OUT NOCOPY	VARCHAR2,
  O_Error_Message	OUT NOCOPY	VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  logical_cost_txn  This procedure is added for the 11i10 dropshipment   --
--                    project. It is called only for logical transactions  --
--                    to create the distributions. It has the same set of  --
--                    parameters as inv_cost_txn.                          --
--                                                                         --
-- End of comments                                                         --
-----------------------------------------------------------------------------
procedure logical_cost_txn(
  I_ORG_ID              IN          NUMBER,
  I_TXN_ID              IN          NUMBER,
  I_COST_GRP_ID         IN          NUMBER,
  I_ITEM_ID             IN          NUMBER,
  I_TXN_DATE            IN          DATE,
  I_P_QTY               IN          NUMBER,
  I_SUBINV              IN          VARCHAR2,
  I_TXN_ACT_ID          IN          NUMBER,
  I_TXN_SRC_ID          IN          NUMBER,
  I_SRC_TYPE_ID         IN          NUMBER,
  I_TXN_TYPE_ID         IN          NUMBER,
  I_DIST_ACCT           IN          NUMBER,
  I_SOB_ID              IN          NUMBER,
  I_PRI_CURR            IN          VARCHAR2,
  I_ALT_CURR            IN          VARCHAR2,
  I_CONV_DATE           IN          DATE,
  I_CONV_RATE           IN          NUMBER,
  I_CONV_TYPE           IN          VARCHAR2,
  I_SO_ACCOUNTING       IN          NUMBER,
  I_COGS_PERCENTAGE     IN          NUMBER,
  I_COGS_OM_LINE_ID     IN          NUMBER,
  I_EXP_ITEM            IN          NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  consigned_update_cost_txn    This procedure is added for the 11i10     --
--              dropshipment project to cost the new consigned price update--
--              transaction for retropricing. It has the same set of       --
--              input parameters as inv_cost_txn.                          --
--                                                                         --
-- End of comments                                                         --
-----------------------------------------------------------------------------
procedure consigned_update_cost_txn(
  I_ORG_ID              IN          NUMBER,
  I_TXN_ID              IN          NUMBER,
  I_COST_GRP_ID         IN          NUMBER,
  I_ITEM_ID             IN          NUMBER,
  I_TXN_DATE            IN          DATE,
  I_P_QTY               IN          NUMBER,
  I_SUBINV              IN          VARCHAR2,
  I_TXN_ACT_ID          IN          NUMBER,
  I_TXN_SRC_ID          IN          NUMBER,
  I_SRC_TYPE_ID         IN          NUMBER,
  I_DIST_ACCT           IN          NUMBER,
  I_SOB_ID              IN          NUMBER,
  I_PRI_CURR            IN          VARCHAR2,
  I_ALT_CURR            IN          VARCHAR2,
  I_CONV_DATE           IN          DATE,
  I_CONV_RATE           IN          NUMBER,
  I_CONV_TYPE           IN          VARCHAR2,
  I_EXP_ITEM            IN          NUMBER,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY  NUMBER,
  O_Error_Code          OUT NOCOPY  VARCHAR2,
  O_Error_Message       OUT NOCOPY  VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  inventory_accounts_std   This procedure is very similar to the basic   --
--       inventory_accounts() procedure.  It was necessary to add it for   --
--       the 11i10 dropshipment project because standard and average       --
--       organizations both use the same cost processor for the logical    --
--       transactions. Because there would have been substantial changes   --
--       to inventory_accounts() to accommodate standard costing, it made  --
--       more sense to just add this new procedure.                        --
--                                                                         --
-- End of comments                                                         --
-----------------------------------------------------------------------------
procedure inventory_accounts_std(
  I_ORG_ID              IN      NUMBER,
  I_TXN_ID              IN      NUMBER,
  I_COMM_ISS_FLAG       IN      NUMBER,
  I_COST_TXN_ACTION_ID  IN      NUMBER,
  I_COST_GRP_ID         IN      NUMBER,
  I_ITEM_ID             IN      NUMBER,
  I_P_QTY               IN      NUMBER,
  I_SOB_ID              IN      NUMBER,
  I_TXN_DATE            IN      DATE,
  I_TXN_SRC_ID          IN      NUMBER,
  I_SRC_TYPE_ID         IN      NUMBER,
  I_EXP_ITEM            IN      NUMBER,
  I_EXP_SUBINV          IN      NUMBER,
  I_EXP_ACCT            IN      NUMBER,
  I_SUBINV              IN      VARCHAR2,
  I_INTRANSIT           IN      NUMBER,
  I_SND_RCV             IN      NUMBER,
  I_PRI_CURR            IN      VARCHAR2,
  I_ALT_CURR            IN      VARCHAR2,
  I_CONV_DATE           IN      DATE,
  I_CONV_RATE           IN      NUMBER,
  I_CONV_TYPE           IN      VARCHAR2,
  I_USER_ID             IN      NUMBER,
  I_LOGIN_ID            IN      NUMBER,
  I_REQ_ID              IN      NUMBER,
  I_PRG_APPL_ID         IN      NUMBER,
  I_PRG_ID              IN      NUMBER,
  O_Error_Num           OUT NOCOPY      NUMBER,
  O_Error_Code          OUT NOCOPY      VARCHAR2,
  O_Error_Message       OUT NOCOPY      VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of comments                                                       --
--                                                                         --
-- PROCEDURE                                                               --
--  cost_process_discrete_trx
--       This process is called from cmlmcw.lpc for process-discrete xfers --
--       across process and discrete standard costing organizations.       --
--       Process Mfg. orgs are always marked as Standard Costing orgs.     --
--       This new procesure will only be called for these transactions.    --
--                                                                         --
--  Bug 4432078  OPM INVCONV umoogala  15-Apr-2005                         --
-- End of comments                                                         --
-----------------------------------------------------------------------------

PROCEDURE cost_process_discrete_trx(
  trans_id      IN BINARY_INTEGER
, prg_appid     IN BINARY_INTEGER
, prg_id        IN BINARY_INTEGER
, req_id        IN BINARY_INTEGER
, user_id       IN BINARY_INTEGER
, login_id      IN BINARY_INTEGER

, O_Error_Num     OUT NOCOPY VARCHAR2
, O_Error_Code    OUT NOCOPY VARCHAR2
, O_Error_Message OUT NOCOPY VARCHAR2
);

END CSTPACDP;

/
