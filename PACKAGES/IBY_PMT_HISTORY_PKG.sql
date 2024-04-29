--------------------------------------------------------
--  DDL for Package IBY_PMT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PMT_HISTORY_PKG" AUTHID CURRENT_USER as
/*$Header: ibypmths.pls 120.2 2005/10/30 05:48:58 appldev ship $*/

    procedure eval_factor
	(
	i_ecappid	IN	iby_trxn_summaries_all.ecappid%TYPE,
	i_payeeid	IN	iby_trxn_summaries_all.payeeid%TYPE,
	i_payerid	IN	iby_trxn_summaries_all.payerid%TYPE,
	i_instrid	IN	iby_trxn_summaries_all.payerinstrid%TYPE,
	i_ccNumber	IN	iby_trxn_summaries_all.instrnumber%TYPE,
	i_master_key	IN	iby_payee.master_key%TYPE,
	o_score		OUT NOCOPY INTEGER
	);

end iby_pmt_history_pkg;


/
