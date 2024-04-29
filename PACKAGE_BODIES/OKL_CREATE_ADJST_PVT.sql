--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_ADJST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_ADJST_PVT" AS
/* $Header: OKLROCAB.pls 120.10.12010000.5 2009/08/06 08:44:21 nikshah ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.ADJUSTMENTS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  IS_DEBUG_STATEMENT_ON BOOLEAN;
  IS_DEBUG_EXCEPTION_ON BOOLEAN;

TYPE l_adj_lines_rec_type IS RECORD
( APPLY_DATE                okl_trx_ar_adjsts_b.APPLY_DATE%type,
  GL_DATE                   okl_trx_ar_adjsts_b.GL_DATE%type,
  ADJUSTMENT_REASON_CODE    okl_trx_ar_adjsts_b.ADJUSTMENT_REASON_CODE%type,
  COMMENTS                  okl_trx_ar_adjsts_tl.COMMENTS%type,
  adjsts_lns_id             okl_txl_adjsts_lns_b.ID%type,
  payment_schedule_id       okl_txl_adjsts_lns_b.PSL_ID%type,
  AMOUNT                    okl_txl_adjsts_lns_b.AMOUNT%type,
  CODE_COMBINATION_ID       okl_txl_adjsts_lns_b.CODE_COMBINATION_ID%type,
  customer_trx_id           ra_customer_trx_all.customer_trx_id%type,
  customer_trx_line_id      ra_customer_trx_lines_all.customer_trx_line_id%type
);
TYPE l_adj_lines_tbl_type IS TABLE OF l_adj_lines_rec_type INDEX BY BINARY_INTEGER;

TYPE l_adj_hdr_rec_type IS RECORD
( lines l_adj_lines_tbl_type,
  cons_invoice VARCHAR2(1)
);
TYPE l_adj_hdr_tbl_type IS TABLE OF l_adj_hdr_rec_type INDEX BY BINARY_INTEGER;

-- End of wraper code generated automatically by Debug code generator

---------------------------------------------------------------------------
-- PROCEDURE get_adj_header_and_lines
---------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              get_adj_header_and_lines                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This will return adjustment header and lines table to calling API       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    NIKSHAH  03-AUG-09  Created                                      |
 +===========================================================================*/
PROCEDURE get_adj_header_and_lines
          (p_api_version    IN         NUMBER
          ,p_init_msg_list  IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
          ,p_psl_id         IN         NUMBER DEFAULT NULL
          ,x_return_status  OUT NOCOPY VARCHAR2
          ,x_msg_count      OUT NOCOPY NUMBER
          ,x_msg_data       OUT NOCOPY VARCHAR2
          ,x_adj_hdr_tbl    OUT NOCOPY l_adj_hdr_tbl_type
          ,x_adj_lines_tbl  OUT NOCOPY l_adj_lines_tbl_type)
IS

l_apply_date                AR_ADJUSTMENTS.APPLY_DATE%TYPE;
l_gl_date                   AR_ADJUSTMENTS.GL_DATE%TYPE;
l_adjustment_reason_code    AR_ADJUSTMENTS.REASON_CODE%TYPE;
l_comments                  AR_ADJUSTMENTS.COMMENTS%TYPE;
l_adjsts_lns_id             OKL_TXL_ADJSTS_LNS_B.ID%TYPE;
l_payment_schedule_id       AR_ADJUSTMENTS.PAYMENT_SCHEDULE_ID%TYPE;
l_code_combination_id       AR_ADJUSTMENTS.CODE_COMBINATION_ID%TYPE;
l_amount                    AR_ADJUSTMENTS.AMOUNT%TYPE;

CURSOR c_get_adjustments IS
SELECT a.APPLY_DATE
      ,a.GL_DATE
      ,a.ADJUSTMENT_REASON_CODE
      ,a.COMMENTS
      ,b.ID
      ,b.PSL_ID
      ,b.AMOUNT
      ,b.CODE_COMBINATION_ID
      ,ln.customer_trx_id
      ,ln.customer_trx_line_id
FROM   okl_trx_ar_adjsts_v a,
       okl_txl_adjsts_lns_v b,
       ra_customer_trx_lines_all ln,
       ar_payment_schedules_all ps,
       okc_k_headers_b khr,
       okc_k_lines_v kle,
       okl_strm_type_v sty
WHERE  a.id = b.adj_id
AND    b.receivables_adjustment_id IS NULL
AND    b.psl_id = ps.payment_schedule_id
AND    ln.customer_trx_id = ps.customer_trx_id
AND    khr.contract_number = ln.interface_line_attribute6
AND    khr.id = kle.chr_id
AND    kle.name = ln.interface_line_attribute7
AND    sty.name = ln.interface_line_attribute9
AND    sty.id = b.sty_id
AND    khr.id = b.khr_id
AND    kle.id = b.kle_id
AND    ps.payment_schedule_id = NVL(p_psl_id, ps.payment_schedule_id)
ORDER BY ln.customer_trx_id, b.PSL_ID;

CURSOR c_is_consolidated_invoice(cp_psl_id IN NUMBER) IS
SELECT 'Y'
FROM   AR_PAYMENT_SCHEDULES_ALL APS,
       OKL_CNSLD_AR_STRMS_B CAS
WHERE  APS.CUSTOMER_TRX_ID = CAS.RECEIVABLES_INVOICE_ID
  AND  APS.PAYMENT_SCHEDULE_ID = cp_psl_id;

l_is_cons_inv VARCHAR2(1) := 'N';

l_adj_hdr_tbl l_adj_hdr_tbl_type;
l_adj_lines_tbl l_adj_lines_tbl_type;

l_first_record          BOOLEAN := TRUE;
cl                      NUMBER;
ch                      NUMBER;
l_last_psl_id           NUMBER;
l_last_trx_id           NUMBER;
l_customer_trx_id       ra_customer_trx_all.customer_trx_id%type;
l_customer_trx_line_id  ra_customer_trx_lines_all.customer_trx_line_id%type;

