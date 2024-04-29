--------------------------------------------------------
--  DDL for Package Body OKL_MISC_TRANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MISC_TRANS_PVT" AS
/* $Header: OKLRMSCB.pls 120.7 2008/01/17 10:13:59 veramach noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.TRANSACTIONS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Function to check if the distributions have gone to Accounting or GL

-- Added by Santonyr on 26-Jul-2004 for the bug 3772490

SUBTYPE asev_rec_type IS Okl_Acct_Sources_Pvt.asev_rec_type;
SUBTYPE asev_tbl_type IS Okl_Acct_Sources_Pvt.asev_tbl_type;


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

-- Added by Santonyr on 26-Jul-2004 for the bug 3772490

  CURSOR src_csr(v_source_id  NUMBER, v_source_table VARCHAR2) IS
  SELECT ID
  FROM OKL_ACCT_SOURCES
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;

-- Added by Santonyr on 26-Jul-2004 for the bug 3772490

  l_asev_rec      ASEV_REC_TYPE;
  x_asev_rec      ASEV_REC_TYPE;


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


   OPEN src_csr(p_source_id, p_source_table);
     FETCH src_csr INTO  l_id;
   CLOSE src_csr;

  l_asev_rec.ID :=l_id;

-- Start of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRTDTB.pls call Okl_Acct_Sources_Pvt.delete_acct_sources ');
    END;
  END IF;


   Okl_Acct_Sources_Pvt.delete_acct_sources (
                           p_api_version   => l_api_version
                          ,p_init_msg_list => l_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => l_msg_count
                          ,x_msg_data      => l_msg_data
                          ,p_asev_rec      => l_asev_rec);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRTDTB.pls call Okl_Acct_Sources_Pvt.delete_acct_sources ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Trns_Acc_Dstrs_Pub.delete_trns_acc_dstrs



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

-- Added by Santonyr on 03-Dec-2002
-- This procedure makes sure that the sum of transaction line
-- amount is not greater than transaction amount.


PROCEDURE Validate_Amount (p_tclv_rec           IN     tclv_rec_type,
			   p_mode		IN     VARCHAR2,
			   x_return_status      OUT    NOCOPY VARCHAR2)
IS

-- Cursor to fetch trx amount

CURSOR trx_amt_csr (l_trx_id NUMBER) IS
SELECT AMOUNT
FROM OKL_TRX_CONTRACTS
WHERE ID = l_trx_id;

-- Cursor to fetch trx line amount
CURSOR txl_amt_in_csr (l_trx_id NUMBER) IS
SELECT SUM(AMOUNT) SUM_AMOUNT
FROM OKL_TXL_CNTRCT_LNS
WHERE TCN_ID = l_trx_id;

-- Cursor to fetch trx line amount
CURSOR txl_amt_up_csr (l_trx_id NUMBER, l_txl_id NUMBER) IS
SELECT SUM(AMOUNT) SUM_AMOUNT
FROM OKL_TXL_CNTRCT_LNS
WHERE TCN_ID = l_trx_id AND
      ID <> l_txl_id;


l_trx_amt	NUMBER := 0;
l_sum_txl_amt   NUMBER := 0;

BEGIN

x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Fetch trx amount
FOR trx_amt_rec IN trx_amt_csr (p_tclv_rec.TCN_ID) LOOP
  l_trx_amt := NVL(trx_amt_rec.AMOUNT, 0);
END LOOP;

IF p_mode = 'I' THEN

-- Fetch trx line amount for insert mode

  FOR txl_amt_in_rec IN txl_amt_in_csr (p_tclv_rec.TCN_ID) LOOP
    l_sum_txl_amt := NVL(txl_amt_in_rec.SUM_AMOUNT, 0);
  END LOOP;

ELSE

-- Fetch trx line amount for update mode

  FOR txl_amt_up_rec IN txl_amt_up_csr (p_tclv_rec.TCN_ID, p_tclv_rec.ID) LOOP
    l_sum_txl_amt := NVL(txl_amt_up_rec.SUM_AMOUNT, 0);
  END LOOP;

END IF;

-- Return Error status if sum of trx line amount is greater than trx amount.

IF (l_sum_txl_amt + NVL(p_tclv_rec.AMOUNT, 0) )> l_trx_amt THEN
  x_return_status := OKL_API.G_RET_STS_ERROR;
END IF;

END Validate_Amount;


PROCEDURE CREATE_MISC_DSTR_LINE(p_api_version        IN     NUMBER,
                                p_init_msg_list      IN     VARCHAR2,
                                x_return_status      OUT    NOCOPY VARCHAR2,
                                x_msg_count          OUT    NOCOPY NUMBER,
                                x_msg_data           OUT    NOCOPY VARCHAR2,
                                p_tclv_rec           IN     tclv_rec_type,
                                x_tclv_rec           OUT    NOCOPY tclv_rec_type)
IS

  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT tsu_code
  FROM OKL_TRX_CONTRACTS
  WHERE ID = v_tcn_id;

  CURSOR tcl_csr(v_tcl_id NUMBER) IS
  SELECT avl_id,
         sty_id,
         description,
         amount
  FROM OKL_TXL_CNTRCT_LNS
  WHERE ID = v_tcl_id;


  l_api_name               CONSTANT VARCHAR2(40) := 'CREATE_MISC_DSTR_LINE';
  l_api_version            CONSTANT NUMBER        := 1.0;
  l_tab_api_version        CONSTANT NUMBER        := 1.0;

  l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count         NUMBER := 0;
  l_msg_data          VARCHAR2(2000);
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_tclv_rec_in       TCLV_REC_TYPE ;
  l_tclv_rec_out      TCLV_REC_TYPE;
  l_tabv_tbl          OKL_TRNS_ACC_DSTRS_PUB.TABV_TBL_TYPE;
  l_old_avl_id        NUMBER := NULL;
  l_source_table      OKL_TRNS_ACC_DSTRS.source_table%TYPE := 'OKL_TXL_CNTRCT_LNS';
  i                   NUMBER := 0;
  l_tsu_code          OKL_TRX_CONTRACTS.TSU_CODE%TYPE;

  l_check_status      NUMBER;
  l_avl_id            NUMBER;
  l_sty_id            NUMBER;
  l_description       OKL_TXL_CNTRCT_LNS.DESCRIPTION%TYPE;
  l_amount            NUMBER;




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

   l_tclv_rec_in   := p_tclv_rec;

   OPEN tcn_csr(l_tclv_rec_in.TCN_ID);
   FETCH tcn_csr INTO l_tsu_code;
   CLOSE tcn_csr;

   IF (l_tsu_code = 'CANCELED') THEN

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TRX_CANCELED');

      RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;

   IF (l_tclv_rec_in.Amount IS NULL) OR
      (l_tclv_rec_in.Amount = OKL_API.G_MISS_NUM) OR
      (l_tclv_rec_in.Amount = 0)   THEN
       OKL_API.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'AMOUNT');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   IF (l_tclv_rec_in.ID = OKL_API.G_MISS_NUM) OR
      (l_tclv_rec_in.ID IS NULL) THEN  -- Create Mode

       l_tclv_rec_in.TCL_TYPE := 'MAE';

       l_tclv_rec_in.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => l_tclv_rec_in.amount,
			 p_currency_code => l_tclv_rec_in.currency_code);


        Validate_Amount (p_tclv_rec   => l_tclv_rec_in,
			 p_mode	      => 'I',
			 x_return_status => l_return_status);

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  	      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          	  p_msg_name     => 'OKL_TRX_AMT_GT_LINE_AMT');
              RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;


-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRMSCB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines ');
    END;
  END IF;
       OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines(p_api_version     => l_api_version,
                                                     p_init_msg_list   => l_init_msg_list,
                                                     x_return_status   => l_return_status,
                                                     x_msg_count       => l_msg_count,
                                                     x_msg_data        => l_msg_data,
                                                     p_tclv_rec        => l_tclv_rec_in,
                                                     x_tclv_rec        => l_tclv_rec_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRMSCB.pls call OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines

       IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

           IF (l_tclv_rec_in.AVL_ID IS NOT NULL) AND
              (l_tclv_rec_in.AVL_ID <> OKL_API.G_MISS_NUM) THEN

	       CREATE_DIST_LINE(p_tclv_rec       => l_tclv_rec_out,
			        x_return_status  => l_return_status);

		-- SAntonyr Added to fix 2804913
		IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	           RAISE OKL_API.G_EXCEPTION_ERROR;
           	END IF;


           END IF;

       END IF;

   ELSE  -- Update Mode

   -- Determine what has changed

       OPEN tcl_csr(l_tclv_rec_in.ID);
       FETCH tcl_csr INTO
             l_avl_id,
             l_sty_id,
             l_description,
             l_amount;
       CLOSE tcl_csr;


       l_tclv_rec_in.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => l_tclv_rec_in.amount,
			 p_currency_code => l_tclv_rec_in.currency_code);


        Validate_Amount (p_tclv_rec   => l_tclv_rec_in,
			 p_mode	      => 'U',
			 x_return_status => l_return_status);

        IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  	      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          	  p_msg_name     => 'OKL_TRX_AMT_GT_LINE_AMT');
              RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;



       -- Update has to be done anyway

-- Start of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRMSCB.pls call OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines ');
    END;
  END IF;
       OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines(p_api_version     => l_api_version,
                                                     p_init_msg_list   => l_init_msg_list,
                                                     x_return_status   => l_return_status,
                                                     x_msg_count       => l_msg_count,
                                                     x_msg_data        => l_msg_data,
                                                     p_tclv_rec        => l_tclv_rec_in,
                                                     x_tclv_rec        => l_tclv_rec_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRMSCB.pls call OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines

       IF (nvl(l_tclv_rec_in.avl_id,OKL_API.G_MISS_NUM) <> nvl(l_avl_id,OKL_API.G_MISS_NUM)) OR
          (nvl(l_tclv_rec_in.sty_id,OKL_API.G_MISS_NUM) <> nvl(l_sty_id,OKL_API.G_MISS_NUM)) OR
          (nvl(l_tclv_rec_in.amount,OKL_API.G_MISS_NUM) <> nvl(l_amount,OKL_API.G_MISS_NUM)) THEN
                     -- Significant Changed


          l_check_status := CHECK_DIST(p_source_id    => l_tclv_rec_in.ID,
                                       p_source_table  => l_source_table);

          IF (l_check_status = 1)  OR (l_check_status = 2) THEN
            -- Delete from Distributions
              DELETE_DIST_AE(p_flag          => 'DIST',
                             p_source_id     => l_tclv_rec_in.ID,
                             p_source_table  => l_source_table,
                             x_return_status => l_return_status);

              IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

          END IF;

          IF (l_check_status = 2)  THEN
           -- delete from AE
             DELETE_DIST_AE(p_flag          => 'AE',
                            p_source_id     => l_tclv_rec_in.ID,
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

          -- Now create distributions if template is specified.

	  IF ((l_tclv_rec_in.AVL_ID IS NOT NULL) AND
              (l_tclv_rec_in.AVL_ID <> OKL_API.G_MISS_NUM)) THEN

 	      CREATE_DIST_LINE(p_tclv_rec        => l_tclv_rec_out,
			       x_return_status   => l_return_status);

	      -- SAntonyr Added to fix 2804913
	      IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

	  END IF;


       END IF;  -- Of something significant changed

   END IF; -- Of Update Mode

   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

   x_return_status := l_return_status;
   x_tclv_rec      := l_tclv_rec_out;

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



END CREATE_MISC_DSTR_LINE;


PROCEDURE CREATE_DIST_LINE(p_tclv_rec       IN  TCLV_REC_TYPE,
 			   x_return_status  OUT NOCOPY VARCHAR2)


IS

  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT trunc(date_transaction_occurred),
-- Added by Santonyr on 22-Nov-2002 Multi-Currency
	 currency_code,
  	 currency_conversion_type,
  	 currency_conversion_rate,
	 currency_conversion_date
  FROM OKL_TRX_CONTRACTS
  WHERE ID = v_tcn_id;

  CURSOR prod_csr(v_aes_id NUMBER) IS
  SELECT ID
  FROM OKL_PRODUCTS_V
  WHERE aes_id = v_aes_id;

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

  CURSOR khr_prod_csr(v_khr_id NUMBER) IS
  SELECT PDT_ID
  FROM OKL_K_HEADERS
  WHERE id = v_khr_id;

  CURSOR avl_csr(v_template_id NUMBER) IS
  SELECT sty_id,
         try_id,
         aes_id,
         syt_code,
         -- Added by HKPATEL for bug# 2943310
         inv_code,
         -- Added code ends here
         fac_code,
         advance_arrears,
         memo_yn,
         prior_year_yn,
         factoring_synd_flag
  FROM OKL_AE_TEMPLATES
  WHERE id = v_template_id;

  CURSOR org_csr IS
  SELECT mo_global.get_current_org_id()
  from dual;

  l_org_id  NUMBER;

  Cursor sales_csr(v_khr_id NUMBER) IS
  SELECT ct.object1_id1 id
  from   okc_contacts        ct,
         okc_contact_sources csrc,
         okc_k_party_roles_b pty,
         okc_k_headers_b     chr
  where  ct.cpl_id               = pty.id
  and    ct.cro_code             = csrc.cro_code
  and    ct.jtot_object1_code    = csrc.jtot_object_code
  and    ct.dnz_chr_id           = chr.id
  and    pty.rle_code            = csrc.rle_code
  and    csrc.cro_code           = 'SALESPERSON'
  and    csrc.rle_code           = 'LESSOR'
  and    csrc.buy_or_sell        = chr.buy_or_sell
  and    pty.dnz_chr_id          = chr.id
  and    pty.chr_id              = chr.id
  and    chr.id                  = v_khr_id;

  l_sales_rep  OKC_CONTACTS.object1_id1%TYPE;

  CURSOR trx_csr IS
  SELECT cust_trx_type_id
  FROM ra_cust_trx_types
  WHERE name = 'Invoice-OKL';

  l_trx_type NUMBER;

  Cursor Billto_csr(v_khr_id NUMBER) IS
  SELECT object1_id1 cust_acct_site_id
  FROM okc_rules_b rul
  WHERE  rul.rule_information_category = 'BTO'
         and exists (select '1'
                     from okc_rule_groups_b rgp
                     where rgp.id = rul.rgp_id
                          and   rgp.rgd_code = 'LABILL'
                          and   rgp.chr_id   = rul.dnz_chr_id
                          and   rgp.chr_id = v_khr_id );

 l_ar_site_use OKC_RULES_B.object1_id1%TYPE;


  l_functional_curr   OKL_TRNS_ACC_DSTRS.CURRENCY_CODE%TYPE;

  l_template_name     OKL_AE_TEMPLATES.NAME%TYPE;
  l_source_table      OKL_TRNS_ACC_DSTRS.source_table%TYPE := 'OKL_TXL_CNTRCT_LNS';
  l_accounting_date   DATE;

-- Added by Santonyr on 22-Nov-2002 Multi-Currency
  l_currency_code		okl_trx_contracts.currency_code%TYPE;
  l_currency_conversion_type	okl_trx_contracts.currency_conversion_type%TYPE;
  l_currency_conversion_rate	okl_trx_contracts.currency_conversion_rate%TYPE;
  l_currency_conversion_date	okl_trx_contracts.currency_conversion_date%TYPE;

  l_dist_api_version  CONSTANT NUMBER       := 1.0;
  l_aes_id            NUMBER;

  l_init_msg_list     VARCHAR2(1) := OKL_API.G_FALSE;
  l_msg_count         NUMBER := 0;
  l_msg_data          VARCHAR2(2000);
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_template_id       NUMBER ;

  l_dist_info_rec     OKL_ACCOUNT_DIST_PUB.DIST_INFO_REC_TYPE;
  l_tmpl_identify_rec OKL_ACCOUNT_DIST_PUB.TMPL_IDENTIFY_REC_TYPE;
  l_ctxt_val_tbl      OKL_ACCOUNT_DIST_PUB.CTXT_VAL_TBL_TYPE;
  l_template_tbl      OKL_TMPT_SET_PUB.AVLV_TBL_TYPE;
  l_amount_tbl        OKL_ACCOUNT_DIST_PUB.AMOUNT_TBL_TYPE;
  l_acc_gen_primary_key_tbl OKL_ACCOUNT_DIST_PUB.ACC_GEN_PRIMARY_KEY;



BEGIN

    l_template_id := p_tclv_rec.avl_id;

    OPEN tcn_csr(p_tclv_rec.tcn_id);
    FETCH tcn_csr
    INTO l_accounting_date,
-- Added by Santonyr on 22-Nov-2002 Multi-Currency
	 l_currency_code,
    	 l_currency_conversion_type,
   	 l_currency_conversion_rate,
    	 l_currency_conversion_date;

    IF (tcn_csr%NOTFOUND) THEN
        OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name       => g_invalid_value
                           ,p_token1         => g_col_name_token
                           ,p_token1_value   => 'TCN_ID');

        CLOSE tcn_csr;
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    CLOSE tcn_csr;

-- Since we want do not want to create a new signature for accounting procedure for Misc
-- the following round about way is adopted. We already know the Template, so we are trying
-- to get all the parameters for the template from template table. These parameters will
-- in turn be passed to the accounting engine, which will identify the same template....

    OPEN avl_csr(l_template_id);
    FETCH avl_csr INTO
         l_tmpl_identify_rec.STREAM_TYPE_ID,
         l_tmpl_identify_rec.TRANSACTION_TYPE_ID,
         l_aes_id,
         l_tmpl_identify_rec.SYNDICATION_CODE,
         -- Added by HKPATEL for Bug# 2943310
         l_tmpl_identify_rec.INVESTOR_CODE,
         -- Added code ends here
         l_tmpl_identify_rec.FACTORING_CODE,
         l_tmpl_identify_rec.ADVANCE_ARREARS,
         l_tmpl_identify_rec.MEMO_YN,
         l_tmpl_identify_rec.PRIOR_YEAR_YN,
         l_tmpl_identify_rec.FACTORING_SYND_FLAG;
    CLOSE avl_csr;

-- The following cursor may return multiple records, but we are interest in only one record

/*
    OPEN prod_csr(l_aes_id);
    FETCH prod_csr INTO l_tmpl_identify_rec.PRODUCT_ID;
    CLOSE prod_csr;

*/

