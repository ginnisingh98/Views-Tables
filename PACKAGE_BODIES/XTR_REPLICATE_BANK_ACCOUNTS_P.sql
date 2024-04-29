--------------------------------------------------------
--  DDL for Package Body XTR_REPLICATE_BANK_ACCOUNTS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_REPLICATE_BANK_ACCOUNTS_P" AS
/* |  $Header: xtrrbacb.pls 120.10.12010000.3 2009/07/29 04:54:56 nipant ship $ | */
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
 *     p_xtr_party_info_rec    	Record type of XTR_PARTY_INFO.
 *					             This record type contains the Bank/Bank Branch
 *                              related information about the bank attached with
 *                              Bank Account.
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
      ( p_xtr_bank_account_rec  IN XTR_BANK_ACCOUNTS%ROWTYPE,
        p_action_flag           IN VARCHAR2,
        x_return_status         OUT NOCOPY  VARCHAR2,
        x_msg_count             OUT NOCOPY  NUMBER,
        x_msg_data              OUT NOCOPY  VARCHAR2)

IS

CURSOR c_branch_name
IS
select full_name
from xtr_party_info
where party_code = p_xtr_bank_account_rec.bank_code;

l_bank_branch_name xtr_party_info.full_name%TYPE;

BEGIN

    x_msg_count := NULL;
    FND_MSG_PUB.Initialize; -- Initializes the message list that stores the errors

    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- Verifies if the party_code in xtr_party_info is not same as the bank_code in xtr_bank_accounts
    IF ((NOT XTR_REPLICATE_BANK_BRANCHES_P.CHK_BANK_BRANCH(p_xtr_bank_account_rec.bank_branch_id))
            ) THEN -- The Bank does not exist or not authorized in XTR

        OPEN c_branch_name;
        FETCH c_branch_name INTO l_bank_branch_name;
        CLOSE c_branch_name;
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_BANK_BRANCH',l_bank_branch_name);

    END IF;

   IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF(p_action_flag = 'I') THEN -- If user has created a new bank account in CE



            INSERT_BANK_ACCOUNTS(p_xtr_bank_account_rec,x_return_status);


        ELSIF(p_action_flag = 'U')THEN -- If user has updated an existing bank
                                       -- account in CE

            UPDATE_BANK_ACCOUNTS(p_xtr_bank_account_rec,x_return_status);


        ELSE

            x_return_status    := FND_API.G_RET_STS_ERROR;
            LOG_ERR_MSG('XTR_INV_PARAM','ACTION_FLAG');


        END IF;


    END IF;

    IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('xtr_replicate_bank_accounts_P: '||'Replicate_Bank_Accounts');
        xtr_risk_debug_pkg.dlog('Replicate_Bank_Accounts: ' || 'bank_acct_rec.ce_bank_account_id',p_xtr_bank_account_rec.ce_bank_account_id);
        xtr_risk_debug_pkg.dlog('Replicate_Bank_Accounts: ' || 'p_action_flag',p_action_flag);
        xtr_risk_debug_pkg.dlog('Replicate_Bank_Accounts: ' || 'x_return_status' , x_return_status);
        xtr_risk_debug_pkg.dlog('Replicate_Bank_Accounts: ' || 'x_msg_count' , x_msg_count);
        xtr_risk_debug_pkg.dpop('xtr_replicate_bank_accounts_P: '||'Replicate_Bank_Accounts');
    END IF;
--

    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );
--
      EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END REPLICATE_BANK_ACCOUNTS;

/* This procedure is written so that CE can pass the individual parameters instead of ROW TYPE */
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
	p_iban_number IN XTR_BANK_ACCOUNTS.iban%TYPE  --ER6391546
        ) IS
l_xtr_bank_accounts_rec XTR_BANK_ACCOUNTS%ROWTYPE;