BEGIN
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'OKL_CREATE_ADJST_PVT.get_adjustment_header_and_lines BEGIN(+)  ');
     END;
   END IF;

    --Table initialization
    l_adj_lines_tbl.delete;
    l_adj_hdr_tbl.delete;
    l_first_record := TRUE;
    cl := 1;
    ch := 1;
    l_last_psl_id := -1;
    l_last_trx_id := -1;

    OPEN c_get_adjustments;
    LOOP
      FETCH c_get_adjustments INTO   l_apply_date
                                    ,l_gl_date
                                    ,l_adjustment_reason_code
                                    ,l_comments
                                    ,l_adjsts_lns_id
                                    ,l_payment_schedule_id
                                    ,l_amount
                                    ,l_code_combination_id
                                    ,l_customer_trx_id
                                    ,l_customer_trx_line_id;
      EXIT WHEN c_get_adjustments%NOTFOUND;
      IF l_first_record = TRUE THEN
        l_adj_lines_tbl(cl).apply_date := l_apply_date;
        l_adj_lines_tbl(cl).gl_date := l_gl_date;
        l_adj_lines_tbl(cl).adjustment_reason_code := l_adjustment_reason_code;
        l_adj_lines_tbl(cl).comments := l_comments;
        l_adj_lines_tbl(cl).adjsts_lns_id := l_adjsts_lns_id;
        l_adj_lines_tbl(cl).payment_schedule_id := l_payment_schedule_id;
        l_adj_lines_tbl(cl).amount := l_amount;
        l_adj_lines_tbl(cl).code_combination_id := l_code_combination_id;
        l_adj_lines_tbl(cl).customer_trx_id := l_customer_trx_id;
        l_adj_lines_tbl(cl).customer_trx_line_id := l_customer_trx_line_id;

        l_last_psl_id := l_payment_schedule_id;
        l_last_trx_id := l_customer_trx_id;
        cl := cl + 1;
        l_first_record := FALSE;
      ELSE
        IF l_payment_schedule_id = l_last_psl_id AND l_customer_trx_id = l_customer_trx_id THEN
          l_adj_lines_tbl(cl).apply_date := l_apply_date;
          l_adj_lines_tbl(cl).gl_date := l_gl_date;
          l_adj_lines_tbl(cl).adjustment_reason_code := l_adjustment_reason_code;
          l_adj_lines_tbl(cl).comments := l_comments;
          l_adj_lines_tbl(cl).adjsts_lns_id := l_adjsts_lns_id;
          l_adj_lines_tbl(cl).payment_schedule_id := l_payment_schedule_id;
          l_adj_lines_tbl(cl).amount := l_amount;
          l_adj_lines_tbl(cl).code_combination_id := l_code_combination_id;
          l_adj_lines_tbl(cl).customer_trx_id := l_customer_trx_id;
          l_adj_lines_tbl(cl).customer_trx_line_id := l_customer_trx_line_id;

          l_last_psl_id := l_payment_schedule_id;
          l_last_trx_id := l_customer_trx_id;
          cl := cl + 1;
        ELSE
          --Wrap up last lines table into one header and decide whether that was
          --for cons invoice or regular R12 invoice
          OPEN c_is_consolidated_invoice(l_last_psl_id);
          FETCH c_is_consolidated_invoice INTO l_is_cons_inv;
          IF c_is_consolidated_invoice%NOTFOUND THEN
            l_is_cons_inv := 'N';
          END IF;
          CLOSE c_is_consolidated_invoice;
          l_adj_hdr_tbl(ch).lines := l_adj_lines_tbl;
          l_adj_hdr_tbl(ch).cons_invoice := l_is_cons_inv;
          cl := 1;
          l_adj_lines_tbl.delete;
          ch := ch + 1;

          --Now create new header with all lines information
          l_adj_lines_tbl(cl).apply_date := l_apply_date;
          l_adj_lines_tbl(cl).gl_date := l_gl_date;
          l_adj_lines_tbl(cl).adjustment_reason_code := l_adjustment_reason_code;
          l_adj_lines_tbl(cl).comments := l_comments;
          l_adj_lines_tbl(cl).adjsts_lns_id := l_adjsts_lns_id;
          l_adj_lines_tbl(cl).payment_schedule_id := l_payment_schedule_id;
          l_adj_lines_tbl(cl).amount := l_amount;
          l_adj_lines_tbl(cl).code_combination_id := l_code_combination_id;
          l_adj_lines_tbl(cl).customer_trx_id := l_customer_trx_id;
          l_adj_lines_tbl(cl).customer_trx_line_id := l_customer_trx_line_id;

          l_last_psl_id := l_payment_schedule_id;
          l_last_trx_id := l_customer_trx_id;
          cl := cl + 1;
        END IF;
      END IF;
    END LOOP;
    CLOSE c_get_adjustments;
    --Wrap up last lines table into one header and decide whether that was
    --for cons invoice or regular R12 invoice
    OPEN c_is_consolidated_invoice(l_last_psl_id);
    FETCH c_is_consolidated_invoice INTO l_is_cons_inv;
    IF c_is_consolidated_invoice%NOTFOUND THEN
      l_is_cons_inv := 'N';
    END IF;
    CLOSE c_is_consolidated_invoice;
    l_adj_hdr_tbl(ch).lines := l_adj_lines_tbl;
    l_adj_hdr_tbl(ch).cons_invoice := l_is_cons_inv;
    l_adj_lines_tbl.delete;

   IF(IS_DEBUG_STATEMENT_ON) THEN
     BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,L_MODULE,' COUNT OF ADJUSTMENT HEADER : ' || l_adj_hdr_tbl.COUNT);
     END;
   END IF;

    x_adj_hdr_tbl := l_adj_hdr_tbl;
    x_adj_lines_tbl := l_adj_lines_tbl;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'OKL_CREATE_ADJST_PVT.get_adjustment_header_and_lines END(-)  ');
     END;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
   IF(IS_DEBUG_EXCEPTION_ON) THEN
     BEGIN
       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION,L_MODULE,'OKL_CREATE_ADJST_PVT.get_adjustment_header_and_lines EXCEPTION : ' || sqlerrm );
     END;
   END IF;
   x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
   x_msg_data := sqlerrm ;
END get_adj_header_and_lines;

---------------------------------------------------------------------------
-- PROCEDURE create_adjustments
---------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |              create_adjustments                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine to create an adjustment in AR       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Bruno Vaghela  16-AUG-02  Created                                      |
 |    18-Jul-2006 dkagrawa  Bug 5378114 MOAC changes                         |
 +===========================================================================*/

PROCEDURE create_adjustments   ( p_api_version  IN  NUMBER
                  ,p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                  ,p_psl_id         IN  NUMBER   DEFAULT NULL
                  ,p_commit_flag         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                  ,p_chk_approval_limits IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                  ,x_return_status  OUT NOCOPY VARCHAR2
                  ,x_msg_count  OUT NOCOPY NUMBER
                  ,x_msg_data      OUT NOCOPY VARCHAR2
                  ,x_new_adj_id          OUT NOCOPY NUMBER --Will be used only for IEX call
                  )IS

------------------------------
-- DECLARE Local variables
------------------------------

l_api_version               NUMBER DEFAULT 1.0;
l_init_msg_list             VARCHAR2(1) ;
l_return_status        VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data        VARCHAR2(2000);

l_type                      CONSTANT AR_ADJUSTMENTS.TYPE%TYPE := 'INVOICE';
l_created_from              CONSTANT AR_ADJUSTMENTS.CREATED_FROM%TYPE := 'ADJ-API';

l_adjsts_lns_id             OKL_TXL_ADJSTS_LNS_B.ID%TYPE;
l_new_adj_id                OKL_TXL_ADJSTS_LNS_B.RECEIVABLES_ADJUSTMENT_ID%TYPE;

