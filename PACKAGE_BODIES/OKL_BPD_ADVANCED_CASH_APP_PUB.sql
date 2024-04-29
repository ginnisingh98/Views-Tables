--------------------------------------------------------
--  DDL for Package Body OKL_BPD_ADVANCED_CASH_APP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_ADVANCED_CASH_APP_PUB" AS
/* $Header: OKLPAVCB.pls 120.12 2008/01/23 09:30:37 asawanka ship $ */

PROCEDURE ADVANCED_CASH_APP       ( p_api_version    IN  NUMBER
	                               ,p_init_msg_list  IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                               ,x_return_status  OUT NOCOPY VARCHAR2
	                               ,x_msg_count	     OUT NOCOPY NUMBER
	                               ,x_msg_data	     OUT NOCOPY VARCHAR2
                                   ,p_contract_num   IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                   ,p_customer_num   IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                   ,p_receipt_num    IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                   ,p_receipt_type   IN  OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT NULL
                                   ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                  ) IS

   l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_api_name		         CONSTANT VARCHAR2(30) := 'ADVANCED_CASH_APP';
   l_api_version			 NUMBER := 1;
   l_init_msg_list			 VARCHAR2(1);
   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   l_contract_id             OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
   l_contract_num            OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
   l_customer_id             OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
   l_customer_num            AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
   l_receipt_id              AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
   l_receipt_num             OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_receipt_num;
   l_receipt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE DEFAULT NULL;
   l_receipt_type            OKL_TRX_CSH_RECEIPT_V.RECEIPT_TYPE%TYPE DEFAULT p_receipt_type;

BEGIN

    ------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_adv_mon;


    OKL_BPD_ADVANCED_CASH_APP_PVT.ADVANCED_CASH_APP  ( p_api_version    => l_api_version
	                                                  ,p_init_msg_list  => l_init_msg_list
	                                                  ,x_return_status  => l_return_status
	                                                  ,x_msg_count	    => l_msg_count
	                                                  ,x_msg_data	    => l_msg_data
                                                      ,p_contract_num   => l_contract_num
                                                      ,p_customer_num   => l_customer_num
                                                      ,p_receipt_num    => l_receipt_num
                                                      ,p_cross_currency_allowed => p_cross_currency_allowed
                                                     );


    IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
        NULL;
		--RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
        NULL;
		--RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	WHEN OTHERS THEN
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

END ADVANCED_CASH_APP;

PROCEDURE REAPPLIC_ADVANCED_CASH_APP ( p_api_version        IN  NUMBER
	                              ,p_init_msg_list      IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                              ,x_return_status      OUT NOCOPY VARCHAR2
	                              ,x_msg_count	        OUT NOCOPY NUMBER
	                              ,x_msg_data	        OUT NOCOPY VARCHAR2
                                      ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                      ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                      ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                      ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                      ,p_receipt_date_from  IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_date_to    IN  OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL
                                      ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
				      ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                      ) IS

   l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_api_name		         CONSTANT VARCHAR2(30)  := 'REAPPLIC_ADVANCED_CASH_APP';
   l_api_version			 NUMBER := 1;
   l_init_msg_list			 VARCHAR2(1);
   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   l_contract_id             OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
   l_contract_num            OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
   l_customer_id             OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
   l_customer_num            AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
   l_receipt_id              AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
   l_receipt_num             OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_receipt_num;
   l_receipt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE DEFAULT NULL;
   l_receipt_date_from       OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT p_receipt_date_from;
   l_receipt_date_to         OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT p_receipt_date_to;
   l_receipt_type            varchar2(30) := p_receipt_type;
   l_cross_currency_allowed      VARCHAR2(1) DEFAULT p_cross_currency_allowed;

BEGIN

    ------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_adv_mon;


    OKL_BPD_ADVANCED_CASH_APP_PVT.REAPPLIC_ADVANCED_CASH_APP ( p_api_version      => l_api_version
	                                                          ,p_init_msg_list     => l_init_msg_list
	                                                          ,x_return_status     => l_return_status
	                                                          ,x_msg_count	       => l_msg_count
	                                                          ,x_msg_data	       => l_msg_data
                                                              ,p_contract_num      => l_contract_num
                                                              ,p_customer_num      => l_customer_num
                                                              ,p_receipt_id        => l_receipt_id
                                                              ,p_receipt_num       => l_receipt_num
                                                              ,p_receipt_date_from => l_receipt_date_from
                                                              ,p_receipt_date_to   => l_receipt_date_to
                                                              ,p_receipt_type      => l_receipt_type
							      ,p_cross_currency_allowed => l_cross_currency_allowed
                                                             );


    IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
		RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
		RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	WHEN OTHERS THEN
                 ROLLBACK TO sp_adv_mon;
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

END REAPPLIC_ADVANCED_CASH_APP;

