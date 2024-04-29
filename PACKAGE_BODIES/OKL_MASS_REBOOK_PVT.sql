--------------------------------------------------------
--  DDL for Package Body OKL_MASS_REBOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MASS_REBOOK_PVT" AS
/* $Header: OKLRMRPB.pls 120.33.12010000.5 2009/12/16 05:01:27 rpillay ship $*/


    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

--Global Variables
  G_INIT_NUMBER NUMBER := -9999;
  G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_MASS_REBOOK_PVT';
  G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';

  g_stream_trx_number NUMBER; -- Stream Trx number, updated only from rebook_contract

  --DEBUG
  G_PPD_TRX_ID   NUMBER := NULL; -- PPD trx id
  G_PPD_TRX_TYPE VARCHAR2(100) := NULL; -- PPD trx type
  G_TERMINATION_TRX_ID   NUMBER := NULL; -- termination trx id
  G_TERMINATION_TRX_TYPE VARCHAR2(100) := NULL; -- termination trx type
  G_MASS_RBK_TRX_ID      NUMBER := NULL;
  -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
  G_ICB_REAMORT CONSTANT OKL_PRODUCT_PARAMETERS_V.INTEREST_CALCULATION_BASIS%TYPE
                := 'REAMORT';
  G_RRM_STREAMS CONSTANT OKL_PRODUCT_PARAMETERS_V.REVENUE_RECOGNITION_METHOD%TYPE
                := 'STREAMS';
  -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End

  subtype rgpv_rec_type IS OKL_RULE_PUB.rgpv_rec_type;

  subtype rulv_rec_type IS OKL_RULE_PUB.rulv_rec_type;
  subtype rulv_tbl_type IS OKL_RULE_PUB.rulv_tbl_type;

  /*TYPE kle_rec_type IS RECORD (
    ID          OKL_K_LINES_V.ID%TYPE
  );

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER; */


------------------------------------------------------------------------------
-- PROCEDURE Report_Error
-- It is a generalized routine to display error on Concurrent Manager Log file
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE Report_Error(
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2
                        ) IS

  x_msg_index_out NUMBER;
  x_msg_out       VARCHAR2(2000);

  BEGIN

    okl_api.end_activity(
                         X_msg_count => x_msg_count,
                         X_msg_data  => x_msg_data
                        );
    FOR i in 1..x_msg_count
    LOOP
      FND_MSG_PUB.GET(
                      p_msg_index     => i,
                      p_encoded       => FND_API.G_FALSE,
                      p_data          => x_msg_data,
                      p_msg_index_out => x_msg_index_out
                     );

    END LOOP;
    return;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END Report_Error;

------------------------------------------------------------------------------
-- PROCEDURE get_seq_id
--   This proecdure returns unique sequence ID
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

------------------------------------------------------------------------------
-- PROCEDURE get_formated_value
--   This proecdure checks for NUMERIC or CHARACTER Value
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE get_formated_value(
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_orig_value    IN  VARCHAR2,
                               x_fmt_value     OUT NOCOPY VARCHAR2
                              ) IS
  l_proc_name VARCHAR2(35) := 'GET_FORMATED_VALUE';
  l_dummy_number NUMBER;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for NUMBER and CHARACTER
    BEGIN
      l_dummy_number := TO_NUMBER(p_orig_value);
      x_fmt_value    := p_orig_value;
    EXCEPTION
      WHEN VALUE_ERROR THEN
         x_fmt_value := ''''||p_orig_value||'''';
    END;

    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
  END get_formated_value;

------------------------------------------------------------------------------
-- PROCEDURE get_qcl_id
-- It returns qcl_id for QA checker to run
-- Calls:
-- Called By:
------------------------------------------------------------------------------

   PROCEDURE get_qcl_id(
                        x_return_status OUT NOCOPY VARCHAR2,
                        p_qcl_name      IN  VARCHAR2,
                        x_qcl_id        OUT NOCOPY NUMBER) IS

   CURSOR qcl_csr (p_qcL_name VARCHAR2) IS
   SELECT id
   FROM   okc_qa_check_lists_v
   WHERE  name = p_qcl_name;

   l_id   NUMBER;

   BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      OPEN qcl_csr(p_qcl_name);
      FETCH qcl_csr INTO l_id;
      CLOSE qcl_csr;

      x_qcl_id := l_id;

   END get_qcl_id;

------------------------------------------------------------------------------
-- PROCEDURE build_selection
--   This proecdure builds "SELECT" statement from Operands and criteria
--   provided on OKL_MASS_RBK_CRITERIA Table against a REQUEST_NAME.
--   It returns the SELECT Statement for further processing
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE build_selection(
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_request_name  IN  VARCHAR2,
                            p_transaction_date IN DATE,
                            x_statement     OUT NOCOPY VARCHAR2
                           ) IS

  l_api_name    VARCHAR2(35)    := 'build_selection';
  l_proc_name   VARCHAR2(35)    := 'BUILD_SELECTION';

  CURSOR mass_rbk_csr (p_req_name VARCHAR2) IS
  SELECT *
  FROM   okl_mass_rbk_criteria
  WHERE  request_name = p_req_name
  AND    operand IS NOT NULL
  ORDER BY line_number;

  CURSOR crit_csr (p_code VARCHAR2) IS
  SELECT 'Y'
  FROM   fnd_lookups
  WHERE  lookup_type = 'OKL_MASS_RBK_CRITERIA'
  AND    lookup_code = p_code;

  l_query         VARCHAR2(2000);
  l_clause        VARCHAR2(10);
  l_present       VARCHAR2(1);
  l_criteria_code VARCHAR2(35);
  l_fmt_value     VARCHAR2(100);
  i               NUMBER := 0;
  l_asset_row     NUMBER := 0;
  l_fmt_criteria1 VARCHAR2(100);
  l_fmt_criteria2 VARCHAR2(100);
  l_asset_query_present VARCHAR2(1);

  build_error EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     l_asset_query_present := 'F';  -- Checks the presence of Asset Related Criteria

     l_query := 'SELECT CON.ID, CON.CONTRACT_NUMBER, LINE.ID, CON.SHORT_DESCRIPTION FROM OKL_K_HEADERS_FULL_V CON, ';
     l_query := l_query || ' OKL_K_LINES_FULL_V LINE ';

     --insert into dd_dummy values (1,l_query);

     FOR rbk_rec IN mass_rbk_csr(p_request_name)
     LOOP

        OPEN crit_csr (rbk_rec.criteria_code);
        FETCH crit_csr INTO l_present;
        IF crit_csr%NOTFOUND THEN
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_CODE,
                               'VALUE',
                               rbk_rec.criteria_code
                              );
           RAISE build_error;
        END IF;

        CLOSE crit_csr;

        l_criteria_code := rbk_rec.criteria_code;
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_criteria_code);
        END IF;
        -- Special formatting for CONTRACT_NUMBER, always character
        IF (l_criteria_code = 'CONTRACT_NUMBER') THEN

          l_fmt_criteria1 := ''''||rbk_rec.criteria_value1||'''';

        ELSE
           -- Check criteria_value, set_value type
           IF (rbk_rec.criteria_value1 IS NOT NULL) THEN
              get_formated_value(
                                 x_return_status => x_return_status,
                                 p_orig_value    => rbk_rec.criteria_value1,
                                 x_fmt_value     => l_fmt_value
                                );
              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 okl_api.set_message(
                                     G_APP_NAME,
                                     G_FORMAT_ERROR
                                    );
                 RAISE build_error;
              END IF;

              l_fmt_criteria1 := l_fmt_value;
           ELSE
              l_fmt_criteria1 := NULL;
           END IF;

           IF (rbk_rec.criteria_value2 IS NOT NULL) THEN
              get_formated_value(
                                 x_return_status => x_return_status,
                                 p_orig_value    => rbk_rec.criteria_value2,
                                 x_fmt_value     => l_fmt_value
                                );
              IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 okl_api.set_message(
                                     G_APP_NAME,
                                     G_FORMAT_ERROR
                                    );
                 RAISE build_error;
              END IF;

              l_fmt_criteria2 := l_fmt_value;
           ELSE
              l_fmt_criteria2 := NULL;
           END IF;
        END IF;

        i := i + 1;

        IF (i = 1) THEN -- First Row
          l_clause := ' WHERE ';
        ELSE
          l_clause := ' AND ' ;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_fmt_criteria1||', '||l_fmt_criteria2);
        END IF;


        IF (l_criteria_code IN ('BOOK_TYPE_CODE', 'DEPRN_METHOD_CODE', 'DATE_PLACED_IN_SERVICE')) THEN
           l_asset_row := l_asset_row + 1;
           l_asset_query_present := 'T';
           l_query := l_query || l_clause || ' ';
           IF (l_asset_row = 1) THEN -- First Asset Criteria
              l_query := l_query || 'EXISTS ( SELECT 1 FROM OKC_K_ITEMS_V ITEM, FA_BOOKS FB ';
              l_query := l_query || 'WHERE ITEM.JTOT_OBJECT1_CODE = '||''''||'OKX_ASSET'||'''';
              l_query := l_query || ' AND ITEM.DNZ_CHR_ID = CON.ID ';
              l_query := l_query || ' AND LINE.ID = ITEM.CLE_ID ';
              l_query := l_query || ' AND ITEM.OBJECT1_ID1 = FB.ASSET_ID AND';
              --insert into dd_dummy values (2,l_query);
              IF (UPPER(rbk_rec.operand) = 'BETWEEN') THEN
                 l_query := l_query || ' FB.' || l_criteria_code || ' '|| upper(rbk_rec.operand)|| ' ';
                 l_query := l_query || l_fmt_criteria1 || ' AND ' ||
                                       l_fmt_criteria2 ||' ';
                 --insert into dd_dummy values (3,l_query);
              ELSE
                 l_query := l_query || ' FB.'||l_criteria_code|| ' ' || upper(rbk_rec.operand) || ' ' || l_fmt_criteria1;
                 --insert into dd_dummy values (4,l_query);
              END IF;
           ELSE
              IF (UPPER(rbk_rec.operand) = 'BETWEEN') THEN

                 l_query := l_query || ' FB.'|| l_criteria_code || ' ' || upper(rbk_rec.operand)|| ' ';
                 l_query := l_query || l_fmt_criteria1 || ' AND ' ||
                                       l_fmt_criteria2 ||' ';
                 --insert into dd_dummy values (5,l_query);
              ELSE
                 l_query := l_query || ' FB.'||l_criteria_code|| ' ' || upper(rbk_rec.operand) || ' ' || l_fmt_criteria1;
                 --insert into dd_dummy values (6,l_query);
              END IF;

           -- go to FA_BOOKS
           -- Add criteria from OKL_TXD_ASSETS_V and OKL_TXL_ASSETS_V
           --
           END IF;
        ELSIF (l_criteria_code = 'ASSET_CATEGORY_ID') THEN
           -- go to FA_ADDITIONS
           IF (l_asset_query_present = 'T') THEN
              l_query := l_query || ' ) '; -- Complete Asset Query above
              l_asset_query_present := 'F';
           END IF;

           l_query := l_query || l_clause || ' ';
           l_query := l_query || ' EXISTS ( SELECT 1 FROM OKC_K_ITEMS_V ITEM, FA_ADDITIONS ASSET ';
           l_query := l_query || 'WHERE ITEM.JTOT_OBJECT1_CODE = '||''''||'OKX_ASSET'||'''';
           l_query := l_query || ' AND ITEM.DNZ_CHR_ID = CON.ID ';
           l_query := l_query || ' AND LINE.ID = ITEM.CLE_ID ';
           l_query := l_query || ' AND ITEM.OBJECT1_ID1 = ASSET.ASSET_ID ';
           l_query := l_query || ' AND ASSET.'||l_criteria_code|| ' ' || upper(rbk_rec.operand) || ' ' || l_fmt_criteria1;
           l_query := l_query || ' )';
           --insert into dd_dummy values (7,l_query);

        ELSE

           l_query := l_query || l_clause || 'CON.'|| l_criteria_code ||' ';
           --insert into dd_dummy values (8,l_query);

           IF (upper(rbk_rec.operand) = 'BETWEEN') THEN
               l_query := l_query || upper(rbk_rec.operand)||' ';
               l_query := l_query || l_fmt_criteria1 ||' AND '||
                                     l_fmt_criteria2 ||' ';
               --insert into dd_dummy values (9,l_query);
           ELSE
               l_query := l_query || upper(rbk_rec.operand)||' ';
               l_query := l_query || l_fmt_criteria1 || ' ';
               --insert into dd_dummy values (10,l_query);
           END IF;

        END IF;  -- Asset criteria

     END LOOP;

     IF (l_asset_query_present = 'T') THEN
        l_query := l_query || ' ) ';
        l_asset_query_present := 'F';
     END IF;

     l_query := l_query || ' AND CON.STS_CODE = '||''''||'BOOKED'||'''';
      ----
     --Get the Formatted Value for Revision Date
     IF (p_transaction_date IS NOT NULL) THEN
         get_formated_value(
                            x_return_status => x_return_status,
                            p_orig_value    => p_transaction_date,
                            x_fmt_value     => l_fmt_value
                            );
     END IF;
     l_query := l_query || ' '||' AND '|| l_fmt_value || ''||'BETWEEN'||'';
     l_query := l_query || ' CON.START_DATE AND CON.END_DATE ' ||'';
     --------

     l_query := l_query || ' AND CON.ID = LINE.DNZ_CHR_ID ';
     l_query := l_query || ' AND LINE.STS_CODE = '||''''||'BOOKED'||'''';
     l_query := l_query || ' AND LINE.LSE_ID = (SELECT ID FROM OKC_LINE_STYLES_V ';
     l_query := l_query || ' WHERE LTY_CODE = '||''''||'FIXED_ASSET'||''''||')';

     --
     -- Add authoring org restriction

     IF (i = 0) THEN
        -- Error 1
       okl_api.set_message(
                            G_APP_NAME,
                            G_NOT_VALID_REQUEST,
                            'REQ_NAME',
                            p_request_name
                           );
        RAISE build_error;
     END IF;

     --l_query := l_query || ';';

     x_statement := l_query;
     RETURN;

  EXCEPTION
     WHEN build_error THEN

        IF crit_csr%ISOPEN THEN
           CLOSE crit_csr;
        END IF;

        x_return_status := OKL_API.G_RET_STS_ERROR;

     WHEN OTHERS THEN
         okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );
         x_return_status := OKL_API.G_RET_STS_ERROR;
  END build_selection;


------------------------------------------------------------------------------
-- PROCEDURE get_contract
--   This proecdure uses DYNAMIC SQL to get list of contracts from
--   selection criteria provided by user in OKL_MASS_RBK_CRITERIA
--   against REQUEST_NAME
--   It returns the list of contracts selected under present crietria
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE get_contract(
                         p_api_version        IN  NUMBER,
                         p_init_msg_list      IN  VARCHAR2,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2,
                         p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                         p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE DEFAULT SYSDATE,
                         x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                         x_rbk_count          OUT NOCOPY NUMBER
                        ) IS

  l_api_name    VARCHAR2(35)    := 'get_contract';
  l_proc_name   VARCHAR2(35)    := 'GET_CONTRACT';
  l_api_version NUMBER          := 1.0;

  l_statement   VARCHAR2(2000);
  TYPE rbk_csr_type IS REF CURSOR;
  l_rbk_csr     rbk_csr_type;
  l_rbk_rec     rbk_rec_type;
  l_rbk_tbl     rbk_tbl_type;
  i             NUMBER;
  l_dummy       VARCHAR2(1);

  l_mstv_tbl    mstv_tbl_type;

  get_contract_failed EXCEPTION;

  CURSOR req_csr (p_request_name OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE) IS
  SELECT 'Y'
  FROM  okl_rbk_selected_contract
  WHERE request_name = p_request_name;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     OPEN req_csr (p_request_name);
     FETCH req_csr INTO l_dummy;
     IF req_csr%FOUND THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_DUPLICATE_REQUEST,
                            'REQ_NAME',
                            p_request_name
                           );
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE get_contract_failed;
     END IF;

     CLOSE req_csr;

     --
     -- Get Statement from Selection criteria
     --

     build_selection(
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_request_name  => p_request_name,
                     p_transaction_date => p_transaction_date,
                     x_statement     => l_statement
                    );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise get_contract_failed;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise get_contract_failed;
     END IF;

     --insert into dd_dummy values (l_statement);
     --commit;

     --
     -- Run Dynamic SQL to get Contracts
     --

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_statement);
     END IF;
     i := 0;
     OPEN l_rbk_csr FOR l_statement;
     LOOP
        i := i+ 1;
        FETCH l_rbk_csr INTO l_rbk_tbl(i);
        EXIT WHEN l_rbk_csr%NOTFOUND;
     END LOOP;

     --x_rbk_tbl   := l_rbk_tbl;
     x_rbk_count := l_rbk_tbl.COUNT;

     IF (x_rbk_count = 0) THEN
       okl_api.set_message(
                            G_APP_NAME,
                            G_NO_MATCH_FOUND
                           );
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE get_contract_failed;
     ELSE
     --
     -- Populate Selection Table with these Contracts
     --
     FOR i IN 1..x_rbk_count
     LOOP
        l_mstv_tbl(i).request_name         := p_request_name; -- Link with Criteria Table
        l_mstv_tbl(i).transaction_date     := p_transaction_date;
        l_mstv_tbl(i).khr_id               := l_rbk_tbl(i).khr_id;
        l_mstv_tbl(i).contract_number      := l_rbk_tbl(i).contract_number;
        l_mstv_tbl(i).contract_description := l_rbk_tbl(i).description;
        l_mstv_tbl(i).kle_id               := l_rbk_tbl(i).kle_id;
        l_mstv_tbl(i).status               := 'NEW';
        l_mstv_tbl(i).selected_flag        := 'Y';
     END LOOP;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before selected contract insert');
     END IF;

     okl_mst_pvt.insert_row(
                            p_api_version   => 1.0,
                            p_init_msg_list => OKL_API.G_FALSE,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_mstv_tbl      => l_mstv_tbl,
                            x_mstv_tbl      => x_mstv_tbl
                           );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise get_contract_failed;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise get_contract_failed;
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After selected contract insert');
     END IF;
     END IF;

     RETURN;

  EXCEPTION
      WHEN get_contract_failed THEN
         RETURN;

      when OTHERS then
         okl_api.set_message(
                    G_APP_NAME,
                    G_UNEXPECTED_ERROR,
                    'OKL_SQLCODE',
                    SQLCODE,
                    'OKL_SQLERRM',
                    SQLERRM || ': '||G_PKG_NAME||'.'||l_proc_name
                   );
         x_return_status := OKL_API.G_RET_STS_ERROR;

  END get_contract;

