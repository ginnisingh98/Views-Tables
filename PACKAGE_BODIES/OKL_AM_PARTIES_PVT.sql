--------------------------------------------------------
--  DDL for Package Body OKL_AM_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PARTIES_PVT" AS
/* $Header: OKLRAMPB.pls 120.9 2007/12/18 09:16:08 ansethur noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------

-- GLOBAL VARIABLES
  G_LEVEL_PROCEDURE             CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT             CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_EXCEPTION             CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_MODULE_NAME                 CONSTANT VARCHAR2(500) := 'okl.am.plsql.okl_am_parties_pvt.';

  SUBTYPE taiv_rec_type IS okl_trx_ar_invoices_pub.taiv_rec_type;


-- Start of comments
--
-- Procedure Name       : get_contract_party
-- Description          : Return contract parties for a role
-- Business Rules       :
-- Parameters           : contract, role code
-- Version              : 1.0
-- End of comments

PROCEDURE get_contract_party (
        p_contract_id           IN NUMBER,
        p_role_code             IN VARCHAR2,
        x_qpyv_tbl              OUT NOCOPY qpyv_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        l_qpyv_tbl              qpyv_tbl_type;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_cnt                   NUMBER          := 0;

        CURSOR l_k_party_role_csr (
                cp_role_code    VARCHAR2,
                cp_contract_id  NUMBER) IS
                SELECT  pr.id                   cpl_id,
                        pr.jtot_object1_code    object1_code,
                        pr.object1_id1          object1_id1,
                        pr.object1_id2          object1_id2
                FROM    okc_k_party_roles_b     pr
                WHERE   pr.rle_code             = cp_role_code
                AND     pr.cle_id               IS NULL
                AND     pr.chr_id               = cp_contract_id
                AND     pr.dnz_chr_id           = cp_contract_id
                AND     rownum                  = 1; -- Only return 1st party


-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_contract_party';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_contract_id :'||p_contract_id);
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_role_code :'||p_role_code);
   END IF;

        FOR l_k_role_rec IN l_k_party_role_csr (p_role_code, p_contract_id)
        LOOP
                l_cnt := l_cnt + 1;
                l_qpyv_tbl(l_cnt).cpl_id                  := l_k_role_rec.cpl_id;
                l_qpyv_tbl(l_cnt).party_jtot_object1_code := l_k_role_rec.object1_code;
                l_qpyv_tbl(l_cnt).party_object1_id1       := l_k_role_rec.object1_id1;
                l_qpyv_tbl(l_cnt).party_object1_id2       := l_k_role_rec.object1_id2;
        END LOOP;

        x_qpyv_tbl              := l_qpyv_tbl;
        x_return_status         := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN
                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;
                -- Close open cursors
                IF l_k_party_role_csr%ISOPEN THEN
                        CLOSE l_k_party_role_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_contract_party;


-- Start of comments
--
-- Procedure Name       : get_quote_party
-- Description          : Return quote party based on setup rules
-- Business Rules       :
-- Parameters           : contract, rule group, rule code, quote role
-- Version              : 1.0
-- End of comments

PROCEDURE get_quote_party (
        p_contract_id           IN NUMBER,
        p_rule_chr_id           IN NUMBER,
        p_rgd_code              IN VARCHAR2,
        p_rdf_code              IN VARCHAR2,
        p_qpt_code              IN VARCHAR2,
        px_qpyv_tbl             IN OUT NOCOPY qpyv_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        l_rulv_rec              okl_rule_pub.rulv_rec_type;
        l_qpyv_tbl              qpyv_tbl_type;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_date_sent             DATE            := SYSDATE;
        l_k_cnt                 NUMBER;
        l_q_cnt                 NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_quote_party';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_contract_id :'||p_contract_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_rule_chr_id :'||p_rule_chr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_rgd_code :'||p_rgd_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_rdf_code :'||p_rdf_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qpt_code :'||p_qpt_code);
   END IF;

        okl_am_util_pvt.get_rule_record (
                p_rgd_code      => p_rgd_code,
                p_rdf_code      => p_rdf_code,
                p_chr_id        => p_rule_chr_id,
                p_cle_id        => NULL,
                x_rulv_rec      => l_rulv_rec,
                x_return_status => l_return_status,
                p_message_yn    => FALSE);

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
       'after call to okl_am_util_pvt.get_rule_record :'||l_return_status);
   END IF;

        IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
            IF  l_rulv_rec.rule_information1 IS NOT NULL
            AND l_rulv_rec.rule_information1 <> G_MISS_CHAR THEN
                get_contract_party (
                        p_contract_id   => p_contract_id,
                        p_role_code     => l_rulv_rec.rule_information1,
                        x_qpyv_tbl      => l_qpyv_tbl,
                        x_return_status => l_return_status);
            ELSE
                l_return_status := OKL_API.G_RET_STS_ERROR;
            END IF;
        END IF;

        -- No parties found - create empty row
        IF l_qpyv_tbl.COUNT = 0 THEN
                l_qpyv_tbl(1).cpl_id := NULL;
                l_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;

        FOR l_k_cnt IN l_qpyv_tbl.FIRST..l_qpyv_tbl.LAST LOOP

                l_qpyv_tbl(l_k_cnt).date_sent   := l_date_sent;
                l_qpyv_tbl(l_k_cnt).qpt_code    := p_qpt_code;

                IF l_rulv_rec.rule_information2 <> G_MISS_CHAR THEN
                    IF    p_qpt_code = 'ADVANCE_NOTICE' THEN
                        l_qpyv_tbl(l_k_cnt).delay_days := l_rulv_rec.rule_information2;
                    ELSIF p_qpt_code = 'RECIPIENT_ADDITIONAL' THEN
                        l_qpyv_tbl(l_k_cnt).allocation_percentage := l_rulv_rec.rule_information2;
                    END IF;
                END IF;

                l_q_cnt := NVL (px_qpyv_tbl.COUNT, 0) + 1;
                px_qpyv_tbl(l_q_cnt) := l_qpyv_tbl(l_k_cnt);

        END LOOP;

        x_return_status := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;
                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_quote_party;


-- Start of comments
--
-- Procedure Name       : get_rule_quote_parties
-- Description          : Determine all quote parties using setup rules
-- Business Rules       :
-- Parameters           : contract id, optional quote id
-- Version              : 1.0
-- End of comments

PROCEDURE get_rule_quote_parties (
        p_qtev_rec              IN  qtev_rec_type,
        x_qpyv_tbl              OUT NOCOPY qpyv_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        l_qpyv_tbl              qpyv_tbl_type;
        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

        l_contract_id           NUMBER := p_qtev_rec.khr_id;
        l_rule_chr_id           NUMBER;

        l_recipient_rg          VARCHAR2(30);
        l_approver_rg           VARCHAR2(30);
        l_cou_copy_rg           VARCHAR2(30);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_rule_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'after call to get_rule_quote_parties  :'||l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.id : '||p_qtev_rec.id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qrs_code : '||p_qtev_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qst_code : '||p_qtev_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_qte_id : '||p_qtev_rec.consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.khr_id : '||p_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.art_id : '||p_qtev_rec.art_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qtp_code : '||p_qtev_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.trn_code : '||p_qtev_rec.trn_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.pdt_id : '||p_qtev_rec.pdt_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.date_effective_from : '||p_qtev_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.quote_number : '||p_qtev_rec.quote_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.early_termination_yn : '||p_qtev_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.partial_yn : '||p_qtev_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.preproceeds_yn : '||p_qtev_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.summary_format_yn : '||p_qtev_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_yn : '||p_qtev_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.payment_received_yn : '||p_qtev_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.requested_by : '||p_qtev_rec.requested_by);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.approved_yn : '||p_qtev_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.accepted_yn : '||p_qtev_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.org_id : '||p_qtev_rec.org_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.legal_entity_id : '||p_qtev_rec.legal_entity_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.repo_quote_indicator_yn : '||p_qtev_rec.repo_quote_indicator_yn);
   END IF;

        IF l_contract_id IS NULL
        OR l_contract_id = G_MISS_NUM THEN

                l_overall_status := OKL_API.G_RET_STS_ERROR;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'CONTRACT_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'GET_RULE_QUOTE_PARTIES');

        END IF;

        l_rule_chr_id := okl_am_util_pvt.get_rule_chr_id (p_qtev_rec);

        IF p_qtev_rec.qtp_code LIKE 'TER_RECOURSE%' THEN
                l_recipient_rg  := 'AVQR1R';
                l_approver_rg   := 'AVQR5A';
                l_cou_copy_rg   := 'AVQR9F';
        ELSE
                l_recipient_rg  := 'AMQR1R';
                l_approver_rg   := 'AMQR5A';
                l_cou_copy_rg   := 'AMQR9F';
        END IF;

        IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            get_quote_party (
                p_contract_id   => l_contract_id,
                p_rule_chr_id   => l_rule_chr_id,
                p_rgd_code      => l_recipient_rg,
                p_rdf_code      => 'AMLCRO',
                p_qpt_code      => 'RECIPIENT',
                px_qpyv_tbl     => l_qpyv_tbl,
                x_return_status => l_return_status);


           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_quote_party :'||l_return_status);
           END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS
            OR l_qpyv_tbl.COUNT = 0 THEN
                okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_QTE_RECIPIENT_NOT_FOUND'
                        ,p_token1       => 'QUOTE_PARTY_TYPE'
                        ,p_token1_value => 'RECIPIENT');
            END IF;

            get_quote_party (
                p_contract_id   => l_contract_id,
                p_rule_chr_id   => l_rule_chr_id,
                p_rgd_code      => l_recipient_rg,
                p_rdf_code      => 'AMLCRP',
                p_qpt_code      => 'RECIPIENT_ADDITIONAL',
                px_qpyv_tbl     => l_qpyv_tbl,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_quote_party 1 :'||l_return_status);
           END IF;

            get_quote_party (
                p_contract_id   => l_contract_id,
                p_rule_chr_id   => l_rule_chr_id,
                p_rgd_code      => l_approver_rg,
                p_rdf_code      => 'AMLCAP',
                p_qpt_code      => 'APPROVER',
                px_qpyv_tbl     => l_qpyv_tbl,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_quote_party 2 :'||l_return_status);
           END IF;

            get_quote_party (
                p_contract_id   => l_contract_id,
                p_rule_chr_id   => l_rule_chr_id,
                p_rgd_code      => l_approver_rg,
                p_rdf_code      => 'AMLCAV',
                p_qpt_code      => 'ADVANCE_NOTICE',
                px_qpyv_tbl     => l_qpyv_tbl,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_quote_party 3 :'||l_return_status);
           END IF;

            get_quote_party (
                p_contract_id   => l_contract_id,
                p_rule_chr_id   => l_rule_chr_id,
                p_rgd_code      => l_cou_copy_rg,
                p_rdf_code      => 'AMLCCO',
                p_qpt_code      => 'FYI',
                px_qpyv_tbl     => l_qpyv_tbl,
                x_return_status => l_return_status);

           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_quote_party 4 :'||l_return_status);
           END IF;

        END IF;

        x_qpyv_tbl              := l_qpyv_tbl;
        x_return_status         := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_rule_quote_parties;


-- Start of comments
--
-- Procedure Name       : fetch_rule_quote_parties
-- Description          : Return quote parties using setup rules
-- Business Rules       :
-- Parameters           : contract_id
-- Version              : 1.0
-- End of comments

PROCEDURE fetch_rule_quote_parties (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_qtev_rec              IN  qtev_rec_type,
        x_qpyv_tbl              OUT NOCOPY qpyv_tbl_type,
        x_q_party_uv_tbl        OUT NOCOPY q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER) IS

        l_q_party_tbl           q_party_uv_tbl_type;
        l_object_tbl            okl_am_util_pvt.jtf_object_tbl_type;
        l_qpyv_tbl              qpyv_tbl_type;
        l_cnt                   NUMBER          := 0;

        CURSOR l_q_party_role_csr (
                        cp_cpl_id               NUMBER,
                        cp_khr_id               NUMBER,
                        cp_qpt_code             VARCHAR2) IS
                SELECT  kh.buy_or_sell          k_buy_or_sell,
                        lq.meaning              qp_party_role,
                        pr.rle_code             kp_role_code,
                        lk.meaning              kp_party_role
                FROM    okc_k_party_roles_b     pr,
                        okc_k_headers_b         kh,
                        fnd_lookups             lq,
                        fnd_lookups             lk
                WHERE   pr.id                   = cp_cpl_id
                AND     kh.id                   = cp_khr_id
                AND     kh.id                   = pr.chr_id
                AND     lq.lookup_code          = cp_qpt_code
                AND     lq.lookup_type          = 'OKL_QUOTE_PARTY_TYPE'
                AND     lk.lookup_code          = pr.rle_code
                AND     lk.lookup_type          = 'OKC_ROLE';

        CURSOR l_q_no_party_csr (
                        cp_khr_id               NUMBER,
                        cp_qpt_code             VARCHAR2) IS
                SELECT  kh.buy_or_sell          k_buy_or_sell,
                        lq.meaning              qp_party_role
                FROM    okc_k_headers_v         kh,
                        fnd_lookups             lq
                WHERE   kh.id                   = cp_khr_id
                AND     lq.lookup_code          = cp_qpt_code
                AND     lq.lookup_type          = 'OKL_QUOTE_PARTY_TYPE';

        l_q_role_rec            l_q_party_role_csr%ROWTYPE;
        l_q_no_role_rec         l_q_no_party_csr%ROWTYPE;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

        l_api_name              CONSTANT VARCHAR2(30)   := 'fetch_rule_quote_parties';
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);
        l_contract_id           NUMBER          := p_qtev_rec.khr_id;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'fetch_rule_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'after call to get_rule_quote_parties  :'||l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.id : '||p_qtev_rec.id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qrs_code : '||p_qtev_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qst_code : '||p_qtev_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_qte_id : '||p_qtev_rec.consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.khr_id : '||p_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.art_id : '||p_qtev_rec.art_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qtp_code : '||p_qtev_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.trn_code : '||p_qtev_rec.trn_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.pdt_id : '||p_qtev_rec.pdt_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.date_effective_from : '||p_qtev_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.quote_number : '||p_qtev_rec.quote_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.early_termination_yn : '||p_qtev_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.partial_yn : '||p_qtev_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.preproceeds_yn : '||p_qtev_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.summary_format_yn : '||p_qtev_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_yn : '||p_qtev_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.payment_received_yn : '||p_qtev_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.requested_by : '||p_qtev_rec.requested_by);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.approved_yn : '||p_qtev_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.accepted_yn : '||p_qtev_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.org_id : '||p_qtev_rec.org_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.legal_entity_id : '||p_qtev_rec.legal_entity_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.repo_quote_indicator_yn : '||p_qtev_rec.repo_quote_indicator_yn);
   END IF;

        -- ***************************************************************
        -- Check API version, initialize message list and create savepoint
        -- ***************************************************************

        l_return_status := OKL_API.START_ACTIVITY (
                l_api_name,
                G_PKG_NAME,
                p_init_msg_list,
                l_api_version,
                p_api_version,
                '_PVT',
                x_return_status);

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- ***********************************
        -- Extract parties from contract rules
        -- ***********************************

        get_rule_quote_parties (
                p_qtev_rec      => p_qtev_rec,
                x_qpyv_tbl      => l_qpyv_tbl,
                x_return_status => l_return_status);


           IF (is_debug_statement_on) THEN
               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
               'after call to get_rule_quote_parties  :'||l_return_status);
           END IF;

        -- Errors are acceptable
        -- IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        --      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        -- ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        --      RAISE OKL_API.G_EXCEPTION_ERROR;
        -- END IF;

        -- ********************
        -- Process every record
        -- ********************

        IF l_qpyv_tbl.COUNT > 0 THEN

            FOR i IN l_qpyv_tbl.FIRST..l_qpyv_tbl.LAST LOOP

                l_q_role_rec.kp_role_code := NULL;

                OPEN    l_q_party_role_csr (
                        l_qpyv_tbl(i).cpl_id, l_contract_id, l_qpyv_tbl(i).qpt_code);
                FETCH   l_q_party_role_csr INTO l_q_role_rec;
                CLOSE   l_q_party_role_csr;

                IF l_q_role_rec.kp_role_code IS NOT NULL THEN

                    -- Get Party Object
                    okl_am_util_pvt.get_object_details (
                        p_object_code   => l_qpyv_tbl(i).party_jtot_object1_code,
                        p_object_id1    => l_qpyv_tbl(i).party_object1_id1,
                        p_object_id2    => l_qpyv_tbl(i).party_object1_id2,
                        x_object_tbl    => l_object_tbl,
                        x_return_status => l_return_status);

                           IF (is_debug_statement_on) THEN
                               OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                               'after call to okl_am_util_pvt.get_object_details :'||l_return_status);
                           END IF;

                    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_object_tbl.COUNT > 0 THEN
                        FOR l_ind IN l_object_tbl.FIRST..l_object_tbl.LAST LOOP
                            -- Party Object is found
                            l_cnt := l_cnt + 1;
                            l_q_party_tbl(l_cnt).contract_id    := l_contract_id;
                            l_q_party_tbl(l_cnt).kp_party_id    := l_qpyv_tbl(i).cpl_id;
                            l_q_party_tbl(l_cnt).qp_role_code   := l_qpyv_tbl(i).qpt_code;
                            l_q_party_tbl(l_cnt).k_buy_or_sell  := l_q_role_rec.k_buy_or_sell;
                            l_q_party_tbl(l_cnt).qp_party_role  := l_q_role_rec.qp_party_role;
                            l_q_party_tbl(l_cnt).kp_role_code   := l_q_role_rec.kp_role_code;
                            l_q_party_tbl(l_cnt).kp_party_role  := l_q_role_rec.kp_party_role;
                            l_q_party_tbl(l_cnt).po_party_id1   := l_object_tbl(l_ind).id1;
                            l_q_party_tbl(l_cnt).po_party_id2   := l_object_tbl(l_ind).id2;
                            l_q_party_tbl(l_cnt).po_party_object := l_object_tbl(l_ind).object_code;
                            l_q_party_tbl(l_cnt).po_party_name  := l_object_tbl(l_ind).name;
                            l_q_party_tbl(l_cnt).po_party_desc  := l_object_tbl(l_ind).description;
                        END LOOP;
                    ELSE
                            -- Party Object is not found
                            l_cnt := l_cnt + 1;
                            l_q_party_tbl(l_cnt).contract_id    := l_contract_id;
                            l_q_party_tbl(l_cnt).kp_party_id    := l_qpyv_tbl(i).cpl_id;
                            l_q_party_tbl(l_cnt).qp_role_code   := l_qpyv_tbl(i).qpt_code;
                            l_q_party_tbl(l_cnt).k_buy_or_sell  := l_q_role_rec.k_buy_or_sell;
                            l_q_party_tbl(l_cnt).qp_party_role  := l_q_role_rec.qp_party_role;
                            l_q_party_tbl(l_cnt).kp_role_code   := l_q_role_rec.kp_role_code;
                            l_q_party_tbl(l_cnt).kp_party_role  := l_q_role_rec.kp_party_role;
                            l_q_party_tbl(l_cnt).po_party_id1   := l_qpyv_tbl(i).party_jtot_object1_code;
                            l_q_party_tbl(l_cnt).po_party_id2   := l_qpyv_tbl(i).party_object1_id1;
                            l_q_party_tbl(l_cnt).po_party_object := l_qpyv_tbl(i).party_object1_id2;
                            l_q_party_tbl(l_cnt).po_party_name  := NULL;
                            l_q_party_tbl(l_cnt).po_party_desc  := NULL;
                    END IF;

                ELSE

                            OPEN        l_q_no_party_csr (l_contract_id, l_qpyv_tbl(i).qpt_code);
                            FETCH       l_q_no_party_csr INTO l_q_no_role_rec;
                            CLOSE       l_q_no_party_csr;

                            -- Party Role is not found
                            l_cnt := l_cnt + 1;
                            l_q_party_tbl(l_cnt).contract_id    := l_contract_id;
                            l_q_party_tbl(l_cnt).kp_party_id    := l_qpyv_tbl(i).cpl_id;
                            l_q_party_tbl(l_cnt).qp_role_code   := l_qpyv_tbl(i).qpt_code;
                            l_q_party_tbl(l_cnt).k_buy_or_sell  := l_q_no_role_rec.k_buy_or_sell;
                            l_q_party_tbl(l_cnt).qp_party_role  := l_q_no_role_rec.qp_party_role;
                            l_q_party_tbl(l_cnt).kp_role_code   := NULL;
                            l_q_party_tbl(l_cnt).kp_party_role  := NULL;
                            l_q_party_tbl(l_cnt).po_party_id1   := NULL;
                            l_q_party_tbl(l_cnt).po_party_id2   := NULL;
                            l_q_party_tbl(l_cnt).po_party_object := NULL;
                            l_q_party_tbl(l_cnt).po_party_name  := NULL;
                            l_q_party_tbl(l_cnt).po_party_desc  := NULL;

                END IF;

            END LOOP;

        END IF;

        -- **************
        -- Return results
        -- **************

        x_record_count          := l_q_party_tbl.COUNT;
        x_q_party_uv_tbl        := l_q_party_tbl;
        x_qpyv_tbl              := l_qpyv_tbl;
        x_return_status         := l_overall_status;

        OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OKL_API.G_EXCEPTION_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'USER DEFINED');
        END IF;

                x_return_status := OKL_API.HANDLE_EXCEPTIONS
                        (
                        l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT'
                        );

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'UNEXPECTED');
        END IF;

                x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                        (
                        l_api_name,
                        G_PKG_NAME,
                        'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PVT'
                        );

        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

                -- Close open cursors
                IF l_q_party_role_csr%ISOPEN THEN
                        CLOSE l_q_party_role_csr;
                END IF;

                IF l_q_no_party_csr%ISOPEN THEN
                        CLOSE l_q_no_party_csr;
                END IF;

                x_return_status :=OKL_API.HANDLE_EXCEPTIONS
                        (
                        l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PVT'
                        );

END fetch_rule_quote_parties;


-- Start of comments
--
-- Procedure Name       : create_partner_as_recipient
-- Description          : Assign a vendor partner as a quote recipient
-- Business Rules       :
-- Parameters           : quote_id and contract_id
-- Version              : 1.0
-- End of comments

PROCEDURE create_partner_as_recipient (
        p_qtev_rec              IN  qtev_rec_type,
        p_validate_only         IN  BOOLEAN,
        x_qpyv_tbl              OUT NOCOPY qpyv_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        lp_qpyv_tbl             qpyv_tbl_type;
        lx_qpyv_tbl             qpyv_tbl_type;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);

        -- Get contract program partner
        CURSOR l_partner_csr (cp_chr_id NUMBER) IS
                SELECT  khr.id                  khr_id,
                        par.id                  par_id,
                        kpr.id                  kpr_id,
                        kpr.jtot_object1_code   object1_code,
                        kpr.object1_id1         object1_id1,
                        kpr.object1_id2         object1_id2
                FROM    okl_k_headers           khr,
                        okc_k_headers_all_b     par,
                        okc_k_party_roles_b     kpr
                WHERE   khr.id                  = cp_chr_id
                AND     par.id          (+)     = khr.khr_id
                AND     par.scs_code    (+)     = 'PROGRAM'
                AND     kpr.dnz_chr_id  (+)     = par.id
                AND     kpr.rle_code    (+)     = 'OKL_VENDOR';

        l_partner_rec   l_partner_csr%ROWTYPE;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_partner_as_recipient';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
      IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'after call to get_rule_quote_parties  :'||l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.id : '||p_qtev_rec.id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qrs_code : '||p_qtev_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qst_code : '||p_qtev_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_qte_id : '||p_qtev_rec.consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.khr_id : '||p_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.art_id : '||p_qtev_rec.art_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qtp_code : '||p_qtev_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.trn_code : '||p_qtev_rec.trn_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.pdt_id : '||p_qtev_rec.pdt_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.date_effective_from : '||p_qtev_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.quote_number : '||p_qtev_rec.quote_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.early_termination_yn : '||p_qtev_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.partial_yn : '||p_qtev_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.preproceeds_yn : '||p_qtev_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.summary_format_yn : '||p_qtev_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_yn : '||p_qtev_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.payment_received_yn : '||p_qtev_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.requested_by : '||p_qtev_rec.requested_by);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.approved_yn : '||p_qtev_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.accepted_yn : '||p_qtev_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.org_id : '||p_qtev_rec.org_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.legal_entity_id : '||p_qtev_rec.legal_entity_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.repo_quote_indicator_yn : '||p_qtev_rec.repo_quote_indicator_yn);
   END IF;

        -- *******************
        -- Validate parameters
        -- *******************

        IF NOT p_validate_only THEN

            IF p_qtev_rec.id IS NULL
            OR p_qtev_rec.id = G_MISS_NUM THEN

                l_overall_status := OKL_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'QUOTE_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'CREATE_PARTNER_AS_RECIPIENT');

            END IF;

        END IF;

        IF p_qtev_rec.khr_id IS NULL
        OR p_qtev_rec.khr_id = G_MISS_NUM THEN

                l_overall_status := OKL_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'CONTRACT_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'CREATE_PARTNER_AS_RECIPIENT');

        END IF;

        -- ********************
        -- Choose quote parties
        -- ********************

        IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

                OPEN    l_partner_csr (p_qtev_rec.khr_id);
                FETCH   l_partner_csr INTO l_partner_rec;
                CLOSE   l_partner_csr;

                IF l_partner_rec.khr_id IS NULL THEN
                        l_return_status := OKL_API.G_RET_STS_ERROR;
                        OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'Contract Id');
                ELSIF l_partner_rec.par_id IS NULL THEN
                        l_return_status := OKL_API.G_RET_STS_ERROR;
                        okl_am_util_pvt.set_message(
                                 p_app_name     => G_APP_NAME
                                ,p_msg_name     => 'OKL_VP_INVALID_PARENT_AGRMNT');
                ELSIF l_partner_rec.kpr_id IS NULL THEN
                        l_overall_status := OKL_API.G_RET_STS_ERROR;
                        OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'Vendor Program Party');
                ELSE

                        lp_qpyv_tbl(1).party_jtot_object1_code  := l_partner_rec.object1_code;
                        lp_qpyv_tbl(1).party_object1_id1        := l_partner_rec.object1_id1;
                        lp_qpyv_tbl(1).party_object1_id2        := l_partner_rec.object1_id2;
                        lp_qpyv_tbl(1).qte_id                   := p_qtev_rec.id;
                        lp_qpyv_tbl(1).date_sent                := SYSDATE;
                        lp_qpyv_tbl(1).qpt_code                 := 'RECIPIENT';
                        lp_qpyv_tbl(1).allocation_percentage    := 100;

                END IF;

        END IF;

        -- ******************
        -- Save quote parties
        -- ******************

        IF NOT p_validate_only THEN

            IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

                IF lp_qpyv_tbl.COUNT > 0 THEN

                    okl_quote_parties_pub.insert_quote_parties (
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_qpyv_tbl      => lp_qpyv_tbl,
                        x_qpyv_tbl      => lx_qpyv_tbl);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_quote_parties_pub.insert_quote_parties :'||l_return_status);
                   END IF;

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                            l_overall_status := l_return_status;
                        END IF;
                    END IF;

                END IF;
            END IF;
        END IF;

        x_qpyv_tbl              := lx_qpyv_tbl;
        x_return_status         := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- Close open cursors
                IF l_partner_csr%ISOPEN THEN
                        CLOSE l_partner_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_partner_as_recipient;


-- Start of comments
--
-- Procedure Name       : create_quote_parties
-- Description          : Create all quote parties using setup rules
-- Business Rules       :
-- Parameters           : quote id, list of parties or contract id
-- History          : PAGARG   29-SEP-04 Added a validation for receipient role
--                  :          If quote type is rollover then recipient can be
--                  :          LESSEE only. In case it is not LESSEE then throw
--                  :          error
--                  : PAGARG   19-Nov-2004 Bug# 4021165
--                  :          Set overall status and don't raise exception in
--                  :          case of error in rollover quote party.
--                  :          Use correct application name while setting message
--                  : rmunjulu 4131592 For rollover quotes additional receipient can only be LESSEE
-- Version              : 1.0
-- End of comments

PROCEDURE create_quote_parties (
        p_qtev_rec              IN  qtev_rec_type,
        p_qpyv_tbl              IN  qpyv_tbl_type,
        p_validate_only         IN  BOOLEAN,
        x_qpyv_tbl              OUT NOCOPY qpyv_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        l_qpyv_tbl              qpyv_tbl_type;
        lp_qpyv_tbl             qpyv_tbl_type;
        lx_qpyv_tbl             qpyv_tbl_type;
        l_taiv_rec              taiv_rec_type;
        e_taiv_rec              taiv_rec_type;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_overall_status        VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);
        l_party_name            VARCHAR2(1000);

        l_seq                   NUMBER          := 0;
        l_approver_found        BOOLEAN         := FALSE;
        l_recipient_found       BOOLEAN         := FALSE;
        l_email_missing         BOOLEAN         := FALSE;

        l_allc_total            NUMBER          := 0; -- Total allocated
        l_no_allc               NUMBER          := 0; -- Recipients without allocation
        l_alloc_status          VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;

        CURSOR  l_kpr_csr (cp_cpl_id IN NUMBER, cp_khr_id NUMBER) IS
                SELECT  kpr.rle_code            rle_code,
                        kpr.jtot_object1_code   object1_code,
                        kpr.object1_id1         object1_id1,
                        kpr.object1_id2         object1_id2
                FROM    okc_k_party_roles_b     kpr
                WHERE   kpr.id                  = cp_cpl_id
                AND     kpr.chr_id              = cp_khr_id
                AND     kpr.dnz_chr_id          = cp_khr_id;

        l_k_role_rec    l_kpr_csr%ROWTYPE;
        e_k_role_rec    l_kpr_csr%ROWTYPE;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'create_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   IF (is_debug_statement_on) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'after call to get_rule_quote_parties  :'||l_return_status);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.id : '||p_qtev_rec.id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qrs_code : '||p_qtev_rec.qrs_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qst_code : '||p_qtev_rec.qst_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_qte_id : '||p_qtev_rec.consolidated_qte_id     );
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.khr_id : '||p_qtev_rec.khr_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.art_id : '||p_qtev_rec.art_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.qtp_code : '||p_qtev_rec.qtp_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.trn_code : '||p_qtev_rec.trn_code);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.pdt_id : '||p_qtev_rec.pdt_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.date_effective_from : '||p_qtev_rec.date_effective_from);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.quote_number : '||p_qtev_rec.quote_number);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.early_termination_yn : '||p_qtev_rec.early_termination_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.partial_yn : '||p_qtev_rec.partial_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.preproceeds_yn : '||p_qtev_rec.preproceeds_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.summary_format_yn : '||p_qtev_rec.summary_format_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.consolidated_yn : '||p_qtev_rec.consolidated_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.payment_received_yn : '||p_qtev_rec.payment_received_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.requested_by : '||p_qtev_rec.requested_by);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.approved_yn : '||p_qtev_rec.approved_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.accepted_yn : '||p_qtev_rec.accepted_yn);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.org_id : '||p_qtev_rec.org_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.legal_entity_id : '||p_qtev_rec.legal_entity_id);
        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_qtev_rec.repo_quote_indicator_yn : '||p_qtev_rec.repo_quote_indicator_yn);
   END IF;
        -- *******************
        -- Validate parameters
        -- *******************

        IF NOT p_validate_only THEN

            IF p_qtev_rec.id IS NULL
            OR p_qtev_rec.id = G_MISS_NUM THEN

                l_overall_status := OKL_API.G_RET_STS_ERROR;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'QUOTE_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'CREATE_QUOTE_PARTIES');

            END IF;

        END IF;

        -- ********************
        -- Choose quote parties
        -- ********************

        IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            IF p_qpyv_tbl.COUNT = 0 THEN

                -- Use contract rules to decide on quote parties
                get_rule_quote_parties (
                        p_qtev_rec      => p_qtev_rec,
                        x_qpyv_tbl      => l_qpyv_tbl,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_rule_quote_parties :'||l_return_status);
                   END IF;

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                    IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                    END IF;
                END IF;

            ELSE
                -- User-defined quote parties
                l_qpyv_tbl := p_qpyv_tbl;
            END IF;

        END IF;

        -- ******************************************************************
        -- Validate records, populate missing fields and remove empty records
        -- ******************************************************************

        IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

            FOR i IN l_qpyv_tbl.FIRST..l_qpyv_tbl.LAST LOOP

                -- Every quote party has to point to contract party
                IF  l_qpyv_tbl(i).cpl_id IS NOT NULL
                AND l_qpyv_tbl(i).cpl_id <> G_MISS_NUM THEN

                    -- Must have at least one recipient
                    IF l_qpyv_tbl(i).qpt_code = 'RECIPIENT' THEN
                        l_recipient_found       := TRUE;
                    END IF;

                    -- User-defined parties must have email addresses
                    IF  p_qpyv_tbl.COUNT > 0
                    AND (   l_qpyv_tbl(i).email_address IS NULL
                         OR l_qpyv_tbl(i).email_address = G_MISS_CHAR) THEN
                            l_email_missing := TRUE;
                    END IF;

                    -- Delay Days is required for Advance Notice Party
                    IF l_qpyv_tbl(i).qpt_code = 'ADVANCE_NOTICE' THEN

                        IF l_qpyv_tbl(i).delay_days IS NULL
                        OR l_qpyv_tbl(i).delay_days = G_MISS_NUM
                        OR l_qpyv_tbl(i).delay_days < 0 THEN

                            l_overall_status := OKL_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => 'OKC_DATA_REQUIRED',
                                p_token1        => 'DATA_NAME',
                                p_token1_value  => 'Delay Days',
                                p_token2        => 'OPERATION',
                                p_token2_value  => 'Advance Notice');

                        END IF;

                    ELSE
                        l_qpyv_tbl(i).delay_days := NULL;
                    END IF;

                    -- Allocation Percentage is required for Additional Recipient Party
                    IF  l_qpyv_tbl(i).qpt_code = 'RECIPIENT_ADDITIONAL' THEN

                        IF l_qpyv_tbl(i).allocation_percentage IS NULL
                        OR l_qpyv_tbl(i).allocation_percentage = G_MISS_NUM THEN

                            l_overall_status := OKL_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => 'OKC_DATA_REQUIRED',
                                p_token1        => 'DATA_NAME',
                                p_token1_value  => 'Allocation Percentage',
                                p_token2        => 'OPERATION',
                                p_token2_value  => 'Additional Recipient');

                        ELSIF l_qpyv_tbl(i).allocation_percentage NOT BETWEEN 0 AND 100 THEN

                            l_overall_status := OKL_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => 'OKL_PERCENATGE_FORMAT',
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Additional Recipient Percentage');

                        END IF;

                    END IF;

                    -- Allocation Percentage is bounded for Recipient Party
                    IF  l_qpyv_tbl(i).qpt_code = 'RECIPIENT' THEN

                        IF  l_qpyv_tbl(i).allocation_percentage IS NOT NULL
                        AND l_qpyv_tbl(i).allocation_percentage <> G_MISS_NUM
                        AND l_qpyv_tbl(i).allocation_percentage NOT BETWEEN 0 AND 100
                        THEN

                            l_overall_status := OKL_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => 'OKL_PERCENATGE_FORMAT',
                                p_token1        => 'COL_NAME',
                                p_token1_value  => 'Recipient Percentage');

                        END IF;

                    END IF;

                    -- Calculate allocation_percentage
                    IF l_qpyv_tbl(i).qpt_code IN ('RECIPIENT_ADDITIONAL','RECIPIENT') THEN

                        IF  l_qpyv_tbl(i).allocation_percentage IS NOT NULL
                        AND l_qpyv_tbl(i).allocation_percentage <> G_MISS_NUM THEN

                            IF l_qpyv_tbl(i).allocation_percentage BETWEEN 0 AND 100 THEN
                                l_allc_total    := l_allc_total + l_qpyv_tbl(i).allocation_percentage;
                            ELSE
                                l_alloc_status := OKL_API.G_RET_STS_ERROR;
                            END IF;

                        ELSE
                                l_no_allc       := l_no_allc + 1;
                        END IF;

                    ELSE
                        l_qpyv_tbl(i).allocation_percentage := NULL;
                    END IF;

                    -- Approver and Advance Copy are mutually exclusive
                    IF l_qpyv_tbl(i).qpt_code IN ('APPROVER','ADVANCE_NOTICE') THEN

                        IF l_approver_found THEN

                            l_overall_status := OKL_API.G_RET_STS_ERROR;
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => 'OKC_POPULATE_ONLY_ONE',
                                p_token1        => 'COL_NAME1',
                                p_token1_value  => 'Approver',
                                p_token2        => 'COL_NAME2',
                                p_token2_value  => 'Advance Notice');

                        ELSE
                            l_approver_found := TRUE;
                        END IF;

                    END IF;

                    -- Get Contract Party Role
                    l_k_role_rec := e_k_role_rec;
                    OPEN        l_kpr_csr (l_qpyv_tbl(i).cpl_id, p_qtev_rec.khr_id);
                    FETCH       l_kpr_csr INTO l_k_role_rec;
                    CLOSE       l_kpr_csr;

                    -- Invalid contract party role
                    IF l_k_role_rec.rle_code IS NULL THEN

                        l_overall_status := OKL_API.G_RET_STS_ERROR;
                        OKC_API.SET_MESSAGE (
                                p_app_name      => G_OKC_APP_NAME,
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'Contract Party');

                    ELSIF l_qpyv_tbl(i).qpt_code IN ('RECIPIENT_ADDITIONAL','RECIPIENT') THEN

                        -- Only Lessee and Vendor have setup for billing rules
                        IF l_k_role_rec.rle_code NOT IN ('OKL_VENDOR','LESSEE') THEN

                            l_overall_status    := OKL_API.G_RET_STS_ERROR;
                            l_party_name        := okl_am_util_pvt.get_jtf_object_name (
                                l_k_role_rec.object1_code,
                                l_k_role_rec.object1_id1,
                                l_k_role_rec.object1_id2);
                            OKC_API.SET_MESSAGE (
                                p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_NO_BILLING_INFO',
                                p_token1        => 'PARTY',
                                p_token1_value  => l_party_name);

                        -- Check billing information exist for vendor
                        ELSIF l_k_role_rec.rle_code = 'OKL_VENDOR' THEN

                            l_taiv_rec := e_taiv_rec;
                            l_taiv_rec.khr_id := p_qtev_rec.khr_id;

                            Okl_Am_Invoices_Pvt.Get_Vendor_Billing_Info (
                                p_cpl_id        => l_qpyv_tbl(i).cpl_id,
                                px_taiv_rec     => l_taiv_rec,
                                x_return_status => l_return_status);

                            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                              IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                                l_overall_status := l_return_status;
                              END IF;
                            END IF;

                        END IF;

                    END IF;

            --Bug #3921591: pagarg +++ Rollover +++++++ Start ++++++++++
            ----------------------
            -- Validate Recipient in case of rollover quote
            ----------------------
            -- In case of rollover quote recipient can only be LESSEE
            IF p_qtev_rec.qtp_code LIKE 'TER_ROLL%'
            AND l_qpyv_tbl(i).qpt_code = 'RECIPIENT'
            AND l_k_role_rec.rle_code <> 'LESSEE'
            THEN
               --19 Nov 2004 PAGARG Bug# 4021165
               --Set the overall status in case of error
               --Don't raise exception
               --Use correct application name while setting message
               l_overall_status := OKL_API.G_RET_STS_ERROR;
               OKL_API.set_message( p_app_name     => OKL_API.G_APP_NAME,
                                    p_msg_name     => 'OKL_QTE_RCPT_LESSEE_ONLY');
            END IF;
            --Bug #3921591: pagarg +++ Rollover +++++++ End ++++++++++

            -- rmunjulu 4131592 For Rollover Quote Additional Receipient can only be lessee
            IF p_qtev_rec.qtp_code LIKE 'TER_ROLL%'
            AND l_qpyv_tbl(i).qpt_code = 'RECIPIENT_ADDITIONAL'
            AND l_k_role_rec.rle_code <> 'LESSEE'
            THEN
               --19 Nov 2004 PAGARG Bug# 4021165
               --Set the overall status in case of error
               --Don't raise exception
               --Use correct application name while setting message
               l_overall_status := OKL_API.G_RET_STS_ERROR;
               OKL_API.set_message( p_app_name     => OKL_API.G_APP_NAME,
                                    p_msg_name     => 'OKL_QTE_RCPT_LESSEE_ONLY');
            END IF;

                    -- Save party details
                    IF l_qpyv_tbl(i).party_object1_id1 IS NULL
                    OR l_qpyv_tbl(i).party_object1_id1 = G_MISS_CHAR THEN
                        l_qpyv_tbl(i).party_jtot_object1_code := l_k_role_rec.object1_code;
                        l_qpyv_tbl(i).party_object1_id1   := l_k_role_rec.object1_id1;
                        l_qpyv_tbl(i).party_object1_id2   := l_k_role_rec.object1_id2;
                    END IF;

                    -- Attach quote parties to a quote
                    l_qpyv_tbl(i).qte_id        := p_qtev_rec.id;

                    -- Save results
                    l_seq := l_seq + 1;
                    lp_qpyv_tbl(l_seq)          := l_qpyv_tbl(i);

                END IF;

            END LOOP;

            /* Bug 2554547 - Email is optional in the screen
            -- Users did not supply email
            IF l_email_missing THEN
                l_return_status := OKL_API.G_RET_STS_ERROR;
                OKC_API.SET_MESSAGE (
                        p_app_name      => G_OKC_APP_NAME,
                        p_msg_name      => G_REQUIRED_VALUE,
                        p_token1        => G_COL_NAME_TOKEN,
                        p_token1_value  => 'Email Address');
            END IF;
            */

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

            -- Recipient not found
            IF NOT l_recipient_found THEN
                l_return_status := OKL_API.G_RET_STS_ERROR;
                -- Only display message if user-defined parties
                -- Rule-defined parties have its own message
                IF  p_qpyv_tbl.COUNT > 0 THEN
                    okl_am_util_pvt.set_message (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => 'OKL_AM_QTE_RECIPIENT_NOT_FOUND'
                        ,p_token1       => 'QUOTE_PARTY_TYPE'
                        ,p_token1_value => 'RECIPIENT');
                END IF;
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

            IF  l_allc_total > 100
            OR (l_allc_total = 100 AND l_no_allc > 0)
            OR (l_allc_total < 100 AND l_no_allc = 0) THEN
                l_alloc_status := OKL_API.G_RET_STS_ERROR;
            ELSIF (l_allc_total < 100 AND l_no_allc > 0) THEN
                -- Divide the rest equally
                FOR i IN lp_qpyv_tbl.FIRST..lp_qpyv_tbl.LAST LOOP
                    IF      lp_qpyv_tbl(i).qpt_code IN ('RECIPIENT_ADDITIONAL','RECIPIENT')
                    AND (   lp_qpyv_tbl(i).allocation_percentage IS NULL
                         OR lp_qpyv_tbl(i).allocation_percentage = G_MISS_NUM)
                    THEN
                        lp_qpyv_tbl(i).allocation_percentage := (100 - l_allc_total) / l_no_allc;
                    END IF;
                END LOOP;
            END IF;

            IF l_alloc_status <> OKL_API.G_RET_STS_SUCCESS THEN
                l_return_status         := OKL_API.G_RET_STS_ERROR;
                -- Message Text: Invalid value for the column Allocation Percentage
                OKL_API.SET_MESSAGE (
                        p_app_name      => G_OKC_APP_NAME,
                        p_msg_name      => G_INVALID_VALUE,
                        p_token1        => G_COL_NAME_TOKEN,
                        p_token1_value  => 'Allocation Percentage');
            END IF;

            IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                        l_overall_status := l_return_status;
                END IF;
            END IF;

        END IF;

        -- ******************
        -- Save quote parties
        -- ******************

        IF NOT p_validate_only THEN

            IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

                IF lp_qpyv_tbl.COUNT > 0 THEN

                    okl_quote_parties_pub.insert_quote_parties (
                        p_api_version   => l_api_version,
                        p_init_msg_list => OKL_API.G_FALSE,
                        x_return_status => l_return_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_qpyv_tbl      => lp_qpyv_tbl,
                        x_qpyv_tbl      => lx_qpyv_tbl);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_quote_parties_pub.insert_quote_parties  :'||l_return_status);
                   END IF;

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
                            l_overall_status := l_return_status;
                        END IF;
                    END IF;

                END IF;
            END IF;
        END IF;

        x_qpyv_tbl              := lx_qpyv_tbl;
        x_return_status         := l_overall_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- Close open cursors
                IF l_kpr_csr%ISOPEN THEN
                        CLOSE l_kpr_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END create_quote_parties;


