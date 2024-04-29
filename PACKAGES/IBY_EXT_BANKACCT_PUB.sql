--------------------------------------------------------
--  DDL for Package IBY_EXT_BANKACCT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXT_BANKACCT_PUB" AUTHID CURRENT_USER AS
/*$Header: ibyxbnks.pls 120.11.12010000.9 2010/04/02 13:06:58 vkarlapu ship $*/

 --
 -- Declaring Global variables
 --
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_EXT_BANKACCT_PUB';

 --
 -- module name used for the application debugging framework
 --
 G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_EXT_BANKACCT_PUB';


 -- Masking character
 G_MASK_CHARACTER CONSTANT VARCHAR2(1) := 'X';
 -- Default unmask length
 G_DEF_UNMASK_LENGTH CONSTANT NUMBER := 4;
 -- Bank number padd character
 G_BANK_NUMBER_PAD CONSTANT VARCHAR2(1) := ' ';


 -------------------------------------------------------------------------
 -- **Defining all DataStructures required by the APIs**
 -- The following PL/SQL record/table types are defined
 -- to store the objects (entities) necessary for the APIs.
 -------------------------------------------------------------------------
 --
 -- Generic Record Types
 --

 -- External Bank Record
  TYPE ExtBank_rec_type IS RECORD (
    bank_id                     hz_parties.PARTY_ID%TYPE,
    bank_name                   hz_parties.PARTY_NAME%TYPE,
    bank_number                 hz_organization_profiles.BANK_OR_BRANCH_NUMBER%TYPE,
    institution_type            hz_code_assignments.CLASS_CODE%TYPE,
    country_code                hz_parties.COUNTRY%TYPE,
    bank_alt_name               hz_parties.ORGANIZATION_NAME_PHONETIC%TYPE,
    bank_short_name             hz_parties.KNOWN_AS%TYPE,
    description                 hz_parties.MISSION_STATEMENT%TYPE,
    tax_payer_id                hz_organization_profiles.JGZZ_FISCAL_CODE%TYPE,
    tax_registration_number     hz_organization_profiles.TAX_REFERENCE%TYPE,
    attribute_category          hz_parties.ATTRIBUTE_CATEGORY%TYPE,
    attribute1                  hz_parties.ATTRIBUTE1%TYPE,
    attribute2                  hz_parties.ATTRIBUTE2%TYPE,
    attribute3                  hz_parties.ATTRIBUTE3%TYPE,
    attribute4                  hz_parties.ATTRIBUTE4%TYPE,
    attribute5                  hz_parties.ATTRIBUTE5%TYPE,
    attribute6                  hz_parties.ATTRIBUTE6%TYPE,
    attribute7                  hz_parties.ATTRIBUTE7%TYPE,
    attribute8                  hz_parties.ATTRIBUTE8%TYPE,
    attribute9                  hz_parties.ATTRIBUTE9%TYPE,
    attribute10                 hz_parties.ATTRIBUTE10%TYPE,
    attribute11                 hz_parties.ATTRIBUTE11%TYPE,
    attribute12                 hz_parties.ATTRIBUTE12%TYPE,
    attribute13                 hz_parties.ATTRIBUTE13%TYPE,
    attribute14                 hz_parties.ATTRIBUTE14%TYPE,
    attribute15                 hz_parties.ATTRIBUTE15%TYPE,
    attribute16                 hz_parties.ATTRIBUTE16%TYPE,
    attribute17                 hz_parties.ATTRIBUTE17%TYPE,
    attribute18                 hz_parties.ATTRIBUTE18%TYPE,
    attribute19                 hz_parties.ATTRIBUTE19%TYPE,
    attribute20                 hz_parties.ATTRIBUTE20%TYPE,
    attribute21                 hz_parties.ATTRIBUTE21%TYPE,
    attribute22                 hz_parties.ATTRIBUTE22%TYPE,
    attribute23                 hz_parties.ATTRIBUTE23%TYPE,
    attribute24                 hz_parties.ATTRIBUTE24%TYPE,
    object_version_number       hz_parties.OBJECT_VERSION_NUMBER%TYPE
    );

 -- External Bank Branch Record
  TYPE ExtBankBranch_rec_type IS RECORD(
        branch_party_id            hz_parties.PARTY_ID%TYPE,
        bank_party_id		       hz_parties.PARTY_ID%TYPE,
        branch_name                hz_parties.PARTY_NAME%TYPE,
        branch_number              hz_organization_profiles.BANK_OR_BRANCH_NUMBER%TYPE,
	    branch_type		           hz_code_assignments.CLASS_CODE%TYPE,
        alternate_branch_name      hz_parties.ORGANIZATION_NAME_PHONETIC%TYPE,
        description                hz_parties.MISSION_STATEMENT%TYPE,
        bic                        hz_contact_points.EFT_SWIFT_CODE%TYPE,
        eft_number	               hz_contact_points.EFT_USER_NUMBER%TYPE,
	    rfc_identifier	           hz_code_assignments.CLASS_CODE%TYPE,
	    attribute_category         hz_parties.ATTRIBUTE_CATEGORY%TYPE,
	    attribute1                 hz_parties.ATTRIBUTE1%TYPE,
  	    attribute2                 hz_parties.ATTRIBUTE2%TYPE,
	    attribute3                 hz_parties.ATTRIBUTE3%TYPE,
	    attribute4                 hz_parties.ATTRIBUTE4%TYPE,
	    attribute5                 hz_parties.ATTRIBUTE5%TYPE,
	    attribute6                 hz_parties.ATTRIBUTE6%TYPE,
	    attribute7                 hz_parties.ATTRIBUTE7%TYPE,
	    attribute8                 hz_parties.ATTRIBUTE8%TYPE,
	    attribute9                 hz_parties.ATTRIBUTE9%TYPE,
	    attribute10                hz_parties.ATTRIBUTE10%TYPE,
	    attribute11                hz_parties.ATTRIBUTE11%TYPE,
	    attribute12                hz_parties.ATTRIBUTE12%TYPE,
	    attribute13                hz_parties.ATTRIBUTE13%TYPE,
	    attribute14                hz_parties.ATTRIBUTE14%TYPE,
	    attribute15                hz_parties.ATTRIBUTE15%TYPE,
	    attribute16                hz_parties.ATTRIBUTE16%TYPE,
	    attribute17                hz_parties.ATTRIBUTE17%TYPE,
	    attribute18                hz_parties.ATTRIBUTE18%TYPE,
	    attribute19                hz_parties.ATTRIBUTE19%TYPE,
	    attribute20                hz_parties.ATTRIBUTE20%TYPE,
	    attribute21                hz_parties.ATTRIBUTE21%TYPE,
	    attribute22                hz_parties.ATTRIBUTE22%TYPE,
	    attribute23                hz_parties.ATTRIBUTE23%TYPE,
	    attribute24                hz_parties.ATTRIBUTE24%TYPE,
	    bch_object_version_number  hz_parties.OBJECT_VERSION_NUMBER%TYPE,
        typ_object_version_number  hz_code_assignments.OBJECT_VERSION_NUMBER%TYPE,
	    rfc_object_version_number  hz_code_assignments.OBJECT_VERSION_NUMBER%TYPE,
        eft_object_version_number  hz_code_assignments.OBJECT_VERSION_NUMBER%TYPE
  );

 -- External Bank Account Record
  TYPE ExtBankAcct_rec_type IS RECORD (
    bank_account_id		         iby_ext_bank_accounts.EXT_BANK_ACCOUNT_ID%TYPE,
    country_code		         iby_ext_bank_accounts.COUNTRY_CODE%TYPE,
    branch_id			         iby_ext_bank_accounts.BRANCH_ID%TYPE,
    bank_id			             iby_ext_bank_accounts.BANK_ID%TYPE,
    acct_owner_party_id          iby_account_owners.ACCOUNT_OWNER_PARTY_ID%TYPE,
    bank_account_name		     iby_ext_bank_accounts.BANK_ACCOUNT_NAME%TYPE,
    bank_account_num		     iby_ext_bank_accounts.BANK_ACCOUNT_NUM%TYPE,
    currency			         iby_ext_bank_accounts.CURRENCY_CODE%TYPE,
    iban			             iby_ext_bank_accounts.IBAN%TYPE,
    check_digits		         iby_ext_bank_accounts.CHECK_DIGITS%TYPE,
    multi_currency_allowed_flag  varchar2(1),
    alternate_acct_name		     iby_ext_bank_accounts.BANK_ACCOUNT_NAME_ALT%TYPE,
    short_acct_name              iby_ext_bank_accounts.SHORT_ACCT_NAME%TYPE,
    acct_type			         iby_ext_bank_accounts.BANK_ACCOUNT_TYPE%TYPE,
    acct_suffix			         iby_ext_bank_accounts.ACCOUNT_SUFFIX%TYPE,
    description			         iby_ext_bank_accounts.DESCRIPTION%TYPE,
    agency_location_code	     iby_ext_bank_accounts.AGENCY_LOCATION_CODE%TYPE,
    foreign_payment_use_flag	 iby_ext_bank_accounts.FOREIGN_PAYMENT_USE_FLAG%TYPE,
    exchange_rate_agreement_num  iby_ext_bank_accounts.EXCHANGE_RATE_AGREEMENT_NUM%TYPE,
    exchange_rate_agreement_type iby_ext_bank_accounts.EXCHANGE_RATE_AGREEMENT_TYPE%TYPE,
    exchange_rate		         iby_ext_bank_accounts.EXCHANGE_RATE%TYPE,
    payment_factor_flag		     iby_ext_bank_accounts.PAYMENT_FACTOR_FLAG%TYPE,
    status                       varchar2(1),
    end_date                     iby_ext_bank_accounts.END_DATE%TYPE,
    START_DATE                   iby_ext_bank_accounts.START_DATE%TYPE,
    hedging_contract_reference   iby_ext_bank_accounts.HEDGING_CONTRACT_REFERENCE%TYPE,
    attribute_category		     iby_ext_bank_accounts.ATTRIBUTE_CATEGORY%TYPE,
    attribute1			         iby_ext_bank_accounts.ATTRIBUTE1%TYPE,
    attribute2			         iby_ext_bank_accounts.ATTRIBUTE2%TYPE,
    attribute3			         iby_ext_bank_accounts.ATTRIBUTE3%TYPE,
    attribute4                   iby_ext_bank_accounts.ATTRIBUTE4%TYPE,
    attribute5                   iby_ext_bank_accounts.ATTRIBUTE5%TYPE,
    attribute6                   iby_ext_bank_accounts.ATTRIBUTE6%TYPE,
    attribute7                   iby_ext_bank_accounts.ATTRIBUTE7%TYPE,
    attribute8                   iby_ext_bank_accounts.ATTRIBUTE8%TYPE,
    attribute9                   iby_ext_bank_accounts.ATTRIBUTE9%TYPE,
    attribute10                  iby_ext_bank_accounts.ATTRIBUTE10%TYPE,
    attribute11                  iby_ext_bank_accounts.ATTRIBUTE11%TYPE,
    attribute12                  iby_ext_bank_accounts.ATTRIBUTE12%TYPE,
    attribute13                  iby_ext_bank_accounts.ATTRIBUTE13%TYPE,
    attribute14                  iby_ext_bank_accounts.ATTRIBUTE14%TYPE,
    attribute15                  iby_ext_bank_accounts.ATTRIBUTE15%TYPE,
    object_version_number        iby_ext_bank_accounts.OBJECT_VERSION_NUMBER%TYPE,
    secondary_account_reference   iby_ext_bank_accounts.SECONDARY_ACCOUNT_REFERENCE%TYPE,   -- Bug 7408747(Added New Parameter to save Secondary Account Reference),
    contact_name		  iby_ext_bank_accounts.CONTACT_NAME%TYPE, -- New columns for CLM Reference Data Management uptake.
    contact_phone                 iby_ext_bank_accounts.CONTACT_PHONE%TYPE,
    contact_email                 iby_ext_bank_accounts.CONTACT_EMAIL%TYPE,
    contact_fax			  iby_ext_bank_accounts.CONTACT_FAX%TYPE
  );

 -- Intermediary Bank Account Record
  TYPE IntermediaryAcct_rec_type IS RECORD(
    intermediary_acct_id        iby_intermediary_accts.INTERMEDIARY_ACCT_ID%TYPE,
    bank_account_id             iby_intermediary_accts.BANK_ACCT_ID%TYPE,
	country_code                iby_intermediary_accts.COUNTRY_CODE%TYPE,
	bank_name	                iby_intermediary_accts.BANK_NAME%TYPE,
	city                        iby_intermediary_accts.CITY%TYPE,
	bank_code                   iby_intermediary_accts.BANK_CODE%TYPE,
	branch_number               iby_intermediary_accts.BRANCH_NUMBER%TYPE,
	bic                         iby_intermediary_accts.BIC%TYPE,
	account_number              iby_intermediary_accts.ACCOUNT_NUMBER%TYPE,
	check_digits                iby_intermediary_accts.CHECK_DIGITS%TYPE,
	iban                        iby_intermediary_accts.IBAN%TYPE,
	comments                    iby_intermediary_accts.COMMENTS%TYPE,
	object_version_number       iby_intermediary_accts.OBJECT_VERSION_NUMBER%TYPE
  );

  /*======================================================================
   * APIs defined in this package
   *
   *   1. create_ext_bank
   *   2. update_ext_bank
   *   3. set_ext_bank_end_date
   *   4. check_ext_bank_exist
   *   5. create_bank_branch
   *   6. update_bank_branch
   *   7. set_bank_branch_end_date
   *   8. check_ext_bank_branch_exist
   *   9. create_ext_bank_acct
   *  10. update_ext_bank_acct
   *  11. set_ext_bank_acct_dates
   *  12. check_ext_acct_exist
   *  13. get_ext_bank_acct
   *  14. get_ext_bank_acct
   *  15. create_intermediary_acct
   *  16. update_intermediary_acct
   *  17. add_joint_acct_owner
   *  18. set_joint_acct_owner_end_date
   *  19. change_primary_acct_owner
   +====================================================================*/


   -- 1. create_ext_bank
   --
   --   API name        : create_ext_bank
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Creates an external bank
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --
   PROCEDURE create_ext_bank (
    p_api_version              IN  NUMBER,
	p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_ext_bank_rec             IN  ExtBank_rec_type,
	x_bank_id                  OUT NOCOPY NUMBER,
	x_return_status            OUT NOCOPY VARCHAR2,
	x_msg_count                OUT NOCOPY NUMBER,
	x_msg_data                 OUT NOCOPY VARCHAR2,
	x_response                 OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


   -- 2. update_ext_bank
   --
   --   API name        : update_ext_bank
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Updates the external bank
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --
   PROCEDURE update_ext_bank (
    p_api_version              IN  NUMBER,
	p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	p_ext_bank_rec             IN  ExtBank_rec_type,
	x_return_status            OUT NOCOPY VARCHAR2,
	x_msg_count                OUT NOCOPY NUMBER,
	x_msg_data                 OUT NOCOPY VARCHAR2,
	x_response                 OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
   );


   -- 3. set_bank_end_date
   --
   --   API name        : set_bank_end_date
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Sets the bank end date
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --
   PROCEDURE set_bank_end_date (
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_bank_id                   IN   NUMBER,
    p_end_date                  IN   DATE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    );


  -- 4. check_bank_exist
  --
  --   API name        : check_bank_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the bank exists; bank name/number
  --                     and country code are used for identity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_bank_exist (
   p_api_version                 IN   NUMBER,
   p_init_msg_list               IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_country_code                IN   VARCHAR2,
   p_bank_name                   IN   VARCHAR2,
   p_bank_number                 IN   VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   x_bank_id                     OUT NOCOPY NUMBER,
   x_end_date                    OUT NOCOPY DATE,
   x_response                    OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    );


  -- 5. create_ext_bank_branch
  --
  --   API name        : create_ext_bank_branch
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates the external bank branch
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_ext_bank_branch (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 default FND_API.G_FALSE,
   p_ext_bank_branch_rec        IN   ExtBankBranch_rec_type,
   x_branch_id                  OUT  NOCOPY  NUMBER,
   x_return_status              OUT  NOCOPY  VARCHAR2,
   x_msg_count                  OUT  NOCOPY  NUMBER,
   x_msg_data                   OUT  NOCOPY  VARCHAR2,
   x_response                   OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 6. update_ext_bank_branch
  --
  --   API name        : update_ext_bank_branch
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates the external bank branch
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_ext_bank_branch (
   p_api_version                IN     NUMBER,
   p_init_msg_list              IN     VARCHAR2 default FND_API.G_FALSE,
   p_ext_bank_branch_rec        IN OUT NOCOPY ExtBankBranch_rec_type,
   x_return_status                 OUT NOCOPY  VARCHAR2,
   x_msg_count                     OUT NOCOPY  NUMBER,
   x_msg_data                      OUT NOCOPY  VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 7. set_ext_bank_branch_end_date
  --
  --   API name        : set_ext_bank_branch_end_date
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the bank branch end date
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_ext_bank_branch_end_date (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 default FND_API.G_FALSE,
   p_branch_id                  IN   NUMBER,
   p_end_date                   IN   DATE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 8. check_ext_bank_branch_exist
  --
  --   API name        : check_ext_bank_branch_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the bank branch exists; branch name/number
  --                     and bank id are used for identity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_ext_bank_branch_exist (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 default FND_API.G_FALSE,
   p_bank_id                    IN   NUMBER,
   p_branch_name                IN   VARCHAR2,
   p_branch_number              IN   VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_branch_id                  OUT NOCOPY NUMBER,
   x_end_date                   OUT NOCOPY DATE,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 9. create_ext_bank_acct
  --
  --   API name        : create_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_ext_bank_acct (
   p_api_version                IN   NUMBER,
   p_init_msg_list            	IN   VARCHAR2 default FND_API.G_FALSE,
   p_ext_bank_acct_rec          IN   ExtBankAcct_rec_type,
   x_acct_id			        OUT  NOCOPY NUMBER,
   x_return_status            	OUT  NOCOPY  VARCHAR2,
   x_msg_count                	OUT  NOCOPY  NUMBER,
   x_msg_data                 	OUT  NOCOPY  VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );

  --- Updated for the bug 6461487
  PROCEDURE create_ext_bank_acct (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_ext_bank_acct_rec          IN   ExtBankAcct_rec_type,
   p_association_level          IN   VARCHAR2,
   p_supplier_site_id           IN   NUMBER,
   p_party_site_id              IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_org_type			IN   VARCHAR2 default NULL,     --Bug7136876: new parameter
   x_acct_id                    OUT  NOCOPY NUMBER,
   x_return_status              OUT  NOCOPY  VARCHAR2,
   x_msg_count                  OUT  NOCOPY  NUMBER,
   x_msg_data                   OUT  NOCOPY  VARCHAR2,
   x_response                   OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 10. update_ext_bank_acct
  --
  --   API name        : update_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_ext_bank_acct (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2 default FND_API.G_FALSE,
   p_ext_bank_acct_rec         IN  OUT NOCOPY ExtBankAcct_rec_type,
   x_return_status                 OUT NOCOPY VARCHAR2,
   x_msg_count                     OUT NOCOPY NUMBER,
   x_msg_data                      OUT NOCOPY VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 11. get_ext_bank_acct
  --
  --   API name        : get_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE get_ext_bank_acct (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
   p_bankacct_id               IN   NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   x_bankacct                  OUT NOCOPY ExtBankAcct_rec_type,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 12. get_ext_bank_acct
  --
  --   API name        : get_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries an external bank account, decrypting secure
  --                     fields
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE get_ext_bank_acct (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
   p_bankacct_id               IN   NUMBER,
   p_sec_key                   IN   VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   x_bankacct                  OUT NOCOPY ExtBankAcct_rec_type,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 13. set_ext_bank_acct_dates
  --
  --   API name        : set_ext_bank_acct_dates
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the bank account end dates
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_ext_bank_acct_dates (
   p_api_version              IN     NUMBER,
   p_init_msg_list            IN     VARCHAR2 default FND_API.G_FALSE,
   p_acct_id                  IN     NUMBER,
   p_start_date		          IN	 DATE,
   p_end_date                 IN     DATE,
   p_object_version_number    IN OUT NOCOPY  NUMBER,
   x_return_status               OUT NOCOPY  VARCHAR2,
   x_msg_count                   OUT NOCOPY  NUMBER,
   x_msg_data                    OUT NOCOPY  VARCHAR2,
   x_response                    OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 14. check_ext_acct_exist
  --
  --   API name        : check_ext_acct_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the external account exists; identity
  --                     is determined by bank id, branch id, country and
  --                     currency codes
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
   PROCEDURE check_ext_acct_exist(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 default FND_API.G_FALSE,
    p_ext_bank_acct_rec      IN  ExtBankAcct_rec_type,
    x_acct_id                OUT NOCOPY NUMBER,
	x_start_date		     OUT NOCOPY DATE,
	x_end_date		         OUT NOCOPY DATE,
	x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_response               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );

  -- 14. check_ext_acct_exist
  --
  --   API name        : check_ext_acct_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the external account exists; identity
  --                     is determined by bank id, branch id, country and
  --                     currency codes
  --
  --
  --        Input parameters for the procedure is modified to facilitate
  -- country specific unique bank account validation. But this procedure
  -- is used by many external products. To ensure that no other code breaks
  -- due to this change, the original procedure is maintained as overloaded
  -- procedure. This procedure should be removed as soon as all the external
  -- products update their code to use the updated procedure.
  --
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
   PROCEDURE check_ext_acct_exist(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2  default FND_API.G_FALSE,
    p_bank_id                IN varchar2,
    p_branch_id              IN  NUMBER,
    p_acct_number            IN  VARCHAR2,
    p_acct_name              IN  VARCHAR2,
    p_currency		     IN  VARCHAR2,
    p_country_code           IN  VARCHAR2,
    x_acct_id                OUT NOCOPY NUMBER,
    x_start_date		     OUT NOCOPY DATE,
    x_end_date		         OUT NOCOPY DATE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_response               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 15. create_intermediary_acct
  --
  --   API name        : create_intermediary_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates an intermediary bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_intermediary_acct (
    p_api_version              IN   NUMBER,
	p_init_msg_list            IN   VARCHAR2 default FND_API.G_FALSE,
    p_intermed_acct_rec        IN   IntermediaryAcct_rec_type,
	x_intermediary_acct_id     OUT  NOCOPY NUMBER,
	x_return_status            OUT  NOCOPY  VARCHAR2,
	x_msg_count                OUT  NOCOPY  NUMBER,
	x_msg_data                 OUT  NOCOPY  VARCHAR2,
	x_response                 OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 16. Update_Intermediary_Acct
  --
  --   API name        : Update_Intermediary_Acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates an intermediary bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_intermediary_acct (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 default FND_API.G_FALSE,
   p_intermed_acct_rec        IN  OUT NOCOPY  IntermediaryAcct_rec_type,
   x_return_status                OUT NOCOPY  VARCHAR2,
   x_msg_count                    OUT NOCOPY  NUMBER,
   x_msg_data                     OUT NOCOPY  VARCHAR2,
   x_response                     OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 17. add_joint_account_owner
  --
  --   API name        : add_joint_account_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Associates another owner with a bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE add_joint_account_owner (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2 default FND_API.G_FALSE,
   p_bank_account_id           IN   NUMBER,
   p_acct_owner_party_id       IN   NUMBER,
   x_joint_acct_owner_id	   OUT  NOCOPY  NUMBER,
   x_return_status             OUT  NOCOPY  VARCHAR2,
   x_msg_count                 OUT  NOCOPY  NUMBER,
   x_msg_data                  OUT  NOCOPY  VARCHAR2,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 18. set_joint_acct_owner_end_date
  --
  --   API name        : set_joint_acct_owner_end_date
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the end data for a joint account owner
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_joint_acct_owner_end_date (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN     VARCHAR2 default FND_API.G_FALSE,
   p_acct_owner_id              IN     NUMBER,
   p_end_date                   IN     DATE,
   p_object_version_number      IN OUT NOCOPY  NUMBER,
   x_return_status                 OUT NOCOPY  VARCHAR2,
   x_msg_count                     OUT NOCOPY  NUMBER,
   x_msg_data                      OUT NOCOPY  VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 19. change_primary_acct_owner
  --
  --   API name        : change_primary_acct_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Changes the
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE change_primary_acct_owner (
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2 default FND_API.G_FALSE,
   p_bank_acct_id               IN NUMBER,
   p_acct_owner_party_id        IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );



    -- 20. check_bank_acct_owner
  --
  --   API name        : check_bank_acct_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Changes the
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_bank_acct_owner (
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2 default FND_API.G_FALSE,
   p_bank_acct_id               IN NUMBER,
   p_acct_owner_party_id        IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  );


  -- 100. Mask_Bank_Number
  --
  --   Function        : Mask_Bank_Number
  --   Type            : Private
  --   Purpose         : Masks secured bank account attributes using bank
  --                     account mask settings
  --
  FUNCTION Mask_Bank_Number( p_bank_number IN VARCHAR2 ) RETURN VARCHAR2;

  -- 101. Mask_Bank_Number
  --
  --   Function        : Mask_Bank_Number
  --   Type            : Private
  --   Purpose         : Masks secured bank account attributes
  --
  FUNCTION Mask_Bank_Number
  (p_bank_number     IN   VARCHAR2,
   p_mask_option     IN   iby_ext_bank_accounts.ba_mask_setting%TYPE,
   p_unmask_len      IN   iby_ext_bank_accounts.ba_unmask_length%TYPE
  )
  RETURN VARCHAR2;

  --
  -- USE: Gets the Bank account encryption mode setting
  --
  FUNCTION Get_BA_Encrypt_Mode
  RETURN iby_sys_security_options.ext_ba_encryption_mode%TYPE;


  -- 102. Uncipher_Bank_Number
  --
  --   Function        : Uncipher_Bank_Number
  --   Type            : Private
  --   Purpose         : Unciphers a bank account/IBAN number
  --
  FUNCTION Uncipher_Bank_Number
  (p_unmask_digits  IN   VARCHAR2,
   p_segment_id     IN   iby_security_segments.sec_segment_id%TYPE,
   p_sys_key        IN   iby_security_pkg.DES3_KEY_TYPE,
   p_sub_key_cipher IN   iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_segment_cipher IN   iby_security_segments.segment_cipher_text%TYPE,
   p_encoding       IN   iby_security_segments.encoding_scheme%TYPE,
   p_mask_option    IN   iby_ext_bank_accounts.ba_mask_setting%TYPE,
   p_unmask_len     IN   iby_ext_bank_accounts.ba_unmask_length%TYPE
  )
  RETURN VARCHAR2;

  -- 103. Remask_Accounts
  --
  --   Function        : Remask_Accounts
  --   Type            : Private
  --   Purpose         : Remasks secured bank account attributes
  --
  PROCEDURE Remask_Accounts
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  -- 104. Encrypt_Accounts
  --
  --   Function        : Encrypt_Accounts
  --   Type            : Private
  --   Purpose         : Encrypts all unencrypted accounts
  --
  PROCEDURE Encrypt_Accounts
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  -- 104. Decrypt_Accounts
  --
  --   Function        : Decrypt_Accounts
  --   Type            : Private
  --   Purpose         : Decrypt all encrypted accounts
  --
  PROCEDURE Decrypt_Accounts
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  );

  -- 105. Compress_Bank_Number
  --
  PROCEDURE Compress_Bank_Number
  (p_bank_number  IN VARCHAR2,
   p_mask_setting IN iby_sys_security_options.ext_ba_mask_setting%TYPE,
   p_unmask_len   IN iby_sys_security_options.ext_ba_unmask_len%TYPE,
   x_compress_num OUT NOCOPY VARCHAR2,
   x_unmask_digits OUT NOCOPY VARCHAR2
  );


  --106. FSIO Code.. To Fetch vendor_id given party_id
  --
  PROCEDURE vendor_id(p_party_id IN VARCHAR2,
                      x_vendor_id OUT NOCOPY NUMBER);



--
  FUNCTION find_assignment_OU
  ( p_ext_bank_acct_id IN iby_ext_bank_accounts.ext_bank_account_id%TYPE
  )
  RETURN NUMBER;

END IBY_EXT_BANKACCT_PUB;

/
