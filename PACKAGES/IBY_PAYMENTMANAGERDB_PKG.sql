--------------------------------------------------------
--  DDL for Package IBY_PAYMENTMANAGERDB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYMENTMANAGERDB_PKG" AUTHID CURRENT_USER AS
/* $Header: ibypmmgs.pls 120.7.12010000.5 2010/01/21 06:28:52 sgogula ship $ */


/* Property name for the BEP which supports bank payables. */
C_PAYABLES_BEP_PROP_NAME CONSTANT VARCHAR2(100) := 'IBY_BANK_PAYMENT_SYSTEM_SUFFIX';


/* This record is used as an input to listBep and to getPmtName. */
/* It contains all the parameters that may be used for routing. */
TYPE RoutingAPIFields_rec_type IS RECORD (
        amount          NUMBER,
        instr_type      VARCHAR2(30),
        instr_subtype   VARCHAR2(30),
        currency        VARCHAR2(15),
        payee_id        VARCHAR2(80),
        cc_type         VARCHAR2(80),
        cc_num          VARCHAR2(80),
        aba_routing_no  VARCHAR2(80),
        bnf_routing_no  VARCHAR2(80),
        org_id          NUMBER,
        financing_app_type VARCHAR2(80),
        merchant_bank_country VARCHAR2(80),
        factor_flag     VARCHAR2(1),
        int_bank_acct_id NUMBER,
        int_bank_id     NUMBER,
        br_signed_flag  VARCHAR2(1),
        br_drawee_issued_flag VARCHAR2(1),
        ar_receipt_method_id NUMBER,
	payer_bank_country VARCHAR2(80),
	pmt_channel_code      VARCHAR2(30)
        );

