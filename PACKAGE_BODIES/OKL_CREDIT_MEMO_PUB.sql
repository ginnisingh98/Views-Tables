--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MEMO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MEMO_PUB" AS
/* $Header: OKLPCRMB.pls 120.5 2007/04/20 19:08:18 apaul noship $ */

  PROCEDURE insert_request(p_api_version     IN          NUMBER,
                           p_init_msg_list   IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                           --p_lsm_id          IN          NUMBER,
                           p_tld_id          IN          NUMBER, -- 5897792
                           p_credit_amount   IN          NUMBER,
                           p_credit_sty_id   IN          NUMBER   DEFAULT NULL,
                           p_credit_desc     IN          VARCHAR2 DEFAULT NULL,
                           p_credit_date     IN          DATE DEFAULT SYSDATE,
                           p_try_id          IN          NUMBER   DEFAULT NULL,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL, -- 5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_tai_id          OUT NOCOPY  NUMBER,
                           x_taiv_rec        OUT NOCOPY  taiv_rec_type,
                           x_return_status   OUT NOCOPY  VARCHAR2,
                           x_msg_count       OUT NOCOPY  NUMBER,
                           x_msg_data        OUT NOCOPY  VARCHAR2) IS


    lx_tai_id                NUMBER;

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

  SAVEPOINT insert_request;





  -- PVT API call
-- Added p_credit_date as an addtnl parameter. Bug 3816891

  okl_credit_memo_pvt.insert_request(p_api_version           => p_api_version,
                        	     p_init_msg_list         => p_init_msg_list,
				     --p_lsm_id                => p_lsm_id,
				     p_tld_id                => p_tld_id, -- 5897792
				     p_credit_amount         => p_credit_amount,
				     p_credit_sty_id         => p_credit_sty_id,
                                     p_credit_desc           => p_credit_desc,
                                     p_credit_date           => p_credit_date,
                                     p_try_id                => p_try_id,
                                   p_transaction_source => p_transaction_source, -- 5897792
                                   p_source_trx_number => p_source_trx_number,

                                     x_tai_id                => x_tai_id,
                                     x_taiv_rec              => x_taiv_rec,
                                     x_return_status         => l_return_status,
                                     x_msg_count             => l_msg_count,
                                     x_msg_data              => l_msg_data);

  IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;



  lx_tai_id := x_tai_id;




  x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CREDIT_MEMO_PUB','insert_request');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END insert_request;


  -----------------------------------------------------------------------------------------------
  -- Procedure insert_request to insert a credit memo request (used by Lease Center)
  -- Overloaded procedure required as a workaround for the following known FORMS restriction:
  -- Error 512 Implementation Restriction:  Cannot directly access remote package variable or Cursor
  -----------------------------------------------------------------------------------------------
  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           --p_lsm_id                  IN          NUMBER,
                           p_tld_id                  IN          NUMBER, -- 5897792
                           p_credit_amount           IN          NUMBER,
                           p_credit_sty_id           IN          NUMBER,
                           p_credit_desc             IN          VARCHAR2,
                           p_credit_date             IN          DATE DEFAULT SYSDATE,
                           p_try_id                  IN          NUMBER,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL, -- 5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_tai_id                  OUT NOCOPY  NUMBER,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2) IS

    lx_taiv_rec       taiv_rec_type;
    l_return_status   VARCHAR2(1);

  BEGIN

    --Added p_credit_date as an addtnl parameter to this api.
    --Bug 3816891
    insert_request(p_api_version     => p_api_version,
                   p_init_msg_list   => p_init_msg_list,
                   --p_lsm_id          => p_lsm_id,
                   p_tld_id          => p_tld_id, -- 5897792
                   p_credit_amount   => p_credit_amount,
                   p_credit_sty_id   => p_credit_sty_id,
                   p_credit_desc     => p_credit_desc,
                   p_credit_date     => p_credit_date,
                   p_try_id          => p_try_id,
                   p_transaction_source => p_transaction_source, -- 5897792
                   p_source_trx_number  => p_source_trx_number,
                   x_tai_id          => x_tai_id,
                   x_taiv_rec        => lx_taiv_rec,
                   x_return_status   => l_return_status,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status      :=     l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => sqlcode,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => sqlerrm);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


  END insert_request;


  PROCEDURE insert_request(p_api_version             IN          NUMBER,
                           p_init_msg_list           IN          VARCHAR2,
                           p_credit_list             IN          credit_tbl,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL, -- 5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                           x_taiv_tbl                OUT NOCOPY  taiv_tbl_type,
                           x_return_status           OUT NOCOPY  VARCHAR2,
                           x_msg_count               OUT NOCOPY  NUMBER,
                           x_msg_data                OUT NOCOPY  VARCHAR2) IS

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT insert_request;






    -- PVT API call

    okl_credit_memo_pvt.insert_request(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       p_credit_list   => p_credit_list,
                           p_transaction_source => p_transaction_source, -- 5897792
                           p_source_trx_number  => p_source_trx_number,
                                       x_taiv_tbl      => x_taiv_tbl,
                                       x_return_status => l_return_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;






    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);


    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CREDIT_MEMO_PUB','insert_request');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END insert_request;

  --rkuttiya added for bug # 4341480
   PROCEDURE insert_on_acc_cm_request(p_api_version     IN          NUMBER,
                                      p_init_msg_list   IN          VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                      --p_lsm_id          IN          NUMBER,
                                      p_tld_id          IN          NUMBER, -- 5897792
                                      p_credit_amount   IN          NUMBER,
                                      p_credit_sty_id   IN          NUMBER   DEFAULT NULL,
                                      p_credit_desc     IN          VARCHAR2 DEFAULT NULL,
                                      p_credit_date     IN          DATE DEFAULT SYSDATE,
                                      p_try_id          IN          NUMBER   DEFAULT NULL,
                           p_transaction_source IN VARCHAR2 DEFAULT NULL, -- 5897792
                           p_source_trx_number  IN VARCHAR2 DEFAULT NULL,
                                      x_tai_id          OUT NOCOPY  NUMBER,
                                      x_taiv_rec        OUT NOCOPY  taiv_rec_type,
                                      x_return_status   OUT NOCOPY  VARCHAR2,
                                      x_msg_count       OUT NOCOPY  NUMBER,
                                      x_msg_data        OUT NOCOPY  VARCHAR2) IS
   lx_tai_id                NUMBER;

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

  SAVEPOINT insert_request;

-- PVT API call
-- Added p_credit_date as an addtnl parameter. Bug 3816891

  okl_credit_memo_pvt.insert_on_acc_cm_request(p_api_version           => p_api_version,
                                                   p_init_msg_list         => p_init_msg_list,
                                                             --p_lsm_id                => p_lsm_id,
       p_tld_id                => p_tld_id, -- 5897792
                                                               p_credit_amount         => p_credit_amount,
                                                               p_credit_sty_id         => p_credit_sty_id,
                                               p_credit_desc           => p_credit_desc,
                                               p_credit_date           => p_credit_date,
                                               p_try_id                => p_try_id,
       p_transaction_source => p_transaction_source, -- 5897792
       p_source_trx_number  => p_source_trx_number,
                                               x_tai_id                => x_tai_id,
                                               x_taiv_rec              => x_taiv_rec,
                                               x_return_status         => l_return_status,
                                               x_msg_count             => l_msg_count,
                                               x_msg_data              => l_msg_data);

  IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  lx_tai_id := x_tai_id;

  x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO insert_request;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CREDIT_MEMO_PUB','insert_request');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END insert_on_acc_cm_request;

--end fix for bug #4341480

END okl_credit_memo_pub;

/
