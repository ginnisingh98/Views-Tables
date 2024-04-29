--------------------------------------------------------
--  DDL for Package IBY_FREQ_OF_PURCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_FREQ_OF_PURCH_PKG" AUTHID CURRENT_USER as
/*$Header: ibyfops.pls 120.1.12000000.1 2007/01/18 06:06:06 appldev ship $*/

    PROCEDURE eval_factor
	(
	i_ecappid IN iby_trxn_summaries_all.ecappid%TYPE,
	i_payeeid IN iby_trxn_summaries_all.payeeid%TYPE,
	i_instrid IN iby_trxn_summaries_all.payerinstrid%TYPE,
	i_ccNumber IN iby_trxn_summaries_all.instrnumber%TYPE,
	i_master_key in iby_payee.master_key%TYPE,
	o_score  out NOCOPY integer
	);

end iby_freq_of_purch_pkg;


 

/
