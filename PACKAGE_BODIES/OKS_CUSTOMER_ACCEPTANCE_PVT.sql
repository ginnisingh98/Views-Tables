--------------------------------------------------------
--  DDL for Package Body OKS_CUSTOMER_ACCEPTANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CUSTOMER_ACCEPTANCE_PVT" AS
/* $Header: OKSVCUSB.pls 120.27.12010000.4 2009/11/17 16:03:49 cgopinee ship $ */
 ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  g_pkg_name                     CONSTANT VARCHAR2 (200)
                                             := 'OKS_CUSTOMER_ACCEPTANCE_PVT';
  g_app_name                     CONSTANT VARCHAR2 (3) := 'OKS';
  g_level_procedure              CONSTANT NUMBER := fnd_log.level_procedure;
  g_module                       CONSTANT VARCHAR2 (250)
                                         := 'oks.plsql.' ||
                                            g_pkg_name ||
                                            '.';
  g_application_id               CONSTANT NUMBER := 515;    -- OKS Application
  g_false                        CONSTANT VARCHAR2 (1) := fnd_api.g_false;
  g_true                         CONSTANT VARCHAR2 (1) := fnd_api.g_true;
  g_ret_sts_success              CONSTANT VARCHAR2 (1)
                                                  := fnd_api.g_ret_sts_success;
  g_ret_sts_error                CONSTANT VARCHAR2 (1)
                                                    := fnd_api.g_ret_sts_error;
  g_ret_sts_unexp_error          CONSTANT VARCHAR2 (1)
                                              := fnd_api.g_ret_sts_unexp_error;
  g_unexpected_error             CONSTANT VARCHAR2 (200)
                                                     := 'OKS_UNEXPECTED_ERROR';
  g_sqlerrm_token                CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
  g_sqlcode_token                CONSTANT VARCHAR2 (200) := 'ERROR_CODE';

  FUNCTION get_contract_amount (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                     := 'get_contract_amount';
    l_k_amount                              VARCHAR2 (1000) := '';

    CURSOR csr_k_amt IS
      SELECT TO_CHAR
               (oks_extwar_util_pvt.round_currency_amt
                                       ((NVL (ch.estimated_amount, 0) +
                                         NVL (sh.tax_amount, 0)
                                        ),
                                        ch.currency_code),
                fnd_currency.get_format_mask (ch.currency_code, 50)) ||
             ' ' ||
             ch.currency_code AS amount
        FROM okc_k_headers_all_b ch,
             oks_k_headers_b sh
       WHERE ch.ID = sh.chr_id
         AND ch.ID = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_amt;

    FETCH csr_k_amt
     INTO l_k_amount;

    CLOSE csr_k_amt;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_k_amount;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_k_amount;
  END get_contract_amount;

  FUNCTION get_contract_subtotal (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                   := 'get_contract_subtotal';
    l_k_subtotal                            VARCHAR2 (1000) := '';

    CURSOR csr_k_subtotal IS
      SELECT TO_CHAR
               (oks_extwar_util_pvt.round_currency_amt
                                                (NVL (ch.estimated_amount,
                                                      0),
                                                 ch.currency_code),
                fnd_currency.get_format_mask (ch.currency_code, 50)) ||
             ' ' ||
             ch.currency_code AS amount
        FROM okc_k_headers_all_b ch
       WHERE ch.ID = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_subtotal;

    FETCH csr_k_subtotal
     INTO l_k_subtotal;

    CLOSE csr_k_subtotal;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_k_subtotal;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_k_subtotal;
  END get_contract_subtotal;

  FUNCTION get_contract_tax (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                     := 'get_contract_amount';
    l_k_tax                                 VARCHAR2 (1000) := '';

    CURSOR csr_k_tax IS
     SELECT TO_CHAR
               (oks_extwar_util_pvt.round_currency_amt
                                         (NVL (sh.tax_amount, 0), ch.currency_code),
                fnd_currency.get_format_mask (ch.currency_code, 50)) ||
             ' ' ||
             ch.currency_code AS amount
        FROM okc_k_headers_all_b ch,
             oks_k_headers_b sh
       WHERE ch.ID = sh.chr_id
         AND ch.ID = p_chr_id;

  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_tax;

    FETCH csr_k_tax
     INTO l_k_tax;

    CLOSE csr_k_tax;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_k_tax;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_k_tax;
  END get_contract_tax;

  FUNCTION get_contract_accept_clause (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                              := 'get_contract_accept_clause';
    l_contract_accept_clause                VARCHAR2 (4000) := '';
    l_customer_name                         VARCHAR2 (1000) := '';
    l_vendor_name                           VARCHAR2 (1000) := '';
    l_customer_token_exists                 VARCHAR2 (1) := '';
    l_vendor_token_exists                   VARCHAR2 (1) := '';

    CURSOR csr_customer_name IS
      SELECT p.party_name AS customer_name
        FROM okc_k_party_roles_b r,
             hz_parties p
       WHERE p.party_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_PARTY'
         AND r.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
         -- gets only the CUSTOMER /SUBSCRIBER
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;

    CURSOR csr_vendor_name IS
      SELECT o.NAME AS vendor_name
        FROM okc_k_party_roles_b r,
             hr_all_organization_units o
       WHERE o.organization_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_OPERUNIT'
         AND r.rle_code IN
                     ('VENDOR', 'MERCHANT') -- gets only the VENDOR / MERCHANT
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;

    CURSOR csr_customer_token_exists IS
      SELECT 'Y'
        FROM fnd_new_messages
       WHERE message_name = 'OKS_CUST_ACCEPT_CLAUSE'
         AND language_code = USERENV ('LANG')
         AND regexp_like (MESSAGE_TEXT,
                          'CUSTOMER_NAME',
                          'c'
                         );

    CURSOR csr_vendor_token_exists IS
      SELECT 'Y'
        FROM fnd_new_messages
       WHERE message_name = 'OKS_CUST_ACCEPT_CLAUSE'
         AND language_code = USERENV ('LANG')
         AND regexp_like (MESSAGE_TEXT,
                          'VENDOR_NAME',
                          'c'
                         );
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- check if Customer Name token exists
    OPEN csr_customer_token_exists;

    FETCH csr_customer_token_exists
     INTO l_customer_token_exists;

    IF csr_customer_token_exists%FOUND THEN
      -- Customer Name token exists, get the name
      OPEN csr_customer_name;

      FETCH csr_customer_name
       INTO l_customer_name;

      CLOSE csr_customer_name;
    ELSE
      -- Customer Name token does not exists
      l_customer_token_exists    := 'N';
    END IF;

    CLOSE csr_customer_token_exists;

    -- check if Vendor Name token exists
    OPEN csr_vendor_token_exists;

    FETCH csr_vendor_token_exists
     INTO l_vendor_token_exists;

    IF csr_vendor_token_exists%FOUND THEN
      -- Vendor Name token exists, get the name
      OPEN csr_vendor_name;

      FETCH csr_vendor_name
       INTO l_vendor_name;

      CLOSE csr_vendor_name;
    ELSE
      -- Vendor Name token does not exists
      l_vendor_token_exists      := 'N';
    END IF;

    CLOSE csr_vendor_token_exists;

    -- set the fnd message for acceptance clause
    fnd_message.set_name ('OKS', 'OKS_CUST_ACCEPT_CLAUSE');

    IF l_customer_token_exists = 'Y' THEN
      fnd_message.set_token ('CUSTOMER_NAME', l_customer_name);
    END IF;

    IF l_vendor_token_exists = 'Y' THEN
      fnd_message.set_token ('VENDOR_NAME', l_vendor_name);
    END IF;

    l_contract_accept_clause   := fnd_message.get;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_contract_accept_clause;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_contract_accept_clause;
  END get_contract_accept_clause;

  FUNCTION get_contract_decline_clause (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                             := 'get_contract_decline_clause';
    l_contract_decline_clause               VARCHAR2 (4000) := '';
    l_customer_name                         VARCHAR2 (1000) := '';
    l_vendor_name                           VARCHAR2 (1000) := '';
    l_customer_token_exists                 VARCHAR2 (1) := '';
    l_vendor_token_exists                   VARCHAR2 (1) := '';

    CURSOR csr_customer_name IS
      SELECT p.party_name AS customer_name
        FROM okc_k_party_roles_b r,
             hz_parties p
       WHERE p.party_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_PARTY'
         AND r.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
         -- gets only the CUSTOMER /SUBSCRIBER
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;

    CURSOR csr_vendor_name IS
      SELECT o.NAME AS vendor_name
        FROM okc_k_party_roles_b r,
             hr_all_organization_units o
       WHERE o.organization_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_OPERUNIT'
         AND r.rle_code IN
                     ('VENDOR', 'MERCHANT') -- gets only the VENDOR / MERCHANT
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;

    CURSOR csr_customer_token_exists IS
      SELECT 'Y'
        FROM fnd_new_messages
       WHERE message_name = 'OKS_CUST_DECLINE_CLAUSE'
         AND language_code = USERENV ('LANG')
         AND regexp_like (MESSAGE_TEXT,
                          'CUSTOMER_NAME',
                          'c'
                         );

    CURSOR csr_vendor_token_exists IS
      SELECT 'Y'
        FROM fnd_new_messages
       WHERE message_name = 'OKS_CUST_DECLINE_CLAUSE'
         AND language_code = USERENV ('LANG')
         AND regexp_like (MESSAGE_TEXT,
                          'VENDOR_NAME',
                          'c'
                         );
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- check if Customer Name token exists
    OPEN csr_customer_token_exists;

    FETCH csr_customer_token_exists
     INTO l_customer_token_exists;

    IF csr_customer_token_exists%FOUND THEN
      -- Customer Name token exists, get the name
      OPEN csr_customer_name;

      FETCH csr_customer_name
       INTO l_customer_name;

      CLOSE csr_customer_name;
    ELSE
      -- Customer Name token does not exists
      l_customer_token_exists    := 'N';
    END IF;

    CLOSE csr_customer_token_exists;

    -- check if Vendor Name token exists
    OPEN csr_vendor_token_exists;

    FETCH csr_vendor_token_exists
     INTO l_vendor_token_exists;

    IF csr_vendor_token_exists%FOUND THEN
      -- Vendor Name token exists, get the name
      OPEN csr_vendor_name;

      FETCH csr_vendor_name
       INTO l_vendor_name;

      CLOSE csr_vendor_name;
    ELSE
      -- Vendor Name token does not exists
      l_vendor_token_exists      := 'N';
    END IF;

    CLOSE csr_vendor_token_exists;

    -- set the fnd message for decline clause
    fnd_message.set_name ('OKS', 'OKS_CUST_DECLINE_CLAUSE');

    IF l_customer_token_exists = 'Y' THEN
      fnd_message.set_token ('CUSTOMER_NAME', l_customer_name);
    END IF;

    IF l_vendor_token_exists = 'Y' THEN
      fnd_message.set_token ('VENDOR_NAME', l_vendor_name);
    END IF;

    l_contract_decline_clause  := fnd_message.get;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_contract_decline_clause;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_contract_decline_clause;
  END get_contract_decline_clause;

  FUNCTION get_contract_vendor (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                     := 'get_contract_vendor';
    l_vendor_name                           VARCHAR2 (1000) := '';

    CURSOR csr_vendor_name IS
      SELECT o.NAME AS vendor_name
        FROM okc_k_party_roles_b r,
             hr_all_organization_units o
       WHERE o.organization_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_OPERUNIT'
         AND r.rle_code = 'VENDOR'                     -- gets only the VENDOR
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_vendor_name;

    FETCH csr_vendor_name
     INTO l_vendor_name;

    CLOSE csr_vendor_name;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_vendor_name;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_vendor_name;
  END get_contract_vendor;

  FUNCTION get_contract_customer (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                   := 'get_contract_customer';
    l_customer_name                         VARCHAR2 (1000) := '';

    CURSOR csr_customer_name IS
      SELECT p.party_name AS customer_name
        FROM okc_k_party_roles_b r,
             hz_parties p
       WHERE p.party_id = r.object1_id1
         AND r.jtot_object1_code = 'OKX_PARTY'
         AND r.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
         -- gets only the CUSTOMER /SUBSCRIBER
         AND r.cle_id IS NULL
         AND r.dnz_chr_id = p_chr_id; /*  changed chr_id to dnz_chr_id for
bug6439795 */
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_customer_name;

    FETCH csr_customer_name
     INTO l_customer_name;

    CLOSE csr_customer_name;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_customer_name;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_customer_name;
  END get_contract_customer;

---------------------------------------------------
  FUNCTION get_contract_party (
    p_chr_id                         IN       NUMBER
  )
    RETURN NUMBER AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                      := 'get_contract_party';
    l_party_id                              NUMBER := '';

    CURSOR csr_k_party IS
      SELECT object1_id1
        FROM okc_k_party_roles_b
       WHERE dnz_chr_id = p_chr_id
         AND cle_id IS NULL
         AND jtot_object1_code = 'OKX_PARTY'
         AND rle_code = 'CUSTOMER';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_party;

    FETCH csr_k_party
     INTO l_party_id;

    CLOSE csr_k_party;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_party_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_party_id;
  END get_contract_party;

---------------------------------------------------
  FUNCTION get_contract_organization (
    p_chr_id                         IN       NUMBER
  )
    RETURN NUMBER AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'get_contract_organization';
    l_organization_id                       NUMBER := '';

    CURSOR csr_k_organization IS
      SELECT authoring_org_id
        FROM okc_k_headers_all_b
       WHERE ID = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_organization;

    FETCH csr_k_organization
     INTO l_organization_id;

    CLOSE csr_k_organization;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_organization_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_organization_id;
  END get_contract_organization;

---------------------------------------------------
-- bug 4918198
-- The below function would return the Name of salesrep
-- instead of the salesrep email

  FUNCTION get_contract_salesrep_email (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                             := 'get_contract_salesrep_email';
    l_salesrep_email                        VARCHAR2 (1000) := '';

    CURSOR csr_k_salesrep IS
      SELECT res.resource_name AS salesrep_name
        FROM okc_k_headers_all_b khr,
             okc_contacts ct,
             jtf_rs_salesreps srp,
             jtf_rs_resource_extns_vl res
       WHERE khr.ID = ct.dnz_chr_id
         AND ct.object1_id1 = srp.salesrep_id
         AND srp.resource_id = res.resource_id
         AND srp.org_id = khr.authoring_org_id
         AND ct.jtot_object1_code='OKX_SALEPERS' --bug 6243682
         AND res.CATEGORY IN
                ('EMPLOYEE', 'OTHER', 'PARTY', 'PARTNER', 'SUPPLIER_CONTACT')
         -- AND srp.email_address IS NOT NULL  -- bug 4918198
         AND res.user_name IS NOT NULL          -- Salesrep MUST be a FND USER
         AND khr.ID = p_chr_id;

-- bug 5218842
CURSOR csr_party_helpdesk (
      p_k_party_id                     IN       NUMBER
    ) IS
SELECT per.full_name help_desk_name
  FROM jtf_rs_resource_extns jtfrse,
       oks_k_defaults gcd,
       per_all_people_f per
 WHERE jtfrse.user_id = gcd.user_id
   AND per.person_id = jtfrse.source_id
   AND per.effective_start_date = (SELECT MAX (a.effective_start_date)
                                     FROM per_all_people_f a
                                    WHERE a.person_id = per.person_id)
   AND gcd.cdt_type = 'SDT'
   AND gcd.jtot_object_code = 'OKX_PARTY'
   AND jtfrse.category = 'EMPLOYEE'
   AND gcd.segment_id1 = p_k_party_id;
/*
      SELECT hd.help_desk_name
        FROM oks_k_defaults gcd,
             oks_help_desk_v hd
       WHERE gcd.cdt_type = 'SDT'
         AND gcd.jtot_object_code = 'OKX_PARTY'
         AND gcd.user_id  = hd.user_id
         -- AND gcd.email_address IS NOT NULL
         AND gcd.segment_id1 = p_k_party_id;
*/

-- bug 5218842
CURSOR csr_org_helpdesk (
      p_k_org_id                       IN       NUMBER
    ) IS
SELECT per.full_name help_desk_name
  FROM jtf_rs_resource_extns jtfrse,
       oks_k_defaults gcd,
       per_all_people_f per
 WHERE jtfrse.user_id = gcd.user_id
   AND per.person_id = jtfrse.source_id
   AND per.effective_start_date = (SELECT MAX (a.effective_start_date)
                                     FROM per_all_people_f a
                                    WHERE a.person_id = per.person_id)
   AND gcd.cdt_type = 'SDT'
   AND gcd.jtot_object_code = 'OKX_OPERUNIT'
   AND jtfrse.category = 'EMPLOYEE'
   AND gcd.segment_id1 = p_k_org_id;
/*
      SELECT hd.help_desk_name
        FROM oks_k_defaults gcd,
             oks_help_desk_v hd
       WHERE gcd.cdt_type = 'SDT'
         AND gcd.jtot_object_code = 'OKX_OPERUNIT'
         AND gcd.user_id  = hd.user_id
         -- AND gcd.email_address IS NOT NULL
         AND gcd.segment_id1 = p_k_org_id;
*/

-- bug 5218842
CURSOR csr_global_helpdesk IS
SELECT per.full_name help_desk_name
  FROM jtf_rs_resource_extns jtfrse,
       oks_k_defaults gcd,
       per_all_people_f per
 WHERE jtfrse.user_id = gcd.user_id
   AND per.person_id = jtfrse.source_id
   AND per.effective_start_date = (SELECT MAX (a.effective_start_date)
                                     FROM per_all_people_f a
                                    WHERE a.person_id = per.person_id)
   AND gcd.cdt_type = 'MDT'
   AND jtfrse.category = 'EMPLOYEE';
/*
      SELECT hd.help_desk_name
        FROM oks_k_defaults gcd,
             oks_help_desk_v hd
       WHERE gcd.user_id  = hd.user_id
	     AND gcd.cdt_type = 'MDT';
*/
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_salesrep;

    FETCH csr_k_salesrep
     INTO l_salesrep_email;

    IF csr_k_salesrep%FOUND THEN
      -- Salesrep exist on K
      CLOSE csr_k_salesrep;

      RETURN l_salesrep_email;
    END IF;                                                  -- k_salesrep csr

    CLOSE csr_k_salesrep;

    -- Go to GCD at party level
    OPEN csr_party_helpdesk (p_k_party_id                      => get_contract_party
                                                                     (p_chr_id));

    FETCH csr_party_helpdesk
     INTO l_salesrep_email;

    IF csr_party_helpdesk%FOUND THEN
      CLOSE csr_party_helpdesk;

      RETURN l_salesrep_email;
    END IF;                                         -- helpdesk on party level

    CLOSE csr_party_helpdesk;

    -- Go to GCD at organization level
    OPEN csr_org_helpdesk (p_k_org_id                        => get_contract_organization
                                                                     (p_chr_id));

    FETCH csr_org_helpdesk
     INTO l_salesrep_email;

    IF csr_org_helpdesk%FOUND THEN
      CLOSE csr_org_helpdesk;

      RETURN l_salesrep_email;
    END IF;                                         -- helpdesk on party level

    CLOSE csr_org_helpdesk;

    -- Go to GCD at global level
    OPEN csr_global_helpdesk;

    FETCH csr_global_helpdesk
     INTO l_salesrep_email;

    CLOSE csr_global_helpdesk;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_salesrep_email;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_salesrep_email;
  END get_contract_salesrep_email;

---------------------------------------------------
  FUNCTION get_contract_cust_account_id (
    p_chr_id                         IN       NUMBER
  )
    RETURN NUMBER AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                            := 'get_contract_cust_account_id';
    l_cust_account_id                       NUMBER := '';

    CURSOR csr_cust_account_dtls IS
      SELECT p.party_name AS customer_name,
             r.object1_id1 AS party_id,
             ca.cust_account_id AS customer_account_id
        FROM okc_k_party_roles_b r,
             hz_parties p,
             hz_cust_accounts ca
       WHERE p.party_id = r.object1_id1
         AND ca.party_id = p.party_id
         AND r.jtot_object1_code = 'OKX_PARTY'
         AND r.rle_code IN ('CUSTOMER', 'SUBSCRIBER')
         -- gets only the CUSTOMER /SUBSCRIBER
         AND r.cle_id IS NULL
         AND r.chr_id = p_chr_id;

    l_csr_cust_account_id_rec               csr_cust_account_dtls%ROWTYPE;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- set context to multi org
    -- mo_global.init ('OKC');

    OPEN csr_cust_account_dtls;

    FETCH csr_cust_account_dtls
     INTO l_csr_cust_account_id_rec;

    CLOSE csr_cust_account_dtls;

    l_cust_account_id          :=
                                 l_csr_cust_account_id_rec.customer_account_id;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_cust_account_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_cust_account_id;
  END get_contract_cust_account_id;

---------------------------------------------------
  FUNCTION get_req_ass_email_subject (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'get_req_ass_email_subject';
    l_email_subject                         VARCHAR2 (4000) := '';
    l_contract_number                       VARCHAR2 (1000) := '';

    CURSOR csr_k_number IS
      SELECT kc.contract_number ||
             DECODE (kc.contract_number_modifier,
                     NULL, NULL,
                     '-'
                    ) ||
             kc.contract_number_modifier AS contract_number
        FROM okc_k_headers_all_b kc
       WHERE kc.ID = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    OPEN csr_k_number;

    FETCH csr_k_number
     INTO l_contract_number;

    CLOSE csr_k_number;

    -- build the email subject message
    -- set the fnd message for email subject
    fnd_message.set_name ('OKS', 'OKS_CUST_ACCEPT_EMAIL_SUB');
    fnd_message.set_token ('CONTRACT_NUM', l_contract_number);
    l_email_subject            := fnd_message.get;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_email_subject;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_email_subject;
  END get_req_ass_email_subject;

---------------------------------------------------
  FUNCTION duration_unit_and_period (
    p_start_date                     IN       DATE,
    p_end_date                       IN       DATE
  )
    RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                := 'duration_unit_and_period';
    l_duration                              NUMBER;
    l_timeunit                              VARCHAR2 (100) := '';
    l_timeunit_desc                         VARCHAR2 (1000) := '';
    l_duration_period                       VARCHAR2 (4000) := '';
    l_return_status                         VARCHAR2 (1);

    CURSOR csr_timeunit_desc (
      p_code                           IN       VARCHAR2
    ) IS
      SELECT short_description
        FROM okc_time_code_units_v
       WHERE uom_code = p_code
         AND active_flag = 'Y';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters : p_start_date : ' ||
                      p_start_date
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_end_date : ' ||
                      p_end_date
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Calling OKC_TIME_UTIL_PUB.get_duration'
                     );
    END IF;

    okc_time_util_pub.get_duration (p_start_date                      => p_start_date,
                                    p_end_date                        => p_end_date,
                                    x_duration                        => l_duration,
                                    x_timeunit                        => l_timeunit,
                                    x_return_status                   => l_return_status
                                   );

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '150: After Calling OKC_TIME_UTIL_PUB.get_duration'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '150: x_return_status : ' ||
                      l_return_status
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '150: x_duration  : ' ||
                      l_duration
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '150: x_timeunit : ' ||
                      l_timeunit
                     );
    END IF;

    OPEN csr_timeunit_desc (p_code                            => l_timeunit);

    FETCH csr_timeunit_desc
     INTO l_timeunit_desc;

    CLOSE csr_timeunit_desc;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '200: l_timeunit_desc : ' ||
                      l_timeunit_desc
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    l_duration_period          := l_duration ||
                                  ' ' ||
                                  l_timeunit_desc;
    RETURN l_duration_period;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_duration_period;
  END duration_unit_and_period;

---------------------------------------------------
  FUNCTION get_credit_card_dtls (
    p_trxn_extension_id              IN       NUMBER
  )
    RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                    := 'get_credit_card_dtls';
    l_cc_detail                             VARCHAR2 (2000) := '';

    CURSOR csr_cc_dtls IS
      SELECT ibyt.card_number ||
             ' , ' ||
             ibyt.card_issuer_name
             /*modified by cgopinee for PA-DSS one off strategy*/
             ||' , ' ||
             decode(encrypted,'A','',TO_CHAR(TO_DATE(ibyt.card_expirydate), 'MM/YYYY')) AS cc_number
        FROM iby_trxn_extensions_v ibyt
       WHERE ibyt.trxn_extension_id = p_trxn_extension_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters : p_trxn_extension_id : ' ||
                      p_trxn_extension_id
                     );
    END IF;

    OPEN csr_cc_dtls;

    FETCH csr_cc_dtls
     INTO l_cc_detail;

    CLOSE csr_cc_dtls;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '200: l_cc_detail : ' ||
                      l_cc_detail
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_cc_detail;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_cc_detail;
  END get_credit_card_dtls;

---------------------------------------------------
  FUNCTION get_credit_card_cvv2 (
    p_trxn_extension_id              IN       NUMBER
  )
    RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                    := 'get_credit_card_cvv2';
    l_cc_cvv2                               VARCHAR2 (2000) := '';

    CURSOR csr_cc_dtls IS
      SELECT ibyt.instrument_security_code AS cc_cvv2
        FROM iby_trxn_extensions_v ibyt
       WHERE ibyt.trxn_extension_id = p_trxn_extension_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters : p_trxn_extension_id : ' ||
                      p_trxn_extension_id
                     );
    END IF;

    OPEN csr_cc_dtls;

    FETCH csr_cc_dtls
     INTO l_cc_cvv2;

    CLOSE csr_cc_dtls;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '200: l_cc_cvv2 : ' ||
                      l_cc_cvv2
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_cc_cvv2;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_cc_cvv2;
  END get_credit_card_cvv2;

---------------------------------------------------
  FUNCTION get_contract_currency_tip (
    p_chr_id                         IN       NUMBER
  )
    RETURN VARCHAR2 IS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                               := 'get_contract_currency_tip';
    l_currency_code_tip                     VARCHAR2 (2000) := '';

    CURSOR csr_currency_tip IS
      SELECT k.currency_code ||
             ' = ' ||
             f.NAME
        FROM okc_k_headers_all_b k,
             fnd_currencies_tl f
       WHERE k.currency_code = f.currency_code
         AND f.LANGUAGE = USERENV ('LANG')
         AND k.ID = p_chr_id;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters : p_chr_id : ' ||
                      p_chr_id
                     );
    END IF;

    OPEN csr_currency_tip;

    FETCH csr_currency_tip
     INTO l_currency_code_tip;

    CLOSE csr_currency_tip;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '200: l_currency_code_tip : ' ||
                      l_currency_code_tip
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    RETURN l_currency_code_tip;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      RETURN l_currency_code_tip;
  END get_contract_currency_tip;

---------------------------------------------------
  PROCEDURE decline_contract (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_chr_id                         IN       NUMBER,
    p_reason_code                    IN       VARCHAR2,
    p_decline_reason                 IN       VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                        := 'decline_contract';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;
    -- set context to multi org
    -- mo_global.init ('OKC');
    oks_wf_k_process_pvt.customer_decline_quote
                                          (p_api_version                     => p_api_version,
                                           p_init_msg_list                   => p_init_msg_list,
                                           p_commit                          => g_true,
                                           p_contract_id                     => p_chr_id,
                                           p_item_key                        => NULL,
                                           p_reason_code                     => p_reason_code,
                                           p_comments                        => p_decline_reason,
                                           x_return_status                   => x_return_status,
                                           x_msg_data                        => x_msg_data,
                                           x_msg_count                       => x_msg_count
                                          );

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                               p_count                           => x_msg_count,
                               p_data                            => x_msg_data
                              );

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END decline_contract;

---------------------------------------------------
  PROCEDURE accept_contract (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_chr_id                         IN       NUMBER,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                         := 'accept_contract';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;
    -- set context to multi org
    -- mo_global.init ('OKC');
    oks_wf_k_process_pvt.customer_accept_quote
                                          (p_api_version                     => p_api_version,
                                           p_init_msg_list                   => p_init_msg_list,
                                           p_contract_id                     => p_chr_id,
                                           p_item_key                        => NULL,
                                           x_return_status                   => x_return_status,
                                           x_msg_data                        => x_msg_data,
                                           x_msg_count                       => x_msg_count
                                          );

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                               p_count                           => x_msg_count,
                               p_data                            => x_msg_data
                              );

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END accept_contract;

---------------------------------------------------
  PROCEDURE update_payment_details (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_chr_id                         IN       NUMBER,
    p_payment_type                   IN       VARCHAR2,
    p_payment_details                IN       VARCHAR2,
    p_party_id                       IN       NUMBER,
    p_cust_account_id                IN       NUMBER,
    p_card_number                    IN       VARCHAR2 DEFAULT NULL,
    p_expiration_month               IN       VARCHAR2 DEFAULT NULL,
    p_expiration_year                IN       VARCHAR2 DEFAULT NULL,
    p_cvv_code                       IN       VARCHAR2 DEFAULT NULL,
    p_instr_assignment_id            IN       NUMBER DEFAULT NULL,
    p_old_txn_entension_id           IN       NUMBER DEFAULT NULL,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                  := 'update_payment_details';
    l_rnrl_rec                              oks_renew_util_pvt.rnrl_rec_type;
    x_rnrl_rec                              oks_renew_util_pvt.rnrl_rec_type;

    CURSOR csr_billing_address_id IS
      SELECT st.party_site_id
        FROM okc_k_headers_all_b okc,
             hz_cust_site_uses_all su,
             hz_cust_acct_sites_all sa,
             hz_party_sites st
       WHERE okc.bill_to_site_use_id = su.site_use_id
         AND su.cust_acct_site_id = sa.cust_acct_site_id
         AND sa.party_site_id = st.party_site_id
         AND okc.ID = p_chr_id;

    CURSOR csr_expiration_date (
      p_month                          IN       VARCHAR2,
      p_year                           IN       VARCHAR2
    ) IS
      SELECT LAST_DAY (TO_DATE (p_month ||
                                '/' ||
                                p_year, 'MM/YYYY'))
        FROM DUAL;

    l_trxn_extension_id                     oks_k_headers_b.trxn_extension_id%TYPE;
    l_billing_address_id                    hz_party_sites.party_site_id%TYPE;
    l_expiration_date                       DATE := '';

    SUBTYPE l_payer_type IS iby_fndcpt_common_pub.payercontext_rec_type;

    l_payer                                 l_payer_type;
    l_response                              iby_fndcpt_common_pub.result_rec_type;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters p_chr_id : ' ||
                      p_chr_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_payment_type : ' ||
                      p_payment_type
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_payment_details : ' ||
                      p_payment_details
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_party_id : ' ||
                      p_party_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_cust_account_id : ' ||
                      p_cust_account_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_expiration_month : ' ||
                      p_expiration_month
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_expiration_year : ' ||
                      p_expiration_year
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_cvv_code : ' ||
                      p_cvv_code
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_instr_assignment_id : ' ||
                      p_instr_assignment_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_old_txn_entension_id : ' ||
                      p_old_txn_entension_id
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;

    -- if p_payment_type is USEDCC then don't update credit card information
    IF (p_payment_type = 'USEDCC') THEN
      RETURN;
    END IF;

    -- delete any existing old txn extension id record
    delete_transaction_extension (p_chr_id                          => p_chr_id,
                                  p_commit                          => fnd_api.g_false,
                                  x_return_status                   => x_return_status,
                                  x_msg_data                        => x_msg_data,
                                  x_msg_count                       => x_msg_count
                                 );

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Get the payment_terms_id1 from GCD
         -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '210: Calling OKS_RENEW_UTIL_PVT.get_renew_rules'
                     );
    END IF;

    -- Call OKS_RENEW_UTIL_PVT.get_renew_rules
    oks_renew_util_pvt.get_renew_rules (x_return_status                   => x_return_status,
                                        p_api_version                     => 1.0,
                                        p_init_msg_list                   => g_false,
                                        p_chr_id                          => p_chr_id,
                                        p_party_id                        => NULL,
                                        p_org_id                          => NULL,
                                        p_date                            => SYSDATE,
                                        p_rnrl_rec                        => l_rnrl_rec,
                                        x_rnrl_rec                        => x_rnrl_rec,
                                        x_msg_count                       => x_msg_count,
                                        x_msg_data                        => x_msg_data
                                       );

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250: After Calling OKS_RENEW_UTIL_PVT.get_renew_rules'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250: x_return_status : ' ||
                      x_return_status
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.payment_terms_id1  : ' ||
                      x_rnrl_rec.payment_terms_id1
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.payment_terms_id2  : ' ||
                      x_rnrl_rec.payment_terms_id2
                     );
    END IF;

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Update contract table attributes
    IF p_payment_type = 'CCR' THEN
      -- Validate all CCR information is entered from UI
      IF (p_instr_assignment_id IS NULL) THEN
        -- this is a new credit card, check if all info is entered from UI
        IF    (p_card_number IS NULL)
           OR (p_expiration_month IS NULL)
           OR (p_expiration_year IS NULL) THEN
          fnd_message.set_name (g_app_name, 'OKS_CC_INVALID_DATA');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;                                             -- cc info invalid
      END IF;                                 -- p_instr_assignment_id is null

      -- get billing_address_id
      OPEN csr_billing_address_id;

      FETCH csr_billing_address_id
       INTO l_billing_address_id;

      CLOSE csr_billing_address_id;

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_billing_address_id : ' ||
                        l_billing_address_id
                       );
      END IF;

      -- get the card expiration date
      IF     (p_expiration_month IS NOT NULL)
         AND (p_expiration_year IS NOT NULL) THEN
        /*
        OPEN csr_expiration_date (p_month                           => p_expiration_month,
                                  p_year                            => p_expiration_year);
        FETCH csr_expiration_date
         INTO l_expiration_date;
        CLOSE csr_expiration_date;
        */
        l_expiration_date := LAST_DAY (TO_DATE (p_expiration_month ||'/' ||p_expiration_year, 'MM/YYYY'));
      END IF;

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_expiration_date : ' ||
                        TO_CHAR (l_expiration_date)
                       );
      END IF;

      -- call process_credit_card
          -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: Calling  process_credit_card '
                       );
      END IF;

      process_credit_card (p_api_version                     => 1.0,
                           p_init_msg_list                   => g_false,
                           p_commit                          => g_false,
                           p_order_id                        => p_chr_id,
                           p_party_id                        => p_party_id,
                           p_cust_account_id                 => p_cust_account_id,
                           p_card_number                     => p_card_number,
                           p_expiration_date                 => l_expiration_date,
                           p_billing_address_id              => l_billing_address_id,
                           p_cvv_code                        => p_cvv_code,
                           p_instr_assignment_id             => p_instr_assignment_id,
                           p_old_txn_entension_id            => NULL,
                           -- as we are deleting above
                           x_new_txn_entension_id            => l_trxn_extension_id,
                           x_return_status                   => x_return_status,
                           x_msg_data                        => x_msg_data,
                           x_msg_count                       => x_msg_count
                          );

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING
             (fnd_log.level_statement,
              g_module ||
              l_api_name,
              '450: After Calling  process_credit_card x_return_status : ' ||
              x_return_status
             );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '450: l_trxn_extension_id : ' ||
                        l_trxn_extension_id
                       );
      END IF;

      IF (x_return_status = g_ret_sts_unexp_error) THEN
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error) THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- update OKC and OKS entities
      UPDATE oks_k_headers_b
         SET payment_type = p_payment_type,
             trxn_extension_id = l_trxn_extension_id,
             commitment_id = NULL,
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE chr_id = p_chr_id;

      UPDATE okc_k_headers_all_b
         SET cust_po_number = NULL,
             payment_instruction_type = NULL,
             cust_po_number_req_yn = 'N',
             payment_term_id =
                           NVL (x_rnrl_rec.payment_terms_id1, payment_term_id),
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE ID = p_chr_id;
    ELSIF p_payment_type = 'COM' THEN
      UPDATE oks_k_headers_b
         SET payment_type = p_payment_type,
             commitment_id = p_payment_details,
             trxn_extension_id = NULL,
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE chr_id = p_chr_id;

      UPDATE okc_k_headers_all_b
         SET cust_po_number = NULL,
             payment_instruction_type = NULL,
             cust_po_number_req_yn = 'N',
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE ID = p_chr_id;
    ELSE
      UPDATE oks_k_headers_b
         SET payment_type = NULL,
             trxn_extension_id = NULL,
             commitment_id = NULL,
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE chr_id = p_chr_id;

      UPDATE okc_k_headers_all_b
         SET cust_po_number = p_payment_details,
             payment_instruction_type = p_payment_type,
             object_version_number = object_version_number +
                                     1,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.login_id
       WHERE ID = p_chr_id;
    END IF;

    -- bump up the minor version number
    UPDATE okc_k_vers_numbers
       SET minor_version = minor_version +
                           1,
           object_version_number = object_version_number +
                                   1,
           last_update_date = SYSDATE,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
     WHERE chr_id = p_chr_id;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                               p_count                           => x_msg_count,
                               p_data                            => x_msg_data
                              );

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END update_payment_details;

