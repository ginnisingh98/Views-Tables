--------------------------------------------------------
--  DDL for Package Body OKL_GL_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GL_TRANSFER_PVT" AS
/* $Header: OKLRGLTB.pls 120.8 2007/01/24 12:43:40 rgooty noship $ */


-- Calls common transfer to GL API.

FUNCTION  GET_PROPER_LENGTH(p_input_data          IN   VARCHAR2,
                            p_input_length        IN   NUMBER,
				    p_input_type          IN   VARCHAR2)
RETURN VARCHAR2

IS

x_return_data VARCHAR2(1000);

BEGIN

IF (p_input_type = 'TITLE') THEN
    IF (p_input_data IS NOT NULL) THEN
     x_return_data := RPAD(SUBSTR(ltrim(rtrim(p_input_data)),1,p_input_length),p_input_length,' ');
    ELSE
     x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
ELSE
    IF (p_input_data IS NOT NULL) THEN
         IF (length(p_input_data) > p_input_length) THEN
             x_return_data := RPAD('*',p_input_length,'*');
         ELSE
             x_return_data := RPAD(p_input_data,p_input_length,' ');
         END IF;
    ELSE
         x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
END IF;

RETURN x_return_data;

END GET_PROPER_LENGTH;


PROCEDURE CREATE_REPORT(p_request_id NUMBER)
IS
--Added by Keerthi to format the report

/*  TYPE report_rec_type IS RECORD(
    transaction_date            char(12),
    contract_number	 	char(20),
    transaction_number		char(14),
    transaction_line_number	char(6),
    accounting_date		char(12),
    dr_cr_flag			char(4),
    accounted_amount		char(19),
    account			char(30),
    currency			char(4));
*/

--Changed by Santonyr to support multi-byte formats Bug Number 2960042

  TYPE report_rec_type IS RECORD(
    transaction_date            VARCHAR2(36),
    contract_number	 	VARCHAR2(60),
    transaction_number		VARCHAR2(42),
    transaction_line_number	VARCHAR2(18),
    accounting_date		VARCHAR2(36),
    dr_cr_flag			VARCHAR2(12),
    accounted_amount		VARCHAR2(57),
    account			VARCHAR2(90),
    currency			VARCHAR2(12));


    l_transaction_date_len      NUMBER := 12;
    --PAGARG Bug 4198290 As Account is moved to next line, increased the length
    --for contract number
    l_contract_num_len    	  NUMBER := 45;
    l_transaction_num_len	  NUMBER := 14;
    l_transaction_line_num_len  NUMBER := 7;
    l_accounting_date_len	  NUMBER := 12;
    l_dr_cr_flag_len		  NUMBER := 4;
    l_accounted_amount_len		  NUMBER := 19;
    --PAGARG Bug 4198290 As Account is moved to next line, increased the length
    l_account_len			  NUMBER := 90;
    --PAGARG Bug 4198290 As Account is moved to next line, increased the length
    --for currency
    l_currency_len		  NUMBER := 8;
    l_offset_len                NUMBER := 115;

    header_report1_rec         report_rec_type;
    header_report2_rec		report_rec_type;
    proc_report_rec 		report_rec_type;
    non_proc_report_rec		report_rec_type;