BEGIN

	l_xtr_bank_accounts_rec.account_number	:=	p_account_number;
	l_xtr_bank_accounts_rec.authorised	:=	p_authorised;
	l_xtr_bank_accounts_rec.party_code	:=	p_party_code;
	l_xtr_bank_accounts_rec.party_type	:=	p_party_type;
	l_xtr_bank_accounts_rec.bank_code	:=	p_bank_code;
	l_xtr_bank_accounts_rec.currency	:=	p_currency;
	l_xtr_bank_accounts_rec.bank_short_code	:=	p_bank_short_code;
	l_xtr_bank_accounts_rec.default_acct	:=	p_default_acct;
	l_xtr_bank_accounts_rec.eft_script_name	:=	p_eft_script_name;
	l_xtr_bank_accounts_rec.code_combination_id	:=	p_code_combination_id;
	l_xtr_bank_accounts_rec.interest_calculation_basis	:=	p_interest_calculation_basis;
	l_xtr_bank_accounts_rec.location	:=	p_location;
	l_xtr_bank_accounts_rec.portfolio_code	:=	p_portfolio_code;
	l_xtr_bank_accounts_rec.primary_settlement_method	:=	p_primary_settlement_method;
	-- Bug 6119714 Start
	l_xtr_bank_accounts_rec.street	:=	SUBSTR(p_street,1,35);
	-- Bug 6119714 end
	l_xtr_bank_accounts_rec.year_calc_type	:=	p_year_calc_type;
	l_xtr_bank_accounts_rec.swift_id	:=	p_swift_id;
	l_xtr_bank_accounts_rec.attribute_category	:=	p_attribute_category;
	l_xtr_bank_accounts_rec.attribute1	:=	p_attribute1;
	l_xtr_bank_accounts_rec.attribute2	:=	p_attribute2;
	l_xtr_bank_accounts_rec.attribute3	:=	p_attribute3;
	l_xtr_bank_accounts_rec.attribute4	:=	p_attribute4;
	l_xtr_bank_accounts_rec.attribute5	:=	p_attribute5;
	l_xtr_bank_accounts_rec.attribute6	:=	p_attribute6;
	l_xtr_bank_accounts_rec.attribute7	:=	p_attribute7;
	l_xtr_bank_accounts_rec.attribute8	:=	p_attribute8;
	l_xtr_bank_accounts_rec.attribute9	:=	p_attribute9;
	l_xtr_bank_accounts_rec.attribute10	:=	p_attribute10;
	l_xtr_bank_accounts_rec.attribute11	:=	p_attribute11;
	l_xtr_bank_accounts_rec.attribute12	:=	p_attribute12;
	l_xtr_bank_accounts_rec.attribute13	:=	p_attribute13;
	l_xtr_bank_accounts_rec.attribute14	:=	p_attribute14;
	l_xtr_bank_accounts_rec.attribute15	:=	p_attribute15;
	l_xtr_bank_accounts_rec.pricing_model	:=	p_pricing_model;
	l_xtr_bank_accounts_rec.legal_account_name	:=	p_legal_account_name;
	l_xtr_bank_accounts_rec.ce_bank_account_id	:=	p_ce_bank_account_id;
	l_xtr_bank_accounts_rec.bank_branch_id	:=	p_bank_branch_id;
	l_xtr_bank_accounts_rec.bank_acct_use_id	:=	p_bank_acct_use_id;
	l_xtr_bank_accounts_rec.iban := p_iban_number; --ER6391546


    REPLICATE_BANK_ACCOUNTS(l_xtr_bank_accounts_rec,p_action_flag,
        x_return_status,x_msg_count,x_msg_data);

    EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END REPLICATE_BANK_ACCOUNTS;



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
        )

IS


BEGIN

--
       VALIDATE_BANK_ACCOUNTS(p_xtr_bank_account_rec,x_return_status);

        IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
/* All validations for bank account are true */
            MODIFY_BANK_ACCOUNTS(p_xtr_bank_account_rec,'I'
                                        ,x_return_status);

        END IF;



    IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('xtr_replicate_bank_accounts_P: '||'Insert_Bank_Accounts');
        xtr_risk_debug_pkg.dlog('Insert_Bank_Accounts: ' || 'bank_acct_rec.ce_bank_account_id',p_xtr_bank_account_rec.ce_bank_account_id);
        xtr_risk_debug_pkg.dlog('Insert_Bank_Accounts: ' || 'x_return_status' , x_return_status);
        xtr_risk_debug_pkg.dpop('xtr_replicate_bank_accounts_P: '||'Insert_Bank_Accounts');
    END IF;


  EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END INSERT_BANK_ACCOUNTS;

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
        )
IS

BEGIN

