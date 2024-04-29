--------------------------------------------------------
--  DDL for Package IBY_EXT_BANKACCT_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EXT_BANKACCT_VALIDATIONS" AUTHID CURRENT_USER AS
/*$Header: ibybnkvals.pls 120.1.12000000.1 2007/01/18 06:04:02 appldev ship $*/

 --
 -- Declaring Global variables
 --
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_EXT_BANKACCT_VALIDATIONS';

 --
 -- module name used for the application debugging framework
 --
  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_EXT_BANKACCT_VALIDATIONS';


  --  iby_validate_account
  --
  --   API name        : iby_validate_account
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : validates the external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0

  PROCEDURE iby_validate_account(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 default FND_API.G_FALSE,
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    x_response                OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    );


  --  iby_validate_account
  --
  --   API name        : iby_validate_account
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : validates the external bank account, overloaded
  --                     using the p_create_flag parameter
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --

  PROCEDURE iby_validate_account(
    p_api_version             IN NUMBER,
    p_init_msg_list           IN VARCHAR2 default FND_API.G_FALSE,
    p_create_flag             IN VARCHAR2 default FND_API.G_TRUE,
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    x_response                OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    );


END IBY_EXT_BANKACCT_VALIDATIONS;

 

/
