--------------------------------------------------------
--  DDL for Package Body OKL_AM_VENDOR_RES_SHARE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_VENDOR_RES_SHARE_PVT" AS
/* $Header: OKLRVRSB.pls 120.9 2007/05/18 13:14:24 ansethur noship $ */

  -- *********************
  -- GLOBAL DATASTRUCTURES
  -- *********************

  -- Rec Type to Store Messages
  TYPE msg_rec_type IS RECORD (
           id       NUMBER,  -- Added
           msg      VARCHAR2(2000));

  -- Table Type to Messages Rec
  TYPE msg_tbl_type IS TABLE OF msg_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to Store Message details with IA details
  TYPE message_rec_type  IS RECORD (
           id               NUMBER,
           contract_number  VARCHAR2(300),
           start_date       DATE,
           end_date         DATE,
           status           VARCHAR2(300),
           asset_number     VARCHAR2(300),
           vpa_number       VARCHAR2(300) );

  -- Table Type to Store Recs of Message details with IA details
  TYPE message_tbl_type IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to Store Messages
  TYPE share_rec_type IS RECORD (
           party_id       NUMBER,
           pay_to_site_id NUMBER,
           party_name     VARCHAR2(300),
           share_percent  NUMBER);

  TYPE share_tbl_type IS TABLE OF  share_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to store contract Details
  TYPE kle_rec_type IS RECORD (
           id                NUMBER,
           asset_number      VARCHAR2(300),
           asset_start_date  DATE,
           asset_end_date    DATE,
           asset_sts_code    OKC_K_LINES_B.sts_code%TYPE,
           date_terminated   DATE,
           asset_residual    OKL_K_LINES.residual_value%TYPE,
           khr_id            NUMBER,
           contract_number   OKC_K_HEADERS_B.contract_number%TYPE,
           product_id        NUMBER,
           vpa_id            NUMBER,
           vpa_number        OKC_K_HEADERS_B.contract_number%TYPE,
           retirement_id     NUMBER,
           date_retired      DATE,
           scs_code          OKC_K_HEADERS_B.scs_code%TYPE); -- rmunjulu 4622198

  TYPE kle_tbl_type IS TABLE OF kle_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to store contract Details
  TYPE rpt_rec_type IS RECORD (
           PROGRAM_AGREEMENT VARCHAR2(300),
           ASSET_NUMBER      VARCHAR2(300),
           ASSET_DESCRIPTION VARCHAR2(3000),
           CONTRACT_NUMBER   VARCHAR2(300),
           ASSET_TERMINATION_DATE    DATE,
           VENDOR            VARCHAR2(3000),
           DISPOSITION_DATE  DATE,
           VENDOR_SHARE      VARCHAR2(300));

  TYPE rpt_tbl_type IS TABLE OF rpt_rec_type INDEX BY BINARY_INTEGER;

  -- *********************
  -- GLOBAL MESSAGE CONSTANTS
  -- *********************
  G_INVALID_VALUE  CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN  CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  -- *********************
  -- GLOBAL VARIABLES
  -- *********************
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_AM_VENDOR_RES_SHARE_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1          CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR       CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_API_VERSION         CONSTANT NUMBER        := 1;
  G_MISS_CHAR           CONSTANT VARCHAR2(1)   := OKL_API.G_MISS_CHAR;
  G_MISS_NUM            CONSTANT NUMBER        := OKL_API.G_MISS_NUM;
  G_MISS_DATE           CONSTANT DATE          := OKL_API.G_MISS_DATE;
  G_TRUE                CONSTANT VARCHAR2(1)   := OKL_API.G_TRUE;
  G_FALSE               CONSTANT VARCHAR2(1)   := OKL_API.G_FALSE;
  G_YES                 CONSTANT VARCHAR2(1)   := 'Y';
  G_NO                  CONSTANT VARCHAR2(1)   := 'N';
  G_FIRST               CONSTANT NUMBER        := FND_MSG_PUB.G_FIRST;
  G_NEXT                CONSTANT NUMBER        := FND_MSG_PUB.G_NEXT;
  G_ERROR               VARCHAR2(1) := 'N';
  G_KLE_ENDED_BY_DATE   DATE;
  success_message_table message_tbl_type;
  error_message_table   message_tbl_type;
  l_error_count NUMBER := 1;

  -- *********************
  -- GLOBAL EXCEPTIONS
  -- *********************
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXCEPTION_ERROR EXCEPTION;
  G_EXCEPTION_HALT  EXCEPTION;

  -- *********************
  -- GLOBAL DECLARATIONS
  -- *********************
  msg_lines_table        msg_tbl_type;
  l_success_tbl_index    NUMBER := 1;
  l_error_tbl_index      NUMBER := 1;

  -- Start of comments
  --
  -- Procedure Name : fnd_error_output
  -- Desciption     : Logs the messages in the output log
  -- Business Rules :
  -- Parameters     :
  -- Version  : 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE fnd_output  (
                  p_kle_rec      IN  kle_rec_type,
                  p_control_flag IN  VARCHAR2 ) IS

      lx_error_rec  OKL_API.error_rec_type;
        l_msg_idx     INTEGER := G_FIRST;

  BEGIN

       -- Get the messages in the log
       LOOP

        FND_MSG_PUB.get(
               p_msg_index     => l_msg_idx,
               p_encoded       => G_FALSE,
               p_data          => lx_error_rec.msg_data,
               p_msg_index_out => lx_error_rec.msg_count);

         IF (lx_error_rec.msg_count IS NOT NULL) THEN

                 -- Store the contract id
                 msg_lines_table(l_error_count).id   := p_kle_rec.id;
                 msg_lines_table(l_error_count).msg  := lx_error_rec.msg_data;

                 l_error_count := l_error_count + 1;
         END IF;

        EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
          OR (lx_error_rec.msg_count IS NULL));

        l_msg_idx := G_NEXT;

       END LOOP;


       IF p_control_flag = 'PROCESSED' THEN

          success_message_table(l_success_tbl_index).id              := p_kle_rec.id;
          success_message_table(l_success_tbl_index).contract_number := p_kle_rec.contract_number;
          success_message_table(l_success_tbl_index).start_date      := p_kle_rec.asset_start_date;
          success_message_table(l_success_tbl_index).end_date        := p_kle_rec.asset_end_date;
          success_message_table(l_success_tbl_index).status          := p_kle_rec.asset_sts_code;
          success_message_table(l_success_tbl_index).asset_number    := p_kle_rec.asset_number;
          success_message_table(l_success_tbl_index).vpa_number      := p_kle_rec.vpa_number;
          l_success_tbl_index := l_success_tbl_index + 1;

       ELSE

          error_message_table(l_error_tbl_index).id              := p_kle_rec.id;
          error_message_table(l_error_tbl_index).contract_number := p_kle_rec.contract_number;
          error_message_table(l_error_tbl_index).start_date      := p_kle_rec.asset_start_date;
          error_message_table(l_error_tbl_index).end_date        := p_kle_rec.asset_end_date;
          error_message_table(l_error_tbl_index).status          := p_kle_rec.asset_sts_code;
          error_message_table(l_error_tbl_index).asset_number    := p_kle_rec.asset_number;
          error_message_table(l_error_tbl_index).vpa_number      := p_kle_rec.vpa_number;

          l_error_tbl_index := l_error_tbl_index + 1;

       END IF;

  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

  END fnd_output;

  -- Start of comments
  --
  -- Procedure Name : create_report
  -- Desciption     : Creates the Output and Log Reports
  -- Business Rules :
  -- Parameters     :
  -- Version        : 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE create_report  IS

         i NUMBER;
         j NUMBER;
         k NUMBER;
         l_success NUMBER;
         l_error NUMBER;

         -- Get the  Org Name
         CURSOR org_csr (p_org_id IN NUMBER) IS
            SELECT HOU.name
            FROM   HR_OPERATING_UNITS HOU
            WHERE  HOU.organization_id = p_org_id;

         l_org_id NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();

         l_org_name          VARCHAR2(300);
         l_orcl_logo         VARCHAR2(300);
         l_term_heading      VARCHAR2(300);
         l_set_of_books      VARCHAR2(300);
         l_set_of_books_name VARCHAR2(300);
         l_run_date          VARCHAR2(300);
         l_oper_unit         VARCHAR2(300);
         l_type              VARCHAR2(300);
         l_processed         VARCHAR2(300);
         l_serial            VARCHAR2(300);
         l_k_num             VARCHAR2(300);
         l_start_date        VARCHAR2(300);
         l_end_date          VARCHAR2(300);
         l_status            VARCHAR2(300);
         l_messages          VARCHAR2(300);
         l_eop               VARCHAR2(300);
         l_inv_ended_by      VARCHAR2(300);
         l_inv               VARCHAR2(300);
         l_print             VARCHAR2(1);
         msg_lines_table_index  NUMBER;
         l_vpa_num           VARCHAR2(300);
         l_kle_num           VARCHAR2(300);
         l_residual_shr_success VARCHAR2(300);
         l_residual_shr_error VARCHAR2(300);

  BEGIN

       l_success := success_message_table.COUNT;
       l_error   := error_message_table.COUNT;

       l_orcl_logo      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_ACCT_LEASE_MANAGEMENT');
       l_term_heading   := 'Vendor Residual Share';
       l_set_of_books   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SET_OF_BOOKS');
       l_run_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_RUN_DATE');
       l_oper_unit      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_OPERUNIT');
       l_type           := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_TYPE');
       l_processed      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_PROCESSED_ENTRIES');
       l_serial         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SERIAL_NUMBER');
       l_k_num          := 'Contract Number';
       l_start_date     := 'Asset Start Date';
       l_end_date       := 'Asset End Date';
       l_status         := 'Asset Status';
       l_messages       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_MESSAGES');
       l_eop            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_OF_REPORT');
       l_inv_ended_by   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INV_AGR_ENDED_BY');
       l_inv            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INVALID_TERM_DATE');
       l_vpa_num        := 'Program Agreement';
       l_kle_num        := 'Asset Number';
       l_residual_shr_success   := 'Vendor Residual Share Successful';
       l_residual_shr_error   := 'Vendor Residual Share Errored';

       l_set_of_books_name := OKL_ACCOUNTING_UTIL.get_set_of_books_name (OKL_ACCOUNTING_UTIL.get_set_of_books_id);

       -- Get the Org Name
       FOR org_rec IN org_csr (l_org_id)  LOOP
          l_org_name := org_rec.name;
       END LOOP;

       -- Valid Vendor Prg Chosen
       IF G_ERROR <> 'Y' THEN

       --log
       FND_FILE.put_line(FND_FILE.log, RPAD('=',77,'=' ));
       FND_FILE.put_line(FND_FILE.log, l_type ||
                                          RPAD(' ',40-LENGTH(l_type),' ') ||
                                          l_processed);

       FND_FILE.put_line(FND_FILE.log, RPAD('-',77 ,'-'));

       FND_FILE.put_line(FND_FILE.log, l_residual_shr_success ||
                                          RPAD(' ',40-LENGTH(l_residual_shr_success),' ') ||
                                          l_success);

       FND_FILE.put_line(FND_FILE.log, l_residual_shr_error ||
                                          RPAD(' ',40-LENGTH(l_residual_shr_error),' ') ||
                                          l_error);
       FND_FILE.put_line(FND_FILE.log,'');
       FND_FILE.put_line(FND_FILE.log, RPAD('=',77,'=' ));

       -- output
       FND_FILE.PUT_LINE(FND_FILE.output, RPAD(' ', 128/2-LENGTH(l_orcl_logo)/2, ' ' ) ||
                                          l_orcl_logo);

       FND_FILE.PUT_LINE(FND_FILE.output, RPAD(' ', 128/2-LENGTH(l_term_heading)/2, ' ' ) ||
                                          l_term_heading);

       FND_FILE.put_line(FND_FILE.output, RPAD(' ',128/2-LENGTH(l_term_heading)/2 , ' ' ) ||
                                          RPAD('-',LENGTH(l_term_heading),'-'));

       FND_FILE.put_line(FND_FILE.output, '');

       FND_FILE.put_line(FND_FILE.output, l_set_of_books ||' : '||
                                          l_set_of_books_name ||
                                          RPAD(' ', 128-LENGTH(l_set_of_books)-LENGTH(l_set_of_books_name)-LENGTH(l_run_date)-25, ' ' ) ||
                                          l_run_date  ||' : ' ||
                                          TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'));

       FND_FILE.put_line(FND_FILE.output, l_oper_unit || ' : ' ||
                                          l_org_name);

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');

       FND_FILE.put_line(FND_FILE.output, l_type ||
                                          RPAD(' ',40-LENGTH(l_type),' ') ||
                                          l_processed);

       FND_FILE.put_line(FND_FILE.output, RPAD('-',128 ,'-'));

       FND_FILE.put_line(FND_FILE.output, l_residual_shr_success ||
                                          RPAD(' ',40-LENGTH(l_residual_shr_success),' ') ||
                                          l_success);

       FND_FILE.put_line(FND_FILE.output, l_residual_shr_error ||
                                          RPAD(' ',40-LENGTH(l_residual_shr_error),' ') ||
                                          l_error);

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD('=',128,'=' ));
       FND_FILE.put_line(FND_FILE.output,'');

       -- Print VPAs Terminated Successfully
       IF l_success > 0 THEN

        FND_FILE.put_line(FND_FILE.output, l_residual_shr_success);
        FND_FILE.put_line(FND_FILE.output, RPAD('-',LENGTH(l_residual_shr_success), '-' ));
        FND_FILE.put_line(FND_FILE.output,'');

        l_print := 'N';

        FOR i IN success_message_table.FIRST..success_message_table.LAST LOOP

           IF l_print = 'N' THEN

           FND_FILE.put_line(FND_FILE.output,  l_serial || RPAD(' ',15-LENGTH(l_serial),' ')||
                                               l_kle_num || RPAD(' ',35-LENGTH(l_kle_num),' ')||
                                               l_k_num || RPAD(' ',35-LENGTH(l_k_num),' ')||
                                               l_vpa_num || RPAD(' ',35-LENGTH(l_vpa_num),' ')||
                                               l_start_date||RPAD(' ',20-LENGTH(l_start_date),' ') ||
                                               l_end_date||RPAD(' ',15-LENGTH(l_end_date),' '));

           FND_FILE.put_line(FND_FILE.output,  RPAD('-',LENGTH(l_serial),'-') || RPAD('-',15-LENGTH(l_serial),'-')||
                                               RPAD('-',LENGTH(l_kle_num),'-') || RPAD('-',35-LENGTH(l_kle_num),'-')||
                                               RPAD('-',LENGTH(l_k_num),'-') || RPAD('-',35-LENGTH(l_k_num),'-')||
                                               RPAD('-',LENGTH(l_vpa_num),'-') || RPAD('-',35-LENGTH(l_vpa_num),'-')||
                                               RPAD('-',LENGTH(l_start_date),'-')||RPAD('-',20-LENGTH(l_start_date),'-') ||
                                               RPAD('-',LENGTH(l_end_date),'-')||RPAD('-',15-LENGTH(l_end_date),'-'));

           l_print := 'Y';
           END IF;

           FND_FILE.put_line(FND_FILE.output,  i || RPAD(' ',15-LENGTH(i),' ')||
                                               success_message_table(i).asset_number ||
                                               RPAD(' ',35-LENGTH(success_message_table(i).asset_number),' ')||
                                               success_message_table(i).contract_number ||
                                               RPAD(' ',35-LENGTH(success_message_table(i).contract_number),' ')||
                                               success_message_table(i).vpa_number ||
                                               RPAD(' ',35-LENGTH(success_message_table(i).vpa_number),' ')||
                                               success_message_table(i).start_date||
                                               RPAD(' ',20-LENGTH(success_message_table(i).start_date),' ') ||
                                               success_message_table(i).end_date||
                                               RPAD(' ',15-LENGTH(success_message_table(i).end_date),' '));

      END LOOP;
       END IF;

       FND_FILE.put_line(FND_FILE.output,'');

       -- Print VPAs errored
       IF l_error > 0 THEN

        FND_FILE.put_line(FND_FILE.output, l_residual_shr_error);
        FND_FILE.put_line(FND_FILE.output, RPAD('-',LENGTH(l_residual_shr_error), '-' ));
        FND_FILE.put_line(FND_FILE.output,'');

        -- Initialize the table index
        msg_lines_table_index := 1;

        FOR i IN error_message_table.FIRST..error_message_table.LAST LOOP

           FND_FILE.put_line(FND_FILE.output,  l_serial || RPAD(' ',15-LENGTH(l_serial),' ')||
                                               l_kle_num || RPAD(' ',35-LENGTH(l_kle_num),' ')||
                                               l_k_num || RPAD(' ',35-LENGTH(l_k_num),' ')||
                                               l_vpa_num || RPAD(' ',35-LENGTH(l_vpa_num),' ')||
                                               l_start_date||RPAD(' ',20-LENGTH(l_start_date),' ') ||
                                               l_end_date||RPAD(' ',15-LENGTH(l_end_date),' '));

           FND_FILE.put_line(FND_FILE.output,  RPAD('-',LENGTH(l_serial),'-') || RPAD('-',15-LENGTH(l_serial),'-')||
                                               RPAD('-',LENGTH(l_kle_num),'-') || RPAD('-',35-LENGTH(l_kle_num),'-')||
                                               RPAD('-',LENGTH(l_k_num),'-') || RPAD('-',35-LENGTH(l_k_num),'-')||
                                               RPAD('-',LENGTH(l_vpa_num),'-') || RPAD('-',35-LENGTH(l_vpa_num),'-')||
                                               RPAD('-',LENGTH(l_start_date),'-')||RPAD('-',20-LENGTH(l_start_date),'-') ||
                                               RPAD('-',LENGTH(l_end_date),'-')||RPAD('-',15-LENGTH(l_end_date),'-'));

           FND_FILE.put_line(FND_FILE.output,  i || RPAD(' ',15-LENGTH(i),' ')||
                                               error_message_table(i).asset_number ||
                                               RPAD(' ',35-LENGTH(error_message_table(i).asset_number),' ')||
                                               error_message_table(i).contract_number ||
                                               RPAD(' ',35-LENGTH(error_message_table(i).contract_number),' ')||
                                               error_message_table(i).vpa_number ||
                                               RPAD(' ',35-LENGTH(error_message_table(i).vpa_number),' ')||
                                               error_message_table(i).start_date||
                                               RPAD(' ',20-LENGTH(error_message_table(i).start_date),' ') ||
                                               error_message_table(i).end_date||
                                               RPAD(' ',15-LENGTH(error_message_table(i).end_date),' '));

           FND_FILE.put_line(FND_FILE.output,'');

           FND_FILE.put_line(FND_FILE.output,  RPAD(' ',5,' ') || l_messages || ' :');

           k := 1;
           FOR j IN msg_lines_table_index .. msg_lines_table.LAST LOOP
               IF msg_lines_table(j).id = error_message_table(i).id THEN
                  FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || k || ': ' || msg_lines_table(j).msg);
                  FND_FILE.put_line(FND_FILE.output,'');
                  k := k + 1;
               ELSE
                  msg_lines_table_index := j ;
                  EXIT;
               END IF;

           END LOOP;

           FND_FILE.put_line(FND_FILE.output,'');

      END LOOP;

       END IF;

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD(' ', 53 , ' ' ) || l_eop);

       ELSE

       FND_FILE.put_line(FND_FILE.log,l_processed || ' = 0');
       FND_FILE.put_line(FND_FILE.log,l_inv);

       END IF;
  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

  END create_report;



  -- Start of comments
  --
  -- Procedure Name  : get_residual_share_terms
  -- Description     : procedure to do get residual share terms and residual share formula
  --                   for the contracts program agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE get_residual_share_terms(
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    p_kle_rec        IN   kle_rec_type,
                    x_share_formula  OUT  NOCOPY VARCHAR2,
                    x_share_tbl      OUT  NOCOPY OKL_RULE_PUB.rulv_tbl_type) IS

          l_return_status    VARCHAR2(3) := G_RET_STS_SUCCESS;
          l_rgpv_tbl  okl_rule_pub.rgpv_tbl_type;
          l_rulv_tbl  okl_rule_pub.rulv_tbl_type;
          l_rulv_rec  okl_rule_pub.rulv_rec_type;

          l_api_version  CONSTANT NUMBER := g_api_version;
          l_msg_count  NUMBER  := OKL_API.G_MISS_NUM;
          l_msg_data  VARCHAR2(2000);

          l_rg_count  NUMBER;
          l_rule_count  NUMBER;

          l_no_rule_data  EXCEPTION;
          i NUMBER;

  BEGIN

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                        'Begin(+)');
        END IF;

        -- get rule data
       OKL_RULE_APIS_PUB.get_contract_rgs (
            p_api_version => l_api_version,
            p_init_msg_list => OKL_API.G_FALSE,
            p_chr_id        => p_kle_rec.vpa_id,
            p_cle_id        => NULL,
            p_rgd_code      => 'VGLRS',
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data,
            x_rgpv_tbl      => l_rgpv_tbl,
            x_rg_count      => l_rg_count);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
   RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (NVL (l_rg_count, 0) <> 1) THEN

      -- Unable to complete process due to missing
      -- information (RULE rule in GROUP group)
      OKL_API.set_message (
               p_app_name     => OKL_API.G_APP_NAME,
               p_msg_name     => 'OKL_AM_VRS_NO_RULE_DATA',
               p_token1       => 'GROUP',
               p_token1_value => 'VGLRS',
               p_token2       => 'RULE',
               p_token2_value => 'VGLRSP');

   RAISE l_no_rule_data;
  END IF;

     -- Get vendor share party details -- multiple records
        OKL_RULE_APIS_PUB.get_contract_rules (
         p_api_version   => l_api_version,
         p_init_msg_list => OKL_API.G_FALSE,
         p_rgpv_rec      => l_rgpv_tbl(1),
         p_rdf_code      => 'VGLRSP',
         x_return_status => l_return_status,
         x_msg_count     => l_msg_count,
         x_msg_data      => l_msg_data,
         x_rulv_tbl      => l_rulv_tbl,
         x_rule_count    => l_rule_count);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF (NVL (l_rule_count, 0) = 0 ) THEN

      -- Unable to complete process due to missing
      -- information (RULE rule in GROUP group)
      OKL_API.set_message (
               p_app_name     => OKL_API.G_APP_NAME,
               p_msg_name     => 'OKL_AM_VRS_NO_RULE_DATA',
               p_token1       => 'GROUP',
               p_token1_value => 'VGLRS',
               p_token2       => 'RULE',
               p_token2_value => 'VGLRSP');

     RAISE l_no_rule_data;
     END IF;

        -- get vendor share formula
  OKL_AM_UTIL_PVT.get_rule_record(
            p_rgd_code      => 'VGLRS',
            p_rdf_code      => 'VGLRSF',
            p_chr_id        => p_kle_rec.vpa_id,
            p_cle_id        => NULL,
            p_message_yn    => TRUE,
            x_rulv_rec      => l_rulv_rec,
            x_return_status => l_return_status,
            x_msg_count     => l_msg_count,
            x_msg_data      => l_msg_data);

     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

        -- set return status
        x_return_status    := l_return_status;
        x_share_tbl        := l_rulv_tbl;
        x_share_formula    := l_rulv_rec.rule_information1;

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                         'End(-)');
        END IF;

  EXCEPTION

 WHEN l_no_rule_data THEN

           x_return_status := OKL_API.G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                             'EXP - l_no_rule_data');
           END IF;

      WHEN G_EXCEPTION_ERROR THEN

           x_return_status := OKL_API.G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.get_residual_share_terms.',
                             'EXP - OTHERS');
           END IF;

  END get_residual_share_terms;

  -- Start of comments
  --
  -- Procedure Name  : vendor_share
  -- Description     : procedure to do vendor residual share for each Terminated/Expired eligible asset
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE vendor_share(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_kle_rec        IN   kle_rec_type,
                    p_sys_date       IN   DATE,
                    p_share_tbl      IN   share_tbl_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

        CURSOR get_program_info_csr IS
        SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
               DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
               DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
               DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
               mo_global.get_current_org_id()
        FROM DUAL;

        CURSOR c_app_info IS
        SELECT APPLICATION_ID
        FROM   FND_APPLICATION
        WHERE  APPLICATION_SHORT_NAME = 'OKL' ;

        CURSOR get_pay_to_site_csr (p_party_id NUMBER) IS
        SELECT PAR.pay_site_id,
                     PV.vendor_name
        FROM   OKL_PARTY_PAYMENT_DTLS_V  PAR,
               PO_VENDORS PV,
               PO_VENDOR_SITES_ALL VS
        WHERE  PAR.cpl_id = p_party_id
        AND    PAR.pay_site_id = VS.vendor_site_id(+)
        AND    VS.vendor_id = PV.vendor_id;

        CURSOR get_party_role_csr (p_party_id NUMBER) IS
        SELECT ROL.rle_code party_role
        FROM   OKC_K_PARTY_ROLES_V  ROL
        WHERE  ROL.id = p_party_id;

        l_return_status             VARCHAR2(3) := G_RET_STS_SUCCESS;
        l_msg_tbl                   msg_tbl_type;
        l_api_name                  VARCHAR2(30) := 'do_vendor_share';
        l_api_version               CONSTANT NUMBER := G_API_VERSION;
        l_kle_rec                   kle_rec_type := p_kle_rec;
        l_share_tbl                 okl_rule_pub.rulv_tbl_type;
        l_tapv_rec                  OKL_TAP_PVT.tapv_rec_type ;
        x_tapv_rec                  OKL_TAP_PVT.tapv_rec_type ;
        l_tplv_rec                  OKL_TPL_PVT.tplv_rec_type;
        x_tplv_rec                  OKL_TPL_PVT.tplv_rec_type;

        l_add_params                OKL_EXECUTE_FORMULA_PUB.ctxt_val_tbl_type;
        lp_thpv_rec                 OKL_TRX_ASSETS_PUB.thpv_rec_type;
        lx_thpv_rec                 OKL_TRX_ASSETS_PUB.thpv_rec_type;
        lp_tlpv_rec                 OKL_TXL_ASSETS_PUB.tlpv_rec_type;
        lx_tlpv_rec                 OKL_TXL_ASSETS_PUB.tlpv_rec_type;
        l_share_formula             VARCHAR2(300);
        l_request_id                NUMBER;
        l_program_application_id    NUMBER;
        l_program_id                NUMBER;
        l_program_update_date       DATE;
        l_org_id                    NUMBER;
        l_sty_id                    NUMBER;
        lx_subsidy_amount           NUMBER;
        l_app_id                    NUMBER;
        l_trx_type_id               NUMBER;
        l_residual_shr_try_id       NUMBER;
        l_document_category         VARCHAR2(100):= 'OKL Lease Pay Invoices';
        lx_dbseqnm                  VARCHAR2(2000):= '';
        lx_dbseqid                  NUMBER := NULL;
        l_msg_count                 NUMBER := OKL_API.G_MISS_NUM;
        l_msg_data                  VARCHAR2(2000);
        l_pay_to_site_id            NUMBER;
        l_share_percent             NUMBER;
        l_party_role                VARCHAR2(350);
        l_party_id                  NUMBER;
        l_party_name                VARCHAR2(350);
        l_share_amount              NUMBER;
        l_share_amount_for_party    NUMBER;
        i                           NUMBER;
        l_sob_id                    NUMBER;
        l_trans_meaning             VARCHAR2(3000);
        l_retirement_id             NUMBER;
        l_retirement_date           DATE;

        l_functional_currency_code  VARCHAR2(15);
        l_contract_currency_code    VARCHAR2(15);
        l_currency_conversion_type  VARCHAR2(30);
        l_currency_conversion_rate  NUMBER;
        l_currency_conversion_date  DATE;
        l_converted_amount          NUMBER;

        -- Since we do not use the amount or converted amount
        -- set a hardcoded value for the amount (and pass to to
        -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
        -- conversion values )
        l_hard_coded_amount NUMBER := 100;

      -- rmunjulu 4622198
        l_fact_synd_code FND_LOOKUPS.lookup_code%TYPE;
        l_inv_acct_code OKC_RULES_B.rule_information1%TYPE;

  /*      29-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start Changes */
         l_tplv_tbl       okl_tpl_pvt.tplv_tbl_type ;
         x_tplv_tbl      okl_tpl_pvt.tplv_tbl_type ;
  /*      29-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End Changes */

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                        'Begin(+)');
       END IF;

