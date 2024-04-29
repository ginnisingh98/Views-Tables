--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_REBOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_REBOOK_PUB" AS
/* $Header: OKLPRBKB.pls 115.0 2002/04/11 17:56:11 pkm ship     $*/

-- Global Variables
   G_DEBUG       NUMBER := 1;
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_CONTRACT_REBOOK_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';

--   subtype tcnv_rec_type IS OKL_TRX_CONTRACTS_PVT.tcnv_rec_type;
   subtype stmv_rec_type IS OKL_STREAMS_PUB.stmv_rec_type;
   subtype selv_rec_type IS OKL_STREAMS_PUB.selv_rec_type;
   subtype selv_tbl_type IS OKL_STREAMS_PUB.selv_tbl_type;
   subtype khrv_rec_type IS OKL_CONTRACT_PUB.khrv_rec_type;
   subtype chrv_rec_type IS OKL_OKC_MIGRATION_PVT.chrv_rec_type;


------------------------------------------------------------------------------
-- PROCEDURE sync_rebook_orig_contract
--
--  This procedure synchronize Rebook and Original Contract and make Rebook
--  contract status 'ABANDONED'
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE sync_rebook_orig_contract(
                                      p_api_version        IN  NUMBER,
                                      p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_msg_count          OUT NOCOPY NUMBER,
                                      x_msg_data           OUT NOCOPY VARCHAR2,
                                      p_rebook_chr_id      IN  OKC_K_HEADERS_V.ID%TYPE
                                     ) IS
  l_api_name    VARCHAR2(35)    := 'sync_rebook_orig_contract';
  l_proc_name   VARCHAR2(35)    := 'SYNC_REBOOK_ORIG_CONTRACT';

  l_orig_chr_id OKC_K_HEADERS_V.ID%TYPE;
  l_khrv_rec    khrv_rec_type;
  l_chrv_rec    chrv_rec_type;

  x_khrv_rec    khrv_rec_type;
  x_chrv_rec    chrv_rec_type;

  BEGIN

    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKC_API.START_ACTIVITY(
	                                      p_api_name      => l_api_name,
	                                      p_pkg_name      => G_PKG_NAME,
	                                      p_init_msg_list => p_init_msg_list,
	                                      l_api_version   => p_api_version,
	                                      p_api_version   => p_api_version,
	                                      p_api_type      => G_API_TYPE,
	                                      x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    okl_contract_rebook_pvt.sync_rebook_orig_contract(
                                                      p_api_version        => p_api_version,
                                                      p_init_msg_list      => p_init_msg_list,
                                                      x_return_status      => x_return_status,
                                                      x_msg_count          => x_msg_count,
                                                      x_msg_data           => x_msg_data,
                                                      p_rebook_chr_id      => p_rebook_chr_id
                                                     );

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END sync_rebook_orig_contract;

------------------------------------------------------------------------------
-- PROCEDURE create_txn_contract
--
--  This procedure creates Rebook Contract and Create a Transaction for that
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_txn_contract(
                                p_api_version        IN  NUMBER,
                                p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_msg_count          OUT NOCOPY NUMBER,
                                x_msg_data           OUT NOCOPY VARCHAR2,
                                p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                p_rebook_reason_code IN  VARCHAR2,
                                p_rebook_description IN  VARCHAR2,
                                p_trx_date           IN  DATE,
                                x_tcnv_rec           OUT NOCOPY tcnv_rec_type,
                                x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                               ) IS

  l_api_name    VARCHAR2(35)    := 'create_txn_contract';
  l_proc_name   VARCHAR2(35)    := 'CREATE_TXN_CONTRACT';
  l_api_version CONSTANT NUMBER := 1;

  BEGIN -- main process begins here

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      okl_contract_rebook_pvt.create_txn_contract(
                                                  p_api_version        => p_api_version,
                                                  p_init_msg_list      => p_init_msg_list,
                                                  x_return_status      => x_return_status,
                                                  x_msg_count          => x_msg_count,
                                                  x_msg_data           => x_msg_data,
                                                  p_from_chr_id        => p_from_chr_id,
                                                  p_rebook_reason_code => p_rebook_reason_code,
                                                  p_rebook_description => p_rebook_description,
                                                  p_trx_date           => p_trx_date,
                                                  x_tcnv_rec           => x_tcnv_rec,
                                                  x_rebook_chr_id      => x_rebook_chr_id
                                                 );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_txn_contract;

------------------------------------------------------------------------------
-- PROCEDURE sync_rebook_stream
--
--  This procedure Synchronizes between Rebooked Contract Stream and Orginal Stream
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE sync_rebook_stream(
                               p_api_version        IN  NUMBER,
                               p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER,
                               x_msg_data           OUT NOCOPY VARCHAR2,
                               p_chr_id             IN  OKC_K_HEADERS_V.ID%TYPE,
                               p_stream_status      IN  OKL_STREAMS.SAY_CODE%TYPE
                              ) IS

  l_api_name    VARCHAR2(35)    := 'sync_rebook_stream';
  l_proc_name   VARCHAR2(35)    := 'SYNC_REBOOK_STREAM';

  l_orig_chr_id NUMBER;

  BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--**********************************************************

      okl_contract_rebook_pvt.sync_rebook_stream(
                                                 p_api_version        => p_api_version,
                                                 p_init_msg_list      => p_init_msg_list,
                                                 x_return_status      => x_return_status,
                                                 x_msg_count          => x_msg_count,
                                                 x_msg_data           => x_msg_data,
                                                 p_chr_id             => p_chr_id,
                                                 p_stream_status      => 'CURR'
                                                );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END sync_rebook_stream;

------------------------------------------------------------------------------
-- PROCEDURE create_rebook_contract
--
--  This procedure creates a Rebook Contract from Original Contract provieded as parameter
--  p_from_chr_id and set the status of new contract as 'ENTERED'.
--  This process does not touch/chnage the original contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------

  PROCEDURE create_rebook_contract(
                                   p_api_version        IN  NUMBER,
                                   p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2,
                                   p_from_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                                   x_rebook_chr_id      OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                                  ) IS

  l_api_name             VARCHAR2(35)    := 'create_rebook_contract';
  l_proc_name            VARCHAR2(35)    := 'CREATE_REBOOK_CONTRACT';

  l_orig_chr_id NUMBER;

  BEGIN

      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;
--**********************************************************

      okl_contract_rebook_pvt.create_rebook_contract(
                                                     p_api_version        => p_api_version,
                                                     p_init_msg_list      => p_init_msg_list,
                                                     x_return_status      => x_return_status,
                                                     x_msg_count          => x_msg_count,
                                                     x_msg_data           => x_msg_data,
                                                     p_from_chr_id        => p_from_chr_id,
                                                     x_rebook_chr_id      => x_rebook_chr_id
                                                    );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

--**********************************************************
      OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count,
                           x_msg_data    => x_msg_data);

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END create_rebook_contract;

END OKL_CONTRACT_REBOOK_PUB;

/
