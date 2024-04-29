--------------------------------------------------------
--  DDL for Package Body OKL_BILLING_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILLING_UTIL_PVT" AS
/* $Header: OKLRBULB.pls 120.9.12010000.3 2009/12/10 11:37:51 rpillay ship $ */
 --Start of wrapper code generated automatically by Debug Code Generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
 --End of wrapper code generated automatically by Debug code generator

 ------------------------------------------------------------------------------

-- **** Authoring requirement APIs ****
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : LAST_INVOICE_DATE
-- Description     : api to return last(max) invoice date for a contract
-- Business Rules  :
-- Parameters      :
--                 p_contract_id - Contract ID
--
--                 x_invoice_date - Last invoice date
--
-- Version         : 1.0
-- End of comments
-------------------------------------------------------------------------------
--Comments:
--1. need to tune the sql for the cursor, gives full scan for ra_customer_trx_lines_all

 PROCEDURE Last_Invoice_Date(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_contract_id                  IN  NUMBER
   ,x_invoice_date                 OUT NOCOPY DATE
 )
 IS

  -- Cursor to obtain the last invoice date for a contract
   CURSOR c_last_invoice_date(p_contract_id IN NUMBER) IS
   SELECT max(ractrx.trx_date)
   FROM ra_customer_trx_all ractrx
   WHERE EXISTS (
               SELECT 'x'
               FROM ra_customer_trx_lines_all ractrl
               WHERE ractrl.customer_trx_id = ractrx.customer_trx_id
               AND ractrl.interface_line_attribute6 = (SELECT contract_number
                                                       FROM okc_k_headers_b
                                                       WHERE ID = p_contract_id)
               );
   l_invoice_date DATE;
   l_api_name     VARCHAR2(60) := 'Last Invoice Date';
 BEGIN
   OPEN c_last_invoice_date(p_contract_id);
   FETCH c_last_invoice_date INTO l_invoice_date;
   CLOSE c_last_invoice_date;

   x_invoice_date := l_invoice_date;
   x_return_status := 'S';
 EXCEPTION
     WHEN OTHERS THEN
                IF c_last_invoice_date%ISOPEN THEN
                   CLOSE c_last_invoice_date;
                END IF;

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

 END Last_Invoice_Date;



-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : INVOICE_AMOUNT_FOR_STREAM
-- Description     : api to return all the the total invoice line amount for
-- stream type purpose = p_stream_purpose ('UNSCHEDULED_PRINCIPAL_PAYMENT') for
-- each contract.
-- Select khr_id, sum(line_amount) group by khr_id where OKL invoice
-- and stream type purpose matches with invice line context field.
-- Business Rules  :
-- Parameters      :
--                 p_stream_purpose - Stream type purpose
--
--                 x_contract_invoice_tbl         - table containing contract_id
--                 and invoice amount
--
-- Version         : 1.0
-- End of comments
-------------------------------------------------------------------------------
-- Comments:
--
 PROCEDURE INVOICE_AMOUNT_FOR_STREAM(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_stream_purpose               IN  VARCHAR2
   ,x_contract_invoice_tbl         OUT NOCOPY contract_invoice_tbl
 )
 IS
   CURSOR c_strm_invoice_amt(p_stream_purpose IN VARCHAR2) IS
   SELECT chr.id,
          SUM(ractrl.amount_due_original) amount
   FROM ra_customer_trx_lines_all ractrl,
        okc_k_headers_b chr
   WHERE chr.contract_number = ractrl.interface_line_attribute6
   AND EXISTS(SELECT sty.code
              FROM OKL_STRM_TYPE_B sty
              WHERE sty.stream_type_purpose = p_stream_purpose
              AND sty.code = ractrl.interface_line_attribute9)
   GROUP BY chr.id;

   l_api_name              VARCHAR2(60) := 'Invoice Amount for Stream';
   l_contract_invoice_tbl  contract_invoice_tbl;
   i                       NUMBER;
 BEGIN
 i := 1;
    --Loop through the cursor
      FOR l_invoice_amt_rec IN c_strm_invoice_amt(p_stream_purpose) LOOP
         l_contract_invoice_tbl(i).khr_id := l_invoice_amt_rec.id;
         l_contract_invoice_tbl(i).amount := l_invoice_amt_rec.amount;
         i := i + 1;
      END LOOP;

      x_contract_invoice_tbl := l_contract_invoice_tbl;
      x_return_status := 'S';
 EXCEPTION
    WHEN OTHERS THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

 END Invoice_Amount_For_Stream;