/*
       -- *************
       -- Check API version, initialize message list and create savepoint
       -- *************
       l_return_status := OKL_API.start_activity(
                                       p_api_name      => l_api_name,
                                       p_pkg_name      => G_PKG_NAME,
                                       p_init_msg_list => p_init_msg_list,
                                       l_api_version   => l_api_version,
                                       p_api_version   => p_api_version,
                                       p_api_type      => '_PVT',
                                       x_return_status => x_return_status);


       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                       'start_activity = '||l_return_status );
       END IF;

       -- Rollback if error setting activity for api
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;
*/
savepoint vend_res_share;
       -- Start processing
       -- get the residual share terms and conditions
       get_residual_share_terms(
                       x_return_status  =>  l_return_status,
                       p_kle_rec        =>  l_kle_rec,
                       x_share_formula  =>  l_share_formula,
                       x_share_tbl      =>  l_share_tbl);

       IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

          -- Message:
          OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VRS_SHARE_TERMS');

          RAISE G_EXCEPTION_ERROR;

       END IF;

       -- raise exception
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
       OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => p_api_version
       ,p_init_msg_list                => OKL_API.G_FALSE
       ,x_return_status                => l_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       ,p_khr_id                       => p_kle_rec.khr_id
       ,p_scs_code                     => p_kle_rec.scs_code
       ,p_trx_date                     => sysdate
       ,x_fact_synd_code               => l_fact_synd_code
       ,x_inv_acct_code                => l_inv_acct_code
       );

       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

    IF l_share_tbl.count > 1 THEN

         l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency();

         -- Get the currency conversion details from ACCOUNTING_Util
         OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id                    => p_kle_rec.khr_id,
                     p_to_currency               => l_functional_currency_code,
                     p_transaction_date          => SYSDATE,
                     p_amount                    => l_hard_coded_amount,
                     x_return_status             => l_return_status,
                     x_contract_currency         => l_contract_currency_code,
                     x_currency_conversion_type  => l_currency_conversion_type,
                     x_currency_conversion_rate  => l_currency_conversion_rate,
                     x_currency_conversion_date  => l_currency_conversion_date,
                     x_converted_amount          => l_converted_amount);

         IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE G_EXCEPTION_ERROR;
         END IF;

         -- Get Application Info
         OPEN c_app_info ;
         FETCH c_app_info INTO l_app_id;
         IF(c_app_info%NOTFOUND) THEN
                   -- Message:
                   OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VRS_APPS_INFO');
                   CLOSE c_app_info ;
                   RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF ;
          CLOSE c_app_info;

          -- get Disbursement transaction type
          OKL_AM_UTIL_PVT.get_transaction_id (
                          p_try_name      => 'Disbursement',
                        x_return_status     => l_return_status,
                          x_try_id          => l_trx_type_id);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                               p_lookup_type    => 'OKL_ACCOUNTING_EVENT_TYPE',
                               p_lookup_code => 'DISBURSEMENT',
                               p_validate_yn    => 'Y');

             OKL_API.set_message(
              p_app_name            => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => l_trans_meaning);

             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF ;

          -- get vendor residual share  transaction type
          OKL_AM_UTIL_PVT.get_transaction_id (
                          p_try_name      => 'Vendor Residual Share',
                        x_return_status     => l_return_status,
                          x_try_id          => l_residual_shr_try_id);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                               p_lookup_type    => 'OKL_ACCOUNTING_EVENT_TYPE',
                               p_lookup_code => 'VENDOR RESIDUAL SHARE',
                               p_validate_yn    => 'Y');

             OKL_API.set_message(
              p_app_name            => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => l_trans_meaning);

             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF ;

       -- get program info
          OPEN get_program_info_csr;
          FETCH get_program_info_csr INTO
                           l_request_id,
                           l_program_application_id,
                           l_program_id,
                           l_program_update_date,
                           l_org_id;
          CLOSE get_program_info_csr;

          -- get stream type id for purpose for the contract
          OKL_STREAMS_UTIL.get_primary_stream_type(
                                       p_khr_id              => l_kle_rec.khr_id,
                                       p_primary_sty_purpose => 'VENDOR_RESIDUAL_SHARING', -- new purpose code
                                       x_return_status       => l_return_status,
                                       x_primary_sty_id      => l_sty_id);

          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;

    -- get set of books id
          l_sob_id := OKL_ACCOUNTING_UTIL.get_set_of_books_id;

          -- DEFAULT SHARE FORMULA
          IF l_share_formula IS NULL THEN
            l_share_formula := 'VENDOR_RESIDUAL_SHARE';
          END IF;

          -- pass retirement transaction id and get the gain/loss for that retirement transaction
          l_add_params(1).name := 'retirement_id';
          l_add_params(1).value := to_char(l_kle_rec.retirement_id);

          -- Evaluate share formula for asset and contract, pass share percent for relevant party
          OKL_AM_UTIL_PVT.get_formula_value (
              p_formula_name         => l_share_formula,
              p_chr_id             => p_kle_rec.khr_id,
              p_cle_id             => p_kle_rec.id,
                 p_additional_parameters => l_add_params,
              x_formula_value         => l_share_amount, -- get back share amt in contract currency
              x_return_status         => l_return_status);

          IF (l_return_status <> G_RET_STS_SUCCESS) THEN

             -- Message:
             OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VRS_SHARE_FORMULA');

          END IF;

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;

          IF (to_number(l_share_amount) = 0 ) THEN

             -- Message:
             OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VRS_SHARE_FORMULA_ZERO');

             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          -- create header transaction record in okl_trx_assets
          lp_thpv_rec.tas_type := 'VRS'; -- new lookup seeded
          lp_thpv_rec.tsu_code := 'PROCESSED';
          lp_thpv_rec.try_id   := l_residual_shr_try_id;
          lp_thpv_rec.date_trans_occurred := sysdate;

          OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                        p_api_version           => p_api_version,
                        p_init_msg_list         => OKL_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_thpv_rec              => lp_thpv_rec,
                        x_thpv_rec              => lx_thpv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
          END IF;

       i := l_share_tbl.FIRST;
       LOOP

             l_party_id       := to_number(l_share_tbl(i).rule_information1);
             l_share_percent  := nvl(to_number(l_share_tbl(i).rule_information2),0);

             -- party role
             OPEN  get_party_role_csr (l_party_id);
             FETCH get_party_role_csr INTO l_party_role;
             CLOSE get_party_role_csr;

          IF l_party_role <> 'LESSOR' THEN -- do not do residual sharing invoicing for LESSOR

               -- get party pay to site id
               OPEN  get_pay_to_site_csr (l_party_id);
               FETCH get_pay_to_site_csr INTO l_pay_to_site_id, l_party_name;
               CLOSE get_pay_to_site_csr;

               IF l_pay_to_site_id IS NULL THEN

                 -- Message: No Pay site defined for Vendor VENDOR_NAME.
                 OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VRS_PAY_SITE_ERROR',
                          p_token1         => 'VENDOR',
                          p_token1_value   => l_party_name);

                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               -- get share amount for the party based on share percent
               l_share_amount_for_party := to_number(l_share_amount) * l_share_percent/100;

                -- Do AP debit/credit memo
                l_tapv_rec.invoice_number := FND_SEQNUM.get_next_sequence
                                                        (appid       =>  l_app_id,
                                                         cat_code    =>  l_document_category,
                                                         sobid       =>  l_sob_id,
                                                         met_code    =>  'A',
                                                         trx_date    =>  SYSDATE,
                                                         dbseqnm     =>  lx_dbseqnm,
                                                         dbseqid     =>  lx_dbseqid);

                l_tapv_rec.amount                   :=  l_share_amount_for_party;
                l_tapv_rec.ipvs_id                  :=  l_pay_to_site_id;
                l_tapv_rec.vendor_id                :=  p_kle_rec.vpa_id;
                l_tapv_rec.sfwt_flag                :=  'N' ;
                l_tapv_rec.trx_status_code          :=  'ENTERED' ;
                l_tapv_rec.currency_code            :=  l_contract_currency_code;
                l_tapv_rec.currency_conversion_type :=  l_currency_conversion_type;
                l_tapv_rec.currency_conversion_rate :=  l_currency_conversion_rate;
                l_tapv_rec.currency_conversion_date :=  l_currency_conversion_date;
                l_tapv_rec.set_of_books_id          :=  l_sob_id;
                l_tapv_rec.try_id                   :=  l_trx_type_id;
                -- sjalasut, assigned khr_id to null at the transaction header level.
                -- changes made as part of OKLR12B disbursements project.
                l_tapv_rec.khr_id                   :=  NULL; -- p_kle_rec.khr_id ;
                l_tapv_rec.invoice_type             :=  'STANDARD';
                l_tapv_rec.workflow_yn              :=  'N';
                l_tapv_rec.consolidate_yn           :=  'N';
                l_tapv_rec.wait_vendor_invoice_yn   :=  'N';
                l_tapv_rec.date_invoiced            :=  SYSDATE;
                l_tapv_rec.date_gl                  :=  SYSDATE;
                l_tapv_rec.date_entered             :=  SYSDATE;
                l_tapv_rec.object_version_number    :=  1;
                l_tapv_rec.request_id               :=  l_request_id;
                l_tapv_rec.program_application_id   :=  l_program_application_id;
                l_tapv_rec.program_id               :=  l_program_id;
                l_tapv_rec.program_update_date      :=  l_program_update_date;
                l_tapv_rec.org_id                   :=  l_org_id;
                --20-NOV-2006 ANSETHUR R12B - LEGAL ENTITY UPTAKE PROJECT
                l_tapv_rec.legal_entity_id          :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_kle_rec.khr_id);

                -- Populate internal AP invoice Lines Record
                -- sjalasut, added code to have khr_id moved to the line level.
                -- changes made as part of OKLR12B disbursements project.
                l_tplv_rec.khr_id                  :=  p_kle_rec.khr_id ;
                l_tplv_rec.amount                  :=  l_share_amount_for_party;
                l_tplv_rec.sty_id                  :=  l_sty_id;
                l_tplv_rec.inv_distr_line_code     :=  'MANUAL';
                l_tplv_rec.line_number             :=  1;
                l_tplv_rec.org_id                  :=  l_tapv_rec.org_id;
                l_tplv_rec.disbursement_basis_code :=  'BILL_DATE';


                /*      29-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT Start changes */

                  l_tplv_tbl(0) := l_tplv_rec;

                  OKL_CREATE_DISB_TRANS_PVT.create_disb_trx(p_api_version
                                            ,p_init_msg_list     => OKL_API.G_FALSE
                                            ,x_return_status     => l_return_status
                                            ,x_msg_count         => x_msg_count
                                            ,x_msg_data          => x_msg_data
                                            ,p_tapv_rec          => l_tapv_rec
                                            ,p_tplv_tbl          => l_tplv_tbl
                                            ,x_tapv_rec          => x_tapv_rec
                                            ,x_tplv_tbl          => x_tplv_tbl
                                            );


                  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                /*      29-JAN-2007  ANSETHUR  BUILD: R12 B DISBURSEMENT End changes */

               -- Insert transaction in transaction tables okl_trx_assets and okl_txl_assets
                lp_tlpv_rec.currency_code          := l_contract_currency_code;
                lp_tlpv_rec.tas_id                 := lx_thpv_rec.id;
                lp_tlpv_rec.kle_id                 := l_kle_rec.id;
                lp_tlpv_rec.line_number            := 1;
                lp_tlpv_rec.tal_type               := 'VRS'; -- new lookup seeded
                lp_tlpv_rec.asset_number           := l_kle_rec.asset_number;
                lp_tlpv_rec.dnz_khr_id             := l_kle_rec.khr_id;
                lp_tlpv_rec.fa_trx_date            := l_kle_rec.date_retired;  -- store disposition date
                lp_tlpv_rec.residual_shr_party_id  := l_party_id; -- new column
                lp_tlpv_rec.residual_shr_amount    := l_share_amount_for_party;  -- new column
                lp_tlpv_rec.retirement_id          := l_kle_rec.retirement_id;  -- new column  store retirement id


                lp_tlpv_rec.original_cost          := 0; -- needed for the TAPI
                lp_tlpv_rec.current_units          := 1; -- needed for the TAPI

                -- insert record in txl lines table
                OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                        p_api_version           => p_api_version,
                        p_init_msg_list         => OKL_API.G_FALSE,
                        x_return_status         => l_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data,
                        p_tlpv_rec              => lp_tlpv_rec,
                        x_tlpv_rec              => lx_tlpv_rec);

                IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                   RAISE G_EXCEPTION_ERROR;
                END IF;

          END IF;
          EXIT WHEN (i = l_share_tbl.LAST);
             i := l_share_tbl.NEXT(i);
       END LOOP;
    END IF;

       -- set return status
       x_return_status := l_return_status;

       -- End Activity
      --OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