-- Added by Santonyr on 30-Jul-2003 to fix the bug 2941805

    OPEN khr_prod_csr(p_tclv_rec.khr_id);
    FETCH khr_prod_csr INTO l_tmpl_identify_rec.PRODUCT_ID;
    CLOSE khr_prod_csr;

-- Populate the Account Generator Parameters

    OPEN org_csr;
    FETCH org_csr INTO l_org_id;
    CLOSE org_csr;

    OPEN sales_csr(p_tclv_rec.khr_id);
    FETCH sales_csr INTO l_sales_rep;
    CLOSE sales_csr;

    OPEN trx_csr;
    FETCH trx_csr INTO l_trx_type;
    CLOSE trx_csr;

    OPEN billto_csr(p_tclv_rec.khr_id);
    FETCH billto_csr INTO l_ar_site_use;
    CLOSE billto_csr;

    l_acc_gen_primary_key_tbl(1).source_table        := 'FINANCIALS_SYSTEM_PARAMETERS';
    l_acc_gen_primary_key_tbl(1).primary_key_column  := l_org_id;
    l_acc_gen_primary_key_tbl(2).source_table        := 'JTF_RS_SALESREPS_MO_V';
    l_acc_gen_primary_key_tbl(2).primary_key_column  :=  l_sales_rep;
    l_acc_gen_primary_key_tbl(3).source_table        := 'AR_SITE_USES_V';
    l_acc_gen_primary_key_tbl(3).primary_key_column  := l_ar_site_use;
    l_acc_gen_primary_key_tbl(4).source_table        := 'RA_CUST_TRX_TYPES';
    l_acc_gen_primary_key_tbl(4).primary_key_column  := l_trx_type;