-- Start of comments
--
-- Procedure Name       : get_quote_parties
-- Description          : Return quote party information
-- Note                 : View OKL_AM_QUOTE_PARTIES_UV
--                        returns the same results
-- Business Rules       :
-- Parameters           : quote_id
-- Version              : 1.0
-- History          : PAGARG 4299668 Modify quote party role cursor to return
--                    record for a given party if party id is passed.
-- End of comments

PROCEDURE get_quote_parties (
        p_api_version           IN  NUMBER,
        p_init_msg_list         IN  VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_q_party_uv_rec        IN  q_party_uv_rec_type,
        x_q_party_uv_tbl        OUT NOCOPY q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER) IS

        l_q_party_tbl           q_party_uv_tbl_type;
        l_object_tbl            okl_am_util_pvt.jtf_object_tbl_type;
        l_cnt                   NUMBER          := 0;
        l_quote_id              NUMBER;

--PAGARG 4299668 Modify the curosr to restrict the records for a given party if
--party id is passed
        CURSOR l_q_party_role_csr (cp_qte_id NUMBER, cp_qpt_code VARCHAR2, cp_party_id NUMBER  ) IS
                SELECT  qp.id                   qp_party_id,
                        qp.qpt_code             qp_role_code,
                        qp.CREATED_BY           qp_created_by,
                        qp.CREATION_DATE        qp_creation_date,
                        qp.LAST_UPDATED_BY      qp_last_updated_by,
                        qp.LAST_UPDATE_DATE     qp_last_update_date,
                        qp.LAST_UPDATE_LOGIN    qp_last_update_login,
                        qp.PARTY_JTOT_OBJECT1_CODE      qp_party_object,
                        qp.PARTY_OBJECT1_ID1            qp_party_id1,
                        qp.PARTY_OBJECT1_ID2            qp_party_id2,
                        qp.CONTACT_JTOT_OBJECT1_CODE    qp_contact_object,
                        qp.CONTACT_OBJECT1_ID1          qp_contact_id1,
                        qp.CONTACT_OBJECT1_ID2          qp_contact_id2,
                        qp.EMAIL_ADDRESS                qp_email_address,
                        lq.meaning              qp_party_role,
                        qp.date_sent            qp_date_sent,
                        pr.id                   kp_party_id,
                        pr.rle_code             kp_role_code,
                        lk.meaning              kp_party_role,
                        pr.jtot_object1_code    po_party_object,
                        pr.object1_id1          po_party_id1,
                        pr.object1_id2          po_party_id2,
                        kh.id                   contract_id,
                        kh.buy_or_sell          k_buy_or_sell
                FROM    okl_quote_parties       qp,
                        okc_k_party_roles_b     pr,
                        okl_trx_quotes_b        tq,
                        okc_k_headers_all_b     kh,
                        fnd_lookups             lq,
                        fnd_lookups             lk
                WHERE   qp.qte_id               = cp_qte_id
                AND     qp.qpt_code             = NVL (cp_qpt_code, qp.qpt_code)
                AND     pr.id           (+)     = qp.cpl_id
                AND     tq.id                   = qp.qte_id
                AND     tq.id                   = cp_qte_id
                AND     kh.id                   = tq.khr_id
                AND     lq.lookup_code          = qp.qpt_code
                AND     lq.lookup_type          = 'OKL_QUOTE_PARTY_TYPE'
                AND     lk.lookup_code  (+)     = pr.rle_code
                AND     lk.lookup_type  (+)     = 'OKC_ROLE'
        AND qp.id = nvl(cp_party_id, qp.id);

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_api_name              CONSTANT VARCHAR2(30)   := 'get_quote_parties';
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);
        l_qpt_code              VARCHAR2(30);