/*
            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
*/
rollback to vend_res_share;
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
/*
            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');
*/
rollback to vend_res_share;
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
/*
            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');
*/
rollback to vend_res_share;
           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.vendor_share.',
                             'EXP - OTHERS');
           END IF;

  END vendor_share;

  -- Start of comments
  --
  -- Procedure Name  : do_vendor_share
  -- Description     : Procedure to do vendor share
  --                   Pick assets to do vendor share with following conditions
  --                       Has not been already picked up for vendor residual sharing (check transaction in OKL)
  --                       Has Vendor program attached with residual sharing defined (check contract and vendor program)
  --                       Has terminated or expired (check asset status)
  --                       Has been sold through asset disposal (Term with purchase/remarket/scrap/sale) (check transaction in FA)
  --                       This API will do residual share for the same asset if there is a new retirement transaction (ie multiple shares for multiple partial retirements)
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE do_vendor_share(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

       -- Get the terminated/expired assets for the org which has residual sharing and which have not been picked earlier
       CURSOR get_expired_kle_csr (p_date IN DATE) IS
            SELECT  CLE.id,
                    CLE.name asset_number,
                    CHR.id khr_id,
                    CHR.contract_number contract_number,
                    CLE.start_date,
                    CLE.end_date,
                    CLE.date_terminated,
                    KLE.residual_value,
                    VPA.id vpa_id,
                    VPA.contract_number vpa_number,
                    KHR.pdt_id,
                    RET.retirement_id,
                    RET.date_retired,
                    CHR.scs_code -- rmunjulu 4622198
            FROM    OKC_K_LINES_V CLE,
                    OKL_K_LINES KLE,
           OKC_K_HEADERS_B CHR,
                    OKL_K_HEADERS KHR,
                    OKC_LINE_STYLES_V LSE,
                    OKC_K_HEADERS_B VPA,
                    FA_RETIREMENTS RET,
                    OKX_ASSET_LINES_V OAL
            WHERE   CLE.id = KLE.id
            AND     KHR.id = CHR.id
            AND     KHR.id = CLE.chr_id
            AND     KHR.khr_id IS NOT NULL
            AND     KHR.khr_id = VPA.id -- contract has vendor program attached
            AND     CLE.lse_id = LSE.id
            AND     LSE.lty_code = 'FREE_FORM1' -- pick only financial assets
            AND     CLE.sts_code IN ('TERMINATED','EXPIRED') -- Asset should have been TERMINATED/EXPIRED
            AND     CLE.date_terminated <= TRUNC(p_date)   -- Ended

            AND     OAL.parent_line_id = CLE.id
            AND     OAL.corporate_book IS NOT NULL
            AND     OAL.asset_id = RET.asset_id
            -- AND     RET.status = 'PROCESSED' -- Retirement transaction status is processed -- NOT REQUIRED
            AND     RET.book_type_code = OAL.corporate_book -- For corporate book

            -- Asset is not Securitized is checked once the asset is obtained
            AND     CLE.id NOT IN (-- residual share already done for that retirement transaction
                                   SELECT TAL.kle_id
                                   FROM   OKL_TRX_ASSETS TAS,
                                          OKL_TXL_ASSETS_B TAL
                                   WHERE  TAL.kle_id = CLE.id
                                   AND    TAL.tas_id = TAS.id
                                   AND    TAS.tas_type = 'VRS'
                                   AND    TAL.tal_type = 'VRS'
                                   AND    TAS.tsu_code = 'PROCESSED'

                                   AND    TAL.retirement_id = RET.retirement_id -- do not pick if residual share already done for that retirement trn
                                   )
            AND     1 < ( -- has residual sharing with more than one party (if one party then it is Lessor)
                          SELECT count(rul.rule_information1)
                          FROM   OKC_RULES_V rul,
                                 OKC_RULE_GROUPS_B rgp
                          WHERE  rul.dnz_chr_id = VPA.id
                          AND    rul.rgp_id = rgp.id
                          AND    rgp.rgd_code = 'VGLRS'
                          AND    rul.rule_information_category  = 'VGLRSP'
         );

           CURSOR  get_residual_value_stm_id ( p_kle_id IN NUMBER,
                                         p_sty_id IN NUMBER) IS
           SELECT  STM.id
           FROM    OKL_STREAMS_V STM,
                   OKL_STRM_TYPE_B STY
           WHERE   STM.kle_id   = p_kle_id
           AND     STM.say_code = 'CURR'
           AND     STM.STY_ID   = STY.ID
           AND     STY.ID       = p_sty_id;

        l_return_status    VARCHAR2(3) := G_RET_STS_SUCCESS;
        l_sys_date DATE;
        i NUMBER;
        l_kle_rec kle_rec_type;
        l_share_tbl share_tbl_type;
        TYPE kle_tbl_type IS TABLE OF get_expired_kle_csr%ROWTYPE INDEX BY BINARY_INTEGER;
        l_kle_tbl kle_tbl_type;
        i NUMBER;
        l_api_name VARCHAR2(30) := 'do_vendor_share';
        l_inv_agmt_chr_id_tbl OKL_SECURITIZATION_PVT.inv_agmt_chr_id_tbl_type;
        l_is_securitized VARCHAR2(3) := OKL_API.G_FALSE;
        l_residual_sty_id NUMBER;
        l_inv_agmt_chr_id NUMBER;
        l_residual_stm_id NUMBER;
        l_assets_found VARCHAR2(3) := 'N';
  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_VENDOR_RES_SHARE_PVT.do_write_off_balances.',
                        'Begin(+)');
       END IF;

       SELECT sysdate INTO l_sys_date FROM DUAL;

       -- For Performance :: Do a bulk fetch of all eligible assets into a pl/sql table
       OPEN  get_expired_kle_csr (l_sys_date);
       FETCH get_expired_kle_csr BULK COLLECT INTO l_kle_tbl;
       CLOSE get_expired_kle_csr;

       IF l_kle_tbl.COUNT > 0 THEN

           -- Loop thru the eligible assets
           FOR i IN 1..l_kle_tbl.COUNT LOOP

              l_kle_rec.id := l_kle_tbl(i).id;
              l_kle_rec.asset_number := l_kle_tbl(i).asset_number;
              l_kle_rec.khr_id := l_kle_tbl(i).khr_id;
              l_kle_rec.contract_number := l_kle_tbl(i).contract_number;
              l_kle_rec.asset_start_date := l_kle_tbl(i).start_date;
              l_kle_rec.asset_end_date := l_kle_tbl(i).end_date;
              l_kle_rec.date_terminated := l_kle_tbl(i).date_terminated;
              l_kle_rec.asset_residual := l_kle_tbl(i).residual_value;
              l_kle_rec.vpa_id := l_kle_tbl(i).vpa_id;
              l_kle_rec.vpa_number := l_kle_tbl(i).vpa_number;
              l_kle_rec.product_id := l_kle_tbl(i).pdt_id;
              l_kle_rec.retirement_id := l_kle_tbl(i).retirement_id;
              l_kle_rec.date_retired := l_kle_tbl(i).date_retired;
              l_kle_rec.scs_code := l_kle_tbl(i).scs_code; -- rmunjulu 4622198

              OKL_STREAMS_UTIL.get_primary_stream_type(
                                                   l_kle_rec.khr_id,
                                                   'RESIDUAL_VALUE',
                                                   l_return_status,
                                                   l_residual_sty_id);

              -- get the residual value stm id
     OPEN  get_residual_value_stm_id ( l_kle_rec.id,
                                       l_residual_sty_id);
              FETCH get_residual_value_stm_id INTO l_residual_stm_id;
     CLOSE get_residual_value_stm_id;

              IF l_return_status = OKL_API.G_RET_STS_SUCCESS
              AND l_residual_stm_id IS NOT NULL
              AND l_residual_stm_id <> OKL_API.G_MISS_NUM THEN

        -- Check KLE RESIDUAL Stream HDR securitized
                 OKL_SECURITIZATION_PVT.check_stm_securitized(
                    p_api_version                  => p_api_version,
                    p_init_msg_list                => OKL_API.G_FALSE,
                    x_return_status                => l_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_stm_id                       => l_residual_stm_id,
                    p_effective_date               => sysdate,
                    x_value                        => l_is_securitized);

              END IF;


              -- DO NOT DO VENDOR SHARE IF RESIDUAL SECURITIZED
              IF l_return_status = OKL_API.G_RET_STS_SUCCESS
              AND nvl(l_is_securitized,OKL_API.G_FALSE)= OKL_API.G_FALSE THEN

                    l_assets_found := 'Y';

                    okl_api.init_msg_list(OKL_API.G_TRUE);

                    -- vendor share
                    vendor_share(
                       p_api_version    =>  p_api_version,
                       p_init_msg_list  =>  OKL_API.G_FALSE,
                       x_return_status  =>  l_return_status,
                       x_msg_count      =>  x_msg_count,
                       x_msg_data       =>  x_msg_data,
                       p_kle_rec        =>  l_kle_rec,
                       p_share_tbl      =>  l_share_tbl,
                       p_sys_date       =>  l_sys_date,
                       p_control_flag   =>  p_control_flag);

                    IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
                       fnd_output  (
                         p_kle_rec       => l_kle_rec,
                         p_control_flag  => 'PROCESSED');
                    ELSE

                       fnd_output  (
                         p_kle_rec       => l_kle_rec,
                         p_control_flag  => 'ERROR');
                    END IF;

                    -- Create the Output Report
                    --create_report;

              END IF;

           END LOOP;
           create_report;
       END IF;

       IF l_assets_found = 'N' THEN

         FND_FILE.put_line(FND_FILE.output, ' No Assets Found for Vendor Residual Sharing');
         FND_FILE.put_line(FND_FILE.log, ' No Assets Found for Vendor Residual Sharing');

       END IF;

       -- set return status
       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_VENDOR_RES_SHARE_PVT.do_vendor_share.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.do_vendor_share.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.do_vendor_share.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_VENDOR_RES_SHARE_PVT.do_vendor_share.',
                             'EXP - OTHERS');
           END IF;

  END do_vendor_share;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_vend_res_share_prg
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE concurrent_vend_res_share_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                    p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_kle_id         IN  VARCHAR2 DEFAULT NULL) IS



        l_return_status  VARCHAR2(3);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(2000);
        l_api_version    NUMBER;

  BEGIN

       -- Initialize message list
       OKL_API.init_msg_list('T');

       l_api_version := TO_NUMBER(p_api_version);

       -- Do Vendor Share
       do_vendor_share(
                         p_api_version     =>  l_api_version,
                         p_init_msg_list   =>  p_init_msg_list,
                         x_return_status   =>  l_return_status,
                         x_msg_count       =>  l_msg_count,
                         x_msg_data        =>  l_msg_data,
                         p_control_flag    =>  'BATCH_MULTIPLE');

  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

  END concurrent_vend_res_share_prg;


  -- Start of comments
  --
  -- Procedure Name : create_report_output
  -- Desciption     : Creates the Output and Log for REPORT
  -- Business Rules :
  -- Parameters     :
  -- Version  : 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE create_report_output (p_values rpt_tbl_type) IS

         -- Get the  Org Name
         CURSOR org_csr (p_org_id IN NUMBER) IS
            SELECT HOU.name
            FROM   HR_OPERATING_UNITS HOU
            WHERE  HOU.organization_id = p_org_id;


         l_org_id NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();

         l_org_name          VARCHAR2(300);
         l_orcl_logo         VARCHAR2(300);
         l_term_heading      VARCHAR2(300);
         l_set_of_books      VARCHAR2(300);
         l_set_of_books_name VARCHAR2(300);
         l_run_date          VARCHAR2(300);
         l_oper_unit         VARCHAR2(300);
         l_k_num             VARCHAR2(300);
         l_eop               VARCHAR2(300);
         l_serial            VARCHAR2(300);
         l_vpa_num           VARCHAR2(300);
         l_kle_num           VARCHAR2(300);
         l_num_rows          VARCHAR2(300);
         l_kle_desc          VARCHAR2(300);
         l_kle_term_dt       VARCHAR2(300);
         l_vendor            VARCHAR2(300);
         l_disp_dt           VARCHAR2(300);
         l_vend_share        VARCHAR2(300);

  BEGIN

       l_orcl_logo      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_ACCT_LEASE_MANAGEMENT');
       l_term_heading   := 'OKL Report : Vendor Residual Share Report';
       l_set_of_books   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SET_OF_BOOKS');
       l_run_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_RUN_DATE');
       l_eop            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_OF_REPORT');

       l_oper_unit      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_OPERUNIT');
       l_vpa_num        := 'Program Agreement';
       l_kle_num        := 'Asset Number';
       l_kle_desc       := 'Asset Description';
       l_kle_term_dt    := 'Asset Term Date';
       l_vendor         := 'Vendor';
       l_disp_dt        := 'Disposition Date';
       l_vend_share     := 'Vendor Share';
       l_k_num          := 'Contract Number';
       l_num_rows       := 'Number of Rows';
       l_serial         := 'Serial #';

       l_set_of_books_name := OKL_ACCOUNTING_UTIL.get_set_of_books_name (OKL_ACCOUNTING_UTIL.get_set_of_books_id);

       -- Get the Org Name
       FOR org_rec IN org_csr (l_org_id)  LOOP
          l_org_name := org_rec.name;
       END LOOP;

       --log
       FND_FILE.put_line(FND_FILE.log, RPAD('=',77,'=' ));
