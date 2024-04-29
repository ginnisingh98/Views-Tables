--------------------------------------------------------
--  DDL for Package Body ARP_EXT_BANK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_EXT_BANK_PKG" AS
/* $Header: AREXTBAB.pls 120.6.12010000.6 2010/04/14 14:22:23 npanchak ship $ */
  /*-------------------------------------+
   |  WHO column values from FND_GLOBAL  |
   +-------------------------------------*/
  pg_user_id          varchar2(15);
  pg_login_id         number;
  pg_prog_appl_id     number;
  pg_sob_id           number;
  pg_program_id       number;
  pg_request_id       number;
  l_account_exists    number := 0;
  l_rowid    	      varchar2(18);
  l_inactive_date     date;
  CRLF                VARCHAR2(10):= arp_global.CRLF;
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  PROCEDURE strip_white_spaces(
    p_credit_card_num IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
    p_stripped_cc_num OUT NOCOPY iby_ext_bank_accounts_v.bank_account_number%TYPE
  ) IS

  TYPE character_tab_typ IS TABLE of char(1) INDEX BY BINARY_INTEGER;
  len_credit_card_num   number := 0;
  l_cc_num_char         character_tab_typ;
  BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('arp_ext_bank_pkg.strip_white_spaces()+');
        END IF;

        SELECT lengthb(p_credit_card_num)
        INTO   len_credit_card_num
        FROM   dual;

        FOR i in 1..len_credit_card_num LOOP
                SELECT substrb(p_credit_card_num,i,1)
                INTO   l_cc_num_char(i)
                FROM   dual;

                IF ( (l_cc_num_char(i) >= '0') and
                     (l_cc_num_char(i) <= '9')
                   )
                THEN
                    -- Numeric digit. Add to stripped_number and table.
                    p_stripped_cc_num := p_stripped_cc_num || l_cc_num_char(i);
                END IF;
        END LOOP;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('arp_ext_bank_pkg.strip_white_spaces()-');
        END IF;
  EXCEPTION
        when OTHERS then
                raise;
  END strip_white_spaces;

-- begin bug5594142
   PROCEDURE Branch_Num_Format(
               p_Country_Code  IN Varchar2,
               p_Branch_Number IN VARCHAR2,
               p_value_out     OUT NOCOPY VARCHAR2,
               x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_init_msg_list             VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_branch_number             ce_bank_branches_v.branch_number%TYPE ;
    l_value_out                 varchar2(100);
  BEGIN
      arp_standard.debug('arp_ext_bank_pkg.Branch_Num_Format(+)');
      arp_standard.debug('branch number '||p_branch_number);
      CE_VALIDATE_BANKINFO.GET_BRANCH_NUM_FORMAT
                   (X_COUNTRY_NAME  => p_country_code,
                    X_BRANCH_NUMBER => p_branch_number,
                    X_VALUE_OUT     => p_value_out,
                    p_init_msg_list => l_init_msg_list,
                    x_msg_count     => l_msg_count,
                    x_msg_data      => l_msg_data,
                    x_return_status => l_return_status);

      arp_standard.debug ('IBY BRANCH NUM FORMAT API Return Status = ' || l_return_status);
      arp_standard.debug('IBY BRANCH NUMB FORMAT API Branch Number = '||p_value_out);
      x_return_status := l_return_status ;

      IF l_return_status  = fnd_api.g_ret_sts_error OR
         l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

         arp_standard.debug('Errors Reported By IBY Branch Num Format API: ');
         FOR i in 1 .. l_msg_count LOOP
           fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
             l_msg_count);
           arp_standard.debug(l_msg_data);
         END LOOP;
      ELSE
        arp_standard.debug('Branch Number from BRANCH NUM FORMAT API : ' || p_value_out);
      END IF;
      arp_standard.debug('arp_ext_bank_pkg.Branch_Num_Format(-)');
  EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.Branch_Num_Format');
       RAISE;
  END Branch_Num_Format;
-- end bug5594142


/*===========================================================================+
 | PROCEDURE insert_ext_bank_branch                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a bank branch via IBY - CE - TCA api.                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |    iby_ext_bankacct_pub.create_ext_bank                                   |
 |    iby_ext_bankacct_pub.create_ext_bank_branch                            |
 |                                                                           |
 | ARGUMENTS  : IN: p_bank_name            Bank Name                         |
 |                  p_branch_name          Bank Branch Name                  |
 |                  p_bank_number          Bank Number                       |
 |                  p_bank_num             Bank Branch Number                |
 |                  p_end_date             Inactive on                       |
 |                  p_description          Description                       |
 |                                                                           |
 |              OUT:                                                         |
 |                  x_bank_party_id        Bank   Party ID                   |
 |                  x_branch_party_id      Branch Party ID                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-AUG-2005  Surendra Rajan       Created.                            |
 +===========================================================================*/

