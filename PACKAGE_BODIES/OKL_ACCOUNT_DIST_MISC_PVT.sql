--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_DIST_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_DIST_MISC_PVT" AS
/* $Header: OKLRTDSB.pls 120.2 2006/07/11 10:04:37 dkagrawa noship $ */

-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.TRANSACTIONS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

PROCEDURE POPULATE_DSTR_REC(p_tabv_rec       IN   TABV_REC_TYPE,
                            x_tabv_rec       OUT  NOCOPY TABV_REC_TYPE,
                            p_mode	     IN   VARCHAR2)

IS

  l_curr_code           OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;
  l_currency_conversion_date OKL_TRNS_ACC_DSTRS.currency_conversion_date%TYPE;
  l_currency_conversion_rate OKL_TRNS_ACC_DSTRS.currency_conversion_rate%TYPE;
  l_currency_conversion_type OKL_TRNS_ACC_DSTRS.currency_conversion_type%TYPE;


  l_date_transaction_occurred  DATE;

-- Chnaged by Santonyr on 25-Nov-2002
-- Multi-Currency Changes. Get the currency conversion
-- factors from transaction table.

  CURSOR tcn_csr(v_source_id NUMBER) IS
  SELECT trunc(date_transaction_occurred),
  	 currency_code,
  	 currency_conversion_date,
  	 currency_conversion_rate,
  	 currency_conversion_type
  FROM OKL_TRX_CONTRACTS
  WHERE ID IN (SELECT TCN_ID
               FROM OKL_TXL_CNTRCT_LNS
               WHERE ID = v_source_id);

BEGIN

-- Commented out by Santonyr on 25-Nov-2002 for MUlti Currency Changes
-- Get the currency conversion factors from transaction table.

/*

-- since we are only supporting One Currency this phase,
-- Equate the Accounted Amount to Amount
-- Equate the currency code to the functional Currency
-- Wiil need change when multiple currencies are to be supported


  l_curr_code := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;
*/

x_tabv_rec   := p_tabv_rec;

  OPEN tcn_csr(p_tabv_rec.source_id);
  FETCH tcn_csr INTO
  	l_date_transaction_occurred,
  	l_curr_code,
  	l_currency_conversion_date,
  	l_currency_conversion_rate,
  	l_currency_conversion_type;
  CLOSE tcn_csr;

IF p_mode = 'I' THEN

  x_tabv_rec.amount               	    := Okl_Accounting_Util.ROUND_AMOUNT
                                               (p_amount        => p_tabv_rec.amount,
                                               p_currency_code  => l_curr_code);

  x_tabv_rec.accounted_amount               := Okl_Accounting_Util.ROUND_AMOUNT
                                               (p_amount        => (p_tabv_rec.amount * NVL(l_currency_conversion_rate, 1)),
                                               p_currency_code  => l_curr_code);

-- Fixed bug 2559862

  IF (x_tabv_rec.cr_dr_flag = 'D') THEN
     x_tabv_rec.AE_LINE_TYPE           := 'LEASE_DEBIT';
  END IF;
  IF (x_tabv_rec.cr_dr_flag = 'C') THEN
     x_tabv_rec.AE_LINE_TYPE           := 'LEASE_CREDIT';
  END IF;

  x_tabv_rec.currency_code                  := l_curr_code;
  x_tabv_rec.post_to_gl                     := 'Y';
  x_tabv_rec.original_dist_id               := NULL;
  x_tabv_rec.reverse_event_flag             := 'N';
  x_tabv_rec.gl_reversal_flag               := 'N';
  x_tabv_rec.posted_yn                      := 'N';
  x_tabv_rec.percentage                     := NULL;
  x_tabv_rec.currency_conversion_date       := l_currency_conversion_date;
  x_tabv_rec.currency_conversion_rate       := l_currency_conversion_rate;
  x_tabv_rec.currency_conversion_type       := l_currency_conversion_type;

   -- Added by HKPATEL for default date for bug 3254298
    l_date_transaction_occurred := OKL_ACCOUNTING_UTIL.get_valid_gl_date(l_date_transaction_occurred);

        IF l_date_transaction_occurred IS NULL THEN
             OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => 'OKL_INVALID_GL_DATE');
             RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
    -- Added code ends here

  x_tabv_rec.gl_date                        := l_date_transaction_occurred;