/* This procedure is used across both Core and ExtendedSET   */

  /* APIs to fetch the bep configuration for the given      */
  /* transaction type.  The logic is pretty much the following:*/
  /* - For orainv, oraauth, oracredit, oraclosebatch, or       */
  /*   oraqrybatchstatus, go by the payment_name               */
  /* - For orapay or orasync, go by the bep suffix          */
  /* - For all other operations, go by the order_id            */
  /* */
  /* The parameters are the following:                         */
  /* - PayeeID_in: an IN parameter with the   */
  /*   id corresponding to PAYEE_ID in the IBY_PAYEE     */
  /*   table.                                                  */
  /* - order_id_in: an IN parameter with the order_id of the   */
  /*   current trxn.                                           */
  /* - payment_name_in: an optional IN parameter, routing rule   */
  /*   name				                           */
  /* - payment_operation_in: an IN parameter with the name of  */
  /*   the current operation type, e.g., orainv, ORAPMTREQ      */
  /* - BEPID_out: an OUT parameter with the numeric value  */
  /*   of the bep id corresponding to BEP_ID in the      */
  /*   IBY_BEPINFO table.                                       */
  /* - bep_suffix_in: an OUT parameter of bep suffix.          */
  /*   Corresponds to the SUFFIX column in the IBY_BEPINFO table*/
  /* - bep_url_out: an OUT parameter that contains the URL  */
  /*   to access the bep.  It's a combination of the base   */
  /*   URL in the IBY_BEPINFO table, plus add'l info based upon */
  /*   the bep pmtscheme plus the trxn type.                */
  /* - bep_key_out: an OUT parameter set up for this      */
  /*   payee/bep combination, the KEY in the      */
  /*   IBY_bepkey table.                                   */
  /* - bep_pmtscheme_out: an OUT parameter specifying the   */
  /*   bep API that the bep recognizes.  			*/
  /*    Corresponds to the PMTSCHEME_NAME in the  */
  /*   IBY_PMTSCHEMES table.                                    */
  /* - security_out: The value of OapfSecurity for the input   */
  /*   payment_name_in.  1=SET, which brings up a wallet.      */
  /*   2=SSL, which brings up an HTML page.                    */
  /* - setnoinit_flag_out: an OUT parameter which is set to 1  */
  /*   during an ORAPMTREQ for a SET bep.  This may not be    */
  /*   supported by all beps since standalone auth is not   */
  /*   an official SET functionality.                          */
  /* - bep_lang_in_out: an OUT parameter which returns the  */
  /*   bep language set in the configuration.               */
  /* - amount_in: an IN paramater that tells the amount. This    */
  /*   will be used to evaluate the routing rules                */
  /* - instrtype_in: an IN paramater that tells the instrument   */
  /*   used. This will be used to evaluate the routing rules.    */
  /*   and payment scheme					 */
  /* - bep_type_out: indicates whether the bep is a gateway or	 */
  /*    processor-model one					 */

 PROCEDURE listbep (
         p_amount                IN        iby_trxn_summaries_all.amount%type
                                           default null,
         p_payment_channel_code  IN        iby_trxn_summaries_all.payment_channel_code%type  default null,
         p_currency              IN        iby_trxn_summaries_all.currencynamecode%type default null,
         p_payee_id              IN        iby_trxn_summaries_all.payeeid%type
                                           default null,
         p_cc_type               IN        VARCHAR2 default null,
         p_cc_num                IN        iby_creditcard.ccnumber%type
                                           default null,
         p_aba_routing_no        IN        iby_bankacct.routingno%type
                                           default null,
         p_org_id                IN        iby_trxn_summaries_all.org_id%type
                                           default null,
         p_fin_app_type          IN        VARCHAR2 default null,
         p_transaction_id_in     IN        iby_trxn_summaries_all.TransactionID%TYPE default null,
         p_payment_operation_in  IN        VARCHAR2,
         p_ecappid_in            IN        iby_ecapp.ecappid%type default null,
         p_instr_subtype         IN        iby_trxn_summaries_all.instrsubtype%type default null,
         p_bnf_routing_no        IN        iby_bankacct.routingno%type,
         p_merchant_bank_country IN        VARCHAR2,
         p_factored_flag         IN        iby_trxn_summaries_all.factored_flag%type default null,
         p_int_bank_acct_id      IN        NUMBER,
         p_br_signed_flag        IN        iby_trxn_summaries_all.br_signed_flag%TYPE,
         p_br_drawee_issued_flag IN        iby_trxn_summaries_all.br_drawee_issued_flag%TYPE,
         p_ar_receipt_mth_id     IN        iby_trxn_summaries_all.ar_receipt_method_id%TYPE,
         px_payee_id_in_out      IN  OUT NOCOPY iby_payee.PayeeID%TYPE,
         px_order_id_in_out      IN  OUT NOCOPY VARCHAR2,
         px_payment_name_in_out  IN  OUT NOCOPY VARCHAR2,
         px_bep_lang_in_out      IN  OUT NOCOPY VARCHAR2,
         x_payee_username_out        OUT NOCOPY iby_payee.Username%TYPE,
         x_payee_passwd_out          OUT NOCOPY iby_payee.Password%TYPE,
         x_payee_operation_out       OUT NOCOPY NUMBER,
         x_bepid_out                 OUT NOCOPY iby_BEPInfo.BEPID%TYPE,
         x_bep_suffix_out            OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         x_bep_url_out               OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         x_bep_key_out               OUT NOCOPY IBY_BEPKeys.Key%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY IBY_BEPInfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY IBY_BEPInfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE,
         x_bep_type_out              OUT NOCOPY IBY_BEPInfo.Bep_Type%TYPE,
         x_fndcpt_user_profile_code_out OUT NOCOPY
                                     IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE,
         p_payer_bank_country IN        VARCHAR2
         );

 PROCEDURE listbep (
         p_amount                IN        iby_trxn_summaries_all.amount%type
                                           default null,
         p_payment_channel_code  IN        iby_trxn_summaries_all.payment_channel_code%type,
         p_currency              IN        iby_trxn_summaries_all.currencynamecode%type default null,
         p_payee_id              IN        iby_trxn_summaries_all.payeeid%type
                                           default null,
         p_cc_type               IN        VARCHAR2 default null,
         p_cc_num                IN        iby_creditcard.ccnumber%type
                                           default null,
         p_aba_routing_no        IN        iby_bankacct.routingno%type
                                           default null,
         p_org_id                IN        iby_trxn_summaries_all.org_id%type
                                           default null,
         p_fin_app_type          IN        VARCHAR2 default null,
         p_transaction_id_in     IN        iby_trxn_summaries_all.TransactionID%TYPE default null,
         p_payment_operation_in  IN        VARCHAR2,
         p_ecappid_in            IN        iby_ecapp.ecappid%type default null,
         p_instr_subtype         IN        iby_trxn_summaries_all.instrsubtype%type default null,
         p_bnf_routing_no        IN        iby_bankacct.routingno%type,
         p_factored_flag         IN        iby_trxn_summaries_all.factored_flag%type default null,
         p_int_bank_acct_id      IN        NUMBER,

         p_br_signed_flag        IN        iby_trxn_summaries_all.br_signed_flag%TYPE,
         p_br_drawee_issued_flag IN        iby_trxn_summaries_all.br_drawee_issued_flag%TYPE,
         p_ar_receipt_mth_id     IN        iby_trxn_summaries_all.ar_receipt_method_id%TYPE,
         px_payee_id_in_out      IN  OUT NOCOPY iby_payee.PayeeID%TYPE,
         px_order_id_in_out      IN  OUT NOCOPY VARCHAR2,
         px_payment_name_in_out  IN  OUT NOCOPY VARCHAR2,
         px_bep_lang_in_out      IN  OUT NOCOPY VARCHAR2,
         x_payee_username_out        OUT NOCOPY iby_payee.Username%TYPE,
         x_payee_passwd_out          OUT NOCOPY iby_payee.Password%TYPE,
         x_payee_operation_out       OUT NOCOPY NUMBER,
         x_bepid_out                 OUT NOCOPY iby_BEPInfo.BEPID%TYPE,
         x_bep_suffix_out            OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         x_bep_url_out               OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         x_bep_key_out               OUT NOCOPY IBY_BEPKeys.Key%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY IBY_BEPInfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY IBY_BEPInfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE,
         x_bep_type_out              OUT NOCOPY IBY_BEPInfo.Bep_Type%TYPE,
         x_fndcpt_user_profile_code_out OUT NOCOPY
                                     IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE
         );

 /*
  * Gets bep info by the bep suffix; method used by batch
  * trxns which have no routing data and which in any case require
  * eventual closure of batches for all bep's.
  *
  */
  PROCEDURE listbep (
         p_payee_id              IN  iby_bepkeys.OwnerId%TYPE,
         p_bepkey                IN  iby_bepkeys.KEY%TYPE,
         p_instr_type            IN  iby_trxn_summaries_all.InstrType%TYPE,
         px_bep_suffix_in_out    IN  OUT NOCOPY iby_bepinfo.Suffix%TYPE,
         x_bepid_out                 OUT NOCOPY iby_bepinfo.BepId%TYPE,
         x_bep_url_out               OUT NOCOPY iby_bepinfo.BaseUrl%TYPE,
         x_bep_pmtscheme_out         OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         x_bep_username_out          OUT NOCOPY iby_bepinfo.BEPUsername%TYPE,
         x_bep_passwd_out            OUT NOCOPY iby_bepinfo.BEPPassword%TYPE,
         x_security_out              OUT NOCOPY NUMBER,
         x_setnoinit_flag_out        OUT NOCOPY NUMBER,
         x_bep_type_out	             OUT NOCOPY iby_bepinfo.Bep_Type%TYPE,
         x_bep_lang_out      	     OUT NOCOPY VARCHAR2,
         x_lead_time_out             OUT NOCOPY iby_bepinfo.leadtime%TYPE
	);


  /* Internal procedure to get the bep configuration by the */
  /* payment name.                                             */