------------------------------------------------------------------------------
-- PROCEDURE validate_request
--   This proecdure checks incoming request before inserting and selecting contract
--   for mass re-book process. Checks include OPERAND, CRITERIA_VALUE and SET_VALUE
--   for each line in request.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE validate_request(
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             p_request_name   IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                             p_mrbv_tbl       IN  mrbv_tbl_type
                            ) IS

  l_api_name     VARCHAR2(35)    := 'validate_request';
  l_proc_name    VARCHAR2(35)    := 'VALIDATE_REQUEST';
  l_api_version  NUMBER          := 1.0;

  l_set_value_present VARCHAR2(1) := 'N';
  request_failed EXCEPTION;
  CURSOR get_nls_date_format IS
    SELECT VALUE
    FROM v$nls_parameters
     WHERE parameter = 'NLS_DATE_FORMAT';
  l_nls_date_format v$nls_parameters.VALUE%TYPE;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Req Lines: '||p_mrbv_tbl.COUNT);
    END IF;

    l_set_value_present:= 'N';
    OPEN get_nls_date_format;
    FETCH get_nls_date_format INTO l_nls_date_format;
    CLOSE get_nls_date_format;

    FOR i IN 1..p_mrbv_tbl.COUNT
    LOOP
      IF (p_mrbv_tbl(i).criteria_code = 'CONTRACT_NUMBER') THEN

         IF (p_mrbv_tbl(i).operand NOT IN ('LIKE','=')) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_SET_VALUE,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

      ELSIF (p_mrbv_tbl(i).criteria_code = 'START_DATE') THEN

         IF (p_mrbv_tbl(i).operand NOT IN ('BETWEEN', '<=', '>=')) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         --Check for Date Integrity
         IF((p_mrbv_tbl(i).operand = 'BETWEEN') AND
            ((FND_DATE.string_to_date(p_mrbv_tbl(i).CRITERIA_VALUE1,l_nls_date_format)) > (FND_DATE.string_to_date(p_mrbv_tbl(i).CRITERIA_VALUE2,l_nls_date_format)))) THEN
           -- NAMED INVALID DATE RANGE
           okl_api.set_message(
                                'FND',
                                'NAMED INVALID DATE RANGE',
                                'RANGE',
                                'CONTRACT_START_DATE');
           x_return_status := OKL_API.G_RET_STS_ERROR;

         END IF;
         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_SET_VALUE,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

      ELSIF (p_mrbv_tbl(i).criteria_code = 'BOOK_TYPE_CODE') THEN

         IF (p_mrbv_tbl(i).operand NOT IN ('=')) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_SET_VALUE,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
      ELSIF (p_mrbv_tbl(i).criteria_code = 'DEPRN_METHOD_CODE') THEN
         IF (p_mrbv_tbl(i).operand IS NOT NULL
             AND
             p_mrbv_tbl(i).operand <> '=') THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            l_set_value_present := 'Y';
         END IF;

      ELSIF (p_mrbv_tbl(i).criteria_code = 'DATE_PLACED_IN_SERVICE') THEN
         IF (p_mrbv_tbl(i).operand IS NOT NULL
             AND
             p_mrbv_tbl(i).operand NOT IN('BETWEEN', '<=', '>=')) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         --Check for Date Integrity
         IF((p_mrbv_tbl(i).operand = 'BETWEEN') AND
            ((FND_DATE.string_to_date(p_mrbv_tbl(i).CRITERIA_VALUE1,l_nls_date_format)) > (FND_DATE.string_to_date(p_mrbv_tbl(i).CRITERIA_VALUE2,l_nls_date_format)))) THEN
           -- NAMED INVALID DATE RANGE
             okl_api.set_message(
                                'FND',
                                'NAMED INVALID DATE RANGE',
                                'RANGE',
                                'INSERVICE_DATE');
           x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            l_set_value_present := 'Y';
         END IF;

      ELSIF (p_mrbv_tbl(i).criteria_code = 'ASSET_CATEGORY_ID') THEN
         IF (p_mrbv_tbl(i).operand <> '=') THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_OPERAND,
                                'OPERAND',
                                p_mrbv_tbl(i).operand,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_SET_VALUE,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;
     /* ELSIF (p_mrbv_tbl(i).criteria_code = 'LIFE_IN_MONTHS'
             OR
             p_mrbv_tbl(i).criteria_code = 'BASIC_RATE'
             OR
             p_mrbv_tbl(i).criteria_code = 'ADJUSTED_RATE') THEN

         IF (p_mrbv_tbl(i).operand IS NOT NULL
             OR
             p_mrbv_tbl(i).criteria_value1 IS NOT NULL
             OR
             p_mrbv_tbl(i).criteria_value2 IS NOT NULL) THEN
            okl_api.set_message(
                                G_APP_NAME,
                                G_INVALID_MATCH_OPTION,
                                'CRIT_CODE',
                                p_mrbv_tbl(i).criteria_code
                               );
            x_return_status := OKL_API.G_RET_STS_ERROR;
         END IF;

         IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            l_set_value_present := 'Y';
         END IF; */

      END IF;

    END LOOP;

   /* IF (l_set_value_present = 'N') THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_NO_SET_VALUE,
                           'REQ_NAME',
                           p_request_name
                          );
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF; */

  EXCEPTION
    WHEN request_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
  END validate_request;

