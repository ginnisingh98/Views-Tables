--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_ACCRUALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_ACCRUALS_PUB" AS
/* $Header: OKLPACRB.pls 120.3.12010000.3 2008/10/20 19:41:15 apaul ship $ */

FUNCTION SUBMIT_ACCRUALS(
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_api_version IN NUMBER,
    p_accrual_date IN DATE,
    p_batch_name IN VARCHAR2 ) RETURN NUMBER IS

    l_api_version       NUMBER := 1.0;
    l_api_name          CONSTANT VARCHAR2(30)  := 'SUBMIT_ACCRUALS';
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_request_id        NUMBER;

BEGIN

  SAVEPOINT SUBMIT_ACCRUALS;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- Execute the Main Procedure

  x_request_id := OKL_GENERATE_ACCRUALS_PVT.SUBMIT_ACCRUALS(
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_api_version => l_api_version,
                                p_accrual_date => p_accrual_date,
                                p_batch_name => p_batch_name);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  RETURN x_request_id;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SUBMIT_ACCRUALS;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      --Bug 3074377. Adding return statement.
      RETURN x_request_id;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SUBMIT_ACCRUALS;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      --Bug 3074377. Adding return statement.
      RETURN x_request_id;

  WHEN OTHERS THEN
      ROLLBACK TO SUBMIT_ACCRUALS;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUAL_PUB','SUBMIT_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --Bug 3074377. Adding return statement.
      RETURN x_request_id;

END SUBMIT_ACCRUALS;

  -- This API is used to display the contract receivable value for the accrual override screen
  FUNCTION CALCULATE_CNTRCT_REC(p_ctr_id IN OKC_K_HEADERS_B.id%TYPE) RETURN NUMBER IS
    l_receivable_balance NUMBER;
  BEGIN
    l_receivable_balance := OKL_GENERATE_ACCRUALS_PVT.CALCULATE_CNTRCT_REC(
                                p_ctr_id => p_ctr_id);

    RETURN l_receivable_balance;
  END CALCULATE_CNTRCT_REC;

  --This API Validates the Accrual Rule for a Contract
  PROCEDURE VALIDATE_ACCRUAL_RULE(x_return_status OUT NOCOPY VARCHAR2
                                 ,x_msg_count OUT NOCOPY NUMBER
								 ,x_msg_data OUT NOCOPY VARCHAR2
                                 ,x_result OUT NOCOPY VARCHAR2
                                 ,p_ctr_id IN OKL_K_HEADERS.ID%TYPE) IS

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.VALIDATE_ACCRUAL_RULE
	  (x_return_status => x_return_status
      ,x_result => x_result
      ,p_ctr_id => p_ctr_id
	  );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','VALIDATE_ACCRUAL_RULE');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END VALIDATE_ACCRUAL_RULE;

  -- This API performs the accrual catchup process
  PROCEDURE CATCHUP_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_catchup_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type,
    p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY' --MGAAP 7263041
    ) IS

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.CATCHUP_ACCRUALS (
                           p_api_version => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_catchup_rec => p_catchup_rec,
                           x_return_status => x_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data => x_msg_data,
                           x_tcnv_tbl => x_tcnv_tbl,
                           x_tclv_tbl => x_tclv_tbl,
                           p_representation_type => p_representation_type
                           );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','CATCHUP_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END CATCHUP_ACCRUALS;

  -- This API performs the accrual reversal process
  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_reverse_rec IN accrual_rec_type,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    x_tcnv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tcnv_tbl_type,
    x_tclv_tbl OUT NOCOPY OKL_TRX_CONTRACTS_PUB.tclv_tbl_type
    ) IS

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.REVERSE_ACCRUALS (
                           p_api_version => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_reverse_rec => p_reverse_rec,
                           x_return_status => x_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data => x_msg_data,
                           x_tcnv_tbl => x_tcnv_tbl,
                           x_tclv_tbl => x_tclv_tbl
                           );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','REVERSE_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END REVERSE_ACCRUALS;

  PROCEDURE REVERSE_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_khr_id IN NUMBER,
    p_reversal_date IN DATE,
    p_accounting_date IN DATE,
    p_reverse_from IN DATE,
    p_reverse_to IN DATE,
    p_tcn_type IN VARCHAR2) IS

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.REVERSE_ACCRUALS (
                 p_api_version       => p_api_version,
                 p_init_msg_list     => p_init_msg_list,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count,
                 x_msg_data          => x_msg_data,
                 p_khr_id            => p_khr_id,
                 p_reversal_date     => p_reversal_date,
                 p_accounting_date   => p_accounting_date,
                 p_reverse_from      => p_reverse_from,
                 p_reverse_to        => p_reverse_to,
                 p_tcn_type          => p_tcn_type);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','REVERSE_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END REVERSE_ACCRUALS;

  PROCEDURE REVERSE_ALL_ACCRUALS (
    p_api_version IN NUMBER,
	p_init_msg_list IN VARCHAR2,
    p_khr_id IN NUMBER,
    p_reverse_date IN DATE,
    p_description IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2) IS

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.REVERSE_ALL_ACCRUALS (
                           p_api_version => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_khr_id => p_khr_id,
                           p_reverse_date => p_reverse_date,
                           p_description => p_description,
                           x_return_status => x_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','REVERSE_ALL_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END REVERSE_ALL_ACCRUALS;

  -- This API accelerates accrual
  PROCEDURE ACCELERATE_ACCRUALS (
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
	p_acceleration_rec IN acceleration_rec_type,
     p_representation_type IN VARCHAR2 DEFAULT 'PRIMARY', --MGAAP 7263041
     x_trx_number OUT NOCOPY OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE) IS --MGAAP 7263041

  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;

    OKL_GENERATE_ACCRUALS_PVT.ACCELERATE_ACCRUALS (
                           p_api_version => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count => x_msg_count,
                           x_msg_data => x_msg_data,
                           p_acceleration_rec => p_acceleration_rec,
                           p_representation_type => p_representation_type,
                           x_trx_number => x_trx_number);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_GENERATE_ACCRUALS_PUB','ACCELERATE_ACCRUALS');
      FND_MSG_PUB.Count_and_get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ACCELERATE_ACCRUALS;

END OKL_GENERATE_ACCRUALS_PUB;

/
