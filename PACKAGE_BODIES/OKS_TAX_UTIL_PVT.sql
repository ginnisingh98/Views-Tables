--------------------------------------------------------
--  DDL for Package Body OKS_TAX_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_TAX_UTIL_PVT" AS
    /* $Header: OKSTAXUB.pls 120.31.12010000.5 2009/04/24 10:09:37 harlaksh ship $*/

    --Declare the cursors and records for this package
    --We do not want to expose them to other APIs, so declare here instead of
    --in the spec
    CURSOR okc_hdr_csr (p_chr_id NUMBER) IS
        SELECT
        ID,
        AUTHORING_ORG_ID,
        INV_ORGANIZATION_ID,
        START_DATE,
        END_DATE,
        CONVERSION_TYPE,
        CONVERSION_RATE,
        CONVERSION_RATE_DATE,
        CUST_ACCT_ID,
        BILL_TO_SITE_USE_ID,
        INV_RULE_ID,
        SHIP_TO_SITE_USE_ID,
        PAYMENT_TERM_ID,
        ORG_ID,
        CURRENCY_CODE,
        CUST_PO_NUMBER,
        ESTIMATED_AMOUNT
        FROM OKC_K_HEADERS_ALL_B
        WHERE id = p_chr_id;

    CURSOR oks_hdr_csr (p_chr_id NUMBER) IS
        SELECT
        ID,
        INV_TRX_TYPE,
        TAX_STATUS,
        EXEMPT_CERTIFICATE_NUMBER,
        EXEMPT_REASON_CODE,
        TAX_EXEMPTION_ID,
        TAX_CLASSIFICATION_CODE,
        TAX_CODE
        FROM OKS_K_HEADERS_B
        WHERE chr_id = p_chr_id;


    CURSOR okc_line_csr (p_chr_id NUMBER, p_line_id NUMBER) IS
        SELECT
        ID,
        PRICE_NEGOTIATED,
        PRICE_UNIT,
        CUST_ACCT_ID,
        BILL_TO_SITE_USE_ID,
        INV_RULE_ID,
        START_DATE,
        SHIP_TO_SITE_USE_ID,
        PAYMENT_TERM_ID,
        CLE_ID,
        --npalepu added lse_id for bug # 5223699
        LSE_ID
        --end npalepu
        FROM OKC_K_LINES_B
        WHERE dnz_chr_id = p_chr_id
        AND id = p_line_id
        AND chr_id IS NOT NULL;

    CURSOR oks_line_csr(p_chr_id NUMBER, p_line_id NUMBER) IS
        SELECT
        ID,
        TAX_STATUS,
        EXEMPT_CERTIFICATE_NUMBER,
        EXEMPT_REASON_CODE,
        TAX_EXEMPTION_ID,
        TAX_CLASSIFICATION_CODE,
        TAX_CODE
        FROM OKS_K_LINES_B
        WHERE dnz_chr_id = p_chr_id
        AND cle_id = p_line_id;

    ------------------------ End  pakcage body declarations ----------------------------------

    /*
        Internal procedure that prints  a record of type OKS_TAX_UTIL_PVT.RA_REC_TYPE.
    */

    PROCEDURE PRINT_G_RAIL_REC
    (
     p_rail_rec IN ra_rec_type,
     p_msg    IN VARCHAR2,
     p_level  IN NUMBER
    )
    IS
    l_api_name  CONSTANT VARCHAR2(30) := 'PRINT_G_RAIL_REC';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    BEGIN

        IF (p_level >= FND_LOG.g_current_runtime_level) THEN

            FND_LOG.string(p_level, l_mod_name||'.rec_details', p_msg||
            ' ,HEADER_ID='|| p_rail_rec.HEADER_ID||
            ' ,LINE_ID='|| p_rail_rec.LINE_ID||
            ' ,ORG_ID='|| p_rail_rec.ORG_ID||
            ' ,AMOUNT='|| p_rail_rec.AMOUNT||
            ' ,UNIT_SELLING_PRICE='|| p_rail_rec.UNIT_SELLING_PRICE||
            ' ,PRICE_NEGOTIATED='|| p_rail_rec.PRICE_NEGOTIATED||
            ' ,QUANTITY='|| p_rail_rec.QUANTITY||
            ' ,TAX_VALUE='|| p_rail_rec.TAX_VALUE||
            ' ,TAX_RATE='|| p_rail_rec.TAX_RATE||
            ' ,AMOUNT_INCLUDES_TAX_FLAG='|| p_rail_rec.AMOUNT_INCLUDES_TAX_FLAG||
            ' ,TOTAL_PLUS_TAX='|| p_rail_rec.TOTAL_PLUS_TAX||
            ' ,TAX_EXEMPT_FLAG='|| p_rail_rec.TAX_EXEMPT_FLAG||
            ' ,TAX_CLASSIFICATION_CODE='|| p_rail_rec.TAX_CLASSIFICATION_CODE||
            ' ,EXEMPT_CERTIFICATE_NUMBER='|| p_rail_rec.EXEMPT_CERTIFICATE_NUMBER||
            ' ,EXEMPT_REASON_CODE='|| p_rail_rec.EXEMPT_REASON_CODE||
            ' ,CUST_TRX_TYPE_ID='|| p_rail_rec.CUST_TRX_TYPE_ID||
            ' ,SHIP_TO_SITE_USE_ID='|| p_rail_rec.SHIP_TO_SITE_USE_ID||
            ' ,BILL_TO_SITE_USE_ID='|| p_rail_rec.BILL_TO_SITE_USE_ID||
            ' ,SHIP_TO_PARTY_ID='|| p_rail_rec.SHIP_TO_PARTY_ID||
            ' ,SHIP_TO_PARTY_SITE_ID='|| p_rail_rec.SHIP_TO_PARTY_SITE_ID||
            ' ,SHIP_TO_CUST_ACCT_ID='|| p_rail_rec.SHIP_TO_CUST_ACCT_ID||
            ' ,SHIP_TO_CUST_ACCT_SITE_ID='|| p_rail_rec.SHIP_TO_CUST_ACCT_SITE_ID||
            ' ,SHIP_TO_CUST_ACCT_SITE_USE_ID='|| p_rail_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID||
            ' ,BILL_TO_PARTY_ID='|| p_rail_rec.BILL_TO_PARTY_ID||
            ' ,BILL_TO_PARTY_SITE_ID='|| p_rail_rec.BILL_TO_PARTY_SITE_ID||
            ' ,BILL_TO_CUST_ACCT_ID='|| p_rail_rec.BILL_TO_CUST_ACCT_ID||
            ' ,BILL_TO_CUST_ACCT_SITE_ID='|| p_rail_rec.BILL_TO_CUST_ACCT_SITE_ID||
            ' ,BILL_TO_CUST_ACCT_SITE_USE_ID='|| p_rail_rec.BILL_TO_CUST_ACCT_SITE_USE_ID||
            ' ,CONVERSION_TYPE='|| p_rail_rec.CONVERSION_TYPE||
            ' ,CONVERSION_DATE='|| p_rail_rec.CONVERSION_DATE||
            ' ,CONVERSION_RATE='|| p_rail_rec.CONVERSION_RATE||
            ' ,PRODUCT_TYPE='|| p_rail_rec.PRODUCT_TYPE);

        END IF;


    EXCEPTION

        WHEN OTHERS THEN
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            RAISE;

    END PRINT_G_RAIL_REC;


    /*
        Internal function to get set_of_books id for a given org.
    */
    FUNCTION GET_SET_OF_BOOKS_ID (p_org_id NUMBER) RETURN NUMBER IS

    l_api_name CONSTANT VARCHAR2(30) := 'GET_SET_OF_BOOKS_ID';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    CURSOR l_org_csr  IS
        SELECT     set_of_books_id
        FROM    ar_system_parameters_all
        WHERE    org_id = p_org_id;
    l_set_of_books_id  ar_system_parameters_all.set_of_books_id%TYPE;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_org_id='||p_org_id);
        END IF;

        OPEN  l_org_csr;
        FETCH l_org_csr INTO l_set_of_books_id ;
        CLOSE l_org_csr;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'l_set_of_books_id='||l_set_of_books_id);
        END IF;

        RETURN (l_set_of_books_id);

    EXCEPTION
        WHEN OTHERS THEN

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF l_org_csr%isopen THEN
                CLOSE l_org_csr;
            END IF;

            RAISE;

    END GET_SET_OF_BOOKS_ID;

    /*
        Internal procedure to set the following attributes in px_rail_rec from the
        contract header
            TAX_EXEMPT_FLAG
            EXEMPT_CERTIFICATE_NUMBER
            EXEMPT_REASON_CODE
            TAX_CLASSIFICATION_CODE
    */

    PROCEDURE GET_HDR_TAX
    (
     p_oks_rec               IN  oks_hdr_csr%ROWTYPE,
     p_okc_rec               IN  okc_hdr_csr%ROWTYPE,
     p_okc_line_rec          IN  okc_line_csr%ROWTYPE,
     px_rail_rec             IN  OUT NOCOPY ra_rec_type,
     x_return_status		 OUT NOCOPY	VARCHAR2
     )
    IS

    l_api_name          CONSTANT VARCHAR2(30) := 'GET_HDR_TAX';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    CURSOR tax_exempt_csr(cp_tax_exempt_id NUMBER) IS
        SELECT EXEMPT_CERTIFICATE_NUMBER,
        EXEMPT_REASON_CODE
        FROM ZX_EXEMPTIONS
        WHERE TAX_EXEMPTION_ID = cp_tax_exempt_id;
    TAX_REC     tax_exempt_csr%ROWTYPE;

    --npalepu added on 12-JUL-2006 for bug # 5380878
    CURSOR get_taxcode_from_taxexempt_csr(cp_tax_exempt_id NUMBER) IS
        SELECT ex.TAX_CODE
        FROM RA_TAX_EXEMPTIONS_ALL ex
        WHERE ex.TAX_EXEMPTION_ID = cp_tax_exempt_id;
    --end npalepu

    CURSOR tax_code_csr(cp_tax_code VARCHAR2) IS
        SELECT TAX_CLASSIFICATION_CODE
        FROM ZX_ID_TCC_MAPPING
        WHERE TAX_RATE_CODE_ID = cp_tax_code
        AND source = 'AR';
    l_tax_code    ZX_ID_TCC_MAPPING.TAX_CLASSIFICATION_CODE%TYPE;


    CURSOR cust_acct_csr(cp_site_use_id NUMBER) IS
        SELECT ACCT_SITE_SHIP.CUST_ACCOUNT_ID
        FROM   HZ_CUST_SITE_USES_ALL       S_SHIP,
               HZ_CUST_ACCT_SITES_ALL          ACCT_SITE_SHIP
        WHERE  S_SHIP.SITE_USE_ID = cp_site_use_id
        AND  S_SHIP.CUST_ACCT_SITE_ID = acct_site_ship.cust_acct_site_id;

    l_header_cust_acct_id   NUMBER;
    l_line_cust_acct_id     NUMBER;


    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_oks_rec.tax_status='||p_oks_rec.tax_status||' ,p_okc_rec.cust_acct_id='||p_okc_rec.cust_acct_id||' ,p_okc_line_rec.cust_acct_id='||p_okc_line_rec.cust_acct_id||
            ' ,p_oks_rec.EXEMPT_CERTIFICATE_NUMBER='||p_oks_rec.EXEMPT_CERTIFICATE_NUMBER||' ,p_oks_rec.EXEMPT_REASON_CODE='||p_oks_rec.EXEMPT_REASON_CODE||' ,p_oks_rec.TAX_EXEMPTION_ID='||p_oks_rec.TAX_EXEMPTION_ID||
            ' ,p_oks_rec.TAX_CLASSIFICATION_CODE='||p_oks_rec.TAX_CLASSIFICATION_CODE||' ,p_oks_rec.TAX_CODE='||p_oks_rec.TAX_CODE);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        --need to copy the tax_exempt_flag from oks_k_headers_b (p_oks_rec)
        --to px_rail_rec
        --the IF condition is so that we don't overwrite the tax information from the line
        IF px_rail_rec.TAX_EXEMPT_FLAG IS NULL THEN
            px_rail_rec.TAX_EXEMPT_FLAG := p_oks_rec.tax_status;
        END IF;


        --Get exemption information if tax_status is 'E'
        IF NVL(p_oks_rec.tax_status, 'S') = 'E' THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.tax_status','p_oks_rec.tax_status: Tax Status is E (Exempt)');
            END IF;

            --Check if the header and lines have the same cust_acct_id
            --We only use the header level exemptions for the lines
            --if the header and line customer accounts are the same
            l_header_cust_acct_id := p_okc_rec.cust_acct_id;
            l_line_cust_acct_id := p_okc_line_rec.cust_acct_id;

            IF l_header_cust_acct_id IS NULL THEN
                OPEN cust_acct_csr(p_okc_rec.bill_to_site_use_id);
                FETCH cust_acct_csr INTO l_header_cust_acct_id;
                CLOSE cust_acct_csr;
            END IF;

            IF l_line_cust_acct_id IS NULL THEN
                OPEN cust_acct_csr(p_okc_line_rec.bill_to_site_use_id);
                FETCH cust_acct_csr INTO l_line_cust_acct_id;
                CLOSE cust_acct_csr;
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cust_accts','l_header_cust_acct_id='||l_header_cust_acct_id||' ,l_line_cust_acct_id='||l_line_cust_acct_id);
            END IF;

            IF l_header_cust_acct_id = l_line_cust_acct_id THEN

                px_rail_rec.TAX_EXEMPT_FLAG := p_oks_rec.TAX_STATUS;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cust_accts','Header and line have same customer account ID');
                END IF;

                IF(p_oks_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL)THEN

                    --Contracts created after R12
                    px_rail_rec.EXEMPT_CERTIFICATE_NUMBER := p_oks_rec.EXEMPT_CERTIFICATE_NUMBER;
                    px_rail_rec.EXEMPT_REASON_CODE := p_oks_rec.EXEMPT_REASON_CODE;

                ELSE

                    --Historical contracts
                    OPEN tax_exempt_csr(p_oks_rec.TAX_EXEMPTION_ID);
                    FETCH tax_exempt_csr INTO tax_rec;
                    CLOSE tax_exempt_csr;

                    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_tax_exempt_csr','old contracts - tax_rec.EXEMPT_CERTIFICATE_NUMBER='|| tax_rec.EXEMPT_CERTIFICATE_NUMBER||
                        ' ,tax_rec.EXEMPT_REASON_CODE='|| tax_rec.EXEMPT_REASON_CODE);
                    END IF;

                    px_rail_rec.TAX_EXEMPT_NUMBER := tax_rec.EXEMPT_CERTIFICATE_NUMBER;
                    px_rail_rec.TAX_EXEMPT_REASON := tax_rec.EXEMPT_REASON_CODE;

                    --npalepu added on 12-jul-2006 for bug # 5380878
                    OPEN get_taxcode_from_taxexempt_csr(p_oks_rec.TAX_EXEMPTION_ID);
                    FETCH get_taxcode_from_taxexempt_csr INTO l_tax_code;

                    IF get_taxcode_from_taxexempt_csr%FOUND THEN
                        px_rail_rec.TAX_CLASSIFICATION_CODE := l_tax_code;

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_taxcode_from_taxexempt_csr','old contracts - TAX_CLASSIFICATION_CODE='|| l_tax_code);
                        END IF;
                    END IF;
                    CLOSE get_taxcode_from_taxexempt_csr;
                    --end npalepu

                END IF; --of IF(p_oks_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL)THEN

            ELSE

                --log the line level customer id and header level customer id
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cust_accts','header and line have different customers, cannot use header exemptions for line, setting TAX_EXEMPT_FLAG to S (Standard)');
                END IF;

                --since the exemption flag is 'E' taken from the header, and we cannot use it
                --we should NOT set the exemption flag to 'E'
                --set it to 'S' instead
                px_rail_rec.TAX_EXEMPT_FLAG := 'S';

            END IF; -- of IF l_header_cust_acct_id = l_line_cust_acct_id THEN

        END IF; --of  IF NVL(p_oks_rec.tax_status, 'S') = 'E' THEN

        -- Populate Tax Classification Code
        IF p_oks_rec.TAX_CLASSIFICATION_CODE IS NOT NULL THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.classification_code_new','New contract, TAX_CLASSIFICATION_CODE='||p_oks_rec.TAX_CLASSIFICATION_CODE);
            END IF;

            --Contracts created after R12
            px_rail_rec.TAX_CLASSIFICATION_CODE := p_oks_rec.TAX_CLASSIFICATION_CODE;

        ELSIF p_oks_rec.TAX_CODE IS NOT NULL THEN

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.classification_code_old','Old contract, TAX_CODE='||p_oks_rec.TAX_CODE);
            END IF;

            --Historical contracts
            OPEN tax_code_csr(p_oks_rec.TAX_CODE);
            FETCH tax_code_csr INTO l_tax_code;

            IF tax_code_csr%FOUND THEN

                px_rail_rec.TAX_CLASSIFICATION_CODE := l_tax_code;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.classification_code_old','classification code from ZX_ID_TCC_MAPPING, l_tax_code='|| l_tax_code);
                END IF;

            END IF; --of IF tax_code_csr%FOUND THEN
            CLOSE tax_code_csr;

        END IF; --of IF p_oks_rec.TAX_CLASSIFICATION_CODE IS NOT NULL THEN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;


    EXCEPTION

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF cust_acct_csr%isopen THEN
                CLOSE cust_acct_csr;
            END IF;
            IF tax_exempt_csr%isopen THEN
                CLOSE tax_exempt_csr;
            END IF;
            IF tax_code_csr%isopen THEN
                CLOSE tax_code_csr;
            END IF;

            RAISE;

    END GET_HDR_TAX;


    /*
        Internal procedure to set the following attributes in px_rail_rec from the
        contract header
            INVOICING_RULE_ID
            TRX_DATE
            CONVERSION_TYPE
            CONVERSION_RATE
            CONVERSION_RATE_DATE
            CUST_TRX_TYPE_ID
            PAYMENT_TERM_ID

            BILL_TO_SITE_USE_ID
            ORIG_SYSTEM_BILL_CUSTOMER_ID
            ORIG_SYSTEM_BILL_ADDRESS_ID
            ORIG_SYSTEM_SOLD_CUSTOMER_ID
            BILL_TO_ORG_ID

            ORIG_SYSTEM_SHIP_CUSTOMER_ID
            ORIG_SYSTEM_SHIP_ADDRESS_ID
            SHIP_TO_SITE_USE_ID
            SHIP_TO_ORG_ID
    */

    -- Added for rule re-architecture.
    PROCEDURE GET_HDR_RULES
    (
     p_oks_rec               IN  oks_hdr_csr%ROWTYPE,
     p_okc_rec               IN  okc_hdr_csr%ROWTYPE,
     px_rail_rec             IN OUT NOCOPY ra_rec_type,
     x_return_status		 OUT NOCOPY	VARCHAR2
     ) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'GET_HDR_RULES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);
    /* Added by sjanakir for Bug# 6972776 */
    x_date      DATE;
    x_hook      NUMBER;

    CURSOR cur_address(cp_site_use_id IN VARCHAR2, cp_code VARCHAR2) IS
        SELECT CS.SITE_USE_ID, CS.ORG_ID, CA.CUST_ACCOUNT_ID, CA.CUST_ACCT_SITE_ID
        FROM HZ_CUST_SITE_USES_ALL CS, HZ_CUST_ACCT_SITES_ALL CA
        WHERE CS.SITE_USE_ID = cp_site_use_id AND CS.SITE_USE_CODE = cp_code
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID;
    ADDRESS_REC      cur_address%ROWTYPE;


    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_okc_rec.INV_RULE_ID='||p_okc_rec.INV_RULE_ID||' ,p_okc_rec.START_DATE='||p_okc_rec.START_DATE||' ,p_okc_rec.org_id='||p_okc_rec.org_id||
            ' ,p_okc_rec.currency_code='||p_okc_rec.currency_code||' ,p_okc_rec.PAYMENT_TERM_ID='||p_okc_rec.PAYMENT_TERM_ID||' ,p_oks_rec.INV_TRX_TYPE='||p_oks_rec.INV_TRX_TYPE||
            ' ,p_okc_rec.CONVERSION_TYPE='||p_okc_rec.CONVERSION_TYPE||' ,p_okc_rec.CONVERSION_RATE='||p_okc_rec.CONVERSION_RATE||'  ,p_okc_rec.CONVERSION_RATE_DATE='||p_okc_rec.CONVERSION_RATE_DATE||
            ' ,p_okc_rec.BILL_TO_SITE_USE_ID='||p_okc_rec.BILL_TO_SITE_USE_ID||' ,p_okc_rec.SHIP_TO_SITE_USE_ID='||p_okc_rec.SHIP_TO_SITE_USE_ID);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        px_rail_rec.INVOICING_RULE_ID := p_okc_rec.INV_RULE_ID; -- IRE

        --Get Transaction Date
         IF (px_rail_rec.TRX_DATE IS NULL) AND (p_okc_rec.START_DATE IS NOT NULL)
         THEN

			 /* Added by sjanakir for Bug#6972776 */
			 oks_code_hook.tax_trx_date(p_chr_id         => p_okc_rec.id,
										p_cle_id         => NULL,
										p_hdr_start_date => p_okc_rec.START_DATE,
									    p_lin_start_date => NULL,
										x_hook           => x_hook,
										x_date           => x_date
							           );
		     IF x_hook = 1 AND x_date IS NOT NULL
		     THEN
			    px_rail_rec.TRX_DATE := x_date;
             ELSE
                px_rail_rec.TRX_DATE := p_okc_rec.START_DATE;
             END IF;
          END IF;
        ----------------- CVN rule -------------------
        px_rail_rec.CONVERSION_TYPE := p_okc_rec.CONVERSION_TYPE;
        IF (px_rail_rec.CONVERSION_TYPE = 'User') THEN
            px_rail_rec.CONVERSION_RATE := 1;
        ELSE
            px_rail_rec.CONVERSION_RATE := NULL;
        END IF;

        IF (okc_currency_api.get_ou_currency(p_okc_rec.org_id) <> p_okc_rec.currency_code ) THEN
            IF (p_okc_rec.CONVERSION_TYPE = 'User') THEN
                px_rail_rec.CONVERSION_RATE := nvl(p_okc_rec.CONVERSION_RATE, 1);
            ELSE
                px_rail_rec.CONVERSION_RATE := NULL;
            END IF;
        END IF;

        -- conversion date is not getting used anywhere.
        IF p_okc_rec.CONVERSION_RATE_DATE IS NULL THEN
            px_rail_rec.CONVERSION_DATE := SYSDATE;
        ELSE
            px_rail_rec.CONVERSION_DATE := p_okc_rec.CONVERSION_RATE_DATE;
        END IF;

        -------------------- BTO rule ----------------------------
        OPEN  cur_address(p_okc_rec.BILL_TO_SITE_USE_ID, 'BILL_TO');
        FETCH cur_address INTO address_rec;
        IF cur_address%FOUND THEN
            px_rail_rec.BILL_TO_SITE_USE_ID := address_rec.site_use_id;
            px_rail_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.ORIG_SYSTEM_BILL_ADDRESS_ID := address_rec.cust_acct_site_id;
            px_rail_rec.ORIG_SYSTEM_SOLD_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.BILL_TO_ORG_ID := address_rec.org_id;
        END IF;
        CLOSE cur_address;

        ----------------- STO rule ------------------------------
        OPEN  cur_address(p_okc_rec.SHIP_TO_SITE_USE_ID, 'SHIP_TO');
        FETCH cur_address INTO address_rec;
        IF cur_address%FOUND THEN
            px_rail_rec.ORIG_SYSTEM_SHIP_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.ORIG_SYSTEM_SHIP_ADDRESS_ID := address_rec.cust_acct_site_id;
            px_rail_rec.SHIP_TO_SITE_USE_ID := address_rec.site_use_id;
            px_rail_rec.SHIP_TO_ORG_ID := address_rec.org_id;
        END IF;
        CLOSE cur_address;

        -------------------- PTR rule -----------------------------
        px_rail_rec.PAYMENT_TERM_ID := p_okc_rec.PAYMENT_TERM_ID;

        ------------------ SBG rule -------------------------------

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calling_get_cust_trx_type_id','p_oks_rec.INV_TRX_TYPE='||p_oks_rec.INV_TRX_TYPE||' ,p_org_id='||p_okc_rec.org_id);
        END IF;


        px_rail_rec.CUST_TRX_TYPE_ID := get_cust_trx_type_id(
             p_org_id => p_okc_rec.org_id,
             p_inv_trx_type => p_oks_rec.INV_TRX_TYPE);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_cust_trx_type_id','px_rail_rec.CUST_TRX_TYPE_ID='||px_rail_rec.CUST_TRX_TYPE_ID);
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF cur_address%isopen THEN
                CLOSE cur_address;
            END IF;
            RAISE;

    END GET_HDR_RULES;

    /*
        Internal procedure to set the following attributes in px_rail_rec from the
        contract line
            INVOICING_RULE_ID
            LINE_ID
            PRICE_NEGOTIATED
            TRX_DATE

            TAX_EXEMPT_FLAG
            EXEMPT_CERTIFICATE_NUMBER
            EXEMPT_REASON_CODE
            TAX_CLASSIFICATION_CODE


            CONVERSION_TYPE
            CONVERSION_RATE
            CONVERSION_RATE_DATE
            PAYMENT_TERM_ID

            BILL_TO_SITE_USE_ID
            ORIG_SYSTEM_BILL_CUSTOMER_ID
            ORIG_SYSTEM_BILL_ADDRESS_ID
            ORIG_SYSTEM_SOLD_CUSTOMER_ID
            BILL_TO_ORG_ID

            ORIG_SYSTEM_SHIP_CUSTOMER_ID
            ORIG_SYSTEM_SHIP_ADDRESS_ID
            SHIP_TO_SITE_USE_ID
            SHIP_TO_ORG_ID
    */

    PROCEDURE GET_LINE_RULES
    (
     p_oks_line_rec        IN  oks_line_csr%ROWTYPE,
     p_okc_line_rec        IN  okc_line_csr%ROWTYPE,
     px_rail_rec            IN  OUT NOCOPY ra_rec_type,
     x_return_status        OUT NOCOPY	VARCHAR2,
     x_need_header_tax      OUT NOCOPY  VARCHAR2
    )
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'GET_LINE_RULES';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    /* Added by sjanakir for Bug# 6972776 */
    x_date      DATE;
    x_hook      NUMBER;


    CURSOR tax_exempt_csr(cp_tax_exempt_id NUMBER) IS
        SELECT EXEMPT_CERTIFICATE_NUMBER,
        EXEMPT_REASON_CODE
        FROM ZX_EXEMPTIONS
        WHERE TAX_EXEMPTION_ID = cp_tax_exempt_id;
    TAX_REC     tax_exempt_csr%ROWTYPE;

    --npalepu added on 12-JUL-2006 for bug # 5380878
    CURSOR get_taxcode_from_taxexempt_csr(cp_tax_exempt_id NUMBER) IS
        SELECT ex.TAX_CODE
        FROM RA_TAX_EXEMPTIONS_ALL ex
        WHERE ex.TAX_EXEMPTION_ID = cp_tax_exempt_id;
    --end npalepu

    CURSOR tax_code_csr(cp_tax_code VARCHAR2) IS
        SELECT TAX_CLASSIFICATION_CODE
        FROM ZX_ID_TCC_MAPPING
        WHERE TAX_RATE_CODE_ID = cp_tax_code
        AND source = 'AR';
    l_tax_code    ZX_ID_TCC_MAPPING.TAX_CLASSIFICATION_CODE%TYPE;

    CURSOR cur_address(cp_site_use_id IN VARCHAR2, cp_code VARCHAR2) IS
        SELECT CS.SITE_USE_ID, CS.ORG_ID, CA.CUST_ACCOUNT_ID, CA.CUST_ACCT_SITE_ID
        FROM HZ_CUST_SITE_USES_ALL CS, HZ_CUST_ACCT_SITES_ALL CA
        WHERE CS.SITE_USE_ID = cp_site_use_id AND CS.SITE_USE_CODE = cp_code
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID;
    ADDRESS_REC      cur_address%ROWTYPE;

    l_need_header_tax VARCHAR2(1);

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'p_okc_line_rec.INV_RULE_ID='||p_okc_line_rec.INV_RULE_ID||' ,p_oks_line_rec.id='||p_oks_line_rec.id||' ,p_okc_line_rec.PRICE_NEGOTIATED='||p_okc_line_rec.PRICE_NEGOTIATED||
            ' ,p_okc_line_rec.START_DATE='||p_okc_line_rec.START_DATE||' ,p_oks_line_rec.TAX_STATUS='||p_oks_line_rec.TAX_STATUS||' ,p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER='||p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER||
            ' ,p_oks_line_rec.EXEMPT_REASON_CODE='||p_oks_line_rec.EXEMPT_REASON_CODE||' ,p_oks_line_rec.TAX_EXEMPTION_ID='||p_oks_line_rec.TAX_EXEMPTION_ID||' ,p_oks_line_rec.TAX_CLASSIFICATION_CODE='||p_oks_line_rec.TAX_CLASSIFICATION_CODE||
            ' ,p_oks_line_rec.TAX_CODE='||p_oks_line_rec.TAX_CODE||' ,p_okc_line_rec.PAYMENT_TERM_ID='||p_okc_line_rec.PAYMENT_TERM_ID||
            ' ,p_okc_line_rec.BILL_TO_SITE_USE_ID='||p_okc_line_rec.BILL_TO_SITE_USE_ID||' ,p_okc_line_rec.SHIP_TO_SITE_USE_ID='||p_okc_line_rec.SHIP_TO_SITE_USE_ID);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        IF p_okc_line_rec.INV_RULE_ID IS NOT NULL THEN
            px_rail_rec.INVOICING_RULE_ID := p_okc_line_rec.INV_RULE_ID; -- IRE
        END IF;

        --Added in R12
        IF p_oks_line_rec.id IS NOT NULL THEN
            px_rail_rec.LINE_ID := p_oks_line_rec.id;
        END IF;

        --For sublines only
        IF p_okc_line_rec.PRICE_NEGOTIATED IS NOT NULL THEN
            px_rail_rec.PRICE_NEGOTIATED := p_okc_line_rec.price_negotiated;
        END IF;

        --Get Transaction Date
        IF p_okc_line_rec.START_DATE IS NOT NULL THEN

   	    /* Added by sjanakir for Bug#6972776 */
        	  oks_code_hook.tax_trx_date(p_chr_id         => NULL,
		                                 p_cle_id         => p_okc_line_rec.id,
		                                 p_hdr_start_date => NULL,
			                             p_lin_start_date => p_okc_line_rec.start_date,
			                             x_hook           => x_hook,
			                             x_date           => x_date
	                                     );

           	  IF x_hook = 1 AND x_date IS NOT NULL
			  THEN
			     px_rail_rec.TRX_DATE := x_date;
              ELSE
                 px_rail_rec.TRX_DATE := p_okc_line_rec.START_DATE;
              END IF;
        END IF;
        --Populate Exemption Information if Tax Status = 'E'
        IF p_oks_line_rec.TAX_STATUS IS NOT NULL THEN

            px_rail_rec.TAX_EXEMPT_FLAG := p_oks_line_rec.TAX_STATUS;

            IF(NVL(px_rail_rec.TAX_EXEMPT_FLAG, 'S') = 'E') THEN

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.tax_status','Tax status is E, p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER='|| p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER||
                    ' ,p_oks_line_rec.EXEMPT_REASON_CODE='|| p_oks_line_rec.EXEMPT_REASON_CODE||' ,p_oks_line_rec.TAX_EXEMPTION_ID='||p_oks_line_rec.TAX_EXEMPTION_ID);
                END IF;

                IF(p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL)THEN

                    --Contracts created after R12
                    IF p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL THEN
                        px_rail_rec.EXEMPT_CERTIFICATE_NUMBER := p_oks_line_rec.EXEMPT_CERTIFICATE_NUMBER;
                    END IF;

                    IF p_oks_line_rec.EXEMPT_REASON_CODE IS NOT NULL THEN
                        px_rail_rec.EXEMPT_REASON_CODE := p_oks_line_rec.EXEMPT_REASON_CODE;
                    END IF;

                ELSE

                    --Historical contracts
                    OPEN tax_exempt_csr(p_oks_line_rec.TAX_EXEMPTION_ID);
                    FETCH tax_exempt_csr INTO tax_rec;
                    CLOSE tax_exempt_csr;

                    IF tax_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL THEN
                        px_rail_rec.EXEMPT_CERTIFICATE_NUMBER := tax_rec.EXEMPT_CERTIFICATE_NUMBER;
                    END IF;

                    IF tax_rec.EXEMPT_REASON_CODE IS NOT NULL THEN
                        px_rail_rec.EXEMPT_REASON_CODE := tax_rec.EXEMPT_REASON_CODE;
                    END IF;

                    --npalepu added on 12-jul-2006 for bug # 5380878
                    OPEN get_taxcode_from_taxexempt_csr(p_oks_line_rec.TAX_EXEMPTION_ID);
                    FETCH get_taxcode_from_taxexempt_csr INTO l_tax_code;

                    IF get_taxcode_from_taxexempt_csr%FOUND THEN
                        px_rail_rec.TAX_CLASSIFICATION_CODE := l_tax_code;

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_taxcode_from_taxexempt_csr','old contracts - TAX_CLASSIFICATION_CODE='|| l_tax_code);
                        END IF;
                    END IF;
                    CLOSE get_taxcode_from_taxexempt_csr;
                    --end npalepu

                END IF; --of IF(p_oks_rec.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL)THEN

            ELSE

                NULL;

            END IF; --of IF(NVL(px_rail_rec.TAX_EXEMPT_FLAG, 'S') = 'E') THEN

        END IF; --of IF p_oks_line_rec.TAX_STATUS IS NOT NULL THEN


        -- Populate Tax Classification Code
        IF p_oks_line_rec.TAX_CLASSIFICATION_CODE IS NOT NULL THEN

            --Contracts created after R12
            px_rail_rec.TAX_CLASSIFICATION_CODE := p_oks_line_rec.TAX_CLASSIFICATION_CODE;
            IF p_oks_line_rec.TAX_STATUS IS NULL THEN
                --tax code is not null, but tax status is null
                --default tax status to 'S'
                px_rail_rec.TAX_EXEMPT_FLAG := 'S';
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.tax_classification_code','New Contract - tax_classification_code='||p_oks_line_rec.TAX_CLASSIFICATION_CODE);
            END IF;

        ELSIF p_oks_line_rec.TAX_CODE IS NOT NULL THEN

            --Historical contracts
            OPEN tax_code_csr(p_oks_line_rec.TAX_CODE);
            FETCH tax_code_csr INTO l_tax_code;
            IF tax_code_csr%FOUND THEN
                px_rail_rec.TAX_CLASSIFICATION_CODE := l_tax_code;
            ELSE
                --tax_status is 'S' or 'R', no tax code
                px_rail_rec.TAX_CLASSIFICATION_CODE := NULL;
                l_need_header_tax := 'Y';
            END IF;
            CLOSE tax_code_csr;

            IF p_oks_line_rec.TAX_STATUS IS NULL THEN
                --tax code is not null, but tax status is null
                --default tax status to 'S'
                px_rail_rec.TAX_EXEMPT_FLAG := 'S';
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.tax_classification_code','Old unmigarted Contract - tax_code='||p_oks_line_rec.TAX_CODE||' ,corresponding classification_code='||l_tax_code);
            END IF;

        ELSE
            --no tax code on line level, need header information
            --This is to prevent the null subline information from overwriting top line
            --IF px_rail_rec.TAX_CLASSIFICATION_CODE IS NULL AND px_rail_rec.TAX_EXEMPT_FLAG <> 'E' THEN --gbgupta
            IF px_rail_rec.TAX_CLASSIFICATION_CODE IS NULL AND px_rail_rec.TAX_EXEMPT_FLAG IS NULL THEN --gbgupta
                l_need_header_tax := 'Y';
            END IF;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.tax_classification_code','Both tax classication code and tax code are null');
            END IF;

        END IF; -- of IF p_oks_rec.TAX_CLASSIFICATION_CODE IS NOT NULL THEN

        IF px_rail_rec.TAX_EXEMPT_FLAG IS NULL THEN
            l_need_header_tax := 'Y';
        END IF;

        x_need_header_tax := l_need_header_tax;


        -------------------- BTO rule ----------------------------
        IF px_rail_rec.BILL_TO_CUST_ACCT_ID IS NULL AND p_okc_line_rec.CUST_ACCT_ID IS NOT NULL THEN
            px_rail_rec.BILL_TO_CUST_ACCT_ID := p_okc_line_rec.CUST_ACCT_ID;
        END IF;

        OPEN  cur_address(p_okc_line_rec.BILL_TO_SITE_USE_ID, 'BILL_TO');
        FETCH cur_address INTO address_rec;
        IF cur_address%FOUND THEN
            px_rail_rec.BILL_TO_SITE_USE_ID := address_rec.site_use_id;
            px_rail_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.ORIG_SYSTEM_BILL_ADDRESS_ID := address_rec.cust_acct_site_id;
            px_rail_rec.ORIG_SYSTEM_SOLD_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.BILL_TO_ORG_ID := address_rec.org_id;
        END IF;
        CLOSE cur_address;

        ----------------- STO rule ------------------------------
        OPEN  cur_address(p_okc_line_rec.SHIP_TO_SITE_USE_ID, 'SHIP_TO');
        FETCH cur_address INTO address_rec;
        IF cur_address%FOUND THEN
            px_rail_rec.ORIG_SYSTEM_SHIP_CUSTOMER_ID := address_rec.cust_account_id;
            px_rail_rec.ORIG_SYSTEM_SHIP_ADDRESS_ID := address_rec.cust_acct_site_id;
            px_rail_rec.SHIP_TO_SITE_USE_ID := address_rec.site_use_id;
            px_rail_rec.SHIP_TO_ORG_ID := address_rec.org_id;
        END IF;
        CLOSE cur_address;

        -------------------- PTR rule -----------------------------
        px_rail_rec.PAYMENT_TERM_ID := p_okc_line_rec.PAYMENT_TERM_ID;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status||' ,x_need_header_tax='||x_need_header_tax);
        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF cur_address%isopen THEN
                CLOSE cur_address;
            END IF;
            IF tax_exempt_csr%isopen THEN
                CLOSE tax_exempt_csr;
            END IF;
            IF tax_code_csr%isopen THEN
                CLOSE tax_code_csr;
            END IF;

            RAISE;

    END GET_LINE_RULES;


    /*
        Internal procedure to set the following attributes in px_rail_rec from the
        SHIP_TO_SITE_USE_ID and BILL_TO_SITE_USE_ID attributes
            SHIP_TO_POSTAL_CODE
            SHIP_TO_LOCATION_ID
            FOB_POINT
            SHIP_TO_PARTY_ID
            SHIP_TO_PARTY_SITE_ID
            SHIP_TO_CUST_ACCT_SITE_USE_ID
            SHIP_TO_CUST_ACCT_ID
            SHIP_TO_CUST_ACCT_SITE_ID

            BILL_TO_POSTAL_CODE
            BILL_TO_LOCATION_ID
            BILL_TO_PARTY_ID
            BILL_TO_PARTY_SITE_ID
            BILL_TO_CUST_ACCT_ID
            BILL_TO_CUST_ACCT_SITE_ID
    */
    PROCEDURE TAX_INTEGRATION
    (
     p_chr_id        IN NUMBER,
     px_rail_rec     IN OUT NOCOPY RA_REC_TYPE,
     x_return_status OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name      CONSTANT VARCHAR2(30) := 'TAX_INTEGRATION';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    CURSOR cur_cust_info(cp_siteuseid NUMBER) IS
        SELECT S_SHIP.CUST_ACCT_SITE_ID,
               S_SHIP.fob_point,
               S_SHIP.warehouse_id,
               ACCT_SITE_SHIP.CUST_ACCOUNT_ID,
               ACCT_SITE_SHIP.org_id,
               LOC_SHIP.POSTAL_CODE,
               --LOC_ASSIGN_SHIP.LOC_ID,
               PARTY.PARTY_NAME,
               PARTY.party_id,
               CUST_ACCT.ACCOUNT_NUMBER,
               CUST_ACCT.TAX_HEADER_LEVEL_FLAG,
               CUST_ACCT.TAX_ROUNDING_RULE,
               CUST_ACCT.PARTY_ID CUST_ACCT_PARTY_ID,
               PARTY_SITE_SHIP.PARTY_SITE_ID,
               PARTY_SITE_SHIP.LOCATION_ID,
               LOC_SHIP.STATE
        FROM
               HZ_CUST_SITE_USES_ALL      S_SHIP,
               HZ_CUST_ACCT_SITES_ALL     ACCT_SITE_SHIP,
               HZ_PARTY_SITES             PARTY_SITE_SHIP,
               HZ_LOCATIONS               LOC_SHIP,
               --HZ_LOC_ASSIGNMENTS       LOC_ASSIGN_SHIP,
               HZ_PARTIES                 PARTY,
               HZ_CUST_ACCOUNTS           CUST_ACCT
        WHERE  S_SHIP.SITE_USE_ID = cp_siteuseid
          AND  S_SHIP.CUST_ACCT_SITE_ID = acct_site_ship.cust_acct_site_id
          AND  acct_site_ship.cust_account_id = cust_acct.cust_account_id
          AND  cust_acct.party_id = party.party_id
          AND  acct_site_ship.party_site_id = party_site_ship.party_site_id
          AND  party_site_ship.location_id = loc_ship.location_id;
    --and  loc_ship.location_id       = loc_assign_ship.location_id;
    CUST_INFO_REC       cur_cust_info%ROWTYPE;


    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin', 'px_rail_rec.SHIP_TO_SITE_USE_ID='||px_rail_rec.SHIP_TO_SITE_USE_ID||' ,px_rail_rec.BILL_TO_SITE_USE_ID='||px_rail_rec.BILL_TO_SITE_USE_ID);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN cur_cust_info(px_rail_rec.SHIP_TO_SITE_USE_ID);
        FETCH cur_cust_info INTO cust_info_rec;
        IF cur_cust_info%FOUND THEN
            px_rail_rec.SHIP_TO_POSTAL_CODE := cust_info_rec.POSTAL_CODE;
            px_rail_rec.SHIP_TO_LOCATION_ID := cust_info_rec.LOCATION_ID;
            px_rail_rec.FOB_POINT := cust_info_rec.FOB_POINT;
            px_rail_rec.SHIP_TO_PARTY_ID := cust_info_rec.CUST_ACCT_PARTY_ID;
            px_rail_rec.SHIP_TO_PARTY_SITE_ID := cust_info_rec.PARTY_SITE_ID;
            px_rail_rec.SHIP_TO_CUST_ACCT_SITE_USE_ID := px_rail_rec.SHIP_TO_SITE_USE_ID;
            px_rail_rec.SHIP_TO_CUST_ACCT_ID := cust_info_rec.CUST_ACCOUNT_ID;
            px_rail_rec.SHIP_TO_CUST_ACCT_SITE_ID := cust_info_rec.CUST_ACCT_SITE_ID;
        END IF;
        CLOSE cur_cust_info;

        OPEN cur_cust_info(px_rail_rec.BILL_TO_SITE_USE_ID);
        FETCH cur_cust_info INTO cust_info_rec;
        IF cur_cust_info%FOUND THEN
            px_rail_rec.BILL_TO_POSTAL_CODE := cust_info_rec.POSTAL_CODE;
            px_rail_rec.BILL_TO_LOCATION_ID := cust_info_rec.LOCATION_ID;
            px_rail_rec.BILL_TO_PARTY_ID := cust_info_rec.CUST_ACCT_PARTY_ID;
            px_rail_rec.BILL_TO_PARTY_SITE_ID := cust_info_rec.PARTY_SITE_ID;
            --bill_to_cust_acct_id is needed for getting legal_entity_id later
            --in case user does not enter any party information on the line
            --bill_to_cust_acct_id at this point will be null
            --If it's not null, then it's already populated from the lines
            --and we do not want to overwrite that
            IF px_rail_rec.BILL_TO_CUST_ACCT_ID IS NULL THEN
                px_rail_rec.BILL_TO_CUST_ACCT_ID := cust_info_rec.CUST_ACCOUNT_ID;
            END IF;

            px_rail_rec.BILL_TO_CUST_ACCT_SITE_ID := cust_info_rec.CUST_ACCT_SITE_ID;
        END IF;
        CLOSE cur_cust_info;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status);
        END IF;

    EXCEPTION

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF cur_cust_info%isopen THEN
                CLOSE cur_cust_info;
            END IF;
            RAISE;

    END TAX_INTEGRATION;

    /*
        Internal procedure that sets the EB Tax (ZX) record structure before calling the calculate tax
        api
    */

    PROCEDURE INIT_ZX_TRXLINE_DIST_TBL
    (
     p_rail_rec  IN RA_REC_TYPE
    )
    IS

    l_api_name      CONSTANT VARCHAR2(30) := 'INIT_ZX_TRXLINE_DIST_TBL';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    l_legal_entity_id   NUMBER;
    l_bill_from_location_id NUMBER;  /* added for bug8323627 */

    BEGIN
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','begin');
        END IF;

        --Initialize the global PL/SQL table
        ZX_GLOBAL_STRUCTURES_PKG.init_trx_line_dist_tbl(1);

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(1) := p_rail_rec.org_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLICATION_ID(1) := 515;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ENTITY_CODE(1) := 'OKC_K_HEADERS_B';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_CLASS_CODE(1) := 'SALES_TRANSACTION_TAX_QUOTE';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EVENT_TYPE_CODE(1) := 'CREATE';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_ID(1) := p_rail_rec.header_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_ID(1) := p_rail_rec.line_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LEVEL_TYPE(1) := 'LINE';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_LEVEL_ACTION(1) := 'CREATE';

	/*Added by nchadala on 16-JUL-2007 for Bug#6164825*/
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name, 'Added the trxtypeid to the AR dist table='||p_rail_rec.cust_trx_type_id);
        END IF;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID(1) := p_rail_rec.cust_trx_type_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.QUOTE_FLAG(1) := 'Y';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_DATE(1) := p_rail_rec.trx_date;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEDGER_ID(1) := p_rail_rec.set_of_books_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_CURRENCY_CODE(1) := p_rail_rec.currency_code;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(1) := p_rail_rec.conversion_date;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(1) := p_rail_rec.conversion_rate;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(1) := p_rail_rec.conversion_type;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(1) := p_rail_rec.minimum_accountable_unit;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRECISION(1) := p_rail_rec.PRECISION;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calling_get_legal_entity_id','p_bill_to_cust_acct_id='||p_rail_rec.bill_to_cust_acct_id||' ,p_cust_trx_type_id='||p_rail_rec.cust_trx_type_id||' ,p_org_id='||p_rail_rec.org_id);
        END IF;

        l_legal_entity_id := get_legal_entity_id(
            p_bill_to_cust_acct_id => p_rail_rec.bill_to_cust_acct_id,
            p_cust_trx_type_id => p_rail_rec.cust_trx_type_id,
            p_org_id => p_rail_rec.org_id);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_legal_entity_id','l_legal_entity_id='||l_legal_entity_id);
        END IF;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LEGAL_ENTITY_ID(1) := l_legal_entity_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(1) := nvl(p_rail_rec.ship_to_party_id, p_rail_rec.bill_to_party_id);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(1) := p_rail_rec.bill_to_party_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(1) := nvl(p_rail_rec.ship_to_party_site_id, p_rail_rec.bill_to_party_site_id);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(1) := p_rail_rec.bill_to_party_site_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_TYPE(1) := 'ITEM';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.FOB_POINT(1) := p_rail_rec.fob_point;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ID(1) := p_rail_rec.inventory_item_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_ORG_ID(1) := p_rail_rec.inventory_org_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.UOM_CODE(1) := p_rail_rec.uom_code;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.PRODUCT_TYPE(1) := p_rail_rec.product_type;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT(1) := p_rail_rec.amount; --nvl(p_rail_rec.price_negotiated, p_rail_rec.amount);

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_QUANTITY(1) := p_rail_rec.quantity;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(1) := p_rail_rec.line_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(1) := p_rail_rec.exempt_certificate_number;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPT_REASON_CODE(1) := p_rail_rec.exempt_reason_code;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(1) := nvl(p_rail_rec.tax_exempt_flag, 'S'); --fix bug 4766741

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_LOCATION_ID(1) := nvl(p_rail_rec.ship_to_location_id, p_rail_rec.bill_to_location_id);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_LOCATION_ID(1) := p_rail_rec.bill_to_location_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_ID(1) := nvl(p_rail_rec.ship_to_party_id, p_rail_rec.bill_to_party_id);

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_ID(1) := p_rail_rec.bill_to_party_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID(1) := nvl(p_rail_rec.ship_to_party_site_id, p_rail_rec.bill_to_party_site_id);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID(1) := p_rail_rec.bill_to_party_site_id;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_CLASS(1) := 'STANDARD';
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TRX_LINE_DATE(1) := p_rail_rec.trx_date;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(1) := p_rail_rec.tax_classification_code;

        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(1) := nvl(p_rail_rec.ship_to_cust_acct_site_use_id, p_rail_rec.bill_to_site_use_id);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(1) := p_rail_rec.bill_to_site_use_id;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(1) := p_rail_rec.BILL_TO_CUST_ACCT_ID;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(1) := nvl(p_rail_rec.SHIP_TO_CUST_ACCT_ID, p_rail_rec.BILL_TO_CUST_ACCT_ID);
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(1) := p_rail_rec.BILL_TO_CUST_ACCT_SITE_ID;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(1) := p_rail_rec.SHIP_TO_CUST_ACCT_SITE_ID;
      /*  ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG (1) := 'N';*/
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG (1) := 'S'; /*Modified for bug:8307724*/
        /* code added for bug8323627 -- start */
        BEGIN
	            SELECT location_id
	              INTO l_bill_from_location_id
	              FROM HR_ALL_ORGANIZATION_UNITS
	             WHERE organization_id = p_rail_rec.org_id ;
        EXCEPTION
	         WHEN OTHERS THEN
	              l_bill_from_location_id := NULL;
        END;
        ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.BILL_FROM_LOCATION_ID(1) := l_bill_from_location_id;
        /* code added for bug8323627 -- end */

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','end');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            RAISE;

    END INIT_ZX_TRXLINE_DIST_TBL;


    ------------------------ End  Internal procedures ----------------------------------

    /*
        External function to get Invoice Transaction id Type for given org and/or invoice
        transaction type name.
    */

    FUNCTION GET_CUST_TRX_TYPE_ID
    (
     p_org_id IN NUMBER,
     p_inv_trx_type IN VARCHAR2
    ) RETURN NUMBER
    IS

    CURSOR cur_custtrx_type_id(cp_book_id NUMBER, cp_object1id1 NUMBER, cp_org_id NUMBER) IS
        SELECT  cust_trx_type_id
        FROM    RA_CUST_TRX_TYPES_ALL
        WHERE   SET_OF_BOOKS_ID = cp_book_id
        AND     org_id = cp_org_id
        AND     cust_trx_type_id = NVL(cp_object1id1,  -99);


    CURSOR cur_default_custtrx_type_id(cp_book_id NUMBER, cp_org_id NUMBER) IS
        SELECT  cust_trx_type_id
        FROM    RA_CUST_TRX_TYPES_ALL
        WHERE   SET_OF_BOOKS_ID = cp_book_id
        AND     org_id = cp_org_id
        AND TYPE = 'INV' AND name = 'Invoice-OKS' AND SYSDATE <= nvl(end_date, SYSDATE);

    l_api_name  CONSTANT VARCHAR2(30) := 'GET_CUST_TRX_TYPE_ID';
    l_mod_name  VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text    VARCHAR(512);

    l_cust_trx_type_id  NUMBER;
    l_set_of_books_id   NUMBER;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_org_id='|| p_org_id||' ,p_inv_trx_type='|| p_inv_trx_type);
        END IF;

        l_cust_trx_type_id := NULL;

        l_set_of_books_id := get_set_of_books_id(p_org_id);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_set_of_books_id','l_set_of_books_id='|| l_set_of_books_id);
        END IF;

        IF p_inv_trx_type IS NOT NULL THEN
            OPEN cur_custtrx_type_id(l_set_of_books_id, p_inv_trx_type, p_org_id);
            FETCH cur_custtrx_type_id INTO l_cust_trx_type_id;
            CLOSE cur_custtrx_type_id;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.cust_trx_type','p_inv_trx_type is not null, l_cust_trx_type_id='||l_cust_trx_type_id);
            END IF;

        END IF;

        IF l_cust_trx_type_id IS NULL THEN
            OPEN cur_default_custtrx_type_id(l_set_of_books_id,p_org_id);
            FETCH cur_default_custtrx_type_id INTO l_cust_trx_type_id;
            CLOSE cur_default_custtrx_type_id;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.default_trx_type','l_cust_trx_type_id is null, default value - l_cust_trx_type_id=' || l_cust_trx_type_id);
            END IF;

        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','l_cust_trx_type_id='||l_cust_trx_type_id);
        END IF;

        RETURN l_cust_trx_type_id;

    EXCEPTION

        WHEN OTHERS THEN

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF cur_custtrx_type_id%isopen THEN
                CLOSE cur_custtrx_type_id;
            END IF;

            IF cur_default_custtrx_type_id%isopen THEN
                CLOSE cur_default_custtrx_type_id;
            END IF;

    END GET_CUST_TRX_TYPE_ID;

    /*
        External function to get legal entity for a given contract.
    */
    FUNCTION GET_LEGAL_ENTITY_ID (p_chr_id IN NUMBER) RETURN NUMBER IS

    l_api_name  CONSTANT VARCHAR2(30) := 'GET_LEGAL_ENTITY_ID';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    CURSOR cur_batch_source_id(cp_org_id IN NUMBER) IS
        SELECT BATCH_SOURCE_ID
        FROM ra_batch_sources_all
        WHERE org_id = cp_org_id
        AND NAME = 'OKS_CONTRACTS';


    CURSOR cur_k_header(cp_chr_id IN  NUMBER) IS
        SELECT a.ORG_ID, a.CUST_ACCT_ID, b.INV_TRX_TYPE
        FROM OKC_K_HEADERS_ALL_B a, OKS_K_HEADERS_B b
        WHERE a.id = cp_chr_id
        AND b.chr_id = a.id;

    CURSOR cur_okc_lines(cp_chr_id IN  NUMBER) IS
        SELECT CUST_ACCT_ID
        FROM OKC_K_LINES_B
        WHERE CHR_ID = cp_chr_id;

    l_batch_source_id       NUMBER;
    l_legal_entity_id       NUMBER;
    l_bill_to_cust_acct_id  NUMBER;
    l_cust_trx_type_id      NUMBER;
    l_org_id                NUMBER;
    l_inv_trx_type          OKS_K_HEADERS_B.inv_trx_type%TYPE;

    l_return_status     VARCHAR2(1);
    l_msg_data          VARCHAR2(2000);

    l_otoc_le_info      XLE_BUSINESSINFO_GRP.otoc_le_rec;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id='||p_chr_id);
        END IF;

        OPEN cur_k_header(p_chr_id);
        FETCH cur_k_header INTO l_org_id, l_bill_to_cust_acct_id, l_inv_trx_type;
        CLOSE cur_k_header;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_cur_k_header', 'l_org_id='||l_org_id||' ,l_bill_to_cust_acct_id='||l_bill_to_cust_acct_id||' ,l_inv_trx_type='||l_inv_trx_type);
        END IF;

        IF l_bill_to_cust_acct_id IS NULL THEN
            OPEN cur_okc_lines(p_chr_id);
            FETCH cur_okc_lines INTO l_bill_to_cust_acct_id;
            CLOSE cur_okc_lines;

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_cur_okc_lines', 'l_bill_to_cust_acct_id='||l_bill_to_cust_acct_id);
            END IF;
        END IF;


        l_cust_trx_type_id := get_cust_trx_type_id(
                                    p_org_id => l_org_id,
                                    p_inv_trx_type => l_inv_trx_type);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_get_cust_trx_type_id', 'l_cust_trx_type_id='||l_cust_trx_type_id);
        END IF;

        OPEN cur_batch_source_id(l_org_id);
        FETCH cur_batch_source_id INTO l_batch_source_id;
        CLOSE cur_batch_source_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_cur_batch_source_id', 'l_batch_source_id='||l_batch_source_id);
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calling_ XLE_BUSINESSINFO_GRP.get_ordertocash_info','p_customer_type: BILL_TO'||' ,p_customer_id: '|| l_bill_to_cust_acct_id||
            ' ,P_transaction_type_id: '|| l_cust_trx_type_id||' ,p_batch_source_id: '|| l_batch_source_id||' ,p_operating_unit_id: '|| l_org_id);
        END IF;


        XLE_BUSINESSINFO_GRP.get_ordertocash_info(
            x_return_status => l_return_status,
            x_msg_data => l_msg_data,
            p_customer_type => 'BILL_TO',
            p_customer_id => l_bill_to_cust_acct_id,
            P_transaction_type_id => l_cust_trx_type_id,
            p_batch_source_id => l_batch_source_id,
            p_operating_unit_id => l_org_id,
            x_otoc_le_info => l_otoc_le_info);

        l_legal_entity_id := l_otoc_le_info.LEGAL_ENTITY_ID;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_XLE_BUSINESSINFO_GRP.get_ordertocash_info','x_return_status='||l_return_status||' ,x_otoc_le_info.LEGAL_ENTITY_ID='||l_otoc_le_info.LEGAL_ENTITY_ID);
        END IF;

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','end');
        END IF;

        RETURN (l_legal_entity_id);

    EXCEPTION

        WHEN FND_API.g_exc_error THEN

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'end_error');
            END IF;

            IF (cur_k_header%isopen) THEN
                CLOSE cur_k_header;
            END IF;
            IF (cur_okc_lines%isopen) THEN
                CLOSE cur_okc_lines;
            END IF;
            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_unexpected_error', 'end_unexpected_error');
            END IF;

            IF (cur_k_header%isopen) THEN
                CLOSE cur_k_header;
            END IF;
            IF (cur_okc_lines%isopen) THEN
                CLOSE cur_okc_lines;
            END IF;
            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;

        WHEN OTHERS THEN

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF (cur_k_header%isopen) THEN
                CLOSE cur_k_header;
            END IF;
            IF (cur_okc_lines%isopen) THEN
                CLOSE cur_okc_lines;
            END IF;
            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;

    END GET_LEGAL_ENTITY_ID;


    /*
        External function to get legal entity for a given customer, transaction type and org.
    */

    FUNCTION GET_LEGAL_ENTITY_ID
    (
     p_bill_to_cust_acct_id IN NUMBER,
     p_cust_trx_type_id IN NUMBER,
     p_org_id IN NUMBER
    ) RETURN NUMBER IS

    l_api_name  CONSTANT VARCHAR2(30) := 'GET_LEGAL_ENTITY_ID(2)';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    CURSOR cur_batch_source_id IS
        SELECT BATCH_SOURCE_ID
        FROM ra_batch_sources_all
        WHERE org_id = p_org_id
        AND NAME = 'OKS_CONTRACTS';

    l_batch_source_id   NUMBER;
    l_legal_entity_id   NUMBER;

    l_return_status     VARCHAR2(1);
    l_msg_data          VARCHAR2(2000);

    l_otoc_le_info      XLE_BUSINESSINFO_GRP.otoc_le_rec;

    BEGIN

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_bill_to_cust_acct_id='||p_bill_to_cust_acct_id||' ,p_cust_trx_type_id='||p_cust_trx_type_id||' ,p_org_id='||p_org_id);
        END IF;


        OPEN cur_batch_source_id;
        FETCH cur_batch_source_id INTO l_batch_source_id;
        CLOSE cur_batch_source_id;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.after_cur_batch_source_id', 'l_batch_source_id='||l_batch_source_id);
        END IF;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calling_ XLE_BUSINESSINFO_GRP.get_ordertocash_info','p_customer_type: BILL_TO'||' ,p_customer_id: '|| p_bill_to_cust_acct_id||
            ' ,P_transaction_type_id: '|| p_cust_trx_type_id||' ,p_batch_source_id: '|| l_batch_source_id||' ,p_operating_unit_id: '|| p_org_id);
        END IF;


        XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info(
            x_return_status => l_return_status,
            x_msg_data => l_msg_data,
            p_customer_type => 'BILL_TO',
            p_customer_id => p_bill_to_cust_acct_id,
            P_transaction_type_id => p_cust_trx_type_id,
            p_batch_source_id => l_batch_source_id,
            p_operating_unit_id => p_org_id,
            x_otoc_Le_info => l_otoc_le_info);

        l_legal_entity_id := l_otoc_le_info.LEGAL_ENTITY_ID;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_XLE_BUSINESSINFO_GRP.get_ordertocash_info','x_return_status='||l_return_status||' ,x_otoc_le_info.LEGAL_ENTITY_ID='||l_otoc_le_info.LEGAL_ENTITY_ID);
        END IF;

        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','end');
        END IF;

        RETURN (l_legal_entity_id);

    EXCEPTION

        WHEN FND_API.g_exc_error THEN

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'end_error');
            END IF;

            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;

        WHEN FND_API.g_exc_unexpected_error THEN

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_unexpected_error', 'end_unexpected_error');
            END IF;

            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;

        WHEN OTHERS THEN

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 512);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            IF (cur_batch_source_id%isopen) THEN
                CLOSE cur_batch_source_id;
            END IF;


    END GET_LEGAL_ENTITY_ID;

    /*
        Procedure that calciulates tax for a given contract line and pupulates the
        results in px_rail_rec

        Parameters
            p_chr_id        :   contract id
            p_cle_id        :   top line or subline id
            px_rail_rec     :   empty tax record structure, that is populated with tax results

    */



    PROCEDURE GET_TAX
    (
     p_api_version			IN	NUMBER,
     p_init_msg_list		IN	VARCHAR2,
     p_chr_id			    IN	NUMBER,
     p_cle_id               IN  NUMBER,
     px_rail_rec            IN OUT NOCOPY RA_REC_TYPE,
     x_msg_count			OUT 	NOCOPY	NUMBER,
     x_msg_data				OUT 	NOCOPY	VARCHAR2,
     x_return_status		OUT 	NOCOPY	VARCHAR2
     )
    IS
    l_api_name              CONSTANT VARCHAR2(30) := 'GET_TAX';
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR(512);

    -- Gets subline details
    CURSOR cur_sub_lines(cp_sub_line_id NUMBER) IS
        SELECT
        CLE_ID,
        PRICE_UNIT,
        PRICE_NEGOTIATED,
        --npalepu added start_date on 28-jun-2006 for bug # 5223699
        START_DATE
        --end npalepu
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_chr_id
        AND lse_id IN (7, 8, 9, 10, 11, 13, 18, 25, 35)
        AND id = cp_sub_line_id;
    SUB_LINE_REC    cur_sub_lines%ROWTYPE;

    CURSOR cur_item(cp_cle_id IN NUMBER) IS
        SELECT  a.object1_id1, a.object1_id2, jtot_object1_code,
                a.Number_of_items,
                a.UOM_code
        FROM    OKC_K_ITEMS a
        WHERE   a.CLE_ID = cp_cle_id;
    ITEM_REC     cur_item%ROWTYPE;

    CURSOR cur_tax_info(cp_trx_id NUMBER) IS
        SELECT
        tax_rate,
        tax_amt,
        tax_amt_included_flag,
        tax_rate_code
        FROM zx_detail_tax_lines_gt
        WHERE application_id = 515
        AND entity_code = 'OKC_K_HEADERS_B'
        AND event_class_code = 'SALES_TRANSACTION_TAX_QUOTE'
        AND trx_id = cp_trx_id;
    TAX_REC     cur_tax_info%ROWTYPE;

    CURSOR cur_get_precision(cp_currency_code VARCHAR2) IS
        SELECT    c.minimum_accountable_unit, c.precision
        FROM      FND_CURRENCIES C
        WHERE  c.currency_code = cp_currency_code;
    PRECISION_REC       cur_get_precision%ROWTYPE;

    CURSOR get_operating_unit(cp_org_id NUMBER) IS
        SELECT name
        FROM hr_all_organization_units_tl -- Bug 5036523 hr_operating_units
        WHERE organization_id = cp_org_id;

    G_RAIL_REC                  OKS_TAX_UTIL_PVT.ra_rec_type;
    l_okc_hdr_rec               okc_hdr_csr%ROWTYPE;
    l_oks_hdr_rec               oks_hdr_csr%ROWTYPE;
    l_okc_line_rec              okc_line_csr%ROWTYPE;
    l_oks_line_rec              oks_line_csr%ROWTYPE;

    l_parent_cle_id             NUMBER;
    l_line_amount               NUMBER := px_rail_rec.amount;

    transaction_rec             ZX_API_PUB.transaction_rec_type;
    l_doc_level_recalc_flag     ZX_LINES_DET_FACTORS.threshold_indicator_flag%TYPE;

    l_default_tax_code          VARCHAR2(50); /* npalepu 12-jul-2006, changed the tax_code field length from 30 to 50 for bug # 5380870 */
    l_need_header_tax           VARCHAR2(1);
    l_op_unit_name      hr_all_organization_units_tl.name%TYPE; --Bug 5036523 hr_operating_units.name%TYPE;

    --npalepu added on 28-jun-2006 for bug # 5223699
    l_subline_start_date okc_k_lines_b.start_date%TYPE;
    --end npalepu

    --npalepu added on 11-jul-2006 for bug # 5380881
    CURSOR Cur_Batch_Source_Id(p_org_id IN NUMBER)
        IS
        SELECT BATCH_SOURCE_ID
        FROM ra_batch_sources_all
        WHERE org_id = p_org_id
        AND NAME = 'OKS_CONTRACTS';

    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_ret_stat                  VARCHAR2(20);
    l_valid_flag                VARCHAR2(3) := 'N';
    l_batch_source_id           NUMBER;
    --end npalepu

    BEGIN

        --npalepu removed the following code on 20-jun-2006 for bug # 5335312.
        --Reverting back the changes made for the bug # 5292938
        /*
        --npalepu added on 6/9/2006 for bug # 5292938
        --setting the context to contract context, only if no org context is set
        IF mo_global.get_current_org_id IS NULL THEN
                okc_context.set_okc_org_context(p_chr_id => p_chr_id);
        END IF;
        */
        --end npalepu

        --0. log the input details
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.begin','p_chr_id='||p_chr_id||' ,p_cle_id= '||p_cle_id||' ,line_amount='||l_line_amount);
            print_g_rail_rec(
                p_rail_rec => px_rail_rec,
                p_msg => 'Begin get_tax, PX_RAIL_REC details',
                p_level => FND_LOG.level_procedure);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        IF(FND_API.G_TRUE = p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
        END IF;

        --1. get hdr details from okc table and do basic id validation
        OPEN okc_hdr_csr(p_chr_id);
        FETCH okc_hdr_csr  INTO l_okc_hdr_rec;
        IF (okc_hdr_csr%notfound) THEN
            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_INV_CONTRACT');
            FND_MESSAGE.set_token('CONTRACT_ID', p_chr_id);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.basic_validation', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            CLOSE okc_hdr_csr;
            RAISE FND_API.g_exc_error;
        END IF;
        CLOSE okc_hdr_csr;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_okc_hdr_csr', 'ok');
        END IF;

        G_RAIL_REC.HEADER_ID := p_chr_id;
        G_RAIL_REC.LINE_ID := p_cle_id;
        G_RAIL_REC.ORG_ID := l_okc_hdr_rec.org_id;
        G_RAIL_REC.INVENTORY_ORG_ID := l_okc_hdr_rec.inv_organization_id;
        G_RAIL_REC.CURRENCY_CODE := l_okc_hdr_rec.currency_code;
        G_RAIL_REC.PURCHASE_ORDER := l_okc_hdr_rec.cust_po_number;
        G_RAIL_REC.SET_OF_BOOKS_ID := get_set_of_books_id(l_okc_hdr_rec.org_id);
        G_RAIL_REC.AMOUNT := nvl(l_okc_hdr_rec.estimated_amount, 0);

        --2. get hdr details from oks table
        OPEN oks_hdr_csr(p_chr_id);
        FETCH oks_hdr_csr INTO l_oks_hdr_rec;
        CLOSE oks_hdr_csr;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_oks_hdr_csr', 'ok');
        END IF;

        --3. populate hdr rules in G_RAIL_REC
        get_hdr_rules(
            p_oks_rec => l_oks_hdr_rec,
            p_okc_rec => l_okc_hdr_rec,
            px_rail_rec => G_RAIL_REC,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_hdr_rules', 'x_return_status='||x_return_status);
            print_g_rail_rec(
                p_rail_rec => G_RAIL_REC,
                p_msg => 'After calling get_hdr_rules, G_RAIL_REC details',
                p_level => FND_LOG.level_statement);
        END IF;


        --4. find out if p_cle_id is top line (for subscription) or sub line id
        OPEN cur_sub_lines(p_cle_id);
        FETCH cur_sub_lines INTO sub_line_rec;
        IF cur_sub_lines%FOUND THEN
            l_parent_cle_id := sub_line_rec.cle_id; -- This is when the given line is a subline
            --npalepu added on 28-jun-2006 for bug # 5223699
            l_subline_start_date := sub_line_rec.start_date;
            --end npalepu
        ELSE
            l_parent_cle_id := p_cle_id; -- This is when the given line is a top line
            --npalepu added on 28-jun-2006 for bug # 5223699
            l_subline_start_date := null;
            --end npalepu
        END IF;
        CLOSE cur_sub_lines;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_cur_sub_lines', 'p_cle_id='||p_cle_id||' ,l_parent_cle_id='||l_parent_cle_id);
        END IF;

        --5. All tax details except amount are at the topline level
        -- get the topline details from okc table
        OPEN okc_line_csr(p_chr_id, l_parent_cle_id);
        FETCH okc_line_csr INTO l_okc_line_rec;
        IF okc_line_csr%FOUND THEN
            G_RAIL_REC.UNIT_SELLING_PRICE := nvl(l_okc_line_rec.price_unit, l_okc_line_rec.price_negotiated);
            G_RAIL_REC.AMOUNT := nvl(l_okc_line_rec.price_negotiated, 0);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.top_line_open_oks_line_csr', 'line id='||l_okc_line_rec.id);
            END IF;

            --6. get the topline details from oks table
            OPEN oks_line_csr(p_chr_id, l_okc_line_rec.id);
            FETCH oks_line_csr INTO l_oks_line_rec;
            CLOSE oks_line_csr;

            --npalepu added on 28-jun-2006 for bug # 5223699
            --Except for subscription, over riding the top line start_date with sub line start_date
            IF l_subline_start_date is not null then
                l_okc_line_rec.start_date := l_subline_start_date;
            end if;
            --end npalepu

            --7. populate line rules in G_RAIL_REC, also figure out if some rules need to be
            --defaulted from header
            get_line_rules(
                p_oks_line_rec => l_oks_line_rec,
                p_okc_line_rec => l_okc_line_rec,
                px_rail_rec => G_RAIL_REC,
                x_return_status => x_return_status,
                x_need_header_tax => l_need_header_tax);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_line_rules', 'x_return_status='||x_return_status||' ,l_need_header_tax='||l_need_header_tax);
                print_g_rail_rec(
                    p_rail_rec => G_RAIL_REC,
                    p_msg => 'After calling get_line_rules, G_RAIL_REC details',
                    p_level => FND_LOG.level_statement);
            END IF;

            --8. get the item  details
            OPEN cur_item(l_okc_line_rec.id);
            FETCH cur_item INTO item_rec;
            IF cur_item%FOUND THEN
                G_RAIL_REC.INVENTORY_ITEM_id := item_rec.object1_id1;
                G_RAIL_REC.QUANTITY := item_rec.Number_of_items;
                G_RAIL_REC.UOM_CODE := item_rec.UOM_code;

                --bug 5193041, commented after request from EB Tax team
                /*
                OPEN Cur_prod_type(G_RAIL_REC.INVENTORY_ITEM_ID, G_RAIL_REC.ORG_ID);
                FETCH Cur_prod_type INTO l_product_type;
                G_RAIL_REC.PRODUCT_TYPE := l_product_type;
                CLOSE Cur_prod_type;
                */
            END IF;
            CLOSE Cur_item;

            IF l_need_header_tax = 'Y' THEN

                --9. Get header tax info such as tax classification code,
                --exemption details, if not present at lines
                get_hdr_tax(
                    p_oks_rec => l_oks_hdr_rec,
                    p_okc_rec => l_okc_hdr_rec,
                    p_okc_line_rec => l_okc_line_rec,
                    px_rail_rec => G_RAIL_REC,
                    x_return_status => x_return_status);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_get_hdr_tax', 'x_return_status='||x_return_status);
                    print_g_rail_rec(
                        p_rail_rec => G_RAIL_REC,
                        p_msg => 'After calling get_hdr_tax on top line, G_RAIL_REC details',
                        p_level => FND_LOG.level_statement);
                END IF;

            END IF; --of IF l_need_header_tax = 'Y' THEN

        END IF; --of IF okc_line_csr%FOUND THEN - TOPLINE CSR
        CLOSE okc_line_csr;


        --10. if p_cle_id is that of a subline, get the subline amount and unit selling price,
        --else get the topline values
        IF (nvl(l_parent_cle_id, -99) = p_cle_id) THEN

            --p_cle_id is id of topline, do nothing
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.amount','p_cle_id='||p_cle_id||' is topline id');
            END IF;

        ELSE

            --p_cle_id is id of subline, get the subline amount
            G_RAIL_REC.UNIT_SELLING_PRICE := nvl(sub_line_rec.price_unit, sub_line_rec.price_negotiated);
            G_RAIL_REC.AMOUNT := nvl(sub_line_rec.price_negotiated, 0);

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.amount','p_cle_id='||p_cle_id||' is subline id, sub_line_rec.price_negotiated='||sub_line_rec.price_negotiated);
            END IF;

        END IF;


        --11. set other misc attributes
        G_RAIL_REC.WAREHOUSE_ID := G_RAIL_REC.INVENTORY_ORG_ID; -- added for Vertex

        OPEN cur_get_precision(G_RAIL_REC.CURRENCY_CODE);
        FETCH cur_get_precision INTO precision_rec;
        IF cur_get_precision%FOUND THEN
            G_RAIL_REC.MINIMUM_ACCOUNTABLE_UNIT := precision_rec.MINIMUM_ACCOUNTABLE_UNIT;
            G_RAIL_REC.PRECISION := precision_rec.PRECISION;
        END IF;
        CLOSE cur_get_precision;

        --12. if the calling module specifies an amount, use that instead of the line amount from DB.
        IF l_line_amount IS NOT NULL THEN
            G_RAIL_REC.AMOUNT := l_line_amount;
        END IF;



        --13. check to trx type
        --Added for tax bug # 4026206, trx type must be defined on contract or for org
        IF G_RAIL_REC.CUST_TRX_TYPE_ID IS NULL THEN
            OPEN get_operating_unit(G_RAIL_REC.ORG_ID);
            FETCH get_operating_unit INTO l_op_unit_name;
            CLOSE get_operating_unit;

            FND_MESSAGE.set_name(G_OKS_APP_NAME, 'OKS_NO_TRX_TYPE');
            FND_MESSAGE.set_token('NAME', l_op_unit_name);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.no_trx_type', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;
        -- End of added for tax bug # 4026206


        --14. populate transaction record
        transaction_rec.internal_organization_id := l_okc_hdr_rec.ORG_ID;
        transaction_rec.application_id := 515;
        transaction_rec.entity_code := 'OKC_K_HEADERS_B';
        transaction_rec.event_class_code := 'SALES_TRANSACTION_TAX_QUOTE';
        transaction_rec.event_type_code := 'CREATE';
        transaction_rec.trx_id := l_okc_hdr_rec.id;


        --15. populate  hz-related information
        tax_integration(
            p_chr_id => p_chr_id,
            px_rail_rec => G_RAIL_REC,
            x_return_status => x_return_status);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.after_tax_integration', 'x_return_status='||x_return_status);
        END IF;

        --in case the exemption control is null, we default it to 'S'
        G_RAIL_REC.tax_exempt_flag := nvl(G_RAIL_REC.tax_exempt_flag, 'S');

        --npalepu added on 11-jul-2006 for bug # 5380881
        --validating tax_exemptions
        IF G_RAIL_REC.EXEMPT_CERTIFICATE_NUMBER IS NOT NULL THEN
            BEGIN
                OPEN Cur_Batch_Source_Id(G_RAIL_REC.org_id);
                FETCH Cur_Batch_Source_Id INTO l_batch_source_id;
                CLOSE Cur_Batch_Source_Id;

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.validating_exemptions','calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS to validate tax exemptions'||
                        ' ,p_tax_exempt_number='|| G_RAIL_REC.EXEMPT_CERTIFICATE_NUMBER ||
                        ' ,p_tax_exempt_reason_code='|| G_RAIL_REC.EXEMPT_REASON_CODE ||
                        ' ,p_ship_to_org_id='|| G_RAIL_REC.ship_to_site_use_id ||
                        ' ,p_invoice_to_org_id='|| G_RAIL_REC.bill_to_site_use_id ||
                        ' ,p_bill_to_cust_account_id='|| G_RAIL_REC.BILL_TO_CUST_ACCT_ID ||
                        ' ,p_ship_to_party_site_id='|| G_RAIL_REC.SHIP_TO_PARTY_SITE_ID ||
                        ' ,p_bill_to_party_site_id='|| G_RAIL_REC.BILL_TO_PARTY_SITE_ID ||
                        ' ,p_org_id='|| G_RAIL_REC.org_id ||
                        ' ,p_bill_to_party_id='|| G_RAIL_REC.BILL_TO_PARTY_ID ||
                        ' ,p_legal_entity_id='|| NULL ||
                        ' ,p_trx_type_id='|| G_RAIL_REC.CUST_TRX_TYPE_ID ||
                        ' ,p_batch_source_id='|| l_batch_source_id ||
                        ' ,p_trx_date='|| G_RAIL_REC.trx_date ||
                        ' ,p_exemption_status='|| 'PMU' );
                END IF;

                ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
                        (p_tax_exempt_number => G_RAIL_REC.EXEMPT_CERTIFICATE_NUMBER,
                        p_tax_exempt_reason_code => G_RAIL_REC.EXEMPT_REASON_CODE,
                        p_ship_to_org_id => G_RAIL_REC.ship_to_site_use_id,
                        p_invoice_to_org_id => G_RAIL_REC.bill_to_site_use_id,
                        p_bill_to_cust_account_id => G_RAIL_REC.BILL_TO_CUST_ACCT_ID,
                        p_ship_to_party_site_id => G_RAIL_REC.SHIP_TO_PARTY_SITE_ID,
                        p_bill_to_party_site_id => G_RAIL_REC.BILL_TO_PARTY_SITE_ID,
                        p_org_id => G_RAIL_REC.org_id,
                        p_bill_to_party_id => G_RAIL_REC.BILL_TO_PARTY_ID,
                        p_legal_entity_id => NULL,
                        p_trx_type_id => G_RAIL_REC.CUST_TRX_TYPE_ID,
                        p_batch_source_id => l_batch_source_id,
                        p_trx_date => G_RAIL_REC.trx_date,
                        p_exemption_status => 'PMU',
                        x_valid_flag => l_valid_flag,
                        x_return_status => l_ret_stat,
                        x_msg_count => l_msg_count,
                        x_msg_data => l_msg_data);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(FND_LOG.level_statement, l_mod_name || '.After_VALIDATE_TAX_EXEMPTIONS', 'l_valid_flag='||l_valid_flag);
                End If;

                IF l_valid_flag <> 'Y' THEN
                       --reset the tax_exempt_flag to 'S'
                      G_RAIL_REC.TAX_EXEMPT_FLAG := 'S';
                      G_RAIL_REC.EXEMPT_CERTIFICATE_NUMBER := NULL;
                      G_RAIL_REC.EXEMPT_REASON_CODE := NULL;
                      IF l_oks_line_rec.TAX_EXEMPTION_ID IS NOT NULL THEN
                           G_RAIL_REC.tax_classification_code := NULL;
                      ELSIF l_need_header_tax = 'Y' AND l_oks_hdr_rec.TAX_EXEMPTION_ID IS NOT NULL THEN
                           G_RAIL_REC.tax_classification_code := NULL;
                      END IF;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN

                    IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                        --first log the sqlerrm
                        l_error_text := substr (SQLERRM, 1, 512);
                        FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.exemption_validation_error', l_error_text);
                        --then add it to the message api list
                        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                    END IF;
                    IF Cur_Batch_Source_Id%ISOPEN THEN
                        CLOSE Cur_Batch_Source_Id;
                    END IF;
                    RAISE FND_API.g_exc_unexpected_error;
            END;
        END IF;
        --end npalepu

        --16. get the default tcc if null
        --fix bug 4952080, need to call the defaulting logic if tax_classification_code is null
        IF G_RAIL_REC.tax_classification_code IS NULL THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.default_tcc','calling ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification to get default tcc'||
                ' ,p_ship_to_site_use_id='|| G_RAIL_REC.ship_to_site_use_id ||
                ' ,p_bill_to_site_use_id='|| G_RAIL_REC.bill_to_site_use_id ||
                ' ,p_inventory_item_id='|| G_RAIL_REC.inventory_item_id ||
                ' ,p_organization_id='|| G_RAIL_REC.org_id ||
                ' ,p_set_of_books_id='|| G_RAIL_REC.set_of_books_id ||
                ' ,p_trx_date='|| trunc(G_RAIL_REC.trx_date) ||
                ' ,p_trx_type_id='|| G_RAIL_REC.cust_trx_type_id ||
                ' ,p_internal_organization_id='|| G_RAIL_REC.org_id);
            END IF;

            --as per zx documentation,
            --the api ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
            --will either return a tcc or an exception
            BEGIN

                ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification(
                    p_ship_to_site_use_id => G_RAIL_REC.ship_to_site_use_id,
                    p_bill_to_site_use_id => G_RAIL_REC.bill_to_site_use_id,
                    p_inventory_item_id => G_RAIL_REC.inventory_item_id,
                    p_organization_id => G_RAIL_REC.org_id,
                    p_set_of_books_id => G_RAIL_REC.set_of_books_id,
                    p_trx_date => trunc(G_RAIL_REC.trx_date),
                    p_trx_type_id => G_RAIL_REC.cust_trx_type_id,
                    p_tax_classification_code => l_default_tax_code,
                    appl_short_name => 'OKS',
                    p_entity_code => 'OKC_K_HEADERS_B',
                    p_event_class_code => 'SALES_TRANSACTION_TAX_QUOTE',
                    p_application_id => 515,
                    p_internal_organization_id => G_RAIL_REC.org_id);

            EXCEPTION
                WHEN OTHERS THEN

                    IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                        --first log the sqlerrm
                        l_error_text := substr (SQLERRM, 1, 512);
                        FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.default_tcc_error', l_error_text);
                        --then add it to the message api list
                        FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
                    END IF;
                    RAISE FND_API.g_exc_unexpected_error;

            END; --of inner block

            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.default_tcc','after call to  ZX_AR_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification, p_tax_classification_code='||l_default_tax_code);
            END IF;

            G_RAIL_REC.tax_classification_code := l_default_tax_code;

        END IF; --of IF G_RAIL_REC.tax_classification_code IS NULL
        --end of bug 4952080


        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            print_g_rail_rec(
                p_rail_rec => G_RAIL_REC,
                p_msg => 'Final state of G_RAIL_REC details, before calling ZX_API_PUB.calculate_tax',
                p_level => FND_LOG.level_statement);
        END IF;


        --17. populate pl/sql global table
        init_zx_trxline_dist_tbl(p_rail_rec => G_RAIL_REC);


        --18. finally call the zx api to calculate tax
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calculate_tax','calling ZX_API_PUB.calculate_tax, p_quote_flag=Y, p_data_transfer_mode=PLS, p_validation_level=FND_API.G_VALID_LEVEL_FULL, transaction_rec_details.'||
            ' ,trec.internal_organization_id='||transaction_rec.internal_organization_id||
            ' ,trec.application_id='||transaction_rec.application_id||
            ' ,trec.entity_code='||transaction_rec.entity_code||
            ' ,trec.event_class_code='||transaction_rec.event_class_code||
            ' ,trec.event_type_code='||transaction_rec.event_type_code||
            ' ,trec.trx_id='||transaction_rec.trx_id);
        END IF;

        ZX_API_PUB.calculate_tax(
            p_api_version => p_api_version,
            p_init_msg_list => p_init_msg_list,
            p_commit => FND_API.G_FALSE,
            p_validation_level => FND_API.G_VALID_LEVEL_FULL,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_transaction_rec => transaction_rec,
            p_quote_flag => 'Y',
            p_data_transfer_mode => 'PLS',
            x_doc_level_recalc_flag => l_doc_level_recalc_flag);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_statement, l_mod_name||'.calculate_tax','after call to  ZX_API_PUB.calculate_tax, x_return_status='||x_return_status||' ,x_doc_level_recalc_flag='||l_doc_level_recalc_flag);
        END IF;

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --19. get the calculated tax value
        --query to get the calculated tax from the global temp table
        G_RAIL_REC.TAX_VALUE := 0;

        OPEN cur_tax_info(l_okc_hdr_rec.id);
        LOOP
            FETCH cur_tax_info INTO tax_rec;
            EXIT WHEN cur_tax_info%NOTFOUND;

            G_RAIL_REC.TAX_VALUE := G_RAIL_REC.TAX_VALUE + nvl(tax_rec.tax_amt,0);
            G_RAIL_REC.TAX_RATE := tax_rec.tax_rate;
            G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG := tax_rec.tax_amt_included_flag;

        END LOOP;
        CLOSE cur_tax_info;

        IF NVL(G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG, 'N') = 'N' THEN
            G_RAIL_REC.TOTAL_PLUS_TAX := NVL(G_RAIL_REC.AMOUNT, 0) + NVL(G_RAIL_REC.TAX_VALUE, 0);
            G_RAIL_REC.AMOUNT_INCLUDES_TAX_FLAG := 'N';
        ELSE
            G_RAIL_REC.TOTAL_PLUS_TAX := NVL(G_RAIL_REC.AMOUNT, 0);
        END IF;
        px_rail_rec := G_RAIL_REC;


        --20. log the tax details and exit
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name||'.end','x_return_status='||x_return_status||' ,px_rail_rec(key details). '||
            ' .AMOUNT=' || px_rail_rec.AMOUNT ||
            ' .TAX_VALUE=' || px_rail_rec.TAX_VALUE ||
            ' .TAX_RATE=' || px_rail_rec.TAX_RATE ||
            ' .AMOUNT_INCLUDES_TAX_FLAG=' || px_rail_rec.AMOUNT_INCLUDES_TAX_FLAG ||
            ' .TOTAL_PLUS_TAX=' || px_rail_rec.TOTAL_PLUS_TAX);

            print_g_rail_rec(
                p_rail_rec => px_rail_rec,
                p_msg => 'End get_tax, PX_RAIL_REC details',
                p_level => FND_LOG.level_procedure);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );


    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF okc_hdr_csr%ISOPEN THEN
                CLOSE okc_hdr_csr;
            END IF;

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF okc_line_csr%ISOPEN THEN
                CLOSE okc_line_csr;
            END IF;

            IF oks_line_csr%ISOPEN THEN
                CLOSE oks_line_csr;
            END IF;

            IF cur_sub_lines%ISOPEN THEN
                CLOSE cur_sub_lines;
            END IF;

            IF cur_item%ISOPEN THEN
                CLOSE cur_item;
            END IF;

            IF cur_get_precision%ISOPEN THEN
                CLOSE cur_get_precision;
            END IF;

            IF get_operating_unit%ISOPEN THEN
                CLOSE get_operating_unit;
            END IF;

            IF cur_tax_info%ISOPEN THEN
                CLOSE cur_tax_info;
            END IF;

            --npalepu added on 11-jul-2006 for bug # 5380881
            IF Cur_Batch_Source_Id%ISOPEN THEN
                CLOSE Cur_Batch_Source_Id;
            END IF;
            --end npalepu

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

            IF okc_hdr_csr%ISOPEN THEN
                CLOSE okc_hdr_csr;
            END IF;

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF okc_line_csr%ISOPEN THEN
                CLOSE okc_line_csr;
            END IF;

            IF oks_line_csr%ISOPEN THEN
                CLOSE oks_line_csr;
            END IF;

            IF cur_sub_lines%ISOPEN THEN
                CLOSE cur_sub_lines;
            END IF;

            IF cur_item%ISOPEN THEN
                CLOSE cur_item;
            END IF;

            IF cur_get_precision%ISOPEN THEN
                CLOSE cur_get_precision;
            END IF;

            IF get_operating_unit%ISOPEN THEN
                CLOSE get_operating_unit;
            END IF;

            IF cur_tax_info%ISOPEN THEN
                CLOSE cur_tax_info;
            END IF;

            --npalepu added on 11-jul-2006 for bug # 5380881
            IF Cur_Batch_Source_Id%ISOPEN THEN
                CLOSE Cur_Batch_Source_Id;
            END IF;
            --end npalepu

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

            IF okc_hdr_csr%ISOPEN THEN
                CLOSE okc_hdr_csr;
            END IF;

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF okc_line_csr%ISOPEN THEN
                CLOSE okc_line_csr;
            END IF;

            IF oks_line_csr%ISOPEN THEN
                CLOSE oks_line_csr;
            END IF;

            IF cur_sub_lines%ISOPEN THEN
                CLOSE cur_sub_lines;
            END IF;

            IF cur_item%ISOPEN THEN
                CLOSE cur_item;
            END IF;

            IF cur_get_precision%ISOPEN THEN
                CLOSE cur_get_precision;
            END IF;

            IF get_operating_unit%ISOPEN THEN
                CLOSE get_operating_unit;
            END IF;

            IF cur_tax_info%ISOPEN THEN
                CLOSE cur_tax_info;
            END IF;

            --npalepu added on 11-jul-2006 for bug # 5380881
            IF Cur_Batch_Source_Id%ISOPEN THEN
                CLOSE Cur_Batch_Source_Id;
            END IF;
            --end npalepu

    END GET_TAX;



    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_HEADERS_B:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE

            OKS_K_HEADERS_BH:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER and EXEMPT_REASON_CODE
    */
    PROCEDURE TAX_MIGRATION
    (
     ERRBUF OUT NOCOPY VARCHAR2,
     RETCODE OUT NOCOPY NUMBER
     ) IS

    l_module_name CONSTANT VARCHAR2(30) := 'TAX_MIGRATION';

    BEGIN
        RETCODE := 0; --0 for success, 1 for warning, 2 for error
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Starting Concurrent Program: '|| G_PKG_NAME || '.' || l_module_name);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'time: '|| to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

        --migrate the header level tax_exemption_id to exempt_certificate_number and exempt_reason_code
        --npalepu updating tax_code and tax_exemption_id to null for bug # 4908543
        UPDATE /*+  parallel(oks)  */ OKS_K_HEADERS_B  oks
        SET (EXEMPT_CERTIFICATE_NUMBER, EXEMPT_REASON_CODE)
        = (SELECT zx.EXEMPT_CERTIFICATE_NUMBER, zx.EXEMPT_REASON_CODE
           FROM ZX_EXEMPTIONS zx
           WHERE zx.TAX_EXEMPTION_ID = oks.tax_exemption_id)
        ,TAX_EXEMPTION_ID = NULL
        ,TAX_CODE = NULL
        WHERE oks.tax_exemption_id IS NOT NULL
        AND (oks.EXEMPT_CERTIFICATE_NUMBER IS NULL OR oks.EXEMPT_REASON_CODE IS NULL);
        --end npalepu

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Finished migrating tax_exemption_id in OKS_K_HEADERS_B');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'time: '|| to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));

        /*npalepu added migration of tax_exemption_id to exempt_certificate_number and exempt_reason_code in oks_k_headers_bh table.
        updating tax_code and tax_exemption_id to null for bug # 4908543 */
        UPDATE /*+  parallel(oks)  */ OKS_K_HEADERS_BH  oks
        SET (EXEMPT_CERTIFICATE_NUMBER, EXEMPT_REASON_CODE)
        = (SELECT zx.EXEMPT_CERTIFICATE_NUMBER, zx.EXEMPT_REASON_CODE
           FROM ZX_EXEMPTIONS zx
           WHERE zx.TAX_EXEMPTION_ID = oks.tax_exemption_id)
        ,TAX_EXEMPTION_ID = NULL
        ,TAX_CODE = NULL
        WHERE oks.tax_exemption_id IS NOT NULL
        AND (oks.EXEMPT_CERTIFICATE_NUMBER IS NULL OR oks.EXEMPT_REASON_CODE IS NULL);
        --end npalepu

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Finished migrating tax_exemption_id in OKS_K_HEADERS_BH');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'time: '|| to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
        --end npalepu

        COMMIT;

        FND_FILE.PUT_LINE(FND_FILE.LOG,'End Concurrent Program - Success, time: '|| to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') ||' ,retcode='|| retcode);

    EXCEPTION
        WHEN OTHERS THEN
            retcode := 2;
            errbuf := SQLCODE || SQLERRM;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'End Concurrent Program - Error, time: '|| to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') ||' ,retcode='|| retcode);

    END TAX_MIGRATION;


--npalepu added on 19-jun-2006 for bug # 4908543.
PROCEDURE Update_Tax_BMGR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Num_Workers in number)
IS
BEGIN
--
-- Manager processing for OKS_K_LINES_B table
--
        fnd_file.put_line(FND_FILE.LOG, 'Start of Update_Tax_BMGR ');
        fnd_file.put_line(FND_FILE.LOG, '  P_batch_size : '||P_batch_size);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'starting oks_k_lines_b update worker ');

        AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf,
                                             X_retcode,
                                             'OKS',
                                             'OKSTAXBWKR',
                                             P_batch_size,
                                             P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'X_errbuf  : '||X_errbuf);
        fnd_file.put_line(FND_FILE.LOG, 'X_retcode : '||X_retcode);