--pagarg 4299668 variable to hold party id value
        l_party_id              NUMBER;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_quote_parties';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.quote_id : '|| p_q_party_uv_rec.quote_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.contract_id : '||p_q_party_uv_rec.contract_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.k_buy_or_sell : '||p_q_party_uv_rec.k_buy_or_sell );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_id : '||p_q_party_uv_rec.qp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_role_code : '||p_q_party_uv_rec.qp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_role : '||p_q_party_uv_rec.qp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_sent : '||p_q_party_uv_rec.qp_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_hold : '||p_q_party_uv_rec.qp_date_hold );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_created_by : '||p_q_party_uv_rec.qp_created_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_creation_date : '||p_q_party_uv_rec.qp_creation_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_updated_by : '||p_q_party_uv_rec.qp_last_updated_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_date : '||p_q_party_uv_rec.qp_last_update_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_login : '||p_q_party_uv_rec.qp_last_update_login );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_id : '||p_q_party_uv_rec.kp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_role_code : '|| p_q_party_uv_rec.kp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_role : '|| p_q_party_uv_rec.kp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id1 : '|| p_q_party_uv_rec.po_party_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id2 : '|| p_q_party_uv_rec.po_party_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_object : '|| p_q_party_uv_rec.po_party_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_name : '|| p_q_party_uv_rec.po_party_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_desc : '|| p_q_party_uv_rec.po_party_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id1 : '|| p_q_party_uv_rec.co_contact_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id2 : '|| p_q_party_uv_rec.co_contact_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_object : '|| p_q_party_uv_rec.co_contact_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_name : '|| p_q_party_uv_rec.co_contact_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_desc : '|| p_q_party_uv_rec.co_contact_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_email : '|| p_q_party_uv_rec.co_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_order_num : '|| p_q_party_uv_rec.co_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_date_sent : '|| p_q_party_uv_rec.co_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_id : '|| p_q_party_uv_rec.cp_point_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_type : '|| p_q_party_uv_rec.cp_point_type );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_primary_flag : '|| p_q_party_uv_rec.cp_primary_flag );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_email : '|| p_q_party_uv_rec.cp_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_details : '|| p_q_party_uv_rec.cp_details );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_order_num : '|| p_q_party_uv_rec.cp_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_date_sent : '|| p_q_party_uv_rec.cp_date_sent );
   END IF;
        -- ***************************************************************
        -- Check API version, initialize message list and create savepoint
        -- ***************************************************************

        l_return_status := OKL_API.START_ACTIVITY (
                l_api_name,
                G_PKG_NAME,
                p_init_msg_list,
                l_api_version,
                p_api_version,
                '_PVT',
                x_return_status);

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- *******************
        -- Validate parameters
        -- *******************

        IF p_q_party_uv_rec.quote_id IS NULL
        OR p_q_party_uv_rec.quote_id = G_MISS_NUM THEN

                l_return_status := OKL_API.G_RET_STS_ERROR;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'QUOTE_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'GET_QUOTE_PARTIES');

        ELSE
                l_quote_id := p_q_party_uv_rec.quote_id;
                l_qpt_code := p_q_party_uv_rec.qp_role_code;
                IF l_qpt_code = G_MISS_CHAR THEN
                        l_qpt_code := NULL;
                END IF;
