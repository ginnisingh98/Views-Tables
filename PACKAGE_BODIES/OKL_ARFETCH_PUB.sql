--------------------------------------------------------
--  DDL for Package Body OKL_ARFETCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ARFETCH_PUB" AS
/* $Header: OKLPARFB.pls 120.7 2006/09/21 05:08:26 abhsaxen noship $ */

-- -------------------------------------------------
-- To print log messages
-- -------------------------------------------------
PROCEDURE PRINT_TO_LOG(p_message	IN	VARCHAR2)
IS
BEGIN

 IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_FILE.PUT_LINE (FND_FILE.LOG,p_message);

       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'okl_arfetch_pub',
              p_message );

 END IF;

 okl_debug_pub.logmessage(NVL(p_message, 'NONE'));

 FND_FILE.PUT_LINE(FND_FILE.LOG,p_message);
--dbms_output.put_line(p_message);
END PRINT_TO_LOG;


PROCEDURE Get_AR_Invoice_numbers (
    	  p_api_version                  IN NUMBER,
    	  p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    	  x_return_status                OUT NOCOPY VARCHAR2,
    	  x_msg_count                    OUT NOCOPY NUMBER,
    	  x_msg_data                     OUT NOCOPY VARCHAR2)
IS


  CURSOR unfetched_invs_csr IS
  --start modified abhsaxen for performance SQLID 20562651
   SELECT
    customer_trx_id,
    to_number(interface_line_attribute10||interface_line_attribute11) lsm_id,
    xsi.id xsi_id,
    xls.tld_id tld_id,
    xls.til_id til_id,
    cnr.id cnr_id,
    lln.id lln_id,
    cnr.consolidated_invoice_number,
    sty.name sty_name,
    lsm.amount lsm_amount
   FROM ra_customer_trx_lines_all trx,
    okl_cnsld_ar_strms_b lsm,
    okl_cnsld_ar_lines_b lln,
    okl_cnsld_ar_hdrs_b cnr,
    okl_xtl_sell_invs_b xls,
    okl_ext_sell_invs_b xsi,
    okl_strm_type_v sty
   WHERE trx.line_type <> 'TAX'
    AND trx.interface_line_context = 'OKL_CONTRACTS'
    AND (trx.interface_line_attribute10||trx.interface_line_attribute11)
    = to_char(lsm.id)
    AND lln.cnr_id = cnr.id
    AND lln.id     = lsm.lln_id
    AND lsm.receivables_invoice_id = -99999
    AND xls.lsm_id = lsm.id
    AND xsi.id = xls.xsi_id_details
    AND xsi.trx_status_code = 'PROCESSED'
    AND sty.id = lsm.sty_id
    AND cnr.org_id = trx.org_id
   ;
  --end modified abhsaxen for performance SQLID 20562651

  -- --------------------------------------------
  -- Cursor to fetch due dates for an AR invoice
  -- --------------------------------------------
  CURSOR ar_due_date_csr ( p_cust_trx_id NUMBER ) IS
    SELECT due_date, trx.trx_number
  	FROM ar_payment_schedules_all ps,
         ra_customer_trx_all trx
   	WHERE ps.customer_trx_id = p_cust_trx_id
    AND trx.customer_trx_id = ps.customer_trx_id;

  -- ----------------------------------------------
  -- Cursor to fetch tax amounts for an AR invoice
  -- ----------------------------------------------
  CURSOR ar_tax_csr ( p_cust_trx_id NUMBER ) IS
    SELECT SUM(NVL( extended_amount ,0))
  	FROM ra_customer_trx_lines
   	WHERE customer_trx_id = p_cust_trx_id AND
		   LINE_TYPE = 'TAX';


  Type num_tbl is table of NUMBER index  by BINARY_INTEGER ;
  Type date_tbl is table of DATE index  by BINARY_INTEGER ;
  Type chr_tbl is table of Varchar2(2000) index  by BINARY_INTEGER ;

  customer_trx_id_tbl num_tbl;
  lsm_id_tbl    num_tbl;
  xsi_id_tbl    num_tbl;
  tld_id_tbl    num_tbl;
  til_id_tbl    num_tbl;
  cnr_id_tbl    num_tbl;
  lln_id_tbl    num_tbl;
  cons_inv      chr_tbl;
  sty_name      chr_tbl;
  due_date_tbl  date_tbl;
  trx_number_tbl chr_tbl;
  tax_amount_tbl num_tbl;
  lsm_amount_tbl num_tbl;

  L_FETCH_SIZE   NUMBER := 10000;

  -- *******************************************
  -- End Bulk Fetch changes
  -- *******************************************

   l_return_status	VARCHAR2(1) 		   := Okl_Api.G_RET_STS_SUCCESS;
   l_api_name		CONSTANT VARCHAR2(30)  := 'AR Fetcher Routine';

    -- ----------------------
    -- Std Who columns
    -- ----------------------
    lx_last_updated_by     okl_ext_sell_invs_v.last_updated_by%TYPE := Fnd_Global.USER_ID;
    lx_last_update_login   okl_ext_sell_invs_v.last_update_login%TYPE := Fnd_Global.LOGIN_ID;
    lx_request_id          okl_ext_sell_invs_v.request_id%TYPE := Fnd_Global.CONC_REQUEST_ID;

    lx_program_application_id
                okl_ext_sell_invs_v.program_application_id%TYPE := Fnd_Global.PROG_APPL_ID;
    lx_program_id  okl_ext_sell_invs_v.program_id%TYPE := Fnd_Global.CONC_PROGRAM_ID;


    bulk_errors   EXCEPTION;

    PRAGMA EXCEPTION_INIT (bulk_errors, -24381);