------------------------------------------------------------------------------
-- PROCEDURE build_and_get_contracts
--   Overloaded process to accept transaction date from page
--   This proecdure inserts selection criteria to OKL_MASS_RBK_CRITERIA table
--   and populates OKL_RBK_SELECTED_CONTRACT table with selected contracts.
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE build_and_get_contracts(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                    p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                                    p_mrbv_tbl           IN  mrbv_tbl_type,
                                    x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                                    x_rbk_count          OUT NOCOPY NUMBER
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'build_and_get_contracts';
  l_proc_name   VARCHAR2(35)    := 'BUILD_AND_GET_CONTRACTS';
  l_api_version NUMBER          := 1.0;

  x_mrbv_tbl    mrbv_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Validate incoming data
     --
     validate_request(
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_request_name   => p_request_name,
                      p_mrbv_tbl       => p_mrbv_tbl
                     );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
        raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Insert Selection criteria
     --
     okl_mrb_pvt.insert_row(
                            p_api_version   => l_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_mrbv_tbl      => p_mrbv_tbl,
                            x_mrbv_tbl      => x_mrbv_tbl
                           );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Insert');
     END IF;
     --
     -- Get Selected Contracts
     --
     get_contract(
                  p_api_version      => l_api_version,
                  p_init_msg_list    => p_init_msg_list,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_request_name     => p_request_name,
                  p_transaction_date => p_transaction_date,
                  x_mstv_tbl         => x_mstv_tbl,
                  x_rbk_count        => x_rbk_count
                 );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Get Contract');
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END build_and_get_contracts;

------------------------------------------------------------------------------
-- PROCEDURE build_and_get_contracts
--   This proecdure inserts selection criteria to OKL_MASS_RBK_CRITERIA table
--   and populates OKL_RBK_SELECTED_CONTRACT table with selected contracts.
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE build_and_get_contracts(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                    p_mrbv_tbl           IN  mrbv_tbl_type,
                                    x_mstv_tbl           OUT NOCOPY mstv_tbl_type,
                                    x_rbk_count          OUT NOCOPY NUMBER
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'build_and_get_contracts';
  l_proc_name   VARCHAR2(35)    := 'BUILD_AND_GET_CONTRACTS';
  l_api_version NUMBER          := 1.0;

  x_mrbv_tbl    mrbv_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Validate incoming data
     --
     validate_request(
                      x_return_status  => x_return_status,
                      x_msg_count      => x_msg_count,
                      x_msg_data       => x_msg_data,
                      p_request_name   => p_request_name,
                      p_mrbv_tbl       => p_mrbv_tbl
                     );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
        raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Insert Selection criteria
     --
     okl_mrb_pvt.insert_row(
                            p_api_version   => l_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_mrbv_tbl      => p_mrbv_tbl,
                            x_mrbv_tbl      => x_mrbv_tbl
                           );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Insert');
     END IF;
     --
     -- Get Selected Contracts
     --
     get_contract(
                  p_api_version   => l_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_request_name  => p_request_name,
                  x_mstv_tbl      => x_mstv_tbl,
                  x_rbk_count     => x_rbk_count
                 );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Get Contract');
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END build_and_get_contracts;

 ---------------------------------------------------------------------------
 -- FUNCTION get_rec from OKL_RBK_SELECTED_CONTRACT
 ---------------------------------------------------------------------------
  FUNCTION get_rec (
                    p_request_name IN   VARCHAR2,
                    p_chr_id       IN   NUMBER,
                    x_return_status OUT NOCOPY VARCHAR2
                   )
  RETURN mstv_tbl_type IS

  CURSOR mstv_csr (p_request_name VARCHAR2,
                   p_chr_id       NUMBER) IS
  SELECT
     id
    ,request_name
    ,khr_id
    ,contract_number
    ,contract_description
    ,transaction_id
    ,selected_flag
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
  FROM okl_rbk_selected_contract
  WHERE request_name = p_request_name
  AND   khr_id       = p_chr_id
  AND   NVL(status, 'NEW') IN ('NEW', 'ERROR');

  x_mstv_tbl mstv_tbl_type;
  i          NUMBER := 0;
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    i := 1;
    FOR mstv_rec IN mstv_csr(p_request_name,
                              p_chr_id)
    LOOP
       x_mstv_tbl(i).id                   := mstv_rec.id;
       x_mstv_tbl(i).request_name         := mstv_rec.request_name;
       x_mstv_tbl(i).khr_id               := mstv_rec.khr_id;
       x_mstv_tbl(i).contract_number      := mstv_rec.contract_number;
       x_mstv_tbl(i).contract_description := mstv_rec.contract_description;
       x_mstv_tbl(i).transaction_id       := mstv_rec.transaction_id;
       x_mstv_tbl(i).selected_flag        := mstv_rec.selected_flag;
       x_mstv_tbl(i).attribute_category   := mstv_rec.attribute_category;
       x_mstv_tbl(i).attribute1           := mstv_rec.attribute1;
       x_mstv_tbl(i).attribute2           := mstv_rec.attribute2;
       x_mstv_tbl(i).attribute3           := mstv_rec.attribute3;
       x_mstv_tbl(i).attribute4           := mstv_rec.attribute4;
       x_mstv_tbl(i).attribute5           := mstv_rec.attribute5;
       x_mstv_tbl(i).attribute6           := mstv_rec.attribute6;
       x_mstv_tbl(i).attribute7           := mstv_rec.attribute7;
       x_mstv_tbl(i).attribute8           := mstv_rec.attribute8;
       x_mstv_tbl(i).attribute9           := mstv_rec.attribute9;
       x_mstv_tbl(i).attribute10          := mstv_rec.attribute10;
       x_mstv_tbl(i).attribute11          := mstv_rec.attribute11;
       x_mstv_tbl(i).attribute12          := mstv_rec.attribute12;
       x_mstv_tbl(i).attribute13          := mstv_rec.attribute13;
       x_mstv_tbl(i).attribute14          := mstv_rec.attribute14;
       x_mstv_tbl(i).attribute15          := mstv_rec.attribute15;
       i := i + 1;

       --debug_message('Indise ID'||i||' : '||mstv_rec.id);
       --debug_message('Indise ID'||i||' : '||x_mstv_tbl(i).id);
    END LOOP;
    IF (i = 0) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       okl_api.set_message(
                           G_APP_NAME,
                           G_NO_SEL_CONTRACT,
                           'REQ_NAME',
                           p_request_name
                          );
    END IF;

    RETURN x_mstv_tbl;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'WHEN OTHERS occurred');
      END IF;
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              'SQLcode',
              SQLCODE,
              'SQLerrm',
              SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_rec;

------------------------------------------------------------------------------
-- PROCEDURE update_residual_value
--   This proecdure updates Residual Value at Contract Financial Asset Line
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE update_residual_value(
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2,
                                  p_kle_tbl            IN  kle_tbl_type,
                                  p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE
                                 ) IS
  l_api_name    VARCHAR2(35)    := 'update_residual_value';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_RESIDUAL_VALUE';
  l_api_version NUMBER          := 1.0;

  CURSOR oec_csr (p_top_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT oec
  FROM   okl_k_lines_full_v
  WHERE  id = p_top_line_id;

  l_oec          NUMBER;
  l_residual_ptg NUMBER;
  l_klev_tbl     klev_tbl_type;
  l_clev_tbl     clev_tbl_type;

  x_klev_tbl     klev_tbl_type;
  x_clev_tbl     clev_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    FOR i IN 1..p_kle_tbl.COUNT
    LOOP
       l_klev_tbl(i).id := p_kle_tbl(i).id;
       l_clev_tbl(i).id := p_kle_tbl(i).id;

       l_oec := 0;
       l_residual_ptg := NULL;

       OPEN oec_csr (p_kle_tbl(i).id);
       FETCH oec_csr INTO l_oec;
       CLOSE oec_csr;

       IF (l_oec <> 0) THEN
          l_residual_ptg := p_residual_value * 100 / l_oec;
       END IF;

       l_klev_tbl(i).residual_value      := p_residual_value;
       l_klev_tbl(i).residual_percentage := l_residual_ptg;

    END LOOP;

    okl_contract_pub.update_contract_line(
                                          p_api_version     => 1.0,
                                          p_init_msg_list   => OKC_API.G_FALSE,
                                          x_return_status   => x_return_status,
                                          x_msg_count       => x_msg_count,
                                          x_msg_data        => x_msg_data,
                                          p_clev_tbl        => l_clev_tbl,
                                          p_klev_tbl        => l_klev_tbl,
                                          x_clev_tbl        => x_clev_tbl,
                                          x_klev_tbl        => x_klev_tbl
                                         );

    RETURN; -- handle error, if any, at calling block

  END update_residual_value;

------------------------------------------------------------------------------
-- PROCEDURE populate_asset_change
--   This proecdure populates asset related changes to appropriate records
--   and creates Transactions for those.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE populate_asset_change(
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2,
                                  p_request_name       IN  VARCHAR2,
                                  p_online_yn          IN  VARCHAR2,
                                  p_khr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                                  p_kle_tbl            IN  kle_tbl_type,
                                  p_line_count         IN  NUMBER,
                                  p_book_type_code     IN  FA_BOOKS.BOOK_TYPE_CODE%TYPE,
                                  p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                                  p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                                  p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                                  p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                                  p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE ,
                                  p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE DEFAULT SYSDATE
                                 ) IS
  l_api_name    VARCHAR2(35)    := 'populate_asset_change';
  l_proc_name   VARCHAR2(35)    := 'POPULATE_ASSET_CHANGE';
  l_api_version NUMBER          := 1.0;

  CURSOR try_csr(p_trx_type VARCHAR2) IS
  SELECT id
  FROM   okl_trx_types_tl
  WHERE  language = 'US'
  AND    name     = p_trx_type;

  CURSOR book_csr (p_asset_number   okx_ast_bks_v.asset_number%TYPE,
                   p_book_type_code okx_ast_bks_v.book_type_code%TYPE,
                   p_book_class     okx_ast_bks_v.book_class%TYPE) IS
  SELECT id2,
         deprn_method_code,
         life_in_months,
         acquisition_date,
         cost
  FROM   okx_ast_bks_v
  WHERE  book_class     = p_book_class
  AND    asset_number   = p_asset_number
  AND    book_type_code = NVL(p_book_type_code, book_type_code);

  CURSOR addl_line_csr (p_fa_line_id NUMBER) IS
  SELECT oec,
         name
  FROM   OKL_K_LINES_FULL_V
  WHERE  id = (SELECT cle_id
               FROM   okl_k_lines_full_v
               WHERE  id = p_fa_line_id);

  CURSOR unit_csr (p_fa_line_id NUMBER) IS
  SELECT number_of_items
  FROM   okc_k_items_v
  WHERE  cle_id = p_fa_line_id;

  CURSOR fa_line_csr (p_chr_id OKL_K_HEADERS_V.ID%TYPE,
                      p_kle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT line.id
  FROM   okc_k_lines_v line,
         okc_line_styles_v style
  WHERE  line.lse_id    = style.id
  AND    style.lty_code = 'FIXED_ASSET'
  AND    dnz_chr_id     = p_chr_id
  AND    cle_id         = p_kle_id;

  l_thpv_rec   thpv_rec_type;
  x_thpv_rec   thpv_rec_type;

  l_tlpv_rec   tlpv_rec_type;
  x_tlpv_rec   tlpv_rec_type;

  l_adpv_tbl   adpv_tbl_type;
  x_adpv_tbl   adpv_tbl_type;

  l_try_id     NUMBER;
  l_fa_line_id NUMBER;

  l_name        OKL_K_LINES_FULL_V.NAME%TYPE;
  l_oec         OKL_K_LINES_FULL_V.OEC%TYPE;
  l_no_of_items OKC_K_ITEMS.NUMBER_OF_ITEMS%TYPE;
  l_corp_book   OKX_AST_BKS_V.ID2%TYPE;

  l_tax_count   NUMBER;
  l_deprn_method_code OKX_AST_BKS_V.DEPRN_METHOD_CODE%TYPE;
  l_life_in_months    OKX_AST_BKS_V.LIFE_IN_MONTHS%TYPE;
  l_cost              OKX_AST_BKS_V.COST%TYPE;
  l_acquisition_date  DATE;

  asset_change_failed EXCEPTION;
  --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    OPEN try_csr ('Rebook');
    FETCH try_csr INTO l_try_id;
    CLOSE try_csr;

    FOR i IN 1..p_line_count  -- For Each FIXED_ASSET Line
    LOOP

       -- Populate TRX
       l_thpv_rec.tas_type            := 'CRB';
       l_thpv_rec.tsu_code            := 'ENTERED';
       l_thpv_rec.date_trans_occurred := p_transaction_date; --SYSDATE;
       l_thpv_rec.try_id              := l_try_id;

	--Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_thpv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_khr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

       okl_trx_assets_pub.create_trx_ass_h_def(
                                               p_api_version   => 1.0,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_thpv_rec      => l_thpv_rec,
                                               x_thpv_rec      => x_thpv_rec
                                              );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE asset_change_failed;
       END IF;

       -- Populate TXLs
       IF (p_deprn_method_code IS NOT NULL
           OR
           p_life_in_months IS NOT NULL
           OR
           p_in_service_date IS NOT NULL
           OR
           p_basic_rate IS NOT NULL
           OR
           p_adjusted_rate IS NOT NULL) THEN

          l_tlpv_rec.tas_id             := x_thpv_rec.id;
          l_tlpv_rec.tal_type           := 'CRB';
          l_tlpv_rec.dnz_khr_id         := p_khr_id;
          --l_tlpv_rec.in_service_date    := p_in_service_date;
          l_tlpv_rec.line_number        := 1;

          IF (p_in_service_date IS NOT NULL) THEN
             l_tlpv_rec.in_service_date := p_in_service_date;
          END IF;

          IF (p_basic_rate IS NOT NULL) THEN
             l_tlpv_rec.deprn_rate      := p_basic_rate;
          END IF;

          IF (p_adjusted_rate IS NOT NULL) THEN
             l_tlpv_rec.deprn_rate      := p_adjusted_rate;
          END IF;

          IF (p_online_yn = 'Y') THEN
             l_fa_line_id      := p_kle_tbl(i).id;
             l_tlpv_rec.kle_id := l_fa_line_id;
          ELSE

             --
             -- Get FIXED_ASSET Line ID from Top Line ID
             --
             OPEN fa_line_csr(p_khr_id,
                              p_kle_tbl(i).id);
             FETCH fa_line_csr INTO l_fa_line_id;
             CLOSE fa_line_csr;

             l_tlpv_rec.kle_id := l_fa_line_id;
          END IF;

          OPEN addl_line_csr (l_fa_line_id);
          FETCH addl_line_csr INTO l_oec,
                                   l_name;
          CLOSE addl_line_csr;

          l_tlpv_rec.asset_number       := l_name;
          l_tlpv_rec.original_cost      := l_oec;

          OPEN unit_csr (l_fa_line_id);
          FETCH unit_csr INTO l_no_of_items;
          CLOSE unit_csr;

          l_tlpv_rec.current_units      := l_no_of_items;

          --
          -- Get CORPORATE BOOK
          --

          OPEN book_csr(l_name,
                        NULL,
                        'CORPORATE');
          FETCH book_csr INTO l_corp_book,
                              l_deprn_method_code,
                              l_life_in_months,
                              l_acquisition_date,
                              l_cost;
          CLOSE book_csr;

          l_tlpv_rec.corporate_book := l_corp_book;
          l_tlpv_rec.deprn_method   := l_deprn_method_code;
          l_tlpv_rec.life_in_months := l_life_in_months;
          l_tlpv_rec.depreciation_cost := l_cost;
          IF (p_in_service_date IS NULL) THEN
             l_tlpv_rec.in_service_date := l_acquisition_date;
          END IF;

          okl_txl_assets_pub.create_txl_asset_def(
                                                   p_api_version   => 1.0,
                                                   p_init_msg_list => OKL_API.G_FALSE,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_tlpv_rec      => l_tlpv_rec,
                                                   x_tlpv_rec      => x_tlpv_rec
                                                  );

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE asset_change_failed;
          END IF;

       END IF;

       IF (p_deprn_method_code IS NOT NULL
           OR
           p_life_in_months IS NOT NULL
           OR
           p_adjusted_rate IS NOT NULL) THEN

          IF (p_book_type_code IS NULL
              OR
              p_deprn_method_code IS NULL) THEN  -- Get all TAX Book for this asset
             l_tax_count := 0;
             FOR book_rec IN book_csr(l_name,
                                      p_book_type_code,
                                      'TAX')
             LOOP
                l_tax_count := l_tax_count + 1;
                l_adpv_tbl(l_tax_count).tal_id             := x_tlpv_rec.id;
                l_adpv_tbl(l_tax_count).life_in_months_tax := p_life_in_months;
                l_adpv_tbl(l_tax_count).asset_number       := l_name;
                l_adpv_tbl(l_tax_count).cost               := book_rec.cost;

                IF (p_book_type_code IS NULL) THEN
                   l_adpv_tbl(l_tax_count).tax_book        := book_rec.id2;
                ELSE
                   l_adpv_tbl(l_tax_count).tax_book        := p_book_type_code;
                END IF;

                IF (p_deprn_method_code IS NULL) THEN
                   l_adpv_tbl(l_tax_count).deprn_method_tax := book_rec.deprn_method_code;
                ELSE
                   l_adpv_tbl(l_tax_count).deprn_method_tax := p_deprn_method_code;
                END IF;

                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Life in months: '||l_adpv_tbl(l_tax_count).life_in_months_tax);
                END IF;

                 IF (p_adjusted_rate IS NOT NULL) THEN
                    l_adpv_tbl(l_tax_count).deprn_rate_tax := p_adjusted_rate;
                 END IF;
             END LOOP;
          ELSE
             l_adpv_tbl(1).tal_id             := x_tlpv_rec.id;
             l_adpv_tbl(1).deprn_method_tax   := p_deprn_method_code;
             l_adpv_tbl(1).life_in_months_tax := p_life_in_months;
             l_adpv_tbl(1).asset_number       := l_name;
             l_adpv_tbl(1).tax_book           := p_book_type_code;
             l_adpv_tbl(1).deprn_rate_tax     := p_adjusted_rate;
          END IF;

          okl_txd_assets_pub.create_txd_asset_def(
                                                  p_api_version   => 1.0,
                                                  p_init_msg_list => OKL_API.G_FALSE,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_adpv_tbl      => l_adpv_tbl,
                                                  x_adpv_tbl      => x_adpv_tbl
                                                 );

          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
              RAISE asset_change_failed;
          END IF;
       END IF;

    END LOOP;

    RETURN;

  EXCEPTION
    WHEN asset_change_failed THEN
      NULL; --propagate error to caller
  END populate_asset_change;

------------------------------------------------------------------------------
-- PROCEDURE update_slh_sll
--   This proecdure updates any changes requested for Payments (SLH, SLL)
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE update_slh_sll(
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_khr_id            IN  OKC_K_HEADERS_V.ID%TYPE,
                           p_kle_tbl           IN  kle_tbl_type,
                           p_strm_lalevl_tbl   IN  strm_lalevl_tbl_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'update_slh_sll';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_SLH_SLL';
  l_api_version NUMBER          := 1.0;

  CURSOR rgp_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT ID
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id     = p_cle_id
  AND    rgd_code   = 'LALEVL';

  CURSOR slh_csr (p_stream_id OKC_RULES_V.OBJECT1_ID1%TYPE,
                  p_rgp_id    OKC_RULES_V.RGP_ID%TYPE) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  object1_id1 = p_stream_id
  AND    rgp_id      = p_rgp_id
  AND    rule_information_category = 'LASLH';

  CURSOR sll_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_slh_id OKC_RULES_V.ID%TYPE,
                  p_rgp_id OKC_RULE_GROUPS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  dnz_chr_id                = p_chr_id
  AND    rgp_id                    = p_rgp_id
  AND    object2_id1               = p_slh_id
  AND    rule_information_category = 'LASLL';

  l_match_found VARCHAR2(1);
  l_slh_id      NUMBER;
  l_rgpv_rec    rgpv_rec_type;
  x_rgpv_rec    rgpv_rec_type;
  l_rulv_rec    rulv_rec_type;
  l_rulv_tbl    rulv_tbl_type;

  l_slh_rulv_rec rulv_rec_type;
  x_slh_rulv_rec rulv_rec_type;

  l_sll_rulv_rec rulv_rec_type;
  x_sll_rulv_rec rulv_rec_type;

  l_sll_rulv_tbl rulv_tbl_type;
  x_sll_rulv_tbl rulv_tbl_type;

  l_sll_count    NUMBER;
  k              NUMBER;
  l_rgp_id       OKC_RULE_GROUPS_V.ID%TYPE;
  l_slh_rule_id  OKC_RULES_V.ID%TYPE;

  update_failed  EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     FOR i IN 1..p_kle_tbl.COUNT
     LOOP
        l_match_found := 'N';
        l_sll_count   := 0;
        l_sll_rulv_tbl.DELETE; -- Bug# 2754344
        FOR j IN 1..p_strm_lalevl_tbl.COUNT
        LOOP
           IF (p_khr_id = p_strm_lalevl_tbl(j).chr_id
               AND
               p_kle_tbl(i).id = p_strm_lalevl_tbl(j).cle_id) THEN

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'KLE ID: '||p_strm_lalevl_tbl(j).cle_id);
                  END IF;

                  l_match_found := 'Y';
                  IF (p_strm_lalevl_tbl(j).rule_information_category = 'LASLH') THEN

                     OPEN rgp_csr (p_khr_id,
                                   p_strm_lalevl_tbl(j).cle_id);
                     FETCH rgp_csr INTO l_rgp_id;

                     IF rgp_csr%NOTFOUND THEN
                        l_rgpv_rec.rgd_code   := 'LALEVL';
                        l_rgpv_rec.chr_id     := NULL;
                        l_rgpv_rec.dnz_chr_id := p_khr_id;
                        l_rgpv_rec.cle_id     := p_strm_lalevl_tbl(j).cle_id;
                        l_rgpv_rec.rgp_type   := 'KRG';

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Rule group creation');
                        END IF;
                        OKL_RULE_PUB.create_rule_group(
			                             p_api_version     => 1.0,
			                             p_init_msg_list   => OKL_API.G_FALSE,
			                             x_return_status   => x_return_status,
			                             x_msg_count       => x_msg_count,
			                             x_msg_data        => x_msg_data,
			                             p_rgpv_rec        => l_rgpv_rec,
			                             x_rgpv_rec        => x_rgpv_rec
			                            );
			IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            raise update_failed;
                        END IF;
                        l_rgp_id := x_rgpv_rec.id;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Rule Group Created');
                        END IF;
                     END IF;

                     CLOSE rgp_csr;

                     l_slh_id := NULL;
                     OPEN slh_csr (p_strm_lalevl_tbl(j).object1_id1,
                                   l_rgp_id);
                     FETCH slh_csr INTO l_slh_id;
                     CLOSE slh_csr;

                     IF (l_slh_id IS NOT NULL) THEN -- delete rules (SLH, SLL)

                       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside delete rule');
                       END IF;
                       l_rulv_rec.id := l_slh_id;
                       okl_rule_pub.delete_rule(
		                                p_api_version    => 1.0,
		                                p_init_msg_list  => OKC_API.G_FALSE,
		                                x_return_status  => x_return_status,
		                                x_msg_count      => x_msg_count,
		                                x_msg_data       => x_msg_data,
		                                p_rulv_rec       => l_rulv_rec
                                               );
                        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            RAISE update_failed;
                        END IF;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH deleted');
                        END IF;
                        k := 0;
                        FOR sll_rec IN sll_csr(p_khr_id,
                                               l_slh_id,
                                               l_rgp_id)
                        LOOP
                           k := k + 1;
                           l_rulv_tbl(k).id := sll_rec.id;
                        END LOOP;
                        okl_rule_pub.delete_rule(
  		                                 p_api_version    => 1.0,
		                                 p_init_msg_list  => OKC_API.G_FALSE,
		                                 x_return_status  => x_return_status,
		                                 x_msg_count      => x_msg_count,
		                                 x_msg_data       => x_msg_data,
		                                 p_rulv_tbl       => l_rulv_tbl
                                                );
                        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            RAISE update_failed;
                        END IF;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL deleted');
                        END IF;
                     END IF;

                     l_slh_rulv_rec.object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_slh_rulv_rec.jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_slh_rulv_rec.dnz_chr_id                := p_khr_id;
                     l_slh_rulv_rec.rgp_id                    := l_rgp_id;
                     l_slh_rulv_rec.std_template_yn           := 'N';
                     l_slh_rulv_rec.warn_yn                   := 'N';
                     l_slh_rulv_rec.template_yn               := 'N';
                     l_slh_rulv_rec.sfwt_flag                 := 'N';
                     l_slh_rulv_rec.rule_information_category := 'LASLH';
                     l_slh_rulv_rec.rule_information1         := p_strm_lalevl_tbl(j).rule_information1;
                     l_slh_rulv_rec.rule_information2         := p_strm_lalevl_tbl(j).rule_information2;
                     l_slh_rulv_rec.rule_information3         := p_strm_lalevl_tbl(j).rule_information3;
                     l_slh_rulv_rec.rule_information4         := p_strm_lalevl_tbl(j).rule_information4;
                     l_slh_rulv_rec.rule_information5         := p_strm_lalevl_tbl(j).rule_information5;
                     l_slh_rulv_rec.rule_information6         := p_strm_lalevl_tbl(j).rule_information6;
                     l_slh_rulv_rec.rule_information7         := p_strm_lalevl_tbl(j).rule_information7;
                     l_slh_rulv_rec.rule_information8         := p_strm_lalevl_tbl(j).rule_information8;
                     l_slh_rulv_rec.rule_information9         := p_strm_lalevl_tbl(j).rule_information9;
                     l_slh_rulv_rec.rule_information10        := p_strm_lalevl_tbl(j).rule_information10;
                     l_slh_rulv_rec.rule_information11        := p_strm_lalevl_tbl(j).rule_information11;
                     l_slh_rulv_rec.rule_information12        := p_strm_lalevl_tbl(j).rule_information12;
                     l_slh_rulv_rec.rule_information13        := p_strm_lalevl_tbl(j).rule_information13;
                     l_slh_rulv_rec.rule_information14        := p_strm_lalevl_tbl(j).rule_information14;
                     l_slh_rulv_rec.rule_information15        := p_strm_lalevl_tbl(j).rule_information15;
                     l_slh_rulv_rec.jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_slh_rulv_rec.jtot_object2_code         := p_strm_lalevl_tbl(j).jtot_object2_code;
                     l_slh_rulv_rec.jtot_object3_code         := p_strm_lalevl_tbl(j).jtot_object3_code;
                     l_slh_rulv_rec.object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_slh_rulv_rec.object1_id2               := p_strm_lalevl_tbl(j).object1_id2;
                     l_slh_rulv_rec.object2_id1               := p_strm_lalevl_tbl(j).object2_id1;
                     l_slh_rulv_rec.object2_id2               := p_strm_lalevl_tbl(j).object2_id2;
                     l_slh_rulv_rec.object3_id1               := p_strm_lalevl_tbl(j).object3_id1;
                     l_slh_rulv_rec.object3_id2               := p_strm_lalevl_tbl(j).object3_id2;

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before SLH creation');
                     END IF;

                     Okl_Rule_Pub.create_rule(
                         p_api_version     => 1.0,
                         p_init_msg_list   => Okc_Api.G_FALSE,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_rulv_rec        => l_slh_rulv_rec,
                         x_rulv_rec        => x_slh_rulv_rec
                        );

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH status: '||x_return_status);
                     END IF;

                     IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                        RAISE update_failed;
                     END IF;

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH rule created');
                     END IF;

                  ELSIF (p_strm_lalevl_tbl(j).rule_information_category = 'LASLL') THEN

                     l_sll_count := l_sll_count + 1;
                     l_sll_rulv_tbl(l_sll_count).object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_sll_rulv_tbl(l_sll_count).jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_sll_rulv_tbl(l_sll_count).dnz_chr_id                := p_khr_id;
                     l_sll_rulv_tbl(l_sll_count).rgp_id                    := l_rgp_id;
                     l_sll_rulv_tbl(l_sll_count).std_template_yn           := 'N';
                     l_sll_rulv_tbl(l_sll_count).warn_yn                   := 'N';
                     l_sll_rulv_tbl(l_sll_count).template_yn               := 'N';
                     l_sll_rulv_tbl(l_sll_count).sfwt_flag                 := 'N';
                     l_sll_rulv_tbl(l_sll_count).rule_information_category := 'LASLL';
                     l_sll_rulv_tbl(l_sll_count).rule_information1         := p_strm_lalevl_tbl(j).rule_information1;
                     l_sll_rulv_tbl(l_sll_count).rule_information2         := p_strm_lalevl_tbl(j).rule_information2;
                     l_sll_rulv_tbl(l_sll_count).rule_information3         := p_strm_lalevl_tbl(j).rule_information3;
                     l_sll_rulv_tbl(l_sll_count).rule_information4         := p_strm_lalevl_tbl(j).rule_information4;
                     l_sll_rulv_tbl(l_sll_count).rule_information5         := p_strm_lalevl_tbl(j).rule_information5;
                     l_sll_rulv_tbl(l_sll_count).rule_information6         := p_strm_lalevl_tbl(j).rule_information6;
                     l_sll_rulv_tbl(l_sll_count).rule_information7         := p_strm_lalevl_tbl(j).rule_information7;
                     l_sll_rulv_tbl(l_sll_count).rule_information8         := p_strm_lalevl_tbl(j).rule_information8;
                     l_sll_rulv_tbl(l_sll_count).rule_information9         := p_strm_lalevl_tbl(j).rule_information9;
                     l_sll_rulv_tbl(l_sll_count).rule_information10        := p_strm_lalevl_tbl(j).rule_information10;
                     l_sll_rulv_tbl(l_sll_count).rule_information11        := p_strm_lalevl_tbl(j).rule_information11;
                     l_sll_rulv_tbl(l_sll_count).rule_information12        := p_strm_lalevl_tbl(j).rule_information12;
                     l_sll_rulv_tbl(l_sll_count).rule_information13        := p_strm_lalevl_tbl(j).rule_information13;
                     l_sll_rulv_tbl(l_sll_count).rule_information14        := p_strm_lalevl_tbl(j).rule_information14;
                     l_sll_rulv_tbl(l_sll_count).rule_information15        := p_strm_lalevl_tbl(j).rule_information15;
                     l_sll_rulv_tbl(l_sll_count).jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_sll_rulv_tbl(l_sll_count).jtot_object2_code         := p_strm_lalevl_tbl(j).jtot_object2_code;
                     l_sll_rulv_tbl(l_sll_count).jtot_object3_code         := p_strm_lalevl_tbl(j).jtot_object3_code;
                     l_sll_rulv_tbl(l_sll_count).object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_sll_rulv_tbl(l_sll_count).object1_id2               := p_strm_lalevl_tbl(j).object1_id2;
                     l_sll_rulv_tbl(l_sll_count).object2_id1               := x_slh_rulv_rec.id;
                     -- nikshah 25-Nov-08 bug # 6697542
                     l_sll_rulv_tbl(l_sll_count).object2_id2               := '#' ;--p_strm_lalevl_tbl(j).object2_id2;
                     --l_sll_rulv_tbl(l_sll_count).object2_id2               := p_strm_lalevl_tbl(j).object2_id2;
                     -- nikshah 25-Nov-08 bug # 6697542
                     l_sll_rulv_tbl(l_sll_count).object3_id1               := p_strm_lalevl_tbl(j).object3_id1;
                     l_sll_rulv_tbl(l_sll_count).object3_id2               := p_strm_lalevl_tbl(j).object3_id2;
                     -- populate rule tbl data
               END IF;
           END IF;
        END LOOP;

        IF (l_match_found = 'Y') THEN

           l_match_found := 'N';
           Okl_Rule_Pub.create_rule(
	                            p_api_version     => 1.0,
	                            p_init_msg_list   => Okc_Api.G_FALSE,
	                            x_return_status   => x_return_status,
	                            x_msg_count       => x_msg_count,
	                            x_msg_data        => x_msg_data,
	                            p_rulv_tbl        => l_sll_rulv_tbl,
	                            x_rulv_tbl        => x_sll_rulv_tbl
	                           );

	   IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	      RAISE update_failed;
	   END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL rule created');
           END IF;

        END IF;

     END LOOP; -- Contract Header/Line

     RETURN;

  EXCEPTION
     WHEN update_failed THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update failed in update_slh_sll');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        --raise; -- handle error in called routine
  END update_slh_sll;

------------------------------------------------------------------------------
-- PROCEDURE update_ppd_amount
--   This proecdure updates PPD Payments (SLH, SLL)
-- Calls:
-- Called by: rebook_contract (for PPD amount only)

------------------------------------------------------------------------------
  PROCEDURE update_ppd_amount(
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_khr_id            IN  OKC_K_HEADERS_V.ID%TYPE,
                           p_kle_tbl           IN  kle_tbl_type,
                           p_strm_lalevl_tbl   IN  strm_lalevl_tbl_type
                         ) IS

  l_api_name    VARCHAR2(35)    := 'update_ppd_amount';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_PPD_AMOUNT';
  l_api_version NUMBER          := 1.0;

  CURSOR rgp_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT ID
  FROM   okc_rule_groups_v
  WHERE  dnz_chr_id = p_chr_id
  AND    cle_id     = p_cle_id
  AND    rgd_code   = 'LALEVL';

  CURSOR slh_csr (p_stream_id OKC_RULES_V.OBJECT1_ID1%TYPE,
                  p_rgp_id    OKC_RULES_V.RGP_ID%TYPE) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  object1_id1 = p_stream_id
  AND    rgp_id      = p_rgp_id
  AND    rule_information_category = 'LASLH';

  CURSOR sll_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                  p_slh_id OKC_RULES_V.ID%TYPE,
                  p_rgp_id OKC_RULE_GROUPS_V.ID%TYPE) IS
  SELECT id
  FROM   okc_rules_v
  WHERE  dnz_chr_id                = p_chr_id
  AND    rgp_id                    = p_rgp_id
  AND    object2_id1               = p_slh_id
  AND    rule_information_category = 'LASLL';

  l_match_found VARCHAR2(1);
  l_slh_id      NUMBER;
  l_rgpv_rec    rgpv_rec_type;
  x_rgpv_rec    rgpv_rec_type;
  l_rulv_rec    rulv_rec_type;
  l_rulv_tbl    rulv_tbl_type;

  l_slh_rulv_rec rulv_rec_type;
  x_slh_rulv_rec rulv_rec_type;

  l_sll_rulv_rec rulv_rec_type;
  x_sll_rulv_rec rulv_rec_type;

  l_sll_rulv_tbl rulv_tbl_type;
  x_sll_rulv_tbl rulv_tbl_type;

  l_sll_count    NUMBER;
  k              NUMBER;
  l_rgp_id       OKC_RULE_GROUPS_V.ID%TYPE;
  l_slh_rule_id  OKC_RULES_V.ID%TYPE;

  l_previous_lasll_exists BOOLEAN := FALSE;
  update_failed  EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     FOR i IN 1..p_kle_tbl.COUNT
     LOOP
        l_match_found := 'N';
        l_sll_count   := 0;
        l_sll_rulv_tbl.DELETE; -- Bug# 2754344
        l_previous_lasll_exists := FALSE;
        FOR j IN 1..p_strm_lalevl_tbl.COUNT
        LOOP
           IF (p_khr_id = p_strm_lalevl_tbl(j).chr_id
               AND
               p_kle_tbl(i).id = p_strm_lalevl_tbl(j).cle_id) THEN

                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'KLE ID: '||p_strm_lalevl_tbl(j).cle_id);
                  END IF;

                  l_match_found := 'Y';
                  IF (p_strm_lalevl_tbl(j).rule_information_category = 'LASLH') THEN

                     IF (l_previous_lasll_exists) THEN
                        Okl_Rule_Pub.create_rule(
	                            p_api_version     => 1.0,
	                            p_init_msg_list   => Okc_Api.G_FALSE,
	                            x_return_status   => x_return_status,
	                            x_msg_count       => x_msg_count,
	                            x_msg_data        => x_msg_data,
	                            p_rulv_tbl        => l_sll_rulv_tbl,
	                            x_rulv_tbl        => x_sll_rulv_tbl
	                           );

	                IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	                  RAISE update_failed;
	                END IF;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL rule created');
                        END IF;
                        l_previous_lasll_exists := FALSE;
                        l_sll_rulv_tbl.DELETE; -- Bug# 2754344

                     END IF;

                     OPEN rgp_csr (p_khr_id,
                                   p_strm_lalevl_tbl(j).cle_id);
                     FETCH rgp_csr INTO l_rgp_id;

                     IF rgp_csr%NOTFOUND THEN
                        l_rgpv_rec.rgd_code   := 'LALEVL';
                        l_rgpv_rec.chr_id     := NULL;
                        l_rgpv_rec.dnz_chr_id := p_khr_id;
                        l_rgpv_rec.cle_id     := p_strm_lalevl_tbl(j).cle_id;
                        l_rgpv_rec.rgp_type   := 'KRG';

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Rule group creation');
                        END IF;
                        OKL_RULE_PUB.create_rule_group(
			                             p_api_version     => 1.0,
			                             p_init_msg_list   => OKL_API.G_FALSE,
			                             x_return_status   => x_return_status,
			                             x_msg_count       => x_msg_count,
			                             x_msg_data        => x_msg_data,
			                             p_rgpv_rec        => l_rgpv_rec,
			                             x_rgpv_rec        => x_rgpv_rec
			                            );
			IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            raise update_failed;
                        END IF;
                        l_rgp_id := x_rgpv_rec.id;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Rule Group Created');
                        END IF;
                     END IF;

                     CLOSE rgp_csr;

                     l_slh_id := NULL;
                     OPEN slh_csr (p_strm_lalevl_tbl(j).object1_id1,
                                   l_rgp_id);
                     FETCH slh_csr INTO l_slh_id;
                     CLOSE slh_csr;

                     IF (l_slh_id IS NOT NULL) THEN -- delete rules (SLH, SLL)

                       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inside delete rule');
                       END IF;
                       l_rulv_rec.id := l_slh_id;
                       okl_rule_pub.delete_rule(
		                                p_api_version    => 1.0,
		                                p_init_msg_list  => OKC_API.G_FALSE,
		                                x_return_status  => x_return_status,
		                                x_msg_count      => x_msg_count,
		                                x_msg_data       => x_msg_data,
		                                p_rulv_rec       => l_rulv_rec
                                               );
                        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            RAISE update_failed;
                        END IF;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH deleted');
                        END IF;
                        k := 0;
                        FOR sll_rec IN sll_csr(p_khr_id,
                                               l_slh_id,
                                               l_rgp_id)
                        LOOP
                           k := k + 1;
                           l_rulv_tbl(k).id := sll_rec.id;
                        END LOOP;
                        okl_rule_pub.delete_rule(
  		                                 p_api_version    => 1.0,
		                                 p_init_msg_list  => OKC_API.G_FALSE,
		                                 x_return_status  => x_return_status,
		                                 x_msg_count      => x_msg_count,
		                                 x_msg_data       => x_msg_data,
		                                 p_rulv_tbl       => l_rulv_tbl
                                                );
                        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                            RAISE update_failed;
                        END IF;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL deleted');
                        END IF;
                     END IF;

                     l_slh_rulv_rec.object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_slh_rulv_rec.jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_slh_rulv_rec.dnz_chr_id                := p_khr_id;
                     l_slh_rulv_rec.rgp_id                    := l_rgp_id;
                     l_slh_rulv_rec.std_template_yn           := 'N';
                     l_slh_rulv_rec.warn_yn                   := 'N';
                     l_slh_rulv_rec.template_yn               := 'N';
                     l_slh_rulv_rec.sfwt_flag                 := 'N';
                     l_slh_rulv_rec.rule_information_category := 'LASLH';
                     l_slh_rulv_rec.rule_information1         := p_strm_lalevl_tbl(j).rule_information1;
                     l_slh_rulv_rec.rule_information2         := p_strm_lalevl_tbl(j).rule_information2;
                     l_slh_rulv_rec.rule_information3         := p_strm_lalevl_tbl(j).rule_information3;
                     l_slh_rulv_rec.rule_information4         := p_strm_lalevl_tbl(j).rule_information4;
                     l_slh_rulv_rec.rule_information5         := p_strm_lalevl_tbl(j).rule_information5;
                     l_slh_rulv_rec.rule_information6         := p_strm_lalevl_tbl(j).rule_information6;
                     l_slh_rulv_rec.rule_information7         := p_strm_lalevl_tbl(j).rule_information7;
                     l_slh_rulv_rec.rule_information8         := p_strm_lalevl_tbl(j).rule_information8;
                     l_slh_rulv_rec.rule_information9         := p_strm_lalevl_tbl(j).rule_information9;
                     l_slh_rulv_rec.rule_information10        := p_strm_lalevl_tbl(j).rule_information10;
                     l_slh_rulv_rec.rule_information11        := p_strm_lalevl_tbl(j).rule_information11;
                     l_slh_rulv_rec.rule_information12        := p_strm_lalevl_tbl(j).rule_information12;
                     l_slh_rulv_rec.rule_information13        := p_strm_lalevl_tbl(j).rule_information13;
                     l_slh_rulv_rec.rule_information14        := p_strm_lalevl_tbl(j).rule_information14;
                     l_slh_rulv_rec.rule_information15        := p_strm_lalevl_tbl(j).rule_information15;
                     l_slh_rulv_rec.jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_slh_rulv_rec.jtot_object2_code         := p_strm_lalevl_tbl(j).jtot_object2_code;
                     l_slh_rulv_rec.jtot_object3_code         := p_strm_lalevl_tbl(j).jtot_object3_code;
                     l_slh_rulv_rec.object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_slh_rulv_rec.object1_id2               := p_strm_lalevl_tbl(j).object1_id2;
                     l_slh_rulv_rec.object2_id1               := p_strm_lalevl_tbl(j).object2_id1;
                     l_slh_rulv_rec.object2_id2               := p_strm_lalevl_tbl(j).object2_id2;
                     l_slh_rulv_rec.object3_id1               := p_strm_lalevl_tbl(j).object3_id1;
                     l_slh_rulv_rec.object3_id2               := p_strm_lalevl_tbl(j).object3_id2;

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before SLH creation');
                     END IF;

                     Okl_Rule_Pub.create_rule(
                         p_api_version     => 1.0,
                         p_init_msg_list   => Okc_Api.G_FALSE,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_rulv_rec        => l_slh_rulv_rec,
                         x_rulv_rec        => x_slh_rulv_rec
                        );

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH status: '||x_return_status);
                     END IF;

                     IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                        RAISE update_failed;
                     END IF;

                     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLH rule created');
                     END IF;

                  ELSIF (p_strm_lalevl_tbl(j).rule_information_category = 'LASLL') THEN

                     l_previous_lasll_exists:= TRUE;
                     l_sll_count := l_sll_count + 1;
                     l_sll_rulv_tbl(l_sll_count).object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_sll_rulv_tbl(l_sll_count).jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_sll_rulv_tbl(l_sll_count).dnz_chr_id                := p_khr_id;
                     l_sll_rulv_tbl(l_sll_count).rgp_id                    := l_rgp_id;
                     l_sll_rulv_tbl(l_sll_count).std_template_yn           := 'N';
                     l_sll_rulv_tbl(l_sll_count).warn_yn                   := 'N';
                     l_sll_rulv_tbl(l_sll_count).template_yn               := 'N';
                     l_sll_rulv_tbl(l_sll_count).sfwt_flag                 := 'N';
                     l_sll_rulv_tbl(l_sll_count).rule_information_category := 'LASLL';
                     l_sll_rulv_tbl(l_sll_count).rule_information1         := p_strm_lalevl_tbl(j).rule_information1;
                     l_sll_rulv_tbl(l_sll_count).rule_information2         := p_strm_lalevl_tbl(j).rule_information2;
                     l_sll_rulv_tbl(l_sll_count).rule_information3         := p_strm_lalevl_tbl(j).rule_information3;
                     l_sll_rulv_tbl(l_sll_count).rule_information4         := p_strm_lalevl_tbl(j).rule_information4;
                     l_sll_rulv_tbl(l_sll_count).rule_information5         := p_strm_lalevl_tbl(j).rule_information5;
                     l_sll_rulv_tbl(l_sll_count).rule_information6         := p_strm_lalevl_tbl(j).rule_information6;
                     l_sll_rulv_tbl(l_sll_count).rule_information7         := p_strm_lalevl_tbl(j).rule_information7;
                     l_sll_rulv_tbl(l_sll_count).rule_information8         := p_strm_lalevl_tbl(j).rule_information8;
                     l_sll_rulv_tbl(l_sll_count).rule_information9         := p_strm_lalevl_tbl(j).rule_information9;
                     l_sll_rulv_tbl(l_sll_count).rule_information10        := p_strm_lalevl_tbl(j).rule_information10;
                     l_sll_rulv_tbl(l_sll_count).rule_information11        := p_strm_lalevl_tbl(j).rule_information11;
                     l_sll_rulv_tbl(l_sll_count).rule_information12        := p_strm_lalevl_tbl(j).rule_information12;
                     l_sll_rulv_tbl(l_sll_count).rule_information13        := p_strm_lalevl_tbl(j).rule_information13;
                     l_sll_rulv_tbl(l_sll_count).rule_information14        := p_strm_lalevl_tbl(j).rule_information14;
                     l_sll_rulv_tbl(l_sll_count).rule_information15        := p_strm_lalevl_tbl(j).rule_information15;
                     l_sll_rulv_tbl(l_sll_count).jtot_object1_code         := p_strm_lalevl_tbl(j).jtot_object1_code;
                     l_sll_rulv_tbl(l_sll_count).jtot_object2_code         := p_strm_lalevl_tbl(j).jtot_object2_code;
                     l_sll_rulv_tbl(l_sll_count).jtot_object3_code         := p_strm_lalevl_tbl(j).jtot_object3_code;
                     l_sll_rulv_tbl(l_sll_count).object1_id1               := p_strm_lalevl_tbl(j).object1_id1;
                     l_sll_rulv_tbl(l_sll_count).object1_id2               := p_strm_lalevl_tbl(j).object1_id2;
                     l_sll_rulv_tbl(l_sll_count).object2_id1               := x_slh_rulv_rec.id;
                     -- nikshah 25-Nov-08 bug # 6697542
                     l_sll_rulv_tbl(l_sll_count).object2_id2               := '#' ;--p_strm_lalevl_tbl(j).object2_id2;
                     --l_sll_rulv_tbl(l_sll_count).object2_id2               := p_strm_lalevl_tbl(j).object2_id2;
                     -- nikshah 25-Nov-08 bug # 6697542
                     l_sll_rulv_tbl(l_sll_count).object3_id1               := p_strm_lalevl_tbl(j).object3_id1;
                     l_sll_rulv_tbl(l_sll_count).object3_id2               := p_strm_lalevl_tbl(j).object3_id2;
                     -- populate rule tbl data
               END IF;
           END IF;
        END LOOP;

        IF (l_match_found = 'Y') THEN

           l_match_found := 'N';
           Okl_Rule_Pub.create_rule(
	                            p_api_version     => 1.0,
	                            p_init_msg_list   => Okc_Api.G_FALSE,
	                            x_return_status   => x_return_status,
	                            x_msg_count       => x_msg_count,
	                            x_msg_data        => x_msg_data,
	                            p_rulv_tbl        => l_sll_rulv_tbl,
	                            x_rulv_tbl        => x_sll_rulv_tbl
	                           );

	   IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	      RAISE update_failed;
	   END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'SLL rule created');
           END IF;

        END IF;

     END LOOP; -- Contract Header/Line

     RETURN;

  EXCEPTION
     WHEN update_failed THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update failed in update_ppd_amount');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        NULL; -- handle error in called routine
       --raise;
  END update_ppd_amount;

