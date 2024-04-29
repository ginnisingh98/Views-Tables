--------------------------------------------------------
--  DDL for Package Body OKL_TRANS_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRANS_CONTRACTS_PVT" AS
/* $Header: OKLRTCTB.pls 120.4 2006/11/13 05:48:42 dpsingh noship $ */

--Added by dpsingh for LE Uptake
CURSOR get_contract_number(p_khr_id NUMBER) IS
SELECT CONTRACT_NUMBER
FROM OKC_K_HEADERS_B
WHERE ID = p_khr_id ;

-- Added by Santonyr on 03-Dec-2002
-- This procedure makes sure that the sum of transaction line
-- amount is not greater than transaction amount.

PROCEDURE Validate_Amount (p_tcnv_rec           IN     tcnv_rec_type,
			   x_return_status      OUT    NOCOPY VARCHAR2)
IS

-- Cursor to fetch trx line amount
CURSOR txl_amt_csr (l_trx_id NUMBER) IS
SELECT SUM(AMOUNT) SUM_AMOUNT
FROM OKL_TXL_CNTRCT_LNS
WHERE TCN_ID = l_trx_id;

l_sum_txl_amt   NUMBER := 0;

BEGIN

x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Fetch trx line amount for update mode

FOR txl_amt_rec IN txl_amt_csr (p_tcnv_rec.ID) LOOP
  l_sum_txl_amt := NVL(txl_amt_rec.SUM_AMOUNT, 0);
END LOOP;

-- Return Error status if sum of trx line amount is greater than trx amount.

IF l_sum_txl_amt > NVL(p_tcnv_rec.amount, 0) THEN
  x_return_status := OKL_API.G_RET_STS_ERROR;
END IF;

END Validate_Amount;

PROCEDURE create_trx_contracts(p_api_version     IN  NUMBER
                              ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              ,x_msg_count       OUT NOCOPY NUMBER
                              ,x_msg_data        OUT NOCOPY VARCHAR2
                              ,p_tcnv_rec        IN  tcnv_rec_type
                              ,p_tclv_tbl        IN  tclv_tbl_type
                              ,x_tcnv_rec        OUT NOCOPY tcnv_rec_type
                              ,x_tclv_tbl        OUT NOCOPY tclv_tbl_type)

IS

l_api_version NUMBER := 1.0;
l_try_id      NUMBER := 0;
l_tcnv_rec    tcnv_rec_type := p_tcnv_rec;
l_functional_currency okl_trx_contracts.currency_code%TYPE;

-- Added by Santonyr on 22-Nov-2002 Multi-Currency

l_currency_conversion_type	okl_k_headers.currency_conversion_type%TYPE;
l_currency_conversion_rate	okl_k_headers.currency_conversion_rate%TYPE;
l_currency_conversion_date	okl_k_headers.currency_conversion_date%TYPE;
l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

CURSOR try_csr IS
SELECT ID
FROM OKL_TRX_TYPES_TL
WHERE NAME = 'Miscellaneous'
AND   LANGUAGE = 'US';

-- Added by Santonyr on 22-Nov-2002. Multi-Currency Changes
-- Derived the currency conversion factors from Contracts table

CURSOR curr_csr (l_khr_id NUMBER) IS
SELECT 	currency_conversion_type, currency_conversion_rate,
	currency_conversion_date
FROM 	okl_k_headers
WHERE 	id = l_khr_id;

l_legal_entity_id   NUMBER;

BEGIN

   IF (p_tcnv_rec.khr_id IS NULL) OR
      (p_tcnv_rec.khr_id = OKL_Api.G_MISS_NUM) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'KHR_ID');
       x_return_status     := OKL_Api.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;

   IF (p_tcnv_rec.Amount IS NULL) OR
      (p_tcnv_rec.Amount = OKL_Api.G_MISS_NUM) OR
      (p_tcnv_rec.Amount = 0)   THEN
       OKC_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'AMOUNT');
       x_return_status     := OKL_Api.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;

   END IF;


   OPEN try_csr;
   FETCH try_csr INTO l_try_id;

   IF (try_csr%NOTFOUND) THEN
     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_MISC_TRX_NOT_FOUND');
     CLOSE try_csr;
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   CLOSE try_csr;

  --Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_tcnv_rec.khr_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
                l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                  -- get the contract number
                OPEN get_contract_number(l_tcnv_rec.khr_id);
                FETCH get_contract_number INTO l_cntrct_number;
                CLOSE get_contract_number;
		Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

   l_tcnv_rec.TRY_ID   := l_try_id;
   l_tcnv_rec.TCN_TYPE := 'MAE';


