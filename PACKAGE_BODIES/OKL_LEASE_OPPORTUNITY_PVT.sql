--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_OPPORTUNITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_OPPORTUNITY_PVT" AS
/* $Header: OKLRLOPB.pls 120.17.12010000.2 2008/11/13 13:06:39 kkorrapo ship $ */

  CURSOR c_functional_currency IS
    SELECT OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE
    FROM DUAL;

  -------------------------------
  -- PROCEDURE validate_lease_opp
  -------------------------------
  PROCEDURE validate_lease_opp (p_lease_opp_rec         IN lease_opp_rec_type,
                                x_return_status         OUT NOCOPY VARCHAR2) IS

    l_return_status    VARCHAR2(1);

    l_program_name      CONSTANT VARCHAR2(30) := 'validate_lease_opp';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;
    l_db_lease_opp_rec  lease_opp_rec_type;

    CURSOR chk_uniquness (p_reference_number VARCHAR2) IS
      SELECT '1'
      FROM okl_lease_opportunities_b
      WHERE  reference_number = p_reference_number
      AND    id <> NVL(p_lease_opp_rec.id, -9999);

    l_refno_unq_chk         NUMBER;

    --Bug 7022258-Added by kkorrapo
    l_valid varchar2(3);
    --Bug 7022258--Addition end

    l_functional_currency   VARCHAR2(15);

  BEGIN

    OPEN chk_uniquness(p_lease_opp_rec.reference_number);
    FETCH chk_uniquness INTO l_refno_unq_chk;
    CLOSE chk_uniquness;

    IF l_refno_unq_chk IS NOT NULL THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_REFNO_UNIQUE_CHECK');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- viselvar added this validation for Bug 5042858
    l_return_status := OKL_LEASE_APP_PVT.is_curr_conv_valid(
                          p_curr_code    => p_lease_opp_rec.currency_code
                         ,p_curr_type    => p_lease_opp_rec.currency_conversion_type
                         ,p_curr_rate    => p_lease_opp_rec.currency_conversion_rate
                         ,p_curr_date    => p_lease_opp_rec.currency_conversion_date);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*OPEN c_functional_currency;
    FETCH c_functional_currency INTO l_functional_currency;
    CLOSE c_functional_currency;

    IF p_lease_opp_rec.currency_code <> l_functional_currency THEN

      IF p_lease_opp_rec.currency_conversion_type IS NULL THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_REQUIRED_CURRENCY_TYPE');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF p_lease_opp_rec.currency_conversion_date IS  NULL THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_REQUIRED_CURRENCY_DATE');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF p_lease_opp_rec.currency_conversion_type = 'User' AND p_lease_opp_rec.CURRENCY_CONVERSION_RATE IS NOT NULL THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_REQUIRED_CURRENCY_RATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSE

      IF p_lease_opp_rec.CURRENCY_CONVERSION_TYPE IS NOT NULL THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_NOTREQUIRED_CURRENCY_TYPE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF p_lease_opp_rec.CURRENCY_CONVERSION_DATE IS NOT NULL THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_NOTREQUIRED_CURRENCY_DATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF p_lease_opp_rec.CURRENCY_CONVERSION_RATE IS NOT NULL THEN
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_NOTREQUIRED_CURRENCY_RATE');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;*/

    -- Date Validations
    IF p_lease_opp_rec.expected_start_date  < p_lease_opp_rec.valid_from THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LOP_INVALID_START_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_opp_rec.funding_date  < p_lease_opp_rec.valid_from THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LOP_INVALID_FUNDING_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_lease_opp_rec.delivery_date  < p_lease_opp_rec.valid_from THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LOP_INVALID_DELV_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_lease_opp;


  -----------------------------
  -- PROCEDURE create_lease_opp
  -----------------------------
  PROCEDURE create_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              p_quick_quote_id          IN  NUMBER,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_lease_opp';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_opp_rec        lease_opp_rec_type;
    l_functional_currency  VARCHAR2(15);

    l_return_status        VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_lease_opp_rec := p_lease_opp_rec;

    l_lease_opp_rec.valid_from               := TRUNC(l_lease_opp_rec.valid_from);
    l_lease_opp_rec.expected_start_date      := TRUNC(l_lease_opp_rec.expected_start_date);
    l_lease_opp_rec.delivery_date            := TRUNC(l_lease_opp_rec.delivery_date);
    l_lease_opp_rec.funding_date             := TRUNC(l_lease_opp_rec.funding_date);
    l_lease_opp_rec.currency_conversion_date := TRUNC(l_lease_opp_rec.currency_conversion_date);

    l_lease_opp_rec.status                   := 'INCOMPLETE';

    --Bug 7022258-Modified by kkorrapo
    l_lease_opp_rec.reference_number         := l_lease_opp_rec.reference_number;
    --Bug 7022258--Modification end


    --Bug 5100228 Begin
      l_return_status := okl_lease_app_pvt.is_curr_conv_valid(
                          p_curr_code    => l_lease_opp_rec.currency_code
                         ,p_curr_type    => l_lease_opp_rec.currency_conversion_type
                         ,p_curr_rate    => l_lease_opp_rec.currency_conversion_rate
                         ,p_curr_date    => l_lease_opp_rec.currency_conversion_date);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 5100228 End

    validate_lease_opp(p_lease_opp_rec => l_lease_opp_rec,
                       x_return_status => l_return_status);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    okl_lop_pvt.insert_row(
                       p_api_version   => G_API_VERSION
                      ,p_init_msg_list => G_TRUE
                      ,x_return_status => l_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_lopv_rec      => l_lease_opp_rec
                      ,x_lopv_rec      => x_lease_opp_rec
                      );

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_quick_quote_id IS NOT NULL THEN

      UPDATE okl_quick_quotes_b SET
        lease_opportunity_id = x_lease_opp_rec.id
       ,currency_code = l_lease_opp_rec.currency_code
       ,program_agreement_id = l_lease_opp_rec.program_agreement_id
      WHERE id = p_quick_quote_id;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_lease_opp;


  -----------------------------
  -- PROCEDURE update_lease_opp
  -----------------------------
  PROCEDURE update_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_lease_opp';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_opp_rec        lease_opp_rec_type;
    l_functional_currency  VARCHAR2(15);

    l_return_status        VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_lease_opp_rec := p_lease_opp_rec;

    --Bug 4895154 Beging
    IF l_lease_opp_rec.STATUS <> 'CANCELLED' THEN
    --Bug 4895154 END

      l_lease_opp_rec.valid_from               := TRUNC(l_lease_opp_rec.valid_from);
      l_lease_opp_rec.expected_start_date      := TRUNC(l_lease_opp_rec.expected_start_date);
      l_lease_opp_rec.delivery_date            := TRUNC(l_lease_opp_rec.delivery_date);
      l_lease_opp_rec.funding_date             := TRUNC(l_lease_opp_rec.funding_date);
      l_lease_opp_rec.currency_conversion_date := TRUNC(l_lease_opp_rec.currency_conversion_date);

    --Bug 5100228 Begin
      l_return_status := okl_lease_app_pvt.is_curr_conv_valid(
                          p_curr_code    => l_lease_opp_rec.currency_code
                         ,p_curr_type    => l_lease_opp_rec.currency_conversion_type
                         ,p_curr_rate    => l_lease_opp_rec.currency_conversion_rate
                         ,p_curr_date    => l_lease_opp_rec.currency_conversion_date);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR)
    THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 5100228 End

      validate_lease_opp(p_lease_opp_rec => l_lease_opp_rec,
                         x_return_status => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    --Bug 4895154 Beging
    END IF;
    --Bug 4895154 END

    okl_lop_pvt.update_row(
                       p_api_version   => G_API_VERSION
                      ,p_init_msg_list => G_TRUE
                      ,x_return_status => l_return_status
                      ,x_msg_count     => x_msg_count
                      ,x_msg_data      => x_msg_data
                      ,p_lopv_rec      => l_lease_opp_rec
                      ,x_lopv_rec      => x_lease_opp_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_lease_opp;


  ------------------------------------
  -- PROCEDURE cancel_lease_opp_childs
  ------------------------------------
  PROCEDURE cancel_lease_opp_childs (
    p_lease_opp_id   IN  NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   ,x_msg_count     OUT NOCOPY NUMBER
   ,x_msg_data      OUT NOCOPY VARCHAR2
   ) IS

    l_program_name           CONSTANT VARCHAR2(30) := 'cancel_lease_opp_childs';
    l_api_name               CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    i                        PLS_INTEGER;
    l_return_status          VARCHAR2(1);
    l_del_lease_qte_tbl      okl_lease_quote_pvt.lease_qte_tbl_type;

    CURSOR c_lsq IS
      SELECT lsq.id
      FROM   okl_lease_quotes_b lsq
      WHERE  lsq.parent_object_code = 'LEASEOPP'
        AND  lsq.parent_object_id = p_lease_opp_id;

    CURSOR c_qqh IS
      SELECT qqh.id
      FROM   okl_quick_quotes_b qqh
      WHERE  lease_opportunity_id = p_lease_opp_id;

  BEGIN

    FOR l_qqh IN c_qqh LOOP

      DELETE FROM okl_quick_quote_lines_tl WHERE id IN (SELECT id FROM okl_quick_quote_lines_b WHERE quick_quote_id = l_qqh.id);
      DELETE FROM okl_quick_quote_lines_b WHERE quick_quote_id = l_qqh.id;
      DELETE FROM okl_quick_quotes_b WHERE id = l_qqh.id;
      DELETE FROM okl_quick_quotes_tl WHERE id = l_qqh.id;

    END LOOP;

    FOR l_lsq IN c_lsq LOOP
      i := i + 1;
      l_del_lease_qte_tbl(i).id := l_lsq.id;
    END LOOP;

    IF l_del_lease_qte_tbl.COUNT > 0 THEN

      okl_lease_quote_pvt.cancel_lease_qte(
                                           p_api_version         => G_API_VERSION
                                          ,p_init_msg_list       => G_TRUE
                                          ,p_transaction_control => G_TRUE
                                          ,x_return_status       => l_return_status
                                          ,x_msg_count           => x_msg_count
                                          ,x_msg_data            => x_msg_data
                                          ,p_lease_qte_tbl       => l_del_lease_qte_tbl);


      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;

    x_return_status  :=  G_RET_STS_SUCCESS;

  EXCEPTION

   WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_lease_opp_childs;


 ------------------------------
  -- PROCEDURE cancel_lease_opp
 ------------------------------
  PROCEDURE cancel_lease_opp (p_api_version             IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_id            IN  NUMBER,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'cancel_lease_opp';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lopv_rec          lease_opp_rec_type;
    q_lopv_rec          lease_opp_rec_type;

    i                   PLS_INTEGER;

    l_return_status     VARCHAR2(1);

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;


	l_lopv_rec.id := p_lease_opp_id;
	l_lopv_rec.status := 'CANCELLED';

	Select object_version_number
	into l_lopv_rec.object_version_number
	from Okl_lease_opportunities_b
	where id = p_lease_opp_id;

    update_lease_opp (p_api_version          => p_api_version
                      ,p_init_msg_list       => p_init_msg_list
                      ,p_transaction_control => p_transaction_control
                      ,p_lease_opp_rec       => l_lopv_rec
                      ,x_lease_opp_rec       => q_lopv_rec
                      ,x_return_status       => l_return_status
                      ,x_msg_count           => x_msg_count
                      ,x_msg_data            => x_msg_data);


    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Handle Subsidy pool usage
    okl_lease_quote_subpool_pvt.process_cancel_leaseopp(
						   p_api_version         => G_API_VERSION
                          ,p_init_msg_list       => G_TRUE
                          ,p_transaction_control => G_TRUE
                          ,p_parent_object_id    => p_lease_opp_id
                          ,x_return_status       => l_return_status
                          ,x_msg_count           => x_msg_count
                          ,x_msg_data            => x_msg_data);
    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status  :=  G_RET_STS_SUCCESS;

  EXCEPTION

     WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END cancel_lease_opp;


  -----------------------------------
  -- PROCEDURE defaults_for_lease_opp
  -----------------------------------
  PROCEDURE defaults_for_lease_opp (p_api_version       IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              p_user_id                 IN  VARCHAR2,
                              x_sales_rep_name          OUT NOCOPY VARCHAR2,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_dff_name                OUT NOCOPY VARCHAR2,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'defaults_for_lease_opp';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_lease_opp_rec     lease_opp_rec_type;
    l_sales_rep_name    VARCHAR2(240);
    l_dff_name          VARCHAR2(40);

    l_return_status     VARCHAR2(1);

    CURSOR c_prop_tax_dflts IS
      SELECT property_tax_applicable,
             bill_property_tax
      FROM   okl_property_tax_setups
      WHERE  org_id = mo_global.get_current_org_id();

    CURSOR c_reference_number IS
      SELECT okl_util.get_next_seq_num('OKL_LOP_REF_SEQ','OKL_LEASE_OPPORTUNITIES_B','REFERENCE_NUMBER') FROM DUAL;--Bug 7022258-Modified by kkorrapo

    CURSOR c_sales_rep_dflts IS
       SELECT rep.salesrep_id sales_rep_id
              ,rep.name sales_rep_name
       FROM   jtf_rs_salesreps rep
              ,jtf_rs_resource_extns res
       WHERE  rep.org_id = mo_global.get_current_org_id()
       AND    rep.resource_id = res.resource_id
       AND    res.user_id = G_USER_ID;

    CURSOR c_dff_name IS
      SELECT descriptive_flexfield_name
      FROM   fnd_descriptive_flexs
      WHERE  table_application_id = 540
      AND    application_table_name = 'OKL_LEASE_OPPORTUNITIES_B'
      AND    context_column_name = 'ATTRIBUTE_CATEGORY'
      AND    freeze_flex_definition_flag = 'Y';

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    OPEN c_functional_currency;
    FETCH c_functional_currency INTO l_lease_opp_rec.currency_code;
    CLOSE c_functional_currency;

    OPEN c_prop_tax_dflts;
    FETCH c_prop_tax_dflts INTO
      l_lease_opp_rec.property_tax_applicable,
      l_lease_opp_rec.property_tax_billing_type;
    CLOSE c_prop_tax_dflts;

    OPEN c_reference_number;
    FETCH c_reference_number INTO l_lease_opp_rec.reference_number;
    CLOSE c_reference_number;

    OPEN c_sales_rep_dflts;
    FETCH c_sales_rep_dflts INTO
      l_lease_opp_rec.sales_rep_id,
      l_sales_rep_name;
    CLOSE c_sales_rep_dflts;

    OPEN c_dff_name;
    FETCH c_dff_name INTO l_dff_name;
    CLOSE c_dff_name;

    x_sales_rep_name := l_sales_rep_name;
    x_dff_name       := l_dff_name;
    x_lease_opp_rec  := l_lease_opp_rec;

    x_return_status  :=  G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END defaults_for_lease_opp;


  --------------------------------
  -- PROCEDURE duplicate_lease_opp
  --------------------------------
  PROCEDURE duplicate_lease_opp (p_api_version          IN  NUMBER,
                              p_init_msg_list           IN  VARCHAR2,
                              p_transaction_control     IN  VARCHAR2,
                              p_source_leaseopp_id      IN  NUMBER,
                              p_lease_opp_rec           IN  lease_opp_rec_type,
                              x_lease_opp_rec           OUT NOCOPY lease_opp_rec_type,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_msg_count               OUT NOCOPY NUMBER,
                              x_msg_data                OUT NOCOPY VARCHAR2) IS

    l_program_name      CONSTANT VARCHAR2(30) := 'duplicate_lease_opp';
    l_api_name          CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    lx_lease_qte_rec  okl_lease_quote_pvt.lease_qte_rec_type;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    create_lease_opp (
        p_api_version         => G_API_VERSION
       ,p_init_msg_list       => G_TRUE
       ,p_transaction_control => G_TRUE
       ,p_lease_opp_rec       => p_lease_opp_rec
       ,p_quick_quote_id      => NULL
       ,x_lease_opp_rec       => x_lease_opp_rec
       ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
       );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	-- Duplicate Estimates
	okl_quick_quotes_pvt.duplicate_estimate(
        p_api_version         => G_API_VERSION
       ,p_init_msg_list       => G_TRUE
       ,source_lopp_id        => p_source_leaseopp_id
       ,target_lopp_id        => x_lease_opp_rec.id
       ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	-- Duplicate Quotes
    okl_lease_quote_pvt.duplicate_quotes (
        p_api_version         => G_API_VERSION
       ,p_init_msg_list       => G_TRUE
       ,p_transaction_control => G_TRUE
       ,p_source_leaseopp_id  => p_source_leaseopp_id
       ,p_target_leaseopp_id  => x_lease_opp_rec.id
       ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      IF p_transaction_control = G_TRUE THEN
        ROLLBACK TO l_program_name;
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data  => x_msg_data);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END duplicate_lease_opp;

END OKL_LEASE_OPPORTUNITY_PVT;

/