PROCEDURE insert_ext_bank_branch(
    p_bank_name        IN  ce_bank_branches_v.bank_name%TYPE,
    p_branch_name      IN  ce_bank_branches_v.bank_branch_name%TYPE,
    p_bank_number      IN  ce_bank_branches_v.bank_number%TYPE,
    p_branch_number    IN  ce_bank_branches_v.branch_number%TYPE,
    p_end_date         IN  ce_bank_branches_v.end_date%TYPE DEFAULT NULL,
    p_description      IN  ce_bank_branches_v.description%TYPE DEFAULT NULL,
    x_bank_party_id    OUT NOCOPY ce_bank_branches_v.bank_party_id%TYPE,
    x_branch_party_id  OUT NOCOPY ce_bank_branches_v.branch_party_id%TYPE,
    x_return_status    OUT NOCOPY VARCHAR2) IS                            -- bug 5594142

    l_profile_value             VARCHAR2(30);

    l_bank_party_id       	NUMBER;
    l_bank_party_number   	VARCHAR2(30);
    l_bank_profile_id          	NUMBER;
    l_bank_code_assignment_id  	NUMBER;
    l_ext_bank_rec            	IBY_EXT_BANKACCT_PUB.extbank_rec_type;
    l_bank_response             IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_branch_type     		VARCHAR2(30);
    l_branch_party_id     	NUMBER;
    l_branch_party_number 	VARCHAR2(30);
    l_branch_profile_id         NUMBER;

    l_ext_branch_rec            IBY_EXT_BANKACCT_PUB.ExtBankBranch_rec_type;
    l_branch_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;

    l_api_version      	        NUMBER := 1.0;
    l_init_msg_list    	 	VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_commit	        	VARCHAR2(30) DEFAULT FND_API.G_FALSE;
    l_return_status       	VARCHAR2(30);
    l_msg_count           	NUMBER;
    l_msg_data            	VARCHAR2(2000);

  BEGIN

    arp_standard.debug('arp_ext_bank_pkg.insert_ext_bank_branch(+)');

    fnd_profile.get(
      name => 'HZ_GENERATE_PARTY_NUMBER',
      val  => l_profile_value);

    -- if profile value is 'N' then put 'Y' for this piece of code.
    -- once this processing is done put it back to 'N'. please note
    -- l_profile_valu will continue to have the original value.

    IF (l_profile_value = 'N') THEN
      fnd_profile.put(
         name => 'HZ_GENERATE_PARTY_NUMBER',
         val  => 'Y');
    END IF;

    l_ext_bank_rec.bank_id          := NULL;
    l_ext_bank_rec.bank_name        := p_bank_name;
    l_ext_bank_rec.bank_number      := p_bank_number;
    l_ext_bank_rec.institution_type := 'BANK';
    l_ext_bank_rec.country_code     := 'US';
    l_ext_bank_rec.description      := p_description;


    arp_standard.debug('Calling iby_ext_bankacct_pub.create_ext_bank(+)');

    iby_ext_bankacct_pub.create_ext_bank(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_rec        => l_ext_bank_rec,
      -- OUT parameters
      x_bank_id             => l_bank_party_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_response            => l_bank_response );

    arp_standard.debug ('IBY Bank API Return Status = ' || l_return_status);
    -- begin bug5594142
    x_return_status := l_return_status ;
    -- end bug5594142

    IF l_return_status  = fnd_api.g_ret_sts_error OR
       l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

       arp_standard.debug('Errors Reported By Bank API: ');
       FOR i in 1 .. l_msg_count LOOP
         fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
           l_msg_count);
         arp_standard.debug(l_msg_data);
       END LOOP;

    ELSE
      arp_standard.debug('Bank Party ID : ' || l_bank_party_id);
    END IF;

    x_bank_party_id := l_bank_party_id;

  -- create a branch for the bank above

    l_ext_branch_rec.branch_party_id := NULL;
    l_ext_branch_rec.bank_party_id   := l_bank_party_id;
    l_ext_branch_rec.branch_name     := p_branch_name;
    l_ext_branch_rec.branch_number   := p_branch_number;
    l_ext_branch_rec.branch_type     := 'ABA';
    l_ext_branch_rec.description     := p_description;

    arp_standard.debug('Calling iby_ext_bankacct_pub.create_ext_bank_branch(+)');

    iby_ext_bankacct_pub.create_ext_bank_branch(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_branch_rec => l_ext_branch_rec,
      -- OUT parameters
      x_branch_id           => l_branch_party_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_response            => l_branch_response);

    arp_standard.debug ('IBY Bank Branch API Return Status = ' || l_return_status);
    -- begin bug5594142
    x_return_status := l_return_status ;
    -- end bug5594142

    IF l_return_status  = fnd_api.g_ret_sts_error OR
       l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

       arp_standard.debug('Errors Reported By Bank Branch API: ');
       FOR i in 1 .. l_msg_count LOOP
           fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
            l_msg_count);
           arp_standard.debug(l_msg_data);
       END LOOP;
    ELSE
       arp_standard.debug('Branch Party ID        : ' || l_branch_party_id);
    END IF;

    -- put the profile value back to the original value if changed
    IF (l_profile_value = 'N') THEN
       fnd_profile.put(
             name => 'HZ_GENERATE_PARTY_NUMBER',
             val  => 'N');
    END IF;

    x_branch_party_id := l_branch_party_id;

    arp_standard.debug('arp_ext_bank_pkg.insert_ext_bank_branch(-)');

  EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.insert_ext_bank_branch');
       RAISE;

  END insert_ext_bank_branch;