---------------------------------------------------
  PROCEDURE send_email (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_chr_id                         IN       NUMBER,
    p_send_to                        IN       VARCHAR2,
    p_cc_to                          IN       VARCHAR2,
    p_subject                        IN       VARCHAR2,
    p_text                           IN       VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2 (30) := 'send_email';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Parameters p_chr_id : ' ||
                      p_chr_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_send_to : ' ||
                      p_send_to
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_api_version : ' ||
                      p_api_version
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '110: Calling FND_MSG_PUB.initialize'
                     );
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;
    -- set context to multi org
    -- mo_global.init ('OKC');

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
            (fnd_log.level_procedure,
             g_module ||
             l_api_name,
             '140: Calling OKS_WF_K_PROCESS_PVT.customer_request_assistance '
            );
    END IF;

    oks_wf_k_process_pvt.customer_request_assistance
                                          (p_api_version                     => p_api_version,
                                           p_init_msg_list                   => p_init_msg_list,
                                           p_commit                          => g_true,
                                           p_contract_id                     => p_chr_id,
                                           p_item_key                        => NULL,
                                           p_to_email                        => p_send_to,
                                           p_cc_email                        => p_cc_to,
                                           p_subject                         => p_subject,
                                           p_message                         => p_text,
                                           x_return_status                   => x_return_status,
                                           x_msg_data                        => x_msg_data,
                                           x_msg_count                       => x_msg_count
                                          );

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
        (fnd_log.level_procedure,
         g_module ||
         l_api_name,
         '150: After Calling customer_request_assistance x_return_status : ' ||
         x_return_status
        );
    END IF;

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                               p_count                           => x_msg_count,
                               p_data                            => x_msg_data
                              );

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END send_email;