BEGIN

 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
   RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;

 -- ------------------------------
 -- Bulk Fetch and Bulk Updates
 -- ------------------------------


 OPEN unfetched_invs_csr;
 LOOP

      customer_trx_id_tbl.delete;
      lsm_id_tbl.delete;
      xsi_id_tbl.delete;
      tld_id_tbl.delete;
      til_id_tbl.delete;
      cnr_id_tbl.delete;
      lln_id_tbl.delete;
      cons_inv.delete;
      sty_name.delete;
      lsm_amount_tbl.delete;

 FETCH unfetched_invs_csr
    BULK COLLECT INTO   customer_trx_id_tbl,
                        lsm_id_tbl,
                        xsi_id_tbl,
                        tld_id_tbl,
                        til_id_tbl,
                        cnr_id_tbl,
                        lln_id_tbl,
                        cons_inv,
                        sty_name,
                        lsm_amount_tbl
    LIMIT L_FETCH_SIZE;

    -- ------------------------------------------------------
    -- Update Tax amounts on CNR/LLN/LSM
    -- ------------------------------------------------------

    tax_amount_tbl.delete;

    if customer_trx_id_tbl.count > 0 then
        for indx in customer_trx_id_tbl.first..customer_trx_id_tbl.last loop

            open ar_tax_csr( customer_trx_id_tbl(indx) );
            fetch ar_tax_csr into tax_amount_tbl(indx);
            close ar_tax_csr;

        end loop;

        forall indx in cnr_id_tbl.first..cnr_id_tbl.last
        save exceptions
                update okl_cnsld_ar_hdrs_b
                set amount = 0
                where id = cnr_id_tbl(indx);


        forall indx in tax_amount_tbl.first..tax_amount_tbl.last
        save exceptions
                update okl_cnsld_ar_hdrs_b
                set amount = amount + nvl(lsm_amount_tbl(indx),0) + nvl( tax_amount_tbl(indx), 0),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = cnr_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

        forall indx in tax_amount_tbl.first..tax_amount_tbl.last
        save exceptions
                update okl_cnsld_ar_lines_b
                set tax_amount = nvl(tax_amount,0)+ nvl(tax_amount_tbl(indx),0),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = lln_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

        forall indx in tax_amount_tbl.first..tax_amount_tbl.last
        save exceptions
                update okl_cnsld_ar_strms_b
                set tax_amount = nvl(tax_amount_tbl(indx),0),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = lsm_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

    end if;    -- Update Tax amounts

    commit;
    -- ------------------------------------------------------
    -- Update Due Date on CNR
    -- ------------------------------------------------------

    due_date_tbl.delete;
    trx_number_tbl.delete;


    IF customer_trx_id_tbl.COUNT > 0 THEN

       FOR indx IN customer_trx_id_tbl.FIRST..customer_trx_id_tbl.LAST LOOP

        OPEN  ar_due_date_csr ( customer_trx_id_tbl(indx) );
        FETCH ar_due_date_csr INTO due_date_tbl(indx),trx_number_tbl(indx);
        CLOSE ar_due_date_csr;

       END LOOP;

       FORALL indx in customer_trx_id_tbl.FIRST..customer_trx_id_tbl.LAST
       save exceptions
            UPDATE okl_cnsld_ar_hdrs_b
            SET due_date = due_date_tbl(indx),
                last_update_date = sysdate,
                last_updated_by = lx_last_updated_by,
                last_update_login = lx_last_update_login,
                request_id = lx_request_id,
                program_update_date = sysdate,
                program_application_id = lx_program_application_id,
                program_id = lx_program_id
            where id = cnr_id_tbl(indx);

       if sql%bulk_exceptions.count > 0 then
         for i in 1..sql%bulk_exceptions.count loop
             print_to_log('while fetching, error ' || i || ' occurred during '||
                 'iteration ' || sql%bulk_exceptions(i).error_index);
             print_to_log('oracle error is ' ||
                 sqlerrm(sql%bulk_exceptions(i).error_code));
         end loop;
       end if;

    END IF;

    commit;

    -- ------------------------------------------------------
    -- Update receivables_invoice_id in XSI,TLD,TIL and LSM
    -- ------------------------------------------------------
    IF xsi_id_tbl.COUNT > 0 THEN

        -- ------------------------------------------------------
        -- Populate customer_trx_id in tld.receivables_invoice_id
        -- ------------------------------------------------------
        FORALL indx IN xsi_id_tbl.FIRST..xsi_id_tbl.LAST
        save exceptions
                update okl_ext_sell_invs_b
                set receivables_invoice_id = customer_trx_id_tbl(indx),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = xsi_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

    END IF; -- Xsi records found

    IF tld_id_tbl.COUNT > 0 THEN

        -- ------------------------------------------------------
        -- Populate customer_trx_id in tld.receivables_invoice_id
        -- ------------------------------------------------------
        FORALL indx IN til_id_tbl.FIRST..til_id_tbl.LAST
        save exceptions
                update okl_txd_ar_ln_dtls_b
                set receivables_invoice_id = customer_trx_id_tbl(indx),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id

                where id = tld_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

    END IF; -- Tld records found


    IF til_id_tbl.COUNT > 0 THEN

        -- ------------------------------------------------------
        -- Populate customer_trx_id in til.receivables_invoice_id
        -- ------------------------------------------------------
        FORALL indx IN til_id_tbl.FIRST..til_id_tbl.LAST
        save exceptions
                update okl_txl_ar_inv_lns_b
                set receivables_invoice_id = customer_trx_id_tbl(indx),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = til_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

    END IF; -- Til records found

    IF lsm_id_tbl.COUNT > 0 THEN

        -- ------------------------------------------------------
        -- Populate customer_trx_id in lsm.receivables_invoice_id
        -- ------------------------------------------------------
        FORALL indx IN lsm_id_tbl.FIRST..lsm_id_tbl.LAST
        save exceptions
                update okl_cnsld_ar_strms_b
                set receivables_invoice_id = customer_trx_id_tbl(indx),
                    last_update_date = sysdate,
                    last_updated_by = lx_last_updated_by,
                    last_update_login = lx_last_update_login,
                    request_id = lx_request_id,
                    program_update_date = sysdate,
                    program_application_id = lx_program_application_id,
                    program_id = lx_program_id
                where id = lsm_id_tbl(indx);

        if sql%bulk_exceptions.count > 0 then
          for i in 1..sql%bulk_exceptions.count loop
              print_to_log('while fetching, error ' || i || ' occurred during '||
                  'iteration ' || sql%bulk_exceptions(i).error_index);
              print_to_log('oracle error is ' ||
                  sqlerrm(sql%bulk_exceptions(i).error_code));
          end loop;
        end if;

    END IF; -- Lsm records found

    IF customer_trx_id_tbl.count > 0 THEN
        FOR indx in customer_trx_id_tbl.FIRST..customer_trx_id_tbl.LAST LOOP
            Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Processing: Consolidated Invoice=> '||cons_inv(indx)
                                        ||' , Stream=> '||sty_name(indx)
                                        ||' ,Amount=> '||lsm_amount_tbl(indx));
            Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '    Fetching Assigned AR Invoice=> '||trx_number_tbl(indx));
            Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                  TAX Amount is => '||tax_amount_tbl(indx));
            Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                    Due Date is => '||due_date_tbl(indx));
        END LOOP;
    END IF;


 EXIT WHEN unfetched_invs_csr%NOTFOUND;
 END LOOP;
 CLOSE unfetched_invs_csr;

 COMMIT;
 x_return_status := l_return_status;


 Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