/*  PROCEDURE getBepByPmtName
       (payment_name_in   	IN  iby_routinginfo.PaymentMethodName%TYPE,
         o_payment_method_id    OUT NOCOPY iby_routinginfo.PaymentMethodID%TYPE,
         o_bepid             	OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         o_suffix          	OUT NOCOPY IBY_BEPInfo.suffix%TYPE,
         o_bep_base_url        	OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         o_pmtschemeName       	OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         instr_type_in     IN     iby_accttype.instrtype%type);*/

  /* Internal procedure that gets the bep configuration by  */
  /* the order_id for a non-SET bep (since it looks in the  */
  /* IBY_TRANSACTIONS table).                                   */
/*  PROCEDURE getBepByOrderId
        (order_id_in       IN      iby_trxn_summaries_all.TangibleID%TYPE,
         payee_id_in    IN      IBY_Payee.PayeeID%TYPE,
         o_bepid              OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         o_suffix          OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         o_bep_base_url        OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         o_pmtschemeName       OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         i_instrtype     IN     iby_accttype.instrtype%type);
*/
  /* Internal procedure that gets the bep configuration by  */
  /* the order_id for a SET bep (since it looks in the      */
  /* IBY_TRANSACTIONS_SET table).                               */
/*  PROCEDURE getBepByOrderId_SET
        (order_id_in       IN      iby_trxn_summaries_all.TangibleID%TYPE,
         payee_id_in    IN      IBY_Payee.PayeeID%TYPE,
         v_id              IN OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         v_suffix          IN OUT NOCOPY IBY_BEPInfo.Suffix%TYPE,
         v_base_url        IN OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         v_pmtscheme       IN OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE);
*/

  /* Internal procedure that gets the bep configuration by  */
  /* bep suffix.                                            */
  PROCEDURE getBepBySuffix
        (i_suffix          IN     IBY_BEPInfo.Suffix%TYPE,
         o_bepid              OUT NOCOPY IBY_BEPInfo.BEPID%TYPE,
         o_bep_base_url        OUT NOCOPY IBY_BEPInfo.BaseURL%TYPE,
         o_pmtschemename       OUT NOCOPY iby_pmtschemes.PmtSchemeName%TYPE,
         i_instrtype     IN     iby_accttype.instrtype%type );



  /* Internal procedure that finds the pmt method name using routing rules */
  PROCEDURE getPmtName(
     p_routingAPIfields          IN   RoutingAPIFields_rec_type,
     px_pmt_name_in_out          IN   OUT NOCOPY VARCHAR2 );


   -- reject any illegal payment operation
  procedure checkPaymentOperation(p_payment_operation_in IN VARCHAR2);


