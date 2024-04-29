--------------------------------------------------------
--  DDL for Package Body OKL_CS_PRINCIPAL_PAYDOWN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_PRINCIPAL_PAYDOWN_PUB" AS
/* $Header: OKLPPPDB.pls 120.3 2005/10/26 13:05:12 rkuttiya noship $ */


 PROCEDURE create_working_copy(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                p_commit                 IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_chr_id                IN NUMBER,
                x_chr_id                OUT NOCOPY NUMBER)
    AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_chr_id                 NUMBER;

  BEGIN






  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.create_working_copy (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                   p_commit        => p_commit,
                                                   p_chr_id        => p_chr_id,
                                                   x_chr_id        => x_chr_id,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('okl_cs_principal_paydown_PUB','create_working_copy');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

END create_working_copy;

   PROCEDURE calculate(
                p_api_version           IN      NUMBER,
                p_init_msg_list         IN      VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_trqv_tbl              IN okl_trx_requests_pub.trqv_tbl_type,
                x_trqv_tbl              OUT NOCOPY okl_trx_requests_pub.trqv_tbl_type)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_chr_id                 NUMBER;

  BEGIN






  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.calculate (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
--                                                   p_commit        => p_commit,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data,
                                                   p_trqv_tbl      => p_trqv_tbl,
                                                   x_trqv_tbl      => x_trqv_tbl);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('okl_cs_principal_paydown_PUB','calculate');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

END calculate;

PROCEDURE update_ppd_request(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_trqv_rec              IN  okl_trx_requests_pub.trqv_rec_type
    ,x_trqv_rec              OUT  NOCOPY okl_trx_requests_pub.trqv_rec_type)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_chr_id                 NUMBER;

  BEGIN






  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.update_ppd_request (p_api_version   => p_api_version,
                                                    p_init_msg_list => p_init_msg_list,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => l_msg_count,
                                                   x_msg_data      => l_msg_data,
                                                   p_trqv_rec      => p_trqv_rec,
                                                   x_trqv_rec      => x_trqv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('okl_cs_principal_paydown_PUB','update_ppd_request');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

END update_ppd_request;


PROCEDURE create_ppd_invoice (p_khr_id          IN NUMBER,
                                p_ppd_amount        IN NUMBER,
                                p_ppd_desc          IN VARCHAR2,
                                p_syndication_code  IN VARCHAR2,
                                p_factoring_code    IN VARCHAR2,
                                x_tai_id            OUT NOCOPY NUMBER,
                                x_return_status     OUT NOCOPY VARCHAR2,
                                x_msg_count         OUT NOCOPY NUMBER,
                                x_msg_data          OUT NOCOPY VARCHAR2)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_chr_id                 NUMBER;

  BEGIN






  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.create_ppd_invoice (p_khr_id           => p_khr_id,
                                                            p_ppd_amount       => p_ppd_amount,
                                                            p_ppd_desc         => p_ppd_desc,
                                                            p_syndication_code => p_syndication_code,
                                                            p_factoring_code   => p_factoring_code,
                                                            x_tai_id           => x_tai_id,
                                                            x_return_status    => l_return_status,
                                                            x_msg_count        => l_msg_count,
                                                            x_msg_data         => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('okl_cs_principal_paydown_PUB','create_ppd_invoice');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

END create_ppd_invoice;



 PROCEDURE cancel_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_chr_id                 NUMBER;

  BEGIN
  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.cancel_ppd (p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count     => l_msg_count,
                                             x_msg_data      => l_msg_data,
                                             p_khr_id        => p_khr_id);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------
  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CS_PRINCIPAL_PAYDOWN_PUB','cancel_ppd');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);
END cancel_ppd;


 PROCEDURE invoice_apply_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_khr_id               IN  NUMBER
                ,p_trx_id               IN  NUMBER)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN
  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.invoice_apply_ppd (p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count     => l_msg_count,
                                             x_msg_data      => l_msg_data,
                                             p_khr_id        => p_khr_id,
                                             p_trx_id        => p_trx_id);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------
  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CS_PRINCIPAL_PAYDOWN_PUB','invoice_apply_ppd');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);
END invoice_apply_ppd;


 PROCEDURE process_ppd(
                p_api_version           IN  NUMBER
                ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                ,x_return_status        OUT  NOCOPY VARCHAR2
                ,x_msg_count            OUT  NOCOPY NUMBER
                ,x_msg_data             OUT  NOCOPY VARCHAR2
                ,p_ppd_request_id       IN  NUMBER)
     AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN
  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.process_ppd (p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count     => l_msg_count,
                                             x_msg_data      => l_msg_data,
                                             p_ppd_request_id => p_ppd_request_id);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------
  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CS_PRINCIPAL_PAYDOWN_PUB','process_ppd');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);
END process_ppd;

PROCEDURE process_lpd(
    p_api_version		IN  NUMBER,
    p_init_msg_list		IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status		OUT NOCOPY VARCHAR2,
    x_msg_count			OUT NOCOPY NUMBER,
    x_msg_data			OUT NOCOPY VARCHAR2,
    p_ppd_request_id    	IN  NUMBER)
AS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN
  ------------ Call to Private Process API--------------

    okl_cs_principal_paydown_pvt.process_lpd (p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => l_return_status,
                                             x_msg_count     => l_msg_count,
                                             x_msg_data      => l_msg_data,
                                             p_ppd_request_id => p_ppd_request_id);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------
  x_return_status := l_return_status;
  x_msg_count     := l_msg_count;
  x_msg_data      := l_msg_data;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CS_PRINCIPAL_PAYDOWN_PUB','process_ppd');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);
END process_lpd;

END OKL_CS_PRINCIPAL_PAYDOWN_PUB;

/