/*===========================================================================+
 | PROCEDURE insert_bank_account                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a bank account via iby api.                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |    iby_ext_bankacct_pub.create_ext_bank_acc                               |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_bank_account_name    Account Name                      |
 |                  p_bank_account_num     Account Number                    |
 |                  p_bank_party_id        Bank Party ID                     |
 |                  p_branch_party_id      Branch Party ID                   |
 |                  p_customer_id          Customer ID                       |
 |                  p_description          Description                       |
 |                                                                           |
 |              OUT:                                                         |
 |                  x_bank_account_id      Bank Account ID                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Sep-2005  Surendra Rajan       Created                             |
 |                                                                           |
 +===========================================================================*/

  procedure insert_bank_account(
    p_bank_account_name        in  iby_ext_bank_accounts_v.bank_account_name%type,
    p_bank_account_num         in  iby_ext_bank_accounts_v.bank_account_number%type,
    p_bank_party_id            in  iby_ext_bank_accounts_v.bank_party_id%type,
    p_branch_party_id          in  iby_ext_bank_accounts_v.branch_party_id%type,
    p_customer_id              in  iby_ext_bank_accounts_v.primary_acct_owner_party_id%type,
    p_description              in  iby_ext_bank_accounts_v.description%type,
    p_currency_code            in  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_account_id          OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%type,
    x_return_status            OUT NOCOPY VARCHAR2                             -- bug 5594142
                              )  IS

    l_bank_account_id             iby_ext_bank_accounts_v.bank_account_id%TYPE;
    l_ext_bank_acct_rec           iby_ext_bankacct_pub.extbankacct_rec_type;
    l_bank_acct_response          iby_fndcpt_common_pub.result_rec_type;
    l_party_id			  iby_ext_bank_accounts_v.primary_acct_owner_party_id%type;

    l_api_version               NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_commit                    VARCHAR2(30) DEFAULT FND_API.G_FALSE;
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

BEGIN
    arp_standard.debug('arp_ext_bank_pkg.insert_bank_account(+)');

    /* Bug 6799655 : Get the party_id from cust_account_id supplied */
    IF p_customer_id IS NOT NULL THEN
        SELECT party_id INTO l_party_id
        FROM hz_cust_accounts
        WHERE cust_account_id = p_customer_id;
    ELSE
	l_party_id := NULL;
    END IF;

--    l_ext_bank_acct_rec.bank_account_id    := NULL;
    l_ext_bank_acct_rec.bank_account_name  := p_bank_account_name;
    l_ext_bank_acct_rec.bank_account_num   := p_bank_account_num;
    l_ext_bank_acct_rec.bank_id            := p_bank_party_id;
    l_ext_bank_acct_rec.branch_id          := p_branch_party_id;
    l_ext_bank_acct_rec.acct_owner_party_id := l_party_id;
    l_ext_bank_acct_rec.country_code     := 'US';
    l_ext_bank_acct_rec.description        := p_description;
    l_ext_bank_acct_rec.currency           := p_currency_code;


    arp_standard.debug('Calling iby_ext_bankacct_pub.create_ext_bank_acct(+)');

    iby_ext_bankacct_pub.create_ext_bank_acct(
      -- IN parameters
      p_api_version         => l_api_version,
      p_init_msg_list       => l_init_msg_list,
      p_ext_bank_acct_rec   => l_ext_bank_acct_rec,
      -- OUT parameters
      x_acct_id             => l_bank_account_id,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      x_response            => l_bank_acct_response );

    arp_standard.debug ('IBY Bank API Return Status = ' || l_return_status);
    -- begin bug5594142
    x_return_status := l_return_status ;
    -- end bug5594142

    IF l_return_status  = fnd_api.g_ret_sts_error OR
       l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

       arp_standard.debug('Errors Reported By Bank API: ');
       FOR i in 1 .. l_msg_count LOOP
         fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
           l_msg_count);
         arp_standard.debug(l_msg_data);
       END LOOP;

    ELSE
      arp_standard.debug('Bank Account ID : ' || l_bank_account_id);
    END IF;

    x_bank_account_id:= l_bank_account_id;
    arp_standard.debug('arp_ext_bank_pkg.insert_bank_account(-)');
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       arp_standard.debug('Customer_id is invalid');
       RAISE;
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.insert_bank_account');
       RAISE;
END insert_bank_account;


