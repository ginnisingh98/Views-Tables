--------------------------------------------------------
--  DDL for Package CE_BANK_AND_ACCOUNT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_AND_ACCOUNT_VALIDATION" AUTHID CURRENT_USER AS
/*$Header: cebavals.pls 120.9.12010000.2 2009/02/06 06:34:23 talapati ship $ */

  /*=======================================================================+
   | PUBLIC FUNCTION ce_check_numeric                                      |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check if a value is numeric                                         |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     check_value                                                       |
   |     pos_from                                                          |
   |     pos_to                                                            |
   +=======================================================================*/
   FUNCTION ce_check_numeric(check_value VARCHAR2,
                               pos_from    NUMBER,
                               pos_for     NUMBER  )  RETURN VARCHAR2;

  /*=======================================================================+
   | PUBLIC PROCEDURE  validate_bank                                       |
   |   This procedure should be registered as the value of the profile     |
   |   option 'HZ_BANK_VALIDATION_PROCEDURE' in fnd_profile_option_values  |
   | DESCRIPTION                                                           |
   |   Dynamic bound validation routine.                                   |
   |   Validate the combination of country and bank name is unique. This   |
   |   procedure is called by TCA create_bank/update_bank API              |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_temp_org_profile_id   temp_id in HZ_ORG_PROFILE_VAL_GT table    |
   +=======================================================================*/
   PROCEDURE validate_bank (p_temp_id         IN  NUMBER,
                            x_return_status   IN OUT NOCOPY VARCHAR2);


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_branch                                      |
   |   This procedure should be registered as the value of the profile     |
   |   option of 'HZ_BANK_BRANCH_VALIDATION_PROCEDURE' in                  |
   |   fnd_profile_option_values                                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Dynamic bound validation routine.                                   |
   |   This procedure is called by TCA create_bank_branch/                 |
   |   update_bank_branch API                                              |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_temp_org_profile_id   temp_id in HZ_ORG_PROFILE_VAL_GT table    |
   +=======================================================================*/
   PROCEDURE validate_branch (p_temp_org_profile_id   IN  NUMBER,
                              x_return_status         IN OUT NOCOPY VARCHAR2);



  /*=======================================================================+
   | PUBLIC PROCEDURE validate_org                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the org is a valid org in TCA/HR and satisfies             |
   |   MO security profile                                                 |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_name  		name of org to be validated                |
   |     p_org_classification	HR_BG (Business Group)                     |
   |                            OPERATING_UNIT                             |
   |                            HR_LEGAL                                   |
   |     p_security_profile_id                                             |
   +=======================================================================*/
