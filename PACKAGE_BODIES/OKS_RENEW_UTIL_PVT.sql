--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_UTIL_PVT" AS
/* $Header: OKSRRUTB.pls 120.16.12010000.2 2008/10/22 12:51:22 ssreekum ship $*/

    FUNCTION CHECK_TEMPLATE_SET_VALIDITY (p_template_set_id IN NUMBER)
    RETURN VARCHAR2 IS

    CURSOR l_template_set_cur (p_template_set_id IN NUMBER, p_profile IN VARCHAR2) IS
        SELECT 'Y'
        FROM OKS_TEMPLATE_SET
        WHERE id = p_template_set_id
        AND template_source = p_profile;

    l_profile VARCHAR2(10);
    l_return VARCHAR2(1) := 'N';

    BEGIN
        l_profile := NVL(FND_PROFILE.VALUE('OKS_LAYOUT_TEMPLATE_SOURCE'), 'OKC');

        OPEN l_template_set_cur(p_template_set_id, l_profile);
        FETCH l_template_set_cur INTO l_return;

        IF l_template_set_cur%NOTFOUND THEN
            l_return := 'N';
        END IF;

        CLOSE l_template_set_cur;

        RETURN l_return;
    EXCEPTION
        WHEN OTHERS THEN
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);
    END;


  --======================================================================

    PROCEDURE UPDATE_RENEWAL_STATUS (
                                     X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                     P_CHR_ID IN NUMBER,
                                     P_RENEW_STATUS IN VARCHAR2,
                                     P_CHR_STATUS IN VARCHAR2
                                     ) IS

    l_api_version CONSTANT NUMBER := 1.0;
    l_init_msg_list CONSTANT VARCHAR2(1) := 'T';
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000) := NULL;

    l_khdr_rec_in OKS_CONTRACT_HDR_PUB.khrv_rec_type;
    l_khdr_rec_out OKS_CONTRACT_HDR_PUB.khrv_rec_type;

    l_okc_hdr_rec_in OKC_CONTRACT_PUB.chrv_rec_type;
    l_okc_hdr_rec_out OKC_CONTRACT_PUB.chrv_rec_type;

    e_error EXCEPTION;

    BEGIN

        l_return_status := OKC_API.G_RET_STS_SUCCESS;

        l_khdr_rec_in.chr_id := p_chr_id;
        l_khdr_rec_in.renewal_status := p_renew_status;

        oks_contract_hdr_pub.update_header(
                                           p_api_version => l_api_version,
                                           p_init_msg_list => l_init_msg_list,
                                           x_return_status => l_return_status,
                                           x_msg_count => l_msg_count,
                                           x_msg_data => l_msg_data,
                                           p_khrv_rec => l_khdr_rec_in,
                                           x_khrv_rec => l_khdr_rec_out,
                                           p_validate_yn => 'N'
                                           );

        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE e_Error;
        END IF;

        l_okc_hdr_rec_in.id := p_chr_id;
        l_okc_hdr_rec_in.sts_code := p_chr_status;

        okc_contract_pub.update_contract_header(
                                                p_api_version => l_api_version,
                                                p_init_msg_list => l_init_msg_list,
                                                x_return_status => l_return_status,
                                                x_msg_count => l_msg_count,
                                                x_msg_data => l_msg_data,
                                                p_restricted_update => 'F',
                                                p_chrv_rec => l_okc_hdr_rec_in,
                                                x_chrv_rec => l_okc_hdr_rec_out
                                                );

        IF NOT l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            RAISE e_Error;
        END IF;

    EXCEPTION
        WHEN E_Error THEN
            x_Return_status := l_Return_status;
        WHEN OTHERS THEN
	  -- store SQL error message on message stack for caller
            OKC_API.SET_MESSAGE(
                                p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM
                                );

      -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END;

    PROCEDURE get_payment_terms (
                                 p_chr_id IN NUMBER,
                                 p_party_id IN NUMBER,
                                 p_org_id IN NUMBER,
                                 p_effective_date IN DATE,
                                 x_pay_term_id1 OUT NOCOPY VARCHAR2,
                                 x_pay_term_id2 OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2) IS

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_payment_terms_id1 VARCHAR2(40);
    l_payment_terms_id2 VARCHAR2(40);
    l_payment_term_flag VARCHAR2(1) := 'N';
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);
    l_procedure_name VARCHAR2(80);
    l_party NUMBER;
    l_org NUMBER;

    CURSOR l_party_cur IS
        SELECT object1_id1 FROM OKC_K_PARTY_ROLES_V
        WHERE dnz_chr_id = p_chr_id
        AND cle_id IS NULL
        AND jtot_object1_code = 'OKX_PARTY'
        AND rle_code = 'CUSTOMER';

    CURSOR l_org_cur IS
        SELECT authoring_org_id
        FROM OKC_K_HEADERS_V
        WHERE id = p_chr_id;

        -- Cursor to fetch values defined at Party/Org level in Global Defaults.
    CURSOR l_party_org_level_cur(p_id1 IN VARCHAR2,
                                 p_id2 IN VARCHAR2,
                                 p_object_code IN VARCHAR2,
                                 p_date IN DATE
                                 ) IS
        SELECT payment_terms_id1, payment_terms_id2
        FROM   OKS_K_DEFAULTS_V
        WHERE  SEGMENT_ID1 = p_id1
        AND    SEGMENT_ID2 = p_id2
        AND    JTOT_OBJECT_CODE = p_object_code
        AND    CDT_TYPE = 'SDT'
        AND    nvl(p_date, SYSDATE) BETWEEN
               nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE);

        -- Cursor to fetch renewal rules defined at Global level in Global Defaults.
    CURSOR l_global_level_cur IS
        SELECT payment_terms_id1, payment_terms_id2
        FROM   OKS_K_DEFAULTS_V
        WHERE  cdt_type = 'MDT'
        AND    segment_id1 IS NULL
        AND    segment_id2 IS NULL
        AND    jtot_object_code IS NULL;

    BEGIN

        IF (p_chr_id IS NULL OR p_chr_id = FND_API.G_MISS_NUM ) AND
            (
             (p_party_id IS NULL OR p_party_id = FND_API.G_MISS_NUM ) OR
             (p_org_id IS NULL OR p_org_id = FND_API.G_MISS_NUM)
             ) THEN

            IF p_chr_id IS NULL OR p_chr_id = FND_API.G_MISS_NUM THEN
                OKC_API.SET_MESSAGE(G_APP_NAME, G_REQUIRED_PARAM,
                                    'TOKEN1', 'CHR_ID',
                                    'TOKEN2', 'GET_PAYMENT_TERMS');
            END IF;

            IF p_party_id IS NULL OR p_party_id = FND_API.G_MISS_NUM THEN
                OKC_API.SET_MESSAGE(G_APP_NAME, G_REQUIRED_PARAM,
                                    'TOKEN1', 'PARTY_ID',
                                    'TOKEN2', 'GET_PAYMENT_TERMS');
            END IF;

            IF p_org_id IS NULL OR p_org_id = FND_API.G_MISS_NUM THEN
                OKC_API.SET_MESSAGE(G_APP_NAME, G_REQUIRED_PARAM,
                                    'TOKEN1', 'ORG_ID',
                                    'TOKEN2', 'GET_PAYMENT_TERMS');
            END IF;

            l_Return_Status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

    -- Check for party_id, if not present get party_id
        IF p_party_id IS NULL OR p_party_id = FND_API.G_MISS_NUM THEN
            OPEN l_party_cur;
            FETCH l_party_cur INTO l_party;
            CLOSE l_party_cur;
        ELSE
            l_party := p_party_id;
        END IF;

    -- Fetch renewal rules for this party as there are set in
    -- Global Defaults
        IF l_party IS NOT NULL THEN
            OPEN l_party_org_level_cur(to_char(l_party), '#', 'OKX_PARTY', p_effective_date);
            FETCH l_party_org_level_cur INTO l_payment_terms_id1, l_payment_terms_id2;
            CLOSE l_party_org_level_cur;

            IF l_payment_terms_id1 IS NOT NULL AND l_payment_terms_id2 IS NOT NULL THEN
                l_payment_term_flag := 'Y';
            END IF;
        END IF;

        IF l_payment_term_flag = 'N' THEN

        -- Check for org_id, if not present get Org_id
            IF p_org_id IS NULL OR p_org_id = FND_API.G_MISS_NUM THEN
                OPEN l_org_cur;
                FETCH l_org_cur INTO l_org;
                CLOSE l_org_cur;
            ELSE
                l_org := p_org_id;
            END IF;

       -- Fetch payment terms for this org as set in Global Defaults
            IF l_org IS NOT NULL THEN
                OPEN l_party_org_level_cur(to_char(l_org), '#', 'OKX_OPERUNIT', p_effective_date);
                FETCH l_party_org_level_cur INTO l_payment_terms_id1, l_payment_terms_id2;
                CLOSE l_party_org_level_cur;

                IF l_payment_terms_id1 IS NOT NULL AND l_payment_terms_id2 IS NOT NULL THEN
                    l_payment_term_flag := 'Y';
                END IF;
            END IF;
        END IF;

        IF l_payment_term_flag = 'N' THEN

       -- Fetch payment terms as set at global level in Global Defaults
            OPEN l_global_level_cur;
            FETCH l_global_level_cur INTO l_payment_terms_id1, l_payment_terms_id2;

       -- As there should be always values under globals in
       -- global defaults setup, if nothing is found, raise error
            IF l_global_level_cur%NOTFOUND THEN
                CLOSE l_global_level_cur;
                OKC_API.set_message(G_APP_NAME, 'OKS_GLOBAL_DEFAULTS_NOT_FOUND');
                l_return_status := OKC_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            CLOSE l_global_level_cur;
        END IF;

    -- Populate the out parameters with the renewal fields
        x_pay_term_id1 := l_payment_terms_id1;
        x_pay_term_id2 := l_payment_terms_id2;
        x_return_status := l_return_status;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status;
        WHEN OTHERS THEN
            -- store SQL error message on message stack for caller
            OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                                p_msg_name => g_unexpected_error,
                                p_token1 => g_sqlcode_token,
                                p_token1_value => SQLCODE,
                                p_token2 => g_sqlerrm_token,
                                p_token2_value => SQLERRM);

            -- notify caller of an UNEXPECTED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END get_payment_terms;

    PROCEDURE Can_Update_Contract(
                                  p_chr_id IN NUMBER,
                                  x_can_update_yn OUT NOCOPY VARCHAR2,
                                  x_can_submit_yn OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2
                                  ) IS

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        x_can_update_yn := 'Y';
        x_can_submit_yn := 'Y';
    END Can_Update_Contract;