/*===========================================================================+
 | PROCEDURE check_bank_account                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Checks whether an external bank account already exists based on        |
 |    routing_number and account_number.                                     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |    iby_ext_bankacct_pub.check_ext_acct_exist                              |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_routing_number       Routing Number                    |
 |                  p_account_number       Account Number                    |
 |                  p_bank_party_id        Bank Party ID                     |
 |                  p_branch_party_id      Branch Party ID                   |
 |              OUT:                                                         |
 |                  x_bank_account_id      Bank Account Id                   |
 |                  x_start_date           Start Date                        |
 |                  x_end_date             End Date                          |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Sep-2005  Surendra Rajan       Created                             |
 |                                                                           |
 +===========================================================================*/

  procedure check_bank_account(
    p_routing_number  IN  ce_bank_branches_v.branch_number%TYPE,
    p_account_number  IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
    p_bank_party_id   IN  iby_ext_bank_accounts_v.bank_party_id%type,
    p_branch_party_id IN  iby_ext_bank_accounts_v.branch_party_id%type,
    p_currency_code   IN  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_account_id OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%TYPE,
    x_start_date      OUT NOCOPY iby_ext_bank_accounts_v.start_date%TYPE,
    x_end_date        OUT NOCOPY iby_ext_bank_accounts_v.end_date%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2                              -- 5594142
                      )  IS

    l_bank_account_id             iby_ext_bank_accounts_v.bank_account_id%TYPE;
    l_start_date                  iby_ext_bank_accounts_v.start_date%TYPE;
    l_end_date                    iby_ext_bank_accounts_v.end_date%TYPE;
    l_bank_acct_response          iby_fndcpt_common_pub.result_rec_type;

    l_api_version               NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_commit                    VARCHAR2(30) DEFAULT FND_API.G_FALSE;
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

BEGIN
    arp_standard.debug('arp_ext_bank_pkg.check_bank_account(+)');


    iby_ext_bankacct_pub.check_ext_acct_exist(
      -- IN parameters
      p_api_version       => l_api_version,
      p_init_msg_list     => l_init_msg_list,
      p_bank_id           => p_bank_party_id,
      p_branch_id         => p_branch_party_id,
      p_acct_number   	  => p_account_number,
      p_acct_name         => p_routing_number||' '||p_account_number,
      p_currency          => p_currency_code,
      p_country_code      => 'US',
      -- OUT parameters
      x_acct_id           => l_bank_account_id,
      x_start_date        => l_start_date,
      x_end_date          => l_end_date,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      x_response          => l_bank_acct_response );

    arp_standard.debug ('IBY Bank API Return Status = ' || l_return_status);
    -- begin bug5594142
    x_return_status := l_return_status ;
    -- end bug5594142

    IF l_return_status  = fnd_api.g_ret_sts_error OR
       l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

       arp_standard.debug('Errors Reported By Bank API: ');
       FOR i in 1 .. l_msg_count LOOP
         fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
           l_msg_count);
         arp_standard.debug(l_msg_data);
       END LOOP;

    ELSE
      arp_standard.debug('Bank Account ID : ' || l_bank_account_id);
      arp_standard.debug('Start Date      : ' || l_start_date     );
      arp_standard.debug('End Date        : ' || l_end_date       );
    END IF;

    x_bank_account_id:= l_bank_account_id;
    x_start_date     := l_start_date;
    x_end_date       := l_end_date;
    arp_standard.debug('arp_ext_bank_pkg.check_bank_account(-)');
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.check_bank_account');
       RAISE;
END check_bank_account;

