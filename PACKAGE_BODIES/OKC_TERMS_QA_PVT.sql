--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_QA_PVT" AS
/* $Header: OKCVDQAB.pls 120.22.12010000.8 2011/12/12 06:57:43 vechittu ship $ */

    ---------------------------------------------------------------------------
    -- GLOBAL MESSAGE CONSTANTS
    ---------------------------------------------------------------------------
    G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
    G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
    G_INVALID_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
    G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
    G_OKC_MSG_INVALID_ARGUMENT   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_INVALID_ARGUMENT';
    -- ARG_NAME ARG_VALUE is invalid.
    ---------------------------------------------------------------------------
    -- GLOBAL CONSTANTS
    ---------------------------------------------------------------------------
    G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_QA_PVT';
    G_MODULE                     CONSTANT   VARCHAR2(250)   := 'okc.plsql.'||G_PKG_NAME||'.';
    G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
    G_TMPL_DOC_TYPE              CONSTANT   VARCHAR2(30)  := OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE;

    G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
    G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;
    G_OKC                        CONSTANT   VARCHAR2(3) := 'OKC';

    G_QA_STS_SUCCESS             CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_SUCCESS;
    G_QA_STS_ERROR               CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_ERROR;
    G_QA_STS_WARNING             CONSTANT   varchar2(1) := OKC_TERMS_QA_GRP.G_QA_STS_WARNING;

    G_RET_STS_SUCCESS            CONSTANT   varchar2(1) := FND_API.G_RET_STS_SUCCESS;
    G_RET_STS_ERROR              CONSTANT   varchar2(1) := FND_API.G_RET_STS_ERROR;
    G_RET_STS_UNEXP_ERROR        CONSTANT   varchar2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

    G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
    G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
    G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
    G_ART_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'ARTICLE';
    G_TMPL_QA_TYPE               CONSTANT   VARCHAR2(30)  := 'TEMPLATE';
    G_SCN_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'SECTION';
    G_DLV_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'DELIVERABLE';
    G_EXP_QA_TYPE                CONSTANT   VARCHAR2(30)  := 'CONTRACT_EXPERT';
    G_QA_LOOKUP                  CONSTANT   VARCHAR2(30)  := 'OKC_TERM_QA_LIST';
    G_INCOMPATIBLE               CONSTANT   VARCHAR2(30)  := 'INCOMPATIBLE';
    G_ALTERNATE                  CONSTANT   VARCHAR2(30)  := 'ALTERNATE';
    G_AMEND_CODE_DELETED         CONSTANT   VARCHAR2(30)  := 'DELETED';
    G_UNASSIGNED_SECTION_CODE    CONSTANT   VARCHAR2(30)  := 'UNASSIGNED';
    G_CONTRACT                   CONSTANT   VARCHAR2(30)  := 'CONTRACT';


                      -- QA Checks --

    G_CHECK_INCOMPATIBILITY    CONSTANT VARCHAR2(30) := 'CHECK_INCOMPATIBILITY';
    G_CHECK_ALTERNATE          CONSTANT VARCHAR2(30) := 'CHECK_ALTERNATE';
    G_CHECK_DUPLICATE          CONSTANT VARCHAR2(30) := 'CHECK_DUPLICATE';
    G_CHECK_ART_VALIDITY       CONSTANT VARCHAR2(30) := 'CHECK_ART_VALIDITY';
    G_CHECK_LATEST_VERSION     CONSTANT VARCHAR2(30) := 'CHECK_LATEST_VERSION';
    G_CHECK_UNRESOLVED_SYS_VAR CONSTANT VARCHAR2(30) := 'CHECK_UNRESOLVED_SYS_VAR';
    G_CHECK_VAR_USAGE          CONSTANT VARCHAR2(30) := 'CHECK_VAR_USAGE';
    G_CHECK_EXT_VAR_VALUE      CONSTANT VARCHAR2(30) := 'CHECK_EXT_VAR_VALUE';
    G_CHECK_INT_VAR_VALUE      CONSTANT VARCHAR2(30) := 'CHECK_INT_VAR_VALUE';
    G_CHECK_UNASSIGNED_ART     CONSTANT VARCHAR2(30) := 'CHECK_UNASSIGNED_ARTICLE';
    G_CHECK_EMPTY_SECTION      CONSTANT VARCHAR2(30) := 'CHECK_EMPTY_SECTION';
    G_CHECK_SCN_AMEND_NO_TEXT  CONSTANT VARCHAR2(30) := 'CHECK_SCN_AMEND_NO_TEXT';
    G_CHECK_ART_AMEND_NO_TEXT  CONSTANT VARCHAR2(30) := 'CHECK_ART_AMEND_NO_TEXT';
    G_CHECK_TMPL_EFFECTIVITY   CONSTANT VARCHAR2(30) := 'CHECK_TEMPL_EFFECTIVITY';
    G_CHECK_LAYOUT_TMPL        CONSTANT VARCHAR2(30) := 'CHECK_LAYOUT_TMPL';
    G_OKC_CHECK_LOCK_CONTRACT  CONSTANT VARCHAR2(30) := 'CHECK_LOCK_CONTRACT';
    G_OKC_CHECK_CONTRACT_ADMIN  CONSTANT VARCHAR2(30) := 'CHECK_CONTRACT_ADMIN';
    -- For Bug# 6979012
    G_CHECK_ART_REJECTED       CONSTANT VARCHAR2(30) := 'CHECK_ART_REJECTED';

    G_CHECK_ART_EXT                    CONSTANT    VARCHAR2(30) := 'CHECK_ART_EXT';
    G_CHECK_ART_TYP                    CONSTANT    VARCHAR2(30) := 'CHECK_ART_INV_TYP';
    G_CHECK_ART_DEF_SEC                CONSTANT    VARCHAR2(30) := 'CHECK_ART_DEF_SEC';
    G_CHECK_ART_INV_VAR                CONSTANT    VARCHAR2(30) := 'CHECK_ART_INV_VAR';
    G_CHECK_ART_INV_VAL                CONSTANT    VARCHAR2(30) := 'CHECK_ART_INV_VAL';
    G_CHECK_TRANS_TMPL_REVISION        CONSTANT    VARCHAR2(30) := 'CHECK_TRANS_TMPL_REV';
    G_CHECK_TRANS_TMPL_EFF             CONSTANT    VARCHAR2(30) := 'CHECK_TRANS_TMPL_EFF';

    /* expert commented out
    G_CHECK_RUL_INC                    CONSTANT    VARCHAR2(30) := 'CHECK_RUL_INC';
    G_CHECK_RUL_ALT                    CONSTANT    VARCHAR2(30) := 'CHECK_RUL_ALT';
    G_CHECK_RUL_DUP                    CONSTANT    VARCHAR2(30) := 'CHECK_RUL_DUP';
    G_CHECK_RUL_VAR_DOC                CONSTANT    VARCHAR2(30) := 'CHECK_RUL_VAR_DOC';
    G_CHECK_RUL_ART_VAL                CONSTANT    VARCHAR2(30) := 'CHECK_RUL_ART_VAL';
    */
                      -- QA Error messages --

    G_OKC_CHECK_INCOMPATIBILITY CONSTANT VARCHAR2(30) := 'OKC_CHECK_INCOMPATIBILITY';
    G_OKC_CHECK_ALTERNATE       CONSTANT VARCHAR2(30) := 'OKC_CHECK_ALTERNATE';
    G_OKC_CHECK_DUPLICATE       CONSTANT VARCHAR2(30) := 'OKC_CHECK_DUPLICATE';
    G_OKC_CHECK_ART_VALIDITY    CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_VALIDITY';
    G_OKC_CHECK_TMPL_ART_VALIDITY    CONSTANT VARCHAR2(30) := 'OKC_CHECK_TMPL_ART_VALIDITY';
    G_OKC_CHECK_LATEST_VERSION  CONSTANT VARCHAR2(30) := 'OKC_CHECK_LATEST_VERSION';
    G_OKC_CHECK_UNRES_SYS_VAR   CONSTANT VARCHAR2(30) := 'OKC_CHECK_UNRES_SYS_VAR';
    G_OKC_CHECK_VAR_USAGE        CONSTANT VARCHAR2(30) := 'OKC_CHECK_VAR_USAGE';
    G_OKC_CHECK_EXT_VAR_VALUE    CONSTANT VARCHAR2(30) := 'OKC_CHECK_EXT_VAR_VALUE';
    G_OKC_CHECK_INT_VAR_VALUE    CONSTANT VARCHAR2(30) := 'OKC_CHECK_INT_VAR_VALUE';
    G_OKC_CHECK_UNASSIGNED_ART   CONSTANT VARCHAR2(30) := 'OKC_CHECK_UNASSIGNED_ART';
    G_OKC_CHECK_EMPTY_SECTION    CONSTANT VARCHAR2(30) := 'OKC_CHECK_EMPTY_SECTION';
    G_OKC_CHECK_SCN_AMEND_NO_TEXT    CONSTANT VARCHAR2(30) := 'OKC_CHECK_SCN_AMEND_NO_TEXT';
    G_OKC_CHECK_ART_AMEND_NO_TEXT    CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_AMEND_NO_TEXT';
    G_OKC_CHECK_TMPL_EFFECTIVITY    CONSTANT VARCHAR2(30) := 'OKC_CHECK_TEMPL_EFFECTIVITY';
    --Bug 4126819
    G_OKC_CHECK_TEMPL_USG_ASSO   CONSTANT VARCHAR2(30) := 'OKC_CHECK_TEMPL_USG_ASSO';
    G_OKC_CHECK_LAYOUT_TMPL      CONSTANT VARCHAR2(30) := 'OKC_CHECK_LAYOUT_TMPL';
    -- For Bug# 6979012
    G_OKC_CHECK_ART_REJECTED      CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_REJECTED';

    G_OKC_CHECK_ART_EXT                CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_EXT';
    G_OKC_CHECK_ART_TYP                CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_TYP';
    G_OKC_CHECK_ART_DEF_SEC            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_DEF_SEC';
    G_OKC_CHECK_ART_INV_VAR            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAR';
    G_OKC_CHECK_ART_INV_VAL            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAL';
    G_OKC_CHECK_TRANS_TMPL_REV         CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_REV';
    G_OKC_CHECK_TRANS_TMPL_EFF         CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_EFF';

    /* expert commented out
    G_OKC_CHECK_RUL_INC                CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_INC';
    G_OKC_CHECK_RUL_ALT                CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_ALT';
    G_OKC_CHECK_RUL_DUP                CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_DUP';
    G_OKC_CHECK_RUL_VAR_DOC            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_VAR_DOC';
    G_OKC_CHECK_RUL_ART_VAL            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_ART_VAL';
    */
                      -- QA Error messages (Short)--

    G_OKC_CHECK_INCOMPATIBILITY_SH CONSTANT VARCHAR2(50) := 'OKC_CHECK_INCOMPATIBILITY_SH';
    G_OKC_CHECK_ALTERNATE_SH       CONSTANT VARCHAR2(50) := 'OKC_CHECK_ALTERNATE_SH';
    G_OKC_CHECK_DUPLICATE_SH       CONSTANT VARCHAR2(50) := 'OKC_CHECK_DUPLICATE_SH';
    G_OKC_CHECK_ART_VALIDITY_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_ART_VALIDITY_SH';
    G_OKC_CHECK_TMPL_ART_VALID_SH    CONSTANT VARCHAR2(30) := 'OKC_CHECK_TMPL_ART_VALIDITY_SH';
    G_OKC_CHECK_LATEST_VERSION_SH  CONSTANT VARCHAR2(50) := 'OKC_CHECK_LATEST_VERSION_SH';
    G_OKC_CHECK_UNRES_SYS_VAR_SH   CONSTANT VARCHAR2(50) := 'OKC_CHECK_UNRES_SYS_VAR_SH';
    G_OKC_CHECK_VAR_USAGE_SH        CONSTANT VARCHAR2(50) := 'OKC_CHECK_VAR_USAGE_SH';
    G_OKC_CHECK_EXT_VAR_VALUE_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_EXT_VAR_VALUE_SH';
    G_OKC_CHECK_INT_VAR_VALUE_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_INT_VAR_VALUE_SH';
    G_OKC_CHECK_UNASSIGNED_ART_SH   CONSTANT VARCHAR2(50) := 'OKC_CHECK_UNASSIGNED_ART_SH';
    G_OKC_CHECK_EMPTY_SECTION_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_EMPTY_SECTION_SH';
    G_OKC_CHK_SCN_AMEND_NO_TEXT_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_SCN_AMEND_NO_TEXT_SH';
    G_OKC_CHK_ART_AMEND_NO_TEXT_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_ART_AMEND_NO_TEXT_SH';
    G_OKC_CHK_TMPL_EFFECTIVITY_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_TEMPL_EFFECTIVITY_SH';
    --Bug 4126819
    G_OKC_CHECK_TEMPL_USG_ASSO_SH    CONSTANT VARCHAR2(50) := 'OKC_CHECK_TEMPL_USG_ASSO_SH';

    G_OKC_CHECK_ART_EXT_SH            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_EXT_SH';
    G_OKC_CHECK_ART_TYP_SH            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_TYP_SH';
    G_OKC_CHECK_ART_DEF_SEC_SH        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_DEF_SEC_SH';
    G_OKC_CHECK_ART_INV_VAR_SH        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAR_SH';
    G_OKC_CHECK_ART_INV_VAL_SH        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAL_SH';
    G_OKC_CHECK_TRANS_TMPL_REV_SH     CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_REV_SH';
    G_OKC_CHECK_TRANS_TMPL_EFF_SH     CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_EFF_SH';
    G_OKC_CHECK_LOCK_CONTRACT_SH      CONSTANT    VARCHAR2(30) := 'OKC_CHECK_LOCK_CONTRACT_SH';
    G_OKC_CHECK_CTRT_ADMIN_SH         CONSTANT    VARCHAR2(30) := 'OKC_CHECK_CTRT_ADMIN_SH';
    G_OKC_CTRT_ADMIN_EMP_SH            CONSTANT    VARCHAR2(30) := 'OKC_CTRT_ADMIN_EMP_SH';
    G_OKC_ADMIN_VALID_EMP_SH           CONSTANT    VARCHAR2(30) := 'OKC_ADMIN_VALID_EMP_SH';
    G_OKC_CTRT_ADMIN_EMP_DT            CONSTANT    VARCHAR2(30) := 'OKC_CTRT_ADMIN_EMP_DT';
    G_OKC_ADMIN_VALID_EMP_DT           CONSTANT    VARCHAR2(30) := 'OKC_ADMIN_VALID_EMP_DT';

    /* expert commented out
    G_OKC_CHECK_RUL_INC_SH            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_INC_SH';
    G_OKC_CHECK_RUL_ALT_SH            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_ALT_SH';
    G_OKC_CHECK_RUL_DUP_SH            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_DUP_SH';
    G_OKC_CHECK_RUL_VAR_DOC_SH        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_VAR_DOC_SH';
    G_OKC_CHECK_RUL_ART_VAL_SH        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_ART_VAL_SH';
    */
                      -- QA Suggestion messages --

    G_OKC_CHECK_INCOMPATIBILITY_S CONSTANT VARCHAR2(30) := 'OKC_CHECK_INCOMPATIBILITY_S';
    G_OKC_CHECK_ALTERNATE_S       CONSTANT VARCHAR2(30) := 'OKC_CHECK_ALTERNATE_S';
    G_OKC_CHECK_DUPLICATE_S       CONSTANT VARCHAR2(30) := 'OKC_CHECK_DUPLICATE_S';
    G_OKC_CHECK_ART_VALIDITY_S    CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_VALIDITY_S';
    G_OKC_CHECK_TMPL_ART_VALID_S    CONSTANT VARCHAR2(30) := 'OKC_CHECK_TMPL_ART_VALIDITY_S';
    G_OKC_CHECK_LATEST_VERSION_S  CONSTANT VARCHAR2(30) := 'OKC_CHECK_LATEST_VERSION_S';
    G_OKC_CHECK_UNRES_SYS_VAR_S   CONSTANT VARCHAR2(30) := 'OKC_CHECK_UNRES_SYS_VAR_S';
    G_OKC_CHECK_VAR_USAGE_S       CONSTANT VARCHAR2(30) := 'OKC_CHECK_VAR_USAGE_S';
    G_OKC_CHECK_EXT_VAR_VALUE_S   CONSTANT VARCHAR2(30) := 'OKC_CHECK_EXT_VAR_VALUE_S';
    G_OKC_CHECK_INT_VAR_VALUE_S   CONSTANT VARCHAR2(30) := 'OKC_CHECK_INT_VAR_VALUE_S';
    G_OKC_CHECK_UNASSIGNED_ART_S  CONSTANT VARCHAR2(30) := 'OKC_CHECK_UNASSIGNED_ART_S';
    G_OKC_CHECK_EMPTY_SECTION_S   CONSTANT VARCHAR2(30) := 'OKC_CHECK_EMPTY_SECTION_S';
    G_OKC_CHK_SCN_AMEND_NO_TEXT_S CONSTANT VARCHAR2(30) := 'OKC_CHECK_SCN_AMEND_NO_TEXT_S';
    G_OKC_CHK_ART_AMEND_NO_TEXT_S CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_AMEND_NO_TEXT_S';
    G_OKC_CHECK_TMPL_EFFECTIVITY_S CONSTANT VARCHAR2(30) := 'OKC_CHECK_TEMPL_EFFECTIVITY_S';
    --Bug 4126819
    G_OKC_CHECK_TEMPL_USG_ASSO_S CONSTANT VARCHAR2(30) := 'OKC_CHECK_TEMPL_USG_ASSO_S';
    G_OKC_CHECK_LAYOUT_TMPL_S     CONSTANT VARCHAR2(30) := 'OKC_CHECK_LAYOUT_TMPL_S';
    -- For Bug# 6979012
    G_OKC_CHECK_ART_REJECTED_S     CONSTANT VARCHAR2(30) := 'OKC_CHECK_ART_REJECTED_S';

    G_OKC_CHECK_ART_EXT_S            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_EXT_S';
    G_OKC_CHECK_ART_TYP_S            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_TYP_S';
    G_OKC_CHECK_ART_DEF_SEC_S        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_DEF_SEC_S';
    G_OKC_CHECK_ART_INV_VAR_S        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAR_S';
    G_OKC_CHECK_ART_INV_VAL_S        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_INV_VAL_S';
    G_OKC_CHECK_TRANS_TMPL_REV_S     CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_REV_S';
    G_OKC_CHECK_TRANS_TMPL_EFF_S     CONSTANT    VARCHAR2(30) := 'OKC_CHECK_TRANS_TMPL_EFF_S';
    G_OKC_CHECK_LOCK_CONTRACT_S      CONSTANT    VARCHAR2(30) := 'OKC_CHECK_LOCK_CONTRACT_S';
    G_OKC_CHECK_CTRT_ADMIN_S         CONSTANT    VARCHAR2(30) := 'OKC_CHECK_CTRT_ADMIN_S';
    G_OKC_CTRT_ADMIN_EMP_S           CONSTANT    VARCHAR2(30) := 'OKC_CTRT_ADMIN_EMP_S';
    G_OKC_ADMIN_VALID_EMP_S          CONSTANT    VARCHAR2(30) := 'OKC_ADMIN_VALID_EMP_S';
    G_OKC_ADMIN_EMP_SUGG             CONSTANT    VARCHAR2(30) := 'OKC_ADMIN_EMP_SUGG';
    G_OKC_ADMIN_VALID_EMP_SUGG       CONSTANT    VARCHAR2(30) := 'OKC_ADMIN_VALID_EMP_SUGG';
    /* expert commented out
    G_OKC_CHECK_RUL_INC_S            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_INC_S';
    G_OKC_CHECK_RUL_ALT_S            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_ALT_S';
    G_OKC_CHECK_RUL_DUP_S            CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_DUP_S';
    G_OKC_CHECK_RUL_VAR_DOC_S        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_RUL_VAR_DOC_S';
    G_OKC_CHECK_RUL_ART_VAL_S        CONSTANT    VARCHAR2(30) := 'OKC_CHECK_ART_VAL_DOC_S';
    */
    ---------------------------------------------------------------------------
    -- GLOBAL VARIABLES
    ------------------------------------------------------------------------------
    TYPE article_rec_type IS RECORD (
        id                       OKC_K_ARTICLES_B.ID%TYPE,
        article_id               OKC_K_ARTICLES_B.SAV_SAE_ID%TYPE,
        article_version_id       OKC_K_ARTICLES_B.ARTICLE_VERSION_ID%TYPE,
        amendment_operation_code OKC_K_ARTICLES_B.amendment_operation_code%TYPE,
        amendment_description    OKC_K_ARTICLES_B.amendment_description%TYPE,
        scn_id                   OKC_K_ARTICLES_B.scn_id%TYPE,
        title                    OKC_QA_ERRORS_T.title%TYPE,
        std_art_id               OKC_K_ARTICLES_B.SAV_SAE_ID%TYPE
    );

    /* expert commented out
    -- new type to store xprt clause details
    TYPE xprt_article_rec_type IS RECORD (
        article_id                    OKC_ARTICLES_ALL.ARTICLE_ID%TYPE,
        article_version_id            OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
        title                        OKC_QA_ERRORS_T.title%TYPE,
        rule_id                        OKC_XPRT_CLAUSES_V.rule_id%TYPE,
        rule_name                    OKC_XPRT_CLAUSES_V.rule_name%TYPE
    );
    */

    TYPE section_rec_type IS RECORD (
        id                       OKC_SECTIONS_B.ID%TYPE,
        amendment_operation_code OKC_SECTIONS_B.amendment_operation_code%TYPE,
        amendment_description    OKC_SECTIONS_B.amendment_description%TYPE,
        scn_id                   OKC_SECTIONS_B.scn_id%TYPE,
        heading                  OKC_QA_ERRORS_T.section_name%TYPE,
        scn_code                 OKC_SECTIONS_B.scn_code%TYPE
    );

    TYPE qa_detail_type IS RECORD (
        qa_code             FND_LOOKUPS.LOOKUP_CODE%TYPE,
        qa_name             FND_LOOKUPS.MEANING%TYPE,
        severity_flag       OKC_DOC_QA_LISTS.SEVERITY_FLAG%TYPE,
        perform_qa           VARCHAR2(1)
    );

    TYPE qa_detail_tbl_type IS TABLE OF qa_detail_type INDEX BY BINARY_INTEGER;
    TYPE article_tbl_type IS TABLE OF article_rec_type INDEX BY BINARY_INTEGER;
    TYPE section_tbl_type IS TABLE OF section_rec_type INDEX BY BINARY_INTEGER;

    /* expert commented out
    TYPE xprt_article_tbl_type IS TABLE OF xprt_article_rec_type INDEX BY BINARY_INTEGER;
    */

    g_validation_level      VARCHAR2(1);
    g_expert_enabled        VARCHAR2(1);
    g_start_date            DATE;
    g_end_date              DATE;
    g_status_code           OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE;
    g_template_name         OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
    g_org_id                NUMBER;

    l_qa_detail_tbl                qa_detail_tbl_type;
    l_article_tbl                article_tbl_type;
    l_section_tbl                section_tbl_type;
    l_article_effective_date    DATE ;

    /* expert commented out
    l_xprt_article_tbl            xprt_article_tbl_type;
    */