-- This account already exists in XTR and it is being updated in CE
    VALIDATE_BANK_ACCOUNTS(p_xtr_bank_account_rec
                                ,x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    /* All validations for bank account are true */
        MODIFY_BANK_ACCOUNTS(p_xtr_bank_account_rec,'U'
                                        ,x_return_status);

    END IF;
    IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('xtr_replicate_bank_accounts_P: '||'Update_Bank_Accounts');
        xtr_risk_debug_pkg.dlog('Insert_Bank_Accounts: ' || 'bank_acct_rec.ce_bank_account_id',p_xtr_bank_account_rec.ce_bank_account_id);
        xtr_risk_debug_pkg.dlog('Update_Bank_Accounts: ' || 'x_return_status', x_return_status);
        xtr_risk_debug_pkg.dpop('xtr_replicate_bank_accounts_P: '||'Update_Bank_Accounts');
    END IF;

    EXCEPTION
        WHEN others THEN
        x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
        LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END UPDATE_BANK_ACCOUNTS;


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
        x_return_status   IN OUT NOCOPY VARCHAR2
        )
IS
-- This cursor verifies if the code combination id passed is defined in
-- XTR_GL_REFERENCES_V for that company
CURSOR c_cc_id IS
    SELECT 'Y'
    FROM XTR_GL_REFERENCES_V
    WHERE code_combination_id = p_xtr_bank_account_rec.code_combination_id
    AND company_code = p_xtr_bank_account_rec.party_code;
-- This cursor verifies if the pricing model passed is authorized or not
cursor c_pm_authorized is
   select authorized
   from   xtr_price_models_v
   where  deal_type = 'CA'
   and    code = p_xtr_bank_account_rec.pricing_model;
-- This cursor verifies if the party_code passed is
-- of a valid company or not
cursor c_valid_company is
    select authorised,legal_entity_id
    from xtr_parties_v
    where party_code = p_xtr_bank_account_rec.party_code
    and party_type = 'C';
-- This cursor Verfies if A default account already exists for this company/currency combination.
cursor c_default_acct is
    select default_acct,ce_bank_account_id -- Modified Bug 4764437
    from xtr_bank_accounts
    where party_code = p_xtr_bank_account_rec.party_code
    and currency = p_xtr_bank_account_rec.currency
    and default_acct = 'Y';


l_cc_id VARCHAR2(2);
l_pm_authorized XTR_BANK_ACCOUNTS.PRICING_MODEL%TYPE;
l_valid_company VARCHAR2(2);
l_le_id XTR_PARTY_INFO.legal_entity_id%TYPE;
l_default_acct  VARCHAR2(2);
l_chk_default XTR_BANK_ACCOUNTS.CE_BANK_ACCOUNT_ID%TYPE; -- Added Bug 4764437

      -- Enter the procedure variables here. As shown below
    --variable_name        datatype  NOT NULL DEFAULT default_value;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Verifies if the ce_bank_account_id in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.ce_bank_account_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_PARAM','XTR_BANK_ACCOUNTS.ce_bank_account_id');
    END IF;
-- Verifies if the  bank_branch_id in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.bank_branch_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_PARAM','XTR_BANK_ACCOUNTS.BANK_BRANCH_ID');
    END IF;
/* Removed the validation Bug 4582759
-- Verifies if the bank_acct_use_id in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.bank_acct_use_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_PARAM','XTR_BANK_ACCOUNTS.BANK_ACCT_USE_ID');
    END IF;
*/
    -- Verifies if bank_short_code in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.bank_short_code is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_ACCT_NAME_MANDATORY');
    END IF;
-- Verifies if currency in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.currency is null ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_CURRENCY_MANDATORY');
    END IF;
-- Verifies if location in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.location is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_LOCATION_MANDATORY');
    END IF;
-- Verifies if street in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.street is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_STREET_MANDATORY');
    END IF;
-- Verifies if party_code in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.party_code is null ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_ACCT_OWNER_MANDATORY');
    END IF;
