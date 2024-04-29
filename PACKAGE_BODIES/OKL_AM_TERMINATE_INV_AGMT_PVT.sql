--------------------------------------------------------
--  DDL for Package Body OKL_AM_TERMINATE_INV_AGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_TERMINATE_INV_AGMT_PVT" AS
/* $Header: OKLRTIAB.pls 120.10.12010000.3 2009/06/02 10:52:42 racheruv ship $ */


     -- *** Is there a need to check for POC.kle_id = STM.kle_id -- *** --
     -- YES always, since poc are for assets only, so should get sels for assets only


  -- GLOBAL VARIABLES
  success_message_table  message_tbl_type;
  error_message_table    message_tbl_type;
   -- sosharma added codes for tranaction_status
   G_POOL_TRX_STATUS_COMPLETE               CONSTANT VARCHAR2(30) := 'COMPLETE';

  -- SECHAWLA 26-JAN-04 3377730: new declarations
  msg_lines_table        msg_tbl_type;

  l_success_tbl_index NUMBER := 1;
  l_error_tbl_index NUMBER := 1;

  G_INV_ENDED_BY_DATE DATE;

  G_ERROR VARCHAR2(1) := 'N'; -- RMUNJULU 115.4 3061748

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
                  p_ia_rec       IN  ia_rec_type,
                  p_control_flag IN  VARCHAR2 ) IS

     	lx_error_rec  OKL_API.error_rec_type;
        l_msg_idx     INTEGER := G_FIRST;

       -- SECHAWLA  l_msg_tbl     msg_tbl_type;
        l_tbl_count  INTEGER := 0; --Bug 7007686
  BEGIN

       -- Get the messages in the log
       LOOP

  	    	FND_MSG_PUB.get(
   		  	       p_msg_index     => l_msg_idx,
			       p_encoded       => G_FALSE,
			       p_data          => lx_error_rec.msg_data,
			       p_msg_index_out => lx_error_rec.msg_count);

       		IF (lx_error_rec.msg_count IS NOT NULL) THEN

                 --Bug 7007686
                 l_tbl_count:=msg_lines_table.count+1;
                 msg_lines_table(l_tbl_count).id := p_ia_rec.id;
                 msg_lines_table(l_tbl_count).msg := lx_error_rec.msg_data;

                 /* --7007686
                 -- SECHAWLA 26-JAN-04 3377730: Store the contract id
                 msg_lines_table(lx_error_rec.msg_count).id := p_ia_rec.id;

                 -- SECHAWLA 26-JAN-04 3377730: populate message lines in a global pl/sql table
                 --l_msg_tbl(lx_error_rec.msg_count).msg := lx_error_rec.msg_data;

                 msg_lines_table(lx_error_rec.msg_count).msg := lx_error_rec.msg_data;
                 */ --7007686
     	  	END IF;

      		EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
      			 OR (lx_error_rec.msg_count IS NULL));

      		l_msg_idx	:= G_NEXT;

       END LOOP;

       IF p_control_flag = 'PROCESSED' THEN

          success_message_table(l_success_tbl_index).id := p_ia_rec.id;
          success_message_table(l_success_tbl_index).contract_number := p_ia_rec.contract_number;
          success_message_table(l_success_tbl_index).start_date  := p_ia_rec.start_date;
          success_message_table(l_success_tbl_index).end_date  := p_ia_rec.end_date;
          success_message_table(l_success_tbl_index).status  := p_ia_rec.sts_code;
          -- SECHAWLA  26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
          -- of db/Pl Sql  Removed the msg_tbl field from message_rec_type

          -- success_message_table(l_success_tbl_index).msg_tbl :=  l_msg_tbl;
          l_success_tbl_index := l_success_tbl_index + 1;

       ELSE

          error_message_table(l_error_tbl_index).id := p_ia_rec.id;
          error_message_table(l_error_tbl_index).contract_number := p_ia_rec.contract_number;
          error_message_table(l_error_tbl_index).start_date  := p_ia_rec.start_date;
          error_message_table(l_error_tbl_index).end_date  := p_ia_rec.end_date;
          error_message_table(l_error_tbl_index).status  := p_ia_rec.sts_code;
          -- SECHAWLA  26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
          -- of db/Pl Sql  Removed the msg_tbl field from message_rec_type

          -- error_message_table(l_error_tbl_index).msg_tbl :=  l_msg_tbl;
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
  --                : RMUNJULU 115.4 3061748
  --
  -- End of comments
  PROCEDURE create_report  IS

         i NUMBER;
         j NUMBER;
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
         -- RMUNJULU 115.4 3061748
         l_inv               VARCHAR2(300);

         l_print             VARCHAR2(1);

         -- SECHAWLA 26-JAN-04 3377730: New deaclarations
         msg_lines_table_index  NUMBER;

         --Bug 7007686
        l_msg_num  NUMBER:=0;
        --Bug 7007686 :End

  BEGIN

       l_success := success_message_table.COUNT;
       l_error   := error_message_table.COUNT;

       l_orcl_logo      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_ACCT_LEASE_MANAGEMENT');
       l_term_heading   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_TERM_INV');
       l_set_of_books   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SET_OF_BOOKS');
       l_run_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_RUN_DATE');
       l_oper_unit      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_OPERUNIT');
       l_type           := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_TYPE');
       l_processed      := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_PROCESSED_ENTRIES');
       l_term_k         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_TERMINATED_INV');
       l_error_k        := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_ERRORED_INV');
       l_serial         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_SERIAL_NUMBER');
       l_k_num          := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_INV_AGR_NUM');
       l_start_date     := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_START_DATE');
       l_end_date       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_DATE');
       l_status         := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_STATUS');
       l_messages       := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_MESSAGES');
       l_eop            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_END_OF_REPORT');
       l_inv_ended_by   := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INV_AGR_ENDED_BY');
       -- RMUNJULU 115.4 3061748
       l_inv            := OKL_ACCOUNTING_UTIL.get_message_token('OKL_AM_CONC_OUTPUT','OKL_AM_INVALID_TERM_DATE');

       l_set_of_books_name := OKL_ACCOUNTING_UTIL.get_set_of_books_name (OKL_ACCOUNTING_UTIL.get_set_of_books_id);

       -- Get the Org Name
       FOR org_rec IN org_csr (l_org_id)  LOOP
          l_org_name := org_rec.name;
       END LOOP;

       -- RMUNJULU 115.4 3061748
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
                                          TO_CHAR(G_INV_ENDED_BY_DATE, 'DD-MON-YYYY HH24:MI'));

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

       -- Print Investor Agreements Terminated Successfully
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

           --FND_FILE.put_line(FND_FILE.output,'');

           --FND_FILE.put_line(FND_FILE.output,  RPAD(' ',5,' ') || l_messages || ' :');

           --FOR j IN success_message_table(i).msg_tbl.FIRST..success_message_table(i).msg_tbl.LAST LOOP
               --FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || j || ': ' || success_message_table(i).msg_tbl(j).msg);
               --FND_FILE.put_line(FND_FILE.output,'');
           --END LOOP;

           --FND_FILE.put_line(FND_FILE.output,'');

     	END LOOP;
       END IF;

       FND_FILE.put_line(FND_FILE.output,'');

       -- Print Investor Agreements errored
       IF l_error > 0 THEN

        FND_FILE.put_line(FND_FILE.output, l_error_k);
        FND_FILE.put_line(FND_FILE.output, RPAD('-',LENGTH(l_error_k), '-' ));
        FND_FILE.put_line(FND_FILE.output,'');

        -- SECHAWLA 26-JAN-04 3377730: Initialize the table index
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

           -- SECHAWLA  26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
           -- of db/Pl Sql  Removed the msg_tbl field from message_rec_type
           /*
           FOR j IN error_message_table(i).msg_tbl.FIRST..error_message_table(i).msg_tbl.LAST LOOP
               FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || j || ': ' || error_message_table(i).msg_tbl(j).msg);
               FND_FILE.put_line(FND_FILE.output,'');
           END LOOP;
           */

           -- SECHAWLA  26-JAN-04 3377730: A table can not have a table or record with composite fields on lower versions
          -- of db/Pl Sql  Removed the msg_tbl field from message_rec_type


           --Bug 7007686 : Changed the for loop to scan through all the messages
		   -- and to display the correct serial number
           l_msg_num:=0;
           --FOR j IN msg_lines_table_index .. msg_lines_table.LAST LOOP
		   FOR j IN msg_lines_table.FIRST..msg_lines_table.LAST LOOP
               IF msg_lines_table(j).id = error_message_table(i).id THEN
                  --Bug 7007686
                  l_msg_num:=l_msg_num+1;
                  --FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || j || ': ' || msg_lines_table(j).msg);
				  FND_FILE.put(FND_FILE.output, RPAD(' ',5,' ') || l_msg_num || ': ' || msg_lines_table(j).msg);
				  --Bug 7007686 :End
                  FND_FILE.put_line(FND_FILE.output,'');

			   /*Bug 7007686  :commented
               ELSE
                  msg_lines_table_index := j ;
                  EXIT;
			  */
               END IF;

           END LOOP;

           FND_FILE.put_line(FND_FILE.output,'');

     	END LOOP;

       END IF;

       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output,'');
       FND_FILE.put_line(FND_FILE.output, RPAD(' ', 53 , ' ' ) || l_eop);

       ELSE -- RMUNJULU 115.4 3061748

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
  -- Procedure Name  : get_ia_leases
  -- Description     : procedure to get the IA Pool Leases
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE get_ia_leases(
                    p_ia_rec          IN ia_rec_type,
                    x_ia_k_tbl        OUT  NOCOPY ia_k_tbl_type,
                    x_return_status   OUT  NOCOPY VARCHAR2) IS

       -- Get leases of the IA Active Pool
       CURSOR get_ia_k_csr( p_ia_id IN NUMBER) IS
            SELECT DISTINCT CHR.id,
                   CHR.contract_number,
                   CHR.start_date,
                   CHR.end_date,
                   CHR.sts_code,
                   CHR.date_terminated
            FROM   OKL_POOLS POL,
                   OKL_POOL_CONTENTS POC,
                   OKC_K_HEADERS_B KHR,
                   OKC_K_HEADERS_B CHR
            WHERE  KHR.id = p_ia_id
            AND    KHR.id = POL.khr_id
            AND    POL.id = POC.pol_id
            AND    POL.status_code = 'ACTIVE' -- Pool status
            AND    POC.status_code = POL.status_code
            AND    POC.khr_id = CHR.id;

        i NUMBER := 1;
        l_ia_k_tbl    ia_k_tbl_type;
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.get_ia_leases.',
                         'Begin(+)');
       END IF;

       -- Populate the Lease tbl
       FOR get_ia_k_rec IN get_ia_k_csr (p_ia_rec.id) LOOP

             l_ia_k_tbl(i).id               :=   get_ia_k_rec.id;
             l_ia_k_tbl(i).contract_number  :=   get_ia_k_rec.contract_number;
             l_ia_k_tbl(i).start_date       :=   get_ia_k_rec.start_date;
             l_ia_k_tbl(i).end_date         :=   get_ia_k_rec.end_date;
             l_ia_k_tbl(i).sts_code         :=   get_ia_k_rec.sts_code;
             l_ia_k_tbl(i).date_terminated  :=   get_ia_k_rec.date_terminated;

             i := i + 1;

       END LOOP;

       x_return_status :=  l_return_status;
       x_ia_k_tbl := l_ia_k_tbl;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.get_ia_leases.',
                         'End(-)');
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

        IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.get_ia_leases.',
                             'EXP - OTHERS');
        END IF;

  END get_ia_leases;

  -- Start of comments
  --
  -- Procedure Name  : validate_ia_pool
  -- Description     : Checks Investor Agreement Pool contents and Pool streams valid
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE validate_ia_pool(
                    p_ia_rec          IN ia_rec_type,
                    x_return_status   OUT  NOCOPY VARCHAR2) IS

       -- Check if any ACTIVE pool contents for the IA which are are end_dated after
       -- IA end_date or not end_dated at all
       CURSOR check_ia_poc_date_csr (p_ia_id IN NUMBER) IS
            SELECT 1 id
            FROM DUAL WHERE EXISTS (
            SELECT POC.id
            FROM   OKL_POOLS POL,
                   OKL_POOL_CONTENTS POC,
                   OKC_K_HEADERS_B CHR
            WHERE  CHR.id = p_ia_id
            AND    CHR.id = POL.khr_id
            AND    POL.id = POC.pol_id
            AND    NVL(POC.streams_to_date, CHR.end_date+1) > CHR.end_date
            AND    POL.status_code = 'ACTIVE'
            AND    POC.status_code = POL.status_code);

       -- Check if any CURRENT ACTIVE BILLABLE stream elements of IA pools
       -- which are dated after the IA end_date
       CURSOR check_ia_sel_date_csr( p_ia_id IN NUMBER) IS
            SELECT 1 id
            FROM DUAL WHERE EXISTS (
            SELECT SEL.id
            FROM   OKL_STREAMS STM,
                   OKL_STRM_ELEMENTS SEL,
                   OKL_STRM_TYPE_B STY,
                   OKL_POOLS POL,
                   OKL_POOL_CONTENTS POC,
                   OKC_K_HEADERS_B CHR
            WHERE  CHR.id = p_ia_id
            AND    CHR.id = POL.khr_id
            AND    POL.id = POC.pol_id
            AND    POL.status_code = 'ACTIVE'
            AND    POC.status_code = POL.status_code
            AND    POC.sty_id = STM.sty_id
            AND    STM.id = SEL.stm_id
            AND    SEL.stream_element_date > CHR.end_date
            AND    POC.kle_id = STM.kle_id
            AND    STM.say_code = 'CURR' -- CURRENT
            AND    STM.active_yn = G_YES  -- ACTIVE
            AND    STM.sty_id = STY.id
            AND    NVL(STY.billable_yn,G_NO) = G_YES); -- BILLABLE

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_poc_id     NUMBER := G_MISS_NUM;
        l_sel_id     NUMBER := G_MISS_NUM;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.validate_ia_pool.',
                         'Begin(+)');
       END IF;

       SAVEPOINT validate_ia_pool_trx;

       -- **********
       -- Check if IA Pool Contents valid
       -- **********

       -- Get the invalid Pool Contents
       FOR check_ia_poc_date_rec IN check_ia_poc_date_csr(p_ia_rec.id) LOOP
            l_poc_id := check_ia_poc_date_rec.id;
       END LOOP;


       IF  l_poc_id = 1 THEN
            -- Pool contents exist after the Investor Agreement AGREEMENT_NUMBER
            -- end date END_DATE.
            OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_INV_POC_DATE',
                      p_token1        => 'AGREEMENT_NUMBER',
                      p_token1_value  => p_ia_rec.contract_number,
                      p_token2        => 'END_DATE',
                      p_token2_value  => p_ia_rec.end_date);

            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- **********
       -- Check if IA Pool Stream Elements valid
       -- **********

       -- Get the invalid Pool Stream Elements
       FOR check_ia_sel_date_rec IN check_ia_sel_date_csr(p_ia_rec.id) LOOP
            l_sel_id := check_ia_sel_date_rec.id;
       END LOOP;

       IF  l_sel_id = 1 THEN
            -- Streams associated with Investor Agreement AGREEMENT_NUMBER has
            -- due date after end date END_DATE.
            OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_INV_SEL_DATE',
                      p_token1        => 'AGREEMENT_NUMBER',
                      p_token1_value  => p_ia_rec.contract_number,
                      p_token2        => 'END_DATE',
                      p_token2_value  => p_ia_rec.end_date);

            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set return status
       x_return_status := l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.validate_ia_pool.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO validate_ia_pool_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.validate_ia_pool.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_ia_pool_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.validate_ia_pool.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO validate_ia_pool_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.validate_ia_pool.',
                             'EXP - OTHERS');
           END IF;

  END validate_ia_pool;

  -- Start of comments
  --
  -- Procedure Name  : check_unbilled_streams_of_pool
  -- Description     : procedure to check if any unbilled streams of investor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE check_unbilled_streams_of_pool(
                    p_ia_rec          IN ia_rec_type,
                    x_return_status   OUT  NOCOPY VARCHAR2) IS

       -- Get unbilled stream elements
       CURSOR get_unbilled_sel_csr( p_ia_id IN NUMBER) IS
            SELECT 1 id
            FROM DUAL WHERE EXISTS (
            SELECT SEL.id
            FROM   OKL_STREAMS STM,
                   OKL_STRM_ELEMENTS SEL,
                   OKL_STRM_TYPE_B STY,
                   OKL_POOLS POL,
                   OKL_POOL_CONTENTS POC,
                   OKC_K_HEADERS_B KHR
            WHERE  KHR.id = p_ia_id
            AND    KHR.id = POL.khr_id
            AND    POL.id = POC.pol_id
            AND    POL.status_code = 'ACTIVE'
            AND    POC.status_code = POL.status_code
            AND    POC.sty_id = STM.sty_id
            AND    STM.id = SEL.stm_id
            AND    (SEL.stream_element_date BETWEEN POC.streams_from_date
                                            AND POC.streams_to_date)
            AND    POC.kle_id = STM.kle_id
            AND    STM.say_code = 'CURR' -- CURRENT
            AND    STM.active_yn = G_YES  -- ACTIVE
            AND    SEL.date_billed IS NULL -- Not billed
            AND    STM.sty_id = STY.id
            AND    NVL(STY.billable_yn,G_NO) = G_YES); -- BILLABLE

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_strm_id  NUMBER;

  BEGIN

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.check_unbilled_streams_of_pool.',
                         'Begin(+)');
        END IF;

        -- *********
        -- Unbilled Stream elements
        -- *********

        SAVEPOINT check_unbilled_trx;

        -- Get the unbilled stream elements
        FOR get_unbilled_sel_rec IN get_unbilled_sel_csr(p_ia_rec.id) LOOP
            l_strm_id := get_unbilled_sel_rec.id;
        END LOOP;

        -- If unbilled stream elements then error
        IF l_strm_id = 1  THEN

             -- Streams associated with Investor Agreement AGREEMENT_NUMBER have
             -- not been billed.
             OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_INV_UNBILL_STRM',
                      p_token1        => 'AGREEMENT_NUMBER',
                      p_token1_value  => p_ia_rec.contract_number);

             RAISE G_EXCEPTION_ERROR;

        END IF;

        -- Set return status
        x_return_status := l_return_status;

        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.check_unbilled_streams_of_pool.',
                         'End(-)');
        END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            ROLLBACK TO check_unbilled_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_unbilled_streams_of_pool.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            ROLLBACK TO check_unbilled_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_unbilled_streams_of_pool.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            ROLLBACK TO check_unbilled_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_unbilled_streams_of_pool.',
                             'EXP - OTHERS');
           END IF;

  END check_unbilled_streams_of_pool;

  -- Start of comments
  --
  -- Procedure Name  : check_pending_disb_for_ia
  -- Description     : procedure to check if any pending disbursements for the
  --                   Investor Agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE check_pending_disb_for_ia(
                    p_ia_rec          IN ia_rec_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- stream type INVESTOR RENT DISBURSEMENT BASIS streams generated during
       -- activation of investor agreement
       -- stream type INVESTOR RENT PAYABLE streams generated when disbursement of
       -- INVESTOR RENT DISBURSEMENT BASIS streams is done
       -- some of stream type subclass INVESTOR_DISBURSEMENT streams generated when
       -- disbursement of INVESTOR RENT DISBURSEMENT BASIS streams is done
       -- some of stream type subclass INVESTOR_DISBURSEMENT streams generated when
       -- early termination of contract which is securitized is done

       -- stream_type_subclass INVESTOR_DISBURSEMENT should cover following stream types
       --
       -- INVESTOR CONTRACT OBLIGATION PAYABLE
       --   Stream created by AM for payment of rent amount on termination.
       -- INVESTOR RESIDUAL PAYABLE
       --   Stream created by AM for payment of residual amount on termination.
       -- INVESTOR LATE CHARGE PAYABLE
       --   Stream created by BPD for payment of late charge to investor.
       -- INVESTOR LATE FEE PAYABLE
       --   Stream created by BPD for payment of late interest to investor.
       -- INVESTOR RENT BUYBACK
       --   Stream created by Securitization for payment of rent buy back to investor.
       -- INVESTOR RESIDUAL BUYBACK
       --   Stream created by Securitization for payment of residual buy back to investor.

       -- Get the undisbursed streams for IA
       -- RMUNJULU 21-OCT-03 3061748 Changed the cursor to look at right source_id
       -- SMODUGA 11-Oct-04 Bug 3925469
       -- Modified cursor by passing sty_id based on the stream purpose
       CURSOR get_undisb_sel_csr( p_ia_id IN NUMBER,p_invdisbas_sty_id IN NUMBER,p_invpbl_sty_id IN NUMBER,
            p_prindisbas_sty_id IN NUMBER,p_prinpbl_sty_id IN NUMBER,
            p_intdisbas_sty_id IN NUMBER,p_intpbl_sty_id IN NUMBER,
            p_ppddisbas_sty_id IN NUMBER,p_ppdpbl_sty_id IN NUMBER) IS
        SELECT 1 id
        FROM DUAL WHERE EXISTS (
   SELECT
    ste.id				sel_id
      FROM
             okl_strm_elements		ste,
    okl_streams			    stm,
    okl_strm_type_v			sty
   WHERE ste.amount        <> 0
   AND	  stm.id		    = ste.stm_id
         AND   sty.stream_type_subclass IS NULL
         AND   sty.id          IN (p_invdisbas_sty_id,p_invpbl_sty_id,p_prindisbas_sty_id,
         p_prinpbl_sty_id,p_intdisbas_sty_id,p_intpbl_sty_id, p_ppddisbas_sty_id,p_ppdpbl_sty_id)
   AND	  ste.date_billed   IS NULL  -- Once disb is done date_billed is populated
   AND	  stm.active_yn	    = 'Y'
   AND	  stm.say_code	    = 'CURR'
   AND	  sty.id		    = stm.sty_id
   AND	  sty.billable_yn   = 'N'
         AND   stm.source_id     = p_ia_id); -- Investor Agreement is now stored on disb stream

        -- Get the undisbursed streams for IA
        -- RMUNJULU 21-OCT-03 3061748 Changed the cursor to look at right source_id
        CURSOR get_undisb_csr( p_ia_id IN NUMBER) IS
         SELECT 1 id
         FROM DUAL WHERE EXISTS (
   SELECT
    ste.id				sel_id
      FROM
             okl_strm_elements		ste,
    okl_streams			    stm,
    okl_strm_type_v			sty
   WHERE ste.amount        <> 0
   AND	  stm.id	    	= ste.stm_id
         AND   sty.stream_type_subclass = 'INVESTOR_DISBURSEMENT'
   AND	  ste.date_billed	IS NULL  -- Once disb is done date_billed is populated
   AND	  stm.active_yn	    = 'Y'
   AND	  stm.say_code	    = 'CURR'
   AND	  sty.id		    = stm.sty_id
   AND	  sty.billable_yn	= 'N'
         AND   stm.source_id     = p_ia_id); -- Investor Agreement is now stored on disb stream

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_disb_id  NUMBER ;
        l_ia_k_tbl ia_k_tbl_type;
        l_contract_number VARCHAR2(300);

        -- SMODUGA added variable for userdefined streams 3925469
        lx_invdisbas_sty_id NUMBER;
        lx_invpbl_sty_id NUMBER;

  -- sosharma added variable for loan disbersement stream types
         lx_prindisbas_sty_id NUMBER;
        lx_prinpbl_sty_id NUMBER;

        lx_intdisbas_sty_id NUMBER;
        lx_intpbl_sty_id NUMBER;

        lx_ppddisbas_sty_id NUMBER;
        lx_ppdpbl_sty_id NUMBER;


  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.check_pending_disb_for_ia.',
                        'Begin(+)');
       END IF;

       -- *********
       -- Pending Disbursements
       -- *********

       SAVEPOINT check_pending_disb_trx;

        -- smoduga +++++++++ User Defined Streams -- start    ++++++++++++++++
     /*  OKL_STREAMS_UTIL.get_dependent_stream_type(p_ia_rec.id,
                                                   'RENT',
                                                   'INVESTOR_RENT_DISBURSEMENT_BASIS',
                                                   l_return_status,
                                                   lx_invdisbas_sty_id);

      OKL_STREAMS_UTIL.get_dependent_stream_type(p_ia_rec.id,
                                                   'RENT',
                                                   'INVESTOR_RENT_PAYABLE',
                                                   l_return_status,
                                                   lx_invpbl_sty_id);
    -- smoduga +++++++++ User Defined Streams -- end    ++++++++++++++++  */

    -- gkadarka fix for bug 4609338 - start
      OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                'INVESTOR_RENT_DISB_BASIS',-- 'INVESTOR_RENT_DISBURSEMENT_BASIS', --GKADARKA CHANGED FOR TEST
                                                   l_return_status,
                                                   lx_invdisbas_sty_id);

      OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                   'INVESTOR_RENT_PAYABLE',
                                                   l_return_status,
                                                   lx_invpbl_sty_id);
