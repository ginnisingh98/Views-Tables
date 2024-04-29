--------------------------------------------------------
--  DDL for Package Body OKL_AM_BAL_WRITEOFF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_BAL_WRITEOFF_PVT" AS
/* $Header: OKLRBWRB.pls 120.11 2007/08/10 11:53:42 dpsingh noship $ */

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
           status           VARCHAR2(300) );

  -- Table Type to Store Recs of Message details with IA details
  TYPE message_tbl_type IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;

  -- *********************
  -- GLOBAL MESSAGE CONSTANTS
  -- *********************
  G_INVALID_VALUE CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_CONTRACT_NUMBER_TOKEN   CONSTANT VARCHAR2(2000) := 'CONTRACT_NUMBER';
  -- *********************
  -- GLOBAL VARIABLES
  -- *********************
  G_PKG_NAME        CONSTANT VARCHAR2(200) := 'OKL_AM_BAL_WRITEOFF_PVT';
  G_APP_NAME        CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
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
  G_KHR_ENDED_BY_DATE   DATE;
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
  -- Procedure Name: fnd_error_output
  -- Desciption     : Logs the messages in the output log
  -- Business Rules:
  -- Parameters    :
  -- Version: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE fnd_output  (
                  p_khr_rec      IN  khr_rec_type,
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
                 msg_lines_table(l_error_count).id := p_khr_rec.id;
                 msg_lines_table(l_error_count).msg := lx_error_rec.msg_data;

                 l_error_count := l_error_count + 1;
       END IF;

      EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
       OR (lx_error_rec.msg_count IS NULL));

      l_msg_idx:= G_NEXT;

       END LOOP;


       IF p_control_flag = 'PROCESSED' THEN

          success_message_table(l_success_tbl_index).id := p_khr_rec.id;
          success_message_table(l_success_tbl_index).contract_number := p_khr_rec.contract_number;
          success_message_table(l_success_tbl_index).start_date  := p_khr_rec.start_date;
          success_message_table(l_success_tbl_index).end_date  := p_khr_rec.end_date;
          success_message_table(l_success_tbl_index).status  := p_khr_rec.sts_code;
          l_success_tbl_index := l_success_tbl_index + 1;

       ELSE

          error_message_table(l_error_tbl_index).id := p_khr_rec.id;
          error_message_table(l_error_tbl_index).contract_number := p_khr_rec.contract_number;
          error_message_table(l_error_tbl_index).start_date  := p_khr_rec.start_date;
          error_message_table(l_error_tbl_index).end_date  := p_khr_rec.end_date;
          error_message_table(l_error_tbl_index).status  := p_khr_rec.sts_code;
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
  -- Procedure Name: create_report
  -- Desciption     : Creates the Output and Log Reports
  -- Business Rules:
  -- Parameters    :
  -- Version: 1.0
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
         l_term_k            VARCHAR2(300);
         l_error_k           VARCHAR2(300);
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

  BEGIN

       l_success := success_message_table.COUNT;
       l_error   := error_message_table.COUNT;

       l_orcl_logo      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_ACCT_LEASE_MANAGEMENT');
       --l_term_heading   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_TERM_INV');

       l_term_heading   := 'Balance Writeoff for Terminated and Expired Contracts';

       l_set_of_books   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SET_OF_BOOKS');
       l_run_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_RUN_DATE');
       l_oper_unit      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_OPERUNIT');
       l_type           := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_TYPE');
       l_processed      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_PROCESSED_ENTRIES');
       --l_term_k         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_TERMINATED_INV');

       l_term_k         := 'Successful Writeoffs';

       --l_error_k        := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_ERRORED_INV');

       l_error_k        := 'Errored Writeoffs';

       l_serial         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SERIAL_NUMBER');
       --l_k_num          := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_INV_AGR_NUM');

       l_k_num          := 'Contract Number';
       l_start_date     := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_START_DATE');
       l_end_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_DATE');
       --l_status         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_STATUS');

       l_status         := 'Contract Status';

       l_messages       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_MESSAGES');
       l_eop            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_OF_REPORT');
