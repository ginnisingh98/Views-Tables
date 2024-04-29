--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMNT_VENDOR_PRG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMNT_VENDOR_PRG_PVT" AS
/* $Header: OKLRTVPB.pls 120.3.12010000.2 2008/10/01 22:52:54 rkuttiya ship $ */

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
           va_number        VARCHAR2(300),
           start_date       DATE,
           end_date         DATE,
           status           VARCHAR2(300) );

  -- Table Type to Store Recs of Message details with IA details
  TYPE message_tbl_type IS TABLE OF message_rec_type INDEX BY BINARY_INTEGER;

  -- Rec Type to Store Lease K Details
  TYPE va_k_rec_type IS RECORD (
           id                NUMBER,
           va_number         OKC_K_HEADERS_B.contract_number%TYPE,
           start_date        DATE,
           end_date          DATE,
           sts_code          OKC_K_HEADERS_B.sts_code%TYPE,
           date_terminated   DATE);

  -- Table Type to store Recs of IA Details
  TYPE va_k_tbl_type IS TABLE OF va_k_rec_type INDEX BY BINARY_INTEGER;

  -- SUBTYPE the transaction Rec Type
  SUBTYPE tcnv_rec_type IS OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;

  -- *********************
  -- GLOBAL MESSAGE CONSTANTS
  -- *********************
  G_INVALID_VALUE	 CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN	 CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'ERROR_CODE';

  -- *********************
  -- GLOBAL VARIABLES
  -- *********************
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_TERMNT_VENDOR_PRG_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
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
  G_VPA_ENDED_BY_DATE    DATE;
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
  -- Procedure Name	: fnd_error_output
  -- Desciption     : Logs the messages in the output log
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
  -- History        : RMUNJULU created
  --
  -- End of comments
  PROCEDURE fnd_output  (
                  p_va_rec       IN  va_rec_type,
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
                 msg_lines_table(l_error_count).id := p_va_rec.id;
                 msg_lines_table(l_error_count).msg := lx_error_rec.msg_data;

                 l_error_count := l_error_count + 1;
     	  	END IF;

      		EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
      			 OR (lx_error_rec.msg_count IS NULL));

      		l_msg_idx	:= G_NEXT;

       END LOOP;


       IF p_control_flag = 'PROCESSED' THEN

          success_message_table(l_success_tbl_index).id := p_va_rec.id;
          success_message_table(l_success_tbl_index).va_number := p_va_rec.va_number;
          success_message_table(l_success_tbl_index).start_date  := p_va_rec.start_date;
          success_message_table(l_success_tbl_index).end_date  := p_va_rec.end_date;
          success_message_table(l_success_tbl_index).status  := p_va_rec.sts_code;
          l_success_tbl_index := l_success_tbl_index + 1;

       ELSE

          error_message_table(l_error_tbl_index).id := p_va_rec.id;
          error_message_table(l_error_tbl_index).va_number := p_va_rec.va_number;
          error_message_table(l_error_tbl_index).start_date  := p_va_rec.start_date;
          error_message_table(l_error_tbl_index).end_date  := p_va_rec.end_date;
          error_message_table(l_error_tbl_index).status  := p_va_rec.sts_code;
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
  -- Procedure Name	: create_report
  -- Desciption     : Creates the Output and Log Reports
  -- Business Rules	:
  -- Parameters	    :
  -- Version		: 1.0
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
         l_vpa_ended_by      VARCHAR2(300);
         l_vpa               VARCHAR2(300);
         l_print             VARCHAR2(1);
         msg_lines_table_index  NUMBER;

  BEGIN

       l_success := success_message_table.COUNT;
       l_error   := error_message_table.COUNT;

       l_orcl_logo      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_ACCT_LEASE_MANAGEMENT');
       l_term_heading   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_TERM_VPA'); --***
       l_set_of_books   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_SET_OF_BOOKS');
       l_run_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_RUN_DATE');
       l_oper_unit      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_OPERUNIT');
       l_type           := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_TYPE');
       l_processed      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_PROCESSED_ENTRIES');
       l_term_k         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_EXP_VPA'); --***
       l_error_k        := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_ERR_VPA'); --***
       l_serial         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_SERIAL_NUMBER');
       l_k_num          := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_VPA_NUMBER');  --***
       l_start_date     := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_START_DATE');
       l_end_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_END_DATE');
       l_status         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_STATUS');
       l_messages       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_MESSAGES');
       l_eop            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_END_OF_REPORT');
       l_vpa_ended_by   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_VPA_ENDED_BY'); --***
       l_vpa            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_VPA_CONC_OUTPUT','OKL_AM_INVALID_TERM_DATE');

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
                                          RPAD(' ', 128-LENGTH(l_oper_unit)-LENGTH(l_org_name)-LENGTH(l_vpa_ended_by)-25, ' ' ) ||
                                          l_vpa_ended_by  ||' : ' ||
                                          TO_CHAR(G_VPA_ENDED_BY_DATE, 'DD-MON-YYYY HH24:MI'));

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
                                               success_message_table(i).va_number ||
                                               RPAD(' ',35-LENGTH(success_message_table(i).va_number),' ')||
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
                                               error_message_table(i).va_number ||
                                               RPAD(' ',35-LENGTH(error_message_table(i).va_number),' ')||
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
       FND_FILE.put_line(FND_FILE.log,l_vpa);

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
  -- Procedure Name  : val_pop_vendor_prg
  -- Description     : procedure to validate and populate vendor program
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE val_pop_vendor_prg(
                    p_va_rec         IN   va_rec_type,
                    p_control_flag   IN   VARCHAR2,
                    x_va_rec         OUT  NOCOPY va_rec_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- Get the details of the VPA
       CURSOR get_va_details_csr (p_va_id IN NUMBER) IS
            SELECT   CHR.id,
                     CHR.contract_number va_number,
                     CHR.START_DATE,
                     CHR.end_date,
                     CHR.sts_code, -- Should be ACTIVE
                     CHR.scs_code  -- Should be PROGRAM or OPERATING
            FROM     OKC_K_HEADERS_B CHR,
                     OKL_K_HEADERS   KHR
            WHERE    CHR.id = p_va_id
            AND      CHR.id = KHR.id;

       -- Get the IA TRN for Termination ie TCN_TYPE =  'IAT'
       CURSOR get_trn_csr (p_va_id IN NUMBER) IS
            SELECT   TRN.tsu_code
            FROM     OKL_TRX_CONTRACTS TRN
            WHERE    TRN.khr_id = p_va_id
           --rkuttiya added for 12.1.1 Multi GAAP
            AND      TRN.representation_type = 'PRIMARY'
           --
            AND      TRN.tcn_type = 'IAT';

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_ia_number  VARCHAR2(300);
        l_start_date DATE;
        l_end_date   DATE;
        l_status     VARCHAR2(300);
        l_type       VARCHAR2(300);
        l_pdt_id     NUMBER;
        i NUMBER := 0;
        l_tsu_code  VARCHAR2(300);
        l_va_rec    va_rec_type;
        get_va_details_rec get_va_details_csr%ROWTYPE;

  BEGIN

       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       -- Begin Logic
       -- 0   Get the IA details
       -- 1.1 Throw error if VPA ID/Number not valid
       -- 1.2 Throw error if VPA type not valid
       -- 1.3 Throw error if VPA End Date not valid
       -- End Logic
       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.val_pop_vendor_prg.',
                        'Begin(+)');
       END IF;

       SAVEPOINT validate_va_trx;

       -- Get VPA details
       OPEN get_va_details_csr (p_va_rec.id);
       FETCH get_va_details_csr INTO get_va_details_rec;
       CLOSE get_va_details_csr;

       -- Set the va rec with VPA details
       l_va_rec.id := get_va_details_rec.id;
       l_va_rec.va_number := get_va_details_rec.va_number;
       l_va_rec.start_date := get_va_details_rec.start_date;
       l_va_rec.end_date := get_va_details_rec.end_date;
       l_va_rec.sts_code := get_va_details_rec.sts_code;
       l_va_rec.date_terminated := sysdate;
       l_va_rec.scs_code := get_va_details_rec.scs_code;

       -- If single request then do additional validations
       IF p_control_flag = 'BATCH_SINGLE' THEN -- Do additional checks

           -- Check for ID
           IF get_va_details_rec.id IS NULL
		   OR get_va_details_rec.id = OKL_API.G_MISS_NUM THEN

                -- Message: Invalid value for Vendor Program ID.
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VPA_ID_INVALID');

                RAISE G_EXCEPTION_ERROR;
           END IF;

		   -- Check for type
           IF get_va_details_rec.scs_code NOT IN ('PROGRAM','OPERATING') THEN

                -- Message: Invalid value for Program Type for Vendor Program VPA_NUMBER.
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VPA_TYPE_INVALID',
                          p_token1         => 'VPA_NUMBER',
                          p_token1_value   => get_va_details_rec.va_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

           -- Check for status
           IF get_va_details_rec.sts_code NOT IN ('ACTIVE') THEN

                -- Message: Invalid value for Program Status for Vendor Program VPA_NUMBER.
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VPA_STATUS_INVALID',
                          p_token1         => 'VPA_NUMBER',
                          p_token1_value   => get_va_details_rec.va_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

           -- Check for end date
           IF trunc(get_va_details_rec.end_date) > G_VPA_ENDED_BY_DATE THEN -- G_VPA_ENDED_BY_DATE is passed by user

                -- Message: Program VPA_NUMBER has not reached its end date.
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_VPA_END_DATE_INVALID',
                          p_token1         => 'VPA_NUMBER',
                          p_token1_value   => get_va_details_rec.va_number);

                RAISE G_EXCEPTION_ERROR;
           END IF;

       END IF;

       -- Set return values
       x_return_status :=  l_return_status;
       x_va_rec        :=  l_va_rec;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.val_pop_vendor_prg.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO validate_va_trx;
            x_return_status := G_RET_STS_ERROR;
            x_va_rec        :=  l_va_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.val_pop_vendor_prg.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_va_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_va_rec        :=  l_va_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.val_pop_vendor_prg.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO validate_va_trx;
            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_va_rec        :=  l_va_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.val_pop_vendor_prg.',
                             'EXP - OTHERS');
           END IF;

  END val_pop_vendor_prg;

  -- Start of comments
  --
  -- Procedure Name  : pop_or_insert_transaction
  -- Description     : procedure to insert termination transaction for the VPA
  --                   if does not exist or else if exists then populate
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE pop_or_insert_transaction(
                    p_va_rec            IN   va_rec_type,
                    p_sys_date          IN   DATE,
                    p_validate_success  IN   VARCHAR2,
                    x_trn_already_yn    OUT  NOCOPY VARCHAR2,
                    px_tcnv_rec         IN OUT  NOCOPY tcnv_rec_type,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        -- Get the trn if exists
        CURSOR get_trn_csr ( p_ia_id IN NUMBER ) IS
        SELECT   TRN.id,
                 TRN.trx_number,
                 TRN.tsu_code,
                 TRN.tcn_type,
                 TRN.try_id,
                 TRN.khr_id,
                 TRN.tmt_validated_yn,
                 TRN.tmt_accounting_entries_yn,
                 TRN.tmt_contract_updated_yn,
                 TRN.tmt_recycle_yn,
                 TRN.tmt_generic_flag1_yn,
                 TRN.tmt_generic_flag2_yn,
                 TRN.tmt_generic_flag3_yn
        FROM     OKL_TRX_CONTRACTS TRN
        WHERE    TRN.khr_id = p_ia_id
        --rkuttiya added for 12.1.1 Multi GAAP
        AND      TRN.representation_type = 'PRIMARY'
        --
        AND      TRN.tcn_type = 'IAT';

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        lp_tcnv_rec   tcnv_rec_type ;
        lx_tcnv_rec   tcnv_rec_type ;
        l_try_id NUMBER;
        l_currency_code VARCHAR2(2000);
        l_trans_meaning VARCHAR2(2000);
        l_trn_already_yn VARCHAR2(1) := G_NO;

        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.pop_or_insert_transaction.',
                        'Begin(+)');
       END IF;

       SAVEPOINT pop_insert_trn_trx;

       -- *************
  	   -- Populate TRN if exists
       -- *************
       FOR get_trn_rec IN get_trn_csr ( p_va_rec.id ) LOOP

           lx_tcnv_rec.id                        := get_trn_rec.id;
           lx_tcnv_rec.tsu_code                  := get_trn_rec.tsu_code;
           lx_tcnv_rec.trx_number                := get_trn_rec.trx_number;
           lx_tcnv_rec.tcn_type                  := get_trn_rec.tcn_type;
           lx_tcnv_rec.try_id                    := get_trn_rec.try_id;
           lx_tcnv_rec.khr_id                    := get_trn_rec.khr_id;
           lx_tcnv_rec.tmt_validated_yn          := get_trn_rec.tmt_validated_yn;
           lx_tcnv_rec.tmt_accounting_entries_yn := get_trn_rec.tmt_accounting_entries_yn;
           lx_tcnv_rec.tmt_contract_updated_yn   := get_trn_rec.tmt_contract_updated_yn;
           lx_tcnv_rec.tmt_recycle_yn            := get_trn_rec.tmt_recycle_yn;
           lx_tcnv_rec.tmt_generic_flag1_yn      := get_trn_rec.tmt_generic_flag1_yn;
           lx_tcnv_rec.tmt_generic_flag2_yn      := get_trn_rec.tmt_generic_flag2_yn;
           lx_tcnv_rec.tmt_generic_flag3_yn      := get_trn_rec.tmt_generic_flag3_yn;
           l_trn_already_yn := G_YES;

       END LOOP;

       -- *************
	   -- Insert TRN if not exists
  	   -- *************
       IF lx_tcnv_rec.id IS NULL
       OR lx_tcnv_rec.id = G_MISS_NUM THEN

           -- Get the Transaction Id
           OKL_AM_UTIL_PVT.get_transaction_id (
  	                           p_try_name	    => 'Termination',
	                           x_return_status  => l_return_status,
  	                           x_try_id		    => l_try_id);

           -- Get the meaning of lookup OKL_ACCOUNTING_EVENT_TYPE
           l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                   p_lookup_type  => 'OKL_ACCOUNTING_EVENT_TYPE',
                                   p_lookup_code  => 'TERMINATION',
                                   p_validate_yn  => G_YES);

           IF l_return_status <> G_RET_STS_SUCCESS THEN

                -- Message: Unable to find a transaction type for the transaction TRY_NAME -- Seeded
                OKL_API.set_message(
                          p_app_name       => G_APP_NAME,
                          p_msg_name       => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1         => 'TRY_NAME',
                          p_token1_value   => l_trans_meaning);

                RAISE G_EXCEPTION_ERROR;

           END IF;

           -- Get the contract currency code
           l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_va_rec.id);

           -- Set the TRN rec
           lp_tcnv_rec.khr_id   := p_va_rec.id;
           lp_tcnv_rec.tsu_code := 'ENTERED';
           lp_tcnv_rec.tcn_type := 'IAT';
           lp_tcnv_rec.try_id   := l_try_id;
           lp_tcnv_rec.currency_code := l_currency_code;
           lp_tcnv_rec.date_transaction_occurred := p_sys_date;

           -- Call create_trx_contracts to create transaction
           OKL_TRX_CONTRACTS_PUB.create_trx_contracts(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_tcnv_rec       => lp_tcnv_rec,
                           x_tcnv_rec       => lx_tcnv_rec);

           -- Set msg if error
           IF l_return_status <> G_RET_STS_SUCCESS THEN
                 -- Error occured while creating termination transaction for the
                 -- Investor Agreement AGREEMENT_NUMBER..
                 OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_TRN_CREATE_ERR');
           END IF;

           -- raise exception if create failed
           IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
           END IF;

           -- Set if TRN was already existing
           l_trn_already_yn := G_NO;

       END IF;

       -- Set return values
       x_return_status  :=  l_return_status;
       px_tcnv_rec      :=  lx_tcnv_rec;
       x_trn_already_yn :=  l_trn_already_yn;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.pop_or_insert_transaction.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO pop_insert_trn_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.pop_or_insert_transaction.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO pop_insert_trn_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.pop_or_insert_transaction.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO pop_insert_trn_trx;

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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.pop_or_insert_transaction.',
                             'EXP - OTHERS');
           END IF;

  END pop_or_insert_transaction;

  -- Start of comments
  --
  -- Procedure Name  : update_transaction
  -- Description     : procedure to update termination transaction for the VPA
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_transaction(
                    p_va_rec            IN   va_rec_type,
                    p_status            IN   VARCHAR2,
                    p_step              IN   VARCHAR2,
                    px_tcnv_rec         IN OUT NOCOPY tcnv_rec_type,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
        lp_tcnv_rec     tcnv_rec_type;
        lx_tcnv_rec     tcnv_rec_type;
        l_api_version   CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	    NUMBER := G_MISS_NUM;
        l_msg_data      VARCHAR2(2000);
        l_status        VARCHAR2(3);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                        'Begin(+)');
       END IF;

       SAVEPOINT update_transaction_trx;

       lp_tcnv_rec := px_tcnv_rec;

       IF p_step = 'tmt_contract_updated_yn' THEN -- If last step
          IF p_status = G_RET_STS_SUCCESS THEN
             lp_tcnv_rec.tsu_code := 'PROCESSED';
          ELSE
             lp_tcnv_rec.tsu_code := 'ERROR';
          END IF;
       ELSE
          IF p_status = G_RET_STS_SUCCESS THEN
             lp_tcnv_rec.tsu_code := 'WORKING';
          ELSE
             lp_tcnv_rec.tsu_code := 'ERROR';
          END IF;
       END IF;

       IF p_status = G_RET_STS_SUCCESS THEN
          l_status := 'Y';
       ELSE
          l_status := 'N';
       END IF;

       IF p_step = 'tmt_contract_updated_yn' THEN
          lp_tcnv_rec.tmt_contract_updated_yn := l_status;
       ELSIF p_step = 'tmt_validated_yn' THEN
          lp_tcnv_rec.tmt_validated_yn := l_status;
       END IF;

       -- Call update_trx_contracts to update transaction
       OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_tcnv_rec       => lp_tcnv_rec,
                           x_tcnv_rec       => lx_tcnv_rec);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                        'l_return_status '||l_return_status);
       END IF;

       -- Set msg if error
       IF l_return_status <> G_RET_STS_SUCCESS THEN
            -- Message: Error updating Program Agreement VPA_NUMBER.
            OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_VPA_UPD_TRN_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_va_rec.va_number);
       END IF;

       -- raise exception if update failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set return status
       x_return_status := l_return_status;
       px_tcnv_rec := lx_tcnv_rec;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_transaction_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_transaction_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO update_transaction_trx;

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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_transaction.',
                             'EXP - OTHERS');
           END IF;

  END update_transaction;

  -- Start of comments
  --
  -- Procedure Name  : update_vendor_prg
  -- Description     : procedure to update vendor program to EXPIRED
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_vendor_prg(
                    p_va_rec         IN   va_rec_type,
                    p_control_flag   IN   VARCHAR2,
                    px_va_rec        IN OUT NOCOPY va_rec_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        lp_chrv_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
        lp_khrv_rec  OKL_CONTRACT_PUB.khrv_rec_type;
        lx_chrv_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
        lx_khrv_rec  OKL_CONTRACT_PUB.khrv_rec_type;
        l_trn_reason_code  VARCHAR2(30) := 'EXP';
        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                        'Begin(+)');
       END IF;

       SAVEPOINT update_vpa_trx;

       -- Set the rec types
       lp_chrv_rec.id  := px_va_rec.id;
       lp_khrv_rec.id  := px_va_rec.id;
       lp_chrv_rec.date_terminated := sysdate;
       lp_chrv_rec.sts_code  := 'EXPIRED';
       lp_chrv_rec.trn_code  := l_trn_reason_code;

       -- Call update contract to expire VPA
       OKL_CONTRACT_PUB.update_contract_header(
                      p_api_version       => l_api_version,
                      p_init_msg_list     => G_FALSE,
                      x_return_status     => l_return_status,
                      x_msg_count         => l_msg_count,
                      x_msg_data          => l_msg_data,
                      p_chrv_rec          => lp_chrv_rec,
                      p_khrv_rec          => lp_khrv_rec,
                      x_chrv_rec          => lx_chrv_rec,
                      x_khrv_rec          => lx_khrv_rec);

	   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                        'l_return_status '||l_return_status);
       END IF;

       IF l_return_status <> G_RET_STS_SUCCESS THEN
            -- Message : Error updating Program Agreement VPA_NUMBER.
            OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_VPA_TRMNT_ERR',
                      p_token1        => 'VPA_NUMBER',
                      p_token1_value  => px_va_rec.va_number);
       END IF;

       -- raise exception if update failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- The VPA is now expired
       px_va_rec.sts_code := 'EXPIRED';

       -- Set return values
       x_return_status :=  l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_vpa_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_vpa_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO update_vpa_trx;
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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.update_vendor_prg.',
                             'EXP - OTHERS');
           END IF;

  END update_vendor_prg;


  -- Start of comments
  --
  -- Procedure Name  : terminate_vendor_prog
  -- Description     : procedure to terminate Vendor Program
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE terminate_vendor_prog(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_va_rec         IN   va_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_overall_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_trx_id NUMBER;
        l_pdt_id NUMBER;
        l_va_rec va_rec_type := p_va_rec;
        l_sys_date DATE;
        l_tcnv_rec tcnv_rec_type;
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
        l_api_name VARCHAR2(30) := 'terminate_vendor_prg';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;

        G_EXCEPTION EXCEPTION;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
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

       -- *************
       -- Validate and Populate VPA
       -- *************
       val_pop_vendor_prg(
                       p_va_rec         =>  p_va_rec,
                       p_control_flag   =>  p_control_flag,
                       x_va_rec         =>  l_va_rec,
                       x_return_status  =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                         'val_pop_vendor_prg = '||l_return_status );
       END IF;

       -- Set Overall Status
       IF  l_overall_status =  G_RET_STS_SUCCESS
       AND l_overall_status <> G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

/*
       l_validate_status := l_return_status;

       -- *************
       -- Populate or Insert VPA Transaction based on need
       -- *************
       pop_or_insert_transaction(
                       p_va_rec           =>  l_va_rec,
                       p_sys_date         =>  l_sys_date,
                       p_validate_success =>  l_overall_status,
                       x_trn_already_yn   =>  l_trn_already_yn,
                       px_tcnv_rec        =>  l_tcnv_rec,
                       x_return_status    =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                         'pop_or_insert_transaction = '||l_return_status );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

       l_step := 'tmt_validated_yn';

       -- *************
       -- Update VPA Transaction based on validate_YN success or fail
       -- *************
       update_transaction(
                   p_va_rec           =>  l_va_rec,
                   p_status           =>  l_validate_status,
                   p_step             =>  l_step,
                   px_tcnv_rec        =>  l_tcnv_rec,
                   x_return_status    =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_vendor_prog.',
                         'update_transaction = '||l_return_status ||
						 'l_step = '||l_step );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
       END IF;

*/
       -- *************
       -- Update VPA
       -- *************
       IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

          update_vendor_prg(
                       p_va_rec         =>  p_va_rec,
                       p_control_flag   =>  p_control_flag,
                       px_va_rec        =>  l_va_rec,
                       x_return_status  =>  l_return_status);

          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                         'update_vendor_prg = '||l_return_status );
          END IF;

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE G_EXCEPTION_ERROR;
          END IF;