--<<<<<<<<<<<<<<<<<< INTERNAL Simple API PROCEDURES for OKC_QA_ERRORS_T <<<<<<<<<<<<<<<<<<

    ---------------------------------------------------------------------------
    -- FUNCTION do_validation
    ---------------------------------------------------------------------------
    /* new function to check the validation level */

    FUNCTION do_validation (
        p_severity        IN VARCHAR2,
        p_doc_type        IN VARCHAR2) RETURN BOOLEAN
    IS

        l_api_name         CONSTANT VARCHAR2(30) := 'do_validation';

    BEGIN

        IF (p_doc_type = 'TEMPLATE') THEN
            IF  (g_validation_level  = 'A') THEN
                -- always do validations
                RETURN TRUE;
            ELSE
                -- do only  error checks (now g_validation_level = 'E')
                IF (p_severity = 'E') THEN
                    RETURN TRUE;
                ELSE
                    RETURN FALSE;
                END IF;
            END IF;
        ELSE
            -- for non TEMPLATE doc types always return true.
            RETURN TRUE;
        END IF;

    END do_validation;

    ---------------------------------------------------------------------------
    -- FUNCTION get_seq_id
    ---------------------------------------------------------------------------
    FUNCTION get_seq_id (
        x_sequence_id        OUT NOCOPY NUMBER)RETURN VARCHAR2
    IS

        l_api_name         CONSTANT VARCHAR2(30) := 'get_seq_id';
        CURSOR l_seq_csr IS
            SELECT OKC_QA_ERRORS_T_S.NEXTVAL FROM DUAL;

    BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered get_seq_id');
        END IF;

        OPEN l_seq_csr;
        FETCH l_seq_csr INTO x_sequence_id       ;
        IF l_seq_csr%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
        END IF;
        CLOSE l_seq_csr;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'200: Leaving get_seq_id');
        END IF;
        RETURN G_RET_STS_SUCCESS;
    EXCEPTION
        WHEN OTHERS THEN

            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving get_seq_id because of EXCEPTION: '||sqlerrm);
            END IF;

            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;

            IF l_seq_csr%ISOPEN THEN
                CLOSE l_seq_csr;
            END IF;

            RETURN G_RET_STS_UNEXP_ERROR ;

    END get_seq_id;

    ------------------------------------------------
    -- PROCEDURE insert_row for:OKC_QA_ERRORS_T --
    ------------------------------------------------
    FUNCTION insert_row(
        p_document_type      IN VARCHAR2,
        p_document_id        IN NUMBER,
        p_sequence_id        IN NUMBER,
        p_error_record_type  IN VARCHAR2,
        p_title              IN VARCHAR2,
        p_error_severity     IN VARCHAR2,
        p_qa_code            IN VARCHAR2,
        p_message_name       IN VARCHAR2,
        p_problem_short_desc IN VARCHAR2,
        p_problem_details_short    IN VARCHAR2,
        p_problem_details    IN VARCHAR2,
        p_Sgestion         IN VARCHAR2,
        p_article_id         IN NUMBER,
        p_deliverable_id     IN NUMBER,
        p_section_name       IN VARCHAR2,
        p_reference_column1  IN VARCHAR2,
        p_reference_column2  IN VARCHAR2,
        p_reference_column3  IN VARCHAR2,
        p_reference_column4  IN VARCHAR2,
        p_reference_column5  IN VARCHAR2,
        p_creation_date      IN DATE,
        p_error_record_type_name IN VARCHAR2,
        p_error_severity_name IN VARCHAR2 )RETURN VARCHAR2
    IS

        l_api_name         CONSTANT VARCHAR2(30) := 'Insert_Row';

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'700: Entered Insert_Row function');
        END IF;

        INSERT INTO OKC_QA_ERRORS_T
        (
            DOCUMENT_TYPE,
            DOCUMENT_ID,
            SEQUENCE_ID,
            ERROR_RECORD_TYPE,
            TITLE,
            ERROR_SEVERITY,
            QA_CODE,
            MESSAGE_NAME,
            PROBLEM_SHORT_DESC,
            PROBLEM_DETAILS_SHORT,
            PROBLEM_DETAILS,
            SUGGESTION,
            ARTICLE_ID,
            DELIVERABLE_ID,
            SECTION_NAME,
            REFERENCE_COLUMN1,
            REFERENCE_COLUMN2,
            REFERENCE_COLUMN3,
            REFERENCE_COLUMN4,
            REFERENCE_COLUMN5,
            CREATION_DATE,
            ERROR_RECORD_TYPE_NAME,
            ERROR_SEVERITY_NAME
        )
        VALUES
        (
            p_document_type,
            p_document_id,
            p_sequence_id,
            p_error_record_type,
            p_title,
            p_error_severity,
            p_qa_code,
            p_message_name,
            p_problem_short_desc,
            p_problem_details_short,
            p_problem_details,
            p_Sgestion,
            p_article_id,
            p_deliverable_id,
            p_section_name,
            p_reference_column1,
            p_reference_column2,
            p_reference_column3,
            p_reference_column4,
            p_reference_column5,
            p_creation_date,
            p_error_record_type_name,
            p_error_severity_name
        );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'800: Leaving Insert_Row');
        END IF;

        RETURN( G_RET_STS_SUCCESS );

    EXCEPTION
        WHEN OTHERS THEN

            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'900: Leaving Insert_Row:OTHERS Exception');
            END IF;

            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;

            RETURN( G_RET_STS_UNEXP_ERROR );

    END insert_row;



    -------------------------------------
    -- FUNCTION get_article_title
    -------------------------------------
    FUNCTION get_article_title (
        p_cat_id        IN  NUMBER) RETURN VARCHAR2
    IS

        l_article_title   OKC_QA_ERRORS_T.TITLE%TYPE;

    BEGIN
        IF l_article_tbl.COUNT > 0 THEN
            FOR i IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP
                IF l_article_tbl(i).id=p_cat_id THEN
                    l_article_title := substr(l_article_tbl(i).title,1,240);
                    Exit;
                END IF;
            END LOOP;
        END IF; -- IF l_article_tbl.count > 0 THEN
        Return l_article_title;
    END get_article_title;

    -------------------------------------
    -- FUNCTION get_section_title
    -------------------------------------
    FUNCTION get_section_title (
        p_scn_id        IN  NUMBER
    ) RETURN VARCHAR2
    IS

        l_section_title   OKC_QA_ERRORS_T.TITLE%TYPE;

    BEGIN
        IF l_section_tbl.COUNT > 0 THEN
            FOR i IN l_section_tbl.FIRST..l_section_tbl.LAST LOOP
                IF l_section_tbl(i).id = p_scn_id THEN
                    l_section_title := substr(l_section_tbl(i).heading,1,240);
                    Exit;
                END IF;
            END LOOP;
        END IF; -- IF l_section_tbl.COUNT > 0 THEN
        Return l_section_title;
    END  get_section_title;

    -------------------------------------
    -- PROCEDURE get_qa_code_detail
    -------------------------------------
    /* API to get severity and qa name for any QA .Will be used to populate QA result table. */
    PROCEDURE get_qa_code_detail(
        p_qa_code            IN   VARCHAR2,
        x_perform_qa         OUT  NOCOPY VARCHAR2,
        x_qa_name            OUT  NOCOPY VARCHAR2,
        x_severity_flag      OUT  NOCOPY VARCHAR2,
        x_return_status      OUT  NOCOPY VARCHAR2)
    IS

        l_api_name               constant varchar2(30) := 'get_qa_code_detail';
        l_found                  boolean :=FALSE;

    BEGIN

        x_return_status := G_RET_STS_SUCCESS ;
        IF l_qa_detail_tbl.COUNT > 0 THEN
            FOR i IN l_qa_detail_tbl.FIRST..l_qa_detail_tbl.LAST LOOP
                IF l_qa_detail_tbl(i).qa_code = p_qa_code  THEN
                    x_perform_qa    := l_qa_detail_tbl(i).perform_qa;
                    x_severity_flag := l_qa_detail_tbl(i).severity_flag ;
                    x_qa_name       := l_qa_detail_tbl(i).qa_name ;
                    l_found := TRUE;
                    EXIT;
                END IF;
            END LOOP; -- FOR i IN l_qa_detail_tbl.FIRST..l_qa_detail_tbl.LAST LOOP
        END IF; -- IF l_qa_detail_tbl.COUNT > 0 THEN

        IF not l_found THEN
            FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
            FND_MESSAGE.set_token('ARG_NAME', 'p_qa_code');
            FND_MESSAGE.set_token('ARG_VALUE', p_qa_code);
            FND_MSG_PUB.add;
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving get_qa_code_detail : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving get_qa_code_detail :  FND_API.G_EXC_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving get_qa_code_detail:OTHERS Exception');
            END IF;

            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END get_qa_code_detail;

    -------------------------------------
    -- PROCEDURE log_qa_messages
    -------------------------------------
    PROCEDURE log_qa_messages (
        x_return_status    OUT NOCOPY VARCHAR2,
        p_qa_result_tbl    IN qa_result_tbl_type,
        x_sequence_id      OUT NOCOPY NUMBER)
    IS

        l_api_name         CONSTANT VARCHAR2(30) := 'log_qa_messages';
        i NUMBER ;

    BEGIN
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1000: Entered log_qa_messages');
        END IF;
        --  Initialize API return status to success
        x_return_status := G_RET_STS_SUCCESS;

        --- Setting item attributes
        -- Set primary key value
        x_return_status := get_seq_id(
            x_sequence_id => x_sequence_id
        );

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF p_qa_result_tbl.COUNT > 0 THEN
            FOR i IN p_qa_result_tbl.FIRST..p_qa_result_tbl.LAST LOOP
                --------------------------------------------
                -- Calling Simple API for Creating A Row
                --------------------------------------------
                x_return_status := insert_row(
                p_sequence_id        => x_sequence_id,
                p_document_type      => p_qa_result_tbl(i).document_type,
                p_document_id        => p_qa_result_tbl(i).document_id,
                p_error_record_type  => p_qa_result_tbl(i).error_record_type,
                p_title              => p_qa_result_tbl(i).title,
                p_error_severity     => p_qa_result_tbl(i).error_severity,
                p_qa_code            => p_qa_result_tbl(i).qa_code,
                p_message_name       => p_qa_result_tbl(i).message_name,
                p_problem_short_desc => p_qa_result_tbl(i).problem_short_desc,
                p_problem_details_short    => p_qa_result_tbl(i).problem_details_short,
                p_problem_details    => p_qa_result_tbl(i).problem_details,
                p_Sgestion           => p_qa_result_tbl(i).suggestion,
                p_article_id         => p_qa_result_tbl(i).article_id,
                p_deliverable_id     => p_qa_result_tbl(i).deliverable_id,
                p_section_name       => p_qa_result_tbl(i).section_name,
                p_reference_column1  => p_qa_result_tbl(i).reference_column1,
                p_reference_column2  => p_qa_result_tbl(i).reference_column2,
                p_reference_column3  => p_qa_result_tbl(i).reference_column3,
                p_reference_column4  => p_qa_result_tbl(i).reference_column4,
                p_reference_column5  => p_qa_result_tbl(i).reference_column5,
                p_creation_date      => p_qa_result_tbl(i).creation_date,
                p_error_record_type_name => p_qa_result_tbl(i).error_record_type_name,
                p_error_severity_name    => p_qa_result_tbl(i).error_severity_name);

                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

            END LOOP; -- FOR i IN p_qa_result_tbl.FIRST..p_qa_result_tbl.LAST LOOP
        END IF; -- If p_qa_result_tbl.COUNT > 0 THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1100: Leaving log_qa_messages');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1200: Leaving Log_QA_Messages : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1300: Leaving Log_QA_Messages : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1400: Leaving Log_QA_Messages because of EXCEPTION: '||sqlerrm);
            END IF;
            x_return_status := G_RET_STS_UNEXP_ERROR ;

            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
    END log_qa_messages;