END Update_Tax_BMGR;

PROCEDURE Update_Tax_HMGR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Num_Workers in number)
IS
BEGIN
--
-- Manager processing for OKS_K_LINES_BH table
--
        fnd_file.put_line(FND_FILE.LOG, 'Start of Update_Tax_HMGR ');
        fnd_file.put_line(FND_FILE.LOG, '  P_batch_size : '||P_batch_size);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'starting oks_k_lines_bh update worker ');

        AD_CONC_UTILS_PKG.submit_subrequests(X_errbuf,
                                             X_retcode,
                                             'OKS',
                                             'OKSTAXHWKR',
                                             P_batch_size,
                                             P_Num_Workers);

        fnd_file.put_line(FND_FILE.LOG, 'X_errbuf  : '||X_errbuf);
        fnd_file.put_line(FND_FILE.LOG, 'X_retcode : '||X_retcode);

END Update_Tax_HMGR;

    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_LINES_B:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER, EXEMPT_REASON_CODE and TAX_CLASSIFICATION_CODE
                TAX_CODE --> TAX_CLASSIFICATION_CODE
    */
PROCEDURE Update_Tax_BWKR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Worker_Id   in number,
                          P_Num_Workers in number)
IS
l_worker_id             number;
l_product               varchar2(30) := 'OKS';
l_table_name            varchar2(30) := 'OKS_K_LINES_B';
l_update_name           varchar2(30) := 'OKSTAXUPG_CP';
l_status                varchar2(30);
l_industry              varchar2(30);
l_retstatus             boolean;
l_table_owner           varchar2(30);
l_any_rows_to_process   boolean;
l_start_rowid           rowid;
l_end_rowid             rowid;
l_rows_processed        number;
BEGIN
--
-- get schema name of the table for ROWID range processing
--
        l_retstatus := fnd_installation.get_app_info(l_product,
                                                     l_status,
                                                     l_industry,
                                                     l_table_owner);
        if ((l_retstatus = FALSE)  OR (l_table_owner is null))
        then
                raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
        end if;

        fnd_file.put_line(FND_FILE.LOG, 'Start of upgrade script for OKS_K_LINES_B table ');
        fnd_file.put_line(FND_FILE.LOG, '  P_Worker_Id : '||P_Worker_Id);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