l_payment_schedule_id       AR_ADJUSTMENTS.PAYMENT_SCHEDULE_ID%TYPE;
l_contract_number        OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
l_amount                    AR_ADJUSTMENTS.AMOUNT%TYPE;

l_receivables_trx_id        AR_ADJUSTMENTS.RECEIVABLES_TRX_ID%TYPE;
l_receivables_trx_name      AR_RECEIVABLES_TRX_ALL.NAME%TYPE;

l_code_combination_id       AR_ADJUSTMENTS.CODE_COMBINATION_ID%TYPE;
l_apply_date                AR_ADJUSTMENTS.APPLY_DATE%TYPE;
l_gl_date                   AR_ADJUSTMENTS.GL_DATE%TYPE;
l_adjustment_reason_code    AR_ADJUSTMENTS.REASON_CODE%TYPE;
l_comments                  AR_ADJUSTMENTS.COMMENTS%TYPE;

l_set_of_books_id           AR_ADJUSTMENTS.SET_OF_BOOKS_ID%TYPE DEFAULT NULL;

x_new_adj_number        AR_ADJUSTMENTS.ADJUSTMENT_NUMBER%TYPE;

l_org_id                    NUMBER DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();

------------------------------
-- DECLARE Record/Table Types
------------------------------

l_adj_rec                   ar_adjustments%rowtype;
l_ajlv_rec                  ajlv_rec_type;
x_ajlv_rec                  ajlv_rec_type;

l_ajlv_tbl                  okl_txl_adjsts_lns_pub.ajlv_tbl_type;
x_ajlv_tbl                  okl_txl_adjsts_lns_pub.ajlv_tbl_type;
l_counter                   NUMBER := 1;

------------------------------
-- DECLARE Exceptions
------------------------------


------------------------------
-- DECLARE Cursors
------------------------------

CURSOR c_get_receivables_trx_id (cp_set_of_books_id IN NUMBER) IS
SELECT RECEIVABLES_TRX_ID, NAME
FROM   ar_receivables_trx_all
WHERE  set_of_books_id = cp_set_of_books_id
AND    name = 'OKL Adjustment';


------------------------------

CURSOR c_get_cont_num(cp_psl_id IN NUMBER) IS
/*SELECT DISTINCT(contract_number)
FROM   okl_bpd_leasing_payment_trx_v
WHERE  payment_schedule_id = cp_psl_id; */ -- Bug 6358836
select distinct ractrl.interface_line_attribute6
from   ra_customer_trx_lines_all ractrl,
       ar_payment_schedules_all aps
where  aps.customer_trx_id = ractrl.customer_trx_id
and    ractrl.line_type = 'LINE'
and    aps.payment_schedule_id = cp_psl_id;

------------------------------

l_is_cons_inv     VARCHAR2(1) := 'N';
l_psl_id          NUMBER;
l_is_cons_invoice VARCHAR2(1);
l_commit_flag VARCHAR2(3) := p_commit_flag;
l_chk_approval_limits       VARCHAR2(3) := p_chk_approval_limits;
l_llca_adj_trx_lines_tbl          ar_adjust_pub.llca_adj_trx_line_tbl_type;
l_llca_adj_create_tbl_type        ar_adjust_pub.llca_adj_create_tbl_type;

l_adj_hdr_tbl l_adj_hdr_tbl_type;
l_adj_lines_tbl l_adj_lines_tbl_type;
l_customer_trx_id       ra_customer_trx_all.customer_trx_id%type;
l_customer_trx_line_id  ra_customer_trx_lines_all.customer_trx_line_id%type;