--<<<<<<<<<<<<<<<<<< INTERNAL QA Check API PROCEDURES <<<<<<<<<<<<<<<<<<
    -------------------------------------------
    -- PROCEDURE check_incomp_and_alternate
    -------------------------------------------
    PROCEDURE check_incomp_and_alternate (
        p_qa_mode          IN  VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,

        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name            CONSTANT VARCHAR2(30) := 'Check_Incomp_and_alternate';
        l_indx                NUMBER;
        l_incom_severity      OKC_QA_ERRORS_T.Error_severity%TYPE;
        l_incom_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_alternate_severity  OKC_QA_ERRORS_T.Error_severity%TYPE;
        l_alternate_desc      OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_alternate_qa VARCHAR2(1);
        l_perform_incom_qa     VARCHAR2(1);

        l_current_org_id      VARCHAR2(100);

        CURSOR l_get_incomp_alter_csr(c_current_org_id IN NUMBER) IS
            SELECT kart1.id                       source_cat_id,
                rel.SOURCE_ARTICLE_ID          source_article_id,
                kart1.SCN_ID                   scn_id,
                kart1.label                    source_label,
                Kart2.ID                       target_cat_id,
                rel.TARGET_ARTICLE_ID          target_article_id,
                kart2.label                    target_label,
                kart1.AMENDMENT_OPERATION_CODE amendment_operation_code,
                rel.RELATIONSHIP_TYPE          relationship_type
            FROM    OKC_K_ARTICLES_B kart1,
                OKC_ARTICLE_RELATNS_ALL rel,
                OKC_K_ARTICLES_B kart2
            WHERE   kart1.document_type = p_doc_type
                AND     kart1.document_id=p_doc_id
                AND     kart1.sav_sae_id=rel.source_article_id
                AND     kart2.document_type = p_doc_type
                AND     kart2.document_id=p_doc_id
                AND     kart2.sav_sae_id=rel.target_article_id
                AND     rel.org_id = c_current_org_id
                AND     rel.relationship_type in (G_INCOMPATIBLE ,G_ALTERNATE)
                AND     nvl(kart2.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
                AND     nvl(kart2.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED
                AND     nvl(kart1.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
                AND     nvl(kart1.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED;

        /* expert commented out
        -- new cursor to check for xprt articles
        CURSOR l_get_incomp_alter_xprt_csr(c_current_org_id IN NUMBER) IS
            SELECT
                Rule.clause_id         source_article_id,
                Rule.rule_id        rule_id,
                Rule.rule_name        rule_name,
                Kart.sav_sae_id        target_article_id,
                Rel.relationship_type     relationship_type
            FROM    OKC_XPRT_CLAUSES_V rule,
                OKC_K_ARTICLES_B kart,
                OKC_ARTICLE_RELATNS_ALL rel
            WHERE rule.template_id = p_doc_id
                AND kart.document_type = p_doc_type
                AND kart.document_id = p_doc_id
                AND rule.rule_id =rel.source_article_id
                AND kart.sav_sae_id = rel.target_article_id
                AND rel.org_id = c_current_org_id
                AND rel.relationship_type in   (G_INCOMPATIBLE ,G_ALTERNATE) ;
        */

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_Incomp_and_alternate');
        END IF;

        -- current Org Id
        -- fnd_profile.get('ORG_ID',l_current_org_id);
        l_current_org_id := OKC_TERMS_UTIL_PVT.get_current_org_id(p_doc_type, p_doc_id);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_current_org_id : '||l_current_org_id);
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_INCOMPATIBILITY,
            x_perform_qa    => l_perform_incom_qa,
            x_qa_name       => l_incom_desc,
            x_severity_flag => l_incom_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ALTERNATE,
            x_perform_qa    => l_perform_alternate_qa,
            x_qa_name       => l_alternate_desc,
            x_severity_flag => l_alternate_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_incom_QA ='Y' OR l_perform_alternate_QA='Y' THEN

            IF (NOT do_validation(l_incom_severity, p_doc_type))  AND
                (NOT do_validation(l_alternate_severity, p_doc_type))  THEN
                -- validation is not required
                RETURN;
            END IF;

            FOR cr IN l_get_incomp_alter_csr(l_current_org_id)  LOOP
                IF (p_qa_mode =G_AMEND_QA and cr.amendment_operation_code IS NOT NULL)
                    OR p_qa_mode<>G_AMEND_QA THEN

                    IF cr.relationship_type=G_INCOMPATIBLE  AND  l_perform_incom_qa ='Y' THEN
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := cr.source_article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title               := get_article_title(cr.source_cat_id);
                        px_qa_result_tbl(l_indx).section_name        := get_section_title(cr.scn_id);

                        px_qa_result_tbl(l_indx).qa_code       := G_CHECK_INCOMPATIBILITY;
                        px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_INCOMPATIBILITY;
                        px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_INCOMPATIBILITY_S);

                        px_qa_result_tbl(l_indx).error_severity      := l_incom_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_incom_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INCOMPATIBILITY_SH, 'TARGET_ARTICLE', get_article_title(cr.target_cat_id));
                        px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INCOMPATIBILITY, 'SOURCE_ARTICLE', px_qa_result_tbl(l_indx).title, 'TARGET_ARTICLE', get_article_title(cr.target_cat_id));

                    ELSIF cr.relationship_type=G_ALTERNATE AND  l_perform_alternate_qa ='Y' THEN
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := cr.source_article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title               := get_article_title(cr.source_cat_id);
                        px_qa_result_tbl(l_indx).section_name        := get_section_title(cr.scn_id);

                        px_qa_result_tbl(l_indx).qa_code       := G_CHECK_ALTERNATE;
                        px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_ALTERNATE;
                        px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_ALTERNATE_S);
                        px_qa_result_tbl(l_indx).error_severity      := l_alternate_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_alternate_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ALTERNATE_SH, 'ALTERNATE_ARTICLE', get_article_title(cr.target_cat_id));
                        px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ALTERNATE, 'SOURCE_ARTICLE', px_qa_result_tbl(l_indx).title, 'TARGET_ARTICLE', get_article_title(cr.target_cat_id));

                    END IF; -- IF cr.relationship_type=G_INCOMPATIBLE  AND

                END IF; -- IF (p_qa_mode =G_AMEND_QA and cr.amendment_operation_c

            END LOOP; -- FOR cr IN l_get_incomp_alter_csr LOOP

            /* expert commented out
            -- validate expert clauses
            IF  (g_expert_enabled = 'Y') THEN
                FOR cr IN l_get_incomp_alter_xprt_csr(l_current_org_id) LOOP

                    IF ( (cr.relationship_type = G_INCOMPATIBLE)  AND  (l_perform_incom_qa = 'Y')
                    AND do_validation(l_incom_severity, p_doc_type) )THEN
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_EXP_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := cr.source_article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title  :=
                            get_xprt_article_title(cr.source_article_id);
                        px_qa_result_tbl(l_indx).section_name        := Null;
                        px_qa_result_tbl(l_indx).qa_code       := G_CHECK_RUL_INC;
                        px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_RUL_INC;
                        px_qa_result_tbl(l_indx).suggestion    :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_INC_S);
                        px_qa_result_tbl(l_indx).error_severity      := l_incom_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_incom_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_INC_SH);
                        px_qa_result_tbl(l_indx).problem_details   :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_INC,
                                'RULE', cr.rule_name,
                                'SOURCE_ARTICLE', get_xprt_article_title(cr.source_article_id),
                                'TARGET_ARTICLE', get_xprt_article_title(cr.target_article_id));

                    ELSIF ( (cr.relationship_type = G_ALTERNATE)  AND  (l_perform_alternate_qa = 'Y')
                    AND do_validation(l_alternate_severity, p_doc_type) )THEN
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_EXP_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := cr.source_article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title  :=
                            get_xprt_article_title(cr.source_article_id);
                        px_qa_result_tbl(l_indx).section_name        := Null;
                        px_qa_result_tbl(l_indx).qa_code       := G_CHECK_RUL_ALT;
                        px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_RUL_ALT;
                        px_qa_result_tbl(l_indx).suggestion    :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_ALT_S);
                        px_qa_result_tbl(l_indx).error_severity      := l_alternate_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_alternate_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_ALT_SH);
                        px_qa_result_tbl(l_indx).problem_details   :=
                            OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_ALT,
                                'RULE', cr.rule_name,
                                'SOURCE_ARTICLE', get_xprt_article_title(cr.source_article_id),
                                'TARGET_ARTICLE', get_xprt_article_title(cr.target_article_id));
                        NULL;
                    END IF;

                END LOOP;
            END IF; -- of IF  (g_expert_enabled = 'Y') THEN
            */

        END IF;-- IF l_perform_incom_QA ='Y' OR l_perform_alternate_QA='Y'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_Incomp_and_alternate');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_incomp_alter_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_csr;
            END IF;
            /* expert commented out
            IF l_get_incomp_alter_xprt_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_xprt_csr;
            END IF;
            */

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_incomp_alter_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_csr;
            END IF;
            /* expert commented out
            IF l_get_incomp_alter_xprt_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_xprt_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_Incomp_and_alternate because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_incomp_alter_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_csr;
            END IF;
            /* expert commented out
            IF l_get_incomp_alter_xprt_csr%ISOPEN THEN
                CLOSE l_get_incomp_alter_xprt_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_incomp_and_alternate;


    -------------------------------------------
    -- PROCEDURE check_lock_contract
    -------------------------------------------
    PROCEDURE check_lock_contract (
        p_qa_mode          IN  VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,

        x_qa_result_tbl    IN OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status IN OUT NOCOPY VARCHAR2,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name            CONSTANT VARCHAR2(30) := 'check_lock_contract';
        l_indx                NUMBER;
        l_lock_severity      OKC_QA_ERRORS_T.Error_severity%TYPE;
        l_lock_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_lock_severity_flag OKC_QA_ERRORS_T.Error_severity%TYPE;

        l_perform_lock_qa     VARCHAR2(1);
        l_lock_contract       VARCHAR2(1);

        CURSOR l_get_qa_detail_csr(p_qa_code VARCHAR2) IS
        SELECT
             decode(fnd.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa,
             fnd.meaning qa_name,
             nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag
		   FROM FND_LOOKUPS FND, OKC_DOC_QA_LISTS QA
		   WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
		   AND   QA.QA_CODE(+) = FND.LOOKUP_CODE
		   AND   Fnd.LOOKUP_TYPE=G_QA_LOOKUP
		   AND   fnd.lookup_code = p_qa_code;


        CURSOR l_get_lock_error_warn_csr IS
            SELECT nvl(qa.severity_flag,G_QA_STS_ERROR) severity_flag
            FROM OKC_DOC_QA_LISTS QA
            WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
                AND   QA.QA_CODE(+) = G_OKC_CHECK_LOCK_CONTRACT;




    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_lock_contract');
        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_lock_contract : '||l_lock_contract);
        END IF;

        -- Initialize API return status to success
	   x_return_status := G_RET_STS_SUCCESS;

        OPEN l_get_qa_detail_csr(G_OKC_CHECK_LOCK_CONTRACT);
           FETCH l_get_qa_detail_csr into l_perform_lock_qa,l_lock_desc,l_lock_severity;
        CLOSE l_get_qa_detail_csr;


        IF l_perform_lock_qa ='Y' THEN

            IF (NOT do_validation(l_lock_severity, p_doc_type))  THEN
                -- validation is not required
                RETURN;
            END IF;

            l_lock_contract := OKC_TERMS_UTIL_PVT.is_terms_locked(p_doc_type,p_doc_id);
            if(l_lock_contract = 'Y') THEN

                        l_indx := x_qa_result_tbl.COUNT + 1;

                        x_qa_result_tbl(l_indx).error_record_type   := G_CONTRACT;
                        x_qa_result_tbl(l_indx).article_id          := null;
                        x_qa_result_tbl(l_indx).deliverable_id      := Null;
                        x_qa_result_tbl(l_indx).title               := null;
                        x_qa_result_tbl(l_indx).section_name        := null;

                        x_qa_result_tbl(l_indx).qa_code       := G_OKC_CHECK_LOCK_CONTRACT  ;
                        x_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_LOCK_CONTRACT ;
                        x_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_LOCK_CONTRACT_S);
                        OPEN l_get_lock_error_warn_csr;
                        FETCH l_get_lock_error_warn_csr into l_lock_severity_flag;
                        IF (l_get_lock_error_warn_csr%NOTFOUND) THEN
                            x_qa_result_tbl(l_indx).error_severity      := 'E';
					   x_qa_return_status := 'E';
                        ELSE
                            x_qa_result_tbl(l_indx).error_severity :=  l_lock_severity_flag;
					   x_qa_return_status := l_lock_severity_flag;
                        END IF;
                        x_qa_result_tbl(l_indx).problem_short_desc  := l_lock_desc;
                        x_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LOCK_CONTRACT_SH);
                        x_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LOCK_CONTRACT_SH);
                        x_qa_result_tbl(l_indx).document_type       := p_doc_type;
				    x_qa_result_tbl(l_indx).document_id         := p_doc_id;
				    x_qa_result_tbl(l_indx).creation_date       := sysdate;


                END IF; -- IF (l_lock_contract = 'Y')

        END IF;-- IF l_perform_lock_QA ='Y'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_Incomp_and_alternate');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_Incomp_and_alternate because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_lock_contract;



    -------------------------------------------
    -- PROCEDURE check_contract_admin
    -------------------------------------------
    PROCEDURE check_contract_admin (
        p_qa_mode          IN  VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,

        x_qa_result_tbl    IN OUT NOCOPY qa_result_tbl_type,
	   x_qa_return_status IN OUT NOCOPY VARCHAR2,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name            CONSTANT VARCHAR2(30) := 'check_contract_admin';
        l_indx                NUMBER;
        l_ctrt_admin_severity      OKC_QA_ERRORS_T.Error_severity%TYPE;
        l_ctrt_admin_desc          OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_ctrt_admin_severity_flag OKC_QA_ERRORS_T.Error_severity%TYPE;

        l_perform_ctrt_admin_qa     VARCHAR2(1);
        l_ctrt_admin                VARCHAR2(1);
	   l_ctrt_admin_emp            VARCHAR2(1);
	   l_ctrt_admin_valid_emp      VARCHAR2(1);


        CURSOR l_get_qa_detail_csr(p_qa_code VARCHAR2) IS
	        SELECT
	        decode(fnd.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa,
	        fnd.meaning qa_name,
		   nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag
	        FROM FND_LOOKUPS FND, OKC_DOC_QA_LISTS QA
	        WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
	        AND   QA.QA_CODE(+) = FND.LOOKUP_CODE
	        AND   Fnd.LOOKUP_TYPE=G_QA_LOOKUP
	        AND   fnd.lookup_code = p_qa_code;



        CURSOR l_get_ctrt_admin_err_wrn_csr IS
            SELECT nvl(qa.severity_flag,G_QA_STS_ERROR) severity_flag
            FROM OKC_DOC_QA_LISTS QA
            WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
                AND   QA.QA_CODE(+) = G_OKC_CHECK_CONTRACT_ADMIN;

        CURSOR contract_admin_exists is
            SELECT 'Y' FROM OKC_TEMPLATE_USAGES
            	WHERE DOCUMENT_TYPE = P_DOC_TYPE
            	AND   DOCUMENT_ID = P_DOC_ID
				AND   CONTRACT_ADMIN_ID IS NOT NULL;

        -- Fix for 13435490 start
         CURSOR rep_contract_admin_exists is
            SELECT 'Y' FROM okc_rep_contracts_all
            	WHERE CONTRACT_TYPE = P_DOC_TYPE
            	AND   CONTRACT_ID = P_DOC_ID
				AND   OWNER_ID IS NOT NULL;

        -- Fix for 13435490 end


	   CURSOR contract_admin_emp is
	       SELECT 'Y' FROM OKC_TEMPLATE_USAGES USG, fnd_user ctrtadm, PER_ALL_PEOPLE_F adminppl
		     WHERE USG.DOCUMENT_TYPE = P_DOC_TYPE
			AND   USG.DOCUMENT_ID = P_DOC_ID
			AND   USG.CONTRACT_ADMIN_ID IS NOT NULL
			AND   USG.contract_admin_id = ctrtadm.user_id
	          AND   ctrtadm.employee_id = adminppl.person_id
			and   rownum < 2;

	   CURSOR contract_admin_valid_emp is
	       SELECT 'Y' FROM OKC_TEMPLATE_USAGES USG, fnd_user ctrtadm, PER_ALL_PEOPLE_F adminppl
		     WHERE USG.DOCUMENT_TYPE = P_DOC_TYPE
			AND   USG.DOCUMENT_ID = P_DOC_ID
			AND   USG.CONTRACT_ADMIN_ID IS NOT NULL
			AND   USG.contract_admin_id = ctrtadm.user_id
	          AND   ctrtadm.employee_id = adminppl.person_id
			and adminppl.effective_start_date = adminppl.start_date;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_contract_admin');
        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: l_ctrt_admin : '||l_ctrt_admin);

	   END IF;

        -- Initialize API return status to success
	   x_return_status := G_RET_STS_SUCCESS;

        OPEN l_get_qa_detail_csr(G_OKC_CHECK_CONTRACT_ADMIN);
           FETCH l_get_qa_detail_csr into l_perform_ctrt_admin_qa,l_ctrt_admin_desc,l_ctrt_admin_severity_flag;
        CLOSE l_get_qa_detail_csr;



        IF l_perform_ctrt_admin_qa ='Y' THEN

            IF (NOT do_validation(l_ctrt_admin_severity, p_doc_type))  THEN
                -- validation is not required
                RETURN;
            END IF;
            l_ctrt_admin := 'N';
             -- Fix for 13435490 start
            IF(p_doc_type LIKE 'REP%') THEN
              OPEN rep_contract_admin_exists;
              fetch rep_contract_admin_exists into l_ctrt_admin;
              close rep_contract_admin_exists;
            ELSE    -- Fix for 13435490 end
              OPEN contract_admin_exists;
              fetch contract_admin_exists into l_ctrt_admin;
              close contract_admin_exists;
            END IF;

            if(l_ctrt_admin <> 'Y') THEN

                        l_indx := x_qa_result_tbl.COUNT + 1;

                        x_qa_result_tbl(l_indx).error_record_type   := G_CONTRACT;
                        x_qa_result_tbl(l_indx).article_id          := null;
                        x_qa_result_tbl(l_indx).deliverable_id      := Null;
                        x_qa_result_tbl(l_indx).title               := null;
                        x_qa_result_tbl(l_indx).section_name        := null;

                        x_qa_result_tbl(l_indx).qa_code       := G_OKC_CHECK_CONTRACT_ADMIN  ;
                        x_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_CTRT_ADMIN_S ;
                        x_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_CTRT_ADMIN_S);
                        OPEN l_get_ctrt_admin_err_wrn_csr;
                        FETCH l_get_ctrt_admin_err_wrn_csr into l_ctrt_admin_severity_flag;
                        IF (l_get_ctrt_admin_err_wrn_csr%NOTFOUND) THEN
                            x_qa_result_tbl(l_indx).error_severity      := 'W';
					   x_qa_return_status := 'W';
                        ELSE
                            x_qa_result_tbl(l_indx).error_severity :=  l_ctrt_admin_severity_flag;
					   x_qa_return_status := l_ctrt_admin_severity_flag;
                        END IF;
                        x_qa_result_tbl(l_indx).problem_short_desc  := l_ctrt_admin_desc;
                        x_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_CTRT_ADMIN_SH);
                        x_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_CTRT_ADMIN_SH);
                        x_qa_result_tbl(l_indx).document_type       := p_doc_type;
				    x_qa_result_tbl(l_indx).document_id         := p_doc_id;
				    x_qa_result_tbl(l_indx).creation_date       := sysdate;


              ELSE
		              l_ctrt_admin_emp := 'N';
		              OPEN contract_admin_emp;
				    fetch contract_admin_emp into l_ctrt_admin_emp;
				    close contract_admin_emp;
				    if(l_ctrt_admin_emp <> 'Y') THEN
                           x_qa_result_tbl(l_indx).error_record_type   := G_CONTRACT;
                           x_qa_result_tbl(l_indx).article_id          := null;
                           x_qa_result_tbl(l_indx).deliverable_id      := Null;
                           x_qa_result_tbl(l_indx).title               := null;
                           x_qa_result_tbl(l_indx).section_name        := null;

                           x_qa_result_tbl(l_indx).qa_code       := G_OKC_CHECK_CONTRACT_ADMIN  ;
                           x_qa_result_tbl(l_indx).message_name  := G_OKC_CTRT_ADMIN_EMP_S ;
                           x_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_ADMIN_EMP_SUGG);
                           OPEN l_get_ctrt_admin_err_wrn_csr;
                           FETCH l_get_ctrt_admin_err_wrn_csr into l_ctrt_admin_severity_flag;
                           IF (l_get_ctrt_admin_err_wrn_csr%NOTFOUND) THEN
                             x_qa_result_tbl(l_indx).error_severity      := 'W';
					    x_qa_return_status := 'W';
                           ELSE
                              x_qa_result_tbl(l_indx).error_severity :=  l_ctrt_admin_severity_flag;
					     x_qa_return_status := l_ctrt_admin_severity_flag;
                          END IF;
                          x_qa_result_tbl(l_indx).problem_short_desc  := l_ctrt_admin_desc;
                          x_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CTRT_ADMIN_EMP_SH);
                          x_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CTRT_ADMIN_EMP_DT);
					 x_qa_result_tbl(l_indx).document_type       := p_doc_type;
					 x_qa_result_tbl(l_indx).document_id         := p_doc_id;
					 x_qa_result_tbl(l_indx).creation_date       := sysdate;

				    ELSE
		                 l_ctrt_admin_valid_emp := 'N';
		                 OPEN contract_admin_valid_emp;
				       fetch contract_admin_valid_emp into l_ctrt_admin_valid_emp;
				       close contract_admin_valid_emp;
					  if(l_ctrt_admin_valid_emp <> 'Y') THEN
                             x_qa_result_tbl(l_indx).error_record_type   := G_CONTRACT;
                             x_qa_result_tbl(l_indx).article_id          := null;
                             x_qa_result_tbl(l_indx).deliverable_id      := Null;
                             x_qa_result_tbl(l_indx).title               := null;
                             x_qa_result_tbl(l_indx).section_name        := null;

                             x_qa_result_tbl(l_indx).qa_code       := G_OKC_CHECK_CONTRACT_ADMIN  ;
                             x_qa_result_tbl(l_indx).message_name  := G_OKC_ADMIN_VALID_EMP_S ;
                             x_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_ADMIN_VALID_EMP_SUGG);
                             OPEN l_get_ctrt_admin_err_wrn_csr;
                             FETCH l_get_ctrt_admin_err_wrn_csr into l_ctrt_admin_severity_flag;
                             IF (l_get_ctrt_admin_err_wrn_csr%NOTFOUND) THEN
                               x_qa_result_tbl(l_indx).error_severity      := 'W';
					      x_qa_return_status := 'W';
                             ELSE
                               x_qa_result_tbl(l_indx).error_severity :=  l_ctrt_admin_severity_flag;
					      x_qa_return_status := l_ctrt_admin_severity_flag;
                             END IF;
                             x_qa_result_tbl(l_indx).problem_short_desc  := l_ctrt_admin_desc;
                             x_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_ADMIN_VALID_EMP_SH);
                             x_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_ADMIN_VALID_EMP_DT);
				         x_qa_result_tbl(l_indx).document_type       := p_doc_type;
				         x_qa_result_tbl(l_indx).document_id         := p_doc_id;
				         x_qa_result_tbl(l_indx).creation_date       := sysdate;

					  END IF; -- if(l_ctrt_admin_valid_emp <> 'Y')

				    END IF; --  if(l_ctrt_admin_emp <> 'Y')



              END IF; -- IF (l_ctrt_admin = 'Y')

        END IF;-- IF l_perform_ctrt_admin_qa ='Y'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_Incomp_and_alternate');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_Incomp_and_alternate : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_Incomp_and_alternate because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_contract_admin;




    -------------------------------------------
    -- PROCEDURE check_duplicate_articles
    -------------------------------------------
    /*  API to do QA Check for duplicate article */

    PROCEDURE check_duplicate_articles (
        p_qa_mode          IN  VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,

        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name                CONSTANT VARCHAR2(30) := 'check_duplicate_articles';
        l_indx                    NUMBER;
        l_error_count            NUMBER := 0;
        l_severity                OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc                    OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_duplicate_qa    Varchar2(1);

        /* expert commented out
        -- new cursor to check for xprt articles
        CURSOR l_get_dup_xprt_csr IS
            SELECT
                Rule.clause_id         xprt_article_id,
                Rule.rule_id        rule_id,
                Rule.rule_name        rule_name
            FROM    OKC_XPRT_CLAUSES_V rule,
                OKC_K_ARTICLES_B kart
            WHERE rule.template_id = p_doc_id
                AND kart.document_type = p_doc_type
                AND kart.document_id = p_doc_id
                AND rule.clause_id =kart.sav_sae_id;
        */

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_duplicate_articles');
        END IF;

        get_qa_code_detail(p_qa_code       => 'CHECK_DUPLICATE',
            x_perform_qa    => l_perform_duplicate_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_duplicate_qa ='Y' THEN

            IF (NOT do_validation(l_severity, p_doc_type))  THEN
                -- validation is not required
                RETURN;
            END IF;

            IF l_article_tbl.COUNT > 0 THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: totally:'||l_article_tbl.COUNT||' articles to check');
                END IF;

                FOR i IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP

                  --Bug 4128923
                    l_error_count := 0;
                    IF( p_qa_mode=G_AMEND_QA and l_article_tbl(i).amendment_operation_code IS NOT NULL
                        OR p_qa_mode<>G_AMEND_QA )
                        and nvl(l_article_tbl(i).amendment_operation_code,'?')<>G_AMEND_CODE_DELETED THEN

                        --Bug 4128923      l_error_count := 0;

                        FOR k IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP
                            --IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              --  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: i:'||i||', k:'||k);
                            --END IF;

                            IF nvl(l_article_tbl(k).amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
                                AND Nvl(l_article_tbl(k).std_art_id,l_article_tbl(k).article_id)
                                =Nvl(l_article_tbl(i).std_art_id,l_article_tbl(i).article_id) THEN

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Dupicate found - i:'||i||', k:'||k);
                                END IF;
                                l_error_count := l_error_count + 1;
                            END IF;
                        END LOOP; -- FOR k IN l_article_tbl1.FIRST..l_article_tbl1.LAST LOOP
                    END IF; -- IF ( (      p_qa_mode =G_AMEND_QA

                    IF l_error_count > 1 THEN
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := l_article_tbl(i).article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title               := get_article_title(l_article_tbl(i).id);
                        px_qa_result_tbl(l_indx).section_name        := get_section_title(l_article_tbl(i).scn_id);
                        px_qa_result_tbl(l_indx).qa_code       := G_CHECK_DUPLICATE;
                        px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_DUPLICATE;
                        px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_DUPLICATE_S);

                        px_qa_result_tbl(l_indx).error_severity      := l_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_DUPLICATE_SH, 'NUMBER',l_error_count);
                        px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_DUPLICATE, 'ARTICLE', px_qa_result_tbl(l_indx).title, 'NUMBER',l_error_count);
                    END IF; -- IF l_error_count > 1 THEN

                    /* expert commented out
                    IF  ((g_expert_enabled = 'Y') and (p_doc_type = 'TEMPLATE')) THEN

                        FOR cr IN l_get_dup_xprt_csr LOOP
                            l_indx := px_qa_result_tbl.COUNT + 1;

                            px_qa_result_tbl(l_indx).error_record_type   := G_EXP_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id          := cr.xprt_article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;
                            px_qa_result_tbl(l_indx).title   :=
                                get_xprt_article_title(cr.xprt_article_id);
                            px_qa_result_tbl(l_indx).section_name        := Null;
                            px_qa_result_tbl(l_indx).qa_code       := G_CHECK_RUL_DUP;
                            px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_RUL_DUP;
                            px_qa_result_tbl(l_indx).suggestion    :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_DUP_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_severity;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                            px_qa_result_tbl(l_indx).problem_details_short     :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_DUP_SH);
                            px_qa_result_tbl(l_indx).problem_details   :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_DUP,
                                    'RULE', cr.rule_name,
                                    'XPRT_ARTICLE', get_xprt_article_title(cr.xprt_article_id));
                        END LOOP;

                    END IF; -- of IF  ((g_expert_enabled = 'Y') and (p_doc_type = 'TEMPLATE')) THEN
                    */

                END LOOP; -- FOR i IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP

            END IF; -- IF l_article_tbl.COUNT > 0 THEN

        END IF; -- IF l_perform_duplicate_qa ='Y' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_duplicate_articles');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_duplicate_articles : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            /* expert commented out
            IF l_get_dup_xprt_csr%ISOPEN THEN
                CLOSE l_get_dup_xprt_csr;
            END IF;
            */

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_duplicate_articles : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            /* expert commented out
            IF l_get_dup_xprt_csr%ISOPEN THEN
                CLOSE l_get_dup_xprt_csr;
            END IF;
            */
            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_duplicate_articles because of EXCEPTION: '||sqlerrm);
            END IF;

            /* expert commented out
            IF l_get_dup_xprt_csr%ISOPEN THEN
                CLOSE l_get_dup_xprt_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_duplicate_articles;

    -------------------------------------------
    -- PROCEDURE check_var_doc_type_usage
    -------------------------------------------
    /*  API to do QA Check variable Doc type usage */

    PROCEDURE check_var_doc_type_usage (
        p_qa_mode          IN VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name            CONSTANT VARCHAR2(30) := 'G_Check_var_doc_type_usage';
        l_indx                NUMBER;
        l_severity            OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc                OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_var_usg_qa  VARCHAR2(1);

        /* 11.5.10+ modified cursor - see below
        CURSOR l_check_usage_csr IS
            SELECT kart.id         id,
                kart.sav_sae_id article_id,
                kart.article_version_id article_version_id,
                kart.amendment_operation_code amendment_operation_code,
                kart.scn_id scn_id,
                var.variable_code variable_code,
                busvar.variable_name variable_name,
                busdoc.name         doc_type
            FROM   okc_k_articles_b kart,
                okc_k_art_variables var,
                okc_bus_variables_vl busvar,
                okc_bus_doc_types_v busdoc
        WHERE  kart.document_type=p_doc_type
            and    kart.document_id=p_doc_id
            and    var.cat_id=kart.id
            and    var.variable_type IN ('S','D')
            and    var.variable_code=busvar.variable_code
            and    busdoc.document_type = kart.document_type
            and    not exists (SELECT 'x' from  OKC_VARIABLE_DOC_TYPES vo
                WHERE var.variable_code=vo.variable_code
                    and   doc_type=p_doc_type)
            and    p_doc_type<>G_TMPL_DOC_TYPE
            and    nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
            and    nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED
        UNION ALL
        SELECT kart.id  id,
            kart.sav_sae_id article_id,
            vers.article_version_id article_version_id,
            kart.amendment_operation_code amendment_operation_code,
            kart.scn_id scn_id,
            var.variable_code variable_code,
            busvar.variable_name variable_name,
            busdoc.name  doc_type
        FROM   okc_k_articles_b kart,
            okc_article_versions vers,
            okc_allowed_tmpl_usages allwd ,
            okc_article_variables var,
            okc_bus_variables_vl busvar ,
            okc_bus_doc_types_v busdoc
        WHERE  kart.document_type=G_TMPL_DOC_TYPE
            and    kart.document_id=p_doc_id
            and    allwd.template_id=kart.document_id
            and    kart.sav_sae_id=vers.article_id
            and    vers.article_status='APPROVED'
            AND    vers.start_date = (SELECT max(start_date)
                FROM OKC_ARTICLE_VERSIONS
                WHERE  article_id= kart.sav_sae_id
                AND article_status='APPROVED')
            and    vers.article_version_id=var.article_version_id
            and    busvar.variable_code=var.variable_code
            and    busvar.variable_type IN ('S','D')
            and    busdoc.document_type = allwd.document_type
            and    not exists (SELECT 'x' FROM OKC_VARIABLE_DOC_TYPES vo
                WHERE var.variable_code=vo.variable_code
                and   doc_type=allwd.document_type)
            and    p_doc_type=G_TMPL_DOC_TYPE
            and    nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
            and    nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED;
        */

        /* 11.5.10+ modified cursor definition
        1. no change for non TEMPLATE doc types
        2. for TEMPLATE doc types, get selected draft versions also
        */
	--Repository Enhancement 12.1 (For Validate Action)
	  p_rep_doc_type                      varchar2(30);
	  l_intent                   okc_bus_doc_types_b.intent%type;
	-- Repository Enhancement 12.1 Ends (For Validate Action)

        CURSOR l_check_usage_csr IS
            -- no change for non TEMPLATE document types
            SELECT kart.id         id,
                kart.sav_sae_id article_id,
                kart.article_version_id article_version_id,
                kart.amendment_operation_code amendment_operation_code,
                kart.scn_id scn_id,
                var.variable_code variable_code,
                busvar.variable_name variable_name,
                busdoc.name         doc_type
            FROM   okc_k_articles_b kart,
                okc_k_art_variables var,
                okc_bus_variables_vl busvar,
                okc_bus_doc_types_v busdoc
        WHERE  kart.document_type=p_doc_type
            and    kart.document_id=p_doc_id
            and    var.cat_id=kart.id
            and    var.variable_type IN ('S','D')
            and    var.variable_code=busvar.variable_code
      --Repository Enhancement 12.1 (For Validate Action)
        and    busdoc.document_type = kart.document_type
        --    and    busdoc.document_type = p_rep_doc_type
            and    not exists (SELECT 'x' from  OKC_VARIABLE_DOC_TYPES vo
                WHERE var.variable_code=vo.variable_code
      --Repository Enhancement 12.1 (For Validate Action)
      --           and   doc_type=p_doc_type)
                   and   doc_type= p_rep_doc_type)
            and    p_doc_type<>G_TMPL_DOC_TYPE
            and    nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
            and    nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED
        UNION ALL
        -- change to get draft/rejected clause versions also
        SELECT kart.id  id,
            kart.sav_sae_id article_id,
            vers.article_version_id article_version_id,
            kart.amendment_operation_code amendment_operation_code,
            kart.scn_id scn_id,
            var.variable_code variable_code,
            busvar.variable_name variable_name,
            busdoc.name  doc_type
        FROM   okc_k_articles_b kart,
            okc_article_versions vers,
            okc_allowed_tmpl_usages allwd ,
            okc_article_variables var,
            okc_bus_variables_vl busvar ,
            okc_bus_doc_types_v busdoc
        WHERE  kart.document_type=G_TMPL_DOC_TYPE
            and    kart.document_id=p_doc_id
            and    allwd.template_id=kart.document_id
            and    kart.sav_sae_id=vers.article_id
            -- new logic for determining clause version
            and vers.article_version_id = OKC_TERMS_UTIL_PVT.get_latest_tmpl_art_version_id(
                kart.sav_sae_id,
                g_start_date,
                g_end_date,
                g_status_code,
                p_doc_type,
                p_doc_id)
            /* existing logic of determining clause version
            and    vers.article_status='APPROVED'
            AND    vers.start_date = (select max(start_date)
            FROM OKC_ARTICLE_VERSIONS
            WHERE  article_id= kart.sav_sae_id
            AND article_status='APPROVED')
            */
            and    vers.article_version_id=var.article_version_id
            and    busvar.variable_code=var.variable_code
            and    busvar.variable_type IN ('S','D')
            and    busdoc.document_type = allwd.document_type
            and    not exists ((SELECT 'x' FROM OKC_VARIABLE_DOC_TYPES vo
                WHERE var.variable_code=vo.variable_code
                and   doc_type=allwd.document_type)
		UNION ALL
		(SELECT 'x' FROM OKC_VARIABLE_DOC_TYPES vo
                WHERE var.variable_code=vo.variable_code
                and   doc_type like '%REPOSITORY%'))
            and    p_doc_type=G_TMPL_DOC_TYPE
            and    nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
            and    nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED;

	-- Repository Enhancement 12.1 (For Validate Action)
		CURSOR l_get_intent is
		SELECT intent
		FROM okc_bus_doc_types_b
		WHERE document_type = p_doc_type;
	-- Repository Enhancement 12.1 Ends (For Validate Action)


        /* expert commented out
        CURSOR l_xprt_check_usage_csr IS
            SELECT
                Rule.clause_id         xprt_article_id,
                Rule.rule_id        rule_id,
                Rule.rule_name        rule_name,
                var.variable_code     variable_code,
                busvar.variable_name     variable_name,
                busdoc.name          doc_type
            FROM    okc_xprt_clauses_v rule,
                okc_allowed_tmpl_usages allwd ,
                okc_article_versions vers,
                okc_article_variables var,
                okc_bus_variables_vl busvar ,
                okc_bus_doc_types_v busdoc
            WHERE rule.template_id = p_doc_id
                and    allwd.template_id=p_doc_id
                and    vers.article_id = rule.clause_id
                and    vers.article_version_id =
                    OKC_TERMS_UTIL_PVT.get_latest_tmpl_art_version_id(
                    rule.clause_id,
                    g_start_date,
                    g_end_date,
                    g_status_code,
                    p_doc_type,
                    p_doc_id)
                and    var.article_version_id = vers.article_version_id
                and    busvar.variable_code = var.variable_code
                and    busvar.variable_type IN ('S','D')
                and    busdoc.document_type = allwd.document_type
                and    not exists (select 'x' from OKC_VARIABLE_DOC_TYPES vo
                    where vo.variable_code=var.variable_code
                    and   vo.doc_type=allwd.document_type) ;
        */

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_var_doc_type_usage');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_VAR_USAGE,
            x_perform_qa    => l_perform_var_usg_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_var_usg_qa ='Y' THEN

            IF (NOT do_validation(l_severity, p_doc_type))  THEN
                -- validation is not required
                RETURN;
            END IF;

	-- Repository Enhancement 12.1 (For Validate Action)
          OPEN  l_get_intent;
          FETCH l_get_intent into l_intent;
          CLOSE l_get_intent;
           IF SubStr(p_doc_type,1,3) = 'REP'  and l_intent = 'S' THEN
           p_rep_doc_type:='OKC_REPOSITORY_SELL';
           ELSIF SubStr(p_doc_type,1,3) = 'REP'  and l_intent = 'B' THEN
           p_rep_doc_type:='OKC_REPOSITORY_BUY';
           ELSE
           p_rep_doc_type:=p_doc_type;
           END IF;
	-- Repository Enhancement 12.1 Ends(For Validate Action)

            FOR cr IN l_check_usage_csr LOOP

                IF ( (      p_qa_mode =G_AMEND_QA
                    and cr.amendment_operation_code IS NOT NULL
                    )
                    OR p_qa_mode<>G_AMEND_QA) THEN

                    l_indx := px_qa_result_tbl.COUNT + 1;

                    px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id       := cr.article_id;
                    px_qa_result_tbl(l_indx).deliverable_id   := Null;
                    px_qa_result_tbl(l_indx).title            := get_article_title(cr.id);
                    px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);
                    px_qa_result_tbl(l_indx).qa_code       := G_CHECK_VAR_USAGE;
                    px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_VAR_USAGE;
                    px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_VAR_USAGE_S);

                    px_qa_result_tbl(l_indx).error_severity      := l_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_VAR_USAGE_SH, 'VARIABLE',cr.variable_name,'DOCUMENT_TYPE',cr.doc_type);
                    px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_VAR_USAGE, 'VARIABLE', cr.variable_name, 'DOCUMENT_TYPE',cr.doc_type);
                END IF; -- IF ( (      p_qa_mode =G_AMEND_QA

            END LOOP; -- FOR cr IN l_check_usage_csr LOOP

            /* expert commented out
            IF  ((g_expert_enabled = 'Y') AND (p_doc_type = 'TEMPLATE')) THEN
                FOR cr IN l_xprt_check_usage_csr LOOP
                    l_indx := px_qa_result_tbl.COUNT + 1;

                    px_qa_result_tbl(l_indx).error_record_type   := G_EXP_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id          := cr.xprt_article_id;
                    px_qa_result_tbl(l_indx).deliverable_id   := Null;
                    px_qa_result_tbl(l_indx).title           :=
                        get_xprt_article_title(cr.xprt_article_id);
                    px_qa_result_tbl(l_indx).section_name        := Null;

                    px_qa_result_tbl(l_indx).qa_code       := G_CHECK_RUL_VAR_DOC;
                    px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_RUL_VAR_DOC;
                    px_qa_result_tbl(l_indx).suggestion    :=
                        OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_VAR_DOC_S);
                    px_qa_result_tbl(l_indx).error_severity      := l_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     :=
                        OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_VAR_DOC_SH);
                    px_qa_result_tbl(l_indx).problem_details   :=
                        OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_VAR_DOC,
                            'RULE', cr.rule_name,
                            'XPRT_ARTICLE', get_xprt_article_title(cr.xprt_article_id),
                            'DOCUMENT_TYPE', cr.doc_type);
                END LOOP;
            END IF; -- of IF  ((g_expert_enabled = 'Y') AND (p_doc_type = 'TEMPLATE'))
            */

        END IF; -- IF l_perform_var_usg_qa ='Y' THEN


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_var_doc_type_usage');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_var_doc_type_usage : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_check_usage_csr%ISOPEN THEN
                CLOSE l_check_usage_csr ;
            END IF;

            /* expert commented out
            IF l_xprt_check_usage_csr%ISOPEN THEN
                CLOSE l_xprt_check_usage_csr ;
            END IF;
            */

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_var_doc_type_usage : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_check_usage_csr%ISOPEN THEN
                CLOSE l_check_usage_csr ;
            END IF;

            /* expert commented out
            IF l_xprt_check_usage_csr%ISOPEN THEN
                CLOSE l_xprt_check_usage_csr ;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_var_doc_type_usage because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_check_usage_csr%ISOPEN THEN
                CLOSE l_check_usage_csr ;
            END IF;

            /* expert commented out
            IF l_xprt_check_usage_csr%ISOPEN THEN
                CLOSE l_xprt_check_usage_csr ;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_var_doc_type_usage;

-------------------------------------------
-- PROCEDURE check_user_vars_with_procs
-------------------------------------------

PROCEDURE check_user_vars_with_procs (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
IS

    l_api_name            CONSTANT VARCHAR2(30) := 'check_user_vars_with_procs';
    l_indx                NUMBER;
    l_int_severity        OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
    l_int_desc            OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
    l_perform_int_qa      VARCHAR2(1);

    l_variable_value      VARCHAR2(2500) := NULL;
    l_previous_var_code	  okc_bus_variables_b.variable_code%TYPE := '-99';
    l_return_status       VARCHAR2(10);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2500);


CURSOR csr_get_udv_with_procs IS
SELECT VB.variable_code,
       KA.id,
       KA.sav_sae_id article_id,
       KA.scn_id,
       VT.variable_name
FROM okc_k_articles_b KA,
     okc_k_art_variables KV,
     okc_bus_variables_b VB,
     okc_bus_variables_tl VT
WHERE VB.variable_code = KV.variable_code
AND KA.id = KV.cat_id
AND VB.variable_code = VT.variable_code
AND VB.variable_source = 'P'
AND KA.document_type = p_doc_type
AND KA.document_id = p_doc_id
AND language =  USERENV('LANG')
ORDER BY VB.variable_code;


   BEGIN
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'100: Entered check_user_vars_with_procs');
    END IF;

	get_qa_code_detail(p_qa_code => G_CHECK_INT_VAR_VALUE,
	    x_perform_qa    => l_perform_int_qa,
	    x_qa_name       => l_int_desc,
	    x_severity_flag => l_int_severity,
	    x_return_status => x_return_status);
	IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR ;
	END IF;


    FOR csr_udv_with_procs_rec IN csr_get_udv_with_procs LOOP

        /* Get the variable value */
        IF l_previous_var_code <> csr_udv_with_procs_rec.variable_code THEN

            l_variable_value := NULL;

            OKC_TERMS_UTIL_PVT.get_udv_with_proc_value (
                p_document_type => p_doc_type,
                p_document_id  => p_doc_id,
                p_variable_code => csr_udv_with_procs_rec.variable_code,
                p_output_error => FND_API.G_FALSE,
                x_variable_value =>	l_variable_value,
                x_return_status	=> l_return_status,
                x_msg_data => l_msg_data,
                x_msg_count	=> l_msg_count );

        END IF;

        /* Add to the qa results, if the variable is unresolved */
        IF l_variable_value IS NULL THEN

            l_indx := px_qa_result_tbl.COUNT + 1;

            px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
            px_qa_result_tbl(l_indx).article_id       := csr_udv_with_procs_rec.article_id;
            px_qa_result_tbl(l_indx).deliverable_id   := NULL;
            px_qa_result_tbl(l_indx).title            := get_article_title(csr_udv_with_procs_rec.id);
            px_qa_result_tbl(l_indx).qa_code       := G_CHECK_INT_VAR_VALUE;
            px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_INT_VAR_VALUE;
            px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_INT_VAR_VALUE_S);
            px_qa_result_tbl(l_indx).section_name     := get_section_title(csr_udv_with_procs_rec.scn_id);

            px_qa_result_tbl(l_indx).error_severity      := l_INT_severity;
            px_qa_result_tbl(l_indx).problem_short_desc  := l_INT_desc;
            px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INT_VAR_VALUE_SH, 'VARIABLE', csr_udv_with_procs_rec.variable_name);
            px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INT_VAR_VALUE, 'VARIABLE', csr_udv_with_procs_rec.variable_name,'ARTICLE',px_qa_result_tbl(l_indx).title);

        END IF;

        l_previous_var_code := csr_udv_with_procs_rec.variable_code;

    END LOOP;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'600: Leaving check_user_vars_with_procs');
    END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1100: Leaving  check_user_vars_with_procs : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF csr_get_udv_with_procs%ISOPEN THEN
                CLOSE csr_get_udv_with_procs;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1200: Leaving  check_user_vars_with_procs : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF csr_get_udv_with_procs%ISOPEN THEN
                CLOSE csr_get_udv_with_procs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'1300: Leaving  check_user_vars_with_procs because of EXCEPTION: '||sqlerrm);
            END IF;

            IF csr_get_udv_with_procs%ISOPEN THEN
                CLOSE csr_get_udv_with_procs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