--pagarg 4299668 Obtain value of party id and replace G_MISS_NUM with null
                l_party_id := p_q_party_uv_rec.qp_party_id;
                IF l_party_id = G_MISS_NUM THEN
                        l_party_id := NULL;
                END IF;
        END IF;

        -- ********************
        -- Process every record
        -- ********************

--pagarg 4299668 pass party id also to the quote party role cursor
        FOR l_q_role_rec IN l_q_party_role_csr (l_quote_id, l_qpt_code, l_party_id) LOOP
            IF l_q_role_rec.kp_party_id IS NOT NULL THEN
                -- Get Contract Party Object
                okl_am_util_pvt.get_object_details (
                        p_object_code   => l_q_role_rec.po_party_object,
                        p_object_id1    => l_q_role_rec.po_party_id1,
                        p_object_id2    => l_q_role_rec.po_party_id2,
                        x_object_tbl    => l_object_tbl,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;

            ELSE
                -- Get Quote Party Object
                okl_am_util_pvt.get_object_details (
                        p_object_code   => l_q_role_rec.qp_party_object,
                        p_object_id1    => l_q_role_rec.qp_party_id1,
                        p_object_id2    => l_q_role_rec.qp_party_id2,
                        x_object_tbl    => l_object_tbl,
                        x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;

            END IF;

            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_object_tbl.COUNT > 0 THEN
                    FOR l_ind IN l_object_tbl.FIRST..l_object_tbl.LAST LOOP
                        -- Party Object is found
                        l_cnt := l_cnt + 1;
                        l_q_party_tbl(l_cnt).quote_id           := l_quote_id;
                        l_q_party_tbl(l_cnt).contract_id        := l_q_role_rec.contract_id;
                        l_q_party_tbl(l_cnt).k_buy_or_sell      := l_q_role_rec.k_buy_or_sell;
                        l_q_party_tbl(l_cnt).qp_party_id        := l_q_role_rec.qp_party_id;
                        l_q_party_tbl(l_cnt).qp_role_code       := l_q_role_rec.qp_role_code;
                        l_q_party_tbl(l_cnt).qp_party_role      := l_q_role_rec.qp_party_role;
                        l_q_party_tbl(l_cnt).qp_date_hold       := NULL;
                        l_q_party_tbl(l_cnt).qp_date_sent       := l_q_role_rec.qp_date_sent;
                        l_q_party_tbl(l_cnt).qp_created_by      := l_q_role_rec.qp_created_by;
                        l_q_party_tbl(l_cnt).qp_creation_date   := l_q_role_rec.qp_creation_date;
                        l_q_party_tbl(l_cnt).qp_last_updated_by := l_q_role_rec.qp_last_updated_by;
                        l_q_party_tbl(l_cnt).qp_last_update_date  := l_q_role_rec.qp_last_update_date;
                        l_q_party_tbl(l_cnt).qp_last_update_login := l_q_role_rec.qp_last_update_login;
                        l_q_party_tbl(l_cnt).kp_party_id        := l_q_role_rec.kp_party_id;
                        l_q_party_tbl(l_cnt).kp_role_code       := l_q_role_rec.kp_role_code;
                        l_q_party_tbl(l_cnt).kp_party_role      := l_q_role_rec.kp_party_role;
                        l_q_party_tbl(l_cnt).po_party_id1       := l_object_tbl(l_ind).id1;
                        l_q_party_tbl(l_cnt).po_party_id2       := l_object_tbl(l_ind).id2;
                        l_q_party_tbl(l_cnt).po_party_object    := l_object_tbl(l_ind).object_code;
                        l_q_party_tbl(l_cnt).po_party_name      := l_object_tbl(l_ind).name;
                        l_q_party_tbl(l_cnt).po_party_desc      := l_object_tbl(l_ind).description;
                        l_q_party_tbl(l_cnt).co_contact_id1     := l_q_role_rec.qp_contact_id1;
                        l_q_party_tbl(l_cnt).co_contact_id2     := l_q_role_rec.qp_contact_id2;
                        l_q_party_tbl(l_cnt).co_contact_object  := l_q_role_rec.qp_contact_object;
                        l_q_party_tbl(l_cnt).co_email           := l_q_role_rec.qp_email_address;
                        l_q_party_tbl(l_cnt).co_order_num       := 1;
                    END LOOP;
            ELSE
                        -- Party Object is not found
                        l_cnt := l_cnt + 1;
                        l_q_party_tbl(l_cnt).quote_id           := l_quote_id;
                        l_q_party_tbl(l_cnt).contract_id        := l_q_role_rec.contract_id;
                        l_q_party_tbl(l_cnt).k_buy_or_sell      := l_q_role_rec.k_buy_or_sell;
                        l_q_party_tbl(l_cnt).qp_party_id        := l_q_role_rec.qp_party_id;
                        l_q_party_tbl(l_cnt).qp_role_code       := l_q_role_rec.qp_role_code;
                        l_q_party_tbl(l_cnt).qp_party_role      := l_q_role_rec.qp_party_role;
                        l_q_party_tbl(l_cnt).qp_date_hold       := NULL;
                        l_q_party_tbl(l_cnt).qp_date_sent       := l_q_role_rec.qp_date_sent;
                        l_q_party_tbl(l_cnt).qp_created_by      := l_q_role_rec.qp_created_by;
                        l_q_party_tbl(l_cnt).qp_creation_date   := l_q_role_rec.qp_creation_date;
                        l_q_party_tbl(l_cnt).qp_last_updated_by := l_q_role_rec.qp_last_updated_by;
                        l_q_party_tbl(l_cnt).qp_last_update_date  := l_q_role_rec.qp_last_update_date;
                        l_q_party_tbl(l_cnt).qp_last_update_login := l_q_role_rec.qp_last_update_login;
                        l_q_party_tbl(l_cnt).kp_party_id        := l_q_role_rec.kp_party_id;
                        l_q_party_tbl(l_cnt).kp_role_code       := l_q_role_rec.kp_role_code;
                        l_q_party_tbl(l_cnt).kp_party_role      := l_q_role_rec.kp_party_role;
                        l_q_party_tbl(l_cnt).po_party_name      := NULL;
                        l_q_party_tbl(l_cnt).po_party_desc      := NULL;
                        l_q_party_tbl(l_cnt).co_contact_id1     := l_q_role_rec.qp_contact_id1;
                        l_q_party_tbl(l_cnt).co_contact_id2     := l_q_role_rec.qp_contact_id2;
                        l_q_party_tbl(l_cnt).co_contact_object  := l_q_role_rec.qp_contact_object;
                        l_q_party_tbl(l_cnt).co_email           := l_q_role_rec.qp_email_address;
                        l_q_party_tbl(l_cnt).co_order_num       := 1;

                    IF l_q_role_rec.kp_party_id IS NOT NULL THEN
                        l_q_party_tbl(l_cnt).po_party_id1       := l_q_role_rec.po_party_id1;
                        l_q_party_tbl(l_cnt).po_party_id2       := l_q_role_rec.po_party_id2;
                        l_q_party_tbl(l_cnt).po_party_object    := l_q_role_rec.po_party_object;
                    ELSE
                        l_q_party_tbl(l_cnt).po_party_id1       := l_q_role_rec.qp_party_id1;
                        l_q_party_tbl(l_cnt).po_party_id2       := l_q_role_rec.qp_party_id2;
                        l_q_party_tbl(l_cnt).po_party_object    := l_q_role_rec.qp_party_object;
                    END IF;

            END IF;

        END LOOP;

        -- **************
        -- Return results
        -- **************

        x_record_count          := l_q_party_tbl.COUNT;
        x_q_party_uv_tbl        := l_q_party_tbl;
        x_return_status         := l_return_status;

        OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- Close open cursors
                IF l_q_party_role_csr%ISOPEN THEN
                        CLOSE l_q_party_role_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_quote_parties;


-- Start of comments
--
-- Procedure Name       : get_quote_party_contacts
-- Description          : Return quote party contact information
-- Business Rules       :
-- Parameters           : quote_id, optional quote_party_id
-- Version              : 1.0
--                  : PAGARG 4299668 fix the logic to obtain party contacts when
--                    party id is available
-- End of comments

PROCEDURE get_quote_party_contacts (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_q_party_uv_rec        IN q_party_uv_rec_type,
        x_q_party_uv_tbl        OUT NOCOPY q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER) IS

        l_q_party_tbl           q_party_uv_tbl_type;
        l_temp_q_party_tbl      q_party_uv_tbl_type;
        l_curr_qp_rec           q_party_uv_rec_type;

        l_object_tbl            okl_am_util_pvt.jtf_object_tbl_type;
        l_t_object_tbl          okl_am_util_pvt.jtf_object_tbl_type;
        l_where_cond            okl_am_util_pvt.where_tbl_type;
        l_other_cols            okl_am_util_pvt.select_tbl_type;

        l_cnt                   NUMBER  := 0;
        l_obj                   NUMBER;
        l_quote_id              NUMBER;
        l_quote_party_id        NUMBER  := NULL;
        l_contact_source_count  NUMBER;
        l_party_count           NUMBER;
        l_contact_object        VARCHAR2(30);

        CURSOR l_cntct_src_count_csr (cp_rle_code VARCHAR2, cp_buy_or_sell VARCHAR2) IS
                SELECT  count(*)
                FROM    okc_contact_sources cs
                WHERE   cs.rle_code     = cp_rle_code
                AND     cs.start_date   <= SYSDATE
                AND     NVL (cs.end_date, SYSDATE) >= SYSDATE
                AND     cs.buy_or_sell  = cp_buy_or_sell;

        CURSOR l_contacts_csr (
                        cp_k_party_id   NUMBER,
                        cp_rle_code     VARCHAR2,
                        cp_buy_or_sell  VARCHAR2,
                        cp_contract_id  NUMBER) IS
                SELECT  cn.jtot_object1_code,
                        cn.object1_id1,
                        cn.object1_id2
                FROM    okc_contacts            cn,
                        okc_contact_sources     cs
                WHERE   cn.cpl_id               = cp_k_party_id
                AND     cn.dnz_chr_id           = cp_contract_id
                AND     cn.cro_code             = cs.cro_code
                AND     cn.jtot_object1_code    = cs.jtot_object_code
                AND     cs.start_date           <= SYSDATE
                AND     NVL (cs.end_date, SYSDATE) >= SYSDATE
                AND     cs.rle_code             = cp_rle_code
                AND     cs.buy_or_sell          = cp_buy_or_sell;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_api_name              CONSTANT VARCHAR2(30)   :=
                                'get_quote_party_contacts';
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_quote_party_contacts';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;

   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.quote_id : '|| p_q_party_uv_rec.quote_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.contract_id : '||p_q_party_uv_rec.contract_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.k_buy_or_sell : '||p_q_party_uv_rec.k_buy_or_sell );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_id : '||p_q_party_uv_rec.qp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_role_code : '||p_q_party_uv_rec.qp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_role : '||p_q_party_uv_rec.qp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_sent : '||p_q_party_uv_rec.qp_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_hold : '||p_q_party_uv_rec.qp_date_hold );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_created_by : '||p_q_party_uv_rec.qp_created_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_creation_date : '||p_q_party_uv_rec.qp_creation_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_updated_by : '||p_q_party_uv_rec.qp_last_updated_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_date : '||p_q_party_uv_rec.qp_last_update_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_login : '||p_q_party_uv_rec.qp_last_update_login );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_id : '||p_q_party_uv_rec.kp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_role_code : '|| p_q_party_uv_rec.kp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_role : '|| p_q_party_uv_rec.kp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id1 : '|| p_q_party_uv_rec.po_party_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id2 : '|| p_q_party_uv_rec.po_party_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_object : '|| p_q_party_uv_rec.po_party_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_name : '|| p_q_party_uv_rec.po_party_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_desc : '|| p_q_party_uv_rec.po_party_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id1 : '|| p_q_party_uv_rec.co_contact_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id2 : '|| p_q_party_uv_rec.co_contact_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_object : '|| p_q_party_uv_rec.co_contact_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_name : '|| p_q_party_uv_rec.co_contact_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_desc : '|| p_q_party_uv_rec.co_contact_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_email : '|| p_q_party_uv_rec.co_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_order_num : '|| p_q_party_uv_rec.co_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_date_sent : '|| p_q_party_uv_rec.co_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_id : '|| p_q_party_uv_rec.cp_point_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_type : '|| p_q_party_uv_rec.cp_point_type );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_primary_flag : '|| p_q_party_uv_rec.cp_primary_flag );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_email : '|| p_q_party_uv_rec.cp_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_details : '|| p_q_party_uv_rec.cp_details );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_order_num : '|| p_q_party_uv_rec.cp_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_date_sent : '|| p_q_party_uv_rec.cp_date_sent );
   END IF;
        -- ***************************************************************
        -- Check API version, initialize message list and create savepoint
        -- ***************************************************************

        l_return_status := OKL_API.START_ACTIVITY (
                l_api_name,
                G_PKG_NAME,
                p_init_msg_list,
                l_api_version,
                p_api_version,
                '_PVT',
                x_return_status);

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- *******************
        -- Validate parameters
        -- *******************

        IF p_q_party_uv_rec.quote_id IS NULL
        OR p_q_party_uv_rec.quote_id = G_MISS_NUM THEN

                l_return_status := OKL_API.G_RET_STS_ERROR;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'QUOTE_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'GET_QUOTE_PARTY_CONTACTS');

        ELSE
                l_quote_id       := p_q_party_uv_rec.quote_id;
                l_quote_party_id := p_q_party_uv_rec.qp_party_id;
                IF l_quote_party_id = G_MISS_NUM THEN
                        l_quote_party_id := NULL;
                END IF;
        END IF;

        -- ********************
        -- Get quote party data
        -- ********************