-------------------------------------------------------------------------------
/* This procedure gets the values of period_type,period_start and price_uom from GCD
if contract header id is null else gets the values from contract header record.
*/
    PROCEDURE get_period_defaults(p_hdr_id IN NUMBER DEFAULT NULL,
                                  p_org_id IN VARCHAR2 DEFAULT NULL,
                                  x_period_type OUT NOCOPY VARCHAR2,
                                  x_period_start OUT NOCOPY VARCHAR2,
                                  x_price_uom OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2)
    IS

    CURSOR get_hdr_period_val(p_hdr_id IN NUMBER)
        IS
        SELECT period_type, period_start, price_uom
        FROM   oks_k_headers_b
        WHERE  chr_id = p_hdr_id;

    CURSOR get_gcd_org_period_val (p_org_id IN VARCHAR2)
        IS
        SELECT period_type, period_start, price_uom
        FROM   oks_k_defaults
        WHERE  cdt_type = 'SDT'
        AND   segment_id1 = p_org_id;

    CURSOR get_gcd_glob_period_val
        IS
        SELECT period_type, period_start, price_uom
        FROM   oks_k_defaults
        WHERE  cdt_type = 'MDT'
        AND   segment_id1 IS NULL;

    l_period_type oks_k_defaults.period_type%TYPE;
    l_period_start oks_k_defaults.period_start%TYPE;
    l_price_uom oks_k_defaults.price_uom%TYPE;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF p_hdr_id IS NOT NULL
            THEN
            OPEN get_hdr_period_val(p_hdr_id);
            FETCH get_hdr_period_val INTO l_period_type, l_period_start, l_price_uom;
            CLOSE get_hdr_period_val;
        ELSE
 -- If hdr_id is null, then values are taken from GCD
            IF p_org_id IS NOT NULL
                THEN
                OPEN get_gcd_org_period_val(p_org_id);
                FETCH get_gcd_org_period_val INTO l_period_type, l_period_start, l_price_uom;
                CLOSE get_gcd_org_period_val;

                --anjkumar PP CR002, both period type and period start should be defined
                --at any level for it to be considered

                --IF (l_period_type IS NULL) AND (l_period_start IS NULL)
                IF (l_period_type IS NULL) OR (l_period_start IS NULL)
                    THEN
                    OPEN get_gcd_glob_period_val;
                    FETCH get_gcd_glob_period_val INTO l_period_type, l_period_start, l_price_uom;
                    CLOSE get_gcd_glob_period_val;
                END IF;
            ELSE
                OPEN get_gcd_glob_period_val;
                FETCH get_gcd_glob_period_val INTO l_period_type, l_period_start, l_price_uom;
                CLOSE get_gcd_glob_period_val;
            END IF;
        END IF;

        --if both period type and period start have to be not null to consider it
        IF (l_period_type IS NULL) OR (l_period_start IS NULL) THEN
            x_period_type := NULL;
            x_period_start := NULL;
            x_price_uom := NULL;
        ELSE
            x_period_type := l_period_type;
            x_period_start := l_period_start;
            x_price_uom := l_price_uom;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;

    END get_period_defaults;

    /*
    -------------------------------------------------------------------------
    rewritten R12 traversal api that fetches all the rules from gcd
    following the hierarchy - input->contract->party->org->global

    it recoginzes the new attributes introduced forRr12, groups
    interdependent attributes from the same level and improves
    performance and logging.
    -------------------------------------------------------------------------
    */
    PROCEDURE get_renew_rules(x_return_status OUT NOCOPY VARCHAR2,
                              p_api_version IN NUMBER DEFAULT 1,
                              p_init_msg_list IN VARCHAR2 DEFAULT FND_API.g_false,
                              p_chr_id IN NUMBER,
                              p_party_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_date IN DATE DEFAULT SYSDATE,
                              p_rnrl_rec IN rnrl_rec_type,
                              x_rnrl_rec OUT NOCOPY rnrl_rec_type,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
    IS

    TYPE rnrl_rec_tbl_type IS TABLE OF rnrl_rec_type INDEX BY BINARY_INTEGER;

    l_api_name CONSTANT VARCHAR2(30) := 'GET_RENEW_RULES';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;

    l_party_id NUMBER;
    l_org_id NUMBER;
    l_k_org_id NUMBER; --to store the contract org id, if p_org_id not passed

    lk_rnrl_rec rnrl_rec_type;
    l_rules_tbl_tmp rnrl_rec_tbl_type; -- temp table to store output of bulk collect
    l_rules_tbl rnrl_rec_tbl_type; -- table to store all the rules in the correct order -> input, contract, party, org, global

    l_effective_base_currency VARCHAR2(30);
    l_error_text VARCHAR2(512);

    CURSOR c_k_party(cp_chr_id IN NUMBER) IS
        SELECT object1_id1  FROM okc_k_party_roles_b
        WHERE dnz_chr_id = cp_chr_id
        AND cle_id IS NULL
        AND jtot_object1_code = 'OKX_PARTY'
        AND rle_code  IN ('CUSTOMER', 'SUBSCRIBER');

    CURSOR c_k_rules(cp_chr_id IN NUMBER) IS
        SELECT a.renewal_type_code,
            b.renewal_pricing_type, b.renewal_markup_percent, b.renewal_price_list,
            b.renewal_po_required,
            b.renewal_est_rev_percent, b.renewal_est_rev_duration, b.renewal_est_rev_period,
            b.billing_profile_id, b.renewal_grace_duration, b.renewal_grace_period,
            a.currency_code, a.approval_type, nvl(a.org_id, a.authoring_org_id)
        FROM okc_k_headers_all_b a, oks_k_headers_b b
        WHERE a.id = cp_chr_id AND a.id = b.chr_id;

    --cp_org_id the org for which the rules need to be obtained, can be null
    --cp_party_id the party for which the rules need to be obtained, can be null
    --cp_date the date on which the rule should be effective, should not be null
    --cursor will always return 1 record and at max return 3 records
    CURSOR c_cgd_rules(cp_org_id IN NUMBER, cp_party_id IN NUMBER, cp_date IN DATE) IS
        SELECT
            cdt_type,
            jtot_object_code,
            renewal_type,
            renewal_pricing_type,
            markup_percent,
            price_list_id1,
            price_list_id2,
            pdf_id,
            qcl_id,
            cgp_new_id,
            cgp_renew_id,
            po_required_yn,
            credit_amount,
            rle_code,
            revenue_estimated_percent,
            revenue_estimated_duration,
            revenue_estimated_period,
            NULL,  --function_name,
            NULL,  -- salesrep_name
            template_set_id,
            base_currency,  --threshold_currency, col obsolete
            threshold_amount,
            email_address,
            billing_profile_id,
            user_id,
            threshold_enabled_yn,
            grace_period,
            grace_duration,
            payment_terms_id1,
            payment_terms_id2,
            base_currency,  --evergreen_threshold_curr, col obsolete
            evergreen_threshold_amt,
            payment_method,
            base_currency,  --payment_threshold_curr, col obsolete
            payment_threshold_amt,
            interface_price_break,
            base_currency,
            approval_type,
            evergreen_approval_type,
            online_approval_type,
            purchase_order_flag,
            credit_card_flag,
            wire_flag,
            commitment_number_flag,
            check_flag,
            period_type,
            period_start,
            price_uom,
            template_language
            FROM oks_k_defaults
            WHERE
                (cdt_type = 'MDT' AND jtot_object_code IS NULL AND segment_id1 IS NULL AND segment_id2 IS NULL)
                OR
                (cdt_type = 'SDT' AND jtot_object_code = 'OKX_OPERUNIT' AND segment_id1 = to_char(cp_org_id) AND segment_id2 = '#'
                 AND trunc(cp_date) BETWEEN start_date AND nvl(end_date, greatest(start_date, trunc(cp_date))))
                OR
                (cdt_type = 'SDT' AND jtot_object_code = 'OKX_PARTY' AND segment_id1 = to_char(cp_party_id) AND segment_id2 = '#'
                 AND trunc(cp_date) BETWEEN start_date AND nvl(end_date, greatest(start_date, trunc(cp_date))));


    --this procedure sets the interdependent and dependent attributes.
    --using the hierarchy - input->contract->party->org->global. for
    --interdependent attributes all rules are fetched from the same level
    --for e.g., if grace period is set at party level
    --we should get the grace duration from the same level and not the org level
    --even if party level grace duration is null
    PROCEDURE set_attributes
    IS
    BEGIN
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.set_attributes.begin', 'begin');
            END IF;
        END IF;

        -- assume that l_rules_tbl(0) has input rules, l_rules_tbl(1) has contract rules, l_rules_tbl(2) has party rules etc
        FOR i IN l_rules_tbl.first..l_rules_tbl.last LOOP

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.set_attributes.for_loop', 'i=' || i);
                END IF;
            END IF;

            --first set the interdependent attributes
            --renewal type and approval type
            IF (x_rnrl_rec.renewal_type IS NULL) THEN
                x_rnrl_rec.renewal_type := l_rules_tbl(i).renewal_type;
                IF (x_rnrl_rec.renewal_type IS NOT NULL) THEN
                    x_rnrl_rec.approval_type := l_rules_tbl(i).approval_type;
                END IF;
            END IF;

            --renewal pricing_type, markup percent, price list
            IF (x_rnrl_rec.renewal_pricing_type IS NULL) THEN
                x_rnrl_rec.renewal_pricing_type := l_rules_tbl(i).renewal_pricing_type;
                IF (x_rnrl_rec.renewal_pricing_type IS NOT NULL) THEN
                    x_rnrl_rec.markup_percent := l_rules_tbl(i).markup_percent;
                    x_rnrl_rec.price_list_id1 := l_rules_tbl(i).price_list_id1;
                    x_rnrl_rec.price_list_id2 := l_rules_tbl(i).price_list_id2;
                END IF;
            END IF;

            --revenue estimated percent, duration and period
            IF (x_rnrl_rec.revenue_estimated_percent IS NULL) THEN
                x_rnrl_rec.revenue_estimated_percent := l_rules_tbl(i).revenue_estimated_percent;
                IF (x_rnrl_rec.revenue_estimated_percent IS NOT NULL) THEN
                    x_rnrl_rec.revenue_estimated_duration := l_rules_tbl(i).revenue_estimated_duration;
                    x_rnrl_rec.revenue_estimated_period := l_rules_tbl(i).revenue_estimated_period;
                END IF;
            END IF;

            --grace period and duration
            IF (x_rnrl_rec.grace_period IS NULL) THEN
                x_rnrl_rec.grace_period := l_rules_tbl(i).grace_period;
                IF (x_rnrl_rec.grace_period IS NOT NULL) THEN
                    x_rnrl_rec.grace_duration := l_rules_tbl(i).grace_duration;
                END IF;
            END IF;

            --partial period type, start and uom
            IF (x_rnrl_rec.period_type IS NULL) THEN
                x_rnrl_rec.period_type := l_rules_tbl(i).period_type;
                IF (x_rnrl_rec.period_type IS NOT NULL) THEN
                    x_rnrl_rec.period_start := l_rules_tbl(i).period_start;
                    x_rnrl_rec.price_uom := l_rules_tbl(i).price_uom;

                    --anjkumar both period type and period start have to be not null, otherwise we should ignore
                    --the values at this level, Partial Period Change request CR 002
                    IF (x_rnrl_rec.period_start IS NULL) THEN
                        x_rnrl_rec.period_type := NULL;
                        x_rnrl_rec.period_start := NULL;
                        x_rnrl_rec.price_uom := NULL;
                    END IF;

                END IF;
            END IF;

            --payment terms id1 and id2
            IF (x_rnrl_rec.payment_terms_id1 IS NULL) THEN
                x_rnrl_rec.payment_terms_id1 := l_rules_tbl(i).payment_terms_id1;
                IF (x_rnrl_rec.payment_terms_id1 IS NOT NULL) THEN
                    x_rnrl_rec.payment_terms_id2 := l_rules_tbl(i).payment_terms_id2;
                END IF;
            END IF;

            --helpdesk user id and email
            IF (x_rnrl_rec.user_id IS NULL) THEN
                x_rnrl_rec.user_id := l_rules_tbl(i).user_id;
                IF (x_rnrl_rec.user_id IS NOT NULL) THEN
                    x_rnrl_rec.email_address := l_rules_tbl(i).email_address;
                END IF;
            END IF;

            --get the base currency level
            IF (x_rnrl_rec.base_currency IS NULL) THEN
                x_rnrl_rec.base_currency := l_rules_tbl(i).base_currency;
                IF (x_rnrl_rec.base_currency IS NOT NULL) THEN
                    l_effective_base_currency := x_rnrl_rec.base_currency;
                END IF;
            END IF;

            --set the currency dependent attributes
            --special handling for curremcy dependent attributes
            --for e.g., if contract currency is usd, and party level currency is eur and org level currency
            --is usd, we should get the threshold amounts from org level and not party level

            --evergreen threshold amt, evergreen threshold curr, evergreen approval type
            IF (x_rnrl_rec.evergreen_threshold_amt IS NULL) THEN

                IF(l_rules_tbl(i).evergreen_threshold_amt IS NOT NULL AND
                   nvl(l_rules_tbl(i).base_currency, 'X') = l_effective_base_currency) THEN
                    x_rnrl_rec.evergreen_threshold_amt := l_rules_tbl(i).evergreen_threshold_amt;
                    x_rnrl_rec.evergreen_threshold_curr := l_rules_tbl(i).base_currency;
                    x_rnrl_rec.evergreen_approval_type := l_rules_tbl(i).evergreen_approval_type;
                END IF;

            END IF;

            --online threshold amt, online threshold curr, online approval type
            IF (x_rnrl_rec.threshold_amount IS NULL) THEN

                IF(l_rules_tbl(i).threshold_amount IS NOT NULL AND
                   nvl(l_rules_tbl(i).base_currency, 'X') = l_effective_base_currency) THEN
                    x_rnrl_rec.threshold_amount := l_rules_tbl(i).threshold_amount;
                    x_rnrl_rec.threshold_currency := l_rules_tbl(i).base_currency;
                    x_rnrl_rec.online_approval_type := l_rules_tbl(i).online_approval_type;
                END IF;

            END IF;

            --payment threshold amt, paymnet threshold curr
            IF (x_rnrl_rec.payment_threshold_amt IS NULL) THEN

                IF(l_rules_tbl(i).payment_threshold_amt IS NOT NULL AND
                   nvl(l_rules_tbl(i).base_currency, 'X') = l_effective_base_currency) THEN
                    x_rnrl_rec.payment_threshold_amt := l_rules_tbl(i).payment_threshold_amt;
                    x_rnrl_rec.payment_threshold_curr := l_rules_tbl(i).base_currency;
                END IF;

            END IF;

            --set the remaining independent attributes
            IF (x_rnrl_rec.pdf_id IS NULL) THEN
                x_rnrl_rec.pdf_id := l_rules_tbl(i).pdf_id;
            END IF;

            IF (x_rnrl_rec.qcl_id IS NULL) THEN
                x_rnrl_rec.qcl_id := l_rules_tbl(i).qcl_id;
            END IF;

            IF (x_rnrl_rec.cgp_new_id IS NULL) THEN
                x_rnrl_rec.cgp_new_id := l_rules_tbl(i).cgp_new_id;
            END IF;

            IF (x_rnrl_rec.cgp_renew_id IS NULL) THEN
                x_rnrl_rec.cgp_renew_id := l_rules_tbl(i).cgp_renew_id;
            END IF;

            IF (x_rnrl_rec.po_required_yn IS NULL) THEN
                x_rnrl_rec.po_required_yn := l_rules_tbl(i).po_required_yn;
            END IF;

            IF (x_rnrl_rec.credit_amount IS NULL) THEN
                x_rnrl_rec.credit_amount := l_rules_tbl(i).credit_amount;
            END IF;

            IF (x_rnrl_rec.rle_code IS NULL) THEN
                x_rnrl_rec.rle_code := l_rules_tbl(i).rle_code;
            END IF;

            IF (x_rnrl_rec.template_set_id IS NULL) THEN
                x_rnrl_rec.template_set_id := l_rules_tbl(i).template_set_id;
            END IF;

            IF (x_rnrl_rec.billing_profile_id IS NULL) THEN
                x_rnrl_rec.billing_profile_id := l_rules_tbl(i).billing_profile_id;
            END IF;

            IF (x_rnrl_rec.threshold_enabled_yn IS NULL) THEN
                x_rnrl_rec.threshold_enabled_yn := l_rules_tbl(i).threshold_enabled_yn;
            END IF;

            IF (x_rnrl_rec.payment_method IS NULL) THEN
                x_rnrl_rec.payment_method := l_rules_tbl(i).payment_method;
            END IF;

            IF (x_rnrl_rec.interface_price_break IS NULL) THEN
                x_rnrl_rec.interface_price_break := l_rules_tbl(i).interface_price_break;
            END IF;

            IF (x_rnrl_rec.template_language IS NULL) THEN
                x_rnrl_rec.template_language := l_rules_tbl(i).template_language;
            END IF;

            IF (x_rnrl_rec.purchase_order_flag IS NULL) THEN
                x_rnrl_rec.purchase_order_flag := l_rules_tbl(i).purchase_order_flag;
            END IF;

            IF (x_rnrl_rec.credit_card_flag IS NULL) THEN
                x_rnrl_rec.credit_card_flag := l_rules_tbl(i).credit_card_flag;
            END IF;

            IF (x_rnrl_rec.wire_flag IS NULL) THEN
                x_rnrl_rec.wire_flag := l_rules_tbl(i).wire_flag;
            END IF;

            IF (x_rnrl_rec.wire_flag IS NULL) THEN
                x_rnrl_rec.wire_flag := l_rules_tbl(i).wire_flag;
            END IF;

            IF (x_rnrl_rec.commitment_number_flag IS NULL) THEN
                x_rnrl_rec.commitment_number_flag := l_rules_tbl(i).commitment_number_flag;
            END IF;

            IF (x_rnrl_rec.check_flag IS NULL) THEN
                x_rnrl_rec.check_flag := l_rules_tbl(i).check_flag;
            END IF;

            IF (x_rnrl_rec.function_name IS NULL) THEN
                x_rnrl_rec.function_name := l_rules_tbl(i).function_name;
            END IF;

            IF (x_rnrl_rec.salesrep_name IS NULL) THEN
                x_rnrl_rec.salesrep_name := l_rules_tbl(i).salesrep_name;
            END IF;

        END LOOP;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.set_attributes.end', 'end');
            END IF;
        END IF;

    END set_attributes;

    BEGIN
        --main procedure begins here

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id ||' ,p_party_id='|| p_party_id ||' ,p_org_id='|| p_org_id || ',p_date=' || p_date);
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.input_rules', 'see following log');
                log_rules(l_mod_name || '.input_rules', p_rnrl_rec);
            END IF;
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --basic parameter validation
        IF ((p_chr_id IS NULL OR p_chr_id = FND_API.G_MISS_NUM) AND
            (p_party_id IS NULL OR p_party_id = FND_API.G_MISS_NUM) AND
            (p_org_id IS NULL OR p_org_id = FND_API.G_MISS_NUM)) THEN

            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_REN_RUL_INV_ARG');
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation', FALSE);
            END IF;
            FND_MSG_PUB.ADD;

            RAISE FND_API.g_exc_error;
        END IF;

        --initialize the rules table
        l_rules_tbl(G_INPUT_LEVEL) := p_rnrl_rec;
        l_rules_tbl(G_CONTRACT_LEVEL) := NULL;
        l_rules_tbl(G_PARTY_LEVEL) := NULL;
        l_rules_tbl(G_ORG_LEVEL) := NULL;
        l_rules_tbl(G_GLOBAL_LEVEL) := NULL;

        --get the party id and org id from the input or from the contract
        l_party_id := p_party_id;
        l_org_id := p_org_id;


        --get the contract party, org and the contract level rules if p_chr_id is passed
        IF(p_chr_id IS NOT NULL) THEN

            -- if contract party id is not passed get it from okc_k_party_roles_b
            IF (l_party_id IS NULL) THEN
                OPEN c_k_party(p_chr_id);
                FETCH c_k_party INTO l_party_id;
                CLOSE c_k_party;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_party', 'l_party_id=' || l_party_id);
                    END IF;
                END IF;

            END IF;

            --get the contract attributes from okc_k_headers_all_b and oks_k_headers_b
            --also get the contract org id, use this if p_org_id is not passed
            OPEN c_k_rules(p_chr_id);
            FETCH c_k_rules INTO lk_rnrl_rec.renewal_type,
            lk_rnrl_rec.renewal_pricing_type, lk_rnrl_rec.markup_percent, lk_rnrl_rec.price_list_id1,
            lk_rnrl_rec.po_required_yn,
            lk_rnrl_rec.revenue_estimated_percent, lk_rnrl_rec.revenue_estimated_duration, lk_rnrl_rec.revenue_estimated_period,
            lk_rnrl_rec.billing_profile_id, lk_rnrl_rec.grace_duration, lk_rnrl_rec.grace_period,
            lk_rnrl_rec.base_currency, lk_rnrl_rec.approval_type, l_k_org_id;

            IF (c_k_rules%notfound) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
                FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_k_rules', FALSE);
                END IF;
                FND_MSG_PUB.ADD;
                CLOSE c_k_rules;
                RAISE FND_API.g_exc_error;
            END IF;
            CLOSE c_k_rules;

            --if p_org_id is not passed use the contract org id
            IF (l_org_id IS NULL) THEN
                l_org_id := l_k_org_id;
            END IF;

            IF (lk_rnrl_rec.price_list_id1 IS NOT NULL) THEN
                lk_rnrl_rec.price_list_id2 := '#';
            END IF;
            l_rules_tbl(G_CONTRACT_LEVEL) := lk_rnrl_rec;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_org', 'l_org_id=' || l_org_id);
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.contract_level_rules', 'see following log');
                    log_rules(l_mod_name || '.contract_level_rules', l_rules_tbl(G_CONTRACT_LEVEL));
                END IF;
            END IF;

        END IF; -- of if(p_chr_id is not null) then

        --get the party, org and global level rules
        --this cursor will fetch at max 3 records
        OPEN c_cgd_rules(l_org_id, l_party_id, nvl(p_date, SYSDATE));
        FETCH c_cgd_rules BULK COLLECT INTO l_rules_tbl_tmp;
        CLOSE c_cgd_rules;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.get_gcd_rules', 'gcd_record_count=' || l_rules_tbl_tmp.COUNT);
            END IF;
        END IF;

        --assign the rules table
        FOR i IN l_rules_tbl_tmp.first..l_rules_tbl_tmp.last LOOP
            IF (l_rules_tbl_tmp(i).cdt_type = 'MDT') THEN
                l_rules_tbl(G_GLOBAL_LEVEL) := l_rules_tbl_tmp(i);
            ELSIF (l_rules_tbl_tmp(i).cdt_type = 'SDT' AND l_rules_tbl_tmp(i).jtot_object_code = 'OKX_OPERUNIT') THEN
                l_rules_tbl(G_ORG_LEVEL) := l_rules_tbl_tmp(i);
            ELSIF (l_rules_tbl_tmp(i).cdt_type = 'SDT' AND l_rules_tbl_tmp(i).jtot_object_code = 'OKX_PARTY') THEN
                l_rules_tbl(G_PARTY_LEVEL) := l_rules_tbl_tmp(i);
            END IF;
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.gcd_loop', 'cdt_type=' || l_rules_tbl_tmp(i).cdt_type ||' , jtot_object_code'|| l_rules_tbl_tmp(i).jtot_object_code);
                END IF;
            END IF;
        END LOOP;
        l_rules_tbl_tmp.DELETE;

        --log all the rules fetched if debug logging enabled
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.party_level_rules', 'see following log');
                log_rules(l_mod_name || '.party_level_rules', l_rules_tbl(G_PARTY_LEVEL));
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.org_level_rules', 'see following log');
                log_rules(l_mod_name || '.org_level_rules', l_rules_tbl(G_ORG_LEVEL));
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.global_level_rules', 'see following log');
                log_rules(l_mod_name || '.global_level_rules', l_rules_tbl(G_GLOBAL_LEVEL));
            END IF;
        END IF;

        --set the attributes
        set_attributes;

        l_rules_tbl.DELETE;


        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.effective_rules', 'see following log');
                log_rules(l_mod_name || '.effective_rules', x_rnrl_rec);
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.end', 'x_return_status=' || x_return_status);
            END IF;
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party%isopen) THEN
                CLOSE c_k_party;
            END IF;
            IF (c_k_rules%isopen) THEN
                CLOSE c_k_rules;
            END IF;
            IF (c_cgd_rules%isopen) THEN
                CLOSE c_cgd_rules;
            END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party%isopen) THEN
                CLOSE c_k_party;
            END IF;
            IF (c_k_rules%isopen) THEN
                CLOSE c_k_rules;
            END IF;
            IF (c_cgd_rules%isopen) THEN
                CLOSE c_cgd_rules;
            END IF;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text );
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party%isopen) THEN
                CLOSE c_k_party;
            END IF;
            IF (c_k_rules%isopen) THEN
                CLOSE c_k_rules;
            END IF;
            IF (c_cgd_rules%isopen) THEN
                CLOSE c_cgd_rules;
            END IF;

    END get_renew_rules;

    -- this procedures logs all the rule attributes in the FND_LOG_messages table
    -- use only after checking the log level
    PROCEDURE log_rules(p_module IN VARCHAR2,
                        p_rnrl_rec IN rnrl_rec_type)
    IS
    l_api_name VARCHAR2(30) := 'LOG_RULES';
    l_mod_name VARCHAR2(256) := nvl(p_module, lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name);
    BEGIN
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'renewal_type=' || p_rnrl_rec.renewal_type ||' ,approval_type='|| p_rnrl_rec.approval_type);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'period_type='|| p_rnrl_rec.period_type ||' ,period_start='|| p_rnrl_rec.period_start ||' ,price_uom='|| p_rnrl_rec.price_uom);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'base_currency=' || p_rnrl_rec.base_currency ||' ,evergreen_threshold_amt='|| p_rnrl_rec.evergreen_threshold_amt ||' ,evergreen_approval_type='|| p_rnrl_rec.evergreen_approval_type);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'threshold(online)_amount='|| p_rnrl_rec.threshold_amount ||' ,online_approval_type='|| p_rnrl_rec.online_approval_type ||'  ,payment_threshold_amt='|| p_rnrl_rec.payment_threshold_amt);
            FND_LOG.string(FND_LOG.level_statement,l_mod_name,'evn_threshold_curr='|| p_rnrl_rec.evergreen_threshold_curr||' ,online_curr='|| p_rnrl_rec.threshold_currency ||' ,payment_threshold_curr='|| p_rnrl_rec.payment_threshold_curr||
            ' ,threshold(online)_enabled_yn='||p_rnrl_rec.threshold_enabled_yn);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'ren_pricing_type=' || p_rnrl_rec.renewal_pricing_type ||' , markup_pct='|| p_rnrl_rec.markup_percent ||' ,pl_id1='|| p_rnrl_rec.price_list_id1 ||' ,pl_id2='|| p_rnrl_rec.price_list_id2);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'rev_est_pct=' || p_rnrl_rec.revenue_estimated_percent ||' ,rev_est_duration='|| p_rnrl_rec.revenue_estimated_duration ||' ,rev_est_period='|| p_rnrl_rec.revenue_estimated_period);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'grace_period='|| p_rnrl_rec.grace_period ||' ,grace_duration='|| p_rnrl_rec.grace_duration);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'pdf_id=' || p_rnrl_rec.pdf_id ||' ,qcl_id='|| p_rnrl_rec.qcl_id ||' ,cgp_new_id='|| p_rnrl_rec.cgp_new_id ||' ,cgp_renew_id='|| p_rnrl_rec.cgp_renew_id);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'credit_amt='|| p_rnrl_rec.credit_amount ||' ,rle_code='|| p_rnrl_rec.rle_code ||' template_set_id='|| p_rnrl_rec.template_set_id ||' ,template_language='|| p_rnrl_rec.template_language);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'user_id=' || p_rnrl_rec.user_id ||' ,email_address='|| p_rnrl_rec.email_address);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'billing_profile_id='|| p_rnrl_rec.billing_profile_id ||' ,interface_price_break='|| p_rnrl_rec.interface_price_break);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'po_required_yn=' || p_rnrl_rec.po_required_yn||' ,payment_terms_id1='|| p_rnrl_rec.payment_terms_id1 ||' ,payment_terms_id2='|| p_rnrl_rec.payment_terms_id2);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'po_flag='|| p_rnrl_rec.purchase_order_flag ||' ,cc_flag='|| p_rnrl_rec.credit_card_flag);
            FND_LOG.string(FND_LOG.level_statement, l_mod_name,'wire_flag='|| p_rnrl_rec.wire_flag ||' ,com_flag='|| p_rnrl_rec.commitment_number_flag ||' ,check_flag='|| p_rnrl_rec.check_flag);
        END IF;
    END log_rules;


    /* stripped down version of get_renew_rules, only gets the template set id and template lang */
    PROCEDURE get_template_set(p_api_version IN NUMBER DEFAULT 1,
                               p_init_msg_list IN VARCHAR2 DEFAULT FND_API.g_false,
                               p_chr_id IN NUMBER,
                               x_template_set_id OUT NOCOPY NUMBER,
                               x_template_lang OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2)
    IS

    TYPE l_tset_rec IS RECORD(
                              cdt_type oks_k_defaults.cdt_type%TYPE,
                              jtot_object_code oks_k_defaults.jtot_object_code%TYPE,
                              template_set_id oks_k_defaults.template_set_id%TYPE,
                              template_language oks_k_defaults.template_language%TYPE);

    TYPE l_tset_tbl_type IS TABLE OF l_tset_rec INDEX BY BINARY_INTEGER;

    l_api_name CONSTANT VARCHAR2(30) := 'GET_TEMPLATE_SET';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;

    l_party_id NUMBER;
    l_org_id NUMBER;
    l_tset_tbl_tmp l_tset_tbl_type;
    l_tset_tbl l_tset_tbl_type;

    l_error_text VARCHAR2(512);

    --should be outer join with party roles, so that
    --if we don't get a party we atleast get an org
    CURSOR c_k_party_org(cp_chr_id IN NUMBER) IS
        SELECT b.object1_id1, a.authoring_org_id
        FROM okc_k_headers_all_b a LEFT OUTER JOIN okc_k_party_roles_b b
        ON a.id = b.dnz_chr_id AND b.cle_id IS NULL AND b.jtot_object1_code = 'OKX_PARTY'
            AND b.rle_code  IN ('CUSTOMER', 'SUBSCRIBER')
        WHERE  a.id = cp_chr_id;


    --cp_org_id the org for which the rules need to be obtained, can be null
    --cp_party_id the party for which the rules need to be obtained, can be null
    --cp_date the date on which the rule should be effective, should not be null
    -- cursor will always return 1 record and at max return 3 records
    CURSOR c_cgd_template_set(cp_org_id IN NUMBER, cp_party_id IN NUMBER, cp_date IN DATE) IS
        SELECT
            cdt_type, jtot_object_code, template_set_id, template_language
            FROM oks_k_defaults
            WHERE
                (cdt_type = 'MDT' AND jtot_object_code IS NULL AND segment_id1 IS NULL AND segment_id2 IS NULL)
                OR
                (cdt_type = 'SDT' AND jtot_object_code = 'OKX_OPERUNIT' AND segment_id1 = to_char(cp_org_id) AND segment_id2 = '#'
                 AND trunc(cp_date) BETWEEN start_date AND nvl(end_date, greatest(start_date, trunc(cp_date))))
                OR
                (cdt_type = 'SDT' AND jtot_object_code = 'OKX_PARTY' AND segment_id1 = to_char(cp_party_id) AND segment_id2 = '#'
                 AND trunc(cp_date) BETWEEN start_date AND nvl(end_date, greatest(start_date, trunc(cp_date))));


    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
            END IF;
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_template_set_id := NULL;
        x_template_lang := NULL;

        OPEN c_k_party_org(p_chr_id);
        FETCH c_k_party_org INTO l_party_id, l_org_id;
        IF (c_k_party_org%notfound) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_k_org', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            CLOSE c_k_party_org;
            RAISE FND_API.g_exc_error;
        END IF;
        CLOSE c_k_party_org;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.party_org', 'l_party_id=' || l_party_id ||' , l_org_id'|| l_org_id);
            END IF;
        END IF;

        --get the party, org and global level rules
        --this cursor will fetch at max 3 records
        OPEN c_cgd_template_set(l_org_id, l_party_id, SYSDATE);
        FETCH c_cgd_template_set BULK COLLECT INTO l_tset_tbl_tmp;
        CLOSE c_cgd_template_set;

        --assign the rules table
        FOR i IN l_tset_tbl_tmp.first..l_tset_tbl_tmp.last LOOP
            IF (l_tset_tbl_tmp(i).cdt_type = 'MDT') THEN
                l_tset_tbl(G_GLOBAL_LEVEL) := l_tset_tbl_tmp(i);
            ELSIF (l_tset_tbl_tmp(i).cdt_type = 'SDT' AND l_tset_tbl_tmp(i).jtot_object_code = 'OKX_OPERUNIT') THEN
                l_tset_tbl(G_ORG_LEVEL) := l_tset_tbl_tmp(i);
            ELSIF (l_tset_tbl_tmp(i).cdt_type = 'SDT' AND l_tset_tbl_tmp(i).jtot_object_code = 'OKX_PARTY') THEN
                l_tset_tbl(G_PARTY_LEVEL) := l_tset_tbl_tmp(i);
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                IF (FND_LOG.test(FND_LOG.level_statement, l_mod_name)) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.gcd_loop', 'cdt_type=' || l_tset_tbl_tmp(i).cdt_type ||' , jtot_object_code'|| l_tset_tbl_tmp(i).jtot_object_code);
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.gcd_loop','template_set_id='|| l_tset_tbl_tmp(i).template_set_id ||' ,template_language='|| l_tset_tbl_tmp(i).template_language);
                END IF;
            END IF;
        END LOOP;
        l_tset_tbl_tmp.DELETE;

        FOR i IN l_tset_tbl.first..l_tset_tbl.last LOOP

            IF(x_template_set_id IS NULL) THEN
                x_template_set_id := l_tset_tbl(i).template_set_id;
            END IF;

            IF(x_template_lang IS NULL) THEN
                x_template_lang := l_tset_tbl(i).template_language;
            END IF;

        END LOOP;
        l_tset_tbl.DELETE;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end','x_template_set_id ='|| x_template_set_id ||', x_return_status='|| x_return_status);
            END IF;
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION

        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party_org%isopen) THEN
                CLOSE c_k_party_org;
            END IF;
            IF (c_cgd_template_set%isopen) THEN
                CLOSE c_cgd_template_set;
            END IF;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party_org%isopen) THEN
                CLOSE c_k_party_org;
            END IF;
            IF (c_cgd_template_set%isopen) THEN
                CLOSE c_cgd_template_set;
            END IF;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_party_org%isopen) THEN
                CLOSE c_k_party_org;
            END IF;
            IF (c_cgd_template_set%isopen) THEN
                CLOSE c_cgd_template_set;
            END IF;

    END get_template_set;


    /* utility function to get template set id */
    FUNCTION get_template_set_id(p_chr_id IN NUMBER
                                 ) RETURN NUMBER
    IS

    l_template_set_id NUMBER := NULL;
    l_template_lang VARCHAR2(5) := NULL;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);

    BEGIN
        get_template_set(p_api_version => 1,
                         p_init_msg_list => FND_API.G_FALSE,
                         p_chr_id => p_chr_id,
                         x_template_set_id => l_template_set_id,
                         x_template_lang => l_template_lang,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);
        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        RETURN l_template_set_id;

    END get_template_set_id;

    /* utility function to get template set lang */
    FUNCTION get_template_lang(p_chr_id IN NUMBER
                               ) RETURN VARCHAR2
    IS

    l_template_set_id NUMBER := NULL;
    l_template_lang VARCHAR2(5) := NULL;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);

    BEGIN
        get_template_set(p_api_version => 1,
                         p_init_msg_list => FND_API.G_FALSE,
                         p_chr_id => p_chr_id,
                         x_template_set_id => l_template_set_id,
                         x_template_lang => l_template_lang,
                         x_return_status => l_return_status,
                         x_msg_count => l_msg_count,
                         x_msg_data => l_msg_data);

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        RETURN l_template_lang;

    END get_template_lang;

    /*
    Procedure evaluates the renewal rules setup in Contract or GCD to determine
    the effective renewal type for a contract.

    Parameters
        p_chr_id        :   id of the contract whose renewal type needs to be determined, mandatory
        p_amount        :   contract amount, optional, if not passed derived from p_chr_id
        p_currency_code :   contract currency, optional, if not passed derived from p_chr_id
        p_rnrl_rec      :   record containing the effective renewal rules for the contract,
                            optional, if not populated, derived from p_chr_id
        x_renewal_type  :   renewal type as determined
        x_approval_type :   approval type associated with the renewal type
        x_threshold_used :  Y|N flag indicating, if GCD thresholds were used to determine the renewal type
    */
    PROCEDURE GET_RENEWAL_TYPE
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_amount IN NUMBER DEFAULT NULL,
     p_currency_code IN VARCHAR2 DEFAULT NULL,
     p_rnrl_rec IN rnrl_rec_type DEFAULT NULL,
     x_renewal_type OUT NOCOPY VARCHAR2,
     x_approval_type OUT NOCOPY VARCHAR2,
     x_threshold_used OUT NOCOPY VARCHAR2
    )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_RENEWAL_TYPE';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    CURSOR c_k_hdr(cp_chr_id IN NUMBER) IS
        SELECT estimated_amount, currency_code, start_date
        FROM okc_k_headers_all_b
        WHERE id = cp_chr_id;

    l_amount            NUMBER;
    l_currency_code     VARCHAR2(15);
    l_start_date        DATE;
    l_rnrl_rec          OKS_RENEW_UTIL_PVT.rnrl_rec_type;

    BEGIN
        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_api_version=' || p_api_version ||' ,p_chr_id='|| p_chr_id||' ,p_amount='||p_amount||
                ' ,p_currency_code='||p_currency_code||' ,p_rnrl_rec.base_currency='||p_rnrl_rec.base_currency);
            END IF;
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --basic input validation
        IF(p_chr_id IS NULL) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_MANDATORY_ARG');
            FND_MESSAGE.set_token('ARG_NAME', 'p_chr_id');
            FND_MESSAGE.set_token('PROG_NAME', G_PKG_NAME || '.' || l_api_name);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.input_validation', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        --get contract details if they are not passed
        IF ((p_amount IS NULL) OR (p_currency_code IS NULL) OR (p_rnrl_rec.base_currency IS NULL)) THEN

            OPEN c_k_hdr(p_chr_id);
            FETCH c_k_hdr INTO l_amount, l_currency_code, l_start_date;
            CLOSE c_k_hdr;

            --if invalid contract
            IF (l_start_date IS NULL) THEN
                FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
                FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
                IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.message(FND_LOG.level_error, l_mod_name || '.get_k_details', FALSE);
                END IF;
                FND_MSG_PUB.ADD;
                RAISE FND_API.g_exc_error;
            END IF;

            --means the renewal rules are not passed, get them
            IF (p_rnrl_rec.base_currency IS NULL) THEN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.calling_get_renew_rules', 'p_chr_id=' || p_chr_id ||', p_date='|| l_start_date);
                END IF;

                OKS_RENEW_UTIL_PVT.get_renew_rules(
                                x_return_status => x_return_status,
                                p_api_version => 1.0,
                                p_init_msg_list => FND_API.G_FALSE,
                                p_chr_id => p_chr_id,
                                p_party_id => NULL,
                                p_org_id => NULL,
                                p_date => l_start_date,
                                p_rnrl_rec => p_rnrl_rec,
                                x_rnrl_rec => l_rnrl_rec,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_renew_rules', 'x_return_status=' || x_return_status);
                END IF;
                IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                ELSIF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
                END IF;

            END IF; --of IF (p_rnrl_rec.base_currency IS NULL) THEN

        END IF; --of IF ((p_amount IS NULL) OR (p_currency_code IS NULL) OR (p_rnrl_rec.base_currency IS NULL)) THEN

        l_amount := nvl(p_amount, l_amount);
        l_currency_code := nvl(p_currency_code, l_currency_code);
        IF(p_rnrl_rec.base_currency IS NULL) THEN
            NULL;
        ELSE
            l_rnrl_rec := p_rnrl_rec;
        END IF;

        --now determine the effective renewal type
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.renewal_rules', 'l_rnrl_rec.renewal_type='||l_rnrl_rec.renewal_type||' ,l_rnrl_rec.approval_type='||l_rnrl_rec.approval_type||
            ' ,l_rnrl_rec.base_currency='||l_rnrl_rec.base_currency||' ,l_rnrl_rec.evergreen_threshold_amt='||l_rnrl_rec.evergreen_threshold_amt||' ,l_rnrl_rec.evergreen_approval_type='||l_rnrl_rec.evergreen_approval_type||
            ' ,l_rnrl_rec.threshold_amount='||l_rnrl_rec.threshold_amount||' ,l_rnrl_rec.online_approval_type='||l_rnrl_rec.online_approval_type||' ,l_amount='||l_amount||' ,l_currency_code='||l_currency_code);
        END IF;

        --initialize to default value, if GCD not setup
        l_rnrl_rec.renewal_type := nvl(l_rnrl_rec.renewal_type, 'NSR');

        --first check if renewal_type = 'DNR';
        IF(l_rnrl_rec.renewal_type = 'DNR') THEN
            x_renewal_type := 'DNR';
            x_approval_type := NULL;
            x_threshold_used := NULL;
        ELSE

            --first priority given to EVN : evergreen, then ERN : online, then NSR: manual
            --first check if renewal type is EVN
            -- Bug 5859046, don't change renewal type to EVN if evergreen_threshold_amt IS NULL
            IF(l_rnrl_rec.renewal_type = 'EVN') THEN
                x_renewal_type := 'EVN';
                x_approval_type := nvl(l_rnrl_rec.approval_type, 'Y'); --Required
                x_threshold_used := 'N';
            ELSE

                --then check if amount < evergreen threshold
                IF ( (l_currency_code = l_rnrl_rec.base_currency) AND
                    (l_amount <= l_rnrl_rec.evergreen_threshold_amt) ) THEN -- Bug 5859046
                    x_renewal_type := 'EVN';
                    x_approval_type := nvl(l_rnrl_rec.evergreen_approval_type, 'Y'); --Required
                    x_threshold_used := 'Y';
                ELSE

                    --if EVN fails, check if renewal type is ERN
                    -- Bug 5859046, don't change renewal type to ERN if threshold_amount IS NULL
                    IF(l_rnrl_rec.renewal_type = 'ERN') THEN
                        x_renewal_type := 'ERN';
                        x_approval_type := nvl(l_rnrl_rec.approval_type, 'M'); --Manual
                        x_threshold_used := 'N';
                    ELSE
                        --if online renewal threhold is enabled and amount < online threshold
                        IF ((nvl(l_rnrl_rec.threshold_enabled_yn, 'N') = 'Y') AND
                            (l_currency_code = l_rnrl_rec.base_currency) AND
                            (l_amount <= l_rnrl_rec.threshold_amount) ) THEN -- Bug 5859046
                            x_renewal_type := 'ERN';
                            x_approval_type := nvl(l_rnrl_rec.online_approval_type, 'M'); --Manual
                            x_threshold_used := 'Y';
                        ELSE
                            --if both EVN and ERN fail
                            x_renewal_type := 'NSR';
                            x_approval_type := nvl(l_rnrl_rec.approval_type, 'Y'); --Required
                            x_threshold_used := 'N';
                        END IF;
                    END IF;
                END IF;
            END IF; --IF(l_rnrl_rec.renewal_type = 'EVN') THEN
        END IF; --of IF(l_rnrl_rec.renewal_type = 'DNR') THEN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            IF (FND_LOG.test(FND_LOG.level_procedure, l_mod_name)) THEN
                FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', ' x_return_status='|| x_return_status||', x_renewal_type='||x_renewal_type||' ,x_approval_type='||x_approval_type||' ,x_threshold_used='||x_threshold_used);
            END IF;
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF (c_k_hdr%isopen) THEN
                CLOSE c_k_hdr;
            END IF;

    END GET_RENEWAL_TYPE;