-- Verifies if account_number in XTR_BANK_ACCOUNTS is passed as null
    IF(p_xtr_bank_account_rec.account_number is null ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_ACCOUNT_MANDATORY_FIELD');
    END IF;


    OPEN c_pm_authorized;
    FETCH c_pm_authorized INTO l_pm_authorized;
    CLOSE c_pm_authorized;
-- Verifies if pricing model in XTR_BANK_ACCOUNTS is authorized or not
    IF(nvl(l_pm_authorized,'N') = 'N' AND p_xtr_bank_account_rec.pricing_model IS NOT NULL ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_TRS_PRICING_MODEL');
    END IF;

    OPEN c_cc_id;
    FETCH c_cc_id INTO l_cc_id;
    CLOSE c_cc_id;
-- Verifies if code combination id in XTR_BANK_ACCOUNTS is authorized or not
    IF(nvl(l_cc_id,'N') = 'N' AND p_xtr_bank_account_rec.code_combination_id IS NOT NULL
                              AND p_xtr_bank_account_rec.party_code IS NOT NULL) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_CC_ID');
    END IF;

    OPEN C_valid_company;
    FETCH C_valid_company INTO l_valid_company,l_le_id;
    CLOSE C_valid_company;
-- Verifies if company exists in XTR_PARTIES_V
    IF(nvl(l_valid_company,'N') = 'N' and p_xtr_bank_account_rec.party_code IS NOT NULL) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_LE_COMP_CODE',l_le_id);
    END IF;
    OPEN C_default_acct;
    FETCH C_default_acct INTO l_default_acct,l_chk_default;
    CLOSE C_default_acct;
-- Verfies if A default account already exists for this company/currency combination.
    IF((nvl(l_default_acct,'N') = 'Y') AND p_xtr_bank_account_rec.default_acct = 'Y'
          AND (nvl(l_chk_default,-1) <> p_xtr_bank_account_rec.ce_bank_account_id) ) THEN  -- Modified Bug 4764437
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_DEFAULT_ACCT');
    END IF;
-- Verifies if  year calculated basis is '30/'  and a day count basis type of Both Days for the same deal.
    IF(substr(p_xtr_bank_account_rec.year_calc_type,1,2) = '30'
            and p_xtr_bank_account_rec.day_count_type = 'B') THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_CHK_30_BOTH');
    END IF;

    IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('xtr_replicate_bank_accounts_P: '||'Validate_Bank_Accounts');
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.ce_bank_account_id',p_xtr_bank_account_rec.ce_bank_account_id);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.bank_code',p_xtr_bank_account_rec.bank_code);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.bank_short_code',p_xtr_bank_account_rec.bank_short_code);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.currency',p_xtr_bank_account_rec.currency);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.location',p_xtr_bank_account_rec.location);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.street',p_xtr_bank_account_rec.street);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.party_code',p_xtr_bank_account_rec.party_code);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.year_calc_type',p_xtr_bank_account_rec.year_calc_type);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.account_number',p_xtr_bank_account_rec.account_number);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.pricing_model',p_xtr_bank_account_rec.pricing_model);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'bank_acct_rec.default_acct',p_xtr_bank_account_rec.default_acct);
        xtr_risk_debug_pkg.dlog('Validate_Bank_Accounts: ' || 'x_return_status', x_return_status);
        xtr_risk_debug_pkg.dpop('xtr_replicate_bank_accounts_P: '||'Validate_Bank_Accounts');
    END IF;

    EXCEPTION
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END VALIDATE_BANK_ACCOUNTS;


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
        x_return_status   IN OUT  NOCOPY VARCHAR2
        )

IS
-- This cursor verifies if there is a lock on the row that user is trying to update
CURSOR c_chk_lock IS
    SELECT ce_bank_account_id
    FROM XTR_BANK_ACCOUNTS
    WHERE ce_bank_account_id = p_xtr_bank_account_rec.ce_bank_account_id
    FOR UPDATE NOWAIT;
record_lock EXCEPTION;
l_ce_bank_account_id XTR_BANK_ACCOUNTS.ce_bank_account_id%TYPE;

