--------------------------------------------------------
--  DDL for Package XTR_REPLICATE_BANK_ACCOUNTS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_REPLICATE_BANK_ACCOUNTS_P" AUTHID CURRENT_USER AS
/* |  $Header: xtrrbacs.pls 120.1.12010000.2 2009/07/28 12:38:23 nipant ship $ | */

/* This package is used to replicate the Internal Bank accounts created in CE into XTR tables.
*/

/**
 * PROCEDURE replicate_bank_accounts
 *
 * DESCRIPTION
 *     This is the main procedure that is called by CE to replicate the
 *      Bank/Bank Branch and Bank account data created in CE into XTR tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_bank_account_rec   Record type of XTR_BANK_ACCOUNTS
 *                              This record type contains the Bank Account
 *                              related information.
 *      p_action_flag           Indicates wether Bank account information needs
 *                              to be inserted or updated.
 *                              'I' - Insert,'U' - Update
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 *      x_msg_count                     To return the number of error messages
 *                                      in stack
 *      x_msg_data                      To return the error message if
 *                                      x_msg_count = 1.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE REPLICATE_BANK_ACCOUNTS
      (p_xtr_bank_account_rec IN XTR_BANK_ACCOUNTS%ROWTYPE,
        p_action_flag IN VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data     OUT NOCOPY  VARCHAR2
        );


PROCEDURE REPLICATE_BANK_ACCOUNTS
      (p_account_number	IN	XTR_BANK_ACCOUNTS.account_number%TYPE,
	   p_authorised	IN	XTR_BANK_ACCOUNTS.authorised%TYPE,
	   p_party_code	IN	XTR_BANK_ACCOUNTS.party_code%TYPE,
	   p_party_type	IN	XTR_BANK_ACCOUNTS.party_type%TYPE,
	   p_bank_code	IN	XTR_BANK_ACCOUNTS.bank_code%TYPE,
	   p_currency	IN	XTR_BANK_ACCOUNTS.currency%TYPE,
	   p_bank_short_code	IN	XTR_BANK_ACCOUNTS.bank_short_code%TYPE,
	   p_default_acct	IN	XTR_BANK_ACCOUNTS.default_acct%TYPE,
	   p_eft_script_name	IN	XTR_BANK_ACCOUNTS.eft_script_name%TYPE,
	   p_code_combination_id	IN	XTR_BANK_ACCOUNTS.code_combination_id%TYPE,
	   p_interest_calculation_basis	IN	XTR_BANK_ACCOUNTS.interest_calculation_basis%TYPE,
	   p_location	IN	XTR_BANK_ACCOUNTS.location%TYPE,
	   p_portfolio_code	IN	XTR_BANK_ACCOUNTS.portfolio_code%TYPE,
	   p_primary_settlement_method	IN	XTR_BANK_ACCOUNTS.primary_settlement_method%TYPE,
	   p_street	IN	XTR_BANK_ACCOUNTS.street%TYPE,
	   p_year_calc_type	IN	XTR_BANK_ACCOUNTS.year_calc_type%TYPE,
	   p_swift_id	IN	XTR_BANK_ACCOUNTS.swift_id%TYPE,
	   p_attribute_category	IN	XTR_BANK_ACCOUNTS.attribute_category%TYPE,
	   p_attribute1	IN	XTR_BANK_ACCOUNTS.attribute1%TYPE,
	   p_attribute2	IN	XTR_BANK_ACCOUNTS.attribute2%TYPE,
	   p_attribute3	IN	XTR_BANK_ACCOUNTS.attribute3%TYPE,
	   p_attribute4	IN	XTR_BANK_ACCOUNTS.attribute4%TYPE,
	   p_attribute5	IN	XTR_BANK_ACCOUNTS.attribute5%TYPE,
	   p_attribute6	IN	XTR_BANK_ACCOUNTS.attribute6%TYPE,
	   p_attribute7	IN	XTR_BANK_ACCOUNTS.attribute7%TYPE,
	   p_attribute8	IN	XTR_BANK_ACCOUNTS.attribute8%TYPE,
	   p_attribute9	IN	XTR_BANK_ACCOUNTS.attribute9%TYPE,
	   p_attribute10	IN	XTR_BANK_ACCOUNTS.attribute10%TYPE,
	   p_attribute11	IN	XTR_BANK_ACCOUNTS.attribute11%TYPE,
	   p_attribute12	IN	XTR_BANK_ACCOUNTS.attribute12%TYPE,
	   p_attribute13	IN	XTR_BANK_ACCOUNTS.attribute13%TYPE,
	   p_attribute14	IN	XTR_BANK_ACCOUNTS.attribute14%TYPE,
	   p_attribute15	IN	XTR_BANK_ACCOUNTS.attribute15%TYPE,
	   p_pricing_model	IN	XTR_BANK_ACCOUNTS.pricing_model%TYPE,
	   p_legal_account_name	IN	XTR_BANK_ACCOUNTS.legal_account_name%TYPE,
	   p_ce_bank_account_id	IN	XTR_BANK_ACCOUNTS.ce_bank_account_id%TYPE,
	   p_bank_branch_id	IN	XTR_BANK_ACCOUNTS.bank_branch_id%TYPE,
	   p_bank_acct_use_id	IN	XTR_BANK_ACCOUNTS.bank_acct_use_id%TYPE,
        p_action_flag IN VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data     OUT NOCOPY  VARCHAR2,
	p_iban_number IN XTR_BANK_ACCOUNTS.iban%TYPE -- ER 6391546
        );

/**
 * PROCEDURE insert_bank_accounts
 *
 * DESCRIPTION
 *     This procedure is called in replicate_bank_accounts to insert
 *      the bank account related data into XTR tables. This procedure is
 *      called when p_action_flag = 'I'
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_bank_account_rec   Record type of XTR_BANK_ACCOUNTS
 *                              This record type contains the Bank Account
 *                              related information.
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */
    PROCEDURE INSERT_BANK_ACCOUNTS
      ( p_xtr_bank_account_rec IN XTR_BANK_ACCOUNTS%ROWTYPE,
        x_return_status    OUT NOCOPY  VARCHAR2
        );

 /**
 * PROCEDURE update_bank_accounts
 *
 * DESCRIPTION
 *     This procedure is called in replicate_bank_accounts to update
 *      the bank account related data into XTR tables. This procedure is
 *      called when p_action_flag = 'I'
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_xtr_bank_account_rec   Record type of XTR_BANK_ACCOUNTS
 *                              This record type contains the Bank Account
 *                              related information.
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */

    PROCEDURE UPDATE_BANK_ACCOUNTS
      ( p_xtr_bank_account_rec IN XTR_BANK_ACCOUNTS%ROWTYPE,
        x_return_status    OUT NOCOPY  VARCHAR2
        );