---------------------------------------------------
  PROCEDURE get_valid_payments (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_chr_id                         IN       NUMBER,
    x_valid_payments                 OUT NOCOPY VARCHAR2,
    x_default_payment                OUT NOCOPY VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                      := 'get_valid_payments';
    l_api_version                  CONSTANT NUMBER := 1;
    l_valid_payments                        VARCHAR2 (2000) := '';
    l_effective_payments                    VARCHAR2 (2000) := '';
    l_default_payment                       VARCHAR2 (2000) := '';
    l_separator                             VARCHAR2 (1) := '';
    l_rnrl_rec                              oks_renew_util_pvt.rnrl_rec_type;
    x_rnrl_rec                              oks_renew_util_pvt.rnrl_rec_type;
    l_k_amount                              NUMBER (15, 2);
    l_k_curr                                VARCHAR2 (100);
    l_curr_instrument                       okc_k_headers_all_b.payment_instruction_type%TYPE
                                                                        := '';
    l_curr_payment                          oks_k_headers_b.payment_type%TYPE
                                                                        := '';
    l_k_current_payments                    VARCHAR2 (2000) := '';

    CURSOR csr_k_amt_curr IS
      SELECT (NVL (ch.estimated_amount, 0) + NVL (sh.tax_amount, 0) ) AS amount,
             ch.currency_code AS currency_code,
             ch.payment_instruction_type AS instrument_type,
             sh.payment_type AS payment_type
        FROM okc_k_headers_all_b ch,
             oks_k_headers_b sh
       WHERE ch.ID = sh.chr_id
         AND ch.ID = p_chr_id;

    CURSOR csr_curr_payment IS
      SELECT payment_type
        FROM oks_k_headers_b
       WHERE chr_id = p_chr_id;

    --cgopinee bugfix for 7443435
    CURSOR csr_chk_effective_payments(l_valid_payments IN VARCHAR2)  IS
      SELECT LOOKUP_CODE
       FROM fnd_lookups
      WHERE lookup_type='OKS_OA_PAYMENT_TYPES'
        AND INSTR (l_valid_payments,(lookup_code)) <> 0
        AND ENABLED_FLAG<>'N'
        AND Nvl(END_DATE_ACTIVE,SYSDATE)>= SYSDATE ;


  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;
    -- set context to multi org
    -- mo_global.init ('OKC');

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '200: Calling OKS_RENEW_UTIL_PVT.get_renew_rules'
                     );
    END IF;

    -- Call OKS_RENEW_UTIL_PVT.get_renew_rules
    oks_renew_util_pvt.get_renew_rules (x_return_status                   => x_return_status,
                                        p_api_version                     => 1.0,
                                        p_init_msg_list                   => g_false,
                                        p_chr_id                          => p_chr_id,
                                        p_party_id                        => NULL,
                                        p_org_id                          => NULL,
                                        p_date                            => SYSDATE,
                                        p_rnrl_rec                        => l_rnrl_rec,
                                        x_rnrl_rec                        => x_rnrl_rec,
                                        x_msg_count                       => x_msg_count,
                                        x_msg_data                        => x_msg_data
                                       );

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250: After Calling OKS_RENEW_UTIL_PVT.get_renew_rules'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250: x_return_status : ' ||
                      x_return_status
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.credit_card_flag  : ' ||
                      x_rnrl_rec.credit_card_flag
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.commitment_number_flag  : ' ||
                      x_rnrl_rec.commitment_number_flag
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.purchase_order_flag  : ' ||
                      x_rnrl_rec.purchase_order_flag
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.check_flag  : ' ||
                      x_rnrl_rec.check_flag
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '250:x_rnrl_rec.wire_flag  : ' ||
                      x_rnrl_rec.wire_flag
                     );
    END IF;

    --- If any errors happen abort API
    IF (x_return_status = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- check the contract amount and payment_threshold_amt
    -- if contract amount is less then the payment_threshold_amt then credit card is the only valid option
    OPEN csr_k_amt_curr;

    FETCH csr_k_amt_curr
     INTO l_k_amount,
          l_k_curr,
          l_curr_instrument,
		  l_curr_payment;

    CLOSE csr_k_amt_curr;

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300: l_k_amount : ' ||
                      l_k_amount
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300:l_k_curr  : ' ||
                      l_k_curr
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300:l_curr_instrument  : ' ||
                      l_curr_instrument
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300: x_rnrl_rec.payment_threshold_amt : ' ||
                      x_rnrl_rec.payment_threshold_amt
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300: x_rnrl_rec.base_currency : ' ||
                      x_rnrl_rec.base_currency
                     );
    END IF;

    -- if the contract has some payment type or instrument type entered thru forms
    -- then always append to valid payment types