PROCEDURE ADVANCED_CASH_APP_CONC ( errbuf  		        OUT NOCOPY VARCHAR2
                                  ,retcode 		        OUT NOCOPY NUMBER
                                  ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                  ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
                                  ,p_receipt_id         IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                                  ,p_receipt_num        IN  OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT NULL
                                  ,p_receipt_date_from  IN  VARCHAR2 DEFAULT NULL
                                  ,p_receipt_date_to    IN  VARCHAR2 DEFAULT NULL
                                  ,p_receipt_type       IN  VARCHAR2 DEFAULT NULL
				  ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                 ) IS

  l_api_version     NUMBER := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count     	NUMBER;
  l_msg_data    	VARCHAR2(450);
  l_init_msg_list   VARCHAR2(1);

  l_msg_index_out   NUMBER :=0;
  l_error_msg_rec   Okl_Accounting_Util.Error_message_Type;

  l_contract_id             OKC_K_HEADERS_V.ID%TYPE DEFAULT NULL;
  l_contract_num            OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_id             OKL_TRX_CSH_RECEIPT_V.ILE_ID%TYPE DEFAULT NULL;
  l_customer_num            AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
  l_receipt_id              AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL;
  l_receipt_num             OKL_TRX_CSH_RECEIPT_V.CHECK_NUMBER%TYPE DEFAULT p_receipt_num;
  l_receipt_amount          AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE DEFAULT NULL;
  l_receipt_date_from       OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL;
  l_receipt_date_to         OKL_TRX_CSH_RECEIPT_V.DATE_EFFECTIVE%TYPE DEFAULT NULL;
  l_receipt_type            VARCHAR2(30) := p_receipt_type;
  l_cross_currency_allowed  VARCHAR2(1) DEFAULT p_cross_currency_allowed;

  l_request_id      NUMBER;
  l_data                varchar2(2000);


  CURSOR req_id_csr IS
  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
  FROM dual;

BEGIN

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    IF p_receipt_date_from IS NOT NULL THEN
        l_receipt_date_from :=  FND_DATE.CANONICAL_TO_DATE(p_receipt_date_from);
    END IF;

    IF p_receipt_date_to IS NOT NULL THEN
        l_receipt_date_to :=  FND_DATE.CANONICAL_TO_DATE(p_receipt_date_to);
    END IF;



    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Process Advanced Monies');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||SYSDATE||' Request Id: '||l_request_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = ' ||p_contract_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Customer Number = ' ||p_customer_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Receipt Number  = ' ||p_receipt_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cross Currency Allowed  = ' ||p_cross_currency_allowed);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

    IF p_cross_currency_allowed IS NULL THEN
      l_cross_currency_allowed := 'N';
    END IF;

    OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_ADVANCED_CASH_APP ( p_api_version      => l_api_version
	                                                          ,p_init_msg_list     => l_init_msg_list
	                                                          ,x_return_status     => l_return_status
	                                                          ,x_msg_count	       => l_msg_count
	                                                          ,x_msg_data	       => l_msg_data
                                                              ,p_contract_num      => l_contract_num
                                                              ,p_customer_num      => l_customer_num
                                                              ,p_receipt_id        => l_receipt_id
                                                              ,p_receipt_num       => l_receipt_num
                                                              ,p_receipt_date_from => l_receipt_date_from
                                                              ,p_receipt_date_to   => l_receipt_date_to
                                                              ,p_receipt_type      => l_receipt_type
							      ,p_cross_currency_allowed => l_cross_currency_allowed
                                                              );
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        fnd_file.put_line(fnd_file.log
                         ,'Unexpected error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_ADVANCED_CASH_APP ');
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        fnd_file.put_line(fnd_file.log
                         ,'Error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_ADVANCED_CASH_APP ');
        RAISE okl_api.g_exception_error;
      END IF;

    BEGIN

        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
            FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');
            END LOOP;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;
    retcode := 0;
EXCEPTION
      WHEN okl_api.g_exception_error THEN
        retcode := 2;
       -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN okl_api.g_exception_unexpected_error THEN
        retcode := 2;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN OTHERS THEN
        retcode := 2;
        errbuf := sqlerrm;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;
        fnd_file.put_line(fnd_file.log, sqlerrm);
END ADVANCED_CASH_APP_CONC;

PROCEDURE REAPPLIC_RCPT_W_CNTRCT ( p_api_version      IN  NUMBER
	                              ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                              ,x_return_status    OUT NOCOPY VARCHAR2
	                              ,x_msg_count	      OUT NOCOPY NUMBER
	                              ,x_msg_data	      OUT NOCOPY VARCHAR2
                                  ,p_contract_num     IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                  ,p_customer_num     IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
				  ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                 )IS

   l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
   l_api_name		         CONSTANT VARCHAR2(30)  := 'REAPPLIC_RCPT_W_CNTRCT';
   l_api_version			 NUMBER := 1;
   l_init_msg_list			 VARCHAR2(1);
   l_msg_count				 NUMBER;
   l_msg_data				 VARCHAR(2000);

   l_contract_num            OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
   l_customer_num            AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
   l_cross_currency_allowed  VARCHAR2(1) DEFAULT p_cross_currency_allowed;



