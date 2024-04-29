--------------------------------------------------------
--  DDL for Package Body OKL_PERIOD_SWEEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PERIOD_SWEEP_PVT" AS
/* $Header: OKLRSWPB.pls 120.13.12010000.3 2008/11/13 05:55:43 racheruv ship $ */

--- This procedure creates report. It is called from the main procedure

PROCEDURE CREATE_REPORT(l_start_date    IN DATE,
                        l_end_date      IN DATE,
                        l_mode          IN VARCHAR2,
                        p_period_from   IN VARCHAR2,
                        p_period_to     IN VARCHAR2,
                        l_to_start_date IN DATE,
                        p_ledger_id     IN VARCHAR2)
IS

CURSOR acct_csr(p_gl_date_from  DATE,
                p_gl_date_to    DATE)
IS
 SELECT DISTINCT dstrs.SOURCE_ID,
                 dstrs.SOURCE_TABLE,
                 dstrs.GL_DATE
   FROM OKL_TRNS_ACC_DSTRS dstrs,XLA_EVENTS xle
  WHERE dstrs.GL_DATE BETWEEN p_gl_date_from AND p_gl_date_to
    AND dstrs.SET_OF_BOOKS_ID = p_ledger_id
    AND dstrs.ACCOUNTING_EVENT_ID =xle.EVENT_ID
    AND xle.EVENT_STATUS_CODE IN ('I','U')
  ORDER BY GL_DATE;

acct_rec acct_csr%ROWTYPE;

--Cursors to fetch the information to be printed on the report
-- Changed by Santonyr on 02 Apr 2004
-- Changed okl_trx_types_tl to okl_trx_types_v in the cursor
-- select statement as it retrives the records with other languages too

CURSOR tcn_csr (p_source_id NUMBER) IS
SELECT khr.contract_number,
       try.name  trx_type,
       sty.name stream_type,
       tcn.trx_number,
       tcn.date_transaction_occurred,
       tcl.line_number,
       tcl.amount line_amount
FROM okl_trx_contracts_all tcn,
     okl_txl_cntrct_lns_all tcl,
     okl_strm_type_tl sty,
     okl_trx_types_v try,
     okc_k_headers_all_b khr
WHERE tcl.id = p_source_id
AND   tcn.id = tcl.tcn_id
AND   tcl.sty_id = sty.id(+)
AND   tcn.try_id = try.id
AND   khr.id = tcn.khr_id
--added by rkuttiya for MultiGAAP Project
AND   tcn.set_of_books_id = p_ledger_id;

-- Changed by Santonyr on 02 Apr 2004
-- Changed okl_trx_types_tl to okl_trx_types_v in the cursor
-- select statement as it retrives the records with other languages too

--rkuttiya commented out following cursor for MultiGAAP Project
--no longer needed
/* CURSOR tas_csr(p_source_id NUMBER) IS
SELECT khr.contract_number,
       try.name trx_type,
       tas.trans_number,
       tas.date_trans_occurred,
       tal.line_number,
       tal.original_cost line_amount
FROM okl_trx_assets tas,
     okl_txl_assets_b tal,
     okl_trx_types_v try,
     okc_k_headers_all_b khr
WHERE tal.id = p_source_id
AND   tas.id = tal.tas_id
AND   tas.try_id = try.id
AND   khr.id = tal.dnz_khr_id;
*/


tcn_rec    tcn_csr%ROWTYPE;

--rkuttiya commented out following for Multigaap Project
--tas_rec    tas_csr%ROWTYPE;
l_ledger_name  VARCHAR2(30);