--PAGARG 4299668 call the procedure even when if party is not null so as to
--populate other fields of the party record
                get_quote_parties (
                        p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data,
                        x_return_status  => l_return_status,
                        p_q_party_uv_rec => p_q_party_uv_rec,
                        x_q_party_uv_tbl => l_temp_q_party_tbl,
                        x_record_count   => l_party_count);


                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_quote_parties :'||l_return_status);
                   END IF;

        -- ********************
        -- Process every record
        -- ********************

        l_where_cond(1).column_name     := 'PARTY_ID';
        l_where_cond(2).column_name     := 'PARTY_ID2';
        l_other_cols(1)                 := 'EMAIL_ADDRESS';

--PAGARG 4299668 check the table count before looping the table
    IF l_temp_q_party_tbl.count > 0
    THEN
      FOR l_ind IN l_temp_q_party_tbl.FIRST..l_temp_q_party_tbl.LAST LOOP
        --PAGARG 4299668 Empty the object table for each quote party role
        l_object_tbl.delete;
                -- ****************************
                -- Detemine Contact Object Code
                -- ****************************
                l_curr_qp_rec           := l_temp_q_party_tbl(l_ind);
                l_contact_source_count  := 0;
                l_contact_object        := NULL;

                IF l_curr_qp_rec.co_contact_object IS NULL THEN

                    OPEN l_cntct_src_count_csr
                                (l_curr_qp_rec.kp_role_code,
                                 l_curr_qp_rec.k_buy_or_sell);
                    FETCH l_cntct_src_count_csr INTO l_contact_source_count;
                    CLOSE l_cntct_src_count_csr;

                    IF l_contact_source_count = 0 THEN
                        IF    l_curr_qp_rec.po_party_object = 'OKX_PARTY' THEN
                                l_contact_object := 'OKX_PCONTACT';
                        ELSIF l_curr_qp_rec.po_party_object = 'OKX_VENDOR' THEN
                                l_contact_object := 'OKX_VCONTACT';
                        END IF;
                    END IF;

                END IF;

                -- **************************
                -- Get Contact Name and Email
                -- **************************

                IF  l_curr_qp_rec.co_contact_object IS NULL
                AND l_contact_source_count = 0
                AND l_contact_object IS NULL THEN
                        -- Contact Object Code is not found
                        l_cnt := l_cnt + 1;
                        l_q_party_tbl(l_cnt) := l_curr_qp_rec;

                ELSE

                    IF l_curr_qp_rec.co_contact_object IS NOT NULL THEN

                        -- *******************************************
                        -- Get Contact Object from TCA (Quote Contact)
                        -- *******************************************

                        -- Get all contacts for a quote
                        okl_am_util_pvt.get_object_details (
                                p_object_code   => l_curr_qp_rec.co_contact_object,
                                p_object_id1    => l_curr_qp_rec.co_contact_id1,
                                p_object_id2    => l_curr_qp_rec.co_contact_id2,
                                p_other_select  => l_other_cols,
                                x_object_tbl    => l_object_tbl,
                                x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;

                    ELSIF l_contact_source_count <> 0 THEN

                        -- ***************************
                        -- Get Contact Object from OKC
                        -- ***************************

                        l_obj := 0;

                        FOR l_cntct_rec IN l_contacts_csr
                                (l_curr_qp_rec.kp_party_id,
                                l_curr_qp_rec.kp_role_code,
                                l_curr_qp_rec.k_buy_or_sell,
                                l_curr_qp_rec.contract_id)
                        LOOP

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'before call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;
                            -- Get Contact Object
                            okl_am_util_pvt.get_object_details (
                                p_object_code   => l_cntct_rec.jtot_object1_code,
                                p_other_select  => l_other_cols,
                                p_object_id1    => l_cntct_rec.object1_id1,
                                p_object_id2    => l_cntct_rec.object1_id2,
                                x_object_tbl    => l_t_object_tbl,
                                x_return_status => l_return_status);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;

                            FOR l_ind3 IN l_t_object_tbl.FIRST..l_t_object_tbl.LAST LOOP
                                l_obj   := l_obj + 1;
                                l_object_tbl(l_obj) := l_t_object_tbl(l_ind3);
                            END LOOP;

                        END LOOP;

                    ELSIF l_contact_object IS NOT NULL THEN

                        -- *******************************************
                        -- Get Contact Object from TCA (Party Contact)
                        -- *******************************************

                        l_where_cond(1).condition_value := l_curr_qp_rec.po_party_id1;
                        l_where_cond(2).condition_value := l_curr_qp_rec.po_party_id2;

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'before call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                   END IF;

                        -- Get all contacts for a party
                        okl_am_util_pvt.get_object_details (
                                p_object_code   => l_contact_object,
                                p_other_select  => l_other_cols,
                                p_other_where   => l_where_cond,
                                p_check_status  => 'Y',
                                x_object_tbl    => l_object_tbl,
                                x_return_status => l_return_status);

                          IF (is_debug_statement_on) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                               'before call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                           END IF;

                    END IF;

                    -- ************
                    -- Save results
                    -- ************

                    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_object_tbl.COUNT > 0 THEN
                        FOR l_ind2 IN l_object_tbl.FIRST..l_object_tbl.LAST LOOP
                            -- Contact Object is found
                            l_cnt := l_cnt + 1;
                            l_q_party_tbl(l_cnt) := l_curr_qp_rec;
                            l_q_party_tbl(l_cnt).co_contact_id1 := l_object_tbl(l_ind2).id1;
                            l_q_party_tbl(l_cnt).co_contact_id2 := l_object_tbl(l_ind2).id2;
                            l_q_party_tbl(l_cnt).co_contact_object := l_object_tbl(l_ind2).object_code;
                            l_q_party_tbl(l_cnt).co_contact_name   := l_object_tbl(l_ind2).name;
                            l_q_party_tbl(l_cnt).co_contact_desc   := l_object_tbl(l_ind2).description;
                            l_q_party_tbl(l_cnt).co_email       := l_object_tbl(l_ind2).other_values;
                            l_q_party_tbl(l_cnt).co_order_num   := l_ind2;
                            l_q_party_tbl(l_cnt).co_date_sent   := NULL;
                        END LOOP;
            --PAGARG 4299668 Removed else clause as there is no need to populate
            --back the record in result table if there is no contact
                    END IF;
                END IF;
      END LOOP;
    END IF;

        -- **************
        -- Return results
        -- **************

        IF  l_quote_party_id IS NOT NULL
        AND l_q_party_tbl.COUNT = 1
        AND (   l_q_party_tbl(1).co_contact_id1 IS NULL
             OR l_q_party_tbl(1).co_contact_id1 = G_MISS_CHAR) THEN
                -- No contact was found
                x_record_count  := 0;
        ELSE
                x_record_count  := l_q_party_tbl.COUNT;
        END IF;

        x_q_party_uv_tbl        := l_q_party_tbl;
        x_return_status         := l_return_status;

        OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- Close open cursors

                IF l_cntct_src_count_csr%ISOPEN THEN
                        CLOSE l_cntct_src_count_csr;
                END IF;

                IF l_contacts_csr%ISOPEN THEN
                        CLOSE l_contacts_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_quote_party_contacts;


-- Start of comments
--
-- Procedure Name       : get_quote_contact_points
-- Description          : Return quote party contact point information
-- Business Rules       :
-- Parameters           : quote_id, optional quote_party_id and contact_id
-- Version              : 1.0
--                  : PAGARG 4299668 fix the logic to obtain party contact points
--                    when party id is available
-- End of comments
PROCEDURE get_quote_contact_points (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_return_status         OUT NOCOPY VARCHAR2,
        p_q_party_uv_rec        IN q_party_uv_rec_type,
        x_q_party_uv_tbl        OUT NOCOPY q_party_uv_tbl_type,
        x_record_count          OUT NOCOPY NUMBER) IS

        l_co_point_tbl          q_party_uv_tbl_type;
        l_temp_qp_tbl           q_party_uv_tbl_type;
        l_temp_co_tbl           q_party_uv_tbl_type;
        l_curr_qp_rec           q_party_uv_rec_type;
        l_curr_co_rec           q_party_uv_rec_type;

        l_cnt1                  NUMBER          := 0;
        l_cnt2                  NUMBER;
        l_quote_id              NUMBER;
        l_quote_party_id        NUMBER          := NULL;
        l_contact_id            VARCHAR2(40)    := NULL;
        l_contact_count         NUMBER;
        l_party_count           NUMBER;
        l_table_id              VARCHAR2(40);
        l_table_name            VARCHAR2(30);
        l_added_yn2             BOOLEAN;

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_api_name              CONSTANT VARCHAR2(30)   :=
                                'get_quote_contact_points';
        l_api_version           CONSTANT NUMBER := G_API_VERSION;
        l_msg_count             NUMBER          := G_MISS_NUM;
        l_msg_data              VARCHAR2(2000);

        CURSOR l_c_points_csr
                        (cp_owner_table_name    VARCHAR2,
                        cp_owner_table_id       NUMBER) IS
                SELECT  Initcap (
                          Decode (c.contact_point_type,
                            'PHONE', Decode (c.phone_line_type,
                                                'GEN', c.contact_point_type,
                                                c.phone_line_type),
                            'EMAIL', c.contact_point_type))
                                                contact_point_type,
                        Decode (c.contact_point_type,
                            'PHONE', LTrim (RTrim  (
                                Decode (c.telephone_type,       NULL, NULL,
                                        c.telephone_type         || ' ') ||
                                Decode (c.phone_country_code,   NULL, NULL,
                                        c.phone_country_code || ' ') ||
                                Decode (c.phone_area_code,      NULL, NULL,
                                        c.phone_area_code        || ' ') ||
                                Decode (c.phone_number,         NULL, NULL,
                                        c.phone_number   || ' ') ||
                                Decode (c.phone_extension,      NULL, NULL,
                                        'Ext. ' || c.phone_extension))),
                            'EMAIL', c.email_address)
                                                contact_point_details,
                        c.contact_point_id      contact_point_id,
                        c.email_address         email_address,
                        c.primary_flag          primary_flag
                FROM    okx_contact_points_v c
                WHERE   c.owner_table_name      = cp_owner_table_name
                AND     c.owner_table_id        = cp_owner_table_id
                AND     c.status                = 'A'
                AND     c.contact_point_type    IN ('EMAIL','PHONE');

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_quote_contact_points';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.quote_id : '|| p_q_party_uv_rec.quote_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.contract_id : '||p_q_party_uv_rec.contract_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.k_buy_or_sell : '||p_q_party_uv_rec.k_buy_or_sell );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_id : '||p_q_party_uv_rec.qp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_role_code : '||p_q_party_uv_rec.qp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_party_role : '||p_q_party_uv_rec.qp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_sent : '||p_q_party_uv_rec.qp_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_date_hold : '||p_q_party_uv_rec.qp_date_hold );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_created_by : '||p_q_party_uv_rec.qp_created_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_creation_date : '||p_q_party_uv_rec.qp_creation_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_updated_by : '||p_q_party_uv_rec.qp_last_updated_by );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_date : '||p_q_party_uv_rec.qp_last_update_date );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.qp_last_update_login : '||p_q_party_uv_rec.qp_last_update_login );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_id : '||p_q_party_uv_rec.kp_party_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_role_code : '|| p_q_party_uv_rec.kp_role_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.kp_party_role : '|| p_q_party_uv_rec.kp_party_role );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id1 : '|| p_q_party_uv_rec.po_party_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_id2 : '|| p_q_party_uv_rec.po_party_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_object : '|| p_q_party_uv_rec.po_party_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_name : '|| p_q_party_uv_rec.po_party_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.po_party_desc : '|| p_q_party_uv_rec.po_party_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id1 : '|| p_q_party_uv_rec.co_contact_id1 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_id2 : '|| p_q_party_uv_rec.co_contact_id2 );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_object : '|| p_q_party_uv_rec.co_contact_object );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_name : '|| p_q_party_uv_rec.co_contact_name );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_contact_desc : '|| p_q_party_uv_rec.co_contact_desc );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_email : '|| p_q_party_uv_rec.co_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_order_num : '|| p_q_party_uv_rec.co_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.co_date_sent : '|| p_q_party_uv_rec.co_date_sent );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_id : '|| p_q_party_uv_rec.cp_point_id );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_point_type : '|| p_q_party_uv_rec.cp_point_type );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_primary_flag : '|| p_q_party_uv_rec.cp_primary_flag );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_email : '|| p_q_party_uv_rec.cp_email );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_details : '|| p_q_party_uv_rec.cp_details );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_order_num : '|| p_q_party_uv_rec.cp_order_num );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_q_party_uv_rec.cp_date_sent : '|| p_q_party_uv_rec.cp_date_sent );
   END IF;
        -- ***************************************************************
        -- Check API version, initialize message list and create savepoint
        -- ***************************************************************

        l_return_status := OKL_API.START_ACTIVITY (
                l_api_name,
                G_PKG_NAME,
                p_init_msg_list,
                l_api_version,
                p_api_version,
                '_PVT',
                x_return_status);

        IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- *******************
        -- Validate parameters
        -- *******************

        IF p_q_party_uv_rec.quote_id IS NULL
        OR p_q_party_uv_rec.quote_id = G_MISS_NUM THEN

                l_return_status := OKL_API.G_RET_STS_ERROR;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'QUOTE_ID',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'GET_QUOTE_PARTY_CONTACT_POINTS');

        ELSE
                l_quote_id       := p_q_party_uv_rec.quote_id;
                l_quote_party_id := p_q_party_uv_rec.qp_party_id;
                l_contact_id     := p_q_party_uv_rec.co_contact_id1;
                IF l_quote_party_id = G_MISS_NUM THEN
                        l_quote_party_id := NULL;
                END IF;
                IF l_contact_id = G_MISS_CHAR THEN
                        l_contact_id := NULL;
                END IF;
        END IF;

        -- ********************
        -- Get quote party data
        -- ********************