BEGIN

    ------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_adv_mon_w_rcpt;


    OKL_BPD_ADVANCED_CASH_APP_PVT.REAPPLIC_RCPT_W_CNTRCT ( p_api_version   =>  l_api_version
	                                                      ,p_init_msg_list =>  l_init_msg_list
	                                                      ,x_return_status =>  l_return_status
	                                                      ,x_msg_count	   =>  l_msg_count
	                                                      ,x_msg_data	   =>  l_msg_data
                                                          ,p_contract_num  =>  l_contract_num
                                                          ,p_customer_num  =>  l_customer_num
							  ,p_cross_currency_allowed => l_cross_currency_allowed
                                                          );


    IF l_return_status = Fnd_Api.G_RET_STS_ERROR THEN
		RAISE Fnd_Api.G_EXC_ERROR;
	ELSIF l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
         RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	END IF;

    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_adv_mon_w_rcpt;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_adv_mon_w_rcpt;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	WHEN OTHERS THEN
                 ROLLBACK TO sp_adv_mon_w_rcpt;
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

END REAPPLIC_RCPT_W_CNTRCT;

PROCEDURE REAPPLIC_RCPT_W_CNTRCT_CONC  (  errbuf  		       OUT NOCOPY VARCHAR2
                                         ,retcode 		       OUT NOCOPY NUMBER
                                         ,p_contract_num       IN  OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT NULL
                                         ,p_customer_num       IN  AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT NULL
					 ,p_cross_currency_allowed IN VARCHAR2 DEFAULT 'N'
                                        ) IS

  l_api_version     NUMBER := 1;
  l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_msg_count     	NUMBER;
  l_msg_data    	VARCHAR2(450);
  l_init_msg_list   VARCHAR2(1);

  l_msg_index_out   NUMBER :=0;
  l_error_msg_rec   Okl_Accounting_Util.Error_message_Type;

  l_contract_num            OKC_K_HEADERS_V.CONTRACT_NUMBER%TYPE DEFAULT p_contract_num;
  l_customer_num            AR_CASH_RECEIPTS_ALL.PAY_FROM_CUSTOMER%TYPE DEFAULT p_customer_num;
  l_cross_currency_allowed  VARCHAR2(1) DEFAULT p_cross_currency_allowed;
  l_request_id      NUMBER;
  l_data                varchar2(2000);


  CURSOR req_id_csr IS
  SELECT DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
  FROM dual;

BEGIN

    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Process Advanced Monies');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Program Run Date: '||SYSDATE||' Request Id: '||l_request_id);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'PARAMETERS');
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Contract Number = ' ||p_contract_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Customer Number = ' ||p_customer_num);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Cross Currency Allowed  = ' ||p_cross_currency_allowed);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '***********************************************');

    IF p_cross_currency_allowed IS NULL THEN
      l_cross_currency_allowed := 'N';
    END IF;
    OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_RCPT_W_CNTRCT ( p_api_version    => l_api_version
	                                                      ,p_init_msg_list  => l_init_msg_list
	                                                      ,x_return_status  => l_return_status
	                                                      ,x_msg_count	    => l_msg_count
	                                                      ,x_msg_data	    => l_msg_data
                                                          ,p_contract_num   => l_contract_num
                                                          ,p_customer_num   => l_customer_num
							  ,p_cross_currency_allowed => l_cross_currency_allowed
                                                         );
         IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Unexpected error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_RCPT_W_CNTRCT');
          RAISE okl_api.g_exception_unexpected_error;
        ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
          fnd_file.put_line(fnd_file.log
                           ,'Error in call to OKL_BPD_ADVANCED_CASH_APP_PUB.REAPPLIC_RCPT_W_CNTRCT');
        END IF;



    BEGIN

        Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
        IF (l_error_msg_rec.COUNT > 0) THEN
            FOR i IN l_error_msg_rec.FIRST..l_error_msg_rec.LAST
            LOOP
                FND_FILE.PUT_LINE(FND_FILE.LOG, l_error_msg_rec(i));
                FND_FILE.PUT_LINE (FND_FILE.LOG, '----------------------------------------------------------------------------');
            END LOOP;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Error '||TO_CHAR(SQLCODE)||': '||SQLERRM);
    END;
    retcode := 0;
