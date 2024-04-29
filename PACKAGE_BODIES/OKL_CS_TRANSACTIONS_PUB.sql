--------------------------------------------------------
--  DDL for Package Body OKL_CS_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CS_TRANSACTIONS_PUB" AS
/* $Header: OKLPBFNB.pls 120.3 2008/02/22 10:20:03 dkagrawa ship $ */

  ------------------------------------------------------------------------------
  -- PROCEDURE get_totals
  ------------------------------------------------------------------------------

  PROCEDURE get_totals (p_select          IN           VARCHAR2,
                        p_from            IN           VARCHAR2,
                        p_where           IN           VARCHAR2,
                        x_inv_total       OUT NOCOPY   NUMBER,
                        x_rec_total       OUT NOCOPY   NUMBER,
                        x_due_total       OUT NOCOPY   NUMBER,
			x_credit_total    OUT NOCOPY   NUMBER,
			x_adjust_total    OUT NOCOPY   NUMBER,
                        x_row_count       OUT NOCOPY   NUMBER,
                        x_return_status   OUT NOCOPY   VARCHAR2,
                        x_msg_count       OUT NOCOPY   NUMBER,
                        x_msg_data        OUT NOCOPY   VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT get_totals;





    -- PVT API call

    okl_cs_transactions_pvt.get_totals (p_select          => p_select,
                                        p_from            => p_from,
                                        p_where           => p_where,
                                        x_inv_total       => x_inv_total,
                                        x_rec_total       => x_rec_total,
                                        x_due_total       => x_due_total,
                                        x_credit_total    => x_credit_total,
                                        x_adjust_total    => x_adjust_total,
                                        x_row_count       => x_row_count,
                                        x_return_status   => l_return_status,
                                        x_msg_count       => l_msg_count,
                                        x_msg_data        => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;





    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO get_totals;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_totals;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO get_totals;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME,'get_totals');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

  END get_totals;


  ------------------------------------------------------------------------------
  -- PROCEDURE get_svf_info
  ------------------------------------------------------------------------------

  PROCEDURE get_svf_info (p_khr_id         IN  NUMBER,
                          p_svf_code       IN  VARCHAR2,
                          x_svf_info_rec   OUT NOCOPY svf_info_rec,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT get_svf_info;





    -- PVT API call

    okl_cs_transactions_pvt.get_svf_info (p_khr_id          => p_khr_id,
                                          p_svf_code        => p_svf_code,
                                          x_svf_info_rec    => x_svf_info_rec,
                                          x_return_status   => l_return_status,
                                          x_msg_count       => l_msg_count,
                                          x_msg_data        => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;





    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO get_svf_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_svf_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO get_svf_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'get_svf_info');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END get_svf_info;



  ------------------------------------------------------------------------------
  -- PROCEDURE get_credit_memo_info
  ------------------------------------------------------------------------------

  PROCEDURE get_credit_memo_info (p_khr_id         IN  NUMBER,
                          p_tai_id         IN  NUMBER,
                          x_trx_type       OUT NOCOPY VARCHAR2,
                          x_inv_num        OUT NOCOPY NUMBER,
                          x_trx_date       OUT NOCOPY DATE,
                          x_trx_amount     OUT NOCOPY NUMBER,
                          x_amnt_app       OUT NOCOPY NUMBER,
                          x_amnt_due       OUT NOCOPY NUMBER,
                          x_crd_amnt       OUT NOCOPY NUMBER,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT get_credit_memo_info;





    -- PVT API call

    okl_cs_transactions_pvt.get_credit_memo_info (p_khr_id  => p_khr_id,
                                          p_tai_id          => p_tai_id,
                                          x_trx_type        => x_trx_type,
                                          x_inv_num         => x_inv_num,
                                          x_trx_date        => x_trx_date,
                                          x_trx_amount      => x_trx_amount,
                                          x_amnt_app        => x_amnt_app,
                                          x_amnt_due        => x_amnt_due,
                                          x_crd_amnt        => x_crd_amnt,
                                          x_return_status   => l_return_status,
                                          x_msg_count       => l_msg_count,
                                          x_msg_data        => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;





    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO get_credit_memo_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_credit_memo_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO get_credit_memo_info;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'get_credit_memo_info');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END get_credit_memo_info;


  ------------------------------------------------------------------------------
  -- PROCEDURE check_process_template
  ------------------------------------------------------------------------------

  PROCEDURE check_process_template (p_ptm_code       IN VARCHAR2,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count      OUT NOCOPY NUMBER,
                                    x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT check_process_template;





    -- PVT API call

    okl_cs_transactions_pvt.check_process_template (p_ptm_code        => p_ptm_code,
                                                    x_return_status   => l_return_status,
                                                    x_msg_count       => l_msg_count,
                                                    x_msg_data        => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;





    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO check_process_template;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO check_process_template;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO check_process_template;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'check_process_template');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END check_process_template;


  ------------------------------------------------------------------------------
  -- PROCEDURE get_pvt_label_email
  ------------------------------------------------------------------------------

  PROCEDURE get_pvt_label_email (p_khr_id         IN         NUMBER,
                                 x_email          OUT NOCOPY VARCHAR2,
                                 x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count      OUT NOCOPY NUMBER,
                                 x_msg_data       OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN

    SAVEPOINT get_pvt_label_email;





    -- PVT API call

    okl_cs_transactions_pvt.get_pvt_label_email (p_khr_id          => p_khr_id,
                                                 x_email           => x_email,
                                                 x_return_status   => l_return_status,
                                                 x_msg_count       => l_msg_count,
                                                 x_msg_data        => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;





    x_return_status := l_return_status;


  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO get_pvt_label_email;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_pvt_label_email;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO get_pvt_label_email;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'get_pvt_label_email');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END get_pvt_label_email;


  ------------------------------------------------------------------------------
  -- PROCEDURE create_svf_invoice
  ------------------------------------------------------------------------------

  PROCEDURE create_svf_invoice (p_khr_id             IN NUMBER,
                                p_sty_name           IN VARCHAR2,
                                p_svf_code           IN VARCHAR2,
                                p_svf_amount         IN NUMBER,
                                p_svf_desc           IN VARCHAR2,
                                p_syndication_code   IN VARCHAR2,
                                p_factoring_code     IN VARCHAR2,
                                x_tai_id             OUT NOCOPY NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

    l_syndication_code       VARCHAR2(30);
    l_factoring_code         VARCHAR2(30);

    lx_tai_id                 NUMBER;

  BEGIN

    SAVEPOINT create_svf_invoice;

    l_syndication_code := p_syndication_code;
    l_factoring_code   := p_factoring_code;





    -- PVT API call

    okl_cs_transactions_pvt.create_svf_invoice (p_khr_id            => p_khr_id,
                                                p_sty_name          => p_sty_name,
                                                p_svf_code          => p_svf_code,
                                                p_svf_amount        => p_svf_amount,
                                                p_svf_desc          => p_svf_desc,
                                                p_syndication_code  => l_syndication_code,
                                                p_factoring_code    => l_factoring_code,
                                                x_tai_id            => x_tai_id,
                                                x_return_status     => l_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;



    lx_tai_id := x_tai_id;



    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO create_svf_invoice;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_svf_invoice;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                 p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_svf_invoice;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(G_PKG_NAME, 'create_svf_invoice');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END create_svf_invoice;


END okl_cs_transactions_pub;

/