/* Procedure: checkPayeeByAccpPmtMthd
 * Function: to make sure given instrument type is supported by payee
*/

   PROCEDURE checkPayeeByAccpPmtMthd(i_payeeid iby_payee.payeeid%type,
				i_instr_type iby_accttype.instrtype%type);


/* Procedure: getBEPLang
 * Function:  fetch valid nlslang based on input lang
 */
PROCEDURE getBEPLang(i_bepid IN iby_bepinfo.bepid%type,
			io_beplang IN OUT NOCOPY iby_beplangs.beplang%type);
/*
 * This function is a wrapper around the getBEPLang() procedure.
 * The purpose of this wrapper is to make the NLS lang available
 * as a return parameter (so that it can be used in an SQL statement).
 */
/* comment out for now */
/* FUNCTION getNLSLang(i_bepid IN iby_bepinfo.bepid%type,
			io_beplang IN OUT NOCOPY iby_beplangs.beplang%type);
*/

PROCEDURE getPmtSchemeName(i_bepid IN iby_bepinfo.bepid%type,
         		i_instrtype IN iby_accttype.instrtype%type,
			o_pmtschemename OUT
				iby_pmtschemes.pmtschemename%type);

PROCEDURE getBepUrl(i_base_url IN iby_bepinfo.baseurl%type,
			i_payment_op IN VARCHAR2,
		    i_pmtschemename IN iby_pmtschemes.pmtschemename%type,
		    i_suffix IN iby_bepinfo.suffix%type,
		    o_bep_url OUT NOCOPY VARCHAR2);

PROCEDURE getBepIdByPmtName(i_paymentmethodname IN   VARCHAR2,
                            i_payeeid           IN   iby_payee.payeeid%type,
                            o_bepid             OUT NOCOPY iby_bepinfo.bepid%type,
                            o_bepkey            OUT NOCOPY iby_bepkeys.key%type,
                            o_fc_user_profile_code     IN   OUT NOCOPY VARCHAR2);

PROCEDURE getDefaultBepId(i_mpayeeid          IN  iby_payee.mpayeeid%type,
                          i_payment_channel_code  IN  iby_trxn_summaries_all.payment_channel_code%type,
                          o_bepid             OUT NOCOPY iby_bepinfo.bepid%type,
                          o_bepkey            OUT NOCOPY iby_bepkeys.key%type,
                          o_fndcpt_user_profile_code OUT NOCOPY
                                              IBY_FNDCPT_USER_CC_PF_VL.USER_CC_PROFILE_CODE%TYPE);


PROCEDURE getBepById(i_bepid IN iby_bepinfo.bepid%type,
		o_suffix OUT NOCOPY iby_bepinfo.suffix%type,
		o_baseurl OUT NOCOPY iby_bepinfo.baseurl%type,
		o_securityscheme OUT NOCOPY iby_bepinfo.securityscheme%type,
		o_bepusername OUT NOCOPY iby_bepinfo.bepusername%type,
		o_beppassword OUT NOCOPY iby_bepinfo.beppassword%type,
		o_beptype     OUT NOCOPY iby_bepinfo.bep_type%TYPE,
		o_leadtime    OUT NOCOPY iby_bepinfo.leadtime%TYPE);

PROCEDURE populateRoutingFields(
         p_amount         IN  iby_trxn_summaries_all.amount%type default null,
         p_instr_type     IN  iby_trxn_summaries_all.instrtype%type
                              default null,
         p_instr_subtype  IN  iby_trxn_summaries_all.instrsubtype%type
                              default null,
         p_currency       IN  iby_trxn_summaries_all.currencynamecode%type
                              default null,
         p_payee_id       IN  iby_trxn_summaries_all.payeeid%type default null,
         p_cc_type        IN  VARCHAR2 default null,
         p_cc_num         IN  iby_creditcard.ccnumber%type default null,
         p_aba_routing_no IN  iby_bankacct.routingno%type default null,
         p_bnf_routing_no IN  iby_bankacct.routingno%type default null,
         p_org_id         IN  iby_trxn_summaries_all.org_id%type default null,
         p_fin_app_type   IN  VARCHAR2 default null,
         p_merchant_bank_country IN VARCHAR2,
         p_factor_flag    IN iby_trxn_summaries_all.factored_flag%type,
         p_payer_bank_country  IN VARCHAR2,
         x_routingfields  OUT NOCOPY RoutingAPIFields_rec_type
);

END iby_paymentmanagerdb_pkg;

/
