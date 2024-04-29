--------------------------------------------------------
--  DDL for Package XTR_IAC_TRANSFERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_IAC_TRANSFERS_PKG" AUTHID CURRENT_USER AS
/* $Header: xtrimias.pls 120.1 2005/06/29 12:25:25 rjose noship $ */
--------------------------------------------------------------------------

  Procedure Log_IAC_Errors(p_Error_Code    In Varchar2,
                           p_Field_Name    In Varchar2 DEFAULT NULL);

  function VALID_CURRENCY(p_curr IN VARCHAR2) return boolean;


  function VALID_PARTY_ACCT(p_party      IN VARCHAR2,
                            p_party_acct IN VARCHAR2,
                            p_curr       IN VARCHAR2) return varchar2;

  function VALID_PRODUCT(p_product IN VARCHAR2) return boolean;

  function VALID_PORTFOLIO(p_comp      IN VARCHAR2,
                           p_portfolio IN VARCHAR2) return boolean;


  function VALID_DEALER_CODE(p_dealer_code IN varchar2) return boolean;

  function VALID_TRANSFER_AMOUNT (p_value IN NUMBER) return boolean;

  function VALID_DEAL_DATE (p_value IN DATE) return boolean;

  procedure CHECK_MANDATORY_FIELDS(
				ARec_IAC IN XTR_INTERACCT_TRANSFERS%rowtype,
				p_error OUT NOCOPY BOOLEAN);

  procedure VALIDATE_DEALS(ARec_IAC         IN  XTR_INTERACCT_TRANSFERS%rowtype,
                           p_Bank_Code_From OUT NOCOPY VARCHAR2,
                           p_Bank_Code_To   OUT NOCOPY VARCHAR2,
                           p_error          OUT NOCOPY BOOLEAN);

  procedure VALIDATE_SETTLE_DDA (p_validate_flag IN  BOOLEAN,
                                 p_settle_flag   IN  BOOLEAN,
                                 p_actual_settle IN  DATE,
                                 p_dual_auth_by  OUT NOCOPY VARCHAR2,
                                 p_dual_auth_on  OUT NOCOPY DATE,
                                 p_settle        OUT NOCOPY VARCHAR2,
                                 p_settle_no     OUT NOCOPY NUMBER,
                                 p_settle_no2    OUT NOCOPY NUMBER,
                                 p_settle_auth   OUT NOCOPY VARCHAR2,
                                 p_settle_date   OUT NOCOPY DATE,
                                 p_trans_mts     OUT NOCOPY VARCHAR2,
                                 p_audit_indic   OUT NOCOPY VARCHAR2);


  procedure INS_DEAL_DATE_AMTS (
		ARec_IAC      IN  XTR_INTERACCT_TRANSFERS%rowtype,
                p_From_Bank   IN  XTR_DEAL_DATE_AMOUNTS.LIMIT_PARTY%TYPE,
                p_To_Bank     IN  XTR_DEAL_DATE_AMOUNTS.LIMIT_PARTY%TYPE,
                p_tran_num    IN  NUMBER,
                p_Validated   IN  BOOLEAN,
                p_Settled     IN  BOOLEAN );

  procedure CREATE_IAC_DEAL(ARec_IAC      IN  XTR_INTERACCT_TRANSFERS%rowtype,
                            p_Validated   IN  BOOLEAN,
                            p_tran_num    IN  NUMBER);

  procedure TRANSFER_IAC_DEALS(
			ARec_IAC           IN  XTR_INTERACCT_TRANSFERS%rowtype,
                        p_Validated        IN  BOOLEAN,
                        p_Settled          IN  BOOLEAN,
                        user_error         OUT NOCOPY BOOLEAN,
                        mandatory_error    OUT NOCOPY BOOLEAN,
                        validation_error   OUT NOCOPY BOOLEAN,
                        p_tran_num         OUT NOCOPY NUMBER);

  G_iac_user   xtr_dealer_codes.dealer_code%TYPE;
  G_iac_date   DATE;
  G_sys_date   DATE;

 -- Constants  ----------------------------------------------------------------
  C_iac_type       constant VARCHAR2(3)  := 'IAC';
  C_ZBA            constant VARCHAR2(3)  := 'ZBA';
  C_CL             constant VARCHAR2(3)  := 'CL';


END;

 

/