BEGIN
    -- Bug 5137819 Changed to insert the bank account in treasury while updation of treasury use
    -- allowed flag in CE after the bank account is created for that bank branch.

    OPEN c_chk_lock;
    FETCH c_chk_lock INTO l_ce_bank_account_id;
    close c_chk_lock ;

    IF ( (p_action_flag = 'I') or (p_action_flag = 'U' and l_ce_bank_account_id Is Null )) THEN -- The bank account has to be inserted

        INSERT INTO XTR_BANK_ACCOUNTS
        (account_number
        ,authorised
        ,party_code
        ,party_type
        ,bank_code
        ,currency
        ,bank_short_code
        ,default_acct
        ,created_by
        ,created_on
        ,eft_script_name
        ,code_combination_id
        ,interest_calculation_basis
        ,location
        ,portfolio_code
        ,primary_settlement_method
        ,street
        ,year_calc_type
        ,swift_id
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
        ,pricing_model
        ,legal_account_name
        ,ce_bank_account_id
        ,bank_branch_id
        ,bank_acct_use_id
        ,gl_company_code
	,iban --ER6391546
        )
        VALUES
        (p_xtr_bank_account_rec.account_number
        ,'Y'
        ,p_xtr_bank_account_rec.party_code
        ,'C'
        ,p_xtr_bank_account_rec.bank_code
        ,p_xtr_bank_account_rec.currency
        ,p_xtr_bank_account_rec.bank_short_code
        ,p_xtr_bank_account_rec.default_acct
        ,fnd_global.user_id
        ,sysdate
        ,p_xtr_bank_account_rec.eft_script_name
        ,p_xtr_bank_account_rec.code_combination_id
        ,p_xtr_bank_account_rec.interest_calculation_basis
        ,p_xtr_bank_account_rec.location
        ,p_xtr_bank_account_rec.portfolio_code
        ,'E'
        ,p_xtr_bank_account_rec.street
        ,p_xtr_bank_account_rec.year_calc_type
        ,p_xtr_bank_account_rec.swift_id
        ,p_xtr_bank_account_rec.attribute_category
        ,p_xtr_bank_account_rec.attribute1
        ,p_xtr_bank_account_rec.attribute2
        ,p_xtr_bank_account_rec.attribute3
        ,p_xtr_bank_account_rec.attribute4
        ,p_xtr_bank_account_rec.attribute5
        ,p_xtr_bank_account_rec.attribute6
        ,p_xtr_bank_account_rec.attribute7
        ,p_xtr_bank_account_rec.attribute8
        ,p_xtr_bank_account_rec.attribute9
        ,p_xtr_bank_account_rec.attribute10
        ,p_xtr_bank_account_rec.attribute11
        ,p_xtr_bank_account_rec.attribute12
        ,p_xtr_bank_account_rec.attribute13
        ,p_xtr_bank_account_rec.attribute14
        ,p_xtr_bank_account_rec.attribute15
        ,p_xtr_bank_account_rec.pricing_model
        ,p_xtr_bank_account_rec.legal_account_name
        ,p_xtr_bank_account_rec.ce_bank_account_id
        ,p_xtr_bank_account_rec.bank_branch_id
        ,p_xtr_bank_account_rec.bank_acct_use_id
        ,p_xtr_bank_account_rec.party_code
	,p_xtr_bank_account_rec.iban  --ER6391546
        );

   ELSIF (p_action_flag = 'U' and l_ce_bank_account_id Is Not Null ) THEN -- The bank account has to be updated

        UPDATE XTR_BANK_ACCOUNTS
        SET authorised      =   p_xtr_bank_account_rec.authorised
        ,bank_code          =   p_xtr_bank_account_rec.bank_code
        ,bank_short_code    =   p_xtr_bank_account_rec.bank_short_code
        ,default_acct       =   p_xtr_bank_account_rec.default_acct
        ,eft_script_name    =   p_xtr_bank_account_rec.eft_script_name
        ,code_combination_id =  p_xtr_bank_account_rec.code_combination_id
       -- ,interest_calculation_basis =   p_xtr_bank_account_rec.interest_calculation_basis Bug 5398434
        ,location          =   p_xtr_bank_account_rec.location
        ,portfolio_code    =   p_xtr_bank_account_rec.portfolio_code
        ,street            =   p_xtr_bank_account_rec.street
        ,updated_by        =   fnd_global.user_id
        ,updated_on        =   sysdate
       -- ,year_calc_type    =   p_xtr_bank_account_rec.year_calc_type  Bug 5398434
        ,swift_id          =   p_xtr_bank_account_rec.swift_id
        ,attribute_category =  p_xtr_bank_account_rec.attribute_category
        ,attribute1        =   p_xtr_bank_account_rec.attribute1
        ,attribute2        =   p_xtr_bank_account_rec.attribute2
        ,attribute3        =   p_xtr_bank_account_rec.attribute3
        ,attribute4        =   p_xtr_bank_account_rec.attribute4
        ,attribute5        =   p_xtr_bank_account_rec.attribute5
        ,attribute6        =   p_xtr_bank_account_rec.attribute6
        ,attribute7        =   p_xtr_bank_account_rec.attribute7
        ,attribute8        =   p_xtr_bank_account_rec.attribute8
        ,attribute9        =   p_xtr_bank_account_rec.attribute9
        ,attribute10        =   p_xtr_bank_account_rec.attribute10
        ,attribute11        =   p_xtr_bank_account_rec.attribute11
        ,attribute12       =   p_xtr_bank_account_rec.attribute12
        ,attribute13       =   p_xtr_bank_account_rec.attribute13
        ,attribute14       =   p_xtr_bank_account_rec.attribute14
        ,attribute15       =   p_xtr_bank_account_rec.attribute15
        ,pricing_model     =   p_xtr_bank_account_rec.pricing_model
        ,legal_account_name  =   p_xtr_bank_account_rec.legal_account_name
        ,currency     =   p_xtr_bank_account_rec.currency
	,iban = p_xtr_bank_account_rec.iban
         WHERE   ce_bank_account_id = l_ce_bank_account_id; -- change this

    END IF;



    IF xtr_risk_debug_pkg.g_Debug THEN
        xtr_risk_debug_pkg.dpush('xtr_replicate_bank_accounts_P: '||'Modify_Bank_Accounts');
        xtr_risk_debug_pkg.dlog('Modify_Bank_Accounts: ' || 'bank_acct_rec.ce_bank_account_id',p_xtr_bank_account_rec.ce_bank_account_id);
        xtr_risk_debug_pkg.dlog('Modify_Bank_Accounts: ' || 'p_action_flag', p_action_flag);
        xtr_risk_debug_pkg.dlog('Modify_Bank_Accounts: ' || 'x_return_status', x_return_status);
        xtr_risk_debug_pkg.dpop('xtr_replicate_bank_accounts_P: '||'Modify_Bank_Accounts');
    END IF;

    EXCEPTION
        When app_exceptions.RECORD_LOCK_EXCEPTION then -- If the record is locked
            if C_CHK_LOCK%ISOPEN then
                close c_CHK_LOCK;
            end if;
            LOG_ERR_MSG('CHK_LOCK');
            x_return_status := FND_API.G_RET_STS_ERROR;
           --app_exceptions.RECORD_LOCK_EXCEPTION;
        WHEN  DUP_VAL_ON_INDEX then                 -- bug 4870353
             x_return_status    := FND_API.G_RET_STS_ERROR;
             LOG_ERR_MSG('XTR_UNIQUE_ACCOUNT');
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END MODIFY_BANK_ACCOUNTS;

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
      )

