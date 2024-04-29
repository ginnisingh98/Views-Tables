--------------------------------------------------------
--  DDL for Package Body OKS_QA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QA_DATA_INTEGRITY" AS
    /* $Header: OKSRQADB.pls 120.56.12010000.9 2009/11/13 12:31:16 spingali ship $ */


    G_BULK_FETCH_LIMIT           CONSTANT NUMBER := 1000;

    /*============================================================================+
    | Procedure:           get_line_number
    |
    | Purpose:             Given a line id it will return the line number.
    |
    | In Parameters:       p_cle_id  The line id
    |
    +============================================================================*/
    FUNCTION get_line_number
    (
     p_cle_id                   IN  NUMBER
     )
    RETURN VARCHAR2 IS

    CURSOR l_get_top_line_number_csr (p_line_id NUMBER) IS
        SELECT line_number, cle_id
        FROM   OKC_K_LINES_B
        WHERE id = p_line_id;


    l_line_num          VARCHAR2(150);
    l_top_line_num      VARCHAR2(150);
    l_cle_id            NUMBER;

    BEGIN

        OPEN l_get_top_line_number_csr(p_cle_id);
        FETCH l_get_top_line_number_csr INTO l_line_num, l_cle_id;
        CLOSE l_get_top_line_number_csr;

        IF l_cle_id IS NOT NULL THEN
            OPEN l_get_top_line_number_csr(l_cle_id);
            FETCH l_get_top_line_number_csr INTO l_top_line_num, l_cle_id;
            CLOSE l_get_top_line_number_csr;
            l_line_num := l_top_line_num || '.' || l_line_num;
        END IF;


        IF l_line_num IS NULL THEN
            RETURN('x');
        ELSE
            RETURN(l_line_num);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            -- verify that cursor was closed
            IF l_get_top_line_number_csr%ISOPEN THEN
                CLOSE l_get_top_line_number_csr;
            END IF;
            RETURN('x');

    END get_line_number;

    /*============================================================================+
    | Procedure:           get_contract_name
    |
    | Purpose:             Given a contract header id it will return the
    |                      <contract number, contract modifier>
    |
    | In Parameters:       p_chr_id  The contract header id
    |
    +============================================================================*/
    FUNCTION get_contract_name
    (
     p_chr_id                   IN  NUMBER
     )
    RETURN VARCHAR2 IS
    l_contr_name VARCHAR2(3300);

    CURSOR get_contr_name(l_chr_id NUMBER) IS
        SELECT contract_number, contract_number_modifier
        FROM okc_k_headers_all_b WHERE id = p_chr_id;
    l_contr_num VARCHAR2(120);
    l_contr_modifier VARCHAR2(120);

    BEGIN
        OPEN get_contr_name(p_chr_id);
        FETCH get_contr_name INTO l_contr_num, l_contr_modifier;
        IF get_contr_name%FOUND THEN
            l_contr_name := l_contr_num;
            IF l_contr_modifier IS NOT NULL THEN
                l_contr_name := l_contr_name || ', ' || l_contr_modifier;
            END IF;
        END IF;
        CLOSE get_contr_name;

        RETURN l_contr_name;
    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            RETURN 'x';
    END get_contract_name;



    /*============================================================================+
    | Procedure:           get_line_name
    |
    | Purpose:
    |
    | In Parameters:       p_cle_id            contract line id
    |
    +============================================================================*/
    FUNCTION get_line_name
    (
     p_cle_id                   IN  NUMBER
     )
    RETURN VARCHAR2 IS

    CURSOR l_chk_cle_csr IS
        SELECT clev.cle_id, RTRIM(clev.line_number) line_number
        FROM
               OKC_K_LINES_V clev
        WHERE
        clev.id = p_cle_id;

    CURSOR l_get_top_line_number_csr (p_line_id NUMBER) IS
        SELECT line_number
        FROM   OKC_K_LINES_B
        WHERE id = p_line_id;

    CURSOR l_line_name_csr IS
        SELECT RTRIM(RTRIM(line_number) || ', ' || RTRIM(lsev.name) || ' ' ||
                     RTRIM(clev.name)) "LINE_NAME"
        FROM   OKC_LINE_STYLES_V lsev,
               OKC_K_LINES_V clev
        WHERE  lsev.id = clev.lse_id
        AND    clev.id = p_cle_id;

    l_line_name_rec l_line_name_csr%ROWTYPE;
    l_chk_cle_rec   l_chk_cle_csr%ROWTYPE;
    l_line_name     VARCHAR2(1000);
    l_get_top_line_number_rec l_get_top_line_number_csr%ROWTYPE;
    BEGIN


        OPEN l_chk_cle_csr;
        FETCH l_chk_cle_csr INTO l_chk_cle_rec;
        IF  l_chk_cle_rec.cle_id IS NULL
            THEN
            OPEN l_line_name_csr;
            FETCH l_line_name_csr INTO l_line_name_rec;
            CLOSE l_line_name_csr;

            l_line_name := l_line_name_rec.line_name;

        ELSE
            OPEN l_get_top_line_number_csr (l_chk_cle_rec.cle_id);
            FETCH l_get_top_line_number_csr INTO l_get_top_line_number_rec;
            CLOSE l_get_top_line_number_csr;

            OPEN l_line_name_csr;
            FETCH l_line_name_csr INTO l_line_name_rec;
            CLOSE l_line_name_csr;

            l_line_name := l_get_top_line_number_rec.line_number || '.' || l_line_name_rec.line_name;

        END IF; --IF  l_chk_cle_rec.cle_id IS NULL

        CLOSE l_chk_cle_csr;

        IF l_line_name_rec.line_name IS NULL THEN
            RETURN('No Line Name Found');
        ELSE
            RETURN(l_line_name);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            -- verify that cursor was closed
            IF l_line_name_csr%ISOPEN THEN
                CLOSE l_line_name_csr;
            END IF;
            RETURN('Error getting Line Name');
    END get_line_name;

    /*============================================================================+
    | Procedure:           get_renewal_status
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            contract id
    |added for bug 4069048

    +============================================================================*/
    FUNCTION get_renewal_status
    (
     p_chr_id                   IN  NUMBER
     )RETURN VARCHAR2 IS


    CURSOR l_renewal_sts_csr IS
        SELECT renewal_status
        FROM
               OKS_K_HEADERS_B
        WHERE
        chr_id = p_chr_id;

    l_renewal_sts  VARCHAR2(30);
    BEGIN
        OPEN l_renewal_sts_csr;
        FETCH l_renewal_sts_csr INTO l_renewal_sts;
        CLOSE l_renewal_sts_csr;

        IF l_renewal_sts IS NULL THEN
            RETURN '-999';
        ELSE
            RETURN l_renewal_sts;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            -- verify that cursor was closed
            IF l_renewal_sts_csr%ISOPEN THEN
                CLOSE l_renewal_sts_csr;
            END IF;


    END get_renewal_status;




    /*============================================================================+
    | Procedure:           Check_PO_Flag
    |
    | Purpose:             Checks PO flag and number at contract level.
    |                      If PO flag is 'Y' then po number is required.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_PO_Flag
    (
     x_return_status             OUT NOCOPY VARCHAR2,
     p_chr_id                    IN NUMBER
     )
    IS
    -- Gets PO number at contract level.
    CURSOR get_po IS
        SELECT CUST_PO_NUMBER_REQ_YN, CUST_PO_NUMBER
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id AND CUST_PO_NUMBER_REQ_YN = 'Y';

    l_po_flag    VARCHAR2(3);
    l_po_num     VARCHAR2(150);
    l_null       VARCHAR2(200);
    l_return_status VARCHAR2(1);
    l_renewal_status  VARCHAR2(30);

    BEGIN
        l_return_status := OKC_API.G_RET_STS_SUCCESS;
        --adding the following code for Bug#4069048
        -- get renewal status to see if this is called for Electronic renewal
        -- if so bypass the PO Number  validation
        l_renewal_status := get_renewal_status(p_chr_id);

        --Bug 4673694 in R12 the renewal status codes have been modified
        --if nvl(l_renewal_status ,'-99') <> 'QAS' and nvl(l_renewal_status, '-99') <> 'ERN_QA_CHECK_FAIL' then
        IF nvl(l_renewal_status, '-99') <> 'PEND_PUBLISH' THEN

            -- If PO Flag has been set at contract level then PO number should not be null
            OPEN get_po;
            FETCH get_po INTO l_po_flag, l_po_num;
            IF get_po%FOUND THEN
                IF l_po_num IS NULL THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_PO_NUM_REQUIRED
                                        );
                    -- notify caller of an error
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF;
            CLOSE get_po;
        END IF;
        x_return_status := l_return_status;



    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
            IF get_po%ISOPEN THEN
                CLOSE get_po;
            END IF;

    END Check_PO_Flag;

    /*============================================================================+
    | Procedure:           Check_Service_PO_Flag
    |
    | Purpose:             Checks service PO flag and number.
    |                      If service PO flag is 'Y' then service po number is
    |                      required.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_Service_PO_Flag
    (
     x_return_status             OUT NOCOPY VARCHAR2,
     p_chr_id                    IN NUMBER
     )
    IS

    -- Gets service PO from SPO rules.
    CURSOR rules_cur IS
        SELECT SERVICE_PO_NUMBER sr_po_num, SERVICE_PO_REQUIRED  sr_po_flag
        FROM
            OKS_K_HEADERS_B
        WHERE   chr_id = p_chr_id;

    l_sr_po_flag    VARCHAR2(3);
    l_sr_po_num     VARCHAR2(150);
    l_null       VARCHAR2(200);

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- Check if Service PO flag has been set for SPO rule
        OPEN rules_cur;
        FETCH rules_cur INTO l_sr_po_num, l_sr_po_flag;
        CLOSE rules_cur;
        -- If PO flag is set for renewal then check if the po number has been entered.
        IF l_sr_po_flag = 'Y' AND l_sr_po_num IS NULL THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_SERVICE_PO_NUM
                                );
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;


    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Check_Service_PO_Flag;

    /*============================================================================+
    | Procedure:           Check_Currency_Conv_Type
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_Currency_Conv_Type
    (
     x_return_status             OUT NOCOPY VARCHAR2,
     p_chr_id                    IN NUMBER
     )
    IS
    to_currency VARCHAR2(30); -- vendor currency code
    from_currency VARCHAR2(30);
    l_org_id NUMBER;
    l_rgp_id NUMBER;
    l_conversion_type VARCHAR2(30);

    CURSOR get_contract_info IS
        SELECT currency_code, authoring_org_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;
    -- CVN
    CURSOR get_rule IS
        SELECT CONVERSION_TYPE --object1_id1
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN get_contract_info;
        FETCH get_contract_info INTO from_currency, l_org_id;
        CLOSE get_contract_info;
        to_currency := OKC_CURRENCY_API.GET_OU_CURRENCY (p_ORG_ID => l_org_id);

        IF from_currency <> to_currency THEN
            OPEN get_rule;
            FETCH get_rule INTO l_conversion_type;
            IF get_rule%NOTFOUND THEN
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_CURR_CONV_REQUIRED
                                    );
                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            CLOSE get_rule;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Check_Currency_Conv_Type;

    /*============================================================================+
    | Procedure:           Check_Price_List_Currency
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/

    -- GCHADHA --
    -- 28 - OCT - 2004 --
    -- MULTI CURRENCY PRICE LIST PROJECT --
    -- VALIDATE THE HEADER AND LINES LEVEL PRICELIST
    -- IF INVALID THROW THE APPROPRIATE ERROR
    PROCEDURE Check_Price_List_Currency
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     )
    IS

    CURSOR get_hdr_info(p_chr_id NUMBER) IS
        SELECT currency_code, price_list_id, sts_code
        FROM okc_k_headers_all_b WHERE id = p_chr_id;

    CURSOR get_status(l_sts_code VARCHAR) IS
        SELECT ste_code
        FROM okc_statuses_b
        WHERE ste_code = 'ENTERED' AND code = l_sts_code;

    /*cursor get_price_list(l_price_list_id number) is
    SELECT CURRENCY_CODE
    FROM QP_LIST_HEADERS_B
    WHERE list_type_code IN ('PRL','AGR')
    AND id1 = l_price_list_id;*/

    CURSOR get_line_info(p_chr_id NUMBER) IS
        /**
        SELECT  line_number, price_list_id, sts_code
        FROM okc_k_lines_b WHERE chr_id = p_chr_id
        AND lse_id IN (1, 12, 46, 19)
        AND date_cancelled IS NULL  ; --Changes [llc]
        **/
        --bug 5442886
        SELECT line_number, price_list_id
        FROM okc_k_lines_b,
             okc_statuses_b
        WHERE chr_id = p_chr_id
        AND lse_id IN (1,12,46,19)
        AND ste_code = 'ENTERED'
        AND code = sts_code
        AND date_cancelled IS NULL;

    TYPE chr150_tbl_type IS TABLE OF okc_k_lines_b.line_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_line_number_tbl    chr150_tbl_type;
    l_price_list_id_tbl  num_tbl_type;

    -- GCHADHA --
    -- BUG 4048186 --

    CURSOR get_renewal_info(p_chr_id IN NUMBER) IS
        SELECT RENEWAL_PRICE_LIST FROM OKS_K_HEADERS_B
        WHERE CHR_ID = p_chr_id;

    l_renewal_price_list_id NUMBER;

    -- END GCHADHA --

    l_price_list_curr VARCHAR2(90);
    l_currency_code VARCHAR2(30);
    l_price_list_id NUMBER;
    l_line_number   NUMBER;
    l_pricing_effective_date   DATE;
    l_validate_result          VARCHAR2(1);
    l_sts_code VARCHAR2(30);
    l_hdr_ste_code VARCHAR2(30);
    l_line_ste_code VARCHAR2(30);

    BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN get_hdr_info(p_chr_id);
        FETCH get_hdr_info INTO l_currency_code, l_price_list_id, l_sts_code;
        CLOSE get_hdr_info;

        OPEN get_status(l_sts_code);
        FETCH get_status INTO l_hdr_ste_code;
        CLOSE get_status;
        /*Open get_price_list(l_price_list_id);
        Fetch get_price_list into l_price_list_curr;
        Close get_price_list; */

        -- Check for hdr level pricelist only for entered status contracts.
        IF l_hdr_ste_code = 'ENTERED' THEN
            QP_UTIL_PUB.Validate_Price_list_Curr_code(
                                                      l_price_list_id => l_price_list_id
                                                      , l_currency_code => l_currency_code
                                                      , l_pricing_effective_date => l_pricing_effective_date
                                                      , l_validate_result => l_validate_result);




            IF UPPER(nvl(l_validate_result, 'N')) <> 'Y' THEN
                --	Throw error in check list
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_PRICE_LIST_CURR_H -- MSG FOR INVALID PL AT HDR
                                    );
                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;


            -- CHECK RENEWAL PRICE LIST --
            OPEN get_renewal_info(p_chr_id);
            FETCH get_renewal_info INTO l_renewal_price_list_id;
            CLOSE get_renewal_info;

            IF NVL(l_renewal_price_list_id,  - 99) <>  - 99 THEN

                QP_UTIL_PUB.Validate_Price_list_Curr_code(
                                                          l_price_list_id => l_renewal_price_list_id
                                                          , l_currency_code => l_currency_code
                                                          , l_pricing_effective_date => l_pricing_effective_date
                                                          , l_validate_result => l_validate_result);

                IF UPPER(nvl(l_validate_result, 'N')) <> 'Y' THEN
                    --	Throw error in check list
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_PRICE_LIST_CURR_R -- MSG FOR INVALID PL FOR RENEWAL
                                        );
                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF ; -- IF NVL(l_renwal_price_list_id, -99) <> -99 THEN
        END IF; -- If l_hdr_ste_code = 'ENTERED'


        -- CHECK FOR LINES --
        /**
        FOR CUR_REC IN  get_line_info(p_chr_id) LOOP

            OPEN get_status(cur_rec.sts_code);
            FETCH get_status INTO l_line_ste_code;
            IF get_status%FOUND THEN
                l_price_list_id := cur_rec.price_list_id;
                l_line_number := cur_rec.line_number;

                QP_UTIL_PUB.Validate_Price_list_Curr_code(
                                                          l_price_list_id => l_price_list_id
                                                          , l_currency_code => l_currency_code
                                                          , l_pricing_effective_date => l_pricing_effective_date
                                                          , l_validate_result => l_validate_result);

                IF UPPER(nvl(l_validate_result, 'N')) <> 'Y' THEN
                    --	Throw error in check list
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_PRICE_LIST_CURR_L, -- MSG FOR INVALID PL AT LINES
                                        p_token1 => 'TOKEN1',
                                        p_token1_value => l_line_number
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF;
            CLOSE get_status;

        END LOOP;
        **/


       --bug 5442886
       OPEN get_line_info(p_chr_id);
       LOOP

          FETCH get_line_info BULK COLLECT INTO l_line_number_tbl, l_price_list_id_tbl LIMIT G_BULK_FETCH_LIMIT;

          EXIT WHEN (l_line_number_tbl.count = 0);

          FOR i IN l_line_number_tbl.FIRST..l_line_number_tbl.LAST LOOP

               QP_UTIL_PUB.Validate_Price_list_Curr_code(
               l_price_list_id	     => l_price_list_id_tbl(i)
               ,l_currency_code          => l_currency_code
               ,l_pricing_effective_date => l_pricing_effective_date
               ,l_validate_result        => l_validate_result);

               If UPPER(nvl(l_validate_result,'N')) <> 'Y' THEN
               --	Throw error in check list
                   OKC_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => G_PRICE_LIST_CURR_L,-- MSG FOR INVALID PL AT LINES
                    p_token1       => 'TOKEN1',
                    p_token1_value => l_line_number_tbl(i)
                    );
                   x_return_status := OKC_API.G_RET_STS_ERROR;
               End If;

          END LOOP;

       END LOOP;
       CLOSE get_line_info;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Check_Price_List_Currency;

    /*============================================================================+
    | Procedure:           Check_Inv_Trx
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_Inv_Trx
    (
     x_return_status             OUT NOCOPY VARCHAR2,
     p_chr_id                    IN NUMBER
     )
    IS

    CURSOR ORG_CUR IS
        SELECT authoring_org_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    CURSOR TAX_METHOD_CUR(p_org_id NUMBER)  IS
        SELECT tax_method_code
        FROM zx_product_options_all
        WHERE org_id = p_org_id
        AND application_id = 222;


    l_org_id            NUMBER;
    l_tax_method        zx_product_options_all.tax_method_code%TYPE;
    l_inv_trx_type      oks_k_headers_b.inv_trx_type%TYPE;
    l_api_name          CONSTANT VARCHAR2(30) := 'Check_Inv_Trx';
    l_mod_name          VARCHAR2(256) := G_APP_NAME || '.PLSQL.' || G_PKG_NAME || '.' || l_api_name;

    BEGIN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_mod_name,'Entering: '|| l_api_name);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN ORG_CUR;
        FETCH ORG_CUR INTO l_org_id;
        CLOSE ORG_CUR;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_org_id: '|| l_org_id);
        END IF;

        OPEN TAX_METHOD_CUR(l_org_id);
        FETCH TAX_METHOD_CUR INTO l_tax_method;
        CLOSE TAX_METHOD_CUR;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_tax_method: '|| l_tax_method);
        END IF;

        IF l_tax_method = 'LTE' THEN
            SELECT inv_trx_type INTO l_inv_trx_type
            FROM oks_k_headers_b
            WHERE id = p_chr_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'latin tax, l_inv_trx_type: '|| l_inv_trx_type);
            END IF;

            IF l_inv_trx_type IS NULL THEN
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => 'OKS_INV_TRX_TYPE_REQUIRED');
            END IF;
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_mod_name,'Leaving: '|| l_api_name);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_mod_name,'Exception OTHERS, SQLCODE: '|| SQLCODE ||' SQLERRM:'|| SQLERRM);
            END IF;

            IF ORG_CUR%ISOPEN THEN
                CLOSE ORG_CUR;
            END IF;

            IF TAX_METHOD_CUR%ISOPEN THEN
                CLOSE TAX_METHOD_CUR;
            END IF;
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Check_Inv_Trx;





    /*============================================================================+
    | Procedure:           check_required_values
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_required_values
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     )
    IS
    l_return_status VARCHAR2(1);

    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        check_req_values
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );

        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;


        Check_PO_Flag
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );

        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;

        Check_Service_PO_Flag
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );

        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;

        Check_Currency_Conv_Type
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );
        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;

        Check_Price_List_Currency
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );
        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;

        --Begin: Added for R12 eBTax
        Check_Inv_Trx
        (
         x_return_status => l_return_status,
         p_chr_id => p_chr_id
         );
        IF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            x_return_status := l_return_status;
        END IF;
        --End: Added for R12 eBTax



        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
    END check_required_values;


    PROCEDURE Check_Counter_base_reading
    (
     p_chr_id        IN  NUMBER,
     X_return_status OUT NOCOPY VARCHAR2
     )
    IS

    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        NULL;
        -- code taken  out.
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END;

    /*============================================================================+
    | Procedure:           val_credit_card
    |
    | Purpose:             function to validate credit card   - Hari  02/14/2001
    |                      Returns 0' failure,  1' success
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    FUNCTION val_credit_card (
                              p_cc_num_stripped       IN  VARCHAR2
                              ) RETURN NUMBER IS

    l_stripped_num_table		numeric_tab_typ;   /* Holds credit card number stripped of white spaces */
    l_product_table		numeric_tab_typ;   /* Table of cc digits multiplied by 2 or 1,for validity check */
    l_len_credit_card_num   	NUMBER := 0;  	   /* Length of credit card number stripped of white spaces */
    l_product_tab_sum   		NUMBER := 0;  	   /* Sum of digits in product table */
    l_actual_cc_check_digit       NUMBER := 0;  	   /* First digit of credit card, numbered from right to left */
    l_mod10_check_digit        	NUMBER := 0;  	   /* Check digit after mod10 algorithm is applied */
    j 				NUMBER := 0;  	   /* Product table index */

    BEGIN

        SELECT length(p_cc_num_stripped)
        INTO   l_len_credit_card_num
        FROM   dual;

        FOR i IN 1..l_len_credit_card_num LOOP
            SELECT to_number(substr(p_cc_num_stripped, i, 1))
            INTO   l_stripped_num_table(i)
            FROM   dual;
        END LOOP;
        l_actual_cc_check_digit := l_stripped_num_table(l_len_credit_card_num);

        FOR i IN 1..l_len_credit_card_num - 1 LOOP
            IF (MOD(l_len_credit_card_num + 1 - i, 2) > 0 )
                THEN
                -- Odd numbered digit.  Store as is, in the product table.
                j := j + 1;
                l_product_table(j) := l_stripped_num_table(i);
            ELSE
                -- Even numbered digit.  Multiply digit by 2 and store in the product table.
                -- Numbers beyond 5 result in 2 digits when multiplied by 2. So handled seperately.
                IF (l_stripped_num_table(i) >= 5)
                    THEN
                    j := j + 1;
                    l_product_table(j) := 1;
                    j := j + 1;
                    l_product_table(j) := (l_stripped_num_table(i) - 5) * 2;
                ELSE
                    j := j + 1;
                    l_product_table(j) := l_stripped_num_table(i) * 2;
                END IF;
            END IF;
        END LOOP;

        -- Sum up the product table's digits
        FOR k IN 1..j LOOP
            l_product_tab_sum := l_product_tab_sum + l_product_table(k);
        END LOOP;

        l_mod10_check_digit := MOD((10 - MOD(l_product_tab_sum, 10)), 10);

        -- If actual check digit and check_digit after mod10 don't match, the credit card is an invalid one.
        IF (l_mod10_check_digit <> l_actual_cc_check_digit)
            THEN
            RETURN(0);
        ELSE
            RETURN(1);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;

    END val_credit_card;

    /*============================================================================+
    | Procedure:           check_overlap
    |
    | Purpose:             Helper procedure. Get's called inside of
    |                      check_covlvl_Overlap. Checks if the current contract
    |                      has covered lines which dates over lap with the
    |                      covered lines of an existing contract. The existing
    |                      contract should not be cancelled, terminated or expired.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_overlap
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_cle_id                   IN  NUMBER,
     p_lty_code                 IN  VARCHAR2,
     p_jtot_object1_code        IN  VARCHAR2,
     p_object1_id1              IN  VARCHAR2,
     p_object1_id2              IN  VARCHAR2,
     p_start_date               IN  DATE,
     p_end_date                 IN  DATE
     ) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;

    CURSOR l_chr_csr IS
        SELECT  chdr.contract_number
               , cle.id
               , chdr.contract_number_modifier
        FROM    okc_k_headers_all_b chdr,
                OKC_K_ITEMS cim,
                OKC_LINE_STYLES_V lse,
                OKC_K_LINES_B cle,
                OKC_STATUSES_B sts
        WHERE   chdr.id = cle.dnz_chr_id
        AND     object1_id1 = p_object1_id1
        AND     object1_id2 = p_object1_id2
        AND     jtot_object1_code = p_jtot_object1_code
        AND     cim.cle_id = cle.id
        AND    (p_start_date BETWEEN cle.start_date
                AND NVL(cle.date_terminated, cle.end_date)
                OR p_end_date BETWEEN cle.start_date
                AND NVL(cle.date_terminated, cle.end_date)
                OR (p_start_date < cle.start_date
                    AND p_end_date > cle.start_date ))
        AND     lse.lty_code = p_lty_code
        AND     lse.id = cle.lse_id
        AND     cle.id <> p_cle_id
        AND     nvl(cle.date_terminated, SYSDATE + 1) > SYSDATE -- added condition for bug # 3646108
        AND     sts.code = chdr.sts_code
        AND     sts.ste_code NOT IN ('CANCELLED', 'TERMINATED', 'EXPIRED')
    AND	  cle.date_cancelled IS NULL -- Changes [llc]
    ;

    l_chr_rec l_chr_csr%ROWTYPE;

    l_contr_num_list    VARCHAR2(32000);
    l_contr_num         VARCHAR2(120);
    l_count_contr       NUMBER := 0;

    BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- Find Coverage Overlap
        OPEN  l_chr_csr;
        LOOP
            FETCH l_chr_csr INTO l_chr_rec;
            EXIT WHEN l_chr_csr%NOTFOUND;
            x_return_status := OKC_API.G_RET_STS_ERROR;
            l_contr_num := l_chr_rec.contract_number || '(' || get_line_name(l_chr_rec.id) || ')';

            IF l_contr_num_list IS NULL THEN
                l_contr_num_list := l_contr_num;
            ELSE
                l_contr_num_list := l_contr_num_list || ', ' || l_contr_num;
            END IF;
            l_count_contr := l_count_contr + 1;

            IF l_count_contr = 50 OR length(l_contr_num_list) > 30000 THEN
                OKC_API.set_message
                (
                 p_app_name => 'OKS',
                 p_msg_name => G_COVERAGE_OVERLAP_LIST,
                 p_token1 => 'LINE_NAME',
                 p_token1_value => get_line_name(p_cle_id),
                 p_token2 => 'CONTRACT_NUMBER',
                 p_token2_value => l_contr_num_list
                 );
                l_contr_num_list := NULL;
                l_count_contr := 0;
            END IF;
            /*
            OKC_API.set_message
            (
            p_app_name     => 'OKS',
            p_msg_name     => G_COVERAGE_OVERLAP,
            p_token1       => 'LINE_NAME',
            p_token1_value => get_line_name(p_cle_id),
            p_token2       => 'CONTRACT_NUMBER',
            p_token2_value => l_chr_rec.contract_number,
            p_token3       => 'CONTRACT_MODIFIER',
            p_token3_value => l_chr_rec.contract_number_modifier,
            p_token4       => 'LINE_NAME1',
            p_token4_value => get_line_name(l_chr_rec.id));
            */
        END LOOP;
        CLOSE l_chr_csr;
        IF l_contr_num_list IS NOT NULL AND l_count_contr > 0 THEN
            OKC_API.set_message
            (
             p_app_name => 'OKS',
             p_msg_name => G_COVERAGE_OVERLAP_LIST,
             p_token1 => 'LINE_NAME',
             p_token1_value => get_line_name(p_cle_id),
             p_token2 => 'CONTRACT_NUMBER',
             p_token2_value => l_contr_num_list
             );
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
            IF l_chr_csr%ISOPEN THEN
                CLOSE l_chr_csr;
            END IF;
    END check_overlap;

    /*cgopinee code fix for bug 8361496*/

    /*============================================================================+
    | Procedure:           check_curr_conv_date
    |
    | Purpose:             Check if the currency conversion date falls within
    |                      contract's header effectivity.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_curr_conv_date
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
    ) IS

     l_api_name CONSTANT VARCHAR2(30) := 'check_curr_conv_date';
     l_invalid VARCHAR2(1)  := 'N';

     CURSOR c_conv_date IS
        SELECT 'Y'
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id
        AND conversion_type IS NOT NULL
        AND conversion_rate_date NOT BETWEEN start_date AND end_date;

    BEGIN

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
        END IF;

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN  c_conv_date;
        FETCH c_conv_date INTO l_invalid;
        CLOSE c_conv_date;

        IF l_invalid = 'Y' THEN

           x_return_status := OKC_API.G_RET_STS_ERROR;
           OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_INV_CURR_CONV_DATE');

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Currency conversion date is not within header effectivity');
           END IF;

        END IF;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;
    END;

     /*cgopinee end of bug fix*/

    /*============================================================================+
    | Procedure:           check_covlvl_Overlap
    |
    | Purpose:             Calls the helper procedure check_overlap to
    |                      checks if the current contract has covered lines which
    |                      dates over lap with  the covered lines of an existing
    |                      contract. The existing contract should not be
    |                      cancelled, terminated or expired.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_covlvl_Overlap
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     ) IS

    /***
    Bug 4767013: commented out
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;

    CURSOR l_cle_csr IS
    SELECT  cle.id
    , lse.lty_code
    , cle.name
    , cle.start_date
    , cle.end_date
    , cim.jtot_object1_code
    , cim.object1_id1
    , cim.object1_id2
    FROM   OKC_K_ITEMS cim,
    OKC_LINE_STYLES_B lse,
    OKC_K_LINES_V cle
    WHERE  cim.cle_id      = cle.id
    and    lse.id          = cle.lse_id
    and    cle.chr_id      = p_chr_id
    and    cle.date_cancelled is null  --Changes [llc]
    ;


    l_cle_rec l_cle_csr%ROWTYPE;

    CURSOR l_cve_csr (p_cle_id NUMBER) IS
    SELECT    cle.id
    ,cle.PRICE_NEGOTIATED
    , cle.name
    , cle.start_date
    , cle.end_date
    , lse.lty_code
    , cim.jtot_object1_code
    , cim.object1_id1
    , cim.object1_id2
    , cle.date_terminated
    FROM       OKC_K_ITEMS cim,
    OKC_LINE_STYLES_B lse,
    OKC_K_LINES_V cle
    WHERE      cim.cle_id     = cle.id
    AND        lse.LTY_CODE IN
    ('COVER_CUST', 'COVER_ITEM', 'COVER_PROD',
    'COVER_PTY',  'COVER_SITE', 'COVER_SYS','INST_CTR')
    AND        lse.id         = cle.lse_id
    AND        cle.cle_id     = p_cle_id
    AND        nvl(cle.date_terminated, sysdate+1) > sysdate  -- added condition for bug # 3646108
    AND	      cle.date_cancelled is null;   --Changes [llc]

    l_cve_rec l_cve_csr%ROWTYPE;
    ***/

    l_api_name CONSTANT VARCHAR2(30) := 'check_covlvl_Overlap';

    TYPE chr120_tbl_type IS TABLE OF okc_k_headers_all_b.contract_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE chr640_tbl_type IS TABLE OF VARCHAR2(640) INDEX BY BINARY_INTEGER;
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    CURSOR c_chk_overlap(cp_chr_id IN NUMBER, cp_date IN DATE) IS
        SELECT trgh.contract_number, nvl(trgh.contract_number_modifier, OKC_API.G_MISS_CHAR),
        nvl(rtrim(trgtl.line_number) || '.' || RTRIM(trgsl.line_number) ||', '|| RTRIM(trgst.name) ||' '|| RTRIM(trgsl.name), OKC_API.G_MISS_CHAR) trg_name,
        nvl(rtrim(srctl.line_number) || '.' || RTRIM(srcsl.line_number) ||', '|| RTRIM(srcst.name) ||' '|| RTRIM(srcsl.name), OKC_API.G_MISS_CHAR) src_name,
        srcsl.id srcsl_id
        FROM okc_k_headers_all_b trgh,
        okc_k_lines_v trgsl,
        okc_k_items trgi,
        okc_k_lines_b trgtl,
        okc_line_styles_v trgst,
        okc_k_lines_v srcsl,
        okc_k_items srci,
        okc_k_lines_b srctl,
        okc_line_styles_v srcst,
        okc_statuses_b sts
        WHERE srcsl.dnz_chr_id = cp_chr_id
        AND srcsl.lse_id IN (7, 8, 9, 10, 11, 35, 13, 18, 25)
        AND nvl(srcsl.date_terminated, cp_date + 1) > cp_date
        AND srci.cle_id = srcsl.id
        AND srcst.id = srcsl.lse_id
        AND srctl.id = srcsl.cle_id
        AND trgi.object1_id1 = srci.object1_id1
        AND trgi.jtot_object1_code = srci.jtot_object1_code
        AND trgi.object1_id2 = srci.object1_id2
        AND trgsl.id = trgi.cle_id
        AND trgsl.id <> srcsl.id
        AND nvl(trgsl.date_terminated, cp_date + 1) > cp_date
        AND (
             (srcsl.start_date BETWEEN trgsl.start_date
              AND nvl(trgsl.date_terminated, trgsl.end_date))
             OR (nvl(srcsl.date_terminated, srcsl.end_date) BETWEEN trgsl.start_date
                 AND nvl(trgsl.date_terminated, trgsl.end_date))
             OR (srcsl.start_date < trgsl.start_date
                 AND nvl(srcsl.date_terminated, srcsl.end_date) > trgsl.start_date)
             )
	     AND nvl(trgsl.date_terminated, trgsl.end_date) <> trgsl.start_date/*Bugfix 6040062-FP of 6013613*/
        AND trgst.id = trgsl.lse_id
        AND trgtl.id = trgsl.cle_id
        AND trgh.id = trgsl.dnz_chr_id
        AND sts.code = trgh.sts_code
        AND sts.ste_code NOT IN ('CANCELLED', 'TERMINATED', 'EXPIRED')
        AND trgsl.date_cancelled IS NULL -- Changes [llc]
    ORDER BY srcsl.id;   -- note: each time the source subline changes, we dump the warning/error messages for the previous line
                         -- that is why we need this ORDER BY here to avoid unnessarily large number of messages
                         -- also, since the cursor looks at only those sublines with overlapping coverages, that number is not
                         -- expected to be large so the performance overhead of the ORDER BY should be minimal



    l_date              DATE;
    l_k_num_tbl         chr120_tbl_type;
    l_k_mod_tbl         chr120_tbl_type;
    l_src_name_tbl      chr640_tbl_type;
    l_src_name          VARCHAR2(640);
    l_srcsl_id_tbl      num_tbl_type;
    l_trg_name_tbl      chr640_tbl_type;


    l_contr_num_list    VARCHAR2(32000);
    l_contr_num         VARCHAR2(120);
    l_count_contr       NUMBER := 0;

    BEGIN

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
        END IF;

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        l_date := SYSDATE;

        OPEN c_chk_overlap(p_chr_id, l_date);
        LOOP
            FETCH c_chk_overlap BULK COLLECT INTO l_k_num_tbl, l_k_mod_tbl,
            l_trg_name_tbl, l_src_name_tbl, l_srcsl_id_tbl  LIMIT G_BULK_FETCH_LIMIT;

            EXIT WHEN (l_k_num_tbl.COUNT = 0);

            FOR i IN l_k_num_tbl.FIRST..l_k_num_tbl.LAST LOOP

                x_return_status := OKC_API.G_RET_STS_ERROR;

                IF i > l_k_num_tbl.FIRST AND l_srcsl_id_tbl(l_srcsl_id_tbl.PRIOR(i)) <> l_srcsl_id_tbl(i) AND l_count_contr > 0 THEN
                   -- the source subline has changed so we need to dump information (if any) for the last source subline processed

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'The source subline has changed so we need to dump information for the last source subline processed.');
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'previous l_src_name_tbl(' || l_src_name_tbl.PRIOR(i) ||'): ' || l_src_name_tbl(l_src_name_tbl.PRIOR(i)));
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'current l_src_name_tbl(' ||i ||'): ' || l_src_name_tbl(i));
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'previous l_count_contr: ' || l_count_contr);
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'previous l_contr_num_list: ' || l_contr_num_list);
                    END IF;

                    OKC_API.set_message
                    (
                     p_app_name => 'OKS',
                     p_msg_name => G_COVERAGE_OVERLAP_LIST,
                     p_token1 => 'LINE_NAME',
                     p_token1_value => l_src_name_tbl(l_src_name_tbl.PRIOR(i)),
                     p_token2 => 'CONTRACT_NUMBER',
                     p_token2_value => l_contr_num_list
                     );

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'message set for l_contr_num_list of previous source subline: ' || l_contr_num_list);
                    END IF;

                    l_contr_num_list := NULL;
                    l_count_contr := 0;

                END IF;


                --processing for current source subline continues
               /*Commented for bug:7114842
                l_contr_num := l_k_num_tbl(i) || '(' || l_trg_name_tbl(i) || ')';
                */
                If l_k_mod_tbl(i) <> FND_API.G_MISS_CHAR THEN
 	    l_contr_num := l_k_num_tbl(i) || ' - Contract_modifier= '||l_k_mod_tbl(i)||' , ' || '(' || l_trg_name_tbl(i) || ')';
                 ELSE
                               l_contr_num := l_k_num_tbl(i) || '(' || l_trg_name_tbl(i) || ')';
                 END IF;

                IF l_contr_num_list IS NULL THEN
                    l_contr_num_list := l_contr_num;
                ELSE
                    l_contr_num_list := l_contr_num_list || ', ' || l_contr_num;
                END IF;
                l_count_contr := l_count_contr + 1;
                l_src_name := l_src_name_tbl(i);

                --IF l_count_contr = 50 OR length(l_contr_num_list) > 30000 THEN
                IF l_count_contr = 50 OR length(l_contr_num_list) > 1500 THEN  --anything larger than 1928 results in a numeric value error from OKC/FND API.set_message

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_src_name_tbl(' ||i ||'): ' || l_src_name_tbl(i));
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_count_contr: ' || l_count_contr);
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_contr_num_list: ' || l_contr_num_list);
                    END IF;

                    OKC_API.set_message
                    (
                     p_app_name => 'OKS',
                     p_msg_name => G_COVERAGE_OVERLAP_LIST,
                     p_token1 => 'LINE_NAME',
                     p_token1_value => l_src_name_tbl(i),
                     p_token2 => 'CONTRACT_NUMBER',
                     p_token2_value => l_contr_num_list
                     );

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'message set for l_contr_num_list: ' || l_contr_num_list);
                    END IF;

                    l_contr_num_list := NULL;
                    l_count_contr := 0;

                END IF;

            END LOOP;

        END LOOP;

        --this processing applies only to coverage overlaps of the same source subline since dumping of a different source subline has already occured at this point
        IF l_contr_num_list IS NOT NULL AND l_count_contr > 0 THEN

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_src_name: ' || l_src_name);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_count_contr: ' || l_count_contr);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_contr_num_list: ' || l_contr_num_list);
            END IF;

            OKC_API.set_message
            (
             p_app_name => 'OKS',
             p_msg_name => G_COVERAGE_OVERLAP_LIST,
             p_token1 => 'LINE_NAME',
             p_token1_value => l_src_name,
             p_token2 => 'CONTRACT_NUMBER',
             p_token2_value => l_contr_num_list
             );

             IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'message set for l_contr_num_list: ' || l_contr_num_list);
             END IF;

        END IF;


        CLOSE c_chk_overlap;



        /***
        Bug 4767013  commented out

        -- initialize return status
        l_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- Get Top Lines
        OPEN  l_cle_csr;
        LOOP
        FETCH l_cle_csr INTO l_cle_rec;
        EXIT WHEN l_cle_csr%NOTFOUND;

        -- Get Covered Levels( sub lines) for top Line
        OPEN l_cve_csr (l_cle_rec.id);
        LOOP
        FETCH l_cve_csr INTO l_cve_rec;
        EXIT WHEN l_cve_csr%NOTFOUND;

        -- Check for covered overlap
        check_overlap(
        l_return_status
        ,l_cve_rec.id
        ,l_cve_rec.lty_code
        ,l_cve_rec.jtot_object1_code
        ,l_cve_rec.object1_id1
        ,l_cve_rec.object1_id2
        ,l_cve_rec.start_date
        ,nvl(l_cve_rec.date_terminated, l_cve_rec.end_date)
        );
        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
        END IF;

        END LOOP;
        CLOSE l_cve_csr;

        END LOOP;
        CLOSE l_cle_csr;
        x_return_status  := l_return_status;
        ***/

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Leaving '|| G_PKG_NAME || '.' || l_api_name);
        END IF;


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'WHEN OTHERS: setting message after encountering error: ' || SQLCODE || ' ' || SQLERRM);
            END IF;

            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
            IF c_chk_overlap%ISOPEN THEN
                CLOSE c_chk_overlap;
            END IF;


            /**
            IF l_cle_csr%ISOPEN THEN
            CLOSE l_cle_csr;
            END IF;
            IF l_cve_csr%ISOPEN THEN
            CLOSE l_cve_csr;
            END IF;
            **/

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'WHEN OTHERS: x_return_status: ' || x_return_status);
            END IF;

    END;

    /*============================================================================+
    | Procedure:           check_covered_levels
    |
    | Purpose:
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_covered_levels(
                                   x_return_status            OUT NOCOPY VARCHAR2,
                                   p_chr_id                   IN  NUMBER
                                   ) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;

    CURSOR l_cle_csr IS
        SELECT cle.id, lse.lty_code, cle.name, cle.lse_id,
               cle.start_date, cle.end_date,
               cim.jtot_object1_code, cim.object1_id1, cim.object1_id2
          FROM OKC_K_ITEMS cim,
               OKC_LINE_STYLES_B lse,
               OKC_K_LINES_V cle
         WHERE cim.cle_id = cle.id
           AND lse.id = cle.lse_id
           AND cle.chr_id = p_chr_id
           AND cle.date_cancelled IS NULL --Changes [llc]
           ;

    l_cle_rec l_cle_csr%ROWTYPE;

    CURSOR l_cve_csr (p_cle_id NUMBER) IS
        SELECT cle.id, cle.PRICE_NEGOTIATED, cle.name, cle.lse_id,
               cle.start_date, cle.end_date, lse.lty_code,
               cim.jtot_object1_code, cim.object1_id1, cim.object1_id2
           FROM OKC_K_ITEMS cim,
                OKC_LINE_STYLES_B lse,
                OKC_K_LINES_V cle
          WHERE cim.cle_id = cle.id
            AND lse.LTY_CODE IN
                ('COVER_CUST', 'COVER_ITEM', 'COVER_PROD',
                 'COVER_PTY', 'COVER_SITE', 'COVER_SYS', 'INST_CTR')
            AND lse.id = cle.lse_id
            AND cle.cle_id = p_cle_id
        AND cle.date_cancelled IS NULL ; --Changes [llc]

    l_cve_rec l_cve_csr%ROWTYPE;

    CURSOR l_cva_csr (p_cle_id NUMBER) IS
        SELECT COUNT( * )
          FROM OKC_LINE_STYLES_B lse,
               OKC_K_LINES_B cle
         WHERE lse.lty_code = 'COVERAGE'
           AND lse.id = cle.lse_id
           AND cle.cle_id = p_cle_id
         GROUP BY cle.cle_id;

    --  Rule_information10 in QRE
    CURSOR l_usage_type_csr(p_id NUMBER) IS
        SELECT  Usage_type
         FROM   OKS_K_LINES_B
         WHERE  cle_id = p_id;

    --  Rule_information5  in QRE
    CURSOR l_default_csr(p_cle_id NUMBER) IS
        SELECT  Default_quantity
        FROM   OKS_K_LINES_B
        WHERE  cle_id = p_cle_id;

    CURSOR l_salescredit_csr(p_cle_id NUMBER) IS
        SELECT NVL(SUM(PERCENT), 0)
        FROM OKS_K_SALES_CREDITS sc,
            OE_SALES_CREDIT_TYPES sct
        WHERE sc.cle_id = p_cle_id
       AND   sc.sales_credit_type_id1 = sct.sales_credit_type_id
       AND   sct.quota_flag = 'Y';

    /*** for revenue and Quota Sales Credit **/
    -- keeping this okx view because it's complicated
    CURSOR l_cust_csr(p_contact_id NUMBER) IS
        SELECT cust_acct_id
        -- FROM   OKX_CUST_ROLE_RESP_V
        FROM   OKX_CUST_CONTACTS_V --Bug 4558172
        WHERE  id1 = p_contact_id;

    CURSOR l_customer_csr(l_billto_siteuse_id IN VARCHAR2) IS
        SELECT CA.CUST_ACCOUNT_ID
        FROM HZ_CUST_ACCT_SITES_ALL CA, HZ_CUST_SITE_USES_ALL CS
        WHERE CS.SITE_USE_ID = l_billto_siteuse_id
        AND CS.SITE_USE_CODE = 'BILL_TO'
        AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID;


    CURSOR l_Contact_csr(p_cle_id NUMBER) IS
        SELECT Contact.object1_id1
        FROM  Okc_contacts Contact
              , Okc_k_party_roles_b Party
             , okc_k_lines_b lines
        WHERE Contact.cpl_id = Party.id
        AND   party.cle_id = p_cle_id
        AND  party.jtot_object1_code = 'OKX_PARTY'
        AND  Contact.cro_code = 'CUST_BILLING'
        AND  party.cle_id = lines.id
        AND  party.dnz_chr_id = lines.dnz_chr_id;

    -- object1_id1 in BTO
    CURSOR l_billto_csr(p_id NUMBER) IS
        SELECT BILL_TO_SITE_USE_ID
        FROM   OKC_K_LINES_B
        -- Bug 4558172 --
        -- where cle_id = p_id;
        WHERE id = p_id;
    -- Bug 4558172 --
    /* The following two cursors are added since the covered product name
    in authoring form is no longer mandatory - Bug #2364436 - Anupama */

    CURSOR l_cvd_lvl_csr (p_cle_id NUMBER) IS
        SELECT cle.id id
        FROM okc_k_lines_v cle, okc_line_styles_v lse
        WHERE  lse.id = cle.lse_id
        AND lse.LTY_CODE IN
              ('COVER_CUST', 'COVER_ITEM', 'COVER_PROD',
               'COVER_PTY', 'COVER_SITE', 'COVER_SYS', 'INST_CTR')
        AND cle.dnz_chr_id = p_chr_id
        AND cle.date_cancelled IS NULL --Changes [llc]
        ;
    l_cvd_lvl_rec l_cvd_lvl_csr%ROWTYPE;

    CURSOR l_cvd_item_csr (line_id NUMBER) IS
        SELECT object1_id1
        FROM   okc_k_items
        WHERE  cle_id = line_id ;
    l_cvd_item_rec l_cvd_item_csr%ROWTYPE;


    CURSOR l_org_csr IS
    SELECT org_id              --from R12, we use org_id instead of authoring_org_id
    FROM okc_k_headers_all_b
    WHERE id = p_chr_id;


    CURSOR l_salesperson_contact IS
    SELECT contact.object1_id1
    FROM  okc_contacts contact
         ,okc_k_party_roles_b party
         ,okc_k_headers_all_b header
    WHERE contact.cpl_id = party.id
    AND   party.chr_id = p_chr_id
    AND  party.jtot_object1_code = 'OKX_OPERUNIT'   --'okx_party'
    --npalepu modified on 06-FEB-2007 for bug # 5855434
    /* AND  contact.cro_code = 'SALESPERSON' */
    AND  contact.cro_code in (SELECT cro_code
                              FROM okc_contact_sources
                              WHERE rle_code in ('VENDOR', 'MERCHANT')
                              AND buy_or_sell = 'S'
                              AND jtot_object_code = 'OKX_SALEPERS')
    --end npalepu
    AND  party.chr_id = header.id
    --npalepu added condition on party.dnz_chr_id for bug # 5845463
    AND party.dnz_chr_id = p_chr_id;
    --end npalepu


    l_check_salesperson_contact CHAR(1) := 'F';

    l_sc_percent  NUMBER;
    l_default_qty NUMBER;
    l_Usage_type  VARCHAR2(3);
    l_cust_id     NUMBER;
    l_contact_id  NUMBER := NULL;
    l_customer_id NUMBER;
    l_billto_id   NUMBER;
    l_renewal_status  VARCHAR2(30);

    l_org_id      NUMBER;

    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- The following code added for bug # 2364436 - Anupama

        OPEN l_cvd_lvl_csr (p_chr_id);
        LOOP
            FETCH l_cvd_lvl_csr INTO l_cvd_lvl_rec;
            EXIT WHEN l_cvd_lvl_csr%NOTFOUND;

            OPEN  l_cvd_item_csr (l_cvd_lvl_rec.id);
            FETCH l_cvd_item_csr INTO l_cvd_item_rec;
            IF    (l_cvd_item_csr%NOTFOUND) OR (l_cvd_item_rec.object1_id1 IS NULL) THEN
                /**
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_REQUIRED_LINE_VALUE,
                                    p_token1 => G_COL_NAME_TOKEN,
                                    p_token1_value => 'Covered Level Name',
                                    p_token2 => 'LINE_NAME',
                                    p_token2_value => get_line_name(l_cvd_lvl_rec.id));
                **/

                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_COVERED_LINE_REQUIRED,
                                    p_token1 => 'LINE_NAME',
                                    p_token1_value => get_line_name(l_cvd_lvl_rec.id));

                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            CLOSE l_cvd_item_csr;
        END LOOP;
        CLOSE l_cvd_lvl_csr;


        -- Get Contract Lines
        OPEN  l_cle_csr;
        LOOP
            FETCH l_cle_csr INTO l_cle_rec;
            EXIT WHEN l_cle_csr%NOTFOUND;

            -- Get Covered Levels for Contract Line

            OPEN l_cve_csr (l_cle_rec.id);
            LOOP
                FETCH l_cve_csr INTO l_cve_rec;
                EXIT WHEN l_cve_csr%NOTFOUND;
                IF l_cve_rec.lty_code <> 'INST_CTR' THEN
                    -- Negotiated amount at covered levels is required.
                    IF l_cve_rec.PRICE_NEGOTIATED IS NULL THEN
                        /**
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_REQUIRED_LINE_VALUE,
                                            p_token1 => G_COL_NAME_TOKEN,
                                            p_token1_value => 'Final Price',
                                            p_token2 => 'LINE_NAME',
                                            p_token2_value => get_line_name(l_cve_rec.id));
                        **/

                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_NEG_AMT_REQUIRED,
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(l_cve_rec.id));
                        -- notify caller of an error
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;
                END IF;


                OPEN l_Usage_type_csr(l_cle_rec.id);
                FETCH l_Usage_type_csr INTO l_usage_type;
                CLOSE l_Usage_type_csr;


                OPEN l_default_csr(l_cve_rec.id);
                FETCH l_default_csr INTO l_default_qty;
                CLOSE l_default_csr;

                IF l_usage_type = 'VRT' AND l_default_qty IS NULL THEN
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                    OKC_API.set_message
                    (
                     p_app_name => G_APP_NAME,
                     p_msg_name => G_DEFAULT_READING,
                     p_token1 => 'TOKEN',
                     p_token1_value => get_line_name(l_cve_rec.id)
                     );

                END IF;

            END LOOP;

            -- if statement added for subscription lines.
            IF l_cle_rec.lse_id <> 46 THEN
                -- A Contract Line must have at least 1 covered level line
                IF l_cve_csr%ROWCOUNT <= 0 THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_REQUIRED_COVERED_LINE,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(l_cle_rec.id));
                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF; -- l_cle_rec.lse_id <> 46
            CLOSE l_cve_csr;

            IF l_cle_rec.lty_code = 'SERVICE' THEN
                OPEN  l_cva_csr (l_cle_rec.id);
                FETCH l_cva_csr INTO l_count;
                CLOSE l_cva_csr;

                IF l_count > 1 THEN
                    -- A Service Line must have at most 1 coverage line
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_INVALID_COVERAGE_LINE,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(l_cle_rec.id));
                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF;


            --adding the following code for Bug#4069048
            -- get renewal status to see if this is called for Electronic renewal
            -- if so bypass the sales credit  validation
            l_renewal_status := get_renewal_status(p_chr_id);

            --Bug 4673694 in R12 the renewal status codes have been modified
            --if nvl(l_renewal_status ,'-99') <> 'QAS' and nvl(l_renewal_status, '-99') <> 'ERN_QA_CHECK_FAIL' then
            IF nvl(l_renewal_status, '-99') <> 'PEND_PUBLISH' THEN

                /**  check sales credit for Top lines **/

                l_sc_percent := 0;

                l_org_id := NULL;
                OPEN l_org_csr;
                FETCH l_org_csr INTO l_org_id;
                CLOSE l_org_csr;

                IF l_cle_rec.lse_id IN (1, 12, 19, 46)  AND
                    --(FND_PROFILE.VALUE('OKS_ENABLE_SALES_CREDIT') IN ('YES', 'R') OR OKS_BILL_UTIL_PUB.Is_Sc_Allowed) THEN
                    (FND_PROFILE.VALUE('OKS_ENABLE_SALES_CREDIT') IN ('YES', 'DRT', 'R') OR OKS_BILL_UTIL_PUB.Is_Sc_Allowed(l_org_id)) THEN

                    l_check_salesperson_contact := 'T';

                    OPEN l_salescredit_csr(l_cle_rec.id);
                    FETCH l_salescredit_csr INTO l_sc_percent;
                    CLOSE l_salescredit_csr;

                    IF l_sc_percent <> 100  THEN

                        /**
                        OKC_API.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_LINE_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'Quota Sales Credit at line must be assigned to 100%',
                        p_token2       => 'LINE_NAME',
                        p_token2_value => get_line_name(l_cle_rec.id));
                        **/
                        OKC_API.set_message( -- Bug 4708540 (changed message)
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => 'OKS_INCOMP_QUOTA_SALES_CREDIT',
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(l_cle_rec.id));

                        -- notify caller of an error
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                    END IF;

                END IF;
            END IF;
            l_contact_id := null;  /*harlaksh bug:7013295*/
            OPEN l_contact_csr(l_cle_rec.id);
            FETCH l_contact_csr INTO l_contact_id;
            CLOSE l_contact_csr;


            IF l_contact_id IS NOT NULL THEN
                OPEN l_cust_csr(l_contact_id);
                FETCH l_cust_csr INTO l_cust_id;
                CLOSE l_cust_csr;

                OPEN l_billto_csr(l_cle_rec.id);
                FETCH l_billto_csr INTO l_billto_id;
                CLOSE l_billto_csr;

                OPEN l_customer_csr(l_billto_id);
                FETCH l_customer_csr INTO l_customer_id;
                CLOSE l_customer_csr;
                -- Bug 4558172--
                IF nvl(l_cust_id, 0) <> nvl(l_customer_id,  - 99) THEN
                    -- Bug 4558172--
                    /**
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_REQUIRED_VALUE,
                                        p_token1 => G_COL_NAME_TOKEN,
                                        p_token1_value => 'INVALID BILLING CONTACTS ');
                    **/

                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_INVALID_BILLING_CONTACTS);

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;

            END IF;




        END LOOP;
        -- A Contract must have at least 1 Contract Line

        IF l_cle_csr%ROWCOUNT <= 0 THEN
            /**
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_REQUIRED_VALUE,
                                p_token1 => G_COL_NAME_TOKEN,
                                p_token1_value => 'Contract Line');
            **/

            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_LINE_REQUIRED);


            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;


        CLOSE l_cle_csr;


        --bug 5136368
        IF l_check_salesperson_contact = 'T' THEN
           l_contact_id := NULL;

           OPEN l_salesperson_contact;
           FETCH l_salesperson_contact INTO l_contact_id;
           CLOSE l_salesperson_contact;

           IF l_contact_id IS NULL THEN
              OKC_API.set_message(
                            p_app_name => G_APP_NAME,
                            p_msg_name => G_MISSING_SALESREP);

              -- notify caller of an error
              x_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;

        END IF;



        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;



    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
            IF l_cle_csr%ISOPEN THEN
                CLOSE l_cle_csr;
            END IF;
            IF l_cve_csr%ISOPEN THEN
                CLOSE l_cve_csr;
            END IF;
            IF l_cva_csr%ISOPEN THEN
                CLOSE l_cva_csr;
            END IF;


    END check_covered_levels;

    /*============================================================================+
    | Procedure:           check_req_values
    |
    | Purpose:
    |
    | Modified:            mkhayer -- to support merchant and subscriber for
    |                      subscription contracts
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_req_values(
                               x_return_status            OUT NOCOPY VARCHAR2,
                               p_chr_id                   IN  NUMBER
                               ) IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;

    CURSOR l_cle_csr IS
      /**
        SELECT cle.id, COUNT( * )
          FROM OKC_K_ITEMS cim,
               OKC_K_LINES_B cle
         WHERE cim.cle_id = cle.id
           AND cle.dnz_chr_id = p_chr_id
           AND cle.date_cancelled IS NULL --Changes [llc]
        GROUP BY cle.id
        HAVING COUNT( * ) > 1;
      **/
      --bug 5442886
      SELECT cle_id, count(*)
      FROM  okc_k_items
      WHERE dnz_chr_id = p_chr_id
      GROUP BY cle_id
      HAVING COUNT(*) > 1;


    l_cle_rec l_cle_csr%ROWTYPE;
    l_date_cancelled DATE;

    CURSOR l_cle1_csr IS
        SELECT cle.id
          FROM OKC_K_LINES_V cle
         WHERE cle.dnz_chr_id = p_chr_id
         AND cle.name IS NULL
         AND cle.date_cancelled IS NULL  ; --Changes [llc]

    l_cle1_rec l_cle1_csr%ROWTYPE;

    CURSOR l_cpl_csr (p_rle_code VARCHAR2) IS
        SELECT COUNT( * )
          FROM OKC_K_PARTY_ROLES_B cpl
         WHERE cpl.rle_code = p_rle_code
           AND cpl.dnz_chr_id = p_chr_id
           AND cpl.cle_id IS NULL;

    CURSOR l_desc_csr IS
        SELECT  contract_number, Short_description
        FROM    OKC_K_HEADERS_V
        WHERE   id = p_chr_id;

    CURSOR  l_qa_csr IS
        SELECT  contract_number, QCL_ID, scs_code
        FROM    okc_k_headers_all_b
        WHERE   id = p_chr_id;

    -- Object1_id1 in PRE rule
    CURSOR l_price_csr IS
        SELECT price_list_id -- Object1_id1
        FROM   okc_k_headers_all_b
        WHERE  id = p_chr_id;


    CURSOR l_k_grp_csr IS
        SELECT  id
        FROM   OKC_K_GRPINGS
        WHERE  Included_chr_id = p_chr_id;

    CURSOR l_wf_csr IS
        SELECT  id
        FROM   OKC_K_PROCESSES
        WHERE  Chr_id = p_chr_id;

    --Fixes Bug# 1926370

    /***
    CURSOR  l_get_top_line_csr IS
        SELECT  id
        FROM   OKC_K_LINES_B
        WHERE  dnz_chr_id = p_chr_id
        AND    lse_id IN (1, 19)
        AND    date_cancelled IS NULL  ; --Changes [llc]

    CURSOR  l_get_sub_line_csr (p_cle_id NUMBER) IS
        SELECT  id, price_unit
        FROM   OKC_K_LINES_B
        WHERE  dnz_chr_id = p_chr_id
        AND    cle_id = p_cle_id
        AND    lse_id IN (7, 8, 9, 10, 11, 18, 25, 35)
        AND    date_cancelled IS NULL --Changes [llc]
        ;

    CURSOR  l_get_item_csr (p_cle_id NUMBER) IS
        SELECT  id, uom_code
        FROM   OKC_K_ITEMS_V
        WHERE  dnz_chr_id = p_chr_id
        AND    cle_id = p_cle_id;
    ***/

    --bug 5442886
    CURSOR l_get_line_details_csr IS
      SELECT /*+ ordered use_nl(rlb,ri) */
                 rlb.id sub_line_id, rlb.price_unit,
              ri.uom_code
       FROM   okc_k_lines_b rla,
              okc_k_lines_b rlb,
              okc_k_items_v ri
       WHERE  rla.dnz_chr_id = p_chr_id
       AND    rla.lse_id IN (1,19)
       AND    rla.date_cancelled IS NULL
       AND    rlb.cle_id = rla.id
       AND    rlb.lse_id IN (7,8,9,10,11,18,25,35)
       AND    rlb.date_cancelled IS NULL
       ------AND    ri.dnz_chr_id = rla.dnz_chr_id  --not necessary
       AND    ri.cle_id = rlb.id
       AND    (rlb.price_unit IS NULL OR ri.uom_code IS NULL);

    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE chr3_tbl_type IS TABLE OF okc_k_items.uom_code%TYPE INDEX BY BINARY_INTEGER;

    l_sub_line_id_tbl num_tbl_type;
    l_price_unit_tbl  num_tbl_type;
    l_uom_code_tbl    chr3_tbl_type;

    l_desc VARCHAR2(600);
    l_qcl  NUMBER;
    l_contr_category VARCHAR2(30);
    l_customer VARCHAR2(30);
    l_vedor VARCHAR2(30);
    l_grp_id NUMBER;
    l_price_id NUMBER;
    l_wf_id NUMBER;
    l_k_no VARCHAR2(120);


    /* check for product availability */

    service_rec_type        OKS_OMINT_PUB.check_service_rec_type;
    l_service_id		NUMBER;
    l_service_item_id	NUMBER;
    l_product_id		NUMBER;
    l_product_item_id	NUMBER;
    l_customer_id		NUMBER;
    l_msg_Count		NUMBER;
    l_msg_Data		VARCHAR2(50);
    --l_Return_Status		VARCHAR2(1);
    l_Available_YN	 	VARCHAR2(1);
    l_sts_code              VARCHAR2(100);
    l_prod_start_date       DATE;

    --start changes for org id in is_service_available
    CURSOR get_auth_org_csr IS
        SELECT authoring_org_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    get_auth_org_rec  get_auth_org_csr%ROWTYPE;
    --End changes for org id in is_service_available

    /*** Get all service lines for given Contract header id ***/
    CURSOR l_csr_get_service_line_id(p_chr_id NUMBER) IS
        SELECT cle.id, sts.ste_code sts_code
        FROM   okc_k_lines_v cle,
               okc_statuses_b sts
        WHERE  cle.dnz_chr_id = p_chr_id
        AND    sts.code = cle.sts_code
        AND    cle.lse_id IN (1, 19);

    /*** Get customer id for all the above service lines ***/
    -- object1_id1 in CAN rule
    CURSOR l_csr_get_customer_id IS
        SELECT CUST_ACCT_ID -- object1_id1
        FROM   okc_k_lines_b
        WHERE  id = l_service_id;


    /*** Get service item id for all the service lines from OKC_K_ITEMS_V ***/
    CURSOR l_csr_get_service_item_id(p_cle_id IN NUMBER) IS
        SELECT object1_id1
        FROM   okc_k_items_v
        WHERE  cle_id = p_cle_id ;


    /*** Get all product lines and item lines for each service line ***/
    CURSOR l_csr_get_product_line_id IS
        SELECT id, start_date
        FROM   okc_k_lines_v
        WHERE  cle_id = l_service_id
        AND    lse_id IN (9, 25, 7); -- 7 added for bug#2430496


    /*** Get service item id or product item if for all the service lines
    *** or product lines  from OKC_K_ITEMS_V                              ***/
    CURSOR l_csr_get_item_id(p_cle_id IN NUMBER) IS
        SELECT object1_id1
        FROM   okc_k_items_v
        WHERE  cle_id = p_cle_id ;

    CURSOR l_product_csr(p_cp_id NUMBER) IS
        SELECT inventory_item_id
        FROM   csi_item_instances
        WHERE  instance_id = p_cp_id;

    l_cp_id NUMBER;


    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        --changes for passing org_id in is_service_available
        OPEN get_auth_org_csr;
        FETCH get_auth_org_csr INTO get_auth_org_rec;
        CLOSE get_auth_org_csr;

        -- A Contract Line may have at most 1 contract item
        OPEN  l_cle_csr;
        LOOP
            FETCH l_cle_csr INTO l_cle_rec;
            EXIT WHEN l_cle_csr%NOTFOUND;

            l_date_cancelled := NULL;
            SELECT date_cancelled
            INTO l_date_cancelled
            FROM okc_k_lines_b
            WHERE id = l_cle_rec.cle_id;

            IF l_date_cancelled IS NULL THEN
               OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_INVALID_LINE_ITEM,
                                p_token1 => 'LINE_NAME',
                                --p_token1_value => get_line_name(l_cle_rec.id));
                                p_token1_value => get_line_name(l_cle_rec.cle_id));


               -- notify caller of an error
               x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;

        END LOOP;
        CLOSE l_cle_csr;

        -- A Contract Line must have a name
        -- This check is no longer needed.
        --OPEN  l_cle1_csr;
        --LOOP
        --  FETCH l_cle1_csr INTO l_cle1_rec;
        --  EXIT WHEN l_cle1_csr%NOTFOUND;
        --      OKC_API.set_message(
        --        p_app_name     => G_APP_NAME,
        --        p_msg_name     => G_REQUIRED_LINE_VALUE,
        --        p_token1       => G_COL_NAME_TOKEN,
        --        p_token1_value => 'Name',
        --        p_token2       => 'LINE_NAME',
        --        p_token2_value => get_line_name(l_cle1_rec.id));

        --    -- notify caller of an error
        --    x_return_status := OKC_API.G_RET_STS_ERROR;
        --END LOOP;
        --CLOSE l_cle1_csr;
        OPEN l_qa_csr;
        FETCH l_qa_csr INTO l_k_no, l_qcl, l_contr_category;
        CLOSE l_qa_csr;

        IF l_qcl IS NULL THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_QA_CHECK,
                                p_token1 => 'TOKEN',
                                p_token1_value => l_k_no);

            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        IF l_contr_category = 'SUBSCRIPTION' THEN
            l_customer := 'SUBSCRIBER';
            l_vedor := 'MERCHANT';
        ELSE
            l_customer := 'CUSTOMER';
            l_vedor := 'VENDOR';
        END IF;
        -- At most only 1 customer or subscriber may be attached to the Contract
        OPEN  l_cpl_csr(l_customer);
        FETCH l_cpl_csr INTO l_count;
        CLOSE l_cpl_csr;

        IF (l_count > 1) THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_PARTY_ROLE,
                                p_token1 => 'ROLE',
                                p_token1_value => l_customer);
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        -- It is required that one customer or subscriber may be attached to
        -- a contract. Added by mkhayer on 05/03/2002
        IF (l_count < 1) THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_PARTY_MISSING_ROLE,
                                p_token1 => 'ROLE',
                                p_token1_value => l_customer);
            -- notify caller of an error (The contract has no Customer attached to it)
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        -- At most only 1 vendor or merchant may be attached to the Contract
        OPEN  l_cpl_csr(l_vedor);
        FETCH l_cpl_csr INTO l_count;
        CLOSE l_cpl_csr;

        IF (l_count > 1) THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_PARTY_ROLE,
                                p_token1 => 'ROLE',
                                p_token1_value => l_vedor);
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        -- It is required that one vendor or merchant may be attached to a contract.
        -- Added by mkhayer on 05/03/2002
        IF (l_count < 1) THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_PARTY_MISSING_ROLE,
                                p_token1 => 'ROLE',
                                p_token1_value => l_vedor);
            -- notify caller of an error (The contract has no Vendor attached to it)
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        OPEN l_desc_csr;
        FETCH l_desc_csr INTO l_k_no, l_desc;
        CLOSE l_desc_csr;

        IF l_desc IS NULL THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_SHORT_DESC,
                                p_token1 => 'TOKEN',
                                p_token1_value => l_k_no);
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        OPEN l_price_csr;
        FETCH l_price_csr INTO l_price_id;
        CLOSE l_price_csr;

        IF l_price_id IS NULL THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_PRICE_LIST,
                                p_token1 => 'TOKEN',
                                --p_token1_value => 'BILLING HEADER');
                                p_token1_value => l_k_no);
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;


        OPEN l_k_grp_csr;
        FETCH l_k_grp_csr INTO l_grp_id;

        IF l_grp_id IS NULL THEN

            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_K_GROUP,
                                p_token1 => 'TOKEN',
                                --p_token1_value => 'Header Admin');
                                p_token1_value => l_k_no);


            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        CLOSE l_k_grp_csr;


        OPEN l_wf_csr;
        FETCH l_wf_csr INTO l_wf_id;
        CLOSE l_wf_csr;

        IF l_wf_id IS NULL THEN

            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_WORKFLOW );


            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        /* check for product availability*/
        /*** Get customer_id ****/

        /* -- Comented out by mkhayer --
        -- there is an API called check_product_availability which has the exact code
        -- as below.
        OPEN l_csr_get_service_line_id(p_chr_id);

        LOOP

        FETCH l_csr_get_service_line_id INTO l_service_id,l_sts_code;
        IF l_csr_get_service_line_id%NOTFOUND THEN
        EXIT;
        END IF;

        l_customer_id := NULL;

        OPEN l_csr_get_customer_id;
        FETCH l_csr_get_customer_id INTO l_customer_id;
        IF l_csr_get_customer_id%NOTFOUND THEN
        x_return_status := 'E';
        EXIT;
        END IF;
        CLOSE l_csr_get_customer_id;

        l_service_item_id := NULL;

        OPEN l_csr_get_item_id(l_service_id);
        FETCH l_csr_get_item_id INTO l_service_item_id;
        IF l_csr_get_item_id%NOTFOUND THEN
        x_return_status := 'E';
        EXIT;
        END IF;
        CLOSE l_csr_get_item_id;

        l_product_id := NULL;
        l_prod_start_date := NULL;

        OPEN l_csr_get_product_line_id;
        LOOP
        FETCH l_csr_get_product_line_id INTO l_product_id,l_prod_start_date;
        IF l_csr_get_product_line_id%NOTFOUND THEN

        EXIT;
        END IF;

        l_product_item_id := NULL;

        OPEN l_csr_get_item_id(l_product_id);
        FETCH l_csr_get_item_id INTO l_product_item_id;
        IF l_csr_get_item_id%NOTFOUND THEN
        x_return_status := 'E';
        EXIT;
        END IF;
        CLOSE l_csr_get_item_id;

        l_cp_id := NULL;

        Open l_product_csr(l_product_item_id);
        Fetch l_product_csr into l_cp_id;
        Close l_product_csr;

        service_rec_type.service_item_id := l_service_item_id;
        service_rec_type.customer_id     := l_customer_id;
        service_rec_type.product_item_id := l_cp_id;
        service_rec_type.request_date := l_prod_start_date;
        l_available_YN := NULL;

        If l_sts_code = 'ENTERED'
        then
        --changes for passing org_id in is_service_available
        OKS_OMINT_PUB.Is_Service_Available
        (
        p_api_version        => 1.0	,
        p_init_msg_list      => 'F'	,
        x_msg_count          => l_msg_Count	,
        x_msg_data           => l_msg_Data	,
        x_return_status      => l_Return_Status	,
        p_check_service_rec  => service_rec_type,
        x_available_yn       => l_available_YN,
        p_org_id             => get_auth_org_rec.authoring_org_id
        );


        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_PKG_NAME||'.'||l_api_name,'After Service_Available p return_status: '||x_return_status);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_PKG_NAME||'.'||l_api_name,'l_msg_data: '||l_msg_data);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_PKG_NAME||'.'||l_api_name,'l_msg_count: '||l_msg_count);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_PKG_NAME||'.'||l_api_name,'l_available_YN: '||l_available_YN);
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT , G_PKG_NAME||'.'||l_api_name,'l_org_id: '||get_auth_org_rec.authoring_org_id);
        END IF;

        If l_available_yn = 'N'  then
        x_return_status := OKC_API.G_RET_STS_ERROR;

        OKC_API.set_message
        (
        p_app_name      => 'OKS',
        p_msg_name      => 'OKS_PRODUCT_AVAILABILITY',
        p_token1        => 'TOKEN1',
        --p_token1_value  => get_line_name(l_line_rec.line_number),
        p_token1_value  => get_line_name(l_service_id),
        p_token2        => 'TOKEN2',
        p_token2_value  => get_line_name(l_product_id)
        );

        End If;
        End if; --If l_sts_code = 'ENTERED'

        END LOOP;  	-- End loop get product line id
        CLOSE l_csr_get_product_line_id;

        END LOOP;  -- End loop get service line id
        CLOSE l_csr_get_service_line_id; */

        /****
        IF NVL(fnd_profile.VALUE('OKS_USE_QP_FOR_MANUAL_ADJ'), 'NO') = 'YES'
            THEN
            FOR l_get_top_line_rec IN l_get_top_line_csr
                LOOP

                FOR l_get_sub_line_rec IN l_get_sub_line_csr (l_get_top_line_rec.id)
                    LOOP
                    FOR l_get_item_rec IN l_get_item_csr (l_get_sub_line_rec.id)
                        LOOP

                        IF (l_get_sub_line_rec.price_unit IS NULL OR l_get_item_rec.uom_code IS NULL)
                            THEN

                            -- store SQL error message on message stack
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_UOM_VALUES',
                             p_token1 => 'TOKEN1',
                             p_token1_value => get_line_name(l_get_sub_line_rec.id));

                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF; -- IF (l_get_sub_line_rec.price_unit IS NULL OR l_get_item_rec.uom_code IS NULL)

                    END LOOP; --FOR l_get_item_rec in l_get_item_csr

                END LOOP; --FOR l_get_sub_line_rec in l_get_sub_line_csr

            END LOOP; --FOR l_get_top_line_rec in l_get_top_line_csr

        ELSE

            FOR l_get_top_line_rec IN l_get_top_line_csr
                LOOP

                FOR l_get_sub_line_rec IN l_get_sub_line_csr (l_get_top_line_rec.id)
                    LOOP
                    FOR l_get_item_rec IN l_get_item_csr (l_get_sub_line_rec.id)
                        LOOP

                        IF (l_get_item_rec.uom_code IS NULL)
                            THEN

                            -- store SQL error message on message stack
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_UOM_VALUES',
                             p_token1 => 'TOKEN1',
                             p_token1_value => get_line_name(l_get_sub_line_rec.id));

                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF; -- IF (l_get_sub_line_rec.price_unit IS NULL OR l_get_item_rec.uom_code IS NULL)

                    END LOOP; --FOR l_get_item_rec in l_get_item_csr

                END LOOP; --FOR l_get_sub_line_rec in l_get_sub_line_csr

            END LOOP; --FOR l_get_top_line_rec in l_get_top_line_csr



        END IF; -- IF NVL(fnd_profile.value('OKS_USE_QP_FOR_MANUAL_ADJ'),'NO') = 'YES'
        ****/


        --bug 5442886
        OPEN l_get_line_details_csr;

        LOOP

           FETCH l_get_line_details_csr BULK COLLECT INTO l_sub_line_id_tbl, l_price_unit_tbl, l_uom_code_tbl LIMIT G_BULK_FETCH_LIMIT;

           EXIT WHEN l_sub_line_id_tbl.COUNT = 0;

           FOR i IN l_sub_line_id_tbl.FIRST..l_sub_line_id_tbl.LAST LOOP

                  --Modified for Bug#6317316 harlaksh. Price_unit check is not necessary.
                  /* commenting out the first IF condition keeping only else condition part.
             	  IF NVL(fnd_profile.value('OKS_USE_QP_FOR_MANUAL_ADJ'),'NO') = 'YES' THEN

                  IF (l_price_unit_tbl(i) IS NULL OR l_uom_code_tbl(i) IS NULL)
                  THEN
                        -- store SQL error message on message stack
           	          OKC_API.SET_MESSAGE
           	               (
                             p_app_name        => G_APP_NAME,
                             p_msg_name        => 'OKS_UOM_VALUES',
                             p_token1          => 'TOKEN1',
                             p_token1_value    => get_line_name(l_sub_line_id_tbl(i)));

                        x_return_status := OKC_API.G_RET_STS_ERROR;

                  END IF;

               ELSE
    Bug #6317316 commented the above IF part */
                  IF (l_uom_code_tbl(i) IS NULL)
                  THEN
                        -- store SQL error message on message stack
                        OKC_API.SET_MESSAGE
                           (
                             p_app_name        => G_APP_NAME,
                             p_msg_name        => 'OKS_UOM_VALUES',
                             p_token1          => 'TOKEN1',
                             p_token1_value    => get_line_name(l_sub_line_id_tbl(i)));

                        x_return_status := OKC_API.G_RET_STS_ERROR;

                  END IF;
                 --commented for bug#6317316 harlaksh
               --END IF;
           --commented for bug#6317316 harlaksh

           END LOOP;

        END LOOP;

        CLOSE l_get_line_details_csr;



        /* Commented out because it's getting called in check_required_values
        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
        OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => 'OKS_QA_SUCCESS');
        END IF;
        */
    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed

            IF l_cle_csr%ISOPEN THEN
                CLOSE l_cle_csr;
            END IF;

            IF l_cpl_csr%ISOPEN THEN
                CLOSE l_cpl_csr;
            END IF;

    END check_req_values;

    /*============================================================================+
    | Procedure:           Get_Cust_Trx_Type_Id
    |
    | Purpose:     Gets transaction type ID for check_tax_exemption
    |              If no transaction type ID is found for the given org and
    |              transaction type, a default value will be used
    |
    | In Parameters:       p_org_id            the org id
    |                      p_inv_trx_type      the transaction type
    | Return:              transaction type ID
    |
    +============================================================================*/

    FUNCTION Get_Cust_Trx_Type_Id(p_org_id IN NUMBER,
                                  p_inv_trx_type IN VARCHAR2) RETURN NUMBER
    IS

    CURSOR Cur_custtrx_type_id(bookId NUMBER, object1Id1 NUMBER, orgId NUMBER) IS
        SELECT  Cust_trx_type_id
        FROM    RA_CUST_TRX_TYPES_ALL
        WHERE   SET_OF_BOOKS_ID = bookId
        AND     org_id = orgId
        AND     Cust_trx_type_id = NVL(object1Id1,  - 99);


    CURSOR Cur_default_custtrx_type_id(bookId NUMBER, orgId NUMBER) IS
        SELECT  Cust_trx_type_id
        FROM    RA_CUST_TRX_TYPES_ALL
        WHERE   SET_OF_BOOKS_ID = bookId
        AND     org_id = orgId
        AND TYPE = 'INV' AND name = 'Invoice-OKS' AND SYSDATE <= nvl(end_date, SYSDATE);

    CURSOR l_org_csr  IS
        SELECT     set_of_books_id
        FROM    ar_system_parameters_all
        WHERE    org_id = p_org_id;

    l_api_name          CONSTANT VARCHAR2(30) := 'Get_Cust_Trx_Type_Id';
    l_cust_trx_type_id  NUMBER;
    l_set_of_books_id   NUMBER;

    BEGIN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering: '|| l_api_name);
        END IF;

        l_cust_trx_type_id := NULL;

        OPEN  l_org_csr;
        FETCH l_org_csr INTO l_set_of_books_id ;
        CLOSE l_org_csr;



        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_set_of_books_id: '|| l_set_of_books_id);
        END IF;

        IF p_inv_trx_type IS NOT NULL THEN
            OPEN Cur_custtrx_type_id(l_set_of_books_id,
                                     p_inv_trx_type,
                                     p_org_id);
            FETCH Cur_custtrx_type_id INTO l_cust_trx_type_id;
            CLOSE Cur_custtrx_type_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_inv_trx_type is not null');
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_set_of_books_id: '|| l_set_of_books_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'p_org_id: ' || p_org_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_cust_trx_type_id: ' || l_cust_trx_type_id);
            END IF;

        END IF;



        IF l_cust_trx_type_id IS NULL THEN
            OPEN Cur_default_custtrx_type_id(l_set_of_books_id,
                                             p_org_id);
            FETCH Cur_default_custtrx_type_id INTO l_cust_trx_type_id;
            CLOSE Cur_default_custtrx_type_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_cust_trx_type_id is null, getting the default value.');
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'default l_cust_trx_type_id: ' || l_cust_trx_type_id);
            END IF;

        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Leaving: '|| l_api_name);
        END IF;

        RETURN l_cust_trx_type_id;
    EXCEPTION
        WHEN OTHERS THEN
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
            IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, G_PKG_NAME || '.' || l_api_name,'Exception OTHERS: '|| SQLERRM);
            END IF;

    END Get_Cust_Trx_Type_Id;

    /*============================================================================+
    | Procedure:           check_tax_exemption
    |
    | Purpose:     Gets the approval status of the tax_exempt.
    |              Reports an error if its invalid. It also reports an error
    |              if the line start date is not between the satrt date and
    |              end date of the tax exemption.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_tax_exemption(
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  p_chr_id                   IN  NUMBER
                                  )
    IS
    l_api_name                   CONSTANT VARCHAR2(30) := 'check_tax_exemption';
    l_mod_name          VARCHAR2(256) := G_APP_NAME || '.PLSQL.' || G_PKG_NAME || '.' || l_api_name;
    l_api_version CONSTANT NUMBER := 1;
    l_error_text VARCHAR2(512);


    --Begin: Add for R12
    -- if the statement fetches a row then the exemption
    -- is valid for the transaction date; if it cursor does not
    -- fetch a row, raise error
    CURSOR old_valid_exemption_csr(l_tax_exemption_id NUMBER, l_start_date DATE)
        IS
        SELECT v2.exempt_certificate_number
        FROM   zx_exemptions v2
        WHERE (trunc(l_start_date) BETWEEN trunc(v2.EFFECTIVE_FROM)
               AND nvl(trunc(v2.EFFECTIVE_TO), trunc(l_start_date)))
        AND v2.tax_exemption_id = l_tax_exemption_id;




    CURSOR old_exemption_period_csr(l_start_date DATE, l_tax_exemption_id NUMBER, l_trx_date DATE)
        IS
        SELECT exempt_certificate_number, effective_from, effective_to
        FROM zx_exemptions v1
        WHERE EXEMPTION_STATUS_CODE IN ('PRIMARY', 'MANUAL', 'UNAPPROVED')
        AND v1.tax_exemption_id = l_tax_exemption_id --selected tax_exemption_id from top_line_csr
        AND NOT EXISTS(
                       SELECT 1 FROM zx_exemptions v2
                       WHERE v2.tax_exemption_id = l_tax_exemption_id
                       AND trunc(l_trx_date) BETWEEN trunc(v1.EFFECTIVE_FROM) AND nvl(trunc(v1.EFFECTIVE_TO), trunc(l_trx_date ))
                       )
        ;




    CURSOR old_approved_exemption_csr(l_tax_exempt_id NUMBER)
        IS
        -- if the sql statement fetches a row, raise error.
        SELECT exemption_status_code
        FROM ZX_EXEMPTIONS
        WHERE exemption_status_code = 'UNAPPROVED'
        AND TAX_EXEMPTION_ID = l_tax_exempt_id;




    CURSOR tax_info_csr(p_site_use_id IN NUMBER) IS
        SELECT c.party_id,
        a.party_site_id,
        a.cust_account_id,
        a.org_id
        FROM hz_cust_acct_sites_all a,
        hz_cust_site_uses_all b,
        hz_party_sites c
        WHERE a.cust_acct_site_id = b.cust_acct_site_id
        AND c.party_site_id = a.party_site_id
        AND b.site_use_id = p_site_use_id;

    l_bill_tax_info_rec tax_info_csr%ROWTYPE;
    l_ship_tax_info_rec tax_info_csr%ROWTYPE;
    l_hdr_bill_tax_rec  tax_info_csr%ROWTYPE;
    l_hdr_ship_tax_rec  tax_info_csr%ROWTYPE;

    --End: Add for R12


    -- added for tax exemption project
    -- select tax exemption_id and cle_id

    CURSOR top_line_csr(p_chr_id IN NUMBER) IS
        SELECT CLEB.id,
        tax_exemption_id,
        line_number,
        bill_to_site_use_id,
        ship_to_site_use_id,
        cust_acct_id,
        start_date,
        exempt_certificate_number,
        exempt_reason_code

        FROM
          OKC_K_LINES_B CLEB,
          OKS_K_LINES_B KLN
        WHERE
        CLEB.dnz_chr_id = p_chr_id AND
        CLEB.ID = KLN.CLE_ID AND
        lse_id IN (1, 12, 19, 46);

    -- added for tax exemption project
    -- select date transaction

    CURSOR trx_date_csr(l_cle_id IN NUMBER) IS
        SELECT MAX(date_transaction)
        FROM oks_level_elements
        WHERE parent_cle_id = l_cle_id;


    -- GCHADHA --
    -- 5/6/2005 --
    -- IKON ENHANCEMENT --
    CURSOR old_check_tax_exempt_acct(l_tax_exemption_id IN NUMBER ) IS
        SELECT cust_account_id
        FROM zx_exemptions
        WHERE exemption_status_code IN ('PRIMARY', 'MANUAL', 'UNAPPROVED')
        AND tax_exemption_id = l_tax_exemption_id; --selected tax_exemption_id from top_line_csr

    /**  not needed for new R12 flow bug 5264786
    CURSOR new_check_tax_exempt_acct(l_tax_exempt_number VARCHAR2,
                                     l_tax_exempt_reason_code VARCHAR2) IS
        SELECT cust_account_id
        FROM zx_exemptions_v
        WHERE EXEMPT_CERTIFICATE_NUMBER = l_tax_exempt_number
        AND EXEMPT_REASON_CODE = l_tax_exempt_reason_code
        AND exemption_status_code IN ('PRIMARY', 'MANUAL', 'UNAPPROVED');
    **/

    CURSOR  Get_Customer_Name (p_cust_acct_id IN NUMBER) IS
        SELECT name
        FROM okx_customer_accounts_v
        WHERE id1 = p_cust_acct_id;

    -- IKON ENHANCEMENT -
    CURSOR get_hdr_tax_exemp(p_chr_id NUMBER) IS
        SELECT
        tax_exemption_id,
        exempt_certificate_number,
        exempt_reason_code,
        bill_to_site_use_id,
        ship_to_site_use_id,
        cust_acct_id,
        start_date,
        end_date
        FROM
        okc_k_headers_all_b OKC,
        OKS_K_HEADERS_B OKS
        WHERE
        OKC.id = p_chr_id AND
        OKC.ID = OKS.chr_id
        AND (exempt_certificate_number IS NOT NULL
             OR tax_exemption_id IS NOT NULL);
    hdr_tax_exemp_rec get_hdr_tax_exemp%ROWTYPE;


    CURSOR Cur_Batch_Source_Id(p_org_id IN NUMBER)
        IS
        SELECT BATCH_SOURCE_ID
        FROM ra_batch_sources_all
        WHERE org_id = p_org_id
        AND NAME = 'OKS_CONTRACTS';

    CURSOR Cur_Inv_Trx_Type(p_chr_id IN NUMBER)
        IS
        SELECT inv_trx_type
        FROM OKS_K_HEADERS_B
        WHERE OKS_K_HEADERS_B.id = p_chr_id;

    CURSOR cust_acct_csr(p_site_use_id NUMBER) IS
        SELECT ACCT_SITE_SHIP.CUST_ACCOUNT_ID
        FROM
           HZ_CUST_SITE_USES_ALL       S_SHIP,
           HZ_CUST_ACCT_SITES_ALL          ACCT_SITE_SHIP
        WHERE  S_SHIP.SITE_USE_ID = p_site_use_id
        AND  S_SHIP.CUST_ACCT_SITE_ID = acct_site_ship.cust_acct_site_id
        ;





    --l_cle_id  NUMBER;
    l_tax_exemption_id  NUMBER;
    l_status	 VARCHAR2(30);
    l_trx_date  DATE;
    --l_number   NUMBER;
    l_tax_exemption_number VARCHAR2(80);
    l_start_date  DATE;
    --l_line_start_date  DATE; -- Added for bug # 4069388
    --l_exemption_id    number;
    l_end_date      DATE;
    l_bill_to_site_use_id  NUMBER;
    l_ship_to_site_use_id  NUMBER;

    --l_cust_acct_id   NUMBER;


    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE dte_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    TYPE chr80_tbl_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
    TYPE chr30_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    l_cle_id_tbl              num_tbl_type;
    l_tax_exemption_id_tbl    num_tbl_type;
    l_number_tbl              num_tbl_type;
    l_bill_to_site_use_id_tbl num_tbl_type;
    l_ship_to_site_use_id_tbl num_tbl_type;
    l_cust_acct_id_tbl        num_tbl_type;
    l_line_start_date_tbl     dte_tbl_type;
    l_exempt_cert_number_tbl chr80_tbl_type;
    l_exempt_reason_code_tbl chr30_tbl_type;


    -- IKON ENHANCEMENT --
    -- GCHADHA --
    -- 5/6/2005 --
    l_cust_acct_name          VARCHAR2(360);
    l_tax_exempt_acct         NUMBER;
    -- IKON ENHANCEMENT --

    --Added in R12
    l_exempt_certificate_number  VARCHAR2(80);
    l_exempt_reason_code         VARCHAR2(30);
    l_bill_to_party_site_id      NUMBER;
    l_ship_to_party_site_id      NUMBER;
    l_bill_to_cust_acct_id       NUMBER;
    l_bill_to_party_id           NUMBER;
    l_legal_entity_id            NUMBER;
    l_org_id                     NUMBER;
    l_inv_trx_type               OKS_K_HEADERS_B.inv_trx_type%TYPE;
    l_cust_trx_type_id           NUMBER;
    l_batch_source_id            NUMBER;

    l_valid_flag                 VARCHAR2(1);
    l_return_status              VARCHAR2(1);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    BEGIN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_mod_name || '.begin', 'p_chrid=' || p_chr_id);
        END IF;

        --basic input validation
        IF(p_chr_id IS NULL) THEN
            FND_MESSAGE.set_name(G_APP_NAME, 'OKS_MANDATORY_ARG');
            FND_MESSAGE.set_token('ARG_NAME', 'p_chr_id');
            FND_MESSAGE.set_token('PROG_NAME', G_PKG_NAME || '.' || l_api_name);
            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.message(FND_LOG.level_error, l_mod_name || '.input_validation', FALSE);
            END IF;
            FND_MSG_PUB.ADD;
            RAISE FND_API.g_exc_error;
        END IF;

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;



        --modified top_line_csr to use bulk collect for bug 5442886

        OPEN top_line_csr(p_chr_id);
        LOOP
	        FETCH top_line_csr BULK COLLECT INTO l_cle_id_tbl,l_tax_exemption_id_tbl, l_number_tbl,
	        l_bill_to_site_use_id_tbl, l_ship_to_site_use_id_tbl, l_cust_acct_id_tbl, l_line_start_date_tbl,
			l_exempt_cert_number_tbl, l_exempt_reason_code_tbl LIMIT G_BULK_FETCH_LIMIT;

	        EXIT WHEN l_cle_id_tbl.COUNT = 0;

                FOR i IN l_cle_id_tbl.FIRST..l_cle_id_tbl.LAST LOOP

	            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'After querying the top line');
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_cle_id: '|| l_cle_id_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_tax_exemption_id: '|| l_tax_exemption_id_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_number: '|| l_number_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_site_use_id: '|| l_bill_to_site_use_id_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_ship_to_site_use_id: '|| l_ship_to_site_use_id_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_cust_acct_id: '|| l_cust_acct_id_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_line_start_date: '|| l_line_start_date_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_exempt_cert_number: '|| l_exempt_cert_number_tbl(i));
	                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_exempt_reason_code: '|| l_exempt_reason_code_tbl(i));
	            END IF;


	            IF l_exempt_cert_number_tbl(i) IS NOT NULL THEN
	                --New contracts
	                l_trx_date := NULL;
	                OPEN trx_date_csr(l_cle_id_tbl(i));
	                FETCH trx_date_csr INTO l_trx_date;
	                CLOSE trx_date_csr;

	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_trx_date: '|| l_trx_date);
	                END IF;

	                OPEN tax_info_csr(l_bill_to_site_use_id_tbl(i));
	                FETCH tax_info_csr INTO l_bill_tax_info_rec;
	                IF tax_info_csr%FOUND THEN
	                    l_bill_to_party_site_id := l_bill_tax_info_rec.party_site_id;
	                    l_bill_to_party_id := l_bill_tax_info_rec.party_id;
	                    l_bill_to_cust_acct_id := l_bill_tax_info_rec.cust_account_id;
	                    l_org_id := l_bill_tax_info_rec.org_id;
	                END IF;
	                CLOSE tax_info_csr;

	                IF l_bill_to_cust_acct_id IS NULL THEN
	                    --if cust_acct_id is null, we can derive it from the site_use_id
	                    OPEN cust_acct_csr(l_bill_to_site_use_id_tbl(i));
	                    FETCH cust_acct_csr INTO l_bill_to_cust_acct_id;
	                    CLOSE cust_acct_csr;
	                END IF;

	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_party_site_id: '|| l_bill_to_party_site_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_party_id: '|| l_bill_to_party_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_cust_acct_id: '|| l_bill_to_cust_acct_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_org_id: '|| l_org_id);
	                END IF;

	                OPEN tax_info_csr(l_ship_to_site_use_id_tbl(i));
	                FETCH tax_info_csr INTO l_ship_tax_info_rec;
	                IF tax_info_csr%FOUND THEN
	                    l_ship_to_party_site_id := l_ship_tax_info_rec.party_site_id;
	                END IF;
	                CLOSE tax_info_csr;
	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_ship_to_party_site_id: '|| l_ship_to_party_site_id);
	                END IF;

	                --inv_trx_type is per contract
	                --so to avoid execute the query multiple times over multiple lines,
	                --we put a conditional check
	                IF l_inv_trx_type IS NULL THEN
	                    OPEN Cur_Inv_Trx_Type(p_chr_id);
	                    FETCH Cur_Inv_Trx_Type INTO l_inv_trx_type;
	                    CLOSE Cur_Inv_Trx_Type;
	                END IF;

	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_inv_trx_type: '|| l_inv_trx_type);
	                END IF;

	                l_cust_trx_type_id := Get_Cust_Trx_Type_Id(l_org_id, l_inv_trx_type);
	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_cust_trx_type_id: '|| l_cust_trx_type_id);
	                END IF;

	                OPEN Cur_Batch_Source_Id(l_org_id);
	                FETCH Cur_Batch_Source_Id INTO l_batch_source_id;
	                CLOSE Cur_Batch_Source_Id;

	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_batch_source_id: '|| l_batch_source_id);
	                END IF;


	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'Before calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on l_line_start_date: '|| l_line_start_date_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_tax_exempt_number: '|| l_exempt_cert_number_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_tax_exempt_reason_code: '|| l_exempt_reason_code_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_ship_to_org_id: '|| l_ship_to_site_use_id_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_invoice_to_org_id: '|| l_bill_to_site_use_id_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_cust_account_id: '|| l_bill_to_cust_acct_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_ship_to_party_site_id: '|| l_ship_to_party_site_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_party_site_id: '|| l_bill_to_party_site_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_org_id: '|| l_org_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_party_id: '|| l_bill_to_party_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_legal_entity_id: '|| l_legal_entity_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_trx_type_id: '|| l_cust_trx_type_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_batch_source_id: '|| l_batch_source_id);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_trx_date: '|| l_line_start_date_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_exemption_status: '|| 'PMU');
	                END IF;

	                ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
	                (p_tax_exempt_number => l_exempt_cert_number_tbl(i),
	                 p_tax_exempt_reason_code => l_exempt_reason_code_tbl(i),
	                 p_ship_to_org_id => l_ship_to_site_use_id_tbl(i),
	                 p_invoice_to_org_id => l_bill_to_site_use_id_tbl(i),
	                 p_bill_to_cust_account_id => l_bill_to_cust_acct_id,
	                 p_ship_to_party_site_id => l_ship_to_party_site_id,
	                 p_bill_to_party_site_id => l_bill_to_party_site_id,
	                 p_org_id => l_org_id,
	                 p_bill_to_party_id => l_bill_to_party_id,
	                 p_legal_entity_id => l_legal_entity_id,  --per Nilesh Patel, legal_entity_id is optional
	                 p_trx_type_id => l_cust_trx_type_id,
	                 p_batch_source_id => l_batch_source_id,
	                 p_trx_date => l_line_start_date_tbl(i),
	                 p_exemption_status => 'PMU',  --fix bug 4766994
	                 x_valid_flag => l_valid_flag,
	                 x_return_status => l_return_status,
	                 x_msg_count => l_msg_count,
	                 x_msg_data => l_msg_data);

	                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'After calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on l_line_start_date: '|| l_line_start_date_tbl(i));
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_valid_flag: '|| l_valid_flag);
	                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_legal_entity_id: '|| l_legal_entity_id);
	                END IF;


	                IF l_valid_flag <> 'Y' THEN

	                    OKC_API.set_message(p_app_name => G_APP_NAME,
	                                        p_msg_name => G_INVALID_TAX_EXEMPT_DATE,
	                                        p_token1 => 'LINE_NUM',
	                                        p_token1_value => l_number_tbl(i),
	                                        p_token2 => 'EXEMPT_NUM',
	                                        p_token2_value => l_exempt_cert_number_tbl(i)
	                                        );

	                    x_return_status := OKC_API.G_RET_STS_ERROR;


	                    -- GCHADHA --
	                    -- IKON Enhancement --
	                    -- 5/6/2005 --
	                ELSE
	                    --now check if the exemption is valid at the transaction date (end date)
	                    --of the contract
	                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'Before calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on l_trx_date: '|| l_trx_date);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_tax_exempt_number: '|| l_exempt_cert_number_tbl(i));
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_tax_exempt_reason_code: '|| l_exempt_reason_code_tbl(i));
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_ship_to_org_id: '|| l_ship_to_site_use_id_tbl(i));
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_invoice_to_org_id: '|| l_bill_to_site_use_id_tbl(i));
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_cust_account_id: '|| l_bill_to_cust_acct_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_ship_to_party_site_id: '|| l_ship_to_party_site_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_party_site_id: '|| l_bill_to_party_site_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_org_id: '|| l_org_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_bill_to_party_id: '|| l_bill_to_party_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_legal_entity_id: '|| l_legal_entity_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_trx_type_id: '|| l_cust_trx_type_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_batch_source_id: '|| l_batch_source_id);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_trx_date: '|| l_line_start_date_tbl(i));
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'p_exemption_status: '|| 'PMU');
	                    END IF;

	                    ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
	                    (p_tax_exempt_number => l_exempt_cert_number_tbl(i),
	                     p_tax_exempt_reason_code => l_exempt_reason_code_tbl(i),
	                     p_ship_to_org_id => l_ship_to_site_use_id_tbl(i),
	                     p_invoice_to_org_id => l_bill_to_site_use_id_tbl(i),
	                     p_bill_to_cust_account_id => l_bill_to_cust_acct_id,
	                     p_ship_to_party_site_id => l_ship_to_party_site_id,
	                     p_bill_to_party_site_id => l_bill_to_party_site_id,
	                     p_org_id => l_org_id,
	                     p_bill_to_party_id => l_bill_to_party_id,
	                     p_legal_entity_id => l_legal_entity_id,  --per Nilesh Patel, legal_entity_id is optional
	                     p_trx_type_id => l_cust_trx_type_id,
	                     p_batch_source_id => l_batch_source_id,
	                     p_trx_date => l_trx_date,
	                     p_exemption_status => 'PMU', --fix bug 4766994
	                     x_valid_flag => l_valid_flag,
	                     x_return_status => l_return_status,
	                     x_msg_count => l_msg_count,
	                     x_msg_data => l_msg_data);

	                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'After calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on l_trx_date: '|| l_trx_date);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_valid_flag: '|| l_valid_flag);
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_legal_entity_id: '|| l_legal_entity_id);
	                    END IF;

	                    IF l_valid_flag <> 'Y' THEN
	                        OKC_API.set_message(
	                                            p_app_name => G_APP_NAME,
	                                            p_msg_name => 'OKS_PARTIAL_TAX_EXEMPT_LINE',
	                                            p_token1 => 'EXEMPT_NUM',
	                                            p_token1_value => l_exempt_cert_number_tbl(i),
	                                            p_token2 => 'LINE_NUM',
	                                            p_token2_value => l_number_tbl(i));
	                        -- notify caller of an error
	                        x_return_status := OKC_API.G_RET_STS_ERROR;

	                    /**  not needed for new R12 flow bug 5264786
	                    ELSE

	                        OPEN new_check_tax_exempt_acct(l_exempt_certificate_number, l_exempt_reason_code);
	                        FETCH  new_check_tax_exempt_acct INTO l_tax_exempt_acct;
	                        CLOSE new_check_tax_exempt_acct;
	                        IF l_tax_exempt_acct <> l_cust_acct_id THEN
	                            OPEN Get_Customer_Name (l_cust_acct_id);
	                            FETCH Get_Customer_Name INTO l_cust_acct_name;
	                            CLOSE Get_Customer_Name;
	                            OKC_API.set_message(
	                                                p_app_name => G_APP_NAME,
	                                                p_msg_name => G_INVALID_TAX_EXEMPT_LINE,
	                                                p_token1 => 'TOKEN1',
	                                                p_token1_value => l_exempt_certificate_number,
	                                                p_token2 => 'TOKEN2',
	                                                p_token2_value => l_cust_acct_name,
	                                                p_token3 => 'TOKEN3',
	                                                p_token3_value => l_number);
	                            x_return_status := OKC_API.G_RET_STS_ERROR;
	                        END IF;
	                     **/

	                        -- END GCHADHA --
	                        -- 5/6/2005 --
	                        -- IKON Enhancement --
	                    END IF; --l_valid_flag <> 'Y'



	                END IF;


	            ELSIF l_tax_exemption_id_tbl(i) IS NOT NULL THEN
	                --historical contracts
	                OPEN old_valid_exemption_csr(l_tax_exemption_id_tbl(i), l_line_start_date_tbl(i)); --old_valid_exemption_csr
	                FETCH old_valid_exemption_csr INTO l_tax_exemption_number;
	                -- if found means date does not fall between the start date/end date of the exemption
	                IF old_valid_exemption_csr%FOUND THEN
	                    -- Line LINE_NUM start date does not fall within the effective dates
	                    -- for Tax Exemption EXEMPT_NUM. The Tax Exemption will not be applied to this line.
	                    OKC_API.set_message(p_app_name => G_APP_NAME,
	                                        p_msg_name => G_INVALID_TAX_EXEMPT_DATE,
	                                        p_token1 => 'LINE_NUM',
	                                        p_token1_value => l_number_tbl(i),
	                                        p_token2 => 'EXEMPT_NUM',
	                                        p_token2_value => l_tax_exemption_number
	                                        );
	                    x_return_status := OKC_API.G_RET_STS_ERROR;

	                ELSE
	                    OPEN trx_date_csr(l_cle_id_tbl(i));
	                    FETCH trx_date_csr INTO l_trx_date;

	                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_trx_date: '|| l_trx_date);
	                    END IF;

	                    IF  trx_date_csr%found AND l_tax_exemption_id_tbl(i) IS NOT NULL THEN
	                        OPEN old_exemption_period_csr (l_line_start_date_tbl(i), l_tax_exemption_id_tbl(i), l_trx_date) ;
	                        FETCH  old_exemption_period_csr INTO l_tax_exemption_number, l_start_date, l_end_date ;
	                        IF   old_exemption_period_csr%FOUND THEN
	                            OKC_API.set_message(
	                                                p_app_name => G_APP_NAME,
	                                                p_msg_name => G_INVALID_TAX_EXEMPT,
	                                                p_token1 => 'EXEMPTNUMBER',
	                                                p_token1_value => l_tax_exemption_number,
	                                                p_token2 => 'LINE',
	                                                p_token2_value => l_number_tbl(i),
	                                                p_token3 => 'DATE',
	                                                p_token3_value => l_end_date);
	                            -- notify caller of an error
	                            x_return_status := OKC_API.G_RET_STS_ERROR;
	                            -- GCHADHA --
	                            -- IKON Enhancement --
	                            -- 5/6/2005 --
	                        ELSE
	                            OPEN old_check_tax_exempt_acct(l_tax_exemption_id_tbl(i));
	                            FETCH  old_check_tax_exempt_acct INTO l_tax_exempt_acct;
	                            CLOSE old_check_tax_exempt_acct;
	                            IF l_tax_exempt_acct <> l_cust_acct_id_tbl(i) THEN
	                                OPEN Get_Customer_Name (l_cust_acct_id_tbl(i));
	                                FETCH Get_Customer_Name INTO l_cust_acct_name;
	                                CLOSE Get_Customer_Name;
	                                OKC_API.set_message(
	                                                    p_app_name => G_APP_NAME,
	                                                    p_msg_name => G_INVALID_TAX_EXEMPT_LINE,
	                                                    p_token1 => 'TOKEN1',
	                                                    p_token1_value => l_tax_exemption_number,
	                                                    p_token2 => 'TOKEN2',
	                                                    p_token2_value => l_cust_acct_name,
	                                                    p_token3 => 'TOKEN3',
	                                                    p_token3_value => l_number_tbl(i));
	                                x_return_status := OKC_API.G_RET_STS_ERROR;
	                            END IF;
	                            -- END GCHADHA --
	                            -- 5/6/2005 --
	                            -- IKON Enhancement --
	                        END IF;
	                        CLOSE old_exemption_period_csr;
	                    END IF;
	                    CLOSE trx_date_csr;
	                END IF;
	                CLOSE old_valid_exemption_csr;
	                -- Added for bug # 4085884

	                OPEN old_approved_exemption_csr(l_tax_exemption_id_tbl(i)); --old_approved_exemption_csr
	                FETCH old_approved_exemption_csr INTO l_status;
	                IF old_approved_exemption_csr%FOUND THEN
	                    -- Line LINE_NUM has an unapproved exemption. Billing this
	                    -- line will result in creation of an invoice with an
	                    -- unapproved tax exemption.
	                    OKC_API.set_message(p_app_name => G_APP_NAME,
	                                        p_msg_name => G_UNAPPROVED_TAX_EXEMPT,
	                                        p_token1 => 'LINE_NUM',
	                                        p_token1_value => l_number_tbl(i)
	                                        );
	                    x_return_status := OKC_API.G_RET_STS_ERROR;
	                END IF;
	                CLOSE old_approved_exemption_csr;

	            END IF;

            END LOOP;

        END LOOP;

        CLOSE top_line_csr;



        OPEN get_hdr_tax_exemp(p_chr_id);
        FETCH get_hdr_tax_exemp INTO hdr_tax_exemp_rec;
        IF get_hdr_tax_exemp%FOUND THEN
            IF hdr_tax_exemp_rec.tax_exemption_id IS NOT NULL THEN
                OPEN old_approved_exemption_csr(hdr_tax_exemp_rec.tax_exemption_id);
                FETCH old_approved_exemption_csr INTO l_status;
                IF old_approved_exemption_csr%FOUND THEN
                    OKC_API.set_message(p_app_name => G_APP_NAME,
                                        p_msg_name => G_UNAPPROVED_HDR_TAX_EXEMPT
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
                CLOSE old_approved_exemption_csr;
            ELSIF hdr_tax_exemp_rec.exempt_certificate_number IS NOT NULL THEN
                -- This contract has an unapproved exemption. Billing this
                -- contract will result in creation of an invoice with an
                -- unapproved tax exemption.


                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_trx_date: '|| l_trx_date);
                END IF;

                OPEN tax_info_csr(hdr_tax_exemp_rec.bill_to_site_use_id);
                FETCH tax_info_csr INTO l_hdr_bill_tax_rec;
                IF tax_info_csr%FOUND THEN
                    l_bill_to_party_site_id := l_hdr_bill_tax_rec.party_site_id;
                    l_bill_to_party_id := l_hdr_bill_tax_rec.party_id;
                    l_bill_to_cust_acct_id := l_hdr_bill_tax_rec.cust_account_id;
                    l_org_id := l_hdr_bill_tax_rec.org_id;
                ELSE
                    --this is to avoid the case when the values on the line are retained
                    --even though there's no value on the header
                    l_bill_to_party_site_id := NULL;
                    l_bill_to_party_id := NULL;
                    l_bill_to_cust_acct_id := NULL;
                    l_org_id := NULL;
                END IF;
                CLOSE tax_info_csr;

                IF l_bill_to_cust_acct_id IS NULL THEN
                    --if cust_acct_id is null, we can derive it from the site_use_id
                    OPEN cust_acct_csr(hdr_tax_exemp_rec.bill_to_site_use_id);
                    FETCH cust_acct_csr INTO l_bill_to_cust_acct_id;
                    CLOSE cust_acct_csr;
                END IF;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_party_site_id: '|| l_bill_to_party_site_id);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_party_id: '|| l_bill_to_party_id);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_bill_to_cust_acct_id: '|| l_bill_to_cust_acct_id);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_org_id: '|| l_org_id);
                END IF;

                OPEN tax_info_csr(hdr_tax_exemp_rec.ship_to_site_use_id);
                FETCH tax_info_csr INTO l_hdr_ship_tax_rec;
                IF tax_info_csr%FOUND THEN
                    l_ship_to_party_site_id := l_hdr_ship_tax_rec.party_site_id;
                END IF;
                CLOSE tax_info_csr;
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_ship_to_party_site_id: '|| l_ship_to_party_site_id);
                END IF;

                --inv_trx_type is already obtained from the header, so no need to
                --re-execute the query to get the trx_type_id
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_inv_trx_type: '|| l_inv_trx_type);
                END IF;

                l_cust_trx_type_id := Get_Cust_Trx_Type_Id(l_org_id, l_inv_trx_type);
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_cust_trx_type_id: '|| l_cust_trx_type_id);
                END IF;

                OPEN Cur_Batch_Source_Id(l_org_id);
                FETCH Cur_Batch_Source_Id INTO l_batch_source_id;
                CLOSE Cur_Batch_Source_Id;

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_batch_source_id: '|| l_batch_source_id);
                END IF;


                ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
                (p_tax_exempt_number => hdr_tax_exemp_rec.exempt_certificate_number,
                 p_tax_exempt_reason_code => hdr_tax_exemp_rec.exempt_reason_code,
                 p_ship_to_org_id => hdr_tax_exemp_rec.ship_to_site_use_id, -- Modified By sjanakir for bug#6709146
                 p_invoice_to_org_id => hdr_tax_exemp_rec.bill_to_site_use_id, -- Modified By sjanakir for bug#6709146
                 p_bill_to_cust_account_id => l_bill_to_cust_acct_id,
                 p_ship_to_party_site_id => l_ship_to_party_site_id,
                 p_bill_to_party_site_id => l_bill_to_party_site_id,
                 p_org_id => l_org_id,
                 p_bill_to_party_id => l_bill_to_party_id,
                 p_legal_entity_id => l_legal_entity_id,  --per Nilesh Patel, legal_entity_id is optional
                 p_trx_type_id => l_cust_trx_type_id,
                 p_batch_source_id => l_batch_source_id,
                 p_exemption_status => 'PMU',  -- fix bug 4766994
                 p_trx_date => hdr_tax_exemp_rec.start_date,
                 x_valid_flag => l_valid_flag,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data);

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'After calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on header start_date: '|| hdr_tax_exemp_rec.start_date);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_valid_flag: '|| l_valid_flag);
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_legal_entity_id: '|| l_legal_entity_id);
                END IF;


                IF l_valid_flag <> 'Y' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => 'OKS_INVALID_TAX_EXEMPT_HEADER',
                                        p_token1 => 'EXEMPT_NUM',
                                        p_token1_value => hdr_tax_exemp_rec.exempt_certificate_number);

                    x_return_status := OKC_API.G_RET_STS_ERROR;

                ELSE
                    ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS
                    (p_tax_exempt_number => hdr_tax_exemp_rec.exempt_certificate_number,
                     p_tax_exempt_reason_code => hdr_tax_exemp_rec.exempt_reason_code,
                     p_ship_to_org_id => hdr_tax_exemp_rec.ship_to_site_use_id, -- Modified By sjanakir for bug#6709146
                     p_invoice_to_org_id => hdr_tax_exemp_rec.bill_to_site_use_id, -- Modified By sjanakir for bug#6709146
                     p_bill_to_cust_account_id => l_bill_to_cust_acct_id,
                     p_ship_to_party_site_id => l_ship_to_party_site_id,
                     p_bill_to_party_site_id => l_bill_to_party_site_id,
                     p_org_id => l_org_id,
                     p_bill_to_party_id => l_bill_to_party_id,
                     p_legal_entity_id => l_legal_entity_id,  --per Nilesh Patel, legal_entity_id is optional
                     p_trx_type_id => l_cust_trx_type_id,
                     p_batch_source_id => l_batch_source_id,
                     p_trx_date => hdr_tax_exemp_rec.end_date,
                     p_exemption_status => 'PMU',  --fix bug 4766994
                     x_valid_flag => l_valid_flag,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data);

                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'After calling ZX_TCM_VALIDATE_EXEMPT_PKG.VALIDATE_TAX_EXEMPTIONS on header end_date: '|| hdr_tax_exemp_rec.end_date);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_valid_flag: '|| l_valid_flag);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_mod_name,'l_legal_entity_id: '|| l_legal_entity_id);
                    END IF;
                    IF l_valid_flag <> 'Y' THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => 'OKS_PARTIAL_TAX_EXEMPT_HEADER',
                                            p_token1 => 'EXEMPT_NUM',
                                            p_token1_value => hdr_tax_exemp_rec.exempt_certificate_number);

                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;


                END IF;



            END IF;
        END IF;
        CLOSE get_hdr_tax_exemp;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_mod_name,'Leaving: '|| l_api_name);
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF top_line_csr%ISOPEN THEN
                CLOSE top_line_csr;
            END IF;

            IF trx_date_csr%ISOPEN THEN
                CLOSE trx_date_csr;
            END IF;

            IF old_valid_exemption_csr%ISOPEN THEN
                CLOSE old_valid_exemption_csr;
            END IF;


            IF old_exemption_period_csr%ISOPEN THEN
                CLOSE old_exemption_period_csr;
            END IF;


            IF old_approved_exemption_csr%ISOPEN THEN
                CLOSE old_approved_exemption_csr;
            END IF;


            IF old_check_tax_exempt_acct%ISOPEN THEN
                CLOSE old_check_tax_exempt_acct;
            END IF;

            /**
            IF new_check_tax_exempt_acct%ISOPEN THEN
                CLOSE new_check_tax_exempt_acct;
            END IF;
            **/

            IF tax_info_csr%ISOPEN THEN
                CLOSE tax_info_csr;
            END IF;

            IF Get_Customer_Name%ISOPEN THEN
                CLOSE Get_Customer_Name;
            END IF;

            IF get_hdr_tax_exemp%ISOPEN THEN
                CLOSE get_hdr_tax_exemp;
            END IF;

            IF Cur_Batch_Source_Id%ISOPEN THEN
                CLOSE Cur_Batch_Source_Id;
            END IF;

            IF Cur_Inv_Trx_Type%ISOPEN THEN
                CLOSE Cur_Inv_Trx_Type;
            END IF;


    END check_tax_exemption;







    /*============================================================================+
    | Procedure:           check_cust_credit_hold
    |
    | Purpose:       Checks if the customer is on credit hold.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_cust_credit_hold(
                                     x_return_status            OUT NOCOPY VARCHAR2,
                                     p_chr_id                   IN  NUMBER
                                     )
    IS
    -- object1_id1 of BTO rule
   /*Modified cursor for bug8819474 as per appsperf team suggestion,
     added to_char to CA.CUST_ACCOUNT_ID */
  /* Modified for bug 7446647
  CURSOR check_cust_on_credit_hold
        IS
        SELECT prt.party_name
          FROM oe_hold_sources_all		ohs,
               HZ_PARTIES prt,
               HZ_PARTY_SITES PS, HZ_CUST_ACCT_SITES_ALL CA, HZ_CUST_SITE_USES_ALL CS,
               okc_k_headers_all_b                  rl
        WHERE  ohs.hold_entity_code = 'C'
          AND  ohs.released_flag = 'N'
          AND  ohs.org_id = okc_context.get_okc_org_id
          AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
          AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
          AND  CS.SITE_USE_CODE = 'BILL_TO'
          AND  PS.PARTY_ID = prt.party_id
          AND prt.PARTY_TYPE IN ('PERSON', 'ORGANIZATION')
          AND  CS.SITE_USE_ID = rl.BILL_TO_SITE_USE_ID -- object1_id1
          AND rl.id = p_chr_id
          AND  ohs.hold_entity_id = to_char(CA.CUST_ACCOUNT_ID); --okx_bill_to.cust_account_id  */


