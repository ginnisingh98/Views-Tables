--------------------------------------------------------
--  DDL for Package Body CST_COMMON_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_COMMON_HOOKS" AS
/* $Header: CSTCOHKB.pls 120.0.12000000.3 2007/10/15 09:55:17 sbhati noship $ */

/*--------------------------------------------------------------------------------
| FUNCTION                                                                        |
|  Get_NRtax_amount                                                               |
|  This function is used to get the additional taxes involved in PO or            |
|  Internal order receiving transactions that will be used to calculate the       |
|  Encumbrance amount that is required to create the encumbrance reversal         |
|  entry for PO and Internal Orders receiving  transactions to Inventory/Expense  |
|  destinations.                                                                  |
|  integer 1	Hook has been used get Recoverable and Non Recoverable tax amount |
|               from hook and use them for computing Encumbrance Amount.          |
|	   0  	No Taxes involved use original amount derived by system logic.    |
|         -1       Error in Hook                                                  |
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
return integer IS
l_hook	          NUMBER;
l_err_num         NUMBER;
l_err_code        VARCHAR2(240);
l_err_msg         VARCHAR2(8000);
l_stmt_num        NUMBER;
l_currency_code   gl_sets_of_books.currency_code %TYPE;
undefined_source  EXCEPTION;
l_debug           VARCHAR2(80);

BEGIN
  /* Intialize local variables */
  l_hook          :=0;
  l_err_num       :=0;
  l_err_code      :='';
  l_err_msg       :='';
  l_currency_code :='';

l_debug := fnd_profile.value('MRP_DEBUG');
/* Getting Currency information for OU */
  l_stmt_num :=10;

IF l_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Get_NRtax_amount <<');
   fnd_file.put_line(fnd_file.log, 'Transaction_id  : '||I_ACCT_TXN_ID);
   fnd_file.put_line(fnd_file.log, 'Source Doc Type : '||I_SOURCE_DOC_TYPE);
   fnd_file.put_line(fnd_file.log, 'Source Doc ID   : '||I_SOURCE_DOC_ID);
   fnd_file.put_line(fnd_file.log, 'Accounting Src  : '||I_ACCT_SOURCE);
END IF;


IF ( I_SOURCE_DOC_TYPE IN ('PO','REQ') AND  I_ACCT_SOURCE ='MMT') THEN
	SELECT DISTINCT cod.currency_code
	  INTO l_currency_code
	  FROM mtl_material_transactions mmt,
	       cst_organization_definitions cod
	 WHERE mmt.organization_id    =cod.organization_id
	   AND mmt.transaction_id     =I_ACCT_TXN_ID;

ELSIF (I_SOURCE_DOC_TYPE IN ('PO') AND  I_ACCT_SOURCE ='RCV' ) THEN
	 SELECT DISTINCT gsob.currency_code
	   INTO l_currency_code
	   FROM po_distributions_all          pod,
		gl_sets_of_books              gsob
	  WHERE pod.set_of_books_id           =gsob.set_of_books_id
	    AND pod.po_distribution_id        =I_SOURCE_DOC_ID;
  ELSE
     raise undefined_source;
END IF;

IF l_debug = 'Y' THEN
   fnd_file.put_line(fnd_file.log, 'Currency Code : '||l_currency_code);
END IF;

  l_stmt_num :=20;
     /* Check for Indian Local Accounting This will return
            TRUE  - Indian Local Accounting used
            FALSE - Indian Local Accounting not used */

     IF ( AD_EVENT_REGISTRY_PKG.Is_Event_Done( p_Owner            => 'JA',
                                               p_Event_Name => 'JAI_EXISTENCE_OF_TABLES' ) = TRUE  )
       AND l_currency_code = 'INR'
     THEN
     l_stmt_num :=20;
     jai_encum_prc.fetch_encum_rev_amt( p_acct_txn_id        =>I_ACCT_TXN_ID,
				        p_source_doc_type    =>I_SOURCE_DOC_TYPE,
				        p_source_doc_id      =>I_SOURCE_DOC_ID,
				        p_acct_source        =>I_ACCT_SOURCE,
				        p_nr_tax_amount      =>O_DOC_NR_TAX,
				        p_rec_tax_amount     =>O_DOC_REC_TAX,
				        p_err_num            =>l_err_num,
				        p_err_code           =>l_err_code,
				        p_err_msg            =>l_err_msg);
	     l_hook:=1;
	     if(l_err_num <>0 )then

		o_err_num  := l_err_num;
		o_err_code := l_err_code;
		o_err_msg  := substr(l_err_msg,1,240);
		   return -1;
	     end if;
	     return 1;
     ELSE
             l_hook        :=0;
	     O_DOC_NR_TAX  :=0;
	     O_DOC_REC_TAX :=0;
   	     o_err_num     :=0;
	     o_err_code    :='';
	     o_err_msg     :='';
	     return 0;
     END IF;

EXCEPTION
  when undefined_source then
    o_err_num  := -1;
    o_err_code := 'undefined_source';
    o_err_msg  := 'CST_Common_hooks.Get_NRtax_amount: ' || to_char(l_stmt_num)|| substrb('Unrecognised Transactions Source',1,180);
    return -1;

  when others then
    o_err_num  := -1;
    o_err_code := SQLCODE;
    o_err_msg  := 'CST_Common_hooks.Get_NRtax_amount: ' || to_char(l_stmt_num)|| substrb(SQLERRM,1,180);
    return -1;
END Get_NRtax_amount;

END CST_Common_hooks;

/