--
-- Worker processing
--
        BEGIN
                ad_parallel_updates_pkg.initialize_rowid_range(ad_parallel_updates_pkg.ROWID_RANGE,
                                                               l_table_owner,
                                                               l_table_name,
                                                               l_update_name,
                                                               P_worker_id,
                                                               P_num_workers,
                                                               P_batch_size,
                                                               0);
                ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                                         l_end_rowid,
                                                         l_any_rows_to_process,
                                                         P_batch_size,
                                                         TRUE);
                while (l_any_rows_to_process = TRUE)
                loop

                        UPDATE (SELECT /*+ ROWID(oks) LEADING(oks) */ oks.id,
                                        oks.TAX_CLASSIFICATION_CODE TAX_CLASSIFICATION_CODE,
                                        oks.TAX_CODE TAX_CODE,
                                        oks.EXEMPT_CERTIFICATE_NUMBER EXEMPT_CERTIFICATE_NUMBER,
                                        oks.EXEMPT_REASON_CODE EXEMPT_REASON_CODE,
                                        oks.TAX_EXEMPTION_ID TAX_EXEMPTION_ID
                                FROM OKS_K_LINES_B oks
                                WHERE oks.rowid BETWEEN l_start_rowid and l_end_rowid
                                --npalepu added on 07-jul-2006 for bug # 4908543
                                AND (oks.TAX_CODE IS NOT NULL OR TAX_EXEMPTION_ID IS NOT NULL)
                                --end npalepu
                                ) oks1
                        set  TAX_CLASSIFICATION_CODE = (CASE WHEN oks1.TAX_CODE IS NOT NULL
                                                                  AND oks1.TAX_CLASSIFICATION_CODE IS NULL
                                                             THEN
                                                               (SELECT zx.TAX_CLASSIFICATION_CODE
                                                                FROM  ZX_ID_TCC_MAPPING_ALL zx /* npalepu replaced  ZX_ID_TCC_MAPPING with  ZX_ID_TCC_MAPPING_ALL on 29-jun-2006 for bug # 4908543 */
                                                                WHERE zx.TAX_RATE_CODE_ID = oks1.TAX_CODE
                                                                AND zx.SOURCE = 'AR')
                                                        --npalepu added on 29-jun-2006 for bug # 4908543
                                                             WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL)
                                                              THEN
                                                                 (SELECT zx.TAX_CODE
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        --end npalepu
                                                        ELSE
                                                               oks1.TAX_CLASSIFICATION_CODE
                                                        END)
                          ,EXEMPT_CERTIFICATE_NUMBER = (CASE WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL
                                                                    AND
                                                                   (oks1.EXEMPT_CERTIFICATE_NUMBER IS NULL
                                                                     OR oks1.EXEMPT_REASON_CODE IS NULL))
                                                              THEN
                                                                 (SELECT zx.CUSTOMER_EXEMPTION_NUMBER /* npalepu replaced zx.EXEMPT_CERTIFICATE_NUMBER with zx.CUSTOMER_EXEMPTION_NUMBER for bug # 4908543. */
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx /* npalepu replaced ZX_EXEMPTIONS with RA_TAX_EXEMPTIONS_ALL for bug # 4908543. */
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        ELSE
                                                                 oks1.EXEMPT_CERTIFICATE_NUMBER
                                                        END)
                          ,EXEMPT_REASON_CODE        = (CASE WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL
                                                                   AND
                                                                  (oks1.EXEMPT_CERTIFICATE_NUMBER IS NULL
                                                                    OR oks1.EXEMPT_REASON_CODE IS NULL))
                                                             THEN
                                                                 (SELECT zx.REASON_CODE /* npalepu replaced zx.EXEMPT_REASON_CODE with zx.REASON_CODE for bug # 4908543. */
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx /* npalepu replaced ZX_EXEMPTIONS with RA_TAX_EXEMPTIONS_ALL by bug # 4908543. */
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        ELSE
                                                                 oks1.EXEMPT_REASON_CODE
                                                        END)
                          --npalepu added on 29-jun-2006 for bug # 4908543
                          ,TAX_EXEMPTION_ID          = NULL
                          ,TAX_CODE                  = NULL;
                          --end npalepu

                        l_rows_processed := SQL%ROWCOUNT;
                        ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                                      l_end_rowid);
                        commit;
                        ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
                                                                l_end_rowid,
                                                                l_any_rows_to_process,
                                                                P_batch_size,
                                                                FALSE);
                end loop;
                fnd_file.put_line(FND_FILE.LOG,'Upgrade for tax columns in OKS_K_LINES_B table completed successfully');
                X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
                X_errbuf  := ' ';
        EXCEPTION
        WHEN OTHERS THEN
                X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
                X_errbuf  := SQLERRM;
                fnd_file.put_line(FND_FILE.LOG,'X_errbuf : '||X_errbuf);
                fnd_file.put_line(FND_FILE.LOG,'  ');
                raise;
        END;