ELSE

-- Fixed bug 2559862

  IF (x_tabv_rec.cr_dr_flag = 'D') THEN
     x_tabv_rec.AE_LINE_TYPE           := 'LEASE_DEBIT';
  END IF;
  IF (x_tabv_rec.cr_dr_flag = 'C') THEN
     x_tabv_rec.AE_LINE_TYPE           := 'LEASE_CREDIT';
  END IF;

  x_tabv_rec.amount               	    := Okl_Accounting_Util.ROUND_AMOUNT
                                               (p_amount        => p_tabv_rec.amount,
                                               p_currency_code  => l_curr_code);

  x_tabv_rec.accounted_amount               := Okl_Accounting_Util.ROUND_AMOUNT
                                               (p_amount        => (p_tabv_rec.amount * NVL(l_currency_conversion_rate, 1)),
                                               p_currency_code  => l_curr_code);

END IF;

END POPULATE_DSTR_REC;



-- Function to check if the distributions have gone to Accounting SubLedger or GL

FUNCTION  CHECK_DIST(p_source_id            IN          NUMBER,
                     p_source_table         IN          VARCHAR2)

RETURN NUMBER


IS

  l_posted_yn           VARCHAR2(1);
  l_gl_transfer_flag    VARCHAR2(1);

  CURSOR dist_csr(v_source_id NUMBER,
                  v_source_table VARCHAR2) IS
  SELECT POSTED_YN
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;


  CURSOR aeh_csr(v_source_id NUMBER,
                 v_source_table VARCHAR2) IS

  SELECT gl_transfer_flag
  FROM OKL_AE_HEADERS aeh, OKL_ACCOUNTING_EVENTS aet
  WHERE  aeh.accounting_event_id = aet.accounting_event_id
  AND    aet.source_id    = v_source_id
  AND    aet.source_table = v_source_table;

BEGIN

  OPEN dist_csr(p_source_id, p_source_table);
  FETCH dist_csr INTO l_posted_yn;
  IF (dist_csr%NOTFOUND) THEN -- Distributions do not exist
     CLOSE dist_csr;
     RETURN 0;
  END IF;
  CLOSE dist_csr;

  IF (l_posted_yn = 'N') THEN  -- Distributions exist and are not posted to AE
     RETURN 1;
  ELSIF (l_posted_yn = 'Y') THEN -- Posted
     OPEN aeh_csr(p_source_id, p_source_table);
     FETCH aeh_csr INTO l_gl_transfer_flag;
     CLOSE aeh_csr;
     IF (l_gl_transfer_flag <> 'N') THEN
         RETURN 3;  -- Gone to GL
     ELSE
         RETURN 2; -- Not Gone to GL
     END IF;
  END IF;

END CHECK_DIST;



--Procedure to delete the lines from the Distribution Table and the AE tables in case of an updation

PROCEDURE  DELETE_DIST_AE(p_flag          IN VARCHAR2,
                          p_source_id     IN NUMBER,
                          p_source_table  IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2)

IS

  CURSOR dist_csr(v_source_id  NUMBER, v_source_table VARCHAR2) IS
  SELECT ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;

  CURSOR aet_csr(v_source_id NUMBER, v_source_table VARCHAR2) IS
  SELECT accounting_event_id
  FROM OKL_ACCOUNTING_EVENTS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;

  l_dist_tbl      TABV_TBL_TYPE;
  l_aetv_rec      OKL_ACCT_EVENT_PUB.AETV_REC_TYPE;
  i               NUMBER := 0;
  l_api_version   NUMBER := 1.0;
  l_init_msg_list VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count     NUMBER := 0;
  l_msg_data      VARCHAR2(2000);
  l_id            NUMBER;
  l_aet_id        NUMBER;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  IF (p_flag = 'DIST') THEN

      OPEN dist_csr(p_source_id, p_source_table);
      LOOP
        FETCH dist_csr INTO  l_id;
        EXIT WHEN dist_csr%NOTFOUND;
        i := i + 1;
        l_dist_tbl(i).ID := l_id;
      END LOOP;

      CLOSE dist_csr;

      IF (l_dist_tbl.COUNT > 0) THEN

-- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRMSCB.pls call Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs ');
    END;
  END IF;
           Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs(p_api_version     => l_api_version
                                                       ,p_init_msg_list   => l_init_msg_list
                                                       ,x_return_status   => x_return_status
                                                       ,x_msg_count       => l_msg_count
                                                       ,x_msg_data        => l_msg_data
                                                       ,p_tabv_tbl        => l_dist_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRMSCB.pls call Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs

      END IF;


  END IF;


  IF (p_flag = 'AE') THEN

     OPEN  aet_csr(p_source_id, p_source_table);
     FETCH aet_csr INTO l_aet_id;
     CLOSE aet_csr;

     l_aetv_rec.accounting_event_ID  := l_aet_id;

-- Start of wraper code generated automatically by Debug code generator for Okl_Acct_Event_Pub.delete_acct_event
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRMSCB.pls call Okl_Acct_Event_Pub.delete_acct_event ');
    END;
  END IF;
     Okl_Acct_Event_Pub.delete_acct_event(p_api_version     => l_api_version
                                         ,p_init_msg_list   => l_init_msg_list
                                         ,x_return_status   => x_return_status
                                         ,x_msg_count       => l_msg_count
                                         ,x_msg_data        => l_msg_data
                                         ,p_aetv_rec        => l_aetv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRMSCB.pls call Okl_Acct_Event_Pub.delete_acct_event ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Acct_Event_Pub.delete_acct_event


  END IF;

END DELETE_DIST_AE;



-- Added by Santonyr to fix the bug 2557421 on 17th Jan, 2003

PROCEDURE validate_line_amount(p_tabv_tbl	IN TABV_TBL_TYPE,
		    			       x_return_status	OUT NOCOPY VARCHAR2)

IS

l_total_cr_amount	NUMBER := 0;
l_total_dr_amount	NUMBER := 0;
l_line_amount		OKL_TXL_CNTRCT_LNS.AMOUNT%TYPE;
i					NUMBER := 0;

CURSOR lineAmount_csr(v_source_id NUMBER) IS
    SELECT amount
    FROM OKL_TXL_CNTRCT_LNS
    WHERE ID = v_source_id;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_tabv_tbl.COUNT
  LOOP
     IF (p_tabv_tbl(i).CR_DR_FLAG = 'C') THEN
        l_total_cr_amount := l_total_cr_amount + NVL(p_tabv_tbl(i).AMOUNT, 0);
     ELSE
        l_total_dr_amount := l_total_dr_amount + NVL(p_tabv_tbl(i).AMOUNT, 0);
	 END IF;
  END LOOP;


IF (NVL(l_total_cr_amount, 0) <> NVL(l_total_dr_amount, 0)) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name       => 'OKL_AMT_DR_CR_UNEQUAL');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;

END IF;


  OPEN lineAmount_csr(p_tabv_tbl(1).source_id);
  FETCH lineAmount_csr INTO
    	l_line_amount;
  CLOSE lineAmount_csr;



IF ( NVL(l_line_amount, 0) <> NVL(l_total_cr_amount,0)) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                             ,p_msg_name       => 'OKL_TXL_AMT_NE_DSTR_AMT');
          x_return_status    := Okc_Api.G_RET_STS_ERROR;

END IF;


END VALIDATE_LINE_AMOUNT;



PROCEDURE insert_updt_dstrs(p_api_version         IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_tabv_tbl            IN  tabv_tbl_type,
                            x_tabv_tbl            OUT NOCOPY tabv_tbl_type)