-- Added by Santonyr on 22-Nov-2002. Multi-Currency Changes
-- Derive the currency conversion factors from Contracts table

-- Fetch the functional currency
   l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

-- Fetch the currency conversion factors if functional currency is not equal
-- to the transaction currency

   IF l_functional_currency <> l_tcnv_rec.currency_code THEN

-- Fetch the currency conversion factors from Contracts
     FOR curr_rec IN curr_csr(l_tcnv_rec.khr_id) LOOP
       l_currency_conversion_type := curr_rec.currency_conversion_type;
       l_currency_conversion_rate := curr_rec.currency_conversion_rate;
       l_currency_conversion_date := curr_rec.currency_conversion_date;
     END LOOP;

-- Fetch the currency conversion factors from GL_DAILY_RATES if the
-- conversion type is not 'USER'.

     IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date := l_tcnv_rec.date_transaction_occurred;
         l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
         	(p_from_curr_code => l_tcnv_rec.currency_code,
       		p_to_curr_code => l_functional_currency,
       		p_con_date => l_currency_conversion_date,
		p_con_type => l_currency_conversion_type);

     END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

   END IF;  -- End IF for (l_functional_currency <> l_tcnv_rec.currency_code)

-- Populate the currency conversion factors

   l_tcnv_rec.currency_conversion_type := l_currency_conversion_type;
   l_tcnv_rec.currency_conversion_rate := l_currency_conversion_rate;
   l_tcnv_rec.currency_conversion_date := l_currency_conversion_date;

-- Round the transaction amount

   l_tcnv_rec.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => p_tcnv_rec.amount,
			 p_currency_code => l_tcnv_rec.currency_code);


   OKL_TRX_CONTRACTS_PUB.create_trx_contracts( p_api_version     => l_api_version
                                             ,p_init_msg_list   => p_init_msg_list
                                             ,x_return_status   => x_return_status
                                             ,x_msg_count       => x_msg_count
                                             ,x_msg_data        => x_msg_data
                                             ,p_tcnv_rec        => l_tcnv_rec
                                             ,p_tclv_tbl        => p_tclv_tbl
                                             ,x_tcnv_rec        => x_tcnv_rec
                                             ,x_tclv_tbl        => x_tclv_tbl );

EXCEPTION

   WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;

END;



PROCEDURE create_trx_contracts(p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_tcnv_rec           IN  tcnv_rec_type,
                               x_tcnv_rec           OUT NOCOPY tcnv_rec_type)
IS

  l_api_version NUMBER := 1.0;
  l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TRX_CONTRACTS';
  l_functional_currency okl_trx_contracts.currency_code%TYPE;

  l_try_id      NUMBER := 0;
  l_tcnv_rec    tcnv_rec_type := p_tcnv_rec;

-- Added by Santonyr on 22-Nov-2002 Multi-Currency

  l_currency_conversion_type	okl_k_headers.currency_conversion_type%TYPE;
  l_currency_conversion_rate	okl_k_headers.currency_conversion_rate%TYPE;
  l_currency_conversion_date	okl_k_headers.currency_conversion_date%TYPE;
  l_cntrct_number         OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  CURSOR try_csr IS
  SELECT ID
  FROM OKL_TRX_TYPES_TL
  WHERE NAME = 'Miscellaneous'
  AND   LANGUAGE = 'US';

-- Added by Santonyr on 22-Nov-2002. Multi-Currency Changes
-- Derived the currency conversion factors from Contracts table

  CURSOR curr_csr (l_khr_id NUMBER) IS
  SELECT currency_conversion_type, currency_conversion_rate,
	 currency_conversion_date
  FROM 	 okl_k_headers
  WHERE  id = l_khr_id;

--Added by dpsingh for LE Uptake
l_legal_entity_id  NUMBER;

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

   IF (l_tcnv_rec.khr_id IS NULL) OR
      (l_tcnv_rec.khr_id = OKL_Api.G_MISS_NUM) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'KHR_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF (l_tcnv_rec.Amount IS NULL) OR
      (l_tcnv_rec.Amount = OKL_Api.G_MISS_NUM) OR
      (l_tcnv_rec.Amount = 0)   THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKC'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'AMOUNT');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