END check_user_vars_with_procs;


    -------------------------------------------
    -- PROCEDURE check_variables
    -------------------------------------------
    /*  API to do QA Check  variables*/

    PROCEDURE check_variables (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name            CONSTANT VARCHAR2(30) := 'G_Check_variables';
        l_indx                NUMBER;
        l_int_severity        OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_int_desc            OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_ext_severity        OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_ext_desc            OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_int_qa    VARCHAR2(1);
        l_perform_ext_qa    VARCHAR2(1);
        l_sys_severity      OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_sys_desc            OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_sys_qa    Varchar2(1);
        l_var_value_tbl        OKC_TERMS_UTIL_GRP.sys_var_value_tbl_type;
        l_msg_count            NUMBER;
        l_msg_data            VARCHAR2(1000);


	-- Bug# 6002595. Modified the cursor to exclude user variables with procedures
	--Rep Enh, Modified cursor to fetch system defined variables for all Repository Document Types
	CURSOR l_check_variable_csr IS
            SELECT kart.id         id,
                kart.sav_sae_id article_id,
                kart.amendment_operation_code amendment_operation_code,
                kart.scn_id scn_id,
                var.variable_code variable_code,
                busvar.variable_name variable_name,
                var.variable_value variable_value,
                var.variable_type,
                var.external_yn,
                var.variable_value_id,
                busvar.mrv_flag,
                var.mr_variable_html,
                var.mr_variable_xml
            FROM   okc_k_articles_b kart,
                okc_k_art_variables var,
                okc_bus_variables_vl busvar
            WHERE  kart.document_type=p_doc_type
                and    kart.document_id=p_doc_id
                and    var.cat_id=kart.id
                and    busvar.variable_code=var.variable_code
                and     nvl(kart.amendment_operation_code,'?')<>G_AMEND_CODE_DELETED
                and     nvl(kart.summary_amend_operation_code,'?')<>G_AMEND_CODE_DELETED
                and    ( (var.variable_type = 'U' AND busvar.variable_source = 'M') OR exists (( SELECT 'x' FROM okc_variable_doc_types vo
                    WHERE vo.variable_code = var.variable_code
                    AND vo.doc_type = p_doc_type
                    )UNION all ( SELECT 'x' FROM okc_variable_doc_types vo
                    WHERE vo.variable_code = var.variable_code
                    AND vo.doc_type LIKE '%REPOSITORY%'))) ;


    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_variables');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_UNRESOLVED_SYS_VAR,
            x_perform_qa    => l_perform_sys_qa ,
            x_qa_name       => l_sys_desc,
            x_severity_flag => l_sys_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_INT_VAR_VALUE,
            x_perform_qa    => l_perform_int_qa,
            x_qa_name       => l_int_desc,
            x_severity_flag => l_int_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_EXT_VAR_VALUE,
            x_perform_qa    => l_perform_ext_qa,
            x_qa_name       => l_ext_desc,
            x_severity_flag => l_ext_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
        IF l_perform_sys_qa ='Y' THEN
           OKC_TERMS_UTIL_PVT.Get_System_Variables (
                p_api_version        => 1,
                x_return_status      => x_return_status,
                x_msg_data           => l_msg_data,
                x_msg_count          => l_msg_count,
                p_doc_type           => p_doc_type,
                p_doc_id             => p_doc_id,
                p_only_doc_variables => FND_API.G_TRUE,
                x_sys_var_value_tbl  => l_var_value_tbl
                );

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
        END IF;--  IF l_perform_sys_qa ='Y' THEN

	-- Bug# 6002595. Invoking check_user_vars_with_procs to check unresolved user variables with procedures
	IF l_perform_int_QA ='Y' THEN

	   check_user_vars_with_procs (
                p_doc_type           => p_doc_type,
                p_doc_id             => p_doc_id,
                px_qa_result_tbl   => px_qa_result_tbl,
                x_return_status    => x_return_status
                );

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

	END IF;
	-- End of fix for Bug# 6002595.

	IF l_perform_int_QA='Y' or l_perform_ext_qa='Y' or l_perform_sys_qa ='Y' THEN

            FOR cr IN l_check_variable_csr LOOP

                IF ( ( cr.variable_type='U' AND cr.external_yn='Y' AND l_perform_ext_qa='Y')
                    AND
                    (  ( Nvl(cr.mrv_flag,'N') = 'N' AND cr.variable_value IS NULL
                       and cr.variable_value_id IS NULL )
                      OR
                      ( Nvl(cr.mrv_flag,'N') = 'Y' AND cr.mr_variable_html IS NULL )
                     )
                   ) THEN

                    l_indx := px_qa_result_tbl.COUNT + 1;

                    px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id       := cr.article_id;
                    px_qa_result_tbl(l_indx).deliverable_id   := Null;
                    px_qa_result_tbl(l_indx).title            := get_article_title(cr.id);
                    px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);
                    px_qa_result_tbl(l_indx).qa_code       := G_CHECK_EXT_VAR_VALUE;
                    px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_EXT_VAR_VALUE;
                    px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_EXT_VAR_VALUE_S);

                    px_qa_result_tbl(l_indx).error_severity      := l_ext_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_ext_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_EXT_VAR_VALUE_SH, 'VARIABLE', cr.variable_name);
                    px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_EXT_VAR_VALUE, 'VARIABLE', cr.variable_name,'ARTICLE',px_qa_result_tbl(l_indx).title);

                ELSIF ( ( cr.variable_type='U' AND cr.external_yn='N' AND l_perform_int_qa='Y')
                        AND
                        (
                           (Nvl(cr.mrv_flag,'N') = 'N' AND cr.variable_value IS NULL
                            and cr.variable_value_id IS NULL )
                            OR
                           (Nvl(cr.mrv_flag,'N') = 'Y' AND cr.mr_variable_html IS NULL )
                         )
                      ) THEN

                    l_indx := px_qa_result_tbl.COUNT + 1;
                    px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id       := cr.article_id;
                    px_qa_result_tbl(l_indx).deliverable_id   := Null;
                    px_qa_result_tbl(l_indx).title            := get_article_title(cr.id);
                    px_qa_result_tbl(l_indx).qa_code       := G_CHECK_INT_VAR_VALUE;
                    px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_INT_VAR_VALUE;
                    px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_INT_VAR_VALUE_S);
                    px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);

                    px_qa_result_tbl(l_indx).error_severity      := l_INT_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_INT_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INT_VAR_VALUE_SH, 'VARIABLE', cr.variable_name);
                    px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_INT_VAR_VALUE, 'VARIABLE', cr.variable_name,'ARTICLE',px_qa_result_tbl(l_indx).title);

                ELSIF cr.variable_type='S'  AND l_perform_sys_qa='Y' THEN

                    IF l_var_value_tbl.COUNT > 0 THEN
                        FOR i IN l_var_value_tbl.FIRST..l_var_value_tbl.LAST LOOP
                            IF l_var_value_tbl(i).variable_code=cr.variable_code AND l_var_value_tbl(i).variable_value_id is NULL THEN

                                l_indx := px_qa_result_tbl.COUNT + 1;
                                px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                                px_qa_result_tbl(l_indx).article_id       := cr.article_id;
                                px_qa_result_tbl(l_indx).deliverable_id   := Null;
                                px_qa_result_tbl(l_indx).title            := get_article_title(cr.id);
                                px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);
                                px_qa_result_tbl(l_indx).qa_code          := G_CHECK_UNRESOLVED_SYS_VAR;
                                px_qa_result_tbl(l_indx).message_name     := G_OKC_CHECK_UNRES_SYS_VAR;
                                px_qa_result_tbl(l_indx).suggestion       := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_UNRES_SYS_VAR_S);

                                px_qa_result_tbl(l_indx).error_severity   := l_sys_severity;
                                px_qa_result_tbl(l_indx).problem_short_desc  := l_sys_desc;
                                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_UNRES_SYS_VAR_SH, 'VARIABLE',cr.variable_name);
                                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_UNRES_SYS_VAR, 'ARTICLE', px_qa_result_tbl(l_indx).title, 'VARIABLE',cr.variable_name);
                            END IF; -- IF l_var_value_tbl(i).variable_code
                        END LOOP; -- FOR i IN l_var_value_tbl.FIRST..
                    END IF; -- IF l_var_value_tbl.COUNT > 0 THEN

                END IF; -- IF cr_variable_type<>'S' AND cr.external_yn='Y'

            END LOOP; -- FOR cr IN l_check_variable_csr LOOP

        END IF; -- IF l_perform_int_QA='Y' or l_perform_ext_qa='Y' or l_perf


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving  Check_variables');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving  Check_variables : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_check_variable_csr%ISOPEN THEN
                CLOSE l_check_variable_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving  Check_variables : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_check_variable_csr%ISOPEN THEN
                CLOSE l_check_variable_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving  Check_variables because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_check_variable_csr%ISOPEN THEN
                CLOSE l_check_variable_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_variables;

    -------------------------------------------
    -- PROCEDURE check_unassigned_articles
    -------------------------------------------
    PROCEDURE check_unassigned_articles (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'G_check_unassigned_articles';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_unas_art_qa VARCHAR2(1);

        CURSOR l_get_unass_art_crs IS
            SELECT
                kart.id id,
                kart.sav_sae_id article_id,
                kart.scn_id     scn_id
                FROM  OKC_K_ARTICLES_B KART,
                OKC_SECTIONS_B   SCN
            WHERE kart.document_type=p_doc_type
                AND   kart.document_id  =p_doc_id
                AND   scn.id       = kart.scn_id
                AND   scn.scn_code   = G_UNASSIGNED_SECTION_CODE
                AND   nvl(scn.amendment_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND   nvl(kart.amendment_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND   nvl(kart.summary_amend_operation_code,'?') <> G_AMEND_CODE_DELETED;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_unassigned_articles');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_UNASSIGNED_ART,
            x_perform_qa    => l_perform_unas_art_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_unas_art_qa='Y' THEN
            FOR cr IN l_get_unass_art_crs LOOP

                l_indx := px_qa_result_tbl.COUNT + 1;

                    px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id       := cr.article_id;
                    px_qa_result_tbl(l_indx).deliverable_id   := Null;
                    px_qa_result_tbl(l_indx).title            := get_article_title(cr.id);
                    px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);
                    px_qa_result_tbl(l_indx).qa_code       := G_CHECK_UNASSIGNED_ART;
                    px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_UNASSIGNED_ART;
                    px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_UNASSIGNED_ART_S);
                    px_qa_result_tbl(l_indx).error_severity := l_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_UNASSIGNED_ART_SH);
                    px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_UNASSIGNED_ART, 'ARTICLE', px_qa_result_tbl(l_indx).title);

            END LOOP; -- FOR cr IN l_get_unass_art_crs LOOP
        END IF; -- IF l_perform_unas_art_qa='Y' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_unassigned_articles');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_unassigned_articles : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_unass_art_crs%ISOPEN THEN
                CLOSE l_get_unass_art_crs;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_unassigned_articles : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_unass_art_crs%ISOPEN THEN
                CLOSE l_get_unass_art_crs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_unassigned_articles because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_unass_art_crs%ISOPEN THEN
                CLOSE l_get_unass_art_crs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_unassigned_articles;

    -------------------------------------------
    -- PROCEDURE check_empty_sections
    -------------------------------------------
    PROCEDURE check_empty_sections (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'G_check_empty_sections';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_empty_scn_qa VARCHAR2(1);

        CURSOR l_get_empty_section_csr IS
            SELECT
                id id,
                scn_id     scn_id
            FROM  OKC_SECTIONS_B SCN
            WHERE document_type=p_doc_type
                AND   document_id  =p_doc_id
                AND   nvl(amendment_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND   nvl(summary_amend_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND   not exists ( SELECT 'x' FROM OKC_K_ARTICLES_B WHERE scn_id=scn.id
                AND nvl(amendment_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND nvl(summary_amend_operation_code,'?') <> G_AMEND_CODE_DELETED)
                AND   not exists ( SELECT 'x' FROM OKC_SECTIONS_B SCN1 WHERE SCN1.scn_id = scn.id
                AND nvl(amendment_operation_code,'?') <> G_AMEND_CODE_DELETED
                AND nvl(summary_amend_operation_code,'?') <> G_AMEND_CODE_DELETED);
            -- if section has sub sections then it is not considered empty Bug 3219528
    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_empty_sections');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_EMPTY_SECTION,
            x_perform_qa    => l_perform_empty_scn_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_empty_scn_QA='Y' THEN
            FOR cr IN l_get_empty_section_csr LOOP

                l_indx := px_qa_result_tbl.COUNT + 1;

                px_qa_result_tbl(l_indx).error_record_type:= G_SCN_QA_TYPE;
                px_qa_result_tbl(l_indx).article_id       := Null;
                px_qa_result_tbl(l_indx).deliverable_id   := Null;
                px_qa_result_tbl(l_indx).title            := get_section_title(cr.id);
                px_qa_result_tbl(l_indx).section_name     := get_section_title(cr.scn_id);
                px_qa_result_tbl(l_indx).qa_code       := G_CHECK_EMPTY_SECTION;
                px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_EMPTY_SECTION;
                px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_EMPTY_SECTION_S);
                px_qa_result_tbl(l_indx).error_severity := l_severity;
                px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_EMPTY_SECTION_SH);
                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_EMPTY_SECTION, 'SECTION', px_qa_result_tbl(l_indx).title);

            END LOOP; -- FOR cr IN l_get_empty_section_csr LOOP
        END IF; -- IF l_perform_empty_scn_QA='Y' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_empty_sections');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_empty_sections : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_empty_section_csr%ISOPEN THEN
                CLOSE l_get_empty_section_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_empty_sections : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_empty_section_csr%ISOPEN THEN
                CLOSE l_get_empty_section_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_empty_sections because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_empty_section_csr%ISOPEN THEN
                CLOSE l_get_empty_section_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_empty_sections;

    -------------------------------------------
    -- PROCEDURE check_section_amend_no_texts
    -------------------------------------------
    PROCEDURE check_section_amend_no_texts (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'G_Check_Section_Amend_No_Texts';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_scn_amend_qa VARCHAR2(1);
        l_disable_amend_yn VARCHAR2(1);

        CURSOR l_get_doc_disable_amend_csr IS
            SELECT NVL(disable_amend_yn,'N')
            FROM OKC_BUS_DOC_TYPES_B
            WHERE  document_type = p_doc_type;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_Section_Amend_No_Texts');
        END IF;

        --Bug 3681462 Check for disable_amend_yn
        OPEN l_get_doc_disable_amend_csr;
            FETCH l_get_doc_disable_amend_csr INTO l_disable_amend_yn;
        CLOSE l_get_doc_disable_amend_csr;

        IF l_disable_amend_yn = 'N' THEN

            get_qa_code_detail(p_qa_code       => G_CHECK_SCN_AMEND_NO_TEXT,
                x_perform_qa    => l_perform_scn_amend_qa,
                x_qa_name       => l_desc,
                x_severity_flag => l_severity,
                x_return_status => x_return_status);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            IF l_perform_scn_amend_qa='Y' THEN
                IF l_section_tbl.count>0 THEN
                    FOR i IN l_section_tbl.FIRST..l_section_tbl.LAST LOOP

                        IF l_section_tbl(i).amendment_operation_code IS NOT NULL AND l_section_tbl(i).amendment_description IS NULL THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;

                            px_qa_result_tbl(l_indx).error_record_type:= G_SCN_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id       := Null;
                            px_qa_result_tbl(l_indx).deliverable_id   := Null;
                            px_qa_result_tbl(l_indx).title            := get_section_title(l_section_tbl(i).id);
                            px_qa_result_tbl(l_indx).section_name     := get_section_title(l_section_tbl(i).scn_id);
                            px_qa_result_tbl(l_indx).qa_code       := G_CHECK_SCN_AMEND_NO_TEXT;
                            px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_SCN_AMEND_NO_TEXT;
                            px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHK_SCN_AMEND_NO_TEXT_S);
                            px_qa_result_tbl(l_indx).error_severity := l_severity;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                            px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHK_SCN_AMEND_NO_TEXT_SH);
                            px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_SCN_AMEND_NO_TEXT, 'SECTION', px_qa_result_tbl(l_indx).title);
                        END IF; -- IF l_section_tbl(i).amendment_operation_code

                    END LOOP;-- FOR i IN l_section_tbl.FIRST..l_section_tbl.LAST
                END IF; -- IF l_section_tbl.count>0 THEN
            END IF; -- IF l_perform_scn_amend_qa='Y' THEN

        END IF; --  l_disable_amend_yn = 'N'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_Section_Amend_No_Texts');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_Section_Amend_No_Texts : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_Section_Amend_No_Texts : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_Section_Amend_No_Texts because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_section_amend_no_texts;

    -------------------------------------------
    -- PROCEDURE check_article_amend_no_texts
    -------------------------------------------
    PROCEDURE check_article_amend_no_texts (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'G_check_article_amend_no_texts';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_art_amend_qa VARCHAR2(1);
        l_disable_amend_yn VARCHAR2(1);

        CURSOR l_get_doc_disable_amend_csr IS
            SELECT NVL(disable_amend_yn,'N')
            FROM OKC_BUS_DOC_TYPES_B
            WHERE  document_type = p_doc_type;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_article_amend_no_texts');
        END IF;

        --Bug 3681462 Check for disable_amend_yn
        OPEN l_get_doc_disable_amend_csr;
        FETCH l_get_doc_disable_amend_csr INTO l_disable_amend_yn;
        CLOSE l_get_doc_disable_amend_csr;

        IF l_disable_amend_yn = 'N' THEN

            get_qa_code_detail(p_qa_code       => G_CHECK_ART_AMEND_NO_TEXT,
                x_perform_qa    => l_perform_art_amend_qa,
                x_qa_name       => l_desc,
                x_severity_flag => l_severity,
                x_return_status => x_return_status);
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

            IF l_perform_art_amend_qa ='Y' THEN

                IF l_article_tbl.count > 0 THEN

                    FOR i IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP

                        IF l_article_tbl(i).amendment_operation_code IS NOT NULL
                            AND l_article_tbl(i).amendment_description IS NULL THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;

                            px_qa_result_tbl(l_indx).error_record_type:= G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id       := l_article_tbl(i).article_id;
                            px_qa_result_tbl(l_indx).deliverable_id   := Null;
                            px_qa_result_tbl(l_indx).title            := get_article_title(l_article_tbl(i).id);
                            px_qa_result_tbl(l_indx).section_name     := get_section_title(l_article_tbl(i).scn_id);
                            px_qa_result_tbl(l_indx).qa_code       := G_CHECK_ART_AMEND_NO_TEXT;
                            px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_ART_AMEND_NO_TEXT;
                            px_qa_result_tbl(l_indx).suggestion    := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHK_ART_AMEND_NO_TEXT_S);
                            px_qa_result_tbl(l_indx).error_severity := l_severity;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                            px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHK_ART_AMEND_NO_TEXT_SH);
                            px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_AMEND_NO_TEXT, 'ARTICLE', px_qa_result_tbl(l_indx).title);
                        END IF; -- IF l_article_tbl(i).amendment_operation_code I

                    END LOOP; -- FOR i IN l_article_tbl.FIRST..l_article_tbl.LAST LOOP
                END IF; -- IF l_article_tbl.count>0 THEN
            END IF; -- IF l_perform_art_amend_qa ='Y' THEN

        END IF; -- l_disable_amend_yn = 'N'

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_article_amend_no_texts');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_article_amend_no_texts : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_article_amend_no_texts : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_article_amend_no_texts because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_article_amend_no_texts;

    -------------------------------------------
    -- PROCEDURE check_inactive_template
    -------------------------------------------
    /* Check inactive Template */

    PROCEDURE check_inactive_template (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name       CONSTANT VARCHAR2(30) := 'check_inactive_template';
        l_indx           NUMBER;
        l_severity       OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc           OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_tmpl_qa VARCHAR2(1);
        l_tmpl_usg_exists_flag varchar2(1):=OKC_API.G_MISS_CHAR;
        l_doc_type_name  OKC_BUS_DOC_TYPES_TL.NAME%TYPE;


        CURSOR l_get_template_crs IS
            SELECT status_code,end_date,template_name
            FROM
                OKC_TERMS_TEMPLATES_ALL TMPL,
                OKC_TEMPLATE_USAGES USG
            WHERE  USG.DOCUMENT_TYPE = p_doc_type
                AND    USG.DOCUMENT_ID   = p_doc_id
                AND    TMPL.TEMPLATE_ID  = USG.TEMPLATE_ID;

         --Bug 4126819 Added cursor to get check if the template is associated to the document.
         CURSOR l_get_template_usg_csr IS
             SELECT 'Y'
             FROM OKC_ALLOWED_TMPL_USAGES
             WHERE TEMPLATE_ID = (SELECT TEMPLATE_ID
                                  FROM OKC_TEMPLATE_USAGES
                                  WHERE DOCUMENT_ID = p_doc_id
                                    AND DOCUMENT_TYPE = p_doc_type)
                    AND DOCUMENT_TYPE = p_doc_type;
         --Bug 4126819 Added cursor to get the document type
         CURSOR l_get_doc_type_name IS
              SELECT name
              FROM okc_bus_doc_types_tl
              WHERE document_type = p_doc_type
                    AND LANGUAGE = userenv('LANG');

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_inactive_template');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_TMPL_EFFECTIVITY,
            x_perform_qa    => l_perform_tmpl_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        IF l_perform_tmpl_qa ='Y' THEN
            FOR cr in l_get_template_crs LOOP

                IF cr.status_code='ON_HOLD'
                    OR (  cr.status_code='APPROVED'
                    AND nvl(cr.end_date,sysdate+1)< sysdate)  THEN

                    l_indx := px_qa_result_tbl.COUNT + 1;

                    px_qa_result_tbl(l_indx).error_record_type   := G_TMPL_QA_TYPE;
                    px_qa_result_tbl(l_indx).article_id          := Null;
                    px_qa_result_tbl(l_indx).deliverable_id      := Null;
                    px_qa_result_tbl(l_indx).title               := cr.template_name;
                    px_qa_result_tbl(l_indx).section_name        := Null;
                    px_qa_result_tbl(l_indx).qa_code             := G_CHECK_TMPL_EFFECTIVITY;
                    px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_TMPL_EFFECTIVITY;
                    px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_TMPL_EFFECTIVITY_S);
                    px_qa_result_tbl(l_indx).error_severity      := l_severity;
                    px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                    px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHK_TMPL_EFFECTIVITY_SH);
                    px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TMPL_EFFECTIVITY, 'TEMPLATE', cr.template_name);
                END IF; -- IF cr.status_code='ON_HOLD'

               --Bug 4126819 Getting the document type
	       OPEN l_get_doc_type_name;
               FETCH l_get_doc_type_name into l_doc_type_name;
               CLOSE l_get_doc_type_name;

               --Checking if the template is associated to the document type.
               OPEN l_get_template_usg_csr;
                    FETCH l_get_template_usg_csr into l_tmpl_usg_exists_flag;
                    IF l_get_template_usg_csr%NOTFOUND THEN

                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_TMPL_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := Null;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title               := cr.template_name;
                        px_qa_result_tbl(l_indx).section_name        := Null;
                        px_qa_result_tbl(l_indx).qa_code             := G_CHECK_TMPL_EFFECTIVITY;
                        px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_TEMPL_USG_ASSO;
                        px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_TEMPL_USG_ASSO_S,'DOCUMENT_TYPE',l_doc_type_name);
                        px_qa_result_tbl(l_indx).error_severity      := l_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TEMPL_USG_ASSO_SH);
                        px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TEMPL_USG_ASSO,'DOCUMENT_TYPE',l_doc_type_name,'TEMPLATE', cr.template_name);
                    END IF;
            	CLOSE l_get_template_usg_csr;

            END LOOP; -- FOR cr in l_get_template_crs LOOP
        END IF; -- IF l_perform_tmpl_qa ='Y' THEN


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_inactive_template');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_inactive_template : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_template_crs%ISOPEN THEN
                CLOSE l_get_template_crs;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_inactive_template : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_template_crs%ISOPEN THEN
                CLOSE l_get_template_crs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_inactive_template because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_template_crs%ISOPEN THEN
                CLOSE l_get_template_crs;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_inactive_template;

    -------------------------------------------
    -- PROCEDURE check_art_effectivity
    -------------------------------------------
    /* Check article effectitvity  */

    PROCEDURE check_art_effectivity (
        p_qa_mode          IN  VARCHAR2,
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2    )
    IS

        l_api_name       CONSTANT VARCHAR2(30) := 'G_check_art_effectivity';
        l_indx           NUMBER;
        l_indx1          NUMBER;
        l_art_val_severity       OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_art_val_desc           OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;

        l_lat_vers_severity       OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_lat_vers_desc           OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_start_date              DATE;
        l_end_date                DATE;
        l_found                   BOOLEAN := FALSE;

        l_perform_art_val_qa      VARCHAR2(1);
        l_perform_lat_vers_qa      VARCHAR2(1);
        TYPE article_version_tbl_type       IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
        l_article_version_tbl     article_version_tbl_type;

        CURSOR l_get_tmpl_dates_csr IS
            SELECT START_DATE,END_DATE
            FROM OKC_TERMS_TEMPLATES_ALL
            WHERE TEMPLATE_ID=p_doc_id;

        /* This will executed only in TEMPLATE QA */
        /*
        CURSOR l_check_art_tmpl_csr(p_article_effective_date IN DATE) IS
            SELECT kart.id,
                kart.sav_sae_id article_id,
                kart.scn_id scn_id,
                kart.amendment_operation_code amendment_operation_code,
                kart.amendment_description amendment_description
            FROM OKC_K_ARTICLES_B KART
            WHERE DOCUMENT_TYPE=p_doc_type
                AND   DOCUMENT_ID  =p_doc_id
                AND   NOT EXISTS ( SELECT 'X' FROM OKC_ARTICLE_VERSIONS VERS
                    WHERE VERS.ARTICLE_ID=KART.SAV_SAE_ID
                    AND VERS.ARTICLE_STATUS='APPROVED'
                    AND nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
                    AND nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
            );

        */

        /* This will executed only in TEMPLATE QA
        11.5.10+ Modify the cursor l_check_art_tmpl_csr to allow draft/rejected clauses also*/

        CURSOR l_check_art_tmpl_csr(p_article_effective_date IN DATE) IS
            SELECT kart.id,
                kart.sav_sae_id article_id,
                kart.scn_id scn_id,
                kart.amendment_operation_code amendment_operation_code,
                kart.amendment_description amendment_description
            FROM OKC_K_ARTICLES_B KART,
                okc_terms_templates_all tmpl,
                okc_articles_all art
            WHERE kart.document_id = tmpl.template_id
                AND  kart.sav_sae_id = art.article_id
                AND DOCUMENT_TYPE=p_doc_type
                AND   DOCUMENT_ID  =p_doc_id
                AND
                    (
                        ( art.org_id <> tmpl.org_id
                        AND NOT EXISTS ( SELECT 'X'
                            FROM OKC_ARTICLE_ADOPTIONS  ADP,
                                OKC_ARTICLE_VERSIONS VER
                            WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VER.article_version_id
                                AND   VER.article_id = KART.SAV_SAE_ID
                                AND   ADP.LOCAL_ORG_ID = tmpl.org_id
                                AND   ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
                                AND   ADP.ADOPTION_TYPE = 'ADOPTED'
                                AND   VER.ARTICLE_STATUS='APPROVED'
                                AND nvl(p_article_effective_date,sysdate) >=  VER.START_DATE
                                AND nvl(p_article_effective_date,sysdate)
                                    <= nvl(VER.end_date, nvl(p_article_effective_date,sysdate) +1)
                            )
                        )  OR
                        ( art.org_id = tmpl.org_id
                        AND   NOT EXISTS ( SELECT 'X' FROM OKC_ARTICLE_VERSIONS VERS
                            WHERE VERS.ARTICLE_ID=KART.SAV_SAE_ID
                                -- modified to include DRAFT and REJECTED statuses also
                                --AND VERS.ARTICLE_STATUS='APPROVED'
                                AND VERS.ARTICLE_STATUS in ('APPROVED', 'DRAFT' , 'REJECTED')
                                AND nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
                                AND nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date, nvl(p_article_effective_date,sysdate) +1)
                            )
                        )
                    );


        /* Define a new cursor to check expert clauses for validity */
        /* expert commented out
        CURSOR l_check_xprt_art_tmpl_csr (p_article_effective_date IN DATE) IS
            SELECT
                Rule.clause_id         xprt_article_id,
                Rule.rule_id        rule_id,
                Rule.rule_name        rule_name
            FROM    okc_xprt_clauses_v  rule,
                okc_terms_templates_all tmpl,
                okc_articles_all art
            WHERE rule.template_id = tmpl.template_id
                AND tmpl.template_id = p_doc_id
                AND art.article_id = rule.clause_id
                AND
                (
                    ( art.org_id <> tmpl.org_id
                    AND NOT EXISTS ( SELECT 'X'
                        FROM OKC_ARTICLE_ADOPTIONS  ADP,
                        OKC_ARTICLE_VERSIONS VER
                        WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VER.article_version_id
                        AND   VER.article_id = rule.clause_id
                        AND   ADP.LOCAL_ORG_ID = tmpl.org_id
                        AND   ADP.adoption_status IN ( 'APPROVED', 'ON_HOLD')
                        AND   ADP.ADOPTION_TYPE = 'ADOPTED'
                        AND   VER.ARTICLE_STATUS='APPROVED'
                        AND nvl(p_article_effective_date,sysdate) >=  VER.START_DATE
                        AND nvl(p_article_effective_date,sysdate) <= nvl(VER.end_date,
                            nvl(p_article_effective_date,sysdate) +1)
                        )
                    )
                    OR
                    ( art.org_id = tmpl.org_id
                    AND   NOT EXISTS ( SELECT 'X' FROM OKC_ARTICLE_VERSIONS VERS
                        WHERE VERS.ARTICLE_ID=rule.clause_id
                        AND VERS.ARTICLE_STATUS in ('APPROVED', 'DRAFT' , 'REJECTED')
                        AND nvl(p_article_effective_date,sysdate) >=  VERS.START_DATE
                        AND nvl(p_article_effective_date,sysdate) <= nvl(VERS.end_date,
                        nvl(p_article_effective_date,sysdate) +1)
                        )
                    )
                );
        */

        CURSOR l_check_art_doc_csr(b_effective_date IN DATE) IS
            SELECT kart.id,
                kart.sav_sae_id article_id,
                kart.article_version_id article_version_id,
                kart.scn_id scn_id,
                vers.start_date start_date,
                kart.amendment_operation_code amendment_operation_code,
                kart.amendment_description amendment_description
            FROM OKC_K_ARTICLES_B KART,
                OKC_ARTICLE_VERSIONS VERS,
                OKC_ARTICLES_ALL ART
            WHERE DOCUMENT_TYPE=p_doc_type
                AND   DOCUMENT_ID  =p_doc_id
                AND   VERS.ARTICLE_VERSION_ID=KART.ARTICLE_VERSION_ID
                AND   ART.ARTICLE_ID = KART.SAV_SAE_ID
                AND   ART.STANDARD_YN='Y'
                AND   nvl(AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
                AND   nvl(SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
                AND   ( ARTICLE_STATUS<>'APPROVED'
                    OR ( ARTICLE_STATUS='APPROVED' AND
                    nvl(END_DATE,b_effective_date+1)< b_effective_date
                        )
                    );

        CURSOR l_check_latest_version_csr IS
            SELECT distinct KART.ID ID,
                KART.SAV_SAE_ID ARTICLE_ID,
                KART.ARTICLE_VERSION_ID ARTICLE_VERSION_ID,
                KART.SCN_ID SCN_ID,
                KART.AMENDMENT_OPERATION_CODE AMENDMENT_OPERATION_CODE,
                KART.AMENDMENT_DESCRIPTION AMENDMENT_DESCRIPTION
            FROM   OKC_K_ARTICLES_B KART,
                OKC_ARTICLE_VERSIONS VERS,
                OKC_ARTICLE_VERSIONS VERS1,
                OKC_TEMPLATE_USAGES USG,
                OKC_TERMS_TEMPLATES_ALL TMPL
            WHERE  KART.DOCUMENT_TYPE=p_doc_type
                AND    KART.DOCUMENT_ID  =p_doc_id
                AND    KART.DOCUMENT_TYPE= USG.DOCUMENT_TYPE
                AND    KART.DOCUMENT_ID  = USG.DOCUMENT_ID
                AND    USG.TEMPLATE_ID = TMPL.TEMPLATE_ID
                AND    KART.SAV_SAE_ID = VERS.ARTICLE_ID
                AND    nvl(KART.AMENDMENT_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
                AND    nvl(KART.SUMMARY_AMEND_OPERATION_CODE,'?')<>G_AMEND_CODE_DELETED
                AND    KART.ARTICLE_VERSION_ID = VERS1.ARTICLE_VERSION_ID
                AND    VERS.START_DATE > VERS1.START_DATE
                AND    trunc(NVL(USG.ARTICLE_EFFECTIVE_DATE,SYSDATE)) BETWEEN trunc(VERS.START_DATE) AND NVL(VERS.END_DATE,SYSDATE)
                AND    VERS.ARTICLE_STATUS = 'APPROVED'
                AND    (EXISTS
                            (SELECT 1
                            FROM OKC_ARTICLE_ADOPTIONS ADP
                            WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
                                AND ADP.ADOPTION_TYPE = 'ADOPTED'
                                AND ADP.ADOPTION_STATUS = 'APPROVED'
                                AND ADP.LOCAL_ORG_ID = TMPL.ORG_ID)
                        OR
                        NOT EXISTS
                            (SELECT 1
                            FROM OKC_ARTICLE_ADOPTIONS ADP
                            WHERE ADP.GLOBAL_ARTICLE_VERSION_ID = VERS1.ARTICLE_VERSION_ID
                                AND ADP.ADOPTION_TYPE = 'ADOPTED'
                            AND ADP.LOCAL_ORG_ID = TMPL.ORG_ID)
                        ) ;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_art_effectivity');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_VALIDITY,
            x_perform_qa    => l_perform_art_val_qa,
            x_qa_name       => l_art_val_desc,
            x_severity_flag => l_art_val_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_LATEST_VERSION,
            x_perform_qa    => l_perform_lat_vers_qa,
            x_qa_name       => l_lat_vers_desc,
            x_severity_flag => l_lat_vers_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        -- 11.5.10+: check should be OR not AND
        --IF l_perform_art_val_qa='Y' AND  l_perform_lat_vers_qa='Y' THEN
        IF l_perform_art_val_qa='Y' OR  l_perform_lat_vers_qa='Y' THEN


            IF p_doc_type=G_TMPL_DOC_TYPE THEN

                IF l_perform_art_val_qa='Y' THEN

                    /*
                    OPEN  l_get_tmpl_dates_csr;
                    FETCH l_get_tmpl_dates_csr INTO l_start_date,l_end_date;
                    CLOSE l_get_tmpl_dates_csr;
                    */

                    IF (NOT do_validation(l_art_val_severity, p_doc_type))  THEN
                        -- validation is not required
                        RETURN;
                    END IF;

                    FOR cr in l_check_art_tmpl_csr(l_article_effective_date) LOOP
                    -- FOR cr in l_check_art_tmpl_csr(l_start_date,l_end_date) LOOP
                        l_indx := px_qa_result_tbl.COUNT + 1;

                        px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id          := cr.article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;
                        px_qa_result_tbl(l_indx).title               := Get_article_title(cr.id);
                        px_qa_result_tbl(l_indx).section_name        := Get_section_title(cr.scn_id);
                        px_qa_result_tbl(l_indx).qa_code             := G_CHECK_ART_VALIDITY;
                        px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_TMPL_ART_VALIDITY;
                        px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_TMPL_ART_VALID_S);
                        px_qa_result_tbl(l_indx).error_severity      := l_art_val_severity;
                        px_qa_result_tbl(l_indx).problem_short_desc  := l_art_val_desc;
                        px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TMPL_ART_VALID_SH);
                        px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TMPL_ART_VALIDITY, 'ARTICLE', px_qa_result_tbl(l_indx).title);

                    END LOOP; -- FOR cr in l_check_art_tmpl_csr

                    /* expert commented out
                    -- check expert clauses for validtity
                    IF  (g_expert_enabled = 'Y') THEN
                        FOR cr IN l_check_xprt_art_tmpl_csr(l_article_effective_date ) LOOP
                            l_indx := px_qa_result_tbl.COUNT + 1;

                            px_qa_result_tbl(l_indx).error_record_type   := G_EXP_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id          := cr.xprt_article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;
                            px_qa_result_tbl(l_indx).title           :=
                                get_xprt_article_title(cr.xprt_article_id);
                            px_qa_result_tbl(l_indx).section_name        := Null;

                            px_qa_result_tbl(l_indx).qa_code       := G_CHECK_RUL_ART_VAL;
                            px_qa_result_tbl(l_indx).message_name  := G_OKC_CHECK_RUL_ART_VAL;
                            px_qa_result_tbl(l_indx).suggestion    :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_ART_VAL_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_art_val_severity;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_art_val_desc;
                            px_qa_result_tbl(l_indx).problem_details_short     :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_RUL_ART_VAL_SH);
                            px_qa_result_tbl(l_indx).problem_details   :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_RUL_ART_VAL,
                                    'RULE', cr.rule_name,
                                    'XPRT_ARTICLE', get_xprt_article_title(cr.xprt_article_id)
                                    );
                        END LOOP;
                    END IF; -- of IF  (g_expert_enabled = 'Y') THEN
                    */

                END IF; -- of IF l_perform_art_val_qa='Y' THEN

            ELSE

                -- non TEMPLATE document types
                IF l_perform_lat_vers_qa ='Y' THEN
                    FOR cr IN l_check_latest_version_csr LOOP
                        IF (  p_qa_mode =G_AMEND_QA
                            AND cr.amendment_operation_code IS NOT NULL
                            )
                            OR p_qa_mode<>G_AMEND_QA THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;

                            l_indx1 := l_article_version_tbl.COUNT + 1;
                            l_article_version_tbl(l_indx1) := cr.article_version_id;

                            px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id          := cr.article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;
                            px_qa_result_tbl(l_indx).title               := Get_article_title(cr.id);
                            px_qa_result_tbl(l_indx).section_name        := Get_section_title(cr.scn_id);
                            px_qa_result_tbl(l_indx).qa_code             := G_CHECK_LATEST_VERSION;
                            px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_LATEST_VERSION;
                            px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_LATEST_VERSION_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_lat_vers_severity;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_lat_vers_desc;
                            px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LATEST_VERSION_SH);
                            px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LATEST_VERSION, 'ARTICLE', px_qa_result_tbl(l_indx).title);

                        END IF; -- IF (  p_qa_mode =G_AMEND_QA
                    END LOOP; -- FOR cr IN l_check_latest_version_csr LOOP
                END IF; -- IF l_perform_lat_vers_qa ='Y' THEN

                IF l_perform_art_val_qa='Y' THEN
                    FOR cr in l_check_art_doc_csr(l_article_effective_date) LOOP

                        IF (  p_qa_mode =G_AMEND_QA
                            AND cr.amendment_operation_code IS NOT NULL
                            )
                            OR p_qa_mode<>G_AMEND_QA THEN

                            l_found := FALSE;

                            IF l_article_version_tbl.COUNT > 0 THEN
                                FOR k in l_article_version_tbl.FIRST..l_article_version_tbl.LAST LOOP
                                    IF l_article_version_tbl(k) = cr.article_version_id THEN
                                        l_found := TRUE;
                                    END IF;
                                END LOOP; -- FOR k in l_article_version_tbl.FI
                            END IF; -- IF l_article_version_tbl.COUNT > 0 THEN

                            IF NOT l_found THEN
                                l_indx := px_qa_result_tbl.COUNT + 1;

                                px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                                px_qa_result_tbl(l_indx).article_id          := cr.article_id;
                                px_qa_result_tbl(l_indx).deliverable_id      := Null;
                                px_qa_result_tbl(l_indx).title               := Get_article_title(cr.id);
                                px_qa_result_tbl(l_indx).section_name        := Get_section_title(cr.scn_id);

                                px_qa_result_tbl(l_indx).qa_code             := G_CHECK_ART_VALIDITY;
                                px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_ART_VALIDITY;
                                px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_ART_VALIDITY_S);
                                px_qa_result_tbl(l_indx).error_severity      := l_art_val_severity;
                                px_qa_result_tbl(l_indx).problem_short_desc  := l_art_val_desc;
                                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_VALIDITY_SH);
                                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_VALIDITY, 'ARTICLE', px_qa_result_tbl(l_indx).title);
                            END IF; -- IF NOT l_found THEN

                        END IF; -- IF (  p_qa_mode =G_AMEND_QA

                    END LOOP; -- FOR cr in l_check_art_doc_csr(l_article_effect

                END IF;  -- IF l_perform_art_val_qa='Y' THEN

            END IF;  -- IF p_doc_type=G_TMPL_DOC_TYPE ELSE branch

        END IF; -- IF l_perform_art_val_qa='Y' OR l_perform_lat_vers_qa='Y'


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_art_effectivity');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_art_effectivity : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_tmpl_dates_csr%ISOPEN THEN
                CLOSE l_get_tmpl_dates_csr;
            END IF;
            IF l_check_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_art_tmpl_csr;
            END IF;
            IF l_check_art_doc_csr%ISOPEN THEN
                CLOSE l_check_art_doc_csr;
            END IF;
            IF l_check_latest_version_csr%ISOPEN THEN
                CLOSE l_check_latest_version_csr;
            END IF;

            /* expert commented out
            IF l_check_xprt_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_xprt_art_tmpl_csr;
            END IF;
            */

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_art_effectivity : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_tmpl_dates_csr%ISOPEN THEN
                CLOSE l_get_tmpl_dates_csr;
            END IF;
            IF l_check_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_art_tmpl_csr;
            END IF;
            IF l_check_art_doc_csr%ISOPEN THEN
                CLOSE l_check_art_doc_csr;
            END IF;
            IF l_check_latest_version_csr%ISOPEN THEN
                CLOSE l_check_latest_version_csr;
            END IF;

            /* expert commented out
            IF l_check_xprt_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_xprt_art_tmpl_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_art_effectivity because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_tmpl_dates_csr%ISOPEN THEN
                CLOSE l_get_tmpl_dates_csr;
            END IF;
            IF l_check_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_art_tmpl_csr;
            END IF;
            IF l_check_art_doc_csr%ISOPEN THEN
                CLOSE l_check_art_doc_csr;
            END IF;
            IF l_check_latest_version_csr%ISOPEN THEN
                CLOSE l_check_latest_version_csr;
            END IF;

            /* expert commented out
            IF l_check_xprt_art_tmpl_csr%ISOPEN THEN
                CLOSE l_check_xprt_art_tmpl_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;
    END check_art_effectivity;

    -------------------------------------------
    -- PROCEDURE check_layout_template
    -------------------------------------------
    /* check_layout_template */

    PROCEDURE check_layout_template (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'G_CHECK_LAYOUT_TEMPLATE';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_layout_tmpl_qa VARCHAR2(1);
        l_template_name     OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
        l_print_template_id OKC_TERMS_TEMPLATES_ALL.PRINT_TEMPLATE_ID%TYPE;

        CURSOR l_get_layout_tmpl_csr IS
        SELECT template_name, print_template_id
        FROM  okc_terms_templates_all
        WHERE template_id = p_doc_id ;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_layout_template');
        END IF;
        get_qa_code_detail(p_qa_code       => G_CHECK_LAYOUT_TMPL,
            x_perform_qa    => l_perform_layout_tmpl_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


        IF l_perform_layout_tmpl_qa='Y' THEN

            IF NOT do_validation(l_severity, p_doc_type) THEN
                -- validation is not required
                RETURN;
              END IF;

            OPEN l_get_layout_tmpl_csr;
            FETCH l_get_layout_tmpl_csr INTO l_template_name, l_print_template_id;
            CLOSE l_get_layout_tmpl_csr;

            IF l_print_template_id IS NULL THEN

                l_indx := px_qa_result_tbl.COUNT + 1;

                px_qa_result_tbl(l_indx).error_record_type   := G_TMPL_QA_TYPE;
                px_qa_result_tbl(l_indx).article_id          := Null;
                px_qa_result_tbl(l_indx).deliverable_id      := Null;
                px_qa_result_tbl(l_indx).title               := l_template_name;
                px_qa_result_tbl(l_indx).section_name        := Null;
                px_qa_result_tbl(l_indx).qa_code             := G_CHECK_LAYOUT_TMPL;
                px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_LAYOUT_TMPL;
                px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_LAYOUT_TMPL_S);
                px_qa_result_tbl(l_indx).error_severity      := l_severity;
                px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LAYOUT_TMPL);
                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_LAYOUT_TMPL);

            END IF;

        END IF; -- IF l_perform_layout_tmpl_qa='Y' THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_layout_template');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_layout_template : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_layout_tmpl_csr%ISOPEN THEN
                CLOSE l_get_layout_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_layout_template : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_layout_tmpl_csr%ISOPEN THEN
                CLOSE l_get_layout_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_layout_template because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_layout_tmpl_csr%ISOPEN THEN
                CLOSE l_get_layout_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_layout_template;


--MLS for templates
    -------------------------------------------
    -- PROCEDURE Check_translated_tmpl_revision
    -------------------------------------------
    /* Check_translated_tmpl_revision */

    PROCEDURE Check_translated_tmpl_rev (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(40) := 'G_CHECK_TRANSLATED_TMPL_REVISION';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_trans_rev_qa VARCHAR2(1);
        l_template_name     OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
	l_trans_tmpl_name   OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
        l_template_id       OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE;

        CURSOR l_translated_tmpl_revision_csr IS
          SELECT parent.template_id, parent.template_name, trans.template_name
          FROM okc_terms_templates_all parent, okc_terms_templates_all trans
          WHERE parent.template_id = trans.translated_from_tmpl_id
          AND  trans.template_id = p_doc_id
          AND  exists (SELECT 1
                      FROM  okc_terms_templates_all revision
                      WHERE parent.template_id = revision.parent_template_id);


    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_translated_tmpl_revision');
        END IF;
        get_qa_code_detail(p_qa_code       => G_CHECK_TRANS_TMPL_REVISION,
            x_perform_qa    => l_perform_trans_rev_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


        IF l_perform_trans_rev_qa ='Y' THEN

            IF NOT do_validation(l_severity, p_doc_type) THEN
                -- validation is not required
                RETURN;
              END IF;

            OPEN l_translated_tmpl_revision_csr;
            FETCH l_translated_tmpl_revision_csr INTO l_template_id, l_template_name, l_trans_tmpl_name;
            CLOSE l_translated_tmpl_revision_csr;

            IF l_template_id IS NOT NULL THEN

                l_indx := px_qa_result_tbl.COUNT + 1;

                px_qa_result_tbl(l_indx).error_record_type   := G_TMPL_QA_TYPE;
                px_qa_result_tbl(l_indx).article_id          := Null;
                px_qa_result_tbl(l_indx).deliverable_id      := Null;
                px_qa_result_tbl(l_indx).title               := l_trans_tmpl_name;
                px_qa_result_tbl(l_indx).section_name        := Null;
                px_qa_result_tbl(l_indx).qa_code             := G_CHECK_TRANS_TMPL_REVISION;
                px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_TRANS_TMPL_REV;
                px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_TRANS_TMPL_REV_S);
                px_qa_result_tbl(l_indx).error_severity      := l_severity;
                px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TRANS_TMPL_REV_SH,'TMPL1',l_template_name);
                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TRANS_TMPL_REV,'TMPL1',l_template_name);

            END IF;

        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_translated_tmpl_revision');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_translated_tmpl_revision : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_translated_tmpl_revision_csr%ISOPEN THEN
                CLOSE l_translated_tmpl_revision_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_translated_tmpl_revision : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_translated_tmpl_revision_csr%ISOPEN THEN
                CLOSE l_translated_tmpl_revision_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_translated_tmpl_revision because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_translated_tmpl_revision_csr%ISOPEN THEN
                CLOSE l_translated_tmpl_revision_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END Check_translated_tmpl_rev;


