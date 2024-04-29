--------------------------------------------------------
--  DDL for Package Body OKL_LEASE_QUOTE_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASE_QUOTE_INS_PVT" AS
/* $Header: OKLRQUIB.pls 120.2.12010000.2 2008/11/18 10:23:21 kkorrapo ship $ */


  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  PROCEDURE validate_record (
     p_insurance_estimate_rec  IN  ins_est_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'validate_record';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_mpp                  BINARY_INTEGER;

  BEGIN

    IF p_insurance_estimate_rec.policy_term <= 0 THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIOD_ZERO');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF TRUNC(p_insurance_estimate_rec.policy_term) <> p_insurance_estimate_rec.policy_term THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_PERIOD_FRACTION');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_insurance_estimate_rec.periodic_amount < 0 THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_LEVEL_AMOUNT_ZERO');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_insurance_estimate_rec.payment_frequency = 'A' THEN
      l_mpp := 12;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'S' THEN
      l_mpp := 6;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'Q' THEN
      l_mpp := 3;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'M' THEN
      l_mpp := 1;
    END IF;

    IF (p_insurance_estimate_rec.policy_term / l_mpp) <> TRUNC (p_insurance_estimate_rec.policy_term / l_mpp) THEN
      OKL_API.SET_MESSAGE (p_app_name => G_APP_NAME, p_msg_name => 'OKL_TERM_FREQ_MISMATCH');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END validate_record;


  -----------------------
  -- PROCEDURE insert_row
  -----------------------
  PROCEDURE insert_row (
     p_insurance_estimate_rec  IN  OUT NOCOPY ins_est_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'insert_row';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_quev_rec             okl_que_pvt.quev_rec_type;
    lx_quev_rec            okl_que_pvt.quev_rec_type;

  BEGIN

    l_quev_rec.lease_quote_id     := p_insurance_estimate_rec.lease_quote_id;
    l_quev_rec.policy_term        := p_insurance_estimate_rec.policy_term;
    l_quev_rec.description        := p_insurance_estimate_rec.description;
    --Bug#6935907 -Added by kkorrapo
    l_quev_rec.attribute_category := p_insurance_estimate_rec.attribute_category;
    l_quev_rec.attribute1 :=  p_insurance_estimate_rec.attribute1;
    l_quev_rec.attribute2 :=  p_insurance_estimate_rec.attribute2;
    l_quev_rec.attribute3 :=  p_insurance_estimate_rec.attribute3;
    l_quev_rec.attribute4 :=  p_insurance_estimate_rec.attribute4;
    l_quev_rec.attribute5 :=  p_insurance_estimate_rec.attribute5;
    l_quev_rec.attribute6 :=  p_insurance_estimate_rec.attribute6;
    l_quev_rec.attribute7 :=  p_insurance_estimate_rec.attribute7;
    l_quev_rec.attribute8 :=  p_insurance_estimate_rec.attribute8;
    l_quev_rec.attribute9 :=  p_insurance_estimate_rec.attribute9;
    l_quev_rec.attribute10 := p_insurance_estimate_rec.attribute10;
    l_quev_rec.attribute11 := p_insurance_estimate_rec.attribute11;
    l_quev_rec.attribute12 := p_insurance_estimate_rec.attribute12;
    l_quev_rec.attribute13 := p_insurance_estimate_rec.attribute13;
    l_quev_rec.attribute14 := p_insurance_estimate_rec.attribute14;
    l_quev_rec.attribute15 := p_insurance_estimate_rec.attribute15;
    --Bug#6935907 -Addition end

    okl_que_pvt.insert_row (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     ,p_quev_rec            => l_quev_rec
     ,x_quev_rec            => lx_quev_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    p_insurance_estimate_rec.id := lx_quev_rec.id;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------
  -- PROCEDURE update_row
  -----------------------
  PROCEDURE update_row (
     p_insurance_estimate_rec  IN  ins_est_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_row';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_quev_rec             okl_que_pvt.quev_rec_type;
    lx_quev_rec            okl_que_pvt.quev_rec_type;

  BEGIN

    l_quev_rec.id                    := p_insurance_estimate_rec.id;
    l_quev_rec.object_version_number := p_insurance_estimate_rec.ovn;
    l_quev_rec.lease_quote_id        := p_insurance_estimate_rec.lease_quote_id;
    l_quev_rec.policy_term           := p_insurance_estimate_rec.policy_term;
    l_quev_rec.description           := p_insurance_estimate_rec.description;
    --Bug#6935907 -Added by kkorrapo
    l_quev_rec.attribute_category := p_insurance_estimate_rec.attribute_category;
    l_quev_rec.attribute1 :=  p_insurance_estimate_rec.attribute1;
    l_quev_rec.attribute2 :=  p_insurance_estimate_rec.attribute2;
    l_quev_rec.attribute3 :=  p_insurance_estimate_rec.attribute3;
    l_quev_rec.attribute4 :=  p_insurance_estimate_rec.attribute4;
    l_quev_rec.attribute5 :=  p_insurance_estimate_rec.attribute5;
    l_quev_rec.attribute6 :=  p_insurance_estimate_rec.attribute6;
    l_quev_rec.attribute7 :=  p_insurance_estimate_rec.attribute7;
    l_quev_rec.attribute8 :=  p_insurance_estimate_rec.attribute8;
    l_quev_rec.attribute9 :=  p_insurance_estimate_rec.attribute9;
    l_quev_rec.attribute10 := p_insurance_estimate_rec.attribute10;
    l_quev_rec.attribute11 := p_insurance_estimate_rec.attribute11;
    l_quev_rec.attribute12 := p_insurance_estimate_rec.attribute12;
    l_quev_rec.attribute13 := p_insurance_estimate_rec.attribute13;
    l_quev_rec.attribute14 := p_insurance_estimate_rec.attribute14;
    l_quev_rec.attribute15 := p_insurance_estimate_rec.attribute15;
    --Bug#6935907 -Addition end

    okl_que_pvt.update_row (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     ,p_quev_rec            => l_quev_rec
     ,x_quev_rec            => lx_quev_rec
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
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
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ----------------------------
  -- PROCEDURE create_cashflow
  ----------------------------
  PROCEDURE create_cashflow (
     p_insurance_estimate_rec  IN  ins_est_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'create_cashflow';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cashflow_header_rec  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_cashflow_level_tbl   okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

    l_mpp                  BINARY_INTEGER;

  BEGIN

    l_cashflow_header_rec.type_code           := 'INFLOW';
    l_cashflow_header_rec.stream_type_id      := p_insurance_estimate_rec.stream_type_id;
    l_cashflow_header_rec.arrears_flag        := 'N';
    l_cashflow_header_rec.frequency_code      := p_insurance_estimate_rec.payment_frequency;
    l_cashflow_header_rec.parent_object_code  := 'QUOTED_INSURANCE';
    l_cashflow_header_rec.parent_object_id    := p_insurance_estimate_rec.id;
    l_cashflow_header_rec.quote_type_code     := p_insurance_estimate_rec.quote_type_code;
    l_cashflow_header_rec.quote_id            := p_insurance_estimate_rec.lease_quote_id;

    IF p_insurance_estimate_rec.payment_frequency = 'A' THEN
      l_mpp := 12;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'S' THEN
      l_mpp := 6;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'Q' THEN
      l_mpp := 3;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'M' THEN
      l_mpp := 1;
    END IF;

    l_cashflow_level_tbl(1).periods             := p_insurance_estimate_rec.policy_term / l_mpp;
    l_cashflow_level_tbl(1).periodic_amount     := p_insurance_estimate_rec.periodic_amount;
    l_cashflow_level_tbl(1).record_mode         := 'CREATE';

    okl_lease_quote_cashflow_pvt.create_cashflow (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,p_transaction_control => G_FALSE
     ,p_cashflow_header_rec => l_cashflow_header_rec
     ,p_cashflow_level_tbl  => l_cashflow_level_tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_cashflow;


  ----------------------------
  -- PROCEDURE update_cashflow
  ----------------------------
  PROCEDURE update_cashflow (
     p_insurance_estimate_rec  IN  ins_est_rec_type
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'update_cashflow';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_cashflow_header_rec  okl_lease_quote_cashflow_pvt.cashflow_header_rec_type;
    l_cashflow_level_tbl   okl_lease_quote_cashflow_pvt.cashflow_level_tbl_type;

    l_mpp                  BINARY_INTEGER;

  BEGIN

    l_cashflow_header_rec.type_code           := 'INFLOW';
    l_cashflow_header_rec.stream_type_id      := p_insurance_estimate_rec.stream_type_id;
    l_cashflow_header_rec.arrears_flag        := 'N';
    l_cashflow_header_rec.frequency_code      := p_insurance_estimate_rec.payment_frequency;
    l_cashflow_header_rec.parent_object_code  := 'QUOTED_INSURANCE';
    l_cashflow_header_rec.parent_object_id    := p_insurance_estimate_rec.id;
    l_cashflow_header_rec.quote_type_code     := p_insurance_estimate_rec.quote_type_code;
    l_cashflow_header_rec.quote_id            := p_insurance_estimate_rec.lease_quote_id;
    l_cashflow_header_rec.cashflow_header_id  := p_insurance_estimate_rec.cashflow_header_id;
    l_cashflow_header_rec.cashflow_object_id  := p_insurance_estimate_rec.cashflow_object_id;
    l_cashflow_header_rec.cashflow_header_ovn := p_insurance_estimate_rec.cashflow_header_ovn;

    IF p_insurance_estimate_rec.payment_frequency = 'A' THEN
      l_mpp := 12;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'S' THEN
      l_mpp := 6;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'Q' THEN
      l_mpp := 3;
    ELSIF p_insurance_estimate_rec.payment_frequency = 'M' THEN
      l_mpp := 1;
    END IF;

    l_cashflow_level_tbl(1).cashflow_level_id   := p_insurance_estimate_rec.cashflow_level_id;
    l_cashflow_level_tbl(1).cashflow_level_ovn  := p_insurance_estimate_rec.cashflow_level_ovn;
    l_cashflow_level_tbl(1).periods             := p_insurance_estimate_rec.policy_term / l_mpp;
    l_cashflow_level_tbl(1).periodic_amount     := p_insurance_estimate_rec.periodic_amount;
    l_cashflow_level_tbl(1).record_mode         := 'UPDATE';

    okl_lease_quote_cashflow_pvt.update_cashflow (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,p_transaction_control => G_FALSE
     ,p_cashflow_header_rec => l_cashflow_header_rec
     ,p_cashflow_level_tbl  => l_cashflow_level_tbl
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_program_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_cashflow;


  --------------------------------------
  -- PROCEDURE create_insurance_estimate
  --------------------------------------
  PROCEDURE create_insurance_estimate (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_insurance_estimate_rec  IN  ins_est_rec_type
   ,x_insurance_estimate_id   OUT NOCOPY NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

    l_program_name            CONSTANT VARCHAR2(30) := 'create_insurance_estimate';
    l_api_name                CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_insurance_estimate_rec  ins_est_rec_type;


     --Bug#6935907 -Added by kkorrapo
    Cursor c_par_obj_code IS
    SELECT parent_object_code
    FROM okl_lease_quotes_b
    WHERE id = p_insurance_estimate_rec.lease_quote_id;

    l_parent_object_code  VARCHAR2(30);
    --Bug#6935907 -Addition end


  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_insurance_estimate_rec := p_insurance_estimate_rec;


    --Bug#6935907 -Added by kkorrapo
    OPEN c_par_obj_code;
    FETCH c_par_obj_code INTO l_parent_object_code;
    CLOSE c_par_obj_code;

    IF (l_parent_object_code = 'LEASEOPP') THEN
       l_insurance_estimate_rec.quote_type_code := 'LQ';
    ELSIF (l_parent_object_code = 'LEASEAPP') THEN
         l_insurance_estimate_rec.quote_type_code := 'LA';
    ELSE
         l_insurance_estimate_rec.quote_type_code := 'QQ';
    END IF;
    --Bug#6935907 -Addition end
    validate_record (
      p_insurance_estimate_rec => l_insurance_estimate_rec
     ,x_return_status          => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (
      p_insurance_estimate_rec  => l_insurance_estimate_rec
     ,x_return_status           => x_return_status
     ,x_msg_count               => x_msg_count
     ,x_msg_data                => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    create_cashflow (
      p_insurance_estimate_rec => l_insurance_estimate_rec
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_insurance_estimate_id := l_insurance_estimate_rec.id;
    x_return_status         := G_RET_STS_SUCCESS;

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

  END create_insurance_estimate;


  --------------------------------------
  -- PROCEDURE update_insurance_estimate
  --------------------------------------
  PROCEDURE update_insurance_estimate (
    p_api_version             IN  NUMBER
   ,p_init_msg_list           IN  VARCHAR2
   ,p_transaction_control     IN  VARCHAR2
   ,p_insurance_estimate_rec  IN  ins_est_rec_type
   ,x_return_status           OUT NOCOPY VARCHAR2
   ,x_msg_count               OUT NOCOPY NUMBER
   ,x_msg_data                OUT NOCOPY VARCHAR2
   ) IS

    l_program_name            CONSTANT VARCHAR2(30) := 'update_insurance_estimate';
    l_api_name                CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

    l_insurance_estimate_rec  ins_est_rec_type;

   --Bug#6935907 -Added by kkorrapo
    Cursor c_par_obj_code IS
    SELECT parent_object_code
    FROM okl_lease_quotes_b
    WHERE id = p_insurance_estimate_rec.lease_quote_id;

    l_parent_object_code  VARCHAR2(30);
   --Bug#6935907 -Addition end
  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_insurance_estimate_rec := p_insurance_estimate_rec;
    --Bug#6935907 -Added by kkorrapo
    OPEN c_par_obj_code;
    FETCH c_par_obj_code INTO l_parent_object_code;
    CLOSE c_par_obj_code;

     IF (l_parent_object_code = 'LEASEOPP') THEN
         l_insurance_estimate_rec.quote_type_code := 'LQ';
     ELSIF (l_parent_object_code = 'LEASEAPP') THEN
    	 l_insurance_estimate_rec.quote_type_code := 'LA';
     ELSE
         l_insurance_estimate_rec.quote_type_code := 'QQ';
     END IF;
     --Bug#6935907 -Addition end
    validate_record (
      p_insurance_estimate_rec => l_insurance_estimate_rec
     ,x_return_status          => x_return_status
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (
      p_insurance_estimate_rec  => l_insurance_estimate_rec
     ,x_return_status           => x_return_status
     ,x_msg_count               => x_msg_count
     ,x_msg_data                => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_cashflow (
      p_insurance_estimate_rec => l_insurance_estimate_rec
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data
     );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status         := G_RET_STS_SUCCESS;

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

  END update_insurance_estimate;


  --------------------------------------
  -- PROCEDURE delete_insurance_estimate
  --------------------------------------
  PROCEDURE delete_insurance_estimate (
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2
    ,p_transaction_control     IN  VARCHAR2
    ,p_insurance_estimate_id   IN  NUMBER
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ) IS

    l_program_name         CONSTANT VARCHAR2(30) := 'delete_insurance_estimate';
    l_api_name             CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_program_name;

  BEGIN

    IF p_transaction_control = G_TRUE THEN
      SAVEPOINT l_program_name;
    END IF;

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    okl_lease_quote_cashflow_pvt.delete_cashflows (
      p_api_version         => G_API_VERSION
     ,p_init_msg_list       => G_FALSE
     ,p_transaction_control => G_FALSE
     ,p_source_object_code  => 'QUOTED_INSURANCE'
     ,p_source_object_id    => p_insurance_estimate_id
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
    );

    IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM okl_insurance_estimates_tl WHERE id = p_insurance_estimate_id;
    DELETE FROM okl_insurance_estimates_b WHERE id = p_insurance_estimate_id;

    x_return_status := G_RET_STS_SUCCESS;

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

  END delete_insurance_estimate;


END OKL_LEASE_QUOTE_INS_PVT;

/