------------------------------------------------------------------------------
-- PROCEDURE rebook_contract
--   This proecdure process rebook for each contract supplied as parameter.
--   Set values are in form of parameter too. Either specify or send NULL
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE rebook_contract(
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_msg_count          OUT NOCOPY NUMBER,
                            x_msg_data           OUT NOCOPY VARCHAR2,
                            p_online_yn          IN  VARCHAR2,
                            p_khr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                            p_kle_tbl            IN  kle_tbl_type,
                            p_line_count         IN  NUMBER,
                            p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                            p_book_type_code     IN  FA_BOOKS.BOOK_TYPE_CODE%TYPE,
                            p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                            p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                            p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                            p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                            p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                            p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                            p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                            p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE DEFAULT SYSDATE
                          ) IS
  l_api_name    VARCHAR2(35)    := 'rebook_contract';
  l_proc_name   VARCHAR2(35)    := 'REBOOK_CONTRACT';
  l_api_version NUMBER          := 1.0;

  l_mstv_rec    mstv_rec_type;
  x_mstv_rec    mstv_rec_type;

  l_mstv_tbl    mstv_tbl_type;
  x_mstv_tbl    mstv_tbl_type;

  l_qcl_id      NUMBER;
  l_msg_tbl     Okl_Qa_Check_Pub.msg_tbl_type;
  l_qa_check_status VARCHAR2(1);

  x_trx_number           NUMBER;
  x_trx_status           VARCHAR2(100);

  l_khrv_rec             khrv_rec_type;
  x_khrv_rec             khrv_rec_type;

  l_chrv_rec             chrv_rec_type;
  x_chrv_rec             chrv_rec_type;

  l_cvmv_rec             cvmv_rec_type;
  x_cvmv_rec             cvmv_rec_type;

  l_tcnv_rec             tcnv_rec_type;
  x_tcnv_rec             tcnv_rec_type;

  l_c_no varchar2(100);
  l_sts  varchar2(100);

  CURSOR con_sts_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT sts.ste_code
  FROM   okc_statuses_b sts,
         okc_k_headers_b hdr
  WHERE  hdr.sts_code = sts.code
  AND    hdr.id       = p_chr_id;

  l_request_name         okl_rbk_selected_contract.request_name%TYPE;
  rebook_contract_failed EXCEPTION;

  l_transaction_date  DATE;
  x_ignore_flag       VARCHAR2(1);
  l_upfront_tax_status VARCHAR2(1) := 'S';

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    IF (p_transaction_date IS NULL
        OR
        p_transaction_date = OKL_API.G_MISS_DATE) THEN

       l_transaction_date := TRUNC(SYSDATE);
    ELSE
       l_transaction_date := p_transaction_date;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract : '||p_khr_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Tot Line : '||p_line_count);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Online? :' ||p_online_yn);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Transaction Date :' ||l_transaction_date);
    END IF;

    g_stream_trx_number := NULL; -- initialize before start

    --Bug# 8756653
    -- Check if contract has been upgraded for effective dated rebook
    -- for all mass rebooks other than partial termination
    IF (G_TERMINATION_TRX_ID IS NULL) THEN
      OKL_LLA_UTIL_PVT.check_rebook_upgrade
        (p_api_version     => 1.0,
         p_init_msg_list   => OKL_API.G_FALSE,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_chr_id          => p_khr_id);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE rebook_contract_failed;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE rebook_contract_failed;
      END IF;
    END IF;

    IF (p_online_yn = 'N') THEN -- populate selected_contract table for Non-Online process only
       l_request_name          := TO_CHAR(get_seq_id());
       l_mstv_rec.request_name := l_request_name;
       FOR i IN 1..p_line_count
       LOOP
         l_mstv_rec.khr_id           := p_khr_id;
         l_mstv_rec.kle_id           := p_kle_tbl(i).id;
         l_mstv_rec.status           := 'NEW';
         l_mstv_rec.transaction_date := l_transaction_date;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Req: '||l_mstv_rec.request_name);
         END IF;
         okl_mst_pvt.insert_row(
                          p_api_version   => 1.0,
                          p_init_msg_list => OKL_API.G_FALSE,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_mstv_rec      => l_mstv_rec,
                          x_mstv_rec      => x_mstv_rec
                         );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
             RAISE rebook_contract_failed;
         END IF;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Line ID: '||p_kle_tbl(i).id);
         END IF;
       END LOOP;

    ELSE
       l_request_name := p_request_name;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Versioning...');
    END IF;
    --
    -- Version the Original Contract, only if it is ACTIVE, OKC requirement
    --

    FOR con_sts_rec IN con_sts_csr (p_khr_id)
    LOOP
       IF (con_sts_rec.ste_code = 'ACTIVE') THEN

          l_cvmv_rec.chr_id := p_khr_id;
          okl_version_pub.version_contract(
                                           p_api_version   => 1.0,
                                           p_init_msg_list => OKC_API.G_FALSE,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_cvmv_rec      => l_cvmv_rec,
                                           p_commit        => OKL_API.G_FALSE,
                                           x_cvmv_rec      => x_cvmv_rec
                                          );

           IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE rebook_contract_failed;
           END IF;

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract is versioned: '||x_return_status);
           END IF;
       END IF;
    END LOOP;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After Versioning of Contract');
     END IF;
     -- Create Transaction for the rebook-ed contract

     okl_transaction_pvt.create_transaction(
                        p_api_version        => l_api_version,
                        p_init_msg_list      => OKL_API.G_FALSE,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_chr_id             => p_khr_id,
                        p_new_chr_id         => NULL,
                        p_reason_code        => 'OTHER',
                        p_description        => NULL,
                        p_trx_date           => l_transaction_date, --SYSDATE,
                        p_trx_type           => 'REBOOK',
                        x_tcnv_rec           => x_tcnv_rec
                       );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE rebook_contract_failed;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Status After create transaction: '||x_return_status);
     END IF;

     l_mstv_tbl := get_rec(l_request_name, p_khr_id, x_return_status);

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after get_rec : '||x_return_status);
     END IF;
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE rebook_contract_failed;
     END IF;

     FOR i IN 1..l_mstv_tbl.COUNT
     LOOP
        l_mstv_tbl(i).transaction_id := x_tcnv_rec.id;
        l_mstv_tbl(i).status         := 'UNDER REVISION';
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ID : '|| l_mstv_tbl(i).id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'TRX ID : '|| l_mstv_tbl(i).transaction_id);
        END IF;
     END LOOP;

     okl_mst_pvt.update_row(
                            p_api_version    => l_api_version,
                            p_init_msg_list  => OKL_API.G_FALSE,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_mstv_tbl       => l_mstv_tbl,
                            x_mstv_tbl       => x_mstv_tbl
                           );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after update mst :'|| x_return_status);
     END IF;
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE rebook_contract_failed;
     END IF;

     -- Termination specific logic here
     IF (G_TERMINATION_TRX_ID IS NOT NULL) THEN
       --
       -- Update Mass rebook Transaction with source trx.
       --
       okl_api.set_message('OKL', 'AM', 'Termination Trx ID: ', G_TERMINATION_TRX_ID);
       l_tcnv_rec.id              := x_tcnv_rec.id;
       l_tcnv_rec.source_trx_id   := G_TERMINATION_TRX_ID;
       l_tcnv_rec.source_trx_type := G_TERMINATION_TRX_TYPE;
       G_MASS_RBK_TRX_ID          := x_tcnv_rec.id;

       Okl_Trx_Contracts_Pub.update_trx_contracts(
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => OKL_API.G_FALSE,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_tcnv_rec      => l_tcnv_rec,
                                         x_tcnv_rec      => x_tcnv_rec
                                        );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After update transaction: '||x_return_status);
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after first loop ');
     END IF;

     --DEBUG
     -- PPD specific logic here
     IF (G_PPD_TRX_ID IS NOT NULL) THEN
       --
       -- Update Mass rebook Transaction with source trx.
       --
       okl_api.set_message('OKL', 'AM', 'Termination Trx ID: ', G_TERMINATION_TRX_ID);
       l_tcnv_rec.id              := x_tcnv_rec.id;
       l_tcnv_rec.source_trx_id   := G_PPD_TRX_ID;
       --l_tcnv_rec.source_trx_type := G_PPD_TRX_TYPE;
       l_tcnv_rec.source_trx_type := 'TCN';
       G_MASS_RBK_TRX_ID          := x_tcnv_rec.id;

       Okl_Trx_Contracts_Pub.update_trx_contracts(
                                         p_api_version   => l_api_version,
                                         p_init_msg_list => OKL_API.G_FALSE,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_tcnv_rec      => l_tcnv_rec,
                                         x_tcnv_rec      => x_tcnv_rec
                                        );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After update transaction: '||x_return_status);
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after second loop ');
     END IF;
     --
     -- Fix Bug# 2894810
     -- Create reversal journal entries before
     -- modifying the contract. This will help
     -- successfully reverse the current JE
     --

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Transaction date: '||l_transaction_date);
     END IF;
     -- Bug#4542290 - smadhava - 01-SEP-2005 - Added - Start
     -- Bypass accoutning call for source transaction = Loan/Principal Pay down or Partial termination
     IF ( G_PPD_TRX_ID IS NULL AND G_TERMINATION_TRX_ID IS NULL ) THEN
     -- Bug#4542290 - smadhava - 01-SEP-2005 - Added - End

       OKL_LA_JE_PVT.GENERATE_JOURNAL_ENTRIES(
                      p_api_version      => l_api_version,
                      p_init_msg_list    => OKL_API.G_FALSE,
                      p_commit           => OKL_API.G_FALSE,
                      p_contract_id      => p_khr_id,
                      p_transaction_type => 'Rebook',
                      p_transaction_date => l_transaction_date, --trunc(SYSDATE),
                      p_draft_yn         => OKL_API.G_FALSE,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data
                     );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after generate journal entries ');
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE rebook_contract_failed;
       END IF;
     -- Bug#4542290 - smadhava - 01-SEP-2005 - Added - Start
     END IF; -- end of check for the source transaction
     -- Bug#4542290 - smadhava - 01-SEP-2005 - Added - End


     -- Update contract according to parameter specified
     populate_asset_change(
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           p_request_name       => l_request_name,
                           p_online_yn          => p_online_yn,
                           p_khr_id             => p_khr_id,
                           p_kle_tbl            => p_kle_tbl,
                           p_line_count         => p_line_count,
                           p_book_type_code     => p_book_type_code,
                           p_deprn_method_code  => p_deprn_method_code,
                           p_in_service_date    => p_in_service_date,
                           p_life_in_months     => p_life_in_months,
                           p_basic_rate         => p_basic_rate,
                           p_adjusted_rate      => p_adjusted_rate,
                           p_transaction_date   => l_transaction_date
                          );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after populate asset change ');
     END IF;
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE rebook_contract_failed;
     END IF;

     --
     -- Update RESIDUAL_VALUE if asked for ...
     --
     IF (p_residual_value IS NOT NULL) THEN
        update_residual_value(
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_kle_tbl            => p_kle_tbl,
                              p_residual_value     => p_residual_value
                             );

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE rebook_contract_failed;
        END IF;
     END IF;

     --
     -- Update SLH, SLL if provided, only for Non-OnLine process
     --
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before calling update_ppd_amount');
     END IF;
     IF (p_online_yn = 'N'
         AND
         p_strm_lalevl_tbl.COUNT > 0) THEN
       IF (G_PPD_TRX_ID IS NOT NULL) THEN
        update_ppd_amount(
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data,
                       p_khr_id           => p_khr_id,
                       p_kle_tbl          => p_kle_tbl,
                       p_strm_lalevl_tbl  => p_strm_lalevl_tbl
                      );
       ELSE
        update_slh_sll(
                       x_return_status    => x_return_status,
                       x_msg_count        => x_msg_count,
                       x_msg_data         => x_msg_data,
                       p_khr_id           => p_khr_id,
                       p_kle_tbl          => p_kle_tbl,
                       p_strm_lalevl_tbl  => p_strm_lalevl_tbl
                      );
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'after calling update_ppd_amount');
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           RAISE rebook_contract_failed;
       END IF;
     END IF;

     --
     -- Bug# 2843007, 14-MAR-2003
     -- Call Insurance API for asset termination
     --