/*
   PROCEDURE validate_org (p_org_id			IN  NUMBER,
			   p_org_classification		IN  VARCHAR2,
			   p_security_profile_id	IN  NUMBER,
			   x_out                        OUT NUMBER);
*/

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_currency                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the currency_code is valid in FND_CURRENCIES               |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_currency_code                                                   |
   +=======================================================================*/
   PROCEDURE validate_currency (p_currency_code		IN  VARCHAR2,
				x_return_status         IN OUT NOCOPY VARCHAR2);


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_name                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the account_name is unique within a branch                 |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_branch_id                                                       |
   |     p_account_name                                                    |
   +=======================================================================*/
   PROCEDURE validate_account_name (p_branch_id		IN  NUMBER,
				    p_account_name	IN  VARCHAR2,
				    p_account_id	IN  NUMBER,
				    x_return_status     IN OUT NOCOPY VARCHAR2);

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_IBAN                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate IBAN according to IBAN validation rules                    |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_IBAN                                                            |
   +=======================================================================*/
   PROCEDURE validate_IBAN (p_IBAN         	IN  VARCHAR2,
			    p_IBAN_OUT     	OUT NOCOPY VARCHAR2,
			    x_return_status     IN OUT NOCOPY VARCHAR2 );


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_use                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   At least one use is selected for the bank account                   |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_ap, p_ar, p_pay, p_xtr                                          |
   +=======================================================================*/
   PROCEDURE validate_account_use(p_ap      IN  VARCHAR2,
                                  p_ar      IN  VARCHAR2,
                                  p_pay     IN  VARCHAR2,
                                  p_xtr     IN  VARCHAR2,
			    x_return_status     IN OUT NOCOPY VARCHAR2 );

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_end_date                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate the end date cannot be earlier than the start date         |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_start_date, p_end_date                                          |
   +=======================================================================*/
   PROCEDURE validate_end_date(p_start_date    IN  DATE,
                               p_end_date      IN  DATE,
			    x_return_status     IN OUT NOCOPY VARCHAR2 );

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_short_account_name                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Short Account Name is required when Xtr use is selected for the     |
   |     bank account                                                      |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_short_account_name, p_xtr                                       |
   +=======================================================================*/
   PROCEDURE validate_short_account_name(p_short_account_name  IN  VARCHAR2,
                                  	 p_xtr   	       IN  VARCHAR2,
			    x_return_status     IN OUT NOCOPY VARCHAR2 );

  /*=======================================================================+
   | PUBLIC FUNCTION Get_Emp_Name                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    Get Employee Name                                                  |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_emp_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Emp_Name( p_emp_id NUMBER )
	RETURN VARCHAR2;

  /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type                                               |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Org_Type( p_org_id NUMBER )
	RETURN VARCHAR2;


  /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type_Code                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type Code.  Used in Systerm Parameters.            |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Org_Type_Code( p_org_id NUMBER )
        RETURN VARCHAR2;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_account_access_org                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate that the account use is valid for the org                  |
   |
   |    Validate organization use
   |    Access Org        | Org can be          | Org cannot be
   |    Classification    | use in              | use In
   |    --------------------------------------------------------------
   |    LE                | XTR                 | AP, AR, PAY
   |    BG                | PAY                 | AR, AP, XTR
   |    OU                | AP, AR              | PAY, XTR
   |    BG and OU         | AP, AR, PAY         | XTR
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_ap, p_ar, p_pay, p_xtr, p_org_id                                |
   +=======================================================================*/
   PROCEDURE validate_account_access_org(p_ap      IN  VARCHAR2,
                                  p_ar      IN  VARCHAR2,
                                  p_pay     IN  VARCHAR2,
                                  p_xtr     IN  VARCHAR2,
				  p_org_type IN VARCHAR2,
				  p_org_id  IN	NUMBER ,
			    x_return_status     IN OUT NOCOPY VARCHAR2 );


  /*=======================================================================+
   | PUBLIC PROCEDURE VALIDATE_ALC                                         |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate Agency Location Code		                           |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    ALC_VALUE                                                          |
   |   OUT                                                                 |
   |    x_msg_count                                                        |
   |    x_msg_data                                                         |
   |    X_VALUE_OUT                                                        |
   +=======================================================================*/
   PROCEDURE VALIDATE_ALC(ALC_VALUE in varchar2,
 			  p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    			      x_msg_count      OUT NOCOPY NUMBER,
			      x_msg_data       OUT NOCOPY VARCHAR2,
		              X_VALUE_OUT      OUT NOCOPY VARCHAR2,
			      x_return_status     IN OUT NOCOPY VARCHAR2);


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_country                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check to see that the country specified is defined in               |
   |   territories.                                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_country_code							   |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    Xin Wang      Created.                               |
   +=======================================================================*/
  PROCEDURE validate_country (
    p_country_code  IN     VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_def_settlement                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Allow only one account per currency and account use (AP or XTR)     |
   |   to be flagged as the default settlement account for each  LE or OU  |
   |                                                                       |
   |   Possible combination:                                               |
   |   LE1, USD, AP USE,  BANK ACCOUNT 1                                   |
   |   LE1, USD, XTR USE, BANK ACCOUNT 2                                   |
   |   OU1, USD, AP USE,  BANK ACCOUNT 1                                   |
   |   OU1, USD, XTR USE, BANK ACCOUNT 1                                   |
   |                                                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_bank_account_id - required 					   |
   |    p_bank_acct_use_id - required 					   |
   |    p_org_id - required	                                           |
   |    p_ap_def_settlement, p_xtr_def_settlement, p_init_msg_list	   |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |    x_msg_count                                                        |
   |	x_msg_data   	                                                   |
   |		                                                           |
   | MODIFICATION HISTORY                                                  |
   |   21-DEC-2004    lkwan         Created.                               |
   +=======================================================================*/
  PROCEDURE validate_def_settlement(
		p_bank_account_id 	IN  number,
		p_bank_acct_use_id 	IN  number,
		p_org_id 		IN  number,
		p_ap_def_settlement 	in  VARCHAR2,
		p_xtr_def_settlement 	in  VARCHAR2,
		p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
    		x_msg_count      OUT NOCOPY NUMBER,
		x_msg_data       OUT NOCOPY VARCHAR2,
                x_return_status IN OUT NOCOPY VARCHAR2);

  /*=======================================================================+
   | PUBLIC FUNCTION get_masked_account_num                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Passing the bank_account_num and return the                         |
   |   masked bank_account_num based on the profile option:                |
   |     CE: MASK INTERNAL BANK ACCOUNT NUMBER                             |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |   p_bank_account_num                                                  |
   |                                                                       |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   23-NOV-2004    lkwan         Created.                               |
   +=======================================================================*/
/*
  FUNCTION get_masked_account_num (
    p_bank_account_num  IN     VARCHAR2,
    p_acct_class  IN     VARCHAR2
  ) RETURN VARCHAR2;
*/

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_unique_org_access                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    The combination or bank_account_id and org_id/legal_entity_id in   |
   |    in CE_BANK_ACCT_USES_ALL should be unique.                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    p_org_le_id                                                        |
   |    p_bank_account_id                                                  |
   |   OUT                                                                 |
   |    x_return_status                                                    |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   22-JUN-2005    Xin Wang      Created.                               |
   +=======================================================================*/
  PROCEDURE validate_unique_org_access (
    p_org_le_id        IN     NUMBER,
    p_bank_account_id  IN     NUMBER,
    p_acct_use_id      IN     NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2
  );

  /*=======================================================================+
   | PUBLIC PROCEDURE get_pay_doc_cat                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |    Obtaining the correct document category will be a hierarchical
   |     approach:
   |     1) payment document
   |     2) bank account use/payment method
   |     3) bank account use                                               |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |    P_PAYMENT_DOCUMENT_ID
   |    P_PAYMENT_METHOD_CODE
   |    P_BANK_ACCT_USE_ID
   |   OUT                                                                 |
   |    P_PAYMENT_DOC_CATEGORY_ID ("-1" if no category code is defined)
   |		                                                           |
   | MODIFICATION HISTORY                                                  |
   |   21-FEB-2006    lkwan         Created.                               |
   +=======================================================================*/
   PROCEDURE get_pay_doc_cat(
		P_PAYMENT_DOCUMENT_ID 	IN  number,
		P_PAYMENT_METHOD_CODE 	IN  VARCHAR2,
		P_BANK_ACCT_USE_ID	IN  number,
		P_PAYMENT_DOC_CATEGORY_CODE  OUT NOCOPY VARCHAR2);


 /*=======================================================================+
   | PUBLIC FUNCTION Get_Org_Type_Code_Isetup                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get Organization Type Code.  Used in Systerm Parameters.            |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_org_id                                                          |
   +=======================================================================*/
   FUNCTION Get_Org_Type_Code_Isetup( p_org_id NUMBER )
        RETURN VARCHAR2;


END CE_BANK_AND_ACCOUNT_VALIDATION;

/