--MLS for templates

    -------------------------------------------
    -- PROCEDURE Check_translated_tmpl_effectivity
    -------------------------------------------
    /* Check_translated_tmpl_effectivity */

    PROCEDURE Check_translated_tmpl_eff (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(40) := 'G_CHECK_TRANSLATED_TMPL_EFFECTIVITY';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_trans_tmpl_eff_qa VARCHAR2(1);
        l_template_name     OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
	l_trans_tmpl_name   OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE;
        l_template_id       OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE;

        CURSOR l_get_trans_tmpl_csr IS
          SELECT parent.template_id, parent.template_name, trans.template_name
          FROM okc_terms_templates_all parent, okc_terms_templates_all trans
          WHERE ( trunc(sysdate) >= nvl(trunc(parent.end_date),sysdate+1)
                  OR parent.status_code = 'ON_HOLD' )
          AND  parent.template_id = trans.translated_from_tmpl_id
          AND  trans.template_id = p_doc_id;


    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered Check_translated_tmpl_effectivity');
        END IF;
        get_qa_code_detail(p_qa_code       => G_CHECK_TRANS_TMPL_EFF,
            x_perform_qa    => l_perform_trans_tmpl_eff_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


        IF l_perform_trans_tmpl_eff_qa ='Y' THEN

            IF NOT do_validation(l_severity, p_doc_type) THEN
                -- validation is not required
                RETURN;
              END IF;

            OPEN l_get_trans_tmpl_csr;
            FETCH l_get_trans_tmpl_csr INTO l_template_id, l_template_name, l_trans_tmpl_name;
            CLOSE l_get_trans_tmpl_csr;

            IF l_template_id IS NOT NULL THEN

                l_indx := px_qa_result_tbl.COUNT + 1;

                px_qa_result_tbl(l_indx).error_record_type   := G_TMPL_QA_TYPE;
                px_qa_result_tbl(l_indx).article_id          := Null;
                px_qa_result_tbl(l_indx).deliverable_id      := Null;
                px_qa_result_tbl(l_indx).title               := l_trans_tmpl_name;
                px_qa_result_tbl(l_indx).section_name        := Null;
                px_qa_result_tbl(l_indx).qa_code             := G_CHECK_TRANS_TMPL_EFF;
                px_qa_result_tbl(l_indx).message_name        := G_OKC_CHECK_TRANS_TMPL_EFF ;
                px_qa_result_tbl(l_indx).suggestion          := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_TRANS_TMPL_EFF_S);
                px_qa_result_tbl(l_indx).error_severity      := l_severity;
                px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
                px_qa_result_tbl(l_indx).problem_details_short     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TRANS_TMPL_EFF_SH,'TMPL1',l_template_name);
                px_qa_result_tbl(l_indx).problem_details     := OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_TRANS_TMPL_EFF,'TMPL1',l_template_name);

            END IF;

        END IF;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving Check_translated_tmpl_effectivity');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving Check_translated_tmpl_effectivity : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_trans_tmpl_csr%ISOPEN THEN
                CLOSE l_get_trans_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving Check_translated_tmpl_effectivity : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_get_trans_tmpl_csr%ISOPEN THEN
                CLOSE l_get_trans_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving Check_translated_tmpl_effectivity because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_trans_tmpl_csr%ISOPEN THEN
                CLOSE l_get_trans_tmpl_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END Check_translated_tmpl_eff;