IS

  l_api_version         NUMBER := 1.0;
  l_api_name            VARCHAR2(30) := 'INSERT_UPDT_DSTRS';
  l_total_cr_amount     NUMBER := 0;
  l_total_acc_cr_amount NUMBER := 0;
  l_total_dr_amount     NUMBER := 0;
  l_total_acc_dr_amount NUMBER := 0;
  l_tabv_rec_out        TABV_REC_TYPE;
  l_tabv_rec		TABV_REC_TYPE;
  l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_check_status        NUMBER;
  l_source_table        OKL_TRNS_ACC_DSTRS.source_table%TYPE := 'OKL_TXL_CNTRCT_LNS';

-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

  l_tcn_id OKL_TRX_CONTRACTS.ID%TYPE;
  l_tsu_code OKL_TRX_CONTRACTS.TSU_CODE%TYPE;

  CURSOR tcl_csr(v_source_id NUMBER) IS
  SELECT tcn_id
  FROM OKL_TXL_CNTRCT_LNS
  WHERE ID = v_source_id;

  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT tsu_code
  FROM OKL_TRX_CONTRACTS
  WHERE ID = v_tcn_id;


BEGIN

  l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                            G_PKG_NAME,
                                            p_init_msg_list,
                                            l_api_version,
                                            p_api_version,
                                            '_PVT',
                                            x_return_status);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

-- Added by Santonyr to fix the bug 3089327 on 07th Aug, 2003

   OPEN tcl_csr(p_tabv_tbl(1).source_id);
   FETCH tcl_csr INTO l_tcn_id;
   CLOSE tcl_csr;

   OPEN tcn_csr(l_tcn_id);
   FETCH tcn_csr INTO l_tsu_code;
   CLOSE tcn_csr;

   IF (l_tsu_code = 'CANCELED') THEN

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TRX_CANCELED');

      RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;


  -- Added by Santonyr to fix the bug 2557421 on 17th Jan, 2003

  validate_line_amount(p_tabv_tbl	  	=> p_tabv_tbl,
  			       	   x_return_status	=> l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--Validation to check if the transactions have been transferred to GL.If so they cannot be updated

    l_check_status := CHECK_DIST(p_source_id     => p_tabv_tbl(1).source_id,
                                 p_source_table  => l_source_table);

    IF (l_check_status = 1)  OR (l_check_status = 2) THEN
            -- Delete from Distributions
              DELETE_DIST_AE(p_flag          => 'DIST',
                             p_source_id     => p_tabv_tbl(1).source_id,
                             p_source_table  => l_source_table,
                             x_return_status => l_return_status);



    END IF;

    IF (l_check_status = 2)  THEN
           -- delete from AE
             DELETE_DIST_AE(p_flag          => 'AE',
                            p_source_id     => p_tabv_tbl(1).source_id,
                            p_source_table  => l_source_table,
                            x_return_status => l_return_status);

             IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

    END IF;


    IF (l_check_status = 3) THEN
              OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_AE_GONE_TO_GL');
              RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



  FOR i IN 1..p_tabv_tbl.COUNT

  LOOP
            POPULATE_DSTR_REC(p_tabv_rec      => p_tabv_tbl(i),
                               x_tabv_rec      => l_tabv_rec_out,
                               p_mode	   => 'I');

            OKL_TRNS_ACC_DSTRS_PUB.insert_trns_acc_dstrs(p_api_version       => l_api_version,
                                                      p_init_msg_list     => p_init_msg_list,
                                                      x_return_status     => l_return_status,
                                                      x_msg_count         => x_msg_count,
                                                      x_msg_data          => x_msg_data,
                                                      p_tabv_rec          => l_tabv_rec_out,
                                                      x_tabv_rec          => x_tabv_tbl(i) );

              IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

   END LOOP;


  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  x_return_status := l_return_status;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END insert_updt_dstrs;



END OKL_ACCOUNT_DIST_MISC_PVT;


/