--   This API checks if function is accessible under current responsibility.
--   by calling fnd_function.test. This is a wrapper on fnd_function.test
--   parameters
--   function_name - function to test
--   RETURNS
--   Y if function is accessible else N

    FUNCTION get_function_access (p_function_name VARCHAR2)
    return VARCHAR2
    IS
    l_return_val  VARCHAR2(1);

    BEGIN
        IF fnd_function.test(p_function_name, 'Y') THEN
            l_return_val := 'Y';
        ELSE
            l_return_val := 'N';
        END IF;
        return(l_return_val);
    EXCEPTION
    WHEN others THEN
            l_return_val := 'N';
        return(l_return_val);
    END get_function_access;

/*=========================================================================
  API name      : get_language_info
  Type          : Private.
  Function      : This procedure derives the language and territory that
                  will be used to generate message or documents to be sent
                  to customer.
  Pre-reqs      : None.
  Parameters    :
  IN            : p_api_version    IN NUMBER         Required
                     Api version
                : p_init_msg_list  IN VARCHAR2       Required
                     Initialize message stack parameter
                : p_contract_id    IN NUMBER         Required
                     Contract header Id
                : p_document_type  IN VARCHAR2       Required
                     Type of the layout template like Quote, Activation etc
                : p_template_id    IN NUMBER         Required
                     Message layout template id can be passed if available
                     so that external api call is avoided.
                : p_template_language IN VARCHAR2    Required
                     Language defined in GCD if availble to avoid api call
  OUT           : x_fnd_language     OUT VARCHAR2
                     Returns fnd_languages's language code.
                : x_fnd_iso_language OUT  VARCHAR2
                     Returns fnd_language's iso_language
                : x_fnd_iso_territory OUT VARCHAR2
                     Returns fnd_language's iso_territory
                : x_gcd_template_lang    OUT NOCOPY VARCHAR2
                     Returns language defined in GCD
                : x_return_status  OUT  VARCHAR2
                     Api return status
                : x_msg_count      OUT  NUMBER
                     Count of message on error stack
                : x_msg_data       OUT  VARCHAR2
                     Actual error messages on error stack
  Note          :
=========================================================================*/
PROCEDURE get_language_info
(
 p_api_version          IN         NUMBER,
 p_init_msg_list        IN         VARCHAR2,
 p_contract_id          IN         NUMBER,
 p_document_type        IN         VARCHAR2  DEFAULT 'QUOTE',
 p_template_id          IN         NUMBER    DEFAULT NULL,
 p_template_language    IN         VARCHAR2  DEFAULT NULL,
 x_fnd_language         OUT NOCOPY VARCHAR2,
 x_fnd_iso_language     OUT NOCOPY VARCHAR2,
 x_fnd_iso_territory    OUT NOCOPY VARCHAR2,
 x_gcd_template_lang    OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
) IS

 l_api_version   CONSTANT NUMBER := 1.0;
 l_api_name      CONSTANT VARCHAR2(50) := 'get_language_info';

 CURSOR l_fnd_lang_terr_csr (p_lang VARCHAR2) IS
 SELECT lower(iso_language), iso_territory
 FROM fnd_languages
 WHERE language_code = p_lang;