/* Commented by Kanti for Bug Number 2335254


   IF (l_tcnv_rec.TRX_NUMBER IS NULL) OR
      (l_tcnv_rec.TRX_NUMBER = OKL_Api.G_MISS_CHAR) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKL'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'TRX_NUMBER');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

*/


   OPEN try_csr;
   FETCH try_csr INTO l_try_id;

   IF (try_csr%NOTFOUND) THEN
     OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => 'OKL_MISC_TRX_NOT_FOUND');
     CLOSE try_csr;
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   CLOSE try_csr;

   --Added by dpsingh for LE Uptake
            l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_tcnv_rec.khr_id) ;
            IF  l_legal_entity_id IS NOT NULL THEN
                l_tcnv_rec.legal_entity_id :=  l_legal_entity_id;
            ELSE
                OPEN get_contract_number(l_tcnv_rec.khr_id);
                FETCH get_contract_number INTO l_cntrct_number;
                CLOSE get_contract_number;
		Okl_Api.set_message(p_app_name     => g_app_name,
                                                 p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                         p_token1           =>  'CONTRACT_NUMBER',
			                         p_token1_value  =>  l_cntrct_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;

   l_tcnv_rec.TRY_ID := l_try_id;
   l_tcnv_rec.TCN_TYPE := 'MAE';
   l_tcnv_rec.TSU_CODE := 'ENTERED';


-- Added by Santonyr on 22-Nov-2002. Multi-Currency Changes
-- Derive the currency conversion factors from Contracts table

-- Fetch the functional currency
   l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

-- Fetch the currency conversion factors if functional currency is not equal
-- to the transaction currency

   IF l_functional_currency <> l_tcnv_rec.currency_code THEN

-- Fetch the currency conversion factors from Contracts
     FOR curr_rec IN curr_csr(l_tcnv_rec.khr_id) LOOP
       l_currency_conversion_type := curr_rec.currency_conversion_type;
       l_currency_conversion_rate := curr_rec.currency_conversion_rate;
       l_currency_conversion_date := curr_rec.currency_conversion_date;
     END LOOP;

-- Fetch the currency conversion factors from GL_DAILY_RATES if the
-- conversion type is not 'USER'.

     IF UPPER(l_currency_conversion_type) <> 'USER' THEN
	 l_currency_conversion_date := l_tcnv_rec.date_transaction_occurred;
         l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
         	(p_from_curr_code => l_tcnv_rec.currency_code,
       		p_to_curr_code => l_functional_currency,
       		p_con_date => l_currency_conversion_date,
		p_con_type => l_currency_conversion_type);

     END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

   END IF;  -- End IF for (l_functional_currency <> l_tcnv_rec.currency_code)

-- Populate the currency conversion factors

   l_tcnv_rec.currency_conversion_type := l_currency_conversion_type;
   l_tcnv_rec.currency_conversion_rate := l_currency_conversion_rate;
   l_tcnv_rec.currency_conversion_date := l_currency_conversion_date;

-- Round the transaction amount

   l_tcnv_rec.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => p_tcnv_rec.amount,
			 p_currency_code => l_tcnv_rec.currency_code);


   OKL_TRX_CONTRACTS_PUB.create_trx_contracts(p_api_version   => l_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => l_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_tcnv_rec      => l_tcnv_rec,
                                              x_tcnv_rec      => x_tcnv_rec);

  x_return_status := l_return_status;

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );


END CREATE_TRX_CONTRACTS;



PROCEDURE create_trx_contracts(p_api_version            IN  NUMBER,
                               p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_msg_count              OUT NOCOPY NUMBER,
                               x_msg_data               OUT NOCOPY VARCHAR2,
                               p_tcnv_tbl               IN  tcnv_tbl_type,
                               x_tcnv_tbl               OUT NOCOPY tcnv_tbl_type)
 IS


l_api_version NUMBER := 1.0;
i             NUMBER := 0;
l_try_id      NUMBER := 0;



BEGIN

 x_return_status := OKL_API.G_RET_STS_SUCCESS;

 IF (p_tcnv_tbl.COUNT > 0) THEN

      i := p_tcnv_tbl.FIRST;

      LOOP

        create_trx_contracts(p_api_version     => l_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_tcnv_rec        => p_tcnv_tbl(i),
                             x_tcnv_rec        => x_tcnv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            EXIT;
        END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);
        i := p_tcnv_tbl.NEXT(i);

      END LOOP;

 END IF;