--PAGARG 4299668 call the procedure even when if party is not null so as to
--populate other fields of the party record
                get_quote_parties (
                        p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data,
                        x_return_status  => l_return_status,
                        p_q_party_uv_rec => p_q_party_uv_rec,
                        x_q_party_uv_tbl => l_temp_qp_tbl,
                        x_record_count   => l_party_count);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_quote_parties :'||l_return_status);
                   END IF;

        -- **************************
        -- Process every party record
        -- **************************
--PAGARG 4299668 check the table count before looping the table
    IF l_temp_qp_tbl.count > 0
    THEN
          FOR l_ind1 IN l_temp_qp_tbl.FIRST..l_temp_qp_tbl.LAST LOOP

            l_curr_qp_rec       := l_temp_qp_tbl(l_ind1);

            -- ****************
            -- Get Party Points
            -- ****************
            IF l_contact_id IS NULL THEN

                l_table_name    := NULL;
                l_table_id      := NULL;

                IF l_curr_qp_rec.po_party_object = 'OKX_PARTY' THEN
                        l_table_name    := 'HZ_PARTIES';
                        l_table_id      := l_curr_qp_rec.po_party_id1;
                        IF l_table_id = G_MISS_CHAR THEN
                            l_table_id  := NULL;
                        END IF;
                END IF;

                l_added_yn2 := FALSE;

                IF l_table_name IS NOT NULL
                AND l_table_id IS NOT NULL THEN

                    l_cnt2 := 0;
                    FOR l_c_points_rec IN l_c_points_csr (l_table_name, l_table_id) LOOP
                        -- Contact Point is found for a Party
                        l_added_yn2 := TRUE;
                        l_cnt1 := l_cnt1 + 1;
                        l_cnt2 := l_cnt2 + 1;
                        l_co_point_tbl(l_cnt1) := l_curr_qp_rec;
                        l_co_point_tbl(l_cnt1).cp_point_id      := l_c_points_rec.contact_point_id;
                        l_co_point_tbl(l_cnt1).cp_point_type    := l_c_points_rec.contact_point_type;
                        l_co_point_tbl(l_cnt1).cp_primary_flag  := l_c_points_rec.primary_flag;
                        l_co_point_tbl(l_cnt1).cp_email         := l_c_points_rec.email_address;
                        l_co_point_tbl(l_cnt1).cp_details       := l_c_points_rec.contact_point_details;
                        l_co_point_tbl(l_cnt1).cp_order_num     := l_cnt2;
                        l_co_point_tbl(l_cnt1).cp_date_sent     := NULL;

                    END LOOP;

                END IF;

            END IF;

            -- **********************
            -- Get party contact data
            -- **********************

            IF l_curr_qp_rec.co_contact_id1 IS NULL
            OR l_curr_qp_rec.co_contact_id1 = G_MISS_CHAR THEN

                get_quote_party_contacts (
                        p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_msg_count      => l_msg_count,
                        x_msg_data       => l_msg_data,
                        x_return_status  => l_return_status,
                        p_q_party_uv_rec => l_curr_qp_rec,
                        x_q_party_uv_tbl => l_temp_co_tbl,
                        x_record_count   => l_contact_count);

                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to get_quote_party_contacts :'||l_return_status);
                   END IF;


            ELSE
                l_temp_co_tbl(1) := l_curr_qp_rec;
            END IF;

            -- ****************************
            -- Process every contact record
            -- ****************************
        --PAGARG 4299668 check the table count before looping the table
        IF l_temp_co_tbl.count > 0
        THEN
            FOR l_ind2 IN l_temp_co_tbl.FIRST..l_temp_co_tbl.LAST LOOP

                l_curr_co_rec   := l_temp_co_tbl(l_ind2);
                l_table_name    := NULL;
                l_table_id      := NULL;

                IF l_curr_co_rec.co_contact_object = 'OKX_PCONTACT' THEN
                        l_table_name    := 'HZ_PARTIES';
                        l_table_id      := l_curr_co_rec.co_contact_id1;
                        IF l_table_id = G_MISS_CHAR THEN
                            l_table_id  := NULL;
                        END IF;
                END IF;

                l_added_yn2 := FALSE;

                IF l_table_name IS NOT NULL
                AND l_table_id IS NOT NULL THEN

                    l_cnt2 := 0;
                    FOR l_c_points_rec IN l_c_points_csr (l_table_name, l_table_id) LOOP
                        -- Contact Point is found for a Contact
                        l_added_yn2 := TRUE;
                        l_cnt1 := l_cnt1 + 1;
                        l_cnt2 := l_cnt2 + 1;
                        l_co_point_tbl(l_cnt1) := l_curr_co_rec;
                        l_co_point_tbl(l_cnt1).cp_point_id      := l_c_points_rec.contact_point_id;
                        l_co_point_tbl(l_cnt1).cp_point_type    := l_c_points_rec.contact_point_type;
                        l_co_point_tbl(l_cnt1).cp_primary_flag  := l_c_points_rec.primary_flag;
                        l_co_point_tbl(l_cnt1).cp_email         := l_c_points_rec.email_address;
                        l_co_point_tbl(l_cnt1).cp_details       := l_c_points_rec.contact_point_details;
                        l_co_point_tbl(l_cnt1).cp_order_num     := l_cnt2;
                        l_co_point_tbl(l_cnt1).cp_date_sent     := NULL;

                    END LOOP;
                END IF;
            END LOOP;
                END IF;
          END LOOP;
    END IF;

        -- **************
        -- Return results
        -- **************

        IF  l_contact_id IS NOT NULL
        AND l_co_point_tbl.COUNT = 1
        AND (   l_co_point_tbl(1).cp_point_id IS NULL
             OR l_co_point_tbl(1).cp_point_id = G_MISS_NUM) THEN
                -- No contact point was found
                x_record_count  := 0;
        ELSE
                x_record_count  := l_co_point_tbl.COUNT;
        END IF;

        x_q_party_uv_tbl        := l_co_point_tbl;
        x_return_status         := l_return_status;

        OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;