--Bug#5955320
     OKL_INSURANCE_POLICIES_PUB.cancel_create_policies(
                                                       p_api_version        => 1.0,
                                                       p_init_msg_list      => OKL_API.G_FALSE,
                                                       x_return_status      => x_return_status,
                                                       x_msg_count          => x_msg_count,
                                                       x_msg_data           => x_msg_data,
                                                       p_khr_id             => p_khr_id,
                                                       p_cancellation_date  => l_transaction_date, --SYSDATE
                                                       --Bug# 4055812
                                                       --Bug# 3945995
					               p_transaction_id     => G_MASS_RBK_TRX_ID,
                                                       x_ignore_flag        => x_ignore_flag
                                                      );

     IF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        IF (x_ignore_flag = OKL_API.G_FALSE) THEN
           raise rebook_contract_failed;
        ELSE
           x_return_status := OKL_API.G_RET_STS_SUCCESS;
        END IF;
     ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise rebook_contract_failed;
     END IF;

     -- Run QA Checker

     get_qcl_id(
                x_return_status => x_return_status,
                p_qcl_name      => 'OKL LA QA CHECK LIST',
                x_qcl_id        => l_qcl_id
               );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Running QA Checker...');
     END IF;
     l_qa_check_status := 'S';
     okl_contract_book_pub.execute_qa_check_list(
                                                 p_api_version    => 1.0,
                                                 p_init_msg_list  => OKL_API.G_FALSE,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_qcl_id         => l_qcl_id,
                                                 p_chr_id         => p_khr_id,
                                                 x_msg_tbl        => l_msg_tbl
                                                );

     FOR i IN 1..l_msg_tbl.LAST
     LOOP
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Name        : '||l_msg_tbl(i).name);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Description : '||l_msg_tbl(i).description);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error Status: '||l_msg_tbl(i).error_status);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Data        : '||l_msg_tbl(i).data);
        END IF;

        IF (l_msg_tbl(i).error_status = 'E') THEN
           l_qa_check_status := 'E';
        END IF;
     END LOOP;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After 1st Qa Checker '|| l_qa_check_status);
     END IF;

     IF (l_qa_check_status <> 'S') THEN
        RAISE rebook_contract_failed;
     END IF;

     -- R12B Authoring OA Migration
     -- Upfront Tax Calculation has been moved out of QA Checker.
     -- For Mass Rebook, Upfront Tax calculation will not be performed.
     -- The below call will only update the status of the Calculate Upfront Tax
     -- task to Complete.
     OKL_CONTRACT_BOOK_PVT.calculate_upfront_tax(
       p_api_version      =>  1.0,
       p_init_msg_list    =>  OKL_API.G_FALSE,
       x_return_status    =>  x_return_status,
       x_msg_count        =>  x_msg_count,
       x_msg_data         =>  x_msg_data,
       p_chr_id           =>  p_khr_id,
       x_process_status   =>  l_upfront_tax_status);

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       RAISE rebook_contract_failed;
     END IF;

     -- Generate Stream
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Submitting Request to generate Streams....');
     END IF;
     -- Changed to handle internal and external streams as well
     -- Fix Bug#
     --OKL_GENERATE_STREAMS_PUB.GENERATE_STREAMS(
     --
     OKL_LA_STREAM_PUB.GEN_INTR_EXTR_STREAM (
                                               p_api_version         => 1.0,
                                               p_init_msg_list       => OKL_API.G_FALSE,
                                               p_khr_id              => p_khr_id,
                                               p_generation_ctx_code => 'AUTH',
                                               x_trx_number          => x_trx_number,
                                               x_trx_status          => x_trx_status,
                                               x_return_status       => x_return_status,
                                               x_msg_count           => x_msg_count,
                                               x_msg_data            => x_msg_data
                                              );

     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE rebook_contract_failed;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Stream Status :'||x_return_status);
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Trx# : '||x_trx_number);
     END IF;

     g_stream_trx_number := x_trx_number;

     RETURN;

  EXCEPTION

      WHEN rebook_contract_failed THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rebook_contract_failed');
        END IF;
        g_stream_trx_number := NULL;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        --raise; -- propagate error to caller
     WHEN others THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rebook_contract_failed');
        END IF;
        g_stream_trx_number := NULL;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        --raise; -- propagate error to caller

  END rebook_contract;

------------------------------------------------------------------------------
-- PROCEDURE update_mass_rbk_contract
--   Call this process to update selected contracts. This process updates
--   selected_flag and status of contract provided as parameter
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE update_mass_rbk_contract(
                                     p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_mstv_tbl                     IN  MSTV_TBL_TYPE,
                                     x_mstv_tbl                     OUT NOCOPY MSTV_TBL_TYPE
                                    ) IS

  l_api_name    VARCHAR2(35)    := 'update_mass_rbk_contract';
  l_proc_name   VARCHAR2(35)    := 'UPDATE_MASS_RBK_CONTRACT';
  l_api_version NUMBER          := 1.0;

  CURSOR rbk_csr (p_request_name OKL_RBK_SELECTED_CONTRACT.REQUEST_NAME%TYPE,
                  p_chr_id       OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT id
  FROM   okl_rbk_selected_contract
  WHERE  khr_id       = p_chr_id
  AND    request_name = p_request_name;

  l_mstv_upd_tbl mstv_tbl_type;
  x_mstv_upd_tbl mstv_tbl_type;
  l_upd_count    NUMBER := 0;

  update_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_upd_count := 1;
     FOR i IN 1..p_mstv_tbl.COUNT
     LOOP
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ID     :'||p_mstv_tbl(i).id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'KHR_ID :'||p_mstv_tbl(i).khr_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'REQ    :'||p_mstv_tbl(i).request_name);
        END IF;

        FOR rbk_rec IN rbk_csr(p_mstv_tbl(i).request_name,
                               p_mstv_tbl(i).khr_id)
        LOOP
           l_mstv_upd_tbl(l_upd_count).id            := rbk_rec.id;
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'ID     :'||l_mstv_upd_tbl(l_upd_count).id);
           END IF;
           --insert into dd_dummy values (3.1, 'ID: '||l_mstv_upd_tbl(l_upd_count).id);
           l_mstv_upd_tbl(l_upd_count).selected_flag := p_mstv_tbl(i).selected_flag;
           l_mstv_upd_tbl(l_upd_count).status        := p_mstv_tbl(i).status;
           l_upd_count := l_upd_count+ 1;
        END LOOP;
     END LOOP;

     okl_mst_pvt.update_row(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_mstv_tbl      => l_mstv_upd_tbl,
                            x_mstv_tbl      => x_mstv_upd_tbl
                           );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --insert into dd_dummy values (3.2, 'After update');
     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);

     RETURN;

  EXCEPTION
      WHEN update_failed THEN
          x_return_status := OKL_API.G_RET_STS_SUCCESS;

      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END update_mass_rbk_contract;

------------------------------------------------------------------------------
-- PROCEDURE update_trx_asset
--   Call this process to update status (TSU_CODE) of okl_trx_assets_v with
--   p_status.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE update_trx_asset(
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                             p_status        IN  VARCHAR2
                            ) IS
  --Bug# 3521126 :
  /*--modified cursor to change only status of current transaction--
  --CURSOR trx_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  --SELECT txl.tas_id
  --FROM   okl_txl_assets_v txl
  --WHERE  txl.dnz_khr_id = p_chr_id
  --AND    EXISTS (SELECT 'Y'
                 --FROM   okl_trx_assets_v trx
                 --WHERE  trx.id       = txl.tas_id
                 --AND    trx.tsu_code = 'ENTERED');
  ---------------------------------------------------------------*/
  CURSOR trx_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT trx.id
  FROM   okl_trx_assets   trx,
         okl_trx_types_tl ttyp,
         okl_txl_assets_b txl
  WHERE  trx.id         = txl.tas_id
  AND    trx.try_id     = ttyp.id
  AND    trx.tas_type   = 'CRB'
  AND    trx.tsu_code   = 'ENTERED'
  AND    ttyp.name      = 'Rebook'
  AND    ttyp.language  = 'US'
  AND    txl.tal_type   = 'CRB'
  AND    txl.dnz_khr_id = p_chr_id;

  l_thpv_rec   thpv_rec_type;
  x_thpv_rec   thpv_rec_type;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    FOR trx_rec IN trx_csr(p_chr_id)
    LOOP
       l_thpv_rec.id       := trx_rec.id;
       l_thpv_rec.tsu_code := p_status;

       okl_trx_assets_pub.update_trx_ass_h_def(
                                        p_api_version   => 1.0,
                                        p_init_msg_list => OKL_API.G_FALSE,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_thpv_rec      => l_thpv_rec,
                                        x_thpv_rec      => x_thpv_rec
                                       );

    END LOOP;

  END update_trx_asset;

  -- Bug# 4398936
  PROCEDURE  process_securitization_stream(p_chr_id   IN  OKC_K_HEADERS_V.ID%TYPE,
                                           p_rbk_trx_id   IN NUMBER,
                                           x_return_status OUT NOCOPY VARCHAR2,
                                           x_msg_count     OUT NOCOPY NUMBER,
                                           x_msg_data      OUT NOCOPY VARCHAR2)
  IS

    l_api_name    VARCHAR2(35)    := 'process_securitization_stream';
    l_proc_name   VARCHAR2(35)    := 'process_securitization_stream';
    l_api_version CONSTANT NUMBER := 1;

  CURSOR l_okl_trbk_txn_csr
  IS
    SELECT date_transaction_occurred
    FROM   okl_trx_contracts
    WHERE  id   = p_rbk_trx_id;

  CURSOR l_okl_tcn_type_csr
  IS
  SELECT trxp.tcn_type,
         trxp.qte_id,
         trxp.date_transaction_occurred,
         qtev.qtp_code
  FROM   okl_trx_contracts trxp,
         okl_trx_contracts trxc,
         okl_trx_quotes_v qtev
  WHERE  trxp.id = trxc.source_trx_id
  AND    trxc.id = p_rbk_trx_id
  AND    trxc.tsu_code <> 'PROCESSED'
  AND    qtev.id = trxp.qte_id;



    --Bug 6740000 ssdeshpa start
    --Changed Stream Type Subclass to 'INVESTOR_DISBURSEMENT'
    CURSOR disb_strm_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT strm.id
    FROM   okl_streams strm,
           okl_strm_type_v TYPE
    WHERE  TYPE.id                   = strm.sty_id
    AND    TYPE.stream_type_subclass = 'INVESTOR_DISBURSEMENT'
    AND    strm.khr_id               = p_chr_id
    AND    strm.say_code             = 'CURR';
    --Bug 6740000 ssdeshpa End

    CURSOR accu_strm_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT strm.id
    FROM   okl_streams strm,
           okl_strm_type_v TYPE
    WHERE  TYPE.id       = strm.sty_id
    AND    TYPE.stream_type_purpose IN (
                         'INVESTOR_RENTAL_ACCRUAL',
                         'INVESTOR_PRE_TAX_INCOME',
                         'INVESTOR_INTEREST_INCOME',
                         'INVESTOR_VARIABLE_INTEREST'
                        )
    AND    strm.khr_id   = p_chr_id
    AND    strm.say_code = 'CURR';

    CURSOR l_okl_alt_kle_csr(p_qte_id IN NUMBER)
    IS
    SELECT kle_id
    FROM   okl_txl_quote_lines_v
    WHERE  qte_id = p_qte_id
    AND    qlt_code = 'AMCFIA';

    --Bug 6740000 ssdeshpa start
    --Cursor to get the deal Type for Contract
    CURSOR get_deal_type_csr(p_chr_id OKL_K_HEADERS.ID%TYPE)
    IS
     SELECT DEAL_TYPE
     FROM OKL_K_HEADERS
     WHERE ID = p_chr_id;

     l_deal_type OKL_K_HEADERS.DEAL_TYPE%TYPE;
     --Bug 6740000 ssdeshpa End

    i NUMBER := 0;
    l_disb_strm_tbl OKL_STREAMS_PUB.stmv_tbl_type;
    x_disb_strm_tbl OKL_STREAMS_PUB.stmv_tbl_type;

    l_accu_strm_tbl OKL_STREAMS_PUB.stmv_tbl_type;
    x_accu_strm_tbl OKL_STREAMS_PUB.stmv_tbl_type;


    lx_value VARCHAR2(1);
    lx_inv_agmt_chr_id_tbl Okl_Securitization_Pvt.inv_agmt_chr_id_tbl_type;

    secu_failed EXCEPTION;

    --l_stream_type_subclass         okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL;
    l_alt_purchase BOOLEAN := FALSE;

    BEGIN
      IF (G_DEBUG_ENABLED = 'Y') THEN
        G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
      END IF;

      x_return_status := OKC_API.G_RET_STS_SUCCESS;

      --
      -- Check for Securitized Contract
      --
      FOR l_okl_trbk_txn_rec IN l_okl_trbk_txn_csr
      LOOP

      Okl_Securitization_Pvt.check_khr_securitized(
                                                   p_api_version         => 1.0,
                                                   p_init_msg_list       => OKC_API.G_FALSE,
                                                   x_return_status       => x_return_status,
                                                   x_msg_count           => x_msg_count,
                                                   x_msg_data            => x_msg_data,
                                                   p_khr_id              => p_chr_id,
                                                   p_effective_date      => l_okl_trbk_txn_rec.date_transaction_occurred,
                                                   x_value               => lx_value,
                                                   x_inv_agmt_chr_id_tbl => lx_inv_agmt_chr_id_tbl
                                                  );

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         RAISE secu_failed;
      END IF;

      IF (lx_value = OKL_API.G_TRUE) THEN
	      --
	      -- HISTorize disbursement streams, with subclass = 'INVESTOR_DISBURSEMENT'
	      --
	      FOR disb_strm_rec IN disb_strm_csr (p_chr_id)
	      LOOP
		 i := disb_strm_csr%ROWCOUNT;
		 l_disb_strm_tbl(i).id        := disb_strm_rec.id;
		 l_disb_strm_tbl(i).say_code  := 'HIST';
		 l_disb_strm_tbl(i).active_yn := 'N';
     l_disb_strm_tbl(i).date_history  := SYSDATE;
	      END LOOP;

	      IF (l_disb_strm_tbl.COUNT > 0) THEN
		  okl_streams_pub.update_streams(
						 p_api_version    => 1.0,
						 p_init_msg_list  => OKC_API.G_FALSE,
						 x_return_status  => x_return_status,
						 x_msg_count      => x_msg_count,
						 x_msg_data       => x_msg_data,
						 p_stmv_tbl       => l_disb_strm_tbl,
						 x_stmv_tbl       => x_disb_strm_tbl
					       );

		   IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		     RAISE secu_failed;
	    	END IF;
	      END IF;

             FOR l_okl_tcn_type_rec IN l_okl_tcn_type_csr
   	     LOOP

		  IF l_okl_tcn_type_rec.tcn_type = 'ALT' THEN
		    IF l_okl_tcn_type_rec.qtp_code IN (
		             'TER_PURCHASE',       -- Termination - With Purchase
		             'TER_ROLL_PURCHASE',  -- Termination - Rollover To New Contract With Purchase
		             'TER_RECOURSE',       -- Termination - Recourse With Purchase
		             'TER_MAN_PURCHASE'    -- Termination - Manual With Purchase
		            )
		    THEN
		       l_alt_purchase := TRUE;
		    ELSE -- Termination without purchase
		      l_alt_purchase := FALSE;
		    END IF;

	            --Bug 6740000 ssdeshpa Start
                    --get the Deal type for Contract
                    OPEN get_deal_type_csr(p_chr_id);
                    FETCH get_deal_type_csr INTO l_deal_type;
                    CLOSE get_deal_type_csr;
                    --Bug 6740000 ssdeshpa end

	            FOR l_okl_alt_kle_rec IN l_okl_alt_kle_csr(l_okl_tcn_type_rec.qte_id)
		    LOOP

                      --Bug 6740000 ssdeshpa Start
                          IF(l_deal_type IN('LEASEOP','LEASEDF','LEASEST')) THEN
		              Okl_Securitization_Pvt.modify_pool_contents(
								  p_api_version         => 1.0,
								  p_init_msg_list       => OKC_API.G_FALSE,
								  x_return_status       => x_return_status,
								  x_msg_count           => x_msg_count,
								  x_msg_data            => x_msg_data,
								  p_transaction_reason  => Okl_Securitization_Pvt.G_TRX_REASON_ASSET_TERMINATION,
								  p_khr_id              => p_chr_id,
								  p_kle_id              => l_okl_alt_kle_rec.kle_id,
								  p_transaction_date    => l_okl_tcn_type_rec.date_transaction_occurred,
								  p_effective_date      => l_okl_tcn_type_rec.date_transaction_occurred,
                                                                  p_stream_type_subclass => 'RENT'
								 );
			  ELSIF(l_deal_type IN('LOAN', 'LOAN-REVOLVING')) THEN
		              Okl_Securitization_Pvt.modify_pool_contents(
								  p_api_version         => 1.0,
								  p_init_msg_list       => OKC_API.G_FALSE,
								  x_return_status       => x_return_status,
								  x_msg_count           => x_msg_count,
								  x_msg_data            => x_msg_data,
								  p_transaction_reason  => Okl_Securitization_Pvt.G_TRX_REASON_ASSET_TERMINATION,
								  p_khr_id              => p_chr_id,
								  p_kle_id              => l_okl_alt_kle_rec.kle_id,
								  p_transaction_date    => l_okl_tcn_type_rec.date_transaction_occurred,
								  p_effective_date      => l_okl_tcn_type_rec.date_transaction_occurred,
                                                                  p_stream_type_subclass => 'LOAN_PAYMENT'
								 );
                      END IF;
                      --Bug 6740000 ssdeshpa End
		      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			   RAISE secu_failed;
		      END IF;

		      IF l_alt_purchase THEN
			      Okl_Securitization_Pvt.modify_pool_contents(
									  p_api_version         => 1.0,
									  p_init_msg_list       => OKC_API.G_FALSE,
									  x_return_status       => x_return_status,
									  x_msg_count           => x_msg_count,
									  x_msg_data            => x_msg_data,
									  p_transaction_reason  => Okl_Securitization_Pvt.G_TRX_REASON_ASSET_DISPOSAL,
									  p_khr_id              => p_chr_id,
									  p_kle_id              => l_okl_alt_kle_rec.kle_id,
									  p_transaction_date    => l_okl_tcn_type_rec.date_transaction_occurred,
									  p_effective_date      => l_okl_tcn_type_rec.date_transaction_occurred,
									  p_stream_type_subclass => 'RESIDUAL'
									 );
			      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
				 RAISE secu_failed;
			      END IF;
               END IF;

		      END LOOP; -- l_okl_alt_kle_rec

		  END IF; -- 		  l_okl_tcn_type_rec.tcn_type = 'ALT'



	      END LOOP; -- l_okl_tcn_type_csr



   	              --
		      -- Create Pool transaction for Mass Rebook
		      --
		      Okl_Securitization_Pvt.modify_pool_contents(
								  p_api_version         => 1.0,
								  p_init_msg_list       => OKC_API.G_FALSE,
								  x_return_status       => x_return_status,
								  x_msg_count           => x_msg_count,
								  x_msg_data            => x_msg_data,
								  p_transaction_reason  => Okl_Securitization_Pvt.G_TRX_REASON_CONTRACT_REBOOK,
								  p_khr_id              => p_chr_id,
								  p_transaction_date    => l_okl_trbk_txn_rec.date_transaction_occurred,
								  p_effective_date      => l_okl_trbk_txn_rec.date_transaction_occurred
								 );

		      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
    			 RAISE secu_failed;
		      END IF;