EXCEPTION
    WHEN bulk_errors THEN
	 Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'ERROR (01): '||SQLERRM);

           if sql%bulk_exceptions.count > 0 then
            for i in 1..sql%bulk_exceptions.count loop
                print_to_log('while fetching, error ' || i || ' occurred during '||
                    'iteration ' || sql%bulk_exceptions(i).error_index);
                print_to_log('oracle error is ' ||
                    sqlerrm(sql%bulk_exceptions(i).error_code));

            end loop;
           end if;

    WHEN OTHERS THEN
	 Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'ERROR (02): '||SQLERRM);
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        'Okl_Arfetch_Pub',
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END get_AR_invoice_numbers;

PROCEDURE Get_AR_Invoice_numbers_conc (
                errbuf  OUT NOCOPY VARCHAR2 ,
                retcode OUT NOCOPY NUMBER )

IS

  l_api_version   NUMBER := 1;
  lx_msg_count     NUMBER;
  l_count1          NUMBER :=0;
  l_count2          NUMBER :=0;
  l_count           NUMBER :=0;
  I                 NUMBER :=0;
  l_msg_index_out   NUMBER :=0;
  lx_msg_data    VARCHAR2(450);
  lx_return_status  VARCHAR2(1);

BEGIN

    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Starting Fetcher Program.. ');
         Okl_Arfetch_Pub.get_AR_invoice_numbers (
                p_api_version   => l_api_version,
                p_init_msg_list => Okl_Api.G_FALSE,
                x_return_status => lx_return_status,
                x_msg_count     => lx_msg_count,
                x_msg_data      => errbuf
				);
    Fnd_File.PUT_LINE (Fnd_File.LOG, 'Ending Fetcher Program.. ');
    IF lx_msg_count > 0 THEN
       FOR i IN 1..lx_msg_count LOOP
            Fnd_Msg_Pub.get (p_msg_index     => i,
                             p_encoded       => 'F',
                             p_data          => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);
    		Fnd_File.PUT_LINE (Fnd_File.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);
       END LOOP;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
END get_AR_invoice_numbers_conc;

END Okl_Arfetch_Pub;

/