--       l_inv_ended_by   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INV_AGR_ENDED_BY');

       l_inv_ended_by   := 'Contracts Ended By';

       l_inv            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INVALID_TERM_DATE');

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

       FND_FILE.put_line(FND_FILE.log, l_term_k ||
                                          RPAD(' ',40-LENGTH(l_term_k),' ') ||
                                          l_success);

       FND_FILE.put_line(FND_FILE.log, l_error_k ||
                                          RPAD(' ',40-LENGTH(l_error_k),' ') ||
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
                                          l_org_name ||
                                          RPAD(' ', 128-LENGTH(l_oper_unit)-LENGTH(l_org_name)-LENGTH(l_inv_ended_by)-25, ' ' ) ||
                                          l_inv_ended_by  ||' : ' ||
                                          TO_CHAR(G_KHR_ENDED_BY_DATE, 'DD-MON-YYYY HH24:MI'));

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');

       FND_FILE.put_line(FND_FILE.output, l_type ||
                                          RPAD(' ',40-LENGTH(l_type),' ') ||
                                          l_processed);

       FND_FILE.put_line(FND_FILE.output, RPAD('-',128 ,'-'));

       FND_FILE.put_line(FND_FILE.output, l_term_k ||
                                          RPAD(' ',40-LENGTH(l_term_k),' ') ||
                                          l_success);

       FND_FILE.put_line(FND_FILE.output, l_error_k ||
                                          RPAD(' ',40-LENGTH(l_error_k),' ') ||
                                          l_error);

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD('=',128,'=' ));
       FND_FILE.put_line(FND_FILE.output,'');

       -- Print VPAs Terminated Successfully
       IF l_success > 0 THEN

        FND_FILE.put_line(FND_FILE.output, l_term_k);
        FND_FILE.put_line(FND_FILE.output, RPAD('-',LENGTH(l_term_k), '-' ));
        FND_FILE.put_line(FND_FILE.output,'');

        l_print := 'N';

        FOR i IN success_message_table.FIRST..success_message_table.LAST LOOP

           IF l_print = 'N' THEN

           FND_FILE.put_line(FND_FILE.output,  l_serial || RPAD(' ',15-LENGTH(l_serial),' ')||
                                               l_k_num || RPAD(' ',35-LENGTH(l_k_num),' ')||
                                               l_start_date||RPAD(' ',15-LENGTH(l_start_date),' ') ||
                                               l_end_date||RPAD(' ',15-LENGTH(l_end_date),' ') ||
                                               l_status||RPAD(' ',15-LENGTH(l_status),' '));

           FND_FILE.put_line(FND_FILE.output,  RPAD('-',LENGTH(l_serial),'-') || RPAD('-',15-LENGTH(l_serial),'-')||
                                               RPAD('-',LENGTH(l_k_num),'-') || RPAD('-',35-LENGTH(l_k_num),'-')||
                                               RPAD('-',LENGTH(l_start_date),'-')||RPAD('-',15-LENGTH(l_start_date),'-') ||
                                               RPAD('-',LENGTH(l_end_date),'-')||RPAD('-',15-LENGTH(l_end_date),'-') ||
                                               RPAD('-',LENGTH(l_status),'-')||RPAD('-',15-LENGTH(l_status),'-'));

           l_print := 'Y';
           END IF;

           FND_FILE.put_line(FND_FILE.output,  i || RPAD(' ',15-LENGTH(i),' ')||
                                               success_message_table(i).contract_number ||
                                               RPAD(' ',35-LENGTH(success_message_table(i).contract_number),' ')||
                                               success_message_table(i).start_date||
                                               RPAD(' ',15-LENGTH(success_message_table(i).start_date),' ') ||
                                               success_message_table(i).end_date||
                                               RPAD(' ',15-LENGTH(success_message_table(i).end_date),' ') ||
                                               success_message_table(i).status||
                                               RPAD(' ',15-LENGTH(success_message_table(i).status),' '));

          END LOOP;
       END IF;

       FND_FILE.put_line(FND_FILE.output,'');

       -- Print VPAs errored
       IF l_error > 0 THEN

        FND_FILE.put_line(FND_FILE.output, l_error_k);
        FND_FILE.put_line(FND_FILE.output, RPAD('-',LENGTH(l_error_k), '-' ));
        FND_FILE.put_line(FND_FILE.output,'');

        -- Initialize the table index
        msg_lines_table_index := 1;

        FOR i IN error_message_table.FIRST..error_message_table.LAST LOOP

           FND_FILE.put_line(FND_FILE.output,  l_serial || RPAD(' ',15-LENGTH(l_serial),' ')||
                                               l_k_num || RPAD(' ',35-LENGTH(l_k_num),' ')||
                                               l_start_date||RPAD(' ',15-LENGTH(l_start_date),' ') ||
                                               l_end_date||RPAD(' ',15-LENGTH(l_end_date),' ') ||
                                               l_status||RPAD(' ',15-LENGTH(l_status),' '));

           FND_FILE.put_line(FND_FILE.output,  RPAD('-',LENGTH(l_serial),'-') || RPAD('-',15-LENGTH(l_serial),'-')||
                                               RPAD('-',LENGTH(l_k_num),'-') || RPAD('-',35-LENGTH(l_k_num),'-')||
                                               RPAD('-',LENGTH(l_start_date),'-')||RPAD('-',15-LENGTH(l_start_date),'-') ||
                                               RPAD('-',LENGTH(l_end_date),'-')||RPAD('-',15-LENGTH(l_end_date),'-') ||
                                               RPAD('-',LENGTH(l_status),'-')||RPAD('-',15-LENGTH(l_status),'-'));

           FND_FILE.put_line(FND_FILE.output,  i || RPAD(' ',15-LENGTH(i),' ')||
                                               error_message_table(i).contract_number ||
                                               RPAD(' ',35-LENGTH(error_message_table(i).contract_number),' ')||
                                               error_message_table(i).start_date||
                                               RPAD(' ',15-LENGTH(error_message_table(i).start_date),' ') ||
                                               error_message_table(i).end_date||
                                               RPAD(' ',15-LENGTH(error_message_table(i).end_date),' ') ||
                                               error_message_table(i).status||
                                               RPAD(' ',15-LENGTH(error_message_table(i).status),' '));

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
  -- Procedure Name  : populate_khr_prg
  -- Description     : procedure to validate khr rec
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE populate_khr_prg(
                    p_khr_rec        IN   khr_rec_type,
                    x_khr_rec        OUT  NOCOPY khr_rec_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- Get the details of the VPA
       CURSOR get_khr_details_csr (p_khr_id IN NUMBER) IS
            SELECT   CHR.id,
                     CHR.contract_number contract_number,
                     CHR.START_DATE,
                     CHR.end_date,
                     CHR.sts_code,
                     CHR.scs_code,
                     CHR.date_terminated
            FROM     OKC_K_HEADERS_B CHR,
                     OKL_K_HEADERS   KHR
            WHERE    CHR.id = p_khr_id
            AND      CHR.id = KHR.id;

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_khr_rec   khr_rec_type;
        get_khr_details_rec get_khr_details_csr%ROWTYPE;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.populate_khr_prg.',
                        'Begin(+)');
       END IF;

       SAVEPOINT populate_khr_trx;

       -- Get VPA details
       OPEN get_khr_details_csr (p_khr_rec.id);
       FETCH get_khr_details_csr INTO get_khr_details_rec;
       CLOSE get_khr_details_csr;

       -- Set the va rec with VPA details
       l_khr_rec.id := get_khr_details_rec.id;
       l_khr_rec.contract_number := get_khr_details_rec.contract_number;
       l_khr_rec.start_date := get_khr_details_rec.start_date;
       l_khr_rec.end_date := get_khr_details_rec.end_date;
       l_khr_rec.sts_code := get_khr_details_rec.sts_code;
       l_khr_rec.date_terminated := get_khr_details_rec.date_terminated;
       l_khr_rec.scs_code := get_khr_details_rec.scs_code;

       -- Set return values
       x_return_status :=  l_return_status;
       x_khr_rec       :=  l_khr_rec;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.populate_khr_prg.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN OTHERS THEN
            ROLLBACK TO populate_khr_trx;
            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.populate_khr_prg.',
                             'EXP - OTHERS');
           END IF;

  END populate_khr_prg;


  -- Start of comments
  --
  -- Procedure Name  : validate_khr_prg
  -- Description     : procedure to validate khr rec
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE validate_khr_prg(
                    p_khr_rec        IN   khr_rec_type,
                    p_control_flag   IN   VARCHAR2,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- Check if close balances already done thru termination
       CURSOR get_termination_trn_csr (p_khr_id IN NUMBER) IS
            SELECT   TRN.id
            FROM     OKL_TRX_AR_ADJSTS_V BAL,
                     OKL_TRX_CONTRACTS TRN
            WHERE    TRN.khr_id = p_khr_id
            AND      TRN.tcn_type = 'TMT'
            AND      BAL.tcn_id = TRN.id;

       -- Check if close balances already done thru termination
       CURSOR get_writeoff_trn_csr (p_khr_id IN NUMBER) IS
            SELECT   TRN.id
            FROM     OKL_TRX_CONTRACTS TRN
            WHERE    TRN.khr_id = p_khr_id
            AND      TRN.tcn_type = 'BWO';

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_ia_number  VARCHAR2(300);
        l_start_date DATE;
        l_end_date   DATE;
        l_status     VARCHAR2(300);
        l_type       VARCHAR2(300);
        l_pdt_id     NUMBER;
        l_trn_id     NUMBER;
        i NUMBER := 0;
        l_tsu_code  VARCHAR2(300);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.validate_khr_prg.',
                        'Begin(+)');
       END IF;

       SAVEPOINT validate_khr_trx;

       -- If single request then do additional validations
       IF p_control_flag = 'BATCH_SINGLE' THEN -- Do additional checks

           -- Check for ID
           IF p_khr_rec.id IS NULL
                        OR p_khr_rec.id = OKL_API.G_MISS_NUM THEN

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_ID_INV');

                RAISE G_EXCEPTION_ERROR;
           END IF;

            -- Check for type
           IF p_khr_rec.scs_code NOT IN ('LEASE','LOAN') THEN -- *** CHECK

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_TYPE_INV',
                          p_token1         => 'CONTRACT_NUMBER',
                          p_token1_value   => p_khr_rec.contract_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

           -- Check for status
           IF p_khr_rec.sts_code NOT IN ('TERMINATED', 'EXPIRED') THEN

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_STATUS_INV',
                          p_token1         => 'CONTRACT_NUMBER',
                          p_token1_value   => p_khr_rec.contract_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

           -- Check for end date
           IF p_khr_rec.end_date IS NULL THEN

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_END_DATE_INV',
                          p_token1         => 'CONTRACT_NUMBER',
                          p_token1_value   => p_khr_rec.contract_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

              -- Check if balance writeoff already done  through termination
             OPEN get_termination_trn_csr (p_khr_rec.id);
             FETCH get_termination_trn_csr INTO l_trn_id;
             CLOSE get_termination_trn_csr;

   IF  l_trn_id IS NOT NULL
   AND l_trn_id <> OKL_API.G_MISS_NUM THEN

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_DONE',
                          p_token1         => 'CONTRACT_NUMBER',
                          p_token1_value   => p_khr_rec.contract_number);

                RAISE G_EXCEPTION_ERROR;

   END IF;

   -- Check if balance writeoff already done
   OPEN get_writeoff_trn_csr (p_khr_rec.id);
   FETCH get_writeoff_trn_csr INTO l_trn_id;
   CLOSE get_writeoff_trn_csr;

   IF  l_trn_id IS NOT NULL
   AND l_trn_id <> OKL_API.G_MISS_NUM THEN

                -- Message:
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_BWR_KHR_DONE',
                          p_token1         => 'CONTRACT_NUMBER',
                          p_token1_value   => p_khr_rec.contract_number);

                RAISE G_EXCEPTION_ERROR;

   END IF;

       END IF;

       -- Set return values
       x_return_status :=  l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.validate_khr_prg.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO validate_khr_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.validate_khr_prg.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_khr_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.validate_khr_prg.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO validate_khr_trx;
            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.validate_khr_prg.',
                             'EXP - OTHERS');
           END IF;

  END validate_khr_prg;


  -- Start of comments
  --
  -- Procedure Name: create_report
  -- Desciption     : Creates the Output and Log Reports
  -- Business Rules:
  -- Parameters    :
  -- Version: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE write_off_balances(
                    p_api_version     IN   NUMBER,
                    p_init_msg_list   IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status   OUT  NOCOPY VARCHAR2,
                    x_msg_count       OUT  NOCOPY NUMBER,
                    x_msg_data        OUT  NOCOPY VARCHAR2,
                    p_khr_rec         IN   khr_rec_type,
                    p_sys_date        IN   DATE,
                    p_control_flag    IN   VARCHAR2) IS

   -- Cursor to get the balances of contract
