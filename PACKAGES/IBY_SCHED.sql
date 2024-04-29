--------------------------------------------------------
--  DDL for Package IBY_SCHED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_SCHED" AUTHID CURRENT_USER as
/*$Header: ibyscfis.pls 120.2.12010000.2 2009/07/07 12:30:19 sugottum ship $*/

procedure cardInfo (in_payerinstrid in iby_trans_fi_v.payerinstrid%type,
                    in_payeeid in iby_trans_fi_v.payeeid%type,
                    in_tangibleid in iby_trans_fi_v.tangibleid%type,
                    out_ccnumber_from out nocopy iby_creditcard_v.ccnumber%type,
                    out_expdate_from out nocopy iby_creditcard_v.expirydate%type,
                    out_accttype_from out nocopy iby_accttype.accttype%type,
                    out_name out nocopy varchar2,
                    out_bankid_to out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_to out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_to out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_to out nocopy iby_accttype.accttype%type,
                    out_acctno out nocopy iby_tangible.acctno%type,
                    out_refinfo out nocopy iby_tangible.refinfo%type,
                    out_memo out nocopy iby_tangible.memo%type,
                    out_currency out nocopy iby_tangible.currencynamecode%type);

procedure bankInfo (in_payerinstrid in iby_trans_fi_v.payerinstrid%type,
                    in_payeeid in iby_trans_fi_v.payeeid%type,
                    in_tangibleid in iby_trans_fi_v.tangibleid%type,
                    out_bankid_from out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_from out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_from out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_from out nocopy iby_accttype.accttype%type,
                    out_name out nocopy varchar2,
                    out_bankid_to out nocopy iby_ext_bank_accounts_v.bank_party_id%type,
                    out_branchid_to out nocopy iby_ext_bank_accounts_v.branch_party_id%type,
                    out_acctid_to out nocopy iby_ext_bank_accounts_v.ext_bank_account_id%type,
                    out_accttype_to out nocopy iby_accttype.accttype%type,
                    out_acctno out nocopy iby_tangible.acctno%type,
                    out_refinfo out nocopy iby_tangible.refinfo%type,
                    out_memo out nocopy iby_tangible.memo%type,
                    out_currency out nocopy iby_tangible.currencynamecode%type);

procedure update_ecapp (in_ecappid in iby_ecapp.ecappid%type);

procedure update_ecapp;

function updPmtStatus (in_psreqid in iby_trxn_fi.psreqid%type,
                        in_dtpmtprc in varchar2, -- YYYMMDD
                        in_pmtprcst in varchar2, -- 'PAID','UNPAID','FAILED','PAYFAILED'
                        in_srvrid in iby_trxn_fi.srvid%type,
                        in_refinfo in iby_trxn_fi.referencecode%type)
  return number; -- nonzero if rows were updated.

procedure update_trxn_status( i_unchanged_status            IN    NUMBER,
                              i_numTrxns                    IN    NUMBER,
                              i_status_arr                  IN    JTF_NUMBER_TABLE,
                              i_errLoc_arr                  IN    JTF_NUMBER_TABLE,
                              i_errCode_arr                 IN    JTF_VARCHAR2_TABLE_100,
                              i_errMsg_arr                  IN    JTF_VARCHAR2_TABLE_300,
                              i_tangibleId_arr              IN    JTF_VARCHAR2_TABLE_100,
                              i_trxnMId_arr                 IN    JTF_NUMBER_TABLE,
                              i_srvrId_arr                  IN    JTF_VARCHAR2_TABLE_100,
                              i_refCode_arr                 IN    JTF_VARCHAR2_TABLE_100,
                              i_auxMsg_arr                  IN    JTF_VARCHAR2_TABLE_300,
                              i_fee_arr                     IN    JTF_NUMBER_TABLE,
                              o_status_arr                  OUT NOCOPY JTF_NUMBER_TABLE,
                              o_error_code                  OUT NOCOPY NUMBER,
                              o_error_msg                   OUT NOCOPY VARCHAR2
                            );

end iby_sched;

/