IS

CURSOR c_field_name(p_name VARCHAR2) IS
    SELECT text
    FROM xtr_sys_languages_vl
    WHERE item_name = p_name
    AND MODULE_NAME = 'XTRSECOM'
    UNION
    SELECT text
    FROM xtr_sys_languages_vl
    WHERE item_name = p_name
    AND MODULE_NAME = 'XTRSECPY';



l_field_name    xtr_sys_languages_vl.text%TYPE;

BEGIN

    IF p_error_code = 'XTR_MANDATORY' THEN
        OPEN c_field_name(p_field_name);
        FETCH c_field_name INTO l_field_name;
        CLOSE c_field_name;
        FND_MESSAGE.Set_Name('XTR','XTR_MANDATORY_FIELD');
        FND_MESSAGE.Set_Token('FIELD', l_field_name);
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_INV_TRS_PRICING_MODEL' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_INV_TRS_PRICING_MODEL');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_INV_CC_ID' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_INV_CC_ID');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_UNIQUE_ACCOUNT' THEN    -- bug 4870353

        FND_MESSAGE.Set_Name('XTR','XTR_UNIQUE_ACCOUNT');
        FND_MSG_PUB.Add;

    ELSIF p_error_code = 'XTR_UNEXP_ERROR' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_UNEXP_ERROR');
        FND_MESSAGE.Set_Token('SQLCODE', p_field_name);
        --FND_MESSAGE.Set_Token('SQLSTATE', p_field_name2);
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_INV_LE_COMP_CODE' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_INV_LE_COMP_CODE');
	FND_MESSAGE.Set_Token('LEGAL_ENTITY', p_field_name);
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'CHK_LOCK' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_1999');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_INV_PARAM' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_INV_PARAMETER');
        FND_MESSAGE.Set_Token('FIELD', p_field_name);
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_DEFAULT_ACCT' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_1676');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_CHK_30_BOTH' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_CHK_30_BOTH');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

   ELSIF p_error_code = 'XTR_INV_BANK_BRANCH' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_INV_BANK_BRANCH');
        FND_MESSAGE.Set_Token('TCA_BANK_BRANCH_NAME', p_field_name);
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_ACCT_NAME_MANDATORY' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_ACCT_NAME_MANDATORY');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_CURRENCY_MANDATORY' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_CURRENCY_MANDATORY');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_LOCATION_MANDATORY' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_LOCATION_MANDATORY');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_STREET_MANDATORY' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_STREET_MANDATORY');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_ACCT_OWNER_MANDATORY' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_ACCT_OWNER_MANDATORY');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.

    ELSIF p_error_code = 'XTR_ACCOUNT_MANDATORY_FIELD' THEN

        FND_MESSAGE.Set_Name('XTR','XTR_ACCOUNT_MANDATORY_FIELD');
        FND_MSG_PUB.Add; -- Adds the error messages to the list.




    END IF;

    EXCEPTION
        WHEN others THEN

         LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END LOG_ERR_MSG;

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
        )

