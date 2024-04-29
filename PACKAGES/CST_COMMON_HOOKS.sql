--------------------------------------------------------
--  DDL for Package CST_COMMON_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_COMMON_HOOKS" AUTHID CURRENT_USER AS
/* $Header: CSTCOHKS.pls 120.0.12000000.3 2007/10/15 09:54:07 sbhati noship $ */

/*--------------------------------------------------------------------------------
| FUNCTION                                                                        |
|  Get_NRtax_amount                                                               |
|  This function is used to get the additional taxes involved in PO or            |
|  Internal order receiving transactions that will be used to calculate the       |
|  Encumbrance amount that is required to create the encumbrance reversal         |
|  entry for PO and Internal Orders receiving  transactions to Inventory/Expense  |
|  destinations.                                                                  |
|  RETURN VALUES :                                                                |
|  integer 1	Hook has been used get Recoverable and Non Recoverable tax amount |
|               from hook and use them for computing Encumbrance Amount.          |
|	   0  	No Taxes involved use original amount derived by system logic.    |
|         -1       Error in Hook                                                  |
|                                                                                 |
|  INPUT PARAMETERS                                                               |
|   I_ACCT_TXN_ID      (RCV_TRANSACTION_ID OR TRANSACTION_ID from mmt)            |
|   I_SOURCE_DOC_TYPE  (PO  OR REQ )                                              |
|   I_SOURCE_DOC_ID    (PO_DISTRIBUTION_ID OR REQUISITION_LINE_ID)                |
|   I_ACCT_SOURCE      (RCV OR MMT)                                               |
|   I_USER_ID                                                                     |
|   I_LOGIN_ID                                                                    |
|   I_REQ_ID                                                                      |
|   I_PRG_APPL_ID                                                                 |
|   I_PRG_ID                                                                      |
|   O_DOC_NR_TAX                                                                  |
|   O_DOC_REC_TAX                                                                 |
|   O_Err_Num                                                                     |
|   O_Err_Code                                                                    |
|   O_Err_Msg                                                                     |
---------------------------------------------------------------------------------*/
function Get_NRtax_amount(
  I_ACCT_TXN_ID	    IN 	NUMBER,
  I_SOURCE_DOC_TYPE IN  VARCHAR2,
  I_SOURCE_DOC_ID   IN  NUMBER,
  I_ACCT_SOURCE     IN  VARCHAR2,
  I_USER_ID	    IN	NUMBER,
  I_LOGIN_ID        IN	NUMBER,
  I_REQ_ID	    IN	NUMBER,
  I_PRG_APPL_ID	    IN	NUMBER,
  I_PRG_ID	    IN 	NUMBER,
  O_DOC_NR_TAX      OUT NOCOPY  NUMBER,
  O_DOC_REC_TAX     OUT NOCOPY  NUMBER,
  O_Err_Num	    OUT NOCOPY	NUMBER,
  O_Err_Code	    OUT NOCOPY	VARCHAR2,
  O_Err_Msg	    OUT NOCOPY	VARCHAR2
)
return integer;

END CST_Common_hooks;

 

/