EXCEPTION

   WHEN OTHERS THEN
      NULL;

END CREATE_TRX_CONTRACTS;



PROCEDURE create_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_rec            IN  tclv_rec_type,
                                  x_tclv_rec            OUT NOCOPY tclv_rec_type)
IS

 l_api_version   NUMBER := 1.0;

 l_tclv_rec  TCLV_REC_TYPE := p_tclv_rec;

BEGIN

   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   IF (l_tclv_rec.AMOUNT IS NULL) OR
      (l_tclv_rec.AMOUNT = OKL_Api.G_MISS_NUM) OR
      (l_tclv_rec.AMOUNT = 0) THEN
       Okl_Api.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'AMOUNT');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_tclv_rec.TCL_TYPE := 'MAE';

   OKL_TRX_CONTRACTS_PUB.create_trx_cntrct_lines(p_api_version      => l_api_version,
                                                 p_init_msg_list    => p_init_msg_list,
                                                 x_return_status    => x_return_status,
                                                 x_msg_count        => x_msg_count,
                                                 x_msg_data         => x_msg_data,
                                                 p_tclv_rec         => l_tclv_rec,
                                                 x_tclv_rec         => x_tclv_rec);
EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status     := Okl_Api.G_RET_STS_ERROR;

END CREATE_TRX_CNTRCT_LINES;



PROCEDURE create_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_tbl            IN  tclv_tbl_type,
                                  x_tclv_tbl            OUT NOCOPY tclv_tbl_type)
IS

  l_api_version  NUMBER := 1.0;
  i NUMBER := 0;

BEGIN

  IF (p_tclv_tbl.COUNT > 0) THEN

      i := p_tclv_tbl.FIRST;

      LOOP

        create_trx_cntrct_lines(p_api_version     => l_api_version,
                                p_init_msg_list   => p_init_msg_list,
                                x_return_status   => x_return_status,
                                x_msg_count       => x_msg_count,
                                x_msg_data        => x_msg_data,
                                p_tclv_rec        => p_tclv_tbl(i),
                                x_tclv_rec        => x_tclv_tbl(i));

        IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            EXIT;
        END IF;

        EXIT WHEN (i = p_tclv_tbl.LAST);
        i := p_tclv_tbl.NEXT(i);

      END LOOP;

 END IF;

EXCEPTION

  WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END CREATE_TRX_CNTRCT_LINES;



PROCEDURE update_trx_contracts( p_api_version         IN  NUMBER
                               ,p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2
                               ,p_tcnv_rec            IN  tcnv_rec_type
                               ,p_tclv_tbl            IN  tclv_tbl_type
                               ,x_tcnv_rec            OUT NOCOPY tcnv_rec_type
                               ,x_tclv_tbl            OUT NOCOPY tclv_tbl_type)
IS
l_api_version   NUMBER := 1.0;
l_return_status VARCHAR2(1);

-- Added by Santonyr for Multi-Currency

l_tcnv_rec    tcnv_rec_type := p_tcnv_rec;

BEGIN

-- Added by Santonyr  Round the transaction amount

   l_tcnv_rec.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => p_tcnv_rec.amount,
			 p_currency_code => l_tcnv_rec.currency_code);

   Validate_Amount (p_tcnv_rec   => l_tcnv_rec,
	            x_return_status => l_return_status);

   IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  	 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_TRX_AMT_GT_LINE_AMT');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OKL_TRX_CONTRACTS_PUB.update_trx_contracts( p_api_version     => l_api_version
                                              ,p_init_msg_list   => p_init_msg_list
                                              ,x_return_status   => x_return_status
                                              ,x_msg_count       => x_msg_count
                                              ,x_msg_data        => x_msg_data
                                              ,p_tcnv_rec        => l_tcnv_rec
                                              ,p_tclv_tbl        => p_tclv_tbl
                                              ,x_tcnv_rec        => x_tcnv_rec
                                              ,x_tclv_tbl        => x_tclv_tbl );



END;


PROCEDURE update_trx_contracts(p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_tcnv_rec           IN  tcnv_rec_type,
                               x_tcnv_rec           OUT NOCOPY tcnv_rec_type)