FUNCTION INVOICE_LINE_AMOUNT_ORIG(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR invoice_line_tax_amount(p_line_id NUMBER) IS
  SELECT SUM(NVL(EXTENDED_AMOUNT, 0)) LINE_TAX_AMOUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  LINK_TO_CUST_TRX_LINE_ID = p_line_id;

l_line_amount NUMBER;
l_line_tax_amount NUMBER;
l_line_original_due NUMBER;

BEGIN

  --Bug# 7720775
  l_line_amount := INV_LN_AMT_ORIG_WOTAX(p_customer_trx_id,
                                         p_customer_trx_line_id);

  FOR r IN invoice_line_tax_amount(p_customer_trx_line_id)
  LOOP
    l_line_tax_amount := r.LINE_TAX_AMOUNT;
  END LOOP;

  l_line_original_due := NVL(NVL(l_line_amount,0) + NVL(l_line_tax_amount,0),0);
  return (l_line_original_due);
END;
--asawanka modified for bug # 6497335 start
FUNCTION INVOICE_LINE_AMOUNT_APPLIED(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR tax_applied_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) tax_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad,
             ra_customer_trx_lines_all lines
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   IN ('INV','CM') --Receipt can be applied against credit memo
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CASH'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
      AND    lines.link_to_cust_trx_line_id = p_line_id
      AND    lines.line_type = 'TAX';

l_line_amount_applied NUMBER;
l_tax_amount_applied NUMBER;

--Bug# 9116332
CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_line_count NUMBER;
l_amount_applied NUMBER;
--Bug# 9116332

BEGIN

  --Bug# 9116332
  FOR r IN line_count_csr(p_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    --Bug# 7720775
    l_line_amount_applied := INV_LN_AMT_APPLIED_WOTAX(p_customer_trx_id,
                                                      p_customer_trx_line_id);

    FOR r in tax_applied_csr(p_customer_trx_id, p_customer_trx_line_id)
    LOOP
      l_tax_amount_applied := r.tax_applied;
    END LOOP;

    l_amount_applied := nvl(l_line_amount_applied,0) + NVL(l_tax_amount_applied,0);

  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_applied := invoice_amount_applied(p_customer_trx_id);

  END IF;
  --Bug# 9116332

  RETURN(l_amount_applied);
END;

FUNCTION INVOICE_LINE_AMOUNT_CREDITED(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR tax_credited_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) credit_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad,
             ra_customer_trx_lines_all lines
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   = 'INV'
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CM'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
      AND    lines.link_to_cust_trx_line_id = p_line_id
      AND    lines.line_type = 'TAX';

l_line_amount_credited NUMBER;
l_tax_amount_credited NUMBER;

--Bug# 9116332
CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_line_count NUMBER;
l_amount_credited NUMBER;
--Bug# 9116332

BEGIN

  --Bug# 9116332
  FOR r IN line_count_csr(p_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice

    --Bug# 7720775
    l_line_amount_credited := INV_LN_AMT_CREDITED_WOTAX(
                                       p_customer_trx_id,
                                       p_customer_trx_line_id);

    FOR r in tax_credited_csr(p_customer_trx_id, p_customer_trx_line_id)
    LOOP
      l_tax_amount_credited := r.credit_applied;
    END LOOP;

    l_amount_credited := nvl(l_line_amount_credited,0) + NVL(l_tax_amount_credited,0);

  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_credited := invoice_amount_credited(p_customer_trx_id);

  END IF;
  --Bug# 9116332

  RETURN(l_amount_credited);
END;
--asawanka modified for bug # 6497335 end
FUNCTION INVOICE_LINE_AMOUNT_REMAINING(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
l_invoice_line_amount_orig NUMBER;
l_invoice_line_amount_applied NUMBER;
l_invoice_line_amount_credited NUMBER;
l_invoice_line_amt_remaining NUMBER;
l_invoice_line_amount_adjusted  NUMBER;
BEGIN
  l_invoice_line_amount_orig := INVOICE_LINE_AMOUNT_ORIG(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_applied := INVOICE_LINE_AMOUNT_APPLIED(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_credited := INVOICE_LINE_AMOUNT_CREDITED(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_adjusted := INVOICE_LINE_AMOUNT_ADJUSTED(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amt_remaining := NVL(l_invoice_line_amount_orig -l_invoice_line_amount_applied - l_invoice_line_amount_credited + l_invoice_line_amount_adjusted, 0);

  RETURN (l_invoice_line_amt_remaining);
END;

FUNCTION INVOICE_AMOUNT_ORIG(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_amount_orig_csr(p_header_id NUMBER) IS
SELECT SUM(NVL(APS.AMOUNT_DUE_ORIGINAL,0)) AMOUNT_DUE_ORIGINAL
FROM   AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUSTOMER_TRX_ALL RACTRX
WHERE  RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
AND    RACTRX.CUSTOMER_TRX_ID = p_header_id;
l_invoice_amount_orig NUMBER;
BEGIN
  FOR R IN invoice_amount_orig_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_orig := r.AMOUNT_DUE_ORIGINAL;
  END LOOP;
  RETURN (l_invoice_amount_orig);
END;

FUNCTION INVOICE_AMOUNT_APPLIED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
--dkagrawa modified the cusrsor to add class CM
CURSOR invoice_amount_applied_csr(p_header_id NUMBER) IS
      SELECT NVL(SUM(app.amount_applied),0) AMOUNT_APPLIED
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   IN ('INV','CM') --Receipt can be applied against credit memo
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CASH';
l_invoice_amount_applied NUMBER;
BEGIN
  FOR R IN invoice_amount_applied_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_applied := r.AMOUNT_APPLIED;
  END LOOP;
  RETURN (l_invoice_amount_applied);
END;

FUNCTION INVOICE_AMOUNT_CREDITED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_amount_credited_csr(p_header_id NUMBER) IS
      SELECT NVL(SUM(app.amount_applied),0) AMOUNT_CREDITED
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   = 'INV'
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CM';
l_invoice_amount_credited NUMBER;
BEGIN
  FOR R IN invoice_amount_credited_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_credited := r.AMOUNT_CREDITED;
  END LOOP;
  RETURN (l_invoice_amount_credited);
END;

FUNCTION INVOICE_AMOUNT_REMAINING(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_amount_remaining_csr(p_header_id NUMBER) IS
SELECT SUM(NVL(APS.AMOUNT_DUE_REMAINING,0)) AMOUNT_DUE_REMAINING
FROM   AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUSTOMER_TRX_ALL RACTRX
WHERE  RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
AND    RACTRX.CUSTOMER_TRX_ID = p_header_id;
l_invoice_amount_remaining NUMBER;
BEGIN
  FOR R IN invoice_amount_remaining_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_remaining := r.AMOUNT_DUE_REMAINING;
  END LOOP;
  RETURN (l_invoice_amount_remaining);
END;

FUNCTION LINE_ID_APPLIED(p_cash_receipt_id IN NUMBER,
                         p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_lines(p_cash_receipt_id IN NUMBER,p_customer_trx_id IN NUMBER) IS
SELECT RACTRXLN.customer_trx_line_id
FROM   RA_CUSTOMER_TRX_LINES_ALL RACTRXLN
WHERE  RACTRXLN.LINE_TYPE = 'LINE'
AND    RACTRXLN.interface_line_context = 'OKL_CONTRACTS'
AND    RACTRXLN.CUSTOMER_TRX_ID = p_customer_trx_id;
l_inv_ln_id NUMBER := NULL;
l_count NUMBER :=0;
BEGIN
  FOR R IN invoice_lines (p_cash_receipt_id,p_customer_trx_id)
  LOOP
    l_count := l_count + 1;
    l_inv_ln_id := R.customer_trx_line_id;
  END LOOP;
  IF l_count = 1 THEN
    RETURN l_inv_ln_id;
  ELSE
    RETURN NULL;
  END IF;
END;

FUNCTION LINE_NUMBER_APPLIED(p_cash_receipt_id IN NUMBER,
                             p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_lines(p_cash_receipt_id IN NUMBER,p_customer_trx_id IN NUMBER) IS
SELECT RACTRXLN.line_number
FROM   RA_CUSTOMER_TRX_LINES_ALL RACTRXLN
WHERE  RACTRXLN.LINE_TYPE = 'LINE'
AND    RACTRXLN.interface_line_context = 'OKL_CONTRACTS'
AND    RACTRXLN.CUSTOMER_TRX_ID = p_customer_trx_id;
l_inv_ln_num NUMBER := NULL;
l_count NUMBER :=0;
BEGIN
  FOR R IN invoice_lines (p_cash_receipt_id,p_customer_trx_id)
  LOOP
    l_count := l_count + 1;
    l_inv_ln_num := R.line_number;
  END LOOP;
  IF l_count = 1 THEN
    RETURN l_inv_ln_num;
  ELSE
    RETURN NULL;
  END IF;
END;

/*FUNCTION DEBUG_PROC(msg varchar2) RETURN VARCHAR2 as
      PRAGMA AUTONOMOUS_TRANSACTION ;
      l_seq_num number;
   BEGIN
      SELECT new_seq.nextval into l_seq_num from dual;
      INSERT INTO DEBUG_TABLE_k VALUES(l_seq_num,SYSDATE, msg);
      commit;
      RETURN 'X';
END DEBUG_PROC;*/

FUNCTION get_tld_amount_orig( p_tld_id IN  NUMBER ) RETURN NUMBER IS
CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_orig NUMBER := 0;
BEGIN
  NULL;
  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    l_amount_orig := invoice_line_amount_orig(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_orig := invoice_amount_orig(l_customer_trx_id);
  END IF;

  RETURN (l_amount_orig);

END;

FUNCTION get_tld_amount_applied( p_tld_id IN  NUMBER ) RETURN NUMBER IS
CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_applied NUMBER := 0;
BEGIN
  NULL;
  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    l_amount_applied := invoice_line_amount_applied(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_applied := invoice_amount_applied(l_customer_trx_id);
  END IF;

  RETURN (l_amount_applied);

END;

FUNCTION get_tld_amount_credited( p_tld_id IN  NUMBER ) RETURN NUMBER IS
CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_credited NUMBER := 0;
BEGIN
  NULL;
  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    l_amount_credited := invoice_line_amount_credited(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_credited := invoice_amount_credited(l_customer_trx_id);
  END IF;

  RETURN (l_amount_credited);

END;

FUNCTION get_tld_amount_remaining( p_tld_id IN  NUMBER ) RETURN NUMBER IS
CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_remaining NUMBER := 0;
BEGIN
  NULL;
  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    l_amount_remaining := invoice_line_amount_remaining(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_remaining := invoice_amount_remaining(l_customer_trx_id);
  END IF;

  RETURN (l_amount_remaining);

END;

PROCEDURE get_tld_balance(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,p_tld_id                       IN  NUMBER
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_orig_amount                  OUT NOCOPY NUMBER
   ,x_applied_amount               OUT NOCOPY NUMBER
   ,x_credited_amount              OUT NOCOPY NUMBER
   ,x_remaining_amount             OUT NOCOPY NUMBER
   ,x_tax_amount                   OUT NOCOPY NUMBER
 )
 IS

CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

CURSOR invoice_line_tax_amount(p_line_id NUMBER) IS
  SELECT SUM(NVL(EXTENDED_AMOUNT, 0)) LINE_TAX_AMOUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  LINK_TO_CUST_TRX_LINE_ID = p_line_id
  AND    LINE_TYPE='TAX';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_remaining NUMBER := 0;

l_api_name              VARCHAR2(60) := 'Get TLD Balance';

BEGIN

  x_orig_amount := 0.0;
  x_applied_amount := 0;
  x_credited_amount := 0;
  x_remaining_amount := 0;
  x_tax_amount := 0;

  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  FOR r IN invoice_line_tax_amount(l_customer_trx_line_id)
  LOOP
    x_tax_amount := r.LINE_TAX_AMOUNT;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    x_orig_amount := invoice_line_amount_orig(
                          l_customer_trx_id, l_customer_trx_line_id);
    x_applied_amount := invoice_line_amount_applied(
                          l_customer_trx_id, l_customer_trx_line_id);
    x_credited_amount := invoice_line_amount_credited(
                          l_customer_trx_id, l_customer_trx_line_id);
    x_remaining_amount := invoice_line_amount_remaining(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    x_orig_amount := invoice_amount_orig(l_customer_trx_id);
    x_applied_amount := invoice_amount_applied(l_customer_trx_id);
    x_credited_amount := invoice_amount_credited(l_customer_trx_id);
    x_remaining_amount := invoice_amount_remaining(l_customer_trx_id);
  END IF;

  x_return_status := 'S';

 EXCEPTION
    WHEN OTHERS THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

END get_tld_balance;



PROCEDURE get_contract_invoice_balance(
   p_api_version                  IN NUMBER
  ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
  ,p_contract_number              IN  VARCHAR2
  ,p_trx_number                   IN  VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
  ,x_remaining_amount             OUT NOCOPY NUMBER
) IS


CURSOR cust_trx_csr(p_cust_trx_number VARCHAR2, p_contract_number VARCHAR2) IS
SELECT LNS.CUSTOMER_TRX_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL LNS,
       RA_CUSTOMER_TRX_ALL HDR
WHERE  LNS.INTERFACE_LINE_ATTRIBUTE6 = p_contract_number
  AND  HDR.TRX_NUMBER                = p_cust_trx_number
  AND  HDR.CUSTOMER_TRX_ID           = LNS.CUSTOMER_TRX_ID;


l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_amount_remaining NUMBER := 0;

l_api_name              VARCHAR2(60) := 'get_contract_invoice_balance';

BEGIN

  x_remaining_amount := 0;

  open cust_trx_csr(p_trx_number,p_contract_number);
   fetch cust_trx_csr into l_customer_trx_id;
  close cust_trx_csr;

    x_remaining_amount := invoice_amount_remaining(l_customer_trx_id);
  x_return_status := 'S';

 EXCEPTION
    WHEN OTHERS THEN

                x_return_status := OKL_API.HANDLE_EXCEPTIONS (
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => G_PKG_NAME,
                                        p_exc_name      => 'OTHERS',
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_api_type      => '_PVT');

END get_contract_invoice_balance;

FUNCTION INVOICE_LINE_TAX_AMOUNT(p_customer_trx_line_id NUMBER) RETURN NUMBER IS
CURSOR invoice_line_tax_amount(p_line_id NUMBER) IS
  SELECT SUM(NVL(EXTENDED_AMOUNT, 0)) LINE_TAX_AMOUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  LINK_TO_CUST_TRX_LINE_ID = p_line_id
  AND    LINE_TYPE='TAX';

l_tax_amount NUMBER;
BEGIN

  l_tax_amount := 0;

  FOR r IN invoice_line_tax_amount(p_customer_trx_line_id)
  LOOP
    l_tax_amount := r.LINE_TAX_AMOUNT;
  END LOOP;

  RETURN(l_tax_amount);

END;


/** VPANWAR 05-Sep-2007 Procedure to list In Process Billing
		Transactions pre-upgrade script **/
PROCEDURE  CHECK_PREUPGRADE_DATA(x_errbuf    OUT NOCOPY VARCHAR2,
                                 x_retcode   OUT NOCOPY NUMBER,
			         x_any_data_exists OUT NOCOPY BOOLEAN )
  IS
        l_api_name                CONSTANT VARCHAR2(30) := 'CHECK_PREUPGRADE_DATA';
        l_msg_count                NUMBER;
        l_msg_data                VARCHAR2(2000);
        l_return_status                VARCHAR2(1);
        l_api_version                NUMBER;
        l_init_msg_list                VARCHAR2(1);
        l_total_length                CONSTANT NUMBER DEFAULT 152;
        l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_BILLING_UTIL_PVT.CHECK_PREUPGRADE_DATA';
        l_debug_enabled                VARCHAR2(10);
        is_debug_procedure_on        BOOLEAN;
        is_debug_statement_on        BOOLEAN;
        l_contract              VARCHAR2(120);

        -- This cursor is used for the following purpose
        -- For every record in okl_trx_ar_invoices_b, okl_txl_ar_inv_lns_b, okl_txd_ar_ln_dtls_b
        -- check if corresponding records exist in okl_ext_sell_invs_b, okl_xtl_sell_invs_b table.
        -- We check both two level and three level transactions with the external tables.
        CURSOR int_ext_check_csr IS
                SELECT OKC_K_HEADERS_B.CONTRACT_NUMBER
                FROM OKL_TXL_AR_INV_LNS_B
                     , OKL_TXD_AR_LN_DTLS_B
                     , OKL_TRX_AR_INVOICES_B
                     , OKL_K_HEADERS
                     , OKC_K_HEADERS_B
                WHERE OKL_TXD_AR_LN_DTLS_B.TIL_ID_DETAILS = OKL_TXL_AR_INV_LNS_B.ID
                      AND OKC_K_HEADERS_B.ID = OKL_K_HEADERS.ID
                      AND OKL_K_HEADERS.ID = OKL_TRX_AR_INVOICES_B.KHR_ID
                      AND OKL_TXL_AR_INV_LNS_B.TAI_ID = OKL_TRX_AR_INVOICES_B.ID
                      AND OKL_TXD_AR_LN_DTLS_B.ID NOT IN
                      (  SELECT OKL_XTL_SELL_INVS_B.TLD_ID
                         FROM OKL_XTL_SELL_INVS_B
                              , OKL_EXT_SELL_INVS_B
                         WHERE OKL_EXT_SELL_INVS_B.ID = OKL_XTL_SELL_INVS_B.XSI_ID_DETAILS
                                AND OKL_XTL_SELL_INVS_B.TLD_ID IS NOT NULL)
                UNION
                SELECT OKC_K_HEADERS_B.CONTRACT_NUMBER
                FROM OKL_TXL_AR_INV_LNS_B TIL
                     , OKL_TRX_AR_INVOICES_B
                     , OKL_K_HEADERS
                     , OKC_K_HEADERS_B
                WHERE OKC_K_HEADERS_B.ID = OKL_K_HEADERS.ID
                      AND OKL_K_HEADERS.ID = OKL_TRX_AR_INVOICES_B.KHR_ID
                      AND TIL.TAI_ID = OKL_TRX_AR_INVOICES_B.ID
                      AND NOT EXISTS (
                       SELECT 1 FROM OKL_TXD_AR_LN_DTLS_B TXD
                       WHERE TXD.TIL_ID_DETAILS = TIL.ID
                      )
                      AND TIL.ID NOT IN
                      (SELECT OKL_XTL_SELL_INVS_B.TIL_ID
                       FROM OKL_XTL_SELL_INVS_B
                            , OKL_EXT_SELL_INVS_B
                       WHERE OKL_EXT_SELL_INVS_B.ID = OKL_XTL_SELL_INVS_B.XSI_ID_DETAILS
                             AND OKL_XTL_SELL_INVS_B.TIL_ID IS NOT NULL);

        -- This cursor is used for the following purpose
        -- For every record in okl_ext_sell_invs_b, okl_xtl_sell_invs_b check if
        -- corresponding records exist in okl_cnsld_ar_hdrs_b, okl_cnsld_ar_lines_b,
        -- okl_cnsld_ar_Strms_b tables.

          CURSOR ext_cnsld_check_csr IS
            SELECT DISTINCT OKC_K_HEADERS_B.CONTRACT_NUMBER
            FROM OKL_XTL_SELL_INVS_B
                ,OKL_EXT_SELL_INVS_B
                ,OKL_XTL_SELL_INVS_TL
                ,OKL_TRX_AR_INVOICES_B
                ,OKL_TXL_AR_INV_LNS_B
                ,OKL_TXD_AR_LN_DTLS_B
                ,OKC_K_HEADERS_B
            WHERE OKL_EXT_SELL_INVS_B.ID = OKL_XTL_SELL_INVS_B.XSI_ID_DETAILS
            AND OKL_XTL_SELL_INVS_B.ID = OKL_XTL_SELL_INVS_TL.ID
            AND OKL_XTL_SELL_INVS_B.LSM_ID IS NULL
            AND (OKL_TXL_AR_INV_LNS_B.ID = OKL_XTL_SELL_INVS_B.TIL_ID OR OKL_XTL_SELL_INVS_B.TLD_ID = OKL_TXD_AR_LN_DTLS_B.ID)
            AND OKL_TXD_AR_LN_DTLS_B.TIL_ID_DETAILS = OKL_TXL_AR_INV_LNS_B.ID
            AND  OKL_TXL_AR_INV_LNS_B.TAI_ID = OKL_TRX_AR_INVOICES_B.ID
            AND OKL_TRX_AR_INVOICES_B.KHR_ID = OKC_K_HEADERS_B.id;

        -- This cursor is used for the following purpose
        -- For every record in okl_cnsld_hdrs_b, okl_cnsld_ar_lines_b, okl_cnsld_ar_strms_b check
        -- if corresponding records exist in AR.
        CURSOR cnsld_ar_check_csr IS
                SELECT DISTINCT OKC_K_HEADERS_B.CONTRACT_NUMBER
                FROM OKL_CNSLD_AR_STRMS_B
                        , OKL_CNSLD_AR_LINES_B
                        , OKL_CNSLD_AR_HDRS_B
                        , OKL_K_HEADERS
                        , OKC_K_HEADERS_B
                WHERE OKL_CNSLD_AR_LINES_B.CNR_ID = OKL_CNSLD_AR_HDRS_B.ID
                        AND OKL_CNSLD_AR_STRMS_B.LLN_ID = OKL_CNSLD_AR_LINES_B.ID
                        AND OKC_K_HEADERS_B.ID = OKL_K_HEADERS.ID
                        AND OKL_K_HEADERS.ID = OKL_CNSLD_AR_STRMS_B.KHR_ID
                        AND OKL_CNSLD_AR_STRMS_B.KHR_ID = OKL_CNSLD_AR_LINES_B.KHR_ID
                        AND OKL_CNSLD_AR_STRMS_B.RECEIVABLES_INVOICE_ID IS NULL;

        -- This cursor is used for the following purpose
        -- For every record in okl_cnsld_ar_strms_b check if receivable_invoice_id is a positive number.
        CURSOR cnsld_pstv_check_csr IS
                SELECT DISTINCT OKC_K_HEADERS_B.CONTRACT_NUMBER
                FROM OKL_CNSLD_AR_STRMS_B
                        , OKL_CNSLD_AR_LINES_B
                        , OKL_CNSLD_AR_HDRS_B
                        , OKL_K_HEADERS
                        , OKC_K_HEADERS_B
                WHERE OKL_CNSLD_AR_LINES_B.CNR_ID = OKL_CNSLD_AR_HDRS_B.ID
                        AND OKL_CNSLD_AR_STRMS_B.LLN_ID = OKL_CNSLD_AR_LINES_B.ID
                        AND OKC_K_HEADERS_B.ID = OKL_K_HEADERS.ID
                        AND OKL_K_HEADERS.ID = OKL_CNSLD_AR_STRMS_B.KHR_ID
                        AND OKL_CNSLD_AR_STRMS_B.KHR_ID = OKL_CNSLD_AR_LINES_B.KHR_ID
                        AND OKL_CNSLD_AR_STRMS_B.RECEIVABLES_INVOICE_ID < 0
                        AND OKL_CNSLD_AR_STRMS_B.RECEIVABLES_INVOICE_ID IS NOT NULL;

  BEGIN

  		x_any_data_exists := false; -- VPANWAR changed for pre upgrade test

        /* l_debug_enabled := okl_debug_pub.check_log_enabled;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
        IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRBULB.pls call CHECK_PREUPGRADE_DATA');
        END IF;*/

        x_retcode := 0;
        x_errbuf := null;
	x_any_data_exists := FALSE;

        l_api_version := 1.0;
        l_init_msg_list := Okl_Api.G_TRUE;
        l_msg_count := 0;

        l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        -- Printing In Process Billing Transactions report header. The formatting of the message titles is
        -- also taken care here.
        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKLHOMENAVTITLE') ||
        RPAD(' ', 53 , ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKL_IN_PRCS_BILL_TRANS_REP') ||
        RPAD(' ', 53 , ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || '-------------------------------' || RPAD(' ', 51, ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));*/

        -- Printing the titles for 'Contract Number' and 'Next Step'
       /* FND_FILE.PUT(FND_FILE.OUTPUT, RPAD('Contract Number                 Next Step',150,' '));
        FND_FILE.PUT(FND_FILE.OUTPUT, RPAD('------------------               --------------',150,' ')); */

         /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Contract Number                 Next Step');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'------------------               --------------'); */

        -- Initialize the contract variable to Null.
        -- Open the cursor Int_Ext_Check_Csr, Loop through it and display the contract number
        -- and the Next step value should be 'Run Prepare Receivables Bills concurrent program'.
        l_contract := NULL;
        OPEN int_ext_check_csr;
        -- Fetch from the cursor the first time and check if any row is found.
        -- If found then print the contract number , the next step and loop through
        -- the cursor. If not found then display the No records found message.
        FETCH int_ext_check_csr INTO l_contract;
        IF int_ext_check_csr%FOUND
        THEN
                LOOP
                	x_any_data_exists := true; -- VPANWAR changed for pre upgrade test
                	x_retcode := 1;
                        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(SUBSTR(l_contract,1,28),30,' ')||
                        RPAD('   Run Prepare Receivables Bills concurrent program',120,' '));
                        FETCH int_ext_check_csr INTO l_contract;
                        EXIT WHEN int_ext_check_csr%NOTFOUND;*/
                        x_errbuf := 'Prepare Receivables Bills concurrent program';
                        EXIT;
                END LOOP;
        /* ELSE
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || 'No Records Found' || RPAD(' ', 51, ' ' ));*/
        END IF;
        CLOSE int_ext_check_csr;

        -- Insert blank lines
        /*FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));*/

        -- Initialize the contract variable to Null.
        -- Open the cursor ext_cnsld_check_csr, Loop through it and display the contract number
        -- and the Next step value should be 'Run Receivables Bills Consolidation concurrent program'.
        l_contract := NULL;
        OPEN ext_cnsld_check_csr;
        -- Fetch from the cursor the first time and check if any row is found.
        -- If found then print the contract number , the next step and loop through
        -- the cursor. If not found then display the No records found message.
        FETCH ext_cnsld_check_csr INTO l_contract;
        IF ext_cnsld_check_csr%FOUND
        THEN
                LOOP
                	x_any_data_exists := true; -- VPANWAR changed for pre upgrade test
                	x_retcode := 1;
                        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(SUBSTR(l_contract,1,28),30,' ')||
                        RPAD('   Run Receivables Bills Consolidation concurrent program',120,' '));
                        FETCH ext_cnsld_check_csr INTO l_contract;
                        EXIT WHEN ext_cnsld_check_csr%NOTFOUND;*/
                        x_errbuf := 'Receivables Bills Consolidation concurrent program';
                        EXIT;
                END LOOP;
        /*ELSE
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || 'No Records Found' || RPAD(' ', 51, ' ' ));*/
        END IF;
        CLOSE ext_cnsld_check_csr;

        -- Insert blank lines
        /*FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));*/

        -- Initialize the contract variable to Null.
        -- Open the cursor cnsld_ar_check_csr, Loop through it and display the contract number
        -- and the Next step value should be 'Run Prepare Receivables Bills concurrent program'.
        l_contract := NULL;
        OPEN cnsld_ar_check_csr;
        -- Fetch from the cursor the first time and check if any row is found.
        -- If found then print the contract number , the next step and loop through
        -- the cursor. If not found then display the No records found message.
        FETCH cnsld_ar_check_csr INTO l_contract;
        IF cnsld_ar_check_csr%FOUND
        THEN
                LOOP
                	x_any_data_exists := true; -- VPANWAR changed for pre upgrade test
                	x_retcode := 1;
                        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(SUBSTR(l_contract,1,28),30,' ')||
                        RPAD('   Run Receivables Invoice Transfer to AR concurrent program',120,' '));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',30,' ')||
                        RPAD('   Run AutoInvoice Master Program',120,' '));
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',30,' ')||
                        RPAD('   Run Fetch AR Invoice Numbers',120,' '));
                        FETCH cnsld_ar_check_csr INTO l_contract;
                        EXIT WHEN cnsld_ar_check_csr%NOTFOUND;*/
                        x_errbuf := 'AutoInvoice Master Program and Fetch AR Invoice Numbers';
                        EXIT;
                END LOOP;
        /*ELSE
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || 'No Records Found' || RPAD(' ', 51, ' ' ));*/
        END IF;
        CLOSE cnsld_ar_check_csr;

        -- Insert blank lines
        /*FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, rPAD(' ', 150, ' '));*/

        -- Initialize the contract variable to Null.
        -- Open the cursor cnsld_pstv_check_csr, Loop through it and display the contract number
        -- and the Next step value should be 'Run Prepare Receivables Bills concurrent program'.
        l_contract := NULL;
        OPEN cnsld_pstv_check_csr;
        -- Fetch from the cursor the first time and check if any row is found.
        -- If found then print the contract number , the next step and loop through
        -- the cursor. If not found then display the No records found message.
        FETCH cnsld_pstv_check_csr INTO l_contract;
        IF cnsld_pstv_check_csr%FOUND
        THEN
                LOOP
                	x_any_data_exists := true; -- VPANWAR changed for pre upgrade test
                	x_retcode := 1;
                        /*FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(SUBSTR(l_contract,1,28),30,' ')||
                        RPAD('   Run Fetch AR Invoice Numbers',120,' '));
                        FETCH cnsld_pstv_check_csr INTO l_contract;
                        EXIT WHEN cnsld_pstv_check_csr%NOTFOUND;*/
                        x_errbuf := 'Fetch AR Invoice Numbers';
                        EXIT;
                END LOOP;
        /*ELSE
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || 'No Records Found' || RPAD(' ', 51, ' ' ));*/
        END IF;
        CLOSE cnsld_pstv_check_csr;

        okl_api.END_ACTIVITY(l_msg_count, l_msg_data);
        IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
                okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRUPGB.pls call IN_PROCESS_BILLING_TXN');
        END IF;

        EXCEPTION
            WHEN OTHERS THEN
                    IF int_ext_check_csr%ISOPEN
                    THEN
                        CLOSE int_ext_check_csr;
                    END IF;
                    IF ext_cnsld_check_csr%ISOPEN
                    THEN
                        CLOSE ext_cnsld_check_csr;
                    END IF;
                    IF cnsld_ar_check_csr%ISOPEN
                    THEN
                        CLOSE cnsld_ar_check_csr;
                    END IF;
                    IF cnsld_pstv_check_csr%ISOPEN
                    THEN
                        CLOSE cnsld_pstv_check_csr;
                    END IF;
                    x_errbuf := SQLERRM;
                    x_retcode := 2;
					x_any_data_exists := true; -- VPANWAR changed for pre upgrade test

                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

                    IF (SQLCODE <> -20001) THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
                        RAISE;
                    ELSE
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
                        APP_EXCEPTION.RAISE_EXCEPTION;
                    END IF;
END check_preupgrade_data;

-- bug bug 6328168 get the amounts without Tax

FUNCTION get_tld_amt_remaining_WOTAX( p_tld_id IN  NUMBER ) RETURN NUMBER IS
CURSOR cust_trx_csr(p_interface_line_attribute14 VARCHAR2) IS
SELECT CUSTOMER_TRX_ID, CUSTOMER_TRX_LINE_ID
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  INTERFACE_LINE_ATTRIBUTE14 = p_interface_line_attribute14
AND    INTERFACE_LINE_CONTEXT = 'OKL_CONTRACTS';

CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
SELECT COUNT(1) LINE_COUNT
FROM   RA_CUSTOMER_TRX_LINES_ALL
WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
AND    LINE_TYPE = 'LINE';

l_customer_trx_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_ID%TYPE;
l_customer_trx_line_id RA_CUSTOMER_TRX_LINES_ALL.CUSTOMER_TRX_LINE_ID%TYPE;
l_line_count NUMBER;
l_amount_remaining NUMBER := 0;
BEGIN
  NULL;
  FOR r IN cust_trx_csr(p_tld_id)
  LOOP
    l_customer_trx_id := r.CUSTOMER_TRX_ID;
    l_customer_trx_line_id := r.CUSTOMER_TRX_LINE_ID;
  END LOOP;

  FOR r IN line_count_csr(l_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice
    l_amount_remaining := INV_LN_AMT_REMAINING_WOTAX(
                          l_customer_trx_id, l_customer_trx_line_id);
  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_remaining := INV_AMT_REMAINING_WOTAX(l_customer_trx_id);
  END IF;

  RETURN (l_amount_remaining);

END;

FUNCTION INV_LN_AMT_REMAINING_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
l_invoice_line_amount_orig NUMBER;
l_invoice_line_amount_applied NUMBER;
l_invoice_line_amount_credited NUMBER;
l_invoice_line_amt_remaining NUMBER;
--Bug# 7720775
l_invoice_line_amount_adjusted NUMBER;
BEGIN
  l_invoice_line_amount_orig := INV_LN_AMT_ORIG_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_applied := INV_LN_AMT_APPLIED_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_credited := INV_LN_AMT_CREDITED_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  --Bug# 7720775
  l_invoice_line_amount_adjusted := INV_LN_AMT_ADJUSTED_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amt_remaining := NVL(l_invoice_line_amount_orig -l_invoice_line_amount_applied - l_invoice_line_amount_credited + l_invoice_line_amount_adjusted, 0);

  RETURN (l_invoice_line_amt_remaining);
END;

FUNCTION INV_AMT_REMAINING_WOTAX(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_amount_remaining_csr(p_header_id NUMBER) IS
SELECT SUM(NVL(APS.AMOUNT_DUE_REMAINING,0)) AMOUNT_DUE_REMAINING
FROM   AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUSTOMER_TRX_ALL RACTRX
WHERE  RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
AND    RACTRX.CUSTOMER_TRX_ID = p_header_id;
l_invoice_amount_remaining NUMBER;
BEGIN
  FOR R IN invoice_amount_remaining_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_remaining := r.AMOUNT_DUE_REMAINING;
  END LOOP;
  RETURN (l_invoice_amount_remaining);
END;


FUNCTION INV_LN_AMT_ORIG_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
CURSOR invoice_line_amount(p_header_id NUMBER, p_line_id NUMBER) IS
  SELECT NVL(EXTENDED_AMOUNT, 0) LINE_AMOUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  CUSTOMER_TRX_ID = p_header_id
  AND    CUSTOMER_TRX_LINE_ID = p_line_id;

l_line_amount NUMBER;
l_line_original_due NUMBER;

BEGIN

  FOR r IN invoice_line_amount(p_customer_trx_id, p_customer_trx_line_id)
  LOOP
    l_line_amount := r.LINE_AMOUNT;
  END LOOP;

  l_line_original_due := NVL(l_line_amount,0);
  return (l_line_original_due);
END;


FUNCTION INV_LN_AMT_CREDITED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
CURSOR line_credited_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) credit_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   = 'INV'
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CM'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = p_line_id;

l_line_amount_credited NUMBER;
BEGIN
  FOR r in line_credited_csr(p_customer_trx_id, p_customer_trx_line_id)
  LOOP
    l_line_amount_credited := r.credit_applied;
  END LOOP;
  RETURN(nvl(l_line_amount_credited,0));
END;

FUNCTION INV_LN_AMT_APPLIED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
--dkagrawa modified the cusrsor to add class CM
CURSOR line_applied_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) line_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   IN ('INV','CM') --Receipt can be applied against credit memo
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CASH'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = p_line_id;
--dkagrawa modified the cusrsor to add class CM

l_line_amount_applied NUMBER;
BEGIN
  FOR r in line_applied_csr(p_customer_trx_id, p_customer_trx_line_id)
  LOOP
    l_line_amount_applied := r.line_applied;
  END LOOP;
  RETURN(nvl(l_line_amount_applied,0));
END;

FUNCTION INVOICE_AMOUNT_ADJUSTED(
          p_customer_trx_id IN NUMBER) RETURN NUMBER IS
CURSOR invoice_amount_adj_csr(p_header_id NUMBER) IS
SELECT SUM(NVL(APS.AMOUNT_ADJUSTED,0)) AMOUNT_ADJUSTED
FROM   AR_PAYMENT_SCHEDULES_ALL APS,
       RA_CUSTOMER_TRX_ALL RACTRX
WHERE  RACTRX.CUSTOMER_TRX_ID = APS.CUSTOMER_TRX_ID
AND    RACTRX.CUSTOMER_TRX_ID = p_header_id;
l_invoice_amount_adj NUMBER;
BEGIN
  FOR R IN invoice_amount_adj_csr (p_customer_trx_id)
  LOOP
    l_invoice_amount_adj := r.AMOUNT_ADJUSTED;
  END LOOP;
  RETURN (l_invoice_amount_adj);
END INVOICE_AMOUNT_ADJUSTED;

FUNCTION INVOICE_LINE_AMOUNT_ADJUSTED(
          p_customer_trx_id IN NUMBER,
	  p_customer_trx_line_id IN NUMBER) RETURN NUMBER IS

  CURSOR invoice_ln_tax_adj(p_header_id NUMBER, p_line_id NUMBER) IS
  SELECT SUM(nvl(dist.amount_cr,0))- SUM(nvl(dist.amount_dr,0)) tax_adjusted
  FROM   ar_adjustments_all adj,
         ar_payment_schedules_all sch,
         ar_distributions_all dist,
         ra_customer_trx_lines_all lines
  WHERE  adj.payment_schedule_id = sch.payment_schedule_id
  AND    sch.class = 'INV'
  AND    sch.customer_trx_id = p_header_id
  AND    adj.ADJUSTMENT_ID = dist.source_id
  AND    dist.source_table = 'ADJ'
  AND    dist.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
  AND    lines.link_to_cust_trx_line_id = p_line_id
  AND    lines.line_type = 'TAX';

  l_invoice_ln_amount_adj NUMBER;
  l_invoice_ln_tax_adj    NUMBER;

  --Bug# 9116332
  CURSOR line_count_csr(p_customer_trx_id NUMBER) IS
  SELECT COUNT(1) LINE_COUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  CUSTOMER_TRX_ID = p_customer_trx_id
  AND    LINE_TYPE = 'LINE';

  l_line_count NUMBER;
  l_amount_adjusted NUMBER;
  --Bug# 9116332

BEGIN

  --Bug# 9116332
  FOR r IN line_count_csr(p_customer_trx_id)
  LOOP
    l_line_count := r.line_count;
  END LOOP;

  IF (l_line_count > 1) THEN
    -- New style (R12B) invoice

    --Bug# 7720775
    l_invoice_ln_amount_adj := INV_LN_AMT_ADJUSTED_WOTAX(
                                       p_customer_trx_id,
                                       p_customer_trx_line_id);

    FOR R IN invoice_ln_tax_adj (p_customer_trx_id,p_customer_trx_line_id)
    LOOP
      l_invoice_ln_tax_adj := r.tax_adjusted;
    END LOOP;

    l_amount_adjusted := NVL(l_invoice_ln_amount_adj,0)+NVL(l_invoice_ln_tax_adj,0);

  ELSIF (l_line_count = 1) THEN
    -- Old style invoice
    l_amount_adjusted := invoice_amount_adjusted(p_customer_trx_id);

  END IF;
  --Bug# 9116332

  RETURN (l_amount_adjusted);

END INVOICE_LINE_AMOUNT_ADJUSTED;

--Bug# 7720775
FUNCTION INV_LN_AMT_ADJUSTED_WOTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id IN NUMBER) RETURN NUMBER IS

  CURSOR invoice_ln_amount_adj(p_header_id NUMBER, p_line_id NUMBER) IS
  SELECT SUM(nvl(dist.amount_cr,0))- SUM(nvl(dist.amount_dr,0)) amt_adjsuted
  FROM   ar_distributions_all dist ,
         ar_adjustments_all adj ,
         ar_payment_schedules_all aps
  WHERE  dist.source_table = 'ADJ'
  AND    dist.source_id = adj.adjustment_id
  AND    aps.customer_trx_id = p_header_id
  AND    adj.payment_schedule_id = aps.payment_schedule_id
  AND    aps.class = 'INV'
  AND    ref_customer_trx_line_id = p_line_id;

  l_invoice_ln_amount_adj NUMBER;
BEGIN
  FOR R IN invoice_ln_amount_adj (p_customer_trx_id,p_customer_trx_line_id)
  LOOP
    l_invoice_ln_amount_adj := r.amt_adjsuted;
  END LOOP;

  RETURN NVL(l_invoice_ln_amount_adj,0);

END INV_LN_AMT_ADJUSTED_WOTAX;

--Bug# 7720775
-- Functions to return Invoice Line Amount with Inclusive Invoice Tax Line Amounts
FUNCTION INV_LN_AMT_ORIG_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR invoice_line_tax_amount(p_line_id NUMBER) IS
  SELECT SUM(NVL(EXTENDED_AMOUNT, 0)) LINE_TAX_AMOUNT
  FROM   RA_CUSTOMER_TRX_LINES_ALL
  WHERE  LINK_TO_CUST_TRX_LINE_ID = p_line_id
  AND    AMOUNT_INCLUDES_TAX_FLAG = 'Y';

l_line_amount NUMBER;
l_line_tax_amount NUMBER;
l_line_original_due NUMBER;

BEGIN

  l_line_amount := INV_LN_AMT_ORIG_WOTAX(p_customer_trx_id,
                                         p_customer_trx_line_id);

  FOR r IN invoice_line_tax_amount(p_customer_trx_line_id)
  LOOP
    l_line_tax_amount := r.LINE_TAX_AMOUNT;
  END LOOP;

  l_line_original_due := NVL(NVL(l_line_amount,0) + NVL(l_line_tax_amount,0),0);
  return (l_line_original_due);
END;

FUNCTION INV_LN_AMT_APPLIED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR tax_applied_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) tax_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad,
             ra_customer_trx_lines_all lines
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   IN ('INV','CM') --Receipt can be applied against credit memo
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CASH'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
      AND    lines.link_to_cust_trx_line_id = p_line_id
      AND    lines.line_type = 'TAX'
      AND    lines.amount_includes_tax_flag = 'Y';

l_line_amount_applied NUMBER;
l_tax_amount_applied NUMBER;
BEGIN

  l_line_amount_applied := INV_LN_AMT_APPLIED_WOTAX(p_customer_trx_id,
                                                    p_customer_trx_line_id);

  FOR r in tax_applied_csr(p_customer_trx_id, p_customer_trx_line_id)
  LOOP
    l_tax_amount_applied := r.tax_applied;
  END LOOP;
  RETURN(nvl(l_line_amount_applied,0) + NVL(l_tax_amount_applied,0));
END;

FUNCTION INV_LN_AMT_CREDITED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS

CURSOR tax_credited_csr(p_header_id NUMBER, p_line_id NUMBER) IS
      SELECT SUM(nvl(ad.amount_cr,0))- SUM(nvl(ad.amount_dr,0)) credit_applied
      FROM   ar_receivable_applications_all app,
             ar_payment_schedules_all sch,
             ar_distributions_all ad,
             ra_customer_trx_lines_all lines
      WHERE  app.status                  = 'APP'
      AND    app.applied_payment_schedule_id = sch.payment_schedule_id
      AND    sch.class                   = 'INV'
      AND    sch.customer_trx_id         = p_header_id
      AND    app.application_type = 'CM'
      AND    app.receivable_application_id = ad.source_id
      AND    ad.source_table = 'RA'
      AND    ad.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
      AND    lines.link_to_cust_trx_line_id = p_line_id
      AND    lines.line_type = 'TAX'
      AND    lines.amount_includes_tax_flag = 'Y';

l_line_amount_credited NUMBER;
l_tax_amount_credited NUMBER;
BEGIN

  l_line_amount_credited := INV_LN_AMT_CREDITED_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  FOR r in tax_credited_csr(p_customer_trx_id, p_customer_trx_line_id)
  LOOP
    l_tax_amount_credited := r.credit_applied;
  END LOOP;
  RETURN(nvl(l_line_amount_credited,0) + NVL(l_tax_amount_credited,0));
END;

FUNCTION INV_LN_AMT_ADJUSTED_W_INCTAX(
          p_customer_trx_id IN NUMBER,
	    p_customer_trx_line_id IN NUMBER) RETURN NUMBER IS

  CURSOR invoice_ln_tax_adj(p_header_id NUMBER, p_line_id NUMBER) IS
  SELECT SUM(nvl(dist.amount_cr,0))- SUM(nvl(dist.amount_dr,0)) tax_adjusted
  FROM   ar_adjustments_all adj,
         ar_payment_schedules_all sch,
         ar_distributions_all dist,
         ra_customer_trx_lines_all lines
  WHERE  adj.payment_schedule_id = sch.payment_schedule_id
  AND    sch.class = 'INV'
  AND    sch.customer_trx_id = p_header_id
  AND    adj.ADJUSTMENT_ID = dist.source_id
  AND    dist.source_table = 'ADJ'
  AND    dist.ref_Customer_trx_Line_Id = lines.customer_trx_line_id
  AND    lines.link_to_cust_trx_line_id = p_line_id
  AND    lines.line_type = 'TAX'
  AND    lines.amount_includes_tax_flag = 'Y';

  l_invoice_ln_amount_adj NUMBER;
  l_invoice_ln_tax_adj    NUMBER;
BEGIN

  l_invoice_ln_amount_adj := INV_LN_AMT_ADJUSTED_WOTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  FOR R IN invoice_ln_tax_adj (p_customer_trx_id,p_customer_trx_line_id)
  LOOP
    l_invoice_ln_tax_adj := r.tax_adjusted;
  END LOOP;

  RETURN (NVL(l_invoice_ln_amount_adj,0)+NVL(l_invoice_ln_tax_adj,0));

END INV_LN_AMT_ADJUSTED_W_INCTAX;

FUNCTION INV_LN_AMT_REMAINING_W_INCTAX(
          p_customer_trx_id IN NUMBER,
          p_customer_trx_line_id NUMBER) RETURN NUMBER IS
l_invoice_line_amount_orig NUMBER;
l_invoice_line_amount_applied NUMBER;
l_invoice_line_amount_credited NUMBER;
l_invoice_line_amt_remaining NUMBER;
l_invoice_line_amount_adjusted  NUMBER;
BEGIN
  l_invoice_line_amount_orig    := INV_LN_AMT_ORIG_W_INCTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_applied := INV_LN_AMT_APPLIED_W_INCTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_credited := INV_LN_AMT_CREDITED_W_INCTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amount_adjusted := INV_LN_AMT_ADJUSTED_W_INCTAX(
                                     p_customer_trx_id,
                                     p_customer_trx_line_id);

  l_invoice_line_amt_remaining := NVL(l_invoice_line_amount_orig -l_invoice_line_amount_applied - l_invoice_line_amount_credited + l_invoice_line_amount_adjusted, 0);

  RETURN (l_invoice_line_amt_remaining);
END;

END OKL_BILLING_UTIL_PVT;

/