-- Changed by Santonyr on 18th Jun, 2003 to fix the bug 3012735
-- Changed the length of variables to hold the multi-byte values

  l_line_length          NUMBER   :=121;
  l_total_process        NUMBER   :=0;
  l_error_process        NUMBER   :=0;
  l_success_process      NUMBER   :=0;
  l_set_of_books_name    VARCHAR2(150);
  l_temp_trx_number      VARCHAR2(90);
  l_accounted_amount     VARCHAR2(60);
  l_dr_cr_flag		 VARCHAR2(30);
  l_temp_trx_type        VARCHAR2(90);
  l_temp_contract_number VARCHAR2(120);
  l_date_transaction_occurred DATE;
  l_temp_line_number     NUMBER;
  l_temp_acc_date        DATE;
  l_temp_period_name     VARCHAR2(90);
  l_temp_start_date      DATE;
  l_temp_end_date        DATE;
  l_org_name		VARCHAR2(150);
  l_org_id               NUMBER;

 CURSOR cntrct_details_csr(l_source_id NUMBER)  IS
  SELECT tcn.trx_number,
	khr.contract_number,
	tcn.date_transaction_occurred,
	tcl.line_number
  FROM 	okl_trx_contracts tcn,
    	okl_trx_types_v try,
     	okc_k_headers_b khr,
     	okl_txl_cntrct_lns tcl
  WHERE tcn.id = tcl.tcn_id AND
      tcn.try_id = try.id AND
      tcn.khr_id = khr.id AND
      tcl.id = l_source_id;

 CURSOR asset_details_csr(l_source_id NUMBER)  IS
  SELECT tas.trans_number,
	khr.contract_number,
	tas.date_trans_occurred,
	tal.line_number
  FROM 	okl_trx_assets tas,
        okl_txl_assets_b tal,
        okl_trx_types_v try,
        okc_k_headers_b khr
  WHERE tas.id = tal.tas_id AND
        tas.try_id = try.id AND
        tal.dnz_khr_id = khr.id AND
        tal.id = l_source_id;

CURSOR ae_category_csr(p_request_id NUMBER) IS
  SELECT sum(accounted_dr) total_dr,
    sum(accounted_cr) total_cr,
         try.name  try_name,
         try.id    try_id,
         aeh.ae_category ae_category,
         ael.currency_code
  FROM  okl_Ae_headers aeh,
        okl_ae_lines ael,
        okl_trx_types_v try,
        okl_txl_cntrct_lns tcl,
        okl_trx_contracts tcn
  WHERE aeh.ae_header_id=ael.ae_header_id
  AND   aeh.accounting_error_code IS NULL
  AND   ael.accounting_error_code IS NULL
  AND   aeh.request_id = p_request_id
  AND   ael.source_id  = tcl.id
  AND   tcl.tcn_id = tcn.id
  AND   tcn.try_id = try.id
  GROUP BY aeh.ae_category,
           try.name,
 	   try.id,
           ael.currency_code
  UNION
  SELECT  sum(accounted_dr) total_dr,
    sum(accounted_cr) total_cr,
         try.name  try_name,
	 try.id try_id,
         aeh.ae_category ae_category,
         ael.currency_code
  FROM  okl_Ae_headers  aeh,
        okl_ae_lines     ael,
        okl_trx_types_v try,
        okl_trx_assets   tas,
        okl_txl_assets_b tal
  WHERE aeh.ae_header_id=ael.ae_header_id
  AND   aeh.accounting_error_code IS NULL
  AND   ael.accounting_error_code IS NULL
  AND   aeh.request_id = p_request_id
  AND   ael.source_id  = tal.id
  AND   tal.tas_id = tas.id
  AND   tas.try_id = try.id
  GROUP BY aeh.ae_category,
           try.name,
	   try.id,
           ael.currency_code;

CURSOR gl_proc_dst_csr(p_request_id NUMBER,
                       p_category VARCHAR,
		       p_try_id   NUMBER,
                       p_currency_code VARCHAR)  IS
SELECT  ael.source_table,
         ael.source_id,
         ael.ae_line_number,
         aeh.accounting_date,
         aeh.ae_category,
         ael.accounted_dr,
         ael.accounted_cr,
         okl_Accounting_util.get_concat_segments(ael.code_combination_id) account,
         ael.currency_code
  FROM okl_ae_headers aeh,
       okl_ae_lines ael,
       okl_txl_cntrct_lns tcl,
       okl_trx_contracts tcn
 WHERE ael.ae_header_id = aeh.ae_header_id
 AND ael.gl_transfer_error_code is null
 AND aeh.request_id = p_request_id
 AND aeh.ae_category=p_category
 AND ael.currency_code = p_currency_code
 AND   tcl.id = ael.source_id
 AND   tcl.tcn_id = tcn.id
 AND   tcn.try_id = p_try_id
 ORDER BY ael.source_id;