-- Bug# 4775555: Start
-- Accrual Streams will now be Historized in OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS
-- This API will create the new accrual streams, link the old and new streams
-- and then Historize the old streams
/*
	      --
	      -- HISTorize accrual streams
	      --
	      FOR accu_strm_rec IN accu_strm_csr (p_chr_id)
	      LOOP
		 i := accu_strm_csr%ROWCOUNT;
		 l_accu_strm_tbl(i).id        := accu_strm_rec.id;
		 l_accu_strm_tbl(i).say_code  := 'HIST';
		 l_accu_strm_tbl(i).active_yn := 'N';
	      END LOOP;

	      IF (l_accu_strm_tbl.COUNT > 0) THEN
		  okl_streams_pub.update_streams(
						 p_api_version    => 1.0,
						 p_init_msg_list  => OKC_API.G_FALSE,
						 x_return_status  => x_return_status,
						 x_msg_count      => x_msg_count,
						 x_msg_data       => x_msg_data,
						 p_stmv_tbl       => l_accu_strm_tbl,
						 x_stmv_tbl       => x_accu_strm_tbl
					       );

		IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		   RAISE secu_failed;
		END IF;
	      END IF;
*/
-- Bug# 4775555: End

	      --
	      -- Regenerate disbursement streams
	      --
	      okl_stream_generator_pvt.create_disb_streams(
							   p_api_version         => 1.0,
							   p_init_msg_list       => OKC_API.G_FALSE,
							   x_return_status       => x_return_status,
							   x_msg_count           => x_msg_count,
							   x_msg_data            => x_msg_data,
							   p_contract_id         => p_chr_id
							  );

	      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		 RAISE secu_failed;
	      END IF;

            -- Bug# 4775555
            --
            -- Regenerate Present Value Disbursement streams
            --
            okl_stream_generator_pvt.create_pv_streams(
                                       p_api_version         => 1.0,
                                       p_init_msg_list       => OKC_API.G_FALSE,
                                       x_return_status       => x_return_status,
                                       x_msg_count           => x_msg_count,
                                       x_msg_data            => x_msg_data,
                                       p_contract_id         => p_chr_id
                                       );

            IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE secu_failed;
            END IF;
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After regerating Present Value Disbursement streams');
            END IF;

	      --
	      -- Generate Investor accrual streams
	      --
	      OKL_ACCRUAL_SEC_PVT.CREATE_STREAMS(
						 p_api_version    => 1.0,
						 p_init_msg_list  => OKL_API.G_FALSE,
						 x_return_status  => x_return_status,
						 x_msg_count      => x_msg_count,
						 x_msg_data       => x_msg_data,
						 p_khr_id         => p_chr_id
						);

	      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		 RAISE secu_failed;
	      END IF;


      END IF;
      END LOOP; -- l_okl_trbk_txn_csr
      RETURN;

    EXCEPTION
        WHEN secu_failed THEN
           NULL; -- excception is handled by caller

        WHEN OTHERS THEN
           x_return_status := OKC_API.HANDLE_EXCEPTIONS(
  			p_api_name  => l_api_name,
  			p_pkg_name  => G_PKG_NAME,
  			p_exc_name  => 'OTHERS',
  			x_msg_count => x_msg_count,
  			x_msg_data  => x_msg_data,
  			p_api_type  => G_API_TYPE);

    END process_securitization_stream;
-- Bug# 4398936

-- Bug# 5038395
------------------------------------------------------------------------------
-- PROCEDURE mass_rebook_activate
-- This procedure performs Approval and Activation for Mass rebook. This will
-- be called from mass_rebook_after_yield that is called by Stream generation
-- process after completing stream generation during mass rebook. This procedure
-- will also be called from Submit button on Contract Booking UI if the user
-- is trying to activate a contract for which Mass rebook is in progress.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE mass_rebook_activate(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_chr_id             IN  NUMBER
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'mass_rebook_activate';
  l_proc_name   VARCHAR2(35)    := 'MASS_REBOOK_ACTIVATE';
  l_api_version NUMBER          := 1.0;

  CURSOR check_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT DISTINCT
         A.REQUEST_NAME,
         A.KHR_ID,
         A.TRANSACTION_ID,
         --Bug# 4107330
         A.TRANSACTION_DATE,
         B.MULTI_GAAP_YN,  -- MGAAP 7263041
         C.REPORTING_PDT_ID  -- MGAAP 7263041
  FROM   okl_rbk_selected_contract A,
         okl_k_headers B,
         okl_products C
  WHERE  A.khr_id = p_chr_id
  AND    NVL(A.status,'NEW') = 'UNDER REVISION'
  AND    A.KHR_ID = B.ID -- MGAAP 7263041
  AND    B.PDT_ID = C.ID; -- MGAAP 7263041
  --AND    NVL(status,'NEW') <> 'PROCESSED';


  CURSOR parent_trx_csr (p_trx_id NUMBER) IS
  SELECT source_trx_id, source_trx_type
  FROM   okl_trx_contracts
  WHERE  id        =  p_trx_id
  AND    tsu_code <> 'PROCESSED';

  CURSOR parent_tcn_type_csr (p_trx_id NUMBER) IS
  select tcn_type
  from   okl_trx_contracts
  where id = p_trx_id;

  l_rbk_id             okl_rbk_selected_contract.id%TYPE;
  l_rbk_khr_id         okl_rbk_selected_contract.khr_id%TYPE;
  l_rbk_transaction_id okl_rbk_selected_contract.transaction_id%TYPE;

  -- MGAAP start 7263041
  l_multi_gaap_yn      okl_k_headers.multi_gaap_yn%TYPE;
  l_reporting_pdt_id   okl_products.reporting_pdt_id%TYPE;
  -- MGAAP end 7263041

  --Bug# 4107330
  l_rbk_trx_date       okl_rbk_selected_contract.transaction_date%TYPE;
  l_request_name       okl_rbk_selected_contract.request_name%TYPE;

  l_parent_tcn_type    okl_trx_contracts.tcn_type%TYPE;
  l_mstv_tbl           mstv_tbl_type;
  x_mstv_tbl           mstv_tbl_type;

  l_tcnv_rec           tcnv_rec_type;
  x_tcnv_rec           tcnv_rec_type;

  l_am_tcnv_rec        tcnv_rec_type;
  x_am_tcnv_rec        tcnv_rec_type;

  not_to_process       EXCEPTION;

  -- dedey,Bug#4264314
  lx_trx_number OKL_TRX_CONTRACTS.trx_number%TYPE := null; -- MGAAP 7263041
  l_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;
  -- dedey,Bug#4264314

  --Bug# 4775555
  l_inv_accrual_rec OKL_GENERATE_ACCRUALS_PVT.adjust_accrual_rec_type;
  l_inv_stream_tbl  OKL_GENERATE_ACCRUALS_PVT.stream_tbl_type;

  --Bug# 9191475
  lx_trxnum_tbl      OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;
  l_trxnum_init_tbl  OKL_GENERATE_ACCRUALS_PVT.trxnum_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Check contract for Mass Rebook
     --
     OPEN check_csr(p_chr_id);
     --Bug# 4107330
     FETCH check_csr INTO l_request_name,
                          l_rbk_khr_id,
                          l_rbk_transaction_id,
                          l_rbk_trx_date,
                          l_multi_gaap_yn, -- MGAAP 7263041
                          l_reporting_pdt_id; -- MGAAP 7263041
     IF check_csr%NOTFOUND THEN
        RAISE not_to_process; -- Not a candidate for mass re-book
     END IF;
     CLOSE check_csr;

     --insert into dd_dummy values (1, 'Selected for Mass rebook');

     --
     -- Process after Yield for this contract
     --
     --debug_message('Submit for Approval...');
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Approve Contract...');
     END IF;
     --Bug# 2566822 : Integration with AME/WF for approval
     --okl_contract_book_pub.submit_for_approval(
     okl_contract_book_pvt.approve_contract(
             p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_chr_id
            );

     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

    -- dedey,Bug#4264314

     OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041
     OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
       p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_rbk_khr_id      => p_chr_id,
       p_orig_khr_id     => p_chr_id,
       p_trx_id          => l_rbk_transaction_id,
       p_trx_date        => sysdate, -- 4583578 passing sysdate instead of rebook date
       x_accrual_rec     => l_accrual_rec,
       x_stream_tbl      => l_stream_tbl);

     IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
       RAISE Okl_Api.G_EXCEPTION_ERROR;
     END IF;

    -- dedey,Bug#4264314

      -- Bug# 4398936
      --
      -- Securitization stream processing
      --
      process_securitization_stream(p_chr_id   => p_chr_id,
                                    p_rbk_trx_id   => l_rbk_transaction_id,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Bug# 4398936

     --insert into dd_dummy values (2, 'Approval Done');
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Submit for Activation ...');
     END IF;

     okl_contract_book_pub.activate_contract(
             p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_chr_id
            );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- R12B Authoring OA Migration
     -- Update the status of the Submit Contract task to Complete
     OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
       p_api_version        => p_api_version,
       p_init_msg_list      => p_init_msg_list,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data,
       p_khr_id             => p_chr_id ,
       p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_SUBMIT_CONTRACT,
       p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE);

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --insert into dd_dummy values (3, 'Activation Done');
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Activation Done');
     END IF;

     -- Bug# 4775555: Start
     --
     -- Create Investor Disbursement Adjustment
     --
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call create_inv_disb_adjustment');
     END IF;
     OKL_CONTRACT_REBOOK_PVT.create_inv_disb_adjustment(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_orig_khr_id     => p_chr_id
                         );
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call create_inv_disb_adjustment'||x_return_status);
     END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;
     -- Bug# 4775555: End

     --Bug# 4107330
     -- This call is moved from Okl_Activate_Contract_Pub(OKLPACOB.pls)
     -- as the accrual adjustment api requires the Contract
     -- status to be 'BOOKED' before accrual adjustments can be
     -- generated.

     -- dedey,Bug#4264314

       IF(l_stream_tbl.COUNT>0) THEN
        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_accrual_rec,
          p_stream_tbl     => l_stream_tbl);

      -- dedey,Bug#4264314

        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

      -- dedey,Bug#4264314
      END IF;
      -- dedey,Bug#4264314

     -- MGAAP start 7263041
     IF (l_multi_gaap_yn = 'Y') THEN

       OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS; -- MGAAP 7263041

       OKL_CONTRACT_REBOOK_PVT.calc_accrual_adjustment(
         p_api_version     => p_api_version,
         p_init_msg_list   => p_init_msg_list,
         x_return_status   => x_return_status,
         x_msg_count       => x_msg_count,
         x_msg_data        => x_msg_data,
         p_rbk_khr_id      => p_chr_id,
         p_orig_khr_id     => p_chr_id,
         p_trx_id          => l_rbk_transaction_id,
         p_trx_date        => sysdate, -- 4583578 passing sysdate instead of rebook date
         x_accrual_rec     => l_accrual_rec,
         x_stream_tbl      => l_stream_tbl);

       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS; -- MGAAP 7263041

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

       IF(l_stream_tbl.COUNT>0) THEN
        --Bug# 9191475
        --l_accrual_rec.trx_number := lx_trx_number;

        OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_accrual_rec,
          p_stream_tbl     => l_stream_tbl,
          p_representation_type     => 'SECONDARY');


        IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okl_Api.G_EXCEPTION_ERROR;
        END IF;

      END IF;

     END IF;
     -- MGAAP end 7263041


     -- Bug# 4775555: Start
     --
     -- Create Investor Accrual Adjustment
     --
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call calc_inv_acc_adjustment');
     END IF;
     OKL_CONTRACT_REBOOK_PVT.calc_inv_acc_adjustment(
                         p_api_version     => p_api_version,
                         p_init_msg_list   => p_init_msg_list,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data,
                         p_orig_khr_id     => p_chr_id,
                         p_trx_id          => l_rbk_transaction_id,
                         p_trx_date        => sysdate,
                         x_inv_accrual_rec => l_inv_accrual_rec,
                         x_inv_stream_tbl  => l_inv_stream_tbl
                         );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call calc_inv_acc_adjustment'||x_return_status);
     END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     lx_trx_number := null; -- MGAAP 7263041
     --Bug# 9191475
     lx_trxnum_tbl := l_trxnum_init_tbl;
     IF (l_inv_stream_tbl.COUNT > 0) THEN
       OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data ,
          --Bug# 9191475
          --x_trx_number     => lx_trx_number,
          x_trx_tbl        => lx_trxnum_tbl,
          p_accrual_rec    => l_inv_accrual_rec,
          p_stream_tbl     => l_inv_stream_tbl);

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;
     END IF;
     -- Bug# 4775555: End

     -- MGAAP start 7263041
     IF (l_multi_gaap_yn = 'Y') THEN
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before call calc_inv_acc_adjustment for SECONDARY');
       END IF;

       OKL_STREAMS_SEC_PVT.SET_REPO_STREAMS;
       OKL_CONTRACT_REBOOK_PVT.calc_inv_acc_adjustment(
                           p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_orig_khr_id     => p_chr_id,
                           p_trx_id          => l_rbk_transaction_id,
                           p_trx_date        => sysdate,
                           x_inv_accrual_rec => l_inv_accrual_rec,
                           x_inv_stream_tbl  => l_inv_stream_tbl,
                           p_product_id      => l_reporting_pdt_id
                           );

       OKL_STREAMS_SEC_PVT.RESET_REPO_STREAMS;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After call calc_inv_acc_adjustment'||x_return_status);
       END IF;

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (l_inv_stream_tbl.COUNT > 0) THEN
         --Bug# 9191475
         --l_inv_accrual_rec.trx_number := lx_trx_number;
         OKL_GENERATE_ACCRUALS_PVT.ADJUST_ACCRUALS (
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data ,
            --Bug# 9191475
            --x_trx_number     => lx_trx_number,
            x_trx_tbl        => lx_trxnum_tbl,
            p_accrual_rec    => l_inv_accrual_rec,
            p_stream_tbl     => l_inv_stream_tbl,
            p_representation_type     => 'SECONDARY');

         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
           RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;
       END IF;

     END IF;
     -- MGAAP end 7263041

     --
     -- Update source transaction to PROCESSED, if any
     --
     FOR parent_trx_rec IN parent_trx_csr (l_rbk_transaction_id)
     LOOP

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Source Trx ID: '|| parent_trx_rec.source_trx_id);
        END IF;

        IF (parent_trx_rec.source_trx_id IS NOT NULL) THEN

          begin
            open parent_tcn_type_csr(parent_trx_rec.source_trx_id);
            FETCH parent_tcn_type_csr INTO l_parent_tcn_type;

            IF parent_tcn_type_csr%NOTFOUND THEN
              x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
              CLOSE parent_tcn_type_csr;
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
            CLOSE parent_tcn_type_csr;
          end;

         IF (l_parent_tcn_type = 'PPD') THEN
          --DEBUG
          --
          -- Cancel PPD Amount, if any
          --
           l_am_tcnv_rec.id                      := parent_trx_rec.source_trx_id;
           l_am_tcnv_rec.tsu_code                := 'PROCESSED';

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before update_trx_contracts');
           END IF;

           Okl_Trx_Contracts_Pub.update_trx_contracts(
                                               p_api_version   => l_api_version,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_tcnv_rec      => l_am_tcnv_rec,
                                               x_tcnv_rec      => x_am_tcnv_rec
                                              );

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update_trx_contracts: '||x_return_status);
           END IF;

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
           END IF;

           okl_api.set_message('OKL','AM','Term trx updated', parent_trx_rec.source_trx_id);

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Cancel PPD : '||x_return_status);
          END IF;
          OKL_CS_PRINCIPAL_PAYDOWN_PUB.cancel_ppd(
                                 p_api_version    => 1.0,
                                 p_init_msg_list  => OKL_API.G_FALSE,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 p_khr_id         => p_chr_id
                               );
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cancel PPD : '||x_return_status);
          END IF;

          okl_api.set_message('OKL','AM','After cancel PPD Amount', x_return_status);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
            raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
            raise OKL_API.G_EXCEPTION_ERROR;
          END IF;


          ELSIF (l_parent_tcn_type = 'ALT') THEN
          --ELSE
           l_am_tcnv_rec.id                      := parent_trx_rec.source_trx_id;
           --Bug# 6043327 : R12B SLA impact
           --l_am_tcnv_rec.tsu_code                := 'PROCESSED';
           l_am_tcnv_rec.tmt_status_code                := 'PROCESSED';
           l_am_tcnv_rec.tmt_contract_updated_yn := 'Y';

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'before update_trx_contracts');
           END IF;

           Okl_Trx_Contracts_Pub.update_trx_contracts(
                                               p_api_version   => l_api_version,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_tcnv_rec      => l_am_tcnv_rec,
                                               x_tcnv_rec      => x_am_tcnv_rec
                                              );

           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update_trx_contracts: '||x_return_status);
           END IF;

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
           END IF;

           okl_api.set_message('OKL','AM','Term trx updated', parent_trx_rec.source_trx_id);

           -- Bug 4556370
           -- Cancel Termination Quote, if any
           --
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before Cancel Termination : '||x_return_status);
           END IF;
           OKL_AM_INTEGRATION_PVT.cancel_termination_quotes  (
                                                    p_api_version    => 1.0,
                                                    p_init_msg_list  => OKL_API.G_FALSE,
                                                    p_khr_id         => p_chr_id,
                                                    p_source_trx_id  => parent_trx_rec.source_trx_id,
                                                    p_source         => l_parent_tcn_type, -- 'ALT'
                                                    x_return_status  => x_return_status,
                                                    x_msg_count      => x_msg_count,
                                                    x_msg_data       => x_msg_data
                                                   );
           IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cancel Termination : '||x_return_status);
           END IF;

           okl_api.set_message('OKL','AM','After cancel term quote', x_return_status);

           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
             raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
             raise OKL_API.G_EXCEPTION_ERROR;
           END IF;

         END IF;
        END IF;

     END LOOP;

     --
     -- Update Transaction and Rebook status to PROCESSED
     --

     l_mstv_tbl(1).request_name := l_request_name;
     l_mstv_tbl(1).khr_id       := p_chr_id;
     l_mstv_tbl(1).status       := 'PROCESSED';

     okl_mass_rebook_pvt.update_mass_rbk_contract(
                                                  p_api_version    => l_api_version,
                                                  p_init_msg_list  => OKL_API.G_FALSE,
                                                  x_return_status  => x_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data       => x_msg_data,
                                                  p_mstv_tbl       => l_mstv_tbl,
                                                  x_mstv_tbl       => x_mstv_tbl
                                                 );


     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update_mas_rbk_contract: '||x_return_status);
     END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --insert into dd_dummy values (4, 'update mass rebook status');

     l_tcnv_rec.id       := l_rbk_transaction_id;
     l_tcnv_rec.tsu_code := 'PROCESSED';


     Okl_Trx_Contracts_Pub.update_trx_contracts(
                                               p_api_version   => l_api_version,
                                               p_init_msg_list => OKL_API.G_FALSE,
                                               x_return_status => x_return_status,
                                               x_msg_count     => x_msg_count,
                                               x_msg_data      => x_msg_data,
                                               p_tcnv_rec      => l_tcnv_rec,
                                               x_tcnv_rec      => x_tcnv_rec
                                              );

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'update_trx_contracts : '||x_return_status);
     END IF;

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --insert into dd_dummy values (5, 'update trx status');
     --
     -- Update trx_asset status = 'PROCESSED'
     --
     update_trx_asset(
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      p_status        => 'PROCESSED'
                     );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --insert into dd_dummy values (6, 'update trx asset status');

     --DEBUG
     --IF G_PPD_TRX_ID IS NOT NULL THEN  (To be checked by the API if for PPD)
     BEGIN
       --Create AR invoice for principal amount
       --Call BPD API to create AR journal entries
       OKL_CS_PRINCIPAL_PAYDOWN_PUB.invoice_apply_ppd(
                p_api_version   => l_api_version,
                p_init_msg_list => OKL_API.G_FALSE,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_khr_id        => p_chr_id,
                p_trx_id        => l_rbk_transaction_id );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
       END IF;

       EXCEPTION WHEN OTHERS THEN
         null; -- For any errors during journal creation, we just ignore
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
       END;
     --END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     --insert into dd_dummy values (7, 'returning after yield');
     RETURN;

  EXCEPTION
      WHEN not_to_process THEN
          x_return_status := OKL_API.G_RET_STS_SUCCESS;

      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error...');
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
END mass_rebook_activate;
-- Bug# 5038395