END  Update_Tax_BWKR;

    /*
        This is a concurrent program to migrate the pre-R12 tax data
        to R12 eBTax.  We do not remove the old values.
            OKS_K_LINES_BH:
                TAX_EXEMPTION_ID --> EXEMPT_CERTIFICATE_NUMBER, EXEMPT_REASON_CODE and TAX_CLASSIFICATION_CODE
                TAX_CODE --> TAX_CLASSIFICATION_CODE
    */
PROCEDURE Update_Tax_HWKR(X_errbuf     out NOCOPY varchar2,
                          X_retcode    out NOCOPY varchar2,
                          P_batch_size  in number,
                          P_Worker_Id   in number,
                          P_Num_Workers in number)
IS
l_worker_id             number;
l_product               varchar2(30) := 'OKS';
l_table_name            varchar2(30) := 'OKS_K_LINES_BH';
l_update_name           varchar2(30) := 'OKSTAXUPH_CP';
l_status                varchar2(30);
l_industry              varchar2(30);
l_retstatus             boolean;
l_table_owner           varchar2(30);
l_any_rows_to_process   boolean;
l_start_rowid           rowid;
l_end_rowid             rowid;
l_rows_processed        number;
BEGIN
--
-- get schema name of the table for ROWID range processing
--
        l_retstatus := fnd_installation.get_app_info(l_product,
                                                     l_status,
                                                     l_industry,
                                                     l_table_owner);
        if ((l_retstatus = FALSE)  OR (l_table_owner is null))
        then
                raise_application_error(-20001,'Cannot get schema name for product : '||l_product);
        end if;

        fnd_file.put_line(FND_FILE.LOG, 'Start of upgrade script for OKS_K_LINES_BH table ');
        fnd_file.put_line(FND_FILE.LOG, '  P_Worker_Id : '||P_Worker_Id);
        fnd_file.put_line(FND_FILE.LOG, 'P_Num_Workers : '||P_Num_Workers);