/**
 * PROCEDURE validate_bank_accounts
 *
 *     This procedure is used to validate the Bank account related data before
 *      it is inserted/updated into XTR_BANK_ACCOUNTS. This procedure will
 *      perform the required validations and puts the corresponding error
 *      messages into list
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_bank_account_rec   Record type of XTR_BANK_ACCOUNTS
 *                              This record type contains the Bank Account
 *                              related information.
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE VALIDATE_BANK_ACCOUNTS
      ( p_xtr_bank_account_rec IN XTR_BANK_ACCOUNTS%ROWTYPE,
        x_return_status   IN OUT NOCOPY  VARCHAR2
        );

 /**
 * PROCEDURE modify_bank_accounts
 *
 * DESCRIPTION
 *     This procedure will insert/update XTR_BANK_ACCOUNTS table with the
 *      Bank account data passed form CE. It will insert if p_action_flag = 'I'
 *      and update if p_action_flag = 'U'
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_bank_account_rec   Record type of XTR_BANK_ACCOUNTS
 *                              This record type contains the Bank Account
 *      p_action_flag           Indicates wether Bank account information needs
 *                              to be inserted or updated.
 *                              'I' - Insert,'U' - Update                            related information.
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE MODIFY_BANK_ACCOUNTS
      ( p_xtr_bank_account_rec IN XTR_BANK_ACCOUNTS%ROWTYPE,
        p_action_flag IN VARCHAR2,
        x_return_status  IN  OUT NOCOPY  VARCHAR2
        );
 /**
 * PROCEDURE log_err_msg
 *
 * DESCRIPTION
 *     This procedure will attach the tokens with the error messages and puts
 *      all the error messages into a list. CE can extract the error messages
 *      from this list and show them to the user.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_error_code                     This will pass the message_name
 *                                      which has to be put into the list.
 *     p_field_name                     This will pass the token which has to be
 *                                      attached with the error message.
 *   IN/OUT:
 *
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */
    PROCEDURE LOG_ERR_MSG
      ( p_error_code    IN  VARCHAR2,
        p_field_name    IN  VARCHAR2 default null,
        p_field_name2   IN  VARCHAR2 default null
      );

/**
 * PROCEDURE replicate_interest_schedules
 *
 * DESCRIPTION
 *     This is the main procedure that is called by CE to replicate the
 *      interest schedules data created in CE into XTR tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_ce_bank_account_id    	This is the CE_BANK_ACCOUNT_ID in  XTR_PARTY_INFO.
 *                              CE will pass this parameter. This will tell us
 *                              which Bank Account is attached with the interest
 *                              schedule being updated.
 *     p_interest_rounding     	This is the ROUNDING_TYPE in XTR_BANK_ACCOUNTS.
 *                              CE will pass this parameter. This will tell us
 *                              what is the updated interest rounding.
 *      p_interest_includes    	This is the DAY_COUNT_TYPE in XTR_BANK_ACCOUNTS.
 *                              CE will pass this parameter. This will tell us
 *                              what is the updated Interest Includes.
 *      p_interest_calculation
 *                  _basis    	This is the BASIS in XTR_BANK_ACCOUNTS.
 *                              CE will pass this parameter. This will tell us
 *                              what is the updated BASIS.
 *     p_day_count_basis     	 This is the DAY_COUNT_BASIS in XTR_BANK_ACCOUNTS.
 *                              CE will pass this parameter. This will tell us
 *                              what is the updated day count basis.
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 *      x_msg_count                     To return the number of error messages
 *                                      in stack
 *      x_msg_data                      To return the error message if
 *                                      x_msg_count = 1.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE REPLICATE_INTEREST_SCHEDULES
      ( p_ce_bank_account_id   IN XTR_BANK_ACCOUNTS.ce_bank_account_id%TYPE,--Chnage this to bank_account_id
        p_interest_rounding IN XTR_BANK_ACCOUNTS.ROUNDING_TYPE%TYPE,
        p_interest_includes IN XTR_BANK_ACCOUNTS.DAY_COUNT_TYPE%TYPE,
        p_interest_calculation_basis IN XTR_BANK_ACCOUNTS.INTEREST_CALCULATION_BASIS%TYPE,
        p_day_count_basis IN XTR_BANK_ACCOUNTS.YEAR_CALC_TYPE%TYPE,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_msg_data     OUT NOCOPY  VARCHAR2
        );


END XTR_REPLICATE_BANK_ACCOUNTS_P; -- Package spec


/