--cgopinee bugfix for 6802038
 CURSOR l_template_def_lang_csr (p_template_id NUMBER) IS
 SELECT CASE WHEN a.installed_flag = 'D' THEN 'US' ELSE  a.language_code END language_code,
 CASE WHEN a.installed_flag = 'D' THEN 'en' ELSE b.default_language END default_language,
 CASE WHEN a.installed_flag = 'D' THEN '00' ELSE b.default_territory END default_territory
 FROM fnd_languages a, xdo_templates_b b
 WHERE a.iso_language = upper(b.default_language)
 AND b.template_id = p_template_id
 AND (a.iso_territory = b.default_territory
 OR (b.default_territory = '00' and a.installed_flag IN ('B','I','D')))
 ORDER BY a.installed_flag ASC;

 l_message_template_id    NUMBER;
 l_attachment_template_id NUMBER;
 l_attachment_name        VARCHAR2(150);
 l_k_status               VARCHAR2(30);

BEGIN

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                   'Entered '||G_PKG_NAME ||'.'||l_api_name||
                   '(p_contract_id=>'||p_contract_id||
                   ',p_document_type=>'||p_document_type||
                   ',p_template_id=>'||p_template_id||
                   ',p_template_language=>'||p_template_language||');');
 END IF;

 -- Standard call to check for call compatibility.
 IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- Initialize message list if p_init_msg_list is set to TRUE.
 IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
 END IF;

 --  Initialize API return status to success
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_contract_id IS NULL THEN
    FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
    FND_MESSAGE.SET_TOKEN('HDR_ID',p_contract_id);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- If language is known already, use it to get iso_language and territory
 IF p_template_language IS NOT NULL THEN
   x_fnd_language := p_template_language;
 ELSE
   x_fnd_language := OKS_RENEW_UTIL_PVT.get_template_lang(p_chr_id => p_contract_id);
 END IF;

 -- This is used to get character set in which an email has to be delivered
 x_gcd_template_lang := x_fnd_language;

 -- If you got the language from GCD get iso_language and territory
 IF x_fnd_language IS NOT NULL THEN
   OPEN l_fnd_lang_terr_csr(x_fnd_language);
   FETCH l_fnd_lang_terr_csr INTO x_fnd_iso_language, x_fnd_iso_territory;
   CLOSE l_fnd_lang_terr_csr;
 -- If language is not found in GCD, get layout template to get default language, territory
 ELSE
   IF p_template_id IS NOT NULL THEN
     l_message_template_id := p_template_id;
   ELSE
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                  'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(p_contract_id= '
                  ||p_contract_id||' p_document_type ='||p_document_type||')');
     END IF;
     OKS_TEMPLATE_SET_PUB.get_template_set_dtls
     (
      p_api_version             => p_api_version,
      p_init_msg_list           => p_init_msg_list,
      p_contract_id             => p_contract_id,
      p_document_type           => p_document_type,
      x_template_language       => x_fnd_language,
      x_message_template_id     => l_message_template_id,
      x_attachment_template_id  => l_attachment_template_id,
      x_attachment_name         => l_attachment_name,
      x_contract_update_status  => l_k_status,
      x_return_status           => x_return_status,
      x_msg_data                => x_msg_data,
      x_msg_count               => x_msg_count
     );
     IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  'OKS_TEMPLATE_SET_PUB.get_template_set_dtls(x_return_status= '||x_return_status||
                  ' x_msg_count ='||x_msg_count||')');
       fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                  ' x_template_language ='||x_fnd_language||
                  ' x_message_template_id ='||l_message_template_id||
                  ' x_attachment_template_id ='||l_attachment_template_id||
                  ' x_attachment_name ='||l_attachment_name||
                  ' x_contract_update_status ='||l_k_status);
     END IF;
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
   -- Get layout template's default language to get installed /
   -- base language's iso language and territory
   IF l_message_template_id IS NOT NULL THEN
     OPEN l_template_def_lang_csr(l_message_template_id);
     FETCH l_template_def_lang_csr INTO x_fnd_language,x_fnd_iso_language,x_fnd_iso_territory;
     CLOSE l_template_def_lang_csr;
   ELSE
     x_fnd_language      := NULL;
     x_fnd_iso_language  := NULL;
     x_fnd_iso_territory := NULL;
     -- skip raising an error instead return null values
     -- FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NOLAYOUT_TEMPLATE');
     -- FND_MSG_PUB.add;
     -- RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                    'x_fnd_language '||x_fnd_language||
                    ' x_fnd_iso_language '||x_fnd_iso_language||
                    ' x_fnd_iso_territory ' ||x_fnd_iso_territory);
 END IF;
 -- Standard call to get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count=>x_msg_count, p_data=>x_msg_data);

 IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,G_MODULE||l_api_name,
                    'Leaving '||G_PKG_NAME ||'.'||l_api_name);
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ERROR');
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END get_language_info;

END OKS_RENEW_UTIL_PVT;

/