IS

  CURSOR chk_csr(v_tcn_id NUMBER, v_source_table VARCHAR2) IS
  SELECT NVL(COUNT(*),0)
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id IN (SELECT id FROM OKL_TXL_CNTRCT_LNS
                      WHERE TCN_ID = v_tcn_id)
  AND   source_table = v_source_table;


  CURSOR tcl_csr(v_tcn_id NUMBER) IS
  SELECT ID
  FROM OKL_TXL_CNTRCT_LNS
  WHERE TCN_ID = v_tcn_id;


  CURSOR tcn_csr(v_tcn_id NUMBER) IS
  SELECT tsu_code
  FROM OKL_TRX_CONTRACTS
  WHERE id = v_tcn_id;


  tcl_rec          tcl_csr%ROWTYPE;
  l_source_id_tbl  OKL_REVERSAL_PUB.SOURCE_ID_TBL_TYPE;
  l_tsu_code       OKL_TRX_CONTRACTS.TSU_CODE%TYPE;
  l_source_table   OKL_TRNS_ACC_DSTRS.source_table%TYPE := 'OKL_TXL_CNTRCT_LNS';
  l_acct_date      DATE := SYSDATE;

  l_total_dist     NUMBER := 0;
  l_api_name       CONSTANT VARCHAR2(30) := 'UPDATE_TRX_CONTRACTS';
  l_api_version    NUMBER := 1.0;
  i                NUMBER := 0;
  l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

-- Added by Santonyr for Multi-Currency

  l_tcnv_rec    tcnv_rec_type := p_tcnv_rec;



BEGIN

   l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                             G_PKG_NAME,
                                             p_init_msg_list,
                                             l_api_version,
                                             p_api_version,
                                             '_PVT',
                                             x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

-- Allow update only if Status is not cancelled.

  OPEN tcn_csr(p_tcnv_rec.ID);
  FETCH tcn_csr INTO l_tsu_code;
  CLOSE tcn_csr;

  IF (l_tsu_code = 'CANCELED') THEN

      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_TRX_CANCELED');
      RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

-- Added by Santonyr  Round the transaction amount

   l_tcnv_rec.amount := okl_accounting_util.cross_currency_round_amount
   			(p_amount => p_tcnv_rec.amount,
			 p_currency_code => l_tcnv_rec.currency_code);

   Validate_Amount (p_tcnv_rec   => l_tcnv_rec,
	            x_return_status => l_return_status);

   IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
  	 OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_TRX_AMT_GT_LINE_AMT');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


  OKL_TRX_CONTRACTS_PUB.update_trx_contracts(p_api_version   => l_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_tcnv_rec      => l_tcnv_rec,
                                             x_tcnv_rec      => x_tcnv_rec);



  IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

-- If transaction is being canceled, then reverse the accounting
-- But we need to make sure that Lines and Accounting actually exist

       IF (p_tcnv_rec.TSU_CODE = 'CANCELED') THEN

           OPEN chk_csr(p_tcnv_rec.ID,l_source_table);
           FETCH chk_csr INTO l_total_dist;
           CLOSE chk_csr;

           IF (l_total_dist > 0) THEN

              FOR tcl_rec IN tcl_csr(p_tcnv_rec.ID)
              LOOP
                  i := i + 1;
                  l_source_id_tbl(i) := tcl_rec.ID;
              END LOOP;

              OKL_REVERSAL_PUB.REVERSE_ENTRIES(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                               x_return_status   => l_return_status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data,
                                               p_source_table    => l_source_table,
                                               p_acct_date       => l_acct_date,
                                               p_source_id_tbl   => l_source_id_tbl);

           END IF;
       END IF;

  END IF;

  x_return_status := l_return_status;

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

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
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

END UPDATE_TRX_CONTRACTS;



PROCEDURE update_trx_contracts(p_api_version            IN  NUMBER,
                               p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_msg_count              OUT NOCOPY NUMBER,
                               x_msg_data               OUT NOCOPY VARCHAR2,
                               p_tcnv_tbl               IN  tcnv_tbl_type,
                               x_tcnv_tbl               OUT NOCOPY tcnv_tbl_type)
 IS

 l_api_version NUMBER := 1.0;
 i             NUMBER := 0;
 l_overall_Status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 BEGIN

   IF (p_tcnv_tbl.COUNT > 0) THEN

     i := p_tcnv_tbl.FIRST;

     LOOP

        update_trx_contracts(p_api_version     => l_api_version,
                             p_init_msg_list   => p_init_msg_list,
                             x_return_status   => x_return_status,
                             x_msg_count       => x_msg_count,
                             x_msg_data        => x_msg_data,
                             p_tcnv_rec        => p_tcnv_tbl(i),
                             x_tcnv_rec        => x_tcnv_tbl(i));

        IF (x_return_status <> OKL_Api.G_RET_STS_SUCCESS) THEN
           EXIT;
        END IF;

        EXIT WHEN (i = p_tcnv_tbl.LAST);

        i := p_tcnv_tbl.NEXT(i);

     END LOOP;

   END IF;