BEGIN
    l_set_of_books_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;
    l_psl_id := p_psl_id;

    OPEN  c_get_receivables_trx_id(l_set_of_books_id);
    FETCH c_get_receivables_trx_id INTO l_receivables_trx_id, l_receivables_trx_name;
    CLOSE c_get_receivables_trx_id;

    IF l_receivables_trx_id IS NULL THEN

        -- Message Text: Invalid receivables transaction
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME
                            ,p_msg_name      =>'OKL_BPD_RECV_ACTVTY_NOT_SET'
                           );

        --RAISE G_EXCEPTION_HALT_VALIDATION; --bug 6727171
        RAISE OKL_API.G_EXCEPTION_ERROR; -- bug 6727171
    END IF;

    get_adj_header_and_lines (p_api_version   => l_api_version
                             ,p_init_msg_list => l_init_msg_list
                             ,p_psl_id        => l_psl_id
                             ,x_return_status => l_return_status
                             ,x_msg_count     => l_msg_count
                             ,x_msg_data      => l_msg_data
                             ,x_adj_hdr_tbl => l_adj_hdr_tbl
                             ,x_adj_lines_tbl => l_adj_lines_tbl);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    l_is_cons_invoice := 'N';
    IF l_adj_hdr_tbl.COUNT > 0 THEN
      FOR i IN l_adj_hdr_tbl.FIRST..l_adj_hdr_tbl.LAST
      LOOP
        l_adj_lines_tbl := l_adj_hdr_tbl(i).lines;
      	l_is_cons_invoice := l_adj_hdr_tbl(i).cons_invoice;

        IF l_adj_lines_tbl.COUNT > 0 THEN
      	  IF l_is_cons_invoice = 'Y' THEN
            l_apply_date := l_adj_lines_tbl(1).apply_date;
            l_gl_date := l_adj_lines_tbl(1).gl_date;
            l_adjustment_reason_code := l_adj_lines_tbl(1).adjustment_reason_code;
            l_comments := l_adj_lines_tbl(1).comments;
            l_adjsts_lns_id := l_adj_lines_tbl(1).adjsts_lns_id;
            l_payment_schedule_id := l_adj_lines_tbl(1).payment_schedule_id;
            l_amount := l_adj_lines_tbl(1).amount;
            l_code_combination_id := l_adj_lines_tbl(1).code_combination_id;

            l_adj_rec.type                := l_type;
            l_adj_rec.created_from        := l_created_from;
            l_adj_rec.apply_date          := l_apply_date;
            l_adj_rec.gl_date             := l_gl_date;
            l_adj_rec.reason_code         := l_adjustment_reason_code;
            l_adj_rec.comments            := l_comments;
            l_adj_rec.payment_schedule_id := l_payment_schedule_id;
            l_adj_rec.amount              := (l_amount * -1);
            l_adj_rec.code_combination_id := l_code_combination_id;
            l_adj_rec.receivables_trx_id  := l_receivables_trx_id;
          ELSE --if it is regular R12 AR invoice
            l_apply_date := l_adj_lines_tbl(1).apply_date;
            l_gl_date := l_adj_lines_tbl(1).gl_date;
            l_adjustment_reason_code := l_adj_lines_tbl(1).adjustment_reason_code;
            l_comments := l_adj_lines_tbl(1).comments;
            l_payment_schedule_id := l_adj_lines_tbl(1).payment_schedule_id;
            l_code_combination_id := l_adj_lines_tbl(1).code_combination_id;
            l_customer_trx_id := l_adj_lines_tbl(1).customer_trx_id;
            l_customer_trx_line_id := l_adj_lines_tbl(1).customer_trx_line_id;

            l_adj_rec.type                := 'LINE';
            l_adj_rec.created_from        := l_created_from;
            l_adj_rec.apply_date          := l_apply_date;
            l_adj_rec.gl_date             := l_gl_date;
            l_adj_rec.reason_code         := l_adjustment_reason_code;
            l_adj_rec.comments            := l_comments;
            l_adj_rec.payment_schedule_id := l_payment_schedule_id;
            l_adj_rec.customer_trx_id     := l_customer_trx_id;
            l_adj_rec.ussgl_transaction_code  := NULL;
            l_adj_rec.code_combination_id := l_code_combination_id;
            l_adj_rec.receivables_trx_id  := null;

            l_llca_adj_trx_lines_tbl.delete;
            l_amount := 0;

            For j in l_adj_lines_tbl.FIRST..l_adj_lines_tbl.LAST
            LOOP
              l_llca_adj_trx_lines_tbl(j).customer_trx_line_id:=l_adj_lines_tbl(j).customer_trx_line_id;
              l_llca_adj_trx_lines_tbl(j).line_amount:= (-1)*l_adj_lines_tbl(j).amount;
              l_llca_adj_trx_lines_tbl(j).receivables_trx_id:=l_receivables_trx_id;
              l_amount := l_amount + l_adj_lines_tbl(j).amount;

              l_ajlv_tbl(l_counter).id := l_adj_lines_tbl(j).adjsts_lns_id;
              l_counter := l_counter + 1;
            END LOOP;
          END IF;
	      END IF;

        LOOP
            IF l_gl_date IS NULL THEN
                l_gl_date := SYSDATE;
            END IF;

            IF l_apply_date IS NULL OR l_adjustment_reason_code IS NULL OR
               l_payment_schedule_id IS NULL OR l_amount IS NULL THEN

              -- Missing mandatory fields for cash application process
              OKC_API.set_message( p_app_name      => G_APP_NAME
                                  ,p_msg_name      => 'OKL_BPD_ADJUST_MAN'
                                  ,p_token1        => 'APPLY_DATE'
                                  ,p_token1_value  => l_apply_date
                                  ,p_token2        => 'ADJUSTMENT_REASON_CODE'
                                  ,p_token2_value  => l_adjustment_reason_code
                                  ,p_token3        => 'PAYMENT_SCHEDULE_ID'
                                  ,p_token3_value  => l_payment_schedule_id
                                  ,p_token4        => 'AMOUNT'
                                  ,p_token4_value  => l_amount
                                  ,p_token5        => 'RECEIVABLES_TRX_ID'
                                  ,p_token5_value  => l_receivables_trx_id
                                  );
              EXIT; -- move to next record.
            END IF;

            -- Start of wraper code generated automatically
            -- by Debug code generator for AR_ADJUST_PUB.CREATE_ADJUSTMENT
            IF(L_DEBUG_ENABLED='Y') THEN
              L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
              IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
            END IF;
            IF(IS_DEBUG_PROCEDURE_ON) THEN
              BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLROCAB.pls call AR_ADJUST_PUB.CREATE_ADJUSTMENT  ');
              END;
            END IF;

            IF l_is_cons_invoice = 'Y' THEN
              AR_ADJUST_PUB.CREATE_ADJUSTMENT ( p_api_name           => 'AR_ADJUST_PUB'
                                               ,p_api_version        => 1.0
                                               ,p_msg_count          => l_msg_count
                                               ,p_msg_data           => l_msg_data
                                               ,p_return_status      => l_return_status
                                               ,p_adj_rec            => l_adj_rec
                                               ,p_commit_flag         => l_commit_flag
                                               ,p_chk_approval_limits => l_chk_approval_limits
                                               ,p_new_adjust_number  => x_new_adj_number
                                               ,p_new_adjust_id      => x_new_adj_id
                                              );
            ELSE
              AR_ADJUST_PUB.CREATE_LINELEVEL_ADJUSTMENT
              ( p_api_name            => 'AR_ADJUST_PUB'
               ,p_api_version         => 1.0
               ,p_msg_count           => l_msg_count
               ,p_msg_data            => l_msg_data
               ,p_return_status       => l_return_status
               ,p_adj_rec             => l_adj_rec
               ,p_commit_flag         => l_commit_flag
               ,p_chk_approval_limits => l_chk_approval_limits
               ,p_check_amount => 'F'
               ,p_llca_adj_trx_lines_tbl  =>   l_llca_adj_trx_lines_tbl
               ,p_move_deferred_tax   => 'Y'
               ,p_llca_adj_create_tbl_type => l_llca_adj_create_tbl_type
               ,p_called_from   => 'OKL-ADJ'
               ,p_old_adjust_id       => null
              );
              IF l_llca_adj_create_tbl_type.COUNT > 0 THEN
               IF l_llca_adj_create_tbl_type.exists(l_llca_adj_create_tbl_type.LAST) THEN
                 x_new_adj_id := l_llca_adj_create_tbl_type(l_llca_adj_create_tbl_type.LAST).adjustment_id;
               END IF;
              END IF;
            END IF;
            IF(IS_DEBUG_PROCEDURE_ON) THEN
              BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLROCAB.pls call AR_ADJUST_PUB.CREATE_ADJUSTMENT  ');
              END;
            END IF;
            -- End of wraper code generated automatically by Debug code generator for AR_ADJUST_PUB.CREATE_ADJUSTMENT

            OPEN  c_get_cont_num(l_payment_schedule_id);
            FETCH c_get_cont_num INTO l_contract_number;
            CLOSE c_get_cont_num;

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) OR
               (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

                OKC_API.set_message( p_app_name      => G_APP_NAME
                                    ,p_msg_name      => 'OKL_BPD_NO_ADJUST_CREATED'
                                    ,p_token1        => 'CONTRACT_NUMBER'
                                    ,p_token1_value  => l_contract_number
                                    ,p_token2        => 'AMOUNT'
                                    ,p_token2_value  => l_amount
                                   );
                EXIT;
            ELSE
                OKC_API.set_message( p_app_name      => G_APP_NAME
                                    ,p_msg_name      => 'OKL_BPD_ADJUST_CREATED'
                                    ,p_token1        => 'CONTRACT_NUMBER'
                                    ,p_token1_value  => l_contract_number
                                    ,p_token2        => 'AMOUNT'
                                    ,p_token2_value  => l_amount
                                   );
            END IF;

            For j in l_ajlv_tbl.FIRST..l_ajlv_tbl.LAST
            LOOP
              l_new_adj_id := x_new_adj_id;
              l_ajlv_tbl(j).receivables_adjustment_id := l_new_adj_id;
            END LOOP;

            -- Start of wraper code generated automatically by Debug code generator for OKL_TXL_ADJSTS_LNS_PUB.UPDATE_TXL_ADJSTS_LNS
            IF(IS_DEBUG_PROCEDURE_ON) THEN
              BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLROCAB.pls call OKL_TXL_ADJSTS_LNS_PUB.UPDATE_TXL_ADJSTS_LNS ');
              END;
            END IF;
            OKL_TXL_ADJSTS_LNS_PUB.UPDATE_TXL_ADJSTS_LNS(l_api_version
                                ,l_init_msg_list
                                ,l_return_status
                                ,l_msg_count
                                ,l_msg_data
                                ,l_ajlv_tbl
                                ,x_ajlv_tbl);
            IF(IS_DEBUG_PROCEDURE_ON) THEN
              BEGIN
                OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLROCAB.pls call OKL_TXL_ADJSTS_LNS_PUB.UPDATE_TXL_ADJSTS_LNS ');
              END;
            END IF;
            -- End of wraper code generated automatically by Debug code generator for OKL_TXL_ADJSTS_LNS_PUB.UPDATE_TXL_ADJSTS_LNS

            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            EXIT;
        END LOOP;
      END LOOP;
    END IF;

    x_return_status := l_return_status;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := sqlerrm ;

END create_adjustments;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              iex_create_adjustments                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              This is the main routine to create an adjustment in AR       |
 |              specifically for IEX guys.                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_api_name                                              |
 |                   p_api_version                                           |
 |                   p_init_msg_list                                         |
 |                   p_commit_flag                                           |
 |                   p_psl_id                                                |
 |                   p_chk_approval_limits                                   |
 |            : OUT:                                                         |
 |                   x_new_adj_id                                            |
 |                   x_return_status                                         |
 |                   x_msg_count                         |
 |             x_msg_data                                         |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |    Bruno Vaghela  09-OCT-02  Created                                      |
 |    varao     19-SEP-05  Addressed bug 4505226                             |
 |    varao     11-NOV-05  Addressed bug 4728481                             |
 |    varao     17-NOV-05  Addressed bug 4622198                             |
 +===========================================================================*/


PROCEDURE iex_create_adjustments   ( p_api_version       IN  NUMBER
                      ,p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                                    ,p_commit_flag         IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                    ,p_psl_id              IN  NUMBER
                                    ,p_chk_approval_limits IN  VARCHAR2 DEFAULT OKL_API.G_TRUE
                                    ,x_new_adj_id          OUT NOCOPY NUMBER
                                    ,x_return_status       OUT NOCOPY VARCHAR2
                                    ,x_msg_count       OUT NOCOPY NUMBER
                                    ,x_msg_data           OUT NOCOPY VARCHAR2
                                   )IS

------------------------------
-- DECLARE Local variables
------------------------------

l_api_version               NUMBER DEFAULT 1.0;
l_init_msg_list             VARCHAR2(1) ;
l_return_status        VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data        VARCHAR2(2000);

l_type                      CONSTANT AR_ADJUSTMENTS.TYPE%TYPE := 'INVOICE';
l_created_from              CONSTANT AR_ADJUSTMENTS.CREATED_FROM%TYPE := 'ADJ-API';

l_adjsts_lns_id             OKL_TXL_ADJSTS_LNS_B.ID%TYPE;
l_new_adj_id                OKL_TXL_ADJSTS_LNS_B.RECEIVABLES_ADJUSTMENT_ID%TYPE;

l_payment_schedule_id       AR_ADJUSTMENTS.PAYMENT_SCHEDULE_ID%TYPE;
l_contract_number        OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL;
l_amount                    AR_ADJUSTMENTS.AMOUNT%TYPE;

l_receivables_trx_id        AR_ADJUSTMENTS.RECEIVABLES_TRX_ID%TYPE;
l_receivables_trx_name      AR_RECEIVABLES_TRX_ALL.NAME%TYPE;

l_code_combination_id       AR_ADJUSTMENTS.CODE_COMBINATION_ID%TYPE;
l_apply_date                AR_ADJUSTMENTS.APPLY_DATE%TYPE;
l_gl_date                   AR_ADJUSTMENTS.GL_DATE%TYPE;
l_adjustment_reason_code    AR_ADJUSTMENTS.REASON_CODE%TYPE;
l_comments                  AR_ADJUSTMENTS.COMMENTS%TYPE;

l_chk_approval_limits       VARCHAR2(3);
l_commit_flag    VARCHAR2(3);

l_set_of_books_id           AR_ADJUSTMENTS.SET_OF_BOOKS_ID%TYPE DEFAULT NULL;

l_org_id                    NUMBER DEFAULT MO_GLOBAL.GET_CURRENT_ORG_ID();
-- 19-Sep-05 varao bug 4505226 Start
l_pdt_id                    NUMBER := 0;
l_try_id NUMBER := NULL;

l_acc_gen_primary_key_tbl   OKL_ACCOUNT_DIST_PUB.acc_gen_primary_key;

-- 19-Sep-05 varao bug 4505226 End

------------------------------
-- DECLARE Record/Table Types
------------------------------

l_adjv_rec                  adjv_rec_type;
x_adjv_rec                  adjv_rec_type;
l_ajlv_rec                  ajlv_rec_type;
x_ajlv_rec                  ajlv_rec_type;
l_ajlv_new_rec              ajlv_rec_type;

------------------------------
-- DECLARE Exceptions
------------------------------


------------------------------
-- DECLARE Cursors
------------------------------

CURSOR c_get_receivables_trx_id (cp_set_of_books_id IN NUMBER) IS
SELECT RECEIVABLES_TRX_ID, NAME
FROM   ar_receivables_trx_all
WHERE  set_of_books_id = cp_set_of_books_id
AND    name = 'OKL Adjustment';


------------------------------

-- 19-Sep-05 varao bug 4505226 Start

/* Commented since this cursor is not used now
CURSOR c_get_cont_num(cp_psl_id IN NUMBER) IS
SELECT DISTINCT(contract_number)
FROM   okl_bpd_leasing_payment_trx_v
WHERE  payment_schedule_id = cp_psl_id;
*/
------------------------------

-- Cursor to get the details for a payment schedule id
/* Bug 6727171 Start
CURSOR c_pmnt_schedule_dtls(cp_psl_id IN NUMBER) IS
SELECT OBLP.amount_due_remaining        AMOUNT_DUE_REMAINING,
        OBLP.stream_type_id             STREAM_TYPE_ID,
        OBLP.contract_line_id             CONTRACT_LINE_ID,
        OBLP.stream_name                STREAM_NAME,
        OBLP.contract_id                CONTRACT_ID,
        OBLP.contract_number            CONTRACT_NUMBER,
        OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
        OBLP.currency_code              CURRENCY_CODE,
        OTIL.id                         TIL_ID,
        -999                            TLD_ID
FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
        OKL_TXL_AR_INV_LNS_B          OTIL
WHERE  OBLP.payment_schedule_id     = cp_psl_id
AND    OBLP.receivables_invoice_id  = OTIL.receivables_invoice_id
AND    oblp.stream_type_id          = otil.sty_id   --added by dkagrawa for performance
AND    OBLP.amount_due_remaining > 0
UNION
SELECT OBLP.amount_due_remaining        AMOUNT_DUE_REMAINING,
        OBLP.stream_type_id             STREAM_TYPE_ID,
OBLP.contract_line_id             CONTRACT_LINE_ID,
        OBLP.stream_name                STREAM_NAME,
        OBLP.contract_id                CONTRACT_ID,
        OBLP.contract_number            CONTRACT_NUMBER,
        OBLP.receivables_invoice_number AR_INVOICE_NUMBER,
        OBLP.currency_code              CURRENCY_CODE,
        OTAI.til_id_details             TIL_ID,
        OTAI.id                         TLD_ID
FROM   OKL_BPD_LEASING_PAYMENT_TRX_V  OBLP,
        OKL_TXD_AR_LN_DTLS_B          OTAI
WHERE  OBLP.payment_schedule_id     = cp_psl_id
AND    OBLP.receivables_invoice_id  = OTAI.receivables_invoice_id
AND    oblp.stream_type_id          = otai.sty_id  --added by dkagrawa for performance
AND    OBLP.amount_due_remaining > 0;

Bug 6727171 End */

--Bug 6727171 Start

CURSOR c_pmnt_schedule_dtls(cp_psl_id IN NUMBER) IS
SELECT    RACTRL.AMOUNT_DUE_REMAINING       AMOUNT_DUE_REMAINING,
          RACTRL.STY_ID                     STREAM_TYPE_ID,
          RACTRL.KLE_ID                     CONTRACT_LINE_ID,
          RACTRL.KHR_ID                     CONTRACT_ID,
          RACTRL.CONTRACT_NUMBER            CONTRACT_NUMBER,
          RACTRL.CUSTOMER_TRX_ID            AR_INVOICE_NUMBER,
          RACTRL.STREAM_TYPE                STREAM_NAME,
          OKL_AM_UTIL_PVT.get_chr_currency(RACTRL.KHR_ID) CURRENCY_CODE,
          RACTRL.til_id_details             TIL_ID,
          RACTRL.TLD_ID                     TLD_ID
   FROM   OKL_BPD_TLD_AR_LINES_V     RACTRL,
          AR_PAYMENT_SCHEDULES_ALL   APS
   WHERE  APS.PAYMENT_SCHEDULE_ID = cp_psl_id
   AND    RACTRL.CUSTOMER_TRX_ID  = APS.CUSTOMER_TRX_ID
   AND    RACTRL.amount_due_remaining > 0;

--Bug 6727171 End

CURSOR c_pmnt_schedule_summary(cp_psl_id IN NUMBER) IS
SELECT    SUM(RACTRL.AMOUNT_DUE_REMAINING)       AMOUNT_DUE_REMAINING
   FROM   OKL_BPD_TLD_AR_LINES_V     RACTRL,
          AR_PAYMENT_SCHEDULES_ALL   APS
   WHERE  APS.PAYMENT_SCHEDULE_ID = cp_psl_id
   AND    RACTRL.CUSTOMER_TRX_ID  = APS.CUSTOMER_TRX_ID
   AND    RACTRL.amount_due_remaining > 0;


c_pmnt_schedule_dtls_rec c_pmnt_schedule_dtls%ROWTYPE;

l_total_amt_due_remaining NUMBER;

------------------------------

-- Cursor to get the product of the contract
CURSOR c_prod_id(cp_khr_id IN NUMBER) IS
SELECT   KHR.pdt_id
FROM     OKL_K_HEADERS_V KHR
WHERE    KHR.id = cp_khr_id;

------------------------------

-- Cursor to get the distribution for the transaction id and
-- transaction table
-- Make sure we get the debit distribution and also it is 100percent
CURSOR c_code_combination_id(cp_source_id    IN NUMBER,
                             cp_source_table IN VARCHAR2) IS
SELECT DST.code_combination_id
FROM   OKL_TRNS_ACC_DSTRS DST
WHERE  DST.source_id = cp_source_id
AND    DST.source_table = cp_source_table
AND    DST.cr_dr_flag = 'D'
AND    DST.percentage = 100;

------------------------------

-- Get transaction id for 'Adjustments' trx type
CURSOR c_try_id (cp_try_name IN VARCHAR2) IS
 SELECT id
 FROM okl_trx_types_tl t
 WHERE   UPPER (t.name)= UPPER (cp_try_name);

------------------------------
-- 19-Sep-05 varao bug 4505226 End

-- Code added by varao for bug #4728481 - START
  CURSOR get_psl_context IS
    SELECT org_id
    FROM   ar_payment_schedules_all
    WHERE  payment_schedule_id = p_psl_id;
-- Code added by varao for bug #4728481 - END

 --Bug 6316320 dpsingh start
       l_tmpl_identify_tbl          Okl_Account_Dist_Pvt.tmpl_identify_tbl_type;
       l_dist_info_tbl              Okl_Account_Dist_Pvt.dist_info_tbl_type;
       l_ctxt_tbl                   Okl_Account_Dist_Pvt.CTXT_TBL_TYPE;
       l_acc_gen_tbl                Okl_Account_Dist_Pvt.ACC_GEN_TBL_TYPE;
       l_template_out_tbl           Okl_Account_Dist_Pvt.avlv_out_tbl_type;
       l_amount_out_tbl             Okl_Account_Dist_Pvt.amount_out_tbl_type;
       l_account_derivation OKL_SYS_ACCT_OPTS.ACCOUNT_DERIVATION%TYPE;

   CURSOR get_account_derivation_meth IS
   SELECT ACCOUNT_DERIVATION
   FROM OKL_SYS_ACCT_OPTS;
 --Bug 6316320 dpsingh end

  -- Bug 7138249 start
  l_functional_currency_code VARCHAR2(15);
  l_currency_code             VARCHAR2(200);
  l_contract_currency_code   VARCHAR2(15);
  l_currency_conversion_type VARCHAR2(30);
  l_currency_conversion_rate NUMBER;
  l_currency_conversion_date DATE;
  l_converted_amount NUMBER;
  l_trans_meaning             VARCHAR2(200);
  -- Bug 7138249 end

BEGIN

    -- Code added by varao for bug #4728481 - START
    OPEN  get_psl_context;
    FETCH get_psl_context INTO l_org_id;
    CLOSE get_psl_context;
    -- Code added by varao for bug #4728481 - END

    l_set_of_books_id := Okl_Accounting_Util.GET_SET_OF_BOOKS_ID;

    l_commit_flag := p_commit_flag;
    l_payment_schedule_id := p_psl_id;
    l_chk_approval_limits := p_chk_approval_limits;

    OPEN  c_get_receivables_trx_id(l_set_of_books_id);
    FETCH c_get_receivables_trx_id INTO l_receivables_trx_id, l_receivables_trx_name;
    CLOSE c_get_receivables_trx_id;

    IF l_receivables_trx_id IS NULL THEN
        -- Message Text: Invalid receivables transaction
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message( p_app_name      => G_APP_NAME
                            ,p_msg_name      =>'OKL_BPD_RECV_ACTVTY_NOT_SET'
                            );

        --RAISE G_EXCEPTION_HALT_VALIDATION; -- bug 6727171
        RAISE OKL_API.G_EXCEPTION_ERROR; -- bug 6727171
    END IF;

    -- 19-Sep-05 varao bug 4505226 Start
    --Get amount due remaining for payment schedule
    OPEN c_pmnt_schedule_summary(p_psl_id);
    FETCH c_pmnt_schedule_summary INTO l_total_amt_due_remaining;
    CLOSE c_pmnt_schedule_summary;

    IF l_total_amt_due_remaining IS NOT NULL AND l_total_amt_due_remaining <> 0 THEN

  -- Create adjusment header record in okl_trx_ar_adjsts_b
      l_adjv_rec.adjustment_reason_code:= 'WRITE OFF';
      l_adjv_rec.apply_date := SYSDATE;
      l_adjv_rec.gl_date    := SYSDATE;
      l_adjv_rec.trx_status_code := 'WORKING';
      --Bug 6316320 dpsingh start
      -- Get the transaction id for 'Adjustments' trx type
      OPEN c_try_id('Adjustments');
      FETCH c_try_id INTO l_try_id;
      CLOSE c_try_id;

      IF l_try_id IS NULL THEN
          OKL_API.set_message(p_app_name       => G_APP_NAME,
                              p_msg_name       => 'OKL_AM_NO_TRX_TYPE_FOUND',
                              p_token1         => 'TRY_NAME',
                              p_token1_value   => 'Adjustments');
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_adjv_rec.try_id :=l_try_id;
      --Bug 6316320 dpsingh end
      okl_trx_ar_adjsts_pub.insert_trx_ar_adjsts(
             p_api_version              => l_api_version
            ,p_init_msg_list            => l_init_msg_list
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
            ,p_adjv_rec                 => l_adjv_rec
            ,x_adjv_rec                 => x_adjv_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message( p_app_name      => G_APP_NAME,
                                p_msg_name      => 'OKL_AM_ERR_ADJST_BAL');
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get the payment schedule details
      OPEN  c_pmnt_schedule_dtls(p_psl_id);
      LOOP
        FETCH c_pmnt_schedule_dtls INTO c_pmnt_schedule_dtls_rec;
        EXIT WHEN c_pmnt_schedule_dtls%NOTFOUND;

      -- Create adjusment line record in okl_txl_adjsts_lns_b
      l_ajlv_rec.adj_id := x_adjv_rec.id;
      l_ajlv_rec.psl_id := p_psl_id;
      l_ajlv_rec.amount := c_pmnt_schedule_dtls_rec.amount_due_remaining;
      l_ajlv_rec.til_id := c_pmnt_schedule_dtls_rec.til_id;

      IF  c_pmnt_schedule_dtls_rec.tld_id <> -999
        AND c_pmnt_schedule_dtls_rec.tld_id IS NOT NULL
        AND c_pmnt_schedule_dtls_rec.tld_id <> OKL_API.G_MISS_NUM THEN
              l_ajlv_rec.tld_id   :=   c_pmnt_schedule_dtls_rec.tld_id;
      END IF;

      -- Bug 7138249 start
      -- Get the functional currency from AM_Util
      l_functional_currency_code := OKL_AM_UTIL_PVT.get_functional_currency;

      -- Get the contract currency code
      l_currency_code := OKL_AM_UTIL_PVT.get_chr_currency(
                                  c_pmnt_schedule_dtls_rec.contract_id);

      l_trans_meaning := OKL_AM_UTIL_PVT.get_lookup_meaning(
                                  p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                  p_lookup_code=> 'ADJUSTMENTS',
                                  p_validate_yn => 'Y');
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
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

      OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id           => c_pmnt_schedule_dtls_rec.contract_id,
                     p_to_currency      => l_functional_currency_code,
                     p_transaction_date => SYSDATE,
                     p_amount  => c_pmnt_schedule_dtls_rec.amount_due_remaining,
                     x_return_status    => l_return_status,
                     x_contract_currency         => l_contract_currency_code,
                     x_currency_conversion_type  => l_currency_conversion_type,
                     x_currency_conversion_rate  => l_currency_conversion_rate,
                     x_currency_conversion_date  => l_currency_conversion_date,
                     x_converted_amount => l_converted_amount);
      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
              OKL_API.set_message(
                           p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_ERR_ACC_ENT',
                           p_token1        => 'TRX_TYPE',
                           p_token1_value  => l_trans_meaning);

              IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                       'OKL_CREATE_ADJST_PVT.write_off_balances.',
                       'currency_conv_error = '||l_return_status );
              END IF;

              RAISE OKL_API.G_EXCEPTION_ERROR;

      END IF;

      -- Bug 7138249 end

      --Bug 6316320 dpsingh start
      l_ajlv_rec.khr_id := c_pmnt_schedule_dtls_rec.contract_id;
      l_ajlv_rec.sty_id := c_pmnt_schedule_dtls_rec.stream_type_id;
      l_ajlv_rec.kle_id := c_pmnt_schedule_dtls_rec.contract_line_id ;
      --Bug 6316320 dpsingh end
      okl_txl_adjsts_lns_pub.insert_txl_adjsts_lns(
             p_api_version              => l_api_version
            ,p_init_msg_list            => l_init_msg_list
            ,x_return_status            => l_return_status
            ,x_msg_count                => l_msg_count
            ,x_msg_data                 => l_msg_data
            ,p_ajlv_rec                 => l_ajlv_rec
            ,x_ajlv_rec                 => x_ajlv_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            OKL_API.set_message( p_app_name     => G_APP_NAME,
                                 p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get the product id
      OPEN  c_prod_id(c_pmnt_schedule_dtls_rec.contract_id);
      FETCH c_prod_id INTO l_pdt_id;
      CLOSE c_prod_id;

      l_contract_number := c_pmnt_schedule_dtls_rec.contract_number;

      IF l_pdt_id IS NULL OR l_pdt_id = 0 THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_AM_PRODUCT_ID_ERROR',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => l_contract_number);
             RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Do accounting entries to get code_combination_id
      -- Set the tmpl_identify_rec in parameter
      l_tmpl_identify_tbl(1).product_id  := l_pdt_id;
      l_tmpl_identify_tbl(1).transaction_type_id := l_try_id;
      l_tmpl_identify_tbl(1).memo_yn  :=  G_NO;
      l_tmpl_identify_tbl(1).prior_year_yn  := G_NO;
      l_tmpl_identify_tbl(1).stream_type_id := c_pmnt_schedule_dtls_rec.stream_type_id;

      -- Set the dist_info_rec in parameter
       l_dist_info_tbl(1).source_id  := x_ajlv_rec.id;
       l_dist_info_tbl(1).source_table  := 'OKL_TXL_ADJSTS_LNS_B';
       l_dist_info_tbl(1).accounting_date := SYSDATE;
       l_dist_info_tbl(1).gl_reversal_flag := G_NO;
       l_dist_info_tbl(1).post_to_gl  := G_NO;
       l_dist_info_tbl(1).contract_id := c_pmnt_schedule_dtls_rec.contract_id;
       l_dist_info_tbl(1).amount := c_pmnt_schedule_dtls_rec.amount_due_remaining;
       l_dist_info_tbl(1).currency_code := c_pmnt_schedule_dtls_rec.currency_code;
      -- Bug 7138249 start
       IF l_functional_currency_code <> l_contract_currency_code THEN
         l_dist_info_tbl(1).currency_conversion_type := l_currency_conversion_type;
         l_dist_info_tbl(1).currency_conversion_rate := l_currency_conversion_rate;
         l_dist_info_tbl(1).currency_conversion_date := l_currency_conversion_date;
       END IF;
      -- Bug 7138249 end


      OKL_ACC_CALL_PVT.okl_populate_acc_gen (
                p_contract_id       => c_pmnt_schedule_dtls_rec.contract_id,
                p_contract_line_id  => NULL,
                x_acc_gen_tbl       => l_acc_gen_primary_key_tbl,
                x_return_status     => l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

       l_acc_gen_tbl(1).acc_gen_key_tbl := l_acc_gen_primary_key_tbl;
       l_acc_gen_tbl(1).source_id :=  x_ajlv_rec.id;

      -- 19-Sep-05 varao bug 4622198 Start
      Okl_Securitization_Pvt.check_khr_ia_associated(
                                             p_api_version    => l_api_version
                                                ,p_init_msg_list  => l_init_msg_list
                                                ,x_return_status  => l_return_status
                                                ,x_msg_count      => l_msg_count
                                                ,x_msg_data       => l_msg_data
                                                ,p_khr_id         => c_pmnt_schedule_dtls_rec.contract_id
                                                ,p_scs_code       => NULL
                                                ,p_trx_date       => sysdate
                                                ,x_fact_synd_code => l_tmpl_identify_tbl(1).FACTORING_SYND_FLAG
                                                ,x_inv_acct_code  => l_tmpl_identify_tbl(1).INVESTOR_CODE);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- 19-Sep-05 varao bug 4622198 End

      -- Call accounting engine
      -- This will calculate the adjstmnts and generate accounting entries
     Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
                                  p_api_version        => l_api_version,
                                  p_init_msg_list      => l_init_msg_list,
                                  x_return_status      => l_return_status,
                                  x_msg_count          => l_msg_count,
                                  x_msg_data           => l_msg_data,
                                  p_tmpl_identify_tbl  => l_tmpl_identify_tbl,
                                  p_dist_info_tbl      => l_dist_info_tbl,
                                  p_ctxt_val_tbl       => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl       => l_template_out_tbl,
                                  x_amount_tbl         => l_amount_out_tbl,
                                  p_trx_header_id      => x_adjv_rec.id,
                                  p_trx_header_table  =>'OKL_TRX_AR_ADJSTS_B');

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
               OKL_API.set_message( p_app_name      => G_APP_NAME,
                                    p_msg_name      => 'OKL_AM_ERR_ACC_ENT_MSG',
                                    p_token1        => 'TRX_TYPE',
                                    p_token1_value  => 'Adjustments',
                                    p_token2        => 'STREAM_TYPE',
                                    p_token2_value  => c_pmnt_schedule_dtls_rec.stream_name);
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN  get_account_derivation_meth;
             FETCH get_account_derivation_meth INTO l_account_derivation;
             CLOSE get_account_derivation_meth;

      IF l_account_derivation = 'ATS' THEN
      -- Get the code_combination_id for the transaction
      OPEN  c_code_combination_id(x_ajlv_rec.id, 'OKL_TXL_ADJSTS_LNS_B');
      FETCH c_code_combination_id INTO l_code_combination_id;
      CLOSE c_code_combination_id;

      IF l_code_combination_id = -1 OR l_code_combination_id IS NULL THEN
          OKL_API.set_message( p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_AM_CODE_CMB_ERROR',
                               p_token1       => 'CONTRACT_NUMBER',
                               p_token1_value => l_contract_number);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Update adjusment line record in okl_txl_adjsts_lns_b with CCID
      l_ajlv_rec := l_ajlv_new_rec; -- Empty the rec

      -- Set the rec with CCID got from accounting distibutions
      l_ajlv_rec.id  := x_ajlv_rec.id;
      l_ajlv_rec.code_combination_id  :=  l_code_combination_id;

      x_ajlv_rec := l_ajlv_new_rec; -- Empty the rec

      OKL_TXL_ADJSTS_LNS_PUB.update_txl_adjsts_lns(
                p_api_version      => l_api_version,
                p_init_msg_list    => l_init_msg_list,
                x_return_status    => l_return_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_ajlv_rec           => l_ajlv_rec,
                x_ajlv_rec           => x_ajlv_rec);

      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
          OKL_API.set_message( p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_AM_ERR_ADJST_BAL');
      END IF;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
      -- 19-Sep-05 varao bug 4505226 End
    END LOOP;

      --Now create adjustments through AR
      --Call create_adjustments API with l_payment_schedule_id as parameter
      create_adjustments   ( p_api_version         => l_api_version
                            ,p_init_msg_list       => l_init_msg_list
                            ,p_psl_id              => l_payment_schedule_id
                            ,p_commit_flag         => l_commit_flag
                            ,p_chk_approval_limits => l_chk_approval_limits
                            ,x_new_adj_id          => l_new_adj_id
                            ,x_return_status       => l_return_status
                            ,x_msg_count           => l_msg_count
                            ,x_msg_data            => l_msg_data
                            );

      x_return_status := l_return_status;
      x_new_adj_id := l_new_adj_id;

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSE

      Okl_api.set_message( p_app_name      => g_app_name
                         , p_msg_name      => 'OKL_NO_RECORD' ) ;
      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

EXCEPTION

   --Added snizam
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
    --End snizam

    WHEN OTHERS THEN
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

END iex_create_adjustments;

END OKL_CREATE_ADJST_PVT;

/