/*
    OPEN csr_curr_payment;

    FETCH csr_curr_payment
     INTO l_curr_payment;

    CLOSE csr_curr_payment;
*/
    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '300: l_curr_payment : ' ||
                      l_curr_payment
                     );
    END IF;

    IF l_curr_payment = 'CCR' THEN
      l_k_current_payments       :=
        '''' ||
        'USEDCC' ||
        '''' ||
        ',' ||
        '''' ||
        'CCR' ||
        '''' ||
        ',' ||
        '''' ||
        'NEWCC' ||
        '''';
      l_separator                := ',';
      l_default_payment          := 'USEDCC';
    ELSIF l_curr_payment = 'COM' THEN
      l_k_current_payments       := '''' ||
                                    l_curr_payment ||
                                    '''';
      l_separator                := ',';
      l_default_payment          := l_curr_payment;
    END IF;

    IF l_curr_instrument IS NOT NULL THEN
      l_k_current_payments       :=
        l_k_current_payments ||
        l_separator ||
        '''' ||
        l_curr_instrument ||
        '''';
      l_separator                := ',';

      IF l_default_payment IS NULL THEN
        l_default_payment          := l_curr_instrument;
      END IF;
    END IF;                                                 -- curr instrument

    IF x_rnrl_rec.base_currency = l_k_curr THEN
      IF NVL (l_k_amount, 0) < NVL (x_rnrl_rec.payment_threshold_amt, 0) THEN
        -- credit card is the only valid option
        x_valid_payments           :=
          l_k_current_payments ||
          l_separator ||
          '''' ||
          'CCR' ||
          '''' ||
          ',' ||
          '''' ||
          'NEWCC' ||
          '''';
        x_default_payment          := 'CCR';
        RETURN;
      END IF;                        -- credit card is the only payment option
    END IF;                                -- currency of K and base curr same

    -- debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '350: l_k_current_payments : ' ||
                      l_k_current_payments
                     );
    END IF;

    -- if contract has any current payment, prepend the same
    IF l_k_current_payments IS NOT NULL THEN
      l_valid_payments           := l_k_current_payments;
      l_separator                := ',';
    END IF;

    -- get the allowed payment methods
    IF NVL (x_rnrl_rec.credit_card_flag, 'N') = 'Y' THEN
      l_valid_payments           :=
        l_valid_payments ||
        l_separator ||
        '''' ||
        'CCR' ||
        '''' ||
        ',' ||
        '''' ||
        'NEWCC' ||
        '''';
      l_separator                := ',';
      l_default_payment          := 'CCR';
    END IF;

    IF NVL (x_rnrl_rec.commitment_number_flag, 'N') = 'Y' THEN
      l_valid_payments           :=
                     l_valid_payments ||
                     l_separator ||
                     '''' ||
                     'COM' ||
                     '''';
      l_separator                := ',';

      IF l_default_payment IS NULL THEN
        l_default_payment          := 'COM';
      END IF;
    END IF;

    IF NVL (x_rnrl_rec.purchase_order_flag, 'N') = 'Y' THEN
      l_valid_payments           :=
                     l_valid_payments ||
                     l_separator ||
                     '''' ||
                     'PON' ||
                     '''';
      l_separator                := ',';

      IF l_default_payment IS NULL THEN
        l_default_payment          := 'PON';
      END IF;
    END IF;

    IF NVL (x_rnrl_rec.check_flag, 'N') = 'Y' THEN
      l_valid_payments           :=
                     l_valid_payments ||
                     l_separator ||
                     '''' ||
                     'CHK' ||
                     '''';
      l_separator                := ',';

      IF l_default_payment IS NULL THEN
        l_default_payment          := 'CHK';
      END IF;
    END IF;

    IF NVL (x_rnrl_rec.wire_flag, 'N') = 'Y' THEN
      l_valid_payments           :=
                     l_valid_payments ||
                     l_separator ||
                     '''' ||
                     'WIR' ||
                     '''';
      l_separator                := ',';

      IF l_default_payment IS NULL THEN
        l_default_payment          := 'WIR';
      END IF;
    END IF;



   --cgopinee bugfix for 7443435

   /* checking for the effective payment types from the list.*/

    FOR rec in csr_chk_effective_payments(l_valid_payments)
    LOOP
      IF  l_effective_payments IS NOT NULL THEN
         l_effective_payments := l_effective_payments||','||''''||rec.LOOKUP_CODE||'''';
      ELSE
         l_effective_payments :=''''||rec.LOOKUP_CODE||'''';
      END IF;
    END LOOP;

    /*Check if the default payment type is in the list of valid payment type
      else assign the payment type in the same order as it was assigned earlier*/

    IF (InStr(l_effective_payments,l_default_payment) <>0 ) THEN
         l_default_payment := l_default_payment;
    ELSIF (InStr(l_effective_payments,'CCR') <>0 ) THEN
        l_default_payment          := 'CCR';
    ELSIF (InStr(l_effective_payments,'COM') <>0 ) THEN
        l_default_payment          := 'COM';
    ELSIF (InStr(l_effective_payments,'PON') <>0 ) THEN
        l_default_payment          := 'PON';
    ELSIF (InStr(l_effective_payments,'CHK') <>0 ) THEN
        l_default_payment          := 'CHK';
    ELSE
        l_default_payment          := 'WIR';
    END IF;


  -- debug log
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.STRING (fnd_log.level_procedure,
                       g_module ||
                       l_api_name,
                       '500: x_valid_payments : ' ||
                       l_valid_payments
                      );
       fnd_log.STRING (fnd_log.level_procedure,
                       g_module ||
                       l_api_name,
                       '500: x_default_payment : ' ||
                       l_default_payment
                      );
    END IF;



    x_valid_payments           := l_effective_payments;
    x_default_payment          := l_default_payment;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END get_valid_payments;