BEGIN

      l_ledger_name := OKL_ACCOUNTING_UTIL.get_set_of_books_name (p_ledger_id);
     INSERT INTO OKL_G_REPORTS_GT(VALUE1_TEXT,VALUE2_TEXT,VALUE1_DATE)
     VALUES('HEADER' ,l_ledger_name, l_to_start_date);

    FOR acct_rec IN acct_csr(l_start_date,l_end_date)
    LOOP
      IF acct_rec.source_table = 'OKL_TXL_CNTRCT_LNS' THEN
        OPEN tcn_csr(acct_rec.source_id);
        FETCH tcn_csr INTO tcn_rec;
        IF (tcn_csr%FOUND) THEN
           INSERT INTO
           OKL_G_REPORTS_GT(VALUE1_TEXT,
                            VALUE2_TEXT,
                            VALUE3_TEXT,
                            VALUE4_TEXT,
                            VALUE5_TEXT,
                            VALUE1_DATE,
                            VALUE1_NUM,
                            VALUE2_NUM,
                            VALUE2_DATE)
                     VALUES('LINES',
                            tcn_rec.contract_number,
                            tcn_rec.trx_type,
                            tcn_rec.stream_type,
                            tcn_rec.trx_number,
                            tcn_rec.date_transaction_occurred,
                            tcn_rec.line_number,
                            tcn_rec.line_amount,
                            acct_rec.gl_date);
        END IF;
      CLOSE tcn_csr;
    END IF;

--rkuttiya commented out following code for MultiGAAP Project
-- no longer needed
/*
     IF acct_rec.source_table = 'OKL_TXL_ASSETS_B'  THEN
          OPEN tas_csr(acct_rec.source_id);
          FETCH tas_csr INTO tas_rec;
          IF (tas_csr%FOUND) THEN
          INSERT INTO OKL_G_REPORTS_GT(VALUE1_TEXT,
                                       VALUE2_TEXT,
                                       VALUE3_TEXT,
                                       VALUE4_TEXT,
                                       VALUE5_TEXT,
                                       VALUE1_DATE,
                                       VALUE1_NUM,
                                       VALUE2_NUM,
                                       VALUE2_DATE)
                                VALUES('LINES',
                                       tas_rec.contract_number,
                                       tas_rec.trx_type,
                                       null,
                                       tas_rec.trans_number,
                                       tas_rec.date_trans_occurred,
                                       tas_rec.line_number,
                                       tas_rec.line_amount,
                                       acct_rec.gl_date);
        END IF;
      CLOSE tas_csr;
    END IF;
*/

  END LOOP;
END CREATE_REPORT;



--- This is the main procedure for sweep process. It takes four arguments. If run option
--- is 'REPORT ONLY' then it only generates report, otherwise it does both processing and
--- generates report

PROCEDURE OKL_PERIOD_SWEEP (p_errbuf               OUT NOCOPY VARCHAR2,
                            p_retcode              OUT NOCOPY NUMBER,
                            p_representation_code  IN  VARCHAR2,
                            p_period_from          IN VARCHAR2,
                            p_period_to            IN VARCHAR2,
                            p_run_option           IN VARCHAR2)