/* rmunjulu R12 Fixes - Billing fixes -- replaced with new cursor below
   CURSOR  k_balances_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS
   SELECT  SUM(amount_due_remaining)
   FROM    OKL_BPD_LEASING_PAYMENT_TRX_V
   WHERE   contract_id = p_khr_id
   AND     invoice_date <= sysdate;
*/

-- rmunjulu R12 Fixes - Billing fixes -- changes to this cursor as old bpd view does not work anymore
   CURSOR  k_balances_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS
   SELECT  SUM(amount_due_remaining)
   FROM    OKL_BPD_TLD_AR_LINES_V
   WHERE   khr_id = p_khr_id
   AND     invoice_date <= sysdate;

/* rmunjulu R12 Fixes - Billing fixes -- replaced with new cursor below
   -- Cursor to get the lines with amount due and payment schedule id for the balances
   CURSOR k_bal_lns_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS
   SELECT OBLP.amount_due_remaining       AMOUNT,
          OBLP.stream_type_id             STREAM_TYPE_ID,
          OSTY.name                       STREAM_MEANING,
          OBLP.payment_schedule_id        SCHEDULE_ID,
          OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
          OTIL.id                         TIL_ID,
          -999                            TLD_ID
   FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
          OKL_TXL_AR_INV_LNS_V           OTIL,
          OKL_STRM_TYPE_V                OSTY
   WHERE  OBLP.contract_id             = p_khr_id
   AND    OBLP.receivables_invoice_id  = OTIL.receivables_invoice_id
   AND    OBLP.stream_type_id          = OSTY.id
   AND    OBLP.amount_due_remaining > 0
   AND    OBLP.invoice_date <= p_trn_date
   UNION
   SELECT OBLP.amount_due_remaining       AMOUNT,
          OBLP.stream_type_id             STREAM_TYPE_ID,
          OSTY.name                       STREAM_MEANING,
          OBLP.payment_schedule_id        SCHEDULE_ID,
          OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
          OTAI.til_id_details             TIL_ID,
          OTAI.id                         TLD_ID
   FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
          OKL_TXD_AR_LN_DTLS_V           OTAI,
          OKL_STRM_TYPE_V                OSTY
   WHERE  OBLP.contract_id             = p_khr_id
   AND    OBLP.receivables_invoice_id  = OTAI.receivables_invoice_id
   AND    OBLP.stream_type_id          = OSTY.id
   AND    OBLP.amount_due_remaining > 0
   AND    OBLP.invoice_date <= p_trn_date;
*/

