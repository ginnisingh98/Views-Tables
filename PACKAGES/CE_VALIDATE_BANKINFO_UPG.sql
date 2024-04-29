--------------------------------------------------------
--  DDL for Package CE_VALIDATE_BANKINFO_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_VALIDATE_BANKINFO_UPG" AUTHID CURRENT_USER AS
/* $Header: cevlbkus.pls 120.1 2005/03/09 21:47:13 eliu noship $ */


FUNCTION ce_check_numeric(check_value VARCHAR2,
                               pos_from    NUMBER,
                               pos_for     NUMBER  )  RETURN VARCHAR2;


PROCEDURE COMPARE_BANK_AND_BRANCH_NUM(Xi_branch_num IN VARCHAR2,
					Xi_BANK_ID IN NUMBER);

FUNCTION COMPARE_ACCOUNT_NUM_AND_CD(Xi_account_num IN VARCHAR2,
					Xi_CD IN NUMBER,
					Xi_CD_length in number,
					Xi_CD_pos_from_right IN Number default 0) RETURN BOOLEAN;


FUNCTION CE_VAL_UNIQUE_TAX_PAYER_ID (p_country_code    IN  VARCHAR2,
                 		       p_taxpayer_id     IN  VARCHAR2
  			   		 ) RETURN VARCHAR2;

PROCEDURE ce_check_cross_module_tax_id(p_country_code     IN  VARCHAR2,
                               p_entity_name      IN  VARCHAR2,
                               p_taxpayer_id      IN  VARCHAR2,
                               p_return_ar        OUT NOCOPY VARCHAR2,
                               p_return_ap        OUT NOCOPY VARCHAR2,
                               p_return_hr        OUT NOCOPY VARCHAR2,
                               p_return_bk        OUT NOCOPY VARCHAR2);

FUNCTION ce_tax_id_check_algorithm(p_taxpayer_id  IN VARCHAR2,
                           		p_country   IN VARCHAR2,
                          		p_tax_id_cd IN VARCHAR2) RETURN VARCHAR2;



/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_*                                                    |
 --------------------------------------------------------------------- */