--MLS for templates


    -------------------------------------------
    -- PROCEDURE check_articles_exist
    -------------------------------------------
    /* check_articles_exist */

    PROCEDURE check_articles_exist (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        l_api_name          CONSTANT VARCHAR2(30) := 'check_articles_exist';
        l_indx              NUMBER;
        l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
        l_perform_articles_exist_qa        VARCHAR2(1);

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_articles_exist');
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_EXT,
            x_perform_qa    => l_perform_articles_exist_qa,
            x_qa_name       => l_desc,
            x_severity_flag => l_severity,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


        IF (l_perform_articles_exist_qa <> 'Y') THEN
            RETURN;
        END IF;

        IF NOT do_validation(l_severity, p_doc_type) then
            -- validation is not required
            RETURN;
        END IF;

        IF (p_doc_type = 'TEMPLATE' AND l_article_tbl.COUNT = 0) then

            -- l_article_tbl is a global variable containing the template articles.
            -- indicates no clauses are present.
            l_indx := px_qa_result_tbl.COUNT + 1;

            px_qa_result_tbl(l_indx).error_record_type        := G_TMPL_QA_TYPE;
            px_qa_result_tbl(l_indx).article_id                := Null;
            px_qa_result_tbl(l_indx).deliverable_id            := Null;
            px_qa_result_tbl(l_indx).title                    := g_template_name;
            px_qa_result_tbl(l_indx).section_name            := Null;
            px_qa_result_tbl(l_indx).qa_code                := G_CHECK_ART_EXT;
            px_qa_result_tbl(l_indx).message_name            := G_OKC_CHECK_ART_EXT;
            px_qa_result_tbl(l_indx).suggestion                :=
                OKC_TERMS_UTIL_PVT.get_message(G_OKC,G_OKC_CHECK_ART_EXT_S);
            px_qa_result_tbl(l_indx).error_severity            := l_severity;
            px_qa_result_tbl(l_indx).problem_short_desc        := l_desc;
            px_qa_result_tbl(l_indx).problem_details_short    :=
                OKC_TERMS_UTIL_PVT.get_message(G_OKC, G_OKC_CHECK_ART_EXT_SH);
            px_qa_result_tbl(l_indx).problem_details        :=
                OKC_TERMS_UTIL_PVT.get_message(G_OKC, G_OKC_CHECK_ART_EXT);
        END IF;


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_articles_exist');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_articles_exist : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_articles_exist : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_articles_exist because of EXCEPTION: '||sqlerrm);
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_articles_exist;

    -------------------------------------------
    -- PROCEDURE check_validate_draft_articles
    -------------------------------------------
    /* check_validate_draft_articles gets all the draft versions
        in a template and validates them for errors.
    */
    PROCEDURE check_validate_draft_articles (
        p_doc_type         IN  VARCHAR2,
        p_doc_id           IN  NUMBER,
        px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
        x_return_status    OUT NOCOPY  VARCHAR2)
    IS

        /*
        TYPE draft_art_rec_type IS RECORD (
            article_id                    OKC_ARTICLES_ALL.ARTICLE_ID%TYPE,
            article_version_id            OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
            title                         OKC_QA_ERRORS_T.title%TYPE,
            section                       OKC_TMPL_DRAFT_CLAUSES.SECTION_NAME%TYPE
            );

        TYPE draft_art_tbl_type IS TABLE OF draft_art_rec_type INDEX BY BINARY_INTEGER;
        */

        TYPE art_id_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.ARTICLE_ID%TYPE INDEX BY BINARY_INTEGER;
        TYPE ver_id_tbl_type    IS TABLE of OKC_TMPL_DRAFT_CLAUSES.ARTICLE_VERSION_ID%TYPE INDEX BY BINARY_INTEGER;
        TYPE title_tbl_type     IS TABLE of OKC_ARTICLE_VERSIONS.DISPLAY_NAME%TYPE INDEX BY BINARY_INTEGER;
        TYPE sec_tbl_type       IS TABLE of OKC_TMPL_DRAFT_CLAUSES.SECTION_NAME%TYPE INDEX BY BINARY_INTEGER;

        l_api_name          CONSTANT VARCHAR2(30) := 'check_validate_draft_articles';
        l_indx              NUMBER;

        --l_draft_art_tbl             draft_art_tbl_type;

        l_draft_art_id_tbl          art_id_tbl_type;
        l_draft_ver_id_tbl          ver_id_tbl_type;
        l_draft_title_tbl           title_tbl_type;
        l_draft_sec_tbl             sec_tbl_type;

        l_art_ver_tbl               OKC_ART_BLK_PVT.NUM_TBL_TYPE;
        l_validation_results        OKC_ART_BLK_PVT.VALIDATION_TBL_TYPE;
        l_msg_count                 NUMBER;
        l_msg_data                  VARCHAR2(2000);
        l_qa_return_status          VARCHAR2(1);

        l_perform_qa_art_typ            VARCHAR2(1);
        l_severity_art_typ                OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc_art_typ                    OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;

        l_perform_qa_def_sec            VARCHAR2(1);
        l_severity_def_sec                OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc_def_sec                    OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;

        l_perform_qa_inv_var            VARCHAR2(1);
        l_severity_inv_var                OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc_inv_var                    OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;

        l_perform_qa_inv_val            VARCHAR2(1);
        l_severity_inv_val                OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
        l_desc_inv_val                    OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;

        l_title                            OKC_QA_ERRORS_T.TITLE%TYPE;
        l_section                        OKC_QA_ERRORS_T.SECTION_NAME%TYPE;

        CURSOR l_draft_art_csr IS
            SELECT DRA.article_id, DRA.article_version_id,
                --NVL(VER.display_name, ART.article_title) title, DRA.section_name section
                NVL(VER.display_name, ART.article_title) title,NVL(DRA.section_name, '*') section
            FROM OKC_TMPL_DRAFT_CLAUSES DRA,
                OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
            WHERE DRA.template_id = p_doc_id and
                DRA.selected_yn  = 'Y' and
                DRA.article_id = ART.article_id and
                VER.article_version_id  = DRA.article_version_id
                -- additional check to ensure that we are not checking some
                -- orphaned records in the OKC_TMPL_DRAFT_CLAUSES table
                AND EXISTS (SELECT '1' FROM OKC_K_ARTICLES_B KART WHERE
                                KART.document_type = p_doc_type AND
                                KART.document_id = p_doc_id AND
                                KART.sav_sae_id = DRA.article_id);

        PROCEDURE get_art_title_sec(
            p_art_id        IN NUMBER,
            x_title         OUT  NOCOPY VARCHAR2,
            x_section       OUT  NOCOPY VARCHAR2)
        IS
        BEGIN
            x_title := NULL;
            x_section := NULL;

            /*
            IF l_draft_art_tbl.COUNT > 0 THEN
                FOR i IN l_draft_art_tbl.FIRST..l_draft_art_tbl.LAST LOOP
                    IF (l_draft_art_tbl(i).article_id = p_art_id) THEN
                        x_title := l_draft_art_tbl(i).title;
                        x_section := l_draft_art_tbl(i).section;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

            */

            IF l_draft_art_id_tbl.COUNT > 0 THEN
                FOR i IN l_draft_art_id_tbl.FIRST..l_draft_art_id_tbl.LAST LOOP
                    IF (l_draft_art_id_tbl(i) = p_art_id) THEN
                        x_title := l_draft_title_tbl(i);
                        x_section := l_draft_sec_tbl(i);
                        EXIT;
                    END IF;
                END LOOP;
            END IF;

        END get_art_title_sec;

    BEGIN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_validate_draft_articles');
        END IF;

        IF (p_doc_type <> 'TEMPLATE') THEN
            RETURN; -- no other doc  type is supported.
        END IF;

	   -- Fix for the bug# 4448520, validate the template with Revision status
	   IF (g_status_code NOT in ('DRAFT', 'REJECTED', 'REVISION')) THEN
            RETURN; -- no article validation for other statuses.
        END IF;