------------------------------------------------------------------------------
-- PROCEDURE mass_rebook_after_yield
--   Call this process after yeild comes back. It will do rest of the mass
--   rebook process. It first checks eligibility of a contract for Mass Rebook
--   and then process the same.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE mass_rebook_after_yield(
                                    p_api_version        IN  NUMBER,
                                    p_init_msg_list      IN  VARCHAR2,
                                    x_return_status      OUT NOCOPY VARCHAR2,
                                    x_msg_count          OUT NOCOPY NUMBER,
                                    x_msg_data           OUT NOCOPY VARCHAR2,
                                    p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE
                                   ) IS

  l_api_name    VARCHAR2(35)    := 'mass_rebook_after_yield';
  l_proc_name   VARCHAR2(35)    := 'MASS_REBOOK_AFTER_YIELD';
  l_api_version NUMBER          := 1.0;

  CURSOR check_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT DISTINCT
         REQUEST_NAME,
         KHR_ID,
         TRANSACTION_ID,
         --Bug# 4107330
         TRANSACTION_DATE
  FROM   okl_rbk_selected_contract
  WHERE  khr_id = p_chr_id
  AND    NVL(status,'NEW') = 'UNDER REVISION';
  --AND    NVL(status,'NEW') <> 'PROCESSED';

  l_rbk_khr_id         okl_rbk_selected_contract.khr_id%TYPE;
  l_rbk_transaction_id okl_rbk_selected_contract.transaction_id%TYPE;
  --Bug# 4107330
  l_rbk_trx_date       okl_rbk_selected_contract.transaction_date%TYPE;
  l_request_name       okl_rbk_selected_contract.request_name%TYPE;

  after_yield_failed   EXCEPTION;
  not_to_process       EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Check contract for Mass Rebook
     --
     OPEN check_csr(p_chr_id);
     --Bug# 4107330
     FETCH check_csr INTO l_request_name,
                          l_rbk_khr_id,
                          l_rbk_transaction_id,
                          l_rbk_trx_date;
     IF check_csr%NOTFOUND THEN
        RAISE not_to_process; -- Not a candidate for mass re-book
     END IF;
     CLOSE check_csr;

     --insert into dd_dummy values (1, 'Selected for Mass rebook');

     -- Bug# 5038395
     -- This procedure will handle approval and activation for
     -- mass rebook
     okl_mass_rebook_pvt.mass_rebook_activate(
             p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_chr_id          => p_chr_id
            );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise after_yield_failed;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise after_yield_failed;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     --insert into dd_dummy values (7, 'returning after yield');
     RETURN;

  EXCEPTION
      WHEN not_to_process THEN
          x_return_status := OKL_API.G_RET_STS_SUCCESS;

      WHEN after_yield_failed THEN

          -- Bug# 5038395
          -- Update status of Submit Contract task to Error
          OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
            p_api_version        => p_api_version,
            p_init_msg_list      => OKL_API.G_FALSE, --To retain message stack
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_khr_id             => p_chr_id ,
            p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_SUBMIT_CONTRACT ,
            p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);

          x_return_status := OKL_API.G_RET_STS_SUCCESS;

      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error...');
         END IF;
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END mass_rebook_after_yield;

------------------------------------------------------------------------------
-- PROCEDURE cancel_transaction
--   Call this process to CANCEL any pending mass rebook transaction
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE cancel_transaction(
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE
                         ) IS

  l_proc_name VARCHAR2(35) := 'CANCEL_TRANSACTION';
  l_api_name  VARCHAR2(35) := 'CANCEL_TRANSACTION';

  CURSOR trx_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT DISTINCT
         REQUEST_NAME,
         KHR_ID,
         TRANSACTION_ID
  FROM   okl_rbk_selected_contract
  WHERE  khr_id            = p_chr_id
  AND    NVL(status,'NEW') <> 'PROCESSED';

  l_mstv_tbl mstv_tbl_type;
  l_tcnv_rec tcnv_rec_type;
  x_mstv_tbl mstv_tbl_type;
  x_tcnv_rec tcnv_rec_type;

  cancel_failed EXCEPTION;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
    END IF;

    FOR trx_rec IN trx_csr (p_chr_id)
    LOOP

       --
       -- Update Transaction and Rebook status to CANCELLED
       --

       l_mstv_tbl(1).request_name := trx_rec.request_name;
       l_mstv_tbl(1).khr_id       := p_chr_id;
       l_mstv_tbl(1).status       := 'CANCELED';

       okl_mass_rebook_pvt.update_mass_rbk_contract(
                                                    p_api_version    => 1.0,
                                                    p_init_msg_list  => OKL_API.G_FALSE,
                                                    x_return_status  => x_return_status,
                                                    x_msg_count      => x_msg_count,
                                                    x_msg_data       => x_msg_data,
                                                    p_mstv_tbl       => l_mstv_tbl,
                                                    x_mstv_tbl       => x_mstv_tbl
                                                   );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE cancel_failed;
       END IF;
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After mass rebook trx update: '||x_return_status);
       END IF;

       l_tcnv_rec.id       := trx_rec.transaction_id;
       l_tcnv_rec.tsu_code := 'CANCELED';

       Okl_Trx_Contracts_Pub.update_trx_contracts(
                                                  p_api_version   => 1.0,
                                                  p_init_msg_list => OKL_API.G_FALSE,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_tcnv_rec      => l_tcnv_rec,
                                                  x_tcnv_rec      => x_tcnv_rec
                                                 );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          RAISE cancel_failed;
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After trx update: '||x_return_status);
       END IF;

    END LOOP;

  EXCEPTION

      when cancel_failed then
         x_return_status := OKL_API.G_RET_STS_ERROR;

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  END cancel_transaction;

------------------------------------------------------------------------------
-- PROCEDURE process_mass_rebook
--   This proecdure applies Rebook when called from On-line user
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE process_mass_rebook(
                                p_api_version        IN  NUMBER,
                                p_init_msg_list      IN  VARCHAR2,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2,
                                p_request_name       IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE
                               ) IS
  l_api_name    VARCHAR2(35)    := 'process_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'PROCESS_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_set_count      NUMBER       := 0;
  l_contract_count NUMBER       := 0;

  l_deprn_method_code VARCHAR2(35) := NULL;
  l_in_service_date   DATE         := NULL;
  l_life_in_months    NUMBER       := NULL;
  l_basic_rate        NUMBER       := NULL;
  l_adjusted_rate     NUMBER       := NULL;
  l_book_type_code    FA_BOOKS.BOOK_TYPE_CODE%TYPE := NULL;

  l_contract_id       NUMBER;
  l_line_count        NUMBER := 0;
  l_prev_contract_id  NUMBER;
  l_kle_id            NUMBER;

   -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
  l_object_version_no OKL_K_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
   -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End

  l_kle_tbl           kle_tbl_type;
  l_strm_lalevl_tbl   strm_lalevl_tbl_type;

  l_transaction_date  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE;

  CURSOR rbk_set_csr (p_req_name VARCHAR2) IS
  SELECT criteria_code,
         criteria_value1,
         set_value
  FROM   okl_mass_rbk_criteria
  WHERE  request_name = p_req_name
  AND    (set_value IS NOT NULL
          OR
          criteria_code = 'BOOK_TYPE_CODE'); -- in order to keep Tax Book as selection crietria

 -- Bug#4542290 - smadhava - 26-AUG-2005 - Modified - Start
  -- Modified cusor to get the object version number of the OKL_K_HEADERS table
  CURSOR rbk_csr (p_req_name VARCHAR2) IS
  SELECT
         rbk.khr_id,
         rbk.contract_number,
         rbk.contract_description,
         rbk.kle_id,
         rbk.transaction_date,
         khr.object_version_number
  FROM   okl_rbk_selected_contract rbk
       , okl_k_headers khr
  WHERE
         rbk.request_name = p_req_name
  AND    rbk.selected_flag = 'Y'
  AND    rbk.transaction_id IS NULL
  AND    khr.id = rbk.khr_id;
 -- Bug#4542290 - smadhava - 26-AUG-2005 - Modified - End

 -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
 l_pdt_params_rec OKL_SETUPPRODUCTS_PUB.pdt_parameters_rec_type;
 lp_khrv_rec       OKL_KHR_PVT.khrv_rec_type;
 lx_khrv_rec       OKL_KHR_PVT.khrv_rec_type;

 -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End
  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;

     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     --
     -- Get SET_VALUE for ALl contracts to be processed
     --

     l_set_count := 0;
     l_deprn_method_code := NULL;
     l_in_service_date   := NULL;
     l_life_in_months    := NULL;
     l_basic_rate        := NULL;
     l_adjusted_rate     := NULL;
     l_book_type_code    := NULL;

     FOR rbk_set_rec IN rbk_set_csr(p_request_name)
     LOOP
        l_set_count := l_set_count + 1;
        IF (rbk_set_rec.criteria_code = 'DEPRN_METHOD_CODE') THEN
            l_deprn_method_code := rbk_set_rec.set_value;
        ELSIF (rbk_set_rec.criteria_code = 'DATE_PLACED_IN_SERVICE') THEN
            l_in_service_date := rbk_set_rec.set_value;
        ELSIF (rbk_set_rec.criteria_code = 'LIFE_IN_MONTHS') THEN
            l_life_in_months := rbk_set_rec.set_value;
        ELSIF (rbk_set_rec.criteria_code = 'BASIC_RATE') THEN
            l_basic_rate := TO_NUMBER(rbk_set_rec.set_value);
        ELSIF (rbk_set_rec.criteria_code = 'ADJUSTED_RATE') THEN
            l_adjusted_rate := TO_NUMBER(rbk_set_rec.set_value);
        ELSIF (rbk_set_rec.criteria_code = 'BOOK_TYPE_CODE') THEN
            l_book_type_code := rbk_set_rec.criteria_value1;        -- For selection only, do not Set value
        ELSE
           okl_api.set_message(
                               G_APP_NAME,
                               G_INVALID_SET_VALUE,
                               'CRIT_CODE',
                               rbk_set_rec.criteria_code
                              );
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

     END LOOP;

     IF (l_set_count = 0) THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_NO_SET_VALUE,
                           'REQ_NAME',
                           P_request_name
                          );
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_contract_count := 0;
     l_line_count     := 0;
     l_prev_contract_id := G_INIT_NUMBER;
     FOR rbk_rec IN rbk_csr(p_request_name)
     LOOP

       -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
       OKL_K_RATE_PARAMS_PVT.get_product(
                p_api_version       => p_api_version,
                p_init_msg_list     => p_init_msg_list,
                x_return_status     => x_return_status,
                x_msg_count         => x_msg_count,
                x_msg_data          => x_msg_data,
                p_khr_id            => rbk_rec.khr_id,
                x_pdt_parameter_rec => l_pdt_params_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End

        l_transaction_date := rbk_rec.transaction_date;

        l_contract_count := l_contract_count + 1;
        IF (l_prev_contract_id = rbk_rec.khr_id
            OR
            l_contract_count = 1) THEN               -- Either same contract or first record
           l_line_count := l_line_count + 1;
           l_kle_tbl(l_line_count).id := rbk_rec.kle_id;
           l_contract_id         := rbk_rec.khr_id;
           l_prev_contract_id    := rbk_rec.khr_id;

           -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
           l_object_version_no := rbk_rec.object_version_number;
           -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End
        ELSE
           -- Call Rebook_Contract
           rebook_contract(
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_online_yn          => 'Y',
                        p_khr_id             => l_contract_id,
                        p_kle_tbl            => l_kle_tbl,         -- FA Line ID
                        p_line_count         => l_line_count,
                        p_request_name       => p_request_name,
                        p_book_type_code     => l_book_type_code,
                        p_deprn_method_code  => l_deprn_method_code,
                        p_in_service_date    => l_in_service_date,
                        p_life_in_months     => l_life_in_months,
                        p_basic_rate         => l_basic_rate,
                        p_adjusted_rate      => l_adjusted_rate,
                        p_residual_value     => NULL,              -- Not for On-Line Rebook
                        p_strm_lalevl_tbl    => l_strm_lalevl_tbl,  -- Not for On-Line Rebook
                        p_transaction_date   => l_transaction_date
                       );
           IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
             raise OKL_API.G_EXCEPTION_ERROR;
           END IF;
           -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
           -- Updating the Last interest calculation date to the rebook
           -- transaction date if the Interest Calc. Basis=REAMORT and
           -- Rev. recognition method=STREAMS
           IF ( l_pdt_params_rec.interest_calculation_basis = G_ICB_REAMORT
              AND l_pdt_params_rec.revenue_recognition_method = G_RRM_STREAMS )
           THEN
            lp_khrv_rec.id := rbk_rec.khr_id;
             -- get the object version number of the record
            lp_khrv_rec.object_version_number := rbk_rec.object_version_number;

             -- Update the last interest calc date field
             lp_khrv_rec.date_last_interim_interest_cal := l_transaction_date;
             OKL_KHR_PVT.update_row(
                       p_api_version     => p_api_version
                     , p_init_msg_list   => p_init_msg_list
                     , x_return_status   => x_return_status
                     , x_msg_count       => x_msg_count
                     , x_msg_data        => x_msg_data
                     , p_khrv_rec        => lp_khrv_rec
                     , x_khrv_rec        => lx_khrv_rec);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF; -- end of check for ICB and RRM
           -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End

           l_line_count := 1; -- Reset for next contract
           l_kle_tbl(l_line_count).id := rbk_rec.kle_id;
           l_contract_id      := rbk_rec.khr_id;
           l_prev_contract_id := rbk_rec.khr_id;

        END IF;
     END LOOP;

     IF (l_contract_count = 0 ) THEN
        okl_api.set_message(
                            G_APP_NAME,
                            G_NO_SEL_CONTRACT,
                            'REQ_NAME',
                            p_request_name
                           );
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     -- Final Call for last contract
     rebook_contract(
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_online_yn          => 'Y',
                        p_khr_id             => l_contract_id,
                        p_kle_tbl            => l_kle_tbl,         -- FA Line ID
                        p_line_count         => l_line_count,
                        p_request_name       => p_request_name,
                        P_book_type_code     => l_book_type_code,
                        p_deprn_method_code  => l_deprn_method_code,
                        p_in_service_date    => l_in_service_date,
                        p_life_in_months     => l_life_in_months,
                        p_basic_rate         => l_basic_rate,
                        p_adjusted_rate      => l_adjusted_rate,
                        p_residual_value     => NULL,             -- Not for On-Line Rebook
                        p_strm_lalevl_tbl    => l_strm_lalevl_tbl, -- Not for On-Line Rebook
                        p_transaction_date   => l_transaction_date
                       );
     IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;
     -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - Start
     -- Updating the Last interest calculation date to the rebook
     -- transaction date if the Interest Calc. Basis=REAMORT and
     -- Rev. recognition method=STREAMS
     IF ( l_pdt_params_rec.interest_calculation_basis = G_ICB_REAMORT
        AND l_pdt_params_rec.revenue_recognition_method = G_RRM_STREAMS )
     THEN
      lp_khrv_rec.id := l_contract_id;
       -- get the object version number of the record
       lp_khrv_rec.object_version_number := l_object_version_no;

       -- Update the last interest calc date field
       lp_khrv_rec.date_last_interim_interest_cal := l_transaction_date;
       OKL_KHR_PVT.update_row(
                  p_api_version     => p_api_version
                , p_init_msg_list   => p_init_msg_list
                , x_return_status   => x_return_status
                , x_msg_count       => x_msg_count
                , x_msg_data        => x_msg_data
                , p_khrv_rec        => lp_khrv_rec
                , x_khrv_rec        => lx_khrv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF; -- end of check for ICB and RRM
     -- Bug#4542290 - smadhava - 26-AUG-2005 - Added - End

    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                         x_msg_data    => x_msg_data);

    RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END process_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts. It should be called
--   by those who does not have access to MASS REBOOK UI under OKL
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type
                             ) IS
  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Count: '||p_rbk_tbl.COUNT);
     END IF;

     IF (p_rbk_tbl.COUNT > 0 ) THEN
       l_line_count := 0;
       l_contract_count := 0;
       l_prev_contract_id := G_INIT_NUMBER;
       FOR i IN 1..p_rbk_tbl.COUNT
       LOOP
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract# :'||p_rbk_tbl(i).contract_number);
          END IF;
          l_contract_count := l_contract_count + 1;
          IF (l_prev_contract_id = p_rbk_tbl(i).khr_id
              OR
              l_contract_count = 1) THEN
             l_line_count := l_line_count + 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id := p_rbk_tbl(i).khr_id;
             l_prev_contract_id := p_rbk_tbl(i).khr_id; --Bug# 2579620
          ELSE
             -- Call Rebook_Contract
             rebook_contract(
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_online_yn          => 'N',
                          p_khr_id             => l_contract_id,
                          p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                          p_line_count         => l_line_count,
                          p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                          p_book_type_code     => NULL,
                          p_deprn_method_code  => p_deprn_method_code,
                          p_in_service_date    => p_in_service_date,
                          p_life_in_months     => p_life_in_months,
                          p_basic_rate         => p_basic_rate,
                          p_adjusted_rate      => p_adjusted_rate,
                          p_residual_value     => p_residual_value,
                          p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                         );
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;
             l_line_count := 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id         := p_rbk_tbl(i).khr_id;
          END IF;
       END LOOP;

       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => l_contract_id,
                       p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => p_deprn_method_code,
                       p_in_service_date    => p_in_service_date,
                       p_life_in_months     => p_life_in_months,
                       p_basic_rate         => p_basic_rate,
                       p_adjusted_rate      => p_adjusted_rate,
                       p_residual_value     => p_residual_value,
                       p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rebook Contract status: '||x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Nothing to Process...');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts. It should be called
--   by those who does not have access to MASS REBOOK UI under OKL.
--   This process is overloaded from previous one to return stream transactio ID
--   to caller program
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              x_stream_trx_tbl     OUT NOCOPY strm_trx_tbl_type
                             ) IS
  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Count: '||p_rbk_tbl.COUNT);
     END IF;

     IF (p_rbk_tbl.COUNT > 0 ) THEN
       l_line_count := 0;
       l_contract_count := 0;
       l_prev_contract_id := G_INIT_NUMBER;
       FOR i IN 1..p_rbk_tbl.COUNT
       LOOP
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract# :'||p_rbk_tbl(i).contract_number);
          END IF;
          l_contract_count := l_contract_count + 1;
          IF (l_prev_contract_id = p_rbk_tbl(i).khr_id
              OR
              l_contract_count = 1) THEN
             l_line_count := l_line_count + 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id := p_rbk_tbl(i).khr_id;
             l_prev_contract_id := p_rbk_tbl(i).khr_id; --Bug# 2579620
          ELSE
             -- Call Rebook_Contract
             rebook_contract(
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_online_yn          => 'N',
                          p_khr_id             => l_contract_id,
                          p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                          p_line_count         => l_line_count,
                          p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                          p_book_type_code     => NULL,
                          p_deprn_method_code  => p_deprn_method_code,
                          p_in_service_date    => p_in_service_date,
                          p_life_in_months     => p_life_in_months,
                          p_basic_rate         => p_basic_rate,
                          p_adjusted_rate      => p_adjusted_rate,
                          p_residual_value     => p_residual_value,
                          p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                         );

             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             x_stream_trx_tbl(l_contract_count).chr_id     := l_contract_id;
             x_stream_trx_tbl(l_contract_count).trx_number := g_stream_trx_number;

             l_line_count := 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id         := p_rbk_tbl(i).khr_id;

          END IF;
       END LOOP;

       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => l_contract_id,
                       p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => p_deprn_method_code,
                       p_in_service_date    => p_in_service_date,
                       p_life_in_months     => p_life_in_months,
                       p_basic_rate         => p_basic_rate,
                       p_adjusted_rate      => p_adjusted_rate,
                       p_residual_value     => p_residual_value,
                       p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rebook Contract status: '||x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --l_contract_count := l_contract_count + 1;
       x_stream_trx_tbl(l_contract_count).chr_id     := l_contract_id;
       x_stream_trx_tbl(l_contract_count).trx_number := g_stream_trx_number;

     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Nothing to Process...');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts. It should be called