---------------------------------------------------
  PROCEDURE process_credit_card (
    p_api_version                    IN       NUMBER,
    p_init_msg_list                  IN       VARCHAR2,
    p_commit                         IN       VARCHAR2 DEFAULT fnd_api.g_false,
    p_order_id                       IN       NUMBER,
    p_party_id                       IN       NUMBER,
    p_cust_account_id                IN       NUMBER,
    p_card_number                    IN       VARCHAR2 DEFAULT NULL,
    p_expiration_date                IN       DATE DEFAULT NULL,
    p_billing_address_id             IN       NUMBER DEFAULT NULL,
    p_cvv_code                       IN       VARCHAR2 DEFAULT NULL,
    p_instr_assignment_id            IN       NUMBER DEFAULT NULL,
    p_old_txn_entension_id           IN       NUMBER DEFAULT NULL,
    x_new_txn_entension_id           OUT NOCOPY NUMBER,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                                     := 'process_credit_card';
    l_api_version                  CONSTANT NUMBER := 1;
    l_instr_assignment_id                   NUMBER := '';

    SUBTYPE l_payer_type IS iby_fndcpt_common_pub.payercontext_rec_type;

    SUBTYPE l_credit_card_type IS iby_fndcpt_setup_pub.creditcard_rec_type;

    SUBTYPE l_pmtinstrassignment_type IS iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;

    SUBTYPE l_trxnextension_type IS iby_fndcpt_trxn_pub.trxnextension_rec_type;

    l_payer                                 l_payer_type;
    l_credit_card                           l_credit_card_type;
    l_pmtinstrassignment                    l_pmtinstrassignment_type;
    l_response                              iby_fndcpt_common_pub.result_rec_type;
    l_trxnextension                         l_trxnextension_type;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: *******   Parameters ********'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_init_msg_list : ' ||
                      p_init_msg_list
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_order_id : ' ||
                      p_order_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_party_id : ' ||
                      p_party_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_cust_account_id : ' ||
                      p_cust_account_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_card_number : ' ||
                      p_card_number
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_expiration_date : ' ||
                      TO_CHAR (p_expiration_date)
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_billing_address_id : ' ||
                      p_billing_address_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_cvv_code : ' ||
                      p_cvv_code
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_instr_assignment_id : ' ||
                      p_instr_assignment_id
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_old_txn_entension_id : ' ||
                      p_old_txn_entension_id
                     );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name
                                       ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;
    -- populate the payer record
    l_payer.payment_function   := 'CUSTOMER_PAYMENT';
    l_payer.party_id           := p_party_id;
    l_payer.cust_account_id    := p_cust_account_id;

    -- Delete any old transaction extension id
    IF (p_old_txn_entension_id IS NOT NULL) THEN
      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: Found old txn extension id : ' ||
                        p_old_txn_entension_id
                       );
        fnd_log.STRING
          (fnd_log.level_statement,
           g_module ||
           l_api_name,
           '150: ***** Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension *****'
          );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: ***** Parameters *****'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.Payment_Function : ' ||
                        'CUSTOMER_PAYMENT'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.Party_Id : ' ||
                        l_payer.party_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.cust_account_id : ' ||
                        l_payer.cust_account_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: p_commit : ' ||
                        p_commit
                       );
      END IF;

      -- dbms_output.put_line('Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
      iby_fndcpt_trxn_pub.delete_transaction_extension
           (p_api_version                     => 1.0,
            p_init_msg_list                   => fnd_api.g_false,
            p_commit                          => p_commit,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            p_payer                           => l_payer,
            p_payer_equivalency               => iby_fndcpt_common_pub.g_payer_equiv_full,
            p_entity_id                       => p_old_txn_entension_id,
            x_response                        => l_response
           );

      /*
           dbms_output.put_line('After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
           dbms_output.put_line(' x_return_status : '|| x_return_status);
           dbms_output.put_line(' x_msg_count : '|| x_msg_count);
           dbms_output.put_line(' l_response.result_code : '|| l_response.result_code);
           dbms_output.put_line(' l_response.result_category : '|| l_response.result_category);
           dbms_output.put_line(' l_response.result_message : '|| l_response.result_message);
           */

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING
          (fnd_log.level_statement,
           g_module ||
           l_api_name,
           '200: ***** After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension *****'
          );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_return_status : ' ||
                        x_return_status
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_msg_count : ' ||
                        x_msg_count
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_code : ' ||
                        l_response.result_code
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_category : ' ||
                        l_response.result_category
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_message : ' ||
                        l_response.result_message
                       );
      END IF;

      IF (x_return_status = g_ret_sts_unexp_error) THEN
        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error) THEN
        /*
         iby will NOT allow txn extn to be deleted if there are any authorizations against the txn extn id
         In OKS QA check, we get a authorization from iby to validate credit card
         If QA check is run on the contract, then delete will fail and iby will return an error
         We will ignore Error from iby when delete txn is called.


        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
        */
        null;  -- error is ignored
      END IF;
    END IF;                              -- p_old_txn_entension_id is not null

    -- if p_instr_assignment_id IS NULL then it is new credit card
    -- call the process_credit_card_api to get instrument assignment id
    IF (p_instr_assignment_id IS NULL) THEN
      l_credit_card.owner_id     := p_party_id;
      l_credit_card.billing_address_id := p_billing_address_id;
      l_credit_card.card_number  := p_card_number;
      l_credit_card.expiration_date := p_expiration_date;

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: p_instr_assignment_id IS NULL'
                       );
        fnd_log.STRING
          (fnd_log.level_statement,
           g_module ||
           l_api_name,
           '300: ***** Calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card *****'
          );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: ***** Parameters *****'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_credit_card.Owner_Id : ' ||
                        l_credit_card.owner_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_credit_card.Billing_Address_Id : ' ||
                        l_credit_card.billing_address_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_credit_card.Card_Number : ' ||
                        l_credit_card.card_number
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_credit_card.Expiration_Date : ' ||
                        l_credit_card.expiration_date
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_payer.Payment_Function : ' ||
                        'CUSTOMER_PAYMENT'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_payer.Party_Id : ' ||
                        l_payer.party_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: l_payer.cust_account_id : ' ||
                        l_payer.cust_account_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '300: p_commit : ' ||
                        p_commit
                       );
      END IF;

      -- dbms_output.put_line('Calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card');
      iby_fndcpt_setup_pub.process_credit_card
                                (p_api_version                     => 1.0,
                                 p_init_msg_list                   => fnd_api.g_false,
                                 p_commit                          => p_commit,
                                 x_return_status                   => x_return_status,
                                 x_msg_count                       => x_msg_count,
                                 x_msg_data                        => x_msg_data,
                                 p_payer                           => l_payer,
                                 p_credit_card                     => l_credit_card,
                                 p_assignment_attribs              => l_pmtinstrassignment,
                                 x_assign_id                       => l_instr_assignment_id,
                                 x_response                        => l_response
                                );

      /*
           dbms_output.put_line('After Calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card');
           dbms_output.put_line(' x_return_status : '|| x_return_status);
           dbms_output.put_line(' x_msg_count : '|| x_msg_count);
           dbms_output.put_line(' l_response.result_code : '|| l_response.result_code);
           dbms_output.put_line(' l_response.result_category : '|| l_response.result_category);
           dbms_output.put_line(' l_response.result_message : '|| l_response.result_message);
           */

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING
               (fnd_log.level_statement,
                g_module ||
                l_api_name,
                '350: After Calling IBY_FNDCPT_SETUP_PUB.Process_Credit_Card'
               );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: x_return_status : ' ||
                        x_return_status
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: l_instr_assignment_id : ' ||
                        l_instr_assignment_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: x_msg_count : ' ||
                        x_msg_count
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: x_response.result_code : ' ||
                        l_response.result_code
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: x_response.result_category : ' ||
                        l_response.result_category
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '350: x_response.result_message : ' ||
                        l_response.result_message
                       );
      END IF;

      IF (x_return_status = g_ret_sts_unexp_error) THEN
        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token ('IBY_API_NAME',
                               'IBY_FNDCPT_SETUP_PUB.Process_Credit_Card');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error) THEN
        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token ('IBY_API_NAME',
                               'IBY_FNDCPT_SETUP_PUB.Process_Credit_Card');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- assignment id exists already
      l_instr_assignment_id      := p_instr_assignment_id;
    END IF;                                   -- p_instr_assignment_id IS NULL

    -- Create a new transaction extension id with the instrument assignment id
    l_trxnextension.originating_application_id := 515;                  -- OKS
    l_trxnextension.order_id   := p_order_id;
    l_trxnextension.instrument_security_code := p_cvv_code;
    l_trxnextension.trxn_ref_number1  := to_char(SYSDATE,'ddmmyyyyhhmmssss');

    -- debug log
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
        (fnd_log.level_statement,
         g_module ||
         l_api_name,
         '500: ***** Calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension *****'
        );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: ***** Parameters *****'
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_TrxnExtension.Originating_Application_Id : ' ||
                      l_trxnextension.originating_application_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_TrxnExtension.Order_Id : ' ||
                      l_trxnextension.order_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_TrxnExtension.instrument_security_code : ' ||
                      l_trxnextension.instrument_security_code
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_payer.Payment_Function : ' ||
                      'CUSTOMER_PAYMENT'
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_payer.Party_Id : ' ||
                      l_payer.party_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: l_payer.cust_account_id : ' ||
                      l_payer.cust_account_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: p_commit : ' ||
                      p_commit
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: p_payer_equivalency : ' ||
                      iby_fndcpt_common_pub.g_payer_equiv_full
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: p_pmt_channel : ' ||
                      iby_fndcpt_setup_pub.g_channel_credit_card
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '500: p_instr_assignment : ' ||
                      l_instr_assignment_id
                     );
    END IF;

    -- dbms_output.put_line('Calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension');
    iby_fndcpt_trxn_pub.create_transaction_extension
           (p_api_version                     => 1.0,
            p_init_msg_list                   => fnd_api.g_false,
            p_commit                          => p_commit,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            p_payer                           => l_payer,
            p_payer_equivalency               => iby_fndcpt_common_pub.g_payer_equiv_full,
            -- FULL
            p_pmt_channel                     => iby_fndcpt_setup_pub.g_channel_credit_card,
            -- CREDIT_CARD
            p_instr_assignment                => l_instr_assignment_id,
            p_trxn_attribs                    => l_trxnextension,
            x_entity_id                       => x_new_txn_entension_id,
            x_response                        => l_response
           );

    /*
        dbms_output.put_line('After Calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension');
        dbms_output.put_line(' x_return_status : '|| x_return_status);
        dbms_output.put_line(' x_msg_count : '|| x_msg_count);
        dbms_output.put_line(' x_entity_id : '|| x_new_txn_entension_id);
        dbms_output.put_line(' l_response.result_code : '|| l_response.result_code);
        dbms_output.put_line(' l_response.result_category : '|| l_response.result_category);
        dbms_output.put_line(' l_response.result_message : '|| l_response.result_message);
        */

    -- debug log
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING
        (fnd_log.level_statement,
         g_module ||
         l_api_name,
         '600: After Calling IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension'
        );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_return_status : ' ||
                      x_return_status
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_new_txn_entension_id : ' ||
                      x_new_txn_entension_id
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_msg_count : ' ||
                      x_msg_count
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_response.result_code : ' ||
                      l_response.result_code
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_response.result_category : ' ||
                      l_response.result_category
                     );
      fnd_log.STRING (fnd_log.level_statement,
                      g_module ||
                      l_api_name,
                      '600: x_response.result_message : ' ||
                      l_response.result_message
                     );
    END IF;

    IF (x_return_status = g_ret_sts_unexp_error) THEN
      fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
      fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension');
      fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
      fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension');
      fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END process_credit_card;

