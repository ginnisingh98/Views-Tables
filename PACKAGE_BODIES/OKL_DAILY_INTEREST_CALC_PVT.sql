--------------------------------------------------------
--  DDL for Package Body OKL_DAILY_INTEREST_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DAILY_INTEREST_CALC_PVT" AS
/* $Header: OKLRDICB.pls 120.23.12010000.4 2008/09/08 09:51:45 rpillay ship $ */
  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
     --G_DEBUG         CONSTANT  NUMBER := 1;
     G_DEBUG           CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
     G_INIT_NUMBER   CONSTANT NUMBER := -9999;
     G_API_TYPE      CONSTANT VARCHAR2(4) := '_PVT';

     --Bug# 7277007
     TYPE rpt_summary_rec_type IS RECORD (
      total_receipt_amt_success   NUMBER
     ,total_receipt_amt_error     NUMBER);

     TYPE rpt_summary_tbl_type IS TABLE OF rpt_summary_rec_type INDEX BY VARCHAR2(15);

     g_rpt_summary_tbl         rpt_summary_tbl_type;
     g_rpt_summary_tbl_counter okc_k_headers_b.currency_code%TYPE;

     TYPE error_msg_tbl_type is TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

     TYPE rpt_error_rec_type IS RECORD (
       contract_number             okc_k_headers_b.contract_number%TYPE
      ,product_name                okl_products.name%TYPE
      ,interest_calc_basis         fnd_lookup_values.lookup_code%TYPE
      ,receipt_date                DATE
      ,receipt_amt                 NUMBER
      ,error_msg_tbl               error_msg_tbl_type);

     TYPE rpt_error_tbl_type IS TABLE OF rpt_error_rec_type INDEX BY BINARY_INTEGER;
     TYPE rpt_error_curr_tbl_type IS TABLE OF rpt_error_tbl_type INDEX BY VARCHAR2(15);

     g_rpt_error_curr_tbl         rpt_error_curr_tbl_type;
     g_rpt_error_curr_tbl_ctr     okc_k_headers_b.currency_code%TYPE;
     g_rpt_error_tbl_counter      NUMBER := 0;

     TYPE rpt_success_rec_type IS RECORD (
       contract_number             okc_k_headers_b.contract_number%TYPE
      ,principal_balance           NUMBER
      ,receipt_amt                 NUMBER
      ,receipt_date                DATE
      ,int_start_date              DATE
      ,int_end_date                DATE
      ,daily_int_amt               NUMBER
      ,daily_prin_amt              NUMBER
      ,int_till_date_amt           NUMBER
      ,prin_till_date_amt          NUMBER
      ,daily_int_adj_amt           NUMBER
      ,daily_prin_adj_amt          NUMBER);

     TYPE rpt_success_tbl_type IS TABLE OF rpt_success_rec_type INDEX BY BINARY_INTEGER;
     TYPE rpt_success_curr_tbl_type IS TABLE OF rpt_success_tbl_type INDEX BY VARCHAR2(15);

     g_rpt_success_curr_tbl       rpt_success_curr_tbl_type;
     g_rpt_success_curr_tbl_ctr   okc_k_headers_b.currency_code%TYPE;
     g_rpt_success_tbl_counter    NUMBER := 0;
     --Bug# 7277007

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE print_line (p_message IN VARCHAR2) IS
  BEGIN
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, p_message);
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN print_line: '||SQLERRM);
  END print_line;

  ---------------------------------------------------------------------------

  --Bug# 7277007
  ------------------------------------------------------------------------------
  -- PROCEDURE print_output
  --
  --  This procedure prints output report for Daily Interest Calculation
  --  concurrent program
  --
  -- Calls:
  -- Called By:
  ------------------------------------------------------------------------------
  PROCEDURE print_output(p_contract_number IN VARCHAR2) IS

    l_contract_number        OKC_K_HEADERS_B.contract_number%TYPE;
    l_print_contract_number  OKC_K_HEADERS_B.contract_number%TYPE;
    l_print_contract_number1 OKC_K_HEADERS_B.contract_number%TYPE;
    l_print_contract_number2 OKC_K_HEADERS_B.contract_number%TYPE;
    l_org_id                 OKC_K_HEADERS_B.authoring_org_id%TYPE;
    l_counter                NUMBER;

    CURSOR l_org_name_csr(p_org_id IN NUMBER) IS
    SELECT name
    FROM hr_all_organization_units
    WHERE organization_id = p_org_id;

    l_org_name_rec l_org_name_csr%ROWTYPE;
    l_total_receipt_amt_error   NUMBER;
    l_total_receipt_amt_success NUMBER;

    l_currency_code OKC_K_HEADERS_B.currency_code%TYPE;
  BEGIN

     l_org_id := MO_GLOBAL.get_current_org_id;
     IF (l_org_id IS NOT NULL) THEN
       OPEN l_org_name_csr(p_org_id => l_org_id);
       FETCH l_org_name_csr INTO l_org_name_rec;
       CLOSE l_org_name_csr;
     END IF;

     print_line('Daily Interest Calculation');
     print_line('****************************************************************************************************');
     print_line('Program Run Date: '||trunc(sysdate));
     print_line('Operating Unit: '||l_org_name_rec.name);
     print_line('Contract Number: '||p_contract_number);
     print_line('****************************************************************************************************');
     print_line(' ');
     print_line(' ');
     print_line('====================================================================================================');
     print_line('Summary');
     print_line(' ');
     print_line(' _____________________________________________________');
     print_line('| Receipt Application  | Currency |             Value |');
     print_line('|_____________________________________________________|');

     IF (g_rpt_summary_tbl.COUNT > 0) THEN
       g_rpt_summary_tbl_counter := g_rpt_summary_tbl.FIRST;
       LOOP

         IF (NVL(g_rpt_summary_tbl(g_rpt_summary_tbl_counter).total_receipt_amt_success,0) <> 0) THEN

           print_line('| ' || RPAD('Processed',21,' ')|| '|' ||
                       ' '|| RPAD(g_rpt_summary_tbl_counter,9,' ') || '|' ||
                       LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_summary_tbl(g_rpt_summary_tbl_counter).total_receipt_amt_success,0),g_rpt_summary_tbl_counter),18,' ') || ' |');
         END IF;

         IF (NVL(g_rpt_summary_tbl(g_rpt_summary_tbl_counter).total_receipt_amt_error,0) <> 0) THEN

           print_line('| ' || RPAD('Rejected',21,' ')|| '|' ||
                       ' '|| RPAD(g_rpt_summary_tbl_counter,9,' ') || '|' ||
                       LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_summary_tbl(g_rpt_summary_tbl_counter).total_receipt_amt_error,0),g_rpt_summary_tbl_counter),18,' ') || ' |');
         END IF;

         print_line('|_____________________________________________________|');

         EXIT WHEN   g_rpt_summary_tbl_counter = g_rpt_summary_tbl.LAST;
         g_rpt_summary_tbl_counter := g_rpt_summary_tbl.next(g_rpt_summary_tbl_counter);
       END LOOP;
     ELSE
       print_line('|_____________________________________________________|');
     END IF;
     print_line(' ');
     print_line(' ');
     print_line('====================================================================================================');

    IF (g_rpt_error_curr_tbl.COUNT > 0) THEN
      print_line('Rejected Receipt Applications');
      print_line('____________________________________________________________________________________________________');

      g_rpt_error_curr_tbl_ctr := g_rpt_error_curr_tbl.FIRST;
      LOOP

        l_total_receipt_amt_error := 0;
        FOR i IN g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr).FIRST..g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr).LAST LOOP

          l_total_receipt_amt_error := l_total_receipt_amt_error + NVL(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).receipt_amt,0);

          print_line(' ');
          print_line(RPAD('Contract Number: '||g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).contract_number,77,' ')||
                     'Product: '||g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).product_name);

          IF LENGTH(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).contract_number) > 60 THEN
            print_line(LPAD(SUBSTR(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).contract_number,61),' ',17));
          END IF;

          print_line(RPAD('Receipt Date: '||TO_CHAR(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).receipt_date,'DD-MON-RRRR'),77,' ')||
                     'Total Receipt Amount: '||OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).receipt_amt,0),g_rpt_error_curr_tbl_ctr));

          print_line(RPAD('Interest Calculation Basis: '||g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).interest_calc_basis,77,' ')||
                     'Currency: '||g_rpt_error_curr_tbl_ctr);
          print_line(' ');
          print_line('Error Description: ');

          IF (g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl.COUNT) > 0 THEN
            FOR j IN g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl.FIRST..g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl.LAST LOOP

              IF (g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl(j) IS NOT NULL) THEN
                l_counter := 1;
                WHILE l_counter <= LENGTH(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl(j))
                LOOP
                  print_line(SUBSTR(g_rpt_error_curr_tbl(g_rpt_error_curr_tbl_ctr)(i).error_msg_tbl(j),l_counter,100));
                  l_counter := l_counter + 100;
                END LOOP;
              END IF;
            END LOOP;
          END IF;

          print_line('____________________________________________________________________________________________________');

        END LOOP;

        print_line(' ');
        print_line('Total Amount Rejected '||g_rpt_error_curr_tbl_ctr||': '||OKL_ACCOUNTING_UTIL.format_amount(l_total_receipt_amt_error,g_rpt_error_curr_tbl_ctr));
        print_line(' ');
        print_line('____________________________________________________________________________________________________');

        EXIT WHEN g_rpt_error_curr_tbl_ctr = g_rpt_error_curr_tbl.LAST;
        g_rpt_error_curr_tbl_ctr := g_rpt_error_curr_tbl.next(g_rpt_error_curr_tbl_ctr);
      END LOOP;

      print_line(' ');
      print_line(' ');
      print_line('====================================================================================================');
    END IF;

    IF (g_rpt_success_curr_tbl.COUNT > 0) THEN
      print_line('Processed Receipt Applications');
      print_line(' ');
      print_line(' '|| RPAD('_',257,'_'));

      print_line('|'  || RPAD('Contract Number',40,' ') ||
                 ' |' || RPAD('Currency',15,' ') ||
                 ' |' || LPAD('Principal Balance',18,' ') ||
                 ' |' || LPAD('Receipt Amount',18,' ') ||
                 ' |' || RPAD('Receipt',11,' ') ||
                 ' |' || RPAD('Interest',11,' ') ||
                 ' |' || RPAD('Interest',11,' ') ||
                 ' |' || LPAD('Calculated Daily',18,' ') ||
                 ' |' || LPAD('Calculated',18,' ') ||
                 ' |' || LPAD('Paid Interest',18,' ') ||
                 ' |' || LPAD('Paid Principal',18,' ') ||
                 ' |' || LPAD('Interest',18,' ') ||
                 ' |' || LPAD('Principal',18,' ') ||
                 ' |');

      print_line('|'  || RPAD(' ',40,' ') ||
                 ' |' || RPAD(' ',15,' ') ||
                 ' |' || LPAD(' ',18,' ') ||
                 ' |' || LPAD(' ',18,' ') ||
                 ' |' || RPAD('Date',11,' ') ||
                 ' |' || RPAD('Start Date',11,' ') ||
                 ' |' || RPAD('End Date',11,' ') ||
                 ' |' || LPAD('Interest',18,' ') ||
                 ' |' || LPAD('Principal',18,' ') ||
                 ' |' || LPAD(' ',18,' ') ||
                 ' |' || LPAD(' ',18,' ') ||
                 ' |' || LPAD('Adjustment',18,' ') ||
                 ' |' || LPAD('Adjustment',18,' ') ||
                 ' |');

      print_line('|' || RPAD('_',257,'_') || '|');

      g_rpt_success_curr_tbl_ctr := g_rpt_success_curr_tbl.FIRST;
      LOOP

        l_total_receipt_amt_success := 0;
        FOR i IN g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr).FIRST..g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr).LAST LOOP

          l_total_receipt_amt_success := l_total_receipt_amt_success + NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).receipt_amt,0);

          IF l_contract_number IS NULL THEN
            l_contract_number       := g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).contract_number;
            l_print_contract_number := g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).contract_number;
            l_currency_code         :=  g_rpt_success_curr_tbl_ctr;

          ELSIF l_contract_number <>  g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).contract_number THEN
            print_line('|' || RPAD('_',257,'_') || '|');
            l_contract_number       := g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).contract_number;
            l_print_contract_number := g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).contract_number;
            l_currency_code         :=  g_rpt_success_curr_tbl_ctr;
          ELSE
            l_print_contract_number := ' ';
            l_currency_code         := ' ';
          END IF;

          l_print_contract_number1 := NULL;
          l_print_contract_number2 := NULL;
          IF LENGTH(l_print_contract_number) > 40 THEN
            l_print_contract_number1 := SUBSTR(l_print_contract_number,41,40);
            l_print_contract_number2 := SUBSTR(l_print_contract_number,81,40);
          END IF;

          print_line('|'  || RPAD(l_print_contract_number,40,' ') ||
                     ' |' || RPAD(l_currency_code,15,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).principal_balance,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).receipt_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || RPAD(TO_CHAR(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).receipt_date,'DD-MON-RRRR'),11,' ') ||
                     ' |' || RPAD(TO_CHAR(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).int_start_date,'DD-MON-RRRR'),11,' ') ||
                     ' |' || RPAD(TO_CHAR(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).int_end_date,'DD-MON-RRRR'),11,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).daily_int_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).daily_prin_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).int_till_date_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).prin_till_date_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).daily_int_adj_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(NVL(g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr)(i).daily_prin_adj_amt,0),g_rpt_success_curr_tbl_ctr),18,' ') ||
                     ' |');

         IF l_print_contract_number1 IS NOT NULL THEN
             print_line('|'  || RPAD(l_print_contract_number1,40,' ') ||
                       ' |' || RPAD(' ',15,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |');
          END IF;

          IF l_print_contract_number2 IS NOT NULL THEN
            print_line('|'  || RPAD(l_print_contract_number2,40,' ') ||
                       ' |' || RPAD(' ',15,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || RPAD(' ',11,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |' || LPAD(' ',18,' ') ||
                       ' |');
          END IF;

          IF (i = g_rpt_success_curr_tbl(g_rpt_success_curr_tbl_ctr).LAST) THEN
            print_line('|' || RPAD('_',257,'_') || '|');
          END IF;

        END LOOP;

        print_line('|'  || LPAD('Total',77,' ') ||
                   ' |' || LPAD(OKL_ACCOUNTING_UTIL.format_amount(l_total_receipt_amt_success,g_rpt_success_curr_tbl_ctr),18,' ') ||
                   ' |' || RPAD(' ',157,' ') ||
                   ' |');

        IF (g_rpt_success_curr_tbl_ctr = g_rpt_success_curr_tbl.LAST) THEN
          print_line('|' || RPAD('_',257,'_') || '|');
          EXIT;
        END IF;

        g_rpt_success_curr_tbl_ctr := g_rpt_success_curr_tbl.next(g_rpt_success_curr_tbl_ctr);
      END LOOP;

      print_line(' ');
      print_line(' ');
      print_line('====================================================================================================');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '** EXCEPTION IN print_output: '||SQLERRM);
  END print_output;


   ------------------------------------------------------------------------------
    -- PROCEDURE debug_message
    --
    --  This procedure prints debug message depending on DEBUG flag
    --
    -- Calls:
    -- Called By:
    ------------------------------------------------------------------------------

    PROCEDURE print_debug (p_message IN VARCHAR2) IS
    BEGIN
--      IF ( G_DEBUG = 'Y' ) THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, p_message);
        OKL_DEBUG_PUB.logmessage(p_message, 25);
        --dbms_output.put_line (p_message);
--      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.LOG, '** EXCEPTION IN print_line: '||SQLERRM);
    END print_debug;

    ------------------------------------------------------------------------------

   PROCEDURE receipt_date_range(
              p_api_version        IN  NUMBER,
              p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2,
              p_contract_id        IN  NUMBER,
              p_start_date         IN  DATE,
              p_due_date           IN  DATE,
              x_principal_balance  OUT NOCOPY NUMBER,
              x_receipt_tbl        OUT NOCOPY receipt_tbl_type)   IS

    l_api_name            CONSTANT    VARCHAR2(30) := 'RECEIPT_DATE_RANGE';
    l_api_version         CONSTANT    NUMBER       := 1.0;
    l_principal_basis     OKL_K_RATE_PARAMS.principal_basis_code%TYPE;
    l_effective_date      DATE := SYSDATE;
    l_principal_balance_tbl  principal_balance_tbl_typ ;
    l_contract_start_date DATE;
    l_start_date          DATE;
    l_counter             NUMBER := 0;
    l_receipt_tbl         receipt_tbl_type;
    l_deal_type           OKL_K_HEADERS_FULL_V.deal_type%TYPE;
    l_stream_element_date DATE;
    l_principal_balance   NUMBER;

    l_receipt_tbl_temp    receipt_tbl_type;
    l_counter_temp        NUMBER := 0;
    l_temp_receipt_date   DATE := NULL;

    Cursor contract_csr (p_contract_id NUMBER) IS
        SELECT start_date, deal_type
        FROM   okl_k_headers_full_v
        WHERE  id = p_contract_id;

-- Begin - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007
    --Bug# 6742532: Modified cursor to fetch correct receipt amount
    --              for contracts with multiple asset lines

    --Bug# 6965021: Modified cursor to fetch correct receipt amount
    --              for cases where invoices contain lines
    --              from multiple contracts

    CURSOR receipt_details_loan_csr (p_contract_id NUMBER,
                                     p_start_date  DATE,
                                     p_due_date    DATE) IS
        SELECT cra.receipt_date receipt_date
              ,SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) receipt_amount --4884843, 4872370
        FROM  okl_txd_ar_ln_dtls_b tld,
              ra_customer_trx_lines_all ractrl,
              okl_txl_ar_inv_lns_b til,
              okl_trx_ar_invoices_b tai,
              ar_payment_schedules_all aps,
              ar_receivable_applications_all raa,
              ar_cash_receipts_all cra,
              okl_strm_type_b sty_ln_pmt,
              ar_distributions_all ad
        WHERE tai.trx_status_code = 'PROCESSED'
          AND tai.khr_id = p_contract_id
          AND tld.khr_id = p_contract_id
          AND ractrl.customer_trx_id = aps.customer_trx_id
          AND raa.applied_customer_trx_id = aps.customer_trx_id
          AND aps.class = 'INV'
          AND raa.application_type IN ('CASH','CM')
          AND raa.status = 'APP'
          AND raa.display = 'Y'
          AND cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
          AND raa.cash_receipt_id = cra.cash_receipt_id
          AND tld.sty_id = sty_ln_pmt.id
          AND sty_ln_pmt.stream_type_purpose IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT', 'UNSCHEDULED_LOAN_PAYMENT', 'AMBCOC' )
          AND to_char(tld.id) = ractrl.interface_line_attribute14
          AND tld.til_id_details = til.id
          AND til.tai_id = tai.id
          AND raa.receivable_application_id = ad.source_id
          AND ad.source_table = 'RA'
          AND ad.ref_customer_trx_Line_Id = ractrl.customer_trx_line_id
          GROUP BY receipt_date
        UNION ALL
        SELECT cra.receipt_date receipt_date
              ,SUM(raa.line_applied) receipt_amount --4884843, 4872370
        FROM  okl_txd_ar_ln_dtls_b tld,
              ra_customer_trx_lines_all ractrl,
              okl_txl_ar_inv_lns_b til,
              okl_trx_ar_invoices_b tai,
              ar_payment_schedules_all aps,
              ar_receivable_applications_all raa,
              ar_cash_receipts_all cra,
              okl_strm_type_b sty_ln_pmt
        WHERE tai.trx_status_code = 'PROCESSED'
          AND tai.khr_id = p_contract_id
          AND tld.khr_id = p_contract_id
          AND ractrl.customer_trx_id = aps.customer_trx_id
          AND raa.applied_customer_trx_id = aps.customer_trx_id
          AND aps.class = 'INV'
          AND raa.application_type IN ('CASH','CM')
          AND raa.status = 'APP'
          AND raa.display = 'Y'
          AND cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
          AND raa.cash_receipt_id = cra.cash_receipt_id
          AND tld.sty_id = sty_ln_pmt.id
          AND sty_ln_pmt.stream_type_purpose IN ('LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT','UNSCHEDULED_LOAN_PAYMENT', 'AMBCOC')
          AND to_char(tld.id) = ractrl.interface_line_attribute14
          AND tld.til_id_details = til.id
          AND til.tai_id = tai.id
          AND  EXISTS (SELECT 1
                       FROM ar_distributions_all ad
                       WHERE raa.receivable_application_id = ad.source_id
                       AND ad.source_table = 'RA'
                       AND ad.source_type = 'REC'
                       AND ad.ref_customer_trx_Line_Id IS NULL)
        GROUP BY receipt_date
        ORDER BY receipt_date asc;

 Cursor receipt_details_rloan_csr (p_contract_id    NUMBER,
                                   p_start_date     DATE,
                                   p_due_date       DATE) IS
      SELECT cra.receipt_date receipt_date
             ,SUM(line_applied) receipt_amount --4884843, 4872370
      FROM   okl_txd_ar_ln_dtls_b tld,
             ra_customer_trx_lines_all ractrl,
             okl_txl_ar_inv_lns_b til,
             okl_trx_ar_invoices_b tai,
             ar_payment_schedules_all aps,
             ar_receivable_applications_all raa,
             ar_cash_receipts_all cra,
             okl_strm_type_b sty
      WHERE  tai.trx_status_code = 'PROCESSED'
        AND  tai.khr_id = p_contract_id
        AND  tld.khr_id = p_contract_id
        AND  ractrl.customer_trx_id = aps.customer_trx_id
        AND  raa.applied_customer_trx_id = aps.customer_trx_id
        AND  aps.class = 'INV'
        AND  raa.application_type IN ('CASH','CM')
        AND  raa.status = 'APP'
        AND  raa.display = 'Y'
        AND  cra.receipt_date <= NVL(p_due_date, cra.receipt_date)
        AND  raa.cash_receipt_id = cra.cash_receipt_id
        AND  tld.sty_id = sty.id
        AND  sty.stream_type_purpose in  ('UNSCHEDULED_LOAN_PAYMENT', 'VARIABLE_LOAN_PAYMENT')
        AND  to_char(tld.id) = ractrl.interface_line_attribute14
        AND  tld.til_id_details = til.id
        AND  til.tai_id = tai.id
      GROUP BY receipt_date
      ORDER BY receipt_date asc;
 -- End - Billing Inline changes - Bug#5898792 - varangan - 23/2/2007

    BEGIN
      x_return_status     := OKL_API.G_RET_STS_SUCCESS;
      l_start_date := p_start_date;

      OPEN contract_csr (p_contract_id);
      FETCH contract_csr INTO l_contract_start_date, l_deal_type;
      IF (contract_csr%NOTFOUND) THEN
         CLOSE contract_csr;
         RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;
      CLOSE contract_csr;

      l_counter := 0;
      IF (l_deal_type = 'LOAN') THEN
         -- Derive Principal Balance
         Okl_Execute_Formula_Pub.EXECUTE(p_api_version          => 1.0,
                                         p_init_msg_list        => OKL_API.G_TRUE,
                                         x_return_status        => x_return_status,
                                         x_msg_count            => x_msg_count,
                                         x_msg_data             => x_msg_data,
                                         p_formula_name         => 'CONTRACT_FINANCED_AMOUNT',
                                         p_contract_id          => p_contract_id,
                                         p_line_id              => NULL,
                                         x_value               =>  l_principal_balance
                                        );
         IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
         END IF;

         FOR current_receipt in receipt_details_loan_csr (p_contract_id, l_start_date, p_due_date)
         LOOP
            l_counter                               := l_counter + 1;
            l_receipt_tbl(l_counter).khr_id         := p_contract_id;
            l_receipt_tbl(l_counter).receipt_date   := current_receipt.receipt_date;
            l_receipt_tbl(l_counter).receipt_amount := current_receipt.receipt_amount;
         END LOOP;

         --x_receipt_tbl := l_receipt_tbl;
         -- 4957212
         x_principal_balance      := l_principal_balance;

      ELSIF (l_deal_type = 'LOAN-REVOLVING') THEN
         FOR current_receipt in receipt_details_rloan_csr (p_contract_id, l_start_date, p_due_date)
         LOOP
            l_counter                               := l_counter + 1;
            l_receipt_tbl(l_counter).khr_id         := p_contract_id;
            l_receipt_tbl(l_counter).receipt_date   := current_receipt.receipt_date;
            l_receipt_tbl(l_counter).receipt_amount := current_receipt.receipt_amount;
         END LOOP;

         --x_receipt_tbl       := l_receipt_tbl;
         -- 4957212
         x_principal_balance := NULL;
      END IF;

      FOR l_counter IN 1..l_receipt_tbl.count LOOP
        --receipt date less than khr start date
        IF (l_receipt_tbl(l_counter).receipt_date < l_contract_start_date) THEN
          IF (l_temp_receipt_date IS NOT NULL
              AND l_receipt_tbl_temp(l_counter_temp).receipt_date = l_receipt_tbl(l_counter).receipt_date) THEN
              --if a record exist in l_receipt_tbl_temp and the current record has the same date as the current
              --record in l_receipt_tbl then add the receipt amount in l_receipt_tbl to the amount in l_receipt_tbl_temp
              l_receipt_tbl_temp(l_counter_temp).receipt_amount := l_receipt_tbl_temp(l_counter_temp).receipt_amount +
                l_receipt_tbl(l_counter).receipt_amount;

          ELSE
            --create a new rec in l_receipt_tbl_temp and set the receipt date to the khr start date
            l_counter_temp := l_counter_temp + 1;
            l_receipt_tbl_temp(l_counter_temp).khr_id := l_receipt_tbl(l_counter).khr_id ;
            l_receipt_tbl_temp(l_counter_temp).receipt_date := l_contract_start_date ;
            l_receipt_tbl_temp(l_counter_temp).receipt_amount := l_receipt_tbl(l_counter).receipt_amount ;
            l_temp_receipt_date := l_receipt_tbl_temp(l_counter_temp).receipt_date;
          END IF;
        ELSE
          --transfer the from l_receipt_tbl to l_receipt_tbl_temp
          l_counter_temp := l_counter_temp + 1;
          l_receipt_tbl_temp(l_counter_temp).khr_id := l_receipt_tbl(l_counter).khr_id;
          l_receipt_tbl_temp(l_counter_temp).receipt_date := l_receipt_tbl(l_counter).receipt_date;
          l_receipt_tbl_temp(l_counter_temp).receipt_amount := l_receipt_tbl(l_counter).receipt_amount ;
          l_temp_receipt_date := l_receipt_tbl_temp(l_counter_temp).receipt_date;
        END IF;
      END LOOP;

      x_receipt_tbl       := l_receipt_tbl_temp;
      -- 4957212
      --x_principal_balance := NULL;

    EXCEPTION

       WHEN OTHERS THEN
                 Okl_Api.SET_MESSAGE(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);

    END receipt_date_range;

  ---------------------------------------------------------------------------

  PROCEDURE daily_interest(p_api_version   IN  NUMBER
    ,p_init_msg_list  IN  VARCHAR2  DEFAULT OKL_API.G_FALSE
    ,x_return_status  OUT NOCOPY VARCHAR2
    ,x_msg_count    OUT NOCOPY NUMBER
    ,x_msg_data       OUT NOCOPY VARCHAR2
    ,p_khr_id IN NUMBER DEFAULT NULL) IS

   ------------------------------------------------------------
   -- Declare Variables required by APIs
   ------------------------------------------------------------
    l_api_version CONSTANT NUMBER         := 1;
    l_api_name   CONSTANT VARCHAR2(30)   := 'DAILY_INTEREST';
    l_return_status  VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    lx_principal_balance NUMBER := 0;
    lx_receipt_tbl receipt_tbl_type;
    l_receipt_tbl_row NUMBER;
    l_prev_receipt_tbl_row NUMBER;
    l_khr_start_date DATE;
    l_range_start_date DATE;
    l_range_end_date DATE;
    l_error_flag BOOLEAN := FALSE;
    l_start_bal NUMBER := 0;
    l_cal_int_amt NUMBER := 0;
    l_daily_int_amt NUMBER := 0;
    l_daily_prin_amt NUMBER := 0;
    l_prev_daily_int_amt NUMBER := 0;
    l_prev_daily_prin_amt NUMBER := 0;
    l_payment_amount NUMBER := 0;
    l_principal_paid NUMBER := 0;
    l_excess_principal NUMBER := 0;
    l_excess_principal_paid NUMBER := 0;
    l_invoice_id NUMBER;

    --Bug# 7277007
    l_daily_int_calc_amt  NUMBER;
    l_daily_prin_calc_amt NUMBER;
    lx_msg_index_out      NUMBER;
    lx_msg_data           VARCHAR2(2000);
    l_receipt_amt_success NUMBER;
    l_receipt_amt_error   NUMBER;
    --Bug# 7277007

   --------------------------------------------------------------------
   --Declare Cursors
   --------------------------------------------------------------------
    --get contract details
    Cursor c_khr_csr(cp_khr_id IN NUMBER) IS  select khr.id khr_id
      , khr.contract_number
      , khr.start_date
      , khr.deal_type
      , khr.currency_code
      , ppm.revenue_recognition_method
      , ppm.interest_calculation_basis
      , ppm.name product_name
    from okl_k_headers_full_v khr
        ,okl_product_parameters_v ppm
    where khr.pdt_id = ppm.id
    and ppm.revenue_recognition_method = 'ACTUAL'
    and khr.id = NVL(cp_khr_id, khr.id)
    order by khr.contract_number;

    --get principal paid as of a given date
    Cursor c_principal_paid_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE) IS select nvl(sum(sel.amount), 0) principal_paid
    from okl_streams_v stm
    , okl_strm_type_v sty
    , okl_strm_elements_v sel
    where stm.khr_id = cp_khr_id
    and   stm.sty_id = sty.id
    and   sty.stream_type_purpose = 'DAILY_INTEREST_PRINCIPAL'
    and   stm.id = sel.stm_id
    and   sel.stream_element_date <= trunc(cp_from_date);

    --get excess principal paid
    Cursor c_excess_principal_paid_csr(cp_khr_id IN NUMBER) IS select nvl(sum(sel.amount), 0) excess_principal_paid
    from okl_streams_v stm
    , okl_strm_type_v sty
    , okl_strm_elements_v sel
    where stm.khr_id = cp_khr_id
    and   stm.sty_id = sty.id
    and   sty.stream_type_purpose = 'EXCESS_LOAN_PAYMENT_PAID'
    and   stm.id = sel.stm_id;

    --get asset termination value between range dates
    Cursor c_asset_term_val_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    select trunc(cbl.termination_date) term_date
         , nvl(sum(cbl.termination_value_amt), 0) term_value
    from okl_contract_balances cbl
    where cbl.khr_id = cp_khr_id
    and   cbl.termination_date between cp_from_date and cp_to_date
    group by trunc(cbl.termination_date);

    --get payments for revolving loans for receipt date range
    -- sjalasut, modified the cursor to include okl_txl_ap_inv_lns_all_b and
    -- okl_cnsld_ap_invs_all. khr_id now will be stored at the internal transaction
    -- line table and consolidated invoice id is also stored at the internal
    -- transaction lines table (okl_txl_ap_inv_lns_all_b)
    -- changes made as part of OKLR12B disbursements project
    Cursor c_borrower_payment_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE, cp_to_date IN DATE) IS
    select iph.check_date borrower_payment_date
        , sum(iph.amount) borrower_payment
    from ap_invoices_all ap_inv
       , okl_trx_ap_invoices_v okl_inv
       , ap_invoice_payment_history_v iph
       , okl_txl_ap_inv_lns_all_b okl_inv_ln
       , okl_cnsld_Ap_invs_all okl_cnsld
       , fnd_application fnd_app
    where okl_inv.id = okl_inv_ln.tap_id
       and okl_inv_ln.khr_id = cp_khr_id
       and ap_inv.application_id = fnd_app.application_id
       and fnd_app.application_short_name = 'OKL'
       and okl_inv_ln.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
       and okl_cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
       and ap_inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
       and okl_inv.funding_type_code = 'BORROWER_PAYMENT'
       and ap_inv.invoice_id = iph.invoice_id
       and iph.check_date BETWEEN cp_from_date AND NVL(cp_to_date, iph.check_date)
       group by iph.check_date;

    --get sum of payments upto a date
    -- sjalasut, modified the cursor to include okl_txl_ap_inv_lns_all_b and
    -- okl_cnsld_ap_invs_all. khr_id now will be stored at the internal transaction
    -- line table and consolidated invoice id is also stored at the internal
    -- transaction lines table (okl_txl_ap_inv_lns_all_b)
    -- changes made as part of OKLR12B disbursements project
    Cursor c_payment_amount_csr(cp_khr_id IN NUMBER, cp_from_date IN DATE) IS
    select sum(iph.amount) payment_amount
    from ap_invoices_all ap_inv
       , okl_trx_ap_invoices_v okl_inv
       , ap_invoice_payment_history_v iph
       , okl_txl_ap_inv_lns_all_b okl_inv_ln
       , okl_cnsld_Ap_invs_all okl_cnsld
       , fnd_application fnd_app
    where okl_inv.id = okl_inv_ln.tap_id
       and okl_inv_ln.khr_id = cp_khr_id
       and ap_inv.application_id = fnd_app.application_id
       and fnd_app.application_short_name = 'OKL'
       and okl_inv_ln.cnsld_ap_inv_id = okl_cnsld.cnsld_ap_inv_id
       and okl_cnsld.cnsld_ap_inv_id = to_number(ap_inv.reference_key1)
       and ap_inv.product_table = 'OKL_CNSLD_AP_INVS_ALL'
       and ap_inv.invoice_num = okl_inv.vendor_invoice_number
       and okl_inv.funding_type_code = 'BORROWER_PAYMENT'
       and ap_inv.invoice_id = iph.invoice_id
       and iph.check_date <= cp_from_date;

    --get existing daily interest streams
    Cursor c_daily_int_stm_csr(cp_khr_id IN NUMBER, cp_sty_purpose IN VARCHAR2, cp_receipt_date IN DATE) IS
    select sum(sel.amount) exist_amount
    from okl_streams_v stm
    , okl_strm_type_v sty
    , okl_strm_elements_v sel
    where stm.khr_id = cp_khr_id
    and   stm.sty_id = sty.id
    and   sty.stream_type_purpose = cp_sty_purpose
    and   stm.id = sel.stm_id
    and   sel.stream_element_date = trunc(cp_receipt_date);

     /*outputs the contents of tables passed to it*/
     PROCEDURE print_table_content(p_receipt_tbl IN receipt_tbl_type) IS
       l_rcpt_tbl_row NUMBER := 0;
       l_out_str varchar2(2000);
     BEGIN

       print_debug('*****************************************');
       print_debug('****START CONTENTS OF P_RECEIPT_TBL****');
       l_rcpt_tbl_row := p_receipt_tbl.first;
       WHILE l_rcpt_tbl_row IS NOT NULL
       LOOP
         print_debug('  khr_id : ' || p_receipt_tbl(l_rcpt_tbl_row).khr_id);
         print_debug('  kle_id : ' || p_receipt_tbl(l_rcpt_tbl_row).kle_id);
         print_debug('  receipt_date   : ' ||   p_receipt_tbl(l_rcpt_tbl_row).receipt_date);
         print_debug('  receipt_amount                       : ' ||   p_receipt_tbl(l_rcpt_tbl_row).receipt_amount);
         print_debug('  principal_pmt_rcpt_amt   : ' ||   p_receipt_tbl(l_rcpt_tbl_row).principal_pmt_rcpt_amt);
         print_debug('  loan_pmt_rcpt_amt  : ' ||   p_receipt_tbl(l_rcpt_tbl_row).loan_pmt_rcpt_amt);

         l_rcpt_tbl_row := p_receipt_tbl.next(l_rcpt_tbl_row);
       END LOOP;
       print_debug('*****END CONTENTS OF P_RECEIPT_TBL*****');
       print_debug('*****************************************');


     EXCEPTION
       WHEN OTHERS THEN
         print_debug('SQLCODE : ' || SQLCODE || ' SQLERRM : ' || SQLERRM);
     END print_table_content;

  BEGIN

    FOR cur_khr IN c_khr_csr(p_khr_id) LOOP
      l_error_flag := FALSE;
      l_receipt_amt_success := 0;
      l_receipt_amt_error := 0;

      print_debug('====================================================================');
      print_debug('Start - Daily Interest Processing for contract number => ' || cur_khr.contract_number);
      print_debug(' Contract start date => ' || cur_khr.start_date);
      print_debug(' Deal type => ' || cur_khr.deal_type);
      print_debug(' Interest calculation basis => ' || cur_khr.interest_calculation_basis);
      print_debug(' Revenue recognition method => ' || cur_khr.revenue_recognition_method);
      receipt_date_range(
                p_api_version        => l_api_version,
                p_init_msg_list      => p_init_msg_list,
                x_return_status      => l_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data,
                p_contract_id        => cur_khr.khr_id,
                p_start_date         => cur_khr.start_date,
                p_due_date           => NULL,
                x_principal_balance  => lx_principal_balance,
                x_receipt_tbl        => lx_receipt_tbl);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_error_flag := TRUE;
        print_debug(' Call to receipt_date_range failed.');
      END IF;
      --print_debug(' Starting principal balance : ' || lx_principal_balance);
      print_table_content(lx_receipt_tbl);

      l_receipt_tbl_row:= lx_receipt_tbl.first;
      l_khr_start_date := cur_khr.start_date;
      l_range_start_date := cur_khr.start_date;
      WHILE (l_receipt_tbl_row IS NOT NULL) LOOP
        IF (NOT(l_error_flag)) THEN
          IF (lx_receipt_tbl(l_receipt_tbl_row).receipt_date = l_khr_start_date) THEN
            l_prev_daily_prin_amt := 0;
            l_daily_prin_amt := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;

            FOR cur_daily_int_stm IN c_daily_int_stm_csr(cur_khr.khr_id, 'DAILY_INTEREST_PRINCIPAL', lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
              l_prev_daily_prin_amt := NVL(cur_daily_int_stm.exist_amount, 0);
            END LOOP;
            --print_debug(' Value of l_prev_daily_prin_amt: ' || l_prev_daily_prin_amt);

            --adjust against existing streams
            l_daily_prin_amt := NVL(l_daily_prin_amt, 0) - NVL(l_prev_daily_prin_amt, 0);
            --print_debug(' After adjustment value of l_daily_prin_amt: ' || l_daily_prin_amt);

            --create a principal accrual strm for entire rcpt amount
            IF (l_daily_prin_amt <> 0) THEN
              print_debug(' Creating stream for DAILY_INTEREST_PRINCIPAL.');
              OKL_VARIABLE_INTEREST_PVT.Create_Daily_Interest_Streams (
                  p_api_version    => l_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => l_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_contract_id    => cur_khr.khr_id,
                  p_amount         => l_daily_prin_amt,
                  p_due_date       => lx_receipt_tbl(l_receipt_tbl_row).receipt_date,
                  p_stream_type_purpose  => 'DAILY_INTEREST_PRINCIPAL',
                  p_create_invoice_flag  => OKL_API.G_FALSE,
                  p_process_flag         => 'DAILY_INTEREST',
                  p_currency_code        => cur_khr.currency_code);

              print_debug('Status of creating stream: ' || l_return_status);
              IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                l_error_flag := TRUE;
                print_debug(' Error: creating stream for DAILY_INTEREST_PRINCIPAL.');
              ELSE
                print_debug(' Success: creating stream for DAILY_INTEREST_PRINCIPAL.');
              END IF;
            END IF;

            --Bug# 7277007
            IF (NOT(l_error_flag)) THEN

              l_receipt_amt_success := l_receipt_amt_success + lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;

              g_rpt_success_tbl_counter := 1;
              IF g_rpt_success_curr_tbl.EXISTS(cur_khr.currency_code) THEN
                g_rpt_success_tbl_counter := g_rpt_success_curr_tbl(cur_khr.currency_code).LAST + 1;
              END IF;

              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).contract_number    := cur_khr.contract_number;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).principal_balance  := lx_principal_balance;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).receipt_amt        := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).receipt_date       := lx_receipt_tbl(l_receipt_tbl_row).receipt_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_start_date     := l_khr_start_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_end_date       := l_khr_start_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_int_amt      := 0;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_prin_amt     := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_till_date_amt  := 0;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).prin_till_date_amt := NVL(l_prev_daily_prin_amt, 0);
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_int_adj_amt  := 0;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_prin_adj_amt := l_daily_prin_amt;
            ELSE

              l_receipt_amt_error := l_receipt_amt_error + lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;

              g_rpt_error_tbl_counter := 1;
              IF g_rpt_error_curr_tbl.EXISTS(cur_khr.currency_code) THEN
                g_rpt_error_tbl_counter := g_rpt_error_curr_tbl(cur_khr.currency_code).LAST + 1;
              END IF;

              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).contract_number      := cur_khr.contract_number;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).product_name         := cur_khr.product_name;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).interest_calc_basis  := cur_khr.interest_calculation_basis;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).receipt_amt          := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).receipt_date         := lx_receipt_tbl(l_receipt_tbl_row).receipt_date;

              IF (x_msg_count >= 1) THEN
                FOR i in 1..x_msg_count LOOP
                  fnd_msg_pub.get (p_msg_index     => i,
                                   p_encoded       => 'F',
                                   p_data          => lx_msg_data,
                                   p_msg_index_out => lx_msg_index_out);

                  g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).error_msg_tbl(i) := SUBSTR(lx_msg_data,1,2000);

                END LOOP;
              END IF;
              --Bug# 7277007

            END IF;

          ELSE
            --receipt date not equal khr start date
            --obtain interest due
            l_range_end_date := lx_receipt_tbl(l_receipt_tbl_row).receipt_date - 1;
            --print_debug(' Value of l_range_start_date: ' || l_range_start_date);
            --print_debug(' Value of l_range_end_date: ' || l_range_end_date);
            l_cal_int_amt := 0;
            l_start_bal := 0;

            IF (cur_khr.deal_type = 'LOAN') THEN
              --get principal balance as of range start date
              FOR cur_principal_paid IN c_principal_paid_csr(cur_khr.khr_id, l_range_start_date) LOOP
                l_start_bal := NVL(lx_principal_balance, 0) - NVL(cur_principal_paid.principal_paid, 0);
              END LOOP; --c_principal_amt_csr
              --print_debug(' Value of l_start_bal: ' || l_start_bal);

              --get asset termination date and termination value
              FOR cur_asset_term_val IN c_asset_term_val_csr(cur_khr.khr_id, l_range_start_date, l_range_end_date) LOOP
                l_cal_int_amt := l_cal_int_amt + OKL_VARIABLE_INTEREST_PVT.calculate_interest (
                  p_api_version    => l_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => l_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_contract_id    => cur_khr.khr_id,
                  p_from_date      => l_range_start_date,
                  p_to_date        =>  cur_asset_term_val.term_date -1,
                  p_principal_amount =>  l_start_bal,
                  p_currency_code    =>  cur_khr.currency_code);

                  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                    l_error_flag := TRUE;
                  END IF;
                  --print_debug(' Value of l_cal_int_amt: ' || l_cal_int_amt);

                  --print_debug('Asset term value: ' || cur_asset_term_val.term_value);
                  --print_debug('Asset term date: ' || cur_asset_term_val.term_date);
                  l_range_start_date := cur_asset_term_val.term_date;
                  l_start_bal := NVL(l_start_bal, 0) - NVL(cur_asset_term_val.term_value, 0);
                  --print_debug(' Value of l_start_bal: ' || l_start_bal);
             END LOOP; --c_asset_term_val_csr

               l_cal_int_amt := l_cal_int_amt + OKL_VARIABLE_INTEREST_PVT.calculate_interest (
               p_api_version    => l_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => l_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_contract_id    => cur_khr.khr_id,
               p_from_date      => l_range_start_date,
               p_to_date        =>  l_range_end_date,
               p_principal_amount =>  l_start_bal,
               p_currency_code    =>  cur_khr.currency_code);

               IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 l_error_flag := TRUE;
               END IF;
               --print_debug(' Value of l_cal_int_amt: ' || l_cal_int_amt);
             ELSE --deal type = Rev Loan
               FOR cur_borrower_payment IN c_borrower_payment_csr(cur_khr.khr_id, l_range_start_date, l_range_end_date) LOOP
                --get payments maid upto the range start date
                 FOR cur_payment_amount IN c_payment_amount_csr(cur_khr.khr_id, l_range_start_date) LOOP
                   l_payment_amount := NVL(cur_payment_amount.payment_amount, 0);
                 END LOOP;
                 --print_debug(' Value of l_payment_amount: ' || l_payment_amount);

                 --get principal paid
                 FOR cur_principal_paid IN c_principal_paid_csr(cur_khr.khr_id, l_range_start_date) LOOP
                   l_principal_paid := NVL(cur_principal_paid.principal_paid, 0);
                 END LOOP;
                 --print_debug(' Value of l_principal_paid: ' || l_principal_paid);

                 l_start_bal := NVL(l_payment_amount, 0) - NVL(l_principal_paid, 0);
                 --print_debug(' Value of l_start_bal: ' || l_start_bal);

                 l_cal_int_amt := l_cal_int_amt + OKL_VARIABLE_INTEREST_PVT.calculate_interest (
                 p_api_version    => l_api_version,
                 p_init_msg_list  => p_init_msg_list,
                 x_return_status  => l_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_contract_id    => cur_khr.khr_id,
                 p_from_date      => l_range_start_date,
                 p_to_date        =>  cur_borrower_payment.borrower_payment_date -1,
                 p_principal_amount =>  l_start_bal,
                 p_currency_code    =>  cur_khr.currency_code);

                 --print_debug(' Value of l_cal_int_amt: ' || l_cal_int_amt);
                 IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                   l_error_flag := TRUE;
                 END IF;

                 l_range_start_date := cur_borrower_payment.borrower_payment_date;
               END LOOP;

               --get payments maid upto the range start date
               FOR cur_payment_amount IN c_payment_amount_csr(cur_khr.khr_id, l_range_start_date) LOOP
                 l_payment_amount := NVL(cur_payment_amount.payment_amount, 0);
               END LOOP;
               --print_debug(' Value of l_payment_amount: ' || l_payment_amount);

               --get principal paid
               FOR cur_principal_paid IN c_principal_paid_csr(cur_khr.khr_id, l_range_start_date) LOOP
                 l_principal_paid := NVL(cur_principal_paid.principal_paid, 0);
               END LOOP;
               --print_debug(' Value of l_principal_paid: ' || l_principal_paid);

               l_start_bal := NVL(l_payment_amount, 0) - NVL(l_principal_paid, 0);
               --print_debug(' Value of l_start_bal: ' || l_start_bal);

               l_cal_int_amt := l_cal_int_amt + OKL_VARIABLE_INTEREST_PVT.calculate_interest (
               p_api_version    => l_api_version,
               p_init_msg_list  => p_init_msg_list,
               x_return_status  => l_return_status,
               x_msg_count      => x_msg_count,
               x_msg_data       => x_msg_data,
               p_contract_id    => cur_khr.khr_id,
               p_from_date      => l_range_start_date,
               p_to_date        =>  l_range_end_date,
               p_principal_amount =>  l_start_bal,
               p_currency_code    =>  cur_khr.currency_code);

               --print_debug(' Value of l_cal_int_amt: ' || l_cal_int_amt);

               IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 l_error_flag := TRUE;
               END IF;
             END IF;

             --split into daily interest and principal
             l_daily_int_amt := 0;
             l_daily_prin_amt := 0;

             --Bug# 7277007
             l_daily_int_calc_amt := 0;
             l_daily_prin_calc_amt := 0;

             IF (lx_receipt_tbl(l_receipt_tbl_row).receipt_amount > l_cal_int_amt) THEN
               l_daily_int_amt := NVL(l_cal_int_amt, 0);
               l_daily_prin_amt := NVL(lx_receipt_tbl(l_receipt_tbl_row).receipt_amount, 0) - NVL(l_daily_int_amt, 0);
             ELSE
               l_daily_int_amt := NVL(lx_receipt_tbl(l_receipt_tbl_row).receipt_amount, 0);
             END IF;
             --print_debug(' Value of l_daily_int_amt: ' || l_daily_int_amt);
             --print_debug(' Value of l_daily_prin_amt: ' || l_daily_prin_amt);

             --Bug# 7277007
             l_daily_int_calc_amt := l_daily_int_amt;
             l_daily_prin_calc_amt := l_daily_prin_amt;

             --check for existing daily interest streams
             l_prev_daily_int_amt := 0;
             l_prev_daily_prin_amt := 0;
             FOR cur_daily_int_stm IN c_daily_int_stm_csr(cur_khr.khr_id, 'DAILY_INTEREST_INTEREST', lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
               l_prev_daily_int_amt := NVL(cur_daily_int_stm.exist_amount, 0);
             END LOOP;

             FOR cur_daily_int_stm IN c_daily_int_stm_csr(cur_khr.khr_id, 'DAILY_INTEREST_PRINCIPAL', lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
               l_prev_daily_prin_amt := NVL(cur_daily_int_stm.exist_amount, 0);
             END LOOP;
             --print_debug(' Value of l_prev_daily_int_amt: ' || l_prev_daily_int_amt);
             --print_debug(' Value of l_prev_daily_prin_amt: ' || l_prev_daily_prin_amt);

             --adjust against existing streams
             l_daily_int_amt := NVL(l_daily_int_amt, 0) - NVL(l_prev_daily_int_amt, 0);
             l_daily_prin_amt := NVL(l_daily_prin_amt, 0) - NVL(l_prev_daily_prin_amt, 0);
             --print_debug(' After adjustment value of l_daily_int_amt: ' || l_daily_int_amt);
             --print_debug(' After adjustment value of l_daily_prin_amt: ' || l_daily_prin_amt);

             --create daily interest streams
             IF (l_daily_int_amt <> 0) AND (NOT(l_error_flag)) THEN
               print_debug(' Creating stream for DAILY_INTEREST_INTEREST.');

               OKL_VARIABLE_INTEREST_PVT.Create_Daily_Interest_Streams (
                 p_api_version    => l_api_version,
                 p_init_msg_list  => p_init_msg_list,
                 x_return_status  => l_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_contract_id    => cur_khr.khr_id,
                 p_amount         => l_daily_int_amt,
                 p_due_date       => lx_receipt_tbl(l_receipt_tbl_row).receipt_date,
                 p_stream_type_purpose  => 'DAILY_INTEREST_INTEREST',
                 p_create_invoice_flag  => OKL_API.G_FALSE,
                 p_process_flag         => 'DAILY_INTEREST',
                 p_currency_code        => cur_khr.currency_code);

             print_debug('Status of creating stream: ' || l_return_status);

             IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
               l_error_flag := TRUE;
               print_debug(' Error: creating stream for DAILY_INTEREST_INTEREST.');
             ELSE
               print_debug(' Success: creating stream for DAILY_INTEREST_INTEREST.');
             END IF;
           END IF;

           IF (l_daily_prin_amt <> 0) AND (NOT(l_error_flag)) THEN

             --check for excess payments
             l_excess_principal := 0;
             IF (cur_khr.deal_type = 'LOAN') THEN
               --check for excess loan payment for LOAN
               FOR cur_principal_paid IN c_principal_paid_csr(cur_khr.khr_id, lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
                 l_excess_principal := (NVL(cur_principal_paid.principal_paid, 0) + NVL(l_daily_prin_amt, 0)) - NVL(lx_principal_balance, 0);
               END LOOP;

             ELSE
               --check for excess loan payment for REV-LOAN
               FOR  cur_payment_amount IN c_payment_amount_csr(cur_khr.khr_id, lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
                 FOR cur_principal_paid IN c_principal_paid_csr(cur_khr.khr_id, lx_receipt_tbl(l_receipt_tbl_row).receipt_date) LOOP
                   l_excess_principal := (NVL(cur_principal_paid.principal_paid, 0) + NVL(l_daily_prin_amt, 0)) - NVL(cur_payment_amount.payment_amount, 0);
                 END LOOP;
               END LOOP;
             END IF;

             IF (l_excess_principal <= 0) AND (NOT(l_error_flag)) THEN
               l_excess_principal := 0;
             ELSE
               --principal is in excess
               --print_debug(' Value of l_excess_principal: ' || l_excess_principal);
               l_daily_prin_amt := NVL(l_daily_prin_amt, 0) - NVL(l_excess_principal, 0);
             END IF;

             print_debug(' Creating stream for DAILY_INTEREST_PRINCIPAL.');

             OKL_VARIABLE_INTEREST_PVT.Create_Daily_Interest_Streams (
                 p_api_version    => l_api_version,
                 p_init_msg_list  => p_init_msg_list,
                 x_return_status  => l_return_status,
                 x_msg_count      => x_msg_count,
                 x_msg_data       => x_msg_data,
                 p_contract_id    => cur_khr.khr_id,
                 p_amount         => l_daily_prin_amt,
                 p_due_date       => lx_receipt_tbl(l_receipt_tbl_row).receipt_date,
                 p_stream_type_purpose  => 'DAILY_INTEREST_PRINCIPAL',
                 p_create_invoice_flag  => OKL_API.G_FALSE,
                 p_process_flag         => 'DAILY_INTEREST',
                 p_currency_code        => cur_khr.currency_code);

             print_debug('Status of creating stream: ' || l_return_status);

             IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
               l_error_flag := TRUE;
               print_debug(' Error: creating stream for DAILY_INTEREST_PRINCIPAL.');
             ELSE
               print_debug(' Success: creating stream for DAILY_INTEREST_PRINCIPAL.');
             END IF;

             --check for excess principal paid
             l_excess_principal_paid := 0;
             FOR cur_excess_principal_paid IN c_excess_principal_paid_csr(cur_khr.khr_id) LOOP
               /*l_excess_principal_paid := NVL(cur_excess_principal_paid.excess_principal_paid, 0);
               print_debug(' Value of l_excess_principal_paid: ' || l_excess_principal_paid);
               l_excess_principal := NVL(l_excess_principal, 0) - NVL(l_excess_principal_paid, 0);*/
               null;
             END LOOP;

             IF (l_excess_principal <> 0) AND (NOT(l_error_flag)) THEN

               --create stream for excess loan payment
               print_debug(' Creating stream for EXCESS_LOAN_PAYMENT_PAID.');

               OKL_VARIABLE_INTEREST_PVT.Create_Daily_Interest_Streams (
                   p_api_version    => l_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => l_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_contract_id    => cur_khr.khr_id,
                   p_amount         => l_excess_principal,
                   p_due_date       => lx_receipt_tbl(l_receipt_tbl_row).receipt_date,
                   p_stream_type_purpose  => 'EXCESS_LOAN_PAYMENT_PAID',
                   p_create_invoice_flag  => OKL_API.G_FALSE,
                   p_process_flag         => 'DAILY_INTEREST',
                   p_currency_code        => cur_khr.currency_code);

               print_debug('Status of creating stream: ' || l_return_status);

               IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                 l_error_flag := TRUE;
                 print_debug(' Error: creating stream for EXCESS_LOAN_PAYMENT_PAID.');
               ELSE
                 print_debug(' Success: creating stream for EXCESS_LOAN_PAYMENT_PAID.');
               END IF;
             END IF;
           END IF;

           --Bug# 7277007
           IF (NOT(l_error_flag)) THEN

              l_receipt_amt_success := l_receipt_amt_success + lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;

              g_rpt_success_tbl_counter := 1;
              IF g_rpt_success_curr_tbl.EXISTS(cur_khr.currency_code) THEN
                g_rpt_success_tbl_counter := g_rpt_success_curr_tbl(cur_khr.currency_code).LAST + 1;
              END IF;

              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).contract_number    := cur_khr.contract_number;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).principal_balance  := l_start_bal;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).receipt_amt        := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).receipt_date       := lx_receipt_tbl(l_receipt_tbl_row).receipt_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_start_date     := l_range_start_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_end_date       := l_range_end_date;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_int_amt      := l_daily_int_calc_amt;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_prin_amt     := l_daily_prin_calc_amt;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).int_till_date_amt  := l_prev_daily_int_amt;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).prin_till_date_amt := l_prev_daily_prin_amt;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_int_adj_amt  := l_daily_int_amt;
              g_rpt_success_curr_tbl(cur_khr.currency_code)(g_rpt_success_tbl_counter).daily_prin_adj_amt := l_daily_prin_amt;
            ELSE

              l_receipt_amt_error := l_receipt_amt_error + lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;

              g_rpt_error_tbl_counter := 1;
              IF g_rpt_error_curr_tbl.EXISTS(cur_khr.currency_code) THEN
                g_rpt_error_tbl_counter := g_rpt_error_curr_tbl(cur_khr.currency_code).LAST + 1;
              END IF;

              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).contract_number      := cur_khr.contract_number;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).product_name         := cur_khr.product_name;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).interest_calc_basis  := cur_khr.interest_calculation_basis;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).receipt_amt          := lx_receipt_tbl(l_receipt_tbl_row).receipt_amount;
              g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).receipt_date         := lx_receipt_tbl(l_receipt_tbl_row).receipt_date;

              IF (x_msg_count >= 1) THEN
                FOR i in 1..x_msg_count LOOP
                  fnd_msg_pub.get (p_msg_index     => i,
                                   p_encoded       => 'F',
                                   p_data          => lx_msg_data,
                                   p_msg_index_out => lx_msg_index_out);

                  g_rpt_error_curr_tbl(cur_khr.currency_code)(g_rpt_error_tbl_counter).error_msg_tbl(i) := SUBSTR(lx_msg_data,1,2000);

                END LOOP;
              END IF;
           END IF;
           --Bug# 7277007

         END IF;
       END IF;

       --if rcpt unapp results in a zero DI-Principal strm elem, then the int calculation
       --must start from the previous start date
       IF ((l_daily_prin_amt + l_prev_daily_prin_amt) <> 0) THEN
         l_range_start_date := lx_receipt_tbl(l_receipt_tbl_row).receipt_date;
       END IF;
       l_receipt_tbl_row:= lx_receipt_tbl.next(l_receipt_tbl_row);
     END LOOP; --lx_receipt_tbl

     --Bug# 7277007
     IF g_rpt_summary_tbl.EXISTS(cur_khr.currency_code)
     THEN
       g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_success :=
         g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_success + l_receipt_amt_success;

       g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_error :=
         g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_error + l_receipt_amt_error;

     ELSE
       g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_success := l_receipt_amt_success;
       g_rpt_summary_tbl(cur_khr.currency_code).total_receipt_amt_error   := l_receipt_amt_error;

     END IF;
     --Bug# 7277007

     IF (l_error_flag) THEN
       print_debug('ERROR - Daily Interest Processing for contract number => ' || cur_khr.contract_number);
     END IF;
       print_debug('====================================================================');
       print_debug('End - Daily Interest Processing for contract number => ' || cur_khr.contract_number);
    END LOOP; --c_khr_csr

  EXCEPTION
    ------------------------------------------------------------
    -- Exception handling
    ------------------------------------------------------------

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

    WHEN OTHERS THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS (
          p_api_name  => l_api_name,
          p_pkg_name  => G_PKG_NAME,
          p_exc_name  => 'OTHERS',
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data,
          p_api_type  => '_PVT');

  END daily_interest;

  --dkagrawa created for concurrent program OKL Daily Interest Calculation
  PROCEDURE calculate_daily_interest(
     errbuf            OUT NOCOPY VARCHAR2,
     retcode           OUT NOCOPY NUMBER,
     p_contract_number IN VARCHAR2
    ) IS
    l_api_version CONSTANT NUMBER DEFAULT 1.0;

    lx_msg_count           NUMBER;
    lx_msg_data            VARCHAR2(450);
    l_msg_index_out        NUMBER;
    lx_return_status       VARCHAR(1);
    l_khr_id               NUMBER DEFAULT NULL;
    l_contract_number      okc_k_headers_b.contract_number%type;
    --dkagrawa changed the cursor to use new view okl_prod_qlty_val_uv for product quality value instead of product_parameter_v
    CURSOR check_contract_csr(cp_contract_number IN VARCHAR2) IS
    SELECT khr.id khr_id
          ,khr.contract_number
          ,khr.authoring_org_id
    FROM   okl_k_headers_full_v khr,
           okl_prod_qlty_val_uv ppm,
           okc_statuses_b ste
    WHERE  khr.contract_number = NVL(cp_contract_number, khr.contract_number)
    AND    khr.pdt_id = ppm.pdt_id
    AND    ppm.quality_name = 'REVENUE_RECOGNITION_METHOD'
    AND    ppm.quality_val = 'ACTUAL'
    AND    khr.sts_code = ste.code
    AND    ste.ste_code in ('ACTIVE', 'TERMINATED');

  BEGIN

    --set variable rate global variables so that interest calculation
    --and interest rate parameter updates works correctly
    OKL_VARIABLE_INTEREST_PVT.G_CALC_METHOD_CODE := 'DAILY_INTEREST';
    OKL_VARIABLE_INTEREST_PVT.G_INTEREST_CALCULATION_BASIS := 'DAILY_INTEREST';
    OKL_VARIABLE_INTEREST_PVT.G_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    OPEN check_contract_csr(p_contract_number);
    LOOP
      FETCH check_contract_csr INTO l_khr_id, l_contract_number, OKL_VARIABLE_INTEREST_PVT.G_AUTHORING_ORG_ID;

      IF (check_contract_csr%NOTFOUND) THEN
        CLOSE check_contract_csr;
        EXIT;
      END IF;

      daily_interest(
                   p_api_version    => l_api_version,
                   p_init_msg_list  => FND_API.G_FALSE,
                   x_return_status  => lx_return_status,
                   x_msg_count      => lx_msg_count,
                   x_msg_data       => lx_msg_data,
                   p_khr_id         => l_khr_id
                  );
      IF lx_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF lx_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END LOOP;

    OKL_VARIABLE_INTEREST_PVT.G_CALC_METHOD_CODE := NULL;
    OKL_VARIABLE_INTEREST_PVT.G_INTEREST_CALCULATION_BASIS := NULL;
    OKL_VARIABLE_INTEREST_PVT.G_REQUEST_ID := NULL;

    errbuf := lx_msg_data;

    --Bug# 7277007
    print_output(p_contract_number => p_contract_number);

    retcode := 0;
  EXCEPTION
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      retcode := 2;
      IF check_contract_csr%ISOPEN THEN
        CLOSE check_contract_csr;
      END IF;
      lx_return_status := Okl_Api.HANDLE_EXCEPTIONS(G_APP_NAME,
                                                  G_PKG_NAME,
                                                 'Okl_Api.G_RET_STS_ERROR',
                                                  lx_msg_count,
                                                  lx_msg_data,
                                                  '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      retcode := 2;
      IF check_contract_csr%ISOPEN THEN
         CLOSE check_contract_csr;
      END IF;
      lx_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => G_APP_NAME,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => lx_msg_count,
                           x_msg_data  => lx_msg_data,
                           p_api_type  => '_PVT');
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := SQLERRM;
      IF check_contract_csr%ISOPEN THEN
        CLOSE check_contract_csr;
      END IF;
      FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||SQLCODE||': '||SQLERRM);
  END calculate_daily_interest;

END OKL_DAILY_INTEREST_CALC_PVT;

/