--
-- muteshev
-- Insert records in OKC_TMPL_DRAFT_CLAUSES before validation
-- bug 4159533 start
    declare
        l_drafts_present varchar2(1);
        x_return_status varchar2(150);
        x_msg_data varchar2(2000);
        x_msg_count number;
    begin
            OKC_TERMS_UTIL_PVT.create_tmpl_clauses_to_submit  (
                p_api_version                  => 1,
                p_init_msg_list                => FND_API.G_FALSE,
                p_template_id                  => p_doc_id,
                p_org_id                       => g_org_id,
                x_drafts_present               => l_drafts_present,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data);
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
    end;
-- bug 4159533 end
-- the above code simulates template submittion else the below
-- l_draft_art_csr will never get any rows unless user submits template himself
-- (template submittion populates the OKC_TMPL_DRAFT_CLAUSES table)
--
        OPEN l_draft_art_csr;
        FETCH l_draft_art_csr BULK COLLECT INTO l_draft_art_id_tbl, l_draft_ver_id_tbl,
            l_draft_title_tbl, l_draft_sec_tbl;
        CLOSE l_draft_art_csr;

        --IF NOT (l_draft_art_tbl.COUNT > 0) THEN
        IF NOT (l_draft_art_id_tbl.COUNT > 0) THEN
            RETURN; -- no articles to validate
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_TYP,
            x_perform_qa    => l_perform_qa_art_typ,
            x_qa_name       => l_desc_art_typ,
            x_severity_flag => l_severity_art_typ,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_DEF_SEC,
            x_perform_qa    => l_perform_qa_def_sec,
            x_qa_name       => l_desc_def_sec,
            x_severity_flag => l_severity_def_sec,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_INV_VAR,
            x_perform_qa    => l_perform_qa_inv_var,
            x_qa_name       => l_desc_inv_var,
            x_severity_flag => l_severity_inv_var,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;

        get_qa_code_detail(p_qa_code       => G_CHECK_ART_INV_VAL,
            x_perform_qa    => l_perform_qa_inv_val,
            x_qa_name       => l_desc_inv_val,
            x_severity_flag => l_severity_inv_val,
            x_return_status => x_return_status);
        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


        l_art_ver_tbl := OKC_ART_BLK_PVT.NUM_TBL_TYPE();
        --FOR i in 1..l_draft_art_tbl.COUNT LOOP
        FOR i in 1..l_draft_art_id_tbl.COUNT LOOP
            l_art_ver_tbl.EXTEND;
            --l_art_ver_tbl(i) := l_draft_art_tbl(i).article_version_id;
            l_art_ver_tbl(i) := l_draft_ver_id_tbl(i);
        END LOOP;

        -- Call the bulk validate api which does the actual validation,
        -- if the appropriate flags are set.
        IF ((l_perform_qa_art_typ ='Y' AND do_validation(l_severity_art_typ, p_doc_type)) OR
            (l_perform_qa_def_sec ='Y' AND do_validation(l_severity_def_sec, p_doc_type)) OR
            (l_perform_qa_inv_var ='Y' AND do_validation(l_severity_inv_var, p_doc_type)) OR
            (l_perform_qa_inv_val ='Y' AND do_validation(l_severity_inv_val, p_doc_type))
            ) THEN

            OKC_ART_BLK_PVT.validate_article_versions_blk(
                p_api_version            => 1.0 ,
                p_init_msg_list            => FND_API.G_FALSE,
                p_commit                => FND_API.G_FALSE,
                p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                x_return_status            => x_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                => l_msg_data,
                p_org_id                => g_org_id,
                p_art_ver_tbl            => l_art_ver_tbl,
                x_qa_return_status      => l_qa_return_status,
                x_validation_results    => l_validation_results
                );
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

        ELSE
            -- nothing to validate
            RETURN;
        END IF;

-- Bug#4086586: Removed Switch/Case stetments as this does not work on 8.1.7.4.

        IF(l_validation_results.COUNT > 0) THEN
            -- some validation errors where found, populate the px_qa_result_tbl with appropriate values.
            FOR i in 1..l_validation_results.COUNT LOOP

--                CASE (l_validation_results(i).error_code)
--                    WHEN (G_CHECK_ART_TYP) THEN
                IF (l_validation_results(i).error_code) = (G_CHECK_ART_TYP) THEN

                        -- insert into px_qa_result_tbl only if the appropriate validation level is set
                        IF (l_perform_qa_art_typ ='Y' AND
                            do_validation(l_severity_art_typ, p_doc_type) )THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;
                            px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id   := l_validation_results(i).article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;

                            get_art_title_sec(
                                p_art_id        => l_validation_results(i).article_id,
                                x_title            =>l_title,
                                x_section        =>l_section);

                            px_qa_result_tbl(l_indx).title            := l_title;
                            px_qa_result_tbl(l_indx).section_name    := l_section;
                            px_qa_result_tbl(l_indx).qa_code        := l_validation_results(i).error_code;

                            px_qa_result_tbl(l_indx).message_name := G_OKC_CHECK_ART_TYP;
                            px_qa_result_tbl(l_indx).suggestion :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_TYP_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_severity_art_typ;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc_art_typ;
                            px_qa_result_tbl(l_indx).problem_details_short   :=
                                --OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_TYP_SH);
                                -- use same as problem_details
                                l_validation_results(i).error_message;
                            px_qa_result_tbl(l_indx).problem_details  :=
                                l_validation_results(i).error_message;
                        END IF;

--                    WHEN (G_CHECK_ART_DEF_SEC) THEN

                ELSIF (l_validation_results(i).error_code) = (G_CHECK_ART_DEF_SEC) THEN
                        -- insert into px_qa_result_tbl only if the appropriate validation level is set
                        IF (l_perform_qa_def_sec ='Y' AND
                            do_validation(l_severity_def_sec, p_doc_type) )THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;
                            px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id   := l_validation_results(i).article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;

                            get_art_title_sec(
                                p_art_id        => l_validation_results(i).article_id,
                                x_title            =>l_title,
                                x_section        =>l_section);

                            px_qa_result_tbl(l_indx).title            := l_title;
                            px_qa_result_tbl(l_indx).section_name    := l_section;
                            px_qa_result_tbl(l_indx).qa_code        := l_validation_results(i).error_code;

                            px_qa_result_tbl(l_indx).message_name := G_OKC_CHECK_ART_DEF_SEC;
                            px_qa_result_tbl(l_indx).suggestion :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_DEF_SEC_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_severity_def_sec;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc_def_sec;
                            px_qa_result_tbl(l_indx).problem_details_short   :=
                                --OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_DEF_SEC_SH);
                                -- use same as problem_details
                                l_validation_results(i).error_message;
                            px_qa_result_tbl(l_indx).problem_details  :=
                                l_validation_results(i).error_message;
                        END IF;
--                    WHEN (G_CHECK_ART_INV_VAR) THEN
                ELSIF (l_validation_results(i).error_code) = (G_CHECK_ART_INV_VAR) THEN

                        -- insert into px_qa_result_tbl only if the appropriate validation level is set
                        IF (l_perform_qa_inv_var ='Y' AND
                            do_validation(l_severity_inv_var, p_doc_type) )THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;
                            px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id   := l_validation_results(i).article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;

                            get_art_title_sec(
                                p_art_id        => l_validation_results(i).article_id,
                                x_title            =>l_title,
                                x_section        =>l_section);

                            px_qa_result_tbl(l_indx).title            := l_title;
                            px_qa_result_tbl(l_indx).section_name    := l_section;
                            px_qa_result_tbl(l_indx).qa_code        := l_validation_results(i).error_code;

                            px_qa_result_tbl(l_indx).message_name := G_OKC_CHECK_ART_INV_VAR;
                            px_qa_result_tbl(l_indx).suggestion :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_INV_VAR_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_severity_inv_var;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc_inv_var;
                            px_qa_result_tbl(l_indx).problem_details_short   :=
                                --OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_INV_VAR_SH);
                                -- use same as problem_details
                                l_validation_results(i).error_message;
                            px_qa_result_tbl(l_indx).problem_details  :=
                                l_validation_results(i).error_message;
                        END IF;

--                    WHEN (G_CHECK_ART_INV_VAL) THEN
                ELSIF (l_validation_results(i).error_code) = (G_CHECK_ART_INV_VAL) THEN

                        -- insert into px_qa_result_tbl only if the appropriate validation level is set
                        IF (l_perform_qa_inv_val ='Y' AND
                            do_validation(l_severity_inv_val, p_doc_type) )THEN

                            l_indx := px_qa_result_tbl.COUNT + 1;
                            px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                            px_qa_result_tbl(l_indx).article_id   := l_validation_results(i).article_id;
                            px_qa_result_tbl(l_indx).deliverable_id      := Null;

                            get_art_title_sec(
                                p_art_id        => l_validation_results(i).article_id,
                                x_title            =>l_title,
                                x_section        =>l_section);

                            px_qa_result_tbl(l_indx).title            := l_title;
                            px_qa_result_tbl(l_indx).section_name    := l_section;
                            px_qa_result_tbl(l_indx).qa_code        := l_validation_results(i).error_code;

                            px_qa_result_tbl(l_indx).message_name := G_OKC_CHECK_ART_INV_VAL;
                            px_qa_result_tbl(l_indx).suggestion :=
                                OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_INV_VAL_S);
                            px_qa_result_tbl(l_indx).error_severity      := l_severity_inv_val;
                            px_qa_result_tbl(l_indx).problem_short_desc  := l_desc_inv_val;
                            px_qa_result_tbl(l_indx).problem_details_short   :=
                                --OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_INV_VAL_SH);
                                -- use same as problem_details
                                l_validation_results(i).error_message;
                            px_qa_result_tbl(l_indx).problem_details  :=
                                l_validation_results(i).error_message;
                        END IF;

                    ELSE
                        -- all other errors are treated as error conditions
                        l_indx := px_qa_result_tbl.COUNT + 1;
                        px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
                        px_qa_result_tbl(l_indx).article_id   := l_validation_results(i).article_id;
                        px_qa_result_tbl(l_indx).deliverable_id      := Null;

                        get_art_title_sec(
                            p_art_id        => l_validation_results(i).article_id,
                            x_title            =>l_title,
                            x_section        =>l_section);

                        px_qa_result_tbl(l_indx).title            := l_title;
                        px_qa_result_tbl(l_indx).section_name    := l_section;
                        px_qa_result_tbl(l_indx).qa_code        := l_validation_results(i).error_code;

                        px_qa_result_tbl(l_indx).message_name := Null;
                        px_qa_result_tbl(l_indx).suggestion := Null;
                        px_qa_result_tbl(l_indx).error_severity      := G_QA_STS_ERROR;
                        px_qa_result_tbl(l_indx).problem_short_desc  := Null;
                        px_qa_result_tbl(l_indx).problem_details_short   := Null;
                        px_qa_result_tbl(l_indx).problem_details  :=
                            l_validation_results(i).error_message;
                  END IF;
--                END CASE;
            END LOOP;
        END IF;


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_validate_draft_articles');
        END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_validate_draft_articles : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_draft_art_csr%ISOPEN THEN
                CLOSE l_draft_art_csr;
            END IF;

            x_return_status := G_RET_STS_ERROR ;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_validate_draft_articles : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;

            IF l_draft_art_csr%ISOPEN THEN
                CLOSE l_draft_art_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_validate_draft_articles because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_draft_art_csr%ISOPEN THEN
                CLOSE l_draft_art_csr;
            END IF;

            x_return_status := G_RET_STS_UNEXP_ERROR ;

    END check_validate_draft_articles;


	 -- For Bug# 6979012
 	                 -------------------------------------------
 	              -- PROCEDURE check_rejected_clauses
 	              -------------------------------------------
 	              /* check_rejected_clauses checks for rejected clauses added to the template and
 	                 displays a warning for each one of them */
 	              PROCEDURE check_rejected_clauses (
 	                  p_doc_type         IN  VARCHAR2,
 	                  p_doc_id           IN  NUMBER,
 	                  px_qa_result_tbl   IN OUT NOCOPY qa_result_tbl_type,
 	                  x_return_status    OUT NOCOPY  VARCHAR2)
 	              IS
 	                  l_api_name          CONSTANT VARCHAR2(30) := 'check_rejected_clauses';
 	                  l_indx              NUMBER;
 	                  l_severity          OKC_QA_ERRORS_T.ERROR_SEVERITY%TYPE;
 	                  l_desc              OKC_QA_ERRORS_T.PROBLEM_SHORT_DESC%TYPE;
 	                  l_perform_articles_exist_qa        VARCHAR2(1);

 	                      CURSOR l_rejected_art_csr IS
 	                      SELECT DRA.article_id article_id, DRA.article_version_id,
 	                          --NVL(VER.display_name, ART.article_title) title, DRA.section_name section
 	                          NVL(VER.display_name, ART.article_title) title,NVL(DRA.section_name, '*') section
 	                      FROM OKC_TMPL_DRAFT_CLAUSES DRA,
 	                          OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
 	                      WHERE DRA.template_id = p_doc_id and
 	                          DRA.selected_yn  = 'Y' and
 	                          DRA.article_id = ART.article_id and
 	                          VER.article_version_id  = DRA.article_version_id
 	                          -- additional check to ensure that we are not checking some
 	                          -- orphaned records in the OKC_TMPL_DRAFT_CLAUSES table
 	                          AND EXISTS (SELECT '1' FROM OKC_K_ARTICLES_B KART WHERE
 	                                          KART.document_type = p_doc_type AND
 	                                          KART.document_id = p_doc_id AND
 	                                          KART.sav_sae_id = DRA.article_id)
 	                          AND VER.article_status='REJECTED';

 	              BEGIN

 	                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1500: Entered check_rejected_clauses');
 	                  END IF;

 	                  IF (p_doc_type <> 'TEMPLATE') THEN
 	                      RETURN; -- no other doc  type is supported.
 	                  END IF;

 	                  IF (g_status_code NOT in ('DRAFT', 'REJECTED')) THEN
 	                      RETURN; -- no article validation for other statuses.
 	                  END IF;

 	                 get_qa_code_detail(p_qa_code       => G_CHECK_ART_REJECTED,
 	                      x_perform_qa    => l_perform_articles_exist_qa,
 	                      x_qa_name       => l_desc,
 	                      x_severity_flag => l_severity,
 	                      x_return_status => x_return_status);
 	                  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
 	                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
 	                  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
 	                      RAISE FND_API.G_EXC_ERROR ;
 	                  END IF;


 	                  IF (l_perform_articles_exist_qa <> 'Y') THEN
 	                      RETURN;
 	                  END IF;

 	                  IF NOT do_validation(l_severity, p_doc_type) then
 	                      -- validation is not required
 	                      RETURN;
 	                  END IF;

 	                  FOR l_rejected_art in l_rejected_art_csr LOOP
 	                       l_indx := px_qa_result_tbl.COUNT + 1;
 	                                      px_qa_result_tbl(l_indx).error_record_type   := G_ART_QA_TYPE;
 	                                      px_qa_result_tbl(l_indx).article_id   := l_rejected_art.article_id;
 	                                      px_qa_result_tbl(l_indx).deliverable_id      := Null;
 	                                      px_qa_result_tbl(l_indx).title            := l_rejected_art.title;
 	                                      px_qa_result_tbl(l_indx).section_name    := l_rejected_art.section;
 	                                      px_qa_result_tbl(l_indx).qa_code        := G_CHECK_ART_REJECTED;
 	                                      px_qa_result_tbl(l_indx).message_name := G_OKC_CHECK_ART_REJECTED;
 	                                      px_qa_result_tbl(l_indx).suggestion :=OKC_TERMS_UTIL_PVT.Get_Message(G_OKC,G_OKC_CHECK_ART_REJECTED_S);
 	                                      px_qa_result_tbl(l_indx).error_severity      := l_severity;
 	                                      px_qa_result_tbl(l_indx).problem_short_desc  := l_desc;
 	                                      px_qa_result_tbl(l_indx).problem_details_short   :=OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_REJECTED);
 	                                      px_qa_result_tbl(l_indx).problem_details  :=OKC_TERMS_UTIL_PVT.Get_Message(G_OKC, G_OKC_CHECK_ART_REJECTED);
 	                  END LOOP;
 	                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: Leaving check_rejected_clauses');
 	                  END IF;

 	              EXCEPTION
 	                  WHEN FND_API.G_EXC_ERROR THEN
 	                      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7800: Leaving check_rejected_clauses : OKC_API.G_EXCEPTION_ERROR Exception');
 	                      END IF;

 	                      IF l_rejected_art_csr%ISOPEN THEN
 	                          CLOSE l_rejected_art_csr;
 	                      END IF;

 	                      x_return_status := G_RET_STS_ERROR ;

 	                  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 	                      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'7900: Leaving check_rejected_clauses : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
 	                      END IF;

 	                      IF l_rejected_art_csr%ISOPEN THEN
 	                          CLOSE l_rejected_art_csr;
 	                      END IF;

 	                      x_return_status := G_RET_STS_UNEXP_ERROR ;

 	                  WHEN OTHERS THEN
 	                      IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'8000: Leaving check_rejected_clauses because of EXCEPTION: '||sqlerrm);
 	                      END IF;

 	                      IF l_rejected_art_csr%ISOPEN THEN
 	                          CLOSE l_rejected_art_csr;
 	                      END IF;

 	                      x_return_status := G_RET_STS_UNEXP_ERROR ;

 	              END check_rejected_clauses;
 	 -- Changes for Bug# 6979012 Ends