---------------------------------------------------
  PROCEDURE get_contract_salesrep_details (
    p_chr_id                         IN       NUMBER,
    x_salesrep_email                 OUT NOCOPY VARCHAR2,
    x_salesrep_username              OUT NOCOPY VARCHAR2,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                           := 'get_contract_salesrep_details';

    CURSOR csr_k_salesrep IS
      SELECT srp.email_address AS email_address,
             res.user_name AS username
        FROM okc_k_headers_all_b khr,
             okc_contacts ct,
             jtf_rs_salesreps srp,
             jtf_rs_resource_extns res
       WHERE khr.ID = ct.dnz_chr_id
         AND ct.object1_id1 = srp.salesrep_id
         AND srp.resource_id = res.resource_id
         AND srp.org_id = khr.authoring_org_id
         AND ct.jtot_object1_code='OKX_SALEPERS' --bug 6243682
         AND res.CATEGORY IN
                ('EMPLOYEE', 'OTHER', 'PARTY', 'PARTNER', 'SUPPLIER_CONTACT')
         -- AND srp.email_address IS NOT NULL   -- bug 4918198
         AND res.user_name IS NOT NULL          -- Salesrep MUST BE a FND USER
         AND khr.ID = p_chr_id;

    CURSOR csr_party_helpdesk (
      p_k_party_id                     IN       NUMBER
    ) IS
      SELECT gcd.email_address,
             fnd.user_name
        FROM oks_k_defaults gcd,
             fnd_user fnd
       WHERE gcd.user_id = fnd.user_id
         AND gcd.cdt_type = 'SDT'
         AND gcd.jtot_object_code = 'OKX_PARTY'
         -- AND gcd.email_address IS NOT NULL  -- bug 4918198
         AND gcd.segment_id1 = p_k_party_id;

    CURSOR csr_org_helpdesk (
      p_k_org_id                       IN       NUMBER
    ) IS
      SELECT gcd.email_address,
             fnd.user_name
        FROM oks_k_defaults gcd,
             fnd_user fnd
       WHERE gcd.user_id = fnd.user_id
         AND gcd.cdt_type = 'SDT'
         AND gcd.jtot_object_code = 'OKX_OPERUNIT'
        -- AND gcd.email_address IS NOT NULL -- bug 4918198
         AND gcd.segment_id1 = p_k_org_id;

    CURSOR csr_global_helpdesk IS
      SELECT gcd.email_address,
             fnd.user_name
        FROM oks_k_defaults gcd,
             fnd_user fnd
       WHERE gcd.user_id = fnd.user_id
         AND gcd.cdt_type = 'MDT';
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: *******   Parameters ********'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_chr_id : ' ||
                      p_chr_id
                     );
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;

    OPEN csr_k_salesrep;

    FETCH csr_k_salesrep
     INTO x_salesrep_email,
          x_salesrep_username;

    IF csr_k_salesrep%FOUND THEN
      -- Salesrep exist on K
      CLOSE csr_k_salesrep;

      RETURN;
    END IF;                                                  -- k_salesrep csr

    CLOSE csr_k_salesrep;

    -- Go to GCD at party level
    OPEN csr_party_helpdesk (p_k_party_id                      => get_contract_party
                                                                     (p_chr_id));

    FETCH csr_party_helpdesk
     INTO x_salesrep_email,
          x_salesrep_username;

    IF csr_party_helpdesk%FOUND THEN
      CLOSE csr_party_helpdesk;

      RETURN;
    END IF;                                         -- helpdesk on party level

    CLOSE csr_party_helpdesk;

    -- Go to GCD at organization level
    OPEN csr_org_helpdesk (p_k_org_id                        => get_contract_organization
                                                                     (p_chr_id));

    FETCH csr_org_helpdesk
     INTO x_salesrep_email,
          x_salesrep_username;

    IF csr_org_helpdesk%FOUND THEN
      CLOSE csr_org_helpdesk;

      RETURN;
    END IF;                                         -- helpdesk on party level

    CLOSE csr_org_helpdesk;

    -- Go to GCD at global level
    OPEN csr_global_helpdesk;

    FETCH csr_global_helpdesk
     INTO x_salesrep_email,
          x_salesrep_username;

    CLOSE csr_global_helpdesk;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END get_contract_salesrep_details;