EXCEPTION
          WHEN okl_api.g_exception_error THEN
        retcode := 2;
       -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN okl_api.g_exception_unexpected_error THEN
        retcode := 2;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;

      WHEN OTHERS THEN
        retcode := 2;
        errbuf := sqlerrm;

        -- print the error message in the output file

        IF (fnd_msg_pub.count_msg > 0) THEN

          FOR l_counter IN 1..fnd_msg_pub.count_msg LOOP
            fnd_msg_pub.get(p_msg_index     =>  l_counter
                           ,p_encoded       =>  'F'
                           ,p_data          =>  l_data
                           ,p_msg_index_out =>  l_msg_index_out);
            fnd_file.put_line(fnd_file.log, l_data);
          END LOOP;

        END IF;
        fnd_file.put_line(fnd_file.log, sqlerrm);
END REAPPLIC_RCPT_W_CNTRCT_CONC;

PROCEDURE AR_advance_receipt ( p_api_version      IN  NUMBER
	                          ,p_init_msg_list    IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
	                          ,x_return_status    OUT NOCOPY VARCHAR2
	                          ,x_msg_count	      OUT NOCOPY NUMBER
	                          ,x_msg_data	      OUT NOCOPY VARCHAR2
                              ,p_xcav_tbl         IN  OKL_BPD_ADVANCED_CASH_APP_PVT.xcav_tbl_type
                              ,p_receipt_id       IN  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT NULL
                              ,p_receipt_amount   IN OUT NOCOPY AR_CASH_RECEIPTS_ALL.AMOUNT%TYPE
                              ,p_receipt_date     IN  AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT NULL
                              ,p_receipt_currency IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                              ,p_currency_code    IN  AR_CASH_RECEIPTS_ALL.CURRENCY_CODE%TYPE DEFAULT NULL
                              ,p_ar_inv_tbl       IN  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type
                             ) IS

  l_ar_inv_tbl                  OKL_BPD_ADVANCED_BILLING_PVT.ar_inv_tbl_type DEFAULT p_ar_inv_tbl;

  l_api_version	                NUMBER := 1.0;
  l_init_msg_list		        VARCHAR2(1) := Okc_Api.g_false;
  l_return_status		        VARCHAR2(1);
  l_msg_count			        NUMBER;
  l_msg_data			        VARCHAR2(2000);
  l_api_name                    CONSTANT VARCHAR2(30) := 'AR_advance_receipt';

  l_receipt_date                AR_CASH_RECEIPTS_ALL.RECEIPT_DATE%TYPE DEFAULT p_receipt_date;
  l_receipt_currency_code       OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_receipt_currency;
  l_receipt_amount              OKL_TRX_CSH_RECEIPT_V.AMOUNT%TYPE DEFAULT p_receipt_amount;
  l_receipt_id                  AR_CASH_RECEIPTS_ALL.CASH_RECEIPT_ID%TYPE DEFAULT p_receipt_id;
  l_currency_code               OKL_TRX_CSH_RECEIPT_V.CURRENCY_CODE%TYPE DEFAULT p_currency_code;  -- entered currency code

  -------------------------------------------------------------------------------
  -- DECLARE Record/Table Types
  -------------------------------------------------------------------------------

  -- External Trans

  l_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  l_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;

  x_xcav_rec Okl_Xca_Pvt.xcav_rec_type;
  x_xcav_tbl Okl_Xca_Pvt.xcav_tbl_type;


BEGIN

    ------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status		:= Fnd_Api.G_RET_STS_SUCCESS;

	SAVEPOINT sp_adv_mon;

    OKL_BPD_ADVANCED_CASH_APP_PVT.AR_advance_receipt( p_api_version       => l_api_version
                       ,p_init_msg_list     => l_init_msg_list
	                   ,x_return_status     => l_return_status
	                   ,x_msg_count	        => l_msg_count
	                   ,x_msg_data	        => l_msg_data
                       ,p_xcav_tbl          => l_xcav_tbl
                       ,p_receipt_id        => l_receipt_id
                       ,p_receipt_amount    => l_receipt_amount
                       ,p_receipt_date      => l_receipt_date
                       ,p_receipt_currency  => l_receipt_currency_code
                       ,p_currency_code     => l_currency_code
                       ,p_ar_inv_tbl        => l_ar_inv_tbl
                      );

    x_return_status := l_return_status;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   -- p_remain_rcpt_amount := l_receipt_amount;

    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO sp_adv_mon;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
	WHEN OTHERS THEN
		x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		Fnd_Msg_Pub.ADD_EXC_MSG (
			p_pkg_name		=> G_PKG_NAME,
			p_procedure_name	=> l_api_name);
		Fnd_Msg_Pub.Count_and_get (
			p_encoded		=> Okc_Api.G_FALSE,
			p_count			=> x_msg_count,
			p_data			=> x_msg_data);

END AR_advance_receipt;


END OKL_BPD_ADVANCED_CASH_APP_PUB;


/