EXCEPTION

        WHEN OTHERS THEN

                IF (is_debug_exception_on) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                           || sqlcode || ' , SQLERRM : ' || sqlerrm);
                END IF;

                -- Close open cursors
                IF l_c_points_csr%ISOPEN THEN
                        CLOSE l_c_points_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_quote_contact_points;


-- Start of comments
--
-- Procedure Name       : get_party_details
-- Description          : Return OKX party, vendor, site, contact information
-- Business Rules       :
-- Parameters           : quote_id, optional quote_party_id
-- Version              : 1.0
-- End of comments

PROCEDURE get_party_details (
        p_id_code               IN VARCHAR2,
        p_id_value              IN VARCHAR2,
        x_party_object_tbl      OUT NOCOPY party_object_tbl_type,
        x_return_status         OUT NOCOPY VARCHAR2) IS

        l_return_status         VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
        l_cnt                   NUMBER          := 0;

        l_id_code               VARCHAR2(10);
        l_code1                 VARCHAR2(30);
        l_code2                 VARCHAR2(30);
        l_code3                 VARCHAR2(30);
        l_added_yn1             BOOLEAN;
        l_added_yn2             BOOLEAN;
        l_pos                   NUMBER;

        l_party_tbl             party_object_tbl_type;
        l_obj1                  okl_am_util_pvt.jtf_object_tbl_type;
        l_obj2                  okl_am_util_pvt.jtf_object_tbl_type;
        l_obj3                  okl_am_util_pvt.jtf_object_tbl_type;
        l_other_cols            okl_am_util_pvt.select_tbl_type;
        l_where_cond            okl_am_util_pvt.where_tbl_type;

        CURSOR l_c_points_csr (cp_object_id VARCHAR2) IS
                SELECT  c.contact_point_id,
                        c.email_address,
                        c.primary_flag
                FROM    okx_contact_points_v c
                WHERE   c.contact_point_type    = 'EMAIL'
                AND     c.owner_table_name      = 'HZ_PARTIES'
                AND     c.status                = 'A'
                AND     c.owner_table_id        = cp_object_id;

        CURSOR l_chr_contacts_csr (cp_k_party_id NUMBER) IS
                SELECT  cn.jtot_object1_code,
                        cn.object1_id1,
                        cn.object1_id2
                FROM    okc_contacts    cn
                WHERE   cn.cpl_id       = cp_k_party_id
                AND     NVL (cn.start_date, SYSDATE) <= SYSDATE
                AND     NVL (cn.end_date,   SYSDATE) >= SYSDATE;

-- for debug logging
    L_MODULE_NAME VARCHAR2(500) := G_MODULE_NAME||'get_party_details';
    is_debug_exception_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_EXCEPTION);
    is_debug_procedure_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_PROCEDURE);
    is_debug_statement_on boolean := OKL_DEBUG_PUB.Check_Log_On (l_module_name, G_LEVEL_STATEMENT);