/*
          l_step := 'tmt_contract_updated_yn';
          l_update_status := l_return_status;

          -- *************
          -- Update VPA Transaction based on contract_updated_YN success or fail
          -- *************
          update_transaction(
                   p_va_rec           =>  l_va_rec,
                   p_status           =>  l_update_status,
                   p_step             =>  l_step,
                   px_tcnv_rec        =>  l_tcnv_rec,
                   x_return_status    =>  l_return_status);

          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_vendor_prog.',
                         'update_transaction = '||l_return_status ||
						 'l_step = '||l_step );
          END IF;

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
          END IF;
*/
       END IF;

/*
       -- Store messages in TRX_MSGS
       OKL_AM_UTIL_PVT.process_messages(
              	   p_trx_source_table  => 'OKL_TRX_CONTRACTS_V',
               	   p_trx_id		       => l_tcnv_rec.id,
               	   x_return_status     => l_return_status);

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;
*/

       -- Set the output log if request from BATCH
       IF p_control_flag LIKE 'BATCH%' THEN

           fnd_output  (
                  p_va_rec       => l_va_rec,
                  p_control_flag => 'PROCESSED');--l_tcnv_rec.tsu_code);

       END IF;

       -- set return status
       x_return_status := l_return_status;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_va_rec       => l_va_rec,
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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_va_rec       => l_va_rec,
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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_va_rec       => l_va_rec,
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
                             'OKL_AM_TERMNT_VENDOR_PRG_PVT.terminate_vendor_prog.',
                             'EXP - OTHERS');
           END IF;

  END terminate_vendor_prog;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_expire_vend_prg
  -- Description     : This procedure is called by concurrent manager to terminate
  --                   ended Vendor Program agreements. When running the concurrent
  --                   manager request, a request can be made for a single VPA to
  --                   be terminated or else all the ended VPAs will be picked
  --                   If No End Date is Passed Defaulted to SysDate
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --                 : RMUNJULU 115.4 3061748 Added code to throw error if
  --                   Termination Date is invalid
  --
  -- End of comments
  PROCEDURE concurrent_expire_vend_prg(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    p_va_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL) IS

       -- Get the VPAs which have reached their end_date and still active
       -- This cursor should NOT be org specific as it needs to pick all VPAs
       CURSOR get_expired_va_csr (p_date IN DATE) IS
            SELECT  CHR.id,
                    CHR.contract_number va_number
            FROM    OKC_K_HEADERS_B CHR
            WHERE   CHR.scs_code IN ('PROGRAM','OPERATING') -- VPAs
            AND     CHR.sts_code = 'ACTIVE' -- ACTIVE
            AND     CHR.date_terminated IS NULL -- Not Terminated
            AND     CHR.end_date <= TRUNC(p_date);   -- Ended

        l_return_status  VARCHAR2(3);
        l_msg_count      NUMBER;
        l_msg_data       VARCHAR2(2000);
        l_date           DATE;
        l_api_version    NUMBER;
        l_va_id          NUMBER;
        l_va_rec         va_rec_type;

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

          G_VPA_ENDED_BY_DATE := TRUNC(l_date);

          l_api_version := TO_NUMBER(p_api_version);
          l_va_id := TO_NUMBER(p_va_id);

          -- Check if a single IA termination request
          IF l_va_id IS NOT NULL THEN

             l_va_rec.id := l_va_id;

             -- Terminate the Vendor Program
             terminate_vendor_prog(
                 p_api_version     =>  l_api_version,
                 p_init_msg_list   =>  p_init_msg_list,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  l_msg_count,
                 x_msg_data        =>  l_msg_data,
                 p_va_rec          =>  l_va_rec,
                 p_control_flag    =>  'BATCH_SINGLE');

          ELSE  -- No Vendor Program passed, so scheduled request to terminate all expired Vendor Programs

             -- Loop thru the expired VPAs
             FOR get_expired_va_rec IN get_expired_va_csr(G_VPA_ENDED_BY_DATE) LOOP

                 l_va_rec.id := get_expired_va_rec.id;
                 l_va_rec.va_number := get_expired_va_rec.va_number;

                 -- Terminate the VPA
                 terminate_vendor_prog(
                         p_api_version     =>  l_api_version,
                         p_init_msg_list   =>  p_init_msg_list,
                         x_return_status   =>  l_return_status,
                         x_msg_count       =>  l_msg_count,
                         x_msg_data        =>  l_msg_data,
                         p_va_rec          =>  l_va_rec,
                         p_control_flag    =>  'BATCH_MULTIPLE');

             END LOOP;
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

  END concurrent_expire_vend_prg;

END OKL_AM_TERMNT_VENDOR_PRG_PVT;

/
