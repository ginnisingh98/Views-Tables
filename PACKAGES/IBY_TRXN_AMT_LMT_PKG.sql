--------------------------------------------------------
--  DDL for Package IBY_TRXN_AMT_LMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_TRXN_AMT_LMT_PKG" AUTHID CURRENT_USER as
/*$Header: ibytxnas.pls 120.1.12000000.1 2007/01/18 06:09:03 appldev ship $*/

    procedure eval_factor
	(
	i_ecappid	IN	iby_trxn_summaries_all.ecappid%TYPE,
	i_payeeid	IN	iby_trxn_summaries_all.payeeid%TYPE,
	i_amount	IN	iby_trxn_summaries_all.amount%TYPE,
	i_instrid	IN	iby_trxn_summaries_all.payerinstrid%TYPE,
	i_ccNumber	IN	iby_trxn_summaries_all.instrnumber%TYPE,
	i_master_key	IN	iby_payee.master_key%TYPE,
	o_score		OUT NOCOPY INTEGER
	);

end iby_trxn_amt_lmt_pkg;


 

/
