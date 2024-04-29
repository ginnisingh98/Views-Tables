--------------------------------------------------------
--  DDL for Package Body OKL_INSURANCE_POLICIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INSURANCE_POLICIES_PUB" AS
/* $Header: OKLPIPXB.pls 120.6 2007/09/13 18:35:32 smereddy ship $ */
        --------------------------------------------------------------------------
      -- Procedures and Functions
      ---------------------------------------------------------------------------

           PROCEDURE   insert_ap_request(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_tap_id          IN NUMBER,
         p_credit_amount   IN NUMBER,
         p_credit_sty_id   IN NUMBER,
         p_khr_id         IN NUMBER ,
         p_kle_id         IN NUMBER,
         p_invoice_date   IN DATE,
         p_trx_id         IN NUMBER,
         p_vendor_site_id      IN NUMBER ,
         x_request_id     OUT NOCOPY NUMBER

    )  IS

    l_api_version NUMBER ;

    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_message   VARCHAR2(2000);
         l_tap_id           NUMBER;
         l_credit_amount    NUMBER;
         l_credit_sty_id    NUMBER;
         l_khr_id          NUMBER ;
         l_kle_id          NUMBER;
         l_invoice_date    DATE;
         l_trx_id          NUMBER ;
         l_vendor_site_id  NUMBER ;
         l_request_id      NUMBER;

    BEGIN
    SAVEPOINT insert_ap_request;
    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;
         l_tap_id           := p_tap_id ;
         l_credit_amount    := p_credit_amount ;
         l_credit_sty_id    := p_credit_sty_id ;
         l_khr_id          := p_khr_id ;
         l_kle_id          := p_kle_id ;
         l_invoice_date    := p_invoice_date ;
         l_trx_id          := p_trx_id ;
         l_vendor_site_id  := p_vendor_site_id;




    OKL_INSURANCE_POLICIES_Pvt.insert_ap_request(
             l_api_version     ,
    		 l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
         l_tap_id          ,
         l_credit_amount   ,
         l_credit_sty_id   ,
         l_khr_id          ,
         l_kle_id         ,
         l_invoice_date   ,
         l_trx_id,
         l_vendor_site_id,
         l_request_id
    );


    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    x_request_id   :=l_request_id ;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'insert_ap_request');
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
         END insert_ap_request;


    ---------------------------------------------------------------------------
         PROCEDURE   insert_ap_request(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_tap_id          IN NUMBER,
         p_credit_amount   IN NUMBER,
         p_credit_sty_id   IN NUMBER,
         p_khr_id         IN NUMBER ,
         p_kle_id         IN NUMBER,
         p_invoice_date   IN DATE,
         p_trx_id         IN NUMBER

    )  IS

      l_api_version NUMBER ;

    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_message   VARCHAR2(2000);
         l_tap_id           NUMBER;
         l_credit_amount    NUMBER;
         l_credit_sty_id    NUMBER;
         l_khr_id          NUMBER ;
         l_kle_id          NUMBER;
         l_invoice_date    DATE;
         l_trx_id          NUMBER ;

    BEGIN
    SAVEPOINT insert_ap_request;
    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;
         l_tap_id           := p_tap_id ;
         l_credit_amount    := p_credit_amount ;
         l_credit_sty_id    := p_credit_sty_id ;
         l_khr_id          := p_khr_id ;
         l_kle_id          := p_kle_id ;
         l_invoice_date    := p_invoice_date ;
         l_trx_id          := p_trx_id ;



    OKL_INSURANCE_POLICIES_Pvt.insert_ap_request(
             l_api_version     ,
    		 l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
         l_tap_id          ,
         l_credit_amount   ,
         l_credit_sty_id   ,
         l_khr_id          ,
         l_kle_id         ,
         l_invoice_date   ,
         l_trx_id
    );


    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO insert_ap_request;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'insert_ap_request'   	);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
         END insert_ap_request;




    -----------------






      PROCEDURE cancel_policy(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                     IN  ipyv_rec_type,
         x_ipyv_rec                     OUT NOCOPY  ipyv_rec_type
         ) IS
      l_api_version NUMBER ;

    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_ipyv_rec  ipyv_rec_type;
    lx_ipyv_rec  ipyv_rec_type;
    l_message   VARCHAR2(2000);
    BEGIN
    SAVEPOINT ins_cancel_policy;
    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;
    l_ipyv_rec  := p_ipyv_rec;

    OKL_INSURANCE_POLICIES_Pvt.cancel_policy(
             l_api_version     ,
    		 l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_ipyv_rec       ,
             lx_ipyv_rec      );
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    x_ipyv_rec := lx_ipyv_rec ;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ins_cancel_policy;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ins_cancel_policy;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO ins_cancel_policy;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'cancel_policy'   	);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
         END cancel_policy;

         PROCEDURE delete_policy(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_ipyv_rec                  IN  ipyv_rec_type,
         x_ipyv_rec                  OUT NOCOPY  ipyv_rec_type
         )IS
           l_api_version NUMBER ;

    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_ipyv_rec  ipyv_rec_type;
    lx_ipyv_rec  ipyv_rec_type;
    l_message   VARCHAR2(2000);
    BEGIN
    SAVEPOINT ins_delete_policy;
    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;
    l_ipyv_rec  := p_ipyv_rec;


    OKL_INSURANCE_POLICIES_Pvt.delete_policy(
             l_api_version     ,
    		 l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_ipyv_rec       ,
             lx_ipyv_rec      );
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    x_ipyv_rec := lx_ipyv_rec ;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ins_delete_policy;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ins_delete_policy;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO ins_delete_policy;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'delete_policy'   	);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
           END delete_policy;

