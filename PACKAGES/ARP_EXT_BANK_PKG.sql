--------------------------------------------------------
--  DDL for Package ARP_EXT_BANK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_EXT_BANK_PKG" AUTHID CURRENT_USER as
/* $Header: AREXTBAS.pls 120.5.12010000.4 2010/04/14 14:20:47 npanchak ship $ */

  TYPE numeric_tab_typ IS TABLE of number INDEX BY BINARY_INTEGER;

  PROCEDURE strip_white_spaces(
        p_credit_card_num       IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
        p_stripped_cc_num       OUT NOCOPY iby_ext_bank_accounts_v.bank_account_number%TYPE
  );

  PROCEDURE insert_ext_bank_branch(
    p_bank_name        IN  ce_bank_branches_v.bank_name%TYPE,
    p_branch_name      IN  ce_bank_branches_v.bank_branch_name%TYPE,
    p_bank_number      IN  ce_bank_branches_v.bank_number%TYPE,
    p_branch_number    IN  ce_bank_branches_v.branch_number%TYPE,
    p_end_date         IN  ce_bank_branches_v.end_date%TYPE DEFAULT NULL,
    p_description      IN  ce_bank_branches_v.description%TYPE DEFAULT NULL,
    x_bank_party_id    OUT NOCOPY ce_bank_branches_v.bank_party_id%TYPE,
    x_branch_party_id  OUT NOCOPY ce_bank_branches_v.branch_party_id%TYPE,
    x_return_status    OUT NOCOPY VARCHAR2);            -- bug5594142

  procedure insert_bank_account(
    p_bank_account_name IN  iby_ext_bank_accounts_v.bank_account_name%type,
    p_bank_account_num  IN  iby_ext_bank_accounts_v.bank_account_number%type,
    p_bank_party_id     IN  iby_ext_bank_accounts_v.bank_party_id%type,
    p_branch_party_id   IN  iby_ext_bank_accounts_v.branch_party_id%type,
    p_customer_id       IN  iby_ext_bank_accounts_v.primary_acct_owner_party_id%type,
    p_description       IN  iby_ext_bank_accounts_v.description%type,
    p_currency_code     IN  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_account_id   OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%type,
    x_return_status     OUT NOCOPY VARCHAR2                  );         -- bug5594142

  procedure check_bank_account(
    p_routing_number  IN  ce_bank_branches_v.branch_number%TYPE,
    p_account_number  IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
    p_bank_party_id   IN  iby_ext_bank_accounts_v.bank_party_id%type,
    p_branch_party_id IN  iby_ext_bank_accounts_v.branch_party_id%type,
    p_currency_code   IN  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_account_id OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%TYPE,
    x_start_date      OUT NOCOPY iby_ext_bank_accounts_v.start_date%TYPE,
    x_end_date        OUT NOCOPY iby_ext_bank_accounts_v.end_date%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2                    );         -- bug5594142

  PROCEDURE create_bank_branch_acc(
    p_routing_number  IN  OUT NOCOPY ce_bank_branches_v.branch_number%TYPE,
    p_account_number  IN  iby_ext_bank_accounts_v.bank_account_number%TYPE,
    p_description     IN  iby_ext_bank_accounts_v.description%type,
    p_customer_id     IN  iby_ext_bank_accounts_v.primary_acct_owner_party_id%type,
    p_currency_code      IN  iby_ext_bank_accounts_v.currency_code%type DEFAULT NULL,
    x_bank_party_id   OUT NOCOPY ce_bank_branches_v.bank_party_id%TYPE,
    x_branch_party_id OUT NOCOPY ce_bank_branches_v.branch_party_id%TYPE,
    x_bank_account_id OUT NOCOPY iby_ext_bank_accounts_v.bank_account_id%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2);                            -- bug5594142

  PROCEDURE insert_acct_instr_assignment(
    p_party_id        IN  NUMBER,
    p_customer_id     IN  NUMBER,
    p_instr_id        IN  NUMBER,
    x_instr_assign_id   OUT NOCOPY iby_fndcpt_payer_assgn_instr_v.INSTR_ASSIGNMENT_ID%TYPE,
    x_return_status   OUT NOCOPY VARCHAR2);                            -- Bug 7346354

 /* bug 6121157 */

  FUNCTION get_cust_pay_method(p_customer_id IN NUMBER,
                  p_site_use_id IN NUMBER DEFAULT null,
                  p_pay_method_id IN NUMBER DEFAULT null,
                  p_cc_only IN BOOLEAN DEFAULT TRUE,
                  p_primary IN BOOLEAN DEFAULT TRUE,
                  p_check IN BOOLEAN DEFAULT FALSE,
                  p_as_of_date IN DATE DEFAULT TRUNC(SYSDATE)) RETURN NUMBER;

 /* bug 6121157 */

  FUNCTION process_cust_pay_method (
               p_pay_method_id IN NUMBER,
               p_customer_id IN NUMBER,
               p_site_use_id IN NUMBER DEFAULT null,
               p_as_of_date IN DATE DEFAULT TRUNC(SYSDATE) ) RETURN NUMBER;


END ARP_EXT_BANK_PKG;

/