--       FND_FILE.put_line(FND_FILE.log,    l_num_rows);-- ||
--                                          --count(p_values));

       FND_FILE.put_line(FND_FILE.log, RPAD('-',77 ,'-'));


       -- output
       FND_FILE.PUT_LINE(FND_FILE.output, RPAD(' ', 128/2-LENGTH(l_orcl_logo)/2, ' ' ) ||
                                          l_orcl_logo);

       FND_FILE.PUT_LINE(FND_FILE.output, RPAD(' ', 128/2-LENGTH(l_term_heading)/2, ' ' ) ||
                                          l_term_heading);

       FND_FILE.put_line(FND_FILE.output, RPAD(' ',128/2-LENGTH(l_term_heading)/2 , ' ' ) ||
                                          RPAD('-',LENGTH(l_term_heading),'-'));

       FND_FILE.put_line(FND_FILE.output, '');

       FND_FILE.put_line(FND_FILE.output, l_set_of_books ||' : '||
                                          l_set_of_books_name ||
                                          RPAD(' ', 128-LENGTH(l_set_of_books)-LENGTH(l_set_of_books_name)-LENGTH(l_run_date)-25, ' ' ) ||
                                          l_run_date  ||' : ' ||
                                          TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'));

       FND_FILE.put_line(FND_FILE.output, l_oper_unit || ' : ' ||
                                          l_org_name ||
                                          RPAD(' ', 128-LENGTH(l_oper_unit)-LENGTH(l_org_name), ' ' ));

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD('=',250,'=' ));
       FND_FILE.put_line(FND_FILE.output,'');


       FND_FILE.put_line(FND_FILE.output,      l_serial || RPAD(' ',15-LENGTH(l_serial),' ')||

                                               l_vpa_num || RPAD(' ',35-LENGTH(l_vpa_num),' ')||

                                               l_kle_num || RPAD(' ',35-LENGTH(l_kle_num),' ')||

                                               l_kle_desc || RPAD(' ',35-LENGTH(l_kle_desc),' ')||

                                               l_k_num || RPAD(' ',35-LENGTH(l_k_num),' ')||

                                               l_kle_term_dt||RPAD(' ',20-LENGTH(l_kle_term_dt),' ') ||

                                               l_vendor||RPAD(' ',35-LENGTH(l_vendor),' ') ||

                                               l_disp_dt||RPAD(' ',20-LENGTH(l_disp_dt),' ') ||

                                               l_vend_share||RPAD(' ',15-LENGTH(l_vend_share),' '));

       FND_FILE.put_line(FND_FILE.output, RPAD('-',250,'-' ));

        FOR i IN p_values.FIRST..p_values.LAST LOOP

           FND_FILE.put_line(FND_FILE.output,  i || RPAD(' ',15-LENGTH(i),' ')||

                                               p_values(i).PROGRAM_AGREEMENT ||
                                               RPAD(' ',35-LENGTH(p_values(i).PROGRAM_AGREEMENT),' ')||

                                               p_values(i).ASSET_NUMBER ||
                                               RPAD(' ',35-LENGTH(p_values(i).ASSET_NUMBER),' ')||

                                               p_values(i).ASSET_DESCRIPTION ||
                                               RPAD(' ',35-LENGTH(p_values(i).ASSET_DESCRIPTION),' ')||

                                               p_values(i).CONTRACT_NUMBER||
                                               RPAD(' ',35-LENGTH(p_values(i).CONTRACT_NUMBER),' ') ||

                                               p_values(i).ASSET_TERMINATION_DATE||
                                               RPAD(' ',20-LENGTH(p_values(i).ASSET_TERMINATION_DATE),' ') ||

                                               p_values(i).VENDOR||
                                               RPAD(' ',35-LENGTH(p_values(i).VENDOR),' ') ||

                                               p_values(i).DISPOSITION_DATE||
                                               RPAD(' ',20-LENGTH(p_values(i).DISPOSITION_DATE),' ') ||

                                               p_values(i).VENDOR_SHARE||
                                               RPAD(' ',15-LENGTH(p_values(i).VENDOR_SHARE),' '));

      END LOOP;

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD(' ', 53 , ' ' ) || l_eop);


  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

  END create_report_output;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_vend_res_share_rpt
  -- Description     : Vendor Residual Share report
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE concurrent_vend_res_share_rpt(
                    errbuf             OUT NOCOPY VARCHAR2,
                    retcode            OUT NOCOPY VARCHAR2,
                    p_api_version      IN  VARCHAR2,
                    p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_asset_number     IN  VARCHAR2 DEFAULT NULL,
                    p_disp_date_from   IN  VARCHAR2 DEFAULT NULL,
                    p_disp_date_to     IN  VARCHAR2 DEFAULT NULL,
                    p_vpa_number       IN  VARCHAR2 DEFAULT NULL,
                    p_asst_end_dt_from IN  VARCHAR2 DEFAULT NULL,
                    p_asst_end_dt_to   IN  VARCHAR2 DEFAULT NULL,
                    p_currency         IN  VARCHAR2 DEFAULT NULL) IS

        CURSOR get_report_details_csr IS
        SELECT VPA.contract_number       PROGRAM_AGREEMENT,
               CLE.name                  ASSET_NUMBER,
               CLE.item_description      ASSET_DESCRIPTION,
               CHR.contract_number       CONTRACT_NUMBER,
               CLE.date_terminated       ASSET_TERMINATION_DATE,
               PPD.vendor_name           VENDOR,
               TAL.fa_trx_date           DISPOSITION_DATE,
               --VPA.contract_number ||' '|| CHR.currency_code  VENDOR_SHARE
               TAL.residual_shr_amount ||' '|| CHR.currency_code  VENDOR_SHARE
        FROM   OKC_K_LINES_V CLE,
               OKC_K_HEADERS_B CHR,
               OKC_K_HEADERS_B VPA,
               OKL_K_HEADERS KHR,
               OKL_TRX_ASSETS TAS,
               OKL_TXL_ASSETS_B TAL,
               OKL_PARTY_PAYMENT_DTLS_UV PPD
        WHERE  TAL.TAS_ID = TAS.ID
        AND    TAS.TAS_TYPE = 'VRS'
        AND    TAL.TAL_TYPE = 'VRS'
        AND    TAL.KLE_ID = CLE.ID
        AND    CLE.CHR_ID = CHR.ID
        AND    CHR.ID = KHR.ID
        AND    KHR.KHR_ID = VPA.ID
        AND    PPD.CPL_ID = TAL.RESIDUAL_SHR_PARTY_ID;

        l_return_status  VARCHAR2(3);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(2000);
        l_api_version    NUMBER;