/*===========================================================================+
 | PROCEDURE Create_bank_branch_acc                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Tries to find a bank branch based on routing number, if branch not     |
 |    found, then a new one is created.                                      |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |    iby_ext_bankacct_pub.create_ext_bank_acc                               |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_routing_number       Routing Number                    |
 |                  p_account_number       Account Number                    |
 |                                                                           |
 |              OUT:                                                         |
 |                  x_bank_party_id        Bank Id                           |
 |                  x_branch_party_id      Bank Branch Id                    |
 |                  x_bank_account_id      Bank Account Id                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Sep-2005  Surendra Rajan       Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_bank_branch_acc(
    p_routing_number  IN  OUT NOCOPY ce_bank_branches_v.branch_number%TYPE,
    p_account_number  IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
    p_description     IN  iby_ext_bank_accounts_v.description%type,
    p_customer_id     IN  iby_ext_bank_accounts_v.primary_acct_owner_party_id%type,
    p_currency_code   IN  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_party_id   OUT NOCOPY ce_bank_branches_v.bank_party_id%TYPE,
    x_branch_party_id OUT NOCOPY ce_bank_branches_v.branch_party_id%TYPE,
    x_bank_account_id OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2) IS                        -- bug5594142

 /*-----------------------------------------------------+
  | Cursor to fetch bank branch based on routing number |
  +-----------------------------------------------------*/
  CURSOR bank_branch_cur(l_routing_number VARCHAR2) IS
    SELECT bank_party_id,branch_party_id
    FROM   ce_bank_branches_V
    WHERE  branch_number = l_routing_number;

    l_routing_number   ce_bank_branches_v.bank_number%TYPE;
    bank_branch_rec    bank_branch_cur%ROWTYPE;
    l_bank_party_id    ce_bank_branches_v.bank_party_id%TYPE;
    l_branch_party_id  ce_bank_branches_v.branch_party_id%TYPE;
    l_account_name     iby_ext_bank_accounts_v.bank_account_name%TYPE;
    l_bank_account_id  iby_ext_bank_accounts_v.bank_account_id%TYPE;
    l_start_date       iby_ext_bank_accounts_v.start_date%TYPE;
    l_end_date         iby_ext_bank_accounts_v.end_date%TYPE;
    l_return_status    VARCHAR2(30) ;
    l_assign_id        NUMBER;
    l_party_id         NUMBER;
    l_count            NUMBER;

  BEGIN
    arp_standard.debug('arp_ext_bank_pkg.create_bank_branch_acc(+)');
   /*-----------------------------------------------------+
    | Remove non-digit characters from the routing number |
    +-----------------------------------------------------*/
    strip_white_spaces(p_routing_number,l_routing_number);

    -- begin bug 5594142, Get Routing Number
    Branch_Num_Format('US',
                       l_routing_Number,
                       p_routing_Number,
                       l_return_status);
    x_return_status := l_return_status ;
    IF x_return_status <> 'S' THEN
      p_routing_number := l_routing_number ;
      x_bank_party_id  := NULL ;
      x_branch_party_id := NULL ;
      x_bank_account_id := NULL ;
      return ;
    END IF ;
    -- end bug 5594142,
   /*----------------------------------------------------+
    | Try to find bank branch based on routing number    |
    +----------------------------------------------------*/
    OPEN bank_branch_cur(p_routing_number);
    FETCH bank_branch_cur INTO bank_branch_rec;
    IF (bank_branch_cur%FOUND) then
      CLOSE bank_branch_cur;
      l_bank_party_id   := bank_branch_rec.bank_party_id;
      l_branch_party_id := bank_branch_rec.branch_party_id;
      x_bank_party_id   := l_bank_party_id;
      x_branch_party_id := l_branch_party_id;

      arp_standard.debug('Bank and Branch exist for this Routing Number'
                           ||p_routing_number);
    arp_standard.debug('Bank Id '||x_bank_party_id);
    arp_standard.debug('Branch Id '||x_branch_party_id);
   /*-----------------------------------------------------------+
    | Try to find Account Id  based on routing account  number  |
    +-----------------------------------------------------------*/
        check_bank_account(
              -- IN parameters
              p_routing_number    => p_routing_number,
              p_account_number    => p_account_number,
              p_bank_party_id     => x_bank_party_id,
              p_branch_party_id   => x_branch_party_id,
              p_currency_code	  => p_currency_code,
              -- OUT parameters
              x_bank_account_id   => l_bank_account_id,
              x_start_date        => l_start_date,
              x_end_date          => l_end_date,
              x_return_status     => l_return_status
              );
         x_return_status := l_return_Status ;
         If l_bank_account_id   is NOT NULL
         THEN
            x_bank_account_id := l_bank_account_id;
            arp_standard.debug('Bank Account ID : ' || l_bank_account_id);
         ELSE
           /*-----------------------------------------------------+
            | Account not exists for this bank                    |
            +-----------------------------------------------------*/
            l_account_name := p_routing_number||' '||p_account_number;

            Insert_bank_account(
                    -- IN parameters
                    p_bank_account_name => l_account_name,
                    p_bank_account_num  => p_account_number,
                    p_bank_party_id     => l_bank_party_id,
                    p_branch_party_id   => l_branch_party_id,
                    p_customer_id       => p_customer_id,
                    p_description       => p_description,
		    p_currency_code     => p_currency_code,
                    -- OUT parameters
                    x_bank_account_id    => l_bank_account_id,
                    x_return_status     => l_return_status);

            x_return_status := l_return_status ;
            x_bank_account_id := l_bank_account_id;
            arp_standard.debug('Bank Account ID : ' || l_bank_account_id);
         END IF;

    ELSE
      CLOSE bank_branch_cur;
     /*------------------------------------------------------+
      | If bank branch could not be found, create new branch |
      +------------------------------------------------------*/
      arp_standard.debug('Bank and Branch does not exist for this Routing
                                   Number'||p_routing_number);
      Insert_ext_bank_branch(
             -- IN parameters
             p_bank_name       => p_routing_number,
             p_branch_name     => p_routing_number,
             p_bank_number     => p_routing_number,
             p_branch_number   => p_routing_number,
             p_description     => p_description,
             -- OUT parameters
             x_bank_party_id   => l_bank_party_id,
             x_branch_party_id => l_branch_party_id,
             x_return_status   => l_return_status);

             x_return_status    := l_return_status ;
             x_bank_party_id    := l_bank_party_id;
             x_branch_party_id  := l_branch_party_id;

      arp_standard.debug('Bank ID       : ' || l_bank_party_id);
      arp_standard.debug('Branch Party ID : ' || l_branch_party_id);

     /*-----------------------------------------------------+
      | Now create bank account based on the bank branch    |
      +-----------------------------------------------------*/
      If l_bank_party_id   is NOT NULL and
         l_branch_party_id is NOT NULL
      THEN
           l_account_name := p_routing_number||' '||p_account_number;

        Insert_bank_account(
             -- IN parameters
             p_bank_account_name => l_account_name,
             p_bank_account_num  => p_account_number,
             p_bank_party_id     => l_bank_party_id,
             p_branch_party_id   => l_branch_party_id,
             p_customer_id       => p_customer_id,
             p_description       => p_description,
	     p_currency_code     => p_currency_code,
             -- OUT parameters
             x_bank_account_id    => l_bank_account_id,
             x_return_status      => l_return_status);

            x_return_status := l_return_status ;
            x_bank_account_id := l_bank_account_id;
            arp_standard.debug('Bank Account ID : ' || l_bank_account_id);
      END IF;
     END IF;

    -- Bug 7346354 - Start
    IF ( l_bank_account_id IS NOT NULL ) AND ( p_customer_id IS NOT NULL ) THEN
      -- Check whether the assignment exists already
      SELECT count(*) INTO l_count FROM iby_fndcpt_payer_assgn_instr_v
      WHERE cust_account_id = p_customer_id
        AND bank_acct_num_hash1 = iby_security_pkg.get_hash(p_account_number,   'F')
        AND bank_acct_num_hash2 = iby_security_pkg.get_hash(p_account_number,   'T')
        AND branch_number = p_routing_number;

     IF(l_count = 0) THEN
       SELECT party_id INTO l_party_id
       FROM hz_cust_accounts
       WHERE cust_account_id = p_customer_id;

      insert_acct_instr_assignment(
          p_party_id        =>  l_party_id,
          p_customer_id     =>  p_customer_id,
          p_instr_id        =>  l_bank_account_id,
          x_instr_assign_id =>  l_assign_id,
          x_return_status   =>  l_return_status);
      END IF;
    END IF;
    -- Bug 7346354 - End
    arp_standard.debug('l_assign_id '||l_assign_id);
    arp_standard.debug('arp_ext_bank_pkg.create_bank_branch_acc(-)');
  EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.create_bank_branch_acc');
       RAISE;
  END create_bank_branch_acc;

-- Bug 7346354 - Start
/*===========================================================================+
 | PROCEDURE insert_acct_instr_assignment                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Creates an instrument assignment to the given customer with the        |
 |    bank account.                                                          |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |    IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment                        |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_party_id       Party Id                                |
 |                  p_customer_id    Customer Id[Cust Account Id]            |
 |                  p_instr_id       Instrument Id[Bank Account Id]          |
 |              OUT:                                                         |
 |                  x_instr_assign_id     Instrument Assign Id               |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-Aug-2008  Thirumalaisamy       Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_acct_instr_assignment(
    p_party_id        IN  NUMBER,
    p_customer_id     IN  NUMBER,
    p_instr_id        IN  NUMBER,
    x_instr_assign_id   OUT NOCOPY iby_fndcpt_payer_assgn_instr_v.INSTR_ASSIGNMENT_ID%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2) IS

    l_payer_context_rec         IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
    l_pmtInstrAssignment_rec    IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
    l_pmtInstrument_rec_type    IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
    l_api_version               NUMBER := 1.0;
    l_init_msg_list             VARCHAR2(30) DEFAULT FND_API.G_TRUE;
    l_commit                    VARCHAR2(30) DEFAULT FND_API.G_FALSE;
    l_return_status             VARCHAR2(30);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_assign_id                 NUMBER;
    l_branch_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;

  BEGIN
    arp_standard.debug('arp_ext_bank_pkg.insert_acct_instr_assignment(+)');
     l_payer_context_rec.Payment_Function := 'CUSTOMER_PAYMENT';
     l_payer_context_rec.Party_Id := p_party_id;
     l_payer_context_rec.Cust_Account_Id := p_customer_id;

     l_pmtInstrument_rec_type.Instrument_Type := 'BANKACCOUNT';
     l_pmtInstrument_rec_type.Instrument_Id := p_instr_id;

     l_pmtInstrAssignment_rec.Instrument := l_pmtInstrument_rec_type;

     arp_standard.debug('Calling IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(+)');

     IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment(
       -- IN parameters
       p_api_version         => l_api_version,
       p_init_msg_list       => l_init_msg_list,
       p_commit              => l_commit,
       p_payer               => l_payer_context_rec,
       p_assignment_attribs  => l_pmtInstrAssignment_rec,
       -- OUT parameters
       x_assign_id           => l_assign_id,
       x_return_status       => l_return_status,
       x_msg_count           => l_msg_count,
       x_msg_data            => l_msg_data,
       x_response            => l_branch_response);
     arp_standard.debug('IBY IBY_FNDCPT_SETUP_PUB.Set_Payer_Instr_Assignment API Return Status = ' || l_return_status);
     x_return_status := l_return_status ;

    IF l_return_status  = fnd_api.g_ret_sts_error OR
       l_return_status  = fnd_api.g_ret_sts_unexp_error THEN

       arp_standard.debug('Errors Reported By Instrument Assignment API: ');
       FOR i in 1 .. l_msg_count LOOP
         fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false, l_msg_data,
           l_msg_count);
         arp_standard.debug(l_msg_data);
       END LOOP;

    ELSE
      arp_standard.debug('Instrument Assign Id : ' || l_assign_id);
    END IF;
    x_instr_assign_id := l_assign_id;
    arp_standard.debug('arp_ext_bank_pkg.insert_acct_instr_assignment(-)');
  EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('exception in arp_ext_bank_pkg.insert_acct_instr_assignment');
       RAISE;
  END insert_acct_instr_assignment;
-- Bug 7346354 - End

/* bug 6121157 Function is added to return customer payment method id associated with a customer */

/*===========================================================================+
 | FUNCTION get_cust_pay_method                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns customer payment method id                                     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_standard.debug                                                     |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN: p_customer_id                                            |
 |                  p_site_use_id                                            |
 |                  p_pay_method_id                                          |
 |                  p_cc_only                                                |
 |                  p_primary                                                |
 |                  p_check                                                  |
 |                  p_as_of_date                                             |
 |                                                                           |
 | RETURNS    : Number                                                       |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     15-Jun-2007  Deep Gaurab       Created.                               |
 +===========================================================================*/
  FUNCTION get_cust_pay_method(p_customer_id IN NUMBER,
			          p_site_use_id IN NUMBER DEFAULT null,
				  p_pay_method_id IN NUMBER DEFAULT null,
			          p_cc_only IN BOOLEAN DEFAULT TRUE,
			          p_primary IN BOOLEAN DEFAULT TRUE,
				  p_check IN BOOLEAN DEFAULT FALSE,
			          p_as_of_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER IS
  TYPE pri_pay_method_typ IS REF CURSOR;

  pri_pay_method      pri_pay_method_typ;
  l_receipt_method_id AR_RECEIPT_METHODS.receipt_method_id%TYPE := NULL;
  l_site_use_id       AP_BANK_ACCOUNT_USES.CUSTOMER_SITE_USE_ID%TYPE;
  l_as_of_date        DATE := NVL(p_as_of_date, TRUNC(SYSDATE));

  sql_stmt       VARCHAR2(10000);

  site_sql_stmt      VARCHAR2(4000) := '
        SELECT	cust_RECEIPT_METHOD_ID, NVL(site_use_id, -1)
  	FROM 	ra_cust_receipt_methods rm
   	WHERE 	rm.customer_id 		= :p_customer_id
   	AND 	rm.SITE_USE_ID          = NVL(:p_site_use_id, -1)
        AND     :p_as_of_date BETWEEN rm.start_date AND NVL(rm.end_date, :p_as_of_date ) ';

  cust_sql_stmt      VARCHAR2(4000) := '
	UNION
        SELECT	cust_RECEIPT_METHOD_ID, NVL(site_use_id, -1)
  	FROM 	ra_cust_receipt_methods rm
   	WHERE 	rm.customer_id 		= :p_customer_id
   	AND 	rm.SITE_USE_ID          IS NULL
        AND     :p_as_of_date BETWEEN rm.start_date AND NVL(rm.end_date, :p_as_of_date ) ';

  cc_only_stmt   VARCHAR2(4000) := ' AND EXISTS ( SELECT 1 FROM ar_receipt_methods ba
				   	     WHERE ba.RECEIPT_METHOD_ID = rm.RECEIPT_METHOD_ID
					     AND   ba.payment_type_code  = ''CREDIT_CARD'' ) ';
  primary_stmt   VARCHAR2(4000) := ' AND rm.primary_flag                 = ''Y'' ';
  pay_stmt       VARCHAR2(4000) := ' AND rm.receipt_method_id = :p_pay_method_id ';

  BEGIN
     --
     IF NOT p_check THEN
	IF p_site_use_id IS NOT NULL THEN
	   cust_sql_stmt := cust_sql_stmt || CRLF || ' AND 1 = 2 ';
	END IF;
     END IF;
     --
     sql_stmt := site_sql_stmt;
     --
     IF p_primary THEN
     --
	arp_standard.debug('Primary Only..');
	sql_stmt := sql_stmt || CRLF || primary_stmt;
     --
     END IF;
     --
     IF p_cc_only THEN
	arp_standard.debug('In CC Only..');
	sql_stmt := sql_stmt || CRLF || cc_only_stmt;
	null;
     END IF;
     --
     IF p_pay_method_id IS NOT NULL THEN
	arp_standard.debug('Pay Method Only..');
	sql_stmt := sql_stmt || CRLF || pay_stmt;
	null;
     END IF;
     --
     sql_stmt := sql_stmt || CRLF || cust_sql_stmt;

     IF p_primary THEN
     --
	sql_stmt := sql_stmt || CRLF || primary_stmt;
     --
     END IF;
     --
     IF p_cc_only THEN
	arp_standard.debug('In CC Only..');
	sql_stmt := sql_stmt || CRLF || cc_only_stmt;
	null;
     END IF;
     --
     IF p_pay_method_id IS NOT NULL THEN
	arp_standard.debug('Pay Method Only..');
	sql_stmt := sql_stmt || CRLF || pay_stmt;
	null;
     END IF;
     --
     arp_standard.debug(sql_stmt);

     IF p_pay_method_id IS NOT NULL THEN
        OPEN  pri_pay_method FOR sql_stmt USING p_customer_id, p_site_use_id, l_as_of_date,
					     l_as_of_date, p_pay_method_id,
                                             p_customer_id, l_as_of_date,
					     l_as_of_date, p_pay_method_id;

     ELSE
        OPEN  pri_pay_method FOR sql_stmt USING p_customer_id, p_site_use_id, l_as_of_date, l_as_of_date,
                                           p_customer_id, l_as_of_date, l_as_of_date;
     END IF;

     -- Always pick the first

     FETCH pri_pay_method INTO l_receipt_method_id, l_site_use_id;

     CLOSE pri_pay_method;

     RETURN (l_receipt_method_id);

  EXCEPTION
     WHEN OTHERS THEN
	RAISE;
  END get_cust_pay_method;

/* bug 6121157 Function "process_cust_pay_method()" added to check if the customer already has a payment method associated else it will insert a record in ra_cust_receipt_methods. */

/*===========================================================================+
 | FUNCTION process_cust_pay_method                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Check if the customer already has a payment method associated else it  |
 |    will insert a record in ra_cust_receipt_methods.                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN: p_pay_method_id                                          |
 |                  p_customer_id                                            |
 |                  p_site_use_id                                            |
 |                  p_as_of_date                                             |
 |                                                                           |
 |                                                                           |
 | RETURNS    : Number                                                       |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     15-Jun-2007  Deep Gaurab       Created.                               |
 +===========================================================================*/
  FUNCTION process_cust_pay_method (
			       p_pay_method_id IN NUMBER,
			       p_customer_id IN NUMBER,
			       p_site_use_id IN NUMBER DEFAULT null,
			       p_as_of_date IN DATE DEFAULT TRUNC(SYSDATE) ) RETURN NUMBER IS
  l_cust_pay_method_id NUMBER;
  l_primary_flag       ra_cust_receipt_methods.primary_flag%type;
  --
    FUNCTION check_primary_method_exists (p_customer_id IN NUMBER,
					  p_site_use_id IN NUMBER DEFAULT null,
					  p_as_of_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN BOOLEAN IS
       l_result BOOLEAN := FALSE;
    BEGIN
       IF get_cust_pay_method(p_customer_id=>p_customer_id,
			      p_site_use_id=>p_site_use_id,
			      p_cc_only=>FALSE,
			      p_primary=>TRUE,
			      p_as_of_date=>NVL(p_as_of_date, TRUNC(SYSDATE))) IS NOT NULL THEN
          l_result := TRUE;
       ELSE
	  l_result := FALSE;
       END IF;

       RETURN(l_result);
    EXCEPTION
       WHEN OTHERS THEN
	  RAISE;
    END check_primary_method_exists;
  --
  BEGIN
     l_cust_pay_method_id := get_cust_pay_method(p_customer_id=>p_customer_id,
					      p_site_use_id=>p_site_use_id,
					      p_pay_method_id=>p_pay_method_id,
					      p_cc_only=>FALSE,
					      p_primary=>FALSE,
					      p_as_of_date=>NVL(p_as_of_date, TRUNC(SYSDATE)));
     IF l_cust_pay_method_id IS NULL THEN
     --
	SELECT
	   RA_CUST_RECEIPT_METHODS_S.NEXTVAL
        INTO
	   l_cust_pay_method_id
        FROM
	   dual;
     --

/* Bug 8359208, We need to create non-primary receipt method for customer
   irrespective of whether a primary receipt method exists for customer or not. */

        l_primary_flag := 'N';

     --
	INSERT INTO ra_cust_receipt_methods
	(customer_id,
	 receipt_method_id,
	 primary_flag,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 program_application_id,
	 site_use_id,
	 start_date,
	 cust_receipt_method_id)
	VALUES
	(p_customer_id,    -- Customer Id
	 p_pay_method_id,  -- Receipt Method Id
	 l_primary_flag,   -- Primary Flag
	 SYSDATE,          -- Creation Date
	 pg_user_id,       -- Created By
	 SYSDATE,          -- Last Update Date
	 pg_user_id,       -- Last Updated By
	 pg_prog_appl_id,  -- Program Application Id
	 p_site_use_id,    -- Site use Id
	 TRUNC(p_as_of_date),   -- Start Date
	 l_cust_pay_method_id);

     END IF;

     RETURN(l_cust_pay_method_id);

  EXCEPTION
     WHEN OTHERS THEN
	RAISE;

  END process_cust_pay_method;

  /*---------------------------------------------+
   |   Package initialization section.           |
   |   Sets WHO column variables for later use.  |
   +---------------------------------------------*/
BEGIN

  pg_user_id          := fnd_global.user_id;
  pg_login_id         := fnd_global.login_id;
  pg_prog_appl_id     := fnd_global.prog_appl_id;

  /* J Rautiainen ACH Implementation */
  pg_program_id       := fnd_global.conc_program_id;
  pg_request_id       := fnd_global.conc_request_id;
  pg_sob_id           := arp_global.set_of_books_id;

END ARP_EXT_BANK_PKG;

/