IS

 l_tabv_tbl           OKL_TRNS_ACC_DSTRS_PUB.TABV_TBL_TYPE;
 x_tabv_tbl           OKL_TRNS_ACC_DSTRS_PUB.TABV_TBL_TYPE;
 l_aetv_tbl           OKL_ACCT_EVENT_PUB.aetv_tbl_type;
 x_aetv_tbl           OKL_ACCT_EVENT_PUB.aetv_tbl_type;
 l_aehv_tbl           OKL_ACCT_EVENT_PUB.aehv_tbl_type;
 x_aehv_tbl           OKL_ACCT_EVENT_PUB.aehv_tbl_type;


 i                    NUMBER:=0;
 j                    NUMBER:=0;
 k                    NUMBER:=0;
 l_end_date           DATE;
 l_start_date         DATE;
 l_to_start_date      DATE;
 l_to_end_date        DATE;
 l_return_status      VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_api_version        NUMBER := 1.0;
 l_init_msg_list      VARCHAR2(1);
 l_msg_count          NUMBER ;
 l_msg_data           VARCHAR2(2000);
 l_period_status      VARCHAR2(1);
 l_event_id           NUMBER := -99;

 TYPE update_event_rec IS RECORD (
      tcn_id          NUMBER,
      event_id        NUMBER,
      accrual_reversal_date DATE,
      trx_type_class VARCHAR2(30));

 l_api_name           VARCHAR2(30) := 'OKL_PERIOD_SWEEP';
 x_msg_count          NUMBER;
 x_msg_data           VARCHAR2(2000);
 x_return_status      VARCHAR2(1);
 l_ledger_id          NUMBER;

 TYPE l_tcn_tbl_type IS TABLE OF update_event_rec INDEX BY BINARY_INTEGER;
 l_tcn_tbl l_tcn_tbl_type;

 x_tcnv_rec           OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;
 l_tcnv_rec           OKL_TRX_CONTRACTS_PUB.tcnv_rec_type;

 CURSOR dist_csr(p_ledger_id    NUMBER,
                 p_gl_date_from DATE,
                 p_gl_date_to   DATE)
 IS
 SELECT dstrs.ID,dstrs.ACCOUNTING_EVENT_ID,dstrs.SOURCE_ID
   FROM OKL_TRNS_ACC_DSTRS dstrs,XLA_EVENTS xle
  WHERE dstrs.GL_DATE BETWEEN p_gl_date_from AND p_gl_date_to
    AND dstrs.SET_OF_BOOKS_ID = p_ledger_id
    AND dstrs.ACCOUNTING_EVENT_ID =xle.EVENT_ID
    AND xle.EVENT_STATUS_CODE IN ('I','U')
  ORDER BY ACCOUNTING_EVENT_ID;

 CURSOR get_tcn_info(p_txl_id NUMBER,
                     p_ledger_id NUMBER) IS
 SELECT TCN.ID,
        TCN.ACCRUAL_REVERSAL_DATE,
        TRY.TRX_TYPE_CLASS
   FROM OKL_TXL_CNTRCT_LNS_ALL TXL ,
        OKL_TRX_CONTRACTS_ALL TCN,
        OKL_TRX_TYPES_B TRY
  WHERE TXL.ID = p_txl_id AND
        TXL.TCN_ID = TCN.ID AND
        TCN.TRY_ID = TRY.ID
        --rkuttiya added for Multi GAAP Project
        AND TCN.SET_OF_BOOKS_ID = p_ledger_id;

 CURSOR get_accrual_reversal_date(p_ledger_id NUMBER,p_accrual_date Date) IS
 SELECT end_date +1 accrual_reversal_date
   FROM gl_period_statuses
  WHERE application_id = 540
    AND set_of_books_id =p_ledger_id
    AND p_accrual_date BETWEEN start_date AND end_date;

 --rkuttiya added for MUltiGAAP Project
 CURSOR c_ledger_id(p_representation_code IN VARCHAR2) IS
 SELECT ledger_id
   FROM okl_representations_v
  WHERE representation_code = p_representation_code;

BEGIN
 p_retcode:=1;

 l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                           l_init_msg_list,
                                           '_PVT',
                                           x_return_status);

    if (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) then
      raise Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = Okl_Api.G_RET_STS_ERROR) then
      raise Okl_Api.G_EXCEPTION_ERROR;
    end if;

 --rkuttiya added  for MUlti GAAP Project
  IF p_representation_code IS NULL THEN
        OKL_API.set_message('OKC',
                             G_REQUIRED_VALUE,
                             G_COL_NAME_TOKEN,
                             'Representation Code');
        RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  --rkuttiya commenting out the following code for MultiGAAP Project
  --Bug 6017242
  --l_ledger_id  := OKL_ACCOUNTING_UTIL.get_set_of_books_id;
  --Bug 6017242

  OPEN  c_ledger_id(p_representation_code);
  FETCH c_ledger_id INTO l_ledger_id;
  CLOSE c_ledger_id;

  OKL_ACCOUNTING_UTIL.get_period_info(p_period_name => p_period_from,
                                      p_start_date  => l_start_date,
                                      p_end_date    => l_end_date,
                                      --Bug 5707866 SLA Uptake Project
                                      p_ledger_id => l_ledger_id);