CURSOR gl_error_dst_csr(p_request_id NUMBER)  IS
SELECT  ael.source_table,
         ael.source_id,
         ael.ae_line_number,
         aeh.accounting_date,
         aeh.ae_category,
         ael.accounted_dr,
         ael.accounted_cr,
         okl_Accounting_util.get_concat_segments(ael.code_combination_id) account,
         ael.currency_code
  FROM okl_ae_headers aeh,
       okl_ae_lines ael
 WHERE ael.ae_header_id = aeh.ae_header_id
 AND ael.gl_transfer_error_code is not null
 AND aeh.request_id = p_request_id
 ORDER BY ael.source_id;

CURSOR header_details_csr(p_request_id NUMBER) IS
 SELECT count(*) total,
        ael.gl_transfer_error_code
 FROM okl_ae_headers aeh,
      okl_ae_lines   ael
 WHERE aeh.request_id    = p_request_id
 AND   aeh.ae_header_id  = ael.ae_header_id
 GROUP BY ael.gl_transfer_error_code;

 CURSOR org_csr (p_org_id IN NUMBER) IS
   SELECT name
   FROM   hr_operating_units
   WHERE  organization_id = p_org_id;

BEGIN


     l_org_id     := MO_GLOBAL.GET_CURRENT_ORG_ID();