-- rmunjulu R12 Fixes - Billing fixes -- changes to this cursor as old bpd view does not work anymore
   CURSOR k_bal_lns_csr (p_khr_id IN NUMBER, p_trn_date DATE) IS
   SELECT RACTRL.amount_due_remaining       AMOUNT,
          RACTRL.STY_ID                     STREAM_TYPE_ID,
          --Bug 6316320 dpsingh start
          RACTRL.KLE_ID                     KLE_ID,
          --Bug 6316320 dpsingh end
          RACTRL.STREAM_TYPE                STREAM_MEANING,
          APS.payment_schedule_id           SCHEDULE_ID,
          RACTRL.CUSTOMER_TRX_ID            AR_INVOICE_NUMBER,
          RACTRL.til_id_details             TIL_ID,
          RACTRL.TLD_ID                     TLD_ID
   FROM   OKL_BPD_TLD_AR_LINES_V     RACTRL,
          AR_PAYMENT_SCHEDULES_ALL   APS
   WHERE  RACTRL.khr_id             = p_khr_id
   AND    RACTRL.amount_due_remaining > 0
   AND    RACTRL.CUSTOMER_TRX_ID  = APS.CUSTOMER_TRX_ID
   AND    RACTRL.invoice_date <= p_trn_date;


   -- Cursor to get the product of the contract
   CURSOR prod_id_csr (p_khr_id IN NUMBER) IS
     SELECT   pdt_id
     FROM     OKL_K_HEADERS_V
     WHERE    id = p_khr_id;

   -- Cursor to get the code_combination_id for the transaction id and
   -- transaction table
   -- RMUNJULU 03-JAN-03 2683876 Added code to
   -- make sure we get the debit distribution and also it is 100percent
   CURSOR code_combination_id_csr(p_source_id    IN NUMBER,
                                  p_source_table IN VARCHAR2) IS
    SELECT DST.code_combination_id
    FROM   OKL_TRNS_ACC_DSTRS DST
    WHERE  DST.source_id     = p_source_id
    AND    DST.source_table  = p_source_table
    AND    DST.cr_dr_flag    = 'D'
    AND    DST.percentage    = 100;

   -- get tolerance profile name
   CURSOR get_profile_name_csr IS
   SELECT user_profile_option_name
   FROM   fnd_profile_options_vl
   WHERE  profile_option_name = 'OKL_SMALL_BALANCE_TOLERANCE';

   k_bal_lns_rec               k_bal_lns_csr%ROWTYPE;
   l_return_status             VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   lp_adjv_rec                 OKL_TRX_AR_ADJSTS_PUB.adjv_rec_type;
   lx_adjv_rec                 OKL_TRX_AR_ADJSTS_PUB.adjv_rec_type;
   l_early_termination_yn      VARCHAR2(1) := OKL_API.G_FALSE;
   l_total_amount_due          NUMBER := -1;
   l_code_combination_id       NUMBER := -1;
   i                           NUMBER :=  1;
   l_tolerance_amt             NUMBER := -1;
   l_api_name                  VARCHAR2(30) := 'write_off_balances';
   l_pdt_id                    NUMBER := 0;
   lp_acc_gen_primary_key_tbl  OKL_ACCOUNT_DIST_PUB.acc_gen_primary_key;

    --Bug 6316320 dpsingh start
   l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
   l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
   l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
   l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
   l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
   l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
   l_acc_gen_primary_key_tbl   Okl_Account_Dist_Pub.acc_gen_primary_key;

   TYPE ajlv_id_rec_type IS RECORD (
        id   NUMBER,
        amount  OKL_BPD_TLD_AR_LINES_V.AMOUNT%TYPE,
        ar_invoice_number  OKL_BPD_TLD_AR_LINES_V.CUSTOMER_TRX_ID%TYPE,
        stream_meaning OKL_BPD_TLD_AR_LINES_V.STREAM_TYPE%TYPE);

   TYPE ajlv_id_tbl_type IS TABLE OF ajlv_id_rec_type INDEX BY BINARY_INTEGER;
   ajlv_id_tbl  ajlv_id_tbl_type;

   CURSOR get_account_derivation_meth IS
   SELECT ACCOUNT_DERIVATION
   FROM OKL_SYS_ACCT_OPTS;

   l_account_derivation OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;
     --Bug 6316320 dpsingh end

   l_overall_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
   l_writeoff_try_id           NUMBER;
   l_trn_try_id                NUMBER;
   l_trans_meaning             VARCHAR2(200);
   l_currency_code             VARCHAR2(200);
   l_formatted_bal_amt         VARCHAR2(200);
   l_formatted_tol_amt         VARCHAR2(200);
   l_formatted_adj_amt         VARCHAR2(200);
   l_api_version               VARCHAR2(3) := G_API_VERSION;

   l_functional_currency_code VARCHAR2(15);
   l_contract_currency_code   VARCHAR2(15);
   l_currency_conversion_type VARCHAR2(30);
   l_currency_conversion_rate NUMBER;
   l_currency_conversion_date DATE;
   l_converted_amount NUMBER;

   -- Since we do not use the amount or converted amount
   -- set a hardcoded value for the amount (and pass to to
   -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
   -- conversion values )
   l_hard_coded_amount CONSTANT NUMBER := 100;

   lp_ajlv_rec          OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;
   lx_ajlv_rec          OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;
   l_ajlv_rec           OKL_TXL_ADJSTS_LNS_PUB.ajlv_rec_type;
   lp_tcnv_rec          OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
   lx_tcnv_rec          OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
   l_tol_profile_name   VARCHAR2(300);

      -- rmunjulu 4622198
   l_fact_synd_code FND_LOOKUPS.lookup_code%TYPE;
   l_inv_acct_code OKC_RULES_B.rule_information1%TYPE;

   l_total_amount NUMBER; -- rmunjulu 4917286
   lpp_tcnv_rec OKL_TRX_CONTRACTS_PUB.tcnv_rec_type; -- rmunjulu 4917286
   lxx_tcnv_rec OKL_TRX_CONTRACTS_PUB.tcnv_rec_type; -- rmunjulu 4917286

  BEGIN
      ---
     --get the tolerance limit from profile
     -- get the total balances of ARs for the contract
     -- if total balance amount within the tolerance limit then
     -- close balances
     -- end if

     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                        'Begin(+)');
     END IF;

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

     -- Rollback if error setting activity for api
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     END IF;

     -- get the total balances of ARs for the contract
     OPEN  k_balances_csr(p_khr_rec.id,p_sys_date);
     FETCH k_balances_csr INTO l_total_amount_due;
     CLOSE k_balances_csr;

     -- set the total amount if it is null
     IF l_total_amount_due IS NULL THEN
       l_total_amount_due := 0;
     END IF;

     -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
     OKL_SECURITIZATION_PVT.check_khr_ia_associated(
        p_api_version                  => p_api_version
       ,p_init_msg_list                => OKL_API.G_FALSE
       ,x_return_status                => l_return_status
       ,x_msg_count                    => x_msg_count
       ,x_msg_data                     => x_msg_data
       ,p_khr_id                       => p_khr_rec.id
       ,p_scs_code                     => p_khr_rec.scs_code
       ,p_trx_date                     => p_sys_date
       ,x_fact_synd_code               => l_fact_synd_code
       ,x_inv_acct_code                => l_inv_acct_code
       );

     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_ERROR;
     END IF;

     -- Check if total amount due is +ve else set message and exit
     IF l_total_amount_due > 0 THEN

      --get the tolerance limit from profile
      FND_PROFILE.get('OKL_SMALL_BALANCE_TOLERANCE',l_tolerance_amt);

      -- if no tolerance amt then assume tolerance amt = 0 ,
      -- raise warning msg and proceed
      -- RMUNJULU 07-APR-03 2883292 Changed IF to check for NULL instead of -1
      IF  l_tolerance_amt IS NULL THEN

        -- get the profile option name
        OPEN  get_profile_name_csr;
        FETCH get_profile_name_csr INTO l_tol_profile_name;
        CLOSE get_profile_name_csr;

        -- No tolerance amount found for closing of balances.
        OKL_API.set_message( p_app_name    => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_NO_TOL_AMT');

-- To set tolerance amount, set value for profile option PROFILE_NAME.
        OKL_API.set_message( p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_AM_TOL_AMT',
                             p_token1       => 'PROFILE_NAME',
                             p_token1_value => l_tol_profile_name);

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                        'NO TOLERANCE');
        END IF;

        RAISE   OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- IF total balance amount within the tolerance limit and amount due>0 then
      IF (l_total_amount_due <= l_tolerance_amt) THEN
              -- ********  GET PRODUCT ID *************** START ****************
           -- get the product id
           OPEN  prod_id_csr(p_khr_rec.id);
           FETCH prod_id_csr INTO l_pdt_id;
           CLOSE prod_id_csr;
           -- raise error message if no pdt_id
           IF l_pdt_id IS NULL OR l_pdt_id = 0 THEN
             -- Error: Unable to create accounting entries because of a missing
             -- Product Type for the contract CONTRACT_NUMBER.
             OKL_API.set_message(
                               p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKL_AM_PRODUCT_ID_ERROR',
                               p_token1      => 'CONTRACT_NUMBER',
                               p_token1_value=> p_khr_rec.contract_number);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'product_id_error = '||l_return_status );
             END IF;

             RAISE   OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- ********  GET PRODUCT ID *************** END ****************

           -- ********  GET BAL WRITE OFF TRY ID *************** START ******

           -- Get the transaction id for adjustments
           OKL_AM_UTIL_PVT.get_transaction_id(
                    p_try_name     => 'Balance Write off',
                  x_return_status     => l_return_status,
                  x_try_id         => l_writeoff_try_id);

           -- Get the meaning of lookup BALANCE_WRITE_OFF
           l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                    p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                  p_lookup_code=> 'BALANCE_WRITE_OFF',
                                  p_validate_yn => 'Y');

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             -- Message: Unable to find a transaction type for
             -- the transaction TRY_NAME
             OKL_API.set_message(
                              p_app_name       => G_APP_NAME,
                              p_msg_name       => 'OKL_AM_NO_TRX_TYPE_FOUND',
                              p_token1         => 'TRY_NAME',
                              p_token1_value   => l_trans_meaning);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'balance_writeoff_trn_error = '||l_return_status );
             END IF;

           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- *** GET CURRENCY CODES ***************************** START ****

           -- Get the functional currency from AM_Util
           l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency;

           -- Get the contract currency code
           l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_khr_rec.id);

           -- *** GET CURRENCY CODES ***************************** END   ****

           -- *** CONVERT CURRENCIES **************************** START  ****

           -- Get the currency conversion details from ACCOUNTING_Util
           OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id              => p_khr_rec.id,
                     p_to_currency         => l_functional_currency_code,
                     p_transaction_date   => p_sys_date, -- rmunjulu EDAT
                     p_amount           => l_hard_coded_amount,
                     x_return_status              => l_return_status,
                     x_contract_currency  => l_contract_currency_code,
                     x_currency_conversion_type  => l_currency_conversion_type,
                     x_currency_conversion_rate  => l_currency_conversion_rate,
                     x_currency_conversion_date  => l_currency_conversion_date,
                     x_converted_amount   => l_converted_amount);
            -- If error from OKL_ACCOUNTING_UTIL
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

              -- Error occurred when creating accounting entries for
              -- transaction TRX_TYPE.
              OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_ERR_ACC_ENT',
                           p_token1        => 'TRX_TYPE',
                           p_token1_value  => l_trans_meaning);

              IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'currency_conv_error = '||l_return_status );
              END IF;

              RAISE OKL_API.G_EXCEPTION_ERROR;

           END IF;

           -- *** CONVERT CURRENCIES **************************** END    ****

     l_total_amount := 0; --rmunjulu 4917286

           -- *** CREATE WRITEOFF TRANSACTION IN OKL_TRX_CONTRACTS ** START *

           -- initialize the transaction rec
           lp_tcnv_rec.khr_id                     := p_khr_rec.id;
           lp_tcnv_rec.tcn_type                   := 'BWO';
           lp_tcnv_rec.try_id                     := l_writeoff_try_id;
           lp_tcnv_rec.currency_code              := l_currency_code;
           lp_tcnv_rec.tsu_code                   := 'ENTERED';
           lp_tcnv_rec.date_transaction_occurred  := p_sys_date;

           OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
           p_api_version=> p_api_version,
           p_init_msg_list=> OKL_API.G_FALSE,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_tcnv_rec       => lp_tcnv_rec,
               x_tcnv_rec       => lx_tcnv_rec);

           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             -- Error occurred when creating adjustment records to write off balances.
             OKL_API.set_message( p_app_name      => G_APP_NAME,
                                  p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');

           END IF;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'OKL_TRX_CONTRACTS_PUB.create_trx_contracts = '||l_return_status );
           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- *** CREATE WRITEOFF TRANSACTION IN OKL_TRX_CONTRACTS ** END  **

           -- *** CREATE ADJUSTMENT HEADER TRN IN OKL_TRX_ADJSTS ** START ***
           -- set the adjusts rec
           lp_adjv_rec.trx_status_code           :=   'WORKING'; -- tsu_code
           lp_adjv_rec.tcn_id                    :=   lx_tcnv_rec.id; -- ID of new Writeoff transaction
           -- adjustment_reason_code comes from OKL_ADJUSTMENT_REASON
           lp_adjv_rec.adjustment_reason_code    :=   'SMALL AMT REMAINING';
           lp_adjv_rec.apply_date                :=   p_sys_date;
           lp_adjv_rec.gl_date                   :=   p_sys_date;
            --Bug 6316320 dpsingh start
           lp_adjv_rec.try_id                     := l_writeoff_try_id;
          --Bug 6316320 dpsingh end
           -- call the adjusts api
           OKL_TRX_AR_ADJSTS_PUB.insert_trx_ar_adjsts(
             p_api_version                  => p_api_version,
             p_init_msg_list                => OKL_API.G_FALSE,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_adjv_rec                      => lp_adjv_rec,
             x_adjv_rec                      => lx_adjv_rec);
           IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

             -- Error occurred when creating adjustment records to write off balances.
             OKL_API.set_message( p_app_name      => G_APP_NAME,
                                  p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');

           END IF;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'OKL_TRX_AR_ADJSTS_PUB.insert_trx_ar_adjsts = '||l_return_status );
           END IF;

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           -- *** CREATE ADJUSTMENT HEADER TRN IN OKL_TRX_ADJSTS ** END  ****

           -- loop thru AR balances for contract
           i := 1;
           FOR k_bal_lns_rec IN k_bal_lns_csr ( p_khr_rec.id,p_sys_date) LOOP
             -- *** CREATE TRN LINE IN OKL_TXL_ADJSTS_LN ***** START  *******

             -- set the rec for adjsts lns
             lp_ajlv_rec.adj_id            :=   lx_adjv_rec.id;
             lp_ajlv_rec.til_id            :=   k_bal_lns_rec.til_id;
             --Bug 6316320 dpsingh start
             lp_ajlv_rec.khr_id          := p_khr_rec.id;
             lp_ajlv_rec.kle_id          := k_bal_lns_rec.kle_id ;
             lp_ajlv_rec.sty_id          := k_bal_lns_rec.stream_type_id;
             --Bug 6316320 dpsingh end
             IF  k_bal_lns_rec.tld_id <> -999
             AND k_bal_lns_rec.tld_id IS NOT NULL
             AND k_bal_lns_rec.tld_id <> OKL_API.G_MISS_NUM THEN
                 lp_ajlv_rec.tld_id          :=   k_bal_lns_rec.tld_id;
             END IF;

             lp_ajlv_rec.amount            :=   k_bal_lns_rec.amount;
             lp_ajlv_rec.psl_id            :=   k_bal_lns_rec.schedule_id;

             l_total_amount := l_total_amount + k_bal_lns_rec.amount; --rmunjulu 4917286 -- keep track of total

             --call the txl_lns_adjsts
             OKL_TXL_ADJSTS_LNS_PUB.insert_txl_adjsts_lns(
                   p_api_version      => p_api_version,
                   p_init_msg_list    => OKL_API.G_FALSE,
                   x_return_status    => l_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_ajlv_rec            => lp_ajlv_rec,
                   x_ajlv_rec            => lx_ajlv_rec);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  -- Error occurred when creating adjustment records to write
                  -- off balances.
                  OKL_API.set_message( p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
             END IF;

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'OKL_TRX_AR_ADJSTS_PUB.insert_txl_adjsts_lns = '||l_return_status );
             END IF;

             -- Raise exception to rollback this whole block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             -- *** CREATE TRN LINE IN OKL_TXL_ADJSTS_LN ***** END    *******

             -- *** CREATE ACCOUNTING DISTRIBUTIONS ******* START ***********

             -- do accounting entries to get code_combination_id
      --Bug 6316320 dpsingh start
             -- Set the tmpl_identify_tbl in parameter
             l_tmpl_identify_tbl(i).product_id          :=  l_pdt_id;
             l_tmpl_identify_tbl(i).transaction_type_id :=  l_writeoff_try_id;
             l_tmpl_identify_tbl(i).memo_yn             :=  'N';
             l_tmpl_identify_tbl(i).prior_year_yn       :=  'N';
             l_tmpl_identify_tbl(i).stream_type_id      :=  k_bal_lns_rec.stream_type_id;

             -- Set the dist_info_tbl in parameter
             l_dist_info_tbl(i).source_id           :=  lx_ajlv_rec.id;
             l_dist_info_tbl(i).source_table        :=  'OKL_TXL_ADJSTS_LNS_B';
             l_dist_info_tbl(i).accounting_date     :=  p_sys_date;
             l_dist_info_tbl(i).gl_reversal_flag    :=  'N';
             l_dist_info_tbl(i).post_to_gl          :=  'N';
             l_dist_info_tbl(i).contract_id         :=  p_khr_rec.id;
             l_dist_info_tbl(i).amount              :=  k_bal_lns_rec.amount;

             -- Set the p_dist_info_rec for currency code
             l_dist_info_tbl(i).currency_code := l_contract_currency_code;

             -- If the functional currency code is different
             -- from contract currency code
             -- then set the rest of the currency conversion columns
             IF l_functional_currency_code <> l_contract_currency_code THEN

                -- Set the p_dist_info_rec currency conversion columns
                l_dist_info_tbl(i).currency_conversion_type := l_currency_conversion_type;
                l_dist_info_tbl(i).currency_conversion_rate := l_currency_conversion_rate;
                l_dist_info_tbl(i).currency_conversion_date := l_currency_conversion_date;

             END IF;

             -- Set lp_acc_gen_primary_key_tbl for account generator
             OKL_ACC_CALL_PVT.okl_populate_acc_gen (
                           p_contract_id       => p_khr_rec.id,
                           p_contract_line_id  => NULL,
                           x_acc_gen_tbl       => lp_acc_gen_primary_key_tbl,
                           x_return_status     => l_return_status);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                -- Error occurred when creating adjustment records to write off balances.
                OKL_API.set_message( p_app_name      => G_APP_NAME,
                                  p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');

             END IF;

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'OKL_ACC_CALL_PVT.okl_populate_acc_gen = '||l_return_status );
             END IF;

             -- Raise exception to rollback to savepoint for this block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

             l_acc_gen_tbl(i).acc_gen_key_tbl := lp_acc_gen_primary_key_tbl;
             l_acc_gen_tbl(i).source_id :=  lx_ajlv_rec.id;
             -- rmunjulu 4622198 SPECIAL_ACCNT set the special accounting parameters
             l_tmpl_identify_tbl(i).factoring_synd_flag := l_fact_synd_code;
             l_tmpl_identify_tbl(i).investor_code := l_inv_acct_code;
             ajlv_id_tbl(i).id := lx_ajlv_rec.id ;
             ajlv_id_tbl(i).amount  := k_bal_lns_rec.amount ;
             ajlv_id_tbl(i).ar_invoice_number := k_bal_lns_rec.ar_invoice_number ;
             ajlv_id_tbl(i).stream_meaning := k_bal_lns_rec.stream_meaning;
           END LOOP; -- balances res
           -- Call Okl_Account_Dist_Pub API to create accounting entries for this transaction
           -- Call new signature
          Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => p_api_version,
                                  p_init_msg_list      => OKL_API.G_FALSE,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
                                  p_trx_header_id      => lx_adjv_rec.id,
                                  p_trx_header_table  =>'OKL_TRX_AR_ADJSTS_B');

            -- store the highest degree of error
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
            Okl_Api.set_message(p_app_name     => g_app_name,
                                             p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                                             p_token1       => g_contract_number_token,
                                             p_token1_value => p_khr_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          -- record that there was an error
            Okl_Api.set_message(p_app_name     => g_app_name,
                                             p_msg_name     => 'OKL_AGN_CRE_DIST_ERROR',
                                             p_token1       => g_contract_number_token,
                                             p_token1_value => p_khr_rec.contract_number);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;

 -- rmunjulu 4917286 update writeoff transaction with total amount
           -- *** UPDATE WRITEOFF TRANSACTION IN OKL_TRX_CONTRACTS ** START *
         lpp_tcnv_rec.id := lx_tcnv_rec.id;
         lpp_tcnv_rec.amount := l_total_amount;

           OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
           p_api_version=> p_api_version,
           p_init_msg_list=> OKL_API.G_FALSE,
               x_return_status => l_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_tcnv_rec       => lpp_tcnv_rec,
               x_tcnv_rec       => lxx_tcnv_rec);

           -- Raise exception to rollback this whole block
           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

          OPEN  get_account_derivation_meth;
          FETCH get_account_derivation_meth INTO l_account_derivation;
          CLOSE get_account_derivation_meth;

        -- *** CREATE ACCOUNTING DISTRIBUTIONS ******* END   ***********
       FOR i IN ajlv_id_tbl.FIRST..ajlv_id_tbl.LAST
       LOOP
          IF l_account_derivation = 'ATS' THEN
       -- *** GET CCID FROM ACCOUNTING DISTRIBUTIONS **** START *******
      -- Get the first code_combination_id for the transaction
             -- from OKL_TRNS_ACC_DSTRS_V
             OPEN  code_combination_id_csr(ajlv_id_tbl(i).id, 'OKL_TXL_ADJSTS_LNS_B');
             FETCH code_combination_id_csr INTO l_code_combination_id;
             CLOSE code_combination_id_csr;
             -- if code_combination_id not found then raise error
             IF l_code_combination_id = -1 OR l_code_combination_id IS NULL THEN

               -- Error: Unable to process small balance
               -- adjustments because of a missing Code Combination ID for the
               -- contract CONTRACT_NUMBER.
               OKL_API.set_message(
                               p_app_name    => G_APP_NAME,
                               p_msg_name    => 'OKL_AM_CODE_CMB_ERROR',
                               p_token1      => 'CONTRACT_NUMBER',
                               p_token1_value=> p_khr_rec.contract_number);

               IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'code_comb_err = '||l_return_status );
               END IF;

               RAISE OKL_API.G_EXCEPTION_ERROR;

             END IF;

             -- *** GET CCID FROM ACCOUNTING DISTRIBUTIONS **** END   *******

             -- ******** UPDATE TRN LINE WITH CCID ************* START ******

             lp_ajlv_rec := l_ajlv_rec; -- Empty the rec

             -- Set the rec with CCID got from accounting distibutions
             lp_ajlv_rec.id  := ajlv_id_tbl(i).id;
             lp_ajlv_rec.code_combination_id  :=   l_code_combination_id;

             lx_ajlv_rec := l_ajlv_rec; -- Empty the rec

             --call the txl_lns_adjsts
             OKL_TXL_ADJSTS_LNS_PUB.update_txl_adjsts_lns(
                   p_api_version      => p_api_version,
                   p_init_msg_list    => OKL_API.G_FALSE,
                   x_return_status    => l_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data,
                   p_ajlv_rec            => lp_ajlv_rec,
                   x_ajlv_rec            => lx_ajlv_rec);

             IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                  -- Error occurred when creating adjustment records to write
                  -- off balances.
                  OKL_API.set_message( p_app_name     => G_APP_NAME,
                                       p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
             END IF;

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'OKL_TXL_ADJSTS_LNS_PUB.update_txl_adjsts_lns = '||l_return_status );
             END IF;

             -- Raise exception to rollback this whole block
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
           END IF;
   -- ******** UPDATE TRN LINE WITH CCID ************* END     ******
    -- Format the adjustment amt
             l_formatted_adj_amt  := OKL_ACCOUNTING_UTIL.format_amount(
                                                            ajlv_id_tbl(i).amount,
                                                            l_currency_code);

             -- Append adjustment amt with currency code
             l_formatted_adj_amt  := l_formatted_adj_amt || ' ' ||l_currency_code;

             -- Adjustment transaction for AR invoice AR_INVOICE_NUM of amount AMOUNT
             -- has been created.
             OKL_API.set_message(
                                p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_ACC_ENT_AR_INV_MSG',
                                p_token1        => 'AR_INVOICE_NUM',
                                p_token1_value  => ajlv_id_tbl(i).ar_invoice_number,
                                p_token2        => 'AMOUNT',
                                p_token2_value  => l_formatted_adj_amt);

             -- Accounting entries created for transaction type TRX_TYPE
             -- and stream type STREAM_TYPE.
             OKL_API.set_message(
                                p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_ACC_ENT_CREATED_MSG',
                                p_token1        => 'TRX_TYPE',
                                p_token1_value  => l_trans_meaning,
                                p_token2        => 'STREAM_TYPE',
                                p_token2_value  => ajlv_id_tbl(i).stream_meaning);
      END LOOP;
   ELSE  --(cannot close all balances since tolerance amt is less)

          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'cannot_close_bal = '||'E' );
          END IF;

          -- Get the currency code for contract
          l_currency_code      := OKL_AM_UTIL_PVT.get_chr_currency(p_khr_rec.id);

          -- Format the balance amt
          l_formatted_bal_amt  := OKL_ACCOUNTING_UTIL.format_amount(l_total_amount_due,l_currency_code);

          -- Append balance amt with currency code
          l_formatted_bal_amt  := l_formatted_bal_amt || ' ' ||l_currency_code;

          -- Format the tolerance amt
          l_formatted_tol_amt  := OKL_ACCOUNTING_UTIL.format_amount(l_tolerance_amt,l_currency_code);

          -- Append tolerance amt with currency code
          l_formatted_tol_amt  := l_formatted_tol_amt || ' ' ||l_currency_code;

          -- Outstanding balance BALANCE_AMT exceeds Tolerance Amount TOLERANCE_AMT.
          OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_BAL_GTR_TOL',
                             p_token1        => 'BALANCE_AMT',
                             p_token1_value  => l_formatted_bal_amt,
                             p_token2        => 'TOLERANCE_AMT',
                             p_token2_value  => l_formatted_tol_amt);

          RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
     ELSE

          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                       'no_balance = '||'E' );
          END IF;

          -- No outstanding balance.
          OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name        => 'OKL_AM_BAL_TOT_ZERO');

          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     x_return_status      := l_return_status;

     -- End Activity
     OKL_API.end_activity (x_msg_count, x_msg_data);

     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                        'End(-)');
     END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                             'EXP - ERROR');
           END IF;


    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                             'EXP - UNEXCP ERROR');
           END IF;

    WHEN OTHERS THEN
         IF k_balances_csr%ISOPEN THEN
            CLOSE k_balances_csr;
         END IF;
         IF k_bal_lns_csr%ISOPEN THEN
            CLOSE k_bal_lns_csr;
         END IF;
         IF code_combination_id_csr%ISOPEN THEN
            CLOSE code_combination_id_csr;
         END IF;

         x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.write_off_balances.',
                             'EXP - OTHERS');
           END IF;

  END write_off_balances;

  -- Start of comments
  --
  -- Procedure Name  : do_write_off_balances
  -- Description     : procedure to terminate Vendor Program
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE do_write_off_balances(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_khr_rec        IN   khr_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_overall_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_trx_id NUMBER;
        l_pdt_id NUMBER;
        l_khr_rec khr_rec_type := p_khr_rec;
        l_sys_date DATE;
        l_trn_already_yn VARCHAR2(1);
        l_end_date DATE;
        l_start_date DATE;
        l_type VARCHAR2(300);
        l_status VARCHAR2(300);
        l_control_flag VARCHAR2(300);
        l_valid_gl_date DATE;
        l_step VARCHAR2(50);
        l_validate_status VARCHAR2(3);
        l_update_status VARCHAR2(3);

     lx_error_rec  OKL_API.error_rec_type;
        l_msg_idx     INTEGER := G_FIRST;
        l_msg_tbl msg_tbl_type;
        l_api_name VARCHAR2(30) := 'do_write_off_balances';
      l_api_version CONSTANT NUMBER := G_API_VERSION;

        G_EXCEPTION EXCEPTION;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                        'Begin(+)');
       END IF;

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

       -- Rollback if error setting activity for api
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       SELECT sysdate INTO l_sys_date FROM DUAL;

       -- populate khr rec
       populate_khr_prg(
                    p_khr_rec        =>  p_khr_rec,
                    x_khr_rec        =>  l_khr_rec,
                    x_return_status  =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                       'populate_khr_prg = '||l_return_status );
       END IF;

       IF l_return_status <> G_RET_STS_SUCCESS THEN
         l_khr_rec := p_khr_rec;
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- validate khr if single contract
       validate_khr_prg(
                    p_khr_rec        =>  l_khr_rec,
                    p_control_flag   =>  p_control_flag,
                    x_return_status  =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                       'validate_khr_prg = '||l_return_status );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- write off balances
       write_off_balances(
                       p_api_version    =>  p_api_version,
                       p_init_msg_list  =>  OKL_API.G_FALSE,
                       x_return_status  =>  l_return_status,
   x_msg_count      =>  x_msg_count,
   x_msg_data       =>  x_msg_data,
                       p_khr_rec        =>  l_khr_rec,
                       p_sys_date       =>  l_sys_date,
                       p_control_flag   =>  p_control_flag);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                       'write_off_balances = '||l_return_status );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set the output log if request from BATCH
       IF p_control_flag LIKE 'BATCH%' THEN

           fnd_output  (
                  p_khr_rec      => l_khr_rec,
                  p_control_flag => 'PROCESSED');

       END IF;

       -- set return status
       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_khr_rec      => l_khr_rec,
                  p_control_flag => 'ERROR');
            END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_khr_rec      => l_khr_rec,
                  p_control_flag => 'ERROR');
            END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_khr_rec      => l_khr_rec,
                  p_control_flag => 'ERROR');
            END IF;

            x_return_status := OKL_API.handle_exceptions(
                                       p_api_name  => l_api_name,
                                       p_pkg_name  => G_PKG_NAME,
                                       p_exc_name  => 'OTHERS',
                                       x_msg_count => x_msg_count,
                                       x_msg_data  => x_msg_data,
                                       p_api_type  => '_PVT');

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_BAL_WRITEOFF_PVT.do_write_off_balances.',
                             'EXP - OTHERS');
           END IF;

  END do_write_off_balances;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_bal_writeoff_prg
  -- Description     : This procedure is called by concurrent manager to do balance writeoff
  --                   for terminated/expired contracts. When running the concurrent
  --                   manager request, a request can be made for a single contract
  --                   or else all the terminated contracts will be picked
  --                   If No End Date is Passed Defaulted to SysDate
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE concurrent_bal_writeoff_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_khr_id         IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL) IS

       -- Get the terminated/expired contracts for the org
       CURSOR get_expired_khr_csr (p_date IN DATE) IS
            SELECT  CHR.id,
                    CHR.contract_number contract_number
            FROM    OKC_K_HEADERS_B CHR,
                    OKL_K_HEADERS KHR
            WHERE   KHR.ID = CHR.ID
            AND     CHR.sts_code IN ('TERMINATED','EXPIRED') -- TERMINATED/EXPIRED
            AND     trunc(CHR.date_terminated) <= TRUNC(p_date)   -- Ended
            AND     CHR.id NOT IN (-- balance writeoffs already done when contract was fully terminated
                                   SELECT TRN.khr_id
                                   FROM   OKL_TRX_AR_ADJSTS_V BAL,
                                          OKL_TRX_CONTRACTS TRN
                                   WHERE  BAL.tcn_id = TRN.id
                                   AND    TRN.tcn_type = 'TMT' -- full termination
                                   AND    TRN.khr_id = CHR.id
                                   -- No need to check for actual step as tcn_id is recorded in AR_ADJSTS table
                                   )
            AND     CHR.id NOT IN (-- new balance writeoffs done as part of this concurrent program
                                   SELECT TRN.khr_id
                                   FROM   OKL_TRX_CONTRACTS TRN
                                   WHERE  TRN.tcn_type = 'BWO' -- new transaction type SEED ***
                                   AND    TRN.khr_id = CHR.id
                                   )
            AND     0 <    ( -- Check that invoices with balances greater than 0 exists and dated before today
/*  rmunjulu R12 Fixes - Billing fixes -- replaced with new select below
                SELECT  sum(BPD.amount_due_remaining)
                            FROM    OKL_BPD_LEASING_PAYMENT_TRX_V BPD
                            WHERE   BPD.invoice_date <= sysdate
AND     BPD.contract_id = CHR.id
*/
-- rmunjulu R12 Fixes - Billing fixes -- changes to this select as old bpd view does not work anymore
                            SELECT  sum(RACTRL.amount_due_remaining)
                            FROM    OKL_BPD_TLD_AR_LINES_V RACTRL
                            WHERE   RACTRL.invoice_date <= sysdate
                            AND     RACTRL.khr_id = CHR.id
   );


        l_return_status  VARCHAR2(3);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(2000);
        l_date           DATE;
        l_api_version    NUMBER;
        l_khr_id         NUMBER;
        l_khr_rec        khr_rec_type;

        TYPE get_expired_khr_tbl_type IS TABLE OF get_expired_khr_csr%ROWTYPE INDEX BY BINARY_INTEGER;
        get_expired_khr_tbl get_expired_khr_tbl_type;
        i NUMBER;

  BEGIN

       -- Initialize message list
       OKL_API.init_msg_list('T');

       -- Set Processing date
       IF p_date IS NULL THEN
           l_date := sysdate;
       ELSE
           l_date := TO_DATE(p_date, 'MM/DD/YYYY');
           IF l_date > TRUNC(sysdate) THEN
               G_ERROR := 'Y';
           END IF;
       END IF;

       -- If no error then
       IF G_ERROR <> 'Y' THEN

          G_KHR_ENDED_BY_DATE := TRUNC(l_date);

          l_api_version := TO_NUMBER(p_api_version);
          l_khr_id := TO_NUMBER(p_khr_id);

          -- Check if a single IA termination request
          IF l_khr_id IS NOT NULL THEN

             l_khr_rec.id := l_khr_id;

             -- do balance writeoff
             do_write_off_balances(
                 p_api_version     =>  l_api_version,
                 p_init_msg_list   =>  p_init_msg_list,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  l_msg_count,
                 x_msg_data        =>  l_msg_data,
                 p_khr_rec         =>  l_khr_rec,
                 p_control_flag    =>  'BATCH_SINGLE');

          ELSE  -- no contract passed

             -- Do a bulk fetch of all eligible contracts
             OPEN get_expired_khr_csr (G_KHR_ENDED_BY_DATE);
             FETCH get_expired_khr_csr BULK COLLECT INTO get_expired_khr_tbl;
             CLOSE get_expired_khr_csr;

             -- for each contract call do writeoff
             IF get_expired_khr_tbl.count > 0 THEN
                FOR i IN get_expired_khr_tbl.first..get_expired_khr_tbl.last LOOP

                   l_khr_rec.id := get_expired_khr_tbl(i).id;
                   l_khr_rec.contract_number := get_expired_khr_tbl(i).contract_number;

                   -- Do balance writeoff
                   do_write_off_balances(
                         p_api_version     =>  l_api_version,
                         p_init_msg_list   =>  p_init_msg_list,
                         x_return_status   =>  l_return_status,
                         x_msg_count       =>  l_msg_count,
                         x_msg_data        =>  l_msg_data,
                         p_khr_rec         =>  l_khr_rec,
                         p_control_flag    =>  'BATCH_MULTIPLE');

                END LOOP;
             END IF;
          END IF;
       END IF;

       -- Create the Output Report
       create_report;

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

  END concurrent_bal_writeoff_prg;

END OKL_AM_BAL_WRITEOFF_PVT;

/