PROCEDURE CE_VALIDATE_CD(X_COUNTRY_NAME    IN varchar2,
			  X_CD	           IN  varchar2,
                          X_BANK_NUMBER    IN varchar2,
                          X_BRANCH_NUMBER  IN varchar2,
                          X_ACCOUNT_NUMBER IN varchar2);
			  --p_init_msg_list  IN  VARCHAR2 := FND_API.G_FALSE,
    			  --x_msg_count      OUT NOCOPY NUMBER,
			  --x_msg_data       OUT NOCOPY VARCHAR2);
                          --X_VALUE_OUT      OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_BRANCH(X_COUNTRY_NAME 	IN  varchar2,
                             --X_BANK_NUMBER 	IN  varchar2,
                             X_BRANCH_NUMBER 	IN  varchar2,
                             --X_BANK_NAME 	IN  varchar2,
                             --X_BRANCH_NAME 	IN  varchar2,
                             X_BRANCH_NAME_ALT IN  varchar2,
                             X_BANK_ID 		IN  NUMBER,
                             --X_BRANCH_ID 	IN  NUMBER,
                             X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
    			     x_msg_count      OUT NOCOPY NUMBER,
			     x_msg_data       OUT NOCOPY VARCHAR2,
                             X_VALUE_OUT      OUT NOCOPY varchar2,
			    x_message_name_all OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_ACCOUNT(X_COUNTRY_NAME 	IN varchar2,
                              X_BANK_NUMBER 	IN varchar2,
                              X_BRANCH_NUMBER 	IN varchar2,
                              X_ACCOUNT_NUMBER 	IN varchar2,
                              --X_BANK_ID 	IN number,
                              --X_BRANCH_ID 	IN number,
                              --X_ACCOUNT_ID 	IN number,
                              --X_CURRENCY_CODE 	IN varchar2,
                              X_ACCOUNT_TYPE 	IN varchar2,
                              X_ACCOUNT_SUFFIX  IN varchar2,
                              X_SECONDARY_ACCOUNT_REFERENCE  IN varchar2,
                              X_ACCOUNT_NAME 	IN varchar2,
                              X_CD	 	IN varchar2,
                              X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			      p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    			      x_msg_count      OUT NOCOPY NUMBER,
			      x_msg_data       OUT NOCOPY VARCHAR2,
		              X_VALUE_OUT      OUT NOCOPY varchar2,
			    x_message_name_all OUT NOCOPY varchar2);

PROCEDURE CE_VALIDATE_BANK( X_COUNTRY_NAME    IN varchar2,
                            X_BANK_NUMBER     IN varchar2,
                            X_BANK_NAME       IN varchar2,
                            X_BANK_NAME_ALT   IN varchar2,
                            X_TAX_PAYER_ID    IN varchar2,
                            --X_BANK_ID 	      IN NUMBER,
                            X_VALIDATION_TYPE	IN  varchar2 := 'ALL',
			    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    			    x_msg_count      OUT NOCOPY NUMBER,
			    x_msg_data       OUT NOCOPY VARCHAR2,
	                    X_VALUE_OUT      OUT NOCOPY varchar2,
			    x_message_name_all OUT NOCOPY varchar2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_CD_*                                                 |
 --------------------------------------------------------------------- */

PROCEDURE ce_validate_cd_pt(Xi_CD               VARCHAR2,
                                 Xi_PASS_MAND_CHECK  VARCHAR2,
                                 Xi_X_BANK_NUMBER    VARCHAR2,
                                 Xi_X_BRANCH_NUMBER  VARCHAR2,
                                 Xi_X_ACCOUNT_NUMBER VARCHAR2);

PROCEDURE ce_validate_cd_es(Xi_CD               VARCHAR2,
                                 Xi_PASS_MAND_CHECK  VARCHAR2,
                                 Xi_X_BANK_NUMBER    VARCHAR2,
                                 Xi_X_BRANCH_NUMBER  VARCHAR2,
                                 Xi_X_ACCOUNT_NUMBER VARCHAR2);


PROCEDURE ce_validate_cd_fr(Xi_CD               VARCHAR2,
                                 Xi_PASS_MAND_CHECK  VARCHAR2,
                                 Xi_X_BANK_NUMBER    VARCHAR2,
                                 Xi_X_BRANCH_NUMBER  VARCHAR2,
                                 Xi_X_ACCOUNT_NUMBER VARCHAR2);

-- new validations for check digits 5/14/02

procedure CE_VALIDATE_CD_DE(Xi_CD in varchar2,
                            Xi_X_ACCOUNT_NUMBER in varchar2);

procedure CE_VALIDATE_CD_GR(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2);

procedure CE_VALIDATE_CD_IS(Xi_CD in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2);

procedure CE_VALIDATE_CD_IT(Xi_CD in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2);

procedure CE_VALIDATE_CD_LU(Xi_CD in varchar2,
                                      Xi_X_BANK_NUMBER in varchar2,
                                      Xi_X_BRANCH_NUMBER in varchar2,
                                      Xi_X_ACCOUNT_NUMBER in varchar2);
                                      --Xo_VALUE_OUT OUT NOCOPY varchar2);

procedure CE_VALIDATE_CD_SE(Xi_CD in varchar2,
                            Xi_X_ACCOUNT_NUMBER in varchar2);

/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BRANCH_*                                             |
 --------------------------------------------------------------------- */


PROCEDURE ce_validate_branch_at(Xi_BRANCH_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

PROCEDURE ce_validate_branch_pt(Xi_BRANCH_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2);

PROCEDURE ce_validate_branch_fr(Xi_BRANCH_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_branch_es(Xi_BRANCH_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                     Xo_VALUE_OUT OUT NOCOPY varchar2);



PROCEDURE ce_validate_branch_br(Xi_BRANCH_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

-- new branch validations 5/14/02

procedure CE_VALIDATE_BRANCH_DE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);

procedure CE_VALIDATE_BRANCH_GR(Xi_BRANCH_NUMBER  in varchar2);

procedure CE_VALIDATE_BRANCH_IS(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER,
                                Xo_VALUE_OUT OUT NOCOPY varchar2);


procedure CE_VALIDATE_BRANCH_IE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);

procedure CE_VALIDATE_BRANCH_IT(Xi_BRANCH_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2);

procedure CE_VALIDATE_BRANCH_LU(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);


procedure CE_VALIDATE_BRANCH_PL(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);


procedure CE_VALIDATE_BRANCH_SE(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);


procedure CE_VALIDATE_BRANCH_CH(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);


procedure CE_VALIDATE_BRANCH_GB(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER);


procedure CE_VALIDATE_BRANCH_US(Xi_BRANCH_NUMBER    in varchar2,
        	                        Xi_PASS_MAND_CHECK  in varchar2,
                	                Xo_VALUE_OUT 	   OUT NOCOPY varchar2);


-- new branch validations 10/19/04

procedure CE_VALIDATE_BRANCH_AU(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BANK_ID        in NUMBER,
                                Xi_PASS_MAND_CHECK VARCHAR2);

procedure CE_VALIDATE_BRANCH_IL(Xi_BRANCH_NUMBER  in varchar2,
                                Xi_PASS_MAND_CHECK VARCHAR2);


procedure CE_VALIDATE_BRANCH_NZ(Xi_BRANCH_NUMBER  in varchar2,
                                Xi_PASS_MAND_CHECK VARCHAR2);

procedure CE_VALIDATE_BRANCH_JP(Xi_BRANCH_NUMBER  in varchar2,
				Xi_BRANCH_NAME_ALT  in varchar2,
                                Xi_PASS_MAND_CHECK VARCHAR2,
					Xi_VALIDATION_TYPE in varchar2);



/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_ACCOUNT_*                                            |
 --------------------------------------------------------------------- */

PROCEDURE ce_validate_account_at(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_account_pt(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

PROCEDURE ce_validate_account_be(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2);


PROCEDURE ce_validate_account_dk(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_account_fr(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT  NOCOPY varchar2);


PROCEDURE ce_validate_account_nl(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2);


PROCEDURE ce_validate_account_es(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_account_no(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2);


PROCEDURE ce_validate_account_fi(Xi_ACCOUNT_NUMBER         VARCHAR2,
                                      Xi_PASS_MAND_CHECK VARCHAR2);


-- new account validations 5/14/02

procedure CE_VALIDATE_ACCOUNT_DE(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

procedure CE_VALIDATE_ACCOUNT_GR(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


procedure CE_VALIDATE_ACCOUNT_IS(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


procedure CE_VALIDATE_ACCOUNT_IE(Xi_ACCOUNT_NUMBER  in varchar2);


procedure CE_VALIDATE_ACCOUNT_IT(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

procedure CE_VALIDATE_ACCOUNT_LU(Xi_ACCOUNT_NUMBER  in varchar2);

procedure CE_VALIDATE_ACCOUNT_PL(Xi_ACCOUNT_NUMBER  in varchar2);

procedure CE_VALIDATE_ACCOUNT_SE(Xi_ACCOUNT_NUMBER  in varchar2);

procedure CE_VALIDATE_ACCOUNT_CH(Xi_ACCOUNT_NUMBER  in varchar2,
  					Xi_ACCOUNT_TYPE in varchar2,
					Xi_VALIDATION_TYPE in varchar2 );

procedure CE_VALIDATE_ACCOUNT_GB(Xi_ACCOUNT_NUMBER  in varchar2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

procedure CE_VALIDATE_ACCOUNT_BR(Xi_ACCOUNT_NUMBER  in varchar2,
                                     Xi_SECONDARY_ACCOUNT_REFERENCE in varchar2);

-- new account validations 10/19/04

procedure CE_VALIDATE_ACCOUNT_AU(Xi_ACCOUNT_NUMBER  in varchar2);
procedure CE_VALIDATE_ACCOUNT_IL(Xi_ACCOUNT_NUMBER  in varchar2);
procedure CE_VALIDATE_ACCOUNT_NZ(Xi_ACCOUNT_NUMBER  in varchar2,
	                              Xi_ACCOUNT_SUFFIX	in varchar2,
					Xi_VALIDATION_TYPE in varchar2);

procedure CE_VALIDATE_ACCOUNT_JP(Xi_ACCOUNT_NUMBER  in varchar2,
	                              Xi_ACCOUNT_TYPE	in varchar2,
					Xi_VALIDATION_TYPE in varchar2);



/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_BANK_*                                               |
 --------------------------------------------------------------------- */

PROCEDURE ce_validate_bank_es(Xi_BANK_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                     Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_bank_fr(Xi_BANK_NUMBER         VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);


PROCEDURE ce_validate_bank_pt(Xi_BANK_NUMBER         VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2);


PROCEDURE ce_validate_bank_br(Xi_BANK_NUMBER          VARCHAR2,
                                     Xi_PASS_MAND_CHECK VARCHAR2,
                                      Xo_VALUE_OUT OUT NOCOPY varchar2);

-- new bank validations 5/14/02


procedure CE_VALIDATE_BANK_DE(Xi_BANK_NUMBER  in varchar2);

procedure CE_VALIDATE_BANK_GR(Xi_BANK_NUMBER  in varchar2);

procedure CE_VALIDATE_BANK_IS(Xi_BANK_NUMBER  in varchar2,
                              Xo_VALUE_OUT OUT NOCOPY varchar2);

procedure CE_VALIDATE_BANK_IE(Xi_BANK_NUMBER  in varchar2);

procedure CE_VALIDATE_BANK_IT(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2);

procedure CE_VALIDATE_BANK_LU(Xi_BANK_NUMBER  in varchar2);


procedure CE_VALIDATE_BANK_PL(Xi_BANK_NUMBER  in varchar2);

procedure CE_VALIDATE_BANK_SE(Xi_BANK_NUMBER  in varchar2);

procedure CE_VALIDATE_BANK_CH(Xi_BANK_NUMBER  in varchar2);


procedure CE_VALIDATE_BANK_GB(Xi_BANK_NUMBER  in varchar2);


procedure CE_VALIDATE_BANK_CO(Xi_COUNTRY_NAME in varchar2,
				Xi_BANK_NAME  in varchar2,
				Xi_TAX_PAYER_ID  in varchar2);

-- new bank validations 10/19/04

procedure CE_VALIDATE_BANK_AU(Xi_BANK_NUMBER  in varchar2);
procedure CE_VALIDATE_BANK_IL(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2);
procedure CE_VALIDATE_BANK_NZ(Xi_BANK_NUMBER  in varchar2,
                                      Xi_PASS_MAND_CHECK in varchar2);

procedure CE_VALIDATE_BANK_JP(Xi_BANK_NUMBER  in varchar2,
				Xi_BANK_NAME_ALT  in varchar2,
                                Xi_PASS_MAND_CHECK in varchar2,
					Xi_VALIDATION_TYPE in varchar2);

-- added 10/25/04
/* --------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|      CE_VALIDATE_MISC_*   other misc validations
 --------------------------------------------------------------------- */

procedure CE_VALIDATE_MISC_EFT_NUM(X_COUNTRY_NAME    in varchar2,
				       X_EFT_NUMBER   in varchar2,
			    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    			    x_msg_count      OUT NOCOPY NUMBER,
			    x_msg_data       OUT NOCOPY VARCHAR2,
			    x_return_status	IN OUT NOCOPY VARCHAR2);

procedure CE_VALIDATE_MISC_ACCT_HLDR_ALT(X_COUNTRY_NAME    in varchar2,
                                       X_ACCOUNT_HOLDER_ALT in varchar2,
                             	X_ACCOUNT_CLASSIFICATION 	in varchar2,
			    p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
    			    x_msg_count      OUT NOCOPY NUMBER,
			    x_msg_data       OUT NOCOPY VARCHAR2,
			    x_return_status	IN OUT NOCOPY VARCHAR2);

END CE_VALIDATE_BANKINFO_UPG;

 

/