/*
-- Search based on these fields:
a) Program Agreement Number
b) Asset Number
c) Asset Termination Date - From / To
d) Asset Disposition Date - From / To
e) Currency
-- Display these fields:
program agreement number
a) Asset Number
b) Asset Description
c) Contract Number
d) Asset Termination Date
e) Vendor
f) Disposition Date
g) Vendor Share (of Profit / Loss)
*/

        l_main_sql VARCHAR2(3000);
        l_select_sql_1 VARCHAR2(3000);
        l_select_sql_2 VARCHAR2(3000);
        l_from_sql_1  VARCHAR2(3000);
        l_where_sql_1 VARCHAR2(3000);
        l_where_sql_2 VARCHAR2(3000);
        l_condition_1 VARCHAR2(300);
        l_condition_2 VARCHAR2(300);
        l_condition_3 VARCHAR2(300);
        l_condition_4 VARCHAR2(300);
        l_condition_5 VARCHAR2(300);
        l_condition_6 VARCHAR2(300);
        l_condition_7 VARCHAR2(300);
        l_final VARCHAR2(3);
        l_total_sql VARCHAR2(4000);
        l_result_sql get_report_details_csr%ROWTYPE;
        TYPE CurTyp IS REF CURSOR;
        dynamic_cursor CurTyp;
        l_rpt_tbl rpt_tbl_type;
        i  NUMBER;

        lp_disp_date_from DATE;
        lp_disp_date_to DATE;
        lp_asst_end_dt_from DATE;
        lp_asst_end_dt_to DATE;

  BEGIN