/*Sosharma
14-01-2008
Changes to included loan type of contracts in Investor Agreement
Start Changes*/
      OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                'INVESTOR_PRINCIPAL_DISB_BASIS',-- 'INVESTOR_LOAN_DISBURSEMENT_BASIS', --GKADARKA CHANGED FOR TEST
                                                   l_return_status,
                                                   lx_prindisbas_sty_id);

      OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                'INVESTOR_INTEREST_DISB_BASIS',-- 'INVESTOR_LOAN_DISBURSEMENT_BASIS', --GKADARKA CHANGED FOR TEST
                                                   l_return_status,
                                                   lx_intdisbas_sty_id);


      OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                   'INVESTOR_PRINCIPAL_PAYABLE',
                                                   l_return_status,
                                                   lx_prinpbl_sty_id);

         OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                   'INVESTOR_INTEREST_PAYABLE',
                                                   l_return_status,
                                                   lx_intpbl_sty_id);


-- Principal Paydown streams

         OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                   'INVESTOR_PPD_DISB_BASIS',
                                                   l_return_status,
                                                   lx_ppddisbas_sty_id);
         OKL_STREAMS_UTIL.get_primary_stream_type(p_ia_rec.id,
                                                   'INVESTOR_PAYDOWN_PAYABLE',
                                                   l_return_status,
                                                   lx_ppdpbl_sty_id);



    -- gkadarka fix for bug 4609338 - End


       -- Get all stream elements which have not been disbursed for the Lease
       FOR get_undisb_sel_rec IN get_undisb_sel_csr(p_ia_rec.id,lx_invdisbas_sty_id,lx_invpbl_sty_id,
                   lx_prindisbas_sty_id,lx_prinpbl_sty_id,lx_intdisbas_sty_id,lx_intpbl_sty_id ,lx_ppddisbas_sty_id,lx_ppdpbl_sty_id) LOOP
          l_disb_id := get_undisb_sel_rec.id;
       END LOOP;