--
-- Worker processing
--
        BEGIN
                ad_parallel_updates_pkg.initialize_rowid_range(ad_parallel_updates_pkg.ROWID_RANGE,
                                                               l_table_owner,
                                                               l_table_name,
                                                               l_update_name,
                                                               P_worker_id,
                                                               P_num_workers,
                                                               P_batch_size,
                                                               0);
                ad_parallel_updates_pkg.get_rowid_range( l_start_rowid,
                                                         l_end_rowid,
                                                         l_any_rows_to_process,
                                                         P_batch_size,
                                                         TRUE);
                while (l_any_rows_to_process = TRUE)
                loop
                        UPDATE (SELECT /*+ ROWID(oks) LEADING(oks) */ oks.id,
                                        oks.TAX_CLASSIFICATION_CODE TAX_CLASSIFICATION_CODE,
                                        oks.TAX_CODE TAX_CODE,
                                        oks.EXEMPT_CERTIFICATE_NUMBER EXEMPT_CERTIFICATE_NUMBER,
                                        oks.EXEMPT_REASON_CODE EXEMPT_REASON_CODE,
                                        oks.TAX_EXEMPTION_ID TAX_EXEMPTION_ID
                                FROM OKS_K_LINES_BH oks
                                WHERE oks.rowid BETWEEN l_start_rowid and l_end_rowid
                                --npalepu added on 07-jul-2006 for bug # 4908543
                                AND (oks.TAX_CODE IS NOT NULL OR TAX_EXEMPTION_ID IS NOT NULL)
                                --end npalepu
                                ) oks1
                        set  TAX_CLASSIFICATION_CODE = (CASE WHEN oks1.TAX_CODE IS NOT NULL
                                                                  AND oks1.TAX_CLASSIFICATION_CODE IS NULL
                                                             THEN
                                                               (SELECT zx.TAX_CLASSIFICATION_CODE
                                                                FROM  ZX_ID_TCC_MAPPING_ALL zx /* npalepu replaced  ZX_ID_TCC_MAPPING with  ZX_ID_TCC_MAPPING_ALL on 29-jun-2006 for bug # 4908543 */
                                                                WHERE zx.TAX_RATE_CODE_ID = oks1.TAX_CODE
                                                                AND zx.SOURCE = 'AR')
                                                        --npalepu added on 29-jun-2006 for bug # 4908543
                                                             WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL)
                                                              THEN
                                                                 (SELECT zx.TAX_CODE
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        --end npalepu
                                                        ELSE
                                                               oks1.TAX_CLASSIFICATION_CODE
                                                        END)
                          ,EXEMPT_CERTIFICATE_NUMBER = (CASE WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL
                                                                    AND
                                                                   (oks1.EXEMPT_CERTIFICATE_NUMBER IS NULL
                                                                     OR oks1.EXEMPT_REASON_CODE IS NULL))
                                                              THEN
                                                                 (SELECT zx.CUSTOMER_EXEMPTION_NUMBER /* npalepu replaced zx.EXEMPT_CERTIFICATE_NUMBER with zx.CUSTOMER_EXEMPTION_NUMBER for bug # 4908543. */
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx /* npalepu replaced ZX_EXEMPTIONS with RA_TAX_EXEMPTIONS_ALL for bug # 4908543. */
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        ELSE
                                                                 oks1.EXEMPT_CERTIFICATE_NUMBER
                                                        END)
                          ,EXEMPT_REASON_CODE        = (CASE WHEN (oks1.TAX_EXEMPTION_ID IS NOT NULL
                                                                   AND
                                                                  (oks1.EXEMPT_CERTIFICATE_NUMBER IS NULL
                                                                    OR oks1.EXEMPT_REASON_CODE IS NULL))
                                                             THEN
                                                                 (SELECT zx.REASON_CODE /* npalepu replaced zx.EXEMPT_REASON_CODE with zx.REASON_CODE for bug # 4908543. */
                                                                  FROM RA_TAX_EXEMPTIONS_ALL zx /* npalepu replaced ZX_EXEMPTIONS with RA_TAX_EXEMPTIONS_ALL for bug # 4908543. */
                                                                  WHERE zx.TAX_EXEMPTION_ID = oks1.TAX_EXEMPTION_ID )
                                                        ELSE
                                                                 oks1.EXEMPT_REASON_CODE
                                                        END)
                          --npalepu added tax_exemption_code on 29-jun-2006 for bug # 4908543
                          ,TAX_EXEMPTION_ID          = NULL
                          ,TAX_CODE                  = NULL;
                          --end npalepu

                        l_rows_processed := SQL%ROWCOUNT;
                        ad_parallel_updates_pkg.processed_rowid_range(l_rows_processed,
                                                                      l_end_rowid);
                        commit;
                        ad_parallel_updates_pkg.get_rowid_range(l_start_rowid,
                                                                l_end_rowid,
                                                                l_any_rows_to_process,
                                                                P_batch_size,
                                                                FALSE);
                end loop;
                fnd_file.put_line(FND_FILE.LOG,'Upgrade for tax columns in OKS_K_LINES_BH table completed successfully');
                X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
                X_errbuf  := ' ';
        EXCEPTION
        WHEN OTHERS THEN
                X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
                X_errbuf  := SQLERRM;
                fnd_file.put_line(FND_FILE.LOG,'X_errbuf : '||X_errbuf);
                fnd_file.put_line(FND_FILE.LOG,'  ');
                raise;
        END;
END  Update_Tax_HWKR;
--end npalepu


END OKS_TAX_UTIL_PVT;




/