--to print the header in 2 lines

     header_report1_rec.transaction_date		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_TRANSACTION'),l_transaction_date_len,'TITLE');

     header_report1_rec.contract_number		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_CONTRACT'),l_contract_num_len,'TITLE');

     header_report1_rec.transaction_number		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_TRANSACTION'),l_transaction_num_len,'TITLE');

     header_report1_rec.transaction_line_number	:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_ACC_LINE'),l_transaction_line_num_len,'TITLE');

     header_report1_rec.accounting_date		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_ACCOUNT_ING'),l_accounting_date_len,'TITLE');

     header_report1_rec.dr_cr_flag		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_DR_CR_FLAG'),l_dr_cr_flag_len,'TITLE');

     header_report1_rec.accounted_amount	:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_ACCOUNTED'),l_accounted_amount_len,'TITLE');

     --PAGARG Bug 4198290 As Account is moved to next line, no need to trim it.
     --Can accomodate the complete title
     header_report1_rec.account	:= okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_ACCOUNT');

     header_report1_rec.currency			:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_CURRENCY'),l_currency_len,'TITLE');

     header_report2_rec.transaction_date		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_DATE'),l_transaction_date_len,'TITLE');

     header_report2_rec.contract_number		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_NUMBER'),l_contract_num_len,'TITLE');

     header_report2_rec.transaction_number		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_NUMBER'),l_transaction_num_len,'TITLE');

     header_report2_rec.transaction_line_number	:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_NUMBER'),l_transaction_line_num_len,'TITLE');

     header_report2_rec.accounting_date		:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_DATE'),l_accounting_date_len,'TITLE');

     header_report2_rec.dr_cr_flag		:=LPAD(' ',l_dr_cr_flag_len,' ');

     header_report2_rec.accounted_amount	:=GET_PROPER_LENGTH(okl_accounting_util.get_message_token
                                            ('OKL_LP_GL_TRANSFER','OKL_AMOUNT'),l_accounted_amount_len,'TITLE');

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 54 , ' ' ) ||  okl_accounting_util.get_message_token
                                       ('OKL_LP_GL_TRANSFER','OKL_ACCT_LEASE_MANAGEMENT'));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 54 , ' ' ) ||  '-----------------------');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 51 , ' ' ) ||  okl_accounting_util.get_message_token
                                       ('OKL_LP_GL_TRANSFER','OKL_GL_TRANSFER_REPORT'));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 51 , ' ' ) ||  '------------------------------');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '');

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                    'OKL_RUN_DATE'),30,' ')||':'|| SUBSTR(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'),1,30));

     l_set_of_books_name := okl_accounting_util.get_set_of_books_name (okl_accounting_util.get_set_of_books_id);

     FOR org_rec IN org_csr (l_org_id)
     LOOP
       l_org_name := org_rec.name;
     END LOOP;

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                                   'OKL_SET_OF_BOOKS'),30,' ')
                                   ||':'|| RPAD(SUBSTR(l_set_of_books_name, 1, 30), 30, ' ') || LPAD(' ', 45 , ' ' ) );
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD( okl_accounting_util.get_message_token
                                  ('OKL_LP_GL_TRANSFER','OKL_OPERUNIT'),30,' ')
                                  ||':'|| SUBSTR(l_org_name, 1, 30) );

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

     FOR header_details_rec IN header_details_csr(p_request_id)
     LOOP

       IF header_details_rec.gl_transfer_error_code is null THEN
           l_success_process := header_details_rec.total;
       END IF;

       IF header_details_rec.gl_transfer_error_code is not null THEN
          l_error_process	:= header_details_rec.total;
       END IF;

     END LOOP;

     l_total_process	:=l_success_process + l_error_process;

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                                     'OKL_TOTAL_ACCT_LINES'),65,' ') ||':'||l_total_process);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                                     'OKL_ACCT_LINES_SUCCESS'),65,' ') ||':'||l_success_process);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                                     'OKL_ACCT_LINES_ERROR'),65,' ') ||':'||l_error_process);
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_PROCESSED_ENTRIES'));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'-----------------');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

     OPEN ae_category_csr(p_request_id);

     IF ae_category_csr%NOTFOUND THEN
  	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_NO_RECORDS'));
     END IF;

     CLOSE ae_category_csr;

     FOR ae_category_rec IN ae_category_csr(p_request_id)
     LOOP

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER',
                     'OKL_JOURNAL_CATEGORY')||' :'||ae_category_rec.ae_category ||'       '||
                      okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_TRANSACTION_TYPE')||
                      ':'||ae_category_rec.try_name , l_line_length ,' '));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,header_report1_rec.transaction_date||
	                    			 header_report1_rec.contract_number||
                   				   header_report1_rec.transaction_number ||
	 			                   header_report1_rec.transaction_line_number ||
				                   header_report1_rec.accounting_date ||
				                   header_report1_rec.dr_cr_flag ||
				                   header_report1_rec.accounted_amount ||
				                   header_report1_rec.currency);

 	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,header_report2_rec.transaction_date||
	                    			 header_report2_rec.contract_number||
                   				   header_report2_rec.transaction_number ||
	 			                   header_report2_rec.transaction_line_number ||
				                   header_report2_rec.accounting_date||
				                   header_report2_rec.dr_cr_flag ||
				                   header_report2_rec.accounted_amount );

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-', l_line_length , '-' ));

         FOR gl_proc_dst_rec IN gl_proc_dst_csr(p_request_id,
						ae_category_rec.ae_category,
						ae_category_rec.try_id,
						ae_category_rec.currency_code)
         LOOP

                IF (gl_proc_dst_rec.source_table='OKL_TXL_CNTRCT_LNS') THEN

                    OPEN cntrct_details_csr(gl_proc_dst_rec.source_id) ;
                    FETCH cntrct_details_csr INTO  l_temp_trx_number,
                                                   l_temp_contract_number ,
                                                   l_date_transaction_occurred,
                                                   l_temp_line_number;
                    CLOSE cntrct_details_csr;

                ELSE

                    OPEN asset_details_csr(gl_proc_dst_rec.source_id) ;
                    FETCH asset_details_csr INTO  l_temp_trx_number,
                                                  l_temp_contract_number ,
                                                  l_date_transaction_occurred,
                                                  l_temp_line_number;
                    CLOSE asset_details_csr;

                END IF;

                IF gl_proc_dst_rec.accounted_dr IS  NOT NULL  THEN
        		l_dr_cr_flag 		:= 'D';
                        l_accounted_amount    := gl_proc_dst_rec.accounted_dr;
	        END IF;

		IF gl_proc_dst_rec.accounted_cr IS  NOT NULL THEN
          		l_dr_cr_flag 		:= 'C';
                        l_accounted_amount    := gl_proc_dst_rec.accounted_cr;
      		END IF;

                proc_report_rec.transaction_date	:= GET_PROPER_LENGTH(l_date_transaction_occurred,
                                                          l_transaction_date_len,'DATA');
        --PAGARG Bug 4198290 Instead of putting * substring the contract number
        --if exceeds given length
        proc_report_rec.contract_number :=
          RPAD(SUBSTR(l_temp_contract_number,1,l_contract_num_len),l_contract_num_len, ' ');
	        proc_report_rec.transaction_number	:= GET_PROPER_LENGTH(l_temp_trx_number,l_transaction_num_len,'DATA');
	        proc_report_rec.transaction_line_number	:= GET_PROPER_LENGTH(l_temp_line_number,
                                                        l_transaction_line_num_len,'DATA');
	        proc_report_rec.accounting_date		:= GET_PROPER_LENGTH(gl_proc_dst_rec.accounting_date,
                                                         l_accounting_date_len,'DATA');
	        proc_report_rec.dr_cr_flag		:= GET_PROPER_LENGTH(l_dr_cr_flag,
                                                         l_dr_cr_flag_len,'DATA');
                proc_report_rec.accounted_amount	:= GET_PROPER_LENGTH(okl_Accounting_util.format_amount(l_accounted_amount,gl_proc_dst_rec.currency_code),
                                                         l_accounted_amount_len,'DATA');
              --PAGARG Bug 4198290 As Account is moved to next line, no need to
              --check length, display complete data
	          proc_report_rec.account := gl_proc_dst_rec.account;
	          proc_report_rec.currency        	:= GET_PROPER_LENGTH(gl_proc_dst_rec.currency_code,
                                                         l_currency_len,'DATA');

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,proc_report_rec.transaction_date ||
  		                            	  proc_report_rec.contract_number ||
						  proc_report_rec.transaction_number ||
					          proc_report_rec.transaction_line_number ||
					          proc_report_rec.accounting_date ||
					          proc_report_rec.dr_cr_flag ||
				                  proc_report_rec.accounted_amount||
					          proc_report_rec.currency);
                --PAGARG Bug 4198290 Move account data to next line
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, header_report1_rec.account ||' : '|| proc_report_rec.account);

               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_line_length , ' ' ));

         END LOOP;

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_line_length , '-' ));

	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_TOTAL') ||
                     RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_DEBIT'),l_accounted_amount_len,' ') ||':'||
                     GET_PROPER_LENGTH(okl_Accounting_util.format_amount(ae_category_rec.total_dr,ae_category_rec.currency_code), l_accounted_amount_len,'DATA') );

	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_TOTAL') ||
                     RPAD(okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_CREDIT_AMT'),l_accounted_amount_len,' ') ||':'||
                                        GET_PROPER_LENGTH(okl_Accounting_util.format_amount(ae_category_rec.total_cr,ae_category_rec.currency_code), l_accounted_amount_len,'DATA'));

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_line_length , '-' ));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

 END LOOP;