/* sosharma end changes */
       -- If undisbursed stream elements then error
       IF l_disb_id = 1 THEN
          --Pending disbursements exists for the investor agreement AGREEMENT_NUMBER.
          OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_INV_PENDING_DISB',
                           p_token1        => 'AGREEMENT_NUMBER',
                           p_token1_value  => p_ia_rec.contract_number);

          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Get all stream elements which have not been disbursed for the Lease
       FOR get_undisb_rec IN get_undisb_csr(p_ia_rec.id) LOOP
          l_disb_id := get_undisb_rec.id;
       END LOOP;

       -- If undisbursed stream elements then error
       IF l_disb_id = 1 THEN
          --Pending disbursements exists for the investor agreement AGREEMENT_NUMBER.
          OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_INV_PENDING_DISB',
                           p_token1        => 'AGREEMENT_NUMBER',
                           p_token1_value  => p_ia_rec.contract_number);

          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set return status
       x_return_status := l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.check_pending_disb_for_ia.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN

            ROLLBACK TO check_pending_disb_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_pending_disb_for_ia.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            ROLLBACK TO check_pending_disb_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_pending_disb_for_ia.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            ROLLBACK TO check_pending_disb_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.check_pending_disb_for_ia.',
                             'EXP - OTHERS');
           END IF;

  END check_pending_disb_for_ia;

  -- Start of comments
  --
  -- Procedure Name  : pop_investor_agreement
  -- Description     : procedure to populate investor agreement details
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE pop_investor_agreement(
                    p_ia_rec         IN   ia_rec_type,
                    x_ia_rec         OUT  NOCOPY ia_rec_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- Get the details of the IA
       CURSOR get_ia_details_csr (p_ia_id IN NUMBER) IS
            SELECT   CHR.id,
                     CHR.contract_number,
                     CHR.START_DATE,
                     CHR.end_date,
                     CHR.sts_code, -- Should be ACTIVE
                     CHR.scs_code, -- should be INVESTOR
                     KHR.pdt_id,
                     POL.id pool_id,
                     POL.pool_number
            FROM     OKC_K_HEADERS_B CHR,
                     OKL_K_HEADERS   KHR,
                     OKL_POOLS       POL
            WHERE    CHR.id = p_ia_id
            AND      CHR.id = KHR.id
            AND      CHR.id = POL.khr_id;

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_ia_number  VARCHAR2(300);
        l_ia_id      NUMBER;
        l_pdt_id     NUMBER;
        l_start_date DATE;
        l_end_date   DATE;
        l_type       VARCHAR2(300);
        l_status     VARCHAR2(300);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_investor_agreement.',
                        'Begin(+)');
       END IF;

       -- **********
       -- Get IA details
       -- **********

       -- Get the K details
       FOR get_ia_details_rec IN get_ia_details_csr(p_ia_rec.id) LOOP
              x_ia_rec.id               := get_ia_details_rec.id;
              x_ia_rec.contract_number  := get_ia_details_rec.contract_number;
              x_ia_rec.START_DATE       := get_ia_details_rec.start_date;
              x_ia_rec.end_date         := get_ia_details_rec.end_date;
              x_ia_rec.sts_code         := get_ia_details_rec.sts_code;
              x_ia_rec.scs_code         := get_ia_details_rec.scs_code;
              x_ia_rec.pdt_id           := get_ia_details_rec.pdt_id;
              x_ia_rec.pool_id          := get_ia_details_rec.pool_id;
              x_ia_rec.pool_number      := get_ia_details_rec.pool_number;
       END LOOP;

       -- Set return values
       x_return_status :=  l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_investor_agreement.',
                        'End(-)');
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

            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_investor_agreement.',
                             'EXP - OTHERS');
           END IF;

  END  pop_investor_agreement;

  -- Start of comments
  --
  -- Procedure Name  : val_pop_investor_agreement
  -- Description     : procedure to validate investor agreement and Populate
  --                   IA Lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE val_pop_investor_agreement(
                    p_ia_rec         IN   ia_rec_type,
                    x_ia_rec         OUT  NOCOPY ia_rec_type,
                    x_ialn_tbl       OUT  NOCOPY ialn_tbl_type,
                    x_return_status  OUT  NOCOPY VARCHAR2) IS

       -- Get the IA TRN for Termination ie TCN_TYPE =  'IAT'
       CURSOR get_trn_csr (p_ia_id IN NUMBER) IS
            SELECT   TRN.tsu_code
            FROM     OKL_TRX_CONTRACTS TRN
            WHERE    TRN.khr_id = p_ia_id
            --rkuttiya added for 12.1.1 Multi GAAP
           AND       TRN.representation_type = 'PRIMARY'
           --
            AND      TRN.tcn_type = 'IAT';

       -- Get the IA Lines
       CURSOR get_ia_lines_csr (p_ia_id IN NUMBER) IS
            SELECT   CLE.id,
                     CLE.name,
                     CLE.sts_code
            FROM     OKC_K_HEADERS_B CHR,
                     OKC_K_LINES_V CLE
            WHERE    CHR.id = p_ia_id
            AND      CHR.id = CLE.dnz_chr_id
            AND      CLE.sts_code = CHR.sts_code;