EXCEPTION

 WHEN OTHERS THEN
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_TRX_CONTRACTS;



PROCEDURE update_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_rec            IN  tclv_rec_type,
                                  x_tclv_rec            OUT NOCOPY tclv_rec_type)
 IS

 l_api_version   NUMBER := 1.0;

 BEGIN

   IF (p_tclv_rec.AMOUNT IS NULL) OR
      (p_tclv_rec.AMOUNT = OKL_Api.G_MISS_NUM) OR
      (p_tclv_rec.AMOUNT = 0) THEN
       OKL_Api.SET_MESSAGE(p_app_name      => 'OKL'
                          ,p_msg_name      => g_required_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'AMOUNT');
       x_return_status     := OKL_Api.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines(p_api_version      => l_api_version,
                                                 p_init_msg_list    => p_init_msg_list,
                                                 x_return_status    => x_return_status,
                                                 x_msg_count        => x_msg_count,
                                                 x_msg_data         => x_msg_data,
                                                 p_tclv_rec         => p_tclv_rec,
                                                 x_tclv_rec         => x_tclv_rec);

   EXCEPTION
      WHEN OKL_API.G_EXCEPTION_ERROR THEN
          NULL;

END;


PROCEDURE update_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_tbl            IN  tclv_tbl_type,
                                  x_tclv_tbl            OUT NOCOPY tclv_tbl_type)
IS
l_api_version  NUMBER := 1.0;

 BEGIN

 OKL_TRX_CONTRACTS_PUB.update_trx_cntrct_lines(p_api_version      => l_api_version,
                                               p_init_msg_list    => p_init_msg_list,
                                               x_return_status    => x_return_status,
                                               x_msg_count        => x_msg_count,
                                               x_msg_data         => x_msg_data,
                                               p_tclv_tbl         => p_tclv_tbl,
                                               x_tclv_tbl         => x_tclv_tbl);



 END;

PROCEDURE delete_trx_contracts(p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_tcnv_rec           IN  tcnv_rec_type)
IS

l_api_version NUMBER := 1.0;

BEGIN
OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(p_api_version   => l_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_tcnv_rec      => p_tcnv_rec );


END;


PROCEDURE delete_trx_contracts(p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_tcnv_tbl           IN  tcnv_tbl_type)
IS

l_api_version NUMBER := 1.0;

BEGIN


  OKL_TRX_CONTRACTS_PUB.delete_trx_contracts(p_api_version   => l_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_tcnv_tbl      => p_tcnv_tbl );


END;


PROCEDURE delete_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_rec            IN  tclv_rec_type)
IS
l_api_version  NUMBER := 1.0;

 BEGIN

 OKL_TRX_CONTRACTS_PUB.delete_trx_cntrct_lines(p_api_version      => l_api_version,
                                               p_init_msg_list    => p_init_msg_list,
                                               x_return_status    => x_return_status,
                                               x_msg_count        => x_msg_count,
                                               x_msg_data         => x_msg_data,
                                               p_tclv_rec         => p_tclv_rec);



 END;


PROCEDURE delete_trx_cntrct_lines(p_api_version         IN  NUMBER,
                                  p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2,
                                  p_tclv_tbl            IN  tclv_tbl_type)
IS
l_api_version  NUMBER := 1.0;

 BEGIN

 OKL_TRX_CONTRACTS_PUB.delete_trx_cntrct_lines(p_api_version      => l_api_version,
                                               p_init_msg_list    => p_init_msg_list,
                                               x_return_status    => x_return_status,
                                               x_msg_count        => x_msg_count,
                                               x_msg_data         => x_msg_data,
                                               p_tclv_tbl         => p_tclv_tbl );

END;


END OKL_TRANS_CONTRACTS_PVT;

/