---------------------------------------------------
  PROCEDURE delete_transaction_extension (
    p_chr_id                         IN       NUMBER,
    p_commit                         IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_msg_data                       OUT NOCOPY VARCHAR2,
    x_msg_count                      OUT NOCOPY NUMBER
  ) AS
    l_api_name                     CONSTANT VARCHAR2 (30)
                                            := 'delete_transaction_extension';

    CURSOR csr_old_txn_id IS
      SELECT oks.trxn_extension_id,
             ca.cust_account_id,
             ca.party_id
        FROM okc_k_headers_all_b okc,
             oks_k_headers_b oks,
             hz_cust_site_uses_all su,
             hz_cust_acct_sites_all sa,
             hz_cust_accounts_all ca
       WHERE oks.chr_id = okc.ID
         AND okc.bill_to_site_use_id = su.site_use_id
         AND su.cust_acct_site_id = sa.cust_acct_site_id
         AND sa.cust_account_id = ca.cust_account_id
         AND oks.trxn_extension_id IS NOT NULL
         AND okc.ID = p_chr_id;

    l_cust_account_id                       hz_cust_accounts_all.cust_account_id%TYPE;
    l_party_id                              hz_cust_accounts_all.party_id%TYPE;
    l_trxn_extension_id                     oks_k_headers_b.trxn_extension_id%TYPE;

    SUBTYPE l_payer_type IS iby_fndcpt_common_pub.payercontext_rec_type;

    l_payer                                 l_payer_type;
    l_response                              iby_fndcpt_common_pub.result_rec_type;
  BEGIN
    -- start debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: Entered ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: *******   Parameters ********'
                     );
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '100: p_chr_id : ' ||
                      p_chr_id
                     );
    END IF;

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;

    OPEN csr_old_txn_id;

    FETCH csr_old_txn_id
     INTO l_trxn_extension_id,
          l_cust_account_id,
          l_party_id;

    IF csr_old_txn_id%FOUND THEN
      -- old txn extension id exists, call iby delete API

      -- populate the payer record
      l_payer.payment_function   := 'CUSTOMER_PAYMENT';
      l_payer.party_id           := l_party_id;
      l_payer.cust_account_id    := l_cust_account_id;

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: Found old txn extension id : ' ||
                        l_trxn_extension_id
                       );
        fnd_log.STRING
          (fnd_log.level_statement,
           g_module ||
           l_api_name,
           '150: ***** Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension *****'
          );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: ***** Parameters *****'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.Payment_Function : ' ||
                        'CUSTOMER_PAYMENT'
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.Party_Id : ' ||
                        l_payer.party_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_payer.cust_account_id : ' ||
                        l_payer.cust_account_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: l_trxn_extension_id : ' ||
                        l_trxn_extension_id
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '150: p_commit : ' ||
                        p_commit
                       );
      END IF;

      iby_fndcpt_trxn_pub.delete_transaction_extension
           (p_api_version                     => 1.0,
            p_init_msg_list                   => fnd_api.g_false,
            p_commit                          => p_commit,
            x_return_status                   => x_return_status,
            x_msg_count                       => x_msg_count,
            x_msg_data                        => x_msg_data,
            p_payer                           => l_payer,
            p_payer_equivalency               => iby_fndcpt_common_pub.g_payer_equiv_full,
            p_entity_id                       => l_trxn_extension_id,
            x_response                        => l_response
           );

      -- debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING
          (fnd_log.level_statement,
           g_module ||
           l_api_name,
           '200: ***** After Calling IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension *****'
          );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_return_status : ' ||
                        x_return_status
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_msg_count : ' ||
                        x_msg_count
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_code : ' ||
                        l_response.result_code
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_category : ' ||
                        l_response.result_category
                       );
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '200: x_response.result_message : ' ||
                        l_response.result_message
                       );
      END IF;                                                     -- debug log

      IF (x_return_status = g_ret_sts_unexp_error) THEN
        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF (x_return_status = g_ret_sts_error) THEN
       /*
       bug 5486543
       iby will NOT allow txn extn to be deleted if there are any authorizations against the txn extn id
       In OKS QA check, we get a authorization from iby to validate credit card
       If QA check is run on the contract, then delete will fail and iby will return an error
       We will ignore Error from iby when delete txn is called.

        fnd_message.set_name (g_app_name, 'OKS_IBY_API_ERROR');
        fnd_message.set_token
                          ('IBY_API_NAME',
                           'IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension');
        fnd_message.set_token ('ERROR_DTLS', l_response.result_message);
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
        */
        x_return_status := fnd_api.g_ret_sts_success; -- initialize
        null;  -- error is ignored
      END IF;
    END IF;                                           --  csr_old_txn_id%FOUND

    CLOSE csr_old_txn_id;

    -- end debug log
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_module ||
                      l_api_name,
                      '1000: Leaving ' ||
                      g_pkg_name ||
                      '.' ||
                      l_api_name
                     );
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN OTHERS THEN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                        g_module ||
                        l_api_name,
                        '4000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
  END delete_transaction_extension;
---------------------------------------------------
END oks_customer_acceptance_pvt;

/