/*
 --Bug 5707866 SLA Uptake Project
 l_period_status := OKL_ACCOUNTING_UTIL.GET_OKL_PERIOD_STATUS(p_ledger_id => l_ledger_id,
                                                              p_period_name => p_period_to);

 IF (l_period_status NOT IN ('O','F')) THEN
     OKL_API.set_message(p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_PERIOD_NOT_OPEN',
                         p_token1        => 'PERIOD_NAME',
                         p_token1_value  => p_period_to);
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
--Bug 5707866  end
*/

  OKL_ACCOUNTING_UTIL.get_period_info(p_period_name => p_period_to,
                                      p_start_date  => l_to_start_date,
                                      p_end_date    => l_to_end_date,
                                      --Bug 5707866 SLA Uptake Project
                                      p_ledger_id => l_ledger_id);

 --Bug 5707866 SLA Uptake Project

 CREATE_REPORT(l_start_date,l_end_date,p_run_option,p_period_from,p_period_to,l_to_start_date,l_ledger_id);

  IF UPPER(p_run_option)= 'RUN' THEN
     j := 0;
     FOR dist_rec IN dist_csr(l_ledger_id,l_start_date,l_end_date)
     LOOP
       l_tabv_tbl(i).id      := dist_rec.id;
       l_tabv_tbl(i).gl_date := l_to_start_date;
       IF(l_event_id <>dist_rec.accounting_event_id) THEN
         l_event_id := dist_rec.accounting_event_id;
         l_tcn_tbl(j).event_id := l_event_id;
         OPEN get_tcn_info(dist_rec.source_id,l_ledger_id);
         FETCH get_tcn_info into l_tcn_tbl(j).tcn_id,l_tcn_tbl(j).accrual_reversal_date,l_tcn_tbl(j).trx_type_class;
         CLOSE get_tcn_info;
         j := j+1;
       END IF;
       i := i +1;
     END LOOP;

      IF (l_tabv_tbl.COUNT > 0) THEN
          OKL_TRNS_ACC_DSTRS_PUB.update_trns_acc_dstrs(p_api_version  => l_api_version,
                                                       p_init_msg_list   => l_init_msg_list,
                                                       x_return_status   => l_return_status,
                                                       x_msg_count       => l_msg_count,
                                                       x_msg_data        => l_msg_data,
                                                       p_tabv_tbl        => l_tabv_tbl,
                                                       x_tabv_tbl        => x_tabv_tbl);
     END IF;
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     j :=0;
     IF (l_tcn_tbl.COUNT > 0) THEN
       FOR j in l_tcn_tbl.FIRST..l_tcn_tbl.LAST LOOP
          OKL_XLA_EVENTS_PVT.update_event(p_api_version   =>l_api_version
                                         ,p_init_msg_list =>l_init_msg_list
                                         ,x_return_status =>l_return_status
                                         ,x_msg_count     =>l_msg_count
                                         ,x_msg_data      =>l_msg_data
                                         ,p_gl_date       =>l_to_start_date
                                         ,p_event_id      =>l_tcn_tbl(j).event_id
                                         ,p_tcn_id        =>l_tcn_tbl(j).tcn_id);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

       IF l_tcn_tbl(j).trx_type_class = 'ACCRUAL' AND  l_tcn_tbl(j).accrual_reversal_date IS NOT NULL THEN
         l_tcnv_rec.id := l_tcn_tbl(j).tcn_id;
         OPEN get_accrual_reversal_date(l_ledger_id, l_to_start_date);
         FETCH get_accrual_reversal_date into l_tcnv_rec.accrual_reversal_date;
         CLOSE get_accrual_reversal_date;
         Okl_Trx_Contracts_Pub.update_trx_contracts(p_api_version => l_api_version,
                                                    p_init_msg_list => l_init_msg_list,
                                                    x_return_status => l_return_status,
                                                    x_msg_count => l_msg_count,
                                                    x_msg_data => l_msg_data,
                                                    p_tcnv_rec => l_tcnv_rec,
                                                    x_tcnv_rec => x_tcnv_rec);

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     END LOOP;
   END IF;