CURSOR check_cust_on_credit_hold
 IS
  SELECT prt.party_name,
         ohd.description,
         Decode(ohd.type_code,
                'CREDIT',
                1,
                'EPAYMENT',
                2,
                'COMPLIANCE',
                3,
                4) credit_typ
    FROM oe_hold_sources_all    ohs,
         oe_hold_definitions    ohd,
         HZ_PARTIES             prt,
         HZ_PARTY_SITES         PS,
         HZ_CUST_ACCT_SITES_ALL CA,
         HZ_CUST_SITE_USES_ALL  CS,
         okc_k_headers_all_b        rl
   WHERE ohs.hold_entity_code = 'C'
     AND ohs.released_flag = 'N'
     AND ohs.org_id = okc_context.get_okc_org_id
     AND ohs.hold_id = ohd.hold_id
     AND ohd.type_code IN ('CREDIT', 'EPAYMENT', 'COMPLIANCE', 'GSA')
     AND PS.PARTY_SITE_ID = CA.PARTY_SITE_ID
     AND CA.CUST_ACCT_SITE_ID = CS.CUST_ACCT_SITE_ID
     AND CS.SITE_USE_CODE = 'BILL_TO'
     AND PS.PARTY_ID = prt.party_id
     AND prt.PARTY_TYPE IN ('PERSON', 'ORGANIZATION')
     AND CS.SITE_USE_ID = rl.BILL_TO_SITE_USE_ID -- object1_id1
     AND rl.id   =  p_chr_id
     AND  ohs.hold_entity_id     = to_char(CA.CUST_ACCOUNT_ID)
   ORDER BY 3;



    v_customer_name     VARCHAR2(360);
    v_crd_hold_desc     VARCHAR2(2000);
    v_crd_typ           NUMBER;


    BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN   check_cust_on_credit_hold;
        FETCH  check_cust_on_credit_hold INTO v_customer_name, v_crd_hold_desc, v_crd_typ;


        IF   check_cust_on_credit_hold%FOUND
            THEN

            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_CUSTOMER_ON_CREDIT_HOLD,
                                p_token1 => 'CUSTOMER_NAME',
                                p_token1_value => v_customer_name,
                                p_token2       => 'HOLD_TYPE',
                                p_token2_value => v_crd_hold_desc);

            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

        CLOSE check_cust_on_credit_hold;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END check_cust_credit_hold;

    /*============================================================================+
    | Procedure:           check_address
    |
    | Purpose:       1. Checks if bill to address exists for service, usage and
    |                   extended warranty lines.
    |                2. Checks if bill to address is active for service, usage
    |                   and extended warranty lines.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_address(
                            x_return_status            OUT NOCOPY VARCHAR2,
                            p_chr_id                   IN  NUMBER
                            )
    IS

    /******
    -- Cursor CHECK_BILL_TO_ADDRESS to check if the bill to
    -- address is entered and is valid for all top lines.
    -- BTO rule. Replaced okx_cust_site_uses_v with HZ_CUST_SITE_USES_ALL
    CURSOR check_address (line_id  NUMBER, l_use_code VARCHAR2)
        IS
        SELECT CS.SITE_USE_ID, CS.STATUS, CS.CUST_ACCT_SITE_ID
        FROM 	okc_k_lines_b           rl,
              HZ_CUST_SITE_USES_ALL CS
        WHERE rl.dnz_chr_id = p_chr_id
        AND rl.id = line_id
        AND  CS.SITE_USE_ID = decode(l_use_code, 'BILL_TO', rl.BILL_TO_SITE_USE_ID, rl.SHIP_TO_SITE_USE_ID)
        AND CS.SITE_USE_CODE = l_use_code -- 'BILL_TO' or 'SHIP_TO'
        AND rl.date_cancelled IS NULL --Changes [llc]
        ;
     ******/

    CURSOR check_site (l_cust_acct_site_id NUMBER) IS
        SELECT CA.STATUS STATUS
        FROM HZ_CUST_ACCT_SITES_ALL CA
        WHERE CA.CUST_ACCT_SITE_ID = l_cust_acct_site_id;

    /******
    -- checks bill to address for top lines.
    CURSOR line_cur IS
        SELECT id, line_number FROM okc_k_lines_b
        WHERE dnz_chr_id = p_chr_id
        AND chr_id = p_chr_id
        AND cle_id IS NULL
        AND   lse_id IN (1, 12, 14, 19, 46)
        AND (date_terminated IS NULL OR date_terminated > SYSDATE)
        AND date_cancelled IS NULL --Changes [llc]
        ;
    ******/


    --bug 5442886
    -- to check if the bill to address is entered and is valid for all top lines.
    CURSOR check_top_line_address IS
    SELECT rl.id, rl.line_number,
           cs.site_use_id, cs.status site_use_status,
           cs.cust_acct_site_id,
           ca.status site_status,
           'BILL_TO' use_code
    FROM   okc_k_lines_b          rl,
           hz_cust_site_uses_all  cs,
           hz_cust_acct_sites_all ca
    WHERE  rl.dnz_chr_id = p_chr_id
    AND rl.chr_id = p_chr_id
    AND rl.cle_id IS NULL
    AND rl.lse_id IN (1,12, 14, 19, 46)
    AND (rl.date_terminated IS NULL OR rl.date_terminated > SYSDATE)
    AND rl.date_cancelled IS NULL
    --
    AND cs.site_use_id (+)= rl.bill_to_site_use_id
    AND cs.site_use_code (+)= 'BILL_TO'
    --
    AND ca.cust_acct_site_id (+)= cs.cust_acct_site_id
    UNION ALL
    SELECT rl.id, rl.line_number,
           cs.site_use_id, cs.status site_use_status,
           cs.cust_acct_site_id,
           ca.status site_status,
	    'SHIP_TO' use_code
    FROM   okc_k_lines_b          rl,
           hz_cust_site_uses_all  cs,
           hz_cust_acct_sites_all ca
    WHERE  rl.dnz_chr_id = p_chr_id
    AND rl.chr_id = p_chr_id
    AND rl.cle_id IS NULL
    AND rl.lse_id IN (1,12, 14, 19, 46)
    AND (rl.date_terminated IS NULL OR rl.date_terminated > SYSDATE)
    AND rl.date_cancelled IS NULL
    --
    AND cs.site_use_id (+)= rl.ship_to_site_use_id
    AND cs.site_use_code (+)= 'SHIP_TO' --l_use_code -- 'bill_to' or 'ship_to'
    --
    AND ca.cust_acct_site_id (+)= cs.cust_acct_site_id;

    TYPE chr150_tbl_type IS TABLE OF okc_k_lines_b.line_number%TYPE INDEX BY BINARY_INTEGER;
    TYPE chr7_tbl_type IS TABLE OF VARCHAR2(7) INDEX BY BINARY_INTEGER;
    TYPE chr1a_tbl_type IS TABLE OF hz_cust_site_uses_all.status%TYPE INDEX BY BINARY_INTEGER;
    TYPE chr1b_tbl_type IS TABLE OF hz_cust_acct_sites_all.status%TYPE INDEX BY BINARY_INTEGER;
    TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    l_id_tbl                num_tbl_type;
    l_line_number_tbl       chr150_tbl_type;
    l_site_use_id_tbl       num_tbl_type;
    l_site_use_status_tbl   chr1a_tbl_type;
    l_cust_acct_site_id_tbl num_tbl_type;
    l_site_status_tbl       chr1b_tbl_type;
    l_use_code_tbl          chr7_tbl_type;

    line_rec            check_top_line_address%ROWTYPE;
    line_id             NUMBER;
    l_status          VARCHAR2(30);

    -- GCHADHA --
    -- 4132844 --
    CURSOR check_address_header(l_site_use_id IN NUMBER, l_site_use_code IN VARCHAR2) IS
        SELECT   CS.SITE_USE_ID, CS.STATUS, CS.CUST_ACCT_SITE_ID
        FROM 	okc_k_headers_all_b           rl,
              HZ_CUST_SITE_USES_ALL CS
        WHERE  rl.id = p_chr_id
        AND  CS.SITE_USE_ID = l_site_use_id
        AND CS.SITE_USE_CODE = l_site_use_code;

    l_bto_address_rec   check_address_header%ROWTYPE;
    l_sto_address_rec   check_address_header%ROWTYPE;

    CURSOR get_billto_shipto(p_chr_id IN NUMBER) IS
        SELECT bill_to_site_use_id, ship_to_site_use_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id ;

    l_bill_to_site_use_id  NUMBER;
    l_ship_to_site_use_id  NUMBER;
    -- END GCHADHA --
    BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        -- Bug 4138244 --
        -- GCHADHA --
        OPEN get_billto_shipto(p_chr_id);
        FETCH get_billto_shipto INTO l_bill_to_site_use_id, l_ship_to_site_use_id ;
        CLOSE get_billto_shipto;

        IF l_bill_to_site_use_id IS NOT NULL  THEN
            OPEN check_address_header(l_bill_to_site_use_id, 'BILL_TO');
            FETCH check_address_header INTO l_bto_address_rec;
            IF check_address_header%FOUND THEN
                IF l_bto_address_rec.status <> 'A' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_BTO_INVALID_HEAD
                                        );

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                    OPEN check_site (l_bto_address_rec.cust_acct_site_id);
                    FETCH check_site INTO l_status;
                    IF check_site%FOUND THEN
                        IF l_status <> 'A' THEN
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_BTO_INVALID_HEAD
                                                );
                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;
                    END IF;
                    CLOSE check_site;
                END IF; -- If l_bto_address_rec.status <> 'A' THEN
            END IF; -- If check_address_header%FOUND Then
            CLOSE check_address_header;
        END  IF;

        IF l_ship_to_site_use_id IS NOT NULL THEN

            OPEN check_address_header(l_ship_to_site_use_id, 'SHIP_TO');
            FETCH check_address_header INTO l_sto_address_rec;
            IF check_address_header%FOUND THEN
                IF l_sto_address_rec.status <> 'A' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_STO_INVALID_HEAD
                                        );

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                    OPEN check_site (l_sto_address_rec.cust_acct_site_id);
                    FETCH check_site INTO l_status;
                    IF check_site%FOUND THEN
                        IF l_status <> 'A' THEN
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_STO_INVALID_HEAD
                                                );
                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;
                    END IF;
                    CLOSE check_site;
                END IF; -- If l_sto_address_rec.status <> 'A' THEN
            END IF; -- If check_address_header%FOUND Then
            CLOSE check_address_header;

        END IF;


        -- END GCHADHA --

        /*******
        FOR line_rec IN line_cur

            LOOP
            -- Check if Bill to Address is entered
            line_id := line_rec.id;

            OPEN check_address(line_id, 'BILL_TO');
            FETCH check_address INTO l_bto_address_rec;

            IF   check_address%NOTFOUND THEN

                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_BTO_REQUIRED,
                                    p_token1 => 'LINE',
                                    p_token1_value => line_rec.line_number);

                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            ELSIF  l_bto_address_rec.status <> 'A' THEN
                -- If bill to address is entered then
                -- check if it is of active status

                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_BTO_INVALID,
                                    p_token1 => 'LINE',
                                    p_token1_value => line_rec.line_number);

                -- notify caller of an error
                x_return_status := OKC_API.G_RET_STS_ERROR;
            ELSE
                OPEN check_site (l_bto_address_rec.cust_acct_site_id);
                FETCH check_site INTO l_status;
                IF check_site%FOUND THEN
                    IF l_status <> 'A' THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_BTO_INVALID,
                                            p_token1 => 'LINE',
                                            p_token1_value => line_rec.line_number);
                        -- notify caller of an error
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;
                END IF;
                CLOSE check_site;
            END IF; -- Elsif l_bto_address_rec.status <> 'A' THEN
            CLOSE check_address;

            OPEN check_address(line_id, 'SHIP_TO');
            FETCH check_address INTO l_sto_address_rec;
            IF check_address%FOUND THEN
                IF l_sto_address_rec.status <> 'A' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_STO_INVALID,
                                        p_token1 => 'LINE',
                                        p_token1_value => line_rec.line_number);

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                    OPEN check_site (l_sto_address_rec.cust_acct_site_id);
                    FETCH check_site INTO l_status;
                    IF check_site%FOUND THEN
                        IF l_status <> 'A' THEN
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_STO_INVALID,
                                                p_token1 => 'LINE',
                                                p_token1_value => line_rec.line_number);
                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;
                    END IF;
                    CLOSE check_site;
                END IF; -- If l_sto_address_rec.status <> 'A' THEN
            END IF; -- If check_address%FOUND Then
            CLOSE check_address;
        END LOOP;
        *******/

        --bug 5442886
        OPEN check_top_line_address;
        LOOP

            FETCH check_top_line_address BULK COLLECT INTO l_id_tbl,
                                                           l_line_number_tbl,
                                                           l_site_use_id_tbl,
                                                           l_site_use_status_tbl,
                                                           l_cust_acct_site_id_tbl,
                                                           l_site_status_tbl,
                                                           l_use_code_tbl LIMIT G_BULK_FETCH_LIMIT;

            EXIT WHEN (l_id_tbl.COUNT = 0);

            FOR i IN l_id_tbl.FIRST..l_id_tbl.LAST LOOP

                IF l_site_use_id_tbl(i) IS NULL AND l_use_code_tbl(i) = 'BILL_TO' THEN
                -- Check if Bill to/Ship to Address is entered

                    OKC_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_BTO_REQUIRED,
                          p_token1       => 'LINE',
                          p_token1_value => l_line_number_tbl(i));

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                ELSIF l_site_use_status_tbl(i) <> 'A' THEN

                   IF l_use_code_tbl(i) = 'BILL_TO' THEN
                   -- If bill to address is entered then check if it is of active status
                       OKC_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_BTO_INVALID,
                          p_token1       => 'LINE',
                          p_token1_value => l_line_number_tbl(i));

                   ELSIF l_site_use_id_tbl(i) IS NOT NULL AND l_use_code_tbl(i) = 'SHIP_TO' THEN
                   -- If ship to address is entered then check if it is of active status
                       OKC_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_STO_INVALID,
                          p_token1       => 'LINE',
                          p_token1_value => l_line_number_tbl(i));
                   END IF;

                       -- notify caller of an error
                       x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                      IF l_cust_acct_site_id_tbl(i) IS NOT NULL AND l_site_status_tbl(i) <> 'A'  THEN

                           IF l_use_code_tbl(i) = 'BILL_TO' THEN
                              OKC_API.set_message(
                                 p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_BTO_INVALID,
                                 p_token1       => 'LINE',
                                 p_token1_value => l_line_number_tbl(i));

                           ELSIF l_use_code_tbl(i) = 'SHIP_TO' THEN
                              OKC_API.set_message(
                                 p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_STO_INVALID,
                                 p_token1       => 'LINE',
                                 p_token1_value => l_line_number_tbl(i));
                           END IF;


                           -- notify caller of an error
                           x_return_status := OKC_API.G_RET_STS_ERROR;

                      END IF;
                END IF;

            END LOOP;

        END LOOP;
        CLOSE check_top_line_address;


        IF x_return_status = OKC_API.G_RET_STS_SUCCESS
            THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed
            IF check_address_header%ISOPEN THEN
                CLOSE check_address_header;
            END IF;

    END check_address;


    /*============================================================================+
    | Procedure:           check_item_effectivity
    |
    | Purpose:     These checks are for entered status top lines:
    |              1. Checks if the inventory item status is active for entered
    |                 status line.
    |              2. Checks if the service item for service and extended warranty
    |                 lines is valid.
    |              3. Checks if the usage item for usage lines is valid.
    |
    |              These checks are for entered status covered levels:
    |              1. Checks if covered product status is active.
    |              2. Checks if covered item status is active.
    |              3. Checks if covered party status is active.
    |              4. Checks if covered product status is active.
    |              5. If header status is QA hold and covered level terminated
    |                 date/end date is greater than covered product end date
    |                 active then report an error if covered product status is
    |                 not active.
    |              6. Checks if covered system status is active.
    |              7. Checks if covered site status is active.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_item_effectivity
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     )
    IS

    CURSOR l_cle_csr IS
        SELECT cle.id, cle.lse_id, sts.ste_code sts_code,
               cle.start_date, cle.end_date, cle.date_terminated,
               cim.jtot_object1_code, cim.object1_id1, cim.object1_id2
          FROM okc_k_items cim,
               okc_k_lines_b cle,
               okc_statuses_b sts
          WHERE cle.dnz_chr_id = p_chr_id
      AND   cle.cle_id IS NULL
      AND   sts.code = cle.sts_code
          AND   cim.cle_id = cle.id
             AND cle.date_cancelled IS NULL --Changes [llc]
          ;

    l_cle_rec l_cle_csr%ROWTYPE;

    CURSOR l_status_csr(p_inv_item NUMBER, p_org_id NUMBER) IS
        SELECT 1
        FROM   Mtl_system_items
        WHERE  Inventory_item_id = p_inv_item
        AND    Organization_id = p_org_id
    AND     (SYSDATE BETWEEN
             NVL(start_date_active, SYSDATE) AND NVL(end_date_active, SYSDATE));

    --Service continuity check

    CURSOR l_chk_service_prod_csr (p_inv_item NUMBER, p_org_id NUMBER) IS
        SELECT service_item_flag, vendor_warranty_flag,
               usage_item_flag, serviceable_product_flag,
               customer_order_enabled_flag, internal_order_enabled_flag,
               invoice_enabled_flag
        FROM   MTL_SYSTEM_ITEMS_B_KFV
        WHERE  Inventory_item_id = p_inv_item
        AND    Organization_id = p_org_id;

    l_chk_service_prod_rec l_chk_service_prod_csr%ROWTYPE;

    CURSOR l_get_inv_item_csr (p_cp_id NUMBER) IS
        SELECT inventory_item_id
        FROM   csi_item_instances -- okx_cust_prod_v
        WHERE  instance_id = p_cp_id;

    l_get_inv_item_rec l_get_inv_item_csr%ROWTYPE;

    CURSOR l_cve_csr (p_cle_id NUMBER) IS
        SELECT cle.id, cle.PRICE_NEGOTIATED, cle.lse_id, sts.ste_code sts_code,
               cle.start_date, cle.end_date, cle.date_terminated,
               cim.jtot_object1_code, cim.object1_id1,
             cim.object1_id2
        FROM OKC_K_ITEMS cim,
             OKC_K_LINES_B cle,
             OKC_STATUSES_B sts
        WHERE cim.cle_id = cle.id
        AND   cle.cle_id = p_cle_id
        AND   sts.code = cle.sts_code
        AND   cle.lse_id IN (35, 7, 8, 9, 10, 11, 13, 18, 25);

    l_cve_rec l_cve_csr%ROWTYPE;


    CURSOR l_inv_csr(p_id NUMBER) IS
        SELECT object1_id1
        FROM   Okc_k_items
        WHERE  cle_id = p_id;

    CURSOR l_covitm_csr(p_inv_item NUMBER, p_org_id NUMBER) IS
        SELECT DECODE(ENABLED_FLAG, 'Y', 'A', 'I') status
        FROM   MTL_SYSTEM_ITEMS_B_KFV --okx_system_items_v
        WHERE  INVENTORY_ITEM_ID = p_inv_item
        AND    Organization_id = p_org_id
        AND serviceable_product_flag = 'Y';

    CURSOR l_covparty_csr(l_inv_id NUMBER) IS
        SELECT status
        FROM   HZ_PARTIES --okx_parties_v
        WHERE PARTY_TYPE IN ('PERSON', 'ORGANIZATION') AND PARTY_ID = l_inv_id;

    -- replaced okx_cust_prod_statuses_v with CS_CUSTOMER_PRODUCT_STATUSES
    -- replace okx_customer_products_v with csi_item_instances CP,MTL_SYSTEM_ITEMS_B_KFV BK
    CURSOR l_covprod_csr(p_inv_id NUMBER, p_org_id NUMBER) IS
        SELECT cs.Service_order_allowed_flag, CP.ACTIVE_END_DATE
        FROM CS_CUSTOMER_PRODUCT_STATUSES  cs,
        csi_item_instances CP, MTL_SYSTEM_ITEMS_B_KFV BK
        WHERE BK.INVENTORY_ITEM_ID = CP.INVENTORY_ITEM_ID
        AND CP.INSTANCE_STATUS_ID = cs.customer_product_status_id
        AND CP.INSTANCE_ID = p_inv_id
        AND BK.ORGANIZATION_ID = p_org_id;

 --Bug 5583158
    CURSOR l_covsys_csr(p_system_id  NUMBER) IS
        SELECT 'A'
        FROM   CSI_SYSTEMS_B CSB
        WHERE  CSB.system_id = p_system_id
	AND sysdate between NVL(start_date_active, sysdate) and NVL(end_date_active, sysdate);
 --Bug 5583158
    --commented out asked by umesh And org_id = p_org_id;

    CURSOR l_org_csr IS
        SELECT authoring_org_id, inv_organization_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    -- Changed this cursor because object1_id1 will be holding the party_site_id
    -- not the customer site use id.
    CURSOR l_covsit_csr(partySiteId NUMBER) IS
        SELECT status
        FROM HZ_PARTY_SITES -- okx_party_sites_v
        WHERE party_site_id = partySiteId;

    --Changed cursor because ste_code does not have QA_HOLD
    CURSOR l_hdr_csr(l_chr_id NUMBER) IS
        SELECT sts_code --sts.ste_code sts_code
        FROM   okc_k_headers_all_b
              -- ,okc_statuses_b sts
        WHERE  id = l_chr_id;
    --And    sts.code = chr.sts_code;


    l_org_id          NUMBER;
    l_organization_id NUMBER;
    l_inv_id          NUMBER;
    l_stat            VARCHAR2(100);
    l_end_date        DATE;
    l_status          NUMBER;
    l_sts_code        VARCHAR2(200);

    BEGIN

        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- Get Contract Lines

        OPEN l_org_csr;
        FETCH l_org_csr INTO l_org_id, l_organization_id;
        CLOSE l_org_csr;


        OPEN  l_cle_csr;
        LOOP
            FETCH l_cle_csr INTO l_cle_rec;
            EXIT WHEN l_cle_csr%NOTFOUND;

            IF (l_cle_rec.date_terminated IS NULL )
                AND (l_cle_rec.sts_code = 'ENTERED') THEN

                OPEN l_status_csr(l_cle_rec.object1_id1, l_organization_id);
                FETCH l_status_csr INTO l_status;
                CLOSE l_status_csr;

                IF l_status IS NULL THEN
                    /**
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_REQUIRED_LINE_VALUE,
                                        p_token1 => G_COL_NAME_TOKEN,
                                        p_token1_value => 'Inventory item status not active',
                                        p_token2 => 'LINE_NAME',
                                        p_token2_value => get_line_name(l_cle_rec.id));
                    **/

                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_INACTIVE_INVENTORY_ITEM,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(l_cle_rec.id));

                    -- notify caller of an error
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                END IF; -- if l_status is NULL
            END IF; -- if (l_cle_rec.date_terminated is null )AND (l_cle_rec.sts_code = 'ENTERED')

            IF l_cle_rec.sts_code = 'ENTERED' AND l_cle_rec.date_terminated IS NULL
                THEN
                OPEN l_chk_service_prod_csr(l_cle_rec.object1_id1, l_organization_id);
                FETCH l_chk_service_prod_csr INTO l_chk_service_prod_rec;

                --for service and extended warranty
                IF (l_cle_rec.lse_id IN (1, 19)
                    AND (l_chk_service_prod_rec.service_item_flag = 'N' OR  l_chk_service_prod_rec.vendor_warranty_flag = 'Y'
                         OR  (l_chk_service_prod_rec.customer_order_enabled_flag = 'N' AND l_chk_service_prod_rec.internal_order_enabled_flag = 'N')
                         OR  l_chk_service_prod_rec.invoice_enabled_flag = 'N'))
                    THEN

                    OKC_API.SET_MESSAGE
                    (
                     p_app_name => G_APP_NAME,
                     p_msg_name => 'OKS_INVALID_SERVICE_ITEM',
                     p_token1 => 'ITEM',
                     p_token1_value => get_line_name(l_cle_rec.id)
                     );
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                END IF; --l_chk_service_prod_rec.service_item_flag = 'Y' and  l_chk_service_prod_rec.vendor_warranty_flag = 'N'

                --for USAGE

                IF (l_cle_rec.lse_id = 12 AND (l_chk_service_prod_rec.usage_item_flag = 'N'
                                               OR  (l_chk_service_prod_rec.customer_order_enabled_flag = 'N' AND l_chk_service_prod_rec.internal_order_enabled_flag = 'N')
                                               OR  l_chk_service_prod_rec.invoice_enabled_flag = 'N'))
                    THEN

                    OKC_API.SET_MESSAGE
                    (
                     p_app_name => G_APP_NAME,
                     p_msg_name => 'OKS_INVALID_USAGE_ITEM',
                     p_token1 => 'ITEM',
                     p_token1_value => get_line_name(l_cle_rec.id)
                     );
                    x_return_status := OKC_API.G_RET_STS_ERROR;

                END IF; --l_chk_service_prod_rec.usage_item_flag = 'Y'

                CLOSE l_chk_service_prod_csr;

            END IF; --IF l_cle_rec.sts_code = 'ENTERED'

            -- Get Covered Levels for Contract Line
            OPEN l_cve_csr (l_cle_rec.id);
            LOOP
                FETCH l_cve_csr INTO l_cve_rec;
                EXIT WHEN l_cve_csr%NOTFOUND;

                IF (l_cve_rec.date_terminated IS NULL )
                    AND (l_cve_rec.sts_code = 'ENTERED') THEN

                    OPEN l_get_inv_item_csr(l_cve_rec.object1_id1);
                    FETCH l_get_inv_item_csr INTO l_get_inv_item_rec;

                    OPEN l_chk_service_prod_csr(l_get_inv_item_rec.inventory_item_id, l_organization_id);
                    FETCH l_chk_service_prod_csr INTO l_chk_service_prod_rec;

                    --for product
                    IF (l_chk_service_prod_rec.serviceable_product_flag = 'N' AND  l_cve_rec.lse_id IN (9, 25))
                        THEN

                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_PRODUCT_INACTIVE',
                         p_token1 => 'ITEM',
                         p_token1_value => get_line_name(l_cve_rec.id)
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;


                    END IF; -- IF (l_chk_service_prod_rec.service_item_flag = 'Y'
                    CLOSE l_chk_service_prod_csr;
                    CLOSE l_get_inv_item_csr;


                    IF l_cve_rec.lse_id = 7  THEN
 			l_stat :='X';	--Bug 5583158

                        OPEN  l_covitm_csr(l_cve_rec.object1_id1, l_organization_id);
                        FETCH l_covitm_csr INTO l_stat;
                        CLOSE l_covitm_csr;

                        IF nvl(l_stat, 'X') <> 'A' THEN		--Bug 5583158
                            /**
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_REQUIRED_LINE_VALUE,
                                                p_token1 => G_COL_NAME_TOKEN,
                                                p_token1_value => 'Covered item status not active',
                                                p_token2 => 'LINE_NAME',
                                                p_token2_value => get_line_name(l_cve_rec.id));
                            **/

                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_INACTIVE_COVERED_ITEM,
                                                p_token1 => 'LINE_NAME',
                                                p_token1_value => get_line_name(l_cve_rec.id));

                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF; -- If l_stat <> 'A' Then
                    END IF; -- If l_cve_rec.lse_id = 7  Then

                    IF l_cve_rec.lse_id = 8  THEN
 			l_stat :='X';	--Bug 5583158
                        OPEN  l_covparty_csr(l_cve_rec.object1_id1);
                        FETCH l_covparty_csr INTO l_stat;
                        CLOSE l_covparty_csr;
                        IF nvl(l_stat, 'X') <> 'A' THEN --Bug 5583158
                            /**
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_REQUIRED_LINE_VALUE,
                                                p_token1 => G_COL_NAME_TOKEN,
                                                p_token1_value => 'Covered Party status not active',
                                                p_token2 => 'LINE_NAME',
                                                p_token2_value => get_line_name(l_cve_rec.id));
                            **/

                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_INACTIVE_COVERED_PARTY,
                                                p_token1 => 'LINE_NAME',
                                                p_token1_value => get_line_name(l_cve_rec.id));

                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF;
                    END IF;

                    IF l_cve_rec.lse_id IN (9, 25)  THEN
 			l_stat :='X';	--Bug 5583158
                        OPEN  l_covprod_csr(l_cve_rec.object1_id1, l_organization_id);
                        FETCH l_covprod_csr INTO l_stat, l_end_date;
                        CLOSE l_covprod_csr;

                        OPEN  l_hdr_csr(p_chr_id);
                        FETCH l_hdr_csr INTO l_sts_code;
                        CLOSE l_hdr_csr;


                        IF nvl(l_sts_code, 'X') <> 'QA_HOLD' THEN
                            IF nvl(l_stat, 'X') <> 'Y' THEN 	--Bug 5583158
                                /**
                                OKC_API.set_message(
                                                    p_app_name => G_APP_NAME,
                                                    p_msg_name => G_REQUIRED_LINE_VALUE,
                                                    p_token1 => G_COL_NAME_TOKEN,
                                                    p_token1_value => 'Covered Product status not active',
                                                    p_token2 => 'LINE_NAME',
                                                    p_token2_value => get_line_name(l_cve_rec.id));
                                **/

                                OKC_API.set_message(
                                                    p_app_name => G_APP_NAME,
                                                    p_msg_name => G_INACTIVE_COVERED_PRODUCT,
                                                    p_token1 => 'LINE_NAME',
                                                    p_token1_value => get_line_name(l_cve_rec.id));

                                -- notify caller of an error
                                x_return_status := OKC_API.G_RET_STS_ERROR;
                            END IF;
                        ELSE
                            IF nvl(l_stat, 'X') <> 'Y' AND  	--Bug5583158
                                nvl(l_cve_rec.date_terminated, l_cve_rec.end_date) > nvl(l_end_date, SYSDATE) THEN
                                /**
                                OKC_API.set_message(
                                                    p_app_name => G_APP_NAME,
                                                    p_msg_name => G_REQUIRED_LINE_VALUE,
                                                    p_token1 => G_COL_NAME_TOKEN,
                                                    p_token1_value => 'Covered Product status not active',
                                                    p_token2 => 'LINE_NAME',
                                                    p_token2_value => get_line_name(l_cve_rec.id));
                                **/

                                OKC_API.set_message(
                                                    p_app_name => G_APP_NAME,
                                                    p_msg_name => G_INACTIVE_COVERED_PRODUCT,
                                                    p_token1 => 'LINE_NAME',
                                                    p_token1_value => get_line_name(l_cve_rec.id));

                                -- notify caller of an error
                                x_return_status := OKC_API.G_RET_STS_ERROR;
                            END IF;
                        END IF;
                    END IF;

		--Bug 5583158
                    IF l_cve_rec.lse_id = 11 THEN
 			l_stat :='X';

                        OPEN  l_covsys_csr(l_cve_rec.object1_id1);
                        FETCH l_covsys_csr INTO l_stat;
                        CLOSE l_covsys_csr;
                        IF nvl(l_stat, 'X') <> 'A' THEN
                            /**
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_REQUIRED_LINE_VALUE,
                                                p_token1 => G_COL_NAME_TOKEN,
                                                p_token1_value => 'Covered System status not active',
                                                p_token2 => 'LINE_NAME',
                                                p_token2_value => get_line_name(l_cve_rec.id));
                            **/

                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_INACTIVE_COVERED_SYSTEM,
                                                p_token1 => 'LINE_NAME',
                                                p_token1_value => get_line_name(l_cve_rec.id));

                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF;
                    END IF;

		--Bug 5583158

                    IF l_cve_rec.lse_id = 10 THEN
 			l_stat :='X';	 		--Bug 5583158
                        OPEN  l_covsit_csr(l_cve_rec.object1_id1);
                        FETCH l_covsit_csr INTO l_stat;
                        CLOSE l_covsit_csr;
                        IF nvl(l_stat, 'X') <> 'A' THEN		--Bug 5583158
                            /**
                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_REQUIRED_LINE_VALUE,
                                                p_token1 => G_COL_NAME_TOKEN,
                                                p_token1_value => 'Covered Site status not active',
                                                p_token2 => 'LINE_NAME',
                                                p_token2_value => get_line_name(l_cle_rec.id));
                            **/

                            OKC_API.set_message(
                                                p_app_name => G_APP_NAME,
                                                p_msg_name => G_INACTIVE_COVERED_SITE,
                                                p_token1 => 'LINE_NAME',
                                                p_token1_value => get_line_name(l_cle_rec.id));

                            -- notify caller of an error
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;
                    END IF;
                END IF;
            END LOOP;

            CLOSE l_cve_csr;

        END LOOP;
        CLOSE l_cle_csr;
        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF l_cve_csr%ISOPEN THEN
                CLOSE l_cve_csr;
            END IF;

            IF l_cle_csr%ISOPEN THEN
                CLOSE l_cle_csr;
            END IF;

    END ;

    /*============================================================================+
    | Procedure:           Get_Pay_Method_Info
    |
    | Purpose:             Returns Payment Method Details for a given Receipt
    |                      Method Id
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Get_Pay_Method_Info
    (p_pay_method_id   IN   NUMBER
     , p_pay_method_name OUT  NOCOPY VARCHAR2
     , p_merchant_ref     OUT  NOCOPY NUMBER
     )
    IS

    CURSOR receipt_csr (pay_id NUMBER) IS
        SELECT
          name, nvl(merchant_ref, 0)
        FROM  AR_RECEIPT_METHODS
        WHERE RECEIPT_METHOD_ID = pay_id
        AND   SYSDATE >= NVL(START_DATE, SYSDATE)
        AND   SYSDATE <= NVL(END_DATE, SYSDATE)
        AND   PAYMENT_TYPE_CODE = 'CREDIT_CARD';

    BEGIN

        --errorout('In Get Pay Method Info');

        OPEN  receipt_csr(p_pay_method_id);
        FETCH receipt_csr INTO p_pay_method_name, p_merchant_ref;
        CLOSE receipt_csr;

        --errorout('Get Pay Method Info Merchant Id '||p_merchant_id);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;

    END Get_Pay_Method_Info;


    /*============================================================================+
    | Procedure:           Check_Authorize_Payment
    |
    | Purpose:             1. Check profile option for authorization. Skip the
    |                         process if no authorization is required.
    |                      2. Exit validation with success if CCR rule
    |                         (credit card rule) doesn't exist or authoring code
    |                         is not null.
    |                      3. Make a call to iPayment API for authorization using
    |                      4. Update OKS header with payment information.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_Authorize_Payment
    (x_return_status  OUT NOCOPY VARCHAR2,
     p_chr_id         IN  NUMBER
     )

    IS

    l_api_name           CONSTANT VARCHAR2(30) := 'Check_Authorize_Payment';
    l_trxn_extension_id  NUMBER;
    l_order_value        NUMBER;
    l_authorize_payment  VARCHAR2(30);

    x_msg_data           VARCHAR2(1995);
    x_msg_count          NUMBER;

    l_payment_type       VARCHAR2(30);


    l_payee_rec          IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
    l_payer_rec          IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
    l_auth_attribs       IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
    l_amount             IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
    l_auth_result        IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
    l_response           IBY_FNDCPT_COMMON_PUB.Result_rec_type;



    G_SUCCESS_HALT_VALIDATION EXCEPTION;
    G_ERROR_HALT_VALIDATION   EXCEPTION;

    CURSOR oks_hdr_csr (p_chr_id NUMBER) IS
        SELECT s.id,
               s.object_version_number,
               s.trxn_extension_id,
               s.payment_type,
               NVL(c.org_id, c.authoring_org_id) org_id,
               c.currency_code,
               c.bill_to_site_use_id
        FROM oks_k_headers_b s,
             okc_k_headers_all_b c
        WHERE s.chr_id = c.id
        AND   c.id = p_chr_id;

    l_oks_header_rec oks_hdr_csr%ROWTYPE;

    CURSOR oks_lines_csr(p_chr_id NUMBER) IS
        SELECT oks.id,
               oks.object_version_number,
               oks.trxn_extension_id,
               oks.payment_type,
               okc.bill_to_site_use_id
        FROM oks_k_lines_b oks,
             okc_k_lines_b okc
        WHERE oks.dnz_chr_id = p_chr_id
        AND   oks.cle_id = okc.id
        AND   okc.date_cancelled IS NULL --4735326
        AND   oks.trxn_extension_id IS NOT NULL; --process only lines with credit cards

    l_oks_lines_rec oks_lines_csr%ROWTYPE;

    CURSOR cust_account_csr(p_site_use_id VARCHAR2, p_site_use_code VARCHAR2) IS
        SELECT accts.party_id,
               sites.cust_account_id
        FROM hz_cust_site_uses_all site_uses,
             hz_cust_acct_sites_all sites,
             hz_cust_accounts accts
        WHERE site_uses.site_use_id = p_site_use_id
        AND   site_uses.site_use_code = p_site_use_code
        AND   site_uses.cust_acct_site_id = sites.cust_acct_site_id
        AND   sites.cust_account_id = accts.cust_account_id;

    cust_account_rec     cust_account_csr%ROWTYPE;


    PROCEDURE create_header_authorization IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization does not exist so creating new one.');
        END IF;

        IBY_FNDCPT_TRXN_PUB.Create_Authorization
        (p_api_version => 1.0
         , p_payee => l_payee_rec
         , p_payer => l_payer_rec
         , p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL -- we need full instead of default G_PAYER_EQUIV_UPWARD (bug 5163778)
         , p_trxn_entity_id => l_oks_header_rec.trxn_extension_id
         , p_auth_attribs => l_auth_attribs
         , p_amount => l_amount
         , x_auth_result => l_auth_result
         , x_response => l_response
         , x_return_status => x_return_status
         , x_msg_count => x_msg_count
         , x_msg_data => x_msg_data
         );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished checking header. x_return_status: '|| x_return_status);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| x_msg_data);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_auth_result.auth_code: '|| l_auth_result.auth_code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_auth_result.auth_id: '|| l_auth_result.auth_id);
        END IF;

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            --show IBY error message on standard FND stack in QA results UI
            x_return_status := OKC_API.G_RET_STS_ERROR;


            --also pick up IBY message in l_response and place onto standard FND message stack
            IF NVL(l_response.Result_Category,'x') <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'
               FND_MSG_PUB.add_exc_msg(
                    p_pkg_name		=> 'IBY_FNDCPT_TRXN_PUB',
                    p_procedure_name	=> 'Create_Authorization',
                    p_error_text	=> SUBSTR(l_response.Result_Message ||' ('||l_response.Result_Code  ||')',1,240));
            END IF;

            RAISE G_ERROR_HALT_VALIDATION;
        END IF;

        --delete the 'AUTH_SUCCESS' message put on stack by IBY
        FND_MSG_PUB.delete_msg(x_msg_count);

        --put success message to display in QA result list for header
        OKC_API.set_message(
                            p_app_name => G_APP_NAME,
                            p_msg_name => 'OKS_QA_SUCCESS');

        COMMIT; --the authorization is always committed by IBY regardless so this commit is necessary to retain the record
        --IBY keeps to link an authorization created with the transaction_extension_id
        --since this is an autonomous transaction, the rest of the contract is unaffected by the commit here
        --ref: bug 4951669

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization successfully created for header');
        END IF;

    END create_header_authorization;



    PROCEDURE create_line_authorization IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN


        IBY_FNDCPT_TRXN_PUB.Create_Authorization
        (p_api_version => 1.0
         , p_payee => l_payee_rec
         , p_payer => l_payer_rec
         , p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_FULL -- we need full instead of default G_PAYER_EQUIV_UPWARD (bug 5163778)
         , p_trxn_entity_id => l_oks_lines_rec.trxn_extension_id
         , p_auth_attribs => l_auth_attribs
         , p_amount => l_amount
         , x_auth_result => l_auth_result
         , x_response => l_response
         , x_return_status => x_return_status
         , x_msg_count => x_msg_count
         , x_msg_data => x_msg_data
         );

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished checking line id: '|| l_oks_lines_rec.id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_return_status: '|| x_return_status);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| x_msg_data);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| x_msg_count);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
        END IF;

        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            -- show IBY error message on standard FND stack in QA results UI
            x_return_status := OKC_API.G_RET_STS_ERROR;


            --also pick up IBY message in l_response and place onto standard FND message stack
            IF NVL(l_response.Result_Category,'x') <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'
               FND_MSG_PUB.add_exc_msg(
                    p_pkg_name          => 'IBY_FNDCPT_TRXN_PUB',
                    p_procedure_name    => 'Create_Authorization',
                    p_error_text	=> SUBSTR(l_response.Result_Message ||' ('||l_response.Result_Code  ||')',1,240));
            END IF;

            RAISE G_ERROR_HALT_VALIDATION;
        END IF;

        --delete the 'AUTH_SUCCESS' message put on stack by IBY
        FND_MSG_PUB.delete_msg(x_msg_count);

        --put success message to display in QA result list for line
        OKC_API.set_message(
                            p_app_name => G_APP_NAME,
                            p_msg_name => 'OKS_QA_SUCCESS');


        COMMIT; --the authorization is always committed by IBY regardless so this commit is necessary to retain the record
        --IBY keeps to link an authorization created with the transaction_extension_id
        --since this is an autonomous transaction, the rest of the contract is unaffected by the commit here
        --ref: bug 4951669

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization successfully created for line');
        END IF;

    END create_line_authorization;




    BEGIN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Entering '|| G_PKG_NAME || '.' || l_api_name);
        END IF;

        x_return_status := OKC_API.G_RET_STS_SUCCESS;



        -- If OKS: Credit Card Validation Level profile does not hold value 'Authorize Payment', skip check
        l_authorize_payment := nvl(fnd_profile.VALUE('OKS_CREDIT_PROCESSING_QA_LEVEL'), '0');

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_authorize_payment: '|| l_authorize_payment);
        END IF;

        IF G_AUTHORIZE_PAYMENT <> l_authorize_payment THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Profile is turned off, no need to perform any check');
            END IF;

            -- skip the process, No Authorization required
            x_return_status := OKC_API.G_RET_STS_SUCCESS;
            RAISE G_SUCCESS_HALT_VALIDATION;
        END IF;


        -- Bug 5106500 --
        -- Get amount to be authorized
        l_order_value := TO_NUMBER(NVL(fnd_profile.VALUE('OKS_CREDIT_AUTHORIZE_MINIMUM_AMOUNT'), fnd_number.canonical_to_number('0.01'))); --(absolute zero not permitted by iPayment)
        -- Bug 5106500 --
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_order_value: '|| to_char(l_order_value));
        END IF;


        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Start checking header.');
        END IF;

        -- First check header
        OPEN oks_hdr_csr(p_chr_id);
        FETCH oks_hdr_csr INTO l_oks_header_rec;
        CLOSE oks_hdr_csr;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.id: '|| l_oks_header_rec.id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.object_version_number: '|| l_oks_header_rec.object_version_number);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.trxn_extension_id: '|| l_oks_header_rec.trxn_extension_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.payment_type: '|| l_oks_header_rec.payment_type);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.org_id: '|| l_oks_header_rec.org_id);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.currency_code: '|| l_oks_header_rec.currency_code);
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_header_rec.bill_to_site_use_id: '|| l_oks_header_rec.bill_to_site_use_id);
        END IF;

        --conduct check only if credit card exists
        IF l_oks_header_rec.trxn_extension_id IS NOT NULL AND 'CCR' = nvl(l_oks_header_rec.payment_type, '0') THEN

            l_amount.currency_code := l_oks_header_rec.currency_code;
            l_amount.VALUE := l_order_value;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_amount.currency_code: '|| l_amount.currency_code);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_amount.value: '|| l_amount.VALUE);
            END IF;

            /**** Setup PayEE Record ****/
            --Payee is optional
            --adding payee information
            l_payee_rec.org_type := 'OPERATING_UNIT';
            l_payee_rec.org_id := l_oks_header_rec.org_id;


            /**** Setup PayER Record ****/
            OPEN cust_account_csr(l_oks_header_rec.bill_to_site_use_id, 'BILL_TO');
            FETCH cust_account_csr INTO cust_account_rec;
            CLOSE cust_account_csr;


            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payee_rec.org_id: '|| l_payee_rec.org_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'cust_account_rec.party_id: '|| cust_account_rec.party_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'cust_account_rec.cust_account_id: '|| cust_account_rec.cust_account_id);
            END IF;

            --org_type and org_id are optional
            l_payer_rec.payment_function := 'CUSTOMER_PAYMENT';
            l_payer_rec.party_id := cust_account_rec.party_id;
            l_payer_rec.cust_account_id := cust_account_rec.cust_account_id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Checking to see if authorization already exists');
            END IF;

            --first determine whether there is a pre-existing credit card authorization for the payer
            IBY_FNDCPT_TRXN_PUB.Get_Authorization
            (p_api_version => 1.0
             , p_payer => l_payer_rec
             , p_trxn_entity_id => l_oks_header_rec.trxn_extension_id
             , x_auth_result => l_auth_result
             , x_response => l_response
             , x_return_status => x_return_status
             , x_msg_count => x_msg_count
             , x_msg_data => x_msg_data
             );

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished checking for existing authorization. x_return_status: '|| x_return_status);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| x_msg_data);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| x_msg_count);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_auth_result.auth_id: '|| l_auth_result.auth_id);
            END IF;

            IF x_return_status = OKC_API.G_RET_STS_SUCCESS AND l_response.Result_Code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN
                --authorization already exists

                --delete the 'SUCCESS' message put on stack by IBY
                FND_MSG_PUB.delete_msg(x_msg_count);

                --put success message to display in QA result list for header
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization already exists so returning success for header');
                END IF;

                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => 'OKS_QA_SUCCESS');


            ELSIF NVL(l_response.Result_Code,'x') IN ('INVALID_AUTHORIZATION', 'INVALID_TXN_EXTENSION') THEN
                -- this covers case of x_return_status = 'E' and l_response.Result_Code = 'INVALID_AUTHORIZATION' or 'INVALID_TXN_EXTENSION'
                -- which means that authorization does not exist and we need to create one
                -- authorization does not already exist so go ahead and create a new one

                --delete the 'INVALID_AUTHORIZATION' or 'INVALID_TXN_EXTENSION' message put on stack by IBY
                FND_MSG_PUB.delete_msg(x_msg_count);

                create_header_authorization;

            ELSIF NVL(l_response.Result_Category,'x') <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'
                x_return_status := OKC_API.G_RET_STS_ERROR; --show IBY error message (should be in stack) in QA results UI

                --also pick up IBY message in l_response and place onto standard FND message stack
                IF l_response.Result_Category <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'
                   FND_MSG_PUB.add_exc_msg(
                    p_pkg_name          => 'IBY_FNDCPT_TRXN_PUB',
                    p_procedure_name    => 'Get_Authorization',
                    p_error_text	=> SUBSTR(l_response.Result_Message ||' ('||l_response.Result_Code  ||')',1,240));
                END IF;

                RAISE G_ERROR_HALT_VALIDATION;

            END IF;




            --Go on to update_Authorization Info of the header
            --we directly update instead of using public API to avoid locking issues
            --auth code could come from either IBY_FNDCPT_TRXN_PUB.Get_Authorization or IBY_FNDCPT_TRXN_PUB.Create_Authorization
            UPDATE oks_k_headers_b
            SET cc_auth_code = l_auth_result.auth_code
            WHERE id = l_oks_header_rec.id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished updating header');
            END IF;


        END IF; --END IF l_trxn_extension_id IS NOT NULL




        --now begin processing contract lines
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Start checking lines.');
        END IF;

        --check each line (associated with a credit card)
        OPEN oks_lines_csr(p_chr_id);
        LOOP
            FETCH oks_lines_csr INTO l_oks_lines_rec;
            EXIT WHEN oks_lines_csr%NOTFOUND;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_lines_rec.id: '|| l_oks_lines_rec.id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_lines_rec.object_version_number: '|| l_oks_lines_rec.object_version_number);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_lines_rec.trxn_extension_id: '|| l_oks_lines_rec.trxn_extension_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_lines_rec.payment_type: '|| l_oks_lines_rec.payment_type);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_oks_lines_rec.bill_to_site_use_id: '|| l_oks_lines_rec.bill_to_site_use_id);
            END IF;

            --we use the currency_code from the header always
            l_amount.currency_code := l_oks_header_rec.currency_code;
            l_amount.VALUE := l_order_value;

            /**** Setup PayEE Record ****/
            --Payee is optional
            l_payee_rec.org_type := 'OPERATING_UNIT';
            l_payee_rec.org_id := l_oks_header_rec.org_id;

            /**** Setup PayER Record ****/
            cust_account_rec.party_id := NULL;
            cust_account_rec.cust_account_id := NULL;

            OPEN cust_account_csr(l_oks_lines_rec.bill_to_site_use_id, 'BILL_TO');
            FETCH cust_account_csr INTO cust_account_rec;
            CLOSE cust_account_csr;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_payee_rec.org_id: '|| l_payee_rec.org_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'cust_account_rec.party_id: '|| cust_account_rec.party_id);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'cust_account_rec.cust_account_id: '|| cust_account_rec.cust_account_id);
            END IF;

            --org_type and org_id are optional
            l_payer_rec.payment_function := 'CUSTOMER_PAYMENT';
            l_payer_rec.party_id := cust_account_rec.party_id;
            l_payer_rec.cust_account_id := cust_account_rec.cust_account_id;

            --first determine whether there is a pre-existing credit card authorization for the payer
            IBY_FNDCPT_TRXN_PUB.Get_Authorization
            (p_api_version => 1.0
             , p_payer => l_payer_rec
             , p_trxn_entity_id => l_oks_lines_rec.trxn_extension_id
             , x_auth_result => l_auth_result
             , x_response => l_response
             , x_return_status => x_return_status
             , x_msg_count => x_msg_count
             , x_msg_data => x_msg_data
             );

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished checking for existing authorization. x_return_status: '|| x_return_status);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_data: '|| x_msg_data);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'x_msg_count: '|| x_msg_count);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'result_code: '|| l_response.Result_Code);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Category: '|| l_response.Result_Category);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Result_Message: '|| l_response.Result_Message);
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_auth_result.auth_id: '|| l_auth_result.auth_id);
            END IF;

            IF x_return_status = OKC_API.G_RET_STS_SUCCESS AND l_response.Result_Code = IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN
                --authorization already exists

                --delete the 'SUCCESS' message put on stack by IBY
                FND_MSG_PUB.delete_msg(x_msg_count);

                --put success message to display in QA result list for line currently being processed
                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization already exists so returning success for line');
                END IF;

                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => 'OKS_QA_SUCCESS');


            ELSIF NVL(l_response.Result_Code,'x') IN ('INVALID_AUTHORIZATION', 'INVALID_TXN_EXTENSION') THEN
                -- this covers case of x_return_status = 'E' and l_response.Result_Code = 'INVALID_AUTHORIZATION' or 'INVALID_TXN_EXTENSION'
                -- which means that authorization does not exist and we need to create one
                -- authorization does not already exist so go ahead and create a new one

                --delete the 'INVALID_AUTHORIZATION' or 'INVALID_TXN_EXTENSION' message put on stack by IBY
                FND_MSG_PUB.delete_msg(x_msg_count);

                IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Authorization does not exist so creating new one.');
                END IF;

                create_line_authorization;


            ELSIF NVL(l_response.Result_Category,'x') <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'

                --show IBY error message (should be in stack) in QA results UI
                x_return_status := OKC_API.G_RET_STS_ERROR;

                --also pick up IBY message in l_response and place onto standard FND message stack
                IF l_response.Result_Category <> IBY_FNDCPT_COMMON_PUB.G_RC_SUCCESS THEN  --'SUCCESS'
                   FND_MSG_PUB.add_exc_msg(
                    p_pkg_name          => 'IBY_FNDCPT_TRXN_PUB',
                    p_procedure_name    => 'Get_Authorization',
                    p_error_text	=> SUBSTR(l_response.Result_Message ||' ('||l_response.Result_Code  ||')',1,240));
                END IF;


                RAISE G_ERROR_HALT_VALIDATION;


            END IF;

            --Go on to update_Authorization Info of line
            --we directly update instead of using public API to avoid locking issues
            --auth code could come from either IBY_FNDCPT_TRXN_PUB.Get_Authorization or IBY_FNDCPT_TRXN_PUB.Create_Authorization
            UPDATE oks_k_lines_b
            SET cc_auth_code = l_auth_result.auth_code
            WHERE id = l_oks_lines_rec.id;

            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'Finished updating line');
            END IF;

        END LOOP;
        CLOSE oks_lines_csr;


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name,'Leaving '|| G_PKG_NAME || '.' || l_api_name);
        END IF;

    EXCEPTION
        WHEN  G_SUCCESS_HALT_VALIDATION  THEN

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF oks_lines_csr%ISOPEN THEN
                CLOSE oks_lines_csr;
            END IF;

            IF cust_account_csr%ISOPEN THEN
                CLOSE cust_account_csr;
            END IF;

            x_return_status := x_return_status;
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');

        WHEN  G_ERROR_HALT_VALIDATION THEN

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF oks_lines_csr%ISOPEN THEN
                CLOSE oks_lines_csr;
            END IF;

            IF cust_account_csr%ISOPEN THEN
                CLOSE cust_account_csr;
            END IF;

            x_return_status := x_return_status;
            -- we rely on IBY or OKS API to put error message on stack and just return error here

        WHEN  OTHERS THEN

            IF oks_hdr_csr%ISOPEN THEN
                CLOSE oks_hdr_csr;
            END IF;

            IF oks_lines_csr%ISOPEN THEN
                CLOSE oks_lines_csr;
            END IF;

            IF cust_account_csr%ISOPEN THEN
                CLOSE cust_account_csr;
            END IF;

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR, G_SQLCODE_TOKEN, SQLCODE, G_SQLERRM_TOKEN,'Check_Authorize_Payment:- '|| SQLERRM);

    END Check_Authorize_Payment;



    /*============================================================================+
    | Procedure:           check_billing_schedule
    |
    | Purpose:  1. Top line Stream Level Line (SLL) should be entered.
    |           2. For subscription lines billed amount should not be greater
    |              than the negotiated price on the subscription line.
    |           3. Subscription lines with "Equal Amount" billing type should have
    |              negotiated price equal to sum of level elements.
    |           4. Top line billing schedule (level elements) should be entered.
    |           5. Top line SLL affectivities should be within line affectivities.
    |              In general, SLL end date should not be less than top line
    |              end date. For "covered level" and "equal amount" the SLL end
    |              date should not be greater than top line end date.
    |              Top line SLL start date should be same as top line start
    |              date.
    |           6. Sub line billing type should be the same as top line billing
    |              type.
    |           7. For "Equal Amount" billing type the start date and end date of
    |              sub lines should be the same as their top lines.
    |           8. Sub line Stream Level Line (SLL) should be entered.
    |           9. Sub line billing schedule should be entered.
    |           10. Sub line start date should be same as SLL start date if billing
    |              level is covered level.
    |           11. For sub lines, billed amount should not be greater than sub
    |               line negotiated price.
    |           12. Sub line SLL period should be the same as the number of
    |               level elements (billing schedule period).
    |           13. Sub line final price should be same as total billing schedule
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_billing_schedule
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     )
    IS
    l_SLL_start_date		   DATE;
    l_SLL_end_date		   DATE;
    l_ETP_flag		   VARCHAR2(450) := ' ';
    l_rules_ctr		   NUMBER := 0;
    l_sub_line_SLL		   NUMBER := 0;
    l_top_line_SLL		   NUMBER := 0;
    l_bs_rec		   NUMBER := 0;
    l_lvl_total_amt		   NUMBER := 0;
    l_lvl_total_billed_amt	   NUMBER := 0;
    --l_lvl_element_count      NUMBER := 0;
    l_temp_total_billed      NUMBER;
    l_price_negotiated      NUMBER;


    TYPE Level_Element_Rec  IS RECORD
    (
     date_start       DATE,
     date_transaction DATE,
     date_to_interface   DATE,
     date_completed   DATE
     );

    --Type Level_Element_Tbl is TABLE of Level_Element_Rec index by binary_integer;

    --l_lvl_tbl    Level_Element_Tbl;

    CURSOR get_currency_csr (p_chr_id NUMBER) IS
        SELECT k_hdr.currency_code
        FROM   okc_k_headers_all_b k_hdr
        WHERE  k_hdr.id = p_chr_id ;

    l_currency       VARCHAR2(15);


    /* original cursor commented out for bug 4947610
    --Top Lines information
    --No billing schedule QA checks for terminated lines.
    CURSOR top_line_grp_csr (p_hdr_id NUMBER) IS
        SELECT 	lines.id, lines.lse_id lse_id, lines.cle_id,
         lines.start_date, lines.end_date, lines.line_number, date_terminated,
         lines.price_negotiated
        FROM 	okc_k_lines_b lines
        WHERE lines.dnz_chr_id = p_hdr_id
        AND	lines.cle_id IS NULL
        AND	lines.lse_id IN (1, 12, 19, 46)
        AND lines.date_terminated IS NULL -- added by mkhayer 11/21/2002.
        AND lines.date_cancelled IS NULL --Changes [llc]
        ORDER BY lines.id;
    */

    --modified cursor, bug 4947610
    CURSOR top_line_grp_csr (p_hdr_id NUMBER) IS
        SELECT 	lines.id, lines.lse_id lse_id, lines.cle_id,
        lines.start_date, lines.end_date, lines.line_number, date_terminated,
        lines.price_negotiated, oks.credit_amount, oks.suppressed_credit, oks.override_amount
        FROM 	okc_k_lines_b lines , oks_k_lines_b oks
        WHERE lines.dnz_chr_id = p_hdr_id
        AND	lines.cle_id IS NULL
        AND	lines.lse_id IN (1, 12, 19, 46)
        AND lines.date_terminated IS NULL -- added by mkhayer 11/21/2002.
        AND lines.date_cancelled IS NULL --Changes [llc]
        AND oks.cle_id = lines.id
        ORDER BY lines.id;

    -- Sub Line information
    CURSOR line_grp_csr (p_hdr_id NUMBER, p_cle_id NUMBER) IS
        SELECT 	lines.id, lines.lse_id lse_id, lines.cle_id,
          lines.start_date, lines.end_date, lines.price_negotiated, lines.line_number, date_terminated
        FROM 	okc_k_lines_b lines
        WHERE lines.dnz_chr_id = p_hdr_id
        AND	lines.cle_id = p_cle_id
        AND	lines.lse_id IN (7, 8, 9, 10, 11, 13, 18, 25, 35)
        AND      lines.date_terminated IS NULL -- uncommented by mkhayer
        AND lines.date_cancelled IS NULL; --Changes [llc]



    -- SLL rule
    CURSOR rules_csr (p_hdr_id NUMBER, p_cle_id NUMBER) IS
        SELECT	id,
         uom_code,
         SEQUENCE_NO,
         start_date,
         level_periods,
         uom_per_period,
         advance_periods,
         level_amount --rule_information6
        FROM	oks_stream_levels_b --okc_rules_b
        WHERE	dnz_chr_id = p_hdr_id
        AND cle_id = p_cle_id;


    --Level element information - to check dates

    CURSOR level_elements_csr (p_id NUMBER) IS
        SELECT	date_start, date_transaction, date_to_interface,
         amount, date_completed
        FROM	oks_level_elements
        WHERE	rul_id = p_id -- is the id in  oks_level_elements
        AND	date_completed IS NULL
        ORDER BY date_start; -- Added for bug# 2517147

    --Level element information - to check amount and periods

    CURSOR level_elements_amt_csr (p_id NUMBER) IS
        SELECT	COUNT(rul_id) lvl_count, SUM(amount) lvl_amt
        FROM	oks_level_elements
        WHERE	rul_id = p_id -- is the id in  oks_level_elements
        GROUP BY rul_id;

    --get rle information E/T/P of top line
    -- SLH rule
    CURSOR get_ETP_csr (p_hdr_id NUMBER, p_cle_id NUMBER) IS
        SELECT BILLING_SCHEDULE_TYPE --rule_information1
        FROM	oks_k_lines_b --okc_rules_b
        WHERE	dnz_chr_id = p_hdr_id
        AND cle_id = p_cle_id;

    CURSOR level_elements_billed_csr (p_id NUMBER) IS
        SELECT	SUM(amount) billed_amt
        FROM	oks_level_elements
        WHERE	rul_id = p_id
        AND	date_completed IS NOT NULL;

    CURSOR get_line_price(l_line_id NUMBER) IS
        SELECT price_negotiated
        FROM okc_k_lines_b
        WHERE  id = l_line_id
        AND lse_id IN  (7, 8, 9, 10, 11, 18, 25, 35, 46);


    CURSOR get_billed_amount(l_sub_line_id NUMBER) IS
        SELECT SUM(amount)
        FROM oks_bill_sub_lines
        WHERE cle_id = l_sub_line_id
        AND bcl_id IN (SELECT id
                       FROM oks_bill_cont_lines
                       WHERE  bill_action = 'RI');

    CURSOR get_top_billed_amount(l_line_id NUMBER) IS
        SELECT SUM(amount)
        FROM oks_bill_cont_lines
        WHERE cle_id = l_line_id AND
        bill_action = 'RI';

    CURSOR sll_end_date_csr(l_cle_id NUMBER) IS
        SELECT MAX(end_date)
        FROM oks_stream_levels_b WHERE cle_id = l_cle_id;

    CURSOR sll_start_date_csr(l_cle_id NUMBER) IS
        SELECT MIN(start_date)
        FROM oks_stream_levels_b WHERE cle_id = l_cle_id;

    CURSOR check_lvl_element(l_cle_id NUMBER) IS
        SELECT amount FROM oks_level_elements
        WHERE nvl(amount, 0) < 0 AND
        cle_id = l_cle_id;

    l_amount  NUMBER;
    l_total_billed     NUMBER;
    l_line_price   NUMBER;
    l_renewal_status  VARCHAR2(30);

    BEGIN


        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        --adding the following code for Bug#4069048
        -- get renewal status to see if this is called for Electronic renewal
        -- if so bypass the Billing Schedule  validation
        l_renewal_status := get_renewal_status(p_chr_id);

        --Bug 4673694 in R12 the renewal status codes have been modified
        --if nvl(l_renewal_status ,'-99') <> 'QAS' and nvl(l_renewal_status, '-99') <> 'ERN_QA_CHECK_FAIL' then
        IF nvl(l_renewal_status, '-99') <> 'PEND_PUBLISH' THEN

            OPEN get_currency_csr (p_chr_id);
            FETCH get_currency_csr INTO l_currency;
            CLOSE get_currency_csr;

            FOR top_line_grp_rec IN top_line_grp_csr (p_chr_id)
                LOOP
                l_lvl_total_amt := 0;
                FOR get_ETP_rec IN get_ETP_csr (p_chr_id, top_line_grp_rec.id)
                    LOOP
                    l_ETP_flag := get_ETP_rec.BILLING_SCHEDULE_TYPE;
                END LOOP;

                --Check for top line SLL exists

                SELECT  COUNT(id)
                   INTO    l_top_line_SLL
                   FROM	oks_stream_levels_b -- okc_rules_b
                   WHERE	dnz_chr_id = p_chr_id
                AND cle_id = top_line_grp_rec.id;


                IF l_top_line_SLL = 0
                    THEN

                    -- store SQL error message on message stack
                    OKC_API.SET_MESSAGE
                    (
                     p_app_name => G_APP_NAME,
                     p_msg_name => 'OKS_TOPLINE_SLL_NOT_EXISTS',
                     p_token1 => 'TOKEN1',
                     --p_token1_value    => top_line_grp_rec.line_number
                     p_token1_value => get_line_name(top_line_grp_rec.id)
                     );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE

                    --l_SLL_end_date  := top_line_grp_rec.start_date;
                    --l_rules_ctr := 0;
                    OPEN sll_end_date_csr(top_line_grp_rec.id);
                    FETCH sll_end_date_csr INTO l_SLL_end_date;
                    CLOSE sll_end_date_csr;

                    OPEN sll_start_date_csr(top_line_grp_rec.id);
                    FETCH sll_start_date_csr INTO l_SLL_start_date;
                    CLOSE sll_start_date_csr;

                    l_lvl_total_billed_amt := 0;


                    FOR rules_rec IN rules_csr (p_chr_id, top_line_grp_rec.id)
                        LOOP

                        --To get end date of product billing cycle

                        /*l_SLL_end_date := okc_time_util_pub.get_enddate
                        (
                        l_SLL_end_date + l_rules_ctr,
                        rules_rec.uom_code,
                        rules_rec.level_periods * TO_NUMBER(rules_rec.uom_per_period)
                        );
                        l_rules_ctr := 1;
                        */

                        --Check for level element exists

                        SELECT COUNT(id)
                            INTO   l_bs_rec
                        FROM   oks_level_elements
                        WHERE   cle_id = top_line_grp_rec.id; -- rul_id = rules_rec.id;

                        IF l_bs_rec = 0
                            THEN

                            -- store SQL error message on message stack
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_LVL_ELEMENT_NOT_EXISTS',
                             p_token1 => 'TOKEN1',
                             --p_token1_value    => top_line_grp_rec.line_number
                             p_token1_value => get_line_name(top_line_grp_rec.id)
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF; --end if of l_bs_rec = 0



                        --l_lvl_element_count := 0;

                        -- This should only loop once.
                        FOR level_elements_amt_rec IN level_elements_amt_csr (rules_rec.id)
                            LOOP

                            /** Removed check (bug 5358599) as we already check for the product billing
                                cycle end dates matching the sublines end date.
                            IF ((rules_rec.level_periods <> level_elements_amt_rec.lvl_count) AND l_ETP_flag <> 'T')
                                THEN

                                -- store SQL error message on message stack
                                OKC_API.SET_MESSAGE
                                (
                                 p_app_name => G_APP_NAME,
                                 p_msg_name => 'OKS_SL_LVL_PERIOD_MISMATCH',
                                 p_token1 => 'TOKEN1',
                                 p_token1_value => get_line_name(top_line_grp_rec.id),
                                 p_token2 => 'TOKEN2',
                                 p_token2_value => rules_rec.level_periods,  --rule_information3,
                                 p_token3 => 'TOKEN3',
                                 p_token3_value => level_elements_amt_rec.lvl_count
                                 );
                                x_return_status := OKC_API.G_RET_STS_ERROR;

                            END IF;
                            **/

                            -- added for subscription lines
                            l_lvl_total_amt := l_lvl_total_amt + level_elements_amt_rec.lvl_amt;

                        END LOOP;

                    END LOOP; --end loop of rules_rec

                    --modified if condition, added check for credit amounts also, bug 4947610
                    -- Usage lines don't have an amount.
                    IF(l_ETP_flag = 'E') AND top_line_grp_rec.lse_id <> 12 AND -- top_line_grp_rec.lse_id = 46 and
                        oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_amt, 0), l_currency) <>
                        (oks_extwar_util_pvt.round_currency_amt(NVL(top_line_grp_rec.price_negotiated, 0),
                                                               l_currency) +
                         oks_extwar_util_pvt.round_currency_amt(NVL(top_line_grp_rec.credit_amount, 0),
                                                               l_currency) +
                         oks_extwar_util_pvt.round_currency_amt(NVL(top_line_grp_rec.suppressed_credit, 0),
                                                               l_currency)) THEN

                    /* original if condition commented for bug 4947610
                    IF(l_ETP_flag = 'E') AND top_line_grp_rec.lse_id <> 12 AND -- top_line_grp_rec.lse_id = 46 and
                        oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_amt, 0), l_currency) <>
                        oks_extwar_util_pvt.round_currency_amt(NVL(top_line_grp_rec.price_negotiated, 0),
                                                               l_currency) THEN
                    */
                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_LVL_TOTAL_PRICE_MIS',
                         p_token1 => 'TOKEN1',
                         p_token1_value => get_line_name(top_line_grp_rec.id),
                         p_token2 => 'TOKEN2',
                         p_token2_value => top_line_grp_rec.price_negotiated,
                         p_token3 => 'TOKEN3',
                         p_token3_value => l_lvl_total_amt
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;


                    --Check for Product billing cycle end date equal to lines end date
                    -- SLL start date should always be same as top line start date.
                    IF TRUNC(l_SLL_end_date) < TRUNC(top_line_grp_rec.end_date) OR
                        TRUNC(l_SLL_start_date) <> TRUNC(top_line_grp_rec.start_date)
                        THEN

                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_TOPLINE_SLL_PERIOD_INVALID',
                         p_token1 => 'TOKEN1',
                         p_token1_value => get_line_name(top_line_grp_rec.id)
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;

                    -- It's possible in Top level billing type that the SLL end date > top line end date
                    IF l_ETP_flag <> 'T' AND TRUNC(l_SLL_end_date) > TRUNC(top_line_grp_rec.end_date)
                        THEN

                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_TOPLINE_SLL_PERIOD_INVALID',
                         p_token1 => 'TOKEN1',
                         p_token1_value => get_line_name(top_line_grp_rec.id)
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                    END IF;

                END IF; --end if of l_top_line_SLL = 0

                -- If the subscription line is billed, the amount should not be
                -- greater than price negotiated.
                IF top_line_grp_rec.lse_id = 46 THEN

                    OPEN get_line_price(top_line_grp_rec.id);
                    FETCH get_line_price INTO l_line_price;
                    CLOSE get_line_price;
                    -- Added for bug # 4053552
                    IF l_ETP_flag IN ('E', 'P') AND nvl(l_line_price, 0) >= 0 THEN
                        -- Checking for negative level element for lse_id = 46
                        OPEN check_lvl_element(top_line_grp_rec.id);
                        FETCH check_lvl_element INTO l_amount;
                        IF check_lvl_element%FOUND THEN
                            -- The billing schedule amount for line number LINE_NO is negative.
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_NEG_LVL_ELEM',
                             p_token1 => 'LINE_NO',
                             p_token1_value => get_line_number(top_line_grp_rec.id)
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;
                        CLOSE check_lvl_element;
                    END IF;
                    -- End modification for bug # 4053552
                    OPEN get_top_billed_amount(top_line_grp_rec.id);
                    FETCH get_top_billed_amount INTO l_total_billed;
                    CLOSE get_top_billed_amount;

                    IF nvl(l_total_billed, 0) <> 0 THEN
                        l_temp_total_billed := nvl(l_total_billed, 0);
                        l_price_negotiated := nvl(l_line_price, 0);
                        -- If Billed amount and negotiated amount are both negative
                        IF (l_temp_total_billed < 0 AND
                            l_price_negotiated < 0 ) THEN
                            l_temp_total_billed := abs(l_temp_total_billed);
                            l_price_negotiated := abs(l_price_negotiated);
                        ELSIF l_price_negotiated < 0  AND l_temp_total_billed > 0 THEN
                            l_price_negotiated := abs(l_price_negotiated) + l_temp_total_billed;
                        END IF;

                        IF (oks_extwar_util_pvt.round_currency_amt(NVL(l_temp_total_billed, 0), l_currency) >
                            oks_extwar_util_pvt.round_currency_amt(NVL(l_price_negotiated, 0), l_currency))

                            THEN
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_SUBSCR_BILLED_AMT_MISMATCH',
                             p_token1 => 'TOKEN1',
                             p_token1_value => get_line_name(top_line_grp_rec.id),
                             p_token2 => 'TOKEN2',
                             p_token2_value => nvl(l_line_price, 0),
                             p_token3 => 'TOKEN3',
                             p_token3_value => nvl(l_total_billed, 0)
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF; -- IF ((oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_billed_amt,0),l_currency) >
                    END IF; -- nvl(l_total_billed, 0) <> 0
                    l_temp_total_billed := 0;
                END IF;
                --------------------------------------------------------------------

                -- Subscription lines will never enter this loop.
                FOR line_grp_rec IN line_grp_csr (p_chr_id, top_line_grp_rec.id)
                    LOOP
                    l_rules_ctr := 0;
                    --l_rules_total  := 0;


                    --Check for sub line SLL exists

                    SELECT  COUNT(id)
                       INTO    l_sub_line_SLL
                       FROM	oks_stream_levels_b
                       WHERE	dnz_chr_id = p_chr_id
                    AND cle_id = line_grp_rec.id;


                    FOR get_ETP_rec IN get_ETP_csr (p_chr_id, line_grp_rec.id)
                        LOOP
                        IF get_ETP_rec.BILLING_SCHEDULE_TYPE <> l_ETP_flag
                            THEN

                            -- store SQL error message on message stack
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_BILLING_FLAG_MISMATCH'
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF; --end if of get_ETP_rec
                    END LOOP;

                    --Check for start date and end date  for equal amount
                    IF l_ETP_flag = 'E' AND
                        (TRUNC(top_line_grp_rec.start_date) <> TRUNC(line_grp_rec.start_date)
                         OR TRUNC(top_line_grp_rec.end_date) <> TRUNC(line_grp_rec.end_date))
                        THEN

                        -- store SQL error message on message stack
                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_TOP_SUB_LINE_DATE_MISMATCH'
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                    END IF; --IF l_ETP_flag = 'E' and top_line_grp_rec.start_date <> line_grp_rec.start_date

                    IF l_sub_line_SLL = 0
                        THEN

                        -- store SQL error message on message stack
                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_SUBLINE_SLL_NOT_EXISTS',
                         p_token1 => 'TOKEN1',
                         --p_token1_value    => top_line_grp_rec.line_number||'.'||line_grp_rec.line_number
                         p_token1_value => get_line_name(line_grp_rec.id)
                         );
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                    ELSE

                        OPEN sll_end_date_csr(line_grp_rec.id);
                        FETCH sll_end_date_csr INTO l_SLL_end_date;
                        CLOSE sll_end_date_csr;

                        OPEN sll_start_date_csr(line_grp_rec.id);
                        FETCH sll_start_date_csr INTO l_SLL_start_date;
                        CLOSE sll_start_date_csr;

                        --l_SLL_end_date  := line_grp_rec.start_date;
                        --l_rules_ctr := 0;
                        l_lvl_total_amt := 0;
                        l_lvl_total_billed_amt := 0;

                        FOR rules_rec IN rules_csr (p_chr_id, line_grp_rec.id)
                            LOOP

                            --To get end date of product billing cycle
                            /*
                            l_SLL_start_date := l_SLL_end_date + l_rules_ctr;
                            l_SLL_end_date := okc_time_util_pub.get_enddate
                            (
                            l_SLL_end_date + l_rules_ctr,
                            rules_rec.uom_code, --object1_id1,
                            rules_rec.level_periods * TO_NUMBER(rules_rec.uom_per_period) --rule_information4)
                            );
                            l_rules_ctr := 1;
                            */
                            SELECT COUNT(id)
                                INTO   l_bs_rec
                            FROM   oks_level_elements
                            WHERE   cle_id = line_grp_rec.id; -- rul_id = rules_rec.id;

                            IF l_bs_rec = 0 THEN
                                -- store SQL error message on message stack
                                OKC_API.SET_MESSAGE
                                (
                                 p_app_name => G_APP_NAME,
                                 p_msg_name => 'OKS_LVL_ELEMENT_NOT_EXISTS',
                                 p_token1 => 'TOKEN1',
                                 --p_token1_value    => top_line_grp_rec.line_number||'.'||line_grp_rec.line_number
                                 p_token1_value => get_line_name(line_grp_rec.id)
                                 );
                                x_return_status := OKC_API.G_RET_STS_ERROR;

                            END IF; --end if of l_bs_rec = 0

                            --level element validation
                            --l_lvl_element_count := 0;

                            FOR level_elements_amt_rec IN level_elements_amt_csr (rules_rec.id)
                                LOOP

                                /** Removed check (bug 5358599) as we already check for the product billing
                                    cycle end dates matching the sublines end date.
                                IF ((rules_rec.level_periods <> level_elements_amt_rec.lvl_count) AND l_ETP_flag <> 'T')
                                    THEN

                                    -- store SQL error message on message stack
                                    OKC_API.SET_MESSAGE
                                    (
                                     p_app_name => G_APP_NAME,
                                     p_msg_name => 'OKS_SL_LVL_PERIOD_MISMATCH',
                                     p_token1 => 'TOKEN1',
                                     p_token1_value => get_line_name(line_grp_rec.id),
                                     p_token2 => 'TOKEN2',
                                     p_token2_value => rules_rec.level_periods,  --rule_information3,
                                     p_token3 => 'TOKEN3',
                                     p_token3_value => level_elements_amt_rec.lvl_count
                                     );
                                    x_return_status := OKC_API.G_RET_STS_ERROR;

                                END IF;
                                **/

                                l_lvl_total_amt := l_lvl_total_amt + level_elements_amt_rec.lvl_amt;

                            END LOOP; -- FOR level_elements_amt_rec IN level_elements_amt_csr
                            /*
                            FOR level_elements_billed_rec IN level_elements_billed_csr (rules_rec.id)
                            LOOP
                            l_lvl_total_billed_amt := l_lvl_total_billed_amt + level_elements_billed_rec.billed_amt;
                            END LOOP; -- FOR level_elements_billed_rec IN level_elements_billed_csr
                            */
                        END LOOP; --end loop of rules_rec

                        --Check for subline level element total equal to price negotiated
                        IF ((oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_amt, 0), l_currency) <>
                             oks_extwar_util_pvt.round_currency_amt(NVL(line_grp_rec.price_negotiated, 0), l_currency))
                            AND line_grp_rec.lse_id <> 13)
                            THEN

                            -- store SQL error message on message stack
                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_SL_LVL_TOT_AMT_MISMATCH',
                             p_token1 => 'TOKEN1',
                             p_token1_value => get_line_name(line_grp_rec.id),
                             p_token2 => 'TOKEN2',
                             p_token2_value => line_grp_rec.price_negotiated,
                             p_token3 => 'TOKEN3',
                             p_token3_value => l_lvl_total_amt
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF;

                        -- Added for bug # 4053552
                        IF l_ETP_flag IN ('E', 'P') AND nvl(line_grp_rec.price_negotiated, 0) >= 0 THEN
                            -- Checking for negative level elements for sub lines.
                            OPEN check_lvl_element(line_grp_rec.id);
                            FETCH check_lvl_element INTO l_amount;
                            IF check_lvl_element%FOUND THEN
                                -- The billing schedule amount for line number LINE_NO is negative.
                                OKC_API.SET_MESSAGE
                                (
                                 p_app_name => G_APP_NAME,
                                 p_msg_name => 'OKS_NEG_LVL_ELEM',
                                 p_token1 => 'LINE_NO',
                                 p_token1_value => get_line_number(line_grp_rec.id)
                                 );
                                x_return_status := OKC_API.G_RET_STS_ERROR;
                            END IF;
                            CLOSE check_lvl_element;
                        END IF;
                        -- End modification for bug # 4053552

                        -- checks if the contract is billed and if so is the line price less than
                        -- the billed amount.
                        IF line_grp_rec.lse_id <> 13 THEN
                            OPEN get_line_price(line_grp_rec.id);
                            FETCH get_line_price INTO l_line_price;
                            CLOSE get_line_price;

                            OPEN get_billed_amount(line_grp_rec.id);
                            FETCH get_billed_amount INTO l_total_billed;
                            CLOSE get_billed_amount;


                            IF nvl(l_total_billed, 0) <> 0 THEN
                                l_temp_total_billed := nvl(l_total_billed, 0);
                                l_price_negotiated := nvl(l_line_price, 0);
                                -- If Billed amount and negotiated amount are both negative
                                IF (l_temp_total_billed < 0 AND
                                    l_price_negotiated < 0 ) THEN
                                    l_temp_total_billed := abs(l_temp_total_billed);
                                    l_price_negotiated := abs(l_price_negotiated);
                                ELSIF l_price_negotiated < 0  AND l_temp_total_billed > 0 THEN
                                    l_price_negotiated := abs(l_price_negotiated) + l_temp_total_billed;
                                END IF;

                                IF (oks_extwar_util_pvt.round_currency_amt(NVL(l_temp_total_billed, 0), l_currency) >
                                    oks_extwar_util_pvt.round_currency_amt(NVL(l_price_negotiated, 0), l_currency))

                                    THEN
                                    OKC_API.SET_MESSAGE
                                    (
                                     p_app_name => G_APP_NAME,
                                     p_msg_name => 'OKS_SL_LVL_BILLED_AMT_MISMATCH',
                                     p_token1 => 'TOKEN1',
                                     p_token1_value => get_line_name(line_grp_rec.id),
                                     p_token2 => 'TOKEN2',
                                     p_token2_value => nvl(l_line_price, 0),
                                     p_token3 => 'TOKEN3',
                                     p_token3_value => nvl(l_total_billed, 0)
                                     );
                                    x_return_status := OKC_API.G_RET_STS_ERROR;
                                END IF; -- IF ((oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_billed_amt,0),l_currency) >
                            END IF; -- nvl(l_total_billed, 0) <> 0
                        END IF; -- line_grp_rec.lse_id <> 13
                        /*
                        --Check for price negotiated should not less than billed amount
                        -- Added so we can have negative prices.
                        If l_lvl_total_billed_amt is not null and l_lvl_total_billed_amt <> 0 Then
                        l_price_negotiated := line_grp_rec.price_negotiated;
                        l_temp_total_billed := l_lvl_total_billed_amt;
                        -- If Billed amount and negotiated amount are both negative
                        IF ( l_lvl_total_billed_amt < 0 and
                        NVL(l_price_negotiated, 0) < 0 ) THEN
                        l_temp_total_billed := abs(l_temp_total_billed);
                        l_price_negotiated := abs(l_price_negotiated);
                        END If;

                        IF ((oks_extwar_util_pvt.round_currency_amt(NVL(l_temp_total_billed ,0),l_currency) >
                        oks_extwar_util_pvt.round_currency_amt(NVL(l_price_negotiated,0),l_currency))
                        AND line_grp_rec.lse_id <> 13)
                        THEN

                        -- store SQL error message on message stack
                        OKC_API.SET_MESSAGE
                        (
                        p_app_name        => G_APP_NAME,
                        p_msg_name        => 'OKS_SL_LVL_BILLED_AMT_MISMATCH',
                        p_token1          => 'TOKEN1',
                        p_token1_value    => get_line_name(line_grp_rec.id),
                        p_token2          => 'TOKEN2',
                        p_token2_value    => line_grp_rec.price_negotiated,
                        p_token3          => 'TOKEN3',
                        p_token3_value    => l_lvl_total_billed_amt
                        );
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                        END IF;
                        End If; -- if there is a billed amount

                        */

                        --Check for Product billing cycle end date equal to lines end date
                        -- This check is not done for Top level billing type because the
                        -- SLL end date in that case might go beyond the line end date.
                        IF ((l_ETP_flag = 'E' OR l_ETP_flag = 'P')
                            AND TRUNC(l_SLL_end_date) <> TRUNC(line_grp_rec.end_date))
                            OR
                            (l_ETP_flag = 'P' AND TRUNC(l_SLL_start_date) <> TRUNC(line_grp_rec.start_date) )
                            THEN

                            OKC_API.SET_MESSAGE
                            (
                             p_app_name => G_APP_NAME,
                             p_msg_name => 'OKS_SUBLINE_SLL_PERIOD_INVALID',
                             p_token1 => 'TOKEN1',
                             p_token1_value => get_line_name(line_grp_rec.id)
                             );
                            x_return_status := OKC_API.G_RET_STS_ERROR;
                        END IF;


                    END IF; --end if of l_sub_line_SLL = 0

                    -- l_sub_line_price_nego_tot := l_sub_line_price_nego_tot + NVL(line_grp_rec.price_negotiated,0);
                    -- Compares each sub line price negotiated to sum of level elements for that subline.
                    /*
                    IF (l_ETP_flag = 'E' AND top_line_grp_rec.lse_id <> 12)
                    and (oks_extwar_util_pvt.round_currency_amt(NVL(l_lvl_total_amt,0),l_currency) <>
                    oks_extwar_util_pvt.round_currency_amt(NVL(line_grp_rec.price_negotiated,0),l_currency))

                    THEN

                    OKC_API.SET_MESSAGE
                    (
                    p_app_name        => G_APP_NAME,
                    p_msg_name        => 'OKS_LVL_TOTAL_PRICE_MIS',
                    p_token1          => 'TOKEN1',
                    p_token1_value    => get_line_name(line_grp_rec.id), --'2'
                    p_token2          => 'TOKEN2',
                    p_token2_value    => line_grp_rec.price_negotiated, -- each negotiated sub line
                    p_token3          => 'TOKEN3',
                    p_token3_value    => l_lvl_total_amt -- sum of subline level elements
                    );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;
                    */

                END LOOP; --end loop of line_grp_rec



            END LOOP; --end loop of top_line_grp_rec
        END IF;
        IF x_return_status = OKC_API.G_RET_STS_SUCCESS
            THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF; -- IF x_return_status = OKC_API.G_RET_STS_SUCCESS


    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := OKC_API.G_RET_STS_ERROR;
            OKC_API.SET_MESSAGE
            (
             p_app_name => G_APP_NAME,
             p_msg_name => G_UNEXPECTED_ERROR,
             p_token1 => G_SQLCODE_TOKEN,
             p_token1_value => SQLCODE,
             p_token2 => G_SQLERRM_TOKEN,
             p_token2_value => SQLERRM
             );
    END check_billing_schedule;

    /*============================================================================+
    | Procedure:           Check_product_availability
    |
    | Purpose:     If line status is ENTERED then checks if service is available
    |              for the covered product or item.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_product_availability
    (
     X_Return_Status	  OUT NOCOPY VARCHAR2,
     p_chr_id		  IN   NUMBER
     )
    IS
    service_rec_type        OKS_OMINT_PUB.check_service_rec_type;
    l_service_id		NUMBER;
    l_service_item_id	NUMBER;
    l_product_id		NUMBER;
    l_product_item_id	NUMBER;
    l_customer_id		NUMBER;
    l_msg_Count		NUMBER;
    l_msg_Data		VARCHAR2(50);
    l_Return_Status		VARCHAR2(1);
    l_Available_YN	 	VARCHAR2(1);
    l_api_name          CONSTANT VARCHAR2(30) := 'Check_product_availability';

    --start changes for org id in is_service_available
    CURSOR get_auth_org_csr IS
        SELECT authoring_org_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    get_auth_org_rec  get_auth_org_csr%ROWTYPE;
    --End changes for org id in is_service_available

    /*** Get all service lines for given Contract header id ***/
    CURSOR l_csr_get_service_line_id(p_chr_id NUMBER) IS
        SELECT cle.id, sts.ste_code sts_code
        FROM   okc_k_lines_b cle,
               okc_statuses_b sts
        WHERE  cle.dnz_chr_id = p_chr_id
        AND    sts.code = cle.sts_code
        AND    cle.lse_id IN (1, 19)
        AND    cle.date_cancelled IS NULL --Changes [llc]
        ;

    /*** Get customer id for all the above service lines ***/
    -- object1_id1 of CAN rule
    CURSOR l_csr_get_customer_id(p_chr_id NUMBER, l_service_id NUMBER) IS
        SELECT CUST_ACCT_ID
        FROM   okc_k_lines_b
        WHERE  dnz_chr_id = p_chr_id
        AND    id = l_service_id;



    /*** Get service item id for all the service lines from OKC_K_ITEMS_V ***/
    CURSOR l_csr_get_service_item_id(p_cle_id IN NUMBER) IS
        SELECT object1_id1
        FROM   okc_k_items_v
        WHERE  cle_id = p_cle_id ;


    /*** Get all product lines and item lines for each service line ***/
    CURSOR l_csr_get_product_line_id IS
        SELECT id, start_date, lse_id
        FROM   okc_k_lines_b
        WHERE  cle_id = l_service_id
        AND    lse_id IN (9, 25, 7) -- 7 added for bug#2430496
        AND    date_cancelled IS NULL --Changes [llc]
        ;


    /*** Get service item id or product item if for all the service lines
    *** or product lines  from OKC_K_ITEMS_V                              ***/
    -- For a covered item the inventory_item_id is
    -- stored inside of object1_id1
    -- For covered products the customer_product_id is stored inside of object1_id1
    CURSOR l_csr_get_item_id(p_cle_id IN NUMBER) IS
        SELECT object1_id1
        FROM   okc_k_items_v
        WHERE  cle_id = p_cle_id ;

    CURSOR l_product_csr(p_cp_id NUMBER) IS
        SELECT inventory_item_id
        FROM   csi_item_instances
        WHERE  instance_id = p_cp_id;

    l_cp_id NUMBER;
    l_sts_code   VARCHAR2(100);
    l_prod_start_date DATE;
    l_lse_id  NUMBER;

    BEGIN

        X_return_status := OKC_API.G_RET_STS_SUCCESS;
        /*** Get customer_id ****/

        l_service_id := NULL;
        l_sts_code := NULL;

        --changes for passing org_id in is_service_available
        OPEN get_auth_org_csr;
        FETCH get_auth_org_csr INTO get_auth_org_rec;
        CLOSE get_auth_org_csr;

        OPEN l_csr_get_service_line_id(p_chr_id);
        LOOP
            FETCH l_csr_get_service_line_id INTO l_service_id, l_sts_code;
            EXIT WHEN  l_csr_get_service_line_id%NOTFOUND;

            l_customer_id := NULL;

            OPEN l_csr_get_customer_id(p_chr_id, l_service_id);
            FETCH l_csr_get_customer_id INTO l_customer_id;
            IF l_csr_get_customer_id%NOTFOUND
                THEN
                x_return_status := 'E';
                CLOSE l_csr_get_customer_id;
                EXIT;
            END IF;
            CLOSE l_csr_get_customer_id;

            l_service_item_id := NULL;

            OPEN l_csr_get_item_id(l_service_id);
            FETCH l_csr_get_item_id INTO l_service_item_id;
            IF l_csr_get_item_id%NOTFOUND
                THEN
                x_return_status := 'E';
                CLOSE l_csr_get_item_id;
                EXIT;
            END IF;
            CLOSE l_csr_get_item_id;

            l_product_id := NULL;
            l_prod_start_date := NULL;

            -------------------- Product line id loop ---------------------------------
            OPEN l_csr_get_product_line_id;
            LOOP
                FETCH l_csr_get_product_line_id INTO l_product_id, l_prod_start_date, l_lse_id;
                EXIT WHEN  l_csr_get_product_line_id%NOTFOUND;

                l_product_item_id := NULL;

                OPEN l_csr_get_item_id(l_product_id);
                FETCH l_csr_get_item_id INTO l_product_item_id;
                IF l_csr_get_item_id%NOTFOUND THEN
                    x_return_status := 'E';
                    CLOSE l_csr_get_item_id;
                    EXIT;
                END IF;
                CLOSE l_csr_get_item_id;

                l_cp_id := NULL;
                -- Fix for bug # 3676448
                -- For a covered item the inventory_item_id is
                -- stored inside of object1_id1 instead of customer_product_id
                -- customer product id is stored in object1_id1 for lse id 25, 9
                IF l_lse_id = 7 THEN
                    l_cp_id := l_product_item_id;
                ELSE
                    OPEN l_product_csr(l_product_item_id);
                    FETCH l_product_csr INTO l_cp_id;
                    CLOSE l_product_csr;
                END IF;

                service_rec_type.service_item_id := l_service_item_id;
                service_rec_type.customer_id := l_customer_id;
                service_rec_type.product_item_id := l_cp_id;
                service_rec_type.request_date := l_prod_start_date;
                l_available_YN := NULL;

                IF l_sts_code = 'ENTERED' THEN
                    --changes for passing org_id in is_service_available
                    OKS_OMINT_PUB.Is_Service_Available
                    (
                     p_api_version => 1.0,
                     p_init_msg_list => 'F',
                     x_msg_count => l_msg_Count,
                     x_msg_data => l_msg_Data,
                     x_return_status => l_Return_Status,
                     p_check_service_rec => service_rec_type,
                     x_available_yn => l_available_YN,
                     p_org_id => get_auth_org_rec.authoring_org_id
                     );


                    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'After Service_Available return_status: '|| x_return_status);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_msg_data: '|| l_msg_data);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_msg_count: '|| l_msg_count);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_available_YN: '|| l_available_YN);
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, G_PKG_NAME || '.' || l_api_name,'l_org_id: '|| get_auth_org_rec.authoring_org_id);
                    END IF;
                    IF l_available_yn = 'N'  THEN
                        x_return_status := OKC_API.G_RET_STS_ERROR;

                        OKC_API.set_message
                        (
                         p_app_name => 'OKS',
                         p_msg_name => 'OKS_PRODUCT_AVAILABILITY',
                         p_token1 => 'TOKEN1',
                         --p_token1_value  => get_line_name(l_line_rec.line_number),
                         p_token1_value => get_line_name(l_service_id),
                         p_token2 => 'TOKEN2',
                         p_token2_value => get_line_name(l_product_id)
                         );

                    END IF;
                END IF; --If l_sts_code = 'ENTERED'

            END LOOP;  	/** End loop get product line id **/
            CLOSE l_csr_get_product_line_id;
            ----------------- Product line id loop -------------------------------

        END LOOP;  /** End loop get service line id  **/
        CLOSE l_csr_get_service_line_id;
        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;



    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            -- verify that cursor was closed


    END Check_product_availability;

    /*============================================================================+
    | Procedure:           check_customer_avail_loop
    |
    | Purpose:     Helper procedure for check_customer_availability
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_customer_avail_loop
    (
     x_return_status	  OUT  NOCOPY VARCHAR2,
     p_cust_acct_id		      IN   NUMBER,
     p_chr_id           IN NUMBER,
     p_line_number      IN NUMBER,
     p_usage            IN VARCHAR2
     ) IS

    l_cust_acct_id  NUMBER := p_cust_acct_id;
    l_acct_name     VARCHAR2(360);
    l_cust_party_id       NUMBER;
    l_party_id      NUMBER;
    l_org_id        NUMBER;

    l_cust_id   NUMBER;
    l_rel_cust_id   NUMBER;
    l_rel_cust_flag VARCHAR2 (5) := 'Y';

    CURSOR get_cust_id(l_cust_acct_id NUMBER) IS
        SELECT P.PARTY_NAME name, CA.PARTY_ID party_id
        FROM HZ_CUST_ACCOUNTS CA, HZ_PARTIES P
        WHERE CA.PARTY_ID = P.PARTY_ID AND
        CA.CUST_ACCOUNT_ID = l_cust_acct_id;

    -- This cursor will return the party id of the customer or third party
    -- stored on the contract header.
    -- If no value is returned then check the related customers
    CURSOR cust_exist_csr(cust_id NUMBER) IS
        SELECT object1_id1 party_id
        FROM okc_k_party_roles_v
        WHERE rle_code NOT IN ('VENDOR', 'MERCHANT')
        AND object1_id1 = cust_id
        AND dnz_chr_id = p_chr_id
        AND chr_id = p_chr_id;

    CURSOR get_org_id IS
        SELECT AUTHORING_ORG_ID
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;

    CURSOR get_contr_cust IS
        SELECT object1_id1 party_id
        FROM okc_k_party_roles_v
        WHERE rle_code NOT IN ('VENDOR', 'MERCHANT')
        AND dnz_chr_id = p_chr_id
        AND chr_id = p_chr_id;

    -- If the party id does not belong to the customer or third party then
    -- it might belong to the related customer account. If not give an error.
    -- replaced OKX_CUST_ACCT_RELATE_ALL_V with HZ_CUST_ACCT_RELATE_ALL
    -- replaced OKX_CUSTOMER_ACCOUNTS_V  with HZ_CUST_ACCOUNTS
    CURSOR get_related_cust_acct_id(orgId NUMBER, relatedCustAccId NUMBER,
                                    custPartyId NUMBER) IS
        SELECT A.CUST_ACCOUNT_ID, A.RELATED_CUST_ACCOUNT_ID
        FROM   HZ_CUST_ACCT_RELATE_ALL A,
        HZ_CUST_ACCOUNTS CA
        WHERE  CA.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
        AND    CA.PARTY_ID = custPartyId
        AND    A.RELATED_CUST_ACCOUNT_ID = relatedCustAccId
        AND    CA.STATUS = 'A'
        AND    A.status = 'A'
        AND    A.org_id = orgId;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- Gets the account name of the party owning the line
        OPEN get_cust_id(l_cust_acct_id);
        FETCH get_cust_id INTO l_acct_name, l_cust_party_id;
        CLOSE get_cust_id;

        IF l_cust_party_id IS NOT NULL THEN
            -- checks to see if the line party is the same as the header party.
            OPEN cust_exist_csr(l_cust_party_id);
            FETCH cust_exist_csr INTO l_party_id;
            -- if account does not belong to customer or third party then
            -- it might belong to related customer.
            IF cust_exist_csr%NOTFOUND THEN
                OPEN get_org_id;
                FETCH get_org_id INTO l_org_id;
                CLOSE get_org_id;

                -- get's the customer/third party, party id of the contract header.
                -- Open get_contr_cust;
                -- Fetch get_contr_cust into l_party_id;
                -- Bug Fix 4253417
                FOR get_contr_rec IN get_contr_cust
                    LOOP
                    l_rel_cust_flag := 'N';
                    l_party_id := get_contr_rec.party_id;
                    -- makes sure the customer on the contract has a relationship
                    -- with the related customer.
                    OPEN get_related_cust_acct_id(l_org_id, l_cust_acct_id, l_party_id);
                    FETCH get_related_cust_acct_id INTO l_cust_id, l_rel_cust_id;
                    IF get_related_cust_acct_id%FOUND THEN
                        CLOSE get_related_cust_acct_id;
                        l_rel_cust_flag := 'Y';
                        EXIT;
                    END IF;
                    CLOSE get_related_cust_acct_id;
                END LOOP;
                -- Bug Fix end 4253417
                IF l_rel_cust_flag = 'N' THEN
                    IF p_usage = 'BTO' THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_BTO_ACCT,
                                            p_token1 => 'ACCOUNT_NAME',
                                            p_token1_value => l_acct_name,
                                            p_token2 => 'LINE_NUMBER',
                                            p_token2_value => p_line_number);
                    ELSE
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_STO_ACCT,
                                            p_token1 => 'ACCOUNT_NAME',
                                            p_token1_value => l_acct_name,
                                            p_token2 => 'LINE_NUMBER',
                                            p_token2_value => p_line_number);
                    END IF;
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;

            END IF; -- cust_exist_csr%NOTFOUND
            CLOSE cust_exist_csr;

        END IF; -- l_cust_party_id is not null


    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END check_customer_avail_loop;

    /*============================================================================+
    | Procedure:           check_customer_availability
    |
    | Purpose:             Checks if the account stored on each contract
    |                      line belongs to the customer/subscriber, third party
    |                      or related customer.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_customer_availability
    (
     x_return_status	  OUT  NOCOPY VARCHAR2,
     p_chr_id		      IN   NUMBER
     ) IS

    --The customer account id, third party account id or the customer related
    -- account id used to be stored in the CAN rule for lines.
    -- Now it's stored in contract lines.
    -- Bug 4915718--
    -- We would not be checking Inactive Customer Account for
    -- lines that have been terminated (with termination date less than sysdate)

    CURSOR get_cust_acct_lines(p_chr_id NUMBER) IS
        SELECT cust_acct_id, id, ship_to_site_use_id, line_number
        FROM okc_k_lines_b
        WHERE  dnz_chr_id = p_chr_id
        AND cust_acct_id IS NOT NULL
        AND chr_id IS NOT NULL
        AND date_cancelled IS NULL --Changes [llc]
        AND (date_terminated IS NULL OR date_terminated > SYSDATE); -- Bug 4915718


    -- gets ship to customber account id
    CURSOR get_ship_to_acct(l_site_use_id NUMBER) IS
        SELECT CA.cust_account_id
        FROM HZ_CUST_SITE_USES_ALL CS, HZ_CUST_ACCT_SITES_ALL CA
        WHERE CS.SITE_USE_ID = l_site_use_id
        AND CS.site_use_code = 'SHIP_TO'
        AND CS.cust_acct_site_id = CA.cust_acct_site_id;

    CURSOR is_cust_active(l_cust_acct_id NUMBER) IS
        SELECT status
        FROM hz_cust_accounts
        WHERE cust_account_id = l_cust_acct_id
        AND status = 'A';

    CURSOR get_contr_cust IS
        SELECT object1_id1 party_id, rle_code
        FROM okc_k_party_roles_v
        WHERE rle_code NOT IN ('VENDOR', 'MERCHANT')
        AND dnz_chr_id = p_chr_id
        AND chr_id = p_chr_id;

    CURSOR is_cust_hdr_active(l_party_id NUMBER) IS
        SELECT CA.CUST_ACCOUNT_ID,
        ca.status,
        decode(CA.ACCOUNT_NAME, NULL, P.PARTY_NAME, CA.Account_NAME) NAME
        FROM HZ_CUST_ACCOUNTS CA, HZ_PARTIES P
        WHERE CA.PARTY_ID = P.PARTY_ID
        AND P.PARTY_ID = l_party_id;

    -- GCHADHA --
    -- BUG 4138244  --
    -- Fetch the Customer Bill to Id and Ship to Id
    -- Get the Cust Account Id
    -- Validate the whether the Cust_Account_Id is
    -- Active or not

    CURSOR get_billto_shipto(p_chr_id IN NUMBER) IS
        SELECT bill_to_site_use_id, ship_to_site_use_id
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id ;


    CURSOR get_billto_cust_acct(p_bill_to_site_use_id IN NUMBER) IS
        SELECT
          c.cust_account_id CUST_ID1,
          p.party_id party_id

        FROM OKX_CUST_SITE_USES_V a,
           hz_cust_accounts c,
           hz_parties p
        WHERE a.id1 = p_bill_to_site_use_id
        AND c.cust_account_id = a.cust_account_id
        AND a.site_use_code = 'BILL_TO'
        AND p.party_id = c.party_id;

    CURSOR get_shipto_cust_acct(p_ship_to_site_use_id IN NUMBER) IS
        SELECT
           c.cust_account_id CUST_ID1,
           p.party_id party_id
        FROM OKX_CUST_SITE_USES_V a,
              hz_cust_accounts c,
              hz_parties p
        WHERE a.id1 = p_ship_to_site_use_id
        AND c.cust_account_id = a.cust_account_id
        AND a.site_use_code = 'SHIP_TO'
        AND p.party_id = c.party_id;

    CURSOR Get_Status_Party (l_cust_acct_id IN NUMBER, l_party_id IN NUMBER) IS
        SELECT CA.CUST_ACCOUNT_ID, ca.status,
        decode(CA.ACCOUNT_NAME, NULL, P.PARTY_NAME, CA.Account_NAME) NAME
        FROM HZ_CUST_ACCOUNTS CA, HZ_PARTIES P
        WHERE CA.PARTY_ID = P.PARTY_ID
        AND P.PARTY_ID = l_party_id
        AND CA.CUST_ACCOUNT_ID = l_cust_acct_id;



    CURSOR Get_Relationship(p_chr_id IN NUMBER, p_party_id IN NUMBER) IS
        SELECT rle_code
        FROM okc_k_party_roles_b
        WHERE rle_code NOT IN ('VENDOR', 'MERCHANT')
        AND dnz_chr_id = p_chr_id
        AND chr_id = p_chr_id
        AND object1_id1 = p_party_id;


    -- Use this Cursor to find Customer /Third Party related to the
    -- Customer_account which is  inactive
    CURSOR get_parent_party (p_org_id IN NUMBER, p_id IN NUMBER) IS
        SELECT rle_code, B.Status, B.PARTY_STATUS  FROM okc_k_party_roles_v A,
        (SELECT CA.PARTY_ID, A.Status, CA.STATUS PARTY_STATUS FROM   HZ_CUST_ACCT_RELATE_ALL A,
         HZ_CUST_ACCOUNTS CA  WHERE  CA.CUST_ACCOUNT_ID = A.CUST_ACCOUNT_ID
         AND    A.RELATED_CUST_ACCOUNT_ID = p_id
         AND    A.org_id = p_org_id) B
       WHERE A.rle_code NOT IN ('VENDOR', 'MERCHANT')
       AND A.dnz_chr_id = p_chr_id
       AND A.chr_id = p_chr_id
      AND A.OBJECT1_ID1 = B.Party_ID
      ORDER BY B.STATUS,B.PARTY_STATUS;/*BUG 6719442*/


    -- Check whether the customer/third party is active or not.
    CURSOR Get_Status_Party_Main (l_party_id IN NUMBER) IS
        SELECT CA.CUST_ACCOUNT_ID, ca.status,
        decode(CA.ACCOUNT_NAME, NULL, P.PARTY_NAME, CA.Account_NAME) NAME
        FROM HZ_CUST_ACCOUNTS CA, HZ_PARTIES P
        WHERE CA.PARTY_ID = P.PARTY_ID
        AND P.PARTY_ID = l_party_id
        AND CA.STATUS = 'A';

    CURSOR get_org_id IS
        SELECT AUTHORING_ORG_ID
        FROM okc_k_headers_all_b
        WHERE id = p_chr_id;


    l_bill_to_site_use_id  NUMBER;

    l_ship_to_site_use_id  NUMBER;

    l_temp_party_id        NUMBER;

    l_org_id               NUMBER;

    l_rle_code             VARCHAR2(30);

    l_flag                 NUMBER := 0; -- Used for Related Customer.

    l_related_status       VARCHAR2(10); -- USed to get status of Related Customer

    l_cust_inactive       NUMBER := 0; -- If the customer itself is inactive set it to 1

    -- Flag to Verify whether the Billto /Shipto Related Customer
    -- is inactive  l_bsto =1 FOR Bill To l_bsto =2 FOR Ship to

    l_bto_flag           NUMBER := 0;

    l_sto_flag           NUMBER := 0;


    l_party_status        VARCHAR2(10); -- Check the party status when checking Related Customer

    -- END GCHADHA --



    l_cust_acct_id  NUMBER;
    l_line_number  VARCHAR2(150);
    l_status   VARCHAR2(30);
    l_name     VARCHAR2(360);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ship_to_cust_acct_id NUMBER;
    l_cust_not_found BOOLEAN;



    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        l_cust_not_found := TRUE;
        -- GCHADHA --
        -- BUG 4138244 ---
        -- Checks if customer/subscriber or third party are active.
        -- First Check whether the Customer/Third Party is Valid or Not
        -- Then Check whether the Cust_Account_ID is Valid Or Not


        FOR get_cust_rec IN get_contr_cust LOOP
            l_cust_not_found := FALSE;
            OPEN Get_Status_Party_Main(get_cust_rec.party_id);
            FETCH Get_Status_Party_Main INTO l_cust_acct_id, l_status, l_name;
            IF Get_Status_Party_Main%NOTFOUND THEN
                -- Get the Customer Name
                OPEN is_cust_hdr_active(get_cust_rec.party_id);
                FETCH is_cust_hdr_active INTO l_cust_acct_id, l_status, l_name;
                CLOSE is_cust_hdr_active;
                l_cust_inactive := 1;
                -- Get the customer name
                IF get_cust_rec.rle_code = 'CUSTOMER' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_CUST_INACTIVE,  -- Customer is not acitive.
                                        p_token1 => 'NAME',
                                        p_token1_value => l_name
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSIF get_cust_rec.rle_code = 'THIRD_PARTY' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_THIRD_PARTY_INACTIVE,  -- Third party is not active.
                                        p_token1 => 'NAME',
                                        p_token1_value => l_name
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSIF get_cust_rec.rle_code = 'SUBSCRIBER' THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_SUB_INACTIVE,  -- Subscriber is  not active.
                                        p_token1 => 'NAME',
                                        p_token1_value => l_name
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;

            END IF;
            CLOSE Get_Status_Party_Main;
        END LOOP;


        OPEN get_billto_shipto(p_chr_id);
        FETCH get_billto_shipto INTO l_bill_to_site_use_id, l_ship_to_site_use_id ;
        CLOSE get_billto_shipto;


        OPEN get_org_id;
        FETCH get_org_id INTO l_org_id;
        CLOSE get_org_id;

        -- Check Bill to Account
        IF l_bill_to_site_use_id IS NOT NULL THEN
            -- Check the status of the cust_account id  using bill to cust account id
            l_cust_not_found := FALSE;
            OPEN get_billto_cust_acct (l_bill_to_site_use_id) ;
            FETCH get_billto_cust_acct INTO l_cust_acct_id, l_temp_party_id;
            CLOSE get_billto_cust_acct;

            OPEN Get_Relationship(p_chr_id, l_temp_party_id);
            FETCH Get_Relationship INTO l_rle_code;
            IF  Get_Relationship%NOTFOUND THEN
                -- Check for Related customer --
                OPEN get_parent_party (l_org_id, l_cust_acct_id);
                FETCH get_parent_party INTO l_rle_code, l_related_status, l_party_status;
                IF l_related_status <> 'A' OR l_party_status <> 'A' THEN
                    l_flag := 1;
                    l_bto_flag := 1; -- Missing Bill to
                END IF;

                CLOSE get_parent_party;
            END IF;
            CLOSE Get_Relationship;

            OPEN Get_Status_Party (l_cust_acct_id, l_temp_party_id);
            FETCH Get_Status_Party INTO l_cust_acct_id, l_status, l_name;
            IF Get_Status_Party%FOUND THEN
                IF l_status <> 'A' AND l_bto_flag <> 1 THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_BILL_CUST_INACTIVE -- Customer is not acitive.

                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF;
            CLOSE Get_Status_Party;


        END IF;
        -- Check Ship to Account
        IF l_ship_to_site_use_id IS NOT NULL THEN
            -- Check the status of the cust_account id  using bil to and ship to cust account id
            l_cust_not_found := FALSE;

            OPEN get_shipto_cust_acct (l_ship_to_site_use_id) ;
            FETCH get_shipto_cust_acct INTO l_cust_acct_id, l_temp_party_id;
            CLOSE get_shipto_cust_acct;

            OPEN Get_Relationship(p_chr_id, l_temp_party_id);
            FETCH Get_Relationship INTO l_rle_code;
            IF  Get_Relationship%NOTFOUND THEN
                -- Check for Related customer --
                OPEN get_parent_party (l_org_id, l_cust_acct_id);
                FETCH get_parent_party INTO l_rle_code, l_related_status, l_party_status;
                IF l_related_status <> 'A' OR l_party_status <> 'A'  THEN
                    l_flag := 1;
                    l_sto_flag := 2; -- Missing Ship to
                END IF;

                CLOSE get_parent_party;
            END IF;
            CLOSE Get_Relationship;


            OPEN Get_Status_Party (l_cust_acct_id, l_temp_party_id);
            FETCH Get_Status_Party INTO l_cust_acct_id, l_status, l_name;
            IF Get_Status_Party%FOUND THEN
                IF l_status <> 'A' AND l_sto_flag <> 2 THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_SHIP_CUST_INACTIVE -- Bill to Customer Account is not acitive.
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
            END IF;
            CLOSE Get_Status_Party;

        END IF;



        -- l_flag is used to display the error in condition when the
        -- billto/shipto account is a related customer and, this customer is
        -- inactive.
        IF l_flag = 1 THEN
            IF l_bto_flag = 1 THEN -- IF THE RELATED CUSTOMER IS IN BILL TO
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_BILL_CUST_INACTIVE -- Bill To Related Customer is not acitive.
                                    );
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            IF l_sto_flag = 2 THEN -- SHIP TO
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_SHIP_CUST_INACTIVE -- Ship To Related  Customer is not acitive.
                                    );
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            l_sto_flag := 0;
            l_bto_flag := 0;
        END IF;
        l_flag := 0;


        /*
        For get_cust_rec in get_contr_cust Loop
        l_cust_not_found := false;
        Open is_cust_hdr_active(get_cust_rec.party_id);
        Fetch is_cust_hdr_active into l_cust_acct_id, l_status, l_name;
        If is_cust_hdr_active%FOUND Then
        If l_status <> 'A' Then
        If get_cust_rec.rle_code = 'CUSTOMER' Then
        OKC_API.set_message(
        p_app_name        =>  G_APP_NAME,
        p_msg_name        =>  G_CUST_INACTIVE, -- Customer is not acitive.
        p_token1  => 'NAME',
        p_token1_value  => l_name
        );
        x_return_status := OKC_API.G_RET_STS_ERROR;
        Elsif get_cust_rec.rle_code = 'THIRD_PARTY' Then
        OKC_API.set_message(
        p_app_name        =>  G_APP_NAME,
        p_msg_name        =>  G_THIRD_PARTY_INACTIVE, -- Third party is not active.
        p_token1  => 'NAME',
        p_token1_value  => l_name
        );
        x_return_status := OKC_API.G_RET_STS_ERROR;
        Elsif get_cust_rec.rle_code = 'SUBSCRIBER' Then
        OKC_API.set_message(
        p_app_name        =>  G_APP_NAME,
        p_msg_name        =>  G_SUB_INACTIVE, -- Subscriber is  not active.
        p_token1  => 'NAME',
        p_token1_value  => l_name
        );
        x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
        End If;
        End If;
        Close is_cust_hdr_active;
        End Loop; */


        -- END BUG 4138244  --


        IF l_cust_not_found THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_CUST_MISSING
                                );
            x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;

        -- Checks bill to and ship to account on each top line
        FOR get_cust_rec IN get_cust_acct_lines(p_chr_id) LOOP
            l_cust_acct_id := get_cust_rec.cust_acct_id;
            OPEN is_cust_active(l_cust_acct_id);
            FETCH is_cust_active INTO l_status;
            IF is_cust_active%NOTFOUND THEN
                OKC_API.set_message(
                                    p_app_name => G_APP_NAME,
                                    p_msg_name => G_CUST_NOT_ACTIVE,  --Bill to customer account is inactive on line number ....
                                    p_token1 => 'LINE',
                                    p_token1_value => get_cust_rec.line_number
                                    );
                x_return_status := OKC_API.G_RET_STS_ERROR;
            END IF;
            CLOSE is_cust_active;
            check_customer_avail_loop(l_return_status, l_cust_acct_id, p_chr_id, get_cust_rec.line_number, 'BTO');
            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
            END IF;

            --- Check ship to cust account
            OPEN get_ship_to_acct(get_cust_rec.ship_to_site_use_id);
            FETCH get_ship_to_acct INTO l_ship_to_cust_acct_id;
            IF get_ship_to_acct%FOUND THEN
                OPEN is_cust_active(l_ship_to_cust_acct_id);
                FETCH is_cust_active INTO l_status;
                IF is_cust_active%NOTFOUND THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_SHIP_CUST_NOT_ACTIVE,  --Ship to customer account is inactive on line number ....
                                        p_token1 => 'LINE',
                                        p_token1_value => get_cust_rec.line_number
                                        );
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
                CLOSE is_cust_active;
                check_customer_avail_loop(l_return_status, l_ship_to_cust_acct_id, p_chr_id, get_cust_rec.line_number, 'STO');
                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    x_return_status := l_return_status;
                END IF;
            END IF;
            CLOSE get_ship_to_acct;


        END LOOP;


        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue with next column
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            IF get_ship_to_acct%ISOPEN THEN
                CLOSE get_ship_to_acct;
            END IF;

    END check_customer_availability;

    /*============================================================================+
    | Procedure:           check_pm
    |
    | Purpose:             This procedure will check PM schedule and PM programs
    |                      effectivity.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_pm
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     )
    IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OKS_PM_PROGRAMS_PVT.check_pm_program_effectivity
        (x_return_status => l_return_status,
         p_chr_id => p_chr_id);


        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
        END IF;

        OKS_PM_PROGRAMS_PVT.check_pm_schedule
        (x_return_status => l_return_status,
         p_chr_id => p_chr_id);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
        END IF;

        OKS_PM_PROGRAMS_PVT.check_pm_new_activities
        (x_return_status => l_return_status,
         p_chr_id => p_chr_id);

        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
        END IF;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
            NULL;
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END check_pm;

    /*============================================================================+
    | Procedure:           Check_item_instance_valid
    |
    | Purpose:             This QA check is only for contracts with ccovered
    |                      products that are covering a subscription item.
    |                      1. It checks if the subscrition item belongs to another
    |                         contract and if so is the other contract active
    |                         or signed.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE Check_item_instance_valid
    (
     x_return_status            OUT NOCOPY VARCHAR2,
     p_chr_id                   IN  NUMBER
     ) IS
    -- Get sublines with covered products
    CURSOR get_cp_lines IS
        SELECT 	id subline_id, start_date, end_date, line_number subline_number, cle_id
           FROM 	okc_k_lines_b
           WHERE    dnz_chr_id = p_chr_id
           AND	cle_id IS NOT NULL
           AND lse_id = 9
           AND date_cancelled IS NULL  ; --Changes [llc]

    -- Checks if the item it's covering is a subscritpion item and then it gets
    -- the item instance
    CURSOR get_item_inst(subline_id NUMBER) IS
        SELECT  a.object1_id1
        FROM okc_k_items a, oks_subscr_header_b b
        WHERE  a.cle_id = subline_id
        AND b.instance_id = a.object1_id1;


    -- is item instance valid
    CURSOR get_subscr(instId NUMBER) IS
        SELECT  b.dnz_chr_id subscr_chr_id, b.cle_id subscr_line_id
        FROM okc_k_headers_all_b a, oks_subscr_header_b b
        WHERE  b.instance_id = instId AND b.dnz_chr_id = a.id AND
        (a.id = p_chr_id  OR (a.id <> p_chr_id  AND a.sts_code IN ('ACTIVE', 'SIGNED')) );

    -- See if the cp dates fall within the the subscription line start date, end date
    CURSOR check_effectivity(subscr_line_Id NUMBER, cpStartDate DATE, cpEndDate DATE) IS
        SELECT sts_code
        FROM okc_k_lines_b
        WHERE id = subscr_line_Id AND (cpStartDate BETWEEN start_date AND end_date)
        AND (cpEndDate BETWEEN start_date AND end_date) AND lse_id = 46 AND	cle_id IS NULL ;

    l_inst_id           NUMBER;
    l_subscr_chr_id    NUMBER;
    l_subscr_cle_id    NUMBER;
    l_valid_status  VARCHAR2(30);
    l_valid_dates   VARCHAR2(30);

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- Gets the sublines with covered products for p_chr_id
        FOR get_cp_rec IN get_cp_lines LOOP
            -- Gets the item instance
            OPEN get_item_inst(get_cp_rec.subline_id);
            FETCH get_item_inst INTO l_inst_id;
            IF get_item_inst%FOUND THEN
                OPEN get_subscr(l_inst_id);
                FETCH get_subscr INTO l_subscr_chr_id, l_subscr_cle_id;
                IF get_subscr%NOTFOUND THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_ITEM_INST_INVALID,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(get_cp_rec.subline_id));
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
                CLOSE get_subscr;
            END IF; -- get_item_inst%FOUND
            CLOSE get_item_inst;
        END LOOP;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF get_subscr%ISOPEN THEN
                CLOSE get_subscr;
            END IF;
            IF get_item_inst%ISOPEN THEN
                CLOSE get_item_inst;
            END IF;
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            -- notify caller of an error as UNEXPETED error
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END Check_item_instance_valid;

    /*============================================================================+
    | Procedure:           check_subscr_element_exist
    |
    | Purpose:             Please note that tangible items have a delivery
    |                      schedule therefore:
    |                      If the subscription line has a tangible item then it
    |                      should have at least one subscription
    |                      element(delivery schedule).
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_subscr_element_exist(p_chr_id IN NUMBER,
                                         x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR get_subscr_line IS
        SELECT id ,date_terminated  -- Added "date_terminated" for Bug 5702660
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_chr_id
        AND lse_id = 46
        AND date_cancelled IS NULL --Changes [llc]
        ;

    CURSOR is_tangible_item(cleId NUMBER) IS
        SELECT a.id
        FROM oks_subscr_header_b a
        WHERE a.cle_id = cleId AND a.dnz_chr_id = p_chr_id
        AND a.fulfillment_channel = 'OM';

    CURSOR get_subscr_element(oshId NUMBER, cleId NUMBER) IS
        SELECT b.id
        FROM oks_subscr_elements b
        WHERE b.dnz_cle_id = cleId AND b.dnz_chr_id = p_chr_id
        AND b.osh_id = oshId;

    l_sh_id             NUMBER;
    l_subscr_ele_id     NUMBER;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        FOR subscr_line_rec IN get_subscr_line LOOP
            OPEN is_tangible_item(subscr_line_rec.id);
            FETCH is_tangible_item INTO l_sh_id;
            IF is_tangible_item%FOUND THEN
                OPEN get_subscr_element(l_sh_id, subscr_line_rec.id);
                FETCH get_subscr_element INTO l_subscr_ele_id;
                --Bug 5702660. Added condition "subscr_line_rec.date_terminated is NULL"
                IF get_subscr_element%NOTFOUND and subscr_line_rec.date_terminated is NULL
                THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_SUBSCR_ELEM_MISS,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(subscr_line_rec.id));
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
                CLOSE get_subscr_element;
            END IF;
            CLOSE is_tangible_item;
        END LOOP;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF get_subscr_element%ISOPEN THEN
                CLOSE get_subscr_element;
            END IF;
            IF is_tangible_item%ISOPEN THEN
                CLOSE is_tangible_item;
            END IF;
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END check_subscr_element_exist;

    /*============================================================================+
    | Procedure:           check_subscr_is_shipable
    |
    | Purpose:             If subscription item is shipable then ship to rule and
    |                      ship to address is required for that subscription line.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_subscr_is_shipable(p_chr_id IN NUMBER,
                                       x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR get_subscr_lines IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = p_chr_id
        AND lse_id = 46
        AND date_cancelled IS NULL --Changes [llc]
        ;


    CURSOR get_shipable_flag(cleId NUMBER) IS
        SELECT SHIPPABLE_ITEM_FLAG
        FROM mtl_system_items a, okc_k_items b
        WHERE b.cle_id = cleId AND a.SHIPPABLE_ITEM_FLAG = 'Y'
        AND a.INVENTORY_ITEM_ID = b.object1_id1
        AND a.ORGANIZATION_ID = b.object1_id2;


    -- Get the ship to rule for the shipable subscription line.
    -- OBJECT1_ID1 of STO for lines only
    CURSOR get_ship_to_rule(cleId NUMBER) IS
        SELECT SHIP_TO_SITE_USE_ID
        FROM    OKC_K_LINES_B
        WHERE   id = cleId;


    -- Get the ship to address for shipable subscription line.
    -- have to use the okx view
    CURSOR ship_to_address(p_id IN VARCHAR2, Code VARCHAR2) IS
        SELECT  a.location_id
        FROM    Okx_cust_site_uses_v a
        WHERE   a.id1 = p_id
        AND     a.site_use_code = Code;

    l_shipable      VARCHAR2(1);
    l_ship_to_id    NUMBER;
    l_location_id   NUMBER;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- Loops through each subscription line and checks if it's items are shipable.
        FOR subscr_line_rec IN get_subscr_lines LOOP
            OPEN get_shipable_flag(subscr_line_rec.id);
            FETCH get_shipable_flag INTO l_shipable;
            IF get_shipable_flag%FOUND THEN
                -- since the subscription item is shipable it has to have a ship to rule.
                OPEN get_ship_to_rule(subscr_line_rec.id);
                FETCH get_ship_to_rule INTO l_ship_to_id;
                IF get_ship_to_rule%NOTFOUND THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_SHIP_RULE_MISS,
                                        p_token1 => 'LINE_NAME',
                                        p_token1_value => get_line_name(subscr_line_rec.id));
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                    OPEN  ship_to_address(l_ship_to_id, 'SHIP_TO');
                    FETCH ship_to_address INTO l_location_id;
                    IF ship_to_address%NOTFOUND THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_SHIP_ADDR_MISS,
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(subscr_line_rec.id));
                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;
                    CLOSE ship_to_address;
                END IF; -- get_ship_to_rule%NOTFOUND
                CLOSE get_ship_to_rule;
            END IF; -- get_shipable_flag%FOUND
            CLOSE get_shipable_flag;
        END LOOP;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF get_shipable_flag%ISOPEN THEN
                CLOSE get_shipable_flag;
            END IF;
            IF get_ship_to_rule%ISOPEN THEN
                CLOSE get_ship_to_rule;
            END IF;
            IF ship_to_address%ISOPEN THEN
                CLOSE  ship_to_address;
            END IF;

            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END check_subscr_is_shipable;

    /*============================================================================+
    | Procedure:           check_covered_product
    |
    | Purpose:             Will check the covered product quantity against
    |                      Installedbase.
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_covered_product(p_chr_id IN NUMBER,
                                    x_return_status OUT NOCOPY VARCHAR2) IS

    CURSOR Get_Covered_Prod(l_chr_id NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        WHERE lse_id IN (9, 25)
        AND dnz_chr_id = l_chr_id
        AND date_cancelled IS NULL --Changes [llc]
        ;

    CURSOR Get_Item_Inst(l_cp_line_id NUMBER) IS
        SELECT object1_id1, number_of_items, uom_code
        FROM okc_k_items
        WHERE cle_id = l_cp_line_id;

    l_item_inst  Get_Item_Inst%ROWTYPE;

    CURSOR is_subscr_item(l_inst_id NUMBER) IS
        SELECT  b.instance_id
        FROM oks_subscr_header_b b
        WHERE b.instance_id = l_inst_id;

    l_subscr_inst_id is_subscr_item%ROWTYPE;


    CURSOR Exact_Item_Inst(l_instance_id NUMBER) IS
        SELECT instance_id, quantity, unit_of_measure
        FROM csi_item_instances
        WHERE instance_id = l_instance_id;

    l_exact_item_inst Exact_Item_Inst%ROWTYPE;


    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        -- This will loop through all the covered product.
        -- A contract can have several covered products
        FOR get_cp_rec IN Get_Covered_Prod(p_chr_id) LOOP
            -- Will get the item_instace
            OPEN Get_Item_Inst(get_cp_rec.id);
            FETCH Get_Item_Inst INTO l_item_inst;
            CLOSE Get_Item_Inst;

            -- We won't do any checks if it's a subscription item.
            OPEN  is_subscr_item(l_item_inst.object1_id1);
            FETCH is_subscr_item INTO l_subscr_inst_id;
            IF is_subscr_item%NOTFOUND THEN
                -- Will try to find the item instance in installedbase
                OPEN Exact_Item_Inst(l_item_inst.object1_id1);
                FETCH Exact_Item_Inst INTO l_exact_item_inst;
                IF Exact_Item_Inst%NOTFOUND THEN
                    -- G_ITEM_INST_MISS = Item instance ITEM_INST for line LINE_NAME is not found in installedbase.
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_ITEM_INST_MISS,
                                        p_token1 => 'ITEM_INST',
                                        p_token1_value => l_item_inst.object1_id1,
                                        p_token2 => 'LINE_NAME',
                                        p_token2_value => get_line_name(get_cp_rec.id));
                    x_return_status := OKC_API.G_RET_STS_ERROR;
                ELSE
                    IF l_exact_item_inst.quantity <> l_item_inst.number_of_items
                        AND l_exact_item_inst.unit_of_measure <> l_item_inst.uom_code  THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_QUANT_UOM_INVALID,
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(get_cp_rec.id),
                                            p_token2 => 'QUANTITY',
                                            p_token2_value => l_exact_item_inst.quantity,
                                            p_token3 => 'UOM',
                                            p_token3_value => l_exact_item_inst.unit_of_measure);

                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    ELSIF l_exact_item_inst.quantity <> l_item_inst.number_of_items THEN
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_QUANT_INVALID,
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(get_cp_rec.id),
                                            p_token2 => 'QUANTITY',
                                            p_token2_value => l_exact_item_inst.quantity);

                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    ELSIF l_exact_item_inst.unit_of_measure <> l_item_inst.uom_code THEN
                        -- G_UOM_INVALID: Covered product unit of measure on line LINE_NAME does not match the value UOM stored in installedbase.
                        OKC_API.set_message(
                                            p_app_name => G_APP_NAME,
                                            p_msg_name => G_UOM_INVALID,
                                            p_token1 => 'LINE_NAME',
                                            p_token1_value => get_line_name(get_cp_rec.id),
                                            p_token2 => 'UOM',
                                            p_token2_value => l_exact_item_inst.unit_of_measure);

                        x_return_status := OKC_API.G_RET_STS_ERROR;
                    END IF;
                END IF;
                CLOSE Exact_Item_Inst;
            END IF;
            CLOSE is_subscr_item;

        END LOOP;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS
            THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

            IF Exact_Item_Inst%ISOPEN THEN
                CLOSE Exact_Item_Inst;
            END IF;
            IF is_subscr_item%ISOPEN THEN
                CLOSE is_subscr_item;
            END IF;

    END check_covered_product;

    /*============================================================================+
    | Procedure:           check_required_PM
    |
    | Purpose:             Check Required Values for Preventive Maintenance
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_required_PM(p_chr_id IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
    IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        OKS_PM_PROGRAMS_PVT.CHECK_PM_REQUIRED_VALUES(x_return_status => l_return_status,
                                                     p_chr_id => p_chr_id);

        x_return_status := l_return_status;


        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END check_required_PM;

    /*============================================================================+
    | Procedure:           check_price_lock
    |
    | Purpose:             Checks if price lock has been carried over from
    |                      original contract
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/
    PROCEDURE check_pirce_lock(p_chr_id IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2)
    IS

    CURSOR get_old_chr_id(l_chr_id NUMBER) IS
        SELECT orig_system_id1
        FROM okc_k_headers_all_b
        WHERE id = l_chr_id
        AND datetime_cancelled IS NULL; --Changes [llc]

    -- Gets old line id's that have a lock
    CURSOR get_old_line_id(l_old_chr_id NUMBER) IS
        SELECT b.cle_id
        FROM okc_k_lines_b a, oks_k_lines_b b
        WHERE a.id = b.cle_id
        AND b.dnz_chr_id = l_old_chr_id
        AND b.dnz_chr_id = a.dnz_chr_id
        AND a.lse_id IN (12, 13)
        AND b.LOCKED_PRICE_LIST_ID IS NOT NULL
        AND b.LOCKED_PRICE_LIST_LINE_ID IS NOT NULL
        AND a.date_cancelled IS NULL --Changes [llc]
        ;
    --and b.prorate is not null; -- prorate is not mandatory

    CURSOR get_new_line_id(l_chr_id NUMBER, l_old_line_id NUMBER) IS
        SELECT id
        FROM okc_k_lines_b
        WHERE dnz_chr_id = l_chr_id
        AND lse_id IN (12, 13)
        AND orig_system_id1 = l_old_line_id;

    CURSOR check_lock(l_chr_id NUMBER, l_cle_id NUMBER) IS
        SELECT cle_id
        FROM oks_k_lines_b
        WHERE dnz_chr_id = l_chr_id
        AND cle_id = l_cle_id
        AND LOCKED_PRICE_LIST_ID IS NOT NULL
        AND LOCKED_PRICE_LIST_LINE_ID IS NOT NULL;
    --and prorate is not null; -- prorate is not mandatory

    l_old_chr_id NUMBER;
    l_id NUMBER;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
        l_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN get_old_chr_id(p_chr_id);
        FETCH get_old_chr_id INTO l_old_chr_id;
        CLOSE get_old_chr_id;

        FOR get_old_id_rec IN  get_old_line_id(l_old_chr_id)
            LOOP
            FOR get_new_id_rec IN get_new_line_id(p_chr_id, get_old_id_rec.cle_id)
                LOOP
                OPEN check_lock(p_chr_id, get_new_id_rec.id);
                FETCH check_lock INTO l_id;
                IF check_lock%NOTFOUND THEN
                    OKC_API.set_message(
                                        p_app_name => G_APP_NAME,
                                        p_msg_name => G_MISS_PRICE_LOCK,
                                        p_token1 => 'NEW_LINE',
                                        p_token1_value => get_line_number(get_new_id_rec.id),
                                        p_token2 => 'CONTRACT_NAME',
                                        p_token2_value => get_contract_name(l_old_chr_id),
                                        p_token3 => 'OLD_LINE',
                                        p_token3_value => get_line_number(get_old_id_rec.cle_id)
                                        );
                    l_return_status := OKC_API.G_RET_STS_ERROR;
                END IF;
                CLOSE check_lock;
            END LOOP;

        END LOOP;
        x_return_status := l_return_status;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    END check_pirce_lock;


    --[llc]

    /*============================================================================+
    | Procedure:           Check_Ren_Source_Lines
    |
    | Purpose:             Checks if source lines has lines with renewal
    |                      relationships to lines on original transferred contract
    |                      that are not in a status of Active, Signed, Hold or Expired
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/

    PROCEDURE Check_Ren_Source_Lines (p_chr_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2)

    IS

    l_dummy_data NUMBER;
    l_dummy_msg VARCHAR2(200);

    CURSOR cur_renewal_source_lines (p_chr_id NUMBER) IS
        SELECT 1
        FROM    okc_operation_lines a, okc_operation_instances b, okc_class_operations  c, okc_k_headers_all_b  d, okc_statuses_b e
        WHERE	a.subject_chr_id = p_chr_id
                AND c.id = b.cop_id
                AND c.opn_code IN('RENEWAL', 'REN_CON')
                AND a.oie_id = b.id
                AND a.active_yn = 'Y'
                AND a.object_chr_id = d.id
                AND e.code = d.sts_code
                AND e.ste_code NOT IN ('ACTIVE', 'SIGNED', 'HOLD', 'EXPIRED');


    BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN cur_renewal_source_lines (p_chr_id);
        FETCH cur_renewal_source_lines INTO l_dummy_data;

        IF cur_renewal_source_lines%FOUND THEN

            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_CHECK_REN_SOURCE_LINES'
                                );
            -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;

        END IF;

        CLOSE cur_renewal_source_lines;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END Check_Ren_Source_Lines;


    --[llc]


    /*============================================================================+
    | Procedure:           Check_Ren_Target_Lines
    |
    | Purpose:             Check to see if cancelled lines have a renewal
    |                      relationship to lines on a target contract
    |
    | In Parameters:       p_chr_id            the contract id
    | Out Parameters:      x_return_status     standard return status
    |
    +============================================================================*/

    PROCEDURE Check_Ren_Target_Lines (p_chr_id IN NUMBER,
                                      x_return_status OUT NOCOPY VARCHAR2)

    IS

    l_dummy_data NUMBER;
    l_target_contract_id    NUMBER;
    l_subject_cle_id    NUMBER;
    l_target_line_number    NUMBER;
    l_target_contract_number    VARCHAR2(120);
    l_line_number   NUMBER;
    l_subline_number    VARCHAR2(100);
    l_target_subline_number VARCHAR2(100);


    CURSOR cur_is_K_renewed IS
        SELECT	d.id target_contract_id
        FROM	okc_operation_lines a, okc_operation_instances b, okc_class_operations  c, okc_k_headers_all_b  d, okc_statuses_b e
        WHERE	a.object_chr_id = p_chr_id
        AND	c.id = b.cop_id
        AND	c.opn_code IN('RENEWAL', 'REN_CON')
        AND	a.oie_id = b.id
        AND	a.active_yn = 'Y'
        AND	a.subject_chr_id = d.id
        AND	e.code = d.sts_code
        AND	e.ste_code NOT IN ('ACTIVE', 'SIGNED', 'HOLD', 'EXPIRED');

    CURSOR cur_lines_status IS
        SELECT	b.id, b.line_number, s.ste_code
        FROM	okc_k_lines_b  b, okc_statuses_b s
        WHERE	dnz_chr_id = p_chr_id
        AND		cle_id IS NULL
        AND		s.code = b.sts_code;


    CURSOR cur_sublines_status(p_cle_id NUMBER) IS
        SELECT	b.id, b.line_number, s.ste_code
        FROM	okc_k_lines_b b, okc_statuses_b s
        WHERE	cle_id = p_cle_id
        AND	s.code = b.sts_code
        AND	s.ste_code = 'CANCELLED';


    CURSOR cur_is_subline_renewed (p_cle_id NUMBER) IS
        SELECT	subject_cle_id
        FROM	okc_operation_lines
        WHERE	object_cle_id = p_cle_id;


    CURSOR cur_is_topline_renewed (p_cle_id NUMBER) IS
        SELECT subject_cle_id
        FROM okc_operation_lines a, okc_operation_instances b, okc_class_operations  c, okc_k_lines_b  d
        WHERE a.object_cle_id = d.id
        AND a.object_chr_id = d.dnz_chr_id
        AND d.cle_id = p_cle_id -- should be a top line id
        AND a.object_chr_id = p_chr_id
        AND c.id = b.cop_id
        AND c.opn_code IN('RENEWAL', 'REN_CON')
        AND a.oie_id = b.id
        AND a.active_yn = 'Y';


    CURSOR cur_target_contract_number (p_contract_id NUMBER) IS
        SELECT	contract_number
        FROM	okc_k_headers_all_b
        WHERE	id = p_contract_id;

    CURSOR cur_target_line_number (p_cle_id NUMBER) IS
        SELECT	line_number
        FROM	okc_k_lines_b
        WHERE	id = p_cle_id;

    CURSOR  cur_target_subline_number (p_cle_id NUMBER) IS
        SELECT	lines2.line_number || '.' || lines1.line_number
        FROM	okc_k_lines_b lines1, okc_k_lines_b lines2
        WHERE	lines1.id = p_cle_id
        AND	lines1.cle_id = lines2.id;



    BEGIN

        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        OPEN cur_is_K_renewed;
        FETCH cur_is_K_renewed INTO l_target_contract_id;

        IF cur_is_K_renewed %FOUND THEN
            OPEN cur_target_contract_number (l_target_contract_id);
            FETCH cur_target_contract_number INTO l_target_contract_number;
            CLOSE cur_target_contract_number;

            FOR  k_cur_lines_status_rec IN cur_lines_status
                LOOP

                IF  k_cur_lines_status_rec.ste_code = 'CANCELLED' THEN

                    OPEN cur_is_topline_renewed(k_cur_lines_status_rec.id);
                    FETCH cur_is_topline_renewed INTO l_subject_cle_id;

                    IF cur_is_topline_renewed%FOUND THEN

                        OPEN cur_target_line_number(l_subject_cle_id);
                        FETCH cur_target_line_number INTO l_target_line_number;
                        CLOSE cur_target_line_number;

                        OKC_API.SET_MESSAGE
                        (
                         p_app_name => G_APP_NAME,
                         p_msg_name => 'OKS_CHECK_REN_TARGET_LINES',
                         p_token1 => 'CURRENT_LINE_NUM',
                         p_token1_value => k_cur_lines_status_rec.line_number,
                         p_token2 => 'TARGET_LINE_NUM',
                         p_token2_value => l_target_line_number,
                         p_token3 => 'TARGET_CONTRACT_NUM',
                         p_token3_value => l_target_contract_number
                         );

                        x_return_status := OKC_API.G_RET_STS_ERROR;

                    END IF; --cur_is_topline_renewed%FOUND
                    CLOSE cur_is_topline_renewed;

                ELSE

                    OPEN cur_sublines_status(k_cur_lines_status_rec.id);

                    IF cur_sublines_status%NOTFOUND THEN
                        CLOSE cur_sublines_status;
                    ELSE
                        CLOSE cur_sublines_status;

                        FOR k_cur_sublines_status_rec IN cur_sublines_status(k_cur_lines_status_rec.id)
                            LOOP

                            OPEN cur_is_subline_renewed(k_cur_sublines_status_rec.id);
                            FETCH cur_is_subline_renewed INTO l_subject_cle_id;

                            IF cur_is_subline_renewed%FOUND THEN
                                l_subline_number := k_cur_lines_status_rec.line_number || '.' || k_cur_sublines_status_rec.line_number;

                                OPEN cur_target_line_number(l_subject_cle_id);
                                FETCH cur_target_line_number INTO l_target_line_number;
                                CLOSE cur_target_line_number;

                                OPEN cur_target_subline_number(l_subject_cle_id);
                                FETCH cur_target_subline_number INTO l_target_subline_number;
                                CLOSE cur_target_subline_number;


                                OKC_API.SET_MESSAGE
                                (
                                 p_app_name => G_APP_NAME,
                                 p_msg_name => 'OKS_CHECK_REN_TARGET_LINES',
                                 p_token1 => 'CURRENT_LINE_NUM',
                                 p_token1_value => l_subline_number,
                                 p_token2 => 'TARGET_LINE_NUM',
                                 p_token2_value => l_target_subline_number,
                                 p_token3 => 'TARGET_CONTRACT_NUM',
                                 p_token3_value => l_target_contract_number
                                 );

                                x_return_status := OKC_API.G_RET_STS_ERROR;

                            END IF;
                            CLOSE cur_is_subline_renewed;

                        END LOOP;

                    END IF; -- cur_sublines_status%NOTFOUND

                END IF; --k_cur_lines_status_rec.ste_code='CANCELLED'

            END LOOP;

        END IF; --cur_is_K_renewed %FOUND
        CLOSE cur_is_K_renewed;

        IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            OKC_API.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKS_QA_SUCCESS');

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- store SQL error message on message stack
            OKC_API.SET_MESSAGE(
                                p_app_name => G_APP_NAME,
                                p_msg_name => G_UNEXPECTED_ERROR,
                                p_token1 => G_SQLCODE_TOKEN,
                                p_token1_value => SQLCODE,
                                p_token2 => G_SQLERRM_TOKEN,
                                p_token2_value => SQLERRM);

            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END Check_Ren_Target_Lines;




END OKS_QA_DATA_INTEGRITY;

/