/*sosharma 14-01-2008
Cursor to validate if transiend pool contents are present for the IA being terminated
Start Changes*/

       CURSOR get_trans_pox_cont_csr (p_ia_id IN NUMBER) IS
            SELECT   POX.id
            FROM     OKL_POOL_TRANSACTIONS POX,
                     OKL_POOLS POL
            WHERE    POL.id=POX.pol_id
            AND      POX.transaction_status <> 'COMPLETE'
            AND      POL.khr_id =p_ia_id
            AND      POX.transaction_type='ADD'
            AND      POX.transaction_reason='ADJUSTMENTS';

/* sosharma end changes*/

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_ia_number  VARCHAR2(300);
        l_start_date DATE;
        l_end_date   DATE;
        l_status     VARCHAR2(300);
        l_type       VARCHAR2(300);
        l_pdt_id     NUMBER;
        l_ialn_tbl   ialn_tbl_type;
        i NUMBER := 0;
        l_tsu_code  VARCHAR2(300);
        l_ia_rec    ia_rec_type;
        l_trans_pool_id   NUMBER;

  BEGIN

       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
       -- Begin Logic
       -- 0   Get the IA details
       -- 1.1 Throw error if IA ID/Number not valid
       -- 1.2 Throw error if IA type not valid
       -- 1.3 Throw error if IA End Date not valid
       -- 1.4 Throw error if IA Trn is already Processed
       -- 2.1 Throw error if any billable stream elements of IA pools end dated
       --     after the IA end date
       -- 2.2 Throw error if any pool contents of IA pool end dated after the IA
       --     end date
       -- 3.  Throw error if any unbilled stream elements of the IA pool exists
       -- 4.  Throw error if any pending disbursements for IA exists.
       -- 5.  Throw error if any undisbursed stream elements of the lease contracts
       --     of IA exists - these are the new disbursement streams created when
       --     lease is securitized and terminated
       -- 6.  Get IA lines
       --
       -- End Logic
       -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.val_pop_investor_agreement.',
                        'Begin(+)');
       END IF;

       SAVEPOINT validate_ia_trx;

       -- *************
       -- Populate IA Values
       -- *************

       pop_investor_agreement(
                       p_ia_rec         =>  p_ia_rec,
                       x_ia_rec         =>  l_ia_rec,
                       x_return_status  =>  l_return_status);

       -- **********
       -- Check if IA valid
       -- **********

       -- invalid id
       IF l_ia_rec.id IS NULL
       OR l_ia_rec.contract_number IS NULL THEN

            -- Invalid Value
            OKL_API.set_message(
                      p_app_name     => G_APP_NAME_1,
                      p_msg_name     => G_INVALID_VALUE,
                      p_token1       => G_COL_NAME_TOKEN,
                      p_token1_value => 'id');

            RAISE G_EXCEPTION_ERROR;

       END IF;

       -- If not investor agreeement
       IF l_ia_rec.scs_code <> 'INVESTOR' THEN

            -- AGREEMENT_NUMBER is not a valid Investor Agreement.
            OKL_API.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_AM_INV_NOT_INV',
                      p_token1       => 'AGREEMENT_NUMBER',
                      p_token1_value => l_ia_rec.contract_number);

            RAISE G_EXCEPTION_ERROR;

       END IF;

       -- If not active
       IF l_ia_rec.sts_code <> 'ACTIVE'  THEN

            -- Investor Agreement AGREEMENT_NUMBER  is not in active status.
            OKL_API.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_AM_INV_NOT_ACTIVE',
                      p_token1       => 'AGREEMENT_NUMBER',
                      p_token1_value => l_ia_rec.contract_number);

            RAISE G_EXCEPTION_ERROR;

       END IF;

       -- If not end dated
       IF l_ia_rec.end_date IS NULL  THEN

            -- End date is not available for Investor Agreement AGREEMENT_NUMBER.
            OKL_API.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_AM_INV_NOT_ENDED',
                      p_token1       => 'AGREEMENT_NUMBER',
                      p_token1_value => l_ia_rec.contract_number);

            RAISE G_EXCEPTION_ERROR;

       END IF;

       -- Get TRN Details
       FOR get_trn_rec IN get_trn_csr(l_ia_rec.id) LOOP

            l_tsu_code := get_trn_rec.tsu_code;

       END LOOP;

       -- If TRN exists and was PROCESSED then error
       IF l_tsu_code = 'PROCESSED' THEN
            -- The transaction status and agreement status are mismatched for
            -- Investor Agreement AGREEMENT_NUMBER.
            OKL_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AM_INV_PRS_TRN_EXIST',
                          p_token1       => 'AGREEMENT_NUMBER',
                          p_token1_value => l_ia_rec.contract_number);

            RAISE G_EXCEPTION_ERROR;
       END IF;

      /*sosharma 14-01-2008
      Validate for condition - transient pool contents are present for the IA being terminated
       Start Changes*/

       FOR get_trans_pox_cont_rec IN get_trans_pox_cont_csr(l_ia_rec.id) LOOP

            l_trans_pool_id := get_trans_pox_cont_rec.id;

       END LOOP;
        IF l_trans_pool_id is not null  THEN

            -- Pending pool contents and transactions are present
            OKL_API.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_AM_INV_PEND_REQ_EXIST',
                      p_token1       => 'AGREEMENT_NUMBER',
                      p_token1_value => l_ia_rec.contract_number);

            RAISE G_EXCEPTION_ERROR;

       END IF;

       -- **********
       -- Validate IA Pool Contents
       -- Throw error if any billable stream elements of IA pools end dated after
       -- the IA end date
       -- Throw error if any pool contents of IA pool end dated after the IA end date
       -- **********

       validate_ia_pool(
                    p_ia_rec          =>  l_ia_rec,
                    x_return_status   =>  l_return_status);

       -- raise exception if api returns error
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE G_EXCEPTION_ERROR;
       END IF;

       -- **********
       -- Check Unbilled Streams of Pool
       -- Throw error if any unbilled stream elements of the IA pool exists
       -- **********

       check_unbilled_streams_of_pool(
                    p_ia_rec          =>  l_ia_rec,
                    x_return_status   =>  l_return_status);

       -- raise exception if api returns error
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE G_EXCEPTION_ERROR;
       END IF;

       -- *************
       -- Check Pending Disbursements for IA
       -- Throw error if any pending disbursements for IA exists.
       -- *************

       check_pending_disb_for_ia(
                    p_ia_rec          =>  l_ia_rec,
                    x_return_status  =>  l_return_status);

       -- raise exception if api returns error
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
           RAISE G_EXCEPTION_ERROR;
       END IF;

       -- *********
       -- Populate the IA Lines
       -- *********

       i := 1;
       FOR get_ia_lines_rec IN get_ia_lines_csr (l_ia_rec.id ) LOOP

            -- If ACTIVE line then Add to IA Lines table
            l_ialn_tbl(i).id := get_ia_lines_rec.id;
            l_ialn_tbl(i).name := get_ia_lines_rec.name;
            i := i + 1;

       END LOOP;

       -- Set the success message
       -- Investor Agreement AGREEMENT_NUMBER is valid.
       OKL_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AM_INV_VALIDATE_SUCC',
                          p_token1       => 'AGREEMENT_NUMBER',
                          p_token1_value => l_ia_rec.contract_number);

       -- Set return values
       x_return_status :=  l_return_status;
       x_ialn_tbl      :=  l_ialn_tbl;
       x_ia_rec        :=  l_ia_rec;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.val_pop_investor_agreement.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO validate_ia_trx;
            x_return_status := G_RET_STS_ERROR;

            x_ialn_tbl      :=  l_ialn_tbl;
            x_ia_rec        :=  l_ia_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.val_pop_investor_agreement.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO validate_ia_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

            x_ialn_tbl      :=  l_ialn_tbl;
            x_ia_rec        :=  l_ia_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.val_pop_investor_agreement.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO validate_ia_trx;
            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;

            x_ialn_tbl      :=  l_ialn_tbl;
            x_ia_rec        :=  l_ia_rec;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.val_pop_investor_agreement.',
                             'EXP - OTHERS');
           END IF;

  END val_pop_investor_agreement;

  -- Start of comments
  --
  -- Procedure Name  : pop_or_insert_transaction
  -- Description     : procedure to insert termination transaction for the investor
  --                   agreement if does not exist or else if exists then populate
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE pop_or_insert_transaction(
                    p_ia_rec            IN   ia_rec_type,
                    p_sys_date          IN   DATE,
                    x_trn_already_yn    OUT  NOCOPY VARCHAR2,
                    px_tcnv_rec         IN OUT  NOCOPY tcnv_rec_type,
                    p_validate_success  IN   VARCHAR2,
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
                 TRN.tmt_generic_flag3_yn,
		 TRN.legal_entity_id
        FROM     OKL_TRX_CONTRACTS TRN
        WHERE    TRN.khr_id = p_ia_id
        --rkuttiya added for 12.1.1 Multi GAAP
        AND      TRN.representation_type = 'PRIMARY'
        --
        AND      TRN.tcn_type = 'IAT';

	-- get legal_entity_id
	CURSOR get_le_csr (p_ia_id IN NUMBER)is
	SELECT legal_entity_id
	FROM Okl_k_headers
	WHERE khr_id =  p_ia_id;

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
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
                        'Begin(+)');
       END IF;

       SAVEPOINT pop_insert_trn_trx;

       -- *************
  	   -- Populate TRN if exists
       -- *************

       FOR get_trn_rec IN get_trn_csr ( p_ia_rec.id ) LOOP

           IF p_validate_success = G_RET_STS_SUCCESS THEN
             lx_tcnv_rec.tmt_validated_yn := G_YES;
           ELSE
             lx_tcnv_rec.tmt_validated_yn := G_NO;
           END IF;

           lx_tcnv_rec.id                        := get_trn_rec.id;
           lx_tcnv_rec.tsu_code                  := get_trn_rec.tsu_code;
           lx_tcnv_rec.trx_number                := get_trn_rec.trx_number;
           lx_tcnv_rec.tcn_type                  := get_trn_rec.tcn_type;
           lx_tcnv_rec.try_id                    := get_trn_rec.try_id;
           lx_tcnv_rec.khr_id                    := get_trn_rec.khr_id;
           lx_tcnv_rec.tmt_accounting_entries_yn := get_trn_rec.tmt_accounting_entries_yn;
           lx_tcnv_rec.tmt_contract_updated_yn   := get_trn_rec.tmt_contract_updated_yn;
           lx_tcnv_rec.tmt_recycle_yn            := get_trn_rec.tmt_recycle_yn;
           lx_tcnv_rec.tmt_generic_flag1_yn      := get_trn_rec.tmt_generic_flag1_yn;
           lx_tcnv_rec.tmt_generic_flag2_yn      := get_trn_rec.tmt_generic_flag2_yn;
           lx_tcnv_rec.tmt_generic_flag3_yn      := get_trn_rec.tmt_generic_flag3_yn;
	   lx_tcnv_rec.legal_entity_id           := get_trn_rec.legal_entity_id;
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

           -- Get the contract currency code -- *** will IA have currency code
           l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(p_ia_rec.id);

           -- Set the TRN rec
           lp_tcnv_rec.khr_id   := p_ia_rec.id;

           IF p_validate_success = G_RET_STS_SUCCESS THEN

             lp_tcnv_rec.tmt_validated_yn := G_YES;
             lp_tcnv_rec.tsu_code := 'ENTERED';

           ELSE
             lp_tcnv_rec.tmt_validated_yn := G_NO;
             lp_tcnv_rec.tsu_code := 'ERROR';
           END IF;
	   FOR get_le_rec IN get_le_csr(p_ia_rec.id) LOOP
		lp_tcnv_rec.legal_entity_id := get_le_rec.legal_entity_id;
	   END LOOP;
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
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO pop_insert_trn_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO pop_insert_trn_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
                             'EXP - OTHERS');
           END IF;

  END pop_or_insert_transaction;

  -- Start of comments
  --
  -- Procedure Name  : reverse_loss_provisions
  -- Description     : procedure to do reversal of loss provisions of investor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE reverse_loss_provisions(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    p_gl_date           IN   DATE,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS


        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_lprv_rec     OKL_REV_LOSS_PROV_PUB.lprv_rec_type;
        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);

  BEGIN

     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                      'OKL_AM_TERMINATE_INV_AGMT_PVT.reverse_loss_provisions.',
                      'Begin(+)');
     END IF;

     -- *********
     -- Reverse Loss Provisions
     -- *********

     SAVEPOINT reverse_loss_trx;

     l_lprv_rec.cntrct_num    := p_ia_rec.contract_number;  --Agreement Number
     l_lprv_rec.reversal_type := NULL; --PGL for reversal of General Loss and PSP for reversal of Specific Loss
     l_lprv_rec.reversal_date := p_gl_date; -- Loss Provision Reversal Date in a valid open period.

     OKL_REV_LOSS_PROV_PUB.reverse_loss_provisions(
                                  p_api_version    => l_api_version,
                                  p_init_msg_list  => G_FALSE,
                                  x_return_status  => l_return_status,
                                  x_msg_count      => l_msg_count,
                                  x_msg_data       => l_msg_data,
                                  p_lprv_rec       => l_lprv_rec);

     IF l_return_status <> G_RET_STS_SUCCESS THEN
          -- Error occured during reversal of loss provisions for Investor
          -- Agreement AGREEMENT_NUMBER.
          OKL_API.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_AM_INV_REVERSE_ERR',
                     p_token1        => 'AGREEMENT_NUMBER',
                     p_token1_value  => p_ia_rec.contract_number);
     END IF;

     -- Raise exception if error
     IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = G_RET_STS_ERROR) THEN
        RAISE G_EXCEPTION_ERROR;
     END IF;

     -- Set the success message
     -- Loss provisions have been reversed for Investor Agreement AGREEMENT_NUMBER.
     OKL_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AM_INV_REVERSE_SUCC',
                          p_token1       => 'AGREEMENT_NUMBER',
                          p_token1_value => p_ia_rec.contract_number);

     -- Set return status
     x_return_status := l_return_status;

     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                      'OKL_AM_TERMINATE_INV_AGMT_PVT.reverse_loss_provisions.',
                      'End(-)');
     END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO reverse_loss_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.reverse_loss_provisions.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO reverse_loss_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.reverse_loss_provisions.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO reverse_loss_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.reverse_loss_provisions.',
                             'EXP - OTHERS');
           END IF;

  END reverse_loss_provisions;

  -- Start of comments
  --
  -- Procedure Name  : accounting_entries
  -- Description     : procedure to do accounting
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE accounting_entries(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    p_gl_date           IN   DATE,
                    px_tcnv_rec         IN OUT NOCOPY tcnv_rec_type,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                        'Begin(+)');
       END IF;

       SAVEPOINT accounting_entries_trx;

       IF  NVL(px_tcnv_rec.tmt_accounting_entries_yn, G_NO) = G_NO THEN

          -- *************
          -- Reversal of Loss Provisions
          -- *************

          reverse_loss_provisions(
                    p_ia_rec            =>  p_ia_rec,
                    p_termination_date  =>  p_termination_date,
                    p_gl_date           =>  p_gl_date,
                    x_return_status     =>  l_return_status);

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE G_EXCEPTION_ERROR;
          END IF;

          -- Set return status
          x_return_status := l_return_status;

          px_tcnv_rec.tmt_accounting_entries_yn := G_YES;

       END IF;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO accounting_entries_trx;
            x_return_status := G_RET_STS_ERROR;
            px_tcnv_rec.tmt_accounting_entries_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO accounting_entries_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;
            px_tcnv_rec.tmt_accounting_entries_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO accounting_entries_trx;

            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;
            px_tcnv_rec.tmt_accounting_entries_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                             'EXP - OTHERS');
           END IF;

  END accounting_entries;

  -- Start of comments
  --
  -- Procedure Name  : update_ia_and_lines
  -- Description     : procedure to update investor agreement and lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_ia_and_lines(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    p_ialn_tbl          IN   ialn_tbl_type,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        lp_chrv_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
        lp_khrv_rec  OKL_CONTRACT_PUB.khrv_rec_type;
        lx_chrv_rec  OKL_OKC_MIGRATION_PVT.chrv_rec_type;
        lx_khrv_rec  OKL_CONTRACT_PUB.khrv_rec_type;

        lp_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
        lp_klev_rec  OKL_CONTRACT_PUB.klev_rec_type;
        lx_clev_rec  OKL_OKC_MIGRATION_PVT.clev_rec_type;
        lx_klev_rec  OKL_CONTRACT_PUB.klev_rec_type;

        l_trn_reason_code  VARCHAR2(30) := 'EXP';
        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);
        i NUMBER;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_ia_and_lines.',
                        'Begin(+)');
       END IF;

       -- *********
       -- Expire IA lines
       -- *********

       SAVEPOINT update_ia_and_lines_trx;

       -- If lines exists then update
       IF p_ialn_tbl.COUNT > 0 THEN

         -- Loop thru the IA lines and expire them
         FOR i IN p_ialn_tbl.FIRST..p_ialn_tbl.LAST LOOP

            -- Set the rec types
            lp_clev_rec.id  := p_ialn_tbl(i).id;
            lp_klev_rec.id  := p_ialn_tbl(i).id;
            lp_clev_rec.date_terminated := p_termination_date;
            lp_clev_rec.sts_code  := 'EXPIRED';
            lp_clev_rec.trn_code  := l_trn_reason_code;

            -- Call update lines to expire lines
            OKL_CONTRACT_PUB.update_contract_line(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_clev_rec       => lp_clev_rec,
                           p_klev_rec       => lp_klev_rec,
                           x_clev_rec       => lx_clev_rec,
                           x_klev_rec       => lx_klev_rec);

            IF l_return_status <> G_RET_STS_SUCCESS THEN
                 -- Error occured during update of Investor Agreement AGREEMENT_NUMBER lines.
                 OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_INV_TRMT_LINE_ERR',
                      p_token1        => 'AGREEMENT_NUMBER',
                      p_token1_value  => p_ia_rec.contract_number);
            END IF;

            -- raise exception if update failed
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
            END IF;


         END LOOP;

       END IF;

       -- *********
       -- Expire IA hdr
       -- *********

       -- Set the rec types
       lp_chrv_rec.id  := p_ia_rec.id;
       lp_khrv_rec.id  := p_ia_rec.id;
       lp_chrv_rec.date_terminated := p_termination_date;
       lp_chrv_rec.sts_code  := 'EXPIRED';
       lp_chrv_rec.trn_code  := l_trn_reason_code;

       -- Call update hdr to expire hdr
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

       IF l_return_status <> G_RET_STS_SUCCESS THEN
            -- Error occured during update of investor agreement AGREEMENT_NUMBER.
            OKL_API.set_message(
                      p_app_name      => G_APP_NAME,
                      p_msg_name      => 'OKL_AM_INV_TRMT_ERR',
                      p_token1        => 'AGREEMENT_NUMBER',
                      p_token1_value  => p_ia_rec.contract_number);
       END IF;

       -- raise exception if update failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set return status
       x_return_status := l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_ia_and_lines.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_ia_and_lines_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_ia_and_lines.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_ia_and_lines_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_ia_and_lines.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO update_ia_and_lines_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_ia_and_lines.',
                             'EXP - OTHERS');
           END IF;

  END update_ia_and_lines;

  -- Start of comments
  --
  -- Procedure Name  : update_pools
  -- Description     : procedure to update investor agreement pools
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --                   RMUNJULU Bug 3455354 Added code to set the lease contract
  --                   to NOT SECURITIZED if no other pool has it
  --
  -- End of comments
  PROCEDURE update_pools(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

       -- get the active pools for the IA
       CURSOR get_pools_csr(p_ia_id IN NUMBER) IS
            SELECT POL.id
            FROM   OKL_POOLS POL,
                   OKC_K_HEADERS_B KHR
            WHERE  KHR.id = p_ia_id
            AND    KHR.id = POL.khr_id
            AND    POL.status_code = 'ACTIVE'; -- ACTIVE

       -- get the pool contents for the pool ( Cannot use POC status as it is
       -- already set to EXPIRED when control comes here )
       CURSOR get_pool_contents_csr(p_pol_id IN NUMBER) IS
            SELECT POC.id,
                   POC.transaction_number_in
            FROM   OKL_POOLS POL,
                   OKL_POOL_CONTENTS POC
            WHERE  POL.id = p_pol_id
            AND    POC.pol_id = POL.id
            AND    POC.status_code = 'ACTIVE';

       -- RMUNJULU Bug 3455354
       -- get lease contract which is associated to this pool but not to any other ACTIVE ones
       CURSOR get_k_update_csr(p_pol_id IN NUMBER) IS
            SELECT DISTINCT POCA.khr_id
            FROM   OKL_POOL_CONTENTS POCA
            WHERE  POCA.pol_id = p_pol_id
            AND    NOT EXISTS (
                              SELECT POCB.khr_id
                              FROM   OKL_POOL_CONTENTS POCB
                              WHERE  POCB.pol_id <> POCA.pol_id
                              AND    POCB.khr_id = POCA.khr_id
                              AND    POCB.status_code = 'ACTIVE'
                              );

         --sosharma added cursor to fetch legal entity bug 6791390
         CURSOR c_pool(p_pool_id IN NUMBER) IS
          SELECT    pol.legal_entity_id
          FROM okl_pools pol
          WHERE pol.id = p_pool_id;



        lp_polv_rec  OKL_POL_PVT.polv_rec_type;
        lx_polv_rec  OKL_POL_PVT.polv_rec_type;
        lp_pocv_rec  OKL_POC_PVT.pocv_rec_type;
        lx_pocv_rec  OKL_POC_PVT.pocv_rec_type;
        lp_poxv_rec  OKL_POX_PVT.poxv_rec_type;
        lx_poxv_rec  OKL_POX_PVT.poxv_rec_type;

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);

         -- sosharma added gor bug 6791390
       l_row_found BOOLEAN := FALSE;
       l_legal_entity_id  NUMBER;

        -- RMUNJULU Bug 3455354
        l_chrv_rec    OKL_OKC_MIGRATION_PVT.chrv_rec_type;
        lx_chrv_rec   OKL_OKC_MIGRATION_PVT.chrv_rec_type;

        l_khrv_rec    OKL_CONTRACT_PUB.khrv_rec_type;
        lx_khrv_rec   OKL_CONTRACT_PUB.khrv_rec_type;


  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_pools.',
                        'Begin(+)');
       END IF;

       SAVEPOINT update_pools_trx;

       -- Loop thru the ACTIVE pools for the IA
       FOR get_pools_rec IN get_pools_csr(p_ia_rec.id) LOOP

            -- ********
            -- Update Pools
            -- ********

            lp_polv_rec.id :=  get_pools_rec.id;
            lp_polv_rec.status_code := 'EXPIRED';

            -- Call update_row to expire pools
            OKL_POL_PVT.update_row(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_polv_rec       => lp_polv_rec,
                           x_polv_rec       => lx_polv_rec);

            IF l_return_status <> G_RET_STS_SUCCESS THEN
                  -- Error occurred during update of pool for the
                  -- Investor Agreement AGREEMENT_NUMBER.
                  OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_UPD_POOL_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_ia_rec.contract_number);
            END IF;

            -- raise exception if update failed
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
            END IF;

            -- *********
            -- create pool transaction
            -- *********

            lp_poxv_rec.pol_id :=  get_pools_rec.id;
            lp_poxv_rec.transaction_date := p_termination_date;
            lp_poxv_rec.transaction_type := 'REMOVE';
            lp_poxv_rec.transaction_reason := 'AGREEMENT_TERMINATION';
            --sosharma 04/12/2007 added to enable status on pool transaction
		         lp_poxv_rec.transaction_status := G_POOL_TRX_STATUS_COMPLETE;
            -- Fixed bug 6791390 Legal entity got getting passed
            OPEN c_pool(get_pools_rec.id);
            FETCH c_pool INTO l_legal_entity_id;
                    l_row_found := c_pool%FOUND;
            CLOSE c_pool;
            IF l_row_found THEN
            lp_poxv_rec.legal_entity_id := l_legal_entity_id;
            END IF;
            -- Call insert_row to create pool transaction
            OKL_POX_PVT.insert_row(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_poxv_rec       => lp_poxv_rec,
                           x_poxv_rec       => lx_poxv_rec);

            IF l_return_status <> G_RET_STS_SUCCESS THEN
                 -- Error occurred during creation of pool transaction for
                 -- the Investor Agreement AGREEMENT_NUMBER.
                 OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_POOL_TRN_CRT_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_ia_rec.contract_number);
            END IF;

            -- raise exception if update failed
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE G_EXCEPTION_ERROR;
            END IF;

            -- ********
            -- Update Pool Contents
            -- ********

            -- Loop thru the ACTIVE pool contents for the pool
            FOR get_pool_contents_rec IN get_pool_contents_csr(get_pools_rec.id) LOOP


                 lp_pocv_rec.id :=  get_pool_contents_rec.id;
                 lp_pocv_rec.status_code := 'EXPIRED';
                 lp_pocv_rec.transaction_number_out :=  lx_poxv_rec.transaction_number;

                 -- Call update_row to expire pool contents
                 OKL_POC_PVT.update_row(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_pocv_rec       => lp_pocv_rec,
                           x_pocv_rec       => lx_pocv_rec);

                 IF l_return_status <> G_RET_STS_SUCCESS THEN
                      -- Error occurred during update of pool contents for
                      -- the Investor Agreement AGREEMENT_NUMBER.
                      OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_UPD_POC_IA_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_ia_rec.contract_number);
                 END IF;

                  -- raise exception if update failed
                 IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                     RAISE G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                     RAISE G_EXCEPTION_ERROR;
                 END IF;
            END LOOP;

            -- RMUNJULU Bug 3455354
            -- ****
            -- For the pool get the contract and update Contract SECURITIZED_CODE
            -- to 'N' if the contract is not attached to any other active pool
            -- ****

            FOR get_k_update_rec IN get_k_update_csr (get_pools_rec.id)LOOP

               l_chrv_rec.id := get_k_update_rec.khr_id;

               l_khrv_rec.id := get_k_update_rec.khr_id;
               l_khrv_rec.securitized_code := 'N';

               OKL_CONTRACT_PUB.update_contract_header(
                     p_api_version    => l_api_version,
                     p_init_msg_list  => OKL_API.G_FALSE,
                     x_return_status  => l_return_status,
                     x_msg_count      => l_msg_count,
                     x_msg_data       => l_msg_data,
                     p_chrv_rec       => l_chrv_rec,
                     p_khrv_rec       => l_khrv_rec,
                     x_chrv_rec       => lx_chrv_rec,
                     x_khrv_rec       => lx_khrv_rec);

               IF l_return_status <> G_RET_STS_SUCCESS THEN
                     -- Error occurred during update of pool for the
                     -- Investor Agreement AGREEMENT_NUMBER.
                     OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_UPD_POOL_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_ia_rec.contract_number);
               END IF;

               -- raise exception if update failed
               IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                   RAISE G_EXCEPTION_ERROR;
               END IF;

            END LOOP;

       END LOOP;

       -- Set return status
       x_return_status := l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_pools.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_pools_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_pools.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_pools_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_pools.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO update_pools_trx;

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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_pools.',
                             'EXP - OTHERS');
           END IF;

  END update_pools;

  -- Start of comments
  --
  -- Procedure Name  : update_investor_agreement
  -- Description     : procedure to update investor agreement and lines and pools
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_investor_agreement(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    p_ialn_tbl          IN   ialn_tbl_type,
                    px_tcnv_rec         IN   OUT NOCOPY tcnv_rec_type,
                    p_overall_status    IN   VARCHAR2,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                        'Begin(+)');
       END IF;

       SAVEPOINT update_ia_trx;

       -- If all steps successful then do update_ia
       IF  p_overall_status = G_RET_STS_SUCCESS  THEN

          -- *************
          -- Update Pool, Create Pool Trn and Update Pool contents
          -- *************

          update_pools(
                    p_ia_rec            =>  p_ia_rec,
                    p_termination_date  =>  p_termination_date,
                    x_return_status     =>  l_return_status);

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE G_EXCEPTION_ERROR;
          END IF;

          -- *************
          -- Update IA and Lines to Expired
          -- *************

          update_ia_and_lines(
                    p_ia_rec            =>  p_ia_rec,
                    p_termination_date  =>  p_termination_date,
                    p_ialn_tbl          =>  p_ialn_tbl,
                    x_return_status     =>  l_return_status);

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
               RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
               RAISE G_EXCEPTION_ERROR;
          END IF;

          -- Set the success message
          -- Investor agreement AGREEMENT_NUMBER expired successfully.
          OKL_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_AM_INV_TRMNT_SUCC',
                          p_token1       => 'AGREEMENT_NUMBER',
                          p_token1_value => p_ia_rec.contract_number);

          -- Set return status
          x_return_status := l_return_status;

          px_tcnv_rec.tmt_contract_updated_yn := G_YES;
          px_tcnv_rec.tsu_code := 'PROCESSED';

       END IF;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_ia_trx;
            x_return_status := G_RET_STS_ERROR;
            px_tcnv_rec.tmt_contract_updated_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_ia_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;
            px_tcnv_rec.tmt_contract_updated_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN
            ROLLBACK TO update_ia_trx;

            -- Set the oracle error message
            OKL_API.set_message(
                 p_app_name      => G_APP_NAME_1,
                 p_msg_name      => G_UNEXPECTED_ERROR,
                 p_token1        => G_SQLCODE_TOKEN,
                 p_token1_value  => SQLCODE,
                 p_token2        => G_SQLERRM_TOKEN,
                 p_token2_value  => SQLERRM);

            x_return_status := G_RET_STS_UNEXP_ERROR;
            px_tcnv_rec.tmt_contract_updated_yn := G_NO;
            px_tcnv_rec.tsu_code := 'ERROR';

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                             'EXP - OTHERS');
           END IF;

  END  update_investor_agreement;

  -- Start of comments
  --
  -- Procedure Name  : update_transaction
  -- Description     : procedure to update termination transaction for the investor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --
  -- End of comments
  PROCEDURE update_transaction(
                    p_ia_rec            IN   ia_rec_type,
                    p_termination_date  IN   DATE,
                    p_tcnv_rec          IN   tcnv_rec_type,
                    x_return_status     OUT  NOCOPY VARCHAR2) IS

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        lp_tcnv_rec   tcnv_rec_type  :=  p_tcnv_rec;
        lx_tcnv_rec   tcnv_rec_type ;

        l_api_version  CONSTANT NUMBER	:= G_API_VERSION;
        l_msg_count	   NUMBER := G_MISS_NUM;
        l_msg_data     VARCHAR2(2000);

  BEGIN

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_transaction.',
                        'Begin(+)');
       END IF;

       SAVEPOINT update_transaction_trx;

       -- Call update_trx_contracts to update transaction
       OKL_TRX_CONTRACTS_PUB.update_trx_contracts(
                           p_api_version    => l_api_version,
                           p_init_msg_list  => G_FALSE,
                           x_return_status  => l_return_status,
                           x_msg_count      => l_msg_count,
                           x_msg_data       => l_msg_data,
                           p_tcnv_rec       => lp_tcnv_rec,
                           x_tcnv_rec       => lx_tcnv_rec);

       -- Set msg if error
       IF l_return_status <> G_RET_STS_SUCCESS THEN
            -- Error occured during update of termination transaction
            -- for Investor Agreement AGREEMENT_NUMBER.
            OKL_API.set_message(
                          p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_AM_INV_TRN_UPD_IA_ERR',
                          p_token1        => 'AGREEMENT_NUMBER',
                          p_token1_value  => p_ia_rec.contract_number);
       END IF;

       -- raise exception if update failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set return status
       x_return_status := l_return_status;

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.update_transaction.',
                        'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION_ERROR THEN
            ROLLBACK TO update_transaction_trx;
            x_return_status := G_RET_STS_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_transaction.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_transaction_trx;
            x_return_status := G_RET_STS_UNEXP_ERROR;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_transaction.',
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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.update_transaction.',
                             'EXP - OTHERS');
           END IF;

  END update_transaction;

  -- Start of comments
  --
  -- Procedure Name  : terminate_investor_agreement
  -- Description     : procedure to terminate investor agreement
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --                 : RMUNJULU 22-OCT-03 Changed code to do proper processing
  --
  -- End of comments
  PROCEDURE terminate_investor_agreement(
                    p_api_version    IN   NUMBER,
                    p_init_msg_list  IN   VARCHAR2 DEFAULT G_FALSE,
                    x_return_status  OUT  NOCOPY VARCHAR2,
                    x_msg_count      OUT  NOCOPY NUMBER,
                    x_msg_data       OUT  NOCOPY VARCHAR2,
                    p_ia_rec         IN   ia_rec_type,
                    p_control_flag   IN   VARCHAR2 DEFAULT NULL) IS

        -- Get the latest IA Status
        CURSOR ia_status_csr (p_ia_id IN NUMBER) IS
             SELECT CHR.sts_code status
             FROM   OKC_K_HEADERS_B CHR
             WHERE  CHR.id = p_ia_id;

        l_return_status    VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_overall_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
        l_trx_id NUMBER;
        l_pdt_id NUMBER;
        l_ia_rec ia_rec_type := p_ia_rec;
        l_ialn_tbl ialn_tbl_type;
        l_sys_date DATE;
        l_tcnv_rec tcnv_rec_type;
        l_trn_already_yn VARCHAR2(1);
        l_end_date DATE;
        l_start_date DATE;
        l_type VARCHAR2(300);
        l_status VARCHAR2(300);
        l_control_flag VARCHAR2(300);
        l_valid_gl_date DATE;

     	lx_error_rec  OKL_API.error_rec_type;
        l_msg_idx     INTEGER := G_FIRST;
        l_msg_tbl msg_tbl_type;
        l_api_name VARCHAR2(30) := 'terminate_investor_ag';
      	l_api_version CONSTANT NUMBER := G_API_VERSION;

        G_EXCEPTION EXCEPTION;

  BEGIN

       -- Create a Termination Transaction -- tcn_type = 'IAT' first time --
       -- Uses the created termination transaction later on, but does validate every time
       -- will not do Accounting Entries if already done

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
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

       -- Get valid GL Date for Termination_Date
       l_valid_gl_date := OKL_ACCOUNTING_UTIL.get_valid_gl_date(
                                                       p_gl_date => l_sys_date);

       -- *************
       -- Validate IA
       -- *************

       val_pop_investor_agreement(
                       p_ia_rec         =>  p_ia_rec,
                       x_ia_rec         =>  l_ia_rec,
                       x_ialn_tbl       =>  l_ialn_tbl,
                       x_return_status  =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                         'val_pop_investor_agreement = '||l_return_status );
       END IF;

       -- Set Overall Status
       IF  l_overall_status =  G_RET_STS_SUCCESS
       AND l_overall_status <> G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := l_return_status;
       END IF;

       -- *************
       -- Populate or Insert IA Transaction based on need
       -- *************
       pop_or_insert_transaction(
                       p_ia_rec           =>  l_ia_rec,
                       p_sys_date         =>  l_sys_date,
                       x_trn_already_yn   =>  l_trn_already_yn,
                       px_tcnv_rec        =>  l_tcnv_rec,
                       p_validate_success =>  l_overall_status,
                       x_return_status    =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.pop_or_insert_transaction.',
                         'pop_or_insert_transaction = '||l_return_status );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
            RAISE G_EXCEPTION_ERROR;
       END IF;

       -- If validation was not successful
       IF l_overall_status <> G_RET_STS_SUCCESS THEN

          -- *************
          -- Update IA Transaction
          -- *************

          update_transaction(
                   p_ia_rec           =>  l_ia_rec,
                   p_termination_date =>  l_sys_date,
                   p_tcnv_rec         =>  l_tcnv_rec,
                   x_return_status    =>  l_return_status);

          IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                            'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                            'update_transaction = '||l_return_status );
          END IF;

          -- raise exception if api failed
          IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE G_EXCEPTION_ERROR;
          END IF;

          -- Raise exception to come out since validation failed
          RAISE G_EXCEPTION;
       END IF;

       -- *************
       -- Do Accounting Entries
       -- *************

       accounting_entries(
                       p_ia_rec           =>  l_ia_rec,
                       p_termination_date =>  l_sys_date,
                       p_gl_date          =>  l_valid_gl_date,
                       px_tcnv_rec        =>  l_tcnv_rec,
                       x_return_status    =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.accounting_entries.',
                         'accounting_entries = '||l_return_status );
       END IF;

       -- Set Overall Status
       IF  l_overall_status =  G_RET_STS_SUCCESS
       AND l_overall_status <> G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := l_return_status;
       END IF;

       -- *************
       -- Update IA, Lines, Pools, Pool Contents
       -- *************

       update_investor_agreement(
                       p_ia_rec            =>  l_ia_rec,
                       p_termination_date  =>  l_sys_date,
                       p_ialn_tbl          =>  l_ialn_tbl,
                       px_tcnv_rec         =>  l_tcnv_rec,
                       p_overall_status    =>  l_overall_status,
                       x_return_status     =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.update_investor_agreement.',
                         'update_investor_agreement = '||l_return_status );
       END IF;

       -- *************
       -- Update IA Transaction
       -- *************

       update_transaction(
                   p_ia_rec           =>  l_ia_rec,
                   p_termination_date =>  l_sys_date,
                   p_tcnv_rec         =>  l_tcnv_rec,
                   x_return_status    =>  l_return_status);

       IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                         'update_transaction = '||l_return_status );
       END IF;

       -- raise exception if api failed
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE G_EXCEPTION_ERROR;
       END IF;

       -- Set the return status
       x_return_status := l_return_status;

       -- Store messages in TRX_MSGS
       OKL_AM_UTIL_PVT.process_messages(
              	   p_trx_source_table  => 'OKL_TRX_CONTRACTS',
               	   p_trx_id		       => l_tcnv_rec.id,
               	   x_return_status     => l_return_status);

       -- Set the output log if request from BATCH
       IF p_control_flag LIKE 'BATCH%' THEN

           -- get the latest status
           FOR ia_status_rec IN ia_status_csr( l_ia_rec.id) LOOP
               l_ia_rec.sts_code := ia_status_rec.status;
           END LOOP;

           fnd_output  (
                  p_ia_rec       => l_ia_rec,
                  p_control_flag => l_tcnv_rec.tsu_code);

       END IF;

       -- End Activity
       OKL_API.end_activity (x_msg_count, x_msg_data);

       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                         'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                         'End(-)');
       END IF;

  EXCEPTION

      WHEN G_EXCEPTION THEN

            -- Store messages in TRX_MSGS
            OKL_AM_UTIL_PVT.process_messages(
                    	   p_trx_source_table  => 'OKL_TRX_CONTRACTS',
               	           p_trx_id		       => l_tcnv_rec.id,
               	           x_return_status     => l_return_status);

            x_return_status := G_RET_STS_SUCCESS;

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_ia_rec       => l_ia_rec,
                  p_control_flag => 'ERROR');
            END IF;

           IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                             'EXP - G_EXCEPTION');
           END IF;

      WHEN G_EXCEPTION_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_ia_rec       => l_ia_rec,
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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

      WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_ia_rec       => l_ia_rec,
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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

      WHEN OTHERS THEN

            -- Set the output log if request from BATCH
            IF p_control_flag LIKE 'BATCH%' THEN
               fnd_output  (
                  p_ia_rec       => l_ia_rec,
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
                             'OKL_AM_TERMINATE_INV_AGMT_PVT.terminate_investor_agreement.',
                             'EXP - OTHERS');
           END IF;

  END terminate_investor_agreement;

  -- Start of comments
  --
  -- Procedure Name  : concurrent_expire_inv_agrmt
  -- Description     : This procedure is called by concurrent manager to terminate
  --                   ended investor agreements. When running the concurrent
  --                   manager request, a request can be made for a single IA to
  --                   be terminated or else all the ended IAs will be picked
  --                   If No End Date is Passed Defaulted to SysDate
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU Created
  --                 : RMUNJULU 115.4 3061748 Added code to throw error if
  --                   Termination Date is invalid
  --
  -- End of comments
  PROCEDURE concurrent_expire_inv_agrmt(
                    errbuf           OUT NOCOPY VARCHAR2,
                    retcode          OUT NOCOPY VARCHAR2,
                    p_api_version    IN  VARCHAR2,
                	p_init_msg_list  IN  VARCHAR2 DEFAULT G_FALSE,
                    p_ia_id          IN  VARCHAR2 DEFAULT NULL,
                    p_date           IN  VARCHAR2 DEFAULT NULL) IS

       -- Get the IAs which have reached their end_date and still active and no processed trn exists
       CURSOR get_expired_ia_csr (p_date IN DATE) IS
            SELECT  CHR.id,
                    CHR.contract_number
            FROM    OKC_K_HEADERS_B CHR
            WHERE   CHR.scs_code = 'INVESTOR' -- IA
            AND     CHR.sts_code = 'ACTIVE' -- ACTIVE
            AND     CHR.date_terminated IS NULL -- Not Terminated
            AND     CHR.end_date <= TRUNC(p_date)   -- Ended -- RMUNJULU 115.4 3061748 Changed to pick equal dates
            AND     CHR.id NOT IN (SELECT TRX.khr_id FROM OKL_TRX_CONTRACTS TRX -- Dont get IA's with Processed TRN
                                   WHERE   TRX.tsu_code = 'PROCESSED'
                                   --rkuttiya added for 12.1.1 Multi GAAP
                                   AND     TRX.representation_type = 'PRIMARY'
                                  --
                                   AND     TRX.tcn_type = 'IAT');

        l_return_status  VARCHAR2(1);
        l_msg_count  NUMBER;
        l_msg_data   VARCHAR2(2000);
        l_sys_date DATE;
        l_date DATE;
        l_api_version NUMBER;
        l_ia_id NUMBER;
        l_ia_rec ia_rec_type;

  BEGIN

       -- Initialize message list
       OKL_API.init_msg_list('T');

       SELECT SYSDATE INTO l_sys_date FROM DUAL;

       IF p_date IS NULL THEN
           l_date := l_sys_date;
       ELSE
           l_date := TO_DATE(SUBSTR(p_date,1,10),'RRRR/MM/DD');
           IF l_date > TRUNC(l_sys_date) THEN
               -- RMUNJULU 115.4 3061748
               G_ERROR := 'Y';