END IF;

Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status :=  Okl_Api.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OKl_API.G_RET_STS_ERROR',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT'
                                                     );

    WHEN OTHERS THEN
       p_errbuf := SQLERRM;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       x_return_status :=  Okl_Api.HANDLE_EXCEPTIONS(l_api_name,
                                                     G_PKG_NAME,
                                                     'OKl_API.G_RET_STS_ERROR',
                                                     x_msg_count,
                                                     x_msg_data,
                                                     '_PVT'
                                                     );
END OKL_PERIOD_SWEEP;



PROCEDURE OKL_PERIOD_SWEEP_CON(p_init_msg_list       IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
                              ,x_return_status       OUT NOCOPY VARCHAR2
                              ,x_msg_count           OUT NOCOPY NUMBER
                              ,x_msg_data            OUT NOCOPY VARCHAR2
                              ,p_representation_code IN VARCHAR2 DEFAULT NULL
                              ,p_period_from         IN VARCHAR2
                              ,p_period_to           IN VARCHAR2
                              ,p_run_option          IN VARCHAR2
                              ,x_request_id          OUT NOCOPY NUMBER)

IS

  l_api_name VARCHAR2(30) := 'OKL_PERIOD_SWEEP_CON';
  l_api_version    NUMBER := 1.0;
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_from_date       VARCHAR2(20) ;
  l_start_date_from DATE;
  l_start_date_to  DATE;
  l_end_date_from  DATE;
  l_end_date_to    DATE;
  l_period_status VARCHAR2(1);
  l_to_period gl_periods.period_name%TYPE;
  l_to_date        DATE;

  CURSOR perd_csr(p_date DATE,
                  p_ledger_id IN NUMBER)
  IS
  SELECT MIN(start_date)
  FROM gl_period_statuses
  WHERE application_id = 540
  AND ledger_id = p_ledger_id
  AND closing_status IN ('F','O')
  AND start_date > p_date
  AND adjustment_period_flag = 'N' ;

-- rkuttiya 05-AUG-2008 added for Multi GAAP Project

  CURSOR c_ledger_id(p_representation_code IN VARCHAR2)
  IS
  SELECT ledger_id
  FROM okl_representations_v
  WHERE representation_code = p_representation_code;

  CURSOR c_representation_code(p_representation_type IN VARCHAR2)
  IS
  SELECT representation_code
  FROM okl_representations_v
  WHERE representation_type = p_representation_type;

  l_representation_code    VARCHAR2(20);
  l_ledger_id              NUMBER;

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

-- rkuttiya 05-Aug-2008 MultiGAAP Project
  l_representation_code := p_representation_code;

  IF p_representation_code IS NULL THEN
    OPEN c_representation_code('PRIMARY');
    FETCH c_representation_code INTO l_representation_code;
    CLOSE c_representation_code;
  END IF;

  OPEN c_ledger_id(l_representation_code);
  FETCH c_ledger_id INTO l_ledger_id;
  CLOSE c_ledger_id;
