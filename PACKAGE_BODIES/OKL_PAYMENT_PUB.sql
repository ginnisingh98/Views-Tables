--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_PUB" AS
/* $Header: OKLPPAYB.pls 120.10 2007/09/07 12:28:18 nikshah noship $ */

  ------------------------------------------------------------------------------
  -- FUNCTION get_ar_receipt_number
  ------------------------------------------------------------------------------
  FUNCTION get_ar_receipt_number(p_cash_receipt_id IN NUMBER) RETURN VARCHAR2 IS

  l_receipt_number AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE;

  CURSOR C1 (p_cash_receipt_id IN NUMBER) IS
  SELECT  RECEIPT_NUMBER
  FROM    AR_CASH_RECEIPTS_ALL
  WHERE   CASH_RECEIPT_ID = p_cash_receipt_id;

  BEGIN

    OPEN  C1(p_cash_receipt_id);
    FETCH C1 INTO l_receipt_number;
    CLOSE C1;

    RETURN l_receipt_number;

  EXCEPTION

    WHEN OTHERS THEN

        l_receipt_number := NULL;

  END get_ar_receipt_number;

  ----------------------------------------------------------------------
  -- PROCEDURE CREATE_INTERNAL_TRANS
  ----------------------------------------------------------------------
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_contract_id			IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version     NUMBER ;
  l_init_msg_list   VARCHAR2(1) ;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER ;
  l_msg_data        VARCHAR2(2000);
  l_customer_id     NUMBER;
  l_contract_id     NUMBER;
  l_payment_amount  NUMBER;
  l_currency_code   VARCHAR2(15);
  l_payment_date    DATE;
  l_payment_id      NUMBER;
  l_payment_method_id  NUMBER;
  l_payment_ref_number okl_trx_csh_receipt_v.check_number%TYPE;

  BEGIN

    SAVEPOINT CREATE_INTERNAL_TRANS;

    l_api_version    := p_api_version ;
    l_init_msg_list  := p_init_msg_list ;
    l_return_status  := x_return_status ;
    l_msg_count      := x_msg_count ;
    l_msg_data       := x_msg_data ;

    l_customer_id := p_customer_id;
    l_contract_id := p_contract_id;
    l_payment_amount := p_payment_amount;
    l_currency_code := p_currency_code;
    l_payment_date := p_payment_date;
    l_payment_method_id  := p_payment_method_id;
    l_payment_ref_number := p_payment_ref_number;


    -- Private API Call start
    OKL_PAYMENT_PVT.CREATE_INTERNAL_TRANS
               (
               p_api_version    => l_api_version,
               p_init_msg_list  => l_init_msg_list,
               p_customer_id    => l_customer_id,
               p_contract_id    => l_contract_id,
               p_payment_method_id  => l_payment_method_id,
               p_payment_ref_number => l_payment_ref_number,
               p_payment_amount => l_payment_amount,
               p_currency_code  => l_currency_code,
               p_payment_date   => l_payment_date,
               x_payment_id     => l_payment_id,
               x_return_status  => l_return_status,
               x_msg_count      => l_msg_count,
               x_msg_data       => l_msg_data
               );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Public API Call end



    --Assign value to OUT variables
    x_payment_id    := l_payment_id;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
				           ,p_data    => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

      WHEN OTHERS THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

  END CREATE_INTERNAL_TRANS;

  ----------------------------------------------------------------------
  -- PROCEDURE CREATE_INTERNAL_TRANS
  ----------------------------------------------------------------------
  PROCEDURE CREATE_INTERNAL_TRANS(
     p_api_version                  IN NUMBER,
     p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_customer_id                  IN NUMBER,
     p_invoice_id 			IN NUMBER,
     p_payment_method_id            IN NUMBER,
     p_payment_ref_number           IN VARCHAR2,
     p_payment_amount               IN NUMBER,
     p_currency_code                IN VARCHAR2,
     p_payment_date                 IN DATE,
     x_payment_id                   OUT NOCOPY NUMBER,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2
  )
  IS

  l_api_version     NUMBER ;
  l_init_msg_list   VARCHAR2(1) ;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER ;
  l_msg_data        VARCHAR2(2000);
  l_customer_id     NUMBER;
  l_invoice_id      NUMBER;
  l_payment_amount  NUMBER;
  l_currency_code   VARCHAR2(15);
  l_payment_date    DATE;
  l_payment_id      NUMBER;
  l_payment_method_id  NUMBER;
  l_payment_ref_number okl_trx_csh_receipt_v.check_number%TYPE;

  BEGIN

    SAVEPOINT CREATE_INTERNAL_TRANS;

    l_api_version    := p_api_version ;
    l_init_msg_list  := p_init_msg_list ;
    l_return_status  := x_return_status ;
    l_msg_count      := x_msg_count ;
    l_msg_data       := x_msg_data ;

    l_customer_id := p_customer_id;
    l_invoice_id := p_invoice_id;
    l_payment_amount := p_payment_amount;
    l_currency_code := p_currency_code;
    l_payment_date := p_payment_date;
    l_payment_method_id  := p_payment_method_id;
    l_payment_ref_number := p_payment_ref_number;



    -- Private API Call start
    OKL_PAYMENT_PVT.CREATE_INTERNAL_TRANS
               (
               p_api_version    => l_api_version,
               p_init_msg_list  => l_init_msg_list,
               p_customer_id    => l_customer_id,
               p_invoice_id     => l_invoice_id,
               p_payment_method_id  => l_payment_method_id,
               p_payment_ref_number => l_payment_ref_number,
               p_payment_amount => l_payment_amount,
               p_currency_code  => l_currency_code,
               p_payment_date   => l_payment_date,
               x_payment_id     => l_payment_id,
               x_return_status  => l_return_status,
               x_msg_count      => l_msg_count,
               x_msg_data       => l_msg_data
               );

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Public API Call end



    --Assign value to OUT variables
    x_payment_id    := l_payment_id;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;



    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
				           ,p_data    => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

      WHEN OTHERS THEN
        SAVEPOINT CREATE_INTERNAL_TRANS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.ADD_EXC_MSG('OKL_PAYMENT_PUB','CREATE_INTERNAL_TRANS');
        FND_MSG_PUB.count_and_get( p_count    => x_msg_count
                                   ,p_data    => x_msg_data);

  END CREATE_INTERNAL_TRANS;

  ----------------------------------------------------------------------
  -- PROCEDURE CREATE_PAYMENTS
  ----------------------------------------------------------------------
  PROCEDURE CREATE_PAYMENTS(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_commit                       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_validation_level             IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_receipt_rec                  IN  receipt_rec_type,
     p_payment_tbl                  IN  payment_tbl_type,
     x_payment_ref_number           OUT NOCOPY AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE,
     x_cash_receipt_id              OUT NOCOPY NUMBER
  )
  IS

  l_api_version             CONSTANT NUMBER := 1.0;
  l_api_name                CONSTANT VARCHAR2(30) := 'OKL_PAYMENT_PUB';
  l_return_status           VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_init_msg_list		    VARCHAR2(1) := Okc_Api.g_false;
  l_msg_count			    NUMBER;
  l_msg_data			    VARCHAR2(2000);

  l_commit                  VARCHAR2(1) := p_commit;
  l_validation_level        NUMBER := p_validation_level;

  l_receipt_rec             receipt_rec_type := p_receipt_rec;
  l_payment_tbl             payment_tbl_type := p_payment_tbl;

  l_payment_ref_number      AR_CASH_RECEIPTS_ALL.RECEIPT_NUMBER%TYPE DEFAULT NULL;
  l_cash_receipt_id          NUMBER;
  BEGIN

    SAVEPOINT CREATE_PAYMENTS;

 -- Begin - Make Payment Update - Varangan

OKL_PAYMENT_PVT.CREATE_PAYMENTS(
     p_api_version          => l_api_version,
     p_init_msg_list        => l_init_msg_list,
     p_commit               => l_commit,
     p_validation_level     => l_validation_level,
     x_return_status        => l_return_status,
     x_msg_count            => l_msg_count,
     x_msg_data             => l_msg_data,
     p_receipt_rec          => l_receipt_rec,
     p_payment_tbl          => l_payment_tbl,
     x_payment_ref_number   => l_payment_ref_number,
     x_cash_receipt_id      => l_cash_receipt_id
  );

-- End - Make Payment Update - Varangan


    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Public API Call end

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_cash_receipt_id  := l_cash_receipt_id;
    x_payment_ref_number := l_payment_ref_number;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_PAYMENTS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_PAYMENTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


      WHEN OTHERS THEN
        ROLLBACK TO CREATE_PAYMENTS;
        x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
        x_msg_count := l_msg_count ;
        x_msg_data := l_msg_data ;
        Fnd_Msg_Pub.ADD_EXC_MSG('OKL_PAYMENT_PUB','unexpected error');
        Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END CREATE_PAYMENTS;

END OKL_PAYMENT_PUB;

/