--For Unprocessed entries
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_ERROR_LOG'));
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_INVALID_ACCOUNT'));
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'---------------');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',l_line_length,' '));

       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,header_report1_rec.transaction_date||
	                    			 header_report1_rec.contract_number||
                   				   header_report1_rec.transaction_number ||
	 			                   header_report1_rec.transaction_line_number ||
				                   header_report1_rec.accounting_date ||
				                   header_report1_rec.dr_cr_flag ||
				                   header_report1_rec.accounted_amount ||
				                   header_report1_rec.currency);


 	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,header_report2_rec.transaction_date||
	                    			 header_report2_rec.contract_number||
                   				   header_report2_rec.transaction_number ||
	 			                   header_report2_rec.transaction_line_number ||
				                   header_report2_rec.accounting_date||
				                   header_report2_rec.dr_cr_flag ||
				                   header_report2_rec.accounted_amount );

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD('-', l_line_length , '-' ));

     OPEN gl_error_dst_csr(p_request_id);

     IF gl_error_dst_csr%NOTFOUND THEN
  	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,okl_accounting_util.get_message_token('OKL_LP_GL_TRANSFER','OKL_NO_RECORDS'));
     END IF;

     CLOSE gl_error_dst_csr;

  FOR gl_error_dst_rec IN gl_error_dst_csr(p_request_id) LOOP

      IF (gl_error_dst_rec.source_table='OKL_TXL_CNTRCT_LNS') THEN

       OPEN cntrct_details_csr(gl_error_dst_rec.source_id) ;
       FETCH cntrct_details_csr INTO  	l_temp_trx_number,
					l_temp_contract_number ,
					l_date_transaction_occurred,
					l_temp_line_number;
       CLOSE cntrct_details_csr;

     ELSE

      OPEN asset_details_csr(gl_error_dst_rec.source_id) ;
       FETCH asset_details_csr INTO  	l_temp_trx_number ,
					l_temp_contract_number ,
					l_date_transaction_occurred,
					l_temp_line_number;
       CLOSE asset_details_csr;

      END IF;

       IF gl_error_dst_rec.accounted_dr IS  NOT NULL  THEN
      		l_dr_cr_flag 		:= 'D';
                l_accounted_amount    := gl_error_dst_rec.accounted_dr;
        END IF;

	IF gl_error_dst_rec.accounted_cr IS  NOT NULL THEN
        	l_dr_cr_flag 		:= 'C';
                l_accounted_amount    := gl_error_dst_rec.accounted_cr;
      	END IF;

      non_proc_report_rec.transaction_date		:= GET_PROPER_LENGTH(l_date_transaction_occurred,l_transaction_date_len,'DATA');
	--PAGARG Bug 4198290 Instead of putting * substring the contract number
	--if exceeds given length
	non_proc_report_rec.contract_number 		:=
		RPAD(SUBSTR(l_temp_contract_number,1,l_contract_num_len),l_contract_num_len,' ');
	non_proc_report_rec.transaction_number		:= GET_PROPER_LENGTH(l_temp_trx_number,l_transaction_num_len,'DATA');
	non_proc_report_rec.transaction_line_number	:= GET_PROPER_LENGTH(l_temp_line_number,l_transaction_line_num_len,'DATA');
	non_proc_report_rec.accounting_date		:= GET_PROPER_LENGTH(gl_error_dst_rec.accounting_date,l_accounting_date_len,'DATA');
	non_proc_report_rec.dr_cr_flag			:= GET_PROPER_LENGTH(l_dr_cr_flag,
                                                         l_dr_cr_flag_len,'DATA');
    	non_proc_report_rec.accounted_amount		:= GET_PROPER_LENGTH(okl_Accounting_util.format_amount(l_accounted_amount,gl_error_dst_rec.currency_code),
                                                         l_accounted_amount_len,'DATA');
    --PAGARG Bug 4198290 As Account is moved to next line, no need to
    --check length, display complete data
	non_proc_report_rec.account	:= gl_error_dst_rec.account;
	non_proc_report_rec.currency        		:= GET_PROPER_LENGTH(gl_error_dst_rec.currency_code,l_currency_len,'DATA');

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,non_proc_report_rec.transaction_date ||
  					non_proc_report_rec.contract_number ||
					non_proc_report_rec.transaction_number ||
					non_proc_report_rec.transaction_line_number ||
					non_proc_report_rec.accounting_date ||
					non_proc_report_rec.dr_cr_flag ||
				        non_proc_report_rec.accounted_amount ||
					non_proc_report_rec.currency);
                --PAGARG Bug 4198290 Move account data to next line
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, header_report1_rec.account ||' : '|| non_proc_report_rec.account);

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_line_length , ' ' ));

    END LOOP;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_line_length , '-' ));