--rkuttiya end

  IF (p_period_from IS NULL) THEN
      OKL_API.set_message('OKC', G_REQUIRED_VALUE, G_COL_NAME_TOKEN,
                           okl_accounting_util.get_message_token('OKL_LP_SWEEP_PROGRAM','OKL_TRANSFER_FROM_PERIOD')
                            );
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_period_status := OKL_ACCOUNTING_UTIL.GET_OKL_PERIOD_STATUS(p_period_from
                                                               ,l_ledger_id);

  IF (l_period_status IS NULL) THEN
     OKL_API.set_message(p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_PERIOD_NOT_FOUND',
                         p_token1        => 'PERIOD_NAME',
                         p_token1_value  => p_period_from);

     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_period_status NOT IN ('O')) THEN
     OKL_API.set_message(p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_PERD_INVALID_STATUS',
                         p_token1        => 'PERIOD',
                         p_token1_value  => p_period_from);

     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OKL_ACCOUNTING_UTIL.get_period_info(p_period_from, l_start_date_from,l_end_date_from,l_ledger_id);

  IF (p_period_to IS NOT NULL) AND (p_period_to <> OKL_API.G_MISS_CHAR) THEN
     OKL_ACCOUNTING_UTIL.get_period_info(p_period_to, l_start_date_to, l_end_date_to, l_ledger_id);
     IF (l_start_date_to IS NULL) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_PERIOD_NOT_FOUND',
                             p_token1        => 'PERIOD_NAME',
                             p_token1_value  => p_period_to);

         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     l_to_period := p_period_to;
  ELSE
     OPEN perd_csr(l_start_date_from,l_ledger_id);
     FETCH perd_csr INTO l_to_date;
     CLOSE perd_csr;
     IF (l_to_date IS NULL) THEN
        OKL_API.set_message('OKC', G_REQUIRED_VALUE, G_COL_NAME_TOKEN,'To Period');
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     OKL_ACCOUNTING_UTIL.get_period_info(l_to_date, l_to_period, l_start_date_to, l_end_date_to,l_ledger_id);
  END IF;

  l_period_status := NULL;
  l_period_status := OKL_ACCOUNTING_UTIL.GET_OKL_PERIOD_STATUS(l_to_period
                                                              ,l_ledger_id);
  IF (l_period_status NOT IN ('O','F')) THEN
     OKL_API.set_message(p_app_name      => G_APP_NAME,
                         p_msg_name      => 'OKL_PERIOD_NOT_OPEN',
                         p_token1        => 'PERIOD_NAME',
                         p_token1_value  => l_to_period);

     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OKL_ACCOUNTING_UTIL.get_period_info(l_to_period, l_start_date_to,l_end_date_to,l_ledger_id);

  IF (l_start_date_to <= l_start_date_from) THEN
     OKL_API.set_message(p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_TO_PERIOD_LATER');
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF (p_run_option IS NULL) THEN
      OKL_API.set_message('OKC', G_REQUIRED_VALUE, G_COL_NAME_TOKEN,'Run Option');
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


 --- Call to okl gl transfer concurrent program

  FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
  x_request_id := Fnd_Request.SUBMIT_REQUEST(application => 'OKL'
                                            ,program     => 'OKLPDSWP'
                                            ,argument1   => p_representation_code
                                            ,argument2   => p_period_from
                                            ,argument3   => l_to_period
                                            ,argument4   => p_run_option);

    IF x_request_id = 0 THEN
       OKL_API.set_message(p_app_name => 'OFA',
                                          p_msg_name => 'FA_DEPRN_TAX_ERROR',
                                          p_token1   => 'REQUEST_ID',
                                          p_token1_value  => x_request_id);

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

END OKL_PERIOD_SWEEP_CON;

-------------------------------------------------------------------------------
  -- Function BEFOREREPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : BEFOREREPORT
  -- Description     : Function for Period Sweep Report Generation
  --                        in XML Publisher
  -- Business Rules  :
  -- Parameters      : p_period_from,p_period_to,p_run_option
  -- Version         : 1.0
  -- History         : 06-Feb-2007 DPSINGH created.
  -- End of comments
  -------------------------------------------------------------------------------
FUNCTION BEFOREREPORT RETURN BOOLEAN
IS
p_errbuf VARCHAR2(150);
p_retcode NUMBER;
BEGIN

OKL_PERIOD_SWEEP (p_errbuf ,
                  p_retcode,
                  p_representation_code => p_representation_code,
                  p_period_from =>p_period_from,
                  p_period_to =>p_period_to,
                  p_run_option =>p_run_option);

IF p_retcode = 1 THEN
  RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;
END BEFOREREPORT;
END OKL_PERIOD_SWEEP_PVT;

/