-- select ' a '|| '||' || ' b ' from dual;
-- select ' a '|| '''vrs''' || ' b ' from dual;
-- bad ----->    EXECUTE IMMEDIATE 'DELETE FROM dept WHERE deptno = ' || to_char (my_deptno);
-- good ----> EXECUTE IMMEDIATE 'DELETE FROM dept WHERE deptno = :1' USING my_deptno;

       -- Initialize message list
       OKL_API.init_msg_list('T');

       l_api_version := TO_NUMBER(p_api_version);

        l_select_sql_1 := ' SELECT VPA.contract_number PROGRAM_AGREEMENT,CLE.name ASSET_NUMBER,CLE.item_description ASSET_DESCRIPTION,CHR.contract_number CONTRACT_NUMBER, ';
        l_select_sql_2 := ' CLE.date_terminated ASSET_TERMINATION_DATE,PPD.vendor_name VENDOR, TAL.fa_trx_date, TAL.residual_shr_amount ||' || ''' ''' || '|| TAL.currency_code  VENDOR_SHARE';
        l_from_sql_1   := ' FROM OKC_K_LINES_V CLE,OKC_K_HEADERS_B CHR,OKC_K_HEADERS_B VPA,OKL_K_HEADERS KHR,OKL_TRX_ASSETS TAS,OKL_TXL_ASSETS_B TAL,OKL_PARTY_PAYMENT_DTLS_UV PPD';
        l_where_sql_1  := ' WHERE TAL.TAS_ID = TAS.ID AND TAS.TAS_TYPE = '||'''VRS'''||' AND TAL.TAL_TYPE = '||'''VRS'''||' ';
        l_where_sql_2  := ' AND TAL.KLE_ID = CLE.ID AND CLE.CHR_ID = CHR.ID AND CHR.ID = KHR.ID AND KHR.KHR_ID = VPA.ID AND PPD.CPL_ID = TAL.RESIDUAL_SHR_PARTY_ID ';

        l_total_sql    :=   l_select_sql_1 || l_select_sql_2  ||
                            l_from_sql_1   ||
                            l_where_sql_1  || l_where_sql_2;

        IF p_asset_number IS NOT NULL THEN
           l_condition_1 := ' AND CLE.name like '''||p_asset_number||'%''';
           l_total_sql := l_total_sql || l_condition_1;
        END IF;

        IF p_disp_date_from IS NOT NULL THEN
           lp_disp_date_from := FND_DATE.CANONICAL_TO_DATE(p_disp_date_from);
           l_condition_2 := ' AND trunc(TAL.fa_trx_date) >= to_date('''||lp_disp_date_from||''',''DD-MON-YY'')';
           l_total_sql := l_total_sql || l_condition_2;
        END IF;

        IF p_disp_date_to IS NOT NULL THEN
           lp_disp_date_to := FND_DATE.CANONICAL_TO_DATE(p_disp_date_to);
           l_condition_3 := ' AND trunc(TAL.fa_trx_date) <= to_date('''||lp_disp_date_to||''',''DD-MON-YY'')';
           l_total_sql := l_total_sql || l_condition_3;
        END IF;

        IF p_vpa_number IS NOT NULL THEN
           l_condition_4 := ' AND VPA.contract_number like '''||p_vpa_number||'%''';
           l_total_sql := l_total_sql || l_condition_4;
        END IF;

        IF p_asst_end_dt_from IS NOT NULL THEN
           lp_asst_end_dt_from := FND_DATE.CANONICAL_TO_DATE(p_asst_end_dt_from);
           l_condition_5 := ' AND trunc(CLE.date_terminated) >= to_date('''||lp_asst_end_dt_from||''',''DD-MON-YY'')';
           l_total_sql := l_total_sql || l_condition_5;
        END IF;

        IF p_asst_end_dt_to IS NOT NULL THEN
           lp_asst_end_dt_to := FND_DATE.CANONICAL_TO_DATE(p_asst_end_dt_to);
           l_condition_6 := ' AND trunc(CLE.date_terminated) <= to_date('''||lp_asst_end_dt_to||''',''DD-MON-YY'')';
           l_total_sql := l_total_sql || l_condition_6;
        END IF;

        IF p_currency IS NOT NULL THEN
           l_condition_7 := ' AND TAL.currency_code like '''||p_currency||'%''';
           l_total_sql := l_total_sql || l_condition_7;
        END IF;

        FND_FILE.put_line(FND_FILE.log, 'l_total_sql - '||l_total_sql);

        i := 1;
     OPEN dynamic_cursor FOR l_total_sql;
        FETCH dynamic_cursor INTO l_result_sql;
        LOOP

           EXIT WHEN dynamic_cursor%NOTFOUND;

           FND_FILE.put_line(FND_FILE.log, 'DYNAMIC SQL EXECUTING -- ROWS FOUND '||i);

           l_rpt_tbl(i).PROGRAM_AGREEMENT := l_result_sql.PROGRAM_AGREEMENT;
           l_rpt_tbl(i).ASSET_NUMBER := l_result_sql.ASSET_NUMBER;
           l_rpt_tbl(i).ASSET_DESCRIPTION := l_result_sql.ASSET_DESCRIPTION;
           l_rpt_tbl(i).CONTRACT_NUMBER := l_result_sql.CONTRACT_NUMBER;
           l_rpt_tbl(i).ASSET_TERMINATION_DATE := l_result_sql.ASSET_TERMINATION_DATE;
           l_rpt_tbl(i).VENDOR := l_result_sql.VENDOR;
           l_rpt_tbl(i).DISPOSITION_DATE := l_result_sql.DISPOSITION_DATE;
           l_rpt_tbl(i).VENDOR_SHARE := l_result_sql.VENDOR_SHARE;

           i := i + 1;

           FETCH dynamic_cursor INTO l_result_sql;
        END LOOP;
        CLOSE dynamic_cursor;

        create_report_output(p_values => l_rpt_tbl);

  EXCEPTION

     WHEN OTHERS THEN
         -- Set the oracle error message
         OKL_API.set_message(
            p_app_name      => G_APP_NAME_1,
            p_msg_name      => G_UNEXPECTED_ERROR,
            p_token1        => G_SQLCODE_TOKEN,
            p_token1_value  => SQLCODE,
            p_token2        => G_SQLERRM_TOKEN,
            p_token2_value  => SQLERRM);

           FND_FILE.put_line(FND_FILE.log, 'Error - '||SQLERRM);

  END concurrent_vend_res_share_rpt;

  -----------------------------------------------------------------------------------
  -- FUNCTION BEFORE_REPORT_INIT_WHRE_CLAUSE
  -----------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : BEFORE_REPORT_INIT_WHRE_CLAUSE
  -- Description     : Function to form the where clause for XML Publisher
  --                   based on the input parameters.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : UDHENUKO created.
  -- End of comments
  ------------------------------------------------------------------------------------

  FUNCTION  BEFORE_REPORT_INIT_WHRE_CLAUSE RETURN BOOLEAN

  IS
        l_where_sql_1        VARCHAR2(3000);
        l_where_sql_2        VARCHAR2(3000);
        l_condition_1        VARCHAR2(300);
        l_condition_2        VARCHAR2(300);
        l_condition_3        VARCHAR2(300);
        l_condition_4        VARCHAR2(300);
        l_condition_5        VARCHAR2(300);
        l_condition_6        VARCHAR2(300);
        l_condition_7        VARCHAR2(300);
        lp_disp_date_from    DATE;
        lp_disp_date_to      DATE;
        lp_asst_end_dt_from  DATE;
        lp_asst_end_dt_to    DATE;
  BEGIN

 -- Forming the where clause condition for the XML publisher report.
 -- Step 1 : Form the static part of the where clause that is independent of the input parameters.
 -- Step 2 : Concatenate the where clause from Step1 with the conditions based on the input parameters.
        l_where_sql_1  := ' WHERE TAL.TAS_ID = TAS.ID AND TAS.TAS_TYPE = '||'''VRS'''||' AND TAL.TAL_TYPE = '||'''VRS'''||' ';
        l_where_sql_2  := ' AND TAL.KLE_ID = CLE.ID AND CLE.CHR_ID = CHR.ID AND CHR.ID = KHR.ID AND KHR.KHR_ID = VPA.ID AND PPD.CPL_ID = TAL.RESIDUAL_SHR_PARTY_ID ';

        WHERE_CLAUSE    :=  l_where_sql_1  || l_where_sql_2;

        IF P_ASSET_NUMBER IS NOT NULL THEN
           l_condition_1 := ' AND CLE.name like '''||P_ASSET_NUMBER||'%''';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_1;
        END IF;

        IF P_DISP_DATE_FROM IS NOT NULL THEN
           lp_disp_date_from := FND_DATE.CANONICAL_TO_DATE(P_DISP_DATE_FROM);
           l_condition_2 := ' AND trunc(TAL.fa_trx_date) >= to_date('''||lp_disp_date_from||''',''DD-MON-YY'')';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_2;
        END IF;

        IF P_DISP_DATE_TO IS NOT NULL THEN
           lp_disp_date_to := FND_DATE.CANONICAL_TO_DATE(P_DISP_DATE_TO);
           l_condition_3 := ' AND trunc(TAL.fa_trx_date) <= to_date('''||lp_disp_date_to||''',''DD-MON-YY'')';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_3;
        END IF;

        IF P_VPA_NUMBER IS NOT NULL THEN
           l_condition_4 := ' AND VPA.contract_number like '''||P_VPA_NUMBER||'%''';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_4;
        END IF;

        IF P_ASST_END_DT_FROM IS NOT NULL THEN
           lp_asst_end_dt_from := FND_DATE.CANONICAL_TO_DATE(P_ASST_END_DT_FROM);
           l_condition_5 := ' AND trunc(CLE.date_terminated) >= to_date('''||lp_asst_end_dt_from||''',''DD-MON-YY'')';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_5;
        END IF;

        IF P_ASST_END_DT_TO IS NOT NULL THEN
           lp_asst_end_dt_to := FND_DATE.CANONICAL_TO_DATE(P_ASST_END_DT_TO);
           l_condition_6 := ' AND trunc(CLE.date_terminated) <= to_date('''||lp_asst_end_dt_to||''',''DD-MON-YY'')';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_6;
        END IF;

        IF P_CURRENCY IS NOT NULL THEN
           l_condition_7 := ' AND TAL.currency_code like '''||P_CURRENCY||'%''';
           WHERE_CLAUSE := WHERE_CLAUSE || l_condition_7;
        END IF;


  RETURN TRUE;

END BEFORE_REPORT_INIT_WHRE_CLAUSE;

END OKL_AM_VENDOR_RES_SHARE_PVT;

/