END CREATE_REPORT;


PROCEDURE OKL_GL_transfer (p_errbuf  OUT NOCOPY VARCHAR2
                          ,p_retcode  OUT NOCOPY NUMBER
                          ,p_batch_name IN VARCHAR2
                          ,p_from_date 	IN VARCHAR2
                          ,p_to_date 	IN VARCHAR2
                          ,p_validate_account IN VARCHAR2
                          ,p_gl_transfer_mode IN VARCHAR2
                          ,p_submit_journal_import IN VARCHAR2 )
IS
BEGIN
  --Stubbed out this procedure for SLA Uptake of periodic reversal concurrent program.
  FND_MESSAGE.SET_NAME( application => g_app_name ,
                        name        => 'OKL_OBS_GL_TRANSFER_PRG' );
  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
END OKL_GL_transfer;

PROCEDURE OKL_gl_transfer_con
  (p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
  ,p_batch_name IN VARCHAR2
  ,p_from_date IN DATE
  ,p_to_date IN DATE
  ,p_validate_account IN VARCHAR2
  ,p_gl_transfer_mode IN VARCHAR2
  ,p_submit_journal_import IN VARCHAR2
  ,x_request_id OUT NOCOPY NUMBER
  )
AS
  l_api_name VARCHAR2(30) := 'OKL_GL_TRANSFER_CON';
  l_api_version  NUMBER := 1.0;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_from_date     VARCHAR2(20) ;
  l_to_date       VARCHAR2(20) ;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  l_return_status := OKL_API.start_activity(l_api_name
                                           ,G_PKG_NAME
                                           ,p_init_msg_list
                                           ,l_api_version
                                           ,l_api_version
                                           ,'_PVT'
                                           ,x_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

-- Added these validations to make sure the values are passed
-- Added by Saran on 28, Jan 2002

 -- check for period name before submitting the request.
  IF (p_to_date IS NULL) OR (p_to_date = Okl_Api.G_MISS_DATE) THEN
      OKL_API.set_message('OKC', G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'To Date');
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

 -- check for validate account before submitting the request.
  IF (p_validate_account IS NULL) OR (p_validate_account = Okl_Api.G_MISS_CHAR) THEN
      OKL_API.set_message('OKC', G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Validate Account');
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;


 -- check for GL Transfer Mode before submitting the request.
  IF (p_gl_transfer_mode IS NULL) OR (p_gl_transfer_mode = Okl_Api.G_MISS_CHAR) THEN
     OKL_API.set_message('OKC', G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'GL Transfer Mode');
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;


 -- check for submit journal import before submitting the request.
  IF (p_submit_journal_import IS NULL) OR (p_submit_journal_import = Okl_Api.G_MISS_CHAR) THEN
      OKL_API.set_message('OKC', G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Submit Journal Import');
    RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_from_date  := FND_DATE.DATE_TO_CANONICAL(p_from_date);
  l_to_date    := FND_DATE.DATE_TO_CANONICAL(p_to_date);


  --call to okl gl transfer concurrent program
  FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
  x_request_id := Fnd_Request.SUBMIT_REQUEST
    (application => 'OKL'
    ,program => 'OKLGLINT'
    ,argument1 => p_batch_name
    ,argument2 => l_from_date
    ,argument3 => l_to_date
    ,argument4 => p_validate_account
    ,argument5 => p_gl_transfer_mode
    ,argument6 => p_submit_journal_import
    );


-- Added these validations to check to see if the request has been submitted successfully.
-- Added by Saran on 28, Jan 2002

    IF x_request_id = 0 THEN
       OKL_API.set_message(p_app_name => 'OFA',
                           p_msg_name => 'FA_DEPRN_TAX_ERROR',
                           p_token1   => 'REQUEST_ID',
                           p_token1_value => x_request_id);

       RAISE okl_api.g_exception_error;
    END IF;

    OKL_API.end_activity(x_msg_count, x_msg_data);

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.handle_exceptions(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
	  		        ,g_pkg_name
                                ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                ,x_msg_count
                                ,x_msg_data
                                ,'_PVT');
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

END OKL_gl_transfer_con;

END Okl_Gl_Transfer_Pvt;

/