-->>>>>>>>>>>>>>>>>> INTERNAL QA Check API PROCEDURES  >>>>>>>>>>>>>>>>>>

    ------------------------------------------------------------
    -- PROCEDURE QA_DOC main api for validating the documents
    ------------------------------------------------------------

    /* 11.5.10+ modified to accept additional in parameter p_validation_level
        p_validation_level  'A' do all qa checks
        p_validation_level  'E' do only error checks
                            applies only to p_doc_type='TEMPLATE'
    */
    PROCEDURE QA_DOC(
        p_qa_mode            IN  VARCHAR2,
        p_doc_type            IN  VARCHAR2,
        p_doc_id            IN  NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        x_sequence_id        OUT NOCOPY NUMBER,
        x_qa_result_tbl        OUT NOCOPY qa_result_tbl_type,
        x_qa_return_status    OUT NOCOPY VARCHAR2,
        p_validation_level    IN VARCHAR2,
	   p_run_expert_flag     IN VARCHAR2 DEFAULT 'Y') -- Bug 5186245
    IS

        l_api_name                CONSTANT VARCHAR2(30) := 'QA_Doc';
        l_now                    DATE;
        i                        NUMBER := 0;
        q                        NUMBER := 0;
        l_error_found            Boolean := FALSE;
        l_warning_found            Boolean := FALSE;
        l_expert_articles_tbl    OKC_XPRT_UTIL_PVT.expert_articles_tbl_type;
        l_perform_qa            BOOLEAN := TRUE;

        CURSOR l_get_qa_detail_csr IS
            SELECT fnd.lookup_code qa_code,
                fnd.meaning qa_name,
                nvl(qa.severity_flag,G_QA_STS_WARNING) severity_flag ,
                decode(fnd.enabled_flag,'N','N','Y',decode(qa.enable_qa_yn,'N','N','Y'),'Y') perform_qa
            FROM FND_LOOKUPS FND, OKC_DOC_QA_LISTS QA
            WHERE QA.DOCUMENT_TYPE(+)=p_doc_type
                AND   QA.QA_CODE(+) = FND.LOOKUP_CODE
                AND   Fnd.LOOKUP_TYPE=G_QA_LOOKUP;

        CURSOR l_get_doc_articles_csr IS
            SELECT KART.ID                                   ID,
                KART.SAV_SAE_ID                              ARTICLE_ID,
                KART.ARTICLE_VERSION_ID                      ARTICLE_VERSION_ID,
                KART.AMENDMENT_OPERATION_CODE                AMENDMENT_OPERATION_CODE,
                KART.AMENDMENT_DESCRIPTION                   AMENDMENT_DESCRIPTION,
                KART.SCN_ID                                  SCN_ID,
                OKC_TERMS_UTIL_PVT.get_article_name(KART.SAV_SAE_ID ,KART.ARTICLE_VERSION_ID) TITLE,
                Decode(ART.standard_yn,'N',KART.ref_article_id,NULL) STD_ART_ID
            FROM OKC_K_ARTICLES_B KART,
                OKC_ARTICLES_ALL ART,
                OKC_ARTICLE_VERSIONS VERS
            WHERE KART.DOCUMENT_TYPE      = p_doc_type
                AND   KART.DOCUMENT_ID        = p_doc_id
                AND   KART.ARTICLE_VERSION_ID = VERS.ARTICLE_VERSION_ID
                AND   KART.SAV_SAE_ID         = ART.ARTICLE_ID;

        /* modified in 11.5.10+
        CURSOR l_get_tmpl_articles_csr IS
            SELECT KART.ID                                      ID,
                KART.SAV_SAE_ID                              ARTICLE_ID,
                STD.ARTICLE_ID                               STD_ART_ID,
                KART.ARTICLE_VERSION_ID                      ARTICLE_VERSION_ID,
                KART.AMENDMENT_OPERATION_CODE                AMENDMENT_OPERATION_CODE,
                KART.AMENDMENT_DESCRIPTION                   AMENDMENT_DESCRIPTION,
                KART.SCN_ID                                  SCN_ID,
                OKC_TERMS_UTIL_PVT.get_article_name(KART.SAV_SAE_ID ,VERS.ARTICLE_VERSION_ID) TITLE
            FROM OKC_K_ARTICLES_B KART, OKC_ARTICLE_VERSIONS VERS, OKC_ARTICLE_VERSIONS STD
                WHERE KART.DOCUMENT_TYPE      = p_doc_type
                AND   KART.DOCUMENT_ID        = p_doc_id
                AND   STD.ARTICLE_VERSION_ID(+) = VERS.STD_ARTICLE_VERSION_ID
                AND   KART.SAV_SAE_ID         = VERS.ARTICLE_ID
                AND   nvl(VERS.START_DATE,sysdate) = ( SELECT nvl(MAX(START_DATE),sysdate)
                    FROM OKC_ARTICLE_VERSIONS
                    WHERE ARTICLE_ID=VERS.ARTICLE_ID);
    */

        -- 11.5.10+ modified cursor to get the version from OKC_TERMS_UTIL_PVT.get_latest_tmpl_art_version_id
        CURSOR l_get_tmpl_articles_csr IS
            SELECT KART.ID                                      ID,
                KART.SAV_SAE_ID                              ARTICLE_ID,
                STD.ARTICLE_ID                               STD_ART_ID,
                KART.ARTICLE_VERSION_ID                      ARTICLE_VERSION_ID,
                KART.AMENDMENT_OPERATION_CODE                AMENDMENT_OPERATION_CODE,
                KART.AMENDMENT_DESCRIPTION                   AMENDMENT_DESCRIPTION,
                KART.SCN_ID                                  SCN_ID,
                OKC_TERMS_UTIL_PVT.get_article_name(KART.SAV_SAE_ID ,VERS.ARTICLE_VERSION_ID) TITLE
            FROM OKC_K_ARTICLES_B KART, OKC_ARTICLE_VERSIONS VERS, OKC_ARTICLE_VERSIONS STD
            WHERE KART.DOCUMENT_TYPE      = p_doc_type
                AND   KART.DOCUMENT_ID        = p_doc_id
                AND   STD.ARTICLE_VERSION_ID(+) = VERS.STD_ARTICLE_VERSION_ID
                AND   KART.SAV_SAE_ID         = VERS.ARTICLE_ID
                AND   VERS.ARTICLE_VERSION_ID = OKC_TERMS_UTIL_PVT.get_latest_tmpl_art_version_id(
                    KART.sav_sae_id,
                    g_start_date,
                    g_end_date,
                    g_status_code,
                    p_doc_type,
                    p_doc_id
                    );

        /* expert commented out
        -- new cursor to fetch the expert articles and their details
        CURSOR l_get_xprt_articles_csr IS
            SELECT XPRT.clause_id                        article_id,
            ver.article_version_id                        article_version_id,
            Nvl(ver.display_name, art.article_title)    title,
            xprt.rule_id                                rule_id,
            xprt.rule_name                                rule_name
            FROM OKC_XPRT_CLAUSES_V XPRT,
                OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
            WHERE XPRT.template_id = p_doc_id
            AND ART.article_id = XPRT.clause_id
            AND VER.article_id = ART.article_id
            AND VER.article_version_id = OKC_TERMS_UTIL_PVT.get_latest_tmpl_art_version_id(
                ART.article_id,
                g_start_date,
                g_end_date,
                g_status_code,
                p_doc_type,
                p_doc_id
                );
        */

        CURSOR l_get_sections_csr IS
            SELECT ID                                      ID,
                AMENDMENT_OPERATION_CODE                AMENDMENT_OPERATION_CODE,
                AMENDMENT_DESCRIPTION                   AMENDMENT_DESCRIPTION,
                SCN_ID                                  SCN_ID,
                SCN_CODE                                SCN_CODE,
                DECODE(LABEL,NULL,HEADING,
                okc_terms_util_pvt.get_message('OKC',
                'OKC_TERMS_LABEL_AND_NAME',
                'LABEL', LABEL,
                'NAME', HEADING))  HEADING
            FROM OKC_SECTIONS_B
            WHERE DOCUMENT_TYPE      = p_doc_type
                AND   DOCUMENT_ID        = p_doc_id;

        CURSOR l_get_effective_date IS
            SELECT nvl(ARTICLE_EFFECTIVE_DATE ,sysdate)
            FROM OKC_TEMPLATE_USAGES
            WHERE DOCUMENT_TYPE=p_doc_type
                AND   DOCUMENT_ID=p_doc_id;

        /* Modified in 11.5.10+ to get additonal template information
        CURSOR l_get_effective_date_template IS
            SELECT start_date, end_date
            FROM okc_terms_templates_all
            WHERE template_id = p_doc_id;
        */

        -- 11.5.10+ modified cursor to get additional template details
        CURSOR l_get_effective_date_template IS
            SELECT start_date, end_date,
                nvl(contract_expert_enabled, 'N'), nvl(status_code, 'DRAFT'),
                template_name,org_id
            FROM okc_terms_templates_all
            WHERE template_id = p_doc_id;

        /* 11.5.10+ replace with global variables
        l_start_date DATE;
        l_end_date   DATE;
        */

    BEGIN
        g_validation_level :='A';
        g_expert_enabled   :='N';
-- because of GSCC warnings the default values are removed
-- but it's not allowed to assign something to IN parameters
-- don't think it's good idea to remove default values
-- it can cause regression
--        if p_qa_mode is null then p_qa_mode := G_NORMAL_QA; end if;
--        if p_validation_level is null then p_validation_level := 'A'; end if;
        l_now := SYSDATE;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2100: Entered QA_Doc');
        END IF;
        --  Initialize API return status to success
        x_return_status    := G_RET_STS_SUCCESS;
        x_qa_return_status := G_QA_STS_SUCCESS;
        g_validation_level := p_validation_level;

        IF p_doc_type = G_TMPL_DOC_TYPE THEN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2110: Opening cursor l_get_effective_date_template');
            END IF;
            OPEN l_get_effective_date_template;
                --FETCH l_get_effective_date_template INTO l_start_date, l_end_date;
                FETCH l_get_effective_date_template INTO g_start_date, g_end_date,
                    g_expert_enabled, g_status_code, g_template_name, g_org_id;
                IF l_get_effective_date_template%NOTFOUND THEN
                    l_perform_qa := FALSE;
                END IF;
            CLOSE l_get_effective_date_template;

            IF NVL(g_end_date,sysdate) >= sysdate  THEN
                IF g_start_date > sysdate THEN
                    l_article_effective_date := g_start_date;
                ELSE
                    l_article_effective_date := sysdate;
                END IF;
            ELSE
                l_article_effective_date := g_end_date;
            END IF;

        ELSE
            -- doc type not Template
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2120: Opening cursor l_get_effective_date');
            END IF;
            OPEN  l_get_effective_date;
            FETCH l_get_effective_date INTO l_article_effective_date;
            IF l_get_effective_date%NOTFOUND THEN
                l_perform_qa := FALSE;
            END IF;
            CLOSE l_get_effective_date;
        END IF;

        IF l_perform_QA then

            -- Reset PL/SQl Tables
            x_qa_result_tbl.DELETE;
            l_article_tbl.DELETE;
            l_section_tbl.DELETE;
            l_qa_detail_tbl.DELETE;

            /* expert commented out
            l_xprt_article_tbl.DELETE;
            */

            -- Get all QA Detail
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2130: Before FOR cr IN l_get_qa_detail_csr LOOP');
            END IF;
            q := 0;
            FOR cr IN l_get_qa_detail_csr LOOP

                l_qa_detail_tbl(q).qa_code := cr.qa_code;
                l_qa_detail_tbl(q).qa_name := cr.qa_name;
                l_qa_detail_tbl(q).severity_flag :=cr.severity_flag;
                l_qa_detail_tbl(q).perform_qa :=cr.perform_qa;

                IF  (l_qa_detail_tbl(q).qa_code = G_CHECK_ART_EXT) THEN

                -- Modify the severity level of the qa check for existence of clauses
                -- to 'W' (warning) if the template is expert enabled. It is 'E' otherwise.
                    IF (g_expert_enabled = 'Y') THEN
                        l_qa_detail_tbl(q).severity_flag := G_QA_STS_WARNING;
                    END IF;

                -- bug 4083727 - muteshev - start
                -- Modify the severity level of the qa check for existence of clauses
                -- to 'W' (warning) if the template contains deliverables. It is 'E' otherwise.
                    if okc_terms_util_grp.Is_Deliverable_Exist(
                                                p_api_version      => 1,
                                                p_init_msg_list    => FND_API.G_FALSE,
                                                x_return_status    => x_return_status,
                                                x_msg_data         => x_msg_data,
                                                x_msg_count        => x_msg_count,
                                                p_doc_type         => 'TEMPLATE',
                                                p_doc_id           => p_doc_id
                                            ) is not null then
                        l_qa_detail_tbl(q).severity_flag := G_QA_STS_WARNING;
                    end if;
                -- bug 4083727 - muteshev - end

                END IF;
                q := q +1;
            END LOOP;


            -- populate l_article_tbl with all the articles.
            IF p_doc_type <> G_TMPL_DOC_TYPE THEN
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2140: Before FOR cr IN l_get_doc_articles_csr LOOP');
                END IF;
                i := 0;
                FOR cr IN l_get_doc_articles_csr LOOP
                    i := i+1;
                    l_article_tbl(i).id                       := cr.id;
                    l_article_tbl(i).article_id               := cr.article_id;
                    l_article_tbl(i).std_art_id               := cr.std_art_id;
                    l_article_tbl(i).article_version_id       := cr.article_version_id;
                    l_article_tbl(i).amendment_operation_code := cr.amendment_operation_code;
                    l_article_tbl(i).amendment_description    := cr.amendment_description;
                    l_article_tbl(i).scn_id                   := cr.scn_id;
                    l_article_tbl(i).title                    := cr.title;
                END LOOP;
            ELSE
                -- doc type is TEMPLATE, if expert enabled get the expert clauses
                /* expert commented out
                IF (g_expert_enabled = 'Y') then
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2150: Before OPEN l_get_xprt_articles_csr');
                    END IF;
                    OPEN l_get_xprt_articles_csr;
                    FETCH l_get_xprt_articles_csr BULK COLLECT INTO l_xprt_article_tbl;
                    CLOSE l_get_xprt_articles_csr;
                END IF;
                */

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2160: Before FOR cr IN l_get_tmpl_articles_csr');
                END IF;
                i := 0;
                FOR cr IN l_get_tmpl_articles_csr LOOP
                    i := i+1;
                    l_article_tbl(i).id                       := cr.id;
                    l_article_tbl(i).article_id               := cr.article_id;
                    l_article_tbl(i).std_art_id               := cr.std_art_id;
                    l_article_tbl(i).article_version_id       := cr.article_version_id;
                    l_article_tbl(i).amendment_operation_code := cr.amendment_operation_code;
                    l_article_tbl(i).amendment_description    := cr.amendment_description;
                    l_article_tbl(i).scn_id                   := cr.scn_id;
                    l_article_tbl(i).title                    := cr.title;
                END LOOP;
            END IF;

            -- populate l_section_tbl with all the sections.
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2170: Before FOR cr IN l_get_sections_csr LOOP');
                END IF;
            i := 0;
            FOR cr IN l_get_sections_csr LOOP
                i := i+1;
                l_section_tbl(i).id                       := cr.id;
                l_section_tbl(i).amendment_operation_code := cr.amendment_operation_code;
                l_section_tbl(i).amendment_description    := cr.amendment_description;
                l_section_tbl(i).scn_id                   := cr.scn_id;
                l_section_tbl(i).heading                  := cr.heading;
                l_section_tbl(i).scn_code                 := cr.scn_code;
            END LOOP;

            --****************************************--
            --        Run set of validation           --
            --****************************************--

            ------------------------------------------------------------
            -- QA Check for Layout Template to be run for templates ONLY
            ------------------------------------------------------------
            IF p_doc_type=G_TMPL_DOC_TYPE THEN
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2180: calling check_layout_template');
                END IF;
                check_layout_template(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                --call new internal procedure to check for article existence
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2190: calling check_articles_exist');
                END IF;
                check_articles_exist (
                    p_doc_type            =>    p_doc_type,
                    p_doc_id            =>    p_doc_id,
                    px_qa_result_tbl    =>    x_qa_result_tbl,
                    x_return_status        =>    x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                --call new internal procedure to validate any draft articles
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: calling check_validate_draft_articles');
                END IF;
                check_validate_draft_articles(
                    p_doc_type            =>    p_doc_type,
                    p_doc_id            =>    p_doc_id,
                    px_qa_result_tbl    =>    x_qa_result_tbl,
                    x_return_status        =>    x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

 	 -- For Bug# 6979012
 	                     --call new internal procedure to give a warning for rejected articles
 	                          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 	                              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2200: calling check_rejected_clauses');
 	                          END IF;
 	                          check_rejected_clauses(
 	                              p_doc_type            =>    p_doc_type,
 	                              p_doc_id            =>    p_doc_id,
 	                              px_qa_result_tbl    =>    x_qa_result_tbl,
 	                              x_return_status        =>    x_return_status
 	                              );
 	                          IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
 	                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
 	                          ELSIF (x_return_status = G_RET_STS_ERROR) THEN
 	                              RAISE FND_API.G_EXC_ERROR ;
 	                          END IF;
 	 -- Changes for Bug# 6979012 Ends

--MLS for templates
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2202: calling Check_translated_tmpl_revision');
                END IF;
                Check_translated_tmpl_rev(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2205: calling Check_translated_tmpl_effectivity');
                END IF;
                Check_translated_tmpl_eff(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;
--MLS for templates


            END IF; -- p_doc_type=G_TMPL_DOC_TYPE


            --------------------------------------------
            -- QA Check for Incompatible articles
            --------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2210: calling check_validate_draft_articles');
            END IF;
            Check_Incomp_and_alternate(
                p_qa_mode          => p_qa_mode,
                p_doc_type         => p_doc_type,
                p_doc_id           => p_doc_id,
                px_qa_result_tbl   => x_qa_result_tbl,
                x_return_status    => x_return_status
                );
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            --------------------------------------------
            -- QA Check for Duplicate articles
            --------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2220: calling Check_duplicate_articles');
            END IF;
            Check_duplicate_articles(
                p_qa_mode          => p_qa_mode,
                p_doc_type         => p_doc_type,
                p_doc_id           => p_doc_id,
                px_qa_result_tbl   => x_qa_result_tbl,
                x_return_status    => x_return_status
                );
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            --------------------------------------------
            -- QA Check for variable-doc type usage
            --------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2230: calling Check_var_doc_type_usage');
            END IF;
            Check_var_doc_type_usage(
                p_qa_mode          => p_qa_mode,
                p_doc_type         => p_doc_type,
                p_doc_id           => p_doc_id,
                px_qa_result_tbl   => x_qa_result_tbl,
                x_return_status    => x_return_status
                );
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            ----------------------------------------------------------------
            -- QA Check for article effectivity and old version of article
            ----------------------------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2240: calling Check_art_effectivity');
            END IF;
            Check_art_effectivity(
                p_qa_mode          => p_qa_mode,
                p_doc_type         => p_doc_type,
                p_doc_id           => p_doc_id,
                px_qa_result_tbl   => x_qa_result_tbl,
                x_return_status    => x_return_status
                );
            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;


            -----------------------------------------------------------------------
            -- QA Check for non-entered user variables(Both External and Internal)
            -----------------------------------------------------------------------
            IF p_doc_type <>G_TMPL_DOC_TYPE THEN

                --------------------------------------------
                -- QA Check for User  Variables
                --------------------------------------------
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2250: calling Check_variables');
                END IF;
                Check_variables(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                ---------------------------------------------------------
                -- QA Check for unassigned articles
                ---------------------------------------------------------
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2260: calling Check_unassigned_articles');
                END IF;
                Check_unassigned_articles(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                ---------------------------------------------------------------
                -- QA Check for empty sections
                ---------------------------------------------------------------
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2270: calling Check_empty_sections');
                END IF;
                Check_empty_sections(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                ---------------------------------------------------------------
                -- QA Check for inactive template
                ---------------------------------------------------------------
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2280: calling check_inactive_template');
                END IF;
                check_inactive_template(
                    p_doc_type         => p_doc_type,
                    p_doc_id           => p_doc_id,
                    px_qa_result_tbl   => x_qa_result_tbl,
                    x_return_status    => x_return_status
                    );
                IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR ;
                END IF;

                IF  p_qa_mode = G_AMEND_QA THEN

                    ------------------------------------------------------------
                    -- QA Check for Amended article with no description
                    ------------------------------------------------------------
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2290: calling Check_article_Amend_No_Texts');
                    END IF;
                    Check_article_Amend_No_Texts(
                        p_doc_type         => p_doc_type,
                        p_doc_id           => p_doc_id,
                        px_qa_result_tbl   => x_qa_result_tbl,
                        x_return_status    => x_return_status
                        );
                    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;

                    ------------------------------------------------------------
                    -- QA Check for Amended section with no description
                    ------------------------------------------------------------
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: calling Check_Section_Amend_No_Texts');
                    END IF;
                    Check_Section_Amend_No_Texts(
                        p_doc_type         => p_doc_type,
                        p_doc_id           => p_doc_id,
                        px_qa_result_tbl   => x_qa_result_tbl,
                        x_return_status    => x_return_status
                        );
                    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
                    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                        RAISE FND_API.G_EXC_ERROR ;
                    END IF;

                END IF;    -- IF  p_qa_mode = G_AMEND_QA THEN

            END IF;    -- IF p_doc_type <>G_TMPL_DOC_TYPE THEN

            ------------------------------------------------------------
            -- QA Check for expert
            ------------------------------------------------------------
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2310: calling OKC_EXPRT_UTIL_GRP.contract_expert_bv');
            END IF;

            IF p_doc_type = G_TMPL_DOC_TYPE THEN
--Added 11.5.10+ CE
             OKC_XPRT_UTIL_PVT.validate_template_for_expert (
                p_api_version         => 1,
                p_init_msg_list       => FND_API.G_FALSE,
                p_template_id         => p_doc_id,
                x_msg_data            => x_msg_data,
                x_msg_count           => x_msg_count,
                x_qa_result_tbl       => x_qa_result_tbl,
                x_return_status       => x_return_status);

            ELSE
		     IF p_run_expert_flag = 'Y' AND p_doc_type <> 'OKS' THEN -- Added for Bug 5186245
			                                                        -- Bug# 4874729. Not invoking expert validation for OKS doc type.

                  OKC_XPRT_UTIL_PVT.contract_expert_bv (
                     p_api_version         => 1,
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_document_type       => p_doc_type,
                     p_document_id         => p_doc_id,
                     p_bv_mode             => 'QA',
                     x_expert_articles_tbl => l_expert_articles_tbl,
                     x_msg_data            => x_msg_data,
                     x_msg_count           => x_msg_count,
                     x_qa_result_tbl       => x_qa_result_tbl,
                     x_return_status       => x_return_status);

                END IF;
            END IF;

            IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            --****************************************--
            --         End of validation set          --
            --****************************************--

            -- update common attributes for the QA table
            IF x_qa_result_tbl.COUNT > 0 THEN

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2320: before FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP');
                END IF;

                FOR i IN x_qa_result_tbl.FIRST..x_qa_result_tbl.LAST LOOP
                    x_qa_result_tbl(i).document_type       := p_doc_type;
                    x_qa_result_tbl(i).document_id         := p_doc_id;
                    x_qa_result_tbl(i).creation_date       := l_now;

                    IF x_qa_result_tbl(i).Error_severity = G_QA_STS_ERROR THEN
                        l_error_found := true;
                    END IF;
                    IF x_qa_result_tbl(i).Error_severity = G_QA_STS_WARNING THEN
                        l_warning_found := true;
                    END IF;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1600: i:'||i||', article_id:'||x_qa_result_tbl(i).article_id||', title:'||x_qa_result_tbl(i).title||', qa_code:'||x_qa_result_tbl(i).qa_code);
                    END IF;

                END LOOP;
                IF l_error_found THEN
                    x_qa_return_status := G_QA_STS_ERROR;
                ELSIF l_warning_found THEN
                    x_qa_return_status := G_QA_STS_WARNING;
                END IF;
            END IF;


        END IF; -- IF l_perform_QA then

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2300: Leaving QA_Doc');
        END IF;
        FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2400: Leaving QA_Doc : OKC_API.G_EXCEPTION_ERROR Exception');
            END IF;

            IF l_get_qa_detail_csr%ISOPEN THEN
                CLOSE l_get_qa_detail_csr;
            END IF;
            IF l_get_doc_articles_csr%ISOPEN THEN
                CLOSE l_get_doc_articles_csr;
            END IF;
            IF l_get_tmpl_articles_csr%ISOPEN THEN
                CLOSE l_get_tmpl_articles_csr;
            END IF;
            IF l_get_sections_csr %ISOPEN THEN
                CLOSE l_get_sections_csr ;
            END IF;
            IF l_get_effective_date%ISOPEN THEN
                CLOSE l_get_effective_date;
            END IF;

            /* expert commented out
            IF l_get_xprt_articles_csr%ISOPEN THEN
                CLOSE l_get_xprt_articles_csr;
            END IF;
            */

            x_return_status := G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO g_QA_Doc;
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2500: Leaving QA_Doc : OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
            END IF;
            IF l_get_qa_detail_csr%ISOPEN THEN
                CLOSE l_get_qa_detail_csr;
            END IF;
            IF l_get_doc_articles_csr%ISOPEN THEN
                CLOSE l_get_doc_articles_csr;
            END IF;
            IF l_get_tmpl_articles_csr%ISOPEN THEN
                CLOSE l_get_tmpl_articles_csr;
            END IF;
            IF l_get_sections_csr %ISOPEN THEN
                CLOSE l_get_sections_csr ;
            END IF;
            IF l_get_effective_date%ISOPEN THEN
                CLOSE l_get_effective_date;
            END IF;

            /* expert commented out
            IF l_get_xprt_articles_csr%ISOPEN THEN
                CLOSE l_get_xprt_articles_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2600: Leaving QA_Doc because of EXCEPTION: '||sqlerrm);
            END IF;

            IF l_get_qa_detail_csr%ISOPEN THEN
                CLOSE l_get_qa_detail_csr;
            END IF;
            IF l_get_doc_articles_csr%ISOPEN THEN
                CLOSE l_get_doc_articles_csr;
            END IF;
            IF l_get_tmpl_articles_csr%ISOPEN THEN
                CLOSE l_get_tmpl_articles_csr;
            END IF;
            IF l_get_sections_csr %ISOPEN THEN
                CLOSE l_get_sections_csr ;
            END IF;
            IF l_get_effective_date%ISOPEN THEN
                CLOSE l_get_effective_date;
            END IF;

            /* expert commented out
            IF l_get_xprt_articles_csr%ISOPEN THEN
                CLOSE l_get_xprt_articles_csr;
            END IF;
            */

            x_return_status := G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
            END IF;
    END QA_Doc;

END OKC_TERMS_QA_PVT;

/