IS

    CURSOR c_chk_lock_interest IS
        SELECT ce_bank_account_id
        FROM XTR_BANK_ACCOUNTS
        WHERE ce_bank_account_id = p_ce_bank_account_id
        FOR UPDATE NOWAIT;
    l_ce_bank_account_id XTR_BANK_ACCOUNTS.ce_bank_account_id%TYPE;--change this

BEGIN
    x_msg_count := NULL;
    FND_MSG_PUB.Initialize; -- Initializes the message list that stores the errors

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Verifies if the ce_bank_account_id in XTR_BANK_ACCOUNTS is passed as null
    IF(p_ce_bank_account_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_INV_PARAM','XTR_BANK_ACCOUNTS.ce_bank_account_id');
    END IF;
-- Verifies if  year calculated basis is '30/'  and a day count basis type of Both Days for the same deal.
    IF(substr(p_day_count_basis,1,2) = '30' and p_interest_includes = 'B') THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        LOG_ERR_MSG('XTR_CHK_30_BOTH');
    END IF;
    IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        OPEN c_chk_lock_interest;
        FETCH c_chk_lock_interest INTO l_ce_bank_account_id;
        IF c_chk_lock_interest%FOUND THEN
            CLOSE c_chk_lock_interest;
            UPDATE XTR_BANK_ACCOUNTS
                SET rounding_type     =   p_interest_rounding
                    ,day_count_type    =   p_interest_includes
                    ,year_calc_type = p_day_count_basis,
                    interest_calculation_basis = p_interest_calculation_basis
                WHERE ce_bank_account_id = l_ce_bank_account_id; -- change this
            -- Calling  the Bank Balances API to replicate
            -- the interest includes and rounding in XTR_BANK_BALANCES
            IF(p_interest_rounding is not null and p_interest_includes is not null) THEN
             XTR_REPLICATE_BANK_BALANCES.UPDATE_ROUNDING_DAYCOUNT
                   (p_ce_bank_account_id ,p_interest_rounding,p_interest_includes
                    ,x_return_status);
            END IF;
        ELSE

            CLOSE c_chk_lock_interest;
                x_return_status := FND_API.G_RET_STS_ERROR;
                LOG_ERR_MSG('XTR_INV_PARAM','XTR_BANK_ACCOUNTS.ce_bank_account_id');

        END IF;

    END IF;
    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
        (   p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
        );
    EXCEPTION
        When app_exceptions.RECORD_LOCK_EXCEPTION then -- If the record is locked
            if C_CHK_LOCK_INTEREST%ISOPEN then
                close c_CHK_LOCK_INTEREST;
            end if;
            LOG_ERR_MSG('CHK_LOCK');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
                (   p_count         =>      x_msg_count     ,
                    p_data          =>      x_msg_data
                 );
           --app_exceptions.RECORD_LOCK_EXCEPTION;
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
          FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
            (   p_count         =>      x_msg_count     ,
                p_data          =>      x_msg_data
            );


END REPLICATE_INTEREST_SCHEDULES;


END XTR_REPLICATE_BANK_ACCOUNTS_P;


/
