--------------------------------------------------------
--  DDL for Package Body IBY_EXT_BANKACCT_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXT_BANKACCT_VALIDATIONS" AS
/*$Header: ibybnkvalb.pls 120.16.12010000.4 2010/01/04 19:04:31 vkarlapu ship $*/

G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 --
 -- Forward Declarations
 --
  PROCEDURE print_debuginfo(
    p_message              IN     VARCHAR2,
    p_prefix               IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level            IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module               IN     VARCHAR2 DEFAULT G_DEBUG_MODULE
  );

  PROCEDURE check_mandatory(
    p_field           IN     VARCHAR2,
    p_value           IN     VARCHAR2
   );

  --  iby_validate_account_at
  --
  --   API name        : iby_validate_account_at
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Austria Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0

  PROCEDURE iby_validate_account_at(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_at';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AT (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P',
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      l_bank_branch_num := p_ext_bank_branch_rec.branch_number;

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AT(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_branch_num);

      p_ext_bank_branch_rec.branch_number :=
         NVL(l_bank_branch_num, p_ext_bank_branch_rec.branch_number);

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_at;


  --  iby_validate_account_au
  --
  --   API name        : iby_validate_account_au
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Australian Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_au(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_au';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_AU(
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_CURRENCY_CODE    => p_ext_bank_acct_rec.currency);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_AU(
         Xi_BANK_NUMBER    => l_bank_num);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_AU(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id,
         Xi_PASS_MAND_CHECK  => 'P');
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'AU',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);


    END IF;
  END iby_validate_account_au;


  --  iby_validate_account_be
  --
  --   API name        : iby_validate_account_be
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Belgian Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_be(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_be';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_BE(
       Xi_ACCOUNT_NUMBER   => l_bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P');


    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);


    END IF;
  END iby_validate_account_be;

  --  iby_validate_account_ca
  --
  --   API name        : iby_validate_account_ca
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Canadian Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_ca(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_ca';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
    END iby_validate_account_ca;


  --  iby_validate_account_de
  --
  --   API name        : iby_validate_account_de
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : German Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_de(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_de';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DE (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_DE(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_DE(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'DE',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);
    END IF;

    -- Validate Check Digit
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_DE(
         Xi_CD               => p_ext_bank_acct_rec.check_digits,
         Xi_X_ACCOUNT_NUMBER => p_ext_bank_acct_rec.bank_account_num);

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);


    END IF;
    END iby_validate_account_de;


  --  iby_validate_account_dk
  --
  --   API name        : iby_validate_account_dk
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Denmark Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_dk(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_dk';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_DK (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P',
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    x_valid := TRUE;

  END iby_validate_account_dk;


  --  iby_validate_account_fi
  --
  --   API name        : iby_validate_account_fi
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Finnish Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_fi(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_fi';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   val_result           BOOLEAN;
   l_bank_account_num   VARCHAR2(100);
   l_bank_branch_num    VARCHAR2(30);
   l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FI (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P');


    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_fi;


  --  iby_validate_account_fr
  --
  --   API name        : iby_validate_account_fr
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : France Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_fr(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_fr';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_FR (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P',
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      l_bank_num := p_ext_bank_rec.bank_number;

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_FR(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_num);

      p_ext_bank_rec.bank_number :=
         NVL(l_bank_num,p_ext_bank_rec.bank_number);

      l_bank_branch_num := p_ext_bank_branch_rec.branch_name;

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_FR(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_branch_num);

      p_ext_bank_branch_rec.branch_number :=
         NVL(l_bank_branch_num, p_ext_bank_branch_rec.branch_number);

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_FR(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_PASS_MAND_CHECK   =>  'P',
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  translate(p_ext_bank_acct_rec.bank_account_num,
                                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                                            '123456789123456789234567890'));

    x_valid := TRUE;

  END iby_validate_account_fr;


  --  iby_validate_account_gb
  --
  --   API name        : iby_validate_account_gb
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Greek Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_gb(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_gb';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GB (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GB(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GB(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'GB',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_gb;


  --  iby_validate_account_gr
  --
  --   API name        : iby_validate_account_gr
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Greek Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_gr(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_gr';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   val_result           BOOLEAN;
   l_bank_account_num   VARCHAR2(100);
   l_bank_branch_num    VARCHAR2(30);
   l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_GR (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_GR(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_GR(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number);

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_GR(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_PASS_MAND_CHECK   =>  'P',
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  translate(p_ext_bank_acct_rec.bank_account_num,
                                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                                            '123456789123456789234567890'));


    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_gr;


  --  iby_validate_account_hk
  --
  --   API name        : iby_validate_account_hk
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Hongkong Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_hk(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_hk';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_hk;


  --  iby_validate_account_il
  --
  --   API name        : iby_validate_account_il
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Iceland Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_il(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_il';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   val_result           BOOLEAN;
   l_bank_account_num   VARCHAR2(100);
   l_bank_branch_num    VARCHAR2(30);
   l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IL (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IL(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number,
         Xi_PASS_MAND_CHECK  => 'P');

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IL(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P');

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);


    END IF;
  END iby_validate_account_il;


  --  iby_validate_account_ie
  --
  --   API name        : iby_validate_account_ie
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Ireland Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_ie(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_ie';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);



  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);
     END IF;
    x_valid := FALSE;

    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IE (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_IE(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IE(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'IE',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);
    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_ie;

  --  iby_validate_account_is
  --
  --   API name        : iby_validate_account_is
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_is(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_is';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IS (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      l_bank_branch_num := p_ext_bank_branch_rec.branch_name;

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IS(
         Xi_BRANCH_NUMBER  => p_ext_bank_branch_rec.branch_number,
		 Xi_BANK_ID        => p_ext_bank_rec.bank_id,
         Xo_VALUE_OUT      => l_bank_branch_num);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'IS',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);

       p_ext_bank_branch_rec.branch_number :=
         NVL(l_bank_branch_num, p_ext_bank_branch_rec.branch_number);

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_IS(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_X_ACCOUNT_NUMBER  =>  translate(p_ext_bank_acct_rec.bank_account_num,
                                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                                            '123456789123456789234567890'));

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_is;

  --  iby_validate_account_it
  --
  --   API name        : iby_validate_account_it
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_it(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_it';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_IT (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_IT(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P');

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_IT(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_PASS_MAND_CHECK   =>  'P',
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  p_ext_bank_acct_rec.bank_account_num);

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_it;


  --  iby_validate_account_jp
  --
  --   API name        : iby_validate_account_jp
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Japan Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_jp(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_jp';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);
     END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_JP(
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_ACCOUNT_TYPE     => p_ext_bank_acct_rec.acct_type);


    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_JP(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number,
         Xi_BANK_NAME_ALT  => p_ext_bank_rec.bank_alt_name,
         Xi_PASS_MAND_CHECK  => 'P');

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_JP(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BRANCH_NAME_ALT  => p_ext_bank_branch_rec.alternate_branch_name,
         Xi_PASS_MAND_CHECK  => 'P');


    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_jp;


  --  iby_validate_account_lu
  --
  --   API name        : iby_validate_account_lu
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Luzembourg Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_lu(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_lu';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_LU (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_LU(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_LU(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'LU',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_LU(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  p_ext_bank_acct_rec.bank_account_num);

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_lu;


  --  iby_validate_account_nl
  --
  --   API name        : iby_validate_account_nl
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Netherlands Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_nl(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_nl';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NL (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P');

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);
    END IF;
  END iby_validate_account_nl;


  --  iby_validate_account_nz
  --
  --   API name        : iby_validate_account_nz
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : New Zealand Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_nz(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_nz';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NZ (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_ACCOUNT_SUFFIX  => p_ext_bank_acct_rec.acct_suffix);

    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_NZ(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number,
         Xi_PASS_MAND_CHECK  => 'P');


      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_NZ(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P');

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_nz;


  --  iby_validate_account_no
  --
  --   API name        : iby_validate_account_no
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Norway Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_no(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_no';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_NO (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P');

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_no;


  --  iby_validate_account_pl
  --
  --   API name        : iby_validate_account_pl
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Poland Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_pl(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_pl';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PL (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num);


    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PL(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

      /*
      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PL(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID          => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'PL',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);
    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_pl;


  --  iby_validate_account_pt
  --
  --   API name        : iby_validate_account_pt
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Portugal Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_pt(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_pt';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_PT (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P',
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_PT(
         Xi_BANK_NUMBER      => p_ext_bank_rec.bank_number,
         Xi_PASS_MAND_CHECK  => 'P');

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_PT(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P');

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_PT(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_PASS_MAND_CHECK   =>  'P',
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  translate(p_ext_bank_acct_rec.bank_account_num,
                                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                                            '123456789123456789234567890'));

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);
    END IF;
  END iby_validate_account_pt;


  --  iby_validate_account_sg
  --
  --   API name        : iby_validate_account_sg
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_sg(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_sg';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_sg;



  --  iby_validate_account_es
  --
  --   API name        : iby_validate_account_es
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_es(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_es';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    l_bank_account_num := p_ext_bank_acct_rec.bank_account_num;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_ES (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num,
       Xi_PASS_MAND_CHECK  => 'P',
       Xo_VALUE_OUT        => l_bank_account_num);

    p_ext_bank_acct_rec.bank_account_num :=
          NVL(l_bank_account_num,p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      l_bank_num := p_ext_bank_rec.bank_number;

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_ES(
         Xi_BANK_NUMBER      => p_ext_bank_rec.bank_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_num);

      p_ext_bank_rec.bank_number :=
         NVL(l_bank_num,p_ext_bank_rec.bank_number);

      l_bank_branch_num := p_ext_bank_branch_rec.branch_number;

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_ES(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_branch_num);

      p_ext_bank_branch_rec.branch_number :=
         NVL(l_bank_branch_num, p_ext_bank_branch_rec.branch_number);

    END IF;

    -- Validate Check Digits
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_ES(
         Xi_CD                =>  p_ext_bank_acct_rec.check_digits,
         Xi_PASS_MAND_CHECK   =>  'P',
         Xi_X_BANK_NUMBER     =>  p_ext_bank_rec.bank_number,
         Xi_X_BRANCH_NUMBER   =>  p_ext_bank_branch_rec.branch_number,
         Xi_X_ACCOUNT_NUMBER  =>  translate(p_ext_bank_acct_rec.bank_account_num,
                                            'ABCDEFGHIJKLMNOPQRSTUVWXYZ ',
                                            '123456789123456789234567890'));

  END iby_validate_account_es;


  --  iby_validate_account_se
  --
  --   API name        : iby_validate_account_se
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_se(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_se';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    -- Validate Bank Account Information
    CE_VALIDATE_BANKINFO.CE_VALIDATE_ACCOUNT_SE (
       Xi_ACCOUNT_NUMBER   => p_ext_bank_acct_rec.bank_account_num);

    IF (foreign_payment_flag) THEN

      -- Validate Bank
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BANK_SE(
         Xi_BANK_NUMBER    => p_ext_bank_rec.bank_number);

       /*
       -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_SE(
         Xi_BRANCH_NUMBER  => p_ext_bank_branch_rec.branch_number,
         Xi_BANK_ID        => p_ext_bank_rec.bank_id);
      */

      -- Validate Bank Branch
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Calling bank branch validation CE API');
            END IF;
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_BANK(
           Xi_COUNTRY	  => 'SE',
           Xi_BRANCH_NUM  => p_ext_bank_branch_rec.branch_number,
           Xi_BANK_NUM	  => p_ext_bank_rec.bank_number,
           Xo_VALUE_OUT   => l_bank_branch_num);
    END IF;

    x_valid := TRUE;

    -- Validate Check Digit
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD_SE(
         Xi_CD               => p_ext_bank_acct_rec.check_digits,
         Xi_X_ACCOUNT_NUMBER => p_ext_bank_acct_rec.bank_account_num);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_se;


  --  iby_validate_account_us
  --
  --   API name        : iby_validate_account_us
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Italy Validations
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  PROCEDURE iby_validate_account_us(
    p_ext_bank_rec            IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBank_rec_type,
    p_ext_bank_branch_rec     IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type,
    p_ext_bank_acct_rec       IN OUT NOCOPY IBY_EXT_BANKACCT_PUB.ExtBankAcct_rec_type,
    foreign_payment_flag      IN BOOLEAN,
    x_valid                   IN OUT NOCOPY BOOLEAN
    )
  IS
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account_us';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  val_result           BOOLEAN;
  l_bank_account_num   VARCHAR2(100);
  l_bank_branch_num    VARCHAR2(30);
  l_bank_num           VARCHAR2(30);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
    END IF;
    x_valid := FALSE;

    IF (foreign_payment_flag
       AND p_ext_bank_branch_rec.branch_number IS NOT NULL  -- Bug 6043905
       ) THEN

      l_bank_num := p_ext_bank_rec.bank_number;

      l_bank_branch_num := p_ext_bank_branch_rec.branch_name;

      -- Validate Bank Branch
      CE_VALIDATE_BANKINFO.CE_VALIDATE_BRANCH_US(
         Xi_BRANCH_NUMBER    => p_ext_bank_branch_rec.branch_number,
         Xi_PASS_MAND_CHECK  => 'P',
         Xo_VALUE_OUT        => l_bank_branch_num);

      p_ext_bank_branch_rec.branch_number :=
         NVL(l_bank_branch_num, p_ext_bank_branch_rec.branch_number);

    END IF;

    x_valid := TRUE;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END iby_validate_account_us;


  --  iby_validate_account
  --
  --   API name        : iby_validate_account
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : validates the external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --

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
    )
    IS

    BEGIN

    iby_validate_account(
       p_api_version            => p_api_version,
       p_init_msg_list          => p_init_msg_list,
       p_create_flag            => FND_API.G_TRUE,
       p_ext_bank_rec           => p_ext_bank_rec,
       p_ext_bank_branch_rec    => p_ext_bank_branch_rec,
       p_ext_bank_acct_rec      => p_ext_bank_acct_rec,
       x_return_status          => x_return_status,
       x_msg_count              => x_msg_count,
       x_msg_data               => x_msg_data,
       x_response               => x_response
       );


    END iby_validate_account;


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
    )
  IS
  l_bank_rec  	       hz_bank_pub.bank_rec_type;
  l_branch_rec         	hz_bank_pub.bank_rec_type;
  l_org_rec   	 hz_party_v2pub.organization_rec_type;
  l_country			VARCHAR2(60);
  l_party_rec 	 hz_party_v2pub.party_rec_type;
  l_api_name           CONSTANT VARCHAR2(30)   := 'iby_validate_account';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  X_PASS_MAND_CHECK  VARCHAR2(1) := 'P';
  COUNTRY            VARCHAR2(2);
  x_valid            BOOLEAN := FALSE;
  l_foreign_pmt_flag BOOLEAN := FALSE;
  l_count            NUMBER;
  l_return_status    VARCHAR2(35);
  l_iban             VARCHAR2(50);
 l_bank_number	 VARCHAR2(30);
 l_branch_number		VARCHAR2(30);
 l_bank_name			VARCHAR2(360);
  -- get bank info. cursor
  CURSOR c_bank IS
      SELECT hz_p.party_name, hz_org.bank_or_branch_number, hz_org.home_country
      FROM   hz_parties                 hz_p,
             hz_organization_profiles   hz_org
      WHERE  hz_p.party_id = hz_org.party_id
      AND    SYSDATE between TRUNC(hz_org.effective_start_date)
             and NVL(TRUNC(hz_org.effective_end_date), SYSDATE+1)
      AND    hz_p.party_id = p_ext_bank_acct_rec.bank_id;

  -- checks if account already exists
CURSOR uniq_check (p_account_number VARCHAR2,
                     p_currency VARCHAR2,
                     p_bank_id NUMBER,
                     p_branch_id NUMBER,
                     p_country_code VARCHAR2,
                     p_bank_account_id NUMBER) IS

     SELECT count(1)
     FROM IBY_EXT_BANK_ACCOUNTS
     WHERE ((BANK_ACCOUNT_NUM = p_account_number) OR
             (BANK_ACCOUNT_NUM_HASH1=  iby_security_pkg.Get_Hash
                       (p_account_number,'F')
                       AND BANK_ACCOUNT_NUM_HASH2=iby_security_pkg.Get_Hash
                       (p_account_number,'T') ))
         AND ((p_currency IS NULL and CURRENCY_CODE is NULL)  OR (CURRENCY_CODE = p_currency))
        AND ((p_bank_id IS NULL AND BANK_ID is NULL) OR (BANK_ID = p_bank_id))
        AND ((p_branch_id IS NULL AND BRANCH_ID is NULL) OR (BRANCH_ID = p_branch_id))
       AND p_country_code=COUNTRY_CODE
     AND ((p_bank_account_id is NULL) OR p_bank_account_id<>EXT_BANK_ACCOUNT_ID);


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Account Number is mandatory
    check_mandatory('IBY_ACCT_NUM_FIELD', p_ext_bank_acct_rec.bank_account_num);

    IF (p_create_flag = FND_API.G_TRUE) THEN

       -- Account Name if specfied should be unique
       IF (p_ext_bank_acct_rec.bank_account_name <> NULL) THEN
         SELECT COUNT(EXT_BANK_ACCOUNT_ID)
           INTO l_count
           FROM IBY_EXT_BANK_ACCOUNTS_V
          WHERE BANK_ACCOUNT_NAME =p_ext_bank_acct_rec.bank_account_name;

          IF (l_count > 0) THEN
            fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_NAME');
            fnd_msg_pub.add;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Bank Account Name failed unique check');
            END IF;
            x_valid := FALSE;
         END IF;
       END IF;

       -- perform unique check for account
       OPEN uniq_check(p_ext_bank_acct_rec.bank_account_num,
                       p_ext_bank_acct_rec.currency,
                       p_ext_bank_acct_rec.bank_id,
                       p_ext_bank_acct_rec.branch_id,
                       p_ext_bank_acct_rec.country_code,
                       p_ext_bank_acct_rec.bank_account_id);
       FETCH uniq_check into l_count;

       IF (l_count > 0) THEN
          fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
          fnd_msg_pub.add;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo('Bank Account Name failed unique check');
          END IF;
          x_valid := FALSE;
       END IF;

    END IF;

    /* Foreign Payment Flag decides whether bank and branch records
     * are optional or mandatory
     */
     IF ((p_ext_bank_acct_rec.foreign_payment_use_flag = 'Y')  AND
       (p_ext_bank_acct_rec.bank_id is NULL)) THEN
        l_foreign_pmt_flag := TRUE;
        -- Bank Name is mandatory
        --check_mandatory('IBY_BANK_NAME_FIELD',p_ext_bank_rec.bank_name);
         fnd_message.set_name('IBY', 'IBY_API_NO_BANK');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
           END IF;

   IF ((p_ext_bank_acct_rec.foreign_payment_use_flag = 'Y')  AND
       (p_ext_bank_acct_rec.branch_id is NULL)) THEN
        l_foreign_pmt_flag := TRUE;
         -- Bank Branch Name is mandatory
        --check_mandatory('IBY_BRANCH_NAME_FIELD',p_ext_bank_branch_rec.branch_name);
         fnd_message.set_name('IBY', 'IBY_API_NO_BRANCH');
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
     END IF;

     /* if bank information provided, we need validate bank info.*/
    if((NOT p_ext_bank_rec.bank_name is NULL)  AND
       (p_ext_bank_acct_rec.bank_id is NULL)) then

/* Bug 6043905: Bank number is not mandatory for all the countries */
--         check_mandatory(IBY_BANK_NUM_FIELD, p_ext_bank_rec.bank_number);

     -- call CE validate bank api to validate bank
     -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_bank(p_ext_bank_rec.country_code,
					  p_ext_bank_rec.bank_number,
					  p_ext_bank_rec.bank_name,
					  p_ext_bank_rec.bank_alt_name,
					  p_ext_bank_rec.tax_payer_id,
					  null,    -- bank_id
                                          FND_API.G_FALSE,  -- do not re-initialize msg stack
                                          x_msg_count,
					  x_msg_data,
					  l_bank_number,   -- reformated bank number
					  x_return_status);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('After return from CE country specific validation: '|| x_return_status);
      END IF;
   -- raise an exception if country specific validations fail
    IF (x_return_status IS NULL OR
        x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

     -- call HZ bank validation API to validate bank record
   l_party_rec.attribute_category := p_ext_bank_rec.attribute_category;
    l_party_rec.attribute1 := p_ext_bank_rec.attribute1;
    l_party_rec.attribute2 := p_ext_bank_rec.attribute2;
    l_party_rec.attribute3 := p_ext_bank_rec.attribute3;
    l_party_rec.attribute4 := p_ext_bank_rec.attribute4;
    l_party_rec.attribute5 := p_ext_bank_rec.attribute5;
    l_party_rec.attribute6 := p_ext_bank_rec.attribute6;
    l_party_rec.attribute7 := p_ext_bank_rec.attribute7;
    l_party_rec.attribute8 := p_ext_bank_rec.attribute8;
    l_party_rec.attribute9 := p_ext_bank_rec.attribute9;
    l_party_rec.attribute10 := p_ext_bank_rec.attribute10;
    l_party_rec.attribute11 := p_ext_bank_rec.attribute11;
    l_party_rec.attribute12 := p_ext_bank_rec.attribute12;
    l_party_rec.attribute13 := p_ext_bank_rec.attribute13;
    l_party_rec.attribute14 := p_ext_bank_rec.attribute14;
    l_party_rec.attribute15 := p_ext_bank_rec.attribute15;
    l_party_rec.attribute16 := p_ext_bank_rec.attribute16;
    l_party_rec.attribute17 := p_ext_bank_rec.attribute17;
    l_party_rec.attribute18 := p_ext_bank_rec.attribute18;
    l_party_rec.attribute19 := p_ext_bank_rec.attribute19;
    l_party_rec.attribute20 := p_ext_bank_rec.attribute20;
    l_party_rec.attribute21 := p_ext_bank_rec.attribute21;
    l_party_rec.attribute22 := p_ext_bank_rec.attribute22;
    l_party_rec.attribute23 := p_ext_bank_rec.attribute23;
    l_party_rec.attribute24 := p_ext_bank_rec.attribute24;


   l_org_rec.organization_name := p_ext_bank_rec.bank_name;
    l_org_rec.organization_name_phonetic := p_ext_bank_rec.bank_alt_name;
    l_org_rec.known_as := p_ext_bank_rec.bank_short_name;
    l_org_rec.mission_statement := p_ext_bank_rec.description;
    l_org_rec.jgzz_fiscal_code := p_ext_bank_rec.tax_payer_id;
    l_org_rec.tax_reference := p_ext_bank_rec.tax_registration_number;
    l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;
    l_org_rec.home_country := p_ext_bank_rec.country_code;
    l_bank_rec.bank_or_branch_number := p_ext_bank_rec.bank_number;
    l_bank_rec.country := p_ext_bank_rec.country_code;
    l_bank_rec.institution_type := 'BANK';
    l_bank_rec.organization_rec := l_org_rec;

     -- now call HZ validation api
    hz_bank_pub.validate_bank (p_init_msg_list,
                               l_bank_rec,
                                'I',
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data);
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo('After return from HZ bank validation: '|| x_return_status);
 END IF;
    -- raise an exception if the validation routine is unsuccessful
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    end if;

/* Bug 6043905: The branch number is not mandatory for all countries.
    if((NOT p_ext_bank_branch_rec.branch_name is NULL)  AND
       (p_ext_bank_acct_rec.branch_id is NULL)) then
         check_mandatory('Branch Number', p_ext_bank_branch_rec.branch_number);
    end if;
*/

   /*
    * If bank id is not available, do not validate the bank branch.
    *
    * The bank is the primary entity, and the branch is the secondary entity.
    * The CE branch validation API expects the bank id as an input param.
    *
    * Without the bank id, this API will always return an error for the
    * branch validation. Therefore, it is logical to skip the branch
    * validation when the bank id is not available.
    *
    * See bug 5117620 for a discussion on this subject.
    */
   -- if the bank is not new, and branch is new, we need validate the branch info.
      if((NOT p_ext_bank_branch_rec.branch_name is NULL)  AND
       (p_ext_bank_acct_rec.branch_id is NULL)            AND
       (NOT p_ext_bank_acct_rec.bank_id is NULL)  ) then

        -- call CE bank branch validation api


    -- get bank information
     OPEN c_bank;
    FETCH c_bank INTO l_bank_name, l_bank_number, l_country;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank;

   -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_branch(l_country,
                                            l_bank_number,
                                            p_ext_bank_branch_rec.branch_number,
                                            l_bank_name,
                                            p_ext_bank_branch_rec.branch_name,
                                             p_ext_bank_branch_rec.alternate_branch_name,
                                            p_ext_bank_acct_rec.bank_id,
                                            null,    -- branch_id
                                            FND_API.G_FALSE,  -- do not re-initialize msg stack
                                            x_msg_count,
                                            x_msg_data,
                                            l_branch_number,   -- reformatted branch number
                                            x_return_status);

    -- raise an exception if country specific validations fail
    IF (x_return_status IS NULL OR
        x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    -- check HZ validate branch API
    l_party_rec.attribute_category := p_ext_bank_branch_rec.attribute_category;
    l_party_rec.attribute1 := p_ext_bank_branch_rec.attribute1;
    l_party_rec.attribute2 := p_ext_bank_branch_rec.attribute2;
    l_party_rec.attribute3 := p_ext_bank_branch_rec.attribute3;
    l_party_rec.attribute4 := p_ext_bank_branch_rec.attribute4;
    l_party_rec.attribute5 := p_ext_bank_branch_rec.attribute5;
    l_party_rec.attribute6 := p_ext_bank_branch_rec.attribute6;
    l_party_rec.attribute7 := p_ext_bank_branch_rec.attribute7;
    l_party_rec.attribute8 := p_ext_bank_branch_rec.attribute8;
    l_party_rec.attribute9 := p_ext_bank_branch_rec.attribute9;
    l_party_rec.attribute10 := p_ext_bank_branch_rec.attribute10;
    l_party_rec.attribute11 := p_ext_bank_branch_rec.attribute11;
    l_party_rec.attribute12 := p_ext_bank_branch_rec.attribute12;
    l_party_rec.attribute13 := p_ext_bank_branch_rec.attribute13;
    l_party_rec.attribute14 := p_ext_bank_branch_rec.attribute14;
    l_party_rec.attribute15 := p_ext_bank_branch_rec.attribute15;
    l_party_rec.attribute16 := p_ext_bank_branch_rec.attribute16;
    l_party_rec.attribute17 := p_ext_bank_branch_rec.attribute17;
    l_party_rec.attribute18 := p_ext_bank_branch_rec.attribute18;
    l_party_rec.attribute19 :=p_ext_bank_branch_rec. attribute19;
    l_party_rec.attribute20 := p_ext_bank_branch_rec.attribute20;
    l_party_rec.attribute21 := p_ext_bank_branch_rec.attribute21;
    l_party_rec.attribute22 := p_ext_bank_branch_rec.attribute22;
    l_party_rec.attribute23 := p_ext_bank_branch_rec.attribute23;
    l_party_rec.attribute24 := p_ext_bank_branch_rec.attribute24;

    l_org_rec.organization_name := p_ext_bank_branch_rec.branch_name;
    l_org_rec.organization_name_phonetic := p_ext_bank_branch_rec.alternate_branch_name;
    l_org_rec.mission_statement := p_ext_bank_branch_rec.description;
    l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;
    l_org_rec.home_country := l_country;

    l_branch_rec.bank_or_branch_number := p_ext_bank_branch_rec.branch_number;
    l_branch_rec.branch_type := p_ext_bank_branch_rec.branch_type;
    l_branch_rec.rfc_code := p_ext_bank_branch_rec.rfc_identifier;
    l_branch_rec.institution_type := 'BANK_BRANCH';
    l_branch_rec.organization_rec := l_org_rec;
    l_branch_rec.country := l_country;

  -- now call HZ validation branch api
    hz_bank_pub.validate_bank_branch (p_init_msg_list,
                               p_ext_bank_acct_rec.bank_id,
                               l_branch_rec,
                                'I',
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data);
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo('After return from HZ branch validation: '|| x_return_status);
 END IF;
    -- raise an exception if the validation routine is unsuccessful
    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    end if;

    /* perform validation on bank number, bank branch number*/


    COUNTRY := p_ext_bank_acct_rec.country_code;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Country Code: '||COUNTRY);
    END IF;
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_country(
        p_country_code  => p_ext_bank_acct_rec.country_code,
        x_return_status => l_return_status);
    IF (l_return_status = fnd_api.g_ret_sts_error) THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate IBAN Number
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN (
       p_IBAN         	=> p_ext_bank_acct_rec.iban,
	   p_IBAN_OUT     	=> l_iban,
	   x_return_status  => l_return_status);
	IF (l_return_status = fnd_api.g_ret_sts_error) THEN
       RAISE fnd_api.g_exc_error;
    END IF;

    -- invoke Country specific validation procedures
    CASE COUNTRY
       WHEN 'AT' THEN
 	      iby_validate_account_at(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
       WHEN 'AU' THEN
 	      iby_validate_account_au(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'BE' THEN
 	      iby_validate_account_be(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'CA' THEN
 	      iby_validate_account_ca(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'DE' THEN
 	      iby_validate_account_de(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'DK' THEN
 	      iby_validate_account_dk(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'ES' THEN
 	      iby_validate_account_es(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'FI' THEN
 	      iby_validate_account_fi(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'FR' THEN
 	      iby_validate_account_fr(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'GB' THEN
 	      iby_validate_account_gb(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'GR' THEN
 	      iby_validate_account_gr(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'HK' THEN
 	      iby_validate_account_hk(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'IE' THEN
 	      iby_validate_account_ie(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'IL' THEN
 	      iby_validate_account_il(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'IS' THEN
 	      iby_validate_account_is(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'IT' THEN
 	      iby_validate_account_it(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'JP' THEN
 	      iby_validate_account_jp(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'LU' THEN
 	      iby_validate_account_lu(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'NL' THEN
 	      iby_validate_account_nl(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'NO' THEN
 	      iby_validate_account_no(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'NZ' THEN
 	      iby_validate_account_nz(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'PL' THEN
 	      iby_validate_account_pl(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'PT' THEN
 	      iby_validate_account_pt(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'SE' THEN
 	      iby_validate_account_se(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'SG' THEN
 	      iby_validate_account_sg(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
      WHEN 'US' THEN
 	      iby_validate_account_us(
            p_ext_bank_rec,
            p_ext_bank_branch_rec,
            p_ext_bank_acct_rec,
            l_foreign_pmt_flag,
            x_valid);
    ELSE
       -- Not a recognized country, mark as successful
       x_valid := TRUE;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('No validations for country'|| COUNTRY);
       END IF;
    END CASE;


    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);


    IF x_msg_count > 0 THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Failed ');
      END IF;
    ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Successful');
      END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('IN Exception fnd_api.g_exc_error');
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('IN Exception fnd_api.g_ret_sts_unexp_error');
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
    --  fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
    --  fnd_message.set_token('ERROR',SQLERRM);
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
    --  fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END iby_validate_account;



  --  print_debuginfo
  --
  --   Type            : check_mandatory procedure
  --   Pre-reqs        : None
  --   Function        : check for mandatory parameters.
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0

   PROCEDURE check_mandatory(
      p_field           IN     VARCHAR2,
      p_value           IN     VARCHAR2
   ) IS

   l_temp         VARCHAR2(80);

   CURSOR c_validate_currency (p_currency_code  VARCHAR2) IS
      SELECT CURRENCY_CODE
        FROM FND_CURRENCIES
       WHERE CURRENCY_CODE = p_currency_code;

   BEGIN

   if (p_value is NULL) THEN
       fnd_message.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
       fnd_message.set_token('PARAM', fnd_message.get_string('IBY', p_field));
       fnd_msg_pub.add;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(p_field || ' is a required parameter.');
       END IF;
       RAISE fnd_api.g_exc_error;
   END IF;


   --Validate Currency
   IF (UPPER(p_field) = 'CURRENCY') THEN
      OPEN c_validate_currency(p_value);
      FETCH c_validate_currency INTO l_temp;
      CLOSE c_validate_currency;

      IF (l_temp IS NULL) THEN
         fnd_message.set_name('IBY', 'IBY_INVALID_CURRENCY');
         fnd_message.set_token('CURRENCY_CODE', p_field);
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;

   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('Checked mandatory field : ' || p_field || ' : ' || p_value);
   END IF;
   END check_mandatory;



  --  print_debuginfo
  --
  --   Type            : utility procedure
  --   Pre-reqs        : None
  --   Function        : write to log
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0

  PROCEDURE print_debuginfo(
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level                             IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module                                IN     VARCHAR2 DEFAULT G_DEBUG_MODULE
  ) IS

   l_message                               VARCHAR2(4000);
   l_module                                VARCHAR2(255);

  BEGIN


    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
       -- Debug info.
       l_module  :=SUBSTRB(p_module,1,255);

       IF p_prefix IS NOT NULL THEN
          l_message :=SUBSTRB(p_prefix||'-'||p_message,1,4000);
       ELSE
          l_message :=SUBSTRB(p_message,1,4000);
       END IF;
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,l_message);

    END IF;
   --   dbms_output.put_line(p_module || ':  ' || p_message);
  END print_debuginfo;

END IBY_EXT_BANKACCT_VALIDATIONS;

/