--               l_date := l_sys_date;
           END IF;
       END IF;

       -- RMUNJULU 115.4 3061748
       IF G_ERROR <> 'Y' THEN

          G_INV_ENDED_BY_DATE := TRUNC(l_date);

          l_api_version := TO_NUMBER(p_api_version);
          l_ia_id := TO_NUMBER(p_ia_id);

          -- Check if a single IA termination request
          IF l_ia_id IS NOT NULL THEN

             l_ia_rec.id := l_ia_id;

             -- Terminate the IA
             terminate_investor_agreement(
                 p_api_version     =>  l_api_version,
                 p_init_msg_list   =>  G_FALSE,
                 x_return_status   =>  l_return_status,
                 x_msg_count       =>  l_msg_count,
                 x_msg_data        =>  l_msg_data,
                 p_ia_rec          =>  l_ia_rec,
                 p_control_flag    =>  'BATCH_SINGLE');

          ELSE  -- No IA passed, so scheduled request to terminate all expired IAs

             -- Loop thru the expired IAs
             FOR get_expired_ia_rec IN get_expired_ia_csr(G_INV_ENDED_BY_DATE) LOOP

                 l_ia_rec.id := get_expired_ia_rec.id;
                 l_ia_rec.contract_number := get_expired_ia_rec.contract_number;

                 -- Terminate the IA
                 terminate_investor_agreement(
                         p_api_version     =>  l_api_version,
                         p_init_msg_list   =>  G_TRUE,
                         x_return_status   =>  l_return_status,
                         x_msg_count       =>  l_msg_count,
                         x_msg_data        =>  l_msg_data,
                         p_ia_rec          =>  l_ia_rec,
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

  END concurrent_expire_inv_agrmt;

END OKL_AM_TERMINATE_INV_AGMT_PVT;

/