--    l_functional_curr := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

    l_dist_info_rec.SOURCE_ID                         := p_tclv_rec.ID;
    l_dist_info_rec.SOURCE_TABLE                      := l_source_table;
    l_dist_info_rec.ACCOUNTING_DATE                   := l_accounting_date;
    l_dist_info_rec.GL_REVERSAL_FLAG                  := 'N';
    l_dist_info_rec.POST_TO_GL                        := 'Y';
    l_dist_info_rec.AMOUNT                            := p_tclv_rec.AMOUNT;
--    l_dist_info_rec.CURRENCY_CODE                     := l_functional_curr;


-- Added by Santonyr on 22-Nov-2002 Multi-Currency
    l_dist_info_rec.CURRENCY_CODE                     := l_currency_code;
    l_dist_info_rec.CURRENCY_CONVERSION_TYPE          := l_currency_conversion_type;
    l_dist_info_rec.CURRENCY_CONVERSION_RATE          := l_currency_conversion_rate;
    l_dist_info_rec.CURRENCY_CONVERSION_DATE          := l_currency_conversion_date;

-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRMSCB.pls call OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
    OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST(p_api_version          => l_dist_api_version,
                                                p_init_msg_list        => l_init_msg_list,
                                                x_return_status        => l_return_status,
                                                x_msg_count            => l_msg_count,
                                                x_msg_data             => l_msg_data,
                                                p_tmpl_identify_rec    => l_tmpl_identify_rec,
                                                p_dist_info_rec        => l_dist_info_Rec,
                                                p_ctxt_val_tbl         => l_ctxt_val_tbl,
                                                p_acc_gen_primary_key_tbl =>  l_acc_gen_primary_key_tbl,
                                                x_template_tbl           => l_template_tbl,
                                                x_amount_tbl             => l_amount_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRMSCB.pls call OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PUB.CREATE_ACCOUNTING_DIST

    x_return_status := l_return_status;

END CREATE_DIST_LINE;


  -----------------------------------------------------------------------------
  -- PROCEDURE populate_jrnl_lines
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_jrnl_lines
  -- Description     : This procedure copies the jrnl line attributes from
  --                 : jrnl_line_rec to tclv_rec
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE populate_jrnl_lines(p_tcn_id        IN         NUMBER,
                                p_khr_id        IN         NUMBER,
                                p_currency_code IN         VARCHAR2,
                                p_jrnl_line_rec IN         jrnl_line_rec_type,
                                x_tclv_rec      OUT NOCOPY okl_trx_contracts_pvt.tclv_rec_type) IS

      l_tclv_rec          okl_trx_contracts_pvt.tclv_rec_type;
      l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||' populate_jrnl_lines ';
  BEGIN
      IF(p_jrnl_line_rec.id IS NOT NULL) THEN
        l_tclv_rec.id               := p_jrnl_line_rec.id;
      END IF;
      l_tclv_rec.khr_id           := p_khr_id;
      l_tclv_rec.line_number      := p_jrnl_line_rec.line_number;
      l_tclv_rec.tcn_id           := p_tcn_id;
      l_tclv_rec.description      := p_jrnl_line_rec.description;
      l_tclv_rec.avl_id           := p_jrnl_line_rec.avl_id;
      l_tclv_rec.sty_id           := p_jrnl_line_rec.sty_id;
      l_tclv_rec.currency_code    := p_currency_code;
      l_tclv_rec.amount           := p_jrnl_line_rec.amount;
      -- return the populated record
      x_tclv_rec                  := l_tclv_rec;

  END populate_jrnl_lines;

  -----------------------------------------------------------------------------
  -- PROCEDURE populate_jrnl_lines
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : populate_jrnl_hdr
  -- Description     : This procedure copies the journal header attributes from
  --                 : jrnl_hdr_rec to tcnv_rec
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE populate_jrnl_hdr(p_jrnl_hdr_rec  IN         jrnl_hdr_rec_type,
                              x_tcnv_rec      OUT NOCOPY okl_trans_contracts_pvt.tcnv_rec_type) IS

      l_tcnv_rec          okl_trans_contracts_pvt.tcnv_rec_type;
      l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||' populate_jrnl_hdr ';

      l_transaction_date okl_trx_contracts.transaction_date%TYPE := okl_api.g_miss_date;

      CURSOR c_transaction_date(
                                cp_khr_id     okl_trx_contracts.khr_id%TYPE,
                                cp_trx_number okl_trx_contracts.trx_number%TYPE
                               ) IS
        SELECT transaction_date
          FROM okl_trx_contracts
         WHERE khr_id = cp_khr_id
           AND trx_number = cp_trx_number;

  BEGIN

    -- assign the values to the tcnv_rec_type
    l_tcnv_rec.khr_id                     :=  p_jrnl_hdr_rec.khr_id;
    l_tcnv_rec.pdt_id                     :=  p_jrnl_hdr_rec.pdt_id;
    l_tcnv_rec.amount                     :=  p_jrnl_hdr_rec.amount;
    l_tcnv_rec.tsu_code                   :=  p_jrnl_hdr_rec.tsu_code;
    l_tcnv_rec.currency_code              :=  p_jrnl_hdr_rec.currency_code;
    l_tcnv_rec.trx_number                 :=  p_jrnl_hdr_rec.trx_number;
    l_tcnv_rec.description                :=  p_jrnl_hdr_rec.description;
    l_tcnv_rec.date_transaction_occurred  :=  p_jrnl_hdr_rec.date_transaction_occurred;
    -- return the populated record
    IF l_tcnv_rec.tsu_code = 'CANCELED' THEN

      OPEN  c_transaction_date(p_jrnl_hdr_rec.khr_id,p_jrnl_hdr_rec.trx_number);
      FETCH c_transaction_date INTO l_transaction_date;
      CLOSE c_transaction_date;
      l_tcnv_rec.transaction_date := l_transaction_date;
    END IF;
    x_tcnv_rec                            :=  l_tcnv_rec;

  END populate_jrnl_hdr;

  -----------------------------------------------------------------------------
  -- PROCEDURE create_misc_transaction
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_misc_transaction
  -- Description     : This procedure creates the manual journal header, lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE create_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     jrnl_line_tbl_type,
                                    x_jrnl_hdr_rec       OUT    NOCOPY jrnl_hdr_rec_type) IS

    l_prog_name      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_misc_transaction';

    l_tcnv_rec       okl_trans_contracts_pvt.tcnv_rec_type;
    lx_tcnv_rec      okl_trans_contracts_pvt.tcnv_rec_type;

    l_tclv_rec       okl_trx_contracts_pvt.tclv_rec_type;
    lx_tclv_rec      okl_trx_contracts_pvt.tclv_rec_type;

    lx_return_status VARCHAR2(1);

  BEGIN

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- populate the journal header record
    populate_jrnl_hdr(p_jrnl_hdr_rec  =>  p_jrnl_hdr_rec,
                      x_tcnv_rec      =>  l_tcnv_rec);

    -- call the public api to create the manual journal header
    okl_trans_contracts_pub.create_trx_contracts(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => lx_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_tcnv_rec      => l_tcnv_rec,
                                                 x_tcnv_rec      => lx_tcnv_rec);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- create journal lines for the header created above
    IF(p_jrnl_line_tbl.COUNT > 0) THEN
      FOR i IN p_jrnl_line_tbl.FIRST .. p_jrnl_line_tbl.LAST LOOP
        IF(p_jrnl_line_tbl.EXISTS(i)) THEN
            -- populate the journal line record.
            populate_jrnl_lines(p_tcn_id        => lx_tcnv_rec.id,
                                p_khr_id        => lx_tcnv_rec.khr_id,
                                p_currency_code => lx_tcnv_rec.currency_code,
                                p_jrnl_line_rec => p_jrnl_line_tbl(i),
                                x_tclv_rec      => l_tclv_rec);
            -- use the populated record to create journal lines
            okl_misc_trans_pub.create_misc_dstr_line(p_api_version   => G_API_VERSION,
                                                     p_init_msg_list => G_FALSE,
                                                     x_return_status => lx_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_tclv_rec      => l_tclv_rec,
                                                     x_tclv_rec      => lx_tclv_rec);

            IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF; -- end of exists condition
      END LOOP; -- end of journal line table loop
    END IF; -- end of condition check for journal lines

    -- populate the record to be returned
    x_jrnl_hdr_rec            :=   p_jrnl_hdr_rec;
    -- update the columns which are updated
    x_jrnl_hdr_rec.id         :=   lx_tcnv_rec.id;
    x_jrnl_hdr_rec.tsu_code   :=   lx_tcnv_rec.tsu_code;
    -- added by zrehman on 14-Dec-2006 as part of Bug#5707931
    x_jrnl_hdr_rec.trx_number    :=   lx_tcnv_rec.trx_number;

    -- return the status
    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_misc_transaction;

  -----------------------------------------------------------------------------
  -- PROCEDURE update_misc_transaction
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_misc_transaction
  -- Description     : This procedure updates the manual journal header, creates/updates lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE update_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     jrnl_line_tbl_type) IS

    l_prog_name      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_misc_transaction';

    l_tcnv_rec       okl_trans_contracts_pvt.tcnv_rec_type;
    lx_tcnv_rec      okl_trans_contracts_pvt.tcnv_rec_type;

    l_tclv_rec       okl_trx_contracts_pvt.tclv_rec_type;
    lx_tclv_rec      okl_trx_contracts_pvt.tclv_rec_type;

    lx_return_status VARCHAR2(1);

  BEGIN

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;


    -- populate the journal header record
    populate_jrnl_hdr(p_jrnl_hdr_rec  =>  p_jrnl_hdr_rec,
                      x_tcnv_rec      =>  l_tcnv_rec);
    l_tcnv_rec.id := p_jrnl_hdr_rec.id;
    -- call the public api to update the manual journal header
    okl_trans_contracts_pub.update_trx_contracts(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => lx_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_tcnv_rec      => l_tcnv_rec,
                                                 x_tcnv_rec      => lx_tcnv_rec);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- create journal lines for the header created above
    IF(p_jrnl_line_tbl.COUNT > 0) THEN
      FOR i IN p_jrnl_line_tbl.FIRST .. p_jrnl_line_tbl.LAST LOOP
        IF(p_jrnl_line_tbl.EXISTS(i)) THEN
            -- populate the journal line record.
            populate_jrnl_lines(p_tcn_id        => lx_tcnv_rec.id,
                                p_khr_id        => lx_tcnv_rec.khr_id,
                                p_currency_code => lx_tcnv_rec.currency_code,
                                p_jrnl_line_rec => p_jrnl_line_tbl(i),
                                x_tclv_rec      => l_tclv_rec);
            -- use the populated record to create journal lines
            okl_misc_trans_pub.create_misc_dstr_line(p_api_version   => G_API_VERSION,
                                                     p_init_msg_list => G_FALSE,
                                                     x_return_status => lx_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_tclv_rec      => l_tclv_rec,
                                                     x_tclv_rec      => lx_tclv_rec);

            IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF lx_return_status = G_RET_STS_ERROR THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
        END IF; -- end of exists condition
      END LOOP; -- end of journal line table loop
    END IF; -- end of condition check for journal lines

    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_misc_transaction;



END OKL_MISC_TRANS_PVT;

/