BEGIN

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'Begin(+)');
   END IF;
   IF (is_debug_statement_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_id_code : '|| p_id_code );
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,'p_id_value : '||p_id_value );
   END IF;
        IF p_id_code IS NULL
        OR p_id_code = G_MISS_CHAR
        OR p_id_code NOT IN ('P', 'PC', 'V', 'VS', 'VC', 'O')
        OR p_id_value IS NULL
        OR p_id_value = G_MISS_CHAR THEN

                l_return_status := OKL_API.G_RET_STS_ERROR;
                l_id_code       := NULL;

                OKC_API.SET_MESSAGE (
                        p_app_name      => OKC_API.G_APP_NAME,
                        p_msg_name      => 'OKC_NO_PARAMS',
                        p_token1        => 'PARAM',
                        p_token1_value  => 'ID_CODE or ID_VALUE',
                        p_token2        => 'PROCESS',
                        p_token2_value  => 'GET_PARTY_DETAILS');

        ELSE

            l_id_code := p_id_code;

            IF    l_id_code = 'P' THEN
                l_code1 := 'OKX_PARTY';
                l_code2 := 'OKX_PCONTACT';
            ELSIF l_id_code = 'PC' THEN
                l_code1 := 'OKX_PCONTACT';
            ELSIF l_id_code = 'V' THEN
                l_code1 := 'OKX_VENDOR';
                l_code2 := 'OKX_VENDSITE';
                l_code3 := 'OKX_VCONTACT';
            ELSIF l_id_code = 'VS' THEN
                l_code1 := 'OKX_VENDSITE';
                l_code2 := 'OKX_VCONTACT';
            ELSIF l_id_code = 'VC' THEN
                l_code1 := 'OKX_VCONTACT';
            ELSIF l_id_code = 'O' THEN
                NULL;
            END IF;

        END IF;

        IF    l_id_code = 'O' THEN

            l_other_cols(1)     := 'EMAIL_ADDRESS';
            l_other_cols(2)     := 'PERSON_ID';

            FOR l_chr_c_rec IN l_chr_contacts_csr (p_id_value) LOOP

                okl_am_util_pvt.get_object_details (
                        p_object_code   => l_chr_c_rec.jtot_object1_code,
                        p_object_id1    => l_chr_c_rec.object1_id1,
                        p_object_id2    => l_chr_c_rec.object1_id2,
                        p_other_select  => l_other_cols,
                        x_object_tbl    => l_obj1,
                        x_return_status => l_return_status);


                   IF (is_debug_statement_on) THEN
                       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                       'after call to okl_am_util_pvt.get_object_details :'||l_return_status);
                   END IF;

                IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                AND l_obj1.COUNT > 0 THEN
                    FOR l_ind IN l_obj1.FIRST..l_obj1.LAST LOOP
                        l_cnt := l_cnt + 1;
                        l_pos := Instr (l_obj1(l_ind).other_values, okl_am_util_pvt.G_DELIM);
                        l_party_tbl(l_cnt).c_code       := l_obj1(l_ind).object_code;
                        l_party_tbl(l_cnt).c_id1        := l_obj1(l_ind).id1;
                        l_party_tbl(l_cnt).c_id2        := l_obj1(l_ind).id2;
                        l_party_tbl(l_cnt).c_name       := l_obj1(l_ind).name;
                        l_party_tbl(l_cnt).c_desc       := l_obj1(l_ind).description;
                        l_party_tbl(l_cnt).c_email      :=
                                Substr (l_obj1(l_ind).other_values, 1, l_pos - 1);
                        l_party_tbl(l_cnt).c_person_id  :=
                                Substr (l_obj1(l_ind).other_values, l_pos + 1);
                    END LOOP;
                END IF;

            END LOOP;

        ELSIF l_id_code = 'PC' THEN

            l_other_cols(1)     := 'EMAIL_ADDRESS';

            okl_am_util_pvt.get_object_details (
                p_object_code   => l_code1,
                p_object_id1    => p_id_value,
                p_other_select  => l_other_cols,
                x_object_tbl    => l_obj1,
                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details :'||l_return_status);
                END IF;

            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_obj1.COUNT > 0 THEN

                FOR l_ind IN l_obj1.FIRST..l_obj1.LAST LOOP

                    l_added_yn1 := FALSE;

                    FOR l_c_points_rec IN l_c_points_csr (l_obj1(l_ind).id1) LOOP
                        l_added_yn1 := TRUE;
                        l_cnt := l_cnt + 1;
                        l_party_tbl(l_cnt).c_code       := l_obj1(l_ind).object_code;
                        l_party_tbl(l_cnt).c_id1        := l_obj1(l_ind).id1;
                        l_party_tbl(l_cnt).c_id2        := l_obj1(l_ind).id2;
                        l_party_tbl(l_cnt).c_name       := l_obj1(l_ind).name;
                        l_party_tbl(l_cnt).c_desc       := l_obj1(l_ind).description;
                        l_party_tbl(l_cnt).c_email      := l_obj1(l_ind).other_values;
                        l_party_tbl(l_cnt).pcp_id       := l_c_points_rec.contact_point_id;
                        l_party_tbl(l_cnt).pcp_email    := l_c_points_rec.email_address;
                        l_party_tbl(l_cnt).pcp_primary  := l_c_points_rec.primary_flag;
                    END LOOP;

                    IF (NOT l_added_yn1) THEN
                        l_cnt := l_cnt + 1;
                        l_party_tbl(l_cnt).c_code       := l_obj1(l_ind).object_code;
                        l_party_tbl(l_cnt).c_id1        := l_obj1(l_ind).id1;
                        l_party_tbl(l_cnt).c_id2        := l_obj1(l_ind).id2;
                        l_party_tbl(l_cnt).c_name       := l_obj1(l_ind).name;
                        l_party_tbl(l_cnt).c_desc       := l_obj1(l_ind).description;
                        l_party_tbl(l_cnt).c_email      := l_obj1(l_ind).other_values;
                    END IF;

                END LOOP;
            END IF;

        ELSIF l_id_code = 'P' THEN

            okl_am_util_pvt.get_object_details (
                p_object_code   => l_code1,
                p_object_id1    => p_id_value,
                x_object_tbl    => l_obj1,
                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details :'||l_return_status);
                END IF;

            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_obj1.COUNT > 0 THEN

                FOR l_ind1 IN l_obj1.FIRST..l_obj1.LAST LOOP

                    l_added_yn1                         := FALSE;
                    l_other_cols(1)                     := 'EMAIL_ADDRESS';
                    l_where_cond(1).column_name         := 'PARTY_ID';
                    l_where_cond(2).column_name         := 'PARTY_ID2';
                    l_where_cond(1).condition_value     := l_obj1(l_ind1).id1;
                    l_where_cond(2).condition_value     := l_obj1(l_ind1).id2;

                    okl_am_util_pvt.get_object_details (
                        p_object_code   => l_code2,
                        p_other_select  => l_other_cols,
                        p_other_where   => l_where_cond,
                        p_check_status  => 'Y',
                        x_object_tbl    => l_obj2,
                        x_return_status => l_return_status);

                        IF (is_debug_statement_on) THEN
                                OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                                'after call to okl_am_util_pvt.get_object_details :'||l_return_status);
                        END IF;

                    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_obj2.COUNT > 0 THEN

                        FOR l_ind2 IN l_obj2.FIRST..l_obj2.LAST LOOP

                            l_added_yn2 := FALSE;

                            FOR l_c_points_rec IN l_c_points_csr (l_obj2(l_ind2).id1) LOOP
                                l_added_yn1 := TRUE;
                                l_added_yn2 := TRUE;
                                l_cnt := l_cnt + 1;
                                l_party_tbl(l_cnt).p_code       := l_obj1(l_ind1).object_code;
                                l_party_tbl(l_cnt).p_id1        := l_obj1(l_ind1).id1;
                                l_party_tbl(l_cnt).p_id2        := l_obj1(l_ind1).id2;
                                l_party_tbl(l_cnt).p_name       := l_obj1(l_ind1).name;
                                l_party_tbl(l_cnt).p_desc       := l_obj1(l_ind1).description;
                                l_party_tbl(l_cnt).c_code       := l_obj2(l_ind2).object_code;
                                l_party_tbl(l_cnt).c_id1        := l_obj2(l_ind2).id1;
                                l_party_tbl(l_cnt).c_id2        := l_obj2(l_ind2).id2;
                                l_party_tbl(l_cnt).c_name       := l_obj2(l_ind2).name;
                                l_party_tbl(l_cnt).c_desc       := l_obj2(l_ind2).description;
                                l_party_tbl(l_cnt).c_email      := l_obj2(l_ind2).other_values;
                                l_party_tbl(l_cnt).pcp_id       := l_c_points_rec.contact_point_id;
                                l_party_tbl(l_cnt).pcp_email    := l_c_points_rec.email_address;
                                l_party_tbl(l_cnt).pcp_primary  := l_c_points_rec.primary_flag;
                            END LOOP;

                            IF (NOT l_added_yn2) THEN
                                l_added_yn1 := TRUE;
                                l_cnt := l_cnt + 1;
                                l_party_tbl(l_cnt).p_code       := l_obj1(l_ind1).object_code;
                                l_party_tbl(l_cnt).p_id1        := l_obj1(l_ind1).id1;
                                l_party_tbl(l_cnt).p_id2        := l_obj1(l_ind1).id2;
                                l_party_tbl(l_cnt).p_name       := l_obj1(l_ind1).name;
                                l_party_tbl(l_cnt).p_desc       := l_obj1(l_ind1).description;
                                l_party_tbl(l_cnt).c_code       := l_obj2(l_ind2).object_code;
                                l_party_tbl(l_cnt).c_id1        := l_obj2(l_ind2).id1;
                                l_party_tbl(l_cnt).c_id2        := l_obj2(l_ind2).id2;
                                l_party_tbl(l_cnt).c_name       := l_obj2(l_ind2).name;
                                l_party_tbl(l_cnt).c_desc       := l_obj2(l_ind2).description;
                                l_party_tbl(l_cnt).c_email      := l_obj2(l_ind2).other_values;
                            END IF;

                        END LOOP;

                    END IF;

                    FOR l_c_points_rec IN l_c_points_csr (l_obj1(l_ind1).id1) LOOP
                            l_added_yn1 := TRUE;
                            l_cnt := l_cnt + 1;
                            l_party_tbl(l_cnt).p_code   := l_obj1(l_ind1).object_code;
                            l_party_tbl(l_cnt).p_id1    := l_obj1(l_ind1).id1;
                            l_party_tbl(l_cnt).p_id2    := l_obj1(l_ind1).id2;
                            l_party_tbl(l_cnt).p_name   := l_obj1(l_ind1).name;
                            l_party_tbl(l_cnt).p_desc   := l_obj1(l_ind1).description;
                            l_party_tbl(l_cnt).pcp_id           := l_c_points_rec.contact_point_id;
                            l_party_tbl(l_cnt).pcp_email        := l_c_points_rec.email_address;
                            l_party_tbl(l_cnt).pcp_primary      := l_c_points_rec.primary_flag;
                    END LOOP;

                    IF (NOT l_added_yn1) THEN
                            l_cnt := l_cnt + 1;
                            l_party_tbl(l_cnt).p_code   := l_obj1(l_ind1).object_code;
                            l_party_tbl(l_cnt).p_id1    := l_obj1(l_ind1).id1;
                            l_party_tbl(l_cnt).p_id2    := l_obj1(l_ind1).id2;
                            l_party_tbl(l_cnt).p_name   := l_obj1(l_ind1).name;
                            l_party_tbl(l_cnt).p_desc   := l_obj1(l_ind1).description;
                    END IF;

                END LOOP;

            END IF;

        ELSIF l_id_code = 'VC' THEN

            l_other_cols(1)     := 'EMAIL_ADDRESS';

            okl_am_util_pvt.get_object_details (
                p_object_code   => l_code1,
                p_object_id1    => p_id_value,
                p_other_select  => l_other_cols,
                x_object_tbl    => l_obj1,
                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details in VC :'||l_return_status);
                END IF;

            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_obj1.COUNT > 0 THEN
                FOR l_ind IN l_obj1.FIRST..l_obj1.LAST LOOP
                        l_cnt := l_cnt + 1;
                        l_party_tbl(l_cnt).c_code       := l_obj1(l_ind).object_code;
                        l_party_tbl(l_cnt).c_id1        := l_obj1(l_ind).id1;
                        l_party_tbl(l_cnt).c_id2        := l_obj1(l_ind).id2;
                        l_party_tbl(l_cnt).c_name       := l_obj1(l_ind).name;
                        l_party_tbl(l_cnt).c_desc       := l_obj1(l_ind).description;
                        l_party_tbl(l_cnt).c_email      := l_obj1(l_ind).other_values;
                END LOOP;
            END IF;

        ELSIF l_id_code = 'VS' THEN

            okl_am_util_pvt.get_object_details (
                p_object_code   => l_code1,
                p_object_id1    => p_id_value,
                x_object_tbl    => l_obj1,
                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details in VS :'||l_return_status);
                END IF;

            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_obj1.COUNT > 0 THEN

                FOR l_ind1 IN l_obj1.FIRST..l_obj1.LAST LOOP

                    l_other_cols(1)                     := 'EMAIL_ADDRESS';
                    l_where_cond(1).column_name         := 'VENDOR_SITE_ID';
                    l_where_cond(1).condition_value     := l_obj1(l_ind1).id1;

                    okl_am_util_pvt.get_object_details (
                        p_object_code   => l_code2,
                        p_other_select  => l_other_cols,
                        p_other_where   => l_where_cond,
                        p_check_status  => 'Y',
                        x_object_tbl    => l_obj2,
                        x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                END IF;


                    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_obj2.COUNT > 0 THEN
                        FOR l_ind2 IN l_obj2.FIRST..l_obj2.LAST LOOP
                            l_cnt := l_cnt + 1;
                            l_party_tbl(l_cnt).s_code   := l_obj1(l_ind1).object_code;
                            l_party_tbl(l_cnt).s_id1    := l_obj1(l_ind1).id1;
                            l_party_tbl(l_cnt).s_id2    := l_obj1(l_ind1).id2;
                            l_party_tbl(l_cnt).s_name   := l_obj1(l_ind1).name;
                            l_party_tbl(l_cnt).s_desc   := l_obj1(l_ind1).description;
                            l_party_tbl(l_cnt).c_code   := l_obj2(l_ind2).object_code;
                            l_party_tbl(l_cnt).c_id1    := l_obj2(l_ind2).id1;
                            l_party_tbl(l_cnt).c_id2    := l_obj2(l_ind2).id2;
                            l_party_tbl(l_cnt).c_name   := l_obj2(l_ind2).name;
                            l_party_tbl(l_cnt).c_desc   := l_obj2(l_ind2).description;
                            l_party_tbl(l_cnt).c_email  := l_obj2(l_ind2).other_values;
                        END LOOP;
                    ELSE
                            l_cnt := l_cnt + 1;
                            l_party_tbl(l_cnt).s_code   := l_obj1(l_ind1).object_code;
                            l_party_tbl(l_cnt).s_id1    := l_obj1(l_ind1).id1;
                            l_party_tbl(l_cnt).s_id2    := l_obj1(l_ind1).id2;
                            l_party_tbl(l_cnt).s_name   := l_obj1(l_ind1).name;
                            l_party_tbl(l_cnt).s_desc   := l_obj1(l_ind1).description;
                    END IF;

                END LOOP;

            END IF;

        ELSIF l_id_code = 'V' THEN

            okl_am_util_pvt.get_object_details (
                p_object_code   => l_code1,
                p_object_id1    => p_id_value,
                x_object_tbl    => l_obj1,
                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                END IF;


            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
            AND l_obj1.COUNT > 0 THEN

                FOR l_ind1 IN l_obj1.FIRST..l_obj1.LAST LOOP

                    l_where_cond(1).column_name         := 'VENDOR_ID';
                    l_where_cond(1).condition_value     := l_obj1(l_ind1).id1;

                    okl_am_util_pvt.get_object_details (
                        p_object_code   => l_code2,
                        p_other_where   => l_where_cond,
                        p_check_status  => 'Y',
                        x_object_tbl    => l_obj2,
                        x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                END IF;


                    IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                    AND l_obj2.COUNT > 0 THEN

                        FOR l_ind2 IN l_obj2.FIRST..l_obj2.LAST LOOP

                            l_other_cols(1)                     := 'EMAIL_ADDRESS';
                            l_where_cond(1).column_name         := 'VENDOR_SITE_ID';
                            l_where_cond(1).condition_value     := l_obj2(l_ind2).id1;

                            okl_am_util_pvt.get_object_details (
                                p_object_code   => l_code3,
                                p_other_select  => l_other_cols,
                                p_other_where   => l_where_cond,
                                p_check_status  => 'Y',
                                x_object_tbl    => l_obj3,
                                x_return_status => l_return_status);

                IF (is_debug_statement_on) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_STATEMENT,L_MODULE_NAME,
                        'after call to okl_am_util_pvt.get_object_details  :'||l_return_status);
                END IF;

                            IF  l_return_status = OKL_API.G_RET_STS_SUCCESS
                            AND l_obj3.COUNT > 0 THEN

                                FOR l_ind3 IN l_obj3.FIRST..l_obj3.LAST LOOP
                                    l_cnt := l_cnt + 1;
                                    l_party_tbl(l_cnt).p_code   := l_obj1(l_ind1).object_code;
                                    l_party_tbl(l_cnt).p_id1    := l_obj1(l_ind1).id1;
                                    l_party_tbl(l_cnt).p_id2    := l_obj1(l_ind1).id2;
                                    l_party_tbl(l_cnt).p_name   := l_obj1(l_ind1).name;
                                    l_party_tbl(l_cnt).p_desc   := l_obj1(l_ind1).description;
                                    l_party_tbl(l_cnt).s_code   := l_obj2(l_ind2).object_code;
                                    l_party_tbl(l_cnt).s_id1    := l_obj2(l_ind2).id1;
                                    l_party_tbl(l_cnt).s_id2    := l_obj2(l_ind2).id2;
                                    l_party_tbl(l_cnt).s_name   := l_obj2(l_ind2).name;
                                    l_party_tbl(l_cnt).s_desc   := l_obj2(l_ind2).description;
                                    l_party_tbl(l_cnt).c_code   := l_obj3(l_ind3).object_code;
                                    l_party_tbl(l_cnt).c_id1    := l_obj3(l_ind3).id1;
                                    l_party_tbl(l_cnt).c_id2    := l_obj3(l_ind3).id2;
                                    l_party_tbl(l_cnt).c_name   := l_obj3(l_ind3).name;
                                    l_party_tbl(l_cnt).c_desc   := l_obj3(l_ind3).description;
                                    l_party_tbl(l_cnt).c_email  := l_obj3(l_ind3).other_values;
                                END LOOP;

                            ELSE
                                    l_cnt := l_cnt + 1;
                                    l_party_tbl(l_cnt).p_code   := l_obj1(l_ind1).object_code;
                                    l_party_tbl(l_cnt).p_id1    := l_obj1(l_ind1).id1;
                                    l_party_tbl(l_cnt).p_id2    := l_obj1(l_ind1).id2;
                                    l_party_tbl(l_cnt).p_name   := l_obj1(l_ind1).name;
                                    l_party_tbl(l_cnt).p_desc   := l_obj1(l_ind1).description;
                                    l_party_tbl(l_cnt).s_code   := l_obj2(l_ind2).object_code;
                                    l_party_tbl(l_cnt).s_id1    := l_obj2(l_ind2).id1;
                                    l_party_tbl(l_cnt).s_id2    := l_obj2(l_ind2).id2;
                                    l_party_tbl(l_cnt).s_name   := l_obj2(l_ind2).name;
                                    l_party_tbl(l_cnt).s_desc   := l_obj2(l_ind2).description;
                            END IF;

                        END LOOP;

                    ELSE
                                    l_cnt := l_cnt + 1;
                                    l_party_tbl(l_cnt).p_code   := l_obj1(l_ind1).object_code;
                                    l_party_tbl(l_cnt).p_id1    := l_obj1(l_ind1).id1;
                                    l_party_tbl(l_cnt).p_id2    := l_obj1(l_ind1).id2;
                                    l_party_tbl(l_cnt).p_name   := l_obj1(l_ind1).name;
                                    l_party_tbl(l_cnt).p_desc   := l_obj1(l_ind1).description;
                    END IF;

                END LOOP;

            END IF;

        END IF;

        x_party_object_tbl      := l_party_tbl;
        x_return_status         := l_return_status;

   IF (is_debug_procedure_on) THEN
       OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_PROCEDURE,L_MODULE_NAME,'End(-)');
   END IF;

EXCEPTION

        WHEN OTHERS THEN

        IF (is_debug_exception_on) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(G_LEVEL_EXCEPTION,L_MODULE_NAME, 'EXCEPTION :'||'OTHERS, SQLCODE: '
                   || sqlcode || ' , SQLERRM : ' || sqlerrm);
        END IF;

                -- Close open cursors
                IF l_c_points_csr%ISOPEN THEN
                        CLOSE l_c_points_csr;
                END IF;
                IF l_chr_contacts_csr%ISOPEN THEN
                        CLOSE l_chr_contacts_csr;
                END IF;

                -- store SQL error message on message stack for caller
                OKL_API.SET_MESSAGE (
                         p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => sqlcode
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => sqlerrm);

                -- notify caller of an UNEXPECTED error
                x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END get_party_details;


END okl_am_parties_pvt;

/