--   by those who does not have access to MASS REBOOK UI under OKL.
--   This process is overloaded from previous one to return stream transactio ID
--   to caller program
--
--   Adding p_transaction_date parameter, if not provided, system
--   will pass SYSDATE to downstream processes
-- Calls:
-- Called by:
------------------------------------------------------------------------------

  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                              x_stream_trx_tbl     OUT NOCOPY strm_trx_tbl_type
                             ) IS
  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Count: '||p_rbk_tbl.COUNT);
     END IF;

     IF (p_rbk_tbl.COUNT > 0 ) THEN
       l_line_count := 0;
       l_contract_count := 0;
       l_prev_contract_id := G_INIT_NUMBER;
       FOR i IN 1..p_rbk_tbl.COUNT
       LOOP
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Contract# :'||p_rbk_tbl(i).contract_number);
          END IF;
          l_contract_count := l_contract_count + 1;
          IF (l_prev_contract_id = p_rbk_tbl(i).khr_id
              OR
              l_contract_count = 1) THEN
             l_line_count := l_line_count + 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id := p_rbk_tbl(i).khr_id;
             l_prev_contract_id := p_rbk_tbl(i).khr_id; --Bug# 2579620
          ELSE
             -- Call Rebook_Contract
             rebook_contract(
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_online_yn          => 'N',
                          p_khr_id             => l_contract_id,
                          p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                          p_line_count         => l_line_count,
                          p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                          p_book_type_code     => NULL,
                          p_deprn_method_code  => p_deprn_method_code,
                          p_in_service_date    => p_in_service_date,
                          p_life_in_months     => p_life_in_months,
                          p_basic_rate         => p_basic_rate,
                          p_adjusted_rate      => p_adjusted_rate,
                          p_residual_value     => p_residual_value,
                          p_strm_lalevl_tbl    => p_strm_lalevl_tbl,
                          p_transaction_date   => p_transaction_date
                         );

             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             x_stream_trx_tbl(l_contract_count).chr_id     := l_contract_id;
             x_stream_trx_tbl(l_contract_count).trx_number := g_stream_trx_number;

             l_line_count := 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id         := p_rbk_tbl(i).khr_id;

          END IF;
       END LOOP;

       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => l_contract_id,
                       p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => p_deprn_method_code,
                       p_in_service_date    => p_in_service_date,
                       p_life_in_months     => p_life_in_months,
                       p_basic_rate         => p_basic_rate,
                       p_adjusted_rate      => p_adjusted_rate,
                       p_residual_value     => p_residual_value,
                       p_strm_lalevl_tbl    => p_strm_lalevl_tbl,
                       p_transaction_date   => p_transaction_date
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rebook Contract status: '||x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --l_contract_count := l_contract_count + 1;
       x_stream_trx_tbl(l_contract_count).chr_id     := l_contract_id;
       x_stream_trx_tbl(l_contract_count).trx_number := g_stream_trx_number;

     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Nothing to Process...');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts.
--   This has been overloaded for following specific purpose:
--   1. To get termination transaction ID (p_source_trx_id)
--   2. Use this ID to update transaction after successful completion of Mass rebook
--   3. To accept source transaction type (p_source_trx_type)
--   4. Return Mass rebook transaction id to caller (x_mass_rebook_trx_id)
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
                              p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
                              x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE
                             ) IS

  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  l_tcnv_rec tcnv_rec_type;
  x_tcnv_rec tcnv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->Count: '||p_rbk_tbl.COUNT);
     END IF;

     IF (p_rbk_tbl.COUNT > 0 ) THEN
       l_line_count := 0;
       l_contract_count := 0;
       l_prev_contract_id := G_INIT_NUMBER;
       FOR i IN 1..p_rbk_tbl.COUNT
       LOOP
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->Contract# :'||p_rbk_tbl(i).contract_number);
          END IF;
          l_contract_count := l_contract_count + 1;
          IF (l_prev_contract_id = p_rbk_tbl(i).khr_id
              OR
              l_contract_count = 1) THEN
             l_line_count := l_line_count + 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id := p_rbk_tbl(i).khr_id;
             l_prev_contract_id := p_rbk_tbl(i).khr_id; --Bug# 2579620
          ELSE
             --
             -- Restart termination process
             -- cancel any ongoing transaction, if any
             --
             cancel_transaction(
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_chr_id         => l_contract_id
                               );

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After cancel_transaction: '||x_return_status);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             G_TERMINATION_TRX_ID   := p_source_trx_id;
             G_TERMINATION_TRX_TYPE := p_source_trx_type;
             G_MASS_RBK_TRX_ID      := NULL;

             okl_api.set_message('OKL', 'AM', 'Before Term Trx ID: ', G_TERMINATION_TRX_ID);

             -- Call Rebook_Contract
             rebook_contract(
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_online_yn          => 'N',
                          p_khr_id             => l_contract_id,
                          p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                          p_line_count         => l_line_count,
                          p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                          p_book_type_code     => NULL,
                          p_deprn_method_code  => p_deprn_method_code,
                          p_in_service_date    => p_in_service_date,
                          p_life_in_months     => p_life_in_months,
                          p_basic_rate         => p_basic_rate,
                          p_adjusted_rate      => p_adjusted_rate,
                          p_residual_value     => p_residual_value,
                          p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                         );
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After rebook_contract: '||x_return_status);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             x_mass_rebook_trx_id := G_MASS_RBK_TRX_ID;

             l_line_count := 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id         := p_rbk_tbl(i).khr_id;
          END IF;
       END LOOP;

       --
       -- Restart termination process
       -- cancel any ongoing transaction, if any
       --
       cancel_transaction(
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_chr_id         => l_contract_id
                         );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After cancel_transaction: '||x_return_status);
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;


       G_TERMINATION_TRX_ID   := p_source_trx_id;
       G_TERMINATION_TRX_TYPE := p_source_trx_type;
       G_MASS_RBK_TRX_ID      := NULL;

       okl_api.set_message('OKL', 'AM', 'Before Term Trx ID: ', G_TERMINATION_TRX_ID);

       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => l_contract_id,
                       p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => p_deprn_method_code,
                       p_in_service_date    => p_in_service_date,
                       p_life_in_months     => p_life_in_months,
                       p_basic_rate         => p_basic_rate,
                       p_adjusted_rate      => p_adjusted_rate,
                       p_residual_value     => p_residual_value,
                       p_strm_lalevl_tbl    => p_strm_lalevl_tbl
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->rebook Contract status: '||x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       x_mass_rebook_trx_id := G_MASS_RBK_TRX_ID;

     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Nothing to Process...');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts.
--   This has been overloaded for following specific purpose:
--   1. To accept transaction date from calling process, This date is going to
--      be used for accounting too.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE apply_mass_rebook(
                              p_api_version        IN  NUMBER,
                              p_init_msg_list      IN  VARCHAR2,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_msg_count          OUT NOCOPY NUMBER,
                              x_msg_data           OUT NOCOPY VARCHAR2,
                              p_rbk_tbl            IN  rbk_tbl_type,
                              p_deprn_method_code  IN  FA_BOOKS.DEPRN_METHOD_CODE%TYPE,
                              p_in_service_date    IN  FA_BOOKS.DATE_PLACED_IN_SERVICE%TYPE,
                              p_life_in_months     IN  FA_BOOKS.LIFE_IN_MONTHS%TYPE,
                              p_basic_rate         IN  FA_BOOKS.BASIC_RATE%TYPE,
                              p_adjusted_rate      IN  FA_BOOKS.ADJUSTED_RATE%TYPE,
                              p_residual_value     IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
                              p_strm_lalevl_tbl    IN  strm_lalevl_tbl_type,
                              p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
                              p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
                              p_transaction_date   IN  OKL_RBK_SELECTED_CONTRACT.TRANSACTION_DATE%TYPE,
                              x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE
                             ) IS

  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  l_tcnv_rec tcnv_rec_type;
  x_tcnv_rec tcnv_rec_type;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->Count: '||p_rbk_tbl.COUNT);
     END IF;

     IF (p_rbk_tbl.COUNT > 0 ) THEN
       l_line_count := 0;
       l_contract_count := 0;
       l_prev_contract_id := G_INIT_NUMBER;
       FOR i IN 1..p_rbk_tbl.COUNT
       LOOP
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->Contract# :'||p_rbk_tbl(i).contract_number);
          END IF;
          l_contract_count := l_contract_count + 1;
          IF (l_prev_contract_id = p_rbk_tbl(i).khr_id
              OR
              l_contract_count = 1) THEN
             l_line_count := l_line_count + 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id := p_rbk_tbl(i).khr_id;
             l_prev_contract_id := p_rbk_tbl(i).khr_id; --Bug# 2579620
          ELSE
             --
             -- Restart termination process
             -- cancel any ongoing transaction, if any
             --
             cancel_transaction(
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_chr_id         => l_contract_id
                               );

             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After cancel_transaction: '||x_return_status);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             G_TERMINATION_TRX_ID   := p_source_trx_id;
             G_TERMINATION_TRX_TYPE := p_source_trx_type;
             G_MASS_RBK_TRX_ID      := NULL;

             okl_api.set_message('OKL', 'AM', 'Before Term Trx ID: ', G_TERMINATION_TRX_ID);

             -- Call Rebook_Contract
             rebook_contract(
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_online_yn          => 'N',
                          p_khr_id             => l_contract_id,
                          p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                          p_line_count         => l_line_count,
                          p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                          p_book_type_code     => NULL,
                          p_deprn_method_code  => p_deprn_method_code,
                          p_in_service_date    => p_in_service_date,
                          p_life_in_months     => p_life_in_months,
                          p_basic_rate         => p_basic_rate,
                          p_adjusted_rate      => p_adjusted_rate,
                          p_residual_value     => p_residual_value,
                          p_strm_lalevl_tbl    => p_strm_lalevl_tbl,
                          p_transaction_date   => p_transaction_date
                         );
             IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After rebook_contract: '||x_return_status);
             END IF;
             IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
               raise OKL_API.G_EXCEPTION_ERROR;
             END IF;

             x_mass_rebook_trx_id := G_MASS_RBK_TRX_ID;

             l_line_count := 1;
             l_kle_tbl(l_line_count).id := p_rbk_tbl(i).kle_id;
             l_contract_id         := p_rbk_tbl(i).khr_id;
          END IF;
       END LOOP;

       --
       -- Restart termination process
       -- cancel any ongoing transaction, if any
       --
       cancel_transaction(
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_chr_id         => l_contract_id
                         );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After cancel_transaction: '||x_return_status);
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;


       G_TERMINATION_TRX_ID   := p_source_trx_id;
       G_TERMINATION_TRX_TYPE := p_source_trx_type;
       G_MASS_RBK_TRX_ID      := NULL;

       okl_api.set_message('OKL', 'AM', 'Before Term Trx ID: ', G_TERMINATION_TRX_ID);

       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => l_contract_id,
                       p_kle_tbl            => l_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => p_deprn_method_code,
                       p_in_service_date    => p_in_service_date,
                       p_life_in_months     => p_life_in_months,
                       p_basic_rate         => p_basic_rate,
                       p_adjusted_rate      => p_adjusted_rate,
                       p_residual_value     => p_residual_value,
                       p_strm_lalevl_tbl    => p_strm_lalevl_tbl,
                       p_transaction_date   => p_transaction_date
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->rebook Contract status: '||x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       x_mass_rebook_trx_id := G_MASS_RBK_TRX_ID;

     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Nothing to Process...');
        END IF;
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE apply_mass_rebook
--   This proecdure uses to apply mass rebook for contracts.
--   This has been overloaded for following specific purpose:
--   1. To accept prescheduled payment amount.
-- Calls:
-- Called by:
------------------------------------------------------------------------------
  PROCEDURE apply_mass_rebook(
     p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2,
     p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
     p_kle_tbl            IN  kle_tbl_type,
     p_source_trx_id      IN  OKL_TRX_CONTRACTS.SOURCE_TRX_ID%TYPE,
     p_source_trx_type    IN  OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE,
     p_transaction_date   IN  OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE,
     x_mass_rebook_trx_id OUT NOCOPY OKL_TRX_CONTRACTS.ID%TYPE,
     p_ppd_amount   IN  NUMBER,
     p_ppd_reason_code   IN  FND_LOOKUPS.LOOKUP_CODE%TYPE,
     p_payment_struc   IN  okl_mass_rebook_pvt.strm_lalevl_tbl_type
  )
IS
  l_api_name    VARCHAR2(35)    := 'apply_mass_rebook';
  l_proc_name   VARCHAR2(35)    := 'APPLY_MASS_REBOOK';
  l_api_version NUMBER          := 1.0;

  l_line_count       NUMBER;
  l_contract_count   NUMBER;
  l_contract_id      NUMBER;
  l_prev_contract_id NUMBER;

  l_kle_tbl          kle_tbl_type;

  l_tcnv_rec tcnv_rec_type;
  x_tcnv_rec tcnv_rec_type;
  l_strm_lalevl_tbl   strm_lalevl_tbl_type;  /* DEBUG */

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
     	                                       p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;


       --
       -- Restart termination process
       -- cancel any ongoing transaction, if any
       --
       cancel_transaction(
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_chr_id         => p_chr_id
                         );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->After cancel_transaction: '||x_return_status);
       END IF;
       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;


       /* DEBUG */
       G_TERMINATION_TRX_ID := NULL;
       G_PPD_TRX_ID   := p_source_trx_id;
       G_PPD_TRX_TYPE := p_source_trx_type;
       G_MASS_RBK_TRX_ID      := NULL;

       --okl_api.set_message('OKL', 'AM', 'Before Term Trx ID: ', G_TERMINATION_TRX_ID);

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling rebook contract...');
       END IF;
       l_line_count := p_kle_tbl.COUNT;
       rebook_contract(
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       p_online_yn          => 'N',
                       p_khr_id             => p_chr_id,
                       p_kle_tbl            => p_kle_tbl,           -- Table of Top Line ID
                       p_line_count         => l_line_count,
                       p_request_name       => NULL,                -- Not a ON-LINE Mass Rebook
                       p_book_type_code     => NULL,
                       p_deprn_method_code  => NULL,
                       p_in_service_date    => NULL,
                       p_life_in_months     => NULL,
                       p_basic_rate         => NULL,
                       p_adjusted_rate      => NULL,
                       p_residual_value     => NULL,
                       p_strm_lalevl_tbl    => p_payment_struc,
                       p_transaction_date   => p_transaction_date
                      );

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'----->rebook Contract status: '||x_return_status);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After rebook contract: x_return_status=' || x_return_status);
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Raising OKL_API.G_RET_STS_UNEXP_ERROR:');
          END IF;
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Raising OKL_API.G_EXCEPTION_ERROR:');
          END IF;
          raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       x_mass_rebook_trx_id := G_MASS_RBK_TRX_ID;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     RETURN;

  EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After HANDLE_EXCEPTIONS: x_return_status='|| x_return_status);
        END IF;

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

  --null;
  return;
  END apply_mass_rebook;

------------------------------------------------------------------------------
-- PROCEDURE create_mass_rbk_set_values
--   This proecdure uses to create set values for  mass rebook request
-- Calls:
-- Called by:
------------------------------------------------------------------------------
    /* Added for CR */
  PROCEDURE create_mass_rbk_set_values(
                                     p_api_version      IN  NUMBER,
                                     p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_msg_count        OUT NOCOPY NUMBER,
                                     x_msg_data         OUT NOCOPY VARCHAR2,
                                     p_request_name     IN  OKL_MASS_RBK_CRITERIA.REQUEST_NAME%TYPE,
                                     p_mrbv_tbl         IN  mrbv_tbl_type,
                                     x_mrbv_tbl         OUT NOCOPY mrbv_tbl_type)
                                      IS

  l_api_name    VARCHAR2(35)    := 'create_mass_rbk_set_values';
  l_proc_name   VARCHAR2(35)    := 'CREATE_MASS_RBK_SET_VALUES';
  l_api_version NUMBER          := 1.0;
  i             INTEGER;
  l_set_value_present VARCHAR2(1) := 'N';

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_proc_name);
     END IF;
     -- call START_ACTIVITY to create savepoint, check compatibility
     -- and initialize message list
     x_return_status := OKL_API.START_ACTIVITY(
                                               p_api_name      => l_api_name,
                                               p_pkg_name      => G_PKG_NAME,
                                               p_init_msg_list => p_init_msg_list,
                                               l_api_version   => l_api_version,
                                               p_api_version   => p_api_version,
                                               p_api_type      => G_API_TYPE,
                                               x_return_status => x_return_status);

     -- check if activity started successfully
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;
     --Validate the Set Values Data
     --Atleast one Set Value should be Present
     FOR i IN p_mrbv_tbl.FIRST..p_mrbv_tbl.LAST
     LOOP
       IF(p_mrbv_tbl.EXISTS(i)) THEN
          IF (p_mrbv_tbl(i).criteria_code = 'LIFE_IN_MONTHS'
             OR
             p_mrbv_tbl(i).criteria_code = 'BASIC_RATE'
             OR
             p_mrbv_tbl(i).criteria_code = 'ADJUSTED_RATE') THEN

           IF (p_mrbv_tbl(i).operand IS NOT NULL
              OR
              p_mrbv_tbl(i).criteria_value1 IS NOT NULL
              OR
              p_mrbv_tbl(i).criteria_value2 IS NOT NULL) THEN
              okl_api.set_message(
                                 G_APP_NAME,
                                 G_INVALID_MATCH_OPTION,
                                 'CRIT_CODE',
                                 p_mrbv_tbl(i).criteria_code
                               );
              RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
        END IF;
        --Check for Data Integrity
        IF(p_mrbv_tbl(i).criteria_code = 'LIFE_IN_MONTHS' AND
           p_mrbv_tbl(i).set_value IS NOT NULL) THEN
           IF(p_mrbv_tbl(i).set_value <= 0 OR TRUNC(p_mrbv_tbl(i).set_value)<>(p_mrbv_tbl(i).set_value)) THEN
              okl_api.set_message(
                                G_APP_NAME,
                                'OKL_CONTRACTS_INVALID_VALUE',
                                'COL_NAME',
                                'LIFE_IN_MONTHS');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        END IF;
        IF(p_mrbv_tbl(i).criteria_code = 'BASIC_RATE' AND
           p_mrbv_tbl(i).set_value IS NOT NULL) THEN
           IF(p_mrbv_tbl(i).set_value <= 0 ) THEN
              okl_api.set_message(
                                G_APP_NAME,
                                'OKL_CONTRACTS_INVALID_VALUE',
                                'COL_NAME',
                                'BASIC_RATE');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        END IF;
        IF(p_mrbv_tbl(i).criteria_code = 'ADJUSTED_RATE' AND
           p_mrbv_tbl(i).set_value IS NOT NULL) THEN
           IF(p_mrbv_tbl(i).set_value <= 0 ) THEN
              okl_api.set_message(
                                G_APP_NAME,
                                'OKL_CONTRACTS_INVALID_VALUE',
                                'COL_NAME',
                                'ADJUSTED_RATE');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

        END IF;
        IF (p_mrbv_tbl(i).set_value IS NOT NULL) THEN
            l_set_value_present := 'Y';
        END IF;

       END IF;
     END LOOP;
     IF (l_set_value_present = 'N') THEN
       okl_api.set_message(
                           G_APP_NAME,
                           G_NO_SET_VALUE,
                           'REQ_NAME',
                           p_request_name
                          );
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    --
    -- Insert Selection criteria
    --
    okl_mrb_pvt.insert_row(
                            p_api_version   => l_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_mrbv_tbl      => p_mrbv_tbl,
                            x_mrbv_tbl      => x_mrbv_tbl
                           );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                          x_msg_data    => x_msg_data);


     EXCEPTION
      when OKL_API.G_EXCEPTION_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After HANDLE_EXCEPTIONS: x_return_status='|| x_return_status);
        END IF;

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => G_PKG_NAME,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => G_API_TYPE);


  END create_mass_rbk_set_values;

END OKL_MASS_REBOOK_PVT;

/