--Bug#5955320
          PROCEDURE cancel_create_policies(
                 p_api_version                  IN NUMBER,
                 p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 p_khr_id                       IN  NUMBER,
                 p_cancellation_date            IN  DATE,
                 p_crx_code                     IN VARCHAR2 DEFAULT null, --++++++++ Effective Dated Term Qte changes  +++++++++
                 p_transaction_id               IN NUMBER
                 ) IS
                 l_api_name CONSTANT VARCHAR2(30) := 'cancel_create_policies';
                 l_api_version NUMBER ;
                 l_init_msg_list VARCHAR2(1) ;
                 l_msg_count NUMBER ;
                 l_msg_data VARCHAR2(2000);
                 --l_api_version         CONSTANT NUMBER := 1;
                 l_return_status      VARCHAR2(1) ;
                 l_khr_id                  number;
                 l_cancellation_date   DATE ;
                 l_crx_code   VARCHAR2(30) ;
                 l_ignore_flag VARCHAR2(1); -- 3945995
                 l_transaction_id NUMBER;
                BEGIN


                SAVEPOINT ins_cancel_policies;
                l_api_version := p_api_version ;
                l_init_msg_list := p_init_msg_list ;
                l_return_status := x_return_status ;
                l_msg_count := x_msg_count ;
                l_msg_data := x_msg_data ;
                l_khr_id  := p_khr_id;
                l_cancellation_date  := p_cancellation_date;
                l_crx_code  := p_crx_code; --Effective Dated Term Change ++--
                l_transaction_id := p_transaction_id;

    OKL_INSURANCE_POLICIES_PVT.cancel_create_policies(
             l_api_version     ,
             l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_khr_id       ,
             l_cancellation_date ,
             l_crx_code,      --+++ Eff Quote Date Modification +++----
             l_transaction_id,
             l_ignore_flag); -- 3945995

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   l_api_name);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);


    END cancel_create_policies;



   PROCEDURE cancel_create_policies(
                 p_api_version                  IN NUMBER,
                 p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 p_khr_id                       IN  NUMBER,
                 p_cancellation_date            IN  DATE,
                 p_crx_code                     IN VARCHAR2 DEFAULT NULL,
	         p_transaction_id               IN NUMBER,
                 x_ignore_flag                  OUT NOCOPY VARCHAR2 -- 3945995
                 ) IS
                 l_api_name CONSTANT VARCHAR2(30) := 'cancel_create_policies';
                 l_api_version NUMBER ;
                 l_init_msg_list VARCHAR2(1) ;
                 l_msg_count NUMBER ;
                 l_msg_data VARCHAR2(2000);
                 l_ignore_flag           VARCHAR2(1) :=  Okc_Api.G_TRUE;
                 l_return_status      VARCHAR2(1) ;
                 l_khr_id                  number;
                 l_cancellation_date   DATE ;
                 l_crx_code  VARCHAR2(30);
                 l_transaction_id NUMBER;
                BEGIN


                 SAVEPOINT cancel_create_policies;
                l_api_version := p_api_version ;
                l_init_msg_list := p_init_msg_list ;
                l_return_status := x_return_status ;
                l_msg_count := x_msg_count ;
                l_msg_data := x_msg_data ;
                l_khr_id  := p_khr_id;
                l_cancellation_date  := p_cancellation_date;
                l_crx_code  := p_crx_code;
                l_transaction_id := p_transaction_id;




    OKL_INSURANCE_POLICIES_PVT.cancel_create_policies(
             l_api_version     ,
             l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_khr_id       ,
             l_cancellation_date,
             l_crx_code,
             l_transaction_id,
             l_ignore_flag ); -- 3945995

    x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    x_ignore_flag := l_ignore_flag ;

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    --Assign value to OUT variables



    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN


          IF (x_ignore_flag =  Okc_Api.G_TRUE) THEN
             x_return_status := l_return_status ;

           ELSE

            ROLLBACK TO cancel_create_policies;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_count := l_msg_count ;
            x_msg_data := l_msg_data ;
            FND_MSG_PUB.count_and_get(
              p_count   => x_msg_count
              ,p_data    => x_msg_data);
          END IF;



        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO cancel_create_policies;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO cancel_create_policies;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   l_api_name    );
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);


    END cancel_create_policies;

      PROCEDURE cancel_policies(
         p_api_version                  IN NUMBER,
         p_init_msg_list                IN VARCHAR2 ,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_contract_id                  IN  NUMBER,
         p_cancellation_date            IN DATE,
         p_crx_code                     IN VARCHAR2 DEFAULT NULL ) IS --++++++++ Effective Dated Term Qte changes  +++++++++

           l_api_version NUMBER ;

    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    l_contract_id  NUMBER;
    l_cancellation_date DATE ;
    l_crx_code VARCHAR2(30) ; --Effective Dated Term Change ++---

    BEGIN
    SAVEPOINT ins_cancel_policies;
    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_return_status := x_return_status ;
    l_msg_count := x_msg_count ;
    l_msg_data := x_msg_data ;
    l_contract_id  := p_contract_id;
    l_cancellation_date := p_cancellation_date ;
    l_crx_code := p_crx_code ;--Effective Dated Term Change ++---


    OKL_INSURANCE_POLICIES_Pvt.cancel_policies(
             l_api_version     ,
    		 l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_contract_id       ,
             l_cancellation_date      ,
             l_crx_code      );--Effective Dated Term Change ++---

    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO ins_cancel_policies;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'cancel_policies'   	);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
         END cancel_policies;

 --+++++++++++++ Effective Dated Term Qte changes -- start +++++++++
    PROCEDURE check_claims(
                 p_api_version                  IN NUMBER,
                 p_init_msg_list                IN VARCHAR2 ,
                 x_return_status                OUT NOCOPY VARCHAR2,
                 x_msg_count                    OUT NOCOPY NUMBER,
                 x_msg_data                     OUT NOCOPY VARCHAR2,
                 x_clm_exist                    OUT NOCOPY VARCHAR2,
                 p_khr_id                       IN  NUMBER,
                 p_trx_date                 IN  DATE
                 ) IS
                 l_api_name CONSTANT VARCHAR2(30) := 'check_claims';
                 l_api_version NUMBER ;
                 l_init_msg_list VARCHAR2(1) ;
                 l_msg_count NUMBER ;
                 l_msg_data VARCHAR2(2000);
                 --l_api_version         CONSTANT NUMBER := 1;
                 l_return_status      VARCHAR2(1) ;
                 l_clm_exist          VARCHAR2(1) ;
                 l_khr_id                  number;
                 l_trx_date   DATE ;
                BEGIN
                SAVEPOINT check_claims;
                l_api_version := p_api_version ;
                l_init_msg_list := p_init_msg_list ;
                l_return_status := x_return_status ;
                l_msg_count := x_msg_count ;
                l_msg_data := x_msg_data ;
                l_clm_exist := x_clm_exist ;
                l_khr_id  := p_khr_id;
                l_trx_date  := p_trx_date;
    OKL_INSURANCE_POLICIES_PVT.check_claims(
             l_api_version     ,
             l_init_msg_list   ,
             l_return_status   ,
             l_msg_count       ,
             l_msg_data        ,
             l_clm_exist       ,
             l_khr_id       ,
             l_trx_date      );
    IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO check_claims;
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO check_Claims;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
        WHEN OTHERS THEN
          ROLLBACK TO check_claims;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count := l_msg_count ;
          x_msg_data := l_msg_data ;
          FND_MSG_PUB.ADD_EXC_MSG( G_PKG_NAME ,   'check_claims'   	);
          FND_MSG_PUB.count_and_get(
                 p_count   => x_msg_count
                ,p_data    => x_msg_data);
           END check_claims;
    --+++++++++++++ Effective Dated Term Qte changes -- End +++++++++



END OKL_INSURANCE_POLICIES_PUB;

/
